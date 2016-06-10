load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

dirs=(/"/srv/ccrc/data31/z3393020/NARCliM/reanalysis/R1/out/","/srv/ccrc/data27/z3393020/WRF_NNRP/R2/1950-2010/out/","/srv/ccrc/data29/z3236814/NARCliM/reanalysis/R3/out/"/)

outfiles=(/"/srv/ccrc/data34/z3478332/WRF/WRF_R1_ncep1_precip.nc","/srv/ccrc/data34/z3478332/WRF/WRF_R2_ncep1_precip.nc","/srv/ccrc/data34/z3478332/WRF/WRF_R3_ncep1_precip.nc"/)

  fin=addfile("/srv/ccrc/data13/z3393020/Analyses/share/geo_em_files/geo_em.d01.narclim.nc","r")
  lat1 = wrf_user_getvar(fin,"XLAT_M",-1)
  lon1 = wrf_user_getvar(fin,"XLONG_M",-1)
  lat2=fspan(-90,90,73)
  lon2=fspan(0,357.5,144)
  lon3=fspan(105,180,151)
  lat3=fspan(-50,0,101)

  datafile = "date_195009.txt"
  dates = asciiread(datafile,-1,"string")
  yy = str_get_cols(dates, 0, 3)
  mm = str_get_cols(dates, 4, 5)
  dd = str_get_cols(dates, 7, 8)
  time = stringtoint(yy)*100+stringtoint(mm)

   Opt                = True
   Opt@DstGridLat = lat2
   Opt@DstGridLon = lon2
   Opt@ForceOverwrite = True

   Opt2                = True
   Opt2@DstGridLat = lat3
   Opt2@DstGridLon = lon3
   Opt2@ForceOverwrite = True

;Get rain at 23Z on 31/12/1989 to use for background
n=2

do while(n.lt.dimsizes(dirs))
f1=addfile(dirs(n) + "wrfhrly_d01_1950-01-01_00:00:00.nc","r")
r1=wrf_user_getvar(f1,"RAINC",-1) + wrf_user_getvar(f1,"RAINNC",-1)
rinit=r1(0,:,:)
delete([/r1,f1/])

rain = new((/720,144,215/),"float")
      
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
  
   rain@lat2d=lat1(0,:,:)
   rain@lon2d=lon1(0,:,:)

   rain2 = ESMF_regrid(rain,Opt)   ; Do the regridding - 1.5 degrees
   rain2!0 = "time"
   rain2!1   ="lat"
   rain2!2   ="lon"
   rain2&time = time
   rain2&lat = lat2
   rain2&lon = lon2
   rain2@description = "50 km WRF monthly rain regridded to 2.5 degree grid"

   rain3 = ESMF_regrid(rain,Opt2)   ; Do the regridding - 1.5 degrees
   rain3!0 = "time"
   rain3!1   ="lat50"
   rain3!2   ="lon50"
   rain3&time = time
   rain3&lat50 = lat3
   rain3&lon50 = lon3
   rain3@description = "50 km WRF monthly rain regridded to 0.5 degree grid"

   system("/bin/rm -f "+outfiles(n))
   out = addfile(outfiles(n),"c")
   dim_names = (/"time", "lat",  "lon" , "lat50",  "lon50" /)
   dim_sizes = (/ dimsizes(time) ,  dimsizes(lat2) ,  dimsizes(lon2),  dimsizes(lat3) ,  dimsizes(lon3)   /)
   dimUnlim = (/ True, False, False, False, False /)
   filedimdef( out, dim_names, dim_sizes, dimUnlim )

   out->prcp250 = rain2
   out->prcp50 = rain3

   delete([/rain,rain2,rain3,out/])
   n=n+1
end do
