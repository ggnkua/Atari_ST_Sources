***************************************************************************
*                                                                         *
*  TRAKREAD FDC Program.  Written by David Small.    6/86                 *
*                                                                         *
*  START magazine, Fall 1986.      Copyright 1986 by Antic Publishing.    *
*                                                                         *
*  Portions of this code (C) 1986 Atari.  Used by permission.             *
*                                                                         *
***************************************************************************
*************************************************************
* Routine to read all addr marks and track data. Plugs      *
* them into memory. Print them or display them.             *
*************************************************************
* code begins.
**************************************************************
* Get disk,side,track # to dump, in hex, from keyboard       *
**************************************************************
getdisk: nop
        lea     mdisk,a2        * pointer to mg
        lea     t1,a6           * hl return
        bra     putstring       * print string
t1:     lea     t2,a5           * ll return
        bra     getc
t2:     cmpi.b  #'a',d0         * disk a?
        beq     drivea
        cmpi.b  #'b',d0         * disk b?
        beq     driveb
        bra     getdisk
drivea: move.w  #0,thedisk      * drive a
        bra     getside
driveb: move.w  #1,thedisk      * drive b
        bra     getside
***
        .even
mdisk   .dc.b   cr,lf,cr,lf, ' Address Mark & Track Dump ',cr,lf
        .dc.b   '  by Dave Small',cr,lf
        .dc.b   ' (c) 1986 START Magazine',cr,lf
        .dc.b   cr,lf
        .dc.b   cr,lf,cr,lf,'Press  "a"  for drive A: , or, ',cr,lf
        .dc.b   'Press  "b"  for drive B:',cr,lf
        .dc.b   cr,lf,'?',00
        .even
***
getside: nop
        lea     mside,a2        * pointer to msg
        lea     t3,a6           * hl return
        bra     putstring       * print string
t3:     lea     t4,a5           * ll return
        bra     getc
t4:     cmpi.b  #'0',d0         * side 0?
        beq     side0
        cmpi.b  #'1',d0         * side 1?
        beq     side1
        bra     getside
side0:  move.w  #0,theside      * side 0
        bra     gettrack
side1:  move.w  #1,theside      * side 1
        bra     gettrack
***
        .even
mside:  .dc.b   cr,lf,'Now, Press  "0"  for side 0 (front) , or, ',cr,lf
        .dc.b   '     Press  "1"  for side 1 (back)',cr,lf,00
        .even
***
gettrack: lea   mtrack,a2       * pointer to track #$
        lea     t5,a6           * hl return addr
        bra     putstring       * print track message
t5:     lea     t6,a6           * ll return
        bra     getbyte         * go fetch a byte in hex..
* Returns it in d2.b.
t6:     move.l  #0,d0           * clean out d0
        move.b  d2,d0           * sign extend, kinda
        move.w  d0,thetrack     * save as track # to dump.
        bra     read            * and do the read.
***
        .even
mtrack: .dc.b   cr,lf,cr,lf,' Now enter, in hex, the track # to examine. ',cr,lf,00
        .even
***
* Input goodies about the disk:
thedisk:  .dc.w 0               * disk # (0=a,1=b)
theside:  .dc.w 0               * side # (0=front,1=back)
thetrack: .dc.w 0               * track # to dump, input from keybd.
*********************************************************
*  Read Address Marks                                   *
*********************************************************
read:   nop
*
* Read Address Marks.
* Passed on the stack (Matches read sector format for easy use):
*
        move.l  #mra,-(a7)      * pointer to message
        move.w  #9,-(a7)
        trap    #1              * output message
        adda.l  #6,a7           * fixee stack
*
        jsr      makesuper      * put us into supervisor mode
* Setup stack:
        move.w  #0,-(a7)        * count.w (irrelevant here)
        move.w  theside,-(a7)   * ** side.w (relevant)
        move.w  thetrack,-(a7)  * ** track.w (relevant)
        move.w  #1,-(a7)        * sector.w (irrelevant)
        move.w  thedisk,-(a7)   * ** device.w  (relevant)
        move.l  #0,-(a7)        * dummy.l (irreleveant)
        move.l  #$60000,-(a7)   * ** buffer address.l (relevant)
        jsr     readaddr
        adda.l  #20,a7          * Fix stack.
*
*********************************************************
* Read Track.                                           *
*********************************************************
*
        move.l  #mrt,-(a7)      * pointer to message
        move.w  #9,-(a7)
        trap    #1              * output message
        adda.l  #6,a7           * fixee stack
* Setup stack:
        move.w  #0,-(a7)        * count.w (irrelevant here)
        move.w  theside,-(a7)   * ** side.w (relevant)
        move.w  thetrack,-(a7)  * ** track.w (relevant)
        move.w  #1,-(a7)        * sector.w (irrelevant)
        move.w  thedisk,-(a7)   * ** device.w  (relevant)
        move.l  #0,-(a7)        * dummy.l (irreleveant)
        move.l  #$70000,-(a7)   * ** buffer address.l (relevant)
        jsr     readtrack
        adda.l  #20,a7          * unscrozzle stack
*******************************************************
* Select output device (c for console, p for printer) *
*******************************************************
selecter: nop
        lea     cp,a2           * point to message
        lea     ot2,a6
        bra     putstring       * output it
ot2:    lea     ot3,a5          * ll
        bra     getc            * get a char
ot3:    cmpi.b  #'p',d0
        beq     ptr             * its printer
        cmpi.b  #'c',d0
        beq     con             * its console
        bra     selecter        * its neither; error.

con:    move.w  #console,device * select console output
        bra     output          * do it.

ptr:    move.w  #printer,device * select printer output
        bra     output          * and go do it.
*******
        .even
cp:     .dc.b   cr,lf,'Press  c  to dump to console/screen, or,',cr,lf
        .dc.b   'Press  p  to dump to printer.',cr,lf,cr,lf
        .dc.b   '(During dump, press any key to pause, another',cr,lf
        .dc.b   ' key to restart. CTRL-C stops dump, exits.)',cr,lf,cr,lf,00
        .even
*******************************************************
* Dump the track data..                               *
*******************************************************
output: nop

* Dump Address marks: header
        lea     amh,a2                  * ptr to string
        lea     dx2,a6                  * hl return
        bra     putstring               * output string
* Dump Address marks: data
dx2:    nop

        movea.l #$60000,a4              * Address to begin dump at
        movea.l #$60000+$80,a1          * Address to end dump at (plenty)
        jsr     adump

* Track Dump Header
        lea     rth,a2                  * ptr to string
        lea     dx3,a6                  * hl return
        bra     putstring
* Track Dump Data
dx3:    nop
        movea.l #$70000,a4              * Begin Dump
        movea.l #$70000+$2000,a1        * End Dump
        jsr     dump

* End. Exit to GEM.
split:  nop                             * entry point on ctrl-C
        move.w  #0,-(a7)
        trap    #1                      * Exit, stage left (pterm)
**************************
        .even
amh     .dc.b   cr,lf,cr,lf,cr,lf,  ' Address Mark Data: ',cr,lf,cr,lf,00
        .even
rth     .dc.b   cr,lf,cr,lf,cr,lf,  ' Read Track Data: ',cr,lf,cr,lf,00
        .even
**************************
adump:  nop                             * Primary entry point
        move.l  #0,d7                   * output counter..
* print header
        lea     admheader,a2            * ptr to string
        lea     adm3,a6                 * hl cmd
        bra     putstring               * pop it out
*
        .even   
admheader:
*********1234567891123456789212345678931234567894123456789512345678961234567897
 .dc.b  '  addr  : Trk#   Side#  Sector#  Size#   CRC1    CRC2   '
        .dc.b   cr,lf,00
*********
*
        .even   
* Loop: Do Another Line
adm3: nop
* print base address (long)
        move.l  d7,d3           * d3 = input to putlong
        lea     all2,a6 * hl
        bra     putlong
* add colon
all2:   lea     all3,a6 * hl
        bra     putcolon
all3:   lea     all4,a6 * hl
        bra     putspace
all4:   nop
* do 6 bytes..
        move.l  #6-1,d4         * d4 = # bytes per set
asixloop
* fetch byte, display
        move.b  (a4)+,d2        * d2 = input to putbyte, a4 = addr, incrd
        andi.l  #$FF,d2         * insurance
        addi.l  #1,d7           * bump displayed counter up 1
        lea     afb2,a6 * hl
        bra     putbyte         * output a byte
afb2:
* 6 spaces...makes it line up.
        move.l  #6-1,d6         * counter
afb2a:  lea     afb3,a6 * hl
        bra     putspace        * output a space
afb3:   dbf     d6,afb2a
*
* See if A1 = A4. A1 is our loop limit, do not exceed.
        cmpa.l  a1,a4
        bcc     return          * disappear... if a4>a1, carry set
        dbf     d4,asixloop     * output 6 bytes
* line is done. End it.
        lea     afb6,a6         * hl
        bra     putcr
* reloop, do a new line.
afb6:   bra     adm3            * reloop
******************************************
dump:   nop                             * Primary entry point
        move.l  #0,d7                   * output counter..
* print header
        lea     dmheader,a2             * ptr to string
        lea     dm3,a6                  * hl cmd
        bra     putstring               * pop it out
*
        .even   
*
dmheader
*********1234567891123456789212345678931234567894123456789512345678961234567897
 .dc.b  '  addr  : +0 +1 +2 +3  +4 +5 +6 +7   +8 +9 +A +B  +C +D +E +F'
        .dc.b   cr,lf,00
*********
*
        .even   
* Loop: Do Another Line
dm3: nop
* Check for key waiting - suspend or exit.
        move.l  a1,tempa1       * bug fix
        jsr     status
        cmpi.w  #$ffff,d0       * ffff = yes, something there
        bne     keepgoing
* Oh, a key. Okay. Fetch it, look at it.
        lea     dm3a,a5         * ll
        bra     getc
tempa1  .dc.l   0               * store A1...
dm3a:   cmpi.b  #$03,d0         * is key a 03? ctrl-C?
        beq     split
* Okay, just pause until next key pressed.
        lea     dm3b,a5         * ll
        bra     getc
dm3b:   nop                     * and start back up.
        movea.l tempa1,a1       * bug fix: restore a1
keepgoing: nop                  * no key input.
        move.l  #2-1,d6         * d6 = # of 8 byte chunks to do
* print base address (long)
        move.l  d7,d3           * d3 = input to putlong
        lea     ll2,a6  * hl
        bra     putlong         * output a long
* add colon
ll2:
        lea     ll3,a6  * hl
        bra     putcolon
* entry point to do second 8 byte chunk (with address printout)
grploop: nop
* add space
ll3:
        lea     ll4,a6  * hl
        bra     putspace
ll4:
* do full 8 bytes..
        move.l  #2-1,d5         * d5 = ctr of 4-byte groups
* entry point to do second half of two four byte groups
twoloop
        move.l  #4-1,d4         * d4 = # bytes per set
* entry point to do 2,3,4 of 4 byte group
fourloop
* fetch byte, display
        move.b  (a4)+,d2        * d2 = input to putbyte, a4 = addr, incrd
        andi.l  #$FF,d2         * insurance
        addi.l  #1,d7           * bump displayed counter up 1
        lea     fb2,a6  * hl
        bra     putbyte         * output a byte
fb2:
        lea     fb3,a6  * hl
        bra     putspace        * output a space
fb3:
* See if A1 = A4. A1 is our loop limit, do not exceed.
        cmpa.l  a1,a4
        bcc     return          * disappear... if a4>a1, carry set
        dbf     d4,fourloop     * output 4 bytes
* now space once between groups of 4 to be neat.
        lea     fb4,a6
        bra     putspace        * output a space
fb4
        dbf     d5,twoloop      * output 1 more grp of 4 bytes
* okay, 8 bytes done. now, reprint address and colon.
        dbf     d6,grploop      * output 1 more 8 byte chunk with addr
* line is done. End it.
        lea     fb6,a6          * hl
        bra     putcr
* reloop, do a new line.
fb6:    bra     dm3             * reloop

return: rts
**************************************************
* 
* I/O Suboutines: Present register map.
*
* d0,a0: getc/putc,itoa,atoi
* d1: counter in putlong
* a1: unused
* d2,a2: getbyte,putbyte
* a2 is also input to putstring
* d3,a3: getlong,putlong
* -----
* d4,d5,d6,d7 are main routine counters
* a4 is usually a pointer at a mem location (display, go, etc)
* a5 is the return address for low level (ll) subroutines
* a6 is the return address for high level (hl) subroutines.
* a7 is stack pointer .. a no-no to use.
* 
***************************************************
cr      equ     $0d
lf      equ     $0a
***************************************************
*         SUBROUTINES TO SUPPORT ALL THIS             *
*******************************************************
* findputstring
putstring       nop
* puts (a2) out until zero byte terminator hi. No conversion.
* input: a2 points to string to output.
* Clobbers a2,(a0,d0 in putc)
*
putsloop        nop
        move.b  (a2)+,d0                * fetch byte, d0 = input for putc
        cmpi.b  #0,d0                   * zero byte terminator?
        bne     ps1                     * nope
        jmp     (a6)                    * yup, bye
*
ps1:
        lea     putsloop,a5     * ll call, reloops back up
        bra     putc
*******************************************************
* findputcolon
putcolon        nop
* put a colon out to the screen. Clobbers (a0,d0 in putc).
        move.b  #':',d0
        movea.l a6,a5                   * just transfer hl to ll return
        bra     putc
*******************************************************
* findputspace
putspace
* put a space out to the screen. Clobbers (a0,d0 in putc).
        move.b  #' ',d0
        movea.l a6,a5                   * just transfer hl to ll return
        bra     putc
*******************************************************
* findputcr
putcr
* put a c, then lf, out to the screen. Clobbers (a0,d0 in putc).
        move.b  #cr,d0
        lea     putcr2,a5               * ll
        bra     putc
putcr2
        move.b  #lf,d0
        movea.l a6,a5                   * make putc return to hl..
        bra     putc
*
*******************************************************
* findputlong
putlong
* put d3.l out.
* input: d3
* clobbers: d3,a3,(d2,a2 in putbyte),(d0,a0 in putc)
* also clobbers: d1 (our private counter)
*
        movea.l a6,a3                   * storage
*
        move.l  #4-1,d1                 * counter
plloop
* rotate in first char from left
        rol.l   #8,d3
        move.b  d3,d2                   * get d3 byte into d2 (putbyte input)
        andi.l  #$ff,d2                 * insurance
        lea     pl2,a6          * hl
        bra     putbyte
pl2
        dbf     d1,plloop               * do 3 more, 4 total
        jmp     (a3)                    * stored input a6 (hl)
*********************************************************
* findputbyte
putbyte
* dumps d2.b. Clobbers: d2,(d0,a0 in putc)
        ror.l   #4,d2                   * get to high nibble first
        move.b  d2,d0                   * d0 is input to itoa
        andi.l  #$f,d0                  * insurance
        lea     pb2,a5          * ll
        bra     itoa                    * makes d0.b to ascii..
pb2
* send byte; d0 is input to putc and output from itoa, so it works fine.. 
        lea     pb3,a5
        bra     putc
*
pb3
        rol.l   #4,d2                   * back to lower nibble
        move.b  d2,d0                   * into d0 for itoa
        andi.l  #$f,d0                  * insurance
        lea     pb4,a5          * ll
        bra     itoa                    * makes d0.b ascii
pb4
* input to putc is in d0. output from itoa was in d0. works.
        lea     pb5,a5          
        bra     putc                    * send char
*
pb5
        jmp     (a6)                    * Typical hl exit.
******************************************************
* finditoa
itoa
* converts d0.nibb to d0.b in ascii. Straight lookup.
* clobbers: d0,a0
* input: d0.nibb
* note: d0,a0 also used in getc/putc. But since this calls no one
* it should be okay. Also, it is convenient, since we generally
* call those after calling this or atoi.
*
        andi.l  #$f,d0                  * mask for insurance
        lea     itoatab,a0              * a0 points to table
        adda.l  d0,a0                   * add in index
        move.b  (a0),d0                 * fetch byte into d0
        jmp     (a5)                    * ll exit
*
*
        .even   
*
itoatab
        .dc.b   '0123456789ABCDEFZZ'
*
        .even   
*
*********************************************************
* findgetlong
getlong
* gets up to 8 hex chars into d3.l
* if <8, right justifies (e.g., "100" in = 0000 0100 in d3.l)
* if >8, keeps last 8
* if <CR>, returns (only legit exit)
* if <ESC>, jumps straight to CMD .. no need to clean up stack,
*           since we don't use one.
*
* exit: d3.l contains input.
*
* clobbers: d3,a3,(a0,d0 in getc)
*
* Output <long?> as single chars. Not cleverly.. don't use registers much,
* hence, no calls to putstring (which would be easy, but would use A2,A6)
*
        lea     longmsg,a3              * a3 points to msg
longloop
        move.b  (a3)+,d0                * for output
        cmpi.b  #0,d0                   * if d0 = 0, terminate
        beq     longcont
        lea     longloop,a5             * set up for ll return and loop
        bra     putc
*
        .even
*
longmsg .dc.b   'ADDRESS (LONG) ? ',00
*
        .even
*
longcont
* okay, get to work..
*
        move.l  #0,d3           * set result to 0
* entry point to get another character
glloop
        lea     gl1,a5  * ll
        bra     getc
gl1
* analyze character. if CR, go home now.
        cmpi.b  #cr,d0          * CR?
        bne     glnotcr
        jmp     (a6)            * so leave already
******
glnotcr
* d0 is input to atoi..
        lea     gl2,a5  * ll
        bra     atoi            * convert ascii to integer in d0
gl2
* if atoi returns FF, it was an illegal character.
        cmpi.b  #$ff,d0
        beq     glloop          * oh, just ignore it
****
        andi.l  #$F,d0          * insurance
        rol.l   #4,d3           * rotate any previous chars left
        or.b    d0,d3           * save input key in d3
        bra     glloop          * and go get another.
********************************************************************
* findgetbyte
getbyte
* gets up to 2 hex digits into d2.b.
* if >2, takes last 2 b/4 <CR>
* if <2, right justifies (e.g., "A<CR>" = 0000 000A in D2.L)
*
* Output a > so we know we are waiting for a byte..
*
        move.b  #'>',d0                 * char to output
        lea     gbcont,a5               * ll return     
        bra     putc
*
gbcont  nop
*
        move.l  #$ffff0000,d2           * preset to cr-only error
gbloop
        lea     gb1,a5          * ll
        bra     getc                    * go fetchee char into d0
gb1
        cmpi.b  #cr,d0                  * cr?
        bne     gbnotcr                 * nope
        jmp     (A6)                    * yup, so exit, hl
*
gbnotcr
        cmpi.b  #$20,d0                 * space?
        bne     gbnotsp                 * nope
        andi.l  #$000000ff,d2           * mask off all top bits
        ori.l   #$eeee0000,d2           * set high word of d2 to show space
        jmp     (A6)                    * exit, HL
***
gbnotsp
* well, must be a real character. Go crunch it.
* d0 contains char.. and is input to atoi.
        lea     gb2,a5          * ll
        bra     atoi                    * return me an integer
gb2
        cmpi.b  #$ff,d0                 * if bad, ff returned
        beq     gbloop                  * just ignore it
*
        andi.l  #$f,d0                  * insurance
        rol.b   #4,d2                   * only rotate in byte.. 2 chars max
        or.b    d0,d2                   * and put it in..
        andi.l  #$ff,d2                 * mask off all higher stuff.
* that andi also gets rid of ffff ffff flags..
        bra     gbloop 
*****************************************************************
* findatoi
atoi
* converts ascii input in d0.b to integer nibble in d0.nibb. returns
* ff in d0.b if illegal (not 0-9,a-f) character.
* uses a0,d0
*
* 
        lea     atoitab,a0
        swap    d0
        move.w  #0,d0                   * counter in upper word of d0
        swap    d0
*
ailoop
        cmp.b   (a0)+,d0                * see if d0 matches table entry
        beq     aifound                 * got it
        swap    d0
        addq.l  #1,d0                   * bump counter
        cmpi.b  #$10,d0                 * if $10, we're dead
        bne     aimore                  * not yet, keep looking
* tested $10 chars, no luck. Heading west.
        swap    d0                      * be consistent (not needed, tho)
        move.l  #$ff,d0
        jmp     (a5)                    * return error
* comes here if we need to keep looking..
aimore  nop
        swap    d0                      * get back to normal..
        bra     ailoop
****
aifound
* so just return the loop index.
        swap    d0                      * its in the top half..
        andi.l  #$ff,d0                 * get rid of input nibble..
        jmp     (a5)                    * ll return
*****
*
        .even   
*
atoitab
        .dc.b   '0123456789abcdefzz'
*
        .even   
*
*********************************************************
*                                                       *
* All program I/O goes through getc/putc. Change them   *
* to change the destination device (Atari CRT, 68901,   *
* 6850, Mordor..)                                       *
*                                                       *
*********************************************************
* findgetc
getc    nop
* get input char/byte into d0.b.  Clobbers d0,a0.
        bra     congetc
*
* Atari keyset version (BIOS call)
*
* Global equates:
* Devices:
printer equ     $0              * printer device #
console EQU     $2              * bios 13 console device for conin/out/stat
*
* BIOS 13 Trap 1,2,3 Call Types:
constat equ     $1              * bios 13 parameter for input device status
conin   equ     $2              * bios 13 parameter for conin call      
conout  equ     $3              * bios 13 parameter for conout call
*
************* CONSOLE GETC ****************
* findcongetc
congetc nop                     * entry pt
* Wait for a character..
getcrdy nop                     * for no-char-yet reloop
*
        move.w  #console,-(a7)  * console call
        move.w  #constat,-(a7)  * bios status of input device call #
*
        jsr     saveregs        * save all regs but a7 around bios call
*
        trap    #13             * do call
        addq.l  #4,a7           * fix stack
* d0.l is 0 if no chars rdy, 0000 ffff if some ready.
        tst.w   d0              * test low word
        beq     getcrdy         * loop, waiting for key to be ready
*
        jsr     restregs        * fix registers
**********
* character ready, input it.
        move.w  #console,-(a7)  * device
        move.w  #conin,-(a7)    * conin call
        jsr     saveregs        * save registers but a7&d0  around bios call
        trap    #13
        adda.l  #4,a7           * fix stack
        jsr     restregs        * restore all but a7 and d0
*
        andi.l  #$ff,d0         * mask off IBM stuff in high word
* mask, check, return.
        andi.l  #$7f,d0         * mask off parity bit
* We really should echo the key to th screen..
        bra     putc            * which will jmp (a5) to return..heh
**************************************************************
* Do console input status. Exit with d0 = ff if char waiting.*
**************************************************************
status: nop
        move.w  #console,-(a7)  * console call
        move.w  #constat,-(a7)  * bios status of input device call #
*
        jsr     saveregs        * save all regs but a7 around bios call
*
        trap    #13             * do call
        addq.l  #4,a7           * fix stack
* d0.l is 0 if no chars rdy, 0000 ffff if some ready.
        jsr     restregs        * restore registers (all but a7 and d0)
*
        rts
************************************************************
* findputc
putc    nop
        bra     conputc                 * BIOS console putc
*
* put byte to device. Byte in d0.b. Uses d0,a0.
* Note: Must not destroy d0. Getc jumps here to echo input character.
*
****************************
* poll device for ok to send
****************************
*------------------------------------------------------------------------
* findconputc
conputc: nop
* Atari monitor version
* Always ready to have something sent to it.. 
*------------------------------------------------------------------------
**********
* put char
**********
*------------------------------------------------------------------------
* Atari monitor version
        movea.l d0,a0           * save d0 in a0 just in case
*
conout  EQU     $3              * BIOS parameter for conout..
        move.w  d0,-(a7)        * character to display
        move.w  device,-(a7)    * device
        move.w  #conout,-(a7)   * conout bios function
*
        jsr     saveregs        * save registers around bios call
*
        trap    #13             * do the char output function
        addq.l  #6,a7           * fix stack
*
        jsr     restregs        * restore all but a7 & d0
*
        move.l  a0,d0           * recover d0, just in case
* All done. Exit normally.
        jmp     (a5)                    * ll return
* Output redirection flag...
device  .dc.w   console                 * default to console
*-------------------------------------------------------------------------
* Save and Restore registers around a trap 13.
*
* Does not save or restore d0 or a7, because a7 is the stack,
* and because d0 is what the traps return for status..
*
* of course, this code is only good when the stack is up (but
* a bios call assumes that anyway).
*
saveregs        nop
        move.l  d0,d0bios
        move.l  d1,d1bios
        move.l  d2,d2bios
        move.l  d3,d3bios
        move.l  d4,d4bios
        move.l  d5,d5bios
        move.l  d6,d6bios
        move.l  d7,d7bios
*
        move.l  a0,a0bios
        move.l  a1,a1bios
        move.l  a2,a2bios
        move.l  a3,a3bios
        move.l  a4,a4bios
        move.l  a5,a5bios
        move.l  a6,a6bios
        move.l  a7,a7bios
        rts
********
restregs        nop
* restore all but a7 and d0. Used in bios calls in getc/putc.

*       (skip d0)
        move.l  d1bios,d1
        move.l  d2bios,d2
        move.l  d3bios,d3
        move.l  d4bios,d4
        move.l  d5bios,d5
        move.l  d6bios,d6
        move.l  d7bios,d7
*
        movea.l a0bios,a0
        movea.l a1bios,a1
        movea.l a2bios,a2
        movea.l a3bios,a3
        movea.l a4bios,a4
        movea.l a5bios,a5
        movea.l a6bios,a6
*       (skip a7)
        rts
*****
*
* save locs, used by BIOS calls only in basic i/o (getc,putc):
*
        .even
*
d0bios  dc.l    0
d1bios  dc.l    $d1d1d1d1
d2bios  dc.l    $d2d2d2d2
d3bios  dc.l    $d3d3d3d3
d4bios  dc.l    $d4d4d4d4
d5bios  dc.l    $d5d5d5d5
d6bios  dc.l    $d6d6d6d6
d7bios  dc.l    $d7d7d7d7
a0bios  dc.l    $a0a0a0a0
a1bios  dc.l    $a1a1a1a1
a2bios  dc.l    $a2a2a2a2
a3bios  dc.l    $a3a3a3a3
a4bios  dc.l    $a4a4a4a4
a5bios  dc.l    $a5a5a5a5
a6bios  dc.l    $a6a6a6a6
a7bios  dc.l    $a7a7a7a7
*
        .even

************************************************************
* end of code *
***     end
*
*       .dc.b   $4a,$fc         * SID breakpoint..going back to sid..
********************************************************
        .even
mra:    .dc.b   'Reading address marks: ',00
        .even
mrt     .dc.b   'Reading track data: ',00
        .even
********************************************************
makesuper: nop
* Get in supervisor mode so we can tweak hardware directly. 
        move    sr,d0           * If in super already, kindly do not undo
        andi.w  #$2000,d0       * Mask to super bit of status register
        bne     nowsuper        * no need to change
* Shift to Super via GEMDOS call #$20.
        move.l  #0,-(sp)        * use present USP for SSP
        move.w  #$20,-(sp)      * GEMDOS trap #20
        trap    #1
        adda.l  #6,sp           * fix stack
nowsuper: nop
        rts
*********************************************************
*------------------------------------------------------------------------
*       130-ST / 520-ST                                                 :
*       Floppy Disk Driver                                              :
*       (C)1985 Atari Corp.                                             :
*       Used here with permission (June 4, 1986).                       :
*       Modified by Dave Small to do read ID mark and track dump.       :
*       Shortened & simplified, but remarkably, still operational.      :
*------------------------------------------------------------------------
*
*------ Tunable values (subject to tweaking):
retries         equ     2               ; default # of retries - 1
midretry        equ     1               ; "middle" retry (when to reseek)
timeout         equ     $40000          ; short timeout (motor already on)
ltimeout        equ     $60000          ; long timeout (to startup motor)

*------ Floppy state variables in DSB: RAM usage..
** When we start out, we have a table for both drives of what track
** they are on.. but we don't *really know* where the drives are. They
** need an initial restore so we can be sure they are on track 0.
** Putting an FF00 into the track # forces a restore next time we SELECT
** the drive.
** Each DSB is 4 bytes long. At: $A08, $A0C in ROM version TOS.
recal           equ     $ff00           ; recalibrate flag (in dcurtrack)
** Layout of DSB: first track #, then seek rate. That is all..
dcurtrack       equ     0               ; current track#
dseekrt         equ     dcurtrack+2     ; This floppy's seek-rate (3 usually)
**
dsbsiz          equ     dseekrt+2       ; (size of a DSB..should just say 4)

** HARDWARE equates:
*--- DMA chip.
diskctl         equ     $ffff8604       ; disk controller data access
fifo            equ     $ffff8606       ; DMA mode control / status
dmahigh         equ     $ffff8609       ; DMA base high
dmamid          equ     $ffff860b       ; DMA base medium
dmalow          equ     $ffff860d       ; DMA base low

**--- 1770 select values. These are used as part A of selecting a FDC
** register; next, you output the value. (DMA chip controls a0,a1 into FDC).
cmdreg          equ     $80             ; select command register
trkreg          equ     $82             ; select track register
secreg          equ     $84             ; select sector register
datareg         equ     $86             ; select data register

*--- GI ("psg") sound chip: These are the drive A and B select lines,
*--- and the side select.
giselect        equ     $ffff8800       ; (W) sound chip register select
giread          equ     $ffff8800       ; (R) sound chip read-data
giwrite         equ     $ffff8802       ; (W) sound chip write-data
giporta         equ     $e              ; GI register# for I/O port A

*--- 68901 ("mfp") sticky chip:
** The IRQ line from the FDC comes to bit 5 of the GPIP in the MFP.
** It doesn't generate an interrupt, but we can poll for it.

mfp     equ     $fffffa00               ; mfp base
gpip    equ     mfp+1           ; general purpose I/O
*+
************************************************************************
* _floprd: Floppy Sector read (multiples are perfectly acceptable, thank
* you)
* Passed (on the stack):
*       $14(sp) count
*       $12(sp) sideno
*       $10(sp) trackno
*        $e(sp) sectno
*        $c(sp) devno
*        $8(sp) ->DSB
*        $4(sp) ->buffer
*        $0(sp) return address
*
* Returns:      EQ, the read won (on all sectors),
*               NE, the read failed (on some sector).
*
* This is here for your reference. We do not call it. However,
* note how close the read address mark and read track are to it.
**********************
_floprd:        nop
* Setup a6, a1; plug things off stack into variables. 
        bsr     floplock                ; lock floppies, setup parameters
* Select drive, plug in track & sector numbers to FDC.
frd1:   bsr     select                  ; select drive, setup registers
* Do seek to track if necessary.
        bsr     go2track                ; seek appropriate track
* If seek loses, dieg
        bne     seekfail                        ; retry on seek failure
* DMA stuff. Configure DMA chip for Disk -> RAM direction transfer
        move.w  #$090,(a6)              ; toggle DMA data direction,
        move.w  #$190,(a6)              ; leave hardware in READ state
        move.w  #$090,(a6)              
* Output # of sectors to pull in. We saved this, in floplock.
        move.w  ccount,diskctl          ; set sector count register in DMA chip
* Issue FDC read sector command. FDC will now begin.
        move.w  #cmdreg,(a6)            ; We want to talk to FDC cmd reg.
        move.w  #$90,d7                 ; 1770 read sector multple command.
        bsr     wdiskctl                ; (writes out d7 to FDC)
* Set up a timer-outer if FDC faints under workload.
        move.l  #timeout,d7             ; set timeout count
        move.l  edma,a2                 ; a2 -> target DMA address
*--- Wait for read completion:
* Entry point if FDC not done and not timed out yet.
frd2:   btst.b  #5,gpip                 ; 1770 done yet? Test MFP input of IRQ
        beq     frd4                    ; (yes) (IRQ-not)
* Read not done yet
        subq.l  #1,d7                   ; decrement timeout counter
        beq     frd3                    ; (punt on timeout)
        bra     frd2                    ; no, wait some more.
*--- timeout: reset the controller and die.
* Comes here on timeout in read poll loop.
frd3:   nop
        bsr     reset1770               ; (clobber 1770 -- reset it)
        bra     xtimeout                ; bang..we die.
*--- check status after read: Comes here when mfp shows done.
frd4:   move.w  #$090,(a6)              ; examine DMA status register
        move.w  (a6),d0                 ; fetch status byte
        btst    #0,d0                   ; bit zero indicates DMA error
        beq     dmafault                ; (when its zero -- boom)
* DMA chip said okay. Let's reloop 20 (decimal) times to grab a track
* full of ID marks.
        addi.w  #1,loopc                ; increment # of times through.
        move.w  loopc,d0
        cmpi.w  #20,d0                  ; 20 times through?
        bne     reloop
* Okay, DMA says okay, check FDC.
        move.w  #$080,(a6)              ; point to 1770 status register
        bsr     rdiskctl                ; read into d0
        and.b   #$18,d0                 ; check for RNF, checksum, lost-data
        bne     fdcbang
* Normal Exit:
        bra     normalexit
*
**********************************************************************
* Read Address Mark
* Passed (on the stack):
*       $14(sp) count n/a
*       $12(sp) sideno 
*       $10(sp) trackno
*        $e(sp) sectno n/a
*        $c(sp) devno
*        $8(sp) ->DSB 
*        $4(sp) ->buffer
*        $0(sp) return address
*
* Returns:      EQ, the read won
*               NE, the read failed
**********************-
readaddr:       nop
* Setup a6, a1; plug things off stack into variables. 
        bsr     floplock                ; lock floppies, setup parameters
* Select drive, plug in track & sector numbers to FDC.
rad1:   bsr     select                  ; select drive, setup registers
* Do seek to track if necessary.:
        bsr     go2track                ; seek appropriate track
* If seek loses, die
        bne     seekfail                        ; retry on seek failure
* DMA stuff. Configure DMA chip for Disk -> RAM direction transfer
        move.w  #$090,(a6)              ; toggle DMA data direction,
        move.w  #$190,(a6)              ; leave hardware in READ state
        move.w  #$090,(a6)              
* 1 sector only. Actually, less than that; 54 bytes/track.
        move.w  #1,diskctl              ; set sector count register in DMA chip
** Special for read address mark. We have to reissue command
** a few times to get data past the DMA chip fifo.
** Besides, there are usually 9 address marks per track,
** so, let's loop 20 (decimal) times.
        move.w  #0,loopc                ; zero counter of # of loops.
* Comes here to reissue command..
reloop: nop
        move.w  #cmdreg,(a6)            ; We want to talk to FDC cmd reg.
        move.w  #$c0,d7                 ; 1770 read ID addr marks command.
        bsr     wdiskctl                ; (writes out d7 to FDC)
* Set up a timer-outer if FDC faints under workload.
        move.l  #timeout,d7             ; set timeout count
        move.l  edma,a2                 ; a2 -> target DMA address

*--- Wait for read completion:
* Entry point if FDC not done and not timed out yet.
rad2:   btst.b  #5,gpip                 ; 1770 done yet? Test MFP input of IRQ
        beq     rad4                    ; (yes) (IRQ-not)
* Read not done yet
        subq.l  #1,d7                   ; decrement timeout counter
        beq     rad3                    ; (punt on timeout)
        bra     rad2                    ; no, wait some more.
*
*--- timeout: reset the controller and die.
* Comes here on timeout in read poll loop.
rad3:   nop
        bsr     reset1770               ; (clobber 1770 -- reset it)
        bra     xtimeout                        ; die.

*--- check status after read: Comes here when mfp shows done.

rad4:   move.w  #$090,(a6)              ; examine DMA status register
        move.w  (a6),d0                 ; fetch status byte
        btst    #0,d0                   ; bit zero indicates DMA error
        beq     dmafault                ; (when its zero -- boom)
* Okay, DMA says okay. 
* Because this is read address mark, let's reloop 20 (decimal) 
* times to grab a track full of ID marks.
        addi.w  #1,loopc                ; increment # of times through.
        move.w  loopc,d0                ; Fetch # of times into d0.
        cmpi.w  #20,d0                  ; 20 times through?
        bne     reloop                  ; Yup, keep going.
* Now check FDC status. (It does not like us to do this in midcommand.)
        move.w  #$080,(a6)              ; point to 1770 status register
        bsr     rdiskctl                ; read into d0
        and.b   #$18,d0                 ; check for RNF, checksum, lost-data
        bne     fdcbang                 ; FDC error message.
* DMA chip said okay. FDC said okay.
        bra     normalexit              ; exit, stage left.
*********************************************************************
* Track Read. 
* Passed (on the stack):
*       $14(sp) count n/a
*       $12(sp) sideno
*       $10(sp) trackno
*        $e(sp) sectno n/a
*        $c(sp) devno
*        $8(sp) ->DSB
*        $4(sp) ->buffer
*        $0(sp) return address
*
* Returns:      EQ, the read won.
*               NE, the read failed.
**********************-
readtrack:      nop
* Setup a6, a1; plug things off stack into variables. 
        bsr     floplock                ; lock floppies, setup parameters
* Select drive, plug in track & sector numbers to FDC.
rtd1:   bsr     select                  ; select drive, setup registers
* Do seek to track if necessary.:
        bsr     go2track                ; seek appropriate track
* If seek loses, die.
        bne     seekfail                        ; retry on seek failure
*
* DMA stuff. Configure DMA chip for Disk -> RAM direction transfer
        move.w  #$090,(a6)              ; toggle DMA data direction,
        move.w  #$190,(a6)              ; leave hardware in READ state
        move.w  #$090,(a6)              
* Output a very high # of sector to read, since read track transfers
* about 6000 bytes of data.
        move.w  #$50,diskctl
* Output readtrack command
        move.w  #cmdreg,(a6)            ; We want to talk to FDC cmd reg.
        move.w  #$e0,d7                 ; 1770 track read command.
        bsr     wdiskctl                ; (writes out d7 to FDC)
* Set up a timer-outer if FDC faints under workload.
        move.l  #timeout,d7             ; set timeout count
        move.l  edma,a2                 ; a2 -> target DMA address
*
* Wai for read completion..
* Entry point if FDC not done and not timed out yet.
rtd2:   btst.b  #5,gpip                 ; 1770 done yet? Test MFP input of IRQ
        beq     rtd4                    ; (yes) (IRQ-not)
* Read not done yet
        subq.l  #1,d7                   ; decrement timeout counter
        beq     rtd3                    ; (punt on timeout)
        bra     rtd2                    ; no, wait some more.
*
*--- timeout: reset the controller and die.
* Comes here on timeout in read poll loop.
rtd3:   nop
        bsr     reset1770               ; (clobber 1770 -- reset it)
        bra     xtimeout                ; (go die)
*--- check status after read: Comes here when mfp shows done.
rtd4:   move.w  #$090,(a6)              ; examine DMA status register
        move.w  (a6),d0                 ; fetch status byte
        btst    #0,d0                   ; bit zero indicates DMA error
        beq     dmafault                ; (when its zero -- boom)
* Okay, DMA says okay, check FDC.
        move.w  #$080,(a6)              ; point to 1770 status register
        bsr     rdiskctl                ; read into d0
        and.b   #$18,d0                 ; check for RNF, checksum, lost-data
        bne     fdcbang
* Normal Exit:
        bra     normalexit
******************************************************************
* Ways for the above routines to end, either with an okay or a bang!
* They all generate a diagnostic message.
*
* All okay..
normalexit:     move.l  #mok,-(a7)              ; All is well.
        move.w  #$9,-(a7)
        trap    #1
        adda.l  #6,a7
        bra     flopok                  ; return OK if no errors
* FDC seek fault..
seekfail: move.l #mseekfail,-(a7)       ; FDC seek error...
        move.w  #$9,-(a7)
        trap    #1                      ; GEMDOS
        adda.l  #6,a7
        bra     flopfail
* Other FDC errors:
fdcbang: move.l #mfdcbang,-(a7)         ; FDC error...
        move.w  #$9,-(a7)
        trap    #1                      ; GEMDOS
        adda.l  #6,a7
        bra     flopfail
* DMA fault..
dmafault: move.l #mdmafault,-(a7)       ; DMA error code fault..
        move.w  #$9,-(a7)
        trap    #1                      ; GEMDOS
        adda.l  #6,a7
        bra     flopfail                ; error exit
* FDC timeout.
xtimeout: move.l #mtimeout,-(a7)        ; FDC timed out. 
        move.w  #$9,-(a7)
        trap    #1                      ; GEMDOS
        adda.l  #6,a7
        bra     flopfail                ; error exit
*************************
        .even
mfdcbang: .dc.b ' FDC STATUS shows ERROR (rnf,crc,lostdata). ',13,10,00
        .even
mdmafault .dc.b         ' DMA STATUS shows ERROR. ',13,10,00
        .even
mok     .dc.b           ' Normal FDC command termination. ',13,10,00
        .even
mtimeout .dc.b          ' FDC went to sleep (timeout.) ERROR. ',13,10,00
        .even
mseekfail .dc.b         ' Seek failed. ERROR.',13,10,00
        .even
* Reloop counter:
loopc   .dc.w   0                       ; test only
* Messages:
        .even
*************************************
* Write sector notes:
* To do a write, here's the scoop:
*
* Setup DMA hardware for write to FDC..
*       move.w  #$190,(a6)              ; toggle DMA chip to clear status
*       move.w  #$090,(a6)
*       move.w  #$190,(a6)              ; leave in WRITE mode
* 
*       move.w  #1,d7                   ; load sector-count register
*       bsr     wdiskctl
*       move.w  #$180,(a6)              ; load "WRITE SECTOR" command
*                                       * Note: the "1" means from-Ram
*                                       * and the $80 selects FDC cmd reg
* $A0 is plain vanilla write sector, no flavors.
*       move.w  #$a0,d7                 ; into 1770 cmdreg ($a0 is 1770 cmd)
* Ship out FDC write command.
*       bsr     wdiskctl                * ship it out (in d7)
*
************************************************************
* floppy format details..
*
*       move.b  cdma+3(a5),dmalow       * setup DMA address
*       move.b  cdma+2(a5),dmamid
*       move.b  cdma+1(a5),dmahigh
*       move.w  #$190,(a6)              * toggle DMA, leave in WRITE
*       move.w  #$90,(a6)               *
*       move.w  #$190,(a6)              * leave in WRITE
*       move.w  #$1F,D7                 * very high (absurd) sector count
*       bsr     wdiskctl                * write d7 to FDC cmd register
*       move.w  #$180,(a6)              * select 1770 cmd register w/ write
*       move.w  #$F0,D7                 * format track command
*       bsr     wdiskctl
*
*************************************************************
*
* floplock - lock floppies and setup floppy parameters
*
* Passed (on the stack):
*       $18(sp) - count.W (sector count)
*       $16(sp) - side.W (side#)
*       $14(sp) - track.W (track#)
*       $12(sp) - sect.W (sector#)
*       $10(sp) - dev.W (device#)
*        $c(sp) - obsolete.L
*         8(sp) - dma.L (dma pointer)
*         4(sp) - ret1.L (caller's return address)
*         0(sp) - ret.L (floplock's return address)
*
* It is not coincidence that this matches the read and write input list;
* they call us to get stuff off stack and plug into parameters. Then,
* routine "select" actually pops this stuff into hardware.
*
* Passed:       D0.W = default error number
*
* Also, we helpfully point A6 at the DMA chip, and A1 at the DSB.
*-
floplock:
        movem.l d3-d7/a3-a6,regsave     ; save C registers
        lea     fifo,a6                 ; a6 -> fifo
* Start setting up param block..
        move.w  d0,def_error            ; set default error number
        move.w  d0,curr_err             ; set current error number
* Kick VBL off floppies..
        move.w  #1,flock                ; tell vbl not to touch floppies
* Stuff off stack:
        move.l  8(sp),cdma              ; cdma -> /even/ DMA address
        move.w  $10(sp),cdev    ; save device# (0 .. 1)
        move.w  $12(sp),csect   ; save sector# (1 .. 9, usually)
        move.w  $14(sp),ctrack  ; save track# (0 .. 39 .. 79 ..)
        move.w  $16(sp),cside   ; save side# (0 .. 1)
        move.w  $18(sp),ccount  ; save sector count (1..spt)
*--- pick a DSB: Point a1 at it.
        lea     dsb0,a1         * pick dsb 0 (drive A)
        tst.w   cdev
        beq     flock2
        lea     dsb1,a1         * pick dsb 1 (drive B)
*--- compute ending DMA address from count parameter: Plug into edma.
* This is used in multisector transfers in read-multiple-sector,
* but we don't use it here.
flock2: moveq   #0,d7
        move.w  ccount,d7               ; edma = cdma + (ccount * 512)
        lsl.w   #8,d7
        lsl.w   #1,d7                   * do a 9 shift..
        move.l  cdma,a0
        add.l   d7,a0
        move.l  a0,edma                 * save in edma
*--- recalibrate drive, if it needs it. This only happens when the DSB
* says that this drive has never awoken before, and needs an initial
* recal to match its current track # with the DSB track #. 
        tst.w   dcurtrack(a1)           ; if (curtrack < 0) recalibrate()
        bpl     flockr
*
        bsr     select                  ; select drive & side
        clr.w   dcurtrack(a1)           ; we're optimistic -- assume winnage
* Restore.
        bsr     restore                 ; attempt restore
        beq     flockr                  ; (it won)
        moveq   #10,d7                  ; attempt seek to track 10
        bsr     hseek1
        bne     flock1                  ; (failed)
        bsr     restore                 ; attempt restore again
        beq     flockr                  ; (it won)
*
flock1  move.w  #recal,dcurtrack(a1)    ; complete failure (what can we do?)
flockr: rts
*
*********************************************************************
*+
* flopfail - unlock floppies and return error.
* Common way for read and write to return.
*
* Note: Returns via unlok1.
*-
flopfail:
        move.l  #$ffffffff,d0           * aargh, error
        bra.s   unlok1                  ; clobber floppy lock & return
****************************************************
*+
* flopok - unlock floppies and return success status. Also a common
* way for r/w to return.
*
*-
flopok: clr.l   d0                      ; return 0 (success)
* Entry point from flopfail..
unlok1: move.l  d0,-(sp)                ; (save return value)
* I believe this code returns the FDC's status to a type-1 status, where
* the write protect switch is available for VBL to look at.
        move.w  #datareg,(a6)           ; force WP to real-time mode
* Sets FDC's current track register to track we are on right now.
        move.w  dcurtrack(a1),d7        ; dest-track = current track
        bsr     wdiskctl
* Does it with a "noop seek" (source=dest). Only forces FDC to type 1 status.
        move.w  #$10,d6                 ; cmd = seek w/o verify
        bsr     flopcmds                ; do it
* Look at status register..Reloops here, waiting for motor to turn off.
* If we just deselect drive, the $!@#%^$ FDC will not ever shut motor off,
* because it will never see index pulses.
waitoff: nop
        move.w  #cmdreg,(a6)            ; force WP to real-time mode
* Wait for old dimwits to turn off the motor..
        bsr     rdiskctl                ; read status into d7
        andi.w  #$0080,d0               ; mask to motoron bit
        bne     waitoff
* Turn off drive absolutely, positively
        move.b  #$07,d0
        bsr     setporta                ; turns off a,b, side
*
unlok2: move.l  (sp)+,d0                ; restore return value
        movem.l regsave,d3-d7/a3-a6     ; restore C registers
* clear floppy lock of vblank..
        clr.w   flock                   ; allow vblank .. unlock floppies
* wave byebye at the pretty camera, jenny...
        rts
************************* Seek routines ********************
*+
* hseek  - seek to 'ctrack' without verify
* hseek1 - seek to 'd7' without verify
* hseek2 - seek to 'd7' without verify, keep current error number
*
* Returns:      NE on seek failure ("cannot happen"?)
*               EQ if seek wins
*
* Uses:         d7, d6, ...
* Exits to:     flopcmds
* Called-by:    _flopfmt, _flopini
*
*-
hseek:  move.w  ctrack,d7               ; dest track = 'ctrack'
hseek1: nop
hseek2: move.w  #datareg,(a6)           ; write destination track# to data reg
        bsr     wdiskctl                ; write d7 to FDC data register
* seek command:
        move.w  #$10,d6                 ; execute "seek" command
*                                       * Note: no spinup time.
        bra     flopcmds                ; (without verify...)
*
************************************************
*+
* reseek - home head, then reseek track
* Returns:      EQ/NE on success/failure
* Falls-into:   go2track
*
*-
reseek:
        bsr     restore                 ; restore head
        bne     go2trr                  ; (punt if home fails)

        clr.w   dcurtrack(a1)           ; current track = 0
        move.w  #trkreg,(a6)            ; set "current track" reg on 1770
        clr.w   d7
        bsr     wdiskctl                * write a 00 to trk register.

        move.w  #datareg,(a6)           ; seek out to track five
        move.w  #5,d7
        bsr     wdiskctl                ; dest track = 5
        move.w  #$10,d6
        bsr     flopcmds                ; seek
*                                       * Note: no spinup time.
        bne     go2trr                  ; return error on seek failure
        move.w  #5,dcurtrack(a1)        ; set current track#

************************************************+
* go2track - seek proper track
* Passed:       Current floppy parameters (ctrack, et al.).
* Returns:      EQ/NE on success/failure
* Calls:        flopcmds
* Called by: read sector, for instance. Lots of places.
*-
go2track:
        move.w  #datareg,(a6)           ; set destination track# in
        move.w  ctrack,d7               ;  1770's data register
        bsr     wdiskctl                ; (write track#)
        moveq   #$14,d6                 ; execute 1770 "seek_with_verify"
        bsr     flopcmds                ; (include seek-rate bits)
        bne     go2trr                  ; return error on seek failure
        move.w  ctrack,dcurtrack(a1)    ; update current track number
        and.b   #$18,d7                 ; check for RNF, CRC_error, lost_data
go2trr: rts                             ; return EQ/NE on succes/failure

**************************************************
*+
* restore - home head
* Passed:       nothing
* Returns:      EQ/NE on success/failure
*-
restore:
        clr.w   d6                      ; $00 = 1770 "restore" command
        bsr     flopcmds                ; do restore
        bne     res_r                   ; punt on timeout
        btst    #2,d7                   ; test TRK00 bit
        eor     #$04,ccr                ; flip Z bit (return NE if bit is zero)
        bne     res_r                   ; punt if didn't win
        clr.w   dcurtrack(a1)           ; set current track#
res_r:  rts

*****************************************************
* Special floppy cmd just for seeking:
*+
* flopcmds - floppy command (or-in seek speed bits from database)
* Passed:       d6.w = 1770 command
* Sets-up:      seek bits (bits 0 and 1) in d6.w
* Falls-into:   flopcmd
* Returns:      EQ/NE on success/failure
*
* I get the impression this is only used for seeking. I am right.
*-
flopcmds:
        move.w  dseekrt(a1),d0          ; get floppy's seek rate bits
        and.b   #3,d0                   ; OR into command
        or.b    d0,d6
* Fall in...
*******************************************************+
* flopcmd - execute any ol' 1770 command (with timeout)
* Passed:       d6.w = 1770 command
*
* Returns:      EQ/NE on success/failure
*               d7 = 1770 status bits
*
* Note: does motor spinup, if cmd in d6 specs it (I would *hope*!)
*-
flopcmd:
        move.l  #timeout,d7             ; setup timeout count (assume short)
        move.w  #cmdreg,(a6)            ; select 1770 command register
        bsr     rdiskctl                ; read it to clobber READY status
        btst    #7,d0                   ; is motor on?
        bne     flopcm                  ; (yes, keep short timeout)
        move.l  #ltimeout,d7            ; extra timeout for motor startup
flopcm: bsr     wdiskct6                ; write command (in d6)

flopc1: subq.l  #1,d7                   ; timeout?
        beq     flopcto                 ; (yes, reset and return failure)
        btst.b  #5,gpip                 ; 1770 completion?
        bne     flopc1                  ; (not yet, so wait some more)
        bsr     rdiskct7                ; return EQ + 1770 status in d7
        clr.w   d6
        rts
*****
flopcto:
* We timed out.. a gruesome death indeed.
* Whap controller back to life.
        bsr     reset1770               ; bash controller
        moveq   #1,d6                   ; and return NE
        rts

********************************************************
*+
* reset1770 - reset disk controller after a catastrophe
* Passed:       nothing
* Returns:      nothing
* Uses:         d7
*-
reset1770:
        move.w  #cmdreg,(a6)            ; execute 1770 "reset" command
        move.w  #$d0,d7                 * force interrupt
        bsr     wdiskctl
        move.w  #15,d7                  ; wait for 1770 to stop convulsing
r1770:  dbra    d7,r1770                ; (short delay loop)
        bsr     rdiskct7                ; return 1770 status in d7
        rts

*******************************************************
*+
* select - setup drive select, 1770 and DMA registers
* Passed:       cside, cdev
* Returns:      appropriate drive and side selected
*
* Called: All over the place.
*
*-
select:
        move.w  cdev,d0                 ; get device number
        addq.b  #1,d0                   ; add and shift to get select bits
        lsl.b   #1,d0                   ; into bits 1 and 2
        or.w    cside,d0                ; or-in side number (bit 0)
        eor.b   #7,d0                   ; negate bits for funky hardware select
        and.b   #7,d0                   ; strip anything else out there
        bsr     setporta                ; do drive select
* Have to restore 1770's track register from table..in dsb.
        move.w  #trkreg,(a6)            ; setup 1770 track register
        move.w  dcurtrack(a1),d7        ; from current track number
        bsr     wdiskctl
        clr.b   tmpdma                  ; zero bits 24..32 of target DMA addr

* Setup R/W parameters on 1770. Used by
* r/w sector, among others. This is where the sector register gets set.
* 
select1:
        move.w  #secreg,(a6)            ; setup requested sector_number from
        move.w  csect,d7                ;       caller's parameters
        bsr     wdiskctl
        move.b  cdma+3,dmalow           ; setup DMA chip's DMA pointer
        move.b  cdma+2,dmamid
        move.b  cdma+1,dmahigh
        rts

*************************************************
*+
* setporta - set floppy select bits in PORT A on the sound chip
* Passed:       d0.b (low three bits)
* Returns:      d1 = value written to port A
*               d2 = old value read from port A
* Uses:         d1
*-
setporta:
        move    sr,-(sp)                ; save our IPL
        or      #$0700,sr               ; start critical section
        move.b  #giporta,giselect       ; select port on GI chip
        move.b  giread,d1               ; get current bits
        move.b  d1,d2                   ; save old bits for caller
        and.b   #$ff-7,d1               ; strip low three bits there
        or.b    d0,d1                   ; or-in our new bits
        move.b  d1,giwrite              ; and write 'em back out there
        move    (sp)+,sr                ; restore IPL to terminate CS, return
        rts

***************************************************
*+
* Primitives to read/write 1770 controller chip (DISKCTL register).
*
* The 1770 can't keep up with full-tilt CPU accesses, so
* we have to surround reads and writes with delay loops.
* This is not really as slow as it sounds.
*
wdiskct6:                               * write d6 to diskctl
        bsr     rwdelay                 ;       delay
        move.w  d6,diskctl              ;       write it
        bra     rwdelay                 ;       delay and return

wdiskctl:                               * write d7 to diskctl
        bsr     rwdelay                 ;       delay
        move.w  d7,diskctl              ;       write it
        bra     rwdelay                 ;       delay and return

rdiskct7:                               * read diskctl into d7
        bsr     rwdelay                 ;       delay
        move.w  diskctl,d7              ;       read it
        bra     rwdelay                 ;       delay and return

rdiskctl:                               * read diskctl into d0
        bsr     rwdelay                 ;       delay
        move.w  diskctl,d0              ;       read it
* And here's the delay loop:
rwdelay:
        move    sr,-(sp)                ; save flags
        move.w  d7,-(sp)                ; save counter register
        move.w  #$20,d7                 ; 0x20 seems about right...
rwdly1: dbra    d7,rwdly1               ; busy-loop: give 1770 time to settle
        move.w  (sp)+,d7                ; restore register, flags, and return
        move    (sp)+,sr
        rts

*********************************************************
        .even

*-------------- Floppy RAM usage:
* Note: move OS variables here (from .globl's)
* Note: make into dc. .. so linker doesn't have to fool with bss.
*
retrycnt:       dc.w    1               ; retry counter         (used)
*
* Note: These vars -used- to be referenced off A5, with A5.L = 0.
* Now I have made them absolute .. habit, I suppose.
*
cdev:           dc.w    4               ; device #              parm
ctrack:         dc.w    5               ; track number          parm
csect:          dc.w    6               ; sector number         parm
cside:          dc.w    7               ; side number           parm
ccount:         dc.w    8               ; sector count          parm
cdma:           dc.l    9               ; DMA address           parm
edma:           dc.l    10              ; ending DMA address    computed

tmpdma:         dc.l    11              ; temp for hardware DMA image
def_error:      dc.w    12              ; default error number
curr_err:       dc.w    13              ; current error number

regsave:        dc.l    14              ; save area for C registers (9 total)1
                dc.l    15              ; save area for C registers (9 total)2
                dc.l    16              ; save area for C registers (9 total)3
                dc.l    17              ; save area for C registers (9 total)4
                dc.l    18              ; save area for C registers (9 total)5
                dc.l    19              ; save area for C registers (9 total)6
                dc.l    20              ; save area for C registers (9 total)7
                dc.l    21              ; save area for C registers (9 total)8
                dc.l    22              ; save area for C registers (9 total)9

dsb0:           equ     $a06
dsb1:           equ     $a0a
*
* 
flock   equ     $43e            ; floppy locker
seekrate        equ     3       ; default seek at 3 msec.

        end
