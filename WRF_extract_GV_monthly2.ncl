load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
;load "./WRFUserARW.ncl"

begin
  DATADir="/srv/ccrc/data45/z3478332/WRF/output/ERAI_R2_nonudging_notopo/out/"
  OUTDir = "/srv/ccrc/data45/z3478332/WRF/output/ERAI_R2_nonudging_notopo/out/impact/"  

;DATADir="/srv/ccrc/data33/z3481416/CCRC-WRF3.6.0.5-SEB/ERA-Interim/R2_nudging/out/"
;OUTDir="/srv/ccrc/data34/z3478332/WRF/ERA-nudge/"

  fin=addfile("/srv/ccrc/data13/z3393020/Analyses/share/geo_em_files/geo_em.d01.narclim.nc","r")
  lat1=wrf_user_getvar(fin,"XLAT_M",0)
  lon1=wrf_user_getvar(fin,"XLONG_M",0)
  delete(fin)
  a=dimsizes(lat1)
  GV_d01 = new((/240,a(0),a(1)/),"float")
  GV_d01!1 = lat1!0
  GV_d01!2 = lat1!1
  GV_d01!0 = "Time"
  GV_d01@units = "s-1"

     south_north = 144 
     west_east = 215
     num_metgrid_levels = 38
     scale = -1.e+05     

; calculate geostrophic vorticity  no function available. 
G = 9.8005  ; m/s2, grivity at 45 deg lat used by the WMO
W = 7.292e-5 ; 1/s, earth ang rotation
rad = 4.*atan(1.)/180.
f0 = 2. * W * sin(lat1*rad) ; coriolis parameter

dlon = 48918.09 ; WRF grid space for NARCliM domain
dlonsq = dlon*dlon
dlat = 48918.09
dlatsq = dlat*dlat


n=0
year=1990
year2=2009
do while(year.le.year2)
m=1
do while(m.le.12)
  print(year+"-"+sprinti("%0.2i",m))
  FILES1 = systemfunc (" ls -1 " + DATADir + "wrfout_d01_"+year+"-"+sprinti("%0.2i",m)+"-??_??:00:00")
  f1 = addfiles(FILES1+".nc","r")

  GH = wrf_user_getvar(f1,"geopt",-1)
  p = wrf_user_getvar(f1,"pressure",-1)
  GH_P = wrf_user_intrp3d(GH,p,"h",500.,0.,False)
  GH_P =smth9(smth9( smth9(GH_P,0.5,0.25,False),0.5,0.25,False),0.5,0.25,False)
  GH_P =smth9(smth9( smth9(GH_P,0.5,0.25,False),0.5,0.25,False),0.5,0.25,False)

dimfiles = dimsizes(GH) ; how many files
nfiles = dimfiles(0) - 1

lap = new((/dimfiles(0),south_north,west_east/),"float") ; here I calcuate 6 hourly GV (4 times a day)

do ifile = 0, nfiles
lap_lon = new((/south_north,west_east/),"float")
lap_lat = new((/south_north,west_east/),"float")
; Laplacian along west-east direction
do it =1,west_east-2 
lap_lon(:,it) = GH_P(ifile,:,it+1)+GH_P(ifile,:,it-1)-2.0*GH_P(ifile,:,it)
end do
;Edges
lap_lon(:,0) = lap_lon(:,1)
lap_lon(:,west_east-1) = lap_lon(:,west_east-2)
; divided by spacing and ff
lap_lon(:,:) = lap_lon(:,:)/dlonsq/f0

; Laplacian along south-north direction
do nt = 1,south_north-2
lap_lat(nt,:) = GH_P(ifile,nt+1,:)+GH_P(ifile,nt-1,:) -2.0*GH_P(ifile,nt,:)
end do
;Edges
lap_lat(0,:) = lap_lat(1,:)
lap_lat(south_north-1,:) = lap_lat(south_north-2,:)
; divided by spacing an ff
lap_lat(:,:) = lap_lat(:,:)/dlatsq/f0

; total laplacian by sum up lon/lat components
lap(ifile,:,:) = lap_lon + lap_lat

end do

GV_d01(n,:,:) = dim_avg_n_Wrap(lap*scale,0) ; vorticity is negative for low in south hemisphere


delete([/lap,GH,GH_P,p,lap_lat,lap_lon,dimfiles,nfiles,f1,FILES1/])


n=n+1
m=m+1
end do
year=year+1
end do

  outfile=OUTDir+"WRF_d01_monthly_gv_fix"
  system("/bin/rm -f "+outfile+".nc")
  out = addfile(outfile+".nc","c")
  out->GV_d01=GV_d01

end