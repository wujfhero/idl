;+ 
; NAME: 
; KPI_PLOT_PANEL
;
; PURPOSE: 
; 
; CATEGORY: 
; 
; CALLING SEQUENCE:  
; Graphics
; 
; CALLING SEQUENCE: 
;
; OPTIONAL INPUTS:
; Xmaps: The total number of columns of plots on the resulting page.
; Default is 1.
;
; Ymaps: The total number of rows of plots on the resulting page.
; Default is 1.
;
; Xmap: The current horizontal (column) index of this panel.
; Default is 0.
;
; Ymap: The current vertical (row) index of this panel.
; Default is 0.
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
; YRANGE: Set this keyword to change the range of the y axis.
;
; SILENT: Set this keyword to surpress all messages/warnings.
;
; CHARTHICK: Set this keyword to change the font thickness.
;
; CHARSIZE: Set this keyword to change the font size. 
;
; PSYM: Set this keyword to change the symbol used for plotting.
;
; XSTYLE: Set this keyword to change the style of the x axis.
;
; YSTYLE: Set this keyword to change the style of the y axis.
;
; XTITLE: Set this keyword to change the title of the x axis.
;
; YTITLE: Set this keyword to change the title of the y axis.
;
; XTICKS: Set this keyword to change the number of major x tick marks.
;
; XMINOR: Set this keyword to change the number of minor x tick marks.
;
; YTICKS: Set this keyword to change the number of major y tick marks.
;
; YMINOR: Set this keyword to change the number of minor y tick marks.
;
; LINESTYLE: Set this keyword to change the style of the line.
; Default is 0 (solid).
;
; LINECOLOR: Set this keyword to a color index to change the color of the line.
; Default is black.
;
; LINETHICK: Set this keyword to change the thickness of the line.
; Default is 1.
;
; XTICKFORMAT: Set this keyword to change the formatting of the time fopr the x axis.
;
; YTICKFORMAT: Set this keyword to change the formatting of the y axis values.
;
; POSITION: Set this keyword to a 4-element vector of normalized coordinates 
; if you want to override the internal
; positioning calculations.
;
; LAST: Set this keyword to indicate that this is the last panel in a column,
; hence XTITLE and XTICKNAMES will be set.
;
; EXAMPLE:
; 
; MODIFICATION HISTORY: 
; Written by: Lasse Clausen, 2009.
;-
pro kpi_plot_panel, xmaps, ymaps, xmap, ymap, $
	date=date, time=time, long=long, $
	yrange=yrange, bar=bar, $
	silent=silent, $
	charthick=charthick, charsize=charsize, psym=psym, symsize=symsize, $ 
	xstyle=xstyle, ystyle=ystyle, xtitle=xtitle, ytitle=ytitle, $
	xticks=xticks, xminor=xminor, yticks=yticks, $
	linestyle=linestyle, linecolor=linecolor, linethick=linethick, $
	xtickformat=xtickformat, ytickformat=ytickformat, position=position, $
	last=last, first=first, with_info=with_info, info=info, rectangle=rectangle

common kpi_data_blk

if kpi_info.nrecs eq 0L then begin
	prinfo, 'No data loaded.'
	return
endif

if n_params() lt 4 then begin
	if ~keyword_set(silent) then $
		prinfo, 'XMAPS, YMAPS, XMAP and YMAP not set, using default.'
	xmaps = 1
	ymaps = 1
	xmap = 0
	ymap = 0
endif

if ~keyword_set(position) then begin
	if keyword_set(info) then begin
		position = define_panel(xmaps, ymaps, xmap, ymap, bar=bar, /with_info)
		position = [position[0], position[3], $
			position[2], position[3]+0.05]
	endif else $
		position = define_panel(xmaps, ymaps, xmap, ymap, bar=bar, with_info=with_info)
endif

if ~keyword_set(date) then begin
	caldat, kpi_data.juls[0], month, day, year
	date = year*10000L + month*100L + day
endif

if ~keyword_set(time) then $
	time = [0000,2400]

sfjul, date, time, sjul, fjul, long=long
xrange = [sjul, fjul]

if ~keyword_set(xtitle) then $
	_xtitle = 'Time UT' $
else $
	_xtitle = xtitle

if ~keyword_set(xtickformat) then $
	_xtickformat = 'label_date' $
else $
	_xtickformat = xtickformat

if ~keyword_set(xtickname) then $
	_xtickname = '' $
else $
	_xtickname = xtickname

if ~keyword_set(ytitle) then $
	_ytitle = 'Kp' $
else $
	_ytitle = ytitle

if ~keyword_set(ytickformat) then $
	_ytickformat = '' $
else $
	_ytickformat = ytickformat

if ~keyword_set(xstyle) then $
	xstyle = 1

if ~keyword_set(ystyle) then $
	ystyle = 1

if ~keyword_set(yrange) then $
	yrange = get_default_range('kp_index')

if ~keyword_set(charsize) then $
	charsize = get_charsize(xmaps, ymaps)

if ~keyword_set(linethick) then $
	linethick = 1.

if ~keyword_set(linecolor) then $
	linecolor = get_foreground()

; check if format is sardines.
; if yes, loose the x axis information
; unless it is given
fmt = get_format(sardines=sd, tokyo=ty)
if (sd and ~keyword_set(last)) or keyword_set(info) then begin
	if ~keyword_set(xtitle) then $
		_xtitle = ' '
	if ~keyword_set(xtickformat) then $
		_xtickformat = ''
	if ~keyword_set(xtickname) then $
		_xtickname = replicate(' ', 60)
endif
if ty and ~keyword_set(first) then begin
	if ~keyword_set(ytitle) then $
		_ytitle = ' '
	if ~keyword_set(ytickformat) then $
		_ytickformat = ''
	if ~keyword_set(ytickname) then $
		_ytickname = replicate(' ', 60)
endif

if ~keyword_set(xticks) then $
	xticks = get_xticks(sjul, fjul, xminor=_xminor)

if keyword_set(xminor) then $
	_xminor = xminor

if n_elements(psym) eq 0 then begin
	load_usersym, /circle
	psym = 8
endif

if ~keyword_set(symsize) then $
	symsize = .75

; set up coordinate system for plot
plot, [0,0], /nodata, position=position, $
	xstyle=xstyle+4, ystyle=ystyle+4, $
	xrange=xrange, yrange=yrange

; get data
xtag = 'juls'
ytag = 'kp_index'
if ~tag_exists(kpi_data, xtag) then begin
	prinfo, 'Parameter '+xtag+' does not exist in KPI_DATA.'
	return
endif
if ~tag_exists(kpi_data, ytag) then begin
	prinfo, 'Parameter '+ytag+' does not exist in KPI_DATA.'
	return
endif
dd = execute('xdata = kpi_data.'+xtag)
dd = execute('ydata = kpi_data.'+ytag)

if keyword_set(rectangle) then begin
	; overplot data
	for i=0L, n_elements(xdata)-1L do begin
		xx = xdata[i]+3.d/24.d*[0.,1.,1.,0.,0.]
		yy = ydata[i]*[0., 0., 1., 1., 0.]
		polyfill, xx, yy, color=get_gray(), noclip=0
		oplot, xx, yy, $
			thick=linethick, color=linecolor, linestyle=linestyle, noclip=0
	endfor
endif else begin
	; overplot data
	for i=0L, n_elements(xdata)-1L do begin
		oplot, replicate(xdata[i]+1.5d/24.d, 2), [0., ydata[i]], $
			thick=linethick, color=linecolor, linestyle=linestyle, noclip=0
		plots, xdata[i]+1.5d/24.d, ydata[i], psym=psym, symsize=symsize, color=linecolor, noclip=0
	endfor
endelse

; overplot axis
plot, [0,0], /nodata, position=position, $
	charthick=charthick, charsize=(keyword_set(info) ? .6 : 1.)*charsize, $ 
	xstyle=xstyle, ystyle=ystyle, xtitle=_xtitle, ytitle=_ytitle, $
	xticks=xticks, xminor=_xminor, $
	xtickformat=_xtickformat, ytickformat=_ytickformat, $
	xtickname=_xtickname, ytickname=_ytickname, ygridstyle=2, yticklen=1., $
	xrange=xrange, yrange=yrange, yminor=2, yticks=yticks, $
	color=get_foreground()

end
