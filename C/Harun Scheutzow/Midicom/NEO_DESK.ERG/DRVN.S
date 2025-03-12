HDVMED	EQU	$047E
HDVBPB	EQU	$0472
HDVRW		EQU	$0476

			.EXPORT install
install:		move.l	HDVMED,old_hdmed
				move.l	#neu_hdmed,HDVMED
				move.l	HDVBPB,old_hdBPB
				move.l	#neu_hdBPB,HDVBPB
				move.l	HDVRW,old_hdRW
				move.l	#neu_hdRW,HDVRW
				rts

				dc.l	"XBRAMCDN"
old_hdRW:	dc.l	0
neu_hdRW:	cmpi.w	#13,14(sp)
				bne.s		notme1
				move.l  6(sp),A0
				movem.l A1,-(SP)
				lea     ROOT,A1
				move.w  #9,D0
RCOPY:		move.l  (A1)+,(A0)+				
				move.l  (A1)+,(A0)+				
				move.l  (A1)+,(A0)+				
				move.l  (A1)+,(A0)+				
				move.l  (A1)+,(A0)+				
				move.l  (A1)+,(A0)+				
				move.l  (A1)+,(A0)+				
				move.l  (A1)+,(A0)+				
				move.l  (A1)+,(A0)+				
				move.l  (A1)+,(A0)+				
				move.l  (A1)+,(A0)+				
				move.l  (A1)+,(A0)+				
				move.l  (A1)+,(A0)+				
				move.l  (A1)+,(A0)+				
				dbmi    D0,RCOPY
				move.l  (SP)+,A1
				moveq		#0,D0
				bra.s    ret_RW
notme1:		move.l	old_hdRW,-(sp)
ret_RW:		rts		

				dc.l	"XBRAMCDN"
old_hdmed:	dc.l	0
neu_hdmed:	cmpi.w	#13,4(sp)
				bne.s		notme0
				moveq		#0,D0
				bra.s    ret_med
notme0:		move.l	old_hdmed,-(sp)
ret_med:		rts		
				
				
				dc.l	"XBRAMCDN"
old_hdBPB:	dc.l	0
neu_hdBPB:	cmpi.w	#13,4(sp)
				bne		notme
				move.l	#BPB,D0
				bra.s    bpbreturn
notme:		move.l	old_hdBPB,-(sp)
bpbreturn:	rts		

BPB:		DC.W 512,2,1024,5,5,12,1000,10000,0
ROOT:	DC.W 0,0,0,0,0,0,514,256,512,418,32760,16384,0,0,0,0
      DC.W 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
      DC.W 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
      DC.W 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
      DC.W 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
      DC.W 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
      DC.W 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
      DC.W 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
      DC.W 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
      DC.W 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
      DC.W 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
