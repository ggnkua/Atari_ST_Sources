;*****************************************************************************;
;   module 4a source file    Copyright 1986 Tom Bajoras
;   main menu command branching routine:  br1anch
;*****************************************************************************;

 OPT DEBUG
 OPT HCLN

 INCLUDE D_A_L.INC
 INCLUDE D_M_Z.INC
 INCLUDE BSS.INC

 SECTION foura,code

;*****************************************************************************;
;   br1anch
;      x1 = itemx
;*****************************************************************************;

 XDEF br1anch

 XREF getabc
 XREF message
 XREF checkws
 XREF synftows
 XREF readftx
 XREF wstosyn
 XREF movemem
 XREF branch1
 XREF branch2
 XREF branch6
 XREF branch8
 XREF branch8b
 XREF branch9
 XREF branch11
 XREF value
 XREF getyn
 XREF findfil
 XREF savefil
 XREF lockfil
 XREF unlkfil
 XREF usefile
 XREF writfil
 XREF namefil
 XREF lockall
 XREF unlkall
 XREF edtows
 XREF wstoed
 XREF writinfo
 XREF wstofil
 XREF syntows
 XREF diskerr
 XREF scratch
 XREF infobar
 XREF creturn
 XREF getyn
 XREF branch5
 XREF initws
 XREF readdx7
 XREF writdx7
 XREF readtx7
 XREF writfdx7

br1anch  movem.l  D0-A6,-(a7) ; save registers and x1-x5
   move.l   x1,-(a7)
   move.l   x2,-(a7)
   move.l   x3,-(a7)
   move.l   x4,-(a7)
   move.l   x5,-(a7)
   move.l   x1,d0     ; d0.l = itemx
   moveq    #0,d6     ; d6.l = menux

   tst.b    d0     ; branch according to itemx
   beq   @initws
   cmpi.b   #1,d0
   beq   @namews
   cmpi.b   #5,d0
   beq   @fetchtx
   cmpi.b   #6,d0
   beq   @wstosyn
   cmpi.b   #4,d0
   beq   @syntows
   cmpi.b   #7,d0
   beq   @lockfil
   cmpi.b   #8,d0
   beq   @unlkfil
   cmpi.b   #3,d0
   beq   @savefil
   cmpi.b   #2,d0
   beq   @usefile
   cmpi.b   #9,d0
   beq   @scrfile
   cmpi.b   #10,d0
   beq   @replace
   cmpi.b   #11,d0
   beq   @rename
   cmpi.b   #12,d0
   beq   @lockall
   cmpi.b   #13,d0
   beq   @unlkall
   cmpi.b   #14,d0
   beq   @ftosyn
   bra   returnx    ; illegal itemx simply returns:

return   jsr   writinfo
returnx  move.l   d6,x1
   jsr   infobar   ; update infobar
   move.l   (a7)+,x5  ; restore x5-x1,registers,return
   move.l   (a7)+,x4
   move.l   (a7)+,x3
   move.l   (a7)+,x2
   move.l   (a7)+,x1
   movem.l  (a7)+,D0-A6
   rts

@initws  move.l   d6,x1
   jsr   creturn creturn
   move.l   #-1,x1
   move.l   #6,x2
   jsr   getyn    ; are you sure? (y/n)
   tst.b    y1
   bne   .initws2
   jsr   branch5
.initws2 jsr   initws   ; initsnd and initname
   tst.b    monws    ; if monws=1 send w.s. to synth
   beq   returnx
   jsr   wstosyn
   jsr   writdx7
   move.l   #wkspace,x1
   add.l    #145,x1
   jsr   writfdx7
   bra   returnx    ; restore registers and x1-x5 , return

@namews  lea   .namews2,a6  ; loop back to here if bad name
.namews2 clr.l    d7
   jsr   branch8  ; get name
   move.l   a0,x1    ; a0 --> name (from branch8)
   move.l   #wksname,x2
   move.b   #10,x3
   jsr   movemem
   tst.b    monws
   beq   returnx
   jsr   wstosyn
   jsr   writdx7
   bra   returnx

@fetchtx jsr   readftx  ; read tx f-pars into buffer
   tst.b    y1    ; check for errors
   bne   .fetchtx2
   jsr   synftows
   move.l   #wkspace,x1
   jsr   checkws   ; make sure no data mangled
   bra   returnx
.fetchtx2   cmpi.b   #1,y1
   bne   .fetchtx3
   move.l   d6,x1
   jsr   creturn
   move.l   #messss,x1
   add.l    #600,x1
   move.b   #1,x2
   move.b   cursory,x3
   move.b   cmessge,x4
   lea   messsl,a0
   move.b   15(a0),x5
   jsr   message   ; synth i/o problem
   bra   returnx
.fetchtx3   move.l   d6,x1
   jsr   creturn
   move.l   #messss,x1
   add.l    #1360,x1
   move.b   #1,x2
   move.b   cursory,x3
   move.b   cmessge,x4
   lea   messsl,a0
   move.b   34(a0),x5
   jsr   message   ; bad format
   bra   returnx

@wstosyn jsr   wstosyn    ; copy w.s. to synth i/o buffer
   move.l   d6,x1
   jsr   creturn
   move.l   #38,x1
   jsr   getabc   ; send f-pars, non-f-pars, both?
   cmpi.b   #2,y1
   beq   .wstosyn2
   jsr   writdx7
   cmpi.b   #1,y1
   beq   returnx
.wstosyn2   move.l   #wkspace,x1
   add.l    #145,x1
   jsr   writfdx7
   bra   returnx    ; restore registers and x1-x5 , return

@syntows lea   .syntows2,a6   ; loop back if bad #
.syntows2   moveq    #22,d7
   jsr   branch9   ; get #
   jsr   value
   move.l   y1,d1     ; d1.l = #
   ble   .syntows3    ; bad # if < 1 or > maxslot
   cmp.l    #$7F,d1
   bgt   .syntows3
   cmp.b    maxslot,d1
   ble   .syntows4
.syntows3   move.l   #1,x2
   jsr   branch11  ; bad # routine
.syntows4   move.b   d1,x1
   jsr   readdx7  ; read a synth voice into buffer
   cmpi.b   #2,y1    ; check for data format error
   beq   synerr
   tst.b    y1
   beq   .success
   jsr   readtx7
   tst.b    y1    ; check for data format or time-out errors
   bne   synerr
.success jsr   syntows  ; copy synth i/o buffer to w.s.
   move.l   d6,x1
   jsr   creturn
   move.l   #-1,x1
   move.l   #39,x2
   jsr   getyn    ; default w.s. function parameters? (y/n)
   tst.b    y1
   beq   .syntows5
   move.l   #initsnd,x1
   add.l    #145,x1
   move.l   #wkspace,x2
   add.l    #145,x2
   move.b   #15,x3   ; if y:
   jsr   movemem  ; default w.s. function parameters
.syntows5   move.l   #wkspace,x1
   jsr   checkws  ; make sure no data mangled
   bra   returnx    ; restore registers and x1-x5 , return
synerr   move.b   y1,d1     ; protect y1
   move.l   d6,x1
   jsr   creturn
   move.l   #messss,x1
   move.b   #1,x2
   move.b   cursory,x3
   move.b   cmessge,x4
   lea   messsl,a0
   cmpi.b   #1,d1
   bne   synerr2
   add.l    #600,x1   ; time-out error
   move.b   15(a0),x5
   bra   synerrx
synerr2  add.l    #1360,x1  ; format error
   move.b   34(a0),x5
synerrx  jsr   message
   bra   returnx

@lockfil move.w   nfiles,d1
   bne   .lockfil1
   move.l   #7,x3    ; error if no files
   jsr   branch1
.lockfil1   cmp.w    nfillok,d1
   bne   .lockfil2
   move.l   #8,x3    ; error if all files already locked
   jsr   branch1
.lockfil2   lea   .lockfil3,a6  ; loop to here if bad file name
.lockfil3   moveq    #3,d7
   jsr   branch8    ; prompt for a file name
   jsr   findfil  ; try to find the file
   move.w   y1,d1    ; d1 = filex if found, else = 0
   bne   .lockfil4
   move.l   #9,x3    ; if not found, prompt again
   jsr   branch2
.lockfil4   lea   fillock,a0
   subq.l   #1,a0
   tst.b    0(a0,d1.w)
   beq   .lockfil5
   move.l   #10,x3   ; error if file already locked
   jsr   branch2
.lockfil5   move.w   d1,x1
   jsr   lockfil  ; lock the specified file
   bra   return     ; restore registers and x1-x5 , return

@unlkfil tst.w    nfiles
   bne   .unlkfil1
   move.l   #7,x3    ; error if no files
   jsr   branch1
.unlkfil1   tst.w    nfillok
   bne   .unlkfil2
   move.l   #11,x3   ; error if no files locked
   jsr   branch1
.unlkfil2   lea   .unlkfil3,a6  ; loop back to here if bad file name
.unlkfil3   moveq    #3,d7
   jsr   branch8    ; prompt for file name
   jsr   findfil  ; try to find the file
   move.w   y1,d1    ; d1 = filex if found, else = 0
   bne   .unlkfil4
   move.l   #9,x3    ; if not found, prompt again
   jsr   branch2
.unlkfil4   lea   fillock,a0
   subq.l   #1,a0
   tst.b    0(a0,d1.w)
   bne   .unlkfil5
   move.l   #12,x3   ; error if file not locked
   jsr   branch2
.unlkfil5   move.w   d1,x1
   jsr   unlkfil  ; unlock the specified file
   bra   return     ; restore registers and x1-x5 , return

@savefil lea   .savefil2,a6  ; loop back to here if bad file name
.savefil2   moveq    #3,d7
   jsr   branch8b
   jsr   findfil  ; try to find the file
   move.w   y1,d1    ; d1 = filex if found , else = 0
   beq   .savefil4
   move.l   d6,x1
   jsr   creturn
   move.l   #7,x1    ; if file is found , prompt to
   move.l   #2,x2    ; replace it (y/n)
   jsr   getyn
   tst.b    y1
   bne   .savefil3
   jsr   branch6    ; if no, abort and loop back
.savefil3   lea   fillock,a1
   subq.l   #1,a1
   tst.b    0(a1,d1.l)
   beq   .savefil5
   move.l   #14,x3   ; can't replace it if file is locked
   jsr   branch2
.savefil4   move.w   nfiles,d3
   cmp.w    maxfile,d3
   bne   .savefil5
   move.l   #30,x3   ; can't add a file to a full disk
   jsr   branch2
.savefil5   move.w   d1,x1
   jsr   savefil  ; save the file
   tst.b    y1
   beq   return
   jmp   diskerr

@usefile tst.w    nfiles
   bne   .usefile1
   move.l   #7,x3    ; error if no files
   jsr   branch1
.usefile1   lea   .usefile2,a6   ;  loop back to here if bad file name
.usefile2   moveq    #3,d7
   jsr   branch8    ; prompt for a file name
   jsr   findfil  ; try to find the file
   move.w   y1,d1    ; d1 = filex if found, else = 0
   bne   .usefile3
   move.l   #9,x3    ; error if not found
   jsr   branch2
.usefile3   move.w   d1,x1
   jsr   usefile  ; use the file
   tst.b    y1    ; all ok?
   beq   .usefile4
   jmp   diskerr
.usefile4   move.l   #wkspace,x1
   jsr   checkws  ; make sure no data is mangled
   tst.b    monws    ; if monws=1 send w.s. to synth
   beq   returnx
   jsr   wstosyn
   jsr   writdx7
   move.l   #wkspace,x1
   add.l    #145,x1
   jsr   writfdx7
   bra   returnx    ; restore registers and x1-x5 , return

@scrfile move.w   nfiles,d1
   bne   .scrfile1
   move.l   #7,x3    ; error if no files
   jsr   branch1
.scrfile1   cmp.w    nfillok,d1
   bne   .scrfile2
   move.l   #15,x3   ; error if all files locked
   jsr   branch1
.scrfile2   lea   .scrfile3,a6   ; loop back to here if bad file name
.scrfile3   moveq    #3,d7
   jsr   branch8    ; prompt for a file name
   jsr   findfil  ; try to find the file
   move.w   y1,d1    ; d1 = filex if found , else = 0
   bne   .scrfile4
   move.l   #9,x3      ; error if not found
   jsr   branch2
.scrfile4   lea   fillock,a1
   subq.l   #1,a1
   tst.b    0(a1,d1.w)
   beq   .scrfile5
   move.l   #14,x3   ; error if file is locked
   jsr   branch2
.scrfile5   move.w   d1,x1
   jsr   scratch  ; scratch the file
   bra   return     ; restore registers and x1-x5 , return

@replace move.w   nfiles,d1
   bne   .replace1
   move.l   #7,x3    ; error if no files
   jsr   branch1
.replace1   cmp.w    nfillok,d1
   bne   .replace2
   move.l   #15,x3   ; error if all files locked
   jsr   branch1
.replace2   move.l   #wksname,x1
   move.l   #namebuf,x2
   move.b   #10,x3
   jsr   movemem  ; copy w.s. name to namebuf for hashing
   jsr   findfil  ; try to find w.s. name on disk
   move.w   y1,d1    ; d1 = filex if found , else = 0
   bne   .replace3
   move.l   #16,x3   ; error if not found
   jsr   branch1
.replace3   lea   fillock,a0
   subq.l   #1,a0
   tst.b    0(a0,d1.w)
   beq   .replace4
   move.l   #14,x3   ; error if file is locked
   jsr   branch1
.replace4   lea   revtabl,a0
   subq.l   #1,a0
   cmpi.b   #$FF,0(a0,d1.w)
   bne   .replace5
   move.l   #31,x3   ; error if file is at revision 255
   jsr   branch1
.replace5   jsr   wstofil  ; copy w.s. to file i/o buffer
   move.w   d1,x1
   jsr   writfil  ; write file i/o buffer to disk
   tst.b    y1
   bne   .replace6
   addq.b   #1,0(a0,d1.w)   ; success: bump revision
   bra   return      ; and return
.replace6   jmp   diskerr   ; failure: print error message

@rename  tst.w    nfiles
   bne   .rename1
   move.l   #7,x3    ; error if no files
   jsr   branch1
.rename1 lea   .rename2,a6   ; loop back to here if bad file name
.rename2 moveq    #4,d7
   jsr   branch8    ; prompt for old file name
   jsr   findfil  ; try to find old file
   move.w   y1,d1    ; d1 = old filex if found , else = 0
   bne   .rename3
   move.l   #9,x3    ; error if not found
   jsr   branch2
.rename3 lea   .rename4,a6   ; loop back to here if bad file name
.rename4 moveq    #5,d7
   jsr   branch8    ; prompt for new file name
   jsr   findfil  ; try to find new file
   move.w   y1,d2    ; d2 = new filex if found , else = 0
   beq   .rename5
   cmp.w    d1,d2
   beq   returnx    ; do nothing if oldx=newx
   move.l   #17,x3   ; error if new name already exists
   jsr   branch2
.rename5 move.w   d1,x1
   jsr   namefil  ; rename the file
   bra   return     ; restore registers and x1-x5 , return

@lockall move.w   nfiles,d1
   bne   .lockall1
   move.l   #7,x3    ; error if no files
   jsr   branch1
.lockall1   cmp.w    nfillok,d1
   bne   .lockall2
   move.l   #26,x3   ; error if all files already locked
   jsr   branch1
.lockall2   jsr   lockall  ; lock all files
   bra   return     ; restore registers and x1-x5 , return

@unlkall tst.w    nfiles
   bne   .unlkall1
   move.l   #7,x3
   jsr   branch1
.unlkall1   tst.w    nfillok
   bne   .unlkall2
   move.l   #11,x3   ; error if no files locked
   jsr   branch1
.unlkall2   jsr   unlkall  ; unlock all files
   bra   return     ; restore registers and x1-x5 , return

@ftosyn  tst.w    nfiles   ; note: this is identical to usefile
   bne   .ftosyn1
   move.l   #7,x3    ; error if no files
   jsr   branch1
.ftosyn1 lea   .ftosyn2,a6   ;  loop back to here if bad file name
.ftosyn2 moveq    #3,d7
   jsr   branch8    ; prompt for a file name
   jsr   findfil  ; try to find the file
   move.w   y1,d1    ; d1 = filex if found, else = 0
   bne   .ftosyn3
   move.l   #9,x3    ; error if not found
   jsr   branch2
.ftosyn3 jsr   wstoed
   move.l   #wksname,x1
   move.l   #namebuf,x2
   move.b   #10,x3
   jsr   movemem
   move.w   d1,x1
   jsr   usefile  ; use the file
   tst.b    y1    ; all ok?
   beq   .ftosyn4
   jsr   edtows
   move.l   #namebuf,x1
   move.l   #wksname,x2
   move.b   #10,x3
   jsr   movemem
   jmp   diskerr
.ftosyn4 move.l   #wkspace,x1
   jsr   checkws  ; make sure no data is mangled
   jsr   wstosyn
   jsr   writdx7
   move.l   #wkspace,x1
   add.l    #145,x1
   jsr   writfdx7
   jsr   edtows
   move.l   #namebuf,x1
   move.l   #wksname,x2
   move.b   #10,x3
   jsr   movemem
   bra   returnx
