load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
;load "./WRFUserARW.ncl"

begin

  OUTDir = "/srv/ccrc/data36/z3478332/WRF/output/"  
  DATADir = "/srv/ccrc/data28/z3444417/ERA-interim/R2_nudging/out/"
  CONTDir = "/srv/ccrc/data36/z3478332/WRF/output/ERAI_R2_nudging_default_fix/out/" 
  outfile=OUTDir+"D01_prlr_default_notopo"

  wks = gsn_open_wks("pdf", outfile+"_dailyanom")  ; Open graphics file
      gsn_define_colormap(wks,"precip_diff_12lev")                ; choose colormap

  f1 = addfile(DATADir+"wrfhrly_d01_2007-06-01_00:00:00.nc","r")
  f1a = addfile(CONTDir+"wrfhrly_d01_2007-06-01_00:00:00.nc","r")

  rain_exp1a=wrf_user_getvar(f1,"RAINNC",-1)
  rain_exp1b=wrf_user_getvar(f1a,"RAINNC",-1)
  rain_con1a=wrf_user_getvar(f1,"RAINC",-1)
  rain_con1b=wrf_user_getvar(f1a,"RAINC",-1)
  var_in1 = rain_exp1a + rain_con1a -rain_exp1b - rain_con1b
 
  lat1 = wrf_user_getvar(f1,"XLAT",-1)
  lon1 = wrf_user_getvar(f1,"XLONG",-1)
  times = wrf_user_getvar(f1,"times",-1)
  numDAYS = dimsizes(times)/24
  len=dimsizes(times)-1 

  res                 = True

; Set some contouring resources.
  res@cnFillOn        = True
  res@cnLinesOn       = False
  res@cnLineLabelsOn  = False
  res@cnInfoLabelOn   = False
  res@cnLevelSelectionMode = "ExplicitLevels"
  res@cnLevels             = (/ -50., -25., -10., -5., -2., -1., 1., 2., 5., 10., 25., 50./)
  res@gsnDraw         = False
  res@gsnFrame        = False

  res2 = res

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


; So, we loop over each day, which has 8 observations in d01 and 24 obs in d02
  do ip = 1,numDAYS-1      

    print("Working on date : " + times(ip*24) )

    var1 = (var_in1(ip*24,:,:) - var_in1((ip-1)*24,:,:))
    var1@description = "24hr average rainfall difference ("+ times(ip*24) +")"
    var1@units = "mm"
    var1@lat2d = lat1(ip,:,:)
    var1@lon2d = lon1(ip,:,:)
    
    map = gsn_csm_contour_map(wks, var1, res)
    draw(map)
    frame(wks)
    delete(var1)
  
  end do

delete(wks)
  wks = gsn_open_wks("pdf", outfile+"_monthlyanom")  ; Open graphics file
      gsn_define_colormap(wks,"precip_diff_12lev")     
  res@cnLevels             = (/ -200.,-100., -50., -25., -10., -5., 5., 10., 25., 50.,100.,200./)
    var1 = (var_in1(len,:,:) - var_in1(0,:,:))
    var1@description = "Total Precipitation to " + times(len)
    var1@units = "mm"
    var1@lat2d = lat1(0,:,:)
    var1@lon2d = lon1(0,:,:)
    map = gsn_csm_contour_map(wks, var1, res)
    draw(map)
    frame(wks)

end
