
;Pipe drawing using preshifts for scrolling

ENABLECOLLISION = 1							;Set to 1 to enable collision
ENABLEPIPESCROLL = 1						;Set to 1 to enable pipe scrolling
ENABLESCROLLCHECK = 0						;Set to 1 to enable scrolling check for all Y offsets

	SECTION	TEXT

;----------------------------------
;Initialise pipes
pipeinit
	move.w	#70,pipecheck					;Check scroll for pipe Y offsets of 70...0
	bra		pipereset						;(does RTS)
	
;----------------------------------
;Reset pipe positions for start of game
pipereset
	lea		pipes,a0
	move.w	#340,d2							;Starting position off-screen for first pipe
	
	moveq.w	#NUMPIPES-1,d3
.loop
	move.w	d2,PIPE_X(a0)
	bsr		piperandomoffset
	bsr		pipeset
	lea		PIPE_SIZE(a0),a0
	add.w	#PIPEXGAP,d2
	dbra.w	d3,.loop	
	rts

;----------------------------------
;Return d0.w as random gap Y offset (0...70 inclusive)
piperandomoffset
	bsr		utilrandword					;Random value in d0.w
	move.w	d0,d1
	and.w	#63,d0							;0...63
	lsr.w	#6,d1
	and.w	#7,d1							;0...7
	add.w	d1,d0							;Range is 0...70 inclusive
	rts

;----------------------------------
;Set pipe details, pass d0.w as gap Y offset (0...70 inclusive) and a0.l as pipe structure
pipeset
	IFGT ENABLESCROLLCHECK
	move.w	pipecheck,d0					;Read and decrement each Y offset to check scroller
	subq.w	#1,pipecheck
	bge.s	.checkok
	move.w	#0,pipecheck
.checkok
	ENDC

	lea		pipedetails,a1
	move.w	d0,d1							;Store Y line for end of top pipe (ie gap)
	add.w	#20,d1							;End of top pipe ranges 20...90
	move.w	d1,PIPE_Y(a0)
	add.w	d0,d0
	add.w	pipedetailstbl(pc,d0.w),a1		;*52
	move.w	(a1)+,PIPE_LINEOFFSET(a0)		;Copy pipe details for Y offset
	move.w	(a1)+,PIPE_CAPOFFSET(a0)
	move.w	(a1)+,PIPE_SKYOFFSET(a0)
	move.w	(a1)+,PIPE_SKY1OFFSET(a0)
	move.w	(a1)+,PIPE_SKY2OFFSET(a0)
	move.w	(a1)+,PIPE_SKY3OFFSET(a0)
	move.l	(a1)+,PIPE_FUNCTOP(a0)
	move.l	(a1)+,PIPE_FUNCTOP1(a0)
	move.l	(a1)+,PIPE_FUNCTOP2(a0)
	move.l	(a1)+,PIPE_FUNCTOP3(a0)
	move.l	(a1)+,PIPE_FUNCTOP4(a0)
	move.l	(a1)+,PIPE_FUNCBOTTOM(a0)
	move.l	(a1)+,PIPE_FUNCBOTTOM1(a0)
	move.l	(a1)+,PIPE_FUNCBOTTOM2(a0)
	move.l	(a1)+,PIPE_FUNCBOTTOM3(a0)
	move.l	(a1)+,PIPE_FUNCBOTTOM4(a0)
	rts

;----------------------------------

pipedetailstbl
	dc.w	52*0,52*1,52*2,52*3,52*4,52*5,52*6,52*7,52*8,52*9,52*10,52*11,52*12
	dc.w	52*13,52*14,52*15,52*16,52*17,52*18,52*19,52*20,52*21,52*22,52*23,52*24,52*25
	dc.w	52*26,52*27,52*28,52*29,52*30,52*31,52*32,52*33,52*34,52*35,52*36,52*37,52*38
	dc.w	52*39,52*40,52*41,52*42,52*43,52*44,52*45,52*46,52*47,52*48,52*49,52*50,52*51
	dc.w	52*52,52*53,52*54,52*55,52*56,52*57,52*58,52*59,52*60,52*61,52*62,52*63,52*64
	dc.w	52*65,52*66,52*67,52*68,52*69,52*70

;----------------------------------
;Scroll pipes and recycle back on screen
pipeupdate
	lea		pipes,a0

	moveq.w	#NUMPIPES-1,d2
.loop
	move.w	PIPE_X(a0),d0
	IFGT ENABLEPIPESCROLL
	subq.w	#1,d0							;Scroll pipe left a pixel
	ENDC
	cmp.w	#-48,d0							;Moved left off-screen?
	ble.s	.wrappipe						;Yes, wrap back on right hand side
	move.w	d0,PIPE_X(a0)
	cmp.w	#PIPEXSCORE,d0					;Have passed through pipe?
	bne.s	.continue
	move.l	a0,-(sp)						;Yes, increment score by 1 and play sound
	lea		bcdscore,a0
	bsr		gamescoreinc
	lea		pointsfx,a0
	bsr		soundplay1
	move.l	(sp)+,a0
.continue	
	lea		PIPE_SIZE(a0),a0
	dbra.w	d2,.loop
	rts

.wrappipe
	add.w	#NUMPIPES*PIPEXGAP,d0			;Move pipe to end
	move.w	d0,PIPE_X(a0)	
	bsr		piperandomoffset				;Random new pipe Y position
	bsr		pipeset
	bra.s	.continue
	
;----------------------------------
;Check if bird collides with any pipe, returns d0.w as 1 if hit pipe or 2 if hit floor (on first collision), otherwise 0
pipecheckcollision
	move.w	birdx,d0						;Read bird position
	move.w	birdy,d1
	cmp.w	#160-13,d1						;Always check floor collision
	bge.s	.hitfloor

	IFGT ENABLECOLLISION
	move.w	birdhit,d2						;Is player alive?
	bne.s	.done							;No, skip collision checks

	lea		pipes,a0

	moveq.w	#NUMPIPES-1,d3
.loop
	;Check if bird collision box is outside pipe on X axis
	move.w	PIPE_X(a0),d2					;Screen X of left edge of pipe
	sub.w	#20,d2							;Offset for right of bird collision box
	cmp.w	d0,d2
	bge.s	.nocollision
	add.w	#35,d2							;Offset for left of bird collision box
	cmp.w	d0,d2
	ble.s	.nocollision
	
	;Check if bird collision box is within pipe on Y
	move.w	PIPE_Y(a0),d2					;Screen Y of last line on top pipe
	sub.w	#4,d2							;Offset for top of bird collision box
	cmp.w	d1,d2
	bge.s	.hitpipe
.notopcol
	add.w	#40,d2							;Bottom of collision box
	cmp.w	d1,d2
	ble.s	.hitpipe
.nobottomcol

.nocollision
	lea		PIPE_SIZE(a0),a0	
	dbra.w	d3,.loop
.done
	ENDC
	moveq.w	#0,d0							;Return no collision
	rts

.hitfloor
	move.w	#160-13,birdy					;Put on floor
	moveq.w	#2,d0							;Return floor collision
	move.w	d0,birdhit						;Set as collision
	rts
.hitpipe
	moveq.w	#1,d0							;Return pipe collision
	move.w	d0,birdhit
	rts

;----------------------------------
;Draw all pipes to screen
pipedrawall
	lea		pipes,a0

	moveq.w	#NUMPIPES-1,d0
.loop
	move.w	d0,-(sp)
	move.l	a0,-(sp)
	bsr		pipedraw
	move.l	(sp)+,a0
	move.w	(sp)+,d0
	lea		PIPE_SIZE(a0),a0
	dbra.w	d0,.loop	
	rts
	
;----------------------------------
;Draw pipe, pass a0.l as pipe structure
pipedraw
	move.w	PIPE_X(a0),d0
	cmp.w	#-32,d0							;Culled left?
	ble.s	.offscreen
	cmp.w	#-16,d0							;Clipped left?
	blt		pipedrawtopclip1
	cmp.w	#0,d0
	blt		pipedrawtopclip2
	cmp.w	#320,d0							;Culled right?
	bge.s	.offscreen
	cmp.w	#304,d0							;Clipped right?
	bge		pipedrawtopclip4
	cmp.w	#288,d0
	bge		pipedrawtopclip3
	bra		pipedrawtop						;Fully on-screen
.offscreen
	rts

;----------------------------------
;Draw top pipe, with cap
pipedrawtop							;1712-5912 cycles, 3-12 rasters
	move.l	offscreenbse,a1			;20
	move.w	PIPE_X(a0),d0			;12

	move.w	d0,d1					;4		;Add X screen offset
	lsr.w	#1,d1					;8
	and.w	#$fff8,d1				;8
	add.w	d1,a1					;8
	sub.w	PIPE_LINEOFFSET(a0),a1	;16		;Offset Y

	lea		pipetopscrolltbl,a6		;12		;Look up preshift to X position
	and.w	#15,d0					;8
	lsl.w	#2,d0					;12
	move.l	(a6,d0.w),a2			;20
	movem.l	(a2)+,d0-d5				;60		;Read Planes 1+2+3+4 for pipe column

	move.l	PIPE_FUNCTOP(a0),a6		;16
	jmp		(a6)					;8

a0	movem.l	d0-d5,160*10(a1)		;60		;Draw pipe column, up to 4680 cycles
a1	movem.l	d0-d5,160*11(a1)
a2	movem.l	d0-d5,160*12(a1)
a3	movem.l	d0-d5,160*13(a1)
a4	movem.l	d0-d5,160*14(a1)
a5	movem.l	d0-d5,160*15(a1)
a6	movem.l	d0-d5,160*16(a1)
a7	movem.l	d0-d5,160*17(a1)
a8	movem.l	d0-d5,160*18(a1)
a9	movem.l	d0-d5,160*19(a1)
a10	movem.l	d0-d5,160*20(a1)
a11	movem.l	d0-d5,160*21(a1)
a12	movem.l	d0-d5,160*22(a1)
a13	movem.l	d0-d5,160*23(a1)
a14	movem.l	d0-d5,160*24(a1)
a15	movem.l	d0-d5,160*25(a1)
a16	movem.l	d0-d5,160*26(a1)
a17	movem.l	d0-d5,160*27(a1)
a18	movem.l	d0-d5,160*28(a1)
a19	movem.l	d0-d5,160*29(a1)
a20	movem.l	d0-d5,160*30(a1)
a21	movem.l	d0-d5,160*31(a1)
a22	movem.l	d0-d5,160*32(a1)
a23	movem.l	d0-d5,160*33(a1)
a24	movem.l	d0-d5,160*34(a1)
a25	movem.l	d0-d5,160*35(a1)
a26	movem.l	d0-d5,160*36(a1)
a27	movem.l	d0-d5,160*37(a1)
a28	movem.l	d0-d5,160*38(a1)
a29	movem.l	d0-d5,160*39(a1)
a30	movem.l	d0-d5,160*40(a1)
a31	movem.l	d0-d5,160*41(a1)
a32	movem.l	d0-d5,160*42(a1)
a33	movem.l	d0-d5,160*43(a1)
a34	movem.l	d0-d5,160*44(a1)
a35	movem.l	d0-d5,160*45(a1)
a36	movem.l	d0-d5,160*46(a1)
a37	movem.l	d0-d5,160*47(a1)
a38	movem.l	d0-d5,160*48(a1)
a39	movem.l	d0-d5,160*49(a1)
a40	movem.l	d0-d5,160*50(a1)
a41	movem.l	d0-d5,160*51(a1)
a42	movem.l	d0-d5,160*52(a1)
a43	movem.l	d0-d5,160*53(a1)
a44	movem.l	d0-d5,160*54(a1)
a45	movem.l	d0-d5,160*55(a1)
a46	movem.l	d0-d5,160*56(a1)
a47	movem.l	d0-d5,160*57(a1)
a48	movem.l	d0-d5,160*58(a1)
a49	movem.l	d0-d5,160*59(a1)
a50	movem.l	d0-d5,160*60(a1)
a51	movem.l	d0-d5,160*61(a1)
a52	movem.l	d0-d5,160*62(a1)
a53	movem.l	d0-d5,160*63(a1)
a54	movem.l	d0-d5,160*64(a1)
a55	movem.l	d0-d5,160*65(a1)
a56	movem.l	d0-d5,160*66(a1)
a57	movem.l	d0-d5,160*67(a1)
a58	movem.l	d0-d5,160*68(a1)
a59	movem.l	d0-d5,160*69(a1)
a60	movem.l	d0-d5,160*70(a1)
a61	movem.l	d0-d5,160*71(a1)
a62	movem.l	d0-d5,160*72(a1)
a63	movem.l	d0-d5,160*73(a1)
a64	movem.l	d0-d5,160*74(a1)
a65	movem.l	d0-d5,160*75(a1)
a66	movem.l	d0-d5,160*76(a1)
a67	movem.l	d0-d5,160*77(a1)
a68	movem.l	d0-d5,160*78(a1)
a69	movem.l	d0-d5,160*79(a1)
a70	movem.l	d0-d5,160*80(a1)
	movem.l	d0-d5,160*81(a1)
	movem.l	d0-d5,160*82(a1)
	movem.l	d0-d5,160*83(a1)
	movem.l	d0-d5,160*84(a1)
	movem.l	d0-d5,160*85(a1)
	movem.l	d0-d5,160*86(a1)
	movem.l	d0-d5,160*87(a1)

	movem.l	(a2)+,d0-d5				;60		;Draw pipe cap, 1020 cycles
	movem.l	d0-d5,160*88(a1)		;60
	movem.l	(a2)+,d0-d5
	movem.l	d0-d5,160*89(a1)
	movem.l	(a2)+,d0-d5
	movem.l	d0-d5,160*90(a1)
	movem.l	d0-d5,160*91(a1)
	movem.l	d0-d5,160*92(a1)
	movem.l	d0-d5,160*93(a1)
	movem.l	d0-d5,160*94(a1)
	movem.l	d0-d5,160*95(a1)
	movem.l	d0-d5,160*96(a1)
	movem.l	d0-d5,160*97(a1)
	movem.l	(a2)+,d0-d5
	movem.l	d0-d5,160*98(a1)
	movem.l	(a2),d0-d5
	movem.l	d0-d5,160*99(a1)
	bra		pipedrawbottom
	
;----------------------------------
;Draw top pipe, with cap, clipped for X of -32...-16
pipedrawtopclip1					;900-2860 cycles, 2-6 rasters
	move.l	offscreenbse,a1			;20
	move.w	PIPE_X(a0),d0			;12

	sub.w	PIPE_LINEOFFSET(a0),a1	;16		;Offset Y

	lea		pipetopscrolltbl,a6		;12		;Look up preshift to X position
	and.w	#15,d0					;8
	lsl.w	#2,d0					;12
	move.l	(a6,d0.w),a2			;16
	moveq.w	#16,d6					;4		;Offset for source
	add.w	d6,a2					;8
	movem.l	(a2)+,d4-d5				;28		;Read Planes 1+2+3+4 for pipe column

	move.l	PIPE_FUNCTOP1(a0),a6	;16
	jmp		(a6)					;8

b0	movem.l	d4-d5,160*10(a1)		;28		;Draw pipe column, 2184 cycles
b1	movem.l	d4-d5,160*11(a1)
b2	movem.l	d4-d5,160*12(a1)
b3	movem.l	d4-d5,160*13(a1)
b4	movem.l	d4-d5,160*14(a1)
b5	movem.l	d4-d5,160*15(a1)
b6	movem.l	d4-d5,160*16(a1)
b7	movem.l	d4-d5,160*17(a1)
b8	movem.l	d4-d5,160*18(a1)
b9	movem.l	d4-d5,160*19(a1)
b10	movem.l	d4-d5,160*20(a1)
b11	movem.l	d4-d5,160*21(a1)
b12	movem.l	d4-d5,160*22(a1)
b13	movem.l	d4-d5,160*23(a1)
b14	movem.l	d4-d5,160*24(a1)
b15	movem.l	d4-d5,160*25(a1)
b16	movem.l	d4-d5,160*26(a1)
b17	movem.l	d4-d5,160*27(a1)
b18	movem.l	d4-d5,160*28(a1)
b19	movem.l	d4-d5,160*29(a1)
b20	movem.l	d4-d5,160*30(a1)
b21	movem.l	d4-d5,160*31(a1)
b22	movem.l	d4-d5,160*32(a1)
b23	movem.l	d4-d5,160*33(a1)
b24	movem.l	d4-d5,160*34(a1)
b25	movem.l	d4-d5,160*35(a1)
b26	movem.l	d4-d5,160*36(a1)
b27	movem.l	d4-d5,160*37(a1)
b28	movem.l	d4-d5,160*38(a1)
b29	movem.l	d4-d5,160*39(a1)
b30	movem.l	d4-d5,160*40(a1)
b31	movem.l	d4-d5,160*41(a1)
b32	movem.l	d4-d5,160*42(a1)
b33	movem.l	d4-d5,160*43(a1)
b34	movem.l	d4-d5,160*44(a1)
b35	movem.l	d4-d5,160*45(a1)
b36	movem.l	d4-d5,160*46(a1)
b37	movem.l	d4-d5,160*47(a1)
b38	movem.l	d4-d5,160*48(a1)
b39	movem.l	d4-d5,160*49(a1)
b40	movem.l	d4-d5,160*50(a1)
b41	movem.l	d4-d5,160*51(a1)
b42	movem.l	d4-d5,160*52(a1)
b43	movem.l	d4-d5,160*53(a1)
b44	movem.l	d4-d5,160*54(a1)
b45	movem.l	d4-d5,160*55(a1)
b46	movem.l	d4-d5,160*56(a1)
b47	movem.l	d4-d5,160*57(a1)
b48	movem.l	d4-d5,160*58(a1)
b49	movem.l	d4-d5,160*59(a1)
b50	movem.l	d4-d5,160*60(a1)
b51	movem.l	d4-d5,160*61(a1)
b52	movem.l	d4-d5,160*62(a1)
b53	movem.l	d4-d5,160*63(a1)
b54	movem.l	d4-d5,160*64(a1)
b55	movem.l	d4-d5,160*65(a1)
b56	movem.l	d4-d5,160*66(a1)
b57	movem.l	d4-d5,160*67(a1)
b58	movem.l	d4-d5,160*68(a1)
b59	movem.l	d4-d5,160*69(a1)
b60	movem.l	d4-d5,160*70(a1)
b61	movem.l	d4-d5,160*71(a1)
b62	movem.l	d4-d5,160*72(a1)
b63	movem.l	d4-d5,160*73(a1)
b64	movem.l	d4-d5,160*74(a1)
b65	movem.l	d4-d5,160*75(a1)
b66	movem.l	d4-d5,160*76(a1)
b67	movem.l	d4-d5,160*77(a1)
b68	movem.l	d4-d5,160*78(a1)
b69	movem.l	d4-d5,160*79(a1)
b70	movem.l	d4-d5,160*80(a1)
	movem.l	d4-d5,160*81(a1)
	movem.l	d4-d5,160*82(a1)
	movem.l	d4-d5,160*83(a1)
	movem.l	d4-d5,160*84(a1)
	movem.l	d4-d5,160*85(a1)
	movem.l	d4-d5,160*86(a1)
	movem.l	d4-d5,160*87(a1)

	add.w	d6,a2					;8		;Draw pipe cap, 516 cycles
	movem.l	(a2)+,d4-d5				;28
	movem.l	d4-d5,160*88(a1)		;28
	add.w	d6,a2
	movem.l	(a2)+,d4-d5
	movem.l	d4-d5,160*89(a1)
	add.w	d6,a2
	movem.l	(a2)+,d4-d5
	movem.l	d4-d5,160*90(a1)
	movem.l	d4-d5,160*91(a1)
	movem.l	d4-d5,160*92(a1)
	movem.l	d4-d5,160*93(a1)
	movem.l	d4-d5,160*94(a1)
	movem.l	d4-d5,160*95(a1)
	movem.l	d4-d5,160*96(a1)
	movem.l	d4-d5,160*97(a1)
	add.w	d6,a2
	movem.l	(a2)+,d4-d5
	movem.l	d4-d5,160*98(a1)
	add.w	d6,a2
	movem.l	(a2),d4-d5
	movem.l	d4-d5,160*99(a1)
	bra		pipedrawbottomclip1
	
;----------------------------------
;Draw top pipe, with cap, clipped for X of -16...0
pipedrawtopclip2					;1316-4396 cycles, 3-9 rasters
	move.l	offscreenbse,a1			;20
	move.w	PIPE_X(a0),d0			;12

	sub.w	PIPE_LINEOFFSET(a0),a1	;16		;Offset Y

	lea		pipetopscrolltbl,a6		;12		;Look up preshift to X position
	and.w	#15,d0					;8
	lsl.w	#2,d0					;12
	move.l	(a6,d0.w),a2			;16
	moveq.w	#8,d6					;4		;Offset for source
	add.w	d6,a2					;8
	movem.l	(a2)+,d2-d5				;44		;Read Planes 1+2+3+4 for pipe column

	move.l	PIPE_FUNCTOP2(a0),a6	;16
	jmp		(a6)					;8

c0	movem.l	d2-d5,160*10(a1)		;44		;Draw pipe column, 3432 cycles
c1	movem.l	d2-d5,160*11(a1)
c2	movem.l	d2-d5,160*12(a1)
c3	movem.l	d2-d5,160*13(a1)
c4	movem.l	d2-d5,160*14(a1)
c5	movem.l	d2-d5,160*15(a1)
c6	movem.l	d2-d5,160*16(a1)
c7	movem.l	d2-d5,160*17(a1)
c8	movem.l	d2-d5,160*18(a1)
c9	movem.l	d2-d5,160*19(a1)
c10	movem.l	d2-d5,160*20(a1)
c11	movem.l	d2-d5,160*21(a1)
c12	movem.l	d2-d5,160*22(a1)
c13	movem.l	d2-d5,160*23(a1)
c14	movem.l	d2-d5,160*24(a1)
c15	movem.l	d2-d5,160*25(a1)
c16	movem.l	d2-d5,160*26(a1)
c17	movem.l	d2-d5,160*27(a1)
c18	movem.l	d2-d5,160*28(a1)
c19	movem.l	d2-d5,160*29(a1)
c20	movem.l	d2-d5,160*30(a1)
c21	movem.l	d2-d5,160*31(a1)
c22	movem.l	d2-d5,160*32(a1)
c23	movem.l	d2-d5,160*33(a1)
c24	movem.l	d2-d5,160*34(a1)
c25	movem.l	d2-d5,160*35(a1)
c26	movem.l	d2-d5,160*36(a1)
c27	movem.l	d2-d5,160*37(a1)
c28	movem.l	d2-d5,160*38(a1)
c29	movem.l	d2-d5,160*39(a1)
c30	movem.l	d2-d5,160*40(a1)
c31	movem.l	d2-d5,160*41(a1)
c32	movem.l	d2-d5,160*42(a1)
c33	movem.l	d2-d5,160*43(a1)
c34	movem.l	d2-d5,160*44(a1)
c35	movem.l	d2-d5,160*45(a1)
c36	movem.l	d2-d5,160*46(a1)
c37	movem.l	d2-d5,160*47(a1)
c38	movem.l	d2-d5,160*48(a1)
c39	movem.l	d2-d5,160*49(a1)
c40	movem.l	d2-d5,160*50(a1)
c41	movem.l	d2-d5,160*51(a1)
c42	movem.l	d2-d5,160*52(a1)
c43	movem.l	d2-d5,160*53(a1)
c44	movem.l	d2-d5,160*54(a1)
c45	movem.l	d2-d5,160*55(a1)
c46	movem.l	d2-d5,160*56(a1)
c47	movem.l	d2-d5,160*57(a1)
c48	movem.l	d2-d5,160*58(a1)
c49	movem.l	d2-d5,160*59(a1)
c50	movem.l	d2-d5,160*60(a1)
c51	movem.l	d2-d5,160*61(a1)
c52	movem.l	d2-d5,160*62(a1)
c53	movem.l	d2-d5,160*63(a1)
c54	movem.l	d2-d5,160*64(a1)
c55	movem.l	d2-d5,160*65(a1)
c56	movem.l	d2-d5,160*66(a1)
c57	movem.l	d2-d5,160*67(a1)
c58	movem.l	d2-d5,160*68(a1)
c59	movem.l	d2-d5,160*69(a1)
c60	movem.l	d2-d5,160*70(a1)
c61	movem.l	d2-d5,160*71(a1)
c62	movem.l	d2-d5,160*72(a1)
c63	movem.l	d2-d5,160*73(a1)
c64	movem.l	d2-d5,160*74(a1)
c65	movem.l	d2-d5,160*75(a1)
c66	movem.l	d2-d5,160*76(a1)
c67	movem.l	d2-d5,160*77(a1)
c68	movem.l	d2-d5,160*78(a1)
c69	movem.l	d2-d5,160*79(a1)
c70	movem.l	d2-d5,160*80(a1)
	movem.l	d2-d5,160*81(a1)
	movem.l	d2-d5,160*82(a1)
	movem.l	d2-d5,160*83(a1)
	movem.l	d2-d5,160*84(a1)
	movem.l	d2-d5,160*85(a1)
	movem.l	d2-d5,160*86(a1)
	movem.l	d2-d5,160*87(a1)

	add.w	d6,a2					;8		;Draw pipe cap, 788 cycles
	movem.l	(a2)+,d2-d5				;44
	movem.l	d2-d5,160*88(a1)		;44
	add.w	d6,a2
	movem.l	(a2)+,d2-d5
	movem.l	d2-d5,160*89(a1)
	add.w	d6,a2
	movem.l	(a2)+,d2-d5
	movem.l	d2-d5,160*90(a1)
	movem.l	d2-d5,160*91(a1)
	movem.l	d2-d5,160*92(a1)
	movem.l	d2-d5,160*93(a1)
	movem.l	d2-d5,160*94(a1)
	movem.l	d2-d5,160*95(a1)
	movem.l	d2-d5,160*96(a1)
	movem.l	d2-d5,160*97(a1)
	add.w	d6,a2
	movem.l	(a2)+,d2-d5
	movem.l	d2-d5,160*98(a1)
	add.w	d6,a2
	movem.l	(a2),d2-d5
	movem.l	d2-d5,160*99(a1)
	bra		pipedrawbottomclip2
	
;----------------------------------
;Draw top pipe, with cap, clipped for X of 288...304
pipedrawtopclip3					;1316-4396 cycles, 3-9 rasters
	move.l	offscreenbse,a1			;20
	move.w	PIPE_X(a0),d0			;12

	lea		160-16(a1),a1			;8		;Add X screen offset
	sub.w	PIPE_LINEOFFSET(a0),a1	;16		;Offset Y

	lea		pipetopscrolltbl,a6		;12		;Look up preshift to X position
	and.w	#15,d0					;8
	lsl.w	#2,d0					;12
	move.l	(a6,d0.w),a2			;16
	moveq.w	#8,d6					;4		;Offset for source
	movem.l	(a2)+,d0-d3				;44		;Read Planes 1+2+3+4 for pipe column
	add.w	d6,a2					;8

	move.l	PIPE_FUNCTOP3(a0),a6	;16
	jmp		(a6)					;8

d0	movem.l	d0-d3,160*10(a1)		;44		;Draw pipe column, 3432 cycles
d1	movem.l	d0-d3,160*11(a1)
d2	movem.l	d0-d3,160*12(a1)
d3	movem.l	d0-d3,160*13(a1)
d4	movem.l	d0-d3,160*14(a1)
d5	movem.l	d0-d3,160*15(a1)
d6	movem.l	d0-d3,160*16(a1)
d7	movem.l	d0-d3,160*17(a1)
d8	movem.l	d0-d3,160*18(a1)
d9	movem.l	d0-d3,160*19(a1)
d10	movem.l	d0-d3,160*20(a1)
d11	movem.l	d0-d3,160*21(a1)
d12	movem.l	d0-d3,160*22(a1)
d13	movem.l	d0-d3,160*23(a1)
d14	movem.l	d0-d3,160*24(a1)
d15	movem.l	d0-d3,160*25(a1)
d16	movem.l	d0-d3,160*26(a1)
d17	movem.l	d0-d3,160*27(a1)
d18	movem.l	d0-d3,160*28(a1)
d19	movem.l	d0-d3,160*29(a1)
d20	movem.l	d0-d3,160*30(a1)
d21	movem.l	d0-d3,160*31(a1)
d22	movem.l	d0-d3,160*32(a1)
d23	movem.l	d0-d3,160*33(a1)
d24	movem.l	d0-d3,160*34(a1)
d25	movem.l	d0-d3,160*35(a1)
d26	movem.l	d0-d3,160*36(a1)
d27	movem.l	d0-d3,160*37(a1)
d28	movem.l	d0-d3,160*38(a1)
d29	movem.l	d0-d3,160*39(a1)
d30	movem.l	d0-d3,160*40(a1)
d31	movem.l	d0-d3,160*41(a1)
d32	movem.l	d0-d3,160*42(a1)
d33	movem.l	d0-d3,160*43(a1)
d34	movem.l	d0-d3,160*44(a1)
d35	movem.l	d0-d3,160*45(a1)
d36	movem.l	d0-d3,160*46(a1)
d37	movem.l	d0-d3,160*47(a1)
d38	movem.l	d0-d3,160*48(a1)
d39	movem.l	d0-d3,160*49(a1)
d40	movem.l	d0-d3,160*50(a1)
d41	movem.l	d0-d3,160*51(a1)
d42	movem.l	d0-d3,160*52(a1)
d43	movem.l	d0-d3,160*53(a1)
d44	movem.l	d0-d3,160*54(a1)
d45	movem.l	d0-d3,160*55(a1)
d46	movem.l	d0-d3,160*56(a1)
d47	movem.l	d0-d3,160*57(a1)
d48	movem.l	d0-d3,160*58(a1)
d49	movem.l	d0-d3,160*59(a1)
d50	movem.l	d0-d3,160*60(a1)
d51	movem.l	d0-d3,160*61(a1)
d52	movem.l	d0-d3,160*62(a1)
d53	movem.l	d0-d3,160*63(a1)
d54	movem.l	d0-d3,160*64(a1)
d55	movem.l	d0-d3,160*65(a1)
d56	movem.l	d0-d3,160*66(a1)
d57	movem.l	d0-d3,160*67(a1)
d58	movem.l	d0-d3,160*68(a1)
d59	movem.l	d0-d3,160*69(a1)
d60	movem.l	d0-d3,160*70(a1)
d61	movem.l	d0-d3,160*71(a1)
d62	movem.l	d0-d3,160*72(a1)
d63	movem.l	d0-d3,160*73(a1)
d64	movem.l	d0-d3,160*74(a1)
d65	movem.l	d0-d3,160*75(a1)
d66	movem.l	d0-d3,160*76(a1)
d67	movem.l	d0-d3,160*77(a1)
d68	movem.l	d0-d3,160*78(a1)
d69	movem.l	d0-d3,160*79(a1)
d70	movem.l	d0-d3,160*80(a1)
	movem.l	d0-d3,160*81(a1)
	movem.l	d0-d3,160*82(a1)
	movem.l	d0-d3,160*83(a1)
	movem.l	d0-d3,160*84(a1)
	movem.l	d0-d3,160*85(a1)
	movem.l	d0-d3,160*86(a1)
	movem.l	d0-d3,160*87(a1)

	movem.l	(a2)+,d0-d3				;44		;Draw pipe cap, 780 cycles
	add.w	d6,a2					;8
	movem.l	d0-d3,160*88(a1)		;44
	movem.l	(a2)+,d0-d3	
	add.w	d6,a2
	movem.l	d0-d3,160*89(a1)
	movem.l	(a2)+,d0-d3
	add.w	d6,a2
	movem.l	d0-d3,160*90(a1)
	movem.l	d0-d3,160*91(a1)
	movem.l	d0-d3,160*92(a1)
	movem.l	d0-d3,160*93(a1)
	movem.l	d0-d3,160*94(a1)
	movem.l	d0-d3,160*95(a1)
	movem.l	d0-d3,160*96(a1)
	movem.l	d0-d3,160*97(a1)
	movem.l	(a2)+,d0-d3
	add.w	d6,a2
	movem.l	d0-d3,160*98(a1)
	movem.l	(a2),d0-d3
	movem.l	d0-d3,160*99(a1)
	bra		pipedrawbottomclip3

;----------------------------------
;Draw top pipe, with cap, clipped for X of 304...320
pipedrawtopclip4					;900-2860 cycles, 2-6 rasters
	move.l	offscreenbse,a1			;20
	move.w	PIPE_X(a0),d0			;12

	lea		160-8(a1),a1			;8		;Add X screen offset
	sub.w	PIPE_LINEOFFSET(a0),a1	;16		;Offset Y

	lea		pipetopscrolltbl,a6		;12		;Look up preshift to X position
	and.w	#15,d0					;8
	lsl.w	#2,d0					;12
	move.l	(a6,d0.w),a2			;16
	moveq.w	#16,d6					;4		;Offset for source
	movem.l	(a2)+,d0-d1				;28		;Read Planes 1+2+3+4 for pipe column
	add.w	d6,a2					;8

	move.l	PIPE_FUNCTOP4(a0),a6	;16
	jmp		(a6)					;8

e0	movem.l	d0-d1,160*10(a1)		;28		;Draw pipe column, 2184 cycles
e1	movem.l	d0-d1,160*11(a1)
e2	movem.l	d0-d1,160*12(a1)
e3	movem.l	d0-d1,160*13(a1)
e4	movem.l	d0-d1,160*14(a1)
e5	movem.l	d0-d1,160*15(a1)
e6	movem.l	d0-d1,160*16(a1)
e7	movem.l	d0-d1,160*17(a1)
e8	movem.l	d0-d1,160*18(a1)
e9	movem.l	d0-d1,160*19(a1)
e10	movem.l	d0-d1,160*20(a1)
e11	movem.l	d0-d1,160*21(a1)
e12	movem.l	d0-d1,160*22(a1)
e13	movem.l	d0-d1,160*23(a1)
e14	movem.l	d0-d1,160*24(a1)
e15	movem.l	d0-d1,160*25(a1)
e16	movem.l	d0-d1,160*26(a1)
e17	movem.l	d0-d1,160*27(a1)
e18	movem.l	d0-d1,160*28(a1)
e19	movem.l	d0-d1,160*29(a1)
e20	movem.l	d0-d1,160*30(a1)
e21	movem.l	d0-d1,160*31(a1)
e22	movem.l	d0-d1,160*32(a1)
e23	movem.l	d0-d1,160*33(a1)
e24	movem.l	d0-d1,160*34(a1)
e25	movem.l	d0-d1,160*35(a1)
e26	movem.l	d0-d1,160*36(a1)
e27	movem.l	d0-d1,160*37(a1)
e28	movem.l	d0-d1,160*38(a1)
e29	movem.l	d0-d1,160*39(a1)
e30	movem.l	d0-d1,160*40(a1)
e31	movem.l	d0-d1,160*41(a1)
e32	movem.l	d0-d1,160*42(a1)
e33	movem.l	d0-d1,160*43(a1)
e34	movem.l	d0-d1,160*44(a1)
e35	movem.l	d0-d1,160*45(a1)
e36	movem.l	d0-d1,160*46(a1)
e37	movem.l	d0-d1,160*47(a1)
e38	movem.l	d0-d1,160*48(a1)
e39	movem.l	d0-d1,160*49(a1)
e40	movem.l	d0-d1,160*50(a1)
e41	movem.l	d0-d1,160*51(a1)
e42	movem.l	d0-d1,160*52(a1)
e43	movem.l	d0-d1,160*53(a1)
e44	movem.l	d0-d1,160*54(a1)
e45	movem.l	d0-d1,160*55(a1)
e46	movem.l	d0-d1,160*56(a1)
e47	movem.l	d0-d1,160*57(a1)
e48	movem.l	d0-d1,160*58(a1)
e49	movem.l	d0-d1,160*59(a1)
e50	movem.l	d0-d1,160*60(a1)
e51	movem.l	d0-d1,160*61(a1)
e52	movem.l	d0-d1,160*62(a1)
e53	movem.l	d0-d1,160*63(a1)
e54	movem.l	d0-d1,160*64(a1)
e55	movem.l	d0-d1,160*65(a1)
e56	movem.l	d0-d1,160*66(a1)
e57	movem.l	d0-d1,160*67(a1)
e58	movem.l	d0-d1,160*68(a1)
e59	movem.l	d0-d1,160*69(a1)
e60	movem.l	d0-d1,160*70(a1)
e61	movem.l	d0-d1,160*71(a1)
e62	movem.l	d0-d1,160*72(a1)
e63	movem.l	d0-d1,160*73(a1)
e64	movem.l	d0-d1,160*74(a1)
e65	movem.l	d0-d1,160*75(a1)
e66	movem.l	d0-d1,160*76(a1)
e67	movem.l	d0-d1,160*77(a1)
e68	movem.l	d0-d1,160*78(a1)
e69	movem.l	d0-d1,160*79(a1)
e70	movem.l	d0-d1,160*80(a1)
	movem.l	d0-d1,160*81(a1)
	movem.l	d0-d1,160*82(a1)
	movem.l	d0-d1,160*83(a1)
	movem.l	d0-d1,160*84(a1)
	movem.l	d0-d1,160*85(a1)
	movem.l	d0-d1,160*86(a1)
	movem.l	d0-d1,160*87(a1)

	movem.l	(a2)+,d0-d1				;28		;Draw pipe cap, 508 cycles
	add.w	d6,a2					;8
	movem.l	d0-d1,160*88(a1)		;28
	movem.l	(a2)+,d0-d1
	add.w	d6,a2
	movem.l	d0-d1,160*89(a1)
	movem.l	(a2)+,d0-d1
	add.w	d6,a2
	movem.l	d0-d1,160*90(a1)
	movem.l	d0-d1,160*91(a1)
	movem.l	d0-d1,160*92(a1)
	movem.l	d0-d1,160*93(a1)
	movem.l	d0-d1,160*94(a1)
	movem.l	d0-d1,160*95(a1)
	movem.l	d0-d1,160*96(a1)
	movem.l	d0-d1,160*97(a1)
	movem.l	(a2)+,d0-d1
	add.w	d6,a2
	movem.l	d0-d1,160*98(a1)
	movem.l	(a2),d0-d1
	movem.l	d0-d1,160*99(a1)
	bra		pipedrawbottomclip4
	
;----------------------------------
;Draw bottom pipe
pipedrawbottom						;996-7476 cycles, 2-15 rasters
	move.l	offscreenbse,a1			;20	
	move.w	PIPE_X(a0),d0			;12

	move.w	d0,d1					;4		;Add X screen offset
	lsr.w	#1,d1					;8
	and.w	#$fff8,d1				;8
	add.w	d1,a1					;8

	lea		pipeskyscrolltbl,a6		;12		;Get preshifts for X position
	and.w	#127,d0					;8
	lsl.w	#3,d0					;12
	add.w	d0,a6					;8
	lea		pipetoppreshift,a2		;12
	add.w	(a6)+,a2				;12
	lea		pipesky1preshift,a3		;12
	moveq.l	#0,d0					;4		;Offset for sky1 is unsigned
	move.w	(a6)+,d0				;8
	add.l	d0,a3					;8
	add.w	PIPE_SKY1OFFSET(a0),a3	;16
	lea		pipesky2preshift,a4		;12
	add.w	(a6)+,a4				;12
	add.w	PIPE_SKY2OFFSET(a0),a4	;16
	lea		pipesky3preshift,a5		;12
	add.w	(a6),a5					;12
	add.w	PIPE_SKY3OFFSET(a0),a5	;16
	movem.l	(a2),d0-d5				;60		;Read Planes 1+2+3+4 for pipe column

	movem.l	d0-d5,160*151(a1)		;60		;Draw very bottom of pipe first, 540 cycles
	movem.l	d0-d5,160*152(a1)
	movem.l	d0-d5,160*153(a1)
	movem.l	d0-d5,160*154(a1)
	movem.l	d0-d5,160*155(a1)
	movem.l	d0-d5,160*156(a1)
	movem.l	d0-d5,160*157(a1)
	movem.l	d0-d5,160*158(a1)
	movem.l	d0-d5,160*159(a1)

	move.l	PIPE_FUNCBOTTOM(a0),a6	;16
	jmp		(a6)					;8

f0	movem.l	d0-d5,160*80(a1)		;60		;Draw pipe column, 1920 cycles
f1	movem.l	d0-d5,160*81(a1)
f2	movem.l	d0-d5,160*82(a1)
f3	movem.l	d0-d5,160*83(a1)
f4	movem.l	d0-d5,160*84(a1)
f5	movem.l	d0-d5,160*85(a1)
f6	movem.l	d0-d5,160*86(a1)
f7	movem.l	d0-d5,160*87(a1)
f8	movem.l	d0-d5,160*88(a1)
f9	movem.l	d0-d5,160*89(a1)
f10	movem.l	d0-d5,160*90(a1)
f11	movem.l	d0-d5,160*91(a1)
f12	movem.l	d0-d5,160*92(a1)
f13	movem.l	d0-d5,160*93(a1)
f14	movem.l	d0-d5,160*94(a1)
f15	movem.l	d0-d5,160*95(a1)
f16	movem.l	d0-d5,160*96(a1)
f17	movem.l	d0-d5,160*97(a1)
f18	movem.l	d0-d5,160*98(a1)
f19	movem.l	d0-d5,160*99(a1)
f20	movem.l	d0-d5,160*100(a1)
f21	movem.l	d0-d5,160*101(a1)
f22	movem.l	d0-d5,160*102(a1)
f23	movem.l	d0-d5,160*103(a1)
f24	movem.l	d0-d5,160*104(a1)
f25	movem.l	d0-d5,160*105(a1)
f26	movem.l	d0-d5,160*106(a1)
f27	movem.l	d0-d5,160*107(a1)
f28	movem.l	d0-d5,160*108(a1)
f29	movem.l	d0-d5,160*109(a1)
f30	movem.l	d0-d5,160*110(a1)
f31	movem.l	d0-d5,160*111(a1)

f32	movem.l	(a3)+,d0-d5				;60		;Sky top, 1320 cycles
	movem.l	d0-d5,160*112(a1)		;60
f33	movem.l	(a3)+,d0-d5
	movem.l	d0-d5,160*113(a1)
f34	movem.l	(a3)+,d0-d5
	movem.l	d0-d5,160*114(a1)
f35	movem.l	(a3)+,d0-d5
	movem.l	d0-d5,160*115(a1)
f36	movem.l	(a3)+,d0-d5
	movem.l	d0-d5,160*116(a1)
f37	movem.l	(a3)+,d0-d5
	movem.l	d0-d5,160*117(a1)
f38	movem.l	(a3)+,d0-d5
	movem.l	d0-d5,160*118(a1)
f39	movem.l	(a3)+,d0-d5
	movem.l	d0-d5,160*119(a1)
f40	movem.l	(a3)+,d0-d5
	movem.l	d0-d5,160*120(a1)
f41	movem.l	(a3)+,d0-d5
	movem.l	d0-d5,160*121(a1)
f42	movem.l	(a3),d0-d5
	movem.l	d0-d5,160*122(a1)

f43	movem.l	(a4)+,d0-d5				;60		;Buildings, 2280 cycles
	movem.l	d0-d5,160*123(a1)		;60
f44	movem.l	(a4)+,d0-d5
	movem.l	d0-d5,160*124(a1)
f45	movem.l	(a4)+,d0-d5
	movem.l	d0-d5,160*125(a1)
f46	movem.l	(a4)+,d0-d5
	movem.l	d0-d5,160*126(a1)
f47	movem.l	(a4)+,d0-d5
	movem.l	d0-d5,160*127(a1)
f48	movem.l	(a4)+,d0-d5
	movem.l	d0-d5,160*128(a1)
f49	movem.l	(a4)+,d0-d5
	movem.l	d0-d5,160*129(a1)
f50	movem.l	(a4)+,d0-d5
	movem.l	d0-d5,160*130(a1)
f51	movem.l	(a4)+,d0-d5
	movem.l	d0-d5,160*131(a1)
f52	movem.l	(a4)+,d0-d5
	movem.l	d0-d5,160*132(a1)
f53	movem.l	(a4)+,d0-d5
	movem.l	d0-d5,160*133(a1)
f54	movem.l	(a4)+,d0-d5
	movem.l	d0-d5,160*134(a1)
f55	movem.l	(a4)+,d0-d5
	movem.l	d0-d5,160*135(a1)
f56	movem.l	(a4)+,d0-d5
	movem.l	d0-d5,160*136(a1)
f57	movem.l	(a4)+,d0-d5
	movem.l	d0-d5,160*137(a1)
f58	movem.l	(a4)+,d0-d5
	movem.l	d0-d5,160*138(a1)
f59	movem.l	(a4)+,d0-d5
	movem.l	d0-d5,160*139(a1)
f60	movem.l	(a4)+,d0-d5
	movem.l	d0-d5,160*140(a1)
f61	movem.l	(a4),d0-d5
	movem.l	d0-d5,160*141(a1)
	
f62	movem.l	(a5)+,d0-d5				;60		;Grass, 1080 cycles
	movem.l	d0-d5,160*142(a1)		;60
f63	movem.l	(a5)+,d0-d5
	movem.l	d0-d5,160*143(a1)
f64	movem.l	(a5)+,d0-d5
	movem.l	d0-d5,160*144(a1)
f65	movem.l	(a5)+,d0-d5
	movem.l	d0-d5,160*145(a1)
f66	movem.l	(a5)+,d0-d5
	movem.l	d0-d5,160*146(a1)
f67	movem.l	(a5)+,d0-d5
	movem.l	d0-d5,160*147(a1)
f68	movem.l	(a5)+,d0-d5
	movem.l	d0-d5,160*148(a1)
f69	movem.l	(a5)+,d0-d5
	movem.l	d0-d5,160*149(a1)
f70	movem.l	(a5),d0-d5
	movem.l	d0-d5,160*150(a1)
	bra		pipedrawbottomcap
	
;----------------------------------
;Draw bottom pipe clipped for X of -32...-16
pipedrawbottomclip1					;604-3932 cycles, 1-8 rasters
	move.l	offscreenbse,a1			;20
	move.w	PIPE_X(a0),d0			;12

	lea		pipeskyscrolltbl,a6		;12		;Get preshifts for X position
	and.w	#127,d0					;8
	lsl.w	#3,d0					;12
	add.w	d0,a6					;8
	lea		pipetoppreshift,a2		;12
	add.w	(a6)+,a2				;12
	lea		pipesky1preshift,a3		;12
	moveq.l	#0,d0					;4		;Offset for sky1 is unsigned
	move.w	(a6)+,d0				;8
	add.l	d0,a3					;8
	add.w	PIPE_SKY1OFFSET(a0),a3	;16
	lea		pipesky2preshift,a4		;12
	add.w	(a6)+,a4				;12
	add.w	PIPE_SKY2OFFSET(a0),a4	;16
	lea		pipesky3preshift,a5		;12
	add.w	(a6),a5					;12
	add.w	PIPE_SKY3OFFSET(a0),a5	;16
	moveq.w	#16,d6					;4		;Offset for sky source
	movem.l	(a2,d6.w),d4-d5			;36		;Read Planes 1+2+3+4 for pipe column

	movem.l	d4-d5,160*151(a1)		;28		;Draw very bottom of pipe first, 252 cycles
	movem.l	d4-d5,160*152(a1)
	movem.l	d4-d5,160*153(a1)
	movem.l	d4-d5,160*154(a1)
	movem.l	d4-d5,160*155(a1)
	movem.l	d4-d5,160*156(a1)
	movem.l	d4-d5,160*157(a1)
	movem.l	d4-d5,160*158(a1)
	movem.l	d4-d5,160*159(a1)

	move.l	PIPE_FUNCBOTTOM1(a0),a6	;16
	jmp		(a6)					;8

g0	movem.l	d4-d5,160*80(a1)		;28		;Draw pipe column, 896 cycles
g1	movem.l	d4-d5,160*81(a1)
g2	movem.l	d4-d5,160*82(a1)
g3	movem.l	d4-d5,160*83(a1)
g4	movem.l	d4-d5,160*84(a1)
g5	movem.l	d4-d5,160*85(a1)
g6	movem.l	d4-d5,160*86(a1)
g7	movem.l	d4-d5,160*87(a1)
g8	movem.l	d4-d5,160*88(a1)
g9	movem.l	d4-d5,160*89(a1)
g10	movem.l	d4-d5,160*90(a1)
g11	movem.l	d4-d5,160*91(a1)
g12	movem.l	d4-d5,160*92(a1)
g13	movem.l	d4-d5,160*93(a1)
g14	movem.l	d4-d5,160*94(a1)
g15	movem.l	d4-d5,160*95(a1)
g16	movem.l	d4-d5,160*96(a1)
g17	movem.l	d4-d5,160*97(a1)
g18	movem.l	d4-d5,160*98(a1)
g19	movem.l	d4-d5,160*99(a1)
g20	movem.l	d4-d5,160*100(a1)
g21	movem.l	d4-d5,160*101(a1)
g22	movem.l	d4-d5,160*102(a1)
g23	movem.l	d4-d5,160*103(a1)
g24	movem.l	d4-d5,160*104(a1)
g25	movem.l	d4-d5,160*105(a1)
g26	movem.l	d4-d5,160*106(a1)
g27	movem.l	d4-d5,160*107(a1)
g28	movem.l	d4-d5,160*108(a1)
g29	movem.l	d4-d5,160*109(a1)
g30	movem.l	d4-d5,160*110(a1)
g31	movem.l	d4-d5,160*111(a1)

g32	add.w	d6,a3					;8		;Sky top, 704 cycles
	movem.l	(a3)+,d4-d5				;28
	movem.l	d4-d5,160*112(a1)		;28
g33	add.w	d6,a3
	movem.l	(a3)+,d4-d5
	movem.l	d4-d5,160*113(a1)
g34	add.w	d6,a3
	movem.l	(a3)+,d4-d5
	movem.l	d4-d5,160*114(a1)
g35	add.w	d6,a3
	movem.l	(a3)+,d4-d5
	movem.l	d4-d5,160*115(a1)
g36	add.w	d6,a3
	movem.l	(a3)+,d4-d5
	movem.l	d4-d5,160*116(a1)
g37	add.w	d6,a3
	movem.l	(a3)+,d4-d5
	movem.l	d4-d5,160*117(a1)
g38	add.w	d6,a3
	movem.l	(a3)+,d4-d5
	movem.l	d4-d5,160*118(a1)
g39	add.w	d6,a3
	movem.l	(a3)+,d4-d5
	movem.l	d4-d5,160*119(a1)
g40	add.w	d6,a3
	movem.l	(a3)+,d4-d5
	movem.l	d4-d5,160*120(a1)
g41	add.w	d6,a3
	movem.l	(a3)+,d4-d5
	movem.l	d4-d5,160*121(a1)
g42	add.w	d6,a3
	movem.l	(a3),d4-d5
	movem.l	d4-d5,160*122(a1)

g43	add.w	d6,a4					;8		;Buildings, 1216 cycles
	movem.l	(a4)+,d4-d5				;28
	movem.l	d4-d5,160*123(a1)		;28
g44	add.w	d6,a4
	movem.l	(a4)+,d4-d5
	movem.l	d4-d5,160*124(a1)
g45	add.w	d6,a4
	movem.l	(a4)+,d4-d5
	movem.l	d4-d5,160*125(a1)
g46	add.w	d6,a4
	movem.l	(a4)+,d4-d5
	movem.l	d4-d5,160*126(a1)
g47	add.w	d6,a4
	movem.l	(a4)+,d4-d5
	movem.l	d4-d5,160*127(a1)
g48	add.w	d6,a4
	movem.l	(a4)+,d4-d5
	movem.l	d4-d5,160*128(a1)
g49	add.w	d6,a4
	movem.l	(a4)+,d4-d5
	movem.l	d4-d5,160*129(a1)
g50	add.w	d6,a4
	movem.l	(a4)+,d4-d5
	movem.l	d4-d5,160*130(a1)
g51	add.w	d6,a4
	movem.l	(a4)+,d4-d5
	movem.l	d4-d5,160*131(a1)
g52	add.w	d6,a4
	movem.l	(a4)+,d4-d5
	movem.l	d4-d5,160*132(a1)
g53	add.w	d6,a4
	movem.l	(a4)+,d4-d5
	movem.l	d4-d5,160*133(a1)
g54	add.w	d6,a4
	movem.l	(a4)+,d4-d5
	movem.l	d4-d5,160*134(a1)
g55	add.w	d6,a4
	movem.l	(a4)+,d4-d5
	movem.l	d4-d5,160*135(a1)
g56	add.w	d6,a4
	movem.l	(a4)+,d4-d5
	movem.l	d4-d5,160*136(a1)
g57	add.w	d6,a4
	movem.l	(a4)+,d4-d5
	movem.l	d4-d5,160*137(a1)
g58	add.w	d6,a4
	movem.l	(a4)+,d4-d5
	movem.l	d4-d5,160*138(a1)
g59	add.w	d6,a4
	movem.l	(a4)+,d4-d5
	movem.l	d4-d5,160*139(a1)
g60	add.w	d6,a4
	movem.l	(a4)+,d4-d5
	movem.l	d4-d5,160*140(a1)
g61	add.w	d6,a4
	movem.l	(a4),d4-d5
	movem.l	d4-d5,160*141(a1)
	
g62	add.w	d6,a5					;8		;Grass, 576 cycles
	movem.l	(a5)+,d4-d5				;28
	movem.l	d4-d5,160*142(a1)		;28
g63	add.w	d6,a5
	movem.l	(a5)+,d4-d5
	movem.l	d4-d5,160*143(a1)
g64	add.w	d6,a5
	movem.l	(a5)+,d4-d5
	movem.l	d4-d5,160*144(a1)
g65	add.w	d6,a5
	movem.l	(a5)+,d4-d5
	movem.l	d4-d5,160*145(a1)
g66	add.w	d6,a5
	movem.l	(a5)+,d4-d5
	movem.l	d4-d5,160*146(a1)
g67	add.w	d6,a5
	movem.l	(a5)+,d4-d5
	movem.l	d4-d5,160*147(a1)
g68	add.w	d6,a5
	movem.l	(a5)+,d4-d5
	movem.l	d4-d5,160*148(a1)
g69	add.w	d6,a5
	movem.l	(a5)+,d4-d5
	movem.l	d4-d5,160*149(a1)
g70	add.w	d6,a5
	movem.l	(a5),d4-d5
	movem.l	d4-d5,160*150(a1)
	bra		pipedrawbottomcapclip1
	
;----------------------------------
;Draw bottom pipe clipped for X of -16...0
pipedrawbottomclip2					;756-5852 cycles, 2-12 rasters
	move.l	offscreenbse,a1			;20	
	move.w	PIPE_X(a0),d0			;12

	lea		pipeskyscrolltbl,a6		;12		;Get preshifts for X position
	and.w	#127,d0					;8
	lsl.w	#3,d0					;12
	add.w	d0,a6					;8
	lea		pipetoppreshift,a2		;12
	add.w	(a6)+,a2				;12
	lea		pipesky1preshift,a3		;12
	moveq.l	#0,d0					;4		;Offset for sky1 is unsigned
	move.w	(a6)+,d0				;8
	add.l	d0,a3					;8
	add.w	PIPE_SKY1OFFSET(a0),a3	;16
	lea		pipesky2preshift,a4		;12
	add.w	(a6)+,a4				;12
	add.w	PIPE_SKY2OFFSET(a0),a4	;16
	lea		pipesky3preshift,a5		;12
	add.w	(a6),a5					;12
	add.w	PIPE_SKY3OFFSET(a0),a5	;16
	moveq.w	#8,d6					;4		;Offset for sky source
	movem.l	(a2,d6.w),d2-d5			;52		;Read Planes 1+2+3+4 for pipe column

	movem.l	d2-d5,160*151(a1)		;44		;Draw very bottom of pipe first, 396 cycles
	movem.l	d2-d5,160*152(a1)
	movem.l	d2-d5,160*153(a1)
	movem.l	d2-d5,160*154(a1)
	movem.l	d2-d5,160*155(a1)
	movem.l	d2-d5,160*156(a1)
	movem.l	d2-d5,160*157(a1)
	movem.l	d2-d5,160*158(a1)
	movem.l	d2-d5,160*159(a1)

	move.l	PIPE_FUNCBOTTOM2(a0),a6	;16
	jmp		(a6)					;8

h0	movem.l	d2-d5,160*80(a1)		;44		;Draw pipe column, 1408 cycles
h1	movem.l	d2-d5,160*81(a1)
h2	movem.l	d2-d5,160*82(a1)
h3	movem.l	d2-d5,160*83(a1)
h4	movem.l	d2-d5,160*84(a1)
h5	movem.l	d2-d5,160*85(a1)
h6	movem.l	d2-d5,160*86(a1)
h7	movem.l	d2-d5,160*87(a1)
h8	movem.l	d2-d5,160*88(a1)
h9	movem.l	d2-d5,160*89(a1)
h10	movem.l	d2-d5,160*90(a1)
h11	movem.l	d2-d5,160*91(a1)
h12	movem.l	d2-d5,160*92(a1)
h13	movem.l	d2-d5,160*93(a1)
h14	movem.l	d2-d5,160*94(a1)
h15	movem.l	d2-d5,160*95(a1)
h16	movem.l	d2-d5,160*96(a1)
h17	movem.l	d2-d5,160*97(a1)
h18	movem.l	d2-d5,160*98(a1)
h19	movem.l	d2-d5,160*99(a1)
h20	movem.l	d2-d5,160*100(a1)
h21	movem.l	d2-d5,160*101(a1)
h22	movem.l	d2-d5,160*102(a1)
h23	movem.l	d2-d5,160*103(a1)
h24	movem.l	d2-d5,160*104(a1)
h25	movem.l	d2-d5,160*105(a1)
h26	movem.l	d2-d5,160*106(a1)
h27	movem.l	d2-d5,160*107(a1)
h28	movem.l	d2-d5,160*108(a1)
h29	movem.l	d2-d5,160*109(a1)
h30	movem.l	d2-d5,160*110(a1)
h31	movem.l	d2-d5,160*111(a1)

h32	add.w	d6,a3					;8		;Sky top, 1056 cycles
	movem.l	(a3)+,d2-d5				;44
	movem.l	d2-d5,160*112(a1)		;44
h33	add.w	d6,a3
	movem.l	(a3)+,d2-d5
	movem.l	d2-d5,160*113(a1)
h34	add.w	d6,a3
	movem.l	(a3)+,d2-d5
	movem.l	d2-d5,160*114(a1)
h35	add.w	d6,a3
	movem.l	(a3)+,d2-d5
	movem.l	d2-d5,160*115(a1)
h36	add.w	d6,a3
	movem.l	(a3)+,d2-d5
	movem.l	d2-d5,160*116(a1)
h37	add.w	d6,a3
	movem.l	(a3)+,d2-d5
	movem.l	d2-d5,160*117(a1)
h38	add.w	d6,a3
	movem.l	(a3)+,d2-d5
	movem.l	d2-d5,160*118(a1)
h39	add.w	d6,a3
	movem.l	(a3)+,d2-d5
	movem.l	d2-d5,160*119(a1)
h40	add.w	d6,a3
	movem.l	(a3)+,d2-d5
	movem.l	d2-d5,160*120(a1)
h41	add.w	d6,a3
	movem.l	(a3)+,d2-d5
	movem.l	d2-d5,160*121(a1)
h42	add.w	d6,a3
	movem.l	(a3),d2-d5
	movem.l	d2-d5,160*122(a1)

h43	add.w	d6,a4					;8		;Buildings, 1824 cycles
	movem.l	(a4)+,d2-d5				;44
	movem.l	d2-d5,160*123(a1)		;44
h44	add.w	d6,a4
	movem.l	(a4)+,d2-d5
	movem.l	d2-d5,160*124(a1)
h45	add.w	d6,a4
	movem.l	(a4)+,d2-d5
	movem.l	d2-d5,160*125(a1)
h46	add.w	d6,a4
	movem.l	(a4)+,d2-d5
	movem.l	d2-d5,160*126(a1)
h47	add.w	d6,a4
	movem.l	(a4)+,d2-d5
	movem.l	d2-d5,160*127(a1)
h48	add.w	d6,a4
	movem.l	(a4)+,d2-d5
	movem.l	d2-d5,160*128(a1)
h49	add.w	d6,a4
	movem.l	(a4)+,d2-d5
	movem.l	d2-d5,160*129(a1)
h50	add.w	d6,a4
	movem.l	(a4)+,d2-d5
	movem.l	d2-d5,160*130(a1)
h51	add.w	d6,a4
	movem.l	(a4)+,d2-d5
	movem.l	d2-d5,160*131(a1)
h52	add.w	d6,a4
	movem.l	(a4)+,d2-d5
	movem.l	d2-d5,160*132(a1)
h53	add.w	d6,a4
	movem.l	(a4)+,d2-d5
	movem.l	d2-d5,160*133(a1)
h54	add.w	d6,a4
	movem.l	(a4)+,d2-d5
	movem.l	d2-d5,160*134(a1)
h55	add.w	d6,a4
	movem.l	(a4)+,d2-d5
	movem.l	d2-d5,160*135(a1)
h56	add.w	d6,a4
	movem.l	(a4)+,d2-d5
	movem.l	d2-d5,160*136(a1)
h57	add.w	d6,a4
	movem.l	(a4)+,d2-d5
	movem.l	d2-d5,160*137(a1)
h58	add.w	d6,a4
	movem.l	(a4)+,d2-d5
	movem.l	d2-d5,160*138(a1)
h59	add.w	d6,a4
	movem.l	(a4)+,d2-d5
	movem.l	d2-d5,160*139(a1)
h60	add.w	d6,a4
	movem.l	(a4)+,d2-d5
	movem.l	d2-d5,160*140(a1)
h61	add.w	d6,a4
	movem.l	(a4),d2-d5
	movem.l	d2-d5,160*141(a1)
	
h62	add.w	d6,a5					;8		;Grass, 864 cycles
	movem.l	(a5)+,d2-d5				;44
	movem.l	d2-d5,160*142(a1)		;44
h63	add.w	d6,a5
	movem.l	(a5)+,d2-d5
	movem.l	d2-d5,160*143(a1)
h64	add.w	d6,a5
	movem.l	(a5)+,d2-d5
	movem.l	d2-d5,160*144(a1)
h65	add.w	d6,a5
	movem.l	(a5)+,d2-d5
	movem.l	d2-d5,160*145(a1)
h66	add.w	d6,a5
	movem.l	(a5)+,d2-d5
	movem.l	d2-d5,160*146(a1)
h67	add.w	d6,a5
	movem.l	(a5)+,d2-d5
	movem.l	d2-d5,160*147(a1)
h68	add.w	d6,a5
	movem.l	(a5)+,d2-d5
	movem.l	d2-d5,160*148(a1)
h69	add.w	d6,a5
	movem.l	(a5)+,d2-d5
	movem.l	d2-d5,160*149(a1)
h70	add.w	d6,a5
	movem.l	(a5),d2-d5
	movem.l	d2-d5,160*150(a1)
	bra		pipedrawbottomcapclip2
	
;----------------------------------
;Draw bottom pipe clipped for X of 288...304
pipedrawbottomclip3					;748-5828 cycles, 2-12 rasters
	move.l	offscreenbse,a1			;20	
	move.w	PIPE_X(a0),d0			;12

	lea		160-16(a1),a1			;8		;Add X screen offset

	lea		pipeskyscrolltbl,a6		;12		;Get preshifts for X position
	and.w	#127,d0					;8
	lsl.w	#3,d0					;12
	add.w	d0,a6					;8
	lea		pipetoppreshift,a2		;12
	add.w	(a6)+,a2				;12
	lea		pipesky1preshift,a3		;12
	moveq.l	#0,d0					;4		;Offset for sky1 is unsigned
	move.w	(a6)+,d0				;8
	add.l	d0,a3					;8
	add.w	PIPE_SKY1OFFSET(a0),a3	;16
	lea		pipesky2preshift,a4		;12
	add.w	(a6)+,a4				;12
	add.w	PIPE_SKY2OFFSET(a0),a4	;16
	lea		pipesky3preshift,a5		;12
	add.w	(a6),a5					;12
	add.w	PIPE_SKY3OFFSET(a0),a5	;16
	moveq.w	#8,d6					;4		;Offset for sky source
	movem.l	(a2),d0-d3				;44		;Read Planes 1+2+3+4 for pipe column

	movem.l	d0-d3,160*151(a1)		;44		;Draw very bottom of pipe first, 396 cycles
	movem.l	d0-d3,160*152(a1)
	movem.l	d0-d3,160*153(a1)
	movem.l	d0-d3,160*154(a1)
	movem.l	d0-d3,160*155(a1)
	movem.l	d0-d3,160*156(a1)
	movem.l	d0-d3,160*157(a1)
	movem.l	d0-d3,160*158(a1)
	movem.l	d0-d3,160*159(a1)

	move.l	PIPE_FUNCBOTTOM3(a0),a6	;16
	jmp		(a6)					;8

i0	movem.l	d0-d3,160*80(a1)		;44		;Draw pipe column, 1408 cycles
i1	movem.l	d0-d3,160*81(a1)
i2	movem.l	d0-d3,160*82(a1)
i3	movem.l	d0-d3,160*83(a1)
i4	movem.l	d0-d3,160*84(a1)
i5	movem.l	d0-d3,160*85(a1)
i6	movem.l	d0-d3,160*86(a1)
i7	movem.l	d0-d3,160*87(a1)
i8	movem.l	d0-d3,160*88(a1)
i9	movem.l	d0-d3,160*89(a1)
i10	movem.l	d0-d3,160*90(a1)
i11	movem.l	d0-d3,160*91(a1)
i12	movem.l	d0-d3,160*92(a1)
i13	movem.l	d0-d3,160*93(a1)
i14	movem.l	d0-d3,160*94(a1)
i15	movem.l	d0-d3,160*95(a1)
i16	movem.l	d0-d3,160*96(a1)
i17	movem.l	d0-d3,160*97(a1)
i18	movem.l	d0-d3,160*98(a1)
i19	movem.l	d0-d3,160*99(a1)
i20	movem.l	d0-d3,160*100(a1)
i21	movem.l	d0-d3,160*101(a1)
i22	movem.l	d0-d3,160*102(a1)
i23	movem.l	d0-d3,160*103(a1)
i24	movem.l	d0-d3,160*104(a1)
i25	movem.l	d0-d3,160*105(a1)
i26	movem.l	d0-d3,160*106(a1)
i27	movem.l	d0-d3,160*107(a1)
i28	movem.l	d0-d3,160*108(a1)
i29	movem.l	d0-d3,160*109(a1)
i30	movem.l	d0-d3,160*110(a1)
i31	movem.l	d0-d3,160*111(a1)

i32	movem.l	(a3)+,d0-d3				;44		;Sky top, 1048 cycles
	add.w	d6,a3					;8
	movem.l	d0-d3,160*112(a1)		;44
i33	movem.l	(a3)+,d0-d3
	add.w	d6,a3
	movem.l	d0-d3,160*113(a1)
i34	movem.l	(a3)+,d0-d3
	add.w	d6,a3
	movem.l	d0-d3,160*114(a1)
i35	movem.l	(a3)+,d0-d3
	add.w	d6,a3
	movem.l	d0-d3,160*115(a1)
i36	movem.l	(a3)+,d0-d3
	add.w	d6,a3
	movem.l	d0-d3,160*116(a1)
i37	movem.l	(a3)+,d0-d3
	add.w	d6,a3
	movem.l	d0-d3,160*117(a1)
i38	movem.l	(a3)+,d0-d3
	add.w	d6,a3
	movem.l	d0-d3,160*118(a1)
i39	movem.l	(a3)+,d0-d3
	add.w	d6,a3
	movem.l	d0-d3,160*119(a1)
i40	movem.l	(a3)+,d0-d3
	add.w	d6,a3
	movem.l	d0-d3,160*120(a1)
i41	movem.l	(a3)+,d0-d3
	add.w	d6,a3
	movem.l	d0-d3,160*121(a1)
i42	movem.l	(a3),d0-d3
	movem.l	d0-d3,160*122(a1)

i43	movem.l	(a4)+,d0-d3				;44		;Buildings, 1816 cycles
	add.w	d6,a4					;8
	movem.l	d0-d3,160*123(a1)		;44
i44	movem.l	(a4)+,d0-d3
	add.w	d6,a4
	movem.l	d0-d3,160*124(a1)
i45	movem.l	(a4)+,d0-d3
	add.w	d6,a4
	movem.l	d0-d3,160*125(a1)
i46	movem.l	(a4)+,d0-d3
	add.w	d6,a4
	movem.l	d0-d3,160*126(a1)
i47	movem.l	(a4)+,d0-d3
	add.w	d6,a4
	movem.l	d0-d3,160*127(a1)
i48	movem.l	(a4)+,d0-d3
	add.w	d6,a4
	movem.l	d0-d3,160*128(a1)
i49	movem.l	(a4)+,d0-d3
	add.w	d6,a4
	movem.l	d0-d3,160*129(a1)
i50	movem.l	(a4)+,d0-d3
	add.w	d6,a4
	movem.l	d0-d3,160*130(a1)
i51	movem.l	(a4)+,d0-d3
	add.w	d6,a4
	movem.l	d0-d3,160*131(a1)
i52	movem.l	(a4)+,d0-d3
	add.w	d6,a4
	movem.l	d0-d3,160*132(a1)
i53	movem.l	(a4)+,d0-d3
	add.w	d6,a4
	movem.l	d0-d3,160*133(a1)
i54	movem.l	(a4)+,d0-d3
	add.w	d6,a4
	movem.l	d0-d3,160*134(a1)
i55	movem.l	(a4)+,d0-d3
	add.w	d6,a4
	movem.l	d0-d3,160*135(a1)
i56	movem.l	(a4)+,d0-d3
	add.w	d6,a4
	movem.l	d0-d3,160*136(a1)
i57	movem.l	(a4)+,d0-d3
	add.w	d6,a4
	movem.l	d0-d3,160*137(a1)
i58	movem.l	(a4)+,d0-d3
	add.w	d6,a4
	movem.l	d0-d3,160*138(a1)
i59	movem.l	(a4)+,d0-d3
	add.w	d6,a4
	movem.l	d0-d3,160*139(a1)
i60	movem.l	(a4)+,d0-d3
	add.w	d6,a4
	movem.l	d0-d3,160*140(a1)
i61	movem.l	(a4),d0-d3
	movem.l	d0-d3,160*141(a1)
	
i62	movem.l	(a5)+,d0-d3				;44		;Grass, 856 cycles
	add.w	d6,a5					;8
	movem.l	d0-d3,160*142(a1)		;44
i63	movem.l	(a5)+,d0-d3
	add.w	d6,a5
	movem.l	d0-d3,160*143(a1)
i64	movem.l	(a5)+,d0-d3
	add.w	d6,a5
	movem.l	d0-d3,160*144(a1)
i65	movem.l	(a5)+,d0-d3
	add.w	d6,a5
	movem.l	d0-d3,160*145(a1)
i66	movem.l	(a5)+,d0-d3
	add.w	d6,a5
	movem.l	d0-d3,160*146(a1)
i67	movem.l	(a5)+,d0-d3
	add.w	d6,a5
	movem.l	d0-d3,160*147(a1)
i68	movem.l	(a5)+,d0-d3
	add.w	d6,a5
	movem.l	d0-d3,160*148(a1)
i69	movem.l	(a5)+,d0-d3
	add.w	d6,a5
	movem.l	d0-d3,160*149(a1)
i70	movem.l	(a5),d0-d3
	movem.l	d0-d3,160*150(a1)
	bra		pipedrawbottomcapclip3

;----------------------------------
;Draw bottom pipe clipped for X of 304...320
pipedrawbottomclip4					;596-3908 cycles, 1-8 rasters
	move.l	offscreenbse,a1			;20	
	move.w	PIPE_X(a0),d0			;12

	lea		160-8(a1),a1			;8		;Add X screen offset

	lea		pipeskyscrolltbl,a6		;12		;Get preshifts for X position
	and.w	#127,d0					;8
	lsl.w	#3,d0					;12
	add.w	d0,a6					;8
	lea		pipetoppreshift,a2		;12
	add.w	(a6)+,a2				;12
	lea		pipesky1preshift,a3		;12
	moveq.l	#0,d0					;4		;Offset for sky1 is unsigned
	move.w	(a6)+,d0				;8
	add.l	d0,a3					;8
	add.w	PIPE_SKY1OFFSET(a0),a3	;16
	lea		pipesky2preshift,a4		;12
	add.w	(a6)+,a4				;12
	add.w	PIPE_SKY2OFFSET(a0),a4	;16
	lea		pipesky3preshift,a5		;12
	add.w	(a6),a5					;12
	add.w	PIPE_SKY3OFFSET(a0),a5	;16
	moveq.w	#16,d6					;4		;Offset for sky source
	movem.l	(a2),d0-d1				;28		;Read Planes 1+2+3+4 for pipe column

	movem.l	d0-d1,160*151(a1)		;28		;Draw very bottom of pipe first, 252 cycles
	movem.l	d0-d1,160*152(a1)
	movem.l	d0-d1,160*153(a1)
	movem.l	d0-d1,160*154(a1)
	movem.l	d0-d1,160*155(a1)
	movem.l	d0-d1,160*156(a1)
	movem.l	d0-d1,160*157(a1)
	movem.l	d0-d1,160*158(a1)
	movem.l	d0-d1,160*159(a1)

	move.l	PIPE_FUNCBOTTOM4(a0),a6	;16
	jmp		(a6)					;8

j0	movem.l	d0-d1,160*80(a1)		;28		;Draw pipe column, 896 cycles
j1	movem.l	d0-d1,160*81(a1)
j2	movem.l	d0-d1,160*82(a1)
j3	movem.l	d0-d1,160*83(a1)
j4	movem.l	d0-d1,160*84(a1)
j5	movem.l	d0-d1,160*85(a1)
j6	movem.l	d0-d1,160*86(a1)
j7	movem.l	d0-d1,160*87(a1)
j8	movem.l	d0-d1,160*88(a1)
j9	movem.l	d0-d1,160*89(a1)
j10	movem.l	d0-d1,160*90(a1)
j11	movem.l	d0-d1,160*91(a1)
j12	movem.l	d0-d1,160*92(a1)
j13	movem.l	d0-d1,160*93(a1)
j14	movem.l	d0-d1,160*94(a1)
j15	movem.l	d0-d1,160*95(a1)
j16	movem.l	d0-d1,160*96(a1)
j17	movem.l	d0-d1,160*97(a1)
j18	movem.l	d0-d1,160*98(a1)
j19	movem.l	d0-d1,160*99(a1)
j20	movem.l	d0-d1,160*100(a1)
j21	movem.l	d0-d1,160*101(a1)
j22	movem.l	d0-d1,160*102(a1)
j23	movem.l	d0-d1,160*103(a1)
j24	movem.l	d0-d1,160*104(a1)
j25	movem.l	d0-d1,160*105(a1)
j26	movem.l	d0-d1,160*106(a1)
j27	movem.l	d0-d1,160*107(a1)
j28	movem.l	d0-d1,160*108(a1)
j29	movem.l	d0-d1,160*109(a1)
j30	movem.l	d0-d1,160*110(a1)
j31	movem.l	d0-d1,160*111(a1)

j32	movem.l	(a3)+,d0-d1				;28		;Sky top, 696 cycles
	add.w	d6,a3					;8
	movem.l	d0-d1,160*112(a1)		;28
j33	movem.l	(a3)+,d0-d1
	add.w	d6,a3
	movem.l	d0-d1,160*113(a1)
j34	movem.l	(a3)+,d0-d1
	add.w	d6,a3
	movem.l	d0-d1,160*114(a1)
j35	movem.l	(a3)+,d0-d1
	add.w	d6,a3
	movem.l	d0-d1,160*115(a1)
j36	movem.l	(a3)+,d0-d1
	add.w	d6,a3
	movem.l	d0-d1,160*116(a1)
j37	movem.l	(a3)+,d0-d1
	add.w	d6,a3
	movem.l	d0-d1,160*117(a1)
j38	movem.l	(a3)+,d0-d1
	add.w	d6,a3
	movem.l	d0-d1,160*118(a1)
j39	movem.l	(a3)+,d0-d1
	add.w	d6,a3
	movem.l	d0-d1,160*119(a1)
j40	movem.l	(a3)+,d0-d1
	add.w	d6,a3
	movem.l	d0-d1,160*120(a1)
j41	movem.l	(a3)+,d0-d1
	add.w	d6,a3
	movem.l	d0-d1,160*121(a1)
j42	movem.l	(a3),d0-d1
	movem.l	d0-d1,160*122(a1)

j43	movem.l	(a4)+,d0-d1				;28		;Buildings, 1208 cycles
	add.w	d6,a4					;8
	movem.l	d0-d1,160*123(a1)		;28
j44	movem.l	(a4)+,d0-d1
	add.w	d6,a4
	movem.l	d0-d1,160*124(a1)
j45	movem.l	(a4)+,d0-d1
	add.w	d6,a4
	movem.l	d0-d1,160*125(a1)
j46	movem.l	(a4)+,d0-d1
	add.w	d6,a4
	movem.l	d0-d1,160*126(a1)
j47	movem.l	(a4)+,d0-d1
	add.w	d6,a4
	movem.l	d0-d1,160*127(a1)
j48	movem.l	(a4)+,d0-d1
	add.w	d6,a4
	movem.l	d0-d1,160*128(a1)
j49	movem.l	(a4)+,d0-d1
	add.w	d6,a4
	movem.l	d0-d1,160*129(a1)
j50	movem.l	(a4)+,d0-d1
	add.w	d6,a4
	movem.l	d0-d1,160*130(a1)
j51	movem.l	(a4)+,d0-d1
	add.w	d6,a4
	movem.l	d0-d1,160*131(a1)
j52	movem.l	(a4)+,d0-d1
	add.w	d6,a4
	movem.l	d0-d1,160*132(a1)
j53	movem.l	(a4)+,d0-d1
	add.w	d6,a4
	movem.l	d0-d1,160*133(a1)
j54	movem.l	(a4)+,d0-d1
	add.w	d6,a4
	movem.l	d0-d1,160*134(a1)
j55	movem.l	(a4)+,d0-d1
	add.w	d6,a4
	movem.l	d0-d1,160*135(a1)
j56	movem.l	(a4)+,d0-d1
	add.w	d6,a4
	movem.l	d0-d1,160*136(a1)
j57	movem.l	(a4)+,d0-d1
	add.w	d6,a4
	movem.l	d0-d1,160*137(a1)
j58	movem.l	(a4)+,d0-d1
	add.w	d6,a4
	movem.l	d0-d1,160*138(a1)
j59	movem.l	(a4)+,d0-d1
	add.w	d6,a4
	movem.l	d0-d1,160*139(a1)
j60	movem.l	(a4)+,d0-d1
	add.w	d6,a4
	movem.l	d0-d1,160*140(a1)
j61	movem.l	(a4),d0-d1
	movem.l	d0-d1,160*141(a1)
	
j62	movem.l	(a5)+,d0-d1				;28		;Grass, 568 cycles
	add.w	d6,a5					;8
	movem.l	d0-d1,160*142(a1)		;28
j63	movem.l	(a5)+,d0-d1
	add.w	d6,a5
	movem.l	d0-d1,160*143(a1)
j64	movem.l	(a5)+,d0-d1
	add.w	d6,a5
	movem.l	d0-d1,160*144(a1)
j65	movem.l	(a5)+,d0-d1
	add.w	d6,a5
	movem.l	d0-d1,160*145(a1)
j66	movem.l	(a5)+,d0-d1
	add.w	d6,a5
	movem.l	d0-d1,160*146(a1)
j67	movem.l	(a5)+,d0-d1
	add.w	d6,a5
	movem.l	d0-d1,160*147(a1)
j68	movem.l	(a5)+,d0-d1
	add.w	d6,a5
	movem.l	d0-d1,160*148(a1)
j69	movem.l	(a5)+,d0-d1
	add.w	d6,a5
	movem.l	d0-d1,160*149(a1)
j70	movem.l	(a5),d0-d1
	movem.l	d0-d1,160*150(a1)
	bra		pipedrawbottomcapclip4

;----------------------------------
;Routines to draw bottom cap
CAPLINE1	MACRO					;224 cycles
	movem.l	\1(a3),d0-d5			;64		;Read sky for 48 pixels
	move.l	(a2),d6					;12
	and.l	d6,d0					;8
	and.l	d6,d1					;8
	move.l	12(a2),d6				;16
	and.l	d6,d2					;8
	and.l	d6,d3					;8
	move.l	24(a2),d6				;16
	and.l	d6,d4					;8
	and.l	d6,d5					;8
	lea		36(a2),a2				;8
	movem.l	d0-d5,\2(a1)			;60		;Write
	ENDM

CAPLINE2	MACRO					;304 cycles
	movem.l	\1(a3),d0-d5			;64
	move.l	(a2)+,d6				;12
	and.l	d6,d0					;8
	and.l	d6,d1					;8
	or.l	(a2)+,d0				;16
	or.l	(a2)+,d1				;16	
	move.l	(a2)+,d6				;12
	and.l	d6,d2					;8
	and.l	d6,d3					;8
	or.l	(a2)+,d2				;16
	or.l	(a2)+,d3				;16
	move.l	(a2)+,d6				;12
	and.l	d6,d4					;8
	and.l	d6,d5					;8
	or.l	(a2)+,d4				;16
	or.l	(a2)+,d5				;16
	movem.l	d0-d5,\2(a1)			;60
	ENDM

CAPLINE3	MACRO					;168 cycles
	movem.l	\1(a3),d0-d3			;48
	and.l	d4,d0					;8
	and.l	d4,d1					;8
	or.l	d5,d0					;8
	or.l	d6,d1					;8
	move.l	a4,d7					;4
	and.l	d7,d2					;8
	and.l	d7,d3					;8
	move.l	a5,d7					;4
	or.l	d7,d2					;8
	move.l	a6,d7					;4
	or.l	d7,d3					;8
	movem.l	d0-d3,\2(a1)			;44
	ENDM

CAPLINE4	MACRO					;92 cycles
	movem.l	\1(a3),d0-d1			;32
	and.l	d4,d0					;8
	and.l	d4,d1					;8
	or.l	d5,d0					;8
	or.l	d6,d1					;8
	movem.l	d0-d1,\2(a1)			;28
	ENDM

;----------------------------------
;Draw bottom pipe cap
pipedrawbottomcap					;1164-3448 cycles, 2-7 rasters
	move.l	offscreenbse,a1			;20
	move.w	PIPE_X(a0),d0			;12

	move.w	d0,d1					;4		;Add X screen offset
	lsr.w	#1,d1					;8
	and.w	#$fff8,d1				;8
	add.w	d1,a1					;8
	add.w	PIPE_CAPOFFSET(a0),a1	;16		;Offset Y

	move.w	PIPE_SKYOFFSET(a0),d1	;12		;Offset to line in sky
	beq.w	.fasterversion			;10/12	;If over solid sky colour use faster routine
	move.l	skyimg,a3				;20		;Source sky
	add.w	d1,a3					;8
	move.w	d0,d1					;4		;Add X sky offset 0...63
	sub.w	#96,d1					;8
	lsr.w	#1,d1					;8
	and.w	#$38,d1					;8
	add.w	d1,a3					;8

	lea		pipecapscrolltbl,a6		;12		;Look up preshift to X position
	and.w	#15,d0					;8
	lsl.w	#2,d0					;12
	move.l	(a6,d0.w),a2			;20

	CAPLINE1	80*0,160*0			;224
	CAPLINE2	80*1,160*1			;304
	movem.l	(a2)+,d4-d6/a4-a6		;60		;Read pipe Mask and Planes 1+2+3+4 for 32 pixels
	CAPLINE3	80*2,160*2			;168	;8 lines, 1344 cycles
	CAPLINE3	80*3,160*3
	CAPLINE3	80*4,160*4
	CAPLINE3	80*5,160*5
	CAPLINE3	80*6,160*6
	CAPLINE3	80*7,160*7
	CAPLINE3	80*8,160*8
	CAPLINE3	80*9,160*9
	movem.l	(a2)+,d4-d6				;36		;Read pipe Mask and Planes 1+2+3+4 for 16 pixels
	CAPLINE4	80*2+16,160*2+16	;92		;8 lines, 736 cycles
	CAPLINE4	80*3+16,160*3+16
	CAPLINE4	80*4+16,160*4+16
	CAPLINE4	80*5+16,160*5+16
	CAPLINE4	80*6+16,160*6+16
	CAPLINE4	80*7+16,160*7+16
	CAPLINE4	80*8+16,160*8+16
	CAPLINE4	80*9+16,160*9+16
	CAPLINE2	80*10,160*10		;304
	CAPLINE1	80*11,160*11		;224
	rts

.fasterversion
	lea		pipebottomscrolltbl,a6	;12		;Look up preshift to X position
	and.w	#15,d0					;8
	lsl.w	#2,d0					;12
	move.l	(a6,d0.w),a2			;20

	movem.l	(a2)+,d0-d5				;60		;Draw pipe cap, 1016 cycles
	movem.l	d0-d5,(a1)				;56
	movem.l	(a2)+,d0-d5				;60
	movem.l	d0-d5,160*1(a1)			;60
	movem.l	(a2)+,d0-d5
	movem.l	d0-d5,160*2(a1)
	movem.l	d0-d5,160*3(a1)
	movem.l	d0-d5,160*4(a1)
	movem.l	d0-d5,160*5(a1)
	movem.l	d0-d5,160*6(a1)
	movem.l	d0-d5,160*7(a1)
	movem.l	d0-d5,160*8(a1)
	movem.l	d0-d5,160*9(a1)
	movem.l	(a2)+,d0-d5
	movem.l	d0-d5,160*10(a1)
	movem.l	(a2),d0-d5
	movem.l	d0-d5,160*11(a1)
	rts

;----------------------------------
;Routines to draw bottom cap
CAPCLIP1LINE1	MACRO				;100 cycles
	movem.l	\1+16(a3),d0-d1			;32		;Read sky for 16 pixels
	move.l	24(a2),d2				;16
	and.l	d2,d0					;8
	and.l	d2,d1					;8
	lea		36(a2),a2				;8
	movem.l	d0-d1,\2(a1)			;28		;Write
	ENDM

CAPCLIP1LINE2	MACRO				;128 cycles
	movem.l	\1+16(a3),d0-d1			;32
	lea		24(a2),a2				;8
	move.l	(a2)+,d2				;12
	and.l	d2,d0					;8
	and.l	d2,d1					;8
	or.l	(a2)+,d0				;16
	or.l	(a2)+,d1				;16	
	movem.l	d0-d1,\2(a1)			;28
	ENDM

CAPCLIP1LINE3	MACRO				;92 cycles
	movem.l	\1+16(a3),d0-d1			;32
	and.l	d4,d0					;8
	and.l	d4,d1					;8
	or.l	d5,d0					;8
	or.l	d6,d1					;8
	movem.l	d0-d1,\2(a1)			;28
	ENDM
	
;----------------------------------
;Draw bottom pipe cap, clipped for X of -32...-16
pipedrawbottomcapclip1				;616-1388 cycles, 1-3 rasters
	move.l	offscreenbse,a1			;20
	move.w	PIPE_X(a0),d0			;12

	add.w	PIPE_CAPOFFSET(a0),a1	;16		;Offset Y

	move.w	PIPE_SKYOFFSET(a0),d1	;12		;Offset to line in sky
	beq.w	.fasterversion			;10/12	;If over solid sky colour use faster routine
	move.l	skyimg,a3				;20		;Source sky
	add.w	d1,a3					;8		;And add X sky offset

	lea		pipecapscrolltbl,a6		;12		;Look up preshift to X position
	and.w	#15,d0					;8
	lsl.w	#2,d0					;12
	move.l	(a6,d0.w),a2			;20

	CAPCLIP1LINE1	80*0,160*0		;100
	CAPCLIP1LINE2	80*1,160*1		;128
	lea		24(a2),a2				;8
	movem.l	(a2)+,d4-d6				;36		;Read pipe Mask and Planes 1+2+3+4 for 16 pixels
	CAPCLIP1LINE3	80*2,160*2		;92		;8 lines, 736 cycles
	CAPCLIP1LINE3	80*3,160*3
	CAPCLIP1LINE3	80*4,160*4
	CAPCLIP1LINE3	80*5,160*5
	CAPCLIP1LINE3	80*6,160*6
	CAPCLIP1LINE3	80*7,160*7
	CAPCLIP1LINE3	80*8,160*8
	CAPCLIP1LINE3	80*9,160*9
	CAPCLIP1LINE2	80*10,160*10	;128
	CAPCLIP1LINE1	80*11,160*11	;100
	rts

.fasterversion
	lea		pipebottomscrolltbl,a6	;12		;Look up preshift to X position
	and.w	#15,d0					;8
	lsl.w	#2,d0					;12
	move.l	(a6,d0.w),a2			;20

	movem.l	16(a2),d0-d1			;32		;Draw pipe cap, 492 cycles
	movem.l	d0-d1,(a1)				;24
	movem.l	40(a2),d0-d1			;32
	movem.l	d0-d1,160*1(a1)			;28
	movem.l	64(a2),d0-d1
	movem.l	d0-d1,160*2(a1)
	movem.l	d0-d1,160*3(a1)
	movem.l	d0-d1,160*4(a1)
	movem.l	d0-d1,160*5(a1)
	movem.l	d0-d1,160*6(a1)
	movem.l	d0-d1,160*7(a1)
	movem.l	d0-d1,160*8(a1)
	movem.l	d0-d1,160*9(a1)
	movem.l	88(a2),d0-d1
	movem.l	d0-d1,160*10(a1)
	movem.l	112(a2),d0-d1
	movem.l	d0-d1,160*11(a1)
	rts

;----------------------------------
;Routines to draw bottom cap
CAPCLIP2LINE1	MACRO				;164 cycles
	movem.l	\1+8(a3),d0-d3			;48		;Read sky for 32 pixels
	move.l	12(a2),d4				;16
	and.l	d4,d0					;8
	and.l	d4,d1					;8
	move.l	24(a2),d4				;16
	and.l	d4,d2					;8
	and.l	d4,d3					;8
	lea		36(a2),a2				;8
	movem.l	d0-d3,\2(a1)			;44		;Write
	ENDM

CAPCLIP2LINE2	MACRO				;220 cycles
	movem.l	\1+8(a3),d0-d3			;48
	lea		12(a2),a2				;8
	move.l	(a2)+,d4				;12
	and.l	d4,d0					;8
	and.l	d4,d1					;8
	or.l	(a2)+,d0				;16
	or.l	(a2)+,d1				;16	
	move.l	(a2)+,d4				;12
	and.l	d4,d2					;8
	and.l	d4,d3					;8
	or.l	(a2)+,d2				;16
	or.l	(a2)+,d3				;16
	movem.l	d0-d3,\2(a1)			;44
	ENDM

CAPCLIP2LINE3	MACRO				;168 cycles
	movem.l	\1+8(a3),d0-d3			;48
	and.l	d4,d0					;8
	and.l	d4,d1					;8
	or.l	d5,d0					;8
	or.l	d6,d1					;8
	move.l	a4,d7					;4
	and.l	d7,d2					;8
	and.l	d7,d3					;8
	move.l	a5,d7					;4
	or.l	d7,d2					;8
	move.l	a6,d7					;4
	or.l	d7,d3					;8
	movem.l	d0-d3,\2(a1)			;44
	ENDM

;----------------------------------
;Draw bottom pipe cap, clipped for X of -16...0
pipedrawbottomcapclip2				;888-2336 cycles, 2-5 rasters
	move.l	offscreenbse,a1			;20
	move.w	PIPE_X(a0),d0			;12

	add.w	PIPE_CAPOFFSET(a0),a1	;16		;Offset Y

	move.w	PIPE_SKYOFFSET(a0),d1	;12		;Offset to line in sky
	beq.w	.fasterversion			;10/12	;If over solid sky colour use faster routine
	move.l	skyimg,a3				;20		;Source sky
	lea		8(a3,d1.w),a3			;12		;And add X sky offset

	lea		pipecapscrolltbl,a6		;12		;Look up preshift to X position
	and.w	#15,d0					;8
	lsl.w	#2,d0					;12
	move.l	(a6,d0.w),a2			;20

	CAPCLIP2LINE1	80*0,160*0		;164
	CAPCLIP2LINE2	80*1,160*1		;220
	lea		12(a2),a2				;8
	movem.l	(a2)+,d4-d6/a4-a6		;60		;Read pipe Mask and Planes 1+2+3+4 for 32 pixels
	CAPCLIP2LINE3	80*2,160*2		;168	;8 lines, 1344 cycles
	CAPCLIP2LINE3	80*3,160*3
	CAPCLIP2LINE3	80*4,160*4
	CAPCLIP2LINE3	80*5,160*5
	CAPCLIP2LINE3	80*6,160*6
	CAPCLIP2LINE3	80*7,160*7
	CAPCLIP2LINE3	80*8,160*8
	CAPCLIP2LINE3	80*9,160*9
	CAPCLIP2LINE2	80*10,160*10	;220
	CAPCLIP2LINE1	80*11,160*11	;164
	rts

.fasterversion
	lea		pipebottomscrolltbl,a6	;12		;Look up preshift to X position
	and.w	#15,d0					;8
	lsl.w	#2,d0					;12
	move.l	(a6,d0.w),a2			;20

	movem.l	8(a2),d0-d3				;48		;Draw pipe cap, 764 cycles
	movem.l	d0-d3,(a1)				;40
	movem.l	32(a2),d0-d3			;48
	movem.l	d0-d3,160*1(a1)			;44
	movem.l	56(a2),d0-d3
	movem.l	d0-d3,160*2(a1)
	movem.l	d0-d3,160*3(a1)
	movem.l	d0-d3,160*4(a1)
	movem.l	d0-d3,160*5(a1)
	movem.l	d0-d3,160*6(a1)
	movem.l	d0-d3,160*7(a1)
	movem.l	d0-d3,160*8(a1)
	movem.l	d0-d3,160*9(a1)
	movem.l	80(a2),d0-d3
	movem.l	d0-d3,160*10(a1)
	movem.l	104(a2),d0-d3
	movem.l	d0-d3,160*11(a1)
	rts
	
;----------------------------------
;Routines to draw bottom cap
CAPCLIP3LINE1	MACRO				;160 cycles
	movem.l	\1(a3),d0-d3			;48		;Read sky for 32 pixels
	move.l	(a2),d4					;12
	and.l	d4,d0					;8
	and.l	d4,d1					;8
	move.l	12(a2),d4				;16
	and.l	d4,d2					;8
	and.l	d4,d3					;8
	lea		36(a2),a2				;8
	movem.l	d0-d3,\2(a1)			;44		;Write
	ENDM

CAPCLIP3LINE2	MACRO				;220 cycles
	movem.l	\1(a3),d0-d3			;48
	move.l	(a2)+,d4				;12
	and.l	d4,d0					;8
	and.l	d4,d1					;8
	or.l	(a2)+,d0				;16
	or.l	(a2)+,d1				;16	
	move.l	(a2)+,d4				;12
	and.l	d4,d2					;8
	and.l	d4,d3					;8
	or.l	(a2)+,d2				;16
	or.l	(a2)+,d3				;16
	lea		12(a2),a2				;8
	movem.l	d0-d3,\2(a1)			;44
	ENDM

CAPCLIP3LINE3	MACRO				;168 cycles
	movem.l	\1(a3),d0-d3			;48
	and.l	d4,d0					;8
	and.l	d4,d1					;8
	or.l	d5,d0					;8
	or.l	d6,d1					;8
	move.l	a4,d7					;4
	and.l	d7,d2					;8
	and.l	d7,d3					;8
	move.l	a5,d7					;4
	or.l	d7,d2					;8
	move.l	a6,d7					;4
	or.l	d7,d3					;8
	movem.l	d0-d3,\2(a1)			;44
	ENDM

;----------------------------------
;Draw bottom pipe cap, clipped for X of 288...304
pipedrawbottomcapclip3				;892-2136 cycles, 2-4 rasters
	move.l	offscreenbse,a1			;20
	move.w	PIPE_X(a0),d0			;12

	lea		160-16(a1),a1			;8		;Add X screen offset
	add.w	PIPE_CAPOFFSET(a0),a1	;16		;Offset Y

	move.w	PIPE_SKYOFFSET(a0),d1	;12		;Offset to line in sky
	beq.w	.fasterversion			;10/12	;If over solid sky colour use faster routine
	move.l	skyimg,a3				;20		;Source sky
	lea		32(a3,d1.w),a3			;12		;And add X sky offset

	lea		pipecapscrolltbl,a6		;12		;Look up preshift to X position
	and.w	#15,d0					;8
	lsl.w	#2,d0					;12
	move.l	(a6,d0.w),a2			;20

	CAPCLIP3LINE1	80*0,160*0		;160
	CAPCLIP3LINE2	80*1,160*1		;220
	movem.l	(a2)+,d4-d6/a4-a6		;60		;Read pipe Mask and Planes 1+2+3+4 for 32 pixels
	lea		12(a2),a2				;8
	CAPCLIP3LINE3	80*2,160*2		;168	;8 lines, 1344 cycles
	CAPCLIP3LINE3	80*3,160*3
	CAPCLIP3LINE3	80*4,160*4
	CAPCLIP3LINE3	80*5,160*5
	CAPCLIP3LINE3	80*6,160*6
	CAPCLIP3LINE3	80*7,160*7
	CAPCLIP3LINE3	80*8,160*8
	CAPCLIP3LINE3	80*9,160*9
	CAPCLIP3LINE2	80*10,160*10	;220
	CAPCLIP3LINE1	80*11,160*11	;160
	rts

.fasterversion
	lea		pipebottomscrolltbl,a6	;12		;Look up preshift to X position
	and.w	#15,d0					;8
	lsl.w	#2,d0					;12
	move.l	(a6,d0.w),a2			;20

	movem.l	(a2),d0-d3				;44		;Draw pipe cap, 760 cycles
	movem.l	d0-d3,(a1)				;40
	movem.l	24(a2),d0-d3			;48
	movem.l	d0-d3,160*1(a1)			;44
	movem.l	48(a2),d0-d3
	movem.l	d0-d3,160*2(a1)
	movem.l	d0-d3,160*3(a1)
	movem.l	d0-d3,160*4(a1)
	movem.l	d0-d3,160*5(a1)
	movem.l	d0-d3,160*6(a1)
	movem.l	d0-d3,160*7(a1)
	movem.l	d0-d3,160*8(a1)
	movem.l	d0-d3,160*9(a1)
	movem.l	72(a2),d0-d3
	movem.l	d0-d3,160*10(a1)
	movem.l	96(a2),d0-d3
	movem.l	d0-d3,160*11(a1)
	rts

;----------------------------------
;Routines to draw bottom cap
CAPCLIP4LINE1	MACRO				;96 cycles
	movem.l	\1(a3),d0-d1			;32		;Read sky for 16 pixels
	move.l	(a2),d2					;12
	and.l	d2,d0					;8
	and.l	d2,d1					;8
	lea		36(a2),a2				;8
	movem.l	d0-d1,\2(a1)			;28		;Write
	ENDM

CAPCLIP4LINE2	MACRO				;128 cycles
	movem.l	\1(a3),d0-d1			;32
	move.l	(a2)+,d2				;12
	and.l	d2,d0					;8
	and.l	d2,d1					;8
	or.l	(a2)+,d0				;16
	or.l	(a2)+,d1				;16	
	lea		24(a2),a2				;8
	movem.l	d0-d1,\2(a1)			;28
	ENDM

CAPCLIP4LINE3	MACRO				;92 cycles
	movem.l	\1(a3),d0-d1			;32
	and.l	d4,d0					;8
	and.l	d4,d1					;8
	or.l	d5,d0					;8
	or.l	d6,d1					;8
	movem.l	d0-d1,\2(a1)			;28
	ENDM

;----------------------------------
;Draw bottom pipe cap, clipped for X of 304...320
pipedrawbottomcapclip4				;620-1392 cycles, 1-3 rasters
	move.l	offscreenbse,a1			;20
	move.w	PIPE_X(a0),d0			;12

	lea		160-8(a1),a1			;8		;Add X screen offset
	add.w	PIPE_CAPOFFSET(a0),a1	;16		;Offset Y

	move.w	PIPE_SKYOFFSET(a0),d1	;12		;Offset to line in sky
	beq.w	.fasterversion			;10/12	;If over solid sky colour use faster routine
	move.l	skyimg,a3				;20		;Source sky
	lea		40(a3,d1.w),a3			;12		;And add X sky offset

	lea		pipecapscrolltbl,a6		;12		;Look up preshift to X position
	and.w	#15,d0					;8
	lsl.w	#2,d0					;12
	move.l	(a6,d0.w),a2			;20

	CAPCLIP4LINE1	80*0,160*0		;96
	CAPCLIP4LINE2	80*1,160*1		;128
	movem.l	(a2)+,d4-d6				;36		;Read pipe Mask and Planes 1+2+3+4 for 16 pixels
	lea		24(a2),a2				;8
	CAPCLIP4LINE3	80*2,160*2		;92		;8 lines, 736 cycles
	CAPCLIP4LINE3	80*3,160*3
	CAPCLIP4LINE3	80*4,160*4
	CAPCLIP4LINE3	80*5,160*5
	CAPCLIP4LINE3	80*6,160*6
	CAPCLIP4LINE3	80*7,160*7
	CAPCLIP4LINE3	80*8,160*8
	CAPCLIP4LINE3	80*9,160*9
	CAPCLIP4LINE2	80*10,160*10	;128
	CAPCLIP4LINE1	80*11,160*11	;96
	rts

.fasterversion
	lea		pipebottomscrolltbl,a6	;12		;Look up preshift to X position
	and.w	#15,d0					;8
	lsl.w	#2,d0					;12
	move.l	(a6,d0.w),a2			;20

	movem.l	(a2),d0-d1				;28		;Draw pipe cap, 488 cycles
	movem.l	d0-d1,(a1)				;24
	movem.l	24(a2),d0-d1			;32
	movem.l	d0-d1,160*1(a1)			;28
	movem.l	48(a2),d0-d1
	movem.l	d0-d1,160*2(a1)
	movem.l	d0-d1,160*3(a1)
	movem.l	d0-d1,160*4(a1)
	movem.l	d0-d1,160*5(a1)
	movem.l	d0-d1,160*6(a1)
	movem.l	d0-d1,160*7(a1)
	movem.l	d0-d1,160*8(a1)
	movem.l	d0-d1,160*9(a1)
	movem.l	72(a2),d0-d1
	movem.l	d0-d1,160*10(a1)
	movem.l	96(a2),d0-d1
	movem.l	d0-d1,160*11(a1)
	rts

;----------------------------------
;Pipe structure
	RSRESET
PIPE_X				rs.w	1				;Pipe X coordinate
PIPE_Y				rs.w	1				;Y offset (0...70 inclusive)
PIPE_LINEOFFSET		rs.w	1				;Screen offset for first line
PIPE_CAPOFFSET		rs.w	1				;Screen offset for bottom cap
PIPE_SKYOFFSET		rs.w	1				;Offset into sky for bottom cap
PIPE_SKY1OFFSET		rs.w	1				;Offset into sky preshift images
PIPE_SKY2OFFSET		rs.w	1
PIPE_SKY3OFFSET		rs.w	1
PIPE_FUNCTOP		rs.l	1				;Functions for top pipe drawing
PIPE_FUNCTOP1		rs.l	1
PIPE_FUNCTOP2		rs.l	1
PIPE_FUNCTOP3		rs.l	1
PIPE_FUNCTOP4		rs.l	1
PIPE_FUNCBOTTOM		rs.l	1				;Functions for bottom pipe drawing
PIPE_FUNCBOTTOM1	rs.l	1
PIPE_FUNCBOTTOM2	rs.l	1
PIPE_FUNCBOTTOM3	rs.l	1
PIPE_FUNCBOTTOM4	rs.l	1
PIPE_SIZE = 60

NUMPIPES = 5								;We have up to 5 pipes on screen
PIPEXGAP = 80								;Pixels between each pixel across screen
PIPEYGAP = 48								;Vertical pixel gap in pipe
PIPEXSCORE = 118							;Award score if pipe passes this X position

;----------------------------------

	SECTION	DATA

;List of details to set pipe for Y of 20...90 (ie 71 different height offsets)
pipedetails
	dc.w	160*80,160*68,80*0,0,0,0		;20
	dc.l	a70,b70,c70,d70,e70, f0,g0,h0,i0,j0
	dc.w	160*79,160*69,80*0,0,0,0		;21
	dc.l	a69,b69,c69,d69,e69, f1,g1,h1,i1,j1
	dc.w	160*78,160*70,80*0,0,0,0		;22
	dc.l	a68,b68,c68,d68,e68, f2,g2,h2,i2,j2
	dc.w	160*77,160*71,80*0,0,0,0		;23
	dc.l	a67,b67,c67,d67,e67, f3,g3,h3,i3,j3
	dc.w	160*76,160*72,80*0,0,0,0		;24
	dc.l	a66,b66,c66,d66,e66, f4,g4,h4,i4,j4
	dc.w	160*75,160*73,80*0,0,0,0		;25
	dc.l	a65,b65,c65,d65,e65, f5,g5,h5,i5,j5
	dc.w	160*74,160*74,80*0,0,0,0		;26
	dc.l	a64,b64,c64,d64,e64, f6,g6,h6,i6,j6
	dc.w	160*73,160*75,80*0,0,0,0		;27
	dc.l	a63,b63,c63,d63,e63, f7,g7,h7,i7,j7
	dc.w	160*72,160*76,80*0,0,0,0		;28
	dc.l	a62,b62,c62,d62,e62, f8,g8,h8,i8,j8
	dc.w	160*71,160*77,80*0,0,0,0		;29
	dc.l	a61,b61,c61,d61,e61, f9,g9,h9,i9,j9
	dc.w	160*70,160*78,80*0,0,0,0		;30
	dc.l	a60,b60,c60,d60,e60, f10,g10,h10,i10,j10
	dc.w	160*69,160*79,80*0,0,0,0		;31
	dc.l	a59,b59,c59,d59,e59, f11,g11,h11,i11,j11
	dc.w	160*68,160*80,80*0,0,0,0		;32
	dc.l	a58,b58,c58,d58,e58, f12,g12,h12,i12,j12
	dc.w	160*67,160*81,80*0,0,0,0		;33
	dc.l	a57,b57,c57,d57,e57, f13,g13,h13,i13,j13
	dc.w	160*66,160*82,80*0,0,0,0		;34
	dc.l	a56,b56,c56,d56,e56, f14,g14,h14,i14,j14
	dc.w	160*65,160*83,80*0,0,0,0		;35
	dc.l	a55,b55,c55,d55,e55, f15,g15,h15,i15,j15
	dc.w	160*64,160*84,80*0,0,0,0		;36
	dc.l	a54,b54,c54,d54,e54, f16,g16,h16,i16,j16
	dc.w	160*63,160*85,80*0,0,0,0		;37
	dc.l	a53,b53,c53,d53,e53, f17,g17,h17,i17,j17
	dc.w	160*62,160*86,80*0,0,0,0		;38
	dc.l	a52,b52,c52,d52,e52, f18,g18,h18,i18,j18
	dc.w	160*61,160*87,80*0,0,0,0		;39
	dc.l	a51,b51,c51,d51,e51, f19,g19,h19,i19,j19
	dc.w	160*60,160*88,80*0,0,0,0		;40
	dc.l	a50,b50,c50,d50,e50, f20,g20,h20,i20,j20
	dc.w	160*59,160*89,80*0,0,0,0		;41
	dc.l	a49,b49,c49,d49,e49, f21,g21,h21,i21,j21
	dc.w	160*58,160*90,80*0,0,0,0		;42
	dc.l	a48,b48,c48,d48,e48, f22,g22,h22,i22,j22
	dc.w	160*57,160*91,80*0,0,0,0		;43
	dc.l	a47,b47,c47,d47,e47, f23,g23,h23,i23,j23
	dc.w	160*56,160*92,80*0,0,0,0		;44
	dc.l	a46,b46,c46,d46,e46, f24,g24,h24,i24,j24
	dc.w	160*55,160*93,80*0,0,0,0		;45
	dc.l	a45,b45,c45,d45,e45, f25,g25,h25,i25,j25
	dc.w	160*54,160*94,80*0,0,0,0		;46
	dc.l	a44,b44,c44,d44,e44, f26,g26,h26,i26,j26
	dc.w	160*53,160*95,80*0,0,0,0		;47
	dc.l	a43,b43,c43,d43,e43, f27,g27,h27,i27,j27
	dc.w	160*52,160*96,80*0,0,0,0		;48
	dc.l	a42,b42,c42,d42,e42, f28,g28,h28,i28,j28
	dc.w	160*51,160*97,80*0,0,0,0		;49
	dc.l	a41,b41,c41,d41,e41, f29,g29,h29,i29,j29
	dc.w	160*50,160*98,80*0,0,0,0		;50
	dc.l	a40,b40,c40,d40,e40, f30,g30,h30,i30,j30
	dc.w	160*49,160*99,80*0,0,0,0		;51
	dc.l	a39,b39,c39,d39,e39, f31,g31,h31,i31,j31
	dc.w	160*48,160*100,80*0,24*0,0,0	;52
	dc.l	a38,b38,c38,d38,e38, f32,g32,h32,i32,j32
	dc.w	160*47,160*101,80*6,24*1,0,0	;53
	dc.l	a37,b37,c37,d37,e37, f33,g33,h33,i33,j33
	dc.w	160*46,160*102,80*7,24*2,0,0	;54
	dc.l	a36,b36,c36,d36,e36, f34,g34,h34,i34,j34
	dc.w	160*45,160*103,80*8,24*3,0,0	;55
	dc.l	a35,b35,c35,d35,e35, f35,g35,h35,i35,j35
	dc.w	160*44,160*104,80*9,24*4,0,0	;56
	dc.l	a34,b34,c34,d34,e34, f36,g36,h36,i36,j36
	dc.w	160*43,160*105,80*10,24*5,0,0	;57
	dc.l	a33,b33,c33,d33,e33, f37,g37,h37,i37,j37
	dc.w	160*42,160*106,80*11,24*6,0,0	;58
	dc.l	a32,b32,c32,d32,e32, f38,g38,h38,i38,j38
	dc.w	160*41,160*107,80*12,24*7,0,0	;59
	dc.l	a31,b31,c31,d31,e31, f39,g39,h39,i39,j39
	dc.w	160*40,160*108,80*13,24*8,0,0	;60
	dc.l	a30,b30,c30,d30,e30, f40,g40,h40,i40,j40
	dc.w	160*39,160*109,80*14,24*9,0,0	;61
	dc.l	a29,b29,c29,d29,e29, f41,g41,h41,i41,j41
	dc.w	160*38,160*110,80*15,24*10,0,0	;62
	dc.l	a28,b28,c28,d28,e28, f42,g42,h42,i42,j42
	dc.w	160*37,160*111,80*16,0,24*0,0	;63
	dc.l	a27,b27,c27,d27,e27, f43,g43,h43,i43,j43
	dc.w	160*36,160*112,80*17,0,24*1,0	;64
	dc.l	a26,b26,c26,d26,e26, f44,g44,h44,i44,j44
	dc.w	160*35,160*113,80*18,0,24*2,0	;65
	dc.l	a25,b25,c25,d25,e25, f45,g45,h45,i45,j45
	dc.w	160*34,160*114,80*19,0,24*3,0	;66
	dc.l	a24,b24,c24,d24,e24, f46,g46,h46,i46,j46
	dc.w	160*33,160*115,80*20,0,24*4,0	;67
	dc.l	a23,b23,c23,d23,e23, f47,g47,h47,i47,j47
	dc.w	160*32,160*116,80*21,0,24*5,0	;68
	dc.l	a22,b22,c22,d22,e22, f48,g48,h48,i48,j48
	dc.w	160*31,160*117,80*22,0,24*6,0	;69
	dc.l	a21,b21,c21,d21,e21, f49,g49,h49,i49,j49
	dc.w	160*30,160*118,80*23,0,24*7,0	;70
	dc.l	a20,b20,c20,d20,e20, f50,g50,h50,i50,j50
	dc.w	160*29,160*119,80*24,0,24*8,0	;71
	dc.l	a19,b19,c19,d19,e19, f51,g51,h51,i51,j51
	dc.w	160*28,160*120,80*25,0,24*9,0	;72
	dc.l	a18,b18,c18,d18,e18, f52,g52,h52,i52,j52
	dc.w	160*27,160*121,80*26,0,24*10,0	;73
	dc.l	a17,b17,c17,d17,e17, f53,g53,h53,i53,j53
	dc.w	160*26,160*122,80*27,0,24*11,0	;74
	dc.l	a16,b16,c16,d16,e16, f54,g54,h54,i54,j54
	dc.w	160*25,160*123,80*28,0,24*12,0	;75
	dc.l	a15,b15,c15,d15,e15, f55,g55,h55,i55,j55
	dc.w	160*24,160*124,80*29,0,24*13,0	;76
	dc.l	a14,b14,c14,d14,e14, f56,g56,h56,i56,j56
	dc.w	160*23,160*125,80*30,0,24*14,0	;77
	dc.l	a13,b13,c13,d13,e13, f57,g57,h57,i57,j57
	dc.w	160*22,160*126,80*31,0,24*15,0	;78
	dc.l	a12,b12,c12,d12,e12, f58,g58,h58,i58,j58
	dc.w	160*21,160*127,80*32,0,24*16,0	;79
	dc.l	a11,b11,c11,d11,e11, f59,g59,h59,i59,j59
	dc.w	160*20,160*128,80*33,0,24*17,0	;80
	dc.l	a10,b10,c10,d10,e10, f60,g60,h60,i60,j60
	dc.w	160*19,160*129,80*34,0,24*18,0	;81
	dc.l	a9,b9,c9,d9,e9, f61,g61,h61,i61,j61
	dc.w	160*18,160*130,80*35,0,0,24*0	;82
	dc.l	a8,b8,c8,d8,e8, f62,g62,h62,i62,j62
	dc.w	160*17,160*131,80*36,0,0,24*1	;83
	dc.l	a7,b7,c7,d7,e7, f63,g63,h63,i63,j63
	dc.w	160*16,160*132,80*37,0,0,24*2	;84
	dc.l	a6,b6,c6,d6,e6, f64,g64,h64,i64,j64
	dc.w	160*15,160*133,80*38,0,0,24*3	;85
	dc.l	a5,b5,c5,d5,e5, f65,g65,h65,i65,j65
	dc.w	160*14,160*134,80*39,0,0,24*4	;86
	dc.l	a4,b4,c4,d4,e4, f66,g66,h66,i66,j66
	dc.w	160*13,160*135,80*40,0,0,24*5	;87
	dc.l	a3,b3,c3,d3,e3, f67,g67,h67,i67,j67
	dc.w	160*12,160*136,80*41,0,0,24*6	;88
	dc.l	a2,b2,c2,d2,e2, f68,g68,h68,i68,j68
	dc.w	160*11,160*137,80*42,0,0,24*7	;89
	dc.l	a1,b1,c1,d1,e1, f69,g69,h69,i69,j69
	dc.w	160*10,160*138,80*43,0,0,24*8	;90
	dc.l	a0,b0,c0,d0,e0, f70,g70,h70,i70,j70

pipetopscrolltbl
	dc.l	pipetoppreshift+(144*0)
	dc.l	pipetoppreshift+(144*1)
	dc.l	pipetoppreshift+(144*2)
	dc.l	pipetoppreshift+(144*3)
	dc.l	pipetoppreshift+(144*4)
	dc.l	pipetoppreshift+(144*5)
	dc.l	pipetoppreshift+(144*6)
	dc.l	pipetoppreshift+(144*7)
	dc.l	pipetoppreshift+(144*8)
	dc.l	pipetoppreshift+(144*9)
	dc.l	pipetoppreshift+(144*10)
	dc.l	pipetoppreshift+(144*11)
	dc.l	pipetoppreshift+(144*12)
	dc.l	pipetoppreshift+(144*13)
	dc.l	pipetoppreshift+(144*14)
	dc.l	pipetoppreshift+(144*15)

pipebottomscrolltbl
	dc.l	pipebottompreshift+(120*0)
	dc.l	pipebottompreshift+(120*1)
	dc.l	pipebottompreshift+(120*2)
	dc.l	pipebottompreshift+(120*3)
	dc.l	pipebottompreshift+(120*4)
	dc.l	pipebottompreshift+(120*5)
	dc.l	pipebottompreshift+(120*6)
	dc.l	pipebottompreshift+(120*7)
	dc.l	pipebottompreshift+(120*8)
	dc.l	pipebottompreshift+(120*9)
	dc.l	pipebottompreshift+(120*10)
	dc.l	pipebottompreshift+(120*11)
	dc.l	pipebottompreshift+(120*12)
	dc.l	pipebottompreshift+(120*13)
	dc.l	pipebottompreshift+(120*14)
	dc.l	pipebottompreshift+(120*15)

pipecapscrolltbl
	dc.l	pipecappreshift+(180*0)
	dc.l	pipecappreshift+(180*1)
	dc.l	pipecappreshift+(180*2)
	dc.l	pipecappreshift+(180*3)
	dc.l	pipecappreshift+(180*4)
	dc.l	pipecappreshift+(180*5)
	dc.l	pipecappreshift+(180*6)
	dc.l	pipecappreshift+(180*7)
	dc.l	pipecappreshift+(180*8)
	dc.l	pipecappreshift+(180*9)
	dc.l	pipecappreshift+(180*10)
	dc.l	pipecappreshift+(180*11)
	dc.l	pipecappreshift+(180*12)
	dc.l	pipecappreshift+(180*13)
	dc.l	pipecappreshift+(180*14)
	dc.l	pipecappreshift+(180*15)

pipeskyscrolltbl
	dc.w	144*0,264*0,456*0,216*0
	dc.w	144*1,264*1,456*1,216*1
	dc.w	144*2,264*2,456*2,216*2
	dc.w	144*3,264*3,456*3,216*3
	dc.w	144*4,264*4,456*4,216*4
	dc.w	144*5,264*5,456*5,216*5
	dc.w	144*6,264*6,456*6,216*6
	dc.w	144*7,264*7,456*7,216*7
	dc.w	144*8,264*8,456*8,216*8
	dc.w	144*9,264*9,456*9,216*9
	dc.w	144*10,264*10,456*10,216*10
	dc.w	144*11,264*11,456*11,216*11
	dc.w	144*12,264*12,456*12,216*12
	dc.w	144*13,264*13,456*13,216*13
	dc.w	144*14,264*14,456*14,216*14
	dc.w	144*15,264*15,456*15,216*15
	dc.w	144*0,264*16,456*16,216*16
	dc.w	144*1,264*17,456*17,216*17
	dc.w	144*2,264*18,456*18,216*18
	dc.w	144*3,264*19,456*19,216*19
	dc.w	144*4,264*20,456*20,216*20
	dc.w	144*5,264*21,456*21,216*21
	dc.w	144*6,264*22,456*22,216*22
	dc.w	144*7,264*23,456*23,216*23
	dc.w	144*8,264*24,456*24,216*24
	dc.w	144*9,264*25,456*25,216*25
	dc.w	144*10,264*26,456*26,216*26
	dc.w	144*11,264*27,456*27,216*27
	dc.w	144*12,264*28,456*28,216*28
	dc.w	144*13,264*29,456*29,216*29
	dc.w	144*14,264*30,456*30,216*30
	dc.w	144*15,264*31,456*31,216*31
	dc.w	144*0,264*32,456*0,216*32
	dc.w	144*1,264*33,456*1,216*33
	dc.w	144*2,264*34,456*2,216*34
	dc.w	144*3,264*35,456*3,216*35
	dc.w	144*4,264*36,456*4,216*36
	dc.w	144*5,264*37,456*5,216*37
	dc.w	144*6,264*38,456*6,216*38
	dc.w	144*7,264*39,456*7,216*39
	dc.w	144*8,264*40,456*8,216*40
	dc.w	144*9,264*41,456*9,216*41
	dc.w	144*10,264*42,456*10,216*42
	dc.w	144*11,264*43,456*11,216*43
	dc.w	144*12,264*44,456*12,216*44
	dc.w	144*13,264*45,456*13,216*45
	dc.w	144*14,264*46,456*14,216*46
	dc.w	144*15,264*47,456*15,216*47
	dc.w	144*0,264*48,456*16,216*48
	dc.w	144*1,264*49,456*17,216*49
	dc.w	144*2,264*50,456*18,216*50
	dc.w	144*3,264*51,456*19,216*51
	dc.w	144*4,264*52,456*20,216*52
	dc.w	144*5,264*53,456*21,216*53
	dc.w	144*6,264*54,456*22,216*54
	dc.w	144*7,264*55,456*23,216*55
	dc.w	144*8,264*56,456*24,216*56
	dc.w	144*9,264*57,456*25,216*57
	dc.w	144*10,264*58,456*26,216*58
	dc.w	144*11,264*59,456*27,216*59
	dc.w	144*12,264*60,456*28,216*60
	dc.w	144*13,264*61,456*29,216*61
	dc.w	144*14,264*62,456*30,216*62
	dc.w	144*15,264*63,456*31,216*63
	dc.w	144*0,264*64,456*0,216*0
	dc.w	144*1,264*65,456*1,216*1
	dc.w	144*2,264*66,456*2,216*2
	dc.w	144*3,264*67,456*3,216*3
	dc.w	144*4,264*68,456*4,216*4
	dc.w	144*5,264*69,456*5,216*5
	dc.w	144*6,264*70,456*6,216*6
	dc.w	144*7,264*71,456*7,216*7
	dc.w	144*8,264*72,456*8,216*8
	dc.w	144*9,264*73,456*9,216*9
	dc.w	144*10,264*74,456*10,216*10
	dc.w	144*11,264*75,456*11,216*11
	dc.w	144*12,264*76,456*12,216*12
	dc.w	144*13,264*77,456*13,216*13
	dc.w	144*14,264*78,456*14,216*14
	dc.w	144*15,264*79,456*15,216*15
	dc.w	144*0,264*80,456*16,216*16
	dc.w	144*1,264*81,456*17,216*17
	dc.w	144*2,264*82,456*18,216*18
	dc.w	144*3,264*83,456*19,216*19
	dc.w	144*4,264*84,456*20,216*20
	dc.w	144*5,264*85,456*21,216*21
	dc.w	144*6,264*86,456*22,216*22
	dc.w	144*7,264*87,456*23,216*23
	dc.w	144*8,264*88,456*24,216*24
	dc.w	144*9,264*89,456*25,216*25
	dc.w	144*10,264*90,456*26,216*26
	dc.w	144*11,264*91,456*27,216*27
	dc.w	144*12,264*92,456*28,216*28
	dc.w	144*13,264*93,456*29,216*29
	dc.w	144*14,264*94,456*30,216*30
	dc.w	144*15,264*95,456*31,216*31
	dc.w	144*0,264*96,456*0,216*32
	dc.w	144*1,264*97,456*1,216*33
	dc.w	144*2,264*98,456*2,216*34
	dc.w	144*3,264*99,456*3,216*35
	dc.w	144*4,264*100,456*4,216*36
	dc.w	144*5,264*101,456*5,216*37
	dc.w	144*6,264*102,456*6,216*38
	dc.w	144*7,264*103,456*7,216*39
	dc.w	144*8,264*104,456*8,216*40
	dc.w	144*9,264*105,456*9,216*41
	dc.w	144*10,264*106,456*10,216*42
	dc.w	144*11,264*107,456*11,216*43
	dc.w	144*12,264*108,456*12,216*44
	dc.w	144*13,264*109,456*13,216*45
	dc.w	144*14,264*110,456*14,216*46
	dc.w	144*15,264*111,456*15,216*47
	dc.w	144*0,264*112,456*16,216*48
	dc.w	144*1,264*113,456*17,216*49
	dc.w	144*2,264*114,456*18,216*50
	dc.w	144*3,264*115,456*19,216*51
	dc.w	144*4,264*116,456*20,216*52
	dc.w	144*5,264*117,456*21,216*53
	dc.w	144*6,264*118,456*22,216*54
	dc.w	144*7,264*119,456*23,216*55
	dc.w	144*8,264*120,456*24,216*56
	dc.w	144*9,264*121,456*25,216*57
	dc.w	144*10,264*122,456*26,216*58
	dc.w	144*11,264*123,456*27,216*59
	dc.w	144*12,264*124,456*28,216*60
	dc.w	144*13,264*125,456*29,216*61
	dc.w	144*14,264*126,456*30,216*62
	dc.w	144*15,264*127,456*31,216*63

;----------------------------------

	SECTION	BSS

pipecheck		ds.w	1					;Y offset scroller check value
pipes			ds.b	PIPE_SIZE*NUMPIPES	;Pipe structures
	EVEN
