;********************************************************
; Plot storm stracks from wrfout files.
;********************************************************

load "/opt/ncarg/6.2.0/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "/opt/ncarg/6.2.0/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "/opt/ncarg/6.2.0//lib/ncarg/nclscripts/csm/contributed.ncl"
load "/opt/ncarg/6.2.0/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
load "/opt/ncarg/6.2.0/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"


begin
 fs = systemfunc("ls ../WRF_HWRFHOURLY_DEFAULT/wrfout_d03*0:00*")
 nfs= dimsizes(fs)
;print(fs)
    f = addfiles(fs+".nc","r")
;print(f)
times  = wrf_user_list_times(f)  ; get times in the file
  ntimes = dimsizes(times)         ; number of times in the file(s)

;  print("There are " +ntimes+ " times in this file")

loc = wrf_user_ij_to_ll(f, 739., 106., True)
 print("lon/lat locations are: " + loc)
uu      = new((/ntimes/),float)
vv      = new((/ntimes/),float)
psfc      = new((/ntimes/),float)
maxspd      = new((/ntimes/),float)
meanspd      = new((/ntimes/),float)
i=0
do while (i.le.ntimes-1)
uu(i)    = f[i]->U10(:,106,739)   ; (time, lat,lon)    ; (2,64,128)
vv(i)    = f[i]->V10(:,106,739)        ; V10(:,29.301,-94.797) 
psfc(i)  = f[i]->PSFC(:,106,739)
maxspd(i)= f[i]->SPDUV10MAX(:,106,739)
meanspd(i)= f[i]->SPDUV10MEAN(:,106,739)
i = i + 1
end do
   model_wspd = sqrt(uu^2+vv^2) ;wind_speed(uu,vv)
   model_psfc = psfc/100.
   model_maxspd = maxspd
   model_meanspd = meanspd
fs1 = systemfunc("ls ../WRF_INUNDATION_TIMEVARYING/wrfout_d03*0:00*")
 nfs1= dimsizes(fs1)
;print(fs)
    f1 = addfiles(fs1+".nc","r")
;print(f)
times1  = wrf_user_list_times(f1)  ; get times in the file
  ntimes1 = dimsizes(times1)         ; number of times in the file(s)

;  print("There are " +ntimes+ " times in this file")

loc1 = wrf_user_ij_to_ll(f1, 739., 106., True)
 print("lon/lat locations are: " + loc)
uu1      = new((/ntimes1/),float)
vv1      = new((/ntimes1/),float)
psfc1      = new((/ntimes1/),float)
maxspd1      = new((/ntimes/),float)
meanspd1      = new((/ntimes/),float)
i1=0
do while (i1.le.ntimes1-1)
uu1(i1)    = f1[i1]->U10(:,106,739)   ; (time, lat,lon)    ; (2,64,128)
vv1(i1)    = f1[i1]->V10(:,106,739)        ; V10(:,29.301,-94.797)
psfc1(i1)  = f1[i1]->PSFC(:,106,739)
maxspd1(i1)= f1[i1]->SPDUV10MAX(:,106,739)
meanspd1(i1)= f1[i1]->SPDUV10MEAN(:,106,739)
i1 = i1 + 1
end do
   model_wspd1 = sqrt(uu1^2+vv1^2) ;wind_speed(uu,vv)
   model_psfc1 = psfc1/100.
   model_maxspd1 = maxspd1
   model_meanspd1 = meanspd1

z1 = asciiread("./Gal_pleasure_piers.csv",(/121,6/),"float")

obs_date = z1(0:120:5,0)
obs_time = z1(0:120:5,1)
obs_wspd = z1(0:120:5,3)
obs_maxspd=z1(0:120:5,4)
obs_psfc = z1(0:120:5,5)

print(obs_date + "  " + obs_psfc)

 filename = "gal_21_ready.csv"
  system("rm -rf " + filename)

dq = str_get_dq() 
fields = (/"DATE_EP", "TIME_EP", "OBS_WSPD_EP", "OBS_MAXSPD_EP", "OBS_PSFC_EP","DEFAULT_WSPD_EP","DEFAULT_MAXSPD_EP", \
                    "DEFAULT_PSFC_EP","INUND_WSPD_EP","INUND_MAXSPD_EP","INUND_PSFC_EP","DEFAULT_MEANSPD","INUND_MEANSPD"/)
 fields = dq + fields + dq                      ; Pre/append quotes to field names
  header = [/str_join(fields,",")/]              ; Header is field names separated


 alist  = [/obs_date,obs_time,obs_wspd,obs_maxspd,obs_psfc,model_wspd,model_maxspd,model_psfc,model_wspd1,model_maxspd1,model_psfc1,model_meanspd,model_meanspd1/]
  format = "%7f,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g"
 write_table(filename, "w", header, "%s")   ; Write header to CSV file.
  write_table(filename, "a", alist, format)





end
