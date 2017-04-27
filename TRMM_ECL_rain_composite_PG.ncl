load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

ECLDIR="/srv/ccrc/data40/z3444417/ECLs/Browning/3_FILTERED_EVENTS/v14p1_in-v14p1_out/1990-2010/PG3/AMS_LAND/WRF-N50/txt/"
DATADIR="/srv/ccrc/data40/z3444417/Data/TRMM-3B42/3HOURLY/"
OUTDIR="/srv/ccrc/data37/z3478332/ECL_evaluation/"
syear=1998

source="JRA55" ;"ERAI-75-6"
sres="50-6"
res=50
thresh="PG3"
duration="D3"

; This is the dimensions of the output grid
; Unlike mLDB, where all rounded to nearest 0.5-1 degree so points never match, for this one they can be centred anywhere so centre on the closest point
  lon0=fspan(-10,10,81)
  lon0!0="lon"
  lon0@units="degrees_E"
  lat0=fspan(-10,10,81)
  lat0!0="lat"
  lat0@units="degrees_N"

  filename = ECLDIR+source+"-"+sres+"-global-present-"+res+"-6_v14p1-"+duration+"-"+thresh+".csv"
  read_data= asciiread(filename,-1,"string")
  header    = read_data(0)        ; Header. Use for variable names.
  data      = read_data(1:)       ; Get rid of first line which is a header.
  quote = inttochar(34) 
  delim=","+quote
  date1 = tointeger(str_get_field(data,3,delim))
  I=ind(date1.ge.syear)
  date = tointeger(str_get_field(data(I),3,delim))*10000+tointeger(str_get_field(data(I),4,delim))*100+tointeger(str_get_field(data(I),5,delim))
  year=tointeger(str_get_field(data(I),3,delim))

  time = tointeger(str_get_field(data(I),6,delim))/3
  lat = tofloat(str_get_field(data(I),7,delim))
  lon= tofloat(str_get_field(data(I),8,delim))
  len=dimsizes(date)  

  ECL_PRCP=new((/len,dimsizes(lat0),dimsizes(lon0)/),"float")
  ECL_PRCP!0="Time"
  ECL_PRCP!1="lat"
  ECL_PRCP!2="lon"
  ECL_PRCP@description="6-hour instantaneous rainfall rate within 1000km radius of low centre"

; Get info about the 
  f1=addfile(DATADIR+"1998/3B42.19981003.7.nc","r")
  lat1=f1->latitude ; +-50
  lon1=f1->longitude ; -180  to 180, need to reshape? Naaa, don't care about 170E lows.
  lon1=where(lon1.lt.0,lon1+360.,lon1)

  I=ind_nearest_coord(lat,lat1,0)
  J=ind_nearest_coord(lon,lon1,0)

; Now, load in the data for each of our time steps.

  do ip=0,len-1
      if(mod(ip,100).eq.0)
         print(date(ip))
      end if
      if(I(ip).gt.40.and.I(ip).lt.360.and.J(ip).gt.20.and.J(ip).lt.1400.) then

      if(year(ip).ge.2000.and.year(ip).le.2010) then
         FILE1=addfile(DATADIR+year(ip)+"/3B42."+date(ip)+".7A.nc","r")
      else
         FILE1=addfile(DATADIR+year(ip)+"/3B42."+date(ip)+".7.nc","r")
      end if

      p=FILE1->pcp(time(ip),:,:)   
      ECL_PRCP(ip,:,:)=p((I(ip)-40):(I(ip)+40),(J(ip)-40):(J(ip)+40))
      
      delete([/FILE1,p/])
      end if
  end do
  ECL_PRCP!1="lat"
  ECL_PRCP!2="lon"

; Finally, write me a netcdf file

fout=OUTDIR+"ECLrain_TRMM_"+source+"-"+res+"-"+duration+"-"+thresh+".nc"
system("/bin/rm -f "+fout)
out = addfile(fout,"c")
out->ECL_PRCP=ECL_PRCP

