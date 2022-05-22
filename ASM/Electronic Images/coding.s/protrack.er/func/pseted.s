                PART 'pset editor/pset-ed!(disabled)'

;---- Preset Editor/PED ----

preseteditor:
                jsr     waitforbuttonup
                jmp     shownotimpl

                IFEQ beta

                move.w  #4,currscreen
                st      disableanalyzer
                st      nosampleinfo
                bsr     clearped
                bsr     swappresedscreen
ped_refresh:    bsr     clearped
                clr.w   ped_action

                jsr     setnormalptrcol
                jsr     clearanalyzercolors
                bsr     showpednumbers
                bsr     showpresetnames
                rts

swappresedscreen:
                lea     preseteddata,A1
                movea.l log_base,A0     ;;
                moveq   #122-1,D0       ;;
spesloop2:
                REPT 20
                move.l  (A0),D1         ;;
                move.l  (A1),(A0)       ;;
                move.l  D1,(A1)+        ;;
                addq.l  #8,A0
                ENDR
                dbra    D0,spesloop2    ;;
                moveq   #-1,D0
                rts

clearped:       movea.l log_base,A0     ;;
                addq.l  #4,A0           ;;
                moveq   #122-1,D0       ;;
                moveq   #0,D1           ;;
pedloop:
i               SET 0
                REPT 20
                move.l  D1,i(A0)        ;;
i               SET i+8
                ENDR
                lea     160(A0),A0
                dbra    D0,pedloop      ;;
                rts

checkpresedgadgs:
                movem.w mousex2(PC),D0-D1
                cmp.w   #45,D1
                bhs     checkpednames
                clr.w   ped_action
                jsr     setnormalptrcol
                cmp.w   #307,D0
                bhs     ped_gotoplst
ped_menu1:
                cmp.w   #101,D0
                bhs     ped_menu2
                cmp.w   #34,D1
                bhs     ped_deletedisk
                cmp.w   #23,D1
                bhs     ped_delete
                cmp.w   #12,D1
                bhs     ped_insert
                bra     ped_addpathgadg

ped_menu2:
                cmp.w   #209,D0
                bhs     ped_menu3
                cmp.w   #34,D1
                bhs     ped_clearplst
                cmp.w   #23,D1
                bhs     return2
                cmp.w   #12,D1
                bhs     ped_disk
                bra     ped_enterpath

ped_menu3:
                cmp.w   #34,D1
                bhs     ped_print
                cmp.w   #23,D1
                bhs     writeplst
                cmp.w   #12,D1
                bhs.s   xloadplst
                bra     ped_enterpath

xloadplst:
                bsr     loadplst
                move.w  #1,pedpos
                bra     ped_refresh

ped_gotoplst:
                bsr     ped_exit
                bra     plst

ped_exit:
                jsr     waitforbuttonup
                bsr     plstchecknum
                bsr     clearped        ;;
                bsr     swappresedscreen ;;

                clr.b   rawkeycode
pedexi2:        jsr     clearanalyzercolors
                jmp     displaymainall

ped_addpathgadg:
                tst.l   plstmem
                bne     pedawok
                bsr     allocplst
                tst.l   plstmem
                beq     plstmemerr
pedawok:        movea.l dosbase(PC),A6
                move.l  #peddefaultpath,D1
                moveq   #-2,D2
                jsr     lvolock(A6)
                move.l  D0,filelock
                beq     unlockreadpath
                jsr     setdiskptrcol
                lea     addingpathtext(PC),A0
                bsr     showstatustext
                movea.l dosbase(PC),A6
                move.l  filelock(PC),D1
                move.l  #fileinfoblock,D2
                jsr     lvoexamine(A6)
                tst.l   D0
                bpl     unlockreadpath
                tst.l   fib_entrytype
                bpl     checkpathdirname
                bsr     addpreset
                bra     isplstfull

checkpathdirname:
                cmpi.b  #'-',fib_filename+2
                bne     isplstfull
                move.b  fib_filename+3,snddisknum0
                move.b  fib_filename+4,snddisknum1
                bsr     showpednumbers
isplstfull:
                move.w  presettotal(PC),D0
                cmp.w   maxplstentries,D0
                blo     readpathnext
                bsr     plstisfull
                bra     readpathend

readpathnext:
                movea.l dosbase,A6
                move.l  filelock(PC),D1
                move.l  #fileinfoblock,D2
                jsr     lvoexnext(A6)
                tst.l   D0
                bpl     readpathend
                btst    #2,$DFF016
                beq     readpathend
                tst.l   fib_entrytype
                bpl     isplstfull
                cmpi.l  #'.inf',fib_filename
                beq     isplstfull
                cmpi.l  #'.inf',fib_filename+4
                beq     isplstfull
                lea     fib_filename,A0
                moveq   #28,D0
repalop:        cmpi.b  #'.',(A0)+
                beq     couldbeinfo
                dbra    D0,repalop
rpnskip:        clr.w   presetrepeat
                move.w  #1,presetreplen
                tst.b   iffloopflag     ; name is ok, test for IFF
                beq     rpnskp2
                lea     peddefaultpath,A0
                jsr     copypath
                lea     fib_filename,A0
rpncpfn:        move.b  (A0)+,(A1)+
                bne.s   rpncpfn
                move.l  #filename,D1
                move.l  #1005,D2
                movea.l dosbase(PC),A6
                jsr     lvoopen         ;;
                move.l  D0,filehandle
                beq.s   rpnskp2
                move.l  D0,D1
                lea     chkiffbuffer(PC),A2
                clr.l   (A2)
                move.l  A2,D2
                moveq   #12,D3
                jsr     lvoread         ;;
                cmpi.l  #"FORM",(A2)
                bne.s   rpnclse
                cmpi.l  #"8SVX",8(A2)
                bne.s   rpnclse
rpnvhdr:        move.l  filehandle(PC),D1
                move.l  A2,D2
                moveq   #4,D3
                jsr     lvoread         ;;
                tst.l   D0
                beq.s   rpnclse
                cmpi.l  #"VHDR",(A2)
                bne.s   rpnvhdr
                move.l  filehandle(PC),D1
                move.l  A2,D2
                moveq   #12,D3
                jsr     lvoread         ;;
                move.l  8(A2),D0
                beq.s   rpnclse
                lsr.w   #1,D0
                move.w  D0,presetreplen
                move.l  4(A2),D0
                lsr.w   #1,D0
                move.w  D0,presetrepeat
rpnclse:        move.l  filehandle(PC),D1
                jsr     lvoclose        ;;
rpnskp2:        bsr     addpreset
                bsr     showpednumbers
                bra     isplstfull

chkiffbuffer:
                DC.L 0,0,0

couldbeinfo:
                cmpi.b  #'i',(A0)+
                bne     rpnskip
                cmpi.b  #'n',(A0)+
                bne     rpnskip
                cmpi.b  #'f',(A0)+
                bne     rpnskip
                cmpi.b  #'o',(A0)+
                bne     rpnskip
                cmpi.b  #0,(A0)+
                bne     rpnskip
                bra     isplstfull


readpathend:
                movea.l dosbase(PC),A6
                move.l  filelock(PC),D1
                beq     rpeskip
                jsr     lvounlock(A6)
rpeskip:        jsr     setnormalptrcol
                bsr     showpresetnames
                bra     showallright

unlockreadpath:
                movea.l dosbase(PC),A6
                move.l  filelock(PC),D1
                beq     urpend
                jsr     lvounlock(A6)
urpend:         jmp     seterrorptrcol

addpreset:
                lea     peddefaultvol(PC),A0
                lea     presetname(PC),A1
                moveq   #5,D0           ; Disk; ST-XX...
aploop:         move.b  (A0)+,(A1)+
                dbra    D0,aploop
                lea     fib_filename,A0
                moveq   #14,D0          ; Name; 16 letters.
aploop2:        move.b  (A0)+,(A1)+
                bne     apskip
                subq.l  #1,A0
apskip:         dbra    D0,aploop2
                clr.b   (A1)
                move.l  fib_filesize,D0
                cmp.l   #$FFFE,D0
                bls.s   *+%10
                move.w  #$FFFE,D0
apskip2:        lsr.w   #1,D0
                move.w  D0,presetlength
                clr.w   presetfinetune
                lea     presetname(PC),A6
                bsr     ped_checkadd
                addq.w  #1,presettotal
                addi.l  #30,maxplstoffset
                rts

ped_insert:
                tst.l   plstmem
                bne     pediwok
                bsr     allocplst
                tst.l   plstmem
                beq     plstmemerr
pediwok:        move.w  presettotal(PC),D0
                cmp.w   maxplstentries2,D0
                bhs     plstisfull
                lea     insertpsettext(PC),A0
                lea     presetname(PC),A1
                moveq   #39,D0
pediloop:
                move.b  (A0)+,(A1)+
                dbra    D0,pediloop
possibleedit:
                jsr     storeptrcol
                jsr     setwaitptrcol
                movea.l textbplptr(PC),A0
                lea     2320(A0),A0
                moveq   #59,D0
pediloop2:
                clr.l   (A0)+
                dbra    D0,pediloop2
                lea     enterdatatext(PC),A0
                bsr     showstatustext
                move.w  #63,linecury
                lea     presetname(PC),A6
                moveq   #3,D7
                move.b  #4,entertextflag
showpsettext:
                lea     presetname+3(PC),A0
                moveq   #37,D0
                move.w  #2321,D1
                bsr     showtext3
                move.w  D7,D0
                subq.w  #3,D0
                asl.w   #3,D0
                add.w   #12,D0
                move.w  D0,linecurx
                bsr     updatelinecurpos
pediwaitkey:
                jsr     dokeybuffer
                move.b  rawkeycode(PC),D0
                beq     pediwaitkey
                clr.b   rawkeycode
                btst    #7,D0
                bne     pediwaitkey
                and.w   #$FF,D0
                cmp.b   #69,D0
                beq     ped_esckey
                cmp.b   #65,D0
                beq     ped_bkspacekey
                cmp.b   #68,D0
                beq     ped_returnkey
                cmp.b   #79,D0
                beq     ped_leftarrowkey
                cmp.b   #78,D0
                beq     ped_rightarrowkey
                cmp.b   #64,D0
                bhi     pediwaitkey
                cmp.w   #40,D7
                beq     pediwaitkey
                cmp.w   #22,D7
                beq     pediwaitkey
                lea     unshiftedkeymap(PC),A0
                tst.w   shiftkeystatus
                beq     shiftkeyskip
                lea     shiftedkeymap(PC),A0
shiftkeyskip:
                move.b  0(A0,D0.w),D1
                beq     pediwaitkey

                cmp.w   #6,D7
                blo.s   hexchk2
                cmp.w   #25,D7
                blo     ped_printchar
hexchk2:        cmp.b   #'0',D1
                blo     pediwaitkey
                cmp.b   #'f',D1
                bhi     pediwaitkey
                cmp.b   #'9',D1
                bls     ped_printchar
                cmp.b   #'a',D1
                bhs     ped_printchar
                bra     pediwaitkey

ped_printchar:
                move.b  D1,0(A6,D7.w)
                bra     ped_rightarrowkey

ped_returnkey:
                cmpi.b  #' ',psetnametext
                beq     ped_esckey
                lea     psetvoltext(PC),A0
                lea     fitutexttab+32(PC),A1
                move.b  (A0)+,D1
                lsl.w   #8,D1
                move.b  (A0),D1
                moveq   #15,D0
vofloop:        cmp.w   -(A1),D1
                beq.s   vofound
                dbra    D0,vofloop
                moveq   #0,D0
vofound:        move.w  D0,presetfinetune
                lea     psetlentext(PC),A0
                bsr     hextointeger
                lsr.w   #1,D0
                move.w  D0,presetlength
                lea     psetrepeattext(PC),A0
                bsr     hextointeger
                lsr.w   #1,D0
                move.w  D0,presetrepeat
                lea     psetreplentext(PC),A0
                bsr     hextointeger
                lsr.w   #1,D0
                move.w  D0,presetreplen
                bsr     ped_checkadd
                addq.w  #1,presettotal
ped_esckey:
                clr.w   linecurx
                move.w  #270,linecury
                bsr     updatelinecurpos
                bsr     showpresetnames
                bsr     showpednumbers
                bsr     showallright
                clr.b   entertextflag
                jmp     restoreptrcol

ped_bkspacekey:
                cmp.w   #23,D7
                bhs     pedbsend
                cmp.w   #6,D7
                bls     pedbsend
                subq.w  #1,D7
                move.b  #' ',0(A6,D7.w)
pedbsend:
                bra     showpsettext

ped_leftarrowkey:
                subq.w  #1,D7
                cmp.w   #2,D7
                bls     pedlakskip2
                cmp.w   #5,D7
                beq     pedlakskip
                cmp.w   #22,D7
                beq     pedlakskip
                cmp.w   #25,D7
                beq     pedlakskip
                cmp.w   #30,D7
                beq     pedlakskip
                cmp.w   #35,D7
                beq     pedlakskip
                bra     showpsettext

pedlakskip:
                subq.w  #1,D7
                bra     showpsettext

pedlakskip2:
                moveq   #3,D7
                bra     showpsettext

ped_rightarrowkey:
                addq.w  #1,D7
                cmp.w   #5,D7
                beq     pedrakskip
                cmp.w   #22,D7
                beq     pedrakskip
                cmp.w   #25,D7
                beq     pedrakskip
                cmp.w   #30,D7
                beq     pedrakskip
                cmp.w   #35,D7
                beq     pedrakskip
                cmp.w   #40,D7
                bhs     pedrakskip2
                bra     showpsettext

pedrakskip:
                addq.w  #1,D7
                bra     showpsettext

pedrakskip2:
                moveq   #39,D7
                bra     showpsettext

ped_checkadd:
                moveq   #23,D0
pedcaloop:
                subq.w  #1,D0
                cmpi.b  #' ',0(A6,D0.w)
                beq     pedcaloop
                clr.b   1(A6,D0.w)
                movea.l plstmem(PC),A5
                lea     30(A5),A5
pedccnextloop:
                moveq   #6,D0
                tst.b   6(A5)
                beq     ped_addpreset
ped_convertloop:
                move.b  0(A5,D0.w),D2
                bne     ped_convertcase
                tst.b   0(A6,D0.w)
                bne     ped_convertcase
                clr.b   6(A5)
                subq.w  #1,presettotal
                bra     ped_addpreset

ped_convertcase:
                cmp.b   #'A',D2
                blo     pedccskip
                cmp.b   #'Z',D2
                bhi     pedccskip
                add.b   #32,D2
pedccskip:
                move.b  0(A6,D0.w),D1
                cmp.b   #' ',D1
                beq     pedccskip3
                cmp.b   #'A',D1
                blo     pedccskip2
                cmp.b   #'Z',D1
                bhi     pedccskip2
                add.b   #32,D1
pedccskip2:
                cmp.b   D2,D1
                beq     pedccnext
                bhi     pedccskip3
                bra     ped_addpreset

pedccnext:
                addq.w  #1,D0
                cmp.w   #22,D0
                bne     ped_convertloop
pedccskip3:
                lea     30(A5),A5
                bra     pedccnextloop

ped_addpreset:  tst.b   6(A5)
                beq     pedapskip
                movea.l plstmem(PC),A1
                move.w  presettotal(PC),D0
                cmp.w   #1,D0
                beq     pedapskip
                mulu    #30,D0
                adda.l  D0,A1
                lea     30(A1),A1
                clr.b   31(A1)
pedaploop:
                move.w  (A1),30(A1)
                subq.l  #2,A1
                cmpa.l  A1,A5
                bls     pedaploop
pedapskip:
                moveq   #21,D0
pedaploop2:
                move.b  0(A6,D0.w),D1
                cmp.b   #'A',D1
                blo     pedapskip2
                cmp.b   #'Z',D1
                bhi     pedapskip2
                add.b   #32,D1
pedapskip2:
                cmp.b   #' ',D1
                bne     pedapskip3
                moveq   #0,D1
pedapskip3:
                move.b  D1,0(A5,D0.w)
                dbra    D0,pedaploop2
                move.w  presetlength(PC),22(A5)
                move.b  presetfinetune+1(PC),24(A5)
                move.b  #$40,25(A5)
                move.w  presetrepeat(PC),26(A5)
                move.w  presetreplen(PC),28(A5)
                rts



ped_delete:
                jsr     setdeleteptrcol
                move.w  #1,ped_action
                lea     selectentrytext(PC),A0
                bra     showstatustext

ped_clearplst:
                lea     clearplsttext,A0
                jsr     areyousure
                bne     return2
                bsr     freeplst
                bra     ped_refresh

clearplsttext:  DC.B 'clear plst ?',0,0

ped_print:
                lea     printplsttext,A0
                jsr     areyousure
                bne     return2
                jsr     storeptrcol
                movea.l dosbase(PC),A6
                move.l  #printpath,D1
                move.l  #1006,D2
                jsr     lvoopen         ;;
                move.l  D0,filehandle
                beq     cantopenfile
                jsr     setdiskptrcol
                move.l  D0,D1
                move.l  #psetplsttext,D2
                moveq   #56,D3
                jsr     lvowrite        ;;
                lea     printingplsttext(PC),A0
                bsr     showstatustext
                clr.w   psetnumtemp
pedpmainloop:
                move.w  psetnumtemp(PC),D0
                lea     psetprtnumtext(PC),A0
                bsr     inttodecascii
                movea.l plstmem(PC),A0
                move.w  psetnumtemp(PC),D0
                mulu    #30,D0
                adda.l  D0,A0
                move.l  A0,psetptrtemp
                lea     psetprtnametext(PC),A1
                movea.l A1,A2
                moveq   #19,D1
fillspaceloop:
                move.b  #' ',(A2)+
                dbra    D1,fillspaceloop
                moveq   #19,D1
pedploop:
                tst.b   (A0)
                beq     pedpskip
                move.b  (A0)+,(A1)+
                dbra    D1,pedploop
pedpskip:
                movea.l psetptrtemp(PC),A1
                move.w  22(A1),D0
                lea     psetprtlentext(PC),A0
                bsr     inttohexascii
                movea.l psetptrtemp(PC),A1
                move.w  26(A1),D0
                lea     psetprtrepeattext(PC),A0
                bsr     inttohexascii
                movea.l psetptrtemp(PC),A1
                move.w  28(A1),D0
                add.w   D0,D0
                lea     psetprtreplentext(PC),A0
                bsr     inttohexascii
                move.l  filehandle(PC),D1
                move.l  #psetprtnumtext,D2
                moveq   #53,D3
                jsr     lvowrite        ;;
                btst    #2,$DFF016
                beq     abortplstprint
                addq.w  #1,psetnumtemp
                move.w  psetnumtemp(PC),D0
                cmp.w   presettotal(PC),D0
                bne     pedpmainloop
                bra     pedpend

abortplstprint:
                lea     oprabortedtext(PC),A0
                bsr     showstatustext
                jsr     seterrorptrcol
pedpend:        move.l  filehandle(PC),D1
                jsr     lvoclose        ;;
                bsr     showallright
                jmp     restoreptrcol

inttodecascii:
                moveq   #3,D3
                move.l  #1000,D2
itdloop:        ext.l   D0
                divu    D2,D0
                add.b   #'0',D0
                move.b  D0,(A0)+
                divu    #10,D2
                swap    D0
                dbra    D3,itdloop
                rts


writeplst:
                lea     saveplsttext,A0
                jsr     areyousure
                bne     return2
                jsr     storeptrcol
                jsr     setdiskptrcol
                lea     savingplsttext(PC),A0
                bsr     showstatustext
                lea     ptpath,A0
                jsr     copypath
                lea     plstname(PC),A0
                moveq   #4,D0
dsploop:        move.b  (A0)+,(A1)+
                dbra    D0,dsploop
                move.l  #filename,D1
                move.l  #1006,D2
                movea.l dosbase(PC),A6
                jsr     lvoopen         ;;
                move.l  D0,D7
                beq     cantopenfile
                move.l  D0,D1
                move.l  plstmem(PC),D2
                move.w  presettotal(PC),D3
                mulu    #30,D3
                jsr     lvowrite        ;;
                move.l  D7,D1
                jsr     lvoclose        ;;
                bsr     showallright
                jmp     restoreptrcol

checkpednames:
                cmp.w   #307,D0
                blo     ped_psethit
                clr.w   ped_action
                jsr     setnormalptrcol
                cmp.w   #122,D1
                bhs     return2
                cmp.w   #111,D1
                bhs     ped_bottom
                cmp.w   #100,D1
                bhs.s   ped_onedown
                cmp.w   #67,D1
                bhs     ped_exit
                cmp.w   #56,D1
                bhs.s   ped_oneup
                bra.s   ped_top

ped_oneup:
                subq.w  #1,pedpos
                tst.w   shiftkeystatus
                bne.s   poup2
                btst    #2,$DFF016
                bne.s   pedouskip
poup2:          subq.w  #7,pedpos
pedouskip:
                cmpi.w  #1,pedpos
                bge     showpresetnames
ped_top:        move.w  #1,pedpos
                bra     showpresetnames

ped_onedown:
                cmpi.w  #9,presettotal
                blo     showpresetnames
                addq.w  #1,pedpos
                tst.w   shiftkeystatus
                bne.s   podn2
                btst    #2,$DFF016
                bne.s   pedodskip
podn2:          addq.w  #7,pedpos
pedodskip:
                move.w  presettotal,D0
                sub.w   #10,D0
                cmp.w   pedpos,D0
                bhs     showpresetnames
pedodsx:        move.w  D0,pedpos
                bra     showpresetnames

ped_bottom:
                move.w  presettotal(PC),D0
                sub.w   #11,D0
                bmi.s   ped_top
                addq.w  #1,D0
                bra.s   pedodsx

showpresetnames:
                move.w  #2321,D6
                moveq   #9,D7
                move.l  plstmem(PC),D0
                beq     return2
                movea.l D0,A5
                move.w  pedpos(PC),D0
                mulu    #30,D0
                adda.l  D0,A5
spndploop:
                tst.b   (A5)
                beq     return2
                lea     presetnametext,A1
                moveq   #21,D0
spnloop:        move.b  #' ',(A1)+
                dbra    D0,spnloop
                movea.l A5,A0
                addq.l  #3,A0
                lea     -22(A1),A1
spnloop2:
                move.b  (A0)+,D0
                beq.s   displaypreset
                move.b  D0,(A1)+
                bra.s   spnloop2

fitutexttab:
                DC.B " 0+1+2+3+4+5+6+7-8-7-6-5-4-3-2-1"

displaypreset:
                moveq   #19,D0
                lea     presetnametext,A0
                move.w  D6,D1
                bsr     showtext3
                add.w   #20,D6
                move.w  D6,textoffset
                moveq   #0,D0
                move.b  24(A5),D0
                and.b   #$0F,D0
                add.w   D0,D0
                lea     fitutexttab(PC,D0.w),A0
                move.w  #2,textlength
                bsr     showtext2
                move.w  22(A5),D0
                add.w   D0,D0
                move.w  D0,wordnumber
                addq.w  #1,textoffset
                bsr     printhexword
                move.w  26(A5),D0
                add.w   D0,D0
                move.w  D0,wordnumber
                addq.w  #1,textoffset
                bsr     printhexword
                move.w  28(A5),D0
                add.w   D0,D0
                move.w  D0,wordnumber
                addq.w  #1,textoffset
                bsr     printhexword
                add.w   #220,D6         ; 218
                lea     30(A5),A5
                dbra    D7,spndploop
                rts

ped_enterpath:
                jsr     storeptrcol
                jsr     setwaitptrcol
                clr.l   editmode
                lea     peddefaultpath(PC),A6
                bsr     updatelinecurpos
                move.l  A6,textendptr
                move.l  A6,showtextptr
                addi.l  #31,textendptr
                move.w  #20,textlength
                movea.l #178,A4
                bsr     gettextline
                clr.l   textendptr
                jmp     restoreptrcol

ped_disk:
                jsr     storeptrcol
                jsr     setwaitptrcol
                clr.l   editmode
                clr.b   snddisknum0
                clr.b   snddisknum1
                lea     snddisknum0(PC),A6
                move.l  A6,textendptr
                move.l  A6,showtextptr
                addq.l  #2,textendptr
                move.w  #2,textlength
                movea.l #621,A4
                move.b  #3,entertextflag
                bsr     gettextline
                lea     snddisknum0(PC),A6
                move.b  #':',2(A6)
                clr.b   entertextflag
                clr.l   textendptr
                jmp     restoreptrcol

showpednumbers:
                move.w  presettotal,wordnumber
                move.w  #1061,textoffset
                bsr     print4decdigits
                lea     peddefaultpath,A0
                move.w  #178,D1
                moveq   #20,D0
                bsr     showtext3
                lea     peddefaultvol,A0
                move.w  #618,D1
                moveq   #6,D0
                bra     showtext3

ped_psethit:
                cmpi.w  #1,presettotal
                beq.s   pedphend
                move.w  mousey2(PC),D0
                cmp.w   #59,D0
                blo.s   pedphend
                cmp.w   #119,D0
                bhs.s   pedphend
                sub.w   #59,D0
                divu    #6,D0
                move.l  D0,D1
                swap    D1
                cmp.w   #5,D1
                beq.s   pedphend
                move.w  D0,D2
                add.w   pedpos(PC),D2
                cmp.w   presettotal(PC),D2
                bhi.s   pedphend
                mulu    #30,D0
                movea.l plstmem(PC),A5
                adda.l  D0,A5
                move.w  pedpos(PC),D0
                mulu    #30,D0
                adda.l  D0,A5
                tst.w   ped_action
                beq.s   ped_copyname
                cmpi.w  #1,ped_action
                beq     ped_dodelete
pedphend:
                rts

ped_copyname:
                lea     presetname(PC),A0
                moveq   #21,D0
pedcnloop:
                move.b  (A5)+,D1
                bne     pedcnskip
                move.b  #' ',D1
pedcnskip:
                move.b  D1,(A0)+
                dbra    D0,pedcnloop
                moveq   #0,D0
                move.b  2(A5),D0
                and.b   #$0F,D0
                add.w   D0,D0
                lea     fitutexttab(PC),A1
                lea     0(A1,D0.w),A1
                lea     psetvoltext(PC),A0
                move.b  #' ',-1(A0)
                move.b  (A1)+,(A0)+
                move.b  (A1),(A0)
                move.w  (A5),D0
                add.w   D0,D0
                lea     6(A0),A0
                bsr     inttohexascii
                move.w  4(A5),D0
                add.w   D0,D0
                lea     9(A0),A0
                bsr     inttohexascii
                lea     9(A0),A0
                move.w  6(A5),D0
                add.w   D0,D0
                bsr     inttohexascii
                bra     possibleedit

ped_dodelete:
                clr.w   ped_action
                lea     deletepresettext,A0
                jsr     areyousure
                bne     return2
                movea.l plstmem(PC),A1
                move.w  presettotal(PC),D0
                mulu    #30,D0
                adda.l  D0,A1
pedddloop:
                move.w  30(A5),(A5)
                addq.l  #2,A5
                cmpa.l  A5,A1
                bhi.s   pedddloop
                clr.b   (A5)
                subq.w  #1,presettotal
                subi.l  #30,maxplstoffset
                move.w  pedpos(PC),D0
                add.w   #9,D0
                cmp.w   presettotal(PC),D0
                bhi.s   pedddskip
                subq.w  #1,pedpos
pedddskip:
                bsr     showpednumbers
                bsr     showpresetnames
                jsr     setnormalptrcol
                jmp     storeptrcol

sepc:           jmp     seterrorptrcol

plstisfull:
                lea     plstfulltext(PC),A0
                bsr     showstatustext
                jmp     seterrorptrcol

ped_deletedisk:
                lea     deldisktext(PC),A0
                move.b  snddisknum0(PC),10(A0)
                move.b  snddisknum1(PC),11(A0)
                jsr     areyousure
                bne     return2
                jsr     storeptrcol
                jsr     setwaitptrcol
                movea.l plstmem(PC),A0
                movea.l A0,A1
                move.w  presettotal(PC),D0
                mulu    #30,D0
                adda.l  D0,A1
                move.l  snddisknum0-1(PC),D1
                move.l  #$FF5F5FFF,D2
                and.l   D2,D1
peddslo:        move.l  2(A0),D0
                and.l   D2,D0
                cmp.l   D1,D0
                bne.s   peddsno
                movea.l A0,A2
peddslp:        move.w  30(A0),(A0)+
                cmpa.l  A1,A0
                blo.s   peddslp
                subq.w  #1,presettotal
                subi.l  #30,maxplstoffset
                movea.l A2,A0
                bra.s   peddsn1
peddsno:        lea     30(A0),A0
peddsn1:        cmpa.l  A1,A0
                blo.s   peddslo
                move.w  #1,pedpos
                bsr     showpednumbers
                bsr     showpresetnames
                jmp     restoreptrcol

deldisktext:    DC.B "Delete ST-.. ?",0,0

                ENDC

                ENDPART
