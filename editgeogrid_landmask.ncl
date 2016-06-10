load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

f1=addfile("/srv/ccrc/data36/z3478332/WRF/geogrid/geo_em.d01.nznoland.nc","w")
land=f1->LANDMASK
landusef=f1->LANDUSEF
lu_index=f1->LU_INDEX

land(:,13:49,129:169)=0 ; Make ocean
lu_index(:,13:49,129:169)=16 ; Make ocean
landusef(:,:,13:49,129:169)=0 ; Make no percentages
landusef(:,15,13:49,129:169)=1 ; Fix category 16

f1->LANDMASK = land
f1->LANDUSEF = landusef
f1->LU_INDEX = lu_index
