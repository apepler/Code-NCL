load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

outfiles=(/"/srv/ccrc/data36/z3478332/CMIP3/WRF10_R2_miroc3.2_precip_noregrid.nc","/srv/ccrc/data36/z3478332/CMIP3/WRF10_R2_echam5_precip_noregrid.nc","/srv/ccrc/data36/z3478332/CMIP3/WRF10_R2_cccma_precip_noregrid.nc","/srv/ccrc/data36/z3478332/CMIP3/WRF10_R2_csiromk3_precip_noregrid.nc","/srv/ccrc/data36/z3478332/CMIP3/WRF10_R1_miroc3.2_precip_noregrid.nc","/srv/ccrc/data36/z3478332/CMIP3/WRF10_R1_echam5_precip_noregrid.nc","/srv/ccrc/data36/z3478332/CMIP3/WRF10_R1_cccma_precip_noregrid.nc","/srv/ccrc/data36/z3478332/CMIP3/WRF10_R1_csiromk3_precip_noregrid.nc","/srv/ccrc/data36/z3478332/CMIP3/WRF10_R3_miroc3.2_precip_noregrid.nc","/srv/ccrc/data36/z3478332/CMIP3/WRF10_R3_echam5_precip_noregrid.nc","/srv/ccrc/data36/z3478332/CMIP3/WRF10_R3_cccma_precip_noregrid.nc","/srv/ccrc/data36/z3478332/CMIP3/WRF10_R3_csiromk3_precip_noregrid.nc"/)

outfiles2=(/"/srv/ccrc/data36/z3478332/CMIP3/WRF10_R2_miroc3.2_precip_forcdo.nc","/srv/ccrc/data36/z3478332/CMIP3/WRF10_R2_echam5_precip_forcdo.nc","/srv/ccrc/data36/z3478332/CMIP3/WRF10_R2_cccma_precip_forcdo.nc","/srv/ccrc/data36/z3478332/CMIP3/WRF10_R2_csiromk3_precip_forcdo.nc","/srv/ccrc/data36/z3478332/CMIP3/WRF10_R1_miroc3.2_precip_forcdo.nc","/srv/ccrc/data36/z3478332/CMIP3/WRF10_R1_echam5_precip_forcdo.nc","/srv/ccrc/data36/z3478332/CMIP3/WRF10_R1_cccma_precip_forcdo.nc","/srv/ccrc/data36/z3478332/CMIP3/WRF10_R1_csiromk3_precip_forcdo.nc","/srv/ccrc/data36/z3478332/CMIP3/WRF10_R3_miroc3.2_precip_forcdo.nc","/srv/ccrc/data36/z3478332/CMIP3/WRF10_R3_echam5_precip_forcdo.nc","/srv/ccrc/data36/z3478332/CMIP3/WRF10_R3_cccma_precip_forcdo.nc","/srv/ccrc/data36/z3478332/CMIP3/WRF10_R3_csiromk3_precip_forcdo.nc"/)

  f2=addfile("/srv/ccrc/data30/z3393020/NARCliM/postprocess/1990-2009/ECHAM5/R2/d02/CCRC_NARCliM_MON_2000-2009_tasmax.nc","r")
  rot=f2->Rotated_pole
  lat=f2->lat
  lon=f2->lon

  datafile = "daylist3.csv"
  dates = asciiread(datafile,-1,"string")
  yy = str_get_cols(dates, 0, 3)
  mm = str_get_cols(dates, 4, 5)
  dd = str_get_cols(dates, 7, 8)
  time = stringtoint(yy)*100+stringtoint(mm)

n=0
do while(n.lt.dimsizes(outfiles))
out = addfile(outfiles(n),"r")
out2= addfile(outfiles2(n),"c")

rain=out->prcp
rain!0 = "time"
rain!1 = lat!0
rain!2 = lat!1
rain&time = time
rain@grid_mapping = "Rotated_pole"
rain@coordinates = "lon lat"

out2->prcp = rain
out2->lat=lat
out2->lon=lon
out2->Rotated_pole = rot

delete([/out,out2,rain/])
n=n+1
end do



