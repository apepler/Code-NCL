load "/usr/local/ncl/6.0/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "/usr/local/ncl/6.0/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "/usr/local/ncl/6.0/lib/ncarg/nclscripts/csm/contributed.ncl"

uwind = addfile("uwnd.mon.mean.nc","r") 
u = short2flt(uwind->uwnd(:,:5,:,:))

vwind = addfile("vwnd.mon.mean.nc","r") 
v = short2flt(vwind->vwnd(:,:5,:,:))
                   
lev = uwind->level(:5)
lat = uwind->lat   
lon = uwind->lon  
time = uwind->time

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
  
uA=month_to_annual(u(:,0,:,:),1)
vA=month_to_annual(v(:,0,:,:),1)
wks = gsn_open_wks("pdf","wind_ann_1000_7909")
vcres@tiMainString = "Annual mean wind direction (NCEP1) at 1000 hPa (1979-2009)"
ave = gsn_csm_vector_map_ce(wks,dim_avg_n_Wrap(uA(31:61,:,:),0),dim_avg_n_Wrap(vA(31:61,:,:),0),vcres)
delete(wks)

uA=month_to_annual(u(:,2,:,:),1)
vA=month_to_annual(v(:,2,:,:),1)
wks = gsn_open_wks("pdf","wind_ann_850_7909")
vcres@tiMainString = "Annual mean wind direction (NCEP1) at 850 hPa (1979-2009)"
ave = gsn_csm_vector_map_ce(wks,dim_avg_n_Wrap(uA(31:61,:,:),0),dim_avg_n_Wrap(vA(31:61,:,:),0),vcres)
delete(wks)

u2=runave_n_Wrap(u(:,2,:,:),5,0,0)
v2=runave_n_Wrap(v(:,2,:,:),5,0,0)
uS=u2(12:782:12,:,:)
vS=v2(12:782:12,:,:)
wks = gsn_open_wks("pdf","wind_warm_850_7909")
vcres@tiMainString = "NDJFM mean wind direction (NCEP1) at 850 hPa (1979-2009)"
ave = gsn_csm_vector_map_ce(wks,dim_avg_n_Wrap(uS(31:61,:,:),0),dim_avg_n_Wrap(vS(31:61,:,:),0),vcres)
delete(wks)


  


