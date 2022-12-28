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
 fs = systemfunc("ls ../WRF/hourly_data/wrfoutd03*")
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
wspd(i)    = f[i]->wspd10m(:,708,303)   ; (time, lat,lon)    ; (2,64,128)
maxwspd(i)    = f[i]->wspd10max(:,708,303)        ; V10(:,29.301,-94.797) 
psfc(i)  = f[i]->slp(:,708,303)
wdir(i)  = f[i]->wdir10m(:,708,303)
i = i + 1
end do

   model_wspd = wspd
   model_maxwspd = maxwspd
   model_wdir = wdir
   model_psfc = psfc



 filename = "KILM_hourly_ready.csv"
  system("rm -rf " + filename)

dq = str_get_dq() 
fields = (/"MODEL_WIND_WV", "MODEL_GUST_WV", "MODEL_WDIR_WV", "MODEL_PSFC_WV"/)
 fields = dq + fields + dq                      ; Pre/append quotes to field names
  header = [/str_join(fields,",")/]              ; Header is field names separated


 alist  = [/model_wspd,model_maxwspd,model_wdir,model_psfc/]
  format = "%g,%g,%g,%g"
 write_table(filename, "w", header, "%s")   ; Write header to CSV file.
  write_table(filename, "a", alist, format)





end
