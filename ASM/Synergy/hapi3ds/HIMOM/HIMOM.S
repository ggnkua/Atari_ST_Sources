                                                                                                                                                                                                                                                                
                >PART 'constants'
                PATH 'D:\RAPIDO.SSD\HIMOM\BINARY\'
system          EQU 0

                IFNE system
                DEFAULT 1
                OUTPUT 'D:\HIMOM.PRG'
                ELSE
                DEFAULT 2
                OUTPUT 'D:\HIMOM.SYN'
                ENDC

                ENDPART
                >PART 'base'

                IFNE system
                  bsr.s go_super
                  bsr   clear_bss
                  lea   stack,sp
                  lea   ustack,a0
                  move  a0,usp
                  bsr.s save_regs
                  bsr   clear_regs
                  bsr   flush_keyboard
                  bsr   main
exit2:            bsr   clear_regs
                  bsr   rest_regs
                  bsr   flush_keyboard
                  bra.s go_user

                OPT O-

go_super:         clr.l -(sp)
                  move.w #32,-(sp)
                  trap  #1
                  addq.l #6,sp
                  move.l d0,user_stack+2
                  rts

go_user:          move  #$2300,sr
user_stack:       pea   0
                  move.w #32,-(sp)
                  trap  #1
                  addq.l #6,sp
                  clr.w -(sp)
                  trap  #1

                OPT O+

save_regs:        lea   old_regs,a0
                  lea   $fffffa00.w,a1
                  move.l $ffff8200.w,(a0)+
                  move.b $ffff820a.w,(a0)+
                  move.b $ffff8260.w,(a0)+
                  movem.l $ffff8240.w,d0-d7
                  movem.l d0-d7,(a0)
                  lea   32(a0),a0

                  movep.w $07(a1),d0
                  movep.l $13(a1),d1
                  movep.l $1b(a1),d2
                  move.w d0,(a0)+
                  move.l d1,(a0)+
                  move.l d2,(a0)+
                  move.l $60.w,(a0)+
                  move.l $68.w,(a0)+
                  move.l $70.w,(a0)+
                  move.l $80.w,(a0)+
                  move.l $0110.w,(a0)+
                  move.l $0114.w,(a0)+
                  move.l $0118.w,(a0)+
                  move.l $0120.w,(a0)+
                  move.l $0134.w,(a0)+
                  rts

rest_regs:        lea   old_regs,a0
                  lea   $fffffa00.w,a1
                  stop  #$2300
                  move.l (a0)+,$ffff8200.w
                  move.b (a0)+,$ffff820a.w
                  move.b (a0)+,$ffff8260.w
                  stop  #$2300
                  movem.l (a0)+,d0-d7
                  movem.l d0-d7,$ffff8240.w

                  move  #$2700,sr
                  move.w (a0)+,d0
                  move.l (a0)+,d1
                  move.l (a0)+,d2
                  movep.w d0,$07(a1)
                  movep.l d1,$13(a1)
                  movep.l d2,$1b(a1)
                  move.l (a0)+,$60.w
                  move.l (a0)+,$68.w
                  move.l (a0)+,$70.w
                  move.l (a0)+,$80.w
                  move.l (a0)+,$0110.w
                  move.l (a0)+,$0114.w
                  move.l (a0)+,$0118.w
                  move.l (a0)+,$0120.w
                  move.l (a0)+,$0134.w
                  rts

clear_regs:       lea   $fffffa00.w,a0
                  lea   rte_rout(pc),a1
                  moveq #0,d0

                  movep.w d0,$07(a0)
                  movep.l d0,$13(a0)
                  movep.l d0,$1b(a0)
                  move.b #$40,$17(a0)
                  move.l a1,$60.w
                  move.l a1,$68.w
                  move.l a1,$70.w
                  move.l a1,$80.w
                  move.l a1,$0110.w
                  move.l a1,$0114.w
                  move.l a1,$0118.w
                  move.l a1,$0120.w
                  move.l a1,$0134.w

                  rts
rte_rout:         rte

                ELSE

                  move.l (sp),return_adr

                  lea   stack,sp
                  lea   ustack,a0
                  move  a0,usp
                  bsr.s clear_bss
                  bsr.s flush_keyboard
                  bsr   main
exit2:            move  #$2700,sr
                  movea.l return_adr(pc),a0
                  jmp   (a0)

return_adr:     DS.L 1
                ENDC

clear_bss:        lea   start_bss,a0
                  move.l #end_bss-start_bss-1,d0
                  move.w d0,d1
                  lsr.l #4,d0
                  subq.w #1,d0
                  moveq #0,d2
cbss:             move.l d2,(a0)+
                  move.l d2,(a0)+
                  move.l d2,(a0)+
                  move.l d2,(a0)+
                  dbra  d0,cbss
                  and.w #$0f,d1
                  subq.w #1,d1
cbss2:            move.b d2,(a0)+
                  dbra  d1,cbss2
                  rts

flush_keyboard:   btst  #0,$fffffc00.w
                  beq.s no_flush
                  move.b $fffffc02.w,d0
                  bra.s flush_keyboard
no_flush:         rts

                ENDPART
                >PART 'text'
                DC.B "HIMOM IDEA BY SCAVENGER WITH SOME GOOD LAUGHS FROM RAPIDO......"
                DC.B "LITTLE SAMPLEREPLAY ROUTJE BY BATJE"
                DC.B "HIMOM RENDERING THINGY DONE IN GFABASIC (50 hours)"
                EVEN
                ENDPART

main:             bsr   init_screen
                  bsr.s init_sample
                  bsr   init_mfp
                  bsr   init_main_p
                  bsr   init_anim

                  clr.w vbl_flag
main_loop:        bsr   wvbl
                  bsr   anim_himom
                  bsr   switch_p
                  bsr   screen_switch
                  cmpi.b #57,$fffffc02.w
                  bne.s main_loop
                  rts

init_sample:    >PART
                  lea   sample1,a0
                  move.l a0,spl_ptr+2
                  move.l a0,spl_adr+2
                  lea   sample2,a0
                  move.l a0,spl_end_ptr+2

                  lea   spl_tab(pc),a0
                  move.w #256-1,d0
fixspl:           move.b 5(a0),6(a0)
                  addq.l #8,a0
                  dbra  d0,fixspl

                  move.l #$07077f7f,$ffff8800.w
                  rts
                ENDPART
spl_int:        >PART
                OPT O-

                  move.l a0,-(sp)
                  move.l d0,-(sp)

spl_ptr:          lea   spl_ptr,a0
                  moveq #0,d0
                  move.b (a0)+,d0
spl_end_ptr:      cmpa.l #spl_end_ptr,a0
                  bne.s sample_ok
spl_adr:          lea   spl_adr,a0
sample_ok:        move.l a0,spl_ptr+2

                  lea   $ffff8800.w,a0
                  lsl.w #3,d0
                  move.l spl_tab+4(pc,d0.w),(a0)
                  move.l spl_tab(pc,d0.w),d0
                  movep.l d0,0(a0)
exit_spl:         move.l (sp)+,d0
                  movea.l (sp)+,a0
                  rte

                OPT O+

spl_tab:        IBYTES 'IMPTAB2.BIN'

                ENDPART

init_screen:    >PART
                  move.l #raw_screen1+256,d0
                  move.l #raw_screen2+256,d1
                  clr.b d0
                  clr.b d1
                  move.l d0,screen1
                  move.l d1,screen2
                  lsr.w #8,d1
                  stop  #$2300
                  move.l d1,$ffff8200.w
                  move.b #2,$ffff820a.w
                  clr.b $ffff8260.w
                  stop  #$2300
                  rts
                ENDPART
init_mfp:       >PART
                  move  #$2700,sr
                  move.l #spl_int,$0134.w
                  move.l #vbl_rout,$70.w
                  move.l #trap0_rout,$80.w
                  move.l #hbi_r,$0120.w
                  ori.b #%100001,$fffffa07.w
                  ori.b #%100001,$fffffa13.w
                  clr.b $fffffa19.w
                  move.b #4,$fffffa1f.w
                  move.b #%100,$fffffa19.w
                  move  #$2300,sr
                  rts
                ENDPART
vbl_rout:       >PART
                  movem.l d0-d7,-(sp)
                  clr.b $fffffa1b.w
                  move.b #29,$fffffa21.w
                  move.b #8,$fffffa1b.w
                  movem.l pal2(pc),d0-d7
                  movem.l d0-d7,$ffff8240.w
                  addq.w #1,vbl_flag
                  movem.l (sp)+,d0-d7
                  rte
                ENDPART

hbi_r:          >PART 'hbi rout'

                  move  #$2700,sr
                  movem.l d0-d7,-(sp)
                  movem.l pal1(pc),d0-d7
                  move.b $fffffa21.w,hbi_0_0_1+3
hbi_0_0_1:        cmpi.b #1,$fffffa21.w
                  beq.s hbi_0_0_1
                  clr.b $fffffa1b.w
                  movem.l d0-d7,$ffff8240.w
                  movem.l (sp)+,d0-d7
                  rte
                ENDPART
trap0_rout:     >PART
                  rtr
                ENDPART

init_anim:      >PART 'init all animation pointers'

                  lea   redraw_b1,a0
                  clr.w (a0)
                  move.l a0,redraw_p1
                  lea   redraw_b2,a0
                  clr.w (a0)
                  move.l a0,redraw_p2
                  lea   anim_data,a0
                  move.l a0,cur_anim_p
                  rts
                ENDPART
draw_pic:       >PART 'draw picture'

*a0 pointer to picture
*a1 pointer to screen

                  movea.l redraw_p1,a2
                  move.w (a0)+,d0
                  move.w d0,(a2)+
                  bra.s draw_p_y_l_e
draw_p_y_l:       move.w (a0)+,d1
                  add.w (a0)+,d1
                  move.w d1,(a2)+
                  lea   0(a1,d1.w),a3
                  moveq #20,d2
                  sub.w (a0)+,d2
                  add.w d2,d2
                  add.w d2,d2
                  move.w d2,(a2)+
                  jmp   2(pc,d2.w)
draw_p_x_l:     REPT 20
                  move.l (a0)+,(a3)+
                  move.l (a0)+,(a3)+
                ENDR
draw_p_x_l_e:
draw_p_y_l_e:     dbra  d0,draw_p_y_l
                  rts

                ENDPART
init_main_p:    >PART 'init main picture'
                  movea.l screen1,a0
                  movea.l screen2,a1
                  lea   main_pic+34(pc),a2
                  move.w #8000-1,d0
init_main_p_l:    move.l (a2)+,d1
                  move.l d1,(a0)+
                  move.l d1,(a1)+
                  dbra  d0,init_main_p_l
                  rts

                ENDPART
draw_back:      >PART 'draw picture back'

*a0 pointer to screen
*a1 pointer to main picture

                  movea.l redraw_p1,a2
                  move.w (a2)+,d0
                  bra.s d_back_l_y_e
d_back_l_y:       move.w (a2)+,d1
                  lea   0(a0,d1.w),a3
                  lea   0(a1,d1.w),a4
                  move.w (a2)+,d2
                  jmp   2(pc,d2.w)
d_back_l_x:     REPT 20
                  move.l (a4)+,(a3)+
                  move.l (a4)+,(a3)+
                ENDR
d_back_l_x_e:
d_back_l_y_e:     dbra  d0,d_back_l_y
                  rts

                ENDPART

anim_himom:     >PART 'animate himom'
                  movea.l screen1,a0
                  lea   main_pic+34(pc),a1
                  bsr.s draw_back
                  movea.l cur_anim_p,a0
ani_himom_1:      move.l (a0)+,d0
                  bge.s ani_himom_2
                  lea   anim_data,a0
                  move.l a0,cur_anim_p
                  bra.s ani_himom_1
ani_himom_2:      move.l a0,cur_anim_p
                  movea.l d0,a0
                  movea.l screen1,a1
                  bsr   draw_pic
                  rts

                ENDPART
switch_p:       >PART 'switch pointers/buffers'
                  move.l redraw_p1,d0
                  move.l redraw_p2,redraw_p1
                  move.l d0,redraw_p2
                  rts
                ENDPART
screen_switch:  >PART
                  move.l screen1,d0
                  move.l screen2,screen1
                  move.l d0,screen2
                  lsr.w #8,d0
                  move.l d0,$ffff8200.w
                  rts
                ENDPART
wvbl:           >PART
                  move.w vbl_flag,d0
wait_vbl_l:       cmp.w vbl_flag,d0
                  beq.s wait_vbl_l
                  rts
                ENDPART

                DATA

                >PART 'new pal'

pal1:           DC.W 0
                DC.W $0607,$0507,$0407,$0307,$0207,$0107,$06,$05,$04,$03,$02
                DC.W $0602,$0601,$0600,$0500

                ENDPART
                >PART 'graphic data'

main_pic:       IBYTES 'BERGTIET.PI1'
p0:             IBYTES 'PIC0'
p2:             IBYTES 'PIC2'
p4:             IBYTES 'PIC4'
p6:             IBYTES 'PIC6'
p8:             IBYTES 'PIC8'
p10:            IBYTES 'PIC10'
p12:            IBYTES 'PIC12'
p14:            IBYTES 'PIC14'
p16:            IBYTES 'PIC16'
p18:            IBYTES 'PIC18'
p20:            IBYTES 'PIC20'
p22:            IBYTES 'PIC22'
p24:            IBYTES 'PIC24'
p26:            IBYTES 'PIC26'
p28:            IBYTES 'PIC28'
p30:            IBYTES 'PIC30'
p32:            IBYTES 'PIC32'
p34:            IBYTES 'PIC34'
p36:            IBYTES 'PIC36'
p38:            IBYTES 'PIC38'
p40:            IBYTES 'PIC40'
p42:            IBYTES 'PIC42'
p44:            IBYTES 'PIC44'
p46:            IBYTES 'PIC46'
p48:            IBYTES 'PIC48'
p50:            IBYTES 'PIC50'
pal2            EQU main_pic+2

                ENDPART
                >PART 'animate data'

anim_data:      DC.L p0
                DC.L p2
                DC.L p4
                DC.L p6
                DC.L p8
                DC.L p10
                DC.L p12
                DC.L p14
                DC.L p16
                DC.L p18
                DC.L p20
                DC.L p22
                DC.L p24
                DC.L p26
                DC.L p28
                DC.L p30
                DC.L p32
                DC.L p34
                DC.L p36
                DC.L p38
                DC.L p40
                DC.L p42
                DC.L p44
                DC.L p46
                DC.L p48
                DC.L p50

                DC.L p48
                DC.L p46
                DC.L p44
                DC.L p42
                DC.L p40
                DC.L p38
                DC.L p36
                DC.L p34
                DC.L p32
                DC.L p30
                DC.L p28
                DC.L p26
                DC.L p24
                DC.L p22
                DC.L p20
                DC.L p18
                DC.L p16
                DC.L p14
                DC.L p12
                DC.L p10
                DC.L p8
                DC.L p6
                DC.L p4
                DC.L p2
                DC.L -1

                ENDPART
                >PART 'samples'

sample1:        IBYTES 'INTRO.SPL'
sample2:
                EVEN
                ENDPART

                BSS

                >PART 'init'
old_regs:       DS.B 1024
                DS.B 1024*2
stack:          DS.L 1
                DS.B 1024*2
ustack:         DS.L 1
                DS.B 1024
                ENDPART
start_bss:      >PART 'shit'
vbl_flag:       DS.W 1
                ENDPART
                >PART 'pals'

pa1:            DS.W 16
pa2:            DS.W 16

                ENDPART
                >PART 'buffers'

redraw_p1:      DS.L 1
redraw_p2:      DS.L 1

redraw_b1:      DS.L 200
redraw_b2:      DS.L 200

cur_anim_p:     DS.L 1

                ENDPART
                >PART 'screens'

screen1:        DS.L 1
screen2:        DS.L 1

raw_screen1:    DS.B 32000+256
raw_screen2:    DS.B 32000+256

                ENDPART
end_bss:
                END




                END
