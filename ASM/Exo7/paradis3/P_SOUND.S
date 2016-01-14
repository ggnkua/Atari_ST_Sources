; +======================================================================+
; | PARADIS3 - PARALLAX DISTORTER - STNICC 2015                          |
; +----------------------------------------------------------------------+
; | Sample replay routine                                                |
; +======================================================================+
; | Copyright (c) 2015 Frederic Poeydomenge <dyno@aldabase.com>          |
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

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 SECTION TEXT
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

;#===========#
;# Constants #
;#===========#

SOUND_FRAMES  		= 86

SAMPLES_BEFORE_VBL 	= 11			; in PARADIS3.S/P_SCRTXT.S/P_CURVE.S
SAMPLES_DURING_VBL 	= 156			; in P_SYNCSC.S/P_GENCOD.S
SAMPLES_PER_FRAME	= SAMPLES_BEFORE_VBL+SAMPLES_DURING_VBL
						; = 167 (~ 8.35 Khz)
;#=======================#
;# Macro - Sample replay #
;#=======================#

sample_replay:	MACRO
	
	move.l	d7,a3               		; [ 1]
	moveq.l	#0,d1				; [ 1]
	move.b	(a3)+,d1			; [ 2]
	move.l	a3,d7               		; [ 1]

	lsl.w	#3,d1				; [ 4] 8+2n

	add.l	d5,d1				; [ 2]
	move.l	d1,a3				; [ 1]

	move.l	(a3)+,d2			; [ 3]
	move.l	(a3)+,d3			; [ 3]
	movep.l	d2,1440(a1)			; [ 7]
	move.l	d3,1440(a1)			; [ 4] => [29]

	ENDM

;#====================#
;# Reset YM registers #
;#====================#

RESET_YM_REGISTERS:
	lea	YM_REGISTER.w,a0
	lea	reset_ym,a2
ym_ini:	move.w	(a2)+,d0
	bmi.s	ym_end
	movep.w	d0,(a0)
	bra.s	ym_ini
ym_end:	RTS

;#=================#
;# Turns sound OFF #
;#=================#

SOUND_OFF:
	move.l	#$08000000,YM_REGISTER.w
	move.l	#$09000000,YM_REGISTER.w
	move.l	#$0A000000,YM_REGISTER.w
	RTS

;#===================#
;# Init sound buffer #
;#===================#

INIT_SOUND:

	lea	sound_toc,a0
	move.l	a0,sound_toc_pos
	move.l	(a0),sound_table_pos

	move.w	#SOUND_FRAMES,sound_iteration

	RTS

;#======================#
;# Compute sound buffer #
;#======================#

COMPUTE_SOUND:

	add.l	#SAMPLES_DURING_VBL,sound_table_pos

	; Next iteration
	subq.w	#1,sound_iteration
	bne.s	not_end_sample

	; End of the sample
	move.w	#SOUND_FRAMES,sound_iteration
	
	; Load next sample
	move.l	sound_toc_pos,a0
	addq.l	#4,a0
	move.l	(a0),a1
	cmp.l	#0,a1
	bne.s	cs_adr
	; If a1=0, loop table
	lea	sound_toc,a0
cs_adr:	move.l	a0,sound_toc_pos
	move.l	(a0),sound_table_pos

not_end_sample:

	RTS

;#===============#
;# Play a sample #
;#===============#

PLAY_SAMPLE:

	lea	YM_REGISTER.w,a0
	move.l	sound_table_pos,a3
	moveq.l	#0,d1
	move.b	(a3)+,d1
	move.l	a3,sound_table_pos

	lsl.w	#3,d1
	
	lea	volume_table,a3
	add.l	d1,a3
	move.l	(a3)+,d2
	move.l	(a3)+,d3
	movep.l	d2,(a0)
	move.l	d3,(a0)

	RTS

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 SECTION DATA
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

;#===================#
;# YM default values #
;#===================#

reset_ym:		dc.w $0000,$0100,$0200,$0300,$0400,$0500
			dc.w $0600,$077F,$0800,$0900,$0A00,$0D00,-1

;#==============#
;# Volume table #
;#==============#

volume_table:		incbin	INC\SOUND.BIN

;#===================#
;# Music composition #
;#===================#

sound_toc:
			dc.l sample_1,sample_1,sample_1,sample_3
			dc.l sample_1,sample_1,sample_1,sample_2
			dc.l sample_6,sample_6,sample_6,sample_3
			dc.l sample_1,sample_1,sample_6,sample_2
			dc.l 0

;#=========#
;# Samples #
;#=========#

sample_1:		incbin	SOUND\SAMPLE1.SPL
sample_2:		incbin	SOUND\SAMPLE2.SPL
sample_3:		incbin	SOUND\SAMPLE3.SPL
;sample_4:		incbin	SOUND\SAMPLE4.SPL
;sample_5:		incbin	SOUND\SAMPLE5.SPL
sample_6:		incbin	SOUND\SAMPLE6.SPL
;sample_7:		incbin	SOUND\SAMPLE7.SPL
;sample_8:		incbin	SOUND\SAMPLE8.SPL

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 SECTION BSS
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

;#==================#
;# Current position #
;#==================#

sound_toc_pos:		ds.l	1
sound_table_pos:	ds.l	1
sound_iteration:	ds.w	1

;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 SECTION TEXT
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@