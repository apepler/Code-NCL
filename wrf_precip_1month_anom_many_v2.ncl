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

diff1 = new((/5,144,215/),"float")
diff2 = new((/5,200,325/),"float")

  fin=addfile("/srv/ccrc/data13/z3393020/Analyses/share/geo_em_files/geo_em.d01.narclim.nc","r")
  lat1=rm_single_dims(wrf_user_getvar(fin,"XLAT_M",-1))
  lon1=rm_single_dims(wrf_user_getvar(fin,"XLONG_M",-1))
  diff1@lat2d = lat1
  diff1@lon2d = lon1
  delete(fin)

  fin=addfile("/srv/ccrc/data13/z3393020/Analyses/share/geo_em_files/geo_em.d02.narclim.nc","r")
  lat2=rm_single_dims(wrf_user_getvar(fin,"XLAT_M",-1))
  lon2=rm_single_dims(wrf_user_getvar(fin,"XLONG_M",-1))
  diff2@lat2d = lat2
  diff2@lon2d = lon2

month=6

OUTDir="/srv/ccrc/data37/z3478332/WRF/output/ERAI_R1_ensemble_BRAN_noeac/out/"
hour=(/"00","06","12","18"/)
day=27
n=0


do while(day.le.31)
hh=0
do while(hh.lt.1)

  print("200705"+day+hour(hh))

  DATADir = "/srv/ccrc/data37/z3478332/WRF/output/ERAI_R1_ensemble_BRAN_noeac/out/200705"+day+hour(hh)+"/"
  CONTDir = "/srv/ccrc/data37/z3478332/WRF/output/ERAI_R1_ensemble_BRAN/out/200705"+day+hour(hh)+"/"

  f1 = addfile(DATADir+"wrfhrly_d01_2007-"+sprinti("%0.2i",month)+"-01_00:00:00.nc","r")
  f1a = addfile(CONTDir+"wrfhrly_d01_2007-"+sprinti("%0.2i",month)+"-01_00:00:00.nc","r")
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

  outfile=DATADir+"D01_prlr_bran_1monthanom"
  wks = gsn_open_wks("pdf", outfile)  ; Open graphics file
      gsn_define_colormap(wks,"precip_diff_12lev")       
  var1 = (var_in_dir-var_in_cont)
  var1@description = "Total Precipitation Difference in month "+month
  var1@units = "mm"
  var1@lat2d = lat1
  var1@lon2d = lon1
  map = gsn_csm_contour_map(wks, var1, res)
  draw(map)
  frame(wks)
  delete([/outfile,wks,var1,map/])

  diff1(n,:,:) = (var_in_dir-var_in_cont)
  delete([/times,f1,f1a,len/])
  delete([/rain_exp1a,rain_exp1b,rain_con1a,rain_con1b,var_in_dir,var_in_cont/])

  f1 = addfile(DATADir+"wrfhrly_d02_2007-"+sprinti("%0.2i",month)+"-01_00:00:00.nc","r")
  f1a = addfile(CONTDir+"wrfhrly_d02_2007-"+sprinti("%0.2i",month)+"-01_00:00:00.nc","r")
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

  outfile=DATADir+"D02_prlr_bran_1monthanom"
  wks = gsn_open_wks("pdf", outfile)  ; Open graphics file
      gsn_define_colormap(wks,"precip_diff_12lev")       
  var1 = (var_in_dir-var_in_cont)
  var1@description = "Total Precipitation Difference in month "+month
  var1@units = "mm"
  var1@lat2d = lat2
  var1@lon2d = lon2
  map = gsn_csm_contour_map(wks, var1, res)
  draw(map)
  frame(wks)
  delete([/outfile,wks,var1,map/])

  diff2(n,:,:) = (var_in_dir-var_in_cont)

  delete([/times,f1,f1a,len/])
  delete([/rain_exp1a,rain_exp1b,rain_con1a,rain_con1b,var_in_dir,var_in_cont/])

hh=hh+1
n=n+1
end do
day=day+1
end do

  diff1a=dim_avg_n_Wrap(diff1,0)
  diff2a=dim_avg_n_Wrap(diff2,0)

  diff1a@description = "Average Precipitation Difference in June 2007"
  diff1a@units = "mm"
  diff2a@description = "Average Precipitation Difference in June 2007"
  diff2a@units = "mm"

  outfile1=OUTDir+"D01_prlr_bran_1monthanom_mean"
  outfile2=OUTDir+"D02_prlr_bran_1monthanom_mean"

  wks = gsn_open_wks("pdf", outfile1)  ; Open graphics file
      gsn_define_colormap(wks,"precip_diff_12lev")      

  map = gsn_csm_contour_map(wks, diff1a, res)
  draw(map)
  frame(wks)
  delete([/map,wks/])

  wks = gsn_open_wks("pdf", outfile2)  ; Open graphics file
      gsn_define_colormap(wks,"precip_diff_12lev")                ; choose colormap

  map = gsn_csm_contour_map(wks, diff2a, res)
  draw(map)
  frame(wks)
  delete([/map,wks,outfile1,outfile2/])

  ndiff1a = dim_num_n(diff1.lt.0,0)*100/n 
  ndiff2a = dim_num_n(diff2.lt.0,0)*100/n
  copy_VarAtts(diff1a,ndiff1a)
  copy_VarAtts(diff2a,ndiff2a)

  ndiff1a@description = "Proportion of runs with decreased rainfall"
  ndiff1a@units = "%"
  ndiff2a@description = "Proportion of runs with decreased rainfall"
  ndiff2a@units = "%"  


  outfile1=OUTDir+"D01_prlr_bran_1monthanom_prop"
  outfile2=OUTDir+"D02_prlr_bran_1monthanom_prop"
  res@cnLevelSelectionMode = "ExplicitLevels"

  delete(res@cnLevels)
  res@cnLevels             = (/ 10,25,35,45,55,65,75,90/)
  res@cnFillColors         = (/13,12,11,10,8,6,5,4,3/)

  wks = gsn_open_wks("pdf", outfile1)  ; Open graphics file
      gsn_define_colormap(wks,"precip_diff_12lev")      

  map = gsn_csm_contour_map(wks, ndiff1a, res)
  draw(map)
  frame(wks)
  delete([/map,wks/])

  wks = gsn_open_wks("pdf", outfile2)  ; Open graphics file
      gsn_define_colormap(wks,"precip_diff_12lev")                ; choose colormap

  map = gsn_csm_contour_map(wks, ndiff2a, res)
  draw(map)
  frame(wks)
  delete([/map,wks,outfile1,outfile2/])

end


