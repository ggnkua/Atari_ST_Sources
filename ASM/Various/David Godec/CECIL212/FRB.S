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

		********
		TEXT
		********
		
		; routine d'initialisation du _FRB
CreateFRB:
		moveq	#$0000000f,d0
		moveq	#$fffffff0,d1
		
		lea	TsrEnd(pc),a0
		add.l	(a0),d0
		and.l	d1,d0
		
		lea	_FRB(pc),a2
		move.l	d0,(a2)
		
		add.l	#65536,d0
		move.l	d0,(a0)
		
		rts
		
		********
