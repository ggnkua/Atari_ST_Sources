*
*  Source-Datei erzeugt mit:
*  << Resource-to-Source Konverter >>
*  v1.17 ½ Dez 1991 by Bernd Eckstein
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

*******
*  -->>  Konstantendefinitionen:
DIALOG 	equ	0 	; /* form/dialog */
DRIVEA 	equ	4 	; /* BOXCHAR in tree DIALOG */
EXIT 	equ	30 	; /* BUTTON in tree DIALOG */
SAVE 	equ	31 	; /* BUTTON in tree DIALOG */
WIDMUNG 	equ	32 	; /* STRING in tree DIALOG */
OK 	equ	34 	; /* BUTTON in tree DIALOG */

sumTREES	equ	1	; Anzahl aller B„ume
OBJCs000	equ	35	; Objekte in Baum 1
sumOBJCS	equ	35	; Summe aller Objekte

*******
*  -->>  Objektbaum $0
Objc000000:	dc.w	$FFFF,$0001,$0022,$8900+G_BOX,$0000,$0010
	dc.l	$00021100
	dc.w	$0001,$0001,$002A,$000C
Objc000001:	dc.w	$0002,$FFFF,$FFFF,G_STRING,$0000,$0000
	dc.l	spec000001
	dc.w	$0001,$0001,$000D,$0001
Objc000002:	dc.w	$0003,$FFFF,$FFFF,G_TEXT,$0000,$0000
	dc.l	spec000002
	dc.w	$0001,$0003,$0407,$0001
Objc000003:	dc.w	$001E,$0004,$001D,G_BOX,$0000,$0000
	dc.l	$00011141
	dc.w	$0001,$0004,$0028,$0005
Objc000004:	dc.w	$0005,$FFFF,$FFFF,G_BOXCHAR,$0001,$0000
	dc.l	$41FF1100
	dc.w	$0001,$0001,$0002,$0001
Objc000005:	dc.w	$0006,$FFFF,$FFFF,G_BOXCHAR,$0001,$0000
	dc.l	$42FF1100
	dc.w	$0004,$0001,$0002,$0001
Objc000006:	dc.w	$0007,$FFFF,$FFFF,G_BOXCHAR,$0001,$0000
	dc.l	$43FF1100
	dc.w	$0007,$0001,$0002,$0001
Objc000007:	dc.w	$0008,$FFFF,$FFFF,G_BOXCHAR,$0001,$0000
	dc.l	$44FF1100
	dc.w	$000A,$0001,$0002,$0001
Objc000008:	dc.w	$0009,$FFFF,$FFFF,G_BOXCHAR,$0001,$0000
	dc.l	$45FF1100
	dc.w	$000D,$0001,$0002,$0001
Objc000009:	dc.w	$000A,$FFFF,$FFFF,G_BOXCHAR,$0001,$0000
	dc.l	$46FF1100
	dc.w	$0010,$0001,$0002,$0001
Objc00000A:	dc.w	$000B,$FFFF,$FFFF,G_BOXCHAR,$0001,$0000
	dc.l	$47FF1100
	dc.w	$0013,$0001,$0002,$0001
Objc00000B:	dc.w	$000C,$FFFF,$FFFF,G_BOXCHAR,$0001,$0000
	dc.l	$48FF1100
	dc.w	$0016,$0001,$0002,$0001
Objc00000C:	dc.w	$000D,$FFFF,$FFFF,G_BOXCHAR,$0001,$0000
	dc.l	$49FF1100
	dc.w	$0019,$0001,$0002,$0001
Objc00000D:	dc.w	$000E,$FFFF,$FFFF,G_BOXCHAR,$0001,$0000
	dc.l	$4AFF1100
	dc.w	$001C,$0001,$0002,$0001
Objc00000E:	dc.w	$000F,$FFFF,$FFFF,G_BOXCHAR,$0001,$0000
	dc.l	$4BFF1100
	dc.w	$001F,$0001,$0002,$0001
Objc00000F:	dc.w	$0010,$FFFF,$FFFF,G_BOXCHAR,$0001,$0000
	dc.l	$4CFF1100
	dc.w	$0022,$0001,$0002,$0001
Objc000010:	dc.w	$0011,$FFFF,$FFFF,G_BOXCHAR,$0001,$0000
	dc.l	$4DFF1100
	dc.w	$0025,$0001,$0002,$0001
Objc000011:	dc.w	$0012,$FFFF,$FFFF,G_BOXCHAR,$0001,$0000
	dc.l	$4EFF1100
	dc.w	$0001,$0003,$0002,$0001
Objc000012:	dc.w	$0013,$FFFF,$FFFF,G_BOXCHAR,$0001,$0000
	dc.l	$4FFF1100
	dc.w	$0004,$0003,$0002,$0001
Objc000013:	dc.w	$0014,$FFFF,$FFFF,G_BOXCHAR,$0001,$0000
	dc.l	$50FF1100
	dc.w	$0007,$0003,$0002,$0001
Objc000014:	dc.w	$0015,$FFFF,$FFFF,G_BOXCHAR,$0001,$0000
	dc.l	$51FF1100
	dc.w	$000A,$0003,$0002,$0001
Objc000015:	dc.w	$0016,$FFFF,$FFFF,G_BOXCHAR,$0001,$0000
	dc.l	$52FF1100
	dc.w	$000D,$0003,$0002,$0001
Objc000016:	dc.w	$0017,$FFFF,$FFFF,G_BOXCHAR,$0001,$0000
	dc.l	$53FF1100
	dc.w	$0010,$0003,$0002,$0001
Objc000017:	dc.w	$0018,$FFFF,$FFFF,G_BOXCHAR,$0001,$0000
	dc.l	$54FF1100
	dc.w	$0013,$0003,$0002,$0001
Objc000018:	dc.w	$0019,$FFFF,$FFFF,G_BOXCHAR,$0001,$0000
	dc.l	$55FF1100
	dc.w	$0016,$0003,$0002,$0001
Objc000019:	dc.w	$001A,$FFFF,$FFFF,G_BOXCHAR,$0001,$0000
	dc.l	$56FF1100
	dc.w	$0019,$0003,$0002,$0001
Objc00001A:	dc.w	$001B,$FFFF,$FFFF,G_BOXCHAR,$0001,$0000
	dc.l	$57FF1100
	dc.w	$001C,$0003,$0002,$0001
Objc00001B:	dc.w	$001C,$FFFF,$FFFF,G_BOXCHAR,$0001,$0000
	dc.l	$58FF1100
	dc.w	$001F,$0003,$0002,$0001
Objc00001C:	dc.w	$001D,$FFFF,$FFFF,G_BOXCHAR,$0001,$0000
	dc.l	$59FF1100
	dc.w	$0022,$0003,$0002,$0001
Objc00001D:	dc.w	$0003,$FFFF,$FFFF,G_BOXCHAR,$0001,$0000
	dc.l	$5AFF1100
	dc.w	$0025,$0003,$0002,$0001
Objc00001E:	dc.w	$001F,$FFFF,$FFFF,$2100+G_BUTTON,$0005,$0000
	dc.l	spec00001E
	dc.w	$0001,$000A,$000A,$0001
Objc00001F:	dc.w	$0020,$FFFF,$FFFF,$2200+G_BUTTON,$0005,$0000
	dc.l	spec00001F
	dc.w	$0013,$000A,$000C,$0001
Objc000020:	dc.w	$0021,$FFFF,$FFFF,G_STRING,$0805,$0000
	dc.l	spec000020
	dc.w	$0017,$0001,$0012,$0001
Objc000021:	dc.w	$0022,$FFFF,$FFFF,G_STRING,$0000,$0000
	dc.l	spec000021
	dc.w	$001A,$0002,$000D,$0001
Objc000022:	dc.w	$0000,$FFFF,$FFFF,G_BUTTON,$0827,$0000
	dc.l	spec000022
	dc.w	$0021,$000A,$0008,$0001

*******
*  -->>  Objektinhalte
*  -->>  Objektbaum $0
spec000001:	dc.b	'WProtect 1.02',0

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


