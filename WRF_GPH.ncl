load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

;Version 2 - actually does a mean monthly Uwind

datafile = "daylist2.csv"
dates = asciiread(datafile,-1,"string")
yy = stringtoint(str_get_cols(dates, 0, 3))
mm = stringtoint(str_get_cols(dates, 4, 5))
nd = stringtoint(str_get_cols(dates, 6, 7))

i=0
j=1
fname = "/srv/ccrc/data27/z3393020/WRF_NNRP/R2/1950-2010/out/wrfout_d01_" + yy(i) + "-" + sprinti("%0.2i",mm(i)) + "-" + sprinti("%0.2i",j) + "_00:00:00.nc"
f1 = addfile(fname,"r")
lat = wrf_user_getvar(f1,"XLAT",-1)
lon = wrf_user_getvar(f1,"XLONG",-1)
Z=new((/dimsizes(dates),4,144,215/),"float",-999999)

; Get the monthly mean 850 wind - both U and V
level = (/925.0,850.0,700.0,500.0/)
i=0
j=1
do while (i.lt.dimsizes(dates))
  z=new((/nd(i)*8,4,144,215/),"float",-999999)
  j=1
  do while(j.le.nd(i))
    fname = "/srv/ccrc/data27/z3393020/WRF_NNRP/R2/1950-2010/out/wrfout_d01_" + yy(i) + "-" + sprinti("%0.2i",mm(i)) + "-" + sprinti("%0.2i",j) + "_00:00:00.nc"
    f1 = addfile(fname,"r")
    p = wrf_user_getvar(f1,"pressure",-1)
    za = wrf_user_getvar(f1,"z",-1)    
    k=0
    do while (k.lt.4)
       z((j-1)*8:j*8-1,k,:,:) = wrf_user_intrp3d(za,p,"h",level(k),0.,False)
       k=k+1
    end do
    delete(f1)
    j=j+1
  end do
  Z(i,:,:,:) = dim_avg_n_Wrap(z,0)
  delete(z)
  i=i+1
end do

; Format it and save to a netcdf
Z!0 = "Times"
Z!1 = "Levels"
Z!2 = lat!0
Z!3 = lat!1
Z@long_name = "Mean height (850hPa)"           ; assign attributes 
Z@units     = "m"

ncdf     = addfile("WRF_gph.nc" ,"c")
dim_names = (/ "Times", "Levels", lat!0,  lat!1/)
dim_sizes = (/ dimsizes(dates), 4, 144 , 215   /)
dimUnlim = (/True, False, False , False /)
filedimdef( ncdf, dim_names, dim_sizes, dimUnlim )

time=stringtoint(str_get_cols(dates, 0, 5))
time!0 = "Times"
ncdf->lat = lat
ncdf->lon = lon
ncdf->time = time
ncdf->levels = levels
ncdf->Z = Z

; Plotting?

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
  vcres@gsnAddCyclic = False
  vcres@vcMinDistanceF = 0.03

U@lat2d=lat
U@lon2d=lon
V@lat2d=lat
V@lon2d=lon

uA=month_to_annual(U(Times|:,south_north|:,west_east|:),1)
vA=month_to_annual(V(Times|:,south_north|:,west_east|:),1)
wks = gsn_open_wks("pdf","wind_WRF_850_7909")
vcres@tiMainString = "Annual mean wind direction (WRF) at 850 hPa (1979-2009)"
ave = gsn_csm_vector_map_ce(wks,dim_avg_n_Wrap(uA,0),dim_avg_n_Wrap(vA,0),vcres)
delete(wks)

us=runave_n_Wrap(U(Times|:,south_north|:,west_east|:),3,0,0)
vs=runave_n_Wrap(V(Times|:,south_north|:,west_east|:),3,0,0)
delete(uS)
delete(vS)
uS=us(12:371:12,:,:)
vS=vs(12:371:12,:,:)
wks = gsn_open_wks("pdf","wind_WRF_djf_850_7909")
vcres@tiMainString = "DJF mean wind direction (WRF) at 850 hPa (1979-2009)"
ave = gsn_csm_vector_map_ce(wks,dim_avg_n_Wrap(uS,0),dim_avg_n_Wrap(vS,0),vcres)
delete(wks)

; Version 3 - loads & saves all the daily mean Uwind in the GDI segment

datafile = "daylist.csv"
dates = asciiread(datafile,-1,"string")
yy = str_get_cols(dates, 0, 3)
mm = str_get_cols(dates, 4, 5)
dd = str_get_cols(dates, 6, 7)
Uwind = new((/dimsizes(dates)/),"float")

i=0
do while(i.le.dimsizes(dates))
  fname = "/srv/ccrc/data18/z3393242/studies/NARCliM/nnrp/R2/out/wrfout_d01_" + yy(i) + "-" + mm(i) + "-" + dd(i) + "_00:00:00.nc"
  f1 = addfile(fname,"r")
  p = wrf_user_getvar(f1,"pressure",-1)
  ua = wrf_user_getvar(f1,"ua",-1)
  u2 = wrf_user_intrp3d(ua,p,"h",850.0,0.,False)
  Uwind(i) = avg(u2(:,48:69,110:113)) ; approximately 149-152 E, 25-35 S. All eight times. 
  delete(f1)
  i=i+1
end do

asciiwrite("~/Documents/Data/JE_WRF/UwindA.txt",Uwind)

data = (/toint(yy), toint(mm), toint(dd), Uwind/)
data2=transpose(data)

opt= True
opt@fout="~/Documents/Data/JE_WRF/Uwind2.txt"
write_matrix(data2, "%d %d %d %f", opt)




