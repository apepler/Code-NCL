load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
;load "./WRFUserARW.ncl"

begin

  OUTDir = "/srv/ccrc/data37/z3478332/WRF/output/"  
  DATADir = "/srv/ccrc/data37/z3478332/WRF/output/ERAI_R2_nudging_default_2007_BRAN_noeac/out/"
  CONTDir = "/srv/ccrc/data37/z3478332/WRF/output/ERAI_R2_nudging_default_2007_BRAN/out/" 
  outfile=OUTDir+"D01_prlr_BRAN_noeac"


  wks = gsn_open_wks("pdf", outfile+"_monthlyanom")  ; Open graphics file
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

  rain = new((/24,144,215/),"float")
;  rain = new((/12,200,325/),"float")
  rain@description = "Total Precipitation"
  rain@units = "mm"

  f1 = addfile(DATADir+"wrfhrly_d01_2007-06-01_00:00:00.nc","r")
  lat1 = wrf_user_getvar(f1,"XLAT",0)
  lon1 = wrf_user_getvar(f1,"XLONG",0)
  rain@lat2d = lat1
  rain@lon2d = lon1

  year1=2007
  year2=2008

  year=year1
  n=0
  do while(year.le.year2)
  month=1
  do while(month.le.12)

  f1 = addfile(CONTDir+"wrfhrly_d01_"+year+"-"+sprinti("%0.2i",month)+"-01_00:00:00.nc","r")
  f2 = addfile(DATADir+"wrfhrly_d01_"+year+"-"+sprinti("%0.2i",month)+"-01_00:00:00.nc","r")

  rain_exp=wrf_user_getvar(f1,"PREC_ACC_NC",-1)
  rain_con=wrf_user_getvar(f1,"PREC_ACC_C",-1)
  rain_exp2=wrf_user_getvar(f2,"PREC_ACC_NC",-1)
  rain_con2=wrf_user_getvar(f2,"PREC_ACC_C",-1)

  var_in_cont = dim_sum_n_Wrap(rain_exp,0)+dim_sum_n_Wrap(rain_con,0)
  var_in_dir = dim_sum_n_Wrap(rain_exp2,0)+dim_sum_n_Wrap(rain_con2,0)
  rain(n,:,:)=(var_in_dir-var_in_cont)
  map = gsn_csm_contour_map(wks, rain(n,:,:), res)
  draw(map)
  frame(wks)

  delete([/f1,f2,rain_exp,rain_exp2,rain_con,rain_con2,var_in_cont,var_in_dir/]) 

n=n+1
month=month+1
end do
year=year+1
end do
delete(wks)

var1=dim_sum_n_Wrap(rain,0)
  wks = gsn_open_wks("pdf", outfile+"_annualanom")  ; Open graphics file
      gsn_define_colormap(wks,"precip_diff_12lev")       

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

    map = gsn_csm_contour_map(wks, var1, res)
    draw(map)
    frame(wks)

end


