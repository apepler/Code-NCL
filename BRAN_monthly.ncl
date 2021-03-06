load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

; First, the general WRF stuff
BDIR="/srv/ccrc/data36/z3478332/WRF/DATA/BRAN/"

year1=1993
year2=2011  
year=year1
do while(year.le.year2)

input=BDIR+"bran3p5_sst_"+year+".nc"
output=BDIR+"bran3p5_sst_"+year+"_monthly.nc"
;Loading the three bluelink daily files & combining

fin=addfile(input,"r")
lonB = fin->xt_ocean
latB = fin->yt_ocean
time = fin->Time
date=cd_calendar(time,-5)
sstB  = short2flt(fin->temp(:,0,:,:))
a=dimsizes(sstB)
sstB2 = new((/12,a(1),a(2)/),typeof(sstB),sstB@_FillValue)
copy_VarAtts(sstB,sstB2)
delete(a)

m=1
do while(m.le.12)
  a=ind(date(:,1).eq.m)
  sstB2(m-1,:,:)=dim_avg_n_Wrap(sstB(a,:,:),0)
  m=m+1
  delete(a)
end do

a=ind(date(:,2).eq.1)
date2=date(a,0:1)
date2!0=sstB!0
date2!0="YYYYMM"

sstB2!0=sstB!0
sstB2!1=sstB!1
sstB2!2=sstB!2

system("/bin/rm -f "+output)
out = addfile(output,"c")
out->SST = sstB2
out->Times = date2

delete([/a,latB,lonB,time,date,sstB,sstB2,date2,out,input,output/])
year=year+1
end do


