; +======================================================================+
; | Fillers Overscan                                                     |
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
;# Overscan switches #
;#===================#

switch_res_hi_low: MACRO
	move.w	a1,(a1)		; [ 2] Change the resolution to high-res
	nop			; [ 1]
	move.b	d0,(a1)		; [ 2] Get back to low-res
	ENDM

switch_res_hi_low6: MACRO
	move.w	a1,(a1)		; [ 2] Change the resolution to high-res
	or.l	d0,d0		; [ 2]
	move.b	d0,(a1)		; [ 2] Get back to low-res
	ENDM

switch_freq_60_50: MACRO
	move.b	d0,(a0)		; [ 2] Change the display frequency to 60Hz
	move.w	a0,(a0)		; [ 2] Get back to 50Hz
	ENDM

stabilisator: MACRO
	switch_res_hi_low		; [ 5]
	ENDM

;#==================#
;# Top-level macros #
;#==================#

; Value = 1 :  4 nops
;       = 2 :  8 nops
;       = 3 : 12 nops
;       etc...

fill_step4:	MACRO	VALUE
	moveq	#\1,d0		; [1]
	subq.w	#1,d0		; [1*VALUE]
	bne.s	*-2		; [3*(VALUE-1)+2]
	ENDM

; Value = 1 :  5 nops
;       = 2 : 10 nops
;       = 3 : 15 nops
;       etc...

fill_step5:	MACRO	VALUE
	moveq	#\1,d0		; [1]
	subq.l	#1,d0		; [2*VALUE]
	bne.s	*-2		; [3*(VALUE-1)+2]
	ENDM

;#=============#
;# Wait X nops #
;#=============#

fill_nop_1: MACRO
	nop			; [ 1]
	ENDM
fill_nop_2: MACRO
	or.l	d0,d0		; [ 2]
	ENDM
fill_nop_3: MACRO
	lsr.l	#2,d0		; [ 3] 8+2n
	ENDM
fill_nop_4: MACRO
	lsr.l	#4,d0		; [ 4] 8+2n
	ENDM
fill_nop_5: MACRO
	lsr.l	#6,d0		; [ 5] 8+2n
	ENDM
fill_nop_6: MACRO
	lsr.l	#8,d0		; [ 6] 8+2n
	ENDM
fill_nop_7: MACRO
	moveq    	#8,d0     		; [ 1]
	lsr.l	d0,d0		; [ 6] 8+2n
	ENDM
fill_nop_8: MACRO
	moveq    	#10,d0     		; [ 1]
	lsr.l	d0,d0		; [ 7] 8+2n
	ENDM
fill_nop_9: MACRO
	moveq    	#12,d0     		; [ 1]
	lsr.l	d0,d0		; [ 8] 8+2n
	ENDM
fill_nop_10: MACRO
	moveq    	#14,d0     		; [ 1]
	lsr.l	d0,d0		; [ 9] 8+2n
	ENDM
fill_nop_11: MACRO
	moveq    	#16,d0     		; [ 1]
	lsr.l	d0,d0		; [10] 8+2n
	ENDM
fill_nop_12: MACRO
	moveq    	#18,d0     		; [ 1]
	lsr.l	d0,d0		; [11] 8+2n
	ENDM
fill_nop_13: MACRO
	moveq    	#20,d0     		; [ 1]
	lsr.l	d0,d0		; [12] 8+2n
	ENDM
fill_nop_14: MACRO
	moveq    	#22,d0     		; [ 1]
	lsr.l	d0,d0		; [13] 8+2n
	ENDM
fill_nop_15: MACRO
	moveq    	#24,d0     		; [ 1]
	lsr.l	d0,d0		; [14] 8+2n
	ENDM
fill_nop_16: MACRO
	moveq    	#26,d0     		; [ 1]
	lsr.l	d0,d0		; [15] 8+2n
	ENDM
fill_nop_17: MACRO
	moveq    	#28,d0     		; [ 1]
	lsr.l	d0,d0		; [16] 8+2n
	ENDM
fill_nop_18: MACRO
	moveq    	#30,d0     		; [ 1]
	lsr.l	d0,d0		; [17] 8+2n
	ENDM
fill_nop_19: MACRO
	moveq    	#32,d0     		; [ 1]
	lsr.l	d0,d0		; [18] 8+2n
	ENDM
fill_nop_20: MACRO
	moveq    	#34,d0     		; [ 1]
	lsr.l	d0,d0		; [19] 8+2n
	ENDM
fill_nop_21: MACRO
	moveq    	#36,d0     		; [ 1]
	lsr.l	d0,d0		; [20] 8+2n
	ENDM
fill_nop_22: MACRO
	moveq    	#38,d0     		; [ 1]
	lsr.l	d0,d0		; [21] 8+2n
	ENDM
fill_nop_23: MACRO
	moveq    	#40,d0     		; [ 1]
	lsr.l	d0,d0		; [22] 8+2n
	ENDM
fill_nop_24: MACRO
	moveq    	#42,d0     		; [ 1]
	lsr.l	d0,d0		; [23] 8+2n
	ENDM
fill_nop_25: MACRO
	moveq    	#44,d0     		; [ 1]
	lsr.l	d0,d0		; [24] 8+2n
	ENDM
fill_nop_26: MACRO
	moveq    	#46,d0     		; [ 1]
	lsr.l	d0,d0		; [25] 8+2n
	ENDM
fill_nop_27: MACRO
	moveq    	#48,d0     		; [ 1]
	lsr.l	d0,d0		; [26] 8+2n
	ENDM
fill_nop_28: MACRO
	moveq    	#50,d0     		; [ 1]
	lsr.l	d0,d0		; [27] 8+2n
	ENDM
fill_nop_29: MACRO
	moveq    	#52,d0     		; [ 1]
	lsr.l	d0,d0		; [28] 8+2n
	ENDM
fill_nop_30: MACRO
	moveq    	#54,d0     		; [ 1]
	lsr.l	d0,d0		; [29] 8+2n
	ENDM
fill_nop_31: MACRO
	moveq    	#56,d0     		; [ 1]
	lsr.l	d0,d0		; [30] 8+2n
	ENDM
fill_nop_32: MACRO
	moveq    	#58,d0     		; [ 1]
	lsr.l	d0,d0		; [31] 8+2n
	ENDM
fill_nop_33: MACRO
	moveq    	#60,d0     		; [ 1]
	lsr.l	d0,d0		; [32] 8+2n
	ENDM
fill_nop_34: MACRO
	moveq    	#62,d0     		; [ 1]
	lsr.l	d0,d0		; [33] 8+2n
	ENDM
fill_nop_35: MACRO
	fill_step5	7
	ENDM
fill_nop_36: MACRO
	fill_step4	9
	ENDM
fill_nop_37: MACRO
	fill_step4	9
	fill_nop_1
	ENDM
fill_nop_38: MACRO
	fill_step4	9
	fill_nop_2
	ENDM
fill_nop_39: MACRO
	fill_step4	9
	fill_nop_3
	ENDM
fill_nop_40: MACRO
	fill_step5	8
	ENDM
fill_nop_41: MACRO
	fill_step5	8
	fill_nop_1
	ENDM
fill_nop_42: MACRO
	fill_step5	8
	fill_nop_2
	ENDM
fill_nop_43: MACRO
	fill_step5	8
	fill_nop_3
	ENDM
fill_nop_44: MACRO
	fill_step4	11
	ENDM
fill_nop_45: MACRO
	fill_step5	9
	ENDM
fill_nop_46: MACRO
	fill_step5	9
	fill_nop_1
	ENDM
fill_nop_47: MACRO
	fill_step5	9
	fill_nop_2
	ENDM
fill_nop_48: MACRO
	fill_step4	12
	ENDM
fill_nop_49: MACRO
	fill_step4	12
	fill_nop_1
	ENDM
fill_nop_50: MACRO
	fill_step5	10
	ENDM
fill_nop_51: MACRO
	fill_step5	10
	fill_nop_1
	ENDM
fill_nop_52: MACRO
	fill_step4	13
	ENDM
fill_nop_53: MACRO
	fill_step4	13
	fill_nop_1
	ENDM
fill_nop_54: MACRO
	fill_step4	13
	fill_nop_2
	ENDM
fill_nop_55: MACRO
	fill_step5	11
	ENDM
fill_nop_56: MACRO
	fill_step4	14
	ENDM
fill_nop_57: MACRO
	fill_step4	14
	fill_nop_1
	ENDM
fill_nop_58: MACRO
	fill_step4	14
	fill_nop_2
	ENDM
fill_nop_59: MACRO
	fill_step4	14
	fill_nop_3
	ENDM
fill_nop_60: MACRO
	fill_step5	12
	ENDM
fill_nop_61: MACRO
	fill_step5	12
	fill_nop_1
	ENDM
fill_nop_62: MACRO
	fill_step5	12
	fill_nop_2
	ENDM
fill_nop_63: MACRO
	fill_step5	12
	fill_nop_3
	ENDM
fill_nop_64: MACRO
	fill_step4	16
	ENDM
fill_nop_65: MACRO
	fill_step5	13
	ENDM
fill_nop_66: MACRO
	fill_step5	13
	fill_nop_1
	ENDM
fill_nop_67: MACRO
	fill_step5	13
	fill_nop_2
	ENDM
fill_nop_68: MACRO
	fill_step4	17
	ENDM
fill_nop_69: MACRO
	fill_step4	17
	fill_nop_1
	ENDM
fill_nop_70: MACRO
	fill_step5	14
	ENDM
fill_nop_71: MACRO
	fill_step5	14
	fill_nop_1
	ENDM
fill_nop_72: MACRO
	fill_step4	18
	ENDM
fill_nop_73: MACRO
	fill_step4	18
	fill_nop_1
	ENDM
fill_nop_74: MACRO
	fill_step4	18
	fill_nop_2
	ENDM
fill_nop_75: MACRO
	fill_step5	15
	ENDM
fill_nop_76: MACRO
	fill_step4	19
	ENDM
fill_nop_77: MACRO
	fill_step4	19
	fill_nop_1
	ENDM
fill_nop_78: MACRO
	fill_step4	19
	fill_nop_2
	ENDM
fill_nop_79: MACRO
	fill_step4	19
	fill_nop_3
	ENDM
fill_nop_80: MACRO
	fill_step5	16
	ENDM
fill_nop_81: MACRO
	fill_step5	16
	fill_nop_1
	ENDM
fill_nop_82: MACRO
	fill_step5	16
	fill_nop_2
	ENDM
fill_nop_83: MACRO
	fill_step5	16
	fill_nop_3
	ENDM
fill_nop_84: MACRO
	fill_step4	21
	ENDM
fill_nop_85: MACRO
	fill_step5	17
	ENDM
fill_nop_86: MACRO
	fill_step5	17
	fill_nop_1
	ENDM
fill_nop_87: MACRO
	fill_step5	17
	fill_nop_2
	ENDM
fill_nop_88: MACRO
	fill_step4	22
	ENDM
fill_nop_89: MACRO
	fill_step4	22
	fill_nop_1
	ENDM
fill_nop_90: MACRO
	fill_step5	18
	ENDM
fill_nop_91: MACRO
	fill_step5	18
	fill_nop_1
	ENDM
fill_nop_92: MACRO
	fill_step4	23
	ENDM
fill_nop_93: MACRO
	fill_step4	23
	fill_nop_1
	ENDM
fill_nop_94: MACRO
	fill_step4	23
	fill_nop_2
	ENDM
fill_nop_95: MACRO
	fill_step5	19
	ENDM
fill_nop_96: MACRO
	fill_step4	24
	ENDM
fill_nop_97: MACRO
	fill_step4	24
	fill_nop_1
	ENDM
fill_nop_98: MACRO
	fill_step4	24
	fill_nop_2
	ENDM
fill_nop_99: MACRO
	fill_step4	24
	fill_nop_3
	ENDM
fill_nop_100: MACRO
	fill_step5	20
	ENDM
fill_nop_101: MACRO
	fill_step5	20
	fill_nop_1
	ENDM
fill_nop_102: MACRO
	fill_step5	20
	fill_nop_2
	ENDM
fill_nop_103: MACRO
	fill_step5	20
	fill_nop_3
	ENDM
fill_nop_104: MACRO
	fill_step4	26
	ENDM
fill_nop_105: MACRO
	fill_step5	21
	ENDM
fill_nop_106: MACRO
	fill_step5	21
	fill_nop_1
	ENDM
fill_nop_107: MACRO
	fill_step5	21
	fill_nop_2
	ENDM
fill_nop_108: MACRO
	fill_step4	27
	ENDM
fill_nop_109: MACRO
	fill_step4	27
	fill_nop_1
	ENDM
fill_nop_110: MACRO
	fill_step5	22
	ENDM
fill_nop_111: MACRO
	fill_step5	22
	fill_nop_1
	ENDM
fill_nop_112: MACRO
	fill_step4	28
	ENDM
fill_nop_113: MACRO
	fill_step4	28
	fill_nop_1
	ENDM
fill_nop_114: MACRO
	fill_step4	28
	fill_nop_2
	ENDM
fill_nop_115: MACRO
	fill_step5	23
	ENDM
fill_nop_116: MACRO
	fill_step4	29
	ENDM
fill_nop_117: MACRO
	fill_step4	29
	fill_nop_1
	ENDM
fill_nop_118: MACRO
	fill_step4	29
	fill_nop_2
	ENDM
fill_nop_119: MACRO
	fill_step4	29
	fill_nop_3
	ENDM
fill_nop_120: MACRO
	fill_step5	24
	ENDM
fill_nop_121: MACRO
	fill_step5	24
	fill_nop_1
	ENDM
fill_nop_122: MACRO
	fill_step5	24
	fill_nop_2
	ENDM
fill_nop_123: MACRO
	fill_step5	24
	fill_nop_3
	ENDM
fill_nop_124: MACRO
	fill_step4	31
	ENDM
fill_nop_125: MACRO
	fill_step5	25
	ENDM
fill_nop_126: MACRO
	fill_step5	25
	fill_nop_1
	ENDM
fill_nop_127: MACRO
	fill_step5	25
	fill_nop_2
	ENDM
fill_nop_128: MACRO
	fill_step4	32
	ENDM
