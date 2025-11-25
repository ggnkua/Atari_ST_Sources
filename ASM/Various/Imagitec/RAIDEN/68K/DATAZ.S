; RAIDEN DATA STUFF  (C)FREDDY, DONT FUCKING TAKE !

	Include	Hies.S
	Include	AnmCv.s
	Even

Panel_Palette
	Incbin	D:\Raiden\Gamedata\Panel.Cpl
	Ds.w	20
Alien_Sine
	Incbin	D:\Raiden\Gamedata\Sine.Bin
	Incbin	D:\Raiden\Gamedata\Sine.Bin

	Include	LinkInfo.s
	Include	Diskname.s
	Include	Score.s
	Include	SpInfo.s
	Include	Pevent.s
	Include	Wepanims.s
	Include	Spranims.s
	Include	DedRouts.s
	Include	Paral.s
Arc_Tan
	Include	Angle.s
	Include	Flames.s
	Even
	Ifeq	Load_Event
Event_Data
	Include	D:\Raiden\Level_5\Event1.Src
	Endc

Paralax_Event
	Ds.b	102
	Dc.b	-1
	Ds.b	235-102
	Dc.b	-1
XParalax_Event
	Ds.b	400-(XParalax_Event-Paralax_Event)
	Even

rom_file_table=$804000

intmask		dc.b	1
	Even

	Section BSS
Pre_Generated_Objects		Ds.b	16*Maximum_Amount_Of_Sprites
Pre_Generated_Player_Objects	Ds.b	16*Maximum_Amount_Of_Player_Sprites
Data	Ds.b	Varend	
	Even
Pre_Sines		
	Ds.l	256*16
	Cnop	0,4
	Ds.w	4
Alien_Boxes
	Ds.w	4*Maximum_Amount_Of_Sprites
Player_Boxes
	Ds.w	Maximum_Amount_Of_Player_Sprites*4
	Cnop	0,4
Pl1	Ds.b	PVarend
	Cnop	0,4
Pl2	Ds.b	PVarend
	Even

Joyedge	Ds.l	2
JoyCur	Ds.l	2
	Ds.w	1
Mypal	Ds.w	256
DestPal	Ds.w	256
Plates_Ram	Ds.w	24*4
Element_Table
	Ds.w	19*2
Dummy_Sprite
	Ds.b	Aln_End

	Ds.b	8
Stuff_To_Load
	Ds.l	Load_Buff_Size/4
Player_Sprites	
	Ds.l	(280000)/4
Screen1	Ds.b	BACKDROP_MEM*2

Player_1_Script	Equ	$1ff000
Player_2_Script	Equ	$1ff800

	End