;+ 
; NAME: 
; PRI 
; 
; PURPOSE: 
; This procedure prints information about the procedure/function
; Routine_name, if such a procedure/function exists. The procedure/function
; must be written in IDL, it will not work on built-in IDL functions not written
; in IDL. If no procedure/function
; if found that matches Routine_name exactly, all procedures/functions which
; have Routine_name as a part of their name are printed.
; 
; CATEGORY: 
; Misc
; 
; CALLING SEQUENCE: 
; PRI, Routine_name
; 
; INPUTS: 
; Routine_name: A string containing the name of the procedure/function
; to query.
; 
; KEYWORD PARAMETERS: 
; EDIT: Set this keyword to open the procedure/function in your favorite
; editor.
;
; USAGE: Set this keyword to a named variable that will contain information
; about the usage of the procedure/function. If this keyword is set
; PRI will not print any information on the sreen.
;
; SOURCE_FILE: Set this keyword to a named variable that will contain
; the full path top the source file of the procedure/function. If this keyword is set
; PRI will not print any information on the sreen.
;
; NO_COMPILE: Set this keyword to prevent PRI from trying to resolving/compiling
; the procedure/function. Bear in mind that PRI only finds compiled 
; procedures/functions.
; 
; EXAMPLE: 
; 
; MODIFICATION HISTORY: 
; Written by Lasse Clausen, Nov, 24 2009
;-
pro pri, routine_name, edit=edit, usage=usage, source_file=source_file, $
	no_compile=no_compile

common user_prefs

; check input
if n_params() lt 1 then begin
	prinfo, 'Must give Routine_name.'
	return
endif
if size(routine_name, /type) ne 7 then begin
	prinfo, 'Routine_name must be of type string.'
	return
endif

editor = get_editor()
; check wether we can open an editor
if keyword_set(edit) then begin
	if strcmp(!version.os, 'windows') then begin
		prinfo, 'EDIT keyword not supported under Windows.'
		edit = !false
	endif
	if strcmp(!version.os, 'linux') then begin
		spawn, 'which '+editor, res
		if strpos(res, 'no '+editor+' in') ne -1 then begin
			prinfo, 'Editor not found.'
			edit = !false
		endif
	endif
endif

; set this up such that no message is printed if any
; of the following keywords are set.
if arg_present(usage) or arg_present(source_file) then $
	donotdisplay = !true $
else $
	donotdisplay = !false

; we'll try and resolve the routine is it is not
; compiled yet
try_compile = !true
if keyword_set(no_compile) then $
	try_compile = !false

; what happens is this:
;
; IDL distinguishes between routines and functions.
; Function return something, routines don't.
; When using the IDL routine RESOLVE_ROUTINE, we'll 
; need to know whether the routine tom resolve
; is a function or a procedure.
; We don't know that, hence be establish an error handler
; and try first for a routine and then for a function
; If both fails, we know that the routines doesn't exist.
; But we don't go home just yet, instead we'll try the
; IDL function ROUTINE_INFO (again with procedure and function)
; and if that fails, we'll just look through all compile
; ruotines to see if we find routines which name contains
; Routine_name.
; 
; If the resolving phase is skipped, because NO_COMPILE is 
; set, we need to find whether it is a function or procedure
; when trying to get the inputs, keywords, etc.

; start off by assuming it is not a function
func = !false
error_count = 0

; try to resolve/compile the routine
; Establish error handler. When errors occur, 
; program control is after this command
catch, error_status

;This statement begins the error handler:  
if error_status ne 0 then begin
;	print, !ERROR_STATE.MSG
	error_count = error_count + 1
	; both routine and function have not worked
	; hence we know no such routine exists.
	; But we'll continue anyway
	if error_count gt 1 then begin
		prinfo, 'Routine "'+routine_name+'" cannot be compiled.'
		catch, /cancel
		try_compile = !false
	endif
	func = !true
endif
if try_compile then $
	; can't handle self-compiling stuff
	if ~strcmp(routine_name,'pri',/fold_case) then $
		resolve_routine, routine_name, is_function=func, /no_recompile
; earse error handler
catch, /cancel

; if routine was compiled, we know
; whether is is function or procedure
; no nedd to go through that again
if ~try_compile then $
	func = !false
error_count = 0

; Establish error handler. When errors occur, 
; program control is after this command
catch, Error_status

;This statement begins the error handler:  
IF Error_status NE 0 THEN BEGIN
;	print, !ERROR_STATE.MSG
	error_count = error_count + 1
	; ROUTINE_INFO failed twice, hence
	; we definitively know it doesn't exist.
	; so we loop through all compile routines and try and find
	; routines with similar names.
	if error_count gt 1 then begin
		help, /routines, /procedures, output=routs
		help, /routines, /functions, output=funcs
		comp_found = !false
		for i=2, n_elements(routs)-1L do begin
			arout = strmid(routs[i], 0, (strpos(routs[i], ' '))[0])
			if strpos(arout, strupcase(routine_name)) ne -1 then begin
				comp_found = !true
				print, 'Similar routine found: ', $
					strmid(routs[i], 0, strpos(routs[i],' '))
			endif
		endfor
		for i=2, n_elements(funcs)-1L do begin
			afunc = strmid(funcs[i], 0, (strpos(funcs[i], ' '))[0])
			if strpos(afunc, strupcase(routine_name)) ne -1 then begin
				comp_found = !true
				print, 'Similar function found: ', $
					strmid(funcs[i], 0, strpos(funcs[i],' '))
			endif
		endfor
		if ~comp_found then begin
			prinfo, 'Cannot find procedure/function: '+routine_name
		endif
		catch, /cancel
		return
	endif
	func = !true
ENDIF
; get info on procedure/function
aa = routine_info(routine_name, /parameter, func=func)

; earse error handler
catch, /cancel
; get source file of procedure/function
bb = routine_info(routine_name, /source, func=func)

; assemble output string
if func then begin
	str_func = 'Result = '
endif else begin
	str_func = ''
endelse
str_op_brack = ''
str_args = ''
str_jner = ''
str_keyw = ''
str_cl_brack = ''

; assemble arguments
if aa.num_args ne 0 then begin
	if func then begin
		str_op_brack = '('
		str_cl_brack = ')'
	endif else begin
		str_op_brack = ', '
		str_cl_brack = ''
	endelse
	str_args = strjoin(aa.args, ', ')
endif

; and keywords
if aa.num_kw_args ne 0 then begin
	tmp = transpose([[aa.kw_args], [aa.kw_args]])
	str_keyw = strjoin(strjoin(tmp, '='), ', ')
	str_jner = ', '
endif

; put together usage string
usage = str_func + strupcase(routine_name) + $
	str_op_brack + str_args + str_jner + str_keyw + str_cl_brack
source_file = bb.path

; open editor if keyword is set
if keyword_set(edit) then begin
	if func then begin
		thingie = 'function'
	endif else begin
		thingie = 'pro'
	endelse
	sep = ','
	regex = ' *'+thingie+' +'+routine_name+' *('+sep+'|$)'
	line = ''
	if ~file_test(source_file) then begin
		prinfo, 'Cannot find source file: '+source_file
		return
	endif
	if ~file_test(source_file, /read) then begin
		prinfo, 'No permission to open source file: '+source_file
		return
	endif
	openr, fin, source_file, /get_lun
	line_no = 0L
	while ~eof(fin) do begin
		readf, fin, line
		line_no += 1L
		if stregex(strlowcase(line), regex) ne -1 then begin
			if strcmp(editor, 'nedit') then $
				line = '-line' $
			else $
				line = ''
			cmd = editor+' '+line+' '+strtrim(string(line_no),2)+' '+source_file+' &'
			spawn, cmd
			break
		endif 
	endwhile
	free_lun, fin
	return
endif

; return if no output is wanted
if donotdisplay then $
	return

; print some information
print, '+---+'
print, (func ? 'Function ' : 'Procedure '), strupcase(routine_name)
print, 'Usage: '
print, '  '+usage
print, 'Source: '
print, '  '+source_file
print, '+---+'

end