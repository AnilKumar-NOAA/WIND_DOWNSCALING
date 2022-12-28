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
;print(fs)
    f1 = addfiles(fs1+".nc","r")
;print(f)
  ntimes1 = 35 ; dimsizes(f1)         ; number of times in the file(s)

;  print("There are " +ntimes+ " times in this file")

loc1 = wrf_user_ij_to_ll(f1, 643., 529., True)
 print("lon/lat locations are: " + loc)
uu1      = new((/ntimes1/),float)
vv1      = new((/ntimes1/),float)
psfc1      = new((/ntimes1/),float)
i1=0
do while (i1.le.ntimes1-1)
uu1(i1)    = f1[i1]->U(:,0,529,643)   ; (time, lat,lon)    ; (2,64,128)
vv1(i1)    = f1[i1]->V(:,0,529,643)        ; V10(:,29.301,-94.797)
psfc1(i1)  = f1[i1]->PSFC(:,529,643)
i1 = i1 + 1
end do
   model_wspd1 = sqrt(uu1^2+vv1^2) ;wind_speed(uu,vv)
   model_wdir1 = wind_direction(uu1,vv1,0) 
   model_psfc1 = psfc1/100.
print(ntimes + " " + ntimes1)

z1 = asciiread("./obs_panamacity_hourly.txt",(/35,9/),"float")
obs_date = z1(:,0)
obs_time = z1(:,1)
obs_wspd = z1(:,2)*0.514
obs_wdir = z1(:,3)
obs_psfc = z1(:,6)

print(obs_wspd)

;print(obs_date + "  " + obs_wspd + "  " + model_wspd + "  " + model_wspd1)
print(obs_date + "  " + obs_wdir + "  " + model_wdir + "  " + model_wdir1)
 filename = "hrrr_panamacity_hourly_ready.csv"
  system("rm -rf " + filename)

dq = str_get_dq() 
fields = (/"DATE", "TIME", "OBS_WSPD", "OBS_WDIR", "OBS_PSFC","HRRR_WSPD","HRRR_WDIR", \
                    "HRRR_PSFC","WRFHRRR_WSPD","WRFHRRR_WDIR","WRFHRRR_PSFC"/)
 fields = dq + fields + dq                      ; Pre/append quotes to field names
  header = [/str_join(fields,",")/]              ; Header is field names separated


 alist  = [/obs_date,obs_time,obs_wspd,obs_wdir,obs_psfc,model_wspd,model_wdir,model_psfc,model_wspd1,model_wdir1,model_psfc1/]
  format = "%7f,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g"
 write_table(filename, "w", header, "%s")   ; Write header to CSV file.
  write_table(filename, "a", alist, format)


end
