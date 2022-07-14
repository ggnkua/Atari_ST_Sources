/*
 *  vectors.S: bios vector intercepts for USB storage under TOS/FreeMiNT
 *
 *  Based on the assembler code by David Galvez (2010-2012), which
 *  was itself extracted from the USB disk utility assembler code by
 *  Didier Mequignon (2005-2009).
 *
 *  Copyright 2014 Roger Burrows <rfburrows@ymail.com>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 *  MA 02110-1301, USA.
 */

    .global _install_vectors
    .extern _usb_getbpb,_usb_rwabs,_usb_mediach

/*
 *  miscellaneous definitions
 */
#define _hdv_bpb        0x472
#define _hdv_rw         0x476
#define _hdv_mediach    0x47E
#define pinfo_pun       2           /* offset to pun[] within PUN_INFO */

// FixME - defined in xhdi.h as well
#define MAX_LOGICAL_DRIVE   32

    .text
/*
 *  install vectors
 */
_install_vectors:
    lea     -16(sp),sp
    movem.l d0-d1/a0-a1,(sp)        //save registers
    move.w  sr,d0                   //save old status register
    move.w  d0,-(sp)
    ori.l   #0x0700,d0
    move.w  d0,sr                   //mask interrupts

    move.l  #_hdv_bpb,a0            //bpb handler
    lea     save_hdv_bpb,a1
    move.l  (a0),(a1)               //save old
    lea     my_hdv_bpb,a1
    move.l  a1,(a0)                 //install new

    move.l  #_hdv_rw,a0             //rw handler
    lea     save_hdv_rw,a1
    move.l  (a0),(a1)               //save old
    lea     my_hdv_rw,a1
    move.l  a1,(a0)                 //install new

    move.l  #_hdv_mediach,a0        //mediach handler
    lea     save_hdv_mediach,a1
    move.l  (a0),(a1)               //save old
    lea     my_hdv_mediach,a1
    move.l  a1,(a0)                 //install new

    move.w  (sp)+,d0                //exit:
    move.w  d0,sr                   //restore interrupts
    movem.l (sp),d0-d1/a0-a1
    lea     16(sp),sp               //restore registers
    rts

/*
 *  hdv_bpb intercept
 */
    dc.l    0x58425241              //XBRA
    dc.l    0x5f555342              //id _USB
save_hdv_bpb:
    dc.l    0
my_hdv_bpb:
    moveq   #0,d0                   //ok to clobber, since Getbpb() returns a value in d0
    move.w  4(sp),d0                //d0 = drive
    move.l  a0,-(sp)                //save work register
    cmpi.l  #MAX_LOGICAL_DRIVE,d0   //valid drive?
    bcc.s   .bpbnext                //no, go to next handler
    lea     _pun_usb,a0             //a0 -> pun_usb
    tst.b   pinfo_pun(a0,d0.l)      //is it one of ours?
    bpl.s   .bpbget                 //yes, go get bpb
.bpbnext:                           //go to next handler
    move.l  (sp)+,a0                //restore register
    move.l  save_hdv_bpb,-(sp)      //& go
    rts

.bpbget:
    subq.l  #8,sp
    movem.l d1/a1,(sp)              //save other GCC scratch registers
    move.l  d0,-(sp)                //drive number
    jsr     _usb_getbpb
    addq.l  #4,sp
    movem.l (sp),d1/a1              //restore d1, a1
    addq.l  #8,sp
    move.l  (sp)+,a0                //restore a0
    rts

/*
 *  hdv_rw intercept
 */
    dc.l    0x58425241              //XBRA
    dc.l    0x5f555342              //id _USB
save_hdv_rw:
    dc.l    0
my_hdv_rw:
                                    //ok to clobber d0, since Rwabs() returns a value in d0
    move.w  4(sp),d0                //d0.w = mode
    swap    d0
    move.w  14(sp),d0               //d0.w = drive
    move.l  a0,-(sp)                //save work register
    btst    #3+16,d0                //physical mode?
    beq.s   .rwlogical              //no, go handle
                                    //handle physical mode requests
                                    //note: we subtract 2 from the physical drive #
    andi.l  #0x0000ffff,d0          //d0.l = drive
    subq.l  #2,d0                   //allow for floppies
    bmi.b   .rwnext                 //not for us
    btst    #5,d0                   //is the PUN_USB bit set?
    beq.s   .rwnext                 //no, can't be for us
    btst    #6,d0                   //is bit 6 set?
    bne.s   .rwnext                 //yes, not ours
                                    //search pun[] for match
    lea     _pun_usb+pinfo_pun,a0   //a0 -> pun[]
.rwloop:
    tst.b   (a0)                    //entry valid?
    bmi.s   .rwincr                 //no
    cmp.b   (a0),d0                 //matching entry?
    beq.b   .rwio                   //yes, ok
.rwincr:
    addq.l  #1,a0
    cmpa.l  #_pun_usb+pinfo_pun+MAX_LOGICAL_DRIVE,a0
    bne.s   .rwloop
    bra.s   .rwnext                 //not found, on to next handler
                                    //handle normal requests
.rwlogical:
    andi.l  #0x0000ffff,d0          //d0.l = drive
    cmpi.l  #MAX_LOGICAL_DRIVE,d0   //valid drive?
    bcc.s   .rwnext                 //no, go to next handler
    lea     _pun_usb,a0             //a0 -> pun_usb
    tst.b   pinfo_pun(a0,d0.l)      //is it one of ours?
    bpl.s   .rwio                   //yes, go do i/o

.rwnext:                            //go to next handler
    move.l  (sp)+,a0                //restore register
    move.l  save_hdv_rw,-(sp)       //& go
    rts

.rwio:                              //do the i/o
    lea     -12(sp),sp
    movem.l d1-d2/a1,(sp)           //save registers
    movea.w 4+16(sp),a1             //a1 = mode
    movea.l 6+16(sp),a0             //a0 = buffer ptr
    moveq.l #0,d2
    move.w  10+16(sp),d2            //d2 == sector count
    moveq.l #0,d1
    move.w  12+16(sp),d1            //d1 = sector number
    cmpi.w  #0xffff,d1              //special value?
    bne.s   .rwcall                 //no, branch
    move.l  16+16(sp),d1            //else use long value
.rwcall:                            //call the C routine
    move.l  a1,-(sp)                //mode
    move.l  a0,-(sp)                //buffer ptr
    move.l  d2,-(sp)                //logical sector count
    move.l  d1,-(sp)                //logical sector number
    move.l  d0,-(sp)                //drive number
    jsr     _usb_rwabs
    lea     20(sp),sp
    movem.l (sp),d1-d2/a1           //restore registers
    lea     12(sp),sp
    move.l  (sp)+,a0                //restore a0
    rts

/*
 *  hdv_mediach intercept
 */
    dc.l    0x58425241              //XBRA
    dc.l    0x5f555342              //id _USB
save_hdv_mediach:
    dc.l    0
my_hdv_mediach:
                                    //ok to clobber d0, since Mediach() returns a value in d0
    moveq   #0,d0
    move.w  4(sp),d0                //d0 = drive
    move.l  a0,-(sp)                //save work register
    cmpi.l  #MAX_LOGICAL_DRIVE,d0   //valid drive?
    bcc.s   .medianext              //no, go to next handler
    lea     _pun_usb,a0             //a0 -> pun_usb
    tst.b   pinfo_pun(a0,d0.l)      //is it one of ours?
    bpl.s   .mediatst               //yes, go test mediachange
.medianext:                         //go to next handler
    move.l  (sp)+,a0                //restore register
    move.l  save_hdv_mediach,-(sp)  //& go
    rts

.mediatst:
    subq.l  #8,sp
    movem.l d1/a1,(sp)              //save other GCC scratch registers
    move.l  d0,-(sp)                //drive number
    jsr     _usb_mediach
    addq.l  #4,sp
    movem.l (sp),d1/a1              //restore d1, a1
    addq.l  #8,sp
    move.l  (sp)+,a0                //restore a0
    rts

    .data
// Config block for SETTER.TTP/.PRG
    .even
    .global _enable_flop_mediach
hkbg:
    .asciz "hAruNs cONfigER"
    .dc.l hkbg

    .asciz "Media change detection for USB floppy drives"
    .even
    .dc.w 0x0000    // type = 0, boolean
_enable_flop_mediach:
    .dc.w 0x0000    // default value = FALSE

    .dc.w 0    // end