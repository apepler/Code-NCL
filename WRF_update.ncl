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
lonH=fspan(105,180,76)
latH=fspan(-50,0,51)

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
   Opt@DstGridLat = latH
   Opt@DstGridLon = lonH
   Opt@ForceOverwrite = True
   slp3 = ESMF_regrid(slp2,Opt)   ; Do the regridding - 1.5 degrees
   slp3!0   ="time"
   slp3!1   ="latH"
   slp3!2   ="lonH"
   slp3&latH = latH
   slp3&lonH = lonH
   slp3@description = "NCEP-driven WRF slp regridded to 1.0x1.0 regular grid""

   out = addfile(fout,"w")
   out->slpH = slp3

   i=i+1
   delete([/slp,slp2,slp3,Opt,f1/])
end do
