;----------------------------------------------------------------------
; wrf_title_4.ncl
;----------------------------------------------------------------------
; Concepts illustrated:
;   - Customizing or turning off titles in plots created by wrf_xxxx functions
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.4.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/apps/ncl/6.5.0-CentOS7.5_64bit_gnu485/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "/apps/ncl/6.5.0-CentOS7.5_64bit_gnu485/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "/apps/ncl/6.5.0-CentOS7.5_64bit_gnu485/lib/ncarg/nclscripts/csm/contributed.ncl"
load "/apps/ncl/6.5.0-CentOS7.5_64bit_gnu485/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
load "/apps/ncl/6.5.0-CentOS7.5_64bit_gnu485/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/apps/ncl/6.5.0-CentOS7.5_64bit_gnu485/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"


begin
;---Open WRF output file and read first timestep of HGT variable
;  fname = "wrfout_d01_2003-07-15_00:00:00"
a = addfile("/scratch2/COASTAL/coastal/save/Anil.Kumar/HURRICANE_MICHAEL/WRFV3/run/wrfout_d01_2018-10-10_17:00:00.nc","r")

  slp   = wrf_user_getvar(a,"PSFC",0)

;---Indicate where to send graphics
  wks = gsn_open_wks("png","les_psfc_17utc")

;---Default plot with footer turn off
  res           = True
  res@cnFillOn  = True
  res@Footer    = False                  ; Turn off footer strings


;---Change the title at top left of plot
  res@FieldTitle = "SEA LEVEL PRESSURE"    ; Change variable description
  res@UnitLabel  = "mb"                    ; Change variable units
  res@lbTitleOn  = False                   ; Turn off title on labelbar
  
  res@mpOutlineBoundarySets = "AllBoundaries"
  res@mpDataSetName         = "Earth..4"      ; Gives us provincial boundaries
  res@mpGeophysicalLineThicknessF = 1.5       ; thickness of map outlines
  res@mpProvincialLineThicknessF  = 2.
  res@mpProvincialLineColor       = "black" 

  contour = wrf_contour(a,wks,slp,res)

 mpres                             = True
  mpres@mpGeophysicalLineColor      = "Black"
  mpres@mpNationalLineColor         = "Black"
  mpres@mpUSStateLineColor          = "Black"
  mpres@mpGridLineColor             = "Black"
  mpres@mpLimbLineColor             = "Black"
  mpres@mpPerimLineColor            = "Black"
  mpres@mpGeophysicalLineThicknessF = 1.0
  mpres@mpGridLineThicknessF        = 1.0
  mpres@mpLimbLineThicknessF        = 1.0
  mpres@mpNationalLineThicknessF    = 0.5
  mpres@mpUSStateLineThicknessF     = 0.5
  mpres@mpDataResolution            = "FinestResolution"

;---------------------
; Overlay contours on map
;---------------------
  pltres = True
pltres@NoTitles = True
pltres@NoHeaderFooter = True
pltres@InitTime = False

  plot    = wrf_map_overlays(a,wks,contour,pltres,mpres)



end
