; PC anim converter
; Converts seperate LBM pics to a delta compressed LBM file
	Include	E:\Includes\Systregs.Inc
	Include	FileSelc.s

Print	Macro
	Move.l	#\1,-(sp)
	Move.w	#$9,-(sp)
	Trap	#1
	Addq.l	#6,sp
	Endm

Input	Macro
	Pea	\1
	Move.w	#$a,-(sp)
	Trap	#1
	Addq.l	#6,sp
	Endm

My_Start	
	Print		Intro_Text
	Move.l		#$4ffff,d0
.Loop	Subq.l		#1,d0
	Bne.s	.LOOP

	Bsr		File_Select
	Lea		Full_File_Name,a0
	Lea		Anim_Name,a1
	Lea		Fuck_Off_LBM_Name,a2
.Find_Zero
	MOve.b	(a0),(a1)+
	MOve.b	(a0)+,(a2)+
	Bne.s	.Find_Zero

	Bsr	Main
	Print	Replay_Text
	Input	Bool-2
	Cmp.b	#"Y",Bool
	Beq	Go_Example
	Cmp.b	#"y",Bool
	Beq	Go_Example
No_Example
	Print	Save_Text
	Move.l		#$4ffff,d0
.Loop	Subq.l		#1,d0
	Bne.s	.LOOP
	
	Move.l	#".FAN",extension	
	Bsr		File_Select
	Lea		Full_File_Name,a0
	Lea	Anim_Creation,a1
	Move.l	Last_Address,a2
	Bsr		Save_File
	Print	Delete_Text
	Input	Bool-2
	Move.w	#1,Current_Anim
	Cmp.b	#"Y",Bool
	Beq	Delete_Lbms
	Cmp.b	#"y",Bool
	Beq	Delete_Lbms
	Bra	Quit

Delete_Lbms
	Pea		Fuck_Off_LBM_Name
	Move.w		#65,-(sp)
	Trap		#1
	Addq.l		#6,sp
	Tst.l		d0
	Bmi		.Done
	Lea		Fuck_Off_LBM_Name,a2
	Addq.w	#1,Current_Anim
	Moveq	#0,d0
	Move.w	Current_Anim,d0
	Lea	FUCK_OFF_LBM_NAME,a1
.Find	Cmp.b	#".",(a1)+
	Bne.s	.Find
	Subq.l	#5,a1
	Divu	#1000,d0
	Add.b	#"0",d0
	Move.b	d0,(a1)+
	Clr.w	d0
	Swap	d0
	Divu	#100,d0
	Add.b	#"0",d0
	Move.b	d0,(a1)+
	Clr.w	d0
	Swap	d0
	Divu	#10,d0
	Add.b	#"0",d0
	Move.b	d0,(a1)+
	Clr.w	d0
	Swap	d0
	Add.b	#"0",d0
	Move.b	d0,(a1)+
	Bra	Delete_Lbms
	


.Done	Bra	Quit



 


Go_Example
	Pea	No_Example(pc)
	Bra	Example

Main	Bsr	Load_Init_File
.Loop	Bsr	Load_Lbm_File
	Bne	Ready_To_Save
	Sub.l	a2,a2
	Bsr	DecodeVga
	Bsr	Convert_Vga
	Bsr	Eor_Screen
	Bsr	SaVe_Difference
	Bsr	Move_To_Eor_Buffer
	Subq.w	#1,Files
;	Beq	Ready_To_Save
	Bra.s	.Loop
Ready_To_Save
	Move.l	Creationp,a6
	Move.l	#"FEND",(A6)+
	Move.l	a6,Last_Address
	Rts
	
Files	Dc.w	20

SaVe_Difference
	Move.l	Creationp,a6
	Lea	Eor_BUFFER,a0
	Move.l	a6,-(sp)
	Bsr.s	.Do
	Move.l	a6,Creationp
	Move.l	(sp)+,a5
	Sub.l	a5,a6
 	Move.l	a6,4(a5)
	Rts
.Do	Move.l	#"ANIM",(a6)+
	Clr.l	(a6)+
	Move.w	#64000/2,d7
Delta_Compress
	Move.w	(a0),d0
	Beq	.Maybe_Skip
.Not_skip
	Cmp.w	2(a0),d0
	Beq	Run_Op
	Bra	Copy_Op
.Maybe_Skip
	Cmp.w	2(a0),d0
	Bne	.Not_skip
	BRA	SKIP_OP

Run_Op	Move.b	#1,d3			Type Run !
	Move.w	#1,(a6)+		Type 0 (skip)
	Moveq	#0,d1
.Loop	Move.w	(a0)+,d0
	Cmp.w	(a0),d0
	Bne.s	.Done
	Addq.w	#1,d1
	Subq.w	#1,d7
	Beq	Return_Delta
	Bra.s	.Loop
.Done	Addq.w	#1,d1
	Move.w	d1,(a6)+
	Move.w	d0,(a6)+
	Bra	Delta_Compress

Copy_Op	Move.b	#2,d3			Type Run !
	Move.w	#2,(a6)+		Type 0 (skip)
	Moveq	#0,d1
	Pea	(a6)
	Addq.L	#2,a6
.Loop	Move.w	(a0)+,d0
	Cmp.w	(a0),d0
	Beq.s	.Done
	Move.w	d0,(a6)+
	Addq.w	#1,d1
	Subq.w	#1,d7
	Beq	Return_Delta
	Bra.s	.Loop
.Done	Addq.w	#1,d1
	Move.w	d0,(a6)+
	Move.l	(sp)+,a5
	Move.w	d1,(a5)+
	Bra	Delta_Compress

Skip_Op
	Move.b	#0,d3			Type skip !
	Move.w	#0,(a6)+		Type 0 (skip)
	Moveq	#0,d1
.Loop	Move.w	(a0)+,d0
	Cmp.w	(a0),d0
	Bne.s	.Done
	Addq.w	#1,d1
	Subq.w	#1,d7
	Beq.s	Return_Delta
	Bra.s	.Loop
.Done	Addq.w	#1,d1
	Move.w	d1,(a6)+
	Bra	Delta_Compress

Return_Delta	
	Cmp.b	#0,d3
	Bne.s	.Not_Skip
;	Addq.w	#1,d1
	Move.w	d1,(a6)+
	Rts
.Not_Skip	
	Cmp.b	#1,d3
	Bne.s	.Not_Run
;	Addq.w	#1,d1
	Move.w	d1,(a6)+
	Move.w	d0,(a6)+
	Rts
.Not_Run
;	Addq.w	#1,d1
	Move.w	d0,(a6)+
	MOve.l	(sp)+,a5
	Move.w	d1,(a5)
	Rts

Eor_Screen
	Lea	Convert_Buffer,a0
	Lea	Eor_BUFFER,a1
	Move.w	#64000-1,d0
.Loop	Move.b	(a0)+,d1
	Eor.b	d1,(a1)+
	Dbra	d0,.Loop
	Rts
	
Move_To_Eor_Buffer	
	Lea	CONVERT_Buffer,a0
	Lea	Eor_Buffer,a1
	Move.w	#64000-1,d0
.Loop	Move.b	(a0)+,(a1)+
	Dbra	d0,.Loop
	Rts

Load_Init_File
	Lea	Anim_Name(pc),a0
	Bsr	Load_LBM_File	
	Bne	Quit
	Lea	Anim_Creation,a2
	Bsr	Decode_InitVga
	Move.l	a2,Creationp
	Bsr	Convert_Vga
	Bsr	Move_To_Eor_Buffer
	Rts
	
	
Quit	Clr.w	-(sp)
	Trap	#1
	

Load_LBM_File	
	Lea	Anim_Name,a0
	Lea	File_Buffer,a1
	Bsr	Load_File
	Bmi	No_More
	Addq.w	#1,Current_Anim
	Moveq	#0,d0
	Move.w	Current_Anim,d0
	Lea	Anim_Name,a1
.Find	Cmp.b	#".",(a1)+
	Bne.s	.Find
	Subq.l	#5,a1
	Divu	#1000,d0
	Add.b	#"0",d0
	Move.b	d0,(a1)+
	Clr.w	d0
	Swap	d0
	Divu	#100,d0
	Add.b	#"0",d0
	Move.b	d0,(a1)+
	Clr.w	d0
	Swap	d0
	Divu	#10,d0
	Add.b	#"0",d0
	Move.b	d0,(a1)+
	Clr.w	d0
	Swap	d0
	Add.b	#"0",d0
	Move.b	d0,(a1)+
	Moveq	#0,d0
No_More	Rts

Load_File
	Move.l	a1,-(sp)
	Move.w	#0,-(sp)		
	Move.l	a0,-(sp)
	Move.w	#$3d,-(sp)		
	Trap	#1			
	Addq.l	#8,sp			
	Tst.l	d0
	Bmi	Cant_Open
	Move.w	d0,Handle		
	Move.l	#$80000,-(sp)		
	Move.w	Handle,-(sp)		
	Move.w	#$3f,-(sp)
	Trap	#1
	Lea	12(sp),sp
	Subq.l	#4,sp	
	Tst.l	d0
	Bmi	Cant_Open
	Addq.l	#4,sp	
	Move.w	Handle,-(sp)
	Move.w	#$3e,-(sp)		
	Trap	#1
	Addq.l	#4,sp
	Moveq	#0,d0
	Rts
;a0-File name
;a1-Start
;a2-End

Save_File
	Movem.l	a0-a2,-(sp)
	Move.w	#0,-(sp)
	PEa	(a0)
	Move.w	#60,-(sp)
	Trap	#1
	Addq.l	#8,sp

	Movem.l	(SP),a0-a2
	Move.w	d0,Handle		
	Movem.l	4(sp),d0-d1
	Sub.l	d0,d1
	Move.l	d0,-(sp)
	Move.l	d1,-(sp)		
	Move.w	Handle,-(sp)		
	Move.w	#$40,-(sp)
	Trap	#1
	Lea	12(sp),sp
	Tst.l	d0
	Bmi	Cant_Open
	Move.w	Handle,-(sp)
	Move.w	#$3e,-(sp)		
	Trap	#1
	Addq.l	#4,sp
	Lea	12(sp),sp
	Moveq	#0,d0
	Rts

Cant_Open
	Addq.l	#4,sp
	Moveq	#-1,d0
	Rts


Clear_Convert_Buffer
	Lea	Convert_Buffer,a0
	MOve.w	#64000-1,d0
.Loop	Clr.b	(a0)+
	Dbra	d0,.Loop
	Rts

Convert_VGA
	Bsr	Clear_Convert_Buffer
	Move.l	#320*200,d0			; Screen size in pixels
	Lea	Decode_Buffer,a0
	Lea	Convert_Buffer,a1
Convert_Vga1
	Move.w	#$8000,d7
.Loop	Move.b	(a0)+,d1
	Moveq	#7,d6
.Loop2	Lsr.b	#1,d1
	Bcc.s	.Nx
	Or.w	d7,(a1)
.Nx	Addq.l	#2,a1
	Dbra	d6,.Loop2
	Lea	-16(a1),a1
	Ror.w	#1,d7
	Bcc.s	.Nx1
	Lea	16(a1),a1
.Nx1	Subq.l	#1,d0
	Bne.s	.Loop
	Rts	

Decode_InitVGA
	Lea	File_Buffer,a0
	Move.l	a0,-(sp)
	Lea	Decode_Buffer,a1
	Move.l	a2,d0
	Tst.l	d0
	Beq.s	.No_Cmap
.SearchCMAP
 	Cmp.l	#"CMAP",(a0)		
 	Beq.s	.Cmapfound
 	Addq.l	#2,a0
 	Bra.s	.SearchCMAP
.Cmapfound
	Addq.l	#4,a0
	Move.l	(a0)+,d0		; Length of Color data !
.Cloop	Move.b	(a0)+,d1
	Move.b	(a0)+,d2
	Move.b	(a0)+,d3		; R/G/B
	Move.b	d1,(a2)+
	Move.b	d2,(a2)+
	Clr.b	(a2)+
	Move.b	d3,(a2)+		; Format for pallete !
	Subq.l	#3,d0
	Bne.s	.Cloop

.No_Cmap
	Move.l	(sp)+,a0
.Searchbody
	Cmp.l	#"BODY",(a0)
	Beq.s	.Bodyfound		; Search for body !
	Addq.l	#2,a0
	Bra.s	.Searchbody

.Bodyfound
	Move.l	#"FRAM",(A2)+
	Addq.l	#4,a0
	Move.l	(a0)+,d0		; Length of byte-run
	Move.l	d0,(a2)+
.ByterunLoop
	Move.b	(a0),(a2)+
	Move.b	(a0)+,d1		; Byte in d1
	Bmi.s	.Run
	Moveq	#0,d3			; Clear d3
	Move.b	d1,d3			; Length in d3
	Addq.b	#2,d3			; Add 1 for extra count byte
.Copyloop
	Move.b	(a0),(a2)+
	Move.b	(a0)+,(a1)+		; Copy byte
	Subq.b	#1,d1
	Bge.s	.Copyloop		; Decrement loop
	Sub.l	d3,d0			; Away from total count
	Bgt.s	.ByterunLoop	
	Bra.s	.Byterunexit	
.Run	Move.b	(a0),(a2)+
	Move.b	(a0)+,d2		; byte to repeat !
.Rloop	Move.b	d2,(a1)+		; Byte in
	Addq.b	#1,d1			; Decrement loop
	Ble.s	.RLoop
	Subq.l	#2,d0
	Bgt.s	.ByterunLoop
.Byterunexit
	Addq.l	#2,a2
	Move.l	a2,d0
	And.l	#-2,d0
	Move.l	d0,a2
	Rts

DecodeVGA
	Lea	File_Buffer,a0
	Move.l	a0,-(sp)
	Lea	Decode_Buffer,a1
	Move.l	a2,d0
	Tst.l	d0
	Beq.s	.No_Cmap
.SearchCMAP
 	Cmp.l	#"CMAP",(a0)		
 	Beq.s	.Cmapfound
 	Addq.l	#2,a0
 	Bra.s	.SearchCMAP
.Cmapfound
	Addq.l	#4,a0
	Move.l	(a0)+,d0		; Length of Color data !
.Cloop	Move.b	(a0)+,d1
	Move.b	(a0)+,d2
	Move.b	(a0)+,d3		; R/G/B
	Move.b	d1,(a2)+
	Move.b	d2,(a2)+
	Clr.b	(a2)+
	Move.b	d3,(a2)+		; Format for pallete !
	Subq.l	#3,d0
	Bne.s	.Cloop

.No_Cmap
	Move.l	(sp)+,a0
.Searchbody
	Cmp.l	#"BODY",(a0)
	Beq.s	.Bodyfound		; Search for body !
	Addq.l	#2,a0
	Bra.s	.Searchbody

.Bodyfound
	Addq.l	#4,a0
	Move.l	(a0)+,d0		; Length of byte-run
.ByterunLoop
	Move.b	(a0)+,d1		; Byte in d1
	Bmi.s	.Run
	Moveq	#0,d3			; Clear d3
	Move.b	d1,d3			; Length in d3
	Addq.b	#2,d3			; Add 1 for extra count byte
.Copyloop
	Move.b	(a0)+,(a1)+		; Copy byte
	Subq.b	#1,d1
	Bge.s	.Copyloop		; Decrement loop
	Sub.l	d3,d0			; Away from total count
	Bgt.s	.ByterunLoop	
	Bra.s	.Byterunexit	
.Run	Move.b	(a0)+,d2		; byte to repeat !
.Rloop	Move.b	d2,(a1)+		; Byte in
	Addq.b	#1,d1			; Decrement loop
	Ble.s	.RLoop
	Subq.l	#2,d0
	Bgt.s	.ByterunLoop
.Byterunexit
	Rts

**********************************
Example
	Move.w	#-1,-(sp)
	Move.l	#My_Screen1,-(sp)
	Move.l	#My_Screen1,-(sp)
	Move.w	#5,-(sp)
	Trap	#14
	Lea	12(sp),sp
	Moveq	#$3,d0
	Bsr	Setmode

	clr.l	-(sp)
	move	#$20,-(sp)
	trap	#1
	addq	#6,sp
	Move.l	d0,Stacksave

	Move.w	sr,-(sp)	
	Or.w	#$700,sr

	MOVE.L	#MY_SCREEN1,SCREENP
	MOVE.L	#MY_SCREEN2,SCREENP+4

	Lea	Anim_Creation,a0
	Lea	Pal256,a1
	Movem.l	Screenp,a2-a3
	Bsr	Init_Anim

	Move.l	$70.w,INTSAVE
	Move.l	#NewVbl,$70.w
	Move.w	(sp)+,sr	
.Main	Bsr	Wait_Vbl
	Bsr	Wait_Vbl
	Bsr	Wait_Vbl
	Bsr	Wait_Vbl
	Bsr	Wait_Vbl
	Bsr	Wait_Vbl
	Bsr	Wait_Vbl
	Bsr	Write_Screen_Address
	Move.l	Screenp+4,a1
	Bsr	Anim_Vbl

	Movem.l	Screenp,d0-d1
	Exg	d0,d1
	Movem.l	d0-d1,Screenp
	Beq	.Main
.Exit	Move.l	INTSAVE,$70.w
	
	Move.w	Old_Mode,d0
	Bsr	Setmode
	Move.l	Stacksave,-(sp)
	Move.w	#32,-(sp)
	Trap	#1
	Addq.l	#6,sp
	Rts	
Newvbl	St	Vbl_Flag
	Rte

Wait_Vbl
	Sf	Vbl_Flag
.Loop	Tst.b	Vbl_Flag
	Beq.s	.Loop
	Rts


Setmode	Move.w	d0,-(sp)
	Move.w	#88,-(sp)
	Trap	#14
	Addq.l	#4,sp
	Move.w	d0,Old_Mode
	rts
**********************************
Write_Screen_Address
	Move.l	SCREENp,-(sp)
	Move.b	1(sp),Bp_Hi
	Move.b	2(sp),Bp_Md
	Move.b	3(sp),Bp_Lo+1
	Addq.l	#4,sp
	Rts

**********************************
; Animation Replay routine 
; Various animation routines that are used, to play an anim
; 1. Set the parameters for INIT_ANIM, and call it.
; 2. Call ANIM_VBL, Syncronize with some sort of timer.
; 3. The ANIM_VBL returns 0, if the animation is not finished, and -1 if finished

**********************************
;a0-Points to start of anim file
;a1-Points to pallete dest
;a2-Points to screen1
;a3-Points to screen2
INIT_ANIM
	Movem.l	d0-a6,-(sp)
	Pea	(a0)
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
	Move.l	a0,Anim_Frame_Pointer
	Addq.l	#4,sp
	St	Init_Anim_Flag
	Movem.l	(sp)+,d0-a6
	Rts

Run_Length_Decode
	Movem.l	a2-a3,-(sp)
	Addq.l	#4,a0
	Move.l	(a0)+,d0		; Length of byte-run
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
.Byterunexit
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
	Tst.w	Init_Anim_Flag
	Beq.s	.Do_2
	Move.l	Anim_Frame_Pointer,a0
	Move.l	a0,Anim_Frame_Pointer_Save
	Cmp.l	#"FEND",(a0)
	Beq.s	.No_Anim
	Move.l	4(a0),d0
	Subq.l	#8,d0
	Addq.l	#8,a0
	Bsr	Delta_Uncompress
	Move.l	a0,Anim_Frame_Pointer
	Clr.w	Init_Anim_Flag
	Moveq	#0,d0
	Movem.l	(sp)+,d1-a6
	Rts
.No_Anim
	Moveq	#-1,d0
	Movem.l	(sp)+,d1-a6
	Rts

.Do_2	Move.l	Anim_Frame_Pointer_Save,a0
	Pea	(a1)
	Bsr.s	.Do
	Move.l	(sp)+,a1
	Bne.s	.Anim_Done
	Move.l	a0,Anim_Frame_Pointer_Save
	Bsr.s	.Do
	Bne.s	.Anim_Done
	Move.l	a0,Anim_Frame_Pointer
	Moveq	#0,d0
	Movem.l	(sp)+,d1-a6
	Rts
.Anim_Done
	Moveq	#-1,d0
	Movem.l	(sp)+,d1-a6
	Rts

.Do	Cmp.l	#"FEND",(a0)
	Beq.s	.Anim_Finished
	Move.l	4(a0),d0
	Subq.l	#8,d0
	Addq.l	#8,a0
	Bsr	Delta_Uncompress
	Moveq	#0,d0
	Rts
.Anim_Finished
	Moveq	#-1,d0
	Rts

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

Anim_Frame_Pointer	Ds.l	2
Anim_Frame_Pointer_Save	Ds.l	2
Init_Anim_Flag		Ds.w	1


Creationp	Ds.l	1
Last_Address	Ds.l	1
Handle	Ds.l	1
Vbl_Flag	Ds.w	1
Old_Mode	Ds.w	1
INTSAVE		DS.L	1
ScreenP		Ds.l	2
Stacksave	Ds.l	1
	Dc.b	01,0
Bool	Ds.b	2

Anim_Name
	Ds.b	200
	Even
Fuck_Off_LBM_Name
	Ds.b	200


Current_Anim
	Dc.w	1

Intro_Text
	Dc.b	$a,$d
	Dc.b	"Dpaint anim converter ! Done by Freddy",$A,$D
	Dc.b	"Give me an initial filename... ",$A,$D
	Dc.b	0
	Even

Replay_Text
	Dc.b	27,"E"
	Dc.b	$a,$d
	Dc.b	"Do you wanna make sure freddys code works ? ",$A,$D
	Dc.b	0
	Even

Save_Text
	Dc.b	27,"E"
	Dc.b	$a,$d
	Dc.b	"Give me an save filename... ",$A,$D
	Dc.b	0
	Even

Delete_Text
	Dc.b	27,"E" 
	Dc.b	$a,$d
	Dc.b	"Do you wsh to delete all the remaining LBM files"
	Dc.b	" from your H/D... ",$A,$D
	Dc.b	0
	Even


	
	CNOP	0,4
File_Buffer	Ds.l	64000/4
Decode_Buffer	Ds.l	64000/4
Convert_Buffer	Ds.l	64000/4
Eor_Buffer	Ds.l	64000/4

MY_SCREEN1	Ds.L	64000/4
MY_SCREEN2	Ds.L	64000/4

	Section	BSS
Anim_Creation	Ds.l	500000/4