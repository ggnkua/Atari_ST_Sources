**********************************
; Animation Replay routine (SPACE JUNK CHARACTER SPECIFIC !!!!!!)
; Done by FEDDY! (BANANA KICKBOXER DESIGNZ for IMAGITEC DESIGN!)
; Various animation routines that are used, to play an anim
; 1. Set the parameters for Jinit_Anim, and call it.
; 2. Call ANIM_VBL, Syncronize with some sort of timer.
; 3. The ANIM_VBL returns 0, if the animation is not finished, and -1 if finished

**********************************
;d7-Ping PONG !  (SET -1 to do ping pong)
;a0-Points to start of anim file
;a1-Points to pallete dest
;a2-Points to screen1
;a3-Points to screen2
Jinit_Anim
	Movem.l	d0-a6,-(sp)
	Clr.l	JbackwardsTablep1	
	Clr.l	JbackwardsTablep2	
	Clr.l	Janim_Pallete_Pointer	
	Clr.l	Janim_Frame_Pointer	
	Clr.l	Janim_Frame_Pointer_Save
	Clr.b	Jinit_Anim_Flag		
	Clr.b	JPing_Pong_Flag1	
	Clr.b	JPing_Pong_Flag2	
	Clr.b	JInit_Color		


	Move.b	d7,JPing_Pong_Flag1
	Move.b	d7,JPing_Pong_Flag2
	Lea	JbackwardsTable,a5
	Move.l	#-1,(a5)+
	Pea	(a0)
.Loopx	Cmp.l	#"ANIM",(a0)
	Beq.s	.Found_Anim
	Cmp.l	#"FEND",(a0)
	Beq.s	.Done	
.Back	Addq.l	#2,a0
	Bra.s	.Loopx
.Found_Anim
	Move.l	a0,(a5)+
	Bra.s	.Back
	
.Done	Move.l	a5,JbackwardsTablep1
	Move.l	a5,JbackwardsTablep2

	Move.l	(sp),a0
	Move.w	#255,d0
.Loop	Move.l	(a0)+,(a1)+		Colour pallete is always 255
	Dbra	d0,.Loop
	Move.l	(sp),a0
	Move.l	#"FRAM",d0
	Bsr	Search_4chars
	Bsr	Run_Length_Decode
	Move.l	(sp),a0
	Move.l	#"ANIM",d0
	Bsr	Search_4chars
	Move.l	a0,Janim_Frame_Pointer
	Move.l	(sp),a0
	Move.l	#"PALS",d0
	Bsr	Search_4chars
	Addq.l	#4,a0
	Move.l	a0,Janim_Pallete_Pointer
	Addq.l	#4,sp
	St	Jinit_Anim_Flag
	Movem.l	(sp)+,d0-a6
	Rts

Run_Length_Decode
	Movem.l	a2-a3,-(sp)
	Addq.l	#4,a0
	Move.l	(a0)+,d0		; Length of byte-run
	Bmi.s	.Uncompressed
.ByterunLoop
	Move.b	(a0)+,d1		; Byte in d1
	Bmi.s	.Run
	Moveq	#0,d3			; Clear d3
	Move.b	d1,d3			; Length in d3
	Addq.b	#2,d3			; Add 1 for extra count byte
.Copyloop
	Move.b	(a0)+,(a2)+
	Clr.b	(a3)+			; Copy byte
	Subq.b	#1,d1
	Bge.s	.Copyloop		; Decrement loop
	Sub.l	d3,d0			; Away from total count
	Bgt.s	.ByterunLoop	
	Bra.s	.Byterunexit	
.Run	Move.b	(a0)+,d2		; byte to repeat !
.Rloop	
	Move.b	d2,(a2)+		; Byte in
	Clr.b	(a3)+
	Addq.b	#1,d1			; Decrement loop
	Ble.s	.RLoop
	Subq.l	#2,d0
	Bgt.s	.ByterunLoop
	Bra.s	.Byte_Run_Exit
.Uncompressed
	Move.b	(a0)+,(a2)+
	Clr.b	(a3)+
	Addq.l	#1,d0
	Bne.s	.Uncompressed
.Byterunexit
.Byte_run_exit
	Movem.l	(sp)+,a2-a3
	Move.l	#64000,d0
	Move.w	#$8000,d1
.Loopx	Move.b	(a2)+,d2
	Moveq	#7,d3
.Loop1	Lsr.b	#1,d2
	Bcc.s	.Nx1
	Or.w	d1,(a3)
.Nx1	Addq.l	#2,a3
	Dbra	d3,.Loop1
	Lea	-16(a3),a3
	Ror.w	#1,d1
	Bcc.s	.Nx
	Lea	16(a3),a3
.Nx	Subq.l	#1,d0
	Bne.s	.Loopx
	Move.l	#64000/4-1,d0
.Loop2	Move.l	-(a3),-(a2)
	Dbra	d0,.Loop2
	Rts

**********************************
; Syncronize with vertical blank, load a1 with the destination screen
; Address,d0=0 if not finished anim

Anim_Vbl
	Movem.l	d1-a6,-(sp)
	Tst.b	Jinit_Anim_Flag
	Beq.s	.Do_2
	Move.l	Janim_Frame_Pointer,a0
	Move.l	a0,Janim_Frame_Pointer_Save
	Cmp.l	#"FEND",(a0)
	Beq.s	.No_Anim
	Move.l	4(a0),d0
	Subq.l	#8,d0
	Addq.l	#8,a0
	Bsr	Delta_Uncompress
	Move.l	a0,Janim_Frame_Pointer
	Clr.b	Jinit_Anim_Flag
	Moveq	#0,d0
	Movem.l	(sp)+,d1-a6
	Rts
.No_Anim
	Moveq	#-1,d0
	Movem.l	(sp)+,d1-a6
	Rts

.Do_2	Move.l	Janim_Frame_Pointer_Save,a0
.Back1	Move.l	JbackwardsTablep1,a5
	Pea	(a1)
	Move.b	JPing_Pong_Flag1,d1
	Bsr	.Do
	Move.l	a5,JbackwardsTablep1
	Move.l	(sp)+,a1
	Tst.l	d0
	Bne.s	.Anim_Done1
	Move.l	a0,Janim_Frame_Pointer_Save
.BACK2	Move.l	JbackwardsTablep2,a5
	Move.b	JPing_Pong_Flag2,d1
	Bsr	.Do
	Move.l	a5,JbackwardsTablep2
	Tst.l	d0
	Bne.s	.Anim_Done2
	Move.l	a0,Janim_Frame_Pointer
	Moveq	#0,d0
	Movem.l	(sp)+,d1-a6
	Rts

.Anim_Done1
	Not.b	JPing_Pong_Flag1
	Bne	.No_Anim
	Move.l	JbackwardsTablep1,a5
	Move.l	-(a5),a0
	Move.l	a5,JbackwardsTablep1
	BRA	.BACK1

.Anim_Done2
	Not.b	JPing_Pong_Flag2
	Bne	.No_Anim
	Move.l	JbackwardsTablep2,a5
	Move.l	-(a5),a0
	Move.l	a5,JbackwardsTablep2
	Bra	.Back2

.Do	Cmp.l	#"FEND",(a0)
	Beq.s	.Anim_Finished
	Move.l	4(a0),d0
	Subq.l	#8,d0
	Addq.l	#8,a0
	Tst.b	d1
	Bsr	Delta_Uncompress1
	Moveq	#0,d0
	Rts
.Anim_Finished
	Moveq	#-1,d0
	Rts

Ping_Pong_Vbl
	Bsr	DELTA_UNCOMPRESS
.Ping_Pong_Vbl
	Move.l	-(a5),a0
	Tst.l	(a5)
	Bmi.s	.Done_Anim	
	Rts
.Done_Anim
	Addq.l	#4,sp
	Move.l	#-1,d0
	Rts

Delta_Uncompress1
	Beq.s	Ping_Pong_Vbl
Delta_Uncompress
	Cmp.l	#"FEND",(A0)
	Beq.s	.Exit
	Cmp.l	#"ANIM",(A0)
	BNE.s	.Cont
.Exit	RTS
.Cont	Move.w	(a0)+,d0
	Jmp	.Type(pc,d0*2)

.Type	Bra.s	Skip_Operation
	Bra.s	Run_Operation
	Bra.s	Copy_Operation
	
Skip_Operation
	Moveq	#0,d1
	Move.w	(a0)+,d1
	Lea	(a1,d1.l*2),a1
	Bra.s	Delta_Uncompress
Run_Operation
	Move.w	(a0)+,d0
	Move.w	(a0)+,d1
.Loop	Eor.w	d1,(a1)+
	Subq.w	#1,d0
	Bne.s	.Loop
	Bra.s	Delta_Uncompress
	
Copy_Operation
	Move.w	(a0)+,d0
	Moveq	#0,d6
	Move.w	d0,d6
.Loop	Move.w	(a0)+,d1
	Eor.w	d1,(a1)+
	Subq.w	#1,d0
	Bne.s	.Loop
	Bra.s	Delta_Uncompress

Search_4chars
	Cmp.l	(a0),d0
	Beq.s	.Found
	Addq.l	#2,a0
	Bra.s	Search_4chars
.Found	Move.l	4(a0),d0		Get length of hunk !
	Rts

;CALL THIS AT THE SCREEN SWAP!

Copy_Janim_Pallete
	Tst.b	Jinit_Anim_Flag
	Bne.s	.Done
	Tst.b	JPing_Pong_Flag2
	Beq.s	Ping_Pong_Color
	Move.l	Janim_Pallete_Pointer(pc),a0
	Lea	$ff9800.l,a1
	Move.w	#176-1,d0
.Loop	Move.l	(a0)+,(a1)+
	Dbra	d0,.Loop
	Move.l	a0,Janim_Pallete_Pointer
.Done	Rts



Ping_Pong_Color
	Tst.b	JInit_Color
	Bne.s	.Yes
	St	JInit_Color
	Sub.l	#176*4*2,Janim_Pallete_Pointer
.Yes	Move.l	Janim_Pallete_Pointer(pc),a0
	Lea	176*4(a0),a0
	Lea	$ff9800.l,a1
	Lea	176*4(a1),a1
	Move.w	#176-1,d0
.Loop	Move.l	-(a0),-(a1)
	Dbra	d0,.Loop
	Lea	-176*4(a0),a0
	Move.l	a0,Janim_Pallete_Pointer
.Done	Rts
	


JbackwardsTablep1	Ds.l	1
JbackwardsTablep2	Ds.l	1
JbackwardsTable		Ds.l	200
Janim_Pallete_Pointer	Ds.l	1
Janim_Frame_Pointer	Ds.l	2
Janim_Frame_Pointer_Save	Ds.l	2
Jinit_Anim_Flag		Ds.b	1
JPing_Pong_Flag1		Ds.b	1
JPing_Pong_Flag2		Ds.b	1
JInit_Color		Ds.b	1
	Even

