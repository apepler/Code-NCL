; Next complicated thing - WRF - NCEP?

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

INDIRS=(/"/srv/ccrc/data45/z3444417/CORDEX_postprocess/R2/6hr/"/)
OUTDIRS=(/"/srv/ccrc/data34/z3478332/WRF/ERA-nonudge/"/)

  fin=addfile("/srv/ccrc/data13/z3393020/Analyses/share/geo_em_files/geo_em.d01.narclim.nc","r")
  lat1=rm_single_dims(wrf_user_getvar(fin,"XLAT_M",-1))
  lon1=rm_single_dims(wrf_user_getvar(fin,"XLONG_M",-1))

;  fin=addfile("/srv/ccrc/data13/z3393020/Analyses/share/geo_em_files/geo_em.d02.narclim.nc","r")
;  lat2=rm_single_dims(wrf_user_getvar(fin,"XLAT_M",-1))
;  lon2=rm_single_dims(wrf_user_getvar(fin,"XLONG_M",-1))

  levlist=fspan(300.,900.,13)
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
;do while(n.lt.1)
  INDIR=INDIRS(n)
  OUTDIR=OUTDIRS(n)
  print(INDIR)

  year=1990
  year2=2009
  month1=1
  month2=12

do while(year.le.year2)
    print(year)

i=0
do while(i.lt.dimsizes(levlist))

  FILES1=INDIR+"zg"+levlist(i)+"/zg"+levlist(i)+"_AUS-44_ECMWF-ERAINT_evaluation_r1p1i1_UNSW-WRF360K_v1_6hr_"+year+"010100-"+year+"123118.nc"
  f1 = addfile(FILES1,"r")
  z = wrf_user_getvar(f1,"zg"+levlist(i),-1)

  if(i.eq.0) then
     dim=dimsizes(z)
     dim2=dimsizes(lat1)
     zNew = new((/dim(0),dimsizes(levlist),dim2(0),dim2(1)/),"float")
     delete([/dim,dim2/])
  end if
   zNew(:,i,8:135,8:206) = z
   delete([/FILES1,f1,z/])

   i=i+1
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

  outfile=OUTDIR+"WRF_d01_gph_"+year
  system("/bin/rm -f "+outfile+"_regrid.nc")
  out = addfile(outfile+"_regrid.nc","c")
  out->Z=zNew2
  ;out->Times=times3
  out->lev=levlist

  delete([/out,outfile,zNew,zNew2/])

year=year+1
end do
n=n+1
end do

