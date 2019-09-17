; RSC_TO_S -- Version 1.00   by Keith Baines  3rd January 1993
; 
; 29-01-1995

G_BOX	EQU	20
G_TEXT	EQU	21
G_BOXTEXT	EQU	22
G_IMAGE	EQU	23
G_PROGDEF	EQU	24
G_IBOX	EQU	25
G_BUTTON	EQU	26
G_BOXCHAR	EQU	27
G_STRING	EQU	28
G_FTEXT	EQU	29
G_FBOXTEXT	EQU	30
G_ICON	EQU	31
G_TITLE	EQU	32

NONE	EQU	0
SELECTABLE	EQU	1
DEFAULT	EQU	2
EXIT	EQU	4
EDITABLE	EQU	8
RBUTTON	EQU	16
LASTOB	EQU	32
TOUCHEXIT	EQU	64
HIDDEN	EQU	128
INDIRECT	EQU	256

NORMAL	EQU	0
SELECTED	EQU	1
CROSSED	EQU	2
CHECKED	EQU	4
DISABLED	EQU	8
OUTLINED	EQU	16
SHADOWED	EQU	32





*************************************************
** Resource data from file A:\RSCDEMO\DEMO.RSC **
*************************************************



;-----------------;
; RSC File Header ;
;-----------------;

	DC.W	1		RSC File Version
	DC.W	$11A		Start of Objects
	DC.W	$F0		Start of TEDINFOs
	DC.W	$10C		Start of ICONBLKs
	DC.W	$10C		Start of BITBLKs
	DC.W	$F0		List of free strings
	DC.W	$24		Start of string data
	DC.W	$80		Start of bit image data
	DC.W	$11A		List of free images
	DC.W	$222		List of Trees
	DC.W	11		Number of Objects
	DC.W	2		Number of Trees
	DC.W	1		Number of TEDINFOs
	DC.W	0		Number of ICONBLKs
	DC.W	1		Number of BITBLKs
	DC.W	0		Number of Free STrings
	DC.W	0		Number of Free Images
	DC.W	$22A		RSC File Length



;-------------;
; String Data ;
;-------------;

STR_24	DC.B	'Resouces Demo',0
STR_32	DC.B	'for Ictari',0
STR_3D	DC.B	'by Keith Baines',0
STR_4D	DC.B	'January 1995',0
STR_5A	DC.B	'OK',0
STR_5D	DC.B	'OK',0
STR_60	DC.B	'Some Small Text',0
STR_70	DC.B	0
STR_71	DC.B	0
STR_72	DC.B	'And an Image:',0


;----------------;
; Bit Image Data ;
;----------------;

;  32 Wide by 28 High
IMG_80	DC.W	$0,$0
	DC.W	$ED9,$8CE0
	DC.W	$4AA,$5080
	DC.W	$4AA,$5080
	DC.W	$48B,$D6C0
	DC.W	$48A,$5280
	DC.W	$48A,$5280
	DC.W	$E8A,$4CE0
	DC.W	$0,$0
	DC.W	$7FFF,$FFFC
	DC.W	$4000,$4
	DC.W	$4000,$4
	DC.W	$4E51,$8CE4
	DC.W	$44AA,$5084
	DC.W	$44AA,$5084
	DC.W	$44AA,$5084
	DC.W	$44AA,$5084
	DC.W	$448A,$50C4
	DC.W	$448B,$D684
	DC.W	$448A,$5284
	DC.W	$448A,$5284
	DC.W	$448A,$5284
	DC.W	$4E8A,$4CE4
	DC.W	$4000,$4
	DC.W	$5FFF,$FFF4
	DC.W	$4000,$4
	DC.W	$7FFF,$FFFC
	DC.W	$0,$0



;----------;
; TEDINFOs ;
;----------;

TED_F0	DC.L	STR_60,STR_70,STR_71
	DC.W	$5,$0,$2,$1181,$0,$0,$10,$1




;---------;
; BITBLKs ;
;---------;

BITBLK_10C	DC.L	IMG_80
	DC.W	$4,$1C,$0,$0,$1




;-------;
; Trees ;
;-------;

tr_FirstDialog
	DC.W	-1,1,5,G_BOX
	DC.W	NONE
	DC.W	OUTLINED
	DC.W	$2,$1181
	DC.W	$11,$303,$1B,$C
;  Object 1
	DC.W	2,-1,-1,G_STRING
	DC.W	NONE
	DC.W	NORMAL
	DC.L	STR_24
	DC.W	$7,$1,$D,$1
;  Object 2
	DC.W	3,-1,-1,G_STRING
	DC.W	NONE
	DC.W	NORMAL
	DC.L	STR_32
	DC.W	$8,$3,$A,$1
;  Object 3
	DC.W	4,-1,-1,G_STRING
	DC.W	NONE
	DC.W	NORMAL
	DC.L	STR_3D
	DC.W	$6,$5,$F,$1
;  Object 4
	DC.W	5,-1,-1,G_STRING
	DC.W	NONE
	DC.W	NORMAL
	DC.L	STR_4D
	DC.W	$8,$7,$C,$1
;  Object 5
	DC.W	0,-1,-1,G_BUTTON
	DC.W	SELECTABLE+DEFAULT+EXIT+LASTOB
	DC.W	NORMAL
	DC.L	STR_5A
	DC.W	$9,$A,$A,$1


tr_SecondDialog
	DC.W	-1,1,4,G_BOX
	DC.W	NONE
	DC.W	OUTLINED
	DC.W	$2,$1181
	DC.W	$712,$307,$19,$609
;  Object 1
	DC.W	2,-1,-1,G_BUTTON
	DC.W	SELECTABLE+DEFAULT+EXIT
	DC.W	NORMAL
	DC.L	STR_5D
	DC.W	$7,$7,$B,$1
;  Object 2
	DC.W	3,-1,-1,G_TEXT
	DC.W	NONE
	DC.W	NORMAL
	DC.L	TED_F0
	DC.W	$1,$1,$17,$1
;  Object 3
	DC.W	4,-1,-1,G_STRING
	DC.W	NONE
	DC.W	NORMAL
	DC.L	STR_72
	DC.W	$3,$4,$D,$1
;  Object 4
	DC.W	0,-1,-1,G_IMAGE
	DC.W	LASTOB
	DC.W	NORMAL
	DC.L	BITBLK_10C
	DC.W	$13,$4,$4,$2




;---------------;
; List Of Trees ;
;---------------;

LIST_222	DC.L	tr_FirstDialog
	DC.L	tr_SecondDialog



; ==== End of File ====
;