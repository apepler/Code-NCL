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
     opts_psl@cnLevelSpacingF = 2.0

  fin=addfile("/srv/ccrc/data13/z3393020/Analyses/share/geo_em_files/geo_em.d01.narclim.nc","r")
  lat1 = rm_single_dims(wrf_user_getvar(fin,"XLAT_M",-1))
  lon1 = rm_single_dims(wrf_user_getvar(fin,"XLONG_M",-1))

month=6
hour=(/"00","06","12","18"/)
  
INDIRS=(/"_BRAN/out/","_BRAN_noeac/out/","_BRAN_2eac/out/"/)
names=(/"BRAN","noeac","2eac"/)
OUTDir="/srv/ccrc/data37/z3478332/WRF/output/"
II=1

do while(II.lt.dimsizes(INDIRS))

  slpall = new((/119,144,215/),"float")
  rainall = new((/119,144,215/),"float")

  slpall@lat2d=lat1
  slpall@lon2d=lon1
  rainall@lat2d=lat1
  rainall@lon2d=lon1
  rainall@description = ""
  rainall@units = ""

r=1
n=0
do while(r.le.3)
day=27
do while(day.le.31)
hh=0
;do while(hh.lt.4)

  print("200705"+day+hour(hh))

  DATADir = "/srv/ccrc/data37/z3478332/WRF/output/ERAI_R"+r+"_ensemble"+INDIRS(II)+"200705"+day+hour(hh)+"/"

  outfile=DATADir+"D01_mslp_prlr_6hourly"
  wks = gsn_open_wks("pdf", outfile)  ; Open graphics file
    gsn_define_colormap(wks,"prcp_1")                ; choose colormap
  
  FILES1 = systemfunc (" ls -1 " + DATADir + "wrfout_d01_2007-06-??_??:00:00")
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

  f2=addfile(DATADir+"wrfhrly_d01_2007-06-01_00:00:00.nc","r")
  var_in1 = wrf_user_getvar(f2,"RAINNC",-1)+wrf_user_getvar(f2,"RAINC",-1)
  times2 = wrf_user_getvar(f2,"times",-1)
  len=dimsizes(times1)-1 
  delete(f2)
; So, we loop over each day, which has 8 observations in d01 and 24 obs in d02
;Manually set to 40, i.e. going from 00Z on 5th to 00Z on 10th
  do ip = 2,len,2

    print("Working on time : " + times1(ip) )

    var1 = (var_in1(ip*3,:,:) - var_in1((ip-2)*3,:,:))
    var1@description = ""
    var1@units = ""
    var1@lat2d = lat1
    var1@lon2d = lon1
    res@tiMainPosition="Left"
    res@tiMainString=times1(ip)

    if(n.eq.0) then
        slpall((ip/2)-1,:,:)=slp(ip,:,:)
        rainall((ip/2)-1,:,:)=var1
    else
        slpall((ip/2)-1,:,:)=slpall((ip/2)-1,:,:)+slp(ip,:,:)
        rainall((ip/2)-1,:,:)=rainall((ip/2)-1,:,:)+var1
    end if

    contour_psl = gsn_csm_contour(wks,slp(ip,:,:),opts_psl)    
    map = gsn_csm_contour_map(wks, var1, res)
    overlay(map, contour_psl)
    draw(map)
    frame(wks)
    delete(var1)
  end do
;hh=hh+1
n=n+1
;end do
day=day+1
end do
r=r+1
end do

slpall=slpall/n
rainall=rainall/n
outfile=OUTDir+"D01_ensmean_mslp_prlr_6hourly_"+names(II)
wks = gsn_open_wks("pdf", outfile)  ; Open graphics file
gsn_define_colormap(wks,"prcp_1")             
do ip = 0,118
    res@tiMainString=times1(ip*2+2)
    contour_psl = gsn_csm_contour(wks,slpall(ip,:,:),opts_psl)    
    map = gsn_csm_contour_map(wks, rainall(ip,:,:), res)
    overlay(map, contour_psl)
    draw(map)
    frame(wks)
  end do

delete([/contour_psl,map,wks,outfile,slpall,rainall,DATADir/])
II=II+1
end do
end
