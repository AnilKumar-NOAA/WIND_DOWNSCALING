;********************************************************
; Plot storm stracks from wrfout files.
;********************************************************
load "/apps/ncl/6.5.0-CentOS7.5_64bit_gnu485/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "/apps/ncl/6.5.0-CentOS7.5_64bit_gnu485/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "/apps/ncl/6.5.0-CentOS7.5_64bit_gnu485/lib/ncarg/nclscripts/csm/contributed.ncl"
load "/apps/ncl/6.5.0-CentOS7.5_64bit_gnu485/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
load "/apps/ncl/6.5.0-CentOS7.5_64bit_gnu485/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/apps/ncl/6.5.0-CentOS7.5_64bit_gnu485/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"


begin



 src_file = "../maxele.63.nc"
 sfile = addfile(src_file,"r")

;printVarSummary(sfile)
 lat1D = sfile->y 
 lon1D = sfile->x
 var = sfile->zeta_max

 dst_file = "geo_em.d02.nc"
 dfile    = addfile(dst_file,"r")


;---Set up regridding options

    Opt                = True

;---"bilinear" is the default. "patch" and "conserve" are other options.
    Opt@InterpMethod     = "neareststod"        ;;---Change (maybe)
    Opt@WgtFileName      = "unstruct_to_rect_D2.nc"

    Opt@SrcGridLat       = lat1D
    Opt@SrcGridLon       = lon1D
    Opt@SrcRegional      = False            ;;--Change (maybe)
    Opt@SrcInputFileName = src_file          ; optional, but good idea

    Opt@SrcMask2D        = where(.not.ismissing(var),1,0) ; Necessary if has
                                                          ; missing values.

    dst_lat              = dfile->XLAT_M(0,:,:)    ; Be sure to use appropriate names 
    dst_lon              = dfile->XLONG_M(0,:,:)   ; here.
    Opt@DstGridLon       = dst_lon
    Opt@DstGridLat       = dst_lat
    Opt@DstRegional      = True            ;;--Change (maybe)
;    Opt@DstMask2D = where(.not.ismissing(dst_lat).and.\
;                          .not.ismissing(dst_lon),1,0) ; Necessary if lat/lon
                                                      ; has missing values.
                                                      ; has missing values.
    Opt@ForceOverwrite   = True
    Opt@Debug            = True
    Opt@PrintTimings     = True

    var_regrid = ESMF_regrid(var,Opt)     ; Do the regridding

    printVarSummary(var_regrid)

 
;----------------------------------------------------------------------
; Plotting section
;
; This section creates filled contour plots of both the original
; data and the regridded data, and panels them.
;----------------------------------------------------------------------
    var@lat2d = lat1D     ; Needed for plotting. "var_regrid" 
    var@lon2d = lon1D     ; already has these attrs attached.

  
    wks = gsn_open_wks("ps","unstruct_to_wrf_D2_nearestpoint")

;---Resources to share between both plots
    res                      = True              ; Plot mods desired

    res@gsnDraw              = False
    res@gsnFrame             = False

    res@gsnMaximize          = True              ; Maximize plot

    res@cnFillOn             = True              ; color plot desired
    res@cnLinesOn            = False             ; turn off contour lines
    res@cnLineLabelsOn       = False             ; turn off contour labels
    res@cnFillMode           = "RasterFill"      ; turn raster on      

    res@lbLabelBarOn          = False    ; Turn on later in panel

    res@mpOutlineBoundarySets = "GeophysicalAndUSStates"    
    res@mpOutlineOn   = True
    res@mpMinLatF            = min(dst_lat)
    res@mpMaxLatF            = max(dst_lat)
    res@mpMinLonF            = min(dst_lon)
    res@mpMaxLonF            = max(dst_lon)


;;--Change (maybe)
    mnmxint = nice_mnmxintvl( 0, 6, 20, False)
    res@cnLevelSelectionMode = "ManualLevels"
    res@cnMinLevelValF       = mnmxint(0)
    res@cnMaxLevelValF       = mnmxint(1)
    res@cnLevelSpacingF      = mnmxint(2)
    res@tfDoNDCOverlay              = True 
    res@gsnAddCyclic = False    
    res@tiMainString  = "Data on WRF grid (" + Opt@InterpMethod + ")"
    res@mpGeophysicalLineColor = "Black"
    res@mpUSStateLineColor     = "Black"
     res@mpGeophysicalLineThicknessF = 2.0
     res@mpUSStateLineThicknessF     = 2.0
    plot_regrid = gsn_csm_contour_map_ce(wks,var_regrid,res)

    delete(res@tfDoNDCOverlay)
;---Resources for plotting original data
    res@gsnAddCyclic       = False            ;;---Change (maybe)
    res@sfXArray           = lon1D
    res@sfYArray           = lat1D
    res@tiMainString = "Original unstructured grid (" + \
                        dimsizes(lon1D) + " cells)"

    plot_orig = gsn_csm_contour_map_ce(wks,var,res)  

;---Draw both plots in a panel
    pres                   = True
    pres@gsnMaximize       = True
    pres@gsnPanelLabelBar  = True

    gsn_panel(wks,(/plot_orig,plot_regrid/),(/2,1/),pres)

end
