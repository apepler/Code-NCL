load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

INDIRS=(/"/srv/ccrc/data45/z3478332/WRF/output/ERAI_R2_nonudging_notopo/out/","/srv/ccrc/data33/z3481416/CCRC-WRF3.6.0.5-SEB/ERA-Interim/R2_nudging/out/","/srv/ccrc/data34/z3478332/WRF/output/ERAI_R2_nudging_notopo_19902009/out/"/)
OUTDIRS=(/"/srv/ccrc/data45/z3478332/WRF/output/ERAI_R2_nonudging_notopo/out/impact/","/srv/ccrc/data34/z3478332/WRF/ERA-nudge/","/srv/ccrc/data34/z3478332/WRF/output/ERAI_R2_nudging_notopo_19902009/out/impact/"/)


fin=addfile("/srv/ccrc/data13/z3393020/Analyses/share/geo_em_files/geo_em.d01.narclim.nc","r")
lat1 = rm_single_dims(wrf_user_getvar(fin,"XLAT_M",-1))
lon1 = rm_single_dims(wrf_user_getvar(fin,"XLONG_M",-1))

year1=1990
year2=2009

n=2
do while(n.lt.dimsizes(INDIRS))
  INDIR=INDIRS(n)
  print(INDIR)

year=year1
do while(year.le.year2)
  print(year)
; Get the 6-hourly winds (instantaneous)

  FILES1 = systemfunc (" ls -1 " + INDIR + "wrfhrly_d01_" + year + "-??-??_00:00:00")
; Since it's centred, 01-01-0000Z needs previous three hours. Except for year 1 
  f1 = addfiles(FILES1+".nc","r")
  times=wrf_user_getvar(f1,"times",-1)
  numDAYS = dimsizes(times)/6
  a=ispan(0,dimsizes(times)-1,6) 

  u10 = wrf_user_getvar(f1,"U10",a)    ; uv
  v10 = wrf_user_getvar(f1,"V10",a)

fout=OUTDIRS(n)+"uv_"+year+"_d01_6hr.nc"

u10!0="Time"
u10!1="south_north"
u10!2="east_west"
u10@description="6-hour instantaneous 10m zonal wind"

v10!0="Time"
v10!1="south_north"
v10!2="east_west"
v10@description="6-hour instantaneous 10m meridional wind within 500km radius of low centre"

system("/bin/rm -f "+fout)
out = addfile(fout,"c")
out->u10=u10
out->v10=v10

delete([/u10,v10,out,fout,FILES1,f1,numDAYS,times,a/])
year=year+1
end do
n=n+1
end do
