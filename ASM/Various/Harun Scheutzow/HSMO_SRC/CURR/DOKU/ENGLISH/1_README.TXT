English translation by Mick Lock verified by Peter West 1996,1997
-----------------------------------------------------------------


Modular (Serial) Device Driver
==============================

>> HSMODA07.LZH is an interim version. It doesn't have everything I'd like 
in it yet, but it does give all users the current state of development. 
There are some bug fixes. <<

Attention! On the 1994-12-30 I carried out a major change. Therefore DRVIN 
and drivers must be used together as either pre or post 1994-12-30 sets, 
and not a mixture of the two.

This package contains serial drivers for every type of interface or every 
interface component exisiting as a separate driver. The advantage for the 
user is that he only needs to select the correct driver for his setup. I 
use a  clean modular setup, therefore  you need to install the program 
(DRVIN.PRG) before the specific driver; this program provides those 
functions that are missing from the operating systems (TOS, Mag!X, MiNT) 
which supplement the drivers.

Sequence
--------
DRVIN.PRG must be loaded before the drivers. DRVIN and the drivers are 
best kept in he AUTO\ folder. They should be loaded as late as possible 
for maximum speed benefit. However DRVIN and the drivers must be loaded 
before any programs in the AUTO\ folder that use them. DRVIN.PRG is 
explained more fully in DRVIN.TXT. The individual drivers are named 
according to the names of the interfaces or interface ICs they support and 
are similarly explained in corresponding *.TXT files.

With a TOS version 2.0  or later, or by using  a similar Shell, you  can
easily check the sequence in the AUTO\ folder by switching the  display
of the directory listing to "unsorted". With older TOS versions you need
to copy all files to a different directory, then copy the files back one
by one in the order you wish them to be activated.

DRVIN should be activated after the following programs, if you should  
use them, otherwise problems can occur:

    - Overscan driver (when using the TOS1.4 fix)

    - FPATCH2.PRG on the Falcon (FPATCH1.PRG should not be used)


Configuration
-------------
The ability for the user to select the driver for his system already 
provides a certain amount of configuration. A more individual setup for 
the specific driver is often necessary due to the diversity of the 
hardware (or any enhancements), and to cater for dirty software, these 
additional settings are saved directly in the driver. Additional 
information  about specific configuration options are contained in the 
driver itself (in German with the more important parts translated to 
English). If you require more detail then refer to the specific driver 
*.TXT.

Configuration is achieved using the enclosed program SETTER.TTP, which is 
explained in more detail in SETTER.TXT. From TOS1.04 and up it is easy to 
use SETTER; simply drag the driver program to be configured to SETTER.TTP, 
it will load the driver program and either display the configuration 
dialogue or that which is not configurable; With old TOS versions you will 
have to activate SETTER by double clicking it and typing in the name and 
path of the driver file to be configured.


HSMODEM1 (compatibility)
------------------------
These drivers replace HSMODEM1. The BIOS function calls for MODEM1 are a 
little bit slower than those in HSMODEM1, because of the support for 
several interfaces. Those of  you who use an old program together with the 
last version (HSMOD105.LZH) of HSMODEM1 need not "update" to this version.

If MFP.PRG is the last or only driver loaded, then all programs which
run with HSMODEM1 should run with this driver.


Brief Instructions
------------------
This section describes the installation under TOS and Mag!X as briefly and 
clearly as possible. It should be read from start to finish, whilst 
installing and executing the program. 

You only install these drivers if the program you want to use has stated 
that these drivers are necessary or will provide advantages, or you have 
some other reason to install them. If you don't have a reason to install 
them, then  you should follow the text _without_ carrying out any actions.

If you have any programs in your AUTO\ folder that use the serial 
interface(s), then remove them elsewhere.

Remove all of your installed patch programs for the serial interface(s) 
(e.g. RS232ENC, TURBOCTS, SERIALFX), from the AUTO\ folder.

Select the driver you need. The following hints should help you:

Basic Equipment:
For ST, STE, MegaST: MFP.PRG
for MegaSTE:         MFP.PRG, SCC.PRG
for TT:              MFP.PRG, SCC.PRG, MFP_TT.PRG
for Falcon:          SCC.PRG

Additions & Enhancements:
If you have replaced the original 85C30 in your MegaSTE, TT or Falcon with 
a 85C230A or a Z85230, you can use ESCC.PRG instead of the SCC.PRG. The 
"computer in its original state" contains only a SCC, so only use the 
SCC.PRG in that case! 

If your Falcon has been modified to use the (normally unused) MFP serial 
interface (MODEM1), use MFP_FALC.PRG as well.
If you have installed the ST-ESCC hardware modification in your computer, 
use ES_ESCC.PRG in addition. Those who have made other interface  
modifications should read the documentation and can also ask me for 
advice.

The selected driver is configured using the SETTER.TTP, see above under 
"Configuration". To do this you have to answer the questions given, and 
select one of the options. Where you need additional information, you can 
find it in the *.TXT-Files corresponding to the driver you are 
configuring, e.g. in MFP.TXT for the MFP_FALC.PRG.

You copy DRVIN.PRG into the AUTO\ folder. You then copy the selected and 
configured drivers into the AUTO\ folder as well. The sequence of these 
drivers is unimportant. (This assumes that the User program is modern and 
error free. Otherwise this statement could prove to be false.)

The installation is now complete. Reboot your computer and test the 
drivers. When  you're happy it's running correctly, copy the serial 
interface-using programs you removed at the start back into the AUTO\ 
folder.

Copyright
---------
This driver package may be freely copied, under following conditions:

- The instructions and drivers are copied unchanged.
- The copies are free of charge, or at the usual PD disk rates.
- The distribution  with other PD and Shareware products is generally
  permitted.
- The distribution with commercial products is also permitted, but the 
  distributor or programmer must inform me about it (email is sufficient).
- Only copy single files in exceptional circumstances, because the 
  first-time user will have difficulty without the complete package.

Translations of the texts into other languages is explicitly desired. 
However the German originals must always be included.

Anyone who wishes to add files to this archive must identify them as his 
own.

I believe this version to be error free. I have tested it within the range 
of my capabilities. If however a fault does occur, please email or snail 
mail me with an exact description of it. I can only remove bugs that I can 
duplicate with help from the description provided.

I am not liable for any consequences through action or non function, 
experienced by use or non use, whole or in part of this package 
whatsoever.
                                                       
Product names and trademarks are used without guarantee of free 
useability.

The drivers and documentation were wrote in my spare time. There is no 
firm that pays me for that. My activities are supported  by the 
programmers using my drivers and the users sending me (good) bug reports. 
Here I want to thank those persons and also append an appeal: If somebody 
finds a mistake in these texts, has written a good example program that he 
wants to publish, improves the description or has translated to another 
language, should inform me. I'm interested in extending the scope of the 
package and in favour of complete documentation.) 

My addresses:

Mausnet: Harun Scheutzow @B
Internet: Harun_Scheutzow@B.Maus.De
(Because of  the limitations  in the  mausnet, PLEASE  DON'T send  mails
greater than 16kbyte) 
Postal  Address: 
Harun Scheutzow 
Dresdener  Straže 83 
D-10179 Berlin, Germany


Additional files
----------------
In addition to the drivers and their documentation, the following are 
included:
The program SETTER with its documentation.
The description of RSVF-Cookies in RSVF_COO.TXT.  
The proposed  hardware-independent software interface description for 
serial (and similar) interfaces SERSOFST.TXT

Versions
--------
I provide no version  numbers, but use  the date of  the program as  the 
criterion. I use the date in the form year, month, day, the date year is 
given as a four digit number, however under older TOS versions, this can 
change.

New  versions  are  found  first  on  Maus  Berlin3,  telephone   number 
+49-30-6249514, and will  be spread  throughout the Maus  boxes. If  the 
opportunity arises I'll also copy the current version onto the  internet 
server:  atari.archive.umich.edu.   You  should   look  for   the   file 
"HSMOD*.*". The archives will  be called HSMODAXX.LZH,  where xx is  the 
current publication number and the A for all interfaces.

