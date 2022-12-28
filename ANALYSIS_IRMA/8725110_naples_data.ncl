;********************************************************
; Plot storm stracks from wrfout files.
;********************************************************

load "/opt/ncl/6.4.0-precompiled/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "/opt/ncl/6.4.0-precompiled/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "/opt/ncl/6.4.0-precompiled/lib/ncarg/nclscripts/csm/contributed.ncl"
load "/opt/ncl/6.4.0-precompiled/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
load "/opt/ncl/6.4.0-precompiled/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"


begin
/;
 fs = systemfunc("ls ./HWRFINPUT/met_em.d02*")
 nfs= dimsizes(fs)
;print(fs)
    f = addfiles(fs+".nc","r")
;print(f)
  ntimes = 31 ;dimsizes(f)         ; number of times in the file(s)

;  print("There are " +ntimes+ " times in this file")

loc = wrf_user_ij_to_ll(f, 641., 1052., True)
 print("lon/lat locations are: " + loc)
uu      = new((/ntimes/),float)
vv      = new((/ntimes/),float)
psfc      = new((/ntimes/),float)
i=0
do while (i.le.ntimes-1)
uu(i)    = f[i]->UU(:,0,1052,641)   ; (time, lat,lon)    ; (2,64,128)
vv(i)    = f[i]->VV(:,0,1052,641)        ; V10(:,29.301,-94.797) 
psfc(i)  = f[i]->PSFC(:,1052,641)
i = i + 1
end do
   model_wspd = sqrt(uu^2+vv^2) ;wind_speed(uu,vv)
   model_wdir = wind_direction(uu,vv,0)
   model_psfc = psfc/100.


fs1 = systemfunc("ls ./URMA_HWRINPUT/met_em.d02*")
 nfs1= dimsizes(fs1)
;print(fs)
    f1 = addfiles(fs1+".nc","r")
;print(f)
  ntimes1 = 31 ; dimsizes(f1)         ; number of times in the file(s)

;  print("There are " +ntimes+ " times in this file")

loc1 = wrf_user_ij_to_ll(f1, 641., 1052., True)
 print("lon/lat locations are: " + loc)
uu1      = new((/ntimes1/),float)
vv1      = new((/ntimes1/),float)
psfc1      = new((/ntimes1/),float)
i1=0
do while (i1.le.ntimes1-1)
uu1(i1)    = f1[i1]->UU(:,0,1052,641)   ; (time, lat,lon)    ; (2,64,128)
vv1(i1)    = f1[i1]->VV(:,0,1052,641)        ; V10(:,29.301,-94.797)
psfc1(i1)  = f1[i1]->PSFC(:,1052,641)
i1 = i1 + 1
end do
   model_wspd1 = sqrt(uu1^2+vv1^2) ;wind_speed(uu,vv)
   model_wdir1 = wind_direction(uu1,vv1,0) 
   model_psfc1 = psfc1/100.
print(ntimes + " " + ntimes1)

;/

; wrf output reader for particular station location
 
fs1 = systemfunc("ls ../IRMA_DATA_FORCING/WRF/temp/wrfout_d02*")
 nfs1= dimsizes(fs1)
;print(fs)
    f1 = addfiles(fs1+".nc","r")
print(f1)
  ntimes1 = dimsizes(fs1)         ; number of times in the file(s)

  print("There are " +ntimes1+ " times in this file")

loc1 = wrf_user_ij_to_ll(f1, 405., 681., True)
 print("lon/lat locations are: " + loc1)
uu1      = new((/ntimes1/),float)
vv1      = new((/ntimes1/),float)
maxspd1    = new((/ntimes1/),float)
meanspd1    = new((/ntimes1/),float)
psfc1      = new((/ntimes1/),float)
i1=0
do while (i1.le.ntimes1-1)
uu1(i1)    = f1[i1]->U10(:,681,405)   ; (time, lat,lon)    ; (2,64,128)
vv1(i1)    = f1[i1]->V10(:,681,405)        ; V10(:,29.301,-94.797)
maxspd1(i1)    = f1[i1]->SPDUV10MAX(:,681,405)  
meanspd1(i1)    = f1[i1]->SPDUV10MEAN(:,681,405) 
psfc1(i1)  = f1[i1]->PSFC(:,681,405)

i1 = i1 + 1
end do
   model_wspd1 = sqrt(uu1^2+vv1^2) ;wind_speed(uu,vv)
   model_gust1 = maxspd1    ;  sqrt(uu1^2+vv1^2) ;wind_speed(uu,vv)
   model_wdir1 = wind_direction(uu1,vv1,0)
   model_psfc1 = psfc1/100.
   model_meanspd1 = meanspd1


print (model_meanspd1 + "  " + model_wspd1 + "  "  + model_gust1 + "  " + model_wdir1 + "  " + model_psfc1 )




z1 = asciiread("./8725110.txt",(/242,6/),"float")
obs_date = z1(0:241:5,0)
obs_time = z1(0:241:5,1)
obs_wspd = z1(0:241:5,2)
obs_wdir = z1(0:241:5,3)
obs_gust = z1(0:241:5,4)
obs_psfc = z1(0:241:5,5)

;print(obs_date + "  " + obs_wspd + "  " + model_wspd + "  " + model_wspd1)
;print(obs_time + "  " +obs_wspd+ "  " + obs_gust)


z2 = asciiread("./timeavg_8725110.txt",(/49,3/),"float")
obs_timeavg_wspd = z2(:,1)
obs_timeavg_gust = z2(:,2)


 filename = "naples_ready.csv"
  system("rm -rf " + filename)

dq = str_get_dq() 
fields = (/"DATE", "TIME", "OBS_WSPD", "OBS_WDIR", "OBS_GUST", "OBS_PSFC", "LES_WSPD", "LES_WDIR", "LES_GUST", \
                    "LES_MEANSPD","LES_PSFC","OBS_TIMEAVG_WSPD","OBS_TIMEAVG_GUST"/)
 fields = dq + fields + dq                      ; Pre/append quotes to field names
  header = [/str_join(fields,",")/]              ; Header is field names separated


 alist  = [/obs_date,obs_time,obs_wspd,obs_wdir,obs_gust,obs_psfc,model_wspd1,model_wdir1,model_gust1,model_meanspd1,model_psfc1,obs_timeavg_wspd,obs_timeavg_gust/]
  format = "%7f,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g,%g"
 write_table(filename, "w", header, "%s")   ; Write header to CSV file.
  write_table(filename, "a", alist, format)


end
