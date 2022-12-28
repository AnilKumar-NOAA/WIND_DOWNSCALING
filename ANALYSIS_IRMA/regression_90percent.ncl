;*************************************************
; regress_1a.ncl
;
; Concepts illustrated:
;   - Create arrays with data
;   - Calculating the simple linear regression via 'regline_stats'
;     Returns same information as 'regline' *and* many additional statistics.
;   - Uses 6.4.0 information to calculate:
;     (a) 95% line drawn with 5 and 95% slope and y-intercept limits
;     (b) 95% mean response
;     (c) 95% confidence interval
;   - Drawing a scatter plot with regression line
;   - Drawing all regression information
;*************************************************
; http://www.ncl.ucar.edu/Document/Functions/Contributed/regline_stats.shtml
; Uses 6.4.0 updates
;*************************************************

begin
;
;    x    = (/ 1190.,1455.,1550.,1730.,1745.,1770. \
;            , 1900.,1920.,1960.,2295.,2335.,2490. \
;            , 2720.,2710.,2530.,2900.,2760.,3010. /)
;      
;    y    = (/ 1115.,1425.,1515.,1795.,1715.,1710. \
;            , 1830.,1920.,1970.,2300.,2280.,2520. \
;            , 2630.,2740.,2390.,2800.,2630.,2970. /)
;

z1 = asciiread("./naples_15minaverage_data.txt",(/37,12/),"float")
obs_date = z1(0:36:1,0)
obs_time = z1(0:36:1,1)
obs_wspd = z1(0:36:1,2)
obs_wdir = z1(0:36:1,3)
obs_gust = z1(0:36:1,4)
obs_psfc = z1(0:36:1,5)
model_wspd = z1(0:36:1,6)
model_wdir = z1(0:36:1,8)
model_psfc = z1(0:36:1,11)

x = obs_wspd
y = model_wspd

    rc =  regline_stats(x,y) ; linear regression coef
    print(rc)
                                         ; EXTREMES with 95% slope & y-intercept
    Yest_025 = rc@y95(0) + rc@b95(0)*x  
    Yest_975 = rc@y95(1) + rc@b95(1)*x  

;************************************************
; create an array to hold both the original data
; and the calculated regression line   
;************************************************
    nx   = dimsizes(x)
    pltarry      = new ( (/6,nx/), typeof(x))
    pltarry(0,:) = y                                 ; use markers
    pltarry(1,:) = rc@Yest

    pltarry(2,:) = rc@YMR025                         ; mean response
    pltarry(3,:) = rc@YMR975

    pltarry(4,:) = rc@YPI025                         ; prediction limits
    pltarry(5,:) = rc@YPI975

;    pltarry(6,:) = Yest_025                    
;    pltarry(7,:) = Yest_975

;************************************************
; plotting parameters
; This illustrates one approach. Overlays could also be used.
;************************************************
    wks  = gsn_open_wks("png","regress")             ; send graphics to PNG file
    
    res                     = True                   ; plot mods desired
    res@xyMarkLineModes     = (/"Markers","Lines" \  ; choose which have markers
                               ,"Lines"  ,"Lines" \ 
                               ,"Lines"  ,"Lines" /)
    res@xyMarkers           = 16                     ; choose type of marker 
    res@xyMarkerSizeF       = 0.0075                 ; Marker size (default 0.01)

    res@xyDashPatterns      = 0                      ; solid line 
    res@xyLineThicknesses   = (/1,3,2,2,2,2,1,1/)     
    res@xyLineColors        = (/ "black", "black" \
                               , "blue" , "blue"  \
                               , "red"  , "red" /)  

;    res@trXMinF             =   min(x)
;    res@trXMaxF             =   max(x)
     res@trXMinF            =  min(x)
    res@trXMaxF             =  60 ;max(x) 
    res@trYMinF             =  min(y)
    res@trYMaxF             =  60 ;max(y)


    res@tmYLFormat          = "f"                    ; not necessary but nicer labels 

    res@tiMainString           = "regline_stats"
    res@tiYAxisString          = "Y"
    res@tiXAxisString          = "X"
    plot  = gsn_csm_xy (wks,x,pltarry(0:1,:),res)           ; create plot

;---Make legend smaller and move into plot
    res@pmLegendDisplayMode    = "Always"            ; turn on legend
    res@pmLegendSide           = "Top"               ; Change location of 
    res@pmLegendParallelPosF   = .25                 ; move units right
    res@pmLegendOrthogonalPosF = -0.35               ; move units down
    res@pmLegendWidthF         = 0.175               ; Change width and
    res@pmLegendHeightF        = 0.175               ; height of legend.
    res@lgPerimOn              = True                ; turn off/on box around
    res@lgLabelFontHeightF     = .015                ; label font height
    res@xyExplicitLegendLabels = (/"data"         , "regline"       \
                                  ,"5% response"  , "95% response"  \   
                                  ,"5% prediction", "95% prediction"\   
                                  ,"5% b0, b1"    , "95% b0, b1"    /)

    plot  = gsn_csm_xy (wks,x,pltarry,res)           ; create plot
end
