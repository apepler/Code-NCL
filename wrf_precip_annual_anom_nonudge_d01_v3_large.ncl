load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
;load "./WRFUserARW.ncl"

begin
  OUTDir="/srv/ccrc/data45/z3478332/WRF/output/"
  CONTDir="/srv/ccrc/data34/z3478332/WRF/ERA-nonudge/"
  DATADir="/srv/ccrc/data45/z3478332/WRF/output/ERAI_R2_nonudging_notopo/out/impact/"

  r=2
  year1=1990
  year2=2009

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

  res                 = True
; Set some contouring resources.
  res@cnFillOn        = True
  res@cnLinesOn       = False
  res@cnLineLabelsOn  = False
  res@cnInfoLabelOn   = False
  res@cnLevelSelectionMode = "ExplicitLevels"
  res@cnLevels             = (/-500., -250.,-100., -50., -25., -10., 10., 25., 50.,100.,250.,500./)
  res@gsnDraw         = False
  res@gsnFrame        = False

; Add map resources
  res@mpFillOn              = False
  res@mpDataBaseVersion     = "MediumRes"          ; Default is LowRes
  res@mpOutlineDrawOrder    = "PostDraw"           ; Draw map outlines last
  res@mpGridAndLimbOn       = False                ; Turn off lat/lon lines
  res@pmTickMarkDisplayMode = "Always"             ; Turn on map tickmarks
;  res = set_mp_wrf_map_resources(f1[0],res)
  res@mpMinLonF = 100
  res@mpMaxLonF = 180
  res@mpMinLatF = -50
  res@mpMaxLatF = 0

    res@mpGridLineDashPattern = 2
  res@mpGridLineThicknessF = 0.5
  res@mpProjection = "CylindricalEquidistant"
  res@lbOrientation = "vertical"
  
; Add label bar resources
  res@lbLabelAutoStride = True 
  res@lbBoxMinorExtentF        = 0.13
  res@lbLabelFontHeightF       = 0.012

  res@gsnLeftStringFontHeightF = 0.01
  res@gsnRightStringFontHeightF = 0.008
  res@gsnMaximize     = False    ; Maximize plot in frame
  res@mpGeophysicalLineThicknessF = 2

    opts_psl = True          
     opts_psl@cnLineColor       = "red"
     opts_psl@cnInfoLabelOn     = False
     opts_psl@cnLineLabelFontHeightF = 0.01
     opts_psl@cnLineLabelPerimOn = False
     opts_psl@gsnContourLineThicknessesScale = 2
     opts_psl@gsnDraw         = False
     opts_psl@gsnFrame        = False
     opts_psl@cnLevelSelectionMode = "EqualSpacedLevels" ; set equal spaced contour levels
     opts_psl@cnMaxLevelCount = 1	
     opts_psl@cnLineLabelsOn = False


  fin=addfile("/srv/ccrc/data13/z3393020/Analyses/share/geo_em_files/geo_em.d01.narclim.nc","r")
  lat1=rm_single_dims(wrf_user_getvar(fin,"XLAT_M",-1))
  lon1=rm_single_dims(wrf_user_getvar(fin,"XLONG_M",-1))
  a=dimsizes(lat1)
  default_d01 = new((/a(0),a(1),3/),"float")
  default_d01@lat2d = lat1
  default_d01@lon2d = lon1
  notopo_d01 = default_d01
  delete([/a,fin/])

f1=addfile(CONTDir+"WRF_d01_monthly_uvpr.nc","r")
r1=f1->PRCP_d01
f2=addfile(DATADir+"WRF_d01_monthly_uvpr.nc","r")
r2=f2->PRCP_d01

  tmp=ispan(0,239,1)
  tmp2=mod(tmp,12)+1
  tmp1=tmp/12

  a=dimsizes(r1)
  r1a = new((/20,a(0),a(1)/),"float")
  r2a=r1a
  
  do ip=0,19
     I=ind((tmp2.ge.1.and.tmp2.le.12).and.tmp1.eq.ip)
     r2a(ip,:,:)=dim_sum_n_Wrap(r2(:,:,I),2)   
     r1a(ip,:,:)=dim_sum_n_Wrap(r1(:,:,I),2)
  end do

  diff1=dim_avg_n_Wrap(r2a-r1a,0)
  diff1@description = "Average Precipitation Difference in 1990-2009"
  diff1@units = "mm"
  diff1@lat2d=lat1
  diff1@lon2d=lon1

diff1a=100*dim_sum_n_Wrap(r2a-r1a,0)/where(dim_sum_n_Wrap(r1a,0).gt.0,dim_sum_n_Wrap(r1a,0),r1a@_FillValue)
diff1a@description= "Average Precipitation Difference in 1990-2009"
diff1a@units = "%"
diff1a@lat2d=lat1
diff1a@lon2d=lon1

outfile1=OUTDir+"D01_prlr_nonudgevnotopo_annanom_mean_ESB_large"

  wks = gsn_open_wks("pdf", outfile1)  ; Open graphics file
      gsn_define_colormap(wks,"precip_diff_12lev")      

 contourP = gsn_csm_contour(wks,ESB,opts_psl)    
  map = gsn_csm_contour_map(wks, diff1, res)
  overlay(map,contourP)
  draw(map)
  frame(wks)
  delete([/map,wks,outfile1/])

  outfile1=OUTDir+"D01_prlr_nonudgevnotopo_annanom_mean_PC_ESB_large"
  res@cnLevelSelectionMode = "ExplicitLevels"

  delete(res@cnLevels)
;  res@cnLevels             = (/ -40,-30,-20,-10,10,20,30,40/)
res@cnLevels             = (/ -40,-30,-20,-10,-5,5,10,20,30,40/)
;  res@cnFillColors         = (/13,12,11,10,8,6,5,4,3/)
res@cnFillColors         = (/2,3,4,5,6,8,10,11,12,13,14/)

  wks = gsn_open_wks("pdf", outfile1)  ; Open graphics file
      gsn_define_colormap(wks,"precip_diff_12lev")      

  contourP = gsn_csm_contour(wks,ESB,opts_psl)   
  map = gsn_csm_contour_map(wks, diff1a, res)
  overlay(map,contourP)
  draw(map)
  frame(wks)
  delete([/map,wks,outfile1/])

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

  outfile1=OUTDir+"D01_prlr_nonnudgevnotopo_annanom_mean_PC_ESB_sig_large"
  wks = gsn_open_wks("pdf", outfile1)  ; Open graphics file
      gsn_define_colormap(wks,"precip_diff_12lev")      

  diff1b=where(pval.lt.0.05,diff1a,diff1a@_FillValue)
  copy_VarMeta(diff1a,diff1b)

  contourP = gsn_csm_contour(wks,ESB,opts_psl)   
  map = gsn_csm_contour_map(wks, diff1b, res)
  overlay(map,contourP)
    draw(map)
    frame(wks)
    delete(wks)



end


