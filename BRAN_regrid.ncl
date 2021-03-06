; Next complicated thing - WRF - NCEP?

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

  INDIR="/srv/ccrc/data36/z3478332/WRF/DATA/BRAN/"
  year=2007
  infile=INDIR+"bran3p5_sst_"+year+".nc"
  outfile=INDIR+"bran3p5_sst_"+year+"_noeac.nc"

  f1=addfile(infile,"r")
  lat=f1->yt_ocean
  lon=f1->xt_ocean
  time=f1->Time
  sst=short2flt(f1->temp)

  infile=INDIR+"bran3p5_sst_"+(year-1)+".nc"
  f1=addfile(infile,"r")
  len=dimsizes(f1->Time)-1
  sst1=short2flt(f1->temp((len-13):len,:,:,:)) ; Prev 14
  infile=INDIR+"bran3p5_sst_"+(year+1)+".nc"
  f1=addfile(infile,"r")
  sst2=short2flt(f1->temp(0:13,:,:,:)) ; Subs 14

  SST=array_append_record(array_append_record(sst1,sst,0),sst2,0) ; Extended to +- 14 days

  I=ind(lon.le.165..and.lon.ge.160)
  sstA=dim_avg_n_Wrap(SST(:,:,:,I),3) ;Average across 160-165 for day

  dailydiff=SST
  i=0
  do while(i.lt.dimsizes(lon))
    dailydiff(:,:,:,i)=SST(:,:,:,i)-sstA ; Difference between SST and our band
    i=i+1
  end do
  diff14=runave_n_Wrap(dailydiff,29,0,0) ; Running average differences
  diff7=runave_n_Wrap(dailydiff,15,0,0) 
  diff3=runave_n_Wrap(dailydiff,7,0,0) 

  dd=dimsizes(SST)
  diff0a=dailydiff(14:(dd(0)-15),:,:,:) ; Just the 365 days of the year
  diff14a=diff14(14:(dd(0)-15),:,:,:) 
  diff7a=diff7(14:(dd(0)-15),:,:,:)
  diff3a=diff3(14:(dd(0)-15),:,:,:)

  delete([/len,dd,diff14,diff7,diff3,dailydiff,SST,sst1,sst2,sstA,I/])

  ; Replace point points 140-160,50-20 with the latitudinal mean where above average
  sst3=sst
  sst7=sst
  sst14=sst
  i=0
  b=ind(lat.ge.-50..and.lat.le.-20.)
  do while(i.lt.dimsizes(b))
    j=0
    do while(j.lt.dimsizes(time))
      sst3(j,0,b(i),:)=where(diff0a(j,0,b(i),:).gt.0..and.lon.ge.140..and.lon.le.160.,sst3(j,0,b(i),:)-diff3a(j,0,b(i),:),sst3(j,0,b(i),:))
      sst7(j,0,b(i),:)=where(diff0a(j,0,b(i),:).gt.0..and.lon.ge.140..and.lon.le.160.,sst7(j,0,b(i),:)-diff7a(j,0,b(i),:),sst7(j,0,b(i),:))
      sst14(j,0,b(i),:)=where(diff0a(j,0,b(i),:).gt.0..and.lon.ge.140..and.lon.le.160.,sst14(j,0,b(i),:)-diff14a(j,0,b(i),:),sst14(j,0,b(i),:))
      j=j+1
    end do
    i=i+1
  end do
  copy_VarMeta(sst,sst14)
  copy_VarMeta(sst,sst7)
  copy_VarMeta(sst,sst3)
  ;v2 - regrid to 2.5 degrees then back

  lat0=fspan(-70,70,57)
  lon0=fspan(2.5,357.5,143)
;  sst4=new(dimsizes(sst),typeof(sst),sst@_FillValue)
  sstCoarse=new((/dimsizes(time),1,dimsizes(lat0),dimsizes(lon0)/),typeof(sst),sst@_FillValue)

; make the coarse ssts
  i=0
  do while(i.lt.dimsizes(lat0))
    I=ind(lat.ge.(lat0(i)-1.25).and.lat.le.(lat0(i)+1.25))
    j=0
    do while(j.lt.dimsizes(lon0))
       J=ind(lon.ge.(lon0(j)-1.25).and.lon.le.(lon0(j)+1.25))
       if(dimsizes(I).gt.1.and.dimsizes(J).gt.1) then
          sstCoarse(:,0,i,j)=dim_avg_n_Wrap(sst(:,0,I,J),(/1,2/))
       else if(dimsizes(I).gt.1.or.dimsizes(J).gt.1) then
          sstCoarse(:,0,i,j)=dim_avg_n_Wrap(sst(:,0,I,J),1)
       else
          sstCoarse(:,0,i,j)=sst(:,0,I,J)
       end if
       end if
       delete(J)
       j=j+1
    end do
    delete(I)
    i=i+1
  end do

  sstCoarse!0 = "Time"
  sstCoarse!1 = "st_ocean"
  sstCoarse!2 = "lat0"
  sstCoarse!3 = "lon0"
  sstCoarse&lat0=lat0
  sstCoarse&lon0=lon0
  copy_VarAtts(sst,sstCoarse)

; Why regrid when already doing in other code?
;  Opt3                = True
;  Opt3@SrcRegional    = True             ; These are necessary
;  Opt3@DstRegional    = True
;  Opt3@DstGridLat = lat
;  Opt3@DstGridLon = lon
;  Opt3@ForceOverwrite = True
;  sst3 = ESMF_regrid(sstCoarse,Opt3)   ; Do the regridding - 0.5 degrees
;  copy_VarMeta(sst,sst3)

   system("/bin/rm -f "+outfile)
   out = addfile(outfile,"c")
   out->sst_NoEac_14 = pack_values(sst14,"short",False)
   out->sst_NoEac_7 = pack_values(sst7,"short",False)
   out->sst_NoEac_3 = pack_values(sst3,"short",False) 
   out->Time = time
;   out->sst_Coarse = pack_values(sstCoarse,"short",False)



