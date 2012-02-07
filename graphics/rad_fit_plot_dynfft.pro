;+ 
; NAME: 
; RAD_FIT_PLOT_DYNFFT
; 
; PURPOSE: 
; This procedure plots a dynamic FFT on a page. With title.
; 
; CATEGORY:  
; Graphics
; 
; CALLING SEQUENCE: 
; RAD_FIT_PLOT_DYNFFT
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
; values are 'power', 'velocity', and 'width'. Default is 'power'.
;
; BEAMS: Set this keyword to a scalar or array of beam numbers to plot.
;
; GATES: Set this keyword to a scalar or array of gate numbers to plot.
;
; CHANNEL: Set this keyword to the channel number you want to plot.
;
; SCAN_ID: Set this keyword to the numeric scan id you want to plot.
;
; XRANGE: Set this keyword to change the range of the x axis (in Julian Days).
;
; YRANGE: Set this keyword to change the range of the y axis.
;
; SILENT: Set this keyword to surpress all messages/warnings.
;
; CHARTHICK: Set this keyword to change the font thickness.
;
; CHARSIZE: Set this keyword to change the font size.
;
; FREQ_BAND: Set this keyword to a 2-element vector indicating the
; frequency pass band you wish to plot.
;
; INTERPOLATE: Set this keyword to a time resolution in seconds to interpolate the input
; data.  Interpolation is required to place radar data onto a regular time grid before
; computing the FFT.  If INTERPOLATE is not set, a default value of 5 seconds is used.
; To disable interpolation (useful if data set is already uniform in time), set
; INTERPOLATE = -1.
;
; DETREND: Set this keyword to the degree polynomial to fit and then subtract from each set
; of windowed data.  By default, this is set to DETREND=1 which corresponds to a linear fit/
; detrending.  Set DETREND=0 to remove the average; set DETREND=-1 to disable detrending.
;
; WINDOWLENGTH: Set this keyword to set the length of the time window in seconds over which 
; to compute each FFT.  Default of WINDOWLENGTH = 600 s.
;
; STEPLENGTH: Set this keyword to set the length of the interval between FFT windows.  This valuel defaults to WINDOWLENGTH/2.
;
; MAGNITUDE: Set this keyword to return the unnormalized magnitude of the FFT.
;
; NORMALIZE: Set this keyword to return the normalized magnitude of the FFT.
;
; EXCLUDE: Set this keyword to exclude from plotting data with outside of a specified range.  Keyword should be a two-element vector in the form of EXCLUDE = [minVal, maxVal].  If this keyword is not set, the default value of [-10000, 10000] will be used.
;
; NO_TITLE: Set this keyword to surpress plotting of a title.
;
; DATAOUT: Set to name of variable to hold the data structure generated by the CALC_DYNFFT routine.
;
; COMMON BLOCKS:
; RAD_DATA_BLK: The common block holding radar data.
;
; EXAMPLE: 
; 
; COPYRIGHT:
; MODIFICATION HISTORY: 
; Based on Steve Milan's PLOT_RTI.
; Written by Lasse Clausen, Nov, 24 2009; Nathaniel A. Frissell, 2011
;-
PRO RAD_FIT_PLOT_DYNFFT                 $
    ,date               = date          $
    ,time               = time          $
    ,long               = long          $
    ,param              = param         $
    ,beams              = beams         $
    ,gates              = gates         $
    ,channel            = channel       $
    ,scan_id            = scan_id       $
    ,yrange             = yrange        $
    ,XRANGE             = xRange        $
    ,XSTYLE             = xstyle        $
    ,YSTYLE             = ystyle        $
    ,SCALE              = scale         $
    ,INTERPOLATE        = interpolate   $
    ,WINDOWLENGTH       = windowLength  $
    ,STEPLENGTH         = stepLength    $
    ,DETREND            = detrend       $
    ,NORMALIZE          = normalize     $
    ,exclude            = exclude       $
    ,freq_band          = freq_band     $
    ,silent             = silent        $
    ,charthick          = charthick     $
    ,charsize           = charsize      $
    ,no_title           = no_title      $
    ,NO_TRANSFORM       = no_transform  $
    ,avg_gates          = avg_gates     $
    ,SCORE              = score         $
    ,GAPS               = gaps          $
    ,DATAOUT            = dataOut

common rad_data_blk
bar     = 1
; get index for current data
data_index = rad_fit_get_data_index()
if data_index eq -1 then $
	return

if (*rad_fit_info[data_index]).nrecs eq 0L then begin
	if ~keyword_set(silent) then begin
		prinfo, 'No data in index '+string(data_index)
		rad_fit_info
	endif
	return
endif

IF KEYWORD_SET(score) THEN scale=[0,1]

if ~keyword_set(param) then $
	param = get_parameter()

;if ~is_valid_parameter(param) then begin
;	prinfo, 'Invalid plotting parameter: >'+strjoin(param,'<>')+'<'
;	return
;endif

if ~keyword_set(date) then begin
	if ~keyword_set(silent) then $
		prinfo, 'No DATE given, trying for scan date.'
	caldat, (*rad_fit_data[data_index]).juls[0], month, day, year
	date = year*10000L + month*100L + day
endif

if ~keyword_set(time) then $
	time = [0000,2400]

if n_elements(beams) eq 0 then $
	_beams = rad_get_beam() $
else $
	_beams = beams

if n_elements(gates) eq 0 then $
	_gates = [rad_get_gate()] $
else $
	_gates = [gates] ; ( n_elements(gates) eq 1 ? [gates] : gates )

nbeams = n_elements(_beams)
ngates = (keyword_set(avg_gates) ? 1L : n_elements(_gates))
nparams = n_elements(param)
npanels = max([nbeams, ngates, nparams])

if ngates gt 1 and nbeams gt 1 and ~keyword_set(avg_gates) then begin
	prinfo, 'You cannot plot multiple gates AND multiple beams.'
	return
endif

if ngates gt 1 and nparams gt 1 and ~keyword_set(avg_gates) then begin
	prinfo, 'You cannot plot multiple gates AND multiple parameters.'
	return
endif

if nbeams gt 1 and nparams gt 1 then begin
	prinfo, 'You cannot plot multiple beams AND multiple parameters.'
	return
endif

if nbeams eq 1 and ngates gt 1 then begin
	_beams = replicate(_beams, ngates)
	nbeams = ngates
	npanels = nbeams
endif

if ngates eq 1 and nbeams gt 1 then begin
	_gates = transpose(reform(rebin(_gates, n_elements(_gates)*nbeams, /sample), nbeams, n_elements(_gates)))
	ngates = nbeams
	npanels = nbeams
endif

if ngates eq 1 and nparams gt 1 then begin
	_gates = transpose(reform(rebin(_gates, n_elements(_gates)*nparams, /sample), nparams, n_elements(_gates)))
	ngates = nparams
	npanels = nparams
endif

;if nparams gt 1 then begin
;	if ngates gt 1 or nbeams gt 1 then begin
;		prinfo, 'If multiple params are set, beam and gate must be scalar.'
;		return
;	endif
;	npanels = nparams
;endif

; calculate number of panels per page
xmaps = floor(sqrt(npanels)) > 1
ymaps = ceil(npanels/float(xmaps)) > 1

; take into account format of page
; if landscape, make xmaps > ymaps
fmt = get_format(landscape=ls)
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

; for multiple parameter plot
; always stack them
if nparams gt 1 then begin
	ymaps = npanels
	xmaps = 1
endif

; for plots of less than 4 beams
; always stack them
if npanels lt 4 then begin
	ymaps = npanels
	xmaps = 1
endif

; set charsize of info panels smaller
ichars = (!d.name eq 'X' ? 1. : 1. ) * get_charsize(xmaps > 1, ymaps > 2)

; clear output area
clear_page

; loop through panels
for b=0, npanels-1 do begin

	if nparams gt 1 then begin
		aparam = param[b]
		abeam = _beams[0]
		agate = ( keyword_set(avg_gates) ? _gates[*,b] : _gates[0] )
		if keyword_set(yrange) then ascale = yrange[b*2:b*2+1]

	endif else begin
		aparam = param[0]
		abeam = _beams[b]
		agate = ( keyword_set(avg_gates) ? _gates[*,b] : _gates[b] )
		if keyword_set(yrange) then ascale = yrange
	endelse

        IF KEYWORD_SET(ascale) THEN BEGIN
            IF ascale[0] EQ ascale[1] THEN ascale = 0
        ENDIF

	xmap = b mod xmaps
	ymap = b/xmaps

	first = 0
	if xmap eq 0 then $
		first = 1

	last = 0
	if ymap eq ymaps-1 then $
		last = 1

	; plot an rti panel for each beam
	RAD_FIT_PLOT_DYNFFT_PANEL, xmaps, ymaps, xmap, ymap     $
		,date           = date                          $
                ,time           = time                          $
                ,long           = long                          $
		,param          = aparam                        $
                ,beam           = abeam                         $
                ,gate           = agate                         $
                ,avg_gates      = avg_gates                     $
		,channel        = channel                       $
                ,scan_id        = scan_id                       $
		,freq_band      = freq_band                     $
                ,INTERPOLATE    = interpolate                   $
                ,WINDOWLENGTH   = windowLength                  $
                ,STEPLENGTH     = stepLength                    $
                ,DETREND        = detrend                       $
                ,NORMALIZE      = normalize                     $
                ,XRANGE         = xRange                        $
		,yrange         = ascale                        $
                ,XSTYLE         = xStyle                        $
                ,YSTYLE         = yStyle                        $
                ,exclude        = exclude                       $
                ,silent         = silent                        $
		,charthick      = charthick                     $
                ,charsize       = charsize                      $
		,last           = last                          $
                ,first          = first                         $
                ,bar            = bar                           $
                ,SCALE          = scale                         $
                ,ZRANGEOUT      = zRangeOut                     $
                ,NO_TRANSFORM   = no_transform                  $
                ,DATAOUT        = dataOut                       $
                ,SCORE          = score                         $
                ,GAPS           = gaps                          $
                ,/with_info

        IF ~KEYWORD_SET(no_transform) THEN BEGIN
            IF ~KEYWORD_SET(score) THEN BEGIN
                legend$ = 'FFT Magnitude'
            ENDIF ELSE BEGIN
                legend$ = 'Wave Score'
            ENDELSE
            PLOT_COLORBAR,xmaps,ymaps,xmap,ymap                     $
                    ,LEGEND         = legend$                       $
                    ,SCALE          = zRangeOut                     $
                    ,PARAM          = 'power'                       $
                    ,COLORSTEPS     = GET_NCOLORS                   $
                    ,LEVEL_FORMAT='(F6.2)'                          $
                    ,/WITH_INFO                                     $
                    ,/NO_ROTATE
        ENDIF ELSE BEGIN
            PLOT_COLORBAR,xmaps,ymaps,xmap,ymap                 $
                    ,param              = param                 $
                    ,SCALE              = zRangeOut             $
                    ,LEVEL_FORMAT       = '(F6.0)'              $
                    ,/WITH_INFO
        ENDELSE

	if ~keyword_set(no_title) then $
		rad_fit_plot_dynfft_title, xmaps, ymaps, xmap, ymap, $
			charthick=charthick, charsize=charsize, $
			beam=abeam, gate=agate, /with_info, bar=bar

	if nparams gt 1 then begin
		;only plot tfreq noise panel once
		if b eq 0 then begin
;			if ~keyword_set(no_title) then $
;				rad_fit_plot_tsr_title, xmaps, ymaps, xmap, ymap, $
;					charthick=charthick, charsize=charsize, $
;					freq_band=freq_band, beam=abeam, gate=agate, /with_info
			rad_fit_plot_scan_id_info_panel, xmaps, ymaps, xmap, ymap, bar=bar, $
				date=date, time=time, long=long, $
				charthick=charthick, charsize=ichars, $
				beam=abeam, channel=channel, /with_info, /legend
			rad_fit_plot_tfreq_panel, xmaps, ymaps, xmap, ymap, bar=bar, $
				date=date, time=time, long=long, $
				charthick=charthick, charsize=ichars, $
				beam=abeam, channel=channel, scan_id=scan_id, /info, $
				last=last, first=first
			rad_fit_plot_noise_panel, xmaps, ymaps, xmap, ymap, bar=bar, $
				date=date, time=time, long=long, $
				charthick=charthick, charsize=ichars, $
				beam=abeam, channel=channel, scan_id=scan_id, /info, $
				last=last, first=first
		endif
	endif else begin
;		if ~keyword_set(no_title) then $
;			rad_fit_plot_tsr_title, xmaps, ymaps, xmap, ymap, $
;				charthick=charthick, charsize=charsize, $
;				freq_band=freq_band, beam=abeam, gate=agate, /with_info
		; plot noise and tfreq info panel
		if ymap eq 0 then begin
			rad_fit_plot_scan_id_info_panel, xmaps, ymaps, xmap, ymap, bar=bar, $
				date=date, time=time, long=long, $
				charthick=charthick, charsize=ichars, $
				beam=abeam, channel=channel, /with_info, /legend
			rad_fit_plot_tfreq_panel, xmaps, ymaps, xmap, ymap, bar=bar, $
				date=date, time=time, long=long, $
				charthick=charthick, charsize=ichars, $
				beam=abeam, channel=channel, scan_id=scan_id, /info, $
				last=last, first=first
			rad_fit_plot_noise_panel, xmaps, ymaps, xmap, ymap, bar=bar, $
				date=date, time=time, long=long, $
				charthick=charthick, charsize=ichars, $
				beam=abeam, channel=channel, scan_id=scan_id, /info, $
				last=last, first=first
		endif
	endelse

endfor
fitstr = 'N/A'
if (*rad_fit_info[data_index]).fitex then $
        fitstr = 'fitEX'

if (*rad_fit_info[data_index]).fitacf then $
        fitstr = 'fitACF'

if (*rad_fit_info[data_index]).fit then $
        fitstr = 'fit'

if (*rad_fit_info[data_index]).filtered then $
        filterstr = 'filtered ' $
else $
        filterstr = ''
rdrName$ = STRUPCASE((*rad_fit_info[data_index]).code)+': '+param+' ('+filterstr+fitstr+')'
; plot a title for all panels
IF ~KEYWORD_SET(no_transform) THEN BEGIN
    rad_fit_plot_title, 'Dynamic FFT of', scan_id=scan_id
ENDIF ELSE BEGIN
    tsMax       = MAX(dataOut.windowedTimeSeries,MIN=tsMin)
    subtitle$   = 'Min/Max: [' + NUMSTR(tsMin,1) +', '+ NUMSTR(tsMax,1) +']'
    rad_fit_plot_title, 'Windowed TS of '+rdrName$,subtitle$
ENDELSE

end