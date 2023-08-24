; STabloid Sound ! Player !!!

                	PEA     0
                	MOVE.W  #32,-(SP)
                	TRAP    #1
                	ADDQ.L  #6,SP

		move.l	$114.w,old114
		move.b	$fffffa09.w,oldfa09
		move.b	$fffffa1d.w,oldfa1d
		move.b	$fffffa15.w,oldfa15
		move.b	$fffffa17.w,oldfa17

                	MOVEQ   #1,D0
                	BSR     player+4
	      
vbl		move.l	$466,d0
waitsync		cmp.l	$466,d0
		beq.s	waitsync
		move.w	#$000,$ffff8240.w
		BSR     	player
		move.w	#$777,$ffff8240.w
		CMPI.B  	#$39,$FFFFFC02.w
                	BNE.S   	vbl

                	MOVEQ   #-1,D0
                	BSR     player

	      	move	#$8800,a0
	      	move.l	#$08000000,(a0)
	      	move.l	#$09000000,(a0)
              	move.l 	#$0a000000,(a0)
	      	move.b	#7,$484.w

		move.l    old114,$114.w
		move.b    oldfa09,$fffffa09.w
		move.b    oldfa1d,$fffffa1d.w
		move.b    oldfa15,$fffffa15.w
		move.b    oldfa17,$fffffa17.w
;		move.b    #$b4,$fffffa23.w

                	MOVE.W  #32,-(SP)
                	TRAP    #1
                	ADDQ.L  #6,SP

                	CLR.L   -(SP)
                	TRAP    #1

		data

player:         	INCBIN 'STABLOID.SND'
                	EVEN
ssp:            	DS.L 1
old114:		dc.l	0
oldfa09:		dc.b	0
oldfa15:		dc.b	0
oldfa17:		dc.b	0
oldfa1d:		dc.b	0
                	END

