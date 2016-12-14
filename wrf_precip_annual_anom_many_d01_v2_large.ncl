load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
;load "./WRFUserARW.ncl"

begin
  OUTDir="/srv/ccrc/data45/z3478332/WRF/output/extracted_data/"

  r=1
  year1=2007
  year2=2008

  fin=addfile("ESB_mask.nc","r")
  ESB=fin->mask
  latA=fin->lat
  latA@units="degreesN"
  latA!0="lat"
  lonA=fin->lon
  lonA@units="degreesE"
  lonA!0="lon"
  ESB!0="lat"
  ESB!1="lon"
  ESB&lat=latA
  ESB&lon=lonA

  res                 = True
; Set some contouring resources.
  res@cnFillOn        = True
  res@cnLinesOn       = False
  res@cnLineLabelsOn  = False
  res@cnInfoLabelOn   = False
  res@cnLevelSelectionMode = "ExplicitLevels"
  res@cnLevels             = (/-500., -250.,-100., -50., -25., -10., 10., 25., 50.,100.,250.,500./)
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
  res@mpLeftCornerLonF   = 100.
  res@mpRightCornerLatF  = 0.
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
  res@gsnMaximize     = False    ; Maximize plot in frame

    opts_psl = True          
     opts_psl@cnLineColor       = "red"
     opts_psl@cnInfoLabelOn     = False
     opts_psl@cnLineLabelFontHeightF = 0.01
     opts_psl@cnLineLabelPerimOn = False
     opts_psl@gsnContourLineThicknessesScale = 3
     opts_psl@gsnDraw         = False
     opts_psl@gsnFrame        = False
     opts_psl@cnLevelSelectionMode = "EqualSpacedLevels" ; set equal spaced contour levels
     opts_psl@cnMaxLevelCount = 1	
     opts_psl@cnLineLabelsOn = False


  fin=addfile("/srv/ccrc/data13/z3393020/Analyses/share/geo_em_files/geo_em.d01.narclim.nc","r")
  lat1=rm_single_dims(wrf_user_getvar(fin,"XLAT_M",-1))
  lon1=rm_single_dims(wrf_user_getvar(fin,"XLONG_M",-1))
  a=dimsizes(lat1)
  default_d01 = new((/a(0),a(1),3/),"float")
  default_d01@lat2d = lat1
  default_d01@lon2d = lon1
  notopo_d01 = default_d01
  delete([/a,fin/])

f1=addfile(OUTDir+"WRF_d01_LH_PRCP.nc","r")
control_d01=f1->PRCP_d01
f2=addfile(OUTDir+"WRF_d01_LH_PRCP_notopo.nc","r")
default_d01=f2->PRCP_d01

diff1=(default_d01-control_d01)/2
diff1@description = "Average Precipitation Difference in 2007-08"
diff1@units = "mm"
diff1@lat2d=lat1
diff1@lon2d=lon1

diff1a=100*(default_d01-control_d01)/where(control_d01.gt.0,control_d01,control_d01@_FillValue)
diff1a@description= "Average Precipitation Difference in 2007-08"
diff1a@units = "%"
diff1a@lat2d=lat1
diff1a@lon2d=lon1

outfile1=OUTDir+"D01_prlr_notopo_Rall_annanom_mean_ESB"

  wks = gsn_open_wks("pdf", outfile1)  ; Open graphics file
      gsn_define_colormap(wks,"precip_diff_12lev")      

 contourP = gsn_csm_contour(wks,ESB,opts_psl)    
  map = gsn_csm_contour_map(wks, dim_avg_n_Wrap(diff1,2), res)
  overlay(map,contourP)
  draw(map)
  frame(wks)
  delete([/map,wks,outfile1/])

  outfile1=OUTDir+"D01_prlr_notopo_Rall_annanom_mean_PC_ESB"
  res@cnLevelSelectionMode = "ExplicitLevels"

  delete(res@cnLevels)
;  res@cnLevels             = (/ -40,-30,-20,-10,10,20,30,40/)
res@cnLevels             = (/ -40,-30,-20,-10,-5,5,10,20,30,40/)
;  res@cnFillColors         = (/13,12,11,10,8,6,5,4,3/)
res@cnFillColors         = (/2,3,4,5,6,8,10,11,12,13,14/)

  wks = gsn_open_wks("pdf", outfile1)  ; Open graphics file
      gsn_define_colormap(wks,"precip_diff_12lev")      

  contourP = gsn_csm_contour(wks,ESB,opts_psl)   
  map = gsn_csm_contour_map(wks, dim_avg_n_Wrap(diff1a,2), res)
  overlay(map,contourP)
  draw(map)
  frame(wks)
  delete([/map,wks,outfile1/])


end


