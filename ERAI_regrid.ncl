load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

; First, need to copy each ERAI file to a new netcdf.
; Then we run this on each netcdf file

; Want to take it to the same lat/lon as NCEP
ncep = addfile("/srv/ccrc/data23/z3478332/NCEP/slp.1948.nc","r")
lat = ncep->lat
lon = ncep->lon

in = addfile("/srv/ccrc/data23/z3444417/studies/Data/ERAI/global/psl/raw/ERAI_mslp_1989-01_1999-12.nc","r")
slp1 = short2flt(in->msl)
time = in->time
lat1 = in->latitude
lon1 = in->longitude

slp = linint2(lon1,lat1,slp1,True,lon,lat,0)
slp!0   ="time"
slp!1   ="lat"
slp!2   ="lon"
slp&time = time
slp&lat = lat
slp&lon = lon

system("/bin/rm -f /srv/ccrc/data23/z3478332/ERAI/ERAI_mslp_1989-01_1999-12_regrid.nc")
out = addfile("/srv/ccrc/data23/z3478332/ERAI/ERAI_mslp_1989-01_1999-12_regrid.nc","c")
out->msl = slp

delete(slp1)
delete(slp)
delete(time)

in = addfile("/srv/ccrc/data23/z3444417/studies/Data/ERAI/global/psl/raw/ERAI_mslp_2000-01_2010-12.nc","r")
slp1 = short2flt(in->msl)
time = in->time
slp = linint2(lon1,lat1,slp1,True,lon,lat,0)
slp!0   ="time"
slp!1   ="lat"
slp!2   ="lon"
slp&time = time
slp&lat = lat
slp&lon = lon

system("/bin/rm -f /srv/ccrc/data23/z3478332/ERAI/ERAI_mslp_2000-01_2010-12_regrid.nc")
out = addfile("/srv/ccrc/data23/z3478332/ERAI/ERAI_mslp_2000-01_2010-12_regrid.nc","c")
out->msl = slp

; For some ungodly reason this doesn't like me. Think I'll try a version without interpolation
; Just taking every second value

in = addfile("/srv/ccrc/data23/z3444417/studies/Data/ERAI/global/psl/raw/ERAI_mslp_1989-01_1999-12.nc","r")
slp1 = short2flt(in->msl)
time = in->time
lat1 = in->latitude
lon1 = in->longitude

lat = lat1(0:120:2)
lon = lon1(0:239:2)
slp = slp1(:,0:120:2,0:239:2) 
slp!0   ="time"
slp!1   ="lat"
slp!2   ="lon"
slp&time = time
slp&lat = lat
slp&lon = lon

system("/bin/rm -f /srv/ccrc/data23/z3478332/ERAI/ERAI_mslp_1989-01_1999-12_half.nc")
out = addfile("/srv/ccrc/data23/z3478332/ERAI/ERAI_mslp_1989-01_1999-12_half.nc","c")
out->msl = slp

delete(slp1)
delete(slp)
delete(time)

in = addfile("/srv/ccrc/data23/z3444417/studies/Data/ERAI/global/psl/raw/ERAI_mslp_2000-01_2010-12.nc","r")
slp1 = short2flt(in->msl)
time = in->time
slp = slp1(:,0:120:2,0:239:2) 
slp!0   ="time"
slp!1   ="lat"
slp!2   ="lon"
slp&time = time
slp&lat = lat
slp&lon = lon

system("/bin/rm -f /srv/ccrc/data23/z3478332/ERAI/ERAI_mslp_2000-01_2010-12_half.nc")
out = addfile("/srv/ccrc/data23/z3478332/ERAI/ERAI_mslp_2000-01_2010-12_half.nc","c")
out->msl = slp

