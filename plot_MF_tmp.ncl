  vcres                         = True             ; plot mods desired
  vcres@vcRefLengthF            = 0.05            ; define length of vec ref
  vcres@vcGlyphStyle            = "CurlyVector"    ; turn on curly vectors
  vcres@mpMinLonF = 100
  vcres@mpMaxLonF = 180
  vcres@mpMinLatF = -50
  vcres@mpMaxLatF = 0
  vcres@mpFillOn                   = False               ; turn off gray map
  vcres@mpOutlineDrawOrder         = "PreDraw"           ; draw outline first
  vcres@vcMonoLineArrowColor  = True                ; vec's colored by their mag
  vcres@vcRefMagnitudeF         = 25.0              ; make vectors larger
  vcres@gsnSpreadColors     = True      ; use full colormap
  vcres@lbLabelStride       = 5.         ; plot every other colar bar label
  vcres@vcLevelSelectionMode = "ManualLevels"     ; set manual contour levels
  vcres@vcMinLevelValF       = 0               ; set min contour level
  vcres@vcMaxLevelValF       = 3000                ; set max contour level
  vcres@vcLevelSpacingF      = 200               ; set contour spacing
vcres@vcMinDistanceF          = 0.017
  vcres@vcRefAnnoOrthogonalPosF = -1.0    ; move ref vector into plot
  vcres@vcRefAnnoString1 = "$VMG$ kg/m/s"


Umoist_d01@lat2d = rm_single_dims(lat1)
Umoist_d01@lon2d = rm_single_dims(lon1)
Vmoist_d01@lat2d = rm_single_dims(lat1)
Vmoist_d01@lon2d = rm_single_dims(lon1)

delete(Umoist_d01@units)
delete(Vmoist_d01@units)
wks = gsn_open_wks("pdf","tmp1")
gsn_define_colormap(wks,"BlAqGrYeOrReVi200")
map = gsn_csm_vector_map_ce(wks,Umoist_d01(:,:,n),Vmoist_d01(:,:,n),vcres)
;draw(map)
;frame(wks)
delete(wks)