; Next complicated thing - WRF - NCEP?

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

tlist=(/"miroc","echam5","cccma","csiromk3"/)

dirsPAST=(/"/srv/ccrc/data11/z3393020/MIROC3.2/R1/1990-2010/out/","/srv/ccrc/data12/z3393020/MIROC3.2/R2/1990-2010/out/","/srv/ccrc/data14/z3393020/MIROC3.2/R3/1990-2010/out/","/srv/ccrc/data20/z3393020/WRF_ECHAM5/R1/1990-2010/out/","/srv/ccrc/data20/z3393020/WRF_ECHAM5/R2/1990-2010/out/","/srv/ccrc/data14/z3393020/WRF_ECHAM5/R3/1990-2010/out/","/srv/ccrc/data21/z3393020/WRF_CCCMA/R1/1990-2010/out/","/srv/ccrc/data24/z3393020/WRF_CCCMA/R2/1990-2010/out/","/srv/ccrc/data21/z3393020/WRF_CCCMA/R3/1990-2010/out/","/srv/ccrc/data25/z3444417/NARCliM/CSIRO-Mk3.0/1990-2009/R1/out/","/srv/ccrc/data23/z3444417/NARCliM/CSIRO-Mk3.0/1990-2009/R2/out/","/srv/ccrc/data26/z3444417/studies/NARCliM/CSIRO-Mk3.0/1990-2009/R3/out/"/)

dirsFUTURE=(/"/srv/ccrc/data17/z3393020/MIROC3.2/R1/2060-2080/out/","/srv/ccrc/data17/z3393020/MIROC3.2/R2/2060-2080/out/","/srv/ccrc/data17/z3393020/MIROC3.2/R3/2060-2080/out/","/srv/ccrc/data20/z3393020/WRF_ECHAM5/R1/2060-2080/out/","/srv/ccrc/data20/z3393020/WRF_ECHAM5/R2/2060-2080/out/","/srv/ccrc/data21/z3393020/WRF_ECHAM5/R3/2060-2080/out/","/srv/ccrc/data21/z3393020/WRF_CCCMA/R1/2060-2080/out/","/srv/ccrc/data26/z3393020/WRF_CCCMA/R2/2060-2080/out/","/srv/ccrc/data25/z3393020/WRF_CCCMA/R3/2060-2080/out/","/srv/ccrc/data27/z3444417/WRF_MK30/R1/2060-2080/out/","/srv/ccrc/data27/z3444417/WRF_MK30/R2/2060-2080/out/","/srv/ccrc/data28/z3444417/NARCliM/mk30/R3/2060-2080/out/"/)

f2=addfile("/srv/ccrc/data30/z3393020/NARCliM/postprocess/1990-2009/ECHAM5/R2/d01/CCRC_NARCliM_MON_2000-2009_tasmax.nc","r")
rot=f2->Rotated_pole
lat=f2->lat
lat2=ndtooned(lat)
lon=f2->lon
lon2=ndtooned(lon)
dist=new(dimsizes(lon2),"float")
dir=dist
zNew=new((/dimsizes(lon2),3/),"float")
levlist=(/900.0,600.0,300.0/)  

; This will eventually be a loop

cmip=0
do while(cmip.lt.dimsizes(tlist))
wrf=0
do while(wrf.lt.3)
i=cmip*3+wrf
idir="/srv/ccrc/data34/z3478332/CMIP-WRF-ECLs/outputUM/proj100/outputUM_"+tlist(cmip)+"_WRFR"+(wrf+1)+"_50_rad2cv06/"
filename=idir+"ECLfixes_umelb_"+tlist(cmip)+"_wrfR"+(wrf+1)+"_proj100_rad2cv0.8_9009.csv"

; FIRST - Load in the ECL data

  values_1d = asciiread(filename,-1,"string")
  header    = values_1d(0)        ; Header. Use for variable names.
  data1      = values_1d(1:)       ; Get rid of first line which is a header.

  data = new((/dimsizes(data1),15/),"float")
n=0
do while(n.lt.11)
  if(n.eq.3) then
    dum=str_get_field(data1,n+2,",")
    dum = str_sub_str(dum,str_get_dq(),"")   ; Replace quotes with blank 
    data(:,n)=tofloat(str_get_field(dum,1,":"))
  else
    data(:,n)=tofloat(str_get_field(data1,n+2,","))
  end if
  n=n+1
end do

dates=str_get_field(data1,4,",")
yy=tointeger(str_get_cols(dates, 0, 3))
a=ind(yy.gt.2018)
yy(a)=yy(a)-20
delete(a)
mm=tointeger(str_get_cols(dates, 4, 5))
dd=tointeger(str_get_cols(dates, 6, 7))
hh=data(:,3)

k=0
do while(k.lt.dimsizes(yy))
if(mod(k,100).eq.0) then
  print(k)
end if

  FILES1 = systemfunc (" ls -1 " + dirsPAST(i) + "wrfout_d01_"+yy(k)+"-"+sprinti("%0.2i",mm(k))+"-"+sprinti("%0.2i",dd(k))+"_??:00:00")
  f1 = addfile(FILES1+".nc","r")
  times = wrf_user_getvar(f1,"times",-1)
  hhW = stringtointeger(str_get_cols(times, 11, 12))

  a=ind(hhW.eq.hh(k))
  z = wrf_user_getvar(f1,"z",a)
  p = wrf_user_getvar(f1,"pressure",a)
  delete([/a,f1,times,hhW,FILES1/])
  tt=0
  do while(tt.lt.dimsizes(levlist))
    zNew(:,tt) =ndtooned(wrf_user_intrp3d(z,p,"h",levlist(tt),0.,False))
    tt=tt+1
  end do

  tt=0
  do while(tt.lt.dimsizes(lat2))
    dist(tt)=gc_latlon(lat2(tt),lon2(tt),data(k,6),data(k,5),2,4)
    dir(tt)=180+atan2(data(k,5)-lon2(tt),data(k,6)-lat2(tt))*45.0/atan(1.0)
    tt=tt+1
  end do

  a=ind(dist<500)     
  zPert=dim_max_n(zNew(a,:),0)-dim_min_n(zNew(a,:),0)
  data(k,11)=(zPert(2)-zPert(1))/(log(300)-log(600)) ;VU
  data(k,12)=(zPert(1)-zPert(0))/(log(600)-log(900)) ;Vl
  data(k,13)=(zPert(2)-zPert(0))/(log(300)-log(900)) ; Vt
  delete(a)

; Now for the hard part - calculating B!

  if(data(k,1).ne.1) then
    dir1=180+atan2(data(k,5)-data(k-1,5),data(k,6)-data(k-1,6))*45.0/atan(1.0)

    ; So if dir1=dir, they're on the same line
    ; dir< dir1 < dir+180 = LEFT
    ; dir-180<dir1<dir = RIGHT

    b=mod((dir-dir1)+360,360)
    left=ind(b.lt.180.and.dist.lt.500)
    right=ind(b.gt.180.and.dist.lt.500)

    ; B = mean (600-900)L - mean(600-900)R
    data(k,14)=avg(zNew(left,1)-zNew(left,0))-avg(zNew(right,1)-zNew(right,0))
    delete([/b,left,right/])
  end if
  delete([/z,p/])
k=k+1
end do
 
fout=idir+"ECLfixes_umelb_"+tlist(cmip)+"_wrfR"+(wrf+1)+"_proj100_rad2cv0.8_9009_warmcold.txt"

   opt = True
   opt@title  = "       ID       Fix        VU        VL        VT         B"
   opt@fout = fout
   data2=data(:,(/0,1,11,12,13,14/)) ; Only the necessary parts, as the dates went weird

   data2@_FillValue = 9999.99             ; change to some value
   write_matrix (data2, "2f10.1,4f10.3", opt)

delete([/data,data1,data2,opt,fout,values_1d,header/])
delete([/idir,filename,dum,dates,yy,mm,dd,hh/])
wrf=wrf+1
end do
cmip=cmip+1
end do

