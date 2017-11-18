/
/ File: HD_DVR.S         Hard disk driver startup stuff
/
////////////////////////////////////////////////////////////////////////////
/
/                           Installer
/                          -----------
/ HISTORY
/---------
/ Jun 1989. THS. Started. Needed this to boot driver with Atari HD boot
/                V0.00
/
/Copyright (c) 1988 - 1991 by Ted Schipper.
/
/Permission to use, copy, modify, and distribute this software and its
/documentation for any purpose and without fee is hereby granted,
/provided that the above copyright notice appear in all copies and that
/both that copyright notice and this permission notice appear in
/supporting documentation.
/
/This software is provided AS IS with no warranties of any kind.  The author
/shall have no liability with respect to the infringement of copyrights,
/trade secrets or any patents by this file or any part thereof.  In no
/event will the author be liable for any lost revenue or profits or
/other special, indirect and consequential damages.
/
////////////////////////////////////////////////////////////////////////////

        .comm   errno_, 2
        .globl  i_sasi1_        / hard disk driver main entry point
        .prvd

        .globl hd_boot_flg_
hd_boot_flg_:
        .word   0       / true if called by HD boot program

        .globl base_pg_addr_
base_pg_addr_:
        .long   0       / storage for basepage pointer

        .shri

        .globl _start_
_start_:
                        / if called normal, this is the normal entry point
        bra     i_sasi1_        / jump to hd driver entry point
                                / this is the entry point if called by HD boot
        st      hd_boot_flg_    / set the boot flag to TRUE
        move.l  a2,base_pg_addr_        / save base page address
        bra     i_sasi1_        / jump to hd driver entry point

