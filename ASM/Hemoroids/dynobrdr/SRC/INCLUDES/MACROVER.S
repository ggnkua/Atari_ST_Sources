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

fill_dbra_35: MACRO
	moveq	#10,d1
	dbra	d1,*
	ENDM
fill_dbra_38: MACRO
	moveq	#11,d1
	dbra	d1,*
	ENDM
fill_dbra_41: MACRO
	moveq	#12,d1
	dbra	d1,*
	ENDM
fill_dbra_44: MACRO
	moveq	#13,d1
	dbra	d1,*
	ENDM
fill_dbra_47: MACRO
	moveq	#14,d1
	dbra	d1,*
	ENDM
fill_dbra_50: MACRO
	moveq	#15,d1
	dbra	d1,*
	ENDM
fill_dbra_53: MACRO
	moveq	#16,d1
	dbra	d1,*
	ENDM
fill_dbra_56: MACRO
	moveq	#17,d1
	dbra	d1,*
	ENDM
fill_dbra_59: MACRO
	moveq	#18,d1
	dbra	d1,*
	ENDM
fill_dbra_62: MACRO
	moveq	#19,d1
	dbra	d1,*
	ENDM
fill_dbra_65: MACRO
	moveq	#20,d1
	dbra	d1,*
	ENDM
fill_dbra_68: MACRO
	moveq	#21,d1
	dbra	d1,*
	ENDM
fill_dbra_71: MACRO
	moveq	#22,d1
	dbra	d1,*
	ENDM
fill_dbra_74: MACRO
	moveq	#23,d1
	dbra	d1,*
	ENDM
fill_dbra_77: MACRO
	moveq	#24,d1
	dbra	d1,*
	ENDM
fill_dbra_80: MACRO
	moveq	#25,d1
	dbra	d1,*
	ENDM
fill_dbra_83: MACRO
	moveq	#26,d1
	dbra	d1,*
	ENDM
fill_dbra_86: MACRO
	moveq	#27,d1
	dbra	d1,*
	ENDM
fill_dbra_89: MACRO
	moveq	#28,d1
	dbra	d1,*
	ENDM
fill_dbra_92: MACRO
	moveq	#29,d1
	dbra	d1,*
	ENDM
fill_dbra_95: MACRO
	moveq	#30,d1
	dbra	d1,*
	ENDM
fill_dbra_98: MACRO
	moveq	#31,d1
	dbra	d1,*
	ENDM
fill_dbra_101: MACRO
	moveq	#32,d1
	dbra	d1,*
	ENDM
fill_dbra_104: MACRO
	moveq	#33,d1
	dbra	d1,*
	ENDM
fill_dbra_107: MACRO
	moveq	#34,d1
	dbra	d1,*
	ENDM
fill_dbra_110: MACRO
	moveq	#35,d1
	dbra	d1,*
	ENDM
fill_dbra_113: MACRO
	moveq	#36,d1
	dbra	d1,*
	ENDM
fill_dbra_116: MACRO
	moveq	#37,d1
	dbra	d1,*
	ENDM
fill_dbra_119: MACRO
	moveq	#38,d1
	dbra	d1,*
	ENDM
fill_dbra_122: MACRO
	moveq	#39,d1
	dbra	d1,*
	ENDM
fill_dbra_125: MACRO
	moveq	#40,d1
	dbra	d1,*
	ENDM
fill_dbra_128: MACRO
	moveq	#41,d1
	dbra	d1,*
	ENDM

fill_nop_0: MACRO
	ENDM
fill_nop_1: MACRO
	nop			; [ 1]
	ENDM
fill_nop_2: MACRO
	or.l	d1,d1		; [ 2]
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
	moveq    	#8,d1     		; [ 1]
	lsr.l	d1,d0		; [ 6] 8+2n
	ENDM
fill_nop_8: MACRO
	moveq    	#10,d1     		; [ 1]
	lsr.l	d1,d0		; [ 7] 8+2n
	ENDM
fill_nop_9: MACRO
	moveq    	#12,d1     		; [ 1]
	lsr.l	d1,d0		; [ 8] 8+2n
	ENDM
fill_nop_10: MACRO
	moveq    	#14,d1     		; [ 1]
	lsr.l	d1,d0		; [ 9] 8+2n
	ENDM
fill_nop_11: MACRO
	moveq    	#16,d1     		; [ 1]
	lsr.l	d1,d0		; [10] 8+2n
	ENDM
fill_nop_12: MACRO
	moveq    	#18,d1     		; [ 1]
	lsr.l	d1,d0		; [11] 8+2n
	ENDM
fill_nop_13: MACRO
	moveq    	#20,d1     		; [ 1]
	lsr.l	d1,d0		; [12] 8+2n
	ENDM
fill_nop_14: MACRO
	moveq    	#22,d1     		; [ 1]
	lsr.l	d1,d0		; [13] 8+2n
	ENDM
fill_nop_15: MACRO
	moveq    	#24,d1     		; [ 1]
	lsr.l	d1,d0		; [14] 8+2n
	ENDM
fill_nop_16: MACRO
	moveq    	#26,d1     		; [ 1]
	lsr.l	d1,d0		; [15] 8+2n
	ENDM
fill_nop_17: MACRO
	moveq    	#28,d1     		; [ 1]
	lsr.l	d1,d0		; [16] 8+2n
	ENDM
fill_nop_18: MACRO
	moveq    	#30,d1     		; [ 1]
	lsr.l	d1,d0		; [17] 8+2n
	ENDM
fill_nop_19: MACRO
	moveq    	#32,d1     		; [ 1]
	lsr.l	d1,d0		; [18] 8+2n
	ENDM
fill_nop_20: MACRO
	moveq    	#34,d1     		; [ 1]
	lsr.l	d1,d0		; [19] 8+2n
	ENDM
fill_nop_21: MACRO
	moveq    	#36,d1     		; [ 1]
	lsr.l	d1,d0		; [20] 8+2n
	ENDM
fill_nop_22: MACRO
	moveq    	#38,d1     		; [ 1]
	lsr.l	d1,d0		; [21] 8+2n
	ENDM
fill_nop_23: MACRO
	moveq    	#40,d1     		; [ 1]
	lsr.l	d1,d0		; [22] 8+2n
	ENDM
fill_nop_24: MACRO
	moveq    	#42,d1     		; [ 1]
	lsr.l	d1,d0		; [23] 8+2n
	ENDM
fill_nop_25: MACRO
	moveq    	#44,d1     		; [ 1]
	lsr.l	d1,d0		; [24] 8+2n
	ENDM
fill_nop_26: MACRO
	moveq    	#46,d1     		; [ 1]
	lsr.l	d1,d0		; [25] 8+2n
	ENDM
fill_nop_27: MACRO
	moveq    	#48,d1     		; [ 1]
	lsr.l	d1,d0		; [26] 8+2n
	ENDM
fill_nop_28: MACRO
	moveq    	#50,d1     		; [ 1]
	lsr.l	d1,d0		; [27] 8+2n
	ENDM
fill_nop_29: MACRO
	moveq    	#52,d1     		; [ 1]
	lsr.l	d1,d0		; [28] 8+2n
	ENDM
fill_nop_30: MACRO
	moveq    	#54,d1     		; [ 1]
	lsr.l	d1,d0		; [29] 8+2n
	ENDM
fill_nop_31: MACRO
	moveq    	#56,d1     		; [ 1]
	lsr.l	d1,d0		; [30] 8+2n
	ENDM
fill_nop_32: MACRO
	moveq    	#58,d1     		; [ 1]
	lsr.l	d1,d0		; [31] 8+2n
	ENDM
fill_nop_33: MACRO
	moveq    	#60,d1     		; [ 1]
	lsr.l	d1,d0		; [32] 8+2n
	ENDM
fill_nop_34: MACRO
	moveq    	#62,d1     		; [ 1]
	lsr.l	d1,d0		; [33] 8+2n
	ENDM
fill_nop_35: MACRO
	fill_dbra_35
	ENDM
fill_nop_36: MACRO
	fill_dbra_35
	nop
	ENDM
fill_nop_37: MACRO
	fill_dbra_35
	or.l	d1,d1
	ENDM
fill_nop_38: MACRO
	fill_dbra_38
	ENDM
fill_nop_39: MACRO
	fill_dbra_38
	nop
	ENDM
fill_nop_40: MACRO
	fill_dbra_38
	or.l	d1,d1
	ENDM
fill_nop_41: MACRO
	fill_dbra_41
	ENDM
fill_nop_42: MACRO
	fill_dbra_41
	nop
	ENDM
fill_nop_43: MACRO
	fill_dbra_41
	or.l	d1,d1
	ENDM
fill_nop_44: MACRO
	fill_dbra_44
	ENDM
fill_nop_45: MACRO
	fill_dbra_44
	nop
	ENDM
fill_nop_46: MACRO
	fill_dbra_44
	or.l	d1,d1
	ENDM
fill_nop_47: MACRO
	fill_dbra_47
	ENDM
fill_nop_48: MACRO
	fill_dbra_47
	nop
	ENDM
fill_nop_49: MACRO
	fill_dbra_47
	or.l	d1,d1
	ENDM
fill_nop_50: MACRO
	fill_dbra_50
	ENDM
fill_nop_51: MACRO
	fill_dbra_50
	nop
	ENDM
fill_nop_52: MACRO
	fill_dbra_50
	or.l	d1,d1
	ENDM
fill_nop_53: MACRO
	fill_dbra_53
	ENDM
fill_nop_54: MACRO
	fill_dbra_53
	nop
	ENDM
fill_nop_55: MACRO
	fill_dbra_53
	or.l	d1,d1
	ENDM
fill_nop_56: MACRO
	fill_dbra_56
	ENDM
fill_nop_57: MACRO
	fill_dbra_56
	nop
	ENDM
fill_nop_58: MACRO
	fill_dbra_56
	or.l	d1,d1
	ENDM
fill_nop_59: MACRO
	fill_dbra_59
	ENDM
fill_nop_60: MACRO
	fill_dbra_59
	nop
	ENDM
fill_nop_61: MACRO
	fill_dbra_59
	or.l	d1,d1
	ENDM
fill_nop_62: MACRO
	fill_dbra_62
	ENDM
fill_nop_63: MACRO
	fill_dbra_62
	nop
	ENDM
fill_nop_64: MACRO
	fill_dbra_62
	or.l	d1,d1
	ENDM
fill_nop_65: MACRO
	fill_dbra_65
	ENDM
fill_nop_66: MACRO
	fill_dbra_65
	nop
	ENDM
fill_nop_67: MACRO
	fill_dbra_65
	or.l	d1,d1
	ENDM
fill_nop_68: MACRO
	fill_dbra_68
	ENDM
fill_nop_69: MACRO
	fill_dbra_68
	nop
	ENDM
fill_nop_70: MACRO
	fill_dbra_68
	or.l	d1,d1
	ENDM
fill_nop_71: MACRO
	fill_dbra_71
	ENDM
fill_nop_72: MACRO
	fill_dbra_71
	nop
	ENDM
fill_nop_73: MACRO
	fill_dbra_71
	or.l	d1,d1
	ENDM
fill_nop_74: MACRO
	fill_dbra_74
	ENDM
fill_nop_75: MACRO
	fill_dbra_74
	nop
	ENDM
fill_nop_76: MACRO
	fill_dbra_74
	or.l	d1,d1
	ENDM
fill_nop_77: MACRO
	fill_dbra_77
	ENDM
fill_nop_78: MACRO
	fill_dbra_77
	nop
	ENDM
fill_nop_79: MACRO
	fill_dbra_77
	or.l	d1,d1
	ENDM
fill_nop_80: MACRO
	fill_dbra_80
	ENDM
fill_nop_81: MACRO
	fill_dbra_80
	nop
	ENDM
fill_nop_82: MACRO
	fill_dbra_80
	or.l	d1,d1
	ENDM
fill_nop_83: MACRO
	fill_dbra_83
	ENDM
fill_nop_84: MACRO
	fill_dbra_83
	nop
	ENDM
fill_nop_85: MACRO
	fill_dbra_83
	or.l	d1,d1
	ENDM
fill_nop_86: MACRO
	fill_dbra_86
	ENDM
fill_nop_87: MACRO
	fill_dbra_86
	nop
	ENDM
fill_nop_88: MACRO
	fill_dbra_86
	or.l	d1,d1
	ENDM
fill_nop_89: MACRO
	fill_dbra_89
	ENDM
fill_nop_90: MACRO
	fill_dbra_89
	nop
	ENDM
fill_nop_91: MACRO
	fill_dbra_89
	or.l	d1,d1
	ENDM
fill_nop_92: MACRO
	fill_dbra_92
	ENDM
fill_nop_93: MACRO
	fill_dbra_92
	nop
	ENDM
fill_nop_94: MACRO
	fill_dbra_92
	or.l	d1,d1
	ENDM
fill_nop_95: MACRO
	fill_dbra_95
	ENDM
fill_nop_96: MACRO
	fill_dbra_95
	nop
	ENDM
fill_nop_97: MACRO
	fill_dbra_95
	or.l	d1,d1
	ENDM
fill_nop_98: MACRO
	fill_dbra_98
	ENDM
fill_nop_99: MACRO
	fill_dbra_98
	nop
	ENDM
fill_nop_100: MACRO
	fill_dbra_98
	or.l	d1,d1
	ENDM
fill_nop_101: MACRO
	fill_dbra_101
	ENDM
fill_nop_102: MACRO
	fill_dbra_101
	nop
	ENDM
fill_nop_103: MACRO
	fill_dbra_101
	or.l	d1,d1
	ENDM
fill_nop_104: MACRO
	fill_dbra_104
	ENDM
fill_nop_105: MACRO
	fill_dbra_104
	nop
	ENDM
fill_nop_106: MACRO
	fill_dbra_104
	or.l	d1,d1
	ENDM
fill_nop_107: MACRO
	fill_dbra_107
	ENDM
fill_nop_108: MACRO
	fill_dbra_107
	nop
	ENDM
fill_nop_109: MACRO
	fill_dbra_107
	or.l	d1,d1
	ENDM
fill_nop_110: MACRO
	fill_dbra_110
	ENDM
fill_nop_111: MACRO
	fill_dbra_110
	nop
	ENDM
fill_nop_112: MACRO
	fill_dbra_110
	or.l	d1,d1
	ENDM
fill_nop_113: MACRO
	fill_dbra_113
	ENDM
fill_nop_114: MACRO
	fill_dbra_113
	nop
	ENDM
fill_nop_115: MACRO
	fill_dbra_113
	or.l	d1,d1
	ENDM
fill_nop_116: MACRO
	fill_dbra_116
	ENDM
fill_nop_117: MACRO
	fill_dbra_116
	nop
	ENDM
fill_nop_118: MACRO
	fill_dbra_116
	or.l	d1,d1
	ENDM
fill_nop_119: MACRO
	fill_dbra_119
	ENDM
fill_nop_120: MACRO
	fill_dbra_119
	nop
	ENDM
fill_nop_121: MACRO
	fill_dbra_119
	or.l	d1,d1
	ENDM
fill_nop_122: MACRO
	fill_dbra_122
	ENDM
fill_nop_123: MACRO
	fill_dbra_122
	nop
	ENDM
fill_nop_124: MACRO
	fill_dbra_122
	or.l	d1,d1
	ENDM
fill_nop_125: MACRO
	fill_dbra_125
	ENDM
fill_nop_126: MACRO
	fill_dbra_125
	nop
	ENDM
fill_nop_127: MACRO
	fill_dbra_125
	or.l	d1,d1
	ENDM
fill_nop_128: MACRO
	fill_dbra_128
	ENDM
