; +======================================================================+
; | VSync routine                                                        |
; +======================================================================+
; | Copyright (c) 2015-2017 Frederic Poeydomenge <dyno@aldabase.com>     |
; +----------------------------------------------------------------------+
; | This program is free software: you can redistribute it and/or modify |
; | it under the terms of the GNU General Public License as published by |
; | the Free Software Foundation, either version 3 of the License, or    |
; | (at your option) any later version.                                  |
; |                                                                      |
; | This program is distributed in the hope that it will be useful,      |
; | but WITHOUT ANY WARRANTY; without even the implied warranty of       |
; | MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the         |
; | GNU General Public License for more details.                         |
; |                                                                      |
; | You should have received a copy of the GNU General Public License    |
; | along with this program. If not, see <http://www.gnu.org/licenses/>. |
; +======================================================================+

;#========================#
;# Wait for Vertical SYNC #
;#========================#

vsync:
	move.w	d0,-(sp)
	move.w	K_NB_VBL.w,d0	; Number of VBL routines
.vsync:	cmp.w	K_NB_VBL.w,d0	; Wait until it has been incremented
	beq.s	.vsync
	move.w	(sp)+,d0
default_rts:
	rts

;#==================================#
;# Dummy VBL & Timer B HBL routines #
;#==================================#

default_vbl:
	bsr.s	call_qvbl		; Call QVBL
	addq.w	#1,K_NB_VBL.w	; Increment number of VBL routines
default_hbl:
	rte

;#========================#
;# Call QVbl-like routine #
;#========================#

call_qvbl:
	movem.l	d0-a6,-(sp)
	move.l	K_QVBL.w,d0
	beq.s	.skip_qvbl
	move.l	d0,a0
	jsr	(a0)
.skip_qvbl:	movem.l	(sp)+,d0-a6
	rts
