;+
; NAME: 
; OMN_MAKE_OMNIEX_FILES
;
; PURPOSE: 
; This procedure reads dailly ONMI data files in HRO format and splits them
; into two files which are used as input to the map potential routines. 
; One file contains the delays in 
; year month day hour minut second dhour dminute
; format, the other the IMF in 
; year month day hour minut second bx by bz
; format.
; The map potential fitting routine (map_addmodel in RST) can be instructed
; to read IMF data and delays from text files. However, we can't use
; OMNI data as is because the IMF in the OMNI files is already lagged.
; Hence after splitting into daily files we must write the delay times
; in one ascii file and the de-delayed imf into a separate one. 
; This procedure does just that.
; The OMNI data should be obtained from
; ftp://nssdcftp.gsfc.nasa.gov/spacecraft_data/omni/high_res_omni/.
; 
; CATEGORY: 
; Input/Output
; 
; CALLING SEQUENCE:
; OMN_MAKE_OMNIEX_FILES, Filename
;
; INPUTS:
; Filename: The name of the file containing the daily OMNI data in HRO format.
;
; KEYWORD PARAMETERS:
; OUTDIR: Set this keyword to the directory in which the daily files will be stored.
;
; EXAMPLE:
;
; MODIFICATION HISTORY:
; Written by Lasse Clausen, 8 Jan, 2010
;-
pro omn_make_omniex_files, filename, outdir=outdir

;- The common format for the 1-min and 5-min OMNI data sets is
;- 
;- Year			        I4	      1995 ... 2006
;- Day			        I4	1 ... 365 or 366
;- Hour			        I3	0 ... 23
;- Minute			        I3	0 ... 59 at start of average
;- ID for IMF spacecraft	        I3	See  footnote D below
;- ID for SW Plasma spacecraft	I3	See  footnote D below
;- # of points in IMF averages	I4
;- # of points in Plasma averages	I4
;- Percent interp		        I4	See  footnote A above
;- Timeshift, sec		        I7
;- RMS, Timeshift		        I7
;- RMS, Phase front normal	        F6.2	See Footnotes E, F below
;- Time btwn observations, sec	I7	DBOT1, See  footnote C above
;- Field magnitude average, nT	F8.2
;- Bx, nT (GSE, GSM)		F8.2
;- By, nT (GSE)		        F8.2
;- Bz, nT (GSE)		        F8.2
;- By, nT (GSM)	                F8.2	Determined from post-shift GSE components
;- Bz, nT (GSM)	                F8.2	Determined from post-shift GSE components
;- RMS SD B scalar, nT	        F8.2	
;- RMS SD field vector, nT	        F8.2	See  footnote E below
;- Flow speed, km/s		F8.1
;- Vx Velocity, km/s, GSE	        F8.1
;- Vy Velocity, km/s, GSE	        F8.1
;- Vz Velocity, km/s, GSE	        F8.1
;- Proton Density, n/cc		F7.2
;- Temperature, K		        F9.0
;- Flow pressure, nPa		F6.2	See  footnote G below		
;- Electric field, mV/m		F7.2	See  footnote G below
;- Plasma beta		        F7.2	See  footnote G below
;- Alfven mach number		F6.1	See  footnote G below
;- X(s/c), GSE, Re		        F8.2
;- Y(s/c), GSE, Re		        F8.2
;- Z(s/c), GSE, Re		        F8.2
;- BSN location, Xgse, Re	        F8.2	BSN = bow shock nose
;- BSN location, Ygse, Re	        F8.2
;- BSN location, Zgse, Re 	        F8.2
;- 
;- AE-index, nT                    I6      See World Data Center for Geomagnetism, Kyoto
;- AL-index, nT                    I6      See World Data Center for Geomagnetism, Kyoto
;- AU-index, nT                    I6      See World Data Center for Geomagnetism, Kyoto
;- SYM/D index, nT                 I6      See World Data Center for Geomagnetism, Kyoto
;- SYM/H index, nT                 I6      See World Data Center for Geomagnetism, Kyoto
;- ASY/D index, nT                 I6      See World Data Center for Geomagnetism, Kyoto
;- ASY/H index, nT                 I6      See World Data Center for Geomagnetism, Kyoto
;- PC(N) index,                    F7.2    See World Data Center for Geomagnetism, Copenhagen

ifiles = file_search(filename, count=cc)
if cc lt 1 then begin
	prinfo, 'No files found: '+filename
	return
endif

fmt = '(2I4,2I3,18X,I7,28X,F8.2,16X,2F8.2)'
year = 0
doy  = 0
hr   = 0
mt   = 0
dt   = 0L
bx   = 0.0
by   = 0.0
bz   = 0.0
ilun = 0
olun_d = 0
olun_i = 0

if ~keyword_set(outdir) then $
	outdir = './'

; test if output dir exists and is writable
if ~file_test(outdir, /dir)then begin
	prinfo, 'OUTDIR does not exist: '+outdir
	return
endif

if ~file_test(outdir, /write)then begin
	prinfo, 'You do not have write permission in OUTDIR: '+outdir
	return
endif

; loop through all files
for i=0, cc-1 do begin

	stem_ofile = file_basename(ifiles[i], '.asc')
	d_filename = outdir+'/'+stem_ofile+'ex_delay.asc'
	i_filename = outdir+'/'+stem_ofile+'ex_imf.asc'

	; open input file
	openr, ilun, ifiles[i], /get_lun
	; open output delay file
	openw, olun_d, d_filename, /get_lun
	; open output imf file
	openw, olun_i, i_filename, /get_lun

	; map fitting does not do 
	; sanity checks on read delay times
	; hence be do not print out
	; delay time into the omniex files
	; if the omni data contains
	; 9999

	; loop through file, only reading the year and the
	; day number
	while ~eof(ilun) do begin

		; read data
		readf, ilun, year, doy, hr, mt, dt, bx, by, bz, $
			format=fmt
	
		if dt eq 999999L then $
			continue
	
		; calculate date of de-delayed imf measurements
		jul = julday(1, doy, year, hr, mt)
		caldat, jul, mn, dy, yr, hr, mt, sc
		ijul = jul - double(dt)/86400.
		caldat, ijul, imn, idy, iyr, ihr, imt, isc
		dhr = dt/3600L
		dmn = (dt - dhr*3600L)/60L
;		dsc = (dt mod 60L)
	
		; print the original time with the delay in one
		printf, olun_d, $
			yr, mn, dy, hr, mt, sc, dhr, dmn, $
			format='(I4,5(" ",I02)," ",I2," ",I3)'
	
		; and the de-delayed time with the IMF in the other file
		printf, olun_i, $
			iyr, imn, idy, ihr, imt, isc, bx, by, bz, $
			format='(I4,5(" ",I02),3(" ",F8.2))'
	
	endwhile

	; close input and last output file and exit
	free_lun, olun_d
	free_lun, olun_i
	free_lun, ilun

	; we need to sort the times
	; in the IMF file because 
	; the times need to be in 
	; ascending order for the
	; fitting routines
	; let the shell do all the hard work
	; -n sorts by string numeric value
	; -t give the separator between fields
	spawn, 'sort -n -t " " '+i_filename+' > '+i_filename+'.tmp'
	file_move, i_filename+'.tmp', i_filename, /overwrite

endfor

end
