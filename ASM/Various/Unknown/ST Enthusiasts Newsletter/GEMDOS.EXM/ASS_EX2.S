*	Check to see if the printer is on-line
*	and print an appropriate message.

*       Clear the screen for message.

	pea  clr  ,-(a7)      Clear the screen
	move.w #$09,-(a7)      GEMDOS #$09
	trap   #$01            call it,
	add.l  #$06,  a7       square up stack.

*       Call #$11 checks to see if the printer is 
*	on-line. It returns 0 in D.0 if not.

	move.w #$11,-(a7)      GEMDOS #$11
	trap   #$01 	      call it,
	add.l  #$02,  a7       square up stack.

*	Check returned value.

  	tst.l d0  	      Test to see if zero.

*       Select appropriate message.

	bne  online	      If not 0 printer is on.
	pea  off ,-(a7)       Put offline mess. onto stack.
	bra rest              Jump over next bit.

online  pea   on ,-(a7)       Put online mess. onto stack.

*	Print appropriate message.

rest	move.w #$09,-(a7)      GEMDOS #$09
	trap   #$01	      call it,
	add.l  #$06,  a7       square up stack.

*	Request key-press when ready to return.

	pea  any  ,-(a7)      Return to calling rotine
	move.w #$09,-(a7)      GEMDOS #$09
	trap   #$01    	       call it,
	add.l  #$06,  a7       square up stack.

*	On key-press return to calling routine.
*	(In this case, the desktop).

	move.w #$01,-(a7)      GEMDOS #$01
	trap   #$01            call it,
	add.l  #$02,  a        square up stack.

*	Return to desktop.

	move.w #$00,-(a7)      No error,
	move.w #$4c,-(a7)      GEMDOS #$4c
	trap   #$01            call it.
*	                       No stack to tidy.


*	Messages to be printed.
*	=======================

clr	dc.b  27,69,10,10,10,0

off	dc.b  "THE PRINTER IS OFF LINE.",13,10,10,0

on	dc.b  "OK! THE PRINTER IS ON LINE.",13,10,10,0

any	dc.b  "PRESS ANY KEY TO CONTINUE.",0
		
	end