/*************************************************
	LHarc version 1.13b (c) Yoshi 1988-89.
	usage & message module : 1989/ 5/14
	(for version including no Kanji or Kana)

	adaption to ATARI ST with TURBO-C 1.1
	by J. Moeller 1990/01/31

HTAB = 4
*************************************************/

#ifndef __TOS__
char title[] = "\nLHarc 1.13b (c)Yoshi, 1988-89.\n";
#else
char title[] = "\nLHarc 1.13b (Atari ST) (c)Yoshi, 1988-89.";
#endif

char use[] =
#ifndef __TOS__
"LHarc  version 1.13b                Copyright (c) Haruyasu Yoshizaki, 1988-89.\n"
#else
"LHarc  version 1.13b (Atari ST)     Copyright (c) Haruyasu Yoshizaki, 1988-89.\n"
#endif
"================================================================  05/14/89  ===\n"
"               <<< High-performance file-compression program >>>\n"
"===============================================================================\n"
"  usage : LHarc [<command>] [{{/|-}{<switch>[-|+|2|<option>]}}...] <archive>\n"
"                  [{<drive name>:}|{<base directory>\\}] [<path name> ...]\n"
"-------------------------------------------------------------------------------\n"
"  <command>\n"
"     a: Add files to archive            u: Update files to archive\n"
"     f: Freshen files in archive        m: Move new files into archive\n"
"     d: Delete files from archive     e,x: EXtract files from archive\n"
"     p: disPlay files in archive      l,v: View List of files in archive\n"
#ifndef __TOS__
"     s: make a Self-extract archive     t: Test integrity of archive\n"
#else
"     t: Test integrity of archive\n"
#endif
"  <switch>\n"
"     r: Recursively collect files       w: assign Work directory\n"
"     x: allow eXtended file names       m: no Message for query\n"
"     p: distinguish full Path names     c: skip time-stamp Comparison\n"
"     a: allow any Attributes of files   v: View files by another utility\n"
#ifndef __TOS__
"     n: display No indicator            k: Key word for AUTOLARC.BAT\n"
#else
"     n: display No indicator            h: Hold screen after finishing\n"
#endif
"     t: archive's Time-stamp option\n"
"===============================================================================\n"
"  You can distribute or copy without any donation to me. Nifty-Serve  PFF00253\n"
"  (Detailed descriptions are in user's manual.)          ASCII-pcs    pcs02846";
/*
"  Don't distribute to other network systems!             Nifty-Serve  PFF00253\n"
"  !!!! This version is made only for myself. !!!!        ASCII-pcs    pcs02846";
*/

char M_UNKNOWNERR[]	=	"Unknown error";
char M_INVCMDERR[]	=	"Invalid command";
char M_MANYPATERR[]	=	"Too many files in command line";
char M_NOARCNMERR[]	=	"No archive name";
char M_NOFNERR[]	=	"No file name";
char M_NOARCERR[]	=	"Archive not found";
char M_RENAMEERR[]	=	"Can't rename Archive";
char M_MKTMPERR[]	=	"Can't create temporary file";
char M_DUPFNERR[]	=	"Same names in another path";
char M_TOOMANYERR[]	=	"Too many files matched";
char M_TOOLONGERR[]	=	"Too long path name";
char M_NOFILEERR[]	=	"No file found";
char M_MKFILEERR[]	=	"Can't create file";
char M_RDERR[]		=	"Can't read file";
char M_WTERR[]		=	"Can't write file";
char M_MEMOVRERR[]	=	"Memory overflow";
char M_INVSWERR[]	=	"Invalid switch";
char M_CTRLBRK[]	=	"Ctrl-break pressed";
char M_NOMATCHERR[]	=	"Can't find File";
char M_COPYERR[]	=	"\nFailed in copying temporary file to archive";
char M_NOTLZH[]		=	"Extension of archive(%s) is not '.LZH'. "
						"May continue process? [Y/N] ";
char M_OVERWT[]		=	"Already exist. Overwrite? [Y/N] ";
char M_MKDIR[]		=	"Make directory? [Y/N] ";
char M_MKDIRERR[]	=	"Failed in making directory";
char M_CRCERR[]		=	"CRC Err\n";
char M_RDONLY[]		=	"Read only!";

char *errmes[] = {
	M_UNKNOWNERR, M_INVCMDERR, M_MANYPATERR, M_NOARCNMERR,
	M_NOFNERR, M_NOARCERR, M_RENAMEERR, M_MKTMPERR,
	M_DUPFNERR, M_TOOMANYERR, M_TOOLONGERR, M_NOFILEERR,
	M_MKFILEERR, M_RDERR, M_WTERR, M_MEMOVRERR, M_INVSWERR,
	M_CTRLBRK, M_NOMATCHERR, M_COPYERR,
	M_NOTLZH, M_OVERWT, M_MKDIR, M_MKDIRERR, M_CRCERR,
	M_RDONLY
};