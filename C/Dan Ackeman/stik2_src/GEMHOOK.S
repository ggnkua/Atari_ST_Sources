	export 	ST_GEMDOS
	export	TT_GEMDOS
	export	OLD_GEMDOS
	export  NET_TICK
	export  OLD_TICK
	export  TRP5SIM
    export  clock
    export  NEWSTACKBOTTOM
    export	pkt_mux
    
    import	net_demux        	

	;import  net_demux
	import  net_mux
	
	super
	
	
	data
	
NEWSTACKBOTTOM:	.DS.B 4096 	; new supervisorstack
NEWSTACKTOP: .DC.W	0		; top of new supervisor stack
IP_SEM:		.DC.W	0		;reentrance semaphore
OLD_STACK:	.DC.L	0		;old stack pointer

	text
	

			.DC.B   'XBRAINET'
			.EVEN
OLD_GEMDOS:	.DC.L	0		;old gemdos vector


ST_GEMDOS:	movea.l a7,a0 
			btst.b  #5,(a7) 
			bne		ST_SUPER	; call from supervisor mode
			move	usp,a0
			bra		ST_SWITCH
ST_SUPER:	addq.l	#6,a0

ST_SWITCH:	move.w	(a0),d0		; 612, 620-623, 630-635
			cmpi.w	#612,d0	
			;beq		ST_MYGEM
			cmpi.w	#620,d0
			bcs		ST_OLDGEM
			cmpi.w	#624,d0
			;bcs		ST_MYGEM

			cmpi.w	#630,d0
			bcs		ST_OLDGEM
			cmpi.w	#636,d0
			;bcs		ST_MYGEM

ST_OLDGEM:	movea.l OLD_GEMDOS,a0 
			jmp		(a0)			; let others do the work
			
			
ST_MYGEM:	tas		IP_SEM
			beq		ST_OK
			moveq.l	#-50,d0			; recursive call not allowed
			bra		ST_EXIT
			
ST_OK:		move.l	a7,OLD_STACK
			movea.l	#NEWSTACKTOP,a7
			movem.l d1-a6,-(a7) 
			subi.w  #612,d0 
			beq		ST_DOIT
			subq.w	#7,d0
			cmpi.w	#5,d0
			bcs		ST_DOIT
			subq.w	#6,d0
			
ST_DOIT:	asl.w   #2,d0 
			;lea     GEM_TAB,a1 
			movea.l 0(a1,d0),a1 
			addq.l	#2,a0			; pointer to parameter on stack
			jsr     (a1)
			movem.l (a7)+,d1-a6 
			movea.l	OLD_STACK,a7
			clr.w   IP_SEM			; clear semaphor
TRP5SIM:
ST_EXIT:	rte 

TT_GEMDOS:	movea.l a7,a0 
			btst.b  #5,(a7) 
			bne		TT_SUPER	; call from supervisor mode
			move	usp,a0
			bra		ST_SWITCH
TT_SUPER:	addq.l	#8,a0
			bra		ST_SWITCH

save:	dc.l 0
time:	dc.l 0

			.DC.L	'XBRAINET'
OLD_TICK:	.DC.L	0

NET_TICK:   
			tas		IP_SEM				; test semaphore
			bne		TICK_EXIT			; inet busy -> jump

            move	(a7),savesr
            move.l	2(a7),savepc
			move.l	#myrout,2(a7)

            move.l	d0,-(a7)
			move	savesr,d0
			and		#$f800,d0
			or		#$2000,d0
			move	d0,4(a7)
			move.l	(a7)+,d0
			
            ;sub.l	a0,a0
            ;move.l	$4ba,d0
            ;move.l	d0,save
			;jsr		net_demux
			;move.l	$4ba,d0
			;sub.l	save,d0
			;move.l	d0,time
			;movem.l	(a7)+,d0-a6
			;movea.l	OLD_STACK,a7		; switch back to old stack
			;clr.w	IP_SEM				; free semaphore

TICK_EXIT:
            move.l	OLD_TICK,-(a7)
			rts			                ; jump to old handler
			
myrout:		
            move.l	a7,OLD_STACK
			movea.l	#NEWSTACKTOP,a7		; install new stack
			movem.l	d0-a6,-(a7)			;
            
			sub.l	a0,a0
			;jsr		net_demux
			movem.l	(a7)+,d0-a6
			move.l	OLD_STACK,a7

			move.l	savepc,-(a7)
			move	savesr,-(a7)
			clr		IP_SEM
			rte
			;bra		TICK_EXIT
			
clock:      move.l $4ba,d0				; 
            rts

savepc:		dc.l 0
savesr:		dc.l 0

pkt_mux:	rts
			tas		IP_SEM
			bne		IP_RET
			
			move.l	a7,ipstack
			movea.l	#NEWSTACKTOP,a7
			clr.l	d0
			clr.l	a0
			;jsr		net_demux
			move.l	ipstack,a7
			clr		IP_SEM
IP_RET:
			rts

ipstack:	dc.l	0

