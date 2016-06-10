
load "$NCARG_LIB/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_LIB/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_LIB/ncarg/nclscripts/csm/contributed.ncl"



begin
      ;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      ; User specified options

      ;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      ; read the lat and long for one of the file
      f = addfile("geo_em.d01.nc","r")
      latd02 = f->XLAT_M(0,:,:)
      lond02 = f->XLONG_M(0,:,:)
	  
	  dsize = dimsizes(latd02)
	  
	    ;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      ; generate the extraction grids  which used by Dowdy to choose the maximum of GV
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
	   
     ;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      ; Read in GV files
      ;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      all_files= systemfunc("ls 2060-2080/CCCMA3.1_vorticity_d01_2060-2079_6hrly_R1*.nc")
      print(all_files)     
      f1 = addfiles(all_files,"r") 
      rain_series = f1[:]->lap

     ;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      ; Regrid GV from WRF grids to the extraction grids
      rain_series_regrid = rcm2rgrid(latd02,lond02,rain_series,lat,lon,1) 

      GV_series = dim_max_n(rain_series_regrid,2) ; extract the maximum values 
      GV_1 = dim_max_n(IPV_series,1) ; extract the maximum values
 
      asciiwrite("CCCMA3.1_vor_2060-2079_R1.txt", GV_1) 

end
