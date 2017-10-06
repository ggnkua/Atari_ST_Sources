                    Atari ST SCSI Interface Library
                           For C Programmers
                             Version 0.01

                 Copyright Steve Woodford, August 1993


OVERVIEW:
The source files in this directory implement a nice easy SCSI interface which
can be used by C programmers. The idea is that any type of SCSI device can be
handled through a common interface with similar semantics to Unix read() and
write() system calls. The library is distributed in source form only, since
there is no absolute standard for object library format. At the moment, it is
likely that this code will only compile under Gnu C, so if you use another
C compiler, you will have to massage the Makefile and assembler source files.

Currently, this code is a beta-test release and will be updated as bug reports
arrive. At the moment, unless someone else writes a low-level driver for the
Falcon and TT SCSI buses, only the ST and STE ACSI bus is supported.

There is no formal documentation supplied at the moment, as this is a bit of
a rush release. However, if you decide to write an application around this
code, you will probably be proficient enough in C to understand how to use
it anyway! Documentation will be supplied in some future version though.


DISCLAIMER:
I make no claims as to the suitability of this software to perform it's
intended task and/or any task envisaged by you as a programmer. I will not
be held responsible for any damage or loss through your use or inability to
use this software. Basically, by all means report bugs and/or send me a wish
list but _don't_ hold me responsible when anything goes wrong!

Ok, I had to say that; there are unreasonable people out there....

Please note, however, that this library gives you unrestricted access to
devices hooked onto your SCSI bus. This includes the hard disk drive
containing your valuable data. Unless you know exactly what you're doing,
don't *ever* attempt to write to an active GEM / MiNT partition on your disk
with this library; more than likely, you will damage data and/or make the
partition unusable. TOS certainly does not like hard disk data being altered
under its nose, to say nothing of the cache your hard disk driver program
may contain. The golden rule is "Always make regular backups". Oh, and if
you do use this library to write backup program, keep an executable of
the restore program on floppy. (Better still, several floppies...)


CONTENTS:
The 'zoo' archive containing this library should contains the following files:

   README       - This file 'wot' you are currently reading.
   Makefile     - Makefile setup for Gnu C. Edit for -mshort library
   Patchlev.c   - Revision level of the library
   scsi.h       - Low-level interface. Put this in your include/sys directory
   scsi_io.h    - SCSI I/O interface. Put this in your include/sys directory
   libscsi.h    - Library specific header. Only needed by library routines
   scsi_io.c    - SCSI I/O functions. Uses the following files to implement
                  the high level interface:

   erase.c filemark.c inquire.c load.c mod_sens.c prevent.c req_sens.c
   rezero.c rw_rand.c rw_seq.c seek_rnd.c seek_seq.c space.c test_rdy.c
   timeout.c to.c

   scsicmd.cpp  - This assembler file implements the lowest level of the
                  library; ie. the part which actually issues SCSI commands
                  on the ST's ACSI bus.

   cfile.c      - This is in my own library of useful functions, but since
                  the SCSI library uses it, I have included it here. It
                  simply provides an easy way to handle ASCII configuration
                  files from within programs.
   cfile.h      - Header file for above. Put in your 'include' directory.
   scsi.cnf     - Example configuration file. Good for an Archive Viper 2150,
                  with SCSI ID of 2.

   tape.c       - Lifted from my backup/restore program, this shows how the
                  SCSI library can be used. This is only a code fragment
                  implementing the tape side of my backup program but serves
                  as a short, useful example.


HISTORY:
I wrote this library after buying a secondhand Archive Viper 2150 tapedrive.
At the time, I didn't have access to Internet or Usenet so I had no idea
what the rest of the world was doing. As it turned out, there was very little
software available to support tapedrives on the ST so writing my own was
probably a good move.

The library went through a few 'mutations' before this version emerged as
the best way to implement the interface. Initially, it was specific to
SCSI tapedrives, since that was my only requirement. However, I realised
quite quickly that it would be easy to make it generic, so that it could
support almost any SCSI device which could be hung off the ACSI bus.

At this point, I have to say that I don't have access to much hardware
with which to test this library; only the aforementioned tapedrive and
my hard diskdrive. So I would appreciate comments from programmers who
have more exotic devices.


CONFIGURATION:
The library is mostly self-configuring in terms of finding out what a
particular SCSI device is. However, certain things are not obvious.
Most importantly, different SCSI devices take different lengths of time to
complete an operation. In the case of a hard disk, this is generally a very
short time, ranging from a few tens of milliseconds to perhaps one or two
seconds if the drive recalibrates itself or retries a read/write error.

SCSI tapedrives, however, take much longer to complete operations. Take,
for example, writing the first block of data to a tape you've just
inserted in the drive. This tape may need to be rewound. The drive may
need to write a head calibration track if the tape is brand new. In short,
tapedrive operations may take many tens of seconds, perhaps several minutes.

In this case, you have to provide some way to tell the SCSI library just
what timeouts to apply to a particular device. This is where the 'scsi.cnf'
file comes in. When you first call 'scsi_open()', the library will look
for a 'scsi.cnf' file in the current directory. If that fails, the
environment is searched for a variable named 'SCSI_CONFIG_FILE' which
contains a pathname to a scsi.cnf file. (eg. c:\etc\scsi.cnf) If the
library cannot find a scsi.cnf file, default timeout values are assumed.
Note: The defaults are good only for most hard disk drives....

An example 'scsi.cnf' file is supplied with the library. This is the file
I use on my system. If you read it, you will see that my tapedrive is
set up as SCSI ID#2, and is marked as the 'Default Tapedrive'. If I call
'scsi_open()' with the magic SCSI ID of 'SCSI_TAPE_ID', the library will
automatically use the default tape defined in the scsi.cnf file. This way,
your software doesn't need to worry about finding the tapedrive in a user's
system...

The scsi.cnf file also defines a device's timeout values. The library looks
in the file for an entry: SCSI_TIMEOUT_<id>, where <id> is the device's
SCSI ID. This contains a list of comma separated values defining the maximum
time, in seconds, to wait for a particular operation to complete. The example
scsi.cnf file contains the definition for my Archive Viper tapedrive.


PERFORMANCE:
First of all, don't expect to be able to use this library to obtain
blistering I/O speed on hard diskdrives. Although actual data transfer will
occur at the maximum speed achievable by the device, there is significant
overhead in the library such that the average throughput will probably be
slower than the hard disk driver software you currently use. The main
bottleneck is in the separation of 'read/write' and 'seek', where you have
to 'seek' to a particular block before you can start reading from there.
Note that the 'scsi_seek()' call doesn't involve any head movement, it simply
updates the starting block number for the next 'scsi_read()' or 'scsi_write()'
calls.  (Also note that 'scsi_seek()' is meaningless for tape-drives, use the
'scsi_ioctl()' call instead.)

Remember though, that the main intent of this library is to support devices
which your current disk driver can't, and to provide a clean, easy to to use
method of accessing them.

I have already incorporated this library into a backup/restore program
which can read and write Unix TAR, and CPIO format tapes. So far, the
performance is very good, i.e. my ST can keep the tape streaming pretty
well; I can backup my 80meg drive onto one tape in less than half an
hour, and that's with a mixture of GEM and MinixFS partitions. Performance
deteriorates, however, for badly fragmented drives and/or drives with lots
of small files. (Don't hold your breath for this backup/restore program.
I want to wrap a GEM interface around it before releasing it. I would also
like the library to work with the Falcon and TT so that the backup program
is fully compatible).


MiNT COMPATIBILITY:
I updated the library earlier this year, after getting net access, to
be compatible with MiNT and MiNTLIBS. So far, no problems. In fact, only
a small part of the low-level assembly code needed changing.


HARDWARE COMPATIBILITY:
Currently, only ST, STE, STacy and derived systems are supported. However,
a future version will support other hardware, and may well use the
'dma_read' & 'dma_write' system calls supported by newer versions of TOS.
As yet, though, I'm unsure if these calls can support SCSI tapes since the
SCSI command descriptor block (CDB) for tapedrives is slightly different to
hard diskdrives. These calls certainly do not allow for transfers of less
than 512 bytes; something which is essential for several SCSI commands.


COPYING:
This library is public domain. I don't expect to make any money out of
it. I do retain copyright on the library, however. Don't feel obliged to
donate anything my way, just go down the pub and buy yourself a pint
instead :-} and pretend you bought me it! (My backup program will probably
be Shareware, though)

You have my permission to distribute verbatim copies of this library
just so long as you don't charge for the software. You can make a
reasonable charge for the storage media, eg. floppy disk/s, however.

If you modify the library, be sure to credit yourself and comment where
and what you changed. I don't want to be blamed for other peoples'
mistakes!

If you use this library in your own application/s, you may charge as much
as you like if you decide to sell it. I only ask that you mention in your
documentation the fact that this library is used.


UPDATES:
Please let me know what you think about this library. Tell me if you
find a bug, of which I am sure there are many. If you do tell me about a bug,
give me as much information as possible about how you found the bug. If you
know of a fix for the bug, even better; send me the file/s you updated.
Especially welcome are modifications to the library to support other SCSI
device types, or Atari hardware. However, please quote the version number of
the library which applies in your case. I may already have an updated version
which has had your particular bug fix, or feature implemented. You will find
your version number in 'Patchlev.c'.


Happy hacking, Steve.
March 15th, 1994

Stephen Woodford
11054 ne 33rd Place, #B2
BELLEVUE, WA 98004
USA

e-mail: woodford@esca.com
