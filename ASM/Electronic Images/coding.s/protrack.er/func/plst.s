                PART 'PLST (disabled)'
;---- PLST ----

plst:
                jmp     shownotimpl

                IFEQ beta

                clr.b   rawkeycode
                cmpi.w  #6,currscreen
                beq     exitplst
                cmpi.w  #1,currscreen
                bne     return2
                jsr     waitforbuttonup
                move.w  #6,currscreen
                jsr     clearrightarea
                jsr     clearanalyzercolors
                bsr.s   drawplstscreen
;                beq     exitplst       ;; memory alloc error!
                bsr     redrawplst
plst_rts:
                rts

drawplstscreen:
                lea     plstdata,A0     ;;
                move.l  #plstsize,D0    ;;
                bsr     decompact       ;;
;                beq     return2        ;;
                lea     topmenuspos,A0  ;;
                moveq   #98,D0          ;;
dplstloop1:     moveq   #7,D3           ;;
                moveq   #24,D1          ;;
dplstloop2:
                move.b  2574(A1),2(A0)  ;;
                move.b  (A1)+,(A0)      ;;
                adda.w  D3,A0           ;;
                eori.w  #6,D3           ;;
                dbra    D1,dplstloop2   ;;
                lea     160-103(A0),A0  ;;
                addq.l  #1,A1           ;;
                dbra    D0,dplstloop1   ;;
                bsr     freedecompmem
                moveq   #-1,D0
                rts

showdisknames:
                move.w  #616,textoffset
                move.w  #5,textlength
                movea.l #sttext1,A0
                bsr     showtext2
                addq.w  #1,textoffset
                movea.l #sttext2,A0
                bsr     showtext2
                addq.w  #1,textoffset
                movea.l #sttext3,A0
                bra     showtext2

plstchecknum:
                tst.l   plstmem
                beq     noplst
                tst.l   maxplstoffset
                beq     noplst
                movea.l plstmem(PC),A0
                move.w  presettotal(PC),D7
                subq.w  #1,D7
                tst.b   sttext1number
                bne     plstsskip
                tst.b   sttext2number
                bne     plstsskip
                tst.b   sttext3number
                beq     plstmarkall
plstsskip:
                movea.l sttext1number-1(PC),A3
                movea.l sttext2number-1(PC),A4
                movea.l sttext3number-1(PC),A5
                moveq   #0,D6
plstmarkloop:
                move.w  #'st',(A0)      ; Set lowercase 'st'
                move.b  3(A0),D0
                cmp.b   #'a',D0
                blo.s   pmlskp1
                sub.b   #32,D0
pmlskp1:        move.b  D0,3(A0)
                move.b  4(A0),D0
                cmp.b   #'a',D0
                blo.s   pmlskp2
                sub.b   #32,D0
pmlskp2:        move.b  D0,4(A0)
                move.l  2(A0),D0        ; Get number ('-01:' etc)
plstchk1:
                cmp.l   A3,D0
                bne     plstchk2
                move.w  #'ST',(A0)
                addq.w  #1,D6
                bra     plstmarknext

plstchk2:
                cmp.l   A4,D0
                bne     plstchk3
                move.w  #'ST',(A0)
                addq.w  #1,D6
                bra     plstmarknext

plstchk3:
                cmp.l   A5,D0
                bne     plstmarknext
                move.w  #'ST',(A0)
                addq.w  #1,D6
plstmarknext:
                adda.l  #30,A0
                dbra    D7,plstmarkloop
                move.w  D6,presetmarktotal
                clr.w   plstpos
                clr.l   plstoffset
                rts

plstmarkall:
                move.w  #'ST',(A0)      ; Set uppercase 'ST'
                lea     30(A0),A0
                dbra    D7,plstmarkall
                move.w  presettotal(PC),presetmarktotal
                clr.w   plstpos
                clr.l   plstoffset
                rts

noplst:         clr.w   presetmarktotal
                clr.w   plstpos
                clr.l   plstoffset
                rts

redrawplst:
                move.w  presetmarktotal(PC),wordnumber
                move.w  #189,textoffset
                bsr     print4decdigits
                bsr     showdisknames
                tst.l   plstmem
                beq     plst_rts
                tst.l   maxplstoffset
                beq     plst_rts

                move.l  plstoffset(PC),D6
                movea.l plstmem(PC),A6
                movea.w #976,A5         ; TextOffset
                lea     plstoffset(PC),A4
                moveq   #11,D7          ; Number of lines to print
                tst.l   D6
                bmi     endofplst
dtplstloop:
                cmpi.w  #'ST',0(A6,D6.l) ; Check for 'ST'
                bne     plstnext
                move.l  D6,(A4)+
                move.w  A5,textoffset
                move.w  #19,textlength
                lea     0(A6,D6.l),A3
                addq.l  #3,A3
                move.l  A3,showtextptr
                movem.l D0-A6,-(SP)
                bsr     spaceshowtext
                movem.l (SP)+,D0-A6
                move.w  22(A6,D6.l),wordnumber
                move.w  wordnumber,D0
                add.w   D0,D0
                move.w  D0,wordnumber
                movem.l D0-A6,-(SP)
                bsr     printhexword
                movem.l (SP)+,D0-A6
                add.l   #30,D6
                cmp.l   maxplstoffset(PC),D6
                bhi     endofplst
                lea     240(A5),A5      ; Next Screen position
                dbra    D7,dtplstloop
                rts

plstnext:
                add.l   #30,D6
                cmp.l   maxplstoffset(PC),D6
                bhi     endofplst
                bra     dtplstloop

endofplst:
                move.l  #$FFFFFFFF,(A4)+
                move.w  A5,textoffset
                move.w  #23,textlength
                move.l  #emptylinetext,showtextptr
                movem.l D0-A6,-(SP)
                bsr     spaceshowtext
                movem.l (SP)+,D0-A6
                lea     240(A5),A5
                dbra    D7,endofplst
                rts

typeindisk1:
                lea     sttext1number(PC),A6
                move.w  #156,linecurx
                bra     dotypeindisk

typeindisk2:
                lea     sttext2number(PC),A6
                move.w  #204,linecurx
                bra     dotypeindisk

typeindisk3:
                lea     sttext3number(PC),A6
                move.w  #252,linecurx
dotypeindisk:
                clr.b   (A6)
                clr.b   1(A6)
                jsr     storeptrcol
                jsr     setwaitptrcol
                bsr     showdisknames
                move.w  #20,linecury
                bsr     updatelinecurpos
                bsr     gethexkey
                tst.b   rawkeycode
                bne     cleardisknum
                btst    #2,$DFF016
                beq     cleardisknum
                add.w   D1,D1
                lea     fasthextable+1(PC),A0
                move.b  0(A0,D1.w),(A6)
                addq.w  #8,linecurx
                bsr     showdisknames
                bsr     updatelinecurpos
                bsr     gethexkey
                tst.b   rawkeycode
                bne     cleardisknum
                btst    #2,$DFF016
                beq     cleardisknum
                add.w   D1,D1
                lea     fasthextable+1(PC),A0
                move.b  0(A0,D1.w),1(A6)
                jsr     restoreptrcol
                bsr     plstchecknum
                bsr     redrawplst
                clr.w   linecurx
                move.w  #270,linecury
                bra     updatelinecurpos

clearalldisks:
                bsr     docleardisks
                bsr     plstchecknum
                bra     redrawplst

docleardisks:
                moveq   #0,D0
                move.b  D0,sttext1number
                move.b  D0,sttext1number+1
                move.b  D0,sttext2number
                move.b  D0,sttext2number+1
                move.b  D0,sttext3number
                move.b  D0,sttext3number+1
                rts

mountlist:
                jsr     storeptrcol
                jsr     setdiskptrcol
                bsr     docleardisks
                move.w  #1,mountflag
                lea     df0text(PC),A4
                bsr     domountlist
                lea     sttext1(PC),A0
                bsr     checkmountname
                lea     df1text(PC),A4
                bsr     domountlist
                lea     sttext2(PC),A0
                bsr     checkmountname
                lea     df2text(PC),A4
                bsr     domountlist
                lea     sttext3(PC),A0
                bsr     checkmountname
                clr.w   mountflag
                jsr     restoreptrcol
                bra     cdisknum2

domountlist:
                clr.l   fib_filename
                clr.l   fib_filename+4
                clr.l   fib_filename+8
                movea.l dosbase(PC),A6
                move.l  A4,D1
                moveq   #-2,D2
                jsr     lvolock(A6)
                move.l  D0,filelock
                beq     mounterror
                move.l  filelock(PC),D1
                move.l  #fileinfoblock,D2
                jsr     lvoexamine(A6)
                tst.l   D0
                beq     mounterror
                move.l  filelock(PC),D1
                jsr     lvounlock(A6)
mounterror:
                moveq   #-1,D0
                rts

checkmountname:
                move.w  fib_filename,D0
                beq     mounterror
                move.w  #'ST',D1        ; Check for ST
                and.w   #$1F1F,D0
                and.w   #$1F1F,D1
                cmp.w   D0,D1
                bne     cleardisknum
                move.b  fib_filename+3,D0
                lsl.w   #8,D0
                move.b  fib_filename+4,D0
                cmp.w   #'00',D0
                beq     cleardisknum
                move.b  D0,4(A0)        ; Put disk number into ST-xx
                lsr.w   #8,D0
                move.b  D0,3(A0)
                moveq   #0,D0
                rts

cleardisknum:
                clr.b   rawkeycode
                jsr     restoreptrcol
                clr.b   (A6)
                clr.b   1(A6)
                clr.w   linecurx
                move.w  #270,linecury
                bsr     updatelinecurpos
cdisknum2:
                bsr     plstchecknum
                bra     redrawplst

df0text:        DC.B 'DF0:',0,0
df1text:        DC.B 'DF1:',0,0
df2text:        DC.B 'DF2:',0,0

checkplstgadgs:
                movem.w mousex2(PC),D0-D1
                cmp.w   #120,D0
                blo     cplstend
                cmp.w   #23,D1
                bhs     plstpressed
                cmp.w   #12,D1
                bhs     plstline2
plstline1:
                cmp.w   #268,D0
                bhs     exitplst
                cmp.w   #168,D0
                bhs     cplstend
                cmp.w   #120,D0
                bhs     clearalldisks
                rts

plstline2:
                cmp.w   #268,D0
                bhs     mountlist
                cmp.w   #218,D0
                bhs     typeindisk3
                cmp.w   #168,D0
                bhs     typeindisk2
                bra     typeindisk1
cplstend:
                rts

exitplst:
                jsr     waitforbuttonup
                clr.b   rawkeycode
                jsr     clearrightarea
                jmp     displaymainscreen

plstoneup:
                tst.w   presetmarktotal
                beq     return2
                btst    #6,$BFE001
                beq     plst_rts
                move.w  plstpos,D0
                move.w  D0,D2
                subq.w  #1,D0
                tst.w   shiftkeystatus
                bne.s   pouski2
                btst    #2,$DFF016
                bne     pouskip
pouski2:        sub.w   #9,D0
pouskip:        tst.w   D0
                bpl     doplstupdown
                clr.w   D0
                bra     doplstupdown

plstonedown:
                tst.w   presetmarktotal
                beq     return2
                btst    #6,$BFE001
                beq     plst_rts
                move.w  plstpos(PC),D0
                move.w  D0,D2
                addq.w  #1,D0
                tst.w   shiftkeystatus
                bne.s   podski2
                btst    #2,$DFF016
                bne     podskip
podski2:        add.w   #9,D0
podskip:        move.w  presetmarktotal(PC),D1
                sub.w   #12,D1
                cmp.w   D0,D1
                bhs     doplstupdown
                move.w  D1,D0
doplstupdown:
                bsr     updateoffset
                bra     redrawplst

updateoffset:
                move.w  plstpos(PC),D1
                move.w  D0,plstpos
                cmp.w   D0,D1
                beq     return2
                tst.w   D0
                beq     zeroplstoffset
                subq.w  #1,D0
                movea.l plstmem(PC),A0
                moveq   #0,D6
cpoloop:        cmpi.w  #'ST',0(A0,D6.l) ; Check for 'ST'
                beq     nextplstoffset
                add.l   #30,D6
                bra     cpoloop
nextplstoffset:
                add.l   #30,D6
                dbra    D0,cpoloop
                move.l  D6,plstoffset
                rts

zeroplstoffset:
                clr.l   plstoffset
                rts

plstpressed:
                cmp.w   #24,D1
                blo     return2
                cmp.w   #95,D1
                bhi     return2
                sub.w   #24,D1
                and.l   #$FFFF,D1
                divu    #6,D1
                lsl.w   #2,D1
                lea     plstoffset(PC),A0
                move.l  0(A0,D1.w),D1
                bmi     return2
                divu    #30,D1
                addq.w  #1,D1
                move.w  D1,currentpreset
                jsr     waitforbuttonup
                bra     usepreset

;---- Load PLST ----

loadplst:
                lea     loadplsttext,A0
                jsr     areyousure
                bne     return2
                jsr     waitforbuttonup
                lea     loadingplsttext(PC),A0
                bsr     showstatustext
doloadplst:
                jsr     storeptrcol
                lea     ptpath,A0
                jsr     copypath
                lea     plstname(PC),A0
                moveq   #4,D0
dlploop:        move.b  (A0)+,(A1)+
                dbra    D0,dlploop
                move.l  #filename,D1
                move.l  #1005,D2
                movea.l dosbase(PC),A6
                jsr     lvoopen         ;;
                move.l  D0,D7
                beq     plstopenerr
                jsr     setdiskptrcol
                clr.l   presettotal
                bsr.s   allocplst
                move.l  plstmem(PC),D2
                beq     plstmemerr2
                move.l  D7,D1
                move.l  plstallocsize,D3
                movea.l dosbase(PC),A6
                jsr     lvoread         ;;
                move.l  D0,maxplstoffset
                divu    #30,D0
                move.w  D0,presettotal
cloplst:        move.l  D7,D1
                movea.l dosbase(PC),A6
                jsr     lvoclose        ;;
                bsr     plstchecknum
                bsr     showallright
                jmp     restoreptrcol

plstname:       DC.B 'PLST',0,0

allocplst:
                bsr.s   freeplst
                move.w  maxplstentries,D0
                beq     return2
                mulu    #30,D0
                move.l  D0,plstallocsize
                move.l  #memf_public+memf_clear,D1
                movea.l 4.w,A6
                jsr     lvoallocmem
                move.l  D0,plstmem
                move.w  maxplstentries,maxplstentries2
                rts

freeplst:
                clr.w   maxplstentries2
                clr.l   maxplstoffset
                clr.w   presettotal
                move.l  plstmem,D0
                beq     return2
                movea.l D0,A1
                move.l  plstallocsize,D0
                movea.l 4.w,A6
                jsr     lvofreemem
                clr.l   plstmem
                rts

plstmemerr2:
                bsr.s   plstmemerr
                bra     cloplst

plstmemerr:
                tst.w   maxplstentries
                beq.s   reptrco
                bset    #0,initerror
                lea     plstmemtext,A0
plster:         bsr.s   showstatustext
                move.w  #50,waittime
                jmp     errorrestorecol
reptrco:        jmp     restoreptrcol
plstopenerr:
                tst.w   maxplstentries
                beq.s   reptrco
                bset    #1,initerror
                lea     plstopentext,A0
                bra.s   plster

plstmemtext:    DC.B 'no mem for plst !',0
plstopentext:   DC.B 'plst not found ! ',0

                ENDC

                ENDPART
