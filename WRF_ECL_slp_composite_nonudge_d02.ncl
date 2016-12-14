load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

ECLDIR="/srv/ccrc/data34/z3478332/ECLtracks/outputUM_"

;INDIRS=(/"/srv/ccrc/data34/z3478332/WRF/ERA-nudge/","/srv/ccrc/data45/z3478332/WRF/output/ERAI_R2_nonudging_notopo/out/","/srv/ccrc/data34/z3478332/WRF/output/ERAI_R2_nudging_notopo_19902009/out/"/)

;OUTDIRS=(/"/srv/ccrc/data34/z3478332/WRF/ERA-nudge/","/srv/ccrc/data45/z3478332/WRF/output/ERAI_R2_nonudging_notopo/out/impact/","/srv/ccrc/data34/z3478332/WRF/output/ERAI_R2_nudging_notopo_19902009/out/impact/"/)

INDIRS=(/"/srv/ccrc/data33/z3481416/CCRC-WRF3.6.0.5-SEB/ERA-Interim/R2_nudging/out/","/srv/ccrc/data45/z3478332/WRF/output/ERAI_R2_nonudging_notopo/out/"/)
OUTDIRS=(/"/srv/ccrc/data34/z3478332/WRF/ERA-nudge/","/srv/ccrc/data45/z3478332/WRF/output/ERAI_R2_nonudging_notopo/out/impact/"/)

names=(/"ERA-nudge","ERA-nonudge_notopo","ERA-nudge_notopo"/)
cat=(/"p100_rad2cv1_2","p100_rad2cv1","p100_rad2cv1"/)
cat2="d02_rad2_p100_cv1.0"

fin=addfile("/srv/ccrc/data13/z3393020/Analyses/share/geo_em_files/geo_em.d02.narclim.nc","r")
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
south_north = 200 
west_east = 325
num_metgrid_levels = 38
scale = -1.e+05     

n=1
do while(n.lt.dimsizes(INDIRS))
  INDIR=INDIRS(n)
  print(INDIR)

; Get the ECL list
  filename = ECLDIR+names(n)+"/"+cat(n)+"/d02/"+"ECLfixes_"+names(n)+"_"+cat2+".csv"
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
  FILES1 = systemfunc (" ls -1 " + INDIR + "wrfhrly_d02_????-??-??_00:00:00")
  f1 = addfiles(FILES1+".nc","r")
  times=wrf_user_getvar(f1,"times",-1)
  timelist=ispan(0,dimsizes(times)-1,6)
  delete([/FILES1,f1/])

  slp = new((/dimsizes(timelist),south_north,west_east/),"float")
  GH_P = new((/dimsizes(timelist),south_north,west_east/),"float")
  
  x1=0
  year=1990
  year2=2009
  do while(year.le.year2)
  print(year)

  i=1
  do while(i.le.12)

  FILES1 = systemfunc (" ls -1 " + INDIR + "wrfout_d02_"+year+"-"+sprinti("%0.2i",i)+"-??_00:00:00")
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
  ECL_slp=new((/len,101,101/),typeof(slp))
  ECL_gv=new((/len,101,101/),typeof(lap))
  
  I=getind_latlon2d(lat1,lon1,lat,lon)

  do ip=0,len-1
     J=ind(dateW.eq.date(ip).and.timeW.eq.time(ip))

; removing the edges where things are weird
  if(I(ip,0).gt.0.and.I(ip,0).lt.199.and.I(ip,1).gt.0.and.I(ip,1).lt.324.) then
     if(I(ip,0).lt.50) then
        seq1a=ispan(0,I(ip,0)+50,1) ; Section of matrix, hard end at 0
        seq1b=ispan(50-I(ip,0),100,1) ; Section of result - first squares are blank
     else if(I(ip,0).ge.150) then
        seq1a=ispan(I(ip,0)-50,199,1) ; Section of matrix, hard end at 199
        seq1b=ispan(0,249-I(ip,0),1) ; section of result - last squares are blank.
     else
        seq1a=ispan(I(ip,0)-50,I(ip,0)+50,1) 
        seq1b=ispan(0,100,1) 
     end if
     end if

     if(I(ip,1).lt.50) then
        seq2a=ispan(0,I(ip,1)+50,1) ; Section of matrix, hard end at 0
        seq2b=ispan(50-I(ip,1),100,1) ; Section of result - first squares are blank
     else if(I(ip,1).ge.275) then
        seq2a=ispan(I(ip,1)-50,324,1) ; Section of matrix, hard end at 324
        seq2b=ispan(0,374-I(ip,1),1) ; section of result - last squares are blank.
     else
        seq2a=ispan(I(ip,1)-50,I(ip,1)+50,1) 
        seq2b=ispan(0,100,1) 
     end if
     end if

     ECL_slp(ip,seq1b,seq2b)=slp(J,seq1a,seq2a)
     ECL_gv(ip,seq1b,seq2b)=lap(J,seq1a,seq2a)
     delete([/seq1a,seq2a,seq1b,seq2b/])
  end if
  end do


; Finally, write me a netcdf file

fout=OUTDIRS(n)+"ECLslp_d02_"+names(n)+"_"+cat2+".nc"
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
