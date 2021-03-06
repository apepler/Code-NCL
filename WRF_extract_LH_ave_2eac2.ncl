load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
;load "./WRFUserARW.ncl"

begin

  OUTDir = "/srv/ccrc/data36/z3478332/WRF/output/"  
  type=(/"BRAN","BRAN_noeac","BRAN_2eac"/)

  fin=addfile("/srv/ccrc/data13/z3393020/Analyses/share/geo_em_files/geo_em.d01.narclim.nc","r")
  lat1=wrf_user_getvar(fin,"XLAT_M",-1)
  lon1=wrf_user_getvar(fin,"XLONG_M",-1)
  delete(fin)
  fin=addfile("/srv/ccrc/data13/z3393020/Analyses/share/geo_em_files/geo_em.d02.narclim.nc","r")
  lat2=wrf_user_getvar(fin,"XLAT_M",-1)
  lon2=wrf_user_getvar(fin,"XLONG_M",-1)
  delete(fin)

t=2
do while(t.le.2)
  a=dimsizes(lat1)
  LH_d01 = new((/a(1),a(2),3/),"float")
  LH_d01@lat2d = rm_single_dims(lat1)
  LH_d01@lon2d = rm_single_dims(lon1)
  LH_d01!0 = lat1!1
  LH_d01!1 = lat1!2
  LH_d01!2 = "WRF version"
  PRCP_d01 = LH_d01
  delete(a)

  LH_d01@description="Average surface latent heat flux"
  LH_d01@units = "W m-2"
  PRCP_d01@description="Total precipitation"
  PRCP_d01@units = "mm"

  a=dimsizes(lat2)
  LH_d02 = new((/a(1),a(2),3/),"float")
  LH_d02@lat2d = rm_single_dims(lat2)
  LH_d02@lon2d = rm_single_dims(lon2)
  LH_d02!0 = lat2!1
  LH_d02!1 = lat2!2
  LH_d02!2 = "WRF version"
  PRCP_d02 = LH_d02
  delete(a)

  LH_d02@description="Average surface latent heat flux"
  LH_d02@units = "W m-2"
  PRCP_d02@description="Total precipitation"
  PRCP_d02@units = "mm"

dirs=(/45,36,45/)
r=1
do while(r.le.3)

  DATADir = "/srv/ccrc/data"+dirs(r-1)+"/z3478332/WRF/output/ERAI_R"+r+"_nudging_default_2007_"+type(t)+"/out/"

  FILES1 = systemfunc (" ls -1 " + DATADir + "wrfhrly_d01_200?-??-??_00:00:00")
  f1 = addfiles(FILES1+".nc","r")
  LH_d01(:,:,r-1)=dim_avg_n_Wrap(wrf_user_getvar(f1,"LH",-1),0)
  PRCP_d01(:,:,r-1)=dim_sum_n_Wrap(wrf_user_getvar(f1,"PREC_ACC_NC",-1),0)+dim_sum_n_Wrap(wrf_user_getvar(f1,"PREC_ACC_C",-1),0)

  FILES1a = systemfunc (" ls -1 " + DATADir + "wrfhrly_d02_200?-??-??_00:00:00")
  f1a = addfiles(FILES1a+".nc","r")
  LH_d02(:,:,r-1)=dim_avg_n_Wrap(wrf_user_getvar(f1a,"LH",-1),0)
  PRCP_d02(:,:,r-1)=dim_sum_n_Wrap(wrf_user_getvar(f1a,"PREC_ACC_NC",-1),0)+dim_sum_n_Wrap(wrf_user_getvar(f1a,"PREC_ACC_C",-1),0)
  
  delete([/f1,FILES1,f1a,FILES1a/])


r=r+1
end do
  
  outfile=OUTDir+"WRF_d01_LH_PRCP_"+type(t)+"_v2"
  system("/bin/rm -f "+outfile+".nc")
  out = addfile(outfile+".nc","c")
  out->LH_d01=LH_d01
  out->PRCP_d01=PRCP_d01
  out->lat=lat1
  out->lon=lon1
  delete(outfile)

  outfile=OUTDir+"WRF_d02_LH_PRCP_"+type(t)+"_v2"
  system("/bin/rm -f "+outfile+".nc")
  out = addfile(outfile+".nc","c")
  out->LH_d02=LH_d02
  out->PRCP_d02=PRCP_d02
  out->lat=lat2
  out->lon=lon2

  delete([/LH_d01,LH_d02,PRCP_d01,PRCP_d02,DATADir,outfile/])

t=t+1
end do

end