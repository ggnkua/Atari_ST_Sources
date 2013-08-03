uchar title[] =
"\r\n LHarc "LZHVERSION", Copyright (c) Yoshizaki, 1988-89\r\n"
" Atari version (c) Grunenberg, Mandel, 1994, Dirk Haun, 1996/97\r\n";

#ifndef __SHELL__

uchar title_x[] =
"   LHarc Version "LZHVERSION" (Atari)\r\n"
"   (c) Yoshizaki, 1988-1989, Grunenberg, Mandel, 1994, Haun, 1996/97";

uchar *usage[] =
{
" ================================================================ "__DATE__" =",
" Syntax: LHarc [<command>] [{{-|/}{<switchs>[-|+|0-3|<options>]}}...] <archive>",
"         [{<Drive>:[\\]}|{<Base-Directory>\\}] {[&|&-|~] <Paths/Files> ...}",
" ------------------------------------------------------------------------------",
"  <Command>",
"    a: Add files to archive             u: Update newer files to archive",
"  f,r: Freshen/Re-construct archive     m: Move files to archive (means 'a -d')",
"    d: Delete files from archive      e,x: Extract files from archive",
"    p: DisPlay files on screen        l,v: List/Verbose list of archive",
"    t: Test integrity of archive        c: Compress files in AFX-format",
" ------------------------------------------------------------------------------",
"  <Switches> (WARNING: The meaning of the d-switch has been completely changed)",
"    a: Any attribute                    b: Clear 'Changed'-attribute",
"    c: Skip time-comparison             d: Delete files after command",
"    e: Include file-comments            f: Include folders in archive",
"    g: Extract archive in folder        h: Hold screen after finishing",
"    i: Ignore attributes                j: Exclude empty files",
"    k: Header-level (0-2)               l: Use Larc compatible method",
"    m: No Message at query              n: Set process-indicator",
"    o: Use LHarc 1.13 compatible method p: Distinguish pathnames",
"    q: Suppress all messages (quiet)    r: Recursive expansion of dirs",
"    s: Convert backslashs to slashs     t: Time-stamp of archive",
"    u: Store - don't compress files     v: Display with external tool",
"    w: Specify work-directory           x: Extend filenames",
"    y: Only files with 'changed' attr.  z: Include archive-comment",
"    A: Add if file is not in archive    B: Retain backup copy of archive",
"    C: No crc-check during extraction   D: Delete if file is not specified",
"    F: create 5+3 file names            I: Compress files to directory",
"    K: Acoustic signal after finishing  L: Limit memory-allocations",
"    M: Maximum file-size                N: Only files newer than date ddmmyy",
"    O: don't extract to folder          P: Process-Indicator-Character",
"    R: Rename Unix-Files                S: Case-Sensitive filenames",
"    U: Store files uncompressed         W: No wildcard-matching",
"    X: Make relativ pathnames           Y: Encryption",
"    4: Store in Larc compatible method  5: Force LHarc 2.0x archive (lh5)",
"    ?: Display helpscreen",
"path;\ Make relativ pathnames          ~,! Exclude files",
"   &,@ Get file-list from file       &-,@- Get file-list from standard input",
" ==============================================================================",
"  (You'll find a more detailed description in the documentation 'MANUAL.ENG')",
"",
"  e-mail Yoshizaki: Nifty-Serve  PFF00253  /  oASCII-pcs   pcs02846",
0L
};
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
uchar M_NOTLZH[]     =   "Extension of archive (%s) is not 'LZH'.\r\nContinue? [Y/N]";
uchar M_OVERWT[]     =   "File exists - Overwrite [Y/N/All] or Rename?";
uchar M_ENTERNEW[]   =   "New name:";
uchar M_MKDIR[]      =   "Create folder? [Y/N/All]";
uchar M_MKDIRERR[]   =   "Unable to create folder";
uchar M_CRCERR[]     =   "";
uchar M_RDONLY[]     =   "File is read-only!";
uchar M_PRESSKEY[]   =   "-- Press key to continue --";
uchar M_COMMENT[]    =   "Comment:";
uchar M_PATH[]		 =	 "Paths/Files (wildcards possible (*?@[^-|],)) :";
uchar M_FILETAB[]	 =	 "File table overflow. Ignore";
uchar M_BADTAB[]	 =	 "\r Bad table/encrypted file ";
