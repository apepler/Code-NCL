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

  vcres                         = True             ; plot mods desired
  vcres@vcRefLengthF            = 0.05            ; define length of vec ref
  vcres@vcGlyphStyle            = "CurlyVector"    ; turn on curly vectors
  vcres@vcRefMagnitudeF           = 2.0             ; define vector ref mag
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

  Data1=addfile(dirs(0)+"WRF_d01_monthly_uvpr.nc","r")
  u1=Data1->U_d01
  v1=Data1->V_d01

  Data2=addfile(dirs(1)+"WRF_d01_monthly_uvpr.nc","r")
  u2=Data2->U_d01
  v2=Data2->V_d01

  tmp=ispan(0,239,1)
  tmp2=mod(tmp,12)+1
  tmp1=tmp/12

  a=dimsizes(u1)
  u1a = new((/a(0),a(1),20/),"float")
  u2a=u1a
  v1a=u1a
  v2a=v1a
  
  do ip=0,19
     I=ind(tmp2.ge.1.and.tmp2.le.12.and.tmp1.eq.ip)
     u2a(:,:,ip)=dim_avg_n_Wrap(u2(:,:,I),2)   
     u1a(:,:,ip)=dim_avg_n_Wrap(u1(:,:,I),2)
     v2a(:,:,ip)=dim_avg_n_Wrap(v2(:,:,I),2)   
     v1a(:,:,ip)=dim_avg_n_Wrap(v1(:,:,I),2)
  end do

  udiff=dim_avg_n_Wrap(u2a-u1a,2)
  udiff@lat2d = rm_single_dims(lat1)
  udiff@lon2d = rm_single_dims(lon1)

  vdiff=dim_avg_n_Wrap(v2a-v1a,2)
  vdiff@lat2d = rm_single_dims(lat1)
  vdiff@lon2d = rm_single_dims(lon1)

wks = gsn_open_wks("pdf",OUTDir+"wind_diffNoTopo_nudge_mean")
vcres@tiMainString = "Mean 850 hPa wind"
ave = gsn_csm_vector_map_ce(wks,udiff,vdiff,vcres)
delete(wks)