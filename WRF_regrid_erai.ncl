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

datafile = "daylist3a.csv"
dates = asciiread(datafile,-1,"string")
yy = str_get_cols(dates, 0, 3)
mm = str_get_cols(dates, 4, 5)
dd = str_get_cols(dates, 6, 7)

;Probably the easiest domain is going to be 0-50S, 100-180E
lon0=fspan(105,180,151)
lat0=fspan(-50,0,101)
type=(/"ERA-nudge","ERA-nonudge"/)

dirs=(/"/srv/ccrc/data40/z3444417/CCRC_WRF3-6-0-5_SEB/ERA-Interim/R2/out/","/srv/ccrc/data33/z3481416/CCRC-WRF3.6.0.5-SEB/ERA-Interim/R2_nudging/out/"/)

n=0
do while(n.lt.dimsizes(dirs))
print(dirs(n))
i=0
do while(i.lt.dimsizes(yy))
   if(mm(i).eq."01") then
    print(yy(i)) 
   end if   
   fout="/srv/ccrc/data34/z3478332/WRF/" + type(n) + "/WRF_slp_R2_" + yy(i) + mm(i) + "_regrid.nc"
   FILES1 = systemfunc (" ls -1 " + dirs(n) + "wrfout_d01_" + yy(i) + "-" + mm(i) +"-??_??:00:00")
   f1 = addfiles(FILES1+".nc","r")
   slp=wrf_user_getvar(f1,"slp",-1)
   slp@lat2d=latW(0,:,:)
   slp@lon2d=lonW(0,:,:)

   dim=dimsizes(slp)
   l=dim(0)-1
   slp2=slp(0:l:2,:,:)
   
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
   out->slp0 = slp5

   i=i+1
   delete([/slp,slp2,slp5,Opt3,f1,FILES1,dim,l/])
end do
n=n+1
end do

