;***********************************************
; raster_3.ncl
;
; Concepts illustrated:
;   - Drawing raster contours over a lambert conformal map
;   - Creating a vegetation plot using raster contours
;   - Drawing map outlines in red
;   - Moving the subtitles up
;   - Changing the map grid lines to dashed lines
;   - Overlaying contours on a map using two-dimensional lat,lon arrays
;   - Zooming in on a particular area on a Lambert Conformal map
;
;************************************************
;

load "/opt/ncarg/6.2.0/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "/opt/ncarg/6.2.0/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "/opt/ncarg/6.2.0//lib/ncarg/nclscripts/csm/contributed.ncl"
load "/opt/ncarg/6.2.0/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
load "/opt/ncarg/6.2.0/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"


begin
  ff = addfile("../IRMA_DATA_FORCING/WRF/temp/wrfout_d02_2017-09-11_06:00:00.nc","r")

  veg       = ff->LU_INDEX(0,:,:)
printVarSummary(veg)

 ff1 = addfile("../IRMA_DATA_FORCING/WRF/temp/wrfout_d02_2017-09-10_12:00:00.nc","r")

  veg_orig = ff1->LU_INDEX(0,:,:)

  lat = ff->XLAT(0,:,:)
  lon = ff->XLONG(0,:,:)

 veg@lat = lat
 veg_lon = lon
  wks = gsn_open_wks("png","NLCD_PLOT_DOM2")         ; Open a workstation.

  res                 = True                ; Plot mods desired.

  res@gsnMaximize     = True                ; Maximize plot in frame.
  res@gsnDraw               = False            ; (a) do not draw 
  res@gsnFrame              = False            ; (b) do not advance 'frame'
  res@lbLabelBarOn          = False            ; (c) turn off individual lb's 

  res@gsnStringFontHeightF         = 0.013
  res@gsnRightStringOrthogonalPosF = 0.02
  res@gsnLeftStringOrthogonalPosF  = 0.02

  res@cnFillOn        = True               ; Color plot desired.
  res@cnLinesOn       = False              ; Turn off contour lines      .
  res@cnLineLabelsOn  = False              ; Turn off contour labels.
  res@cnLineLabelsOn        = False            ; turn off contour labels

  res@mpProjection           = "LambertConformal"
  res@mpLambertParallel1F    = 23.0                ; two parallels
  res@mpLambertParallel2F    = 35.0
  res@mpLambertMeridianF     = -81.0               ; central meridian
  res@mpLimitMode            = "LatLon"

  res@mpMinLatF              =  min(lat) ;24.0                ; map area
  res@mpMaxLatF              = max(lat) ;50.0                ; latitudes
  res@mpMinLonF              = min(lon) ;-125.0              ; and
  res@mpMaxLonF              = max(lon) ;-65.0               ; longitudes

  res@cnInfoLabelOn       = False           ; Turn off info label.

  res@mpGeophysicalLineColor = "black"     ; color of continental outlines
  res@mpUSStateLineColor     = "black" 
  res@mpGridLineDashPattern  = 2         ; lat/lon lines as dashed
  res@mpOutlineBoundarySets  = "GeophysicalAndUSStates" 
 res@mpGeophysicalLineThicknessF = 2.0        ; wrf_map_resources uses 0.5
  res@mpUSStateLineThicknessF     = 2.0
res@mpDataBaseVersion    = "HighRes"
  res@pmTickMarkDisplayMode = "Always"       ; Turn on map tickmarks.

   cmap = read_colormap_file("BlAqGrWh2YeOrReVi22")   ; 100 colors
;   res@cnFillPalette        = "./nlcd_lu.rgb" ;cmap(40:,:)
  res@cnFillMode           = "RasterFill"
  res@cnLevelSelectionMode = "ManualLevels"
  res@cnMinLevelValF       = 2              ; min contour level
  res@cnMaxLevelValF       = 40             ; max contour level
  res@cnLevelSpacingF      = 1              ; contour spacing
;  res@lbOrientation         = "Vertical"   
;  res@pmLabelBarWidthF     = 0.6
;  res@lbLabelFontHeightF   = 0.013
;  res@lbLabelStride        = 2
;  res@lbBoxLinesOn         = False
  
  res = wrf_map_resources(ff,res)
  res@gsnAddCyclic          = False            ; regional data: not cyclic 
  res@tfDoNDCOverlay        = True             ; set True for native projections
plts = new (2, "graphic")   

    res@gsnLeftString       = "VEGETATION NLCD 30M (40 VEG-CLASS)"

;    res@gsnCenterString     = "Jan. 1999"
 
 plts(0)  = gsn_csm_contour_map(wks, veg_orig, res) ; create plot

delete(res@gsnLeftString )
res@gsnLeftString       = " NLCD LANDUSE WITH WATER INUNDATION (NEAREST_POINT)"
 plts(1)  = gsn_csm_contour_map(wks, veg, res) ; create plot

  resP                    = True                   ; modify the panel plot
  resP@gsnMaximize        = True                   ; maximize panel area
;  resP@gsnPanelRowSpec      = True             ; specify 1 top, 2 lower level  
  resP@gsnPanelLabelBar     = True             ; add common colorbar
  resP@lbOrientation     = "vertical"
  resP@pmLabelBarWidthF     = 0.07             ; make label wider 
  resP@lbLabelFontHeightF   = 0.010            ; default 0.02 [demo make smaller]
  resP@pmLabelBarHeightF = 0.95
  resP@lbLabelJust        = "CenterLeft"  ; left justify labels
  resP@lbLabelAlignment = "BoxCenters"  
  resP@lbLabelStrings   = \ 
        (/" Evergreen Needleleaf Forest"," Evergreen Broadleaf Forest"," Deciduous Needleleaf Forest"," Deciduous Broadleaf Forest"," Mixed Forest"," Closed Shrubland"," Open Shrubland"," Woody Savanna"," Savanna"," Grassland" \
         ," Permanent Wetland"," Cropland"," Urban and Built-Up"," Cropland / Natural Veg. Mosaic"," Permanent Snow"," Barren  / Sparsely Vegetated"," Water"," Unclassified"," Fill Value"," Unclassified" \
         ," Open Water"," Perennial Ice/Snow"," Developed Open Space"," Developed Low Intensity"," Developed Medium Intensity"," Developed High Intensity" \
         ," Barren Land", " Deciduous Forest", " Evergreen Forest", " Mixed Forest", " Dwarf Scrub", " Shrub/Scrub", " Grassland/Herbaceous", " Sedge/Herbaceous" \
         ," Lichens", " Moss", " Pasture/Hay", " Cultivated Crops", " Woody Wetland", " Emergent Herbaceous Wetland"/)
  res@lbLabelAlignment = "BoxCenter"        ; label orientation
  gsn_panel(wks,plts,(/2,1/),resP)               ; now draw as one plot



; draw(plot)
;  frame(wks)

end
