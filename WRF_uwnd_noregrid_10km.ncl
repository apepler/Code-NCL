load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

;/srv/ccrc/data12/z3393020/MIROC3.2/R2/1990-2010/out/
;/srv/ccrc/data20/z3393020/WRF_ECHAM5/R2/1990-2010/out/
;/srv/ccrc/data24/z3393020/WRF_CCCMA/R2/1990-2010/out
;/srv/ccrc/data23/z3444417/NARCliM/CSIRO-Mk3.0/1990-2009/R2/out

dirs=(/"/srv/ccrc/data12/z3393020/MIROC3.2/R2/1990-2010/out/","/srv/ccrc/data20/z3393020/WRF_ECHAM5/R2/1990-2010/out/","/srv/ccrc/data24/z3393020/WRF_CCCMA/R2/1990-2010/out/","/srv/ccrc/data23/z3444417/NARCliM/CSIRO-Mk3.0/1990-2009/R2/out/","/srv/ccrc/data11/z3393020/MIROC3.2/R1/1990-2010/out/","/srv/ccrc/data20/z3393020/WRF_ECHAM5/R1/1990-2010/out/","/srv/ccrc/data21/z3393020/WRF_CCCMA/R1/1990-2010/out/","/srv/ccrc/data25/z3444417/NARCliM/CSIRO-Mk3.0/1990-2009/R1/out/","/srv/ccrc/data14/z3393020/MIROC3.2/R3/1990-2010/out/","/srv/ccrc/data14/z3393020/WRF_ECHAM5/R3/1990-2010/out/","/srv/ccrc/data21/z3393020/WRF_CCCMA/R3/1990-2010/out/","/srv/ccrc/data26/z3444417/studies/NARCliM/CSIRO-Mk3.0/1990-2009/R3/out/"/)

outfiles=(/"/srv/ccrc/data36/z3478332/CMIP3/WRF10_R2_miroc3.2_uwnd_noregrid.nc","/srv/ccrc/data36/z3478332/CMIP3/WRF10_R2_echam5_uwnd_noregrid.nc","/srv/ccrc/data36/z3478332/CMIP3/WRF10_R2_cccma_uwnd_noregrid.nc","/srv/ccrc/data36/z3478332/CMIP3/WRF10_R2_csiromk3_uwnd_noregrid.nc","/srv/ccrc/data36/z3478332/CMIP3/WRF10_R1_miroc3.2_uwnd_noregrid.nc","/srv/ccrc/data36/z3478332/CMIP3/WRF10_R1_echam5_uwnd_noregrid.nc","/srv/ccrc/data36/z3478332/CMIP3/WRF10_R1_cccma_uwnd_noregrid.nc","/srv/ccrc/data36/z3478332/CMIP3/WRF10_R1_csiromk3_uwnd_noregrid.nc","/srv/ccrc/data36/z3478332/CMIP3/WRF10_R3_miroc3.2_uwnd_noregrid.nc","/srv/ccrc/data36/z3478332/CMIP3/WRF10_R3_echam5_uwnd_noregrid.nc","/srv/ccrc/data36/z3478332/CMIP3/WRF10_R3_cccma_uwnd_noregrid.nc","/srv/ccrc/data36/z3478332/CMIP3/WRF10_R3_csiromk3_uwnd_noregrid.nc"/)

  fin=addfile("/srv/ccrc/data13/z3393020/Analyses/share/geo_em_files/geo_em.d01.narclim.nc","r")
  lat1 = wrf_user_getvar(fin,"XLAT_M",-1)
  lon1 = wrf_user_getvar(fin,"XLONG_M",-1)
  lat2=fspan(-45,-20,11)
  lon2=fspan(130,160,13)
  lon3=fspan(130,160,61) ; Adding in the 0.5 degree domain of WRF50 for comp.
  lat3=fspan(-45,-20,51)
  lon4=fspan(130,160,301)
  lat4=fspan(-45,-20,251)

  datafile = "daylist3.csv"
  dates = asciiread(datafile,-1,"string")
  yy = str_get_cols(dates, 0, 3)
  mm = str_get_cols(dates, 4, 5)
  dd = str_get_cols(dates, 7, 8)
  time = stringtoint(yy)*100+stringtoint(mm)

   Opt                = True
   Opt@DstGridLat = lat2
   Opt@DstGridLon = lon2
   Opt@ForceOverwrite = True

   Opt2                = True
   Opt2@DstGridLat = lat3
   Opt2@DstGridLon = lon3
   Opt2@ForceOverwrite = True

   Opt4                = True
   Opt4@DstGridLat = lat4
   Opt4@DstGridLon = lon4
   Opt4@ForceOverwrite = True

n2=n+4

do while(n.lt.n2)
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
  
   print("Writing")
   system("/bin/rm -f "+outfiles(n))
   out = addfile(outfiles(n),"c")
   out->uwnd = u3
   delete([/u3,out/])
   n=n+1
end do
