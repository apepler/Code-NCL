load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

ECLDIR="/srv/ccrc/data34/z3478332/ECLtracks/outputUM_wrf_2007_all/typing/"
OUTDIR="/srv/ccrc/data45/z3478332/WRF/output/"

INDIRS=(/"/srv/ccrc/data36/z3478332/WRF/output/ERAI_R1_nudging_default_2007/out/","/srv/ccrc/data36/z3478332/WRF/output/ERAI_R2_nudging_default_2007/out/","/srv/ccrc/data36/z3478332/WRF/output/ERAI_R3_nudging_default_2007/out/","/srv/ccrc/data36/z3478332/WRF/output/ERAI_R1_nudging_default_2007_notopo/out/","/srv/ccrc/data36/z3478332/WRF/output/ERAI_R2_nudging_default_2007_notopo/out/","/srv/ccrc/data36/z3478332/WRF/output/ERAI_R3_nudging_default_2007_notopo/out/","/srv/ccrc/data37/z3478332/WRF/output/ERAI_R1_nudging_default_2007_BRAN/out/","/srv/ccrc/data37/z3478332/WRF/output/ERAI_R2_nudging_default_2007_BRAN/out/","/srv/ccrc/data37/z3478332/WRF/output/ERAI_R3_nudging_default_2007_BRAN/out/","/srv/ccrc/data37/z3478332/WRF/output/ERAI_R1_nudging_default_2007_BRAN_noeac/out/","/srv/ccrc/data37/z3478332/WRF/output/ERAI_R2_nudging_default_2007_BRAN_noeac/out/","/srv/ccrc/data37/z3478332/WRF/output/ERAI_R3_nudging_default_2007_BRAN_noeac/out/","/srv/ccrc/data45/z3478332/WRF/output/ERAI_R1_nudging_default_2007_BRAN_2eac/out/","/srv/ccrc/data45/z3478332/WRF/output/ERAI_R2_nudging_default_2007_BRAN_2eac/out/","/srv/ccrc/data45/z3478332/WRF/output/ERAI_R3_nudging_default_2007_BRAN_2eac/out/"/)

names=(/"R1","R2","R3","R1_notopo","R2_notopo","R3_notopo","R1_BRAN","R2_BRAN","R3_BRAN","R1_BRAN_noeac","R2_BRAN_noeac","R3_BRAN_noeac","R1_BRAN_2eac","R2_BRAN_2eac","R3_BRAN_2eac"/)
names2=(/"","","","","","","","","","","","","_v2","_v2","_v2"/)
names3=(/"","","","","","","","","","","","","2","2","2"/)

cat="rad2_p100"

fin=addfile("WRF_d02_ESB_mask.nc","r")
ESB_d02=fin->ESB
fin=addfile("/srv/ccrc/data13/z3393020/Analyses/share/geo_em_files/geo_em.d02.narclim.nc","r")
lat1 = rm_single_dims(wrf_user_getvar(fin,"XLAT_M",-1))
lon1 = rm_single_dims(wrf_user_getvar(fin,"XLONG_M",-1))

n=0
do while(n.lt.dimsizes(INDIRS))
  INDIR=INDIRS(n)
;  OUTDIR=OUTDIRS(n)
  print(INDIR)
  ECLrain=conform_dims((/4,200,325/),0.0,-1) 
  ECLrain!1="south_north"
  ECLrain!2="east_west"
  ECLrain!0="threshold"
  ECLrain&threshold=(/0,6,12,24/)
  ECLrain@description="Number of hours with at least X mm/6hr accumulation within 500km radius of low centre"

  ECLrain_loc=ECLrain
  ECLrain_loc@description="Number of hours with at least X mm/6hr accumulation within 500km radius of low centre, where w/in ECL domain"

  AllRain=ECLrain
  AllRain@description="Number of hours with at least X mm/6hr accumulation"
; Get the ECL list
  
  filename = ECLDIR+"ECLfixes_d02_0708_"+names(n)+"_"+cat+names2(n)+"_typing.csv"
  read_data= asciiread(filename,-1,"string")
  header    = read_data(0)        ; Header. Use for variable names.
  data      = read_data(1:)       ; Get rid of first line which is a header.
  date = tointeger(str_get_field(data,4,","))
  lat = tofloat(str_get_field(data,8,","))  
  lon= tofloat(str_get_field(data,7,","))  
  loc= tointeger(str_get_field(data,11,","))  
  tmp=stringtochar(str_get_field(data,5,","))
  time=tointeger(charactertostring(tmp(:,1:2)))

; Get the 6-hourly rainfall totals - +-3 hours

  FILES1 = systemfunc (" ls -1 " + INDIR + "wrfhrly_d02_200?-??-??_00:00:00")
  f1 = addfiles(FILES1+".nc","r")
  times=wrf_user_getvar(f1,"times",-1)
  numDAYS = dimsizes(times)/6
  var_in1=wrf_user_getvar(f1,"PREC_ACC_NC",-1)+wrf_user_getvar(f1,"PREC_ACC_C",-1)

  rain=new((/numDAYS+1,200,325/),typeof(var_in1))
  rain(0,:,:) = dim_sum_n_Wrap(var_in1(0:2,:,:),0)
  do ip = 1,numDAYS-1      
    rain(ip,:,:) = dim_sum_n_Wrap(var_in1((ip*6-3):(ip*6+2),:,:),0)
  end do
  rain(numDAYS,:,:) = dim_sum_n_Wrap(var_in1((numDAYS*6-3):(numDAYS*6-1),:,:),0)

  rain6=where(rain.ge.6,1,0)
  rain12=where(rain.ge.12,1,0)
  rain24=where(rain.ge.24,1,0)

  delete(tmp)
  tmp=stringtochar(times)
  len=dimsizes(times)-1
  dateW=tointeger(charactertostring(tmp(0:len:6,(/0,1,2,3,5,6,8,9,11,12/))))
  delete(len)

; Make total raifnall
    AllRain(0,:,:)=(/dim_sum_n_Wrap(rain,0)/)
    AllRain(1,:,:)=(/dim_sum_n_Wrap(rain6,0)/)
    AllRain(2,:,:)=(/dim_sum_n_Wrap(rain12,0)/)
    AllRain(3,:,:)=(/dim_sum_n_Wrap(rain24,0)/)

; Now, make the composites
; Need a better way to do the dates - so, need a date/time matrix

datetime=date*100+time
datetime2=get_unique_values(datetime) ; Only in 6.3.0
len2=dimsizes(datetime2)
I=getind_latlon2d(lat1,lon1,lat,lon)

; Really need to do distance so we use true circle, but lazy rectangle for now
; But making sure only incorporates each ECL at a given time once. 

  do ip=0,len2-1
    J=ind(datetime.eq.datetime2(ip))
    K=ind(dateW.eq.datetime2(ip))
    ECLmask=conform_dims((/200,325/),0,-1) 
    ECLmask_loc=conform_dims((/200,325/),0,-1) 

    do ix=0,dimsizes(J)-1
;     can't be anything smaller than 0 or greater than rightmost index
    if(I(J(ix),0).gt.0.and.I(J(ix),0).lt.199.and.I(J(ix),1).gt.0.and.I(J(ix),1).lt.324.) then
      seq1=ispan(max((/0,I(J(ix),0)-50/)),min((/199,I(J(ix),0)+50/)),1)
      seq2=ispan(max((/0,I(J(ix),1)-50/)),min((/324,I(J(ix),1)+50/)),1)

      ECLmask(seq1,seq2)=1
     if(loc(J(ix)).eq.1) then
       ECLmask_loc(seq1,seq2)=1
     end if
    delete([/seq1,seq2/])
    end if
    end do

    ECLrain(0,:,:)=ECLrain(0,:,:)+rain(K,:,:)*ECLmask
    ECLrain_loc(0,:,:)=ECLrain_loc(0,:,:)+rain(K,:,:)*ECLmask_loc
    ECLrain(1,:,:)=ECLrain(1,:,:)+rain6(K,:,:)*ECLmask
    ECLrain_loc(1,:,:)=ECLrain_loc(1,:,:)+rain6(K,:,:)*ECLmask_loc
    ECLrain(2,:,:)=ECLrain(2,:,:)+rain12(K,:,:)*ECLmask
    ECLrain_loc(2,:,:)=ECLrain_loc(2,:,:)+rain12(K,:,:)*ECLmask_loc
    ECLrain(3,:,:)=ECLrain(3,:,:)+rain24(K,:,:)*ECLmask
    ECLrain_loc(3,:,:)=ECLrain_loc(3,:,:)+rain24(K,:,:)*ECLmask_loc

    delete([/J,K/])
  end do

; Finally, write me a netcdf file

fout=OUTDIR+"ECLrain_0708_extremes_d02_"+names(n)+names3(n)+"_"+cat+"_v3.nc"

system("/bin/rm -f "+fout)
out = addfile(fout,"c")
out->allrain=AllRain
out->ECLrain=ECLrain
out->ECLrain_loc=ECLrain_loc

delete([/ECLrain,out,fout,I,ip,ECLrain_loc,AllRain/])
delete([/dateW,times,var_in1,rain,numDAYS,FILES1,f1/])
delete([/data,date,time,lat,lon,loc,tmp,header,read_data,filename,datetime,datetime2,len2/])
n=n+1
end do
