load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

ECLDIR="/srv/ccrc/data34/z3478332/ECLtracks/outputUM_"

;INDIRS=(/"/srv/ccrc/data45/z3478332/WRF/output/ERAI_R2_nonudging_notopo/out/impact/"/)
;INDIRS=(/"/srv/ccrc/data34/z3478332/WRF/ERA-nudge/"/)
INDIRS=(/"/srv/ccrc/data34/z3478332/WRF/output/ERAI_R2_nudging_notopo_19902009/out/impact/"/)


OUTDIRS=INDIRS

names=(/"ERA-nudge_notopo"/)
cat="p100_rad2cv1"
cat2="d01_rad2_p100_cv1.0"

fin=addfile("WRF_d01_ESB_mask.nc","r")
ESB_d01=fin->ESB
fin=addfile("/srv/ccrc/data13/z3393020/Analyses/share/geo_em_files/geo_em.d01.narclim.nc","r")
lat1 = rm_single_dims(wrf_user_getvar(fin,"XLAT_M",-1))
lon1 = rm_single_dims(wrf_user_getvar(fin,"XLONG_M",-1))

n=0
do while(n.lt.dimsizes(INDIRS))
  INDIR=INDIRS(n)
  print(INDIR)

; Get the ECL list
  filename = ECLDIR+names(n)+"/"+cat+"/d01/"+"ECLfixes_"+names(n)+"_"+cat2+".csv"
  read_data= asciiread(filename,-1,"string")
  header    = read_data(0)        ; Header. Use for variable names.
  data      = read_data(1:)       ; Get rid of first line which is a header.
  date = tointeger(str_get_field(data,4,","))
  lat = tofloat(str_get_field(data,8,","))  
  lon= tofloat(str_get_field(data,7,","))  
  tmp=stringtochar(str_get_field(data,5,","))
  time=tointeger(charactertostring(tmp(:,1:2)))
  
  delete([/filename,read_data/])

; Get the 6-hourly rainfall totals

  FILES1 = systemfunc (" ls -1 " + INDIR + "pr_????_d01_6hr_centred.nc")
  f1 = addfiles(FILES1,"r")
  FILES2 = systemfunc (" ls -1 " + INDIR + "uv_????_d01_6hr.nc")
  f2 = addfiles(FILES2,"r")
  ;rain = wrf_user_getvar(f1,"rain",-1)
  times=yyyymmddhh_time(1990,2009,6,"integer")
  dateW=times/100
  timeW=mod(times,100)

; Now, make the composites
  len=dimsizes(date)
  ECLrain=new((/len,21,21/),"float")
  ECLrain!0="Time"
  ECLrain!1="south_north"
  ECLrain!2="east_west"
  ECL_U10=ECLrain
  ECL_V10=ECLrain

  ECLrain@description="6-hour rain accummulation within 500km radius of low centre"
  ECL_U10@description="6-hour instantaneous 10m zonal wind within 500km radius of low centre"
  ECL_V10@description="6-hour instantaneous 10m meridional wind within 500km radius of low centre"

  I=getind_latlon2d(lat1,lon1,lat,lon)
  do ip=0,len-1
     J=ind(dateW.eq.date(ip).and.timeW.eq.time(ip))
     rain=wrf_user_getvar(f1,"rain",J)
     ECLrain(ip,:,:)=rain((I(ip,0)-10):(I(ip,0)+10),(I(ip,1)-10):(I(ip,1)+10))
     u=wrf_user_getvar(f2,"u10",J)
     ECL_U10(ip,:,:)=u((I(ip,0)-10):(I(ip,0)+10),(I(ip,1)-10):(I(ip,1)+10))
     v=wrf_user_getvar(f2,"v10",J)
     ECL_V10(ip,:,:)=v((I(ip,0)-10):(I(ip,0)+10),(I(ip,1)-10):(I(ip,1)+10))
  end do

ECL_WS10=(ECL_U10^2+ECL_V10^2)^0.5
print(max(ECL_WS10))
ECL_WS10!0="Time"
ECL_WS10!1="south_north"
ECL_WS10!2="east_west"
ECL_WS10@description="6-hour instantaneous 10m meridional wind within 500km radius of low centre"

; Finally, write me a netcdf file

fout=OUTDIRS(n)+"ECLrain_"+names(n)+"_"+cat2+"_centred.nc"
system("/bin/rm -f "+fout)
out = addfile(fout,"c")
out->ECLrain=ECLrain
delete([/fout,out/])

fout=OUTDIRS(n)+"ECLwind_"+names(n)+"_"+cat2+".nc"
system("/bin/rm -f "+fout)
out = addfile(fout,"c")
out->ECL_U10=ECL_U10
out->ECL_V10=ECL_V10
out->ECL_WS10=ECL_WS10

delete([/ECLrain,ECL_U10,ECL_V10,ECL_WS10,out,fout,J,I,len,ip/])
delete([/dateW,timeW,times,rain,u,v,FILES1,f1/])
delete([/data,date,time,lat,lon,tmp/])
n=n+1
end do
