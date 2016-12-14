load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
;load "./WRFUserARW.ncl"

;dirs=(/"/srv/ccrc/data34/z3478332/WRF/ERA-nonudge/","/srv/ccrc/data45/z3478332/WRF/output/ERAI_R2_nonudging_notopo/out/impact/"/)
;type=(/"ERA-nonudge","ERA-nonudge_notopo"/)

dirs=(/"/srv/ccrc/data34/z3478332/WRF/ERA-nudge/","/srv/ccrc/data34/z3478332/WRF/output/ERAI_R2_nudging_notopo_19902009/out/impact/"/)
type=(/"ERA-nudge","ERA-nudge_notopo"/)

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
  res@cnMinLevelValF       = -0.5                ; set min contour level
  res@cnMaxLevelValF       =  0.5              ; set max contour level
  res@cnLevelSpacingF      =  0.05              ; set contour spacing
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

  Data1=addfile(dirs(0)+"WRF_d01_monthly_uppers.nc","r")
  u1=Data1->U_d01
  v1=Data1->V_d01
  w1=(u1^2.+v1^2.)^0.5
  p1=Data1->Z_d01
  s1=1000*((w1(:,:,2,:)-w1(:,:,0,:))/(p1(:,:,2,:)-p1(:,:,0,:)))

  Data2=addfile(dirs(1)+"WRF_d01_monthly_uppers.nc","r")
  u2=Data2->U_d01
  v2=Data2->V_d01
  w2=(u2^2.+v2^2.)^0.5
  p2=Data2->Z_d01
  s2=1000*((w2(:,:,2,:)-w2(:,:,0,:))/(p2(:,:,2,:)-p2(:,:,0,:)))

  tmp=ispan(0,239,1)
  tmp2=mod(tmp,12)+1
  tmp1=tmp/12

  a=dimsizes(p1)
  s1a = new((/a(0),a(1),20/),"float")
  s2a=s1a
  
  do ip=0,19
     I=ind((tmp2.le.12.and.tmp2.ge.1).and.tmp1.eq.ip)
     s1a(:,:,ip)=dim_avg_n_Wrap(s1(:,:,I),2)
     s2a(:,:,ip)=dim_avg_n_Wrap(s2(:,:,I),2)
  end do

  sdiff=dim_avg_n_Wrap(s2a-s1a,2)
  sdiff@lat2d = rm_single_dims(lat1)
  sdiff@lon2d = rm_single_dims(lon1)

  xAve = dim_avg (s1a)              ; calculate means at each grid point 
  yAve = dim_avg (s2a)
  xVar = dim_variance (s1a)         ; calculate variances
  yVar = dim_variance (s2a)
  sigr = 0.05                        ; critical sig lvl for r
  xEqv = equiv_sample_size (s1a, sigr,0)
  yEqv = equiv_sample_size (s2a, sigr,0)                               
  xN   = wgt_areaave (xEqv, 1., 1., 0)    ; wgty could be gaussian weights 
  yN   = wgt_areaave (yEqv, 1., 1., 0) 
  iflag= False                        ; population variance similar
  pval = ttest(xAve,xVar,xN, yAve,yVar,yN, iflag, False) 
  pval@lat2d = rm_single_dims(lat1)
  pval@lon2d = rm_single_dims(lon1)

wks = gsn_open_wks("pdf",OUTDir+"windshear_diffNoTopo_nudge_mean")
     res@tiMainString="Difference in 850-200hPa wind (x10^3 s^-1)"
    map = gsn_csm_contour_map(wks,sdiff,res)
    contour_psl = gsn_csm_contour(wks,pval,opts_psl)    
    overlay(map, contour_psl)
    draw(map)
    frame(wks)
    delete(wks)


