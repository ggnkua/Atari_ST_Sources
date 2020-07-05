
                PART 'constants'
                PATH 'F:\RAPIDO\HIMOM\BINARY\'
system          EQU 1

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

main:             bsr   decrypt_mod
                  bsr   init_sample
                  bsr   init_anim
                  bsr.s fade_out
                  bsr   init_screen
                  bsr   init_main_p
                  bsr   init_mfp

                  move.w #1,fade_flag
                  clr.w vbl_flag
main_loop:        bsr   wvbl
                  bsr   anim_himom
                  bsr   switch_p
                  bsr   screen_switch
                  bsr   sample_fader
                  bra.s main_loop

fade_out:       >PART
                  movem.l $ffff8240.w,d0-d7
                  movem.l d0-d7,start_up_pal

                  lea   start_up_pal(pc),a0
                  move.l #$07770777,d0
                  moveq #8-1,d1
fo_loop1:         and.l d0,(a0)+
                  dbra  d1,fo_loop1

                  move.l #start_up_block,fade_block
                  moveq #16-1,d0
fo_loop2:         move.l d0,-(sp)
                  bsr   fader
                  move.l (sp)+,d0
                  stop  #$2300
                  movem.l current_pal(pc),d1-a0
                  movem.l d1-a0,$ffff8240.w
                  dbra  d0,fo_loop2
                  stop  #$2300
                  rts

fade_block:     DS.L 1
start_up_pal:   DS.W 16
current_pal:    DS.W 16
zero_pal:       DS.W 16
pal1_f:         DS.W 16
pal2_f:         DS.W 16

start_up_block: DC.L start_up_pal
                DC.L zero_pal
                DC.L current_pal
                DC.W 0
                DC.W 16-1

                ENDPART
colour_fade:    >PART
                  move.l #fadein_block,fade_block
                  bsr.s fader
                  move.l #fadein_block2,fade_block
                  bsr.s fader
                  rts

fade_switch:      lea   fadein_block(pc),a0
                  lea   fadein_block2(pc),a1
                  move.l #pal2,(a0)
                  move.l #pal1,(a1)
                  move.l #zero_pal,4(a0)
                  move.l #zero_pal,4(a1)
                  rts

fadein_block:   DC.L zero_pal
                DC.L pal2
                DC.L pal2_f
                DC.W 0
                DC.W 16-1

fadein_block2:  DC.L zero_pal
                DC.L pal1
                DC.L pal1_f
                DC.W 0
                DC.W 16-1

                ENDPART
fader:          >PART
* Gradient Fader
* Allways fades in 16 parts
*
* Use:  L:fade_block = pointer to FadeStruct
*
* FadeStruct:  +0  .L = source palette
*              +4  .L = destination palette
*              +8  .L = fading palette
*              +12 .W = fade gradient
*              +14 .W = number of colors to fade - 1

                  movem.l d0-a6,-(sp)
                  movea.l fade_block(pc),a6
                  tst.l 4(a6)
                  beq   no_fader

                  movem.l (a6),a0-a2

                  move.w 12(a6),d7
                  move.w 14(a6),d6

col_loop:         move.w (a0)+,d0
                  move.w (a1)+,d1
                  move.w d0,d2
                  move.w d1,d3
                  move.w #$0777,d4
                  and.w d4,d0
                  and.w d4,d1
                  not.w d4
                  and.w d4,d2
                  and.w d4,d3
                  add.w d0,d0
                  add.w d1,d1
                  lsr.w #3,d2
                  lsr.w #3,d3
                  or.w  d2,d0
                  or.w  d3,d1

                  move.w d0,d2          ;copy dest color
                  move.w d1,d3          ;copy source color
                  lsr.w #8,d2           ;get R dest value
                  lsr.w #8,d3           ;get R source value
                  sub.w d2,d3           ;R source - R dest
                  muls  d7,d3           ;$00-$f0 ;signed => two way fade
                  moveq #0,d5           ;
                  move.b d3,d5          ;copy new col
                  lsl.w #4,d5           ;shift in R position
                  add.w d0,d5           ;add R dest value

                  move.w d0,d2          ;copy dest color
                  move.w d1,d3          ;copy source color
                  lsr.w #4,d2           ;get G dest value
                  lsr.w #4,d3           ;get G source value
                  moveq #$0f,d4         ;mask for G value
                  and.w d4,d2           ;mask out R dest value
                  and.w d4,d3           ;mask out R source value
                  sub.w d2,d3           ;G source - G dest
                  muls  d7,d3           ;0-$f0
                  move.b d3,d5          ;G position
                  add.b d0,d5           ;add G dest value

                  and.w d4,d0           ;mask out B dest value
                  and.w d4,d1           ;mask out B source value
                  sub.w d0,d1           ;B source - B dest
                  muls  d7,d1           ;0-$f0
                  lsr.w #4,d1           ;chop off floating point
                  add.w d0,d1           ;add B dest value

                  and.w d4,d1           ;only B dest value
                  not.w d4              ;invert mask
                  and.w d4,d5           ;chop off old B dest value
                  or.w  d1,d5           ;insert new B dest value

                  move.w d5,d4          ;copy new color
                  and.w #$0eee,d5       ;chop off lower bits each value
                  eor.b d5,d4           ;generate only lower bits
                  lsr.w #1,d5           ;shift RGB into correct place
                  lsl.w #3,d4           ;shift STE bits into 4th bit place
                  or.w  d4,d5           ;mix them
                  move.w d5,(a2)+       ;into color register
                  dbra  d6,col_loop

                  addq.w #1,12(a6)
                  cmpi.w #16+1,12(a6)
                  bne.s no_fader
                  move.w #1,12(a6)
                  clr.l 4(a6)
no_fader:         movem.l (sp)+,d0-a6
                  rts

                ENDPART
decrypt_mod:    >PART
                  lea   sample1,a0
                  move.l #sample2-sample1-1,d2
                  move.b (a0)+,d0
mod_loop:         move.b (a0),d1
                  sub.b d1,d0
                  move.b d0,(a0)+
                  subq.l #1,d2
                  bne.s mod_loop
                  rts
                ENDPART

init_sample:    >PART
                  lea   sample1,a0
                  lea   sample2,a1
                  move.l a0,spl_ptr+2

                  move.l #sample2-sample1,d0
copy_sample:      move.b (a0)+,(a1)+
                  subq.l #1,d0
                  bne.s copy_sample

                  lea   spl_tab,a0
                  move.w #256-1,d0
fixspl:           move.b 5(a0),6(a0)
                  addq.l #8,a0
                  dbra  d0,fixspl

                  lea   spl_tab,a0
                  lea   spl_tab2,a1
                  lea   spl_tab_ptrs,a2
                  lea   spl_tab_fades(pc),a3
                  moveq #0,d7
                  moveq #15-1,d0
spl_loop2:        move.l a0,(a2)+
                  move.w #256-1,d1
spl_loop1:        move.b (a0)+,(a1)+
                  move.b (a0)+,d7
                  move.b 0(a3,d7.w),(a1)+
                  move.b (a0)+,(a1)+
                  move.b (a0)+,d7
                  move.b 0(a3,d7.w),(a1)+
                  move.w (a0)+,(a1)+
                  move.b (a0)+,d7
                  move.b 0(a3,d7.w),(a1)+
                  move.b (a0)+,(a1)+
                  dbra  d1,spl_loop1
                  dbra  d0,spl_loop2

                  move.l -4(a2),spl_tab_ptr
                  move.l a2,fade_ptr

                  move.l #$07077f7f,$ffff8800.w
                  rts

spl_tab_fades:  DC.B 0,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14
                ENDPART
spl_int:        >PART
                OPT O-

                  movem.l d0/a0-a1,-(sp)

spl_ptr:          lea   spl_ptr,a0
                  moveq #0,d0
                  move.b (a0)+,d0
                  move.l a0,spl_ptr+2

                  lea   $ffff8800.w,a0
                  movea.l spl_tab_ptr(pc),a1
                  lsl.w #3,d0
                  move.l 4(a1,d0.w),(a0)
                  move.l 0(a1,d0.w),d0
                  movep.l d0,0(a0)
exit_spl:         movem.l (sp)+,d0/a0-a1
                  rte

                OPT O+
spl_tab_ptr:    DC.L spl_tab


                ENDPART
sample_fader:   >PART
                  move.w fade_flag(pc),d0
                  add.w d0,d0
                  add.w d0,d0
                  movea.l fade_list(pc,d0.w),a0
                  jmp   (a0)

fade_flag:      DC.W 0
fade_delay:     DC.W 10

fade_list:      DC.L sample_fade_wait
                DC.L sample_fade_in
                DC.L sample_fade_out
                DC.L himom_done

sample_fade_wait: cmpi.w #2,sample_loop_ctr
                  blt.s sample_ok2
                  bsr   fade_switch
                  move.w #2,fade_flag
sample_ok2:       rts

sample_fade_in:   subq.w #1,fade_delay
                  bne.s sample_ok3
                  move.w #10,fade_delay
                  movea.l fade_ptr,a0
                  cmpa.l #spl_tab_ptrs,a0
                  beq.s fade_in_done
                  subq.l #4,a0
                  move.l (a0),spl_tab_ptr
                  move.l a0,fade_ptr
sample_ok3:       bsr   colour_fade
                  rts

sample_fade_out:  subq.w #1,fade_delay
                  bne.s sample_ok4
                  move.w #10,fade_delay
                  movea.l fade_ptr,a0
                  cmpa.l #spl_tab_ptrs+14*4,a0
                  beq.s fade_out_done
                  addq.l #4,a0
                  move.l (a0),spl_tab_ptr
                  move.l a0,fade_ptr
sample_ok4:       bsr   colour_fade
                  rts

fade_out_done:    move.w #3,fade_flag
                  rts

fade_in_done:     clr.w fade_flag
                  rts

himom_done:
                  clr.b $fffffa07.w
                  clr.b $fffffa13.w
                  move.l #$08080000,$ffff8800.w
                  move.l #$09090000,$ffff8800.w
                  move.l #$0a0a0000,$ffff8800.w
                  addq.l #4,sp
                  rts
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
                  movem.l d0-a0,-(sp)

                  clr.b $fffffa1b.w
                  move.b #29,$fffffa21.w
                  move.b #8,$fffffa1b.w
                  movem.l pal2_f(pc),d0-d7
                  movem.l d0-d7,$ffff8240.w
                  addq.w #1,vbl_flag

                  move  #$2700,sr
                  movea.l spl_ptr+2(pc),a0
                  cmpa.l #sample2,a0
                  blt.s sample_ok
                  subi.l #sample2-sample1,spl_ptr+2
                  addq.w #1,sample_loop_ctr
sample_ok:
                  movem.l (sp)+,d0-a0
                  rte

sample_loop_ctr:DS.W 1
                ENDPART

hbi_r:          >PART 'hbi rout'

                  move  #$2700,sr
                  movem.l d0-d7,-(sp)
                  movem.l pal1_f(pc),d0-d7
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
                >PART 'sample player'
spl_tab:        IBYTES 'IMPTAB2.BIN'
spl_tab2:       DS.B 256*8*15
                ENDPART
                >PART 'samples'

sample1:        IBYTES 'INTRO.BAT'
sample2:
                DS.W (sample2-sample1)/2
sample3:
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
                >PART 'sample player'
fade_ptr:       DS.L 1
spl_tab_ptrs:   DS.L 16
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
