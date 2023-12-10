Since Eiffel 1.10, there are two HEX files for update the Firmware: 
 - The normal version eiffel.hex need a minimum a PIC programmed 
   with Eiffel 1.0.4 (backward compatibility).
 - The clock interrupt version eiffel_i.hex (who not lost seconds)  
   need a PIC programmed with Eiffel 1.10.
The Flash boot loader since Eiffel 1.10 displays the programming 
address, and 'OK' if the checksum is good on the LCD 2x16.

lcd.slb is a library for use all the LCD sreen from the Atari.
This library is for example used by Aniplayer 2.23.
You need to install E_TEMP.PRG inside the AUTO folder for get the 
temperature and install a serial buffer for send data to the IKBD.
The serial buffer reduce CPU load, because all characters are send
by interrupts.
