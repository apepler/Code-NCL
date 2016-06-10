load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
;load "./WRFUserARW.ncl"

begin

  year1=2007
  year2=2008


  OUTDir = "/srv/ccrc/data37/z3478332/WRF/output/"  
  DATADir = "/srv/ccrc/data37/z3478332/WRF/output/ERAI_R2_nudging_default_2007_BRAN/out/"
  CONTDir = "/srv/ccrc/data36/z3478332/WRF/output/ERAI_R2_nudging_default_2007/out/" 
  outfile=OUTDir+"D01_prlr_default_BRAN"

  wks = gsn_open_wks("pdf", outfile+"_annualanom")  ; Open graphics file
      gsn_define_colormap(wks,"precip_diff_12lev")       

          ; choose colormap
  res                 = True
; Set some contouring resources.
  res@cnFillOn        = True
  res@cnLinesOn       = False
  res@cnLineLabelsOn  = False
  res@cnInfoLabelOn   = False
  res@cnLevelSelectionMode = "ExplicitLevels"
  res@cnLevels             = (/-300., -200.,-100., -50., -25., -10., 10., 25., 50.,100.,200.,300./)
  res@gsnDraw         = False
  res@gsnFrame        = False

; Add map resources
  res@mpFillOn              = False
  res@mpDataBaseVersion     = "MediumRes"          ; Default is LowRes
  res@mpOutlineDrawOrder    = "PostDraw"           ; Draw map outlines last
  res@mpGridAndLimbOn       = False                ; Turn off lat/lon lines
  res@pmTickMarkDisplayMode = "Always"             ; Turn on map tickmarks
;  res = set_mp_wrf_map_resources(f1[0],res)
  res@mpLimitMode        = "Corners"               ; Portion of map to zoom
  res@mpLeftCornerLatF   = -50. 
  res@mpLeftCornerLonF   = 130.
  res@mpRightCornerLatF  = -20.
  res@mpRightCornerLonF  = 180. 
    res@mpGridLineDashPattern = 2
  res@mpGridLineThicknessF = 0.5
  res@mpProjection = "CylindricalEquidistant"
  
; Add label bar resources
  res@lbLabelAutoStride = True 
  res@lbBoxMinorExtentF        = 0.13
  res@lbLabelFontHeightF       = 0.012

  res@gsnLeftStringFontHeightF = 0.01
  res@gsnRightStringFontHeightF = 0.008
  res@gsnMaximize     = True    ; Maximize plot in frame


  f1 = addfile(DATADir+"wrfhrly_d01_2007-01-01_00:00:00.nc","r")
  lat1 = wrf_user_getvar(f1,"XLAT",0)
  lon1 = wrf_user_getvar(f1,"XLONG",0)
  f1a = addfile(DATADir+"wrfhrly_d01_2007-12-01_00:00:00.nc","r")
  times = wrf_user_getvar(f1a,"times",-1)
  len=dimsizes(times)-1 

  rain_exp1a=wrf_user_getvar(f1a,"RAINNC",len)
  rain_exp1b=wrf_user_getvar(f1,"RAINNC",0)
  rain_con1a=wrf_user_getvar(f1a,"RAINC",len)
  rain_con1b=wrf_user_getvar(f1,"RAINC",0)
  var_in_dir = rain_exp1a + rain_con1a -rain_exp1b - rain_con1b

  f2 = addfile(CONTDir+"wrfhrly_d01_2007-01-01_00:00:00.nc","r")
  f2a = addfile(CONTDir+"wrfhrly_d01_2007-12-01_00:00:00.nc","r")

  rain_exp2a=wrf_user_getvar(f2a,"RAINNC",len)
  rain_exp2b=wrf_user_getvar(f2,"RAINNC",0)
  rain_con2a=wrf_user_getvar(f2a,"RAINC",len)
  rain_con2b=wrf_user_getvar(f2,"RAINC",0)
  var_in_cont = rain_exp2a + rain_con2a -rain_exp2b - rain_con2b

    var1 = (var_in_dir-var_in_cont)
    var1@description = "Total Precipitation Difference in 2007"
    var1@units = "mm"
    var1@lat2d = lat1
    var1@lon2d = lon1
    map = gsn_csm_contour_map(wks, var1, res)
    draw(map)
    frame(wks)

delete(wks)
end


