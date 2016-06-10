;this file calculate vorticity from ERA_interim data for 300hpa, 400hpa and 500hpa.


load "$NCARG_LIB/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_LIB/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_LIB/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_LIB/ncarg/nclscripts/wrf/WRF_contributed.ncl"
load "$NCARG_LIB/ncarg/nclscripts/wrf/WRFUserARW.ncl"


begin

     south_north = 144 
     west_east = 215
     num_metgrid_levels = 38
     scale = -1.e+05     

     lap_lon = new((/south_north,west_east/),"float")
     lap_lat = new((/south_north,west_east/),"float")

cdf_file = addfile("geo_em.d01.nc","r") ; inner domain of WRF ; outer domain of WRF (CORDEX domain)
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


dlon = 48918.09 ; WRF grid space for NARCliM domain
dlonsq = dlon*dlon
dlat = 48918.09
dlatsq = dlat*dlat

indir_mod1  = "/home/z3393020/WRFouts/NARCliM/CCCMA3.1/R1/2060-2080/out/"  ;directory of WRF raw data

print(indir_mod1)

all_files = systemfunc("ls "+indir_mod1+ "wrfout_d01_*")

print(all_files)

dimfiles = dimsizes(all_files) ; how many files

nfiles = dimfiles(0) - 1

lap = new((/(nfiles+1)*4,south_north,west_east/),"float") ; here I calcuate 6 hourly GV (4 times a day)

do ifile = 0, nfiles

nifile = ifile*4

filigz = all_files(ifile)
print(filigz)

f1 = addfile(filigz+".nc", "r")

time = 0  ; 00hr
GH = wrf_user_getvar(f1,"geopt",time)
p = wrf_user_getvar(f1,"pressure",time)
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
lap(nifile,:,:) = lap_lon + lap_lat

; 06h
time = 2
GH = wrf_user_getvar(f1,"geopt",time)
p = wrf_user_getvar(f1,"pressure",time)
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
lap(nifile+1,:,:) = lap_lon + lap_lat

; 12h
time =4 
GH = wrf_user_getvar(f1,"geopt",time)
p = wrf_user_getvar(f1,"pressure",time)
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
lap(nifile+2,:,:) = lap_lon + lap_lat

; 18h
time = 6
GH = wrf_user_getvar(f1,"geopt",time)
p = wrf_user_getvar(f1,"pressure",time)
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
lap(nifile+3,:,:) = lap_lon + lap_lat

end do

lap = lap*scale ; vorticity is negative for low in south hemisphere

; write out the vorticity 

fout = addfile("2060-2080/CCCMA3.1_vorticity_d01_2060-2079_6hrly_R1.nc","c")
fatt = True
fatt@title = "Vorticity for domain 1"
fatt@date = systemfunc("date")
fileattdef(fout,fatt)

fout->lat = latd02
fout->lon = lond02
;fout->time = Time
fout->lap = lap

end
