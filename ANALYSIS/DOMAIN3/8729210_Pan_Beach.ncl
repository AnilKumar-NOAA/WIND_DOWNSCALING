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

z2 = asciiread("./pbc_v10.txt",(/301,2/),"float")
model_date = z2(:,0)
v10 = z2(:,1)


z3 = asciiread("./pbc_u10.txt",(/301,2/),"float")
u10 = z3(:,1)


z4 = asciiread("./pbc_psfc.txt",(/301,2/),"float")
psfc = z4(:,1)


z5 = asciiread("./pbc_gust.txt",(/301,2/),"float")
gust = z5(:,1)



   model_wspd = sqrt(u10^2+v10^2) ;wind_speed(uu,vv)
   model_wdir = wind_direction(u10,v10,0) 
   model_psfc = psfc/100.
   model_gust  = gust

z1 = asciiread("./6min_data.txt",(/301,9/),"float")
obs_date = z1(:,0)
obs_time = z1(:,1)
obs_wspd = z1(:,2)*0.514
obs_wdir = z1(:,3)
obs_gust = z1(:,4)*0.514
obs_psfc = z1(:,6)

;print(obs_date + "  " + obs_wspd + "  " + model_wspd + "  " + model_wspd1)
 filename = "pbc_6min.csv"
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
