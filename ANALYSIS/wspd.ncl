;----------------------------------------------------------------------
; WRF_lc_4.ncl
;
; Concepts illustrated:
;   - Plotting WRF data that's on a Lambert Conformal map projection
;   - Using gsn_csm_contour_map to plot WRF-ARW data in its native projection
;   - Paneling plots on a page
;----------------------------------------------------------------------
; This script panels an individual variable from a WRF output file at 
; 6 hour time steps. You need to use a WRF output file that has multiple
; time steps, or else read data from a series of individual WRF output
; files.
;----------------------------------------------------------------------
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/opt/ncarg/6.2.0/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "/opt/ncarg/6.2.0/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "/opt/ncarg/6.2.0//lib/ncarg/nclscripts/csm/contributed.ncl"
load "/opt/ncarg/6.2.0/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
load "/opt/ncarg/6.2.0/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin
;
; Open file and read in data.
; (1) Read Q2 at all times: convert to g/kg
; (2) Read character variable Times; Convert to string for plots
;
  f1       = addfile ("./HWRFINPUT/met_em.d02.2017-09-10_21:00:00.nc","r")
  u = f1->UU(0,0,:,:)
  v = f1->VV(0,0,:,:)

 f50       = addfile ("./URMA_HWRINPUT/met_em.d02.2017-09-10_21:00:00.nc","r")
  u50 = f50->UU(0,0,:,:)
  v50 = f50->VV(0,0,:,:)

lon = f50->XLONG_M
lat = f50->XLAT_M

  wks = gsn_open_wks("png","compare_10_21UTC")

  res                       = True                 ; plot mods desired
;  res@gsnMaximize           = True                 ; maximize plot size
  res@cnFillOn              = True                 ; color plot desired
  res@cnFillPalette         = "BlAqGrYeOrReVi200"  ; select color map
  res@cnLinesOn             = False                ; turn off contour lines
  res@cnLineLabelsOn        = False                ; turn off contour labels

  res = wrf_map_resources(f1,res)
  res@gsnAddCyclic          = False                 ; regional data: not cyclic      
  res@tfDoNDCOverlay        = True                  ; native projection

;---For individual plots 
  res@gsnDraw               = False            ; do not draw 
  res@gsnFrame              = False            ; do not advance 'frame'
  res@lbLabelBarOn          = False            ; turn off individual lb's 
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

  res@mpDataBaseVersion    = "HighRes"
;
; Using a common label bar for panel requires that
; all plots should be set to the same interval.
; Use built in function to determine "nice" limits.
;
  mnmxint                   = nice_mnmxintvl( min(u), max(u), 10, False)
  res@cnLevelSelectionMode  = "ManualLevels"   
  res@cnMinLevelValF        = mnmxint(0)
  res@cnMaxLevelValF        = mnmxint(1)
  res@cnLevelSpacingF       = mnmxint(2)/2.    ; twice as many levels

  res@mpLimitMode = "LatLon"    ; Limit the map view.
  res@mpMinLonF   = min(lon)
  res@mpMaxLonF   = max(lon)
  res@mpMinLatF   = min(lat)
  res@mpMaxLatF   = max(lat)
  res@mpPerimOn   = True        ; Turn on map perimeter.

;---Allocate array to store plots: specify time step
  tstep                     = 6                ; time step to plot          
  plts = new (tstep, "graphic")          ; 1d array to hold plots

;---Loop over each forecast and create a plot with a unique left title
;  n = 0                                    ; counter
;  do nt=6,ntim-1,tstep                     ; plot every 6 hours 
;     res@gsnLeftString = times(nt)
  res@gsnLeftString = "HWRF Surface U Wind (m/s)"
  plts(0) = gsn_csm_contour_map(wks,u,res)
  res@gsnLeftString = "URMA Surface U Wind (m/s)"
  plts(1) = gsn_csm_contour_map(wks,u50,res)
  res@gsnLeftString = "HWRF Surface V Wind (m/s)"
  plts(2) = gsn_csm_contour_map(wks,v,res)
  res@gsnLeftString = "URMA Surface V Wind (m/s)"
  plts(3) = gsn_csm_contour_map(wks,v50,res)

;     n = n+1
;  end do

;---Create panel: panel plots have their own set of resources
  resP                    = True                   ; modify the panel plot
;  resP@gsnPanelMainString = "COMPARE HWRF VS URMA SURFACE WIND FIELDS (12 UTC) 09/10/2017"          ; Main title

  resP@gsnPanelLabelBar = True                   ; add common colorbar
  resP@lbLabelFontHeightF = 0.015 ; set font height of Label Bar labels
;  resP@gsnPanelBottom   = 0.3 ; shrink panel plot by setting bottom edge of plot
;  resP@gsnPanelTop      = 1.0 ; shrink panel plot by setting top edge of plot
  resP@gsnPanelYWhiteSpacePercent = 5.  ; increase spacing along Y-axis between panel plots
  gsn_panel(wks,plts,(/2,2/),resP)               ; now draw as one plot


end

