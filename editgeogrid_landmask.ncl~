load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

f1=addfile("/srv/ccrc/data36/z3478332/WRF/geogrid/geo_em.d01.default.nc","r")
f2=addfile("/srv/ccrc/data36/z3478332/WRF/geogrid/geo_em.d01.notopo.nc","r")

f3=addfile("/srv/ccrc/data36/z3478332/WRF/geogrid/geo_em.d01.austnotopo.nc","w")
f4=addfile("/srv/ccrc/data36/z3478332/WRF/geogrid/geo_em.d01.nznotopo.nc","w")

hgt1=f1->HGT_M
hgt2=f2->HGT_M

hgt3=hgt1
hgt3(:,24:102,29:119)=hgt2(:,24:102,29:119) ; Make all Australia notopo
hgt3(:,93:102,29:65)=hgt1(:,93:102,29:65) ; Fix indonesia
f3->HGT_M = hgt3

hgt4=hgt1
hgt4(:,13:49,129:169)=hgt2(:,13:49,129:169) ; Make all NZ notopo
f4->HGT_M = hgt4
