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
  res@cnLevels             = (/ -50.,-40.,-30., -20., -10., -5., 5., 10., 20., 30., 40., 50./)
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

diff1 = new((/20,30,144,215/),"float")
diff2 = new((/20,30,200,325/),"float")

  fin=addfile("/srv/ccrc/data13/z3393020/Analyses/share/geo_em_files/geo_em.d01.narclim.nc","r")
  diff1@lat2d = rm_single_dims(wrf_user_getvar(fin,"XLAT_M",-1))
  diff1@lon2d = rm_single_dims(wrf_user_getvar(fin,"XLONG_M",-1))
  delete(fin)
  fin=addfile("/srv/ccrc/data13/z3393020/Analyses/share/geo_em_files/geo_em.d02.narclim.nc","r")
  diff2@lat2d = rm_single_dims(wrf_user_getvar(fin,"XLAT_M",-1))
  diff2@lon2d = rm_single_dims(wrf_user_getvar(fin,"XLONG_M",-1))
  OUTDir= "/srv/ccrc/data36/z3478332/WRF/output/ERAI_R3_ensemble_notopo/out/"


month=6
hour=(/"00","06","12","18"/)
day=27
n=0


do while(day.le.31)
hh=0
do while(hh.lt.4)

  print("200705"+day+hour(hh))

  DATADir = "/srv/ccrc/data36/z3478332/WRF/output/ERAI_R3_ensemble_notopo/out/200705"+day+hour(hh)+"/"
  CONTDir = "/srv/ccrc/data36/z3478332/WRF/output/ERAI_R3_ensemble/out/200705"+day+hour(hh)+"/"

  f1 = addfile(DATADir+"wrfhrly_d01_2007-"+sprinti("%0.2i",month)+"-01_00:00:00.nc","r")
  f1a = addfile(CONTDir+"wrfhrly_d01_2007-"+sprinti("%0.2i",month)+"-01_00:00:00.nc","r")
  times = wrf_user_getvar(f1,"times",-1)
  len=dimsizes(times)-1 
  numDAYS = dimsizes(times)/24

  rain_exp1a=wrf_user_getvar(f1,"RAINNC",-1)
  rain_exp1b=wrf_user_getvar(f1a,"RAINNC",-1)
  rain_con1a=wrf_user_getvar(f1,"RAINC",-1)
  rain_con1b=wrf_user_getvar(f1a,"RAINC",-1)
  var1 = rain_exp1a + rain_con1a -rain_exp1b - rain_con1b 

  delete([/times,f1,f1a,len/])
  delete([/rain_exp1a,rain_exp1b,rain_con1a,rain_con1b/])

  f1 = addfile(DATADir+"wrfhrly_d02_2007-"+sprinti("%0.2i",month)+"-01_00:00:00.nc","r")
  f1a = addfile(CONTDir+"wrfhrly_d02_2007-"+sprinti("%0.2i",month)+"-01_00:00:00.nc","r")
  times = wrf_user_getvar(f1,"times",-1)
  len=dimsizes(times)-1 
  rain_exp1a=wrf_user_getvar(f1,"RAINNC",-1)
  rain_exp1b=wrf_user_getvar(f1a,"RAINNC",-1)
  rain_con1a=wrf_user_getvar(f1,"RAINC",-1)
  rain_con1b=wrf_user_getvar(f1a,"RAINC",-1)
  var2 = rain_exp1a + rain_con1a -rain_exp1b - rain_con1b

do ip = 1,numDAYS-1      
   diff1(n,ip-1,:,:) = (var1(ip*24,:,:) - var1((ip-1)*24,:,:))
   diff2(n,ip-1,:,:) = (var2(ip*24,:,:) - var2((ip-1)*24,:,:))
end do
   diff1(n,numDAYS-1,:,:) = (var1(numDAYS*24-1,:,:) - var1((numDAYS-1)*24,:,:))
   diff2(n,numDAYS-1,:,:) = (var2(numDAYS*24-1,:,:) - var2((numDAYS-1)*24,:,:))

  if(n.eq.0)
    TT=times(0:dimsizes(times)-1:24)
  end if

  delete([/times,f1,f1a,len,var1,var2/])
  delete([/rain_exp1a,rain_exp1b,rain_con1a,rain_con1b/])

hh=hh+1
n=n+1
end do
day=day+1
end do

  diff1a=dim_avg_n_Wrap(diff1,0)
  diff2a=dim_avg_n_Wrap(diff2,0)

  diff1a@units = "mm"
  diff2a@units = "mm"
  diff1a@description = "Average 24hr rainfall difference"
  diff2a@description = "Average 24hr rainfall difference"
  
  ndiff1a = dim_num_n(diff1.lt.0,0)*5 
  ndiff2a = dim_num_n(diff2.lt.0,0)*5
  copy_VarAtts(diff1a,ndiff1a)
  copy_VarAtts(diff2a,ndiff2a)

  ndiff1a@units = "%"
  ndiff2a@units = "%"  
  ndiff1a@description = "Proportion of runs  with decreased rainfall"
  ndiff2a@description = "Proportion of runs  with decreased rainfall"

  outfile1=OUTDir+"D01_prlr_notopo_dailyanom_mean"
  outfile2=OUTDir+"D02_prlr_notopo_dailyanom_mean"

  wks = gsn_open_wks("pdf", outfile1)  ; Open graphics file
      gsn_define_colormap(wks,"precip_diff_12lev")      
  do ip = 0,numDAYS-1      
    res@tiMainString=TT(ip)
    map = gsn_csm_contour_map(wks, diff1a(ip,:,:), res)
    draw(map)
    frame(wks)
  end do
  delete([/map,wks/])

  wks = gsn_open_wks("pdf", outfile2)  ; Open graphics file
      gsn_define_colormap(wks,"precip_diff_12lev")      
  do ip = 0,numDAYS-1      
    res@tiMainString=TT(ip)
    map = gsn_csm_contour_map(wks, diff2a(ip,:,:), res)
    draw(map)
    frame(wks)
  end do
  delete([/map,wks,outfile1,outfile2/])

  delete(res@cnLevels)
  res@cnLevels             = (/ 10,25,35,45,55,65,75,90/)
  res@cnFillColors         = (/13,12,11,10,8,6,5,4,3/)
  outfile1=OUTDir+"D01_prlr_notopo_dailyanom_prop"
  outfile2=OUTDir+"D02_prlr_notopo_dailyanom_prop"

  wks = gsn_open_wks("pdf", outfile1)  ; Open graphics file
      gsn_define_colormap(wks,"precip_diff_12lev")      
  do ip = 1,numDAYS-1      
    res@tiMainString=TT(ip)
    map = gsn_csm_contour_map(wks, ndiff1a(ip,:,:), res)
    draw(map)
    frame(wks)
  end do
  delete([/map,wks/])

  wks = gsn_open_wks("pdf", outfile2)  ; Open graphics file
      gsn_define_colormap(wks,"precip_diff_12lev")      
  do ip = 1,numDAYS-1      
    res@tiMainString=TT(ip)
    map = gsn_csm_contour_map(wks, ndiff2a(ip,:,:), res)
    draw(map)
    frame(wks)
  end do
  delete([/map,wks,outfile1,outfile2/])


end


