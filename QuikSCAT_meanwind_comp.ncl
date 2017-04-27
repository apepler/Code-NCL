load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

QDIR="/srv/ccrc/data40/z3444417/Data/QuikSCATM/global/"
OUTDIR="/srv/ccrc/data37/z3478332/ECL_evaluation/"
sources=(/"QuikSCAT","ERAI","MERRA","JRA55","CFSR"/)

years=ispan(1990,2009,1)

f1=addfile(QDIR+"U10/raw/analysis_19880101_v11l30flk.nc","r")
lat1=f1->lat
lon1=f1->lon

IQ=ind(lat1.ge.-60.and.lat1.le.0.)
JQ=ind(lon1.ge.100.and.lon1.le.180.)
lat1a=lat1(IQ)
lon1a=lon1(JQ)

uwnd=new((/dimsizes(sources),dimsizes(years),dimsizes(lat1a),dimsizes(lon1a)/),"float")
uwnd!0="Source"
uwnd!1="Year"
uwnd!2="Lat"
uwnd!3="Lon"
vwnd=uwnd

Opt                = True
Opt@SrcRegional    = True             ; These are necessary
Opt@DstRegional    = True
Opt@DstGridLat = lat1a
Opt@DstGridLon = lon1a
Opt@ForceOverwrite = True
Opt@SrcFileName    = "src_uv.nc"
Opt@DstFileName    = "dst_uv.nc"
Opt@WgtFileName    = "wgt_uv.nc"
Opt@DstGridType = "rectilinear"

Opt2=True
Opt2@DstGridType = "rectilinear"

do s=4,dimsizes(sources)-1
 source=sources(s)
 print(source)
 if(source.eq."ERAI") then
   DATADIR="/srv/ccrc/data40/z3444417/Data/ERAI/global/"
   fin=addfile("/srv/ccrc/data40/z3444417/Data/ERAI/global/U10/raw/fullres/10U_6hrs_sfc_2002_10.nc","r")
   lat2=fin->g0_lat_1
   lon2=fin->g0_lon_2
   delete(fin)
 end if

 if(source.eq."JRA55") then
   DATADIR="/srv/ccrc/data41/z3444417/Data/JRA55/global/"
   fin=addfile("/srv/ccrc/data41/z3444417/Data/JRA55/global/psl/raw/JRA55_psl_2005_3.nc","r")
   lat2=fin->g4_lat_2
   lon2=fin->g4_lon_3
   delete(fin)
 end if

 if(source.eq."MERRA") then
   DATADIR="/srv/ccrc/data30/z3444417/Data/MERRA/global/"
   fin=addfile("/srv/ccrc/data30/z3444417/Data/MERRA/global/U10/raw/MERRA300.prod.assim.tavg1_2d_slv_Nx.20091231.SUB.nc","r")
   lat2=fin->latitude
   lon2=fin->longitude
   delete(fin)
 end if

 if(source.eq."CFSR") then
   DATADIR="/srv/ccrc/data28/z3444417/Data/CFSR/global/UV10/raw/"
   fin=addfile("/srv/ccrc/data28/z3444417/Data/CFSR/global/UV10/raw/CFSR_wnd10m_198001.nc","r")
   lat2=fin->latitude
   lon2=fin->longitude
   IC=ind(lat2.ge.-65.and.lat2.le.5.)
   JC=ind(lon2.ge.95.and.lon2.le.185.)
   lat2a=lat2(IC)
   lon2a=lon2(JC)
   delete(fin)
 end if

 do ip=0,dimsizes(years)-1
    print(years(ip))
; Get reanalysis
    if(source.eq."QuikSCAT") then
      FILE1=addfiles(systemfunc (" ls -1 " + QDIR+"U10/raw/analysis_"+years(ip)+"*.nc"),"r")
      FILE2=addfiles(systemfunc (" ls -1 " + QDIR+"V10/raw/analysis_"+years(ip)+"*.nc"),"r")
      uwnd(s,ip,:,:)=(/dim_avg_n(short2flt(FILE1[:]->uwnd(:,IQ,JQ)),0)/)
      vwnd(s,ip,:,:)=(/dim_avg_n(short2flt(FILE2[:]->vwnd(:,IQ,JQ)),0)/)     
      delete([/FILE1,FILE2/])
    end if

    if(source.eq."ERAI") then
      FILE1=addfiles(systemfunc (" ls -1 " + DATADIR+"U10/raw/fullres/10U_6hrs_sfc_"+years(ip)+"*.nc"),"r")
      FILE2=addfiles(systemfunc (" ls -1 " + DATADIR+"V10/raw/fullres/10V_6hrs_sfc_"+years(ip)+"*.nc"),"r")
      u=dim_avg_n_Wrap(short2flt(FILE1[:]->10U_GDS0_SFC),0)
      v=dim_avg_n_Wrap(short2flt(FILE2[:]->10V_GDS0_SFC),0)
      delete([/FILE1,FILE2/])
     end if

     if(source.eq."CFSR") then
       FILE1=addfiles(systemfunc (" ls -1 " + DATADIR+"CFSR_wnd10m_"+years(ip)+"*.nc"),"r")
       tmp=FILE1[:]->time
       times=ispan(0,dimsizes(tmp)-1,6)   
       u=dim_avg_n_Wrap(FILE1[:]->UGRD_10maboveground(times,IC,JC),0)
       v=dim_avg_n_Wrap(FILE1[:]->VGRD_10maboveground(times,IC,JC),0)
       delete([/FILE1,tmp,times/])
     end if

     if(source.eq."JRA55") then
       FILE1=addfiles(systemfunc (" ls -1 " + DATADIR+"U10/raw/JRA55_U10_"+years(ip)+"*.nc"),"r")
       FILE2=addfiles(systemfunc (" ls -1 " + DATADIR+"V10/raw/JRA55_V10_"+years(ip)+"*.nc"),"r")
       u=dim_avg_n_Wrap(FILE1[:]->UGRD_GDS4_HTGL(:,1,:,:),0)
       v=dim_avg_n_Wrap(FILE2[:]->VGRD_GDS4_HTGL(:,1,:,:),0)
       delete([/FILE1,FILE2/])
     end if

     if(source.eq."MERRA") then
        if(years(ip).le.1992) then
         mnum=100
        else if(years(ip).le.2000) then
         mnum=200
        else
         mnum=300
        end if
        end if 

      FILE1=addfiles(systemfunc (" ls -1 " + DATADIR+"U10/raw/MERRA"+mnum+".prod.assim.tavg1_2d_slv_Nx."+years(ip)+"*.nc"),"r")
      FILE2=addfiles(systemfunc (" ls -1 " + DATADIR+"V10/raw/MERRA"+mnum+".prod.assim.tavg1_2d_slv_Nx."+years(ip)+"*.nc"),"r")
      tmp=FILE1[:]->time
      times=ispan(0,dimsizes(tmp)-1,6)    
      u=dim_avg_n_Wrap(FILE1[:]->u10m(times,:,:),0)
      v=dim_avg_n_Wrap(FILE2[:]->v10m(times,:,:),0)
      delete([/FILE1,FILE2,tmp,times/])
    end if
; Regrid reanalysis

  if(s.gt.0) then
    if(ip.eq.0) then
      uwnd(s,ip,:,:) = (/ESMF_regrid(u,Opt)/)   ; Do the regridding - 0.5 degrees
    else
      uwnd(s,ip,:,:)= (/ESMF_regrid_with_weights(u,"wgt_uv.nc",Opt2)/)
    end if
    vwnd(s,ip,:,:)= (/ESMF_regrid_with_weights(v,"wgt_uv.nc",Opt2)/)
    delete([/u,v/])
  end if
end do ; Done - years

fout=OUTDIR+"wind_annual_"+source+".nc"
system("/bin/rm -f "+fout)
out = addfile(fout,"c")
out->uwnd=uwnd(s,:,:,:)
out->vwnd=vwnd(s,:,:,:)
delete([/out,fout/])
if(s.gt.0) then 
  delete([/lat2,lon2/])
end if

end do ; Done - sources

;fout=OUTDIR+"wind_comp_annual.nc"
;system("/bin/rm -f "+fout)
;out = addfile(fout,"c")
;out->uwnd=uwnd
;out->vwnd=vwnd
;out->sources=sources
;out->lat=lat1a
;out->lon=lon1a


