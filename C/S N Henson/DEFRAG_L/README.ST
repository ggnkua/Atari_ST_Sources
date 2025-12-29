This is a simple port of the Linux defragger. For minixfs it works as two
separate programs defrag and defrag2 for V1 and V2 filesystems. Since the
original was covered by Gnu Copyleft, so is this. The original sources are
readily obtainable from any Linux ftp site.

	A few notes. This version has all the functionality of the Linux
version. The docs have been modified slightly to take account of specific
changes (all minor) for the ST version.

	In case the original docs don't make it obvious: use extreme caution
when using this. fsck should report a clean filesystem before even attempting
to run it in anything other than readonly mode. Back up your data before hand.
If this program gets interupted when writing, then the fileystem is probably
irretrievably trashed. In other words after it has started in anything other
than readonly mode, don't even think about stopping it by signals, resets or
power downs.

	Any bug reports to shenson@nyx.cs.du.edu .

PS NB some of the files are supposed to be zero length. This was just so I could
make the minimum changes to the original sources (and to make porting newer
versions easier).

