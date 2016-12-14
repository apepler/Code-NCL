;this file calculate vorticity from ERA_interim data for 300hpa, 400hpa and 500hpa.

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

INDIRS=(/"/srv/ccrc/data45/z3444417/CORDEX_postprocess/R2/6hr/zg500/"/)
OUTDIRS=(/"/srv/ccrc/data34/z3478332/WRF/ERA-nonudge/"/)

     south_north = 128 
     west_east = 199
     num_metgrid_levels = 38
     scale = -1.e+05     

     lap_lon = new((/south_north,west_east/),"float")
     lap_lat = new((/south_north,west_east/),"float")

cdf_file = addfile("/srv/ccrc/data13/z3393020/Analyses/share/geo_em_files/geo_em.d01.narclim.nc","r") ; inner domain of WRF ; outer domain of WRF (CORDEX domain)
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

G = 9.8005  ; m/s2, grivity at 45 deg lat used by the WMO
W = 7.292e-5 ; 1/s, earth ang rotation
rad = 4.*atan(1.)/180.
f0 = 2. * W * sin(latd02*rad) ; coriolis parameter
f02=f0(8:135,8:206)

dlon = 48918.09 ; WRF grid space for NARCliM domain
dlonsq = dlon*dlon
dlat = 48918.09
dlatsq = dlat*dlat

n=0
do while(n.lt.dimsizes(INDIRS))
;do while(n.lt.1)
  INDIR=INDIRS(n)
  OUTDIR=OUTDIRS(n)
  print(INDIR)

all_files = systemfunc("ls "+INDIR+ "zg500_*")
f1 = addfiles(all_files(11:30),"r")
GH = wrf_user_getvar(f1,"zg500",-1)*9.81

dimfiles = dimsizes(GH) ; how many files
nfiles = dimfiles(0) - 1

lap = new((/dimfiles(0),south_north,west_east/),"float") ; here I calcuate 6 hourly GV (4 times a day)

do ifile = 0, nfiles

GH_P =smth9(smth9( smth9(GH(ifile,:,:),0.5,0.25,False),0.5,0.25,False),0.5,0.25,False)
GH_P =smth9(smth9( smth9(GH_P,0.5,0.25,False),0.5,0.25,False),0.5,0.25,False)

; Laplacian along west-east direction
do it =1,west_east-2 
lap_lon(:,it) = GH_P(:,it+1)+GH_P(:,it-1)-2.0*GH_P(:,it)
end do
;Edges
lap_lon(:,0) = lap_lon(:,1)
lap_lon(:,west_east-1) = lap_lon(:,west_east-2)
; divided by spacing and ff
lap_lon(:,:) = lap_lon(:,:)/dlonsq/f02

; Laplacian along south-north direction
do nt = 1,south_north-2
lap_lat(nt,:) = GH_P(nt+1,:)+GH_P(nt-1,:) -2.0*GH_P(nt,:)
end do
;Edges
lap_lat(0,:) = lap_lat(1,:)
lap_lat(south_north-1,:) = lap_lat(south_north-2,:)
; divided by spacing an ff
lap_lat(:,:) = lap_lat(:,:)/dlatsq/f02

; total laplacian by sum up lon/lat components
lap(ifile,:,:) = lap_lon + lap_lat

end do

lap = lap*scale ; vorticity is negative for low in south hemisphere

lap_regrid = rcm2rgrid(latd02(8:135,8:206),lond02(8:135,8:206),lap,lat,lon,1) 
GV_series = dim_max_n(lap_regrid,(/1,2/)) ; extract the maximum values 
 
asciiwrite(OUTDIR+"GV_6hrly_timeseries.txt", GV_series) 

delete([/lap,all_files,lap_regrid,GV_series/])
n=n+1
end do

