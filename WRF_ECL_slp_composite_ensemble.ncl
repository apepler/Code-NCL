load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

ECLDIR="/srv/ccrc/data34/z3478332/ECLtracks/outputUM_wrf_2007-06/"
;BDIR="/srv/ccrc/data37/z3478332/WRF/output/"

;names=(/"ERAI_R1_ensemble_BRAN","ERAI_R2_ensemble_BRAN","ERAI_R3_ensemble_BRAN","ERAI_R1_ensemble_BRAN_noeac","ERAI_R2_ensemble_BRAN_noeac","ERAI_R3_ensemble_BRAN_noeac","ERAI_R1_ensemble_BRAN_2eac","ERAI_R2_ensemble_BRAN_2eac","ERAI_R3_ensemble_BRAN_2eac"/)
BDIR="/srv/ccrc/data36/z3478332/WRF/output/"
names=(/"ERAI_R1_ensemble","ERAI_R2_ensemble","ERAI_R3_ensemble","ERAI_R1_ensemble_notopo","ERAI_R2_ensemble_notopo","ERAI_R3_ensemble_notopo"/)

cat="d01_p100_rad2cv05"

fin=addfile("/srv/ccrc/data13/z3393020/Analyses/share/geo_em_files/geo_em.d01.narclim.nc","r")
lat1 = rm_single_dims(wrf_user_getvar(fin,"XLAT_M",-1))
lon1 = rm_single_dims(wrf_user_getvar(fin,"XLONG_M",-1))

; Fei's GV calculations
G = 9.8005  ; m/s2, grivity at 45 deg lat used by the WMO
W = 7.292e-5 ; 1/s, earth ang rotation
rad = 4.*atan(1.)/180.
f0 = 2. * W * sin(lat1*rad) ; coriolis parameter
dlon = 48918.09 ; WRF grid space for NARCliM domain
dlonsq = dlon*dlon
dlat = 48918.09
dlatsq = dlat*dlat
south_north = 144 
west_east = 215
num_metgrid_levels = 38
scale = -1.e+05     

hour=(/"00","06","12","18"/)
n=3
do while(n.lt.dimsizes(names))
day=27
do while(day.le.31)
h=0
do while(h.le.3)

INDIR = BDIR+names(n)+"/out/200705"+day+hour(h)+"/"
  print(INDIR)

; Get the ECL list
  filename = ECLDIR+names(n)+"/"+cat+"/ECLfixes_200705"+day+hour(h)+"_typing.csv"
  read_data= asciiread(filename,-1,"string")
  header    = read_data(0)        ; Header. Use for variable names.
  data      = read_data(1:)       ; Get rid of first line which is a header.
  date = tointeger(str_get_field(data,4,","))
  lat = tofloat(str_get_field(data,8,","))  
  lon= tofloat(str_get_field(data,7,","))  
  tmp=stringtochar(str_get_field(data,5,","))
  time=tointeger(charactertostring(tmp(:,1:2)))
  
  delete([/filename,read_data,tmp/])

; Get the 6-hourly rainfall totals
  FILES1 = systemfunc (" ls -1 " + INDIR + "wrfout_d01_2007-06-??_00:00:00")
  f1 = addfiles(FILES1+".nc","r")
  times=wrf_user_getvar(f1,"times",-1)
  timelist=ispan(0,dimsizes(times)-1,2)

  slp= wrf_user_getvar(f1,"slp",timelist)    ; slp

  GH = wrf_user_getvar(f1,"geopt",-1)
  p = wrf_user_getvar(f1,"pressure",-1)
  GH_P = wrf_user_intrp3d(GH(timelist,:,:,:),p(timelist,:,:,:),"h",500.,0.,False)
;  pv = wrf_user_getvar(f1,"pvo",timelist)
  GH_P =smth9(smth9( smth9(GH_P,0.5,0.25,False),0.5,0.25,False),0.5,0.25,False)
  GH_P =smth9(smth9( smth9(GH_P,0.5,0.25,False),0.5,0.25,False),0.5,0.25,False)
  delete([/FILES1,f1/])


wrf_smooth_2d(slp,3)
wrf_smooth_2d(GH_P,3)

lap_lon = new((/dimsizes(timelist),south_north,west_east/),"float")
lap_lat = new((/dimsizes(timelist),south_north,west_east/),"float")

do it =1,west_east-2 
lap_lon(:,:,it) = GH_P(:,:,it+1)+GH_P(:,:,it-1)-2.0*GH_P(:,:,it)
end do
;Edges
lap_lon(:,:,0) = lap_lon(:,:,1)
lap_lon(:,:,west_east-1) = lap_lon(:,:,west_east-2)
; divided by spacing and ff
lap_lon = lap_lon/dlonsq/conform_dims(dimsizes(lap_lat),f0,(/1,2/))

; Laplacian along south-north direction
do nt = 1,south_north-2
lap_lat(:,nt,:) = GH_P(:,nt+1,:)+GH_P(:,nt-1,:) -2.0*GH_P(:,nt,:)
end do
;Edges
lap_lat(:,0,:) = lap_lat(:,1,:)
lap_lat(:,south_north-1,:) = lap_lat(:,south_north-2,:)
; divided by spacing an ff
lap_lat = lap_lat/dlatsq/conform_dims(dimsizes(lap_lat),f0,(/1,2/))

; total laplacian by sum up lon/lat components
lap = lap_lon + lap_lat
lap = lap*scale ; vorticity is negative for low in south hemisphere

  FILES1 = systemfunc (" ls -1 " + INDIR + "wrfhrly_d01_2007-06-??_00:00:00")
  f1 = addfiles(FILES1+".nc","r")
  times2=wrf_user_getvar(f1,"times",-1)
  numDAYS = dimsizes(times2)/6
  var_in1=wrf_user_getvar(f1,"PREC_ACC_NC",-1)+wrf_user_getvar(f1,"PREC_ACC_C",-1)
  a=ispan(0,dimsizes(times2)-1,6) 
  u10 = wrf_user_getvar(f1,"U10",a)    ; uv
  v10 = wrf_user_getvar(f1,"V10",a)

  rain=new((/numDAYS+1,144,215/),typeof(var_in1))
  rain(0,:,:) = dim_sum_n_Wrap(var_in1(0:2,:,:),0)
  do ip = 1,numDAYS-1      
    rain(ip,:,:) = dim_sum_n_Wrap(var_in1((ip*6-3):(ip*6+2),:,:),0)
  end do
  rain(numDAYS,:,:) = dim_sum_n_Wrap(var_in1((numDAYS*6-3):(numDAYS*6-1),:,:),0)

  tmp=stringtochar(times(timelist))
  dateW=tointeger(charactertostring(tmp(:,(/0,1,2,3,5,6,8,9/))))
  timeW=tointeger(charactertostring(tmp(:,11:12)))
; Now, make the composites
  len=dimsizes(date)
  ECL_slp=new((/len,21,21/),typeof(slp))
  ECL_gv=new((/len,21,21/),typeof(lap))
  ECL_rain=new((/len,21,21/),typeof(var_in1))
  ECL_U10=new((/len,21,21/),typeof(u10))
  ECL_V10=new((/len,21,21/),typeof(v10))
  
  I=getind_latlon2d(lat1,lon1,lat,lon)
  do ip=0,len-1
     J=ind(dateW.eq.date(ip).and.timeW.eq.time(ip))
     ECL_slp(ip,:,:)=slp(J,(I(ip,0)-10):(I(ip,0)+10),(I(ip,1)-10):(I(ip,1)+10))
     ECL_gv(ip,:,:)=lap(J,(I(ip,0)-10):(I(ip,0)+10),(I(ip,1)-10):(I(ip,1)+10))
     ECL_rain(ip,:,:)=rain(J,(I(ip,0)-10):(I(ip,0)+10),(I(ip,1)-10):(I(ip,1)+10))
     ECL_U10(ip,:,:)=u10(J,(I(ip,0)-10):(I(ip,0)+10),(I(ip,1)-10):(I(ip,1)+10))
     ECL_V10(ip,:,:)=v10(J,(I(ip,0)-10):(I(ip,0)+10),(I(ip,1)-10):(I(ip,1)+10))
  end do

; Finally, write me a netcdf file

fout=INDIR+"ECL_composite_"+cat+".nc"
ECL_slp!0="Time"
ECL_slp!1="south_north"
ECL_slp!2="east_west"
ECL_slp@description="6-hour slp within 500km radius of low centre"
ECL_gv!0="Time"
ECL_gv!1="south_north"
ECL_gv!2="east_west"
ECL_gv@description="6-hour 500hPa geostrophic vorticity within 500km radius of low centre"
ECL_rain!0="Time"
ECL_rain!1="south_north"
ECL_rain!2="east_west"
ECL_rain@description="6-hour rain accummulation within 500km radius of low centre"
ECL_U10!0="Time"
ECL_U10!1="south_north"
ECL_U10!2="east_west"
ECL_U10@description="6-hour instantaneous 10m zonal wind within 500km radius of low centre"
ECL_V10!0="Time"
ECL_V10!1="south_north"
ECL_V10!2="east_west"
ECL_V10@description="6-hour instantaneous 10m meridional wind within 500km radius of low centre"
ECL_WS10=(ECL_U10^2+ECL_V10^2)^0.5
ECL_WS10!0="Time"
ECL_WS10!1="south_north"
ECL_WS10!2="east_west"
ECL_WS10@description="6-hour instantaneous 10m meridional wind within 500km radius of low centre"

system("/bin/rm -f "+fout)
out = addfile(fout,"c")
out->ECL_slp=ECL_slp
out->ECL_gv=ECL_gv
out->ECL_rain=ECL_rain
out->ECL_U10=ECL_U10
out->ECL_V10=ECL_V10
out->ECL_WS10=ECL_WS10

delete([/ECL_slp,ECL_gv,ECL_rain,ECL_U10,ECL_V10,ECL_WS10/])
delete([/out,fout,J,I,len,ip,GH,p,u10,v10,var_in1,rain/])
delete([/dateW,timeW,times,times2,numDAYS/])
delete([/data,date,time,lat,lon,tmp,FILES1,f1/])

h=h+1
end do
day=day+1
end do
n=n+1
end do
