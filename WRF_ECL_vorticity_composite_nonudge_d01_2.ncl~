load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

ECLDIR="/srv/ccrc/data34/z3478332/ECLtracks/outputUM_"

INDIRS=(/"/srv/ccrc/data45/z3478332/WRF/output/ERAI_R2_nonudging_notopo/out/impact/","/srv/ccrc/data34/z3478332/WRF/ERA-nonudge/"/)
OUTDIRS=INDIRS

names=(/"ERA-nonudge_notopo","ERA-nonudge"/)
cat=(/"p100_rad2cv1","p100_rad2cv1_2"/)
cat2="rad2_p100_cv1.0"
dom="d01"

fin=addfile("/srv/ccrc/data13/z3393020/Analyses/share/geo_em_files/geo_em.d01.narclim.nc","r")
lat1 = rm_single_dims(wrf_user_getvar(fin,"XLAT_M",-1))
lon1 = rm_single_dims(wrf_user_getvar(fin,"XLONG_M",-1))

n=0
do while(n.lt.dimsizes(INDIRS))
  INDIR=INDIRS(n)
  print(INDIR)

; Get the ECL list
  filename = ECLDIR+names(n)+"/"+cat(n)+"/"+dom+"/"+"ECLfixes_"+names(n)+"_"+dom+"_"+cat2+"_typing_impactsC2.csv"
  read_data= asciiread(filename,-1,"string")
  header    = read_data(0)        ; Header. Use for variable names.
  data      = read_data(1:)       ; Get rid of first line which is a header.
  loc = tointeger(str_get_field(data,11,","))
  I=ind(loc.eq.1)
  lat = tofloat(str_get_field(data(I),8,","))  
  lon= tofloat(str_get_field(data(I),7,","))  
  delete(I)

  Data1=addfile(INDIR+"ECLcomposites_"+names(n)+"_d01_rad2_p100_cv1.0_surface.nc","r")
  p=Data1->SLP_d01
  Data1=addfile(INDIR+"ECLcomposites_"+names(n)+"_d01_rad2_p100_cv1.0_vort.nc","r")
  gv=Data1->PVO_d01(:,:,3,:)

  len=dimsizes(lat)
  ECL_slp=new((/len,21,21/),"float")
  ECL_slp!0="Time"
  ECL_slp!1="south_north"
  ECL_slp!2="east_west"
  ECL_gv=ECL_slp

  I=getind_latlon2d(lat1,lon1,lat,lon)
  do ip=0,len-1
     if(I(ip,0).ge.10.and.I(ip,0).le.133.and.I(ip,1).ge.10.and.I(ip,1).le.204) then
       ECL_slp(ip,:,:)=(/p((I(ip,0)-10):(I(ip,0)+10),(I(ip,1)-10):(I(ip,1)+10),ip)/)
       ECL_gv(ip,:,:)=(/gv((I(ip,0)-10):(I(ip,0)+10),(I(ip,1)-10):(I(ip,1)+10),ip)/)
     end if
  end do

fout=OUTDIRS(n)+"ECLcomposites_"+names(n)+"_"+dom+"_"+cat2+"_slpgv.nc"
system("/bin/rm -f "+fout)
out = addfile(fout,"c")
out->ECL_slp=ECL_slp
out->ECL_gv=ECL_gv
delete([/out,fout,ECL_slp,ECL_gv,p,gv,I/])
delete([/filename,read_data,header,data,loc,lat,lon/])
n=n+1
end do
