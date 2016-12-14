; plot the NARCliM/CORDEX WRF topography
;
load "$NCARG_LIB/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_LIB/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_LIB/ncarg/nclscripts/csm/contributed.ncl"
;load "~/ncl/maplabels.ncl"

begin

diri = "/srv/ccrc/data13/z3393020/Analyses/share/geo_em_files/"
diro = "~/"

;CORDEX AUSTRALASIA
f1 = addfile(diri+"geo_em.d01.narclim.nc" , "r")

lat2d1 = f1->XLAT_M(0,:,:)
lon2d1 = f1->XLONG_M(0,:,:)
pole_lat1 = f1@POLE_LAT
pole_lon1 = f1@POLE_LON
cen_lat1 = f1@CEN_LAT
cen_lon1 = f1@CEN_LON

dsize1 = dimsizes(lat2d1)

;convert lon2d to be 0->360 not -180->180
lon2d1 = where(lon2d1.lt.0,360.+lon2d1,lon2d1)

lat11 = lat2d1(0,0)
lat21 = lat2d1(dsize1(0)-1,dsize1(1)-1)
lon11 = lon2d1(0,0)
lon21 = lon2d1(dsize1(0)-1,dsize1(1)-1)

lon2d1@lat2d = lat2d1
lon2d1@lon2d = lon2d1

topo = f1->HGT_M(0,:,:)
topo@lat2d = lat2d1
topo@lon2d = lon2d1

landmask1 = f1->LANDMASK(0,:,:)
var1 = mask(topo,landmask1.eq.1,True)

f = addfile(diri+"geo_em.d02.narclim.nc" , "r")
lat2d = f->XLAT_M(0,:,:)
lon2d = f->XLONG_M(0,:,:)
dsize = dimsizes(lat2d)

wks = gsn_open_wks ("pdf", diro+"Figure1_domain_v2")
gsn_define_colormap (wks,"WhViBlGrYeOrReWh") ; COLOR

res = True
; res@gsnMaximize = True

res@gsnDraw = False
res@gsnFrame = False

res@gsnSpreadColors = True
res@gsnSpreadColorStart = 44
res@gsnSpreadColorEnd = 79

res@mpLimitMode = "Corners"
res@mpLeftCornerLatF = lat11
res@mpLeftCornerLonF = lon11
res@mpRightCornerLatF = lat21
res@mpRightCornerLonF = lon21

res@mpProjection = "CylindricalEquidistant"
res@mpCenterRotF = -3.
res@mpCenterLatF = pole_lat1-90.0
res@mpCenterLonF = pole_lon1-180.0

res@mpOutlineDrawOrder = "PostDraw" ; force map tp be drawn 1st
res@mpGridLineDashPattern = 2 ; lat/lon lines as dashed
res@mpPerimOn = True
res@mpPerimDrawOrder = "PostDraw"
res@mpOutlineOn = True
res@mpGridAndLimbOn = True
res@mpGridSpacingF = 10.
res@pmTickMarkDisplayMode = "Always"
res@tmXTLabelsOn = False
res@tmYRLabelsOn = False

res@mpOutlineBoundarySets = "National"
res@mpGeophysicalLineThicknessF = 1.5
res@mpDataBaseVersion = "MediumRes"
res@mpDataSetName = "Earth..4"
res@mpOutlineSpecifiers = "Australia:states"
res@mpGridMaskMode        = "MaskLand"

res@gsnRightString = ""
  res@gsnAddCyclic         = False           ; don't add longitude cyclic point
  res@mpOceanFillColor     = "white"
  res@mpLandFillColor      = -1
;  res@mpFillDrawOrder      = "PreDraw"
  res@tfDoNDCOverlay = True

res@cnFillOn = True ; color fill
res@cnLinesOn = False
res@cnLineLabelsOn = False
res@cnFillDrawOrder = "PreDraw"

res@gsnAddCyclic = False
res@lbOrientation = "Vertical"
res@lbTitleString = "m"
res@lbLabelStride = 2
res@lbLabelFontHeightF = 0.02
res@gsnLeftString=""

 res@cnLevelSelectionMode = "ManualLevels"
res@cnMinLevelValF = 200.0
res@cnMaxLevelValF = 1400.0
 res@cnLevelSpacingF = 100.0
 
 res@mpGridAndLimbDrawOrder = "Draw"

map = gsn_csm_contour_map(wks,topo,res) ; Draw contours over a map.

resline = True
resline@gsLineColor = "black"
resline@gsLineThicknessF = 4.0

spc = 0 ;number rows/cols to ignore
boxlons1 = (/lon2d(spc,spc),lon2d(dsize(0)-1-spc,spc),lon2d(dsize(0)-1-spc,(dsize(1)-1)/2),lon2d(dsize(0)-1-spc,dsize(1)-1-spc),lon2d(spc,dsize(1)-1-spc),lon2d(spc,(dsize(1)-1)/2),lon2d(spc,spc)/)
boxlats1 = (/lat2d(spc,spc),lat2d(dsize(0)-1-spc,spc),lat2d(dsize(0)-1-spc,(dsize(1)-1)/2),lat2d(dsize(0)-1-spc,dsize(1)-1-spc),lat2d(spc,dsize(1)-1-spc),lat2d(spc,(dsize(1)-1)/2),lat2d(spc,spc)/)

dum = gsn_add_polyline(wks,map,boxlons1,boxlats1,resline)

resline2 = True
resline2@gsLineColor = "blue"
resline2@gsLineThicknessF = 4.0
resline2@gsLineDashPattern = 2

dum2=gsn_add_polyline(wks,map,(/149,161,161,152,152,149,149/),(/-41,-41,-24,-24,-31,-37,-41/),resline2)

draw(wks)
frame(wks)

end

