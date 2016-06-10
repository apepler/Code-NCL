load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

;/srv/ccrc/data12/z3393020/MIROC3.2/R2/1990-2010/out/
;/srv/ccrc/data20/z3393020/WRF_ECHAM5/R2/1990-2010/out/
;/srv/ccrc/data24/z3393020/WRF_CCCMA/R2/1990-2010/out
;/srv/ccrc/data23/z3444417/NARCliM/CSIRO-Mk3.0/1990-2009/R2/out

dirs=(/"/srv/ccrc/data12/z3393020/MIROC3.2/R2/1990-2010/out/","/srv/ccrc/data20/z3393020/WRF_ECHAM5/R2/1990-2010/out/","/srv/ccrc/data24/z3393020/WRF_CCCMA/R2/1990-2010/out/","/srv/ccrc/data23/z3444417/NARCliM/CSIRO-Mk3.0/1990-2009/R2/out/","/srv/ccrc/data11/z3393020/MIROC3.2/R1/1990-2010/out/","/srv/ccrc/data20/z3393020/WRF_ECHAM5/R1/1990-2010/out/","/srv/ccrc/data21/z3393020/WRF_CCCMA/R1/1990-2010/out/","/srv/ccrc/data25/z3444417/NARCliM/CSIRO-Mk3.0/1990-2009/R1/out/","/srv/ccrc/data14/z3393020/MIROC3.2/R3/1990-2010/out/","/srv/ccrc/data14/z3393020/WRF_ECHAM5/R3/1990-2010/out/","/srv/ccrc/data21/z3393020/WRF_CCCMA/R3/1990-2010/out/","/srv/ccrc/data26/z3444417/studies/NARCliM/CSIRO-Mk3.0/1990-2009/R3/out/"/)

outfiles=(/"/srv/ccrc/data36/z3478332/CMIP3/WRF10_R2_miroc3.2_precip_noregrid.nc","/srv/ccrc/data36/z3478332/CMIP3/WRF10_R2_echam5_precip_noregrid.nc","/srv/ccrc/data36/z3478332/CMIP3/WRF10_R2_cccma_precip_noregrid.nc","/srv/ccrc/data36/z3478332/CMIP3/WRF10_R2_csiromk3_precip_noregrid.nc","/srv/ccrc/data36/z3478332/CMIP3/WRF10_R1_miroc3.2_precip_noregrid.nc","/srv/ccrc/data36/z3478332/CMIP3/WRF10_R1_echam5_precip_noregrid.nc","/srv/ccrc/data36/z3478332/CMIP3/WRF10_R1_cccma_precip_noregrid.nc","/srv/ccrc/data36/z3478332/CMIP3/WRF10_R1_csiromk3_precip_noregrid.nc","/srv/ccrc/data36/z3478332/CMIP3/WRF10_R3_miroc3.2_precip_noregrid.nc","/srv/ccrc/data36/z3478332/CMIP3/WRF10_R3_echam5_precip_noregrid.nc","/srv/ccrc/data36/z3478332/CMIP3/WRF10_R3_cccma_precip_noregrid.nc","/srv/ccrc/data36/z3478332/CMIP3/WRF10_R3_csiromk3_precip_noregrid.nc"/)

  fin=addfile("/srv/ccrc/data13/z3393020/Analyses/share/geo_em_files/geo_em.d02.narclim.nc","r")
  lat1 = wrf_user_getvar(fin,"XLAT_M",-1)
  lon1 = wrf_user_getvar(fin,"XLONG_M",-1)

  datafile = "daylist3.csv"
  dates = asciiread(datafile,-1,"string")
  yy = str_get_cols(dates, 0, 3)
  mm = str_get_cols(dates, 4, 5)
  dd = str_get_cols(dates, 7, 8)
  time = stringtoint(yy)*100+stringtoint(mm)

;Get rain at 23Z on 31/12/1989 to use for background
n=0

do while(n.lt.dimsizes(dirs))
f1=addfile(dirs(n) + "wrfhrly_d02_1990-01-01_00:00:00.nc","r")
r1=wrf_user_getvar(f1,"RAINC",-1) + wrf_user_getvar(f1,"RAINNC",-1)
rinit=r1(0,:,:)
delete([/r1,f1/])

rain = new((/240,200,325/),"float")
      
i=0
do while(i.lt.dimsizes(dates))
  if(mm(i).eq."01") then
    print(time(i))
  end if
  f2 = addfile(dirs(n) + "wrfhrly_d02_" + yy(i) + "-" + mm(i) +"-01_00:00:00.nc","r")
  r1 = wrf_user_getvar(f2,"RAINC",-1) + wrf_user_getvar(f2,"RAINNC",-1)
  dsizes=dimsizes(r1)
  rain(i,:,:) = r1(dsizes(0)-1,:,:)-rinit
  rinit=r1(dsizes(0)-1,:,:)
  delete([/f2,r1,dsizes/])
  i=i+1
end do
  

   system("/bin/rm -f "+outfiles(n))
   out = addfile(outfiles(n),"c")
   out->prcp = rain
   out->lat = lat1
   out->lon = lon1ain3

   delete([/rain,out/])
   n=n+1
end do
