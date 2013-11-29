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
		
		; provoque le RESET du bus SCSI !
		
		********
ScReset:
		move.l	a1,-(sp)
		
		move.w	#$8604,a0
		move.w	#$8606,a1
		
		move.w	#NcrInitiatorCommand,(a1)
		move.w	#%10000000,(a0)
		
		moveq	#4,d0
		add.l	$4ba.w,d0
		
		; ca fait un reset hold de ~ 20 mS
.hold_rst
		cmp.l	$4ba.w,d0
		bgt.s	.hold_rst
		
		move.w	#NcrInitiatorCommand,(a1)
		clr.w	(a0)
		
		; laissons les devices reprendre leurs
		; esprits et s'‚brouer ...
		
		moveq	#150,d0	~750 ms
		add.l	$4ba.w,d0
.pause
		cmp.l	$4ba.w,d0
		bgt.s	.pause
		
		move.w	#NcrMode,(a1)
		clr.w	(a0)
		
		move.w	#NcrResetInterrupt,(a1)
		tst.w	(a0)
		tst.w	(a0)
		
		move.w	#$0080,(a1)
		
		moveq	#noErr,d0
		
		move.l	(sp)+,a1
		rts
		
		********
		
********************************************************************
