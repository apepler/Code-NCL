load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

OUTDIR="/srv/ccrc/data37/z3478332/ECL_evaluation/"
outname="test"

a=addfile(OUTDIR+"ECLwind_QuikSCAT_MLDBQC.nc","r")
u=a->ECL_U10
v=a->ECL_V10
w=a->ECL_WS10

  lon0=fspan(-9.875,9.875,80)
  lon0!0="lon"
  lon0@units="degrees_E"
  lat0=fspan(-9.875,9.875,80)
  lat0!0="lat"
  lat0@units="degrees_N"

div=uv2dv_cfd(u(0,:,:),v(0,:,:),lat0,lon0,0)*1e5
vor=uv2vr_cfd(u(0,:,:),v(0,:,:),lat0,lon0,0)*1e5

; One way to find the centre points

locmin = local_min(vor,False,0.)
I=ind(locmin@minval.eq.min(vor))
print(lon0(locmin@xi(I)))
print(lat0(locmin@yi(I)))

; Not great though, especially since centre is usually a bit amorphous rather than a single point. Doing a proper tracking on winds is possible I imagine, but not on my to-do list

; Now, plot both of vorticity and divergence as a test

  res = True          
  res@gsnDraw         = False
  res@gsnFrame        = False
  res@cnFillOn        = True
  res@cnLinesOn       = False
  res@lbLabelBarOn        = False
  res@gsnStringFontHeightF = 0.02
  res@cnFillPalette    = "BlRe"
  res@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
  res@gsnAddCyclic = False

;Divergence/vorticity
  mres=res
  mres@cnMinLevelValF       = -8.                ; set min contour level
  mres@cnMaxLevelValF       =  8.                ; set max contour level
  mres@cnLevelSpacingF      =  1.               ; set contour spacing
  mres@gsnRightString      = "x 1e-5"

; U/V
  vres=res
  vres@cnMinLevelValF       = -16.                ; set min contour level
  vres@cnMaxLevelValF       =  16.                ; set max contour level
  vres@cnLevelSpacingF      =  2.               ; set contour spacing

; Set up a panel

  wks  = gsn_open_wks("pdf",outname)
  wind_plots  = new(2,graphic)    
  div_plots = new(2,graphic)  

   vres@gsnLeftString= "Zonal wind (m/s)"
   wind_plots(0) = gsn_csm_contour(wks,u(0,:,:),vres)
   vres@gsnLeftString= "Meridional wind (m/s)"
   wind_plots(1) = gsn_csm_contour(wks,v(0,:,:),vres)

   mres@gsnLeftString= "Vorticity"
   div_plots(0) = gsn_csm_contour(wks,vor,mres)
   mres@gsnLeftString= "Divergence"
   div_plots(1) = gsn_csm_contour(wks,div,mres)

delete(res)
    res                   = True              ; modify the panel plot
    res@gsnFrame          = False             ; don't advance frame yet
    res@gsnPanelBottom    = 0.5              ; top 2/3 of frame
    res@gsnPanelLabelBar  = True              ; add common colorbar
    res@lbOrientation     = "vertical"
    res@pmLabelBarWidthF  = 0.075             ; make thinner
    res@gsnPanelFigureStrings= (/"a)","b)"/)
    res@amJust   = "TopLeft"

    gsn_panel(wks,wind_plots,(/1,2/),res)

;---Panel the diff plots at the bottom
    res@gsnPanelTop       = 0.5   ; lower 1/3 plus some white space
    res@gsnPanelBottom    = 0.01              ; top 2/3 of frame
    res@gsnPanelFigureStrings= (/"c)","d)"/)

    gsn_panel(wks,div_plots,(/1,2/),res)

    frame(wks)