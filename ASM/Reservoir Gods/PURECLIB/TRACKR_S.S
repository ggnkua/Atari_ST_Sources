;	SECTION CSECT

	xdef	rltrk_begin_tracker
	xdef	rltrk_open_module
	xdef	rltrk_set_master_volume
	xdef	rltrk_set_sample_volume
	xdef	rltrk_set_track_ptrs
	xdef	rltrk_start_sample
	xdef	rltrk_end_sample
	xdef	rltrk_read_master_volume
	xdef	rltrk_read_sample_volume
	xdef	rltrk_close_module
	xdef	rltrk_end_tracker
	xdef	rltrk_set_new_pattern
	xdef	rltrk_return_position

;	SECTION TEXT 
	TEXT

rltrk_begin_tracker:
	movem.l	d0-d7/a0-a6,-(a7)
	st.b	rltrk_sound_on
	bsr	TRACK_INIT_SOUND
	movem.l	(a7)+,d0-d7/a0-a6
	rts

rltrk_open_module:
	movem.l	d0-d7/a0-a6,-(a7)
;	move.l	16*4(a7),a0
	bsr	TRACK_INIT_MODUL
	st.b	rltrk_inter_on
	bsr	TRACK_INIT_INTER
	movem.l	(a7)+,d0-d7/a0-a6
	rts

rltrk_set_master_volume:
	move.l	d0,-(a7)
;	move.l	4+4(a7),d0
	move.w	d0,MASTER_VOLUME
	bsr	TRACK_SET_MASTER
	move.l	(a7)+,d0
	rts

rltrk_set_sample_volume:
	move.l	d0,-(a7)
;	move.l	4+4(a7),d0
	move.w	d0,SAMPLE_VOLUME
	bsr	TRACK_SET_SAMPLE
	move.l	(a7)+,d0
	rts

rltrk_set_track_ptrs:
	movem.l	a0/a1,-(a7)
;	lea		4*2+4(a7),a1
;	move.l	(a1)+,a0
;	move.l	(a1)+,a1
	move.l	#DFF0A0,(a0)+
	move.l	#DFF0B0,(a0)+
	move.l	#DFF0C0,(a0)+
	move.l	#DFF0D0,(a0)+
	move.l	#DFF0E0,(a0)+
	move.l	#DFF0F0,(a0)+
	move.l	#TRACK_1_TAT,(a1)+
	move.l	#TRACK_2_TAT,(a1)+
	move.l	#TRACK_3_TAT,(a1)+
	move.l	#TRACK_4_TAT,(a1)+
	move.l	#TRACK_5_TAT,(a1)+
	move.l	#TRACK_6_TAT,(a1)+
	movem.l	(a7)+,a0/a1
	rts

rltrk_start_sample:
	move.l	d1,-(a7)
	move.l	d0,-(a7)
;	move.l	4*2+4(a7),d0
	moveq	#0,d1
	bset	d0,d1
	or.w	d1,DFF096
	move.l	(a7)+,d0
	move.l	(a7)+,d1
	rts

rltrk_end_sample:
	move.l	d1,-(a7)
	move.l	d0,-(a7)
;	move.l	4*2+4(a7),d0
	moveq	#-1,d1
	bclr	d0,d1
	and.w	d1,DFF096
	move.l	(a7)+,d0
	move.l	(a7)+,d1
	rts


rltrk_read_master_volume:
	move.w	MASTER_VOLUME,d0
	rts

rltrk_read_sample_volume:
	move.w	SAMPLE_VOLUME,d0
	rts

rltrk_close_module:
	movem.l	d0-d7/a0-a6,-(a7)
	tst.b	rltrk_inter_on
	beq.s	interoff
	clr.b	rltrk_inter_on
	bsr	TRACK_STOP_INTER
interoff:
	movem.l	(a7)+,d0-d7/a0-a6
	rts
	
rltrk_end_tracker:
	movem.l	d0-d7/a0-a6,-(a7)
	tst.b	rltrk_inter_on
	beq.s	interoff2
	clr.b	rltrk_inter_on
	bsr	TRACK_STOP_INTER
interoff2:
	tst.b	rltrk_sound_on
	beq.s	soundoff
	clr.b	rltrk_inter_on
soundoff:
	bsr	TRACK_STOP_SOUND
	movem.l	(a7)+,d0-d7/a0-a6
	rts
	
rltrk_set_new_pattern:
	move.l	d0,PT_SONGPOSITION
	clr.b	PT_PBREAKPOSITIO
	st.b	PT_POSJUMPASSERT
	rts

rltrk_return_position:
	move.l	PT_SONGPOSITION,d0
	rts

rltrk_inter_on:	dc.w	0
rltrk_sound_on:	dc.w	0


  BRA       TRACK_INIT_SOUND
  BRA       TRACK_INIT_MODUL
  BRA       TRACK_INIT_INTER
  BRA       TRACK_STOP_INTER
  BRA       TRACK_STOP_SOUND
TRACK_INIT_SOUND:
  MOVE.W    #$80,-(A7)
  TRAP      #$E 
  ADDQ.L    #2,A7 
  TST.W     D0
  BMI       TRACK_ERROR 
  MOVE.W    #1,-(A7)
  MOVE.W    #1,-(A7)
  MOVE.W    #0,-(A7)
  MOVE.W    #9,-(A7)
  MOVE.W    #1,-(A7)
  MOVE.W    #$8B,-(A7)
  TRAP      #$E 
  LEA       $C(A7),A7 
  MOVE.W    #1,-(A7)
  MOVE.W    #$84,-(A7)
  TRAP      #$E 
  ADDQ.L    #4,A7 
  MOVE.W    #0,-(A7)
  MOVE.W    #1,-(A7)
  MOVE.W    #$89,-(A7)
  TRAP      #$E 
  ADDQ.L    #6,A7 
  BSR       TRACK_INIT_DSP
TRACK_OK:
  MOVEQ     #0,D0 
TRACK_ERROR:
  RTS 
TRACK_INIT_MODUL:
  PEA       (A0)
  LEA       DFF0A0,A0 
  BSR       CLEAR_TRACKS
  LEA       DFF0B0,A0 
  BSR       CLEAR_TRACKS
  LEA       DFF0C0,A0 
  BSR       CLEAR_TRACKS
  LEA       DFF0D0,A0 
  BSR       CLEAR_TRACKS
  LEA       DFF0E0,A0 
  BSR       CLEAR_TRACKS
  LEA       DFF0F0,A0 
  BSR       CLEAR_TRACKS
  MOVEA.L   (A7)+,A6
  JSR       PT_INITMUSIC
  JSR       PT_PLAYMUSIC
  BSR       TRACK_SET_TEMPO 
  MOVE.W    MASTER_VOLUME,D0
  BSR       TRACK_SET_MASTER
  RTS 
CLEAR_TRACKS:
  CLR.L     (A0)+ 
  CLR.W     (A0)+ 
  CLR.W     (A0)+ 
  CLR.W     (A0)+ 
  CLR.L     (A0)+ 
  CLR.W     (A0)+ 
  RTS 
TRACK_INIT_INTER:
  MOVE      SR,-(A7)
  MOVE      #$2700,SR 
  LEA       TRACK_SAVE_INTER,A0 
  MOVE.L    $134.W,(A0)+
  MOVE.B    $FFFFFA07.W,(A0)+ 
  MOVE.B    $FFFFFA13.W,(A0)+ 
  MOVE.B    $FFFFFA19.W,(A0)+ 
  MOVE.B    $FFFFFA1F.W,(A0)+ 
  BSR       TRACK_SET_TEMPO 
  MOVE.B    #$C,$FFFF8900.W 
  MOVE.B    #-$50,$FFFF8901.W 
  LEA       TRACK_VBL(PC),A0
  MOVE.L    A0,$134.W 
  CLR.B     $FFFFFA19.W 
  MOVE.B    #1,$FFFFFA1F.W
  MOVE.B    #8,$FFFFFA19.W
  BSET      #5,$FFFFFA07.W
  BSET      #5,$FFFFFA13.W
  BCLR      #3,$FFFFFA17.W
  MOVE      (A7)+,SR
  RTS 
TRACK_STOP_INTER:
  MOVE      SR,-(A7)
  MOVE      #$2700,SR 
  LEA       TRACK_SAVE_INTER,A0 
  MOVE.L    (A0)+,$134.W
  MOVE.B    (A0)+,$FFFFFA07.W 
  MOVE.B    (A0)+,$FFFFFA13.W 
  MOVE.B    (A0)+,$FFFFFA19.W 
  MOVE.B    (A0)+,$FFFFFA1F.W 
  CLR.W     $FFFF8900.W 
  MOVE      (A7)+,SR
  RTS 
TRACK_STOP_SOUND:
  MOVE.W    #1,-(A7)
  MOVE.W    #0,-(A7)
  MOVE.W    #0,-(A7)
  MOVE.W    #8,-(A7)
  MOVE.W    #0,-(A7)
  MOVE.W    #$8B,-(A7)
  TRAP      #$E 
  LEA       $C(A7),A7 
  MOVE.W    #0,-(A7)
  MOVE.W    #0,-(A7)
  MOVE.W    #$89,-(A7)
  TRAP      #$E 
  ADDQ.L    #6,A7 
  MOVE.W    #$81,-(A7)
  TRAP      #$E 
  ADDQ.L    #2,A7 
  BRA       TRACK_OK
TRACK_INIT_DSP:
  MOVE.W    #1,-(A7)
  PEA       $1FF.W
  PEA       DSP_ROUTINE 
  MOVE.W    #$6E,-(A7)
  TRAP      #$E 
  LEA       $C(A7),A7 
  BSR       TRACK_WAIT_RECEI
  MOVE.L    $FFFFA204.W,D0
  RTS 
TRACK_SET_TEMPO:
  MOVE.L    #DUMMY_BUFFER,D0
  MOVEQ     #0,D1 
  MOVE.W    REALTEMPO,D1
  LEA       MYCIA_LIST,A0 
  MOVE.W    (A0,D1.W*2),D1
  LSL.L     #2,D1 
  BSET      #7,$FFFF8901.W
  ADD.L     D0,D1 
  MOVE.B    D0,$FFFF8907.W
  LSR.L     #8,D0 
  MOVE.B    D0,$FFFF8905.W
  LSR.L     #8,D0 
  MOVE.B    D0,$FFFF8903.W
  MOVE.B    D1,$FFFF8913.W
  LSR.L     #8,D1 
  MOVE.B    D1,$FFFF8911.W
  LSR.L     #8,D1 
  MOVE.B    D1,$FFFF890F.W
  RTS 
TRACK_SET_MASTER:
  MOVE.L    A0,-(A7)
  LEA       TRACK_1_TAT,A0
  MOVE.W    D0,2(A0)
  LEA       TRACK_2_TAT,A0
  MOVE.W    D0,2(A0)
  LEA       TRACK_3_TAT,A0
  MOVE.W    D0,2(A0)
  LEA       TRACK_4_TAT,A0
  MOVE.W    D0,2(A0)
  MOVEA.L   (A7)+,A0
  RTS 
TRACK_SET_SAMPLE:
  MOVE.L    A0,-(A7)
  LEA       TRACK_5_TAT,A0
  MOVE.W    D0,2(A0)
  LEA       TRACK_6_TAT,A0
  MOVE.W    D0,2(A0)
  MOVEA.L   (A7)+,A0
  RTS 
TRACK_VBL:
  MOVEM.L   A0-A6/D0-D7,-(A7) 
;  MOVE      #$2700,SR 
	move.w	#$2300,sr
  BSR       TRACK_SET_TEMPO 
  BSR       TRACK_WAIT_TRANS
  MOVE.L    #$747261,$FFFFA204.W
  LEA       $FFFFA200.W,A6
  BSR       TRACK_WAIT_RECEI
  MOVE.L    $FFFFA204.W,D0
  MOVE.W    #0,TRACK_BIT_TEST 
  LEA       DFF0A0,A0 
  LEA       TRACK_1_TAT,A1
  MOVEQ     #6,D0 
  MOVE.L    D0,$FFFFA204.W
  SUBQ.W    #1,D0 
L000C:
  MOVEM.L   A0-A1/D0,-(A7)
  MOVE.W    TRACK_BIT_TEST,D0 
  BSR       TRACK_SEND_TO_DS
  ADDQ.W    #1,TRACK_BIT_TEST 
  MOVEM.L   (A7)+,A0-A1/D0
  LEA       $10(A0),A0
  LEA       $26(A1),A1
  DBF       D0,L000C
  JSR       PT_PLAYMUSIC
  MOVEM.L   (A7)+,A0-A6/D0-D7 
  RTE 
TRACK_SEND_TO_DS:
  BSR       TRACK_WAIT_RECEI
  MOVE.L    4(A6),D6
  ANDI.W    #-2,D6
  EXT.L     D6
  MOVEA.L   0(A0),A3
  MOVE.W    DFF096,D1 
  BTST      D0,D1 
  BEQ.S     L000E 
  ST        $A(A0)
  TAS       0(A0) 
  BEQ       L0010 
  ADDA.L    D6,A3 
  ASR.L     #1,D6 
  MOVEQ     #0,D1 
  MOVE.W    4(A0),D1
  SUB.L     D6,D1 
  BPL.S     L000F 
  MOVEQ     #0,D2 
  MOVE.W    $E(A0),D2 
  BEQ.S     L000E 
  CMP.W     #1,D2 
  BEQ.S     L000E 
  MOVEA.L   $A(A0),A3 
  NEG.L     D1
  DIVU      D2,D1 
  SWAP      D1
  EXT.L     D1
  SUB.L     D1,D2 
  LEA       (A3,D1.W*2),A3
  MOVE.L    D2,D1 
  BRA.S     L000F 
L000E:
  MOVE.W    #1,D1 
  MOVEA.L   $A(A0),A3 
  MOVE.W    D1,$E(A0) 
L000F:
  MOVE.L    A3,0(A0)
  MOVE.W    D1,4(A0)
L0010:
  MOVEQ     #0,D1 
  MOVE.W    0(A1),D1
  ADD.W     4(A1),D1
  TST.L     D1
  BPL.S     L0011 
  MOVEQ     #0,D1 
L0011:
  CMP.L     #$7FFF,D1 
  BLT.S     L0012 
  MOVE.W    #$7FFF,D1 
L0012:
  MOVE.W    D1,0(A1)
  MOVE.W    8(A0),D0
  MOVE.W    #$7FFF,D2 
  SUB.W     D1,D2 
  MULU      D0,D1 
  MULU      D0,D2 
  SWAP      D1
  SWAP      D2
  MOVE.W    2(A1),D7
  MULU      D7,D1 
  MULU      D7,D2 
  LSL.L     #2,D1 
  LSL.L     #2,D2 
  BSR       TRACK_WAIT_TRANS
  MOVE.L    D2,4(A6)
  BSR       TRACK_WAIT_TRANS
  MOVE.L    D1,4(A6)
  MOVEQ     #0,D0 
  MOVEQ     #0,D2 
  MOVE.W    6(A0),D0
  CMP.W     #$6B,D0 
  BLT.S     L0013 
  MOVE.L    #$24665268,D2 
  DIVU.L    D0,D2 
L0013:
  BSR       TRACK_WAIT_TRANS
  MOVE.L    D2,4(A6)
  CLR.L     4(A6) 
  BSR       TRACK_WAIT_RECEI
  MOVE.L    4(A6),D0
  MOVE.W    D0,D3 
  ASR.W     #2,D0 
  ADDQ.W    #3,D0 
  MOVE.W    D0,D2 
  BSR       TRACK_WAIT_TRANS
  MOVE.L    D0,4(A6)
  LEA       6(A6),A5
  TST.L     D2
  BLE       TRACK_NO_TRANSMI
  MOVE.W    4(A0),D3
  CMP.W     D3,D2 
  BLT       TRACK_SEND_NORMA
  CMPI.W    #1,$E(A0) 
  BLE       TRACK_SEND_SILEN
  MOVE.W    $E(A0),D3 
  MOVE.W    4(A0),D0
L0014:
  MOVE.W    D0,D4 
  BSR       TRACK_SEND_NORMA
  SUB.W     D4,D2 
  MOVEA.L   $A(A0),A3 
  CMP.W     D3,D2 
  BLE       L0015 
  MOVE.W    D3,D0 
  BRA       L0014 
L0015:
  MOVE.W    D2,D0 
  BSR       TRACK_SEND_NORMA
TRACK_NO_TRANSMI:
  RTS 
TRACK_SEND_SILEN:
  MOVE.W    4(A0),D0
  SUB.W     D0,D2 
  BSR       TRACK_SEND_NORMA
  MOVEA.L   $A(A0),A3 
  MOVE.W    D2,D0 
  SUBQ.W    #1,D0 
  BMI       L0019 
L0018:
  MOVE.W    (A3),(A5) 
  DBF       D0,L0018
L0019:
  RTS 
TRACK_SEND_NORMA:
  SUBQ.W    #1,D0 
  BMI.S     L001C 
L001B:
  MOVE.W    (A3)+,(A5)
  DBF       D0,L001B
L001C:
  RTS 
TRACK_WAIT_RECEI:
  BTST      #0,$FFFFA202.W
  BEQ.S     TRACK_WAIT_RECEI
  RTS 
TRACK_WAIT_TRANS:
  BTST      #1,$FFFFA202.W
  BEQ.S     TRACK_WAIT_TRANS
  RTS 
DFF096_CONTR:
  MOVE.W    D0,-(A7)
  MOVE.W    6(A7),D0
  BTST      #15,D0
  BNE.S     AP_BITS_SET 
  NOT.W     D0
  AND.W     D0,DFF096 
  BRA.S     DFF096_CONTR_END
AP_BITS_SET:
  OR.W      D0,DFF096 
DFF096_CONTR_END:
  MOVE.W    (A7)+,D0
  RTS 
PT_INITMUSIC:
  MOVE.L    A6,PT_SONGDATAPTR 
  LEA       $3B6(A6),A0 
  CMPM.B    (A0)+,(A0)+ 
  BLS.S     AP_NO_BUGGY 
  CLR.B     -1(A0)
AP_NO_BUGGY:
  MOVEQ     #$7F,D0 
  MOVEQ     #0,D1 
AP_SEARCH_MAX:
  CMP.B     (A0)+,D1
  BHI.S     AP_SEARCHING
  MOVE.B    -1(A0),D1 
AP_SEARCHING:
  DBF       D0,AP_SEARCH_MAX
  ADDQ.L    #1,D1 
  MOVEQ     #$A,D0
  LSL.L     D0,D1 
  LEA       (A6),A0 
  LEA       $2A(A0),A1
  LEA       $43C(A0),A0 
  ADDA.L    D1,A0 
  LEA       PT_SAMPLESTARTS(PC),A2
  MOVEQ     #$1E,D0 
  MOVEQ     #0,D2 
AP_SET_TABL:
  MOVE.L    A0,(A2)+
  MOVEQ     #0,D1 
  MOVE.W    (A1),D1 
  BEQ.S     AP_ANY_SPL
  LEA       (A0,D1.L*2),A0
  ADDQ.W    #1,D2 
AP_ANY_SPL:
  LEA       $1E(A1),A1
  DBF       D0,AP_SET_TABL
  MOVE.B    #6,PT_SPEED 
  MOVE.W    #$7D,REALTEMPO
  MOVEQ     #0,D0 
  LEA       DFF0A0,A0 
  MOVE.W    D0,8(A0)
  MOVE.W    D0,$18(A0)
  MOVE.W    D0,$28(A0)
  MOVE.W    D0,$38(A0)
  CLR.B     PT_SONGPOS
  CLR.B     PT_COUNTER
  CLR.W     PT_PATTPOS
  CLR.L     PT_COUNTER
  MOVE.L    #6,PT_CURRSPEED 
  MOVE.W    #0,PT_DMACONTEMP
  MOVE.W    #$F,PT_ACTIVECHANNEL
  CLR.L     PT_SONGPOSITION 
  CLR.L     PT_PATTERNPTR 
  CLR.L     PT_PATTERNPOSITI
  LEA       PT_AUDCHAN1TEMP(PC),A0
  BSR       PT_CLEARCHANNEL 
  LEA       PT_AUDCHAN2TEMP(PC),A0
  BSR       PT_CLEARCHANNEL 
  LEA       PT_AUDCHAN3TEMP(PC),A0
  BSR       PT_CLEARCHANNEL 
  LEA       PT_AUDCHAN4TEMP(PC),A0
  BSR       PT_CLEARCHANNEL 
  MOVE.W    #$F,-(A7) 
  BSR       DFF096_CONTR
  ADDQ.W    #2,A7 
  RTS 
PT_CLEARCHANNEL:
  CLR.L     (A0)+ 
  CLR.L     (A0)+ 
  CLR.L     (A0)+ 
  CLR.L     (A0)+ 
  CLR.L     (A0)+ 
  TST.L     (A0)+ 
  CLR.L     (A0)+ 
  CLR.L     (A0)+ 
  CLR.L     (A0)+ 
  CLR.L     (A0)+ 
  CLR.L     (A0)+ 
  RTS 
PT_PLAYMUSIC:
  MOVEA.L   PT_SONGDATAPTR(PC),A0 
  ADDQ.L    #1,PT_COUNTER 
  MOVE.L    PT_COUNTER(PC),D0 
  CMP.L     PT_CURRSPEED(PC),D0 
  BCS.S     PT_NONEWNOTE
  CLR.L     PT_COUNTER
  TST.B     L00BB 
  BEQ.S     PT_GETNEWNOTE 
  BSR.S     PT_NONEWALLCHANN
  BRA       PT_DSKIP
PT_NONEWNOTE:
  BSR.S     PT_NONEWALLCHANN
  BRA       PT_NONEWPOSITION
PT_NONEWALLCHANN:
  LEA       PT_AUDCHAN1TEMP(PC),A6
  LEA       DFF0A0,A5 
  BSR       PT_CHECKEFFECTS 
  LEA       PT_AUDCHAN2TEMP(PC),A6
  LEA       DFF0B0,A5 
  BSR       PT_CHECKEFFECTS 
  LEA       PT_AUDCHAN3TEMP(PC),A6
  LEA       DFF0C0,A5 
  BSR       PT_CHECKEFFECTS 
  LEA       PT_AUDCHAN4TEMP(PC),A6
  LEA       DFF0D0,A5 
  BRA       PT_CHECKEFFECTS 
PT_GETNEWNOTE:
  LEA       $C(A0),A3 
  LEA       $3B8(A0),A2 
  LEA       $43C(A0),A0 
  MOVEQ     #0,D1 
  MOVE.L    PT_SONGPOSITION(PC),D0
  MOVE.B    0(A2,D0.W),D1 
  ASL.L     #8,D1 
  ASL.L     #2,D1 
  ADD.L     PT_PATTERNPOSITI(PC),D1 
  MOVE.L    D1,PT_PATTERNPTR
  CLR.W     PT_DMACONTEMP 
  LEA       DFF0A0,A5 
  LEA       PT_AUDCHAN1TEMP(PC),A6
  MOVEQ     #1,D2 
  BSR       PT_PLAYVOICE
  MOVEQ     #0,D0 
  MOVE.B    $13(A6),D0
  MOVE.W    D0,8(A5)
  LEA       DFF0B0,A5 
  LEA       PT_AUDCHAN2TEMP(PC),A6
  MOVEQ     #2,D2 
  BSR.S     PT_PLAYVOICE
  MOVEQ     #0,D0 
  MOVE.B    $13(A6),D0
  MOVE.W    D0,8(A5)
  LEA       DFF0C0,A5 
  LEA       PT_AUDCHAN3TEMP(PC),A6
  MOVEQ     #3,D2 
  BSR.S     PT_PLAYVOICE
  MOVEQ     #0,D0 
  MOVE.B    $13(A6),D0
  MOVE.W    D0,8(A5)
  LEA       DFF0D0,A5 
  LEA       PT_AUDCHAN4TEMP(PC),A6
  MOVEQ     #4,D2 
  BSR.S     PT_PLAYVOICE
  MOVEQ     #0,D0 
  MOVE.B    $13(A6),D0
  MOVE.W    D0,8(A5)
  BRA       PT_SETDMA 
PT_CHECKMETRONOM:
  CMP.B     PT_METROCHANNEL,D2
  BNE       PT_RETURN 
  MOVE.B    PT_METROSPEED,D2
  BEQ       PT_RETURN 
  MOVE.L    PT_PATTERNPOSITI,D3 
  LSR.L     #4,D3 
  DIVU      D2,D3 
  SWAP      D3
  TST.W     D3
  BNE       PT_RETURN 
  ANDI.L    #$FFF,(A6)
  ORI.L     #$10D6F000,(A6) 
  RTS 
PT_PLAYVOICE:
  TST.L     (A6)
  BNE.S     PT_PLVSKIP
  BSR       PT_PERNOP 
PT_PLVSKIP:
  MOVE.L    0(A0,D1.L),(A6) 
  BSR.S     PT_CHECKMETRONOM
  ADDQ.L    #4,D1 
  MOVEQ     #0,D2 
  MOVE.B    2(A6),D2
  ANDI.B    #-$10,D2
  LSR.B     #4,D2 
  MOVE.B    (A6),D0 
  ANDI.B    #-$10,D0
  OR.B      D0,D2 
  TST.B     D2
  BEQ.S     PT_SETREGISTERS 
  MOVEQ     #0,D3 
  LEA       PT_SAMPLESTARTS(PC),A1
  MOVE.W    D2,D4 
  MOVE.B    D2,$2B(A6)
  SUBQ.L    #1,D2 
  LSL.L     #2,D2 
  MULU      #$1E,D4 
  MOVE.L    0(A1,D2.L),4(A6)
  MOVE.W    0(A3,D4.L),8(A6)
  MOVE.W    0(A3,D4.L),$28(A6)
  MOVE.B    2(A3,D4.L),$12(A6)
  MOVE.B    3(A3,D4.L),$13(A6)
  MOVE.W    4(A3,D4.L),D3 
  TST.W     D3
  BEQ.S     PT_NOLOOP 
  MOVE.L    4(A6),D2
  ASL.W     #1,D3 
  ADD.L     D3,D2 
  MOVE.L    D2,$A(A6) 
  MOVE.L    D2,$24(A6)
  MOVE.W    4(A3,D4.L),D0 
  ADD.W     6(A3,D4.L),D0 
  MOVE.W    D0,8(A6)
  MOVE.W    6(A3,D4.L),$E(A6) 
  BRA.S     PT_SETREGISTERS 
PT_NOLOOP:
  MOVE.L    4(A6),D2
  ADD.L     D3,D2 
  MOVE.L    D2,$A(A6) 
  MOVE.L    D2,$24(A6)
  MOVE.W    6(A3,D4.L),$E(A6) 
PT_SETREGISTERS:
  MOVE.W    (A6),D0 
  ANDI.W    #$FFF,D0
  BEQ       PT_CHECKMOREEFFE
  MOVE.W    2(A6),D0
  ANDI.W    #$FF0,D0
  CMP.W     #$E50,D0
  BEQ.S     PT_DOSETFINETUNE
  MOVE.B    2(A6),D0
  ANDI.B    #$F,D0
  CMP.B     #3,D0 
  BEQ.S     PT_CHKTONEPORTA 
  CMP.B     #5,D0 
  BEQ.S     PT_CHKTONEPORTA 
  CMP.B     #9,D0 
  BNE.S     PT_SETPERIOD
  BSR       PT_CHECKMOREEFFE
  BRA.S     PT_SETPERIOD
PT_DOSETFINETUNE:
  BSR       PT_SETFINETUNE
  BRA.S     PT_SETPERIOD
PT_CHKTONEPORTA:
  BSR       PT_SETTONEPORTA 
  BRA       PT_CHECKMOREEFFE
PT_SETPERIOD:
  MOVEM.L   A0-A1/D0-D1,-(A7) 
  MOVE.W    (A6),D1 
  ANDI.W    #$FFF,D1
  LEA       PT_PERIODTABLE(PC),A1 
  MOVEQ     #0,D0 
  MOVEQ     #$24,D7 
PT_FTULOOP:
  CMP.W     0(A1,D0.W),D1 
  BCC.S     PT_FTUFOUND 
  ADDQ.L    #2,D0 
  DBF       D7,PT_FTULOOP 
PT_FTUFOUND:
  MOVEQ     #0,D1 
  MOVE.B    $12(A6),D1
  MULU      #$4A,D1 
  ADDA.L    D1,A1 
  MOVE.W    0(A1,D0.W),$10(A6)
  MOVEM.L   (A7)+,A0-A1/D0-D1 
  MOVE.W    2(A6),D0
  ANDI.W    #$FF0,D0
  CMP.W     #$ED0,D0
  BEQ       PT_CHECKMOREEFFE
  MOVE.W    $14(A6),-(A7) 
  BSR       DFF096_CONTR
  ADDQ.W    #2,A7 
  BTST      #2,$1E(A6)
  BNE.S     PT_VIBNOC 
  CLR.B     $1B(A6) 
PT_VIBNOC:
  BTST      #6,$1E(A6)
  BNE.S     PT_TRENOC 
  CLR.B     $1D(A6) 
PT_TRENOC:
  MOVE.W    8(A6),4(A5) 
  MOVE.L    4(A6),(A5)
  BNE.S     PT_SDMASKP
  CLR.L     $A(A6)
  MOVEQ     #1,D0 
  MOVE.W    D0,4(A5)
  MOVE.W    D0,$E(A6) 
PT_SDMASKP:
  MOVE.W    $10(A6),D0
  MOVE.W    D0,6(A5)
  ST        $2A(A6) 
  MOVE.W    $14(A6),D0
  OR.W      D0,PT_DMACONTEMP
  BRA       PT_CHECKMOREEFFE
PT_SETDMA:
  MOVE.W    PT_DMACONTEMP,D0
  AND.W     PT_ACTIVECHANNEL,D0 
  ORI.W     #-$8000,D0
  MOVE.W    D0,-(A7)
  BSR       DFF096_CONTR
  ADDQ.W    #2,A7 
  LEA       DFF0A0,A5 
  LEA       PT_AUDCHAN4TEMP(PC),A6
  MOVE.L    $A(A6),$3A(A5)
  MOVE.W    $E(A6),$3E(A5)
  LEA       PT_AUDCHAN3TEMP(PC),A6
  MOVE.L    $A(A6),$2A(A5)
  MOVE.W    $E(A6),$2E(A5)
  LEA       PT_AUDCHAN2TEMP(PC),A6
  MOVE.L    $A(A6),$1A(A5)
  MOVE.W    $E(A6),$1E(A5)
  LEA       PT_AUDCHAN1TEMP(PC),A6
  MOVE.L    $A(A6),$A(A5) 
  MOVE.W    $E(A6),$E(A5) 
PT_DSKIP:
  ADDI.L    #$10,PT_PATTERNPOSITI 
  MOVE.B    PT_PATTDELAYTIME,D0 
  BEQ.S     PT_DSKPC
  MOVE.B    D0,L00BB
  CLR.B     PT_PATTDELAYTIME
PT_DSKPC:
  TST.B     L00BB 
  BEQ.S     PT_DSKPA
  SUBQ.B    #1,L00BB
  BEQ.S     PT_DSKPA
  SUBI.L    #$10,PT_PATTERNPOSITI 
PT_DSKPA:
  TST.B     PT_PBREAKFLAG 
  BEQ.S     PT_NNPYSK 
  SF        PT_PBREAKFLAG 
  MOVEQ     #0,D0 
  MOVE.B    PT_PBREAKPOSITIO(PC),D0 
  LSL.W     #4,D0 
  MOVE.L    D0,PT_PATTERNPOSITI 
  CLR.B     PT_PBREAKPOSITIO
PT_NNPYSK:
  CMPI.L    #$400,PT_PATTERNPOSITI
  BNE.S     PT_NONEWPOSITION
PT_NEXTPOSITION:
  MOVEQ     #0,D0 
  MOVE.B    PT_PBREAKPOSITIO(PC),D0 
  LSL.W     #4,D0 
  MOVE.L    D0,PT_PATTERNPOSITI 
  CLR.B     PT_PBREAKPOSITIO
  CLR.B     PT_POSJUMPASSERT
  ADDQ.L    #1,PT_SONGPOSITION
  ANDI.L    #$7F,PT_SONGPOSITION
  MOVE.L    PT_SONGPOSITION(PC),D1
  MOVEA.L   PT_SONGDATAPTR(PC),A0 
  CMP.B     $3B6(A0),D1 
  BCS.S     PT_NONEWPOSITION
  CLR.L     PT_SONGPOSITION 
PT_NONEWPOSITION:
  TST.B     PT_POSJUMPASSERT
  BNE.S     PT_NEXTPOSITION 
  RTS 
PT_CHECKEFFECTS:
  BSR.S     PT_CHKEFX2
  MOVEQ     #0,D0 
  MOVE.B    $13(A6),D0
  MOVE.W    D0,8(A5)
  RTS 
PT_CHKEFX2:
  BSR       PT_UPDATEFUNK 
  MOVE.W    2(A6),D0
  ANDI.W    #$FFF,D0
  BEQ.S     PT_RETURN 
  MOVE.B    2(A6),D0
  ANDI.B    #$F,D0
  TST.B     D0
  BEQ.S     PT_ARPEGGIO 
  CMP.B     #1,D0 
  BEQ       PT_PORTAUP
  CMP.B     #2,D0 
  BEQ       PT_PORTADOWN
  CMP.B     #3,D0 
  BEQ       PT_TONEPORTAMENT
  CMP.B     #4,D0 
  BEQ       PT_VIBRATO
  CMP.B     #5,D0 
  BEQ       PT_TONEPLUSVOLSL
  CMP.B     #6,D0 
  BEQ       PT_VIBRATOPLUSVO
  CMP.B     #$E,D0
  BEQ       PT_ECOMMANDS
  MOVE.W    $10(A6),6(A5) 
  CMP.B     #7,D0 
  BEQ       PT_TREMOLO
  CMP.B     #$A,D0
  BEQ       PT_VOLUMESLIDE
PT_RETURN:
  RTS 
PT_PERNOP:
  MOVE.W    $10(A6),6(A5) 
  RTS 
PT_ARPEGGIO:
  MOVEQ     #0,D0 
  MOVE.L    PT_COUNTER(PC),D0 
  DIVS      #3,D0 
  SWAP      D0
  CMP.W     #1,D0 
  BEQ.S     PT_ARPEGGIO1
  CMP.W     #2,D0 
  BEQ.S     PT_ARPEGGIO2
  MOVE.W    $10(A6),D2
  BRA.S     PT_ARPEGGIOSET
PT_ARPEGGIO1:
  MOVEQ     #0,D0 
  MOVE.B    3(A6),D0
  LSR.B     #4,D0 
  BRA.S     PT_ARPEGGIOFIND 
PT_ARPEGGIO2:
  MOVEQ     #0,D0 
  MOVE.B    3(A6),D0
  ANDI.B    #$F,D0
PT_ARPEGGIOFIND:
  ASL.W     #1,D0 
  MOVEQ     #0,D1 
  MOVE.B    $12(A6),D1
  MULU      #$4A,D1 
  LEA       PT_PERIODTABLE(PC),A0 
  ADDA.L    D1,A0 
  MOVEQ     #0,D1 
  MOVE.W    $10(A6),D1
  MOVEQ     #$24,D7 
PT_ARPLOOP:
  MOVE.W    0(A0,D0.W),D2 
  CMP.W     (A0),D1 
  BCC.S     PT_ARPEGGIOSET
  ADDQ.L    #2,A0 
  DBF       D7,PT_ARPLOOP 
  RTS 
PT_ARPEGGIOSET:
  MOVE.W    D2,6(A5)
  RTS 
PT_FINEPORTAUP:
  TST.L     PT_COUNTER
  BNE.S     PT_RETURN 
  MOVE.B    #$F,PT_LOWMASK
PT_PORTAUP:
  MOVEQ     #0,D0 
  MOVE.B    3(A6),D0
  AND.B     PT_LOWMASK,D0 
  MOVE.B    #-1,PT_LOWMASK
  SUB.W     D0,$10(A6)
  MOVE.W    $10(A6),D0
  ANDI.W    #$FFF,D0
  CMP.W     #$71,D0 
  BPL.S     PT_PORTAUSKIP 
  ANDI.W    #-$1000,$10(A6) 
  ORI.W     #$71,$10(A6)
PT_PORTAUSKIP:
  MOVE.W    $10(A6),D0
  ANDI.W    #$FFF,D0
  MOVE.W    D0,6(A5)
  RTS 
PT_FINEPORTADOWN:
  TST.L     PT_COUNTER
  BNE       PT_RETURN 
  MOVE.B    #$F,PT_LOWMASK
PT_PORTADOWN:
  CLR.W     D0
  MOVE.B    3(A6),D0
  AND.B     PT_LOWMASK,D0 
  MOVE.B    #-1,PT_LOWMASK
  ADD.W     D0,$10(A6)
  MOVE.W    $10(A6),D0
  ANDI.W    #$FFF,D0
  CMP.W     #$358,D0
  BMI.S     PT_PORTADSKIP 
  ANDI.W    #-$1000,$10(A6) 
  ORI.W     #$358,$10(A6) 
PT_PORTADSKIP:
  MOVE.W    $10(A6),D0
  ANDI.W    #$FFF,D0
  MOVE.W    D0,6(A5)
  RTS 
PT_SETTONEPORTA:
  MOVE.L    A0,-(A7)
  MOVE.W    (A6),D2 
  ANDI.W    #$FFF,D2
  MOVEQ     #0,D0 
  MOVE.B    $12(A6),D0
  MULU      #$4A,D0 
  LEA       PT_PERIODTABLE(PC),A0 
  ADDA.L    D0,A0 
  MOVEQ     #0,D0 
PT_STPLOOP:
  CMP.W     0(A0,D0.W),D2 
  BCC.S     PT_STPFOUND 
  ADDQ.W    #2,D0 
  CMP.W     #$4A,D0 
  BCS.S     PT_STPLOOP
  MOVEQ     #$46,D0 
PT_STPFOUND:
  MOVE.B    $12(A6),D2
  ANDI.B    #8,D2 
  BEQ.S     PT_STPGOSS
  TST.W     D0
  BEQ.S     PT_STPGOSS
  SUBQ.W    #2,D0 
PT_STPGOSS:
  MOVE.W    0(A0,D0.W),D2 
  MOVEA.L   (A7)+,A0
  MOVE.W    D2,$18(A6)
  MOVE.W    $10(A6),D0
  CLR.B     $16(A6) 
  CMP.W     D0,D2 
  BEQ.S     PT_CLEARTONEPORT
  BGE       PT_RETURN 
  MOVE.B    #1,$16(A6)
  RTS 
PT_CLEARTONEPORT:
  CLR.W     $18(A6) 
  RTS 
PT_TONEPORTAMENT:
  MOVE.B    3(A6),D0
  BEQ.S     PT_TONEPORTNOCHA
  MOVE.B    D0,$17(A6)
  CLR.B     3(A6) 
PT_TONEPORTNOCHA:
  TST.W     $18(A6) 
  BEQ       PT_RETURN 
  MOVEQ     #0,D0 
  MOVE.B    $17(A6),D0
  TST.B     $16(A6) 
  BNE.S     PT_TONEPORTAUP
  ADD.W     D0,$10(A6)
  MOVE.W    $18(A6),D0
  CMP.W     $10(A6),D0
  BGT.S     PT_TONEPORTASETP
  MOVE.W    $18(A6),$10(A6) 
  CLR.W     $18(A6) 
  BRA.S     PT_TONEPORTASETP
PT_TONEPORTAUP:
  SUB.W     D0,$10(A6)
  MOVE.W    $18(A6),D0
  CMP.W     $10(A6),D0
  BLT.S     PT_TONEPORTASETP
  MOVE.W    $18(A6),$10(A6) 
  CLR.W     $18(A6) 
PT_TONEPORTASETP:
  MOVE.W    $10(A6),D2
  MOVE.B    $1F(A6),D0
  ANDI.B    #$F,D0
  BEQ.S     PT_GLISSSKIP
  MOVEQ     #0,D0 
  MOVE.B    $12(A6),D0
  MULU      #$4A,D0 
  LEA       PT_PERIODTABLE(PC),A0 
  ADDA.L    D0,A0 
  MOVEQ     #0,D0 
PT_GLISSLOOP:
  CMP.W     0(A0,D0.W),D2 
  BCC.S     PT_GLISSFOUND 
  ADDQ.W    #2,D0 
  CMP.W     #$4A,D0 
  BCS.S     PT_GLISSLOOP
  MOVEQ     #$46,D0 
PT_GLISSFOUND:
  MOVE.W    0(A0,D0.W),D2 
PT_GLISSSKIP:
  MOVE.W    D2,6(A5)
  RTS 
PT_VIBRATO:
  MOVE.B    3(A6),D0
  BEQ.S     PT_VIBRATO2 
  MOVE.B    $1A(A6),D2
  ANDI.B    #$F,D0
  BEQ.S     PT_VIBSKIP
  ANDI.B    #-$10,D2
  OR.B      D0,D2 
PT_VIBSKIP:
  MOVE.B    3(A6),D0
  ANDI.B    #-$10,D0
  BEQ.S     PT_VIBSKIP2 
  ANDI.B    #$F,D2
  OR.B      D0,D2 
PT_VIBSKIP2:
  MOVE.B    D2,$1A(A6)
PT_VIBRATO2:
  MOVE.L    A4,-(A7)
  MOVE.B    $1B(A6),D0
  LEA       PT_VIBRATOTABLE(PC),A4
  LSR.W     #2,D0 
  ANDI.W    #$1F,D0 
  MOVEQ     #0,D2 
  MOVE.B    $1E(A6),D2
  ANDI.B    #3,D2 
  BEQ.S     PT_VIB_SINE 
  LSL.B     #3,D0 
  CMP.B     #1,D2 
  BEQ.S     PT_VIB_RAMPDOWN 
  MOVE.B    #-1,D2
  BRA.S     PT_VIB_SET
PT_VIB_RAMPDOWN:
  TST.B     $1B(A6) 
  BPL.S     PT_VIB_RAMPDOWN2
  MOVE.B    #-1,D2
  SUB.B     D0,D2 
  BRA.S     PT_VIB_SET
PT_VIB_RAMPDOWN2:
  MOVE.B    D0,D2 
  BRA.S     PT_VIB_SET
PT_VIB_SINE:
  MOVE.B    0(A4,D0.W),D2 
PT_VIB_SET:
  MOVE.B    $1A(A6),D0
  ANDI.W    #$F,D0
  MULU      D0,D2 
  LSR.W     #7,D2 
  MOVE.W    $10(A6),D0
  TST.B     $1B(A6) 
  BMI.S     PT_VIBRATONEG 
  ADD.W     D2,D0 
  BRA.S     PT_VIBRATO3 
PT_VIBRATONEG:
  SUB.W     D2,D0 
PT_VIBRATO3:
  MOVE.W    D0,6(A5)
  MOVE.B    $1A(A6),D0
  LSR.W     #2,D0 
  ANDI.W    #$3C,D0 
  ADD.B     D0,$1B(A6)
  MOVEA.L   (A7)+,A4
  RTS 
PT_TONEPLUSVOLSL:
  BSR       PT_TONEPORTNOCHA
  BRA       PT_VOLUMESLIDE
PT_VIBRATOPLUSVO:
  BSR.S     PT_VIBRATO2 
  BRA       PT_VOLUMESLIDE
PT_TREMOLO:
  MOVE.L    A4,-(A7)
  MOVE.B    3(A6),D0
  BEQ.S     PT_TREMOLO2 
  MOVE.B    $1C(A6),D2
  ANDI.B    #$F,D0
  BEQ.S     PT_TRESKIP
  ANDI.B    #-$10,D2
  OR.B      D0,D2 
PT_TRESKIP:
  MOVE.B    3(A6),D0
  ANDI.B    #-$10,D0
  BEQ.S     PT_TRESKIP2 
  ANDI.B    #$F,D2
  OR.B      D0,D2 
PT_TRESKIP2:
  MOVE.B    D2,$1C(A6)
PT_TREMOLO2:
  MOVE.B    $1D(A6),D0
  LEA       PT_VIBRATOTABLE(PC),A4
  LSR.W     #2,D0 
  ANDI.W    #$1F,D0 
  MOVEQ     #0,D2 
  MOVE.B    $1E(A6),D2
  LSR.B     #4,D2 
  ANDI.B    #3,D2 
  BEQ.S     PT_TRE_SINE 
  LSL.B     #3,D0 
  CMP.B     #1,D2 
  BEQ.S     PT_TRE_RAMPDOWN 
  MOVE.B    #-1,D2
  BRA.S     PT_TRE_SET
PT_TRE_RAMPDOWN:
  TST.B     $1B(A6) 
  BPL.S     PT_TRE_RAMPDOWN2
  MOVE.B    #-1,D2
  SUB.B     D0,D2 
  BRA.S     PT_TRE_SET
PT_TRE_RAMPDOWN2:
  MOVE.B    D0,D2 
  BRA.S     PT_TRE_SET
PT_TRE_SINE:
  MOVE.B    0(A4,D0.W),D2 
PT_TRE_SET:
  MOVE.B    $1C(A6),D0
  ANDI.W    #$F,D0
  MULU      D0,D2 
  LSR.W     #6,D2 
  MOVEQ     #0,D0 
  MOVE.B    $13(A6),D0
  TST.B     $1D(A6) 
  BMI.S     PT_TREMOLONEG 
  ADD.W     D2,D0 
  BRA.S     PT_TREMOLO3 
PT_TREMOLONEG:
  SUB.W     D2,D0 
PT_TREMOLO3:
  BPL.S     PT_TREMOLOSKIP
  CLR.W     D0
PT_TREMOLOSKIP:
  CMP.W     #$40,D0 
  BLS.S     PT_TREMOLOOK
  MOVE.W    #$40,D0 
PT_TREMOLOOK:
  MOVE.W    D0,8(A5)
  MOVE.B    $1C(A6),D0
  LSR.W     #2,D0 
  ANDI.W    #$3C,D0 
  ADD.B     D0,$1D(A6)
  MOVEA.L   (A7)+,A4
  ADDQ.L    #4,A7 
  RTS 
PT_SAMPLEOFFSET:
  MOVEQ     #0,D0 
  MOVE.B    3(A6),D0
  BEQ.S     PT_SONONEW
  MOVE.B    D0,$20(A6)
PT_SONONEW:
  MOVE.B    $20(A6),D0
  LSL.W     #7,D0 
  CMP.W     8(A6),D0
  BGE.S     PT_SOFSKIP
  SUB.W     D0,8(A6)
  LSL.W     #1,D0 
  ADD.L     D0,4(A6)
  RTS 
PT_SOFSKIP:
  MOVE.W    #1,8(A6)
  RTS 
PT_VOLUMESLIDE:
  MOVEQ     #0,D0 
  MOVE.B    3(A6),D0
  LSR.B     #4,D0 
  TST.B     D0
  BEQ.S     PT_VOLSLIDEDOWN 
PT_VOLSLIDEUP:
  ADD.B     D0,$13(A6)
  CMPI.B    #$40,$13(A6)
  BMI.S     PT_VSUSKIP
  MOVE.B    #$40,$13(A6)
PT_VSUSKIP:
  MOVE.B    $13(A6),D0
  RTS 
PT_VOLSLIDEDOWN:
  MOVEQ     #0,D0 
  MOVE.B    3(A6),D0
  ANDI.B    #$F,D0
PT_VOLSLIDEDOWN2:
  SUB.B     D0,$13(A6)
  BPL.S     PT_VSDSKIP
  CLR.B     $13(A6) 
PT_VSDSKIP:
  MOVE.B    $13(A6),D0
  RTS 
PT_POSITIONJUMP:
  MOVEQ     #0,D0 
  MOVE.B    3(A6),D0
  SUBQ.B    #1,D0 
  MOVE.L    D0,PT_SONGPOSITION
PT_PJ2:
  CLR.B     PT_PBREAKPOSITIO
  ST        PT_POSJUMPASSERT
  RTS 
PT_VOLUMECHANGE:
  MOVEQ     #0,D0 
  MOVE.B    3(A6),D0
  CMP.B     #$40,D0 
  BLS.S     PT_VOLUMEOK 
  MOVEQ     #$40,D0 
PT_VOLUMEOK:
  MOVE.B    D0,$13(A6)
  RTS 
PT_PATTERNBREAK:
  MOVEQ     #0,D0 
  MOVE.B    3(A6),D0
  MOVE.L    D0,D2 
  LSR.B     #4,D0 
  MULU      #$A,D0
  ANDI.B    #$F,D2
  ADD.B     D2,D0 
  CMP.B     #$3F,D0 
  BHI.S     PT_PJ2
  MOVE.B    D0,PT_PBREAKPOSITIO 
  ST        PT_POSJUMPASSERT
  RTS 
PT_SETSPEED:
  MOVE.B    3(A6),D0
  ANDI.W    #$FF,D0 
  BEQ.S     PT_SPEEDNULL
  CMP.W     #$20,D0 
  BCS.S     PT_NORMSPD
  MOVE.W    D0,REALTEMPO
  RTS 
PT_NORMSPD:
  CLR.L     PT_COUNTER
  MOVE.W    D0,L00AA
  RTS 
PT_SPEEDNULL:
  RTS 
PT_CHECKMOREEFFE:
  MOVE.B    2(A6),D0
  ANDI.B    #$F,D0
  CMP.B     #9,D0 
  BEQ       PT_SAMPLEOFFSET 
  CMP.B     #$B,D0
  BEQ       PT_POSITIONJUMP 
  CMP.B     #$D,D0
  BEQ.S     PT_PATTERNBREAK 
  CMP.B     #$E,D0
  BEQ.S     PT_ECOMMANDS
  CMP.B     #$F,D0
  BEQ.S     PT_SETSPEED 
  CMP.B     #$C,D0
  BEQ       PT_VOLUMECHANGE 
  BRA       PT_PERNOP 
PT_ECOMMANDS:
  MOVE.B    3(A6),D0
  ANDI.B    #-$10,D0
  LSR.B     #4,D0 
  BEQ.S     PT_FILTERONOFF
  CMP.B     #1,D0 
  BEQ       PT_FINEPORTAUP
  CMP.B     #2,D0 
  BEQ       PT_FINEPORTADOWN
  CMP.B     #3,D0 
  BEQ.S     PT_SETGLISSCONTR
  CMP.B     #4,D0 
  BEQ       PT_SETVIBRATOCON
  CMP.B     #5,D0 
  BEQ       PT_SETFINETUNE
  CMP.B     #6,D0 
  BEQ       PT_JUMPLOOP 
  CMP.B     #7,D0 
  BEQ       PT_SETTREMOLOCON
  CMP.B     #8,D0 
  BEQ       PT_KARPLUSSTRONG
  CMP.B     #$E,D0
  BEQ       PT_PATTERNDELAY 
  CMP.B     #9,D0 
  BEQ       PT_RETRIGNOTE 
  CMP.B     #$A,D0
  BEQ       PT_VOLUMEFINEUP 
  CMP.B     #$B,D0
  BEQ       PT_VOLUMEFINEDOW
  CMP.B     #$C,D0
  BEQ       PT_NOTECUT
  CMP.B     #$D,D0
  BEQ       PT_NOTEDELAY
  CMP.B     #$F,D0
  BEQ       PT_FUNKIT 
  RTS 
PT_FILTERONOFF:
  RTS 
PT_SETGLISSCONTR:
  MOVE.B    3(A6),D0
  ANDI.B    #$F,D0
  ANDI.B    #-$10,$1F(A6) 
  OR.B      D0,$1F(A6)
  RTS 
PT_SETVIBRATOCON:
  MOVE.B    3(A6),D0
  ANDI.B    #$F,D0
  ANDI.B    #-$10,$1E(A6) 
  OR.B      D0,$1E(A6)
  RTS 
PT_SETFINETUNE:
  MOVE.B    3(A6),D0
  ANDI.B    #$F,D0
  MOVE.B    D0,$12(A6)
  RTS 
PT_JUMPLOOP:
  TST.L     PT_COUNTER
  BNE       PT_RETURN 
  MOVE.B    3(A6),D0
  ANDI.B    #$F,D0
  BEQ.S     PT_SETLOOP
  TST.B     $22(A6) 
  BEQ.S     PT_JUMPCNT
  SUBQ.B    #1,$22(A6)
  BEQ       PT_RETURN 
PT_JMPLOOP:
  MOVE.B    $21(A6),PT_PBREAKPOSITIO
  ST        PT_PBREAKFLAG 
  RTS 
PT_JUMPCNT:
  MOVE.B    D0,$22(A6)
  BRA.S     PT_JMPLOOP
PT_SETLOOP:
  MOVE.L    PT_PATTERNPOSITI,D0 
  LSR.L     #4,D0 
  ANDI.B    #$3F,D0 
  MOVE.B    D0,$21(A6)
  RTS 
PT_SETTREMOLOCON:
  MOVE.B    3(A6),D0
  ANDI.B    #$F,D0
  LSL.B     #4,D0 
  ANDI.B    #$F,$1E(A6) 
  OR.B      D0,$1E(A6)
  RTS 
PT_KARPLUSSTRONG:
  MOVEM.L   A0-A1/D1-D2,-(A7) 
  MOVEA.L   $A(A6),A0 
  MOVEA.L   A0,A1 
  MOVE.W    $E(A6),D0 
  ADD.W     D0,D0 
  SUBQ.W    #2,D0 
PT_KARPLOP:
  MOVE.B    (A0),D1 
  EXT.W     D1
  MOVE.B    1(A0),D2
  EXT.W     D2
  ADD.W     D1,D2 
  ASR.W     #1,D2 
  MOVE.B    D2,(A0)+
  DBF       D0,PT_KARPLOP 
  MOVE.B    (A0),D1 
  EXT.W     D1
  MOVE.B    (A1),D2 
  EXT.W     D2
  ADD.W     D1,D2 
  ASR.W     #1,D2 
  MOVE.B    D2,(A0) 
  MOVEM.L   (A7)+,A0-A1/D1-D2 
  RTS 
PT_RETRIGNOTE:
  MOVE.L    D1,-(A7)
  MOVEQ     #0,D0 
  MOVE.B    3(A6),D0
  ANDI.B    #$F,D0
  BEQ       PT_RTNEND 
  MOVE.L    PT_COUNTER,D1 
  BNE.S     PT_RTNSKP 
  MOVE.W    0(A6),D1
  ANDI.W    #$FFF,D1
  BNE       PT_RTNEND 
  MOVE.L    PT_COUNTER,D1 
PT_RTNSKP:
  DIVU      D0,D1 
  SWAP      D1
  TST.W     D1
  BNE       PT_RTNEND 
PT_DORETRG:
  MOVE.L    4(A6),(A5)
  MOVE.W    8(A6),4(A5) 
  MOVE.W    $10(A6),6(A5) 
  MOVE.L    $A(A6),$A(A5) 
  MOVE.W    $E(A6),$E(A5) 
PT_RTNEND:
  MOVE.L    (A7)+,D1
  RTS 
PT_VOLUMEFINEUP:
  TST.L     PT_COUNTER
  BNE       PT_RETURN 
  MOVEQ     #0,D0 
  MOVE.B    3(A6),D0
  ANDI.B    #$F,D0
  BRA       PT_VOLSLIDEUP 
PT_VOLUMEFINEDOW:
  TST.L     PT_COUNTER
  BNE       PT_RETURN 
  MOVEQ     #0,D0 
  MOVE.B    3(A6),D0
  ANDI.B    #$F,D0
  BRA       PT_VOLSLIDEDOWN2
PT_NOTECUT:
  MOVEQ     #0,D0 
  MOVE.B    3(A6),D0
  ANDI.B    #$F,D0
  CMP.L     PT_COUNTER,D0 
  BNE       PT_RETURN 
  CLR.B     $13(A6) 
  RTS 
PT_NOTEDELAY:
  MOVEQ     #0,D0 
  MOVE.B    3(A6),D0
  ANDI.B    #$F,D0
  CMP.L     PT_COUNTER,D0 
  BNE       PT_RETURN 
  MOVE.W    (A6),D0 
  ANDI.W    #$FFF,D0
  BEQ       PT_RETURN 
  MOVE.L    D1,-(A7)
  BRA       PT_DORETRG
PT_PATTERNDELAY:
  TST.L     PT_COUNTER
  BNE       PT_RETURN 
  MOVEQ     #0,D0 
  MOVE.B    3(A6),D0
  ANDI.B    #$F,D0
  TST.B     L00BB 
  BNE       PT_RETURN 
  ADDQ.B    #1,D0 
  MOVE.B    D0,PT_PATTDELAYTIME 
  RTS 
PT_FUNKIT:
  TST.L     PT_COUNTER
  BNE       PT_RETURN 
  MOVE.B    3(A6),D0
  ANDI.B    #$F,D0
  LSL.B     #4,D0 
  ANDI.B    #$F,$1F(A6) 
  OR.B      D0,$1F(A6)
  TST.B     D0
  BEQ       PT_RETURN 
PT_UPDATEFUNK:
  MOVEM.L   A0/D1,-(A7) 
  MOVEQ     #0,D0 
  MOVE.B    $1F(A6),D0
  LSR.B     #4,D0 
  BEQ.S     PT_FUNKEND
  LEA       PT_FUNKTABLE(PC),A0 
  MOVE.B    0(A0,D0.W),D0 
  ADD.B     D0,$23(A6)
  BTST      #7,$23(A6)
  BEQ.S     PT_FUNKEND
  CLR.B     $23(A6) 
  MOVE.L    $A(A6),D0 
  MOVEQ     #0,D1 
  MOVE.W    $E(A6),D1 
  ADD.L     D1,D0 
  ADD.L     D1,D0 
  MOVEA.L   $24(A6),A0
  ADDQ.L    #1,A0 
  CMPA.L    D0,A0 
  BCS.S     PT_FUNKOK 
  MOVEA.L   $A(A6),A0 
PT_FUNKOK:
  MOVE.L    A0,$24(A6)
  MOVEQ     #-1,D0
  SUB.B     (A0),D0 
  MOVE.B    D0,(A0) 
PT_FUNKEND:
  MOVEM.L   (A7)+,A0/D1 
  RTS 

;	SECTION DATA 
;	DATA

PT_FUNKTABLE:
  DC.B      0,5,6,7,8,$A,$B,$D,$10,$13,$16,$1A,$20,$2B,$40,-$80 
PT_VIBRATOTABLE:
  DC.B      0,$18,$31,$4A,$61,$78,-$73,-$5F,-$4C,-$3B,-$2C,-$20,-$15,-$C,-6,-3,-1,-3,-6,-$C,-$15,-$20,-$2C,-$3B,-$4C,-$5F,-$73,$78,$61,$4A,$31,$18
PT_PERIODTABLE:
  DC.B      3,$58,3,$28,2,-6,2,-$30,2,-$5A,2,-$80,2,$5C,2,$3A,2,$1A,1,-4,1,-$20,1,-$3B,1,-$54,1,-$6C,1,$7D,1,$68,1,$53,1,$40,1,$2E,1,$1D,1,$D,0,-2,0,-$10,0,-$1E,0,-$2A,0,-$36
  DC.B      0,-$42,0,-$4C,0,-$56,0,-$60,0,-$69,0,-$71,0,-$79,0,$7F,0,$78,0,$71,0,0,3,$52,3,$22,2,-$B,2,-$35,2,-$5E,2,$7D,2,$59,2,$37,2,$17,1,-7,1,-$23,1,-$3E,1,-$57,1,-$6F,1,$7B 
  DC.B      1,$65,1,$51,1,$3E,1,$2C,1,$1C,1,$C,0,-3,0,-$11,0,-$1F,0,-$2B,0,-$37,0,-$43,0,-$4D,0,-$57,0,-$61,0,-$6A,0,-$72,0,-$7A,0,$7E,0,$77,0,$71,0,0,3,$4C,3,$1C,2,-$10,2,-$3B
  DC.B      2,-$62,2,$78,2,$55,2,$33,2,$14,1,-$A,1,-$26,1,-$41,1,-$5A,1,-$72,1,$78,1,$63,1,$4F,1,$3C,1,$2A,1,$1A,1,$A,0,-5,0,-$13,0,-$20,0,-$2D,0,-$39,0,-$44,0,-$4F,0,-$59,0,-$62
  DC.B      0,-$6B,0,-$73,0,-$7B,0,$7D,0,$76,0,$70,0,0,3,$46,3,$17,2,-$16,2,-$40,2,-$67,2,$74,2,$50,2,$2F,2,$10,1,-$E,1,-$2A,1,-$44,1,-$5D,1,-$75,1,$75,1,$60,1,$4C,1,$3A,1,$28 
  DC.B      1,$18,1,8,0,-7,0,-$15,0,-$22,0,-$2F,0,-$3A,0,-$45,0,-$50,0,-$5A,0,-$63,0,-$6C,0,-$74,0,-$7C,0,$7D,0,$76,0,$6F,0,0,3,$40,3,$11,2,-$1B,2,-$45,2,-$6C,2,$6F,2,$4C,2,$2B
  DC.B      2,$C,1,-$11,1,-$2D,1,-$47,1,-$60,1,-$78,1,$72,1,$5E,1,$4A,1,$38,1,$26,1,$16,1,6,0,-9,0,-$17,0,-$24,0,-$30,0,-$3C,0,-$47,0,-$51,0,-$5B,0,-$64,0,-$6D,0,-$75,0,-$7D,0,$7C 
  DC.B      0,$75,0,$6E,0,0,3,$3A,3,$B,2,-$20,2,-$4A,2,-$71,2,$6B,2,$48,2,$27,2,8,1,-$15,1,-$31,1,-$4B,1,-$63,1,-$7A,1,$70,1,$5B,1,$48,1,$35,1,$24,1,$14,1,4,0,-$B,0,-$18 
  DC.B      0,-$25,0,-$32,0,-$3D,0,-$48,0,-$52,0,-$5C,0,-$65,0,-$6E,0,-$76,0,-$7E,0,$7B,0,$74,0,$6D,0,0,3,$34,3,6,2,-$26,2,-$4F,2,-$75,2,$66,2,$44,2,$23,2,4,1,-$19,1,-$34,1,-$4E 
  DC.B      1,-$66,1,-$7D,1,$6D,1,$59,1,$45,1,$33,1,$22,1,$12,1,2,0,-$C,0,-$1A,0,-$27,0,-$33,0,-$3F,0,-$49,0,-$54,0,-$5D,0,-$66,0,-$6F,0,-$77,0,-$7F,0,$7A,0,$73,0,$6D,0,0,3,$2E
  DC.B      3,0,2,-$2B,2,-$54,2,-$7A,2,$62,2,$3F,2,$1F,2,1,1,-$1C,1,-$37,1,-$51,1,-$69,1,-$80,1,$6B,1,$56,1,$43,1,$31,1,$20,1,$10,1,0,0,-$E,0,-$1C,0,-$28,0,-$34,0,-$40,0,-$4B
  DC.B      0,-$55,0,-$5F,0,-$68,0,-$70,0,-$78,0,-$80,0,$79,0,$72,0,$6C,0,0,3,-$75,3,$58,3,$28,2,-6,2,-$30,2,-$5A,2,-$80,2,$5C,2,$3A,2,$1A,1,-4,1,-$20,1,-$3B,1,-$54,1,-$6C,1,$7D 
  DC.B      1,$68,1,$53,1,$40,1,$2E,1,$1D,1,$D,0,-2,0,-$10,0,-$1E,0,-$2A,0,-$36,0,-$42,0,-$4C,0,-$56,0,-$60,0,-$69,0,-$71,0,-$79,0,$7F,0,$78,0,0,3,-$7C,3,$52,3,$22,2,-$B,2,-$35
  DC.B      2,-$5D,2,$7C,2,$59,2,$37,2,$17,1,-7,1,-$23,1,-$3E,1,-$57,1,-$6F,1,$7B,1,$65,1,$51,1,$3E,1,$2C,1,$1C,1,$C,0,-3,0,-$12,0,-$1F,0,-$2C,0,-$38,0,-$43,0,-$4D,0,-$57,0,-$61 
  DC.B      0,-$6A,0,-$72,0,-$7A,0,$7E,0,$77,0,0,3,$7E,3,$4C,3,$1C,2,-$10,2,-$3B,2,-$62,2,$78,2,$55,2,$33,2,$14,1,-$A,1,-$26,1,-$41,1,-$5A,1,-$72,1,$78,1,$63,1,$4F,1,$3C,1,$2A 
  DC.B      1,$1A,1,$A,0,-5,0,-$13,0,-$21,0,-$2D,0,-$39,0,-$44,0,-$4F,0,-$59,0,-$62,0,-$6B,0,-$73,0,-$7B,0,$7D,0,$76,0,0,3,$77,3,$46,3,$17,2,-$16,2,-$40,2,-$67,2,$74,2,$50,2,$2F 
  DC.B      2,$10,1,-$E,1,-$2A,1,-$44,1,-$5D,1,-$75,1,$75,1,$60,1,$4C,1,$3A,1,$28,1,$18,1,8,0,-7,0,-$15,0,-$22,0,-$2F,0,-$3A,0,-$45,0,-$50,0,-$5A,0,-$63,0,-$6C,0,-$74,0,-$7C,0,$7D 
  DC.B      0,$76,0,0,3,$71,3,$40,3,$11,2,-$1B,2,-$45,2,-$6C,2,$6F,2,$4C,2,$2B,2,$C,1,-$12,1,-$2D,1,-$47,1,-$60,1,-$78,1,$72,1,$5E,1,$4A,1,$38,1,$26,1,$16,1,6,0,-9,0,-$17
  DC.B      0,-$24,0,-$30,0,-$3C,0,-$47,0,-$51,0,-$5B,0,-$64,0,-$6D,0,-$75,0,-$7D,0,$7B,0,$75,0,0,3,$6B,3,$3A,3,$B,2,-$20,2,-$4A,2,-$71,2,$6B,2,$48,2,$27,2,8,1,-$15,1,-$31,1,-$4B
  DC.B      1,-$63,1,-$7A,1,$70,1,$5B,1,$48,1,$35,1,$24,1,$14,1,4,0,-$B,0,-$18,0,-$25,0,-$32,0,-$3D,0,-$48,0,-$52,0,-$5C,0,-$65,0,-$6E,0,-$76,0,-$7E,0,$7B,0,$74,0,0,3,$64,3,$34
  DC.B      3,6,2,-$26,2,-$4F,2,-$75,2,$66,2,$44,2,$23,2,4,1,-$19,1,-$34,1,-$4E,1,-$66,1,-$7D,1,$6D,1,$59,1,$45,1,$33,1,$22,1,$12,1,2,0,-$C,0,-$1A,0,-$27,0,-$33,0,-$3F,0,-$49
  DC.B      0,-$54,0,-$5D,0,-$66,0,-$6F,0,-$77,0,-$7F,0,$7A,0,$73,0,0,3,$5E,3,$2E,3,0,2,-$2B,2,-$54,2,-$7A,2,$62,2,$3F,2,$1F,2,1,1,-$1C,1,-$37,1,-$51,1,-$69,1,-$80,1,$6B,1,$56 
  DC.B      1,$43,1,$31,1,$20,1,$10,1,0,0,-$E,0,-$1C,0,-$28,0,-$35,0,-$40,0,-$4B,0,-$55,0,-$5F,0,-$68,0,-$70,0,-$78,0,-$80,0,$79,0,$72,0,0
PT_AUDCHAN1TEMP:
  DC.B      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 
PT_AUDCHAN2TEMP:
  DC.B      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 
PT_AUDCHAN3TEMP:
  DC.B      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 
PT_AUDCHAN4TEMP:
  DC.B      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 
PT_SAMPLESTARTS:
  DC.B      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 
  DC.B      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 
  DC.B      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 
PT_COUNTER:
  DC.B      0,0,0,0 
PT_CURRSPEED:
  DC.B      0,0 
L00AA:
  DC.B      0,6 
PT_PATTPOS:
  DC.B      0,0 
PT_DMACONTEMP:
  DC.B      0,0 
PT_ACTIVECHANNEL:
  DC.B      0,$F
PT_PATTERNPTR:
  DC.B      0,0,0,0 
PT_PATTERNPOSITI:
  DC.B      0,0,0,0 
PT_SONGPOSITION:
  DC.B      0,0,0,0 
PT_SONGDATAPTR:
  DC.B      0,0,0,0 
PT_METROSPEED:
  DC.B      0 
PT_METROCHANNEL:
  DC.B      0 
PT_SPEED:
  DC.B      6 
PT_SONGPOS:
  DC.B      0 
PT_PBREAKPOSITIO:
  DC.B      0 
PT_POSJUMPASSERT:
  DC.B      0 
PT_PBREAKFLAG:
  DC.B      0 
PT_LOWMASK:
  DC.B      0 
PT_PATTDELAYTIME:
  DC.B      0 
L00BB:
  DC.B      0 
REALTEMPO:
  DC.B      0,$7D 
MYCIA_LIST:
  DC.B      0,0,-$20,$2A,-$10,$15,-$60,$E,$78,$A,$60,8,$50,7,$44,-$68,$3C,5,$35,$5A,$30,4,$2B,-$5A,$28,3,$24,-$11,$22,$4C,$20,2,$1E,2,$1C,$3E,$1A,-$53,$19,$45,$18,2,$16,-$23,$15,-$2D,$14,-$20,$14,1,$13,$34 
  DC.B      $12,$77,$11,-$38,$11,$26,$10,-$72,$10,1,$F,$7D,$F,1,$E,-$74,$E,$1F,$D,-$48,$D,$56,$C,-6,$C,-$5E,$C,$4F,$C,1,$B,-$4A,$B,$6E,$B,$2A,$A,-$17,$A,-$55,$A,$70,$A,$37,$A,0,9,-$34,9,-$66,9,$6A
  DC.B      9,$3B,9,$F,8,-$1C,8,-$46,8,-$6D,8,$6C,8,$47,8,$23,8,0,7,-$21,7,-$42,7,-$61,7,-$80,7,$63,7,$46,7,$2A,7,$F,6,-$B,6,-$24,6,-$3D,6,-$55,6,-$6D,6,$7D,6,$66,6,$51,6,$3C
  DC.B      6,$27,6,$13,6,0,5,-$13,5,-$25,5,-$38,5,-$49,5,-$5A,5,-$6B,5,-$7C,5,$74,5,$65,5,$55,5,$46,5,$38,5,$29,5,$1B,5,$D,5,0,4,-$D,4,-$1A,4,-$27,4,-$33,4,-$3F,4,-$4B,4,-$57 
  DC.B      4,-$63,4,-$6E,4,-$79,4,$7C,4,$72,4,$67,4,$5D,4,$53,4,$49,4,$3F,4,$36,4,$2C,4,$23,4,$1A,4,$11,4,8,4,0,3,-9,3,-$11,3,-$19,3,-$21,3,-$29,3,-$31,3,-$39,3,-$40,3,-$48 
  DC.B      3,-$4F,3,-$56,3,-$5D,3,-$64,3,-$6B,3,-$72,3,-$79,3,-$7F,3,$7A,3,$74,3,$6E,3,$67,3,$61,3,$5B,3,$55,3,$4F,3,$49,3,$44,3,$3E,3,$38,3,$33,3,$2E,3,$28,3,$23,3,$1E,3,$19 
  DC.B      3,$13,3,$E,3,9,3,5,3,0,2,-5,2,-$A,2,-$E,2,-$13,2,-$18,2,-$1C,2,-$20,2,-$25,2,-$29,2,-$2D,2,-$32,2,-$36,2,-$3A,2,-$3E,2,-$42,2,-$46,2,-$4A,2,-$4E,2,-$52,2,-$56,2,-$59 
  DC.B      2,-$5D,2,-$61,2,-$64,2,-$68,2,-$6C,2,-$6F,2,-$73,2,-$76,2,-$7A,2,-$7D,2,-$80,2,$7C,2,$79,2,$76,2,$73,2,$6F,2,$6C,2,$69,2,$66,2,$63,2,$60,2,$5D,2,$5A,2,$57,2,$54,2,$51
  DC.B      2,$4E,2,$4C,2,$49,2,$46,2,$43,2,$41,2,$3E,2,$3B,2,$39,2,$36,2,$33,2,$31,2,$2E,2,$2C,2,$29,2,$27,2,$24,2,$22,2,$1F,2,$1D,2,$1B,2,$18,2,$16,2,$14,2,$11,2,$F
  DC.B      2,$D,2,$B,2,8,2,6,2,4,2,2,2,0,1,-2,1,-5,1,-7,1,-9,1,-$B,1,-$D,1,-$F,1,-$11,1,-$13,1,-$15,1,-$17,1,-$19,1,-$1B,1,-$1D,1,-$1E 
TRACK_BIT_TEST:
  DC.B      0,0 
TRACK_SAVE_INTER:
  DC.B      0,0,0,0,0,0,0,0,0,0 
MASTER_VOLUME:
  DC.B      -$16,$60
SAMPLE_VOLUME:
  DC.B		-$16,$60
  DC.B		0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 
DSP_ROUTINE:
  DC.B      $C,0,$40,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8,-$21,-$11,0
  DC.B      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 
  DC.B      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 
  DC.B      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,-8,5,0,-$47,8,-$C,-$42,0,0,0,8,-$C,-$41,0 
  DC.B      $C,0,8,-$C,-$60,0,0,1,8,-$C,-$58,0,0,4,0,0,-$46,$65,-$C,0,0,0,0,$66,-$C,0,0,0,0,$67,-$C,0,0,0,0,5,-$C,$25,0,$F,-1,5,-$C,$26,0,$F,-1,5,-$C,$27,0,$F
  DC.B      -1,$20,0,$1B,$70,-$C,0,0,$10,0,6,-$28,$20,$5D,$5E,0,$60,-$C,0,0,$38,$1D,6,$40,-$60,$55,$58,0,$60,-$C,0,0,$10,$14,6,8,-$80,0,0,$66,6,-$18,-$5D,$5D,$58,0,0,0,0,$B,-$10,-$80
  DC.B      0,1,$3F,$A,-$58,$22,$44,-$C,0,$49,$4E,$49,$A,-$57,-$7F,0,0,$6C,8,-$3C,$2B,0,-$10,-$48,$44,-$C,0,$74,$72,$61,$A,-$57,-$80,0,0,$72,8,$4E,$2B,$20,0,$45,$E,$20,$72,$44,-$10,0,0,$38,$5E,$A 
  DC.B      -$57,-$7F,0,0,$79,8,-$3C,$2B,$22,-$12,0,$A,-$34,$20,0,0,$7C,$22,-$3C,0,$20,0,$44,$A,-$10,-$5D,0,0,-$7A,$45,-$C,0,0,$10,0,$20,0,$60,$20,0,$22,$56,$70,0,0,$38,$5E,$A,-$57,-$80,0,0 
  DC.B      -$77,8,$44,$2B,$44,$70,0,0,$38,$5F,$61,-$C,0,0,$10,$14,$60,-$C,0,0,$38,$1D,$76,-$10,0,0,$38,$5F,6,-$22,0,0,0,-$61,$60,$70,0,0,$38,$5D,$B,-$10,-$80,0,0,-$4C,$60,-$10,0,0,$38,$5D
  DC.B      $70,-$C,0,0,0,8,0,0,0,4,$48,$10,$60,-$C,0,0,$38,$1D,$61,-$C,0,0,0,-$1C,$76,-$10,0,0,$38,$5F,6,-$22,0,0,0,-$4F,$60,$70,0,0,$38,$5D,$B,-$1F,-$80,$60,-$10,0,0,$38,$5D,$70 
  DC.B      -$C,0,0,0,8,$61,-$C,0,0,0,-$E,4,$48,$10,$22,-$4A,0,$C,0,$6F,$A,-$57,-$7F,0,0,-$4C,$45,-$28,0,8,-$3B,$2B,$A,-$57,-$80,0,0,-$48,8,$45,$2B,$45,$58,0,$A,-$57,-$80,0,0,-$44,8,$45 
  DC.B      $2B,$45,$58,0,$A,-$57,-$80,0,0,-$40,8,$45,$2B,$45,$58,0,$44,-$10,0,0,$38,$5E,$20,0,-$58,$20,0,$3A,$A,-$57,-$80,0,0,-$38,8,$4E,$2B,$20,0,3,$A,-$10,-$56,0,0,-$2D,$20,0,$13,$56,$58,0 
  DC.B      $56,$58,0,$A,-$10,-$80,0,0,-$2B,$20,$58,0,$20,$58,0,$A,-$57,-$7F,0,0,-$2B,8,-$33,$2B,$A,-$57,-$80,0,0,-$28,8,$44,$2B,$44,$58,0,$61,$58,0,6,-$3C,0,0,0,-$1E,$A,-$57,-$80,0,0,-$21,8
  DC.B      $44,$2B,7,$59,-$7C,0,0,$C,$B,-$10,-$80,0,1,$22,$B,-$10,-$80,0,1,$B,6,-$28,0,0,0,-$11,$47,-$1E,0,$46,-$24,$28,$21,-$4E,-$50,$46,-$2C,0,$5C,$5D,-$50,$5C,$5D,0,$A,-$10,-$80,0,1,0,$B,-$10 
  DC.B      -$80,0,1,$22,$B,-$10,-$80,0,1,$B,6,-$28,0,0,0,-1,$47,-$1E,0,$5E,-$1B,0,$46,-$24,$28,$46,-$2C,-$4E,$5C,$5D,0,$5E,-$1B,0,$21,-$4E,-$4E,$5C,$5D,0,$51,$50,0,$22,$4D,0,$44,-$C,0,0,$38,$60
  DC.B      $20,0,$4C,$55,$63,0,$45,-$C,0,0,0,1,$20,0,$6E,$55,$60,0,0,0,$C,$22,$13,0,$20,$58,0,0,0,0,$22,$14,0,$20,$58,0,$20,$58,$13,$50,-$28,0,$20,0,$32,$21,-$7B,$1B,$21,4,0,$55
  DC.B      -$C,0,0,$38,$60,$47,-$28,0,$22,-$2B,$78,$51,-$20,0,$21,-$4E,0,$70,-$10,0,0,$38,$5E,$A,-$10,-$5E,0,1,$21,$70,-$C,0,0,0,1,0,0,$C,$70,-$C,0,0,0,6,$47,-$C,0,0,-$80,0,$71,-$18
  DC.B      0,$70,-$C,0,0,0,7,$62,-$C,0,0,$38,$60,$61,-$18,0,$62,-$C,0,0,$38,$60,$63,-$C,0,0,$38,$61,$72,-$C,0,0,0,2,$73,-$C,0,0,0,2,$45,-$C,0,0,0,-1,6,-$27,0,0,1,$3D
  DC.B      $4E,-$27,0,$20,0,-$50,$50,$4B,$66,$21,-$7C,0,$20,0,-$38,$51,$4A,0,0,0,$C,8,-$C,-$41,0,$C,0,8,-$C,-$41,0,$3C,0,8,-$C,-$54,0,$41,0,8,-$C,-$53,0,$58,0,8,-$C,-$5F,0,1,-8,8 
  DC.B      -$C,-$5D,0,0,0,0,-4,-$48,0,0,$C,0 
DFF096:
  DC.B      0,0 
DFF0A0:
  DC.B      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 
DFF0B0:
  DC.B      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 
DFF0C0:
  DC.B      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 
DFF0D0:
  DC.B      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 
DFF0E0:
  DC.B      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 
DFF0F0:
  DC.B      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 
TRACK_1_TAT:
  DC.B      $10,0,$10,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 
TRACK_2_TAT:
  DC.B      $70,0,$10,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 
TRACK_3_TAT:
  DC.B      $50,0,$10,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 
TRACK_4_TAT:
  DC.B      $30,0,$10,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 
TRACK_5_TAT:
  DC.B      $10,0,$10,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 
TRACK_6_TAT:
  DC.B      $70,0,$10,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 

;	SECTION BSS
	BSS

DUMMY_BUFFER:
  DS.B      8000

	END
