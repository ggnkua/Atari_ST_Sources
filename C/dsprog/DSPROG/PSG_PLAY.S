; psg_play.s
; Assembler-Routinen
;

export  start_psg
import  play_ovsm, play_seqs

TIMERA = $134
TA_CNTL = $FFFFFA19
TA_DATA = $FFFFFA1F
VEC_REG = $FFFFFA17
IENAB_A = $FFFFFA07
IENAB_B = $FFFFFA09
IMASK_A	= $FFFFFA13

start_psg:
		move		SR,sr_save
		move		#$2700,SR

		movem.l	D0-A5,-(SP)
		
    movem.l SC_INIT,D0-A5 ; (8 Bit)
    movem.l D0-A5,-$7800    ;   (8 Bit)
		
		movem.l (SP)+,D0-A5

    lea     TIMERA,a0
    move.l  (a0),old_timera
    move.l  (a0),old_timera0
    move.l  (a0),old_timera2
    move.l  #no_timera,(a0)
    
    move.b	TA_DATA,data_save
    move.b	D0,TA_DATA
    
    move.b	TA_CNTL,D0
    move.b  D0,cntl_save
    and.b		#$F0,D0
    or.b		#$1,D0
    move.b	D0,TA_CNTL
    
    move.b	IENAB_A,a_save
    move.b	IENAB_B,b_save
    move.b	#$0,IENAB_B
    move.b	#$20,IENAB_A
;    bclr		#5,IENAB_B						; Timer C aus
;    bset		#5,IENAB_A						; Timer A an
    bset		#5,IMASK_A						;    dto.
    
    move.b	VEC_REG,vec_save
    move.b	#$40,VEC_REG
    
		movem.l D3-D7/A2-A6,-(SP)
    move		#$2500,SR

		bsr.s		play_psg

    move		#$2700,SR

		move.b	vec_save(PC),VEC_REG
		move.b	data_save(PC),TA_DATA
		move.b  cntl_save(PC),TA_CNTL
		move.b  a_save(PC),IENAB_A
		move.b	b_save(PC),IENAB_B
		move.l	old_timera(PC),TIMERA
		
		move		sr_save(PC),SR
		movem.l	(SP)+,D3-D7/A2-A6
		rts

; **********************
; * Make sound for PSG *
; **********************
play_psg:

		cmpi		#1,play_ovsm
		beq.s		ovsm_set
		move.l	#new_timera,scnd_ta
		bra.s		no_ovsm
ovsm_set:
		move.l	#ovsm_timera,scnd_ta
				
no_ovsm:		
		lea			SND_DATA(PC),A3
		move.l	play_seqs,A2
		lea			-$7800,A0
		
psg_loop:		
		move		#$2700,SR
		move.l	(A2)+,A1
		move.l	(A2)+,D1
		tst.l		D1							
		beq.s		end_psgplay					
		move		#$2500,SR						
		move.l	#new_timera,TIMERA
		
no_last:
		btst		#31,D1							
		beq.s		no_last							
		bra.s		psg_loop
		
end_psgplay:
		rts
		
; ******************************************************************
; * This procedure plays sound from a playing buffer, like the dma *
; ******************************************************************

    dc.b    'XBRA'
    dc.b    'SNDT'
old_timera0:
    dc.l    1
no_timera:
		rte
		
    dc.b    'XBRA'
    dc.b    'SNDT'
old_timera:
    dc.l    1

new_timera:
		moveq		#0,D4
		move.b	(A1)+,D4
		move		D4,D5
		lsl.w		#3,D4
		
		move.l	A3,A4
		add.w		D4,A4
		
		move		(A4)+,D4
    movep.w D4,(A0)          ; an'nen Soundchip          (8 Bit)
		move		(A4)+,D4
    movep.w D4,(A0)          ; an'nen Soundchip          (8 Bit)
		move		(A4),D4
    movep.w D4,(A0)          ; an'nen Soundchip          (8 Bit)

		subq.l	#1,D1

		move.l	scnd_ta(PC),TIMERA
		rte

    dc.b    'XBRA'
    dc.b    'SNDT'
old_timera2:
    dc.l    1
ovsm_timera:
		ext.w		d5
		
		move.b	(A1),D4
		ext.w		d4
		add.w		d4,d5
		and		  #$1FE,d5
		lsl.w		#2,D5
		
		move.l	A3,A4
		add.w		D5,A4
		
		move		(A4)+,D5
    movep.w D5,(A0)          ; an'nen Soundchip          (8 Bit)
		move		(A4)+,D5
    movep.w D5,(A0)          ; an'nen Soundchip          (8 Bit)
		move		(A4),D5
    movep.w D5,(A0)          ; an'nen Soundchip          (8 Bit)

		move.l	#new_timera,TIMERA
		rte

scnd_ta:	ds.l	1				
a_save:		ds.b	1
b_save:		ds.b	1
vec_save:	ds.b	1
data_save:ds.b  1
cntl_save:ds.b	1
		even
sr_save: 	ds.w	1

INCLUDE "SND_TAB.S"
