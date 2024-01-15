Proposed joystick driver for FreeMiNT
=====================================

What the heck?

  This is a proposed joystick driver for FreeMiNT (possibly MagiC?).
  I call it 'proposed' since we have no defined standard for this 
  type of device yet (afaik).

  It installs 4 devices as follows:

  	/dev/joypad0	- Joypad #0
  	/dev/joypad1	- Joypad #1
  	/dev/joya0	- Analog joystick on port #0
  	/dev/joya1	- Analog joystick on port #1

  These devices can (hopefully) be accessed in the same manner as 
  joysticks on a BSD-type system. It is also possible to access it in 
  a way similar to the old Linux implementation.
  I know there is a new way of using joysticks in Linux, but I 
  haven't implemented that (yet..).


System Requirements:
  
  This particular driver requires enhanced joystick prots a'la 
  F030/STE.


How to read joysticks using this driver:

  There are 2 modes of operation which are described below.

  BSD-style (FreeBSD/OpenBSD/NetBSD) joystick handling:

	Reading the joystick:

	1. Open one of the device files listed earlier
	2. Read 4 (32-bit) INTS.
  		1st int = x-axis value (0 - 255)
  		2nd int = y-axis value   - " -
  		3rd int = Button #1 value (1=pressed)
  		4th int = Button #2 value    - " -
  	3. When fed up with this stuff, close the device file.

 	There are 6 ioctl-commands:

	JOY_SETTIMEOUT		- not used in this driver
	JOY_GETTIMEOUT		-         - " -
	JOY_SET_X_OFFSET    	- Set X-calibration
	JOY_SET_Y_OFFSET	- Set Y-calibration
	JOY_GET_X_OFFSET	- Get X-calibration value
	JOY_GET_Y_OFFSET	- Get Y-calibration value

	I don't know if I've implemented this correctly...


  Linux-style (old implementation) joystick handling:

  	Reading the joystick:

  	1. Open one of the device files listed earlier
  	2. Read 3 (32-bit) INTS.

		1st int = bitfield with button values
		2nd int = x-axis value (0 - 255)
		3rd int = y-axis value (0 - 255)

	3. When done, close the device file

	There are 8 ioctl-commands:

	JS_SET_CAL		- not implemented yet
	JS_GET_CAL		-   - " -
	JS_SET_TIMEOUT		-   - " -
	JS_GET_TIMEOUT		-   - " -
	JS_SET_TIMELIMIT	-   - " -
	JS_GET_TIMELIMIT	-   - " -
	JS_GET_ALL		-   - " -
	JS_SET_ALL		-   - " -

	About the button-bitfield:

	  I don't know exactly how this is supposed to be
	  implemented, except that each button shall be represented
	  as a single bit in the field.

	  I chose the following layout:
		bits 0 - 3: Firebuttons
		bits 4 - 7: System buttons
		bits 8 -15: Unused
		bits 16-31: Special buttons

  Reading other sizes will not return any data in the current 
  implementation. I don´t know if this is really necessary anyway.


Sourcecode

  I've included the source code of this driver along with some test 
  utilities. Feel free to do whatever you want with it.

  The code is in a very early state. I'm sure there are lots of bugs
  that needs to be sorted out.


Thanks

  Draco, for your XDD-skeleton. I've mutilated it quite badly though.

Legal

  This is my first attempt at writing device drivers in any form.
  Don't blame me if something goes wrong when using this software. 


-- Peter Persson (pedda_pirat@hotmail.com)