;********************************************************
; Plot storm stracks from wrfout files.
;********************************************************

load "/apps/ncl/6.5.0-CentOS7.5_64bit_gnu485/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "/apps/ncl/6.5.0-CentOS7.5_64bit_gnu485/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "/apps/ncl/6.5.0-CentOS7.5_64bit_gnu485/lib/ncarg/nclscripts/csm/contributed.ncl"
load "/apps/ncl/6.5.0-CentOS7.5_64bit_gnu485/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
load "/apps/ncl/6.5.0-CentOS7.5_64bit_gnu485/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/apps/ncl/6.5.0-CentOS7.5_64bit_gnu485/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"


begin

 
fs = systemfunc("ls ../../WRFV3/run/WRFOUT_6MIN/wrfout_d03*")

f1 = addfiles(fs+".nc","r")
u10 = f1[:]->U10(:,1095,455)
print(u10)
printVarSummary(u10)

;  times = wrf_user_list_times(f1)

;  ntimes = dimsizes(times)         ; number of times in the file(s)

;  print("There are " +ntimes+ " times in this file")

;loc = wrf_user_ij_to_ll(f, 455., 1095., True)
; print("lon/lat locations are: " + loc)




end
