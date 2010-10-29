;+ 
; NAME: 
; ACE_SWE_READ
;
; PURPOSE: 
; This procedure reads ACE SWEPAM (particles) data into the variables of the structure ACE_SWE_DATA in
; the common block ACE_DATA_BLK. The time range for which data is read is controled by
; the DATE and TIME keywords.
; 
; CATEGORY: 
; Input/Output
; 
; CALLING SEQUENCE:
; ACE_SWE_READ, Date
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
; ACE_DATA_BLK: The common block holding the currently loaded OMNI data and 
; information about that data.
;
; EXAMPLE:
;
; MODIFICATION HISTORY:
; Based on Steve Milan's READ_FILES.
; Written by Lasse Clausen, Nov, 24 2009
; Changed to 1 minute format, 13 Jan, 2010
;-
pro ace_swe_read, date, time=time, long=long, $
	silent=silent, force=force, $
	filename=filename, filedate=filedate

common ace_data_blk

; set nrecs to zero such that 
; you have a way of checking
; whether data was loaded.
ace_swe_info.nrecs = 0L

; resolution is 64 seconds, hence one day
; has about 1440 data records
NFILERECS = 1440L

if ~keyword_set(filename) then begin
	; check if parameters are given
	if n_params() lt 1 then begin
		prinfo, 'Must give date.'
		return
	endif

	; check if data is already loaded
	if  ~keyword_set(force) then begin
		dloaded = ace_swe_check_loaded(date, time=time, long=long)
		if dloaded then $
			return
	endif
	
	; find files to load
	files = ace_swe_find_files(date, time=time, long=long, file_count=fc)
	if fc eq 0 then begin
		if ~keyword_set(silent) then $
			prinfo, 'No files found: '+format_date(date)+$
				', '+format_time(time)
		return
	endif
	no_delete = !false
endif else begin
	fc = n_elements(filename)
	; ac_h0_swe_20090303_v10.cdf
	for i=0, fc-1 do begin
		if ~file_test(filename[i]) then begin
			prinfo, 'Cannot find file: '+filename[i]
			return
		endif
		if keyword_set(filedate) then $
			date = filedate $
		else begin
			bfile = file_basename(filename[i])
			date = long(strmid(bfile, 10, 8))
		endelse
	endfor
	files = filename
endelse

sfjul, date, time, sjul, fjul, no_d=nd
MAX_RECS = NFILERECS*nd

; init temporary arrays
juls = dblarr(MAX_RECS)
vx_gse = fltarr(MAX_RECS)
vy_gse = fltarr(MAX_RECS)
vz_gse = fltarr(MAX_RECS)
vy_gsm = fltarr(MAX_RECS)
vz_gsm = fltarr(MAX_RECS)
vt = fltarr(MAX_RECS)
tpr = fltarr(MAX_RECS)
rx_gse = fltarr(MAX_RECS)
ry_gse = fltarr(MAX_RECS)
rz_gse = fltarr(MAX_RECS)
ry_gsm = fltarr(MAX_RECS)
rz_gsm = fltarr(MAX_RECS)
rt = fltarr(MAX_RECS)
np = fltarr(MAX_RECS)
pd = fltarr(MAX_RECS)
nrecs = 0L

; read files
for i=0, fc-1 do begin

	if ~keyword_set(silent) then $
		prinfo, 'Reading '+files[i]

	data = cdf_read(files[i], ['Epoch','Np','Vp','Tpr','V_GSE','V_GSM','SC_pos_GSE','SC_pos_GSM'], /silent)

	; exit if all read
	if size(data, /type) ne 8 then $
		continue

	; how much data was read
	tnrecs = n_elements(data.epoch[0,*])
	if tnrecs lt 1L then $
		continue

;	help, nrecs, tnrecs, MAX_RECS
	if tnrecs gt MAX_RECS then $
		tnrecs = MAX_RECS

	juls[nrecs:nrecs+tnrecs-1L] = cdf_epoch2jul(reform(data.epoch[0,0:tnrecs-1L]))
	vx_gse[nrecs:nrecs+tnrecs-1L] = data.v_gse[0,0:tnrecs-1L]
	vy_gse[nrecs:nrecs+tnrecs-1L] = data.v_gse[1,0:tnrecs-1L]
	vz_gse[nrecs:nrecs+tnrecs-1L] = data.v_gse[2,0:tnrecs-1L]
	vy_gsm[nrecs:nrecs+tnrecs-1L] = data.v_gsm[1,0:tnrecs-1L]
	vz_gsm[nrecs:nrecs+tnrecs-1L] = data.v_gsm[2,0:tnrecs-1L]
	vt[nrecs:nrecs+tnrecs-1L] = sqrt(total(data.v_gse[*,0:tnrecs-1L]^2, 1))
	tpr[nrecs:nrecs+tnrecs-1L] = data.tpr[0,0:tnrecs-1L]
	rx_gse[nrecs:nrecs+tnrecs-1L] = data.sc_pos_gse[0,0:tnrecs-1L]
	ry_gse[nrecs:nrecs+tnrecs-1L] = data.sc_pos_gse[1,0:tnrecs-1L]
	rz_gse[nrecs:nrecs+tnrecs-1L] = data.sc_pos_gse[2,0:tnrecs-1L]
	ry_gsm[nrecs:nrecs+tnrecs-1L] = data.sc_pos_gsm[1,0:tnrecs-1L]
	rz_gsm[nrecs:nrecs+tnrecs-1L] = data.sc_pos_gsm[2,0:tnrecs-1L]
	rt[nrecs:nrecs+tnrecs-1L] = sqrt(total(data.sc_pos_gse[*,0:tnrecs-1L]^2, 1))
	np[nrecs:nrecs+tnrecs-1L] = data.np[0,0:tnrecs-1L]
	; Actually use a proton mass that assumes 5% of "protons" are actually aplha particles
	pd[nrecs:nrecs+tnrecs-1L] = ((data.np[0,0:tnrecs-1L]*1E6)*(1.92E-27)*(vt[nrecs:nrecs+tnrecs-1L]*1000.0)^2)/1E-9
	nrecs += tnrecs
	
	; if temporary arrays are too small, warn and break
	if nrecs gt MAX_RECS then begin
		prinfo, 'To many data records in file for initialized array. Truncating.'
		break
	endif

endfor

if nrecs lt 1L then begin
	prinfo, 'No real data read.'
	return
endif

jinds = where(juls ge sjul and juls le fjul, ccc)
if ccc lt 1L then begin
	prinfo, 'No data found between '+format_date(date) +' and '+format_time(time)
	return
endif

; set up temporary structure
tace_swe_data = { $
	juls: dblarr(ccc), $
	vx_gse: fltarr(ccc), $
	vy_gse: fltarr(ccc), $
	vz_gse: fltarr(ccc), $
	vy_gsm: fltarr(ccc), $
	vz_gsm: fltarr(ccc), $
	vt: fltarr(ccc), $
	ex_gse: fltarr(ccc), $
	ey_gse: fltarr(ccc), $
	ez_gse: fltarr(ccc), $
	ey_gsm: fltarr(ccc), $
	ez_gsm: fltarr(ccc), $
	et: fltarr(ccc), $
	tpr: fltarr(ccc), $
	beta: fltarr(ccc), $
	rx_gse: fltarr(ccc), $
	ry_gse: fltarr(ccc), $
	rz_gse: fltarr(ccc), $
	ry_gsm: fltarr(ccc), $
	rz_gsm: fltarr(ccc), $
	rt: fltarr(ccc), $
	np: fltarr(ccc), $
	pd: fltarr(ccc) $
}

; populate structure
tace_swe_data.juls = (juls[0:nrecs-1L])[jinds]
tace_swe_data.vx_gse = (vx_gse[0:nrecs-1L])[jinds]
tace_swe_data.vy_gse = (vy_gse[0:nrecs-1L])[jinds]
tace_swe_data.vz_gse = (vz_gse[0:nrecs-1L])[jinds]
tace_swe_data.vy_gsm = (vy_gsm[0:nrecs-1L])[jinds]
tace_swe_data.vz_gsm = (vz_gsm[0:nrecs-1L])[jinds]
tace_swe_data.vt = (vt[0:nrecs-1L])[jinds]
tace_swe_data.tpr = (tpr[0:nrecs-1L])[jinds]
tace_swe_data.rx_gse = (rx_gse[0:nrecs-1L]/!re)[jinds]
tace_swe_data.ry_gse = (ry_gse[0:nrecs-1L]/!re)[jinds]
tace_swe_data.rz_gse = (rz_gse[0:nrecs-1L]/!re)[jinds]
tace_swe_data.ry_gsm = (ry_gsm[0:nrecs-1L]/!re)[jinds]
tace_swe_data.rz_gsm = (rz_gsm[0:nrecs-1L]/!re)[jinds]
tace_swe_data.rt = (rt[0:nrecs-1L])[jinds]
tace_swe_data.np = (np[0:nrecs-1L])[jinds]
tace_swe_data.pd = (pd[0:nrecs-1L])[jinds]

; find invalid data
inds = where(tace_swe_data.vx_gse eq -1e31, cc)
if cc gt 0L then $
	tace_swe_data.vx_gse[inds] = !values.f_nan
inds = where(tace_swe_data.vy_gse eq -1e31, cc)
if cc gt 0L then $
	tace_swe_data.vy_gse[inds] = !values.f_nan
inds = where(tace_swe_data.vz_gse eq -1e31, cc)
if cc gt 0L then $
	tace_swe_data.vz_gse[inds] = !values.f_nan
inds = where(tace_swe_data.vy_gsm eq -1e31, cc)
if cc gt 0L then $
	tace_swe_data.vy_gsm[inds] = !values.f_nan
inds = where(tace_swe_data.vz_gsm eq -1e31, cc)
if cc gt 0L then $
	tace_swe_data.vz_gsm[inds] = !values.f_nan
inds = where(tace_swe_data.vt eq -1e31, cc)
if cc gt 0L then $
	tace_swe_data.vt[inds] = !values.f_nan
inds = where(tace_swe_data.tpr eq -1e31, cc)
if cc gt 0L then $
	tace_swe_data.tpr[inds] = !values.f_nan
inds = where(tace_swe_data.np lt -1e29, cc)
if cc gt 0L then $
	tace_swe_data.np[inds] = !values.f_nan
inds = where(tace_swe_data.pd lt -1e29, cc)
if cc gt 0L then $
	tace_swe_data.pd[inds] = !values.f_nan

; replace old data structure with new one
ace_swe_data = tace_swe_data

ace_swe_info.sjul = ace_swe_data.juls[0L]
ace_swe_info.fjul = ace_swe_data.juls[ccc-1L]
ace_swe_info.nrecs = ccc

end
