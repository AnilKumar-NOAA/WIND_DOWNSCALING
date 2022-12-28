; Wind and Pressure Mapping Program for NCL
; Version: 2.0
; Created by Jason W. Godwin (jgodwin@rsmas.miami.edu)
;
; Program description: This program creates three sets of plots, each containing
; a plot of 10-meter wind speeds, sea-level pressure (SLP), and wind vectors.
; The sets are of the full WRF domain, a user-specified regional zoom-in domain,
; and a zoom-in window that follows the center of the storm. This program assumes
; that each forecast is in a different wrfout file (i.e. each wrfout file contains
; only one history interval).
;
; Instructions: change the figure title by modifying the "fig_title" variable.
; Change the regional zoom-in window by changing the lats and lons arrays around
; lines 50-60ish
;----------------------------------------------------------------------------------

; load the necessary libraries
load "/apps/ncl/6.5.0-CentOS7.5_64bit_gnu485/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "/apps/ncl/6.5.0-CentOS7.5_64bit_gnu485/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "/apps/ncl/6.5.0-CentOS7.5_64bit_gnu485/lib/ncarg/nclscripts/csm/contributed.ncl"
load "/apps/ncl/6.5.0-CentOS7.5_64bit_gnu485/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
load "/apps/ncl/6.5.0-CentOS7.5_64bit_gnu485/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/apps/ncl/6.5.0-CentOS7.5_64bit_gnu485/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"


begin
;---Open WRF output file and read first timestep of HGT variable
  fname = addfile("../../WRFV3/run/met_em.d01.2018-10-10_17:00:00.nc","r")
;  fname = addfile("../../WRFV3/run/WRFOUT_6MIN/wrfout_d01_2018-10-10_17:00:00.nc","r")

  slp   = fname->PSFC 
 slp = slp/100.
  u10 = fname->UU
  v10 = fname->VV
  
f = addfile("../..//WRFV3/run/WRFOUT_6MIN/wrfout_d01_2018-10-10_17:00:00.nc","r")

;---Indicate where to send graphics
 wks = gsn_open_wks("png","hwrf_slp_17utc")

  res                       = True             ; plot mods desired
  res@gsnMaximize           = True             ; maximize plot size
  res@cnFillOn              = True             ; color plot desired
  res@cnFillPalette         = "BlAqGrYeOrReVi200" ; select color map
  res@cnLinesOn             = False            ; turn off contour lines
  res@cnLineLabelsOn        = False            ; turn off contour labels

  res = wrf_map_resources(f,res)
  res@gsnAddCyclic          = False       ; regional data: not cyclic 
  res@tfDoNDCOverlay        = True        ; set True for native mapping

;  res@tiMainString     = times(nt)
;  res@gsnLeftString    = x@description+"  z="+znu(nl)
res@mpOutlineBoundarySets = "AllBoundaries"
res@mpDataSetName         = "Earth..4"      ; Gives us provincial boundaries
res@mpGeophysicalLineColor       = "Black"
res@mpNationalLineColor          = "Black"
res@mpUSStateLineColor           = "Black"
res@mpGridLineColor              = "Black"
res@mpLimbLineColor              = "Black"
res@mpPerimLineColor             = "Black"
res@mpGeophysicalLineThicknessF  = 2.0
res@mpGridLineThicknessF         = 1.0
res@mpLimbLineThicknessF         = 2.0
res@mpNationalLineThicknessF     = 2.0
res@mpUSStateLineThicknessF      = 2.0
res@mpProvincialLineThicknessF  = 2.
res@mpProvincialLineColor       = "black"

res@mpDataBaseVersion    = "HighRes"

res@cnLevelSelectionMode  = "ExplicitLevels" ; explicit [unequal] cn levels
  res@cnLevels              = (/950,960,970,980,990,1000,1010,1020/)


  res@pmTickMarkDisplayMode = "Always"         ; turn on nicer tickmarks
  res@tmXBLabelFontHeightF  = 0.018
  res@tmYLLabelFontHeightF  = 0.018
  res@tmYLLabelStride       = 2                ; label every other tickmark
  res@tmXBLabelStride       = 2


  plot                 = gsn_csm_contour_map(wks,slp(0,:,:),res)



end
