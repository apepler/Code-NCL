load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

ECLDIR="/srv/ccrc/data34/z3478332/ECLtracks/outputUM_"
;INDIR="/srv/ccrc/data45/z3478332/WRF/output/ERAI_R2_nonudging_notopo/out/impact/"
INDIR="/srv/ccrc/data34/z3478332/WRF/ERA-nudge/"

OUTDIR=INDIR

name="ERA-nudge"
cat="p100_rad2cv1_2"
cat2="rad2_p100_cv1.0"

year=ispan(1990,2009,1)

fin=addfile("WRF_d01_ESB_mask.nc","r")
ESB_d01=fin->ESB
fin=addfile("/srv/ccrc/data13/z3393020/Analyses/share/geo_em_files/geo_em.d01.narclim.nc","r")
lat1 = rm_single_dims(wrf_user_getvar(fin,"XLAT_M",-1))
lon1 = rm_single_dims(wrf_user_getvar(fin,"XLONG_M",-1))

  ECLrain=conform_dims((/dimsizes(year),4,144,215/),0.0,-1) 
  ECLrain!0="Time"
  ECLrain!1="Threshold"
  ECLrain!2="south_north"
  ECLrain!3="east_west"
  ECLrain@description="Annual rain accummulation within 500km radius of low centre"

  ECLrain_loc=ECLrain
  ECLrain_loc@description="Annual rain accummulation within 500km radius of low centre, where w/in ECL domain"

  AllRain=ECLrain
  AllRain@description="Annual rain accummulation"
; Get the ECL list

  filename = ECLDIR+name+"/"+cat+"/d01/"+"ECLfixes_"+name+"_d01_"+cat2+".csv"
  read_data= asciiread(filename,-1,"string")
  header    = read_data(0)        ; Header. Use for variable names.
  data      = read_data(1:)       ; Get rid of first line which is a header.
  date = tointeger(str_get_field(data,4,","))
  lat = tofloat(str_get_field(data,8,","))  
  lon= tofloat(str_get_field(data,7,","))  
  loc= tointeger(str_get_field(data,11,","))  
  tmp=stringtochar(str_get_field(data,5,","))
  time=tointeger(charactertostring(tmp(:,1:2)))
  datetime=date*100+time
  datetime2=get_unique_values(datetime) ; Only in 6.3.0
  dateyy=datetime2/1000000

  len2=dimsizes(datetime2)
  I=getind_latlon2d(lat1,lon1,lat,lon)

y=0

do while(y.lt.dimsizes(year))
  
print(year(y))
; Get the 6-hourly rainfall totals - +-3 hours

  f1 = addfile(INDIR+"pr_"+year(y)+"_d01_6hr_centred.nc","r")
  rain=wrf_user_getvar(f1,"rain",-1)
  rain6=where(rain.ge.6,1,0)
  rain12=where(rain.ge.12,1,0)
  rain24=where(rain.ge.24,1,0)

  dateW=yyyymmddhh_time(year(y),year(y),6,"integer")

; Make total raifnall
  AllRain(y,0,:,:)=(/dim_sum_n_Wrap(rain,0)/)
  AllRain(y,1,:,:)=(/dim_sum_n_Wrap(rain6,0)/)
  AllRain(y,2,:,:)=(/dim_sum_n_Wrap(rain12,0)/)
  AllRain(y,3,:,:)=(/dim_sum_n_Wrap(rain24,0)/)

; Really need to do distance so we use true circle, but lazy rectangle for now
; But making sure only incorporates each ECL at a given time once. 

    ECLmask=conform_dims(dimsizes(rain),0,-1) 
    ECLmask_loc=conform_dims(dimsizes(rain),0,-1) 

  Y=ind(dateyy.eq.year(y))
  do ip=Y(0),Y(dimsizes(Y)-1)
    J=ind(datetime.eq.datetime2(ip))
    K=ind(dateW.eq.datetime2(ip))

    do ix=0,dimsizes(J)-1
      ECLmask(K,(I(J(ix),0)-10):(I(J(ix),0)+10),(I(J(ix),1)-10):(I(J(ix),1)+10))=1
     if(loc(J(ix)).eq.1) then
       ECLmask_loc(K,(I(J(ix),0)-10):(I(J(ix),0)+10),(I(J(ix),1)-10):(I(J(ix),1)+10))=1
     end if
    end do
    delete([/J,K/])
  end do

    ECLrain(y,0,:,:)=(/dim_sum_n_Wrap(rain*ECLmask,0)/)
    ECLrain(y,1,:,:)=(/dim_sum_n_Wrap(rain6*ECLmask,0)/)
    ECLrain(y,2,:,:)=(/dim_sum_n_Wrap(rain12*ECLmask,0)/)
    ECLrain(y,3,:,:)=(/dim_sum_n_Wrap(rain24*ECLmask,0)/)

    ECLrain_loc(y,0,:,:)=(/dim_sum_n_Wrap(rain*ECLmask_loc,0)/)
    ECLrain_loc(y,1,:,:)=(/dim_sum_n_Wrap(rain6*ECLmask_loc,0)/)
    ECLrain_loc(y,2,:,:)=(/dim_sum_n_Wrap(rain12*ECLmask_loc,0)/)
    ECLrain_loc(y,3,:,:)=(/dim_sum_n_Wrap(rain24*ECLmask_loc,0)/)

delete([/f1,rain,rain6,rain12,rain24,dateW,ECLmask,ECLmask_loc,Y/])

y=y+1
end do

; Finally, write me a netcdf file

fout=OUTDIR+"ECLrain_annual_"+name+"_"+cat+"_2.nc"

system("/bin/rm -f "+fout)
out = addfile(fout,"c")
out->allrain=AllRain
out->ECLrain=ECLrain
out->ECLrain_loc=ECLrain_loc
