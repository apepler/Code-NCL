load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

ECLDIR="/srv/ccrc/data34/z3478332/ECLtracks/outputUM_wrf_2007_all/typing/"

INDIRS=(/"/srv/ccrc/data36/z3478332/WRF/output/ERAI_R1_nudging_default_2007/out/","/srv/ccrc/data36/z3478332/WRF/output/ERAI_R2_nudging_default_2007/out/","/srv/ccrc/data36/z3478332/WRF/output/ERAI_R3_nudging_default_2007/out/","/srv/ccrc/data36/z3478332/WRF/output/ERAI_R1_nudging_default_2007_notopo/out/","/srv/ccrc/data36/z3478332/WRF/output/ERAI_R2_nudging_default_2007_notopo/out/","/srv/ccrc/data36/z3478332/WRF/output/ERAI_R3_nudging_default_2007_notopo/out/","/srv/ccrc/data37/z3478332/WRF/output/ERAI_R1_nudging_default_2007_BRAN/out/","/srv/ccrc/data37/z3478332/WRF/output/ERAI_R2_nudging_default_2007_BRAN/out/","/srv/ccrc/data37/z3478332/WRF/output/ERAI_R3_nudging_default_2007_BRAN/out/","/srv/ccrc/data37/z3478332/WRF/output/ERAI_R1_nudging_default_2007_BRAN_noeac/out/","/srv/ccrc/data37/z3478332/WRF/output/ERAI_R2_nudging_default_2007_BRAN_noeac/out/","/srv/ccrc/data37/z3478332/WRF/output/ERAI_R3_nudging_default_2007_BRAN_noeac/out/","/srv/ccrc/data45/z3478332/WRF/output/ERAI_R1_nudging_default_2007_BRAN_2eac/out/","/srv/ccrc/data36/z3478332/WRF/output/ERAI_R2_nudging_default_2007_BRAN_2eac/out/","/srv/ccrc/data45/z3478332/WRF/output/ERAI_R3_nudging_default_2007_BRAN_2eac/out/"/)

OUTDIRS=(/"/srv/ccrc/data36/z3478332/WRF/output/ERAI_R1_nudging_default_2007/out/","/srv/ccrc/data36/z3478332/WRF/output/ERAI_R2_nudging_default_2007/out/","/srv/ccrc/data36/z3478332/WRF/output/ERAI_R3_nudging_default_2007/out/","/srv/ccrc/data36/z3478332/WRF/output/ERAI_R1_nudging_default_2007_notopo/out/","/srv/ccrc/data36/z3478332/WRF/output/ERAI_R2_nudging_default_2007_notopo/out/","/srv/ccrc/data36/z3478332/WRF/output/ERAI_R3_nudging_default_2007_notopo/out/","/srv/ccrc/data37/z3478332/WRF/output/ERAI_R1_nudging_default_2007_BRAN/out/","/srv/ccrc/data37/z3478332/WRF/output/ERAI_R2_nudging_default_2007_BRAN/out/","/srv/ccrc/data37/z3478332/WRF/output/ERAI_R3_nudging_default_2007_BRAN/out/","/srv/ccrc/data37/z3478332/WRF/output/ERAI_R1_nudging_default_2007_BRAN_noeac/out/","/srv/ccrc/data37/z3478332/WRF/output/ERAI_R2_nudging_default_2007_BRAN_noeac/out/","/srv/ccrc/data37/z3478332/WRF/output/ERAI_R3_nudging_default_2007_BRAN_noeac/out/","/srv/ccrc/data45/z3478332/WRF/output/ERAI_R1_nudging_default_2007_BRAN_2eac/out/","/srv/ccrc/data45/z3478332/WRF/output/ERAI_R2_nudging_default_2007_BRAN_2eac/out/","/srv/ccrc/data45/z3478332/WRF/output/ERAI_R3_nudging_default_2007_BRAN_2eac/out/"/)

names=(/"R1","R2","R3","R1_notopo","R2_notopo","R3_notopo","R1_BRAN","R2_BRAN","R3_BRAN","R1_BRAN_noeac","R2_BRAN_noeac","R3_BRAN_noeac","R1_BRAN_2eac","R2_BRAN_2eac","R3_BRAN_2eac"/)
names2=(/"","","","","","","","","","","","","_v2","_v2","_v2"/)
names3=(/"","","","","","","","","","","","","2","2","2"/)

cat="rad2_p100"

fin=addfile("WRF_d01_ESB_mask.nc","r")
ESB_d01=fin->ESB
fin=addfile("/srv/ccrc/data13/z3393020/Analyses/share/geo_em_files/geo_em.d01.narclim.nc","r")
lat1 = rm_single_dims(wrf_user_getvar(fin,"XLAT_M",-1))
lon1 = rm_single_dims(wrf_user_getvar(fin,"XLONG_M",-1))
stats=(/"Mean rain","Max rain","Cells >= 5mm","Cells >= 25mm"/)
stats!0="Statistic"

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

n=0
do while(n.lt.dimsizes(INDIRS))
  INDIR=INDIRS(n)
  print(INDIR)

; Get the ECL list
  filename = ECLDIR+"ECLfixes_d01_0708_"+names(n)+"_"+cat+names2(n)+"_typing.csv"
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
  FILES1 = systemfunc (" ls -1 " + INDIR + "wrfhrly_d01_200?-??-??_00:00:00")
  f1 = addfiles(FILES1+".nc","r")
  times=wrf_user_getvar(f1,"times",-1)
  timelist=ispan(0,dimsizes(times)-1,6)
  delete([/FILES1,f1/])

  slp = new((/dimsizes(timelist),south_north,west_east/),"float")
  GH_P = new((/dimsizes(timelist),south_north,west_east/),"float")
  
  x1=0
  year=2007
  year2=2008
  do while(year.le.year2)
  print(year)

  i=1
  do while(i.le.12)

  FILES1 = systemfunc (" ls -1 " + INDIR + "wrfout_d01_"+year+"-"+sprinti("%0.2i",i)+"-??_00:00:00")
  f1 = addfiles(FILES1+".nc","r")
  times2=wrf_user_getvar(f1,"times",-1)
  timelist2=ispan(0,dimsizes(times2)-1,2)
  x2=x1+dimsizes(timelist2)
  ;print(year+"-"+sprinti("%0.2i",i)+": "+x1+"-"+x2)

  slp(x1:(x2-1),:,:) = wrf_user_getvar(f1,"slp",timelist2)    ; slp

  GH = wrf_user_getvar(f1,"geopt",-1)
  p = wrf_user_getvar(f1,"pressure",-1)
  GH_P(x1:(x2-1),:,:) = wrf_user_intrp3d(GH(timelist2,:,:,:),p(timelist2,:,:,:),"h",500.,0.,False)
;  pv = wrf_user_getvar(f1,"pvo",timelist)
  GH_P =smth9(smth9( smth9(GH_P,0.5,0.25,False),0.5,0.25,False),0.5,0.25,False)
  GH_P =smth9(smth9( smth9(GH_P,0.5,0.25,False),0.5,0.25,False),0.5,0.25,False)

  x1=x2
  delete([/FILES1,f1,times2,timelist2,GH,p/])
i=i+1
end do
year=year+1
end do

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

  tmp=stringtochar(times(timelist))
  dateW=tointeger(charactertostring(tmp(:,(/0,1,2,3,5,6,8,9/))))
  timeW=tointeger(charactertostring(tmp(:,11:12)))
; Now, make the composites
  len=dimsizes(date)
  ECL_slp=new((/len,21,21/),typeof(slp))
  ECL_gv=new((/len,21,21/),typeof(lap))
  
  I=getind_latlon2d(lat1,lon1,lat,lon)
  do ip=0,len-1
     J=ind(dateW.eq.date(ip).and.timeW.eq.time(ip))
     ECL_slp(ip,:,:)=slp(J,(I(ip,0)-10):(I(ip,0)+10),(I(ip,1)-10):(I(ip,1)+10))
     ECL_gv(ip,:,:)=lap(J,(I(ip,0)-10):(I(ip,0)+10),(I(ip,1)-10):(I(ip,1)+10))
  end do

; Finally, write me a netcdf file

fout=OUTDIRS(n)+"ECLslp_0708_"+cat+names2(n)+".nc"
ECL_slp!0="Time"
ECL_slp!1="south_north"
ECL_slp!2="east_west"
ECL_slp@description="6-hour slp within 500km radius of low centre"
ECL_gv!0="Time"
ECL_gv!1="south_north"
ECL_gv!2="east_west"
ECL_gv@description="6-hour 500hPa geostrophic vorticity within 500km radius of low centre"

system("/bin/rm -f "+fout)
out = addfile(fout,"c")
out->ECL_slp=ECL_slp
out->ECL_gv=ECL_gv

delete([/ECL_slp,ECL_gv,out,fout,J,I,len,ip/])
delete([/dateW,timeW,times/])
delete([/data,date,time,lat,lon,tmp/])
n=n+1
end do
