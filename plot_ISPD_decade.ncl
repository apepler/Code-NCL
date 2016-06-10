
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin
;-------Options--------

;  arr = (/1870,1900,1930,1949,1961/)
;  labels = (/"Pre-1900","1900-1929","1930-1948","1949-1960","Later"/)
;  color=(/15,16,18,20,1/)
;  tness=(/0.007,0.007,0.007,0.007,0.003/)

  arr = (/1870,1900,1910,1920,1930,1940,1950,1960/)
  labels = (/"Pre-1900","1900s","1910s","1920s","1930s","1940s","1950s"/)
  color=(/15,16,17,18,19,20,1/)
  tness=(/0.007,0.007,0.007,0.007,0.007,0.007,0.007/)
;---------------------------

  filename="/srv/ccrc/data34/z3478332/20CR/ispd_history_v2.2.4.txt"
  data= stringtochar(asciiread(filename,-1,"string"))
  year1=tointeger(charactertostring(data(:,21:24)))
  year2=tointeger(charactertostring(data(:,34:37)))
  lat = tofloat(charactertostring(data(:,47:52)))
  lon= tofloat(charactertostring(data(:,54:59)))

;------------------------------ 
; Create X and Y arrays to hold the points for each range and initialize
; them to missing values.  We want to use num_distinct_markers
; different colors, so we need num_distinct_markers sets of X and
; Y points.
;
  num_distinct_markers = dimsizes(arr)        ; number of distinct markers
  lat_new = new((/num_distinct_markers,dimsizes(lat)/),float,-999)
  lon_new = new((/num_distinct_markers,dimsizes(lat)/),float,-999)
;
; Group the points according to which range they fall in. At the
; same time, create the label that we will use later in the legend.
;       
  do i = 0, num_distinct_markers-1
    if (i.eq.num_distinct_markers-1) then
      indexes = ind(year1.ge.max(arr))
    end if
    if (i.gt.0.and.i.lt.num_distinct_markers-1) then       
      indexes = ind(year1.ge.arr(i).and.year1.lt.arr(i+1))
    end if
    if (i.eq.0) then       
      indexes = ind(year1.lt.arr(i+1))
    end if
;
; Now that we have the set of indexes whose values fall within 
; the given range, take the corresponding lat/lon values and store
; them, so later we can color this set of markers with the appropriate
; color.
;
    if (.not.any(ismissing(indexes))) then 
      npts_range = dimsizes(indexes)   ; # of points in this range.
      lat_new(i,0:npts_range-1) = lat(indexes)
      lon_new(i,0:npts_range-1) = lon(indexes)
    end if
    delete(indexes)            ; Necessary b/c "indexes" may be a different
                               ; size next time.
  end do

;===========================================================================
; Begin plotting section.
;

  wks_type = "pdf"
  wks_type@wkPaperHeightF = 6.
  wks_type@wkPaperWidthF = 8.
  wks = gsn_open_wks(wks_type,"/srv/ccrc/data34/z3478332/20CR/Figure1")     ; Open a workstation and
  gsn_define_colormap(wks,"prcp_3")      ; define a different colormap.
                

;
; Set up some map resources.
;
  mpres              = True
  mpres@gsnMaximize  = True             ; Maximize plot in frame.
  mpres@gsnPaperOrientation = "portrait"
  mpres@gsnFrame     = False            ; Don't advance the frame
;
; Zoom in on Australia
;
  mpres@mpMinLatF    = -60.
  mpres@mpMaxLatF    = 0.
  mpres@mpMinLonF    = 100.
  mpres@mpMaxLonF    = 180.

  mpres@tiMainString = ""
  map = gsn_csm_map(wks,mpres)

; Add an ECL domain
a=namedcolor2rgb("blue")
index=NhlNewColor(wks,a(0,0),a(0,1),a(0,2))
resline2 = True
resline2@gsLineColor = index
resline2@gsLineThicknessF = 4.0
resline2@gsLineDashPattern = 2
;gsn_polyline(wks,map,(/149,161,161,152,152,149,149/),(/-41,-41,-24,-24,-31,-37,-41/),resline2)


;
;  Create logical variables to hold the marker and text resources.
;  These markers are different than the XY markers, because they are not
;  associated with an XY plot. You can put these markers on any plot.
;
  gsres               = True
  gsres@gsMarkerIndex = 16          ; Use filled dots for markers.

  txres               = True
  txres@txFontHeightF = 0.015
;
; Loop through each grouping of markers, and draw them one set at
; a time, assigning the proper color and size with gsn_marker.
;
; At the same time, draw a legend showing the meaning of the markers.
;

;  xleg = (/0.15,0.30,0.45,0.60,0.75/)   ; Location of
;  xtxt = (/0.22,0.37,0.52,0.67,0.80/)   ; legend markers
;  yleg = (/0.22,0.22,0.22,0.22,0.22/)   ; and text
;  ytxt = (/0.22,0.22,0.22,0.22,0.22/)   ; strings.
  xleg = (/0.15,0.29,0.40,0.51,0.62,0.73,0.84/)   ; Location of
  xtxt = (/0.21,0.33,0.44,0.55,0.66,0.77,0.88/)   ; legend markers
  yleg = (/0.2,0.2,0.2,0.2,0.2,0.2,0.2/)   ; and text
  ytxt = (/0.2,0.2,0.2,0.2,0.2,0.2,0.2/)   ; strings.

  do i = 0,6
    if (.not.ismissing(lat_new(6-i,0)))
      gsres@gsMarkerColor      = color(6-i)
      gsres@gsMarkerSizeF = tness(6-i)
      gsn_polymarker(wks,map,lon_new(6-i,:),lat_new(6-i,:),gsres)
;
; Add marker and text for the legend.
;
     gsn_polymarker_ndc(wks,          xleg(6-i),yleg(6-i),gsres)
     gsn_text_ndc      (wks,labels(6-i),xtxt(6-i),ytxt(6-i),txres)
    end if
  end do
gsn_polyline(wks,map,(/149,161,161,152,152,149,149/),(/-41,-41,-24,-24,-31,-37,-41/),resline2)

  frame(wks)    ; Advance the frame.
end     

