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
		
		; extension du pool m‚moire
AddFolders:
		**illegal
		
		move.l	$4f2.w,a0
		move.l	$20(a0),a1	root
		lea	$10(a1),a1
		
		lea	TsrEnd(pc),a2
		move.l	(a2),a3
		move.l	a3,a4
		
		; addition des n chunks de 66 octets
		; (liste chain‚e)
		
		move.w	FolderNum(pc),d0
.foloop		
		lea	66(a3),a3
		move.l	a3,-66(a3)
		move.w	#4,-2(a3)
		
		subq.w	#1,d0
		bgt.s	.foloop
		
		; linkage avec ancienne liste
		
		move.l	a3,(a2)		* tsr end
		lea	-66(a3),a3
		move.l	(a1),(a3)
		move.l	a4,(a1)
		
		rts

		********
