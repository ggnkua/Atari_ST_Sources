THE DISK CATALOGUE SYSTEM
=========================

Usage Notes - Release 1.
------------------------

This suite of programs is designed to facilitate the quick location of program
files held on floppy disks. Each month a large number of programs are released
to the public by the computer press. In addition, the amount of good software
available through Public Domain libraries is growing all the time. It can be
a problem to remember where a particular program or utility is stored, this
system has been written to ease that burden.

The system assumes that the user will assign each disk which is to be recorded
a numeric identifier.

The system comprises of three programs;

    1) DCAT.TOS - This program is the 'workhorse' of the system. Use it to
                  maintain your catalogue by adding, amending or deleting
                  records from it.
                  Catalogue queries are possible; searches may be performed to
                  locate specific folders, program names or subjects.
                  This program also allows for the entire contents of the
                  catalogue to be listed to the screen.

    2) SUBJ.TOS - Each record on the catalogue is assigned a numeric subject
                  code by the user. This allows the catalogue to be queried
                  for all programs on a given topic.
                  The descriptions of the subject codes are stored outside of
                  the catalogue. This program allows for the descriptions to
                  be amended and will also list each code and description to
                  the screen.

                  Note :- The system has a range of subject codes from 1 to 25.

    3) DUMP.TOS - This program will produce a disk file containing a formatted
                  copy of the entire catalogue. This file may be sent to a
                  printer by double-clicking it from the GEM Desktop.


The system also uses the following files;

    1) DCAT.DTA    - The current catalogue.
    2) SUBDATA.DTA - The descriptions of the 25 subject categories.
    3) DUMP.PRN    - A formatted copy the current catalogue; produced by
                     DUMP.TOS.

Further Development.
--------------------

This system represents my first foray into the world of C programming. There
are a number of enhancements that I am aiming to introduce into the next
revision including;

    1) To alter the code to work under GEM. This will require a large
       investment of development time.

    2) To provide an enhanced query and print procedure. I would like to be
       able to remove the need to exit to the GEM Desktop in order to get
       hardcopy.

    3) To generally enhance the system in response to version 1.0 user
       comments.


All of the source code is present on disk. Users of this disk are invited
to send me modifications for consideration for the next release.

I would like to take this moment to congratulate the developers of the
SOZOBON C compiler. It has provided me with an easy path into the world of
C programming without having to go to the expense of buying a commercial
package. May the realm of Public Domain continue to prosper !

Finally, this release is NOT Public Domain. I intend to keep these programs
in limited circulation until a version that operates under GEM is available.
At that stage I will then release the program into the Public Domain.

Version 1.0 users may not distribute this program without my consent.

All questions and observations may be sent to me at the following address;

     Lee Russell
     16 Rockstone Way
     Ramsgate
     Kent
     CT12 6NJ

     Tel : 0843 587063

(c) L.J. Russell, 1992.


