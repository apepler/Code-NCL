load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
;load "$VAPOR_HOME/share/examples/NCL/wrf2geotiff.ncl"
;load "./WRFUserARW.ncl"

begin

  fin=addfile("/srv/ccrc/data13/z3393020/Analyses/share/geo_em_files/geo_em.d01.narclim.nc","r")
  lat1 = rm_single_dims(wrf_user_getvar(fin,"XLAT_M",-1))
  lon1 = rm_single_dims(wrf_user_getvar(fin,"XLONG_M",-1))
  pole_lat1 = fin@POLE_LAT
  pole_lon1 = fin@POLE_LON
  cen_lat1 = fin@CEN_LAT
  cen_lon1 = fin@CEN_LON

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
     opts_psl@mpLeftCornerLatF   = -45. 
     opts_psl@mpLeftCornerLonF   = 140.
     opts_psl@mpRightCornerLatF  = -20.
     opts_psl@mpRightCornerLonF  = 170. 
     opts_psl@mpGridLineDashPattern = 2
     opts_psl@mpGridLineThicknessF = 0.5
     opts_psl@mpProjection = "CylindricalEquidistant"

tlist=(/"MIROC_R1","MIROC_R2","MIROC_R3","ECHAM5_R1","ECHAM5_R2","ECHAM5_R3","CCCMA_R1","CCCMA_R2","CCCMA_R3","MK3_R1","MK3_R2","MK3_R3","NCEP_R1","NCEP_R2","NCEP_R3"/)

INDIRS=(/"/srv/ccrc/data11/z3393020/MIROC3.2/R1/1990-2010/out/","/srv/ccrc/data12/z3393020/MIROC3.2/R2/1990-2010/out/","/srv/ccrc/data14/z3393020/MIROC3.2/R3/1990-2010/out/","/srv/ccrc/data20/z3393020/WRF_ECHAM5/R1/1990-2010/out/","/srv/ccrc/data20/z3393020/WRF_ECHAM5/R2/1990-2010/out/","/srv/ccrc/data14/z3393020/WRF_ECHAM5/R3/1990-2010/out/","/srv/ccrc/data21/z3393020/WRF_CCCMA/R1/1990-2010/out/","/srv/ccrc/data24/z3393020/WRF_CCCMA/R2/1990-2010/out/","/srv/ccrc/data21/z3393020/WRF_CCCMA/R3/1990-2010/out/","/srv/ccrc/data25/z3444417/NARCliM/CSIRO-Mk3.0/1990-2009/R1/out/","/srv/ccrc/data23/z3444417/NARCliM/CSIRO-Mk3.0/1990-2009/R2/out/","/srv/ccrc/data26/z3444417/studies/NARCliM/CSIRO-Mk3.0/1990-2009/R3/out/","/srv/ccrc/data31/z3393020/NARCliM/reanalysis/R1/out/","/srv/ccrc/data27/z3393020/WRF_NNRP/R2/1950-2010/out/","/srv/ccrc/data29/z3236814/NARCliM/reanalysis/R3/out/"/)

OUTDir="/srv/ccrc/data34/z3478332/CMIP-WRF-ECLs/NARCLIM/"

II=0
do while(II.lt.dimsizes(INDIRS))

  DATADir = INDIRS(II)
  print(tlist(II))

  outfile=OUTDir+"D01_mslponly_Oct04_"+tlist(II)
  wks = gsn_open_wks("pdf", outfile)  ; Open graphics file
    gsn_define_colormap(wks,"prcp_1")                ; choose colormap
  
  FILES1 = systemfunc (" ls -1 " + DATADir + "wrfout_d01_2004-10-??_??:00:00")
  numDAYS = dimsizes(FILES1)-1
  f1 = addfiles(FILES1+".nc","r")
  slp = wrf_user_getvar(f1,"slp",-1)    ; slp
  wrf_smooth_2d( slp, 3 )            ; smooth slp
    slp@lat2d = lat1
    slp@lon2d = lon1
    slp@description = ""
    slp@units = ""
  times1 = wrf_user_getvar(f1,"times",-1)
  len=dimsizes(times1)-1 
  delete(f1)

; So, we loop over each day, which has 8 observations in d01 and 24 obs in d02
;Manually set to 40, i.e. going from 00Z on 5th to 00Z on 10th
  do ip = 2,len,2
    opts_psl@tiMainPosition="Left"
    opts_psl@tiMainString=times1(ip)
    contour_psl = gsn_csm_contour_map(wks,slp(ip,:,:),opts_psl)    
    draw(contour_psl)
    frame(wks)
  end do
II=II+1

delete([/times1,slp,len,FILES1,numDAYS,outfile,wks,DATADir/])
end do
end
