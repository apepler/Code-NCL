load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
;load "./WRFUserARW.ncl"

  fin=addfile("/srv/ccrc/data13/z3393020/Analyses/share/geo_em_files/geo_em.d01.narclim.nc","r")
  lat1=wrf_user_getvar(fin,"XLAT_M",-1)
  lon1=wrf_user_getvar(fin,"XLONG_M",-1)
  delete(fin)

  OUTDir = "/srv/ccrc/data45/z3478332/WRF/output/"  
  INDir = "/srv/ccrc/data45/z3478332/WRF/output/extracted_data/"  

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
  res@cnMinLevelValF       = -0.5                ; set min contour level
  res@cnMaxLevelValF       =  0.5               ; set max contour level
  res@cnLevelSpacingF      =  0.05               ; set contour spacing

    opts_psl = True          
     opts_psl@cnLineColor       = "Black"
     opts_psl@cnInfoLabelOn     = False
     opts_psl@cnLineLabelFontHeightF = 0.01
     opts_psl@cnLineLabelPerimOn = False
     opts_psl@gsnContourLineThicknessesScale = 2
     opts_psl@gsnDraw         = False
     opts_psl@gsnFrame        = False
     opts_psl@cnLevelSelectionMode = "ExplicitLevels"
     opts_psl@cnLevels             = (/ -100.,0.05,100./)

;Stuff for just the sig

  

  Data1=addfile(INDir+"WRF_d01_850hPa_vars.nc","r")
  p1=Data1->PVO_d01 
  Data2=addfile(INDir+"WRF_d01_850hPa_vars_notopo.nc","r")
  p2=Data2->PVO_d01   

  p2a=dim_avg_n_Wrap(p2,2)   
  p1a=dim_avg_n_Wrap(p1,2)

  pdiff=dim_avg_n_Wrap(p2a-p1a,2)
  pdiff@lat2d = rm_single_dims(lat1)
  pdiff@lon2d = rm_single_dims(lon1)

print("Range: "+min(pdiff)+" to "+max(pdiff))

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

wks = gsn_open_wks("pdf",OUTDir+"pvo_diffNoTopo_nudge")
     opts_psl@tiMainString="850 hPa Potential Vorticity (s-1)"
    map = gsn_csm_contour_map(wks,pdiff,res)
    contour_psl = gsn_csm_contour(wks,pval,opts_psl)    
;    overlay(map, contour_psl)
    draw(map)
    frame(wks)
    delete(wks)


