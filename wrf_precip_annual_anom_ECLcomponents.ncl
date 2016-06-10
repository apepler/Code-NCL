load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
;load "./WRFUserARW.ncl"

begin
  OUTDir="/srv/ccrc/data37/z3478332/WRF/output/"

  r=1
  year1=2007
  year2=2008

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
  res@gsnMaximize     = False    ; Maximize plot in frame

  fin=addfile("/srv/ccrc/data13/z3393020/Analyses/share/geo_em_files/geo_em.d01.narclim.nc","r")
  lat1=rm_single_dims(wrf_user_getvar(fin,"XLAT_M",-1))
  lon1=rm_single_dims(wrf_user_getvar(fin,"XLONG_M",-1))
  a=dimsizes(lat1)
  ECL_d01 = new((/a(0),a(1),3/),"float")
  ECL_d01@lat2d = lat1
  ECL_d01@lon2d = lon1
  noECL_d01 = ECL_d01
  ECL_d01_cont = ECL_d01
  noECL_d01_cont = ECL_d01
  delete([/a,fin/])

do while(r.le.3)
CONTDir = "/srv/ccrc/data37/z3478332/WRF/output/ERAI_R"+r+"_nudging_default_2007_BRAN/out/"
DATADir = "/srv/ccrc/data37/z3478332/WRF/output/ERAI_R"+r+"_nudging_default_2007_BRAN_noeac/out/"

fname="ECLrain_bymonth_0708_rad2_p100.nc"
f1 = addfile(DATADir+fname,"r")
ECL_d01(:,:,r-1) = dim_sum_n_Wrap(f1->ECLrain_loc,0)
noECL_d01(:,:,r-1) = dim_sum_n_Wrap(f1->allrain,0)-dim_sum_n_Wrap(f1->ECLrain_loc,0)

f2 = addfile(CONTDir+fname,"r")
ECL_d01_cont(:,:,r-1) = dim_sum_n_Wrap(f2->ECLrain_loc,0)
noECL_d01_cont(:,:,r-1) = dim_sum_n_Wrap(f2->allrain,0)-dim_sum_n_Wrap(f2->ECLrain_loc,0)

r=r+1
end do

ECL_diff1=dim_avg_n_Wrap(ECL_d01-ECL_d01_cont,2)/2
ECL_diff1@description = "Average difference in ECL-related rain"
ECL_diff1@units = "mm"
ECL_diff1@lat2d=lat1
ECL_diff1@lon2d=lon1

noECL_diff1=dim_avg_n_Wrap(noECL_d01-noECL_d01_cont,2)/2
noECL_diff1@description = "Average difference in non-ECL rain"
noECL_diff1@units = "mm"
noECL_diff1@lat2d=lat1
noECL_diff1@lon2d=lon1

ECL_diff1a=100*dim_avg_n_Wrap((ECL_d01-ECL_d01_cont)/where(ECL_d01_cont.gt.1,ECL_d01_cont,ECL_d01_cont@_FillValue),2)
ECL_diff1a@description= "Average difference in ECL-related rain"
ECL_diff1a@units = "%"
ECL_diff1a@lat2d=lat1
ECL_diff1a@lon2d=lon1

noECL_diff1a=100*dim_avg_n_Wrap((noECL_d01-noECL_d01_cont)/where(noECL_d01_cont.gt.1,noECL_d01_cont,noECL_d01_cont@_FillValue),2)
noECL_diff1a@description= "Average difference in non-ECL rain"
noECL_diff1a@units = "%"
noECL_diff1a@lat2d=lat1
noECL_diff1a@lon2d=lon1

outfile1=OUTDir+"D01_prlr_noeac_BRAN_Rall_annanom_mean_ECL"

  wks = gsn_open_wks("pdf", outfile1)  ; Open graphics file
      gsn_define_colormap(wks,"precip_diff_12lev")      

  map = gsn_csm_contour_map(wks, ECL_diff1, res)
  draw(map)
  frame(wks)
  delete([/map,wks,outfile1/])

outfile1=OUTDir+"D01_prlr_noeac_BRAN_Rall_annanom_mean_noECL"

  wks = gsn_open_wks("pdf", outfile1)  ; Open graphics file
      gsn_define_colormap(wks,"precip_diff_12lev")      

  map = gsn_csm_contour_map(wks, noECL_diff1, res)
  draw(map)
  frame(wks)
  delete([/map,wks,outfile1/])


  outfile1=OUTDir+"D01_prlr_noeac_BRAN_Rall_annanom_mean_PCchange_ECL"
  res@cnLevelSelectionMode = "ExplicitLevels"

  delete(res@cnLevels)
  res@cnLevels             = (/ -50,-20,-10,-5,5,10,20,50/)
;  res@cnFillColors         = (/13,12,11,10,8,6,5,4,3/)
res@cnFillColors         = (/3,4,5,6,8,10,11,12,13/)

  wks = gsn_open_wks("pdf", outfile1)  ; Open graphics file
      gsn_define_colormap(wks,"precip_diff_12lev")      

  map = gsn_csm_contour_map(wks, ECL_diff1a, res)
  draw(map)
  frame(wks)
  delete([/map,wks,outfile1/])

  outfile1=OUTDir+"D01_prlr_noeac_BRAN_Rall_annanom_mean_PCchange_noECL"
  wks = gsn_open_wks("pdf", outfile1)  ; Open graphics file
      gsn_define_colormap(wks,"precip_diff_12lev")      

  map = gsn_csm_contour_map(wks, noECL_diff1a, res)
  draw(map)
  frame(wks)
  delete([/map,wks,outfile1/])

end


