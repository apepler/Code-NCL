load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

dirs=(/"/srv/ccrc/data31/z3393020/NARCliM/reanalysis/R1/out/","/srv/ccrc/data27/z3393020/WRF_NNRP/R2/1950-2010/out/","/srv/ccrc/data29/z3236814/NARCliM/reanalysis/R3/out/"/)

outfiles=(/"/srv/ccrc/data23/z3478332/WRF/WRF_prcp_R1_monthly.nc","/srv/ccrc/data23/z3478332/WRF/WRF_prcp_R2_monthly.nc","/srv/ccrc/data23/z3478332/WRF/WRF_prcp_R3_monthly.nc"/)

  fin=addfile("/home/z3478332/WRF/WRFV3/test/em_real/wrfinput_d01.nc","r")
  lat = wrf_user_getvar(fin,"XLAT",-1)
  lon = wrf_user_getvar(fin,"XLONG",-1)

  datafile = "daylist5.csv"
  dates = asciiread(datafile,-1,"string")
  yy = str_get_cols(dates, 0, 3)
  mm = str_get_cols(dates, 4, 5)
  dd = str_get_cols(dates, 7, 8)
  time = stringtoint(yy)*100+stringtoint(mm)

n=0

do while(n.lt.dimsizes(dirs))

;Get rain at 00Z on 1/1/1980 to use for background
f1=addfile(dirs(n) + "wrfhrly_d01_1980-01-01_00:00:00.nc","r")
r1=wrf_user_getvar(f1,"RAINC",-1) + wrf_user_getvar(f1,"RAINNC",-1)
rinit=r1(0,:,:)
delete([/r1,f1/])

rain = new((/360,144,215/),"float")
      
i=0
do while(i.lt.dimsizes(dates))
  if(mm(i).eq."01") then
    print(time(i))
  end if
  f2 = addfile(dirs(n) + "wrfhrly_d01_" + yy(i) + "-" + mm(i) +"-01_00:00:00.nc","r")
  r1 = wrf_user_getvar(f2,"RAINC",-1) + wrf_user_getvar(f2,"RAINNC",-1)
  dsizes=dimsizes(r1)
  rain(i,:,:) = r1(dsizes(0)-1,:,:)-rinit
  rinit=r1(dsizes(0)-1,:,:)
  delete([/f2,r1,dsizes/])
  i=i+1
end do
  
   rain@lat2d=lat(0,:,:)
   rain@lon2d=lon(0,:,:)
   rain!0 = "time"
   rain!1   ="west_east"
   rain!2   ="north_south"

   system("/bin/rm -f "+outfiles(n))
   out = addfile(outfiles(n),"c")
   dim_names = (/"time", "west_east",  "north_south" /)
   dim_sizes = (/ dimsizes(time) ,  215, 144  /)
   dimUnlim = (/ True, False, False /)
   filedimdef( out, dim_names, dim_sizes, dimUnlim )

   out->prcp = rain
   out->lat = lat
   out->lon = lon

   delete([/rain,out/])
   n=n+1
end do
