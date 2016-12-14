load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

; This produces figure 10 for the GDR paper

begin

; Directories

OUTDir="/srv/ccrc/data45/z3478332/WRF/output/"
outname=OUTDir+"GDRpaper_panel_nonudge_200hPa"

dirs=(/"/srv/ccrc/data34/z3478332/WRF/ERA-nonudge/","/srv/ccrc/data45/z3478332/WRF/output/ERAI_R2_nonudging_notopo/out/impact/"/)

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
  res@gsnStringFontHeightF = 0.02
  res@vpwidthF=0.6

; SLP
  
  sres=res
  sres@cnFillPalette    = "BlRe"
  sres@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
  sres@cnMinLevelValF       = -25.                ; set min contour level
  sres@cnMaxLevelValF       =  25.              ; set max contour level
  sres@cnLevelSpacingF      =  2.5              ; set contour spacing
  sres@gsnLeftString       = "200hPa height"
  sres@gsnRightString      = "m"
  sres@cnFillOn        = True
  sres@cnLinesOn       = False
  sres@mpOutlineDrawOrder    = "PostDraw"           ; Draw map outlines last
 sres@vpXF             = 0.08                  ; position and sizes
 sres@vpYF             = 0.90                  ; for XY plot
 sres@vpWidthF         = 0.40
 sres@vpHeightF        = 0.80


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

; For winds

  vcres                         = True             ; plot mods desired
  vcres@vcRefLengthF            = 0.05            ; define length of vec ref
  vcres@vcGlyphStyle            = "CurlyVector"    ; turn on curly vectors
  vcres@vcRefMagnitudeF           = 5.0             ; define vector ref mag
  vcres@tiMainFontHeightF = 0.02
  vcres@vcRefAnnoString1 = "$VMG$ m/s"
  vcres@vcMinDistanceF          = 0.017
  vcres@vcRefAnnoOrthogonalPosF = -1   ; move ref vector into plot
  vcres@vcLineArrowThicknessF = 1
  vcres@vcRefAnnoString2On = False
  vcres@gsnDraw         = False
  vcres@gsnFrame        = False
  res@gsnLeftString       = "200hPa vector wind"
  res@gsnRightString      = "m/s"
  vcres@vcMinAnnoArrowSpaceF = 0.0
 res@vpXF             = 0.6                  ; position and sizes
 res@vpYF             = 0.90                  ; for XY plot
 res@vpWidthF         = 0.40
 res@vpHeightF        = 0.80
;  vcres@gsnMaximize = True

; Now, need to get the plots

  wtype           = "eps"
  wtype@wkPaperWidthF  = 25
  wtype@wkPaperHeightF = 10
;  wtype@wkOrientation="portrait"
  wks = gsn_open_wks(wtype,outname)                 ; open a p file

  Data1=addfile(dirs(0)+"WRF_d01_monthly_uppers.nc","r")
  p1=Data1->Z_d01
  u1=Data1->U_d01
  v1=Data1->V_d01

  Data2=addfile(dirs(1)+"WRF_d01_monthly_uppers.nc","r")
  p2=Data2->Z_d01
  u2=Data2->U_d01
  v2=Data2->V_d01

  tmp=ispan(0,239,1)
  tmp2=mod(tmp,12)+1
  tmp1=tmp/12

  a=dimsizes(p1)
  p1a = new((/a(0),a(1),20/),"float")
  p2a=p1a
  
  do ip=0,19
     I=ind((tmp2.le.12.and.tmp2.ge.1).and.tmp1.eq.ip)
     p2a(:,:,ip)=dim_avg_n_Wrap(p2(:,:,2,I),2)   
     p1a(:,:,ip)=dim_avg_n_Wrap(p1(:,:,2,I),2)
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

  plots(0) = gsn_csm_contour_map(wks,pdiff,sres)
  contour_psl = gsn_csm_contour(wks,pval,opts_pval)    
  overlay(plots(0), contour_psl)


  a=dimsizes(u1)
  u1a = new((/a(0),a(1),20/),"float")
  u2a=u1a
  v1a=u1a
  v2a=v1a

  do ip=0,19
     I=ind(tmp2.ge.1.and.tmp2.le.12.and.tmp1.eq.ip)
     u2a(:,:,ip)=dim_avg_n_Wrap(u2(:,:,2,I),2)   
     u1a(:,:,ip)=dim_avg_n_Wrap(u1(:,:,2,I),2)
     v2a(:,:,ip)=dim_avg_n_Wrap(v2(:,:,2,I),2)   
     v1a(:,:,ip)=dim_avg_n_Wrap(v1(:,:,2,I),2)
  end do

  udiff=dim_avg_n_Wrap(u2a-u1a,2)
  udiff@lat2d = rm_single_dims(lat1)
  udiff@lon2d = rm_single_dims(lon1)

  vdiff=dim_avg_n_Wrap(v2a-v1a,2)
  vdiff@lat2d = rm_single_dims(lat1)
  vdiff@lon2d = rm_single_dims(lon1)

  plots(1) = gsn_csm_map(wks,res)
  wind = gsn_csm_vector(wks,udiff,vdiff,vcres)
  overlay(plots(1),wind)

delete(res)
    res                   = True              ; modify the panel 
;    res@gsnPanelFigureStrings= (/"a)","b)"/)
;    res@amJust   = "TopLeft"
    res@gsnMaximize = True
;    res@gsnPaperMargin = 0.1
;    res@gsnPanelYWhiteSpacePercent = 0.0

    gsn_panel(wks,plots,(/1,2/),res)
    frame(wks)

end


