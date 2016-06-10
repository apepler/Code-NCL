load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

wrfv=(/"R1","R2","R3"/)
cmip=(/"ECHAM5","CSIRO-MK3.0","MIROC3.2","CCCMA3.1"/)
cmip2=(/"echam5","csiromk3","miroc","cccma"/)
runyears=(/"2060-2079","2060-2079","2060-2079","2060-2079"/)
ystart=ispan(2060,2079,1)
period="_6079"
proj="240"

dir1="/srv/ccrc/data34/z3478332/CMIP-WRF-ECLs/outputUM/proj"+proj+"/"
cat1="_50_rad2cv1"
cat2="rad2cv1.35"

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
INDIR="/srv/ccrc/data30/z3393020/NARCliM/postprocess/"+runyears(c)+"/"+cmip(c)+"/"+wrfv(w)+"/d01/"

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

  k=0
  do while(k.lt.dimsizes(ystart))
    fname="CCRC_NARCliM_01H_"+ystart(k)+"-"+ystart(k)+"_pracc.nc"
    a=addfile(INDIR+fname,"r")
    data=a->pracc
    times=a->time
    numDAYS = dimsizes(times)/6
    data2=new((/numDAYS,144,215/),typeof(data))
    times2=times(0:(dimsizes(times)-1):6)
    do ip = 0,numDAYS-1      
      data2(ip,:,:) = dim_sum_n_Wrap(data(ip*6:((ip+1)*6-1),:,:),0)
    end do

    if(k.eq.0) then
      rain=data2
      timeW=times2
    else
      tmp1=array_append_record(rain,data2,0)
      tmp2=array_append_record(timeW,times2,0)
      delete([/rain,timeW/])
      rain=tmp1
      timeW=tmp2
      delete([/tmp1,tmp2/])
    end if

    delete([/data,data2,fname,a,times,times2,numDAYS/])
    k=k+1
  end do

  tmp=cd_calendar(timeW,0)
  delete(timeW)
  dateW=tointeger(tmp(:,0))*10000+tointeger(tmp(:,1))*100+tointeger(tmp(:,2))
  timeW=tmp(:,3)

; Now, make the composites
  len=dimsizes(date)
  ECLrain=new((/len,21,21/),typeof(rain))
  
  I=getind_latlon2d(lat1,lon1,lat,lon)
  do ip=0,len-1
     J=ind(dateW.eq.date(ip).and.timeW.eq.time(ip))
     ECLrain(ip,:,:)=rain(J,(I(ip,0)-10):(I(ip,0)+10),(I(ip,1)-10):(I(ip,1)+10))
  end do

; Finally, write me a netcdf file

fout=ECLDIR+"ECLfixes_composite_"+cmip2(c)+"_wrf"+wrfv(w)+"_proj"+proj+"_"+cat2+period+".nc"
ECLrain!0="Time"
ECLrain!1="south_north"
ECLrain!2="east_west"
ECLrain@description="6-hour rain accummulation within 500km radius of low centre"

system("/bin/rm -f "+fout)
out = addfile(fout,"c")
out->ECLrain=ECLrain

delete([/ECLrain,out,fout,J,I,len,ip/])
delete([/dateW,timeW,rain/])
delete([/date,time,lat,lon,tmp/])

w=w+1
end do
c=c+1
end do