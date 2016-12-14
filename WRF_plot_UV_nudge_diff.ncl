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

  Data1=addfile(INDir+"WRF_d01_UV_slp_control.nc","r")
  u1=Data1->U_d01
  v1=Data1->V_d01

  Data2=addfile(INDir+"WRF_d01_UV_slp_notopo.nc","r")
  u2=Data2->U_d01
  v2=Data2->V_d01

  u2a=dim_avg_n_Wrap(u2,2)   
  u1a=dim_avg_n_Wrap(u1,2)
  v2a=dim_avg_n_Wrap(v2,2)   
  v1a=dim_avg_n_Wrap(v1,2)

  udiff=dim_avg_n_Wrap(u2a-u1a,2)
  udiff@lat2d = rm_single_dims(lat1)
  udiff@lon2d = rm_single_dims(lon1)

  vdiff=dim_avg_n_Wrap(v2a-v1a,2)
  vdiff@lat2d = rm_single_dims(lat1)
  vdiff@lon2d = rm_single_dims(lon1)

wks = gsn_open_wks("pdf",OUTDir+"wind_diffNoTopo_nudge")
vcres@tiMainString = "Mean 850 hPa wind"
ave = gsn_csm_vector_map_ce(wks,udiff,vdiff,vcres)
delete(wks)