; Next complicated thing - WRF - NCEP?

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

; Regrid the WRF data to the same grid as NCEP

f1=addfile("/srv/ccrc/data23/z3444417/Data/WRF/2D/WRF10_Lon.nc","r")
lonW=f1->Lon
f1=addfile("/srv/ccrc/data23/z3444417/Data/WRF/2D/WRF10_Lat.nc","r")
latW=f1->Lat

;Can only do the very restrictive domain - 25-40S, 140-160E
lon2=fspan(140,157.5,8)
lat2=fspan(-40,-25,7)
lon1=fspan(139.5,160.5,15)
lat1=fspan(-39,-25.5,10)
lon0=fspan(140,159.5,40)
lat0=fspan(-40,-25,31)
lonH=fspan(141,160,20)
latH=fspan(-40,-25,16)

yy=ispan(1979,2009,1)

i=0

do while(i.lt.dimsizes(yy))
   fout="/srv/ccrc/data23/z3478332/WRF10/WRF10_slp_" + yy(i) + "_regrid.nc"
   fin="/srv/ccrc/data23/z3444417/Data/WRF/nnrp/R2/psl/raw/d02/WRF_mslp_R2_d02_" + yy(i) + "-01.nc"
   f1=addfile(fin,"r")
   slp=f1->SLP
   
   j=2
   do while(j.le.12)
     fin="/srv/ccrc/data23/z3444417/Data/WRF/nnrp/R2/psl/raw/d02/WRF_mslp_R2_d02_" + yy(i) + "-" + sprinti("%0.2i",j) + ".nc"
     f1=addfile(fin,"r")
     slp2=f1->SLP
     slp3=array_append_record(slp,slp2,0)
     delete(slp)
     slp=slp3
     delete([/slp2,slp3/])
     j=j+1
   end do

   slp@lat2d=latW
   slp@lon2d=lonW

   dim=dimsizes(slp)
   l=dim(0)-1
   slp2=slp(0:l:2,:,:)

   Opt                = True
   Opt@SrcRegional    = True             ; These are necessary
   Opt@DstRegional    = True
   Opt@DstGridLat = lat2
   Opt@DstGridLon = lon2
   Opt@ForceOverwrite = True
   slp3 = ESMF_regrid(slp2,Opt)   ; Do the regridding - 1.5 degrees
   slp3!0   ="time"
   slp3!1   ="lat2"
   slp3!2   ="lon2"
   slp3&lat2 = lat2
   slp3&lon2 = lon2
   slp3@description = "NCEP-driven WRF slp regridded to 2.5x2.5 regular grid"

   Opt2                = True
   Opt2@SrcRegional    = True             ; These are necessary
   Opt2@DstRegional    = True
   Opt2@DstGridLat = lat1
   Opt2@DstGridLon = lon1
   Opt2@ForceOverwrite = True
   slp4 = ESMF_regrid(slp2,Opt2)   ; Do the regridding - 2.5 degrees
   slp4!0   ="time"
   slp4!1   ="lat1"
   slp4!2   ="lon1"
   slp4&lat1 = lat1
   slp4&lon1 = lon1
   slp4@description = "NCEP-driven WRF slp regridded to 1.5x1.5 regular grid"
   
   Opt3                = True
   Opt3@SrcRegional    = True             ; These are necessary
   Opt3@DstRegional    = True
   Opt3@DstGridLat = lat0
   Opt3@DstGridLon = lon0
   Opt3@ForceOverwrite = True
   slp5 = ESMF_regrid(slp2,Opt3)   ; Do the regridding - 0.5 degrees
   slp5!0   ="time"
   slp5!1   ="lat0"
   slp5!2   ="lon0"
   slp5&lat0 = lat0
   slp5&lon0 = lon0
   slp5@description = "NCEP-driven WRF slp regridded to 0.5x0.5 regular grid"

   system("/bin/rm -f "+fout)
   out = addfile(fout,"c")
   out->slp2 = slp3
   out->slp1 = slp4
   out->slp0 = slp5

   i=i+1
   delete([/slp,slp2,slp3,slp4,slp5,Opt,Opt2,Opt3,f1/])
end do
