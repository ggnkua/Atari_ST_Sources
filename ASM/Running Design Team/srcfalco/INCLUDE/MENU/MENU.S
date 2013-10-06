;***********************************************************
;***
;*** RUNNING-3D-ENGINE
;***
;*** (C) 1994-1996 BY TARZAN BOY 
;***
;***********************************************************


* Menu by MIG 1996


;**************************************
;* equ's
;**************************************

final           equ 	0
debug           equ 	0
debug_color     equ 	0

record_lauf	equ	0
play_lauf	equ	0

time_debug	equ	0

		include	"e:\running\include\const_02.s"

;**************************************
;**************************************
                

                TEXT

                pea     0
                move.w  #$0020,-(SP)
                trap    #1
                addq.l  #6,SP
                move.l  D0,old_stack

		bsr	MODULEdsp

		jsr	save_video_system

                jsr     init_stuff
                jsr     init_stuff_2

		bsr	mainmenu

                jsr     restore_system

                move.w  old_res,-(SP)
                move.w  #3,-(SP)
                move.l  old_screen,-(SP)
                move.l  old_screen,-(SP)
                move.w  #$0005,-(SP)
                trap    #$0E
                lea     $000E(SP),SP

out:            
		jsr	restore_video_system


                move.l  old_stack,-(SP)
                move.w  #$0020,-(SP)
                trap    #1
                addq.l  #6,SP

             
                clr.w   -(SP)
                trap    #1


****************************************

gear_phase	dc.w	0

episode_menu
		move.w	#0,gear_phase

		lea	FILEgear(pc),a0
		lea	fade_buffer_2,a1
		move.l	BYTESgear(pc),d0
		bsr	load

episode_loop
		rept	4
          	bsr	vsync
		endr

		* Symbol Animation

		move.w	gear_phase,d0
		addq.w	#1,d0
		and.w	#$f,d0
		move.w	d0,gear_phase
		
		move.l	screen_2,a0
		adda.l	#50*640+50,a0

		lea	fade_buffer_2+128,a1
		lsl.w	#5,d0		* 16 * 2 Pixel
		adda.w	d0,a1		

* Zeichnen
		move.w	#$ffff,d2
		move.w	#$0020,d3	* truepaint black is no black !
		move.w	#16-1,d0
scan_line	move.w	#16-1,d1	
scan_pixel	
		move.w	(a1)+,d4
		cmp.w	d3,d4
		bne.s	scan_it
		move.w	d2,d4
scan_it		move.w	d4,(a0)+
		
		dbra	d1,scan_pixel	
		lea	640-32(a0),a0
		lea	512-32(a1),a1
		dbra	d0,scan_line		

		bsr     swap_me
		neg.w	index

		tst.b	keytable+$1c
		beq.s	episode_loop

* menu ist fertig ...

		bsr	MODULEstop
		move.l	old_menu_vbl,$70.w
		rts

		
;**************************************
;* init routines ...
;**************************************

		include	"e:\running\include\init.s"
                
		include	"e:\running\include\key_hit2.s"

;**************************************
;* new_key
;**************************************


new_key:        
                movem.l D0/A0,-(SP)

                lea     $FFFFFC00.w,A0
                move.b  (A0),D0
                btst    #7,D0
                beq.s   must_be_midi

                cmpi.b  #$FF,2(A0)
                bne.s   test_2
i1a:            move.b  (A0),D0
                btst    #7,D0
                beq.s   i1a
i1:             move.b  2(A0),D0
                cmpi.b  #$FF,D0
                beq.s   i1
                move.b  D0,port

                bra.s   new_key_out

;---

test_2:         cmpi.b  #$FE,2(A0)
                bne.s   only_a_key
i1a2:           move.b  (A0),D0
                btst    #7,D0
                beq.s   i1a2
i12:            move.b  2(A0),D0
                cmp.b   #$FE,D0
                beq.s   i12
                move.b  D0,port+1

                bra.s   new_key_out

;---

only_a_key:
                move.b  2(A0),D0
                move.b  D0,key
                bsr.s   convert_key_code

                bra.s   new_key_out

                nop

;---------------

new_key_out:
                movem.l (SP)+,D0/A0

                rte

;---------------

must_be_midi:
                movea.l midi_rout_ptr,A0
                jsr     (A0)

                bra.s   new_key_out

;---------------

convert_key_code:

		ifeq	record_lauf

                lea     keytable(PC),A0
                andi.w  #$00FF,D0
                tst.b   D0
                bmi.s   losgelassen

                move.b  #$FF,0(A0,D0.w)

                rts

losgelassen:
                andi.b  #%01111111,D0
                clr.b   0(A0,D0.w)
                rts

		else

                lea     keytable_help(PC),A0
                andi.w  #$00FF,D0
                tst.b   D0
                bmi.s   losgelassen

                move.b  #$FF,0(A0,D0.w)
                rts

losgelassen:
                andi.b  #%01111111,D0
                clr.b   0(A0,D0.w)
                rts

		endc		

;---------------

keytable:       DS.B 256
keytable_help	ds.b 256
port:           DC.W 0
last_time_joy:  DC.W 0

                
midi_nothing:   

                rts



;**************************************
;* my_vbl
;**************************************

my_vbl:         
                addq.l  #1,vbl_count
                addq.w  #1,vbl_checker

                rte
                
******************************************

	include "menuv6.txt"


;***********************************************************
;***********************************************************


                DATA

counter:        DC.W 0

true_offi:      DC.L true
karte_flag:     DC.W 0

cameraview_flag	dc.w	0
terminal_flag	dc.w	0

screen_1:       dc.l	0
screen_2:       dc.l	0
screen_3:	dc.l	0


;---------------

vbl_start:      DC.L 0
vbl_time:       DC.W 0

;---------------

dont_change_scr	dc.w	0
double_scan	dc.w	0
cinemascope	dc.w	0
ds_vor_karte	dc.w	0
cine_vor_karte	dc.w	0
true_vor_karte	dc.l	0

;---------------

step:           DC.W 0
direction:      DC.W 0
has_moved:      DC.W 0

;---------------

schnitt_flags:  DS.W 4
ccw_erg:        DC.W 0
test_points:    DS.L 4
stand_rot:      DS.L 5*2

schnitt_anz:    DC.W 0
ccw_temp:       DC.W 0
                DC.W 0

sx_test:        DC.L 0
sy_test:        DC.L 0
sh_found:       DC.L 0

inside_ok:      DC.W 0
durchstoss_anz: DC.W 0
clear_it_flag	dc.w	0

inter_ptr:      DS.L 5



file_name_ptr:  DC.L 0
file_size:      DC.L 0
file_buf_ptr:   DC.L 0


;---------------

midi_record:    DS.B 16

midi_rec_pos:   DC.W 0
midi_rec_len:   DC.W 16

old_vbl:        DC.L 0
old_stack:      DC.L 0
old_res:        DC.W 0
old_screen:     DC.L 0
vbl_count:      DC.L 0
vbl_checker:    DC.W 1


;**************************************
;* level daten (pointer)
;**************************************

big_sector_ptr: DC.L 0
boden_col_ptr:  DC.L 0

play_dat_ptr:   DC.L 0

;---------------

max_trains:     DC.W 0
nb_of_trains:   DC.L 0
trains_aktive:  DC.W %0000000000000000
trains_visible: DC.W %0000000000000000

;---------------

video_data:	ds.b	34


********* fire ************

	include	"fire.dat"
	include	"gouraud.dat"
	include	"texture.dat"

;***********************************************************
;***********************************************************

                BSS

bss_start:

vsync_flag	ds.w	1

;---------------
                ;>PART 'main_midi_buf'
main_midi_buf:
                DS.L 1          ; figur 0 - sx
                DS.L 1          ; sy
                DS.W 1          ; sh
                DS.W 1          ; alpha
                DS.W 1          ; animstufe

                DS.L 1          ; figur 1 - sx
                DS.L 1          ; sy
                DS.W 1          ; sh
                DS.W 1          ; alpha
                DS.W 1          ; animstufe

                DS.L 1          ; figur 2 - sx
                DS.L 1          ; sy
                DS.W 1          ; sh
                DS.W 1          ; alpha
                DS.W 1          ; animstufe

                DS.L 1          ; figur 3 - sx
                DS.L 1          ; sy
                DS.W 1          ; sh
                DS.W 1          ; alpha
                DS.W 1          ; animstufe

main_midi_buf_end:
                ;ENDPART

                ;>PART 'test_position_routs'

midi_rout_ptr:  DS.L 1

mouse_pos:      DS.B 8
key:            DS.W 1
midi:           DS.W 1
save_mfp:       DS.L 6
save_system:    DS.L 9
black:          DS.L 8

menue_anim_ptr	ds.l	1
menue_anim_buf	ds.w	16*16

;---------------

pistol_lines:	ds.l	128*4
pistol_offsets:	ds.w	128*4
pistol_pixel:	ds.w	128*4

pistol_data:	ds.b	100000

****** menu **********

	include	"fire.bss"
	include	"gouraud.bss"
	include	"texture.bss"
	include	"data.bss"

**** screen mem ********

		ds.b	256
screen_mem:	ds.b	153600*2
		ds.b	256

bss_end:
                	END

