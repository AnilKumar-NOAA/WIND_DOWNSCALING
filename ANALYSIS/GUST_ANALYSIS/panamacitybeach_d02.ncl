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
print("START")

fs = systemfunc("ls ../../WRFV3/run/WRFOUT_6MIN/wrfout_d02*")

f1 = addfiles(fs+".nc","r")
u10 = f1[:]->U10(:,813,558)
v10 = f1[:]->V10(:,813,558)
psfc = f1[:]->PSFC(:,813,558)
gust = f1[:]->WSPD10MAX(:,813,558)
;print(u10)
;printVarSummary(u10)

   hwrfles_wspd = sqrt(u10^2+v10^2) ;wind_speed(uu,vv)
   hwrfles_wdir = wind_direction(u10,v10,0)
   hwrfles_psfc = psfc/100.
   hwrfles_gust  = gust


; READ HRRR WRF
fs1 = systemfunc("ls ../../../RUN/WRF/run/wrfout_d02*")
 nfs1= dimsizes(fs1)
;print(fs)
    f2 = addfiles(fs1+".nc","r")
;print(f2)
  ntimes1 = 260 ;dimsizes(f2)         ; number of times in the file(s)
  
  print("There are " +ntimes1+ " times in this file")

loc1 = wrf_user_ij_to_ll(f1, 558., 813., True)
 print("lon/lat locations are: " + loc1)
uu1      = new((/ntimes1/),float)
vv1      = new((/ntimes1/),float)
psfc1      = new((/ntimes1/),float)
gust1   =  new((/ntimes1/),float)

i1=0
do while (i1.le.ntimes1-1)
uu1(i1)    = f2[i1]->U10(:,813,558)   ; (time, lat,lon)    ; (2,64,128)
vv1(i1)    = f2[i1]->V10(:,813,558)        ; V10(:,29.301,-94.797)
psfc1(i1)  = f2[i1]->PSFC(:,813,558)
gust1(i1)  = f2[i1]->WSPD10MAX(:,813,558)

i1 = i1 + 1
end do

   hrrrles_wspd = sqrt(uu1^2+vv1^2) ;wind_speed(uu,vv)
   hrrrles_wdir = wind_direction(uu1,vv1,0)
   hrrrles_psfc = psfc1/100.
   hrrrles_gust = gust1


; READ OBS

z1 = asciiread("./pcb_6min.txt",(/260,9/),"float")
obs_date = z1(:,0)
obs_time = z1(:,1)
obs_wspd = z1(:,2)*0.514
obs_wdir = z1(:,3)
obs_gust = z1(:,4)*0.514
obs_psfc = z1(:,6)

print(dimsizes(hwrfles_gust))
print(dimsizes(hrrrles_gust))
print(dimsizes(obs_gust))

print("OK")

;print(obs_date + "  " + obs_wspd + "  " + model_wspd + "  " + model_wspd1)
 filename = "new_pbc_6min.csv"
  system("rm -rf " + filename)

dq = str_get_dq()
fields = (/"DATE", "TIME", "OBS_GUST", "OBS_WSPD", "OBS_WDIR", "OBS_PSFC",\
                    "HWRFLES_GUST","HWRFLES_WSPD","HWRFLES_WDIR","HWRFLES_PSFC",\
                    "HRRRLES_GUST","HRRRLES_WSPD","HRRRLES_WDIR","HRRRLES_PSFC"/)

 fields = dq + fields + dq                      ; Pre/append quotes to field names
  header = [/str_join(fields,",")/]              ; Header is field names separated


 alist  = [/obs_date,obs_time,obs_gust,obs_wspd,obs_wdir,obs_psfc,hwrfles_gust,hwrfles_wspd,hwrfles_wdir,hwrfles_psfc,hrrrles_gust,hrrrles_wspd,hrrrles_wdir,hrrrles_psfc/]
  format = "%7f,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g"
 write_table(filename, "w", header, "%s")   ; Write header to CSV file.
  write_table(filename, "a", alist, format)



end

