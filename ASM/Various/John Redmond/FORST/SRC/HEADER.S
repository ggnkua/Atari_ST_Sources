; HEADER.S: TOS header for file
; Copyright <C> John Redmond 1989, 1990
; Public domain for non-commercial use.
;
	section	text
	even
;
index:  dc.w    $601a	       ;BRA.S flag
	dc.l    0	       ;code space
	dc.l    0	       ;data space
	dc.l    wspace+hspace  ;bss space
	dc.l    0,0,0
	dc.w    $ffff	       ;relocation flag
;
;********************************************************;
;							 ;
; Absolute entry and exit for ForST			 ;
;							 ;
;********************************************************;
;
	bra     setup
cold:   bsr     init
	lea     auto,a0
	move.l  (a0),d0
	beq     start	   ;no autoexecute
	jsr     0(a5,d0.l)
	bra     endup
;
start:  lea     signon,a0       ;Forth message
	push    a0
	bsr     _message
;
warm:   bsr     outer	   ;outer interpreter loop
finish: bsr     endup
;
