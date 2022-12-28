;********************************************************
; Plot storm stracks from wrfout files.
;********************************************************

load "/opt/ncl/6.4.0-precompiled/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "/opt/ncl/6.4.0-precompiled/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "/opt/ncl/6.4.0-precompiled/lib/ncarg/nclscripts/csm/contributed.ncl"
load "/opt/ncl/6.4.0-precompiled/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
load "/opt/ncl/6.4.0-precompiled/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"


begin

z1 = asciiread("./eagle_point.csv",(/121,7/),"float")
obs_date = z1(0:120:5,0)
obs_time = z1(0:120:5,1)
obs_wspd = z1(0:120:5,2)
obs_maxspd=z1(0:120:5,4)
obs_psfc = z1(0:120:5,6)

print(obs_date + "  " + obs_time)
;obs_time1 = obs_time(6:42:1)
;obs_wspd1 = obs_wspd(6:42:1)

 fs = systemfunc("ls ../WRF_HWRFHOURLY_DEFAULT/wrfout_d03*0:00*")
 nfs= dimsizes(fs)
;print(fs)
    f = addfiles(fs+".nc","r")
;print(f)
times  = wrf_user_list_times(f)  ; get times in the file
  ntimes = dimsizes(times)         ; number of times in the file(s)

;  print("There are " +ntimes+ " times in this file")

loc = wrf_user_ij_to_ll(f, 393., 690., True)
 print("lon/lat locations are: " + loc)

fs1 = systemfunc("ls ../WRF_HWRFHOURLY_INUNDATION/wrfout_d03*0:00*")
 nfs1= dimsizes(fs1)
;print(fs)
    f1 = addfiles(fs1+".nc","r")
;print(f)
times1  = wrf_user_list_times(f1)  ; get times in the file
  ntimes1 = dimsizes(times1)         ; number of times in the file(s)

;  print("There are " +ntimes+ " times in this file")

loc1 = wrf_user_ij_to_ll(f1, 690., 393., True)
 print("lon/lat locations are: " + loc1)


end
