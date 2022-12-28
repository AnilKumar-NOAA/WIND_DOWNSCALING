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
load "/opt/ncarg/6.2.0/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "/opt/ncarg/6.2.0/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "/opt/ncarg/6.2.0//lib/ncarg/nclscripts/csm/contributed.ncl"
load "/opt/ncarg/6.2.0/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
load "/opt/ncarg/6.2.0/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"


; set the figure title
;################# CHANGE THE FIGURE TITLE HERE ############################
fig_title	= "Domain 3 (25-meter)"

begin

; define a colour map for the wind speeds
cmap = (/(/255, 255, 255/),(/000, 000, 000/),(/000, 230, 255/),(/000, 255, 255/),(/000, 255, 191/),(/000, 255, 135/),(/000, 255, 000/),(/167, 255, 000/),(/207, 255, 000/),(/255, 255, 000/),(/255, 135, 000/),(/255, 095, 000/),(/255, 039, 000/),(/255, 000, 119/),(/255, 000, 159/),(/255, 000, 199/)/) / 255.

; load in the wrfout file(s)
fList   = systemfunc("ls /data/users/akumar/IRMA_DATA_FORCING/WRF/wrfout_d03_2017-09-11_05:00:00")
nFiles  = dimsizes(fList)


do iFile = 0, nFiles - 1

fileNum	= iFile + 1
print("Working on file " + fileNum + " of " + nFiles)

; create a workstation
filename        = sprinti("wspd_11_05_00UTC_D03",iFile)
filename_full	= sprinti("wspd_11_05_00UTC_D03",iFile)
filename_track	= sprinti("wspd_40m_track_%03d",iFile)
wks             = gsn_open_wks("png",filename)
wks_full	= gsn_open_wks("png",filename_full)
wks_track	= gsn_open_wks("png",filename_track)
gsn_define_colormap(wks,cmap)
gsn_define_colormap(wks_full,cmap)
gsn_define_colormap(wks_track,cmap)
print("Workstations opened.")

; open the wrfout file
a = addfile(fList(iFile),"r")
print("wrfout opened")


lat2d = a->XLAT(0,:,:)
  lon2d = a->XLONG(0,:,:)

; set zoom-in window limits (first column is the SW corner, second column is the NE corner)
; ###################### CHANGE THE VALUES IN THE LATS AND LONS ARRAYS TO SET YOUR WINDOW #################
  lats = (/  min(lat2d),  max(lat2d) /)
  lons = (/ min(lon2d), max(lon2d) /)
  loc = wrf_user_ll_to_ij(a, lons, lats, True)
  x_start = loc(0,0) - 1
  x_end   = loc(0,1) - 1
  y_start = loc(1,0) - 1
  y_end   = loc(1,1) - 1

; Get WRF variables
u       = wrf_user_getvar(a,"ua",-1)		; u wind component
v       = wrf_user_getvar(a,"va",-1)		; v wind component
p       = wrf_user_getvar(a,"pressure",-1)	; pressure
uvmet10 = wrf_user_getvar(a,"uvmet10",-1)	; 10-meter winds
slp     = wrf_user_getvar(a,"slp",-1)		; sea-level pressure
lat     = wrf_user_getvar(a,"lat",-1)		; latitude
lon     = wrf_user_getvar(a,"lon",-1)		; longitude

u10     = uvmet10(0,:,:,:)			; 10-meter u wind component
v10     = uvmet10(1,:,:,:)			; 10-meter v wind component

print("WRF variables imported.")

; Compute the wind speed in meters per second
wspd    		= (u10 * u10 + v10 * v10)^(0.5)
wspd@description        = "Wind Speed"
wspd@units              = "m/s"

; apply mask to only plot gale-force winds
wspd_masked     = mask(wspd,(wspd.gt.18),True)
descr   = "Wind speed at 10 meters"
wspd_masked@description = descr
wspd_masked@units       = "m/s"
print("Wind speeds masked.")

; find location of minimum sea level pressure
;dsize = dimsizes(slp)
;jmax = dsize(1)
;imax = dsize(2)
;slp_min = min(min(slp(0,y_start:y_end,x_start:x_end)))

min_lat=min(lat)
min_lon = min(lon)

;do i = x_start, x_end
;        do j = y_start, y_end
;                if(slp(0,j,i).eq.slp_min) then
;                        min_lat = lat(0,j,i)
;                        min_lon = lon(0,j,i)
;                end if
;        end do
;end do
;print("Storm center located.")

; Plot resources
res             = True
res@MainTitle   = fig_title

; set some map resources for the zoomed in plot
pltres  = True
mpres   = True
mpres@ZoomIn    = True
mpres@Xstart    = x_start
mpres@Xend      = x_end
mpres@Ystart    = y_start
mpres@Yend      = y_end
mpres@mpGeophysicalLineColor      = "Black"
mpres@mpNationalLineColor         = "Black"
mpres@mpUSStateLineColor          = "Black"
mpres@mpGridLineColor             = "Black"
mpres@mpLimbLineColor             = "Black"
mpres@mpPerimLineColor            = "Black"
mpres@mpGeophysicalLineThicknessF = 2.0
;mpres@mpGridLineThicknessF        = 1.0
;mpres@mpLimbLineThicknessF        = 1.0
mpres@mpNationalLineThicknessF    = 2.0
mpres@mpUSStateLineThicknessF     = 2.0
 mpres@mpDataBaseVersion    = "HighRes"
; set resources for the full domain plot
mpres_full				= True
mpres_full@mpGeophysicalLineColor	= "Black"
mpres_full@mpNationalLineColor		= "Black"
mpres_full@mpUSStateLineColor		= "Black"
mpres_full@mpGridLineColor		= "Black"
mpres_full@mpLimbLineColor		= "Black"
mpres_full@mpPerimLineColor		= "Black"
mpres_full@mpGeophysicalLineThicknessF	= 2.0
mpres_full@mpGridLineThicknessF		= 1.0
mpres_full@mpLimbLineThicknessF		= 2.0
mpres_full@mpNationalLineThicknessF	= 2.0
mpres_full@mpUSStateLineThicknessF	= 2.0
mpres_full@mpDataBaseVersion    = "HighRes"
; set some map resources for the storm-following plot
lats = (/  floor(min_lat)-5,  floor(min_lat)+5 /)
lons = (/ floor(min_lon)-5, floor(min_lon)+5 /)
loc = wrf_user_ll_to_ij(a, lons, lats, True)
x_start_track = loc(0,0) - 1
x_end_track   = x_start_track + 40
y_start_track = loc(1,0) - 1
y_end_track   = y_start_track + 40

;pltres  = True
;mpres_track   = True
;mpres_track@ZoomIn    = True
;mpres_track@Xstart    = x_start_track
;mpres_track@Xend      = x_end_track
;mpres_track@Ystart    = y_start_track
;mpres_track@Yend      = y_end_track
;mpres_track@mpOutlineBoundarySets	= "AllBoundaries"
;mpres_track@mpGeophysicalLineColor      = "Black"
;mpres_track@mpNationalLineColor         = "Black"
;mpres_track@mpUSStateLineColor          = "Black"
;mpres_track@mpGridLineColor             = "Black"
;mpres_track@mpLimbLineColor             = "Black"
;mpres_track@mpPerimLineColor            = "Black"
;mpres_track@mpGeophysicalLineThicknessF = 2.0
;mpres_track@mpGridAndLimbOn		= False
;mpres_track@mpNationalLineThicknessF    = 2.0
;mpres_track@mpUSStateLineThicknessF     = 2.0
;mpres_track@tmXTOn			= False
;mpres_track@tmXBOn			= False
;mpres_track@tmYLOn			= False
;mpres_track@tmYROn			= False

; set resources for plotting wind speeds
res                     = True
res@gsnDraw             = False
res@gsnFrame            = False
res@cnFillOn            = True
res@cnLinesOn           = False
res@lbLabelAutoStride   = True
times                   = wrf_user_list_times(a)
res@ValidTime           = True
res@TimeLabel           = times
res@mpDataBaseVersion    = "HighRes"
opts                                    = res
opts@cnFillMode                         = "RasterFill"
opts@cnRasterSmoothingOn                = True
opts@ContourParameters                  = (/18, 50, 3/)
;opts@mpDataBaseVersion    = "HighRes"
; Create a string to plot the minimum central pressure information
;minpres = "Min SLP" + sprintf("%5.0f",slp_min) + " mb (Lat: " + sprintf("%4.1f",min_lat) + ", Lon: " + sprintf("%4.1f",min_lon) + ")"

; set resources for plotting pressure
;pressureres             		= True
;pressureres@cnLineColor 		= "Black"
;pressureres@cnInfoLabelOn		= False
;pressureres@cnMinLevelValF		= 800
;pressureres@cnMaxLevelValF		= 1200
;pressureres@cnLevelSpacingF		= 2
;pressureres@cnLineLabelPlacementMode	= "Constant"

; set resources for plotting the wind vectors
  vecres                                 = True
  vecres@vcGlyphStyle                    = "FillArrow"
  vecres@vcWindBarbLineThicknessF        = 1.5
  vecres@vcMinDistanceF                  = 0.075

; find the maximum wind speed
;wind_max = max(max(wspd(0,y_start:y_end,x_start:x_end)))
;maxspd  = sprintf("Max winds = %.1f", max(max(wspd(0,y_start:y_end,x_start:x_end))))
;maxspd_ms = maxspd + " m/s"
;wind_max_mph = wind_max * 2.23694
;maxspd_mh = sprintf(" (%.1f MPH)", wind_max_mph)
;maxspd_full = maxspd_ms + maxspd_mh

; create a string to plot the min. central pressure and max. wind information
;wind_pres	= maxspd_full + " | " + minpres
;txres                   = True
;txres@txFontHeightF     = 0.015
;gsn_text_ndc(wks,wind_pres,0.50,0.10,txres)
;gsn_text_ndc(wks_full,wind_pres,0.50,0.10,txres)
;gsn_text_ndc(wks_track,wind_pres,0.50,0.10,txres)

; create zoomed-in plots
;contour_slp                             = wrf_contour(a, wks, slp(0,y_start:y_end,x_start:x_end), pressureres)	; plot SLP
;contour_spd                             = wrf_contour(a,wks,wspd_masked(0,y_start:y_end,x_start:x_end),opts)	; plot wind speeds
;vector					= wrf_vector(a, wks, u10(0,y_start:y_end,x_start:x_end), v10(0,y_start:y_end,x_start:x_end), vecres)
;plot                                    = wrf_map_overlays(a,wks,(/contour_slp,contour_spd,vector/),pltres,mpres)	; draw plots
;print("Zoomed-in plots created.")

; create full domain plots
;contour_slp_full	= wrf_contour(a, wks_full, slp(0,:,:), pressureres)
contour_spd_full	= wrf_contour(a, wks_full, wspd_masked(0,:,:), opts)
plot			= wrf_map_overlays(a, wks_full, (/contour_spd_full/), pltres, mpres_full)
print("Full domain plots created.")

; create storm-following plots
;contour_slp_track	= wrf_contour(a, wks_track, slp(0,y_start_track:y_end_track,x_start_track:x_end_track), pressureres)
;contour_spd_track	= wrf_contour(a,wks_track,wspd_masked, opts)	; plot wind speeds
;plot                    = wrf_map_overlays(a,wks_track,contour_spd_track,pltres,mpres_track)	; draw plots
;print("Storm-following plots created.")

; Write track data to text file
;alist   = [/times, min_lat, min_lon, slp_min, wind_max/]
;write_table("wrfrun_table.txt", "a", alist,"%s%5.2f%5.2f%5.0f%5.0f")
;print("Track data written.")
                                                                                
end do

print("Script finished.")
end
