load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
;load "./WRFUserARW.ncl"

begin

  r=2
;  DATADir = "/srv/ccrc/data45/z3478332/WRF/output/ERAI_R"+r+"_nonudging_notopo/out/"
;  CONTDir = "/srv/ccrc/data41/z3444417/Data/WRF/ERAI/R"+r+"/1990-2010/pr/raw/d01/"

DATADir= "/srv/ccrc/data34/z3478332/WRF/output/ERAI_R2_nudging_notopo_19902009/out/"
CONTDir = "/srv/ccrc/data41/z3444417/Data/WRF/ERAI/R"+r+"N/1990-2010/pr/raw/d01/"
  OUTDir="/srv/ccrc/data45/z3478332/WRF/output/"

 outname = "R"+r+"_D01_prlr_nudgenotopo_annanom"

  year1=1990
  year2=2009

  res                 = True
; Set some contouring resources.
  res@cnFillOn        = True
  res@cnLinesOn       = False
  res@cnLineLabelsOn  = False
  res@cnInfoLabelOn   = False
  res@cnLevelSelectionMode = "ExplicitLevels"
  res@cnLevels             = (/-300., -200.,-100., -50., -25., -10., 10., 25., 50.,100.,200.,300./)
  res@gsnDraw         = False
  res@gsnFrame        = False

; Add map resources
  res@mpFillOn              = False
  res@mpDataBaseVersion     = "MediumRes"          ; Default is LowRes
  res@mpOutlineDrawOrder    = "PostDraw"           ; Draw map outlines last
  res@mpGridAndLimbOn       = False                ; Turn off lat/lon lines
  res@pmTickMarkDisplayMode = "Always"             ; Turn on map tickmarks
;  res = set_mp_wrf_map_resources(f1[0],res)
  res@mpLimitMode        = "Corners"               ; Portion of map to zoom
  res@mpLeftCornerLatF   = -50. 
  res@mpLeftCornerLonF   = 100.
  res@mpRightCornerLatF  = 0.
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
  res@gsnMaximize     = False    ; Maximize plot in frame

  fin=addfile("/srv/ccrc/data13/z3393020/Analyses/share/geo_em_files/geo_em.d01.narclim.nc","r")
  lat1=rm_single_dims(wrf_user_getvar(fin,"XLAT_M",-1))
  lon1=rm_single_dims(wrf_user_getvar(fin,"XLONG_M",-1))
  a=dimsizes(lat1)
  default_d01 = new((/a(0),a(1)/),"float")
  default_d01@lat2d = lat1
  default_d01@lon2d = lon1
  notopo_d01 = default_d01
  delete([/a,fin/])

n=0
n2=0
year=year1
do while(year.le.year2)
month=1
do while(month.le.12)

  fname="wrfhrly_d01_"+year+"-"+sprinti("%0.2i",month)+"-01_00:00:00.nc"
  f2 = addfile(DATADir+fname,"r")
  rain_exp2=wrf_user_getvar(f2,"PREC_ACC_NC",-1)
  rain_con2=wrf_user_getvar(f2,"PREC_ACC_C",-1)

  if(n.eq.0) then
    notopo_d01=dim_sum_n_Wrap(rain_exp2,0)+dim_sum_n_Wrap(rain_con2,0)
  else
    notopo_d01=notopo_d01+dim_sum_n_Wrap(rain_exp2,0)+dim_sum_n_Wrap(rain_con2,0)
  end if

  delete([/fname,f2,rain_exp2,rain_con2/])
  
n=n+1
month=month+1
end do

  fname="CCRC_NARCliM_06H_"+year+"_accumulated_pr.nc"
  f1 = addfile(CONTDir+fname,"r")
  rain=f1->pr

  if(n2.eq.0) then
    default_d01=dim_sum_n_Wrap(rain,0)
  else
    default_d01=default_d01+dim_sum_n_Wrap(rain,0)
  end if

  delete([/fname,f1,rain/])
n2=n2+1
year=year+1
end do

year=year-1
diff1=(notopo_d01-default_d01)
diff1@description = "Average Precipitation Difference in "+year1+" to "+year2
diff1@units = "mm"
diff1@lat2d=lat1
diff1@lon2d=lon1

diff1a=100*(notopo_d01-default_d01)/where(default_d01.gt.0,default_d01,default_d01@_FillValue)
diff1a@description= "Average Precipitation Difference in "+year1+" to "+year2
diff1a@units = "%"
diff1a@lat2d=lat1
diff1a@lon2d=lon1

outfile1=OUTDir+outname+"_"+year1+year2+"_mean"

  wks = gsn_open_wks("pdf", outfile1)  ; Open graphics file
      gsn_define_colormap(wks,"precip_diff_12lev")      

  map = gsn_csm_contour_map(wks, diff1, res)
  draw(map)
  frame(wks)
  delete([/map,wks,outfile1/])

  outfile1=OUTDir+outname+"_"+year1+year2+"_PCchange"
  res@cnLevelSelectionMode = "ExplicitLevels"

  delete(res@cnLevels)
  res@cnLevels             = (/ -50,-20,-10,-5,5,10,20,50/)
;  res@cnFillColors         = (/13,12,11,10,8,6,5,4,3/)
res@cnFillColors         = (/3,4,5,6,8,10,11,12,13/)

  wks = gsn_open_wks("pdf", outfile1)  ; Open graphics file
      gsn_define_colormap(wks,"precip_diff_12lev")      

  map = gsn_csm_contour_map(wks, diff1a, res)
  draw(map)
  frame(wks)
  delete([/map,wks,outfile1/])

end


