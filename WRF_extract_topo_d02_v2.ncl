; Next complicated thing - WRF - NCEP?

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"


  f1=addfile("/srv/ccrc/data36/z3478332/WRF/geogrid/geo_em.d01.default.nc","r")
  lat1=f1->XLAT_M(0,:,:)
  lon1=f1->XLONG_M(0,:,:)
  topo1=f1->HGT_M(0,:,:)
  topo1@lat2d=lat1
  topo1@lon2d=lon1

  f2=addfile("/srv/ccrc/data36/z3478332/WRF/geogrid/geo_em.d02.default.nc","r")
  lat2=f2->XLAT_M(0,:,:)
  lon2=f2->XLONG_M(0,:,:)
  topo2=f2->HGT_M(0,:,:)
  topo2@lat2d=lat2
  topo2@lon2d=lon2
  lon0=fspan(140,170,301)
  lat0=fspan(-50,-15,351)

   Opt3                = True
   Opt3@SrcRegional    = True             ; These are necessary
   Opt3@DstRegional    = True
   Opt3@DstGridLat = lat0
   Opt3@DstGridLon = lon0
   Opt3@ForceOverwrite = True

  topo1a = ESMF_regrid(topo1,Opt3)
  topo1a!0   ="lat0"
  topo1a!1   ="lon0"
  topo1a&lat0 = lat0
  topo1a&lon0 = lon0
  topo1a@description = "WRF d01 topo regridded to 0.1x0.1 regular grid"

  topo2a = ESMF_regrid(topo2,Opt3)
  copy_VarMeta(topo1a,topo2a)
  topo3 = where(ismissing(topo2a),topo1a,topo2a)
  copy_VarMeta(topo1a,topo3)


   system("/bin/rm -f /srv/ccrc/data36/z3478332/WRF/WRF_topo_d01_v2.nc")
   out = addfile("/srv/ccrc/data36/z3478332/WRF/WRF_topo_d01_v2.nc","c")
   out->hgt0 = topo1a
   delete(out)

   system("/bin/rm -f /srv/ccrc/data36/z3478332/WRF/WRF_topo_d02_v2.nc")
   out = addfile("/srv/ccrc/data36/z3478332/WRF/WRF_topo_d02_v2.nc","c")
   out->hgt0 = topo3
   delete(out)

 
