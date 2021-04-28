
* Running Programs from Accessories
* Atari ST User Clinic July 1991!!!
* =================================

* Martin Hagelin had a problem with running programs from desk
* accessories that has been solved by Kieron Matthews of Ferndown
* in Dorset. He has provided the assembler source for an accessory
* that runs Atari's disk parking program PARK.PRG

* "I also used the Pexec function of GEMDOS to run the programs,
* but stringentrules for exiting the routine must be followed."
* Kieron's program appears to work for simple programs (such as
* PARK.PRG) and a few TOS based programs, but if you attempt
* to run other GEM programs, you will run into severe problems.

start:
        move.l  #nstack,a7      Install new stack
        move.w  #10,opcode      appl_init
        move.w  #0,sintin
        move.w  #1,sintout
        move.w  #0,saddrin
        move.w  #0,saddrout
        bsr     aes
        move.w  intout,appid    Application ID
        move.w  #77,opcode
        move.w  #0,sintin
        move.w  #5,sintout
        move.w  #0,saddrin
        move.w  #0,saddrout
        bsr     aes
        move.w  intout,grhandle Graphic handle
        move.w  #35,opcode      menu_register
        move.w  #1,sintin
        move.w  #1,sintout
        move.w  #1,saddrin
        move.w  appid,intin
        move.l  #accname,addrin
        bsr     aes
        move.w  intout,accid    Accessory number

loopp:
        bsr     event           Event_multi
        cmp     #40,msgbuff     AC_OPEN message?
        bne     loopp           No
        move.w  msgbuff+8,d0    Our acc number?
        cmp     accid,d0
        bne     loopp           No
        bsr     run             Run actual program
        bra     loopp

event:
        move.w  #25,opcode      GEM evnt_multi
        move.w  #16,sintin
        move.w  #7,sintout
        move.w  #1,saddrin
        move.l  #msgbuff,addrin
        lea     table,a1
        lea     intin,a2
        moveq   #15,d0
lop1    move.w  (a1)+,(a2)+     Set parameters
        dbf     d0,lop1
        bsr     aes
        rts

aes:
        move.l  #aespb,d1
        move    #$C8,d0
        trap    #2
        rts

run:
        pea     env             Pexec
        pea     com
        pea     fil
        move.w  #0,-(sp)
        move.w  #$4B,-(sp)
        trap    #1
        lea.l   16(sp),sp
        rts

aespb           dc.l    contrl,global,intin,intout,addrin,addrout

contrl:
opcode:         ds.w    1
sintin          ds.w    1
sintout         ds.w    1
saddrin         ds.w    1
saddrout        ds.w   1

global:
apversion       ds.w    1
apcount         ds.w    1
appid           ds.w    1
apprivate       ds.w    1
ap1resv         ds.w    1
ap2resv         ds.w    1
ap3resv         ds.w    1
ap4resv         ds.w    1

intin:          ds.w    128
ptsin           ds.w    128
intout          ds.w    128
ptsout          ds.w    128
addrin          ds.w    128
addrout         ds.w    128

vdipb           dc.l    contrl,intin,ptsin,intout,ptsout
grhandle        ds.w    1

msgbuff         ds.w    16
accid           ds.l    1

table           dc.w    $13,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0
accname         dc.b    "  ************",0

fil             dc.b    "D:\PARK\PARK.PRG",0
com             dc.b    0,0
env             dc.b    0,0

                ds.l    300
nstack          ds.l    1




