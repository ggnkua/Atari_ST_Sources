; +======================================================================+
; | Sound routines                                                       |
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

;#====================#
;# Reset YM registers #
;#====================#

reset_ym_registers:
	lea	YM_REGISTER.w,a0
	lea	reset_ym,a2
.ym_ini:	move.w	(a2)+,d0
	bmi.s	.ym_end
	movep.w	d0,(a0)
	bra.s	.ym_ini
.ym_end:	rts

;#=================#
;# Turns sound OFF #
;#=================#

sound_off:
	move.l	#$08000000,YM_REGISTER.w
	move.l	#$09000000,YM_REGISTER.w
	move.l	#$0A000000,YM_REGISTER.w
	rts

;#===================#
;# YM default values #
;#===================#

reset_ym:	dc.w $0000,$0100,$0200,$0300,$0400,$0500
	dc.w $0600,$077F,$0800,$0900,$0A00,$0D00,-1
