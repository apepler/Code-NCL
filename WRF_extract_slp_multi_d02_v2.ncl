; Next complicated thing - WRF - NCEP?

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"


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


;INDIRS=(/"/srv/ccrc/data36/z3478332/WRF/output/ERAI_R2_ensemble/out/","/srv/ccrc/data36/z3478332/WRF/output/ERAI_R2_ensemble_notopo/out/","/srv/ccrc/data36/z3478332/WRF/output/ERAI_R3_ensemble/out/","/srv/ccrc/data36/z3478332/WRF/output/ERAI_R3_ensemble_notopo/out/","/srv/ccrc/data36/z3478332/WRF/output/ERAI_R1_ensemble/out/","/srv/ccrc/data36/z3478332/WRF/output/ERAI_R1_ensemble_notopo/out/"/)
INDIRS=(/"/srv/ccrc/data37/z3478332/WRF/output/ERAI_R1_ensemble_BRAN/out/","/srv/ccrc/data37/z3478332/WRF/output/ERAI_R2_ensemble_BRAN/out/","/srv/ccrc/data37/z3478332/WRF/output/ERAI_R3_ensemble_BRAN/out/","/srv/ccrc/data37/z3478332/WRF/output/ERAI_R1_ensemble_BRAN_noeac/out/","/srv/ccrc/data37/z3478332/WRF/output/ERAI_R2_ensemble_BRAN_noeac/out/","/srv/ccrc/data37/z3478332/WRF/output/ERAI_R3_ensemble_BRAN_noeac/out/","/srv/ccrc/data37/z3478332/WRF/output/ERAI_R1_ensemble_BRAN_2eac/out/","/srv/ccrc/data37/z3478332/WRF/output/ERAI_R2_ensemble_BRAN_2eac/out/","/srv/ccrc/data37/z3478332/WRF/output/ERAI_R3_ensemble_BRAN_2eac/out/"/)

hour=(/"00","06","12","18"/)
n=0
do while(n.lt.dimsizes(INDIRS))
day=27
do while(day.le.31)
h=0
;do while(h.lt.4)
INDIR = INDIRS(n)+"200705"+day+hour(h)+"/"
OUTDIR=INDIR

  print("200705"+day+hour(h))

  FILES1 = systemfunc (" ls -1 " + INDIR + "wrfout_d01_????-??-??_??:00:00")
  f3 = addfiles(FILES1+".nc","r")
  times = wrf_user_getvar(f3,"times",-1)
  yy = stringtointeger(str_get_cols(times, 0, 3))
  mm = stringtointeger(str_get_cols(times, 5, 6))
  dd = stringtointeger(str_get_cols(times, 8, 9))
  hh = stringtointeger(str_get_cols(times, 11, 12))
  times2=yy*1000000+mm*10000+dd*100+hh
  times2!0 = "time"

  slp1 = wrf_user_getvar(f3,"slp",-1)    ; slp
  dim=dimsizes(slp1)
  l=dim(0)-1
  slp1a=slp1(0:l:2,:,:)
  times3=times2(0:l:2)
  slp1a@lat2d=lat1
  slp1a@lon2d=lon1
  wrf_smooth_2d( slp1a, 3 )            ; smooth slp
  slp1c = ESMF_regrid(slp1a,Opt3)   ; Do the regridding - 0.5 degrees
  slp1c!0   ="time"
  slp1c!1   ="lat0"
  slp1c!2   ="lon0"
  slp1c&lat0 = lat0
  slp1c&lon0 = lon0
  slp1c@description = "NCEP-driven WRF slp regridded to 0.5x0.5 regular grid"

  FILES1 = systemfunc (" ls -1 " + INDIR + "wrfout_d02_????-??-??_??:00:00")
  f4 = addfiles(FILES1+".nc","r")
  slp2 = wrf_user_getvar(f4,"slp",-1)    ; slp
  slp2a=slp2(0:l:2,:,:)
  slp2a@lat2d=lat2
  slp2a@lon2d=lon2
  wrf_smooth_2d( slp2a, 3 )            ; smooth slp
  slp2c = ESMF_regrid(slp2a,Opt3)   ; Do the regridding - 0.5 degrees
  copy_VarMeta(slp1c,slp2c)

  slp3 = where(ismissing(slp2c),slp1c,slp2c)
  copy_VarMeta(slp1c,slp3)

   system("/bin/rm -f "+OUTDIR+"WRF_d02_slp_regrid.nc")
   out = addfile(OUTDIR+"WRF_d02_slp_regrid.nc","c") ; smoothed
   out->slp0 = slp3
   out->Times = times3
   delete(out)
 
   delete([/INDIR,OUTDIR,times,times2,times3,yy,mm,dd,hh,FILES1,f3/])
   delete([/slp1,slp1a,slp1c/])
   delete([/slp2,slp2a,slp2c,slp3,f4/])

;h=h+1
;end do
day=day+1
end do
n=n+1
end do

