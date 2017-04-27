load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

wrfv=(/"R1","R2","R3"/)
cmip=(/"ECHAM5","MIROC3.2","CCCMA3.1","CSIROMk3.0"/)
cmip2=(/"echam5","miroc","cccma","csiromk3"/)
runyears=(/"2060-2080","2060-2080","2060-2080","2060-2080","2060-2080"/)
ystart=ispan(2060,2079,1)
period="_6079"
proj="240"
;cmip=(/"nnrp","ECHAM5","MIROC3.2","CCCMA3.1","CSIROMk3.0"/)
;cmip2=(/"ncep","echam5","miroc","cccma","csiromk3"/)
;runyears=(/"1990-2010","1990-2010","1990-2010","1990-2010","1990-2010"/)
;ystart=ispan(1990,2009,1)
;period="_9009"

  lon0=fspan(-10,10,41)
  lon0!0="lon"
  lon0@units="km_E"
  lat0=fspan(-10,10,41)
  lat0!0="lat"
  lat0@units="km_N"


dir1="/srv/ccrc/data34/z3478332/CMIP-WRF-ECLs/outputUM/proj"+proj+"/"
cat1="_50_rad2cv1"
cat2="rad2cv1"

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
  loc=tointeger(str_get_field(data,11,","))
  I=ind(loc.eq.1)
  date = tointeger(str_get_field(data(I),4,",")) 
  quote = inttochar(34) 
  delim=","+quote 
;  date=where(date.ge.20100000,date-200000,date) ; Fix for mistake in the .csv file dates. 
  lat = tofloat(str_get_field(data(I),8,","))  
  lon= tofloat(str_get_field(data(I),7,","))  
  tmp=stringtochar(str_get_field(data(I),5,delim))
  time=tointeger(charactertostring(tmp(:,0:1)))
  year=floor(date/10000.)
  delete([/tmp,data,I,loc/])
; Get the 6-hourly rainfall totals

  ECL_U10=new((/dimsizes(date),dimsizes(lat0),dimsizes(lon0)/),"float")
  ECL_U10!0="Time"
  ECL_U10!1="lat"
  ECL_U10!2="lon"
  ECL_V10=ECL_U10
  ECL_PRCP=ECL_U10
;  ECL_SLP=ECL_U10
  ECL_U10@description="6-hour instantaneous 10m zonal wind within 1000km radius of low centre"
  ECL_V10@description="6-hour instantaneous 10m meridional wind within 1000km radius of low centre"
  ECL_PRCP@description="6-hour instantaneous rainfall rate within 1000km radius of low centre"

  I=getind_latlon2d(lat1,lon1,lat,lon)

  k=0
  do while(k.lt.dimsizes(ystart))
    a1=addfile(INDIR+"U10/raw/d01/CCRC_NARCliM_06H_"+ystart(k)+"_instantaneous_U10.nc","r")
    a2=addfile(INDIR+"V10/raw/d01/CCRC_NARCliM_06H_"+ystart(k)+"_instantaneous_V10.nc","r")
    a3=addfile(INDIR+"pr/raw/d01/CCRC_NARCliM_06H_"+ystart(k)+"_accumulated_pr.nc","r")

    tmp=yyyymmddhh_time(ystart(k),ystart(k),6,"integer")
    dateW=tmp/100
    timeW=tointeger(mod(tmp,100))

    K=ind(year.eq.ystart(k))

    do ip=K(0),K(dimsizes(K)-1) ;Loop over just the indices in K
     J=ind(dateW.eq.date(ip).and.timeW.eq.time(ip))
 
     if(I(ip,0).gt.20.and.I(ip,0).lt.124.and.I(ip,1).gt.20.and.I(ip,1).lt.195) then
       ECL_U10(ip,:,:)=a1->U10(J,(I(ip,0)-20):(I(ip,0)+20),(I(ip,1)-20):(I(ip,1)+20))
       ECL_V10(ip,:,:)=a2->V10(J,(I(ip,0)-20):(I(ip,0)+20),(I(ip,1)-20):(I(ip,1)+20))
       ECL_PRCP(ip,:,:)=a3->pr(J,(I(ip,0)-20):(I(ip,0)+20),(I(ip,1)-20):(I(ip,1)+20))
     end if
    end do

    delete([/a1,a2,a3,timeW,K,J,tmp,dateW/])
    k=k+1
  end do

; Finally, write me a netcdf file

fout=ECLDIR+"ECLfixes_composite_"+cmip2(c)+"_wrf"+wrfv(w)+"_proj"+proj+"_"+cat2+period+"_v3.nc"
ECL_U10!0="Time"
ECL_U10!1="south_north"
ECL_U10!2="east_west"
ECL_U10@description="6-hour instantaneous 10m zonal wind within 500km radius of low centre"

ECL_V10!0="Time"
ECL_V10!1="south_north"
ECL_V10!2="east_west"
ECL_V10@description="6-hour instantaneous 10m meridional wind within 500km radius of low centre"

ECL_PRCP!0="Time"
ECL_PRCP!1="south_north"
ECL_PRCP!2="east_west"
ECL_PRCP@description="6-hour instantaneous rainfall rate within 1000km radius of low centre"

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
out->ECL_PRCP=ECL_PRCP

delete([/ECL_U10,ECL_V10,ECL_WS10,ECL_PRCP,out,fout,I,ip/])
delete([/date,time,lat,lon,year/])

w=w+1
end do
c=c+1
end do
