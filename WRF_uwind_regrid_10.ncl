load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

;/srv/ccrc/data12/z3393020/MIROC3.2/R2/1990-2010/out/
;/srv/ccrc/data20/z3393020/WRF_ECHAM5/R2/1990-2010/out/
;/srv/ccrc/data24/z3393020/WRF_CCCMA/R2/1990-2010/out
;/srv/ccrc/data23/z3444417/NARCliM/CSIRO-Mk3.0/1990-2009/R2/out

dirs=(/"/srv/ccrc/data12/z3393020/MIROC3.2/R2/1990-2010/out/","/srv/ccrc/data20/z3393020/WRF_ECHAM5/R2/1990-2010/out/","/srv/ccrc/data24/z3393020/WRF_CCCMA/R2/1990-2010/out/","/srv/ccrc/data23/z3444417/NARCliM/CSIRO-Mk3.0/1990-2009/R2/out/"/)

outfiles=(/"/srv/ccrc/data23/z3478332/CMIP3/WRF10_miroc3.2_monthly.nc","/srv/ccrc/data23/z3478332/CMIP3/WRF10_echam5_monthly.nc","/srv/ccrc/data23/z3478332/CMIP3/WRF10_cccma_monthly.nc","/srv/ccrc/data23/z3478332/CMIP3/WRF10_csiromk3_monthly.nc"/)

  fin=addfile("/srv/ccrc/data28/z3393020/NARCliM/reanalysis/R1/bdy_data/wrfinput_d02_1980-01.nc","r")
  lat1 = wrf_user_getvar(fin,"XLAT",-1)
  lon1 = wrf_user_getvar(fin,"XLONG",-1)
  lat2=fspan(-90,90,73)
  lon2=fspan(0,357.5,144)

  datafile = "daylist3.csv"
  dates = asciiread(datafile,-1,"string")
  yy = str_get_cols(dates, 0, 3)
  mm = str_get_cols(dates, 4, 5)
  time = stringtoint(yy)*100+stringtoint(mm)

   Opt                = True
   Opt@DstGridLat = lat2
   Opt@DstGridLon = lon2
   Opt@ForceOverwrite = True

n=0
do while(n.lt.dimsizes(dirs))
print(outfiles(n))
u3 = new((/240,200,325/),"float")
      
i=0
do while(i.lt.dimsizes(dates))
  if(mm(i).eq."01") then
    print(time(i))
  end if
  FILES1 = systemfunc (" ls -1 " + dirs(n) + "wrfout_d02_" + yy(i) + "-" + mm(i) +"-??_??:00:00")
  f1 = addfiles(FILES1+".nc","r")
  u = wrf_user_getvar(f1,"uvmet",-1)
  p = wrf_user_getvar(f1,"pressure",-1)
  u2 = wrf_user_intrp3d(u(0,:,:,:,:),p,"h",850.0,0.,False)
  u3(i,:,:)=dim_avg_n_Wrap(u2,0)

  delete([/FILES1,f1,u,p,u2/])
  i=i+1
end do

print("Regridding")
  
   u3@lat2d=lat1(0,:,:)
   u3@lon2d=lon1(0,:,:)

   u4 = ESMF_regrid(u3,Opt)   ; Do the regridding - 1.5 degrees
   u4!0   ="time"
   u4!1   ="lat"
   u4!2   ="lon"
   u4@description = "WRF 850hPa u-wind regridded to 2.5 degree grid"

print("Writing")
   out = addfile(outfiles(n),"w")
   out->uw850 = u4
   delete([/u3,u4,out/])
   n=n+1
end do
