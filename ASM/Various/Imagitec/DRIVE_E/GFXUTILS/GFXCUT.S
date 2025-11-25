; Standard VGA Graphics brush converter
; Reads VGA ILBM FILE
; and converts brushes to blocks of variable sizes of byte/pixel
; Also saves a header with the structure of the following
Sprite_Len=800
OFFy=000
; .W	Nummber of sprites converted
; ..256
; .L   Pallete Information
; ..
; ..600
; .L	Sprite Offset (FROM START OF STRUCTURE!)
; .W	Size X
; .W	Size Y
; ..

; Done by FrEdDy!

; The keyz
; Q 	- Quit
; - 	- Brush height (8/16/24/32)
; + 	- Brush width  (8/16/24/32)
; SPC	- Cut
; Cup	- Edit current sprite position
; Cdn	- Edit current sprite position
; L	- Load sprite position file
; S	- Save sprite position file
; F10	- Save sprites

; And remember to move that mouse and twist those melons !

**********************************************************
** EQUATES SECTION

; MODE EQUATES
vertflag	equ	$100
stmodes		equ	$80
overscan	equ	$40
pall		equ	$20
vga		equ	$10
tv		equ	$00
col80		equ	$08
col40		equ	$00
bps16		equ	4
bps8		equ	3
bps4		equ	2
bps2		equ	1
bps1		equ	0

; BLITTER EQUATES
Blitterstuff 	Equ $ff8a00
Halftone	Equ $000000
Src_Xinc	Equ $000020
Src_Yinc	Equ $000022
Src_Addr	Equ $000024
Endmask1	Equ $000028
Endmask2	Equ $00002a
Endmask3	Equ $00002c
Dst_Xinc	Equ $00002e
Dst_Yinc	Equ $000030
Dst_Addr	Equ $000032
X_Count		Equ $000036
Y_Count		Equ $000038
Hop		Equ $00003a
Op		Equ $00003b
Line_Num	Equ $00003c
Skew		Equ $00003d
Procswitch	Equ $ff8007
Pal256		Equ $ff9800
Scr_mod		Equ $ff820e
Scr_del		Equ $ff8264
Bp_Hi		Equ $ff8201
Bp_Md		Equ $ff8203
Bp_Lo		Equ $ff820c
Vd_Hi		Equ $ff8204
Vd_Md		Equ $ff8206
Vd_Lo		Equ $ff8208


	Move.l	a7,a5
	Move.l	#Ustack,a7
	Move.l	4(a5),a5
	Move.l	$c(a5),d0
	Move.l	$14(a5),d0
	Add.l	$1c(a5),d0
	Add.l	#$100,d0
	MOve.l	d0,-(sp)
	MOVE.L	A5,-(SP)
	MOVE.W	#0,-(SP)
	Move.w	#$4a,-(sp)
	Trap	#1
	Add.l	#12,sp
	Tst.l	d0

	MOVE.W	#STRUCT_END-SPRITE_POS_TABLE,D0
Start	Move.l	a7,Stacksave
	Bsr	Init

Main	Bsr	Wait_vbl
	Bsr	Set_Col
	Bsr	Restore_Box
	Bsr	Restore_Mouse
	Bsr	Check_Box
	Bsr	Save_Mouse
	Bsr	Save_Box
	Bsr	Draw_Box
	Bsr	Draw_Mouse
	Bsr	Dragxy
	Bsr	Do_Key
	Bsr	Print_Num
	Bsr	Print_XY
	Bsr	Print_WH
	Move.w	#$1ff,d0
.Lo	Dbra	d0,.Lo
	Bsr	Set_Video_Pointers
	Bra	Main

Set_Col	Move.l	#$00ff00ff,Pal256+1020
	Rts

Check_Box
	Movem.w	Boxx,d0-d3			x/y/w/h
	Add.w	d0,d2	
	Add.w	d1,d3
	SUBQ.W	#1,D2
	SUBQ.W	#1,D3
	Mulu	#320,d1
	Mulu	#320,d3
	Moveq	#$f,d6
	Moveq	#$f,d7
	And.w	d0,d6
	And.w	d2,d7
	Sub.w	d6,d0
	Sub.w	d7,d2
	Add.l	d0,d1
	Add.l	d2,d3
	Add.l	Screenp,d1
	Add.l	Screenp,d3
	Move.l	d1,a5
	Move.l	d3,a6
	Moveq	#0,d0
	Moveq	#0,d1
	Rept	8
	Or.w	(a5)+,d0
	Endr
	Rept	8
	Or.w	(a6)+,d1
	Endr
	Move.w	.Ortab(pc,d6*2),d6
	Move.w	.Ortab(pc,d7*2),d7
	And.w	d6,d0
	Bne.s	.Error
	And.w	d7,d1
	Bne.s	.Error
	Rts	
.Error	
;	Move.l	#$00FF0000,Pal256
	Rts	
	
	
.Ortab	Dc.w	$8000,$4000,$2000,$1000
	Dc.w	$800,$400,$200,$100
	Dc.w	$80,$40,$20,$10
	Dc.w	$8,$4,$2,$1
	
	

Print_WH
	Clr.l	d7
	Move.w	Width(pc),d7
	Lea	Screen3+(320*192)+176,a6
	Bsr	.Print_it
	Clr.l	d7
	Move.w	Width+2(pc),d7
	Lea	Screen3+(320*192)+240,a6
	Bsr	.Print_it
	Clr.l	d7
	Move.w	Width(pc),d7
	Lea	Screen2+(320*192)+176,a6
	Bsr	.Print_it
	Clr.l	d7
	Move.w	Width+2(pc),d7
	Lea	Screen2+(320*192)+240,a6
	Bsr	.Print_it
	Rts	
	
.Print_It
	Lea	Font,a3
	Divu	#100,d7
	Move.w	d7,d6
	Clr.w	d7
	Swap	d7
	Divu	#10,d7
	Move.w	d7,d5
	Swap	d7
	Add.b	#"0"-32,d5
	Add.b	#"0"-32,d6
	Add.b	#"0"-32,d7
	Lea	(a3,d7*8),a0
	Lea	(a3,d6*8),a1
	Lea	(a3,d5*8),a2
	Exg	a0,a2
	Exg	a1,a0
	Bsr.s	.DDO
	Move.l	a1,a0
	Bsr.s	.DDO
	Move.l	a2,a0
	Bsr.s	.DDO
	Rts
	
.DDO	Move.l	a6,-(sp)
	Moveq	#7,d7
.Loop	Move.b	(a0)+,d6
	Move.b	d6,00(a6)
	Move.b	d6,02(a6)
	Move.b	d6,04(a6)
	Move.b	d6,06(a6)
	Move.b	d6,08(a6)
	Move.b	d6,10(a6)
	Move.b	d6,12(a6)
	Move.b	d6,14(a6)
	Lea	320(a6),a6
	Dbra	d7,.Loop
	Move.l	(sp)+,a6
	Lea	16(a6),a6
	Rts	


Print_XY
	Clr.l	d7
	Move.w	Boxx(pc),d7
	Lea	Screen3+(320*192)+48,a6
	Bsr	.Print_it
	Clr.l	d7
	Move.w	Boxx+2(pc),d7
	Lea	Screen3+(320*192)+112,a6
	Bsr	.Print_it
	Clr.l	d7
	Move.w	Boxx(pc),d7
	Lea	Screen2+(320*192)+48,a6
	Bsr	.Print_it
	Clr.l	d7
	Move.w	Boxx+2(pc),d7
	Lea	Screen2+(320*192)+112,a6
	Bsr	.Print_it
	Rts	
	
.Print_It
	Lea	Font,a3
	Divu	#100,d7
	Move.w	d7,d6
	Clr.w	d7
	Swap	d7
	Divu	#10,d7
	Move.w	d7,d5
	Swap	d7
	Add.b	#"0"-32,d5
	Add.b	#"0"-32,d6
	Add.b	#"0"-32,d7
	Lea	(a3,d7*8),a0
	Lea	(a3,d6*8),a1
	Lea	(a3,d5*8),a2
	Exg	a0,a2
	Exg	a1,a0
	Bsr.s	.DDO
	Move.l	a1,a0
	Bsr.s	.DDO
	Move.l	a2,a0
	Bsr.s	.DDO
	Rts
	
.DDO	Move.l	a6,-(sp)
	Moveq	#7,d7
.Loop	Move.b	(a0)+,d6
	Move.b	d6,00(a6)
	Move.b	d6,02(a6)
	Move.b	d6,04(a6)
	Move.b	d6,06(a6)
	Move.b	d6,08(a6)
	Move.b	d6,10(a6)
	Move.b	d6,12(a6)
	Move.b	d6,14(a6)
	Lea	320(a6),a6
	Dbra	d7,.Loop
	Move.l	(sp)+,a6
	Lea	16(a6),a6
	Rts	

Print_Num
	Move.l	Sprite_Pos_Pointer,a0
	Move.w	Current_Screen,(a0)+
	Move.l	Boxx,(a0)+
	Move.w	Width,(a0)+
	Move.w	Height,(a0)+

	Moveq	#0,d0
	Move.l	Sprite_Pos_Pointer,d0
	Sub.l	#Sprite_Pos_Table,d0
	Divu	#10,d0
	Divu	#100,d0
	Lea	Screen2+320*192,a6
	Lea	Screen3+320*192,a5
	Lea	font,a1
	Add.b	#"0"-32,d0
	Lea	(a1,d0*8),a0
	Clr.w	d0
	Swap	d0
	Divu	#10,d0
	Add.b	#"0"-32,d0
	Lea	(a1,d0*8),a1
	Swap	d0
	Move.w	d0,-(sp)
	Pea	16(a6)
	Pea	16(a5)
	Moveq	#7,d0
.Loop	Move.b	(a0)+,d1
	Move.b	(a1)+,d2
	Rept	8
	Move.b	d1,(a6)+
	Move.b	d2,(a6)+
	Move.b	d1,(a5)+
	Move.b	d2,(a5)+
	Endr
	Lea	320-16(a6),a6
	Lea	320-16(a5),a5
	Dbra	d0,.Loop
	Move.l	(sp)+,a5
	Move.l	(sp)+,a6
	Move.w	(sp)+,d0
	Lea	font,a1
	Add.b	#"0"-32,d0
	Lea	(a1,d0*8),a0
	Moveq	#7,d0
.Loop1	Move.b	(a0)+,d1
	Rept	8
	Move.b	d1,(a6)+
	Move.b	d1,(a5)+
	Addq.l	#1,a5
	Addq.l	#1,a6
	Endr
	Lea	320-16(a6),a6
	Lea	320-16(a5),a5
	Dbra	d0,.Loop1
	Rts

Dragxy	Tst.w	Mbuts
	Beq.s	.No
	Move.l	Mxdelta,Boxx
	Move.l	#$80008000,Prev_mousexy
.No	Clr.w	Mbuts
	Rts	


Restore_Mouse
	Move.l	Mousep,a0
	Tst.l	(a0)
	Beq.s	.Exit
	Move.l	(a0)+,a1
	Moveq	#15,d7
.Loop	Movem.l	(a0)+,d0-d6/a2
	Movem.l	d0-d6/a2,(a1)
	Lea	320(a1),a1
	Dbra	d7,.Loop
.Exit	Rts

Save_Mouse
	Move.l	Mousep,a1
	Movem.w	Mxdelta,d0-d1
	And.w	#$fff0,d0
	Mulu	#320,d1
	Add.l	d0,d1
	Add.l	Screenp,d1
	Move.l	d1,a0
	Move.l	a0,(a1)+
	Moveq	#15,d7
.Loop	Movem.l	(a0),d0-d6/a2
	Movem.l	d0-d6/a2,(a1)
	Lea	320(a0),a0
	Lea	32(a1),a1
	Dbra	d7,.Loop
	Rts
	
Draw_Mouse
	Move.l	Mousep,a1
	Move.l	(a1)+,a1
	Moveq	#$f,d0
	And.w	Mxdelta,d0
	Lea	Mousegfx,a0
	Moveq	#15,d7
.Loop	Moveq	#0,d1
	MOve.w	(a0)+,d1
	Ror.l	d0,d1
	Rept	8
	or.w	d1,(a1)+
	Endr
	Swap	d1
	Rept	8
	or.w	d1,(a1)+
	Endr
	Lea	-32(a1),a1
	Lea	320(a1),a1
	Dbra	d7,.Loop
	Rts

Do_Mouse_Bound
	Movem.l	d0-d1,-(sp)
	Movem.w	Mxdelta,d0-d1
	Move.w	d0,d2
	Move.w	d1,d3
	Tst.w	d0
	Bge.s	.Ok
	Clr.w	d0
.Ok	Tst.w	d1
	Bge.s	.Ok2
	Clr.w	d1
.Ok2	Add.w	Width,d2	
	Add.w	Height,d3
	Cmp.w	#320,d2
	Blt.s	.Ok3
	Move.w	#320,d0
	Sub.w	Width,d0
.Ok3	Cmp.w	#200,d3
	Blt.s	.Ok4
	Move.w	#200,d1
	Sub.w	Height,d1
.Ok4	Movem.w	d0-d1,Mxdelta
	Movem.l	(sp)+,d0-d1
	Rts

Draw_Box
	Movem.w	Boxx,d0-d1
	Mulu	#320,d1
	Add.l	Screenp,d1
	Moveq	#$f,d2
	And.w	d0,d2
	Sub.w	d2,d0
	Add.l	d0,d1
	Move.l	d1,a1
	Move.w	d2,d0
	
	Move.w	Width,d6
	Subq.w	#1,d6
	Move.w	Height,d7
	Move.w	#$8000,d5
	Ror.w	d0,d5
	Move.w	d7,d4
	Subq.w	#1,d4
	Move.l	a1,-(sp)
.Loop	Or.w	d5,(a1)+
	Or.w	d5,(a1)+
	Or.w	d5,(a1)+
	Or.w	d5,(a1)+
	Or.w	d5,(a1)+
	Or.w	d5,(a1)+
	Or.w	d5,(a1)+
	Or.w	d5,(a1)+
	Lea	-16(a1),a1
	Lea	320(a1),a1
	Dbra	d4,.Loop
	Movem.l	(sp),a1
	Add.w	d0,d6
	Move.w	d6,d5
	And.w	#$f,d6
	Sub.w	d6,d5
	Lea	(a1,d5),a1
	Move.w	#$8000,d5
	Ror.w	d6,d5
	Move.w	d7,d4
	Subq.w	#1,d4
.Loop1	Or.w	d5,(a1)+
	Or.w	d5,(a1)+
	Or.w	d5,(a1)+
	Or.w	d5,(a1)+
	Or.w	d5,(a1)+
	Or.w	d5,(a1)+
	Or.w	d5,(a1)+
	Or.w	d5,(a1)+
	Lea	-16(a1),a1
	Lea	320(a1),a1
	Dbra	d4,.Loop1
	Move.l	(sp)+,a1

	Move.w	Width,d6
	Move.w	Height,d7
	Subq.w	#1,d6
	Move.w	#$8000,d5
	Ror.w	d0,d5
	Subq.w	#1,d7
	Mulu	#320,d7
	Lea	(a1,d7.l),a2

.Loop2	
	Rept	8
	Or.w	d5,(a1)+
	Or.w	d5,(a2)+
	Endr
	Lea	-16(a1),a1
	Lea	-16(a2),a2
	Ror.w	#1,d5
	Bcc.s	.Dec
	Lea	16(a1),a1
	Lea	16(a2),a2
.Dec	Dbra	d6,.Loop2
	Rts		
	
Save_Box
	Movem.w	BoxX,d0-d1
	Mulu	#320,d1
	Add.l	Screenp,d1
	And.w	#$fff0,d0
	Add.l	d0,d1
	Move.l	d1,a0
	Move.l	Boxp,a1
	Move.l	a0,(a1)+
	Movem.w	Width(pc),d0-d1
	Move.w	d0,(a1)+
	Move.w	d1,(a1)+
	Add.w	#32,d0
	Lsr.w	#2,d0	 
	Subq.w	#1,d0
	Subq.w	#1,d1
	Move.w	d0,-(sp)
.Loop0	Move.w	(sp),d0
	Pea	320(a1)
	Pea	320(a0)
.Loop1	Move.l	(a0)+,(a1)+
	Dbra	d0,.Loop1
	Movem.l	(sp)+,a0-a1
	Dbra	d1,.Loop0
	Addq.l	#2,sp
	Rts
	
Restore_Box
	Move.l	Boxp,a0
	Tst.l	(a0)
	Beq.s	.Exit
	Move.l	(a0)+,a1
	Movem.w	(a0)+,d0-d1
	Add.w	#32,d0
	Lsr.w	#2,d0	 
	Subq.w	#1,d0
	Subq.w	#1,d1
	Move.w	d0,-(sp)
.Loop0	Move.w	(sp),d0
	Pea	320(a1)
	Pea	320(a0)
.Loop1	Move.l	(a0)+,(a1)+
	Dbra	d0,.Loop1
	Movem.l	(sp)+,a0-a1
	Dbra	d1,.Loop0
	Addq.l	#2,sp
.Exit	Rts

Do_Key	Addq.w	#1,Keyb_Count
	Cmp.w	#6,Keyb_Count
	Beq.s	.DOk
	Rts
	
.DOk	Clr.w	Keyb_Count	
	Move.b	Key,d0

	Cmp.b	#$10,d0			Q
	Beq	.Quit
	Cmp.b	#$a,d0
	Beq	.Decwidth
	Cmp.b	#$b,d0
	Beq	.Incwidth
	Cmp.b	#$0c,d0			-
	Beq	.DecHeight
	Cmp.b	#$0d,d0			+
	Beq	.IncHeight
	Cmp.b	#$39,d0			Space
	Beq	.Cut
	Cmp.b	#$48,d0			CUp
	Beq	.Posup
	Cmp.b	#$50,d0			CDn
	Beq	.Posdn
	Cmp.b	#$26,d0			L
	Beq	.Load
	Cmp.b	#$1f,d0			S
	Beq	.Save
	Cmp.b	#$19,d0			P
	Beq	.Picloady
	Cmp.b	#$44,d0			F10
	Beq	.Save_Sprites
	Cmp.b	#$3b,d0			Screen down
	Beq	.Scr_Dn
	Cmp.b	#$3c,d0			Screen down
	Beq	.Scr_Up
	Cmp.b	#$01,d0			ESC!
	Beq	.Scr_Up2
	Rts

.Scr_Up2
	Rts
.Scr_Dn
	Subq.w	#2,Current_Screen
.Scr_up
	Addq.w	#1,Current_Screen
	Bpl.s	.Scr_Pos
	Clr.w	Current_Screen
.Scr_Pos
	Move.w	Current_Screen,d0
	Move.w	Max_Screen,d1
	Cmp.w	d1,d0
	Ble.s	.scr_Le9
	Move.w	d1,Current_Screen
.Scr_Le9
	Bsr	Vars1
	Bsr	Clear_Screens
	Move.w	Current_Screen,d0
	Mulu	#64000,d0
	Add.l	#Lbm0,d0
	Move.l	d0,a0
	Lea	Screen1,a1
	Move.w	#(64000/4)-1,d0
.Zloop	Move.l	(a0)+,(a1)+
	Dbra	d0,.Zloop
	Bsr	Insert_Mypal
	Bsr	Convert_Vga
	Bsr	Set_Video_Pointers
	Rts	

.Save_sprites
	Move.l	#$80008000,Prev_Mousexy
	Lea	Process_Buffer,a0
	Move.l	a0,-(sp)
	Bsr	Get_Num_Sprites
	Move.w	Num_Sprites,(a0)+	; Internal sprite number
	Lea	My_Pal,a1
	Move.w	#255,d0
.Loop	Move.l	(a1)+,(a0)+		; Copy my pallete !
	Dbra	d0,.Loop

	Lea	Sprite_Pos_Table,a1
	Move.w	Num_Sprites,d0
	Mulu	#10,d0
	St	(a1,d0)
	Lea	8*Sprite_Len(a0),a6		; Destination for sprites !
.Loop2	MOve.w	(a1)+,.Screendo
	Bmi.s	.ExitLoop
	Movem.w	(a1)+,d0-d3
	Move.l	a6,a5			; Curren dest
	Sub.l	(sp),a5			; Base of table
	Move.l	a5,(a0)+		; Save offset
	Move.w	d2,d5
	And.w	#$f,d5
	Sub.w	#16,d5
	Neg.w	d5
	And.w	#$f,d5
	Move.w	d5,Rem
	Move.w	d2,(a0)
	Add.w	d5,(a0)+
	Move.w	d3,(a0)+
	Bsr	.Form_Vga_Sprite	; Make a b/pixel sprite !
	Bra	.Loop2
.OOk	Move.w	d2,(a0)+		; Save width
	Move.w	d3,(a0)+		; Save Height
	Bsr	.Form_Vga_Sprite	; Make a b/pixel sprite !
	Bra	.Loop2

.ExitLoop
 	Move.l	a6,-(sp)		; Start 4(sp), End 0(sp)

	Clr.w	-(sp)
	Pea	Fname2
	Move.w	#$3c,-(sp)		; Create file name !
	Trap	#1
	Addq.l	#8,sp
	Tst.l	d0
	Bmi	.Ferror
	Move.w	d0,Handle
	
	Movem.l	(sp)+,d0-d1		d0=End,d1=Start
	Move.l	d1,-(sp)
	Sub.l	d1,d0			Size
	Move.l	d0,-(sp)		; Save loadsa bytes
	Move.w	Handle,-(sp)		; File handle
	Move.w	#$40,-(sp)		; Write !
	Trap	#1
	Lea	12(sp),sp
	Tst.l	d0
	Bmi	.Ferror			
	Move.w	Handle,-(sp)
	Move.w	#$3e,-(sp)		; Close file
	Trap	#1
	Addq.l	#4,sp
	Bmi	.Ferror
	Rts
	
.Form_Vga_Sprite
	Move.w	.Screendo,d5
	Mulu	#64000,d5
	Add.l	#Lbm0,d5
	Move.l	d5,a5
	Mulu	#320,d1
	Add.w	d0,d1
	Add.l	d1,a5
	Subq.w	#1,d2
	Subq.w	#1,d3
.Copy1	Move.l	a5,-(sp)
	Move.w	d2,d4
.Copy2	Move.b	(a5)+,(a6)+
	Dbra	d4,.Copy2
	Move.w	Rem,d5
.Copy3	Beq.s	.No_Copy3
	Clr.b	(a6)+
	Subq.w	#1,d5
	Bra.s	.Copy3
.No_Copy3
	Move.l	(sp)+,a5
	Lea	320(a5),a5
	Dbra	d3,.Copy1
	Rts

.Screendo	Ds.w	1

.Picloady
	St	Do_Or_Die
.Picload
	Move.l	#$80008000,Prev_Mousexy
	Move.w	#-1,Max_Screen
	Move.l	#Fname0,Pic_To_Load
	Move.l	#LBM0,Addr_To_Load
.Pic_Load_Loop
	Move.w	#0,-(sp)		; Only read
	Move.l	Pic_To_Load,-(sp)
	Move.w	#$3d,-(sp)		; Function
	Trap	#1			; Load it in
	Addq.l	#8,sp			; Re-align stack
	Tst.l	d0
	Bmi	.FError			; -ive then error ! 
	Move.w	d0,Handle		; Save handle
	Pea	Vgapic			; Address to load
	Move.l	#$80000,-(sp)		; Read loadsa bytes
	Move.w	Handle,-(sp)		; File handle
	Move.w	#$3f,-(sp)
	Trap	#1
	Lea	12(sp),sp
	Tst.l	d0
	Bmi	.Ferror			
	Move.w	Handle,-(sp)
	Move.w	#$3e,-(sp)		; Close file
	Trap	#1
	Addq.l	#4,sp
	Bmi	.Ferror
	Tst.b	Do_Or_die
	Beq.s	.No
	Bsr	Vars1
.No	Bsr	Clear_Screens
	Lea	Vgapic,a0
	Bsr	DecodeVGA
	Bsr	Insert_Mypal
	Bsr	Convert_Vga
	Lea	Screen1,a0
	Move.l	Addr_To_Load,a1
	Move.w	#320*200-1,d0
.Cloop	Move.b	(a0)+,(a1)+
	Dbra	d0,.CLoop
	Move.l	a1,Addr_To_Load
	Move.l	Pic_To_Load,a1
.Srcz	Tst.b	(a1)+
	Bne.s	.Srcz
	Move.l	a1,Pic_To_Load
	Addq.w	#1,Max_Screen
	Tst.b	(a1)
	Bpl	.Pic_Load_Loop
	CLR.W	Current_Screen
	Bsr	.Scr_Le9
	Rts
	
.FError	
	Move.l	#$ff0000ff,Pal256
	Move.l	#$ff000000,Pal256
	Bra.s	.FError
.FError2	
	Move.l	#$00000000,Pal256
	Move.l	#$ffff00ff,Pal256
	Bra.s	.FError

; Load SP file !

.Load	Move.l	#$80008000,Prev_Mousexy
	Move.w	#0,-(sp)		; Only read
	Pea	Fname1			; File name on stack !
	Move.w	#$3d,-(sp)		; Function
	Trap	#1			; Load it in
	Addq.l	#8,sp			; Re-align stack
	Tst.l	d0
	Bmi	.FError			; -ive then error ! 
	Move.w	d0,Handle		; Save handle
	Pea	Num_sprites		; Address to load
	Move.l	#Struct_end-Struct_Start,-(sp)		; Read loadsa bytes
	Move.w	Handle,-(sp)		; File handle
	Move.w	#$3f,-(sp)
	Trap	#1
	Lea	12(sp),sp
	Tst.l	d0
	Bmi	.Ferror			
	Move.w	Handle,-(sp)
	Move.w	#$3e,-(sp)		; Close file
	Trap	#1
	Addq.l	#4,sp
	Bmi	.Ferror
	Clr.b	Do_Or_Die
	Move.l	#Sprite_Pos_Table,a0
	Add.l	#Offy*10,a0
	Move.l	a0,Sprite_Pos_Pointer
	Move.w	(a0)+,Current_Screen
	Move.l	(a0)+,Boxx
	Move.w	(a0)+,Width
	Move.w	(a0)+,Height
	Clr.l	Mouse_buffer1
	Clr.l	Mouse_buffer2
	Clr.l	Boxsave1
	Clr.l	Boxsave2
	Bsr	.picload
	Bsr	Get_Num_Sprites
	Move.w	Num_Sprites,d0
	Move.w	#Sprite_Len,d1
	Sub.w	d0,d1
	Mulu	#10,d0
	Mulu	#10,d1
	Lea	Sprite_Pos_Table,a6
	Add.l	d0,a6
	Subq.w	#1,d1
.Loopx	St	(a6)+
	Dbra	d1,.Loopx
	Rts
	
.Save	Move.l	#$80008000,Prev_Mousexy
	Bsr	Get_Num_Sprites
	Clr.w	-(sp)
	Pea	Fname1
	Move.w	#$3c,-(sp)		; Create file name !
	Trap	#1
	Addq.l	#8,sp
	Tst.l	d0
	Bmi	.Ferror
	Move.w	d0,Handle

	Pea	Num_sprites		; Address to save
	Move.l	#Struct_end-Struct_start,-(sp)	; Save loadsa bytes
	Move.w	Handle,-(sp)		; File handle
	Move.w	#$40,-(sp)		; Write !
	Trap	#1
	Lea	12(sp),sp
	Tst.l	d0
	Bmi	.Ferror			
	Move.w	Handle,-(sp)
	Move.w	#$3e,-(sp)		; Close file
	Trap	#1
	Addq.l	#4,sp
	Bmi	.Ferror
	Rts

.Posdn	Move.l	Sprite_Pos_Pointer,a0
 	Tst.b	10(a0)
 	Bmi	.Error
 	Addq.l	#8,a0
 	Addq.l	#2,a0
	Move.l	a0,Sprite_Pos_Pointer
 	Move.w	(a0)+,-(sp)
 	Move.l	(a0)+,Boxx
 	Move.w	(a0)+,Width
 	Move.w	(a0)+,Height
	Move.w	Current_Screen,d2
	Move.w	(sp)+,d3
	Cmp.w	d3,d2
	Beq.s	.OOK2
	Move.w	d3,Current_Screen
	Movem.l	d0-a6,-(sp)
	Bsr	.Scr_Le9
	Movem.l	(sp)+,d0-a6
.OOK2	Move.l	#$80008000,Prev_Mousexy
	Rts 	

.Posup	Move.l	Sprite_Pos_Pointer,a0
	Cmp.l	#Sprite_Pos_Table,a0
	Beq	.Error			Start then no !
	Move.w	-(a0),Height
	Move.w	-(a0),Width
	Move.l	-(a0),Boxx
	Move.w	-(a0),-(sp)
	Move.w	Current_Screen,d2
	Move.w	(sp)+,d3
	Cmp.w	d3,d2
	Beq.s	.OOK1
	Move.w	d3,Current_Screen
	Movem.l	d0-a6,-(sp)
	Bsr	.Scr_Le9
	Movem.l	(sp)+,d0-a6
.OOK1	Move.l	a0,Sprite_Pos_Pointer
	Move.l	#$80008000,Prev_Mousexy
	Rts

.Error	Move.l	#$ff000000,Pal256
	Rts

.Cut	Moveq	#-1,d0
.Floop	Eor.l	#$ff,Pal256
	Dbra	d0,.Floop	
	Addq.l	#8,Sprite_Pos_Pointer
	Addq.l	#2,Sprite_Pos_Pointer
	Rts
	
.Decheight
	Subq.w	#1,Height
	Bgt	.Ok
	Move.w	#1,Height
	Rts
.DecWidth
	Subq.w	#1,Width	
	Bgt	.Ok
	Move.w	#1,Width
	Rts
	
.Incwidth
	Move.l	#$80008000,Prev_Mousexy
	Move.w	Mxdelta,d0
	Add.w	Width,d0
	Addq.w	#1,d0
	Cmp.w	#320,d0
	Bgt.s	.Ok
	Addq.w	#1,Width
	Cmp.w	#320,Width
	Ble.s	.Ok
	Move.w	#320,Width
	Rts	
.IncHeight
	Move.w	Mxdelta+2,d0
	Addq.w	#1,d0
	Add.w	Height,d0
	Cmp.w	#200,d0
	Bgt.s	.Ok
	Move.l	#$80008000,Prev_Mousexy
	Addq.w	#1,Height
	Cmp.w	#200,Height
	Ble.s	.Ok
	Move.w	#200,Height
.Ok	Rts	
	
.Quit	Addq.l	#4,sp
	Bra	Quit	

Addr_To_Load	Ds.l	1
Pic_to_Load	Ds.l	1

Get_Num_Sprites
	Movem.l	d0-d7/a0-a6,-(sp)
	Moveq	#1,d1
	Lea	sprite_Pos_Table,a0
.Loop	Tst.b	10(a0)
	Bmi.s	.Ok
	Addq.w	#1,d1
	Addq.l	#8,a0
	Addq.l	#2,a0
	Bra.s	.loop
.Ok	Move.w	d1,Num_Sprites	
	Movem.l	(sp)+,d0-d7/a0-a6
	Rts
		
	
Set_video_Pointers
	Movem.l	Mousep,d0-d1
	Exg	d0,d1
	Movem.l	d0-d1,Mousep
	Movem.l	Boxp,d0-d1
	Exg	d0,d1
	Movem.l	d0-d1,Boxp
	Movem.l	Screenp,d0-d1
	Exg	d0,d1
	Movem.l	d0-d1,Screenp
	Move.l	d1,X
	Move.w	#-1,d0
.Loop	Dbra	d0,.Loop
	Move.b	X+1,Bp_Hi
	Move.b	X+2,Bp_md
	Move.b	X+3,Bp_Lo+1
	Rts

x	Ds.l	1

Init	Move.w	#Col40+bps8,Screen_mode	Standard 320*200*8 screen
	Move.w	#-1,-(sp)
	Move.l	#Screen1,-(sp)
	Move.l	#Screen1,-(sp)
	Move.w	#5,-(sp)
	Trap	#14
	Lea	12(sp),sp
	Bsr	Setmode				
	Bsr	Setup			Setup interrupts, etc
 	Bsr	Buildkeymap		Position independant
	Bsr	Vars			Initial variables
	Bsr	Savepal			Save the pallete
	Bsr	Clear_Screens		Clear both screens
	Bsr	Set_Video_Pointers
	Bsr	Init_Joy		Set Timers
	Bsr	Set_Vbl			New VBL
	Rts

Vars	Lea	Mouse_Buffer1,a0
	Lea	Mouse_Buffer2,a1
	Movem.l	a0-a1,Mousep
	Lea	Boxsave1,a0
	Lea	Boxsave2,a1
	Movem.l	a0-a1,Boxp
	Lea	Screen2,a0
	Lea	Screen3,a1
	Movem.l	a0-a1,Screenp
	
	Clr.l	Boxx
	Move.w	#16,Width
	Move.w	#16,Height
	Lea	Sprite_Pos_Table,a0
	Move.w	#(5*Sprite_Len*2)-1,d0
.Loop	St	(a0)+
	Dbra	d0,.Loop
	Move.l	#Sprite_Pos_Table,Sprite_Pos_Pointer
	Clr.l	Mouse_buffer1
	Clr.l	Mouse_buffer2
	Clr.l	Boxsave1
	Clr.l	Boxsave2
	Rts


Vars1	Lea	Mouse_Buffer1,a0
	Lea	Mouse_Buffer2,a1
	Movem.l	a0-a1,Mousep
	Lea	Boxsave1,a0
	Lea	Boxsave2,a1
	Movem.l	a0-a1,Boxp
	Lea	Screen2,a0
	Lea	Screen3,a1
	Movem.l	a0-a1,Screenp
	Clr.l	Mouse_buffer1
	Clr.l	Mouse_buffer2
	Clr.l	Boxsave1
	Clr.l	Boxsave2
	Rts

Buildkeymap
	Lea	Keymap,a0
	Move.w	#255,d0
.Loop	Move.b	d0,(a0,d0)
	Dbra	d0,.Loop
	Lea	$41(a0),a0
	Lea	$20(a0),a1
	Moveq	#25,d0
.Loop2	Move.b	(a0)+,(a1)+
	Dbra	d0,.Loop2
	Rts
	
Clear_screens
	Move.l	#320*200-1,d0
	Lea	Screen1,a0
	Lea	Screen2,a1
.Loop	Sf	(a0,d0.l)
	Sf	(a1,d0.l)	
	Subq.l	#1,d0
	Bpl.s	.Loop
	Rts
	
Convert_VGA
	Move.l	#320*200,d0			; Screen size in pixels
	Lea	Screen1,a0	
	Lea	Screen2,a1
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
	Lea	Screen2,a0
	Lea	Screen3,a1
	Move.w	#320*200/4-1,d0
.Loopx	MOve.l	(a0)+,(a1)+
	Dbra	d0,.Loopx
	Rts	
	
Insert_Mypal
	Lea	My_Pal(pc),a0
	Lea	Pal256,a1
	Move.w	#$ff,d0
	Move.l	(a0),Pal256save
.Loop	Move.l	(a0)+,d1
	Move.l	d1,(a1)+
	Dbra	d0,.Loop
	Rts
Pal256save Ds.l	1

Fatal	Move.l	#$fffff,d0
.Loop	Move.l	d0,Pal256
	Subq.l	#1,d0
	Bne.s	.Loop
	Bra	Fatal
	Rts

DecodeVGA
	Move.l	a0,-(sp)
	Lea	Screen1,a1
.Bpxl	Cmp.l	a0,a1
	Beq	Fatal
	Cmp.l	#"PBM ",(a0)
	Beq.s	.Ok1
	Addq.l	#2,a0
;	Bra.s	.Bpxl

.Ok1	
	Move.l	(sp),a0
	Lea	Screen1,a1		; VGA screen
	Lea	My_pal(pc),a2		; My pallete
.SearchCMAP
 	Cmp.l	#"CMAP",(a0)		; Search for CMAP
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

Savepal	Lea	Pal(pc),a0
	Lea	Pal256,a1
	Move.w	#$ff,d0
.Loop	Move.l	(a1),d2
	Move.l	d2,(a0)+
	Addq.l	#4,a1
	Dbra	d0,.Loop
	Rts	

Restorepal
	Lea	Pal(pc),a0
	Lea	$ff9800,a1
	Move.w	#$ff,d0
.Loop	Move.l	(a0)+,d2
	Move.l	d2,d2
	Move.l	d2,(a1)
	Addq.l	#4,a1
	Dbra	d0,.Loop
	Rts	

setup	clr.l	-(sp)
	move	#$20,-(sp)
	trap	#1
	addq	#6,sp
	move.l	d0,super_save
 	move	#37,-(sp)
	trap	#1
	addq	#2,sp
	move.l	$70.w,vbl_save
	Move.b	$ff8201,Scr_Save+1
	Move.b	$ff8203,Scr_Save+2
	Move.b	$ff820d,Scr_Save+3
	rts
Set_Vbl
	move.l	#new_vbl,$70.w
	Rts

New_Vbl	Movem.l	d0-a6,-(sp)
	Move.l	#$0,Pal256
	St	Vbl_Flag
	MOvem.l	(sp)+,d0-a6
	Rte

quit	Move.l	Stacksave,a7
	Move.w	Sr,-(sp)
	Move.w	#$2700,sr
	Bsr	No_joy
	Bsr	RestorePal
	move.l	vbl_save(pc),$70.w
	Move.w	(sp)+,Sr

	move.l	super_save,-(sp)
	move	#$20,-(sp)
	trap	#1
	addq	#6,sp

	Move.w	Oldd,screen_mode
	Bsr	Setmode
	move.l	#0,-(sp)
	trap	#1

Oldd	Ds.w	1

Setmode	Move.w	Screen_mode,-(sp)
	Move.w	#88,-(sp)
	Trap	#14
	Addq.l	#4,sp
	Move.w	d0,Oldd
	rts

wait_vbl
	Clr.w	Vbl_Flag
.loop	tst.w	vbl_flag
	beq.s	.loop
	rts

*************************************************************************
* ST keyboard handler 							*
*************************************************************************
* NB:                       *
* This routine handles ALL  *
* packet types              *
*****************************
*************************************************************************
* Initialize joystick							*
*************************************************************************
init_joy
.cfoz
	move.b	$fffc00,d0
	btst	#0,d0
	beq	.ikbd_ok
.wait
	btst	#1,$fffc00
	beq	.wait
	move.b	$fffc02,d1
	bra	.cfoz
.ikbd_ok
	lea	ikbd_strt,a0
	move	#2,d7
	jsr	ikbd_send
	lea	ikbd_strm,a0
	move	#ikbd_strmL,d7
	jsr	ikbd_send
	move.l	$118,old_118
	move.l	#ikbd_int,$118
	or.b	#$40,$fffa09
	or.b	#$40,$fffa15
	bclr	#6,$fffa11
	rts
****************************************************************************
* Kill joystick				*
****************************************************************************
no_joy
	lea	off,a0
	moveq	#offl,d7
	jsr	ikbd_send
	move.l	old_118,$118
	rts
****************************************************************************
* Send a string to the ikbd				*
****************************************************************************
ikbd_send
	lea	$fffc00,a1
.loop
	move.b	(a0)+,d0
	bsr.s	send_ikbd
	dbf	d7,.loop
	rts
send_ikbd
.wait   
	btst	#1,(a1)
	beq.s	.wait
	move.b	d0,2(a1)
	rts
****************************************************************************
* Read a byte from the ikbd				*
****************************************************************************
read_ikbd
.wait   
	btst	#1,(a1)
	beq.s	.wait
	move.b	2(a1),d0
	rts
****************************************************************************
* The interrupt				*
****************************************************************************
ikbd_int
	movem.l	d0-d7/a0-a6,-(sp)
	move	sr,d0
	and	#$f8ff,d0
	or	#$500,d0
	move	d0,sr
	bclr	#6,$fffa11
	bsr	proc_key_int
	movem.l	(sp)+,d0-d7/a0-a6
	rte
proc_key_int
	lea	$fffc00,a1
	move.b	(a1),d6
	btst	#7,d6
	beq.s	.exit
	btst	#0,d6
 	beq.s	.skip
	bsr.s	read_keyb
.skip
	and.b	#$20,d6
	beq.s	.exit
	move.b	2(a1),d0
.exit
	rts
read_keyb
	moveq	#0,d0
	bsr	read_ikbd
	tst.b	packet_bcnt
	bne.s	.get_packet
	cmp	#$f6,d0
	bge.s	.start_packet
	move.b	d0,key	  ;store raw keycode
	rts
.start_packet
	move.b	d0,packet_hd    ;packet type.
	sub	#$f6,d0
	lea	packet_lens,a0
	move.b	(a0,d0),packet_bcnt     ;store length.
	rts
.get_packet
	moveq	#0,d1
	move.b	packet_bcnt,d1
	lea	packet_hd,a0
	move.b	d0,(a0,d1)
	subq.b	#1,packet_bcnt
	beq.s	.do_packet
	rts
.do_packet
	moveq	#0,d0
	move.b	packet_hd,d0
	sub	#$f6,d0
	add	d0,d0
	add	d0,d0
	move.l	.jumper(pc,d0),a6
	lea	packet_hd,a0
	jmp	(a6)
.jumper 	
	dc.l	drts,damouse,drmouse,drmouse,drmouse,drmouse,dtime,djoy2,djoy0,djoy1
drmouse
	move.b	(a0),d0
	and	#3,d0
	move	d0,mbuts
	move.b	2(a0),d0
	ext	d0
	add	d0,mxdelta
	move.b	1(a0),d0
	ext	d0
	add	d0,mydelta
drts
	Bsr	Do_Mouse_Bound
	rts
damouse
	rts
djoy0
	move.b	1(a0),port0
	rts
djoy1
	move.b	1(a0),port1
	rts
djoy2
	move.b	1(a0),d2
	move.b	2(a0),d0

	move	d0,d1
	and	#$f,d1
	and	#$f0,d0
	lsr	#4,d0
	btst	#0,d2
	beq.s	.1
	bset	#7,d0
.1
	btst	#1,d2
	beq.s	.2
	bset	#7,d1
.2
	move.b	d0,port0
	move.b	d1,port1
	rts
dtime
	rts

port0		dc.b	0
port1		dc.b	0
packet_lens	dc.b	7,5,2,2,2,2,6,2,1,1
packet_hd	ds.b	8
packet_bcnt	dc.b	0
key		ds.b	1
		even
old_118		ds.l	1
ikbd_strJ	dc.b    $12,$14         ;turn on joystick.
ikbd_strJL	equ	*-ikbd_strJ-1
ikbd_strm	dc.b	$08,$0b,1,1
ikbd_strml	equ	*-ikbd_strm-1
off		dc.b    $0a
;		dc	320,200
offl		equ	*-off-1
ikbd_strt	dc.b	$0b,$ff,$ff
		even
mxdelta		ds	1
mydelta		ds	1
Prev_MouseXy	Ds.w	2
mbuts		ds	1

Stacksave	Ds.l	1
super_save	ds.l	1
vbl_save	ds.l	1
scr_save	ds.l	1
vbl_flag	ds.w	1
Pal		Ds.l	256
My_Pal		Ds.l	256
Screen_Mode	Ds.w	1
BoxX		Ds.w	1
BoxY		Ds.w	1
Width		Ds.w	1
Height		Ds.w	1
Keymap		Ds.b	256
Keyb_Count 	Ds.w	1
MouseXY		Ds.w	2
Handle		Ds.w	1
Sprite_Pos_Pointer Ds.l	1
Do_Or_Die	Ds.w	1
Mouse_Moved	Ds.w	1
Screenp		Ds.l	2
Mousep		Ds.l	2
Boxp		Ds.l	2
Rem		Ds.w	1

BoxSave1		Ds.b	8+(320*300)
BoxSave2		Ds.b	8+(320*300)
Mouse_Buffer1	Ds.b	4+(32*32)
Mouse_Buffer2	Ds.b	4+(32*32)
Current_Screen	Ds.w	1	
Max_Screen	Ds.w	1	




*****************************************
* File names !


Fname0	
;	Dc.b	"E:\Raiden\Player\Plyships.lbm",0
;	Dc.b	"E:\Raiden\Player\Plyship.lbm",0
;	Dc.b	"E:\Raiden\Player\2Play.lbm",0
;	Dc.b	-1
	
	Dc.b	"E:\Raiden\GFX\r1.lbm",0
	Dc.b	"E:\Raiden\GFX\r2.lbm",0
	Dc.b	"E:\Raiden\GFX\r3.lbm",0
	Dc.b	"E:\Raiden\GFX\r4.lbm",0
	Dc.b	"E:\Raiden\GFX\r5.lbm",0
	Dc.b	"E:\Raiden\GFX\r6.lbm",0
	Dc.b	"E:\Raiden\GFX\r7.lbm",0
	Dc.b	"E:\Raiden\GFX\r8.lbm",0
	Dc.b	"E:\Raiden\GFX\r9.lbm",0
	Dc.b	"E:\Raiden\GFX\r10.lbm",0
	Dc.b	"E:\Raiden\GFX\r11.lbm",0
	Dc.b	"E:\Raiden\GFX\r12.lbm",0
	Dc.b	"E:\Raiden\GFX\r13.lbm",0
	Dc.b	"E:\Raiden\GFX\r14.lbm",0
	Dc.b	"E:\Raiden\GFX\r15.lbm",0
	Dc.b	"E:\Raiden\GFX\r16.lbm",0
	Dc.b	"E:\Raiden\GFX\r17.lbm",0
	Dc.b	"E:\Raiden\GFX\r18.lbm",0
	Dc.b	"E:\Raiden\GFX\r19.lbm",0
	Dc.b	"E:\Raiden\GFX\r20.lbm",0
	Dc.b	"E:\Raiden\GFX\r21.lbm",0
	Dc.b	"E:\Raiden\GFX\r22.lbm",0
	Dc.b	"E:\Raiden\GFX\r23.lbm",0
	Dc.b	"E:\Raiden\GFX\r24.lbm",0
	Dc.b	"E:\Raiden\GFX\r25.lbm",0
	Dc.b	"E:\Raiden\GFX\r26.lbm",0
	Dc.b	"E:\Raiden\GFX\r27.lbm",0
	Dc.b	"E:\Raiden\GFX\r28.lbm",0
	Dc.b	"E:\Raiden\GFX\r29.lbm",0
	Dc.b	"E:\Raiden\GFX\r30.lbm",0
	Dc.b	"E:\Raiden\GFX\r31.lbm",0
	Dc.b	"E:\Raiden\GFX\r32.lbm",0
	Dc.b	"E:\Raiden\GFX\r33.lbm",0
	Dc.b	"E:\Raiden\GFX\r34.lbm",0
	Dc.b	"E:\Raiden\GFX\r35.lbm",0
	Dc.b	-1
	Even
Fname1	
	Dc.b	"E:\Raiden\GFX\Sprites8.Sp",0
	Even
Fname2	
	Dc.b	"F:\Enemys8.spt",0
	Even

	
Mousegfx
	Dc.w	%1111110000000000
	Dc.w	%1110001000000000
	Dc.w	%1111000000000000
	Dc.w	%1011100000000000
	Dc.w	%1000100000000000
	Dc.w	%1000010000000000
	Dc.w	%0100001000000000
	Dc.w	%0000000100000000
	Dc.w	%0000000010000000
	Dc.w	%0000000001000000
	Dc.w	%0000000000100000
	Dc.w	%0000000000010000
	Dc.w	%0000000000001000
	Dc.w	%0000000000000100
	Dc.w	%0000000000000010
	Dc.w	%0000000000000001

Font	Include	e:\raiden\Raidmisc\font.inc

Vgapic	Ds.l	320*200/4
	Ds.l	32*320/4
	Cnop	0,4
Screen1	Ds.l	320*200/4
	Cnop	0,4
Screen2	Ds.l	320*200/4
	Ds.l	320*32/4
	Cnop	0,4
Screen3	Ds.l	320*200/4
	Ds.l	320*32/4

Struct_Start
Num_Sprites		Ds.w	1
Sprite_Pos_Table	Ds.w	5*Sprite_Len		; enough for 500 sprites
	Ds.w	1
Struct_End


	Ds.l	200
Ustack

Process_Buffer
	Ds.w	1			; Internal sprite number
	Ds.l	256			; pallete info
Sizes_XY
	Ds.w	Sprite_Len*4			; Size X,Y
	Ds.w	1
Sprite_Buff

Process_Buffer_End	equ sprite_buff+600000


Lbm0	equ	Process_Buffer_End
Lbm1	Equ	Lbm0+64000
Lbm2	Equ	Lbm1+64000
Lbm3	Equ	Lbm2+64000
Lbm4	Equ	Lbm3+64000
Lbm5	Equ	Lbm4+64000
Lbm6	Equ	Lbm5+64000
Lbm7	Equ	Lbm6+64000
Lbm8	Equ	Lbm7+64000
Lbm9	Equ	Lbm8+64000
Lbm10	Equ	Lbm9+64000
Lbm11	Equ	Lbm10+64000
Lbm12	Equ	Lbm11+64000
Lbm13	Equ	Lbm12+64000
Lbm14	Equ	Lbm13+64000
Lbm15	Equ	Lbm14+64000
Lbm16	Equ	Lbm15+64000
Lbm17	Equ	Lbm16+64000
Lbm18	Equ	Lbm17+64000
Lbm19	Equ	Lbm18+64000
 
 
 	End