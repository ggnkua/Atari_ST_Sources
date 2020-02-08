KILLheader			.equ	1

; **************** ROM PORT ****************************
RPORTaddress		.equ	$fb0000

RODDpicData			.equ	RPORTaddress+$0002
REVENpicData		.equ	RPORTaddress+$1002
RSTARTdigitiser		.equ	RPORTaddress+$a002
RGRABoddwrite		.equ	RPORTaddress+$b002
RGRABoddread		.equ	RPORTaddress+$3003
RGRABevenwrite		.equ	RPORTaddress+$c002
RGRABevenread		.equ	RPORTaddress+$4003
RPICformat			.equ    RPORTaddress+$d000
RVERSdigitiser		.equ    RPORTaddress+$7002

; **************** TC800 *******************************
PORTaddress		.equ	$fe200000

TCODDpicData		.equ	PORTaddress+$400	; long access!
GODDpicData			.equ	PORTaddress+$402	; word access!
TCEVENpicData		.equ	PORTaddress+$404	; long access!
GEVENpicData		.equ	PORTaddress+$406	; word access!
STARTdigitiser		.equ    PORTaddress+$408
GRABodd				.equ	PORTaddress+$40c    ; byte access!
GRABeven			.equ	PORTaddress+$410    ; byte access!
PICformat			.equ	PORTaddress+$417	; byte access
VERSdigitiser		.equ	PORTaddress+$41f    ; byte access!


; ***************** colour mode ***************************************
MAXdx				.equ	768				; no. of pixels from digitiser
HALFLINE			.equ	(MAXdx >> 1)	; 1/2 line        "     "
QUARTERLINE			.equ	(MAXdx >> 2)	; 1/4 line        "     "
EIGHTHLINE			.equ	(MAXdx >> 3)	; 1/8 line        "     "
SIXTEENTHLINE		.equ	(MAXdx >> 4)	; 1/16 line       "     "

; ***************** fast grey mode ************************************
PIXWIDTH			.equ	(MAXdx >> 1)		; width of line in pixels
HALFPIXWIDTH		.equ	(PIXWIDTH >> 1)		; width of line in pixels / 2
BYTEWIDTH			.equ	(PIXWIDTH >> 3)		; width of line in pixels / 8
WORDWIDTH			.equ	(PIXWIDTH >> 4)		; width of line in pixels / 16

RGBBlack			.equ	0					; colour black in RGB
