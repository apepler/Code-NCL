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
  res@mpMaxLonF = 180
  res@mpMinLatF = -50
  res@mpMaxLatF = 0
  res@mpGridLineThicknessF = 0.5
  res@cnFillOn        = True
  res@cnLinesOn       = False
  res@cnFillPalette    = "BlueRed"
  res@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
  res@cnMinLevelValF       = -10.               ; set min contour level
  res@cnMaxLevelValF       =  10.             ; set max contour level
  res@cnLevelSpacingF      =  1.              ; set contour spacing
     res@mpGeophysicalLineThicknessF = 2.0 

    opts_psl = True          
     opts_psl@cnLineColor       = "Black"
     opts_psl@cnInfoLabelOn     = False
     opts_psl@cnLineLabelFontHeightF = 0.01
     opts_psl@cnLineLabelPerimOn = False
     opts_psl@gsnDraw         = False
     opts_psl@gsnFrame        = False
     opts_psl@cnLevelSelectionMode = "ExplicitLevels"
     opts_psl@cnLevels             = (/ -100.,0.05,100./)
     opts_psl@gsnContourPosLineDashPattern = 2
     opts_psl@gsnContourLineThicknessesScale = 1.5

;Stuff for just the sig

  

  Data1=addfile(dirs(0)+"WRF_d01_monthly_500hPa_vars.nc","r")
  p1=Data1->PVO_d01
  Data2=addfile(dirs(1)+"WRF_d01_monthly_500hPa_vars.nc","r")
  p2=Data2->PVO_d01

  tmp=ispan(0,239,1)
  tmp2=mod(tmp,12)+1
  tmp1=tmp/12

  a=dimsizes(p1)
  p1a = new((/a(0),a(1),20/),"float")
  p2a=p1a
  
  do ip=0,19
     I=ind((tmp2.le.12.and.tmp2.ge.1).and.tmp1.eq.ip)
     p2a(:,:,ip)=-dim_avg_n_Wrap(p2(:,:,I),2) 
     p1a(:,:,ip)=-dim_avg_n_Wrap(p1(:,:,I),2)
  end do

  pdiff=dim_avg_n_Wrap(100*((p2a/p1a)-1),2)
  pdiff@lat2d = rm_single_dims(lat1)
  pdiff@lon2d = rm_single_dims(lon1)

  xAve = dim_avg (p1a)              ; calculate means at each grid point 
  yAve = dim_avg (p2a)
  xVar = dim_variance (p1a)         ; calculate variances
  yVar = dim_variance (p2a)
  sigr = 0.05                        ; critical sig lvl for r
  xEqv = equiv_sample_size (p1a, sigr,0)
  yEqv = equiv_sample_size (p2a, sigr,0)                               
  xN   = wgt_areaave (xEqv, 1., 1., 0)    ; wgty could be gaussian weights 
  yN   = wgt_areaave (yEqv, 1., 1., 0) 
  iflag= False                        ; population variance similar
  pval = ttest(xAve,xVar,xN, yAve,yVar,yN, iflag, False) 
  pval@lat2d = rm_single_dims(lat1)
  pval@lon2d = rm_single_dims(lon1)

wks = gsn_open_wks("pdf",OUTDir+"pvo500_diffNoTopo_nudge_percent")
     opts_psl@tiMainString="500 hPa Potential Vorticity (- %)"
    map = gsn_csm_contour_map(wks,pdiff,res)
    contour_psl = gsn_csm_contour(wks,pval,opts_psl)    
    overlay(map, contour_psl)
    draw(map)
    frame(wks)
    delete(wks)


