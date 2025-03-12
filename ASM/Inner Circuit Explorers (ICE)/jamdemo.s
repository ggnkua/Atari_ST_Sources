********************************************************************
* " The Jam-Colors Demo "   by Techwave of Inner Circuit Explorers *
*               Finished in the beginning of January 1992          *
********************************************************************

                pea       $00
                move.w    #$20,-(sp)
                trap      #1
                addq.l    #6,sp

                move.w    #0,-(sp)
                move.l    #-1,-(sp)
                move.l    #-1,-(sp)
                move.w    #5,-(sp)
                trap      #14
                lea       12(sp),sp

                move.w    #2,$0484.w

                move.l    #$31415926,$0426.w
                move.l    #fuck_reset,$042a.w

                move.l    #screen,d0
                move.b    #0,d0
                add.l     #$0100,d0
                move.l    d0,screen

                move.b    $ffff8201.w,old_scrnhi
                move.b    $ffff8203.w,old_scrnlo
                lsr.w     #8,d0
                move.b    d0,$ffff8203.w
                swap      d0
                move.b    d0,$ffff8201.w


********************************************************************
;               x,y starscroller by Techwave!
;  4 planes... reality stars number for each plane!     320*200!

                movea.l   screen,a0
                move.l    a0,screen1
                adda.w    #32000,a0
                move.l    a0,screen2

                move.w    #0,$0468.w
vsync:          cmpi.w    #0,$0468.w
                beq.s     vsync

                lea       $ffff8240.w,a0

                move.w    #$00,(a0)+
                move.w    #$0222,(a0)+
                move.w    #$0444,(a0)+
                move.w    #$0444,(a0)+
                move.w    #$0666,(a0)+
                move.w    #$0666,(a0)+
                move.w    #$0666,(a0)+
                move.w    #$0666,(a0)+
                move.w    #$0fff,(a0)+
                move.w    #$0fff,(a0)+
                move.w    #$0fff,(a0)+
                move.w    #$0fff,(a0)+
                move.w    #$0fff,(a0)+
                move.w    #$0fff,(a0)+
                move.w    #$0fff,(a0)+
                move.w    #$0fff,(a0)+

                moveq     #0,d0
                movea.l   screen1,a0
                movea.l   a0,a1
                adda.l    #64000,a1
fill_zero:      move.w    d0,(a0)+
                cmpa.l    a0,a1
                bhi.s     fill_zero

                move.w    #4*64*2-1,d7
                lea       xycoords,a6
rnd_loop:       move.w    #17,-(sp)               ; random..24 bits
                trap      #14
                addq.l    #2,sp
;and.w        #$13f,d0                ; 319
                move.w    d0,(a6)+
                dbra      d7,rnd_loop


                move.l    $70.w,oldvbl
                move.l    #vbl_stars,$70.w

star_wait:      cmpi.w    #50*8,stars_on
                bne.s     star_wait
                bra       back_stars
*-------------------------------------------------

vbl_stars:
                movem.l   d0-a6,-(sp)
                move.l    screen1,d0
                move.b    d0,$ffff8209.w
                lsr.w     #8,d0
                move.b    d0,$ffff8207.w
                swap      d0
                move.b    d0,$ffff8205.w
                move.l    screen1,d0
                move.l    screen2,d1
                move.l    d0,screen2
                move.l    d1,screen1

                addq.w    #1,stars_on

                bsr.s     clr_pixs
                bsr.s     do_pixs

                move.w    #0,stars_pek
                st        clr_flg
                movem.l   (sp)+,d0-a6
                rte
;-----------------------------------------------------  Subroutines
; Super-ultra fast x,y plot routine by Techwave.


clr_pixs:       tst.b     clr_flg
                bne.s     clr_it
                rts

clr_it:         lea       dest_addr,a0
                tst.b     clrarea_flg
                beq.s     area1
area2:          lea       4*4*64(a0),a0
area1:
                moveq     #0,d0
                move.w    #64*4-1,d7
clr_loop:
                movea.l   (a0)+,a1
                move.w    d0,(a1)
                dbra      d7,clr_loop
                rts

;-----------------------------------------------------

do_pixs:        lea       dest_addr,a4
                not.b     clrarea_flg
                bne.s     area1_make
area2_make:     lea       4*4*64(a4),a4
area1_make:

                move.l    screen1,d3
                moveq     #15,d4                  ; for cmp ...4 cycles
                move.w    #$8000,d5               ; for move ...4 cycles
                lea       xadd_tab,a0
                lea       yadd_tab,a1
                lea       xycoords,a3
                lea       starvar_x,a5
                lea       starvar_y,a6

                move.w    #4-1,d7
lines:          lea       stars(pc),a2
                adda.w    stars_pek(pc),a2
                addq.w    #2,stars_pek

                move.w    (a2),d6
line_loop:
                moveq     #0,d0
                moveq     #0,d1

                move.w    (a5),d0                 ; starvar x
                add.w     d0,(a3)
                move.w    (a3)+,d0
                cmp.w     #319,d0
                bls.s     y_coord
                and.w     #%111111111,d0          ;511
                cmp.w     #319,d0
                bls.s     y_coord
                sub.w     #319,d0
                move.w    d0,-(a3)
                addq.w    #2,a3

y_coord:
;                move.w    (a6),d1                 ; starvar y
;                add.w     d1,(a3)
                addq.w    #2,(a3)
                move.w    (a3)+,d1
                cmp.w     #197,d1
                bls.s     xyput
                and.w     #$ff,d1
                cmp.w     #197,d1
                bls.s     xyput
                sub.w     #197,d1
                move.w    d1,-(a3)
                addq.w    #2,a3

; ----------------------------------------------------
; converts x & y values to scrmem and plot on position!
; using:  d0-d5 / a0-a2
; d0 = xvalue   d1 = yvalue   d3 = outstars   d4 = #15 (.w)   d5 = $8000.w
; a0 = xadd_tab   a1 = yadd_tab

xyput:          movea.l   d3,a2
                move.w    d5,d2                   ; pixel (to rotate)

; y convert algorithm

                add.w     d1,d1                   ; *2
                adda.w    0(a1,d1.w),a2           ; add to screen

; x convert algorithm

                add.w     d0,d0                   ; *4
                add.w     d0,d0
                adda.w    0(a0,d0.w),a2

                move.w    2(a0,d0.w),d0
                lsr.w     d0,d2
                or.w      d2,(a2)                 ; pixel out

; ------------------------

end_plot:       move.l    a2,(a4)+
                dbra      d6,line_loop
                addq.l    #2,d3

                cmpi.w    #4,(a5)
                bne.s     dec_x
                move.w    #1,(a5)
                bra.s     chk_y
dec_x:          addq.w    #1,(a5)

chk_y:          cmpi.w    #8,(a6)
                bne.s     not_yet
                move.w    #2,(a6)
                dbra      d7,lines
                rts

not_yet:        addq.w    #2,(a6)
                dbra      d7,lines
                rts

;-------------------------------------  restore

back_stars:     move.l    oldvbl,$70.w
;                move.w    #1,-(sp)
;                move.l    #-1,-(sp)
;                move.l    #-1,-(sp)
;                move.w    #5,-(sp)
;                trap      #14
;                lea       12(sp),sp
;                clr.w     -(sp)
;                trap      #1

                move.b    #0,clr_flg
                bra       go_jam_jam

fuck_reset:
                moveq     #0,d0
                lea       $ffff8240.w,a0
              rept 16
                move.w    d0,(a0)+
              endr
fuck:           bra.s     fuck


;-------------------------------------  variables and saved data

; x-add with rotation!
xadd_tab:
              dc.w 0,0,0,1,0,2,0,3,0,4,0,5,0,6,0,7,0,8,0,$09,0,$0a,0,$0b
              dc.w 0,$0c,0,$0d,0,$0e,0,$0f,8,0,8,1,8,2,8,3,8,4,8,5,8,6,8,7
              dc.w 8,8,8,$09,8,$0a,8,$0b,8,$0c,8,$0d,8,$0e,8,$0f,$10,0,$10,1,$10,2,$10,3
              dc.w $10,4,$10,5,$10,6,$10,7,$10,8,$10,$09,$10,$0a,$10,$0b
              dc.w $10,$0c,$10,$0d,$10,$0e,$10,$0f,$18,0,$18,1,$18,2,$18,3
              dc.w $18,4,$18,5,$18,6,$18,7,$18,8,$18,$09,$18,$0a,$18,$0b
              dc.w $18,$0c,$18,$0d,$18,$0e,$18,$0f,$20,0,$20,1,$20,2,$20,3
              dc.w $20,4,$20,5,$20,6,$20,7,$20,8,$20,$09,$20,$0a,$20,$0b
              dc.w $20,$0c,$20,$0d,$20,$0e,$20,$0f,$28,0,$28,1,$28,2,$28,3
              dc.w $28,4,$28,5,$28,6,$28,7,$28,8,$28,$09,$28,$0a,$28,$0b
              dc.w $28,$0c,$28,$0d,$28,$0e,$28,$0f,$30,0,$30,1,$30,2,$30,3
              dc.w $30,4,$30,5,$30,6,$30,7,$30,8,$30,$09,$30,$0a,$30,$0b
              dc.w $30,$0c,$30,$0d,$30,$0e,$30,$0f,$38,0,$38,1,$38,2,$38,3
              dc.w $38,4,$38,5,$38,6,$38,7,$38,8,$38,$09,$38,$0a,$38,$0b
              dc.w $38,$0c,$38,$0d,$38,$0e,$38,$0f,$40,0,$40,1,$40,2,$40,3
              dc.w $40,4,$40,5,$40,6,$40,7,$40,8,$40,$09,$40,$0a,$40,$0b
              dc.w $40,$0c,$40,$0d,$40,$0e,$40,$0f,$48,0,$48,1,$48,2,$48,3
              dc.w $48,4,$48,5,$48,6,$48,7,$48,8,$48,$09,$48,$0a,$48,$0b
              dc.w $48,$0c,$48,$0d,$48,$0e,$48,$0f,$50,0,$50,1,$50,2,$50,3
              dc.w $50,4,$50,5,$50,6,$50,7,$50,8,$50,$09,$50,$0a,$50,$0b
              dc.w $50,$0c,$50,$0d,$50,$0e,$50,$0f,$58,0,$58,1,$58,2,$58,3
              dc.w $58,4,$58,5,$58,6,$58,7,$58,8,$58,$09,$58,$0a,$58,$0b
              dc.w $58,$0c,$58,$0d,$58,$0e,$58,$0f,$60,0,$60,1,$60,2,$60,3
              dc.w $60,4,$60,5,$60,6,$60,7,$60,8,$60,$09,$60,$0a,$60,$0b
              dc.w $60,$0c,$60,$0d,$60,$0e,$60,$0f,$68,0,$68,1,$68,2,$68,3
              dc.w $68,4,$68,5,$68,6,$68,7,$68,8,$68,$09,$68,$0a,$68,$0b
              dc.w $68,$0c,$68,$0d,$68,$0e,$68,$0f,$70,0,$70,1,$70,2,$70,3
              dc.w $70,4,$70,5,$70,6,$70,7,$70,8,$70,$09,$70,$0a,$70,$0b
              dc.w $70,$0c,$70,$0d,$70,$0e,$70,$0f,$78,0,$78,1,$78,2,$78,3
              dc.w $78,4,$78,5,$78,6,$78,7,$78,8,$78,$09,$78,$0a,$78,$0b
              dc.w $78,$0c,$78,$0d,$78,$0e,$78,$0f,$80,0,$80,1,$80,2,$80,3
              dc.w $80,4,$80,5,$80,6,$80,7,$80,8,$80,$09,$80,$0a,$80,$0b
              dc.w $80,$0c,$80,$0d,$80,$0e,$80,$0f,$88,0,$88,1,$88,2,$88,3
              dc.w $88,4,$88,5,$88,6,$88,7,$88,8,$88,$09,$88,$0a,$88,$0b
              dc.w $88,$0c,$88,$0d,$88,$0e,$88,$0f,$90,0,$90,1,$90,2,$90,3
              dc.w $90,4,$90,5,$90,6,$90,7,$90,8,$90,$09,$90,$0a,$90,$0b
              dc.w $90,$0c,$90,$0d,$90,$0e,$90,$0f,$98,0,$98,1,$98,2,$98,3
              dc.w $98,4,$98,5,$98,6,$98,7,$98,8,$98,$09,$98,$0a,$98,$0b
              dc.w $98,$0c,$98,$0d,$98,$0e,$98,$0f,$a0,0,$a0,1,$a0,2,$a0,3
              dc.w $a0,4,$a0,5,$a0,6,$a0,7,$a0,8,$a0,$09,$a0,$0a,$a0,$0b
              dc.w $a0,$0c,$a0,$0d,$a0,$0e,$a0,$0f

yadd_tab:
              dc.w 0,160,320,480,640,800,960,1120,1280,1440,1600,1760
              dc.w 1920,2080,2240,2400,2560,2720,2880,3040,3200,3360
              dc.w 3520,3680,3840,4000,4160,4320,4480,4640,4800,4960
              dc.w 5120,5280,5440,5600,5760,5920,6080,6240,6400,6560
              dc.w 6720,6880,7040,7200,7360,7520,7680,7840,8000,8160
              dc.w 8320,8480,8640,8800,8960,9120,9280,9440,9600,9760
              dc.w 9920
              dc.w 10080,10240,10400,10560,10720,10880,11040,11200
              dc.w 11360,11520,11680,11840,12000,12160,12320,12480
              dc.w 12640,12800,12960,13120,13280,13440,13600,13760
              dc.w 13920,14080,14240,14400,14560,14720,14880,15040
              dc.w 15200,15360,15520,15680,15840,16000,16160,16320
              dc.w 16480,16640,16800,16960,17120,17280,17440,17600
              dc.w 17760,17920,18080,18240,18400,18560,18720,18880
              dc.w 19040,19200,19360,19520,19680,19840,20000,20160
              dc.w 20320,20480,20640,20800,20960,21120,21280,21440
              dc.w 21600,21760,21920,22080,22240,22400,22560,22720
              dc.w 22880,23040,23200,23360,23520,23680,23840,24000
              dc.w 24160,24320,24480,24640,24800,24960,25120,25280
              dc.w 25440,25600,25760,25920,26080,26240,26400,26560
              dc.w 26720,26880,27040,27200,27360,27520,27680,27840
              dc.w 28000,28160,28320,28480,28640,28800,28960,29120
              dc.w 29280,29440,29600,29760,29920,30080,30240,30400
              dc.w 30560,30720,30880,31040,31200,31360,31520,31680
              dc.w 31840

clr_flg:      dc.b 0
clrarea_flg:  dc.b 0
starvar_x:    dc.w 1
starvar_y:    dc.w 2
stars_on:     dc.w 0
              even
stars:        dc.w 128-1,80-1,32-1,16-1
stars_pek:    dc.w 0

screen1:      dc.l 0
screen2:      dc.l 0

dest_addr:    ds.l 4*64*2,$0f8000             ; 2*buffer pixs
xycoords:     ds.w 4*64

              ds.w 4*64

********************************************************************
********************************************************************
go_jam_jam:

                jsr       init_dma
                jsr       play2_dma

********************************************************************

start_again:
                moveq     #0,d0
                lea       $ffff8240.w,a0
              rept 16
                move.w    d0,(a0)+
              endr

                movea.l   screen,a0
                moveq     #0,d0
                move.w    #80*245-1,d7
clr_lp:         move.w    d0,(a0)+
                dbra      d7,clr_lp

                lea       ice_logo+34,a0
                movea.l   screen,a1

                move.w    #80*200-1,d7
logo_out:       move.w    (a0)+,(a1)+
                dbra      d7,logo_out


b_init:         move.b    #3,$ffff8a3b.w          ; op
                move.b    #%0,$ffff8a3d.w         ; no skew
                move.w    #$ffff,$ffff8a28.w      ; endmsk1
                move.w    #$ffff,$ffff8a2a.w      ; endmsk2
                move.w    #$ffff,$ffff8a2c.w      ; endmsk3
                move.w    #2,$ffff8a20.w          ; src x inc
                move.w    #2,$ffff8a22.w          ; src y inc
                move.w    #0,$ffff8a2e.w          ; des x inc
                move.w    #0,$ffff8a30.w          ; des y inc

                bsr       predo_plasma
                move.b    #%1000,option_flg

i_init:
                clr.b     $fffffa09.w

                move.l    $70,oldvbl
                move.l    #vbl,$70

*-------------------------------------------------

wait_vbl:       btst      #7,option_flg           ; chk vbl_done flg
                beq.s     wait_vbl

                lea       ice_logo+2,a0
                movem.l   (a0),d0-d7
                movem.l   d0-d7,$ffff8240.w


wait_col:       btst      #5,option_flg
                beq.s     wait_col

                lea       font_drag+4,a0
                movem.l   (a0),d0-d7
                movem.l   d0-d7,$ffff8240.w

********************************************************************

reset_chk:      tst.b     reset_flg
                beq.s     reset_chk

                move.l    oldvbl,$70

                sf        reset_flg

                move.b    #$ff,read_flg
                move.b    #0,rot_flg
                move.b    #0,work_flg1
                move.b    #0,work_flg2
                move.b    #$ff,place_flg
                move.b    #0,clr_flg

;                move.w    #0,saved_d1
;                move.w    #0,saved_a0
;                move.w    #0,saved_a1

                move.w    #0,y_lines
                move.w    #0,topclr_pek
                move.w    #160*199,downclr_pek
                move.w    #0,wait_clr

                move.w    #0,offset
                move.l    #0,char_scrnpos
                move.w    #0,char_pospek

                move.w    #0,text_pekdrag
                move.b    #0,timechar_out
                move.b    #0,option_flg
                move.b    #0,clr_plasmaflg
                move.w    #0,fnt_xsize

                move.w    #0,char_cols
                move.w    #0,sin_blkpek
                move.w    #0,halfand_colspek
                move.w    #0,halfand_colspek2
                move.w    #0,halfand_loopchk
                move.w    #0,colset_tabpek

                move.w    #0,text_pek

;                move.b    #0,vol_flg
;                move.b    #8,vol_pause
;                move.b    #0,go_fade_vol

                move.w    #0,sinus_plbuffpek

                move.w    #0,sinus_charpek
                move.w    #0,sinus_colbuffpek
                move.w    #0,sinus_plasmapek

                move.l    #0,clr_buffpek
                move.w    #0,col_buffpek

                lea       char_buff,a0

              rept 8
                move.w    #0,(a0)+
              endr

                bra       start_again

********************************************************************

predo_plasma:
                lea       plasma_tab,a2
                lea       col_buff,a1

                moveq     #7-1,d4
times:          lea       plasma,a0
                move.w    (a2)+,d2
                move.w    (a2)+,d3

                moveq     #16-1,d7
lines_plasma:   moveq     #3-1,d5
repeat_line:    moveq     #32-1,d6

line_plasma:    move.w    (a0)+,d0
                move.w    d0,d1
                lsl.w     d2,d1
                move.w    d1,(a1)
                move.w    d0,d1
                lsl.w     d3,d1
                move.w    d1,32*2(a1)
                addq.l    #2,a1
                dbra      d6,line_plasma
                lea       32*2(a1),a1
                suba.w    #2*32,a0
                dbra      d5,repeat_line
                lea       2*32(a0),a0
                dbra      d7,lines_plasma


                moveq     #16-1,d7
lines_copy:     moveq     #32-1,d6
line_copy:      move.w    -(a0),d0
                move.w    d0,d1
                lsl.w     d2,d1
                move.w    d1,(a1)
                move.w    d0,d1
                lsl.w     d3,d1
                move.w    d1,32*2(a1)
                addq.l    #2,a1
                dbra      d6,line_copy
                lea       32*2(a1),a1
                dbra      d7,lines_copy

                dbra      d4,times
                rts

********************************************************************
********************************************************************

vbl:            movem.l   d0-a6,-(sp)

                btst      #3,option_flg
                beq.s     no_termination

                move.w    #1399+19,d0
wait:           dbra      d0,wait

                nop
                nop
                nop

                bclr      #1,$ffff820a.w
                nop
                nop
                nop

                nop
                nop
                nop

                nop
                nop
                nop

                nop
                nop
                nop

                bset      #1,$ffff820a.w
                bra.s     blitt

no_termination:

                addq.b    #1,timechar_out
                cmpi.b    #32,timechar_out
                bne.s     no_char
                move.w    #0,fnt_xsize
                jsr       read
                move.b    #0,timechar_out

no_char:        jsr       do_lines

; -----------------------------------------------

blitt:
                bsr       blitt_cols

                cmpi.w    #52*2-2,col_buffpek
                bne.s     scroll
                move.w    #0,col_buffpek
                bra.s     end_scroll

scroll:         btst      #3,option_flg
                bne.s     end_scroll
                addq.w    #2,col_buffpek
end_scroll:


end_vbl:
                tst.b     clr_plasmaflg
                beq       no_clrpl
                lea       col_buff,a0
                suba.l    #64*2*80,a0
                adda.l    clr_buffpek,a0

                move.w    #0,d0

              rept 64
                move.w    d0,(a0)+
              endr

                move.l    #col_buff,d0
                add.l     #240*(52*2*2+8),d0      ; 64*2*(320)
                cmpa.l    d0,a0
                blo.s     go_clrpl
                move.l    #0,clr_buffpek
                sf        clr_plasmaflg
                bclr      #3,option_flg
                bra.s     no_clrpl
go_clrpl:       addi.l    #64*2,clr_buffpek

no_clrpl:       jsr       textprint_rout
                bset      #7,option_flg           ; set vbl_done flg

                tst.b     go_fade_vol
                beq.s     chk_dma
                jsr       fade_vol


chk_dma:        cmpi.b    #0,$ffff8901.w
                bne.s     playing_dma
                st        go_fade_vol
                jsr       fade_vol
                jsr       play1_dma

playing_dma:    movem.l   (sp)+,d0-a6
                rte
********************************************************************
********************************************************************

blitt_cols:     lea       $ffff8a24.w,a0          ; src addr
                move.l    #$ffff8240,$ffff8a32.w  ; des addr
                lea       $ffff8a36.w,a1          ; x cnt
                lea       $ffff8a3c.w,a2          ; busy


                btst      #3,option_flg
                bne       out_plasma

                move.b    #3,$ffff8a3a.w          ; use halftone
                btst      #1,option_flg
                beq.s     next

                lea       sinus_char,a3
                adda.w    sinus_charpek,a3
                cmpa.l    #sinus_charend,a3
                bne.s     inc_sin
                move.w    #0,sinus_charpek
                bclr      #1,option_flg

                bra.s     next
inc_sin:        addq.w    #2,sinus_charpek

next:
                lea       col_buff,a4             ; for src addr
                adda.w    col_buffpek,a4

                moveq     #0,d1
                btst      #2,option_flg
                beq.s     no_jump
again:          lea       sinus_colbuff,a5
                adda.w    sinus_colbuffpek,a5
                cmpa.l    #sinus_colbuffend,a5
                bne.s     no_shit
                move.w    #0,sinus_colbuffpek
                bra.s     again

no_shit:        move.w    (a5),d0
                move.w    d0,d1
                add.w     d1,d1
                mulu      #52*2*2+8,d0
                suba.w    d0,a4
                addq.w    #2,sinus_colbuffpek

no_jump:        lea       halfand_cols,a5
                adda.w    halfand_colspek2,a5     ; points block with cols
                suba.w    d1,a5

                move.l    a5,d0
                adda.w    halfand_colspek,a5      ; points every single color
                sub.l     a5,d0
                cmp.l     halfand_loopchk,d0
                bne.s     not_end
                move.w    #0,halfand_colspek
                bra.s     ready
not_end:        addq.w    #2,halfand_colspek
ready:
                lea       $ffff8a00.w,a6
                move.w    (a5)+,(a6)              ; half-AND data

                btst      #4,option_flg
                bne       go_smooth
; -----------------------------------------------
                moveq     #52,d1
                moveq     #1,d2
hsync:          move.b    $ffff8209.w,d0
                beq.s     hsync
                not.b     d0
                lsr.b     d0,d0

                btst      #1,option_flg           ; byte
                bne       dist_option

              rept 68-9
                nop
              endr

              rept 240
                move.l    a4,(a0)                 ; src addr, col_buff
                move.w    d1,(a1)                 ; x cnt
                move.w    d2,$ffff8a38.w          ; y cnt
                move.b    #%11000000,(a2)         ; busy!

                lea       52*2*2+8(a4),a4         ; next line
                move.w    (a5)+,(a6)              ; new half-AND data

                nop
                nop

                nop
                nop
                nop
                nop
              endr
                move.w    #0,$ffff8240.w
                rts

dist_option:

              rept 64-8
                nop
              endr

              rept 240
                adda.w    (a3),a4

                move.l    a4,(a0)                 ; src addr, col_buff
                move.w    d1,(a1)                 ; x cnt
                move.w    d2,$ffff8a38.w          ; y cnt
                move.b    #%11000000,(a2)         ; busy!

                suba.w    (a3)+,a4
                lea       52*2*2+8(a4),a4         ; next line
                move.w    (a5)+,(a6)              ; new half-AND data

              endr
                move.w    #0,$ffff8240.w
                rts

; -----------------------------------------------

go_smooth:

                moveq     #52,d1
                moveq     #1,d2
hsync_x:        move.b    $ffff8209.w,d0
                beq.s     hsync_x
                not.b     d0
                lsr.b     d0,d0

                btst      #1,option_flg           ; byte
                bne       dist_option_x

              rept 68-9
                nop
              endr

              rept 240/2
                move.l    a4,(a0)                 ; src addr, col_buff
                move.w    d1,(a1)                 ; x cnt
                move.w    d2,$ffff8a38.w          ; y cnt
                move.b    #%11000000,(a2)         ; busy!

                lea       52*2*2+8(a4),a4         ; next line
                move.w    (a5)+,(a6)              ; new half-AND data

                nop
                nop

                nop
                nop
                nop
;                nop

                move.l    a4,(a0)                 ; src addr, col_buff
                move.w    d1,(a1)                 ; x cnt
                move.w    d2,$ffff8a38.w          ; y cnt
                move.b    #%11000000,(a2)         ; busy!

                lea       52*2*2+8(a4),a4         ; next line
                move.w    (a5)+,(a6)              ; new half-AND data

                nop
                nop

                nop
                nop
                nop
                nop

                nop

              endr
                move.w    #0,$ffff8240.w
                rts


dist_option_x:

              rept 64-8
                nop
              endr

              rept 240/2
                adda.w    (a3),a4

                move.l    a4,(a0)                 ; src addr, col_buff
                move.w    d1,(a1)+                ; x cnt
                move.w    d2,(a1)                 ; y cnt
                move.b    #%11000000,(a2)         ; busy!

                suba.w    (a3)+,a4
                lea       52*2*2+8(a4),a4         ; next line
                move.w    (a5)+,(a6)              ; new half-AND data



                adda.w    (a3),a4

                move.l    a4,(a0)                 ; src addr, col_buff
                move.w    d2,(a1)                 ; y cnt
                move.w    d1,-(a1)                ; x cnt
                move.b    #%11000000,(a2)         ; busy!

                suba.w    (a3)+,a4
                lea       52*2*2+8(a4),a4         ; next line
                move.w    (a5)+,(a6)              ; new half-AND data

                nop
                nop

              endr
                move.w    #0,$ffff8240.w
                rts


; -----------------------------------------------
; -----------------------------------------------
out_plasma:     move.b    #2,$ffff8a3a.w          ; no halftone


                lea       col_buff,a4             ; for src addr
                lea       sinus_plbuff(pc),a3
                adda.w    sinus_plbuffpek(pc),a3
                move.w    (a3),d0
                mulu      #64*2,d0
                adda.w    d0,a4

again_pl:       lea       sinus_plasma(pc),a3
                adda.w    sinus_plasmapek(pc),a3
                cmpa.l    #sinus_plasmaend,a3
                bne.s     go_pl
                move.w    #0,sinus_plasmapek
                bra.s     go_wait

go_pl:          addq.w    #2,sinus_plasmapek

go_wait:

                moveq     #52,d1
                moveq     #1,d2
hsync_2:        move.b    $ffff8209.w,d0
                beq.s     hsync_2
                not.b     d0
                lsr.b     d0,d0

;              rept 64-32
;                nop
;              endr

              rept (240+24)/4
                adda.w    (a3),a4
                move.l    a4,(a0)                 ; src addr, col_buff
                move.w    d1,(a1)                 ; x cnt
                move.w    d2,$ffff8a38.w          ; y cnt
                move.b    #%11000000,(a2)         ; busy!

                suba.w    (a3)+,a4
                lea       64*2(a4),a4             ; next line (52*2*2+8)

                nop
                nop
                nop
                nop

; -----------------------------------------------

                adda.w    (a3),a4
                move.l    a4,(a0)                 ; src addr, col_buff
                move.w    d1,(a1)                 ; x cnt
                move.w    d2,$ffff8a38.w          ; y cnt
                move.b    #%11000000,(a2)         ; busy!

                suba.w    (a3)+,a4
                lea       64*2(a4),a4             ; next line (52*2*2+8)

                nop
                nop
                nop
                nop

; -----------------------------------------------

                adda.w    (a3),a4
                move.l    a4,(a0)                 ; src addr, col_buff
                move.w    d1,(a1)                 ; x cnt
                move.w    d2,$ffff8a38.w          ; y cnt
                move.b    #%11000000,(a2)         ; busy!

                suba.w    (a3)+,a4
                lea       64*2(a4),a4             ; next line (52*2*2+8)

                nop
                nop

; -----------------------------------------------

                adda.w    (a3),a4
                move.l    a4,(a0)                 ; src addr, col_buff
                move.w    d1,(a1)                 ; x cnt
                move.w    d2,$ffff8a38.w          ; y cnt
                move.b    #%11000000,(a2)         ; busy!

                suba.w    (a3)+,a4
                lea       64*2(a4),a4             ; next line (52*2*2+8)

                nop
                nop

              endr
                move.w    #0,$ffff8240.w

; -----------------------------------------------

                lea       sinus_plbuff(pc),a3
                adda.w    sinus_plbuffpek(pc),a3
                cmpa.l    #sinus_plbuffend,a3
                bne.s     go_jam
                move.w    #0,sinus_plbuffpek
                rts

go_jam:         addq.w    #2,sinus_plbuffpek
                rts



; -----------------------------------------------
; -----------------------------------------------

do_lines:       lea       char_buff(pc),a0
                lea       col_buff,a1
                adda.w    col_buffpek,a1

                moveq     #0,d1
                move.l    #52*2*2+8,d2            ; (with dist)

                lea       cols_for_sin(pc),a2     ; (halfand_cols)
                adda.w    halfand_colspek(pc),a2  ; using the same pointer

                lea       sinus_cols(pc),a3
                adda.w    sin_blkpek(pc),a3

                addq.w    #1,fnt_xsize
                cmpi.w    #2,fnt_xsize
                bne.s     do_it
                move.w    #0,fnt_xsize
                st        d1

do_it:
; -----------------------------------------------
                moveq     #8-1,d7
line_lp:        move.w    (a0),d0
                rol.w     #1,d0
                tst.b     d1
                beq.s     no_save
                move.w    d0,(a0)+
                bra.s     tst_bit
no_save:        addq.l    #2,a0


tst_bit:        btst      #0,d0
                bne       char_out

                btst      #0,option_flg           ; byte
                bne       second

              rept 30
                addq.l    #2,a3

                move.w    #0,52*2(a1)             ; place, right
                move.w    #0,(a1)                 ; place, left
                adda.l    d2,a1
              endr

                dbra      d7,line_lp
                rts

second:
              rept 30

                movea.l   a2,a4
                adda.w    (a3)+,a4
                move.w    (a4),d3

;                add.w     #$0f00,d3
                not.w     d3

                move.w    d3,52*2(a1)             ; place, right
                move.w    d3,52*2+2(a1)
                move.w    d3,52*2+4(a1)
                move.w    d3,52*2+6(a1)
                move.w    d3,52*2+8(a1)

                move.w    d3,(a1)                 ; place, left
                adda.l    d2,a1
              endr

                dbra      d7,line_lp
                rts


char_out:       btst      #0,option_flg
                bne       second2


              rept 30
                movea.l   a2,a4
                adda.w    (a3)+,a4

                move.w    (a4),52*2(a1)           ; place, right
                move.w    (a4),(a1)               ; place, left
                adda.l    d2,a1
              endr
                dbra      d7,line_lp
                rts

second2:

              rept 30
                movea.l   a2,a4
                adda.w    (a3)+,a4

                move.w    (a4),52*2(a1)           ; place, right
                move.w    (a4),52*2+2(a1)
                move.w    (a4),52*2+4(a1)
                move.w    (a4),52*2+6(a1)
                move.w    (a4),52*2+8(a1)

                move.w    (a4),(a1)               ; place, left
                adda.l    d2,a1
              endr

                dbra      d7,line_lp
                rts

********************************************************************
; scroll-text routine

read:           lea       text(pc),a0
                adda.w    text_pek(pc),a0

                move.b    (a0),d0

                cmpi.b    #"=",d0
                beq.s     change_colset

                cmpi.b    #0,d0
                bne.s     go_on
                st        reset_flg

                move.w    #0,text_pek
                bra.s     read

go_on:          addq.w    #1,text_pek


; ascii in d0, must be = > 32

                and.w     #$ff,d0
                sub.b     #32,d0                  ; sub space
                add.w     d0,d0
                lea       char_tab(pc),a0
                adda.w    d0,a0
                move.w    (a0),d0

                lea       fontimg,a0              ; (8*3*160)
                adda.w    d0,a0                   ; add offset to font
                lea       char_buff(pc),a1

;_____________________________________  save char to buffer  _______________

              rept 8                          ; lines
                move.w    (a0),d0                 ; font img
                move.w    d0,(a1)+                ; buffer
                lea       160(a0),a0
              endr
                rts
; -----------------------------------------------
change_colset:
                move.w    #0,halfand_colspek

do_set:         lea       colset_tab(pc),a0
                adda.w    colset_tabpek(pc),a0
                addi.w    #3*2+4,colset_tabpek

                cmpi.w    #-1,(a0)
                bne.s     get_set
                move.w    #0,colset_tabpek
                bra.s     do_set

get_set:        move.w    (a0)+,halfand_colspek2
                move.l    (a0)+,halfand_loopchk
                move.w    (a0)+,sin_blkpek
                move.b    (a0),option_flg

                addq.w    #1,text_pek
                bra       read

********************************************************************
textprint_rout:

                tst.b     clr_flg
                beq.s     no_clr
                bsr       clr_screen
                rts

no_clr:         tst.b     read_flg
                beq.s     no_read
                bsr.s     read_drag
                tst.b     read_flg
                beq.s     no_read
                rts

no_read:        bsr       dragchar_out
                rts

; -----------------------------------------------

read_drag:      sf        read_flg
                moveq     #0,d0
read_again:     lea       text_drag(pc),a0
                adda.w    text_pekdrag(pc),a0
                move.b    (a0),d0

                cmp.b     #"&",d0
                bne.s     no_mscroll
                st        clr_plasmaflg

no_mscroll:     cmp.b     #32,d0
                bne.s     tst_end

;                bra.s     tst_end
                lea       char_pos(pc),a1
                adda.w    char_pospek(pc),a1
                cmpa.l    #pos_end,a1
                bne.s     inc_here
                move.w    #0,char_pospek
;                addq.w    #1,text_pekdrag
                st        clr_flg
                st        read_flg
                rts


inc_here:       addq.w    #1,text_pekdrag
                addq.w    #2,char_pospek
                bra.s     read_again

tst_end:        tst.b     d0
                bne.s     ascii
                move.w    #0,char_pospek
                move.w    #0,text_pekdrag
                bra.s     read_again

ascii:          sub.b     #32,d0
                add.w     d0,d0                   ; *2
                lea       char_drag(pc),a0
                adda.w    d0,a0
                move.w    (a0),offset

position:
                movea.l   screen,a0

                lea       char_pos(pc),a1
                adda.w    char_pospek(pc),a1
                cmpa.l    #pos_end,a1
                bne.s     inc_pos
                move.w    #0,char_pospek
;                addq.w    #1,text_pekdrag
                st        clr_flg
                st        read_flg
                rts

inc_pos:        addq.w    #2,char_pospek
                addq.w    #1,text_pekdrag         ; next char

                move.w    (a1),d0
                btst      #0,d0
                beq.s     no_rot
                bclr      #0,d0
                st        rot_flg
                adda.w    d0,a0
                move.l    a0,char_scrnpos
                rts

no_rot:         sf        rot_flg
                adda.w    d0,a0
                move.l    a0,char_scrnpos
                rts

; -----------------------------------------------
dragchar_out:

                tst.b     work_flg1
                bne       work1
                tst.b     work_flg2
                bne       work2

                lea       logic(pc),a2
                adda.w    logic_pek(pc),a2
                cmpa.l    #logic_end,a2
                bne.s     no_end
                move.w    #0,logic_pek
                st        read_flg
                rts

no_end:         addq.w    #2,logic_pek
                move.w    (a2),d1
                move.w    d1,saved_d1

                lea       font_drag+128(pc),a0
                adda.w    offset(pc),a0
                movea.l   char_scrnpos(pc),a1

                not.b     place_flg
                beq.s     go_down
                lea       160*31(a0),a0
                lea       160*31(a1),a1

go_down:        tst.b     rot_flg
                bne.s     rotate

; -----------------------------------------------
                st        work_flg1

do1:            moveq     #4-1,d7
do1_lp:
                move.w    (a0)+,d0
                and.w     d1,d0
                move.w    d0,(a1)+

                move.w    (a0)+,d0
                and.w     d1,d0
                move.w    d0,(a1)+

                move.w    (a0)+,d0
                and.w     d1,d0
                move.w    d0,(a1)+

                move.w    (a0)+,d0
                and.w     d1,d0
                move.w    d0,(a1)+

                move.w    (a0)+,d0
                and.w     d1,d0
                move.w    d0,(a1)+

                move.w    (a0)+,d0
                and.w     d1,d0
                move.w    d0,(a1)+

                move.w    (a0)+,d0
                and.w     d1,d0
                move.w    d0,(a1)+

                move.w    (a0)+,d0
                and.w     d1,d0
                move.w    d0,(a1)+

                tst.b     place_flg
                bne.s     down_1

                lea       160-16(a0),a0
                lea       160-16(a1),a1
                bra.s     yo_1

down_1:         suba.w    #160+16,a0
                suba.w    #160+16,a1
yo_1:
                dbra      d7,do1_lp

                move.l    a0,saved_a0
                move.l    a1,saved_a1
                rts

; -----------------------------------------------
rotate:         st        work_flg2

do2:            moveq     #4-1,d7
do2_lp:
                move.w    (a0)+,d0
                and.w     d1,d0
                move.w    d0,d2
                lsr.w     #8,d0
                lsl.w     #8,d2
                or.w      d2,8(a1)
                or.w      d0,(a1)+

                move.w    (a0)+,d0
                and.w     d1,d0
                move.w    d0,d2
                lsr.w     #8,d0
                lsl.w     #8,d2
                or.w      d2,8(a1)
                or.w      d0,(a1)+

                move.w    (a0)+,d0
                and.w     d1,d0
                move.w    d0,d2
                lsr.w     #8,d0
                lsl.w     #8,d2
                or.w      d2,8(a1)
                or.w      d0,(a1)+

                move.w    (a0)+,d0
                and.w     d1,d0
                move.w    d0,d2
                lsr.w     #8,d0
                lsl.w     #8,d2
                or.w      d2,8(a1)
                or.w      d0,(a1)+

; next blk
                move.w    (a0)+,d0
                and.w     d1,d0
                move.w    d0,d2
                lsr.w     #8,d0
                lsl.w     #8,d2
                or.w      d2,8(a1)
                or.w      d0,(a1)+

                move.w    (a0)+,d0
                and.w     d1,d0
                move.w    d0,d2
                lsr.w     #8,d0
                lsl.w     #8,d2
                or.w      d2,8(a1)
                or.w      d0,(a1)+

                move.w    (a0)+,d0
                and.w     d1,d0
                move.w    d0,d2
                lsr.w     #8,d0
                lsl.w     #8,d2
                or.w      d2,8(a1)
                or.w      d0,(a1)+

                move.w    (a0)+,d0
                and.w     d1,d0
                move.w    d0,d2
                lsr.w     #8,d0
                lsl.w     #8,d2
                or.w      d2,8(a1)
                or.w      d0,(a1)+

                tst.b     place_flg
                bne.s     down_2

                lea       160-16(a0),a0
                lea       160-16(a1),a1
                bra.s     yo_2

down_2:         suba.w    #160+16,a0
                suba.w    #160+16,a1

yo_2:
                dbra      d7,do2_lp

                move.l    a0,saved_a0
                move.l    a1,saved_a1
                rts

; -----------------------------------------------
work1:          move.w    saved_d1(pc),d1
                addq.w    #1,y_lines
                movea.l   saved_a0(pc),a0
                movea.l   saved_a1(pc),a1

chk_1:          cmpi.w    #32/4,y_lines
                bne       do1
                move.w    #0,y_lines
                sf        work_flg1
                rts

work2:          move.w    saved_d1(pc),d1
                addq.w    #1,y_lines
                movea.l   saved_a0(pc),a0
                movea.l   saved_a1(pc),a1

chk_2:          cmpi.w    #32/4,y_lines
                bne       do2
                move.w    #0,y_lines
                sf        work_flg2
                rts

; -----------------------------------------------
clr_screen:     cmpi.w    #70,wait_clr
                beq.s     yez_clr
                addq.w    #1,wait_clr
                rts

yez_clr:        movea.l   screen,a0
                movea.l   a0,a1
                adda.w    topclr_pek(pc),a0
                adda.w    downclr_pek(pc),a1

                moveq     #0,d0
              rept 20*4
                move.w    d0,(a0)+
              endr

              rept 20*4
                move.w    d0,(a1)+
              endr

                cmpi.w    #160*99,topclr_pek
                bne.s     clr_on
                sf        clr_flg
                move.w    #0,topclr_pek
                move.w    #160*199,downclr_pek
                move.w    #0,wait_clr

                bset      #5,option_flg           ; change font_pal!
                rts

clr_on:         addi.w    #160,topclr_pek
                subi.w    #160,downclr_pek
                rts

; -----------------------------------------------
; -----------------------------------------------
play1_dma:      move.b    dma_st+1(pc),$ffff8903.w
                move.b    dma_st+2(pc),$ffff8905.w
                move.b    dma_st+3(pc),$ffff8907.w

                move.b    dma_end+1(pc),$ffff890f.w
                move.b    dma_end+2(pc),$ffff8911.w
                move.b    dma_end+3(pc),$ffff8913.w

                move.b    #%10000001,$ffff8921.w  ; kHz
                move.b    #0,$ffff8901.w
                move.b    #3,$ffff8901.w          ; on shit!
                rts

*-------------------------------------------------

play2_dma:      move.b    dma_st2+1(pc),$ffff8903.w
                move.b    dma_st2+2(pc),$ffff8905.w
                move.b    dma_st2+3(pc),$ffff8907.w

                move.b    dma_end2+1(pc),$ffff890f.w
                move.b    dma_end2+2(pc),$ffff8911.w
                move.b    dma_end2+3(pc),$ffff8913.w

                move.b    #%10000001,$ffff8921.w  ; kHz
                move.b    #0,$ffff8901.w
                move.b    #1,$ffff8901.w          ; on shit!
                rts

; -----------------------------------------------

init_dma:       move.w    #$07ff,$ffff8924.w      ; to mw mask
                lea       mw_set(pc),a0           ; microwire settings
                lea       $ffff8922.w,a1          ; mw data

                move.w    (a1),d7                 ; save previous
mw_loop:        move.w    (a0)+,(a1)
mw_wait:        cmp.w     (a1),d7
                bne.s     mw_wait
                cmpa.l    #mw_setend,a0
                bne.s     mw_loop
                rts
*-------------------------------------------------

fade_vol:       tst.b     vol_flg
                beq.s     go_vol
                rts

go_vol:         cmpi.b    #8,vol_pause
                beq.s     go_vol_now
                addq.b    #1,vol_pause
                rts

go_vol_now:     move.b    #0,vol_pause
                lea       mw_vol(pc),a0
                addq.w    #1,(a0)
                cmpi.w    #%10011000000+41,(a0)
                bne.s     vol_out
                move.w    #%10011000000+25,(a0)
                st        vol_flg
                rts

vol_out:
                move.w    #$07ff,$ffff8924.w      ; to mw mask
                lea       $ffff8922.w,a1          ; mw data

                move.w    (a1),d7                 ; save previous
                move.w    (a0),(a1)
mw_wait2:       cmp.w     (a1),d7
                bne.s     mw_wait2
                rts


mw_vol:       dc.w %10011000000+25            ; master    0-40


; -----------------------------------------------
; -----------------------------------------------
; -----------------------------------------------
back:
                move.l    oldvbl(pc),$70
                move.w    #$03,$ffff8240.w
                move.w    #$0777,$ffff8246.w
                bset      #5,$fffffa09.w
                bset      #1,$ffff820a.w
                move.b    old_scrnhi(pc),$ffff8201.w
                move.b    old_scrnlo(pc),$ffff8203.w
                clr.w     -(sp)
                trap      #1

********************************************************************
********************************************************************
; data & variables for textprint route

;  32*32 dragfont, begins #32 (space)
char_drag:    dc.w $00,$10,$20,$30,$40,$50
              dc.w $60,$70,$80,$90
              dc.w $1400,$1410,$1420,$1430,$1440,$1450
              dc.w $1460,$1470,$1480,$1490
              dc.w $2800,$2810,$2820,$2830,$2840,$2850
              dc.w $2860,$2870,$2880,$2890
              dc.w $3c00,$3c10,$3c20,$3c30,$3c40,$3c50
              dc.w $3c60,$3c70,$3c80,$3c90
              dc.w $5000,$5010,$5020,$5030,$5040,$5050
              dc.w $5060,$5070,$5080,$5090
              dc.w $6400,$6410,$6420,$6430,$6440,$6450
              dc.w $6460,$6470,$6480,$6490


char_pospek:  dc.w 0
char_pos:
              dc.w $00,$10+1,$28,$38+1,$50,$60+1
              dc.w $78,$88+1

              dc.w $1400+$00+1280,$1400+$10+1+1280,$1400+$28+1280,$1400+$38+1+1280,$1400+$50+1280,$1400+$60+1+1280
              dc.w $1400+$78+1280,$1400+$88+1+1280

              dc.w $2800+$00+2560,$2800+$10+1+2560,$2800+$28+2560,$2800+$38+1+2560,$2800+$50+2560,$2800+$60+1+2560
              dc.w $2800+$78+2560,$2800+$88+1+2560

              dc.w $3c00+$00+3840,$3c00+$10+1+3840,$3c00+$28+3840,$3c00+$38+1+3840,$3c00+$50+3840,$3c00+$60+1+3840
              dc.w $3c00+$78+3840,$3c00+$88+1+3840

              dc.w $5000+$00+5120,$5000+$10+1+5120,$5000+$28+5120,$5000+$38+1+5120,$5000+$50+5120,$5000+$60+1+5120
              dc.w $5000+$78+5120,$5000+$88+1+5120
pos_end:

text_pekdrag: dc.w 0
; -----------------------------------------------
; "&" to clr colbuff
text_drag:    dc.b "########"
              dc.b "        "
              dc.b "        "
              dc.b "        "
              dc.b "        "

              dc.b "########"
              dc.b "        "
              dc.b "PRESENTS"
              dc.b "        "
              dc.b "        "

              dc.b "#&######"
              dc.b "########"
              dc.b "THE...  "
              dc.b "JAM-COLS"
              dc.b "   DEMO!"

              dc.b "        "
              dc.b "       #"
              dc.b "########"
              dc.b "####    "
              dc.b "        "

              dc.b "        "
              dc.b "        "
              dc.b "CREDITS:"
              dc.b "        "
              dc.b "        "

              dc.b "        "
              dc.b "ALL CODE"
              dc.b "AND SOME"
              dc.b " GFX BY:"
              dc.b "        "

              dc.b "        "
              dc.b "        "
              dc.b "TECHWAVE"
              dc.b "        "
              dc.b "        "

              dc.b "        "
              dc.b "MEGACOOL"
              dc.b "ICE-LOGO"
              dc.b "  BY:   "
              dc.b "        "

              dc.b "        "
              dc.b "        "
              dc.b " CUTTER "
              dc.b "        "
              dc.b "        "

              dc.b "########"
              dc.b "########"
              dc.b "########"
              dc.b "########"
              dc.b "########"

              dc.b "DIS DEMO"
              dc.b " USES A "
              dc.b "NEW SORT"
              dc.b "OF COLOR"
              dc.b "CODING.."

              dc.b "        "
              dc.b "..NEVER "
              dc.b "SEEN BE4"
              dc.b " ON THE "
              dc.b "  STE!  "

              dc.b "        "
              dc.b "########"
              dc.b "########"
              dc.b "########"
              dc.b "########"

              dc.b "        "
              dc.b "TWICE   "
              dc.b "   AS   "
              dc.b "    NICE"
              dc.b "        "

              dc.b "        "
              dc.b "        "
              dc.b "WITH    "
              dc.b "    ICE!"
              dc.b "        "

              dc.b "####### "
              dc.b " PEOPLE "
              dc.b " IN THE "
              dc.b "ICE VAN:"
              dc.b "        "

              dc.b " TURTLE "
              dc.b " CODFI  "
              dc.b " ELF    "
              dc.b " ANTOX  "
              dc.b " CUTTER "

              dc.b "        "
              dc.b "AND     "
              dc.b "TECHWAVE"
              dc.b "        "
              dc.b "        "

              dc.b "########"
              dc.b "########"
              dc.b "########"
              dc.b "########"
              dc.b "        "

              dc.b "        "
              dc.b " U ARE  "
              dc.b "ABOUT TO"
              dc.b " SEE... "
              dc.b "        "

              dc.b "        "
              dc.b "THE     "
              dc.b " WATER  "
              dc.b "  CYCLES"
              dc.b "        "

              dc.b "########"
              dc.b "########"
              dc.b "########"
              dc.b "########"
              dc.b "########"

              dc.b "########"
              dc.b "########"
              dc.b "########"
              dc.b "########"
              dc.b "########"

              dc.b "        "
              dc.b "THIS... "
              dc.b "JAM-DEMO"
              dc.b "  WAS   "
              dc.b "LAUNCHED"

              dc.b "        "
              dc.b " IN...  "
              dc.b "JANUARY "
              dc.b " -1992- "
              dc.b "        "

              dc.b "        "
              dc.b "-SPREAD-"
              dc.b "THE NICE"
              dc.b "JAM-COLS"
              dc.b "   !!   "

              dc.b "########"
              dc.b "########"
              dc.b "########"
              dc.b "########"
              dc.b "        "

              dc.b "        "
              dc.b "        "
              dc.b " HI TO: "
              dc.b "        "
              dc.b "        "

              dc.b "OMEGA   "
              dc.b "ELECTRA "
              dc.b "SYNC    "
              dc.b "TCB     "
              dc.b "GRC     "

              dc.b "UNIT 17 "
              dc.b "FLEXICH."
              dc.b "PHALANX "
              dc.b "POLTERG."
              dc.b "PENDRAG."

              dc.b "DELTA F."
              dc.b "OVR     "
              dc.b "TLB     "
              dc.b "LIGHT   "
              dc.b "ULM     "

              dc.b "        "
              dc.b "        "
              dc.b "AND YOU!"
              dc.b "        "
              dc.b "        "

              dc.b "########"
              dc.b "########"
              dc.b "########"
              dc.b "########"
              dc.b "########"

              dc.b "########"
              dc.b "########"
              dc.b "########"
              dc.b "        "
              dc.b "        "

              dc.b "########"
              dc.b "BYE     "
              dc.b "  BYE   "
              dc.b "    BYE!"
              dc.b "        "

              dc.b "###     "
              dc.b "LET'S GO"
              dc.b "JAM-JAM "
              dc.b "AGAIN!!!"
              dc.b "        "

              dc.b "########"
              dc.b "########"
              dc.b "########"
              dc.b "########"
              dc.b "########"

              dc.b 0
              even



logic_pek:    dc.w 0
logic:
              dc.w %1100000000000011
              dc.w %1111000000001111
              dc.w %1111110000111111
              dc.w %1111111111111111
logic_end:

read_flg:     dc.b $ff
rot_flg:      dc.b 0
work_flg1:    dc.b 0
work_flg2:    dc.b 0
place_flg:    dc.b $ff
reset_flg:    dc.b 0
              even

saved_d1:     dc.w 0
saved_a0:     dc.l 0
saved_a1:     dc.l 0
y_lines:      dc.w 0
topclr_pek:   dc.w 0
downclr_pek:  dc.w 160*199
wait_clr:     dc.w 0


offset:       dc.w 0
char_scrnpos: dc.l 0

; -----------------------------------------------
; -----------------------------------------------
; data & variables for the fucking rest

mw_set:       dc.w %10011000000+40            ; master    0-40
              dc.w %10101000000+20            ; left      0-20
              dc.w %10100000000+20            ; right     0-20
              dc.w %10010000000+6             ; treble    0-12 (6=0dB)
              dc.w %10001000000+8             ; bass      0-12 (6=0dB)
              dc.w %10000000000+2             ; mix       0-03
mw_setend:
dma_st:       dc.l like
dma_end:      dc.l like_end

dma_st2:      dc.l intro_spl
dma_end2:     dc.l intro_spl_end

*-------------------------------------------------

oldvbl:       dc.l 0
old_scrnhi:   dc.b 0
old_scrnlo:   dc.b 0

text_pek:     dc.w 0
timechar_out: dc.b 0
option_flg:   dc.b 0
clr_plasmaflg:dc.b 0
vol_flg:      dc.b 0
vol_pause:    dc.b 8
go_fade_vol:  dc.b 0

              even

fnt_xsize:    dc.w 0

char_buff:    ds.w 8
char_cols:    dc.w 0

sin_blkpek:   dc.w 0

halfand_colspek:dc.w 0
halfand_colspek2:dc.w 0
halfand_loopchk:dc.l 0

*-------------------------------------------------
colset_tabpek:dc.w 0

colset_tab:
              dc.w 0*(32*2*9)                 ; relative begin address
              dc.l -32*2+2                    ; where to loop (neg)
              dc.w 0                          ; relative sinus address
              dc.b %0                         ; option flg (byte)
              even

              dc.w 1*(32*2*9)
              dc.l -32*2+2
              dc.w 0
              dc.b %0
              even

              dc.w 3*(32*2*9)
              dc.l -32*2+2
              dc.w 0
              dc.b %100                       ; jump baby, jump!
              even

              dc.w 2*(32*2*9)
              dc.l -32*2+2
              dc.w 240*2
              dc.b %0
              even

*-------------------------------------------------

              dc.w 0*(32*2*9)                 ; blue colshit
              dc.l -32*2+2
              dc.w 0
              dc.b %1
              even

              dc.w 0*(32*2*9)
              dc.l -32*2+2
              dc.w 0
              dc.b %11
              even

              dc.w 0*(32*2*9)
              dc.l -32*2+2
              dc.w 0
              dc.b %0
              even

*-------------------------------------------------

              dc.w 2*(32*2*9)                 ; green colshit
              dc.l -32*2+2
              dc.w 240*2
              dc.b %10001
              even

              dc.w 2*(32*2*9)
              dc.l -32*2+2
              dc.w 240*2
              dc.b %10011
              even

              dc.w 2*(32*2*9)
              dc.l -32*2+2
              dc.w 240*2
              dc.b %10000
              even

*-------------------------------------------------

              dc.w 4*(32*2*9)
              dc.l -32*2+2
              dc.w 0
              dc.b %0
              even

*-------------------------------------------------

              dc.w 4*(32*2*9)                 ; red colshit
              dc.l -32*2+2
              dc.w 240*2
              dc.b %10001
              even

              dc.w 4*(32*2*9)
              dc.l -32*2+2
              dc.w 240*2
              dc.b %10011
              even

              dc.w 4*(32*2*9)
              dc.l -32*2+2
              dc.w 240*2
              dc.b %10000
              even


; -----------------------------------------------

              dc.w 0*(32*2*9)
              dc.l -32*2+2
              dc.w 240*2
              dc.b %100
              even

*-------------------------------------------------

              dc.w 0*(32*2*9)                 ; blue colshit
              dc.l -32*2+2
              dc.w 240*2
              dc.b %10001
              even

              dc.w 0*(32*2*9)
              dc.l -32*2+2
              dc.w 240*2
              dc.b %10011
              even

              dc.w 0*(32*2*9)
              dc.l -32*2+2
              dc.w 240*2
              dc.b %10001
              even

              dc.w 0*(32*2*9)
              dc.l -32*2+2
              dc.w 240*2
              dc.b %10011
              even

              dc.w 0*(32*2*9)
              dc.l -32*2+2
              dc.w 240*2
              dc.b %10000
              even
*-------------------------------------------------
              dc.w 2*(32*2*9)
              dc.l -32*2+2
              dc.w 0
              dc.b %100
              even

              dc.w 2*(32*2*9)
              dc.l -32*2+2
              dc.w 0
              dc.b %0
              even

*-------------------------------------------------

              dc.w 1*(32*2*9)                 ; x colshit
              dc.l -32*2+2
              dc.w 240*2
              dc.b %10001
              even

              dc.w 1*(32*2*9)
              dc.l -32*2+2
              dc.w 240*2
              dc.b %10011
              even

              dc.w 1*(32*2*9)
              dc.l -32*2+2
              dc.w 240*2
              dc.b %10000
              even

*-------------------------------------------------
              dc.w 3*(32*2*9)
              dc.l -32*2+2
              dc.w 0
              dc.b %0
              even

*-------------------------------------------------

              dc.w 3*(32*2*9)                 ; x colshit
              dc.l -32*2+2
              dc.w 0
              dc.b %10001
              even

              dc.w 3*(32*2*9)
              dc.l -32*2+2
              dc.w 0
              dc.b %10011
              even

              dc.w 3*(32*2*9)
              dc.l -32*2+2
              dc.w 0
              dc.b %10000
              even

              dc.w -1

*-------------------------------------------------

; font is .w oriented
char_tab:
              dc.w 0,8,16,24,32,40,48,56,64,72,80,88,96,104,112,120,128,136,144,152
              dc.w $0500,$0500+8,$0500+16,$0500+24,$0500+32,$0500+40,$0500+48,$0500+56,$0500+64
              dc.w $0500+72,$0500+80,$0500+88,$0500+96,$0500+104,$0500+112,$0500+120,$0500+128
              dc.w $0500+136,$0500+144,$0500+152
              dc.w $0a00,$0a00+8,$0a00+16,$0a00+24,$0a00+32,$0a00+40,$0a00+48,$0a00+56,$0a00+64
              dc.w $0a00+72,$0a00+80,$0a00+88,$0a00+96,$0a00+104,$0a00+112,$0a00+120,$0a00+128
              dc.w $0a00+136,$0a00+144,$0a00+160
              dc.w $0f00,$0f00+8,$0f00+16,$0f00+24,$0f00+32,$0f00+40,$0f00+48,$0f00+56,$0f00+64
              dc.w $0f00+72,$0f00+80,$0f00+88,$0f00+96,$0f00+104,$0f00+112,$0f00+120,$0f00+128
              dc.w $0f00+136,$0f00+144,$0f00+160
              dc.w $1400,$1400+8,$1400+16,$1400+24,$1400+32,$1400+40,$1400+48,$1400+56
              dc.w $1400+64,$1400+72,$1400+80,$1400+88,$1400+96,$1400+104,$1400+112
              dc.w $1400+120,$1400+128,$1400+136,$1400+144,$1400+160



********************************************************************


; change cols (and sinus) with: =  , and # for fill

text:         dc.b "=THE JAM-COLORS DEMO!        =AND THIS TIME IT'S REALLY "
              dc.b "COLD!     "
              dc.b "=ALL HEAVY MEGA-NICE-JAM-COLOR CODE BY TECHWAVE!    "
              dc.b "=IT'S TIME FOR SOME MORE NICE WAVES...   "
              dc.b "=      ="
              dc.b "                                        "
              dc.b "TECHWAVE RULES!"
              dc.b "=    DRINK &   "
              dc.b "=     =                                 "
              dc.b "                              BE BAD! "
              dc.b "=    "
              dc.b "=GREETINGS TO ALL JAM-COLORS FANS IN THE ENTIRE WORLD!   "
              dc.b "=     =                                 "
              dc.b "                                "
              dc.b "  =    "

              dc.b "= DEDICATED TO ALL TEA-LOVERS!  KEEP THE WATER CLEAR AND "
              dc.b "THE REST GOING!   "

              dc.b "=     =                                 "
              dc.b "                 =     =                 "
              dc.b "                       WATER BRINGS LIFE!   =    "

              dc.b "=HEY CODFI, MINE ROUTS ARE ALWAYS THE FASTEST AND WILL "
              dc.b "NEVER BE BEATEN...HE HE!   "

              dc.b "=TIME FOR SOME NASTY JAM-COLORS...   "

              dc.b "=     =                                 "
              dc.b "                                "
              dc.b "  =    "

              dc.b "=THE END IS NEAR!   U CAN CONTACT ME ON THIS ADDRESS:    "
              dc.b "TOBIAS NILSSON 'TECHWAVE'    "
              dc.b "KONVALESCENTV. 39    "
              dc.b "S-439 00  ONSALA    "
              dc.b "SWEDEN    "

              dc.b "=     =                                 "
              dc.b "                                "
              dc.b "  =    "

              dc.b 0
              even


sinus_plbuffpek:dc.w 0
sinus_plbuff:
              rept 200
              dc.w 0
              endr

              rept 3
              dc.w 0,0,1,1,2,2,3,4,6,8,10,12,14,16,18,20,22,24,26,28,30
              dc.w 32,34,36,38,40,42,43,44,45,46,46,47,47,47
              dc.w 47,47,47,46,46,45,44,43,42,40,38,36,34,32
              dc.w 30,28,26,24,22,20,18,16,14,12,10,8,6,4,3,2,2,1,1,0,0
              endr

sinus_plbuffend:
              dc.w 0


*-------------------------------------------------

plasma_tab:

              dc.w 0
              dc.w 4
              dc.w 8

              dc.w 0
              dc.w 4
              dc.w 8

              dc.w 0
              dc.w 4
              dc.w 8

              dc.w 0
              dc.w 4
              dc.w 8

              dc.w 0
              dc.w 4


plasma:                                           ; 52 cols/line
              rept 2

              dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,$00
              dc.w $00,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
              dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,$00,$08
              dc.w $08,$00,0,0,0,0,0,0,0,0,0,0,0,0,0,0
              dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,$00,$08,$01
              dc.w $01,$08,$00,0,0,0,0,0,0,0,0,0,0,0,0,0
              dc.w 0,0,0,0,0,0,0,0,0,0,0,0,$00,$08,$01,$09
              dc.w $09,$01,$08,$00,0,0,0,0,0,0,0,0,0,0,0,0
              dc.w 0,0,0,0,0,0,0,0,0,0,0,$00,$08,$01,$09,$02
              dc.w $02,$09,$01,$08,$00,0,0,0,0,0,0,0,0,0,0,0
              dc.w 0,0,0,0,0,0,0,0,0,0,$00,$08,$01,$09,$02,$0a
              dc.w $0a,$02,$09,$01,$08,$00,0,0,0,0,0,0,0,0,0,0
              dc.w 0,0,0,0,0,0,0,0,0,$00,$08,$01,$09,$02,$0a,$03
              dc.w $03,$0a,$02,$09,$01,$08,$00,0,0,0,0,0,0,0,0,0
              dc.w 0,0,0,0,0,0,0,0,$00,$08,$01,$09,$02,$0a,$03,$0b
              dc.w $0b,$03,$0a,$02,$09,$01,$08,$00,0,0,0,0,0,0,0,0
              dc.w 0,0,0,0,0,0,0,$00,$08,$01,$09,$02,$0a,$03,$0b,$04
              dc.w $04,$0b,$03,$0a,$02,$09,$01,$08,$00,0,0,0,0,0,0,0
              dc.w 0,0,0,0,0,0,$00,$08,$01,$09,$02,$0a,$03,$0b,$04,$0c
              dc.w $0c,$04,$0b,$03,$0a,$02,$09,$01,$08,$00,0,0,0,0,0,0
              dc.w 0,0,0,0,0,$00,$08,$01,$09,$02,$0a,$03,$0b,$04,$0c,$05
              dc.w $05,$0c,$04,$0b,$03,$0a,$02,$09,$01,$08,$00,0,0,0,0,0
              dc.w 0,0,0,0,$00,$08,$01,$09,$02,$0a,$03,$0b,$04,$0c,$05,$0d
              dc.w $0d,$05,$0c,$04,$0b,$03,$0a,$02,$09,$01,$08,$00,0,0,0,0
              dc.w 0,0,0,$00,$08,$01,$09,$02,$0a,$03,$0b,$04,$0c,$05,$0d,$06
              dc.w $06,$0d,$05,$0c,$04,$0b,$03,$0a,$02,$09,$01,$08,$00,0,0,0
              dc.w 0,0,$00,$08,$01,$09,$02,$0a,$03,$0b,$04,$0c,$05,$0d,$06,$0e
              dc.w $0e,$06,$0d,$05,$0c,$04,$0b,$03,$0a,$02,$09,$01,$08,$00,0,0
              dc.w 0,$00,$08,$01,$09,$02,$0a,$03,$0b,$04,$0c,$05,$0d,$06,$0e,$07
              dc.w $07,$0e,$06,$0d,$05,$0c,$04,$0b,$03,$0a,$02,$09,$01,$08,$00,0
              dc.w $00,$08,$01,$09,$02,$0a,$03,$0b,$04,$0c,$05,$0d,$06,$0e,$07,$0f
              dc.w $0f,$07,$0e,$06,$0d,$05,$0c,$04,$0b,$03,$0a,$02,$09,$01,$08,$00
              endr

              ds.b 50*2
halfand_cols:
; 1st
              rept 9                          ; 32*9=288 lines (for loop)
              dc.w $0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f
              dc.w $0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f

              dc.w $0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f
              dc.w $0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f
              endr

; 2nd
              rept 9
              dc.w $0f,$8f,$1f,$9f,$2f,$af,$3f,$bf
              dc.w $4f,$cf,$5f,$df,$6f,$ef,$7f,$ff

              dc.w $ff,$7f,$ef,$6f,$df,$5f,$cf,$4f
              dc.w $bf,$3f,$af,$2f,$9f,$1f,$8f,$0f
              endr

; 3rd
              rept 9
              dc.w $f0,$08f8,$01f1,$09f9,$02f2,$0afa,$03f3,$0bfb
              dc.w $04f4,$0cfc,$05f5,$0dfd,$06f6,$0efe,$07f7,$0fff

              dc.w $0fff,$07f7,$0efe,$06f6,$0dfd,$05f5,$0cfc,$04f4
              dc.w $0bfb,$03f3,$0afa,$02f2,$09f9,$01f1,$08f8,$f0
              endr

; 4th
              rept 9
              dc.w $ff,$08ff,$01ff,$09ff,$02ff,$0aff,$03ff,$0bff
              dc.w $04ff,$0cff,$05ff,$0dff,$06ff,$0eff,$07ff,$0fff

              dc.w $0fff,$07ff,$0eff,$06ff,$0dff,$05ff,$0cff,$04ff
              dc.w $0bff,$03ff,$0aff,$02ff,$09ff,$01ff,$08ff,$ff
              endr

; 5th
              rept 9
              dc.w $0f00,$0f08,$0f01,$0f09,$0f02,$0f0a,$0f03,$0f0b
              dc.w $0f04,$0f0c,$0f05,$0f0d,$0f06,$0f0e,$0f07,$0f0f

              dc.w $0f0f,$0f07,$0f0e,$0f06,$0f0d,$0f05,$0f0c,$0f04
              dc.w $0f0b,$0f03,$0f0a,$0f02,$0f09,$0f01,$0f08,$0f00
              endr




sinus_cols:                                       ; .w line/char
              rept 8
; 240 words
              dc.w 0,0,2,2,4,6,10,14,20,22,24,26,26,28,28
              dc.w 28,28,26,26,24,22,20,14,10,6,4,2,2,0,0
              endr

;              rept 8
;              dc.w 0,0,0,2,2,4,4,6,8,12,16,20,24,28,32,36,40,44,48
;              dc.w 52,56,60,62,64,66,66,68,68,70,70,70
;              dc.w 70,70,70,68,68,66,66,64,62,60,56,52,48,44,40,36,32
;              dc.w 28,24,20,16,12,8,6,4,4,2,2,0,0,0
;              endr

              rept 8
              dc.w 0,0,0,0,2,2,2,4,4,6,8,10,12,14,16,18,20,22,24,26,28,30,32
              dc.w 34,36,38,40,40,42,42,42,44,44,44,44
              dc.w 44,44,44,44,42,42,42,40,40,38,36,34,32,30,28,26,24,22,20
              dc.w 18,16,14,12,10,8,6,4,4,2,2,2,0,0,0,0
              endr

sinus_charpek:dc.w 0

sinus_char:
              rept 8
              dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
              dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
              endr

              dc.w 0,0,0,0,0,0,0,0,0,0,0,0,2,2,2,2
              dc.w 2,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0

              rept 1
              dc.w 0,0,0,0,0,0,0,0,0,2,2,2,4,4,4,4
              dc.w 4,4,4,4,2,2,2,0,0,0,0,0,0,0,0,0
              endr

              rept 2
              dc.w 0,0,0,0,0,0,0,2,2,4,4,4,6,6,6,6
              dc.w 6,6,6,6,4,4,4,2,2,0,0,0,0,0,0,0
              endr

              rept 8*3
              dc.w 0,0,0,0,2,2,2,4,4,6,6,6,8,8,8,8
              dc.w 8,8,8,8,6,6,6,4,4,2,2,2,0,0,0,0
              endr

              rept 2
              dc.w 0,0,0,0,0,0,0,2,2,4,4,4,6,6,6,6
              dc.w 6,6,6,6,4,4,4,2,2,0,0,0,0,0,0,0
              endr

              rept 1
              dc.w 0,0,0,0,0,0,0,0,0,2,2,2,4,4,4,4
              dc.w 4,4,4,4,2,2,2,0,0,0,0,0,0,0,0,0
              endr

              dc.w 0,0,0,0,0,0,0,0,0,0,0,0,2,2,2,2
              dc.w 2,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0

sinus_charend:
              rept 8
              dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
              dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
              endr

cols_for_sin:

              rept 4
              dc.w $00,$0888,$0111,$0999,$0222,$0aaa,$0333,$0bbb
              dc.w $0444,$0ccc,$0555,$0ddd,$0666,$0eee,$0777,$0fff

              dc.w $0fff,$0777,$0eee,$0666,$0ddd,$0555,$0ccc,$0444
              dc.w $0bbb,$0333,$0aaa,$0222,$0999,$0111,$0888,$00
              endr

sinus_colbuffpek:dc.w 0
sinus_colbuff:
;              dc.w 0,0,0,1,2,3,4,6,8,10,12,14,17,20,24,28,32,36,40,44,48
;              dc.w 44,40,36,32,28,24,20,17,14,12,10,8,6,4,3,2,1,0

              dc.w 0,0,1,2,3,4,6,8,10,13,16,20,24,28,32,36,40,44,48
              dc.w 44,40,36,32,28,24,20,16,13,10,8,6,4,3,2,1,0

sinus_colbuffend:


sinus_plasmapek:dc.w 0
sinus_plasma:
              rept 8

;              dc.w 0,0,0,0,2,2,2,4,4,6,6,8,12,16,20,24,28,32
;              dc.w 34,36,36,38,38,40,40,40,42,42,42,42
;              dc.w 42,42,42,42,40,40,40,38,38,36,36,34
;              dc.w 32,28,24,20,16,12,8,6,6,4,4,2,2,2,0,0,0,0

              dc.w 0,0,0,0,0,2,2,2,2,4,4,4,6,6,8,8,10,14,18,22
              dc.w 26,30,34,38,42,46,50,52,54,54,56,56,56,58,58,58,58
              dc.w 60,60,60,60,60
              dc.w 60,60,60,60,60,58,58,58,58,56,56,56,54,54,52,50
              dc.w 46,42,38,34,30,26,22,18,14,10,8,8,6,6,4,4,4,2,2,2,2
              dc.w 0,0,0,0,0

              endr
sinus_plasmaend:

              rept 8
              dc.w 0,0,0,0,0,2,2,2,2,4,4,4,6,6,8,8,10,14,18,22
              dc.w 26,30,34,38,42,46,50,52,54,54,56,56,56,58,58,58,58
              dc.w 60,60,60,60,60
              dc.w 60,60,60,60,60,58,58,58,58,56,56,56,54,54,52,50
              dc.w 46,42,38,34,30,26,22,18,14,10,8,8,6,6,4,4,4,2,2,2,2
              dc.w 0,0,0,0,0
              endr


font_drag:    ibytes 'A:\DRAGFON3.NEO'
fontimg:      ibytes 'A:\FC168.IMG',3840      ; 160*8*3

clr_buffpek:  dc.l 0
col_buffpek:  dc.w 0
col_buffscroll:ds.b 50*(52*2*2+8)
col_buff:     ds.b 303*(52*2*2+8)             ; 240
col_buffend:
;ds.w 10

ice_logo:     ibytes 'A:\BIG_ICE.PI1'


like:         ibytes 'A:\LIKE.SPL'
like_end:

intro_spl:    ds.b 3000
              ibytes 'B:\YEAHH.SPL'
intro_spl_end:

screen:       dc.l 0
              end
