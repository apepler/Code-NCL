load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
;load "./WRFUserARW.ncl"

begin

  DATADir="/srv/ccrc/data45/z3478332/WRF/output/ERAI_R2_nonudging_notopo/out/"
  OUTDir = "/srv/ccrc/data45/z3478332/WRF/output/ERAI_R2_nonudging_notopo/out/impact/"  

;DATADir="/srv/ccrc/data33/z3481416/CCRC-WRF3.6.0.5-SEB/ERA-Interim/R2_nudging/out/"
;OUTDir="/srv/ccrc/data34/z3478332/WRF/ERA-nudge/"

  fin=addfile("/srv/ccrc/data13/z3393020/Analyses/share/geo_em_files/geo_em.d01.narclim.nc","r")
  lat1=wrf_user_getvar(fin,"XLAT_M",-1)
  lon1=wrf_user_getvar(fin,"XLONG_M",-1)
  delete(fin)
  a=dimsizes(lat1)
  QFX_d01 = new((/a(1),a(2),240/),"float")
  QFX_d01!0 = lat1!1
  QFX_d01!1 = lat1!2
  QFX_d01!2 = "Time"
  PW_d01=QFX_d01

  QFX_d01@description="Average surface moisture flux"
  QFX_d01@units = "mm/day"
  PW_d01@description="Average precipitable water"
  PW_d01@units = "mm"  


n=0
year=1990
year2=2009
do while(year.le.year2)
m=1
do while(m.le.12)
  print(year)
  FILES1 = systemfunc (" ls -1 " + DATADir + "wrfout_d01_"+year+"-"+sprinti("%0.2i",m)+"-??_00:00:00")
  f1 = addfiles(FILES1+".nc","r")

  QFX_d01(:,:,n)=(/dim_avg_n_Wrap(wrf_user_getvar(f1,"QFX",-1)*24*60*60,0)/)
  PW_d01(:,:,n)=(/dim_avg_n_Wrap(wrf_user_getvar(f1,"pw",-1),0)/)
  
  delete([/f1,FILES1/])

n=n+1
m=m+1
end do
year=year+1
end do
 
  outfile=OUTDir+"WRF_d01_monthly_QFX_PW"
  system("/bin/rm -f "+outfile+".nc")
  out = addfile(outfile+".nc","c")
  out->QFX_d01=QFX_d01
  out->PW_d01=PW_d01
  out->lat=lat1
  out->lon=lon1
  delete(outfile)

;  outfile=OUTDir+"WRF_d02_QFX_"+type(t)
;  system("/bin/rm -f "+outfile+".nc")
;  out = addfile(outfile+".nc","c")
;  out->QFX_d02=QFX_d02
;  out->lat=lat2
;  out->lon=lon2

end