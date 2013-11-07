******************************************************************************
*                                                                            *
*    break.asm  version 1.0 of 20 August 1988   (C) L.J.M. de Wit 1988       *
*                                                                            *
* This software may be used and distributed freely if not used commercially  *
* and the originator (me) is mentioned.                                      *
*                                                                            *
******************************************************************************

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
intrupt  equ   -32		; Code returned by interrupted programs

* iorec struct offsets; the buffer ptr. itself has offset 0
ibufsize equ 4
ibufhead equ 6
ibuftl   equ 8
ibuflow  equ 10
ibufhi   equ 12


brkinit:
      move.l   4(sp),a0
      adda.w   #$80,a0		; a0 points to argument string start
      moveq.l  #0,d0
      move.b   (a0)+,d0		; Get string length &
      clr.b    (a0,d0.w)	; ensure '\0' termination
nxtbyt:
      move.b   (a0)+,d0
      beq      nxtdone		; '\0' char is end of string
      cmp.b    #'A',d0
      blt.s    arge
      cmp.b    #'Z',d0
      bgt.s    arge
      or.b     #$20,d0		; Convert uppercase to lower
arge:
      cmp.b    #'e',d0		; enable
      bne.s    argd
      st       enabled		; enabled = TRUE
      bra.s    nxtbyt
argd:
      cmp.b    #'d',d0		; disable
      bne.s    argi
      sf       enabled		; enabled = FALSE
      bra.s    nxtbyt
argi:
      cmp.b    #'i',d0		; input
      bne.s    argc
      move.l   a0,-(sp)
      pea.l    inpmsg
      move.w   #cconws,-(sp)
      trap     #gemdos		; Prompt for break char
      addq.l   #6,sp
      move.w   #crawcin,-(sp)
      trap     #gemdos		; Read the char
      addq.l   #2,sp
      move.l   d0,breakcode	; and store it
      pea.l    retmsg
      move.w   #cconws,-(sp)
      trap     #gemdos		; Print a cr/lf
      addq.l   #6,sp
      move.l   (sp)+,a0
      bra.s    nxtbyt
argc:
      cmp.b    #'c',d0		; code of break char in hex
      bne.s    argz
      moveq.l  #0,d1		; d1 will contain the code
argcnxt:
      move.b   (a0)+,d0
      bne.s    argcnz		; Not end of arg string yet
      move.l   d1,breakcode	; If end, store break char
      bra      nxtdone		; and goto end of arg string interpretation
argcnz:
      cmp.b    #' ',d0		; End of number found
      beq.s    argcend
      cmp.b    #tab,d0		; this one too
      beq.s    argcend
      cmp.b    #'0',d0		; Now follows a series of tests and
      blt.s    userr		; conversions to find the hex digit's value.
      cmp.b    #'a',d0
      blt.s    argcnlc
      sub.w    #32,d0		; convert lower case to upper
argcnlc:
      cmp.b    #'F',d0
      bgt.s    userr
      cmp.b    #'9',d0
      ble.s    argcnum
      cmp.b    #'A',d0
      blt.s    userr
      subq.l   #7,d0		; Make up for diff between '9' and 'A'
argcnum:
      sub.b    #'0',d0		; '0' is the base: 0
      asl.l    #4,d1		; Multiply by 16
      or.b     d0,d1		; OR in the 4 low digits of d0 into d1
      bra.s    argcnxt
argcend:
      move.l   d1,breakcode	; Store the break key code
      bra      nxtbyt
argz:
      cmp.b    #'z',d0
      bne.s    argsep
      st       zeroed		; Set the 'zeroed' flag
      bra      nxtbyt
argsep:
      cmp.b    #' ',d0		; Accept space
      beq      nxtbyt
      cmp.b    #tab,d0		; and tab
      beq      nxtbyt
      cmp.b    #'-',d0		; and hyphen as separators (not strictly)
      beq      nxtbyt
userr:
      pea.l    usemsg		; If error in arg string show usage message
      move.w   #cconws,-(sp)
      trap     #gemdos
      addq.l   #6,sp
      move.w   #1,-(sp)
      move.w   #pterm,-(sp)
      trap     #gemdos		; and terminate with error status

nxtdone:
      move.w   #1,-(sp)
      move.w   #iorec,-(sp)
      trap     #xbios
      addq.l   #4,sp
      move.l   d0,iop		; Save pointer to iorec struct
      move.l   #-1,-(sp)
      move.w   #$46,-(sp)
      move.w   #setexc,-(sp)
      trap     #bios
      addq.l   #8,sp
      move.l   d0,oldvec	; Save old keyboard interrupt vector
      lea.l    breakey,a0
      sub.l    a0,d0
      move.l   d0,diff		; dist between start of old and new
      clr.l    -(sp)
      move.w   #super,-(sp)
      trap     #gemdos		; Supervisor mode
      addq.l   #2,sp
      move.l   d0,(sp)
      lea.l    magic,a0		; a0 points to 'magic' string in this prog
      move.l   diff,d0
      lea.l    (a0,d0.l),a1	; a1 points (perhaps) to 'magic' in old
      move.l   #(magicend-magic-1),d0	    ; # chars in 'magic' string - 1
chkmag:
      cmp.b    (a0)+,(a1)+	; Check strings for equality
      dbne     d0,chkmag
      beq.s    mageq		; If old prog DID contain magic string; else:
magne:
      move.w   #super,-(sp)
      trap     #gemdos		; Back to user mode (sp was still on stack)
      addq.l   #6,sp
      clr.l    diff		; First incarnation: will be made resident
      pea.l    breakey		; breakey will be new keyboard int. vector
      move.w   #$46,-(sp)
      move.w   #setexc,-(sp)
      trap     #bios		; Set it
      addq.l   #8,sp
      move.l   4(sp),a0		; basepage start
      move.l   #bpaglen,d0	; base page length
      add.l    textlen(a0),d0	; + text length
      add.l    datalen(a0),d0	; + data length
      add.l    bsslen(a0),d0	; + bss length
      clr.w    -(sp)		; return value: 0 for success
      move.l   d0,-(sp)		; # bytes to keep
      move.w   #ptermres,-(sp)	; keep process
      trap     #gemdos			; stops here...

mageq:
      move.w   #super,-(sp)	; second run of this program
      trap     #gemdos		; Back to user mode
      addq.l   #6,sp
      move.l   diff,d0
      lea.l    enabled,a0
      move.b   (a0),(a0,d0.l)	; Copy 'enabled' into old image
      lea.l    zeroed,a0
      move.b   (a0),(a0,d0.l)	; Do this too for 'zeroed'
      lea.l    breakcode,a0
      move.l   (a0),(a0,d0.l)	; And also for the current break char
      move.w   #pterm0,-(sp)
      trap     #gemdos		; Exits here with 0 as status.

breakey:
* The new interrupt routine
      pea.l    breaketc		; Return to breaketc after executing old code
      move.w   sr,-(sp)		; This is because old code ends with 'rte'
      move.l   oldvec,-(sp)	; Push old vector onto stack
      rts			; and jump to it

breaketc:
      tst.b    enabled
      beq      dorte		; If not enabled do nothing

      movem.l  d0-d1/a0-a2,-(sp)
      move.l   iop,a0
      move.w   ibuftl(a0),d0
      cmp.w    ibufhead(a0),d0
      beq.s    dontbreak	; If empty keyboard buffer do nothing
      move.l   (a0),a1
      move.l   (a1,d0.w),d1	; get the last entry
      and.l    #$00ff00ff,d1	; mask only scan & ASCII part
      cmp.l    breakcode,d1	; check against break code
      beq.s    normalbrk
      cmp.l    hardbreak,d1	; check against stronger break code
      bne.s    dontbreak
      moveq.l  #-1,d1		; make long negative - means hard break
normalbrk:
      tst.b    zeroed		; we have a break; is 'zeroed' flag set?
      bne.s    dozeroed
      subq.w   #4,d0		; DECREMENT d0 with wrap
      bpl.s    wrapdone
      add.w    ibufsize(a0),d0
wrapdone:
      move.w   d0,ibuftl(a0)
      bra.s    gotbreak
dozeroed:
      move.w   ibuftl(a0),ibufhead(a0)	    ; Clear the entire buffer
gotbreak:
      tst.l    d1		; hard break?
      bmi.s    dobreak
      btst.b   #5,20(sp)	; test Super bit on stacked SR
      bne.s    dontbreak

dobreak:
      movem.l  (sp)+,d0-d1/a0-a2
      move.l   #stop,2(sp)	; Return will be to the routine 'stop'
      rte

dontbreak:
      movem.l  (sp)+,d0-d1/a0-a2
dorte:
      rte

stop:
      move.w   #intrupt,-(sp)	; Code for interrupted programs
      move.w   #pterm,-(sp)
      trap     #gemdos		; and stop here

*   section  s.data

iop:        dc.l  0			; Pointer to iorec struct
breakcode:  dc.l  $002E0000		; Default is alt-C
hardbreak:  dc.l  $002D0000		; Alt-X means I really mean it!
diff:       dc.l  0			; Difference in distance old <-> new
oldvec:     dc.l  0			; previous val of interrupt vector
enabled:    dc.b  $ff			; 'enabled' is default true.
zeroed:     dc.b  0			; 'zeroed' is default false.
magic:      dc.b  'BREAK MARKER',0	; magic string identifies this prog.
magicend:
inpmsg:     dc.b  'Input the break code by hitting the key(s) : ',0
usemsg:     dc.b  'break: usage: break [-e|-d|-z] [-i|-c<code>]',cr,lf,0
retmsg:     dc.b  cr,lf,0

   end



============================================
Opinions expressed above do not necessarily	-- Allan Pratt, Atari Corp.
reflect those of Atari Corp. or anyone else.	  ...ames!atari!apratt


