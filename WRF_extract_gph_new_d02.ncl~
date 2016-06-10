; Next complicated thing - WRF - NCEP?

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

;INDIRS=(/"/srv/ccrc/data36/z3478332/WRF/output/ERAI_R1_nudging_default_2007/out/","/srv/ccrc/data36/z3478332/WRF/output/ERAI_R2_nudging_default_2007/out/","/srv/ccrc/data36/z3478332/WRF/output/ERAI_R3_nudging_default_2007/out/","/srv/ccrc/data36/z3478332/WRF/output/ERAI_R1_nudging_default_2007_notopo/out/","/srv/ccrc/data36/z3478332/WRF/output/ERAI_R2_nudging_default_2007_notopo/out/","/srv/ccrc/data36/z3478332/WRF/output/ERAI_R3_nudging_default_2007_notopo/out/","/srv/ccrc/data37/z3478332/WRF/output/ERAI_R1_nudging_default_2007_BRAN/out/","/srv/ccrc/data37/z3478332/WRF/output/ERAI_R2_nudging_default_2007_BRAN/out/","/srv/ccrc/data37/z3478332/WRF/output/ERAI_R3_nudging_default_2007_BRAN/out/","/srv/ccrc/data37/z3478332/WRF/output/ERAI_R1_nudging_default_2007_BRAN_noeac/out/","/srv/ccrc/data37/z3478332/WRF/output/ERAI_R2_nudging_default_2007_BRAN_noeac/out/","/srv/ccrc/data37/z3478332/WRF/output/ERAI_R3_nudging_default_2007_BRAN_noeac/out/"/)

INDIRS=(/"/srv/ccrc/data45/z3478332/WRF/output/ERAI_R1_nudging_default_2007_BRAN_2eac/out/","/srv/ccrc/data36/z3478332/WRF/output/ERAI_R2_nudging_default_2007_BRAN_2eac/out/","/srv/ccrc/data45/z3478332/WRF/output/ERAI_R3_nudging_default_2007_BRAN_2eac/out/"/)
OUTDIRS=(/"/srv/ccrc/data45/z3478332/WRF/output/ERAI_R1_nudging_default_2007_BRAN_2eac/out/","/srv/ccrc/data45/z3478332/WRF/output/ERAI_R2_nudging_default_2007_BRAN_2eac/out/","/srv/ccrc/data45/z3478332/WRF/output/ERAI_R3_nudging_default_2007_BRAN_2eac/out/"/)

  f1=addfile("/srv/ccrc/data30/z3393020/NARCliM/postprocess/1990-2009/ECHAM5/R2/d01/CCRC_NARCliM_MON_2000-2009_tasmax.nc","r")
  lat1=f1->lat
  lon1=f1->lon

  f2=addfile("/srv/ccrc/data30/z3393020/NARCliM/postprocess/1990-2009/ECHAM5/R2/d02/CCRC_NARCliM_MON_2000-2009_tasmax.nc","r")
  lat2=f2->lat
  lon2=f2->lon

  levlist=fspan(300.,900.,13)
  lon0=fspan(105,180,151)
  lat0=fspan(-50,0,101)

  delete(f1)
  delete(f2)

  Opt3                = True
  Opt3@SrcRegional    = True             ; These are necessary
  Opt3@DstRegional    = True
  Opt3@DstGridLat = lat0
  Opt3@DstGridLon = lon0
  Opt3@ForceOverwrite = True

n=0
do while(n.lt.dimsizes(INDIRS))
;do while(n.lt.1)
  INDIR=INDIRS(n)
  OUTDIR=OUTDIRS(n)+"slp/"
  print(INDIR)

  year=2007
  year2=2008
  month1=1
  month2=12

do while(year.le.year2)
  i=month1
  do while(i.le.month2)
    print(year+sprinti("%0.2i",i))
    FILES1 = systemfunc (" ls -1 " + INDIR + "wrfout_d01_"+year+"-"+sprinti("%0.2i",i)+"-??_??:00:00")
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

  zNew@lat2d=lat1
  zNew@lon2d=lon1
  zNew2 = ESMF_regrid(zNew,Opt3)   ; Do the regridding - 0.5 degrees

;  wrf_smooth_2d( zNew, 3 )            ; smooth slp
 
  levlist!0 = "level"
  zNew2!0 = "time"
  zNew2!1 = "level"
  zNew2!2 = "lat0"
  zNew2!3 = "lon0"
  zNew2&lat0 = lat0
  zNew2&lon0 = lon0
  zNew2@description = "NCEP-driven WRF d02 geopotential height regridded to 0.5x0.5 regular grid"

delete([/FILES1,f1,p,z,dim,l/])

  ;print(year+sprinti("%0.2i",i))
  FILES1 = systemfunc (" ls -1 " + INDIR + "wrfout_d02_"+year+"-"+sprinti("%0.2i",i)+"-??_??:00:00")
  f1 = addfiles(FILES1+".nc","r")
  z = wrf_user_getvar(f1,"z",-1)
  p = wrf_user_getvar(f1,"pressure",-1)
  dim=dimsizes(p)
  l=dim(0)-1

  zNew3 = new((/dim(0)/2,dimsizes(levlist),dim(2),dim(3)/),"float")

  tt=0
  do while(tt.lt.dimsizes(levlist))
    zNew3(:,tt,:,:) = wrf_user_intrp3d(z(0:l:2,:,:,:),p(0:l:2,:,:,:),"h",levlist(tt),0.,False)
    tt=tt+1
  end do
  wrf_smooth_2d( zNew3, 3 )            ; smooth slp

  zNew3@lat2d=lat2
  zNew3@lon2d=lon2
  zNew4 = ESMF_regrid(zNew,Opt3)   ; Do the regridding - 0.5 degrees

  zComb = where(ismissing(zNew4),zNew2,zNew4)
  copy_VarMeta(zNew2,zComb)


  outfile=OUTDIR+"WRF_d02_gph_"+year+sprinti("%0.2i",i)
  system("/bin/rm -f "+outfile+"_regrid.nc")
  out = addfile(outfile+"_regrid.nc","c")
  out->Z=zComb
  out->Times=times3
  out->lev=levlist

   i=i+1
   delete([/FILES1,f1,times,z,p,times2,yy,mm,dd,hh,times3/])
   delete([/out,outfile,zNew,dim,l,tt,zNew2,zNew3,zNew4,zComb/])
end do
year=year+1
end do
n=n+1
end do

