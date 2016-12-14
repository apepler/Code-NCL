load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

ECLDIR="/srv/ccrc/data34/z3478332/ECLtracks/outputUM_"

;INDIRS=(/"/srv/ccrc/data45/z3478332/WRF/output/ERAI_R2_nonudging_notopo/out/impact/"/)
INDIRS=(/"/srv/ccrc/data34/z3478332/WRF/ERA-nudge/"/)

OUTDIRS=INDIRS

names=(/"ERA-nudge"/)
cat="p100_rad2cv1_2"
cat2="d02_rad2_p100_cv1.0"

fin=addfile("WRF_d02_ESB_mask.nc","r")
ESB_d02=fin->ESB
fin=addfile("/srv/ccrc/data13/z3393020/Analyses/share/geo_em_files/geo_em.d02.narclim.nc","r")
lat1 = rm_single_dims(wrf_user_getvar(fin,"XLAT_M",-1))
lon1 = rm_single_dims(wrf_user_getvar(fin,"XLONG_M",-1))

n=0
do while(n.lt.dimsizes(INDIRS))
  INDIR=INDIRS(n)
  print(INDIR)

; Get the ECL list
  filename = ECLDIR+names(n)+"/"+cat+"/d02/"+"ECLfixes_"+names(n)+"_"+cat2+".csv"
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

  FILES1 = systemfunc (" ls -1 " + INDIR + "pr_????_d02_6hr_centred.nc")
  f1 = addfiles(FILES1,"r")
  FILES2 = systemfunc (" ls -1 " + INDIR + "uv_????_d02_6hr.nc")
  f2 = addfiles(FILES2,"r")
  ;rain = wrf_user_getvar(f1,"rain",-1)
  times=yyyymmddhh_time(1990,2009,6,"integer")
  dateW=times/100
  timeW=mod(times,100)

; Now, make the composites
  len=dimsizes(date)
  ECLrain=new((/len,101,101/),"float")
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

     rain=wrf_user_getvar(f1,"rain",J)
     ECLrain(ip,seq1b,seq2b)=rain(seq1a,seq2a)
     u=wrf_user_getvar(f2,"u10",J)
     ECL_U10(ip,seq1b,seq2b)=u(seq1a,seq2a)
     v=wrf_user_getvar(f2,"v10",J)
     ECL_V10(ip,seq1b,seq2b)=v(seq1a,seq2a)
     delete([/seq1a,seq2a,seq1b,seq2b,rain,u,v/])
  end if
  end do

ECL_WS10=(ECL_U10^2+ECL_V10^2)^0.5
print(max(ECL_WS10))
ECL_WS10!0="Time"
ECL_WS10!1="south_north"
ECL_WS10!2="east_west"
ECL_WS10@description="6-hour instantaneous 10m meridional wind within 500km radius of low centre"

; Finally, write me a netcdf file

fout=OUTDIRS(n)+"ECLrain_"+names(n)+"_"+cat2+"_centred_2.nc"
system("/bin/rm -f "+fout)
out = addfile(fout,"c")
out->ECLrain=ECLrain
delete([/fout,out/])

fout=OUTDIRS(n)+"ECLwind_"+names(n)+"_"+cat2+"_2.nc"
system("/bin/rm -f "+fout)
out = addfile(fout,"c")
out->ECL_U10=ECL_U10
out->ECL_V10=ECL_V10
out->ECL_WS10=ECL_WS10

delete([/ECLrain,ECL_U10,ECL_V10,ECL_WS10,out,fout,J,I,len,ip/])
delete([/dateW,timeW,times,FILES1,f1/])
delete([/data,date,time,lat,lon,tmp/])
n=n+1
end do
