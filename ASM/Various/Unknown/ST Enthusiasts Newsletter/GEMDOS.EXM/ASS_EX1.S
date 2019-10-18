*       Print a string to the screen and wait for a key to be 
*	pressed before returning.
	
	pea    mess ,-(a7)       Push address of string onto stack
	move.w   #$09,-(a7)       Print string (null terminated)
	trap #$1                  Call GEMDOS #$09
	add.l    #$06,a7          Square up stack

	move.w   #$07,-(a7)       Wait for key to be pressed
	trap #$1			 Call GEMDOS #$07
	add.l    #$02,a7          Square up stack

	move.w   #$00,-(a7)       Return to desktop.
	trap #$1			 Call GEMDOS #$00
*				 No stack to square up

	
mess 	dc.b 27,69

*       27,69 = Clear screen and home cursor.

	dc.b 10,10,10

*       10,10,10 = Perform three line feeds.

	dc.b "  HI THERE! EASY ISN'T IT!",13,10,10
	dc.b "ANY KEY TO RETURN TO DESKTOP",0

*	The message to be printed.
*	13 = Carraige return.
*        0 = End of message.
	
	end


 