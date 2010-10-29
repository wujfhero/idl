;+
; NAME: 
; RAD_MAP_PLOT
;
; PURPOSE: 
; This procedure plots a map with potential contours, convection boundary, velocity vectors
; and some scales, colorbar and a title.
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE:
; RAD_MAP_PLOT
;
; KEYWORD PARAMETERS:
; DATE: A scalar or 2-element vector giving the time range to plot, 
; in YYYYMMDD or MMMYYYY format.
;
; TIME: A 2-element vector giving the time range to plot, in HHII format.
;
; LONG: Set this keyword to indicate that the TIME value is in HHIISS
; format rather than HHII format.
;
; INDEX: The index number of the map to plot. If not set, that map with the timestamp closest
; to the gien input date will be plotted.
;
; NORTH: Set this keyword to plot the convection pattern for the northern hemisphere.
;
; SOUTH: Set this keyword to plot the convection pattern for the southern hemisphere.
;
; HEMISPHERE; Set this to 1 for the northern and to -1 for the southern hemisphere.
;
; COORDS: Set this to a string containing the name of the coordinate system to plot the map in.
; Allowable systems are geographic ('geog'), magnetic ('magn') and magnetic local time ('mlt').
;
; COAST: Set this keyword to plot coast lines.
;
; NO_FILL: Set this keyword to surpress filling of the coastal lines.
;
; CROSS: Set this keyword to plot a coordinate cross rather than a box.
;
; SCALE: Set this keyword to a 2-element vector containing the minimum and maximum velocity 
; used for coloring the vectors.
;
; MODEL: Set this keyword to include velocity vectors added by the model.
;
; MERGE: Set this keyword to plot velocity vectors
;
; TRUE: Set this keyword to plot velocity vectors
;
; LOS: Set this keyword to plot velocity vectors
;
; GRAD: Set this keyword to plot velocity vectors calculated from the ExB drift using the coefficients
; of the potential.
;
; NEW_PAGE: Set this keyword to plot multiple maps each on a separate page.
;
; COMMON BLOCKS:
; RAD_DATA_BLK: The common block holding map data.
;
; MODIFICATION HISTORY: 
; Written by Lasse Clausen, Dec, 11 2009
;-
pro rad_map_plot, date=date, time=time, long=long, $
	coords=coords, index=index, scale=scale, new_page=new_page, $
	north=north, south=south, hemisphere=hemisphere, $
	xrange=xrange, yrange=yrange, $
	cross=cross, coast=coast, no_fill=no_fill, orig_fan=orig_fan, $
	model=model, merge=merge, true=true, los=los, grad=grad, $
	vec_radar_ids=vec_radar_ids, fan_radar_ids=fan_radar_ids

common rad_data_blk

; check hemisphere and north and south
if ~keyword_set(hemisphere) then begin
	if keyword_set(north) then $
		hemisphere = 1. $
	else if keyword_set(south) then $
		hemisphere = -1. $
	else $
		hemisphere = 1.
endif

if ~keyword_set(scale) then $
	scale = [0,2000]

if n_elements(yrange) ne 2 then $
	yrange = [-46,46]

if n_elements(xrange) ne 2 then $
	xrange = [-46,46]

aspect = float(xrange[1]-xrange[0])/float(yrange[1]-yrange[0])

; this makes int_hemi 0 for north and 1 for south
int_hemi = (hemisphere lt 0)

if rad_map_info[int_hemi].nrecs eq 0L then begin
	if ~keyword_set(silent) then $
		prinfo, 'No data loaded.'
	return
endif

if ~keyword_set(date) then begin
	if ~keyword_set(silent) then $
		prinfo, 'No DATE given, trying for scan date.'
	caldat, (*rad_map_data[int_hemi]).sjuls[0], month, day, year
	date = year*10000L + month*100L + day
endif

if n_elements(time) lt 1 then $
	time = 1200

if n_elements(index) ne 0 then $
	sfjul, date, time, (*rad_map_data[int_hemi]).mjuls[index], /jul

sfjul, date, time, sjul, fjul

; sample time of maps
; in minutes
dt = mean(deriv((*rad_map_data[int_hemi]).mjuls*1440.d))

; account for sjul being before the
; date/time of the first map
sjul = ( sjul > (*rad_map_data[int_hemi]).sjuls[0] )

if n_elements(time) eq 2 then begin
	npanels = round((fjul-sjul)*1440.d/dt)
endif else begin
	npanels = 1
endelse

; calculate number of panels per page
if npanels eq 1 then begin
	xmaps = 1
	ymaps = 1
endif else if npanels eq 2 then begin
	xmaps = 2
	ymaps = 1
endif else if npanels le 4 then begin
	xmaps = 2
	ymaps = 2
endif else if npanels le 6 then begin
	xmaps = 3
	ymaps = 2
endif else begin
	xmaps = floor(sqrt(npanels)) > 1
	ymaps = ceil(npanels/float(xmaps)) > 1
endelse

; take into account format of page
; if landscape, make xmaps > ymaps
fmt = get_format(landscape=ls, sardines=sd)
if ls then begin
	if ymaps gt xmaps then begin
		tt = xmaps
		xmaps = ymaps
		ymaps = tt
	endif
; if portrait, make ymaps > xmaps
endif else begin
	if xmaps gt ymaps then begin
		tt = ymaps
		ymaps = xmaps
		xmaps = tt
	endif
endelse

clear_page
set_format, /sardi

; loop through panels
for b=0, npanels-1 do begin
	
	asjul = sjul + double(b)*dt/1440.d
	sfjul, date, time, asjul, /jul_to

	; calculate index from date and time
	if n_elements(index) eq 0 then begin
		dd = min( abs( (*rad_map_data[int_hemi]).sjuls-asjul ), _index)
		; check if time ditance is not too big
		if dd*1440.d gt 60. then $
			prinfo, 'Map found, but '+string(dd*1440.d,format='(I4)')+' minutes off chosen time.'
	endif else begin
		asjul = (*rad_map_data[int_hemi]).sjuls[index]
		sfjul, date, time, (*rad_map_data[int_hemi]).sjuls[index], /jul_to
		_index = index
	endelse
	amjul = (*rad_map_data[int_hemi]).mjuls[_index]

	if keyword_set(new_page) then begin
		clear_page
		xmaps = 1
		ymaps = 1
		xmap = 0
		ymap = 0
	endif else begin
		xmap = b mod xmaps
		ymap = b/xmaps
	endelse

	if b eq 0 or keyword_set(new_page) then begin
		mpos = define_panel(xmaps, 1, xmaps-1, 0, aspect=aspect, /bar) - [.06, .075, .06, .075]
		opos = define_panel(1, 1, 0, 0, aspect=aspect, /bar) - [.06, .075, .06, .075]
		orange = [amjul + [-1.d,1.d]*30.d/1440.d]
		sfjul, odate, otime, orange, /jul_to
		omn_read, odate, time=otime, /force
		oopos = [opos[0], opos[3]+.01, opos[2], opos[3]+.1]
		omn_plot_panel, date=odate, time=otime, position=oopos, yrange=[-10,10], /ystyle, $
			param='by_gsm', yticks=2, charsize=get_charsize(1,2), xstyle=1, /first, linecolor=get_gray(), ytitle=' ', linethick=2
		omn_plot_panel, date=odate, time=otime, position=oopos, yrange=[-10,10], ystyle=5, $
			param='bz_gsm', charsize=get_charsize(1,2), xstyle=5, /first, linecolor=253, ytitle='[nT]', linethick=2
		xyouts, amjul - 28.d/1440.d, !y.crange[0]+.13*(!y.crange[1]-!y.crange[0]), $
			'By', color=get_gray(), charsize=get_charsize(1,2), charthick=2
		xyouts, amjul - 28.d/1440.d, !y.crange[1]-.18*(!y.crange[1]-!y.crange[0]), $
			'Bz', color=253, charsize=get_charsize(1,2), charthick=2
		oplot, !x.crange, replicate(.5*!y.crange[0], 2), linestyle=1, color=get_gray()
		oplot, !x.crange, replicate(.5*!y.crange[1], 2), linestyle=1, color=get_gray()
		oplot, replicate(amjul,2), !y.crange, linestyle=2, color=252
		oopos = [opos[0], opos[3]+.11, opos[2], opos[3]+.2]
		rad_map_plot_npoints_panel, date=odate, time=otime, position=oopos, yrange=[1e1,1e3], ystyle=5, $
			charsize=get_charsize(1,2), xstyle=5, /ylog, linethick=2, hemisphere=hemisphere
		rad_map_plot_potential_panel, date=odate, time=otime, position=oopos, yrange=[30,130], ystyle=9, $
			charsize=get_charsize(1,2), xstyle=9, /first, linecolor=200, linethick=2, hemisphere=hemisphere
		xyouts, amjul - 28.d/1440.d, !y.crange[0]+.13*(!y.crange[1]-!y.crange[0]), $
			textoidl('\Phi_{pc}'), color=200, charsize=get_charsize(1,2), charthick=2
		xyouts, amjul - 28.d/1440.d, !y.crange[1]-.18*(!y.crange[1]-!y.crange[0]), $
			'Npts', charsize=get_charsize(1,2), charthick=2
		axis, /yaxis, ystyle=1, yrange=[1e1,1e3], yticks=2, /ylog, charsize=get_charsize(1,2), ytitle='Npts'
		axis, /xaxis, /xstyle, xrange=orange, xticks=get_xticks(orange[0], orange[1]), $
			charsize=get_charsize(1,2), xtickformat='label_date'
		oplot, replicate(amjul,2), !y.crange, linestyle=2, color=252
	endif

	factor = 1.*2000./(scale[1]-scale[0])

	if ~keyword_set(position) then $
		_position = define_panel(xmaps, ymaps, xmap, ymap, aspect=aspect, /bar) - [.06, .075, .06, .075] $
	else $
		_position = position

	rad_map_plot_panel, xmaps, ymaps, xmap, ymap, $
		date=date, time=time, long=long, $
		north=north, south=south, hemisphere=hemisphere, $
		coords=coords, index=_index, scale=scale, $
		no_fill=no_fill, cross=cross, coast=coast, $
		model=model, merge=merge, true=true, los=los, grad=grad, $
		xrange=xrange, yrange=yrange, factor=factor, orig_fan=orig_fan, $
		vec_radar_ids=vec_radar_ids, fan_radar_ids=fan_radar_ids, $
		position=_position

	rad_map_plot_title, position=_position, index=_index, $
		charsize=get_charsize(1,2), int_hemisphere=int_hemi

	rad_map_plot_imf, xmaps, ymaps, xmap, ymap, gap=.05*get_charsize(xmaps,ymaps), $
		index=_index, size=.125/sqrt(xmaps > ymaps)*(_position[2]-_position[0]), $
    int_hemisphere=int_hemi, tposition=_position

	rad_map_plot_vector_scale, xmaps, ymaps, xmap, ymap, gap=.05*get_charsize(xmaps,ymaps), $
		scale=scale, xrange=xrange, factor=factor, tposition=_position

	if keyword_set(new_page) then begin
		cb_pos = define_cb_position(_position, height=50, gap=.2*(_position[2]-_position[0]))
		plot_colorbar, /square, scale=scale, parameter='velocity', position=cb_pos, $
			/no_rotate
		if keyword_set(orig_fan) then begin
			cb_pos = define_cb_position(_position, height=50, gap=.13*(_position[2]-_position[0]))
			plot_colorbar, /square, scale=.5*[-scale[1],scale[1]], parameter='velocity', $
				/left, position=cb_pos, legend=' '
		endif
	endif

endfor

if ~keyword_set(new_page) then begin
	cb_pos = define_cb_position(mpos, height=50, gap=.2*(mpos[2]-mpos[0]))
	plot_colorbar, /square, scale=scale, parameter='velocity', position=cb_pos, $
		/no_rotate
	if keyword_set(orig_fan) then begin
		cb_pos = define_cb_position(mpos, height=50, gap=.13*(mpos[2]-mpos[0]))
		plot_colorbar, /square, scale=.5*[-scale[1],scale[1]], parameter='velocity', $
			/left, position=cb_pos, legend=' '
	endif
endif

end
