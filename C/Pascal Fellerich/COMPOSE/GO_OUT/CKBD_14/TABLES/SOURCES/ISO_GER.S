*******************************************************************************
*
* This is the assembler source for an ISO compose table for CKBD
*   The compose sequences in this table have been set up accordingly with
*   DEC's VTxxx compose schemes. Reference was the DEC multinational character
*   set, so this table can be used in conjunction with terminal programs like
*   UNITERM or CONNECT which have the corresponding character set.
*
*   This table was designed for the german keyboard layout!
*
* Assembler: TurboAss 1.7.x
*
* Ω2/1992, 3/1994 by P. Fellerich
*

               output 'ISO_GER.CKB'
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
name:          dc.b 'ISO/VTxxx',0,0,0 ; Name: exakt 12 Zeichen!!

*
* 3. The offsets to the keyboard mapping and compose tables. If a given table
*    is not present it's offset must be zero.
*
unshift_offset:dc.w unshift-id
shift_offset:  dc.w shift-id
caps_offset:   dc.w caps-id
compose_offset:dc.w compose-id

*
* 4. Setup-Words. These words are only read out if the table is autoloaded by
*    CKBD. The magic $BAD0 in the first word is used to indicate that there are
*    more configuration words to follow.
*
compose_mode:  dc.w $BAD0|DEC_MODE|ORDERINDIFF|ON

*
* 5. more config words (not read by older versions of ckbd.prg.
*
;only if compose_mode && 0xFFF0 == 0xBAD0
               dc.w ON        ;ExtKey ON
               dc.w OFF       ;Alt-NNN OFF
               dc.w ON        ;Deadkeys ON
               dc.b "`'^""/,|~",0 ;use these chars
               even

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
* Format is:
*   typedef struct {
*       char    primary;        /* first character plus... */
*       char    secondary;      /* ...second character */
*       char    composed;       /* becomes _composed_char_ ! */
*       char    flags;          /* reserved! (Flags) */
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
; ascii codes >128
               dc.b "!!",161,0 ;≠  inverted !
               dc.b "c/",162,0 ;õ  Cent
               dc.b "C/",162,0 ;õ
               dc.b "c|",162,0 ;õ
               dc.b "C|",162,0 ;õ
               dc.b "l-",163,0 ;ú  Pound
               dc.b "L_",163,0 ;ú  Pound
               dc.b "l_",163,0 ;ú
               dc.b "L-",163,0 ;ú
               dc.b "y-",165,0 ;ù  Yen
               dc.b "y=",165,0 ;ù
               dc.b "Y-",165,0 ;ù
               dc.b "Y=",165,0 ;ù
               dc.b "so",167,0 ;›  Section sign
               dc.b "SO",167,0 ;›
               dc.b "S!",167,0 ;›
               dc.b "s!",167,0 ;›
               dc.b "S0",167,0 ;›
               dc.b "s0",167,0 ;›
               dc.b "xo",168,0 ;   Currency sign (doesn't exist in TOS)
               dc.b "XO",168,0 ;
               dc.b "x0",168,0 ;
               dc.b "X0",168,0 ;
               dc.b "co",169,0 ;Ω  Copyright sign
               dc.b "CO",169,0 ;Ω
               dc.b "c0",169,0 ;Ω
               dc.b "C0",169,0 ;Ω
               dc.b "a-",170,0 ;¶  feminine ordinal indicator
               dc.b "A-",170,0 ;¶
               dc.b "<<",171,0 ;Æ  angle quotation mark left
               dc.b "0^",176,0 ;¯  degree sign
               dc.b "# ",176,0 ;¯
               dc.b "o ",176,0 ;¯
               dc.b "+-",177,0 ;Ò  plus/minus sign
               dc.b "2^",178,0 ;˝  superscript 2
               dc.b "2 ",178,0 ;˝  (id, TOS compose)
               dc.b "3^",179,0 ;˛  superscript 3
               dc.b "3 ",179,0 ;˛
               dc.b "/u",181,0 ;Ê  micron
               dc.b "/U",181,0 ;Ê
               dc.b "p!",182,0 ;º  paragraph sign ('PICA')
               dc.b "P!",182,0 ;º
               dc.b "pp",182,0 ;º
               dc.b "PP",182,0 ;º
               dc.b ".^",183,0 ;˙  middle dot
               dc.b ". ",183,0 ;˙  (id, TOS)
               dc.b "1^",185,0 ;   superscript 1
               dc.b "1 ",185,0 ;   id, pseudo TOS
               dc.b "o-",186,0 ;ß  masculine ordinal indicator
               dc.b "O-",186,0 ;ß
               dc.b ">>",187,0 ;Ø  angle quotation mark right
               dc.b "14",188,0 ;¨  fraction one quarter
               dc.b "12",189,0 ;´  fraction one half
               dc.b "??",191,0 ;®  inverted ?
               dc.b "A`",192,0 ;∂  A grave
               dc.b "A'",193,0 ;   A acute
               dc.b "A^",194,0 ;   A circumflex
               dc.b "A~",195,0 ;∑  A tilde
               dc.b 'A"',196,0 ;é  A umlaut
               dc.b "A*",197,0 ;è  A ring
               dc.b "A.",197,0 ;è  id, TOS
               dc.b "AE",198,0 ;í  AE ligature
               dc.b "C,",199,0 ;Ä  C cedilla
               dc.b "E`",200,0 ;   E grave
               dc.b "E'",201,0 ;ê  E acute
               dc.b "E^",202,0 ;   E circumflex
               dc.b 'E"',203,0 ;   E umlaut
               dc.b "I`",204,0 ;   I grave
               dc.b "I'",205,0 ;   I acute
               dc.b "I^",206,0 ;   I circumflex
               dc.b 'I"',207,0 ;   I umlaut
               dc.b "N~",209,0 ;•  N tilde
               dc.b "O`",210,0 ;   O grave
               dc.b "O'",211,0 ;   O acute
               dc.b "O^",212,0 ;   O circumflex
               dc.b "O~",213,0 ;   O tilde
               dc.b 'O"',214,0 ;   O umlaut
               dc.b "OE",215,0 ;µ  OE ligature
               dc.b "O/",216,0 ;≤  O Smorrebroed
               dc.b "U`",217,0 ;   U grave
               dc.b "U'",218,0 ;   U acute
               dc.b "U^",219,0 ;   U circumflex
               dc.b 'U"',220,0 ;ö  U umlaut
               dc.b 'Y"',221,0 ;   Y umlaut
               dc.b "ss",223,0 ;·  german small sharp s
               dc.b "SS",223,0 ;·  id, TOS
               dc.b "a`",224,0 ;Ö  a grave
               dc.b "a'",225,0 ;†  a acute
               dc.b "a^",226,0 ;É  a circumflex
               dc.b "a~",227,0 ;∞  a tilde
               dc.b 'a"',228,0 ;Ñ  a umlaut
               dc.b "a*",229,0 ;Ü  a ring
               dc.b "a.",229,0 ;Ü  id, TOS
               dc.b "ae",230,0 ;ë  ae ligature
               dc.b "c,",231,0 ;á  c cedilla
               dc.b "e`",232,0 ;ä  e grave
               dc.b "e'",233,0 ;Ç  e acute
               dc.b "e^",234,0 ;à  e circumflex
               dc.b 'e"',235,0 ;â  e umlaut
               dc.b "i`",236,0 ;ç  i grave
               dc.b "i'",237,0 ;°  i acute
               dc.b "i^",238,0 ;å  i circumflex
               dc.b 'i"',239,0 ;ã  i umlaut
               dc.b "n~",241,0 ;§  n tilde
               dc.b "o`",242,0 ;ï  o grave
               dc.b "o'",243,0 ;¢  o acute
               dc.b "o^",244,0 ;ì  o circumflex
               dc.b "o~",245,0 ;±  o tilde
               dc.b 'o"',246,0 ;î  o umlaut
               dc.b "oe",247,0 ;¥  oe ligature
               dc.b "o/",248,0 ;≥  o Smorrebroed
               dc.b "u`",249,0 ;ó  u grave
               dc.b "u'",250,0 ;£  u acute
               dc.b "u^",251,0 ;ñ  u circumflex
               dc.b 'u"',252,0 ;Å  u umlaut
               dc.b 'y"',253,0 ;ò  y umlaut

               dc.l 0         ;end marker

COMPTABSIZE    equ (*-compose)/4

               if (*-compose)>1024
               fail 'Compose table too long!!'
               endc
               endpart
               end
