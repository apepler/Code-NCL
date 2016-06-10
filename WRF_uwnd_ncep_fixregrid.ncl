load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

infiles=(/"/srv/ccrc/data34/z3478332/WRF/WRF_R1_ncep1_uwnd_noregrid.nc","/srv/ccrc/data34/z3478332/WRF/WRF_R2_ncep1_uwnd_noregrid.nc","/srv/ccrc/data34/z3478332/WRF/WRF_R3_ncep1_uwnd_noregrid.nc"/)

outfiles=(/"WRF_R1_ncep1_uwnd.nc","WRF_R2_ncep1_uwnd.nc","WRF_R3_ncep1_uwnd.nc"/)

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

n=0
do while(n.lt.dimsizes(infiles))
a=addfile(infiles(n),"r")
u3=a->uwnd
delete(u3@lat2d)
delete(u3@lon2d)
   u3@lat2d=lat1(0,:,:)
   u3@lon2d=lon1(0,:,:)

   u4 = ESMF_regrid(u3,Opt)   ; Do the regridding - 1.5 degrees
   u4!0   ="time"
   u4!1   ="lat"
   u4!2   ="lon"
   u4&time = time
   u4&lat = lat2
   u4&lon = lon2
   u4@description = "50 km WRF monthly 850hPa u-wind regridded to 2.5 degree grid"

   u5 = ESMF_regrid(u3,Opt2)   ; Do the regridding - 1.5 degrees
   u5!0   ="time"
   u5!1   ="lat50"
   u5!2   ="lon50"
   u5&time = time
   u5&lat50 = lat3
   u5&lon50 = lon3
   u5@description = "50 km WRF monthly 850hPa u-wind regridded to 0.5 degree grid"

   print("Writing")
   system("/bin/rm -f "+outfiles(n))
   out = addfile(outfiles(n),"c")
   dim_names = (/"time", "lat",  "lon","lat50","lon50" /)
   dim_sizes = (/ dimsizes(time) ,  dimsizes(lat2) ,  dimsizes(lon2),  dimsizes(lat3) ,  dimsizes(lon3)   /)
   dimUnlim = (/ True, False, False,False,False /)
   filedimdef( out, dim_names, dim_sizes, dimUnlim )

   out->uwnd250 = u4
   out->uwnd50 = u5
   delete([/u3,u4,u5,out/])
   n=n+1
end do

