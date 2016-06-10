load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"


  DATADIRS=(/"/srv/ccrc/data36/z3478332/WRF/output/ERAI_R1_nudging_default_2007_notopo/out/","/srv/ccrc/data36/z3478332/WRF/output/ERAI_R2_nudging_default_2007_notopo/out/","/srv/ccrc/data36/z3478332/WRF/output/ERAI_R3_nudging_default_2007_notopo/out/","/srv/ccrc/data36/z3478332/WRF/output/ERAI_R1_nudging_default_2007/out/","/srv/ccrc/data36/z3478332/WRF/output/ERAI_R2_nudging_default_2007/out/","/srv/ccrc/data36/z3478332/WRF/output/ERAI_R3_nudging_default_2007/out/"/)

  fin=addfile("/srv/ccrc/data13/z3393020/Analyses/share/geo_em_files/geo_em.d01.narclim.nc","r")
  lat1 = wrf_user_getvar(fin,"XLAT_M",0)
  lon1 = wrf_user_getvar(fin,"XLONG_M",0) 
  lat2=fspan(-40,-20,9)
  lon2=fspan(145,155,5)
  
  Opt                = True
  Opt@DstGridLat = lat2
  Opt@DstGridLon = lon2
  Opt@ForceOverwrite = True

  year1=2007
  year2=2008
  hlist=[/"  Year, Month,   Day,  Hour,     GDI"/]

  n=5
  do while(n.lt.dimsizes(DATADIRS))
  DATADir = DATADIRS(n)
  year=year1
  outfile=DATADir+"uwnd_gdi_3hrly.csv"
  write_table(outfile, "w", hlist, "%s")

  do while(year.le.year2)
  i=1
  do while(i.le.12)

   FILES1 = systemfunc (" ls -1 " + DATADir+ "wrfout_d01_" + year + "-" + sprinti("%0.2i",i) +"-??_??:00:00")
   f1 = addfiles(FILES1+".nc","r")

   times = wrf_user_getvar(f1,"times",-1)
   data = new((/dimsizes(times),5/),"float")
   data(:,0) = stringtointeger(str_get_cols(times, 0,3 ))
   data(:,1) = stringtointeger(str_get_cols(times, 5, 6))
   data(:,2) = stringtointeger(str_get_cols(times, 8, 9))
   data(:,3) = stringtointeger(str_get_cols(times, 11, 12))
   uv = wrf_user_getvar(f1,"uvmet",-1)
   p = wrf_user_getvar(f1,"pressure",-1)
   u = wrf_user_intrp3d(uv(0,:,:,:,:),p,"h",850.0,0.,False)
   u@lat2d=lat1
   u@lon2d=lon1
   u2 = ESMF_regrid(u,Opt)   ; Do the regridding - 2.5 degrees
   data(:,4) = dim_avg_n_Wrap(u2(:,2:6,2),1)

   aslist = [/data(:,0),data(:,1),data(:,2),data(:,3),data(:,4)/]
   write_table(outfile, "a", aslist, "%6.0f,%6.0f,%6.0f,%6.0f,%8.4f")

   delete([/FILES1,f1,times,data,uv,u,u2,p,data,aslist/])
   i=i+1
   end do
   year=year+1
   end do
   
  delete(outfile)
  n=n+1
  end do

     
   