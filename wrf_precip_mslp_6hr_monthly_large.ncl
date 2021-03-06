load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
;load "$VAPOR_HOME/share/examples/NCL/wrf2geotiff.ncl"
;load "./WRFUserARW.ncl"

begin

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

  fin=addfile("/srv/ccrc/data13/z3393020/Analyses/share/geo_em_files/geo_em.d01.narclim.nc","r")
  lat1 = rm_single_dims(wrf_user_getvar(fin,"XLAT_M",-1))
  lon1 = rm_single_dims(wrf_user_getvar(fin,"XLONG_M",-1))

lat2d1 = fin->XLAT_M(0,:,:)
lon2d1 = fin->XLONG_M(0,:,:)
pole_lat1 = fin@POLE_LAT
pole_lon1 = fin@POLE_LON
cen_lat1 = fin@CEN_LAT
cen_lon1 = fin@CEN_LON

dsize1 = dimsizes(lat2d1)

;convert lon2d to be 0->360 not -180->180
lon2d1 = where(lon2d1.lt.0,360.+lon2d1,lon2d1)

lat11 = lat2d1(0,0)
lat21 = lat2d1(dsize1(0)-1,dsize1(1)-1)
lon11 = lon2d1(0,0)
lon21 = lon2d1(dsize1(0)-1,dsize1(1)-1)

lon2d1@lat2d = lat2d1
lon2d1@lon2d = lon2d1

res@mpLimitMode = "Corners"
res@mpLeftCornerLatF = lat11
res@mpLeftCornerLonF = lon11
res@mpRightCornerLatF = lat21
res@mpRightCornerLonF = lon21

res@mpProjection = "CylindricalEquidistant"
res@mpCenterRotF = -3.
res@mpCenterLatF = pole_lat1-90.0
res@mpCenterLonF = pole_lon1-180.0
    res@mpGridLineDashPattern = 2
  res@mpGridLineThicknessF = 0.5

year1=2007
year2=2008
month1=1
month2=12

;INDIRS=(/"/srv/ccrc/data23/z3478332/WRF/output/ERAI_R2_control_NEMOSST/out/","/srv/ccrc/data23/z3478332/WRF/output/ERAI_R2_control_ERAISST/out/"/)
  INDIRS=(/"/srv/ccrc/data37/z3478332/WRF/output/ERAI_R1_nudging_default_2007_BRAN/out/","/srv/ccrc/data37/z3478332/WRF/output/ERAI_R1_nudging_default_2007_BRAN_noeac/out/","/srv/ccrc/data37/z3478332/WRF/output/ERAI_R3_nudging_default_2007_BRAN/out/","/srv/ccrc/data37/z3478332/WRF/output/ERAI_R3_nudging_default_2007_BRAN_noeac/out/"/)

;INDIRS=(/"/srv/ccrc/data36/z3478332/WRF/output/ERAI_R1_nudging_default_2007/out/","/srv/ccrc/data36/z3478332/WRF/output/ERAI_R1_nudging_default_2007_notopo/out/","/srv/ccrc/data36/z3478332/WRF/output/ERAI_R2_nudging_default_2007/out/","/srv/ccrc/data36/z3478332/WRF/output/ERAI_R2_nudging_default_2007_notopo/out/","/srv/ccrc/data36/z3478332/WRF/output/ERAI_R3_nudging_default_2007/out/","/srv/ccrc/data36/z3478332/WRF/output/ERAI_R3_nudging_default_2007_notopo/out/"/)
II=0
do while(II.lt.dimsizes(INDIRS))
DATADir = INDIRS(II)
year=year1
do while(year.le.year2)
i=month1
do while(i.le.month2)

print(year+"-"+sprinti("%0.2i",i))

  outfile=DATADir+"D01_"+year+"-"+sprinti("%0.2i",i)+"_mslp_prlr_6hourly"
  wks = gsn_open_wks("pdf", outfile)  ; Open graphics file
    gsn_define_colormap(wks,"prcp_1")                ; choose colormap
  
    FILES1 = systemfunc (" ls -1 " + DATADir + "wrfout_d01_"+year+"-"+sprinti("%0.2i",i)+"-??_??:00:00")
  numDAYS = dimsizes(FILES1)-1
  f1 = addfiles(FILES1+".nc","r")
  slp = wrf_user_getvar(f1,"slp",-1)    ; slp
  wrf_smooth_2d( slp, 3 )            ; smooth slp
    slp@lat2d = lat1
    slp@lon2d = lon1
    slp@description = ""
    slp@units = ""
  times1 = wrf_user_getvar(f1,"times",-1)
  delete(f1)

  f2=addfile(DATADir+"wrfhrly_d01_"+year+"-"+sprinti("%0.2i",i)+"-01_00:00:00.nc","r")
  var_in1 = wrf_user_getvar(f2,"PREC_ACC_NC",-1)+wrf_user_getvar(f2,"PREC_ACC_C",-1)
  times2 = wrf_user_getvar(f2,"times",-1)
  len=dimsizes(times1)-1 
  delete(f2)
; So, we loop over each day, which has 8 observations in d01 and 24 obs in d02
;Manually set to 40, i.e. going from 00Z on 5th to 00Z on 10th
  do ip = 2,len,2

    print("Working on time : " + times1(ip) )

    var1 = dim_sum_n_Wrap(var_in1(((ip-2)*3):(ip*3),:,:),0)
    var1@description = ""
    var1@units = ""
    var1@lat2d = lat1
    var1@lon2d = lon1
    res@tiMainPosition="Left"
    res@tiMainString=times1(ip)

    contour_psl = gsn_csm_contour(wks,slp(ip,:,:),opts_psl)    
    map = gsn_csm_contour_map(wks, var1, res)
    overlay(map, contour_psl)
    draw(map)
    frame(wks)
    delete(var1)
  end do

delete([/var_in1,slp,len,times2,times1,numDAYS/])
delete([/wks,map,contour_psl,FILES1,outfile/])

i=i+1
end do
year=year+1
end do
delete(DATADir)
II=II+1
end do
end

