load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

f=addfile("wrfinput_2.5.nc","r")
lat1 = f->XLAT
lon1= f->XLONG
topo1 = f->HGT

f=addfile("wrfinput_0.5.nc","r")
msk2 = f->LANDMASK
lat2 = f->XLAT
lon2= f->XLONG
topo2 = f->HGT


   Opt                = True
   Opt@SrcRegional    = True             ; These are necessary
   Opt@DstRegional    = True
   Opt@SrcGridLat = lat1(0,:,:)
   Opt@SrcGridLon = lon1(0,:,:)
   Opt@DstGridLat = lat2(0,:,:)
   Opt@DstGridLon = lon2(0,:,:)
   Opt@ForceOverwrite = True
   topo3 = ESMF_regrid(topo1,Opt)   ; Do the regridding 
   topo3@description = "2.5 degree topo regridded to 0.5 degrees"
   topo3!0 = "Time"
   topo3!1= "south_north"
   topo3!2= "west_east"

   x1D    = ndtooned (topo3)                  ; convert to 1D array
   topo1d = ndtooned (topo2)  
   msk1d  = ndtooned (msk2)  
   imiss  = ind(ismissing(x1D))               ; Missing values equal to v1
   x1D(imiss) = topo1d(imiss)
   imask     = ind(msk1d.eq.0)                  ; Set to 0 if ocean
   x1D(imask)=0
   topo4        = onedtond(x1D, dimsizes(topo3)); Return to 2d
   topo4!0 = "Time"
   topo4!1= "south_north"
   topo4!2= "west_east"

   topo5 = topo2
   topo5(0,24:101,31:128)=topo4(0,24:101,31:128)
   topo5(0,94:101,31:59)=topo2(0,94:101,31:59)

   topo4@description = "2.5 degree topo regridded to 0.5 degrees, with landmask"
   topo5@description = "2.5 degree topo regridded to 0.5 degrees (over aust only)"
   
   out = addfile("WRFtopo_regrid0.5.nc","c")
   out->LANDMASK = msk2
   out->HGT = topo3
   out->HGT_v1 = topo4
   out->HGT_v2=topo5


   
   