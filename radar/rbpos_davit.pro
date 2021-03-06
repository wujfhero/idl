;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;+
; NAME:
;	rbpos
;
; PURPOSE:
;
;	Calculate the geographic or geomagnetic position of radar range/beam
;	cells.
;
; CALLING SEQUENCE:
;
;	  pos = rbpos(range,[height=height],[station=station_id],
;		[beam=beam_number],[lagfr=lag_to_first_range],
;		[smsep=sample_separation],[data=data_ptr],[/CENTER],[/GEO])
;
;		inputs:  the range number (first range =1).  This may be
;				a vector containing a list of ranges.
;			 if the height is not specified a value of 300 km is
;				used.
;			 the following keywords specify the station id, 
;				beam number, lag to the first range, 
;				and lag separation:  "station",
;				"beam", "lagfr", "smsep".  If these keywords 
;				are not specified, their values are taken from
;				the data structure pointed to by the
;				keyword "data" or from "fit_data" if no
;				data structure is specified.
;			 if the keyword data is given a value, the information
;				on the bmnum, smsep, etc. is taken from the
;				structure pointed to by that keyword.
;				Otherwise, the data structure "fit_data"
;				is assummed.
;			 if the keyword CENTER is set, only the position of
;			    the center of the cell is return
;			 if the keyword GEO is set, the coordinates are
;			    returned in geographic, otherwise PACE geomagnetic
;			    coordinates are used.
;
;------------------------------------------------------------------------------
;

function rbpos_davit, station, range, beam, lagfr, smsep, rxrise, year, yrsec, $
	height=height, center=center, geo=geo, maxbeams=maxbeams

common radarinfo, network

;  check the keywords that set radar parameters
if n_params() ne 8 then begin
	prinfo, 'Must give, StationID, Range, Beam, LagFr, SmSep, RxRise, Year and YrSec.'
	return
endif

; load the hardware data if we haven't done so already
if n_elements(network) eq 0 then begin
	prinfo, 'Radar Hardware information not loaded.'
	return, -1.
endif

;  check the keywords that set radar parameters
if keyword_set(height) then $
	_height = float(height) $
else $
	_height = 300.
if keyword_set(beam)) then $
	_beam = beam $
else $
	bmnum=dp.p.bmnum
if keyword_set(first_lag)) then lagfr=first_lag else lagfr=dp.p.lagfr
if keyword_set(smsp)) then smsep = smsp else smsep=dp.p.smsep
if keyword_set(rxrs)) then rxrise = rxrs else rxrise=dp.p.rxrise
if keyword_set(station)) then st_id = station else st_id = dp.p.st_id
if keyword_set(yr)) then year=yr else year=dp.p.year
if keyword_set(yrs)) then yrsec=yrs else $
      yrsec=TimeYMDHMSToYrsec(dp.p.year,dp.p.month,dp.p.day,dp.p.hour, $
                                  dp.p.minut,dp.p.sec)

  yr=year
  s=TimeYrsecToYMDHMS(yr,mo,dy,hr,mt,sc,yrsec)

  rid=RadarGetRadar(network,st_id)
  s=TimeYrsecToYMDHMS(yr,mo,dy,hr,mt,sc,yrsec)
  site=RadarYMDHMSGetSite(rid,yr,mo,dy,hr,mt,sc)

  frang=lagfr*0.15
  rsep=smsep*0.15

;
;	if the center keyword is set then we return a 3 element array,
;	otherwise we return an array of 3,2,2
;

  if (keyword_set(center)) then pos=fltarr(3,n_elements(range)) else $
     pos=fltarr(3,2,2,n_elements(range))

  if (keyword_set(geo)) then mgflag = 0 else mgflag = 1
  if (keyword_set(center)) then cflag = 1 else cflag = 0
  pos1 = fltarr(3,2,2)

 ;       print, site.bmsep, year, yrsec

  for i=0, n_elements(range)-1 do begin
    if n_elements(range) EQ 1 then r = fix(range) else r=fix(range(i))
    if (cflag eq 1) then begin         
      s=RadarPos(1,bmnum,r-1,site,frang,rsep,rxrise,h,rho,lat,lon)
      if (mgflag eq 1) then s=AACGMConvert(lat,lon,h,lat,lon,rad)
      pos1[0,0,0]=lat
      pos1[1,0,0]=lon
      pos1[2,0,0]=rho
    endif else begin
      s=RadarPos(0,bmnum,r-1,site,frang,rsep,rxrise,h,rho,lat,lon)
      if (mgflag eq 1) then s=AACGMConvert(lat,lon,h,lat,lon,rad)
      pos1[0,0,0]=lat
      pos1[1,0,0]=lon
      pos1[2,0,0]=rho
      s=RadarPos(0,bmnum+1,r-1,site,frang,rsep,rxrise,h,rho,lat,lon)
      if (mgflag eq 1) then s=AACGMConvert(lat,lon,h,lat,lon,rad)
      pos1[0,1,0]=lat
      pos1[1,1,0]=lon
      pos1[2,1,0]=rho
      s=RadarPos(0,bmnum,r,site,frang,rsep,rxrise,h,rho,lat,lon)
      if (mgflag eq 1) then s=AACGMConvert(lat,lon,h,lat,lon,rad)
      pos1[0,0,1]=lat
      pos1[1,0,1]=lon
      pos1[2,0,1]=rho
      s=RadarPos(0,bmnum+1,r,site,frang,rsep,rxrise,h,rho,lat,lon)
      if (mgflag eq 1) then s=AACGMConvert(lat,lon,h,lat,lon,rad)
      pos1[0,1,1]=lat
      pos1[1,1,1]=lon
      pos1[2,1,1]=rho
    endelse
    if (n_elements(range) GT 1) then $
      if (keyword_set(center)) then pos(*,i)=pos1(*,0,0) else $
      pos(*,*,*,i)=pos1 else $
      if (keyword_set(center)) then pos=pos1(*,0,0) else $
      pos = pos1
  endfor
  pos=reform(pos)
  return,pos
end	
