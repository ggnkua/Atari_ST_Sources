*	Created by TT-Digger v6.2
*	Mon May 21 13:40:04 2001

	globl wind_get,_aes
	text
module wind_get
	 move	 d1,-(a7)
	 movem	 d0-d1,Gem_pb+60
	 move.l	 #$68020500,d1
	 bsr	 _aes
	 move.l	 a2,d2
	 move	 (a7)+,d1
	 lea	 4(a7),a1
	 cmp	 #'XA',d1			; HR
	 bne	l2
	 moveq	#1,d1
	 bra.s	l1

l2:	 and	 #63,d1				; HR
	 move.b	 lx(pc,d1),d1
	 bra.s	 l1

l0:	 movea.l (a1)+,a2
	 move	 (a0)+,(a2)
l1:	 dbf	 d1,l0
	 movea.l d2,a2
	 rts

;	HR	zero value: intout[0] only
lx:	 dc.b	 0,0,0,0,4,4,4,4
	 dc.b	 1,1,1,4,4,0
	 dc.b	 2					; 14  WF_NEWDESK
	 dc.b	 1,1,4,1,1
	 dc.b	 1					; 20  WF_OWNER
	 dc.b	 0
	 dc.b	 0
	 dc.b	 0
	 dc.b	 4					; 24  WF_BEVENT
	 dc.b	 1					; 25  WF_BOTTOM
	 dc.b	 1					; 26  WF_ICONIFY
	 dc.b	 4					; 27  WF_UNICONIFY
	 dc.b	 0	
	 dc.b	 0
	 dc.b	 2					; 30  WF_TOOLBAR
	 dc.b	 4					; 31  WF_FTOOLBAR

	 dc.b	 4					; 32  WF_NTOOLBAR
	 dc.b	 0,0,0,0,0,0,0
	 dc.b	 0,0,0,0,0,0,0,0
	 dc.b	 0,0,0,0,0,0,0,0
	 dc.b	 0,0,0,0,0,0,0,0
endmod

	end
