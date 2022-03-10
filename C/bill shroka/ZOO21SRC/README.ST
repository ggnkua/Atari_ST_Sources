    This files describes the implementation of the Atari ST version of Zoo 2.1.
Please read ZOO.MAN and then read this file.

GENERAL
-------
ST Zoo 2.1 is completely backward compatible with the port of Zoo 2.01 I did.
In 2.01 we had optimized the compression and decompression functions for speed.
In 2.1 we did not optimize the old-style compression/decompression functions in
lieu of the more efficient "high compression" functions.  Therefore, 2.1 may
not be as fast as 2.01 in extracting old format archives.  I stress that 2.1 is
100% backwards compatible with 2.01, just not as fast when dealing with old
format archives.  We will be concentrating on optimizing the speed of the new
compression/decompression functions in future versions.

ST Zoo requires 400K+ available free memory when using the high compression
option.  Very tight on a 512K machine.

ST Zoo accepts both slashes and backslashes as directory separators.

ST Zoo preserves the attributes of archived files.  So if you archive a
Read-Only file, it will be extracted as a Read-Only file.  PLEASE NOTE:  Not
all attributes of an Atari file are preserved, as these are not transportable
across systems.  ex. the archive bit.

ST Zoo doesn't allow Zoo to be used as a filter. 

NEW OPTIONS
-----------
// - This option will recursively decend all the directories in the specified
     path when used in conjunction with the 'a' command.  NOTE: This is Atari
     specific and will change if/when R. Dhesi adds this option internally to
     Zoo.  This does not affect the ability of Zoo on other platforms to
     extract these archives.

NOVICE COMMANDS
---------------
-add
-freshen
-update
-move    - All default to the high compression mode.

-backup  - This is the same as the expert command 'ah//'.  It will recursively
           descend all directories in the path during an add.

-restore - This is the same as the expert command 'x//'.  It will extract files
           from the archive using full pathnames, if present.

WILDCARD HANDLING FROM THE DESKTOP
----------------------------------
The wildcard expansion routines used in the ST version of Zoo understand the
following elements:
    * or *.*    - Any sequence of zero or more characters.
    ?           - Any single character.
    [x...y]     - Any single character specified by the set x...y, where any
                  character other than minus sign or close bracket may appear
                  in the set.  A minus sign may be used to indicate a range of
                  characters.  ex. [0-5abc] is shorthand for [012345abc].  More
                  than one range may appear inside a character set.  ex.
                  [0-9a-zA-Z._] matches almost all of the legal characters for
                  a host name.
    [^ x...y]   - Any character NOT in the set, which is interpreted as 
                  described above.
    \*, \?, \[  - A *, ? or [ character.  ex. If you named a file '*' and you
                  want it added to a Zoo archive, you would use the following
                  command line:  'zoo ah foo.zoo \*'.  Try to avoid doing this.
See wildmat.man and README.WM for more details.

UNIXMODE
--------
The released binary of Zoo does not fully support UNIXMODE.  The only
option of UNIXMODE not supported is mixed case.  This can be changed by
undefining FOLD in options.h and recompiling Zoo.  See the TOS section of
options.h for more details.  Undefining FOLD will NOT cause any compatibility
problems with produced archives.  If you are unable to recompile Zoo and
want the UNIXMODE version, contact me at one of the email addresses below.

ZOOPAUSE
--------
If you launch ST Zoo from the desktop, it will wait for a keypress when it is
done with it's current operation.  If ST Zoo is launched from a recognized CLI
(currently Gulam, Master 5.0 & 5.4, Craft) or if the environment variable SHELL
is set, ST Zoo will NOT wait for a keypress.  You may also set the environment
variable ZOOPAUSE to either "yes" or "no", depending on whether you want ST Zoo
to wait or not.

ACKNOWLEDGMENTS
---------------

This port of Zoo was done using GCC V1.40 and the excellent libraries 
distributed with it.  Thanks to Jwahar Bammi and Eric Smith for all of the 
time and labor they put into this compiler package.

Thanks to Jwahar Bammi for all the time/code/ideas he donated to this project.

Thanks to Rahul Dhesi for developing Zoo and making it freely available to 
all users, on all platforms.

Thanks to Rich Salz for releasing his wildmat code to the public.  It saved us
alot of headaches developing our own from scratch.

Thanks to Dan Jitta for his port of Zoo 2.01 to the ST.  We used several of his
ideas in this port.


Please send all comments, suggestions, and bug reports to:

Bill Shroka
bjsjr@NCoast.ORG
ncoast!bjsjr@usenet.ins.cwru.edu
uunet!usenet.ins.cwru.edu!ncoast!bjsjr
GEnie: B.SHROKA

