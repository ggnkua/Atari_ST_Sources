******************************************************************************
*                                                                            *
*    break.asm  version 1.0 of 20 August 1988   (C) L.J.M. de Wit 1988       *
*                                                                            *
* This software may be used and distributed freely if not used commercially  *
* and the originator (me) is mentioned.                                      *
*                                                                            *
******************************************************************************
*
* NAME
*    break - stop current program on receipt of interrupt character
*
* SYNTAX
*    break [-e|-d|-z] [-i|-c<code>]
*
* DESCRIPTION
*
*    After installing break, any program can be interrupted.
*    This is achieved by 'extending' the existing keyboard interrupt
*    routine: after executing the old code the break character check
*    is done.
*
*    The various flags have the following meaning:
*       e(nable) : the current break character will end the program.
*                  the code returned is -32, what seems to be the standard
*                  value for programs interrupted by ^C in GEMDOS.
*       d(isable): no actions are done; this restores the old behaviour
*       z(ero)   : the current break character will be discarded (made 0)
*                  in the input buffer; this can be used to disable ^C.
*       i(nput)  : the break character is prompted for. Combinations with
*                  shift, control and alternate keys are also allowed.
*                  Useful for specifying the break character interactively.
*       c(ode)   : specifies the break character as a hexadecimal code.
*                  The hex code must follow the 'c' flag immediately.
*                  Useful for specifying the break character from a script.
*    Of the flags e,d and z only one should be used; e is the default.
*    Also, of the flags i and c only one should be used; control-delete is
*    the default. This is done on purpose; you can always change it to ^C
*    if you want to (or whatever key you like).
*     
*    The break program can be reused indefinitely, because a next invocation
*    is not made memory resident; it only modifies parameters in the first
*    invocation (the resident one).
*
*    The program can be placed into the \AUTO folder to be installed
*    automatically, or activated 'by hand'. If placed in the \AUTO folder, it
*    should of course have a .PRG extension (break.prg); as \AUTO folder
*    programs don't get arguments, the break will be enabled and the break
*    character is control-delete in this case.
*
* BUGS/SHORTCOMINGS
*    A nice extension would be the possibility to catch the interrupt from
*    a user program; this could be achieved by using a new trap. As this
*    implies restoring the old interrupt catch routine when the program
*    exits, and maybe also core dumps could be added to the action of an
*    (other) interrupt character, such a more general signal mechanism is
*    not added (yet). Gives me time to think of a nice implementation 8-).
*
* JOKE
*    Gimme a break, huh?!
*

      module  break
      section s.ccode

* character codes
tab      equ   9
lf       equ   10
cr       equ   13

* GEMDOS & (X)BIOS stuff
gemdos   equ   1
bios     equ   13
xbios    equ   14
ptermres equ   $31
setexc   equ   5
cconws   equ   9
crawcin  equ   7
super    equ   $20
pterm0   equ   0
pterm    equ   $4c
iorec    equ   14

* divers
bpaglen  equ   $100
textlen  equ   12
datalen  equ   20
bsslen   equ   28
intrupt  equ   -32               * Code returned by interrupted programs
curproc  equ   $602c             * Contains base page start of current process

* iorec struct offsets; the buffer ptr. itself has offset 0
ibufsize equ 4
ibufhead equ 6
ibuftl   equ 8
ibuflow  equ 10
ibufhi   equ 12


brkinit
      move.l   4(sp),a0
      adda.w   #$80,a0           * a0 points to argument string start
      moveq.l  #0,d0
      move.b   (a0)+,d0          * Get string length &
      clr.b    (a0,d0.w)         * ensure '\0' termination
nxtbyt
      move.b   (a0)+,d0
      beq      nxtdone           * '\0' char is end of string
      cmp.b    #'A',d0
      blt.s    arge
      cmp.b    #'Z',d0
      bgt.s    arge
      or.b     #$20,d0           * Convert uppercase to lower
arge
      cmp.b    #'e',d0           * enable
      bne.s    argd
      st       enabled           * enabled = TRUE
      bra.s    nxtbyt
argd
      cmp.b    #'d',d0           * disable
      bne.s    argi
      sf       enabled           * enabled = FALSE
      bra.s    nxtbyt
argi
      cmp.b    #'i',d0           * input
      bne.s    argc
      move.l   a0,-(sp)
      pea.l    inpmsg
      move.w   #cconws,-(sp)
      trap     #gemdos           * Prompt for break char
      addq.l   #6,sp
      move.w   #crawcin,-(sp)
      trap     #gemdos           * Read the char
      addq.l   #2,sp
      move.l   d0,breakcode      * and store it
      pea.l    retmsg
      move.w   #cconws,-(sp)
      trap     #gemdos           * Print a cr/lf
      addq.l   #6,sp
      move.l   (sp)+,a0
      bra.s    nxtbyt
argc
      cmp.b    #'c',d0           * code of break char in hex
      bne.s    argz
      moveq.l  #0,d1             * d1 will contain the code
argcnxt
      move.b   (a0)+,d0
      bne.s    argcnz            * Not end of arg string yet
      move.l   d1,breakcode      * If end, store break char
      bra      nxtdone           * and goto end of arg string interpretation
argcnz
      cmp.b    #' ',d0           * End of number found
      beq.s    argcend
      cmp.b    #tab,d0           * this one too
      beq.s    argcend
      cmp.b    #'0',d0           * Now follows a series of tests and
      blt.s    userr             * conversions to find the hex digit's value.
      cmp.b    #'a',d0
      blt.s    argcnlc
      sub.w    #32,d0            * convert lower case to upper
argcnlc
      cmp.b    #'F',d0
      bgt.s    userr
      cmp.b    #'9',d0
      ble.s    argcnum
      cmp.b    #'A',d0
      blt.s    userr
      subq.l   #7,d0             * Make up for diff between '9' and 'A'
argcnum
      sub.b    #'0',d0           * '0' is the base: 0
      asl.l    #4,d1             * Multiply by 16
      or.b     d0,d1             * OR in the 4 low digits of d0 into d1
      bra.s    argcnxt
argcend
      move.l   d1,breakcode      * Store the break key code
      bra      nxtbyt
argz
      cmp.b    #'z',d0
      bne.s    argsep
      st       zeroed            * Set the 'zeroed' flag
      bra      nxtbyt
argsep
      cmp.b    #' ',d0           * Accept space
      beq      nxtbyt
      cmp.b    #tab,d0           * and tab
      beq      nxtbyt
      cmp.b    #'-',d0           * and hyphen as separators (not strictly)
      beq      nxtbyt
userr
      pea.l    usemsg            * If error in arg string show usage message
      move.w   #cconws,-(sp)
      trap     #gemdos
      addq.l   #6,sp
      move.w   #1,-(sp)
      move.w   #pterm,-(sp)
      trap     #gemdos           * and terminate with error status

nxtdone
      move.w   #1,-(sp)
      move.w   #iorec,-(sp)
      trap     #xbios
      addq.l   #4,sp
      move.l   d0,iop            * Save pointer to iorec struct
      move.l   #-1,-(sp)
      move.w   #$46,-(sp)
      move.w   #setexc,-(sp)
      trap     #bios
      addq.l   #8,sp
      move.l   d0,oldvec         * Save old keyboard interrupt vector
      lea.l    breakey,a0
      sub.l    a0,d0
      move.l   d0,diff           * Difference between start addr of old and new
      clr.l    -(sp)
      move.w   #super,-(sp)
      trap     #gemdos           * Supervisor mode
      addq.l   #2,sp
      move.l   d0,(sp)           * Save supervisor stack pointer on stack
      lea.l    magic,a0          * a0 points to 'magic' string in this prog
      move.l   diff,d0
      lea.l    (a0,d0.l),a1      * a1 points (perhaps) to 'magic' in old
      move.l   #(magicend-magic-1),d0 * # chars in 'magic' string minus one
chkmag
      cmp.b    (a0)+,(a1)+       * Check strings for equality
      dbne     d0,chkmag
      beq.s    mageq             * If old prog DID contain magic string; else:
magne
      move.w   #super,-(sp)
      trap     #gemdos           * Back to user mode (sp was still on stack)
      addq.l   #6,sp
      clr.l    diff              * First incarnation: will be made resident
      pea.l    breakey           * breakey will be new keyboard int. vector
      move.w   #$46,-(sp)
      move.w   #setexc,-(sp)
      trap     #bios             * Set it
      addq.l   #8,sp
      move.l   4(sp),a0          * basepage start
      move.l   #bpaglen,d0       * base page length
      add.l    textlen(a0),d0    * + text length
      add.l    datalen(a0),d0    * + data length
      add.l    bsslen(a0),d0     * + bss length
      clr.w    -(sp)             * return value: 0 for success
      move.l   d0,-(sp)          * # bytes to keep
      move.w   #ptermres,-(sp)   * keep process
      trap     #gemdos           * stops here...

mageq
      move.w   #super,-(sp)      * A next incarnation of break in this branch.
      trap     #gemdos           * Back to user mode (sp was still on stack)
      addq.l   #6,sp
      move.l   diff,d0
      lea.l    enabled,a0
      move.b   (a0),(a0,d0.l)    * Copy 'enabled' into old image
      lea.l    zeroed,a0
      move.b   (a0),(a0,d0.l)    * Do this too for 'zeroed'
      lea.l    breakcode,a0
      move.l   (a0),(a0,d0.l)    * And also for the current break char
      move.w   #pterm0,-(sp)
      trap     #gemdos           * Exits here with 0 as status.

breakey
* The new interrupt routine
      pea.l    breaketc          * Return to breaketc after executing old code
      move.w   sr,-(sp)          * This is because old code ends with 'rte'
      move.l   oldvec,-(sp)      * Push old vector onto stack
      rts                        * and jump to it
breaketc
      movem.l  d0-d1/a0-a2,-(sp)
      tst.b    enabled
      beq.s    breakend          * If not enabled do nothing
      move.l   iop,a0
      move.w   ibuftl(a0),d0
      cmp.w    ibufhead(a0),d0
      beq.s    breakend          * If empty keyboard buffer do nothing
      moveq.l  #2,d0
      move.l   curproc,a1
testbp
      tst.l    (a1)              * At end of list?
      beq.s    breakend          * Cur. prog was desktop or so; don't break
      move.l   36(a1),a1         * Back link to previous process
      dbra     d0,testbp
      moveq.l  #0,d0
      move.w   ibufhead(a0),d0   * d0 is used as index into char buffer
      move.l   breakcode,d1
      move.l   (a0),a1           * a1 points to character buffer
testbuf
      cmp.w    ibuftl(a0),d0
      beq.s    breakend          * Checked them all
      addq.l   #4,d0             * Increment index in buffer
      cmp.w    ibufsize(a0),d0   * If at buffer size
      bne.s    notatend
      moveq.l  #0,d0             * wrap it (circular buffer)
notatend
      cmp.l    (a1,d0.w),d1      * Is char at this index the break char?
      bne.s    testbuf           * No; check next
      tst.b    zeroed            * Yes; is 'zeroed' flag set?
      beq.s    notzeroed
      clr.l    (a1,d0.w)         * Make the break char in the buffer 0;
      bra.s    testbuf           * this eliminates any special meaning
notzeroed
      move.w   ibuftl(a0),ibufhead(a0) * Clear the entire buffer
      move.l   #stop,22(sp)      * Return will be to the routine 'stop'
breakend
      movem.l  (sp)+,d0-d1/a0-a2
      rte

stop
      move.w   #intrupt,-(sp)    * Code for interrupted programs
      move.w   #pterm,-(sp)
      trap     #gemdos           * and stop here

   section  s.data

iop         dc.l  0              * Pointer to iorec struct
breakcode   dc.l  $0053001f      * Default is control_delete
diff        dc.l  0              * Difference in byte distance old <-> new
oldvec      dc.l  0              * previous val of interrupt vector
enabled     dc.b  $ff            * 'enabled' is default true.
zeroed      dc.b  0              * 'zeroed' is default false.
magic       dc.b  'BREAK MARKER',0 * magic string that identifies this prog.
magicend
inpmsg      dc.b  'Input the break code by hitting the key(s) : ',0
usemsg      dc.b  'break: usage: break [-e|-d|-z] [-i|-c<code>]',cr,lf,0
retmsg      dc.b  cr,lf,0

   end


