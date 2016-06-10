load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
;load "$VAPOR_HOME/share/examples/NCL/wrf2geotiff.ncl"
;load "./WRFUserARW.ncl"

begin

  wks = gsn_open_wks("pdf", "gippsland_total_diff")  ; Open graphics file
    gsn_define_colormap(wks,"precip_diff_12lev")                ; choose colormap
;  wrf2gtiff = wrf2geotiff_open(wks) - For if doing VAPOR
  
  DATADir = "./"            ; note we assume here similar output frequency
  FILES1 = systemfunc (" ls -1 " + DATADir + "wrfout_d01_2007-06-??_??:00:00")
  numDAYS = dimsizes(FILES1)
  f1 = addfiles(FILES1(numDAYS-1)+".nc","r")
  
  CONTDir = "../Control/"            ; comparing to the SST success case
  FILES1a = systemfunc (" ls -1 " + CONTDir + "wrfout_d01_2007-06-??_??:00:00")
  f1a = addfiles(FILES1a(numDAYS-1)+".nc","r")

  lat1 = wrf_user_getvar(f1,"XLAT",-1)
  lon1 = wrf_user_getvar(f1,"XLONG",-1)
  times = wrf_user_getvar(f1,"times",-1)
  len=dimsizes(times)-1 
  
  res                 = True


; Set some contouring resources.
  res@cnFillOn        = True
  res@cnLinesOn       = False
  res@cnLineLabelsOn  = False
  res@cnInfoLabelOn   = False
  res@cnLevelSelectionMode = "ExplicitLevels"
  res@cnLevels             = (/ -50., -25., -10., -5., -2., -1., 1., 2., 5., 10., 25., 50./)
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

; So, we loop over each day, which has 8 observations in d01 and 24 obs in d02

    print("Working on time : " + times(len) )
    
   rain_exp1=wrf_user_getvar(f1,"RAINNC",len)-wrf_user_getvar(f1a,"RAINNC",len)
   rain_con1=wrf_user_getvar(f1,"RAINC",len)-wrf_user_getvar(f1a,"RAINC",len)
   rain_tot1 = rain_exp1 + rain_con1
   rain_tot1@description = "Total Precipitation to " + times(len)
   rain_tot1@units = "mm"
   rain_tot1@lat2d = lat1(0,:,:)
   rain_tot1@lon2d = lon1(0,:,:)
        
    map = gsn_csm_contour_map(wks, rain_tot1, res)
    draw(map)
    frame(wks)
  
end
