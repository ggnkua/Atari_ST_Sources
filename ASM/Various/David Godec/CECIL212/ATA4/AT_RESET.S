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
		
		; commande de Reset des drives ATA
		; (temps total ~300 ms)
		
		********
AtaReset
		move.l	a1,-(sp)
		
		move.w	#$4ba,a1
		
		; bit 'sRST'
		
		lea	IdeDeviceCtrl,a0
		moveq	#%00000100,d0
		move.b	d0,(a0)
		move.b	d0,(a0)
		
		moveq	#5,d0	~25 ms
		add.l	(a1),d0
.w1		cmp.l	(a1),d0
		bgt.s	.w1
		
		; on relache 'sRST'
		
		clr.b	(a0)
		clr.b	(a0)
		
		; petite pause...
		
		moveq	#50,d0	~250 ms
		add.l	(a1),d0
.w2		cmp.l	(a1),d0
		bgt.s	.w2
		
		****
.end		
		moveq	#noErr,d0
		
		move.l	(sp)+,a1
		rts
		
		********
		