;this file calculate vorticity from ERA_interim data for 300hpa, 400hpa and 500hpa.

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin

;INDIRS=(/"/srv/ccrc/data36/z3478332/WRF/output/ERAI_R1_nudging_default_2007/out/","/srv/ccrc/data36/z3478332/WRF/output/ERAI_R2_nudging_default_2007/out/","/srv/ccrc/data36/z3478332/WRF/output/ERAI_R3_nudging_default_2007/out/","/srv/ccrc/data36/z3478332/WRF/output/ERAI_R1_nudging_default_2007_notopo/out/","/srv/ccrc/data36/z3478332/WRF/output/ERAI_R2_nudging_default_2007_notopo/out/","/srv/ccrc/data36/z3478332/WRF/output/ERAI_R3_nudging_default_2007_notopo/out/","/srv/ccrc/data37/z3478332/WRF/output/ERAI_R1_nudging_default_2007_BRAN/out/","/srv/ccrc/data37/z3478332/WRF/output/ERAI_R2_nudging_default_2007_BRAN/out/","/srv/ccrc/data37/z3478332/WRF/output/ERAI_R3_nudging_default_2007_BRAN/out/","/srv/ccrc/data37/z3478332/WRF/output/ERAI_R1_nudging_default_2007_BRAN_noeac/out/","/srv/ccrc/data37/z3478332/WRF/output/ERAI_R2_nudging_default_2007_BRAN_noeac/out/","/srv/ccrc/data37/z3478332/WRF/output/ERAI_R3_nudging_default_2007_BRAN_noeac/out/"/)

INDIRS=(/"/srv/ccrc/data45/z3478332/WRF/output/ERAI_R1_nudging_default_2007_BRAN_2eac/out/","/srv/ccrc/data36/z3478332/WRF/output/ERAI_R2_nudging_default_2007_BRAN_2eac/out/","/srv/ccrc/data45/z3478332/WRF/output/ERAI_R3_nudging_default_2007_BRAN_2eac/out/"/)

OUTDIRS=(/"/srv/ccrc/data45/z3478332/WRF/output/ERAI_R1_nudging_default_2007_BRAN_2eac/out/","/srv/ccrc/data45/z3478332/WRF/output/ERAI_R2_nudging_default_2007_BRAN_2eac/out/","/srv/ccrc/data45/z3478332/WRF/output/ERAI_R3_nudging_default_2007_BRAN_2eac/out/"/)

     south_north = 200 
     west_east = 325
     num_metgrid_levels = 38
     scale = -1.e+05     

     lap_lon = new((/south_north,west_east/),"float")
     lap_lat = new((/south_north,west_east/),"float")

cdf_file = addfile("/srv/ccrc/data13/z3393020/Analyses/share/geo_em_files/geo_em.d02.narclim.nc","r") ; inner domain of WRF ; outer domain of WRF (CORDEX domain)
      latd02 = cdf_file->XLAT_M(0,:,:)             ; Inform NCL map paramaters from netCDF file
      lond02 = cdf_file->XLONG_M(0,:,:)
      landsea = cdf_file->LANDMASK(0,:,:)
      pole_lat = cdf_file@POLE_LAT
      pole_lon = cdf_file@POLE_LON
      cen_lat = cdf_file@CEN_LAT
      cen_lon = cdf_file@CEN_LON

      dsize = dimsizes(latd02)
      lat1 = latd02(0,0)
      lat2 = latd02(dsize(0)-1,dsize(1)-1)
      lon1 = lond02(0,0)
      lon2 = lond02(dsize(0)-1,dsize(1)-1)

       start_lat = -34.25
       end_lat = -23.75   ;centred on -29, which is drom Dowdy's report

       start_lon = 145.50
       end_lon = 160.50 ; centred on 153, which is from Dowdy's report 

       grid_lat = toint((end_lat-start_lat)/0.1+1) ;0.1 degree grid	
       grid_lon = toint((end_lon-start_lon)/0.1+1) ;0.1 degree grid
	   
       lat =fspan(start_lat,end_lat,grid_lat)
       lon =fspan(start_lon,end_lon,grid_lon)
	  
       lat@units = "degree_north"
       lon@units = "degree_east"


dlon =  9783.618; WRF grid space for NARCliM domain
dlonsq = dlon*dlon
dlat = 9783.618
dlatsq = dlat*dlat

n=0
do while(n.lt.dimsizes(INDIRS))
;do while(n.lt.1)
  INDIR=INDIRS(n)
  OUTDIR=OUTDIRS(n)
  print(INDIR)

all_files = systemfunc("ls "+INDIR+ "wrfout_d02_*")
dimfiles = dimsizes(all_files) ; how many files
nfiles = dimfiles(0) - 1

lap = new((/(nfiles+1)*4,south_north,west_east/),"float") ; here I calcuate 6 hourly GV (4 times a day)

do ifile = 0, nfiles

nifile = ifile*4
filigz = all_files(ifile)
f1 = addfile(filigz+".nc", "r")

timelist=(/0,2,4,6/)
time=0
do while(time.lt.dimsizes(timelist))

GH = wrf_user_getvar(f1,"geopt",timelist(time))
p = wrf_user_getvar(f1,"pressure",timelist(time))
GH_P = wrf_user_intrp3d(GH(:,:,:),p,"h",500.,0.,False)

GH_P =smth9(smth9( smth9(GH_P,0.5,0.25,False),0.5,0.25,False),0.5,0.25,False)
GH_P =smth9(smth9( smth9(GH_P,0.5,0.25,False),0.5,0.25,False),0.5,0.25,False)

lat0 = f1->XLAT
lon0 = f1->XLONG

; calculate geostrophic vorticity  no function available. 
G = 9.8005  ; m/s2, grivity at 45 deg lat used by the WMO
W = 7.292e-5 ; 1/s, earth ang rotation
rad = 4.*atan(1.)/180.
f0 = 2. * W * sin(lat0*rad) ; coriolis parameter

; Laplacian along west-east direction
do it =1,west_east-2 
lap_lon(:,it) = GH_P(:,it+1)+GH_P(:,it-1)-2.0*GH_P(:,it)
end do
;Edges
lap_lon(:,0) = lap_lon(:,1)
lap_lon(:,west_east-1) = lap_lon(:,west_east-2)
; divided by spacing and ff
lap_lon(:,:) = lap_lon(:,:)/dlonsq/f0

; Laplacian along south-north direction
do nt = 1,south_north-2
lap_lat(nt,:) = GH_P(nt+1,:)+GH_P(nt-1,:) -2.0*GH_P(nt,:)
end do
;Edges
lap_lat(0,:) = lap_lat(1,:)
lap_lat(south_north-1,:) = lap_lat(south_north-2,:)
; divided by spacing an ff
lap_lat(:,:) = lap_lat(:,:)/dlatsq/f0

; total laplacian by sum up lon/lat components
lap(nifile+time,:,:) = lap_lon + lap_lat

time=time+1
end do
end do

lap = lap*scale ; vorticity is negative for low in south hemisphere

; write out the vorticity 

;fout = addfile(INDIR+"GV_6hrly_grid_d02.nc","c")
;;fatt = True
;fatt@title = "Vorticity for domain 1"
;fatt@date = systemfunc("date")
;fileattdef(fout,fatt)

;fout->lat = latd02
;fout->lon = lond02
;fout->time = Time
;fout->lap = lap

lap_regrid = rcm2rgrid(latd02,lond02,lap,lat,lon,1) 
GV_series = dim_max_n(lap_regrid,(/1,2/)) ; extract the maximum values 
 
asciiwrite(OUTDIR+"GV_6hrly_timeseries_d02.txt", GV_series) 

delete([/lap,all_files,lap_regrid,GV_series/])
n=n+1
end do
end
