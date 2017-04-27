load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

ECLDIR="/srv/ccrc/data34/z3478332/ECLtracks/"
OUTDIR="/srv/ccrc/data37/z3478332/ECL_evaluation/"
syear=1988

source="MERRA" ;"ERAI-75-6"
res=50
rad="rad2cv1"
proj=240

; This will have to be done differently for ERAI and MERRA as different resolutions.
; And Ale didn't regrid them all. Lame. 
DATADIR="/srv/ccrc/data30/z3444417/Data/"+source+"/global/"

if(source.eq."MERRA") then
  lon0=fspan(-10.,10.,31)
  lon0!0="lon"
  lon0@units="degrees_E"
  lat0=fspan(-10.,10.,41)
  lat0!0="lat"
  lat0@units="degrees_N"

  fin=addfile(DATADIR+"psl/raw/MERRA300.prod.assim.tavg1_2d_slv_Nx.20091231.SUB.nc","r")
  lat1=fin->latitude
  lon1=fin->longitude
  delete(fin)
  fin=addfile(DATADIR+"U10/raw/MERRA300.prod.assim.tavg1_2d_slv_Nx.20091231.SUB.nc","r")
  lat2=fin->latitude
  lon2=fin->longitude
  delete(fin)
end if

  dir=ECLDIR+"outputUM_"+source+"_"+res+"_topo_"+rad+"_proj"+proj+"/"
  filename =dir+"ECLfixes_umelb_"+source+"_"+res+"_topo_"+rad+"_proj"+proj+".csv"
  read_data= asciiread(filename,-1,"string")
  header    = read_data(0)        ; Header. Use for variable names.
  data      = read_data(1:)       ; Get rid of first line which is a header.
  quote = inttochar(34) 
  delim=",:"+quote
  date1 = tointeger(str_get_field(data,4,delim))
  I=ind(date1.ge.syear*10000)
  date = tointeger(str_get_field(data(I),4,delim))
  time = tointeger(str_get_field(data(I),5,delim))
  lat = tofloat(str_get_field(data(I),9,delim))
  lon= tofloat(str_get_field(data(I),8,delim))
  len=dimsizes(date)  
  year=floor(date/10000.)
  month=mod(floor(date/100.),100)
  day=mod(date,100)
  delete(I)

; Output files

  ECL_U10=new((/len,dimsizes(lat0),dimsizes(lon0)/),"double")
  ECL_U10!0="Time"
  ECL_U10!1="lat"
  ECL_U10!2="lon"
  ECL_V10=ECL_U10
  ECL_SLP=ECL_U10
  ECL_U10@description="6-hour instantaneous 10m zonal wind within 1000km radius of low centre"
  ECL_V10@description="6-hour instantaneous 10m meridional wind within 1000km radius of low centre"
  ECL_SLP@description="6-hour instantaneous slp within 1000km radius of low centre"

  I=ind_nearest_coord(lat,lat1,0)
  J=ind_nearest_coord(lon,lon1,0)
  I2=ind_nearest_coord(lat,lat2,0)
  J2=ind_nearest_coord(lon,lon2,0)

 do ip=0,len-1
      if(mod(ip,100).eq.0) then
         print(date(ip))
      end if

      if(year(ip).le.1992) then
         mnum=100
      else if(year(ip).le.2000) then
         mnum=200
      else
         mnum=300
      end if
      end if
 
       FILE1=addfile(DATADIR+"U10/raw/MERRA"+mnum+".prod.assim.tavg1_2d_slv_Nx."+date(ip)+".SUB.nc","r")
       FILE2=addfile(DATADIR+"V10/raw/MERRA"+mnum+".prod.assim.tavg1_2d_slv_Nx."+date(ip)+".SUB.nc","r")
       FILE3=addfile(DATADIR+"psl/raw/MERRA"+mnum+".prod.assim.tavg1_2d_slv_Nx."+date(ip)+".SUB.nc","r")

       u=FILE1->u10m(time(ip),:,:)
       v=FILE2->v10m(time(ip),:,:)
       p=FILE3->slp(time(ip),:,:)/100
 
       if(I(ip).gt.20.and.I(ip).lt.124.and.J(ip).gt.15.and.J(ip).lt.162.and.J2(ip).lt.525) then
         ECL_U10(ip,:,:)=(/u((I2(ip)-20):(I2(ip)+20),(J2(ip)-15):(J2(ip)+15))/)
         ECL_V10(ip,:,:)=(/v((I2(ip)-20):(I2(ip)+20),(J2(ip)-15):(J2(ip)+15))/)
         ECL_SLP(ip,:,:)=(/p((I(ip)-20):(I(ip)+20),(J(ip)-15):(J(ip)+15))/)
       end if

      delete([/FILE1,FILE2,FILE3,u,v,p/])
  end do

; Finally, write me a netcdf file
ECL_WS10=(ECL_U10^2+ECL_V10^2)^0.5
print(max(ECL_WS10))
copy_VarMeta(ECL_U10,ECL_WS10)
ECL_WS10@description="6-hour instantaneous wind speed within 500km radius of low centre"

fout=OUTDIR+"ECLwindslp_LAP_"+source+"_"+res+"_"+rad+"_proj"+proj+".nc"
system("/bin/rm -f "+fout)
out = addfile(fout,"c")
out->ECL_U10=ECL_U10
out->ECL_V10=ECL_V10
out->ECL_WS10=ECL_WS10
out->ECL_SLP=ECL_SLP
