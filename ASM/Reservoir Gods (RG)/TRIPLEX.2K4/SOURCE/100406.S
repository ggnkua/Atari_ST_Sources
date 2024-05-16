;the further adventures of triplex
;big alec/df
;and damo/rg


key_wait        EQU 12
key_rept        EQU 1

types           EQU 10

		TEXT
		opt	o+,ow-
		
		sf      autoload_flag		;<cxt> 2005-02-03
		include  basepage.i
    		beq.s   .no_autoload
    		st      autoload_flag
.no_autoload:				; adjust path n drive
		lea	path(pc),a1
		move.w	driveno(PC),D0
		add.b 	#"A",d0
		move.b 	d0,(a1)+
		move.b  #":",(a1)+
		lea	cmdpath(pc),a0
		bsr 	ctxt_noterm
		lea	fext(pc),a0
		bsr	ctxt		;</cxt>
                movea.l SP,A5
                movea.l 4(A5),A5
                move.l  $0c(A5),D0
                add.l   $14(A5),D0
                add.l   $1c(A5),D0
                add.l   #$0200,D0
                move.l  D0,D1
                add.l   A5,D1
                movea.l D1,SP
                move.l  D0,-(SP)
                move.l  A5,-(SP)
                clr.w   -(SP)
                move.w  #$4a,-(SP)
                trap    #1
                lea     12(SP),SP

                DC.W $a00a                   ;maus aus

                bsr     appl_init

                move.l  #-1,-(SP)            ;freien speicher ermitteln
                move.w  #$48,-(SP)
                trap    #1
                addq.l  #6,SP
                move.l  D0,free_mem
                bmi     quit_q
                subi.l  #50000,D0            ;50000 Bytes fÅr System freilassen
                bmi     quit_q
                move.l  D0,free_mem
                move.l  D0,-(SP)             ;alles allokieren
                move.w  #$48,-(SP)
                trap    #1
                addq.l  #6,SP
                move.l  D0,mod
                bmi     quit_q
                add.l   free_mem,D0
                move.l  D0,free_end

                movea.l mod,A0
                move.l  free_mem,D0
                lsr.l   #8,D0
                subq.w  #1,D0

clr_mem		moveq   #15,D1

clr_mem2	clr.l   (A0)+
                clr.l   (A0)+
                clr.l   (A0)+
                clr.l   (A0)+
                dbra    D1,clr_mem2
                dbra    D0,clr_mem

                pea     0
                move.w  #$20,-(SP)
                trap    #1
                addq.l  #6,SP
                lea     old_stack,A0
                move.l  D0,(A0)

                bsr     start

                move.l  old_stack,-(SP)
                move.w  #$20,-(SP)
                trap    #1
                addq.l  #6,SP

quit_q		bsr     appl_exit

                DC.W $a009                   ;maus an

                clr.w   -(SP)
                trap    #1

old_stack       DC.L 0

*** 'Clear BSS segment'

start		lea     bss_start,A0
                lea     bss_end,A1
                moveq   #0,D0

clear_bss       move.l  D0,(A0)+
                cmpa.l  A0,A1
                bge     clear_bss

                move.l  SP,oldstack
                move    SR,old_sr

                ori     #$0700,SR            ; lock all IRQ's

                lea     stack,SP             ; set own stack

                jsr     init_mod

install_timers
		lea	timer_code,a0
		move.l	#$200,a1
		move.l	#$100/4-1,d0
.loop
		move.l	(a0)+,(a1)+
		dbf	d0,.loop

                bsr     install_all          ; install all hw-registers

                bsr     prepare_screen

                bsr     main_program

quit            bsr     restore_all          ; set back all hw-registers

                movea.l oldstack,SP          ; restore old stack
                move    old_sr,SR            ; and status register

                bsr     flush

                rts

*** Routines for hardware installation/deinstallation

* saves and installs all hardware registers

install_all	move.b  $ffff820a.w,oldsync  ; save syncmode and resolution
                move.b  $ffff8260.w,oldres

                movem.l $ffff8240.w,D0-D7    ; save old palette
                movem.l D0-D7,oldpalette

                bsr     clear_palette

                lea     $ffff8201.w,A0       ; get old screenpointer
                movep.w 0(A0),D0
                move.w  D0,oldscreen

                move.l  #screen_base,D0
                clr.b   D0                   ; remove lowword in screenpointer
                move.l  D0,screen_1

                move.l  screen_1,D0      ; set the first screen
                bsr     set_screen

;                bsr     init_keyboard        ; install keyboard
                bsr     init_mfp

                bsr     init_soundchip

                bsr     flush

                move    #$2300,SR            ; allow IRQ's

                bsr     vsync
                bset    #1,$ffff820a.w       ; 50 Hz

                bsr     vsync
                clr.b   $ffff8260.w          ; Lowres

                move.l  #vbl,$70.w           ; new VBL driver

                movem.l palette,D0-D7    ; set palette
                movem.l D0-D7,$ffff8240.w

                rts

*** 'Restore'              ; alles zurÅcksetzen

* set back all hardware registers like they were before

restore_all	move.l  #start_vbl,$70.w     ; dummy VBL

                bsr     vsync

                bsr     clear_palette

                bsr     vsync
                bset    #1,$ffff820a.w       ; 50 hz
                bsr     vsync
                bclr    #1,$ffff820a.w       ; 60 hz (to remove syncerrors)
                bsr     vsync
                move.b  oldsync,$ffff820a.w  ; restore sync and resolution
                move.b  oldres,$ffff8260.w

                bsr     flush

                bsr     restore_mfp


;                bsr     restore_keyboard

                bsr     flush

                bsr     restore_soundchip

                move.w  oldscreen,D0
                lea     $ffff8201.w,A0
                movep.w D0,0(A0)             ; alte Screenadresse setzen

                movem.l oldpalette,D0-D7
                movem.l D0-D7,$ffff8240.w

                rts

* sets palette to black

clear_palette	lea     $ffff8240.w,A0
                moveq   #7,D0                ; clear 8 longs=16 colours

clrpal          clr.l   (A0)+
                dbra    D0,clrpal
                rts

* in d0 = screenadress

set_screen	lsr.l   #8,D0
                lea     $ffff8201.w,A0
                movep.w D0,0(A0)             ; set mid and highbyte
                rts

* wait until vbl has been done

vsync		lea     vsync_count,A0
                move.l  (A0),D0

wait_sync       cmp.l   (A0),D0
                beq     wait_sync
                rts

*** 'MFP-Install+DeInstall'

* saves all MFP registers and IRQ's and inits them

init_mfp	move    SR,-(SP)
                ori     #$0700,SR            ; Lock all IRQ's

                lea     $fffffa00.w,A0       ; MFP-Baseregister
                lea     $03(A0),A1           ; Start at MFP Reg $03
                lea     mfp_registers,A2
                moveq   #3,D0                ; Get all registers

save_mfp_loop   movep.l 0(A1),D1             ; get 4 registers once
                move.l  D1,(A2)+             ; store them
                addq.l  #8,A1                ; next 4 registers
                dbra    D0,save_mfp_loop

                lea     $60.w,A1             ; First Autovector-IRQ
                lea     auto_vec_save,A2     ; Store the 8 Autovectors here
                lea     dummy_IRQ_routine,A3
                moveq   #7,D0                ; 8 pointers

save_avc_loop   move.l  (A1),D1              ; get old pointer
                move.l  A3,(A1)+             ; let it point on RTE routine
                move.l  D1,(A2)+
                dbra    D0,save_avc_loop

                lea     $0100.w,A1           ; First MFP-Irq
                lea     mfp_vec_save,A2      ; Store the 16 MFP-Pointers here
                moveq   #15,D0               ; 16 pointers

save_irq_loop   move.l  (A1),D1              ; get old pointer
                move.l  A3,(A1)+             ; let it point on RTE routine
                move.l  D1,(A2)+
                dbra    D0,save_irq_loop

                move.l  #newkey,$0118.w      ; new keyboard IRQ routine
                move.l  #start_vbl,$70.w     ; new VBL (dummy)
;                move.l  #timer_b1,$0120.w

		move.l	#$200,$0134.w
		move.l	#$200,$0110.w

		move.w	#$202,$0136.w
		move.w	#$242,$0112.w

;                move.l  #sound_timer1a,$0134.w ; First SID-voice on Timer A
;                move.l  #sound_timer1b,$0110.w ; Second SID-voice on Timer D

                move.b  #$04,$03(A0)         ; Set Active Edge Register
                clr.b   $05(A0)              ; All ports on Input
                move.b  #%100001,$07(A0)     ; Allow Timer A+B (IRQ-Enab. A)
                move.b  #%1010000,$09(A0)    ; Allow Keyb.IRQ (IRQ-Enab. B)
                move.b  #%100001,$13(A0)     ; Allow Timer A+B (IRQ-Mask A)
                move.b  #%1010000,$15(A0)    ; Allow Keyb.IRQ (IRQ-Mask B)
                clr.b   $0b(A0)              ; Clear IRQ Pending A
                clr.b   $0d(A0)              ; Clear IRQ Pending B
                clr.b   $0f(A0)              ; Clear IRQ-In Service A
                clr.b   $11(A0)              ; Clear IRQ-In Service B
                move.b  #%1000000,$17(A0)    ; IRQ Vector Register (Automat. EOI)
                clr.b   $19(A0)              ; Stop Timer A (Timer A Control)
                clr.b   $1b(A0)              ; Stop Timer B (Timer B Control)
                clr.b   $1d(A0)              ; Stop Timer C+D (T. C+D Contr.)
                clr.b   $1f(A0)              ; Timer A Data = 0
                clr.b   $21(A0)              ; Timer B Data = 0
                clr.b   $23(A0)              ; Timer C Data = 0
                clr.b   $25(A0)              ; Timer D Data = 0

                move    (SP)+,SR
                rts

* restores all MFP registers and IRQ's

restore_mfp	move    SR,-(SP)
                ori     #$0700,SR            ; Lock all IRQ's

                lea     $fffffa03.w,A1       ; MFP
                lea     mfp_registers,A2
                moveq   #3,D0                ; Get all registers

rest_mfp_loop   move.l  (A2)+,D1             ; get 4 registers once
                movep.l D1,0(A1)             ; restore them
                addq.l  #8,A1                ; next 4 registers
                dbra    D0,rest_mfp_loop

                lea     $60.w,A1             ; First Autovector-IRQ
                lea     auto_vec_save,A2     ; Store the 8 Autovectors here
                moveq   #7,D0                ; 8 pointers

rest_avc_loop   move.l  (A2)+,(A1)+          ; restore old pointer
                dbra    D0,rest_avc_loop

                lea     $0100.w,A1           ; First MFP-Irq
                lea     mfp_vec_save,A2      ; Store the 16 MFP-Pointers here
                moveq   #15,D0               ; 16 pointers

rest_irq_loop   move.l  (A2)+,(A1)+          ; restore old pointer
                dbra    D0,rest_irq_loop
				; <cxt> 2005-02-06 ugly TiC fix
	and.b	#$F,$fffffa1d.w	; TiC stop
	move.b	#192,$fffffa23.w	; 200 Hz * 192 = 38400 Hz
	or.b 	#$50,$fffffa1d.w	; 38,400 kHz * 64 = 2,4576 MHz
				; </cxt>
                move    (SP)+,SR
                rts


* first dummy VBL

start_vbl	addq.l  #1,vsync_count
                rte

* just to switch off all not needed IRQ's

dummy_IRQ_routine 
                rte

*** 'Keyboard-Install+DeInstall'

* saves the keyboard status and installs everything necessary.

init_keyboard	move    SR,-(SP)
                ori     #$0700,SR            ; lock all IRQ's

                lea     keyboard_save,A1     ; put in values here
                lea     $fffffc00.w,A2       ; keyboard base address
                lea     keystatlist,A3

get_keyb_stats  move.b  (A3)+,D0             ; get status inquiry reg
                bmi     keystatready         ; -1 is last value
                add.w   #$80,D0              ; +$80 -> status inquiry
                bsr     send_ikbd            ; send status inquiry
                moveq   #7,D1                ; get 8 values

get_packet_lp   btst    #0,(A2)              ; Receive reg. full?
                beq     get_packet_lp
                move.b  2(A2),(A1)+          ; store value from packet
                dbra    D1,get_packet_lp
                bra     get_keyb_stats

keystatready 
*                moveq   #$12,D0              ; disable mouse
*                bsr     send_ikbd

                moveq   #$0c,D0
                bsr     send_ikbd
                moveq   #$01,D0
                bsr     send_ikbd
                moveq   #$01,D0
                bsr     send_ikbd
                moveq   #$09,D0
                
		bsr send_ikbd
                moveq   #$01,D0
                bsr     send_ikbd
                moveq   #63,D0
                bsr     send_ikbd
                moveq   #$00,D0
                bsr     send_ikbd
                move.w  #199,D0
                bsr     send_ikbd

                moveq   #$1a,D0              ; disable joysticks
                bsr     send_ikbd

                move    (SP)+,SR
                rts

* restores all the IKBD status

restore_keyboard
		move    SR,-(SP)
                ori     #$0700,SR            ; lock all IRQ's

                lea     keyboard_save,A0
                moveq   #12,D1               ; 13 status values to restore

restore_ikbd_l  addq.l  #1,A0                ; skip first value
                moveq   #6,D2                ; 7 values

rest_ik_l2      move.b  (A0)+,D0             ; send all the status bytes
                bsr     send_ikbd
                dbra    D2,rest_ik_l2
                dbra    D1,restore_ikbd_l

                move    (SP)+,SR
                rts

* sends byte in d0 to keyboardprocessor

send_ikbd	move.l  A0,-(SP)
                lea     $fffffc00.w,A0

waitkeyready    btst    #1,(A0)              ; wait until Transm. Data reg empty
                beq     waitkeyready
                move.b  D0,2(A0)
                movea.l (SP)+,A0
                rts

* list for all keyboard stats to restore/save (13 values)

keystatlist	DC.B $19,$15,$14,$10,$0f,$0c,$0b,$0a,$09,$08,$07,$12,$1a,-1

*** 'Soundchip-Install+DeInstall'

* saves all soundchip values and inits the soundchip

init_soundchip	lea     $ffff8800.w,A0
                lea     sound_save,A1
                moveq   #15,D0               ; save soundchip

save_sound      move.b  D0,(A0)              ; select port
                move.b  (A0),(A1)+           ; get register
                dbra    D0,save_sound

                move.b  #8,(A0)              ; soundchip off (voulume a+b+c)
                clr.b   2(A0)
                move.b  #9,(A0)
                clr.b   2(A0)
                move.b  #10,(A0)
                clr.b   2(A0)
                rts

* restores the soundchip status

restore_soundchip
                lea     sound_save,A0
                lea     $ffff8800.w,A1
                moveq   #15,D0               ; restore soundchip

restore_sound   move.b  D0,(A1)              ; select port
                move.b  (A0)+,2(A1)
                dbra    D0,restore_sound
                rts

flush		btst    #0,$fffffc00.w
                beq     no_more_flush
                move.b  $fffffc02.w,D0
                bra     flush

no_more_flush	rts

prepare_screen	movea.l screen_1,A1
                move.l  A1,box_save
                lea     panel+34,A0
                move.w  #1999,D0

copy_screen1	move.l  (A0)+,(A1)+
                move.l  (A0)+,(A1)+
                move.l  (A0)+,(A1)+
                move.l  (A0)+,(A1)+
                dbra    D0,copy_screen1

                movea.l screen_1,A0
                move.w  old_c_pos,D0
                addi.w  #5*1280,D0
                lea     0(A0,D0.w),A0
                moveq   #7,D0

first_cursor 
                move.b  #$ff,(A0)
                lea     160(A0),A0
                dbra    D0,first_cursor

                bsr     display_position
                bsr     display_instrument
                bsr     display_len_rst
                bsr     display_octave

                move.w  #304,box_x1
                move.w  #86,box_y1
                move.w  #16,box_x2
                move.w  #23,box_y2
                bsr     box_draw

                rts

;============================================================

main_program	move.b  key,D0

	tst.b	autoload_flag	;<cxt> 2005-02-03
	bne	do_autoload		;</cxt>


                tst.w   mouseflags
                beq     no_mouse_action

                cmpi.w  #264,mousex
                blt     no_quit
                cmpi.w  #264+31,mousex
                bgt     no_quit
                cmpi.w  #86,mousey
                blt     no_quit
                cmpi.w  #86+23,mousey
                bgt     no_quit
                cmpi.w  #2,mouseflags
                bne     no_quit

                move.w  #264,box_x1
                move.w  #86,box_y1
                move.w  #32,box_x2
                move.w  #23,box_y2

                bsr     box_draw
                bsr     wait_mouse_rel
                bsr     box_clear

                cmpi.w  #264,mousex
                blt     no_quit
                cmpi.w  #264+31,mousex
                bgt     no_quit
                cmpi.w  #86,mousey
                blt     no_quit
                cmpi.w  #86+23,mousey
                bgt     no_quit

                bra     exit

no_quit 

;============================================================

*** 'Buttons'

                cmpi.w  #304,mousex
                blt     no_voices_on_off

                cmpi.w  #86,mousey
                blt     no_voice1
                cmpi.w  #86+7,mousey
                bgt     no_voice1
                cmpi.w  #1,mouseflags
                bne     no_voice1

                move.w  #304,box_x1
                move.w  #86,box_y1
                move.w  #16,box_x2
                move.w  #7,box_y2

                bsr     box_draw

                eori.w  #1,v_on_1

                tst.w   v_on_1
                bne     v1_an
                bsr     box_clear
                move.b  #8,$ffff8800.w
                move.b  #0,$ffff8802.w

v1_an		bsr     wait_mouse_rel
                bra     main_program

no_voice1	cmpi.w  #86+8,mousey
                blt     no_voice2
                cmpi.w  #86+15,mousey
                bgt     no_voice2
                cmpi.w  #1,mouseflags
                bne     no_voice2

                move.w  #304,box_x1
                move.w  #86+8,box_y1
                move.w  #16,box_x2
                move.w  #7,box_y2

                bsr     box_draw

                eori.w  #1,v_on_2

                tst.w   v_on_2
                bne     v2_an
                bsr     box_clear
                move.b  #9,$ffff8800.w
                move.b  #0,$ffff8802.w
                andi.b  #$f0,$fffffa1d.w

v2_an		bsr     wait_mouse_rel
                bra     main_program

no_voice2	cmpi.w  #86+16,mousey
                blt     no_voices_on_off
                cmpi.w  #86+23,mousey
                bgt     no_voices_on_off
                cmpi.w  #1,mouseflags
                bne     no_voices_on_off

                move.w  #304,box_x1
                move.w  #86+16,box_y1
                move.w  #16,box_x2
                move.w  #7,box_y2

                bsr     box_draw

                eori.w  #1,v_on_3

                tst.w   v_on_3
                bne     v3_an
                bsr     box_clear
                move.b  #10,$ffff8800.w
                move.b  #0,$ffff8802.w
                clr.b   $fffffa19.w

v3_an		bsr     wait_mouse_rel
                bra     main_program

no_voices_on_off 
                cmpi.w  #136,mousex
                blt     no_edit_but
                cmpi.w  #136+31,mousex
                bgt     no_edit_but
                cmpi.w  #86,mousey
                blt     no_edit_but
                cmpi.w  #86+23,mousey
                bgt     no_edit_but
                cmpi.w  #1,mouseflags
                bne     no_edit_but

                move.w  #136,box_x1
                move.w  #86,box_y1
                move.w  #32,box_x2
                move.w  #23,box_y2

                lea     edit_flag,A0
                eori.w  #1,(A0)
                tst.w   (A0)
                bne     now_edit
                bsr     box_draw
                bsr     box_clear
                bra     end_edit_but

now_edit	bsr     box_draw

end_edit_but	bsr     wait_mouse_rel
                bra     main_program

no_edit_but 

;===============================================================================

                cmpi.w  #104,mousex
                blt     no_load_but
                cmpi.w  #104+15,mousex
                bgt     no_load_but
                cmpi.w  #86,mousey
                blt     no_load_but
                cmpi.w  #86+23,mousey
                bgt     no_load_but
                cmpi.w  #1,mouseflags
                bne     no_load_but
do_autoload:			;<cxt> 2005-02-03 </cxt>
                move.w  #104,box_x1
                move.w  #86,box_y1
                move.w  #16,box_x2
                move.w  #23,box_y2

                bsr     box_draw
                bsr     wait_mouse_rel
                bsr     box_clear

                bsr     fileselector_l
                bra     main_program

no_load_but 

;===============================================================================

                cmpi.w  #120,mousex
                blt     no_save_but
                cmpi.w  #120+15,mousex
                bgt     no_save_but
                cmpi.w  #86,mousey
                blt     no_save_but
                cmpi.w  #86+23,mousey
                bgt     no_save_but
                cmpi.w  #1,mouseflags
                bne     no_save_but

                move.w  #120,box_x1
                move.w  #86,box_y1
                move.w  #16,box_x2
                move.w  #23,box_y2

                bsr     box_draw
                bsr     wait_mouse_rel
                bsr     box_clear

                bsr     fileselector_s

                bra     main_program

no_save_but 

;===============================================================================

                cmpi.w  #168,mousex
                blt     no_sounded_but
                cmpi.w  #168+31,mousex
                bgt     no_sounded_but
                cmpi.w  #86,mousey
                blt     no_sounded_but
                cmpi.w  #86+23,mousey
                bgt     no_sounded_but
                cmpi.w  #1,mouseflags
                bne     no_sounded_but

                move.w  #136,box_x1          ;edit button coords
                move.w  #86,box_y1
                move.w  #32,box_x2
                move.w  #23,box_y2
                bsr     box_draw
                bsr     box_clear

                clr.w   edit_flag

                move.w  #168,box_x1          ;sound edit coords
                move.w  #86,box_y1
                move.w  #32,box_x2
                move.w  #23,box_y2

                bsr     box_draw
                bsr     wait_mouse_rel

                bsr     sound_editor

                move.w  #168,box_x1          ;sound edit coords
                move.w  #86,box_y1
                move.w  #32,box_x2
                move.w  #23,box_y2

                bsr     box_draw
                bsr     box_clear

                bsr     wait_mouse_rel

                bra     main_program

no_sounded_but 

;===============================================================================

                cmpi.w  #200,mousex
                blt     no_arp_ed_but
                cmpi.w  #200+31,mousex
                bgt     no_arp_ed_but
                cmpi.w  #86,mousey
                blt     no_arp_ed_but
                cmpi.w  #86+23,mousey
                bgt     no_arp_ed_but
                cmpi.w  #1,mouseflags
                bne     no_arp_ed_but

                move.w  #136,box_x1          ;edit button coords
                move.w  #86,box_y1
                move.w  #32,box_x2
                move.w  #23,box_y2
                bsr     box_draw
                bsr     box_clear

                clr.w   edit_flag

                move.w  #200,box_x1          ;arp edit coords
                move.w  #86,box_y1
                move.w  #32,box_x2
                move.w  #23,box_y2

                bsr     box_draw
                bsr     wait_mouse_rel

                bsr     arpeggio_editor

                move.w  #200,box_x1          ;arp edit coords
                move.w  #86,box_y1
                move.w  #32,box_x2
                move.w  #23,box_y2

                bsr     box_draw
                bsr     box_clear

                bsr     wait_mouse_rel

                bra     main_program

no_arp_ed_but 

;===============================================================================

                cmpi.w  #232,mousex
                blt     no_noz_ed_but
                cmpi.w  #232+31,mousex
                bgt     no_noz_ed_but
                cmpi.w  #86,mousey
                blt     no_noz_ed_but
                cmpi.w  #86+23,mousey
                bgt     no_noz_ed_but
                cmpi.w  #1,mouseflags
                bne     no_noz_ed_but

                move.w  #136,box_x1          ;edit button coords
                move.w  #86,box_y1
                move.w  #32,box_x2
                move.w  #23,box_y2
                bsr     box_draw
                bsr     box_clear

                clr.w   edit_flag

                move.w  #232,box_x1          ;noz edit coords
                move.w  #86,box_y1
                move.w  #32,box_x2
                move.w  #23,box_y2

                bsr     box_draw
                bsr     wait_mouse_rel

                bsr     noise_editor

                move.w  #232,box_x1          ;noz edit coords
                move.w  #86,box_y1
                move.w  #32,box_x2
                move.w  #23,box_y2

                bsr     box_draw
                bsr     box_clear

                bsr     wait_mouse_rel

                bra     main_program

no_noz_ed_but 

;===============================================================================

                cmpi.w  #64,mousex
                blt     no_stop_but
                cmpi.w  #64+39,mousex
                bgt     no_stop_but
                cmpi.w  #98,mousey
                blt     no_stop_but
                cmpi.w  #98+11,mousey
                bgt     no_stop_but
                cmpi.w  #1,mouseflags
                bne     no_stop_but

                move.w  #64,box_x1
                move.w  #98,box_y1
                move.w  #40,box_x2
                move.w  #11,box_y2

                move.w  #0,play_flag
                bsr     box_draw
                jsr     silence
                bsr     wait_mouse_rel
                bsr     box_clear
                bra     main_program

no_stop_but 

;===============================================================================

                cmpi.w  #64,mousex
                blt     no_play_but
                cmpi.w  #64+39,mousex
                bgt     no_play_but
                cmpi.w  #86,mousey
                blt     no_play_but
                cmpi.w  #86+11,mousey
                bgt     no_play_but
                cmpi.w  #1,mouseflags
                bne     no_play_but

                move.w  #64,box_x1
                move.w  #86,box_y1
                move.w  #40,box_x2
                move.w  #11,box_y2

                jsr     init_player

                move.w  #1,play_flag
                bsr     box_draw
                bsr     wait_mouse_rel
                bsr     box_clear
                bra     main_program

no_play_but 

;===============================================================================

                cmpi.w  #8*12,mousey
                blt     no_line1
                cmpi.w  #8*13,mousey
                bgt     no_line1

                move.w  #8*12,box_y1
                move.w  #8,box_x2
                move.w  #8,box_y2

;---------- Position Increase Button ---------

                cmpi.w  #8,mousex
                bgt     no_inc_pos
                cmpi.w  #1,mouseflags
                bne     no_inc_pos

                move.w  #0,box_x1
                bsr     box_draw

                addq.w  #1,current_pos
                andi.w  #$ff,current_pos

                bsr     display_position
                bsr     wait_mouse_rel
                bsr     box_clear

                bra     main_program

no_inc_pos 

;---------- Position Decrease Button ---------

                cmpi.w  #24,mousex
                blt     no_dec_pos
                cmpi.w  #32,mousex
                bgt     no_dec_pos
                cmpi.w  #1,mouseflags
                bne     no_dec_pos

                move.w  #24,box_x1
                bsr     box_draw

                subq.w  #1,current_pos
                andi.w  #$ff,current_pos

                bsr     display_position
                bsr     wait_mouse_rel
                bsr     box_clear

                bra     main_program

no_dec_pos 

;---------- Sequence Increase Button ---------

                cmpi.w  #32,mousex
                blt     no_inc_seq
                cmpi.w  #40,mousex
                bgt     no_inc_seq
                cmpi.w  #1,mouseflags
                bne     no_inc_seq

                move.w  #32,box_x1
                bsr     box_draw

                addq.w  #1,current_patt
                andi.w  #$ff,current_patt
                movea.l mod,A0
                adda.l  $0c(A0),A0
                move.w  current_pos,D0
                move.w  current_patt,D1
                move.b  D1,0(A0,D0.w)

                bsr     display_position
                bsr     wait_mouse_rel
                bsr     box_clear

                bra     main_program

no_inc_seq 

;---------- Sequence Decrease Button ---------

                cmpi.w  #56,mousex
                blt     no_line1
                cmpi.w  #64,mousex
                bgt     no_line1
                cmpi.w  #1,mouseflags
                bne     no_line1

                move.w  #56,box_x1
                bsr     box_draw

                subq.w  #1,current_patt
                andi.w  #$ff,current_patt
                movea.l mod,A0
                adda.l  $0c(A0),A0
                move.w  current_pos,D0
                move.w  current_patt,D1
                move.b  D1,0(A0,D0.w)

                bsr     display_position
                bsr     wait_mouse_rel
                bsr     box_clear

                bra     main_program

no_line1	cmpi.w  #8*15,mousey
                blt     no_line2
                cmpi.w  #8*16,mousey
                bgt     no_line2

                move.w  #8*15,box_y1
                move.w  #8,box_x2
                move.w  #8,box_y2

;---------- Instrument Increase Button ---------

                cmpi.w  #8,mousex
                bgt     no_inc_ins
                cmpi.w  #1,mouseflags
                bne     no_inc_ins

                move.w  #0,box_x1
                bsr     box_draw

                addq.w  #1,instrument
                andi.w  #$1f,instrument

                bsr     display_instrument
                bsr     wait_mouse_rel
                bsr     box_clear

                bra     main_program

no_inc_ins 

;---------- Instrument Decrease Button ---------

                cmpi.w  #24,mousex
                blt     no_dec_ins
                cmpi.w  #32,mousex
                bgt     no_dec_ins
                cmpi.w  #1,mouseflags
                bne     no_dec_ins

                move.w  #24,box_x1
                bsr     box_draw

                subq.w  #1,instrument
                andi.w  #$1f,instrument

                bsr     display_instrument
                bsr     wait_mouse_rel
                bsr     box_clear

                bra     main_program

no_dec_ins 

;---------- Volume Increase Button ---------

                cmpi.w  #32,mousex
                blt     no_inc_vol
                cmpi.w  #40,mousex
                bgt     no_inc_vol
                cmpi.w  #1,mouseflags
                bne     no_inc_vol

                move.w  #32,box_x1
                bsr     box_draw


                movea.l mod,A0
                adda.l  (A0),A0
                move.w  instrument,D0
                beq     no_change_inc
                add.w   D0,D0
                move.w  0(A0,D0.w),D0
                lea     0(A0,D0.w),A0        ;a0 - pointer on instrument

                addq.b  #1,3(A0)             ;increase volume
                andi.b  #$0f,3(A0)

no_change_inc	bsr     display_instrument
                bsr     wait_mouse_rel
                bsr     box_clear

                bra     main_program

no_inc_vol 

;---------- Volume Decrease Button ---------

                cmpi.w  #56,mousex
                blt     no_line2
                cmpi.w  #64,mousex
                bgt     no_line2
                cmpi.w  #1,mouseflags
                bne     no_line2

                move.w  #56,box_x1
                bsr     box_draw

                movea.l mod,A0
                adda.l  (A0),A0
                move.w  instrument,D0
                beq     no_change_dec
                add.w   D0,D0
                move.w  0(A0,D0.w),D0
                lea     0(A0,D0.w),A0        ;a0 - pointer on instrument

                subq.b  #1,3(A0)             ;decrease volume
                andi.b  #$0f,3(A0)

no_change_dec	bsr     display_instrument
                bsr     wait_mouse_rel
                bsr     box_clear

                bra     main_program

no_line2	cmpi.w  #8*18,mousey
                blt     no_line3
                cmpi.w  #8*19,mousey
                bgt     no_line3

                move.w  #8*18,box_y1
                move.w  #8,box_x2
                move.w  #8,box_y2

;---------- Length Increase Button ---------

                cmpi.w  #8,mousex
                bgt     no_inc_len
                cmpi.w  #1,mouseflags
                bne     no_inc_len

                move.w  #0,box_x1
                bsr     box_draw

                movea.l mod,A0
                cmpi.b  #$ff,$14(A0)
                beq     no_more_inc_len
                addq.b  #1,$14(A0)

no_more_inc_len	bsr     display_len_rst
                bsr     wait_mouse_rel
                bsr     box_clear

                bra     main_program

no_inc_len 

;---------- Length Decrease Button ---------

                cmpi.w  #24,mousex
                blt     no_dec_len
                cmpi.w  #32,mousex
                bgt     no_dec_len
                cmpi.w  #1,mouseflags
                bne     no_dec_len

                move.w  #24,box_x1
                bsr     box_draw

                movea.l mod,A0

                cmpi.b  #1,$14(A0)
                beq     no_more_dec_len

                subq.b  #1,$14(A0)

no_more_dec_len	bsr     display_len_rst
                bsr     wait_mouse_rel
                bsr     box_clear

                bra     main_program

no_dec_len 

;---------- Restart Increase Button ---------

                cmpi.w  #32,mousex
                blt     no_inc_rst
                cmpi.w  #40,mousex
                bgt     no_inc_rst
                cmpi.w  #1,mouseflags
                bne     no_inc_rst

                move.w  #32,box_x1
                bsr     box_draw

                movea.l mod,A0
                addq.b  #1,$15(A0)           ;increase restart

                bsr     display_len_rst
                bsr     wait_mouse_rel
                bsr     box_clear

                bra     main_program

no_inc_rst 

;---------- Restart Decrease Button ---------

                cmpi.w  #56,mousex
                blt     no_line3
                cmpi.w  #64,mousex
                bgt     no_line3
                cmpi.w  #1,mouseflags
                bne     no_line3

                move.w  #56,box_x1
                bsr     box_draw

                movea.l mod,A0
                subq.b  #1,$15(A0)           ;decrease restart

                bsr     display_len_rst
                bsr     wait_mouse_rel
                bsr     box_clear

                bra     main_program

no_line3	cmpi.w  #8*21,mousey
                blt     no_line4
                cmpi.w  #8*22,mousey
                bgt     no_line4

                move.w  #8*21,box_y1
                move.w  #8,box_x2
                move.w  #8,box_y2

;---------- Octave Increase Button ---------

                cmpi.w  #8,mousex
                bgt     no_inc_oct
                cmpi.w  #1,mouseflags
                bne     no_inc_oct

                move.w  #0,box_x1
                bsr     box_draw

                cmpi.w  #8,octave
                beq     no_more_inc_oct
                addq.w  #1,octave

no_more_inc_oct	bsr     display_octave
                bsr     wait_mouse_rel
                bsr     box_clear

                bra     main_program

no_inc_oct 

;---------- Octave Decrease Button ---------

                cmpi.w  #24,mousex
                blt     no_line4
                cmpi.w  #32,mousex
                bgt     no_line4
                cmpi.w  #1,mouseflags
                bne     no_line4

                move.w  #24,box_x1
                bsr     box_draw

                tst.w   octave
                beq     no_more_dec_oct

                subq.w  #1,octave

no_more_dec_oct	bsr     display_octave
                bsr     wait_mouse_rel
                bsr     box_clear

                bra     main_program

no_line4	cmpi.w  #8*23,mousey
                blt     no_line5
                cmpi.w  #8*24,mousey
                bgt     no_line5

                move.w  #8*23,box_y1
                move.w  #8,box_x2
                move.w  #8,box_y2

;---------- Type Increase Button ---------

                cmpi.w  #80,mousex
                blt     no_inc_type
                cmpi.w  #88,mousex
                bgt     no_inc_type
                cmpi.w  #1,mouseflags
                bne     no_inc_type

                move.w  #80,box_x1
                bsr     box_draw

                movea.l mod,A0
                adda.l  (A0),A0
                move.w  instrument,D0
                add.w   D0,D0
                move.w  0(A0,D0.w),D0
                lea     0(A0,D0.w),A0        ;a0 - pointer on instrument

                cmpi.b  #types,(A0)
                beq     no_more_inc_type
                addq.b  #1,(A0)

no_more_inc_type 
                bsr     display_wavedata
                bsr     wait_mouse_rel
                bsr     box_clear

                bra     main_program

no_inc_type 

;---------- Type Decrease Button ---------

                cmpi.w  #104,mousex
                blt     no_dec_type
                cmpi.w  #112,mousex
                bgt     no_dec_type
                cmpi.w  #1,mouseflags
                bne     no_dec_type

                move.w  #104,box_x1
                bsr     box_draw

                movea.l mod,A0
                adda.l  (A0),A0
                move.w  instrument,D0
                add.w   D0,D0
                move.w  0(A0,D0.w),D0
                lea     0(A0,D0.w),A0        ;a0 - pointer on instrument

                tst.b   (A0)
                beq     no_more_dec_type

                subq.b  #1,(A0)

no_more_dec_type 
                bsr     display_wavedata
                bsr     wait_mouse_rel
                bsr     box_clear

                bra     main_program

no_dec_type 

;---------- Arpeggio Increase Button ---------

                cmpi.w  #112,mousex
                blt     no_inc_arp
                cmpi.w  #120,mousex
                bgt     no_inc_arp
                cmpi.w  #1,mouseflags
                bne     no_inc_arp

                move.w  #112,box_x1
                bsr     box_draw

                movea.l mod,A0
                adda.l  (A0),A0
                move.w  instrument,D0
                add.w   D0,D0
                move.w  0(A0,D0.w),D0
                lea     1(A0,D0.w),A0        ;a0 - pointer on instrument

                addq.b  #1,(A0)
                andi.b  #$1f,(A0)

                bsr     display_wavedata
                bsr     wait_mouse_rel
                bsr     box_clear

                bra     main_program

no_inc_arp 

;---------- Arpeggio Decrease Button ---------

                cmpi.w  #136,mousex
                blt     no_dec_arp
                cmpi.w  #144,mousex
                bgt     no_dec_arp
                cmpi.w  #1,mouseflags
                bne     no_dec_arp

                move.w  #136,box_x1
                bsr     box_draw

                movea.l mod,A0
                adda.l  (A0),A0
                move.w  instrument,D0
                add.w   D0,D0
                move.w  0(A0,D0.w),D0
                lea     1(A0,D0.w),A0        ;a0 - pointer on instrument

                subq.b  #1,(A0)
                andi.b  #$1f,(A0)

                bsr     display_wavedata
                bsr     wait_mouse_rel
                bsr     box_clear

                bra     main_program

no_dec_arp 

;---------- Noise Increase Button ---------

                cmpi.w  #144,mousex
                blt     no_inc_noz
                cmpi.w  #152,mousex
                bgt     no_inc_noz
                cmpi.w  #1,mouseflags
                bne     no_inc_noz

                move.w  #144,box_x1
                bsr     box_draw

                movea.l mod,A0
                adda.l  (A0),A0
                move.w  instrument,D0
                add.w   D0,D0
                move.w  0(A0,D0.w),D0
                lea     2(A0,D0.w),A0        ;a0 - pointer on instrument

                addq.b  #1,(A0)
                andi.b  #$0f,(A0)

                bsr     display_wavedata
                bsr     wait_mouse_rel
                bsr     box_clear

                bra     main_program

no_inc_noz 

;---------- Noise Decrease Button ---------

                cmpi.w  #168,mousex
                blt     no_dec_noz
                cmpi.w  #176,mousex
                bgt     no_dec_noz
                cmpi.w  #1,mouseflags
                bne     no_dec_noz

                move.w  #168,box_x1
                bsr     box_draw

                movea.l mod,A0
                adda.l  (A0),A0
                move.w  instrument,D0
                add.w   D0,D0
                move.w  0(A0,D0.w),D0
                lea     2(A0,D0.w),A0        ;a0 - pointer on instrument

                subq.b  #1,(A0)
                andi.b  #$0f,(A0)

                bsr     display_wavedata
                bsr     wait_mouse_rel
                bsr     box_clear

                bra     main_program

no_dec_noz 

;---------- Speed Increase Button ---------

                cmpi.w  #176,mousex
                blt     no_inc_speed
                cmpi.w  #184,mousex
                bgt     no_inc_speed
                cmpi.w  #1,mouseflags
                bne     no_inc_speed

                move.w  #176,box_x1
                bsr     box_draw

                movea.l mod,A0
                adda.l  (A0),A0
                move.w  instrument,D0
                add.w   D0,D0
                move.w  0(A0,D0.w),D0
                lea     4(A0,D0.w),A0        ;a0 - pointer on instrument

                addq.b  #1,(A0)
                andi.b  #$1f,(A0)

                bsr     display_wavedata
                bsr     wait_mouse_rel
                bsr     box_clear

                bra     main_program

no_inc_speed 

;---------- Speed Decrease Button ---------

                cmpi.w  #200,mousex
                blt     no_dec_speed
                cmpi.w  #208,mousex
                bgt     no_dec_speed
                cmpi.w  #1,mouseflags
                bne     no_dec_speed

                move.w  #200,box_x1
                bsr     box_draw

                movea.l mod,A0
                adda.l  (A0),A0
                move.w  instrument,D0
                add.w   D0,D0
                move.w  0(A0,D0.w),D0
                lea     4(A0,D0.w),A0        ;a0 - pointer on instrument

                subq.b  #1,(A0)
                andi.b  #$1f,(A0)

                bsr     display_wavedata
                bsr     wait_mouse_rel
                bsr     box_clear

                bra     main_program

no_dec_speed 

no_line5 

;===============================================================================

*** 'Function keys etc.'

no_mouse_action	
		cmpi.b  #$3b,D0              ;F1 - Block start
                bne     no_block_start

		move.w	patt_pos,d1
		move.w	d1,block_start

display_blockstart
                movea.l screen_1,A1
                lea     1280*23(A1),A1
                lea     dummy,A3

                move.w  block_start,D0
;                andi.w  #$1f,D0

                move.l  D0,-(SP)
                move.w  #2,-(SP)
                pea     (A3)
                bsr     hex_convert
                lea     10(SP),SP

                clr.b   2(A3)

                pea     (A3)
                pea     89+32(A1)
                bsr     PrintLine
                addq.l  #8,SP

                bsr     waitrelease
                bra     main_program

no_block_start 
		cmpi.b  #$3c,D0              ;F2 - Block end
                bne     no_block_end

		move.w	patt_pos,d1
		move.w	d1,block_end
display_blockend
                movea.l screen_1,A1
                lea     1280*23(A1),A1
                lea     dummy,A3

                move.w  block_end,D0
;                andi.w  #$1f,D0

                move.l  D0,-(SP)
                move.w  #2,-(SP)
                pea     (A3)
                bsr     hex_convert
                lea     10(SP),SP

                clr.b   2(A3)

                pea     (A3)
                pea     89+48(A1)
                bsr     PrintLine
                addq.l  #8,SP
                bsr     waitrelease
                bra     main_program

no_block_end
		cmpi.b	#$3d,d0			;f3 - copy block to buf
		bne	no_copy_to_buffer

		move.w	block_end,d1		;is block start bigger
		cmp.w	block_start,d1		;than block end?
		blt	no_copy_to_buffer

block_to_buf	movea.l curr_patt_base,A0
                lea     block_buf,A1

                move.w  channel_pos,D0   ;which channel to copy?
                lsl.w   #2,D0
                lea     0(A0,D0.w),A0

		move.w	block_start,d0
		sub.w	d0,d1		;get number of steps to copy
		move.w	d1,block_size		
;		sub.w	#1,d1		;for the dbf
		mulu.w	#12,d0
		lea	(a0,d0.w),a0	;point to exact step
		
            
copy_t_to_b	move.l  (A0),(A1)+
                lea     12(A0),A0
                dbra    D1,copy_t_to_b

		move.l	#62,d1
.loop
		move.l	#0,(a1)+
		dbf	d1,.loop

                bsr     waitrelease
                bra     main_program


no_copy_to_buffer
		cmpi.b	#$3e,d0		;f4 - paste
		bne	no_paste_to_track

;                tst.w   edit_flag
;                beq     no_paste_to_track


		movea.l curr_patt_base,A0
                lea     block_buf,A1

                move.w  channel_pos,D0   ;which channel to copy?
                lsl.w   #2,D0
                lea     0(A0,D0.w),A0

		move.w	patt_pos,d0
		move.w	#63,d1
		sub.w	d0,d1
		cmp.w	block_size,d1
		blt	.skip
		move.w	block_size,d1
.skip		
		mulu	#12,d0
		lea	(a0,d0.w),a0	

		cmp.w	#0,d1
		bne.s	not_single_line
		move.l	(a1),(a0)
		bra.s	end_of_block_paste
not_single_line
;		sub.w	#1,d1
copy_b_to_t
		move.l	(a1)+,(a0)
		lea	12(a0),a0
		dbf	d1,copy_b_to_t
end_of_block_paste
                bsr     set_patt
                bsr     waitrelease
                bra     main_program

no_paste_to_track
;------------------------------------------------

                cmpi.b  #$41,D0              ;F7 - F10 -> Patt. pos
                blt     no_pos_patt
                cmpi.b  #$44,D0
                bgt     no_pos_patt

                subi.b  #$41,D0
                lsl.w   #4,D0
                andi.w  #$3f,D0
                move.w  D0,patt_pos
                bsr     set_patt

                bsr     waitrelease
                bra     main_program

no_pos_patt 

;------------------------------------------------

                cmpi.b  #$61,D0              ;<SHIFT>+<UNDO> - Clear Track
                bne     no_track_clear

                move.w  switch_keys,D0
                andi.w  #3,D0                ;only the shift-keys!
                beq     no_track_clear       ;no shift? no zero...

                bsr     clear_track

                bsr     set_patt

                bsr     waitrelease
                bra     main_program

no_track_clear 

;------------------------------------------------

                cmpi.b  #$39,D0              ;<SPACE> Edit mode
                bne     no_space

                tst.w   play_flag
                beq     no_stop_to_edit

                move.w  #64,box_x1
                move.w  #98,box_y1
                move.w  #40,box_x2
                move.w  #11,box_y2

                move.w  #0,play_flag
                bsr     box_draw
                jsr     silence
                bsr     waitrelease
                bsr     box_clear

                bra     main_program

no_stop_to_edit	
		jsr	silence
		move.w  #136,box_x1
                move.w  #86,box_y1
                move.w  #32,box_x2
                move.w  #23,box_y2

                lea     edit_flag,A0
                eori.w  #1,(A0)
                tst.w   (A0)
                bne     now_edit2
                bsr     box_draw
                bsr     box_clear
                bra     end_edit_but2

now_edit2	bsr     box_draw

end_edit_but2	bsr     waitrelease
                bra     main_program

no_space 

;------------------------------------------------

                cmpi.b  #$3a,D0              ;<CapsLock> Play
                bne     no_caps

                move.w  #64,box_x1
                move.w  #86,box_y1
                move.w  #40,box_x2
                move.w  #11,box_y2

                jsr     init_player

                move.w  #1,play_flag
                bsr     box_draw
                bsr     waitrelease
                bsr     box_clear

                bra     main_program

no_caps 

;--------------------------------------------------

                cmpi.b  #$52,D0              ;<Insert> - insert position
                bne     no_insert_pos

                tst.w   edit_flag
                beq     no_insert_pos

                movea.l curr_patt_base,A0

                move.w  channel_pos,D1       ;which channel to copy?
                lsl.w   #2,D1
                lea     0(A0,D1.w),A0	;a0 points to start of current pat

		move.w	patt_pos,d1	;d1 = current step (0-63)
		move.w	#62,d2
		sub.w	d1,d2		

		cmp.w	#-1,d2			;insert clip
		bne.s	not_last		;incase on last step
		move.l	#0,3*4*63(a0)		;of track
		bra.s	skip_insert
not_last
                lea     62*4*3(A0),A0


insert_it	move.l  (A0),4*3(A0)
                lea     -12(A0),A0
                dbra    D2,insert_it

                move.l  #0,12(A0)
skip_insert
                bsr     set_patt
                bsr     waitrelease
                bra     main_program

no_insert_pos 
                cmpi.b  #83,D0              ;<del> - delete position
                bne     no_del_pos

                tst.w   edit_flag
                beq     no_del_pos

                movea.l curr_patt_base,A0

                move.w  channel_pos,D1       ;which channel to copy?
                lsl.w   #2,D1
                lea     0(A0,D1.w),A0	;a0 points to start of current pat
		lea	12*63(a0),a5
		move.w	patt_pos,d1	;d1 = current step (0-63)
		move.w	#62,d2
		sub.w	d1,d2		

		cmp.w	#-1,d2			;insert clip
		bne.s	not_last2		;incase on last step
;		move.l	#0,3*4*63(a0)		;of track
		bra.s	skip_del
not_last2
		mulu.w	#12,d1		;get current step offset
                lea    (A0,d1.w),A0	;point to exact step


delete_it	move.l  12(A0),(A0)
                lea     12(A0),A0
                dbra    D2,delete_it

;                move.l  #0,12(A0)
skip_del
		move.l	#0,(a5)		;delete last step
                bsr     set_patt
                bsr     waitrelease
                bra     main_program

no_del_pos
;------------------------------------------------

*** 'Cursors & Editing'

                cmpi.b  #$48,D0
                bne     no_curs_up

		tst.w	play_flag
		bne.s	no_curs_up

                bsr     patt_scroll_up
                moveq   #key_wait,D1

wait_curs_up	tst.b   hold_flag
                beq     end_curs_up
                bsr     vsync
                dbra    D1,wait_curs_up

again_cu	bsr     patt_scroll_up
                moveq   #key_rept,D1

wait_curs_up2	tst.b   hold_flag
                beq     end_curs_up
                bsr     vsync
                dbra    D1,wait_curs_up2
                bra     again_cu

end_curs_up	bra     main_program

no_curs_up 

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

                cmpi.b  #$50,D0
                bne     no_curs_down

		tst.w	play_flag
		bne.s	no_curs_down

                bsr     patt_scroll_down
                moveq   #key_wait,D1

wait_curs_down	tst.b   hold_flag
                beq     end_curs_down
                bsr     vsync
                dbra    D1,wait_curs_down

again_cd	bsr     patt_scroll_down
                moveq   #key_rept,D1

wait_curs_down2	tst.b   hold_flag
                beq     end_curs_down
                bsr     vsync
                dbra    D1,wait_curs_down2
                bra     again_cd

end_curs_down	bra     main_program

no_curs_down 

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

                cmpi.b  #$4b,D0
                bne     no_curs_left
                bsr     cursor_left
                moveq   #key_wait,D1

wait_curs_left	tst.b   hold_flag
                beq     end_curs_left
                bsr     vsync
                dbra    D1,wait_curs_left

again_cl	bsr     cursor_left
                moveq   #key_rept,D1

wait_curs_left2	tst.b   hold_flag
                beq     end_curs_left
                bsr     vsync
                dbra    D1,wait_curs_left2
                bra     again_cl

end_curs_left	bra     main_program

no_curs_left 

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

                cmpi.b  #$4d,D0
                bne     no_curs_right
                bsr     cursor_right
                moveq   #key_wait,D1

wait_curs_right	tst.b   hold_flag
                beq     end_curs_right
                bsr     vsync
                dbra    D1,wait_curs_right

again_cr	bsr     cursor_right
                moveq   #key_rept,D1

wait_curs_right2 
                tst.b   hold_flag
                beq     end_curs_right
                bsr     vsync
                dbra    D1,wait_curs_right2
                bra     again_cr

end_curs_right	bra     main_program

no_curs_right 

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

                tst.w   cursor_pos
                bne     no_keyboard

                bsr     keyboard

no_keyboard	tst.w   edit_flag
                beq     no_value_change

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

                cmpi.w  #1,cursor_pos
                beq     instr_change
                cmpi.w  #2,cursor_pos
                bne     no_instr_change

instr_change	bsr     enter_hex
                tst.b   D3
                bmi     no_instr_change
                bsr     process_instr
                bsr     waitrelease
                bra     main_program

no_instr_change 

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

                cmpi.w  #3,cursor_pos
                bne     no_fx_change

                bsr     enter_hex
                tst.b   D3
                bmi     no_fx_change
                bsr     process_effect
                bsr     waitrelease
                bra     main_program

no_fx_change 

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

                cmpi.w  #4,cursor_pos
                beq     value_change
                cmpi.w  #5,cursor_pos
                bne     no_value_change

value_change	bsr     enter_hex
                tst.b   D3
                bmi     no_value_change
                bsr     process_value
                bsr     waitrelease
                bra     main_program

no_value_change 

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

;                bsr     display_position

                bra     main_program

exit		rts

waitrelease	tst.b   hold_flag
                bne     waitrelease
                rts

wait_mouse_rel	tst.w   mouseflags
                bne     wait_mouse_rel
                rts

;=====================================================================

                *** 'Sound Editor (Wave)'

sound_editor	bsr     wait_mouse_rel

                movea.l mod,A0
                move.w  instrument,D0
                beq     exit_sound_edit

                adda.l  (A0),A0
                add.w   D0,D0

                move.w  0(A0,D0.w),D0
                lea     0(A0,D0.w),A0

check_mouse	move.w  mousex,D0
                move.w  mousey,D1
                cmpi.w  #80,D0
                blt     no_wave_edit
                cmpi.w  #80+4*58-1,D0
                bgt     no_wave_edit
                cmpi.w  #113,D1
                blt     no_wave_edit
                cmpi.w  #113+3*18-1,D1
                bgt     no_wave_edit
                cmpi.w  #1,mouseflags
                bne     no_wave_edit
                subi.w  #80,D0
                subi.w  #113,D1
                andi.l  #$ff,D1

                lsr.w   #2,D0
                lea     5(A0,D0.w),A1

                divu    #3,D1

                tst.w   D1
                bne     no_mask_w_e
                eori.b  #$20,(A1)
                bra     no_more_wave_edit

no_mask_w_e	cmpi.w  #1,D1
                bne     no_buzz_w_e
                eori.b  #$10,(A1)
                bra     no_more_wave_edit

no_buzz_w_e	subq.w  #2,D1
                eori.w  #$0f,D1
                andi.b  #$30,(A1)
                or.b    D1,(A1)

no_more_wave_edit 
		bsr     draw_wave
                bsr     wait_mouse_rel

no_wave_edit	move.w  mousex,D0
                move.w  mousey,D1

                cmpi.w  #80,D0
                blt     no_wave_end_m
                cmpi.w  #80+4*58-1,D0
                bgt     no_wave_end_m
                cmpi.w  #168,D1
                blt     no_wave_end_m
                cmpi.w  #172,D1
                bgt     no_wave_end_m
                cmpi.w  #1,mouseflags
                bne     no_wave_end_m

                subi.w  #80,D0
                lsr.w   #2,D0
                lea     5(A0),A1

search_end	tst.b   (A1)+
                bpl     no_ff_wave
                clr.b   -1(A1)

no_ff_wave	dbra    D0,search_end
                move.b  #-1,(A1)

                bsr     draw_wave
                bsr     wait_mouse_rel

no_wave_end_m	cmpi.w  #2,mouseflags
                beq     exit_sound_edit
                bra     check_mouse

exit_sound_edit	rts

*** 'Arpeggio & Noise Editor'

arpeggio_editor	movea.l mod,A0
                movea.l A0,A1
                adda.l  (A0),A0              ;instruments
                adda.l  4(A1),A1             ;arpeggios

                move.w  instrument,D0
                andi.w  #$1f,D0
                add.w   D0,D0
                move.w  0(A0,D0.w),D0
                lea     0(A0,D0.w),A0
                move.b  1(A0),D0
                andi.w  #$1f,D0              ;arpeggio
                add.w   D0,D0
                move.w  0(A1,D0.w),D0
                lea     0(A1,D0.w),A1        ;a1 - pointer on arpeggio data

                move.l  A1,data_base

                bra     data_editor

noise_editor	movea.l mod,A0
                movea.l A0,A1
                adda.l  (A0),A0              ;instruments
                adda.l  8(A1),A1             ;noises

                move.w  instrument,D0
                andi.w  #$1f,D0
                add.w   D0,D0
                move.w  0(A0,D0.w),D0
                lea     0(A0,D0.w),A0
                move.b  2(A0),D0
                andi.w  #$0f,D0              ;noise
                add.w   D0,D0
                move.w  0(A1,D0.w),D0
                lea     0(A1,D0.w),A1        ;a1 - pointer on noise data

                move.l  A1,data_base

data_editor	bsr     prep_data
                clr.w   hi_lo_flag
                bsr     d_cursor

again_d_edit	move.b  key,D0

                cmpi.w  #2,mouseflags        ;<ESC> ?
                bne     no_ed_exit
                bsr     wait_mouse_rel
                bra     exit_d_edit

no_ed_exit	cmpi.b  #$4b,D0
                beq     flip_curs
                cmpi.b  #$4d,D0
                bne     no_flip

flip_curs	bsr     d_cursor
                bsr     waitrelease
                bra     again_d_edit

no_flip		cmpi.b  #$50,D0
                bne     no_down_ed

                lea     data_y,A0
                cmpi.w  #15,(A0)
                bge     no_more_dat_down

                addq.w  #1,(A0)
                bsr     data_scroll_up

no_more_dat_down 
                bsr     waitrelease
                bra     again_d_edit

no_down_ed	cmpi.b  #$48,D0
                bne     no_up_ed

                lea     data_y,A0
                tst.w   (A0)
                ble     no_more_dat_up

                subq.w  #1,(A0)
                bsr     data_scroll_down

no_more_dat_up	bsr     waitrelease
                bra     again_d_edit

no_up_ed	bsr     enter_hex            ;Check for any hexdecimal input
                tst.b   D3
                bmi     again_d_edit

                movea.l data_base,A0
                move.w  data_y,D0
                lea     0(A0,D0.w),A0

                tst.w   hi_lo_flag
                beq     low_edit

                lsl.w   #4,D3
                andi.b  #$0f,(A0)
                or.b    D3,(A0)
                bra     data_ready

low_edit	andi.b  #$f0,(A0)
                or.b    D3,(A0)

data_ready	move.b  (A0),D0
                lea     dummy,A1
                move.l  D0,-(SP)
                move.w  #2,-(SP)
                pea     (A1)
                bsr     hex_convert
                lea     10(SP),SP
                clr.b   2(A1)

                movea.l screen_1,A2
                lea     1280*22(A2),A2

                pea     (A1)
                pea     17(A2)
                bsr     PrintLine
                addq.l  #8,SP

                bsr     waitrelease

                bra     again_d_edit

exit_d_edit	rts

*** 'Block options'

clear_track	movea.l curr_patt_base,A0

                move.w  channel_pos,D1   ;which channel to erase?
                lsl.w   #2,D1
                lea     0(A0,D1.w),A0

                moveq   #63,D0

kill_track	clr.l   (A0)
                lea     12(A0),A0
                dbra    D0,kill_track

                rts

;=====================================================================

*** 'Data Editing'

data_scroll_up	movea.l screen_1,A0
                lea     1280*20+16(A0),A0
                lea     1280(A0),A1

                moveq   #8*4-1,D0

move_data_up	move.b  1(A1),1(A0)
                move.b  8(A1),8(A0)
                lea     160(A0),A0
                lea     160(A1),A1
                dbra    D0,move_data_up

                movea.l data_base,A0
                lea     dummy,A1

                movea.l screen_1,A2
                lea     1280*24(A2),A2

                move.w  data_y,D0
                cmpi.w  #15-2,D0
                bgt     empty_data

                addq.w  #2,D0
                lea     0(A0,D0.w),A0
                move.b  (A0),D1              ;data
                move.l  D1,-(SP)
                move.w  #2,-(SP)
                pea     (A1)
                bsr     hex_convert
                lea     10(SP),SP
                clr.b   2(A1)

                pea     (A1)
                pea     17(A2)
                bsr     PrintLine
                addq.l  #8,SP
                rts

data_scroll_down 
                movea.l screen_1,A0
                lea     1280*25+16-160(A0),A0
                lea     -1280(A0),A1

                moveq   #8*4-1,D0

move_data_down	move.b  1(A1),1(A0)
                move.b  8(A1),8(A0)
                lea     -160(A0),A0
                lea     -160(A1),A1
                dbra    D0,move_data_down

                movea.l data_base,A0
                lea     dummy,A1

                movea.l screen_1,A2
                lea     1280*20(A2),A2

                move.w  data_y,D0
                cmpi.w  #2,D0
                blt     empty_data

                subq.w  #2,D0
                lea     0(A0,D0.w),A0
                move.b  (A0),D1              ;data
                move.l  D1,-(SP)
                move.w  #2,-(SP)
                pea     (A1)
                bsr     hex_convert
                lea     10(SP),SP
                clr.b   2(A1)

                pea     (A1)
                pea     17(A2)
                bsr     PrintLine
                addq.l  #8,SP
                rts

empty_data	move.l  #$20200000,(A1)
                pea     (A1)
                pea     17(A2)
                bsr     PrintLine
                addq.l  #8,SP
                rts

prep_data	movea.l screen_1,A2
                lea     20*1280(A2),A2
                lea     dummy,A1
                bsr     empty_data
                lea     1280(A2),A2
                bsr     empty_data
                lea     1280(A2),A2

                movea.l data_base,A0

                moveq   #2,D7

print_data	move.b  (A0)+,D0
                move.l  D0,-(SP)
                move.w  #2,-(SP)
                pea     (A1)
                bsr     hex_convert
                lea     10(SP),SP

                clr.b   2(A1)                ;end of string

                pea     (A1)
                pea     17(A2)
                bsr     PrintLine
                addq.l  #8,SP
                lea     1280(A2),A2

                dbra    D7,print_data

                clr.w   data_y

                rts

*** 'Pattern Scrolling'

patt_scroll_up	lea     patt_pos,A0
                subq.w  #1,(A0)
                andi.w  #$3f,(A0)
                cmpi.w  #$3f,(A0)
                bne     ok_scroll_up
                bsr     patt_bottom
                rts

ok_scroll_up	movea.l screen_1,A0
                lea     2(A0),A0             ;plane 1
                lea     8*1280+7*160(A0),A0
                lea     1280(A0),A1
                moveq   #8*8-1,D0

move_line	move.b  1(A0),1(A1)
                move.b  8(A0),8(A1)

                move.b  17(A0),17(A1)
                move.b  24(A0),24(A1)
                move.b  25(A0),25(A1)
                move.b  33(A0),33(A1)
                move.b  40(A0),40(A1)
                move.b  48(A0),48(A1)
                move.b  49(A0),49(A1)
                move.b  56(A0),56(A1)

o               SET 48

                move.b  17+o(A0),17+o(A1)
                move.b  24+o(A0),24+o(A1)
                move.b  25+o(A0),25+o(A1)
                move.b  33+o(A0),33+o(A1)
                move.b  40+o(A0),40+o(A1)
                move.b  48+o(A0),48+o(A1)
                move.b  49+o(A0),49+o(A1)
                move.b  56+o(A0),56+o(A1)

o               SET 96

                move.b  17+o(A0),17+o(A1)
                move.b  24+o(A0),24+o(A1)
                move.b  25+o(A0),25+o(A1)
                move.b  33+o(A0),33+o(A1)
                move.b  40+o(A0),40+o(A1)
                move.b  48+o(A0),48+o(A1)
                move.b  49+o(A0),49+o(A1)
                move.b  56+o(A0),56+o(A1)

                lea     -160(A0),A0
                lea     -160(A1),A1
                dbra    D0,move_line

                movea.l screen_1,A1
                lea     2+1280(A1),A1

                move.w  patt_pos,D0
                subq.w  #4,D0
                move.w  D0,D1
                bmi     borders1
                mulu    #4*3,D0              ;real position in pattern

                movea.l curr_patt_base,A2
                lea     0(A2,D0.w),A2        ;exact position

                bsr     display_line
                rts

borders1	bsr     border_line
                rts

patt_scroll_down 
                lea     patt_pos,A0
                addq.w  #1,(A0)
                andi.w  #$3f,(A0)
                tst.w   (A0)
                bne     ok_scroll_down
                bsr     patt_top
                rts

ok_scroll_down	movea.l screen_1,A1
                lea     2(A1),A1             ;plane 1
                lea     1280(A1),A1
                lea     1280(A1),A0
                moveq   #8*8-1,D0

move_line2	move.b  1(A0),1(A1)
                move.b  8(A0),8(A1)

                move.b  17(A0),17(A1)
                move.b  24(A0),24(A1)
                move.b  25(A0),25(A1)
                move.b  33(A0),33(A1)
                move.b  40(A0),40(A1)
                move.b  48(A0),48(A1)
                move.b  49(A0),49(A1)
                move.b  56(A0),56(A1)

o               SET 48

                move.b  17+o(A0),17+o(A1)
                move.b  24+o(A0),24+o(A1)
                move.b  25+o(A0),25+o(A1)
                move.b  33+o(A0),33+o(A1)
                move.b  40+o(A0),40+o(A1)
                move.b  48+o(A0),48+o(A1)
                move.b  49+o(A0),49+o(A1)
                move.b  56+o(A0),56+o(A1)

o               SET 96

                move.b  17+o(A0),17+o(A1)
                move.b  24+o(A0),24+o(A1)
                move.b  25+o(A0),25+o(A1)
                move.b  33+o(A0),33+o(A1)
                move.b  40+o(A0),40+o(A1)
                move.b  48+o(A0),48+o(A1)
                move.b  49+o(A0),49+o(A1)
                move.b  56+o(A0),56+o(A1)

                lea     160(A0),A0
                lea     160(A1),A1
                dbra    D0,move_line2

                movea.l screen_1,A1
                lea     2+1280*9(A1),A1

                move.w  patt_pos,D0
                addq.w  #4,D0
                move.w  D0,D1
                cmpi.w  #63,D0
                bhi     borders2
                mulu    #4*3,D0              ;real position in pattern

                movea.l curr_patt_base,A2
                lea     0(A2,D0.w),A2        ;exact position
                bsr     display_line

                rts

borders2	bsr     border_line
                rts

set_patt	move.w  patt_pos,D6
                movea.l screen_1,A1
                lea     2+1280(A1),A1

                moveq   #8,D7                ;number of displayed lines

next_line	cmpi.w  #4,D6
                blt     its_empty
                cmpi.w  #$44,D6
                blt     no_empty

its_empty	bsr     border_line
                addq.w  #1,D6
                bra     end_of_disp

no_empty	movea.l mod,A2
                adda.l  $10(A2),A2           ;a2 - pointer on patterns
                move.w  current_patt,D2
                mulu    #4*3*64,D2
                lea     0(A2,D2.w),A2        ;a2 - current pattern base

                move.w  D6,D1
                subq.w  #4,D1
                move.w  D1,D2
                mulu    #4*3,D2
                lea     0(A2,D2.w),A2

                bsr     display_line
                lea     16+1280-160(A1),A1
                addq.w  #1,D6

end_of_disp	dbra    D7,next_line

                rts

patt_top	clr.w   patt_pos

                movea.l screen_1,A1
                lea     2+1280(A1),A1

                bsr     border_line
                bsr     border_line
                bsr     border_line
                bsr     border_line

                movea.l mod,A2
                adda.l  $10(A2),A2           ;a2 - pointer on patterns
                move.w  current_patt,D2
                mulu    #4*3*64,D2
                lea     0(A2,D2.w),A2        ;a2 - current pattern base
                move.l  A2,curr_patt_base

                moveq   #0,D1
                bsr     display_line
                lea     16+1280-160(A1),A1
                moveq   #1,D1
                bsr     display_line
                lea     16+1280-160(A1),A1
                moveq   #2,D1
                bsr     display_line
                lea     16+1280-160(A1),A1
                moveq   #3,D1
                bsr     display_line
                lea     16+1280-160(A1),A1
                moveq   #4,D1
                bsr     display_line

                rts

patt_bottom	movea.l screen_1,A1
                lea     2+1280(A1),A1

                movea.l mod,A2
                adda.l  $10(A2),A2           ;a2 - pointer on patterns
                move.w  current_patt,D2
                mulu    #4*3*64,D2
                lea     0(A2,D2.w),A2        ;a2 - current pattern base
                move.l  A2,curr_patt_base
                lea     4*3*$3b(A2),A2

                moveq   #$3b,D1
                bsr     display_line
                lea     16+1280-160(A1),A1
                moveq   #$3c,D1
                bsr     display_line
                lea     16+1280-160(A1),A1
                moveq   #$3d,D1
                bsr     display_line
                lea     16+1280-160(A1),A1
                moveq   #$3e,D1
                bsr     display_line
                lea     16+1280-160(A1),A1
                moveq   #$3f,D1
                bsr     display_line
                lea     16+1280-160(A1),A1

                bsr     border_line
                bsr     border_line
                bsr     border_line
                bsr     border_line
                rts

border_line	movem.l D0-D1,-(SP)
                moveq   #7,D0

empty_lines	clr.b   1(A1)
                clr.b   8(A1)
                moveq   #2,D1

tracks_1	clr.b   17(A1)
                clr.b   24(A1)
                clr.b   25(A1)
                clr.b   33(A1)
                clr.b   40(A1)
                clr.b   48(A1)
                clr.b   49(A1)
                clr.b   56(A1)
                lea     48(A1),A1
                dbra    D1,tracks_1
                lea     16(A1),A1
                dbra    D0,empty_lines
                movem.l (SP)+,D0-D1
                rts

display_line	lea     dummy,A3
                move.l  D1,-(SP)
                move.w  #2,-(SP)
                pea     (A3)
                bsr     hex_convert
                lea     10(SP),SP
                clr.b   2(A3)
                pea     (A3)
                pea     1(A1)
                bsr     PrintLine
                addq.l  #8,SP

                moveq   #2,D1

track_loop	move.b  (A2)+,D0             ;d0 - note
                andi.w  #$7f,D0
                add.w   D0,D0
                add.w   D0,D0
                lea     noten,A3
                pea     0(A3,D0.w)           ;note as a string
                pea     17(A1)
                bsr     PrintLine
                addq.l  #8,SP

                move.b  (A2)+,D0             ;d0 - instrument
                andi.w  #$1f,D0
                move.l  D0,-(SP)
                move.w  #2,-(SP)
                pea     dummy(PC)
                bsr     hex_convert
                lea     10(SP),SP
                lea     dummy,A0
                clr.b   2(A0)
                pea     (A0)
                pea     33(A1)
                bsr     PrintLine
                addq.l  #8,SP

                move.b  (A2)+,D0             ;d0 - effect
                andi.w  #$0f,D0
                move.l  D0,-(SP)
                move.w  #1,-(SP)
                pea     dummy(PC)
                bsr     hex_convert
                lea     10(SP),SP
                lea     dummy,A0
                clr.b   1(A0)
                pea     (A0)
                pea     48(A1)
                bsr     PrintLine
                addq.l  #8,SP

                move.b  (A2)+,D0             ;d0 - value
                andi.w  #$ff,D0
                move.l  D0,-(SP)
                move.w  #2,-(SP)
                pea     dummy(PC)
                bsr     hex_convert
                lea     10(SP),SP
                lea     dummy,A0
                clr.b   2(A0)
                pea     (A0)
                pea     49(A1)
                bsr     PrintLine
                addq.l  #8,SP

                lea     48(A1),A1

                dbra    D1,track_loop

                rts
;-----------------
*** 'Cursor Movement'

cursor_left	movea.l screen_1,A0
                lea     5*1280(A0),A0
                move.w  old_c_pos,D0
                lea     0(A0,D0.w),A1
                moveq   #7,D0

clear_cursor	clr.b   (A1)
                lea     160(A1),A1
                dbra    D0,clear_cursor

                lea     cursor_pos,A1
                lea     channel_pos,A2
                tst.w   (A1)
                bne     ok_c_left
                tst.w   (A2)
                bne     ok_chan_left
                move.w  #3,(A2)

ok_chan_left	subq.w  #1,(A2)
                move.w  #6,(A1)

ok_c_left	subq.w  #1,(A1)

                move.w  (A2),D0
                add.w   D0,D0
                lea     channel_tab,A3
                move.w  0(A3,D0.w),D1
                move.w  (A1),D0
                add.w   D0,D0
                lea     position_tab,A3
                add.w   0(A3,D0.w),D1
                lea     0(A0,D1.w),A0
                move.w  D1,old_c_pos
                moveq   #7,D0

draw_cursor	move.b  #$ff,(A0)
                lea     160(A0),A0
                dbra    D0,draw_cursor

                rts

cursor_right	movea.l screen_1,A0
                lea     5*1280(A0),A0
                move.w  old_c_pos,D0
                lea     0(A0,D0.w),A1
                moveq   #7,D0

clear_cursor2	clr.b   (A1)
                lea     160(A1),A1
                dbra    D0,clear_cursor2

                lea     cursor_pos,A1
                lea     channel_pos,A2
                cmpi.w  #5,(A1)
                bne     ok_c_right
                cmpi.w  #2,(A2)
                bne     ok_chan_right
                move.w  #-1,(A2)

ok_chan_right	addq.w  #1,(A2)
                move.w  #-1,(A1)

ok_c_right	addq.w  #1,(A1)

                move.w  (A2),D0
                add.w   D0,D0
                lea     channel_tab,A3
                move.w  0(A3,D0.w),D1
                move.w  (A1),D0
                add.w   D0,D0
                lea     position_tab,A3
                add.w   0(A3,D0.w),D1
                lea     0(A0,D1.w),A0
                move.w  D1,old_c_pos
                moveq   #7,D0

draw_cursor2	move.b  #$ff,(A0)
                lea     160(A0),A0
                dbra    D0,draw_cursor2

                rts

d_cursor	movea.l screen_1,A0
                lea     1280*22+19(A0),A0
                lea     hi_lo_flag,A1
                eori.w  #1,(A1)
                tst.w   (A1)
                beq     low_curs

                REPT 8
                clr.b   7(A0)
                move.b  #-1,(A0)
                lea     160(A0),A0
                ENDR
                rts

low_curs
		REPT 8
                clr.b   (A0)
                move.b  #-1,7(A0)
                lea     160(A0),A0
                ENDR
                rts

*** 'Keyboard'

keyboard	cmpi.b  #$10,D0              ;C 2 ?
                beq     sure_c2
                cmpi.b  #$33,D0              ;C 2 ?
                bne     not_c2

sure_c2		move.w  #13,note_key
                bsr     process_note
                bsr     waitrelease
                bra     not_b1

not_c2		cmpi.b  #$03,D0              ;C#2 ?
                beq     sure_cis2
                cmpi.b  #$26,D0              ;C#2 ?
                bne     not_cis2

sure_cis2	move.w  #14,note_key
                bsr     process_note
                bsr     waitrelease
                bra     not_b1

not_cis2	cmpi.b  #$34,D0              ;D 2 ?
                beq     sure_d2
                cmpi.b  #$11,D0              ;D 2 ?
                bne     not_d2

sure_d2		move.w  #15,note_key
                bsr     process_note
                bsr     waitrelease
                bra     not_b1

not_d2		cmpi.b  #$27,D0              ;D#2 ?
                beq     sure_dis2
                cmpi.b  #$04,D0              ;D#2 ?
                bne     not_dis2

sure_dis2	move.w  #16,note_key
                bsr     process_note
                bsr     waitrelease
                bra     not_b1

not_dis2	cmpi.b  #$35,D0              ;E 2 ?
                beq     sure_e2
                cmpi.b  #$12,D0              ;E 2 ?
                bne     not_e2

sure_e2		move.w  #17,note_key
                bsr     process_note
                bsr     waitrelease
                bra     not_b1

not_e2		cmpi.b  #$13,D0              ;F 2 ?
                bne     not_f2
                move.w  #18,note_key
                bsr     process_note
                bsr     waitrelease
                bra     not_b1

not_f2		cmpi.b  #$06,D0              ;F#2 ?
                bne     not_fis2
                move.w  #19,note_key
                bsr     process_note
                bsr     waitrelease
                bra     not_b1

not_fis2	cmpi.b  #$14,D0              ;G 2 ?
                bne     not_g2
                move.w  #20,note_key
                bsr     process_note
                bsr     waitrelease
                bra     not_b1

not_g2		cmpi.b  #$07,D0              ;G#2 ?
                bne     not_gis2
                move.w  #21,note_key
                bsr     process_note
                bsr     waitrelease
                bra     not_b1

not_gis2	cmpi.b  #$15,D0              ;A 2 ?
                bne     not_a2
                move.w  #22,note_key
                bsr     process_note
                bsr     waitrelease
                bra     not_b1

not_a2		cmpi.b  #$08,D0              ;A#2 ?
                bne     not_ais2
                move.w  #23,note_key
                bsr     process_note
                bsr     waitrelease
                bra     not_b1

not_ais2	cmpi.b  #$16,D0              ;B 2 ?
                bne     not_b2
                move.w  #24,note_key
                bsr     process_note
                bsr     waitrelease
                bsr     not_b1

not_b2		cmpi.b  #$17,D0              ;C 3 ?
                bne     not_c3
                move.w  #25,note_key
                bsr     process_note
                bsr     waitrelease
                bra     not_b1

not_c3		cmpi.b  #$0a,D0              ;C#3 ?
                bne     not_cis3
                move.w  #26,note_key
                bsr     process_note
                bsr     waitrelease
                bra     not_b1

not_cis3	cmpi.b  #$18,D0              ;D 3 ?
                bne     not_d3
                move.w  #27,note_key
                bsr     process_note
                bsr     waitrelease
                bra     not_b1

not_d3		cmpi.b  #$0b,D0              ;D#3 ?
                bne     not_dis3
                move.w  #28,note_key
                bsr     process_note
                bsr     waitrelease
                bra     not_b1

not_dis3	cmpi.b  #$19,D0              ;E 3 ?
                bne     not_e3
                move.w  #29,note_key
                bsr     process_note
                bsr     waitrelease
                bra     not_b1

not_e3		cmpi.b  #$1a,D0              ;F 3 ?
                bne     not_f3
                move.w  #30,note_key
                bsr     process_note
                bsr     waitrelease
                bra     not_b1

not_f3		cmpi.b  #$0d,D0              ;F#3 ?
                bne     not_fis3
                move.w  #31,note_key
                bsr     process_note
                bsr     waitrelease
                bra     not_b1

not_fis3	cmpi.b  #$1b,D0              ;G 3 ?
                bne     not_g3
                move.w  #32,note_key
                bsr     process_note
                bsr     waitrelease
                bra     not_b1

not_g3		cmpi.b  #$2c,D0              ;C 1 ?
                bne     not_c1
                move.w  #1,note_key
                bsr     process_note
                bsr     waitrelease
                bra     not_b1

not_c1		cmpi.b  #$1f,D0              ;C#1 ?
                bne     not_cis1
                move.w  #2,note_key
                bsr     process_note
                bsr     waitrelease
                bra     not_b1

not_cis1	cmpi.b  #$2d,D0              ;D 1 ?
                bne     not_d1
                move.w  #3,note_key
                bsr     process_note
                bsr     waitrelease
                bra     not_b1

not_d1		cmpi.b  #$20,D0              ;D#1 ?
                bne     not_dis1
                move.w  #4,note_key
                bsr     process_note
                bsr     waitrelease
                bra     not_b1

not_dis1	cmpi.b  #$2e,D0              ;E 1 ?
                bne     not_e1
                move.w  #5,note_key
                bsr     process_note
                bsr     waitrelease
                bra     not_b1

not_e1		cmpi.b  #$2f,D0              ;F 1 ?
                bne     not_f1
                move.w  #6,note_key
                bsr     process_note
                bsr     waitrelease
                bra     not_b1

not_f1		cmpi.b  #$22,D0              ;F#1 ?
                bne     not_fis1
                move.w  #7,note_key
                bsr     process_note
                bsr     waitrelease
                bra     not_b1

not_fis1	cmpi.b  #$30,D0              ;G 1 ?
                bne     not_g1
                move.w  #8,note_key
                bsr     process_note
                bsr     waitrelease
                bra     not_b1

not_g1		cmpi.b  #$23,D0              ;G#1 ?
                bne     not_gis1
                move.w  #9,note_key
                bsr     process_note
                bsr     waitrelease
                bra     not_b1

not_gis1	cmpi.b  #$31,D0              ;A 1 ?
                bne     not_a1
                move.w  #10,note_key
                bsr     process_note
                bsr     waitrelease
                bra     not_b1

not_a1		cmpi.b  #$24,D0              ;A#1 ?
                bne     not_ais1
                move.w  #11,note_key
                bsr     process_note
                bsr     waitrelease
                bra     not_b1

not_ais1	cmpi.b  #$0e,D0
                bne     no_space_bs
		tst.w	edit_flag
		beq	no_space_bs

                move.w  #0,note_key          ;backSPACE!
end_bodge
                bsr     skippy
                bsr     waitrelease
                bra     not_b1

no_space_bs	cmpi.b  #$32,D0              ;B 1 ?
                bne     not_b1
                move.w  #12,note_key
                bsr     process_note
                bsr     waitrelease

not_b1		rts

*** 'Enter Hexadecimal'

enter_hex	moveq   #-1,D3
                cmpi.b  #$02,D0
                blt     no_number_key
                cmpi.b  #$0b,D0
                bgt     no_number_key
                move.b  D0,D3
                subq.b  #1,D3
                cmpi.b  #$0a,D3
                bne     ok_number
                moveq   #0,D3

ok_number	bra     end_hex

no_number_key	cmpi.b  #$1e,D0
                bne     no_a
                moveq   #$0a,D3
                bra     end_hex

no_a		cmpi.b  #$30,D0
                bne     no_b
                moveq   #$0b,D3
                bra     end_hex

no_b		cmpi.b  #$2e,D0
                bne     no_c
                moveq   #$0c,D3
                bra     end_hex

no_c		cmpi.b  #$20,D0
                bne     no_d
                moveq   #$0d,D3
                bra     end_hex

no_d		cmpi.b  #$12,D0
                bne     no_e
                moveq   #$0e,D3
                bra     end_hex

no_e		cmpi.b  #$21,D0
                bne     end_hex
                moveq   #$0f,D3

end_hex		rts

*** 'Process Note, Instrument & FX'

process_note	
		lea	channel_pos,a1
		move.w	(a1),d1
		tst.w	d1
		bne.s	skippy

                movea.l mod,A3

                move.w  instrument,D1
		lsl.w	#1,d1
                adda.l  (A3),A3
                move.w  0(A3,D1.w),D1
                lea     0(A3,D1.w),A3        ;a3 - address of instrument
		move.b	(a3),d1		;get inst type
		cmp.b	#5,d1
		bne.s	.testmore
		rts
.testmore	cmp.b	#8,d1
		blt.s	skippy
		rts		
skippy		
		bsr     just_play_it
                tst.w   edit_flag
                bne     come_on_edit
                rts

come_on_edit	
;		move.w	#$777,$ffff8240
		bsr     calc_pos

                move.w  D2,D3

                tst.w   note_key
                bne     ok_note_process

;		move.l	a1,-(sp)
		lea	channel_pos,a1
		move.w	(a1),d1

		tst.w	d1
		bne	no_silence_chan1

		lea     track1_data,A1   ;necessary to switch off
                move.b  #$3f,$11(A1)         ;"real-time" channel
                clr.b   $06(A1)
                moveq   #0,D1
                moveq   #0,D2
;		move.l	(sp)+,a1
                bra     edit_note

no_silence_chan1
		cmp.w	#1,d1
		bne	no_silence_chan2
		lea     track2_data,A1   ;necessary to switch off
                move.b  #$3f,$11(A1)         ;"real-time" channel
                clr.b   $06(A1)
                moveq   #0,D1
                moveq   #0,D2
;		move.l	(sp)+,a1
                bra     edit_note
no_silence_chan2
		lea     track3_data,A1   ;necessary to switch off
                move.b  #$3f,$11(A1)         ;"real-time" channel
                clr.b   $06(A1)
                moveq   #0,D1
                moveq   #0,D2
;		move.l	(sp)+,a1

                moveq   #0,D1
                moveq   #0,D2
                bra     edit_note

ok_note_process	move.w  octave,D1
                mulu    #12,D1
                add.w   note_key,D1

                move.w  instrument,D2

edit_note	andi.w  #$7f,D1
                move.b  D1,(A0)
                move.b  D2,1(A0)

                movea.l screen_1,A1
                lea     2+5*1280(A1),A1

                move.w  D3,D1

                bsr     display_line

		tst.w	play_flag
		bne.s	.skip

                bsr     patt_scroll_down
.skip
                rts

process_instr	bsr     calc_pos

                cmpi.w  #1,cursor_pos
                bgt     lower_digit
                cmpi.b  #1,D3
                bgt     overflow_instr

                lsl.b   #4,D3

                andi.b  #$0f,1(A0)
                or.b    D3,1(A0)
                bra     keep_it_going

lower_digit	andi.w  #$0f,D3
                andi.b  #$10,1(A0)
                or.b    D3,1(A0)

keep_it_going	movea.l screen_1,A1
                lea     2+5*1280(A1),A1

                move.w  D2,D1

                bsr     display_line

                bsr     patt_scroll_down

overflow_instr	rts

process_value	bsr     calc_pos

                cmpi.w  #4,cursor_pos
                bgt     lower_digit2

                lsl.b   #4,D3

                andi.b  #$0f,3(A0)
                or.b    D3,3(A0)
                bra     keep_it_going2

lower_digit2	andi.w  #$0f,D3
                andi.b  #$f0,3(A0)
                or.b    D3,3(A0)

keep_it_going2	movea.l screen_1,A1
                lea     2+5*1280(A1),A1

                move.w  D2,D1

                bsr     display_line

                bsr     patt_scroll_down
                rts

process_effect	bsr     calc_pos

                andi.w  #$0f,D3
                move.b  D3,2(A0)

                movea.l screen_1,A1
                lea     2+5*1280(A1),A1

                move.w  D2,D1

                bsr     display_line
                bsr     patt_scroll_down

                rts

calc_pos	movea.l curr_patt_base,A0
                move.w  patt_pos,D0
                move.w  D0,D2
                mulu    #4*3,D0

                lea     0(A0,D0.w),A2

                move.w  channel_pos,D1   ;channel * 4 Bytes per Track
                add.w   D1,D1
                add.w   D1,D1
                add.w   D1,D0

                lea     0(A0,D0.w),A0        ;a0 - pointer to right patt. pos

                rts

*** 'Displays'

display_position 
                movea.l screen_1,A1
                lea     1280*12(A1),A1

                lea     dummy,A3

                move.w  current_pos,D0
                andi.w  #$ff,D0

                move.l  D0,-(SP)
                move.w  #2,-(SP)
                pea     (A3)
                bsr     hex_convert
                lea     10(SP),SP

                clr.b   2(A3)

                pea     (A3)
                pea     1(A1)
                bsr     PrintLine
                addq.l  #8,SP

                movea.l mod,A0
                adda.l  $0c(A0),A0           ;seq. tab

                move.b  0(A0,D0.w),D0        ;d0 - seq. number
                andi.w  #$ff,D0

                movea.l mod,A0
                adda.l  $10(A0),A0           ;a2 - pointer on patterns
                move.w  D0,D2
                mulu    #4*3*64,D2
                lea     0(A2,D2.w),A2        ;a2 - current pattern base
                move.l  A2,curr_patt_base

                move.w  D0,current_patt

                move.l  D0,-(SP)
                move.w  #2,-(SP)
                pea     (A3)
                bsr     hex_convert
                lea     10(SP),SP

                clr.b   2(A3)

                pea     (A3)
                pea     17(A1)
                bsr     PrintLine
                addq.l  #8,SP

                bsr     patt_top

                rts


display_instrument 
                movea.l screen_1,A1
                lea     1280*15(A1),A1

                lea     dummy,A3

                move.w  instrument,D0
                andi.w  #$1f,D0

                move.l  D0,-(SP)
                move.w  #2,-(SP)
                pea     (A3)
                bsr     hex_convert
                lea     10(SP),SP

                clr.b   2(A3)

                pea     (A3)
                pea     1(A1)
                bsr     PrintLine
                addq.l  #8,SP

                tst.w   D0
                beq     instr_zero

                movea.l mod,A0
                adda.l  (A0),A0              ;instr. tab

                add.w   D0,D0
                move.w  0(A0,D0.w),D0        ;d0 - instr. offset
                lea     0(A0,D0.w),A0        ;a0 - pointer on instrument
                move.b  3(A0),D0             ;d0 - volume
                andi.w  #$0f,D0

instr_zero	move.l  D0,-(SP)
                move.w  #2,-(SP)
                pea     (A3)
                bsr     hex_convert
                lea     10(SP),SP

                clr.b   2(A3)

                pea     (A3)
                pea     17(A1)
                bsr     PrintLine
                addq.l  #8,SP

                bsr     draw_wave

                rts

display_len_rst	movea.l screen_1,A1
                lea     1280*18(A1),A1

                lea     dummy,A3

                movea.l mod,A0
                move.b  $14(A0),D0

                move.l  D0,-(SP)
                move.w  #2,-(SP)
                pea     (A3)
                bsr     hex_convert
                lea     10(SP),SP

                clr.b   2(A3)

                pea     (A3)
                pea     1(A1)
                bsr     PrintLine
                addq.l  #8,SP

                move.b  $15(A0),D0
                move.l  D0,-(SP)
                move.w  #2,-(SP)
                pea     (A3)
                bsr     hex_convert
                lea     10(SP),SP

                clr.b   2(A3)

                pea     (A3)
                pea     17(A1)
                bsr     PrintLine
                addq.l  #8,SP

                rts

display_octave	movea.l screen_1,A1
                lea     1280*21(A1),A1

                lea     dummy,A3

                move.w  octave,D0

                move.l  D0,-(SP)
                move.w  #2,-(SP)
                pea     (A3)
                bsr     hex_convert
                lea     10(SP),SP

                clr.b   2(A3)

                pea     (A3)
                pea     1(A1)
                bsr     PrintLine
                addq.l  #8,SP

                rts

display_wavedata 
                movea.l screen_1,A1
                lea     1280*23(A1),A1

                movea.l mod,A0
                adda.l  (A0),A0
                move.w  instrument,D0
                add.w   D0,D0
                move.w  0(A0,D0.w),D0
                lea     0(A0,D0.w),A0

                lea     dummy,A3

                move.b  (A0)+,D0             ;type of instrument

                move.l  D0,-(SP)
                move.w  #2,-(SP)
                pea     (A3)
                bsr     hex_convert
                lea     10(SP),SP

                clr.b   2(A3)

                pea     (A3)
                pea     41(A1)
                bsr     PrintLine
                addq.l  #8,SP

                move.b  (A0)+,D0             ;arpeggio number

                move.l  D0,-(SP)
                move.w  #2,-(SP)
                pea     (A3)
                bsr     hex_convert
                lea     10(SP),SP

                clr.b   2(A3)

                pea     (A3)
                pea     57(A1)
                bsr     PrintLine
                addq.l  #8,SP

                move.b  (A0)+,D0             ;noise number

                move.l  D0,-(SP)
                move.w  #2,-(SP)
                pea     (A3)
                bsr     hex_convert
                lea     10(SP),SP

                clr.b   2(A3)

                pea     (A3)
                pea     73(A1)
                bsr     PrintLine
                addq.l  #8,SP

                addq.l  #1,A0

                move.b  (A0),D0              ;speed

                move.l  D0,-(SP)
                move.w  #2,-(SP)
                pea     (A3)
                bsr     hex_convert
                lea     10(SP),SP

                clr.b   2(A3)

                pea     (A3)
                pea     89(A1)
                bsr     PrintLine
                addq.l  #8,SP

                rts

just_play_it	
		tst.w	play_flag
		bne.s	skip_clear

		lea     track1_data,A1   ;necessary to switch off
                move.b  #$3f,$11(A1)         ;"real-time" channel
                clr.b   $06(A1)
		lea     track2_data,A1   ;necessary to switch off
                move.b  #$3f,$11(A1)         ;"real-time" channel
                clr.b   $06(A1)

		lea     track3_data,A1   ;necessary to switch off
                move.b  #$3f,$11(A1)         ;"real-time" channel
                clr.b   $06(A1)

                clr.b   $fffffa19.w
                andi.b  #$f0,$fffffa1d.w

                move.l  #$07ffffff,$ffff8800.w
                move.l  #$08ff00ff,$ffff8800.w
                move.l  #$09ff00ff,$ffff8800.w
                move.l  #$0aff00ff,$ffff8800.w


skip_clear

		move.w	patt_pos,d0
		mulu	#4*3,d0
		movea.l	curr_patt_base,a0
		lea	(a0,d0.w),a0	;get exact position in mod


		lea	dummy_track,a2
		
		move.l	#0,(a2)
		move.l	#0,4(a2)
		move.l	#0,8(a2)
		
		tst.w	edit_flag
		beq.s	.skip

		move.l	(a0)+,(a2)
		move.l	(a0)+,4(a2)
		move.l	(a0)+,8(a2)
	
.skip
		lea	channel_pos,a0	
		move.w	(a0),d0		;get channel column
		lsl.w	#2,d0		;x4 for offset
		lea	(a2,d0.w),a2	;point to correct channel in dummy

                move.w  octave,D0
                mulu    #12,D0
                move.w  note_key,D1
;                beq     sound_off
                add.w   D1,D0
                andi.w  #$7f,D0
                move.b  D0,(A2)		;put note key
                move.w  instrument,D0
                move.b  D0,1(A2)	;put instrument number

                clr.w   2(A2)		;clear data
		

		lea	dummy_track,a2
		lea     player_data,A0

		lea     track1_data,A1
                bsr     pattern_check
                lea     track2_data,A1
                bsr     pattern_check
		lea     track3_data,A1
                bsr     pattern_check
		rts


*** 'HEX Converter'

* Hex Converter  Wert (.l), LÑnge-1 (.w) & Zieladresse (.l) auf den Stack
*                packen, dann nach 'hex_convert' springen sowie lea 10(sp),sp.

hex_convert	movem.l D0-D2/A0-A1,-(SP)
                move.l  30(SP),D0
                move.w  28(SP),D2
                beq     exit_hc
                movea.l 24(SP),A0
                subq.w  #1,D2
                lea     1(A0,D2.w),A0
                lea     conv_tab,A1

con2		move.w  D0,D1
                andi.w  #$0f,D1
                move.b  0(A1,D1.w),-(A0)
                lsr.l   #4,D0
                dbra    D2,con2

exit_hc		movem.l (SP)+,D0-D2/A0-A1
                rts

*** 'Char Output'

PrintLine	movem.l D7-A2,-(SP)
                movea.l 20(SP),A0
                movea.l 24(SP),A1
                lea     font,A2
                move.l  A0,D7
                btst    #0,D7
                bne     uneven

nextchar	moveq   #0,D7
                move.b  (A1)+,D7
                beq     exit_print
                lsl.w   #4,D7
                move.b  0(A2,D7.w),(A0)
                move.b  1(A2,D7.w),160(A0)
                move.b  2(A2,D7.w),320(A0)
                move.b  3(A2,D7.w),480(A0)
                move.b  4(A2,D7.w),640(A0)
                move.b  5(A2,D7.w),800(A0)
                move.b  6(A2,D7.w),960(A0)
                move.b  7(A2,D7.w),1120(A0)
                addq.l  #1,A0

uneven		moveq   #0,D7
                move.b  (A1)+,D7
                beq     exit_print
                lsl.w   #4,D7
                move.b  0(A2,D7.w),(A0)
                move.b  1(A2,D7.w),160(A0)
                move.b  2(A2,D7.w),320(A0)
                move.b  3(A2,D7.w),480(A0)
                move.b  4(A2,D7.w),640(A0)
                move.b  5(A2,D7.w),800(A0)
                move.b  6(A2,D7.w),960(A0)
                move.b  7(A2,D7.w),1120(A0)
                addq.l  #7,A0
                bra     nextchar

exit_print	movem.l (SP)+,D7-A2
                rts

*** 'Box'

box_draw	movem.l D0-D6/A0-A2,-(SP)
                bsr     restore_back
                movea.l screen_1,A1
                lea     box_x1,A0
                move.w  (A0)+,D0             ;x-koordinate
                move.w  D0,D1
                andi.w  #$0f,D0
                move.w  D0,D6
                andi.w  #$fff0,D1
                lsr.w   #1,D1
                move.w  (A0)+,D2             ;y-koordinate
                lsl.w   #5,D2                ;*160
                add.w   D2,D1
                add.w   D2,D2
                add.w   D2,D2
                add.w   D2,D1                ;d1 - Offset zur Screenadresse
                move.w  (A0)+,D2             ;d2 - Breite
                move.w  (A0)+,D3             ;d3 - Hîhe
                move.w  D0,D4
                add.w   D2,D4
                cmpi.w  #32,D4
                blt     less_box
                subi.w  #16,D2
                move.l  #$ffff,D4
                ror.l   D0,D4                ;d4 - 1. wort von links
                add.w   D2,D6
                andi.w  #$0f,D6
                move.l  #$ffff0000,D5
                ror.l   D6,D5                ;d5 - 1. wort von rechts
                eori.w  #$0f,D0
                add.w   D6,D0
                sub.w   D0,D2
                lsr.w   #4,D2                ;d2 - anzahl der fÅllwîrter

                move.w  D2,D6
                addq.w  #2,D6
                lea     box_save,A2
                lea     6(A1,D1.w),A1
                move.l  A1,(A2)+
                move.w  D6,(A2)+
                move.w  D3,(A2)

                moveq   #-1,D6               ;d6 - fÅllwort

filly_box	movea.l A1,A2
                lea     160(A1),A1
                move.w  D2,D0
                or.w    D4,(A2)
                addq.l  #8,A2

fillx_box	move.w  D6,(A2)
                addq.l  #8,A2
                dbra    D0,fillx_box
                or.w    D5,(A2)
                dbra    D3,filly_box
                bra     end_box

less_box	move.l  #$ffff0000,D4
*                move.w  D2,D5
                asr.l   D2,D4
                andi.l  #$ffff,D4
                ror.l   D0,D4
                btst    #4,D2
                bne     notleast_box
                move.l  D4,D5
                swap    D5
                bra     lessok_box

notleast_box	subi.w  #$10,D2
                add.w   D0,D2
                move.l  #$ffff0000,D5
                ror.l   D2,D5

lessok_box	lea     box_save,A2
                lea     6(A1,D1.w),A1
                move.l  A1,(A2)+
                move.w  #1,(A2)+
                move.w  D3,(A2)

filly2_box	movea.l A1,A2
                lea     160(A1),A1
                move.w  D4,(A2)
                addq.l  #8,A2
                move.w  D5,(A2)
                dbra    D3,filly2_box

end_box		bsr     get_back

                movem.l (SP)+,D0-D6/A0-A2
                rts

box_clear	movem.l D0-D2/A0-A2,-(SP)
                clr.l   back_save+6
                clr.l   back_save+10
                clr.l   back_save+14
                lea     box_save,A0
                movea.l (A0),A1
                move.w  4(A0),D0
                move.w  6(A0),D1

y_clear		movea.l A1,A2
                move.w  D0,D2

x_clear		clr.w   (A2)
                addq.l  #8,A2
                dbra    D2,x_clear
                lea     160(A1),A1
                dbra    D1,y_clear
                movem.l (SP)+,D0-D2/A0-A2
                rts

	; <cxt> 2005-02-06
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
gdprint:        movem.l D0-A6,-(SP)
                pea     (A1)
                move.w  #9,-(SP)
                trap    #1
                addq.w  #6,SP
                movem.l (SP)+,D0-A6
                rts
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
loading:       DC.B 27,'E'     ;clear screen
                DC.B '>>> Loading File',27,"f",0
saving:        DC.B 27,'E'     ;clear screen
                DC.B '>>> Saving File',27,"f",0
                EVEN
;- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
	; </cxt>
*** 'Fileselector'

fileselector_l	
		bsr     restore_all
		bsr	flush
		bsr	flush
		bsr	flush
		bsr	flush

;------------------------------------------- ;<cxt> 2005-02-03
		tst.b autoload_flag
		beq.s skip_autoload
 		sf    autoload_flag ; execute only once
		
		lea 	fname(pc),a0
		lea 	filename(pc),a1
		bsr 	ctxt
	
		lea 	realfname(pc),a0
		lea 	path_n_name(pc),a1
		bsr	ctxt
 	
	   	bra.s file_selected
autoload_flag:	ds.b 1
fext		dc.b "\*.SND",0
		even
;-------------------------------------------
skip_autoload: 	                     ; </cxt>
	
		lea loading(pc),a1	; <cxt> 2005-02-06
		bsr gdprint		;</cxt>

                DC.W $a009

                move.l  #load_text,addr_in+8
		move.w 	#$676,$ffff8240.w
                bsr     fileselect           ; select a file
		move.w	oldpalette,$ffff8240.w
                clr.w   no_select
                tst.w   int_out+2
                seq     no_select            ; <cancel> exits.
                DC.W $a00a

                tst.b   no_select
                bne     don_t_bother_l
                bsr     Concate_path
file_selected		; <cxt> 2005-02-03 </cxt>
                move.w  #2,-(SP)
                pea     path_n_name(PC)
                move.w  #$3d,-(SP)           ;OPEN file
                trap    #1
                addq.l  #8,SP
                tst.w   D0
                bmi     don_t_bother_l
                move.w  D0,handle

                movea.l mod,A0
                pea     (A0)
                move.l  free_mem,-(SP)
                move.w  handle,-(SP)
                move.w  #$3f,-(SP)
                trap    #1
                lea     12(SP),SP
                tst.l   D0
                bmi     close_file_l
                move.l  D0,file_length
                add.l   mod,D0
                move.l  D0,mod_end

close_file_l	move.w  handle,-(SP)
                move.w  #$3e,-(SP)
                trap    #1
                addq.l  #4,SP

		clr.w	play_flag		;stop
		lea	dummy_track,a0		;silence monitor channels
		move.l	#0,(a0)+
		move.l	#0,(a0)+
		move.l	#0,(a0)+

		move.w	#0,current_patt		;reset mod position
		move.w	#0,current_pos		;
		lea	track2_data,a0
		move.w	#0,$26(a0)		;reset sid phase and sid morph				
		lea	track1_data,a0
		move.w	#0,$26(a0)		;reset sid phase and sid morph				
		lea	track3_data,a0
		move.w	#0,$26(a0)		;reset sid phase and sid morph				


don_t_bother_l	ori     #$0700,SR
                bsr     install_all

                clr.w   mouseflags

                bsr     patt_top
                bsr     draw_wave
                bsr     display_position
                bsr     display_instrument
                bsr     display_len_rst
                bsr     display_octave

                rts

fileselector_s	
		bsr     restore_all
		bsr	flush
		bsr	flush
		bsr	flush
		bsr	flush

		lea saving(pc),a1	; <cxt> 2005-02-06
		bsr gdprint		; </cxt>

                DC.W $a009

                move.l  #save_text,addr_in+8
		move.w	#$766,$ffff8240.w
                bsr     fileselect           ; select a file
		move.w	oldpalette,$ffff8240.w

                clr.w   no_select
                tst.w   int_out+2
                seq     no_select            ; <cancel> exits.
   
   
                DC.W $a00a

                tst.b   no_select
                bne     don_t_bother_s
                bsr     Concate_path

                moveq   #0,D0
                movea.l mod,A0
                move.b  $14(A0),D0
                adda.l  $0c(A0),A0           ;offset for sequence table

                moveq   #0,D1

get_max_seq	move.b  (A0)+,D2
                cmp.b   D2,D1
                bge     no_higher
                exg     D1,D2

no_higher	dbra    D0,get_max_seq

                andi.w  #$ff,D1
                addq.w  #1,D1
                mulu    #3*4*64,D1
                addi.l  #3222,D1
                move.l  D1,file_length

                move.w  #0,-(SP)
                pea     path_n_name(PC)
                move.w  #$3c,-(SP)           ;CREATE file
                trap    #1
                addq.l  #8,SP
                tst.w   D0
                bmi     don_t_bother_s
                move.w  D0,handle

                movea.l mod,A0
                pea     (A0)
                move.l  file_length,D0
                move.l  D0,-(SP)
                move.w  handle,-(SP)
                move.w  #$40,-(SP)           ;save
                trap    #1
                lea     12(SP),SP
                tst.l   D0
                bmi     close_file_s
                move.l  D0,file_length

close_file_s	move.w  handle,-(SP)
                move.w  #$3e,-(SP)
                trap    #1
                addq.l  #4,SP

don_t_bother_s	ori     #$0700,SR
                bsr     install_all

                clr.w   mouseflags

                rts

no_select       DC.W 0
handle          DC.W 0
file_length     DC.L 0
file_type       DC.B "a Triplex Sound",0
                EVEN
load_text       DC.B "Load",0
                EVEN
save_text       DC.B "Save",0
                EVEN


* Routines for VDI and AES access By Martin Griffiths 1990
* Call appl_init at start of a program and appl_exit before terminating.

* AES call for gemdos fileselector routine.

fileselect      lea     control,A0
                move.w  #90,(A0)+
                move.w  #0,(A0)+
                move.w  #2,(A0)+
                move.w  #4,(A0)+
                move.l  #path,addr_in
                move.l  #filename,addr_in+4
                move.l  #file_type,addr_in+12
                bsr     AES
                rts

		* AES subroutine call.

AES             lea     AESparblock,A0
                move.l  #control,(A0)
                move.l  A0,D1
                move.l  #200,D0
                trap    #2
                rts

		* 1st BDOS call is APPL_INIT

appl_init       lea     control,A0
                move.w  #10,(A0)+
                move.w  #0,(A0)+
                move.w  #1,(A0)+
                move.w  #0,(A0)+
                bra     AES

		* Last BDOS call is APPL_EXIT

appl_exit       lea     control,A0
                move.w  #19,(A0)+
                move.w  #0,(A0)+
                move.w  #1,(A0)+
                move.w  #0,(A0)+
                bra     AES

; The Gem Fileselector returns a path and filename as seperate strings
; - this rout concatenates the two strings together into one (for loading).

Concate_path    lea     path,A1
                movea.l A1,A0

.find_end       tst.b   (A0)+                ; search for end of path
                bne     .find_end

.foundit        cmpi.b  #'\',-(A0)           ; now look back for slash
                beq     .foundslash
                cmpa.l  A1,A0                ; (or if we reach start of path)
                bne     .foundit

.foundslash     suba.l  A1,A0                ; number of bytes
                move.w  A0,D0
                lea     path_n_name,A0
                tst.w   D0
                beq     .nonetodo            ; if zero then not in subdir

.copypath       move.b  (A1)+,(A0)+          ; copy path
                dbra    D0,.copypath

.nonetodo       lea     filename,A1

.copy_filename  move.b  (A1),(A0)+           ; concatenate file name
                tst.b   (A1)+
                bne     .copy_filename
                rts

*** 'BMOVE'

; BMove  Start- (.l), Zieladresse (.l) sowie LÑnge (.w) auf den Stack, dann
;        zu bmove springen und danach Stack um 10 erhîhen.

bmove		movem.l D7/A5-A6,-(SP)

                movea.l 22(SP),A5
                movea.l 18(SP),A6
                moveq   #0,D7
                move.w  16(SP),D7
                beq     endcopy
                cmpa.l  A5,A6
                bgt     copydhs
                subq.w  #1,D7

copbra1		move.b  (A5)+,(A6)+
                dbra    D7,copbra1
                bra     endcopy

copydhs		adda.l  D7,A5
                adda.l  D7,A6
                subq.w  #1,D7

copbra2		move.b  -(A5),-(A6)
                dbra    D7,copbra2

endcopy		movem.l (SP)+,D7/A5-A6

                rts

*** 'Draw Wave'

draw_wave	movem.l D0-D3/A0-A2,-(SP)

                movea.l screen_1,A0
                lea     1280*14+204(A0),A0

                movea.l A0,A1
                moveq   #18*3-1,D0

clear_wave
		REPT 14
                clr.w   (A1)
                lea     8(A1),A1
                ENDR
                clr.b   (A1)
                lea     160-14*8(A1),A1
                dbra    D0,clear_wave
                lea     160*(3*19-1)-2(A0),A1
                REPT 14
                clr.w   (A1)
                clr.w   160(A1)
                clr.w   320(A1)
                lea     8(A1),A1
                ENDR
                clr.b   (A1)
                clr.b   160(A1)
                clr.b   320(A1)

                lea     160*3*17(A0),A0

                movea.l mod,A1
                adda.l  (A1),A1
                move.w  instrument,D0
                add.w   D0,D0
                move.w  0(A1,D0.w),D0
                lea     5(A1,D0.w),A1        ;a1 - pointer on wave

                move.w  #$4000,D1
                move.w  #$e000,D2
                moveq   #57,D0

plot_instr	moveq   #0,D3
                move.b  (A1)+,D3             ;d3 - volume
                btst    #5,D3
                beq     no_mask_bit
                lea     -3*160*17(A0),A2
                or.w    D1,(A2)
                or.w    D2,160(A2)
                or.w    D1,320(A2)

no_mask_bit	btst    #4,D3
                beq     no_buzz_bit
                lea     -3*160*16(A0),A2
                or.w    D1,(A2)
                or.w    D2,160(A2)
                or.w    D1,320(A2)

no_buzz_bit	andi.w  #$0f,D3
                mulu    #3*160,D3
                neg.w   D3
                lea     0(A0,D3.w),A2
                or.w    D1,(A2)
                or.w    D2,160(A2)
                or.w    D1,320(A2)

                cmpi.b  #$ff,(A1)
                beq     end_of_wave

                ror.w   #4,D1
                ror.w   #4,D2
                bcc     no_add_inc
                addq.l  #8,A0

no_add_inc	dbra    D0,plot_instr
                move.w  #$0400,D1
                move.w  #$0e00,D2

end_of_wave	lea     5*160-2(A0),A0
                or.w    D1,(A0)
                or.w    D2,160(A0)
                or.w    D2,320(A0)

                bsr     display_wavedata

                movem.l (SP)+,D0-D3/A0-A2
                rts

;-------------------------------------------------------------------------------

*** 'all IRQ routines'

*** 'VBL'

vbl		addq.l  #1,vsync_count
                movem.l D0-A6,-(SP)
;		move.w	#$777,$ffff8250

                clr.b   $fffffa1b.w
                move.b  #40,$fffffa21.w
                move.b  #8,$fffffa1b.w

;                moveq   #$0d,D0
;                bsr     send_ikbd

                bsr     restore_back
                bsr     get_back
                bsr     draw_mouse

		moveq	#0,d0
		btst	#0,mousekey
		beq.s	.nomousebit0
		bset	#1,d0
.nomousebit0
		btst	#1,mousekey
		beq.s	.nomousebit1
		bset	#0,d0
.nomousebit1
		move.b	d0,mouseflags+1
;                btst    #2,mousekey
;                beq     no_left1
;                ori.w   #1,mouseflags
;                bra     endmousetest
;
;no_left1	btst    #3,mousekey
;                beq     no_left2
;                andi.w  #2,mouseflags
;
;no_left2	btst    #0,mousekey
;                beq     no_right1
;                ori.w   #2,mouseflags
;                bra     endmousetest
;
;no_right1	btst    #1,mousekey
;                beq     endmousetest
;                andi.w  #1,mouseflags

endmousetest	tst.w   play_flag
                beq     no_play

                moveq   #30,D0

wait_ray	
		REPT 100
                nop
                ENDR
                dbra    D0,wait_ray

;                not.w   $ffff8240.w	; Show cpu-time
                jsr     player
;                not.w   $ffff8240.w	; Show cpu-time
                bra     end_play

no_play		jsr     single_play

end_play	
;		bsr     scroller
;               bsr     analyzer

                movem.l (SP)+,D0-A6
                rte

restore_back	lea     back_save,A1
                movea.l (A1)+,A2
                move.w  (A1)+,D2
                move.w  (A1)+,(A2)
                move.w  (A1)+,8(A2)
                move.w  (A1)+,160(A2)
                move.w  (A1)+,168(A2)
                move.w  (A1)+,320(A2)
                move.w  (A1)+,328(A2)
                rts

get_back	move.w  mousey,D0
		cmp.w	#199,d0
		bls.s	.nolimy
		move.w	#199,d0
		move.w	d0,mousey
.nolimy
                lsl.w   #5,D0
                move.w  D0,D1
                add.w   D0,D0
                add.w   D0,D0
                add.w   D0,D1
                move.w  mousex,D0
		cmp.w	#319,d0
		bls.s	.nolimx
		move.w	#319,d0
		move.w	d0,mousex
.nolimx
                move.w  D0,D2
                andi.w  #$fff0,D0
                lsr.w   #1,D0
                add.w   D0,D1
                movea.l screen_1,A0
                andi.w  #$0f,D2
                eori.w  #$0f,D2
                lea     back_save,A1
                lea     6(A0,D1.w),A0
                move.l  A0,(A1)+
                move.w  D2,(A1)+
                move.w  (A0),(A1)+
                move.w  8(A0),(A1)+
                move.w  160(A0),(A1)+
                move.w  168(A0),(A1)+
                move.w  320(A0),(A1)+
                move.w  328(A0),(A1)+
                rts

draw_mouse	lea     back_save,A1
                movea.l (A1)+,A0
                move.w  (A1),D0
                lea     m_pointer,A2
                moveq   #2,D3

pnt_drw		moveq   #0,D1
                move.w  (A2)+,D1
                lsl.l   D0,D1
                eor.w   D1,8(A0)
                swap    D1
                eor.w   D1,(A0)
                lea     160(A0),A0
                dbra    D3,pnt_drw
                rts


*** 'Keyboard IRQ'

newkey		move.w	D0,-(SP)
                move.w	D1,-(SP)
                move.b	$fffffc00.w,D0
                btst	#7,D0
                beq	return

                move.b	$fffffc02.w,D0

                move.b	keycount,D1

                cmpi.b	#2,D1
                bne.s	notwo
                ext.w	d0
                add.w	D0,mousex
                bpl.s	nono
                clr.w	mousex
                bra.s	nono

notwo           cmpi.b	#1,D1
                bne.s	yo
                ext.w	d0
                add.w	D0,mousey
                bpl.s	nono
                clr.w	mousey

nono            subq.b	#1,D1
                bra.s	endkey

yo		cmpi.b  #$f7,D0
                bls.s     nomouse
                cmpi.b	#$fc,d0
                bhs.s	return
		and.b	#3,d0
		move.b	d0,mousekey
                moveq   #2,D1
                bra.s     endkey

nomouse		cmpi.b  #$2a,D0
                bne.s     no_l_shft_p
                ori.w   #1,switch_keys
                bra.s     end_shift

no_l_shft_p	cmpi.b  #$aa,D0
                bne.s     no_l_shft_r
                andi.w  #$fe,switch_keys
                bra.s     end_shift

no_l_shft_r	cmpi.b  #$36,D0
                bne.s     no_r_shft_p
                ori.w   #2,switch_keys
                bra.s     end_shift

no_r_shft_p	cmpi.b  #$b6,D0
                bne.s     no_r_shft_r
                andi.w  #$fd,switch_keys
                bra.s     end_shift

no_r_shft_r	btst    #7,D0
                seq     hold_flag
                move.b  D0,key

end_shift	moveq   #0,D1

endkey          move.b  D1,keycount

return		move.w  (SP)+,D1
                move.w  (SP)+,D0
                rte

;###############################################################################

silence		
		lea     track1_data,A1   ;necessary to switch off
                move.b  #$3f,$11(A1)         ;"real-time" channel
                clr.b   $06(A1)
		lea     track2_data,A1   ;necessary to switch off
                move.b  #$3f,$11(A1)         ;"real-time" channel
                clr.b   $06(A1)

		lea     track3_data,A1   ;necessary to switch off
                move.b  #$3f,$11(A1)         ;"real-time" channel
                clr.b   $06(A1)

                clr.b   $fffffa19.w
                andi.b  #$f0,$fffffa1d.w

                move.l  #$07ffffff,$ffff8800.w
                move.l  #$08ff00ff,$ffff8800.w
                move.l  #$09ff00ff,$ffff8800.w
                move.l  #$0aff00ff,$ffff8800.w
                rts

init_mod	lea     curr_patt_base,A1
                lea     player_data,A2
                move.l  #$0816+$0240+$0140+$0100,(A1)
                move.l  (A1),8(A2)

                move.l 	mod,A0

                move.l  #$16,(A0)            ;offset for instr_tab
                move.l  #$0816,4(A0)
                move.l  #$0816+$0240,8(A0)
                move.l  #$0816+$0240+$0140,$0c(A0)
                move.l  #$0816+$0240+$0140+$0100,$10(A0) ;3222 Bytes

                lea     $14(A0),A1

                move.b  #1,(A1)+             ;set length to 1
                clr.b   (A1)+                ;clear restart; a1 - instr_tab

;-------------- Instrument Table --------------

                move.w  #$40,D3
                move.w  D3,(A1)+             ;instrument 0 (!)

                lea     $56(A0),A2           ;$56 - first instrument
                moveq   #30,D0               ;31 instruments only!

instr_loop	clr.l   (A2)+
                clr.w   (A2)+
                moveq   #-1,D1

                moveq   #57,D2

i_fill_loop	move.b  D1,(A2)+
                dbra	D2,i_fill_loop

                move.w  D3,(A1)+
                addi.w  #$40,D3

                dbra	D0,instr_loop

;------------- Arpeggio Tables --------------

                movea.l A2,A1                ;start arp_tab
                lea     $40(A2),A2           ;first arpeggio

                move.w  #$40,D3

                moveq   #31,D0               ;32 arpeggios

arp_loop	clr.b   (A2)+
                clr.b   (A2)+

                moveq   #13,D2

a_fill_loop	move.b  #-1,(A2)+
                dbra    D2,a_fill_loop

                move.w  D3,(A1)+
                addi.w  #$10,D3

                dbra    D0,arp_loop

                movea.l A2,A1                ;start noz_tab
                lea     $20(A2),A2           ;first noise

                move.w  #$20,D3

                moveq   #15,D0               ;16 noises

noz_loop	clr.b   (A2)+
                move.b  #$20,(A2)+
                moveq   #-1,D1

                moveq   #13,D2

n_fill_loop	move.b  D1,(A2)+
                dbra    D2,n_fill_loop

                move.w  D3,(A1)+
                addi.w  #$10,D3

                dbra    D0,noz_loop

                move.w  #(256+64*3*4)/4,D0

rest_clear	clr.l   (A2)+
                dbra    D0,rest_clear

                rts

;============================ Play Routine ==========================

single_play	
		bra	no_player_step

patt_length     EQU 64

init_player	lea     player_data,A0
                clr.b   (A0)
                clr.b   2(A0)
                move.w  current_pos,D0
                move.b  D0,3(A0)
                lea     track1_data,A0
                clr.b   6(A0)
                move.b  #$3f,$11(A0)
                lea     track2_data,A0
                clr.b   6(A0)
                move.b  #$3f,$11(A0)
                lea     track3_data,A0
                clr.b   6(A0)
                move.b  #$3f,$11(A0)
                rts

player		lea     player_data,A0
                subq.b  #1,(A0)              ;NeXT step?
                bpl     no_player_step

                move.b  1(A0),(A0)           ;Set speed anew

                move.b  2(A0),D0             ;Pattern counter
                moveq   #64,D1
                sub.b   D0,D1
                move.w  D1,patt_pos

                subq.b  #1,2(A0)             ;Pattern end?
                bpl     no_new_pattern

                move.b  #patt_length-1,2(A0) ;Set pattern length
                movea.l mod,A3
                movea.l A3,A1
                adda.l  $0c(A3),A3           ;a3 is now a pointer on the seq's

                moveq   #0,D0
                move.b  3(A0),D0             ;get song position
                addq.b  #1,3(A0)             ;prepare next position
                cmp.b   $14(A1),D0           ;at end position?
                bne     no_restart

                move.b  $15(A1),D0
                move.b  D0,3(A0)
                addq.b  #1,3(A0)

no_restart	move.w  D0,current_pos

                move.b  0(A3,D0.w),D0        ;d0 contains next sequence nr.
                andi.w  #$ff,D0
                mulu    #patt_length*3*4,D0

                movea.l mod,A3
                adda.l  $10(A3),A3
                lea     0(A3,D0.w),A2

		movem.l	d0-7/a0-6,-(sp)
		bsr	display_position
		movem.l	(sp)+,d0-7/a0-6

                bra     shortcut1

no_new_pattern	movea.l $08(A0),A2           ;get old position

		movem.l	d0-7/a0-6,-(sp)
		bsr	ok_scroll_down
		movem.l	(sp)+,d0-7/a0-6
		

shortcut1	lea     track1_data,A1
                bsr     pattern_check
                lea     track2_data,A1
                bsr     pattern_check
                cmpi.b  #5,6(A1)
                beq     no_timer_stop2
                cmpi.b  #7,6(A1)
                bhi.s     no_timer_stop2

                andi.b  #$f0,$fffffa1d.w

no_timer_stop2	lea     track3_data,A1
                bsr     pattern_check
                cmpi.b  #5,6(A1)
                beq     no_timer_stop
                cmpi.b  #7,6(A1)
                bhi     no_timer_stop

                clr.b   $fffffa19.w

no_timer_stop	move.l  A2,$08(A0)           ;Save old position

no_player_step	move.b  #$ff,D7

                lea     ym2149,A6

                moveq   #3,D6
                lea     track1_data,A1
                bsr     wave_shape

                move.b  D0,8*4+2(A6)	;chan a vol
                move.b  D2,2(A6)	;chan a freq
                ror.w   #8,D2
                move.b  D2,4+2(A6)	;chan a freq

;-----

                moveq   #4,D6
                lea     track2_data,A1
                bsr     wave_shape

                move.b  D0,9*4+2(A6)	;chan b vol
                move.b  D2,2*4+2(A6)	;chan b freq
                ror.w   #8,D2		
                move.b  D2,3*4+2(A6)	;chan b freq

;-----

                moveq   #5,D6
                lea     track3_data,A1
                bsr     wave_shape

                move.b  D0,10*4+2(A6)	;chan c vol
                move.b  D2,4*4+2(A6)	;chan c freq
                ror.w   #8,D2
                move.b  D2,5*4+2(A6)	;chan c freq

;-----

                move.b  D7,7*4+2(A6)	;mix


                lea     $ffff8800.w,A0
                move.l  (A6)+,(A0)           ;0
                move.l  (A6)+,(A0)           ;1
                move.l  (A6)+,(A0)           ;2
                move.l  (A6)+,(A0)           ;3
                move.l  (A6)+,(A0)           ;4
                move.l  (A6)+,(A0)           ;5
                move.l  (A6)+,(A0)           ;6
                move.l  (A6)+,(A0)           ;7

                tst.w   v_on_1
                beq     no_v1_play
                move.l  (A6),(A0)            ;8

no_v1_play	addq.l  #4,A6

                lea     track2_data,A1
                cmpi.b  #5,6(A1)
                beq     no_v2_play
                cmpi.b  #7,6(A1)
                bhi.s     no_v2_play

                tst.w   v_on_2
                beq     no_v2_play
                move.l  (A6),(A0)            ;9

no_v2_play	addq.l  #4,A6

                lea     track3_data,A1
                cmpi.b  #5,6(A1)
                beq     no_tenth
                cmpi.b  #7,6(A1)
                bhi.s     no_tenth

                tst.w   v_on_3
                beq.s   no_tenth
                move.l  (A6),(A0)            ;10

no_tenth	addq.l  #4,A6
		cmpi.b	#$c,6(a1)
		beq.s	skip_buzz_freq
                move.l  (A6)+,(A0)           ;11	;buzz freq
                move.l  (A6)+,(A0)           ;12	;buzz freq
skip_buzz_freq
                rts

wave_shape	tst.b   (A1)
                beq     leave_here
		cmp.b	#12,6(a1)
		bne.s	go_ahead
leave_here
                moveq   #0,D0
                moveq   #0,D2
                rts

go_ahead	movea.l $1e(A1),A2           ;get pointer on wave
                move.b  (A2),D0
                bpl     ok_adsr
                subq.l  #1,A2
                move.b  (A2),D0
                bra     ok_wave

ok_adsr		subq.b  #1,$1d(A1)
                bpl     end_adsr
                addq.l  #1,A2
                move.b  $1c(A1),$1d(A1)

end_adsr	move.l  A2,$1e(A1)

ok_wave		move.b  $11(A1),D1           ;get max. volume
                sub.b   D1,D0
                bpl     allright_vol
                moveq   #0,D0                ;silence...

allright_vol	move.l  A2,$1e(A1)           ;save pointer

no_adsr		move.w  D6,D5
                subq.w  #3,D5
                btst    #5,D0                ;mask?
                beq     no_mask_adsr
                bset    D5,D7
                bra     fin_adsr

no_mask_adsr	bclr    D5,D7

fin_adsr	movea.l $18(A1),A2           ;get noise pointer
                move.b  (A2),D2
                bpl     ok_noise
                subq.l  #1,A2
                move.b  (A2),D2

ok_noise	subq.b  #1,$13(A1)
                bpl     no_noise_add
                move.b  $12(A1),$13(A1)
                addq.l  #1,A2

no_noise_add	move.l  A2,$18(A1)

                btst    #5,D2
                bne     no_noise
                bclr    D6,D7
                move.b  D2,6*4+2(A6)
                bra     noise_end

no_noise	bset    D6,D7

noise_end	move.b  (A1),D1              ;get note

                movea.l $0c(A1),A2           ;get arpeggio pointer
                move.b  (A2),D2
                bpl     ok_arpeggio
                cmpi.b  #$ff,D2
                bne     loop_arpeggio
                subq.l  #1,A2
                move.b  (A2),D2
                bra     ok_arpeggio

loop_arpeggio	movea.l 8(A1),A2
                move.b  (A2),D2

ok_arpeggio	subq.b  #1,$10(A1)
                bpl     no_arp_add
                move.b  7(A1),$10(A1)
                addq.l  #1,A2

no_arp_add	move.l  A2,$0c(A1)
                add.b   D2,D1                ;-> note + arpeggio
                andi.w  #$7f,D1

;======================================================================
		moveq	#0,d3
                move.b  6(A1),D3             ;get type
		move.w	d3,d2
		add.b	d2,d2
		add.b	d2,d2

		movea.l	inst_lookup(pc,d2.w),a5
		
		jmp	(a5)
	
inst_lookup
	dc.l	normal		;0
	dc.l	norm_buzz	;1
	dc.l	norm_buzz	;2
	dc.l	calc_buzz	;3
	dc.l	calc_buzz	;4
	dc.l	future_sound	;5
	dc.l	calc_buzz2	;6
	dc.l	calc_buzz2	;7
	dc.l	future_sound2	;8
	dc.l	future_sound3	;9
	dc.l	future_sound4	;a
	dc.l	future_sound5	;b	;sync buzz
	
;======================================================================

normal		add.w   D1,D1
                lea     frequency_tab,A2
                move.w  0(A2,D1.w),D2        ;d2 - frequency

                move.w  $22(A1),D1
                cmpi.b  #1,1(A1)
                blt     no_sliding
                cmpi.b  #3,1(A1)
                bgt     no_sliding
                beq     gliss

                add.w   $24(A1),D1
                move.w  D1,$22(A1)
                bra     no_sliding

gliss		move.w  $24(A1),D4           ;glissando speed

                move.w  $28(A1),D1
                sub.w   D2,D1
                bmi     slide_down

                neg.w   D4

                cmp.w   $24(A1),D1
                bgt     slide_to_it1
                move.w  D1,D4
                neg.w   D4

slide_to_it1	add.w   D4,D1
                bra     no_sliding

slide_down	move.w  D1,D3
                neg.w   D3
                cmp.w   $24(A1),D3
                bgt     slide_to_it2
                move.w  D3,D4

slide_to_it2	add.w   D4,D1

no_sliding	add.w   D1,D2

                move.b  5(A1),D1             ;vib. position
                move.b  4(A1),D3             ;speed (signed!)
                move.b  3(A1),D4             ;width

                add.b   D3,D1
                bpl     no_null
                neg.b   D3
                move.b  D3,4(A1)
                moveq   #0,D1

no_null		cmp.b   D4,D1
                blt     no_max
                neg.b   D3
                move.b  D3,4(A1)
                move.b  D4,D1

no_max		move.b  D1,5(A1)

                ext.w   D1
                ext.w   D4
                lsr.w   #1,D4
                sub.w   D4,D2
                add.w   D1,D2

                move.w  D2,$28(A1)

*                moveq   #-1,D1
                rts

;======================================================================

norm_buzz	lea     buzzfreqtab,A2
                move.b  0(A2,D1.w),D2        ;d2 - frequency

                move.w  $22(A1),D1
                cmpi.b  #1,1(A1)
                blt     no_sliding1
                cmpi.b  #2,1(A1)
                bgt     no_sliding1

                add.w   $24(A1),D1
                move.w  D1,$22(A1)

no_sliding1	add.b   D1,D2

                move.b  5(A1),D1             ;vib. position
                move.b  4(A1),D3             ;speed
                move.b  3(A1),D4

                add.b   D3,D1
                bpl     no_null1
                neg.b   D3
                move.b  D3,4(A1)
                moveq   #0,D1

no_null1	cmp.b   D4,D1
                blt     no_max1
                neg.b   D3
                move.b  D3,4(A1)
                move.b  D4,D1

no_max1		move.b  D1,5(A1)

                lsr.b   #1,D4
                sub.b   D4,D2
                add.b   D1,D2
                move.b  D2,11*4+2(A6)
                clr.b   12*4+2(A6)
                clr.w   D2
*                moveq   #-1,D1
                rts

;======================================================================

calc_buzz	moveq   #0,D2

                lea     buzzfreqtab,A2
                move.b  0(A2,D1.w),D2        ;d2 - frequency

                move.w  $22(A1),D1
                cmpi.b  #1,1(A1)
                blt     no_sliding2
                cmpi.b  #2,1(A1)
                bgt     no_sliding2

                add.w   $24(A1),D1
                move.w  D1,$22(A1)

no_sliding2	add.b   D1,D2

                move.b  5(A1),D1             ;vib. position
                move.b  4(A1),D5             ;speed
                move.b  3(A1),D4

                add.b   D5,D1
                bpl     no_null2
                neg.b   D5
                move.b  D5,4(A1)
                moveq   #0,D1

no_null2	cmp.b   D4,D1
                blt     no_max2
                neg.b   D5
                move.b  D5,4(A1)
                move.b  D4,D1

no_max2		move.b  D1,5(A1)

                lsr.b   #1,D4
                sub.b   D4,D2
                add.b   D1,D2
                move.b  D2,11*4+2(A6)
                clr.b   12*4+2(A6)
                lsl.w   #4,D2
                cmpi.b  #4,D3
                bne     goon_calc
                add.w   D2,D2

goon_calc	subq.w  #3,D2
*                moveq   #-1,D1
                rts

;======================================================================
future_sound	add.w   D1,D1
                lea     frequency_tab,A2
                move.w  0(A2,D1.w),D2        ;d2 - frequency

                move.w  $22(A1),D1
                cmpi.b  #1,1(A1)
                blt     .no_sliding
                cmpi.b  #3,1(A1)
                bgt     .no_sliding
                beq     .gliss

                add.w   $24(A1),D1
                move.w  D1,$22(A1)
                bra     .no_sliding

.gliss		move.w  $24(A1),D4           ;glissando speed

                move.w  $28(A1),D1
                sub.w   D2,D1
                bmi     .slide_down

                neg.w   D4

                cmp.w   $24(A1),D1
                bgt     .slide_to_it
                move.w  D1,D4
                neg.w   D4

.slide_to_it	add.w   D4,D1
                bra     .no_sliding

.slide_down	move.w  D1,D3
                neg.w   D3
                cmp.w   $24(A1),D3
                bgt     .slide_to_it22
                move.w  D3,D4

.slide_to_it22	add.w   D4,D1

.no_sliding	add.w   D1,D2

                move.b  5(A1),D1             ;vib. position
                move.b  4(A1),D3             ;speed (signed!)
                move.b  3(A1),D4             ;width

                add.b   D3,D1
                bpl     .no_null3
                neg.b   D3
                move.b  D3,4(A1)
                moveq   #0,D1

.no_null3	cmp.b   D4,D1
                blt     .no_max
                neg.b   D3
                move.b  D3,4(A1)
                move.b  D4,D1

.no_max		move.b  D1,5(A1)

                ext.w   D1
                ext.w   D4
                lsr.w   #1,D4
                sub.w   D4,D2
                add.w   D1,D2

                move.w  D2,$28(A1)

                cmpi.b  #4,D6
                bne     .voice3_synth

                tst.w   v_on_2
                beq     .no_future_v2

                cmpi.w  #17,D2
                bgt     .ok_max_freq

.no_future_v2	andi.b  #$f0,$fffffa1d.w
                rts

.voice3_synth	tst.w   v_on_3
                beq     .no_future_v3

                cmpi.w  #17,D2
                bgt     .ok_max_freq

.no_future_v3	clr.b   $fffffa19.w
                rts

.ok_max_freq	cmpi.w  #2593,D2
                blt     .do_future

                cmpi.b  #4,D6
                bne     .voice3_synth2

                andi.b  #$f0,$fffffa1d.w
                rts

.voice3_synth2	clr.b   $fffffa19.w
                rts

.do_future	lea     future_freq,A2

                move.w  D2,D3
                add.w   D3,D3
                lea     0(A2,D3.w),A2

                move.b  (A2)+,D3
                move.b  (A2)+,D1

                cmpi.b  #4,D6
                bne     .v3_synth3

;                move.l  #sound_timer1a,$0134.w ; First SID-voice on Timer A
		tst.b	$2b(a1)
 		beq.s	.skip				
;                move.l  #sound_timer1b,$0110.w ; Second SID-voice on Timer D
		move.w	#$242,$0112.w
		clr.b	$2b(a1)
.skip
;                move.b  D0,sound_timer2b+4   ;volume
;                move.b  D0,sound_timer4b+4
;		clr.b	sound_timer1b+4
;		clr.b	sound_timer3b+4
		move.b	d0,$256
		move.b	d0,$276		
		clr.b	$246
		clr.b	$266

                cmp.b   $fffffa25.w,D3
                beq     .same_period2
                move.b  D3,$fffffa25.w

.same_period2	move.b  $fffffa1d.w,D0
                andi.b  #$0f,D0
                cmp.b   D0,D1
                beq     .same_div2
                andi.b  #$f0,$fffffa1d.w
                or.b    D1,$fffffa1d.w

.same_div2	move.b  $26(A1),D3
                andi.w  #$ff,D3
                add.w   D3,D2
                bcc     .ok_phaser2
                moveq   #0,D2

.ok_phaser2	rts

.v3_synth3	
		tst.b	$2b(a1)
		beq.s	.skip2				
;                move.l  #sound_timer1a,$0134.w ; First SID-voice on Timer A
		move.w	#$202,$0136.w
		clr.b	$2b(a1)
.skip2
;		move.b  D0,sound_timer2a+4   ;volume
;                move.b  D0,sound_timer4a+4
;		clr.b	sound_timer1a+4
;		clr.b	sound_timer3a+4

		move.b	d0,$216
		move.b	d0,$236		
		clr.b	$206
		clr.b	$226

                cmp.b   $fffffa1f.w,D3
                beq     .same_period
                move.b  D3,$fffffa1f.w

.same_period	cmp.b   $fffffa19.w,D1
                beq     .same_div
                move.b  D1,$fffffa19.w

.same_div	move.b  $26(A1),D3
                andi.w  #$ff,D3
                add.w   D3,D2
                bcc     .ok_phaser
                moveq   #0,D2

.ok_phaser	rts

;======================================================================
future_sound2	
		add.w   D1,D1
                lea     frequency_tab,A2
                move.w  0(A2,D1.w),D2        ;d2 - frequency

                move.w  $22(A1),D1
                cmpi.b  #1,1(A1)
                blt     .no_sliding
                cmpi.b  #3,1(A1)
                bgt     .no_sliding
                beq     .gliss

                add.w   $24(A1),D1
                move.w  D1,$22(A1)
                bra     .no_sliding

.gliss		move.w  $24(A1),D4           ;glissando speed

                move.w  $28(A1),D1
                sub.w   D2,D1
                bmi     .slide_down

                neg.w   D4

                cmp.w   $24(A1),D1
                bgt     .slide_to_it
                move.w  D1,D4
                neg.w   D4

.slide_to_it	add.w   D4,D1
                bra     .no_sliding

.slide_down	move.w  D1,D3
                neg.w   D3
                cmp.w   $24(A1),D3
                bgt     .slide_to_it22
                move.w  D3,D4

.slide_to_it22	add.w   D4,D1

.no_sliding	add.w   D1,D2

                move.b  5(A1),D1             ;vib. position
                move.b  4(A1),D3             ;speed (signed!)
                move.b  3(A1),D4             ;width

                add.b   D3,D1
                bpl     .no_null3
                neg.b   D3
                move.b  D3,4(A1)
                moveq   #0,D1

.no_null3	cmp.b   D4,D1
                blt     .no_max
                neg.b   D3
                move.b  D3,4(A1)
                move.b  D4,D1

.no_max		move.b  D1,5(A1)

                ext.w   D1
                ext.w   D4
                lsr.w   #1,D4
                sub.w   D4,D2
                add.w   D1,D2

                move.w  D2,$28(A1)

                cmpi.b  #4,D6
                bne     .voice3_synth

                tst.w   v_on_2
                beq     .no_future_v2

                cmpi.w  #17,D2
                bgt     .ok_max_freq

.no_future_v2	andi.b  #$f0,$fffffa1d.w
                rts

.voice3_synth	tst.w   v_on_3
                beq     .no_future_v3

                cmpi.w  #17,D2
                bgt     .ok_max_freq

.no_future_v3	clr.b   $fffffa19.w
                rts

.ok_max_freq	cmpi.w  #2593,D2
                blt     .do_future

                cmpi.b  #4,D6
                bne     .voice3_synth2

                andi.b  #$f0,$fffffa1d.w
                rts

.voice3_synth2	clr.b   $fffffa19.w
                rts

.do_future	lea     future_freq,A2

                move.w  D2,D3
                add.w   D3,D3
                lea     0(A2,D3.w),A2

                move.b  (A2)+,D3
                move.b  (A2)+,D1

                cmpi.b  #4,D6
                bne     .v3_synth3

		tst.b	$2b(a1)
		beq.s	.skip				
;                move.l  #sound_timer1b,$0110.w ; Second SID-voice on Timer D
		move.w	#$242,$0112.w

		clr.b	$2b(a1)
.skip

;                move.b  D0,sound_timer2b+4   ;volume
;                clr.b  	sound_timer4b+4
;		clr.b	sound_timer1b+4
;		clr.b	sound_timer3b+4

		move.b	d0,$256
		clr.b	$276		
		clr.b	$246
		clr.b	$266

                cmp.b   $fffffa25.w,D3
                beq     .same_period2
                move.b  D3,$fffffa25.w

.same_period2	move.b  $fffffa1d.w,D0
                andi.b  #$0f,D0
                cmp.b   D0,D1
                beq     .same_div2
                andi.b  #$f0,$fffffa1d.w
                or.b    D1,$fffffa1d.w

.same_div2	move.b  $26(A1),D3
                andi.w  #$ff,D3
                add.w   D3,D2
                bcc     .ok_phaser2
                moveq   #0,D2

.ok_phaser2	rts

.v3_synth3	
		tst.b	$2b(a1)
		beq.s	.skip2				
;                move.l  #sound_timer1a,$0134.w ; First SID-voice on Timer A
		move.w	#$202,$0136.w
		clr.b	$2b(a1)
.skip2

;		move.b  D0,sound_timer2a+4   ;volume
;                clr.b 	sound_timer4a+4
;		clr.b	sound_timer1a+4
;		clr.b	sound_timer3a+4

		move.b	d0,$216
		clr.b	$236		
		clr.b	$206
		clr.b	$226

                cmp.b   $fffffa1f.w,D3
                beq     .same_period
                move.b  D3,$fffffa1f.w

.same_period	cmp.b   $fffffa19.w,D1
                beq     .same_div
                move.b  D1,$fffffa19.w

.same_div	move.b  $26(A1),D3
                andi.w  #$ff,D3
                add.w   D3,D2
                bcc     .ok_phaser
                moveq   #0,D2

.ok_phaser	rts
;-------------------------
future_sound3			;octave morph sid
		add.w   D1,D1
                lea     frequency_tab,A2
                move.w  0(A2,D1.w),D2        ;d2 - frequency

                move.w  $22(A1),D1
                cmpi.b  #1,1(A1)
                blt     .no_sliding
                cmpi.b  #3,1(A1)
                bgt     .no_sliding
                beq     .gliss

                add.w   $24(A1),D1
                move.w  D1,$22(A1)
                bra     .no_sliding

.gliss		move.w  $24(A1),D4           ;glissando speed

                move.w  $28(A1),D1
                sub.w   D2,D1
                bmi     .slide_down

                neg.w   D4

                cmp.w   $24(A1),D1
                bgt     .slide_to_it
                move.w  D1,D4
                neg.w   D4

.slide_to_it	add.w   D4,D1
                bra     .no_sliding

.slide_down	move.w  D1,D3
                neg.w   D3
                cmp.w   $24(A1),D3
                bgt     .slide_to_it22
                move.w  D3,D4

.slide_to_it22	add.w   D4,D1

.no_sliding	add.w   D1,D2

                move.b  5(A1),D1             ;vib. position
                move.b  4(A1),D3             ;speed (signed!)
                move.b  3(A1),D4             ;width

                add.b   D3,D1
                bpl     .no_null3
                neg.b   D3
                move.b  D3,4(A1)
                moveq   #0,D1

.no_null3	cmp.b   D4,D1
                blt     .no_max
                neg.b   D3
                move.b  D3,4(A1)
                move.b  D4,D1

.no_max		move.b  D1,5(A1)

                ext.w   D1
                ext.w   D4
                lsr.w   #1,D4
                sub.w   D4,D2
                add.w   D1,D2

                move.w  D2,$28(A1)

                cmpi.b  #4,D6
                bne     .voice3_synth

                tst.w   v_on_2
                beq     .no_future_v2

                cmpi.w  #17,D2
                bgt     .ok_max_freq

.no_future_v2	andi.b  #$f0,$fffffa1d.w
                rts

.voice3_synth	tst.w   v_on_3
                beq     .no_future_v3

                cmpi.w  #17,D2
                bgt     .ok_max_freq

.no_future_v3	clr.b   $fffffa19.w
                rts

.ok_max_freq	cmpi.w  #2593,D2
                blt     .do_future

                cmpi.b  #4,D6
                bne     .voice3_synth2

                andi.b  #$f0,$fffffa1d.w
                rts

.voice3_synth2	clr.b   $fffffa19.w
                rts

.do_future	lea     future_freq,A2

                move.w  D2,D3
                add.w   D3,D3
                lea     0(A2,D3.w),A2

                move.b  (A2)+,D3
                move.b  (A2)+,D1

                cmpi.b  #4,D6
                bne     .v3_synth3

		move.b	$27(a1),d6
		andi.w	#$0f,d6

		tst.b	$2b(a1)
		beq.s	.skip1				
;                move.l  #sound_timer1b,$0110.w ; Second SID-voice on Timer D
		move.w	#$242,$0112.w
		clr.b	$2b(a1)
.skip1
;		move.b  D0,sound_timer2b+4   ;volume
		move.b	d0,$256
		sub.b	d6,d0
		bhi	.no_reset
		clr.b	d0
.no_reset
;                move.b  D0,sound_timer4b+4
		move.b	d0,$276
;                clr.b  	sound_timer1b+4  
;		clr.b	sound_timer3b+4
		clr.b	$246
		clr.b	$266

                cmp.b   $fffffa25.w,D3
                beq     .same_period2
                move.b  D3,$fffffa25.w

.same_period2	move.b  $fffffa1d.w,D0
                andi.b  #$0f,D0
                cmp.b   D0,D1
                beq     .same_div2
                andi.b  #$f0,$fffffa1d.w
                or.b    D1,$fffffa1d.w

.same_div2	move.b  $26(A1),D3
                andi.w  #$ff,D3
                add.w   D3,D2
                bcc     .ok_phaser2
                moveq   #0,D2

.ok_phaser2	rts

.v3_synth3	
		move.b	$27(a1),d6
		andi.w	#$0f,d6

		tst.b	$2b(a1)
		beq.s	.skip2				
;                move.l  #sound_timer1a,$0134.w ; First SID-voice on Timer A
		move.w	#$202,$0136.w
		clr.b	$2b(a1)
.skip2

;		move.b  D0,sound_timer2a+4   ;volume
		move.b	d0,$216	
		sub.b	d6,d0
		bhi	.no_reset2
		clr.b	d0
.no_reset2
;                move.b  D0,sound_timer4a+4
		move.b	d0,$236
		
;                clr.b  	sound_timer1a+4  
;		clr.b	sound_timer3a+4
		clr.b	$206
		clr.b	$226

                cmp.b   $fffffa1f.w,D3
                beq     .same_period
                move.b  D3,$fffffa1f.w

.same_period	cmp.b   $fffffa19.w,D1
                beq     .same_div
                move.b  D1,$fffffa19.w

.same_div	move.b  $26(A1),D3
                andi.w  #$ff,D3
                add.w   D3,D2
                bcc     .ok_phaser
                moveq   #0,D2

.ok_phaser	rts

;-------------------------------------------------
future_sound4			;softsid
		add.w   D1,D1
                lea     frequency_tab,A2
                move.w  0(A2,D1.w),D2        ;d2 - frequency

                move.w  $22(A1),D1
                cmpi.b  #1,1(A1)
                blt     .no_sliding
                cmpi.b  #3,1(A1)
                bgt     .no_sliding
                beq     .gliss

                add.w   $24(A1),D1
                move.w  D1,$22(A1)
                bra     .no_sliding

.gliss		move.w  $24(A1),D4           ;glissando speed

                move.w  $28(A1),D1
                sub.w   D2,D1
                bmi     .slide_down

                neg.w   D4

                cmp.w   $24(A1),D1
                bgt     .slide_to_it
                move.w  D1,D4
                neg.w   D4

.slide_to_it	add.w   D4,D1
                bra     .no_sliding

.slide_down	move.w  D1,D3
                neg.w   D3
                cmp.w   $24(A1),D3
                bgt     .slide_to_it22
                move.w  D3,D4

.slide_to_it22	add.w   D4,D1

.no_sliding	add.w   D1,D2

                move.b  5(A1),D1             ;vib. position
                move.b  4(A1),D3             ;speed (signed!)
                move.b  3(A1),D4             ;width

                add.b   D3,D1
                bpl     .no_null3
                neg.b   D3
                move.b  D3,4(A1)
                moveq   #0,D1

.no_null3	cmp.b   D4,D1
                blt     .no_max
                neg.b   D3
                move.b  D3,4(A1)
                move.b  D4,D1

.no_max		move.b  D1,5(A1)

                ext.w   D1
                ext.w   D4
                lsr.w   #1,D4
                sub.w   D4,D2
                add.w   D1,D2

                move.w  D2,$28(A1)

                cmpi.b  #4,D6
                bne     .voice3_synth

                tst.w   v_on_2
                beq     .no_future_v2

                cmpi.w  #17,D2
                bgt     .ok_max_freq

.no_future_v2	andi.b  #$f0,$fffffa1d.w
                rts

.voice3_synth	tst.w   v_on_3
                beq     .no_future_v3

                cmpi.w  #17,D2
                bgt     .ok_max_freq

.no_future_v3	clr.b   $fffffa19.w
                rts

.ok_max_freq	cmpi.w  #2593,D2
                blt     .do_future

                cmpi.b  #4,D6
                bne     .voice3_synth2

                andi.b  #$f0,$fffffa1d.w
                rts

.voice3_synth2	clr.b   $fffffa19.w
                rts

.do_future	lea     future_freq,A2

                move.w  D2,D3
                add.w   D3,D3
                lea     0(A2,D3.w),A2

                move.b  (A2)+,D3
                move.b  (A2)+,D1

                cmpi.b  #4,D6
                bne     .v3_synth3

		sub.b	#2,d0		
		bhi.s	.not_zero
		clr.b	d0
.not_zero
		tst.b	$2b(a1)
		beq.s	.skip				
;                move.l  #sound_timer1b,$0110.w ; Second SID-voice on Timer D
		move.w	#$242,$0112.w
		clr.b	$2b(a1)
.skip

;                move.b  D0,sound_timer2b+4   ;volume
;                move.b  D0,sound_timer4b+4
		move.b	d0,$256
		move.b	d0,$276

		sub.b	#6,d0		
		bhi.s	.not_zero3
		clr.b	d0
.not_zero3

;                move.b  d0,sound_timer1b+4  
;		move.b	d0,sound_timer3b+4
		move.b	d0,$246
		move.b	d0,$266
		
                cmp.b   $fffffa25.w,D3
                beq     .same_period2
                move.b  D3,$fffffa25.w

.same_period2	move.b  $fffffa1d.w,D0
                andi.b  #$0f,D0
                cmp.b   D0,D1
                beq     .same_div2
                andi.b  #$f0,$fffffa1d.w
                or.b    D1,$fffffa1d.w

.same_div2	move.b  $26(A1),D3
                andi.w  #$ff,D3
                add.w   D3,D2
                bcc     .ok_phaser2
                moveq   #0,D2

.ok_phaser2	rts

.v3_synth3	
		sub.b	#2,d0		
		bhi.s	.not_zero2
		clr.b	d0
.not_zero2
		tst.b	$2b(a1)
		beq.s	.skip2				
;                move.l  #sound_timer1a,$0134.w ; First SID-voice on Timer A
		move.w	#$202,$0136.w	

		clr.b	$2b(a1)
.skip2

;		move.b  D0,sound_timer2a+4   ;volume
;                move.b  D0,sound_timer4a+4
		move.b	d0,$216
		move.b	d0,$236

		sub.b	#6,d0		
		bhi.s	.not_zero4
		clr.b	d0
.not_zero4
;                move.b 	d0,sound_timer1a+4  
;		move.b	d0,sound_timer3a+4
		move.b	d0,$206
		move.b	d0,$226

                cmp.b   $fffffa1f.w,D3
                beq     .same_period
                move.b  D3,$fffffa1f.w

.same_period	cmp.b   $fffffa19.w,D1
                beq     .same_div
                move.b  D1,$fffffa19.w

.same_div	move.b  $26(A1),D3
                andi.w  #$ff,D3
                add.w   D3,D2
                bcc     .ok_phaser
                moveq   #0,D2

.ok_phaser	rts

;======================================================================
;======================================================================

calc_buzz2	moveq   #0,D2

                lea     buzzfreqtab,A2
                move.b  0(A2,D1.w),D2        ;d2 - frequency

                move.w  $22(A1),D1
                cmpi.b  #1,1(A1)
                blt     no_sliding4
                cmpi.b  #2,1(A1)
                bgt     no_sliding4

                add.w   $24(A1),D1
                move.w  D1,$22(A1)

no_sliding4	add.b   D1,D2

                move.b  5(A1),D1             ;vib. position
                move.b  4(A1),D5             ;speed
                move.b  3(A1),D4

                add.b   D5,D1
                bpl     no_null4
                neg.b   D5
                move.b  D5,4(A1)
                moveq   #0,D1

no_null4	cmp.b   D4,D1
                blt     no_max4
                neg.b   D5
                move.b  D5,4(A1)
                move.b  D4,D1

no_max4		move.b  D1,5(A1)

                lsr.b   #1,D4
                sub.b   D4,D2
                add.b   D1,D2

                move.b  D2,11*4+2(A6)
                clr.b   12*4+2(A6)

                lsl.w   #6,D2

                divu    #3,D2
                subq.w  #2,D2
*                moveq   #-1,D1
                rts

;======================================================================

calc_buzz3	moveq   #0,D2

                lea     buzzfreqtab,A2
                move.b  0(A2,D1.w),D2        ;d2 - frequency
                lea     frequency_tab,A2
                addi.w  #12,D1
                add.w   D1,D1
                move.w  0(A2,D1.w),D3

                move.b  D2,11*4+2(A6)
                clr.b   12*4+2(A6)

                move.w  D3,D2

*                moveq   #-1,D1
                rts

;======================================================================
future_sound5	add.w   D1,D1
                lea     frequency_tab,A2
                move.w  0(A2,D1.w),D2        ;d2 - frequency

                move.w  $22(A1),D1
                cmpi.b  #1,1(A1)
                blt     .no_sliding
                cmpi.b  #3,1(A1)
                bgt     .no_sliding
                beq     .gliss

                add.w   $24(A1),D1
                move.w  D1,$22(A1)
                bra     .no_sliding

.gliss		move.w  $24(A1),D4           ;glissando speed

                move.w  $28(A1),D1
                sub.w   D2,D1
                bmi     .slide_down

                neg.w   D4

                cmp.w   $24(A1),D1
                bgt     .slide_to_it
                move.w  D1,D4
                neg.w   D4

.slide_to_it	add.w   D4,D1
                bra     .no_sliding

.slide_down	move.w  D1,D3
                neg.w   D3
                cmp.w   $24(A1),D3
                bgt     .slide_to_it22
                move.w  D3,D4

.slide_to_it22	add.w   D4,D1

.no_sliding	add.w   D1,D2

                move.b  5(A1),D1             ;vib. position
                move.b  4(A1),D3             ;speed (signed!)
                move.b  3(A1),D4             ;width

                add.b   D3,D1
                bpl     .no_null3
                neg.b   D3
                move.b  D3,4(A1)
                moveq   #0,D1

.no_null3	cmp.b   D4,D1
                blt     .no_max
                neg.b   D3
                move.b  D3,4(A1)
                move.b  D4,D1

.no_max		move.b  D1,5(A1)

                ext.w   D1
                ext.w   D4
                lsr.w   #1,D4
                sub.w   D4,D2
                add.w   D1,D2

                move.w  D2,$28(A1)

                cmpi.b  #4,D6
                bne     .voice3_synth

                tst.w   v_on_2
                beq     .no_future_v2

                cmpi.w  #17,D2
                bgt     .ok_max_freq

.no_future_v2	andi.b  #$f0,$fffffa1d.w
                rts

.voice3_synth	tst.w   v_on_3
                beq     .no_future_v3

                cmpi.w  #17,D2
                bgt     .ok_max_freq

.no_future_v3	clr.b   $fffffa19.w
                rts

.ok_max_freq	cmpi.w  #2593,D2
                blt     .do_future

                cmpi.b  #4,D6
                bne     .voice3_synth2

                andi.b  #$f0,$fffffa1d.w
                rts

.voice3_synth2	clr.b   $fffffa19.w
                rts

.do_future	lea     future_freq,A2

                move.w  D2,D3
                add.w   D3,D3
                lea     0(A2,D3.w),A2

		move.b	$2c(a1),d1
                move.b  D1,11*4+2(A6)

                move.b  (A2)+,D3
                move.b  (A2)+,D1

.v3_synth3	
		tst.b	$2b(a1)
		beq.s	.skip2				
		move.w	#$282,$0136.w
		clr.b	$2b(a1)
		move.l  #$0aff10ff,$ffff8800.w	;set env generator
; 		move.l  #$0bff00ff,$ffff8800.w	;set buzz freq
		move.l  #$0cffffff,$ffff8800.w	;set buzz freq
;		move.l  #$0dff0dff,$ffff8800.w	;set waveform
.skip2
                cmp.b   $fffffa1f.w,D3
                beq     .same_period
                move.b  D3,$fffffa1f.w

.same_period	cmp.b   $fffffa19.w,D1
                beq     .same_div
                move.b  D1,$fffffa19.w

.same_div	move.b  $26(A1),D3
                andi.w  #$ff,D3
                add.w   D3,D2
                bcc     .ok_phaser
                moveq   #0,D2

.ok_phaser	rts

;======================================================================

pattern_check	move.b  (A2)+,D0             ;get note
                beq     no_new_note

                move.b  D0,(A1)              ;$00 - note
                clr.l   $22(A1)              ;clear slide parameters

no_new_note	move.b  (A2)+,D0             ;get instrument
                beq     no_instrument

                andi.w  #$1f,D0
                add.w   D0,D0

                movea.l mod,A3

                adda.l  (A3),A3
                move.w  0(A3,D0.w),D0
                lea     0(A3,D0.w),A3        ;a3 - address of instrument

                moveq   #0,D0
                move.l  #$ff0dff00,D1
                move.b  (A3)+,D0        ;$06 - instrument type
		move.b	6(a1),$2a(a1)	;store old inst type
		
                move.b  D0,6(A1)
		cmp.b	$2a(a1),d0	;compare new with old inst
		beq.s	.skippy
		move.b	#1,$2b(a1)	;different, so set flag
.skippy
                lea     buzz_types,A4
                move.b  0(A4,D0.w),D1
                bmi     no_buzzers
                rol.l   #8,D1
                move.l  D1,$ffff8800.w

no_buzzers	move.b  (A3)+,D0             ;get arpeggio number
                andi.w  #$1f,D0
                add.w   D0,D0

                movea.l mod,A4

                adda.l  4(A4),A4             ;4 is offset for arpeggio table
                move.w  0(A4,D0.w),D0        ;get offset
                lea     0(A4,D0.w),A4
                move.b  (A4),7(A1)           ;$07 - arpeggio speed save
                move.b  (A4)+,$10(A1)        ;$10 - arpeggio speed counter
                move.l  A4,8(A1)             ;$08 - arpeggio start
                move.l  A4,$0c(A1)           ;$0c - arpeggio pointer

                move.b  (A3)+,D0             ;get noise number
                andi.w  #$1f,D0
                add.w   D0,D0

                movea.l mod,A4

                adda.l  8(A4),A4             ;8 is offset for noise table
                move.w  0(A4,D0.w),D0        ;get offset
                lea     0(A4,D0.w),A4
                move.b  (A4),$12(A1)         ;$12 - noise speed save
                move.b  (A4)+,$13(A1)        ;$13 - noise speed counter
                move.l  A4,$14(A1)           ;$14 - noise start
                move.l  A4,$18(A1)           ;$18 - noise pointer

                move.b  (A3)+,$11(A1)        ;$11 - volume

                clr.b   5(A1)                ;$05 - vibrato counter
                clr.b   3(A1)                ;$04 - vibrato width
                clr.b   4(A1)

                move.b  (A3),$1c(A1)         ;$1c - wave speed save
                move.b  (A3)+,$1d(A1)        ;$1d - wave speed counter
                move.l  A3,$1e(A1)           ;$1e - wave pointer

no_instrument	
		moveq	#0,d0
		move.b  (A2),D0
                move.b  D0,1(A1)             ;$01 - effect
                beq     no_effect

                move.b  1(A2),2(A1)          ;$02 - value

		add.b	d0,d0
		add.b	d0,d0
		
		movea.l	code_lookup(pc,d0.w),a5
		jmp	(a5)

code_lookup	
	dc.l	no_effect	;0
	dc.l	fx_slide_up	;1
	dc.l	fx_slide_down	;2
	dc.l	fx_glissando	;3
	dc.l	fx_set_vibrato	;4
	dc.l	fx_phase_change	;5
	dc.l	fx_sidmorph_change	;6
	dc.l	fx_syncbuzz_change	;7
	dc.l	no_effect	;8
	dc.l	no_effect	;9
	dc.l	no_effect	;a
	dc.l	no_effect	;b
	dc.l	fx_set_volume	;c
	dc.l	fx_patt_break	;d
	dc.l	no_effect	;e
	dc.l	fx_speed_change	;f
	
	
fx_set_volume	move.b  2(A1),$11(A1)        ;set volume
                addq.l  #2,A2
		rts

fx_speed_change move.b  2(A1),(A0)           ;set pattern speed
                move.b  2(A1),1(A0)
                addq.l  #2,A2
		rts

fx_phase_change	move.b  2(A1),$26(A1)
                addq.l  #2,A2
		rts

fx_sidmorph_change	move.b  2(A1),$27(A1)	;sid morph
                addq.l  #2,A2
		rts

fx_syncbuzz_change	
		move.b  2(A1),$2c(A1)	;softsid
                addq.l  #2,A2
		rts

fx_set_vibrato	move.b  2(A1),D0             ;set vibrato
                move.b  D0,4(A1)
                add.b   D0,D0
                add.b   D0,D0
                move.b  D0,3(A1)
                addq.l  #2,A2
		rts

fx_slide_up	move.b  2(A1),D0
                neg.b   D0
                ext.w   D0
                move.w  D0,$24(A1)
                addq.l  #2,A2
		rts

fx_slide_down	move.b  2(A1),D0
                ext.w   D0
                move.w  D0,$24(A1)
                addq.l  #2,A2
		rts

fx_glissando	move.b  2(A1),D0
                andi.w  #$ff,D0
                move.w  D0,$24(A1)
                addq.l  #2,A2
		rts

fx_patt_break	clr.b   2(A0)
		addq.l  #2,A2
		rts
no_effect	
		addq.l  #2,A2
		rts

;low-mem stuff starts at $200
timer_code	rte	;200

sound_timer1a	move.l  #$0aff00ff,$ffff8800.w	;202
                move.w  #$212,$0136.w	;20a
                rte	;210

sound_timer2a	move.l  #$0aff00ff,$ffff8800.w	;212
                move.w  #$222,$0136.w
                rte

sound_timer3a	move.l  #$0aff00ff,$ffff8800.w	;222
                move.w  #$232,$0136.w
                rte

sound_timer4a	move.l  #$0aff00ff,$ffff8800.w	;232
                move.w  #$202,$0136.w
                rte

sound_timer1b	move.l  #$09ff00ff,$ffff8800.w	;242
                move.w	#$252,$0112.w
                rte

sound_timer2b	move.l  #$09ff00ff,$ffff8800.w	;252
                move.w  #$262,$0112.w
                rte

sound_timer3b	move.l  #$09ff00ff,$ffff8800.w	;262
                move.w  #$272,$0112.w
                rte

sound_timer4b	move.l  #$09ff00ff,$ffff8800.w	;272
                move.w  #$242,$0112.w
                rte

sound_timer5	move.l	#$0dff0dff,$ffff8800.w	;282
		move.w	#$292,$0136.w
		rte

sound_timer5b	move.w	#$282,$0136.w		;292
		rte

;low-mem stuff ends at $298
; dam0 is proper l4m3

;-------------------------------------------------------------------------------

*** 'Composer relevant data'

                DATA

screen_1        DC.L 0                       ; up there to have PC relative access
free_mem        DC.L 0
free_end        DC.L 0
mod_end         DC.L 0
ls_flag         DC.W 0

key             DC.B 0
keycount        DC.B 0
mousex          DC.W 0
mousey          DC.W 0
mousekey        DC.B 0
hold_flag       DC.B 0
mouseflags      DC.W 0
switch_keys     DC.W 0

patt_pos        DC.W 0
cursor_pos      DC.W 0
old_c_pos       DC.W 17
channel_pos     DC.W 0
current_patt    DC.W 0
current_pos     DC.W 0
curr_patt_base  DC.L 0

hi_lo_flag      DC.W 0

v_on_1          DC.W 1
v_on_2          DC.W 1
v_on_3          DC.W 1

damo1	dc.b	0
damo2	dc.b	0
data_base       DC.L 0
data_y          DC.W 0

note_key        DC.W 0
octave          DC.W 1
instrument      DC.W 1
edit_flag       DC.W 0
play_flag       DC.W 0

channel_tab     DC.W 17,17+48,17+96
position_tab    DC.W 0,16,23,31,32,39

box_save        DC.L 0,0
back_save	DC.L dummy
                DC.W 0
                DC.W 0
                DC.W 0
                DC.W 0
                DC.W 0
                DC.W 0
                DC.W 0

box_x1          DC.W 0
box_y1          DC.W 0
box_x2          DC.W 0
box_y2          DC.W 0

m_pointer	DC.W %1110000000000000
                DC.W %1100000000000000
                DC.W %1000000000000000

dummy           DC.W 0,0,0,0

dummy_track     DC.B 0,0,0,0,0,0,0,0,0,0,0,0

dummy_file      DC.B 'tunetest.snd',0
path            DC.B "*.SND",0
                DS.B 100
                EVEN
filename        DC.B 'TUNETEST.SND'
                DS.B 64
path_n_name     DS.W 64

		* AES Reserved arrays

AESparblock     DC.L control
                DC.L global
                DC.L int_in
                DC.L int_out
                DC.L addr_in
                DC.L addr_out
control         DS.W 5
global          DS.W 16
int_in          DS.W 16
int_out         DS.W 7
addr_in         DS.L 4
addr_out        DS.L 1

buf_tab         DC.L buf0,buf1,buf2,buf3,buf4,buf5,buf6,buf7,buf8,buf9,bufa,bufb
                DC.L bufc,bufd,bufe,buff
buf_cnt         DC.W 0
rot_buf		DS.W 8*2

o               SET 0
noten		DC.B '---',0
                REPT 9
                DC.B 'C ',o+$30,0
                DC.B 'C#',o+$30,0
                DC.B 'D ',o+$30,0
                DC.B 'D#',o+$30,0
                DC.B 'E ',o+$30,0
                DC.B 'F ',o+$30,0
                DC.B 'F#',o+$30,0
                DC.B 'G ',o+$30,0
                DC.B 'G#',o+$30,0
                DC.B 'A ',o+$30,0
                DC.B 'A#',o+$30,0
                DC.B 'B ',o+$30,0
o               SET o+1
                ENDR
                REPT 30
                DC.B '0  ',0
                ENDR

conv_tab	DC.B '0123456789ABCDEF'

font		incbin 'TRACKER.FNT'


*palette	DC.W $002,$502,$143,$215,$103,$325,$547,$667	;<cxt> 2005-02-04
*               DC.W $224,$724,$254,$437,$325,$547,$667,$777

panel		incbin 'panelcxt.PI1'
palette		equ panel+2					;</cxt>

buzz_types	DC.B -1,$0e,$0c,$0e,$0c,-1,$0e,$0e,-1,-1,-1,-1,-1
                EVEN

div_tab		DC.W 0,4,10,16,50,64,100,200

ym2149		DC.L $ff00ff                 ;freq. A
                DC.L $01ff00ff
                DC.L $02ff00ff               ;freq. B
                DC.L $03ff00ff
                DC.L $04ff00ff               ;freq. C
                DC.L $05ff00ff
                DC.L $06ff00ff               ;noise
                DC.L $07ffffff               ;mix
                DC.L $08ff00ff               ;vol. A
                DC.L $09ff00ff               ;vol. B
                DC.L $0aff00ff               ;vol. C
                DC.L $0bff00ff               ;buzz freq.
                DC.L $0cff00ff               ;0

player_data	DC.B 0                       ;$00 - speed counter
                DC.B 6                       ;$01 - speed save
                DC.B 0                       ;$02 - pattern counter
                DC.B 0
                DC.L 0                       ;$04 - start of current pattern
                DC.L 0                       ;$08 - current position
                DC.L 0
                DC.L 0

track1_data	DC.B 0                       ;$00 - note
                DC.B 0                       ;$01 - effect
                DC.B 0                       ;$02 - value
                DC.B 0                       ;$03 - vibrato width
                DC.B 0                       ;$04 - vibrato speed
                DC.B 0                       ;$05 - vibrato count
                DC.B 0                       ;$06 - instrument type
                DC.B 0                       ;$07 - arpeggio speed
                DC.L 0                       ;$08 - arpeggio start
                DC.L 0                       ;$0c - arpeggio pointer
                DC.B 0                       ;$10 - arpeggio speed counter
                DC.B 0                       ;$11 - volume
                DC.B 0                       ;$12 - noise speed
                DC.B 0                       ;$13 - noise counter
                DC.L 0                       ;$14 - noise start
                DC.L 0                       ;$18 - noise pointer
                DC.B 0                       ;$1c - wave speed
                DC.B 0                       ;$1d - wave counter
                DC.L 0                       ;$1e - wave pointer
                DC.W 0                       ;$22 - slide position
                DC.W 0                       ;$24 - slide value
                DC.B 0                       ;$26 - phase
                DC.B 0                       ;$27 - softsid
                DC.W 0                       ;$28 - old frequency
                DC.W 0				;$2a - timer freq 1
                DC.W 0				;$2c - timer freq 2
                DC.W 0				;$2e - timer freq 3
                DC.W 0				;$30 - timer freq 4
                DC.W 0				;$32 - timer freq 5
                DC.W 0				;$34 - timer freq 6
                DC.W 0				;$36 - timer freq 7
                DC.W 0				;$38 - timer freq 8
                EVEN

track2_data	DC.B 0                       ;$00 - note
                DC.B 0                       ;$01 - effect
                DC.B 0                       ;$02 - value
                DC.B 0                       ;$03 - vibrato width
                DC.B 0                       ;$04 - vibrato speed
                DC.B 0                       ;$05 - vibrato count
                DC.B 0                       ;$06 - instrument type
                DC.B 0                       ;$07 - arpeggio speed
                DC.L 0                       ;$08 - arpeggio start
                DC.L 0                       ;$0c - arpeggio pointer
                DC.B 0                       ;$10 - arpeggio speed counter
                DC.B 0                       ;$11 - volume
                DC.B 0                       ;$12 - noise speed
                DC.B 0                       ;$13 - noise counter
                DC.L 0                       ;$14 - noise start
                DC.L 0                       ;$18 - noise pointer
                DC.B 0                       ;$1c - wave speed
                DC.B 0                       ;$1d - wave counter
                DC.L 0                       ;$1e - wave pointer
                DC.W 0                       ;$22 - slide position
                DC.W 0                       ;$24 - slide value
                DC.B 0                       ;$26 - phase
                DC.B 0                       ;$27 - softsid
                DC.W 0                       ;$28 - old frequency
                DC.b 0				;$2a - old inst number
                DC.b 0				;$2b - inst change flag
                DC.W 0				;$2c - sync buzzer data
                DC.W 0				;$2e - timer freq3
                DC.W 0				;$30 - timer freq4
                DC.W 0				;$32 - timer freq 5
                DC.W 0				;$34 - timer freq 6
                DC.W 0				;$36 - timer freq 7
                DC.W 0				;$38 - timer freq 8
                EVEN

track3_data	DC.B 0                       ;$00 - note
                DC.B 0                       ;$01 - effect
                DC.B 0                       ;$02 - value
                DC.B 0                       ;$03 - vibrato width
                DC.B 0                       ;$04 - vibrato speed
                DC.B 0                       ;$05 - vibrato count
                DC.B 0                       ;$06 - instrument type
                DC.B 0                       ;$07 - arpeggio speed
                DC.L 0                       ;$08 - arpeggio start
                DC.L 0                       ;$0c - arpeggio pointer
                DC.B 0                       ;$10 - arpeggio speed counter
                DC.B 0                       ;$11 - volume
                DC.B 0                       ;$12 - noise speed
                DC.B 0                       ;$13 - noise counter
                DC.L 0                       ;$14 - noise start
                DC.L 0                       ;$18 - noise pointer
                DC.B 0                       ;$1c - wave speed
                DC.B 0                       ;$1d - wave counter
                DC.L 0                       ;$1e - wave pointer
                DC.W 0                       ;$22 - slide position
                DC.W 0                       ;$24 - slide value
                DC.B 0                       ;$26 - phase
                DC.B 0                       ;$27 - softsid
                DC.W 0                       ;$28 - old frequency
                DC.b 0				;$2a - old inst number 
                DC.b 0				;$2b - inst change flag 
                DC.W 0				;$2c - sync buzzer data
                DC.W 0				;$2e - timer freq3
                DC.W 0				;$30 - timer freq4
                DC.W 0				;$32 - timer freq 5
                DC.W 0				;$34 - timer freq 6
                DC.W 0				;$36 - timer freq 7
                DC.W 0				;$38 - timer freq 8
                EVEN

frequency_tab	DC.B 0,0,14,238,14,24,13,75,12,140,11,218,11,48
                DC.B 10,145,9,246,9,105,8,225,8,96
                DC.B 7,234,7,120,7,12,6,165,6,72
                DC.B 5,237,5,151,5,71,4,251,4,180
                DC.B 4,112,4,48,3,244,3,187,3,134
                DC.B 3,83,3,35,2,246,2,203,2,163
                DC.B 2,125,2,90,2,56,2,24,1,250
                DC.B 1,221,1,195,1,169,1,145,1,123
                DC.B 1,101,1,81,1,62,1,45,1,28
                DC.B 1,12,0,253,0,238,0,225,0,212
                DC.B 0,200,0,189,0,178,0,168,0,159
                DC.B 0,150,0,142,0,134,0,126,0,119
                DC.B 0,112,0,106,0,100,0,94,0,89
                DC.B 0,84,0,79,0,75,0,71,0,67
                DC.B 0,63,0,59,0,56,0,53,0,50
                DC.B 0,47,0,44,0,42,0,39,0,37
                DC.B 0,35,0,33,0,31,0,29,0,28
                DC.B 0,26,0,25,0,23,0,22,0,21
                DC.B 0,19,0,18,0,17,0,16,0,15
                DC.B 0,0,0,0,0,0,0,0,0
                DC.B 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                DC.B 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                DC.B 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                EVEN

buzzfreqtab	DC.B 0,240,226,212,200,190,178,168,158,150,142,134,126
                DC.B 120,113,106,100,95,89,84,79,75,71,67,63
                DC.B 60,56,53,50,47,45,42,40,38,36,34,32
                DC.B 30,28,27,25,24,22,21,20,19,18,17,16
                DC.B 15,14,13,12,12,11,11,10,9,9,8,8,7,6,5,4,3,2,1
                EVEN

future_freq	incbin 'FUTURE.FRQ'

;-------------------------------------------------------------------------------

*** 'Sounddata'

mod             DC.L free

;------------------------------------------------------------------------------

                BSS
bss_start 

block_buf	DS.B 4*128
block_start	ds.w	1
block_end	ds.w	1
block_size	ds.w	1
*** 'Saveregs'             ; Space for all the backupped hw-registers

mfp_registers   DS.L 4
auto_vec_save   DS.L 8
mfp_vec_save    DS.L 16

oldres          DS.B 1
oldsync         DS.B 1
oldpalette      DS.L 8
oldscreen       DS.W 1

oldstack        DS.L 1
old_sr          DS.W 1

sound_save      DS.B 16
keyboard_save   DS.B 13*8
vsync_count     DS.L 1

*** 'Stack'

                DS.B 512                     ; 512 bytes stack

*** 'Screens'

stack		DS.B 256                     ; because of screen lowbyte reserve 256 more

screen_base     DS.B 32000+160*56            ; space for two screens

buf0            DS.B 40*8
buf1            DS.B 40*8
buf2            DS.B 40*8
buf3            DS.B 40*8
buf4            DS.B 40*8
buf5            DS.B 40*8
buf6            DS.B 40*8
buf7            DS.B 40*8
buf8            DS.B 40*8
buf9            DS.B 40*8
bufa            DS.B 40*8
bufb            DS.B 40*8
bufc            DS.B 40*8
bufd            DS.B 40*8
bufe            DS.B 40*8
buff            DS.B 40*8

bss_end 

free		END
