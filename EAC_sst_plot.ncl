load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
;load "./WRFUserARW.ncl"

  res                 = True
; Set some contouring resources.
  res@cnFillOn        = True
  res@cnLinesOn       = False
  res@cnLineLabelsOn  = False
  res@cnInfoLabelOn   = False

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
  res@mpLeftCornerLatF   = -40. 
  res@mpLeftCornerLonF   = 135.
  res@mpRightCornerLatF  = -23.
  res@mpRightCornerLonF  = 165. 
    res@mpGridLineDashPattern = 2
  res@mpGridLineThicknessF = 0.5
  res@mpProjection = "CylindricalEquidistant"
  
; Add label bar resources
  res@lbLabelAutoStride = True 
  res@lbBoxMinorExtentF        = 0.13
  res@lbLabelFontHeightF       = 0.012

  res@gsnLeftStringFontHeightF = 0.01
  res@gsnRightStringFontHeightF = 0.008
  res@gsnMaximize     = False    ; Maximize plot in frame


  fin=addfile("/srv/ccrc/data13/z3393020/Analyses/share/geo_em_files/geo_em.d02.narclim.nc","r")
  lat2=rm_single_dims(wrf_user_getvar(fin,"XLAT_M",-1))
  lon2=rm_single_dims(wrf_user_getvar(fin,"XLONG_M",-1))

  year=2007
  month=6

  f1=addfile("/srv/ccrc/data36/z3478332/WRF/WRF_boundary/default_bran/wrflowinp_d02_"+year+"-"+sprinti("%0.2i",month),"r")
  sst1=dim_avg_n_Wrap(f1->SST,0)
  f2=addfile("/srv/ccrc/data36/z3478332/WRF/WRF_boundary/default_bran_2007/wrflowinp_d02_"+year+"-"+sprinti("%0.2i",month),"r")
  sst2=dim_avg_n_Wrap(f2->SST,0)

  diff=where(sst2.eq.0.or.sst2.le.sst1,-999999.,sst2-sst1)
  diff@_FillValue=-999999.
  diff@lat2d = lat2
  diff@lon2d = lon2
  diff@description = "Average SST Difference in June 2007"
  diff@units = "K"

  OUTDir="/srv/ccrc/data37/z3478332/WRF/WRF_boundary/default_bran_2007_2eac/"
  outfile1=OUTDir+"D02_EAC_June2007"

  wks = gsn_open_wks("pdf", outfile1)  ; Open graphics file
      gsn_define_colormap(wks,"WhiteYellowOrangeRed")      

  map = gsn_csm_contour_map(wks, diff, res)
  draw(map)
  frame(wks)
  delete([/map,wks/])

