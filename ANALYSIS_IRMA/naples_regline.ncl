;********************************************************
; Plot storm stracks from wrfout files.
;********************************************************

load "/opt/ncl/6.4.0-precompiled/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "/opt/ncl/6.4.0-precompiled/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "/opt/ncl/6.4.0-precompiled/lib/ncarg/nclscripts/csm/contributed.ncl"
load "/opt/ncl/6.4.0-precompiled/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
load "/opt/ncl/6.4.0-precompiled/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"


begin

 fs = systemfunc("ls ../IRMA_DATA_FORCING/WRF/wrfout_d03*")
 nfs= dimsizes(fs)
;print(fs)
    f = addfiles(fs+".nc","r")
;print(f)
  ntimes = dimsizes(fs)         ; number of times in the file(s)

;  print("There are " +ntimes+ " times in this file")

loc = wrf_user_ij_to_ll(f, 521., 1026., True)
 print("lon/lat locations are: " + loc)
uu        = new((/ntimes/),float)
vv        = new((/ntimes/),float)
psfc      = new((/ntimes/),float)
maxspd    = new((/ntimes/),float)
meanspd    = new((/ntimes/),float)
wspd10max = new((/ntimes/),float)
i=0
do while (i.le.ntimes-1)
uu(i)    = f[i]->U(:,0,1026,521)   ; (time, lat,lon)    ; (2,64,128)
vv(i)    = f[i]->V(:,0,1026,521)        ; V10(:,29.301,-94.797) 
psfc(i)  = f[i]->PSFC(:,1026,521)
maxspd(i)  = f[i]->SPDUV10MAX(:,1026,521)
meanspd(i)  = f[i]->SPDUV10MEAN(:,1026,521)
wspd10max(i) = f[i]->WSPD10MAX(:,1026,521)
i = i + 1
end do
   model_wspd = sqrt(uu^2+vv^2) ;wind_speed(uu,vv)
   model_wdir = wind_direction(uu,vv,0)
   model_psfc = psfc/100.
   model_maxspd = maxspd 
   model_meanspd = meanspd
   model_wspd10max = wspd10max
print(model_maxspd + "  " + model_meanspd)


z1 = asciiread("./15MIN_8725110.txt",(/49,6/),"float")
obs_date = z1(0:48:1,0)
obs_time = z1(0:48:1,1)
obs_wspd = z1(0:48:1,2)
obs_wdir = z1(0:48:1,3)
obs_gust = z1(0:48:1,4)
obs_psfc = z1(0:48:1,5)

;print(obs_date + "  " + obs_wspd + "  " + model_wspd + "  " + model_wspd1)
print(obs_time + "  " +obs_wspd+ "  " + obs_gust)


;z2 = asciiread("./timeavg_8725110.txt",(/49,3/),"float")
;obs_timeavg_wspd = z2(:,1)
;obs_timeavg_gust = z2(:,2)


 filename = "naples_ready_15mincompare.csv"
  system("rm -rf " + filename)

dq = str_get_dq() 
fields = (/"DATE", "TIME", "OBS_WSPD", "OBS_WDIR", "OBS_GUST", "OBS_PSFC", "LES_WSPD", "LES_WSPD10MAX", "LES_WDIR", "LES_GUST", \
                    "LES_MEANWSPD","LES_PSFC"/)
 fields = dq + fields + dq                      ; Pre/append quotes to field names
  header = [/str_join(fields,",")/]              ; Header is field names separated


 alist  = [/obs_date,obs_time,obs_wspd,obs_wdir,obs_gust,obs_psfc,model_wspd,model_wspd10max, model_wdir,model_maxspd,model_meanspd,model_psfc/]
  format = "%7f,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g"
 write_table(filename, "w", header, "%s")   ; Write header to CSV file.
  write_table(filename, "a", alist, format)

end
