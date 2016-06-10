; Next complicated thing - WRF - NCEP?

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

; Regrid the MERRA data

;Probably the easiest domain is going to be 0-50S, 100-180E
lon2=fspan(110,180,29)
lat2=fspan(-50,0,21)
lon1=fspan(111,180,47)
lat1=fspan(-49.5,0,34)
lonH=fspan(110,180,71)
latH=fspan(-50,0,51)
lon0=fspan(110,180,141)
lat0=fspan(-50,0,101)

fin="/srv/ccrc/data28/z3444417/Data/CFSR/global/psl/raw/CFSR_198001.nc"
f1=addfile(fin,"r")
latM=f1->LAT
lat=-latM(:,0)
lonM=f1->LON
lon=lonM(0,:)

yy=ispan(1980,2009,1)
i=0

do while(i.lt.dimsizes(yy))
   fout="/srv/ccrc/data23/z3478332/CFSR/CFSR_slp_" + yy(i) + "_regrid.nc"
   fin="/srv/ccrc/data28/z3444417/Data/CFSR/global/psl/raw/CFSR_" + yy(i) + "01.nc"
   f1=addfile(fin,"r")
   slp=f1->PRMSL
  
   j=2
   do while(j.le.12)
     fin="/srv/ccrc/data28/z3444417/Data/CFSR/global/psl/raw/CFSR_" + yy(i)+ sprinti("%0.2i",j) + ".nc"
     f1=addfile(fin,"r")
     slp2=f1->PRMSL
     slp3=array_append_record(slp,slp2,0)
     delete(slp)
     slp=slp3
     delete([/slp2,slp3/])
     j=j+1
   end do
   dim=dimsizes(slp)
   l=dim(0)-1
   slp2=slp(0:l:6,:,:)
   delete(slp)

   Opt                = True
   Opt@SrcRegional    = True             ; These are necessary
   Opt@DstRegional    = True
   Opt@SrcGridLat = lat
   Opt@SrcGridLon = lon
   Opt@DstGridLat = lat2
   Opt@DstGridLon = lon2
   Opt@ForceOverwrite = True
   slp3 = ESMF_regrid(slp2,Opt)   ; Do the regridding - 1.5 degrees
   slp3!0   ="time"
   slp3!1   ="lat2"
   slp3!2   ="lon2"
   slp3&lat2 = lat2
   slp3&lon2 = lon2
   slp3@description = "CFSR slp regridded to 2.5x2.5 regular grid"

   Opt2                = True
   Opt2@SrcRegional    = True             ; These are necessary
   Opt2@DstRegional    = True
   Opt2@SrcGridLat = lat
   Opt2@SrcGridLon = lon
   Opt2@DstGridLat = lat1
   Opt2@DstGridLon = lon1
   Opt2@ForceOverwrite = True
   slp4 = ESMF_regrid(slp2,Opt2)   ; Do the regridding - 2.5 degrees
   slp4!0   ="time"
   slp4!1   ="lat1"
   slp4!2   ="lon1"
   slp4&lat1 = lat1
   slp4&lon1 = lon1
   slp4@description = "CFSR slp regridded to 1.5x1.5 regular grid"
   
;   Opt3                = True
;   Opt3@SrcRegional    = True             ; These are necessary
;   Opt3@DstRegional    = True
;   Opt3@SrcGridLat = lat
;   Opt3@SrcGridLon = lon
;   Opt3@DstGridLat = lat0
;   Opt3@DstGridLon = lon0
;   Opt3@ForceOverwrite = True
;   slp5 = ESMF_regrid(slp,Opt3)   ; Do the regridding - 0.5 degrees
;   slp5!0   ="time"
;   slp5!1   ="lat0"
;   slp5!2   ="lon0"
;   slp5&lat0 = lat0
;   slp5&lon0 = lon0
;   slp5@description = "CFSR slp regridded to 0.5x0.5 regular grid"

   Opt4                = True
   Opt4@SrcRegional    = True             ; These are necessary
   Opt4@DstRegional    = True
   Opt4@SrcGridLat = lat
   Opt4@SrcGridLon = lon
   Opt4@DstGridLat = latH
   Opt4@DstGridLon = lonH
   Opt4@ForceOverwrite = True
   slp6 = ESMF_regrid(slp2,Opt4)   ; Do the regridding - 1.5 degrees
   slp6!0   ="time"
   slp6!1   ="latH"
   slp6!2   ="lonH"
   slp6&latH = latH
   slp6&lonH = lonH
   slp6@description = "CFSR slp regridded to 1.0x1.0 regular grid"

   system("/bin/rm -f "+fout)
   out = addfile(fout,"c")
   out->slp2 = slp3
   out->slp1 = slp4
;   out->slp0 = slp5
   out->slpH = slp6

   i=i+1
   delete([/slp2,slp3,slp4,slp6,Opt,Opt2,Opt4,f1/])
end do
