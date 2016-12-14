load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
;load "./WRFUserARW.ncl"

DATADIRS=(/"/srv/ccrc/data33/z3481416/CCRC-WRF3.6.0.5-SEB/ERA-Interim/R2_nudging/out/","/srv/ccrc/data45/z3478332/WRF/output/ERAI_R2_nonudging_notopo/out/","/srv/ccrc/data34/z3478332/WRF/output/ERAI_R2_nudging_notopo_19902009/out/"/)
OUTDIRS=(/"/srv/ccrc/data34/z3478332/WRF/ERA-nudge/","/srv/ccrc/data45/z3478332/WRF/output/ERAI_R2_nonudging_notopo/out/impact/","/srv/ccrc/data34/z3478332/WRF/output/ERAI_R2_nudging_notopo_19902009/out/impact/"/)


  DATADir="/srv/ccrc/data45/z3478332/WRF/output/ERAI_R2_nonudging_notopo/out/"
  OUTDir = "/srv/ccrc/data45/z3478332/WRF/output/ERAI_R2_nonudging_notopo/out/impact/"  

;DATADir="/srv/ccrc/data33/z3481416/CCRC-WRF3.6.0.5-SEB/ERA-Interim/R2_nudging/out/"
;OUTDir="/srv/ccrc/data34/z3478332/WRF/ERA-nudge/"

  fin=addfile("/srv/ccrc/data13/z3393020/Analyses/share/geo_em_files/geo_em.d01.narclim.nc","r")
  lat1=wrf_user_getvar(fin,"XLAT_M",-1)
  lon1=wrf_user_getvar(fin,"XLONG_M",-1)

  MSFU=rm_single_dims(fin->MAPFAC_U)
  MSFV=rm_single_dims(fin->MAPFAC_V)
  MSFM=rm_single_dims(fin->MAPFAC_M)
  COR=rm_single_dims(fin->F)
  DX=fin@DX
  DY=fin@DY

  delete(fin)

dd=0
do while (dd.lt.dimsizes(DATADIRS))

DATADir=DATADIRS(dd)
OUTDir=OUTDIRS(dd)
print(DATADir)

  a=dimsizes(lat1)
  Theta_d01 = new((/a(1),a(2),240,4/),"float")
  Theta_d01!0 = lat1!1
  Theta_d01!1 = lat1!2
  Theta_d01!2 = "Month"
  Theta_d01!3 = "Operation"
;  Theta_d01&Operation=(/"Mean","Variance","P10","P90"/)


  SLP_d01=Theta_d01
  SLP_d01@description="Average mean sea level pressure"
  SLP_d01@units = "hPa"

  Z_d01=Theta_d01
  Z_d01@description="Average 850 hPa geopotential height"
  Z_d01@units = "m"

  SH_d01=Theta_d01
  SH_d01@description="Specific humidity at 850 hPa" 
  SH_d01@units="Kg/kg"

  PVO_d01=Theta_d01
  PVO_d01@description="Potential vorticity at 850 hPa"
  PVO_d01@units="s-1"

  AVO_d01=Theta_d01
  AVO_d01@description="Absolute vorticity at 850 hPa"
  AVO_d01@units="s-1"

;  EGR_d01=Theta_d01
;  EGR_d01@description="Eady growth rate at 850 hPa"
;  EGR_d01@units=""

  Theta_d01@description="Potential temperature at 850hPa"
  Theta_d01@units="K"

n=0
year=1990
year2=2009
do while(year.le.year2)
  print(year)
m=1
do while(m.le.12)
  FILES1 = systemfunc (" ls -1 " + DATADir + "wrfout_d01_"+year+"-"+sprinti("%0.2i",m)+"-??_00:00:00")

  f1 = addfiles(FILES1+".nc","r")
  slp = wrf_user_getvar(f1,"slp",-1)
  p = wrf_user_getvar(f1,"pressure",-1)

  mr = wrf_user_getvar(f1,"QVAPOR",-1) ; Mixing ratio
  q = wrf_user_intrp3d(mr/(1+mr),p,"h",850.0,0.,False)  
  th = wrf_user_getvar(f1,"th",-1)  ; Potential temperature
  th2 = wrf_user_intrp3d(th,p,"h",850.0,0.,False)  ; Potential temperature
  u=wrf_user_getvar(f1,"U",-1)
  v=wrf_user_getvar(f1,"V",-1)
  z = wrf_user_intrp3d(wrf_user_getvar(f1,"z",-1),p,"h",850.0,0.,False) 
  avo = wrf_user_intrp3d(wrf_avo( u, v, MSFU, MSFV, MSFM, COR, DX, DY, 0),p,"h",850.0,0.,False)  ; Absolute vorticity
  pvo = wrf_user_intrp3d(wrf_pvo( u, v, th, p*100, MSFU, MSFV, MSFM, COR, DX, DY, 0),p,"h",850.0,0.,False)  ; Potential vorticity

; Mean
  Theta_d01(:,:,n,0)=(/dim_avg_n_Wrap(th2,0)/)
  SH_d01(:,:,n,0)=(/dim_avg_n_Wrap(q,0)/)
  AVO_d01(:,:,n,0)=(/dim_avg_n_Wrap(avo,0)/)
  PVO_d01(:,:,n,0)=(/dim_avg_n_Wrap(pvo,0)/)
  SLP_d01(:,:,n,0)=(/dim_avg_n_Wrap(slp,0)/)
  Z_d01(:,:,n,0)=(/dim_avg_n_Wrap(z,0)/) 

; Var
  Theta_d01(:,:,n,1)=(/dim_variance_n_Wrap(th2,0)/)
  SH_d01(:,:,n,1)=(/dim_variance_n_Wrap(q,0)/)
  AVO_d01(:,:,n,1)=(/dim_variance_n_Wrap(avo,0)/)
  PVO_d01(:,:,n,1)=(/dim_variance_n_Wrap(pvo,0)/)
  SLP_d01(:,:,n,1)=(/dim_variance_n_Wrap(slp,0)/)
  Z_d01(:,:,n,1)=(/dim_variance_n_Wrap(z,0)/) 

; Percentiles?
N = dimsizes(th2)
nLow = N(0)/10 -1 ; the -1 is because NCL is zero based
nUp = 9*N(0)/10-1

ip = dim_pqsort_n(th2, 2, 0)
Theta_d01(:,:,n,2)=th2(nLow,:,:)
Theta_d01(:,:,n,3)=th2(nUp,:,:)

ip = dim_pqsort_n(q, 2, 0)
SH_d01(:,:,n,2)=q(nLow,:,:)
SH_d01(:,:,n,3)=q(nUp,:,:)

ip = dim_pqsort_n(avo, 2, 0)
AVO_d01(:,:,n,2)=avo(nLow,:,:)
AVO_d01(:,:,n,3)=avo(nUp,:,:)

ip = dim_pqsort_n(pvo, 2, 0)
PVO_d01(:,:,n,2)=pvo(nLow,:,:)
PVO_d01(:,:,n,3)=pvo(nUp,:,:)

ip = dim_pqsort_n(slp, 2, 0)
SLP_d01(:,:,n,2)=slp(nLow,:,:)
SLP_d01(:,:,n,3)=slp(nUp,:,:)

ip = dim_pqsort_n(z, 2, 0)
Z_d01(:,:,n,2)=z(nLow,:,:)
Z_d01(:,:,n,3)=z(nUp,:,:)


delete([/FILES1,f1,u,v,p,mr,q,th,th2,avo,pvo,slp,z,ip,N,nLow,nUp/])

n=n+1
m=m+1
end do
year=year+1
end do

  outfile=OUTDir+"WRF_d01_monthly_850hPa_variability"
  system("/bin/rm -f "+outfile+".nc")
  out = addfile(outfile+".nc","c")
  out->Theta_d01=Theta_d01
  out->SH_d01=SH_d01  
  out->AVO_d01=AVO_d01
  out->PVO_d01=PVO_d01
  out->Z_d01=Z_d01
  out->SLP_d01=SLP_d01
delete([/out,outfile,DATADir,OUTDir/])
delete([/Theta_d01,SH_d01,AVO_d01,PVO_d01,Z_d01,SLP_d01/])
dd=dd+1
end do

