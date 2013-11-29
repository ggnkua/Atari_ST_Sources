*******************************************************************************
* corrected draft!
* This is the assembler source for an VIQR compose table for CKBD
* (Mapping recommended by TriChlor group for Vietnamese: www.saigon.com)
* Modified from ISO_GER.CKB.S
*
* Should be set to switch to multi-character mode,
* Order sensitive.
*
* VIQR mapping would give problems in deadkey mode for English text
* because the "dd" sequence and "a." etc. would occur in English text.
* However, I think this isn't a problem in Vietnamese.
* (I might be wrong about this).
*
* -> Deadkey always translates double dead chars into a single one,
*    e.g. ' '  gives ', or with VIQR map: DD -> D
*
* Also the VIQR standard uses "\" as the compose key.. but I don't think
* we should stick with this.
*
* VIQR also requires literal to do things like question mark.
* I haven't added these to the table yet. but they require
* "\?" to be mapped to "?" etc.  ("\" is their literal character)
*
* VIQR also uses Ctrl-A (ascii 0x01) aka <CLS> for "Explicit Closure"
* to signal that no further characters belong to the current compose
* sequence.  Use ESC in CKBD instead!
*
*   This table was designed for the german keyboard layout!
*   To use with other keyboard layouts, select 'Table valid for Compose' in
*   the keyboard manager control panel.
*
* Assembler: TurboAss 1.7.x
*
* ½2/1992, 3/1994 by P. Fellerich
* 4/1996 O.Skelton
*

               output 'VN_VIQR.CKB'
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

* (NEW) flags:
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
name:          dc.b 'Vietnam VIQR' ; Name: exactly 12 characters!!

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
* -> not used by CKBD 1.4 (autoload feature cancelled)
*
compose_mode:  dc.w $BAD0|MULTICHAR|ORDERSENS|ON

*
* 5. more config words (not read by older versions of ckbd.prg.
*
;only if compose_mode && 0xFFF0 == 0xBAD0
               dc.w ON        ;ExtKey ON
               dc.w OFF       ;Alt-NNN OFF
               dc.w ON|SET
               dc.b "ADEIOUYadeiouy",0
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
               PART 'Compose Character Tabelle'
*
* COMPOSED CHARACTERS - table:
*
* Format is:
*   typedef struct {
*       char    primary;        /* first character plus... */
*       char    secondary;      /* ...second character */
*       char    composed;       /* results into _composed_ ! */
*       char    flags;          /* misc. flags */
*                               /* bit 0:       1 = Order sensitive */
*                               /* bit 1..7:    reserved. */
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
; Vietnamese VIQR encoding for VISCII 1.1 8 bit characters:

               dc.b "\?","?",0 ;example...

               dc.b "A'",193,0 ;Á  A acute
               dc.b "A`",192,0 ;À  A grave
               dc.b "A?",196,0 ;Ä  A hook-above
               dc.b "A~",195,0 ;Ã  A tilde
               dc.b "A.",128,0 ;€  A dot-below
               dc.b "A(",197,0 ;Å  A breve
               dc.b 197,"'",129,0 ;  A breve acute
               dc.b 197,"`",130,0 ;‚  A breve grave
               dc.b 197,"?",2,0 ;  A breve hook-above
               dc.b 197,"~",5,0 ;  A breve tilde
               dc.b 197,".",131,0 ;ƒ  A breve dot-below
               dc.b "A^",194,0 ;Â  A circumflex
               dc.b 194,"'",132,0 ;„  A circumflex acute
               dc.b 194,"`",133,0 ;…  A circumflex grave
               dc.b 194,"?",134,0 ;†  A circumflex hook-above
               dc.b 194,"~",6,0 ;  A circumflex tilde
               dc.b 194,".",135,0 ;‡  A circumflex dot-below
               dc.b "DD",208,0 ;Ð  D bar
               dc.b "Dd",208,0 ;Ð  D bar
               dc.b "dD",208,0 ;Ð  D bar
               dc.b "E'",201,0 ;É  E acute
               dc.b "E`",200,0 ;È  E grave
               dc.b "E?",203,0 ;Ë  E hook-above
               dc.b "E~",136,0 ;ˆ  E tilde
               dc.b "E.",137,0 ;‰  E dot-below
               dc.b "E^",202,0 ;Ê  E circumflex
               dc.b 202,"'",138,0 ;Š  E circumflex acute
               dc.b 202,"`",139,0 ;‹  E circumflex grave
               dc.b 202,"?",140,0 ;Œ  E circumflex hook-above
               dc.b 202,"~",141,0 ;  E circumflex tilde
               dc.b 202,".",142,0 ;Ž  E circumflex dot-below
               dc.b "I'",205,0 ;Í  I acute
               dc.b "I`",204,0 ;Ì  I grave
               dc.b "I?",155,0 ;›  I hook-above
               dc.b "I~",206,0 ;Î  I tilde
               dc.b "I.",152,0 ;˜  I dot-below

               dc.b "O'",211,0 ;Ó  O acute
               dc.b "O`",210,0 ;Ò  O grave
               dc.b "O?",153,0 ;™  O hook-above
               dc.b "O~",160,0 ;   O tilde
               dc.b "O.",154,0 ;š  O dot-below
               dc.b "O^",212,0 ;Ô  O circumflex
               dc.b 212,"'",143,0 ;  O circumflex acute
               dc.b 212,"`",144,0 ;  O circumflex grave
               dc.b 212,"?",145,0 ;‘  O circumflex hook-above
               dc.b 212,"~",146,0 ;’  O circumflex tilde
               dc.b 212,".",147,0 ;“  O circumflex dot-below
               dc.b "O+",180,0 ;´  O horn
               dc.b 180,"'",149,0 ;•  O horn acute
               dc.b 180,"`",150,0 ;–  O horn grave
               dc.b 180,"?",151,0 ;—  O horn hook-above
               dc.b 180,"~",179,0 ;³  O horn tilde
               dc.b 180,".",148,0 ;”  O horn dot-below
               dc.b "U'",218,0 ;Ú  U acute
               dc.b "U`",217,0 ;Ù  U grave
               dc.b "U?",156,0 ;œ  U hook-above
               dc.b "U~",157,0 ;  U tilde
               dc.b "U.",158,0 ;ž  U dot-below
               dc.b "U+",191,0 ;¿  U horn
               dc.b 191,"'",186,0 ;º  U horn acute
               dc.b 191,"`",187,0 ;»  U horn grave
               dc.b 191,"?",188,0 ;¼  U horn hook-above
               dc.b 191,"~",255,0 ;ÿ  U horn tilde
               dc.b 191,".",185,0 ;¹  U horn dot-below
               dc.b "Y'",221,0 ;Ý  Y acute
               dc.b "Y`",159,0 ;Ÿ  Y grave
               dc.b "Y?",20,0 ;  Y hook-above
               dc.b "Y~",25,0 ;  Y tilde
               dc.b "Y.",30,0 ;  Y dot-below

; Lower case versions:
               dc.b "a'",225,0 ;á  a acute
               dc.b "a`",224,0 ;à  a grave
               dc.b "a?",228,0 ;ä  a hook-above
               dc.b "a~",227,0 ;ã  a tilde
               dc.b "a.",213,0 ;Õ  a dot-below
               dc.b "a(",229,0 ;å  a breve
               dc.b 229,"'",161,0 ;¡  a breve acute
               dc.b 229,"`",162,0 ;¢  a breve grave
               dc.b 229,"?",198,0 ;Æ  a breve hook-above
               dc.b 229,"~",199,0 ;Ç  a breve tilde
               dc.b 229,".",163,0 ;£  a breve dot-below
               dc.b "a^",226,0 ;â  a circumflex
               dc.b 226,"'",164,0 ;¤  a circumflex acute
               dc.b 226,"`",165,0 ;¥  a circumflex grave
               dc.b 226,"?",166,0 ;¦  a circumflex hook-above
               dc.b 226,"~",231,0 ;ç  a circumflex tilde
               dc.b 226,".",167,0 ;§  a circumflex dot-below
               dc.b "dd",240,0 ;ð  d bar
               dc.b "e'",233,0 ;é  e acute
               dc.b "e`",232,0 ;è  e grave
               dc.b "e?",235,0 ;ë  e hook-above
               dc.b "e~",168,0 ;¨  e tilde
               dc.b "e.",169,0 ;©  e dot-below
               dc.b "e^",234,0 ;ê  e circumflex
               dc.b 234,"'",170,0 ;ª  e circumflex acute
               dc.b 234,"`",171,0 ;«  e circumflex grave
               dc.b 234,"?",172,0 ;¬  e circumflex hook-above
               dc.b 234,"~",173,0 ;­  e circumflex tilde
               dc.b 234,".",174,0 ;®  e circumflex dot-below
               dc.b "i'",237,0 ;í  i acute
               dc.b "i`",236,0 ;ì  i grave
               dc.b "i?",239,0 ;ï  i hook-above
               dc.b "i~",238,0 ;î  i tilde
               dc.b "i.",184,0 ;¸  i dot-below

               dc.b "o'",243,0 ;ó  o acute
               dc.b "o`",242,0 ;ò  o grave
               dc.b "o?",246,0 ;ö  o hook-above
               dc.b "o~",245,0 ;õ  o tilde
               dc.b "o.",247,0 ;÷  o dot-below
               dc.b "o^",244,0 ;ô  o circumflex
               dc.b 244,"'",175,0 ;¯  o circumflex acute
               dc.b 244,"`",176,0 ;°  o circumflex grave
               dc.b 244,"?",177,0 ;±  o circumflex hook-above
               dc.b 244,"~",178,0 ;²  o circumflex tilde
               dc.b 244,".",181,0 ;µ  o circumflex dot-below
               dc.b "o+",189,0 ;½  o horn
               dc.b 189,"'",190,0 ;¾  o horn acute
               dc.b 189,"`",182,0 ;¶  o horn grave
               dc.b 189,"?",183,0 ;·  o horn hook-above
               dc.b 189,"~",222,0 ;Þ  o horn tilde
               dc.b 189,".",254,0 ;þ  o horn dot-below
               dc.b "u'",250,0 ;ú  u acute
               dc.b "u`",249,0 ;ù  u grave
               dc.b "u?",252,0 ;ü  u hook-above
               dc.b "u~",251,0 ;û  u tilde
               dc.b "u.",248,0 ;ø  u dot-below
               dc.b "u+",223,0 ;ß  u horn
               dc.b 223,"'",209,0 ;Ñ  u horn acute
               dc.b 223,"`",215,0 ;×  u horn grave
               dc.b 223,"?",216,0 ;Ø  u horn hook-above
               dc.b 223,"~",230,0 ;æ  u horn tilde
               dc.b 223,".",241,0 ;ñ  u horn dot-below
               dc.b "y'",253,0 ;ý  y acute
               dc.b "y`",207,0 ;Ï  y grave
               dc.b "y?",214,0 ;Ö  y hook-above
               dc.b "y~",219,0 ;Û  y tilde
               dc.b "y.",220,0 ;Ü  y dot-below

               dc.l 0         ;end marker

COMPTABSIZE    equ (*-compose)/4
;The compose table must not have more than 255 entries,
;i.e. must be <=1024 bytes including the end marker
               if (*-compose)>1024
               fail 'Compose table too long!!'
               endc
               endpart
               end
