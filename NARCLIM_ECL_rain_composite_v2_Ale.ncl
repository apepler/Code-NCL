load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

wrfv=(/"R1","R2","R3"/)
cmip=(/"ECHAM5","MIROC3.2","CCCMA3.1","CSIROMk3.0","nnrp"/)
cmip2=(/"echam5","miroc","cccma","csiromk3","ncep"/)
runyears=(/"1990-2010","1990-2010","1990-2010","1990-2010","1990-2010"/)
ystart=ispan(1990,2009,1)
period="_9009"

res="150"
pg="0.7"
dir1="/srv/ccrc/data34/z3478332/CMIP-WRF-ECLs/Alejandro/final/"

fin=addfile("WRF_d01_ESB_mask.nc","r")
ESB_d01=fin->ESB
fin=addfile("/srv/ccrc/data13/z3393020/Analyses/share/geo_em_files/geo_em.d01.narclim.nc","r")
lat1 = rm_single_dims(wrf_user_getvar(fin,"XLAT_M",-1))
lon1 = rm_single_dims(wrf_user_getvar(fin,"XLONG_M",-1))

c=4
do while(c.lt.dimsizes(cmip))
w=0
do while(w.lt.dimsizes(wrfv))

;INDIR="/srv/ccrc/data30/z3393020/NARCliM/postprocess/"+runyears(c)+"/"+cmip(c)+"/"+wrfv(w)+"/d01/"
INDIR="/srv/ccrc/data41/z3444417/Data/WRF/"+cmip(c)+"/"+wrfv(w)+"/"+runyears(c)+"/"

print(INDIR)

; Get the ECL list
  filename =dir1+"ECLfixes_Alejandro_"+cmip2(c)+"_wrf"+wrfv(w)+"_res"+res+period+"_pg"+pg+"_final.csv"
  read_data= asciiread(filename,-1,"string")
  header    = read_data(0)        ; Header. Use for variable names.
  data      = read_data(1:)       ; Get rid of first line which is a header.
  date = tointeger(str_get_field(data,4,","))  
  lat = tofloat(str_get_field(data,7,","))  
  lon= tofloat(str_get_field(data,6,","))  
  time=tointeger(str_get_field(data,5,","))  
  delete([/filename,read_data,data/])
; Get the 6-hourly rainfall totals

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

; Now, make the composites
  len=dimsizes(date)
  ECLrain=new((/len,21,21/),typeof(rain))
  
  I=getind_latlon2d(lat1,lon1,lat,lon)
  do ip=0,len-1
     J=ind(dateW.eq.date(ip).and.timeW.eq.time(ip))
     ECLrain(ip,:,:)=rain(J,(I(ip,0)-10):(I(ip,0)+10),(I(ip,1)-10):(I(ip,1)+10))
  end do

; Finally, write me a netcdf file
fout=dir1+"ECLfixes_compositerain_Alejandro_"+cmip2(c)+"_wrf"+wrfv(w)+"_res"+res+period+"_pg"+pg+".nc"
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