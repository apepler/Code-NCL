; Next complicated thing - WRF - NCEP?

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

; Regrid the WRF data to the same grid as NCEP

  f1=addfile("/srv/ccrc/data30/z3393020/NARCliM/postprocess/1990-2009/ECHAM5/R2/d01/CCRC_NARCliM_MON_2000-2009_tasmax.nc","r")
  lat1=f1->lat
  lon1=f1->lon

  f2=addfile("/srv/ccrc/data30/z3393020/NARCliM/postprocess/1990-2009/ECHAM5/R2/d02/CCRC_NARCliM_MON_2000-2009_tasmax.nc","r")
  lat2=f2->lat
  lon2=f2->lon
;  lon0=fspan(140,170,301)
;  lat0=fspan(-50,-15,351)
  lon0=fspan(105,180,151)
  lat0=fspan(-50,0,101)

   Opt3                = True
   Opt3@SrcRegional    = True             ; These are necessary
   Opt3@DstRegional    = True
   Opt3@DstGridLat = lat0
   Opt3@DstGridLon = lon0
   Opt3@ForceOverwrite = True

dirs=(/"/srv/ccrc/data31/z3393020/NARCliM/reanalysis/R1/out/","/srv/ccrc/data29/z3236814/NARCliM/reanalysis/R3/out/","/srv/ccrc/data27/z3393020/WRF_NNRP/R2/1950-2010/out/"/)
type=(/"R1","R3","R2"/)

n=1
do while(n.lt.dimsizes(dirs))
year=1990
year2=2009
do while(year.le.year2)
m=1
do while(m.le.12)
   fout="/srv/ccrc/data45/z3478332/WRF/NARCliM_regrid/NCEP-" + type(n) + "/WRF_d02_slp_" + type(n) + "_" + year + sprinti("%0.2i",m) + "_regrid.nc"
   print(fout)
   FILES1 = systemfunc (" ls -1 " + dirs(n) + "wrfout_d01_" + year + "-" + sprinti("%0.2i",m) +"-??_??:00:00")
   f3 = addfiles(FILES1+".nc","r")
  slp1 = wrf_user_getvar(f3,"slp",-1)    ; slp
  dim=dimsizes(slp1)
  l=dim(0)-1
  slp1a=slp1(0:l:2,:,:)
  slp1a@lat2d=lat1
  slp1a@lon2d=lon1
  slp1c = ESMF_regrid(slp1a,Opt3)   ; Do the regridding - 0.5 degrees
  slp1c!0   ="time"
  slp1c!1   ="lat0"
  slp1c!2   ="lon0"
  slp1c&lat0 = lat0
  slp1c&lon0 = lon0
  slp1c@description = "NCEP-driven WRF slp regridded to 0.5x0.5 regular grid"

  FILES2 = systemfunc (" ls -1 " + dirs(n) + "wrfout_d02_" + year + "-" + sprinti("%0.2i",m) + "-??_??:00:00")
  f4 = addfiles(FILES2+".nc","r")
  slp2 = wrf_user_getvar(f4,"slp",-1)    ; slp
  slp2a=slp2(0:l:2,:,:)
  wrf_smooth_2d( slp2a, 3 )            ; smooth slp
  slp2a@lat2d=lat2
  slp2a@lon2d=lon2
  slp2c = ESMF_regrid(slp2a,Opt3)   ; Do the regridding - 0.5 degrees
  copy_VarMeta(slp1c,slp2c)

  slp3 = where(ismissing(slp2c),slp1c,slp2c)
  copy_VarMeta(slp1c,slp3)

   system("/bin/rm -f "+fout)
   out = addfile(fout,"c")
   out->slp0 = slp3

   m=m+1
   delete([/dim,l,FILES1,FILES2,f3,f4,fout/])
   delete([/slp1,slp1a,slp1c,slp2,slp2a,slp2c,slp3/])
end do
year=year+1
end do
n=n+1
end do
