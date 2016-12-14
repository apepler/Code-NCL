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
; Get the 6-hourly rainfall totals

  FILES1 = systemfunc (" ls -1 " + INDIR + "wrfhrly_d01_" + year + "-??-??_00:00:00")
; Since it's centred, 01-01-0000Z needs previous three hours. Except for year 1 
  f1 = addfiles(FILES1+".nc","r")
  times=wrf_user_getvar(f1,"times",-1)
  numDAYS = dimsizes(times)/6

  var_in1=wrf_user_getvar(f1,"PREC_ACC_NC",-1)+wrf_user_getvar(f1,"PREC_ACC_C",-1)
  rain=new((/numDAYS,144,215/),typeof(var_in1))

  if(year.eq.year1) then
    rain(0,:,:) = dim_sum_n_Wrap(var_in1(0:2,:,:),0)
  else
    f2=addfile(INDIR + "wrfhrly_d01_" + (year-1) + "-12-01_00:00:00.nc","r")
    times2=wrf_user_getvar(f2,"times",-1)
    gettime=ispan(dimsizes(times2)-3,dimsizes(times2)-1,1)
    var_in2=wrf_user_getvar(f1,"PREC_ACC_NC",gettime)+wrf_user_getvar(f1,"PREC_ACC_C",gettime)
    rain(0,:,:) = dim_sum_n_Wrap(var_in1(0:2,:,:),0)+dim_sum_n_Wrap(var_in2,0)
    delete([/f2,times2,gettime,var_in2/])
  end if

  do ip = 1,numDAYS-1      
      rain(ip,:,:) = dim_sum_n_Wrap(var_in1((ip*6-3):(ip*6+2),:,:),0)
  end do

fout=OUTDIRS(n)+"pr_"+year+"_d01_6hr_centred.nc"
rain!0="Time"
rain!1="south_north"
rain!2="east_west"
rain@description="6-hour rain acumulation centred around the observation time"

system("/bin/rm -f "+fout)
out = addfile(fout,"c")
out->rain=rain
;out->time=times(0:(dimsizes(times)-1):6)

delete([/rain,out,fout,var_in1,FILES1,f1,numDAYS,times/])
year=year+1
end do

n=n+1
end do
