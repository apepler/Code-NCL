load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"
;load "./WRFUserARW.ncl"

begin

  OUTDir = "/srv/ccrc/data34/z3478332/WRF/output/"  
  DATADir = "/srv/ccrc/data36/z3478332/WRF/output/ERAI_R2_nudging_default_2007/out/"
  outfile=OUTDir+"D02_prlr_default"


  wks = gsn_open_wks("pdf", outfile+"_monthlytotals")  ; Open graphics file
  colors= (/"White","White","DarkOliveGreen1", \
                               "DarkOliveGreen3","Chartreuse", \
                               "Chartreuse3","Green","ForestGreen", \
                               "Yellow","Orange","Red","Violet","Violet"/)
          ; choose colormap
  res                 = True
; Set some contouring resources.
  res@cnFillOn        = True
  res@cnLinesOn       = False
  res@cnLineLabelsOn  = False
  res@cnInfoLabelOn   = False
  res@cnLevelSelectionMode = "ExplicitLevels"
  res@cnLevels             = (/ 1., 5., 10., 25., 50., 100., 200., 300./)
  res@cnFillColors         = (/"White","DarkOliveGreen1", \
                               "Green","ForestGreen", \
                               "Yellow","Orange","Red","Violet","MidnightBlue"/)
  res@gsnDraw         = False
  res@gsnFrame        = False

; Add map resources
  res@mpFillOn              = False
  res@mpDataBaseVersion     = "MediumRes"          ; Default is LowRes
  res@mpOutlineDrawOrder    = "PostDraw"           ; Draw map outlines last
  res@mpGridAndLimbOn       = False                ; Turn off lat/lon lines
  res@pmTickMarkDisplayMode = "Always"             ; Turn on map tickmarks
;  res = set_mp_wrf_map_resources(f1[0],res)
  res@mpLimitMode        = "Corners"               ; Portion of map to zoom
  res@mpLeftCornerLatF   = -50. 
  res@mpLeftCornerLonF   = 130.
  res@mpRightCornerLatF  = -20.
  res@mpRightCornerLonF  = 180. 
    res@mpGridLineDashPattern = 2
  res@mpGridLineThicknessF = 0.5
  res@mpProjection = "CylindricalEquidistant"
  
; Add label bar resources
  res@lbLabelAutoStride = True 
  res@lbBoxMinorExtentF        = 0.13
  res@lbLabelFontHeightF       = 0.012

  res@gsnLeftStringFontHeightF = 0.01
  res@gsnRightStringFontHeightF = 0.008
  res@gsnMaximize     = True    ; Maximize plot in frame


;  rain = new((/12,144,215/),"float")
  rain = new((/12,200,325/),"float")
  rain@description = "Total Precipitation"
  rain@units = "mm"

  f1 = addfile(DATADir+"wrfhrly_d02_2007-06-01_00:00:00.nc","r")
  lat1 = wrf_user_getvar(f1,"XLAT",0)
  lon1 = wrf_user_getvar(f1,"XLONG",0)
  rain@lat2d = lat1
  rain@lon2d = lon1

  i=1
  do while(i.le.12)

  f1 = addfile(DATADir+"wrfhrly_d02_2007-"+sprinti("%0.2i",i)+"-01_00:00:00.nc","r")
  lat1 = wrf_user_getvar(f1,"XLAT",0)
  lon1 = wrf_user_getvar(f1,"XLONG",0)
  times = wrf_user_getvar(f1,"times",-1)
  len=dimsizes(times)-1 

  rain_exp1a=wrf_user_getvar(f1,"RAINNC",len)
  rain_exp1b=wrf_user_getvar(f1,"RAINNC",0)
  rain_exp=rain_exp1a-rain_exp1b

  if (any(rain_exp1a.lt.rain_exp1b)) then
     rain_exp2a=ndtooned(rain_exp1a)
     rain_exp2b=ndtooned(rain_exp1b)
     a=ind(rain_exp2a.lt.rain_exp2b)
     rain_exp2a(a)=rain_exp2a(a)+1000
     rain_exp=onedtond(rain_exp2a-rain_exp2b, dimsizes(rain_exp1a)) 
     delete(a)
  end if

  rain_con1a=wrf_user_getvar(f1,"RAINC",len)
  rain_con1b=wrf_user_getvar(f1,"RAINC",0)
  rain_con=rain_con1a-rain_con1b

  if (any(rain_con1a.lt.rain_con1b)) then
     rain_con2a=ndtooned(rain_con1a)
     rain_con2b=ndtooned(rain_con1b)     
     a=ind(rain_con2a.lt.rain_con2b)
     rain_con2a(a)=rain_con2a(a)+1000
     rain_con=onedtond(rain_con2a-rain_con2b, dimsizes(rain_exp1a))
     delete(a)
  end if

  rain(i-1,:,:) = rain_exp + rain_con

    map = gsn_csm_contour_map(wks, rain(i-1,:,:), res)
    draw(map)
    frame(wks)

   delete(times) 
print(i)
i=i+1

end do
delete(wks)

var1=dim_sum_n_Wrap(rain,0)
var1@lat2d = lat1
var1@lon2d = lon1

  wks = gsn_open_wks("pdf", outfile+"_annualtotal")  ; Open graphics file
  colors= (/"White","White","DarkOliveGreen1", \
                               "DarkOliveGreen3","Chartreuse", \
                               "Chartreuse3","Green","ForestGreen", \
                               "Yellow","Orange","Red","Violet","Violet"/)
          ; choose colormap
  res                 = True
; Set some contouring resources.
  res@cnFillOn        = True
  res@cnLinesOn       = False
  res@cnLineLabelsOn  = False
  res@cnInfoLabelOn   = False
  res@cnLevelSelectionMode = "ExplicitLevels"
  res@cnLevels             = (/ 50., 100., 200., 300., 600., \
                                900., 1200., 1800./)
  res@cnFillColors         = (/"White","DarkOliveGreen1", \
                               "Green","ForestGreen", \
                               "Yellow","Orange","Red","Violet","MidnightBlue"/)
  res@gsnDraw         = False
  res@gsnFrame        = False

; Add map resources
  res@mpFillOn              = False
  res@mpDataBaseVersion     = "MediumRes"          ; Default is LowRes
  res@mpOutlineDrawOrder    = "PostDraw"           ; Draw map outlines last
  res@mpGridAndLimbOn       = False                ; Turn off lat/lon lines
  res@pmTickMarkDisplayMode = "Always"             ; Turn on map tickmarks
;  res = set_mp_wrf_map_resources(f1[0],res)
  res@mpLimitMode        = "Corners"               ; Portion of map to zoom
  res@mpLeftCornerLatF   = -50. 
  res@mpLeftCornerLonF   = 130.
  res@mpRightCornerLatF  = -20.
  res@mpRightCornerLonF  = 180. 
    res@mpGridLineDashPattern = 2
  res@mpGridLineThicknessF = 0.5
  res@mpProjection = "CylindricalEquidistant"
  
; Add label bar resources
  res@lbLabelAutoStride = True 
  res@lbBoxMinorExtentF        = 0.13
  res@lbLabelFontHeightF       = 0.012

  res@gsnLeftStringFontHeightF = 0.01
  res@gsnRightStringFontHeightF = 0.008
  res@gsnMaximize     = True    ; Maximize plot in frame

    map = gsn_csm_contour_map(wks, var1, res)
    draw(map)
    frame(wks)

end


