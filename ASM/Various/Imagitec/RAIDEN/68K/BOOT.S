	; Remember to make rommer , use 68k code to decompress Rob Northern!
		Opt	P+
Booter


Ntsc_Height	Equ	226
Pal_Height	Equ	226+48
Pal_Center	Equ	(Pal_Height-Ntsc_Height)/2

Pal_Add_Center	Macro
		Lea	Ntsc_Flag(pc),a6
		Tst.b	(a6)
		Bne.s	.\@1			; Ntsc screen
		Add.w	#Pal_Center,d1
.\@1		
		Endm


Spr_VFlip	Equ	0
Spr_Hflip	Equ	1
Spr_Rotation	Equ	2

	Rsreset
Spr_data		Rs.l	1
Spr_Pixel_Width		Rs.w	1
Spr_SHeight		Rs.w	1
Spr_BitsperPixel	Rs.b	1
Spr_Flags		Rs.b	1
Spr_Yoffset		Rs.w	1
Spr_Palnum		Rs.w	1
Spr_Pad			Rs.w	1

Screen_Width		Equ		324
Screen_Height		Equ		222


	Include	"D:\Raiden\Include\jaguar.inc'	; Jaguar HARDWARE includes



rom_file_table	Equ	$804000
ROB68K
Start	Lea	$200000.l,a7
	Move.w	#$2100,sr
	Lea	File_To_Send(pc),a0
	Lea	$180000.l,a1
	Move.l	#File_To_Sende-File_To_Send,d0
.Loop	Move.b	(a0)+,(a1)+
	Subq.l	#1,d0
	Bne.s	.Loop
	Jmp	$180000.l

File_To_Send
	Bsr	Check_For_Pal_Ntsc
	Bsr	Setup_Initial_Branch
	Bsr	Setup_Object_Processor_To_Point_to_Stop

	Lea	Dataz(pc),a4
	Lea	Logo_Header(pc),a0
	Bsr	File_Load
	Move.l	a1,Logo_Header_Address(a4)
	Lea	Logo_Gfx(pc),a0
	Lea	$190000.l,a1
	Move.l	a1,Logo_Gfx_Address(a4)
	Bsr	File_Load
	Lea	Logo_Palette_Name(pc),a0
	Bsr	File_Load
	Addq.l	#2,a1
	Lea	Logo_Palette(a4),a0
	Move.w	#256-2,d0
.Loop	Move.w	(a1)+,(a0)+
	Dbra	d0,.Loop
	Move.w	-(a1),(a0)+

	Lea	Obj_List(a4),a0
	Move.l	a0,d0
	And.l	#-16,d0
	Move.l	d0,Obj_List_Pointer(a4)

	Move.l	Obj_List_Pointer(a4),Current_List_Pointer(a4)
	Move.l	Logo_Header_Address(a4),a3
	Move.l	Logo_Gfx_Address(a4),a5
	Moveq	#0,d0
	Moveq	#0,d1
	Moveq	#0,d2
	Pal_Add_Center
	Bsr	Blit_A_Sprite		
	Moveq	#0,d0
	Move.w	#200,d1
	Moveq	#1,d2
	Pal_Add_Center
	Bsr	Blit_A_Sprite		
	Move.w	#320,d0
	Move.w	#200,d1
	Moveq	#2,d2
	Pal_Add_Center
	Bsr	Blit_A_Sprite		
	Move.w	#320,d0
	Move.w	#00,d1
	Moveq	#3,d2
	Pal_Add_Center
	Bsr	Blit_A_Sprite		
	Move.l	Current_List_Pointer(a4),a0
	Move.l	#0,(a0)+
	Move.l	#4,(a0)+

	Move.l	Obj_List_Pointer(a4),a0
	Lea	VblObj_List(a4),a1
	Move.w	#16*5-1,d0
.Cloop	Move.b	(a0)+,(a1)+
	Dbra	d0,.Cloop




	Clr.w	Intens(a4)			
	Bsr	Fade
	Lea	$f00000.l,a5
	Move.w	#$0,Int1(a5)
	Pea	Interupt(pc)
	Move.l	(sp)+,$100.w
	Bsr	VideoInit
	Move.w	Height_Of_Screen(pc),d1
	Add.w	d1,d1
	Add.w	#N_Vdb+5,d1
	move.w	d1,VI(a5)
	Move.w	#$101,Int1(a5)

.Loop0	Bsr	Wait_Vbl

	Bsr	Fade_Up	
	Cmp.w	#256,Intens(a4)
	Bne.s	.Loop0

	Lea	File_Name_Txt(pc),a0
	Lea	$3000.w,a1
	Bsr	File_Load
	Add.l	d0,a1
	Lea	File_Name_DTA(pc),a0
	Bsr	File_Load

.Loop1	Bsr	Wait_Vbl
	Bsr	Fade_Down
	Cmp.w	#0,Intens(a4)
	Bne.s	.Loop1
	St	Stop_Object_Active(a4)
;	Move.w	#0,$f00028
;	Move.w	#0,Int1+$f00000
	Jmp	$3000.w

Fade_Up	Addq.w	#2,Intens(a4)
Fade_Down
	Subq.w	#1,Intens(a4)
Fade
	Move.w	Intens(a4),d0
	Lea	Logo_Palette(a4),a0
	Lea	Clut+$f00000,a1
	Move.w	#256-1,d1
.Loop	Move.w	(a0)+,d2
	Move.w	d2,d3
	And.w	#$ff,d3
	Mulu	d0,d3
	Lsr.w	#8,d3
	Move.b	d3,d2
	Move.w	d2,(a1)+
	Dbra	d1,.Loop
	Rts

Wait_Vbl
	Tst.b	Vblank_Done(a4)
	Beq.s	Wait_Vbl
	Clr.b	Vblank_Done(a4)
	Rts

Interupt
	Movem.l	d0-a6,-(sp)
	Lea	Dataz(pc),a4
	Tst.b	Stop_Object_Active(a4)
	Beq.s	.No
	Bsr	Setup_Object_Processor_To_Point_to_Stop	
	Bra.s	.Skip
.No	Move.l	Obj_List_Pointer(a4),a0
	Lea	VblObj_List(a4),a1
	Exg	a0,a1
	Move.w	#16*5-1,d0
.Cloop	Move.b	(a0)+,(a1)+
	Dbra	d0,.Cloop

	Bsr	Setup_Object_Processor
.Skip	St	Vblank_Done(a4)
	Move.w	#$101,Int1+Hardware
	Movem.l	(sp)+,d0-a6
	Move.w	#0,Int2+$f00000
	Rte


Blit_A_Sprite
	Movem.l	d0-a6,-(sp)
	Lsl.w	#4,d2
	Lea	(a3,d2),a3
	Move.l	Spr_Data(a3),a1
	Add.l	a5,a1
	Moveq	#0,d7
	Move.b	Spr_BitsPerPixel(a3),d7
	Move.w	Spr_Pixel_Width(a3),d2
	Moveq	#0,d6
	Move.b	.Pixel_Shift(pc,d7),d6
	Lsr.w	d6,d2
	Move.w	Spr_SHeight(a3),d3
	Ble.s	.No_Spr
	Add.w	Spr_Yoffset(a3),d1
	Move.l	Current_List_Pointer(a4),a0
	Move.w	Spr_Palnum(a3),d6
	Bsr	Make_An_Object
	Move.l	a0,Current_List_Pointer(a4)
.No_Spr	
	Movem.l	(sp)+,d0-a6
	Rts

.Pixel_Shift
	Dc.b	6,5,4,3,2,1


Make_An_Object
	Move.w	d7,Num_Pixels(a4)
	Move.w	d6,Pal_Number(a4)
	Cmp.w	#0,d1
	Bpl.s	.No_Miny
	Sub.w	#0,d1
	Add.w	d1,d3
	Bgt.s	.Height_There
	Rts
.Height_There
	Neg.w	d1
	Mulu	d2,d1
	Lsl.l	#3,d1
	Lea	(a1,d1.l),a1
	Moveq	#0,d1
.No_Miny
	Add.w	#(N_Vdb)/2,d1
;	Add.w	#33,d1
	Asl.w	#1,d1
	Pea	16(a0)			; Next object must take into account the maximum number of phrases for an object header (Scaled=3 phrases)
	Movem.w	d0-d3,-(sp)		; Save coardinates,Phrases wide,Height (in full lines !  not half lines!)
	Clr.l	0(a0)
	Clr.l	4(a0)
	Clr.l	8(a0)
	Clr.l	12(a0)

	Move.l	a0,d5			; Save pointer to object in unused register
	Move.l	a1,d0			; Graphic data in data register
	moveq	#8,d1
	lsl.l	d1,d0			; shift into position
	and.l	#$fffff800,d0		; mask off junk
	move.l	d0,(a0)			; store

; This places the partial result in the correct spot in memory
; Then, in the next part, it 'or's the rest of the data in.
; Doing it all in registers would be faster, but I want to see the results

	Moveq	#16,d0
	Add.l	d5,d0			; Pointer to next object			
	move.l	d0,d2			; Save pointer for bottom half
	moveq	#11,d1
	lsr.l	d1,d0			; shift for top part
	or.l	d0,(a0)+		; or in the new data

; do the bottom half in the next long word

	moveq	#21,d1
	lsl.l	d1,d2			; shift for bottom part
	and.l	#$ff000000,d2		; mask off junk
	move.l	d2,(a0)			; store (prematurely)

; Same comment here about doing this in registers instead of memory

	Move.w	3*2(sp),d0		; Get height of object

	moveq	#14,d1
	lsl.l	d1,d0			; shift it again
	or.l	d0,(a0)			; or in the new data
	Moveq	#0,d0
	Move.w	1*2(sp),d0		; Y in d0
	Ext.l	d0
	Asl.l	#3,d0			; Shift 1 extra coz of halflines-non interlace !
	And.l	#%11111111111000,D0
	Or.l	d0,(a0)+		; Object type is scaled object


; That completes another long word, First phrase done

	Moveq	#0,d0
	Move.w	2*2(sp),d0		; Retreive phrase width
	Move.l	d0,d1
	Lsr.l	#4,d1			; Drop low bits
	move.l	d1,(a0)+
	Or.l	#1<<(47-32),-4(a0)	; Set transparent
	And.w	#%1111,d0
	Move.l	d0,d5
	Ror.l	#4,d5

; Insert dwidth
	Moveq	#0,d0	
	Move.w	2*2(sp),d1
	Or.w	d1,d0			; DWIDTH ? same as IwIDTH

; Insert pitch
	moveq	#3,d1			; make room for pitch
	lsl.l	d1,d0
	ori.l	#$1,d0

; Insert depth
	moveq	#3,d1			; make room for depth

	lsl.l	d1,d0

	Move.w	Num_Pixels(a4),d1
	Or.w	d1,d0	

; Insert xpos
	moveq	#12,d1			; make room for xpos
	lsl.l	d1,d0
	Move.w	0*2(sp),d1
	And.w	#%111111111111,d1
	Add.w	d1,d0
	
; Finally store the data
	Or.l	d5,d0
	move.l	d0,(a0)+
	Move.w	Pal_Number(a4),d6
	Lsl.w	#5,d6
	Or.w	d6,-6(a0)
	Addq.l	#8,sp
	Move.l	(sp)+,a0
	rts





	Include	Video.s
	Include	Objsetup.s

	Rsreset	
Obj_List_Pointer	Rs.l	1
Current_List_Pointer	Rs.l	1
Obj_Pad			Rs.b	16
Obj_List		Rs.b	16*5
VBLObj_List		Rs.b	16*5

Logo_Header_Address	Rs.l	1
Logo_Gfx_Address	Rs.l	1
Logo_Palette		Rs.w	256
Intens			Rs.w	1
Num_Pixels		Rs.w	1
Pal_Number		Rs.w	1

Stop_Object_Active	Rs.b	1
Vblank_Done		Rs.b	1
Varend			Rs.w	0

Dataz	Ds.b		Varend
	Even


Setup_Object_Processor_To_Point_to_Stop
	Move.l	Dont_Know_What_This_Does_Pointer(pc),d0
	Subq.l	#8,d0
	Swap	d0
	Move.l	d0,OLP+$f00000
	Rts

Setup_Object_Processor
	Move.l	Dont_Know_What_This_Does_Pointer(pc),a0
	Lea	16(a0),a0
	Move.l	Obj_List_Pointer(a4),a1
	Move.w	#BRA_VCEQ,d0
	Move.w	#$7ff,d1
	Bsr	Make_Branch_Object
	Move.l	Dont_Know_What_This_Does_Pointer(pc),d0
	Swap	d0
	Move.l	d0,OLP+$f00000
	Rts



Logo_Header
	Dc.b	"BOOTLOGO.JHD",0
Logo_GFX
	Dc.b	"BOOTLOGO.JSP",0
Logo_Palette_Name
	Dc.b	"BOOTLOGO.CPL",0
File_Name_Txt
	Dc.b	"RAIDEN.TXT",0
File_Name_DTA
	Dc.b	"RAIDEN.DTA",0
	Even

file_load:	movem.l	d1-d7/a0-a6,-(sp)	;save all registers
		lea	rom_file_table,a6
		move.w	(a6)+,d2		a6 points to table of offsets.l
		lsl.w	#2,d2			d2*2
		lea	4(a6,d2.w),a5		a5 points to the filenames
		moveq	#0,d6			d6 is file number
.loop		move.b	(a5),d7
		cmp.b	#-1,d7
		bne.s	.valid_char
		illegal				file not found
.valid_char	move.l	a0,a2			copy the filename accross
.a_loop		tst.b	(a5)			see if end of filename in rom
		bne.s	.cont			if not then continue
		tst.b	(a2)			  else then check end of filename in ram
		beq.s	.found			    if so then file name found
		bne.s	.not_found		      else its not this filename
.cont		cmp.b	(a2)+,(a5)+		compare characters
		beq.s	.a_loop			if same the carry on
.not_found	addq.w	#4,d6
.wait_till_zero	tst.b	(a5)+			find the next filename
		bne.s	.wait_till_zero
		bra.s	.loop			loop until file is found
.found		move.l	(a6,d6.w),a0
		add.l	a6,a0
		moveq	#0,d0
		Cmp.l	#"RNC"<<8+1,(a0)
		Bne.s	.Not_Compressed		
		Move.l	4(a0),-(sp)
		Ifnd	ROB68K
		Jsr	DECOMPRESSGPUPP1
		Jsr	WAITFORGPU
		Else
		bsr.s	PP_UNPACK
		Endc
		Addq.l	#8,(sp)
		And.l	#-8,(sp)
		movem.l	(sp)+,d0-d7/a0-a6	;restore registers
		rts
.Not_Compressed	Moveq	#0,d0	
		Move.l	a0,$20(sp)
		movem.l	(sp)+,d1-d7/a0-a6	;restore registers
		Rts

		Ifd	ROB68K
		include	rnc_1.s	
		Endc

Check_For_Pal_Ntsc
	Move.w	$f14002.l,d0
	Lea	Ntsc_Flag(pc),a0
	Lea	Height_Of_Screen(pc),a1
	Btst	#4,d0
	Sne	(a0)				; Set this flag if  ntsc !
	Beq.s	.Pal_Screen
	Move.w	#Ntsc_Height,(a1)
	Rts	
.Pal_Screen
	Move.w	#Pal_Height,(a1)
	Rts

Ntsc_Flag		Ds.w	1
Height_Of_Screen	Ds.w	1

File_To_Sende
