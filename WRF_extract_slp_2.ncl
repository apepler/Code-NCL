; Next complicated thing - WRF - NCEP?

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

  INDIRS=(/"/srv/ccrc/data36/z3478332/WRF/output/ERAI_R1_nudging_default_2007_BRAN_2eac/out/","/srv/ccrc/data36/z3478332/WRF/output/ERAI_R2_nudging_default_2007_BRAN_2eac/out/","/srv/ccrc/data36/z3478332/WRF/output/ERAI_R3_nudging_default_2007_BRAN_2eac/out/"/)

  f2=addfile("/srv/ccrc/data30/z3393020/NARCliM/postprocess/1990-2009/ECHAM5/R2/d01/CCRC_NARCliM_MON_2000-2009_tasmax.nc","r")
  rot=f2->Rotated_pole
  lat=f2->lat
  lon=f2->lon
  lon0=fspan(105,180,151)
  lat0=fspan(-50,0,101)

n=0
do while(n.lt.dimsizes(INDIRS))
  INDIR=INDIRS(n)
  OUTDIR=INDIR+"slp/"

  year=2008
  month1=1
  month2=12

  i=month1
  do while(i.le.month2)
    print(year+sprinti("%0.2i",i))
    FILES1 = systemfunc (" ls -1 " + INDIR + "wrfout_d01_"+year+"-"+sprinti("%0.2i",i)+"-??_??:00:00")
  f1 = addfiles(FILES1+".nc","r")
  slp = wrf_user_getvar(f1,"slp",-1)    ; slp
  wrf_smooth_2d( slp, 3 )            ; smooth slp
  times = wrf_user_getvar(f1,"times",-1)

  yy = stringtointeger(str_get_cols(times, 0, 3))
  mm = stringtointeger(str_get_cols(times, 5, 6))
  dd = stringtointeger(str_get_cols(times, 8, 9))
  hh = stringtointeger(str_get_cols(times, 11, 12))
  times2=yy*1000000+mm*10000+dd*100+hh
  
  times2!0 = "time"
  slp!0 = "time"
  slp!1 = lat!0
  slp!2 = lat!1
  slp@grid_mapping = "Rotated_pole"
  slp@coordinates = "lon lat"
  
  outfile=OUTDIR+"WRF_d01_slp_"+year+sprinti("%0.2i",i)
system("/bin/rm -f "+outfile+".nc")
  out = addfile(outfile+".nc","c")
  out->slp=slp
  out->Times=times2
  out->lat=lat
  out->lon=lon
  out->Rotated_pole = rot
  delete(out)

  dim=dimsizes(slp)
  l=dim(0)-1
  slp2=slp(0:l:2,:,:)
  times3=times2(0:l:2)
  slp2@lat2d=lat
  slp2@lon2d=lon

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
   slp5@description = "NCEP-driven WRF slp regridded to 0.5x0.5 regular grid"

   system("/bin/rm -f "+outfile+"_regrid.nc")
   out = addfile(outfile+"_regrid.nc","c")
   out->slp0 = slp5
   out->Times = times3
   i=i+1
   delete([/FILES1,f1,times,slp,yy,mm,dd,hh,times2/])
   delete([/out,outfile,Opt3,slp2,slp5,dim,l,times3/])
end do
n=n+1
end do

