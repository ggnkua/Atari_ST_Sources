;***************************************************************************
;    CECILE Device Driver
;    Copyright (C) 1999-2006  David Godec  (david.godec@online.fr)
;
;    This program is free software; you can redistribute it and/or modify
;    it under the terms of the GNU General Public License as published by
;    the Free Software Foundation; either version 2 of the License, or
;    (at your option) any later version.
;
;    This program is distributed in the hope that it will be useful,
;    but WITHOUT ANY WARRANTY; without even the implied warranty of
;    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;    GNU General Public License for more details.
;
;    You should have received a copy of the GNU General Public License
;    along with this program; if not, write to the Free Software
;    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA
;
;***************************************************************************

;Opcode 0: UWORD XHGetVersion (void);
;
;Returns the current protocol version. Example: $0119 is Version 1.19 
;(the format is similar to that returned by `Sversion()', but high and low 
;byte are not reversed). This version of the XHDI specification has the 
;version number $0120.

		****
XHGetVersion:
	
	move.l	#$00000120,d0
	rts
		
		****

****************************************************************
