load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

wrfv=(/"R1","R2","R3"/)
;cmip=(/"ECHAM5","CSIRO-MK3.0","MIROC3.2","CCCMA3.1"/)
;cmip2=(/"echam5","csiromk3","miroc","cccma"/)
;runyears=(/"2060-2079","2060-2079","2060-2079","2060-2079"/)
;ystart=ispan(2060,2079,1)
;period="_6079"

cmip=(/"nnrp"/)
cmip2=(/"ncep"/)
runyears=(/"1990-2010"/)
ystart=ispan(1990,2009,1)
period="_9009"
proj="100"

dir1="/srv/ccrc/data34/z3478332/CMIP-WRF-ECLs/outputUM/proj"+proj+"/"
cat1="_50_rad2cv1"
cat2="rad2cv1"

fin=addfile("WRF_d01_ESB_mask.nc","r")
ESB_d01=fin->ESB
fin=addfile("/srv/ccrc/data13/z3393020/Analyses/share/geo_em_files/geo_em.d01.narclim.nc","r")
lat1 = rm_single_dims(wrf_user_getvar(fin,"XLAT_M",-1))
lon1 = rm_single_dims(wrf_user_getvar(fin,"XLONG_M",-1))

c=0
do while(c.lt.dimsizes(cmip))
w=0
do while(w.lt.dimsizes(wrfv))

;INDIR="/srv/ccrc/data30/z3393020/NARCliM/filtered/"+cmip(c)+"/"+wrfv(w)+"/"+runyears(c)+"/d01/"
;INDIR="/srv/ccrc/data30/z3393020/NARCliM/postprocess/"+runyears(c)+"/"+cmip(c)+"/"+wrfv(w)+"/d01/"

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
  time=tointeger(charactertostring(tmp(:,1:2)))
  delete([/tmp,data/])
; Get the 6-hourly rainfall totals

  ECLrain=conform_dims((/144,215/),0.0,-1) 
  ECLrain!0="south_north"
  ECLrain!1="east_west"
  ECLrain@description="Annual rain accummulation within 500km radius of low centre"

  AllRain=ECLrain
  AllRain@description="Annual rain accummulation"

  k=0
  do while(k.lt.dimsizes(ystart))
    fname="pr/raw/d01/CCRC_NARCliM_06H_"+ystart(k)+"_accumulated_pr.nc"
    a=addfile(INDIR+fname,"r")
    if(k.eq.0) then
      rain=a->pr
    else
      tmp=array_append_record(rain,a->pr,0)
      delete([/rain/])
      rain=tmp
      delete([/tmp/])
    end if

    delete([/fname,a/])
    k=k+1
  end do

  tmp=yyyymmddhh_time(ystart(0),ystart(dimsizes(ystart)-1),6,"integer")
  dateW=tmp/100
  timeW=tointeger(mod(tmp,100))

  AllRain=(/dim_sum_n_Wrap(rain,0)/)

; Now, make the composites
  datetime=date*100+time
  datetime2=get_unique_values(datetime) ; Only in 6.3.0
  len=dimsizes(datetime2)
  
  I=getind_latlon2d(lat1,lon1,lat,lon)
  do ip=0,len-1
    J=ind(datetime.eq.datetime2(ip))
    K=ind(dateW.eq.date(ip).and.timeW.eq.time(ip))
    ECLmask=conform_dims((/144,215/),0,-1) 
    do ix=0,dimsizes(J)-1
      ECLmask((I(J(ix),0)-10):(I(J(ix),0)+10),(I(J(ix),1)-10):(I(J(ix),1)+10))=1
    end do

    ECLrain=ECLrain+rain(K,:,:)*ECLmask
    delete([/J,K,ECLmask/])
  end do

; Finally, write me a netcdf file

fout="/srv/ccrc/data34/z3478332/WRF/" + wrfv(w) + "/ECLrain_"+cmip2(c)+"_wrf"+wrfv(w)+"_proj"+proj+"_"+cat2+period+".nc"
system("/bin/rm -f "+fout)
out = addfile(fout,"c")
out->allrain=AllRain
out->ECLrain=ECLrain

delete([/ECLrain,AllRain,out,fout,I,len,ip/])
delete([/dateW,timeW,rain/])
delete([/date,time,lat,lon,tmp,datetime,datetime2/])

w=w+1
end do
c=c+1
end do
