




                                               START, The ST Quarterly
                                               Fall 1986: Volume 1, #2



     To compile any of the programs included on this disk, you will
need the following program files from the Developer's Toolkit:


cp68.prg      C preprocessor
c068.prg      C parser
c168.prg      C code generator
as68.prg      MC68000 assembler
link68.prg    ST linker program
relmod.prg    ST relocation program

     To use the batch files included in each folder, you will need
these programs as well:


batch.prg     ST batch processing program
rm.prg        ST delete (ReMove) file program
wait.prg      ST wait to return to Desktop

     In each START folder you will find one or more .BAT files.  If
every necessary file is on the default drive, each program can be
compiled and linked by running batch.prg with this .BAT file as the
parameter.


     Although not every program requires these header files to
compile, following is an exhaustive list of every system header file
used by every program included on this disk.  By "system header file"
we mean header files provided with the developer's toolkit, and not
any header files a programmer may have created for the specific
program.


portab.h       - definitions intended to assist in writing
                 portable code (from IBM to ST)
machine.h      - intended to assist in porting between 8086
                 and 68000
gembind.h      - GEM procedure bindings and other GEM
                 things
gemdefs.h      - common GEM definitions from AES manual
obdefs.h       - GEM object definitions
osbind.h       - definitions useful for using osbind.o
                 (GEMDOS)
vdibind.h      - extern declarations for GEM VDI procedure
                 calls
taddr.h        - another way to get to the GEM object
                 structure

     Look for the #INCLUDE instructions in a particular program's
listing to determine what specific system header files will be needed











on the compile disk.


     Although not every program requires link files (by which we mean
object and library files necessary to link) following is a list of
every link file necessary to produce any program included on this
disk:


accstart.o     - accessory program startup
apstart.o      - application program startup
gems.o         - standard C lib. routines (printf, etc.)
gemstart.o     - non-gem program startup
osbind.o       - calls for Atari TOS and bios traps
libf           - floating point library
vdibind        - GEM VDI call bindings
aesbind        - GEM AES call bindings

     See the associated batch files for a list of the specific link
files necessary for a particular program.


     Note that some may use separate resource files.  In some cases,
the resource file C sources are included.  In all cases, at least the
.RSC file itself is included.


     Creating a .RSC file from the sources is a difficult thing to do.
We suggest you use DRI's resource editor (on the sources, of course)
if you want to change any of these separate resources.


     All of these programs work with Alcyon C, the compiler provided
with the Developer's Toolkit.  Note that Atari officially recognizes
only two versions of the Developer's Kit.  Atari released Alcyon
version 4.14 as the magazine went to press.  Some programs may need
modification to run on this most recent version.  However, all run on
the current, and most popular version.  Many of the programs will also
compile immediately with Megamax C.



























                       SUBSCRIPTION INFORMATION


All programs, object code, source code, and text files contained on
this disk are (C) Copyright 1986 by Antic Publishing and, unless
otherwise noted, are NOT to be considered as part of the public
domain.

START, The ST Quarterly is a magazine with disk that is published four
times per year by Antic Publishing, 524 Second Street, San Francisco,
CA  94107.

SUBSCRIPTIONS TO START:

    --- One year (4 issues) of START, The ST Quarterly, (magazine + 3
1/2 inch disk) for $59.95.  Act now and receive, absolutely free, 12
issues of ANTIC, including the ST Resource each issue. (Current Antic
subscriptions extended 12 additional issues.)

    --- One year (4 issues) of START, The ST Quarterly, (magazine + 3
1/2 inch disk), plus 12 issues of ANTIC's Action Edition (magazine + 5
1/4 inch disk), for $149.95. (Current Antic disk subscriptions
extended 12 additional issues.)

     Send check or money order to:


                         START SUBSCRIPTIONS
                          524 Second Street
                       San Francisco, CA  94107

    (All orders must be prepaid.  Add $25.00 postage for foreign
subscriptions per year.  Please allow 4-6 weeks for delivery of your
first issue.)

     Back issues of START magazine and disks or additional copies of
the current disk may be purchased by sending $5.00 per magazine, or
$10.95 for disk plus $2.00 for postage and handling per order, to
START DISK, 524 Second St., San Fransisco, CA  94107, or call (800)
443-0100 ext. 133.


TO SUBSCRIBE, call toll free:  (800) 443-0100 ext. 133.

TO ORDER SOFTWARE FROM "The Catalog":  call (800) 443-0100 ext. 133.

CUSTOMER SERVICE:  call (415) 957-0886, 8:00 a.m. to 1:00 p.m. Pacific
Time, Monday through Friday. (Please do not call the 800 number for
Customer Service, thank you.)

COMPUSERVE for ANTIC ONLINE:  type GO ANTIC.










