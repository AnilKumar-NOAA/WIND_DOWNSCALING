;********************************************************
; Plot storm stracks from wrfout files.
;********************************************************

load "/opt/ncarg/6.2.0/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "/opt/ncarg/6.2.0/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "/opt/ncarg/6.2.0//lib/ncarg/nclscripts/csm/contributed.ncl"
load "/opt/ncarg/6.2.0/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
load "/opt/ncarg/6.2.0/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"


begin
 fs = systemfunc("ls ../WRF_HWRFHOURLY_DEFAULT/wrfout_d03*")
 nfs= dimsizes(fs)
;print(fs)
    f = addfiles(fs+".nc","r")
;print(f)
times  = wrf_user_list_times(f)  ; get times in the file
  ntimes = dimsizes(times)         ; number of times in the file(s)
print(ntimes)

print("OK BEFORE")
psfc_0  = f[0]->PSFC(0,:,:)
 psfc_0 = dim_avg(psfc_0)


   model_psfc_0 = psfc_0/100.
print(model_psfc_0)


fs1 = systemfunc("ls ../WRF_INUNDATION_TIMEVARYING/wrfout_d03*")
 nfs1= dimsizes(fs1)
;print(fs)
    f1 = addfiles(fs1+".nc","r")
;print(f)
psfc1      = new((/ntimes1/),float)
i1=0
do while (i1.le.ntimes1-1)
psfc1(i1)  = f1[i1]->PSFC(:,517,1087)
i1 = i1 + 1
end do
   model_psfc1 = psfc1/100.

 filename = "domain3_avg_psfc.csv"
  system("rm -rf " + filename)

dq = str_get_dq() 
fields = (/"TIME","DEFAULT_PSFC","TVINUN_PSFC"/)
 fields = dq + fields + dq                      ; Pre/append quotes to field names
  header = [/str_join(fields,",")/]              ; Header is field names separated

 alist  = [/Time_2,model_psfc,model_psfc1/]
  format = "%7f,%g,%g,%g"
 write_table(filename, "w", header, "%s")   ; Write header to CSV file.
  write_table(filename, "a", alist, format)

end
