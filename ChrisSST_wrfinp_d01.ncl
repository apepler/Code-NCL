load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

; First, the general WRF stuff
;  BDIR="/srv/ccrc/data42/z3457920/nemo_London_temp/nemo_cordex24_ERAI01/"
;  BDIR="/srv/ccrc/data42/z3457920/20151012_eac_sep_dynamics/nemo_cordex24_ERAI01/"
;  WDIR="/srv/ccrc/data23/z3478332/WRF/WRF_boundary/control_NEMOSST/"
  BDIR="/srv/ccrc/data42/z3457920/20151012_eac_sep_dynamics/nemo_cordex24REALNONZ500_ERAI01/"
  WDIR="/srv/ccrc/data23/z3478332/WRF/WRF_boundary/nznoland/"
  Cname="cordex24REALNONZ500-ERAI01_1d_"
  fin=addfile("/srv/ccrc/data13/z3393020/Analyses/share/geo_em_files/geo_em.d01.narclim.nc","r")
  latW = wrf_user_getvar(fin,"XLAT_M",0)
  lonW = wrf_user_getvar(fin,"XLONG_M",0)
  lonW1=where(lonW.lt.0,lonW+360,lonW) ;Because BRAN is 0-360
;  maskW = 1-(fin->LANDMASK(0,:,:))
   delete(fin)

  year1=1992
  year2=2009
  year=year1

  do while(year.le.year2)
  month=1
  do while(month.le.12)


fW=WDIR+"wrflowinp_d01_"+year+"-"+sprinti("%2.2i",month)+".nc" 
out=addfile(fW,"w")
sstW  = out->SST

files1=systemfunc(" ls -1 " + BDIR+(year-1)+"/"+Cname+(year-1)+"????_"+(year-1)+"????_grid_T_2D.nc")
files2=array_append_record(files1,systemfunc(" ls -1 " + BDIR+(year)+"/"+Cname+(year)+"????_"+(year)+"????_grid_T_2D.nc"),0)
files=array_append_record(files2,systemfunc(" ls -1 " + BDIR+(year+1)+"/"+Cname+(year+1)+"????_"+(year+1)+"????_grid_T_2D.nc"),0)
delete([/files1,files2/])

  fin=addfiles(files,"r")
  lonB = fin[0]->nav_lon
  latB = fin[0]->nav_lat
  time = fin[:]->time_average_1d
  date=cd_calendar(time,-5)

  a=ind(date(:,0).eq.year.and.date(:,1).eq.month)
; Okay, so, we want all the days of the month + 1 on either side

  sstB  = fin[:]->tos((a(0)-1):(a(dimsizes(a)-1)+1),:,:)
  sstB@_FillValue = default_fillvalue("float")

; Need to convert to Kelvin
  sstB = where(sstB.eq.0,sstB@_FillValue,sstB)
  len2=dimsizes(sstB)

; Making the file with interpolated daily data
; v1: Goes from 12Z to 12Z, which is easier for averaging
  len3=dimsizes(a)*4+5

  sstB2 = new((/len3,len2(1),len2(2)/),typeof(sstB),sstB@_FillValue)
  sstB2@lon=lonB
  sstB2@lat=latB

; Do silly averaging to convert to 6-hourly. Better will have to incorporate months on either side
  sstB2(0:(len3-1):4,:,:)=sstB
  sstB2(2:(len3-3):4,:,:)=(sstB(0:dimsizes(a),:,:)+sstB(1:(dimsizes(a)+1),:,:))/2
  sstB2(1:(len3-2):2,:,:)=(sstB2(0:(len3-3):2,:,:)+sstB2(2:(len3-1):2,:,:))/2
  delete(a)
; Then, only take the values from 00Z-00Z
  sstB3=sstB2(2:(len3-3),:,:)

  a = where(ismissing(sstB3),0,1)
  b = dim_sum_n(a,0)
  maskB = where(b.eq.(len3-4),1,0)

;Regrid sstB3 to the WRF curvilinear array

;Two methods depending on distance from coast

   Opt                = True
   Opt@SrcGridLat = latB
   Opt@SrcGridLon = lonB
   Opt@DstGridLat = latW
   Opt@DstGridLon = lonW1
   Opt@ForceOverwrite = True
   Opt@DstRegional = True
;   Opt@DstMask2D = maskW
   Opt@SrcMask2D = maskB
   Opt@PrintTimings      = True
   Opt@Debug             = True


Opt@InterpMethod="bilinear"
sstB4=ESMF_regrid(sstB3,Opt)+273.15
Opt@InterpMethod="neareststod"
sstB5=ESMF_regrid(sstB3,Opt)+273.15
sstB6=where(ismissing(sstB4),sstB5,sstB4)


sstB7=where(sstW.eq.0,0,sstB6)
copy_VarMeta(sstW,sstB7)
delete(sstB7@_FillValue)
out->SST = sstB7
   
delete([/out,fW,fin,lonB,latB,time,date,len2,len3/])
delete([/a,b,maskB,Opt,sstW,files/])
delete([/sstB,sstB2,sstB3,sstB4,sstB5,sstB6,sstB7/])
print(year+month)
month=month+1
end do
year=year+1
end do

