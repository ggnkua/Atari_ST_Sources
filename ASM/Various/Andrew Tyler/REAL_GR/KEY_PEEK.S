* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
* Copyright A.Tyler 1991 key_peek.s                                 *
* A program to find where the codes from the keyboard, joystick     *
* and mouse are kept.                                               * 
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

* This is a very long program!
* Run it in the monitor or debugger and having selected the part of RAM
* to look at (around $e40) press the CONTROL and Z keys simultaneously.
* While the program is running you can also press any key or mouse button,
* or waggle the joystick and see where data appears. Then you know where 
* to find it for your programs.

main	bra	main
	END
