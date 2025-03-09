
;		       JAGGED MUSIC/FX SOURCE FILES

;		 MUSIC AND DRIVER REMAIN COPYRIGHT D.LOWE FOR UAMS

;	        Glyn ...Do you want to buy a pc on the cheap!!!!
;   	 I've also made this driver turn of the keyboard as I know
;			you prefer it that way

;	If you assemble this and run it as stand alone code
;	you can step through the fx using (down arrow) for same fx
;	and (right arrow) for next fx.Its probaly best to disable
;	The music (see below) if trying to decide what fx to use
;	for what.I have left the samples disabled see below
;	these run on timer a....they play every five seconds
;	when testing.		
;	Its probaly easier to ring me with any queries...??
;	ps..Theres a volume control for the music only on key v
;	you might want to chuck this out.. see below
;	(Its set about right to stop it blowing out the sample fx.)
;	pps.. the arrow keys sometimes cut the fx short
;	when testing the chip fx...and I havent got a clue why.
;	It doesnt happen when the fx are called properly ie
;	when run ingame.(maybe some spotty kids might know).


;	FX SAMPLES.........1	torpedo in bath
;			   2	torpedo in bigger bath	
;			   3-6  various explosions				

;  	CHIP FX list

	; 1	alarm1
	; 2	alarm2
	; 3	alarm3
	; 4	click_fx	;empty guns..single click	
	; 5	exp1		;chip explosion
	; 6	exp2		;short chip explosion
	; 7	missile4	; launch missile/weapon	
	; 8	missile5	; launch missile/weapon	
	; 9	missile6	; launch missile/weapon	
	; 10	turbo1		; turbo to 1st level
	; 11	turbo2		; turbo to 2st level
	; 12	turbo3		; turbo to 3rd level
	; 13	pop_gun1	; variation   very short
	; 14	enemy pop gun	; high pitched very short
	; 15	your_pop gun	; lower pitch very short
	; 16	wheel_skid	; jumbo jet touchdown ?
	; 17	panel_slide	; panel sliding sound..ish
	; 18	waves....sea side etc/chucked out seagull sample(to big)

	;;;  MUSIC NUMBERS
	
	;   tune 1............title tune/and level music
	;   tune 2............level music
	;   tune 3............level music
	;   tune 4............level/high score
	;   tune 5............change level/win jingle

;			0723 870648 .... Dave Lowe

B08:  equ  16
Bb08:  equ  17
A08:  equ  18
Ab08:  equ  19
G08:  equ  20
Gb08:  equ  21
f08:  equ  22
E08:  equ  24
Eb08:  equ  25
D08:  equ  27
Db08:  equ  28
C08:  equ  30
;  ********

;  *********
B07:  equ  32
Bb07:  equ  34
A07:  equ  36
Ab07:  equ  38
G07:  equ  40
Gb07:  equ  42
f07:  equ  45
E07:  equ  47
Eb07:  equ  50
D07:  equ  53
Db07:  equ  56
C07:  equ  60
;  ********
;  *********
B06:  equ  63
Bb06:  equ  67
A06:  equ  71
Ab06:  equ  75
G06:  equ  80

Gb06:  equ  84
f06:  equ  89
E06:  equ  95
Eb06:  equ  100
D06:  equ  106
Db06:  equ  113
C06:  equ  119
;  ********
;  *********
B05:  equ  127
Bb05:  equ  134
A05:  equ  142
Ab05:  equ  150
G05:  equ  159
Gb05:  equ  169
f05:  equ  179
E05:  equ  190
Eb05:  equ  201
D05:  equ  213
Db05:  equ  225
C05:  equ  239
;  ********
;  *********
B04:  equ  253
Bb04:  equ  268
A04:  equ  284
Ab04:  equ  301
G04:  equ  319
Gb04:  equ  338
f04:  equ  358
E04:  equ  379
Eb04:  equ  402
D04:  equ  426
Db04:  equ  451
C04:  equ  478
;  ********
;  *********
B03:  equ  506
Bb03:  equ  536
A03:  equ  568
Ab03:  equ  602
G03:  equ  638
Gb03:  equ  676
f03:  equ  716
E03:  equ  758
Eb03:  equ  804
D03:  equ  851
Db03:  equ  902
C03:  equ  956
;  ********
;  *********
B02:  equ  1012
Bb02:  equ  1073
A02:  equ  1136
Ab02:  equ  1204
G02:  equ  1276
Gb02:  equ  1351
f02:  equ  1432
E02:  equ  1517
Eb02:  equ  1607
D02:  equ  1703
Db02:  equ  1804
C02:  equ  1911
;  ********
;  *********
B01:  equ  2025
Bb01:  equ  2145
A01:  equ  2273
Ab01:  equ  2408
G01:  equ  2551
Gb01:  equ  2703
f01:  equ  2863
E01:  equ  3034
Eb01:  equ  3214
D01:  equ  3405
Db01:  equ  3608
C01:  equ  3822
;  ********


select_reg   equ $ffff8800
write_data   equ $ffff8802
end_patt    equ 0
end_song    equ $ffffffff
end_data    equ $ff
new_env   equ 4
new_sound    equ 8
pbend    equ 12
octaves   equ 20
endfx_patt	equ 36
hold		equ 40
holdoff	equ 44
cem     equ 20
up     equ 3
down    equ 2
auto    equ 1
man     equ 0
modon    equ 16
modoff   equ 24
pboff    equ 28
bendoff		equ 28
inline   equ 32
rpto    equ $01
rptc    equ $02
trigg	equ 0
notrigg equ 1

CR  	set 20
tcr1 	set 11
tcr2 	set 10
Q   	set CR/2
tq1  	set 5
tq2  	set 6
tsq1 	set 3
tsq2 	set 2
SQ  	set Q/2
m   	set 254
rest 	set $fd00
dcr  	set cr+q
dq  	set q+sq
dsq  	set sq+(sq/2)
sb  	set cr*4
min  	set cr*2
dm  	set min+cr


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


t1     equ %00001000
n1     equ %00000001
b1     equ %00000000
t2     equ %00010000
n2     equ %00000010
b2     equ %00000000
t3     equ %00100000
n3     equ %00000100
b3     equ %00000000

;       ***********************************
;  THIS WHOLE SECTION IS A SHORT CONTROL SECTION TO POKE NUMBERS
;  INTO THE FX BUFFERS TO ENABLE YOU TO ASSEMBLE AND RUN IT WITHOUT   
;  ANY INTERRUPT ROUTINEs ETC......Delete it when not needed

		   jsr super
;  disable key click for volume control...You probably have your own
		MOVE.B $484,D0		;routines for keyboard etc.So I've kept
		AND.B #$FE,D0		;this bit in the deletable section
		MOVE.B D0,$484

 ; test for screen res
   		move.w #4,-(sp)
   		trap #14
  		addq.l #2,sp
  		cmp.w #2,d0
  		beq high_res
; screen to med res
  		move.w #1,-(sp)
   		move.l #-1,-(sp)
  		move.l #-1,-(sp)
   		move.w #5,-(sp)
   		trap #14
  		add.l #12,sp

high_res:
   		move.w col_byte,d0
   		JSR colour
   		move.w d0,col_byte
   		EORi.w #1,D0
   		jsr colour
   		lea ua_mess,a1
   		jsr print
   		LEA TOGGLE_MESS_OFF,a1
   		jsr print
   		LEA TITLE_MESS_POS,A1
   		JSR PRINT
   		jsr select_new_song
		call_loop:


   		cmp.w #0,timer3
   		beq testkey
   		sub.w #1,timer3
  		 bra nokey

testkey:
   		CMP.B #$39,$FFFC02
   		bne nokey
relkey:		clr.b $fffc02
   		move.w #100,timer3

   		move.l song_buffer,d0
   		addq.l #1,d0
   		cmpi.l #4,d0	;songs +1
   		bne okay
   		move.l #1,d0
okay:		 move.l d0,song_buffer
   		jsr SELECT_NEW_SONG

nokey:
   		jsr interrupt
   		jsr sfxdriver

; see if change of toggle required
   		CMP.B #$3a,$FFFC02
   		bne no_change
   		TST.W timer4
   		bne no_change

; toggle sound fx and print to screen
   		tst.w fx_toggle
   		bne off
   		lea toggle_mess_on,a1
   		jsr print
   		bra tj1
off:   		lea toggle_mess_off,a1
   		jsr print
tj1:  		 move.w #200,timer4
   		bchg #0,fx_toggle
NO_CHANGE:
   		tst.w timer4
  		 beq t4ok
   		sub.w #1,timer4
t4ok:
   		tst.w fx_toggle
   		bne toggle_ok
   		bra call_loop

TOGGLE_ok:
;   SAMPLE FX CONTROL
   		subi.w #1,timer
   		cmpi.w #0,timer
   		bne call_loop1
  		 move.l yyy,d0
   		addi.l #1,d0
   		cmpi.l #max_sam,d0
   		bne jjj
   		move.l #1,d0

jjj:  		;move.l d0,fx_buffer  ;THIS INSTRUCION WILL ENABLE/DISABLE
				      ;THE SAMPLES FOR TESTING..
   		move.l d0,yyy
  		 move.w #800,timer
   		bra call_loop
call_loop1:

; chip fx control


		tst.w timer1
		beq new_fx	
		sub.w #1,timer1
		bra call_loop

new_fx
		move.l yyy1,d0
		cmp.b #$50,$fffc02
		beq same_fx

		cmp.b #$4d,$fffc02
   		bne call_loop

  	 	move.l yyy1,d0
   		addi.l #1,d0
   		move.l max_chfx,d1
   		cmp.l d1,d0
   		bne no_reset_chfx
   		move.l #1,d0
no_reset_chfx  
		move.l d0,yyy1
same_fx
		jsr set_up_chip_fx
		move.w #5,timer1

   		bra call_loop
 even
timer: dc.w 3
yyy: dc.l 0
timer1: dc.w 70
yyy1: dc.l curr_fx
timer3: dc.w 0
fx_toggle: dc.w 0
timer4: dc.w 0
col_byte: dc.w -1
print_store: dc.l title_mess
; +++++++++++
print:
; a1 is pointer to data
ploop:
 		MOVE.B (A1)+,D0
 		CMPI.B #255,D0
 		BNE DOP
		 RTS
dop: 		jsr print_sub
   		bra ploop
print2:
		 clr.l d3
 		MOVE.W #13,D3
		ploop2:
 		MOVE.B (A1)+,D0
 		JSR PRINT_SUB
 		DBRA D3,PLOoP2
 		RTS
dop2: 		jsr print_sub
   		bra ploop2


 ; character to print in d0
print_sub:
  		move.w d0,-(sp) ; value to print
  		move.w #2,-(sp)
  		trap #1
  		addq.l #4,sp
  		rts

ua_mess:
 		dc.b 27,'b',0,27,'c',1


 		dc.b 27,'E'     ; CLEAR SCREEN
 		dc.b 27,'Y',32+7,32+32
             	dc.b ' UNCLE~ART '
 		dc.b 27,'Y',32+9,32+26
         	dc.b 'Computer Music Specialists'
 		dc.b 27,'Y',32+10,32+30,' Tel:0723 870648 '



 		dc.b 27,'Y',32+16,32+6
 		dc.b '             Caps Lock to toggle FX/V for MUSIC volume'
        	dc.b 0
toggle_mess_off:
 		dc.b 27,'Y',32+18,32+30,'¯¯¯¯ FX OFF ®®®®'

 		dc.b 27,'Y',32+19,32+30,'     FX  ON     '

 		dc.b 255
toggle_mess_on:
 		dc.b 27,'Y',32+18,32+30,'     FX OFF     '

 		dc.b 27,'Y',32+19,32+30,'¯¯¯¯ FX  ON ®®®®'
 		dc.b 255

title_mess_pos:
 		dc.b 27,'Y',32+15,32+20
title_mess:
 		dc.b  '* LINE OF FIRE MUSIC/FX *'
 		dc.b 27,'Y',32+13,32+14
 		dc.b ' '
 		dc.b 27,'f'
 		dc.b 255,0
	even
colour:
  		move.w d0,-(sp)
  		move.w #0,-(sp)
  		move.w #7,-(sp)
  		trap #14
  		add.w #6,sp
 		 rts
;			END OF CONTROL(deletable)SECTION
;		*********************************

; 		 **********************************
; 		 FLAGS/VARIABLES FOR ACCESS BY PROGRAMMER
;			 DURING RUN TIME		

fx_disable:	dc.w 0	 ;fx disable flag	 1=disable
music_disable:  dc.w 1  ;music disable		 1=disable

fx_buffer: 	dc.l 0	 ;sample fx number required  
song_buffer: 	dc.l 1  ;which piece of music  1 to 5
;		 **********************************

;	 ALL INTERNAL FLAGS/VARIABLES USED INTERNALLY BY THE DRIVER 
chip_fx_on 	dc.w 0
FXBUFFER:	 dc.l 0
backup_buffer: 	dc.l 0
fxcount: 	dc.b 0
fx_patt_f: 	dc.w 0
fx_patt_point: 	dc.l 0
fx_int: 	dc.l 0
curr_fx_fin: 	dc.w 0
duck 		dc.b 0,0
curr_mix 	dc.b %11111111,0
mod2_flag 	dc.w 0
altpf: 		dc.w 0
temp: 		dc.l 0
which_chip 	dc.l 0
no_reg: 	dc.l 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
sample_flag:	dc.w 0
fx_flag:	dc.w %0000000000000000
curr_chann:	dc.w 0
start_patt: 	dc.b m,end_patt
start_song: 	dc.l $ffffffff
curr_comp:	dc.b 3,0
vol_count:	dc.w 6
hold_val_p:	dc.w 0,0
sfxflag		dc.w 0
int_flag	dc.w 0
; ******************************

;  SUBROUTINE TO KILL CHIP...does not save registers

; call here to kill all three channels
kill_chip:
		move.w #13,d0
kloop		move.b d0,select_reg
		move.b #0,write_data
		dbra.w	d0,kloop 
   		move.b #7,select_reg
; turn mixer off
   		move.b #%11111111,write_data
   		rts
; *************************************
 ; SONG SELECTION subroutine...call here AFTER poking number of required
;	piece into song_buffer

select_new_song:
		move.w #1,int_flag
		 jsr kill_chip 
 		move.l #74,d0
 		lea vars1,a0
		clear_loop:
 		move.w #0,(a0)+
 		dbra d0,clear_loop
 		clr.l backup_buffer
 		clr.b fxcount
 		clr.l d0
 		move.l song_buffer,d1
 		add d1,d0
 		add d1,d0
 		add d1,d0
 		add d1,d0
 		add d1,d0
 		add d1,d0
 		add d1,d0
 		add d1,d0
 		add d1,d0
 		add d1,d0
 		add d1,d0
 		add d1,d0
 		LEA SONG_TABLE-12,A1
 		add.l d0,a1 
 		MOVE.L (A1)+,WSONG1 
  		move.l (a1)+,wsong2 
  		move.l (a1),wsong3
  		MOVE.L #START_PATT,PATTR1
  		MOVE.L #start_patt,PATTR2
  		MOVE.L #start_patt,PATTR3
  		move.l #start_song,songr1
  		MOVE.L #start_song,SONGR2
  		MOVE.L #start_song,SONGR3
  		move.w #0,intc1
  		move.w #0,intc2
  		move.w #0,intc3
		clr.w int_flag
  		rts

;****************************************
	;  CALL HERE WITH D0 HOLDING THE long word value
	;  of the fx you want/  see fx list

set_up_chip_fx
		add d0,d0
		add d0,d0
		lea chfx_table-4,a0
		move.l (a0,d0),a1	
		btst #0,fx_flag+1
		bne checkfx2
use1		move.l a1,fxpattr1
		bset #0,fx_flag+1
		rts
checkfx2: 	btst #1,fx_flag+1
		bne checkfx3	
		move.l a1,fxpattr2
		bset #1,fx_flag+1
		rts
checkfx3: 	btst #2,fx_flag+1
		bne overwrite
		move.l a1,fxpattr3
		bset #2,fx_flag+1
overwrite
		lea fxvars1,a0
		jsr clear_fx_1
		bra use1
;*************************************
; CALL HERE ON 50hz INTERRUPT TO PLAY MUSIC/SAMPLES AND FX
; TO PLAY SAMPLE  PLACE NUMBER FROM INCLUDED LISTS INTO..fx_buffer
; TO PLAY CHIP FX CALL ABOVE ROUTINE AS DESCRIBED ABOVE
; TO SELECT WHICH PIECE OF MUSIC PLACE NUMBER FROM INCLUDED
; LIST INTO....song_buffer AND CALL select_new_song
; TO DISABLE MUSIC PLACE A 1 INTO music_disable/0 TO RENABLE
; TO DISABLE SAMPLES/FX PLACE A 1 INTO fx_disable/0 TO RENABLE
; SEE LINE FURTHER  DOWN  FOR MUSIC VOLUME CONTROL
; THERE IS NO NEED TO DISABLE THE 50hz INTERRUPT WHEN USING THE
; ABOVE FUNCTIONS

sfxdriver:
		movem.l a0-a5/d0-d7,-(a7)
		jsr driver
		movem.l (a7)+,a0-a5/d0-d7
 		rts	;YOU PROBABLY NEED TO CHANGE THIS TO RTE WHEN RUNNING
		;IT FROM THE VBI

; *************************************
driver:
		tst.w int_flag
		beq on_line
		rts
on_line   	tst.w fx_disable
   		bne mdriver   
  		tst.l fx_buffer 
		bne set_up_s
   		tst.w fx_patt_f
   		bne fx_in_use
  		bra mdriver 
set_up_s
   		clr.w chip_fx_on
  		move.l fx_buffer,d0
  		add d0,d0
  		add d0,d0  
  		MOVE.L #PATT_TABLE,A1
  		move.l (a1,d0),a2 
set_up_fx: 
		move.l (a2)+,a1 
  		move.l (a2)+,fx_int 
  		move.l a2,fx_patt_point
  		clr.w curr_fx_fin
  		move.l (a1)+,sam_speed
  		move.l (a1)+,sam_end
 		move.l (a1)+,sam_start
  		move.l #0,fx_buffer
 		move.w #1,fx_patt_f 
  		jsr main_program
		move.w #1,sample_flag
 		bra mdriver 
fx_in_use:
	 	tst.w curr_fx_fin 
  		beq mdriver 
 		move.l fx_patt_point,a2
  		cmpi.l #255,(a2) 
  		bne check_delay
  		clr.w fx_patt_f
		move.w #0,sample_flag
		jsr kill_chip
  		beq mdriver
  		bra mdriver
CHECK_DELAY: 	TST.L FX_INT
  		beq set_up_fx
  		sub.l #1,fx_int
		bra mdriver 


patt_table: 	dc.l 0,fxp1,fxp2,fxp3,fxp4,fxp5,fxp6


fxp1: 		dc.l ssplash8,0,255
fxp2: 		dc.l ssplash8,0,255
fxp3: 		dc.l explosi8,0,255
fxp4: 		dc.l explosi85,0,255
fxp5: 		dc.l explosi83,0,255
fxp6:
	 	dc.l explosi8s,0
	 	dc.l explosi5s,0
	 	dc.l explosi3s,0
	 	dc.l explosi6s,0
	 	dc.l explosi9s,0
	 	dc.l explosi10s,0
	 	dc.l explosi5s,0
	 	dc.l explosi83,0,255


ssplash8	dc.l 7,6728+ssplash8d,ssplash8d
explosi8	dc.l 8,4882+explosi8d,explosi8d
explosi8s	dc.l 8,1200+explosi8d,explosi8d
explosi7s	dc.l 7,1200+explosi8d,explosi8d
explosi6s	dc.l 6,1200+explosi8d,explosi8d
explosi5s	dc.l 5,1200+explosi8d,explosi8d
explosi10s	dc.l 10,1200+explosi8d,explosi8d
explosi3s	dc.l 3,1200+explosi8d,explosi8d
explosi9s	dc.l 9,1200+explosi8d,explosi8d

explosi85	dc.l 5,4882+explosi8d,explosi8d
explosi83	dc.l 3,4882+explosi8d,explosi8d

max_sam		equ 7

;**********************************************

clear_chip:	RTS
SAM_SPEED DC.L 0
SAM_END DC.L 0
SAM_START DC.L 0
		MAIN_PROGRAM:
 		jsr kill_chip
		 MOVE.l SAM_SPEED,D0
 		EXT.W D0
 		SUBQ.L #2,D0
 		lSL.w #1,D0
 		MOVE.L SAM_START(PC),sample+2 
 		LEA SPEEDS(PC),A0
 		MOVE.L #interupt,$134 
 		MOVE.W 0(A0,D0.W),D0
 		MOVE.B D0,$FFFA19 
 		LSR.W #8,D0
 		MOVE.B D0,$FFFA1F
 		MOVE.B #$20,$FFFA13 
  		MOVE.B #$20,$FFFFA07 
		 rts
		INTERUPT: ORI.W #$0700,SR 
		 MOVEM.L D0-D2/A0-A2,-(SP) 
 		CLR.W D0 
 		MOVE.L SAM_END,A1
 		LEA SAMPLE+2,A2
		SAMPLE: MOVE.B $00000000,D0 
 		ADDQ.L #1,(A2) 
 			AND.B #$FC,D0
 		LEA CHANEL_A,A0
 		MOVE.W #$0900,D1 
 			MOVE.W #$0A00,D2 
 		MOVE.B 1(A0,D0.W),D1
 		MOVE.B 3(A0,D0.W),D2
 		LEA $FFF8800,A0 
 		MOVEP.W D1,0(A0)
		 MOVEP.W D2,0(A0) 
 		CMPA.L (A2),A1 
 		BLT.S STOP_INTERUPT
 		MOVEM.L (SP)+,D0-D2/A0-A2 
 		BCLR #5,$FFFA0F 
 		RTE 
STOP_INTERUPT: 		BCLR #5,$FFFA19 
 		BCLR #5,$FFFA07 
		 MOVEM.L (SP)+,D0-D2/A0-A2 
 		BCLR #5,$FFFA0F 
 			move.w #1,curr_fx_fin
 			clr.b duck
 		RTE
super:  
  		 move sr,d0
   		andi #$2000,d0
   		bne coldst
   		clr.l -(sp)
   		move.w #$20,-(sp)
   		trap #1
   		add.l #6,sp
   		lea temp,a1
   		MOVE.L D0,(a1)
coldst:   	rts
user:
   		move.l temp,-(sp)
   		move.w #$20,-(sp)
   		trap #1
   		add.l #6,sp
   		rts
interrupt:  	moveq #4,d1
wait2:  	move.l $4ba,d6
wait:  		cmp.l $4ba,d6
   		beq wait
   		subq #1,d1
   		bne wait2
   		rts


;+++++++++++++++++++++++++++++++++++++++++++++++++

mdriver: 

		move.w #1,curr_chann
		move.l #select_reg,a4
		move.l #curr_mix,a5
		tst.w sample_flag	
		beq do1	
		move.l #no_reg,a4
do1: 
  		lea VARS1,A0 
		btst.b #0,fx_flag+1
		beq do1music
		lea fxvars1,a0
 		moveq.l #0,d0 
  		moveq.l #1,d1 
  		moveq.l #8,d2 
 		move.b #%11110110,d7
		jsr check_count_1
			move.l #no_reg,a4
		move.l #no_reg,a5
 		lea VARS1,A0 
		jsr check_count_1
		bra chan2
do1music:
		tst.w music_disable
		bne chan2
  		moveq.l #0,d0 
  		moveq.l #1,d1 
  		moveq.l #8,d2 
  		move.b #%11110110,d7
  		jsr check_count_1
;	******************************

chan2:
		move.w #2,curr_chann
  		move.l #select_reg,a4
		move.l #curr_mix,a5
		tst.w sample_flag	
		beq do2	
		move.l #no_reg,a4
do2  		lea vars2,a0
		btst.b #1,fx_flag+1
		beq do2music
		lea fxvars2,a0
  		moveq.l #2,d0
  		moveq.l #3,d1
   		moveq.l #9,d2
   		move.b #%11101101,d7
		jsr check_count_1
		move.l #no_reg,a4
		move.l #no_reg,a5
  		lea vars2,a0
			jsr check_count_1
		bra chan3
do2music:
		tst.w music_disable
		bne chan3
  		 moveq.l #2,d0
  		 moveq.l #3,d1
   		moveq.l #9,d2
   		move.b #%11101101,d7
   		jsr check_count_1
chan3:
		move.w #4,curr_chann
		move.l #select_reg,a4
		move.l #curr_mix,a5
		tst.w sample_flag	
		beq do3	
		move.l #no_reg,a4
do3   		lea vars3,a0
		btst.b #2,fx_flag+1
		beq do3music
		lea fxvars3,a0
   		moveq.l #4,d0
   		moveq.l #5,d1
   		moveq.l #10,d2
   		move.b #%11011011,d7
		jsr check_count_1
		move.l #no_reg,a4
		move.l #no_reg,a5
  		lea vars3,a0
		jsr check_count_1
		rts
do3music:
		tst.w music_disable
		beq dochan2
		rts
dochan2:
   		moveq.l #4,d0
   		moveq.l #5,d1
   		moveq.l #10,d2
   		move.b #%11011011,d7
   		jsr check_count_1
  		 rts
process_data:
get_new_patt:	  move.l 12(A0),a1 
   		CMPI.B #END_song,(A1) 
   		bne get_patt_a 
   		move.l 16(a0),12(a0) 
   		move.l 12(a0),a1 
get_patt_a:
song_cont_ret:
   		move.l (a1),4(a0) 
   		addq.l #4,a1
   		move.l a1,12(a0)
   		move.w #1,(a0)
   		bra get_new_note
check_count_1:  tst.w 2(a0) 
   		BEQ gET_NEW_NOTE 
   		MOVE.W #0,ALTPf 
   		subq.w #1,2(a0) 
   		move.w 28(a0),d6 
   		tst.b 26(a0) 
   		beq octaves_on
   		tst.w 48(a0)
   		beq contbend
   		subq #1,48(a0)
   		bra octaves_on
contbend:  	addq #1,altpf  
   		clr.w d4
   		move.b 27(a0),d4 
   		move.w 42(a0),d5 
   		cmpi.b #2,26(a0) 
   		beq pbup
		 sub.w d4,d6
   		cmp.w d6,d5
   		bcs octaves_on
   		bra fbend
pbup:  		add.w d4,d6
   		cmp.w d6,d5
   		bcc octaves_on
fbend:  	move.w d5,d6
   		CLR.B 26(A0) 
octaves_on:
   		cmpi.b #5,38(a0) 
   		bls ch_mod_on 
   		addq.b #1,altpf
   		cmpi.b #8,38(a0) 
   		bcc upoct
   		asl #1,d6  
   		addq.b #1,38(a0) 
   		bra send_altered_pitch
upoct:  	asr #1,d6
   		addq.b #1,38(a0)
   		cmpi.b #10,38(a0)
   		bne send_altered_pitch
   		move.b #6,38(a0) 
   		BRA SEND_ALTERED_PITCH
ch_mod_on:
   		tst.b 38(a0) 
   		beq send_altered_pitch 
   		tst.w 44(a0) 
   		beq check_speed
   		subq #1,44(a0)
   		bra send_altered_pitch
check_speed:  	tst.b (a0)
   		beq contmod
   		subq.b #1,(a0)
   		bra send_altered_pitch
contmod:
   		move.b 1(a0),(a0) 
   		addq.b #1,altpf 
   		cmpi.b #3,38(a0)
   		bcc addmod
   		move.w 34(a0),d4
   		sub.w d4,d6 
   		addq.b #1,38(a0) 
   		bra send_altered_pitch
addmod:  	move.w 36(a0),d4
   		add.w d4,d6
   		addq.b #1,38(a0)
   		cmpi.b #5,38(a0)
   		bne send_altered_pitch
   		move.b #1,38(a0) 
		SEND_ALTERED_PITCH: tst.w (ALTPF)
   		beq send_env
   		move.w d6,28(a0)
   		move.b d1,(a4)
   		move.b 28(a0),2(a4)
   		move.b d0,(a4)
   		move.b 29(a0),2(a4)
send_env:  
   		tst.w hold_val_p
		beq no_hold
		move.b hold_val_p,(a4)
		move.b hold_val_p+1,2(a4)
no_hold:
   		move.l 8(a0),a2
   		cmpi.b #255,(a2) 
   		bne more_env
		sub.l #2,a2
more_env:
		move.w fx_flag,d4
		and.w curr_chann,d4	
		cmpi.w #0,d4
		beq music_only
   		move.b d2,(a4)
   		move.b (a2)+,d5
   		move.b d5,2(a4) 
   		move.b #7,(a4) 
   		and.b d7,(a5)
   		move.b (a2)+,d2
		cmpi.w #1,d4
		beq cont_env
		asl.b #1,d2
		cmpi.w #2,d4
		beq cont_env 
		asl.b #1,d2
cont_env:
   		or.b d2,(a5)
   		move.b (a5),2(a4)
   		move.l a2,8(a0)  
no_more_envelope: rts
music_only:
  CMP.B #$2f,$FFFC02	; check `v` key for music volume change
		bne no_vol_change	
		subq.w #1,vol_count
		tst.w vol_count
		bne no_vol_change
		move.w #50,vol_count	
		subq.b #1,curr_comp
		bcc no_vol_change
		move.b #13,curr_comp
no_vol_change
   		move.b d2,(a4)
   		move.b (a2)+,d5
   		sub.b curr_comp,d5 
   		move.b d5,2(a4) 
   		move.b #7,(a4) 
   		and.b d7,(a5)
   		move.b (a2)+,d2
   		or.b d2,(a5)
   		move.b (a5),2(a4)
   		move.l a2,8(a0)  
	 	rts
get_new_note: 	move.l 4(a0),a1
   		move.w 46(a0),44(a0)
CONTROL_RET:
   		clr.l d3
   		move.b (a1)+,d3 
   		cmpi.b #m,d3  
   		beq control_char 
   		cmpi.b #253,d3
   		beq do_rest
legal_note:
    		tst.b 78(a0)
     		bne noretrigg
    		move.l 20(a0),8(a0) 
noretrigg
   		jsr send_env
   		move.b d1,(a4) 
  		 move.b d3,2(a4) 
   		move.b d3,28(a0) 
   		move.b d0,(a4)
   		move.b (a1),29(a0) 
   		move.b (a1)+,2(a4)
   		move.w (a1)+,2(a0) 
   		subq #1,2(a0) 
   		move.l a1,4(a0) 
  	 	rts
do_rest:
 		move.b d2,(a4)
  		clr.b 2(a4) 
  		move.l #restenv,8(a0)  
  		addq #1,a1
   		move.w (a1)+,2(a0)
   		subq #1,2(a0)
in_line_ret
   		move.l a1,4(a0)
   		rts
drum_chan:
   		move.l 20(a0),8(a0) 
   		jsr send_env
   		move.b #6,(a4)
   		move.b (a1)+,2(a4) 
   		move.w (a1)+,2(a0) 
   		subq #1,2(a0) 
   		move.l a1,4(a0) 
   		rts
restenv:  	dc.b 0,0,255
   even
control_char:
   		move.b (a1),d3 
  		move.l #jumptable,a2
  		MOVE.L (A2,D3),A3
  		jmp (a3)
jumptable:
   		dc.l get_new_patt
   		dc.l get_env
   		dc.l do_sound
   		dc.l check_pbend
   		dc.l modulation
   		dc.l set_octaves
   		dc.l do_modoff
   		dc.l do_bend_off
   		dc.l do_inline
   		dc.l do_end_fx
   		dc.l hold_val
   		dc.l do_hold_off


get_env:  	addq #1,a1
		move.b (a1),78(a0)
		addq #2,a1
   		move.l (a1),20(a0) 
   		addq #4,a1  
   		bra control_ret
do_sound:
   		nop 	
   		nop 
check_pbend:
  		addq #1,a1
  		MOVE.W (A1)+,26(A0) 
  		move.w (a1)+,42(a0) 
  		move.w (a1)+,48(a0) 
  		bra control_ret
modulation:
  		addq #1,a1
  		MOVE.W (A1)+,(A0)
  		move.l (a1)+,34(a0) 
  		MOVE.W (A1),44(A0) 
  		move.w (a1)+,46(a0) 
  		move.b #2,38(a0) 
  		bra control_ret
set_octaves:
  		addq #1,a1
  		move.b #9,38(a0) 
  		bra control_ret
do_modoff:  	clr.b 38(a0)
  		addq #1,a1
  		bra control_ret
do_bend_off: 	addq #1,a1
 	 	clr.b 26(a0)
  		bra control_ret
do_inline:
	 	addq.l  #1,a1

in_loop
 		cmpi.b #255,(a1)
 		beq fin_in
 		cmpi.b #254,(a1)
 		beq fin_in1
		move.b (a1)+,(a4)
		move.b (a1)+,2(a4)
		bra in_loop 
fin_in
		addq  #2,a1
		bra control_ret
	
fin_in1
		addq  #2,a1
		bra in_line_ret


hold_val:
		addq #1,a1
		move.w (a1)+,hold_val_p
		bra control_ret
do_hold_off:
		move.w #0,hold_val_p
		addq #1,a1
		bra control_ret
do_end_fx:

		move.b d2,(a4)
 		move.b #0,2(a4) 

		cmpi.w #1,curr_chann	
		bne efx2
		bclr.b #0,fx_flag+1
clear_fx_1	move.l #20,d0
clear_loop1:	move.l #0,(a0)+	
		dbra d0,clear_loop1
		rts 
efx2:		cmpi.w #2,curr_chann	
		bne efx3
		bclr.b #1,fx_flag+1
		move.l #20,d0
clear_loop2:	move.l #0,(a0)+	
		dbra d0,clear_loop2
		rts
efx3:		bclr.b #2,fx_flag+1
		move.l #20,d0
clear_loop3:	move.l #0,(a0)+	
		dbra d0,clear_loop3
		rts
   		even
vars1:
   		dc.w 0  
intc1:  	dc.w 0
pattr1:  	dc.l 0
   		dc.l 0
songr1:  	dc.l 0
wsong1:  	dc.l 0
   		dc.l 0
   		dc.b 0,0
   		dc.b 0,0
   		dc.w 0
   		dc.l 0
   		dc.l 0
   		dc.b 0,0
   		dc.w 0
   		dc.w 0
   		dc.w 0
   		dc.w 0
   		dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
vars2:
   		dc.w 0
intc2:  	dc.w 0
pattr2:  	dc.l 0
   		dc.l 0
songr2:  	dc.l 0
wsong2:  	dc.l 0
   		dc.l 0
   		dc.b 0,0
   		dc.b 0,0
   		dc.w 0
   		dc.l 0
   		dc.l 0
   		dc.b 0,0
   		dc.w 0
   		dc.w 0
   		dc.w 0
   		dc.w 0
   		dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
vars3:
   		dc.w 0
intc3:   	dc.w 0
pattr3:  	dc.l 0
   		dc.l 0
songr3:  	dc.l 0
wsong3:  	dc.l 0
   		dc.l 0
   		dc.b 0,0
   		dc.b 0,0
   		dc.w 0
   		dc.l 0
   		dc.l 0
   		dc.b 0,0
   		dc.w 0
   		dc.w 0
   		dc.w 0
   		dc.w 0
   		dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
fxvars1:
   		dc.w 0  
fxintc1:  	dc.w 0
fxpattr1:  	dc.l 0
   		dc.l 0
fxsongr1:  	dc.l 0
fxwsong1:  	dc.l 0
   		dc.l 0
   		dc.b 0,0
   		dc.b 0,0
   		dc.w 0
   		dc.l 0
   		dc.l 0
  	 	dc.b 0,0
   		dc.w 0
   		dc.w 0
   		dc.w 0
   		dc.w 0
   		dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
fxvars2:
   		dc.w 0
fxintc2:  	dc.w 0
fxpattr2:  	dc.l 0
   		dc.l 0
fxsongr2:  	dc.l 0
fxwsong2:  	dc.l 0
   		dc.l 0
   		dc.b 0,0
   		dc.b 0,0
   		dc.w 0
   		dc.l 0
   		dc.l 0
   		dc.b 0,0
   		dc.w 0
   		dc.w 0
   		dc.w 0
   		dc.w 0
   		dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
fxvars3:
   		dc.w 0
fxintc3:   	dc.w 0
fxpattr3:  	dc.l 0
   		dc.l 0
fxsongr3:  	dc.l 0
fxwsong3:  	dc.l 0
   		dc.l 0
   		dc.b 0,0
   		dc.b 0,0
   		dc.w 0
   		dc.l 0
   		dc.l 0
   		dc.b 0,0
   		dc.w 0
   		dc.w 0
   		dc.w 0
   		dc.w 0
   		dc.w 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


HERExx
song_table:
	dc.l song1,song2,song3
	dc.l song4,song5,song6
	dc.l song13,song14,song15
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


	EVEN
chfx_table:

	dc.l key_click
	dc.l exp1	
	dc.l exp1a	
	dc.l exp1b	
	dc.l exp2
	dc.l exp3
	dc.l gun_shot
	dc.l gun_shota
	dc.l grenade_launch


curr_fx			equ 1
max_chfx		dc.l 10



;**********************************************
	even
key_click:
                       	dc.b  	m,new_env,trigg,0
                       	dc.l  	fx5_env
			dc.w	A05,2
			DC.B	M,inline,6,200,255,0
                       	dc.B    m,endfx_patt

fx5_env:	dc.b 15,t1,9,t1,255,0
;***********************************************

	even
exp1:
                       	dc.b  	m,new_env,trigg,0
                       	dc.l  	exp1_env
			dc.b	M,inline,6,31,254,0
			dc.w	50000,40
			dc.b	m,endfx_patt

exp1a:
                       	dc.b  	m,new_env,trigg,0
                       	dc.l  	exp1_env
			dc.b	M,inline,6,20,254,0
			dc.w	50000,40
			dc.b	m,endfx_patt

exp1b:
                       	dc.b  	m,new_env,trigg,0
                       	dc.l  	exp1_env
			dc.b	M,inline,6,4,254,0
			dc.w	50000,40
			dc.b	m,endfx_patt



exp2:
                       	dc.b  	m,new_env,trigg,0
                       	dc.l  	exp2_env
			dc.b	M,inline,6,31,255,0
			dc.w	0,1
			dc.b    m,inline,6,30,254,0
			DC.B	M,inline,6,30,254,0
			dc.b    m,inline,6,23,254,0
			dc.b    m,inline,6,22,254,0
			DC.w	60000,2
                       	dc.b  	m,new_env,trigg,0
                       	dc.l  	exp2_env
			DC.w	60000,27
			dc.b    m,inline,6,200,254,0
			dc.b	m,endfx_patt



	even
exp3:
                       	dc.b  	m,new_env,trigg,0
                       	dc.l  	exp1_env
			dc.b	M,inline,6,31,254,0
			dc.w	0,4
			dc.b    m,inline,6,30,254,0
			DC.B	M,inline,6,30,254,0
			dc.b    m,inline,6,29,254,0
			dc.b    m,inline,6,28,254,0
			dc.b    m,inline,6,27,254,0
			dc.b    m,inline,6,26,254,0
			dc.b    m,inline,6,25,254,0
			dc.b    m,inline,6,24,254,0
			dc.b    m,inline,6,23,254,0
			dc.b    m,inline,6,22,254,0
			DC.w	60000,2
                       	dc.b  	m,new_env,trigg,0
                       	dc.l  	exp1_env
			DC.w	20,50
			dc.b    m,inline,6,200,254,0
			dc.b	m,endfx_patt










	even
exp1_env:	dc.b 15,n1,15,n1,15,t1,15,n1,15,n1,15,n1,15,n1
		dc.b 15,n1,15,n1,15,b1,15,n1,15,n1,15,n1,15,n1,15,N1,15,N1
		dc.b 14,n1,14,n1,14,n1,14,n1,14,n1,14,n1,14,n1,14,n1,14,n1,14,n1
		dc.b 12,n1,12,n1,12,n1,12,n1,12,n1,12,n1,12,n1,12,n1,12,n1,12,n1
		dc.b 10,n1,10,n1,10,n1,10,n1,10,n1,10,n1,10,n1,10,n1,10,n1,10,n1
		dc.b 8,n1,8,n1,8,n1,8,n1,8,n1,8,n1,8,n1,8,n1,8,n1,8,n1
		dc.b 6,n1,6,n1,6,n1,6,n1,6,n1,6,n1,6,n1,6,n1,6,n1,6,n1
		dc.b 4,n1,4,n1,4,n1,4,n1,4,n1,4,n1,4,n1,4,n1,4,n1,4,n1
		dc.b 2,n1,2,n1,2,n1,2,n1,2,n1,2,n1,2,n1,2,n1,2,n1,2,n1
		DC.B 0,N1,255

exp2_env:	dc.b 15,n1,14,n1,13,b1,12,n1,11,n1,10,n1,7,n1
		dc.b 6,n1,6,n1,6,n1,6,n1,6,n1,6,n1,6,n1,6,n1,6,n1,6,n1
		dc.b 4,n1,4,n1,4,n1,4,n1,4,n1,4,n1,4,n1,4,n1,4,n1,4,n1
		dc.b 2,n1,2,n1,2,n1,2,n1,2,n1,2,n1,2,n1,2,n1,2,n1,2,n1
		DC.B 0,N1,255


gun_shot:
                       	dc.b  	m,new_env,trigg,0
                       	dc.l  	gun_env
			dc.b	M,inline,6,15,255,0
			dc.w	0,1
			dc.b    m,inline,6,18,254,0
			DC.B	M,inline,6,30,254,0
			dc.b    m,inline,6,23,254,0
			dc.b    m,inline,6,12,254,0
			DC.w	0,2
                       	dc.b  	m,new_env,trigg,0
                       	dc.l  	gun_env
			DC.w	0,9
			dc.b    m,inline,6,200,254,0
			dc.b	m,endfx_patt


gun_shota:
                       	dc.b  	m,new_env,trigg,0
                       	dc.l  	gun_env
			dc.b	M,inline,6,15,255,0
			dc.b    m,inline,6,12,254,0
			DC.w	0,9
			dc.b    m,inline,6,200,254,0
			dc.b	m,endfx_patt


gun_env:	dc.b 15,n1,14,n1,13,b1,12,n1,11,n1,10,n1,7,n1
		dc.b 6,n1,6,n1,6,n1,6,n1,6,n1,6,n1,6,n1,6,n1,6,n1,6,n1
		DC.B 0,N1,255

;******************************************
	even
grenade_launch	
                       	dc.b  	m,new_env,trigg,0
                       	dc.l  	grenadel_env
			dc.b	M,inline,6,10,254,0
	  		dc.b 	m,pbend,up,10
  			dc.w 	c04,0
			dc.w	c03,40
			dc.b	m,endfx_patt

	even

fx7_env:	dc.b 15,b1,15,b1,15,b1,15,b1,15,b1,15,b1,15,b1
		dc.b 15,b1,15,b1,15,b1,15,b1,15,b1,15,b1,15,b1,15,b1,15,b1
		dc.b 14,b1,14,b1,14,b1,14,b1,14,b1,14,b1,14,b1,14,b1,14,b1,14,b1
		dc.b 12,b1,12,b1,12,b1,12,b1,12,b1,12,b1,12,b1,12,b1,12,b1,12,b1
		dc.b 10,b1,10,b1,10,b1,10,b1,10,b1,10,b1,10,b1,10,b1,10,b1,10,b1
		dc.b 8,b1,8,b1,8,b1,8,b1,8,b1,8,b1,8,b1,8,b1,8,b1,8,b1
		dc.b 6,b1,6,b1,6,b1,6,b1,6,b1,6,b1,6,b1,6,b1,6,b1,6,b1
		dc.b 4,b1,4,b1,4,b1,4,b1,4,b1,4,b1,4,b1,4,b1,4,b1,4,b1
		dc.b 2,b1,2,b1,2,b1,2,b1,2,b1,2,b1,2,b1,2,b1,2,b1,2,b1
		DC.B 0,b1,255

grenadel_env
		dc.b 7,B1,7,B1,7,B1
		dc.b 7,B1,7,B1,7,B1
		dc.b 9,B1,9,B1,9,B1
		dc.b 9,B1,9,B1,9,B1
		dc.b 10,B1,10,B1
		dc.b 10,B1,10,B1
		dc.b 10,B1,10,B1
		dc.b 10,B1,10,B1
		dc.b 11,B1,11,B1
		dc.b 11,B1,11,B1
		dc.b 12,B1,12,B1
		dc.b 12,B1,12,B1
		dc.b 13,B1,13,B1
		dc.b 14,B1,14,B1
		dc.b 13,B1,13,B1
		dc.b 14,B1,14,B1
		dc.b 15,B1,15,B1,15,B1,15,B1,15,n1,15,N1
		DC.B 255,0




	EVEN
;**************************************************




	even
;;;;;;;;;;;;;;;;;;;;;    JAGGED  Music Data ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



  ;   dave

song1:	
	
	dc.l    p3,p41,p41c,p1,p1,p2
	dc.l	p1,p1
	dc.l	end_song
song2:

	dc.l    p3a,p41a,p41d,p10,p10l,p11,p11
	dc.l	p10,p10l
	dc.l    end_song
;song3:

;	dc.l    pr,pr,pr,pr,p41b,p41e,p20,p20,p12
;	dc.l	p20,p20
;	dc.l   	end_song
song3:
	
        ;dc.l prf

	dc.l	pr,pr,pr,pr
	dc.l	pr,pr,p40,p40,p42
	dc.l	p40,p40
	dc.l   	end_song

pr: 
  	dc.w rest,cr*4
  	dc.b m,end_patt

pr1: 
  	dc.w rest,cr*1
  	dc.b m,end_patt

pr2: 
  	dc.w rest,cr*2
  	dc.b m,end_patt

prf: 
  	;dc.w rest,cr*100
  	dc.b m,end_patt


p1: 			

        dc.b  m,new_env,trigg,0
        dc.l  mono_env1

        dc.w 	a04,cr*3,c05,cr,c05,cr,d05,cr*3,e05,cr*2
	dc.w	b05,cr*3,a05,q,g05,q,a05,cr*4
	dc.w	g05,cr*3,e05,cr,e05,cr*2,d05,cr*3,c05,cr
	dc.w	b04,cr,c05,cr,a04,cr*2
	dc.b 	m,end_patt


p2: 			
        dc.b  m,new_env,trigg,0
        dc.l  mono_env1
        dc.w 	c05,cr*2,a04,cr*2,g04,q,a04,q,g04,cr,e04,cr*2
	dc.w	d04,q,e04,q,d04,cr,b04,cr
	dc.w	a04,q,g04,q,a04,cr*4

        dc.w 	c05,cr*2,a05,cr*2,g05,q,a05,q,g05,cr,e05,cr*2
	dc.w	d05,q,e05,q,d05,q,c05,q,b04,q
	dc.w	a04,q,g04,cr,a04,cr*2-sq

	dc.w	d05,sq,e05,sq,g05,sq,rest,cr+q


	dc.b m,end_patt


p3: 			

        dc.b  m,new_env,trigg,0
        dc.l  mono_env1
        dc.w 	e05,cr,a05,cr,e05,cr,d05,q,c05,q,b04,q,a04,q,g04,cr,a04,cr*2
        dc.w 	c05,q,d05,q,e05,q,f05,q,e05,q,d05,q,c05,cr,a04,cr,g04,cr,a04,cr*2


	dc.b m,end_patt


p3a: 			
        dc.b  m,new_env,trigg,0
        dc.l  mono_env2
        dc.w 	e02,cr,a02,cr,e02,cr,d02,q,c02,q,b01,q,a01,q,g01,cr,a01,cr*2
        dc.w 	c02,q,d02,q,e02,q,f02,q,e02,q,d02,q,c02,cr,a01,cr,g01,cr,a01,cr*2


	dc.b m,end_patt



p10: 			
        dc.b  m,new_env,trigg,0
        dc.l  mono_env2
        dc.w 	a03,q,a04,q,a03,q,a04,q,a03,q,a04,q,a03,q,a04,q
        dc.w 	a03,q,a04,q,a03,q,a04,q,a03,q,a04,q,a03,q,a04,q
        dc.w 	a03,q,a04,q,a03,q,a04,q,a03,q,a04,q,a03,q,a04,q
        dc.w 	a03,q,a04,q,a03,q,a04,q,a03,q,a04,q,a03,q,a04,q
        dc.w 	a03,q,a04,q,a03,q,a04,q,a03,q,a04,q,a03,q,a04,q
        dc.w 	a03,q,a04,q,a03,q,a04,q,a03,q,a04,q,a03,q,a04,q
        dc.w 	a03,q,a04,q,a03,q,a04,q,a03,q,a04,q,a03,q,a04,q
        dc.w 	a03,q,a04,q,a03,q,a04,q,a03,q,a04,q,a03,q,a04,q



  	dc.b m,end_patt


p10l: 			
        dc.b  m,new_env,trigg,0
        dc.l  mono_env2 
       dc.w 	e04,q,a03,q,e04,q,a03,q,e04,q,a03,q,e04,q,a03,q
       dc.w 	e04,q,a03,q,e04,q,a03,q,e04,q,a03,q,e04,q,a03,q
       dc.w 	e04,q,a03,q,e04,q,a03,q,e04,q,a03,q,e04,q,a03,q
       dc.w 	e04,q,a03,q,e04,q,a03,q,e04,q,a03,q,e04,q,a03,q
       dc.w 	e04,q,a03,q,e04,q,a03,q,e04,q,a03,q,e04,q,a03,q
       dc.w 	e04,q,a03,q,e04,q,a03,q,e04,q,a03,q,e04,q,a03,q
       dc.w 	e04,q,a03,q,e04,q,a03,q,e04,q,a03,q,e04,q,a03,q
       dc.w 	e04,q,a03,q,e04,q,a03,q,e04,q,a03,q,e04,q,a03,q



  	dc.b m,end_patt


p11: 			
        dc.b  m,new_env,trigg,0
        dc.l  mono_env2
	dc.w rest,cr*16

	dc.b m,end_patt


p12: 			
        dc.b  m,new_env,trigg,0
        dc.l  mono_env3
        dc.w 	f02,cr*2,c03,cr*2,a02,cr*2,c03,cr*2
        dc.w 	g02,cr*2,b02,cr*2,a02,cr*2,c03,cr*2


        dc.w 	f02,cr*2,c03,cr*2,a02,cr*2,c03,cr*2
        dc.w 	g02,cr*2,b02,cr*2,a02,cr*2,c03,cr*2


	dc.b m,end_patt







p20: 			
        dc.b  m,new_env,trigg,0
        dc.l  mono_env3
        dc.w 	a01,cr*2,e01,cr*2,a01,cr,e01,cr,a01,cr*2
        dc.w 	a01,cr*2,e01,cr*2,a01,cr,e01,cr,a01,cr*2
        dc.w 	a01,cr*2,e01,cr*2,a01,cr,e01,cr,a01,cr*2
        dc.w 	a01,cr*2,e01,cr*2,a01,q,a01,q,e01,q,e01,q
	dc.w	a01,cr*2

  	dc.b m,end_patt


p40: 			
        dc.b  m,new_env,trigg,0
        dc.l  mono_env3
        dc.w 	a02,sq,a02,sq,b02,sq,b02,sq,c04,q,d04,q,e04,cr,a04,cr
	dc.w	a04,cr,g04,cr,e04,cr*2
	dc.w	a03,sq,a03,sq,b03,sq,b03,sq,c04,q,d04,q,e04,cr,a04,cr,c04,cr
	dc.w	b03,q,g04,q,a04,cr*2
	dc.w	a03,sq,a03,sq,b03,sq,b03,sq,c04,q,d04,q,e04,cr,a04,cr,a04,cr
	dc.w	g04,cr,e04,cr*2,d04,q,e04,q,d04,q,c04,q,b04,cr,a03,q,g03,q
	dc.w	a03,cr,g03,cr,a03,cr*2
	dc.b 	m,end_patt


p41

        dc.b  m,new_env,trigg,0
        dc.l  mono_env1
        dc.w 	a03,q,b03,q,c04,q,d04,q,e04,cr,a04,cr
	dc.w	e04,cr,a04,cr

	dc.b	m,end_patt


p41a
        dc.b  m,new_env,trigg,0
        dc.l  mono_env2
        dc.w 	rest,cr,a02,q,b02,q,c03,q,d03,q,e03,cr,a03,cr
	dc.w	c03,cr
	dc.b	m,end_patt


p41b
        dc.b  m,new_env,trigg,0
        dc.l	mono_env3
        dc.w 	rest,cr*2,a03,q,b03,q,c04,q,d04,q,e04,cr,a04,cr
	dc.b	m,end_patt


p41c
        dc.b  m,new_env,trigg,0
        dc.l  mono_env1
        dc.w 	c04,sq,b04,sq,c05,sq,b04,sq,c05,cr
	dc.b	m,end_patt


p41d
        dc.b  m,new_env,trigg,0
        dc.l  mono_env2
        dc.w 	a05,sq,g05,sq,a05,sq,g05,sq,a05,cr
	dc.b	m,end_patt


p41e
        dc.b  m,new_env,trigg,0
        dc.l  mono_env3
        dc.w 	e05,sq,d05,sq,e05,sq,d05,sq,e05,cr
	dc.b	m,end_patt



p42: 			
        dc.b  m,new_env,trigg,0
        dc.l  mono_env3
        dc.w 	f04,q,g04,q,a04,q,b04,q,c05,cr,a05,cr,a05,cr,g05,cr,a05,cr*2
        dc.w 	g04,q,a04,q,b04,q,d05,q,g05,cr,a05,cr,a05,cr,g05,cr,a05,cr*2
        dc.w 	f04,q,g04,q,a04,q,b04,q,c05,cr,a05,cr,a05,cr,g05,cr,a05,cr*2
        dc.w 	g04,q,a04,q,b04,q,d05,q,g05,cr,a05,cr,a05,cr,g05,cr,a05,cr*2

  	dc.b m,end_patt


	even

;***************************************

;line of fire tune2

song4:
  dc.l p10b,p10b,p10b,p10b,p10b,p10b,p10b,p10bx
  dc.l end_song


song5:
  dc.l p1b,p1b,p2b,p1b,p3b,p1b
  dc.l end_song

song6:
  dc.l p1b3,p1b3,p2b3,p1b3,p3b3,p1b3
  dc.l p1b3x,p1b3x,p2b3x,p1b3x,p3b3,p1b3x


  dc.l end_song


	

;*************************************************

p1b:
  dc.b m,new_env,trigg,0
  dc.l bass_env
  dc.w c02,sq,c02,sq,c03,q,bb02,q,a02,q,g02,q,a02,sq
  dc.w bb02,q+sq,g02,sq,g02,sq
  dc.w c02,sq,c02,sq,c03,q,bb02,q,a02,sq,g02,sq,rest,cr*2
  dc.b m,end_patt


p2b: 			
  dc.b m,new_env,trigg,0
  dc.l bass_env
  dc.w f02,sq,f02,sq,f03,q,eb03,q,d03,q,c03,q,d03,sq
  dc.w eb03,q+sq,c03,sq,c03,sq
  dc.w f02,sq,f02,sq,f03,q,eb03,q,d03,sq,c03,sq,rest,cr*2
  dc.b m,end_patt





p3b:

  dc.b m,new_env,trigg,0
  dc.l bass_env
  dc.w g02,sq,g02,sq,d03,q,g02,q,b02,sq,b02,sq
  dc.w g02,sq,g02,sq,d03,sq,d03,sq,g02,sq,g02,sq
  dc.w b02,sq,b02,sq,f02,sq,f02,sq,c03,q,f02,q,a02,sq,a02,sq
  dc.w f02,sq,f02,sq,c03,sq,c03,sq,f02,sq,f02,sq,a02,sq,a02,sq
  dc.b m,end_patt


p1b3:
  dc.b m,new_env,trigg,0
  dc.l bass_env3
  dc.w c03,sq,c03,sq,c04,q,bb03,q,a03,q,g03,q,a03,sq
  dc.w bb03,q+sq,g03,sq,g03,sq
  dc.w c03,sq,c03,sq,c04,q,bb03,q,a03,sq,g03,sq,rest,cr*2
  dc.b m,end_patt


p1b3x:
  dc.b m,new_env,trigg,0
  dc.l bass_env3
  dc.w c03,sq,c03,sq,c04,q,bb03,q,a03,q
  dc.b m,new_env,trigg,0
  dc.l blip_env

  dc.w c06,sq,c05,sq,g05,sq,g05,sq
  dc.w c06,sq,c05,sq,g05,sq,g05,sq
  dc.b m,new_env,trigg,0
  dc.l bass_env3

  dc.w c03,sq,c03,sq,c04,q,bb03,q,a03,sq,g03,sq,rest,cr*2
  dc.b m,end_patt



p2b3x: 			
  dc.b m,new_env,trigg,0
  dc.l bass_env3
  dc.w f03,sq,f03,sq,f04,q,eb04,q,d04,q
  dc.b m,new_env,trigg,0
  dc.l blip_env

  dc.w c06,sq,c05,sq,f05,sq,g05,sq
  dc.w c06,sq,c05,sq,f05,sq,g05,sq

  dc.b m,new_env,trigg,0
  dc.l bass_env3

  dc.w f03,sq,f03,sq,f04,q,eb04,q,d04,sq,c04,sq,rest,cr*2
  dc.b m,end_patt


p2b3: 			
  dc.b m,new_env,trigg,0
  dc.l bass_env3
  dc.w f03,sq,f03,sq,f04,q,eb04,q,d04,q,c04,q,d04,sq
  dc.w eb04,q+sq,c04,sq,c04,sq
  dc.w f03,sq,f03,sq,f04,q,eb04,q,d04,sq,c04,sq,rest,cr*2
  dc.b m,end_patt





p3b3:

  dc.b m,new_env,trigg,0
  dc.l bass_env3
  dc.w g03,sq,g03,sq,d04,q,g03,q,b03,sq,b03,sq
  dc.w g03,sq,g03,sq,d04,sq,d04,sq,g03,sq,g03,sq
  dc.w b03,sq,b03,sq,f03,sq,f03,sq,c04,q,f03,q,a03,sq,a03,sq
  dc.w f03,sq,f03,sq,c04,sq,c04,sq,f03,sq,f03,sq,a03,sq,a03,sq
  dc.b m,end_patt






p10b:     
  	dc.b m,inline,6,200,255,0
  	dc.b m,new_env,trigg,0
  	dc.l bassde
  	dc.b m,pbend,down,200
  	dc.w c01,0
  	dc.w e04,sq,e04,sq,e04,sq

  	dc.b m,new_env,trigg,0
  	dc.l hate
  	dc.w g06,sQ

  	dc.b m,new_env,trigg,0
  	dc.l qclape
  	dc.b m,pbend,down,69
  	dc.w c01,0
  	dc.w c04,sq

  	dc.b m,new_env,trigg,0
  	dc.l hate
  	dc.w g06,sQ

  	dc.b m,new_env,trigg,0
  	dc.l bassde
  	dc.b m,pbend,down,200
  	dc.w c01,0
  	dc.w e04,sq

  	dc.b m,new_env,trigg,0
  	dc.l hate
  	dc.w g06,sQ,g06,sQ,g06,sQ

  	dc.b m,new_env,trigg,0
  	dc.l bassde
  	dc.b m,pbend,down,200
  	dc.w c01,0
  	dc.w e04,sq,e04,sq
  	dc.b m,new_env,trigg,0
  	dc.l snaree
  	dc.b m,pbend,down,69
  	dc.w c01,0
  	dc.w c05,sq

  	dc.b m,new_env,trigg,0
  	dc.l hate
  	dc.w g06,sQ,g06,sQ,g06,sQ

  	dc.b m,end_patt


p10bx:     
  	dc.b m,inline,6,200,255,0
  	dc.b m,new_env,trigg,0
  	dc.l bassde
  	dc.b m,pbend,down,200
  	dc.w c01,0
  	dc.w e04,sq,e04,sq,e04,sq

  	dc.b m,new_env,trigg,0
  	dc.l hate
  	dc.w g06,sQ

  	dc.b m,new_env,trigg,0
  	dc.l qclape
  	dc.b m,pbend,down,69
  	dc.w c01,0
  	dc.w c04,sq

  	dc.b m,new_env,trigg,0
  	dc.l hate
  	dc.w g06,sQ

  	dc.b m,new_env,trigg,0
  	dc.l bassde
  	dc.b m,pbend,down,200
  	dc.w c01,0
  	dc.w e04,sq

  	dc.b m,new_env,trigg,0
  	dc.l hate
  	dc.w g06,sQ,g06,sQ,g06,sQ

  	dc.b m,new_env,trigg,0
  	dc.l bassde
  	dc.b m,pbend,down,200
  	dc.w c01,0
  	dc.w e04,sq,e04,sq
  	dc.b m,new_env,trigg,0
  	dc.l snaree
  	dc.b m,pbend,down,69
  	dc.w c01,0
  	dc.w c05,sq

  	dc.b m,new_env,trigg,0
  	dc.l rota1
  	dc.b m,pbend,down,20
  	dc.w c01,0

  	dc.w g04,sQ,g04,sQ,g03,sQ

  	dc.b m,end_patt




 even

**************************************************************

	;;; WIN JINGLE

song13:		;drums
	dc.l    p22f,prj

  	dc.l 	end_song

song14:		;bass
	dc.l	p21f,prj
        DC.L     end_song

song15:		;tune
		
	dc.l   p20f,prj
	dc.l 	end_song


prj:
  	dc.w rest,cr*1000
  	dc.b m,end_patt


p20f:
  	dc.b m,new_env,trigg,0
  	dc.l marx_env
  	dc.b m,modon,1,1
  	dc.w 3,3,8
  	dc.w bb04,q,c05,q,db05,q,d05,q,eb05,q,e05,q
	dc.w f05,q,gb05,q
  	dc.b m,new_env,trigg,0
  	dc.l bass_env3
	dc.w d03,q+sq,d04,q+sq,D03,cr,D03,sq,d03,sq
	dc.w f03,sq,d03,sq,f03,sq,a03,sq
           dc.w d03,q+sq,d04,q+sq,D03,cr
  	dc.b m,end_patt





  	dc.b m,end_patt


p21f:
  	dc.b m,new_env,trigg,0
  	dc.l bass_env
  	dc.b m,modon,1,1
  	dc.w 3,3,8
  	dc.w bb02,q,c03,q,db03,q,d03,q,eb03,q,e03,q
	dc.w f03,q,gb03,q
  	dc.b m,new_env,trigg,0
  	dc.l bass_env
	dc.w d02,q+sq,d03,q+sq,D02,cr,D02,sq,d02,sq
	dc.w f02,sq,d02,sq,f02,sq,a02,sq
           dc.w d02,q+sq,d03,q+sq,D02,cr
  	dc.b m,end_patt


p22f:
  	dc.b m,new_env,trigg,0
  	dc.l rota1
  	dc.w c02,q,c02,q,c02,q,c02,q,c02,q,c02,q,c02,q,c02,q
	
	dc.w d02,q+sq,d03,q+sq,D02,cr,D02,sq,d02,sq
	dc.w f02,sq,d02,sq,f02,sq,a02,sq
           dc.w d02,q+sq,d03,q+sq,D02,cr



  	dc.b m,end_patt


	EVEN
;****************************************************************



bassde: dc.b 15,b1,14,t1,14,t1,13,t1,13,t1,5,t1
  dc.b 2,t1,0,t1,255
	even
bass_env: dc.b 12,n2,15,t2,15,t2,15,t2,14,t2,14,t2
	dc.b 13,t2,11,t2,10,t2,10,t2,9,t2,8,t2,7,t2,6,t2,255
	even
bass_envt1: dc.b 12,n1,15,t1,15,t1,15,t1,14,t1,14,t1
	dc.b 13,t1,11,t1,10,t1,10,t1,9,t1,8,t1,7,t1,6,t1,255
	even
bass_envt3: dc.b 12,n3,15,t3,15,t3,15,t3,14,t3,14,t3
	dc.b 13,t3,11,t3,10,t3,10,t3,9,t3,8,t3,7,t3,6,t3,255
	even
mono: 	dc.b 13,t3,12,t3,255
mono_env3:
	dc.b 14,t3,13,t3,13,t3,13,t3,13,t3
	dc.b 12,t3,12,t3,12,t3,12,t3,12,t3,12,t3,12,t3,12,t3
        dc.b 11,t3,11,t3,11,t3,11,t3,10,t3,10,t3,10,t3,10,t3
        dc.b 9,t3,9,t3,9,t3,9,t3,9,t3,9,t3,9,t3,9,t3,255
	even
mono_env2:
	dc.b 14,t2,13,t2,13,t2,13,t2,13,t2
	dc.b 12,t2,12,t2,12,t2,12,t2,12,t2,12,t2,12,t2,12,t2
        dc.b 11,t2,11,t2,11,t2,11,t2,10,t2,10,t2,10,t2,10,t2
        dc.b 9,t2,9,t2,9,t2,9,t2,9,t2,9,t2,9,t2,9,t2,255
	even

mono_env1:
	dc.b 14,t1,13,t1,13,t1,13,t1,13,t1
	dc.b 12,t1,12,t1,12,t1,12,t1,12,t1,12,t1,12,t1,12,t1
        dc.b 11,t1,11,t1,11,t1,11,t1,10,t1,10,t1,10,t1,10,t1
        dc.b 9,t1,9,t1,9,t1,9,t1,9,t1,9,t1,9,t1,9,t1,255
	even


snaree:     dc.b 15,b1,15,b1,15,b1,15,b1,13,b1,13,b1
  dc.b 11,b1,11,t1,6,b1,5,t1,5,b1,5
  dc.b t1,6,b1,6,t1,6
  dc.b b1,5,t1,255
	even
hate:     dc.b 13,n1,0,n1,255








;bassa_env2:    dc.b 15,t2,15,t2,0,t2,255
;ash1:     dc.b 0,t1,255
;abassde:     dc.b 15,b1,15,t1,15,t1,15,t1,7,t1
      dc.b 3,t1,0,t1,255
;abass_env:    dc.b 15,t2,15,t2,15,t2,15,t2
      dc.b 15,t2,15,t2
      dc.b 0,t2,255
;ablipa_env:    dc.b 15,t3,15,t3,13,t3,11,t3
      dc.b 15,t3,15,t3,13,t3,11,t3,0,t3,255
;blip_env2:    dc.b 15,t2,15,t2,13,t2,11,t2
      dc.b 15,t2,15,t2,13,t2
      dc.b 11,t2,0,t2,255
;piano_env2:    dc.b 15,t3,15,t3,15,t3,14,t3,3,t3,12,t3,11
      dc.b t3,10,t3,15,t3,14,t3,13,t3,12,t3,12,t3,11
      dc.b t3,10,t3,9,t3,8,t3,7,t3,7,t3,6,t3,5,t3,4
      dc.b t3,3,t3,2,t3,1,t3,0,t3,255
;apaiano_env:    dc.b 15,t3,15,t3,15,t3,15,t3,14,t3
      dc.b 13,t3,13,t3,13,t3,13,t3,13,t3
      dc.b 13,t3,12,t3,12,t3,11,t3
      dc.b 11,t3,10,t3,9,t3,8,t3,7,t3,6,t3,255
;apaiano_envt:    dc.b 15,t3,15,t3,14,t3,13,t3,13,t3
      dc.b 12,t3,8,t3,7,t3,6,t3,6,t3
      dc.b 8,t3,255
;apaiano_drum:    dc.b 15,t1,15,t1,15,t1,15,t1,14,t1
      dc.b 13,t1,13,t1,13,t1,13,t1,13,t1
     dc.b 13,t1,12,t1,12,t1,11,t1
      dc.b 11,t1,10,t1,9,t1,8,t1,7,t1,6,t1
      dc.b 5,t1,4,t1,3,t1,2,t1,1,t1,0,t1,255
;apaiano_env3:    dc.b 15,t2,15,t2,15,t2,15,t2,14,t2
     dc.b 13,t2,13,t2,13,t2,13,t2,13,t2
      dc.b 13,t2,12,t2,12,t2,11,t2
      dc.b 11,t2,10,t2,9,t2,8,t2,7,t2,6,t2
      dc.b 5,t2,4,t2,3,t2,2,t2,1,t2,0,t2,255
;amono_enva:    dc.b 14,t3,255
;long_susa:     dc.b 15,t3,14,t3,255
;arotoe:     dc.b 15,t3,15,t3,15,t3,14,t3,13,t3
      dc.b 13,t3,12,t3,12,t3,11,t3,10,t3
      dc.b 8,t3,7,t3,6
      dc.b t3,5,t3,4,t3,3,t3,2,t3,1,t3,0,t3,255
;fast_env:     dc.b 14,t3,1,t3,14,t3,1,t3,14,t3,1,t3
       dc.b 14,t3,0,t3,255
;asharpa_env:    dc.b 15,t3,15,t3,9,t3,15,t3,15,t3,10,t3
      dc.b 8,t3,7,t3,6,t3,5,t3,2,t3,2,t3,0,t3,255
rota3:     dc.b 15,t3,15,t3,15,t3,14,t3,13,t3
      dc.b 13,t3,12,t3,12,t3,11,t3,10,t3
      dc.b 8,t3,7,t3,6,t3,5,t3,4,t3
      dc.b 4,t3,3,t3,2,t3,1,t3,0,t3,255
;rota2:     dc.b 15,t2,15,t2,15,t2,14,t2,13,t2
      dc.b 13,t2,12,t2,12,t2,11,t2,10,t2
      dc.b 8,t2,7,t2,6,t2,5,t2,4,t2
      dc.b 4,t2,3,t2,2,t2,1,t2,0,t2,255
rota1:     dc.b 15,t1,15,t1,15,t1,14,t1,13,t1
      dc.b 13,t1,12,t1,12,t1,11,t1,10,t1
      dc.b 8,t1,7,t1,6,t1,5,t1,4,t1
      dc.b 4,t1,3,t1,2,t1,1,t1,0,t1,255

;snaree:     dc.b 15,b1,15,t1,15,t1,15,b1,15,t1,15,b1
;  dc.b 12,t1,12,b1,9,t1,7,b1,7,t1,7
;  dc.b b1,6,t1,6,b1,6
;  dc.b t1,5,t1,255
;sh1: dc.b 0,t1,255
;bassde: dc.b 15,b1,15,t1,15,t1,15,t1,7,t1
;  dc.b 3,t1,0,t1,255
;bass_env: dc.b 15,t2,15,t2,15,t2,15,t2
;  dc.b 15,t2,14,t2,13,t2,11,t2,9,t2
;  dc.b 7,t2,255
bass_env3: dc.b 15,t3,15,t3,15,t3,15,t3
  dc.b 15,t3,14,t3,13,t3,11,t3,9,t3
  dc.b 7,t3,255

bass_env_short: dc.b 15,t2,15,t2,15,t2,15,t2
  dc.b 14,t2
  dc.b 7,t2,255



;bass_envs: dc.b 15,t2,15,t2,14,t2
  dc.b 4,t2,255

	even
;bass_envj: dc.b 15,t2,15,t2,0,t2,0,t2
  dc.b 15,t2,15,t2
  dc.b 0,t2,255
	even
;bass_env2: dc.b 15,t2,14,b2,15,t2,15,t2
	dc.b 15,t2,15,t2,15,t2,10,b2,15,t2
	dc.b 15,t2,15,t2,15,t2,14,t2,13,t2
	dc.b 0,t2,255
rest_env:	dc.b 0,0,255
	even
blip_env:    dc.b 15,t3,11,t3,3,t3,13,t3
  dc.b 13,t3,3,t3,3,t3
  dc.b 12,t3,10,t3,3,t3,8,t3,7,t3,6,t3,0,t3,255
	even
;xpiano_env2:    dc.b 15,t3,15,t3,15,t3,14,t3,13,t3,12,t3,11
  dc.b t3,10,t3,15,t3,14,t3,13,t3,12,t3,12,t3,11
  dc.b t3,10,t3,9,t3,8,t3,7,t3,7,t3,6,t3,5,t3,4
  dc.b t3,3,t3,2,t3,1,t3,0,t3,255
;piano_env:    dc.b 15,t3,15,t3,15,t3,15,t3,14,t3
  dc.b 13,t3,13,t3,13,t3,13,t3,13,t3
  dc.b 13,t3,12,t3,12,t3,11,t3
  dc.b 11,t3,10,t3,9,t3,8,t3,7,t3,6,t3
  dc.b 5,t3,4,t3,3,t3,2,t3,1,t3,0,t3,255
;piano_drum:    dc.b 15,t1,15,t1,15,t1,15,t1,14,t1
  dc.b 13,t1,13,t1,13,t1,13,t1,13,t1
  dc.b 13,t1,12,t1,12,t1,11,t1
  dc.b 11,t1,10,t1,9,t1,8,t1,7,t1,6,t1
  dc.b 5,t1,4,t1,3,t1,2,t1,1,t1,0,t1,255
;piano_env3:    dc.b 15,t2,15,t2,15,t2,15,t2,14,t2
  dc.b 13,t2,13,t2,13,t2,13,t2,13,t2
  dc.b 13,t2,12,t2,12,t2,11,t2
  dc.b 11,t2,10,t2,9,t2,8,t2,7,t2,6,t2
  dc.b 5,t2,4,t2,3,t2,2,t2,1,t2,0,t2,255
mono_env:    dc.b 12,t3,255
;mono_env3:    dc.b 15,t3,255
;mono_envt1:    dc.b 13,t1,255,0
;mono_envt2:    dc.b 15,t2,255,0
;piano_envs:    dc.b 15,t3,15,t3,0,t3,0,t3,15,t3,0,t3,255
;long_sus:     dc.b 15,t2,13,t2,255
;long_sus4:     dc.b 14,t2,255
qclape:     dc.b 15,n1,14,n1,14,n1,13,n1,13,n1,12,n1
  dc.b 11,n1,11,n1,9,n1,7,n1,7,n1,7
  dc.b n1,6,n1,6,n1,6
  dc.b n1,5,n1,255
;hate:     dc.b 13,n1,0,n1,255
rotoe:     dc.b 15,t1,15,t1,15,t1,15,t1,15,t1,14,t1
  dc.b 13,t1,13,t1,12,t1,11,t1,10,t1,9
  dc.b t1,8,t1,7,t1,6
  dc.b t1,5,t1,4,t1,3,t1,2,t1,0,t1,255
;hot_env:     dc.b 15,t3,14,t3,15,t3,12,t3,15,t3,10,t3
  dc.b 15,t3,12,t3,255
;hot_env2:     dc.b 15,t2,14,t2,15,t2,12,t2,15,t2,10,t2
  dc.b 15,t2,12,t2,255
;revenv:   dc.b 7,t3,9,t3,11,t3,13,t3,15,t3,14,t3
    dc.b 1,t3,15,t3,6,t3,13,t3,10,t3,9,t3,255
;clip_env:    dc.b 15,t3,15,t3,6,t3,6,t3,15,t3
 dc.b 15,t3,15,t3,13,t3
  dc.b 12,t3,11,t3,255
;DIST_ENV:   dc.b 15,t3,15,t3,12,t3,15,t3,3,t3,15,t3
     dc.b 15,t3,3,t3,12,t3,3,t3,10,t3,9,t3
     dc.b 8,t3,7,t3,3,t3,8,t3,9,t3,12,t3,14,t3
     dc.b 15,t3,15,t3,15,t3,15,t3,0,t3,255
;long_sus2:    dc.b 15,t2,14,t2,13,t2,14,t2,15,t2
  dc.b 14,t2,13,t2,14,t2,15,t2,14,t2,13,t2,14,t2
      dc.b 255
;long_sus3:  dc.b 15,t3,14,t3,13,t3,12,t3,12,t3
   dc.b 11,t3,10,t3,9,t3,8,t3
    dc.b 7,t3,8,t3,7,t3,7,t3
    dc.b 6,t3,6,t3,6,t3,6,t3,6,t3,6,t3,6,t3,4,t3
      dc.b 255
;dhot_env:     dc.b 15,t3,14,t3,15,t3,12,t3,15,t3,10,t3
  dc.b 15,t3,12,t3,15,t3,14,t3,15,t3,12,t3
  dc.b 15,t3,10,t3,15,t3,12,t3,255
marx_env:   dc.b 15,t3,8,t3,15,t3,15,t3,12,t3,11,t3,13,t3,11,t3
     dc.b 12,t3,255
;sq_env1:     dc.b 15,t1,15,t1,14,t1,13,t1,0,t1,255
;sq_env2:     dc.b 15,t2,15,t2,14,t2,13,t2,0,t2,255
;sq_env3:     dc.b 15,t3,15,t3,14,t1,13,t2,0,t3,255
;fxbassde:  dc.b 15,b1,13,t1,255
;;;;;;;;;;;;;;;;;;;;;;  MUSIC DATA END ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SPEEDS:
	 DC.W $0607
 	DC.W $CF01
 	DC.W 39681 
 	DC.W 31745 
 	DC.W 26369 
 	DC.W 22529 
 	DC.W 19713 
 	DC.W 17409 
 	DC.W 15873 
 	DC.W 14337 
 	DC.W 13313 
 	DC.W 12289 
 	DC.W 11265 
 	DC.W 10497 
 	DC.W 9985 
 	DC.W 2307 
CHANEL_A: DC.L $00000000,$00020000,$00020001,$00020002
 DC.L $00030002,$00040001,$00040002,$00050002
 DC.L $00060000,$00060002,$00060003,$00060004
 DC.L $00070002,$00070004,$00070005,$00080002
 DC.L $00080003,$00080004,$00080005,$00090002
 DC.L $00090003,$00090004,$00090005,$00090006
 DC.L $00090007,$000A0003,$000A0004,$000A0005
 DC.L $000A0006,$000A0007,$000B0000,$000B0001
 DC.L $000B0002,$000B0004,$000B0005,$000B0006
 DC.L $000B0007,$000B0008,$000B0008,$000B0009
 DC.L $000B0009,$000C0000,$000C0001,$000C0002
 DC.L $000C0003,$000C0004,$000C0005,$000C0006
 DC.L $000C0008,$000C0008,$000C0009,$000C0009
 DC.L $000C0009,$000C000A,$000D0000,$000D0002
 DC.L $000D0003,$000D0004,$000D0005,$000D0006
 DC.L $000D0007,$000D0008,$000D0008,$000D0009 

;***************************************
ssplash8d:	;incbin a:ssplash8.sam
explosi8d:	;incbin a:explosi8.sam

	END

?




;bassde: dc.b 15,b1,14,t1,14,t1,13,t1,13,t1,5,t1
;  dc.b 2,t1,0,t1,255
	even
;bass_env: dc.b 12,n2,15,t2,15,t2,15,t2,14,t2,14,t2
;	dc.b 13,t2,11,t2,10,t2,10,t2,9,t2,8,t2,7,t2,6,t2,255
	even
bass_envt1: dc.b 12,n1,15,t1,15,t1,15,t1,14,t1,14,t1
	dc.b 13,t1,11,t1,10,t1,10,t1,9,t1,8,t1,7,t1,6,t1,255
	even
bass_envt3: dc.b 12,n3,15,t3,15,t3,15,t3,14,t3,14,t3
	dc.b 13,t3,11,t3,10,t3,10,t3,9,t3,8,t3,7,t3,6,t3,255
	even
mono: 	dc.b 13,t3,12,t3,255
mono_env3:
	dc.b 14,t3,13,t3,13,t3,13,t3,13,t3
	dc.b 12,t3,12,t3,12,t3,12,t3,12,t3,12,t3,12,t3,12,t3
        dc.b 11,t3,11,t3,11,t3,11,t3,10,t3,10,t3,10,t3,10,t3
        dc.b 9,t3,9,t3,9,t3,9,t3,9,t3,9,t3,9,t3,9,t3,255
	even
mono_env2:
	dc.b 14,t2,13,t2,13,t2,13,t2,13,t2
	dc.b 12,t2,12,t2,12,t2,12,t2,12,t2,12,t2,12,t2,12,t2
        dc.b 11,t2,11,t2,11,t2,11,t2,10,t2,10,t2,10,t2,10,t2
        dc.b 9,t2,9,t2,9,t2,9,t2,9,t2,9,t2,9,t2,9,t2,255
	even

mono_env1:
	dc.b 14,t1,13,t1,13,t1,13,t1,13,t1
	dc.b 12,t1,12,t1,12,t1,12,t1,12,t1,12,t1,12,t1,12,t1
        dc.b 11,t1,11,t1,11,t1,11,t1,10,t1,10,t1,10,t1,10,t1
        dc.b 9,t1,9,t1,9,t1,9,t1,9,t1,9,t1,9,t1,9,t1,255
	even


;snaree:     dc.b 15,b1,15,b1,15,b1,15,b1,13,b1,13,b1
;  dc.b 11,b1,11,t1,6,b1,5,t1,5,b1,5
;  dc.b t1,6,b1,6,t1,6
;  dc.b b1,5,t1,255
	even
;hate:     dc.b 13,n1,0,n1,255






