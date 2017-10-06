
                jmp     main

over_buff       equ 700

*********** init routs ************
save_ints:
                move.b  $fffffa07.w,mfpa07
                move.b  $fffffa09.w,mfpa09
                move.b  $fffffa13.w,mfpa13
                move.b  $fffffa15.w,mfpa15
                move.b  $fffffa19.w,mfpa19
                move.b  $fffffa1f.w,mfpa1f
                move.b  $fffffa21.w,mfpa21
                move.b  $fffffa1b.w,mfpa1b
                move.l  $0120.w,oldhbl
                move.l  $0134,old134
                move.l  $70.w,oldvbl
                bclr    #3,$fffffa17.w
                rts
init_ints:
                move    #$2700,sr
                clr.b   $fffffa07.w
                clr.b   $fffffa09.w
                clr.b   $fffffa13.w
                clr.b   $fffffa15.w

                move.l  #samp1,$0134
                move.b  #31,$fffffa1f.w ;16     ;32
                move.b  #2,$fffffa19.w
                bset    #5,$fffffa07.w  ;09
                bset    #5,$fffffa13.w  ;15
                move.l  #vbi,$70.w
                move    #$2300,sr
                rts
ret_ints:
                move    #$2700,sr
                move.b  mfpa07(pc),$fffffa07.w
                move.b  mfpa09(pc),$fffffa09.w
                move.b  mfpa13(pc),$fffffa13.w
                move.b  mfpa15(pc),$fffffa15.w
                move.b  mfpa19(pc),$fffffa19.w
                move.b  mfpa1f(pc),$fffffa1f.w
                move.b  mfpa21(pc),$fffffa21.w
                move.b  mfpa1b(pc),$fffffa1b.w
                move.l  old134(pc),$0134
                move.l  oldvbl(pc),$70.w
                move.l  oldhbl(pc),$0120.w
                move    #$2300,sr
                rts



mfpa07:         dc.b 0
mfpa09:         dc.b 0
mfpa13:         dc.b 0
mfpa15:         dc.b 0
mfpa19:         dc.b 0
mfpa1f:         dc.b 0
mfpa21:         dc.b 0
mfpa1b:         dc.b 0
oldhbl:         dc.l 0
old134:         dc.l 0
oldvbl:         dc.l 0

init_dig:
                moveq   #0,d0
                move.l  musaxx+8,d0
                mulu    #64*8,d0
                add.l   #$0110,d0
                add.l   #musaxx,d0
                move.l  d0,start_buff_add
                add.l   #4,d0
                move.l  d0,samtab_pet
                add.l   #64,d0
                move.l  d0,samp_pet_buff_pet
                lea     emptysamp(pc),a6
                lea     emptysamp(pc),a5
                lea     emptysamp(pc),a4
                lea     emptysamp(pc),a3
                lea     speedtabs(pc),a2

                move.b  musaxx+$0e,currpatt
                jsr     init_digishit
                rts


*********** main routs ************
start_buff_add:
                dc.l 0
samp_pet_buff_pet:
                dc.l 0
samtab_pet:
                dc.l 0
polle:
                dc.w 0
minipek:
                dc.w 0
currposs:
                dc.w 0
currpatt:
                dc.w 0
curr_tunes:
                dc.w 0
                dc.w 0
                dc.w 0
                dc.w 0
play_musaxx:
                addq.b  #1,polle
                move.b  musaxx+12,d0
                subq.b  #1,d0
                and.b   #$0f,d0
                eori.b  #$0f,d0
                cmp.b   polle(pc),d0
                bne.s   no_uppdate

                clr.b   polle
                addq.b  #1,minipek
                move.b  minipek(pc),d0
                and.b   #%111111,d0
                move.b  d0,minipek
                addq.b  #3,d0
                and.b   #%111111,d0
                beq.s   next_patt

                jsr     play_line

no_uppdate:
                rts
next_patt:
                jsr     ms_pos

                move.b  currposs(pc),d0
                cmp.b   musaxx+$8e,d0
                blo.s   forbi_pos

                move.w  #1,loopch1
                move.w  #1,loopch2
                move.w  #1,loopch3
                move.w  #1,loopch4
                lea     emptysamp(pc),a3
                move.l  #emptysamp,endchan1
                lea     emptysamp(pc),a4
                move.l  #emptysamp,endchan2
                lea     emptysamp(pc),a5
                move.l  #emptysamp,endchan3
                lea     emptysamp(pc),a6
                move.l  #emptysamp,endchan4

                move.b  #-1,currposs
                jsr     ms_pos
forbi_pos:
                jsr     play_line
                rts

play_line:
                moveq   #0,d0
                moveq   #0,d1
                move.b  minipek(pc),d3
                addq.b  #3,d3
                and.b   #%111111,d3
                lea     musaxx+$0110,a0
                move.b  currpatt(pc),d0
                mulu    #8*64,d0
                move.b  d3,d1
                mulu    #8,d1
                add.l   d1,d0
                adda.l  d0,a0
                lea     curr_tunes(pc),a1

                move.w  (a0)+,(a1)+
                move.w  (a0)+,(a1)+
                move.w  (a0)+,(a1)+
                move.w  (a0)+,(a1)+
                jsr     start_digi
                rts
ms_pos:
                move.b  currposs(pc),d1
                addq.b  #1,d1
                and.b   #%1111111,d1
                move.b  d1,currposs
                moveq   #0,d0
                move.b  currposs(pc),d0
                lea     musaxx+$0e,a0
                adda.l  d0,a0
                move.b  (a0),d1
                move.b  d1,currpatt
                rts

init_digishit:
;                bsr     conv_imp
                bsr     makespeedtabs
                bsr     intsamp

                move.b  #$3d,minipek
                clr.b   polle

                move.w  #1,loopch1
                move.w  #1,loopch2
                move.w  #1,loopch3
                move.w  #1,loopch4
                lea     emptysamp(pc),a3
                move.l  #emptysamp,endchan1
                lea     emptysamp(pc),a4
                move.l  #emptysamp,endchan2
                lea     emptysamp(pc),a5
                move.l  #emptysamp,endchan3
                lea     emptysamp(pc),a6
                move.l  #emptysamp,endchan4
                jsr     play_line(pc)
                rts

start_digi:
                move    #$2700,sr
;       move.w  #$070,$ff8240
                lea     curr_tunes(pc),a0
;-------------- channel 1
                moveq   #0,d0
                moveq   #0,d1
                move.b  (a0)+,d0
                move.b  (a0)+,d1
                tst.b   d0
                beq     forbdv3
                lea     convtab(pc),a1
                move.b  0(a1,d0.w),d0
                add.w   d0,d0
                add.w   d0,d0
                lea     speedadds(pc),a1
                move.l  0(a1,d0.w),chan1bepos
                move.w  d1,d2
                and.w   #-16,d2
                lsr.w   #1,d2
                movea.l samp_pet_buff_pet(pc),a1
                movea.l 0(a1,d2.w),a3
                adda.l  start_buff_add,a3
                move.l  4(a1,d2.w),endchan1
                move.l  a3,d0
                add.l   d0,endchan1
                subi.l  #over_buff,endchan1

                moveq   #0,d0
                movea.l samtab_pet(pc),a1
                lsr.w   #1,d2
                move.w  2(a1,d2.w),d0
                cmp.w   #0,d0
                beq     no_loop
                move.l  endchan1(pc),start_end
                move.l  endchan1(pc),end_end
                sub.l   d0,start_end
                clr.w   loopch1
                bra     forbdv3
no_loop:
                move.w  #1,loopch1
                move.l  #emptysamp,start_end
                move.l  #emptysamp,end_end
forbdv3:
                and.w   #15,d1
                move.w  d1,chan1special
;-------------- channel 2
                moveq   #0,d0
                moveq   #0,d1
                move.b  (a0)+,d0
                move.b  (a0)+,d1
                tst.b   d0
                beq     forbdv4
                lea     convtab(pc),a1
                move.b  0(a1,d0.w),d0
                add.w   d0,d0
                add.w   d0,d0
                lea     speedadds(pc),a1
                move.l  0(a1,d0.w),chan2bepos
                move.w  d1,d2
                and.w   #-16,d2
                lsr.w   #1,d2
                movea.l samp_pet_buff_pet(pc),a1
                movea.l 0(a1,d2.w),a4
                adda.l  start_buff_add,a4
                move.l  4(a1,d2.w),endchan2
                move.l  a4,d0
                add.l   d0,endchan2
                subi.l  #over_buff,endchan2

                moveq   #0,d0
                movea.l samtab_pet(pc),a1
                lsr.w   #1,d2
                move.w  2(a1,d2.w),d0
                cmp.w   #0,d0
                beq     no_loop2
                move.l  endchan2(pc),start_end2
                move.l  endchan2(pc),end_end2
                sub.l   d0,start_end2
                clr.w   loopch2
                bra     forbdv4
no_loop2:
                move.w  #1,loopch2
                move.l  #emptysamp,start_end2
                move.l  #emptysamp,end_end2
forbdv4:
                and.w   #15,d1
                move.w  d1,chan2special
;-------------- channel 3
                moveq   #0,d0
                moveq   #0,d1
                move.b  (a0)+,d0
                move.b  (a0)+,d1
                tst.b   d0
                beq     forbdv5
                lea     convtab(pc),a1
                move.b  0(a1,d0.w),d0
                add.w   d0,d0
                add.w   d0,d0
                lea     speedadds(pc),a1
                move.l  0(a1,d0.w),chan3bepos
                move.w  d1,d2
                and.w   #-16,d2
                lsr.w   #1,d2
                movea.l samp_pet_buff_pet(pc),a1
                movea.l 0(a1,d2.w),a5
                adda.l  start_buff_add,a5
                move.l  4(a1,d2.w),endchan3
                move.l  a5,d0
                add.l   d0,endchan3
                subi.l  #over_buff,endchan3

                moveq   #0,d0
                movea.l samtab_pet(pc),a1
                lsr.w   #1,d2
                move.w  2(a1,d2.w),d0
                cmp.w   #0,d0
                beq     no_loop3
                move.l  endchan3(pc),start_end3
                move.l  endchan3(pc),end_end3
                sub.l   d0,start_end3
                clr.w   loopch3
                bra     forbdv5
no_loop3:
                move.w  #1,loopch3
                move.l  #emptysamp,start_end3
                move.l  #emptysamp,end_end3
forbdv5:
                and.w   #15,d1
                move.w  d1,chan3special
;----------- channel 4 - drum-voice
                moveq   #0,d0
                moveq   #0,d1
                move.b  (a0)+,d0
                move.b  (a0)+,d1
                tst.b   d0
                beq     forbdv6
                lea     convtab(pc),a1
                move.b  0(a1,d0.w),d0
                add.w   d0,d0
                add.w   d0,d0
                lea     speedadds(pc),a1
                move.l  0(a1,d0.w),chan4bepos
                move.w  d1,d2
                and.w   #-16,d2
                lsr.w   #1,d2
                movea.l samp_pet_buff_pet(pc),a1
                movea.l 0(a1,d2.w),a6
                adda.l  start_buff_add,a6
                move.l  4(a1,d2.w),endchan4
                move.l  a6,d0
                add.l   d0,endchan4
                subi.l  #over_buff,endchan4

                moveq   #0,d0
                movea.l samtab_pet(pc),a1
                lsr.w   #1,d2
                move.w  2(a1,d2.w),d0
                cmp.w   #0,d0
                beq     no_loop4
                move.l  endchan4(pc),start_end4
                move.l  endchan4(pc),end_end4
                sub.l   d0,start_end4
                clr.w   loopch4
                bra     forbdv6
no_loop4:
                move.w  #1,loopch4
                move.l  #emptysamp,start_end4
                move.l  #emptysamp,end_end4
forbdv6:
                and.w   #15,d1
                move.w  d1,chan4special

                move.l  chan2bepos(pc),d0
                sub.l   chan1bepos(pc),d0
                move.l  chan3bepos(pc),d1
                sub.l   chan1bepos(pc),d1
                move.l  chan4bepos(pc),d2
                sub.l   chan1bepos(pc),d2

                movea.l chann1(pc),a0
                move.w  d0,2(a0)
                movea.l chann2(pc),a0
                move.w  d1,2(a0)
                movea.l chann3(pc),a0
                move.w  d2,2(a0)

                move.l  chan1bepos(pc),d0
                cmp.l   oldchan1bepos(pc),d0
                beq.s   forbdv19
                move.l  d0,oldchan1bepos
                movea.l d0,a2
forbdv19:
                add.l   #600,d0
                move.l  d0,endspeedchan1
                move    #$2300,sr
                rts
forbdv:                                 ********

                movea.l $0134,a0
                tst.w   chan1special
                beq.s   frrb2
                cmpi.w  #1,chan1special
                bne     frrb2
                move.w  #$0700,$ffff8240.w
                move.l  #20,d0
                sub.l   d0,chan1bepos
                sub.l   d0,endspeedchan1
                movea.l chan1bepos(pc),a2
                movea.l chann1(pc),a0
                add.w   d0,2(a0)
                movea.l chann2(pc),a0
                add.w   d0,2(a0)
                movea.l chann3(pc),a0
                add.w   d0,2(a0)
frrb2:
                cmpa.l  endspeedchan1(pc),a2
                blt.s   forbdv11
                movea.l chan1bepos(pc),a2
forbdv11:

                cmpa.l  endchan1(pc),a3
                blt.s   forbdv12
                cmpi.w  #1,loopch1
                beq     noch1
                suba.l  endchan1,a3
                adda.l  start_end,a3
                move.l  end_end(pc),endchan1
                bra.s   forbdv12
noch1:
                lea     emptysamp(pc),a3
                move.l  #emptysamp,endchan1
forbdv12:
                cmpa.l  endchan2(pc),a4
                blt.s   forbdv13
                cmpi.w  #1,loopch2
                beq     noch2
                suba.l  endchan2,a4
                adda.l  start_end2,a4
                move.l  end_end2(pc),endchan2
                bra.s   forbdv13
noch2:
                lea     emptysamp(pc),a4
                move.l  #emptysamp,endchan2
forbdv13:
                cmpa.l  endchan3(pc),a5
                blt.s   forbdv14
                cmpi.w  #1,loopch3
                beq     noch3
                suba.l  endchan3,a5
                adda.l  start_end3,a5
                move.l  end_end3(pc),endchan3
                bra.s   forbdv14
noch3:
                lea     emptysamp(pc),a5
                move.l  #emptysamp,endchan3
forbdv14:
                cmpa.l  endchan4(pc),a6
                blt.s   forbdv15
                cmpi.w  #1,loopch4
                beq     noch4
                suba.l  endchan4,a6
                adda.l  start_end4,a6
                move.l  end_end4(pc),endchan4
                bra.s   forbdv15
noch4:
                lea     emptysamp(pc),a6
                move.l  #emptysamp,endchan4
forbdv15:
                rts
chann1:
                dc.l vec11
chann2:
                dc.l vec12
chann3:
                dc.l vec13
start_end:
                dc.l emptysamp
start_end2:
                dc.l emptysamp
start_end3:
                dc.l emptysamp
start_end4:
                dc.l emptysamp
end_end:
                dc.l emptysamp
end_end2:
                dc.l emptysamp
end_end3:
                dc.l emptysamp
end_end4:
                dc.l emptysamp
loopch1:
                dc.w 1
loopch2:
                dc.w 1
loopch3:
                dc.w 1
loopch4:
                dc.w 1

convtab:
                dc.b 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                dc.b 0,1,2,3,4,5,6,7,8,9,10,11,0,0,0,0
                dc.b 12,13,14,15,16,17,18,19,20,21,22,23,0,0,0,0
                dc.b 24,25,26,27,28,29,30,31,32,33,34,35,0,0,0,0
                even

chan1bepos:     dc.l speedtabs
oldchan1bepos:  dc.l 0
chan2bepos:     dc.l speedtabs
chan3bepos:     dc.l speedtabs
chan4bepos:     dc.l speedtabs
endspeedchan1:  dc.l speedtabs
chan1special:   dc.w 0
chan2special:   dc.w 0
chan3special:   dc.w 0
chan4special:   dc.w 0
endchan1:       dc.l emptysamp
endchan2:       dc.l emptysamp
endchan3:       dc.l emptysamp
endchan4:       dc.l emptysamp
speedadds:      ds.l 37
speedtabs:      ds.w 400*37
emptysamp:      dcb.b 1000,128

makespeedtabs:
                move.w  #36,d0
                lea     midspeeddata-12*4(pc),a0
                lea     speedtabs(pc),a1
                lea     speedadds(pc),a2
omsp:           move.l  (a0)+,d1
                move.l  a1,(a2)+
                moveq   #0,d2
                moveq   #0,d3
                moveq   #0,d4
                move.w  #399,d7
omsp2:
                add.l   d1,d2
                move.l  d2,d3
                lsr.l   #8,d3
                lsr.l   #8,d3           ;7 for 15khz samples and 7.5 rout!
                sub.w   d3,d4
                neg.w   d4
                move.w  d4,(a1)+
                move.w  d3,d4
                dbra    d7,omsp2
                dbra    d0,omsp
                rts


speeddata:
                dc.l 8192,8679,9195,9741,10321,10935
                dc.l 11585,12274,13003,13777,14596,15464
                dc.l 16384,17358,18390,19483,20642,21870
                dc.l 23170,24548,26007,27554,29192,30928
                dc.l 32768,34716,36780,38967,41285,43740
                dc.l 46340,49096,52015,55108,58385,61857
midspeeddata:
                dc.l 65536,69432,73561,77935,82570,87480
                dc.l 92681,98193,104031,110217,116771,123715
                dc.l 131072,138865,147123,155871,165140,174960
                dc.l 185363,196386,208063,220435,233543,247430
                dc.l 262144,277731,294246,311743,330280,349920
                dc.l 370727,392772,416127,440871,467087,494861
                dc.l 524288


intsamp:
                move    #$2700,sr
                moveq   #10,d0
omis:
                move.b  d0,$ffff8800.w
                clr.b   $ffff8802.w
                dbra    d0,omis
                move.b  #7,$ffff8800
                move.b  #%11111111,$ffff8802
                move    #$2300,sr
                rts


conv_imp:
                move.w  #255,d7
                lea     imptab+4(pc),a0
.loop:          move.b  (a0),d0
                move.b  1(a0),d1
                move.b  d0,(a0)+
                move.b  d0,(a0)+
                move.b  d1,(a0)+
                move.b  d1,(a0)+
                lea     4(a0),a0
                dbra    d7,.loop
;------ megafix imptab!!!!!!!!!!!!
                lea     imptab(pc),a0
                lea     384*8(a0),a1    ;dont ask, believe!
                move.w  #255,d0
.loop2:         move.l  (a0)+,(a1)+
                move.l  (a0)+,(a1)+
                dbra    d0,.loop2
;--- fill top of imp
                lea     imptab(pc),a0
                move.w  #384-1,d0
                move.l  (a0),d1
                move.l  4(a0),d2
.loop3:         move.l  d1,(a0)+
                move.l  d2,(a0)+
                dbra    d0,.loop3
;---- fill bottom
                move.w  #1024-384-256-1,d0
                move.l  -8(a1),d1
                move.l  -4(a1),d2
.loop4:         move.l  d1,(a1)+
                move.l  d2,(a1)+
                dbra    d0,.loop4
                rts



samp1:
                move    a1,usp          ;1
                moveq   #0,d7           ;1
                moveq   #0,d6           ;1
                move.b  (a6)+,d7        ;2
                move.b  (a5),d6         ;2
                add.w   d6,d7           ;1
                move.b  (a4),d6         ;2
                add.w   d6,d7           ;1
                move.b  (a3),d6         ;2
                add.w   d6,d7           ;1
                asl.w   #3,d7           ;3
                lea     $ffff8800.w,a1  ;2
                move.l  imptab(pc,d7.w),d6 ;4
                movep.l d6,0(a1)        ;7
                move.l  imptab+4(pc,d7.w),(a1) ;6
vec11:          adda.w  0(a2),a4        ;4
vec12:          adda.w  0(a2),a5        ;4
                adda.w  (a2)+,a3        ;3
                move    usp,a1          ;1
* 48 nop
                rte
vec13:
                dc.l 0
                dc.l 0
imptab:
                path 'A:\SEC_PROJ.ECT\DIGIPART\'
                ibytes 'SNDTAB.TAB'
                ds.w 4*256*3

* digi-rout end ***********************************

init_resse:
                lea     $fffa01,a0
                lea     save_mfp(pc),a1
                moveq   #15,d0
save_mfp_loop:
                move.b  (a0),(a1)+
                addq.l  #2,a0
                dbra    d0,save_mfp_loop

                lea     $28,a0
                lea     save_tex(pc),a1
                move.l  #$0200-1,d0
save_tex_loop:
                move.l  (a0)+,(a1)+
                dbra    d0,save_tex_loop

                move.l  #retvars,$042a
                move.l  #$31415926,$0426
                rts
retvars:
                lea     nullstk(pc),sp

                move.w  #$0700,$ff8240

                lea     $28,a0
                lea     save_tex(pc),a1
                move.l  #$0200-1,d0
ret_tex_loop:
                move.l  (a1)+,(a0)+
                dbra    d0,ret_tex_loop

                move.w  #$30,$ff8240

                lea     $fffa01,a0
                lea     save_mfp(pc),a1
                moveq   #15,d0
ret_mfp:
                move.b  (a1)+,(a0)
                addq.l  #2,a0
                dbra    d0,ret_mfp
                move.w  #$0770,$ff8240

                move.l  #retvars,$042a
                move.l  #$31415926,$0426

                move.b  #2,$ff820a

                move.w  #$0707,$ff8240

                move.l  #$0707ffff,$ffff8800.w

                move.w  #$0777,$ff8240

                dc.w $a000

                move.w  #$0444,$ff8240

                move.w  #1,d0
                andi.w  #3,d0
                lea     skumtab(pc),a1
                add.w   d0,d0
                add.w   d0,d0
                move.l  0(a1,d0.w),(a0)
                move.b  #3,$fffffc04.w
                move.b  #$95,$fffffc04.w
                move.b  #3,$fffffc00.w
                move.b  #$96,$fffffc00.w
                move.w  #$c8,d0
tima:           nop
                dbra    d0,tima

                move.w  #$00,$ff8240
                move.w  #$0666,$ff8242
                move.w  #$0666,$ff8244
                move.w  #$0666,$ff8246
                move.w  #$0666,$ff8248

                move    #$2300,sr

                clr.w   (sp)
                trap    #1
save_stk:
                dc.l 0

skumtab:
                dc.w $04,$a0
                dc.w $02,$a0
                dc.w $01,$50
                dc.w $01,$50
                dc.w $8001,$1214

save_mfp:
                ds.b 24
                even
resolution:
                dc.w 0
phys_base:
                dc.l 0
log_base:
                dc.l 0
save_tex:
                ds.l $0300
                ds.l 100
nullstk:

main:
                pea     0
                move.w  #$20,-(sp)
                trap    #1
                addq.l  #6,sp

                move.b  #2,$ff820a
                bclr    #0,$0484

                move.w  #0,-(sp)
                pea     $0f0000
                pea     $0f0000
                move.w  #5,-(sp)
                trap    #14
                adda.l  #12,sp
                move.w  #0,-(sp)
                pea     $0f8000
                pea     $0f8000
                move.w  #5,-(sp)
                trap    #14
                adda.l  #12,sp

                jsr     init_resse

                pea     text
                move.w  #9,-(sp)
                trap    #1
                addq.l  #6,sp

                jsr     init_dig
                jsr     save_ints
                jsr     init_ints


                move.w  #0,wfnc
demo_loop:
                cmpi.w  #1,wfnc
                bne     demo_loop
                move.w  #0,wfnc

                move.w  #2000,d0
om:             dbra    d0,om

                jsr     play_musaxx
                move.w  #0,$ffff8240.w
                cmpi.b  #185,$fffffc02.w
                bne     demo_loop
                jsr     ret_ints
                move.b  #2,$ff820a
                move.w  #0,$ff8240
                move.w  #$0777,$ff8242
                move.w  #$0777,$ff8244
                move.w  #$0777,$ff8246
                move.w  #$0777,$ff8248
                clr.w   -(sp)
                trap    #1

vbi:
                movem.l d0-a1,-(sp)
                move.w  #1,wfnc
                jsr     forbdv
                movem.l (sp)+,d0-a1
                rte
wfnc:
                dc.w 0
text:
                dc.b 27,'E',"NOW PLAYING....",0
                even
musaxx:
                ibytes 'ROCK.MOD'
                even
                end
