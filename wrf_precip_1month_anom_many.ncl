load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
;load "./WRFUserARW.ncl"

begin

  res                 = True
; Set some contouring resources.
  res@cnFillOn        = True
  res@cnLinesOn       = False
  res@cnLineLabelsOn  = False
  res@cnInfoLabelOn   = False
  res@cnLevelSelectionMode = "ExplicitLevels"
  res@cnLevels             = (/ -200.,-100., -50., -25., -10., -5., 5., 10., 25., 50.,100.,200./)
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
  res@gsnMaximize     = False    ; Maximize plot in frame

month=6
hour=(/"00","06","12","18"/)
day=27

do while(day.le.31)
hh=0
do while(hh.lt.4)

  print("200705"+day+hour(hh))

  DATADir = "/srv/ccrc/data36/z3478332/WRF/output/ERAI_R2_ensemble_notopo/out/200705"+day+hour(hh)+"/"
  CONTDir = "/srv/ccrc/data36/z3478332/WRF/output/ERAI_R2_ensemble/out/200705"+day+hour(hh)+"/"
  OUTDir= "/srv/ccrc/data36/z3478332/WRF/output/ERAI_R2_ensemble_notopo/out/"
  outfile1=OUTDir+"D01_prlr_notopo_1monthanom_200705"+day+hour(hh)
  outfile2=OUTDir+"D02_prlr_notopo_1monthanom_200705"+day+hour(hh)


  wks = gsn_open_wks("pdf", outfile1)  ; Open graphics file
      gsn_define_colormap(wks,"precip_diff_12lev")                ; choose colormap

  f1 = addfile(DATADir+"wrfhrly_d01_2007-"+sprinti("%0.2i",month)+"-01_00:00:00.nc","r")
  f1a = addfile(CONTDir+"wrfhrly_d01_2007-"+sprinti("%0.2i",month)+"-01_00:00:00.nc","r")
  lat1 = wrf_user_getvar(f1,"XLAT",0)
  lon1 = wrf_user_getvar(f1,"XLONG",0)
  times = wrf_user_getvar(f1,"times",-1)
  len=dimsizes(times)-1 

  rain_exp1a=wrf_user_getvar(f1,"RAINNC",len)
  rain_exp1b=wrf_user_getvar(f1,"RAINNC",0)
  rain_con1a=wrf_user_getvar(f1,"RAINC",len)
  rain_con1b=wrf_user_getvar(f1,"RAINC",0)
  var_in_dir = rain_exp1a + rain_con1a -rain_exp1b - rain_con1b
 
  rain_exp1a=wrf_user_getvar(f1a,"RAINNC",len)
  rain_exp1b=wrf_user_getvar(f1a,"RAINNC",0)
  rain_con1a=wrf_user_getvar(f1a,"RAINC",len)
  rain_con1b=wrf_user_getvar(f1a,"RAINC",0)
  var_in_cont = rain_exp1a + rain_con1a -rain_exp1b - rain_con1b

  var1 = (var_in_dir-var_in_cont)
  var1@description = "Total Precipitation Difference in month "+month
  var1@units = "mm"
  var1@lat2d = lat1
  var1@lon2d = lon1
  map = gsn_csm_contour_map(wks, var1, res)
  draw(map)
  frame(wks)

  delete([/wks,times,map,var1,f1,f1a,lat1,lon1,len/])
  delete([/rain_exp1a,rain_exp1b,rain_con1a,rain_con1b,var_in_dir,var_in_cont/])


  wks = gsn_open_wks("pdf", outfile2)  ; Open graphics file
      gsn_define_colormap(wks,"precip_diff_12lev")                ; choose colormap

  f1 = addfile(DATADir+"wrfhrly_d02_2007-"+sprinti("%0.2i",month)+"-01_00:00:00.nc","r")
  f1a = addfile(CONTDir+"wrfhrly_d02_2007-"+sprinti("%0.2i",month)+"-01_00:00:00.nc","r")
  lat1 = wrf_user_getvar(f1,"XLAT",0)
  lon1 = wrf_user_getvar(f1,"XLONG",0)
  times = wrf_user_getvar(f1,"times",-1)
  len=dimsizes(times)-1 

  rain_exp1a=wrf_user_getvar(f1,"RAINNC",len)
  rain_exp1b=wrf_user_getvar(f1,"RAINNC",0)
  rain_con1a=wrf_user_getvar(f1,"RAINC",len)
  rain_con1b=wrf_user_getvar(f1,"RAINC",0)
  var_in_dir = rain_exp1a + rain_con1a -rain_exp1b - rain_con1b
 
  rain_exp1a=wrf_user_getvar(f1a,"RAINNC",len)
  rain_exp1b=wrf_user_getvar(f1a,"RAINNC",0)
  rain_con1a=wrf_user_getvar(f1a,"RAINC",len)
  rain_con1b=wrf_user_getvar(f1a,"RAINC",0)
  var_in_cont = rain_exp1a + rain_con1a -rain_exp1b - rain_con1b

  var1 = (var_in_dir-var_in_cont)
  var1@description = "Total Precipitation Difference in month "+month
  var1@units = "mm"
  var1@lat2d = lat1
  var1@lon2d = lon1
  map = gsn_csm_contour_map(wks, var1, res)
  draw(map)
  frame(wks)

  delete([/wks,times,map,var1,f1,f1a,lat1,lon1,len/])
  delete([/rain_exp1a,rain_exp1b,rain_con1a,rain_con1b,var_in_dir,var_in_cont/])


hh=hh+1
end do
day=day+1
end do
end


