/*
    File: HD_DRV.C            Atari AHDI Compatible Harddisk driver

    Oct 1988 V0.00 T.H. Schipper
*/
/*  HISTORY

    Oct 1988.  Started. Tested read and write routines.
    Nov 1988.  Tested send_cmd routine.
    Dec 1988.  Tested req_sense routine. Not sure it works OK.
    Jan 1989.  Tested wd_msel and wd_format.
    Jan 1989.  Tested some drive errors. Controller always reports no
               errors. (HAC bug ?).
*/
/*  Still to be done in the different modules

    Some extra low-level routines. All group zero commands.
    Complete the Installer.
    All locall variables to register type.
    Update the driver to AHDI V3.00.
        Extended partitions.
        Compatible AHDI variables. See Atari AHDI update release notes.
        Support for removeable media.
        Add extra parameter to hrw() function. See Atari AHDI update notes.
*/
/*
Copyright (c) 1988 - 1991 by Ted Schipper.

Permission to use, copy, modify, and distribute this software and its
documentation for any purpose and without fee is hereby granted,
provided that the above copyright notice appear in all copies and that
both that copyright notice and this permission notice appear in
supporting documentation.

This software is provided AS IS with no warranties of any kind.  The author
shall have no liability with respect to the infringement of copyrights,
trade secrets or any patents by this file or any part thereof.  In no
event will the author be liable for any lost revenue or profits or
other special, indirect and consequential damages.
*/

/*static char *version = "(@)HD_DVR.C,V0.00 89/06/25 21:10:35 Ted Schipper\n";*/
short errno;
short hd_boot = 0;
long  base_pg_addr = 0L;

/* MWC Compiler C Startup */

/* Entry Point */

_start()
{
 i_sasi1();         /* call the driver installer entry point */
}

