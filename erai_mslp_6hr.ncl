load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
;load "$VAPOR_HOME/share/examples/NCL/wrf2geotiff.ncl"
;load "./WRFUserARW.ncl"

begin

  fin=addfile("/srv/ccrc/data13/z3393020/Analyses/share/geo_em_files/geo_em.d02.narclim.nc","r")
  pole_lat1 = fin@POLE_LAT
  pole_lon1 = fin@POLE_LON
  cen_lat1 = fin@CEN_LAT
  cen_lon1 = fin@CEN_LON
  OUTDir="/srv/ccrc/data36/z3478332/WRF/output/ERAI_R2_nudging_default/out/"
  outfile=OUTDir+"ERAI_mslponly_6hourly"

  wks = gsn_open_wks("pdf", outfile)  ; Open graphics file
;    gsn_define_colormap(wks,"prcp_1")                ; choose colormap
;  wrf2gtiff = wrf2geotiff_open(wks) - For if doing VAPOR

  f1=addfile("/srv/ccrc/data34/z3478332/ERAI/ERAI_mslp_2005-01_2010-12.nc","r")
  times1 = f1->time
  lat=f1->latitude
  lon=f1->longitude

  yyyymm = cd_calendar(times1,-1)
  a=ind(yyyymm.eq.200706)
  len=dimsizes(a)-1 
  times2=cd_string(times1(a),"%H%M UTC %d %f %Y")
  slp=short2flt(f1->msl(a,:,:))/100
  slp!0 = "time"
  slp!1 = "lat"
  slp!2 = "lon"
  slp&lat = lat
  slp&lon = lon


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

    print("Working on time : " + times2(ip) )

     opts_psl@tiMainPosition="Left"
     opts_psl@tiMainString=times2(ip)

    contour_psl = gsn_csm_contour_map(wks,slp(ip,:,:),opts_psl)
    draw(contour_psl)
    frame(wks)
  
  end do

delete([/wks,FILES1,f1,slp,times1,len/])

end
