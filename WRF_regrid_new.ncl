; Next complicated thing - WRF - NCEP?

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

; Regrid the WRF data to the same grid as NCEP

fin=addfile("/home/z3478332/WRF/WRFV3/test/em_real/wrfinput_d01.nc","r")
latW = wrf_user_getvar(fin,"XLAT",-1)
lonW = wrf_user_getvar(fin,"XLONG",-1)

datafile = "daylist2.csv"
dates = asciiread(datafile,-1,"string")
yy = str_get_cols(dates, 0, 3)
mm = str_get_cols(dates, 4, 5)
dd = str_get_cols(dates, 6, 7)

;Probably the easiest domain is going to be 0-50S, 100-180E
lon2=fspan(105,180,31)
lat2=fspan(-50,0,21)
lon1=fspan(105,180,51)
lat1=fspan(-49.5,0,34)
lon0=fspan(105,180,151)
lat0=fspan(-50,0,101)

dirs=(/"/srv/ccrc/data31/z3393020/NARCliM/reanalysis/R1/out/","/srv/ccrc/data29/z3236814/NARCliM/reanalysis/R3/out/","/srv/ccrc/data27/z3393020/WRF_NNRP/R2/1950-2010/out/"/)
type=(/"R1","R3","R2"/)

n=2
i=0
do while(i.lt.dimsizes(yy))
   fout="/srv/ccrc/data23/z3478332/WRF/" + type(n) + "/WRF_slp_" + type(n) + "_" + yy(i) + mm(i) + "_regrid.nc"
   FILES1 = systemfunc (" ls -1 " + dirs(n) + "wrfout_d01_" + yy(i) + "-" + mm(i) +"-??_??:00:00")
   f1 = addfiles(FILES1+".nc","r")
   slp=wrf_user_getvar(f1,"slp",-1)
   slp@lat2d=latW(0,:,:)
   slp@lon2d=lonW(0,:,:)

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
   delete([/slp,slp2,slp3,slp4,slp5,Opt,Opt2,Opt3,f1,FILES1,dim,l/])
end do
