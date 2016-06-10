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
   Opt@DstGridLat = lat2
   Opt@DstGridLon = lon2
   Opt@ForceOverwrite = True
   slp3 = ESMF_regrid(slp2,Opt)   ; Do the regridding - 1.5 degrees
   slp3!0   ="time"
   slp3!1   ="lat2"
   slp3!2   ="lon2"
   slp3&lat2 = lat2
   slp3&lon2 = lon2
   slp3@description = "MERRA slp regridded to 2.5x2.5 regular grid"

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
   slp4@description = "MERRA slp regridded to 1.5x1.5 regular grid"
   
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
   slp5@description = "MERRA slp regridded to 0.5x0.5 regular grid"

   system("/bin/rm -f "+fout)
   out = addfile(fout,"c")
   out->slp2 = slp3
   out->slp1 = slp4
   out->slp0 = slp5

   i=i+1
   delete([/slp,slp2,slp3,slp4,slp5,Opt,Opt2,Opt3,f1,ddd,I/])
end do
