;********************************************************
; Plot storm stracks from wrfout files.
;********************************************************

load "/opt/ncl/6.4.0-precompiled/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "/opt/ncl/6.4.0-precompiled/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "/opt/ncl/6.4.0-precompiled/lib/ncarg/nclscripts/csm/contributed.ncl"
load "/opt/ncl/6.4.0-precompiled/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
load "/opt/ncl/6.4.0-precompiled/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"


begin

; wrf output reader for particular station location
 
fs1 = systemfunc("ls ../IRMA_DATA_FORCING/WRF/temp/wrfout_d02*")
 nfs1= dimsizes(fs1)
;print(fs)
    f1 = addfiles(fs1+".nc","r")
print(f1)
  ntimes1 = dimsizes(fs1)         ; number of times in the file(s)

  print("There are " +ntimes1+ " times in this file")

loc1 = wrf_user_ij_to_ll(f1, 325., 985., True)
 print("lon/lat locations are: " + loc1)
uu1      = new((/ntimes1/),float)
vv1      = new((/ntimes1/),float)
maxspd1    = new((/ntimes1/),float)
meanspd1    = new((/ntimes1/),float)
psfc1      = new((/ntimes1/),float)
i1=0
do while (i1.le.ntimes1-1)
uu1(i1)    = f1[i1]->U10(:,985,325)   ; (time, lat,lon)    ; (2,64,128)
vv1(i1)    = f1[i1]->V10(:,985,325)        ; V10(:,29.301,-94.797)
maxspd1(i1)    = f1[i1]->SPDUV10MAX(:,985,325)  
meanspd1(i1)    = f1[i1]->SPDUV10MEAN(:,985,325) 
psfc1(i1)  = f1[i1]->PSFC(:,985,325)

i1 = i1 + 1
end do
   model_wspd1 = sqrt(uu1^2+vv1^2) ;wind_speed(uu,vv)
   model_gust1 = maxspd1    ;  sqrt(uu1^2+vv1^2) ;wind_speed(uu,vv)
   model_wdir1 = wind_direction(uu1,vv1,0)
   model_psfc1 = psfc1/100.
   model_meanspd1 = meanspd1


;print (model_meanspd1 + "  " + model_wspd1 + "  "  + model_gust1 + "  " + model_wdir1 + "  " + model_psfc1 )


z1 = asciiread("./8725110.txt",(/241,6/),"float")
obs_date = z1(0:240:5,0)
obs_time = z1(0:240:5,1)


z2 = asciiread("./Big_carlos_pass_data.txt",(/241,3/),"float")
obs_wspd = z2(0:240:5,1)
obs_wdir = z2(0:240:5,0)
obs_psfc = z2(0:240:5,2)

;print(obs_date + "  " + obs_wspd + "  " + model_wspd + "  " + model_wspd1)
print(obs_time+ "  " + obs_psfc)




 filename = "bigcarlos_ready.csv"
  system("rm -rf " + filename)

dq = str_get_dq() 
fields = (/"DATE", "TIME", "OBS_WSPD", "OBS_WDIR", "OBS_PSFC", "LES_WSPD", "LES_WDIR", "LES_GUST", \
                    "LES_MEANSPD","LES_PSFC"/)
 fields = dq + fields + dq                      ; Pre/append quotes to field names
  header = [/str_join(fields,",")/]              ; Header is field names separated


 alist  = [/obs_date,obs_time,obs_wspd,obs_wdir,obs_psfc,model_wspd1,model_wdir1,model_gust1,model_meanspd1,model_psfc1/]
  format = "%7f,%g,%g,%g,%g,%g,%g,%g,%g,%g"
 write_table(filename, "w", header, "%s")   ; Write header to CSV file.
  write_table(filename, "a", alist, format)


end
