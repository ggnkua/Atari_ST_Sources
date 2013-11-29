*******************************************************************************
*
* This is the assembler source for the standard compose table for CKBD
*   without the NVDI 3 specific extensions. If you don't use NVDI3, you
*   should install this table using the CPX module to avoid the generation
*   of 'bad' characters (e.g. uppercase accents IUEOA »ŒêÀ¡ «Õƒ ∂)
*
*   This table does not reassign the keyboard layout.
*
* Assembler: TurboAss 1.7.x
*
* Ω2/1992, 3/1994, 1/1996 by P. Fellerich
*

               output 'NO_NVDI3.CKB'
*
* default output mode is 'BASIC' which is simple binary without any header
*
               default 6

               >PART 'Defines'
*
* These defines are taken from CKBD.H
*
INQUIRE        equ -1
OFF            equ 0
ON             equ 1
SET            equ 2

DEC_MODE       equ 0
MULTICHAR      equ 2
ORDERINDIFF    equ 0
ORDERSENS      equ 4

ORDER          equ 1
               endpart
               >PART 'CKB_Header'
*
* This is the CKB file header
*
* 1. LONG magic:
id:            dc.b "CKBD"

*
* 2. The name of the table. Maximum 12 chars, must be padded with null bytes
*    to exactly 12 bytes.
*                   '123456789012'
name:          dc.b 'No NVDI 3.x',0 ; Name: exakt 12 Zeichen!!

*
* 3. The offsets to the keyboard mapping and compose tables. If a given table
*    is not present it's offset must be zero.
*
unshift_offset:dc.w 0
shift_offset:  dc.w 0
caps_offset:   dc.w 0
compose_offset:dc.w compose-id

               endpart
               >PART 'Compose Character Tabelle'
*
* COMPOSED CHARACTERS - TABELLE:
*   ST-Charset, without NVDI 3 extension from 192...222(DEC Multinational mode)
* Format is:
*   typedef struct {
*       char    primary;        /* first character plus... */
*       char    secondary;      /* ...second character */
*       char    composed;       /* becomes _composed_char_ ! */
*       char    flags;          /* reserved! (Flags) */
*   } comptab[];
*
               even
compose:
; combination, DEC-Ascii code, Null  ; TOS Ascii or description
               dc.b "++#",0   ;35
               dc.b "aa@",0   ;64
               dc.b "AA@",0
               dc.b "(([",0   ;91
               dc.b "//\",0   ;92
               dc.b "))]",0   ;93
               dc.b "(-{",0   ;123
               dc.b "/^|",0   ;124
               dc.b ")-}",0   ;125
               dc.b "DE",ORDER ;127 DELTA
               dc.b "De",ORDER
               dc.b "C,Ä",0   ;128
               dc.b 'u"Å',0   ;129
               dc.b 'uπÅ',0
               dc.b "e'Ç",0   ;130
               dc.b "a^É",0   ;131
               dc.b 'a"Ñ',0   ;132
               dc.b 'aπÑ',0
               dc.b "a`Ö",0   ;133
               dc.b "a.Ü",0   ;134
               dc.b "a¯Ü",0
               dc.b "c,á",0   ;135
               dc.b "e^à",0   ;136
               dc.b 'e"â',0   ;137
               dc.b 'eπâ',0
               dc.b "e`ä",0   ;138
               dc.b 'i"ã',0   ;139
               dc.b 'iπã',0
               dc.b "i^å",0   ;140
               dc.b "i`ç",0   ;141
               dc.b 'A"é',0   ;142
               dc.b 'Aπé',0
               dc.b "A.è",0   ;143
               dc.b "A¯è",0
               dc.b "E'ê",0   ;144
               dc.b "aeë",ORDER ;145
               dc.b "AEí",ORDER ;146
               dc.b "Aeí",ORDER
               dc.b "o^ì",0   ;147
               dc.b 'o"î',0   ;148
               dc.b 'oπî',0
               dc.b "o`ï",0   ;149
               dc.b "u^ñ",0   ;150
               dc.b "u`ó",0   ;151
               dc.b 'y"ò',0   ;152
               dc.b 'yπò',0
               dc.b 'O"ô',0   ;153
               dc.b 'Oπô',0
               dc.b 'U"ö',0   ;154
               dc.b 'Uπö',0
               dc.b "c/õ",0   ;155
               dc.b "C/õ",0
               dc.b "c|õ",0
               dc.b "C|õ",0
               dc.b "L_ú",0   ;156
               dc.b "L-ú",0
               dc.b "l-ú",0
               dc.b "l_ú",0
               dc.b "Y-ù",0   ;157 Yen
               dc.b "y-ù",0
               dc.b "Y=ù",0
               dc.b "y=ù",0
               dc.b "ssû",0   ;158 German Eszet
               dc.b "f-ü",0   ;159 Florin
               dc.b "a'†",0   ;160
               dc.b "i'°",0   ;161
               dc.b "o'¢",0   ;162
               dc.b "u'£",0   ;163
               dc.b "n~§",0   ;164
               dc.b "N~•",0   ;165
               dc.b "a_¶",0   ;166 a underscore (not NVDI)
               dc.b "a-¶",0
               dc.b "o_ß",0   ;167 o underscore (not NVDI)
               dc.b "o-ß",0
               dc.b "??®",0   ;168
               dc.b "12´",ORDER ;171
               dc.b "14¨",ORDER ;172
               dc.b "!!≠",0   ;173
               dc.b "<<Æ",0   ;174
               dc.b ">>Ø",0   ;175
               dc.b "a~∞",0   ;176
               dc.b "o~±",0   ;177
               dc.b "O/≤",0   ;178
               dc.b "O|≤",0
               dc.b "o/≥",0   ;179
               dc.b "o|≥",0
               dc.b "oe¥",ORDER ;180
               dc.b "OEµ",ORDER ;181
               dc.b "Oeµ",ORDER
               dc.b "A`∂",0   ;182
               dc.b "A~∑",0   ;183
               dc.b "O~∏",0   ;184
               dc.b '" π',0   ;185
               dc.b "` ∫",0   ;186
               dc.b "+ ª",0   ;187
               dc.b "PPº",0   ;188
               dc.b "ppº",0
               dc.b "P|º",0
               dc.b "p|º",0
               dc.b "p/º",0
               dc.b "P/º",0
               dc.b "coΩ",0   ;189
               dc.b "COΩ",0
               dc.b "roæ",0   ;190
               dc.b "ROæ",0
               dc.b "tmø",0   ;191
               dc.b "TMø",0
               dc.b "ij¿",ORDER ;ij ligature (not defined in NVDI 3 mapping)
               dc.b "IJ¡",ORDER ;ij ligature (not defined in NVDI 3 mapping)
               dc.b "Ij¡",ORDER
               dc.b "so›",ORDER ;221
               dc.b "SO›",ORDER
               dc.b "ooﬂ",ORDER ;223
               dc.b "OOﬂ",ORDER
               dc.b "al‡",ORDER ;224 alpha
               dc.b "AL‡",ORDER
               dc.b "be·",ORDER ;225 beta
               dc.b "BE·",ORDER
               dc.b "ga‚",ORDER ;226 GAMMA
               dc.b "GA‚",ORDER
               dc.b "pi„",ORDER ;227 pi
               dc.b "PI„",ORDER
               dc.b "SI‰",ORDER ;228 SIGMA
               dc.b "SS‰",ORDER
               dc.b "siÂ",ORDER ;229 sigma
               dc.b "u/Ê",0   ;230 my
               dc.b "u|Ê",0
               dc.b "myÊ",ORDER
               dc.b "MYÊ",ORDER
               dc.b "taÁ",ORDER ;231 tau
               dc.b "TAÁ",ORDER
               dc.b "phË",ORDER ;232 PHI
               dc.b "PHË",ORDER
               dc.b "O-È",0   ;233 THETA
               dc.b "THÈ",ORDER
               dc.b "thÈ",ORDER
               dc.b "OMÍ",ORDER ;234 OMEGA
               dc.b "omÍ",ORDER
               dc.b "deÎ",ORDER ;235 delta
               dc.b "=-",0   ;240
               dc.b "+-Ò",0   ;241
               dc.b ">-Ú",0   ;242
               dc.b ">_Ú",0
               dc.b ">=Ú",0
               dc.b "<-Û",0   ;243
               dc.b "<_Û",0
               dc.b "<=Û",0
               dc.b ":-ˆ",0   ;246
               dc.b "=~˜",0   ;247
               dc.b "o ¯",0   ;248
               dc.b "* ˘",0   ;249
               dc.b ". ˙",0   ;250
               dc.b "v ˚",0   ;251
               dc.b "n ¸",0   ;252
               dc.b "2 ˝",0   ;253
               dc.b "3 ˛",0   ;254
               dc.b "_ ˇ",0   ;255
               dc.l 0         ;total 157 EintrÑge

COMPTABSIZE    equ (*-compose)/4-1

MAXTABSIZE     equ 256

               if COMPTABSIZE>MAXTABSIZE
               fail 'Compose table too long!!'
               endc

               endpart
               end
