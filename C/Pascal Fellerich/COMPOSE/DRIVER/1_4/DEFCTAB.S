               >PART 'KBD: Tabellen & Daten'
; DATEN FEST
clicksound:    dc.b $00,$3B,$01,$00,$02,$00,$03,$00
               dc.b $04,$00,$05,$00,$06,$00,$09,$00
               dc.b $0A,$00,$07,$FE,$08,$10,$0D,$03
               dc.b $0B,$80,$0C,$01,$FF,$00

bellsound:     dc.b $00,$34,$01,$00,$02,$00,$03,$00
               dc.b $04,$00,$05,$00,$06,$00,$07,$FE
               dc.b $08,$10,$09,$00,$0A,$00,$0B,$00
               dc.b $0C,$10,$0D,$09,$FF,$00

*
* Deadkey: welche Zeichen sind als TOT deklariert?
*
dead_default:                           ;(max 15 chars + 1 Nullterm)
               dc.b """","`","'","^","|","~",0,0
               dc.b 0,0,0,0,0,0,0,0
dead_onoff:    dc.w 1
Dead_enabletab:
               ds.b 256       ;256 bytes

*
* COMPOSED CHARACTERS - TABELLE:
*
* Format ist:
*   typedef struct {
*       char    primary;        /* erster Buchstabe plus... */
*       char    secondary;      /* ...zweiter Buchstabe */
*       char    composed;       /* ergibt _composed_ ! */
*       char    flags;          /* div. Flags, reserved! */
*   } comptab[];
*
*
* FLAGS: damit sind verschiedene Angaben mîglich
*   - order sensitiveness
*
               even
comptab:
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
; dc.b "ij¿",0  ;ij ligature not defined in NVDI 3 mapping
; dc.b "IJ¡",0  ;ij ligature not defined in NVDI 3 mapping
; dc.b "Ij¡",0
;************ NVDI 3 FontMap new chars
               dc.b "A^¿",0   ;192 (NOT ij)
               dc.b "A'¡",0   ;193
               dc.b "E^¬",0   ;194
               dc.b 'E"√',0   ;195
               dc.b 'Eπ√',0   ;195
               dc.b "E`ƒ",0   ;196
               dc.b "I^≈",0   ;197
               dc.b 'I"∆',0   ;198
               dc.b 'Iπ∆',0   ;198
               dc.b "I`«",0   ;199
               dc.b "I'»",0   ;200
               dc.b "O^…",0   ;201
               dc.b "O` ",0   ;202
               dc.b "O'À",0   ;203
               dc.b "U^Ã",0   ;204
               dc.b "U`Õ",0   ;205
               dc.b "U'Œ",0   ;206
               dc.b ",,œ",0   ;207
               dc.b "``–",0   ;208
               dc.b "''—",0   ;209
               dc.b ", “",0   ;210
               dc.b "' ”",0   ;211
               dc.b "< ‘",0   ;212
               dc.b "> ’",0   ;213
               dc.b "- ÷",0   ;214 dash medium
               dc.b "_ ◊",0   ;215 dash long
               dc.b "Ptÿ",ORDER ;216 Peseta sign
               dc.b "PTÿ",ORDER
               dc.b "ptÿ",ORDER
               dc.b "upŸ",ORDER ;217
               dc.b "UPŸ",ORDER
               dc.b "dn⁄",ORDER ;218
               dc.b "DN⁄",ORDER
               dc.b "rt€",ORDER ;219
               dc.b "RT€",ORDER
               dc.b "lt‹",ORDER ;220
               dc.b "LT‹",ORDER
               dc.b "so›",ORDER ;221
               dc.b "SO›",ORDER
               dc.b "%oﬁ",0   ;222
               dc.b "%.ﬁ",0
;************ Normale FontMap
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
               dc.l 0         ;total 193 EintrÑge

COMPTABSIZE    equ (*-comptab)/4-1

MAXTABSIZE     equ 256

               if COMPTABSIZE>MAXTABSIZE
               fail 'Composetab zu lang.'
               endc

*
* Platz fÅr weitere Tastaturtabellen:
*

tab_unshift:   ds.b 128
tab_shift:     ds.b 128
tab_caps:      ds.b 128
tab_compose:   ds.l MAXTABSIZE ;1 KByte sollte reichen ( 256 Kombinationen )
emstop:        dc.l 0

* Saveptr - AREA!
               ds.w 46        ; 2 aufrufe...
newarea:
               endpart
