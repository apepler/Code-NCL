load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

ECLDIR="/srv/ccrc/data34/z3478332/ECLtracks/"
DATADIR="/srv/ccrc/data40/z3444417/Data/QuikSCATM/global/"
OUTDIR="/srv/ccrc/data37/z3478332/ECL_evaluation/"
syear=1988

source="ERAI" ;"ERAI-75-6"
res=75
rad="rad2cv1"
proj=240

; This will have to be done differently for ERAI and MERRA as different resolutions.
; And Ale didn't regrid them all. Lame. 
DATADIR="/srv/ccrc/data40/z3444417/Data/"+source+"/global/"

if(source.eq."ERAI") then
  lon0=fspan(-10.08,10.08,29)
  lon0!0="lon"
  lon0@units="degrees_E"
  lat0=fspan(-10.08,10.08,29)
  lat0!0="lat"
  lat0@units="degrees_N"

  fin=addfile("/srv/ccrc/data40/z3444417/Data/ERAI/global/psl/raw/fullres/EIN198904_an_MSLP.nc","r")
  lat1=fin->g0_lat_1
  lon1=fin->g0_lon_2
  delete(fin)
  fin=addfile("/srv/ccrc/data40/z3444417/Data/ERAI/global/U10/raw/fullres/10U_6hrs_sfc_2002_10.nc","r")
  lat2=fin->g0_lat_1
  lon2=fin->g0_lon_2
end if

lon2=where(lon2.lt.0,lon2+360.,lon2)
lon2a=lon2
lon2a(0:239)=lon2(240:479)
lon2a(240:479)=lon2(0:239)

if(source.eq."MERRA") then
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
  time = tointeger(str_get_field(data(I),5,delim))/6
  lat = tofloat(str_get_field(data(I),9,delim))
  lon= tofloat(str_get_field(data(I),8,delim))
  len=dimsizes(date)  
  year=floor(date/10000.)
  month=tointeger(mod(floor(date/100.),100))
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
  J2=ind_nearest_coord(lon,lon2a,0)

 do ip=0,len-1
      if(mod(ip,100).eq.0)
         print(date(ip))
      end if
 
       FILE1=addfile(DATADIR+"U10/raw/fullres/10U_6hrs_sfc_"+year(ip)+"_"+sprinti("%2.2i",month(ip))+".nc","r")
       FILE2=addfile(DATADIR+"V10/raw/fullres/10V_6hrs_sfc_"+year(ip)+"_"+sprinti("%2.2i",month(ip))+".nc","r")
       FILE3=addfile(DATADIR+"psl/raw/fullres/EIN"+year(ip)+sprinti("%2.2i",month(ip))+"_an_MSLP.nc","r")

       n=(day(ip)-1)*4+time(ip)

       u=short2flt(FILE1->10U_GDS0_SFC(n,:,:))
       v=short2flt(FILE2->10V_GDS0_SFC(n,:,:))
       p=FILE3->MSL_GDS0_SFC(n,:,:)/100

       ; Do I need to reshape u/v since longitude is -180 to 180?
       ; Prooobably
       u2=u
       u2(:,0:239)=u(:,240:479)
       u2(:,240:479)=u(:,0:239)
       v2=v
       v2(:,0:239)=v(:,240:479)
       v2(:,240:479)=v(:,0:239)
 
       if(I2(ip).gt.14.and.J2(ip).gt.14.and.I2(ip).lt.227.and.J2(ip).lt.466) then
         ECL_U10(ip,:,:)=(/u2((I2(ip)+14):(I2(ip)-14),(J2(ip)-14):(J2(ip)+14))/)
         ECL_V10(ip,:,:)=(/v2((I2(ip)+14):(I2(ip)-14),(J2(ip)-14):(J2(ip)+14))/)
         ECL_SLP(ip,:,:)=(/p((I(ip)+14):(I(ip)-14),(J(ip)-14):(J(ip)+14))/)
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
