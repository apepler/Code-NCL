load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
;load "$VAPOR_HOME/share/examples/NCL/wrf2geotiff.ncl"
;load "./WRFUserARW.ncl"

begin

;  OUTDir = (/"/srv/ccrc/data36/z3478332/WRF/output/200711/ERAI_R1_nudging/out/","/srv/ccrc/data36/z3478332/WRF/output/200808/ERAI_R1_nudging/out/","/srv/ccrc/data36/z3478332/WRF/output/200711/ERAI_R1_nudging_notopo/out/","/srv/ccrc/data36/z3478332/WRF/output/200808/ERAI_R1_nudging_notopo/out/","/srv/ccrc/data36/z3478332/WRF/output/200711/ERAI_R3_nudging/out/","/srv/ccrc/data36/z3478332/WRF/output/200808/ERAI_R3_nudging/out/","/srv/ccrc/data36/z3478332/WRF/output/200711/ERAI_R3_nudging_notopo/out/","/srv/ccrc/data36/z3478332/WRF/output/200808/ERAI_R3_nudging_notopo/out/"/)


OUTDir=(/"/srv/ccrc/data36/z3478332/WRF/output/ERAI_R2_nudging_BRAN/out/","/srv/ccrc/data36/z3478332/WRF/output/ERAI_R2_nudging_BRAN_noeac/out/","/srv/ccrc/data36/z3478332/WRF/output/ERAI_R2_nudging_BRAN_coarseSST/out/","/srv/ccrc/data34/z3478332/WRF/output/ERAI_R2_nudging_default_SST-2/out/","/srv/ccrc/data34/z3478332/WRF/output/ERAI_R2_nudging_default_SST-1/out/","/srv/ccrc/data34/z3478332/WRF/output/ERAI_R2_nudging_default_SST+1/out/","/srv/ccrc/data34/z3478332/WRF/output/ERAI_R2_nudging_default_SST+2/out/"/)


nn=0
do while(nn.lt.dimsizes(OUTDir))

  DATADir = OUTDir(nn)
  outfile=DATADir+"D02_mslp_prlr_6hourly"

  wks = gsn_open_wks("pdf", outfile)  ; Open graphics file
    gsn_define_colormap(wks,"prcp_1")                ; choose colormap
;  wrf2gtiff = wrf2geotiff_open(wks) - For if doing VAPOR
  
  FILES1 = systemfunc (" ls -1 " + DATADir + "wrfout_d02_200?-??-??_??:00:00")
  numDAYS = dimsizes(FILES1)-1
  f1 = addfiles(FILES1+".nc","r")
  slp = wrf_user_getvar(f1,"slp",-1)    ; slp
  wrf_smooth_2d( slp, 3 )            ; smooth slp
  times1 = wrf_user_getvar(f1,"times",-1)

  files2=systemfunc (" ls -1 " + DATADir+"wrfhrly_d02_200?-??-01_00:00:00")
  f2=addfile(files2+".nc","r")
  var_in1 = wrf_user_getvar(f2,"RAINNC",-1)+wrf_user_getvar(f2,"RAINC",-1)
  lat1 = wrf_user_getvar(f2,"XLAT",-1)
  lon1 = wrf_user_getvar(f2,"XLONG",-1)
  times2 = wrf_user_getvar(f2,"times",-1)
  len=dimsizes(times1)-1 
  
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



; So, we loop over each day, which has 8 observations in d01 and 24 obs in d02
;Manually set to 40, i.e. going from 00Z on 5th to 00Z on 10th
  do ip = 2,len,2    

    print("Working on time : " + times1(ip) )

    var1 = (var_in1(ip*3,:,:) - var_in1((ip-2)*3,:,:))
    var1@description = ""
    var1@units = ""
    var1@lat2d = lat1(ip,:,:)
    var1@lon2d = lon1(ip,:,:)

     res@tiMainPosition="Left"
     res@tiMainString=times1(ip)
    
    opts_psl = True          
     opts_psl@cnLineColor       = "Blue"
     opts_psl@cnInfoLabelOn     = False
     opts_psl@cnLineLabelFontHeightF = 0.01
     opts_psl@cnLineLabelPerimOn = False
     opts_psl@gsnContourLineThicknessesScale = 1.5
     opts_psl@gsnDraw         = False
     opts_psl@gsnFrame        = False
     opts_psl@cnLevelSpacingF = 2.0
     slp@lat2d = lat1(ip,:,:)
     slp@lon2d = lon1(ip,:,:)
     slp@description = ""
     slp@units = ""
     contour_psl = gsn_csm_contour(wks,slp(ip,:,:),opts_psl)
     
    map = gsn_csm_contour_map(wks, var1, res)
    overlay(map, contour_psl)
    draw(map)
    frame(wks)
    delete(var1)
  
  end do

delete([/wks,FILES1,f1,slp,var_in1,lat1,lon1,times1,times2/])

nn=nn+1
end do
end
