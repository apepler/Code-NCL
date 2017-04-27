load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
;load "./WRFUserARW.ncl"

dirs=(/"/srv/ccrc/data34/z3478332/WRF/ERA-nonudge/","/srv/ccrc/data45/z3478332/WRF/output/ERAI_R2_nonudging_notopo/out/impact/"/)
type=(/"ERA-nonudge","ERA-nonudge_notopo"/)
ECLDIR="/srv/ccrc/data34/z3478332/ECLtracks/outputUM_"
cat=(/"p100_rad2cv1_2","p100_rad2cv1"/)
cat2="rad2_p100_cv1.0"
dom="d01"
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
  res@cnMinLevelValF       = -0.1                ; set min contour level
  res@cnMaxLevelValF       =  0.1              ; set max contour level
  res@cnLevelSpacingF      =  0.01              ; set contour spacing
  res@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
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

  levels=(/1000,925,850,500/)

  Data1=addfile(dirs(0)+"ECLcomposites_"+type(0)+"_d01_rad2_p100_cv1.0_vort.nc","r")
  p1a=Data1->PVO_d01
  Data2=addfile(dirs(1)+"ECLcomposites_"+type(1)+"_d01_rad2_p100_cv1.0_vort.nc","r")
  p2a=Data2->PVO_d01

  filename = ECLDIR+type(0)+"/"+cat(0)+"/"+dom+"/"+"ECLfixes_"+type(0)+"_"+dom+"_"+cat2+"_typing_impactsC2.csv"
  read_data= asciiread(filename,-1,"string")
  data      = read_data(1:)       ; Get rid of first line which is a header.
  loc = tointeger(str_get_field(data,11,","))
  I=ind(loc.eq.1)
  fix1 = tointeger(str_get_field(data(I),3,","))
  delete([/filename,read_data,data,loc,I/])
  filename = ECLDIR+type(1)+"/"+cat(1)+"/"+dom+"/"+"ECLfixes_"+type(1)+"_"+dom+"_"+cat2+"_typing_impactsC2.csv"
  read_data= asciiread(filename,-1,"string")
  data      = read_data(1:)       ; Get rid of first line which is a header.
  loc = tointeger(str_get_field(data,11,","))
  I=ind(loc.eq.1)
  fix2 = tointeger(str_get_field(data(I),3,","))
; What about only ECL genesis

  l=1

  I1=ind(fix1.eq.1)
  I2=ind(fix2.eq.1)
  pdiff=dim_avg_n_Wrap(p2a(:,:,l,:),2)-dim_avg_n_Wrap(p1a(:,:,l,:),2)
  pdiff@lat2d = rm_single_dims(lat1)
  pdiff@lon2d = rm_single_dims(lon1)

  xAve = dim_avg (p1a(:,:,l,:))              ; calculate means at each grid point 
  yAve = dim_avg (p2a(:,:,l,:))
  xVar = dim_variance (p1a(:,:,l,:))         ; calculate variances
  yVar = dim_variance (p2a(:,:,l,:))
  sigr = 0.05                        ; critical sig lvl for r
  xEqv = equiv_sample_size (p1a(:,:,l,:), sigr,0)
  yEqv = equiv_sample_size (p2a(:,:,l,:), sigr,0)                               
  xN   = wgt_areaave (xEqv, 1., 1., 0)    ; wgty could be gaussian weights 
  yN   = wgt_areaave (yEqv, 1., 1., 0) 
  iflag= False                        ; population variance similar
  pval = ttest(xAve,xVar,xN, yAve,yVar,yN, iflag, False) 
  pval@lat2d = rm_single_dims(lat1)
  pval@lon2d = rm_single_dims(lon1)

wks = gsn_open_wks("pdf",OUTDir+"pvo"+levels(l)+"_diffNoTopo_nonudge_ECLdays")
     opts_psl@tiMainString="Mean potential vorticity at "+levels(l)+"hPa"
    map = gsn_csm_contour_map(wks,pdiff,res)
    contour_psl = gsn_csm_contour(wks,pval,opts_psl)    
    overlay(map, contour_psl)
    draw(map)
    frame(wks)
    delete(wks)

  res@cnMinLevelValF       = -1.                ; set min contour level
  res@cnMaxLevelValF       =  1.              ; set max contour level
  res@cnLevelSpacingF      =  0.1              ; set contour spacing
wks = gsn_open_wks("pdf",OUTDir+"pvo"+levels(l)+"_NoTopo_ECLdays")
     opts_psl@tiMainString="Mean potential vorticity at "+levels(l)+"hPa"
tmp=dim_avg_n_Wrap(p1a(:,:,l,:),2)
  tmp@lat2d = rm_single_dims(lat1)
  tmp@lon2d = rm_single_dims(lon1)

    map = gsn_csm_contour_map(wks,tmp,res)
    draw(map)
    frame(wks)
    delete(wks)


