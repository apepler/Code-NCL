load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
;load "./WRFUserARW.ncl"

begin

  OUTDir = "/srv/ccrc/data34/z3478332/WRF/output/"  
  DATADir = "/srv/ccrc/data34/z3478332/WRF/output/ERAI_R2_nudging_default_2007_50/out/"
  outfile=OUTDir+"D01_prlr_default_50"


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


  f1 = addfile(DATADir+"wrfhrly_d01_2007-01-01_00:00:00.nc","r")
  lat1 = wrf_user_getvar(f1,"XLAT",0)
  lon1 = wrf_user_getvar(f1,"XLONG",0)
  f1a = addfile(DATADir+"wrfhrly_d01_2007-12-01_00:00:00.nc","r")
  times = wrf_user_getvar(f1a,"times",-1)
  len=dimsizes(times)-1 

  rain_exp1a=wrf_user_getvar(f1a,"RAINNC",len)
  rain_exp1b=wrf_user_getvar(f1,"RAINNC",0)
  rain_con1a=wrf_user_getvar(f1a,"RAINC",len)
  rain_con1b=wrf_user_getvar(f1,"RAINC",0)
  var1 = rain_exp1a + rain_con1a -rain_exp1b - rain_con1b
    var1@description = "Total Precipitation in 2007"
    var1@units = "mm"
    var1@lat2d = lat1
    var1@lon2d = lon1
    map = gsn_csm_contour_map(wks, var1, res)
    draw(map)
    frame(wks)

delete(wks)
end


