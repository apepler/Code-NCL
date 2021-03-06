; Next complicated thing - WRF - NCEP?

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

INDIRS=(/"/srv/ccrc/data36/z3478332/WRF/output/ERAI_R1_ensemble/out/","/srv/ccrc/data36/z3478332/WRF/output/ERAI_R2_ensemble/out/","/srv/ccrc/data36/z3478332/WRF/output/ERAI_R3_ensemble/out/","/srv/ccrc/data36/z3478332/WRF/output/ERAI_R1_ensemble_notopo/out/","/srv/ccrc/data36/z3478332/WRF/output/ERAI_R2_ensemble_notopo/out/","/srv/ccrc/data36/z3478332/WRF/output/ERAI_R3_ensemble_notopo/out/","/srv/ccrc/data37/z3478332/WRF/output/ERAI_R1_ensemble_BRAN/out/","/srv/ccrc/data37/z3478332/WRF/output/ERAI_R2_ensemble_BRAN/out/","/srv/ccrc/data37/z3478332/WRF/output/ERAI_R3_ensemble_BRAN/out/","/srv/ccrc/data37/z3478332/WRF/output/ERAI_R1_ensemble_BRAN_noeac/out/","/srv/ccrc/data37/z3478332/WRF/output/ERAI_R2_ensemble_BRAN_noeac/out/","/srv/ccrc/data37/z3478332/WRF/output/ERAI_R3_ensemble_BRAN_noeac/out/","/srv/ccrc/data37/z3478332/WRF/output/ERAI_R1_ensemble_BRAN_2eac/out/","/srv/ccrc/data37/z3478332/WRF/output/ERAI_R2_ensemble_BRAN_2eac/out/","/srv/ccrc/data37/z3478332/WRF/output/ERAI_R3_ensemble_BRAN_2eac/out/"/)

  f2=addfile("/srv/ccrc/data30/z3393020/NARCliM/postprocess/1990-2009/ECHAM5/R2/d01/CCRC_NARCliM_MON_2000-2009_tasmax.nc","r")
  rot=f2->Rotated_pole
  lat=f2->lat
  lon=f2->lon
  levlist=fspan(300.,900.,13)
  lon0=fspan(105,180,151)
  lat0=fspan(-50,0,101)


n=1
do while(n.lt.dimsizes(INDIRS))
;do while(n.lt.1)
day=27
if(n.lt.6) then 
  hour=(/"00","06","12","18"/)
else
  hour=(/"00"/)
end if 

do while(day.le.31)
h=0
do while(h.lt.dimsizes(hour))

INDIR = INDIRS(n)+"200705"+day+hour(h)+"/"
OUTDIR=INDIR

print(INDIR)

  FILES1 = systemfunc (" ls -1 " + INDIR + "wrfout_d01_????-??-??_??:00:00")
  f1 = addfiles(FILES1+".nc","r")
  z = wrf_user_getvar(f1,"z",-1)
  p = wrf_user_getvar(f1,"pressure",-1)
  dim=dimsizes(p)
  l=dim(0)-1

  times = wrf_user_getvar(f1,"times",-1)
  yy = stringtointeger(str_get_cols(times, 0, 3))
  mm = stringtointeger(str_get_cols(times, 5, 6))
  dd = stringtointeger(str_get_cols(times, 8, 9))
  hh = stringtointeger(str_get_cols(times, 11, 12))
  times2=yy*1000000+mm*10000+dd*100+hh
  times3=times2(0:l:2)
  times3!0 = "time"

  zNew = new((/dim(0)/2,dimsizes(levlist),dim(2),dim(3)/),"float")

  tt=0
  do while(tt.lt.dimsizes(levlist))
    zNew(:,tt,:,:) = wrf_user_intrp3d(z(0:l:2,:,:,:),p(0:l:2,:,:,:),"h",levlist(tt),0.,False)
    tt=tt+1
  end do

  zNew@lat2d=lat
  zNew@lon2d=lon

  Opt3                = True
  Opt3@SrcRegional    = True             ; These are necessary
  Opt3@DstRegional    = True
  Opt3@DstGridLat = lat0
  Opt3@DstGridLon = lon0
  Opt3@ForceOverwrite = True
  zNew2 = ESMF_regrid(zNew,Opt3)   ; Do the regridding - 0.5 degrees

;  wrf_smooth_2d( zNew, 3 )            ; smooth slp
 
  levlist!0 = "level"
  zNew2!0 = "time"
  zNew2!1 = "level"
  zNew2!2 = "lat0"
  zNew2!3 = "lon0"
  zNew2&lat0 = lat0
  zNew2&lon0 = lon0
  zNew2@description = "NCEP-driven WRF d01 geopotential height regridded to 0.5x0.5 regular grid"

  outfile=OUTDIR+"WRF_d01_gph"
  system("/bin/rm -f "+outfile+"_regrid.nc")
  out = addfile(outfile+"_regrid.nc","c")
  out->Z=zNew2
  out->Times=times3
  out->lev=levlist

   h=h+1
   delete([/FILES1,f1,times,z,p,times2,yy,mm,dd,hh,times3/])
   delete([/out,outfile,zNew,dim,l,tt,zNew2/])
end do
day=day+1
end do
delete(hour)
n=n+1
end do

