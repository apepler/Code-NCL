load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

; This produces figure 3 for the GDR paper

begin

; Directories

OUTDir="/srv/ccrc/data45/z3478332/WRF/output/"
outname=OUTDir+"GDRpaper_panel_nudge_nonudge_v2"

contdirs=(/"/srv/ccrc/data34/z3478332/WRF/ERA-nonudge/"/)
datadirs=(/"/srv/ccrc/data45/z3478332/WRF/output/ERAI_R2_nonudging_notopo/out/impact/"/)
type=(/"ERA-nudge","ERA-nonudge"/)

; Latitude/grids 

  fin=addfile("/srv/ccrc/data13/z3393020/Analyses/share/geo_em_files/geo_em.d01.narclim.nc","r")
  lat1=rm_single_dims(wrf_user_getvar(fin,"XLAT_M",-1))
  lat1!0="south_north"
  lat1!1="west_east"
  lon1=rm_single_dims(wrf_user_getvar(fin,"XLONG_M",-1))
  lon1!0="south_north"
  lon1!1="west_east"
  delete(fin)

  lon0=fspan(105,180,151)
  lon0@units="degree_east"
  lon0!0="lon"
  lat0=fspan(-50,-5,91)
  lat0@units="degree_north"
  lat0!0="lat"

  fin=addfile("ESB_mask.nc","r")
  ESB=fin->mask
  latA=fin->lat
  latA@units="degreesN"
  latA!0="lat"
  lonA=fin->lon
  lonA@units="degreesE"
  lonA!0="lon"
  ESB!0="lat"
  ESB!1="lon"
  ESB&lat=latA
  ESB&lon=lonA

; Mapping resources

; Basic map

  res = True          
  res@mpFillOn = False
  res@mpDataBaseVersion     = "MediumRes"          ; Default is Lowres
  res@mpOutlineDrawOrder    = "PostDraw"           ; Draw map outlines last
  res@gsnDraw         = False
  res@gsnFrame        = False
  res@pmTickMarkDisplayMode = "Always"             ; Turn on map tickmarks
  res@mpGridLineDashPattern = 2 ; lat/lon lines as dashed
  res@mpGridAndLimbOn = False
  res@mpGridSpacingF = 10.
  res@mpProjection = "CylindricalEquidistant"
  res@mpGeophysicalLineThicknessF = 2.0 
  res@mpMinLonF = 105
  res@lbOrientation     = "Vertical"
  res@mpMaxLonF = 180
  res@mpMinLatF = -50
  res@mpMaxLatF = -5
  res@mpGridLineThicknessF = 0.5
  res@cnFillOn        = True
  res@cnLinesOn       = False
  res@lbLabelBarOn        = False
  res@gsnStringFontHeightF = 0.02
  res@cnLineLabelsOn = False
 
; Moisture flux

  mres=res
  mres@cnFillPalette    = "BlRe"
  mres@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
  mres@cnMinLevelValF       = -2.                ; set min contour level
  mres@cnMaxLevelValF       =  2.                ; set max contour level
  mres@cnLevelSpacingF      =  0.25               ; set contour spacing
  mres@gsnLeftString       = "Qflux divergence"
  mres@gsnRightString      = "x 1e-5"
  mres@gsnAddCyclic = False

; SLP
  
  sres=res
  sres@cnFillPalette    = "BlRe"
  sres@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
  sres@cnMinLevelValF       = -2.               ; set min contour level
  sres@cnMaxLevelValF       =  2.              ; set max contour level
  sres@cnLevelSpacingF      =  0.25              ; set contour spacing
  sres@gsnLeftString       = "SLP"
  sres@gsnRightString      = "hPa"

; Rain

  pres=res
  pres@cnFillPalette= "precip_diff_12lev"
  pres@cnLevelSelectionMode = "ExplicitLevels"
  pres@cnLevels             = (/ -40,-30,-20,-10,-5,5,10,20,30,40/)
  pres@gsnLeftString       = "Precipitation"
  pres@gsnRightString      = "%"

; For p-values

  opts_psl = True          
  opts_psl@cnInfoLabelOn     = False
  opts_psl@cnLineLabelFontHeightF = 0.01
  opts_psl@cnLineLabelPerimOn = False
  opts_psl@gsnDraw         = False
  opts_psl@gsnFrame        = False

  opts_pval=opts_psl
  opts_pval@cnLineColor       = "Black"
  opts_pval@cnLevelSelectionMode = "ExplicitLevels"
  opts_pval@cnLevels             = (/ -100.,0.05,100./)
  opts_pval@gsnContourPosLineDashPattern = 2
  opts_pval@gsnContourLineThicknessesScale = 1.5

; For ESB boundary
  opts_psl@cnLineColor       = "Gray25"
  opts_psl@cnLevelSelectionMode = "EqualSpacedLevels" ; set equal spaced contour levels
  opts_psl@cnMaxLevelCount = 1	
  opts_psl@cnLineLabelsOn = False
  opts_psl@gsnContourLineThicknessesScale = 2.

; For winds

  vcres                         = True             ; plot mods desired
  vcres@vcRefLengthF            = 0.05            ; define length of vec ref
  vcres@vcGlyphStyle            = "CurlyVector"    ; turn on curly vectors
  vcres@vcRefMagnitudeF           = 5.0             ; define vector ref mag
  vcres@tiMainFontHeightF = 0.02
  vcres@vcRefAnnoString1 = "$VMG$ kg/m/s"
  vcres@gsnLeftString = ""
  vcres@gsnRightString = ""
  vcres@vcMinDistanceF          = 0.017
  vcres@vcRefAnnoOrthogonalPosF = -1.08   ; move ref vector into plot
  vcres@vcVectorDrawOrder         = "PostDraw"
  vcres@gsnDraw         = False
  vcres@gsnFrame        = False
  vcres@vcLineArrowThicknessF = 1.5
  vcres@vcRefAnnoString2On = False

; Now, need to get the six different plots

  wks  = gsn_open_wks("pdf",outname)
  slp_plots  = new(1,graphic)    
  muv_plots = new(1,graphic)   
  rain_plots = new(1,graphic)

  n=0

; First, slp

  Data1=addfile(contdirs(n)+"WRF_d01_monthly_uvpr.nc","r")
  p1=Data1->SLP_d01
  Data2=addfile(datadirs(n)+"WRF_d01_monthly_uvpr.nc","r")
  p2=Data2->SLP_d01

  tmp=ispan(0,239,1)
  tmp2=mod(tmp,12)+1
  tmp1=tmp/12

  a=dimsizes(p1)
  p1a = new((/a(0),a(1),20/),"float")
  p2a=p1a
  
  do ip=0,19
     I=ind((tmp2.ge.1.and.tmp2.le.12).and.tmp1.eq.ip)
     p2a(:,:,ip)=dim_avg_n_Wrap(p2(:,:,I),2)   
     p1a(:,:,ip)=dim_avg_n_Wrap(p1(:,:,I),2)
  end do

  pdiff=dim_avg_n_Wrap(p2a-p1a,2)
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

  slp_plots(n) = gsn_csm_contour_map(wks,pdiff,sres)
  contour_psl = gsn_csm_contour(wks,pval,opts_pval)    
  overlay(slp_plots(n), contour_psl)

  delete([/Data1,Data2,tmp,tmp1,tmp2,a,p1,p2,p1a,p2a,I,pdiff/])
  delete([/xAve,yAve,xVar,yVar,sigr,xEqv,yEqv,xN,yN,pval,contour_psl/])

; Then, MUV

  Data1=addfile(contdirs(n)+"WRF_d01_monthly_moistflux.nc","r")
  u1=Data1->Umoist_d01
  v1=Data1->Vmoist_d01

  Data2=addfile(datadirs(n)+"WRF_d01_monthly_moistflux.nc","r")
  u2=Data2->Umoist_d01
  v2=Data2->Vmoist_d01

  tmp=ispan(0,239,1)
  tmp2=mod(tmp,12)+1
  tmp1=tmp/12

  a=dimsizes(u1)
  u1a = new((/20,a(0),a(1)/),"float")
  u1a!0="time"
  u1a!1=lat1!0
  u1a!2=lat1!1
  u1a@lat2d=lat1
  u1a@lon2d=lon1
  u2a=u1a
  v1a=u1a
  v2a=v1a
  
  do ip=0,19
     I=ind(tmp2.ge.1.and.tmp2.le.12.and.tmp1.eq.ip)
     u2a(ip,:,:)=(/dim_avg_n_Wrap(u2(:,:,I),2)/)   
     u1a(ip,:,:)=(/dim_avg_n_Wrap(u1(:,:,I),2)/)
     v2a(ip,:,:)=(/dim_avg_n_Wrap(v2(:,:,I),2)/)   
     v1a(ip,:,:)=(/dim_avg_n_Wrap(v1(:,:,I),2)/)
  end do

; Now, regrid to a regular grid

   Opt3                = True
   Opt3@SrcRegional    = True             ; These are necessary
   Opt3@DstRegional    = True
   Opt3@DstGridLat = lat0
   Opt3@DstGridLon = lon0
   Opt3@ForceOverwrite = True
   u1b = ESMF_regrid(u1a,Opt3)   ; Do the regridding - 0.5 degreees
   u2b = ESMF_regrid(u2a,Opt3)   ; Do the regridding - 0.5 degreees
   v1b = ESMF_regrid(v1a,Opt3)   ; Do the regridding - 0.5 degreees
   v2b = ESMF_regrid(v2a,Opt3)   ; Do the regridding - 0.5 degreees

  udiff=dim_avg_n_Wrap(u2b-u1b,0)
  udiff!0="lat"
  udiff!1="lon"
  udiff&lat=lat0
  udiff&lon=lon0

  vdiff=dim_avg_n_Wrap(v2b-v1b,0)
  copy_VarMeta(udiff,vdiff)

  div1=uv2dv_cfd(u1b,v1b,lat0,lon0,0)
  div2=uv2dv_cfd(u2b,v2b,lat0,lon0,0)
  divdiff=dim_avg_n_Wrap(div2-div1,0)
  copy_VarMeta(udiff,divdiff)
  divdiff=divdiff/1e-5

  muv_plots(n) = gsn_csm_contour_map(wks,divdiff,mres)
  wind = gsn_csm_vector(wks,udiff,vdiff,vcres)
  overlay(muv_plots(n),wind)

  delete([/Data1,Data2,tmp,tmp1,tmp2,a,I,div1,div2,divdiff,Opt3/])
  delete([/u1,v1,u2,v2,u1a,u2a,v1a,v2a,u1b,v1b,u2b,v2b,udiff,vdiff/])

; Finally, precip

  f1=addfile(contdirs(n)+"WRF_d01_monthly_uvpr.nc","r")
  r1=f1->PRCP_d01
  f2=addfile(datadirs(n)+"WRF_d01_monthly_uvpr.nc","r")
  r2=f2->PRCP_d01

  tmp=ispan(0,239,1)
  tmp2=mod(tmp,12)+1
  tmp1=tmp/12

  a=dimsizes(r1)
  r1a = new((/20,a(0),a(1)/),"float")
  r2a=r1a
  
  do ip=0,19
     I=ind((tmp2.ge.1.or.tmp2.le.12).and.tmp1.eq.ip)
     r2a(ip,:,:)=dim_sum_n_Wrap(r2(:,:,I),2)   
     r1a(ip,:,:)=dim_sum_n_Wrap(r1(:,:,I),2)
  end do

  diff1a=100*dim_sum_n_Wrap(r2a-r1a,0)/where(dim_sum_n_Wrap(r1a,0).gt.0,dim_sum_n_Wrap(r1a,0),r1a@_FillValue)
  diff1a@description= "Average Precipitation Difference in 1990-2009"
  diff1a@units = "%"
  diff1a@lat2d=lat1
  diff1a@lon2d=lon1

  xAve = dim_avg_n(r1a,0)              ; calculate means at each grid point 
  yAve = dim_avg_n(r2a,0)
  xVar = dim_variance_n(r1a,0)         ; calculate variances
  yVar = dim_variance_n(r2a,0)
  sigr = 0.05                        ; critical sig lvl for r
  xEqv = equiv_sample_size (r1a, sigr,0)
  yEqv = equiv_sample_size (r2a, sigr,0)                               
  xN   = wgt_areaave (xEqv, 1., 1., 0)    ; wgty could be gaussian weights 
  yN   = wgt_areaave (yEqv, 1., 1., 0) 
  iflag= False                        ; population variance similar
  pval = ttest(xAve,xVar,xN, yAve,yVar,yN, iflag, False) 
  pval@lat2d = rm_single_dims(lat1)
  pval@lon2d = rm_single_dims(lon1)

  rain_plots(n) = gsn_csm_contour_map(wks,diff1a,pres)
  contour_psl = gsn_csm_contour(wks,pval,opts_pval)    
  overlay(rain_plots(n), contour_psl)

  contourP = gsn_csm_contour(wks,ESB,opts_psl)   
  overlay(rain_plots(n), contourP)

  delete([/f1,f2,tmp,tmp1,tmp2,a,I,r1,r2,r1a,r2a,diff1a,contourP/])
  delete([/xAve,yAve,xVar,yVar,sigr,xEqv,yEqv,xN,yN,pval,contour_psl/])


; Finally, once made, now we need to plot them
;---Resources for paneling
delete(res)
    res                   = True              ; modify the panel plot
    res@gsnFrame          = False             ; don't advance frame yet
    res@gsnPanelBottom    = 0.66              ; top 2/3 of frame
    res@gsnPanelLabelBar  = True              ; add common colorbar
    res@lbOrientation     = "vertical"
    res@pmLabelBarWidthF  = 0.075             ; make thinner
    res@gsnPanelFigureStrings= (/"a)"/)
    res@amJust   = "TopLeft"

    gsn_panel(wks,slp_plots,(/1,1/),res)

;---Panel the diff plots at the bottom
    res@gsnPanelTop       = 0.66   ; lower 1/3 plus some white space
    res@gsnPanelBottom    = 0.33              ; top 2/3 of frame
    res@gsnPanelFigureStrings= (/"b)"/)

    gsn_panel(wks,muv_plots,(/1,1/),res)

    res@gsnPanelTop       = 0.33  ; lower 1/3 plus some white space
    res@gsnPanelBottom    =  0.01
    res@gsnPanelFigureStrings= (/"c)"/)

    gsn_panel(wks,rain_plots,(/1,1/),res)

    frame(wks)

end


