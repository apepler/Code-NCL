; Next complicated thing - WRF - NCEP?

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

; Add NCEP, and only want where the lat/lons/time are the same

uwind = addfile("uwnd.mon.mean.nc","r") 
uN = short2flt(uwind->uwnd(372:743,2,56:32,40:72))
vwind = addfile("vwnd.mon.mean.nc","r") 
vN = short2flt(vwind->vwnd(372:743,2,56:32,40:72))
lat=uwind->lat(56:32)
lon=uwind->lon(40:72)

; Regrid the WRF data to the same grid as NCEP

wrf=addfile("WRF_meanwind.nc","r")
U=wrf->U
V=wrf->V
latW= wrf->lat
lonW = wrf->lon
delete(U@lat2d)
delete(U@lon2d)
delete(V@lat2d)
delete(V@lon2d)
U@lat2d=latW
U@lon2d=lonW
V@lat2d=latW
V@lon2d=lonW

; Regridding WRF

Opt                = True
Opt@SrcRegional    = True             ; These are necessary
Opt@DstRegional    = True
Opt@DstGridLat = lat
Opt@DstGridLon = lon
Opt@ForceOverwrite = True
Ugrid = ESMF_regrid(U,Opt)   ; Do the regridding
Vgrid = ESMF_regrid(V,Opt)   ; Do the regridding

; Grids of differences

diffU=Ugrid-uN
diffV=Vgrid-vN
diffU!0="time"
diffV!0="time"
diffU!1="lat"
diffV!1="lat"
diffU!2="lon"
diffV!2="lon"
diffU&lat=lat
diffU&lon=lon
diffV&lat=lat
diffV&lon=lon

  vcres                         = True             ; plot mods desired
  vcres@vcRefLengthF            = 0.05            ; define length of vec ref
  vcres@vcGlyphStyle            = "CurlyVector"    ; turn on curly vectors
  vcres@vcRefMagnitudeF           = 5.0             ; define vector ref mag
  vcres@mpMinLonF = 100
  vcres@mpMaxLonF = 180
  vcres@mpMinLatF = -50
  vcres@mpMaxLatF = 0
  vcres@mpFillOn                   = False               ; turn off gray map
  vcres@mpOutlineDrawOrder         = "PreDraw"           ; draw outline first
  vcres@tiMainFontHeightF = 0.02
  vcres@vcRefAnnoString1 = "$VMG$ m/s"
  vcres@gsnLeftString = ""
  vcres@gsnRightString = ""
  vcres@gsnAddCyclic = False

; Plotty plotty

annU=month_to_annual(diffU,1)
annV=month_to_annual(diffV,1)
wks = gsn_open_wks("pdf","wind_diff_850_7909")
vcres@tiMainString = "WRF-NCEP diff in annual mean wind direction at 850 hPa (1979-2009)"
ave = gsn_csm_vector_map_ce(wks,dim_avg_n_Wrap(annU,0),dim_avg_n_Wrap(annV,0),vcres)
delete(wks)

; Now re-do all the seasonal stuffs

us=runave_n_Wrap(diffU,5,0,0)
vs=runave_n_Wrap(diffV,5,0,0)
uS=us(7:371:12,:,:)
vS=vs(7:371:12,:,:)
wks = gsn_open_wks("pdf","wind_diff_cool_850_7909")
vcres@tiMainString = "WRF-NCEP diff in JJASO mean wind direction at 850 hPa (1979-2009)"
ave = gsn_csm_vector_map_ce(wks,dim_avg_n_Wrap(uS,0),dim_avg_n_Wrap(vS,0),vcres)
delete(wks)
delete(uS)
delete(vS)