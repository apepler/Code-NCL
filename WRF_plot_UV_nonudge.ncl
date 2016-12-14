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


  vcres                         = True             ; plot mods desired
  vcres@vcRefLengthF            = 0.05            ; define length of vec ref
  vcres@vcGlyphStyle            = "CurlyVector"    ; turn on curly vectors
  vcres@vcRefMagnitudeF           = 5.0             ; define vector ref mag
  vcres@mpMinLonF = 100
  vcres@mpMaxLonF = 180
  vcres@mpMinLatF = -50
  vcres@mpMaxLatF = 0
  vcres@mpFillOn                   = False               ; turn off gray map
  vcres@mpOutlineDrawOrder         = "PreDraw"           ; draw outline first
  vcres@tiMainFontHeightF = 0.02
  vcres@vcRefAnnoString1 = "$VMG$ m/s"
  vcres@gsnLeftString = ""
  vcres@gsnRightString = ""
vcres@vcMinDistanceF          = 0.017

t=0
do while(t.lt.dimsizes(type))
  Data=addfile(dirs(t)+"WRF_d01_monthly_uvpr.nc","r")

u=Data->U_d01
v=Data->V_d01

tmp=ispan(0,239,1)
tmp2=mod(tmp,12)+1
I=ind(tmp2.ge.9.and.tmp2.le.11)

u2=dim_avg_n_Wrap(u(:,:,I),2)
v2=dim_avg_n_Wrap(v(:,:,I),2)

  u2@lat2d = rm_single_dims(lat1)
  u2@lon2d = rm_single_dims(lon1)
  v2@lat2d = rm_single_dims(lat1)
  v2@lon2d = rm_single_dims(lon1)

wks = gsn_open_wks("pdf",OUTDir+"wind_mean_"+type(t)+"_spring")
vcres@tiMainString = "Mean 850 hPa wind"
ave = gsn_csm_vector_map_ce(wks,u2,v2,vcres)
delete(wks)

t=t+1
end do

