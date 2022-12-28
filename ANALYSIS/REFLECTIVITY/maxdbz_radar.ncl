;   Example script to produce dbz plots for a WRF real-data run,
;   with the ARW coordinate dynamics option.
;   November 2008
load "/apps/ncl/6.5.0-CentOS7.5_64bit_gnu485/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "/apps/ncl/6.5.0-CentOS7.5_64bit_gnu485/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "/apps/ncl/6.5.0-CentOS7.5_64bit_gnu485/lib/ncarg/nclscripts/csm/contributed.ncl"
load "/apps/ncl/6.5.0-CentOS7.5_64bit_gnu485/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
load "/apps/ncl/6.5.0-CentOS7.5_64bit_gnu485/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/apps/ncl/6.5.0-CentOS7.5_64bit_gnu485/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"


begin
;
; The WRF ARW input file.  
; This needs to have a ".nc" appended, so just do it.
a = addfile("/scratch2/COASTAL/coastal/save/Anil.Kumar/HURRICANE_MICHAEL/WRFV3/run/wrfout_d01_2018-10-10_17:00:00.nc","r")

;a = addfile("/scratch2/COASTAL/coastal/save/Anil.Kumar/HURRICANE_MICHAEL/WRFOUT_1/wrfout_d01_2018-10-10_18:00:00.nc","r")
 times = wrf_user_list_times(a)
print(times)

; We generate plots, but what kind do we prefer?
;  type = "x11"
; type = "pdf"
 type = "ps"
; type = "ncgm"
  wks = gsn_open_wks(type,"MAXREF_DO1_10_17UTC_LONG")
  gsn_define_colormap(wks,"prcp_1")
 mdbz = wrf_user_getvar(a,"mdbz",0)
     dbz = wrf_user_getvar(a,"dbz",0)

;   mdbz = wrf_user_getvar(a,(/"mdbz","1","1"/),it) 
 ;    dbz = wrf_user_getvar(a,(/"dbz","1","1"/),it) 
;---Set some common resources
  res                       = True


 pltres = True
  mpres = True
mpres@mpGeophysicalLineColor       = "Black"
mpres@mpNationalLineColor          = "Black"
mpres@mpUSStateLineColor           = "Black"
mpres@mpGridLineColor              = "Black"
mpres@mpLimbLineColor              = "Black"
mpres@mpPerimLineColor             = "Black"
mpres@mpGeophysicalLineThicknessF  = 2.0
mpres@mpGridLineThicknessF         = 1.0
mpres@mpLimbLineThicknessF         = 2.0
mpres@mpNationalLineThicknessF     = 2.0
mpres@mpUSStateLineThicknessF      = 2.0

mpres@mpDataBaseVersion    = "HighRes"

;---Copy common resources for dbz plot

     opts = res                         
     opts@cnFillOn = True  
     opts@ContourParameters = (/ 5., 70., 5./)
;     contour = wrf_contour(a,wks,dbz(0,1,:,:),opts)    ; plot only lowest level
;     plot = wrf_map_overlays(a,wks,(/contour/),pltres,mpres)
 
     contour = wrf_contour(a,wks,mdbz,opts)
     plot = wrf_map_overlays(a,wks,(/contour/),pltres,mpres)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
end
