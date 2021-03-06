;+ 
; NAME: 
; GET_DEFAULT_TITLE
; 
; PURPOSE: 
; This function returns a default title for some parameters. 
; 
; CATEGORY: 
; Misc
; 
; CALLING SEQUENCE: 
; GET_DEFAULT_TITLE, Parameter
;
; INPUTS:
; Parameter: A parameter.
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
; Based on Steve Milan's 
; Written by Lasse Clausen, Nov, 24 2009
;-
function get_default_title, parameter

; check input
if n_params() ne 1 then begin
	prinfo, 'Must give Parameter.'
	return, ''
endif

if strcmp(strlowcase(parameter), 'power') then $
	return, 'Power [dB]' $
else if strcmp(strlowcase(parameter), 'lag0power') then $
	return, 'Power [dB]' $
else if strcmp(strlowcase(parameter), 'velocity') then $
	return, textoidl('Velocity [m s^{-1}]') $
else if strcmp(strlowcase(parameter), 'velocity_error') then $
	return, textoidl('\DeltaV [m s^{-1}]') $
else if strcmp(strlowcase(parameter), 'width') then $
	return, textoidl('Spec. Width [m s^{-1}]') $
else if strcmp(strlowcase(parameter), 'phi0') then $
	return, textoidl('\Phi_0 [rad]') $
else if strcmp(strlowcase(parameter), 'elevation') then $
	return, textoidl('Elevation [\circ]') $
else if strcmp(strlowcase(parameter), 'gate') then $
	return, 'Gate [x45 km]' $
else if strcmp(strlowcase(parameter), 'rang') then $
	return, 'Slant range [km]' $
else if strcmp(strlowcase(parameter), 'geog') then $
	return, textoidl('geog. Latitude [\circ]') $
else if strcmp(strlowcase(parameter), 'magn') then $
	return, textoidl('magn. Latitude [\circ]') $
else if strcmp(strlowcase(parameter), 'bx_gse') then $
	return, textoidl('Bx GSE [nT]') $
else if strcmp(strlowcase(parameter), 'by_gse') then $
	return, textoidl('By GSE [nT]') $
else if strcmp(strlowcase(parameter), 'bz_gse') then $
	return, textoidl('Bz GSE [nT]') $
else if strcmp(strlowcase(parameter), 'by_gsm') then $
	return, textoidl('By GSM [nT]') $
else if strcmp(strlowcase(parameter), 'bz_gsm') then $
	return, textoidl('Bz GSM [nT]') $
else if strcmp(strlowcase(parameter), 'bt') then $
	return, textoidl('Bt [nT]') $
else if strcmp(strlowcase(parameter), 'brad') then $
	return, textoidl('Br [nT]') $
else if strcmp(strlowcase(parameter), 'bazm') then $
	return, textoidl('Ba [nT]') $
else if strcmp(strlowcase(parameter), 'bfie') then $
	return, textoidl('Bf [nT]') $
else if strcmp(strlowcase(parameter), 'vx_gse') then $
	return, textoidl('Vx GSE [km s^{-1}]') $
else if strcmp(strlowcase(parameter), 'vy_gse') then $
	return, textoidl('Vy GSE [km s^{-1}]') $
else if strcmp(strlowcase(parameter), 'vz_gse') then $
	return, textoidl('Vz GSE [km s^{-1}]') $
else if strcmp(strlowcase(parameter), 'vy_gsm') then $
	return, textoidl('Vy GSM [km s^{-1}]') $
else if strcmp(strlowcase(parameter), 'vz_gsm') then $
	return, textoidl('Vz GSM [km s^{-1}]') $
else if strcmp(strlowcase(parameter), 'vt') then $
	return, textoidl('Vt [km s^{-1}]') $
else if strcmp(strlowcase(parameter), 'ex_gse') then $
	return, textoidl('Ex GSE [mV m^{-1}]') $
else if strcmp(strlowcase(parameter), 'ey_gse') then $
	return, textoidl('Ey GSE [mV m^{-1}]') $
else if strcmp(strlowcase(parameter), 'ez_gse') then $
	return, textoidl('Ez GSE [mV m^{-1}]') $
else if strcmp(strlowcase(parameter), 'ey_gsm') then $
	return, textoidl('Ey GSM [mV m^{-1}]') $
else if strcmp(strlowcase(parameter), 'ez_gsm') then $
	return, textoidl('Ez GSM [mV m^{-1}]') $
else if strcmp(strlowcase(parameter), 'et') then $
	return, textoidl('Et [mV m^{-1}]') $
else if strcmp(strlowcase(parameter), 'np') then $
	return, textoidl('n [cm^{-3}]') $
else if strcmp(strlowcase(parameter), 'pd') then $
	return, textoidl('pdyn [nPa]') $
else if strcmp(strlowcase(parameter), 'beta') then $
	return, textoidl('\beta') $
else if strcmp(strlowcase(parameter), 'tpr') then $
	return, textoidl('radial T [K]') $
else if strcmp(strlowcase(parameter), 'ma') then $
	return, textoidl('M_{A}') $
else if strcmp(strlowcase(parameter), 'asi') then $
	return, textoidl('Brightness') $
else if strcmp(strlowcase(parameter), 'bx_mag') then $
	return, textoidl('Bx MAG [10^3 nT]') $
else if strcmp(strlowcase(parameter), 'by_mag') then $
	return, textoidl('By MAG [nT]') $
else if strcmp(strlowcase(parameter), 'bz_mag') then $
	return, textoidl('Bz MAG [10^3 nT]') $
else if strcmp(strlowcase(parameter), 'bt_mag') then $
	return, textoidl('Bt [10^3 nT]') $
else if strcmp(strlowcase(parameter), 'cone_angle') then $
	return, textoidl('\theta_{xB} [\circ]') $
else if strcmp(strlowcase(parameter), 'clock_angle') then $
	return, textoidl('\phi [\circ]') $
else if strcmp(strlowcase(parameter), 'tec') then $
	return, textoidl('Total Electron Content [TECU]') $
else $
	prinfo, 'Unknown parameter: '+parameter, /force

return, ''

end
