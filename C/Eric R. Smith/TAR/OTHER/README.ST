Here is GNU tar, ported to the Atari ST. The source code is included
(of course!). See the file "copying" for copyright information.
PLEASE NOTE: THERE IS ABSOLUTELY NO WARRANTY FOR THIS PRODUCT. USE IT
AT YOUR OWN RISK!

All the changes to the source that were necessary for this version
are surrounded by "#ifdef atarist". I used the GCC v1.34, with a new library,
to build it. If you're using another compiler, you may need to do some
work. In particular, you'll probably want to add -Datarist to the CFLAGS
in the makefile.

Read the enclosed manual (in tar.tex -- actually this should be
tar.texinfo, but GEMDOS doesn't know from long extensions) for general
information.

ST-specific information:

Tar is designed to run from a command line interpreter,
preferably one that uses the MWC extended argument passing conventions
(e.g. gulam). You can run it from the desktop if (a) your version of the
desktop will pass lower case letters to programs, and (b) you don't mind
messages disappearing from the screen when the desktop gets redrawn.

There is no default tar file; one must be explicitly specified on the
command line. The "-f" option is assumed, i.e typing "tar tv junk.tar"
is the same as "tar tvf junk.tar".

Several of the options (e.g. -z to compress) are not applicable on the
ST, and will generate error messages.

The -N option only accepts a date in the form MM/DD/YYYY. (Theoretically,
if you have a shell that uses the MWC extended argument passing conventions,
you could use "-NMM/DD/YYY hh:mm:ss" -- make sure you put quotes around
it).

Timezones: generally, you will want to tell the program which time zone
you're currently in. To do this, create an environment variable
called TZ with the format SSS[-]nn[:nn][DDD], (things in [] optional) where
SSS is the name of your time zone, nn:nn is the offset in hours and minutes
from GMT (prefixed by '-' if necessary) and DDD, if present, is the name
used for your time zone when daylight savings time is in effect. Note
that the rules for daylight savings time are very primitive indeed,
and will probably not work outside of North America.
Example: I'm in the N. American Eastern time zone, and I use (in Gulam)
setenv TZ "EST5EDT".
If no TZ environment variable is found, GMT is assumed. This only matters
if you're transferring tar files to/from other systems and you want
to make sure the dates are correct.

GEMDOS filenames are translated to/from Unix; thus "subdir/file" gets
changed to "subdir\file". This can (obviously) cause problems with GEMDOS
files which contain '/' in their names, or Unix files that contain '\'.
Watch out for these. Also, some effort is made to translate names that
have several extensions, e.g. "junk.c.bak" gets mapped to "junk,c.bak".

Multi-volume tar files seem to work, but have not been thoroughly tested.
I would not recommend using them to back up your hard disk, unless you're
feeling particularly brave or don't care about your data.

Report bugs, etc. to me at the address below:

Eric R. Smith                     email:
Dept. of Mathematics            7103_300@uwovax.uwo.ca
University of Western Ontario   7103_300@uwovax.bitnet
London, Ont. Canada N6A 5B7     (a shared mailbox: put my name on
ph: (519) 661-3638              the message, please!)

