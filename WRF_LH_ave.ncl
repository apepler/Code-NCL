load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
;load "./WRFUserARW.ncl"

begin

  OUTDir = "/srv/ccrc/data36/z3478332/WRF/output/"  
  type=(/"BRAN","BRAN_noeac"/)

;  levT2=(/-2.25,-2., -1.75,-1.5, -1.25, -1, -0.75, -0.5, -0.25, 0.25, 0.5, 0.75, 1.,1.25, 1.5, 1.75, 2.,2.25/)
;  levF=(/-45., -40.,-35.,-30.,-25., -20.,-15., -10., -5., 5., 10., 15., 20.,25., 30.,35.,40.,45./)

  res                 = True
; Set some contouring resources.
  res@cnFillOn        = True
  res@cnLinesOn       = False
  res@cnLineLabelsOn  = False
  res@cnInfoLabelOn   = False
  res@cnLevelSelectionMode = "ExplicitLevels"
  res@gsnDraw         = False
  res@gsnFrame        = False
  res@cnLevels = (/0.,25.,50.,75.,100.,125.,150.,175.,200.,225.,250./)

;  res@cnFillColors         = (/3,5,7,9,11,13,15,17,19/)

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
  delete(fin)
  fin=addfile("/srv/ccrc/data13/z3393020/Analyses/share/geo_em_files/geo_em.d02.narclim.nc","r")
  lat2=rm_single_dims(wrf_user_getvar(fin,"XLAT_M",-1))
  lon2=rm_single_dims(wrf_user_getvar(fin,"XLONG_M",-1))
  delete(fin)

t=0
do while(t.le.1)
  a=dimsizes(lat1)
  LH_d01 = new((/a(0),a(1),3/),"float")
  LH_d01@lat2d = lat1
  LH_d01@lon2d = lon1
  delete(a)

  LH_d01@description="Average surface latent heat flux"
  LH_d01@units = "W m-2"

  a=dimsizes(lat2)
  LH_d02 = new((/a(0),a(1),3/),"float")
  LH_d02@lat2d = lat2
  LH_d02@lon2d = lon2
  delete(a)

  LH_d02@description="Average surface latent heat flux"
  LH_d02@units = "W m-2"

r=1
do while(r.le.3)

  DATADir = "/srv/ccrc/data37/z3478332/WRF/output/ERAI_R"+r+"_nudging_default_2007_"+type(t)+"/out/"

  FILES1 = systemfunc (" ls -1 " + DATADir + "wrfhrly_d01_200?-??-??_00:00:00")
  f1 = addfiles(FILES1+".nc","r")
  LH_d01(:,:,r-1)=dim_avg_n_Wrap(wrf_user_getvar(f1,"LH",-1),0)

  FILES1a = systemfunc (" ls -1 " + DATADir + "wrfhrly_d02_200?-??-??_00:00:00")
  f1a = addfiles(FILES1a+".nc","r")
  LH_d02(:,:,r-1)=dim_avg_n_Wrap(wrf_user_getvar(f1a,"LH",-1),0)
  
  delete([/f1,f1a,FILES1,FILES1a/])

  outfile1=OUTDir+"D01_LH_"+type(t)+"_R"+r+"_annmean"
  outfile2=OUTDir+"D02_LH_"+type(t)+"_R"+r+"_annmean"

  wks = gsn_open_wks("pdf", outfile1)  ; Open graphics file
      gsn_define_colormap(wks,"precip_11lev")      

  map = gsn_csm_contour_map(wks, LH_d01(:,:,r-1), res)
  draw(map)
  frame(wks)
  delete([/map,wks/])

  wks = gsn_open_wks("pdf", outfile2)  ; Open graphics file
      gsn_define_colormap(wks,"precip_11lev")      

  map = gsn_csm_contour_map(wks, LH_d02(:,:,r-1), res)
  draw(map)
  frame(wks)
  delete([/map,wks,outfile1,outfile2/])

r=r+1
end do

  outfile1=OUTDir+"D01_LH_"+type(t)+"_Rall_annmean"
  outfile2=OUTDir+"D02_LH_"+type(t)+"_Rall_annmean"

  wks = gsn_open_wks("pdf", outfile1)  ; Open graphics file
      gsn_define_colormap(wks,"precip_11lev")      

  map = gsn_csm_contour_map(wks, dim_avg_n_Wrap(LH_d01,2), res)
  draw(map)
  frame(wks)
  delete([/map,wks/])

  wks = gsn_open_wks("pdf", outfile2)  ; Open graphics file
      gsn_define_colormap(wks,"precip_11lev")      

  map = gsn_csm_contour_map(wks, dim_avg_n_Wrap(LH_d02,2), res)
  draw(map)
  frame(wks)
  delete([/map,wks,outfile1,outfile2,LH_d01,LH_d02,DATADir/])

t=t+1
end do

end