
load "/opt/ncarg/6.2.0/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "/opt/ncarg/6.2.0/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "/opt/ncarg/6.2.0//lib/ncarg/nclscripts/csm/contributed.ncl"
load "/opt/ncarg/6.2.0/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
load "/opt/ncarg/6.2.0/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin

  start_cpu_time = get_cpu_time()     ; We will time this example

;---Open files
  dir   = "./"
  files = systemfunc("ls " + dir + "wrfout_d01*")
  a     = addfiles(files,"r")

;---Read variables
  hgt   = a[:]->HGT(0,:,:)                 ; terrain, 0 is the first time step
  dbz   = wrf_user_getvar(a,"dbz",-1)      ; reflectivity
  times = wrf_user_list_times(a)

  printMinMax(dbz,0)
  printVarSummary(dbz)

;---Set all values < -28 to missing, so they don't get contoured.
  dbz@_FillValue = -999.
  dbz            = where(dbz.lt.-28,dbz@_FillValue,dbz)
  ntim           = dimsizes(dbz(:,0,0,0))
  ilev           = 0                        ; which level to plot

  ter_plot = new(ntim,graphic)
  dbz_plot = new(ntim,graphic)

;---Open workstation
  wks = gsn_open_wks("png","animate_3_1")

;---Set some common resources
  res                       = True
  res@gsnDraw               = False    ; turn off draw
  res@gsnFrame              = False    ; turn off frame
  res@cnFillOn              = True     ; turn on contour fill
  res@cnLinesOn             = False    ; turn off contour lines
  res@cnLineLabelsOn        = False    ; turn off contour line labels

  res@gsnLeftString         = ""       ; turn off subtitles
  res@gsnRightString        = ""
  res@gsnCenterString       = ""

  res@lbLabelFontHeightF       = 0.015    ; size of labelbar labels
  res@pmLabelBarOrthogonalPosF = -0.02    ; move labelbar closer to plot
;
; Setting these four resources is necessary to keep
; the plot from running off the frame.
;
; The plot size will be slightly adjusted internally
; by NCL to preserve the aspect ratio of the map.
;
  res@vpXF                  = 0.08
  res@vpYF                  = 0.88
  res@vpWidthF              = 0.80
  res@vpHeightF             = 0.60
  res@tfDoNDCOverlay        = True      ; faster plotting if we use native WRF map projection

;---Copy common resources for terrain plot
  tres = res 
  tres = wrf_map_resources(a[0],tres)    ; Use first file in list for map proj info

  tres@cnLevelSelectionMode  = "ExplicitLevels"
  tres@cnLevels              = ispan(1,2200,200)
  tres@cnFillPalette         = "OceanLakeLandSnow"
  tres@cnFillOpacityF        = 0.5                 ; make contours partially transparent
  tres@lbLabelBarOn          = False               ; we don't need this

;---Copy common resources for dbz plot
  dres                       = res      

  dres@cnFillMode            = "RasterFill"
  dres@cnLevelSelectionMode  = "ExplicitLevels"
  dres@cnLevels              = ispan(-28,50,8)
  dres@lbOrientation         = "Vertical"

;---Read in colormap so we can subset it.
  cmap_r                     = read_colormap_file("WhViBlGrYeOrRe")
  dres@cnFillPalette         = cmap_r(6:,:)  ; skip the first few colors

;---Loop through each time step and draw a new plot
  do nt=0,ntim-1
;---Don't plot missing or constant fields
    if(all(ismissing(dbz(nt,ilev,:,:))).or.(min(dbz(nt,ilev,:,:)).eq.max(dbz(nt,ilev,:,:)))) then
      print("Field is constant at time='" + times(nt) + "'.  Skipping...")
      continue
    else
      print("time='" + times(nt) + "'")
    end if

;---Create the two plots
    tres@tiMainString = times(nt)
    ter_plot(nt) = gsn_csm_contour_map(wks,hgt,tres)
    dbz_plot(nt) = gsn_csm_contour(wks,dbz(nt,ilev,:,:),dres)

;---Overlay the dbz plot on the terrain plot
    overlay(ter_plot(nt),dbz_plot(nt))

;---Drawing the terrain plot will also draw dbz plot
    draw(ter_plot(nt))
    frame(wks)
  end do

;---Calculate total time for this example.
  end_cpu_time = get_cpu_time()
  print(get_script_prefix_name() + ": elapsed time = " + (end_cpu_time-start_cpu_time) + " seconds.")
end
