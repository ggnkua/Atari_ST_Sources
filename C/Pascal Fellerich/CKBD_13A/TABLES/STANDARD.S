*******************************************************************************
*
* This is the assembler source for the standard compose table used by CKBD
*
*   This file contains no keyboard mapping tables!
*
* Assembler: TurboAss 1.7.x
*
* Ω3/1994 by P. Fellerich
*

               output 'Standard.CKB'
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
name:          dc.b 'Standard GER' ; Name: exakt 12 Zeichen!!

*
* 3. The offsets to the keyboard mapping and compose tables. If a given table
*    is not present it's offset must be zero.
*
unshift_offset:dc.w 0			;unshift-id  if used
shift_offset:  dc.w 0			;shift-id    if used
caps_offset:   dc.w 0			;caps-id     if used
compose_offset:dc.w compose-id

*
* 4. Setup-Words. These words are only read out if the table is autoloaded by
*    CKBD. The magic $BAD0 in the first word is used to indicate that there are
*    more configuration words to follow.
*
compose_mode:  dc.w $0BAD|DEC_MODE|ORDERINDIFF|ON

*
* 5. more config words (not read by older versions of ckbd.prg).
*
;only if compose_mode && 0xFFF0 == 0xBAD0
               dc.w ON        		;ExtKey ON
               dc.w OFF       		;Alt-NNN OFF
               dc.w ON        		;Deadkeys ON
               dc.b "`'^""/,|~",0	;use these characters
               even

               endpart
               >PART 'keyboard mapping tables'

unshift:		;
shift:			; NOT USED; CKBD will substitute the system default!
caps:			;

               endpart
               >PART 'Compose Character Tabelle'
*
* COMPOSED CHARACTERS - TABELLE:
* Format is:
*   typedef struct {
*       char    primary;        /* first character plus... */
*       char    secondary;      /* ...second character */
*       char    composed;       /* becomes _composed_char_ ! */
*       char    flags;          /* reserved! (Flags) */
*   } comptab[];
*
compose:
	dc.b "O-È",0
	dc.b "++#",0
	dc.b "aa@",0
	dc.b "AA@",0
	dc.b "(([",0
	dc.b "//\",0
	dc.b "))]",0
	dc.b "(-{",0
	dc.b "/^|",0
	dc.b ")-}",0
	dc.b "C,Ä",0
	dc.b 'u"Å',0
	dc.b 'uπÅ',0
	dc.b "e'Ç",0
	dc.b "a^É",0
	dc.b 'a"Ñ',0
	dc.b 'aπÑ',0
	dc.b "a`Ö",0
	dc.b "a.Ü",0
	dc.b "a¯Ü",0
	dc.b "c,á",0
	dc.b "e^à",0
	dc.b 'e"â',0
	dc.b 'eπâ',0
	dc.b "e`ä",0
	dc.b 'i"ã',0
	dc.b 'iπã',0
	dc.b "i^å",0
	dc.b "i`ç",0
	dc.b 'A"é',0
	dc.b 'Aπé',0
	dc.b "A.è",0
	dc.b "A¯è",0
	dc.b "E'ê",0
	dc.b "aeë",0
	dc.b "Aeí",0
	dc.b "AEí",0
	dc.b "o^ì",0
	dc.b 'o"î',0
	dc.b 'oπî',0
	dc.b "o`ï",0
	dc.b "u^ñ",0
	dc.b "u`ó",0
	dc.b 'y"ò',0
	dc.b 'yπò',0
	dc.b 'O"ô',0
	dc.b 'Oπô',0
	dc.b 'U"ö',0
	dc.b 'Uπö',0
	dc.b "c/õ",0
	dc.b "C/õ",0
	dc.b "c|õ",0
	dc.b "C|õ",0
	dc.b "l-ú",0
	dc.b "L_ú",0
	dc.b "l_ú",0
	dc.b "L-ú",0
	dc.b "y-ù",0
	dc.b "y=ù",0
	dc.b "Y-ù",0
	dc.b "Y=ù",0
	dc.b "Ptû",0
	dc.b "ptû",0
	dc.b "f-ü",0
	dc.b "a'†",0
	dc.b "i'°",0
	dc.b "o'¢",0
	dc.b "u'£",0
	dc.b "n~§",0
	dc.b "N~•",0
	dc.b "a-¶",0
	dc.b "a_¶",0
	dc.b "o-ß",0
	dc.b "o_ß",0
	dc.b "??®",0
	dc.b "12´",0
	dc.b "14¨",0
	dc.b "!!≠",0
	dc.b "<<Æ",0
	dc.b ">>Ø",0
	dc.b "a~∞",0
	dc.b "o~±",0
	dc.b "O/≤",0
	dc.b "o/≥",0
	dc.b "O|≤",0
	dc.b "o|≥",0
	dc.b "oe¥",0
	dc.b "Oeµ",0
	dc.b "OEµ",0
	dc.b "A`∂",0
	dc.b "A~∑",0
	dc.b "O~∏",0
	dc.b ' "π',0
	dc.b " '∫",0
	dc.b " +ª",0
	dc.b "PPº",0
	dc.b "ppº",0
	dc.b "P|º",0
	dc.b "p|º",0
	dc.b "p/º",0
	dc.b "P/º",0
	dc.b "coΩ",0
	dc.b "COΩ",0
	dc.b "roæ",0
	dc.b "ROæ",0
	dc.b "tmø",0
	dc.b "TMø",0
	dc.b "ij¿",0
	dc.b "IJ¡",0
	dc.b "Ij¡",0
	dc.b "so›",0
	dc.b "SO›",0
	dc.b " ^ﬁ",0
	dc.b "ooﬂ",0
	dc.b "OOﬂ",0
	dc.b "ss·",0
	dc.b "PI„",0
	dc.b "pi„",0
	dc.b "SS‰",0
	dc.b "u/Ê",0
	dc.b "u|Ê",0
	dc.b "=-",0
	dc.b "+-Ò",0
	dc.b ">-Ú",0
	dc.b "<-Û",0
	dc.b ">_Ú",0
	dc.b "<_Û",0
	dc.b ">=Ú",0
	dc.b "<=Û",0
	dc.b ":-ˆ",0
	dc.b "=~˜",0
	dc.b "o ¯",0
	dc.b "* ˘",0
	dc.b ". ˙",0
	dc.b "v ˚",0
	dc.b "n ¸",0
	dc.b "2 ˝",0
	dc.b "3 ˛",0
	dc.b "_ ˇ",0

	dc.l 0				; end of table!

COMPTABSIZE    equ (*-comptab)/4-1

	if (*-compose)>1024
	fail 'Compose table too long!!'
	endc
	endpart

