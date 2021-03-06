load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
;load "./WRFUserARW.ncl"

begin

  month=6

  DATADir = "/srv/ccrc/data36/z3478332/WRF/output/ERAI_R2_nonudge_nznoland/out/"
  CONTDir = "/srv/ccrc/data36/z3478332/WRF/output/ERAI_R2_nonudge/out/"
  OUTDir=DATADir
  outfile=OUTDir+"D01_prlr_nznoland_nonudge"

diri = "/srv/ccrc/data13/z3393020/Analyses/share/geo_em_files/"
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


  wks = gsn_open_wks("pdf", outfile+"_1monthanom")  ; Open graphics file
      gsn_define_colormap(wks,"precip_diff_12lev")                ; choose colormap
  res                 = True
; Set some contouring resources.
  res@cnFillOn        = True
  res@cnLinesOn       = False
  res@cnLineLabelsOn  = False
  res@cnInfoLabelOn   = False
  res@cnLevelSelectionMode = "ExplicitLevels"
  res@cnLevels             = (/ -200.,-100., -50., -25., -10., -5., 5., 10., 25., 50.,100.,200./)
  res@gsnDraw         = False
  res@gsnFrame        = False

; Add map resources
  res@mpFillOn              = False
  res@mpDataBaseVersion     = "MediumRes"          ; Default is LowRes
  res@mpOutlineDrawOrder    = "PostDraw"           ; Draw map outlines last
  res@mpGridAndLimbOn       = False                ; Turn off lat/lon lines
  res@pmTickMarkDisplayMode = "Always"             ; Turn on map tickmarks
;  res = set_mp_wrf_map_resources(f1[0],res)
res@mpLimitMode = "Corners"
res@mpLeftCornerLatF = lat11
res@mpLeftCornerLonF = lon11
res@mpRightCornerLatF = lat21
res@mpRightCornerLonF = lon21

res@mpProjection = "CylindricalEquidistant"
res@mpCenterRotF = -3.
res@mpCenterLatF = pole_lat1-90.0
res@mpCenterLonF = pole_lon1-180.0
    res@mpGridLineDashPattern = 2
  res@mpGridLineThicknessF = 0.5
  
; Add label bar resources
  res@lbLabelAutoStride = True 
  res@lbBoxMinorExtentF        = 0.13
  res@lbLabelFontHeightF       = 0.012

  res@gsnLeftStringFontHeightF = 0.01
  res@gsnRightStringFontHeightF = 0.008
  res@gsnMaximize     = True    ; Maximize plot in frame

  i=month

  f1 = addfile(DATADir+"wrfhrly_d01_2007-"+sprinti("%0.2i",i)+"-01_00:00:00.nc","r")
  f1a = addfile(CONTDir+"wrfhrly_d01_2007-"+sprinti("%0.2i",i)+"-01_00:00:00.nc","r")
  times = wrf_user_getvar(f1,"times",-1)
  len=dimsizes(times)-1 

  rain_exp1a=wrf_user_getvar(f1,"RAINNC",len)
  rain_exp1b=wrf_user_getvar(f1,"RAINNC",0)
  rain_con1a=wrf_user_getvar(f1,"RAINC",len)
  rain_con1b=wrf_user_getvar(f1,"RAINC",0)
  var_in_dir = rain_exp1a + rain_con1a -rain_exp1b - rain_con1b
 
  rain_exp1a=wrf_user_getvar(f1a,"RAINNC",len)
  rain_exp1b=wrf_user_getvar(f1a,"RAINNC",0)
  rain_con1a=wrf_user_getvar(f1a,"RAINC",len)
  rain_con1b=wrf_user_getvar(f1a,"RAINC",0)
  var_in_cont = rain_exp1a + rain_con1a -rain_exp1b - rain_con1b

    var1 = (var_in_dir-var_in_cont)
    var1@description = "Total Precipitation Difference in month "+i
    var1@units = "mm"
    var1@lat2d = lat2d1
    var1@lon2d = lon2d1
    map = gsn_csm_contour_map(wks, var1, res)
    draw(map)
    frame(wks)

   delete(times) 

delete(wks)
end


