; Next complicated thing - WRF - NCEP?

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

  INDIR="/srv/ccrc/data36/z3478332/WRF/output/ERAI_R2_nudging_default/out/"
  OUTDIR=INDIR

  f2=addfile("/srv/ccrc/data30/z3393020/NARCliM/postprocess/1990-2009/ECHAM5/R2/d02/CCRC_NARCliM_MON_2000-2009_tasmax.nc","r")
  rot=f2->Rotated_pole
  lat=f2->lat
  lon=f2->lon

  FILES1 = systemfunc (" ls -1 " + INDIR + "wrfout_d02_????-??-??_??:00:00")
  f1 = addfiles(FILES1+".nc","r")
  slp = wrf_user_getvar(f1,"slp",-1)    ; slp
  wrf_smooth_2d( slp, 3 )            ; smooth slp
  times = wrf_user_getvar(f1,"times",-1)

  yy = stringtointeger(str_get_cols(times, 0, 3))
  mm = stringtointeger(str_get_cols(times, 5, 6))
  dd = stringtointeger(str_get_cols(times, 8, 9))
  hh = stringtointeger(str_get_cols(times, 11, 12))
  times2=yy*1000000+mm*10000+dd*100+hh
  
  slp2=slp(56:71:2,:,:)
  times3=times2(56:71:2)
;  lon0=fspan(105,180,151)
;  lat0=fspan(-50,0,101)
  lon0=fspan(145,165,201)
  lat0=fspan(-45,-20,251)
  slp2@lat2d=lat
  slp2@lon2d=lon

  times3!0 = "time"
  slp2!0 = "time"
  slp2!1 = lat!0
  slp2!2 = lat!1
  slp2@grid_mapping = "Rotated_pole"
  slp2@coordinates = "lon lat"
  
  system("/bin/rm -f "+OUTDIR+"WRF_d02_slp_KK.nc")
  out = addfile(OUTDIR+"WRF_d02_slp_KK.nc","c")
  out->slp=slp2
  out->Times=times3
  out->lat=lat
  out->lon=lon
  out->Rotated_pole = rot

  delete(out)

   Opt3                = True
   Opt3@SrcRegional    = True             ; These are necessary
   Opt3@DstRegional    = True
   Opt3@DstGridLat = lat0
   Opt3@DstGridLon = lon0
   Opt3@ForceOverwrite = True
   slp5 = ESMF_regrid(slp2,Opt3)   ; Do the regridding - 0.5 degrees
   slp5!0   ="time"
   slp5!1   ="lat0"
   slp5!2   ="lon0"
   slp5&lat0 = lat0
   slp5&lon0 = lon0
   slp5@description = "NCEP-driven WRF slp regridded to 0.1x0.1 regular grid"

   system("/bin/rm -f "+OUTDIR+"WRF_d02_slp_KK_regrid.nc")
   out = addfile(OUTDIR+"WRF_d02_slp_KK_regrid.nc","c")
   out->slp0 = slp5
   out->Times = times3

