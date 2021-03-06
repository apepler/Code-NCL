load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

wrfv=(/"R1","R2","R3"/)
;cmip=(/"ECHAM5","MIROC3.2","CCCMA3.1","CSIROMk3.0"/)
;cmip2=(/"echam5","miroc","cccma","csiromk3"/)
;runyears=(/"2060-2080","2060-2080","2060-2080","2060-2080","2060-2080"/)
;ystart=ispan(2060,2079,1)
;period="_6079"
proj="100"
cmip=(/"nnrp"/)
cmip2=(/"ncep"/)
runyears=(/"1990-2010"/)
ystart=ispan(1990,2009,1)
period="_9009"


dir1="/srv/ccrc/data34/z3478332/CMIP-WRF-ECLs/outputUM/proj"+proj+"/"
cat1="_50_rad2cv06"
cat2="rad2cv0.8"

fin=addfile("WRF_d01_ESB_mask.nc","r")
ESB_d01=fin->ESB
fin=addfile("/srv/ccrc/data13/z3393020/Analyses/share/geo_em_files/geo_em.d01.narclim.nc","r")
lat1 = rm_single_dims(wrf_user_getvar(fin,"XLAT_M",-1))
lon1 = rm_single_dims(wrf_user_getvar(fin,"XLONG_M",-1))

c=0
do while(c.lt.dimsizes(cmip))
w=0
do while(w.lt.dimsizes(wrfv))


INDIR="/srv/ccrc/data41/z3444417/Data/WRF/"+cmip(c)+"/"+wrfv(w)+"/"+runyears(c)+"/"

print(INDIR)

; Get the ECL list
  ECLDIR=dir1+"outputUM_"+cmip2(c)+"_WRF"+wrfv(w)+cat1+"/"
  filename = ECLDIR+"ECLfixes_umelb_"+cmip2(c)+"_wrf"+wrfv(w)+"_proj"+proj+"_"+cat2+period+".csv"
  read_data= asciiread(filename,-1,"string")
  header    = read_data(0)        ; Header. Use for variable names.
  data      = read_data(1:)       ; Get rid of first line which is a header.
  delete([/filename,read_data/])

  date = tointeger(str_get_field(data,4,","))  
;  date=where(date.ge.20100000,date-200000,date) ; Fix for mistake in the .csv file dates. 
  lat = tofloat(str_get_field(data,8,","))  
  lon= tofloat(str_get_field(data,7,","))  
  tmp=stringtochar(str_get_field(data,5,","))
  time=tointeger(charactertostring(tmp(:,0:1)))
  delete([/tmp,data/])
; Get the 6-hourly rainfall totals

  k=0
  do while(k.lt.dimsizes(ystart))
    fname1="U10/raw/d01/CCRC_NARCliM_06H_"+ystart(k)+"_instantaneous_U10.nc"
    fname2="V10/raw/d01/CCRC_NARCliM_06H_"+ystart(k)+"_instantaneous_V10.nc"
    if(k.eq.0) then
      a=addfile(INDIR+fname1,"r")
      u10=a->U10
      a=addfile(INDIR+fname2,"r")
      v10=a->V10
    else
      a=addfile(INDIR+fname1,"r")
      tmp1=array_append_record(u10,a->U10,0)
      a=addfile(INDIR+fname2,"r")
      tmp2=array_append_record(v10,a->V10,0)
      delete([/u10,v10/])
      u10=tmp1
      v10=tmp2
      delete([/tmp1,tmp2/])
    end if

    delete([/fname1,fname2,a/])
    k=k+1
  end do
  
  tmp=yyyymmddhh_time(ystart(0),ystart(dimsizes(ystart)-1),6,"integer")
  dateW=tmp/100
  timeW=tointeger(mod(tmp,100))

; Now, make the composites
  len=dimsizes(date)
  ECL_U10=new((/len,21,21/),typeof(u10))
  ECL_V10=new((/len,21,21/),typeof(u10))

  I=getind_latlon2d(lat1,lon1,lat,lon)
  do ip=0,len-1
     J=ind(dateW.eq.date(ip).and.timeW.eq.time(ip))
     ECL_U10(ip,:,:)=u10(J,(I(ip,0)-10):(I(ip,0)+10),(I(ip,1)-10):(I(ip,1)+10))
     ECL_V10(ip,:,:)=v10(J,(I(ip,0)-10):(I(ip,0)+10),(I(ip,1)-10):(I(ip,1)+10))
  end do

; Finally, write me a netcdf file

fout=ECLDIR+"ECLfixes_compositewind_"+cmip2(c)+"_wrf"+wrfv(w)+"_proj"+proj+"_"+cat2+period+".nc"
ECL_U10!0="Time"
ECL_U10!1="south_north"
ECL_U10!2="east_west"
ECL_U10@description="6-hour instantaneous 10m zonal wind within 500km radius of low centre"

ECL_V10!0="Time"
ECL_V10!1="south_north"
ECL_V10!2="east_west"
ECL_V10@description="6-hour instantaneous 10m meridional wind within 500km radius of low centre"

ECL_WS10=(ECL_U10^2+ECL_V10^2)^0.5
print(max(ECL_WS10))
ECL_WS10!0="Time"
ECL_WS10!1="south_north"
ECL_WS10!2="east_west"
ECL_WS10@description="6-hour instantaneous 10m meridional wind within 500km radius of low centre"

system("/bin/rm -f "+fout)
out = addfile(fout,"c")
out->ECL_U10=ECL_U10
out->ECL_V10=ECL_V10
out->ECL_WS10=ECL_WS10

delete([/ECL_U10,ECL_V10,ECL_WS10,out,fout,J,I,len,ip/])
delete([/dateW,timeW,u10,v10/])
delete([/date,time,lat,lon,tmp/])

w=w+1
end do
c=c+1
end do