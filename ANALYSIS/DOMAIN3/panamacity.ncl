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


fs = systemfunc("ls ../../WRFV3/run/WRFOUT_6MIN/wrfout_d03*")

f1 = addfiles(fs+".nc","r")
u10 = f1[:]->U10(:,1095,455)
v10 = f1[:]->V10(:,1095,455)
psfc = f1[:]->PSFC(:,1095,455)
gust = f1[:]->WSPD10MAX(:,1095,455)
print(gust)
;printVarSummary(u10)


   model_wspd = sqrt(u10^2+v10^2) ;wind_speed(uu,vv)
   model_wdir = wind_direction(u10,v10,0) 
   model_psfc = psfc/100.
   model_gust  = gust

z1 = asciiread("./pancity.txt",(/300,9/),"float")
obs_date = z1(:,0)
obs_time = z1(:,1)
obs_wspd = z1(:,2)*0.514
obs_wdir = z1(:,3)
obs_gust = z1(:,4)*0.514
obs_psfc = z1(:,6)

;print(obs_date + "  " + obs_wspd + "  " + model_wspd + "  " + model_wspd1)
 filename = "panamacity6min.csv"
  system("rm -rf " + filename)

dq = str_get_dq() 
fields = (/"DATE", "TIME", "OBS_GUST", "OBS_WSPD", "OBS_WDIR", "OBS_PSFC",\
                    "WRF_GUST","WRF_WSPD","WRF_WDIR","WRF_PSFC"/)
 fields = dq + fields + dq                      ; Pre/append quotes to field names
  header = [/str_join(fields,",")/]              ; Header is field names separated


 alist  = [/obs_date,obs_time,obs_gust,obs_wspd,obs_wdir,obs_psfc,model_gust,model_wspd,model_wdir,model_psfc/]
  format = "%7f,%g,%g,%g,%g,%g,%g,%g,%g,%g"
 write_table(filename, "w", header, "%s")   ; Write header to CSV file.
  write_table(filename, "a", alist, format)

end
