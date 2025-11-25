; Mandelbrot & Julia set generator
; brought to ya by Freddy !

	Include	E:\INCLUDES\SYSTREGS.INC
	Include	E:\Raiden\Spool.s

Start_Real_Val=$fffe0000
End_Real_Val=$00020000
Start_I_Val=$fffe0000
End_I_Val=$20000
Max_Iter=64
Byteswide=320


Start	Bsr	Init			
Re_Start
	Move.l	#Start_Real_Val,Real_Start(a4)
	Move.l	#End_Real_Val,Real_End(a4)
	Move.l	#Start_I_Val,I_Start(a4)
	Move.l	#End_I_Val,I_End(a4)
Re_Iterate
	Bsr	Get_CompLex_Array
	Clr.w	X_Coard(a4)  
	Clr.w	Y_Coard(a4)
	Move.l	Screenp(a4),a0
	Bsr	Write_Screen
Main	Bsr	Get_Quick_Complex
	Bsr	Perform_Iteration
	Bsr	Plot_Pixel
	Addq.w	#1,X_Coard(a4)
	Cmp.w	#Byteswide,X_Coard(a4)
	Bne.s	Main
	Clr.w	X_Coard(a4)
	Bsr	Keycheck
	Tst.b	d0
	Bne.s	.Stop_Generating
	Addq.w	#1,Y_Coard(a4)
	Cmp.w	#200,Y_Coard(a4)
	Bne.s	Main
.Stop_Generating
	Clr.w	Boxx(a4)
	Clr.w	Boxy(a4)
	Move.w	#48,Boxwidth(a4)
	Move.w	#30,BoxHeight(a4)
	Bsr	Save_Box
	Bsr	Draw_Box
.Wait_Key
	Bsr	Keycheck
	Tst.b	d0
	Beq.s	.Wait_Key
	Bsr	Key_Actions
	Bra.s	.Wait_Key
Cycle_Loop
	Bsr	Restore_Box
	Not.b	Ready_To_Cycle(a4)


***********************************************************
Key_Actions
	Cmp.b	#"Q",d0
	Beq	Suby	
	Cmp.b	#"A",d0
	Beq	Addy	
	Cmp.b	#"O",d0
	Beq	Subx	
	Cmp.b	#"P",d0
	Beq	Addx	
	Cmp.b	#"Z",d0
	Beq	Re_Render
	Cmp.b	#"J",d0
	Beq	Julia
	Cmp.b	#"C",d0
	Beq	Cycle
	Cmp.b	#"X",d0
	Beq	Quit
	Cmp.b	#"M",d0
	Beq	Cont
	Cmp.b	#"W",d0
	Beq	Zoom_In
	Cmp.b	#"S",d0
	Beq	Zoom_Out
	Rts

***********************************************************
Zoom_Out
	Bsr	Restore_Box
	Subq.w	#2,BoxY(a4)
	Subq.w	#2,Boxx(a4)
	Bpl.s	.Pos
	Addq.w	#2,Boxx(a4)
	Rts
.Pos	Addq.w	#4,Boxwidth(a4)
	Addq.w	#4,BoxHeight(a4)
	Move.w	Boxwidth(a4),d0
	Add.w	Boxx(a4),d0
	Cmp.w	#320,d0
	Bge.s	.Error
	Bsr	Save_Box
	Bsr	Draw_Box
	Rts
.Error	Addq.w	#2,Boxx(a4)
	Subq.w	#2,Boxwidth(a4)
	Rts

***********************************************************
Zoom_In
	Bsr	Restore_Box
	Addq.w	#2,Boxx(a4)
	Addq.w	#2,BoxY(a4)
.Pos	Subq.w	#4,Boxwidth(a4)
	Subq.w	#4,BoxHeight(a4)
	Bsr	Save_Box
	Bsr	Draw_Box
	Rts

***********************************************************
Cont	Bsr	Restore_Box
	Addq.l	#4,sp
	Bra	Main
***********************************************************
Cycle
	Not.b	Ready_To_Cycle(a4)
	Beq.s	Rest_Box
	Bsr	Restore_Box
	Rts
Rest_Box
	Bsr	Save_Box
	Bsr	Draw_Box
	Rts

***********************************************************
Julia	Not.b	Julia_Flag(a4)
	Beq.s	.Gen_Mandel
	Movem.w	X_coard(a4),d0-d1
	Movem.w	BoxWidth(a4),d2-d3
	Lsr.w	#1,d2
	Lsr.w	#1,d3
	Add.w	d2,d0
	Add.w	d3,d1
	Lea	X_Array(pc),a0
	Lea	Y_Array(pc),a1
	Move.l	(a0,d0*4),Jr(a4)
	Move.l	(a1,d1*4),Ji(a4)
.Gen_Mandel
	Bsr	Setup_Screens
	Addq.l	#4,sp
	Bra	Re_Start

***********************************************************
Re_Render
	Move.w	Boxx(a4),X_Coard(a4)	
	Move.w	BoxY(a4),Y_Coard(a4)	
	Bsr	Get_Complex_Number_From_Plane
	Move.l	Real_Part(a4),-(sp)
	Move.l	I_Part(a4),-(sp)
	Move.w	Boxx(a4),X_Coard(a4)	
	Move.w	BoxY(a4),Y_Coard(a4)	
	Move.w	Boxwidth(a4),d0
	Add.w	d0,X_Coard(a4)
	Move.w	BoxHeight(a4),d0
	Add.w	d0,Y_coard(a4)
	Bsr	Get_Complex_Number_From_Plane
	Move.l	Real_Part(a4),Real_End(a4)
	Move.l	I_Part(a4),I_End(a4)
	Move.l	(sp)+,I_Start(a4)
	Move.l	(sp)+,Real_Start(a4)
	Bsr	Setup_Screens
	Addq.l	#4,sp
	Bra	Re_Iterate

***********************************************************
Subx	Subq.w	#4,Boxx(a4)
	Bpl.s	.Addx
	Clr.w	Boxx(a4)
.Addx	Bra	Redraw_Box
Addx	Move.w	Boxx(a4),d0
	Add.w	Boxwidth(a4),d0
	Cmp.w	#316,d0
	Beq.s	.No_Add
	Addq.w	#4,Boxx(a4)
.No_Add	Bra	Redraw_Box
***********************************************************
Suby	Subq.w	#4,Boxy(a4)
	Bpl.s	.Addy
	Clr.w	Boxy(a4)
.Addy	Bra	Redraw_Box
Addy	Move.w	Boxy(a4),d0
	Add.w	Boxheight(a4),d0
	Cmp.w	#252,d0
	Beq.s	.No_Add
	Addq.w	#4,Boxy(a4)
.No_Add	 
	Bra	Redraw_Box

***********************************************************
	Nop
Redraw_Box
	Bsr	Restore_Box
	Bsr	Save_Box
	Bsr	Draw_Box
	Rts

***********************************************************
Draw_Box
	Movem.w	Boxx(a4),d0-d1
	Lea	Screen1,a6
	Mulu	#Byteswide,d1
	And.w	#$fff0,d0
	Lea	(a6,d0.l),a6
	Lea	(a6,d1.l),a6
	Pea	(a6)
	Movem.w	Boxx(a4),d0-d1
	Movem.w	Boxwidth(a4),d2-d3
	Lsr.w	#1,d2
	Lsr.w	#1,d3
	Add.w	d2,d0
	Add.w	d3,d1
	Moveq	#$f,d2
	And.w	d0,d2
	Sub.w	d2,d0
	Move.w	#$8000,d3
	Ror.w	d2,d3
	Mulu	#Byteswide,d1
	Lea	Screen1,a6
	Lea	(a6,d0.w),a6
	Lea	(a6,d1.l),a6
	Eor.w	d3,(a6)+
	Eor.w	d3,(a6)+
	Eor.w	d3,(a6)+
	Eor.w	d3,(a6)+
	Eor.w	d3,(a6)+
	Eor.w	d3,(a6)+
	Eor.w	d3,(a6)+
	Eor.w	d3,(a6)+

	Move.l	(sp),a6
	Move.w	Boxx(a4),d0
	Move.w	Boxwidth(a4),d2
	And.w	#$f,d0
	Bsr	Draw_Horizontal_Line
	Move.l	(sp),a6
	Move.w	Boxx(a4),d0
	Move.w	Boxwidth(a4),d2
	And.w	#$f,d0
	Move.w	BoxHeight(a4),d1
	Mulu	#Byteswide,d1
	Lea	(a6,d1.l),a6
	Bsr	Draw_Horizontal_Line
	Move.l	(sp),a6
	Move.w	Boxx(a4),d0
	And.w	#$f,d0
	Move.w	BoxHeight(a4),d2
	Bsr	Draw_Vertical_Line
	Move.l	(sp)+,a6
	Move.w	Boxx(a4),d1
	And.w	#$f,d1
	Add.w	Boxwidth(a4),d1
	Lsr.w	#4,d1
	Lsl.w	#4,d1
	Lea	(a6,d1),a6
	Move.w	Boxx(a4),d0
	Add.w	Boxwidth(a4),d0
	And.w	#$f,d0
	Move.w	BoxHeight(a4),d2
	Bsr	Draw_Vertical_Line
	Rts

***********************************************************
;Address in a6,Shift in d0, Height in d2
Draw_Vertical_Line
	Move.w	#$8000,d7
	Ror.w	d0,d7
.Loop0	Eor.w	d7,(a6)+
	Eor.w	d7,(a6)+
	Eor.w	d7,(a6)+
	Eor.w	d7,(a6)+
	Eor.w	d7,(a6)+
	Eor.w	d7,(a6)+
	Eor.w	d7,(a6)+
	Eor.w	d7,(a6)+
	Lea	-16(a6),a6
	Lea	Byteswide(a6),a6
.Nx	Dbra	d2,.Loop0
	Rts


***********************************************************
;Address in a6,Shift in d0, Length in d2
Draw_Horizontal_Line
	Move.w	#$8000,d7
	Ror.w	d0,d7
.Loop0	Eor.w	d7,(a6)+
	Eor.w	d7,(a6)+
	Eor.w	d7,(a6)+
	Eor.w	d7,(a6)+
	Eor.w	d7,(a6)+
	Eor.w	d7,(a6)+
	Eor.w	d7,(a6)+
	Eor.w	d7,(a6)+
	Lea	-16(a6),a6
	Ror.w	#1,d7
	Bcc.s	.Nx
	Lea	16(a6),a6
.Nx	Dbra	d2,.Loop0
	Rts

***********************************************************
Restore_Box
	Lea	Boxsave,a0
	Move.w	(a0)+,d0
	Move.w	(a0)+,d7
	Move.l	(a0)+,a1
	Lsr.w	#4,d0
	Addq.w	#1,d0
.Loop0	Pea	Byteswide(a1)
	Move.w	d0,d1
.Loop1	Movem.l	(a0)+,d2-d5
	Movem.l	d2-d5,(a1)
	Lea	16(a1),a1
	Dbra	d1,.Loop1
	Move.l	(sp)+,a1
	Dbra	d7,.Loop0
	Rts

***********************************************************
Save_Box
	Lea	Boxsave,a1
	Movem.w	Boxx(a4),d0-d1
	Mulu	#Byteswide,d1
	And.w	#$fff0,d0
	Lea	Screen1,a0
	Lea	(a0,d0),a0
	Lea	(a0,d1.l),a0
	Move.w	Boxwidth(a4),d0
	Move.w	d0,(a1)+
	Lsr.w	#4,d0
	Addq.w	#1,d0
	Move.w	BoxHeight(a4),d7
	Move.w	d7,(a1)+
	Move.l	a0,(a1)+
.Loop0	Move.w	d0,d1
	Pea	Byteswide(a0)
.Loop1	Movem.l	(a0)+,d2-d5
	Movem.l	d2-d5,(a1)
	Lea	16(a1),a1
	Dbra	d1,.Loop1
	Move.l	(sp)+,a0
	Dbra	d7,.Loop0
	Rts

***********************************************************
Plot_Pixel
	Movem.w	X_Coard(a4),d0-d1
	Moveq	#$f,d2
	And.w	d0,d2
	Sub.w	d2,d0
	Mulu	#Byteswide,d1
	Add.l	d0,d1
	Move.l	Screenp(a4),a6
	Add.l	d1,a6
	Eor.w	#$f,d2
	Moveq	#1,d3
	Lsl.w	d2,d3
	Move.w	Iterations(a4),d4
.Loop	Lsr.w	#1,d4
	Bcc.s	.No_Or
	Or.w	d3,(a6)
.No_Or	Addq.l	#2,a6
	Tst.w	d4
	Bne.s	.Loop
	Rts

***********************************************************
;CZn(Zn-1)
Dragon_Iteration
	Move.l	#$10000,Zr(a4)
	Move.l	#$00000,Zi(a4)
.Iteratate
	Move.l	Real_Part(a4),d0
	Move.l	Zr(a4),d1
	Bsr	Mult32
	Move.l	d0,-(sp)
	Move.l	Real_Part(a4),d0
	Move.l	Zi(a4),d1
	Bsr	Mult32
	Move.l	d0,-(sp)
	Move.l	I_Part(a4),d0
	Move.l	Zr(a4),d1
	Bsr	Mult32
	Move.l	d0,-(sp)
	Move.l	I_Part(a4),d0
	Move.l	Zi(a4),d1
	Bsr	Mult32
	Move.l	d0,-(sp)		
	Movem.l	(sp)+,d0-d3
	Sub.l	d0,d3
	Add.l	d1,d2
	Move.l	d3,d0
	Move.l	d2,d1
	Movem.l	d0-d1,-(sp)
	Move.l	sp,a5
	Sub.l	#$10000,Zr(a4)
	Move.l	(a5),d0
	Move.l	Zr(a4),d1
	Bsr	Mult32
	Move.l	d0,-(sp)
	Move.l	(a5),d0
	Move.l	Zi(a4),d1
	Bsr	Mult32
	Move.l	d0,-(sp)
	Move.l	4(a5),d0
	Move.l	Zr(a4),d1
	Bsr	Mult32
	Move.l	d0,-(sp)
	Move.l	4(a5),d0
	Move.l	Zr(a4),d1
	Bsr	Mult32
	Move.l	d0,-(sp)
	Movem.l	(sp)+,d0-d3
	Sub.l	d0,d3
	Add.l	d1,d2
	Move.l	d3,d0
	Move.l	d2,d1
	Movem.l	d0-d1,-(sp)
	Move.l	(sp),d0
	Move.l	8(sp),d1
	Bsr	Mult32
	Move.l	d0,Zr(a4)
	Move.l	(sp),d0
	Move.l	12(sp),d1
	Bsr	Mult32
	Move.l	d0,Zi(a4)
	Move.l	4(sp),d0
	Move.l	8(sp),d1
	Bsr	Mult32
	Add.l	d0,Zi(a4)
	Move.l	4(sp),d0
	Move.l	12(sp),d1
	Bsr	Mult32
	Sub.l	d0,Zr(a4)
	Lea	16(sp),sp
	Addq.w	#1,Iterations(a4)
	Move.l	Zr(a4),d0
	Move.l	d0,d1
	Bsr	Mult32
	Move.l	d0,-(sp)
	Move.l	Zi(a4),d0
	Move.l	d0,d1
	Bsr	Mult32
	Move.l	(sp)+,d3
	Add.l	d0,d3
	Cmp.l	#$40000,d3
	Bge.s	.Infinity
	Cmp.w	#Max_Iter,Iterations(a4)
	Bne	.Iteratate
	Clr.w	Iterations(a4)
.Infinity
	Rts





***********************************************************
Perform_Iteration
	Clr.w	Iterations(a4)
	Clr.l	Zr(a4)
	Clr.l	Zi(a4)
;	Bra	Dragon_Iteration
	Tst.b	Julia_Flag(a4)
	Beq.s	.Iterate
	Move.l	Real_Part(a4),Zr(a4)
	Move.l	I_Part(a4),Zi(a4)
.Iterate
	Move.l	Zr(a4),d0
	Move.l	d0,d1
	Bsr	Mult32
	Move.l	d0,d4
	Move.l	Zi(a4),d0
	Move.l	d0,d1
	Bsr	Mult32
	Move.l	d0,d3
	Move.l	d4,d1
	Sub.l	d3,d1
	Move.l	d1,-(sp)		Zr
	Move.l	Zr(a4),d0
	Move.l	Zi(a4),d1
	Bsr	Mult32
	Asl.l	#1,d0
	Move.l	d0,Zi(a4)
	Move.l	(sp)+,Zr(a4)
	Addq.w	#1,Iterations(a4)
	Move.l	Real_Part(a4),d0
	Move.l	I_Part(a4),d1
	Tst.b	Julia_Flag(a4)
	Beq.s	.Mandel2
	Move.l	Jr(a4),d0
	Move.l	Ji(a4),d1
.Mandel2
	Add.l	d0,Zr(a4)
	Add.l	d1,Zi(a4)
	Move.l	Zr(a4),d0
	Move.l	d0,d1
	Bsr	Mult32
	Move.l	d0,-(sp)
	Move.l	Zi(a4),d0
	Move.l	d0,d1
	Bsr	Mult32
	Move.l	(sp)+,d3
	Add.l	d0,d3
	Cmp.l	#$40000,d3
	Bge.s	.Infinity
	Cmp.w	#Max_Iter,Iterations(a4)
	Bne.s	.Iterate
	Clr.w	Iterations(a4)
.Infinity
	Rts

***********************************************************
Mult32	Moveq	#0,d5
	Tst.l	d0
	Smi	d6
	Bpl.s	.Posa
	Neg.l	d0
.Posa	Tst.l	d1
	Smi	d7
	Bpl.s	.Posb
	Neg.l	d1
.Posb	Move.l	d0,d2
	Move.l	d1,d3
	Mulu	d0,d1
	Swap	d1
	Move.w	d1,d5
	Move.l	d2,d0
	Move.l	d3,d1
	Swap	d1
	Mulu	d0,d1
	Add.l	d1,d5
	Move.l	d2,d0
	Move.l	d3,d1
	Swap	d0
	Mulu	d0,d1
	Add.l	d1,d5
	Move.l	d2,d0
	Move.l	d3,d1
	Swap	d0
	Swap	d1
	Mulu	d0,d1
	Swap	d5
	Add.w	d1,d5
	Swap	d5
	Eor.b	d6,d7
	Beq.s	.Positive
	Neg.l	d5
.Positive
	Move.l	d5,d0
	Rts

***********************************************************
Get_Complex_Number_From_Plane
	Move.l	Real_End(a4),d0
	Sub.l	Real_Start(a4),d0
	Move.w	X_Coard(a4),d1
	DivS	#320,d0
	MulS	d1,d0
	Add.l	Real_Start(a4),d0
	Move.l	d0,Real_Part(a4)
	
	Move.l	I_End(a4),d0
	Sub.l	I_Start(a4),d0
	Move.w	Y_Coard(a4),d1
	DivS	#200,d0
	MulS	d1,d0
	Add.l	I_Start(a4),d0
	Move.l	d0,I_Part(a4)
	Rts
***********************************************************
Get_Quick_Complex
	Move.w	X_CoARD(a4),d0
	Move.w	Y_CoARD(a4),d1
	Lea	X_Array(pc),a6
	Move.l	(a6,d0*4),Real_Part(a4)
	Lea	Y_Array(pc),a6
	Move.l	(a6,d1*4),I_Part(a4)
	Rts

***********************************************************
Get_Complex_Array
	Clr.w	X_Coard(a4)
	Clr.w	Y_Coard(a4)
	Lea	X_Array(pc),a6
.Loop	Bsr	Get_Complex_Number_From_Plane
	Move.l	Real_Part(a4),(a6)+
	Addq.w	#1,X_Coard(a4)
	Cmp.w	#320,X_Coard(a4)
	Bne.s	.Loop
	Clr.w	X_Coard(a4)
	Clr.w	Y_Coard(a4)
	Lea	Y_Array(pc),a6
.Loop1	Bsr	Get_Complex_Number_From_Plane
	Move.l	I_Part(a4),(a6)+
	Addq.w	#1,Y_Coard(a4)
	Cmp.w	#200,Y_Coard(a4)
	Bne.s	.Loop1
	Rts

***********************************************************
Fade_Pal
	Lea	Mypal(a4),a0
	Lea	Dest_pal(a4),a1
	Move.w	Intens(a4),d0
	Move.w	#256,d1
	Bsr	Scale_Pal
	Rts

***********************************************************
Swap_Screens
	Movem.l	Screenp(a4),d0-d1
	Exg	d0,d1
	Movem.l	d0-d1,Screenp(a4)
	Move.l	d1,a0
	Bsr	Write_Screen
	Rts

***********************************************************
Write_Screen
	Pea	(a0)
	Move.b	1(sp),Bp_Hi
	Move.b	2(sp),Bp_Md
	Move.b	3(sp),Bp_Lo+1
	Addq.l	#4,sp
	Rts

***********************************************************
Check_for_Q
	Cmp.b	#"Q",Key_Pressed(a4)
	Rts	

***********************************************************
Init	Lea	Data(pc),a4		
	Bsr	Install_Screen		
	Bsr	Cleardata		
	Bsr	Setup_Screen_Mode	
	Bsr	Setup_Screens		
	Bsr	Save_Vbl		
	Bsr	Set_Vbl
	Lea	Vg,a0
	Move.l	Screenp+4(a4),a1
	Lea 	Dest_Pal(a4),a2
	Bsr	Decode_Vga
	Bsr	Copy_Dest
	Rts

**********************************************************
Set_Vbl	Pea	New_Vbl(pc)
	Move.l	(sp)+,$70.w
	Rts
**********************************************************
Install_Screen
	Move.w	#-1,-(sp)
	Move.l	#Screen1,-(sp)
	Move.l	(sp),-(sp)
	Move.w	#5,-(sp)
	Trap	#14
	Lea	12(sp),sp
	Rts

**********************************************************
Setup_Screen_Mode	
	Bsr	Mon_Type
	Cmp.b	#2,d0			
	Seq	Vga_Flag(a4)		
	Bne.s	.Not_Vga		
	Move.w	#$64,Screen_Mode(a4)	
	Bra.s	.Skip			
.Not_Vga 
	Move.w	#$23,Screen_Mode(a4)	
.Skip	Bsr	Setmode			
	Rts

**********************************************************
Quit	Lea	Data(pc),a4
	Move.w	Mod_Save(a4),Scr_Mod
	Move.w	Del_Save(a4),Scr_Del
	Move.l	Vbl_save(a4),$70.w			
	Move.w	Old_Mode(a4),Screen_Mode(a4)	
	Bsr	Setmode			
	Clr.w	-(sp)
	Trap	#1
	
**********************************************************
; Save/Set Vbl
Save_Vbl
	move.l	$70.w,Vbl_save(a4)	
	Pea	New_Vbl(pc)
	Move.l	(sp)+,$70.w		
	Rts

**********************************************************
; All data exept SYSvars
Cleardata
	Move.w	#Varend-1,d0
.Loop	Clr.b	(a4,d0.w)
	Dbra	d0,.Loop
	Rts	

**********************************************************
; Calculate addresses for screens + clear em

Setup_Screens
	Move.l	#Screen1,d0	
	Move.l	#Screen2,d1
	Moveq	#-4,d2			
	And.l	d2,d0
	And.l	d2,d1
	Movem.l	d0-d1,Screenp(a4)	
	Bsr	Clear_Screens
	Move.w	Scr_Del,Del_Save(a4)
	Move.w	Scr_Mod,MOD_Save(a4)
	Rts

**********************************************************
; Clear both screens

Clear_Screens
	Movem.l	Screenp(a4),a0-a1
	Move.l	#64000/4-1,d0
.Loop	Clr.l	(a0)+
	Clr.l	(a1)+
	Dbra	d0,.Loop
	Rts

**********************************************************
; Setup screen mode in SCREEN_MODE(a4)
Setmode	Move.w	Screen_mode(a4),-(sp)
	Move.w	#88,-(sp)
	Trap	#14
	Addq.l	#4,sp
	Move.w	d0,Old_Mode(a4)		
	rts
	
**********************************************************
; Return monitor type in d0
Mon_Type
	Move.w	#89,-(sp)
	Trap	#14
	Addq.l	#2,sp
	Rts

**********************************************************
; Key in d0/Key pressed
Keycheck
	Move.w	#$ff,-(sp)
	Move.w	#6,-(sp)
	Trap	#1			
	Addq.l	#4,sp
	Cmp.b	#"a",d0
	Bcs.s	.Upper
	Cmp.b	#"z"+1,d0
	Bcc.s	.Upper
	Sub.b	#$20,d0
.Upper	Move.b	d0,Key_Pressed(a4)
	Rts

***********************************************************
; Add to Vbl_Count

New_Vbl	Movem.l	d0-a6,-(sp)
	Lea	Data(pc),a4
	Tst.b	Ready_To_Cycle(a4)
	Beq.s	.No
	Lea	Pal256+1024,a0
	Move.l	a0,a1
	Move.l	-(a0),-(sp)
	Move.w	#253,d0
.Loop	Move.l	-(a0),-(a1)
	Dbra	d0,.Loop
	Move.l	(sp)+,-(a1)
.No	Addq.b	#1,Vbl_Flag(a4)
	Movem.l	(sp)+,d0-a6
	Rte

***********************************************************
Copy_Dest
	Lea	Dest_Pal(a4),a0
	Lea	Pal256,a1
	Move.w	#256,d0
	Bsr	Quick_Copy_Long
	Rts

***********************************************************
; Wait for framerate, then clear!
Wait_Vbl
	Cmp.b	#1,Vbl_Flag(a4)
	Bne.s	Wait_Vbl
	Sf	Vbl_Flag(a4)
	Rts

**********************************************************
; a0=Decoded VGA pic, a1=DEST!
Convert_VGA
	Move.l	a1,a2
	Move.w	#(64000/4)-1,d0
.Loopx	Clr.l	(a1)+
	Dbra	d0,.Loopx
	Move.l	a2,a1

	Move.w	#199,d4
.Xloop	Move.w	#319,d0
	Move.l	a1,-(sp)
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
	Bcc.s	.Nx2
	Lea	16(a1),a1
.Nx2	Dbra	d0,.loop
	Move.l	(sp)+,a1
	Lea	Byteswide(a1),a1
	Dbra	d4,.Xloop
	Rts	
	
**********************************************************
; a0=Source pallete , a1=Dest pallete, d0= Intensity, d1=Number !
; Note pallete is in 3 byte RGB format , and throws out in 4 bytes !

Scale_Pal
	Subq.w	#1,d1
.Loop	Movem.w	Clear(a4),d2-d4
	Move.b	(a0)+,d2
	Move.b	(a0)+,d3
	Move.b	(a0)+,d4
	Mulu	d0,d2
	Mulu	d0,d3
	Mulu	d0,d4
	Lsr.w	#8,d2
	Lsr.w	#8,d3
	Lsr.w	#8,d4
	Move.b	d2,(a1)+
	Move.b	d3,(a1)+
	Clr.b	(a1)+
	Move.b	d4,(a1)+
	Dbra	d1,.Loop
	Rts

**********************************************************
; a0=LBM VGA pic, a1=Dest, a2=Pointer to pallete (saves in 3 bytes!)
; Note DEST needs around 64,000 bytes !

Decode_VGA
	Move.l	a0,-(sp)
.SearchCMAP
 	Cmp.l	#"CMAP",(a0)		; Search for CMAP
 	Beq.s	.Cmapfound
 	Addq.l	#2,a0
 	Bra.s	.SearchCMAP
.Cmapfound
	Addq.l	#4,a0
	Move.l	(a0)+,d0		; Length of Color data !
.Cloop	Move.b	(a0)+,(a2)+	
	Move.b	(a0)+,(a2)+
	Clr.b	(a2)+
	Move.b	(a0)+,(a2)+		; R/G/B
	Subq.l	#3,d0
	Bne.s	.Cloop

	Move.l	(sp)+,a0
.Searchbody
	Cmp.l	#"BODY",(a0)
	Beq.s	.Bodyfound		; Search for body !
	Addq.l	#2,a0
	Bra.s	.Searchbody

.Bodyfound
	Addq.l	#4,a0
	Move.l	(a0)+,d0		Length of byte-run
.ByterunLoop
	Move.b	(a0)+,d1		Byte in d1
	Bmi.s	.Run
	Moveq	#0,d3			Clear d3
	Move.b	d1,d3			Length in d3
	Addq.b	#2,d3			Add 1 for extra count byte
.Copyloop
	Move.b	(a0)+,(a1)+		Copy byte
	Subq.b	#1,d1
	Bge.s	.Copyloop		Decrement loop
	Sub.l	d3,d0			Away from total count
	Bgt.s	.ByterunLoop	
	Bra.s	.Byterunexit	
.Run	Move.b	(a0)+,d2		byte to repeat !
.Rloop	Move.b	d2,(a1)+		Byte in
	Addq.b	#1,d1			Decrement loop
	Ble.s	.RLoop
	Subq.l	#2,d0
	Bgt.s	.ByterunLoop
.Byterunexit
	Rts

**********************************************************
; a0=Source , a1=Dest, d0=Num longs
Quick_Copy_Long
	Movem.l	d0-a6,-(sp)
.Loop	Sub.w	#12,d0
	Ble.s	.Noon
	Movem.l	(a0)+,d1-d7/a2-a6
	Movem.l	d1-d7/a2-a6,(a1)
	Lea	48(a1),a1
	Bra.s	.Loop
.Noon	Beq.s	.Exit
	Add.w	#11,d0
.Loop1	Move.l	(a0)+,(a1)+
	Dbra	d0,.Loop1		
.Exit	Movem.l	(sp)+,d0-a6
	Rts

**********************************************************

	Rsreset
Clear		Rs.w	16
Screen_Mode	Rs.w	1
Old_Mode	Rs.w	1
Mod_Save	Rs.w	1
Del_Save	Rs.w	1
Real_Start	Rs.l	1
Real_End	Rs.l	1
I_Start		Rs.l	1
I_End		Rs.l	1
X_Coard		Rs.w	1
Y_Coard		Rs.w	1
Real_Part	Rs.l	1
I_Part		Rs.l	1
Iterations	Rs.w	1
Boxx		Rs.w	1
Boxy		Rs.w	1
Zr		Rs.l	1
Zi		Rs.l	1
Boxwidth	Rs.w	1
BoxHeight	Rs.w	1
Vbl_Save	Rs.l	1
Screenp		Rs.l	2
Intens		Rs.w	3
Dest_Pal	Rs.l	256
Mypal		Rs.b	3*256
Vga_Flag	Rs.b	1
Vbl_Flag	Rs.b	1
Key_Pressed	Rs.b	1
Ready_To_Cycle	Rs.b	1
Jr		Rs.l	1
Ji		Rs.l	1
Julia_Flag	Rs.b	1
Varend		Rs.b	0


Data	Ds.b	Varend
	Even

X_Array	Ds.l	320
Y_Array	Ds.l	200


Boxsave	Ds.l	64000/4
Vg	Incbin	Lbms\l.lbm

	Cnop	0,4
Screen1	Ds.l	64000/4
Screen2	Ds.l	64000/4