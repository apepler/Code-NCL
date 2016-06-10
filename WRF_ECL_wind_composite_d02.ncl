load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

;INDIRS=(/"/srv/ccrc/data36/z3478332/WRF/output/ERAI_R1_nudging_default_2007/out/","/srv/ccrc/data36/z3478332/WRF/output/ERAI_R2_nudging_default_2007/out/","/srv/ccrc/data36/z3478332/WRF/output/ERAI_R3_nudging_default_2007/out/","/srv/ccrc/data36/z3478332/WRF/output/ERAI_R1_nudging_default_2007_notopo/out/","/srv/ccrc/data36/z3478332/WRF/output/ERAI_R2_nudging_default_2007_notopo/out/","/srv/ccrc/data36/z3478332/WRF/output/ERAI_R3_nudging_default_2007_notopo/out/","/srv/ccrc/data37/z3478332/WRF/output/ERAI_R2_nudging_default_2007_BRAN/out/","/srv/ccrc/data37/z3478332/WRF/output/ERAI_R2_nudging_default_2007_BRAN_noeac/out/","/srv/ccrc/data37/z3478332/WRF/output/ERAI_R1_nudging_default_2007_BRAN/out/","/srv/ccrc/data37/z3478332/WRF/output/ERAI_R1_nudging_default_2007_BRAN_noeac/out/","/srv/ccrc/data37/z3478332/WRF/output/ERAI_R3_nudging_default_2007_BRAN/out/","/srv/ccrc/data37/z3478332/WRF/output/ERAI_R3_nudging_default_2007_BRAN_noeac/out/"/)

INDIRS=(/"/srv/ccrc/data45/z3478332/WRF/output/ERAI_R1_nudging_default_2007_BRAN_2eac/out/","/srv/ccrc/data36/z3478332/WRF/output/ERAI_R2_nudging_default_2007_BRAN_2eac/out/","/srv/ccrc/data45/z3478332/WRF/output/ERAI_R3_nudging_default_2007_BRAN_2eac/out/"/)
OUTDIRS=(/"/srv/ccrc/data45/z3478332/WRF/output/ERAI_R1_nudging_default_2007_BRAN_2eac/out/","/srv/ccrc/data45/z3478332/WRF/output/ERAI_R2_nudging_default_2007_BRAN_2eac/out/","/srv/ccrc/data45/z3478332/WRF/output/ERAI_R3_nudging_default_2007_BRAN_2eac/out/"/)

ECLDIR="/srv/ccrc/data34/z3478332/ECLtracks/outputUM_wrf_2007_all/"
;names=(/"R1","R2","R3","R1_notopo","R2_notopo","R3_notopo","R2_BRAN","R2_BRAN_noeac","R1_BRAN","R1_BRAN_noeac","R3_BRAN","R3_BRAN_noeac"/)
names=(/"R1_BRAN_2eac","R2_BRAN_2eac","R3_BRAN_2eac"/)
cat="rad2_p100"

fin=addfile("WRF_d02_ESB_mask.nc","r")
ESB_d01=fin->ESB
fin=addfile("/srv/ccrc/data13/z3393020/Analyses/share/geo_em_files/geo_em.d02.narclim.nc","r")
lat1 = rm_single_dims(wrf_user_getvar(fin,"XLAT_M",-1))
lon1 = rm_single_dims(wrf_user_getvar(fin,"XLONG_M",-1))
stats=(/"Mean rain","Max rain","Cells >= 5mm","Cells >= 25mm"/)
stats!0="Statistic"

n=0
do while(n.lt.dimsizes(INDIRS))
  INDIR=INDIRS(n)
  print(INDIR)

; Get the ECL list
  
  filename = ECLDIR+"ECLfixes_d02_2007_"+names(n)+"_"+cat+"_v2.csv"
  read_data= asciiread(filename,-1,"string")
  header    = read_data(0)        ; Header. Use for variable names.
  data1      = read_data(1:)       ; Get rid of first line which is a header.
  delete([/filename,read_data/])

  filename = ECLDIR+"ECLfixes_d02_2008_"+names(n)+"_"+cat+"_v2.csv"
  read_data= asciiread(filename,-1,"string")
  data2      = read_data(1:)       ; Get rid of first line which is a header.
  data= array_append_record(data1,data2,0)
  delete([/filename,read_data,data1,data2/])

  date = tointeger(str_get_field(data,4,","))  
  lat = tofloat(str_get_field(data,8,","))  
  lon= tofloat(str_get_field(data,7,","))  
  tmp=stringtochar(str_get_field(data,5,","))
  time=tointeger(charactertostring(tmp(:,1:2)))

; Get the 6-hourly wind totals

  FILES1 = systemfunc (" ls -1 " + INDIR + "wrfhrly_d02_200?-??-??_??:00:00")
  f1 = addfiles(FILES1+".nc","r")
  times=wrf_user_getvar(f1,"times",-1)
  numDAYS = dimsizes(times)/6
  a=ispan(0,dimsizes(times)-1,6) 

  u10 = wrf_user_getvar(f1,"U10",a)    ; uv
  v10 = wrf_user_getvar(f1,"V10",a)

  delete([/tmp,a/])
  tmp=stringtochar(times)
  len=dimsizes(times)-1
  dateW=tointeger(charactertostring(tmp(0:len:6,(/0,1,2,3,5,6,8,9/))))
  timeW=tointeger(charactertostring(tmp(0:len:6,11:12)))
  delete(len)

; Now, make the composites
  len=dimsizes(date)
  ECL_U10=new((/len,101,101/),typeof(u10))
  ECL_V10=new((/len,101,101/),typeof(v10))
  
  I=getind_latlon2d(lat1,lon1,lat,lon)
  do ip=0,len-1
     J=ind(dateW.eq.date(ip).and.timeW.eq.time(ip))

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

     ECL_U10(ip,seq1b,seq2b)=u10(J,seq1a,seq2a)
     ECL_V10(ip,seq1b,seq2b)=v10(J,seq1a,seq2a)
     delete([/seq1a,seq2a,seq1b,seq2b/])
  end do

; Finally, write me a netcdf file

fout=OUTDIRS(n)+"ECLwind_d02_0708_"+cat+"_v2.nc"

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
delete([/dateW,timeW,times,u10,v10,numDAYS,FILES1,f1/])
delete([/data,date,time,lat,lon,tmp/])
n=n+1
end do
