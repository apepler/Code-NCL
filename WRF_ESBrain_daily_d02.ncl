load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

;INDIRS=(/"/srv/ccrc/data36/z3478332/WRF/output/ERAI_R1_nudging_default_2007/out/","/srv/ccrc/data36/z3478332/WRF/output/ERAI_R2_nudging_default_2007/out/","/srv/ccrc/data36/z3478332/WRF/output/ERAI_R3_nudging_default_2007/out/","/srv/ccrc/data36/z3478332/WRF/output/ERAI_R1_nudging_default_2007_notopo/out/","/srv/ccrc/data36/z3478332/WRF/output/ERAI_R2_nudging_default_2007_notopo/out/","/srv/ccrc/data36/z3478332/WRF/output/ERAI_R3_nudging_default_2007_notopo/out/","/srv/ccrc/data37/z3478332/WRF/output/ERAI_R2_nudging_default_2007_BRAN/out/","/srv/ccrc/data37/z3478332/WRF/output/ERAI_R2_nudging_default_2007_BRAN_noeac/out/"/)
INDIRS=(/"/srv/ccrc/data37/z3478332/WRF/output/ERAI_R1_nudging_default_2007_BRAN/out/","/srv/ccrc/data37/z3478332/WRF/output/ERAI_R1_nudging_default_2007_BRAN_noeac/out/","/srv/ccrc/data37/z3478332/WRF/output/ERAI_R3_nudging_default_2007_BRAN/out/","/srv/ccrc/data37/z3478332/WRF/output/ERAI_R3_nudging_default_2007_BRAN_noeac/out/"/)


fname="dayrain_d02.txt"

fin=addfile("WRF_d02_ESB_mask.nc","r")
ESB_d02=fin->ESB

fin=addfile("/srv/ccrc/data13/z3393020/Analyses/share/geo_em_files/geo_em.d02.narclim.nc","r")
lat1 = rm_single_dims(wrf_user_getvar(fin,"XLAT_M",-1))
lon1 = rm_single_dims(wrf_user_getvar(fin,"XLONG_M",-1))

stats=(/"Mean rain","Max rain","Cells >= 5mm","Cells >= 25mm"/)
stats!0="Statistic"

year1=2007
year2=2008

n=0
do while(n.lt.dimsizes(INDIRS))
  INDIR=INDIRS(n)
  print(INDIR)
  dayrain=new((/731,4/),"float")
  fout=INDIR+fname

  FILES1 = systemfunc (" ls -1 " + INDIR + "wrfhrly_d02_200?-??-??_00:00:00")
  f1 = addfiles(FILES1+".nc","r")
  times=wrf_user_getvar(f1,"times",-1)
  numDAYS = dimsizes(times)/24
  var_in1=wrf_user_getvar(f1,"PREC_ACC_NC",-1)+wrf_user_getvar(f1,"PREC_ACC_C",-1)

  do ip = 0,numDAYS-1      
    var1 = dim_sum_n_Wrap(var_in1(ip*24:((ip+1)*24-1),:,:),0)
    dayrain(ip,0)=avg(mask(var1,ESB_d02,1))
    dayrain(ip,1)=max(mask(var1,ESB_d02,1))
    dayrain(ip,2)=num(mask(var1,ESB_d02,1).ge.5)
    dayrain(ip,3)=num(mask(var1,ESB_d02,1).ge.25)
  end do

  opt=True
  opt@fout=fout
  write_matrix (dayrain, "4f7.2", opt)

  delete([/dayrain,fout,opt@fout,var1,var_in1,numDAYS/])
  delete([/INDIR,f1,FILES1,times/])

  n=n+1
end do
