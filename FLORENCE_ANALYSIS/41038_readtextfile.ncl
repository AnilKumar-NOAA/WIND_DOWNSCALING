;********************************************************
; Plot storm stracks from wrfout files.
;********************************************************

load "/opt/ncarg/6.2.0/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "/opt/ncarg/6.2.0/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "/opt/ncarg/6.2.0//lib/ncarg/nclscripts/csm/contributed.ncl"
load "/opt/ncarg/6.2.0/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
load "/opt/ncarg/6.2.0/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"



z1 = asciiread("./41038_14sep.txt",(/21,18/),"float")
  
obs_date    = z1(:,0)
obs_time    = z1(:,3)
obs_wspd    = z1(:,6)
obs_wdir    = z1(:,5)
obs_maxwspd = z1(:,7)
obs_psfc    = z1(:,12)

obs_wspd@_FillValue = 9999
obs_wdir@_FillValue = 9999
obs_maxwspd@_FillValue = 9999
obs_psfc@_FillValue = 9999

obs_wspd = obs_wspd
obs_maxwspd = obs_maxwspd

print(obs_wspd + "  " + obs_maxwspd)


;end
