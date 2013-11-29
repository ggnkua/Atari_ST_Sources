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

********************************************************************
		section text
********************************************************************
		
		****************
		
		; macros pour le handshaking
		
		; parametres:
		; 1) delai time out (1/200)
		; 2) label time out
		
		****************
		
		; attente de /REQ true

WaitREQ1		MACRO

		move.l	\1,d2
		add.l	$4ba.w,d2
.LoopREQ1\@
		move.w	#NcrBusStatus,(a1)
		move.w	#CBSR_REQ,d0
		and.w	(a0),d0
		bne.s	.OkREQ1\@
		
		cmp.l	$4ba.w,d2
		bgt.s	.LoopREQ1\@
		
		moveq	#scCommErr,d0
		bra	\2
.OkREQ1\@
		moveq	#noErr,d0
		
		ENDM
		
		****************

		; attente de /REQ false

WaitREQ0		MACRO

		move.l	\1,d2
		add.l	$4ba.w,d2
.LoopREQ0\@
		move.w	#NcrBusStatus,(a1)
		move.w	#CBSR_REQ,d0
		and.w	(a0),d0
		beq.s	.OkREQ0\@
		
		cmp.l	$4ba.w,d2
		bgt.s	.LoopREQ0\@
		
		moveq	#scCommErr,d0
		bra	\2
.OkREQ0\@
		moveq	#noErr,d0
		
		ENDM
		
		
		****************
		

********************************************************************
