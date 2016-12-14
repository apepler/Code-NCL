load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"
;load "./WRFUserARW.ncl"

;dirs=(/"/srv/ccrc/data34/z3478332/WRF/ERA-nonudge/","/srv/ccrc/data45/z3478332/WRF/output/ERAI_R2_nonudging_notopo/out/impact/"/)
dirs=(/"/srv/ccrc/data34/z3478332/WRF/ERA-nudge/","/srv/ccrc/data34/z3478332/WRF/output/ERAI_R2_nudging_notopo_19902009/out/impact/"/)
type=(/"ERA-nudge","ERA-nudge_notopo"/)

OUTDir = "/srv/ccrc/data45/z3478332/WRF/output/"  

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
     res@mpGeophysicalLineThicknessF = 2.0 
     res@mpMinLonF = 105
  res@lbOrientation     = "Vertical"
  res@mpMaxLonF = 180
  res@mpMinLatF = -50
  res@mpMaxLatF = -5
  res@mpGridLineThicknessF = 0.5
  res@cnFillOn        = True
  res@cnLinesOn       = False
  res@cnFillPalette    = "BlueRed"
  res@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
  res@cnMinLevelValF       = -2.                ; set min contour level
  res@cnMaxLevelValF       =  2.                ; set max contour level
  res@cnLevelSpacingF      =  0.2               ; set contour spacing
  res@gsnAddCyclic = False

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


  vcres                         = True             ; plot mods desired
  vcres@vcRefLengthF            = 0.05            ; define length of vec ref
  vcres@vcGlyphStyle            = "CurlyVector"    ; turn on curly vectors
  vcres@vcRefMagnitudeF           = 5.0             ; define vector ref mag
;  vcres@mpMinLonF = 100
;  vcres@mpMaxLonF = 180
;  vcres@mpMinLatF = -50
;  vcres@mpMaxLatF = 0
;  vcres@mpFillOn                   = False               ; turn off gray map
;  vcres@mpOutlineDrawOrder         = "PreDraw"           ; draw outline first
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

  Data1=addfile(dirs(0)+"WRF_d01_monthly_moistflux.nc","r")
  u1=Data1->Umoist_d01
  v1=Data1->Vmoist_d01

  Data2=addfile(dirs(1)+"WRF_d01_monthly_moistflux.nc","r")
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

  xAve = dim_avg_n (div1,0)              ; calculate means at each grid point 
  yAve = dim_avg_n (div2,0)
  xVar = dim_variance_n (div1,0)         ; calculate variances
  yVar = dim_variance_n (div2,0)
  sigr = 0.05                        ; critical sig lvl for r
  xEqv = equiv_sample_size (div1, sigr,0)
  yEqv = equiv_sample_size (div2, sigr,0)                               
  xN   = wgt_areaave (xEqv, 1., 1., 0)    ; wgty could be gaussian weights 
  yN   = wgt_areaave (yEqv, 1., 1., 0) 
  iflag= False                        ; population variance similar
  pval = ttest(xAve,xVar,xN, yAve,yVar,yN, iflag, False) 

wks = gsn_open_wks("pdf",OUTDir+"Mflux_nudge_diffNoTopo_mean_divergence_vert")
vcres@tiMainString = "Mean 1000-500 hPa moisture flux divergence (1e-5)"
    map = gsn_csm_contour_map(wks,divdiff,res)
    contour_psl = gsn_csm_contour(wks,pval,opts_psl)    
    wind = gsn_csm_vector(wks,udiff,vdiff,vcres)
    overlay(map, contour_psl)
    overlay(map,wind)
    draw(map)
    frame(wks)

delete(wks)
