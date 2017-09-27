/* FLIP HISTORY & MANUAL */

/* HISTORY:
 *=========
 *   2.6b tells when copies an executable boot to detect virii
 *   2.6a bug de 'r' repaired
 *        No checksum done if no previous checksum
 *        option 's' for single instead of double (double=default)
 * v 2.6  27 fevrier 88
 *   2.5c re-designing of command parsing
 *	  formats disk ('f' command)
 *	  randomization of serial # at each copy
 *   2.5b t can override disk
 *	  ESC aborts without confirm
 *   2.5a no ESC to another disk, BS!
 *	  aborts on key even in format
 *	  man in another C file
 * v 2.5  released
 *  2.4.5 write-protect detected
 *  2.4.3 option v to verify source only
 *	  multipass copies possible
 *  2.4.2 all sects# outputted on any kind of error.
 *        twister modified to accept starttrack parameter
 *	  track_map to know what to copy
 *	  t option to specify track
 *	  r takes options fvV
 *  2.4.1 i for interactive: default no stop
 *	  V verify after format (case-sensitive options)
 *	  bug of verify reading into main buffer repaired
 * v 2.4: Jan 15 88
 *  2.3.2 If esc on insert abort
 *	  track_read first
 *	  no more skip opt
 * 	  # of sect printed
 *  2.3.1 Drive B presence is really tested
 * v 2.3: Dec 28 87
 *  2.2.3 comparisons were not done!!! -- repaired
 * 	  copy by 3 sectors
 *        stops if copy sector only by 1
 *  2.2.2 bug de a1a1 repare
 *  2.2.1 no verify by default
 *  	  r for re-copy
 * v 2.2: Dec 19 87
 *  2.1.1 prints buffer size on start
 *	  sector_read done 4 times with comparison!
 *	  RETURN repeats last command
 * v 2.1: Nov 28 87
 *  2.0.1 retrys in writes and verify work now.
 *	  verify there is a drive B before copying
 * v 2.0: Nov 22 87
 *  1.6.3 verify is another pass
 *  1.6.2 format does not verify anymore
 *	  format outputs a char
 *  1.6.1 uses TWISTER's code mmtwst.c to format
 * v 1.6: Nov 11 87
 *  1.5.4 abort on ESC
 *        option "2" for 2-sided.
 *  1.5.3 abort on key with confirm
 *  1.5.2 track, sectors begin at 1 instead of 0
 *        retrys on writes retry format-write-verify loop
 *	  on write errors, ESC to go to another disk
 *  1.5.1 port to megamax
 *	  uses all memory
 * v 1.5: more checking of entry syntax.
 *        on-line help
 *        fills bad sectors with 0s before writing
 *	  more sensible memory allocation
 *	  s option for auto skip
 * v 1.4: one automatic retry without prompting. If skips, copies good
 * 	  sectors anyway.
 * v 1.3: when error on a track, asks for retrys, which are done sector 
 *        by sector.
 * v 1.2: when double sided, copy the two sides
 * v 1.1: whole side in memory for one drive use.
 * v 1.0: original one in mark williams. quick and really dirty.
 */

/* ON_LINE_MANUAL:
 *================
 */

char           *help_text[] = {
"",
"				FLIP 2.6 manual",
"				 Colas Nahaboo",
"",
"    flip - disk copier with error-recovery, on either sides.",
"           with FAST formatting as TWISTER or DCFORMAT",
"",
"SYNTAX",
"  the commands are given as: (items in [] are optional)",
"",
"      <source-drive>[<dest-drive>][fvVtios9]                  : copy disks",
"      f[<drive>][fvVtis9]                                     : format disk",
"      v[<drive>][tios9]                                       : verify disk",
"      r[<drive>][fvVi]                            : re-write disk in memory",
"      q                                                       : quits",
"      ?                                                       : help",
"",
"  A drive is specified by the letter \"a\" or \"b\", followed optionally by",
"  \"1\" or \"2\" to indicate the side. (default drive is \"a\", side is \"1\")",
"",
"OPTIONS",
"     f - to format destination side",
"     V - verify disk by re-reading track just after being formatted.",
"     v - verify copy by re-reading track just after being written",
"     t - to specify what track(s) to copy (used with \"z\" to give the",
"           number of tracks of the new disk, default 80)",
"     i - interactive: ask user in case of error (default don't)",
"     o - override: do not look at the source disk boot sector to determine",
"           its type, take 10 sectors, 1 sided, 80 tracks, unless told",
"           otherwise by options \"9\", \"d\" or \"t\"",
"     9 - disk is 9 sectors per track (default 10). Used with \"z\" or \"o\"",
"     s - disk is single-sided (default double). Used with \"z\" or \"o\"",
"",
"EXAMPLES",
"  ab2fv - to copy a non-protected SS disk in drive A on the unformatted",
"          back of a SS disk in drive B, verifying the copy.",
"  afv   - (or fv) to copy ANY disk with format and verify, in drive A.",
"  rfv   - to re-write last copy into drive A",
"  ffv   - to format a double-sided disk in drive A",
"  fs    - to erase all files of a previously formatted single sided disk",
"",
"OPERATION",
"  During copy, flip prints for each track, a:",
"  ,    for reading track without problem",
"  ;    for reading track successfully after 4 retrys sector-by-sector",
"  -    for formatting a track (in FAST format)",
"  v    for verifying a track",
"",
"  You can pause during the copy at any time by pressing a key, but pressing",
"  ESC will abort. ^C always quits.",
"",
"  Without i option, on read error, it retries 4 times to read the track,",
"  then reads sector by sector. With option i, it prompts you for what to do:",
"  (the track and sector number given start at 1, but sector number at 0)",
"    - RETURN or SPACE retries. You'd better try to extract, then re-insert",
"      the disk to try to re-center it. (or try on another drive later)",
"    - \"s\" skips the bad sectors, going on with the rest of the copy.",
"      the bad sectors will be filled with 0s on the copy",
"      (but all that could be read is kept, of course!)",
"    - if it is writing the copy, you can press BACKSPACE if you want to try",
"      to write to another disk.",
"    - any other key aborts the copy.",
"  Experience shows that you can recover most of your damaged disks this way.",
"  If it cannot read the track, it reads it sector by sector, but tells you so",
"  because due to a bug in the TOS, a sector can be read incorrectly without",
"  giving an error. So FLIP does 4 reads of the same sector and compares",
"  them to be sure, but even if reads are equals, it warns you because the",
"  risk subsists, due to the bug in old TOS roms...",
"",
"DESCRIPTION",
"  The program copies TOS disks as a whole, and only non-protected",
"  ones. It can consider the back side of a single-sided disk as another disk",
"  so, it is very useful to use the back sides of protected disks, or",
"  single sided disks, such as MAGIC! ones. (with a two-side drive, of",
"  course!)",
"",
"  But it also reads disks with care, being able to read CORRECTLY most disks",
"  causing a read error to copiers or the GEM desktop. Thus, if you get a",
"  read error on a disk, copy it with FLIP!. Moreover, if it cannot read a",
"  sector, it tells you so! (Unlike the HELP program)",
"",
"  Version 2.6 can format and changes randomly the serial # of the disk",
"  when copying, (without the override option). It copies also executable",
"  boot sectors, but tells you so (in 2.6b) so that you can check for a VIRUS.",
"  it gives you the values at $3A offset to identify the virus",
"  Known virus values are: 41,FA,FF                                         ",
"                                                                           ",
"  When it reads a disk, it first tries to read the boot sector in order",
"  to know the size (tracks and sectors per track) of the disk. If it",
"  can't make sense out of it, it uses 80 tracks by 9 sector, unless you",
"  used the \"o\" option",
"  Thus you don't have to tell him the type of the disk you want to copy.",
"  It will recognize double sided disks automatically, but you can only",
"  copy double sided disks, without flipping their faces!",
"",
"  So, NEVER COPY A DISK WICH GIVES READ ERRORS WITH A BIT-COPIER (procopy)",
"  use FLIP instead!",
"",
"  From version 2.0 on, FLIP format in FAST format, all disks accesses on",
"  this disk will be twice faster compared to a normal disk!. It ALWAYS ",
"  formats disks in 10 sectors, even if only to store 9 sectors.",
"  Be aware that I didn't test the validy of the formatting code on the",
"  new roms, so make some tests if you have them.",
"",
"COPYRIGHT",
"  This program is PUBLIC DOMAIN, and should be given with its sources",
"  Feel free to improve it!, but please mention my name.",
"  I would be very glad if you send me back any improved version, such as",
"  a GEM port",
"  CREDIT: It uses code from TWISTER from Dave SMALL & Dan MOORE.",
"",
"BUGS",
"  Not under GEM - yet!",
"  Cannot copy IBM boot sectors (use DCFORMAT)",
"",
"AUTHOR",
"  Colas NAHABOO",
"  383 ch du clos d'Embertrand",
"  06250 MOUGINS",
"  FRANCE.",
"  Personal phone: 93 75 68 29, give me a call...",
"  Electronic mail address:    colas@mirsa.inria.fr",
0L
};

#include "osbind.h"
#include "stdio.h"

more(text)
char          **text;
{
    char          **p = text, c;
    int             line = 0;

    while (*p) {
	printf("%s\n", *p++);
	line++;
	if (line > 22) {
	    printf("%cp more (SP, CR, BS or ESC) %cq", 27, 27);
	    fflush(stdout);
	    while (!Cconis());
	    c = Cnecin();
	    printf("%cM", 27);
	    fflush(stdout);
	    switch (c) {
	    case 27:
	    case 'q':
		printf("\n");
		return;
		break;
	    case ' ':
		line = 0;
		break;
	    case 8:
		line = 0;
		p -= 48;
		if (p < text)
		    p = text;
		printf("%cp...Backing 1 page...%cq\n", 27, 27);
		break;
	    }
	}
    }
    printf("\n");
}

