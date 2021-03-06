load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

; First, the general WRF stuff
  BDIR="/srv/ccrc/data36/z3478332/WRF/DATA/BRAN/"
  fin=addfile("/srv/ccrc/data13/z3393020/Analyses/share/geo_em_files/geo_em.d01.narclim.nc","r")
  latW = wrf_user_getvar(fin,"XLAT_M",0)
  lonW = wrf_user_getvar(fin,"XLONG_M",0)
  lonW1=where(lonW.lt.0,lonW+360,lonW) ;Because BRAN is 0-360
;  maskW = 1-(fin->LANDMASK(0,:,:))
   delete(fin)

  fin=addfile("/srv/ccrc/data13/z3393020/Analyses/share/geo_em_files/geo_em.d02.narclim.nc","r")
  latWa = wrf_user_getvar(fin,"XLAT_M",0)
  lonWa = wrf_user_getvar(fin,"XLONG_M",0)
  lonWa1=where(lonWa.lt.0,lonWa+360,lonWa) ;Because BRAN is 0-360
;  maskW = 1-(fin->LANDMASK(0,:,:))
   delete(fin)

  lat0=fspan(-70,70,57)
  lon0=fspan(2.5,357.5,143)
  year=2007
  month=1

  do while(month.le.12)

files=(/BDIR+"bran3p5_sst_"+(year-1)+".nc",BDIR+"bran3p5_sst_"+(year)+".nc",BDIR+"bran3p5_sst_"+(year+1)+".nc"/)

;Loading the three bluelink daily files & combining
fin=addfiles(files,"r")
lonB = fin[0]->xt_ocean
latB = fin[0]->yt_ocean
time = fin[:]->Time
date=cd_calendar(time,-5)

a=ind(date(:,0).eq.year.and.date(:,1).eq.month)
; Okay, so, we want all the days of the month + one on either side

  sstB  = short2flt(fin[:]->temp((a(0)-1):(a(dimsizes(a)-1)+1),0,:,:))
  len2=dimsizes(sstB)
;  sst4=new(dimsizes(sst),typeof(sst),sst@_FillValue)
  sstCoarse=new((/len2(0),dimsizes(lat0),dimsizes(lon0)/),typeof(sstB),sstB@_FillValue)

; make the coarse ssts
  i=0
  do while(i.lt.dimsizes(lat0))
    I=ind(latB.ge.(lat0(i)-1.25).and.latB.le.(lat0(i)+1.25))
    j=0
    do while(j.lt.dimsizes(lon0))
       J=ind(lonB.ge.(lon0(j)-1.25).and.lonB.le.(lon0(j)+1.25))
       if(dimsizes(I).gt.1.and.dimsizes(J).gt.1) then
          sstCoarse(:,i,j)=dim_avg_n_Wrap(sstB(:,I,J),(/1,2/))
       else if(dimsizes(I).gt.1.or.dimsizes(J).gt.1) then
          sstCoarse(:,i,j)=dim_avg_n_Wrap(sstB(:,I,J),1)
       else
          sstCoarse(:,i,j)=sstB(:,I,J)
       end if
       end if
       delete(J)
       j=j+1
    end do
    delete(I)
    i=i+1
  end do

  sstCoarse!0 = "Time"
  sstCoarse!1 = "lat"
  sstCoarse!2 = "lon"
  sstCoarse&lat=lat0
  sstCoarse&lon=lon0

  delete(len2)
  len2=dimsizes(sstCoarse)

; Making the file with interpolated daily data
; v1: Goes from 12Z to 12Z, which is easier for averaging
  
  len3=dimsizes(a)*4+5
  sstB2 = new((/len3,len2(1),len2(2)/),typeof(sstB),sstB@_FillValue)
  sstB2@lon=lonB
  sstB2@lat=latB

; Do silly averaging to convert to 6-hourly. Better will have to incorporate months on either side
  sstB2(0:(len3-1):4,:,:)=sstCoarse
  sstB2(2:(len3-3):4,:,:)=(sstCoarse(0:(len2(0)-2),:,:)+sstCoarse(1:(len2(0)-1),:,:))/2
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
   Opt@SrcGridLat = lat0
   Opt@SrcGridLon = lon0
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

fW="/srv/ccrc/data36/z3478332/WRF/WRF_boundary/default_bran_2007_coarseSST/wrflowinp_d01_"+year+"-"+sprinti("%2.2i",month)+".nc" 
out=addfile(fW,"w")
sstW  = out->SST

sstB7=where(sstW.eq.0,0,sstB6)
copy_VarMeta(sstW,sstB7)
delete(sstB7@_FillValue)
out->SST = sstB7

delete([/Opt@DstGridLat,Opt@DstGridLon,sstB4,sstB5,sstB6,sstB7/])
delete([/fW,sstW/])
   
Opt@DstGridLat = latWa
Opt@DstGridLon = lonWa

Opt@InterpMethod="bilinear"
sstB4=ESMF_regrid(sstB3,Opt)+273.15
Opt@InterpMethod="neareststod"
sstB5=ESMF_regrid(sstB3,Opt)+273.15

sstB6=where(ismissing(sstB4),sstB5,sstB4)

fW="/srv/ccrc/data36/z3478332/WRF/WRF_boundary/default_bran_2007_coarseSST/wrflowinp_d02_"+year+"-"+sprinti("%2.2i",month)+".nc" 
out=addfile(fW,"w")
sstW  = out->SST

sstB7=where(sstW.eq.0,0,sstB6)
copy_VarMeta(sstW,sstB7)
delete(sstB7@_FillValue)
out->SST = sstB7

delete([/out,fW,fin,lonB,latB,time,date,len2,len3/])
delete([/a,b,maskB,Opt,sstW/])
delete([/sstB,sstCoarse,sstB2,sstB3,sstB4,sstB5,sstB6,sstB7/])

month=month+1
end do


