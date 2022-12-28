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

fs = systemfunc("ls ../../WRFV3/run/WRFOUT_6MIN/output_tyndall/wrfout_d02*")

f1 = addfiles(fs+".nc","r")
u10 = f1[:]->U10(:,705,785)
v10 = f1[:]->V10(:,705,785)
psfc = f1[:]->PSFC(:,705,785)
gust = f1[:]->WSPD10MAX(:,705,785)
;print(u10)
;printVarSummary(u10)

   hwrfles_wspd = sqrt(u10^2+v10^2) ;wind_speed(uu,vv)
   hwrfles_wdir = wind_direction(u10,v10,0)
   hwrfles_psfc = psfc/100.
   hwrfles_gust  = gust
 
   hwrfles_wspd1 = hwrfles_wspd(0:48)*2.23694
   hwrfles_wdir1 = hwrfles_wdir(0:48)
   hwrfles_psfc1 = hwrfles_psfc(0:48)
  hwrfles_gust1 = hwrfles_gust(0:48)*2.23694

print(hwrfles_gust1)
print("OK")


; READ HRRR WRF
fs1 = systemfunc("ls ../../../RUN/WRF/run/output_tyndall/wrfout_d02*")
 nfs1= dimsizes(fs1)
;print(fs)
    f2 = addfiles(fs1+".nc","r")
;print(f2)
  ntimes1 = 49 ;dimsizes(f2)         ; number of times in the file(s)
  
  print("There are " +ntimes1+ " times in this file")

loc1 = wrf_user_ij_to_ll(f1, 785., 705., True)
 print("lon/lat locations are: " + loc1)
uu1      = new((/ntimes1/),float)
vv1      = new((/ntimes1/),float)
psfc1      = new((/ntimes1/),float)
gust1   =  new((/ntimes1/),float)

i1=0
do while (i1.le.ntimes1-1)
uu1(i1)    = f2[i1]->U10(:,705,785)   ; (time, lat,lon)    ; (2,64,128)
vv1(i1)    = f2[i1]->V10(:,705,785)        ; V10(:,29.301,-94.797)
psfc1(i1)  = f2[i1]->PSFC(:,705,785)
gust1(i1)  = f2[i1]->WSPD10MAX(:,705,785)

i1 = i1 + 1
end do

   hrrrles_wspd = sqrt(uu1^2+vv1^2) ;wind_speed(uu,vv)
   hrrrles_wdir = wind_direction(uu1,vv1,0)
   hrrrles_psfc = psfc1/100.
   hrrrles_gust = gust1
   

   hrrrles_wspd = hrrrles_wspd*2.23694
   hrrrles_gust = hrrrles_gust*2.23694
print(hrrrles_gust)
print("OK LEVEL2")


; READ OBS

z1 = asciiread("./tyndall_station.txt",(/49,6/),"float")
obs_date = z1(:,0)
obs_time = z1(:,1)
obs_wspd = z1(:,2)
obs_wdir = z1(:,3)
obs_gust = z1(:,4)
obs_psfc = z1(:,5)*33.86389

print(obs_gust)

print("OK")

;print(obs_date + "  " + obs_wspd + "  " + model_wspd + "  " + model_wspd1)
 filename = "new_tyndall_6min.csv"
  system("rm -rf " + filename)

dq = str_get_dq()
fields = (/"DATE", "TIME", "OBS_GUST", "OBS_WSPD", "OBS_WDIR", "OBS_PSFC",\
                    "HWRFLES_GUST","HWRFLES_WSPD","HWRFLES_WDIR","HWRFLES_PSFC",\
                    "HRRRLES_GUST","HRRRLES_WSPD","HRRRLES_WDIR","HRRRLES_PSFC"/)

 fields = dq + fields + dq                      ; Pre/append quotes to field names
  header = [/str_join(fields,",")/]              ; Header is field names separated


 alist  = [/obs_date,obs_time,obs_gust,obs_wspd,obs_wdir,obs_psfc,hwrfles_gust1,hwrfles_wspd1,hwrfles_wdir1,hwrfles_psfc1,hrrrles_gust,hrrrles_wspd,hrrrles_wdir,hrrrles_psfc/]
  format = "%7f,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g"
 write_table(filename, "w", header, "%s")   ; Write header to CSV file.
  write_table(filename, "a", alist, format)



end

