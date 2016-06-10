; Next complicated thing - WRF - NCEP?

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

  INDIR="/srv/ccrc/data36/z3478332/WRF/output/ERAI_R2_nudging_default/out/"
  OUTDIR=INDIR

  fin=addfile("/srv/ccrc/data13/z3393020/Analyses/share/geo_em_files/geo_em.d02.narclim.nc","r")
  lat = wrf_user_getvar(fin,"XLAT_M",0)
  lon = wrf_user_getvar(fin,"XLONG_M",0)

  FILES1 = systemfunc (" ls -1 " + INDIR + "wrfout_d02_????-??-??_??:00:00")
  f1 = addfiles(FILES1+".nc","r")
  times = wrf_user_getvar(f1,"times",-1)
  yy = stringtointeger(str_get_cols(times, 0, 3))
  mm = stringtointeger(str_get_cols(times, 5, 6))
  dd = stringtointeger(str_get_cols(times, 8, 9))
  hh = stringtointeger(str_get_cols(times, 11, 12))
  times2=yy*1000000+mm*10000+dd*100+hh

  uv = wrf_user_getvar(f1,"uvmet",-1)    ; slp
  p = wrf_user_getvar(f1,"pressure",-1)
  u = wrf_user_intrp3d(uv(0,56:71:2,:,:,:),p(56:71:2,:,:,:),"h",500.0,0.,False)
  v = wrf_user_intrp3d(uv(1,56:71:2,:,:,:),p(56:71:2,:,:,:),"h",500.0,0.,False)


  times3=times2(56:71:2)

  lon0=fspan(145,165,201)
  lat0=fspan(-45,-20,251)
  u@lat2d=lat
  u@lon2d=lon
  v@lat2d=lat
  v@lon2d=lon

   Opt3                = True
   Opt3@SrcRegional    = True             ; These are necessary
   Opt3@DstRegional    = True
   Opt3@DstGridLat = lat0
   Opt3@DstGridLon = lon0
   Opt3@ForceOverwrite = True

   u2 = ESMF_regrid(u,Opt3)   ; Do the regridding - 0.5 degrees
   v2 = ESMF_regrid(v,Opt3)   ; Do the regridding - 0.5 degrees
   u2!0   ="time"
   u2!1   ="lat0"
   u2!2   ="lon0"
   u2&lat0 = lat0
   u2&lon0 = lon0
   u2@description = "NCEP-driven WRF derived 500 hPa U wind regridded to 0.1x0.1 regular grid"

   v2!0   ="time"
   v2!1   ="lat0"
   v2!2   ="lon0"
   v2&lat0 = lat0
   v2&lon0 = lon0
   v2@description = "NCEP-driven WRF derived 500 hPa V wind regridded to 0.1x0.1 regular grid"

   times3!0 = "time"


   system("/bin/rm -f "+OUTDIR+"WRF_d02_uv_KK_regrid.nc")
   out = addfile(OUTDIR+"WRF_d02_uv_KK_regrid.nc","c")
;   out->U1 = u
;   out->V1 = v
   out->U = u2
   out->V = v2
   out->Times = times3
   delete(out)


