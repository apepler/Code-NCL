load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
;load "./WRFUserARW.ncl"

DATADIRS=(/"/srv/ccrc/data33/z3481416/CCRC-WRF3.6.0.5-SEB/ERA-Interim/R2_nudging/out/","/srv/ccrc/data45/z3478332/WRF/output/ERAI_R2_nonudging_notopo/out/","/srv/ccrc/data34/z3478332/WRF/output/ERAI_R2_nudging_notopo_19902009/out/"/)
OUTDIRS=(/"/srv/ccrc/data34/z3478332/WRF/ERA-nudge/","/srv/ccrc/data45/z3478332/WRF/output/ERAI_R2_nonudging_notopo/out/impact/","/srv/ccrc/data34/z3478332/WRF/output/ERAI_R2_nudging_notopo_19902009/out/impact/"/)

  fin=addfile("/srv/ccrc/data13/z3393020/Analyses/share/geo_em_files/geo_em.d01.narclim.nc","r")
  lat1=wrf_user_getvar(fin,"XLAT_M",-1)
  lon1=wrf_user_getvar(fin,"XLONG_M",-1)

  MSFU=rm_single_dims(fin->MAPFAC_U)
  MSFV=rm_single_dims(fin->MAPFAC_V)
  MSFM=rm_single_dims(fin->MAPFAC_M)
  COR=rm_single_dims(fin->F)
  DX=fin@DX
  DY=fin@DY
  levs=(/850.,500.,200./)

  delete(fin)
  print("Beginning")

dd=0
do while (dd.lt.dimsizes(DATADIRS))

DATADir=DATADIRS(dd)
OUTDir=OUTDIRS(dd)
print(DATADir)

  a=dimsizes(lat1)
  Z_d01 = new((/a(1),a(2),3,240/),"float")
  Z_d01!0 = lat1!1
  Z_d01!1 = lat1!2
  Z_d01!2 = "Level"
  Z_d01@Level = levs
  Z_d01!3 = "Month"

  U_d01=Z_d01
  U_d01@units="m/s"
  V_d01=U_d01
  U_d01@description="Zonal wind" 
  V_d01@description="Meridional wind"
  Z_d01@description="Geopotential height"
  Z_d01@units="m"

n=0
year=1990
year2=2009
do while(year.le.year2)
  print(year)
m=1
do while(m.le.12)
  FILES1 = systemfunc (" ls -1 " + DATADir + "wrfout_d01_"+year+"-"+sprinti("%0.2i",m)+"-??_00:00:00")

  f1 = addfiles(FILES1+".nc","r")
  p = wrf_user_getvar(f1,"pressure",-1)
  uv=wrf_user_getvar(f1,"uvmet",-1)
  z=wrf_user_getvar(f1,"z",-1)

l=0
do while(l.lt.dimsizes(levs))
  Z_d01(:,:,l,n)=(/dim_avg_n_Wrap(wrf_user_intrp3d(z,p,"h",levs(l),0.,False),0)/)
  U_d01(:,:,l,n)=(/dim_avg_n_Wrap(wrf_user_intrp3d(uv(0,:,:,:,:),p,"h",levs(l),0.,False),0)/)
  V_d01(:,:,l,n)=(/dim_avg_n_Wrap(wrf_user_intrp3d(uv(1,:,:,:,:),p,"h",levs(l),0.,False),0)/)
  l=l+1
end do
delete([/FILES1,f1,uv,p,z,l/])

n=n+1
m=m+1
end do
year=year+1
end do
 
  outfile=OUTDir+"WRF_d01_monthly_uppers"
  system("/bin/rm -f "+outfile+".nc")
  out = addfile(outfile+".nc","c")
  out->Z_d01=Z_d01
  out->U_d01=U_d01  
  out->V_d01=V_d01

delete([/out,outfile,DATADir,OUTDir/])
delete([/U_d01,V_d01,Z_d01/])
dd=dd+1
end do

