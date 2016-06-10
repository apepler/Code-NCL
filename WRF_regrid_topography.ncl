; Next complicated thing - WRF - NCEP?

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

; Regrid the MERRA data

;Probably the easiest domain is going to be 0-50S, 100-180E
lon2=fspan(105,180,31)
lat2=fspan(-50,0,21)
lon1=fspan(105,180,51)
lat1=fspan(-49.5,0,34)
lon0=fspan(105,180,151)
lat0=fspan(-50,0,101)
lonH=fspan(105,180,76)
latH=fspan(-50,0,51)

fin="WRF/WRFV3/test/em_real/wrfinput_d01.nc"
fout="/srv/ccrc/data23/z3478332/WRF/WRF_topo_regrid.nc"
f1=addfile(fin,"r")
latM=f1->XLAT
lonM=f1->XLONG
hgt=f1->HGT
   hgt@lat2d=latM(0,:,:)
   hgt@lon2d=lonM(0,:,:)

   Opt                = True
   Opt@SrcRegional    = True             ; These are necessary
   Opt@DstRegional    = True
   Opt@DstGridLat = lat2
   Opt@DstGridLon = lon2
   Opt@ForceOverwrite = True
   slp3 = ESMF_regrid(hgt(0,:,:),Opt)   ; Do the regridding - 1.5 degrees
   slp3!0   ="lat2"
   slp3!1   ="lon2"
   slp3&lat2 = lat2
   slp3&lon2 = lon2
   slp3@description = "WRF topography regridded to 2.5x2.5 regular grid"

   Opt2                = True
   Opt2@SrcRegional    = True             ; These are necessary
   Opt2@DstRegional    = True
   Opt2@DstGridLat = lat1
   Opt2@DstGridLon = lon1
   Opt2@ForceOverwrite = True
   slp4 = ESMF_regrid(hgt(0,:,:),Opt2)   ; Do the regridding - 2.5 degrees
   slp4!0   ="lat1"
   slp4!1   ="lon1"
   slp4&lat1 = lat1
   slp4&lon1 = lon1
   slp4@description = "WRF topography regridded to 1.5x1.5 regular grid"
   
   Opt3                = True
   Opt3@SrcRegional    = True             ; These are necessary
   Opt3@DstRegional    = True
   Opt3@DstGridLat = lat0
   Opt3@DstGridLon = lon0
   Opt3@ForceOverwrite = True
   slp5 = ESMF_regrid(hgt(0,:,:),Opt3)   ; Do the regridding - 0.5 degrees
   slp5!0   ="lat0"
   slp5!1   ="lon0"
   slp5&lat0 = lat0
   slp5&lon0 = lon0
   slp5@description = "WRF topography regridded to 0.5x0.5 regular grid"

   Opt6                = True
   Opt6@SrcRegional    = True             ; These are necessary
   Opt6@DstRegional    = True
   Opt6@DstGridLat = latH
   Opt6@DstGridLon = lonH
   Opt6@ForceOverwrite = True
   slp6 = ESMF_regrid(hgt(0,:,:),Opt6)   ; Do the regridding - 1. degrees
   slp6!0   ="latH"
   slp6!1   ="lonH"
   slp6&latH = latH
   slp6&lonH = lonH
   slp6@description = "WRF topography regridded to 1.0x1.0 regular grid"

   system("/bin/rm -f "+fout)
   out = addfile(fout,"c")
   out->hgt2 = slp3
   out->hgt1 = slp4
   out->hgt0 = slp5
   out->hgtH = slp6

   delete([/slp,slp3,slp4,slp5,slp6,Opt,Opt2,Opt3,Opt6,f1/])

