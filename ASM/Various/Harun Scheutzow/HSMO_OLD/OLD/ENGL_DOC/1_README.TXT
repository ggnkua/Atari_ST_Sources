Modular (Serial) Device Drivers
===============================

>> HSMODA07.LZH is a kind of intermediate release. It provides the current 
state of development to all users. There are some bug fixes. Sorry, but 
the English documentation is a bit outdated. <<

Attention! On 1994-12-30 I made a larger change. Only DRVIN and drivers
all written before the 1994-12-30 or all written on and after this date
will work togehter.

This package contains serial drivers. For every interface or every
interface integrated circuit exist an own driver. The user has to deal
with selecting the right drivers, but the advantage to load only the
drivers he needs. Because I use a clean modular design, a special program
(DRVIN.PRG) has to be loaded before the real drivers. This program adds
the functions for driver installations, which are absent in the operating
system (TOS, Mag!X, MiNT).

Order
-----
DRVIN.PRG has to be loaded before the drivers. DRVIN lays best in the
\AUTO\-folder together with the drivers. It should be loaded as late as
possible because of speed reasons, but before the drivers. DRVIN and the
drivers must be loaded before programs installed in the \AUTO\, which want
use the drivers. DRVIN.PRG is described in DRVIN.TXT. The drivers are
named according to the names of the interfaces or interface ICs and
described in the *.TXT-files with similar names.

With TOS version 2.0 or greater or a good shell it's easy to watch the
real order in the \AUTO\ by switching the display to "unordered /
unsorted". Under older TOS desktops you have to move all programs from
\AUTO\ into an other folder, so that \AUTO\ is empty, and then copy the
programs back into \AUTO\ in the wished order.

DRVIN shall be startet after the following programs if they are used,
because otherwise problems could occur:
- Overscan-driver (if TOS1.4-fix is on)
- FPATCH2.PRG on Falcon (FPATCH1.PRG should not be used in general)


Configuration
-------------
The selection of the drivers by the user allows a part of adaption to the
own system. A more individual adjustment of the drivers is often necessary
because of the various hardware(enhancements), but too because of dirty
software. These settings are saved direct in the drivers. The driver
contains additionally a short (German) explaination to every configuration
point. More information (English too) is contained in the *.TXT to the
driver.

The configuration is done by the program SETTER.TTP included in this
package. It is described in SETTER.TXT. From TOS1.04 up the use of SETTER
is simple: Take the program to modify with the mouse and drag it on
SETTER.TTP. SETTER will start, load the programm and start the
configuration dialog or give a message, that configuration is impossible
because the program doesn't contain any settings. For older versions of
TOS: doubleclick SETTER.TTP and enter the name and path of the program in
the appearing dialog box.


HSMODEM1 (-compatibility)
-------------------------
These drivers replace HSMODEM1. The BIOS function calls for MODEM1 are
because of the support of several interfaces a very little bit slower than
in HSMODEM1. Who uses exclusively a old program together with the last
HSMODEM1 version (HSMOD105.LZH), is not in need of updating to these
drivers.

If MFP.PRG is loaded as the only or the last driver, all old programs,
running with the HSMODEM1 versions, should work with MFP.PRG too.


Short Instruction
-----------------
This chapter shall describe the installation under TOS and Mag!X as short
and clear as possible. It should be seen as program and "executed" from
the start to the end.

You found in a program you want to use the hint that these drivers are
necessary or will provide enhancements. You have any other reason for
installing these drivers. If you have no reason for installation, you
should read this text without "action".

If you have any program in the \AUTO\-folder which uses the serial
interfaces, move it out from the \AUTO\.

Remove any installed patch programs for the serial interfaces, eg.
RS232ENC, TURBOCTS, SERIALFX, from \AUTO\.

Select the drivers you need of this package. The following hints shall
help you:

Basic equipment:
for ST, STE, MegaST: MFP.PRG
for MegaSTE:         MFP.PRG, SCC.PRG
for TT:              MFP.PRG, SCC.PRG, MFP_TT.PRG
for Falcon:          SCC.PRG

Additional or extended equipment:
 If you replaced the original 85C30 in your MegaSTE, TT or Falcon by an
Am85C230A or Z85230, you can use ESCC.PRG instead of SCC.PRG. In the state
of delivery these computers contain only a SCC, then use the SCC.PRG.
 If you modified your falcon by drawing out the MODEM1 interface not
existent in the original state, you can use additionally MFP_FALC.PRG for
this interface.
 Who installed the hardware ST_ESCC in his computer, uses additionally
ST_ESCC.PRG.
 Who has other interface modifications, should read the textes and may ask
me, if he finds nothing.

The configuration of the selected drivers is done by using SETTER.TTP, see
"Configuration" for details. You have to respond to the questions and
decide something. Often you can use the standard settings. If you need
additional information, you will find it in the *.TXT-files which are
named similar the drivers, eg. in MFP.TXT are informations about
MFP_FALC.PRG.

You copy DRVIN.PRG into the \AUTO\-folder. You copy the selected and
prepared drivers into \AUTO\. The order of the drivers is unimportant
(hoping, that the user programs are modern and error free, otherwise this
statement can be false).

The installation is complete. Reboot your computer and test the drivers.
When it runs correctly, copy the serial interface using program you
removed at the beginning back into \AUTO\.


Copyright
---------
This driver package may be freely copied under the following conditions:
- The documentation(s) and drivers are copied unchanged.
- The copies are free of charge or at the same price level as a PD-Disc.
- The distribution together with PD- and Shareware products is generally
  permitted.
- The distribution together with commercial products is permitted. But the
  distributor or programmer has to inform me (email is sufficent).
- Please copy single files only in exceptional situations because the
  first time user can't work with uncomplete packages.

Translations in other languages are expressly wished. But the German
original must stay included into the package.

Who wants to add files, has to mark these as his Addition.

I'm interested in an error free version of this software. I tested it in
the range of my opportunities. If errors occur, please send a detailed
report to my email- or post address. I can fix only bugs I can reproduce
or find by the description.

I'm not liable for any effects or no-effects equal of which kind caused by
the use or no-use of this package in part or whole.

Trademarks and Registered Trademarks are used without warrantee of free
usability.

These drivers and documentations I wrote in my spare time. There is no
firm, which pays me for that. My activities are supported by the
programmers using my drivers and the users sending me (good) bug reports.
At this place I want to thank these persons and append an appeal: If
somebody finds a mistake in these texts, wrote a good example program he
wants to publish, made the describtion better or more intelligible or
translated it, he/she/it should inform me. I'm interested in including
correct addings and programs. (I'm a friend of complete documentations,
others like examples more.)

My addresses:
Mausnet: Harun Scheutzow @B
Internet: Harun_Scheutzow@b.maus.de
(Because of the limitations in the mausnet, PLEASE DON'T send mails
greater than 16kbyte)
Post address:
Harun Scheutzow
Dresdener Straže 83
D-10179 Berlin, Germany

Translation
-----------

This documentation was translated to English by Harun Scheutzow and
Stefan Damerau
For comments about the translation send mail to:
MausNet:  Stefan Damerau @ SL
Internet: cookie@cookie.syd.de
      (or stefan_damerau@sl.maus.de but only mail < 16kB!!!)
Post address:
Stefan Damerau
Bergholm 31
D-24857 Fahrdorf, Germany


Further Files
-------------
The programm SETTER with documentation.
The description of the RSVF-Cookie RSVF_COO.TXT.
The proposal for a hardwareindependent softwareinterface to serial (and
similar) interfaces SERSOFST.TXT, which contains a German and an English
version.


Versions
--------
I give no version numbers, but use the date of the program printed out
during installation as criterion. I note the date as year-month-day with
an year number of four digits. The file date is only a bad replacement
because it can change during copying.

New versions are to find first in the Maus Berlin3, telefon number 
+49-30-6249514 (very often busy) an will spread about the Maus boxes. If I 
have the opportunity, I put the current version on the internet-server 
atari.archive.umich.edu. It should be looked for the file "HSMOD*.*". The 
archiv is named HSMODAxx, where A stands for all serial interfaces and xx 
for a running publication number.

---EOF---