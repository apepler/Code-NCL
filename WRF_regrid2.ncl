; Next complicated thing - WRF - NCEP?

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

; Regrid the WRF data to the same grid as NCEP

f1=addfile("/srv/ccrc/data23/z3444417/Data/WRF50/2D/WRF50_Lon.nc","r")
lonW=f1->Lon
f1=addfile("/srv/ccrc/data23/z3444417/Data/WRF50/2D/WRF50_Lat.nc","r")
latW=f1->Lat

;Probably the easiest domain is going to be 0-50S, 100-180E
lon2=fspan(105,180,31)
lat2=fspan(-50,0,21)
lon1=fspan(105,180,51)
lat1=fspan(-49.5,0,34)
lon0=fspan(105,180,151)
lat0=fspan(-50,0,101)

yy=ispan(1979,2009,1)

i=0

do while(i.lt.dimsizes(yy))
   fin="/srv/ccrc/data23/z3444417/Data/WRF50/nnrp/R2/psl/raw/WRF50_nnrp_R2_3h_psl_" + yy(i) + ".nc"
   fout="/srv/ccrc/data23/z3478332/WRF/WRF_slp_" + yy(i) + "_regrid.nc"

   f1=addfile(fin,"r")
   slp=f1->SLP
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
