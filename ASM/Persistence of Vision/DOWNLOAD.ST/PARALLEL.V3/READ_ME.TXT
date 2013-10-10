Hi Mark!


Here is Version 3.00 of the Widget Downloader.
This should work for any 8mhz ST.

For other speed machines (e.g. Falcon) the delays in TRANSMIT.S need
to be changed until the communication works!

WAKEUP_DELAY - This should be large enough for the receiving machine to
'see' the wake-up code on the parallel port between trap #0 calls. It
also allows the receiver to clear the screen, etc. and prepare for a
download.
If you are only calling trap #0 every few VBLs (e.g. 3D stuff) then
this value should be very large.

NORMAL_DELAY - This is the transmit delay between each nibble. Set this
as small as you can for the sending machine. If it is too small, the
receiver will print an error message.
As a guide, this value is 164 on my 66mhz 486 PC.

INFO_DELAY - After the wake-up call, the start address, data length and
execution address is downloaded. Because it is doing a bit more than
when it is downloading the data block, set this to a bit more than
NORMAL_DELAY.


If you have any problems getting it to work on your machines please
phone or email me.


THIS VERSION NOT FOR DISTRIBUTION!

Please don't spread this version as it's messy and not in a state to be
supported. After some more changes, it will be ok.


Please suggest features to enhance this downloader.

Some of my suggestions:

	Don't use OS to setup or print info on the receiver. Do this
	direct to screen, etc..

	After wake-up, receiver should reset as much of hardware as
	necessary. This will need machine specific versions - but
	that's ok.

	Error trapping with register & stack dumping.

	Change delays to use of an MFP timer.
	Which timer to use?
	Do all Atari machines use the timers? (i.e. will this technique
	work on all machines)
	This will remove the need to change delays between machines.

	Change the background colour on download?


Boris (POV)
