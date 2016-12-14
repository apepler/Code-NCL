load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
;load "./WRFUserARW.ncl"

dirs=(/"/srv/ccrc/data34/z3478332/WRF/ERA-nonudge/","/srv/ccrc/data45/z3478332/WRF/output/ERAI_R2_nonudging_notopo/out/impact/","/srv/ccrc/data34/z3478332/WRF/ERA-nudge/","/srv/ccrc/data34/z3478332/WRF/output/ERAI_R2_nudging_notopo_19902009/out/impact/"/)
type=(/"ERA-nonudge","ERA-nonudge_notopo","ERA-nudge","ERA-nudge_notopo"/)

OUTDir = "/srv/ccrc/data45/z3478332/WRF/output/"  

  fin=addfile("/srv/ccrc/data13/z3393020/Analyses/share/geo_em_files/geo_em.d01.narclim.nc","r")
  lat1=wrf_user_getvar(fin,"XLAT_M",-1)
  lon1=wrf_user_getvar(fin,"XLONG_M",-1)
  delete(fin)

  vcres                         = True             ; plot mods desired
  vcres@vcRefLengthF            = 0.05            ; define length of vec ref
  vcres@vcGlyphStyle            = "CurlyVector"    ; turn on curly vectors
  vcres@vcRefMagnitudeF           = 20.0             ; define vector ref mag
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

;Stuff for just the sig

do dd=0,3

  Data1=addfile(dirs(dd)+"WRF_d01_monthly_uppers.nc","r")
  u1=Data1->U_d01
  v1=Data1->V_d01

  tmp=ispan(0,239,1)
  tmp2=mod(tmp,12)+1
  tmp1=tmp/12

  a=dimsizes(u1)
  u1a = new((/a(0),a(1),a(2),20/),"float")
  v1a=u1a

  do ip=0,19
     I=ind(tmp2.ge.1.and.tmp2.le.12.and.tmp1.eq.ip)
     u1a(:,:,:,ip)=dim_avg_n_Wrap(u1(:,:,:,I),3)
     v1a(:,:,:,ip)=dim_avg_n_Wrap(v1(:,:,:,I),3)
  end do

u1b=dim_avg_n_Wrap(u1a,3)
  u1b@lat2d = rm_single_dims(lat1)
  u1b@lon2d = rm_single_dims(lon1)

v1b=dim_avg_n_Wrap(v1a,3)
  v1b@lat2d = rm_single_dims(lat1)
  v1b@lon2d = rm_single_dims(lon1)

  levs=(/850,500,200/)
  speeds=(/20.,40.,60./)

do n=0,2

wks = gsn_open_wks("pdf",OUTDir+"wind"+levs(n)+"_"+type(dd)+"_mean")
     vcres@tiMainString="Average "+levs(n)+"hPa wind" 
 vcres@vcRefMagnitudeF           = speeds(n)

ave = gsn_csm_vector_map_ce(wks,u1b(:,:,n),v1b(:,:,n),vcres)
delete(wks)
end do
end do