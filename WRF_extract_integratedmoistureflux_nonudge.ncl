load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
;load "./WRFUserARW.ncl"

  ;DATADir="/srv/ccrc/data45/z3478332/WRF/output/ERAI_R2_nonudging_notopo/out/"
  ;OUTDir = "/srv/ccrc/data45/z3478332/WRF/output/ERAI_R2_nonudging_notopo/out/impact/"  

DATADir="/srv/ccrc/data33/z3481416/CCRC-WRF3.6.0.5-SEB/ERA-Interim/R2_nudging/out/"
OUTDir="/srv/ccrc/data34/z3478332/WRF/ERA-nudge/"

;DATADir="/srv/ccrc/data34/z3478332/WRF/output/ERAI_R2_nudging_notopo_19902009/out/"
;OUTDir="/srv/ccrc/data34/z3478332/WRF/output/ERAI_R2_nudging_notopo_19902009/out/impact/"

  fin=addfile("/srv/ccrc/data13/z3393020/Analyses/share/geo_em_files/geo_em.d01.narclim.nc","r")
  lat1=wrf_user_getvar(fin,"XLAT_M",-1)
  lon1=wrf_user_getvar(fin,"XLONG_M",-1)
  delete(fin)
  a=dimsizes(lat1)
  Umoist_d01 = new((/a(1),a(2),240/),"float")
  Umoist_d01!0 = lat1!1
  Umoist_d01!1 = lat1!2
  Umoist_d01!2 = "Time"
  Umoist_d01@units = "Kg m-2 s-1"
  
  Vmoist_d01=Umoist_d01
  Umoist_d01@description="Average vertically-integrated moisture flux"
  Vmoist_d01@description="Average vertically-integrated moisture flux"

  ptop=500.
  pbot=1000.

n=0
year=1990
year2=2009
do while(year.le.year2)
m=1
do while(m.le.12)
  print(year)
  FILES1 = systemfunc (" ls -1 " + DATADir + "wrfout_d01_"+year+"-"+sprinti("%0.2i",m)+"-??_00:00:00")
  f1 = addfiles(FILES1+".nc","r")
  uv = wrf_user_getvar(f1,"uvmet",-1)    ; slp
  p = wrf_user_getvar(f1,"pressure",-1)
  psfc= p(:,0,:,:)
  mr = wrf_user_getvar(f1,"QVAPOR",-1) ; Mixing ratio
  q = mr/(1+mr)

  uq=uv(0,:,:,:,:)*q
  vq=uv(1,:,:,:,:)*q

  copy_VarMeta(p,uq)
  copy_VarMeta(p,vq)
 
  uqint = vibeta (p(Time|:,south_north|:,west_east|:,bottom_top|:), \
                  uq(Time|:,south_north|:,west_east|:,bottom_top|:), 1, psfc, pbot,ptop) 

  vqint = vibeta (p(Time|:,south_north|:,west_east|:,bottom_top|:), \
                  vq(Time|:,south_north|:,west_east|:,bottom_top|:), 1, psfc, pbot,ptop) 

  Umoist_d01(:,:,n)=(/dim_avg_n_Wrap(uqint,0)/)
  Vmoist_d01(:,:,n)=(/dim_avg_n_Wrap(vqint,0)/)

delete([/FILES1,f1,uv,p,psfc,mr,q,uq,vq,uqint,vqint/])

n=n+1
m=m+1
end do
year=year+1
end do
 
  outfile=OUTDir+"WRF_d01_monthly_moistflux"
  system("/bin/rm -f "+outfile+".nc")
  out = addfile(outfile+".nc","c")
  out->Umoist_d01=Umoist_d01
  out->Vmoist_d01=Vmoist_d01

