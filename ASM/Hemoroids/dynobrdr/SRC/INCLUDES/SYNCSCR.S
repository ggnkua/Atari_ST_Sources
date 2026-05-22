; +======================================================================+
; | 1+5 lines Sync-scroll / Hard-scroll routines                         |
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

;#===================#
;# Setup Sync-scroll #
;#===================#

sync_scroll:

	; Finds corresponding sync-scroll lines combination
	clr.w	d3
	move.l	sync_logical,d0
	move.b	d0,d3		; d3 = lower byte of logical screen address
	add.w	d3,d3		; x2
	add.w	d3,d3		; x4
	lea	sync_table,a1
	lea	(a1,d3.w),a1	; a1 = sync-scroll line combination
	
	; Substract offset from logical screen address
	move.w	(a1)+,d2		; First word = offset to remove
	ext.l	d2		; Extend to long
	sub.l	d2,d0		; Substract offset

	; Set physical screen address
	lsr.l	#8,d0
	move.b	d0,VIDEO_ADR_MID.w
	lsr.l	#8,d0
	move.b	d0,VIDEO_ADR_HIGH.w

	; Store the sync-scroll routines for the 6 lines
	clr.w	d2
	lea	sync_routs,a2
	move.l	full_base_address,a3
	moveq	#6-1,d0
.sync_loop:	move.b	(a1)+,d2
	move.l	(a2,d2.w),(a3)+
	dbra	d0,.sync_loop

	rts

;#===========================================#
;# Sync-line: top image line needed for sync #
;#===========================================#
; After synchronization with the beam, at the end of the first line
; there are 74 - 8 = 66 remaining nops that can be used to open
; the right border.
; Possible routs for this purpose are regular line - 2 (158), regular line (160)
; and right overscan (204).

sync_F158:
	fill_nop_31			; [31]
	switch_freq_60_50		; [ 4] Early right border switch
	fill_nop_14			; [14]
	stabilisator		; [ 5] Stabilisator
	fill_nop_7			; [ 7]
	move.l	(a6)+,a5		; [ 3] Next line
	jmp	(a5)		; [ 2]

sync_F160:
	fill_nop_61			; [61]
	move.l	(a6)+,a5		; [ 3] Next line
	jmp	(a5)		; [ 2]

sync_F204:
	fill_nop_32			; [32]
	switch_freq_60_50		; [ 4] Right border
	fill_nop_13			; [13]
	stabilisator		; [ 5] Stabilisator
	fill_nop_7			; [ 7]
	move.l	(a6)+,a5		; [ 3] Next line
	jmp	(a5)		; [ 2]

;#======================#
;# Sync-scroll routines #
;#======================#

;+---------------+
;| 54 bytes line |
;+---------------+
; (DE activated at 60, deactivated at 168. (168-60)/2 = 54)
;
; If we switch to monochrome at position 40, with the left border not removed,
; we obtain line lenght of 80-26 = 54 bytes, corresponding to the 80 bytes of
; each high resolution line - 26 bytes of left border.
;

sync_L54:
	fill_nop_40			; [40]
	switch_res_hi_low		; [ 5] Switch to monochrome
	fill_nop_78			; [78]
	move.l	(a6)+,a5		; [ 3] Next line
	jmp	(a5)		; [ 2]

;+---------------+
;| 80 bytes line |
;+---------------+
; (DE activated at 8, deactivated at 168. (168-8)/2 = 80)
;
; If we switch to monochrome at position 40, with the left border removed,
; we obtain line lenght of 80 bytes, corresponding to the 80 bytes of
; each high resolution line
;

sync_L80:
	switch_res_hi_low		; [ 5] Left border
	fill_nop_35			; [35]
	switch_res_hi_low		; [ 5] Switch to monochrome
	fill_nop_49			; [49]
	switch_freq_60_50		; [ 4] Right border
	fill_nop_13			; [13]
	stabilisator		; [ 5] Stabilisator
	fill_nop_7			; [ 7]
	move.l	(a6)+,a5		; [ 3] Next line
	jmp	(a5)		; [ 2]

;+--------------------------+
;| Regular line [- 2 bytes] |
;+--------------------------+
; (DE activated at 60, deactivated at 376. (376-60)/2 = 158)
;
; We obtain 158 byte line by switching to 60Hz at position 93 (trying to open
; the right border 1 nop before a full overscan), thus enabling the 60Hz end
; of line detection. The line is shorter by a word.
;

sync_L158:
	fill_nop_93			; [93]
	switch_freq_60_50		; [ 4] Early right border switch
	fill_nop_26			; [26]
	move.l	(a6)+,a5		; [ 3] Next line
	jmp	(a5)		; [ 2]

;+--------------+
;| Regular line |
;+--------------+
; (DE activated at 56, deactivated at 376. (376-56)/2 = 160)
;
; A regular 160 byte line.
;

sync_L160:
	fill_nop_123		; [123]
	move.l	(a6)+,a5		; [  3] Next line
	jmp	(a5)		; [  2]

;+---------------------------+
;| Left overscan [- 2 bytes] |
;+---------------------------+
; (DE activated at 8, deactivated at 376. (376-8)/2 = 184)
;
; We obtain 184 byte line by switching to 60Hz at position 93 (trying to open
; the right border 1 nop before a full overscan), thus enabling the 60Hz end
; of line detection. The line is shorter by a word.
;

sync_L184:
	switch_res_hi_low		; [ 5] Left border
	fill_nop_88			; [88]
	switch_freq_60_50		; [ 4] Early right border switch
	fill_nop_14			; [14]
	stabilisator		; [ 5] Stabilisator
	fill_nop_7			; [ 7]
	move.l	(a6)+,a5		; [ 3] Next line
	jmp	(a5)		; [ 2]

;+---------------+
;| Left overscan |
;+---------------+
; (DE activated at 8, deactivated at 380. (380-8)/2 = 186)
;

sync_L186:
	switch_res_hi_low		; [  5] Left border
	fill_nop_106		; [106]
	stabilisator		; [  5] Stabilisator
	fill_nop_7			; [  7]
	move.l	(a6)+,a5		; [  3] Next line
	jmp	(a5)		; [  2]

;+----------------+
;| Right Overscan |
;+----------------+
; (DE activated at 60, deactivated at 468. (468-60)/2 = 204)
;
; Enable Right Overscan by switching to 60Hz at position 94, overiding
; the 50Hz end-of-useable-line detection, and then returning to 50Hz.
;

sync_L204:
	fill_nop_94			; [94]
	switch_freq_60_50		; [ 4] Right border
	fill_nop_25			; [25]
	move.l	(a6)+,a5		; [ 3] Next line
	jmp	(a5)		; [ 2]

;+-------------------+
;| Complete Overscan |
;+-------------------+
; (DE activated at 8, deactivated at 468. (468-8)/2 = 230)
;

sync_L230:
	switch_res_hi_low		; [ 5] Left border
	fill_nop_89			; [89]
	switch_freq_60_50		; [ 4] Right border
	fill_nop_13			; [13]
	stabilisator		; [ 5] Stabilisator
	fill_nop_7			; [ 7]
	move.l	(a6)+,a5		; [ 3] Next line
	jmp	(a5)		; [ 2]

;#========================#
;# Screen logical address #
;#========================#

sync_logical:	dc.l	0

;#==========================#
;# LUT Sync-scroll routines #
;#==========================#

sync_routs:		dc.l sync_F160, sync_F204, sync_F158
		dc.l sync_L54,  sync_L80,  sync_L158, sync_L160
		dc.l sync_L184, sync_L186, sync_L204, sync_L230

;#===================#
;# Sync-scroll table #
;#===================#

sync_table:		dc.b $3,$00,0,12,12,20,20,28	; Offset   0 :  -768, 160,  54,  54, 158, 158, 184
		dc.b $3,$02,0,12,12,20,20,32	; Offset   2 :  -770, 160,  54,  54, 158, 158, 186
		dc.b $3,$04,0,12,12,20,24,32	; Offset   4 :  -772, 160,  54,  54, 158, 160, 186
		dc.b $3,$06,0,12,12,24,24,32	; Offset   6 :  -774, 160,  54,  54, 160, 160, 186
		dc.b $4,$08,0,20,20,28,32,32	; Offset   8 : -1032, 160, 158, 158, 184, 186, 186
		dc.b $4,$0A,0,20,20,32,32,32	; Offset  10 : -1034, 160, 158, 158, 186, 186, 186
		dc.b $4,$0C,0,12,20,36,40,40	; Offset  12 : -1036, 160,  54, 158, 204, 230, 230
		dc.b $3,$0E,0,12,12,12,40,40	; Offset  14 :  -782, 160,  54,  54,  54, 230, 230
		dc.b $4,$10,4,12,28,28,28,40	; Offset  16 : -1040, 204,  54, 184, 184, 184, 230
		dc.b $4,$12,0,12,28,28,40,40	; Offset  18 : -1042, 160,  54, 184, 184, 230, 230
		dc.b $3,$14,0,12,12,20,20,36	; Offset  20 :  -788, 160,  54,  54, 158, 158, 204
		dc.b $2,$16,0,12,12,12,12,20	; Offset  22 :  -534, 160,  54,  54,  54,  54, 158
		dc.b $2,$18,0,12,12,12,12,24	; Offset  24 :  -536, 160,  54,  54,  54,  54, 160
		dc.b $3,$1A,0,12,12,20,28,28	; Offset  26 :  -794, 160,  54,  54, 158, 184, 184
		dc.b $3,$1C,0,12,12,20,28,32	; Offset  28 :  -796, 160,  54,  54, 158, 184, 186
		dc.b $3,$1E,0,12,12,20,32,32	; Offset  30 :  -798, 160,  54,  54, 158, 186, 186
		dc.b $3,$20,0,12,12,24,32,32	; Offset  32 :  -800, 160,  54,  54, 160, 186, 186
		dc.b $4,$22,0,20,28,28,32,32	; Offset  34 : -1058, 160, 158, 184, 184, 186, 186
		dc.b $4,$24,0,20,28,32,32,32	; Offset  36 : -1060, 160, 158, 184, 186, 186, 186
		dc.b $4,$26,0,12,20,40,40,40	; Offset  38 : -1062, 160,  54, 158, 230, 230, 230
		dc.b $3,$28,0,12,12,16,40,40	; Offset  40 :  -808, 160,  54,  54,  80, 230, 230
		dc.b $4,$2A,4,16,28,28,28,40	; Offset  42 : -1066, 204,  80, 184, 184, 184, 230
		dc.b $4,$2C,0,16,28,28,40,40	; Offset  44 : -1068, 160,  80, 184, 184, 230, 230
		dc.b $3,$2E,0,12,12,20,20,40	; Offset  46 :  -814, 160,  54,  54, 158, 158, 230
		dc.b $2,$30,0,12,12,12,12,28	; Offset  48 :  -560, 160,  54,  54,  54,  54, 184
		dc.b $2,$32,0,12,12,12,12,32	; Offset  50 :  -562, 160,  54,  54,  54,  54, 186
		dc.b $3,$34,0,12,12,28,28,28	; Offset  52 :  -820, 160,  54,  54, 184, 184, 184
		dc.b $3,$36,0,12,12,28,28,32	; Offset  54 :  -822, 160,  54,  54, 184, 184, 186
		dc.b $3,$38,0,12,12,28,32,32	; Offset  56 :  -824, 160,  54,  54, 184, 186, 186
		dc.b $3,$3A,0,12,12,32,32,32	; Offset  58 :  -826, 160,  54,  54, 186, 186, 186
		dc.b $4,$3C,0,28,28,28,32,32	; Offset  60 : -1084, 160, 184, 184, 184, 186, 186
		dc.b $4,$3E,0,28,28,32,32,32	; Offset  62 : -1086, 160, 184, 184, 186, 186, 186
		dc.b $4,$40,0,12,28,40,40,40	; Offset  64 : -1088, 160,  54, 184, 230, 230, 230
		dc.b $3,$42,0,12,12,20,36,36	; Offset  66 :  -834, 160,  54,  54, 158, 204, 204
		dc.b $2,$44,0,12,12,12,12,36	; Offset  68 :  -580, 160,  54,  54,  54,  54, 204
		dc.b $4,$46,0,20,20,20,40,40	; Offset  70 : -1094, 160, 158, 158, 158, 230, 230
		dc.b $3,$48,0,12,12,20,28,40	; Offset  72 :  -840, 160,  54,  54, 158, 184, 230
		dc.b $2,$4A,0,12,12,12,16,28	; Offset  74 :  -586, 160,  54,  54,  54,  80, 184
		dc.b $2,$4C,0,12,12,12,16,32	; Offset  76 :  -588, 160,  54,  54,  54,  80, 186
		dc.b $3,$4E,0,12,16,28,28,28	; Offset  78 :  -846, 160,  54,  80, 184, 184, 184
		dc.b $3,$50,0,12,16,28,28,32	; Offset  80 :  -848, 160,  54,  80, 184, 184, 186
		dc.b $3,$52,0,12,16,28,32,32	; Offset  82 :  -850, 160,  54,  80, 184, 186, 186
		dc.b $3,$54,0,12,16,32,32,32	; Offset  84 :  -852, 160,  54,  80, 186, 186, 186
		dc.b $3,$56,0,12,24,24,24,24	; Offset  86 :  -854, 160,  54, 160, 160, 160, 160
		dc.b $4,$58,4,16,28,28,40,40	; Offset  88 : -1112, 204,  80, 184, 184, 230, 230
		dc.b $4,$5A,0,16,28,40,40,40	; Offset  90 : -1114, 160,  80, 184, 230, 230, 230
		dc.b $3,$5C,0,12,12,20,36,40	; Offset  92 :  -860, 160,  54,  54, 158, 204, 230
		dc.b $2,$5E,0,12,12,12,12,40	; Offset  94 :  -606, 160,  54,  54,  54,  54, 230
		dc.b $4,$60,0,20,20,28,40,40	; Offset  96 : -1120, 160, 158, 158, 184, 230, 230
		dc.b $3,$62,0,12,12,28,28,40	; Offset  98 :  -866, 160,  54,  54, 184, 184, 230
		dc.b $2,$64,0,12,12,16,16,28	; Offset 100 :  -612, 160,  54,  54,  80,  80, 184
		dc.b $2,$66,0,12,12,16,16,32	; Offset 102 :  -614, 160,  54,  54,  80,  80, 186
		dc.b $3,$68,0,12,20,20,20,28	; Offset 104 :  -872, 160,  54, 158, 158, 158, 184
		dc.b $3,$6A,0,12,20,20,20,32	; Offset 106 :  -874, 160,  54, 158, 158, 158, 186
		dc.b $3,$6C,0,12,20,20,24,32	; Offset 108 :  -876, 160,  54, 158, 158, 160, 186
		dc.b $3,$6E,0,12,20,24,24,32	; Offset 110 :  -878, 160,  54, 158, 160, 160, 186
		dc.b $3,$70,0,12,12,36,36,36	; Offset 112 :  -880, 160,  54,  54, 204, 204, 204
		dc.b $4,$72,4,20,20,20,40,40	; Offset 114 : -1138, 204, 158, 158, 158, 230, 230
		dc.b $4,$74,0,20,20,36,40,40	; Offset 116 : -1140, 160, 158, 158, 204, 230, 230
		dc.b $3,$76,0,12,12,20,40,40	; Offset 118 :  -886, 160,  54,  54, 158, 230, 230
		dc.b $2,$78,0,12,12,12,16,40	; Offset 120 :  -632, 160,  54,  54,  54,  80, 230
		dc.b $4,$7A,0,20,28,28,40,40	; Offset 122 : -1146, 160, 158, 184, 184, 230, 230
		dc.b $3,$7C,0,12,16,28,28,40	; Offset 124 :  -892, 160,  54,  80, 184, 184, 230
		dc.b $2,$7E,0,12,12,12,20,20	; Offset 126 :  -638, 160,  54,  54,  54, 158, 158
		dc.b $2,$80,0,12,12,12,20,24	; Offset 128 :  -640, 160,  54,  54,  54, 158, 160
		dc.b $2,$82,0,12,12,12,24,24	; Offset 130 :  -642, 160,  54,  54,  54, 160, 160
		dc.b $3,$84,0,12,20,20,28,32	; Offset 132 :  -900, 160,  54, 158, 158, 184, 186
		dc.b $3,$86,0,12,20,20,32,32	; Offset 134 :  -902, 160,  54, 158, 158, 186, 186
		dc.b $3,$88,0,12,20,24,32,32	; Offset 136 :  -904, 160,  54, 158, 160, 186, 186
		dc.b $3,$8A,0,12,12,36,36,40	; Offset 138 :  -906, 160,  54,  54, 204, 204, 230
		dc.b $4,$8C,4,20,20,28,40,40	; Offset 140 : -1164, 204, 158, 158, 184, 230, 230
		dc.b $4,$8E,0,20,20,40,40,40	; Offset 142 : -1166, 160, 158, 158, 230, 230, 230
		dc.b $3,$90,0,12,12,28,40,40	; Offset 144 :  -912, 160,  54,  54, 184, 230, 230
		dc.b $2,$92,0,12,12,16,16,40	; Offset 146 :  -658, 160,  54,  54,  80,  80, 230
		dc.b $4,$94,0,28,28,28,40,40	; Offset 148 : -1172, 160, 184, 184, 184, 230, 230
		dc.b $3,$96,0,12,20,20,20,40	; Offset 150 :  -918, 160,  54, 158, 158, 158, 230
		dc.b $2,$98,0,12,12,12,20,28	; Offset 152 :  -664, 160,  54,  54,  54, 158, 184
		dc.b $2,$9A,0,12,12,12,20,32	; Offset 154 :  -666, 160,  54,  54,  54, 158, 186
		dc.b $2,$9C,0,12,12,12,24,32	; Offset 156 :  -668, 160,  54,  54,  54, 160, 186
		dc.b $3,$9E,0,12,20,28,28,32	; Offset 158 :  -926, 160,  54, 158, 184, 184, 186
		dc.b $3,$A0,0,12,20,28,32,32	; Offset 160 :  -928, 160,  54, 158, 184, 186, 186
		dc.b $3,$A2,0,12,20,32,32,32	; Offset 162 :  -930, 160,  54, 158, 186, 186, 186
		dc.b $3,$A4,0,12,12,36,40,40	; Offset 164 :  -932, 160,  54,  54, 204, 230, 230
		dc.b $4,$A6,4,20,28,28,40,40	; Offset 166 : -1190, 204, 158, 184, 184, 230, 230
		dc.b $4,$A8,0,20,28,40,40,40	; Offset 168 : -1192, 160, 158, 184, 230, 230, 230
		dc.b $3,$AA,0,12,16,28,40,40	; Offset 170 :  -938, 160,  54,  80, 184, 230, 230
		dc.b $2,$AC,0,12,12,12,20,36	; Offset 172 :  -684, 160,  54,  54,  54, 158, 204
		dc.b $1,$AE,0,12,12,12,12,12	; Offset 174 :  -430, 160,  54,  54,  54,  54,  54
		dc.b $3,$B0,0,12,20,20,28,40	; Offset 176 :  -944, 160,  54, 158, 158, 184, 230
		dc.b $2,$B2,0,12,12,12,28,28	; Offset 178 :  -690, 160,  54,  54,  54, 184, 184
		dc.b $2,$B4,0,12,12,12,28,32	; Offset 180 :  -692, 160,  54,  54,  54, 184, 186
		dc.b $2,$B6,0,12,12,12,32,32	; Offset 182 :  -694, 160,  54,  54,  54, 186, 186
		dc.b $3,$B8,0,12,28,28,28,32	; Offset 184 :  -952, 160,  54, 184, 184, 184, 186
		dc.b $3,$BA,0,12,28,28,32,32	; Offset 186 :  -954, 160,  54, 184, 184, 186, 186
		dc.b $3,$BC,0,12,28,32,32,32	; Offset 188 :  -956, 160,  54, 184, 186, 186, 186
		dc.b $3,$BE,0,12,12,40,40,40	; Offset 190 :  -958, 160,  54,  54, 230, 230, 230
		dc.b $3,$C0,0,24,24,24,24,24	; Offset 192 :  -960, 160, 160, 160, 160, 160, 160
		dc.b $4,$C2,0,28,28,40,40,40	; Offset 194 : -1218, 160, 184, 184, 230, 230, 230
		dc.b $3,$C4,0,12,20,20,36,40	; Offset 196 :  -964, 160,  54, 158, 158, 204, 230
		dc.b $2,$C6,0,12,12,12,20,40	; Offset 198 :  -710, 160,  54,  54,  54, 158, 230
		dc.b $1,$C8,0,12,12,12,12,16	; Offset 200 :  -456, 160,  54,  54,  54,  54,  80
		dc.b $3,$CA,0,12,20,28,28,40	; Offset 202 :  -970, 160,  54, 158, 184, 184, 230
		dc.b $2,$CC,0,12,12,16,28,28	; Offset 204 :  -716, 160,  54,  54,  80, 184, 184
		dc.b $2,$CE,0,12,12,16,28,32	; Offset 206 :  -718, 160,  54,  54,  80, 184, 186
		dc.b $2,$D0,0,12,12,16,32,32	; Offset 208 :  -720, 160,  54,  54,  80, 186, 186
		dc.b $3,$D2,0,16,28,28,28,32	; Offset 210 :  -978, 160,  80, 184, 184, 184, 186
		dc.b $3,$D4,0,16,28,28,32,32	; Offset 212 :  -980, 160,  80, 184, 184, 186, 186
		dc.b $3,$D6,0,16,28,32,32,32	; Offset 214 :  -982, 160,  80, 184, 186, 186, 186
		dc.b $3,$D8,0,12,16,40,40,40	; Offset 216 :  -984, 160,  54,  80, 230, 230, 230
		dc.b $2,$DA,0,12,12,12,36,36	; Offset 218 :  -730, 160,  54,  54,  54, 204, 204
		dc.b $3,$DC,4,12,20,20,28,40	; Offset 220 :  -988, 204,  54, 158, 158, 184, 230
		dc.b $3,$DE,0,12,20,20,40,40	; Offset 222 :  -990, 160,  54, 158, 158, 230, 230
		dc.b $2,$E0,0,12,12,12,28,40	; Offset 224 :  -736, 160,  54,  54,  54, 184, 230
		dc.b $1,$E2,0,12,12,12,16,16	; Offset 226 :  -482, 160,  54,  54,  54,  80,  80
		dc.b $3,$E4,0,12,28,28,28,40	; Offset 228 :  -996, 160,  54, 184, 184, 184, 230
		dc.b $2,$E6,0,12,12,20,20,20	; Offset 230 :  -742, 160,  54,  54, 158, 158, 158
		dc.b $2,$E8,0,12,12,20,20,24	; Offset 232 :  -744, 160,  54,  54, 158, 158, 160
		dc.b $2,$EA,0,12,12,20,24,24	; Offset 234 :  -746, 160,  54,  54, 158, 160, 160
		dc.b $2,$EC,0,12,12,24,24,24	; Offset 236 :  -748, 160,  54,  54, 160, 160, 160
		dc.b $3,$EE,0,20,20,20,32,32	; Offset 238 : -1006, 160, 158, 158, 158, 186, 186
		dc.b $3,$F0,0,20,20,24,32,32	; Offset 240 : -1008, 160, 158, 158, 160, 186, 186
		dc.b $3,$F2,0,12,20,36,36,40	; Offset 242 : -1010, 160,  54, 158, 204, 204, 230
		dc.b $2,$F4,0,12,12,12,36,40	; Offset 244 :  -756, 160,  54,  54,  54, 204, 230
		dc.b $3,$F6,4,12,20,28,28,40	; Offset 246 : -1014, 204,  54, 158, 184, 184, 230
		dc.b $3,$F8,0,12,20,28,40,40	; Offset 248 : -1016, 160,  54, 158, 184, 230, 230
		dc.b $2,$FA,0,12,12,16,28,40	; Offset 250 :  -762, 160,  54,  54,  80, 184, 230
		dc.b $1,$FC,0,12,12,16,16,16	; Offset 252 :  -508, 160,  54,  54,  80,  80,  80
		dc.b $3,$FE,0,16,28,28,28,40	; Offset 254 : -1022, 160,  80, 184, 184, 184, 230
