;+ 
; NAME: 
; THE_FGM_PLOT_PANEL
;
; PURPOSE: 
; The procedure plots a panel of Themis FGM data.
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE:  
; THE_FGM_PLOT_PANEL
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
; PARAM: Set this keyword to specify the parameter to plot. Allowable
; values are 'bx_gse','by_gse','bz_gse','by_gsm','bz_gsm','bt'.
;
; COORDS: Set this to GSM or GSE.
;
; BAR: Set this keyword to allow for space right of the panel for a colorbar.
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
; FIRST: Set this keyword to indicate that this panel is the first panel in
; a ROW of plots. That will force Y axis labels.
;
; LAST: Set this keyword to indicate that this is the last panel in a column,
; hence XTITLE and XTICKNAMES will be set.
;
; WITH_INFO: Set this keyword to leave some extra space on the top for plotting noise
; and frequency info panels.
;
; INFO: Set this keyword to plot the panel above a panel which position has been
; defined using DEFINE_PANEL(XMAPS, YMAP, XMAP, YMAP, /WITH_INFO).
;
; EXAMPLE:
; 
; MODIFICATION HISTORY: 
; Written by: Lasse Clausen, 2009.
;-
pro the_fgm_plot_panel, xmaps, ymaps, xmap, ymap, $
	date=date, time=time, long=long, $
	probe=probe, param=param, yrange=yrange, bar=bar, $
	silent=silent, coords=coords, $
	charthick=charthick, charsize=charsize, psym=psym, symsize=symsize, $ 
	linestyle=linestyle, linecolor=linecolor, linethick=linethick, $
	xstyle=xstyle, ystyle=ystyle, xtitle=xtitle, ytitle=ytitle, $
	xticks=xticks, xminor=xminor, yticks=yticks, yminor=yminor, $
	xtickformat=xtickformat, ytickformat=ytickformat, $
	xtickname=xtickname, ytickname=ytickname, $
	position=position, title=title, $
	last=last, first=first, with_info=with_info, info=info

common the_data_blk

if ~keyword_set(probe) then begin
	if ~keyword_set(silent) then $
		prinfo, 'probe not set, using A.'
	probe = 'a'
endif

_probe = strlowcase(probe)
inds = where(_probe ne 'a' and _probe ne 'b' and _probe ne 'c' and _probe ne 'd' and _probe ne 'e', cc)
if cc gt 0l then begin
	prinfo, 'probe must be a, b, c, d or e'
	print, _probe[inds]
	return
endif

if ~keyword_set(coords) then $
	coords = get_coordinates()
_coords = strupcase(coords)

if _coords ne 'GSE' and _coords ne 'GSM' then begin
	prinfo, 'Coordinate system must be GSE or GSM, using GSE.'
	coords = 'GSE'
endif

num_probe = byte(_probe) - (byte('a'))[0]
tnum_probe = num_probe
nprobe = n_elements(num_probe)
for p=0, n_elements(tnum_probe)-1 do begin
	if the_fgm_info[tnum_probe[p]].nrecs eq 0L then begin
		prinfo, 'No data loaded for probe '+_probe[p]
		if nprobe eq 1 then $
			return
		num_probe = num_probe[where(num_probe ne tnum_probe[p], nprobe)]
	endif
endfor
if nprobe gt 1 then begin
	prinfo, 'probe must be scalar.'
	return
endif

if the_fgm_info[num_probe[0]].nrecs eq 0L then begin
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

if ~keyword_set(date) then begin
	caldat, (*the_fgm_data[num_probe[0]]).juls[0], month, day, year
	date = year*10000L + month*100L + day
endif

if ~keyword_set(time) then $
	time = [0000,2400]

if ~keyword_set(param) then $
	param = 'bx_gse'

if ~is_valid_parameter(param) then begin
	prinfo, 'Invalid plotting parameter: '+param
	return
endif

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
	_ytitle = get_default_title(param) $
else $
	_ytitle = ytitle

if ~keyword_set(ytickformat) then $
	_ytickformat = '' $
else $
	_ytickformat = ytickformat

if ~keyword_set(ytickname) then $
	_ytickname = '' $
else $
	_ytickname = ytickname

if keyword_set(info) then begin
	position = define_panel(xmaps, ymaps, xmap, ymap, bar=bar, /with_info)
	position = [position[0], position[3]+.05, $
		position[2], position[3]+.1]
endif

if ~keyword_set(position) then $
	position = define_panel(xmaps, ymaps, xmap, ymap, bar=bar, with_info=with_info)

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

if n_elements(yrange) eq 0 then $
	yrange = get_default_range(param)

if ~keyword_set(charsize) then $
	charsize = get_charsize(xmaps, ymaps)

if ~keyword_set(linethick) then $
	linethick = 1.

if ~keyword_set(linecolor) then $
	linecolor = the_color(num_probe[0])

if ~keyword_set(xticks) then $
	xticks = get_xticks(sjul, fjul, xminor=_xminor)

if keyword_set(xminor) then $
	_xminor = xminor

if n_elements(xstyle) eq 0 then $
	xstyle = 1

; get data
xtag = 'juls'
ytag = param
struc = (*the_fgm_data[num_probe[0]])
if ~tag_exists(struc, xtag) then begin
	prinfo, 'Parameter '+xtag+' does not exist in THE_FGM_DATA.'
	return
endif
if ~tag_exists(struc, ytag) then begin
	prinfo, 'Parameter '+ytag+' does not exist in THE_FGM_DATA.'
	return
endif
dd = execute('xdata = struc.'+xtag)
dd = execute('ydata = struc.'+ytag)

; set up coordinate system for plot
plot, xdata, ydata, /nodata, position=position, $
	charthick=charthick, charsize=charsize, $ 
	xstyle=xstyle, ystyle=ystyle, xtitle=_xtitle, ytitle=_ytitle, $
	xticks=xticks, xminor=_xminor, yticks=yticks, yminor=yminor, $
	xtickformat=_xtickformat, ytickformat=_ytickformat, $
	xrange=xrange, yrange=yrange, $
	ytickname=_ytickname, xtickname=_xtickname, $
	color=get_foreground(), title=title

; overplot data
oplot, xdata, ydata, $
	thick=linethick, color=linecolor, linestyle=linestyle, psym=psym, symsize=symsize

if strmatch(param,'[vb][xyz]_gs[em]') and !y.crange[0] lt 0. and !y.crange[1] gt 0. then $
	oplot, !x.crange, [0,0], linestyle=2, color=get_gray()

end