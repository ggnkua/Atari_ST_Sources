LED Panel v3.0 (c) 1992-95 by Christoph Zwerschke
=================================================

Shortened version of the instructions in English.

Idea and Purpose of LED Panel
-----------------------------
The basic idea of "LED Panel" is to make any access to BIOS drives
(floppy, harddisk, RAM disk etc.) visible and that distinctively
between drives and kind of access (reading or writing). As extra
options the program moreover can show the state of the CapsLock
key as well as the actual date and time. All informations are
shown in the upper right corner of the screen (normally you can
only see the blank right end of the menu title line there).

Restrictions
------------
The LED Panel will not work with most sorts of graphic cards and
"true color". That's because LED Panel is a "TSR" program and
cannot use VDI graphics but writes directly to the screen instead.

The LED Panel Program
---------------------
The actual program which keeps itself resident in memory and shows
drive access on the screen is called "LEDPANEL.PRG". You can start
it from the desktop or put it into the AUTO folder, if you want it
to start automatically. LEDPANEL.PRG should run as one of the last
programs in the AUTO folder then.

The Configuration Program
-------------------------
The configuration of the running program and also the program file
can be set up by the program CONFIG.PRG. You can also rename the
program to CONFIG.ACC and use it as an accessory. Sorry, there is
no English version yet. When the program is startet, and the
LED-Panel isn't active, you are asked for the program file
LEDPANEL.PRG. The configuration then will be loaded from the
program file. Therefore don't "pack" the program file.

Then a dialog box called "LED-Panel Konfiguration" appears. You
can configurate LED-Panel individually with this dialog box. If
the LED Panel is active, you can watch the effects simultaneously
on the screen. Here is a short explanation of the buttons in the
dialog box (from top to bottom):

"Laufwerke:"
Use all effective BIOS drives (Button "angemeldete") or choose a
selection (with the Buttons on the right side).

"Verzîgern"
Choose LED luminous time delay.

"Abstand"
Distance of the LED Panel display to the right screen border.

"Caps"
Show state of CapsLock key.

"R/W"
Show "R" (read) and "W" (write) symbols.

"LEDs"
Show LEDs for all selected drives (A: is leftmost LED).

"Datum"
Show date. Over that you can choose the digit font and whether to
show years ("Jahr") or not.

"Zeit"
Show time. Over that you can choose the digit font and whether to
show seconds ("Sek") or not.

"2in1"
This button appears if you have selected "Zeit", but haven't
selected "Datum". In this case you can choose with this button,
whether to display date instead of time when the Alternate key
is pressed or not.

"Clock symbol"
With this button and some other noncaptioned buttons you can make
small spaces to enhance lucidity.

"LÅcken"
Show space instead of LED if a drive is not used or not selected.

"B aus"
Sum up access to both floppy drives to one LED.

"runde LEDs"
Choose LED shape, either cornered or round.

"Zusatz-LÅcken"
Show extra spaces between LEDs. "Åberall" means spacing for every
LED. You can also choose extra space for two particular drives.

"Anzahl Zeilen"
Choose either one ("eine") or two ("zwei") lines of LEDs. If you
choose two, the upper line stands for read access and the lower
line for write access. If you select "passend", the number of
lines will be automatically fit to the height of the menu title
line due to the current screen resolution.

"Hintergrund schwarz"
Choose background color as either black or white.

"farbige LEDs"
Select whether color shall be used to distinguish between read
access (green) and write access (red).

"Help"
Display help dialog.

"Undo"
Undo all configuration changes made in the dialog box.

"Anzeige aktiv"
LED Panel display active or inactive.

"Einlesen"
Read configuration from the program file LEDPANEL.PRG.

"Speichern"
Save configuration to the program file LEDPANEL.PRG.

"OK"
Leave the dialog box.

LED-Panel "light"
-----------------
LEDLIGHT.PRG is a "light" version of LEDPANEL.PRG. It can only do
the basic funktions of the LED Panel. If you want to install more
than one LED Panel at a time (maybe one before and one after a
harddisk cache program) you have to change the identification of
one of the programs from "LEDP" to something else (but you will
have to use a disk monitor program for that). You can also make a
copy of CONFIG.PRG with the different identification. Normally
only one LED Panel at a time is allowed.

LED-Panel CPX module
--------------------
If you use the XControl accessory, you can configurate LED-Panel 
also using the LEDPANEL.CPX module by Th. Morus Walter.

"Cookie Interface"
------------------
The file LEDPANEL.H is the C header file and likewise the
documentation for the "cookie interface" to LED-Panel.

Liability Disclaimer
--------------------
As always: The author disclaims any liability for any harm due to
the use of the LED panel.

Copyright
---------
Copyright (c) 1992-95 by Christoph Zwerschke. All rights reserved.

Now for something gratifying: "LED panel" is a "Public Domain"
program. It may be copied and given away as long as it stays in
a non commercial scale. If you like the program, you can write
to me and send a small donation.

The Author's Address
--------------------
The programmer on duty:

    Christoph Zwerschke             Banking account:
    Am Steinfeld 4                  Bezirkssparkasse Heidelberg
    59379 Selm-Cappenberg           BLZ 67250020
    Germany                         Account no. 4338405

