; Next complicated thing - WRF - NCEP?

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

; Regrid the MERRA data

;Probably the easiest domain is going to be 0-50S, 100-180E
lonH=fspan(105,180,76)
latH=fspan(-50,0,51)

datafile = "daylist.csv"
dates = asciiread(datafile,-1,"string")
yy = str_get_cols(dates, 0, 3)
years=ispan(1979,2009,1)

fin="/srv/ccrc/data23/z3444417/Data/MERRA/global/psl/raw/MERRA100.prod.assim.tavg1_2d_slv_Nx.19790101.SUB.nc"
f1=addfile(fin,"r")
latM=f1->latitude
lonM=f1->longitude
slpexample=f1->slp

i=0

do while(i.lt.dimsizes(years))
   I=ind(yy.eq.years(i))
   ddd=dates(I)
   
   if (years(i).le.1992) then 
     nn=100
   else if (years(i).ge.2001) then
     nn=300
   else
     nn=200
   end if
   end if
   
   fout="/srv/ccrc/data23/z3478332/MERRA/MERRA_slp_" + years(i) + "_regrid.nc"
   slp2=new((/4*dimsizes(ddd),dimsizes(latM),dimsizes(lonM)/),typeof(slpexample),"No_FillValue") 
   slp2@lat=latM
   slp2@lon=lonM
   
   j=0
   do while(j.lt.dimsizes(ddd))
     fin="/srv/ccrc/data23/z3444417/Data/MERRA/global/psl/raw/MERRA" + nn + ".prod.assim.tavg1_2d_slv_Nx." + ddd(j) + ".SUB.nc"
     f1=addfile(fin,"r")
     slp=f1->slp
     dim=dimsizes(slp)
     l=dim(0)-1
     slp2((j*4):(j*4+3),:,:)=slp(0:l:6,:,:)
     j=j+1
   end do

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
   slp3@description = "MERRA slp regridded to 1.0x1.0 regular grid"

   out = addfile(fout,"w")
   out->slpH = slp3

   i=i+1
   delete([/slp,slp2,slp3,Opt,f1,ddd,I/])
end do
