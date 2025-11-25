; ATARI & IMAGITEC PRESENTATION !
; Freddy / RAIDEN!

MakeDisk=1
	Include	E:\INCLUDES\SYSTREGS.INC
	Include	E:\Raiden\MACROS.S
	Ifeq	Makedisk
	Include	Spool.s
	Endc

Frame_Rate	Equ	1
Byteswide	Equ	384

Start	Bsr	Go
	Clr.w	-(sp)
	Trap	#1

Go	Bsr	Init			; Initialize

Main	Bsr	Send_Atari		; Display ATARI Fuji
	Bsr	Swap_Screens		; Display it !
	Sf	Vbl_Flag(a4)		; No flag
	Clr.w	I(a4)
	Clr.w	D(a4)
	Clr.w	P(a4)	
	Clr.w	B(a4)			; Clear color intensities

.Mn1	Bsr	Wait_Vbl		; Wait a VBL
	Bsr	Fade_Pal		; Fadeup pal
	Bsr	Cycle_Atari		; Cycle Atari colours
	Addq.w	#4,Intens(a4)
	Cmp.w	#256,Intens(a4)
	Ble.s	.Mn1			; Until we get to top
	Move.w	#256,Intens(a4)
	Move.w	#400,-(sp)		; for 8 seconds
.Mn2	Bsr	Wait_Vbl
	Bsr	Fade_Pal
	Bsr	Cycle_Atari
	Subq.w	#1,(sp)			; Cycle the Atari logo
	Bne.s	.Mn2
	Addq.l	#2,sp
.Mn3	Bsr	Wait_Vbl
	Bsr	Fade_Pal
	Bsr	Cycle_Atari
	Subq.w	#4,Intens(a4)
	Bge.s	.Mn3			; Then Fade down Atari Logo
	Clr.l	Intens(a4)	
	Clr.l	Intens+2(a4)		; Used for RGB fade
	Bsr	Send_Idl
	Bsr	Swap_Screens		; Display IDL logo
	Sf	Vbl_Flag(a4)
SS
.Mn3	Bsr	Wait_Vbl
	Bsr	Fade_Pal2		; Fade up letters
	Bsr	Add_I			; Add intensity of "I" "D" "L"
	Bne.s	.Mn3
	Move.w	#299,d7
.Mn4	Bsr	Wait_Vbl		; Wait 6 seconds
	Dbra	d7,.Mn4
	Move.w	#256,Intens(a4)
	Move.w	#256,Intens+2(a4)	; Intensity of RGB components
	Move.w	#256,Intens+4(a4)
.Mn5	Bsr	Wait_Vbl
	Bsr	Fade_Pal3
	Bsr	Sub_I			; Fade down at different speeds
	Bne.s	.Mn5
	Bsr	Setup_Screens
	Move.l	Screenp+4(a4),Temp_Screenp(a4)	; Setup ready for 2 consequtive screens
	Bsr	Send_Presents		; display presents ensignia
	Move.l	#$ff,d1
	Divu	#200,d1
	Move.w	d1,Color_Add(a4)	; Colour proportion for 200 lines
	Swap	d1
	Mulu	#$ff,d1
	MOve.w	d1,Color_Add+2(a4)
	Bsr	Clears2
	Sf	Vbl_Flag(a4)
	St	PP(a4)	

XX	Bsr	Wait_Vbl
	Bsr	Fade_Presents		; Fade up presents & scroll it
	Addq.w	#2,Sine_Val(a4)
	Cmp.w	#200,Sine_Val(a4)	; Until 200 lines done
	Bne.s	XX
	Sf	PP(a4)
	Bra	Quit

***********************************************************
Clears2
	Move.l	#64000/4-1,d0
	MoveM.l	Screenp(a4),A0-A1
.Loop	Move.l	(a0),(a1)+		; Copy decoded LBM image to screen2
	Clr.l	(a0)+			; We see from Screen1
	Dbra	d0,.loop
	Rts

***********************************************************
Get_Pointer
	Move.l	Temp_Screenp(a4),a1
	Move.w	Sine_Val(a4),d0
	Lea	Circ(pc),a0
	Lsr.w	#1,d0
	Move.w	(a0,d0*2),d0
	Mulu	#200,d0
	Swap	d0
	Sub.w	#200,d0
	Neg.w	d0
	Mulu	#Byteswide,d0
	Sub.l	d0,a1
	Move.l	a1,a0
	Bsr	Write_Screen			; Get screen address along a half circle table
	Rts

***********************************************************
Fade_Presents
	Lea	Mypal(a4),a0
	Lea	Dest_pal(a4),a1
	Move.w	Color_Val(a4),d0
	Move.w	#256,d1
	Bsr	Scale_Pal
	Move.l	Color_Add(a4),d0
	Add.l	d0,Color_Val(a4)
	Add.l	d0,Color_Val(a4)
	Rts

***********************************************************
Sub_I	Subq.w	#2,Intens(a4)
	Subq.w	#4,Intens+2(a4)
	Subq.w	#6,Intens+4(a4)
	Sf	d7
	Lea	Intens(a4),a0
	Bsr.s	.Do
	Bsr.s	.Do
	Bsr.s	.Do
	Tst.b	d7
	Rts

.Do	Cmp.w	#0,(a0)+
	Bgt.s	.No
	Move.w	#0,-2(a0)
	Rts
.No	St	d7
	Rts

***********************************************************
Add_I	Addq.w	#4,I(a4)
	Cmp.w	#94,I(a4)
	Blt.s	.Check
	Addq.w	#4,D(a4)
	Cmp.w	#94,D(a4)
	Blt.s	.Check
	Addq.w	#4,P(a4)
	Cmp.w	#94,P(a4)
	Blt.s	.Check
	Addq.w	#4,B(a4)
.Check	Lea	I(a4),a0
	Moveq	#3,d7
	Sf	d6
.Loop	Cmp.w	#256,(a0)+
	Bge.s	.Skip1
	St	d6
	Bra.s	.Skip2
.Skip1	Move.w	#256,-2(a0)
.Skip2	Dbra	d7,.Loop
	Tst.b	d6
	Rts


***********************************************************
Fade_Pal2
	Move.w	I(a4),d0
	Move.w	#52,d1
	Lea	Mypal(a4),a0
	Lea	Dest_Pal(a4),a1
	Bsr	Scale_Pal
	Move.w	D(a4),d0
	Move.w	#53,d1
	Lea	Mypal+3*52(a4),a0
	Lea	Dest_Pal+4*52(a4),a1
	Bsr	Scale_Pal
	Move.w	P(a4),d0
	Move.w	#87,d1
	Lea	Mypal+169*3(a4),a0
	Lea	Dest_Pal+169*4(a4),a1
	Bsr	Scale_Pal
	Move.w	B(a4),d0
	Move.w	#64,d1
	Lea	Mypal+105*3(a4),a0
	Lea	Dest_Pal+105*4(a4),a1
	Bsr	Scale_Pal
	Rts	

Fade_Pal3
	Movem.w	Intens(a4),d0-d2
	Lea	Mypal(a4),a0
	Lea	Dest_pal(a4),a1
	Move.w	#256,d7
	Bsr	Scale_Pal2
	Rts

Scale_Pal2
	Subq.w	#1,d7
.Loop	Movem.w	Clear(a4),d3-d5
	Move.b	(a0)+,d3
	Move.b	(a0)+,d4
	Move.b	(a0)+,d5
	Mulu	d0,d3
	Mulu	d1,d4
	Mulu	d2,d5
	Lsr.w	#8,d3
	Lsr.w	#8,d4
	Lsr.w	#8,d5
	Move.b	d3,(a1)+
	Move.b	d4,(a1)+
	Clr.b	(a1)+
	Move.b	d5,(a1)+
	Dbra	d7,.Loop
	Rts

***********************************************************
Cycle_Atari
	Lea	Mypal+172*3(a4),a0
	Move.l	a0,a1
	Move.b	(a1)+,-(sp)
	Move.b	(a1)+,-(sp)
	Move.b	(a1)+,-(sp)
	Exg	a0,a1
	Move.w	#241-172-1,d0
.Loop	Move.b	(a0)+,(a1)+
	Move.b	(a0)+,(a1)+
	Move.b	(a0)+,(a1)+
	Dbra	d0,.Loop
	Move.b	(sp)+,(a1)+
	Move.b	(sp)+,(a1)+
	Move.b	(sp)+,(a1)+
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
Send_Presents
	Lea	Presents_Buffer,a0
	Bra.s	Skip_A
Send_Idl
	Lea	Idl_Buffer,a0
	Bra.s	Skip_A
Send_Atari
	Lea	Atari_Buffer,a0
Skip_A	Move.l	Screenp+4(a4),a1
	Lea	Mypal(a4),a2
	Bsr	Decode_Vga	
	Movem.l	Screenp(a4),a0-a1
	Exg	a0,a1
	Bsr	Convert_Vga	
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
; Address in a0
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
Init	Lea	Data(pc),a4		; Globals
	Bsr	Install_Screen		; Set logical screen base
	Bsr	Cleardata		; Clear all globals
	Bsr	Setup_Screen_Mode	; 8 plane / overscan
	Bsr	Setup			; Supervisor + Shit
	Bsr	Setup_Screens		; Clear both screens
	Bsr	Save_Vbl		; Save vertical blank
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
	Cmp.b	#2,d0			; Using VGA monitor ?
	Seq	Vga_Flag(a4)		; Set if using VGA Monitor	
	Bne.s	.Not_Vga		; No !
	Move.w	#$64,Screen_Mode(a4)	; Set VGA monitor bit!
	Bra.s	.Skip			; set mode anyway!
.Not_Vga 
	Move.w	#$63,Screen_Mode(a4)	; Normal ST monitor 8 bpl,320x256
.Skip	Bsr	Setmode			; Set screen mode 8bps,PAL/OVERscan!
	Rts

**********************************************************
Quit	
	Ifeq	Makedisk
	Bsr	Fade_Syspal
	Endc
	Lea	Data(pc),a4
	Move.w	Mod_Save(a4),Scr_Mod
	Move.w	Del_Save(a4),Scr_Del
	Move.l	Vbl_save(a4),$70.w			
	Move.w	Old_Mode(a4),Screen_Mode(a4)	
	Ifeq	Makedisk
	Bsr	Setmode			
	Rts
	Else
	Addq.l	#4,sp
	Rts
	Endc
	
**********************************************************
; supervisor + save sys state!

Setup	Move.w	Scr_Del,Del_Save(a4)
	Move.w	Scr_Mod,MOD_Save(a4)
	move	#37,-(sp)
	trap	#1
	addq.l	#2,sp
	rts

**********************************************************
; Save/Set Vbl
Save_Vbl
	move.l	$70.w,Vbl_save(a4)	; Save vbl
	Pea	New_Vbl(pc)
	Move.l	(sp)+,$70.w		; Set VBL
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
	Moveq	#-4,d2			; Mask long word boundry
	And.l	d2,d0
	And.l	d2,d1
	Movem.l	d0-d1,Screenp(a4)	; Save screen pointers
	Bsr	Clear_Screens
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
Setmode	Move.w	Screen_mode(a4),d0
	Or.b	#$20,d0
	Tst.b	$7c.w
	Bne.s	.Pal
	And.b	#$df,d0
.Pal	Move.w	d0,-(sp)
	Move.w	#88,-(sp)
	Trap	#14
	Addq.l	#4,sp
	Move.w	d0,Old_Mode(a4)			Save the old mode!
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
	Trap	#1			; Read key > d0
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
	Tst.b	PP(a4)
	Beq.s	.Skip
	Bsr	Get_Pointer	
.Skip	Bsr	Copy_Dest
	Addq.b	#1,Vbl_Flag(a4)
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
	Cmp.b	#Frame_Rate,Vbl_Flag(a4)
	Bne.s	Wait_Vbl
	Sf	Vbl_Flag(a4)
	Rts

**********************************************************
; a0=Decoded VGA pic, a1=DEST!
Convert_VGA
	Move.l	a1,a2
	Move.w	#(92160/4)-1,d0
.Loopx	Clr.l	(a1)+
	Dbra	d0,.Loopx
	Move.l	a2,a1

	Move.w	#239,d4
.Xloop	Move.w	#383,d0
	Move.l	a1,-(sp)
	Move.w	#$8000,d7
.Loop	Move.b	(a0)+,d1
	Moveq	#7,d6				; Convert from B/Pixel
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
	Pea	(a1)
	Move.w	#23040-1,d0
.Loop0	Clr.l	(a1)+
	Dbra	d0,.Loop0
	Move.l	(sp)+,a1

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
	Lea	7712(a1),a1
	Move.w	#320,d7
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
	Bsr	Check320
	Subq.b	#1,d1
	Bge.s	.Copyloop		Decrement loop
	Sub.l	d3,d0			Away from total count
	Bgt.s	.ByterunLoop	
	Bra.s	.Byterunexit	
.Run	Move.b	(a0)+,d2		byte to repeat !
.Rloop	Move.b	d2,(a1)+		Byte in
	Bsr	Check320
	Addq.b	#1,d1			Decrement loop
	Ble.s	.RLoop
	Subq.l	#2,d0
	Bgt.s	.ByterunLoop
.Byterunexit
	Rts

Check320
	Subq.w	#1,d7
	Bne.s	.Nx1
	Lea	64(a1),a1
	Move.w	#320,d7
.Nx1	Rts

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
Vbl_Save	Rs.l	1
Screenp		Rs.l	2
I		Rs.w	1
D		Rs.w	1
P		Rs.w	1
B		Rs.w	1
Temp_Screenp	Rs.l	1
Sine_Val	Rs.w	1
Color_Val	Rs.l	1
Color_Add	Rs.l	1
Intens		Rs.w	3
Dest_Pal	Rs.l	256
Mypal		Rs.b	3*256
Vga_Flag	Rs.b	1
PP		Rs.b	1
Vbl_Flag	Rs.b	1
Key_Pressed	Rs.b	1
Varend		Rs.b	0


Data	Ds.b	Varend
	Even


Circ		
		Dcb.w	800,$ffff
;	Incbin	E:\Raiden\Raidmisc\Sine.Bin
Atari_Buffer	Incbin	E:\Raiden\Raidmisc\Atari.LBM
Idl_Buffer	Incbin	E:\Raiden\Raidmisc\Idl-logo.LBM
Presents_Buffer	Incbin	E:\Raiden\Raidmisc\Presents.LBM

	Ds.b	2	
Screen1	Ds.l	23040
	Ds.b	2	
Screen2	Ds.l	23040
