**
**	$Filename: devices/inputevent.i $
**	$Release: 1.3 $
**
**	input event definitions	 
**
**	(C) Copyright 1985,1986,1987,1988 Commodore-Amiga, Inc.
**	    All Rights Reserved
**

*------ constants ----------------------------------------------------
  
*   --- InputEvent.ie_Class ---
* A NOP input event
IECLASS_NULL		EQU   $00
* A raw keycode from the keyboard device
IECLASS_RAWKEY		EQU   $01
* A raw mouse report from the game port device
IECLASS_RAWMOUSE	EQU   $02
* A private console event
IECLASS_EVENT		EQU   $03
* A Pointer Position report
IECLASS_POINTERPOS	EQU   $04
* A timer event
IECLASS_TIMER		EQU   $06
* select button pressed down over a Gadget (address in ie_EventAddress)
IECLASS_GADGETDOWN	EQU $07
* select button released over the same Gadget (address in ie_EventAddress)
IECLASS_GADGETUP	EQU   $08
* some Requester activity has taken place.  See Codes REQCLEAR and REQSET
IECLASS_REQUESTER	EQU   $09
* this is a Menu Number transmission (Menu number is in ie_Code)
IECLASS_MENULIST	EQU   $0A
* User has selected the active Window's Close Gadget
IECLASS_CLOSEWINDOW	EQU   $0B
* this Window has a new size
IECLASS_SIZEWINDOW	EQU   $0C
* the Window pointed to by ie_EventAddress needs to be refreshed
IECLASS_REFRESHWINDOW	EQU   $0D
* new preferences are available
IECLASS_NEWPREFS	EQU   $0E
* the disk has been removed
IECLASS_DISKREMOVED	EQU   $0F
* the disk has been inserted
IECLASS_DISKINSERTED	EQU   $10
* the window is about to be been made active
IECLASS_ACTIVEWINDOW	EQU   $11
* the window is about to be made inactive
IECLASS_INACTIVEWINDOW	EQU   $12

* the last class
IECLASS_MAX		EQU   $12

*   --- InputEvent.ie_Code --- 
*  IECLASS_RAWKEY
IECODE_UP_PREFIX	EQU   $80
IECODEB_UP_PREFIX	EQU   7
IECODE_KEY_CODE_FIRST	EQU   $00
IECODE_KEY_CODE_LAST	EQU   $77
IECODE_COMM_CODE_FIRST	EQU   $78
IECODE_COMM_CODE_LAST	EQU   $7F
  
*  IECLASS_ANSI
IECODE_C0_FIRST		EQU   $00
IECODE_C0_LAST		EQU   $1F
IECODE_ASCII_FIRST	EQU   $20
IECODE_ASCII_LAST	EQU   $7E
IECODE_ASCII_DEL	EQU   $7F
IECODE_C1_FIRST		EQU   $80
IECODE_C1_LAST		EQU   $9F
IECODE_LATIN1_FIRST	EQU   $A0
IECODE_LATIN1_LAST	EQU   $FF
  
*  IECLASS_RAWMOUSE
IECODE_LBUTTON		EQU   $68  ; also uses IECODE_UP_PREFIX
IECODE_RBUTTON		EQU   $69  ;
IECODE_MBUTTON		EQU   $6A  ;
IECODE_NOBUTTON		EQU   $FF
  
*  IECLASS_EVENT
IECODE_NEWACTIVE	EQU   $01  ; active input window changed

*  IECLASS_REQUESTER Codes
* REQSET is broadcast when the first Requester (not subsequent ones) opens
* in the Window
IECODE_REQSET		EQU   $01
* REQCLEAR is broadcast when the last Requester clears out of the Window
IECODE_REQCLEAR		EQU   $00

  
*   --- InputEvent.ie_Qualifier ---
IEQUALIFIER_LSHIFT	EQU   $0001
IEQUALIFIERB_LSHIFT	EQU   0
IEQUALIFIER_RSHIFT	EQU   $0002
IEQUALIFIERB_RSHIFT	EQU   1
IEQUALIFIER_CAPSLOCK	EQU   $0004
IEQUALIFIERB_CAPSLOCK	EQU   2
IEQUALIFIER_CONTROL	EQU   $0008
IEQUALIFIERB_CONTROL	EQU   3
IEQUALIFIER_LALT	EQU   $0010
IEQUALIFIERB_LALT	EQU   4
IEQUALIFIER_RALT	EQU   $0020
IEQUALIFIERB_RALT	EQU   5
IEQUALIFIER_LCOMMAND	EQU   $0040
IEQUALIFIERB_LCOMMAND	EQU   6
IEQUALIFIER_RCOMMAND	EQU   $0080
IEQUALIFIERB_RCOMMAND	EQU   7
IEQUALIFIER_NUMERICPAD	EQU   $0100
IEQUALIFIERB_NUMERICPAD EQU   8
IEQUALIFIER_REPEAT	EQU   $0200
IEQUALIFIERB_REPEAT	EQU   9
IEQUALIFIER_INTERRUPT	EQU   $0400
IEQUALIFIERB_INTERRUPT	EQU   10
IEQUALIFIER_MULTIBROADCAST    EQU   $0800
IEQUALIFIERB_MULTIBROADCAST   EQU   11
IEQUALIFIER_MIDBUTTON	EQU   $1000
IEQUALIFIERB_MIDBUTTON	EQU   12
IEQUALIFIER_RBUTTON	EQU   $2000
IEQUALIFIERB_RBUTTON	EQU   13
IEQUALIFIER_LEFTBUTTON	EQU   $4000
IEQUALIFIERB_LEFTBUTTON EQU   14
IEQUALIFIER_RELATIVEMOUSE     EQU   $8000
IEQUALIFIERB_RELATIVEMOUSE    EQU   15
  

* STRUCTURE  InputEvent,0
*   APTR	 ie_NextEvent	      ; the chronologically next event
*   UBYTE   ie_Class	              ; the input event class 
*   UBYTE   ie_SubClass	              ; optional subclass of the class
*   UWORD   ie_Code	              ; the input event code
*   UWORD   ie_Qualifier	      ; qualifiers in effect for the event
*   LABEL ie_EventAddress             ; a pointer parameter for an event
*   WORD	   ie_X		      ; the pointer position for the event,
*   WORD	   ie_Y		      ;	  usually in canvas relative coords 
*   STRUCT  ie_TimeStamp,TV_SIZE      ; the system tick at the event
*   LABEL   ie_SIZEOF

Ie_NextEvent		equ 	0
Ie_Class		equ	4
Ie_SubClass		equ 	5
Ie_Code			equ 	6
Ie_Qualifier		equ	8
Ie_EventAddress		equ	10
Ie_X			equ	14
Ie_Y			equ	16

* Functions
cmnstd		equ 	9
addhandler	equ 	cmnstd+0
remhandler	equ	cmnstd+1
setthresh	equ	cmnstd+3
setperiod	equ	cmnstd+4
* Message port
Lof_msg		equ	$20
* StdIo
io_command	equ	$1c
io_data		equ 	$28
tv_secs		equ	$20
tv_micro	equ	$24
Lof_io		equ 	$30
* Interrupt
ln_type		equ	$08
ln_pri		equ 	$09
ln_name		equ	$0a
is_data		equ 	$0e
is_code		equ	$12
Lof_is		equ	$22

