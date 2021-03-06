;+ 
; NAME: 
; ASI_PLOT_KEOGRAM_PANEL 
; 
; PURPOSE: 
; This procedure plots a keogram of the currently loaded All-Sky Imager data
; in a panel.
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE: 
; ASI_PLOT_KEOGRAM_PANEL
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
; DATE: A scalar giving the date of the image to plot,
; in YYYYMMDD format.
;
; TIME: A scalar giving the time of the image to plot, in HHII format.
;
; LONG: Set this keyword to indicate that the TIME value is in HHIISS
; format rather than HHII format.
;
; SCALE: Set this keyword to a 2-element vector which contains the 
; upper and lower limit of the data range.
;
; SILENT: Set this keyword to surpress warnings but not error messages.
;
; CHARTHICK: Set this keyword to change the font thickness.
;
; CHARSIZE: Set this keyword to change the font size.
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
; XRANGE: Set this keyword to change the range of the x axis.
;
; YRANGE: Set this keyword to change the range of the y axis.
;
; XTICKFORMAT: Set this keyword to change the formatting of the time fopr the x axis.
;
; YTICKFORMAT: Set this keyword to change the formatting of the y axis values.
;
; XTICKNAME: Set this keyword to an array of strings to put on the major tickmarks of the x axis.
;
; YTICKNAME: Set this keyword to an array of strings to put on the major tickmarks of the x axis.
;
; POSITION: Set this keyword to a 4-element vector of normalized coordinates 
; if you want to override the internal
; positioning calculations.
;
; BAR: Set this keyword to allow for space right of the panel for a colorbar.
;
; FIRST: Set this keyword to indicate that this panel is the first panel in
; a ROW of plots. That will force Y axis labels.
;
; LAST: Set this keyword to indicate that this is the last panel in a column,
; hence XTITLE and XTICKNAMES will be set.
;
; WITH_INFO: Set this keyword to leave some extra space on the top for plotting noise
; and frequency info panels. Of course, this keyword only takes
; effect if you do not use the position keyword.
;
; NO_TITLE: If this keyword is set, the panel size will be calculated without 
; leaving space for a big title on the page. Of course, this keyword only takes
; effect if you do not use the position keyword.
; 
; EXAMPLE: 
; 
; COPYRIGHT:
; Non-Commercial Purpose License
; Copyright © November 14, 2006 by Virginia Polytechnic Institute and State University
; All rights reserved.
; Virginia Polytechnic Institute and State University (Virginia Tech) owns the DaViT
; software and its associated documentation (“Software”). You should carefully read the
; following terms and conditions before using this software. Your use of this Software
; indicates your acceptance of this license agreement and all terms and conditions.
; You are hereby licensed to use the Software for Non-Commercial Purpose only. Non-
; Commercial Purpose means the use of the Software solely for research. Non-
; Commercial Purpose excludes, without limitation, any use of the Software, as part of, or
; in any way in connection with a product or service which is sold, offered for sale,
; licensed, leased, loaned, or rented. Permission to use, copy, modify, and distribute this
; compilation for Non-Commercial Purpose is hereby granted without fee, subject to the
; following terms of this license.
; Copies and Modifications
; You must include the above copyright notice and this license on any copy or modification
; of this compilation. Each time you redistribute this Software, the recipient automatically
; receives a license to copy, distribute or modify the Software subject to these terms and
; conditions. You may not impose any further restrictions on this Software or any
; derivative works beyond those restrictions herein.
; You agree to use your best efforts to provide Virginia Polytechnic Institute and State
; University (Virginia Tech) with any modifications containing improvements or
; extensions and hereby grant Virginia Tech a perpetual, royalty-free license to use and
; distribute such modifications under the terms of this license. You agree to notify
; Virginia Tech of any inquiries you have for commercial use of the Software and/or its
; modifications and further agree to negotiate in good faith with Virginia Tech to license
; your modifications for commercial purposes. Notices, modifications, and questions may
; be directed by e-mail to Stephen Cammer at cammer@vbi.vt.edu.
; Commercial Use
; If you desire to use the software for profit-making or commercial purposes, you agree to
; negotiate in good faith a license with Virginia Tech prior to such profit-making or
; commercial use. Virginia Tech shall have no obligation to grant such license to you, and
; may grant exclusive or non-exclusive licenses to others. You may contact Stephen
; Cammer at email address cammer@vbi.vt.edu to discuss commercial use.
; Governing Law
; This agreement shall be governed by the laws of the Commonwealth of Virginia.
; Disclaimer of Warranty
; Because this software is licensed free of charge, there is no warranty for the program.
; Virginia Tech makes no warranty or representation that the operation of the software in
; this compilation will be error-free, and Virginia Tech is under no obligation to provide
; any services, by way of maintenance, update, or otherwise.
; THIS SOFTWARE AND THE ACCOMPANYING FILES ARE LICENSED “AS IS”
; AND WITHOUT WARRANTIES AS TO PERFORMANCE OR
; MERCHANTABILITY OR ANY OTHER WARRANTIES WHETHER EXPRESSED
; OR IMPLIED. NO WARRANTY OF FITNESS FOR A PARTICULAR PURPOSE IS
; OFFERED. THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF
; THE PROGRAM IS WITH YOU. SHOULD THE PROGRAM PROVE DEFECTIVE,
; YOU ASSUME THE COST OF ALL NECESSARY SERVICING, REPAIR OR
; CORRECTION.
; Limitation of Liability
; IN NO EVENT WILL VIRGINIA TECH, OR ANY OTHER PARTY WHO MAY
; MODIFY AND/OR REDISTRIBUTE THE PRORAM AS PERMITTED ABOVE, BE
; LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL,
; INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR
; INABILITY TO USE THE PROGRAM (INCLUDING BUT NOT LIMITED TO LOSS
; OF DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED
; BY YOU OR THIRD PARTIES OR A FAILURE OF THE PROGRAM TO OPERATE
; WITH ANY OTHER PROGRAMS), EVEN IF VIRGINIA TECH OR OTHER PARTY
; HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
; Use of Name
; Users will not use the name of the Virginia Polytechnic Institute and State University nor
; any adaptation thereof in any publicity or advertising, without the prior written consent
; from Virginia Tech in each case.
; Export License
; Export of this software from the United States may require a specific license from the
; United States Government. It is the responsibility of any person or organization
; contemplating export to obtain such a license before exporting.
;
; MODIFICATION HISTORY: 
; Written by Lasse Clausen, Nov, 30 2009
;-
pro asi_plot_keogram_panel, xmaps, ymaps, xmap, ymap, $
	date=date, time=time, long=long, $
	scale=scale, silent=silent, $
	charthick=charthick, charsize=charsize, $ 
	xstyle=xstyle, ystyle=ystyle, xtitle=xtitle, ytitle=ytitle, $
	xrange=xrange, yrange=yrange, xticks=xticks, yticks=yticks, $
	xminor=xminor, yminor=yminor, $
	ytickformat=ytickformat, $
	xtickname=xtickname, ytickname=ytickname, position=position, $
	last=last, first=first, bar=bar, with_info=with_info, no_title=no_title, no_plot=no_plot

common asi_data_blk

if asi_info.nrecs eq 0L then begin
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
	caldat, asi_data.juls[0], month, day, year
	date = year*10000L + month*100L + day
endif

if ~keyword_set(time) then $
	time = [0,2400]

sfjul, date, time, sjul, fjul, long=long

if ~keyword_set(xrange) then $
	xrange = [sjul,fjul]

if ~keyword_set(position) then $
	position = define_panel(xmaps, ymaps, xmap, ymap, bar=bar, with_info=with_info, no_title=no_title)

if ~keyword_set(scale) then $
	scale = get_default_range('asi')

if ~keyword_set(xstyle) then $
	xstyle = 1

if ~keyword_set(ystyle) then $
	ystyle = 1

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
	_ytitle = 'South         North' $
else $
	_ytitle = ytitle

if ~keyword_set(ytickname) then $
	_ytickname = replicate(' ', 60) $
else $
	_ytickname = ytickname

if ~keyword_set(charsize) then $
	charsize = get_charsize(xmaps, ymaps)

if ~keyword_set(xticks) then $
	xticks = get_xticks(sjul, fjul, xminor=_xminor)

if keyword_set(xminor) then $
	_xminor = xminor

; check if format is sardines.
; if yes, loose the x axis information
; unless it isgiven
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

; set up coordinate system for plot
;plot, [0,0], /nodata, position=position, $
;	charthick=charthick, charsize=charsize, $ 
;	xstyle=xstyle, ystyle=ystyle, xtitle=_xtitle, ytitle=_ytitle, $
;	xtickformat=xtickformat, ytickformat=ytickformat, $
;	xtickname=_xtickname, ytickname=_ytickname, $
;	xrange=xrange, yrange=yrange, $
;	color=get_foreground()

bottom = get_bottom()
ncolors = get_ncolors()
color = get_foreground()

; get data
xtag = 'juls'
ytag = 'images'
if ~tag_exists(asi_data, xtag) then begin
	prinfo, 'Parameter '+xtag+' does not exist in ASI_DATA.'
	return
endif
if ~tag_exists(asi_data, ytag) then begin
	prinfo, 'Parameter '+ytag+' does not exist in ASI_DATA.'
	return
endif
dd = execute('xdata = asi_data.'+xtag)
dd = execute('ydata = asi_data.'+ytag)

jinds = where(xdata ge sjul and xdata le fjul, cc)
if cc eq 0L then begin
	prinfo, 'No images found for interval '+format_time(time)
	return
endif

sz = size(ydata, /dim)
xsize = sz[1]
ysize = sz[2]

if ~keyword_set(yrange) then $
	yrange = [0,ysize]

yaxisdata = findgen(ysize+1)
yinds = where(yaxisdata ge yrange[0] and yaxisdata le yrange[1], ycc)
if cc eq 0L then begin
	prinfo, 'No pixels found for yaxis interval '+format_time(yrange)
	return
endif

image = float(reform(ydata[jinds[0L:cc-2L],xsize/2,yinds[0L:ycc-2L]]))

draw_image, image, xdata[jinds[0L:cc-1L]], yaxisdata[yinds[0L:ycc-1L]], range=scale, $
	bottom=bottom, ncolors=ncolors, position=position, $
	charthick=charthick, charsize=charsize, $ 
	xstyle=xstyle, ystyle=ystyle, xtitle=_xtitle, ytitle=_ytitle, $
	xticks=xticks, xminor=_xminor, yticks=yticks, yminor=yminor, $
	xtickformat=_xtickformat, ytickformat=_ytickformat, $
	xtickname=_xtickname, ytickname=_ytickname, $
	xrange=xrange, yrange=yrange, $
	color=color, no_plot=no_plot

;stop
end

