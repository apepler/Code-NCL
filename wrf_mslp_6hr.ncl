load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
;load "$VAPOR_HOME/share/examples/NCL/wrf2geotiff.ncl"
;load "./WRFUserARW.ncl"

begin

;  OUTDir = (/"/srv/ccrc/data36/z3478332/WRF/output/200711/ERAI_R1_nudging/out/","/srv/ccrc/data36/z3478332/WRF/output/200808/ERAI_R1_nudging/out/","/srv/ccrc/data36/z3478332/WRF/output/200711/ERAI_R1_nudging_notopo/out/","/srv/ccrc/data36/z3478332/WRF/output/200808/ERAI_R1_nudging_notopo/out/","/srv/ccrc/data36/z3478332/WRF/output/200711/ERAI_R3_nudging/out/","/srv/ccrc/data36/z3478332/WRF/output/200808/ERAI_R3_nudging/out/","/srv/ccrc/data36/z3478332/WRF/output/200711/ERAI_R3_nudging_notopo/out/","/srv/ccrc/data36/z3478332/WRF/output/200808/ERAI_R3_nudging_notopo/out/"/)

OUTDir="/srv/ccrc/data36/z3478332/WRF/output/ERAI_R2_nudging_default/out/"

  fin=addfile("/srv/ccrc/data13/z3393020/Analyses/share/geo_em_files/geo_em.d02.narclim.nc","r")
  lat1 = rm_single_dims(wrf_user_getvar(fin,"XLAT_M",-1))
  lon1 = rm_single_dims(wrf_user_getvar(fin,"XLONG_M",-1))
  pole_lat1 = fin@POLE_LAT
  pole_lon1 = fin@POLE_LON
  cen_lat1 = fin@CEN_LAT
  cen_lon1 = fin@CEN_LON



nn=0
do while(nn.lt.dimsizes(OUTDir))

  DATADir = OUTDir(nn)
  outfile=DATADir+"D02_mslponly_6hourly"

  wks = gsn_open_wks("pdf", outfile)  ; Open graphics file
;    gsn_define_colormap(wks,"prcp_1")                ; choose colormap
;  wrf2gtiff = wrf2geotiff_open(wks) - For if doing VAPOR
  
  FILES1 = systemfunc (" ls -1 " + DATADir + "wrfout_d02_200?-??-??_??:00:00")
  numDAYS = dimsizes(FILES1)-1
  f1 = addfiles(FILES1+".nc","r")
  slp = wrf_user_getvar(f1,"slp",-1)    ; slp
  wrf_smooth_2d( slp, 3 )            ; smooth slp
  times1 = wrf_user_getvar(f1,"times",-1)
  len=dimsizes(times1)-1 

  slp@lat2d = lat1
  slp@lon2d = lon1
  slp@description = ""
  slp@units = ""

  res                 = True

; Set some contouring resources.
  res@cnFillOn        = True
  res@cnLinesOn       = False
  res@cnLineLabelsOn  = False
  res@cnInfoLabelOn   = False
  res@cnLevelSelectionMode = "ExplicitLevels"
  res@cnLevels             = (/ .2, 1., 2., 5., 10., 25., 50., 100./)
  res@cnFillColors         = (/2,11,10,6,7,8,4,5,17/)

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

    opts_psl = True          
     opts_psl@cnLineColor       = "Blue"
     opts_psl@cnInfoLabelOn     = False
     opts_psl@cnLineLabelFontHeightF = 0.01
     opts_psl@cnLineLabelPerimOn = False
     opts_psl@gsnContourLineThicknessesScale = 1.5
     opts_psl@gsnDraw         = False
     opts_psl@gsnFrame        = False
     opts_psl@cnLevelSpacingF = 4.0
     opts_psl@pmTickMarkDisplayMode = "Always"             ; Turn on map tickmarks
;  res = set_mp_wrf_map_resources(f1[0],res)
     opts_psl@mpDataBaseVersion     = "MediumRes"          ; Default is LowRes
     opts_psl@mpGridLineDashPattern = 2 ; lat/lon lines as dashed
     opts_psl@mpGridAndLimbOn = True
     opts_psl@mpGridSpacingF = 10.
     opts_psl@mpProjection = "CylindricalEquidistant"
     opts_psl@mpCenterRotF = -3.
     opts_psl@mpCenterLatF = pole_lat1-90.0
     opts_psl@mpCenterLonF = pole_lon1-180.0

     opts_psl@mpLimitMode        = "Corners"               ; Portion of map to zoom
     opts_psl@mpLeftCornerLatF   = -50. 
     opts_psl@mpLeftCornerLonF   = 130.
     opts_psl@mpRightCornerLatF  = -20.
     opts_psl@mpRightCornerLonF  = 180. 
     opts_psl@mpGridLineDashPattern = 2
     opts_psl@mpGridLineThicknessF = 0.5
     opts_psl@mpProjection = "CylindricalEquidistant"

; So, we loop over each day, which has 8 observations in d01 and 24 obs in d02
;Manually set to 40, i.e. going from 00Z on 5th to 00Z on 10th
  do ip = 0,len,2    

    print("Working on time : " + times1(ip) )

     opts_psl@tiMainPosition="Left"
     opts_psl@tiMainString=times1(ip)

    contour_psl = gsn_csm_contour_map(wks,slp(ip,:,:),opts_psl)
    draw(contour_psl)
    frame(wks)
  
  end do

delete([/wks,FILES1,f1,slp,times1,len/])

nn=nn+1
end do
end
