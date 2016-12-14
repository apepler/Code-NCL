load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
;load "./WRFUserARW.ncl"

dirs=(/"/srv/ccrc/data34/z3478332/WRF/ERA-nudge/","/srv/ccrc/data34/z3478332/WRF/ERA-nonudge/","/srv/ccrc/data45/z3478332/WRF/output/ERAI_R2_nonudging_notopo/out/impact/"/)
type=(/"ERA-nudge","ERA-nonudge","ERA-nonudge_notopo"/)

OUTDir = "/srv/ccrc/data45/z3478332/WRF/output/"  

  fin=addfile("/srv/ccrc/data13/z3393020/Analyses/share/geo_em_files/geo_em.d01.narclim.nc","r")
  lat1=wrf_user_getvar(fin,"XLAT_M",-1)
  lon1=wrf_user_getvar(fin,"XLONG_M",-1)
  delete(fin)

   opts_psl = True          
     opts_psl@cnLineColor       = "Blue"
     opts_psl@cnInfoLabelOn     = False
     opts_psl@cnLineLabelFontHeightF = 0.01
     opts_psl@cnLineLabelPerimOn = False
     opts_psl@gsnContourLineThicknessesScale = 1.5
     opts_psl@gsnDraw         = False
     opts_psl@gsnFrame        = False
     opts_psl@cnLevelSpacingF = 20.
     opts_psl@pmTickMarkDisplayMode = "Always"             ; Turn on map tickmarks
;  res = set_mp_wrf_map_resources(f1[0],res)
     opts_psl@mpDataBaseVersion     = "MediumRes"          ; Default is LowRes
     opts_psl@mpGridLineDashPattern = 2 ; lat/lon lines as dashed
     opts_psl@mpGridAndLimbOn = True
     opts_psl@mpGridSpacingF = 10.
     opts_psl@mpProjection = "CylindricalEquidistant"
     opts_psl@mpMinLonF = 100
  opts_psl@mpMaxLonF = 180
  opts_psl@mpMinLatF = -50
  opts_psl@mpMaxLatF = 0
     opts_psl@mpGridLineThicknessF = 0.5

t=1
do while(t.lt.dimsizes(type))
  Data=addfile(dirs(t)+"WRF_d01_monthly_gv.nc","r")

p=Data->GV_d01

tmp=ispan(0,239,1)
tmp2=mod(tmp,12)+1
I=ind(tmp2.ge.1.and.tmp2.le.12)

;  p2=dim_avg_n_Wrap(p(:,:,I),2)
p2=p(:,:,0)
  p2@lat2d = rm_single_dims(lat1)
  p2@lon2d = rm_single_dims(lon1)

wks = gsn_open_wks("pdf",OUTDir+"gv_mean_"+type(t))
     opts_psl@tiMainString="Mean 500hPa Geostrophic Vorticity"
    contour_psl = gsn_csm_contour_map(wks,p2,opts_psl)
    draw(contour_psl)
    frame(wks)
    delete(wks)

t=t+1
end do
