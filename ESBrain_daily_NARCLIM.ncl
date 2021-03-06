load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

fout="NARCLIM_dayrain_d01_9009.dat"

fin=addfile("ESB_mask.nc","r")
ESB=fin->mask
latA=fin->lat
lonA=fin->lon

fin=addfile("/srv/ccrc/data13/z3393020/Analyses/share/geo_em_files/geo_em.d01.narclim.nc","r")
lat1 = rm_single_dims(wrf_user_getvar(fin,"XLAT_M",-1))
lon1 = rm_single_dims(wrf_user_getvar(fin,"XLONG_M",-1))

dayrain=new((/7305,15/),"float")
wrfv=(/"R1","R2","R3"/)
cmip=(/"NNRP","ECHAM5","CSIRO-MK30","MIROC3.2","CCCMA3.1"/)
runyears=(/"1950-2010","1990-2010","1990-2010","1990-2010","1990-2010"/)

ystart=(/1990,1995,2000,2005/)
yend=(/1994,1999,2004,2009/)

Opt                = True
Opt@SrcRegional    = True             ; These are necessary
Opt@DstRegional    = True
Opt@DstGridLat = latA
Opt@DstGridLon = lonA
Opt@ForceOverwrite = True

II=0
c=0
do while(c.lt.dimsizes(cmip))
w=0
do while(w.lt.dimsizes(wrfv))

dir="/srv/ccrc/data30/z3393020/NARCliM/filtered/"+cmip(c)+"/"+wrfv(w)+"/"+runyears(c)+"/d01/"

k=0
len=0
do while(k.lt.dimsizes(ystart))

fname="CCRC_NARCliM_DAY_"+ystart(k)+"-"+yend(k)+"_pracc_fl.nc"
print(dir+fname)
a=addfile(dir+fname,"r")
data=a->pracc_fl
delete(a)
data@lat2d=lat1
data@lon2d=lon1
a=dimsizes(data)
data2 = ESMF_regrid(data,Opt)   ; Do the regridding - 0.5 degrees

n=0
do while(n.lt.a(0))
dayrain(n+len,II)=avg(mask(data2(n,:,:),ESB,1))
n=n+1
end do
len=len+a(0)

delete([/data,data2,a,fname/])
k=k+1
end do
delete(dir)
II=II+1
w=w+1
end do
c=c+1
end do

opt=True
opt@fout=fout
write_matrix (dayrain, "15f7.2", opt)

; Delete all the things

delete([/fout,dayrain,wrfv,cmip,runyears,ystart,yend,opt@fout/])

fout="NARCLIM_dayrain_d01_6079.dat"
dayrain=new((/7305,12/),"float")
wrfv=(/"R1","R2","R3"/)
cmip=(/"ECHAM5","CSIRO-MK30","MIROC3.2","CCCMA3.1"/)

ystart=(/2060,2065,2070,2075/)
yend=(/2064,2069,2074,2079/)

II=0
c=0
do while(c.lt.dimsizes(cmip))
w=0
do while(w.lt.dimsizes(wrfv))

dir="/srv/ccrc/data30/z3393020/NARCliM/filtered/"+cmip(c)+"/"+wrfv(w)+"/2060-2080/d01/"

k=0
len=0
do while(k.lt.dimsizes(ystart))

fname="CCRC_NARCliM_DAY_"+ystart(k)+"-"+yend(k)+"_pracc_fl.nc"
print(dir+fname)
a=addfile(dir+fname,"r")
data=a->pracc_fl
delete(a)
data@lat2d=lat1
data@lon2d=lon1
a=dimsizes(data)
data2 = ESMF_regrid(data,Opt)   ; Do the regridding - 0.5 degrees

n=0
do while(n.lt.a(0))
dayrain(n+len,II)=avg(mask(data2(n,:,:),ESB,1))
n=n+1
end do
len=len+a(0)

delete([/data,data2,a,fname/])
k=k+1
end do
delete(dir)
II=II+1
w=w+1
end do
c=c+1
end do

opt=True
opt@fout=fout
write_matrix (dayrain, "15f7.2", opt)



