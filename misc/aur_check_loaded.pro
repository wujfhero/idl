;+ 
; NAME: 
; AUR_CHECK_LOADED
;
; PURPOSE: 
; This function checks whether AU/AL/AE/AO index data for the chosen time interval is
; already loaded.
; 
; CATEGORY: 
; Input/Output
; 
; CALLING SEQUENCE:
; Result = AUR_CHECK_LOADED(Date)
;
; INPUTS:
; Date: The date of which to read data. Can be a scalar in YYYYMMDD format or
; a 2-element vector in YYYYMMDD format.
;
; KEYWORD PARAMETERS:
; TIME: The time range for which to read data. Must be a 2-element vector in 
; HHII format, or HHIISS format if the LONG keyword is set. If TIME is not set
; the default value [0000,2400] is assumed.
;
; LONG: Set this keyword to indicate that the Time value is in HHIISS
; format rather than HHII format.
;
; SILENT: Set this keyword to surpress warnings but not error messages.
;
; PROCEDURE:
; If Date is a scalar
; and Time[0] < Time[1], the interval stretches from Time[0] on Date to Time[1] 
; on Date. If Time[0] > Time[1], the interval stretches from Time[0] on Date to
; Time[1] on the day after Date. If Date is a two element vector, the interval
; stretches from Time[0] on Date[0] to Time[1] on Date[1].
;
; COMMON BLOCKS:
; AUR_DATA_BLK: The common block holding the currently loaded index data and 
; information about that data.
;
; EXAMPLE:
;
; MODIFICATION HISTORY:
; Written by Lasse Clausen, Nov, 30 2009
;-
function aur_check_loaded, date, time=time, long=long, $
	silent=silent

common aur_data_blk

; check if parameters are given
if n_params() lt 1 then begin
	prinfo, 'Must give date.'
	return, !false
endif

; set deault time if neccessary
if ~keyword_set(time) then $
	time = [0000,2400]

; convert input date and time to julian day numbers
sfjul, date, time, sjul, fjul, long=long

; check if any records are in the common block
if aur_info.nrecs eq 0L then $
	return, !false

;- give 3 hours lee way
if aur_info.sjul gt sjul+3.d/24.d then $
	return, !false

if aur_info.fjul lt fjul-3.d/24.d then $
	return, !false

if ~keyword_set(silent) then $
	prinfo, 'Data already loaded, skipping.'

return, !true

end
