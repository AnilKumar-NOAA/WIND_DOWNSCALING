;********************************************************
; Plot storm stracks from wrfout files.
;********************************************************

load "/opt/ncarg/6.2.0/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "/opt/ncarg/6.2.0/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "/opt/ncarg/6.2.0//lib/ncarg/nclscripts/csm/contributed.ncl"
load "/opt/ncarg/6.2.0/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
load "/opt/ncarg/6.2.0/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin

   xp = new((/5,13/),float)            ; allocate memory
   yp = new((/5,13/),float)

;best track
   yp(0,:) = (/ 24.5,   24.6,   24.8,   25.0,  25.2,  25.4,  25.6,   25.7,  26.0,   26.2,  26.3,  26.6,  26.7/)
   xp(0,:) = (/-81.5,  -81.5,  -81.5,  -81.5, -81.6,  -81.7, -81.8, -81.8, -81.7,  -81.8, -81.7, -81.7, -81.7/)
;da
   yp(1,:) = (/ 24.5,   24.6,   24.7,   24.9,  25.1,   25.5,   25.7,   26.0,  26.0,   26.3,   26.2,   26.5,  26.7/)
   xp(1,:) = (/-81.5,  -81.5,  -81.6,  -81.6, -81.7,  -81.6,  -81.7,  -81.6, -81.7,  -81.8,  -81.6,  -81.8,  -81.7/)
;wrfUgfs
;   yp(2,:) = (/ 29.03,  30.29,  31.56,  33.05/)
;   xp(2,:) = (/-94.62, -95.34, -95.45, -95.14/)
;3dvar
;   yp(3,:) = (/ 29.03,  30.47,  32.46,  34.32/)
;   xp(3,:) = (/-94.62, -94.29, -94.38, -93.70/)

;********************************************
   wks      = gsn_open_wks("png","annotate_irma")       ; send graphics to PNG file

   res             = True
   res@gsnDraw     = False                         ; don't draw
   res@gsnFrame    = False                         ; don't advance frame
   res@gsnMaximize = True

   res@mpFillOn              = False
   res@mpPerimOn             = True
   res@mpOutlineBoundarySets = "GeophysicalAndUSStates"
   res@pmTickMarkDisplayMode = "Always"

   res@mpLimitMode = "LatLon"        ; select subregion
   res@mpMinLatF   = 24 
   res@mpMaxLatF   = 28                
   res@mpMinLonF   = -83.5
   res@mpMaxLonF   = -79.5
res@mpDataBaseVersion    = "HighRes"
   res@tmYROn      = False     ; turn off right and top tickmarks
   res@tmXTOn      = False

   res@tiMainString      = "Hurricane Irma track"  ; title
   res@tiMainFontHeightF = 0.02

   map = gsn_csm_map(wks,res)                     ; create map

; Set up some legend resources.
   lgres                    = True
   lgres@lgLineColors       = (/"black","red"/)
   lgres@lgLineThicknessF   = 2. 
   lgres@lgLabelFontHeightF = .08            ; set the legend label font thickness
   lgres@vpWidthF           = 0.15           ; width of legend (NDC)
   lgres@vpHeightF          = 0.1            ; height of legend (NDC)
   lgres@lgMonoDashIndex    = True   
   lgres@lgPerimColor       = "orange"       ; draw the box perimeter in orange
  ;lgres@lgPerimThicknessF = 3.0            ; thicken the box perimeter
   labels = (/"Best track","LES Model"/)

; Create the legend.
   lbid   = gsn_create_legend(wks,2,labels,lgres)         ; create legend

; Set up resources to attach legend to map.
   amres = True
   amres@amParallelPosF   =  -0.27 	         ; positive move legend to the right
   amres@amOrthogonalPosF = 0.25                 ; positive move the legend down
   annoid1 = gsn_add_annotation(map,lbid,amres)   ; attach legend to plot
 
; Add text of every 6 hours  
   txres               = True
   txres@txFontHeightF = 0.015        
   txres@txFontColor   = "black"
   text1 = gsn_add_text(wks,map,"1012",xp(0,0)+0.1,yp(0,0)+0.1,txres)
   text2 = gsn_add_text(wks,map,"1018",xp(0,6)+0.15,yp(0,6),txres)
   text3 = gsn_add_text(wks,map,"1100",xp(0,12)+0.15,yp(0,12),txres)
 ;  text4 = gsn_add_text(wks,map,"1106",xp(0,18),    yp(0,18)+0.1,txres)

; Add trajectory lines.
   pres                  = True               ; polyline resources
   pres@gsLineThicknessF = 3.0                ; line thickness
   pres@gsLineColor      = "black"
   line1 = gsn_add_polyline(wks,map,xp(0,:),yp(0,:),pres)      ; draw the traj

   pres                  = True               ; polyline resources
   pres@gsLineColor      = "red"
   line2 = gsn_add_polyline(wks,map,xp(1,:),yp(1,:),pres)      ; draw the traj


; Add markers to the trajectories.
   mres                = True         ; marker resources for best track
   mres@gsMarkerIndex  = 16           ; marker style (filled circle)
   mres@gsMarkerSizeF  = 8.0          ; marker size
   mres@gsMarkerColor  = "black"      ; maker color
   markers = gsn_add_polymarker(wks,map,xp(0,:),yp(0,:),mres)

   draw(map)                                           
   frame(wks)                                         
  
end

