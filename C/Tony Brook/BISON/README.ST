
This is the distribution of BISON, the GNU project parser generator, as
ported to the Atari ST.

Please read the file COPYING for a description of your rights and
responsibilities as a user of GNU software.

This one's pretty straightforward.  One interesting mod that I had to
make:  

The default name for the output .c file generated from foo.y is
foo-t.c, rather than foo.tab.c.  This may cause problems if the
original file name is already at the limit of the ST file system.

See the doc or source for details on where BISON looks for its two
parser skeletons.  You should define some env vars BISON_SIMPLE and
BISON_HAIRY as the pathnames of those files.  Bison will look other
places, but mostly I haven't bothered to de-Eunuchs-ify the pathname
code internally, so all the other places it looks will lose.  I've
included my GNU.G file as an example.

As always, all mods that I've made to the source are conditionalized
with #ifdef atarist.

Good luck!

JRD@Stony-Brook.SCRC.Symbolics.COM
