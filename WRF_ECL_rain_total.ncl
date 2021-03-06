load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

;INDIRS=(/"/srv/ccrc/data36/z3478332/WRF/output/ERAI_R1_nudging_default_2007/out/","/srv/ccrc/data36/z3478332/WRF/output/ERAI_R2_nudging_default_2007/out/","/srv/ccrc/data36/z3478332/WRF/output/ERAI_R3_nudging_default_2007/out/","/srv/ccrc/data36/z3478332/WRF/output/ERAI_R1_nudging_default_2007_notopo/out/","/srv/ccrc/data36/z3478332/WRF/output/ERAI_R2_nudging_default_2007_notopo/out/","/srv/ccrc/data36/z3478332/WRF/output/ERAI_R3_nudging_default_2007_notopo/out/","/srv/ccrc/data37/z3478332/WRF/output/ERAI_R2_nudging_default_2007_BRAN/out/","/srv/ccrc/data37/z3478332/WRF/output/ERAI_R2_nudging_default_2007_BRAN_noeac/out/"/)

ECLDIR="~/UM/cts.dir/mine/cyc_out/outputUM_wrf_2007/"
;names=(/"R1","R2","R3","R1_notopo","R2_notopo","R3_notopo","R2_BRAN","R2_BRAN_noeac"/)

INDIRS=(/"/srv/ccrc/data37/z3478332/WRF/output/ERAI_R1_nudging_default_2007_BRAN/out/","/srv/ccrc/data37/z3478332/WRF/output/ERAI_R1_nudging_default_2007_BRAN_noeac/out/","/srv/ccrc/data37/z3478332/WRF/output/ERAI_R3_nudging_default_2007_BRAN/out/","/srv/ccrc/data37/z3478332/WRF/output/ERAI_R3_nudging_default_2007_BRAN_noeac/out/"/)
names=(/"R1_BRAN","R1_BRAN_noeac","R3_BRAN","R3_BRAN_noeac"/)

cat="rad2_p100"

fin=addfile("WRF_d01_ESB_mask.nc","r")
ESB_d01=fin->ESB
fin=addfile("/srv/ccrc/data13/z3393020/Analyses/share/geo_em_files/geo_em.d01.narclim.nc","r")
lat1 = rm_single_dims(wrf_user_getvar(fin,"XLAT_M",-1))
lon1 = rm_single_dims(wrf_user_getvar(fin,"XLONG_M",-1))

mlist=array_append_record(ispan(200701,200712,1),ispan(200801,200812,1),0)


n=0
do while(n.lt.dimsizes(INDIRS))
  INDIR=INDIRS(n)
  print(INDIR)
  ECLrain=conform_dims((/24,144,215/),0.0,-1) ; Want each month separate, so can do seasonal separation
  ECLrain!0="Time"
  ECLrain!1="south_north"
  ECLrain!2="east_west"
  ECLrain@description="Monthly rain accummulation within 500km radius of low centre"

  ECLrain_loc=ECLrain
  ECLrain_loc@description="Monthly rain accummulation within 500km radius of low centre, where w/in ECL domain"

  AllRain=ECLrain
  AllRain@description="Monthly rain accummulation"
; Get the ECL list
  
  filename = ECLDIR+"ECLfixes_d01_2007_"+names(n)+"_"+cat+".csv"
  read_data= asciiread(filename,-1,"string")
  header    = read_data(0)        ; Header. Use for variable names.
  data1      = read_data(1:)       ; Get rid of first line which is a header.
  delete([/filename,read_data/])

  filename = ECLDIR+"ECLfixes_d01_2008_"+names(n)+"_"+cat+".csv"
  read_data= asciiread(filename,-1,"string")
  data2      = read_data(1:)       ; Get rid of first line which is a header.
  data= array_append_record(data1,data2,0)
  delete([/filename,read_data,data1,data2/])

  date = tointeger(str_get_field(data,4,","))
  month = floor(date/100)  
  lat = tofloat(str_get_field(data,8,","))  
  lon= tofloat(str_get_field(data,7,","))  
  loc= tointeger(str_get_field(data,11,","))  
  tmp=stringtochar(str_get_field(data,5,","))
  time=tointeger(charactertostring(tmp(:,1:2)))

; Get the 6-hourly rainfall totals

  FILES1 = systemfunc (" ls -1 " + INDIR + "wrfhrly_d01_200?-??-??_00:00:00")
  f1 = addfiles(FILES1+".nc","r")
  times=wrf_user_getvar(f1,"times",-1)
  numDAYS = dimsizes(times)/4
  var_in1=wrf_user_getvar(f1,"PREC_ACC_NC",-1)+wrf_user_getvar(f1,"PREC_ACC_C",-1)

  rain=new((/numDAYS,144,215/),typeof(var_in1))
  do ip = 0,numDAYS-1      
    rain(ip,:,:) = dim_sum_n_Wrap(var_in1(ip*6:((ip+1)*6-1),:,:),0)
  end do

  delete(tmp)
  tmp=stringtochar(times)
  len=dimsizes(times)-1
  dateW=tointeger(charactertostring(tmp(0:len:6,(/0,1,2,3,5,6,8,9/))))
  timeW=tointeger(charactertostring(tmp(0:len:6,11:12)))
  monthW=tointeger(charactertostring(tmp(0:len:6,(/0,1,2,3,5,6/))))
  delete(len)

; Make monthly rainfall
  do ip=0,23
    I=ind(monthW.eq.mlist(ip))
    AllRain(ip,:,:)=(/dim_sum_n_Wrap(rain(I,:,:),0)/)
    delete(I)
  end do

; Now, make the composites
  len=dimsizes(date)
  I=getind_latlon2d(lat1,lon1,lat,lon)
  do ip=0,len-1
     J=ind(dateW.eq.date(ip).and.timeW.eq.time(ip))
     K=ind(mlist.eq.month(ip))
     ECLrain(K,(I(ip,0)-10):(I(ip,0)+10),(I(ip,1)-10):(I(ip,1)+10))=ECLrain(K,(I(ip,0)-10):(I(ip,0)+10),(I(ip,1)-10):(I(ip,1)+10))+rain(J,(I(ip,0)-10):(I(ip,0)+10),(I(ip,1)-10):(I(ip,1)+10))
     if(loc(ip).eq.1) then
       ECLrain_loc(K,(I(ip,0)-10):(I(ip,0)+10),(I(ip,1)-10):(I(ip,1)+10))=ECLrain_loc(K,(I(ip,0)-10):(I(ip,0)+10),(I(ip,1)-10):(I(ip,1)+10))+rain(J,(I(ip,0)-10):(I(ip,0)+10),(I(ip,1)-10):(I(ip,1)+10))
     end if
  end do

; Finally, write me a netcdf file

fout=INDIR+"ECLrain_bymonth_0708_"+cat+".nc"

system("/bin/rm -f "+fout)
out = addfile(fout,"c")
out->allrain=AllRain
out->ECLrain=ECLrain
out->ECLrain_loc=ECLrain_loc

delete([/ECLrain,out,fout,J,I,len,ip,ECLrain_loc,AllRain,month,monthW/])
delete([/dateW,timeW,times,var_in1,rain,numDAYS,FILES1,f1/])
delete([/data,date,time,lat,lon,loc,tmp/])
n=n+1
end do
