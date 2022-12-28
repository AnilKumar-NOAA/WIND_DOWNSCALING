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


 dst_file = "./geo_em.d02.nc"
 dfile    = addfile(dst_file,"w")



    dst_lat              = dfile->XLAT_M(0,:,:)    ; Be sure to use appropriate names 
    dst_lon              = dfile->XLONG_M(0,:,:)   ; here.
    dst_hgt              = dfile->HGT_M(0,:,:)   ; here model terrain elevation height

srcGridName = "source_grid_file.nc"
dstGridName = "destination_grid_file.nc"
wgtFileName = "unstruct_to_rect_D2.nc"


    Opt                      = True
    Opt@InterpMethod         = "neareststod"     ; default
    Opt@ForceOverwrite       = True
    Opt@PrintTimings         = True

 var_regrid = ESMF_regrid_with_weights(var, wgtFileName,Opt)

    printVarSummary(var_regrid)

    printVarSummary(var)


; delete attributes that are not appropriate or needed
    delete( [/ var_regrid@lat2d, var_regrid@lon2d \
             , var_regrid@mesh,  var_regrid@location /] )

;----------------------------------------------------------------------
; Clean up var_regrid before writing to file.
;
;   - Name the the latitude and longitude dimensions using the same
;     names as what dst_lat and dst_lon both have.
;
;   - Update the long_name and units.
;
;   - Set the "coordinates" attribute to indicate what the names are of
;     the latitude and longitude variables on the file. In this case,
;     we're going to use the same names as what they were on the original
;     WRF file.
;----------------------------------------------------------------------
    var_regrid!0           = dst_lon!0     ; update dimension names
    var_regrid!1           = dst_lat!1
    var_regrid@long_name   = "maximum water surface elevationabove geoid"  ; assign attributes
    var_regrid@units       = "m"
    var_regrid@coordinates = "XLONG_M XLAT_M" ; indicates name of lat/lon coord
                                              ; arrays on the file
    printVarSummary(var_regrid)

; Code for writing netcdf format file with lat and long cordinate

  setfileoption("nc", "Format",  "NetCDF4")
  fon = "ZETA_MAX_D02_MAXELV.nc"
  system("/bin/rm -f " + fon) ; remove if exists
  fnew = addfile(fon, "c")


;===================================================================
; create global attributes of the file (optional)
;===================================================================
  fAtt               = True            ; assign file attributes
  fAtt@title         = "NCL Simple Approach to netCDF Creation"
  fAtt@source_file   =  src_file ;"original-file.nc"
  fAtt@Conventions   = "None"
  fAtt@creation_date = systemfunc ("date")
  fileattdef( fnew, fAtt )            ; copy file attributes

  fnew->XLAT_M   = dst_lat
  fnew->XLONG_M  = dst_lon
  fnew->ZETA_MAX = var_regrid                ; name on file different from name in code

; READING LU_INDEX from geo_em file 
lu_index              = dfile->LU_INDEX(0,:,:)

printVarSummary(lu_index)

file2 = "ZETA_MAX_D02_MAXELV.nc"
zfile    = addfile(file2,"r")
zeta_max1              = zfile->ZETA_MAX(:,:)
zeta_lat              = zfile->XLAT_M(:,:)
zeta_lon              = zfile->XLONG_M(:,:)


change_lu_index = where(zeta_max1.gt.0 .and. dst_hgt.lt.zeta_max1, lu_index.eq.17, zeta_max1) ; this give only values in the changed area (water inundation area only)

new_lu_index = where((.not.ismissing(zeta_max1) .and. dst_hgt.lt.zeta_max1) ,17, lu_index )

setfileoption("nc", "Format",  "NetCDF4")
fon1 = "LU_INDEX_D02_MAXELEV.nc"
system("/bin/rm -f " + fon1) ; remove if exists
fnew1 = addfile(fon1, "c")

fnew1->newlu = new_lu_index   
fnew1->change_lu = change_lu_index

dfile->LU_INDEX(0,:,:) = (/new_lu_index/)

end

