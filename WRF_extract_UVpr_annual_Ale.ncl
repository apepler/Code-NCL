load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
;load "./WRFUserARW.ncl"

begin

  DATADir="/srv/ccrc/data45/z3478332/WRF/output/ERAI_R2_nonudging_notopo/out/"
  OUTDirs = (/"/srv/ccrc/data34/z3478332/WRF/ERA-nudge/","/srv/ccrc/data34/z3478332/WRF/ERA-nonudge/"/)

  fin=addfile("/srv/ccrc/data13/z3393020/Analyses/share/geo_em_files/geo_em.d01.narclim.nc","r")
  lat1=wrf_user_getvar(fin,"XLAT_M",-1)
  lon1=wrf_user_getvar(fin,"XLONG_M",-1)
  delete(fin)
  a=dimsizes(lat1)
  U_d01 = new((/a(1),a(2),20/),"float")
  U_d01!0 = lat1!1
  U_d01!1 = lat1!2
  U_d01!2 = "Time"
  SLP_d01=U_d01
  PRCP_d01=U_d01

  U_d01@units = "m s-1"
  V_d01=U_d01
  V_d01@description="Average 850 hPa V-wind"
  U_d01@description="Average 850 hPa U-wind"

  SLP_d01@description="Average mean sea level pressure"
  SLP_d01@units = "hPa"
  PRCP_d01@description="Total precipitation"
  PRCP_d01@units = "mm"


n=0
year=1990
year2=2009
do while(year.le.year2)
  print(year)
  FILES1 = systemfunc (" ls -1 " + DATADir + "wrfout_d01_"+year+"-??-??_??:00:00")
  f1 = addfiles(FILES1+".nc","r")
  SLP_d01(:,:,n) = dim_avg_n_Wrap(wrf_user_getvar(f1,"slp",-1),0)    ; slp
  uv = wrf_user_getvar(f1,"uvmet",-1)
  p = wrf_user_getvar(f1,"pressure",-1)
  u2 = wrf_user_intrp3d(uv(0,:,:,:,:),p,"h",850.0,0.,False)
  v2 = wrf_user_intrp3d(uv(1,:,:,:,:),p,"h",850.0,0.,False)

  U_d01(:,:,n) = dim_avg_n_Wrap(u2,0)    
  V_d01(:,:,n) = dim_avg_n_Wrap(v2,0)    
  delete([/f1,FILES1,uv,p,u2,v2/])

  FILES1 = systemfunc (" ls -1 " + DATADir + "wrfhrly_d01_200?-??-??_00:00:00")
  f1 = addfiles(FILES1+".nc","r")
  PRCP_d01(:,:,n)=dim_sum_n_Wrap(wrf_user_getvar(f1,"PREC_ACC_NC",-1),0)+dim_sum_n_Wrap(wrf_user_getvar(f1,"PREC_ACC_C",-1),0)
  delete([/f1,FILES1/])

n=n+1
year=year+1
end do

  
  outfile=OUTDir+"WRF_d01_annual_uvpr"
  system("/bin/rm -f "+outfile+".nc")
  out = addfile(outfile+".nc","c")
  out->U_d01=U_d01
  out->V_d01=V_d01
  out->SLP_d01=SLP_d01
  out->PRCP_d01=PRCP_d01
  out->lat=lat1
  out->lon=lon1

end