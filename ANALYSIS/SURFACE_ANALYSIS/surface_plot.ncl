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

  filename = "../../WRFV3/run/WRFOUT_6MIN/wrfout_d01_2018-10-10_17:00:00"
  a        = addfile(filename,"r")

;---Read several WRF variables at first time step
  it  = 0
  slp = wrf_user_getvar(a,"slp",it)   ; sea level pressure
  wrf_smooth_2d( slp, 3 )             ; smooth slp
  tc  = wrf_user_getvar(a,"tc",it)    ; 3D temperature
  u   = wrf_user_getvar(a,"ua",it)    ; 3D U at mass points
  v   = wrf_user_getvar(a,"va",it)    ; 3D V at mass points

;---Now get the lowest (bottommost) level
  nl  = 0
  tc2 = tc(nl,:,:)
  u10 = u(nl,:,:)
  v10 = v(nl,:,:)
  tf2 = 1.8*tc2+32.                    ; Convert temperature to Fahrenheit
  u10 = u10*1.94386                    ; Convert wind into knots
  v10 = v10*1.94386

;---Change the metadata
  tf2@description = "Surface Temperature"
  tf2@units       = "degF"
  u10@units       = "kts"
  v10@units       = "kts"

  wks = gsn_open_wks("png","wrf_gsn")

;---Set common resources for all plots
  res                = True
  res@gsnFrame       = False
  res@gsnDraw        = False
  res@gsnLeftString  = ""
  res@gsnRightString = ""
  res@gsnMaximize           = True             ; maximize plot size
  res@cnFillOn              = True             ; color plot desired
  res@cnFillPalette         = "BlAqGrYeOrReVi200" ; select color map
  res@cnLinesOn             = False            ; turn off contour lines
  res@cnLineLabelsOn        = False            ; turn off contour labels



;---Necessary for contours to be overlaid correctly on WRF projection
  res@tfDoNDCOverlay   = True          ; Tell NCL you are doing a native plot
; res@tfDoNDCOverlay   = "NDCViewport" ; can use this in NCL V6.5.0 or later
   
;---Temperature filled contour plot
  tf_res                      = res
  tf_res@cnFillOn             = True  
  tf_res@cnLevelSelectionMode = "ExplicitLevels"
  tf_res@cnLevels             = ispan(-20,90,5)
  tf_res@lbLabelFontHeightF   = 0.015
  tf_res@lbOrientation        = "Vertical"
  tf_res@pmLabelBarOrthogonalPosF = -0.005

  contour_tf = gsn_csm_contour(wks,tf2,tf_res)

;---SLP line contour plot
  levels      = ispan(900,1100,4)
  info_string = "Sea level pressure contours from 900 to 1100 by 4"


res@mpDataBaseVersion    = "HighRes"

res@cnLevelSelectionMode  = "ExplicitLevels" ; explicit [unequal] cn levels
  res@cnLevels              = (/940,950,960,970,980,990,1000,1010,1020/)

  contour_psl = gsn_csm_contour(wks,slp,res)

;---Wind vector plot
  vec_res                  = res
  vec_res@vcMinDistanceF   = 0.02
  vec_res@vcRefLengthF     = 0.02  
  vec_res@vcMinFracLengthF = 0.2
  vec_res@vcGlyphStyle     = "WindBarb"
  vec_res@vcRefAnnoOn      = False

  vector = gsn_csm_vector(wks,u10,v10,vec_res)

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
  
;---Map plot
  map_res               = True
  map_res@gsnFrame      = False
  map_res@gsnDraw       = False
  map_res@tiMainString  = filename
  map_res@gsnLeftString = tf2@description + " (" + tf2@units + ")~C~" + \
                          slp@description + " (" + slp@units + ")~C~" + \
                          "Wind (" + u10@units + ")"
  map_res@gsnLeftStringFontHeightF = 0.01
map_res@mpOutlineBoundarySets = "AllBoundaries"
map_res@mpDataSetName         = "Earth..4"      ; Gives us provincial boundaries
map_res@mpGeophysicalLineColor       = "Black"
map_res@mpNationalLineColor          = "Black"
map_res@mpUSStateLineColor           = "Black"
map_res@mpGridLineColor              = "Black"
map_res@mpLimbLineColor              = "Black"
map_res@mpPerimLineColor             = "Black"
map_res@mpGeophysicalLineThicknessF  = 2.0
map_res@mpGridLineThicknessF         = 1.0
map_res@mpLimbLineThicknessF         = 2.0
map_res@mpNationalLineThicknessF     = 2.0
map_res@mpUSStateLineThicknessF      = 2.0
map_res@mpProvincialLineThicknessF  = 2.
map_res@mpProvincialLineColor       = "black"


map_res@mpDataBaseVersion    = "HighRes"
;---Set map resources based on projection on WRF output file
  map_res = wrf_map_resources(a,map_res)

  map = gsn_csm_map(wks,map_res)

;---Overlay plots on map and draw.
;  overlay(map,contour_tf)
  overlay(map,contour_psl)
  overlay(map,vector)

  draw(map)   ; This will draw all overlaid plots and the map
  frame(wks)


print("Script finished.")
end
