;********************************************************
; Plot storm stracks from wrfout files.
;********************************************************

load "/opt/ncarg/6.2.0/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "/opt/ncarg/6.2.0/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "/opt/ncarg/6.2.0//lib/ncarg/nclscripts/csm/contributed.ncl"
load "/opt/ncarg/6.2.0/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
load "/opt/ncarg/6.2.0/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"


begin
 fs = systemfunc("ls ./WRFOUT/WRF_DEFAULT/wrfout_d03*")
 nfs= dimsizes(fs)
;print(fs)
    f = addfiles(fs+".nc","r")
;print(f)
times  = wrf_user_list_times(f)  ; get times in the file
  ntimes = dimsizes(times)         ; number of times in the file(s)

;  print("There are " +ntimes+ " times in this file")

loc = wrf_user_ij_to_ll(f, 190., 253., True)
 print("lon/lat locations are: " + loc)
uu      = new((/ntimes/),float)
vv      = new((/ntimes/),float)
psfc      = new((/ntimes/),float)
i=0
do while (i.le.ntimes-1)
uu(i)    = f[i]->U10(:,253,190)   ; (time, lat,lon)    ; (2,64,128)
vv(i)    = f[i]->V10(:,253,190)        ; V10(:,29.301,-94.797) 
psfc(i)  = f[i]->PSFC(:,253,190)
i = i + 1
end do
   model_wspd = sqrt(uu^2+vv^2) ;wind_speed(uu,vv)
   model_psfc = psfc/100.

fs1 = systemfunc("ls ./WRFOUT/WRF_HIRES/wrfout_d02*")
 nfs1= dimsizes(fs1)
;print(fs)
    f1 = addfiles(fs1+".nc","r")
;print(f)
times1  = wrf_user_list_times(f1)  ; get times in the file
  ntimes1 = dimsizes(times1)         ; number of times in the file(s)

;  print("There are " +ntimes+ " times in this file")

loc1 = wrf_user_ij_to_ll(f1, 892., 293., True)
 print("lon/lat locations are: " + loc)
uu1      = new((/ntimes1/),float)
vv1      = new((/ntimes1/),float)
psfc1      = new((/ntimes1/),float)
i1=0
do while (i1.le.ntimes1-1)
uu1(i1)    = f1[i1]->U10(:,293,892)   ; (time, lat,lon)    ; (2,64,128)
vv1(i1)    = f1[i1]->V10(:,293,892)        ; V10(:,29.301,-94.797)
psfc1(i1)  = f1[i1]->PSFC(:,293,892)
i1 = i1 + 1
end do
   model_wspd1 = sqrt(uu1^2+vv1^2) ;wind_speed(uu,vv)
   model_psfc1 = psfc1/100.

z1 = asciiread("./Gal_pleasure_piers.csv",(/111,6/),"float")
obs_date = z1(0:110:10,0)
obs_time = z1(0:110:10,1)
obs_wspd = z1(0:110:10,3)
obs_psfc = z1(0:110:10,5)

print(obs_date + "  " + obs_psfc)

 filename = "gal_piers_ready.csv"
  system("rm -rf " + filename)

dq = str_get_dq() 
fields = (/"DATE_GP", "TIME_GP", "OBS_WIND_GP", "OBS_PSFC_GP", "MODEL1KM_WIND_GP", "MODEL1KM_PSFC_GP", "MODEL40M_WIND_GP", "MODEL40M_PSFC_GP"/)
 fields = dq + fields + dq                      ; Pre/append quotes to field names
  header = [/str_join(fields,",")/]              ; Header is field names separated


 alist  = [/obs_date,obs_time,obs_wspd,obs_psfc,model_wspd,model_psfc,model_wspd1,model_psfc1/]
  format = "%7f,%g,%g,%g,%g,%g,%g,%g,%g"
 write_table(filename, "w", header, "%s")   ; Write header to CSV file.
  write_table(filename, "a", alist, format)





end
