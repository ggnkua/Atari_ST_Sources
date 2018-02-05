	PS2 -> Atari /Amiga Mouse Adapter
        ~~~~~~~~~~~~~~~~~~~~~~~


	Version 1.1 September 2004


Due to the short supply of mice for the Atari computers I decided to build an adapter that would allow me to use a serial mouse on my Atari, but even these are getting a bit old now, so I got the soldering iron out again and here's the result. A PS2 Mouse adapter for the Atari. It supports a standard PS2 mouse with 2 or 3 buttons and can also be used with the Microsoft optical IntelliMouse that comes with a USB to PS2 adapter. The middle button on the PS2 mouse is used as a left click and hold function for easy selection. Click the middle button again to release. Now for the bad news, for some reason Microsoft mice don't support the middle button in standard PS2 mode. :-(

Please don't shout at me all you Atari users but as an added feature if you change a link then the adapter can be used with an Amiga as well.


All files, programs etc contained in this archive are copright 2004 by Tom Kirk. Personal use is allowed but any commercial use is not allowed. Please feel free to use my work but don't rip me off. 



	Files in this archive.
        ~~~~~~~~~~~~~~~~~~~~~~

readme.txt		This text file
circuit.bmp		Picture of circuit in bitmap format
PS2Atari_v1_1.hex	Object code of the PIC16F84 program in Intel hex
PS2Atari_v!_1.asm	Source code of the PIC16F84 program
pcbtop.bmp		Top layer of the PCB in bitmap format
pcbbot.bmp		Bottom layer of the PCB in bitmap format



	Technical Details.
	~~~~~~~~~~~~~~~~~~
	
When the PS2 mouse is moved or a button changes state a packet of data is sent, my circuit decodes this data and then simulates the Atari mouse.

The circuit consists of a single microcontroller that contains a program to do the conversion. The circuit is shown in the file circuit.bmp

The microcontroller (PIC) can be either a PIC16C84 or PIC16F84 or PIC16F84A.
 
The PIC (IC1) needs to be programmed with the program.
The program is supplied in two forms PS2Atari_v1_1.hex is an object code file in Intel hex and can be read by most programmers capable of programming the PIC

PS2Atari_v1_1.asm is the source code of the program and could be used with a PIC assembler to generate your own object file.

The Source code has been written using the free MPLAB software from Microchip.

The PIC should be programmed with oscillator as XT, watchdog disabled, powerup timer enabled and code protection off. (No point code protecting a freely available program.)

The source code and object code is compatible with all the PIC microcontrollers listed above. 

I've built mine using a printed circuit board but it's small enough to be built using a small piece of stripboard.

On my PCB I have a 6 pin mini din socket at one end and a 9 pin D type socket at the other. I can then use a standard port extender lead to connect to the Atari. I've found that a 9 pin PC serial extension lead can also be used for this as well if you remove the fastening screws.

If you decide to build one on a piece of stripboard it will be easier to use cable mounted sockets as PCB types don't fit onto a stripboard.

Once built the board can be mounted into a small plastic box.

No special software is required on the Atari and it will work with all software.
Your favourite mouse accelerator program may be used if required.



	Parts list.
	~~~~~~~~~~~

IC1	PIC16F84A or PIC16F84 or PIC16C84

Fi1	4 MHz Ceramic resonator

R1	10K
R2	10K 

C1	4.7 uF
C2	0.1 uF

All capacitors should be rated at 16V or more.

CN1	6 pin mini din PCB mounting socket
CN2	9 Pin D type PCB mounting socket


JP1	3 pin header and 2 way link


If building on a piece of stripboard I suggest using cable mounting types of connectors and use a small piece of multicore cable between the sockets and the stripboard. You will find the PCB sockets do not fit on a piece of stripboard. 

If you don't need the switchable Atari/Amiga support forget the 3 pin header and just use a wire link instead.



	History.
	~~~~~~~~

Version 1.1 Released September 2004.
Added support for the Amiga and added the middle button support.

Version 1.0 Never released.
My original version for the Atari only.



	Help.
	~~~~~

If you need further information or help then contact me at tgkirk@aol.com  

Please allow a few days for a reply as I have other commitments as well.

		Tom Kirk        September 2004

P.S. 	I also have on my web site a PC viewer for Atari format picture files.
	
	http://members.aol.com/tgkirk
 
