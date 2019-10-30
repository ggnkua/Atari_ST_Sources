*
*  Source-Datei erzeugt mit:
*  << Resource-to-Source Konverter >>
*  v1.21 ½ Mai 1992 by Bernd Eckstein
*                        Turmstrasse 188
*                        5100 Aachen
*                        Tel: 0241/876533
*
*  Dieses Programm war wirklich Arbeit, wer es gut findet, der
*  sollte mir 10 DM schicken. Dann gibt's die neueste Version.
*  Dieses Programm ist NICHT Public Domain, sondern SHAREWARE!
*  Wer Ideen und Vorsch„ge hat:  oben steht meine Adresse ...
*

*
*  Quelldatei: WPROTECT.RSC
*

G_BOX	equ	20
G_TEXT	equ	21
G_BOXTEXT	equ	22
G_IMAGE	equ	23
G_USERDEF	equ	24
G_IBOX	equ	25
G_BUTTON	equ	26
G_BOXCHAR	equ	27
G_STRING	equ	28
G_FTEXT	equ	29
G_FBOXTEXT	equ	30
G_ICON	equ	31
G_TITLE	equ	32

NIL	equ	-1

*******
*  -->>  Konstantendefinitionen:
DIALOG 	equ	0 	; /* Formular/Dialog */
DRIVEA 	equ	4 	; /* BOXCHAR in Baum DIALOG */
EXIT 	equ	30 	; /* BUTTON in Baum DIALOG */
SAVE 	equ	31 	; /* BUTTON in Baum DIALOG */
WIDMUNG 	equ	32 	; /* STRING in Baum DIALOG */
OK 	equ	34 	; /* BUTTON in Baum DIALOG */

sumTREES	equ	1	; Anzahl aller B„ume
OBJCs000	equ	35	; Objekte in Baum 1
sumOBJCS	equ	35	; Summe aller Objekte

*******
*  -->>  Objektbaum $0
Objc000000:	dc.w	NIL,$0001,$0022,$8900+G_BOX,$0000,$0010
	dc.l	$00021100
	dc.w	$0000,$0000,$002A,$000C
Objc000001:	dc.w	$0002,NIL,NIL,G_STRING,$0000,$0000
	dc.l	spec000001
	dc.w	$0001,$0001,$000D,$0001
Objc000002:	dc.w	$0003,NIL,NIL,G_TEXT,$0000,$0000
	dc.l	spec000002
	dc.w	$0001,$0003,$0407,$0001
Objc000003:	dc.w	$001E,$0004,$001D,G_BOX,$0000,$0000
	dc.l	$00011141
	dc.w	$0001,$0004,$0028,$0005
Objc000004:	dc.w	$0005,NIL,NIL,G_BOXCHAR,$0001,$0000
	dc.l	$41FF1100
	dc.w	$0001,$0001,$0002,$0001
Objc000005:	dc.w	$0006,NIL,NIL,G_BOXCHAR,$0001,$0000
	dc.l	$42FF1100
	dc.w	$0004,$0001,$0002,$0001
Objc000006:	dc.w	$0007,NIL,NIL,G_BOXCHAR,$0001,$0000
	dc.l	$43FF1100
	dc.w	$0007,$0001,$0002,$0001
Objc000007:	dc.w	$0008,NIL,NIL,G_BOXCHAR,$0001,$0000
	dc.l	$44FF1100
	dc.w	$000A,$0001,$0002,$0001
Objc000008:	dc.w	$0009,NIL,NIL,G_BOXCHAR,$0001,$0000
	dc.l	$45FF1100
	dc.w	$000D,$0001,$0002,$0001
Objc000009:	dc.w	$000A,NIL,NIL,G_BOXCHAR,$0001,$0000
	dc.l	$46FF1100
	dc.w	$0010,$0001,$0002,$0001
Objc00000A:	dc.w	$000B,NIL,NIL,G_BOXCHAR,$0001,$0000
	dc.l	$47FF1100
	dc.w	$0013,$0001,$0002,$0001
Objc00000B:	dc.w	$000C,NIL,NIL,G_BOXCHAR,$0001,$0000
	dc.l	$48FF1100
	dc.w	$0016,$0001,$0002,$0001
Objc00000C:	dc.w	$000D,NIL,NIL,G_BOXCHAR,$0001,$0000
	dc.l	$49FF1100
	dc.w	$0019,$0001,$0002,$0001
Objc00000D:	dc.w	$000E,NIL,NIL,G_BOXCHAR,$0001,$0000
	dc.l	$4AFF1100
	dc.w	$001C,$0001,$0002,$0001
Objc00000E:	dc.w	$000F,NIL,NIL,G_BOXCHAR,$0001,$0000
	dc.l	$4BFF1100
	dc.w	$001F,$0001,$0002,$0001
Objc00000F:	dc.w	$0010,NIL,NIL,G_BOXCHAR,$0001,$0000
	dc.l	$4CFF1100
	dc.w	$0022,$0001,$0002,$0001
Objc000010:	dc.w	$0011,NIL,NIL,G_BOXCHAR,$0001,$0000
	dc.l	$4DFF1100
	dc.w	$0025,$0001,$0002,$0001
Objc000011:	dc.w	$0012,NIL,NIL,G_BOXCHAR,$0001,$0000
	dc.l	$4EFF1100
	dc.w	$0001,$0003,$0002,$0001
Objc000012:	dc.w	$0013,NIL,NIL,G_BOXCHAR,$0001,$0000
	dc.l	$4FFF1100
	dc.w	$0004,$0003,$0002,$0001
Objc000013:	dc.w	$0014,NIL,NIL,G_BOXCHAR,$0001,$0000
	dc.l	$50FF1100
	dc.w	$0007,$0003,$0002,$0001
Objc000014:	dc.w	$0015,NIL,NIL,G_BOXCHAR,$0001,$0000
	dc.l	$51FF1100
	dc.w	$000A,$0003,$0002,$0001
Objc000015:	dc.w	$0016,NIL,NIL,G_BOXCHAR,$0001,$0000
	dc.l	$52FF1100
	dc.w	$000D,$0003,$0002,$0001
Objc000016:	dc.w	$0017,NIL,NIL,G_BOXCHAR,$0001,$0000
	dc.l	$53FF1100
	dc.w	$0010,$0003,$0002,$0001
Objc000017:	dc.w	$0018,NIL,NIL,G_BOXCHAR,$0001,$0000
	dc.l	$54FF1100
	dc.w	$0013,$0003,$0002,$0001
Objc000018:	dc.w	$0019,NIL,NIL,G_BOXCHAR,$0001,$0000
	dc.l	$55FF1100
	dc.w	$0016,$0003,$0002,$0001
Objc000019:	dc.w	$001A,NIL,NIL,G_BOXCHAR,$0001,$0000
	dc.l	$56FF1100
	dc.w	$0019,$0003,$0002,$0001
Objc00001A:	dc.w	$001B,NIL,NIL,G_BOXCHAR,$0001,$0000
	dc.l	$57FF1100
	dc.w	$001C,$0003,$0002,$0001
Objc00001B:	dc.w	$001C,NIL,NIL,G_BOXCHAR,$0001,$0000
	dc.l	$58FF1100
	dc.w	$001F,$0003,$0002,$0001
Objc00001C:	dc.w	$001D,NIL,NIL,G_BOXCHAR,$0001,$0000
	dc.l	$59FF1100
	dc.w	$0022,$0003,$0002,$0001
Objc00001D:	dc.w	$0003,NIL,NIL,G_BOXCHAR,$0001,$0000
	dc.l	$5AFF1100
	dc.w	$0025,$0003,$0002,$0001
Objc00001E:	dc.w	$001F,NIL,NIL,$2100+G_BUTTON,$0005,$0000
	dc.l	spec00001E
	dc.w	$0001,$000A,$000A,$0001
Objc00001F:	dc.w	$0020,NIL,NIL,$2200+G_BUTTON,$0005,$0000
	dc.l	spec00001F
	dc.w	$0013,$000A,$000C,$0001
Objc000020:	dc.w	$0021,NIL,NIL,G_STRING,$0805,$0000
	dc.l	spec000020
	dc.w	$0017,$0001,$0012,$0001
Objc000021:	dc.w	$0022,NIL,NIL,G_STRING,$0000,$0000
	dc.l	spec000021
	dc.w	$001A,$0002,$000D,$0001
Objc000022:	dc.w	$0000,NIL,NIL,G_BUTTON,$0827,$0000
	dc.l	spec000022
	dc.w	$0021,$000A,$0008,$0001

*******
*  -->>  Objektinhalte
*  -->>  Objektbaum $0
spec000001:	dc.b	'WProtect 1.03',0

	even	; TedInfo 000002
spec000002:	dc.l	te_t000002,te_m000002,te_v000002
	dc.w	$0005,$0006,$0000,$1180,$0000,$FFFF,$000B,$0001
te_t000002:	dc.b	'Laufwerke:',0
te_m000002:	dc.b	0
te_v000002:	dc.b	0


spec00001E:	dc.b	' Abbruch ',0

spec00001F:	dc.b	' Sichern ',0

spec000020:	dc.b	' Christoph Conrad ',0

spec000021:	dc.b	'MAUSnet @ AC3',0

spec000022:	dc.b	' Ok ',0


