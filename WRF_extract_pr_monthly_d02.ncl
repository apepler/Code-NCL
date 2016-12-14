load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
;load "./WRFUserARW.ncl"

begin

  DATADir="/srv/ccrc/data45/z3478332/WRF/output/ERAI_R2_nonudging_notopo/out/"
  OUTDir = "/srv/ccrc/data45/z3478332/WRF/output/ERAI_R2_nonudging_notopo/out/impact/"  

;DATADir="/srv/ccrc/data33/z3481416/CCRC-WRF3.6.0.5-SEB/ERA-Interim/R2_nudging/out/"
;OUTDir="/srv/ccrc/data34/z3478332/WRF/ERA-nudge/"

  fin=addfile("/srv/ccrc/data13/z3393020/Analyses/share/geo_em_files/geo_em.d02.narclim.nc","r")
  lat1=wrf_user_getvar(fin,"XLAT_M",-1)
  lon1=wrf_user_getvar(fin,"XLONG_M",-1)
  delete(fin)
  a=dimsizes(lat1)
  PRCP_d02 = new((/a(1),a(2),240/),"float")
  PRCP_d02!0 = lat1!1
  PRCP_d02!1 = lat1!2
  PRCP_d02!2 = "Time"
  PRCP_d02@description="Total precipitation"
  PRCP_d02@units = "mm"


n=0
year=1990
year2=2009
do while(year.le.year2)
m=1
do while(m.le.12)
  print(year)
  FILES1 = systemfunc (" ls -1 " + DATADir + "wrfhrly_d02_"+year+"-"+sprinti("%0.2i",m)+"-??_00:00:00")
  f1 = addfiles(FILES1+".nc","r")
  PRCP_d02(:,:,n)=dim_sum_n_Wrap(wrf_user_getvar(f1,"PREC_ACC_NC",-1),0)+dim_sum_n_Wrap(wrf_user_getvar(f1,"PREC_ACC_C",-1),0)
  delete([/f1,FILES1/])

n=n+1
m=m+1
end do
year=year+1
end do

  
  outfile=OUTDir+"WRF_d02_monthly_pr"
  system("/bin/rm -f "+outfile+".nc")
  out = addfile(outfile+".nc","c")
  out->PRCP_d02=PRCP_d02

end