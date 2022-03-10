uchar title[] =
"\r\n LHarc "LZHVERSION" - dedicated to "PERSON"\r\n"
" Copyright (c) Yoshizaki, 1988-89, Grunenberg, Mandel, 1994\n";

#ifndef __SHELL__

uchar title_x[] =
"   LHarc Version "LZHVERSION" (Atari) - dedicated to "PERSON"\r\n"
"   (c) Haruyasu Yoshizaki, 1988-1989, Grunenberg, Mandel, 1994";

uchar use_1[] =
" ================================================================ "__DATE__" =\r\n"
" Syntax: LHarc [<command>] [{{-|/}{<switchs>[-|+|0-3|<options>]}}...] <archive>\r\n"
"         [{<Drive>:[\\]}|{<Base-Directory>\\}] {[&|&-|~] <Paths/Files> ...}\r\n"
" ------------------------------------------------------------------------------\r\n"
"  <Command>\r\n"
"      a: Add files to archive           u: Update newer files to archive\r\n"
"    f,r: Freshen/Re-construct archive   m: Move files to archive (means 'a -d')\r\n"
"      d: Delete files from archive    e,x: Extract files from archive\r\n"
"      p: DisPlay files on screen      l,v: List/Verbose list of archive\r\n"
"      t: Test integrity of archive      c: Compress files in AFX-format\r\n"
" ------------------------------------------------------------------------------\r\n"
"  <Switchs> (WARNING: The meaning of the d-switch has been completely changed)\r\n"
"      r: Recursive expansion of dirs    w: Specify work-directory\r\n"
"      x: Extend filenames               m: No Message at query\r\n"
"      p: Distinguish pathnames          f: Include folders in archive\r\n"
"      c: Skip time-comparison           i: Ignore attributes\r\n"
"      a: Any attribute                  v: Display with external tool\r\n"
"      n: Set process-indicator          h: Hold screen after finishing\r\n"
"      t: Time-stamp of archive          y: Only files with 'changed' attribute\r\n"
"      b: Clear 'Changed'-attribute      l: Use Larc compatible method\r\n"
"      q: Suppress all messages (quiet)  o: Use LHarc 1.13 compatible method\r\n"
"      u: Store - don't compress files   k: Header-level (0-2)";

uchar use_2[] =
"\r      e: Include file-comments          z: Include archive-comment\r\n"
"      d: Delete files after command     C: No crc-check during extraction\r\n"
"      g: Extract archive in folder      j: Exclude empty files\r\n"
"      5: Force LHarc 2.0x archive (lh5) 4: Store in Larc compatible method\r\n"
"      s: Convert backslashs to slashs   P: Process-Indicator-Character\r\n"
"      L: Limit memory-allocations       S: Case-Sensitive filenames\r\n"
"      M: Maximum file-size              N: Only files newer than date ddmmyy\r\n"
"      U: Store files uncompressed       R: Rename Unix-Files\r\n"
"      I: Compress files to directory    B: Retain backup copy of archive\r\n"
"      A: Add if file is not in archive  D: Delete if file is not specified\r\n"
"      W: No wildcard-matching           X: Make relativ pathnames\r\n"
"      Y: Encryption                     K: Acoustic signal after finishing\r\n"
"      ?: Display helpscreen\r\n"
"  path;\ Make relativ pathnames        ~,! Exclude files\r\n"
"     &,@ Get file-list from file     &-,@- Get file-list from standard input\r\n"
" ==============================================================================\r\n"
"  (You'll find a more detailed description in the documentation 'MANUAL.ENG')\r\n\n"
"  Yoshizaki  : Nifty-Serve  PFF00253\r\n"
"               oASCII-pcs   pcs02846\r\n"
"  Grunenberg : Christian Grunenberg @ S2 (Mausnet)\r\n"
"               Christian_Grunenberg@S2.maus.de (Inter-/Usenet)\n";

uchar use_3[] =
"\r LHarc is a freeware-program. Freeware means that you can freely copy, test\r\n"
" and use this programm. If you are using LHarc regularly, you should support\r\n"
" the further development by sending me a suitable donation (a cheque or a postal\r\n"
" money order about DM 25,- or $15). Thanx.\r\n\r\n"
"  Address:\r\n"
" ----------\r\n"
"  Christian Grunenberg\r\n"
"  Traminerweg 5\r\n"
"  D-71717 Beilstein\r\n"
"  Germany\r\n\n"
"  Important:\r\n"
" ------------\r\n"
"  Use this program at your own RISK! I do not provide any warranty about it!\n";

#endif

uchar M_UNKNOWNERR[] =   "Unknown error";
uchar M_INVCMDERR[]  =   "Unknown command";
uchar M_MANYPATERR[] =   "";
uchar M_NOARCNMERR[] =   "No arcname";
uchar M_NOFNERR[]    =   "No filename";
uchar M_NOARCERR[]   =   "Archive doesn't exist";
uchar M_RENAMEERR[]  =   "Unable to rename archive";
uchar M_MKTMPERR[]   =   "Unable to create temporary file";
uchar M_DUPFNERR[]   =   "";
uchar M_TOOMANYERR[] =   "";
uchar M_TOOLONGERR[] =   "Pathname is to long";
uchar M_NOFILEERR[]  =   "No files found";
uchar M_MKFILEERR[]  =   "Unable to create archive";
uchar M_RDERR[]      =   "Unable to read file";
uchar M_WTERR[]      =   "Unable to write file";
uchar M_MEMOVRERR[]  =   "Not enough memory available";
uchar M_INVSWERR[]   =   "";
uchar M_CTRLBRK[]    =   "";
uchar M_NOMATCHERR[] =   "Unable to find file";
uchar M_COPYERR[]    =   "\r\nUnable to copy temporary file to archive";
uchar M_NOTLZH[]     =   "Extension of archive (%s) is not 'LZH'.\r\nContinue ? [Y/N]";
uchar M_OVERWT[]     =   "File exists,Overwrite [Y/N/All] or Rename?";
uchar M_ENTERNEW[]   =   "New name :";
uchar M_MKDIR[]      =   "Create folder ? [Y/N/All]";
uchar M_MKDIRERR[]   =   "Unable to create folder";
uchar M_CRCERR[]     =   "";
uchar M_RDONLY[]     =   "File is read-only !";
uchar M_PRESSKEY[]   =   "-- Press key to continue --";
uchar M_COMMENT[]    =   "Comment :";
uchar M_PATH[]		 =	 "Paths/Files (wildcards possible (*?@[^-|],)) :";
uchar M_FILETAB[]	 =	 "File table overflow. Ignore";
uchar M_BADTAB[]	 =	 "\r Bad table/encrypted file ";
