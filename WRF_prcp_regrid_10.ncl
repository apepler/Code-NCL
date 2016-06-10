load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

;/srv/ccrc/data12/z3393020/MIROC3.2/R2/1990-2010/out/
;/srv/ccrc/data20/z3393020/WRF_ECHAM5/R2/1990-2010/out/
;/srv/ccrc/data24/z3393020/WRF_CCCMA/R2/1990-2010/out
;/srv/ccrc/data23/z3444417/NARCliM/CSIRO-Mk3.0/1990-2009/R2/out

dirs=(/"/srv/ccrc/data12/z3393020/MIROC3.2/R2/1990-2010/out/","/srv/ccrc/data20/z3393020/WRF_ECHAM5/R2/1990-2010/out/","/srv/ccrc/data24/z3393020/WRF_CCCMA/R2/1990-2010/out/","/srv/ccrc/data23/z3444417/NARCliM/CSIRO-Mk3.0/1990-2009/R2/out/"/)

outfiles=(/"/srv/ccrc/data23/z3478332/CMIP3/WRF10_miroc3.2_monthly.nc","/srv/ccrc/data23/z3478332/CMIP3/WRF10_echam5_monthly.nc","/srv/ccrc/data23/z3478332/CMIP3/WRF10_cccma_monthly.nc","/srv/ccrc/data23/z3478332/CMIP3/WRF10_csiromk3_monthly.nc"/)

  fin=addfile("/srv/ccrc/data28/z3393020/NARCliM/reanalysis/R1/bdy_data/wrfinput_d02_1980-01.nc","r")
  lat1 = wrf_user_getvar(fin,"XLAT",-1)
  lon1 = wrf_user_getvar(fin,"XLONG",-1)
  lat2=fspan(-90,90,73)
  lon2=fspan(0,357.5,144)

  datafile = "daylist3.csv"
  dates = asciiread(datafile,-1,"string")
  yy = str_get_cols(dates, 0, 3)
  mm = str_get_cols(dates, 4, 5)
  dd = str_get_cols(dates, 7, 8)
  time = stringtoint(yy)*100+stringtoint(mm)

   Opt                = True
   Opt@DstGridLat = lat2
   Opt@DstGridLon = lon2
   Opt@ForceOverwrite = True

;Get rain at 23Z on 31/12/1989 to use for background
n=0

do while(n.lt.dimsizes(dirs))
f1=addfile(dirs(n) + "wrfhrly_d02_1990-01-01_00:00:00.nc","r")
rinit=wrf_user_getvar(f1,"RAINC",0) + wrf_user_getvar(f1,"RAINNC",0)
delete(f1)

rain = new((/240,200,325/),"float")
      
i=0
do while(i.lt.dimsizes(dates))
  if(mm(i).eq."01") then
    print(time(i))
  end if
  f2 = addfile(dirs(n) + "wrfhrly_d02_" + yy(i) + "-" + mm(i) +"-01_00:00:00.nc","r")
  dsizes  =  getfiledimsizes(f2) ; get times in the file
  ntimes = dsizes(0)-1       ; number of times in the file
  r1 = wrf_user_getvar(f2,"RAINC",ntimes) + wrf_user_getvar(f2,"RAINNC",ntimes)
  rain(i,:,:) = r1-rinit
  rinit=r1
  delete([/f2,r1,dsizes,ntimes/])
  i=i+1
end do
  
   rain@lat2d=lat1(0,:,:)
   rain@lon2d=lon1(0,:,:)

   rain2 = ESMF_regrid(rain,Opt)   ; Do the regridding - 1.5 degrees
   rain2!0 = "time"
   rain2!1   ="lat"
   rain2!2   ="lon"
   rain2&time = time
   rain2&lat = lat2
   rain2&lon = lon2
   rain2@description = "WRF monthly rain regridded to 2.5 degree grid"

   system("/bin/rm -f "+outfiles(n))
   out = addfile(outfiles(n),"c")
   dim_names = (/"time", "lat",  "lon" /)
   dim_sizes = (/ dimsizes(time) ,  dimsizes(lat2) ,  dimsizes(lon2)  /)
   dimUnlim = (/ True, False, False /)
   filedimdef( out, dim_names, dim_sizes, dimUnlim )

   out->prcp = rain2

   delete([/rain,rain2,out/])
   n=n+1
end do
