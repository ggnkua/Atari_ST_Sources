				export PlayTime
				import ModType

				text
				
;-------------- Calculate Playing Time ----------------------------------

PlayTime:		movem.l	d1-d7/a0-a6,-(sp)
				lea		20+31*30(a0),a2	;ModSongLen
				lea		2+128+4(a2),a3	;ModPatData
				bsr		ModType
				tst.w	d0
				bne.s	GetSongTime31	;31er
				moveq	#4,d0			;15er
				lea		20+15*30(a0),a2	;ModSongLen
				lea		2+128(a2),a3	;ModPatData

GetSongTime31:	move.w	d0,d1
				subq.w	#1,d0
				move.w	d0,Channels
				lsl.w	#8,d1			;*256
				move.w	d1,PatternSize

				move.l	a2,a0			;ModSongLen
				moveq	#0,d0			;SongPos
				moveq	#0,d7			;max SongPos
				moveq	#6,d1			;default Speed
				moveq	#0,d2			;time
				move.w	#20000,a2		;20000 us ( 50 Hz )

;---------------------------------------------------------------------

GetSongTime5:	moveq	#0,d3			;Start GetSongTime
GetSongTime4:	move.b	2(a0,d0.w),d3	;Pattern-Nr
				mulu.w	PatternSize,d3	;*1024 oder *2048
				move.l	a3,a1			;ModPatData
				add.l	d3,a1			;select Pattern
				moveq	#0,d3			;PatternPos

GetSongTime1:	move.l	a2,d4			;us
				mulu.l	d1,d4
				add.l	d4,d2			;add Time
				move.w	Channels,d4		;4 oder 8 Channels

GetSongTime2:	move.l	(a1,d3.w),d5	;Pattern-Long
				move.w	d5,d6			;fÅr Infos
				and.w	#$0f00,d5
				cmp.w	#$0b00,d5		;Position Jump ?
				beq.s	TimePosJump		;ja
				cmp.w	#$0d00,d5		;Pattern-Break ?
				beq.s	TimePattBreak	;ja
				cmp.w	#$0f00,d5		;Speed ?
				beq		TimeSpeed
GetSongTime3:	addq.w	#4,d3			;next Channel
				dbra	d4,GetSongTime2	;do 4/8 channles

				cmp.w	PatternSize,d3	;alle Pattern durch ?
				bne.s	GetSongTime1	;nein

NextSongPos:	cmp.w	d7,d0			;>= max SongPos ?
				bcs.s	TimeExit		;fÅr den Fall, das durch ein Position Jump
										;die letzte Pos nie erreicht wird
				move.w	d0,d7			;neues Max
				addq.w  #1,d0			;next SongPos
                cmp.b   (a0),d0			;letzte Pos erreicht ?
                blo.s   GetSongTime5	;nein

TimeExit:       divu.l	#1000000,d2		;d2 = Time in us
				divu	#60,d2			;in Sekunden
				move.w	d2,d0			;Minuten
				ext.l	d0
				divu	#10,d0
				move.l	d0,d1			;Rest
				swap	d1
				lsl.w	#4,d0
				or.w	d1,d0
				lsl.w	#8,d0
				swap	d2				;Sekunden
				ext.l	d2
				divu	#10,d2
				move.l	d2,d1			;Rest
				swap	d1
				lsl.w	#4,d2
				or.w	d1,d2
				or.w	d2,d0
				movem.l	(sp)+,d1-d7/a0-a6
				rts

TimePosJump:	and.w	#$ff,d6
				move.w	d6,d0			;neue SongPos
				bra		GetSongTime5

TimePattBreak:	addq.w  #1,d0			;next SongPos
                cmp.b   (a0),d0			;letzte Pos erreicht ?
                beq.s	TimeExit		;ja

				moveq	#0,d3
				move.b	2(a0,d0.w),d3	;Pattern-Nr
				mulu.w	PatternSize,d3	;*1024 / *2048
				move.l	a3,a1			;ModPatData
				add.l	d3,a1			;select Pattern
				and.w	#$ff,d6
				mulu.w	Channels,d6
				lsl.w	#2,d6			;*4*4 / *8*4
				move.w	d6,d3			;PatternPosition
				bra		GetSongTime4				


TimeSpeed:		and.l	#$ff,d6
				cmp.w	#$20,d6
				bcc.s	ExtSpeed
				move.w	d6,d1			;neues Speed
				bra		GetSongTime3
ExtSpeed:		move.l	#2500000,d5
				divu.l	d6,d5
				move.l	d5,a2	
				bra		GetSongTime3

				data
Channels:		dc.w	0
PatternSize:	dc.w	0

; BPM Calculation:
; die BPM-Werte stimmen nur wenn der Timer auf 6 gesetzt ist
; die extented Speed in s wird so berechnet:
; 60 / ( 4 * 6 * BPM ) = sekunden
; 2.5 / BPM            = sekunden
; 1 BPM = 4 Takte pro Minute
; 60 = sekunden ( 1 Minute = 60 Sekunden )
; 4 = 4 Takte
; 6 = Timer

