load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"
;load "./WRFUserARW.ncl"

begin

OUTDIRS=(/"/srv/ccrc/data36/z3478332/WRF/output/ERAI_R2_nudging_default/out/","/srv/ccrc/data36/z3478332/WRF/output/ERAI_R2_nudging_BRAN/out/","/srv/ccrc/data36/z3478332/WRF/output/ERAI_R2_nudging_BRAN_noeac/out/","/srv/ccrc/data36/z3478332/WRF/output/ERAI_R2_nudging_BRAN_coarseSST/out/","/srv/ccrc/data34/z3478332/WRF/output/ERAI_R2_nudging_default_SST-2/out/","/srv/ccrc/data34/z3478332/WRF/output/ERAI_R2_nudging_default_SST-1/out/","/srv/ccrc/data34/z3478332/WRF/output/ERAI_R2_nudging_default_SST+1/out/","/srv/ccrc/data34/z3478332/WRF/output/ERAI_R2_nudging_default_SST+2/out/"/)
dlist=(/"default","BRAN","BRAN_noeac","BRAN_coarseSST","SST-2","SST-1","SST+1","SST+2"/)

; FIRST - Load all the awap data

f1 = addfile("/srv/ccrc/data02/z3236814/data/AWAP/DAILY/netcdf/Daily_calib_rainfall_analysis_V3/pre.2007.nc","r")
latA=f1->lat
lonA=f1->lon
timeA=yyyyddd_to_yyyymmdd(f1->time)
monthA=floor((timeA%10000)/100)

month=6
I=ind(monthA.eq.month)
rainA=f1->pre(I+1,:,:)
delete(I)

f1=addfile("/srv/ccrc/data30/z3393020/NARCliM/postprocess/1990-2009/ECHAM5/R2/d01/CCRC_NARCliM_MON_2000-2009_tasmax.nc","r")
lat1=f1->lat
lon1=f1->lon
f1=addfile("/srv/ccrc/data30/z3393020/NARCliM/postprocess/1990-2009/ECHAM5/R2/d02/CCRC_NARCliM_MON_2000-2009_tasmax.nc","r")
lat2=f1->lat
lon2=f1->lon

delete(f1)

   Opt                = True
   Opt@SrcGridLat = latA
   Opt@SrcGridLon = lonA
   Opt@DstGridLat = lat1
   Opt@DstGridLon = lon1
   Opt@ForceOverwrite = True
   Opt@DstRegional = True

rainA1=ESMF_regrid(rainA,Opt)

delete([/Opt@DstGridLat,Opt@DstGridLon/])  
Opt@DstGridLat = lat2
Opt@DstGridLon = lon2
rainA2=ESMF_regrid(rainA,Opt)

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

  res2 = res

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

n=1
do while(n.lt.dimsizes(OUTDIRS))

  DATADir = OUTDIRS(n)
  OUTDir=DATADir
;  CONTDir = CONTDIRS(n)

  FILES1 = systemfunc (" ls -1 " + DATADir + "wrfhrly_d01_200?-??-??_00:00:00")
  f1 = addfiles(FILES1+".nc","r")
  FILES1a = systemfunc (" ls -1 " + DATADir + "wrfhrly_d02_200?-??-??_00:00:00")
  f2 = addfiles(FILES1a+".nc","r")
  times=wrf_user_getvar(f1,"times",-1)
  days = stringtoint(str_get_cols(times, 8,9))
  numDAYS = dimsizes(times)/24
  len=dimsizes(times)-1 

  var_in1 = wrf_user_getvar(f1,"PREC_ACC_NC",-1) + wrf_user_getvar(f1,"PREC_ACC_C",-1)
  var_in2 = wrf_user_getvar(f2,"PREC_ACC_NC",-1) + wrf_user_getvar(f2,"PREC_ACC_C",-1)
  var_in1a = new((/30,144,215/),"float")
  var_in2a = new((/30,200,325/),"float")
  do ip = 1,numDAYS      
    I=ind(days.eq.ip)
    var_in1a(ip-1,:,:) = dim_sum_n_Wrap(var_in1(I,:,:),0)
    var_in2a(ip-1,:,:) = dim_sum_n_Wrap(var_in2(I,:,:),0)
  end do
  
  rms1 = sqrt(dim_avg_n((var_in1a-rainA1)^2,0))
    rms1@description = "RMSE for all days in June 2007"
    rms1@units = "mm"
    rms1@lat2d = lat1
    rms1@lon2d = lon1
  rms1a=rms1/where(dim_avg_n(rainA1,0).gt.1.,dim_avg_n(rainA1,0),rainA1@_FillValue)
  copy_VarMeta(rms1,rms1a)

  rms2 = sqrt(dim_avg_n((var_in2a-rainA2)^2,0))
    rms2@description = "RMSE for all days in June 2007"
    rms2@units = "mm"
    rms2@lat2d = lat2
    rms2@lon2d = lon2
  rms2a=rms2/where(dim_avg_n(rainA2,0).gt.1.,dim_avg_n(rainA2,0),rainA2@_FillValue)
  copy_VarMeta(rms2,rms2a)

  wks = gsn_open_wks("pdf", OUTDir+"D01_prlr_"+dlist(n)+"_rmseAWAP")  ; Open graphics file
    gsn_define_colormap(wks,"prcp_1")                ; choose colormap
    map = gsn_csm_contour_map(wks, rms1, res)
    draw(map)
    frame(wks)
    delete([/map,wks/])

  wks = gsn_open_wks("pdf", OUTDir+"D02_prlr_"+dlist(n)+"_rmseAWAP")  ; Open graphics file
    gsn_define_colormap(wks,"prcp_1")                ; choose colormap
    map = gsn_csm_contour_map(wks, rms2, res)
    draw(map)
    frame(wks)
    delete([/map,wks/])

  res@cnLevels             = (/ .1, .25, .5, 1., 2., 5., 10., 20./)

  wks = gsn_open_wks("pdf", OUTDir+"D01_prlr_"+dlist(n)+"_rmseAWAP_v2")  ; Open graphics file
    gsn_define_colormap(wks,"prcp_1")                ; choose colormap
    map = gsn_csm_contour_map(wks, rms1a, res)
    draw(map)
    frame(wks)
    delete([/map,wks/])

  wks = gsn_open_wks("pdf", OUTDir+"D02_prlr_"+dlist(n)+"_rmseAWAP_v2")  ; Open graphics file
    gsn_define_colormap(wks,"prcp_1")                ; choose colormap
    map = gsn_csm_contour_map(wks, rms2a, res)
    draw(map)
    frame(wks)

  delete([/FILES1,FILES1a,f1,f2,wks,var_in1,map,times/])

n=n+1
end do
end
