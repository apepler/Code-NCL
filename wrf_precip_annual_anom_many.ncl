load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
;load "./WRFUserARW.ncl"

begin
  OUTDir="/srv/ccrc/data37/z3478332/WRF/output/"

  r=1
  year1=2007
  year2=2008

  res                 = True
; Set some contouring resources.
  res@cnFillOn        = True
  res@cnLinesOn       = False
  res@cnLineLabelsOn  = False
  res@cnInfoLabelOn   = False
  res@cnLevelSelectionMode = "ExplicitLevels"
  res@cnLevels             = (/-300., -200.,-100., -50., -25., -10., 10., 25., 50.,100.,200.,300./)
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

  fin=addfile("/srv/ccrc/data13/z3393020/Analyses/share/geo_em_files/geo_em.d01.narclim.nc","r")
  lat1=rm_single_dims(wrf_user_getvar(fin,"XLAT_M",-1))
  lon1=rm_single_dims(wrf_user_getvar(fin,"XLONG_M",-1))
  a=dimsizes(lat1)
  default_d01 = new((/a(0),a(1),3/),"float")
  default_d01@lat2d = lat1
  default_d01@lon2d = lon1
  notopo_d01 = default_d01
  delete([/a,fin/])

  fin=addfile("/srv/ccrc/data13/z3393020/Analyses/share/geo_em_files/geo_em.d02.narclim.nc","r")
  lat2=rm_single_dims(wrf_user_getvar(fin,"XLAT_M",-1))
  lon2=rm_single_dims(wrf_user_getvar(fin,"XLONG_M",-1))
  a=dimsizes(lat2)
  default_d02 = new((/a(0),a(1),3/),"float")
  default_d02@lat2d = lat2
  default_d02@lon2d = lon2
  notopo_d02 = default_d02
  delete([/a,fin/])

do while(r.le.3)
n=0
year=year1
do while(year.le.year1)
month=1
do while(month.le.12)

  DATADir = "/srv/ccrc/data37/z3478332/WRF/output/ERAI_R"+r+"_nudging_default_2007_BRAN_noeac/out/"
  CONTDir = "/srv/ccrc/data37/z3478332/WRF/output/ERAI_R"+r+"_nudging_default_2007_BRAN/out/"

  fname="wrfhrly_d01_"+year+"-"+sprinti("%0.2i",month)+"-01_00:00:00.nc"
  f1 = addfile(CONTDir+fname,"r")
  f2 = addfile(DATADir+fname,"r")

  rain_exp=wrf_user_getvar(f1,"PREC_ACC_NC",-1)
  rain_con=wrf_user_getvar(f1,"PREC_ACC_C",-1)
  rain_exp2=wrf_user_getvar(f2,"PREC_ACC_NC",-1)
  rain_con2=wrf_user_getvar(f2,"PREC_ACC_C",-1)

  if(n.eq.0) then
    default_d01(:,:,r-1)=dim_sum_n_Wrap(rain_exp,0)+dim_sum_n_Wrap(rain_con,0)
    notopo_d01(:,:,r-1)=dim_sum_n_Wrap(rain_exp2,0)+dim_sum_n_Wrap(rain_con2,0)
  else
    default_d01(:,:,r-1)=default_d01(:,:,r-1)+dim_sum_n_Wrap(rain_exp,0)+dim_sum_n_Wrap(rain_con,0)
    notopo_d01(:,:,r-1)=notopo_d01(:,:,r-1)+dim_sum_n_Wrap(rain_exp2,0)+dim_sum_n_Wrap(rain_con2,0)
  end if

  delete([/fname,f1,f2,rain_exp,rain_exp2,rain_con,rain_con2/])
 
  fname="wrfhrly_d02_"+year+"-"+sprinti("%0.2i",month)+"-01_00:00:00.nc"
  f1 = addfile(CONTDir+fname,"r")
  f2 = addfile(DATADir+fname,"r")

  rain_exp=wrf_user_getvar(f1,"PREC_ACC_NC",-1)
  rain_con=wrf_user_getvar(f1,"PREC_ACC_C",-1)
  rain_exp2=wrf_user_getvar(f2,"PREC_ACC_NC",-1)
  rain_con2=wrf_user_getvar(f2,"PREC_ACC_C",-1)

  if(n.eq.0) then
    default_d02(:,:,r-1)=dim_sum_n_Wrap(rain_exp,0)+dim_sum_n_Wrap(rain_con,0)
    notopo_d02(:,:,r-1)=dim_sum_n_Wrap(rain_exp2,0)+dim_sum_n_Wrap(rain_con2,0)
  else
    default_d02(:,:,r-1)=default_d02(:,:,r-1)+dim_sum_n_Wrap(rain_exp,0)+dim_sum_n_Wrap(rain_con,0)
    notopo_d02(:,:,r-1)=notopo_d02(:,:,r-1)+dim_sum_n_Wrap(rain_exp2,0)+dim_sum_n_Wrap(rain_con2,0)
  end if

  delete([/fname,f1,f2,rain_exp,rain_exp2,rain_con,rain_con2/])
 
n=n+1
month=month+1
end do
year=year+1
end do
r=r+1
end do

diff1=(notopo_d01-default_d01)/2
diff1@description = "Average Precipitation Difference in 2007-08"
diff1@units = "mm"
diff1@lat2d=lat1
diff1@lon2d=lon1

diff1a=100*(notopo_d01-default_d01)/where(default_d01.gt.0,default_d01,default_d01@_FillValue)
diff1a@description= "Average Precipitation Difference in 2007-08"
diff1a@units = "%"
diff1a@lat2d=lat1
diff1a@lon2d=lon1

diff2=(notopo_d02-default_d02)/2
diff2@description = "Average Precipitation Difference in 2007-08"
diff2@units = "mm"
diff2@lat2d=lat2
diff2@lon2d=lon2

diff2a=100*(notopo_d02-default_d02)/where(default_d02.gt.0,default_d02,default_d02@_FillValue)
diff2a@description= "Average Precipitation Difference in 2007-08"
diff2a@units = "%"
diff2a@lat2d=lat2
diff2a@lon2d=lon2

outfile1=OUTDir+"D01_prlr_noeac_Rall_annanom_mean"
outfile2=OUTDir+"D02_prlr_noeac_Rall_annanom_mean"

  wks = gsn_open_wks("pdf", outfile1)  ; Open graphics file
      gsn_define_colormap(wks,"precip_diff_12lev")      

  map = gsn_csm_contour_map(wks, dim_avg_n_Wrap(diff1,2), res)
  draw(map)
  frame(wks)
  delete([/map,wks/])

  wks = gsn_open_wks("pdf", outfile2)  ; Open graphics file
      gsn_define_colormap(wks,"precip_diff_12lev")                ; choose colormap

  map = gsn_csm_contour_map(wks, dim_avg_n_Wrap(diff2,2), res)
  draw(map)
  frame(wks)
  delete([/map,wks,outfile1,outfile2/])

  outfile1=OUTDir+"D01_prlr_noeac_Rall_annanom_mean_PCchange"
  outfile2=OUTDir+"D02_prlr_noeac_Rall_annanom_mean_PCchange"
  res@cnLevelSelectionMode = "ExplicitLevels"

  delete(res@cnLevels)
  res@cnLevels             = (/ -50,-20,-10,-5,5,10,20,50/)
;  res@cnFillColors         = (/13,12,11,10,8,6,5,4,3/)
res@cnFillColors         = (/3,4,5,6,8,10,11,12,13/)

  wks = gsn_open_wks("pdf", outfile1)  ; Open graphics file
      gsn_define_colormap(wks,"precip_diff_12lev")      

  map = gsn_csm_contour_map(wks, dim_avg_n_Wrap(diff1a,2), res)
  draw(map)
  frame(wks)
  delete([/map,wks/])

  wks = gsn_open_wks("pdf", outfile2)  ; Open graphics file
      gsn_define_colormap(wks,"precip_diff_12lev")                ; choose colormap

  map = gsn_csm_contour_map(wks, dim_avg_n_Wrap(diff2a,2), res)
  draw(map)
  frame(wks)
  delete([/map,wks,outfile1,outfile2/])


r=1
do while(r.le.3)
  outfile1=OUTDir+"D01_prlr_noeac_R"+r+"_annanom_mean"
  outfile2=OUTDir+"D02_prlr_noeac_R"+r+"_annanom_mean"
  delete([/res@cnLevels,res@cnFillColors/])
  res@cnLevels             = (/-300., -200.,-100., -50., -25., -10., 10., 25., 50.,100.,200.,300./)
   
  wks = gsn_open_wks("pdf", outfile1)  ; Open graphics file
      gsn_define_colormap(wks,"precip_diff_12lev")      

  map = gsn_csm_contour_map(wks, diff1(:,:,r-1), res)
  draw(map)
  frame(wks)
  delete([/map,wks/])

  wks = gsn_open_wks("pdf", outfile2)  ; Open graphics file
      gsn_define_colormap(wks,"precip_diff_12lev")                ; choose colormap

  map = gsn_csm_contour_map(wks, diff2(:,:,r-1), res)
  draw(map)
  frame(wks)
  delete([/map,wks,outfile1,outfile2/])

  outfile1=OUTDir+"D01_prlr_noeac_R"+r+"_annanom_mean_PCchange"
  outfile2=OUTDir+"D02_prlr_noeac_R"+r+"_annanom_mean_PCchange"
  delete(res@cnLevels)
  res@cnLevels             = (/ -50,-20,-10,-5,5,10,20,50/)
  res@cnFillColors         = (/3,4,5,6,8,10,11,12,13/)

  wks = gsn_open_wks("pdf", outfile1)  ; Open graphics file
      gsn_define_colormap(wks,"precip_diff_12lev")      

  map = gsn_csm_contour_map(wks, diff1a(:,:,r-1), res)
  draw(map)
  frame(wks)
  delete([/map,wks/])

  wks = gsn_open_wks("pdf", outfile2)  ; Open graphics file
      gsn_define_colormap(wks,"precip_diff_12lev")                ; choose colormap

  map = gsn_csm_contour_map(wks, diff2a(:,:,r-1), res)
  draw(map)
  frame(wks)
  delete([/map,wks,outfile1,outfile2/])
  r=r+1
end do

end


