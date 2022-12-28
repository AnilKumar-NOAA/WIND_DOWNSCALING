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
 fs = systemfunc("ls ../WRF/run/met_em.d01*")
 nfs= dimsizes(fs)
;print(fs)
    f = addfiles(fs,"r")
print(f)
ntimes=21
uu      = new((/ntimes/),float)
vv      = new((/ntimes/),float)
psfc      = new((/ntimes/),float)
i=0
do while (i.le.ntimes-1)
uu(i)    = f[i]->UU(:,0,318,336)   ; (time, lat,lon)    ; (2,64,128)
vv(i)    = f[i]->VV(:,0,318,336)
psfc(i)    = f[i]->PSFC(:,318,336)
i = i + 1
end do

   model_wspd = sqrt(uu^2+vv^2) 
   model_wdir = wind_direction(uu,vv,0)
   model_psfc = psfc/100.



 filename = "HWRF_WB_ready.csv"
  system("rm -rf " + filename)

dq = str_get_dq() 
fields = (/"HWRF_WIND_WB", "HWRF_WDIR_WB", "HWRF_PSFC_WB"/)
 fields = dq + fields + dq                      ; Pre/append quotes to field names
  header = [/str_join(fields,",")/]              ; Header is field names separated


 alist  = [/model_wspd,model_wdir,model_psfc/]
  format = "%g,%g,%g"
 write_table(filename, "w", header, "%s")   ; Write header to CSV file.
  write_table(filename, "a", alist, format)





end
