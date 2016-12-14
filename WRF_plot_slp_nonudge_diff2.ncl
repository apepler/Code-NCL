load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
;load "./WRFUserARW.ncl"

dirs=(/"/srv/ccrc/data34/z3478332/WRF/ERA-nonudge/","/srv/ccrc/data45/z3478332/WRF/output/ERAI_R2_nonudging_notopo/out/impact/"/)
type=(/"ERA-nonudge","ERA-nonudge_notopo"/)

;dirs=(/"/srv/ccrc/data34/z3478332/WRF/ERA-nudge/","/srv/ccrc/data34/z3478332/WRF/output/ERAI_R2_nudging_notopo_19902009/out/impact/"/)
;type=(/"ERA-nudge","ERA-nudge_notopo"/)

OUTDir = "/srv/ccrc/data45/z3478332/WRF/output/"  

  fin=addfile("/srv/ccrc/data13/z3393020/Analyses/share/geo_em_files/geo_em.d01.narclim.nc","r")
  lat1=wrf_user_getvar(fin,"XLAT_M",-1)
  lon1=wrf_user_getvar(fin,"XLONG_M",-1)
  delete(fin)

   res = True          
     res@mpFillOn = False
     res@mpDataBaseVersion     = "MediumRes"          ; Default is Lowres
     res@mpOutlineDrawOrder    = "PostDraw"           ; Draw map outlines last
     res@gsnDraw         = False
     res@gsnFrame        = False
     res@pmTickMarkDisplayMode = "Always"             ; Turn on map tickmarks
;  res = set_mp_wrf_map_resources(f1[0],res)
     res@mpGridLineDashPattern = 2 ; lat/lon lines as dashed
     res@mpGridAndLimbOn = False
     res@mpGridSpacingF = 10.
     res@mpProjection = "CylindricalEquidistant"
     res@mpMinLonF = 100
  res@lbOrientation     = "Vertical"
  res@mpMaxLonF = 180
  res@mpMinLatF = -50
  res@mpMaxLatF = 0
  res@mpGridLineThicknessF = 0.5
  res@cnFillOn        = True
  res@cnLinesOn       = False
  res@cnFillPalette    = "BlueRed"
  res@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
  res@cnMinLevelValF       = -0.1                ; set min contour level
  res@cnMaxLevelValF       =  0.1              ; set max contour level
  res@cnLevelSpacingF      =  0.01              ; set contour spacing
     res@mpGeophysicalLineThicknessF = 2.0 

    opts_psl = True          
     opts_psl@cnLineColor       = "Black"
     opts_psl@cnInfoLabelOn     = False
     opts_psl@cnLineLabelFontHeightF = 0.01
     opts_psl@cnLineLabelPerimOn = False
     opts_psl@gsnContourLineThicknessesScale = 1.5
     opts_psl@gsnDraw         = False
     opts_psl@gsnFrame        = False
     opts_psl@cnLevelSelectionMode = "ExplicitLevels"
     opts_psl@cnLevels             = (/ -100.,0.05,100./)
     opts_psl@gsnContourPosLineDashPattern = 2


;Stuff for just the sig

  

  Data1=addfile(dirs(0)+"WRF_d01_monthly_850hPa_variability.nc","r")
  p1=Data1->PVO_d01
  Data2=addfile(dirs(1)+"WRF_d01_monthly_850hPa_variability.nc","r")
  p2=Data2->PVO_d01

  tmp=ispan(0,239,1)
  tmp2=mod(tmp,12)+1
  tmp1=tmp/12

  I=ind(tmp2.ge.1.and.tmp2.le.12)
  pdiff=dim_avg_n_Wrap(p2(:,:,I,2)-p1(:,:,I,2),2)   
  pdiff@lat2d = rm_single_dims(lat1)
  pdiff@lon2d = rm_single_dims(lon1)


wks = gsn_open_wks("pdf",OUTDir+"pvo850_diffNoTopo_nonudge_mean_vert")
     opts_psl@tiMainString="Mean sea level pressure"
    map = gsn_csm_contour_map(wks,pdiff,res)
    draw(map)
    frame(wks)
    delete(wks)


