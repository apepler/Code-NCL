load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

fout="/srv/ccrc/data34/z3478332/CMIP-WRF-ECLs/DailyRain/NARCLIM_daywind_d02_9009_v2.nc"

fin=addfile("WRF_d02_ESB_mask.nc","r")
ESB_d02=fin->ESB

fin=addfile("/srv/ccrc/data13/z3393020/Analyses/share/geo_em_files/geo_em.d02.narclim.nc","r")
lat1 = rm_single_dims(wrf_user_getvar(fin,"XLAT_M",-1))
lon1 = rm_single_dims(wrf_user_getvar(fin,"XLONG_M",-1))

daywind=new((/7305,15,5/),"float")
names=new(15,"string")
wrfv=(/"R1","R2","R3"/)
cmip=(/"NNRP","ECHAM5","CSIRO-MK3.0","MIROC3.2","CCCMA3.1"/)
runyears=(/"1950-2009","1990-2009","1990-2009","1990-2009","1990-2009"/)
stats=(/"Max 10min wind (m/s)","Cells >= 18 km/h","Cells >= 36 km/h","Cells >= 50 km/h","Cells >= 60 km/h"/)
stats!0="Statistic"

ystart=(/1990,1995,2000,2005/)
yend=(/1994,1999,2004,2009/)

II=0
c=0
do while(c.lt.dimsizes(cmip))
w=0
do while(w.lt.dimsizes(wrfv))

dir="/srv/ccrc/data30/z3393020/NARCliM/postprocess/"+runyears(c)+"/"+cmip(c)+"/"+wrfv(w)+"/d02/"
names(II)=cmip(c)+"-"+wrfv(w)
k=0
len=0
do while(k.lt.dimsizes(ystart))

fname="CCRC_NARCliM_DAY_"+ystart(k)+"-"+yend(k)+"_wss10maxtstep.nc"
print(dir+fname)
a=addfile(dir+fname,"r")
data=a->wss10maxtstep
delete(a)
a=dimsizes(data)

n=0
do while(n.lt.a(0))
daywind(n+len,II,0)=max(mask(data(n,:,:),ESB_d02,1))
daywind(n+len,II,1)=num(mask(data(n,:,:),ESB_d02,1).ge.5) ; 18 km/h
daywind(n+len,II,2)=num(mask(data(n,:,:),ESB_d02,1).ge.10) ; 36 km/h
daywind(n+len,II,3)=num(mask(data(n,:,:),ESB_d02,1).ge.13.9) ; 50 km/h
daywind(n+len,II,4)=num(mask(data(n,:,:),ESB_d02,1).ge.16.7) ; 60 km/h

n=n+1
end do
len=len+a(0)

delete([/data,fname,a/])
k=k+1
end do
delete(dir)
II=II+1
w=w+1
end do
c=c+1
end do

daywind!0="Day"
daywind!1="RCM"
daywind!2="Statistic"
daywind@description="ESB daily max 10min wind statistics for 1990-2009"
names!0="RCM"


system("/bin/rm -f "+fout)
out = addfile(fout,"c")
dim_names = (/"Day", "RCM",  "Statistic"  /)
dim_sizes = dimsizes(daywind)
dimUnlim = (/ True, False, False /)
filedimdef( out, dim_names, dim_sizes, dimUnlim )

out->data = daywind
;out->rcmnames = names
;out->varnames = stats

; Delete all the things

delete([/fout,daywind,names,wrfv,cmip,runyears,ystart,yend,out/])


fout="/srv/ccrc/data34/z3478332/CMIP-WRF-ECLs/DailyRain/NARCLIM_daywind_d02_6079_v2.nc"
daywind=new((/7305,12,5/),"float")
wrfv=(/"R1","R2","R3"/)
cmip=(/"ECHAM5","CSIRO-MK3.0","MIROC3.2","CCCMA3.1"/)
names=new(12,"string")
ystart=(/2060,2065,2070,2075/)
yend=(/2064,2069,2074,2079/)

II=0
c=0
do while(c.lt.dimsizes(cmip))
w=0
do while(w.lt.dimsizes(wrfv))
dir="/srv/ccrc/data30/z3393020/NARCliM/postprocess/2060-2079/"+cmip(c)+"/"+wrfv(w)+"/d02/"
names(II)=cmip(c)+"-"+wrfv(w)

k=0
len=0
do while(k.lt.dimsizes(ystart))

fname="CCRC_NARCliM_DAY_"+ystart(k)+"-"+yend(k)+"_wss10maxtstep.nc"
print(dir+fname)
a=addfile(dir+fname,"r")
data=a->wss10maxtstep
delete(a)
a=dimsizes(data)

n=0
do while(n.lt.a(0))
daywind(n+len,II,0)=max(mask(data(n,:,:),ESB_d02,1))
daywind(n+len,II,1)=num(mask(data(n,:,:),ESB_d02,1).ge.5) ; 18 km/h
daywind(n+len,II,2)=num(mask(data(n,:,:),ESB_d02,1).ge.10) ; 36 km/h
daywind(n+len,II,3)=num(mask(data(n,:,:),ESB_d02,1).ge.13.9) ; 50 km/h
daywind(n+len,II,4)=num(mask(data(n,:,:),ESB_d02,1).ge.16.7) ; 60 km/h
n=n+1
end do
len=len+a(0)

delete([/data,fname,a/])
k=k+1
end do
delete(dir)
II=II+1
w=w+1
end do
c=c+1
end do

daywind!0="Day"
daywind!1="RCM"
daywind!2="Statistic"
daywind@description="ESB daily max 10min wind statistics for 1990-2009"
names!0="RCM"

system("/bin/rm -f "+fout)
out = addfile(fout,"c")
dim_names = (/"Day", "RCM",  "Statistic"  /)
dim_sizes = dimsizes(daywind)
dimUnlim = (/ True, False, False /)
filedimdef( out, dim_names, dim_sizes, dimUnlim )

out->data = daywind
;out->rcmnames = names
;out->varnames = stats

; Delete all the things

delete([/fout,daywind,names,wrfv,cmip,ystart,yend,out/])
