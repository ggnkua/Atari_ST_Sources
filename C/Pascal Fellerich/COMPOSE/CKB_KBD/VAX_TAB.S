*
* ASM Source der VAX-Tabelle. Die ASCII Codes ber 128 entsprechen dem DEC
*   Multinational Mode; sinnvoll ist der Einsatz dieser Tabelle nur mit
*   UNITERM, das ber den passenden Zeichensatz verfgt.
* (TurboAss!)
*
* ½2/1992 by P. Fellerich
*
               output 'VAX_SET.CKB'

               default 6      ;'BASIC' == BINŽR!

               >PART 'Header'
id:            dc.b "CKBD"    ;Kennung

               dxset 12,0     ;der eigene Name hat 12 chars
;                    ............
name:          dx.b 'VAX/Uniterm'

unshift_offset:dc.w unshift-id ;  Start der UNSHIFT-Tabelle oder 0 wenn nicht da
shift_offset:  dc.w shift-id  ;   Start der Shift-Tabelle
caps_offset:   dc.w caps-id   ;   id, CapsLock
compose_offset:dc.w compose-id ;  Start der Compose-Tabelle

compose_mode:  dc.w %111      ; ON, MULTICHAR MODE, ORDER SENSITIVE

               endpart
               >PART 'Unshift translation table'
unshift:
               dc.b $00,$1B,$31,$32,$33,$34,$35,$36
               dc.b $37,$38,$39,$30,$DF,$27,$08,$09
               dc.b $71,$77,$65,$72,$74,$7A,$75,$69
               dc.b $6F,$70,$FC,$2B,$0D,$00,$61,$73
               dc.b $64,$66,$67,$68,$6A,$6B,$6C,$F6
               dc.b $E4,$23,$00,$7E,$79,$78,$63,$76
               dc.b $62,$6E,$6D,$2C,$2E,$2D,$00,$00
               dc.b $00,$20,$00,$00,$00,$00,$00,$00
               dc.b $00,$00,$00,$00,$00,$00,$00,$00
               dc.b $00,$00,$2D,$00,$00,$00,$2B,$00
               dc.b $00,$00,$00,$7F,$00,$00,$00,$00
               dc.b $00,$00,$00,$00,$00,$00,$00,$00
               dc.b $3C,$00,$00,$28,$29,$2F,$2A,$37
               dc.b $38,$39,$34,$35,$36,$31,$32,$33
               dc.b $30,$2E,$0D,$00,$00,$00,$00,$00
               dc.b $00,$00,$00,$00,$00,$00,$00,$00
               endpart
               >PART 'Shift-translation table'
shift:
               dc.b $00,$1B,$21,$22,$A7,$24,$25,$26
               dc.b $2F,$28,$29,$3D,$3F,$60,$08,$09
               dc.b $51,$57,$45,$52,$54,$5A,$55,$49
               dc.b $4F,$50,$DC,$2A,$0D,$00,$41,$53
               dc.b $44,$46,$47,$48,$4A,$4B,$4C,$D6
               dc.b $C4,$5E,$00,$7C,$59,$58,$43,$56
               dc.b $42,$4E,$4D,$3B,$3A,$5F,$00,$00
               dc.b $00,$20,$00,$00,$00,$00,$00,$00
               dc.b $00,$00,$00,$00,$00,$00,$00,$37
               dc.b $38,$00,$2D,$34,$00,$36,$2B,$00
               dc.b $32,$00,$30,$7F,$00,$00,$00,$00
               dc.b $00,$00,$00,$00,$00,$00,$00,$00
               dc.b $3E,$00,$00,$28,$29,$2F,$2A,$37
               dc.b $38,$39,$34,$35,$36,$31,$32,$33
               dc.b $30,$2E,$0D,$00,$00,$00,$00,$00
               dc.b $00,$00,$00,$00,$00,$00,$00,$00
               endpart
               >PART 'Capslock translation table'
caps:
               dc.b $00,$1B,$31,$32,$33,$34,$35,$36
               dc.b $37,$38,$39,$30,$DF,$27,$08,$09
               dc.b $51,$57,$45,$52,$54,$5A,$55,$49
               dc.b $4F,$50,$DC,$2B,$0D,$00,$41,$53
               dc.b $44,$46,$47,$48,$4A,$4B,$4C,$D6
               dc.b $C4,$23,$00,$7E,$59,$58,$43,$56
               dc.b $42,$4E,$4D,$2C,$2E,$2D,$00,$00
               dc.b $00,$20,$00,$00,$00,$00,$00,$00
               dc.b $00,$00,$00,$00,$00,$00,$00,$00
               dc.b $00,$00,$2D,$00,$00,$00,$2B,$00
               dc.b $00,$00,$00,$7F,$00,$00,$00,$00
               dc.b $00,$00,$00,$00,$00,$00,$00,$00
               dc.b $3C,$00,$00,$28,$29,$2F,$2A,$37
               dc.b $38,$39,$34,$35,$36,$31,$32,$33
               dc.b $30,$2E,$0D,$00,$00,$00,$00,$00
               dc.b $00,$00,$00,$00,$00,$00,$00,$00
               endpart
               >PART 'Compose Character Tabelle'
*
* COMPOSED CHARACTERS - TABELLE:
*   (DEC Multinational mode)
* Format ist:
*   typedef struct {
*       char    primary;        /* erster Buchstabe plus... */
*       char    secondary;      /* ...zweiter Buchstabe */
*       char    composed;       /* ergibt _composed_ ! */
*       char    flags;          /* div. Flags, reserved! */
*   } comptab[];
*
compose:
; combination, DEC-Ascii code, Null  ; TOS Ascii or description
               dc.b '" "',0   ;codes < 128 = STANDARD ASCII
               dc.b "++#",0
               dc.b "' '",0
               dc.b "aa@",0
               dc.b "AA@",0
               dc.b "(([",0
               dc.b "//\",0
               dc.b "))]",0
               dc.b "^ ^",0
               dc.b "(-{",0
               dc.b "/^|",0
               dc.b ")-}",0
               dc.b "~ ~",0

               dc.b "!!",161,0 ;­  inverted !
               dc.b "c/",162,0 ;›  Cent
               dc.b "C/",162,0 ;›
               dc.b "c|",162,0 ;›
               dc.b "C|",162,0 ;›
               dc.b "l-",163,0 ;œ  Pound
               dc.b "L_",163,0 ;œ  Pound
               dc.b "l_",163,0 ;œ
               dc.b "L-",163,0 ;œ
               dc.b "y-",165,0 ;  Yen
               dc.b "y=",165,0 ;
               dc.b "Y-",165,0 ;
               dc.b "Y=",165,0 ;
               dc.b "so",167,0 ;Ý  Section sign
               dc.b "SO",167,0 ;Ý
               dc.b "S!",167,0 ;Ý
               dc.b "s!",167,0 ;Ý
               dc.b "S0",167,0 ;Ý
               dc.b "s0",167,0 ;Ý
               dc.b "xo",168,0 ;   Currency sign (doesn't exist in TOS)
               dc.b "XO",168,0 ;
               dc.b "x0",168,0 ;
               dc.b "X0",168,0 ;
               dc.b "co",169,0 ;½  Copyright sign
               dc.b "CO",169,0 ;½
               dc.b "c0",169,0 ;½
               dc.b "C0",169,0 ;½
               dc.b "a-",170,0 ;¦  feminine ordinal indicator
               dc.b "A-",170,0 ;¦
               dc.b "<<",171,0 ;®  angle quotation mark left
               dc.b "0^",176,0 ;ø  degree sign
               dc.b "# ",176,0 ;ø
               dc.b "o ",176,0 ;ø
               dc.b "+-",177,0 ;ñ  plus/minus sign
               dc.b "2^",178,0 ;ý  superscript 2
               dc.b "2 ",178,0 ;ý  (id, TOS compose)
               dc.b "3^",179,0 ;þ  superscript 3
               dc.b "3 ",179,0 ;þ
               dc.b "/u",181,0 ;æ  micron
               dc.b "/U",181,0 ;æ
               dc.b "p!",182,0 ;¼  paragraph sign ('PICA')
               dc.b "P!",182,0 ;¼
               dc.b "pp",182,0 ;¼
               dc.b "PP",182,0 ;¼
               dc.b ".^",183,0 ;ú  middle dot
               dc.b ". ",183,0 ;ú  (id, TOS)
               dc.b "1^",185,0 ;   superscript 1
               dc.b "1 ",185,0 ;   id, pseudo TOS
               dc.b "o-",186,0 ;§  masculine ordinal indicator
               dc.b "O-",186,0 ;§
               dc.b ">>",187,0 ;¯  angle quotation mark right
               dc.b "14",188,0 ;¬  fraction one quarter
               dc.b "12",189,0 ;«  fraction one half
               dc.b "??",191,0 ;¨  inverted ?
               dc.b "A`",192,0 ;¶  A grave
               dc.b "A'",193,0 ;   A acute
               dc.b "A^",194,0 ;   A circumflex
               dc.b "A~",195,0 ;·  A tilde
               dc.b 'A"',196,0 ;Ž  A umlaut
               dc.b "A*",197,0 ;  A ring
               dc.b "A.",197,0 ;  id, TOS
               dc.b "AE",198,0 ;’  AE ligature
               dc.b "C,",199,0 ;€  C cedilla
               dc.b "E`",200,0 ;   E grave
               dc.b "E'",201,0 ;  E acute
               dc.b "E^",202,0 ;   E circumflex
               dc.b 'E"',203,0 ;   E umlaut
               dc.b "I`",204,0 ;   I grave
               dc.b "I'",205,0 ;   I acute
               dc.b "I^",206,0 ;   I circumflex
               dc.b 'I"',207,0 ;   I umlaut
               dc.b "N~",209,0 ;¥  N tilde
               dc.b "O`",210,0 ;   O grave
               dc.b "O'",211,0 ;   O acute
               dc.b "O^",212,0 ;   O circumflex
               dc.b "O~",213,0 ;   O tilde
               dc.b 'O"',214,0 ;   O umlaut
               dc.b "OE",215,0 ;µ  OE ligature
               dc.b "O/",216,0 ;²  O Smorrebroed
               dc.b "U`",217,0 ;   U grave
               dc.b "U'",218,0 ;   U acute
               dc.b "U^",219,0 ;   U circumflex

               dc.b 'U"',220,0 ;š  U umlaut
               dc.b 'Y"',221,0 ;   Y umlaut
               dc.b "ss",223,0 ;á  german small sharp s
               dc.b "SS",223,0 ;á  id, TOS
               dc.b "a`",224,0 ;…  a grave
               dc.b "a'",225,0 ;   a acute
               dc.b "a^",226,0 ;ƒ  a circumflex
               dc.b "a~",227,0 ;°  a tilde
               dc.b 'a"',228,0 ;„  a umlaut
               dc.b "a*",229,0 ;†  a ring
               dc.b "a.",229,0 ;†  id, TOS
               dc.b "ae",230,0 ;‘  ae ligature
               dc.b "c,",231,0 ;‡  c cedilla
               dc.b "e`",232,0 ;Š  e grave
               dc.b "e'",233,0 ;‚  e acute
               dc.b "e^",234,0 ;ˆ  e circumflex
               dc.b 'e"',235,0 ;‰  e umlaut
               dc.b "i`",236,0 ;  i grave
               dc.b "i'",237,0 ;¡  i acute
               dc.b "i^",238,0 ;Œ  i circumflex
               dc.b 'i"',239,0 ;‹  i umlaut
               dc.b "n~",241,0 ;¤  n tilde
               dc.b "o`",242,0 ;•  o grave
               dc.b "o'",243,0 ;¢  o acute
               dc.b "o^",244,0 ;“  o circumflex
               dc.b "o~",245,0 ;±  o tilde
               dc.b 'o"',246,0 ;”  o umlaut
               dc.b "oe",247,0 ;´  oe ligature
               dc.b "o/",248,0 ;³  o Smorrebroed
               dc.b "u`",249,0 ;—  u grave
               dc.b "u'",250,0 ;£  u acute
               dc.b "u^",251,0 ;–  u circumflex
               dc.b 'u"',252,0 ;  u umlaut
               dc.b 'y"',253,0 ;˜  y umlaut

               dc.l 0         ;Endekennung

COMPTABSIZE    equ (*-compose)/4

               if (*-compose)>1024
               fail 'Compose Tabelle zu lang!'
               endc
               endpart
               end
