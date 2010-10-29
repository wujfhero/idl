;+ 
; NAME: 
; RT_PLOT_RTI_TITLE
; 
; PURPOSE: 
; This procedure plots a more specific title on the top of a RTI panel.
; 
; CATEGORY: 
; Graphics
; 
; CALLING SEQUENCE: 
; RT_PLOT_RTI_TITLE
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
; BEAM: Set this keyword to the beam number.
;
; FREQ_BAND: Set this keyword to a 2-element vector which holds the frequency pass band.
; 
; BAR: Set this keyword to indicate that the panel areas are calculated by taking
; into account space for a color bar.
;
; WITH_INFO: Set this keyword to leave some extra space on the top for plotting noise
; and frequency info panels.
;
; CHARTHICK: Set this keyword to change the font thickness.
;
; CHARSIZE: Set this keyword to change the font size.
;
; ADDSTR: Set this keyword to an additional string you would like to display in the title.
; 
; EXAMPLE: 
; 
; MODIFICATION HISTORY: 
; Written by Lasse Clausen, Nov, 30 2009
;-
pro rt_plot_rti_title, xmaps, ymaps, xmap, ymap, $
	beam=beam, freq_band=freq_band, bar=bar, with_info=with_info, $
	charsize=charsize, charthick=charthick, addstr=addstr

common rt_data_blk

if n_params() lt 4 then begin
	if ~keyword_set(silent) then $
		prinfo, 'XMAPS, YMAPS, XMAP and YMAP not set, using default.'
	xmaps = 1
	ymaps = 1
	xmap = 0
	ymap = 0
endif

if ~keyword_set(charsize) then $
	charsize = get_charsize(xmaps, ymaps)

if n_elements(beam) eq 0 then $
	beam = rt_info.beam

foreground  = get_foreground()

pos = define_panel(xmaps, ymaps, xmap, ymap, bar=bar, with_info=with_info)

fmt = get_format(sardines=sd)
if sd then $
	ypos = pos[3]-.02 $
else $
	ypos = pos[3]+.01

xyouts, pos[0]+0.01, ypos, $
	'Beam '+string(beam, format='(I02)')+(keyword_set(addstr) ? ' '+addstr : ''), /NORMAL, $
	COLOR=foreground, SIZE=charsize, charthick=charthick

if keyword_set(freq_band) then begin
	xyouts, pos[2]-0.01, ypos, $
		'Freq. '+strjoin(string(freq_band, format='(F4.1)'), '-')+'MHz', $
		/NORMAL, COLOR=foreground, SIZE=charsize, align=1., charthick=charthick
endif
end