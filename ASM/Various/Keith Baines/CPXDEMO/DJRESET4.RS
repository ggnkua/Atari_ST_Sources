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





*****************************************************
** Resource data from file A:\CPXDEMO\DJRESET4.RSC **
*****************************************************



;-----------------;
; RSC File Header ;
;-----------------;

	DC.W	1		RSC File Version
	DC.W	$58		Start of Objects
	DC.W	$58		Start of TEDINFOs
	DC.W	$58		Start of ICONBLKs
	DC.W	$58		Start of BITBLKs
	DC.W	$58		List of free strings
	DC.W	$24		Start of string data
	DC.W	$58		Start of bit image data
	DC.W	$58		List of free images
	DC.W	$E8		List of Trees
	DC.W	6		Number of Objects
	DC.W	1		Number of Trees
	DC.W	0		Number of TEDINFOs
	DC.W	0		Number of ICONBLKs
	DC.W	0		Number of BITBLKs
	DC.W	0		Number of Free STrings
	DC.W	0		Number of Free Images
	DC.W	$EC		RSC File Length



;-------------;
; String Data ;
;-------------;

STR_24	DC.B	'OK',0
STR_27	DC.B	'Cancel',0
STR_2E	DC.B	'Reset the Centronics',0
STR_43	DC.B	'port for the Deskjet',0


;-------;
; Trees ;
;-------;

tr_CPXForm
	DC.W	-1,1,1,G_BOX
	DC.W	NONE
	DC.W	NORMAL
	DC.W	$1,$11C1
	DC.W	$0,$0,$20,$B
;  Object 1
	DC.W	0,2,5,G_BOX
	DC.W	NONE
	DC.W	NORMAL
	DC.W	$1,$1181
	DC.W	$2,$2,$1C,$7
;  Object 2
	DC.W	3,-1,-1,G_BUTTON
	DC.W	SELECTABLE+DEFAULT+EXIT
	DC.W	NORMAL
	DC.L	STR_24
	DC.W	$3,$5,$A,$1
;  Object 3
	DC.W	4,-1,-1,G_BUTTON
	DC.W	SELECTABLE+EXIT
	DC.W	NORMAL
	DC.L	STR_27
	DC.W	$10,$5,$A,$1
;  Object 4
	DC.W	5,-1,-1,G_STRING
	DC.W	NONE
	DC.W	NORMAL
	DC.L	STR_2E
	DC.W	$3,$1,$14,$1
;  Object 5
	DC.W	1,-1,-1,G_STRING
	DC.W	LASTOB
	DC.W	NORMAL
	DC.L	STR_43
	DC.W	$3,$2,$14,$1




;---------------;
; List Of Trees ;
;---------------;

LIST_E8	DC.L	tr_CPXForm



; ==== End of File ====
;