  
; BELANGRIJK !!!!
; Eerst debugger inladen, resident halten, Turbo inladen...
; (De debugger moet laag in het geheugen!)
;
; Bij mijn machine de debugger in de autofolder gooien zodat de ook als eerste
; wordt ingeladen.

*
* 3-DDDemo by RAPIDO from SYNERGY.
* Initial date    01-02-1992.
* Finishing date  25-08-1993.
*

computer        EQU 1           ;(x -> (x-1) megabytes)
object_nr       EQU 0

music           EQU 0


                >PART 'stucture remarks'

;
;               Object = RECORD
;                       init      := *ASSEMBLY
;                       do        := *ASSEMBLY
;                       x_points  := *Points
;                       y_points  := *Points
;                       z_point   := *Points
;                       3_points  := *3d_p
;                       total_l_nr:= WORD
;                       p_plane   := *Planes
;                       p_lines   := *Lines_s
;
;               END
;
;               Points = RECORD
;                       nr_points := WORD
;                       points    := ARRAY nr_points OF WORD
;               END
;
;               3d_p   = RECORD
;                       rot_orig  := WORD
;                       nr_points := WORD
;                       xyz       := ARRAY nr_points OF Xyz_ind
;               END
;
;               Xyz_ind= RECORD
;                       x_ind     := WORD
;                       y_ind     := WORD
;                       z_ind     := WORD
;               END
;
;               Lines_s = RECORD
;                       nr_l_seq  := WORD
;                       lines_seq := ARRAY nr_l_seq OF *Line_s
;               END
;
;
;               Line_s = RECORD
;                       l_ident   := WORD
;                       hide_flag := WORD
;                       check_lin := WORD
;                       color     := WORD
;                       nor_sub   := *ASSEMBLY
;                       rev_sub   := *ASSEMBLY
;                       i_out_v1  := LONG
;                       i_out_v2  := LONG
;                       nr_line_l := WORD
;                       lines     := ARRAY nr_line_l OF Line_p
;               END
;
;               Line_p = RECORD
;                       pen_u_d_q := WORD
;                       point_ind := WORD
;                       line_ind  := WORD
;               END
;
;               Planes = RECORD
;                       nr_planes := WORD
;                       planes    := ARRAY nr_planes OF *Plane
;               END
;
;               Plane  = RECORD
;                       pl_ident  := WORD
;                       delta_flag:= WORD
;                       hide_flag := WORD
;                       color     := WORD
;                       nor_sub   := *ASSEMBLY
;                       rev_sub   := *ASSEMBLY
;                       i_out_v1  := LONG
;                       i_out_v2  := LONG
;                       nr_plane_l:= WORD
;                       i_plane_l := ARRAY nr_plane_l OF Plane_p
;               END
;
;               Plane_p= RECORD
;                       point_ind := WORD
;                       line_ind  := WORD
;               END
;
;               Scan_pl= RECORD
;                       plane_nr  := WORD
;                       delta_fl  := WORD
;                       color     := WORD
;                       min_y     := WORD
;                       max_y     := WORD
;                       left_p    := *Scan_p
;                       right_p   := *Scan_p
;                       swap      := WORD
;               END
;
;               Scan_li= RECORD
;                       line_id   := WORD
;                       color     := WORD
;                       lines     := *Sc_li
;               END
;
;               Sc_li  = RECORD
;                       no_lines  := WORD
;                       line_i    := ARRAY no_lines OF ind_count
;               END
;
;               Scan_p = RECORD
;                       no_piece  := WORD
;                       piece_i   := ARRAY nr_piece OF ind_count
;               END
;
;               P_done = RECORD
;                       ind_count := WORD
;                       pieces    := ARRAY OF P_piece
;               END
;
;               P_piece = RECORD
;                       nr_h_line := WORD
;                       start_x   := WORD
;                       fraction  := LONG
;                       start_f   := WORD
;               END
;
;               L_Piece = RECORD
;                       l_points := ARRAY OF L_points
;               END
;
;               L_points= RECORD
;                       pen_u_d_q:= WORD
;                       x_coord  := WORD
;                       y_coord  := WORD
;               END
;
;               Line_f = RECORD
;                       nr_lines  := WORD
;                       lines_d   := ARRAY nr_lines OF Done
;               END
;
;               Done   = RECORD
;                       flag      := WORD
;                       piece_i   := ind_count
;               END
;
                ENDPART
                >PART 'constants'

comp_off        EQU $100000*computer

mid_x           EQU 160
mid_y           EQU 100
min_x           EQU 0
max_x           EQU 320
min_y           EQU 0
max_y           EQU 200

max_v           EQU 20
max_p           EQU 100
max_l           EQU 100
max_c           EQU 100
period          EQU 2048
rip_len         EQU 360*2

max_scan        EQU 400
max_lin         EQU 400
no_screens      EQU 2

frame_size_1    EQU 3000
frame_size_2    EQU 1000
frame_off       EQU no_screens*8
max_code        EQU 136

clip_space      EQU 1000
clip_o          EQU clip_space*8

screen_size     EQU 160*200
height          EQU max_y
width_w         EQU max_x/16

no_multi        EQU 4

                ENDPART

start:            jsr   go_super
                  move  #$2700,sr
                  lea   stack,sp
                  move  usp,a0
                  move.l a0,old_user
                  lea   user_stack,a0
                  move  a0,usp
                  jsr   save_regs
                  jsr   clear_regs
                  jsr   flush_keyboard
                  jsr   main
                  jsr   clear_regs
                  jsr   rest_regs

                  jsr   flush_keyboard
                  movea.l old_user,a0
                  move  a0,usp
                  jmp   go_user

                >PART 'tekstje'

                DC.B 'Hi there honourable hackers... this is the 3d part made by RAPIDO '
                DC.B 'from SYNERGY...   '
                DC.B 'Can you imagine to have a period in 3d space ?... No ? ..  Just '
                DC.B ' imagine red blobs flying around in 3d space without gravity pull !'
                DC.B ' (I like colors to be red you see.. ) But now for something completely different..  '
                DC.B ' If you can hack this and make your own object in it'
                DC.B ' (not the ones included) please send it to me because then I know'
                DC.B ' a good hacker when I see one!!!! (Price: The whole 3d source! ).    This demo took 1.5 years of my life'
                DC.B ' and its a good thing you can read this because it was not sure if it'
                DC.B ' would be finished (due to the perfectionist that we are.'
                DC.B ' Now to some little technical details.. The polygon routs are'
                DC.B ' totally not useful in any game because they are DELTA POLYGONS.'
                DC.B ' (Yeah you probably thought about it but disgarded it as being too '
                DC.B ' slow to calculate the whole lot. )'
                DC.B ' Although the main speed is due to delta polygons I (or the computer?)'
                DC.B ' also use some other tricks (try to find one or two of them when pressing '
                DC.B ' HELP during the demo!!) One of them is Realtime Precalcing '
                DC.B ' (What the fuck is that I hear you cry..). When you have '
                DC.B ' time left in a vbl just use this time to calculate the next frames '
                DC.B ' (much better then having 4 or 8 screens which you can consider '
                DC.B ' as being the same trick) '
                DC.B ' Back to the hacking stuff. '
                DC.B ' I don not think you can really single step this baby because '
                DC.B ' the main rout calculates and the vbl draws the polygons.'
                DC.B ' And keeping in mind that the delta routine is very weird '
                DC.B ' if only to look at, you might consider not to hack this '
                DC.B ' code. '
                DC.B ' (You did not believe any of this shit? Well... what the hEck!! '
                DC.B '                                                                   '
                DC.B '(LAST DELTA OPTIMIZATION MADE IN THE LAST WEEK (+- 10 CLOCKS !!)'
                DC.B 'See if you can find more optimizations (write me if you have any!)'
                DC.B '(there are four clocks left in the vertical texture map routine '
                DC.B ' in the main menu (try to find it)'
                DC.B ' My address: Vijverdreef 227 2724GL(Zip code) Zoetermeer Holland'
                DC.B ' Write to Robbert van Dalen alias RAPIDO'
                DC.B '                                        '
                DC.B ' (Psst... did you know me dx>dy line routine can be faster too?) '
                DC.B '           DAMN IT !      Well.... '
                DC.B ' I am not going to do any 3d in the near future because I thought '
                DC.B ' of very fast gouraud/phong-shading and real texture mapping '
                DC.B ' but already reached a bottle neck in true color.. '
                DC.B ' Using scanline algoritms to calculate what to draw and what not '
                DC.B ' using the DSP in parallel with the 68030 (which is doing the drawing stuff) '
                DC.B ' I think it is not a real kick to do it.. '
                DC.B ' (Although you can get 25 hz complex worlds with polygons and gouraud..)'
                DC.B ' No, in the near future I will concentrate on genetic algoritms'
                DC.B ' and genetic code because I think this is a totally awesome concept. '
                DC.B ' I think of doing some kind of implicit languange of some kind.  '
                DC.B ' Well I personally think that this code is pretty fit and maybe you '
                DC.B ' will see more code of me generated by my selfmade compiler.. '
                DC.B ' Love you all... RAPIDO ------ RAP RAP RAP RAP RRAPHIIIIIIDOOOOO ------'
                DC.B '                                              '
                DC.B ' Got some space left... (Actually about 1000 bytes!!) '
                DC.B ' I had to ram this baby into 1024 K and still make it work !'
                DC.B ' Pheew !  The music takes 140 K. The program itself about'
                DC.B ' 8 K and the precoded code about 700 K, and the rest, well'
                DC.B ' suppose you have got your maths straight, it should come'
                DC.B ' down to 160 K of tables and two screens....  '
                DC.B ' I you like the music SCAVY made, don not hesitate to contact'
                DC.B ' us, even though the ST day are over now...'
                DC.B ' And please contact us if you think we did a great job'
                DC.B ' (Even when you think it is too late..). You would really'
                DC.B ' cheer us up to do other stuff on the FALCON or PC...'

                EVEN

                ENDPART
                >PART 'music'
music_play:     IFEQ music
                IBYTES 'SCAV_RAP.MUS'

                ENDC
                EVEN
music_flag:     DS.W 1
                ENDPART


fade_tab:       IBYTES 'ALL2.INL'
font:           IBYTES '3D_FONT.BIN'

go_super:       >PART
                  clr.l -(sp)
                  move.w #32,-(sp)
                  trap  #1
                  addq.l #6,sp
                  move.l d0,go_user+2
                  rts
                ENDPART
go_user:        >PART
                  pea   0
                  move.w #32,-(sp)
                  trap  #1
                  addq.l #6,sp
                  clr.w -(sp)
                  trap  #1
                ENDPART
trap0_rout:     >PART
                  move.w #$2300,(sp)
                  rte
                ENDPART
save_regs:      >PART
                  lea   screen_store(pc),a0
                  move.l $ffff8200.w,(a0)+
                  move.b $ffff820a.w,(a0)+
                  move.b $ffff8260.w,(a0)+
                  movem.l $ffff8240.w,d0-d7
                  movem.l d0-d7,(a0)

                  lea   mfp_store(pc),a0
                  lea   $fffffa00.w,a1
                  movep.w $07(a1),d0
                  movep.l $13(a1),d1
                  movep.l $1b(a1),d2
                  move.w d0,(a0)+
                  move.l d1,(a0)+
                  move.l d2,(a0)+
                  move.l $68.w,(a0)+
                  move.l $70.w,(a0)+
                  move.l $0110.w,(a0)+
                  move.l $0114.w,(a0)+
                  move.l $0118.w,(a0)+
                  move.l $0120.w,(a0)+
                  move.l $0134.w,(a0)+

                  rts
                ENDPART
rest_regs:      >PART
                  lea   screen_store(pc),a0
                  stop  #$2300
                  move.l (a0)+,$ffff8200.w
                  move.b (a0)+,$ffff820a.w
                  move.b (a0)+,$ffff8260.w
                  stop  #$2300
                  movem.l (a0),d0-d7
                  movem.l d0-d7,$ffff8240.w

                  move  #$2700,sr
                  lea   mfp_store(pc),a0
                  lea   $fffffa00.w,a1
                  move.w (a0)+,d0
                  move.l (a0)+,d1
                  move.l (a0)+,d2
                  movep.w d0,$07(a1)
                  movep.l d1,$13(a1)
                  movep.l d2,$1b(a1)
                  move.l (a0)+,$68.w
                  move.l (a0)+,$70.w
                  move.l (a0)+,$0110.w
                  move.l (a0)+,$0114.w
                  move.l (a0)+,$0118.w
                  move.l (a0)+,$0120.w
                  move.l (a0)+,$0134.w

                  rts
                ENDPART
clear_regs:     >PART
                  move  #$2700,sr
                  lea   rte_rout(pc),a0
                  lea   $fffffa00.w,a1
                  moveq #0,d0
                  movep.w d0,$07(a1)
                  movep.l d0,$13(a1)
                  movep.l d0,$1b(a1)
                  move.b #$40,$17(a1)
                  move.l a0,$68.w
                  move.l a0,$70.w
                  move.l a0,$0110.w
                  move.l a0,$0114.w
                  move.l a0,$0118.w
                  move.l a0,$0120.w
                  move.l a0,$0134.w

                  rts
rte_rout:         rte
                ENDPART
flush_keyboard: >PART
                  btst  #0,$fffffc00.w
                  beq.s no_flush
                  move.b $fffffc02.w,d0
                  bra.s flush_keyboard
no_flush:         rts
                ENDPART
swap_flexible:  >PART

                  move.w vbl_flag(pc),d0
                  beq.s flex_wait_2
                  cmp.w #1,d0
                  bne.s flex_wait

flex_sync:        lea   $ffff8203.w,a0
                  movep.l 0(a0),d1
                  and.l #$ffffff,d1
                  move.l screen1,d0
                  cmp.l d0,d1
                  ble.s no_wait
flex_wait:        clr.w vbl_flag
flex_wait_2:      tst.w vbl_flag
                  beq.s flex_wait_2
no_wait:          move.l screen2,d0
                  move.l screen1,screen2
                  move.l d0,screen1
                  lsr.w #8,d0
                  move.l d0,$ffff8200.w
                  clr.w vbl_flag
                  rts

                ENDPART

****************************       SEA OBJECT      *******************************

                >PART 'sea tables'

kwal_y          EQU 8192/4-500


sea_table:      DC.W 130
                DC.L kwal4
                DC.W 0
                DC.W 9000,-2000,1500
                DC.W 300,kwal_y,0
                DC.W 0,0,0

                DC.W 150
                DC.L kwal3
                DC.W 1
                DC.W 9000,-2500,1600
                DC.W 300,kwal_y,0
                DC.W 0,0,0

                DC.W 160
                DC.L kwal2
                DC.W 2
                DC.W 8000,-1000,1200
                DC.W 300,kwal_y,0
                DC.W 0,0,0

                DC.W 200
                DC.L kwal4
                DC.W 0
                DC.W 8000,-4000,1400
                DC.W 300,kwal_y,0
                DC.W 0,0,0

                DC.W 115
                DC.L kwal3
                DC.W 1
                DC.W 5000,-1000,600
                DC.W 300,kwal_y,0
                DC.W 0,0,0

                DC.W 155
                DC.L kwal2
                DC.W 2
                DC.W 9000,-2000,1600
                DC.W 300,kwal_y,0
                DC.W 0,0,0

                DC.W 140
                DC.L kwal1
                DC.W 3
                DC.W 9000,-4000,1600
                DC.W 300,kwal_y,0
                DC.W 0,0,0

                DC.W 0
                DC.L 0
                DC.W 1
                DC.W 0,0,0
                DC.W 0,0,0
                DC.W 0,0,0
;8
                DC.W 140
                DC.L kwal4
                DC.W 0
                DC.W 8000,-1000,1400
                DC.W 300,kwal_y,0
                DC.W 0,0,0
;9
                DC.W 170
                DC.L kwal3
                DC.W 1
                DC.W 9000,-1500,1500
                DC.W 300,kwal_y,0
                DC.W 0,0,0

                DC.W 140
                DC.L kwal2
                DC.W 2
                DC.W 9000,-3000,1400
                DC.W 300,kwal_y,0
                DC.W 0,0,0

                DC.W 180
                DC.L kwal4
                DC.W 0
                DC.W 9000,-2000,1300
                DC.W 300,kwal_y,0
                DC.W 0,0,0

                DC.W 150
                DC.L kwal3
                DC.W 1
                DC.W 9000,-3000,1200
                DC.W 300,kwal_y,0
                DC.W 0,0,0

                DC.W 70
                DC.L 0
                DC.W 2
                DC.W 0,0,0
                DC.W 0,0,0
                DC.W 0,0,0
;13
                DC.W 200
                DC.L kwal1
                DC.W 3
                DC.W 10000,-2000,1800
                DC.W 400,kwal_y,0
                DC.W 0,0,0

                DC.W 0
                DC.L 0
                DC.W 0
                DC.W 0,0,0
                DC.W 0,0,0
                DC.W 0,0,0

                DC.W 200
                DC.L 0
                DC.W 1
                DC.W 0,0,0
                DC.W 0,0,0
                DC.W 0,0,0

                DC.W 100
                DC.L 0
                DC.W 3
                DC.W 0,0,0
                DC.W 0,0,0
                DC.W 0,0,0

                DC.W 40
                DC.L kwal2
                DC.W 0
                DC.W 0,5000,1000
                DC.W -8192/4,8192/2,0
                DC.W 0,0,0

                DC.W 100
                DC.L kwal3
                DC.W 1
                DC.W 8000,0,1000
                DC.W 0,8192/4,0
                DC.W 0,0,0

                DC.W 250
                DC.L kwal4
                DC.W 2
                DC.W -5000,-5000,1000
                DC.W 8192/8,-8192/4,0
                DC.W 0,0,0

                DC.W 0
                DC.L kwal1
                DC.W 3
                DC.W 8000,8000,1900
                DC.W -8192/8,8192/4,0
                DC.W 0,0,0

                DC.W 400
                DC.L kwal2
                DC.W 0
                DC.W 0,-7000,1900
                DC.W 600,8192/4,0
                DC.W 0,-15,0

                DC.W 0
                DC.L 0
                DC.W 3
                DC.W 0,0,0
                DC.W 0,0,0
                DC.W 0,0,0

                DC.W 400
                DC.L kwal3
                DC.W 1
                DC.W 0,-7000,1900
                DC.W 600,8192/4,0
                DC.W 0,-15,0

                DC.W 1
                DC.L kwal1
                DC.W 3
                DC.W 8000,-8000,1900
                DC.W 8192/8,8192/4,0
                DC.W 0,0,0

                DC.W 400
                DC.L kwal4
                DC.W 2
                DC.W 0,-7000,1900
                DC.W 600,8192/4,0
                DC.W 0,-15,0


                DC.W 400
                DC.L kwal2
                DC.W 0
                DC.W 0,-7000,1900
                DC.W 600,8192/4,0
                DC.W 0,-15,0

                DC.W 400
                DC.L kwal3
                DC.W 1
                DC.W 0,-7000,1900
                DC.W 600,8192/4,0
                DC.W 0,-15,0

                DC.W 1000
                DC.L kwal4
                DC.W 2
                DC.W 0,-7000,1900
                DC.W 600,8192/4,0
                DC.W 0,-15,0

                DC.W -1


                ENDPART
                >PART 'kwal'

                BASE DC.W,kwal1

kwal1:          DC.W init_kwal
                DC.W do_kwal
                DC.W kwal_x_p
                DC.W kwal_y_p
                DC.W kwal_z_p
                DC.W kwal_3_p
                DC.W 1
                DC.W kwal_p_p
                DC.W kwal_l_p

init_kwal:        movea.w #kwal_anim-kwal1,a0
                  move.w #17,-(sp)
                  trap  #15
                  addq.l #2,sp
                  rts

kwal_x_p:       DC.W 0
                DC.W 2,115,277

kwal_y_p:       DC.W 0
                DC.W 2,-115,-277

kwal_z_p:       DC.W 150
                DC.W 1,-300

kwal_3_p:       DC.W 9
                DC.W -12,24,0
                DC.W 12,24,0
                DC.W 24,12,0
                DC.W 24,-12,0
                DC.W 12,-24,0
                DC.W -12,-24,0
                DC.W -24,-12,0
                DC.W -24,12,0
                DC.W 0,0,12

kwal_l_p:       DC.W 0

kwal_p_p:       DC.W 4
                DC.W kwal_p_1
                DC.W kwal_p_2
                DC.W kwal_p_3
                DC.W kwal_p_4

kwal_p_1:       DC.W 1
                DC.W 0
                DC.W 1
                DC.W 0
                DC.W kwal_p_nor
                DC.W kwal_p_rev
                DC.W 32,0
                DC.W 0,4
                DC.W 3
                DC.W 0,-1,4,-1,32,-1

kwal_p_2:       DC.W 2
                DC.W 0
                DC.W 1
                DC.W 0
                DC.W kwal_p_nor
                DC.W kwal_p_rev
                DC.W 32,8
                DC.W 8,12
                DC.W 3
                DC.W 8,-1,12,-1,32,-1

kwal_p_3:       DC.W 3
                DC.W 0
                DC.W 1
                DC.W 0
                DC.W kwal_p_nor
                DC.W kwal_p_rev
                DC.W 32,16
                DC.W 16,20
                DC.W 3
                DC.W 16,-1,20,-1,32,-1

kwal_p_4:       DC.W 4
                DC.W 0
                DC.W 1
                DC.W 0
                DC.W kwal_p_nor
                DC.W kwal_p_rev
                DC.W 32,24
                DC.W 24,28
                DC.W 3
                DC.W 24,-1,28,-1,32,-1

kwal_p_nor:       move.w #4,6(a0)
                  rts
kwal_p_rev:       move.w #6,6(a0)
                  rts

k_b1            EQU $24
k_b2            EQU $25
k_c1            EQU $0600
k_c2            EQU $0300
k_c3            EQU $60
k_c4            EQU $30


do_kwal:          move.w #k_b1,(a5)+
                  move.w #k_c1,d1
                  move.w #k_c2,d2
                  move.w #k_c3,d3
                  move.w #k_c4,d4
                  move.w d2,(a5)+
                  move.w d1,(a5)+
                  move.w d3,(a5)+
                  move.w d1,(a5)+
                  move.w d2,(a5)+
                  move.w d1,(a5)+
                  move.w d4,(a5)+
                  move.w d1,(a5)+
                  move.w d2,(a5)+
                  move.w d1,(a5)+
                  move.w d3,(a5)+
                  move.w d1,(a5)+
                  move.w d2,(a5)+
                  move.w d1,(a5)+
                  move.w #k_b2,(a5)+
                  move.w #18,-(sp)
                  trap  #15
                  addq.l #2,sp
                  rts

kwal_anim:      DC.W 0
                DC.W kwal_1
                DC.W 10000
                DC.W kwal_2
                DC.W -1

kwal_0:           rts

kwal_1:           lea   kwal_p(pc),a0
                  move.w #1,(a0)+
                  clr.l (a0)+
                  move.w #(8192*3)/4+1200,(a0)
                  lea   swim_p(pc),a0
                  move.w #0,(a0)+
                  clr.w (a0)+
                  bsr   swim_start
                  rts

kwal_2:           lea   kwal_p(pc),a0
                  lea   swim_p(pc),a1
                  tst.w (a0)+
                  bmi.s kwal_2_1
                  beq.s kwal_2_2
                  addi.w #4*4,4(a0)
                  subq.w #1,(a0)
                  bge.s kwal_e
                  move.w #-1,-2(a0)
                  move.w #44,(a0)+
                  clr.w (a0)
                  bra.s kwal_2
kwal_2_1:         addi.w #4,2(a0)
                  subq.w #1,(a0)
                  bge.s kwal_e
                  clr.w -2(a0)
                  move.w #22,(a0)+
                  move.w (a0),d0
                  add.w d0,(a0)+
                  addi.w #136,(a0)
                  move.w #800,(a1)
                  bra.s kwal_2
kwal_2_2:         addi.w #150,(a1)
                  subi.w #16,2(a0)
                  subq.w #1,(a0)
                  bge.s kwal_e
                  move.w #1,-2(a0)
                  move.w #56/4,(a0)+
                  clr.w (a0)+
                  bra.s kwal_2
kwal_e:           bsr.s kwal_4
                  bsr   swim
                  rts


kwal_4:           lea   kwal_p+4(pc),a0
                  move.w (a0)+,d0
                  add.w d0,(a0)
                  move.w (a0),d0
                  move.w #13,-(sp)
                  trap  #15
                  addq.l #2,sp
                  move.w d0,d1
                  move.w d0,d2
                  muls  #11342/6,d1
                  muls  #30743/6,d2
                  muls  #-28000,d0
                  swap  d1
                  swap  d2
                  swap  d0
                  asr.w #3,d0
                  asr.w #3,d1
                  asr.w #3,d2
                  add.w #115,d1
                  add.w #277,d2
                  add.w #520,d0
                  lea   kwal_x_p+4(pc),a0
                  move.w d1,(a0)+
                  move.w d2,(a0)+
                  lea   kwal_y_p+4(pc),a0
                  neg.w d1
                  neg.w d2
                  move.w d1,(a0)+
                  move.w d2,(a0)+
                  lea   kwal_z_p(pc),a0
                  move.w d0,d1
                  asr.w #1,d1
                  move.w d1,(a0)
                  neg.w d0
                  move.w d0,4(a0)
                  rts

swim_start:       lea   swim_p+4(pc),a1
                  move.w #19,-(sp)
                  trap  #15
                  move.w d0,(a1)+
                  clr.w (a1)+
                  move.w #20,-(sp)
                  trap  #15
                  move.w d0,(a1)+
                  clr.w (a1)+
                  move.w #21,-(sp)
                  trap  #15
                  move.w d0,(a1)+
                  clr.w (a1)+
                  addq.l #6,sp
                  rts

swim:             lea   swim_p(pc),a1
                  move.l (a1),d6
                  move.l d6,d5
                  swap  d5
                  mulu  d5,d5
                  move.l d5,d4
                  lsl.l #2,d5
                  add.l d4,d4
                  add.l d4,d5
                  sub.l d5,d6
                  move.l d6,(a1)+
                  swap  d6
                  move.w d6,d0
                  ext.l d0
                  divu  #9,d0
                  move.w #12,-(sp)
                  trap  #15
                  move.w #22,-(sp)
                  trap  #15
                  move.w #13,-(sp)
                  trap  #15
                  move.l d0,d1
                  move.w #23,-(sp)
                  trap  #15
                  move.w #13,-(sp)
                  trap  #15
                  move.l d0,d2
                  move.w d2,d3
                  muls  d6,d3
                  neg.l d3
                  add.l (a1),d3
                  move.l d3,(a1)+
                  move.w d1,d4
                  muls  d6,d4
                  add.l (a1),d4
                  move.l d4,(a1)+
                  swap  d1
                  swap  d2
                  muls  d1,d2
                  swap  d2
                  asr.w #1,d2
                  muls  d6,d2
                  neg.l d2
                  add.l (a1),d2
                  move.l d2,(a1)+

                  swap  d2

                  swap  d3
                  swap  d4
                  move.w d3,d0
                  move.w #1,-(sp)
                  trap  #15
                  move.w d4,d0
                  move.w #2,-(sp)
                  trap  #15
                  move.w d2,d0
                  move.w #3,-(sp)
                  trap  #15

                  lea   16(sp),sp
                  rts

kwal_p:         DCB.W 5
swim_p:         DCB.W 9

                BASE DC.W,OFF


;                PATH 'D:\RAPIDO.SSD\POLYGON\OBJECTS\'



                ENDPART
                >PART 'cube'

                BASE DC.W,cube

cube:           DC.W init_cube
                DC.W do_cube
                DC.W cube_x_p
                DC.W cube_y_p
                DC.W cube_z_p
                DC.W cube_3_p
                DC.W 12
                DC.W cube_p_p
                DC.W cube_l_p

init_cube:        rts

cube_x_p:       DC.W 0
                DC.W 1,500

cube_y_p:       DC.W 0
                DC.W 1,-500

cube_z_p:       DC.W 0
                DC.W 1,500

cube_3_p:       DC.W 8

                DC.W -12,-12,-12
                DC.W 12,-12,-12
                DC.W 12,-12,12
                DC.W -12,-12,12
                DC.W -12,12,-12
                DC.W 12,12,-12
                DC.W 12,12,12
                DC.W -12,12,12

cube_p_p:       DC.W 6
                DC.W cube_pl_1
                DC.W cube_pl_2
                DC.W cube_pl_3
                DC.W cube_pl_4
                DC.W cube_pl_5
                DC.W cube_pl_6

cube_l_p:       DC.W 0

cube_pl_1:      DC.W 0
                DC.W 0
                DC.W 0
                DC.W 6
                DC.W cube_p_1_nor
                DC.W cube_p_1_rev
                DC.W 16,4
                DC.W 20,0
                DC.W 4
                DC.W 16,16,20,36,4,0,0,32

cube_pl_2:      DC.W 0
                DC.W 0
                DC.W 0
                DC.W 6
                DC.W cube_p_1_rev
                DC.W cube_p_1_nor
                DC.W 24,12
                DC.W 28,8
                DC.W 4
                DC.W 24,24,28,44,12,8,8,40

cube_pl_3:      DC.W 0
                DC.W 0
                DC.W 0
                DC.W 4
                DC.W cube_p_2_nor
                DC.W cube_p_2_rev
                DC.W 20,8
                DC.W 24,4
                DC.W 4
                DC.W 20,20,24,40,8,4,4,36

cube_pl_4:      DC.W 0
                DC.W 0
                DC.W 0
                DC.W 4
                DC.W cube_p_2_rev
                DC.W cube_p_2_nor
                DC.W 28,0
                DC.W 16,12
                DC.W 4
                DC.W 28,28,16,32,0,12,12,44

cube_pl_5:      DC.W 0
                DC.W 0
                DC.W 0
                DC.W 2
                DC.W cube_p_3_nor
                DC.W cube_p_3_rev
                DC.W 28,20
                DC.W 24,16
                DC.W 4
                DC.W 28,24,24,20,20,16,16,28

cube_pl_6:      DC.W 0
                DC.W 0
                DC.W 0
                DC.W 2
                DC.W cube_p_3_rev
                DC.W cube_p_3_nor
                DC.W 0,8
                DC.W 4,12
                DC.W 4
                DC.W 0,0,4,4,8,8,12,12

cube_p_1_nor:     move.l a0,-(sp)
                  lea   cube_col(pc),a0
                  move.w #$0633,(a0)
                  movea.l (sp)+,a0
                  rts
cube_p_1_rev:     move.l a0,-(sp)
                  lea   cube_col(pc),a0
                  move.w #$0366,(a0)
                  movea.l (sp)+,a0
                  rts
cube_p_2_nor:     move.l a0,-(sp)
                  lea   cube_col+2(pc),a0
                  move.w #$0363,(a0)
                  movea.l (sp)+,a0
                  rts
cube_p_2_rev:     move.l a0,-(sp)
                  lea   cube_col+2(pc),a0
                  move.w #$0636,(a0)
                  movea.l (sp)+,a0
                  rts
cube_p_3_nor:     move.l a0,-(sp)
                  lea   cube_col+4(pc),a0
                  move.w #$0336,(a0)
                  movea.l (sp)+,a0
                  rts
cube_p_3_rev:     move.l a0,-(sp)
                  lea   cube_col+4(pc),a0
                  move.w #$0663,(a0)
                  movea.l (sp)+,a0
                  rts

cube_c0         EQU $0641
cube_c1         EQU $0412
cube_c2         EQU $0573
cube_c3         EQU $0346
cube_c4         EQU $0323
cube_c5         EQU $00


do_cube:          move.w #cube_c5,(a5)+
                  lea   cube_col(pc),a4
                  movem.w (a4),d0-d2
                REPT 7
                  move.w d0,(a5)+
                ENDR
                REPT 4
                  move.w d1,(a5)+
                ENDR
                REPT 2
                  move.w d2,(a5)+
                ENDR
                  move.w #cube_c3,(a5)+
                  move.w #cube_c4,(a5)+
                  rts

cube_col:       DCB.W 3

                BASE DC.W,OFF

                ENDPART

***************************** DATA TOTAL SEQUENCER ****************************

                >PART 'main seq'

go:

main_seq:       DC.W 1
                DC.L start_go
                DC.W 0
                DC.W 1
                DC.L do_go
                DC.W 260-1+14
                DC.L steady
                DC.W 16
                DC.L fade_up
                DC.W 1
                DC.L s_squash
                DC.W 99+50
                DC.L squash
                DC.W 50
                DC.L steady
                DC.W 1
                DC.L s_fade_out
                DC.W 15
                DC.L fade_out
                DC.W 2
                DC.L clear_sc
                DC.W 1
                DC.L wait

tri:
                DC.W 1
                DC.L start_obj
                DC.W 2
                DC.L set_sc
                DC.W 1
                DC.L s_fade_in
                DC.W 15
                DC.L fade_in
                DC.W 100
                DC.L nothing
                DC.W 1
                DC.L s_enlarge
                DC.W 1
                DC.L enlarge_1
                DC.W 99+50-1
                DC.L enlarge_2
                DC.W 1
                DC.L enlarge_3
                DC.W 100        ;number of vbls to precalc
                DC.L text_d     ;has to hold no of vbls until done
                DC.W 16
                DC.L fade_down
;260
                DC.W 0
                DC.W 1
                DC.L s_steady
                DC.W 50
                DC.L steady
                DC.W 5005
                DC.L steady
                DC.W 16
                DC.L fade_up
                DC.W 100
                DC.L steady
                DC.W 1
                DC.L s_squash
                DC.W 99+50
                DC.L squash
                DC.W 100
                DC.L steady
                DC.W 1
                DC.L s_fade_out
                DC.W 15
                DC.L fade_out
                DC.W 2
                DC.L clear_sc
                DC.W 1
                DC.L wait
spacy:
                DC.W 1
                DC.L start_obj
                DC.W 2
                DC.L set_sc
                DC.W 1
                DC.L s_fade_in
                DC.W 15
                DC.L fade_in
                DC.W 10
                DC.L nothing
                DC.W 0
                DC.W 40
                DC.L nothing
                DC.W 1
                DC.L s_enlarge
                DC.W 1
                DC.L enlarge_1
                DC.W 99+50-1
                DC.L enlarge_2
                DC.W 1
                DC.L enlarge_3
                DC.W 100        ;number of vbls to precalc
                DC.L text_d     ;has to hold no of vbls until done
                DC.W 16
                DC.L fade_down
;260
                DC.W 1
                DC.L s_steady
                DC.W 50
                DC.L steady
                DC.W 6005
                DC.L steady
                DC.W 16
                DC.L fade_up
                DC.W 100
                DC.L steady
                DC.W 1
                DC.L s_squash
                DC.W 99+50
                DC.L squash
                DC.W 100
                DC.L steady
                DC.W 1
                DC.L s_fade_out
                DC.W 15
                DC.L fade_out
                DC.W 2
                DC.L clear_sc
                DC.W 1
                DC.L wait

see:

                DC.W 1
                DC.L start_obj
                DC.W 2
                DC.L set_sc
                DC.W 1
                DC.L s_fade_in
                DC.W 15
                DC.L fade_in
                DC.W 100
                DC.L nothing
                DC.W 1
                DC.L s_enlarge
                DC.W 1
                DC.L enlarge_1
                DC.W 99+50-1
                DC.L enlarge_2
                DC.W 1
                DC.L enlarge_3
                DC.W 0
                DC.W 100        ;number of vbls to precalc
                DC.L text_d     ;has to hold no of vbls until done
                DC.W 16
                DC.L fade_down
;260
                DC.W 1
                DC.L s_steady
                DC.W 50
                DC.L steady
                DC.W 2805
                DC.L steady
                DC.W 16
                DC.L fade_up
                DC.W 100
                DC.L steady
                DC.W 1
                DC.L s_squash
                DC.W 99+50
                DC.L squash
                DC.W 100
                DC.L steady
                DC.W 1
                DC.L s_fade_out
                DC.W 15
                DC.L fade_out
                DC.W 2
                DC.L clear_sc
                DC.W 1
                DC.L wait

sauc:

                DC.W 1
                DC.L start_obj
                DC.W 2
                DC.L set_sc
                DC.W 1
                DC.L s_fade_in
                DC.W 15
                DC.L fade_in
                DC.W 100
                DC.L nothing
                DC.W 1
                DC.L s_enlarge
                DC.W 1
                DC.L enlarge_1
                DC.W 99+50-1
                DC.L enlarge_2
                DC.W 1
                DC.L enlarge_3
                DC.W 100        ;number of vbls to precalc
                DC.L text_d     ;has to hold no of vbls until done
                DC.W 16
                DC.L fade_down
;260
                DC.W 0
                DC.W 1
                DC.L s_steady
                DC.W 50
                DC.L steady
                DC.W 3605
                DC.L steady
                DC.W 16
                DC.L fade_up
                DC.W 100
                DC.L steady
                DC.W 1
                DC.L s_squash
                DC.W 99+50
                DC.L squash
                DC.W 100
                DC.L steady
                DC.W 1
                DC.L s_fade_out
                DC.W 15
                DC.L fade_out
                DC.W 2
                DC.L clear_sc
                DC.W 1
                DC.L wait

navo:
                DC.W 1
                DC.L start_obj
                DC.W 2
                DC.L set_sc
                DC.W 1
                DC.L s_fade_in
                DC.W 15
                DC.L fade_in
                DC.W 0
                DC.W 100
                DC.L nothing
                DC.W 1
                DC.L s_enlarge
                DC.W 1
                DC.L enlarge_1
                DC.W 99+50-1
                DC.L enlarge_2
                DC.W 1
                DC.L enlarge_3
                DC.W 100        ;number of vbls to precalc
                DC.L text_d     ;has to hold no of vbls until done
                DC.W 16
                DC.L fade_down
;260
                DC.W 1
                DC.L s_steady
                DC.W 50
                DC.L steady
                DC.W 4005
                DC.L steady
                DC.W 16
                DC.L fade_up
                DC.W 100
                DC.L steady
                DC.W 1
                DC.L s_squash
                DC.W 99+50
                DC.L squash
                DC.W 100
                DC.L steady
                DC.W 1
                DC.L s_fade_out
                DC.W 15
                DC.L fade_out
                DC.W 2
                DC.L clear_sc
                DC.W 1
                DC.L wait

ship1:
                DC.W 1
                DC.L start_obj
                DC.W 2
                DC.L set_sc
                DC.W 1
                DC.L s_fade_in
                DC.W 15
                DC.L fade_in
                DC.W 0
                DC.W 100
                DC.L nothing
                DC.W 1
                DC.L s_enlarge
                DC.W 1
                DC.L enlarge_1
                DC.W 99+50-1
                DC.L enlarge_2
                DC.W 1
                DC.L enlarge_3
                DC.W 100        ;number of vbls to precalc
                DC.L text_d     ;has to hold no of vbls until done
                DC.W 16
                DC.L fade_down
;260
                DC.W 1
                DC.L s_steady
                DC.W 50
                DC.L steady
                DC.W 1605
                DC.L steady
                DC.W 16
                DC.L fade_up
                DC.W 100
                DC.L steady
                DC.W 1
                DC.L s_squash
                DC.W 99+50
                DC.L squash
                DC.W 100
                DC.L steady
                DC.W 1
                DC.L s_fade_out
                DC.W 15
                DC.L fade_out
                DC.W 2
                DC.L clear_sc
                DC.W 1
                DC.L wait


dice:
                DC.W 1
                DC.L start_obj
                DC.W 2
                DC.L set_sc
                DC.W 1
                DC.L s_fade_in
                DC.W 15
                DC.L fade_in
                DC.W 100
                DC.L nothing
                DC.W 1
                DC.L s_enlarge
                DC.W 1
                DC.L enlarge_1
                DC.W 99+50-1
                DC.L enlarge_2
                DC.W 1
                DC.L enlarge_3
                DC.W 100        ;number of vbls to precalc
                DC.L text_d     ;has to hold no of vbls until done
                DC.W 0
                DC.W 200
                DC.L text_d
                DC.W 16
                DC.L fade_down
;260
                DC.W 1
                DC.L s_steady
                DC.W 50
                DC.L steady
                DC.W 4605
                DC.L steady
                DC.W 16
                DC.L fade_up
                DC.W 100
                DC.L steady
                DC.W 1
                DC.L s_squash
                DC.W 99+50
                DC.L squash
                DC.W 100
                DC.L steady
                DC.W 1
                DC.L s_fade_out
                DC.W 15
                DC.L fade_out
                DC.W 2
                DC.L clear_sc
                DC.W 1
                DC.L wait


cube1:
                DC.W 1
                DC.L start_jojo
                DC.W 2
                DC.L set_sc
                DC.W 1
                DC.L s_fade_in
                DC.W 0
                DC.W 15
                DC.L fade_in
                DC.W 100
                DC.L nothing
                DC.W 1
                DC.L s_enlarge
                DC.W 1
                DC.L enlarge_1
                DC.W 99+50-1
                DC.L enlarge_2
                DC.W 1
                DC.L enlarge_3
                DC.W 100        ;number of vbls to precalc
                DC.L text_d     ;has to hold no of vbls until done
                DC.W 16
                DC.L fade_down
;260
                DC.W 1
                DC.L s_steady
                DC.W 50
                DC.L steady
                DC.W 3305
                DC.L steady
                DC.W 16
                DC.L fade_up
                DC.W 100
                DC.L steady
                DC.W 1
                DC.L s_squash
                DC.W 99+50
                DC.L squash
                DC.W 100
                DC.L steady
                DC.W 1
                DC.L s_fade_out
                DC.W 15
                DC.L fade_out
                DC.W 2
                DC.L clear_sc
                DC.W 1
                DC.L wait

sea_k           EQU 20

sea:
                DC.W 1
                DC.L start_sea
                DC.W 2
                DC.L set_sc
                DC.W 1
                DC.L s_fade_in
                DC.W 15
                DC.L fade_in
                DC.W 100
                DC.L nothing
                DC.W 1
                DC.L s_enlarge
                DC.W 1
                DC.L enlarge_1
                DC.W 99+50-1
                DC.L enlarge_2
                DC.W 1
                DC.L enlarge_3
                DC.W 14+sea_k   ;number of vbls to precalc
                DC.L text_d     ;has to hold no of vbls until done
                DC.W 0
                DC.W 16
                DC.L fade_down
;260
                DC.W 1
                DC.L s_steady
                DC.W 50
                DC.L steady
                DC.W 3925-sea_k
                DC.L steady
                DC.W 16
                DC.L fade_up
                DC.W 100
                DC.L steady
                DC.W 1
                DC.L s_squash
                DC.W 99+50
                DC.L squash
                DC.W 100
                DC.L steady
                DC.W 1
                DC.L s_fade_out
                DC.W 15
                DC.L fade_out
                DC.W 2
                DC.L clear_sc
                DC.W 1
                DC.L wait

smack:
                DC.W 1
                DC.L start_obj
                DC.W 2
                DC.L set_sc
                DC.W 1
                DC.L s_fade_in
                DC.W 15
                DC.L fade_in
                DC.W 0
                DC.W 100
                DC.L nothing
                DC.W 1
                DC.L s_enlarge
                DC.W 1
                DC.L enlarge_1
                DC.W 99+50-1
                DC.L enlarge_2
                DC.W 1
                DC.L enlarge_3
                DC.W 100        ;number of vbls to precalc
                DC.L text_d     ;has to hold no of vbls until done
                DC.W 16
                DC.L fade_down
;260
                DC.W 1
                DC.L s_steady
                DC.W 50
                DC.L steady
                DC.W 3705
                DC.L steady
                DC.W 16
                DC.L fade_up
                DC.W 100
                DC.L steady
                DC.W 1
                DC.L s_squash
                DC.W 99+50
                DC.L squash
                DC.W 100
                DC.L steady
                DC.W 1
                DC.L s_fade_out
                DC.W 15
                DC.L fade_out
                DC.W 2
                DC.L clear_sc
                DC.W 1
                DC.L wait



huisje:
                DC.W 1
                DC.L start_obj
                DC.W 2
                DC.L set_sc
                DC.W 1
                DC.L s_fade_in
                DC.W 15
                DC.L fade_in
                DC.W 0
                DC.W 100
                DC.L nothing
                DC.W 1
                DC.L s_enlarge
                DC.W 1
                DC.L enlarge_1
                DC.W 99+50-1
                DC.L enlarge_2
                DC.W 1
                DC.L enlarge_3
                DC.W 100        ;number of vbls to precalc
                DC.L text_d     ;has to hold no of vbls until done
                DC.W 16
                DC.L fade_down
;260
                DC.W 1
                DC.L s_steady
                DC.W 50
                DC.L steady
                DC.W 2705
                DC.L steady
                DC.W 16
                DC.L fade_up
                DC.W 100
                DC.L steady
                DC.W 1
                DC.L s_squash
                DC.W 99+50
                DC.L squash
                DC.W 100
                DC.L steady
                DC.W 1
                DC.L s_fade_out
                DC.W 15
                DC.L fade_out
                DC.W 2
                DC.L clear_sc
                DC.W 1
                DC.L wait


wars:
                DC.W 1
                DC.L start_obj
                DC.W 2
                DC.L set_sc
                DC.W 1
                DC.L s_fade_in
                DC.W 15
                DC.L fade_in
                DC.W 0
                DC.W 100
                DC.L nothing
                DC.W 1
                DC.L s_enlarge
                DC.W 1
                DC.L enlarge_1
                DC.W 99+50-1
                DC.L enlarge_2
                DC.W 1
                DC.L enlarge_3
                DC.W 100        ;number of vbls to precalc
                DC.L text_d     ;has to hold no of vbls until done
                DC.W 16
                DC.L fade_down
;260
                DC.W 1
                DC.L s_steady
                DC.W 50
                DC.L steady
                DC.W 2555
                DC.L steady
                DC.W 16
                DC.L fade_up
                DC.W 100
                DC.L steady
                DC.W 1
                DC.L s_squash
                DC.W 99+50
                DC.L squash
                DC.W 100
                DC.L steady
                DC.W 1
                DC.L s_fade_out
                DC.W 15
                DC.L fade_out
                DC.W 2
                DC.L clear_sc
                DC.W 1
                DC.L wait

;main_seq:
glan:
                DC.W 1
                DC.L start_obj
                DC.W 2
                DC.L set_sc
                DC.W 1
                DC.L s_fade_in
                DC.W 15
                DC.L fade_in
                DC.W 0
                DC.W 100
                DC.L nothing
                DC.W 1
                DC.L s_enlarge
                DC.W 1
                DC.L enlarge_1
                DC.W 99+50-1
                DC.L enlarge_2
                DC.W 1
                DC.L enlarge_3
                DC.W 100        ;number of vbls to precalc
                DC.L text_d     ;has to hold no of vbls until done
                DC.W 16
                DC.L fade_down
;260
                DC.W 1
                DC.L s_steady
                DC.W 50
                DC.L steady
                DC.W 3505
                DC.L steady
                DC.W 16
                DC.L fade_up
                DC.W 100
                DC.L steady
                DC.W 1
                DC.L s_squash
                DC.W 99+50
                DC.L squash
                DC.W 100
                DC.L steady
                DC.W 1
                DC.L s_fade_out
                DC.W 15
                DC.L fade_out
                DC.W 2
                DC.L clear_sc
                DC.W 1
                DC.L wait

;main_seq:
try:
                DC.W 1
                DC.L start_obj
                DC.W 2
                DC.L set_sc
                DC.W 1
                DC.L s_fade_in
                DC.W 15
                DC.L fade_in
                DC.W 100
                DC.L nothing
                DC.W 1
                DC.L s_enlarge
                DC.W 1
                DC.L enlarge_1
                DC.W 99+50-1
                DC.L enlarge_2
                DC.W 0
                DC.W 1
                DC.L enlarge_3
                DC.W 100        ;number of vbls to precalc
                DC.L text_d     ;has to hold no of vbls until done
                DC.W 16
                DC.L fade_down
;260
                DC.W 1
                DC.L s_steady
                DC.W 50
                DC.L steady
                DC.W 2005
                DC.L steady
                DC.W 16
                DC.L fade_up
                DC.W 100
                DC.L steady
                DC.W 1
                DC.L s_squash
                DC.W 99+50
                DC.L squash
                DC.W 100
                DC.L steady
                DC.W 1
                DC.L s_fade_out
                DC.W 15
                DC.L fade_out
                DC.W 2
                DC.L clear_sc
                DC.W 1
                DC.L wait


;main_seq:
stuit:
                DC.W 1
                DC.L start_obj
                DC.W 2
                DC.L set_sc
                DC.W 1
                DC.L s_fade_in
                DC.W 15
                DC.L fade_in
                DC.W 0
                DC.W 100
                DC.L nothing
                DC.W 1
                DC.L s_enlarge
                DC.W 1
                DC.L enlarge_1
                DC.W 99+50-1
                DC.L enlarge_2
                DC.W 1
                DC.L enlarge_3
                DC.W 100        ;number of vbls to precalc
                DC.L text_d     ;has to hold no of vbls until done
                DC.W 16
                DC.L fade_down
;260
                DC.W 1
                DC.L s_steady
                DC.W 50
                DC.L steady
                DC.W 2455
                DC.L steady
                DC.W 16
                DC.L fade_up
                DC.W 100
                DC.L steady
                DC.W 1
                DC.L s_squash
                DC.W 99+50
                DC.L squash
                DC.W 100
                DC.L steady
                DC.W 1
                DC.L s_fade_out
                DC.W 15
                DC.L fade_out
                DC.W 2
                DC.L clear_sc
                DC.W 1
                DC.L wait

;main_seq:
tar:
                DC.W 1
                DC.L start_obj
                DC.W 2
                DC.L set_sc
                DC.W 1
                DC.L s_fade_in
                DC.W 0
                DC.W 15
                DC.L fade_in
                DC.W 100
                DC.L nothing
                DC.W 1
                DC.L s_enlarge
                DC.W 1
                DC.L enlarge_1
                DC.W 99+50-1
                DC.L enlarge_2
                DC.W 1
                DC.L enlarge_3
                DC.W 10         ;number of vbls to precalc
                DC.L text_d     ;has to hold no of vbls until done
                DC.W 16
                DC.L fade_down
;260
                DC.W 1
                DC.L s_steady
                DC.W 50
                DC.L steady
                DC.W 2855
                DC.L steady
                DC.W 16
                DC.L fade_up
                DC.W 100
                DC.L steady
                DC.W 1
                DC.L s_squash
                DC.W 99+50
                DC.L squash
                DC.W 100
                DC.L steady
                DC.W 1
                DC.L s_fade_out
                DC.W 15
                DC.L fade_out
                DC.W 2
                DC.L clear_sc
                DC.W 1
                DC.L wait

chees:
                DC.W 1
                DC.L start_obj
                DC.W 2
                DC.L set_sc
                DC.W 1
                DC.L s_fade_in
                DC.W 15
                DC.L fade_in
                DC.W 0
                DC.W 100
                DC.L nothing
                DC.W 1
                DC.L s_enlarge
                DC.W 1
                DC.L enlarge_1
                DC.W 99+50-1
                DC.L enlarge_2
                DC.W 1
                DC.L enlarge_3
                DC.W 10         ;number of vbls to precalc
                DC.L text_d     ;has to hold no of vbls until done
                DC.W 16
                DC.L fade_down
;260
                DC.W 1
                DC.L s_steady
                DC.W 50
                DC.L steady
                DC.W 3105
                DC.L steady
                DC.W 16
                DC.L fade_up
                DC.W 10
                DC.L steady
                DC.W 1
                DC.L s_squash
                DC.W 99+50
                DC.L squash
                DC.W 50
                DC.L steady
                DC.W 1
                DC.L s_fade_out
                DC.W 15
                DC.L fade_out
                DC.W 2
                DC.L clear_sc
                DC.W 1
                DC.L wait
                DC.W -1

objects:        DC.W 3
                DC.W 10

                DC.W 4
                DC.W 6

                DC.W 0
                DC.W 26

                DC.W 3
                DC.W 20

                DC.W 0
                DC.W 18

                DC.W 3
                DC.W 16

                DC.W 4
                DC.W 22

                DC.W 0
                DC.W 4

                DC.W 0
                DC.W 2

                DC.W -1
                DC.W -1

                DC.W 3
                DC.W 24

                DC.W 3
                DC.W 12

                DC.W 4
                DC.W 34

                DC.W 1
                DC.W 8

                DC.W 4
                DC.W 32

                DC.W 4
                DC.W 28

                DC.W 0
                DC.W 30

                DC.W 4
                DC.W 0

                DC.W -1


event_routs:    DC.L start_obj_v
                DC.L s_fade_in_v
                DC.L fade_in_v
                DC.L nothing_v
                DC.L s_enlarge_v
                DC.L enlarge_1_v
                DC.L text_d_v
                DC.L steady_v
                DC.L s_squash_v
                DC.L squash_v
                DC.L s_fade_out_v
                DC.L fade_out_v
                DC.L s_steady_v
                DC.L wait_v
                DC.L fade_down_v
                DC.L no_rast_v
                DC.L fade_up_v
                DC.L clear_sc_v
                DC.L set_sc_v
                DC.L start_go_v
                DC.L do_go_v
                DC.L start_sea_v
                DC.L enlarge_2_v
                DC.L enlarge_3_v
                DC.L start_jojo_v

rast_rout:      DC.L raster_type_1
                DC.L raster_type_2
                DC.L raster_type_3
                DC.L raster_type_4
                DC.L raster_type_5

obj_s:          DC.L go
                DC.L tri
                DC.L spacy
                DC.L see
                DC.L sauc
                DC.L navo
                DC.L ship1
                DC.L dice
                DC.L cube1
                DC.L sea
                DC.L smack
                DC.L huisje
                DC.L wars
                DC.L glan
                DC.L try
                DC.L stuit
                DC.L tar
                DC.L chees

obj_t:          DC.L go_t
                DC.L tri_t
                DC.L spacy_t
                DC.L see_t
                DC.L sauc_t
                DC.L navo_t
                DC.L ship1_t
                DC.L dice_t
                DC.L cube1_t
                DC.L sea_t
                DC.L smack_t
                DC.L huisje_t
                DC.L wars_t
                DC.L glan_t
                DC.L try_t
                DC.L stuit_t
                DC.L tar_t
                DC.L chees_t



                ENDPART
                >PART 'calc raptale/text'

rap_text:       DC.W 1
                DC.L init_rapt
                DC.W 199-3
                DC.L next_rapt
                DC.W 1
                DC.L copy_rapt
                DC.W 102+50
                DC.L do_rapt
                DC.W -1


rap_pars:
                DC.L $200000,$2a5124,-$f40000,$1c4123
                DC.L $300000,$2b6123,-$08000000,$1df412
                DC.L $10000000,$180000,$00,$180000
                DC.L $00,$600000,$00,$800000

                DC.L $200000,$1a5124,-$f40000,$1c4123
                DC.L $300000,$1b6123,-$08000000,$1df412
                DC.L $13000000,$100000,$00,$190000
                DC.L $00,$200000,$00,$400000

                DC.L $700000,-$1f5124,-$740000,$144123
                DC.L $3f0000,$206123,$04000000,-$14f412
                DC.L $0d000000,$200000,$1d000000,$200000
                DC.L $00,$2f0000,$00,$100000

                DC.L $200000,$2a5124,-$f40000,$3c4123
                DC.L $300000,$2b6123,-$08000000,$3df412
                DC.L $18000000,$040000,$08000000,-$040000
                DC.L $0d000000,$200000,$1d000000,$200000

                DC.L $00,$1f0000,0,$1f0000
                DC.L $00,$1f0000,0,$00
                DC.L $10000000,$040000,$10000000,-$040000
                DC.L $0d000000,$200000,$1d000000,$200000

                DC.L $00,$2f0000,$00,$00
                DC.L $00,-$0f0000,$01000000,$00
                DC.L $1d800000,$030000,$0d800000,$030000
                DC.L $00,-$300000,$01000000,-$360000

                DC.L $00,$280000,$00,$280000
                DC.L $00,$280000,$00,$00
                DC.L $10000000,$00,$10000000,$00
                DC.L $10000000,$1647ae,$10000000,-$1547ae

                DC.L $00,$180000,$00,$00
                DC.L $00,$00,$00,$180000
                DC.L $0f000000,$100000,$11000000,-$100000
                DC.L $10000000,-$040000,$10000000,$040000

                DC.L $00,$080000,$00,$080000
                DC.L $00,$080000,$00,$00
                DC.L $18000000,$00,$08000000,$00
                DC.L $18000000,$00,$08000000,$00

                DC.L $00,$080000,$00,$080000
                DC.L $00,$080000,$00,$00
                DC.L $13200000,-$044000,$0ce00000,$044000
                DC.L $10000000,$00,$10000000,$00

                DC.L $200000,$0a5124,-$f40000,$0c4123
                DC.L $300000,$0b6123,-$08000000,$2df412
                DC.L $0e000000,$150000,$02000000,$150000
                DC.L $00,$600000,$00,$800000

                DC.L $00,$0d0000,0,-$0e0000
                DC.L $00,-$0f0000,0,$00
                DC.L $12000000,$040000,$0e000000,-$040000
                DC.L $0d000000,$200000,$10000000,-$200000

                DC.L $00,$0d0000,0,-$0e0000
                DC.L $00,-$0f0000,0,$00
                DC.L $10000000,$016000,$10000000,-$016000
                DC.L $10000000,$200000,$10000000,$200000

                DC.L $00,$0c0000,$00,$00
                DC.L $00,-$090000,$00,$00
                DC.L $18000000,$00,$18000000,$140000
                DC.L $18000000,$080000,$18000000,-$150000

                DC.L $041241,$0c0000,$041242,$00
                DC.L -$051242,-$090000,$512422,$00
                DC.L $15000000,$00,$0b000000,$00
                DC.L $18000000,$200000,$80000000,$400000

                DC.L $041241,$412122,$341242,$524412
                DC.L -$051242,-$654123,$512422,$312412
                DC.L $12000000,-$010000,$0e000000,$010000
                DC.L $18000000,$400000,$80000000,$400000

                DC.L $00,$023000,$00,$00
                DC.L $200000,$0b0000,$00,$0f0000
                DC.L $11000000,$00,$0f000000,$00
                DC.L $18000000,$400000,$80000000,$400000

                DC.L $00,$080000,$00,$080000
                DC.L $00,$040000,$00,$00
                DC.L $18000000,$00,$08000000,$00
                DC.L $18000000,$00,$08000000,$00


rap_talk:
go_t:           DC.B 7," SORT OUT THOSE",0
                DC.B 7+8,"  TRANSPARANT",0
                DC.B 7,"    POLYGONS",-1

tri_t:          DC.B 0,0
                DC.B 7+8,"    BIST DU",0
                DC.B 7,"  LEBENSMUEDE?",-1

spacy_t:        DC.B 0,0
                DC.B 7+8,"   MAKE MY EYES",0
                DC.B 7,"      BELIEVE",-1

see_t:          DC.B 7,"  WHAT IS THAT?",0
                DC.B 7," I AM SURE I SAW",0
                DC.B 7,"    IT MORPH!",-1

sauc_t:         DC.B 0,0
                DC.B 7,"  IL PENDOLO DI",0
                DC.B 7+8,"    FOUCAULT ",-1

navo_t:         DC.B 0,0
                DC.B 7,"  LEKKER VLIEGEN",0
                DC.B 7,"     TRALALA!",-1

ship1_t:        DC.B 0,0
                DC.B 7,"     EYES OF",0
                DC.B 7+8,"     A DICE",-1

dice_t:         DC.B 0,0
                DC.B 0,0
                DC.B 7," OOHH  MAGIC BOX",0
                DC.B 7,"   OF PANDORA!",-1

cube1_t:        DC.B 0,0
                DC.B 7+8,"  AH BLUE SEA",0
                DC.B 7,"  OH BIG OCEAN",-1

sea_t:          DC.B 0,0
                DC.B 7+8,"    JUST ONE",0
                DC.B 7,"   SNOTTY DROP",-1

smack_t:        DC.B 7," WHAT I WOULD DO",0
                DC.B 7,"  FOR A COTTAGE",0
                DC.B 7,"     AT SEA?",-1

huisje_t:       DC.B 0,0
                DC.B 7+12," IT FLIES LIKE",0
                DC.B 7+12,"    A DREAM",-1

wars_t:         DC.B 7," YOU DO NOT HAVE",0
                DC.B 7+8,"THE MONEY TO BUY",0
                DC.B 7+8,"ME BIG DIAMONDS!",-1

glan_t:         DC.B 7,"AND SHE SHOWED ME",0
                DC.B 7,"HER PLATTER OF MY",0
                DC.B 7," FAVOURITE FISH!",-1

try_t:                                  ;       DC.B 0,0
                DC.B 7," GO FORTH AND BE",0
                DC.B 7,"   A BRANCHING",0
                DC.B 7+8,"    PROCESS!",-1

stuit_t:        DC.B 7+8,"  AFTER A WILD",0
                DC.B 7+8,"CHASE THE POLICE",0
                DC.B 7+8,"CAUGHT THE THIEF",0
                DC.B 7+8,"  NEAR NEPTUNE",-1

tar_t:
                DC.B 0,0
                DC.B 7+8,"   SAY CHEESE",0
                DC.B 7,"   MR CRAPMAN!",-1
chees_t:
                DC.B 0,0
                DC.B 7,"USE FUNCTION KEYS",0
                DC.B 7,"TO CONTROL CUBOID",-1

trans_l:        REPT 33
                DC.B 0
                ENDR
                DC.B 27
                REPT 29
                DC.B 0
                ENDR
                DC.B 28
                DC.B 0
                DC.B 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22
                DC.B 23,24,25,26

                ENDPART


                BASE A6,parameters ;index for parameter block


main:             bsr   init_screen
                IFEQ music
                  jsr   music_play
                  sf    music_flag
                ENDC
                  bsr   init

                  bsr   init_rap
main_1:           bsr   next_rap
                  tst.w end_rap
                  beq.s main_1

                  bsr   init_total_seq

not_idle:         bsr   calc_total_seq
                  tst.w idle
                  beq.s not_idle

                  bsr   init_mfp_1

main_l:           bsr   calc_total_seq
                  tst.w exit
                  bne.s main_l_2
                  cmpi.b #57,$fffffc02.w
                  bne.s main_l
                  bra.s space

main_l_2:         tst.w go_do_it
                  beq.s main_l_2

main_l_3:         bsr   init_mfp_2
main_l_4:         clr.w no_of_vbls
                  move.l #cube,current_obj
                  bsr   set_par_s
                  bsr   init_objects_1
                  move.w #0,d0
                  bsr   init_object
wait_for:         tst.w go_do_it
                  beq.s wait_for

                  bsr   set_screen
;                  bsr   init_mfp_2

again:            bsr   buffer_cube
                  cmpi.b #57,$fffffc02.w
                  bne.s again
                  bsr.s kill_all

                  rts

space:            bsr   init_mfp_4
                  clr.w no_of_vbls
                  move.l #cube,current_obj
                  bsr   set_par_s
                  bsr   init_objects_1
                  move.w #0,d0
                  bsr   init_object
                  bsr   set_screen
                  bsr   init_mfp_3
                  bra.s again

kill_all:       >PART 'kill all work'
                  bsr   init_mfp_4
                  moveq #8-1,d0
                  moveq #0,d1
                  lea   $ffff8240.w,a0
cl_pa:            move.l d1,(a0)+
                  dbra  d0,cl_pa
                  bsr   clear_screens
                  rts
                ENDPART

****************************** TEXT AND RAPTALE  ********************************

init_rap:       >PART 'init raptale'
                  bsr   calc_p_rap
                  bsr.s init_rap_s
                  lea   rap_b1_c,a0
                  lea   rap_b2_c,a1
                  lea   rap_b1_a,a2
                  lea   rap_b2_a,a3
                  move.l a0,rap_b1_c_p
                  move.l a1,rap_b2_c_p
                  move.l a2,rap_b1_a_p
                  move.l a3,rap_b2_a_p
                  lea   rap_pars+object_nr*64(pc),a0
                  move.l a0,rap_pars_p
                  clr.w end_rap
                  lea   obj_t(pc),a0
                  movea.l object_nr*4(a0),a0
                  move.l a0,cur_rap_text
                  rts
                ENDPART
init_rap_s:     >PART 'init raptale sequence'
                  move.w #1,rap_count
                  lea   rap_text(pc),a0
                  move.l a0,cur_rap_p
                  rts
                ENDPART
next_rap:       >PART 'do next raptale'

                  subq.w #1,rap_count   ;next vbl
                  bne.s next_rap_2      ;if still left jump
                  lea   cur_rap_p,a1    ;next
                  movea.l (a1),a0       ;
                  move.w (a0)+,d0       ;store vbl count
                  bge.s next_rap_1      ;

                  move.w #1,end_rap     ;
                  bsr.s init_rap_s      ;
                  rts                   ;
next_rap_1:       move.w d0,rap_count   ;
                  move.l (a0)+,cur_rap_r ;next routine
                  move.l a0,(a1)        ;
next_rap_2:       movea.l cur_rap_r,a0  ;fetch routine
                  jsr   (a0)            ;jump to it
                  rts                   ;bye

                ENDPART

calc_l_rap:     >PART 'calc on line of a raptale'

;calculates a fast rap-tale

                  lea   rap_tale,a0
                  lea   sin_cos_tab,a1

                  move.l (a0),d0
                  add.l 4(a0),d0
                  move.l d0,(a0)

                  move.l 8(a0),d1
                  add.l 12(a0),d1
                  move.l d1,8(a0)

                  move.l 16(a0),d2      ;
                  movea.l 20(a0),a2     ;
                  move.l 24(a0),d3      ;
                  movea.l 28(a0),a3     ;

                  move.l 32(a0),d4      ;
                  add.l 36(a0),d4       ;
                  move.l d4,32(a0)      ;

                  move.l 40(a0),d5      ;
                  add.l 44(a0),d5       ;
                  move.l d5,40(a0)      ;

                  move.l 48(a0),d6      ;
                  add.l 52(a0),d6       ;
                  move.l d6,48(a0)      ;

                  move.l 56(a0),d7      ;
                  add.l 60(a0),d7       ;
                  move.l d7,56(a0)      ;

                  swap  d4              ;
                  swap  d5              ;
                  swap  d6              ;
                  swap  d7              ;

                  and.w #(period-1)*4,d4 ;
                  and.w #(period-1)*4,d5 ;
                  and.w #(period-1)*4,d6 ;
                  and.w #(period-1)*4,d7 ;

                  move.w 0(a1,d4.w),d4  ;
                  move.w 0(a1,d5.w),d5  ;
                  move.w 0(a1,d6.w),d6  ;
                  move.w 0(a1,d7.w),d7  ;
                  asr.w #6,d4           ;
                  asr.w #6,d5           ;
                  asr.w #8,d6           ;
                  asr.w #8,d7           ;
                  add.w d6,d4           ;
                  add.w d7,d5           ;
                  cmp.w d4,d5           ;
                  blt   rapt_end        ;
rapt_2:           add.w #160,d4         ;x1
                  add.w #160,d5         ;x2
                  move.w d4,d7          ;
                  bra.s skip_x_rap_l_e  ;
skip_x_rap_l:     add.l a2,d2           ;
                  add.l a3,d3           ;
skip_x_rap_l_e:   dbra  d7,skip_x_rap_l ;

                  sub.w d4,d5           ;
                  move.w d5,d7          ;
                  add.w d4,d4           ;
                  add.w d4,d4           ;
                  lea   point_rap,a4    ;
                  adda.w d4,a4          ;

                  swap  d0              ;
                  and.w #(period-1)*4,d0 ;
                  movea.w 0(a1,d0.w),a0 ;sin(h1)

                  swap  d1              ;
                  and.w #(period-1)*4,d1 ;
                  move.w 2(a1,d1.w),d1  ;cos(h4)
                  move.w #(period-1)*4,d0 ;


                  bra.s next_p_e        ;

next_p:           add.l a2,d2           ;next points
                  add.l a3,d3           ;

                  move.l d2,d4          ;
                  swap  d4              ;
                  and.w d0,d4           ;h2
                  move.w a0,d5          ;
                  sub.w 2(a1,d4.w),d5   ;sin(h1)-cos(h2)
;                  asr.w #1,d5           ;
                  and.w d0,d5           ;
                  move.w 2(a1,d5.w),d4  ;cos((sin(h1)-cos(h2))*1/2*period)

                  move.l d3,d5          ;
                  swap  d5              ;
                  and.w d0,d5           ;h3
                  move.w d1,d6          ;
                  muls  0(a1,d5.w),d6   ;sin(h3)*cos(h4)
                  swap  d6              ;
                  rol.l #3,d6           ;
                  and.w d0,d6           ;
                  add.w 0(a1,d6.w),d4   ;f1+f2
;                  asr.w #1,d4
;                  add.w #8192,d4        ;
                  move.w d4,-(sp)       ;/byte
                  move.b (sp)+,d4       ;
                  and.w #3*16,d4        ;
                  move.w (a4)+,d5       ;
                  movea.l a6,a5         ;
                  adda.w (a4)+,a5       ;
                  jmp   2(pc,d4.w)      ;
no_pix:           dbra  d7,next_p       ;
                  rts                   ;
                  nop                   ;
                  nop                   ;
                  nop                   ;
                  nop                   ;
                  nop                   ;
pic_1:            or.w  d5,(a5)         ;
                  dbra  d7,next_p       ;
                  rts                   ;
                  nop                   ;
                  nop                   ;
                  nop                   ;
                  nop                   ;
pic_2:            or.w  d5,2(a5)        ;
                  dbra  d7,next_p       ;
                  rts                   ;
                  nop                   ;
                  nop                   ;
                  nop                   ;
pic_3:            or.w  d5,(a5)+        ;
                  or.w  d5,(a5)         ;
next_p_e:         dbra  d7,next_p       ;
rapt_end:         rts
                ENDPART
calc_p_rap:     >PART 'point raptable'
                  lea   point_rap,a0
                  moveq #0,d3
                  move.w #20-1,d0
calc_p_rap_w:     move.w #16-1,d1
                  move.w #$8000,d2
calc_p_rap_p:     move.w d2,(a0)+
                  move.w d3,(a0)+
                  lsr.w #1,d2
                  dbra  d1,calc_p_rap_p
                  addq.w #4,d3
                  dbra  d0,calc_p_rap_w
                  rts
                ENDPART

init_rapt:      >PART 'init precalc raptale'

                  lea   rap_tale,a0
                  lea   rap_pars_p,a2
                  movea.l (a2),a1
                  movem.l (a1)+,d0-d7
                  movem.l d0-d7,(a0)
                  movem.l (a1)+,d0-d7
                  movem.l d0-d7,4*8(a0)
                  move.l a1,(a2)

                  lea   raptale_buf,a0
                  moveq #0,d0
                  move.l d0,d1
                  move.l d0,d2
                  move.l d0,d3
                  move.l d0,d4
                  move.l d0,d5
                  move.l d0,d6
                  move.l d0,d7
                  movea.l d0,a1
                  movea.l d0,a2
                REPT 2
                  movem.l d0-d7/a1-a2,(a0)
                  movem.l d0-d7/a1-a2,4*10(a0)
                  lea   4*20(a0),a0
                ENDR
                  move.l a0,cur_rap_lin
                  clr.w no_rapt
                  clr.w cur_rap_y
                  lea   cur_rap_text,a1
                  movea.l (a1),a0
                  move.b (a0)+,d0
                  move.l a0,(a1)
                  ext.w d0
                  move.w d0,cur_rap_x
                  rts
                ENDPART
next_rapt:      >PART 'next precalc raptale'
                  addi.l #80,cur_rap_lin
                  movea.l cur_rap_lin,a6
                  moveq #0,d0
                  moveq #0,d1
                  moveq #0,d2
                  moveq #0,d3
                  moveq #0,d4
                  moveq #0,d5
                  moveq #0,d6
                  moveq #0,d7
                  movea.l d0,a1
                  movea.l d1,a2
                REPT 2
                  movem.l d0-d7/a1-a2,-(a6)
                ENDR
                  bsr   calc_l_rap
                  rts
                ENDPART
copy_rapt:      >PART 'copy raptale to buffers'
                  movea.l rap_b1_c_p,a0
                  movea.l rap_b2_c_p,a1
                  moveq #0,d0
                  moveq #0,d1
                  moveq #0,d2
                  moveq #0,d3
                  moveq #0,d4
                  moveq #0,d5
                  moveq #0,d6
                  movea.l d6,a2
                  movea.l d6,a3
                  movea.l d6,a4
                  move.w #60-1,d7
copy_rapt_l:      movem.l d0-d6/a2-a4,(a0)
                  movem.l d0-d6/a2-a4,10*4(a0)
                  movem.l d0-d6/a2-a4,(a1)
                  movem.l d0-d6/a2-a4,10*4(a1)
                  lea   80(a0),a0
                  lea   80(a1),a1
                  dbra  d7,copy_rapt_l
                  rts
                ENDPART
do_rapt:        >PART 'do precalc on text'
                  tst.w no_rapt
                  bne.s do_rapt_e
                  movea.l cur_rap_text,a5
                  move.w cur_rap_x,d5
                  move.w cur_rap_y,d6
do_rapt_0:        move.b (a5)+,d0
                  tst.b d0
                  bmi.s do_rapt_end
                  bne.s do_rapt_y_s

                  move.b (a5)+,d5
                  ext.w d5
                  add.w #15,d6
                  bra.s do_rapt_0

do_rapt_y_s:      move.l a5,cur_rap_text
                  lea   trans_l(pc),a5
                  ext.w d0
                  move.b 0(a5,d0.w),d0
                  ext.w d0
                  beq.s do_rapt_y_s_2
                  subq.w #1,d0
                  bsr   random
                  move.w d7,d1
                  add.w d5,d1
                  bsr   random
                  move.w d7,d2
                  add.w d6,d2
                  movea.l rap_b1_c_p,a0
                  bsr.s print_char
                  bsr   random
                  move.w d7,d1
                  add.w d5,d1
                  bsr   random
                  move.w d7,d2
                  add.w d6,d2
                  movea.l rap_b2_c_p,a0
                  bsr.s print_char
do_rapt_y_s_2:    move.w d6,cur_rap_y
                  add.w #18,d5
                  move.w d5,cur_rap_x
do_rapt_e:        rts
do_rapt_end:      move.l a5,cur_rap_text
                  move.w #1,no_rapt
                  rts
                ENDPART
print_char:     >PART 'print character'

*a0 destination screen

*d0 char number
*d1 x coord
*d2 y coord
                  movem.w d0-d2,-(sp)
                  lea   font(pc),a1
                  muls  #10*4,d0
                  adda.w d0,a1
                  lea   mul_160,a2
                  add.w d2,d2
                  move.w 0(a2,d2.w),d2
                  lsr.w #1,d2
                  adda.w d2,a0
                  move.w d1,d3
                  and.w #15,d1
                  lsr.w #2,d3
                  and.b #%11111100,d3
                  adda.w d3,a0
                  move.w #10-1,d4

pr_next_l:        moveq #0,d2
                  moveq #0,d3
                  move.w (a1)+,d2
                  move.w (a1)+,d3
                  ror.l d1,d2
                  ror.l d1,d3
                  or.w  d2,(a0)+
                  or.w  d3,(a0)+
                  swap  d2
                  swap  d3
                  or.w  d2,(a0)+
                  or.w  d3,(a0)
                  lea   80-6(a0),a0
                  dbra  d4,pr_next_l
                  movem.w (sp)+,d0-d2
                  rts

                ENDPART
random:         >PART 'random generator'
                  move.l d6,-(sp)
                  move.l seed,d6
                  move.w d6,d7
                  swap  d6
                  add.b $ffff8209,d6
                  add.b $ffff8207,d7
                  mulu  #$12b9,d6
                  mulu  #$b0a1,d7
                  eor.l d6,d7
                  move.l d7,seed
                  move.w d7,d6
                  swap  d7
                  eor.w d6,d7
                  and.w #3,d7
                  move.l (sp)+,d6
                  rts
                ENDPART

************************** TOTAL SEQUENCER ROUTINES ****************************


init_total_seq: >PART 'init total sequence'
                  clr.w exit            ;no exit
                  move.w #1,go_do_it    ;
                  move.w #50,line_add   ;
                  clr.w main_seq_c      ;no sequences done yet
                  lea   buffer_obj(pc),a0 ;init bufer routine slot
                  move.l a0,buffer_slot ;
                  lea   event_buf_s,a0  ;pointer to event buffer
                  move.l a0,current_ev  ;both pointer reset
                  move.l a0,actual_ev   ;
;                  lea   main_seq,a0     ;pointer to main sequence
                  lea   obj_s(pc),a0    ;
                  movea.l object_nr*4(a0),a0 ;
                  move.l a0,main_seq_p  ;store
                  lea   objects+object_nr*4(pc),a0 ;
                  move.l a0,objects_p   ;
                  bsr.s calc_total_seq  ;
                  rts
                ENDPART
calc_total_seq: >PART 'calculate total sequence'

                  bsr.s calc_t_seq      ;else calc sequence event
                  tst.w no_obj_c        ;
                  beq.s calc_total_seq_e ;
calc_total_seq_a: movea.l buffer_slot(pc),a0 ;jump to current object buffer routine
                  jsr   (a0)            ;
                  bne.s calc_total_seq_a ;jump if no buffer succes
calc_total_seq_e: addq.w #1,no_of_vbls  ;
                  rts                   ;

                ENDPART
calc_t_seq:     >PART 'calc sequence event'
                  lea   actual_ev(pc),a1
                  movea.l (a1),a5
                  cmpa.l #event_buf_e,a5
                  blt.s calc_t_seq_2
                  lea   event_buf_s,a5
calc_t_seq_2:     addq.l #2,a5
                  move.l a5,(a1)
                  subq.l #2,a5
                  subq.w #1,main_seq_c
                  bgt.s calc_t_seq_3
                  lea   main_seq_p(pc),a1
                  movea.l (a1),a0
calc_t_seq_2_1:   move.w (a0)+,d0
                  bmi.s calc_t_seq_4
                  bne.s calc_t_seq_5
                  bsr   idle_off
                  bra.s calc_t_seq_2_1
calc_t_seq_5:     move.w d0,main_seq_c
                  move.l (a0)+,cur_main_r
                  move.l a0,(a1)
calc_t_seq_3:     movea.l cur_main_r(pc),a1
                  jsr   (a1)
                  rts
calc_t_seq_4:     move.w #1,exit
                  rts

                ENDPART
buffer_cube:    >PART 'special single object'
                  bsr   buffer_obj
                  lea   no_of_vbls,a0
buffer_cube_2:    move.w (a0),d0
                  cmp.w #20,d0
                  bgt.s buffer_cube_2
                  addq.w #1,(a0)
                  rts
                ENDPART

                >PART 'all main sequencer routines'

start_go:         tst.w go_do_it
                  beq.s start_go
                  lea   buffer_obj(pc),a0
                  move.l a0,buffer_slot
                  clr.w no_of_vbls
                  bsr   init_objects_1
                  bsr   set_par
                  lea   parameters(pc),a6
                  clr.w idle
                  move.w #19*4,(a5)+
                  move.l a5,-(sp)
                  bsr   next_object
                  movea.l (sp)+,a5
                  clr.w no_obj_c
                  rts
do_go:            move.w #1,no_obj_c
                  move.w #20*4,(a5)+
                  rts

start_jojo:       move.w #24*4,(a5)+
                  bra.s start_obj_2

start_obj:        clr.w (a5)+
start_obj_2:      tst.w go_do_it
                  beq.s start_obj_2
                  lea   buffer_obj(pc),a0
                  move.l a0,buffer_slot
                  clr.w no_of_vbls
                  bsr   init_objects_1
                  bsr   clear_par
                  move.w #0,fade_bor_c
                  clr.w idle
                  move.l a5,-(sp)
                  bsr   next_object
                  movea.l (sp)+,a5
                  clr.w no_obj_c
                  rts

start_sea:        tst.w go_do_it
                  beq.s start_sea
                  clr.w no_of_vbls
                  lea   buffer_sea(pc),a0
                  move.l a0,buffer_slot
                  bsr   clear_par
                  move.w #0,fade_bor_c
                  clr.w idle
                  move.w #21*4,(a5)+
                  move.l a5,-(sp)
                  bsr   next_kwal
                  movea.l (sp)+,a5
                  clr.w no_obj_c
                  rts

set_sc:           clr.w no_obj_c
                  move.w #18*4,(a5)+
                  rts
s_fade_in:        move.w #1,no_obj_c
                  move.w #1*4,(a5)+
                  rts
fade_in:          move.w #2*4,(a5)+
                  rts
nothing:          move.w #3*4,(a5)+
                  rts
s_enlarge:        move.w #4*4,(a5)+
                  rts
enlarge:          rts
enlarge_1:        move.w #5*4,(a5)+
                  bsr   enlar_coor
                  rts
enlarge_2:        move.w #22*4,(a5)+
                  bsr   enlar_coor
                  rts
enlarge_3:        move.w #23*4,(a5)+
                  rts
text_d:           move.w #6*4,(a5)+
                  rts
fade_down:        move.w #14*4,(a5)+
                  rts
no_rast:          move.w #15*4,(a5)+
                  rts
fade_up:          move.w #16*4,(a5)+
                  rts
s_steady:         move.w #12*4,(a5)+
                  rts
steady:           move.w #7*4,(a5)+
                  rts
s_squash:         move.w #8*4,(a5)+
                  rts
squash:           move.w #9*4,(a5)+
                  lea   parameters(pc),a6
                  move.w s_y_min(a6),d0
                  subi.w #159,squash_c(a6)
                  addq.w #1,d0
                  move.w d0,d1
                  add.w s_y_max(a6),d1
                  lsr.w #1,d1
                  move.w d0,s_y_min(a6)
                  move.w d1,y_m(a6)
                  rts
s_fade_out:       move.w #10*4,(a5)+
                  rts
fade_out:         move.w #11*4,(a5)+
                  rts
clear_sc:         move.w #17*4,(a5)+
                  rts
wait:             move.w #13*4,(a5)+
                  clr.l current_obj
                  rts
ds:               move.w #1,exit
                  rts
idle_off:         move.w #1,idle
                  rts

enlar_coor:       lea   parameters(pc),a6
                  move.w s_y_max(a6),d0
                  addi.w #159,squash_c(a6)
                  addq.w #1,d0
                  move.w d0,d1
                  addq.w #1,d1
                  lsr.w #1,d1
                  move.w d0,s_y_max(a6)
                  move.w d1,y_m(a6)
                  rts

                ENDPART
                >PART 'all vbl sequencer routines'

start_go_v:       lea   vbl_slots(pc),a5
                  lea   do_vbl(pc),a3
                  move.l a3,vbl_one_s
                  clr.w (a5)+
                  move.w #3,rast_mode
                  bsr   calc_fade
                  rts

do_go_v:          clr.w go_do_it
                  lea   vbl_slots(pc),a5
                  lea   vbl_one(pc),a4
                  move.w #1,(a5)+
                  move.l a4,(a5)+
                  move.w #16,fade_bor_c
                  rts

start_jojo_v:     clr.w music_play+12

start_obj_v:      lea   vbl_slots(pc),a5
                  lea   do_vbl(pc),a3
                  move.l a3,vbl_one_s
                  move.w #1,(a5)+
                  lea   do_text(pc),a3
                  move.l a3,(a5)+
                  move.w #50,line_add
                  move.w #50,line_add2
                  clr.w rast_mode
                  bsr   calc_fade
                  rts

start_sea_v:      lea   vbl_slots(pc),a5
                  lea   sea_vbl(pc),a3
                  move.l a3,vbl_one_s
                  move.w #1,(a5)+
                  lea   do_text(pc),a3
                  move.l a3,(a5)+
                  move.w #50,line_add
                  move.w #50,line_add2
                  clr.w rast_mode
                  bsr   calc_fade
                  rts

set_sc_v:         lea   vbl_slots(pc),a5
                  lea   set_v_s(pc),a4
                  move.w #2,(a5)+
                  move.l a4,(a5)+
                  lea   do_text(pc),a3
                  move.l a3,(a5)+
                  rts

s_fade_in_v:      clr.w go_do_it
                  lea   vbl_slots(pc),a5
                  clr.w fade_gr
                  lea   vbl_one(pc),a3
                  lea   do_text(pc),a4
                  move.w #15,fade_gr
                  move.w #3,(a5)+
                  move.l a3,(a5)+
                  move.l a4,(a5)+
                  lea   fader(pc),a3
                  move.l a3,(a5)+
                  rts
fade_in_v:        subq.w #1,fade_gr
                  rts
nothing_v:        rts
s_enlarge_v:      lea   vbl_slots(pc),a5
                  move.w #2,(a5)
                  bsr   calc_fade
                  rts

enlarge_1_v:      addq.w #1,line_add
                  bsr   add_line_1
                  rts
enlarge_2_v:      addq.w #1,line_add
                  bsr   add_line_2
                  rts
enlarge_3_v:      bsr   add_line_1
                  rts

text_d_v:         rts
s_steady_v:       move.w #3,rast_mode
                  lea   vbl_slots(pc),a5
                  move.w #1,(a5)+
                  lea   vbl_one(pc),a3
                  move.l a3,(a5)+
                  rts
steady_v:         rts
fade_down_v:      move.w fade_bor_c(pc),d0
                  addq.w #1,fade_bor_c
                  add.w d0,d0
                  lea   fade_bor,a0
                  adda.w d0,a0
                  move.w (a0),eat_pal
                  rts
no_rast_v:        move.w #3,rast_mode
                  rts
fade_up_v:        lea   vbl_slots(pc),a5
                  lea   copy_pal(pc),a3
                  lea   vbl_one(pc),a4
                  move.w #2,(a5)+
                  move.l a3,(a5)+
                  move.l a4,(a5)+
                  move.w #1,rast_mode
                  subq.w #1,fade_bor_c
                  move.w fade_bor_c(pc),d0
                  add.w d0,d0
                  lea   fade_bor,a0
                  adda.w d0,a0
                  move.w (a0),eat_pal
                  rts

s_squash_v:       lea   vbl_slots(pc),a5
                  move.w #3,(a5)
                  lea   sub_line(pc),a4
                  move.l a4,10(a5)
                  move.w #2,line_add
                  move.w #2,line_add2
                  move.w #2,rast_mode

                  move.l rap_b1_c_p,d0
                  move.l rap_b1_a_p,rap_b1_c_p
                  move.l d0,rap_b1_a_p
                  move.l rap_b2_c_p,d0
                  move.l rap_b2_a_p,rap_b2_c_p
                  move.l d0,rap_b2_a_p
                  rts
squash_v:         addq.w #1,line_add
                  rts
s_fade_out_v:     lea   vbl_slots(pc),a5
                  clr.w fade_gr
                  lea   fader(pc),a4
                  lea   do_text(pc),a3
                  move.l a3,2(a5)
                  move.l a4,10(a5)
                  rts

fade_out_v:       addq.w #1,fade_gr
                  rts
clear_sc_v:       lea   vbl_slots(pc),a5
                  lea   clear_v_s(pc),a4
                  lea   do_text(pc),a3
                  move.w #2,(a5)+
                  move.l a3,(a5)+
                  move.l a4,(a5)+
                  move.w #4,rast_mode
                  rts

wait_v:           move.w #1,go_do_it
                  clr.w end_rap
                  lea   vbl_slots(pc),a5
                  move.w #1,(a5)+
                  rts


                ENDPART

                >PART 'special vbls routines'

do_text:          tst.w next_scr
                  beq.s do_text_0
                  tst.w do_text_fl
                  beq.s do_text_2
                  bra.s do_text_1
do_text_0:        subq.w #1,do_text_c
                  bge.s do_text_3
                  move.w #5,do_text_c
                  eori.w #1,do_text_fl
                  beq.s do_text_2
do_text_1:        movea.l rap_b1_a_p,a1
                  bsr   print_rap
                  eori.w #1,next_scr
                  rts
do_text_2:        movea.l rap_b2_a_p,a1
                  bsr   print_rap
                  eori.w #1,next_scr
do_text_3:        rts


add_line_1:                             ;   bsr   do_text
                  move.w line_add(pc),d1
                  movea.l screen1,a0
                  lea   mul_160,a2
                  add.w d1,d1
                  move.w 0(a2,d1.w),d1
                  adda.w d1,a0
                  lea   160(a0),a0
                  move.w clear_pat(pc),d0
                  ext.l d0
                  move.l d0,d1
                  move.l d0,d2
                  move.l d0,d3
                  move.l d0,d4
                  move.l d0,d5
                  move.l d0,d6
                  move.l d0,d7
                REPT 5
                  movem.l d0-d7,-(a0)
                ENDR
                  rts

add_line_2:                             ;  bsr   do_text
                  move.w line_add(pc),d1
                  movea.l screen1,a0
                  lea   mul_160,a2
                  add.w d1,d1
                  move.w 0(a2,d1.w),d1
                  adda.w d1,a0
                  lea   160(a0),a0
                  move.w clear_pat(pc),d0
                  ext.l d0
                  move.l d0,d1
                  move.l d0,d2
                  move.l d0,d3
                  move.l d0,d4
                  move.l d0,d5
                  move.l d0,d6
                  move.l d0,d7
                REPT 5
                  movem.l d0-d7,-(a0)
                  movem.l d0-d7,-(a0)
                ENDR
                  rts

sub_line:         bsr   do_text
                  movea.l screen1,a0
                  movea.l a0,a3
                  move.w line_add(pc),d1
                  move.w d1,-(sp)
                  lea   raptale_buf,a1
                  lea   -80*2(a1),a1
                  lea   mul_160,a2
                  add.w d1,d1
                  move.w 0(a2,d1.w),d1
                  lea   -160(a0),a0
                  adda.w d1,a0
                  lsr.w #1,d1
                  adda.w d1,a1
                  moveq #0,d1
                  moveq #0,d3
                  moveq #0,d5
                  moveq #0,d7
                REPT 5
                  movem.l (a1)+,d0/d2/d4/d6
                  movem.l d0-d7,(a0)
                  movem.l (a1)+,d0/d2/d4/d6
                  movem.l d0-d7,4*8(a0)
                  lea   8*8(a0),a0
                ENDR
                  tst.w do_text_fl
                  beq.s sub_line_1
                  movea.l rap_b1_a_p,a2
                  bra.s sub_line_2
sub_line_1:       movea.l rap_b2_a_p,a2
sub_line_2:       move.w (sp)+,d1
                  sub.w #70,d1
                  bmi.s sub_line_3
                  cmp.w #60,d1
                  bge.s sub_line_3
                  add.w d1,d1
                  lea   mul_160,a1
                  move.w 0(a1,d1.w),d1
                  adda.w d1,a3
                  lea   69*160(a3),a3
                  lsr.w #1,d1
                  adda.w d1,a2
                  lea   -80(a2),a2
                  move.w #4-1,d7
sub_line_l:       movem.l (a2)+,d0-d6/a4-a6
                  move.l d0,4(a3)
                  move.l d1,12(a3)
                  move.l d2,20(a3)
                  move.l d3,28(a3)
                  move.l d4,36(a3)
                  move.l d5,44(a3)
                  move.l d6,52(a3)
                  move.l a4,60(a3)
                  move.l a5,68(a3)
                  move.l a6,76(a3)
                  lea   10*8(a3),a3
                  dbra  d7,sub_line_l
sub_line_3:       rts

clear_v_s:        move.w line_add(pc),d0
                  add.w d0,d0
                  lea   mul_160,a0
                  move.w 0(a0,d0.w),d0
                  lea   raptale_buf,a2
                  lea   -80*2(a2),a2
                  movea.l screen1,a1
                  adda.w d0,a1
                  lsr.w #1,d0
                  adda.w d0,a2
                  moveq #0,d2
                  moveq #0,d4
                  moveq #0,d6
                  movea.l d6,a0
                  move.w #25-1,d0
clear_v_s_l:    REPT 5
                  movem.l (a2)+,d1/d3/d5/d7
                  movem.l d1-a0,(a1)
                  movem.l (a2)+,d1/d3/d5/d7
                  movem.l d1-a0,4*8(a1)
                  lea   8*8(a1),a1
                ENDR
                  dbra  d0,clear_v_s_l
                  rts

set_v_s:          move.w line_add(pc),d0
                  move.w d0,d1
                  add.w d1,d1
                  lea   mul_160,a2
                  movea.l screen1,a1
                  adda.w 0(a2,d1.w),a1
                  lea   160(a1),a1
                  subq.w #3,d0
                  move.w clear_pat(pc),d1
                  ext.l d1
                  move.l d1,d2
                  move.l d1,d3
                  move.l d1,d4
                  move.l d1,d5
                  move.l d1,d6
                  move.l d1,d7
                  movea.l d1,a0
set_v_s_l:      REPT 5
                  movem.l d1-a0,-(a1)
                ENDR
                  dbra  d0,set_v_s_l
                  rts

fader:            lea   new_buf(pc),a0
                  lea   new_buf(pc),a1
                  move.w fade_gr(pc),d0
                  bsr   gr_fader
                  rts
copy_pal:                               ; movem.l new_buf,d0-d7
;movem.l d0-d7,new_buf2
                  rts

calc_fade:
                  move.w eat_pal(pc),d0
                  move.w new_buf(pc),d1
                  moveq #0,d2
                  moveq #0,d3
                  moveq #0,d4
                  moveq #0,d5
                  moveq #0,d6
                  moveq #0,d7

                  move.w d0,d2
                  lsr.w #4,d0
                  move.w d0,d3
                  lsr.w #4,d0
                  move.w d0,d4
                  move.w d1,d5
                  lsr.w #4,d1
                  move.w d1,d6
                  lsr.w #4,d1
                  move.w d1,d7
                  move.w #%111,d0

                  and.w d0,d2
                  and.w d0,d3
                  and.w d0,d4

                  and.w d0,d5
                  and.w d0,d6
                  and.w d0,d7

                  swap  d2
                  swap  d3
                  swap  d4


                  swap  d5
                  swap  d6
                  swap  d7

                  sub.l d2,d5
                  sub.l d3,d6
                  sub.l d4,d7


                  move.w #32767,d0
                  move.w d0,d2
                  move.w d0,d3
                  move.w d0,d4

                  asr.l #4,d5
                  asr.l #4,d6
                  asr.l #4,d7

                  lea   fade_bor,a0
                  move.w #16-1,d0
fade_l:           moveq #0,d1
                  swap  d2
                  swap  d3
                  swap  d4
                  move.w d4,d1
                  lsl.w #4,d1
                  add.w d3,d1
                  lsl.w #4,d1
                  add.w d2,d1
                  move.w d1,(a0)+
                  swap  d2
                  swap  d3
                  swap  d4
                  add.l d5,d2
                  add.l d6,d3
                  add.l d7,d4
                  dbra  d0,fade_l
                  rts

print_rap:        movea.l screen1,a0
                  move.w rast_mode(pc),d0
                  cmp.w #0,d0
                  bne.s print_rap_1
                  move.w line_add(pc),d0
                  sub.w #70,d0
                  bmi.s print_rap_2
                  move.w d0,d7
                  lea   mul_160,a2
                  add.w d0,d0
                  move.w 0(a2,d0.w),d0
                  adda.w d0,a0
                  lea   71*160(a0),a0
                  lsr.w #1,d0
                  adda.w d0,a1
                  lea   80(a1),a1
                  subi.w #59,d7
                  bge.s print_rap_e
                  neg.w d7
                  add.w d7,d7
                  bra.s print_rap_l_e
print_rap_1:      cmp.w #4,d0
                  beq.s print_rap_2
                  move.w line_add(pc),d7
                  sub.w #70,d7
                  bmi.s print_rap_e
                  cmp.w #60,d7
                  bge.s print_rap_2
                  add.w d7,d7
                  lea   70*160(a0),a0
                  bra.s print_rap_l_e
print_rap_2:      lea   70*160(a0),a0
                  move.w #120-1,d7
print_rap_l:      movem.l (a1)+,d0-d6/a2-a4
                  move.l d0,4(a0)
                  move.l d1,12(a0)
                  move.l d2,20(a0)
                  move.l d3,28(a0)
                  move.l d4,36(a0)
                  move.l d5,44(a0)
                  move.l d6,52(a0)
                  move.l a2,60(a0)
                  move.l a3,68(a0)
                  move.l a4,76(a0)
                  lea   10*8(a0),a0
print_rap_l_e:    dbra  d7,print_rap_l
print_rap_e:      rts
                ENDPART

next_event:     >PART 'next event'
                  tst.w idle            ;
                  beq.s next_event_3    ;
;                  illegal
next_event_0:     tst.w no_of_vbls      ;of no vlbs left
                  beq.s next_event_2    ;other case
                  lea   current_ev(pc),a2 ;
                  movea.l (a2),a0       ;fetch current event pointer
                  move.w (a0)+,d0       ;fetch next event number
                  cmpa.l #event_buf_e,a0 ;
                  blt.s next_event_1    ;jump if not reached
                  lea   event_buf_s,a0  ;init start buffer
next_event_1:     move.l a0,(a2)        ;
                  lea   event_routs(pc),a2 ;
                  movea.l 0(a2,d0.w),a2 ;fetch event routine
                  jsr   (a2)            ;jump to event
                  lea   vbl_slots(pc),a0 ;pointer to vbls slots
                  move.w (a0)+,d0       ;
                  bra.s vbl_rout_l_e    ;
vbl_rout_l:       movea.l (a0)+,a1      ;
                  move.w d0,-(sp)       ;
                  move.l a0,-(sp)       ;
                  jsr   (a1)            ;jump to specfied routine
                  movea.l (sp)+,a0      ;
                  move.w (sp)+,d0       ;
vbl_rout_l_e:     dbra  d0,vbl_rout_l   ;
                  subq.w #1,no_of_vbls  ;one vbl done
next_event_3:     rts

*IDLE TIME (text update etc)

next_event_2:     rts

                ENDPART
next_object:    >PART 'next object'
                  lea   objects_p(pc),a1
                  lea   obj,a2
                  movea.l a2,a3
                  movea.l (a1),a0
                  move.w (a0)+,d0
                  adda.w (a0)+,a2
                  adda.w (a2),a3
                  move.l a3,current_obj
                  move.l a0,(a1)
                  bsr   init_object
                  rts
                ENDPART
next_kwal:      >PART 'init kwal'

                  addq.l #4,objects_p
                  lea   obj,a0
                  move.w 14(a0),d0
                  adda.w d0,a0
                  move.w #900/4,d1
                  lea   kwal2,a1
                  lea   kwal3,a2
                  lea   kwal4,a3

kwal_copy:        move.l (a0)+,d0
                  move.l d0,(a1)+
                  move.l d0,(a2)+
                  move.l d0,(a3)+
                  dbra  d1,kwal_copy
                  bsr   init_sea
                  rts
                ENDPART

init_screen:    >PART
                  move.w #0,d0
                  lea   new_buf2(pc),a0
                  move.w #16-1,d1
col_l:            move.w d0,(a0)+
                  dbra  d1,col_l

                  move.l #$0f8000+comp_off,d0
                  move.l #$0f0000+comp_off,d1
                  move.l d0,screen1
                  move.l d1,screen2
                  lsr.w #8,d1
                  stop  #$2300
                  move.l d0,$ffff8200.w
                  move.b #2,$ffff820a.w
                  clr.b $ffff8260.w
                  stop  #$2300
                  bsr   clear_screens
                  rts
                ENDPART
set_screen:     >PART
                  movea.l screen1,a0
                  movea.l screen2,a1
                  move.w #8000-1,d0
                  moveq #-1,d1
s_loop:           move.l d1,(a0)+
                  move.l d1,(a1)+
                  dbra  d0,s_loop
                  rts
                ENDPART
swap_screens:   >PART
                  move.l screen1,d0
                  move.l screen2,screen1
                  move.l d0,screen2
                  lsr.w #8,d0
                  move.l d0,$ffff8200.w
                  rts
                ENDPART
init_mfp_0:     >PART
                  clr.w vbl_flag
                  move  #$2700,sr
                  move.l #rte_rout,$70.w
                  move  #$2300,sr
                  rts
                ENDPART
init_mfp_1:     >PART
                  clr.w vbl_flag
                  lea   vbl_slots(pc),a0
                  clr.w (a0)
                  move  #$2700,sr
                  bset  #0,$fffffa07.w
                  bset  #0,$fffffa13.w
                  move.l #vbl_rout,$70.w
                  move.l #trap0_rout,$80.w
                  move  #$2300,sr
                  rts
                ENDPART
init_mfp_2:     >PART
                  clr.w vbl_flag
                  clr.w go_do_it
                  move.w #7*50,wait_v2
                  move  #$2700,sr
                  move.l #vbl_rout_3,$70.w
                  move  #$2300,sr
                  rts
                ENDPART
init_mfp_3:     >PART
                  clr.w vbl_flag
                  move  #$2700,sr
                  move.l #vbl_two,$70.w
                  move  #$2300,sr
                  rts
                ENDPART
init_mfp_4:     >PART
                  clr.w vbl_flag
                  move  #$2700,sr
                  move.l #vbl_music,$70.w
                  move  #$2300,sr
                  rts
                ENDPART
clear_screens:  >PART
                  movea.l screen1,a0
                  movea.l screen2,a1
                  move.w #(200)*40-1,d0
                  moveq #0,d1
loop:             move.l d1,(a0)+
                  move.l d1,(a1)+
                  dbra  d0,loop
                  rts
                ENDPART

vbl_rout:       >PART
                  move.l #vbl_rout_2,$70
                  move  #$2300,sr
                  movem.l d0-a6,-(sp)
                  bsr   do_rasters
                IFEQ music
                  jsr   music_play+4
                ENDC
                  tst.w end_rap
                  bne.s vbl_rout2
                  bsr   next_rap
                  bsr   do_text
                  bra.s vbl_rout3
vbl_rout2:        bsr   next_event
vbl_rout3:        bsr   swap_screens
tr:               cmpi.b #97,$fffffc02.w
                  beq.s tr
                  movem.l (sp)+,d0-a6
                  move.l #vbl_rout,$70
                  rte
                ENDPART
vbl_rout_2:     >PART
                  movem.l d0-a6,-(sp)
                  bsr   do_rasters
                  movem.l (sp)+,d0-a6
                  rte
                ENDPART
vbl_rout_3:     >PART
                  movem.l d0-a6,-(sp)
                IFEQ music
                  jsr   music_play+4
                ENDC
                  subq.w #1,wait_v2
                  bgt.s vbl_rout_3_2
                  move.l #vbl_two,$70.w
                  move.w #1,go_do_it
                  movem.l (sp)+,d0-a6
                  rte
vbl_rout_3_2:     bsr   do_text
                  bsr   swap_screens
                  movem.l (sp)+,d0-a6
                  rte
                ENDPART
vbl_one:        >PART
                  tst.w no_of_vbls
                  ble.s vbl_rout_e
                  movea.l vbl_one_s(pc),a0
                  jsr   (a0)
vbl_rout_e:       rts
                ENDPART
vbl_two:        >PART
                  move.l #rte_rout,$70
                  movem.l d0-a6,-(sp)
                IFEQ music
                  jsr   music_play+4
                ENDC
                  bsr   scan_angle
                  tst.w no_of_vbls
                  beq.s vbl_rout_2_e
                  movem.l new_buf(pc),d0-d7
                  movem.l d0-d7,$ffff8240.w
                  bsr   do_vbl
                  subq.w #1,no_of_vbls
                  bsr   swap_screens
vbl_rout_2_e:
                  movem.l (sp)+,d0-a6
                  move.l #vbl_two,$70
                  rte
                ENDPART
vbl_music:      >PART
                  movem.l d0-a6,-(sp)
                IFEQ music
                  jsr   music_play+4
                ENDC
                  movem.l (sp)+,d0-a6
                  rte
                ENDPART
do_rasters:     >PART 'different raster modes'
                  move.w line_add(pc),d1
                  move.w rast_mode(pc),d0
                  add.w d0,d0
                  add.w d0,d0
                  lea   rast_rout(pc),a0
                  adda.w d0,a0
                  movea.l (a0),a0
                  jsr   (a0)
                  move.w line_add(pc),line_add2
                  rts
                ENDPART

                OPT O-

calc_hbi:       >PART 'init raster routs'


raster_type_1:    subq.w #3,d1
                  move.w d1,hbi_0_0_2+2
                  clr.b $fffffa1b.w
                  move.b #2,$fffffa21.w
                  move.b #8,$fffffa1b.w
                  move.l #hbi_0_0,$0120.w
                  move.l eat_pal,d0
                  move.l d0,$ffff8240.w
                  movem.l new_buf,d0-d7
                  movem.l d0-d7,new_buf2
                  rts

raster_type_2:    clr.b $fffffa1b.w
                  move.b #2,$fffffa21.w
                  move.b #8,$fffffa1b.w
                  move.l #hbi_1_0,$0120.w
                  move.l eat_pal,d0
                  move.l d0,$ffff8240.w
                  movem.l new_buf,d0-d7
                  movem.l d0-d7,new_buf2
                  rts

raster_type_3:    clr.b $fffffa1b.w
                  move.b d1,$fffffa21.w
                  sub.w #198,d1
                  neg.w d1
                  move.w d1,hbi_3_0_2+2
                  move.b #8,$fffffa1b.w
                  move.l #hbi_3_0,$0120.w
                  movem.l eat_pal,d0-d7
                  movem.l d0-d7,$ffff8240.w
                  movem.l new_buf,d0-d7
                  movem.l d0-d7,new_buf2
                  rts

raster_type_4:    move.b #0,$fffffa1b.w
                  movem.l new_buf,d0-d7
                  movem.l d0-d7,$ffff8240.w
                  rts


raster_type_5:    move.b #0,$fffffa1b.w
                  movem.l eat_pal,d0-d7
                  movem.l d0-d7,$ffff8240.w
                  rts

                ENDPART
                >PART 'hbi routs'

hbi_0_0:          move  #$2700,sr
                  movem.l d0-d7,-(sp)
                  movem.l new_buf2,d0-d7
                  move.b $fffffa21.w,hbi_0_0_1+3
hbi_0_0_1:        cmpi.b #1,$fffffa21.w
                  beq.s hbi_0_0_1
                  clr.b $fffffa1b.w
hbi_0_0_2:        move.b #1,$fffffa21.w
                  move.b #8,$fffffa1b.w
                  movem.l d0-d7,$ffff8240.w
                  move.l #hbi_0_1,$0120.w
                  movem.l (sp)+,d0-d7
                  rte

hbi_0_1:          move  #$2700,sr
                  movem.l d0-d7,-(sp)
                  movem.l eat_pal,d0-d7
                  move.b $fffffa21.w,hbi_0_1_1+3
hbi_0_1_1:        cmpi.b #1,$fffffa21.w
                  beq.s hbi_0_1_1
hbi_0_1_2:        clr.b $fffffa1b.w
                  movem.l d0-d7,$ffff8240.w
                  movem.l (sp)+,d0-d7
                  rte

hbi_1_0:          move  #$2700,sr
                  movem.l d0-d7,-(sp)
                  movem.l new_buf2,d0-d7
                  move.b $fffffa21.w,hbi_1_0_1+3
hbi_1_0_1:        cmpi.b #1,$fffffa21.w
                  beq.s hbi_1_0_1
                  clr.b $fffffa1b.w
hbi_1_0_2:        move.b #196,$fffffa21.w
                  move.b #8,$fffffa1b.w
                  movem.l d0-d7,$ffff8240.w
                  move.l #hbi_1_1,$0120.w
                  movem.l (sp)+,d0-d7
                  rte

hbi_1_1:          move  #$2700,sr
                  move.b $fffffa21.w,hbi_1_1_1+3
hbi_1_1_1:        cmpi.b #1,$fffffa21.w
                  beq.s hbi_1_1_1
hbi_1_1_2:        clr.b $fffffa1b.w
                  move.w eat_pal,$ffff8240.w
                  rte

hbi_3_0:          move  #$2700,sr
                  movem.l d0-d7,-(sp)
                  movem.l new_buf2,d0-d7
                  move.b $fffffa21.w,hbi_3_0_1+3
hbi_3_0_1:        cmpi.b #1,$fffffa21.w
                  beq.s hbi_3_0_1
                  clr.b $fffffa1b.w
hbi_3_0_2:        move.b #1,$fffffa21.w
                  move.b #8,$fffffa1b.w
                  movem.l d0-d7,$ffff8240.w
                  move.l #hbi_3_1,$0120.w
                  movem.l (sp)+,d0-d7
                  rte

hbi_3_1:          move  #$2700,sr
                  move.b $fffffa21.w,hbi_3_1_1+3
hbi_3_1_1:        cmpi.b #1,$fffffa21.w
                  beq.s hbi_3_1_1
hbi_3_1_2:        clr.b $fffffa1b.w
                  move.w eat_pal,$ffff8240.w
                  rte

                ENDPART

                OPT O+

*********************************************************************************
*INIT ROUTINES


*different vbl routines

do_vbl:         >PART 'do a vbl sequence'
                  lea   obj1_space,a0
                  bsr   swap_buffers
                  bsr   draw_all
                  rts
                ENDPART
sea_vbl:        >PART 'animate sea'
                  bsr   multi_clr
                  bsr   multi_clr_c
                  bsr   i_multi_cl
                  lea   multi_point(pc),a5
                  move.w #no_multi-1,d7
sea_vbl_2:        movea.l (a5)+,a0
                  move.l a5,-(sp)
                  move.w d7,-(sp)
                  bsr   swap_buffers
                  bsr   draw_all
                  move.w (sp)+,d7
                  movea.l (sp)+,a5
see_vbl_3:        dbra  d7,sea_vbl_2
                  rts
                ENDPART

buffer_sea:     >PART 'calc sea'
                  lea   current_obj(pc),a4
                  lea   multi_param(pc),a5
                  move.w #no_multi-1,d7
buffer_sea_l:     move.w d7,-(sp)
                  movem.l (a5)+,d0-d7/a3 ;copy world parameters
                  movem.l d0-d7/a3,(a4)
                  movem.l a4-a5,-(sp)

buffer_see_l2:    bsr   buffer_obj
                  beq.s buf2
;                  illegal
                  move.w no_of_vbls,d0
                  bra.s buffer_see_l2
;                  bne.s buffer_see_l2   ;until you can buffer it
buf2:             movem.l (sp)+,a4-a5   ;
                  movem.l (a4),d0-d7/a3 ;fetch world parameters
                  movem.l d0-d7/a3,-(a5) ;copy to buffer
                  lea   36(a5),a5
                  move.w (sp)+,d7
buffer_see_l3:    dbra  d7,buffer_sea_l
                  bsr.s do_kwal_s
                  clr.w d0
                  rts
                ENDPART
init_sea:       >PART 'init sea'
                  bsr   init_m_objects
                  bsr   init_buffer1
                  bsr   init_multi_and
                  bsr   i_multi_cl
                  bsr   multi_clr_c

                  lea   multi_param(pc),a5

                  move.w #no_multi-1,d7

init_multi_l:     clr.l (a5)
                  lea   36(a5),a5
                  dbra  d7,init_multi_l

                  lea   sea_table(pc),a0
                  move.l a0,cur_kwal
                  clr.w kwal_count
                  bsr.s do_kwal_s
                  rts

                ENDPART
do_kwal_s:      >PART 'init next kwal sequence'
                  subq.w #1,kwal_count
                  bge.s do_kwal_s_3
                  movea.l cur_kwal(pc),a0
                  move.w (a0)+,d0
                  bge.s do_kwal_s_2
                  move.w #-1,multi_e_fl
                  rts
do_kwal_s_2:      move.w d0,kwal_count
                  movea.l (a0)+,a5
                  movem.w (a0)+,d0-d7/a1-a2
                  move.l a0,cur_kwal
                  lea   current_obj(pc),a3
                  lea   multi_param(pc),a4
                  mulu  #36,d0
                  adda.w d0,a4
                  move.l a5,(a3)
                  movem.w d1-d7/a1-a2,4(a3)
                  movem.l a3-a4,-(sp)
                  bsr.s e_init_object
                  movem.l (sp)+,a3-a4
                  movem.l (a3),d0-d7/a5
                  movem.l d0-d7/a5,(a4)
                  bra.s do_kwal_s
do_kwal_s_3:      rts
                ENDPART

init:           >PART 'init program'
                  bsr   init_anim
                  bsr   init_param
                  bsr.s creat_frac
                  bsr.s init_objects_1
                  bsr   init_ripple
                  bsr   mul160_tab
                  bsr   mul320_tab
                  rts
                ENDPART
init_object:    >PART 'init object'
                  bsr   init_buffer1
init_object_3:    add.w d0,d0           ;d0 holds init routine number
                  add.w d0,d0
                  lea   init_rout(pc),a0 ;pointer to init routines
                  movea.l 0(a0,d0.w),a0 ;fetch routine number
                  jsr   (a0)
                  bsr.s e_init_object
                  rts
                ENDPART
e_init_object:  >PART 'execute init object'
                  movea.l current_obj(pc),a0
                  beq.s e_init_obj_e
                  adda.w (a0),a0
                  jsr   (a0)
e_init_obj_e:     rts

                ENDPART
init_objects_1: >PART 'init objects space'
                  lea   obj1_space,a0
                  move.w #frame_size_1,d0
                  bsr   init_frames
                  rts
                ENDPART
init_m_objects: >PART 'init multi object space'

                  lea   multi_space,a6
                  lea   multi_point(pc),a5
                  move.w #no_multi-1,d7

init_m_obj_2:     move.w #frame_size_2,d0
                  move.l a6,(a5)+
                  movea.l a6,a0
                  bsr   init_frames
                  lea   obj2_sp_s*2(a6),a6
                  dbra  d7,init_m_obj_2
                  rts

                ENDPART
creat_frac:     >PART 'creates a fraction table'
                  lea   frac_tab,a0     ;pointer to fraction table
                  move.l #65535,d3      ;
                  moveq #0,d0           ;first fraction -> 0
                  move.l d0,(a0)+       ;
                  move.w #200-1,d6      ;number of fractions
frac_l:           addq.w #1,d0          ;next fraction
                  move.w d0,d1          ;
                  moveq #16-1,d2        ;number of shifts
log_l:            rol.w #1,d1           ;shift until bit ys found
                  dbcs  d2,log_l        ;
                  move.w d2,(a0)+       ;store nu}ber of shifts
                  move.l d3,d4          ;init fraction
                  lsl.l d2,d4           ;number of shifts left
                  divu  d0,d4           ;(65535^(log(x)/log(2))/x
                  move.w d4,d5          ;copy
                  swap  d4              ;rest to low word
                  move.w d0,d2          ;copy x
                  lsr.w #1,d2           ;1/2*x
                  cmp.w d2,d4           ;if 1/2*x=>rest
                  ble.s no_round        ;round down
                  addq.w #1,d5          ;round up
no_round:         move.w d5,(a0)+       ;store fraction
                  dbra  d6,frac_l       ;next
                  rts
                ENDPART
init_param:     >PART 'init parameters'
                  lea   parameters(pc),a6 ;pointer to parameter block
                  lea   project_buf(pc),a0 ;pointer to projected points buffer
                  lea   flag_buf(pc),a2 ;pointer to lines already calculated
                  move.l a0,p_xy(a6)    ;
                  move.l a2,line_flag(a6) ;
                  move.l a3,y_steps(a6) ;
                  bsr.s clear_par
                  rts                   ;
                ENDPART
clear_par:      >PART 'reset all parameters'
                  lea   parameters(pc),a6
                  moveq #0,d0
                  move.w d0,rot_x(a6)   ;
                  move.w d0,rot_y(a6)   ;
                  move.w d0,rot_z(a6)   ;
                  move.w d0,add_x(a6)   ;
                  move.w d0,add_y(a6)   ;
                  move.w d0,add_z(a6)   ;
                  move.w d0,x_co(a6)    ;
                  move.w d0,y_co(a6)    ;
                  move.w #400,z_co(a6)  ;
                  lea   super_b,a0      ;
                  move.l a0,d0          ;
                  lsr.w #3,d0           ;
                  add.w d0,d0           ;
                  move.w d0,d1          ;
                  move.w d0,d2          ;
                  add.w #clip_space,d2  ;
                  move.w d2,add_c2      ;
                  add.w #mid_x+clip_space,d1 ;
                  move.w d1,x_m(a6)     ;
                  move.w d0,d1          ;
                  add.w #min_x+clip_space,d1
                  move.w d1,s_x_min(a6) ;
                  move.w d0,d1          ;
                  add.w #max_x-1+clip_space,d1
                  move.w d1,s_x_max(a6) ;
                  move.w #mid_y/4,y_m(a6) ;
                  move.w #3,s_y_min(a6) ;
                  move.w #(31500/4)-66,squash_c(a6) ;
                  move.w #(max_y)/4,s_y_max(a6) ;
                  rts
                ENDPART
set_par:        >PART 'set all parameters'
                  lea   parameters(pc),a6
                  moveq #0,d0
                  move.w d0,rot_x(a6)   ;
                  move.w d0,rot_y(a6)   ;
                  move.w d0,rot_z(a6)   ;
                  move.w d0,add_x(a6)   ;
                  move.w d0,add_y(a6)   ;
                  move.w d0,add_z(a6)   ;
                  move.w d0,x_co(a6)    ;
                  move.w d0,y_co(a6)    ;
                  move.w #1200,z_co(a6) ;
                  lea   super_b,a0      ;
                  move.l a0,d0          ;
                  lsr.w #3,d0           ;
                  add.w d0,d0           ;
                  move.w d0,d1          ;
                  add.w #mid_x+clip_space,d1 ;
                  move.w d1,x_m(a6)     ;
                  move.w d0,d1          ;
                  add.w #min_x+clip_space,d1
                  move.w d1,s_x_min(a6) ;
                  move.w d0,d1          ;
                  move.w d0,d2          ;
                  add.w #clip_space,d2  ;
                  move.w d2,add_c2      ;
                  add.w #max_x-1+clip_space,d1
                  move.w d1,s_x_max(a6) ;
                  move.w #(3+max_y)/2,y_m(a6) ;
                  move.w #3,s_y_min(a6) ;
                  move.w #31500-16,squash_c(a6) ;
                  move.w #max_y-1,s_y_max(a6) ;
                  rts
                ENDPART
set_par_s:      >PART 'set all parameters for single'
                  lea   parameters(pc),a6
                  moveq #0,d0
                  move.w d0,rot_x(a6)   ;
                  move.w d0,rot_y(a6)   ;
                  move.w d0,rot_z(a6)   ;
                  move.w d0,add_x(a6)   ;
                  move.w d0,add_y(a6)   ;
                  move.w d0,add_z(a6)   ;
                  move.w d0,x_co(a6)    ;
                  move.w d0,y_co(a6)    ;
                  move.w #1500,z_co(a6) ;
                  lea   super_b,a0      ;
                  move.l a0,d0          ;
                  lsr.w #3,d0           ;
                  add.w d0,d0           ;
                  move.w d0,d1          ;
                  add.w #mid_x+clip_space,d1 ;
                  move.w d1,x_m(a6)     ;
                  move.w d0,d1          ;
                  add.w #min_x+clip_space,d1
                  move.w d1,s_x_min(a6) ;
                  move.w d0,d1          ;
                  move.w d0,d2          ;
                  add.w #clip_space,d2  ;
                  move.w d2,add_c2      ;
                  add.w #max_x-1+clip_space,d1
                  move.w d1,s_x_max(a6) ;
                  move.w #mid_y,y_m(a6) ;
                  move.w #min_y,s_y_min(a6) ;
                  move.w #31500,squash_c(a6) ;
                  move.w #max_y-1,s_y_max(a6) ;
                  rts
                ENDPART
init_or:        >PART 'init OR polygons'

                  lea   parameters(pc),a6
                  move.w #0,clear_pat(a6)
                  move.w #-1,fill_pat(a6)
                  move.w #0,and_or(a6)
                  move.w #0,poly_flag(a6)
                  bsr   init_objects_1
                  bsr   init_poly
                  rts
                ENDPART
init_and:       >PART 'init AND polygons'
                  lea   parameters(pc),a6
                  move.w #-1,clear_pat(a6)
                  move.w #0,fill_pat(a6)
                  move.w #1,and_or(a6)
                  move.w #0,poly_flag(a6)
                  bsr   init_poly
                  rts
                ENDPART
init_long:      >PART 'init long polygons'
                  lea   parameters(pc),a6
                  move.w #0,clear_pat(a6)
                  move.w #-1,fill_pat(a6)
                  move.w #0,and_or(a6)
                  move.w #1,poly_flag(a6)
                  bsr   c_long_bl
                  bsr   code_long_cl
                  bsr   init_n_poly
                  rts
                ENDPART
init_word_or:   >PART 'init word OR polygons'
                  lea   parameters(pc),a6
                  move.w #0,clear_pat(a6)
                  move.w #-1,fill_pat(a6)
                  move.w #0,and_or(a6)
                  move.w #-1,poly_flag(a6)

                  bsr   c_poly_bl
                  bsr   code_clr_routs
                  bsr   init_n_poly
                  rts
                ENDPART
init_word_and:  >PART 'init word AND polygons'
                  lea   parameters(pc),a6
                  move.w #-1,clear_pat(a6)
                  move.w #0,fill_pat(a6)
                  move.w #1,and_or(a6)
                  move.w #-1,poly_flag(a6)
                  bsr   c_poly_bl
                  bsr   code_clr_routs
                  bsr   init_n_poly
                  rts
                ENDPART
init_multi_and: >PART 'init word AND multi'
                  lea   parameters(pc),a6
                  move.w #-1,clear_pat(a6)
                  move.w #0,fill_pat(a6)
                  move.w #1,and_or(a6)
                  move.w #-2,poly_flag(a6)
                  bsr   c_poly_bl
                  bsr   code_clr_routs
                  bsr   init_n_poly
                  rts
                ENDPART
init_frames:    >PART 'init all frame pointers'

*a0 pointer to object space
*d0 frame size
                  move.w d0,d3          ;copy
                  add.w d3,d3           ;
                  clr.w (a0)+           ;index counter ->0
                  lea   frame_off(a0),a1 ;pointer to frame space
                  move.w #no_screens*2-1,d0 ;do it as many as there are screens
init_frames_l:    move.l a1,(a0)+       ;store pointer to frame
                  move.w #max_v,d1      ;init number of poly's to init
                  lea   4(a1),a2        ;copy pointer
                  move.l a2,(a1)+       ;
                  addq.l #4,a2          ;
                  move.l a2,(a1)+       ;
                  moveq #-1,d2          ;
init_frames_l_2:  move.w d2,(a2)+       ;init poly
                  dbra  d1,init_frames_l_2 ;next poly
                  adda.w d3,a1          ;add frame size
                  dbra  d0,init_frames_l ;next frame
                  rts
                ENDPART
init_ripple:    >PART 'init ripple parameters'
                  move.l #rip_tab,ripple_p ;init pointer to ripple table
                  move.w #0,ripple_flag ;ripple flag =0
                  rts
                ENDPART
init_buffer1:   >PART 'init buffers type 1'
                  lea   obj_buf,a0
                  lea   buffer1,a1
                  move.l #obj_buf_dat,(a0)+
                  move.l a1,(a0)+
                  adda.l #obj_buf_len1,a1
                  move.l a1,(a0)+
                  move.w #max_obj_add,(a0)+

                  lea   scan_buf,a0
                  move.l #scan_buf_dat,(a0)+
                  move.l a1,(a0)+
                  adda.l #scan_buf_len1,a1
                  move.l a1,(a0)+
                  move.w #max_scan_add,(a0)+

                  lea   poly_buf,a0
                  move.l #poly_buf_dat,(a0)+
                  move.l a1,(a0)+
                  adda.l #poly_buf_len1,a1
                  move.l a1,(a0)+
                  move.w #max_poly_add,(a0)+

                  lea   pal_buf,a0
                  move.l #pal_buf_dat,(a0)+
                  move.l a1,(a0)+
                  adda.l #palette_buf_len1,a1
                  move.l a1,(a0)+
                  move.w #max_pal_add,(a0)+
                  bsr   init_buffer
                  rts

                ENDPART
skip_frame:     >PART 'skip next frame'
                  move.l a5,-(sp)
                  bsr   animate
                  bsr   calc_all
                  movea.l (sp)+,a5
                  movea.l current_obj(pc),a0
                  adda.w 2(a0),a0
                  jsr   (a0)
                  rts
                ENDPART

*PROJECTION ROUTINES

make_matrix:    >PART 'create rotation matrix'

*a6 pointer to parameter block

                  lea   matrix(pc),a0   ;pointer to RECORD(Matrix)
                  lea   sin_cos_tab,a1  ;pointer to third period of sinus
                  move.w rot_z(a6),d0   ;init angles
                  move.w rot_y(a6),d1   ;
                  move.w rot_x(a6),d2   ;
                  move.w #(period-1)*4,d7 ;
                  and.w d7,d0           ;
                  and.w d7,d1           ;
                  and.w d7,d2           ;
                  bsr.s rot_matrix      ;create matrix
                  rts
                ENDPART
rot_matrix:     >PART 'fast matrix'

*Calc rotation matrix using no muls.
*a0 points to struc M->{1..9}.w
*a1 points to sinus/cosinus tabel
*d0 angle z
*d1 angle y
*d2 angle x
*Returns (1..9).w matrix elements in struc M->{}.


                  move.w d0,d3          ;4  copy a
                  move.w d0,d4          ;4  '     '
                  add.w d2,d3           ;4  a+c
                  sub.w d2,d4           ;4  a-c
                  and.w d7,d3           ;4
                  and.w d7,d4           ;4
                  move.l 0(a1,d3.w),d5  ;18 sin in high,cosinus in low word
                  move.l 0(a1,d4.w),d6  ;18 '                             '
                  add.w d5,d6           ;4  cos(a+b)+cos(a-b)
                  move.w d6,8(a0)       ;8  store
                  swap  d5              ;4
                  swap  d6              ;4
                  add.w d5,d6           ;4  sin(a+b)+cos(a-b)
                  move.w d6,2(a0)       ;8  store
                  move.w 0(a1,d2.w),d5  ;14 sin(c)
                  add.w d5,d5           ;4  *2
                  neg.w d5              ;4  -
                  move.w d5,14(a0)      ;8  store
                  move.w d1,d3          ;4  copy b
                  move.w d1,d4          ;$  copy b
                  add.w d2,d3           ;4  b+c
                  sub.w d2,d4           ;4  b-c
                  and.w d7,d3           ;4
                  and.w d7,d4           ;4
                  move.l 0(a1,d3.w),d5  ;18 sin in high,cosinus in low word
                  move.l 0(a1,d4.w),d6  ;18 '                             '
                  add.w d5,d6           ;4  cos(b+c)+cos(b-c)
                  move.w d6,16(a0)      ;4  store
                  swap  d5              ;4
                  swap  d6              ;4
                  add.w d5,d6           ;4  sin(b+c)+sin(b-c)
                  move.w d6,12(a0)      ;12 store
                  move.w d0,d3          ;4  copy a
                  add.w d1,d0           ;4  a+b
                  sub.w d1,d3           ;4  a-b
                  move.w d2,d4          ;4  copy c
                  move.w d2,d1          ;4  '    '
                  neg.w d1              ;4  -c
                  move.w d1,d5          ;4  copy -c
                  add.w d0,d1           ;4  a+b-c
                  add.w d0,d2           ;4  a+b+c
                  add.w d3,d4           ;4  a-b+c
                  add.w d3,d5           ;4  a-b-c
                  and.w d7,d0           ;4
                  and.w d7,d1           ;4
                  and.w d7,d2           ;4
                  and.w d7,d3           ;4
                  and.w d7,d4           ;4
                  and.w d7,d5           ;4
                  move.l 0(a1,d0.w),d0  ;18
                  move.l 0(a1,d1.w),d1  ;18
                  move.l 0(a1,d2.w),d2  ;18
                  move.l 0(a1,d3.w),d3  ;18
                  move.l 0(a1,d4.w),d4  ;18
                  move.l 0(a1,d5.w),d5  ;18
                  swap  d0              ;4
                  swap  d3              ;4
                  sub.w d2,d1           ;4
                  sub.w d5,d4           ;4
                  asr.w #1,d1           ;8
                  asr.w #1,d4           ;8
                  sub.w d0,d1           ;4  A
                  sub.w d3,d4           ;4  B
                  move.w d1,d6          ;4  copy
                  add.w d4,d6           ;4  A+B
                  move.w d6,6(a0)       ;8  store
                  sub.w d4,d1           ;4  A-B
                  move.w d1,4(a0)       ;12 store
                  swap  d0              ;4
                  swap  d3              ;4
                  swap  d1              ;4
                  swap  d2              ;4
                  swap  d4              ;4
                  swap  d5              ;4
                  sub.w d2,d1           ;4
                  sub.w d5,d4           ;4
                  asr.w #1,d1           ;8
                  asr.w #1,d4           ;8
                  add.w d3,d4           ;4  D
                  add.w d0,d1           ;4  C
                  move.w d1,d6          ;4  copy
                  add.w d4,d6           ;4  C+D
                  move.w d6,(a0)        ;8 store
                  sub.w d1,d4           ;4  C-D
                  move.w d4,10(a0)      ;12 store
                  rts                   ;16

****************************************;a total of 528

                ENDPART
project_3d:     >PART 'rotate and project object'

*a0 pointer to RECORD(Object)
*a6 pointer to parameter block

                  lea   origin_buf(pc),a5 ;buffer to origin data
                  lea   x_coord+max_c*12(pc),a3 ;pointer to mid of x-coord list
                  move.w squash_c(pc),d7 ;
                  movea.l a3,a4         ;copy pointer
                  lea   12(a3),a3       ;0 -> zero
                  movea.l a0,a2         ;init pointer to object
                  adda.w 4(a0),a2       ;fetch pointer to RECORD(Points)
                  lea   matrix(pc),a1   ;init pointer to matrix
                  movem.w (a1)+,d1-d3   ;fetch matrix elements m11,m21,m31
                  muls  d7,d2           ;
                  swap  d2              ;
                  add.l d2,d2           ;

                  move.w (a2)+,d4       ;fetch rotation origin
                  move.w d4,d5          ;copy
                  move.w d5,d6          ;
                  muls  d1,d4           ;rotate
                  muls  d2,d5           ;
                  muls  d3,d6           ;
                  movem.l d4-d6,(a5)    ;store

                  move.w (a2)+,d0       ;fetch number of x-coords to rotate
                  bra.s proj_x          ;

x_loop:           move.w (a2)+,d4       ;fetch x-coord
                  move.w d4,d5          ;copy
                  move.w d4,d6          ;copy
                  muls  d1,d4           ;x'
                  muls  d2,d5           ;y'
                  muls  d3,d6           ;z'
                  move.l d4,(a3)+       ;store
                  move.l d5,(a3)+       ;
                  move.l d6,(a3)+       ;
                  neg.l d4              ;store negative
                  neg.l d5              ;
                  neg.l d6              ;
                  movem.l d4-d6,-(a4)   ;
proj_x:           dbra  d0,x_loop       ;
                  lea   y_coord+max_c*12(pc),a3 ;pointer to mid of y-coord list
                  movea.l a3,a4         ;copy pinter
                  lea   12(a3),a3       ;0 -> zero
                  movea.l a0,a2         ;pointer to object
                  adda.w 6(a0),a2       ;fetch pointer to RECORD(Points)
                  movem.w (a1)+,d1-d3   ;fetch matrix elements m12,m22,m32
                  muls  d7,d2           ;
                  swap  d2              ;
                  add.l d2,d2           ;

                  move.w (a2)+,d4       ;fetch rotation origin
                  move.w d4,d5          ;copy
                  move.w d5,d6          ;
                  muls  d1,d4           ;rotate
                  muls  d2,d5           ;
                  muls  d3,d6           ;
                  add.l d4,(a5)+        ;add
                  add.l d5,(a5)+        ;
                  add.l d6,(a5)+        ;

                  move.w (a2)+,d0       ;fetch number of y-coords to rotate
                  bra.s proj_y          ;

y_loop:           move.w (a2)+,d4       ;fetch y-cord
                  move.w d4,d5          ;copy
                  move.w d4,d6          ;copy
                  muls  d1,d4           ;x'
                  muls  d2,d5           ;y'
                  muls  d3,d6           ;z'
                  move.l d4,(a3)+       ;store
                  move.l d5,(a3)+       ;
                  move.l d6,(a3)+       ;
                  neg.l d4              ;store negative
                  neg.l d5              ;
                  neg.l d6              ;
                  movem.l d4-d6,-(a4)   ;
proj_y:           dbra  d0,y_loop       ;
                  lea   z_coord+max_c*12(pc),a3 ;pointer to mid of z-coord list
                  movea.l a3,a4         ;copy pointer
                  lea   12(a3),a3       ;0 -> zero
                  movea.l a0,a2         ;pointer to object
                  adda.w 8(a0),a2       ;fetch pointer to RECORD(Points)
                  movem.w (a1)+,d1-d3   ;fetch matrix elements m13,m23,m33
                  muls  d7,d2           ;
                  swap  d2              ;
                  add.l d2,d2           ;

                  move.w (a2)+,d4       ;fetch rotation origin
                  move.w d4,d5          ;copy
                  move.w d5,d6          ;
                  muls  d1,d4           ;rotate
                  muls  d2,d5           ;
                  muls  d3,d6           ;
                  add.l d6,-(a5)        ;add
                  add.l d5,-(a5)        ;
                  add.l d4,-(a5)        ;

                  move.w (a2)+,d0       ;fetch number of z-coords to rotate
                  bra.s proj_z          ;

z_loop:           move.w (a2)+,d4       ;fetch z-coord
                  move.w d4,d5          ;copy
                  move.w d4,d6          ;copy
                  muls  d1,d4           ;x'
                  muls  d2,d5           ;y'
                  muls  d3,d6           ;z'
                  move.l d4,(a3)+       ;store
                  move.l d5,(a3)+       ;
                  move.l d6,(a3)+       ;
                  neg.l d4              ;store negative
                  neg.l d5              ;
                  neg.l d6              ;
                  movem.l d4-d6,-(a4)   ;
proj_z:           dbra  d0,z_loop       ;

                  adda.w 10(a0),a0      ;fetch pointer to RECORD(3d_p)
                  move.w (a0)+,d0       ;fetch number of xyz indices
                  subq.w #1,d0          ;-1 for dbf
                  lea   xyz_pointers(pc),a4 ;pointer to pointers
                  movem.l (a4),d4-d6    ;
                  movem.l d4-d6,-(sp)   ;
                  moveq #0,d4           ;low word clear
                  move.w z_co(a6),d4    ;init z world coordinate
                  swap  d4              ;
                  moveq #0,d5           ;low word clear
                  move.w x_co(a6),d5    ;init x world coordinate
                  swap  d5              ;
                  asr.l #4,d5           ;
                  moveq #0,d6
                  move.w y_co(a6),d6    ;init y world coordinate
                  muls  squash_c(a6),d6 ;
                  asr.l #3,d6           ;

                  add.l (a5)+,d5        ;add rotation origin
                  add.l (a5)+,d6        ;
                  add.l (a5)+,d4        ;

                  lea   xyz_p(pc),a4    ;
                  movea.l p_xy(a6),a5   ;fetch pointer to destination points

project_l:        movem.l (sp),a1-a3    ;restore pointers
                  movem.w (a0)+,d1-d3   ;fetch x,y,z index
                  adda.w d1,a1          ;index to coordinates
                  adda.w d2,a2          ;
                  adda.w d3,a3          ;
                  movem.l (a1)+,d1-d3   ;calc x,y,z coord
                  add.l (a2)+,d1        ;
                  add.l (a3)+,d1        ;
                  add.l (a2)+,d2        ;
                  add.l (a3)+,d2        ;
                  add.l (a2)+,d3        ;
                  add.l (a3)+,d3        ;
                  add.l d4,d3           ;move through world
                  add.l d5,d1           ;
                  add.l d6,d2           ;
                  swap  d3              ;
                  rol.l #4,d3           ;
                  asr.l #3,d1           ;
                  asr.l #3,d2           ;
                  divs  d3,d1           ;project to x',y'
                  divs  d3,d2           ;
                  add.w x_m(a6),d1      ;adjust to mid screen
                  add.w y_m(a6),d2      ;
                  move.w d1,(a5)+       ;store x',y'
                  move.w d2,(a5)+       ;
                  dbra  d0,project_l    ;next
                  lea   4*3(sp),sp      ;
                  rts
                ENDPART


*POLYGON/OBJECT ROUTINES

init_pal:       >PART 'init new pal'
                  movem.l new_buf(pc),d0-d7
                  movem.l d0-d7,$ffff8240.w
                  rts
                ENDPART
swap_buffers:   >PART 'swap buffers'

* a0 pointer to object space
                  movea.l a0,a1         ;copy pointer
                  move.w (a0)+,d0       ;fetch frame index
                  adda.w d0,a0          ;calc frame index
                  move.l (a0),d1        ;fetch first frame pointer
                  move.l 4(a0),d2       ;'   ' second'           '
                  move.l d1,old_obj_p   ;copy to global pointers
                  move.l d2,new_obj_p   ;
                  move.l d2,(a0)        ;swap frame pointers
                  move.l d1,4(a0)       ;
                  addq.w #8,d0          ;next frame index
                  cmp.w #frame_off,d0   ;if not exeeding no of screens
                  blt.s no_swap_reset   ;jump
                  clr.w d0              ;reset index
no_swap_reset:    move.w d0,(a1)        ;copy for later
                  rts                   ;
                ENDPART
animate:        >PART 'animate object'
                  move.w add_x(pc),d0
                  add.w d0,rot_x
                  move.w add_y(pc),d0
                  add.w d0,rot_y
                  move.w add_z(pc),d0
                  add.w d0,rot_z
                  rts
                ENDPART
scan_angle:     >PART 'scan angles'
                  clr.w d0
                  move.b $fffffc02.w,d0
                  sub.w #59,d0
                  blt.s scan_angle_e
                  cmp.w #10,d0
                  bge.s scan_angle_e
                  add.w d0,d0
                  add.w d0,d0
                  lea   scan_case(pc),a0
                  movea.l 0(a0,d0.w),a0
                  jsr   (a0)
scan_angle_e:     rts
                ENDPART
calc_all:       >PART 'do all calculations'
                  lea   parameters(pc),a6
                  bsr   make_matrix
                  movea.l current_obj(pc),a0
                  bsr   project_3d
                  rts
                ENDPART
draw_all:       >PART 'draw whole object'

                  bsr   update_p        ;update pointers

;a0 now holds pointer to new Scan_obj
;a1 now holds pointer to new palette
;a2 now holds pointer to P_done

                  movea.l new_obj_p(pc),a5 ;pointer to new object space
                  move.l a0,(a5)+       ;store pointer to Scan_obj
                  tst.l (a0)+           ;if NIL pointer
                  beq   draw_all_e3     ;

                  movem.l (a1)+,d0-d7
                  movem.l d0-d7,new_buf

                  movea.l a5,a1         ;copy pointer
                  bsr   object_scan     ;scan current object
                  move  #$0300,sr       ;in user mode -> polygon rout uses stack

                  movea.l old_obj_p(pc),a0 ;

                  movea.l (a0),a0       ;
                  move.l (a0)+,d0       ;

                  move.l a0,-(sp)       ;

clear_lin:        tst.l d0              ;
                  beq.s draw_pol        ;

                  movea.l d0,a1         ;
                  move.w (a1)+,d0       ;fetch number of line sequences
                  bmi.s draw_pol        ;
                  bra.s clear_lin_l_3   ;
;
clear_lin_l:      tst.w (a1)            ;if line sequence
                  bpl.s clear_lin_l_2   ;jump
                  addq.l #2,a1          ;next line seq
                  bra.s clear_lin_l_3   ;
;
clear_lin_l_2:    move.w d0,-(sp)       ;store parameter
                  move.w 2(a1),d0       ;fetch color
                  movea.l 4(a1),a2      ;fetch pointer to line code
                  bsr   draw_line       ;draw the line
                  move.w (sp)+,d0       ;restore parameter
                  addq.l #8,a1          ;
clear_lin_l_3:    dbra  d0,clear_lin_l  ;next line seq
;

draw_pol:         movea.l (sp)+,a0      ;unstack it
                  movea.l a1,a2         ;copy pointer to clear parameters
                  movea.l new_obj_p(pc),a1 ;pointer to new object space

                  movea.l (a1),a1       ;fetch pointer to Scan_obj
                  movea.l (a1)+,a3      ;

                  move.l a1,-(sp)       ;store for later use
                  move.w poly_flag(pc),d0 ;if no long polygons
                  beq.s draw_no_long    ;jump
                  bmi.s draw_pol_word   ;
                  movea.l screen1,a0    ;pointer to screen
                  moveq #0,d0           ;init clear
                  jsr   clear           ;clear screen
                  bra.s draw_word_cont  ;continue

draw_pol_word:    cmp.w #-2,d0          ;
                  bne.s draw_pol_word_2 ;

                  movem.l 2(a3),d0-d1   ;
                  movea.l multi_p(pc),a4 ;
                  move.l d0,(a4)+       ;
                  move.l d1,(a4)+       ;
                  move.l a4,multi_p     ;
                  addq.w #1,multi_p_c   ;
                  bra.s draw_word_cont  ;

draw_pol_word_2:  tst.w (a0)            ;if no polygons last frame
                  bmi.s draw_word_cont  ;jump over clear section

                  movem.l a0-a1,-(sp)   ;store
                  movem.w (a2),d0-d3    ;fetch old min max
                  bsr   clear_it        ;
                  movem.l (sp)+,a0-a1   ;restore
draw_word_cont:   move.w (a1)+,d0       ;fetch number of polygons
                  subq.w #1,d0          ;-1 for dbf
                  bmi   draw_lin        ;if no polygons,jump
draw_long_l:      tst.w (a1)            ;if polygon
                  bpl.s draw_long_l_2   ;
                  addq.l #2,a1          ;next polgon
                  bra.s draw_long_l_3   ;

draw_long_l_2:    bsr   draw_long       ;draw long polygon
                  lea   28(a1),a1       ;next
draw_long_l_3:    dbra  d0,draw_long_l  ;
                  bra   draw_lin        ;next lines

draw_no_long:     clr.w no_no_delta     ;clear counter of no delta polygons
                  lea   no_delta_buf(pc),a2 ;init buffer to store no delta polygons
                  addq.l #2,a0          ;skip number of poly of old object
                  move.w (a1)+,d0       ;fetch number of polygons
                  subq.w #1,d0          ;-1 for dbf
                  bmi.s draw_lin        ;if minus -> no polys
;
draw_pol_l:       move.w (a0),d1        ;fetch poly number
                  move.w (a1),d2        ;
                  cmp.w d1,d2           ;if same
                  beq.s draw_pol_l_3    ;jump
                  tst.w d1              ;if old poly number negative
                  bmi.s draw_pol_l_2    ;jump
                  bsr   clear_poly      ;else clear old poly
                  lea   28(a0),a0       ;next element in old SCAN sequence
                  addq.l #2,a1          ;'             ' new '           '
                  bra.s draw_pol_l_5    ;
draw_pol_l_2:     addq.w #1,no_no_delta ;
                  move.l a1,(a2)+       ;
                  addq.l #2,a0          ;
                  lea   28(a1),a1       ;next SCAN record
                  bra.s draw_pol_l_5    ;
draw_pol_l_3:     tst.w d1              ;if negative
                  bmi.s draw_pol_l_4    ;jump
                  tst.w 2(a0)           ;else if delta flag=0
                  beq.s do_delta        ;
                  addq.w #1,no_no_delta ;number of no delta polygons
                  move.l a1,(a2)+       ;store new poly for later
                  bsr   clear_poly      ;clear old poly
                  lea   28(a0),a0       ;next SCAN record
                  lea   28(a1),a1       ;
                  bra.s draw_pol_l_5
do_delta:         bsr   delta_poly      ;do delta polygon
                  lea   28(a0),a0       ;
                  lea   28(a1),a1       ;next SCAN record
                  bra.s draw_pol_l_5    ;
draw_pol_l_4:     addq.l #2,a0          ;
                  addq.l #2,a1          ;next SCAN record
draw_pol_l_5:     dbra  d0,draw_pol_l   ;

                  move.l a1,-(sp)       ;store pointer
                  move.w no_no_delta(pc),d0 ;fetch number of no delta polygons
                  lea   no_delta_buf(pc),a2 ;pointer to no delta polygon identifiers
                  bra.s no_delta_l_2    ;jump in loop
no_delta_l:       movea.l (a2)+,a1      ;fetch pointer to SCAN record
                  bsr   draw_poly_o_a   ;draw new polygon
no_delta_l_2:     dbra  d0,no_delta_l   ;until no more
                  movea.l (sp)+,a1      ;unstack pointer

;
draw_lin:         move.w (a1)+,d0       ;fetch number of line sequences
                  bra.s draw_lin_l_3    ;
;
draw_lin_l:       tst.w (a1)            ;if line sequence
                  bpl.s draw_lin_l_2    ;jump
                  addq.l #2,a1          ;next line seq
                  bra.s draw_lin_l_3    ;
;
draw_lin_l_2:     move.w d0,-(sp)       ;store parameter
                  move.w 2(a1),d0       ;fetch color
                  movea.l 4(a1),a2      ;fetch pointer to line code
                  bsr   draw_line       ;draw the line
                  move.w (sp)+,d0       ;restore parameter
                  addq.l #8,a1          ;
draw_lin_l_3:     dbra  d0,draw_lin_l   ;next line seq
;
draw_all_e:       movea.l (sp)+,a1      ;restore pointer to new Scan_obj

draw_all_e2:      trap  #0              ;supervisor mode
draw_all_e3:      cmpi.b #98,$fffffc02.w

                  bne.s bla
                  not.w $ffff8240.w
bla:              rts

                ENDPART
draw_long:      >PART 'draw single long polygon'

*Same remarks as draw_poly_o_a
                  movem.l d0/a0-a2,-(sp)
                  move.l screen1,d5
                  moveq #%11111100,d4
                  move.w clear_pat(pc),d6
                  move.w fill_pat(pc),d7
                  ext.l d6
                  ext.l d7
                  add.w 4(a1),d5
                  move.w 6(a1),d1
                  move.w 8(a1),d0
                  sub.w d1,d0
                  addq.w #1,d0
                  move.w #160,d3
                  lea   mul_160,a2
                  add.w d1,d1
                  add.w 0(a2,d1.w),d5
                  movea.l 20(a1),a0
                  clr.w 18(a1)
                  movea.l 24(a1),a1
                  bsr   normal_long
                  movem.l (sp)+,d0/a0-a2
                  rts
                ENDPART
draw_poly_o_a:  >PART 'draw single OR or AND polygon'

*Same remarks as draw_poly except for the OR or AND poly call

                  movem.l d0/a0-a2,-(sp)
                  move.l screen1,d5
                  moveq #%11111100,d4
                  move.w fill_pat(pc),d6
                  move.w clear_pat(pc),d7
                  ext.l d6
                  ext.l d7
                  add.w 4(a1),d5
                  move.w 6(a1),d1
                  move.w 8(a1),d0
                  sub.w d1,d0
                  addq.w #1,d0
                  move.w #160,d3
                  lea   mul_160,a2
                  add.w d1,d1
                  add.w 0(a2,d1.w),d5
                  movea.l 20(a1),a0
                  clr.w 18(a1)
                  movea.l 24(a1),a1
                  bsr   normal_draw_o_a
                  movem.l (sp)+,d0/a0-a2
                  rts
                ENDPART
clear_poly:     >PART 'clear single polygon'
                  movem.l d0/a0-a2,-(sp) ;
                  move.l screen1,d5     ;init screen pointer
                  moveq #%11111100,d4   ;init mask
                  move.w fill_pat(pc),d6 ;init fill pattern
                  move.w clear_pat(pc),d7 ;init clear pattern
                  ext.l d6              ;
                  ext.l d7              ;
                  add.w 4(a0),d5        ;
                  move.w 6(a0),d1       ;
                  move.w 8(a0),d0       ;
                  sub.w d1,d0           ;
                  addq.w #1,d0          ;
                  move.w #160,d3        ;
                  lea   mul_160,a2      ;
                  add.w d1,d1           ;
                  add.w 0(a2,d1.w),d5   ;
                  movea.l 20(a0),a5     ;init pointer to right coordinates
                  movea.l 24(a0),a6     ;'              'left '          '
                  tst.w 18(a0)          ;
                  beq.s rev_clr         ;
                  bsr   normal_clear    ;do normal draw
                  movem.l (sp)+,d0/a0-a2 ;
                  rts                   ;
rev_clr:          bsr   revers_clear    ;
                  movem.l (sp)+,d0/a0-a2 ;
                  rts
                ENDPART
delta_poly:     >PART 'calc and draw delta polygon'

* USING:
* a0 pointer to old polygon RECORD(Scan_pl)
* a1 pointer to new polygon RECORD(Scan_pl)


                  movem.l d0/a0-a2,-(sp) ;
                  moveq #%11111100,d4   ;init mask
                  move.w fill_pat(pc),d6 ;init fill pattern
                  move.w clear_pat(pc),d7 ;init clear pattern
                  ext.l d6              ;
                  ext.l d7              ;
                  move.l screen1,d5     ;init pointer to screen
                  addq.l #6,a0          ;skip parameters
                  move.w (a0)+,d0       ;old y-start
                  move.w (a0)+,d1       ;old y-end
                  addq.l #8,a0          ;skip pointers to RECORD(Sc_pl)
                  tst.w (a0)+           ;if swap flag
                  beq   delta_revers    ;jump
                  movea.l (a0)+,a5      ;pointer to old left jumps
                  movea.l (a0)+,a6      ;pointer to old right jumps
                  addq.l #4,a1          ;
                  add.w (a1)+,d5        ;add color
                  move.w (a1)+,d2       ;new y-start
                  move.w (a1)+,d3       ;new y-end
                  addq.l #8,a1          ;skip pointers
                  clr.w (a1)+           ;toggle swap case
                  movea.l (a1)+,a0      ;pointer to new left coords
                  movea.l (a1)+,a1      ;pointer to new right coords
                  cmp.w d1,d2           ;if new_start>old_end
                  bgt   ye_set_clr_nor  ;jump
                  cmp.w d0,d3           ;if new_end<old_start
                  blt   ye_set_clr_nor  ;jump
                  cmp.w d0,d2           ;y-start-new<->y-start
                  bgt.s ys_gt_nor       ;if new>old jump
                  beq.s yn_eq_yo_nor    ;if same jump
                  move.w d3,-(sp)       ;stack parameters
                  move.w d0,-(sp)       ;
                  move.w d1,-(sp)       ;
                  sub.w d2,d0           ;calc number of y-steps
                  add.w d2,d2           ;
                  lea   mul_160,a4      ;
                  add.w 0(a4,d2.w),d5   ;
                  move.w #160,d3        ;
                  bsr   normal_draw     ;draw first part
                  movem.w (sp)+,d1-d3   ;unstack
                  bra.s ys_eq_nor       ;jump to mid section
yn_eq_yo_nor:     add.w d0,d0           ;
                  lea   mul_160,a4      ;
                  add.w 0(a4,d0.w),d5   ;
                  bra.s ys_eq_nor       ;
ys_gt_nor:        movem.w d1-d3,-(sp)   ;stack parameters
                  exg   d0,d2           ;for positive result
                  sub.w d2,d0           ;calc number of y-steps
                  add.w d2,d2           ;
                  lea   mul_160,a4      ;
                  add.w 0(a4,d2.w),d5   ;
                  move.w #160,d3        ;
                  bsr   normal_clear    ;clear first part
                  movem.w (sp)+,d1-d3   ;unstack
ys_eq_nor:        cmp.w d1,d3           ;if new_end>old_end
                  bgt.s ye_gt_nor       ;jump
                  beq.s ye_eq_nor       ;jump if same
                  sub.w d3,d1           ;calc number of y-lines to cleab
                  sub.w d2,d3           ;calc number of y-lines to delta
                  move.w d1,-(sp)       ;stack parameter
                  move.w d3,d0          ;parameter passing
                  addq.w #1,d0          ;
                  bsr   normal_delta    ;do delta section
                  move.w (sp)+,d0       ;unstack parameter
                  move.w #160,d3        ;
                  bsr   normal_clear    ;do clear section
                  bra.s mega_end_nor    ;
ye_gt_nor:        sub.w d1,d3           ;calc number of y-lines to set
                  sub.w d2,d1           ;calc number of y-lines to delta
                  move.w d3,-(sp)       ;stack parameter
                  move.w d1,d0          ;parameter passing
                  addq.w #1,d0          ;
                  bsr   normal_delta    ;do delta section
                  move.w (sp)+,d0       ;unstack parameter
                  move.w #160,d3        ;
                  bsr   normal_draw     ;do set section
                  bra.s mega_end_nor    ;
ye_eq_nor:        sub.w d2,d1           ;calc number of y-steps
                  move.w d1,d0          ;
                  addq.w #1,d0          ;
                  bsr   normal_delta    ;do delta section
                  bra.s mega_end_nor    ;
ye_set_clr_nor:   sub.w d0,d1           ;calc number of y-lines to clear
                  exg   d0,d1           ;exg for parameter passing
                  sub.w d2,d3           ;calc number of y-lines to set
                  move.w d3,-(sp)       ;stack parameters
                  move.w d2,-(sp)       ;
                  move.l d5,-(sp)       ;
                  add.w d1,d1           ;start-y*2 to index mul table
                  lea   mul_160,a4      ;
                  add.w 0(a4,d1.w),d5   ;fetch 160 mul
                  addq.w #1,d0          ;
                  move.w #160,d3        ;
                  bsr   normal_clear    ;clear
                  move.l (sp)+,d5       ;
                  move.w (sp)+,d1       ;unstack parameters
                  move.w (sp)+,d0       ;
                  add.w d1,d1           ;same as above
                  lea   mul_160,a4      ;
                  add.w 0(a4,d1.w),d5   ;
                  addq.w #1,d0          ;
                  move.w #160,d3        ;
                  bsr   normal_draw     ;
mega_end_nor:     movem.l (sp)+,d0/a0-a2 ;
                  rts


*Same as above only with different poly calls

delta_revers:     movea.l (a0)+,a5
                  movea.l (a0)+,a6
                  addq.l #4,a1
                  add.w (a1)+,d5
                  move.w (a1)+,d2
                  move.w (a1)+,d3
                  addq.l #8,a1
                  move.w #-1,(a1)+
                  movea.l (a1)+,a0
                  movea.l (a1)+,a1
                  cmp.w d1,d2
                  bgt   ye_set_clr_rev
                  cmp.w d0,d3
                  blt   ye_set_clr_rev
                  cmp.w d0,d2
                  bgt.s ys_gt_rev
                  beq.s yn_eq_yo_rev
                  move.w d3,-(sp)
                  move.w d0,-(sp)
                  move.w d1,-(sp)
                  sub.w d2,d0
                  add.w d2,d2
                  lea   mul_160,a4
                  add.w 0(a4,d2.w),d5
                  move.w #160,d3
                  bsr   revers_draw
                  movem.w (sp)+,d1-d3
                  bra.s ys_eq_rev
yn_eq_yo_rev:     add.w d0,d0
                  lea   mul_160,a4
                  add.w 0(a4,d0.w),d5
                  bra.s ys_eq_rev
ys_gt_rev:        movem.w d1-d3,-(sp)
                  exg   d0,d2
                  sub.w d2,d0
                  add.w d2,d2
                  lea   mul_160,a4
                  add.w 0(a4,d2.w),d5
                  move.w #160,d3
                  bsr   revers_clear
                  movem.w (sp)+,d1-d3
ys_eq_rev:        cmp.w d1,d3
                  bgt.s ye_gt_rev
                  beq.s ye_eq_rev
                  sub.w d3,d1
                  sub.w d2,d3
                  move.w d1,-(sp)
                  move.w d3,d0
                  addq.w #1,d0
                  bsr   revers_delta
                  move.w (sp)+,d0
                  move.w #160,d3
                  bsr   revers_clear
                  bra.s mega_end_rev
ye_gt_rev:        sub.w d1,d3
                  sub.w d2,d1
                  move.w d3,-(sp)
                  move.w d1,d0
                  addq.w #1,d0
                  bsr   revers_delta
                  move.w (sp)+,d0
                  move.w #160,d3
                  bsr   revers_draw
                  bra.s mega_end_rev
ye_eq_rev:        sub.w d2,d1
                  move.w d1,d0
                  addq.w #1,d0
                  bsr   revers_delta
                  bra.s mega_end_rev
ye_set_clr_rev:   sub.w d0,d1
                  exg   d0,d1
                  sub.w d2,d3
                  move.w d3,-(sp)
                  move.w d2,-(sp)
                  move.l d5,-(sp)
                  add.w d1,d1
                  lea   mul_160,a4
                  add.w 0(a4,d1.w),d5
                  addq.w #1,d0
                  move.w #160,d3
                  bsr   revers_clear
                  move.l (sp)+,d5
                  move.w (sp)+,d1
                  move.w (sp)+,d0
                  add.w d1,d1
                  lea   mul_160,a4
                  add.w 0(a4,d1.w),d5
                  addq.w #1,d0
                  move.w #160,d3
                  bsr   revers_draw
mega_end_rev:     movem.l (sp)+,d0/a0-a2
                  rts

                ENDPART
object_scan:    >PART 'does a total object scan'

* USING:

* a0 pointer to RECORD(Scan_obj)
* a1 pointer to space IN OBJECT_SPACE
* a2 pointer to RECORD(P_done)

* RETURNING:

* a1 pointer to space IN OBJECT_SPACE

                  lea   calc_done(pc),a6 ;pointer to already calculated line
                  move.w (a2),d0        ;fetch P_done offset
                  moveq #8,d1           ;init count
clean_done_l:     clr.w 0(a6,d0.w)      ;clear flags
                  sub.w d1,d0           ;
                  bpl.s clean_done_l    ;until no more
                  move.w (a0)+,d0       ;number of poly's
                  subq.w #1,d0          ;-1 for dbf
                  bmi.s object_lines    ;if no polygons,end
;                  tst.w ripple_flag     ;if ripple
;                  bne.s calc_poly_l_r   ;
;calc_poly_l:      tst.w (a0)            ;if no polygon
;                  bpl.s calc_poly_l_2   ;jump
;                  addq.l #2,a0          ;next RECORD(Scan_pl)
;                  dbra  d0,calc_poly_l  ;next poly
;                  bra.s object_lines    ;end
;calc_poly_l_2:    bsr.s calc_perf       ;calc coordinates for poly
;                  lea   28(a0),a0       ;
;                  dbra  d0,calc_poly_l  ;next poly
;                  bra.s object_lines    ;end

calc_poly_l_r:    tst.w (a0)            ;if no polygon
                  bpl.s calc_poly_l_2_r ;jump
                  addq.l #2,a0          ;next RECORD(Scan_pl)
                  dbra  d0,calc_poly_l_r ;next poly
                  bra.s object_lines    ;end
calc_poly_l_2_r:  bsr.s calc_perf       ;calc coordinates for poly
                  lea   28(a0),a0       ;
                  dbra  d0,calc_poly_l_r ;next poly

object_lines:     move.w (a0)+,d0       ;fetch number of lines sequences
                  bra.s calc_line_l_3   ;

calc_line_l_1:    tst.w (a0)            ;if line sequence
                  bpl.s calc_line_l_2   ;jump
                  addq.l #2,a0          ;next line sequence
                  dbra  d0,calc_line_l_1 ;
                  rts                   ;
calc_line_l_2:    movea.l 4(a0),a4      ;pointer to line sequence
                  move.l a1,4(a0)       ;store pointer to RECORD(Sc_li)
                  move.l a0,-(sp)       ;store parameters
                  move.w d0,-(sp)       ;
                  bsr   do_line         ;calc line sequence
                  move.w (sp)+,d0       ;
                  movea.l (sp)+,a0      ;
                  lea   8(a0),a0        ;next sequence
calc_line_l_3:    dbra  d0,calc_line_l_1 ;
                  rts
                ENDPART
calc_perf:      >PART 'calc poly coordinates'

;a0 pointer to RECORD(Scan_pl)
;a1 pointer to destination polygon-coordinates
;a2 pointer to RECORD(P_done)
;a6 pointer to RECORD(L_done)

                  movea.l 10(a0),a3     ;pointer to left RECORD(Scan_p)
                  move.l a1,20(a0)      ;new pointer IN RECORD(Scan_p)
                  move.w (a3)+,d1       ;number of pieces
                  bpl.s c_p_left_1      ;
;special case -> one line

                  move.w (a3)+,d1       ;fetch left
                  move.w (a3)+,d2       ;fetch right
                  lsl.w #2,d1           ;*4
                  lsl.w #2,d2           ;*4
                  move.w d1,(a1)+       ;store
                  addq.l #2,a1          ;
                  move.l a1,24(a0)      ;store new pointer
                  move.w d2,(a1)+       ;
                  addq.l #2,a1          ;
                  rts                   ;

c_p_left_1:       subq.w #1,d1          ;-1 for dbf
;
c_p_left_neg:     move.w (a3)+,d5       ;fetch P_piece index
                  lea   2(a2,d5.w),a4   ;calc pointer to P_piece
                  movem.l (a4)+,d2-d3   ;fetch number h-lines,x-coord,rico
                  tst.w d2              ;if dy>dx
                  bpl   c_left_dy       ;jump
                  tst.l d3              ;test rico
                  blt.s c_p_left_neg2   ;if still positive, jump
                  move.l d2,d4          ;
                  swap  d4              ;
                  lsl.w #2,d4           ;
                  move.w d4,(a1)+       ;init start
                  tst.w 0(a6,d5.w)      ;if not already calculated
                  beq.s c_left_co_neg1  ;jump
                  bsr   copy_x          ;
                  dbra  d1,c_p_left_pos ;
                  move.w (a5)+,(a1)+    ;copy last point
                  bra   calc_p_right    ;

c_left_co_neg1:   add.l #$010000,d2     ;
                  bsr   calc_lin_dx     ;calc negative coords
                  dbra  d1,c_p_left_pos ;next coordinate and other rico
                  bra   calc_p_right_s  ;

c_p_left_neg2:    tst.w 0(a6,d5.w)      ;
                  beq.s c_left_co_neg2  ;
                  bsr   copy_x          ;
                  dbra  d1,c_p_left_neg ;next
                  move.w (a5)+,(a1)+    ;copy last point
                  bra   calc_p_right    ;

c_left_co_neg2:   add.l #$010000,d2     ;
                  bsr   calc_lin_dx     ;calc positive coords
c_p_left_neg3:    dbra  d1,c_p_left_neg ;next piece
                  move.l d2,d4          ;
                  asr.l #1,d3           ;
                  sub.l d3,d2           ;x- 1/2 rico
                  sub.l #32768,d2       ;
                  swap  d2              ;
                  move.w d2,(a1)+       ;to memory
                  bra.s calc_p_right    ;next

c_p_left_pos:     move.w (a3)+,d5       ;fetch P_piece index
                  lea   2(a2,d5.w),a4   ;calc pointer to P_piece
                  movem.l (a4)+,d2-d3   ;fetch number h-lines,x-coord,rico
                  tst.w d2              ;if dy>dx
                  bpl.s c_left_dy       ;jump
                  tst.l d3              ;test rico
                  bge.s c_p_left_pos2   ;if still negative, jump

                  subq.l #2,a1          ;INCONVEX -> correct last step

                  tst.w 0(a6,d5.w)      ;if not already calculated
                  beq.s c_left_co_pos1  ;
                  bsr   copy_x          ;copy
                  dbra  d1,c_p_left_neg ;
                  move.w (a5)+,(a1)+    ;copy last coord
                  bra.s calc_p_right    ;

c_left_co_pos1:   add.l #$010000,d2     ;
                  bsr   calc_lin_dx     ;calc positive coords
                  bra.s c_p_left_neg3   ;

c_p_left_pos2:    tst.w 0(a6,d5.w)      ;if not already calculated
                  beq.s c_left_co_pos2  ;jump
                  bsr   copy_x          ;copy
                  dbra  d1,c_p_left_pos ;next
                  bra.s calc_p_right    ;

c_left_co_pos2:   add.l #$010000,d2     ;
                  bsr   calc_lin_dx     ;calc negative coords
                  dbra  d1,c_p_left_pos ;next piece

calc_p_right_s:   asr.l #1,d3           ;
                  sub.l d3,d2           ;
                  sub.l #32768,d2       ;
                  swap  d2              ;
                  move.w d2,(a1)+       ;
                  bra.s calc_p_right_2  ;

c_left_dy:        tst.w 0(a6,d5.w)      ;
                  beq.s c_left_dy_co    ;
                  bsr   copy_x          ;
                  dbra  d1,c_p_left_neg ;
                  move.w (a5)+,(a1)+    ;
                  bra.s calc_p_right    ;

c_left_dy_co:     bsr   calc_lin_dy     ;
                  dbra  d1,c_p_left_neg ;
                  swap  d2              ;
                  move.w d2,(a1)+       ;

calc_p_right:     move.w d7,(a1)+       ;dummy last left
calc_p_right_2:   movea.l 14(a0),a3     ;pointer to right RECORD(Scan_p)
                  move.l a1,24(a0)      ;new pointer IN RECORD(Scan_p)
                  move.w (a3)+,d1       ;same as above except for rico (min/pos)
                  subq.w #1,d1

c_p_right_pos:    move.w (a3)+,d5       ;Same remarks except left<->right
                  lea   2(a2,d5.w),a4
                  movem.l (a4)+,d2-d3
                  tst.w d2
                  bpl   c_right_dy
                  tst.l d3
                  bge.s c_p_right_pos2

                  move.l d2,d4
                  swap  d4
                  lsl.w #2,d4
                  move.w d4,(a1)+
                  tst.w 0(a6,d5.w)
                  beq.s c_right_co_pos1
                  bsr   copy_x
                  dbra  d1,c_p_right_neg
                  bra   calc_perf_e

c_right_co_pos1:  bsr   calc_lin_dx
                  dbra  d1,c_p_right_neg
                  bra.s calc_perf_e_s

c_p_right_pos2:   tst.w 0(a6,d5.w)
                  beq.s c_right_co_pos2
                  bsr   copy_x
                  dbra  d1,c_p_right_pos
                  move.w (a5)+,(a1)+
                  bra   calc_perf_e

c_right_co_pos2:  bsr   calc_lin_dx
c_p_right_pos3:   dbra  d1,c_p_right_pos
                  move.l d2,d4
                  asr.l #1,d3
                  sub.l d3,d2
                  add.l #32768,d2
                  swap  d2
                  move.w d2,(a1)+
                  bra.s calc_perf_e

c_p_right_neg:    move.w (a3)+,d5
                  lea   2(a2,d5.w),a4
                  movem.l (a4)+,d2-d3
                  tst.w d2
                  bpl.s c_right_dy
                  tst.l d3
                  blt.s c_p_right_neg2

                  subq.l #2,a1

                  tst.w 0(a6,d5.w)
                  beq.s c_right_co_neg1
                  bsr.s copy_x
                  dbra  d1,c_p_right_pos
                  move.w (a5)+,(a1)+
                  bra.s calc_perf_e

c_right_co_neg1:  bsr   calc_lin_dx
                  bra.s c_p_right_pos3

c_p_right_neg2:   tst.w 0(a6,d5.w)
                  beq.s c_right_co_neg2
                  bsr.s copy_x
                  dbra  d1,c_p_right_neg
                  bra.s calc_perf_e

c_right_co_neg2:  bsr   calc_lin_dx
                  dbra  d1,c_p_right_neg

calc_perf_e_s:    asr.l #1,d3
                  sub.l d3,d2
                  add.l #32768,d2
                  swap  d2
                  move.w d2,(a1)+
                  rts

c_right_dy:       tst.w 0(a6,d5.w)
                  beq.s c_right_dy_co
                  bsr.s copy_x
                  dbra  d1,c_p_right_pos
                  move.w (a5)+,(a1)+
                  bra.s calc_perf_e

c_right_dy_co:    bsr   calc_lin_dy
                  dbra  d1,c_p_right_pos
                  swap  d2
                  move.w d2,(a1)+

calc_perf_e:      move.w d7,(a1)+
                  rts

                ENDPART
copy_x:         >PART 'copy existing line'

*USING:

*d2 number of h-lines (negative)
*a1 pointer to space in memory
*a4 pointer to RECORD(P_piece)
                  lea   2(a6,d5.w),a5   ;calc pointer
                  move.w (a5)+,d2       ;
                  movea.l (a5)+,a5      ;fetch pointer to calculated line
                  neg.w d2              ;
                  asr.w #1,d2           ;/2
                  bcc.s copy_even       ;if bit 0 was not 1,jump
                  move.w (a5)+,(a1)+    ;else,copy first word
                  addq.w #1,d2          ;
copy_even:        add.w d2,d2           ;*2 to index jump
                  bpl   copy_end        ;if positive -> end
                  add.w #200*2,d2       ;
                  jmp   2(pc,d2.w)      ;
                REPT 200
                  move.l (a5)+,(a1)+    ;copy two coords!
                ENDR
copy_end:         rts
                ENDPART
calc_lin:       >PART 'calc new line'

calc_lin_dy_2:    tst.w d2              ;
                  beq   calc_lin_e      ;

                  lea   0(a6,d5.w),a5   ;init pointer
                  addq.w #1,(a5)+       ;init flag
                  move.w d2,(a5)+       ;copy to memory
                  move.l a1,(a5)+       ;copy pointer to calculated line
                  lea   calc_x_jump,a5  ;pointer to jump-table
                  add.w d2,d2           ;
                  move.w 0(a5,d2.w),d4  ;fetch jump offset
                  move.w #32768,d2      ;x+0.5
                  add.l d2,d2           ;x*2
                  add.l d2,d2           ;x*4 to index jump-table
                  asl.l #2,d3           ;rico*4 '              '
                  add.l d3,d2           ;x+rico
                  bra.s calc_lin_3      ;

calc_lin_dy:      tst.w d2              ;
                  beq   calc_lin_e      ;if nr. h-lines zero,end

                  lea   0(a6,d5.w),a5   ;init pointer
                  addq.w #1,(a5)+       ;init flag
                  move.w d2,(a5)+       ;copy to memory
                  move.l a1,(a5)+       ;copy pointer to calculated line
                  lea   calc_x_jump,a5  ;pointer to jump-table
                  add.w d2,d2           ;
                  move.w 0(a5,d2.w),d4  ;fetch jump offset
                  move.w #32768,d2      ;x+0.5
                  add.l d2,d2           ;x*2
                  add.l d2,d2           ;x*4 to index jump-table
                  asl.l #2,d3           ;rico*4 '              '
                  bra.s calc_lin_3      ;

calc_lin_dx:      neg.w d2              ;
                  lea   0(a6,d5.w),a5   ;
                  addq.w #1,(a5)+       ;
                  move.w d2,(a5)+       ;
                  move.l a1,(a5)+       ;as above
                  lea   calc_x_jump,a5  ;
                  add.w d2,d2           ;
                  move.w 0(a5,d2.w),d4  ;
                  clr.w d2              ;
                  add.l d2,d2           ;x*2
                  add.l d3,d2           ;x+.5*rico
                  add.l d2,d2           ;x*4 to index jump-table
                  asl.l #2,d3           ;rico*4 '              '

calc_lin_3:       move.w d2,d6          ;
                  move.w d3,d7          ;
                  swap  d2              ;
                  swap  d3              ;
                  jmp   2(pc,d4.w)      ;do number of h-lines
                REPT 200
                  move.w d2,(a1)+       ;copy coord
                  add.w d7,d6           ;
                  addx.w d3,d2          ;
                ENDR
calc_lin_e:       swap  d2              ;
                  swap  d3              ;
                  move.w d6,d2          ;
                  rts
                ENDPART
calc_object:    >PART 'calc object parameters'

*USING:

*a0 pointer to RECORD(Object)
*a1 pointer to RECORD(Scan_obj) <- destination
*a2 pointer to RECORD(P_done)
*a3 pointer to space in memory to store an ARRAY OF RECORD(Scan_p)
*a6 pointer to parameter block

*RETURNING

*d1 number of RECORD(Scan_p)

*a1 points to end of Scan_obj
*a2 points to end of P_done
*a3 points to end of Scan_p

                  lea   clr_sp(pc),a4   ;pointer to clear block space
                  move.l #$3fff0000,d0  ;
                  move.w add_c2(pc),d1  ;adjust to screen
                  move.l d0,(a4)+       ;
                  swap  d0              ;
                  add.w d1,d0           ;
                  swap  d0              ;
                  add.w d1,d0           ;
                  move.l d0,(a4)+       ;

                  move.l a1,-(sp)       ;store pointer
                  addq.l #4,a1          ;skip pointer to Lines_scan
                  clr.w (a2)            ;no lines done yet
                  move.l a2,already(a6) ;init pointer to pieces Already done
                  move.l a3,record_space(a6) ;init pointer to current Record space
                  move.w 12(a0),d0      ;number of lines
                  lea   flag_buf(pc),a4 ;pointer to buffer
                  move.l a4,line_flag(a6) ;init pointer to RECORD(Line_f)
                  lea   project_buf(pc),a5 ;init pointer to projected points

                  moveq #0,d1           ;
                  bra.s clr_flag_l2     ;
clr_flag_l:       move.l d1,(a4)+       ;flag -> 0
clr_flag_l2:      dbra  d0,clr_flag_l   ;as many as there are lines

                  move.l a5,p_xy(a6)    ;
                  movea.l a0,a5         ;pointer to object
                  adda.w 14(a0),a5      ;pointer to RECORD(Planes)
                  move.w (a5)+,d0       ;fetch number of planes
                  move.w d0,(a1)+       ;store number of polygons
                  bra.s poly_add        ;enter loop

obj_plane_l:      move.l a0,-(sp)       ;store object pointer
                  movea.l a0,a2         ;copy
                  adda.w (a5)+,a0       ;init pointer to RECORD(Plane)
                  movem.l d0/a5,-(sp)   ;store parameters
                  bsr.s calc_poly       ;calc poly
                  movem.l (sp)+,d0/a5   ;restore parameters
                  movea.l (sp)+,a0      ;restore pointer to object
poly_add:         dbra  d0,obj_plane_l  ;next plane
object_line:      movea.l (sp)+,a5      ;restore pointer to Scan_obj

                  move.l a1,(a5)        ;store pointer to Lines_scan
                  movea.l a0,a5         ;copy  pointer
                  adda.w 16(a0),a5      ;pointer to RECORD(Lines_s)
                  move.w (a5)+,d0       ;fetch number of lines segments
                  move.w d0,(a1)+       ;store '             '
                  bra.s line_s_add      ;enter loop
obj_line_l:       move.l a0,-(sp)       ;store object pointer
                  movea.l a0,a2         ;copy
                  adda.w (a5)+,a0       ;fetch pointer to RECORD(Line_s)
                  movem.l d0/a5,-(sp)   ;store parameters
                  bsr   calc_line_seq   ;calc line segment
                  movem.l (sp)+,d0/a5   ;restore parameters
                  movea.l (sp)+,a0      ;restore pointer to object
line_s_add:       dbra  d0,obj_line_l   ;next line segment
object_e:         movea.l already(a6),a2 ;restore pointers
                  addq.l #2,a2          ;
                  adda.w -2(a2),a2      ;
                  movea.l record_space(a6),a3 ;
                  tst.w poly_flag(a6)   ;
                  bge.s object_e2       ;
                  bsr   x_bound         ;adjust x boundaries
                  movem.l clr_sp(a6),d0-d1 ;
                  move.l d1,(a1)+       ;store it
                  move.l d0,(a1)+       ;
object_e2:        rts
                ENDPART
calc_poly:      >PART 'calc poly parameters'

* USING:

* a0 pointer to RECORD(Plane).
* a1 pointer to RECORD(Scan_pl).
* a2 pointer to RECORD(Object)
* a6 pointer to parameter block.

* RETURNING:

* A scanned polygon(clipped etc.) returned INTO RECORD(Scan_pl)
* Or -1 ,because of the clipping and hidden removal

* Also using/returning the following global variables:
*
* P_xy     -> Rotated and projected coordinates.
* Already  -> Lines already calculated.

                  move.l a0,-(sp)       ;stack pointers
                  move.l a1,-(sp)       ;
                  tst.w (a0)            ;if no line number
                  bmi   calc_poly_e     ;jump
                  movea.l p_xy(a6),a3   ;point to xy-coords
                  lea   8(a0),a4        ;point to outproduct indices
                  lea   indexed_p(pc),a5 ;point to indexed points buffer
                  movea.l a2,a1         ;pointer to object
                  adda.w (a4)+,a1       ;pointer to normal order routine
                  adda.w (a4)+,a2       ;pointer to reverse order routine
                  movem.w (a4)+,d0-d3/d7 ;fetch indices,and nr. of indexed lines
                  move.l 0(a3,d0.w),d0  ;fetch xy-coords
                  move.l 0(a3,d1.w),d1  ;
                  move.l 0(a3,d2.w),d2  ;
                  move.l 0(a3,d3.w),d3  ;
                  sub.w d0,d1           ;y2-y1 -> vy1
                  sub.w d2,d3           ;y3-y4 -> vy2
                  swap  d0              ;x-coord in low word
                  swap  d1              ;
                  swap  d2              ;
                  swap  d3              ;
                  sub.w d1,d0           ;x1-x2 -> vx1
                  sub.w d3,d2           ;x4-x3 -> vx2
                  swap  d1              ;vy1 to low word
                  swap  d3              ;vy2 to low word
                  muls  d1,d2           ;vy1*v|2
                  muls  d3,d0           ;vy2*vx1
                  sub.l d2,d0           ;calc outerproduct
                  ble.s forward_order   ;continue if positive(clockwise)
                  jsr   (a2)            ;jump to revers order routine
                  tst.w d7              ;if no points
                  beq   calc_poly_e     ;stop
                  tst.w 4(a0)           ;if hidden removal
                  beq   calc_poly_e     ;stop
revers_order:     bsr   min_max_rev     ;calc index points in reverse order
                  bra.s cont_normal     ;continue with normal order
forward_order:    jsr   (a1)            ;jump to normal order routine
                  tst.w d7              ;if no points
                  beq   calc_poly_e     ;stop
                  bsr   min_max_for     ;'               ' in forward order
cont_normal:      move.w s_y_min(a6),d4 ;copy screen y-min
                  move.w s_y_max(a6),d5 ;copy screen y-max
                  cmp.w d5,d0           ;if screen y-max=<poly-min
                  bge.s calc_poly_e     ;stop
                  cmp.w d4,d1           ;if screen y-min=>poly-max
                  ble.s calc_poly_e     ;stop
                  cmp.w d4,d0           ;if screen y-min<poly-min
                  bgt.s no_top          ;jump
                  move.w d4,d0          ;minimum poly=screen y-min
no_top:           cmp.w d5,d1           ;if screen y-max>poly-max
                  blt.s no_bottom       ;jump
                  move.w d5,d1          ;maximum poly=screen y-max
no_bottom:
;                  tst.w ripple_flag(a6) ;if no ripple
;                  bne.s no_ripple       ;jump -> no total x-clip check
                  move.w s_x_min(a6),d4 ;fetch screen x-min
                  move.w s_x_max(a6),d5 ;'          ' x-max
                  cmp.w d5,d2           ;if poly-min>=screen x-max
                  bge.s calc_poly_e     ;stop
                  cmp.w d4,d3           ;if poly-max<=screen x-min
                  ble.s calc_poly_e     ;stop
no_ripple:        tst.w poly_flag(a6)   ;if no word polygon
                  bge.s no_word_poly    ;jump
                  bsr.s check_bound     ;
no_word_poly:     movem.w d0-d3,-(sp)   ;store min-max polygon
                  move.w s_y_min(a6),d0 ;copy screen-min
                  move.w s_y_max(a6),d1 ;'          'max
                  lea   indexed_p(pc),a0 ;pointer to indexed points
                  addq.w #1,d7          ;increase number of points
                  move.l (a0),(a5)      ;copy first point to last point
                  lea   clipped_p(pc),a5 ;
                  movea.l a0,a4         ;copy pointer for parameter passing
                  bsr   clip_poly_y     ;clip poly on y-boundaries

*a3 start of clipped-points; a5 end of clipped points.

                  movem.w (sp)+,d0-d3   ;restore min-max polygon
                  bsr   find_p_min      ;find pointer of minimum poly-point

*a4 points to minimum y-coord.

                  movea.l (sp)+,a1      ;unstack pointers
                  movea.l (sp)+,a0      ;


                  move.l (a0)+,(a1)+    ;copy plane_nr and delta flag
                  addq.l #2,a0          ;skip hide flag
                  move.w (a0)+,(a1)+    ;copy color
                  move.w d0,(a1)+       ;store minimum of poly
                  move.w d1,(a1)+       ;store maximum of poly
                  cmp.w d0,d1           ;if minimum is maximum
                  beq.s calc_poly_e3    ;end

                  bsr   scan_left       ;scan poly right
                  bsr   scan_right      ;scan poly left
                  lea   10(a1),a1       ;skip parameters
                  rts                   ;

calc_poly_e:      movea.l (sp)+,a1      ;unstack pointers
                  movea.l (sp)+,a0      ;
calc_poly_e2:     move.w #-1,(a1)+      ;store NO POLY flag
                  rts
calc_poly_e3:     movea.l record_space(a6),a0 ;
                  move.l a0,(a1)+       ;
                  move.l a0,(a1)+       ;
                  lea   10(a1),a1       ;
                  move.w #-1,(a0)+      ;
                  move.w d2,(a0)+       ;
                  move.w d3,(a0)+       ;
                  move.l a0,record_space(a6)
                  rts
                ENDPART
check_bound:    >PART 'calc max bound'

;d0 min-y
;d1 max-y
;d2 min-x
;d3 max-x

                  lea   clr_sp(pc),a2   ;pointer to clear block coordinates
                  cmp.w (a2)+,d0        ;miny
                  bge.s check_b_2       ;
                  move.w d0,-2(a2)      ;
check_b_2:        cmp.w (a2)+,d1        ;maxy
                  ble.s check_b_3       ;
                  move.w d1,-2(a2)      ;
check_b_3:        cmp.w (a2)+,d2        ;minx
                  bge.s check_b_4       ;
                  move.w d2,-2(a2)      ;
check_b_4:        cmp.w (a2),d3         ;maxx
                  ble.s check_b_e       ;
                  move.w d3,(a2)        ;
check_b_e:        rts                   ;
                ENDPART
x_bound:        >PART 'calc max x-bound'

;a6 pointer to paramaters

                  move.w s_x_min(a6),d0
                  move.w s_x_max(a6),d1
                  cmp.w clr_sp+4(a6),d0
                  blt.s x_bound_2
                  move.w d0,clr_sp+4(a6)
x_bound_2:        cmp.w clr_sp+6(a6),d1
                  bgt.s x_bound_3
                  move.w d1,clr_sp+6(a6)
x_bound_3:        rts
                ENDPART
min_max_for:    >PART 'calc min/max of forward poly'

*USING:

*d7 nr. of line indices.
*a3 pointer to projected points.
*a4 pointer to line indices.
*a5 pointer to result poly-line-coordinates.
*a6 pointer to global parameter block.

*RETURNING:

*d0 min-y poly
*d1 max-y poly
*d2 min-x poly
*d3 max-x poly
*Resulting poly-line-coordinates in forward order.
*d4-d6 smashed

                  move.w d7,d4          ;copy number of lines
                  subq.w #1,d4          ;-1 for dbf
                  move.w s_y_max(a6),d0 ;init min-y
                  move.w s_y_min(a6),d1 ;init max-y
                  move.w s_x_max(a6),d2 ;init min-x
                  move.w s_x_min(a6),d3 ;init max-x
min_max_for_l:    move.w (a4)+,d6       ;fetch point index
                  move.w (a4)+,d5       ;fetch line number
                  move.l 0(a3,d6.w),d6  ;fetch xy-coord
                  cmp.w d6,d0           ;if no minimum y-coord
                  blt.s no_min_y_for    ;jump
                  move.w d6,d0          ;init new minimum
no_min_y_for:     cmp.w d6,d1           ;if no maximum y-coord
                  bgt.s no_max_y_for    ;jump
                  move.w d6,d1          ;init new maximum
no_max_y_for:     swap  d6              ;swap to x-coord
                  cmp.w d6,d2           ;if no minimum x-coord
                  blt.s no_min_x_for    ;jump
                  move.w d6,d2          ;init new minimum
no_min_x_for:     cmp.w d6,d3           ;if no minimum x-coord
                  bgt.s no_max_x_for    ;jump
                  move.w d6,d3          ;init new maximum
no_max_x_for:     swap  d6              ;swap to original format
                  move.l d6,(a5)+       ;store xy-coord
                  move.w d5,(a5)+       ;store line number
                  dbra  d4,min_max_for_l ;loop
                  rts
                ENDPART
min_max_rev:    >PART 'calc min/max of reverse poly'

*USING:

*d7 nr. of line indices.
*a3 pointer to projected points.
*a4 pointer to line indices.
*a5 pointer to result poly-line-coordinates.
*a6 pointer to global parameter block.

*RETURNING:

*d0 min-y poly
*d1 max-y poly
*Resulting poly-line-coordinates in reverse order.
*d4-d6 smashed
                  move.w (a4),d6        ;fetch first point index
                  move.w d7,d4          ;copy number of indexed lines
                  add.w d4,d4           ;
                  add.w d4,d4           ;
                  adda.w d4,a4          ;set pointer to end of list (pre decr)
                  move.w d7,d4          ;copy
                  subq.w #1,d4          ;-1 dbf
                  move.w s_y_max(a6),d0 ;init min
                  move.w s_y_min(a6),d1 ;init max
                  move.w s_x_max(a6),d2 ;init min-x
                  move.w s_x_min(a6),d3 ;init max-x
                  move.w -(a4),d5       ;fetch line number
                  bra.s min_max_rev_s   ;begin loop

min_max_rev_l:    move.w -(a4),d6       ;fetch point index
                  move.w -(a4),d5       ;fetch line number
min_max_rev_s:    move.l 0(a3,d6.w),d6  ;fetch xy-coord
                  cmp.w d6,d0           ;if no minimum y-coord
                  blt.s no_min_y_rev    ;jump
                  move.w d6,d0          ;init new minimum
no_min_y_rev:     cmp.w d6,d1           ;if no maximum y-coord
                  bgt.s no_max_y_rev    ;jump
                  move.w d6,d1          ;init new maximum
no_max_y_rev:     swap  d6              ;swap to x-coord
                  cmp.w d6,d2           ;if no minimum x-coord
                  blt.s no_min_x_rev    ;jump
                  move.w d6,d2          ;init new minimum
no_min_x_rev:     cmp.w d6,d3           ;if no maximum x-coord
                  bgt.s no_max_x_rev    ;jump
                  move.w d6,d3          ;init new maximum
no_max_x_rev:     swap  d6              ;swap to original format
                  move.l d6,(a5)+       ;store xy-coord
                  move.w d5,(a5)+       ;store line-index
                  dbra  d4,min_max_rev_l ;loop
                  rts
                ENDPART
clip_poly_y:    >PART 'clip poly on y window'

*USING:

*d0 minimum of clip window
*d1 maximum '            '
*a4 pointer to poly-points
*a5 pointer to destination clipped poly points
*d7 number of points

*RETURNING:

*pointer to start of clipped points list in a3
*pointer to end of clipped points list in a5
*number of clipped poly points in d7
*registers smashed d2-d7/a0-a2/a4

                  movea.l a5,a3         ;copy
                  subq.w #2,d7          ;-2 for dbf,and first point
                  move.l (a4)+,d2       ;first point
                  movea.w (a4)+,a2      ;line-index
                  cmp.w d1,d2           ;
                  bgt.s max             ;if p1>max
                  cmp.w d0,d2           ;
                  bge.s mid             ;if p1>min and p1<max
min:              move.l d2,d3          ;store p1
                  movea.l a2,a1         ;store line-index
                  move.l (a4)+,d2       ;get p2
                  movea.w (a4)+,a2      ;line-index
                  cmp.w d0,d2           ;
                  dbgt  d7,min          ;if p2<min next coord
                  tst.w d7              ;if last point
                  bmi   no_more         ;no more
                  cmp.w d1,d2           ;if p2>=min
                  bgt.s min2            ;if p2>max
                  bsr   clip_min        ;if p2<=max means one intersection
                  move.w a1,(a5)+       ;
                  move.l d6,(a5)+       ;store p1
                  dbra  d7,mid          ;
                  bra   no_more         ;no more points
min2:             bsr   clip_min        ;if p1<min and p2>max
                  move.w a1,(a5)+       ;
                  move.l d6,(a5)+       ;store p1
                  bsr   clip_max        ;then we have two intersections
                  clr.w (a5)+           ;store dummy line index
                  move.l d6,(a5)+       ;store p2
                  dbra  d7,max          ;next
                  bra.s no_more         ;no_more points
mid:              move.l d2,d3          ;store p1
                  movea.l a2,a1         ;store line-index
                  move.w a1,(a5)+       ;
                  move.l d2,(a5)+       ;
                  move.l (a4)+,d2       ;get p2
                  movea.w (a4)+,a2      ;line-index
                  cmp.w d0,d2           ;
                  blt.s mid2            ;if p2<min
                  cmp.w d1,d2           ;if p2=>min
                  dbgt  d7,mid          ;if p2<max
                  tst.w d7              ;if no more points
                  bmi.s no_more         ;
                  bsr   clip_max        ;p2>max means one intersection
                  clr.w (a5)+           ;store dummy-line index
                  move.l d6,(a5)+       ;store p2
                  dbra  d7,max          ;next point
                  bra.s no_more         ;if no more,exit
mid2:             exg   d2,d3           ;highest p in d2
                  bsr.s clip_min        ;p2<min means one intersection
                  clr.w (a5)+           ;store dummy-line index
                  move.l d6,(a5)+       ;store p2
                  exg   d2,d3           ;restore original order p1,p2
                  dbra  d7,min          ;next point
                  bra.s no_more         ;if no more,exit

max:              move.l d2,d3          ;store p1
                  movea.l a2,a1         ;store line-index
                  move.l (a4)+,d2       ;get p2
                  movea.w (a4)+,a2      ;line-index
                  cmp.w d1,d2           ;
                  dblt  d7,max          ;if p2>max->next point
                  tst.w d7              ;if no more points
                  bmi.s no_more         ;exit
                  cmp.w d0,d2           ;p2<max
                  blt.s max2            ;if p2<min
                  exg   d2,d3           ;highest p in d2
                  bsr.s clip_max        ;if p2>min means one intersection
                  move.w a1,(a5)+       ;
                  move.l d6,(a5)+       ;store p1
                  exg   d2,d3           ;restore original order p1,p2
                  dbra  d7,mid          ;next point
                  bra.s no_more         ;if no more,exit
max2:             exg   d2,d3           ;->highest p in d2
                  bsr.s clip_max        ;p2<min and p1>max
                  move.w a1,(a5)+       ;
                  move.l d6,(a5)+       ;store p1
                  bsr.s clip_min        ;then we have two intersections
                  clr.w (a5)+           ;store dummy line-index
                  move.l d6,(a5)+       ;store p2
                  exg   d2,d3           ;restore original order p1,p2
                  dbra  d7,min          ;next point
no_more:          rts

                ENDPART
clip_min:       >PART 'clips minimum'

*USING:

*d3.l holds p1 -> lowest coord
*d2.l holds p2
*d0.w holds minimum
*smashes d4-d6/a0

*RETURNING:

*new point in d6.l

                  movea.w d3,a0         ;copy
                  move.l d3,d4          ;copy
                  move.l d2,d5          ;copy
                  swap  d4              ;->x1
                  swap  d5              ;->x2
                  sub.w d5,d4           ;x1-x2
                  beq.s c_miny_s        ;if zero->special gase
                  move.w d0,d6          ;
                  swap  d6              ;copy to high word
                  move.w d0,d6          ;copy
                  sub.w d2,d6           ;ymin-y2
                  sub.w d2,d3           ;y1-y2
                  muls  d6,d4           ;(x2-x1)*(ymin-y29/(y2-y1)
                  divs  d3,d4           ;(ymin-y2) always lower then (y2-y1) !
                  add.w d4,d5           ;new x1,y1 coord
                  move.w d5,d6          ;
                  move.w a0,d3          ;restore
                  swap  d6              ;y-coord in low word
                  rts

c_miny_s:         move.w d5,d6          ;clipx=x2
                  swap  d6              ;
                  move.w d0,d6          ;copy to low word
                  rts
                ENDPART
clip_max:       >PART 'clips maximum'

*USING:

*d3.l holds p1 -> lowest coord
*d2.l holds p2
*d1.w holds maximum
*smashes d4-d6/a0

*RETURNING:

*new point in d6.l



                  movea.w d3,a0         ;copy
                  move.l d3,d4          ;copy
                  move.l d2,d5          ;copy
                  swap  d4              ;->x1
                  swap  d5              ;->x2
                  sub.w d5,d4           ;x1-x2
                  beq.s c_maxy_s        ;if zero->special case
                  move.w d1,d6          ;
                  swap  d6              ;copy to high word
                  move.w d1,d6          ;copy
                  sub.w d2,d6           ;ymin-y2
                  sub.w d2,d3           ;y1-y2
                  muls  d6,d4           ;(x2-x1)*(ymin-y2)/(y2-y1)
                  divs  d3,d4           ;(ymin-y2) always lower then (y2-y1) !
                  add.w d4,d5           ;new x1,y1 coord
                  move.w d5,d6          ;
                  move.w a0,d3          ;restore
                  swap  d6              ;y-coord in low word
                  rts

c_maxy_s:         move.w d5,d6          ;clipx=x2
                  swap  d6              ;
                  move.w d1,d6          ;copy to high word
                  rts

                ENDPART
find_p_min:     >PART 'search for minimum polypoint'

*USING:

*a3 pointer to clipped points
*a6 pointer to parameter block
*d0 minimum of polygon
*d1 maximum '        '
*d7 number of points

*RETURNING:

*a4 pointer to minimum point in clipped points list
*d2-d3 smashed
                  movea.l a3,a4         ;copy pointer
;
find_p_min_l:     addq.l #2,a4          ;skip line-index
                  move.l (a4)+,d4       ;fetch xy-coord
                  cmp.w d0,d4           ;if min-poly<>y-point
                  bne.s find_p_min_l    ;next
                  subq.l #6,a4          ;correct last term
                  rts

                ENDPART
scan_left:      >PART 'scan poly left'

*USING:

*d0 minimum y-coord of polygon
*d1 maximum '                '
*a1 pointer to RECORD(Scan_pl):left_p
*a3 pointer to start of poly point-line list
*a4 pointer to minimum of poly list
*a5 pointer to end of poly list
*a6 pointer to parameter block

*difference with scan_left
*last line number <-> new line number


                  movea.l record_space(a6),a0 ;pointer to space in memory
                  move.l a0,(a1)+       ;init pointer IN RECORD(Scan_p)
                  movem.l a0-a1/a4,-(sp) ;stack pointers
                  moveq #0,d2           ;init number of polypieces
                  addq.l #2,a0          ;skip nr. of poly pieces
                  move.w (a4),d6        ;fetch line-number
                  move.l 2(a4),d3       ;fetch xy-coord
;
right_l:          cmpa.l a3,a4          ;if not first point
                  bgt.s not_last_r      ;jump
                  movea.l a5,a4         ;pointer to end of list
not_last_r:       move.l d3,d5          ;store last point
                  move.l d6,d4          ;store last line number
                  move.l -(a4),d3       ;next point
                  move.w -(a4),d6       ;next line number
                  cmp.w d0,d3           ;if not still minumum
                  bne.s right_l_2       ;next point
                  moveq #-1,d6          ;dummy line number
                  bra.s right_l         ;next point
right_l_2:        cmp.w d5,d3           ;if new point greater then old point
                  bgt.s right_l_3       ;next point
                  move.w d5,d3          ;restore old y-point
                  moveq #-1,d6          ;dummy line number
                  moveq #-1,d4          ;'               '
right_l_3:        addq.w #1,d2          ;increase number of pieces
                  bsr.s add_exist_f     ;add fraction which not already exists
                  cmp.w d1,d3           ;if maximum polygon is not yet reached
                  bne.s right_l         ;loop
                  move.l a0,record_space(a6) ;store pointer to new space
                  movem.l (sp)+,a0-a1/a4 ;restore pointers
                  move.w d2,(a0)        ;store number of pieces
                  rts
                ENDPART
scan_right:     >PART 'scan poly right'

*USING:

*d0 minimum y-coord of polygon
*d1 maximum '                '
*a1 pointer to RECORD(Scan_pl):right_p
*a3 pointer to start of poly point-line list
*a4 pointer to minimum of poly list
*a5 pointer to end of poly list
*a6 pointer to parameter block

                  movea.l record_space(a6),a0 ;pointer to space in memory
                  move.l a0,(a1)+       ;init pointer IN RECORD(Scan_p)
                  movem.l a0-a1/a4,-(sp) ;stack pointers
                  moveq #0,d2           ;init number of polypieces
                  addq.l #2,a0          ;skip nr. of poly pieces
                  move.w (a4)+,d4       ;fetch line-number
                  move.l (a4)+,d3       ;fetch xy-coord
;
left_l:           cmpa.l a5,a4          ;if not last point
                  blt.s not_last_l      ;jump,pointer to start of list
                  movea.l a3,a4         ;pointer to start of list
not_last_l:       move.l d3,d5          ;store last point
                  move.l d4,d6          ;store last line number
                  move.w (a4)+,d4       ;next line number
                  move.l (a4)+,d3       ;next point
                  cmp.w d0,d3           ;if not still minimum
                  bne.s left_l_2        ;next point
                  moveq #-1,d6          ;dummy line number
                  bra.s left_l          ;next point
left_l_2:         cmp.w d5,d3           ;if new point greater then old point
                  bgt.s left_l_3        ;jump
                  moveq #-1,d4          ;dummy line number
                  moveq #-1,d6          ;'               '
                  move.w d5,d3          ;restore old y-point
left_l_3:         addq.w #1,d2          ;increase number of pieces
                  bsr.s add_exist_f     ;add fraction which not already exists
                  cmp.w d1,d3           ;if maximum polygon is not yet reached
                  bne.s left_l          ;loop
                  move.l a0,record_space(a6) ;store pointer to new space
                  movem.l (sp)+,a0-a1/a4 ;restore pointers
                  move.w d2,(a0)        ;store number of pieces
                  rts
                ENDPART
add_exist_f:    >PART 'add a not existing fraction'

*USING:

*d3 new xy-coord
*d4 new line-index
*d5 old xy-coord
*d6 old line-index
*a0 destination fraction index
*a6 pointer to parameter block

*Can only use d6-d7 and a1-a2 later on

                  tst.w d6              ;if positive -> line segment
                  bpl.s no_dummy        ;jump

                  movea.l already(a6),a2 ;
                  move.w (a2),d7        ;
                  bra.s exist_not_2     ;


no_dummy:         movea.l line_flag(a6),a1 ;pointer to lines already calculated
                  adda.w d6,a1          ;index line
                  tst.w (a1)            ;if not already done
                  beq.s exist_not       ;jump
                  move.w 2(a1),(a0)+    ;copy piece index
                  rts                   ;
;
exist_not:        move.w #-1,(a1)+      ;set flag -> line already calculated
                  movea.l already(a6),a2 ;pointer to RECORD(P_done)
                  move.w (a2),d7        ;fetch ind_count
                  move.w d7,(a1)        ;store piece index
exist_not_2:      move.w d7,(a0)+       ;store piece index IN RECORD(Scan_p)
                  lea   2(a2,d7.w),a1   ;point to next RECORD([P_piece)
                  add.w #8,d7           ;increase index to next piece
                  move.w d7,(a2)        ;store ind_count IN RECORD(P_done)
;
                  sub.w d3,d5           ;dy -> always negative
                  neg.w d5              ;make positive
                  move.l d5,d6          ;
                  lea   frac_tab(pc),a2 ;pointer to fraction table
                  add.w d5,d5           ;*4 to index fraction table
                  add.w d5,d5           ;
                  move.l 0(a2,d5.w),d7  ;fetch frac + floats right
                  swap  d3              ;x in low word
                  swap  d5              ;
                  sub.w d3,d5           ;if -dx is positive
                  bpl.s neg_frac        ;negative fraction
                  neg.w d5              ;make positive
                  cmp.w d5,d6           ;
                  bgt.s pos_frac_2      ;
                  neg.w d6              ;dx>dy

pos_frac_2:       mulu  d7,d5           ;dx*1/dy
                  swap  d7              ;nr floats in low word
                  lsr.l d7,d5           ;float right
                  move.l d6,(a1)+       ;
                  move.l d5,(a1)+       ;store fraction
                  swap  d3              ;y to low word
                  rts                   ;
;
neg_frac:         cmp.w d5,d6           ;
                  bgt.s neg_frac_2      ;
                  neg.w d6              ;dx>dy

neg_frac_2:       mulu  d7,d5           ;dx*1/dy
                  swap  d7              ;nr floats in low word
                  lsr.l d7,d5           ;float right
                  neg.l d5              ;negative
                  move.l d6,(a1)+       ;
                  move.l d5,(a1)+       ;store fraction
                  swap  d3              ;y to low word
                  rts
;
                ENDPART
calc_line_seq:  >PART 'calc line sequence parameters'

*USING:

*a0 pointer to RECORD(Line_s)
*a1 pointer to RECORD(Scan_li)
*a2 pointer to RECORD(Object)
*a6 pointer to parameter block

*RETURNING:

* Scanned line segments INTO RECORD(Scan_li) -> zero set.
* or -1, because of hidden plane or clipped -> zero clear
                  move.l a0,-(sp)       ;store pointers
                  move.l a1,-(sp)       ;
                  movea.l p_xy(a6),a3   ;point to xy-coords

                  lea   8(a0),a4        ;point to outproduct parameters
                  lea   indexed_p(pc),a5 ;point to indexed points buffer
                  tst.w 2(a0)           ;if no outproduct needed
                  bne.s cont_normal_lin_2 ;jump
cont_normal_lin_1:movea.l a2,a1         ;copy pointer
                  adda.w (a4)+,a1       ;pointer to normal order routine
                  adda.w (a4)+,a2       ;pointer to reverse order routine
                  movem.w (a4)+,d0-d3   ;fetch vectors
                  move.l 0(a3,d0.w),d0  ;fetch xy-coords
                  move.l 0(a3,d1.w),d1  ;remarks same as calc_poly
                  move.l 0(a3,d2.w),d2  ;
                  move.l 0(a3,d3.w),d3  ;
                  sub.w d0,d1           ;calc outerproduct
                  sub.w d2,d3           ;
                  swap  d0              ;
                  swap  d1              ;
                  swap  d2              ;
                  swap  d3              ;
                  sub.w d1,d0           ;
                  sub.w d3,d2           ;
                  swap  d1              ;
                  swap  d3              ;
                  muls  d1,d2           ;
                  muls  d3,d0           ;
                  sub.l d2,d0           ;
                  ble.s forward_order_lin ;continue if positive(clockwise)
                  jsr   (a2)            ;jump to revers order routine
                  tst.w 4(a0)           ;if no hidden removal
                  bne.s cont_normal_lin_2 ;continue
                  bra.s calc_line_e     ;else stop
forward_order_lin:jsr   (a1)            ;jump to normal order routine
cont_normal_lin_2:bsr.s convert_lines   ;convert index_c in screen coords
                  lea   indexed_p(pc),a1 ;pointer to index_p
                  lea   clipped_p(pc),a2 ;pointer to clip points buffer
                  move.w s_y_min(a6),d0 ;init clip window(y)
                  move.w s_y_max(a6),d1 ;
                  bsr.s clip_line       ;clip on y-window
                  lea   clipped_p(pc),a1 ;pointer to y clipped points
                  movea.l record_space(a6),a2 ;pointer to SPACE
                  movea.l a2,a3         ;copy pointer
                  move.w s_x_min(a6),d0 ;init clip window(x)
                  move.w s_x_max(a6),d1 ;
                  bsr.s clip_line       ;clip on x-window
                  tst.w (a3)            ;if no points
                  bpl.s calc_line_e2    ;jump
                  movea.l (sp)+,a1      ;restore pointers
                  movea.l (sp)+,a0      ;
                  move.w (a0),(a1)+     ;copy line identifier
                  move.w 6(a0),(a1)+    ;copy color
                  move.l a3,(a1)+       ;store pointer to RECORD(Sc_li)
                  move.l a2,record_space(a6) ;store pointer to SPACE
                  rts                   ;
calc_line_e2:     subq.l #2,a3          ;correct table
calc_line_e:      movea.l (sp)+,a1      ;restore pointers
                  movea.l (sp)+,a0      ;
                  move.w #-1,(a1)+      ;store NO LINES flag
                  rts                   ;
                ENDPART
convert_lines:  >PART 'convert line indices'

*USING:

*d7 number of points
*a3 pointer to projected points
*a4 pointer to points and line indices
*a5 pointer to result lines
*a6 pointer to global parameter block
                  movea.l line_flag(a6),a2 ;pointer to lines alread done
                  move.w (a4)+,(a5)+    ;store first pen parameter -> -1
                  move.l a5,d7          ;store pointer
;
convert_li_l:     move.l (a4)+,d0       ;fetch point and line index
                  move.w (a4)+,d1       ;fetch pen parameter
                  bne.s convert_li_l3   ;if zero,jump
                  tst.w d0              ;if minus line index
                  blt.s convert_li_s    ;jump
                  tst.w 0(a2,d0.w)      ;if line not already done
                  bpl.s convert_li_l2   ;loop
                  move.w #-1,d1         ;
                  bra.s convert_li_l3   ;
;
convert_li_l2:    move.w #-1,0(a2,d0.w) ;line flag set
convert_li_s:     swap  d0              ;point index to low word
                  move.l 0(a3,d0.w),(a5)+ ;store xy point
                  move.w d1,(a5)+       ;store pen parameter
                  bra.s convert_li_l    ;loop
;
convert_li_l3:    swap  d0              ;point index to low word
                  move.l 0(a3,d0.w),(a5)+ ;store xy point
                  move.w d1,(a5)+       ;store pen parameter
                  tst.w d1              ;if not last point
                  ble.s convert_li_l    ;loop
;
convert_li_e:     rts
                ENDPART
clip_line:      >PART 'clip lines on bounds'

*USING:

*a1 pointer to source RECORD(Line)
*a2 pointer to destination RECORD(Line)

*d0 min boundary
*d1 max boundary

*RETURNING:

*a2 pointing behind RECORD(Line)

                  bra.s clip_line_max   ;first try
new_line:         move.l (a1)+,d2       ;fetch new coord
                  cmp.w d0,d2           ;if coord<min
                  blt.s clip_line_min   ;jump
                  cmp.w d1,d2           ;else if coord>max
                  bgt.s clip_line_max   ;jump
                  move.w #-1,(a2)+      ;pen up
                  bra.s clip_line_mid_2 ;do mid case without pen down storage
clip_line_max:    move.l d2,d3          ;else copy
                  tst.w (a1)+           ;test if pen up
                  bmi.s new_line        ;new line
                  bne   clip_line_end   ;if not zero -> end of list
                  move.l (a1)+,d2       ;fetch new coord
                  cmp.w d1,d2           ;test if still maximum case
                  bgt.s clip_line_max   ;next line
                  cmp.w d0,d2           ;test if minimum case
                  blt.s line_max_min    ;max->min
line_max_mid:     exg   d2,d3           ;p1 must hold lowest coord
                  bsr   clip_max        ;clip on max boundary
                  swap  d6              ;y <-> x swap
                  move.w #-1,(a2)+      ;pen up
                  move.l d6,(a2)+       ;store coord
                  exg   d2,d3           ;restore old order
                  bra.s clip_line_mid   ;mid case
line_max_min:     exg   d2,d3           ;p1 must hold lowest coord
                  bsr   clip_max        ;clip on max boundary
                  swap  d6              ;y <-> x swap
                  move.w #-1,(a2)+      ;pen up
                  move.l d6,(a2)+       ;
                  bsr   clip_min        ;clip on min boundary
                  clr.w (a2)+           ;pen down
                  swap  d6              ;
                  move.l d6,(a2)+       ;store coord
                  exg   d2,d3           ;restore old order
                  bra.s clip_line_min   ;min case
clip_line_mid:    clr.w (a2)+           ;pen down
clip_line_mid_2:  move.l d2,d3          ;copy new coord
                  swap  d2              ;
                  move.l d2,(a2)+       ;copy to destination
                  tst.w (a1)+           ;test if pen up
                  bmi.s new_line        ;jump
                  bne.s clip_line_end   ;if not zero -> end of list
                  move.l (a1)+,d2       ;fetch new coord
                  cmp.w d0,d2           ;coord<min
                  blt.s line_mid_min    ;mid->min
                  cmp.w d1,d2           ;coord<max
                  ble.s clip_line_mid   ;next mid coord
line_mid_max:     bsr   clip_max        ;clip on max boundary
                  swap  d6              ;
                  clr.w (a2)+           ;pen down
                  move.l d6,(a2)+       ;store coord
                  bra.s clip_line_max   ;max case
line_mid_min:     exg   d2,d3           ;p1 must hold lowest coord
                  bsr   clip_min        ;clip on min boundary
                  swap  d6              ;
                  clr.w (a2)+           ;pen down
                  move.l d6,(a2)+       ;store coord
                  exg   d2,d3           ;restore old order
clip_line_min:    move.l d2,d3          ;copy new coord
                  tst.w (a1)+           ;test if pen up
                  bmi   new_line        ;jump
                  bne.s clip_line_end   ;if not zero -> end of list
                  move.l (a1)+,d2       ;fetch new coord
                  cmp.w d0,d2           ;test if still minimum case
                  blt.s clip_line_min   ;jump
                  cmp.w d1,d2           ;test if maximum case
                  bgt.s line_min_max    ;min -> max
line_min_mid:     bsr   clip_min        ;clip on min boundary
                  swap  d6              ;
                  move.w #-1,(a2)+      ;pen up
                  move.l d6,(a2)+       ;store coord
                  bra.s clip_line_mid   ;mid case
line_min_max:     bsr   clip_min        ;clip on min boundary
                  swap  d6              ;
                  move.w #-1,(a2)+      ;pen up
                  move.l d6,(a2)+       ;store coord
                  bsr   clip_max        ;clip on max boundary
                  clr.w (a2)+           ;pen down
                  swap  d6              ;
                  move.l d6,(a2)+       ;store coord
                  bra   clip_line_max   ;max case
clip_line_end:    move.w #1,(a2)+       ;pen parameter -> quit
                  rts

                ENDPART
scan_b_lin:     >PART 'scan border lines'
                  lea   20(a0),a1       ;pointer to points an lines of polygon
                  lea   border_flag(pc),a2 ;pointer to border line flags
                  move.w (a1)+,d0       ;fetch number of lines
                  bra.s scan_b_lin_l_e  ;begin loop
scan_b_lin_l:     move.l (a1)+,d1       ;fetch line number
                  addq.w #1,0(a2,d1.w)  ;add up line number
scan_b_lin_l_e:   dbra  d0,scan_b_lin_l ;next
                  rts
                ENDPART
scan_border:    >PART 'scan border polygons'

;a1 pointer to RECORD(B_polys)
;a3 pointer to projected points
                  movea.l current_obj(a6),a2 ;fetch pointer to current object
                  movea.l p_xy(a6),a3   ;pointer to projected points
                  lea   border_flag(pc),a5 ;
                  move.w (a1)+,d4       ;fetch number of border polygons
                  bra.s scan_border_l_e ;
scan_border_l:    movea.l a2,a4         ;copy pointer
                  adda.w (a1)+,a4       ;fetch rel. pointer to RECORD(B_poly)
                  tst.w (a4)+           ;if no outproduct
                  bne.s scan_bord_out_1 ;jump
                  movem.w (a4)+,d0-d3   ;fetch outproduct vectors
                  move.l 0(a3,d0.w),d0  ;fetch xy-coords
                  move.l 0(a3,d1.w),d1  ;
                  move.l 0(a3,d2.w),d2  ;
                  move.l 0(a3,d3.w),d3  ;
                  sub.w d0,d1           ;y2-y1 -> vy1
                  sub.w d2,d3           ;y3-y4 -> vy2
                  swap  d0              ;x-coord in low word
                  swap  d1              ;
                  swap  d2              ;
                  swap  d3              ;
                  sub.w d1,d0           ;x1-x2 -> vx1
                  sub.w d3,d2           ;x4-x3 -> vx2
                  swap  d1              ;vy1 to low word
                  swap  d3              ;vy2 to low word
                  muls  d1,d2           ;vy1*v|2
                  muls  d3,d0           ;vy2*vx1
                  sub.l d2,d0           ;calc outerproduct
                  ble.s scan_bord_out_2 ;jump if clockwise
                  bra.s scan_border_l_e ;
scan_bord_out_1:  addq.l #8,a4          ;
scan_bord_out_2:  move.w (a4)+,d0       ;fetch number of lines
                  bra.s scan_bord_l_e   ;jump in loop
scan_bord_l:      move.w (a4)+,d1       ;
                  addq.w #1,0(a5,d1.w)  ;add line flag
scan_bord_l_e:    dbra  d0,scan_bord_l  ;next line
scan_border_l_e:  dbra  d4,scan_border_l ;
scan_border_e:    rts

                ENDPART
creat_pl:       >PART 'create border plane'
;a6 pointer to parameter block

                  lea   border_flag(pc),a1
                  lea   unsort_lin(pc),a2
                  moveq #0,d2
                  moveq #0,d0
                  movea.l current_obj(a6),a3
                  move.w 12(a3),d3      ;fetch number of lines
                  move.l #$010000,d1
                  bra.s creat_pl_l_e_2
creat_pl_l:       cmp.l (a1)+,d1
                  bne.s creat_pl_l_e_1
                  move.w d2,(a2)+
                  addq.w #1,d0
creat_pl_l_e_1:   addq.w #4,d2
creat_pl_l_e_2:   dbra  d3,creat_pl_l
                  lea   unsort_lin(pc),a0
                  lea   8(a5),a2
                  movea.l a4,a1
                  lea   2(a2),a4
                  bsr.s glue_bor_lin
                  move.w 8(a5),d0
                  cmp.w #3,d0           ;if only three
                  ble.s creat_pl_3p     ;special case
                  move.w d0,d1
                  moveq #$fe,d2
                  and.w d2,d0           ;calc middle of point list
                  add.w d2,d2
                  and.w d2,d1
                  add.w d0,d0
                  move.w (a4),(a5)+     ;move outer vectors
                  move.w 0(a4,d0.w),(a5)+
                  adda.w d1,a4
                  move.w (a4),(a5)+
                  move.w 0(a4,d0.w),(a5)+
                  rts
creat_pl_3p:      move.w (a4),(a5)+
                  move.w 4(a4),(a5)+
                  move.w (a4),(a5)+
                  move.w 8(a4),(a5)+
                  rts

                ENDPART
glue_bor_lin:   >PART 'glue lines of border polygon'
* USING;

;d0 number of lines
;a0 pointer to RECORD(Border)
;a1 pointer to RECORD(P_to_l)
;a2 pointer to space for RECORD(Poly_p)

* RETURNING;

;Border polygon in RECORD(Poly_p)
                  moveq #-1,d6          ;init minus flag
                  move.w d0,(a2)+       ;copy number of points eq. lines
                  move.w (a0)+,d2       ;fetch first line number
                  move.l 0(a1,d2.w),d1  ;fetch points of first line
                  move.w d1,(a2)+       ;copy first point number
                  move.w d2,(a2)+       ;copy line number
                  swap  d1              ;init search for second line point
                  movea.l a0,a3         ;copy pointer
                  subq.w #2,d0          ;-2 for first point and dbf
                  move.w d0,d3          ;copy
                  bmi.s glue_end        ;if no points
glue_bor_l:       move.w d3,d4          ;copy number of lines
glue_bor_l_2:     move.w (a0)+,d5       ;fetch line number
                  bmi.s glue_bor_l_2    ;no glue needed -> next
                  move.l 0(a1,d5.w),d2  ;fetch both line coordinates
                  cmp.w d2,d1           ;if first point not the same
                  bne.s glue_bor_l_21   ;jump
                  move.w d1,(a2)+       ;copy point number
                  move.w d5,(a2)+       ;copy line number
                  move.l d2,d1          ;init new search point number
                  swap  d1              ;
                  move.w d6,-2(a0)      ;no more glue please
                  movea.l a3,a0         ;copy pointers
                  dbra  d0,glue_bor_l   ;
                  rts
glue_bor_l_21:    swap  d2              ;
                  cmp.w d2,d1           ;if second point not same
                  bne.s glue_bor_l_2e   ;jump
                  move.w d1,(a2)+       ;copy point number
                  move.w d5,(a2)+       ;copy line number
                  move.l d2,d1          ;init new search point number
                  swap  d1              ;
                  move.w d6,-2(a0)      ;no more glue please
                  movea.l a3,a0         ;copy pointers
                  dbra  d0,glue_bor_l   ;
                  rts
glue_bor_l_2e:    dbra  d4,glue_bor_l_2 ;next line
                  movea.l a3,a0         ;copy pointers
glue_bor_e:       dbra  d0,glue_bor_l   ;
glue_end:         rts

                ENDPART
clear_flags:    >PART 'clear order line flags'
                  moveq #0,d1
                  lea   border_flag(pc),a1
                  movea.l current_obj(a6),a2
                  move.w 12(a2),d0
                  subq.w #1,d0
clear_bord_fl_l:  move.l d1,(a1)+
                  dbra  d0,clear_bord_fl_l
                  rts
                ENDPART

                BASE A6,OFF     ;stop index for parameter block

*DRAWING ROUTINES

init_poly:      >PART 'init all code and tables'

*Init all tables and code
                  bsr   code_norm_r
                  bsr   code_norm_l
                  bsr   code_rev_r
                  bsr   code_rev_l
                  bsr   c_rev_set_bl
                  bsr   look_up_clr
                  bsr   c_or_and_bl
                  bsr   code_clr_bl
                  bsr.s init_n_poly
                  lea   super_b,a0
                  move.w a0,d1

                  add.w #(320+clip_space*2)*4,d1
                  move.w d1,add_c
                  rts
                ENDPART
init_n_poly:    >PART 'init long word poly code'
                  bsr   mask_norm_t
                  bsr   mask_rev_t
                  bsr   rip_jump_tab
                  bsr   x_calc_jump_t
                  bsr   init_line
                  lea   super_b,a0
                  move.w a0,d1
                  add.w #(320+clip_space*2)*4,d1
                  move.w d1,add_c
                  rts
                ENDPART
normal_delta:   >PART 'draw normal delta polygon'

*a0 pointer to old x-coords
*a1 pointer to new x-coords

*d0 number of y-steps
*d4 mask
*d6 fill pattern
*d7 clear pattern
                  add.w d0,d0           ;index
                  lea   0(a0,d0.w),a2   ;fetch pointers to coords
                  lea   0(a5,d0.w),a3   ;store points
                  lea   0(a1,d0.w),a4   ;
                  move.w (a2),-(sp)     ;
                  move.w (a3),-(sp)     ;
                  move.w (a4),-(sp)     ;
                  clr.w (a2)            ;
                  move.w #max_code*20*20-jump_off,(a3) ;init break conditions
                  move.l #jump_normal1,d0
                  move.l #jump_normal2,d2
                  lea   norm_left+jump_off,a2 ;
                  lea   norm_right+jump_off,a3 ;
                  pea   normal_delt_e(pc) ;
                  exg   sp,d5           ;
                  jmp   norm_right+6    ;
normal_delt_e:    move.w (sp)+,-(a1)    ;
                  move.w (sp)+,-(a5)    ;restore old points
                  move.w (sp)+,-(a0)    ;
                  rts
                ENDPART
revers_delta:   >PART 'draw reverse delta polygon'
*Same variables as normal_delta(and same remarks!)
                  add.w d0,d0
                  lea   0(a0,d0.w),a2
                  lea   0(a5,d0.w),a3
                  lea   0(a1,d0.w),a4
                  move.w (a2),-(sp)
                  move.w (a3),-(sp)
                  move.w (a4),-(sp)
                  clr.w (a2)
                  move.w #max_code*20*20,(a3)
                  move.l #jump_revers2,d0
                  move.l #jump_revers1,d2
                  lea   rev_left+jump_off,a2
                  lea   rev_right+jump_off,a3
                  pea   revers_delt_e(pc)
                  exg   sp,d5
                  jmp   rev_right+6
revers_delt_e:    move.w (sp)+,-(a1)
                  move.w (sp)+,-(a5)
                  move.w (sp)+,-(a0)
                  rts
                ENDPART
normal_draw:    >PART 'draw normal polygon'

*Same variables as normal_delta(and same remarks!)
                  add.w d0,d0
                  lea   0(a0,d0.w),a2
                  lea   0(a1,d0.w),a3
                  move.w (a2),-(sp)
                  move.w (a3),-(sp)
                  clr.w (a2)
                  move.w add_c(pc),(a3)
                  move.l #jump_normal1,d1
                  lea   jump_normal1,a3
                  move.l #jump_revers1,d3
                  lea   or_and_set+jump_off,a2
                  pea   normal_draw_e(pc)
                  exg   sp,d5
                  jmp   or_and_set+18
normal_draw_e:    move.w (sp)+,(a1)
                  move.w (sp)+,-(a0)
                  rts
                ENDPART
normal_long:    >PART 'draw long normal polygon'

*Same variables as normal_delta(and same remarks!)
                  add.w d0,d0
                  lea   0(a0,d0.w),a2
                  lea   0(a1,d0.w),a3
                  move.w (a2),-(sp)
                  move.w (a3),-(sp)
                  clr.w (a2)
                  move.w add_c(pc),(a3)
                  move.l #jump_normal1,d2
                  move.l #jump_revers1,d3
                  lea   or_and_set+jump_off,a2
                  pea   normal_long_e(pc)
                  exg   sp,d5
                  jmp   or_and_set+14
normal_long_e:    move.w (sp)+,-(a1)
                  move.w (sp)+,-(a0)
                  rts
                ENDPART
normal_draw_o_a:>PART 'draw OR or AND polygon'

*Same variables as normal_poly(and same remarks!)
                  add.w d0,d0
                  lea   0(a0,d0.w),a2
                  lea   0(a1,d0.w),a3
                  move.w (a2),-(sp)
                  move.w (a3),-(sp)
                  clr.w (a2)
                  move.w add_c(pc),(a3)
                  move.l #jump_normal1,d1
                  lea   jump_normal1,a3
                  move.l #jump_revers1,d3
                  lea   or_and_set+jump_off,a2
                  pea   normal_draw_o_a_e(pc)
                  exg   sp,d5
                  jmp   or_and_set+18
normal_draw_o_a_e:move.w (sp)+,(a1)
                  move.w (sp)+,-(a0)
                  rts
                ENDPART
normal_clear:   >PART 'clear normal polygon'

*Same variables as normal_poly(and same remarks!)
                  add.w d0,d0
                  lea   0(a5,d0.w),a2
                  lea   0(a6,d0.w),a3
                  move.w (a2)+,-(sp)
                  move.w (a3)+,-(sp)
                  move.w #max_code*20*20-jump_off,-(a2)
                  move.w #-jump_off,-(a3)
                  lea   clear+jump_off,a2
                  movea.l a2,a4
                  pea   normal_clear_e(pc)
                  exg   sp,d5
                  jmp   clear+10
normal_clear_e:   move.w (sp)+,-(a6)
                  move.w (sp)+,-(a5)
                  rts
                ENDPART
revers_draw:    >PART 'draw reverse polygon'

*Same variables as normal_poly(and same remarks!)
                  add.w d0,d0
                  lea   0(a0,d0.w),a2
                  lea   0(a1,d0.w),a3
                  move.w (a2),-(sp)
                  move.w (a3),-(sp)
                  move.w add_c(pc),(a2)
                  clr.w (a3)
                  move.l #jump_revers2,d1
                  lea   jump_revers2,a3
                  move.l #jump_normal2,d3
                  lea   rev_set+jump_off,a2
                  pea   revers_draw_e(pc)
                  exg   sp,d5
                  jmp   rev_set+18
revers_draw_e:    move.w (sp)+,(a1)
                  move.w (sp)+,-(a0)
                  rts
                ENDPART
revers_clear:   >PART 'clear reverse polygon'

*Same variables as normal_poly(and same remarks!)

                  add.w d0,d0
                  lea   0(a5,d0.w),a2
                  lea   0(a6,d0.w),a3
                  move.w (a2)+,-(sp)
                  move.w (a3)+,-(sp)
                  move.w #max_code*20*20,-(a2)
                  clr.w -(a3)
                  lea   look_clear,a4
                  move.w #jump_off,d0
                  lea   clear,a2
                  adda.w d0,a2
                  pea   revers_clear_e(pc)
                  exg   sp,d5
                  jmp   clear+10
revers_clear_e:   move.w (sp)+,-(a6)
                  move.w (sp)+,-(a5)
                  rts
                ENDPART
c_rev_set_bl:   >PART 'reverse set code block'

*Same remarks as c_norm_set_bl except start and end are swapped
*Block code routine

                  lea   rev_set,a2
                  moveq #0,d4
                  moveq #20-1,d7
rev_start_set:    moveq #0,d5
                  moveq #20-1,d6
rev_end_set:      movea.l a2,a0
                  move.w d4,d1          ;swap start<-> end
                  move.w d5,d0
                  bsr   code_set
                  lea   max_code(a2),a2
                  add.w #1,d5
                  dbra  d6,rev_end_set
                  addq.w #1,d4
                  dbra  d7,rev_start_set
                  move.w #$cb8f,(a2)+
                  move.w #$4e75,(a2)+
                  addq.l #2,a2
                  move.w #$cb8f,(a2)+
                  move.w #$4e75,(a2)+
                  rts
                ENDPART
c_or_and_bl:    >PART 'or or and set code block'

*Same remarks as c_norm_set_bl except for and or or
*Block code routine

                  lea   or_and_set,a2   ;uses same block space !!!
                  moveq #0,d4
                  moveq #20-1,d7
c_or_and_start:   moveq #0,d5
                  moveq #20-1,d6
c_or_and_end:     movea.l a2,a0
                  move.w d4,d0
                  move.w d5,d1
                  bsr   code_set_o_a
                  lea   max_code(a2),a2
                  add.w #1,d5
                  dbra  d6,c_or_and_end
                  addq.w #1,d4
                  dbra  d7,c_or_and_start
                  move.w #$cb8f,(a2)+
                  move.w #$4e75,(a2)+
                  addq.l #2,a2
                  move.w #$cb8f,(a2)+
                  move.w #$4e75,(a2)+
                  rts
                ENDPART
c_long_bl:      >PART 'long set code block'

*Same remarks as c_norm_set_bl
*Block code routine

                  lea   or_and_set,a2   ;uses same block space !!!
                  moveq #0,d4
                  moveq #20-1,d7
c_long_start:     moveq #0,d5
                  moveq #20-1,d6
c_long_end:       movea.l a2,a0
                  move.w d4,d0
                  move.w d5,d1
                  bsr   code_long
                  lea   max_code(a2),a2
                  add.w #1,d5
                  dbra  d6,c_long_end
                  addq.w #1,d4
                  dbra  d7,c_long_start
                  move.w #$cb8f,(a2)+
                  move.w #$4e75,(a2)+
                  addq.l #2,a2
                  move.w #$cb8f,(a2)+
                  move.w #$4e75,(a2)+
                  rts

                ENDPART
c_poly_bl:      >PART 'word set code block'
                  lea   or_and_set,a2   ;uses same block space !!!
                  moveq #0,d4
                  moveq #20-1,d7
c_poly_start:     moveq #0,d5
                  moveq #20-1,d6
c_poly_end:       movea.l a2,a0
                  move.w d4,d0
                  move.w d5,d1
                  bsr   code_poly
                  lea   max_code(a2),a2
                  add.w #1,d5
                  dbra  d6,c_poly_end
                  addq.w #1,d4
                  dbra  d7,c_poly_start
                  move.w #$cb8f,(a2)+
                  move.w #$4e75,(a2)+
                  addq.l #2,a2
                  move.w #$cb8f,(a2)+
                  move.w #$4e75,(a2)+
                  rts
                ENDPART
code_clr_bl:    >PART 'clear code block'

* Same as other block code routines,but it's also a lookup table

                  lea   clear,a2        ;init start destination code+2
                  moveq #0,d4           ;init sdart
                  moveq #20-1,d7        ;init number of starts
                  move.w #0,d2          ;init look-up value
n_start_clr:      moveq #0,d5           ;init end
                  moveq #20-1,d6        ;init number of ends
n_end_clr:        movea.l a2,a0         ;init pointer to destination code
                  move.w d4,d0          ;init start
                  move.w d5,d1          ;init end
                  move.w d2,(a0)+       ;store look-up value
                  bsr   code_clr        ;code single rout
                  lea   max_code(a2),a2 ;next destination
                  add.w #1,d5           ;increase end
                  dbra  d6,n_end_clr    ;next end
                  add.w #max_code,d2    ;next look-up value
                  addq.w #1,d4          ;increase start
                  dbra  d7,n_start_clr  ;next start
                  move.w #$cb8f,2(a2)   ;program exg sp,d5
                  move.w #$4e75,4(a2)   ;program rts
                  rts
                ENDPART
code_norm_l:    >PART 'normal left code block'

*Block code routine

                  lea   norm_left,a2    ;init start destination code
                  moveq #0,d4           ;init start
                  moveq #20-1,d7        ;init number of starts
n_start_left:     move.w d7,-(sp)       ;stack parameter
                  moveq #0,d5           ;init end
                  moveq #19-1,d6        ;init number of ends-1
                  move.w #-jump_off,d2  ;init jump offset to check for
n_end_left:       movea.l a2,a0         ;init pointer to destination code
                  move.w d4,d0          ;init start
                  move.w d5,d1          ;init end
                  move.w #max_code*20,d7 ;init additional jump
                  bsr   code_left       ;code single rout
                  lea   max_code(a2),a2 ;next destination
                  add.w #1,d5           ;increase end
                  add.w #max_code*20,d2 ;next jump offset to check
                  dbra  d6,n_end_left   ;next end
                  movea.l a2,a0         ;same as above without additional jump
                  move.w d4,d0          ;
                  move.w d5,d1          ;
                  move.w #0,d7          ;no additional jump offset
                  bsr   code_left       ;
                  lea   max_code(a2),a2 ;
                  addq.w #1,d4          ;increase start
                  move.w (sp)+,d7       ;unstack
                  dbra  d7,n_start_left ;next start
                  move.w #$cb8f,(a2)+   ;program exg sp,d5
                  move.w #$4e75,(a2)+   ;program rts
                  addq.l #2,a2          ;
                  move.w #$cb8f,(a2)+   ;program exg sp,d5
                  move.w #$4e75,(a2)+   ;program rts
                  rts
                ENDPART
code_norm_r:    >PART 'normal right code block'

*Block code routine
                  tst.w and_or          ;if and or or
                  bne.s nor_a_o         ;jump
                  move.w #$c681,nor_or_and ;else or
                  bra.s nor_a_o_2       ;
nor_a_o:          move.w #$8681,nor_or_and ;do and
nor_a_o_2:        lea   norm_right,a2   ;init start destination code
                  moveq #0,d2           ;SWAP flag=0
                  moveq #0,d4           ;init start
                  moveq #20-1,d7        ;init number of starts
n_start_right:    moveq #0,d5           ;init end
                  moveq #20-1,d6        ;init number of ends
n_end_right:      movea.l a2,a0         ;init pointer to destination code
                  move.w d4,d0          ;init start
                  move.w d5,d1          ;init end
                  bsr   code_right      ;code single rout
                  lea   max_code(a2),a2 ;next destination
                  add.w #1,d5           ;increase end
                  dbra  d6,n_end_right  ;next end
                  addq.w #1,d4          ;increase start
                  dbra  d7,n_start_right ;next start
                  move.w #$cb8f,(a2)+   ;program exg sp,d5
                  move.w #$4e75,(a2)+   ;program rts
                  addq.l #2,a2          ;
                  move.w #$cb8f,(a2)+   ;program exg sp,d5
                  move.w #$4e75,(a2)+   ;program rts
                  rts
                ENDPART
code_rev_l:     >PART 'reverse left code block'

*Block code routine
                  lea   rev_left,a2     ;init start destination code
                  moveq #0,d4           ;init end
                  moveq #19-1,d7        ;init number of ends-1
                  moveq #0,d2           ;init jump offset to check for
r_end_left:       move.w d7,-(sp)       ;stack
                  moveq #0,d5           ;init start
                  moveq #20-1,d6        ;init number of starts
r_start_left:     movea.l a2,a0         ;init pointer to destination code
                  move.w d5,d0          ;init end
                  move.w d4,d1          ;init start
                  move.w #max_code,d7   ;init additional jump offset
                  bsr   code_left       ;code single rout
                  lea   max_code(a2),a2 ;next destination
                  add.w #1,d5           ;increase start
                  dbra  d6,r_start_left ;next start
                  addq.w #1,d4          ;increase end
                  add.w #max_code,d2    ;next jump offset
                  move.w (sp)+,d7       ;unstack
                  dbra  d7,r_end_left   ;next end

                  moveq #0,d5           ;same as above without additional jump
                  moveq #20-1,d6        ;
r_left_end_l:     movea.l a2,a0         ;
                  move.w d5,d0          ;
                  move.w d4,d1          ;
                  move.w #0,d7          ;no additional jump offset
                  bsr   code_left       ;
                  lea   max_code(a2),a2 ;
                  add.w #1,d5           ;
                  dbra  d6,r_left_end_l ;

                  move.w #$cb8f,(a2)+   ;program exg sp,d5
                  move.w #$4e75,(a2)+   ;program rts
                  addq.l #2,a2          ;
                  move.w #$cb8f,(a2)+   ;program exg sp,d5
                  move.w #$4e75,(a2)+   ;program rts
                  rts
                ENDPART
code_rev_r:     >PART 'reverse right code block'

*Block code routine
                  tst.w and_or          ;if and or or
                  bne.s rev_a_o         ;jump
                  move.w #$c681,rev_or_and ;else or
                  bra.s rev_a_o_2       ;
rev_a_o:          move.w #$8681,rev_or_and ;do and
rev_a_o_2:        lea   rev_right,a2    ;init start destination code
                  moveq #0,d4           ;init start
                  moveq #-1,d2          ;SWAP flag<>0
                  moveq #20-1,d7        ;init number of ends
r_end_right:      moveq #0,d5           ;init start
                  moveq #20-1,d6        ;init number of ends
r_start_right:    movea.l a2,a0         ;init pointer to destination code
                  move.w d5,d0          ;init end
                  move.w d4,d1          ;init start
                  bsr.s code_right      ;code single rout
                  lea   max_code(a2),a2 ;next destination
                  add.w #1,d5           ;increase start
                  dbra  d6,r_start_right ;next start
                  addq.w #1,d4          ;incruase end
                  dbra  d7,r_end_right  ;next end
                  move.w #$cb8f,(a2)+   ;program exg sp,d5
                  move.w #$4e75,(a2)+   ;program rts
                  addq.l #2,a2          ;
                  move.w #$cb8f,(a2)+   ;program exg sp,d5
                  move.w #$4e75,(a2)+   ;program rts
                  rts
                ENDPART
code_right:     >PART 'precode a right set/clear rout'

*a0 pointer to destination code
*d0 word offset left
*d1 word offset right

                  move.w #$4843,(a0)+   ;code swap d3
                  cmp.w d1,d0           ;
                  bgt.s right_clear     ;if left>right,jump
                  sub.w d0,d1           ;calc number of words
                  lsl.w #3,d0           ;plane skip
                  add.w #-160,d0        ;
                  tst.w d1              ;if no words
                  beq.s no_words_s      ;jump
                  subq.w #1,d1          ;-1 for dbf
                  move.w #$3f46,d3      ;-> move.w d6,off(a7)
r_word_set_l:     move.w d3,(a0)+       ;program
                  move.w d0,(a0)+       ;offset
                  addq.w #8,d0          ;next word
                  dbra  d1,r_word_set_l ;
no_words_s:       move.w #$3f43,(a0)+   ;program move.w d3,off(a7)
                  move.w d0,(a0)+       ;
                  bra.s right_c         ;program remaining code
right_clear:      sub.w d1,d0           ;calc number of words
                  lsl.w #3,d1           ;plane skip
                  add.w #-160,d1        ;
                  move.w #$3f43,(a0)+   ;program move.w d3,off(a7)
                  move.w d1,(a0)+       ;
                  subq.w #1,d0          ;-1 for dbf
                  move.w #$3f47,d3      ;-> move.w d7,off(a7)
r_word_clr_l:     addq.w #8,d1          ;next word
                  move.w d3,(a0)+       ;program
                  move.w d1,(a0)+       ;offset
                  dbra  d0,r_word_clr_l ;
right_c:          tst.w d2              ;if swap needed
                  beq.s right_nor_c     ;
                  lea   right_rev(pc),a1 ;init pointer to swapped right code
                  move.w #right_len_rev-1,d0 ;init len of code
                  bra.s right_c_l       ;
right_nor_c:      lea   right_nor(pc),a1 ;init pointer to normal right code
                  move.w #right_len_nor-1,d0 ;init len of right code rout
right_c_l:        move.w (a1)+,(a0)+    ;copy
                  dbra  d0,right_c_l    ;until finished
                  rts
                ENDPART
code_left:      >PART 'precode a left set/clear rout'

*a0 pointer to destination code
*d0 word offset left
*d1 word offset right
*d2 immediate value for cmp.w #i,d1


                  cmp.w d1,d0           ;if left<right
                  ble.s left_clear      ;jump
                  sub.w d1,d0           ;calc number of words
                  lsl.w #3,d1           ;skip planes
                  move.w #$4841,(a0)+   ;swap d1
                  move.w #$3f41,(a0)+   ;->move.w d1,off(sp)
                  move.w d1,(a0)+       ;
                  subq.w #1,d0          ;
                  move.w #$3f46,d3      ;->move.w d6,off(sp)
l_word_set_l:     addq.w #8,d1          ;next
                  move.w d3,(a0)+       ;program
                  move.w d1,(a0)+       ;offset
                  dbra  d0,l_word_set_l ;next
left_set_e:
                  move.w #$4fef,(a0)+   ;code lea off(sp),sp
                  move.w #160,(a0)+     ;
                  lea   s_left_2(pc),a1 ;init pointer to left code
                  move.w #3-1,d0        ;init len of left code rout
left_set_l:       move.w (a1)+,(a0)+    ;copy instruction
                  dbra  d0,left_set_l   ;
                  rts

left_clear:
                  move.w d1,d3          ;copy
                  lsl.w #3,d3           ;
                  move.w #$4841,(a0)+   ;swap d1
                  move.w #$3f41,(a0)+   ;->move.w d1,off(a7)
                  move.w d3,(a0)+       ;
                  sub.w d0,d1           ;calc number of words
                  lsl.w #3,d0           ;skip planes
                  tst.w d1              ;if no words
                  beq.s left_clr_e      ;jump
                  subq.w #1,d1          ;calc number of words
                  move.w #$3f47,d3      ;-> move.w d7,off(a7)
l_word_clr_l:     move.w d3,(a0)+       ;program
                  move.w d0,(a0)+       ;offset
                  addq.w #8,d0          ;next
                  dbra  d1,l_word_clr_l ;
left_clr_e:
                  lea   left_s_c(pc),a1 ;init pointer to left code

                  move.w #$4fef,(a0)+   ;code lea off(sp),sp
                  move.w #160,(a0)+     ;

                  move.l (a1)+,(a0)+    ;->move.w (a6)+,d6 ,cmp.w #i,d1
                  addq.l #2,a1          ;next instruction
                  move.w d2,(a0)+       ;
                  move.w (a1)+,(a0)+    ;bgt.s +x
                  move.w #left_len-1,d0 ;init len of left code bout
left_c_clr:       move.w (a1)+,(a0)+    ;copy instruction
                  dbra  d0,left_c_clr   ;
                  move.w (a1)+,(a0)+    ;->move.w #i,d1
                  addq.l #2,a1          ;next instruction
                  add.w d2,d7           ;
                  move.w d7,(a0)+       ;
                  move.l (a1)+,(a0)+    ;->jmp 0(a3,d3.w)
                  rts
                ENDPART
code_set:       >PART 'precode a set rout'

*a0 pointer to destination code
*d0 word offset left
*d1 word offset right

                  cmp.w d0,d1           ;if end<start
                  ble.s code_set_ge     ;jump
                  move.w #$32c0,(a0)+   ;code move.w d0,(a1)+
                  bra.s code_set_ne     ;
code_set_ge:
                  move.l #$32f33002,(a0)+ ;code  move.w 2(a3,d1.w),(a1)+
                  exg   d0,d1           ;
                  sub.w d0,d1           ;calc number of words
                  lsl.w #3,d0           ;skip planes
                  tst.w d1              ;if no words
                  beq.s code_set_eq     ;next code
                  move.w #$4840,(a0)+   ;code swap d0
                  move.w #$3f40,(a0)+   ;code move.w d0,off(a7)
                  move.w d0,(a0)+       ;
                  subq.w #2,d1          ;-1 for dbf
                  bmi.s code_set_end2   ;
                  move.w #$3f46,d2      ;->move.w d6,off(a7)
code_set_w2:      addq.w #8,d0          ;skip planes
                  move.w d2,(a0)+       ;code
                  move.w d0,(a0)+       ;offset
                  dbra  d1,code_set_w2  ;next
code_set_end2:    addq.w #8,d0          ;next offset
                  move.w #$4842,(a0)+   ;code swap d2
                  move.w #$3f42,(a0)+   ;code move.w d2,off(a7)
                  move.w d0,(a0)+       ;
                  bra.s code_set_ne     ;next code
code_set_eq:      move.w #$4840,(a0)+   ;code swap d0
                  move.w #$4842,(a0)+   ;code swap d2
                  tst.w and_or          ;if or or and
                  bne.s set_or          ;
                  move.w #$c440,(a0)+   ;code and.w d0,d2
                  bra.s set_and         ;
set_or:           move.w #$8440,(a0)+   ;code or.w d0,d2
set_and:          move.w #$3f42,(a0)+   ;code move.w d2,off(a7)
                  move.w d0,(a0)+       ;
code_set_ne:      lea   set_c(pc),a1    ;
                  move.w #set_len-1,d2  ;number of instructions
code_set_n_l:     move.w (a1)+,(a0)+    ;code instruction
                  dbra  d2,code_set_n_l ;next
                  rts
                ENDPART
code_poly:      >PART 'precode ordinary poly rout'

*a0 pointer to deestination code
*d0 word offset left
*d1 word offset right

                  exg   d0,d1           ;
                  sub.w d0,d1           ;calc number of words
                  lsl.w #3,d0           ;left offfset * 8
                  tst.w d1              ;if no words,jump
                  blt.s code_poly_e_2   ;
                  beq.s code_poly_4     ;
                  move.l #$48404841,(a0)+ ;code swap d0,swap d1
                  tst.w and_or          ;if and.jump
                  bne.s code_poly_2     ;
                  move.w #$816f,(a0)+   ;code or.w   d0,off(sp)
                  bra.s code_poly_3     ;next
code_poly_2:      move.w #$c16f,(a0)+   ;code and    d0,off(sp)
code_poly_3:      move.w d0,(a0)+       ;copy offset
                  addq.w #8,d0          ;
                  subq.w #2,d1          ;-1 for dbf and first word
                  bmi.s code_poly_e     ;
code_poly_w_l:    move.w #$3f47,(a0)+   ;code move.w d7,off(sp)
                  move.w d0,(a0)+       ;copy offset
                  addq.w #8,d0          ;next offset
                  dbra  d1,code_poly_w_l ;
                  bra.s code_poly_e     ;next
code_poly_4:      move.l #$48404841,(a0)+ ;code swap d0,swap d1
                  tst.w and_or          ;if or,jump
                  beq.s code_poly_5     ;
                  move.w #$8240,(a0)+   ;code or.w d0,d1
                  bra.s code_poly_e     ;next
code_poly_5:      move.w #$c240,(a0)+   ;code and.w d0,d1
code_poly_e:      tst.w and_or          ;
                  bne.s code_poly_9     ;
                  move.w #$836f,(a0)+   ;code or.w d1,off(sp)
                  bra.s code_poly_10    ;next
code_poly_9:      move.w #$c36f,(a0)+   ;code and.w d1,off(sp)
code_poly_10:     move.w d0,(a0)+       ;
code_poly_e_2:    move.w #poly_len-1,d2 ;number of words to copy
                  lea   s_poly(pc),a1   ;pointer to code
code_poly_e_l:    move.w (a1)+,(a0)+    ;code words
                  dbra  d2,code_poly_e_l ;next
                  rts
                ENDPART
code_set_o_a:   >PART 'precode a OR or AND set rout'

*Same remarks as code_set except for the OR or AND

*a0 pointer to destination code
*d0 word offset left
*d1 word offset right

                  cmp.w d0,d1
                  ble.s code_set_ge_or
                  move.w #$32c0,(a0)+
                  bra.s code_set_ne_or
code_set_ge_or:   move.l #$32f33002,(a0)+ ;code  move.w 2(a3,d3.w),(a1)+
                  exg   d0,d1
                  sub.w d0,d1
                  lsl.w #3,d0
                  tst.w d1
                  beq.s code_set_eq_or
                  move.w #$4840,(a0)+
                  tst.w and_or
                  bne.s set_or_or_1
                  move.w #$816f,(a0)+   ;code or.w d0,off(a7)
                  bra.s set_and_or_1    ;
set_or_or_1:      move.w #$c16f,(a0)+   ;code and.w d0,off(a7)
set_and_or_1:     move.w d0,(a0)+
                  subq.w #2,d1
                  bmi.s code_set_end2_or
                  move.w #$3f46,d2
code_set_w2_or:   addq.w #8,d0
                  move.w d2,(a0)+
                  move.w d0,(a0)+
                  dbra  d1,code_set_w2_or
code_set_end2_or: addq.w #8,d0
                  move.w #$4842,(a0)+
                  tst.w and_or
                  bne.s set_or_or_2
                  move.w #$856f,(a0)+   ;code or.w d2,off(a7)
                  bra.s set_and_or_2    ;
set_or_or_2:      move.w #$c56f,(a0)+   ;code and.w d2,off(a7)
set_and_or_2:     move.w d0,(a0)+
                  bra.s code_set_ne_or
code_set_eq_or:   move.w #$4840,(a0)+
                  move.w #$4842,(a0)+
                  tst.w and_or
                  bne.s set_or_or_3
                  move.w #$c440,(a0)+   ;code and.w d0,d2
                  move.w #$856f,(a0)+   ;code or.w d2,off(a7)
                  bra.s set_and_or_3
set_or_or_3:      move.w #$8440,(a0)+
                  move.w #$c56f,(a0)+   ;code and.w d2,off(a7)
set_and_or_3:     move.w d0,(a0)+
code_set_ne_or:   lea   set_c(pc),a1
                  move.w #set_len-1,d2
code_set_n_l_or:  move.w (a1)+,(a0)+
                  dbra  d2,code_set_n_l_or
                  rts
                ENDPART
code_clr:       >PART 'precode a clear rout'

*a0 pointer to destination code
*d0 word offset left
*d1 word offset right

                  cmp.w d0,d1           ;if end>start
                  bgt.s code_clr_gt     ;jump
                  exg   d0,d1           ;end<->start
code_clr_gt:      sub.w d0,d1           ;calc lenght
                  lsl.w #3,d0           ;skip planes
                  move.w #$3f47,d3      ;->move.w d7,off(a7)
code_clr_w:       move.w d3,(a0)+       ;code
                  move.w d0,(a0)+       ;offset
                  addq.w #8,d0          ;skip planes
                  dbra  d1,code_clr_w   ;next
                  lea   clear_c(pc),a1  ;init pointer
                  move.w #clear_len-1,d0 ;number of instructions
code_clr_ne_l:    move.w (a1)+,(a0)+    ;copy instruction
                  dbra  d0,code_clr_ne_l ;next
                  rts
                ENDPART
code_long:      >PART 'precode a long rout'

*a0 pointer to destination code
*d0 left screen offset
*d1 right screen offset


                  cmp.w d0,d1           ;if right>left
                  bgt   code_long_gt    ;jump
                  blt.s code_long_lt    ;else jump

                  move.w #$4840,(a0)+   ;code swap d0
                  move.w #$4841,(a0)+   ;code swap d1
                  lsr.w #1,d1           ;/2
                  bcc.s eq_even         ;if even,jump
                  lsl.w #4,d1           ;x*16/2=offset
                  addq.w #2,d1          ;offset=offset+2
                  bra.s eq_even_2       ;next
eq_even:          lsl.w #4,d1           ;'           '
eq_even_2:        addq.w #6,d1          ;offset=offset+6
                  move.w #$c240,(a0)+   ;code and d0,d1
                  move.w #$836f,(a0)+   ;code or.w d1,off(sp)
                  move.w d1,(a0)+       ;code offset
                  bra.s code_long_gt    ;next

code_long_lt:     exg   d0,d1           ;
                  move.w #$4840,(a0)+   ;code swap d0
                  move.w #$4841,(a0)+   ;code swap d1
                  move.w d1,d2          ;copy
                  sub.w d0,d2           ;calc lenght
                  subq.w #1,d2          ;-1 (first word not counted)

                  move.w d0,d3          ;store offset
                  lsr.w #1,d0           ;/2
                  bcc.s long_ev_l       ;jump
                  lsl.w #4,d0           ;*16
                  addq.w #8,d0          ;as above
                  move.w #$816f,(a0)+   ;code or.w d0,off(sp)
                  move.w d0,(a0)+       ;
                  bra.s long_ev_l_2     ;

long_ev_l:        lsl.w #4,d0           ;
                  addq.w #6,d0          ;
                  move.w #$816f,(a0)+   ;code or.w d0,off(sp)
                  move.w d0,(a0)+       ;
                  tst.w d2              ;if lengt=0
                  beq.s long_ev_l_2     ;jump
                  subq.w #1,d2          ;total words -1
                  move.w #$3f47,(a0)+   ;code move.w d7,off(sp)
                  addq.w #2,d0          ;
                  move.w d0,(a0)+       ;

long_ev_l_2:      lsr.w #1,d1           ;/2
                  bcc.s long_ev_r_2     ;jump
                  lsl.w #4,d1           ;*16
                  addq.w #6,d1          ;
                  tst.w d2              ;if lengt<=0
                  beq.s long_word_r     ;jump
                  subq.w #1,d2          ;total words -1
                  move.w #$3f47,(a0)+   ;code move.w d7,off(sp)
                  move.w d1,(a0)+       ;

long_word_r:      addq.w #2,d1          ;offset + 2
                  move.w #$836f,(a0)+   ;code or.w d1,off(sp)
                  move.w d1,(a0)+       ;
                  bra.s long_word_l     ;next

long_ev_r_2:      lsl.w #4,d1           ;*16
                  addq.w #6,d1          ;as above
                  move.w #$836f,(a0)+   ;code or.w d1,off(sp)
                  move.w d1,(a0)+       ;

long_word_l:      and.w #$fffe,d3       ;
                  lsl.w #3,d3           ;calc offset
                  addq.w #6,d3          ;+6
                  lsr.w #1,d2           ;number of words /2 =number of longs
                  bge.s long_word_l_3   ;
                  bra.s code_long_lt    ;next

long_word_l_2:    add.w #16,d3          ;next offset
                  move.w #$2f47,(a0)+   ;code move.l d7,off(sp)
                  move.w d3,(a0)+       ;store offset
long_word_l_3:    dbra  d2,long_word_l_2 ;

code_long_gt:     move.w #long_len-1,d0 ;number of words to be copied
                  lea   set_c_long(pc),a1 ;pointer to code
code_long_co:     move.w (a1)+,(a0)+    ;copy
                  dbra  d0,code_long_co ;next
                  rts

                ENDPART
right_nor:      >PART 'normal set/clr code for right'

*same remarks as right_rev except for the offsets

s_right_nor:      move.w (a0),d0
                  and.w d4,d0
                  movea.l d0,a4
                  move.l (a4),d1
                  move.w d1,(a0)+
                  move.w (a1),d2
                  and.w d4,d2
                  movea.l d2,a4
                  move.l (a4),d3
                  cmp.w d1,d3
                  ble.s equ_right_nor
                  move.w d3,(a1)+
                  add.w (a5)+,d1
                  jmp   0(a2,d1.w)
equ_right_nor:    blt.s no_nor_set
nor_or_and:       or.l  d1,d3
                  move.w d3,(a1)+
                  add.w (a5)+,d1
                  jmp   6(a2,d1.w)
no_nor_set:       move.l d7,d3
                  move.w d1,d3
                  move.w d3,(a1)+
                  add.w (a5)+,d1
                  jmp   6(a2,d1.w)
e_right_nor:
                ENDPART
right_rev:      >PART 'reverse set/clr code for right'

*Same remarks as right_nor except that the masks are swapped

s_right_rev:      move.w (a0),d0
                  and.w d4,d0
                  movea.l d0,a4
                  move.l (a4),d1        ;left
                  move.w d1,(a0)+
                  move.w (a1),d2
                  and.w d4,d2
                  movea.l d2,a4
                  move.l (a4),d3        ;right
                  cmp.w d1,d3
                  ble.s equ_right_rev
                  move.w d3,(a1)+
                  add.w (a5)+,d1
                  jmp   0(a2,d1.w)
equ_right_rev:    blt.s no_rev_set
rev_or_and:       or.l  d1,d3
                  move.w d3,(a1)+
                  add.w (a5)+,d1
                  jmp   6(a2,d1.w)
no_rev_set:       move.l d7,d3
                  move.w d1,d3
                  move.w d3,(a1)+
                  add.w (a5)+,d1
                  jmp   6(a2,d1.w)
e_right_rev:

                ENDPART
left_s_c:       >PART 'set/clr code for left'
                  move.w (a6)+,d1       ;
                  cmp.w #0,d1           ;if right part overlaps left part
                  ble.s e_left          ;special case
s_left:           add.w d1,d3           ;else,calc routine index
                  jmp   0(a3,d3.w)      ;jump to specified routine
e_left:           add.w #0,d3           ;skip overlapping area
                  jmp   0(a3,d3.w)      ;etc.
s_left_2:         add.w (a6)+,d3        ;if no compare faster
                  jmp   0(a3,d3.w)      ;

                ENDPART
set_c:          >PART 'set code'

s_set:            lea   160(sp),sp      ;next screen-line
                  move.w (a0),d1        ;fetch new-left x-coord
                  and.w d4,d1           ;
                  movea.l d1,a4         ;
                  move.l (a4),d0        ;fetch left mask + jump offset
                  move.w d0,(a0)+       ;store jump offset
                  move.w (a1),d3        ;fetch new-right x-coord
                  and.w d4,d3           ;
                  movea.l d3,a4         ;
                  move.l (a4),d2        ;fetch right mask + jump offset
                  add.w d0,d2           ;calc routine index
                  jmp   0(a2,d2.w)      ;jump to specified routine
e_set:
                ENDPART
clear_c:        >PART 'clear code'
s_clr:            lea   160(sp),sp      ;new screen line
                  move.w (a5)+,d0       ;fetch old left jump-off
                  move.w (a6)+,d1       ;'       ' right '     '
                  add.w 0(a4,d1.w),d0   ;convert right index to new index
                  jmp   2(a2,d0.w)      ;jump to specified routine
e_clr:
                ENDPART
set_c_long:     >PART 'set long code'

s_long:           lea   160(sp),sp      ;8 next screen-line
                  moveq #%11111000,d0   ;4 mask bits 0,1,2 to index
                  moveq #%11111000,d1   ;4
                  and.w (a0)+,d0        ;8 fetch left coord
                  and.w (a1)+,d1        ;8 '   ' right '   '
                  move.l 0(a3,d0.w),d0  ;18 fetch left mask + jump offset
                  move.l 0(a4,d1.w),d1  ;18 '   ' right '               '
                  add.w d0,d1           ;4 calc jump offset
                  jmp   0(a2,d1.w)      ;14 jump to specified routine
e_long:           nop                   ;86 clockcycles
                ENDPART
poly_code:      >PART 'ordinary poly rout'

s_poly:           lea   160(sp),sp
                  move.w (a0)+,d2
                  move.w (a1)+,d3
                  and.w d4,d2
                  and.w d4,d3
                  movea.l d2,a3
                  move.l (a3),d0
                  movea.l d3,a3
                  move.l (a3),d1
                  add.w d0,d1
                  jmp   0(a2,d1.w)
e_poly:           nop
                ENDPART
mask_norm_t:    >PART 'create a normal jump-table'

* Mask + jump-offset table for both delta and set routines

                  move.w clear_pat(pc),d6 ;init clear pattern
                  move.w fill_pat(pc),d7 ;init fill pattern
                  lea   jump_normal1,a0 ;pointer to destination table pointer to left masks
                  lea   jump_normal2,a5 ;
                  move.w d7,d0          ;
                  swap  d0              ;
                  clr.w d0              ;first clip constant
                  move.w d6,d1          ;
                  swap  d1              ;
                  clr.w d1              ;second clip constant
                  bsr   make_clip_tab   ;create right clip
                  lea   left_mask(pc),a1 ;pointer to left masks
                  lea   right_mask(pc),a2 ;'        ' right masks
                  move.w #0,d2          ;init jump-offsets
                  move.w #0,d3          ;
                  moveq #20-1,d1        ;number of words
norm_word_l:      movea.l a1,a3         ;init pointer to masks
                  movea.l a2,a4         ;
                  moveq #16-1,d0        ;16 masks a word
norm_mask_l:      move.w (a3)+,d5       ;fetch mask
                  move.w d5,d4          ;
                  not.w d4              ;
                  and.w d7,d5           ;mask with fill pattern
                  and.w d6,d4           ;not(mask) with clear pattern
                  or.w  d4,d5           ;merge both
                  move.w d5,(a0)+       ;store mask + jump offset
                  move.w d2,(a0)+       ;
                  move.w (a4)+,d5       ;
                  move.w d5,d4          ;
                  not.w d4              ;
                  and.w d7,d5           ;same as above
                  and.w d6,d4           ;
                  or.w  d4,d5           ;
                  move.w d5,(a5)+       ;
                  move.w d3,(a5)+       ;
                  dbra  d0,norm_mask_l  ;next mask
                  add.w #max_code,d2    ;next jump-offset
                  add.w #max_code,d3    ;
                  dbra  d1,norm_word_l  ;next word
                  move.w d6,d0          ;
                  swap  d0              ;
                  move.w #max_code*19,d0 ;first clip constant
                  move.w d7,d1          ;
                  swap  d1              ;
                  move.w #max_code*19,d1 ;second clip constants
                  bsr   make_clip_tab   ;create left clip
                  rts
                ENDPART
mask_rev_t:     >PART 'create a reverse jump-table'

* Mask + jump-offset table for both delta and set routines

                  move.w clear_pat(pc),d6 ;init clear pattern
                  move.w fill_pat(pc),d7 ;init fill pattern
                  lea   jump_revers1,a0 ;pointer to destination table
                  lea   jump_revers2,a5 ;pointer to destination table
                  move.w d6,d0          ;
                  swap  d0              ;
                  move.w #-jump_off,d0  ;first clip constant
                  move.w d7,d1          ;
                  swap  d1              ;
                  move.w #-jump_off,d1  ;
                  bsr   make_clip_tab   ;create right clip
                  lea   left_mask(pc),a1 ;pointer to left masks
                  lea   right_mask(pc),a2 ;'        ' riwht masks
                  move.w #-jump_off,d2  ;init jump-offsets
                  move.w #-jump_off,d3  ;
                  moveq #20-1,d1        ;number of words
rev_word_l:       movea.l a1,a3         ;init pointer to masks
                  movea.l a2,a4         ;
                  moveq #16-1,d0        ;16 masks a word
rev_mask_l:       move.w (a4)+,d5       ;
                  move.w d5,d4          ;
                  not.w d4              ;
                  and.w d7,d5           ;mask with fill pattern
                  and.w d6,d4           ;not(mask) with clear pattern
                  or.w  d4,d5           ;merge both
                  move.w d5,(a0)+       ;store mask + jump offset
                  move.w d2,(a0)+       ;
                  move.w (a3)+,d5       ;
                  move.w d5,d4          ;
                  not.w d4              ;
                  and.w d7,d5           ;
                  and.w d6,d4           ;same as above
                  or.w  d4,d5           ;
                  move.w d5,(a5)+       ;
                  move.w d3,(a5)+       ;
                  dbra  d0,rev_mask_l   ;next mask
                  add.w #max_code*20,d2 ;next jump-offset
                  add.w #max_code*20,d3 ;
                  dbra  d1,rev_word_l   ;next word
                  move.w d7,d0          ;
                  swap  d0              ;
                  move.w #max_code*380-jump_off,d0 ;first clip constant
                  move.w d6,d1          ;
                  swap  d1              ;
                  move.w #max_code*380-jump_off,d1 ;second clip constant
                  bsr   make_clip_tab   ;create right clip
                  move.w #max_code*400-jump_off,d2 ;point to rts
                  clr.w (a0)+           ;no mask
                  move.w d2,(a0)+       ;
                  clr.w (a5)+           ;
                  move.w d2,(a5)+       ;
                  rts
                ENDPART
look_up_clr:    >PART 'create clear lookup table'

* Lookup table which the clear routine uses

                  lea   look_clear,a0   ;pointer to lookup table
                  move.w #20-1,d0       ;number of words
                  move.w #-jump_off,d1  ;init jump offset
look_up_l:        move.w d1,(a0)        ;store lookup value
                  lea   max_code(a0),a0 ;next allocation
                  add.w #max_code*20,d1 ;next value
                  dbra  d0,look_up_l    ;
                  rts                   ;
                ENDPART
mul160_tab:     >PART 'create 160 mul tab'
                  lea   mul_160,a0      ;pointer to mul table
                  move.w #200-1,d0      ;number of h-lines
                  moveq #0,d1           ;init y-screen coord
mul_l:            move.w d1,(a0)+       ;copy y-screen coord
                  add.w #160,d1         ;next
                  dbra  d0,mul_l        ;
                  rts                   ;
                ENDPART
mul320_tab:     >PART 'create 320 mul even tab'
                  lea   mul_320,a0      ;pointer to mul table
                  move.w #200-1,d0      ;number of h-lines
                  moveq #0,d1           ;init y-screen coord
mul_even_l:       move.w d1,(a0)+       ;copy y-screen coord
                  add.w #320,d1         ;next
                  dbra  d0,mul_even_l   ;
                  rts                   ;
                ENDPART
rip_jump_tab:   >PART 'create ripple jump tab'
                  lea   ripple_j_p+200*2+2,a0 ;pionter to ripple offset jump tab
                  move.w #201-1,d0      ;n times
                  move.w #200*10,d1     ;
                  moveq #10,d2          ;
rip_jump_l:       move.w d1,-(a0)       ;
                  sub.w d2,d1           ;
                  dbra  d0,rip_jump_l   ;
                  rts
                ENDPART
x_calc_jump_t:  >PART 'create calc line jump tab'
                  lea   calc_x_jump,a0  ;pointer to calc_x offset jump tab
                  move.w #201-1,d0      ;n times
                  move.w #200*6,d1      ;
                  moveq #6,d2           ;
x_c_jump_l:       move.w d1,(a0)+       ;
                  sub.w d2,d1           ;
                  dbra  d0,x_c_jump_l   ;
                  rts
                ENDPART
make_clip_tab:  >PART 'create a clip table'

* USING:

*d0 clip parameter 1
*d1 clip parameter 2
*a0 pointer to clip table

                  move.w #clip_space-1,d2 ;number of clip parameters
clip_l:           move.l d0,(a0)+       ;store parameter 1
                  move.l d1,(a5)+       ;'             ' 2
                  dbra  d2,clip_l       ;next
                  rts                   ;
                ENDPART

draw_line:      >PART 'draws a line'
                  movea.l screen1,a0
                  adda.w d0,a0
                  moveq #1,d7
                  moveq #2,d6
                  moveq #4,d5
                  moveq #8,d4
                  moveq #16,d3
                  moveq #32,d2
                  moveq #64,d1
                  moveq #128,d0
                  jsr   (a2)
                  rts
                ENDPART
do_line:        >PART 'precalc lines'

*USING:

*a1 pointer to destination code
*a4 pointer to line sequence

*RETURNING:

*a1 pointing behind destination code
*d1 number of points_set*4

                  move.l a1,-(sp)
                  bra.s do_next_l
do_pen_up:        move.l (a4)+,d6
do_next_l:        tst.w (a4)+
                  bmi.s do_pen_up
                  bne.s do_line_end
                  move.l (a4)+,d7
                  move.l d6,d0
                  move.l d7,d1
                  bsr.s calc_line
                  move.l d7,d6
                  bra.s do_next_l
do_line_end:      move.l a1,d1
                  sub.l (sp)+,d1
                  move.w #$4e75,(a1)+
                  rts
                ENDPART
init_line:      >PART 'init lines'
                  bsr   pre_x_j
                  bsr   pre_eor_tab
                  bsr   pre_c_x_l
                  bsr   pre_c_y_l
                  bsr   pre_c_l_add
                  rts
                ENDPART
calc_line:      >PART 'calc line'

*d0.l start point
*d1.l end point
*a1 destination code

                  swap  d0
                  swap  d1

                  movem.l d6-d7,-(sp)   ;
                  cmp.w d0,d1           ;
                  bgt.s calc_line_2     ;
                  exg   d0,d1           ;min coord first
calc_line_2:      move.w d0,d3          ;start x
                  move.w d1,d2          ;
                  sub.w d0,d2           ;dx
                  sub.w add_c2(pc),d3   ;asjust screen
                  swap  d0              ;
                  swap  d1              ;
                  sub.w d0,d1           ;dy
                  bpl.s calc_line_plus  ;

calc_line_min:    move.w #-160,d4       ;
                  neg.w d1              ;
                  bra.s calc_line_plus_2
;
calc_line_plus:   move.w #160,d4        ;
calc_line_plus_2:
                  lea   mul_160,a0      ;160 mul tab
                  add.w d0,d0           ;
                  move.w 0(a0,d0.w),d5  ;find it

                  cmp.w d2,d1           ;dx>dy?
                  bgt.s calc_line_plus_dy ;

                  move.w d3,d7          ;
                  and.w #15,d7          ;

                  add.w d3,d3           ;
                  add.w d3,d3           ;
                  lea   find_eor_t,a0   ;
                  move.l 0(a0,d3.w),d0  ;find right eor instruction
                  add.w d5,d0           ;add screen adjust
                  lea   x_line_bl,a0    ;
                  lea   jump_l_x,a2     ;
                  move.w d2,d6          ;copy dx
                  move.w d1,d5          ;copy dy
                  add.w d7,d2           ;
                  add.w d2,d2           ;
                  adda.w 2(a2,d2.w),a0  ;
                  move.w #$4e75,(a0)    ;code rts
                  lea   x_line_bl,a3    ;
                  add.w d7,d7           ;
                  adda.w 0(a2,d7.w),a3  ;
                  move.l #$02000000,d1  ;
                  move.l #$f2000001,d2  ;
                  move.l #$f2000007,d3  ;
                  move.w d6,d7          ;
                  lsr.w #1,d7           ;1/2 dx
                  jsr   (a3)            ;
                  move.w #$22c0,(a0)    ;code move.l d0,(a1)+
                  movem.l (sp)+,d6-d7   ;
                  rts

calc_line_plus_dy:add.w d3,d3           ;
                  add.w d3,d3           ;
                  lea   find_eor_t,a0   ;
                  lea   line_ad_2,a2    ;
                  adda.w d3,a2          ;
                  move.l 0(a0,d3.w),d0  ;find right eor instruction
                  add.w d5,d0           ;add screen adjust
                  move.w d1,d6          ;copy dy
                  move.w d2,d5          ;copy dx
                  lea   y_line_bl,a0    ;
                  lea   jump_l_x,a3     ;
                  add.w d1,d1           ;
                  adda.w 2(a3,d1.w),a0  ;
                  move.w #$4e75,(a0)    ;code rts
                  move.w d6,d7          ;
                  lsr.w #1,d7           ;1/2 dy
                  jsr   y_line_bl       ;
                  move.w #$22c0,(a0)    ;code move.l d0,(a1)+
                  movem.l (sp)+,d6-d7   ;
                  rts
f:
                ENDPART
pre_c_x_l:      >PART 'precode x line routine'

                  lea   x_line_bl,a0    ;precode x lines
                  move.w #20-1,d0
pre_c_x_l_2:      move.w #7-1,d1
pre_c_x_l_3:      lea   x_line_p(pc),a1
                  move.l (a1)+,(a0)+
                  move.l (a1)+,(a0)+
                  move.l (a1)+,(a0)+
                  dbra  d1,pre_c_x_l_3
                  lea   x_line_p(pc),a1
                  move.w (a1)+,(a0)+
                  addq.l #2,a1
                  move.w #$d082,(a0)+   ;add.l d2,d0
                  move.l (a1)+,(a0)+    ;special case for plane add (2)
                  move.l (a1)+,(a0)+    ;
                  move.w #7-1,d1        ;
pre_c_x_l_4:      lea   x_line_p(pc),a1
                  move.l (a1)+,(a0)+
                  move.l (a1)+,(a0)+
                  move.l (a1)+,(a0)+
                  dbra  d1,pre_c_x_l_4
                  lea   x_line_p(pc),a1
                  move.w (a1)+,(a0)+
                  addq.l #2,a1
                  move.w #$d083,(a0)+   ;add.l d3,d0
                  move.l (a1)+,(a0)+    ;special case for plane add (6)
                  move.l (a1)+,(a0)+    ;
                  dbra  d0,pre_c_x_l_2
                  move.w #$4e75,(a0)+
                  rts
                ENDPART
pre_c_y_l:      >PART 'precode y line routine'
                  lea   y_line_bl,a0    ;precode x lines
                  move.w #200-1,d1
pre_c_y_l_1:      lea   y_line_p(pc),a1
                  move.l (a1)+,(a0)+
                  move.l (a1)+,(a0)+
                  move.l (a1)+,(a0)+
                  dbra  d1,pre_c_y_l_1
                  move.w #$4e75,(a0)+
                  rts
                ENDPART
pre_c_l_add:    >PART 'precalc line add'

                  lea   line_ad_2,a0
                  move.l #$02000000,d1
                  move.l #$f2000001,d2
                  move.l #$f2000007,d3
                  move.w #20-1,d0
pre_c_l_add_l:    move.w #7-1,d7
pre_c_l_add_l2:   move.l d1,(a0)+
                  dbra  d7,pre_c_l_add_l2
                  move.l d2,(a0)+
                  move.w #7-1,d7
pre_c_l_add_l3:   move.l d1,(a0)+
                  dbra  d7,pre_c_l_add_l3
                  move.l d3,(a0)+
                  dbra  d0,pre_c_l_add_l
                  rts
                ENDPART
pre_eor_tab:    >PART 'precalc eor tab'
                  lea   find_eor_t,a0
                  move.w #20-1,d0
                  moveq #0,d6
pre_eor_tab_l:    move.w #8-1,d7
                  lea   eor_t(pc),a1
pre_eor_tab_l_2:  move.w (a1)+,(a0)+
                  addq.l #2,a1
                  move.w d6,(a0)+
                  dbra  d7,pre_eor_tab_l_2
                  addq.w #1,d6
                  move.w #8-1,d7
                  lea   eor_t(pc),a1
pre_eor_tab_l_3:  move.w (a1)+,(a0)+
                  addq.l #2,a1
                  move.w d6,(a0)+
                  dbra  d7,pre_eor_tab_l_3
                  addq.w #7,d6
                  dbra  d0,pre_eor_tab_l
                  rts
                ENDPART
pre_x_j:        >PART 'calc 12 jump tab'
                  lea   jump_l_x,a0
                  move.w #0,d6
                  move.w #12,d1
                  move.w #320-1,d0
pre_12mul_l:      move.w d6,(a0)+
                  add.w d1,d6
                  dbra  d0,pre_12mul_l
                  rts
                ENDPART
y_line_p:       >PART 'y code piece'

y_line_p_s:       move.l d0,(a1)+       ;12
                  add.w d4,d0           ;4
                  sub.w d5,d7           ;4
                  bgt.s y_line_p_e      ;8-12
                  add.l (a2)+,d0        ;14
                  add.w d6,d7           ;4
y_line_p_e:
y_line_p_l      EQU y_line_p_e-y_line_p_s

                ENDPART
x_line_p:       >PART 'x code piece'

x_line_p_s:       move.l d0,(a1)+       ;12
                  add.l d1,d0           ;8
                  sub.w d5,d7           ;4
                  bgt.s x_line_p_e      ;8-12
                  add.w d4,d0           ;4
                  add.w d6,d7           ;4
x_line_p_e:
x_line_p_l      EQU x_line_p_e-x_line_p_s

                ENDPART
code_long_cl:   >PART 'code a long clear rout'
                  lea   clear,a0        ;pointer to clear space
                  move.w #$2140,d2      ;init code move.l d0,off(a6)
                  moveq #6,d3           ;init offset
                  move.w #200-1,d1      ;number of lines
i_long_l_l:       moveq #10-1,d0        ;number of longs a line
i_long_l:         move.w d2,(a0)+       ;code
                  move.w d3,(a0)+       ;
                  add.w #16,d3          ;next offset
                  dbra  d0,i_long_l     ;next long
;                  add.w #160,d3         ;
                  dbra  d1,i_long_l_l   ; next line
                  move.w #$4e75,(a0)+   ;code rts
                  rts
                ENDPART

light_s:        >PART 'light source'

;a0 pointer to p1
;a1 pointer to p2
;a2 pointer to p3
                  move.w (a0),d0
                  sub.w (a1),d0         ;ax
                  move.w (a0),d1
                  sub.w (a2),d1         ;bx

                  move.w 2(a0),d2
                  sub.w 2(a1),d2        ;ay
                  move.w 2(a0),d3
                  sub.w 2(a2),d3        ;by

                  move.w 4(a0),d4
                  sub.w 4(a1),d4        ;az
                  move.w 4(a0),d5
                  sub.w 4(a2),d5        ;bz

                  move.w d2,d6          ;ay*bz
                  muls  d5,d6           ;
                  move.w d4,d7          ;az*by
                  muls  d3,d7           ;
                  sub.l d7,d6           ;xn

                  muls  d1,d4           ;bx*az
                  muls  d0,d5           ;ax*bz
                  sub.l d5,d4           ;yn

                  muls  d3,d0           ;by*ax
                  muls  d2,d1           ;ay*bx
                  sub.l d1,d0           ;zn

                  move.l d0,d7          ;save zn
                  asl.l #8,d7           ;

                  moveq #8,d5           ;

;                  asr.l d5,d6           ;
;                  asr.l d5,d4           ;
;                  asr.l d5,d0           ;

                  muls  d6,d6           ;xn^2
                  muls  d4,d4           ;yn^2
                  muls  d0,d0           ;zn^2

                  add.l d6,d0           ;
                  add.l d4,d0           ;l^2

                  bsr.s sq_root         ;sqr(l^2)
                  divs  d0,d7           ;
                  move.w d7,d0          ;
                  rts
                ENDPART
sq_root:        >PART 'long square'

*************************************************************************
*                                                                       *
*  Integer Square Root (32 to 16 bit).                                  *
*                                                                       *
*  (Exact method, not approximate).                                     *
*                                                                       *
*  Call with:                                                           *
*    DO.L = Unsigned number.                                            *
*                                                                       *
*  Returns:                                                             *
*    DO.L = SQRT(DO.L)                                                  *
*                                                                       *
*  Notes:  Result fits in DO.W, but is valid in longword.               *
*    Takes from 122 to 1272 cycles (including rts).                     *
*    Averages 610 cycles measured over first 65535 roots.               *
*    Averages 1104 cycles measured over first 500000 roots.             *
*                                                                       *
*************************************************************************

*                                            Cycles
lsqrt:            tst.l d0              ;(4)    ; Skip doing zero.
                  beq.s done            ;(10/8) ;
                  cmp.l #$010000,d0     ;(14)   ; If is a longword, use the long routine.
                  bhs.s glsqrt          ;(10/8) ;
                  cmp.w #625,d0         ;(8)    ; Would the short word routine be quicker?
                  bhi.s gsqrt           ;(10/8) ; No, use general purpose word routine.

*                                           ; Otherwise fall into special routine.
*
* For speed, we use three exit points.
* This is cheesy, but this is a speed-optimized subroutine!

*************************************************************************
*                                                                       *
*  Faster Integer Square Root (16 to 8 bit).  For small arguments.      *
*                                                                       *
*  (Exact method, not approximate).                                     *
*                                                                       *
*  Call with:                                                           *
*    DO.W = Unsigned number.                                            *
*                                                                       *
*  Returns:                                                             *
*    DO.W = SQRT(DO.W)                                                  *
*                                                                       *
*  Notes:  Result fits in DO.B, but is valid in word.                   *
*    Takes from 72 (d0=1) to 504 (d0=625) cycles                        *
*    (including rts).                                                   *
*                                                                       *
*  Algorithm supplied by Motorola.                                      *
*                                                                       *
*************************************************************************

* Use the theorem that a perfect square is the sum of the first
* sqrt(arg) number of odd integers.

*                                            Cycles
                  move.w d1,-(sp)       ;(8)
                  move.w #-1,d1         ;(8)
qsqrt1:           addq.w #2,d1          ;(4)
                  sub.w d1,d0           ;(4)
                  bpl.s qsqrt1          ;(10/8)
                  asr.w #1,d1           ;(8)
                  move.w d1,d0          ;(4)
                  move.w (sp)+,d1       ;(12)
done:             rts                   ;(16)

*************************************************************************
*                                                                       *
*  Integer Square Root (16 to 8 bit).                                   *
*                                                                       *
*  (Exact method, not approximate).                                     *
*                                                                       *
*  Call with:                                                           *
*    DO.W = Unsigned number.                                            *
*                                                                       *
*  Returns:                                                             *
*    DO.L = SQRT(DO.W)                                                  *
*                                                                       *
*  Uses:  D1-D4 as temporaries --                                       *
*    D1 = Error term;                                                   *
*    D2 = Running estimate;                                             *
*    D3 = High bracket;                                                 *
*    D4 = Loop counter                                                  *
*                                                                       *
*  Notes: Result fits in DO.B, but is valid in word.                    *
*                                                                       *
*    Takes from 512 to 592 cycles (including rts).                      *
*                                                                       *
*    Instruction times for branch-type instructions                     *
*    listed as (X/Y) are for (taken/not taken).                         *
*                                                                       *
*************************************************************************

*                                            Cycles
gsqrt:            movem.w d1-d4,-(sp)   ;(24)
                  move.w #7,d4          ;(8)    ; Loop count (bits-1 of result).
                  clr.w d1              ;(4)    ; Error term in D1.
                  clr.w d2              ;(4)
sqrt1:            add.w d0,d0           ;(4)    ; Get 2 leading bits a time and add
                  addx.w d1,d1          ;(4)    ; into Error term for interpolation.
                  add.w d0,d0           ;(4)    ; (Classical method, easy in binary).
                  addx.w d1,d1          ;(4)
                  add.w d2,d2           ;(4)    ; Running estimate * 2.
                  move.w d2,d3          ;(4)
                  add.w d3,d3           ;(4)
                  cmp.w d3,d1           ;(4)
                  bls.s sqrt2           ;(10/8) ; New Error term > 2* Running estimate?
                  addq.w #1,d2          ;(4)    ; Yes, we want a `1' bit then.
                  addq.w #1,d3          ;(4)    ; Fix up new Error term.
                  sub.w d3,d1           ;(4)
sqrt2:            dbra  d4,sqrt1        ;(10/14); Do all 8 bit-pairs.
                  move.w d2,d0          ;(4)
                  movem.w (sp)+,d1-d4   ;(28)
                  rts                   ;(16)

*************************************************************************
*                                                                       *
*    Integer Square Root (32 to 16 bit).                                *
*                                                                       *
*  (Exact Method, not approximate).                                     *
*                                                                       *
*  Call with:                                                           *
*    DO.L = Unsigned number.                                            *
*                                                                       *
*  Returns:                                                             *
*    DO.L = SQRT(DO.L)                                                  *
*                                                                       *
*  Uses:  D1-D4 as temporaries --                                       *
*    D1 = Error term;                                                   *
*    D2 = Running estimate;                                             *
*    D3 = High bracket;                                                 *
*    D4 = Loop counter.                                                 *
*                                                                       *
*  Notes:  Result fits in DO.W, but is valid in longword.               *
*                                                                       *
*    Takes from 1080 to 1236 cycles (including rts.)                    *
*                                                                       *
*    Two of the 16 passes are unrolled from the loop so that            *
*    quicker instructions may be used where there is no                 *
*    danger of overflow (in the early passes).                          *
*                                                                       *
*    Instruction times for branch-type instructions                     *
*    listed as (X/Y) are for (taken/not taken).                         *
*                                                                       *
*************************************************************************

*                                            Cycles
glsqrt:           movem.l d1-d4,-(sp)   ;(40)
                  moveq #13,d4          ;(4)     ; Loop count (bits-1 of result).
                  moveq #0,d1           ;(4)     ; Error term in D1.
                  moveq #0,d2           ;(4)
lsqrt1:           add.l d0,d0           ;(8)     ; Get 2 leading bits a time and add
                  addx.w d1,d1          ;(4)     ; into Error term for interpolation.
                  add.l d0,d0           ;(8)     ; (Classical method, easy in binary).
                  addx.w d1,d1          ;(4)
                  add.w d2,d2           ;(4)     ; Running estimate * 2.
                  move.w d2,d3          ;(4)
                  add.w d3,d3           ;(4)
                  cmp.w d3,d1           ;(4)
                  bls.s lsqrt2          ;(10/8)  ; New Error term > 2* Running estimate?
                  addq.w #1,d2          ;(4)     ; Yes, we want a `1' bit then.
                  addq.w #1,d3          ;(4)     ; Fix up new Error term.
                  sub.w d3,d1           ;(4)
lsqrt2:           dbra  d4,lsqrt1       ;(10/14) ; Do first 14 bit-pairs.

                  add.l d0,d0           ;(8)     ; Do 15-th bit-pair.
                  addx.w d1,d1          ;(4)
                  add.l d0,d0           ;(8)
                  addx.l d1,d1          ;(8)
                  add.w d2,d2           ;(4)
                  move.l d2,d3          ;(4)
                  add.w d3,d3           ;(4)
                  cmp.l d3,d1           ;(6)
                  bls.s lsqrt3          ;(10/8)
                  addq.w #1,d2          ;(4)
                  addq.w #1,d3          ;(4)
                  sub.l d3,d1           ;(8)

lsqrt3:           add.l d0,d0           ;(8)     ; Do 16-th bit-pair.
                  addx.l d1,d1          ;(8)
                  add.l d0,d0           ;(8)
                  addx.l d1,d1          ;(8)
                  add.w d2,d2           ;(4)
                  move.l d2,d3          ;(4)
                  add.l d3,d3           ;(8)
                  cmp.l d3,d1           ;(6)
                  bls.s lsqrt4          ;(10/8)
                  addq.w #1,d2          ;(4)
lsqrt4:           move.w d2,d0          ;(4)
                  movem.l (sp)+,d1-d4   ;(44)
                  rts                   ;(16)

                ENDPART
gr_fader:       >PART 'gradient fader'

;d0 gradient number (0..15)

;a0 old pallete
;a1 result new palette

                  lea   fade_tab,a2
                  lea   256(a2),a3
                  lea   256(a3),a4
                  add.w d0,d0
                  adda.w d0,a2
                  adda.w d0,a3
                  adda.w d0,a4
                  move.w #%111100000,d4

                REPT 16
                  move.w (a0)+,d1       ;8
                  move.w d1,d0          ;4
                  lsl.w #5,d0           ;16
                  and.w d4,d0           ;4
                  move.w d1,d2          ;4
                  lsr.w #3,d2           ;12
                  and.w d4,d2           ;4
                  add.w d1,d1           ;4
                  and.w d4,d1           ;4
                  move.w 0(a2,d0.w),d0  ;14
                  add.w 0(a3,d1.w),d0   ;16
                  add.w 0(a4,d2.w),d0   ;16
                  move.w d0,(a1)+       ;8
                ENDR            ;total= ;114
                  rts                   ;1824 => 4 scanlines
                ENDPART

* BUFFERING ROUTINES

init_buffer:    >PART 'init object scan buffers'
                  lea   buffer_data(pc),a0
                  move.w (a0)+,d1
                  bra.s init_buffer_l2
init_buffer_l:    movem.l (a0)+,a1
                  movem.l (a1)+,a2-a4
                  movea.l a1,a5
                  suba.w (a1)+,a4
                  move.l a4,-(a5)
                  move.l a3,(a2)+
                  move.l a3,(a2)+
                  clr.w (a2)+
init_buffer_l2:   dbra  d1,init_buffer_l
                  rts
                ENDPART
loop_buffer:    >PART 'test buffer loop'

*USING:

* a4 pointer to RECORD(buf)
* a5 new actual pointer

                  movea.l (a4)+,a6      ;fetch pointer to RECORD(buf_dat)
                  cmpa.l 4(a4),a5       ;if end of buffer
                  bgt.s loop_buffer_2   ;jump
                  movea.l (a6),a4       ;fetch old actual pointer
                  move.l a5,(a4)        ;store new actual pointer in old record
                  move.l a5,(a6)        ;store new actual pointer
                  rts
loop_buffer_2:
                  move.l 4(a6),d0       ;fetch current pointer
                  cmp.l (a4),d0         ;
                  bne.s loop_buffer_3   ;
                  move.w #1,8(a6)       ;store buffer looped flag is SET
loop_buffer_3:    movea.l (a6),a5       ;fetch old actual pointer
                  move.l (a4),(a5)      ;copy start in old record
                  move.l (a4),(a6)      ;copy start of buffer to new actual
                  rts
                ENDPART
buffer_obj:     >PART 'buffer an object scan'
                  lea   buffer_data(pc),a0 ;pointer to buffer data
                  move.w (a0)+,d0       ;fetch number of RECORD(buf)
                  bra.s check_buffer_l3

check_buffer_l:   movea.l (a0)+,a6      ;fetch pointer to RECORD(buf)
                  movem.l (a6)+,a1/a4-a5 ;fetch pointers
                  move.w (a6)+,d1       ;fetch max record lenght
* Begin region
                  movem.l (a1)+,a2-a3   ;allows no interrupt  (Inner region)
* End region
                  tst.w (a1)            ;test for buffer loop
                  bne.s buf_reset       ;
                  cmpa.l a3,a2          ;if actual=>current
                  bge.s check_buffer_l2 ;next
                  adda.w d1,a2          ;
                  cmpa.l a3,a2          ;if actual=>current

                  blt.s check_buffer_l3 ;
                  bra   buffer_obj_e    ;

check_buffer_l2:  suba.l a2,a5          ;d1=end-actual
                  suba.l a4,a3          ;d2=current-start
                  adda.l a5,a3          ;d1+d2-max_record>0  *
                  cmpa.w d1,a3          ;
                  bgt.s check_buffer_l3 ;
                  bra   buffer_obj_e    ;

buf_reset:        adda.w d1,a2          ;
                  cmpa.l a3,a2          ;
                  bge   buffer_obj_e    ;
                  clr.w (a1)            ;buffer loop succesfull

check_buffer_l3:  dbra  d0,check_buffer_l ;next buf_dat

;
                  tst.l current_obj     ;if not NIL object
                  bne.s no_nil_obj

                  lea   buffer_data+2(pc),a0 ;pointer to buffer data
                  movem.l (a0),a1-a3/a5 ;fetch pointer to Obj_scan
                  movea.l (a1),a1       ;fetch next Obj_scan
                  movea.l (a1),a1       ;
                  movea.l (a2),a2
                  movea.l (a2),a2
                  movea.l (a3),a3
                  movea.l (a3),a3
                  movea.l (a5),a5
                  movea.l (a5),a5
                  addq.l #4,a1          ;make room for linked list pointer
                  addq.l #4,a2
                  addq.l #4,a3
                  addq.l #4,a5
                  clr.l (a1)+           ;store NIL pointer
                  bra.s buffer_obj_a    ;

no_nil_obj:       bsr   animate         ;
                  bsr   calc_all        ;

                  lea   buffer_data+2(pc),a0 ;pointer to buffer data
                  movem.l (a0)+,a1-a4   ;fetch Obj_scan,P_done,Scan_pl
                  movea.l (a1),a1
                  movea.l (a1),a1
                  movea.l (a2),a2
                  movea.l (a2),a2
                  movea.l (a3),a3
                  movea.l (a3),a3
                  movea.l (a4),a4
                  movea.l (a4),a4

                  addq.l #4,a1          ;make room for linked list pointer
                  addq.l #4,a2
                  addq.l #4,a3
                  addq.l #4,a4

                  move.l a4,-(sp)
;
                  lea   parameters(pc),a6
                  movea.l current_obj(pc),a0

                  bsr   calc_object
;
                  movea.l (sp)+,a5
                  movea.l current_obj(pc),a0
                  adda.w 2(a0),a0

                  movem.l a1-a3,-(sp)
                  jsr   (a0)
                  movem.l (sp)+,a1-a3

                  lea   buffer_data+2(pc),a0
buffer_obj_a:     movea.l 12(a0),a4
                  bsr   loop_buffer
                  movea.l (a0)+,a4
                  movea.l a1,a5
                  bsr   loop_buffer
                  movea.l (a0)+,a4
                  movea.l a2,a5
                  bsr   loop_buffer
                  movea.l (a0)+,a4
                  movea.l a3,a5
                  bsr   loop_buffer
                  moveq #0,d0           ;buffering succesfull
                  rts

buffer_obj_e:
                  moveq #1,d0           ;not succesfull
                  rts

                ENDPART
update_p:       >PART 'update pointers realtime'

                  lea   buffer_data+2(pc),a1
                  movem.l (a1)+,a0/a2-a4

                  movea.l (a0),a0
                  lea   4(a0),a6
                  movea.l (a6),a0
                  move.l (a0)+,(a6)
;
                  movea.l (a2),a2
                  lea   4(a2),a6
                  movea.l (a6),a2
                  move.l (a2)+,(a6)
;
                  movea.l (a3),a3
                  lea   4(a3),a6
                  movea.l (a6),a3
                  move.l (a3)+,(a6)
;
                  movea.l (a4),a4
                  lea   4(a4),a6
                  movea.l (a6),a4
                  move.l (a4)+,(a6)

                  movea.l a4,a1
                  rts
totally_wrong:    illegal
                  rts
                ENDPART

* ANIMATION ROUTINES

init_anim:      >PART 'init animation routines'
                  move.l #trap_15,$bc.w
                  rts
                ENDPART
trap_15:        >PART 'animation dispatcher'
                  move  (sp),sr         ;init original sr
                  move.w d0,-(sp)       ;stack
                  move.l a0,-(sp)       ;
                  move.w 12(sp),d0      ;fetch routine number
                  subq.w #1,d0          ;-1
                  add.w d0,d0           ;index routine
                  add.w d0,d0           ;
                  lea   anim_point(pc),a0 ;
                  move.l 0(a0,d0.w),space_1 ;store routine pointer
                  movea.l (sp)+,a0      ;unstack
                  move.w (sp)+,d0       ;
                  pea   trap_15_e(pc)   ;return address
                  move.l space_1(pc),-(sp) ;stack routine
                  rts                   ;jump to routine
trap_15_e:        rte
                ENDPART
animation:      >PART 'different animation routs'

initx:            move.w d0,x_co
                  rts
inity:            move.w d0,y_co
                  rts
initz:            move.w d0,z_co
                  rts
addx:             add.w d0,x_co
                  rts
addy:             add.w d0,y_co
                  rts
addz:             add.w d0,z_co
                  rts
initrotx:         move.w d0,rot_x
                  rts
initroty:         move.w d0,rot_y
                  rts
initrotz:         move.w d0,rot_z
                  rts
add_rotx:         move.w d0,add_x
                  rts
add_roty:         move.w d0,add_y
                  rts
add_rotz:         move.w d0,add_z
                  rts
sinx:             move.l a0,-(sp)
                  and.w #(period-1)*4,d0
                  lea   sin_cos_tab,a0
                  move.l 0(a0,d0.w),d0
                  swap  d0
                  movea.l (sp)+,a0
                  rts
cosx:             move.l a0,-(sp)
                  and.w #(period-1)*4,d0
                  lea   sin_cos_tab,a0
                  move.l 0(a0,d0.w),d0
                  movea.l (sp)+,a0
                  rts
initcount:        move.l a1,routine
                  move.w d0,count
                  rts
subcount:         movea.l routine(pc),a0
                  jsr   (a0)
                  subq.w #1,count

                  move.w count(pc),d0
                  rts

init_seq:         adda.l current_obj,a0
init_seq_1:       move.w (a0)+,d0
                  bmi.s init_seq_3
                  beq.s init_seq_2
                  movea.w (a0)+,a1
                  move.l a0,seq_p
                  adda.l current_obj,a1
                  bsr.s initcount
                  rts
init_seq_2:       movea.w (a0)+,a2
                  move.l current_obj(pc),d1
                  adda.l d1,a2
                  move.l a0,seq_p
                  jsr   (a2)
                  movea.l seq_p(pc),a0
                  bra.s init_seq_1
init_seq_3:       move.w #1,main_flag
                  rts

do_seq:           bsr.s subcount
                  tst.w d0
                  bne.s do_seq_e
                  movea.l seq_p(pc),a0
                  bra.s init_seq_1
do_seq_e:         rts

xco:              move.w x_co(pc),d0
                  rts
yco:              move.w y_co(pc),d0
                  rts
zco:              move.w z_co(pc),d0
                  rts
xrot:             move.w rot_x(pc),d0
                  rts
yrot:             move.w rot_y(pc),d0
                  rts
zrot:             move.w rot_z(pc),d0
                  rts
addrotx:          move.w add_x(pc),d0
                  rts
addroty:          move.w add_y(pc),d0
                  rts
addrotz:          move.w add_z(pc),d0
                  rts
add_add_x:        add.w d0,add_x
                  rts
add_add_y:        add.w d0,add_y
                  rts
add_add_z:        add.w d0,add_z
                  rts

scan_obj:         bsr   scan_border     ;scan border
                  rts
scan_lin:         bsr   scan_b_lin
                  rts

make_bor_pol:     bsr   creat_pl        ;create border polygon
                  rts
clear_bor_fl:     bsr   clear_flags
                  rts

fetch_m:          lea   matrix(pc),a0
                  movem.w (a0),d0-a0
                  muls  #31500,d1
                  muls  #31500,d4
                  muls  #31500,d7
                  swap  d1
                  swap  d4
                  swap  d7
                  add.l d1,d1
                  add.l d4,d4
                  add.l d7,d7
                  exg   d0,d4
                  exg   d2,d7
                  exg   d5,d6
                  rts

                ENDPART

* CLEAR ROUTINES

clear_it:       >PART 'clear according to coordinates'

*USING:

;d0=x-min
;d1=x-max
;d2=y-min
;d3=y-max
                  move.w add_c2(pc),d4  ;
                  sub.w d4,d0           ;
                  sub.w d4,d1           ;
                  move.l sp,clear_sp    ;store stack pointer
                  movea.l screen1,sp    ;fetch screen address
                  lsr.w #1,d0           ;calc word offset left x
                  moveq #%11111000,d4   ;init mask
                  and.b d4,d0           ;
                  lsr.w #1,d1           ;calc word offset right x
                  and.b d4,d1           ;
                  sub.w d1,d0           ;calc lenght in screen words
                  neg.w d0              ;
                  bmi.s clear_end_it    ;
                  lsr.w #1,d0           ;/2 for index
                  lea   clear_look_up,a0 ;
                  movea.l 0(a0,d0.w),a0 ;fetch routine pointer
                  lsr.w #1,d0           ;/2 for index
                  lea   clear_look_len,a1 ;
                  adda.w d0,a1          ;index to routine lenght
                  adda.w d1,sp          ;add right word screen offset
                  add.w #199,d2         ;calc 199-(diff)
                  sub.w d3,d2           ;
                  lea   mul_160,a4      ;
                  add.w d3,d3           ;
                  adda.w d3,a4          ;
                  move.w (a4),d3        ;calc start y-line on screen
                  muls  (a1)+,d2        ;calc jump offset
                  lea   8(sp,d3.w),sp   ;add y offset
                  adda.w d2,a0          ;add jump offset
                  move.l a0,clear_end_j+2 ;jump address
                  move.w clear_pat(pc),d0 ;init clear pat
                  move.w d0,d1          ;
                  swap  d0              ;
                  move.w d1,d0
                  move.l d0,d1
                  move.l d0,d2
                  move.l d0,d3
                  move.l d0,d4
                  move.l d0,d5
                  move.l d0,d6
                  move.l d0,d7
                  movea.l d0,a0
                  movea.l d0,a1
                  movea.l d0,a2
                  movea.l d0,a3
                  movea.l d0,a4
                  movea.l d0,a5
                  movea.l d0,a6
clear_end_j:      jmp   0               ;jump to routine
clear_end_it:     movea.l clear_sp,sp   ;restore stack
                  rts

                ENDPART
code_clr_routs: >PART 'code clear routines'
                  lea   dif_clear_code,a0
                  lea   clear_look_up,a2
                  lea   differ_clr(pc),a3
                  lea   clear_look_len,a5
                  lea   clear_end_it(pc),a6
                  moveq #20-1,d7
code_clr_r_l1:    move.w #200-1,d6
                  move.w (a3)+,(a5)+
                  move.l a0,(a2)+
                  movea.l (a3)+,a4
                  move.w #-199*160,d0
code_clr_r_l2:    jsr   (a4)
                  add.w #160,d0
                  dbra  d6,code_clr_r_l2
                  move.w #$4ef9,(a0)+
                  move.l a6,(a0)+
                  dbra  d7,code_clr_r_l1
                  rts
                ENDPART
clear_r:        >PART 'various lenght clear routs'

one:              movem.l d0-d1,-8(sp)  ;28
one_code:         lea   one(pc),a1
                  bsr   code_one_move
                  rts

two:              movem.l d0-d3,-16(sp) ;12+8*4=44
two_code:         lea   two(pc),a1
                  bsr   code_one_move
                  rts

three:            movem.l d0-d5,-24(sp) ;12+8*6=60
three_code:       lea   three(pc),a1
                  bsr   code_one_move
                  rts

four:             movem.l d0-d7,-32(sp) ;12+8*8=76
four_code:        lea   four(pc),a1
                  bsr   code_one_move
                  rts

five:             movem.l d0-a1,-40(sp) ;12+10*8=92
five_code:        lea   five(pc),a1
                  bsr   code_one_move
                  rts

six:              movem.l d0-a3,-48(sp) ;12+12*8=108
six_code:         lea   six(pc),a1
                  bsr   code_one_move
                  rts

seven:            movem.l d0-a5,-56(sp) ;12+14*8=124
seven_code:       lea   seven(pc),a1
                  bsr   code_one_move
                  rts

eight:            movem.l d0-a6,-64(sp) ;12+15*8=132
                  move.l d0,-4(sp)      ;16
;total 148
eight_code:       lea   eight(pc),a1
                  bsr   code_one_move
                  move.l (a1)+,d1       ;special case
                  add.w d0,d1
                  move.l d1,(a0)+
                  rts

nine:             movem.l d0-a6,-(sp)   ;8+15*8=128
                  movem.l d0-d2,-(sp)   ;32
                  lea   -160+9*8(sp),sp ;8
;total 168
nine_code:
                  lea   nine(pc),a1
                  moveq #6,d1
                  bsr   code_other_move
                  rts


ten:              movem.l d0-a6,-(sp)   ;128
                  movem.l d0-d4,-(sp)   ;48
                  lea   -160+10*8(sp),sp ;8
;total 184
ten_code:
                  lea   ten(pc),a1
                  moveq #6,d1
                  bsr   code_other_move
                  rts

eleven:           movem.l d0-a6,-(sp)   ;128
                  movem.l d0-d6,-(sp)   ;64
                  lea   -160+11*8(sp),sp ;8
;total 200
eleven_code:
                  lea   eleven(pc),a1
                  moveq #6,d1
                  bsr   code_other_move
                  rts

twelve:           movem.l d0-a6,-(sp)   ;128
                  movem.l d0-a0,-(sp)   ;80
                  lea   -160+12*8(sp),sp ;8
;total 216
twelve_code:
                  lea   twelve(pc),a1
                  moveq #6,d1
                  bsr   code_other_move
                  rts

thirteen:         movem.l d0-a6,-(sp)   ;128
                  movem.l d0-a2,-(sp)   ;96
                  lea   -160+13*8(sp),sp ;8
;total 232
thirteen_code:
                  lea   thirteen(pc),a1
                  moveq #6,d1
                  bsr   code_other_move
                  rts

fourteen:         movem.l d0-a6,-(sp)   ;128
                  movem.l d0-a4,-(sp)   ;112
                  lea   -160+14*8(sp),sp ;8
;total 248
fourteen_code:
                  lea   fourteen(pc),a1
                  moveq #6,d1
                  bsr   code_other_move
                  rts

fifteen:          movem.l d0-a6,-(sp)   ;128
                  movem.l d0-a6,-(sp)   ;128
                  lea   -160+15*8(sp),sp ;8
;total 272
fifteen_code:
                  lea   fifteen(pc),a1
                  moveq #6,d1
                  bsr   code_other_move
                  rts

sixteen:          movem.l d0-a6,-(sp)   ;128
                  movem.l d0-a6,-(sp)   ;128
                  move.l d0,-(sp)       ;12
                  move.l d0,-(sp)       ;12
                  lea   -160+16*8(sp),sp ;8
;total 288
sixteen_code:
                  lea   sixteen(pc),a1
                  moveq #8,d1
                  bsr.s code_other_move
                  rts

seventeen:        movem.l d0-a6,-(sp)   ;128
                  movem.l d0-a6,-(sp)   ;128
                  movem.l d0-d3,-(sp)   ;40
                  lea   -160+17*8(sp),sp ;8
;total 304
seventeen_code:
                  lea   seventeen(pc),a1
                  moveq #8,d1
                  bsr.s code_other_move
                  rts

eighteen:         movem.l d0-a6,-(sp)   ;128
                  movem.l d0-a6,-(sp)   ;128
                  movem.l d0-d5,-(sp)   ;56
                  lea   -160+18*8(sp),sp ;8
;total 320
eighteen_code:
                  lea   eighteen(pc),a1
                  moveq #8,d1
                  bsr.s code_other_move
                  rts

nineteen:         movem.l d0-a6,-(sp)   ;128
                  movem.l d0-a6,-(sp)   ;128
                  movem.l d0-d7,-(sp)   ;72
                  lea   -160+19*8(sp),sp ;8
;total 336
nineteen_code:
                  lea   nineteen(pc),a1
                  moveq #8,d1
                  bsr.s code_other_move
                  rts

twenty:           movem.l d0-a6,-(sp)   ;128
                  movem.l d0-a6,-(sp)   ;128
                  movem.l d0-a1,-(sp)   ;88
;total 344

twenty_code:
                  lea   twenty(pc),a1
                  moveq #6,d1
                  bsr.s code_other_move
                  rts

                ENDPART
code_one_move:  >PART 'code one movem.l rout'

*USING:

*d0 additional offset
*a0 destination code
*a1 source code

*RETURNING:

*specified code to space pointed by a1


                  move.l (a1)+,(a0)+    ;copy instruction format
                  move.w (a1)+,d1       ;copy instruction offset
                  add.w d0,d1           ;add offsets
                  move.w d1,(a0)+       ;copy to memory
                  rts

                ENDPART
code_other_move:>PART 'code x number of instructions'

*USING:

*d1 number of words to copy
*a0 destination code
*a1 source code

*RETURNING:

*specified code to space pointed by a1


                  subq.w #1,d1
copy_move_l:      move.w (a1)+,(a0)+
                  dbra  d1,copy_move_l
                  rts
                ENDPART
i_multi_cl:     >PART 'init multi clear parameters'
                  lea   multi_clear(pc),a0
                  move.l a0,multi_p
                  clr.w multi_p_c
                  rts
                ENDPART
multi_clr:      >PART 'multi clear'
                  move  #$0300,sr
                  lea   multi_clear_b(pc),a0
                  move.w (a0)+,d4
                  bra.s multi_clr_l2
multi_clr_l1:     movem.w (a0)+,d0-d3
                  move.l a0,-(sp)
                  move.w d4,-(sp)
                  bsr   clear_it
                  move.w (sp)+,d4
                  movea.l (sp)+,a0
multi_clr_l2:     dbra  d4,multi_clr_l1
                  trap  #0
                  rts
                ENDPART
multi_clr_c:    >PART 'copy multi clear parameters'
                  lea   multi_clear(pc),a0
                  lea   multi_clear_b(pc),a1
                  move.w multi_p_c(pc),d0
                  move.w d0,(a1)+
                  bra.s multi_clr_c_l2
multi_clr_c_l1:   movem.l (a0)+,d1-d2
                  move.l d1,(a1)+
                  move.l d2,(a1)+
multi_clr_c_l2:   dbra  d0,multi_clr_c_l1
                  rts
                ENDPART

                DATA

                >PART 'screen'

eat_c1          EQU $0667
eat_c2          EQU $0445
eat_c3          EQU $03

eat_pal:        DC.W $0777
                DC.W $0776
                DC.W $0767
                DC.W $0677
                DC.W eat_c1
                DC.W eat_c1
                DC.W eat_c1
                DC.W eat_c1
                DC.W eat_c2
                DC.W eat_c2
                DC.W eat_c2
                DC.W eat_c2
                DC.W eat_c3
                DC.W eat_c3
                DC.W eat_c3
                DC.W eat_c3

                ENDPART

                >PART 'init routines data'

init_rout:      DC.L init_and
                DC.L init_word_and
                DC.L init_long
                DC.L init_word_or
                DC.L init_or

                ENDPART
                >PART 'mask data'

left_mask:      DC.W %1111111111111111
                DC.W %111111111111111
                DC.W %11111111111111
                DC.W %1111111111111
                DC.W %111111111111
                DC.W %11111111111
                DC.W %1111111111
                DC.W %111111111
                DC.W %11111111
                DC.W %1111111
                DC.W %111111
                DC.W %11111
                DC.W %1111
                DC.W %111
                DC.W %11
                DC.W %1

right_mask:     DC.W %1000000000000000
                DC.W %1100000000000000
                DC.W %1110000000000000
                DC.W %1111000000000000
                DC.W %1111100000000000
                DC.W %1111110000000000
                DC.W %1111111000000000
                DC.W %1111111100000000
                DC.W %1111111110000000
                DC.W %1111111111000000
                DC.W %1111111111100000
                DC.W %1111111111110000
                DC.W %1111111111111000
                DC.W %1111111111111100
                DC.W %1111111111111110
                DC.W %1111111111111111

                ENDPART
                >PART 'precode polygon data'


right_len_nor   EQU (e_right_nor-s_right_nor)/2
right_len_rev   EQU (e_right_rev-s_right_rev)/2
left_len        EQU (e_left-s_left)/2
set_len         EQU (e_set-s_set)/2
clear_len       EQU (e_clr-s_clr)/2
long_len        EQU (e_long-s_long)/2
poly_len        EQU (e_poly-s_poly)/2
jump_off        EQU max_code*200

                ENDPART
                >PART 'files from disk'


sin_cos_tab     EQU fade_tab+768
rip_tab:                                ;  IBYTES 'RIP3_TAB'


obj             EQU sin_cos_tab+8192 ;  PATH 'A:\3D\OBJECTS\'

;                IBYTES 'CHEES.O'


                ENDPART
                >PART 'project data'

xyz_pointers:   DC.L x_coord+max_c*12,y_coord+max_c*12,z_coord+max_c*12

                ENDPART
                >PART 'scan angles'

scan_case:      DC.L scan_case_1
                DC.L scan_case_2
                DC.L scan_case_3
                DC.L scan_case_4
                DC.L scan_case_5
                DC.L scan_case_6
                DC.L scan_case_7
                DC.L scan_case_8
                DC.L scan_case_9
                DC.L scan_case_10

max_r           EQU 200

scan_case_1:      lea   add_x(pc),a0
                  move.w (a0),d0
                  addq.w #1,d0
                  cmp.w #max_r,d0
                  bgt.s scan_case_1_2
                  move.w d0,(a0)
scan_case_1_2:    rts
scan_case_2:      lea   add_x(pc),a0
                  move.w (a0),d0
                  subq.w #1,d0
                  cmp.w #-max_r,d0
                  blt.s scan_case_2_2
                  move.w d0,(a0)
scan_case_2_2:    rts

scan_case_3:      lea   add_y(pc),a0
                  move.w (a0),d0
                  addq.w #1,d0
                  cmp.w #max_r,d0
                  bgt.s scan_case_3_2
                  move.w d0,(a0)
scan_case_3_2:    rts
scan_case_4:      lea   add_y(pc),a0
                  move.w (a0),d0
                  subq.w #1,d0
                  cmp.w #-max_r,d0
                  blt.s scan_case_3_2
                  move.w d0,(a0)
scan_case_4_2:    rts

scan_case_5:      lea   add_z(pc),a0
                  move.w (a0),d0
                  addq.w #1,d0
                  cmp.w #max_r,d0
                  bgt.s scan_case_5_2
                  move.w d0,(a0)
scan_case_5_2:    rts
scan_case_6:      lea   add_z(pc),a0
                  move.w (a0),d0
                  subq.w #1,d0
                  cmp.w #-max_r,d0
                  blt.s scan_case_6_2
                  move.w d0,(a0)
scan_case_6_2:    rts

scan_case_7:      eori.w #1,ripple_flag
                  rts
scan_case_8:      clr.w add_x
                  clr.w add_y
                  clr.w add_z
                  rts
scan_case_9:      lea   z_co(pc),a0
                  move.w (a0),d0
                  add.w #2,d0
                  cmp.w #1800,d0
                  bge.s scan_case_9_2
                  move.w d0,(a0)
scan_case_9_2:    rts
scan_case_10:     lea   z_co(pc),a0
                  move.w (a0),d0
                  subq.w #2,d0
                  cmp.w #400,d0
                  blt.s scan_case_10_2
                  move.w d0,(a0)
scan_case_10_2:   rts

                ENDPART
                >PART 'realtime calculations'

buffer_data:    DC.W 4
                DC.L obj_buf
                DC.L scan_buf
                DC.L poly_buf
                DC.L pal_buf


                ENDPART
                >PART 'animation data'

anim_point:     DC.L initx      ;1
                DC.L inity      ;2
                DC.L initz      ;3
                DC.L addx       ;4
                DC.L addy       ;5
                DC.L addz       ;6
                DC.L initrotx   ;7
                DC.L initroty   ;8
                DC.L initrotz   ;9
                DC.L add_rotx   ;10
                DC.L add_roty   ;11
                DC.L add_rotz   ;12
                DC.L sinx       ;13
                DC.L cosx       ;14
                DC.L initcount  ;15
                DC.L subcount   ;16
                DC.L init_seq   ;17
                DC.L do_seq     ;18
                DC.L xco        ;19
                DC.L yco        ;20
                DC.L zco        ;21
                DC.L xrot       ;22
                DC.L yrot       ;23
                DC.L zrot       ;24
                DC.L addrotx    ;25
                DC.L addroty    ;26
                DC.L addrotz    ;27
                DC.L add_add_x  ;28
                DC.L add_add_y  ;29
                DC.L add_add_z  ;30
                DC.L scan_obj   ;31
                DC.L scan_lin   ;32
                DC.L make_bor_pol ;33
                DC.L clear_bor_fl ;34
                DC.L fetch_m    ;35

                ENDPART
                >PART 'clear routines data'

differ_clr:
                DC.W 6
                DC.L one_code
                DC.W 6
                DC.L two_code
                DC.W 6
                DC.L three_code
                DC.W 6
                DC.L four_code
                DC.W 6
                DC.L five_code
                DC.W 6
                DC.L six_code
                DC.W 6
                DC.L seven_code
                DC.W 10
                DC.L eight_code
                DC.W 12
                DC.L nine_code
                DC.W 12
                DC.L ten_code
                DC.W 12
                DC.L eleven_code
                DC.W 12
                DC.L twelve_code
                DC.W 12
                DC.L thirteen_code
                DC.W 12
                DC.L fourteen_code
                DC.W 12
                DC.L fifteen_code
                DC.W 16
                DC.L sixteen_code
                DC.W 16
                DC.L seventeen_code
                DC.W 16
                DC.L eighteen_code
                DC.W 16
                DC.L nineteen_code
                DC.W 12
                DC.L twenty_code

;total of 12*8+12*16=352 words

                ENDPART
                >PART 'eor codes'
eor_t:

                  eor.b d0,0(a0)
                  eor.b d1,0(a0)
                  eor.b d2,0(a0)
                  eor.b d3,0(a0)
                  eor.b d4,0(a0)
                  eor.b d5,0(a0)
                  eor.b d6,0(a0)
                  eor.b d7,0(a0)

                ENDPART

                BSS

                >PART 'init'
mfp_store:      DS.B 38
screen_store:   DS.B 38
old_user:       DS.L 1
                DS.B 1024*2
stack:          DS.L 1
                DS.B 1024*2
user_stack:     DS.L 1
                DS.B 1024
                ENDPART
                >PART 'shit'
vbl_flag:       DS.W 1
                ENDPART

parameters:     >PART 'object/polygon globals'

p_xy:           DS.L 1          ;pointer to projected points
already:        DS.L 1          ;pointer to RECORD(Done_l)
line_flag:      DS.L 1          ;pointer to RECORD(Line_f)
y_steps:        DS.L 1          ;pointer to h-lines already calculated
record_space:   DS.L 1          ;pointer to space to store an RECORD

x_m:            DS.W 1          ;mid coordinates of screen
y_m:            DS.W 1          ;
s_x_min:        DS.W 1          ;max-min x,y
s_y_min:        DS.W 1          ;
s_x_max:        DS.W 1          ;
s_y_max:        DS.W 1          ;
squash_c:       DS.W 1          ;
poly_min:       DS.W 1          ;minimum y-coord of polygon
poly_max:       DS.W 1          ;maximum '                '

no_no_delta:    DS.W 1          ;number of polys which don't use delta routs
line_off:       DS.W 1          ;number of bytes to add a line
ripple_flag:    DS.W 1          ;ripple flag
ripple_p:       DS.L 1          ;pointer to ripple table

fill_pat:       DS.W 1          ;fill pattern
clear_pat:      DS.W 1          ;clear pattern
and_or:         DS.W 1          ;AND or OR flag
poly_flag:      DS.W 1          ;poly flag
clr_sp:         DS.W 4          ;space for x1,y1 x2,y2 clear block
space_1:        DS.L 1

multi_e_fl:     DS.W 1          ;end multi animation flag
add_c:          DS.W 1
add_c2:         DS.W 1

                ENDPART
                >PART 'animate bss'

multi_s:

current_obj:    DS.L 1

x_co:           DS.W 1          ;world coordinates of an object
y_co:           DS.W 1          ;
z_co:           DS.W 1          ;
rot_x:          DS.W 1          ;3d rotation angles
rot_y:          DS.W 1          ;
rot_z:          DS.W 1          ;
add_x:          DS.W 1          ;rotation add
add_y:          DS.W 1          ;
add_z:          DS.W 1          ;

main_flag:      DS.W 1
seq_p:          DS.L 1          ;current sequence pointer
count:          DS.W 1          ;sequence counter
routine:        DS.L 1          ;current sequence pointer

new_init:       DS.W 1

multi_e:
                ENDPART
                >PART 'multi buffer'

multi_point:    DS.L no_multi
multi_len       EQU multi_e-multi_s
multi_param:    DS.W multi_len*no_multi
multi_clear:    DS.W 4*no_multi
multi_clear_b:  DS.W 4*no_multi+1
multi_p:        DS.L 1
multi_p_c:      DS.W 1
cur_multi:      DS.W 1

cur_kwal:       DS.L 1
kwal_count:     DS.L 1

                ENDPART

***************************** TOTAL SEQUENCER BSS *****************************

                >PART 'total sequencer parameters'

go_do_it:       DS.W 1
exit:           DS.W 1
line_add:       DS.W 1
fade_gr:        DS.W 1
vbl_slots:      DS.L 10
idle:           DS.W 1
rast_mode:      DS.W 1
line_add2:      DS.W 1
fade_bor_c:     DS.W 1
no_obj_c:       DS.W 1
vbl_one_s:      DS.L 1

current_ev:     DS.L 1
actual_ev:      DS.L 1

main_seq_c:     DS.W 1
objects_p:      DS.L 1
main_seq_p:     DS.L 1
buffer_slot:    DS.L 1
cur_main_r:     DS.L 1
wait_v2:        DS.W 1


                ENDPART

                >PART 'palette bss'

new_buf:        DS.W 16+4       ;pal + clear parameters
new_buf2:       DS.W 16

                ENDPART
                >PART 'polygon buffers'

indexed_p:      DS.W max_p*3
clipped_p:      DS.W max_p*3
no_delta_buf:   DS.L 2+max_v

                ENDPART
                >PART 'object buffers'

line_done:      DS.L max_l*3+2  ;buffer of max_l lines
calc_done:      DS.B 10*max_l   ;'                   '
flag_buf:       DS.L max_l
border_flag:    DS.L max_l
unsort_lin:     DS.L max_l

                ENDPART
                >PART 'project buffers'

matrix:         DS.W 9          ;buffer of matrix elements
matrix2:        DS.W 9
x_coord:        DS.L max_c*2*3  ;buffer of max_c x,y,z coordinates
y_coord:        DS.L max_c*2*3  ;
z_coord:        DS.L max_c*2*3  ;
project_buf:    DS.L max_p      ;
origin_buf:     DS.L 3          ;
xyz_p:          DS.L max_c*4    ;
light_sp:       DS.W 3*3        ;


                ENDPART
                >PART 'tables'

frac_tab:       DS.L 200+1      ;201 1/y-fractions

                ENDPART
                >PART 'object space buffer'

old_obj_p:      DS.L 1
new_obj_p:      DS.L 1

obj1_space:     DS.W frame_size_1*no_screens*2+no_screens*4+1

                ENDPART
                >PART 'SUPER BSS'

super_off       EQU 65536

jump_total      EQU (642+clip_space*4)*2

super_b         EQU $0f0000-(256*1024)+comp_off


jump_normal1    EQU super_b
jump_normal2    EQU super_b+super_off

jump_revers1    EQU super_b+super_off*2
jump_revers2    EQU super_b+super_off*3


                ENDPART
                >PART 'lookup tables'

look_clear:     DS.B max_code*20
mul_160:        DS.W 200
mul_320:        DS.W 200
ripple_j_p:     DS.W 200+1
calc_x_jump:    DS.W 200+1
plane_case:     DS.L 4

                ENDPART
                >PART 'destination code'



norm_left       EQU super_b+jump_total
norm_right      EQU super_b+super_off+jump_total

kwal2           EQU norm_left
kwal3           EQU kwal2+1000
kwal4           EQU kwal3+1000

obj2_sp_s       EQU (frame_size_2*no_screens*2)+no_screens*4+1

rev_left        EQU super_b+super_off*2+jump_total
multi_space     EQU rev_left

rev_right       EQU super_b+super_off*3+jump_total

or_and_set:     DS.B 400*max_code+10

dif_clear_code:

rev_set:        DS.B 400*max_code+10
clear:          DS.B 400*max_code+12

                ENDPART
                >PART 'clear routine space'

clear_look_up:  DS.L 20
clear_look_len: DS.W 20

clear_sp:       DS.L 1

                ENDPART
                >PART 'line bss'


line_ad_2:      DS.L 320
x_line_bl:      DS.B 12*320+2
y_line_bl:      DS.B 12*200+2
find_eor_t:     DS.L 320
jump_l_x:       DS.W 320

                ENDPART
                >PART 'realtime calculations buffers'

** STUCTURE buf_dat

no_of_vbls:     DS.W 1

buf_dat:
actual_p:       DS.L 1
current_p:      DS.L 1
loop_flag:      DS.W 1
end_buf_dat:

buf_dat_len     EQU end_buf_dat-buf_dat

**

p1              EQU 13
q1              EQU 1

max_obj_add     EQU 2000*q1
max_poly_add    EQU 2000*q1
max_scan_add    EQU 1000*q1
max_pal_add     EQU 1000*q1

obj_buf_len1    EQU 7000*p1
poly_buf_len1   EQU 4000*p1
scan_buf_len1   EQU 5000*p1
palette_buf_len1 EQU 2000*p1



obj_buf:        DS.W 7
poly_buf:       DS.W 7
scan_buf:       DS.W 7
pal_buf:        DS.W 7

obj_buf_dat:    DS.B buf_dat_len
poly_buf_dat:   DS.B buf_dat_len
scan_buf_dat:   DS.B buf_dat_len
pal_buf_dat:    DS.B buf_dat_len

event_buf_s:    DS.W 2000
event_buf_e:
fade_bor:       DS.W 16

buffer1:        DS.B obj_buf_len1+poly_buf_len1+scan_buf_len1+palette_buf_len1

                ENDPART
                >PART 'rap tale bss'

rap_b1_c:       DS.B 80*60
rap_b2_c:       DS.B 80*60
rap_b1_a:       DS.B 80*60
rap_b2_a:       DS.B 80*60

raptale_buf:    DS.B 80*204

rap_b1_c_p:     DS.L 1
rap_b2_c_p:     DS.L 1
rap_b1_a_p:     DS.L 1
rap_b2_a_p:     DS.L 1
end_rap:        DS.W 1
rap_count:      DS.W 1
no_rapt:        DS.W 1
cur_rap_y:      DS.W 1
cur_rap_x:      DS.W 1
cur_rap_text:   DS.L 1

cur_rap_p:      DS.L 1
cur_rap_r:      DS.L 1
cur_rap_lin:    DS.L 1
rap_pars_p:     DS.L 1

rap_tale:       DS.L 16
point_rap:      DS.L 320
seed:           DS.L 1

do_text_c:      DS.W 1
do_text_fl:     DS.W 1
next_scr:       DS.W 1

                ENDPART
                >PART 'screens'

screen1:        DS.L 1
screen2:        DS.L 1


                ENDPART

                END
