load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
;load "./WRFUserARW.ncl"

begin

  OUTDir = "/srv/ccrc/data36/z3478332/WRF/output/"  
  DATADir = "/srv/ccrc/data36/z3478332/WRF/output/ERAI_R2_nudging_default_2Jun/out/"
  CONTDir = "/srv/ccrc/data36/z3478332/WRF/output/ERAI_R2_nudging_default/out/" 
  outfile=OUTDir+"D01_prlr_default_2Jun_4to30"

  day1=20070604
  day2=20070630

  wks = gsn_open_wks("pdf", outfile+"_dailyanom")  ; Open graphics file
      gsn_define_colormap(wks,"precip_diff_12lev")                ; choose colormap

  FILES1 = systemfunc (" ls -1 " + DATADir + "wrfhrly_d01_2007-??-??_00:00:00")
  f1 = addfiles(FILES1+".nc","r")
  FILES1a = systemfunc (" ls -1 " + CONTDir + "wrfhrly_d01_2007-??-??_00:00:00")
  f1a = addfiles(FILES1a+".nc","r")

  times1=wrf_user_getvar(f1,"times",-1)
  times2=stringtointeger(str_get_cols(times1, 0, 3))*10000+stringtointeger(str_get_cols(times1, 5,6))*100+stringtointeger(str_get_cols(times1, 8,9))
  times3=ind(times2.ge.day1.and.times2.le.day2)

  times1a=wrf_user_getvar(f1a,"times",-1)
  times2a=stringtointeger(str_get_cols(times1a, 0, 3))*10000+stringtointeger(str_get_cols(times1a, 5,6))*100+stringtointeger(str_get_cols(times1a, 8,9))
  times3a=ind(times2a.ge.day1.and.times2a.le.day2)


  rain_exp1a=wrf_user_getvar(f1,"RAINNC",times3)
  rain_exp1b=wrf_user_getvar(f1a,"RAINNC",times3a)
  rain_con1a=wrf_user_getvar(f1,"RAINC",times3)
  rain_con1b=wrf_user_getvar(f1a,"RAINC",times3a)
  var_in1 = rain_exp1a + rain_con1a -rain_exp1b - rain_con1b
 
  lat1 = wrf_user_getvar(f1,"XLAT",-1)
  lon1 = wrf_user_getvar(f1,"XLONG",-1)
  times = times1(times3)
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
