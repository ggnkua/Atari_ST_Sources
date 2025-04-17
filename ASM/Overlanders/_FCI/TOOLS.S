; Author: Herve 'Silver' Durand et Benoit 'Crystar' Durand
; Demo Group: Overlanders
; Organization: The Union
; Date (dd/mm/yyyy): 21/09/2016
;
; Set of tools
;

TOOLS_Super:
	; BkpUser is initialized to 0 so the first time I enter I switch to Super mode
	; The second time I enter, BkpUser is set and so I quit Super mode
	move.l	TOOLS_BkpUser,d0
	move.l	d0,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.w	#6,sp
	move.l	d0,TOOLS_BkpUser
	rts

TOOLS_Mouse_Hide:
	dc.w	$A00A				; Line A command to make mouse disappearing
	move.b	#$12,$fffffc02.w		; Mouse movement disabled
	rts

TOOLS_Mouse_Show:
	dc.w	$A009				; Line A command to make mouse appearing
	move.b	#$8,$FFFFFC02.w			; Mouse movement enable
	rts

TOOLS_Context_Backup:
	move.w	#$2700,sr
	move.l	usp,a0				; Backup USP so that we can use usp
	move.l	a0,TOOLS_BkpUSP
	move.w	SR,TOOLS_BkpSR
	move.l 	$10.w,TOOLS_BkpIllegal
	move.l 	$20.w,TOOLS_BkpPrivilege
	move.l 	$28.w,TOOLS_BkpLineA
	move.l 	$2C.w,TOOLS_BkpLineF
	move.l	$68.w,TOOLS_BkpHBL
	move.l	$70.w,TOOLS_BkpVBL
	move.l 	$80.w,TOOLS_BkpTrap0
	move.l	$110.w,TOOLS_BkpTimerD
	move.l	$114.w,TOOLS_BkpTimerC
	move.l	$118.w,TOOLS_BkpACIA
	move.l	$120.w,TOOLS_BkpTimerB
	move.l	$134.w,TOOLS_BkpTimerA
	move.l	$11C.w,TOOLS_BkpFDC
	move.l	#TOOLS_RTE_Interrupt,$70.w
	move.l	#TOOLS_RTE_Interrupt,$68.w
	move.l	#TOOLS_RTE_Interrupt,$134.w
	move.l	#TOOLS_RTE_Interrupt,$120.w
	move.l	#TOOLS_RTE_Interrupt,$114.w
	move.l	#TOOLS_RTE_Interrupt,$110.w
	move.l	#TOOLS_RTE_Interrupt,$118.w
	move.l	$FFFF8200.w,TOOLS_BkpScreenAddress
	move.b	$FFFF820A.w,TOOLS_Bkp820A
	move.b	$FFFF8260.w,TOOLS_Bkp8260
	move.w	$FFFFFA00.w,TOOLS_BkpFA00
	move.l	$FFFFFA06.w,TOOLS_BkpFA06
	move.b	$FFFFFA07.w,TOOLS_BkpFA07
	move.b	$FFFFFA09.w,TOOLS_BkpFA09
	move.b	$FFFFFA13.w,TOOLS_BkpFA13
	move.b	$FFFFFA15.w,TOOLS_BkpFA15
	move.b	$FFFFFA17.w,TOOLS_BkpFA17
	move.b	$FFFFFA19.w,TOOLS_BkpFA19
	move.b	$FFFFFA1B.w,TOOLS_BkpFA1B
	move.b	$FFFFFA1D.w,TOOLS_BkpFA1D
	move.b	$FFFFFA1F.w,TOOLS_BkpFA1F
	move.b	$FFFFFA21.w,TOOLS_BkpFA21
	move.b	$FFFFFA25.w,TOOLS_BkpFA25
	movem.l	$FFFF8240.w,d0-d7
	movem.l	d0-d7,TOOLS_BkpColors
	clr.b	$FFFFFA07.w
	clr.b	$FFFFFA13.w
	clr.b	$FFFFFA09.w
	clr.b	$FFFFFA15.w
	move.b  $484.w,TOOLS_BkpKeyMode
	move.l	$8.w,TOOLS_BkpBusError
	move.l	$C.w,TOOLS_BkpAddressError
	move.l	$14.w,TOOLS_BkpDivideBy0Error
	move.b 	#14,$ffff8800.w 		; PSG port A
	move.b 	$ffff8800.w,TOOLS_BkpPSGPortA
	move.w	#$2300,sr
	rts

TOOLS_Context_Restore:
	move.w	#$2700,sr			; Prevent all interruption
	clr.b	$FFFFFA19.w			; Stop Timer A
	clr.b	$FFFFFA1B.w			; Stop Timer B
	clr.b	$FFFFFA19.w			; Timer A Control: Stop
	clr.b	$FFFFFA1B.w			; Timer B Control: Stop
	move.l	TOOLS_BkpBusError,$8.w
	move.l	TOOLS_BkpAddressError,$C.w
	move.l	TOOLS_BkpDivideBy0Error,$14.w
	move.l 	TOOLS_BkpIllegal,$10.w
	move.l 	TOOLS_BkpPrivilege,$20.w
	move.l 	TOOLS_BkpLineA,$28.w
	move.l 	TOOLS_BkpLineF,$2C.w
	move.l	TOOLS_BkpUSP,a0			; Restore User Stack pointer
	move.l	a0,usp				; Used when we exit superuser mode
	move.w	TOOLS_BkpSR,SR
	move.l	TOOLS_BkpHBL,$68.w
	move.l	TOOLS_BkpVBL,$70.w
	move.l 	TOOLS_BkpTrap0,$80.w
	move.l	TOOLS_BkpTimerB,$120.w
	move.l	TOOLS_BkpTimerA,$134.w
	move.l	TOOLS_BkpTimerC,$114.w
	move.l	TOOLS_BkpTimerD,$110.w
	move.l	TOOLS_BkpACIA,$118.w
	move.l	TOOLS_BkpFDC,$11C.w
	move.b	TOOLS_BkpFA25,$FFFFFA25.w
	move.b	TOOLS_BkpFA21,$FFFFFA21.w
	move.b	TOOLS_BkpFA1F,$FFFFFA1F.w
	move.b	TOOLS_BkpFA1D,$FFFFFA1D.w
	move.b	TOOLS_BkpFA1B,$FFFFFA1B.w
	move.b	TOOLS_BkpFA19,$FFFFFA19.w
	move.b	TOOLS_BkpFA17,$FFFFFA17.w
	move.b	TOOLS_BkpFA15,$FFFFFA15.w
	move.b	TOOLS_BkpFA13,$FFFFFA13.w
	move.b	TOOLS_BkpFA09,$FFFFFA09.w
	move.b	TOOLS_BkpFA07,$FFFFFA07.w
	move.l	TOOLS_BkpFA06,$FFFFFA06.w
	move.w	TOOLS_BkpFA00,$FFFFFA00.w
	clr.b	$FFFFFA1B.w
	move.b	TOOLS_BkpKeyMode,$484.w
	move.l	TOOLS_BkpScreenAddress,$FFFF8200.w
	movem.l	TOOLS_BkpColors,d0-d7
	movem.l	d0-d7,$FFFF8240.w
	move.b	TOOLS_Bkp8260,$FFFF8260.w
	move.b	#0,$FFFF820A.w			; Recalibrate bit plans
	move.b 	#14,$ffff8800.w 		; PSG port A
	move.b 	TOOLS_BkpPSGPortA,$ffff8802.w
	move.w 	#$2300,sr
	stop	#$2300
	move.b	TOOLS_Bkp820A,$FFFF820A.w
	rts

TOOLS_DisplayText:
	movem.l	d0/a0,-(sp)			; Backup d0/a0 as d0/a0 are modified by Cconws
	move.l	12(sp),-(sp)			; Address of text to write
	move.w	#9,-(sp)			; GEMDOS function 9 = Cconws (Character Console Write String)
	trap	#1				; Call to GEMDOS
	addq.l	#6,sp
	movem.l	(sp)+,d0/a0
	move.l	(sp)+,(sp)
	rts

TOOLS_RTE_Interrupt:
	rte
