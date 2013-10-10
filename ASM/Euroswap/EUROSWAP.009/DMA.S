	opt x+
Starttrack	equ 0
Startsect	equ 1
Nbtrack		equ 10
Nbsect		equ Nbtrack*10


Main:
	clr.l -(sp)
	move.w #$20,-(sp)
	trap #1
	addq.l #6,sp
	move.l d0,Stack
	move.w #1,$43e.w
	move.l $70.w,-(sp)
	move.l $11c.w,-(sp)
	move.b $fffffa09.w,-(sp)
	move.b $fffffa15.w,-(sp)
	move.b $fffffa17.w,-(sp)
	bclr #3,$fffffa17.w
	move.l #VBL,$70.w
	moveq #0,d0
	moveq #0,d1
	bsr Set_drive
	bsr Force_IT
	bsr Restore
	move.w #Starttrack,No_Track
	move.w #Startsect,Nb_Sect_read
	move.w #Nbsect,Nb_Sect_to_read
	move.l #Buffer,Adr_DMA
	bsr Lance
wait:
	tst.w Activity_Flag
	bne.s wait
	bsr Unselect_All
	move.b (sp)+,$fffffa17.w
	move.b (sp)+,$fffffa15.w
	move.b (sp)+,$fffffa09.w
	move.l (sp)+,$11c.w
	move.l (sp)+,$70.w
	clr.w $43e.w
	move.l Stack,-(sp)
	move.w #$20,-(sp)
	trap #1
	addq.l #6,sp
	clr.w -(sp)
	trap #1
	
VBL
	movem.l d0-a6,-(sp)
	nop
	movem.l (sp)+,d0-a6
	rte
Adr_DMA		dc.l 0
Step_In_Flag	dc.w 0
Nb_Sect_to_read	dc.w 0
Nb_Sect_read	dc.w 0
No_Track	dc.w 0
Activity_Flag	dc.w 0

Lance:
	st Activity_Flag
	bclr #7,$fffffa09.w
	move.l #It_FDC,$11c.w
	bset #7,$fffffa09.w
	bset #7,$fffffa15.w
	move #$90,$ffff8606.w
	move #$190,$ffff8606.w
	move #$90,$ffff8606.w
	move #$a,$ffff8604.w
	move.l Adr_DMA,d0
	bsr Set_DMA
	st Step_In_Flag
	move #$86,$ffff8606.w
	move No_Track,$ffff8604.w
	move #$80,$ffff8606.w
	nop
	nop
	move #$11,$ffff8604.w
	rts
It_FDC
	move.l d0,-(sp)
	move.w #0,$ffff8240.w
	move #$80,$ffff8606.w
	move $ffff8604.w,d0
	and #$18,d0
	beq.s No_Error
	move.l Adr_DMA,d0
	bsr Set_DMA
	move #$90,$ffff8606.w
	move #$a,$ffff8604.w
	bra.s StepIn_Cmd
No_Error:
	tst.b Step_In_Flag
	bne.s StepIn_Cmd
	subq.w #1,Nb_Sect_to_read
	beq.s Stop_All
	addq.w #1,Nb_Sect_read
	add.l #$200,Adr_DMA
StepIn_Cmd:
	sf Step_In_Flag
	cmp #$b,Nb_Sect_read
	beq.s Next_Track
	move #$84,$ffff8606.w
	move Nb_Sect_read,$ffff8604.w
	move #$80,$ffff8606.w
	nop
	nop
	move #$80,$ffff8604.w
	bra.s Out
Next_Track:
	move #1,Nb_Sect_read
	addq.w #1,No_Track
	move #$90,$ffff8606.w
	move #$a,$ffff8604.w
	move #$80,$ffff8606.w
	nop
	nop
	move #$53,$ffff8604.w
	st Step_In_Flag
Out:
	move.l (sp)+,d0
	move #$777,$ffff8240.w
	rte
Stop_All:
	bclr #7,$fffffa09.w
	bclr #7,$fffffa15.w
	sf Activity_Flag
	move.l (sp)+,d0
	move #$777,$ffff8240.w
	rte
Set_drive:
	addq.b #1,d0
	add.b d0,d0
	or.b d1,d0
	eor.b #7,d0
	move.b #14,$ffff8800.w
	move.b $ffff8800.w,d1
	and.b #$f8,d1
	or.b d0,d1
	move.b d1,$ffff8802.w
	rts
Unselect_All:
	move #$80,$ffff8606.w
.Motor
	move $ffff8604.w,d0
	and #$80,d0
	bne.s .Motor
	lea $ffff8800.w,a0
	move.b #14,(a0)
	move.b (a0),d7
	ori.b #$07,d7
	move.b d7,2(a0)
	rts
Set_DMA:
	move.b d0,$ffff860d.w
	lsr.l #8,d0
	move.b d0,$ffff860b.w
	lsr.l #8,d0
	move.b d0,$ffff8609.w
	rts
Force_IT:
	move #$80,$ffff8606.w
	nop
	nop
	move #$d0,$ffff8604.w
	moveq #40,d7
.wt
	dbf d7,.wt
	rts
Restore:
	move #$80,$ffff8606.w
	nop
	nop
	move #1,$ffff8604.w
	bsr Wait_FDC
	rts
Wait_FDC:
	move.l #$180,d5
.wt	dbf d5,.wt
	move.l #$40000,d5
.mfp	btst #5,$fffffa01.w
	beq .ok
	subq.l #1,d5
	bne.s .mfp
	bsr Error
.ok	rts
Error:
	bsr Force_IT
	rts
Cmd	ds.w 1
CurrentDMA	ds.b 1
highdma		ds.b 1
middma		ds.b 1
lowdma		ds.b 1
Stack		ds.l 1
	section bss
Buffer:
	ds.b 512*Nbsect
finbuf
	END
	
	 