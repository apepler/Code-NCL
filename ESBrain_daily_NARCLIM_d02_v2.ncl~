load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

fout="/srv/ccrc/data34/z3478332/CMIP-WRF-ECLs/DailyRain/NARCLIM_dayrain_d01_9009_v2.nc"

fin=addfile("WRF_d01_ESB_mask.nc","r")
ESB_d01=fin->ESB

fin=addfile("/srv/ccrc/data13/z3393020/Analyses/share/geo_em_files/geo_em.d01.narclim.nc","r")
lat1 = rm_single_dims(wrf_user_getvar(fin,"XLAT_M",-1))
lon1 = rm_single_dims(wrf_user_getvar(fin,"XLONG_M",-1))

dayrain=new((/7305,15,4/),"float")
names=new(15,"string")
wrfv=(/"R1","R2","R3"/)
cmip=(/"NNRP","ECHAM5","CSIRO-MK30","MIROC3.2","CCCMA3.1"/)
runyears=(/"1950-2010","1990-2010","1990-2010","1990-2010","1990-2010"/)
stats=(/"Mean rain","Max rain","Cells >= 5mm","Cells >= 25mm"/)
stats!0="Statistic"

ystart=(/1990,1995,2000,2005/)
yend=(/1994,1999,2004,2009/)

II=0
c=0
do while(c.lt.dimsizes(cmip))
w=0
do while(w.lt.dimsizes(wrfv))

dir="/srv/ccrc/data30/z3393020/NARCliM/filtered/"+cmip(c)+"/"+wrfv(w)+"/"+runyears(c)+"/d01/"
names(II)=cmip(c)+"-"+wrfv(w)
k=0
len=0
do while(k.lt.dimsizes(ystart))

fname="CCRC_NARCliM_DAY_"+ystart(k)+"-"+yend(k)+"_pracc_fl.nc"
print(dir+fname)
a=addfile(dir+fname,"r")
data=a->pracc_fl
delete(a)
a=dimsizes(data)

n=0
do while(n.lt.a(0))
dayrain(n+len,II,0)=avg(mask(data(n,:,:),ESB_d01,1))
dayrain(n+len,II,1)=max(mask(data(n,:,:),ESB_d01,1))
dayrain(n+len,II,2)=num(mask(data(n,:,:),ESB_d01,1).ge.5)
dayrain(n+len,II,3)=num(mask(data(n,:,:),ESB_d01,1).ge.25)
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

dayrain!0="Day"
dayrain!1="RCM"
dayrain!2="Statistic"
dayrain@description="ESB daily rainfall statistics for 1990-2009"
names!0="RCM"

system("/bin/rm -f "+fout)
out = addfile(fout,"c")
dim_names = (/"Day", "RCM",  "Statistic"  /)
dim_sizes = dimsizes(dayrain)
dimUnlim = (/ True, False, False /)
filedimdef( out, dim_names, dim_sizes, dimUnlim )

out->data = dayrain
out->rcmnames = names
out->varnames = stats

; Delete all the things

delete([/fout,dayrain,names,wrfv,cmip,runyears,ystart,yend,out/])


fout="/srv/ccrc/data34/z3478332/CMIP-WRF-ECLs/DailyRain/NARCLIM_dayrain_d01_6079_v2.nc"
dayrain=new((/7305,12,4/),"float")
wrfv=(/"R1","R2","R3"/)
cmip=(/"ECHAM5","CSIRO-MK30","MIROC3.2","CCCMA3.1"/)
names=new(12,"string")
ystart=(/2060,2065,2070,2075/)
yend=(/2064,2069,2074,2079/)

II=0
c=0
do while(c.lt.dimsizes(cmip))
w=0
do while(w.lt.dimsizes(wrfv))

dir="/srv/ccrc/data30/z3393020/NARCliM/filtered/"+cmip(c)+"/"+wrfv(w)+"/2060-2080/d01/"
names(II)=cmip(c)+"-"+wrfv(w)

k=0
len=0
do while(k.lt.dimsizes(ystart))

fname="CCRC_NARCliM_DAY_"+ystart(k)+"-"+yend(k)+"_pracc_fl.nc"
print(dir+fname)
a=addfile(dir+fname,"r")
data=a->pracc_fl
delete(a)
a=dimsizes(data)

n=0
do while(n.lt.a(0))
dayrain(n+len,II,0)=avg(mask(data(n,:,:),ESB_d01,1))
dayrain(n+len,II,1)=max(mask(data(n,:,:),ESB_d01,1))
dayrain(n+len,II,2)=num(mask(data(n,:,:),ESB_d01,1).ge.5)
dayrain(n+len,II,3)=num(mask(data(n,:,:),ESB_d01,1).ge.25)
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

dayrain!0="Day"
dayrain!1="RCM"
dayrain!2="Statistic"
dayrain@description="ESB daily rainfall statistics for 1990-2009"
names!0="RCM"

system("/bin/rm -f "+fout)
out = addfile(fout,"c")
dim_names = (/"Day", "RCM",  "Statistic"  /)
dim_sizes = dimsizes(dayrain)
dimUnlim = (/ True, False, False /)
filedimdef( out, dim_names, dim_sizes, dimUnlim )

out->data = dayrain
out->rcmnames = names
out->varnames = stats

; Delete all the things

delete([/fout,dayrain,names,wrfv,cmip,ystart,yend,out/])
