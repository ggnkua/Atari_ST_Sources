AUTOMATION 5.0.1 PACKER
~~~~~~~~~~~~~~~~~~~~~~~

Hi Guys.....

EGB brings you yet more useful goodies
for your ST. This time it is the latest
version of the Automation packer. The
main reason for this version is that 
the ICE packer from AXE was much faster
than the old Automation packer, but it
did not look as nice, did not have 
chunk options and even had some bugs
(yes AXE.. Bugs!!). Anyhow, this packer
is basically the ICE packer in a new 
shell.

Along with the packer, comes 3 pieces 
of source code.

DEPACK1.S    Depack code from A0 to A0
DEPACK2.S    Depack code from A0 to A1
LUMP501.S    Depack code for Chunk/Lump

When using Chunk/Lump source, you will
need to change a few bits. 

First change the lump name (if you are
using one).

Then change the program name which you
want to load. 

Then change space reserve size to chunk
size.

A few people have to be thanked for
this production, namely :-

Axe - For writing ICE at all
    - and for putting up with ENGLISH
    - people last new year!!!

Duck (Dack renamed) - For bugging me to
    - actually do something, and even
    - send him some disks. For writing
    - those god awful lump depack routs
    - Now CAN you write a fast version?

Arn - For bugger all... and I mean all!

Zippy - For, and I quote 
    - Any lamer can use a chunk packer?
    - Yup, I agree... and some can only
    - use a chunk packer...

Vapour - For patience... you might yet
    - get that intro from me.

Monster - For supplying a decent Lump
    - join facility (still needs an
    - upgrade though!).               