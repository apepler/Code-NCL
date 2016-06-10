; Next complicated thing - WRF - NCEP?

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

;  INDIRS=(/"/srv/ccrc/data36/z3478332/WRF/output/ERAI_R1_nudging_default_2007/out/","/srv/ccrc/data36/z3478332/WRF/output/ERAI_R3_nudging_default_2007/out/","/srv/ccrc/data36/z3478332/WRF/output/ERAI_R1_nudging_default_2007_notopo/out/","/srv/ccrc/data36/z3478332/WRF/output/ERAI_R3_nudging_default_2007_notopo/out/"/)

;  INDIRS=(/"/srv/ccrc/data45/z3478332/WRF/output/ERAI_R1_nudging_default_2007_BRAN_2eac/out/","/srv/ccrc/data45/z3478332/WRF/output/ERAI_R3_nudging_default_2007_BRAN_2eac/out/","/srv/ccrc/data36/z3478332/WRF/output/ERAI_R2_nudging_default_2007_BRAN_2eac/out/"/)

;  OUTDIRS=(/"/srv/ccrc/data45/z3478332/WRF/output/ERAI_R1_nudging_default_2007_BRAN_2eac/out/","/srv/ccrc/data45/z3478332/WRF/output/ERAI_R3_nudging_default_2007_BRAN_2eac/out/","/srv/ccrc/data45/z3478332/WRF/output/ERAI_R2_nudging_default_2007_BRAN_2eac/out/"/)

INDIRS=(/"/srv/ccrc/data45/z3478332/WRF/output/ERAI_R2_nonudging_notopo/out/"/)
OUTDIRS=INDIRS

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

n=0
do while(n.lt.dimsizes(INDIRS))
  INDIR=INDIRS(n)
  OUTDIR=OUTDIRS(n)+"slp/"

  year=1990
   year2=2009

  do while(year.le.year2)
  month1=1
  month2=12

  i=month1
  do while(i.le.month2)

  print(year+sprinti("%0.2i",i))

  FILES1 = systemfunc (" ls -1 " + INDIR + "wrfout_d01_"+year+"-"+sprinti("%0.2i",i)+"-??_??:00:00")
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
  ;wrf_smooth_2d( slp1a, 3 )            ; smooth slp
  slp1a@lat2d=lat1
  slp1a@lon2d=lon1
  slp1c = ESMF_regrid(slp1a,Opt3)   ; Do the regridding - 0.5 degrees
  slp1c!0   ="time"
  slp1c!1   ="lat0"
  slp1c!2   ="lon0"
  slp1c&lat0 = lat0
  slp1c&lon0 = lon0
  slp1c@description = "NCEP-driven WRF slp regridded to 0.5x0.5 regular grid"

  FILES2 = systemfunc (" ls -1 " + INDIR + "wrfout_d02_"+year+"-"+sprinti("%0.2i",i)+"-??_??:00:00")
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

   outfile=OUTDIR+"WRF_d01_slp_"+year+sprinti("%0.2i",i)
   system("/bin/rm -f "+outfile+"_regrid.nc")
   out = addfile(outfile+"_regrid.nc","c")
   out->slp0 = slp1c
   out->Times = times3
   delete([/outfile,out/])

   outfile=OUTDIR+"WRF_d02_slp_"+year+sprinti("%0.2i",i)
   system("/bin/rm -f "+outfile+"_regrid.nc")
   out = addfile(outfile+"_regrid.nc","c")
   out->slp0 = slp3
   out->Times = times3
   delete(out)
 
   delete([/times,times2,times3,yy,mm,dd,hh,FILES1,FILES2,f3/])
   delete([/slp1,slp1a,slp1c/])
   delete([/slp2,slp2a,slp2c,slp3,f4,outfile/])

i=i+1
end do
year=year+1
end do
n=n+1
end do



