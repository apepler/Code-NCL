load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
;load "./WRFUserARW.ncl"

begin
  DATADIRS=(/"/srv/ccrc/data36/z3478332/WRF/output/ERAI_R1_nudging_default_2007_notopo/out/","/srv/ccrc/data36/z3478332/WRF/output/ERAI_R2_nudging_default_2007_notopo/out/","/srv/ccrc/data36/z3478332/WRF/output/ERAI_R3_nudging_default_2007_notopo/out/"/)
  CONTDIRS=(/"/srv/ccrc/data36/z3478332/WRF/output/ERAI_R1_nudging_default_2007/out/","/srv/ccrc/data36/z3478332/WRF/output/ERAI_R2_nudging_default_2007/out/","/srv/ccrc/data36/z3478332/WRF/output/ERAI_R3_nudging_default_2007/out/"/)
  year1=2007
  year2=2008


  f2=addfile("/srv/ccrc/data30/z3393020/NARCliM/postprocess/1990-2009/ECHAM5/R2/d02/CCRC_NARCliM_MON_2000-2009_tasmax.nc","r")
  rot=f2->Rotated_pole
  lat1=f2->lat
  lon1=f2->lon

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

  n=0
  do while(n.lt.dimsizes(DATADIRS))
  OUTDir = DATADIRS(n)
  DATADir = OUTDir
  CONTDir = CONTDIRS(n)
  wks = gsn_open_wks("pdf", OUTDir+"D02_monthly_precipanom_notopo_0708.pdf")  ; Open graphics file
  gsn_define_colormap(wks,"precip_diff_12lev")                ; choose colormap

  year=year1
  do while(year.le.year2)
    i=1
    do while(i.le.12)

     f1 = addfile(DATADir+"wrfhrly_d02_"+year+"-"+sprinti("%0.2i",i)+"-01_00:00:00.nc","r")
     f1a = addfile(CONTDir+"wrfhrly_d02_"+year+"-"+sprinti("%0.2i",i)+"-01_00:00:00.nc","r")
     times = wrf_user_getvar(f1,"times",-1)
     len=dimsizes(times)-1 

     rain1 = wrf_user_getvar(f1,"PREC_ACC_NC",-1) + wrf_user_getvar(f1,"PREC_ACC_C",-1)
     rain2 = wrf_user_getvar(f1a,"PREC_ACC_NC",-1) + wrf_user_getvar(f1a,"PREC_ACC_C",-1)
     var1=dim_sum_n_Wrap(rain1,0)-dim_sum_n_Wrap(rain2,0)
     var1@description = "Total Precipitation Difference in "+year+"-"+sprinti("%0.2i",i)
     var1@units = "mm"
     var1@lat2d = lat1
     var1@lon2d = lon1
     map = gsn_csm_contour_map(wks, var1, res)
     draw(map)
     frame(wks)

     delete([/var1,rain1,rain2,map,len,times,f1,f1a/]) 
     i=i+1
   end do
  year=year+1
  end do

  delete(wks)
  n=n+1
  end do
  end


