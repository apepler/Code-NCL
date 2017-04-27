load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

ECLDIR="/srv/ccrc/data34/z3478332/ECLtracks/outputUM_"

;INDIRS=(/"/srv/ccrc/data45/z3478332/WRF/output/ERAI_R2_nonudging_notopo/out/impact/"/)
;INDIRS=(/"/srv/ccrc/data34/z3478332/WRF/ERA-nudge/"/)
INDIRS=(/"/srv/ccrc/data45/z3478332/WRF/output/ERAI_R2_nonudging_notopo/out/"/)
OUTDIRS=(/"/srv/ccrc/data45/z3478332/WRF/output/ERAI_R2_nonudging_notopo/out/impact/"/)

names=(/"ERA-nonudge_notopo"/)
cat="p100_rad2cv1"
cat2="rad2_p100_cv1.0"
dom="d01"
levs=(/1000,925,850,500/)

fin=addfile("/srv/ccrc/data13/z3393020/Analyses/share/geo_em_files/geo_em.d01.narclim.nc","r")
lat1 = rm_single_dims(wrf_user_getvar(fin,"XLAT_M",-1))
lon1 = rm_single_dims(wrf_user_getvar(fin,"XLONG_M",-1))

  MSFU=rm_single_dims(fin->MAPFAC_U)
  MSFV=rm_single_dims(fin->MAPFAC_V)
  MSFM=rm_single_dims(fin->MAPFAC_M)
  COR=rm_single_dims(fin->F)
  DX=fin@DX
  DY=fin@DY

n=0
do while(n.lt.dimsizes(INDIRS))
  INDIR=INDIRS(n)
  print(INDIR)

; Get the ECL list
  filename = ECLDIR+names(n)+"/"+cat+"/"+dom+"/"+"ECLfixes_"+names(n)+"_"+dom+"_"+cat2+"_typing_impactsC2.csv"
  read_data= asciiread(filename,-1,"string")
  header    = read_data(0)        ; Header. Use for variable names.
  data      = read_data(1:)       ; Get rid of first line which is a header.
  loc = tointeger(str_get_field(data,11,","))

  I=ind(loc.eq.1)
  date = tointeger(str_get_field(data(I),4,","))
  lat = tofloat(str_get_field(data(I),8,","))  
  lon= tofloat(str_get_field(data(I),7,","))  
  tmp=stringtochar(str_get_field(data(I),5,","))
  time=tointeger(charactertostring(tmp(:,1:2)))/3
  len=dimsizes(date)  
  year=floor(date/10000.)
  month=tointeger(mod(floor(date/100.),100))
  day=mod(date,100)

  delete([/filename,read_data,I,header,data,tmp,loc/])

  a=dimsizes(lat1)
  Theta_d01 = new((/a(0),a(1),dimsizes(levs),dimsizes(date)/),"float")
  Theta_d01!0 = "south_north"
  Theta_d01!1 = "west_east"
  Theta_d01!2 = "Level"
  Theta_d01&Level = levs
  Theta_d01!3 = "Fix"

  SH_d01=Theta_d01
  SH_d01@description="Specific humidity" 
  SH_d01@units="Kg/kg"

  PVO_d01=Theta_d01
  PVO_d01@description="Potential vorticity"
  PVO_d01@units="s-1"

  AVO_d01=Theta_d01
  AVO_d01@description="Absolute vorticity"
  AVO_d01@units="s-1"

  Theta_d01@description="Potential temperature"
  Theta_d01@units="K"

  LH_d01 = new((/a(0),a(1),dimsizes(date)/),"float")
  LH_d01!0 = "south_north"
  LH_d01!1 = "west_east"
  LH_d01!2 = "Fix"

  T2_d01=LH_d01
  T2_d01@description="2m temperature"
  T2_d01@units="K"
  SLP_d01=LH_d01
  SLP_d01@description="SLP"
  SLP_d01@units="hPa"
  LH_d01@description="Surface latent heat flux"
  LH_d01@units = "W m-2"

  do ip=0,dimsizes(date)-1
      if(mod(ip,100).eq.0)
         print(date(ip))
      end if
  f1 = addfile(INDIRS(n) + "wrfout_d01_"+year(ip)+"-"+sprinti("%0.2i",month(ip))+"-"+sprinti("%0.2i",day(ip))+"_00:00:00","r")
     
  p = wrf_user_getvar(f1,"pressure",time(ip))
  mr = wrf_user_getvar(f1,"QVAPOR",time(ip)) ; Mixing ratio
  q = mr/(1+mr)                        ; Specific humidity
  copy_VarMeta(mr,q)
  th = wrf_user_getvar(f1,"th",time(ip)) ; Potential temperature
  u=wrf_user_getvar(f1,"U",time(ip))
  v=wrf_user_getvar(f1,"V",time(ip))
  SLP_d01(:,:,ip)=wrf_user_getvar(f1,"slp",time(ip))

  avo = wrf_avo( u, v, MSFU, MSFV, MSFM, COR, DX, DY, 0) ; Absolute vorticity
  pvo = wrf_pvo( u, v, th, p*100, MSFU, MSFV, MSFM, COR, DX, DY, 0) ; Potential vorticity

  do ll=0,dimsizes(levs)-1
    Theta_d01(:,:,ll,ip)=wrf_user_intrp3d(th,p,"h",levs(ll),0.,False)
    SH_d01(:,:,ll,ip)=wrf_user_intrp3d(q,p,"h",levs(ll),0.,False)
    AVO_d01(:,:,ll,ip)=wrf_user_intrp3d(avo,p,"h",levs(ll),0.,False)
    PVO_d01(:,:,ll,ip)=wrf_user_intrp3d(pvo,p,"h",levs(ll),0.,False)
  end do
 
  delete([/f1,u,v,th,q,mr,avo,pvo,p/])
  FILES1 = addfile(INDIRS(n) + "wrfhrly_d01_"+year(ip)+"-"+sprinti("%0.2i",month(ip))+"-01_00:00:00","r")
  xx=(day(ip)-1)*24+time(ip)*3
  LH_d01(:,:,ip)=wrf_user_getvar(FILES1,"LH",xx)
  T2_d01(:,:,ip)=wrf_user_getvar(FILES1,"T2",xx)
  delete([/FILES1,xx/])

  end do
; Finally, write me a netcdf file

fout=OUTDIRS(n)+"ECLcomposites_"+names(n)+"_"+dom+"_"+cat2+"_surface.nc"
system("/bin/rm -f "+fout)
out = addfile(fout,"c")
out->SLP_d01=SLP_d01
out->T2_d01=T2_d01
out->LH_d01=LH_d01
delete([/out,fout/])

fout=OUTDIRS(n)+"ECLcomposites_"+names(n)+"_"+dom+"_"+cat2+"_temphumid.nc"
system("/bin/rm -f "+fout)
out = addfile(fout,"c")
out->Theta_d01=Theta_d01
out->SH_d01=SH_d01  
delete([/out,fout/])

fout=OUTDIRS(n)+"ECLcomposites_"+names(n)+"_"+dom+"_"+cat2+"_vort.nc"
system("/bin/rm -f "+fout)
out = addfile(fout,"c")
out->AVO_d01=AVO_d01
out->PVO_d01=PVO_d01
out->LH_d01=LH_d01
delete([/fout,out,SLP_d01,T2_d01,LH_d01,Theta_d01,SH_d01,AVO_d01,PVO_d01/])
delete([/dateW,timeW,times,FILES1,f1/])
delete([/date,time,lat,lon,year,month,day/])
n=n+1
end do
