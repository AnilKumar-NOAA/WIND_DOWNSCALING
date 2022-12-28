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
 fs = systemfunc("ls ../WRF/hourly_data/wrfoutd01*")
 nfs= dimsizes(fs)
;print(fs)
    f = addfiles(fs,"r")
print(f)
ntimes=21
wspd      = new((/ntimes/),float)
maxwspd   = new((/ntimes/),float)
psfc      = new((/ntimes/),float)
wdir      = new((/ntimes/),float)
i=0
do while (i.le.ntimes-1)
wspd(i)    = f[i]->wspd10m(:,459,591)   ; (time, lat,lon)    ; (2,64,128)
maxwspd(i)    = f[i]->wspd10max(:,459,591)        ; V10(:,29.301,-94.797) 
psfc(i)  = f[i]->slp(:,459,591)
wdir(i)  = f[i]->wdir10m(:,459,591)
i = i + 1
end do

   model_wspd = wspd
   model_maxwspd = maxwspd
   model_wdir = wdir
   model_psfc = psfc


z1 = asciiread("./8656483.txt",(/21,7/),"float")
  
obs_date    = z1(:,0)
obs_time    = z1(:,1)
obs_wspd    = z1(:,2)
obs_wdir    = z1(:,3)
obs_maxwspd = z1(:,4)
obs_psfc    = z1(:,6)

obs_wspd@_FillValue = 9999
obs_wdir@_FillValue = 9999
obs_maxwspd@_FillValue = 9999
obs_psfc@_FillValue = 9999

obs_wspd = obs_wspd*0.514
obs_maxwspd = obs_maxwspd*0.514

print(model_maxwspd + "  " + obs_maxwspd)

 filename = "Beaufort_ready.csv"
  system("rm -rf " + filename)

dq = str_get_dq() 
fields = (/"DATE_WV", "TIME_WV", "OBS_WIND_WV", "OBS_GUST_WV", "OBS_WDIR_WV", "OBS_PSFC_WV", "MODEL_WIND_WV", "MODEL_GUST_WV", "MODEL_WDIR_WV", "MODEL_PSFC_WV"/)
 fields = dq + fields + dq                      ; Pre/append quotes to field names
  header = [/str_join(fields,",")/]              ; Header is field names separated


 alist  = [/obs_date,obs_time,obs_wspd,obs_maxwspd,obs_wdir,obs_psfc,model_wspd,model_maxwspd,model_wdir,model_psfc/]
  format = "%7f,%g,%g,%g,%g,%g,%g,%g,%g,%g"
 write_table(filename, "w", header, "%s")   ; Write header to CSV file.
  write_table(filename, "a", alist, format)





end
