	xref	LSCR
TAB_AFF	dc	.COUL0-TAB_AFF,.COUL1-TAB_AFF,.COUL2-TAB_AFF,.COUL3-TAB_AFF,.COUL4-TAB_AFF,.COUL5-TAB_AFF,.COUL6-TAB_AFF,.COUL7-TAB_AFF,.COUL8-TAB_AFF,.COUL9-TAB_AFF,.COUL10-TAB_AFF,.COUL11-TAB_AFF,.COUL12-TAB_AFF,.COUL13-TAB_AFF,.COUL14-TAB_AFF,.COUL15-TAB_AFF
	cnop	0,16
.COUL0	clr.b	(a2)
	clr.b	2(a2)
	clr.b	4(a2)
	clr.b	6(a2)
	add	LSCR,a2
	dbra	d5,.COUL0	
	rts
	cnop	0,16
.COUL1	move.b	(a1)+,(a2)
	clr.b	2(a2)
	clr.b	4(a2)
	clr.b	6(a2)
	add	LSCR,a2
	dbra	d5,.COUL1	
	rts
	cnop	0,16
.COUL2	clr.b	(a2)
	move.b	(a1)+,2(a2)
	clr.b	4(a2)
	clr.b	6(a2)
	add	LSCR,a2
	dbra	d5,.COUL2
	rts
	cnop	0,16
.COUL3	move.b	(a1)+,d0
	move.b	d0,(a2)
	move.b	d0,2(a2)
	clr.b	4(a2)
	clr.b	6(a2)
	add	LSCR,a2
	dbra	d5,.COUL3
	rts
	cnop	0,16
.COUL4	clr.b	(a2)
	clr.b	2(a2)
	move.b	(a1)+,4(a2)
	clr.b	6(a2)
	add	LSCR,a2
	dbra	d5,.COUL4
	rts
	cnop	0,16
.COUL5	move.b	(a1)+,d0
	move.b	d0,(a2)
	clr.b	2(a2)
	move.b	d0,4(a2)
	clr.b	6(a2)
	add	LSCR,a2
	dbra	d5,.COUL5
	rts
	cnop	0,16
.COUL6	move.b	(a1)+,d0
	clr.b	(a2)
	move.b	d0,2(a2)
	move.b	d0,4(a2)
	clr.b	6(a2)
	add	LSCR,a2
	dbra	d5,.COUL6
	rts
	cnop	0,16
.COUL7	move.b	(a1)+,d0
	move.b	d0,(a2)
	move.b	d0,2(a2)
	move.b	d0,4(a2)
	clr.b	6(a2)
	add	LSCR,a2
	dbra	d5,.COUL7
	rts
	cnop	0,16
.COUL8	clr.b	(a2)
	clr.b	2(a2)
	clr.b	4(a2)
	move.b	(a1)+,6(a2)
	add	LSCR,a2
	dbra	d5,.COUL8	
	rts
	cnop	0,16
.COUL9	move.b	(a1)+,d0
	move.b	d0,(a2)
	clr.b	2(a2)
	clr.b	4(a2)
	move.b	d0,6(a2)
	add	LSCR,a2
	dbra	d5,.COUL9
	rts
	cnop	0,16
.COUL10	move.b	(a1)+,d0
	clr.b	(a2)
	move.b	d0,2(a2)
	clr.b	4(a2)
	move.b	d0,6(a2)
	add	LSCR,a2
	dbra	d5,.COUL10
	rts
	cnop	0,16
.COUL11	move.b	(a1)+,d0
	move.b	d0,(a2)
	move.b	d0,2(a2)
	clr.b	4(a2)
	move.b	d0,6(a2)
	add	LSCR,a2
	dbra	d5,.COUL11
	rts
	cnop	0,16
.COUL12	move.b	(a1)+,d0
	clr.b	(a2)
	clr.b	2(a2)
	move.b	d0,4(a2)
	move.b	d0,6(a2)
	add	LSCR,a2
	dbra	d5,.COUL12
	rts
	cnop	0,16
.COUL13	move.b	(a1)+,d0
	move.b	d0,(a2)
	clr.b	2(a2)
	move.b	d0,4(a2)
	move.b	d0,6(a2)
	add	LSCR,a2
	dbra	d5,.COUL13
	rts
	cnop	0,16
.COUL14	move.b	(a1)+,d0
	clr.b	(a2)
	move.b	d0,2(a2)
	move.b	d0,4(a2)
	move.b	d0,6(a2)
	add	LSCR,a2
	dbra	d5,.COUL14
	rts
	cnop	0,16
.COUL15	move.b	(a1)+,d0
	move.b	d0,(a2)
	move.b	d0,2(a2)
	move.b	d0,4(a2)
	move.b	d0,6(a2)
	add	LSCR,a2
	dbra	d5,.COUL15
	rts

TAB_AFF_INV	dc	.COUL0-TAB_AFF_INV,.COUL1-TAB_AFF_INV,.COUL2-TAB_AFF_INV,.COUL3-TAB_AFF_INV,.COUL4-TAB_AFF_INV,.COUL5-TAB_AFF_INV,.COUL6-TAB_AFF_INV,.COUL7-TAB_AFF_INV,.COUL8-TAB_AFF_INV,.COUL9-TAB_AFF_INV,.COUL10-TAB_AFF_INV,.COUL11-TAB_AFF_INV,.COUL12-TAB_AFF_INV,.COUL13-TAB_AFF_INV,.COUL14-TAB_AFF_INV,.COUL15-TAB_AFF_INV
.COUL0	move.b	#$ff,(a2)
	move.b	#$ff,2(a2)
	move.b	#$ff,4(a2)
	move.b	#$ff,6(a2)
	add	LSCR,a2
	dbra	d5,.COUL0	
	rts
.COUL1	move.b	(a1)+,(a2)
	not.b	(a2)
	move.b	#$ff,2(a2)
	move.b	#$ff,4(a2)
	move.b	#$ff,6(a2)
	add	LSCR,a2
	dbra	d5,.COUL1	
	rts
.COUL2	move.b	#$ff,(a2)
	move.b	(a1)+,2(a2)
	not.b	2(a2)
	move.b	#$ff,4(a2)
	move.b	#$ff,6(a2)
	add	LSCR,a2
	dbra	d5,.COUL2
	rts
.COUL3	move.b	(a1)+,d0
	not	d0
	move.b	d0,(a2)
	move.b	d0,2(a2)
	move.b	#$ff,4(a2)
	move.b	#$ff,6(a2)
	add	LSCR,a2
	dbra	d5,.COUL3
	rts
.COUL4	move.b	#$ff,(a2)
	move.b	#$ff,2(a2)
	move.b	(a1)+,4(a2)
	not.b	4(a2)
	move.b	#$ff,6(a2)
	add	LSCR,a2
	dbra	d5,.COUL4
	rts
.COUL5	move.b	(a1)+,d0
	not	d0
	move.b	d0,(a2)
	move.b	#$ff,2(a2)
	move.b	d0,4(a2)
	move.b	#$ff,6(a2)
	add	LSCR,a2
	dbra	d5,.COUL5
	rts
.COUL6	move.b	(a1)+,d0
	move.b	#$ff,(a2)
	move.b	d0,2(a2)
	move.b	d0,4(a2)
	move.b	#$ff,6(a2)
	add	LSCR,a2
	dbra	d5,.COUL6
	rts
.COUL7	move.b	(a1)+,d0
	not	d0
	move.b	d0,(a2)
	move.b	d0,2(a2)
	move.b	d0,4(a2)
	move.b	#$ff,6(a2)
	add	LSCR,a2
	dbra	d5,.COUL7
	rts
.COUL8	move.b	#$ff,(a2)
	move.b	#$ff,2(a2)
	move.b	#$ff,4(a2)
	move.b	(a1)+,6(a2)
	not.b	6(a2)
	add	LSCR,a2
	dbra	d5,.COUL8	
	rts
.COUL9	move.b	(a1)+,d0
	not	d0
	move.b	d0,(a2)
	move.b	#$ff,2(a2)
	move.b	#$ff,4(a2)
	move.b	d0,6(a2)
	add	LSCR,a2
	dbra	d5,.COUL9
	rts
.COUL10	move.b	(a1)+,d0
	not	d0
	move.b	#$ff,(a2)
	move.b	d0,2(a2)
	move.b	#$ff,4(a2)
	move.b	d0,6(a2)
	add	LSCR,a2
	dbra	d5,.COUL10
	rts
.COUL11	move.b	(a1)+,d0
	not	d0
	move.b	d0,(a2)
	move.b	d0,2(a2)
	move.b	#$ff,4(a2)
	move.b	d0,6(a2)
	add	LSCR,a2
	dbra	d5,.COUL11
	rts
.COUL12	move.b	(a1)+,d0
	not	d0
	move.b	#$ff,(a2)
	move.b	#$ff,2(a2)
	move.b	d0,4(a2)
	move.b	d0,6(a2)
	add	LSCR,a2
	dbra	d5,.COUL12
	rts
.COUL13	move.b	(a1)+,d0
	not	d0
	move.b	d0,(a2)
	move.b	#$ff,2(a2)
	move.b	d0,4(a2)
	move.b	d0,6(a2)
	add	LSCR,a2
	dbra	d5,.COUL13
	rts
.COUL14	move.b	(a1)+,d0
	not	d0
	move.b	#$ff,(a2)
	move.b	d0,2(a2)
	move.b	d0,4(a2)
	move.b	d0,6(a2)
	add	LSCR,a2
	dbra	d5,.COUL14
	rts
.COUL15	move.b	(a1)+,d0
	not	d0
	move.b	d0,(a2)
	move.b	d0,2(a2)
	move.b	d0,4(a2)
	move.b	d0,6(a2)
	add	LSCR,a2
	dbra	d5,.COUL15
	rts
