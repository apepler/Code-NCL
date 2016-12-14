load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
;load "./WRFUserARW.ncl"

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
  print("Beginning")

  a=dimsizes(lat1)
  Theta_d01 = new((/a(1),a(2),240/),"float")
  Theta_d01!0 = lat1!1
  Theta_d01!1 = lat1!2
  Theta_d01!2 = "Month"

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
  p = wrf_user_getvar(f1,"pressure",-1)
  mr = wrf_user_getvar(f1,"QVAPOR",-1) ; Mixing ratio
  q = mr/(1+mr)                        ; Specific humidity
  copy_VarMeta(mr,q)
  th = wrf_user_getvar(f1,"th",-1) ; Potential temperature
  u=wrf_user_getvar(f1,"U",-1)
  v=wrf_user_getvar(f1,"V",-1)

  avo = wrf_avo( u, v, MSFU, MSFV, MSFM, COR, DX, DY, 0) ; Absolute vorticity
  pvo = wrf_pvo( u, v, th, p*100, MSFU, MSFV, MSFM, COR, DX, DY, 0) ; Potential vorticity

;  z = wrf_user_getvar(f1,"pvo",-1) ; Height
;  eady=eady_growth_rate(th, uv(0,:,:,:,:), z, lat, 0,  1)

  Theta_d01(:,:,n)=(/dim_avg_n_Wrap(wrf_user_intrp3d(th,p,"h",850.0,0.,False),0)/)
  SH_d01(:,:,n)=(/dim_avg_n_Wrap(wrf_user_intrp3d(q,p,"h",850.0,0.,False),0)/)
  AVO_d01(:,:,n)=(/dim_avg_n_Wrap(wrf_user_intrp3d(avo,p,"h",850.0,0.,False),0)/)
  PVO_d01(:,:,n)=(/dim_avg_n_Wrap(wrf_user_intrp3d(pvo,p,"h",850.0,0.,False),0)/)
;  EGR_d01(:,:,n)=(/dim_avg_n_Wrap(wrf_user_intrp3d(eady,p,"h",850.0,0.,False),0)/)

delete([/FILES1,f1,u,v,p,mr,q,th,avo,pvo/])

n=n+1
m=m+1
end do
year=year+1
end do

 
  outfile=OUTDir+"WRF_d01_monthly_850hPa_vars"
  system("/bin/rm -f "+outfile+".nc")
  out = addfile(outfile+".nc","c")
  out->Theta_d01=Theta_d01
  out->SH_d01=SH_d01  
  out->AVO_d01=AVO_d01
  out->PVO_d01=PVO_d01
;  out->EGR_d01=EGR_d01

