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
* FLAGS: damit sind verschiedene Angaben m�glich
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
               dc.b "C,�",0   ;128
               dc.b 'u"�',0   ;129
               dc.b 'u��',0
               dc.b "e'�",0   ;130
               dc.b "a^�",0   ;131
               dc.b 'a"�',0   ;132
               dc.b 'a��',0
               dc.b "a`�",0   ;133
               dc.b "a.�",0   ;134
               dc.b "a��",0
               dc.b "c,�",0   ;135
               dc.b "e^�",0   ;136
               dc.b 'e"�',0   ;137
               dc.b 'e��',0
               dc.b "e`�",0   ;138
               dc.b 'i"�',0   ;139
               dc.b 'i��',0
               dc.b "i^�",0   ;140
               dc.b "i`�",0   ;141
               dc.b 'A"�',0   ;142
               dc.b 'A��',0
               dc.b "A.�",0   ;143
               dc.b "A��",0
               dc.b "E'�",0   ;144
               dc.b "ae�",ORDER ;145
               dc.b "AE�",ORDER ;146
               dc.b "Ae�",ORDER
               dc.b "o^�",0   ;147
               dc.b 'o"�',0   ;148
               dc.b 'o��',0
               dc.b "o`�",0   ;149
               dc.b "u^�",0   ;150
               dc.b "u`�",0   ;151
               dc.b 'y"�',0   ;152
               dc.b 'y��',0
               dc.b 'O"�',0   ;153
               dc.b 'O��',0
               dc.b 'U"�',0   ;154
               dc.b 'U��',0
               dc.b "c/�",0   ;155
               dc.b "C/�",0
               dc.b "c|�",0
               dc.b "C|�",0
               dc.b "L_�",0   ;156
               dc.b "L-�",0
               dc.b "l-�",0
               dc.b "l_�",0
               dc.b "Y-�",0   ;157 Yen
               dc.b "y-�",0
               dc.b "Y=�",0
               dc.b "y=�",0
               dc.b "ss�",0   ;158 German Eszet
               dc.b "f-�",0   ;159 Florin
               dc.b "a'�",0   ;160
               dc.b "i'�",0   ;161
               dc.b "o'�",0   ;162
               dc.b "u'�",0   ;163
               dc.b "n~�",0   ;164
               dc.b "N~�",0   ;165
               dc.b "a_�",0   ;166 a underscore (not NVDI)
               dc.b "a-�",0
               dc.b "o_�",0   ;167 o underscore (not NVDI)
               dc.b "o-�",0
               dc.b "??�",0   ;168
               dc.b "12�",ORDER ;171
               dc.b "14�",ORDER ;172
               dc.b "!!�",0   ;173
               dc.b "<<�",0   ;174
               dc.b ">>�",0   ;175
               dc.b "a~�",0   ;176
               dc.b "o~�",0   ;177
               dc.b "O/�",0   ;178
               dc.b "O|�",0
               dc.b "o/�",0   ;179
               dc.b "o|�",0
               dc.b "oe�",ORDER ;180
               dc.b "OE�",ORDER ;181
               dc.b "Oe�",ORDER
               dc.b "A`�",0   ;182
               dc.b "A~�",0   ;183
               dc.b "O~�",0   ;184
               dc.b '" �',0   ;185
               dc.b "` �",0   ;186
               dc.b "+ �",0   ;187
               dc.b "PP�",0   ;188
               dc.b "pp�",0
               dc.b "P|�",0
               dc.b "p|�",0
               dc.b "p/�",0
               dc.b "P/�",0
               dc.b "co�",0   ;189
               dc.b "CO�",0
               dc.b "ro�",0   ;190
               dc.b "RO�",0
               dc.b "tm�",0   ;191
               dc.b "TM�",0
; dc.b "ij�",0  ;ij ligature not defined in NVDI 3 mapping
; dc.b "IJ�",0  ;ij ligature not defined in NVDI 3 mapping
; dc.b "Ij�",0
;************ NVDI 3 FontMap new chars
               dc.b "A^�",0   ;192 (NOT ij)
               dc.b "A'�",0   ;193
               dc.b "E^�",0   ;194
               dc.b 'E"�',0   ;195
               dc.b 'E��',0   ;195
               dc.b "E`�",0   ;196
               dc.b "I^�",0   ;197
               dc.b 'I"�',0   ;198
               dc.b 'I��',0   ;198
               dc.b "I`�",0   ;199
               dc.b "I'�",0   ;200
               dc.b "O^�",0   ;201
               dc.b "O`�",0   ;202
               dc.b "O'�",0   ;203
               dc.b "U^�",0   ;204
               dc.b "U`�",0   ;205
               dc.b "U'�",0   ;206
               dc.b ",,�",0   ;207
               dc.b "``�",0   ;208
               dc.b "''�",0   ;209
               dc.b ", �",0   ;210
               dc.b "' �",0   ;211
               dc.b "< �",0   ;212
               dc.b "> �",0   ;213
               dc.b "- �",0   ;214 dash medium
               dc.b "_ �",0   ;215 dash long
               dc.b "Pt�",ORDER ;216 Peseta sign
               dc.b "PT�",ORDER
               dc.b "pt�",ORDER
               dc.b "up�",ORDER ;217
               dc.b "UP�",ORDER
               dc.b "dn�",ORDER ;218
               dc.b "DN�",ORDER
               dc.b "rt�",ORDER ;219
               dc.b "RT�",ORDER
               dc.b "lt�",ORDER ;220
               dc.b "LT�",ORDER
               dc.b "so�",ORDER ;221
               dc.b "SO�",ORDER
               dc.b "%o�",0   ;222
               dc.b "%.�",0
;************ Normale FontMap
               dc.b "oo�",ORDER ;223
               dc.b "OO�",ORDER
               dc.b "al�",ORDER ;224 alpha
               dc.b "AL�",ORDER
               dc.b "be�",ORDER ;225 beta
               dc.b "BE�",ORDER
               dc.b "ga�",ORDER ;226 GAMMA
               dc.b "GA�",ORDER
               dc.b "pi�",ORDER ;227 pi
               dc.b "PI�",ORDER
               dc.b "SI�",ORDER ;228 SIGMA
               dc.b "SS�",ORDER
               dc.b "si�",ORDER ;229 sigma
               dc.b "u/�",0   ;230 my
               dc.b "u|�",0
               dc.b "my�",ORDER
               dc.b "MY�",ORDER
               dc.b "ta�",ORDER ;231 tau
               dc.b "TA�",ORDER
               dc.b "ph�",ORDER ;232 PHI
               dc.b "PH�",ORDER
               dc.b "O-�",0   ;233 THETA
               dc.b "TH�",ORDER
               dc.b "th�",ORDER
               dc.b "OM�",ORDER ;234 OMEGA
               dc.b "om�",ORDER
               dc.b "de�",ORDER ;235 delta
               dc.b "=-�",0   ;240
               dc.b "+-�",0   ;241
               dc.b ">-�",0   ;242
               dc.b ">_�",0
               dc.b ">=�",0
               dc.b "<-�",0   ;243
               dc.b "<_�",0
               dc.b "<=�",0
               dc.b ":-�",0   ;246
               dc.b "=~�",0   ;247
               dc.b "o �",0   ;248
               dc.b "* �",0   ;249
               dc.b ". �",0   ;250
               dc.b "v �",0   ;251
               dc.b "n �",0   ;252
               dc.b "2 �",0   ;253
               dc.b "3 �",0   ;254
               dc.b "_ �",0   ;255
               dc.l 0         ;total 193 Eintr�ge

COMPTABSIZE    equ (*-comptab)/4-1

MAXTABSIZE     equ 256

               if COMPTABSIZE>MAXTABSIZE
               fail 'Composetab zu lang.'
               endc

*
* Platz f�r weitere Tastaturtabellen:
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
