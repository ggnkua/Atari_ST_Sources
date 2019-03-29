* ½ by  ðACEð  and  ðJEDIð  of   SECTOR ONE  *
*          Original fullscreen routine...          *

	dc.w $a00a
	movem.l img+2,d0-d7
	movem.l d0-d7,$ffff8240.w
	lea img+34,a0
	lea $e0000+160,a1
	move.l #(imgf-img-32)/4,d0
schlaboudou	move.l (a0)+,(a1)+
	subq.l #1,d0
	bne.s schlaboudou
	move #-1,-(sp)
	pea $e0000
	move.l (sp),-(sp)
	move #5,-(sp)
	trap #14
	lea 12(sp),sp
	SF $FFFFFA07.W
	SF $FFFFFA09.W
	MOVE.L #VBL,$70.W
	BRA.S *

VBL     MOVEM.L D0-A6,-(SP) 
        MOVE #$2700,SR
        LEA $FFFF820A.W,A0
        LEA $FFFF8260.W,A1
        LEA $FFFF8209.W,A2
        
        
        MOVEQ #16,D1
        
WAIT    MOVE.B (A2),D0
        BEQ.S WAIT 
        SUB.W D0,D1 
        LSL.W D1,D0
        MOVEQ #0,D0
        
        DCB.W 95,$4E71 
        
        REPT 197
        
	NOP 
        MOVE A1,(A1) 
        NOP 
        MOVE.B D0,(A1) 
        
        DCB.W 89,$4E71 
        
        MOVE.B D0,(A0) 
        MOVE A0,(A0) 
        
        DCB.W 13,$4E71
        
        MOVE A1,(A1) 
        NOP 
        MOVE.B D0,(A1) 
        
        DCB.W 11,$4E71
        
        ENDR
        
	NOP        
        MOVE A1,(A1) 
        NOP 
        MOVE.B D0,(A1) 
        
        DCB.W 89,$4E71 
        
        MOVE.B D0,(A0) 
        MOVE A0,(A0) 
        
        DCB.W 13,$4E71
        
        MOVE A1,(A1) 
        NOP 
        MOVE.B D0,(A1) 
        
        DCB.W 12,$4E71
                  
        MOVE A1,(A1) 
        NOP 
        MOVE.B D0,(A1) 
        
        DCB.W 89,$4E71
        
        MOVE.B D0,(A0) 
        MOVE A0,(A0) 
        
        DCB.W 13,$4E71
        
        MOVE A1,(A1) 
        NOP 
        MOVE.B D0,(A1) 
        
        DCB.W 9,$4E71
        
        MOVE.B D0,(A0) 
        MOVE A1,(A1) 
        
        DCB.W 2,$4E71
        
        MOVE.B D0,(A1) 
        MOVE A0,(A0) 
	
	DCB.W 87,$4E71 
        
        MOVE.B D0,(A0) 
        MOVE A0,(A0) 
        
        DCB.W 13,$4E71
        
        MOVE A1,(A1) 
        NOP 
        MOVE.B D0,(A1) 
        
        DCB.W 12,$4E71

	REPT 43

	MOVE A1,(A1) 
        NOP 
        MOVE.B D0,(A1) 
        
        DCB.W 89,$4E71
        
        MOVE.B D0,(A0) 
        MOVE A0,(A0) 
        
        DCB.W 13,$4E71
        
        MOVE A1,(A1) 
        NOP 
        MOVE.B D0,(A1) 
        
        DCB.W 12,$4E71
        
        ENDR
        
        MOVEM.L (SP)+,D0-A6 
        RTE 

img	incbin *.kid
imgf