load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

in1 = addfile("/srv/ccrc/data34/z3478332/ERAI/ERAI_mslp_1979-01_1983-12.nc","r")
slp1 = short2flt(in1->msl)
time1 = in1->time
lat1 = in1->latitude
lon1 = in1->longitude

in2 = addfile("/srv/ccrc/data34/z3478332/ERAI/ERAI_mslp_1984-01_1988-12.nc","r")
slp2 = short2flt(in2->msl)
time2 = in2->time

lat = lat1(0:120:2)
lon = lon1(0:239:2)
slp = array_append_record(slp1(:,0:120:2,0:239:2), slp2(:,0:120:2,0:239:2),0)
slp!0   ="time"
slp!1   ="lat"
slp!2   ="lon"
slp&time = array_append_record(time1,time2,0)
slp&lat = lat
slp&lon = lon

system("/bin/rm -f /srv/ccrc/data34/z3478332/ERAI/ERAI_mslp_1979-01_1988-12_half.nc")
out = addfile("/srv/ccrc/data34/z3478332/ERAI/ERAI_mslp_1979-01_1988-12_half.nc","c")
out->msl = slp

