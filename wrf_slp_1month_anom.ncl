load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
;load "./WRFUserARW.ncl"

  month=2
  year=1989

DATADir="/srv/ccrc/data23/z3478332/WRF/output/ERAI_R2_control_NEMOSST/out/"
CONTDir="/srv/ccrc/data23/z3478332/WRF/output/ERAI_R2_control_ERAISST/out/"

;  DATADir = "/srv/ccrc/data36/z3478332/WRF/output/ERAI_R2_nonudge_nznoland/out/"
;  CONTDir = "/srv/ccrc/data36/z3478332/WRF/output/ERAI_R2_nonudge/out/"
  OUTDir=DATADir
  outfile=OUTDir+"D01_slp_sstchange"

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
delete(f1)

  wks = gsn_open_wks("pdf", outfile+"_1monthanom")  ; Open graphics file
      gsn_define_colormap(wks,"precip_diff_12lev")                ; choose colormap
  res                 = True
; Set some contouring resources.
  res@cnFillOn        = True
  res@cnLinesOn       = False
  res@cnLineLabelsOn  = False
  res@cnInfoLabelOn   = False
  res@cnLevelSelectionMode = "ExplicitLevels"
  res@cnLevels             = (/ -3.,-2.,-1.5, -1., -0.5, -0.1,0.1, 0.5, 1., 1.5, 2.,3./)
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

 
; Add label bar resources
  res@lbLabelAutoStride = True 
  res@lbBoxMinorExtentF        = 0.13
  res@lbLabelFontHeightF       = 0.012

  res@gsnLeftStringFontHeightF = 0.01
  res@gsnRightStringFontHeightF = 0.008
  res@gsnMaximize     = True    ; Maximize plot in frame

  i=month

  FILES1 = systemfunc (" ls -1 " + DATADir + "wrfout_d01_"+year+"-"+sprinti("%0.2i",month)+"-??_??:00:00")
  f1 = addfiles(FILES1+".nc","r")
  FILES1a = systemfunc (" ls -1 " + CONTDir + "wrfout_d01_"+year+"-"+sprinti("%0.2i",month)+"-??_??:00:00")
  f1a = addfiles(FILES1a+".nc","r")


  slp1 = wrf_user_getvar(f1,"slp",-1)    ; slp
  wrf_smooth_2d( slp1, 3 )            ; smooth slp

  slp2 = wrf_user_getvar(f1a,"slp",-1)    ; slp
  wrf_smooth_2d( slp2, 3 )            ; smooth slp

    var1 = (dim_avg_n_Wrap(slp1,0)-dim_avg_n_Wrap(slp2,0))
    var1@description = "MSLP and 1000-hPa wind difference"
    var1@lat2d = lat2d1
    var1@lon2d = lon2d1
    map = gsn_csm_contour_map(wks, var1, res)
    draw(map)
    frame(wks)
delete(wks)

uv1=wrf_user_getvar(f1,"uvmet",-1)    ; uv
p1 = wrf_user_getvar(f1,"pressure",-1)
u1 = wrf_user_intrp3d(uv1(0,:,:,:,:),p1,"h",1000.0,0.,False)
v1 = wrf_user_intrp3d(uv1(1,:,:,:,:),p1,"h",1000.0,0.,False)

uv2=wrf_user_getvar(f1a,"uvmet",-1)    ; uv
p2 = wrf_user_getvar(f1,"pressure",-1)
u2 = wrf_user_intrp3d(uv2(0,:,:,:,:),p2,"h",1000.0,0.,False)
v2 = wrf_user_intrp3d(uv2(1,:,:,:,:),p2,"h",1000.0,0.,False)

udiff = (dim_avg_n_Wrap(u1,0)-dim_avg_n_Wrap(u2,0))
    udiff@units = "m/s"
    udiff@lat2d = lat2d1
    udiff@lon2d = lon2d1
vdiff = (dim_avg_n_Wrap(v1,0)-dim_avg_n_Wrap(v2,0))
    vdiff@units = "m/s"
    vdiff@lat2d = lat2d1
    vdiff@lon2d = lon2d1

res = True
res@gsnDraw = False
res@gsnFrame = False
vcres = res
mpres = res

  res                 = True
; Set some contouring resources.
  res@cnFillOn        = True
  res@cnLinesOn       = False
  res@cnLineLabelsOn  = False
  res@cnInfoLabelOn   = False
  res@cnLevelSelectionMode = "ExplicitLevels"
  res@cnLevels             = (/ -3.,-2.,-1.5, -1., -0.5, -0.1,0.1, 0.5, 1., 1.5, 2.,3./)
  res@gsnDraw         = False
  res@gsnFrame        = False
  res@cnFillDrawOrder = "Predraw"

mpres@mpLimitMode = "Corners"
mpres@mpLeftCornerLatF = lat11
mpres@mpLeftCornerLonF = lon11
mpres@mpRightCornerLatF = lat21
mpres@mpRightCornerLonF = lon21
mpres@mpFillOn              = False
mpres@mpDataBaseVersion     = "MediumRes"          ; Default is LowRes
mpres@mpProjection = "CylindricalEquidistant"
mpres@mpCenterRotF = -3.
mpres@mpCenterLatF = pole_lat1-90.0
mpres@mpCenterLonF = pole_lon1-180.0
mpres@mpOutlineDrawOrder = "PostDraw"

; Set up some vector resources.
  vcres                         = True             ; plot mods desired
  vcres@vcRefLengthF            = 0.05            ; define length of vec ref
  vcres@vcGlyphStyle            = "CurlyVector"    ; turn on curly vectors
  vcres@vcRefMagnitudeF           = 2.0             ; define vector ref mag
  vcres@tiMainFontHeightF = 0.02
  vcres@vcMinDistanceF          = 0.025              ; thin out windbarbs
  vcres@vcVectorDrawOrder = "Predraw"

  wks2 = gsn_open_wks("pdf", outfile+"_1monthanom_metwind")  ; Open graphics file
      gsn_define_colormap(wks2,"precip_diff_12lev")                ; choose


slpanom = gsn_csm_contour(wks2,var1,res)
windanom = gsn_csm_vector(wks2,udiff, vdiff,vcres)
mpid = gsn_csm_map(wks2,mpres)

; Overlay contour and vector plots on the map plot.
overlay(mpid,slpanom)
overlay(mpid,windanom)
maximize_output(wks2, True) 
delete(wks2)

  