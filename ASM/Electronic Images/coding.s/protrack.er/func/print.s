; Print Song

printsong:
                bra     shownotimpl

                lea     printsongtext,A0
                bsr     areyousure
                bne     return1
                bsr     storeptrcol
                move.l  #printpath,D1
                move.l  #1006,D2
                movea.l dosbase,A6
                jsr     lvoopen         ;;
                move.l  D0,filehandle
                beq     cantopenfile
                bsr     setdiskptrcol
                lea     printingsongtext,A0
                bsr     showstatustext
                move.l  filehandle,D1
                move.l  #songdumptext,D2
                moveq   #68,D3
                movea.l dosbase,A6
                jsr     lvowrite        ;;
                move.l  filehandle,D1
                move.l  songdataptr,D2
                moveq   #20,D3
                jsr     lvowrite        ;;
                bsr     printcrlf
                bsr     printcrlf
                bsr     printsong2
                bsr     printcrlf
                bsr     printsong4
                bsr     printformfeed
                movea.l songdataptr,A0
                moveq   #0,D0
                move.b  sd_numofpatt(A0),D0
                lea     sd_pattpos(A0),A0
                moveq   #0,D7
ps_loop:        cmp.b   0(A0,D0.w),D7
                bgt.s   ps_skip
                move.b  0(A0,D0.w),D7
ps_skip:        subq.w  #1,D0
                bpl.s   ps_loop
                moveq   #0,D1
ps_loop2:
                movem.l D1-A6,-(SP)
                bsr     printpattern
                movem.l (SP)+,D1-A6
                tst.l   D0
                bne.s   ps_skip2
                movem.l D1/D7,-(SP)
                bsr     printformfeed
                movem.l (SP)+,D1/D7
                addq.w  #1,D1
                cmp.w   D7,D1
                blo.s   ps_loop2
ps_skip2:
                movea.l dosbase,A6
                move.l  filehandle,D1
                jsr     lvoclose        ;;
                bsr     showallright
                bra     restoreptrcol

printsong2:
                moveq   #1,D7
ps2_2:          move.l  D7,D0
                lsr.b   #4,D0
                cmp.b   #9,D0
                bls.s   spujk
                addq.b  #7,D0
spujk:          add.b   #'0',D0
                move.b  D0,pattxtext1
                move.b  D7,D0
                and.b   #$0F,D0
                cmp.b   #9,D0
                bls.s   spujk2
                addq.b  #7,D0
spujk2:         add.b   #'0',D0
                move.b  D0,pattxtext2

                movea.l songdataptr,A0
                move.w  D7,D0
                mulu    #30,D0
                lea     -10(A0,D0.w),A0
                lea     pptext,A1
                moveq   #21,D0
ps2_loop:
                move.b  #' ',(A1)+
                dbra    D0,ps2_loop
                lea     pptext,A1

                move.l  A0,savit
ps2_loop2:
                move.b  (A0)+,D0
                beq     printsong3
                move.b  D0,(A1)+
                bra.s   ps2_loop2

savit:          DC.L 0

printsong3:
                move.l  D7,-(SP)        ; pattnum
                movea.l savit(PC),A0
                move.w  22(A0),D0
                add.w   D0,D0
                lea     prafs+2+4,A0
                bsr     inttohexascii
                movea.l savit(PC),A0
                move.w  26(A0),D0
                add.w   D0,D0
                lea     prafs+8+4,A0
                bsr     inttohexascii
                movea.l savit(PC),A0
                move.w  28(A0),D0
                add.w   D0,D0
                lea     prafs+14+4,A0
                bsr     inttohexascii
                movea.l dosbase,A6
                move.l  filehandle,D1
                move.l  #ptottext,D2
                moveq   #52,D3
                jsr     lvowrite        ;;
                move.l  (SP)+,D7
                addq.w  #1,D7
                cmp.w   #$20,D7
                bne     ps2_2
                rts

printsong4:
                movea.l songdataptr,A0
                moveq   #0,D7
                move.b  sd_numofpatt(A0),D7
                lea     sd_pattpos(A0),A0
                moveq   #0,D5
ps4_loop1:
                moveq   #0,D6
ps4_loop2:
                moveq   #0,D0
                move.b  (A0)+,D0
                move.w  D0,D1
                lsr.w   #4,D1
                add.b   #$30,D1
                cmp.b   #$39,D1
                bls.s   ps4_skip
                addq.b  #7,D1
ps4_skip:
                and.b   #15,D0
                add.b   #$30,D0
                cmp.b   #$39,D0
                bls.s   ps4_skip2
                addq.b  #7,D0
ps4_skip2:
                lea     pntext,A1
                move.b  D1,(A1)+
                move.b  D0,(A1)
                movem.l D5-A0,-(SP)
                movea.l dosbase,A6
                move.l  filehandle,D1
                move.l  #pntext,D2
                moveq   #4,D3
                jsr     lvowrite        ;;
                movem.l (SP)+,D5-A0
                addq.w  #1,D5
                cmp.w   D5,D7
                beq     return1
                addq.w  #1,D6
                cmp.w   #$10,D6
                bne.s   ps4_loop2
                movem.l D5-A0,-(SP)
                bsr.s   printcrlf
                movem.l (SP)+,D5-A0
                bra.s   ps4_loop1

printcrlf:
                movea.l dosbase,A6
                move.l  filehandle,D1
                move.l  #crlf_text,D2
                moveq   #2,D3
                jsr     lvowrite        ;;
                rts

printformfeed:
                movea.l dosbase,A6
                move.l  filehandle,D1
                move.l  #ff_text,D2
                moveq   #1,D3
                jsr     lvowrite        ;;
                rts

printpattern:
                move.l  D1,D6           ; D1=pattern number
                divu    #10,D6
                add.b   #'0',D6
                move.b  D6,pattnumtext1
                swap    D6
                add.b   #'0',D6
                move.b  D6,pattnumtext2
                movem.l D0-A6,-(SP)
                move.l  filehandle,D1
                move.l  #patternnumtext,D2
                moveq   #18,D3
                movea.l dosbase,A6
                jsr     lvowrite        ;;
                movem.l (SP)+,D0-A6

                move.l  D1,D6
                movea.l songdataptr,A6
                lea     sd_patterndata(A6),A6
                lsl.l   #8,D6
                lsl.l   #2,D6
                adda.l  D6,A6
                clr.l   ppattpos
                moveq   #0,D6
pp_posloop:
                moveq   #0,D7
                move.w  #2,textlength
                move.l  ppattpos,D1
                lea     pattpostext,A5
                divu    #10,D1
                add.b   #'0',D1
                move.b  D1,(A5)+
                clr.w   D1
                swap    D1
                add.b   #'0',D1
                move.b  D1,(A5)+
                addq.l  #5,A5
pp_noteloop:
                moveq   #0,D0
                moveq   #0,D1
                move.w  #3,textlength
                move.w  (A6),D1
                and.w   #$0FFF,D1
                lea     periodtable,A0
pp_findloop:
                cmp.w   0(A0,D0.l),D1
                beq     printnote
                addq.l  #2,D0
                bra.s   pp_findloop

printnote:
                add.l   D0,D0
                add.l   notenamesptr,D0
                movea.l D0,A0
                move.l  (A0),(A5)+
                cmpi.b  #'¡',-3(A5)
                bne.s   prnoxyz
                move.b  #'b',-3(A5)
prnoxyz:        addq.l  #1,A5
                moveq   #0,D0
                move.w  (A6),D0
                and.w   #$F000,D0
                lsr.w   #8,D0
                add.l   D0,D0
                lea     fasthextable,A0
                adda.l  D0,A0
                move.b  (A0),(A5)+
                moveq   #0,D0
                move.b  2(A6),D0
                add.l   D0,D0
                lea     fasthextable,A0
                adda.l  D0,A0
                move.w  (A0),(A5)+
                moveq   #0,D0
                move.b  3(A6),D0
                add.l   D0,D0
                lea     fasthextable,A0
                adda.l  D0,A0
                move.w  (A0),(A5)+
                addq.l  #4,A5
                addq.l  #4,A6
                addq.l  #1,D7
                cmp.l   #4,D7
                bne     pp_noteloop
                addq.l  #1,ppattpos
                movem.l D0-A6,-(SP)
                movea.l dosbase,A6
                move.l  filehandle,D1
                move.l  #pntext2,D2
                moveq   #68,D3
                jsr     lvowrite        ;;
                bsr     printcrlf
                movem.l (SP)+,D0-A6
;                btst    #2,$DFF016
;                beq.s   negativereturn

                addq.l  #1,D6
                cmp.l   #64,D6
                bne     pp_posloop
                moveq   #0,D0
                rts

negativereturn:
                moveq   #-1,D0
                rts

positivereturn:
                moveq   #0,D0
                rts
