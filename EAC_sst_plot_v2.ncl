load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
;load "./WRFUserARW.ncl"

  OUTDir = "/srv/ccrc/data36/z3478332/WRF/output/"  

  res                 = True
; Set some contouring resources.
  res@cnFillOn        = True
  res@cnLinesOn       = False
  res@cnLineLabelsOn  = False
  res@cnInfoLabelOn   = False

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
  res@mpLeftCornerLonF   = 135.
  res@mpRightCornerLatF  = -20.
  res@mpRightCornerLonF  = 165. 
    res@mpGridLineDashPattern = 2
  res@mpGridLineThicknessF = 0.5
  res@mpProjection = "CylindricalEquidistant"
  
; Add label bar resources
  res@lbLabelAutoStride = True 
  res@lbBoxMinorExtentF        = 0.13
  res@lbLabelFontHeightF       = 0.012

  res@gsnLeftStringFontHeightF = 0.01
  res@gsnRightStringFontHeightF = 0.008
  res@gsnMaximize     = False    ; Maximize plot in frame


  fin=addfile("/srv/ccrc/data13/z3393020/Analyses/share/geo_em_files/geo_em.d01.narclim.nc","r")
  lat2=rm_single_dims(wrf_user_getvar(fin,"XLAT_M",-1))
  lon2=rm_single_dims(wrf_user_getvar(fin,"XLONG_M",-1))

  CONTDir="/srv/ccrc/data36/z3478332/WRF/WRF_boundary/default_bran_2007/"
  DATADir="/srv/ccrc/data37/z3478332/WRF/WRF_boundary/default_bran_2007_2eac/"

  FILES1 = systemfunc (" ls -1 " + CONTDir + "wrflowinp_d01_????-??")
  f1 = addfiles(FILES1+".nc","r")
  sst1=dim_avg_n_Wrap(wrf_user_getvar(f1,"SST",-1),0)
  FILES2 = systemfunc (" ls -1 " + DATADir + "wrflowinp_d01_????-??")
  f2 = addfiles(FILES2+".nc","r")
  sst2=dim_avg_n_Wrap(wrf_user_getvar(f2,"SST",-1),0)

  diff=where(sst2.eq.0.or.sst2.le.sst1,-999999.,sst2-sst1)
  diff@_FillValue=-999999.
  diff@lat2d = lat2
  diff@lon2d = lon2
  diff@description = "Average SST Difference"
  diff@units = "K"

  outfile1=OUTDir+"d01_EAC_average_ESB"

  wks = gsn_open_wks("pdf", outfile1)  ; Open graphics file
      gsn_define_colormap(wks,"WhiteYellowOrangeRed")      

  map = gsn_csm_contour_map(wks, diff, res)
  draw(map)

a=namedcolor2rgb("blue")
index=NhlNewColor(wks,a(0,0),a(0,1),a(0,2))
resline2 = True
resline2@gsLineColor = index
resline2@gsLineThicknessF = 4.0
resline2@gsLineDashPattern = 2
gsn_polyline(wks,map,(/149,161,161,152,152,149,149/),(/-41,-41,-24,-24,-31,-37,-41/),resline2)
  frame(wks)
  delete([/map,wks/])

