;   Example script to produce dbz plots for a WRF real-data run,
;   with the ARW coordinate dynamics option.
;   November 2008

load "/opt/ncarg/6.2.0/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "/opt/ncarg/6.2.0/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "/opt/ncarg/6.2.0//lib/ncarg/nclscripts/csm/contributed.ncl"
load "/opt/ncarg/6.2.0/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
load "/opt/ncarg/6.2.0/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin
;
; The WRF ARW input file.  
; This needs to have a ".nc" appended, so just do it.
a = addfile("/data/users/akumar/IRMA_DATA_FORCING/WRF/wrfout_d01_2017-09-10_20:00:00.nc","r")

; We generate plots, but what kind do we prefer?
;  type = "x11"
; type = "pdf"
 type = "ps"
; type = "ncgm"
  wks = gsn_open_wks(type,"refl_dom1_2100UTC")
  gsn_define_colormap(wks,"WhViBlGrYeOrReWh")

   mdbz = wrf_user_getvar(a,"mdbz",-1)
     dbz = wrf_user_getvar(a,"dbz",-1)
;---Set some common resources
  res                       = True
  res@gsnDraw               = False    ; turn off draw
  res@gsnFrame              = False    ; turn off frame
  res@cnFillOn              = True     ; turn on contour fill
  res@cnLinesOn             = False    ; turn off contour lines
  res@cnLineLabelsOn        = False    ; turn off contour line labels
  res@cnInfoLabelOn         = False    ; turn off info label

  res@gsnLeftString         = ""       ; turn off subtitles
  res@gsnRightString        = ""
  res@gsnCenterString       = ""

  res@lbLabelFontHeightF       = 0.015    ; size of labelbar labels
  res@pmLabelBarOrthogonalPosF = -0.02    ; move labelbar closer to plot
  res@tfDoNDCOverlay           = True     ; faster plotting if we use 
                                          ; native WRF map projection
  res@lbLabelBarOn             = False    ; will add to panel plot


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


;---Copy common resources for dbz plot
  dres                       = res      

  dres@cnFillMode            = "RasterFill"
  dres@cnLevelSelectionMode  = "ExplicitLevels"
  dres@cnLevels              = ispan(-28,50,8)

;---Read in colormap so we can subset it.
  cmap_r                     = read_colormap_file("WhViBlGrYeOrRe")
  dres@cnFillPalette         = cmap_r(6:,:)  ; skip the first few colors
dbz_plot1 = gsn_csm_contour_map(wks,dbz(0,1,:,:),dres)


 
 resP                      = True             ; modify the panel plot
  resP@gsnMaximize          = True             ; maximize panel area
  resP@gsnPanelRowSpec      = True             ; specify 1 top, 2 lower level
;  resP@gsnPanelLabelBar     = True             ; add common colorbar
  resP@pmLabelBarWidthF     = 0.85             ; make label wider
  resP@lbLabelFontHeightF   = 0.015            ; default 0.02 [demo make smaller]


     gsn_panel(wks,dbz_plot1,(/1,1/),resP)               ; now draw as one plot



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
end
