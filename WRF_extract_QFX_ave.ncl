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
  QFX_d01 = new((/a(1),a(2),3/),"float")
  QFX_d01@lat2d = rm_single_dims(lat1)
  QFX_d01@lon2d = rm_single_dims(lon1)
  QFX_d01!0 = lat1!1
  QFX_d01!1 = lat1!2
  QFX_d01!2 = "WRF version"
  delete(a)

  QFX_d01@description="Average surface moisture flux"
  QFX_d01@units = "Kg m-2 s-1"

  a=dimsizes(lat2)
  QFX_d02 = new((/a(1),a(2),3/),"float")
  QFX_d02@lat2d = rm_single_dims(lat2)
  QFX_d02@lon2d = rm_single_dims(lon2)
  QFX_d02!0 = lat2!1
  QFX_d02!1 = lat2!2
  QFX_d02!2 = "WRF version"
  delete(a)

  QFX_d02@description="Average surface moisture flux"
  QFX_d02@units = "Kg m-2 s-1"

r=1
do while(r.le.3)

  DATADir = "/srv/ccrc/data36/z3478332/WRF/output/ERAI_R"+r+"_nudging_default_2007_"+type(t)+"/out/"

  FILES1 = systemfunc (" ls -1 " + DATADir + "wrfout_d01_200?-??-??_00:00:00")
  f1 = addfiles(FILES1+".nc","r")
  QFX_d01(:,:,r-1)=dim_sum_n_Wrap(wrf_user_getvar(f1,"QFX",-1)*3*60*60,0)

;  FILES1a = systemfunc (" ls -1 " + DATADir + "wrfout_d02_200?-??-??_00:00:00")
;  f1a = addfiles(FILES1a+".nc","r")
;  QFX_d02(:,:,r-1)=dim_sum_n_Wrap(wrf_user_getvar(f1a,"QFX",-1)*3*60*60,0)
  
  delete([/f1,FILES1/])


r=r+1
end do
  
  outfile=OUTDir+"WRF_d01_QFX_"+type(t)
  system("/bin/rm -f "+outfile+".nc")
  out = addfile(outfile+".nc","c")
  out->QFX_d01=QFX_d01
  out->lat=lat1
  out->lon=lon1
  delete(outfile)

;  outfile=OUTDir+"WRF_d02_QFX_"+type(t)
;  system("/bin/rm -f "+outfile+".nc")
;  out = addfile(outfile+".nc","c")
;  out->QFX_d02=QFX_d02
;  out->lat=lat2
;  out->lon=lon2

  delete([/QFX_d01,QFX_d02,DATADir,outfile/])

t=t+1
end do

end