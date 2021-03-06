load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
;load "./WRFUserARW.ncl"

begin

  OUTDir = "/srv/ccrc/data45/z3478332/WRF/output/"  
  type=(/"_BRAN","_BRAN_noeac","_BRAN_2eac","","_notopo"/)
  type2=(/"BRAN","BRAN_noeac","BRAN_2eac","control","notopo"/)
  dirlist=(/37,37,36,36,36/)

  fin=addfile("/srv/ccrc/data13/z3393020/Analyses/share/geo_em_files/geo_em.d01.narclim.nc","r")
  lat1=wrf_user_getvar(fin,"XLAT_M",-1)
  lon1=wrf_user_getvar(fin,"XLONG_M",-1)
  delete(fin)

t=1
do while(t.le.dimsizes(type))
  a=dimsizes(lat1)
  U_d01 = new((/a(1),a(2),24,3/),"float")
  U_d01!0 = lat1!1
  U_d01!1 = lat1!2
  U_d01!2 = "Time"
  U_d01!3 = "WRF version"
  delete(a)

  U_d01@description="Average 850 hPa U-wind"
  U_d01@units = "m s-1"

  V_d01=U_d01
  V_d01@description="Average 850 hPa V-wind"

  SLP_d01=U_d01
  SLP_d01@description="Average mean sea level pressure"
  SLP_d01@units = "hPa"

r=1
do while(r.le.3)

  DATADir = "/srv/ccrc/data"+dirlist(t)+"/z3478332/WRF/output/ERAI_R"+r+"_nudging_default_2007"+type(t)+"/out/"
  print(DATADir)
n=0
year=2007
year2=2008
do while(year.le.year2)
m=1
do while(m.le.12)
  FILES1 = systemfunc (" ls -1 " + DATADir + "wrfout_d01_"+year+"-"+sprinti("%0.2i",m)+"-??_??:00:00")
  f1 = addfiles(FILES1+".nc","r")
  SLP_d01(:,:,n,r-1) = dim_avg_n_Wrap(wrf_user_getvar(f1,"slp",-1),0)    ; slp

  uv = wrf_user_getvar(f1,"uvmet",-1)
  p = wrf_user_getvar(f1,"pressure",-1)
  u2 = wrf_user_intrp3d(uv(0,:,:,:,:),p,"h",850.0,0.,False)
  v2 = wrf_user_intrp3d(uv(1,:,:,:,:),p,"h",850.0,0.,False)

  U_d01(:,:,n,r-1) = dim_avg_n_Wrap(u2,0)    ; slp
  V_d01(:,:,n,r-1) = dim_avg_n_Wrap(v2,0)    ; slp

  delete([/f1,FILES1,uv,p,u2,v2/])

n=n+1
m=m+1
end do
year=year+1
end do
r=r+1
end do
  
  outfile=OUTDir+"WRF_d01_UV_slp_"+type2(t)
  system("/bin/rm -f "+outfile+".nc")
  out = addfile(outfile+".nc","c")
  out->U_d01=U_d01
  out->V_d01=V_d01
  out->SLP_d01=SLP_d01
;  out->lat=lat1
;  out->lon=lon1

  delete([/U_d01,V_d01,SLP_d01,DATADir,outfile/])

t=t+1
end do

end