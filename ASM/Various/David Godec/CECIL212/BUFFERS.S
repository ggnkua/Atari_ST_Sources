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
		
		; structure d'un BCB
		
		rsreset
b_link		rs.l	1
b_bufdrv		rs.w	1
b_buftyp		rs.w	1
b_bufrec		rs.w	1
b_dirty		rs.w	1
b_dmd		rs.l	1
b_bufr		rs.l	1
		
		; routine de cr‚ation des buffers
		; data/fat de gemdos
CreateBuffers:
		; taille fixe de 16Ko (max)
		; d'abord les descripteurs (20 octets)
		; et les buffers derriere...

		move.l	TsrEnd(pc),a0	; d‚but descripteurs
		move.w	BufNumFat(pc),d0
		move.w	BufNumData(pc),d1

		move.w	d0,d2
		add.w	d1,d2
		mulu.w	#20,d2
		lea	(a0,d2.l),a1	; d‚but buffers
		
		; liste pour fats
		
		move.l	a0,$4b2.w
.nxtfat		
		move.w	#-1,b_bufdrv(a0)
		move.w	#0,b_buftyp(a0)
		clr.w	b_bufrec(a0)
		clr.w	b_dirty(a0)
		clr.l	b_dmd(a0)
		move.l	a1,b_bufr(a0)
		add.w	#16384,a1
		lea	20(a0),a0
		
		subq.w	#1,d0
		beq.s	.lasfat
		move.l	a0,b_link-20(a0)
		bra.s	.nxtfat
.lasfat		
		clr.l	b_link-20(a0)
		
		; liste pour data
		
		move.l	a0,$4b6.w
.nxtdat		
		move.w	#-1,b_bufdrv(a0)
		move.w	#2,b_buftyp(a0)
		clr.w	b_bufrec(a0)
		clr.w	b_dirty(a0)
		clr.l	b_dmd(a0)
		move.l	a1,b_bufr(a0)
		add.w	#16384,a1
		lea	20(a0),a0
		
		subq.w	#1,d1
		beq.s	.lasdat
		move.l	a0,b_link-20(a0)
		bra.s	.nxtdat
.lasdat
		clr.l	b_link-20(a0)
		
		lea	TsrEnd(pc),a2
		move.l	a1,(a2)
		
		rts
		
		********
