	Dc.l	0
Link_Offsets
 	Ds.l	7
 	Dc.l	Tank_Link			;7
 	Ds.l	10-8
	Dc.l	Powerup_Link
 	Ds.l	14-11
	Dc.l	Mid_2_Link			;14
	Ds.l	32-15
	Dc.l	Planedown_Link			;32
	Dc.l	Planeup_Link			;33
	Ds.l	39-34
	Dc.l	Bigtank_Link			;38
	Ds.l	54-40
	Dc.l	Bomb_Link			;54
	Ds.l	58-55
	Dc.l	Guardian1_Link			;58
	Ds.l	64-59
	Dc.l	Enlarged_Link			;64
	Ds.l	66-65
	Dc.l	Cannon_Link			;66
	Ds.l	69-67
	Dc.l	Powerup_Boat_Link		;69
	Ds.l	71-70
	Dc.l	Boat_Turret_Link
	Dc.l	Boat_Turret_Link
	Dc.l	Boat_Turret_Link
	Dc.l	Boat_Turret_Link		;74
	Ds.l	78-75
	Dc.l	Front_Train_Link		;78
	Ds.l	80-79
	Dc.l	Front_Carraige_Link		;80
	Ds.l	83-81
	Dc.l	Diagonal_Train_Link		;83
	Ds.l	85-84
	Dc.l	Diagonal_Carraige_Link		;85
	Ds.l	87-86
	Dc.l	Guardian2_Link
	Ds.l	99-88
	Dc.l	Rscaf_Link
	Ds.l	101-100
	Dc.l	Lscaf_Link
	Ds.l	103-102
	Dc.l	Hovercraft_Link
	Ds.l	106-104
	Dc.l	Monstrous_Tank_Link
	Ds.l	108-107
	Dc.l	Jeep_Link
	Ds.l	111-109
	Dc.l	Guardian3_Link
	Ds.l	130-112
	Dc.l	Alien_Plane_Link

	Dc.l	Floaty_Link	
	Ds.l	1
	Dc.l	Humongous_Tanklink
	Ds.l	138-134
	Dc.l	Terrain_Uplink
	Dc.l	Terrain_Rightlink
	Ds.l	146-140
	Dc.l	Powerup_holdLink
	Ds.l	160-147
	Dc.l	Lev4_Endlink
	Ds.l	172-161
	Dc.l	Lev4_Extlink1
	Dc.l	Lev4_Extlink2
	Ds.l	177-174
	Dc.l	Track_Tank_Link
	Ds.l	179-178
	Dc.l	Plane_garage_Link
	Ds.l	186-180
	Dc.l	Lev5_Endbaddy_Link
	Ds.l	197-187
	Ds.l	1
	Ds.l	199-198
	Dc.l	0		Bigboat_Link_Right
	Ds.l	205-200
	Dc.l	Cannon_Link2
	Ds.l	208-206
 	Dc.l	Tank_Link2
	Ds.l	212-209
	Dc.l	Guardian1a_Link			
	Ds.l	223-213
	Dc.l	Silly_Tankup_Link
	Dc.l	Silly_TankRight_Link
	Ds.l	230-225
	Dc.l	Bigboat_Link_Right
	Ds.l	237-231
	Dc.l	Bigboat_Link_Left
	Dc.l	Joint_Link
	Ds.l	240-239
	Dc.l	Bit_Goesup_Link

	Ds.l	243-241
	Dc.l	UD_Spider_Link
	Dc.l	LR_Spider_Link
	Ds.l	254-245 
	Dc.l	Tank_Link3			; Black tank!

	Ds.l	270-255
	Dc.l	Baddy_Link7
	Ds.l	278-271
	Dc.l	Silly_Tankleft_Link

	Ds.l	281-279
	Dc.l	Spinny_Plane_Link

	Ds.l	284-282
	Dc.l	Fucker_Plane_Link
	
	Ds.l	289-285
	Dc.l	Plane_garage_Link2
	Dc.l	Humongous_Tanklink
	Ds.l	294-291
	Dc.l	Cannon_Link3

	Ds.l	296-295
	Dc.l	Huge_Cannon_Link

	Ds.l	311-297
	Dc.l	Endbaddy_6_Link
	Ds.l	320-312
	Dc.l	Bunker1_Link
	Dc.l	Bunker2_Link
	Ds.l	358-322
	Dc.l	Baddy8_Link
	Ds.l	360-359
	Dc.l	Wing_Link1	
	Dc.l	Wing_Link2	
	Ds.l	371-362
	Dc.l	Wing_Link1	
	Dc.l	Wing_Link2	

	Ds.l	100

Wing_Link1	
	Dc.l	.Add
	V_Ent	$7fff,367,300,-10,Do_Nothing_Seq	
	Dc.w	-1
.Add	Dc.w	11,11

Wing_Link2
	Dc.l	.Add
	V_Ent	$7fff,367,300,-10,Do_Nothing_Seq	
	Dc.w	-1
.Add	Dc.w	11,11


Baddy8_Link
	Dc.l	.Add
	V_Ent	800,359,300,-10,Alien_8_Guard_seq
	V_Ent	800,365,300,-10,Do_Nothing_Seq	
	V_Ent	$7fff,362,300,-10,Alien8_Fire
	V_Ent	200,363,300,-10,Alien_8_Guard_seq
	V_Ent	200,364,300,-10,Alien_8_Guard_seq
	Dc.w	-1
.Add	Dc.w	48,0
	Dc.w	32,46

	Dc.w	31,11
	Dc.w	10,11
	Dc.w	54,11

Alien_8_Guard_seq
	Hit	0
.Hold	Branch	.Hold

Alien8_Fire
	Stop_Anim
	Wait	120
	Start_Anim
	Wait	3
	Fire_Ship	170
	Branch	Alien8_Fire
	


Spinny_Plane_Link
	Dc.l	.Add
	V_Ent	$7fff,11,300,-10,Do_Nothing_Seq	
	Dc.w	-1
.Add	Dc.w	7,-10

Bunker1_Link
	Dc.l	.Add
	V_Ent	$7fff,323,-50,0,Hold_Seq
	Dc.l	-1
.Add	Dc.w	0,0

Bunker2_Link
	Dc.l	.Add
	V_Ent	$7fff,322,-50,0,Hold_Seq
	Dc.l	-1
.Add	Dc.w	0,0


Endbaddy_6_Link
	Dc.l	.Add
	V_Ent	$7fff,327,-50,0,.Colour_Cyc1
	V_Ent	$7fff,329,-50,0,Hold_Seq
	V_Ent	$7fff,329,-50,0,Hold_Seq
	V_Ent	$7fff,328,-50,0,Hold_Seq
	V_Ent	$7fff,328,-50,0,Hold_Seq
	V_Ent	110,330,-50,0,.Hold_SeqHead
	V_Ent	110,331,-50,0,.Hold_SeqHead

	V_Ent	150,332,-50,0,Hold_Seq
	Dc.w	-1
.Add	Dc.w	32,10
	
	Dc.w	-7,28
	Dc.w	36,28
	Dc.w	-7,-10
	Dc.w	36,-10

	Dc.w	04,05
	Dc.w	41,05

	Dc.w	0,0


.Hold_SeqHead
	Hit		0
	Branch		.Hold_SeqHead
	
	
	

.Colour_Cyc1
	Abs_Move	0,1,60
	Change_Prev_Anim	1,333
	Abs_Move	0,1,100
	Change_Prev_Anim	1,311	
.Hold	Branch		.Hold		


Asteroid_Seq
	Abs_Move	0,0,74
	Fire_Ship	125
	Branch		Asteroid_Seq
Head_Track1	
	Hit		1
	Set_Angle	$c0
	Track		20
Head_Track1a	
	Rep	4
	Track	6
	Change_Anim	318
	Noop
	Change_Anim	319
	Noop
	Fire_Ship	126
	Noop
	Change_Anim	318
	Noop
	Change_Anim	317
	Repend
	Track	80
	Noop
	Change_Anim	318
	Noop
	Change_Anim	319
	Rep		6
	Track		7
	Fire_Ship	127	
	Repend
	Change_Anim	318
	Noop
	Change_Anim	317
	Track		50
	Branch		Head_Track1a	



Head_Track2	
	Hit		1
	Set_Angle	$40
	Track		30
	Branch		Head_Track1a	

Huge_Cannon_Link
	Dc.l	.Add
	V_Ent	80,297,-50,0,Hold_Seq
	V_Ent	80,298,-50,0,Hold_Seq
	V_Ent	80,300,-50,0,Hold_Seq
	Dc.w	-1
.Add	Dc.w	0,32
	Dc.w	16,24
	Dc.w	09,64

Fucker_Plane_Link
	Dc.l	.Add
	V_Ent	80,285,-50,0,.Fuker_Fuck
	V_Ent	80,286,-50,0,Hold_Seq
	V_Ent	80,287,-50,0,Hold_Seq
	V_Ent	80,288,-50,0,.Fucker_Fire

	V_Ent	80,339,-50,0,Hold_Seq
	V_Ent	80,339,-50,0,Hold_Seq

	Dc.l	-1
.Add	
	Dc.w	64,0
	Dc.w	0,40
	Dc.w	64,40
	Dc.w	64-5,18

	Dc.w	23,6
	Dc.w	71,6


.Fucker_Fire
	Stop_Anim
.Back	Abs_Move	0,1,70
	Start_Anim
	Wait_Anim	4
	Pause_Anim	
	Rep		5
	Fire_Ship	119
	Abs_Move	0,1,3
	Repend
	Fire_Ship	120
	Unpause_Anim
	Stop_Anim
	Branch		.Back

.Fuker_Fuck
	Abs_Move	0,1,100
	Fire_Ship	121
	Branch		.Fuker_Fuck

Baddy_Link7
	Dc.l	.Add
	V_Ent	80,271,-50,0,Hold_Seq

	V_Ent	02,277,-50,0,Fire_Row_1
	V_Ent	02,277,-50,0,Fire_Row_1
	V_Ent	02,277,-50,0,Fire_Row_1
	V_Ent	02,-1,-50,0,Hold_Seq
	V_Ent	02,-1,-50,0,Hold_Seq

	V_Ent	02,277,-50,0,Fire_Row_3
	V_Ent	02,277,-50,0,Fire_Row_3
	V_Ent	02,277,-50,0,Fire_Row_3
	V_Ent	02,277,-50,0,Fire_Row_3
	V_Ent	02,277,-50,0,Fire_Row_3
	V_Ent	02,277,-50,0,Fire_Row_3
	V_Ent	02,-1,-50,0,Hold_Seq
	V_Ent	02,-1,-50,0,Hold_Seq

	V_Ent	02,277,-50,0,Fire_Row_4
	V_Ent	02,277,-50,0,Fire_Row_4
	V_Ent	02,277,-50,0,Fire_Row_4
	V_Ent	02,277,-50,0,Fire_Row_4
	V_Ent	02,277,-50,0,Fire_Row_4
	V_Ent	02,277,-50,0,Fire_Row_4


	V_Ent	80,272,-50,0,Hold_Seq
	V_Ent	80,273,-50,0,Hold_Seq

;	V_Ent	80,275,-50,0,Hold_Seq
;	V_Ent	80,275,-50,0,Hold_Seq
	V_Ent	80,-1,-50,0,Hold_Seq
	V_Ent	80,-1,-50,0,Hold_Seq

;	V_Ent	80,276,-50,0,Hold_Seq
;	V_Ent	80,276,-50,0,Hold_Seq
	V_Ent	80,-1,-50,0,Hold_Seq
	V_Ent	80,-1,-50,0,Hold_Seq

	V_Ent	80,357,-50,0,Major_7_Hitter

	Dc.w	-1
.Add	
	Dc.w	-48,65
;1
	Dc.w	57,36,73,36,89,36

	Dc.w	33,50,113,50


;2
	Dc.w	33+2,65,113,65
	Dc.w	33-16+3,65,113+16,65
	Dc.w	33-32+3,65,113+32,65

	Dc.w	33,65,113-8,65
;3
	Dc.w	33-32+8,65+16,106+32,65+16
	Dc.w	33-48+8,65+16,106+48,65+16
	Dc.w	33-16+8,65+16,106+16,65+16

	Dc.w	33-47,161,136,161

	Dc.w	-078,164,176,164

	Dc.w	-044,224,162,224

	Dc.w	57,50

Fire_Row_1
	Stop_Anim
	Abs_Move	0,1,150
	Branch		Lev7_Turret_Fire
Fire_Row_2
	Stop_Anim
	Abs_Move	0,1,200
	Branch		Lev7_Turret_Fire
Fire_Row_3
	Stop_Anim
	Abs_Move	0,1,250
	Branch		Lev7_Turret_Fire
Fire_Row_4
	Stop_Anim
	Abs_Move	0,1,300
	Branch		Lev7_Turret_Fire

Lev7_Turret_Fire
	Start_Anim
	Wait_Anim	4
	Pause_Anim
	Fire_Ship	157
	Wait		3
	UnPause_Anim
	Stop_Anim
	Wait		150
	Branch		Lev7_Turret_Fire


Major_7_Hitter
	Wait		300
	Wait		5
	Fire_Ship	158
	Wait		5
	Fire_Ship	159
	Wait		5
	Fire_Ship	160
	Wait		5
	Fire_Ship	161
	Wait		5
	Fire_Ship	162
	Wait		5
	Fire_Ship	163
	Wait		5
	Fire_Ship	164
	Wait		5
	Fire_Ship	165
	Wait		5
	Fire_Ship	164
	Wait		5
	Fire_Ship	163
	Wait		5
	Fire_Ship	162
	Wait		5
	Fire_Ship	161
	Wait		5
	Fire_Ship	160
	Wait		5
	Fire_Ship	159
	Wait		5
	Fire_Ship	158
	Branch		Major_7_Hitter






UD_Spider_Link
	Dc.l	.Add
	V_Ent	80,251,-50,0,UD_Spider_Seq
	Dc.l	-1
.Add	Dc.w	12,10

LR_Spider_Link
	Dc.l	.Add
	V_Ent	80,252,-50,0,LR_Spider_Seq
	Dc.l	-1
.Add	Dc.w	10,12


UD_Spider_Seq
LR_Spider_Seq
	Stop_Anim
	Abs_Move	0,0,50
	Start_Anim
	Noop
	Noop
	Noop
	Fire_Ship	111
	Branch		LR_Spider_Seq




Joint_Link
	Dc.l	.Bit_Add
	V_Ent	80,247,-50,0,Four_Fire
	V_Ent	80,248,-50,0,Hold_Seq		; left
	V_Ent	80,249,-50,0,Hold_Seq		; right
	V_Ent	80,250,-50,0,Hold_Seq		; down 
	V_Ent	80,246,-50,0,Hold_Seq

	V_Ent	80,253,-50,0,Hold_Seq
	V_Ent	80,253,-50,0,Hold_Seq
	V_Ent	80,253,-50,0,Hold_Seq
	V_Ent	80,253,-50,0,Hold_Seq
	Dc.l	-1
.Bit_Add
	Dc.w	+15,-09
	Dc.w	-10,+14
	Dc.w	+43,+13
	Dc.w	+16,+39

	Dc.w	+16,+30

	Dc.w	+06,+07
	Dc.w	+33,+07
	Dc.w	+06,+28
	Dc.w	+33,+28

Four_Fire
	Abs_Move	0,0,100
	Change_Link_Anim	5,245
	Change_Link_Anim	6,245
	Change_Link_Anim	7,245
	Change_Link_Anim	8,245
	Fire_Ship	92
	Abs_Move	0,0,8
	Change_Link_Anim	5,253
	Change_Link_Anim	6,253
	Change_Link_Anim	7,253
	Change_Link_Anim	8,253
	Branch		Four_Fire


Bit_Goesup_Link
	Dc.l	.Bit_Add
	V_Ent	80,241,-50,0,Hold_Seq
	V_Ent	80,242,-50,0,Hold_Seq
	Dc.l	-1
.Bit_Add
	Dc.w	8,-27
	Dc.w	9,32
	

Silly_Tankleft_Link
	Dc.l	.Tank_Add
	V_Ent	80,225,-50,0,TrackerSilly_Seq
	V_Ent	80,279,-50,0,Hold_Seq
	Dc.l	-1
.Tank_Add
;	Dc.w	5,5
;	Dc.w	0,-3

	Dc.w	15,6
	Dc.w	0,-3


Silly_Tankup_Link
	Dc.l	.Tank_Add
	V_Ent	80,225,-50,0,TrackerSilly_Seq
	V_Ent	80,226,-50,0,Hold_Seq
	Dc.l	-1
.Tank_Add
	Dc.w	6,4
	Dc.w	-3,1


Silly_TankRight_Link
	Dc.l	.Tank_Add
	V_Ent	80,225,-50,0,TrackerSilly_Seq
	V_Ent	80,227,-50,0,Hold_Seq
	Dc.l	-1
.Tank_Add
	Dc.w	5,5
	Dc.w	1,-3

TrackerSilly_Seq
	Track		80
	Rep		4
	Fire_Ship	88
	Track		7
	Repend
	Branch		TrackerSilly_Seq

Bigboat_Link_Right
	Dc.l	.Boat_Add
	V_Ent	80,233,-50,0,Hold_Seq
	V_Ent	$7fff,231,200,0,Hold_Seq
	V_Ent	$7fff,236,100,10,Hold_Seq
	V_Ent	6,119,10,10,Boat_Left_Turret_fire
	V_Ent	6,119,150,10,Boat_Right_Turret_fire

	V_Ent	6,340,150,10,Do_Nothing_Seq
	V_Ent	6,341,150,10,Do_Nothing_Seq
	V_Ent	6,341,150,10,Do_Nothing_Seq
	V_Ent	6,342,150,10,Do_Nothing_Seq
	V_Ent	6,342,150,10,Do_Nothing_Seq

	Dc.l	-1

.Boat_Add
	Dc.w	-22,2,112,-1
	Dc.w	39,13,2,15
	Dc.w	85,15

	Dc.w	-1,54
	Dc.w	18,59
	Dc.w	71,59
	Dc.w	18,-10
	Dc.w	71,-10

;--------
Bigboat_Link_Left
	Dc.l	.Boat_Add
	V_Ent	80,234,-50,0,Hold_Seq
	V_Ent	$7fff,232,200,0,Hold_Seq
	V_Ent	$7fff,236,100,10,Hold_Seq
	V_Ent	6,119,10,10,Boat_Left_Turret_fire
	V_Ent	6,119,150,10,Boat_Right_Turret_fire

	V_Ent	6,340,150,10,Do_Nothing_Seq
	V_Ent	6,341,150,10,Do_Nothing_Seq
	V_Ent	6,341,150,10,Do_Nothing_Seq
	V_Ent	6,342,150,10,Do_Nothing_Seq
	V_Ent	6,342,150,10,Do_Nothing_Seq

	Dc.l	-1

.Boat_Add
	Dc.w	113,-1
	Dc.w	-32,2
	Dc.w	40,08,2,15
	Dc.w	85,15

	Dc.w	-1,54
	Dc.w	18,59
	Dc.w	71,59
	Dc.w	18,-10
	Dc.w	71,-10


Boat_Left_Turret_fire
	Pause_Anim
.Boat_Left_Turret_fire
	Track		100
	UnPause_Anim
	Wait_Anim	4
	Change_Anim	203
	Rep	5
	Track	15
	Fire_Ship	79
	Repend
	Wait_Anim	1
	Change_Anim	204
	Wait_Anim	4
	Pause_Anim
	Change_Anim	119
	Branch	.Boat_Left_Turret_fire


Boat_Right_Turret_fire
	Pause_Anim
.Boat_Right_Turret_fire
	Track		100
	UnPause_Anim
	Wait_Anim	4
	Change_Anim	203
	Rep	5
	Track	7
	Fire_Ship	80
	Repend
	Track	8*5
	Wait_Anim	1
	Change_Anim	204
	Wait_Anim	4
	Pause_Anim
	Change_Anim	119
	Branch	.Boat_Right_Turret_fire



Lev5_Endbaddy_Link
	Dc.l	.Lev5_add
	V_Ent	$7fff,187,300,-10,Big_Gun5_Seq
	V_Ent	100,188,300,-10,Hold_Seq
	V_Ent	100,189,300,-10,Hold_Seq

	V_Ent	$7fff,352,300,-10,Hold_Seq
	V_Ent	$7fff,353,300,-10,Hold_Seq
	V_Ent	$7fff,354,300,-10,Hold_Seq


	V_Ent	$7fff,191,300,-10,Twin_Turret_Fire
	V_Ent	$7fff,190,300,-10,Twin_Turret_Fire

	V_Ent	$7fff,192,300,-10,Lev5_Sideshot_Seqb
	V_Ent	$7fff,192,300,-10,Lev5_Sideshot_Seqb

	V_Ent	$7fff,192,300,-10,Lev5_Sideshot_Seqb
	V_Ent	$7fff,192,300,-10,Lev5_Sideshot_Seqb

	V_Ent	$7fff,193,300,-10,Lev5_Sideshot_Seqb
	V_Ent	$7fff,193,300,-10,Lev5_Sideshot_Seqb

	V_Ent	$7fff,194,300,-10,Backfire1
	V_Ent	$7fff,194,300,-10,Backfire1

	Dc.l	-1
.Lev5_add
	Dc.w	16,20
	Dc.w	-16,30,16,30
	Dc.w	-0,-0
	Dc.w	-16,30,16,30
	Dc.w	+16,45,16,45

	Dc.w	-48+48,33,-32+48,33
	Dc.w	64+16-48,33,64+32-48,33

	Dc.w	03,83,48,83
	Dc.w	04,45,52,45

	Dc.w	04,90,80,00
	
Plane_garage_Link
	Dc.l	.Plane_Add
	V_Ent	$7fff,180,300,-10,Hold_Seq
	V_Ent	$7fff,181,300,-10,Hold_Seq
	V_Ent	$7fff,182,300,-10,Hold_Seq
	V_Ent	$7fff,184,300,-10,Hold_Seq
	V_Ent	$7fff,183,300,-10,Hold_Seq
	V_Ent	$7fff,185,300,-10,Hold_Seq
	Dc.l	-1
.Plane_Add
	Dc.w	48,0
	Dc.w	0,18
	Dc.w	16,26
	Dc.w	48,26
	Dc.w	64,18

	Dc.w	32,26

Plane_garage_Link2
	Dc.l	.Plane_Add
	V_Ent	$7fff,301,300,-10,Hold_Seq
	V_Ent	$7fff,302,300,-10,Wing_Fire_Seq
	V_Ent	$7fff,303,300,-10,Wing_Fire_Seq
	V_Ent	$7fff,304,300,-10,Wing_Fire_Seq
	V_Ent	$7fff,305,300,-10,Wing_Fire_Seq
	V_Ent	$7fff,306,300,-10,Wing_Fire_Seq

	V_Ent	$7fff,11,300,-10,Do_Nothing_Seq
	V_Ent	$7fff,11,300,-10,Do_Nothing_Seq

	Dc.l	-1
.Plane_Add
	Dc.w	48,0
	Dc.w	0,18
	Dc.w	16,26
	Dc.w	48,26
	Dc.w	64,18
	Dc.w	32,26

	Dc.w	08,-9
	Dc.w	56,-9
	

Wing_Fire_Seq
	Stop_Anim
	Abs_Move	0,1,70
	Start_Anim
	Fire_Ship	156
	Stop_Anim
	Branch	Wing_Fire_Seq
	



Track_Tank_Link
	Dc.l	.Track_ext
	V_Ent	$7fff,178,300,-10,.Fire_Seq
	Dc.l	-1
.Track_Ext
	Dc.w	08,09

.Fire_Seq
	Stop_Anim
	Abs_Move	0,0,60
	Start_Anim
	Wait_Anim	4
	Fire_Ship	113
	Stop_Anim
	Branch		.Fire_Seq



Lev4_Extlink2
	Dc.l	.Lev4_Ext
	V_Ent	$7fff,175,300,-10,LEV4_EXTSEQ
	Dc.l	-1
.Lev4_Ext
	Dc.w	11,16

Lev4_Extlink1
	Dc.l	.Lev4_Ext
	V_Ent	$7fff,175,300,-10,LEV4_EXTSEQ
	Dc.l	-1

.Lev4_Ext
	Dc.w	25,14

Lev4_Endlink
	Dc.l	.Lev4_Add
	V_Ent	$7fff,161,300,-10,Do_Nothing_Seq
	V_Ent	$7fff,162,300,-10,Do_Nothing_Seq
	V_Ent	$7fff,163,300,-10,Do_Nothing_Seq

	V_Ent	20,175,300,-10,Bolty4_Seq3
	V_Ent	20,175,300,-10,Bolty4_Seq3
	V_Ent	20,175,300,-10,Bolty4_Seq2
	V_Ent	20,175,300,-10,Bolty4_Seq2
	V_Ent	20,345,300,-10,Bolty4_Seq
	V_Ent	20,345,300,-10,Bolty4_Seq

	V_Ent	$7fff,176,300,-10,Do_Nothing_Seq
	Dc.l	-1
.Lev4_Add
	Dc.w	63,0,0,48,63,48
	Dc.w	30,04
	Dc.w	70,04
	Dc.w	14,32
	Dc.w	87,32
	Dc.w	28,59
	Dc.w	75,59
	
	Dc.w	44,23
	
Powerup_holdLink
	Dc.l	.Powerup_holdAdd
	V_Ent	$7fff,346,300,-10,Do_Nothing_Seq
	V_Ent	$7fff,347,300,-10,Do_Nothing_Seq

;	V_Ent	$7fff,147,300,-10,Do_Nothing_Seq
	V_Ent	$7fff,-1,300,-10,Do_Nothing_Seq
	V_Ent	$7fff,150,300,-10,Do_Nothing_Seq
	V_Ent	$7fff,151,300,-10,Do_Nothing_Seq
	V_Ent	$7fff,148,300,-10,Do_Nothing_Seq
	V_Ent	$7fff,149,300,-10,Do_Nothing_Seq
	Dc.l	-1

.Powerup_holdAdd
	Dc.w	-80+8,12
	Dc.w	+107-5,12

	Dc.w	16-5,11
	Dc.w	-56+8,07
	Dc.w	+55-5,07
	Dc.w	-88+8,2
	Dc.w	+100-5,2


	
Terrain_Rightlink
	Dc.l	.Terrainup_Add
	V_Ent	$7fff,143,300,-10,.LRFIrE
	V_Ent	$7fff,144,300,-10,Do_Nothing_Seq
	V_Ent	$7fff,145,300,-10,Do_Nothing_Seq
	Dc.w	-1
.Terrainup_Add
	Dc.w	07,12
	Dc.w	14,28
	Dc.w	14,0

.Lrfire
	Stop_Anim
	Abs_Move	0,1,60
	Start_Anim
	Fire_Ship	117
	Stop_Anim
	Abs_Move	0,1,20
	Start_Anim
	Fire_Ship	118
	Branch	.Lrfire


Terrain_Uplink
	Dc.l	.Terrainup_Add
	V_Ent	$7fff,140,300,-10,.UDFIRE
	V_Ent	$7fff,141,300,-10,Do_Nothing_Seq
	V_Ent	$7fff,142,300,-10,Do_Nothing_Seq
	Dc.w	-1

.Terrainup_Add
	Dc.w	16,5
	Dc.w	1,13,36,13

.UDFIRE	
	Stop_Anim
	Abs_Move	0,1,60
	Start_Anim
	Fire_Ship	115
	Stop_Anim
	Abs_Move	0,1,20
	Start_Anim
	Fire_Ship	116
	Branch		.UDFIRE

Humongous_Tanklink
	Dc.l	.Humong_add
	V_Ent	$7fff,134,300,-10,Do_Nothing_Seq
	V_Ent	$7fff,135,300,-10,Do_Nothing_Seq
	V_Ent	$7fff,136,300,-10,.Open_Hut_Anim
	V_Ent	$7fff,137,300,-10,.Open_Hut_Anim

	V_Ent	$7fff,107,300,0,.Hum_Track_Seq
	V_Ent	$7fff,107,300,0,.Hum_Track_Seq
	V_Ent	$7fff,107,300,0,.Hum_Track_Seq
	V_Ent	$7fff,107,300,0,.Hum_Track_Seq
	V_Ent	$7fff,107,300,0,.Hum_Cannon_ud_seq
	Dc.w	-1
	
.Humong_add
	Dc.w	02,48
	Dc.w	46,48
	Dc.w	04,07
	Dc.w	40,07
	Dc.w	05,10
	Dc.w	05,28
	Dc.w	42,10
	Dc.w	42,28
	Dc.w	22,18

.Open_Hut_Anim
	Stop_Anim
	Abs_Move	0,1,100
	Start_Anim
	Wait_Anim	4
	Pause_Anim
	Abs_Move	0,1,100
	Stop_Anim
	UnPause_Anim
	Branch		.Open_Hut_Anim


.Hum_Track_Seq
	Track	100
	Rep	3
	Track	35
	Fire_Ship	122
	Repend
	Branch	.Hum_Track_Seq

.Hum_Cannon_ud_seq
	Gosub	.Qfire
	Rep	10
	Track	1
	Move_Child	0,0,1
	Repend
	Rep	10
	Track	1
	Move_Child	0,0,-1
	Repend
	Gosub	.Qfire
	Rep	10
	Track	1
	Move_Child	0,0,-1
	Repend
	Rep	10
	Track	1
	Move_Child	0,0,1
	Repend
	Branch		.Hum_Cannon_ud_seq

.Qfire
	Rep	4
	Fire_Ship	88	
	Track		8
	Repend	
	Return
	
Floaty_Link	
	Dc.l	.Float_Add
	V_Ent	2,280,300,-10,.Float_Seq
	Dc.w	-1
	
.Float_Add
	Dc.w	16,16

.Float_Seq
	Stop_Anim
	Wait		60
	Start_Anim
	Abs_Move	0,1,4
	Fire_Ship	114
	Branch		.Float_Seq
	End_Seq

Boat_Turret_Link
	Dc.l	.Boat_Add
.Turret_Link
	V_Ent	02,008,0,0,Track_Seq1
	Dc.w	-1
.Boat_Add
	Dc.l	$80008001

Tank_Link
	Dc.l	.Tank_Add
.Turret_Link
	V_Ent	02,008,0,0,Track_Seq1
	Dc.w	-1
.Tank_Add
	Dc.l	$80008000

Tank_Link2
	Dc.l	.Tank_Add
.Turret_Link
	V_Ent	02,209,0,0,Track_Seq1
	Dc.w	-1
.Tank_Add
	Dc.l	$80008000



Tank_Link3
	Dc.l	.Tank_Add
.Turret_Link
	V_Ent	02,255,0,0,Track_Seq2y
	Dc.w	-1
.Tank_Add
	Dc.l	$80008000



Track_Seq2y
	Track		50
	Fire_Ship	188
	Branch		Track_Seq2y


Powerup_Link
	Dc.l	.Powerup_Add
.Powerup_Link
	V_Ent	$7fff,56,300,-10,Powerup_FireSeq
	V_Ent	$7fff,11,300,-10,Do_Nothing_Seq
	V_Ent	$7fff,11,300,-10,Do_Nothing_Seq
	V_Ent	$7fff,23,300,-10,Do_Nothing_Seq
	V_Ent	$7fff,23,300,-10,Do_Nothing_Seq

	V_Ent	$7fff,23,300,-10,Do_Nothing_Seq
	V_Ent	$7fff,23,300,-10,Do_Nothing_Seq

	V_Ent	$7fff,11,300,-10,Do_Nothing_Seq
	V_Ent	$7fff,11,300,-10,Do_Nothing_Seq	

	Dc.w	-1
.Powerup_Add
	Dc.w	16,9,8,-6,24,-6,0,11,32,11

	Dc.w	+3,24,+28,+24

	DC.W	0,0,32,0



Mid_2_Link
	Dc.l	.Mid2_Add
.Mid2_Link
	V_Ent	$7fff,15,0,0,Mid2Track_Seq
	V_Ent	$7fff,16,0,0,Do_Nothing_Seq
	V_Ent	$7fff,17,0,0,Do_Nothing_Seq
	V_Ent	$7fff,18,0,0,Do_Nothing_Seq
	V_Ent	$7fff,19,0,0,Do_Nothing_Seq
	V_Ent	$7fff,19,0,0,Do_Nothing_Seq
	V_Ent	$7fff,20,0,0,Do_Nothing_Seq
	V_Ent	$7fff,20,0,0,Do_Nothing_Seq
	Dc.w	-1
.Mid2_Add
	Dc.w	-05,3,16,3
	Dc.w	-12,8,32,6
	Dc.w	01,-03,17,-03
	Dc.w	03,42,19,42
	
Alien_Plane_Link
	Dc.l	.AlienPlane_Add
	V_Ent	$7fff,11,300,-10,Do_Nothing_Seq
	V_Ent	$7fff,11,300,-10,Do_Nothing_Seq
 	Dc.w	-1
.AlienPlane_Add	
	Dc.w	27,-9,22,-9

Planedown_Link
	Dc.l	.Plane_Add
	V_Ent	$7fff,11,300,-10,Do_Nothing_Seq
	V_Ent	$7fff,11,300,-10,Do_Nothing_Seq
 	Dc.w	-1
.Plane_Add
	Dc.w	39,5,9,5

Planeup_Link
	Dc.l	.Planeup_Add
.Plane_UPlnk
	V_Ent	$7fff,12,300,-10,Do_Nothing_Seq
	V_Ent	$7fff,12,300,-10,Do_Nothing_Seq
 	Dc.w	-1
.Planeup_Add
	Dc.w	40,43,8,43

Bigtank_Link
	Dc.l	.Bigtank_Add
.Big_Tank_Link
	V_Ent	$7fff,40,300,-10,Bigtank_Seq
	V_Ent	$7fff,40,300,-10,Bigtank_Seq
	V_Ent	$7fff,40,300,-10,Bigtank_Seq
	V_Ent	$7fff,40,300,-10,Bigtank_Seq
	V_Ent	$7fff,57,300,-10,Bigtank_Seq
	Dc.w	-1

.Bigtank_Add
	Dc.w	-4,+2,+25,+2,-4,+23,+23,+23
	Dc.w	0,0


Bomb_Link
	Dc.l	.Rot_Add	
.Bomb_Link
	V_Ent	15,55,232,-64,Do_Nothing_Seq
	Dc.w	-1
.Rot_Add	
	Dc.w	-8,-30






Guardian1_Link
	Dc.l	.Level1_Add
.End_Level1_Link
	V_Ent	$7fff,59,232,100,Do_Nothing_Seq
	V_Ent	$7fff,59,232,100,Do_Nothing_Seq
	V_Ent	$7fff,59,232,100,Do_Nothing_Seq
	V_Ent	$7fff,59,232,100,Do_Nothing_Seq
	V_Ent	$7fff,60,232,100,Lev1_Seqb
	V_Ent	$7fff,61,232,100,Lev1_Seqc
	V_Ent	$7fff,62,232,100,Lev1_Seqd
	V_Ent	$7fff,63,232,100,Lev1_Seqe
	V_Ent	$7fff,386,100,-64,Lev1_Seqa
	Dc.w	-1
.Level1_Add
	Dc.w	-8,4,+55,4,-8,55,55,+55	
	Dc.w	+10,+48,-01,+35,+63,+35,+53,+48
	Dc.w	+24,+27

Guardian1a_Link
	Dc.l	.Level1_Add
.End_Level1_Link
	V_Ent	$7fff,213,232,100,Do_Nothing_Seq
	V_Ent	$7fff,213,232,100,Do_Nothing_Seq
	V_Ent	$7fff,213,232,100,Do_Nothing_Seq
	V_Ent	$7fff,213,232,100,Do_Nothing_Seq
	V_Ent	$7fff,214,232,100,Lev1_Seqba
	V_Ent	$7fff,215,232,100,Lev1_Seqca
	V_Ent	$7fff,216,232,100,Lev1_Seqda
	V_Ent	$7fff,217,232,100,Lev1_Seqea
	V_Ent	$7fff,386,100,-64,Lev1_Seqaa
	Dc.w	-1
.Level1_Add
	Dc.w	-8,4,+55,4,-8,55,55,+55	
	Dc.w	+10,+48,-01,+35,+63,+35,+53,+48
	Dc.w	+24,+27

Enlarged_Link
.Enlarged_Link
	Dc.l	.Enlarged_Add
	V_Ent	$7fff,65,100,-64,Do_Nothing_Seq
	V_Ent	$7fff,65,100,-64,Do_Nothing_Seq
	Dc.w	-1
.Enlarged_Add
	Dc.w	10,-24,24,-24

Cannon_Link
	Dc.l	.Cannon_Add
.Cannon_Link
	V_Ent	03,67,100,-64,Track_Seq3
	Dc.w	-1
.Cannon_Add
	Dc.l	0

Cannon_Link3
	Dc.l	.Cannon_Add
.Cannon_Link
	V_Ent	05,295,100,-64,Track_Seq3
	Dc.w	-1
.Cannon_Add
	Dc.l	0


Cannon_Link2
	Dc.l	.Cannon_Add
.Cannon_Link
	V_Ent	04,206,100,-64,Track_Seq3
	Dc.w	-1
.Cannon_Add
	Dc.l	0



Powerup_Boat_Link		;69
	Dc.l	.Bigboat_Add
.Boat_Bit_Link
	V_Ent	02,070,0,0,Track_Seq0
	Dc.w	-1
.Bigboat_Add
	Dc.w	5,10

Front_Train_Link		;78
	Dc.l	.Train_Add
.Train_Link
	V_Ent	$7fff,79,100,-64,Do_Nothing_Seq
	Dc.w	-1
.Train_Add
	Dc.w	16,0

Front_Carraige_Link		;80
	Dc.l	 .Carraige_Add
.Carraige_Link
	V_Ent	$7fff,81,100,-64,Do_Nothing_Seq
	V_Ent	$7fff,82,100,-64,Carraige_Seq
	Dc.w	-1
.Carraige_Add
	Dc.w	62-46,0,53-46,4

Diagonal_Train_Link		;83
	Dc.l	.Diagonal_Train_Add
.DTrain_Link
	V_Ent	$7fff,84,100,-64,Do_Nothing_Seq
	Dc.w	-1
.Diagonal_Train_Add
	Dc.w	0,16

Diagonal_Carraige_Link		;85
	Dc.l	.Diagonal_Carraige_Add
.DCarraige_Link
	V_Ent	$7fff,86,100,-64,Carraige_Seq
	Dc.w	-1
.Diagonal_Carraige_Add
	Dc.w	8,7

Carraige_Seq
	Pause_Anim
	Track	37
	Unpause_Anim
	Wait_Anim	7
	Fire_Ship	1
	Wait_Anim	14
	Pause_Anim
	Branch		Carraige_Seq
	


Guardian2_Link
	Dc.l	.Level2_Add
.End_Lev2_Link
	V_Ent	$7fff,88,0,0,Centerright2_Seq
	V_Ent	$7fff,91,0,0,Do_Nothing_Seq
	V_Ent	$7fff,91,0,0,Do_Nothing_Seq
	V_Ent	$7fff,92,0,0,Center_Lev2seqNormal
	V_Ent	60,89,0,0,Secondfireseq1
	V_Ent	60,90,0,0,Secondfireseq2
	Dc.w	-1
.Level2_Add
	Dc.w	48,0,81,46,0,46,+41,+21
	Dc.w	-48+20,+30,95-20,+30

Rscaf_Link
	Dc.l	.Rscaf_Add
.Rscaf_Link
	V_Ent	10,102,340,-52,Do_Nothing_Seq
	Dc.w	-1
.Rscaf_Add
	Dc.w	48,0

Lscaf_Link
	Dc.l	.Lscaf_Add
.Lscaf_Link
	V_Ent	10,100,340,-52,Do_Nothing_Seq
	Dc.w	-1
.Lscaf_Add
	Dc.w	-40,0

Hovercraft_Link
	Dc.l	.Travel_Add
.Boat3_Link
	V_Ent	10,104,340,-52,Hover_TrackSeq
	V_Ent	10,105,340,-52,Do_Nothing_Seq
	V_Ent	10,105,340,-52,Do_Nothing_Seq
	Dc.w	-1
.Travel_Add
	Dc.w	16,14,9,47,32,47

Monstrous_Tank_Link
	Dc.l	.Mon_Add
.Mons_Link
	V_Ent	10,107,200,-32,Track_Seq0
	Dc.w	-1
.Mon_Add
	Dc.w	11,10

Jeep_Link
	Dc.l	.Jeep_Add
.Jeep_Link
	V_Ent	10,109,140,-52,Do_Nothing_Seq
	V_Ent	10,110,140,-52,Do_Nothing_Seq
	Dc.w	-1
.Jeep_Add
	Dc.w	-1,-16,6,-14

Guardian3_Link
	Dc.l	.Level3_Add
.End_Lev3_Link
	V_Ent	$7fff,112,100,-200,Do_Nothing_Seq

;	V_Ent	50,113,100,-200,Do_Nothing_Seq
;	V_Ent	50,114,100,-200,Do_Nothing_Seq
	V_Ent	50,-1,100,-200,Do_Nothing_Seq
	V_Ent	50,-1,100,-200,Do_Nothing_Seq

	V_Ent	50,115,100,-200,Do_Nothing_Seq

	V_Ent	50,116,100,-200,Do_Nothing_Seq
	V_Ent	50,117,100,-200,Do_Nothing_Seq
	V_Ent	50,118,100,-200,Do_Nothing_Seq

	V_Ent	50,121,100,-200,Backturrets_Seq3
	V_Ent	50,122,100,-200,Backturrets_Seq3B
	
	V_Ent	5,120,100,-200,Lev3baddy_turretseq4
	V_Ent	5,120,100,-200,Lev3baddy_turretseq3
	V_Ent	5,120,100,-200,Lev3baddy_turretseq2
	V_Ent	5,120,100,-200,Lev3baddy_turretseq1
	V_Ent	5,120,100,-200,Lev3baddy_turretseq4
	V_Ent	5,120,100,-200,Lev3baddy_turretseq3
	V_Ent	5,120,100,-200,Lev3baddy_turretseq2
	V_Ent	5,120,100,-200,Lev3baddy_turretseq1
	
	V_Ent	50,123,100,-200,NearlyMadLev3_Seq

	V_Ent	50,221,100,-200,Do_Nothing_Seq
	V_Ent	50,221,100,-200,Do_Nothing_Seq

	V_Ent	50,377,100,-200,Do_Nothing_Seq

	Dc.w	-1


.LeveL3_Add
	Dc.w	64,0,00,64,64,64

	Dc.w	0,48,64,48
	Dc.w	0,112,64,112

	Dc.w	67,7,16,7

	Dc.w	24,93+16
	Dc.w	24,76+16
	Dc.w	24,59+16
	Dc.w	24,42+16

	Dc.w	24+32,93+16
	Dc.w	24+32,76+16
	Dc.w	24+32,59+16
	Dc.w	24+32,42+16

	Dc.w	40,13

	Dc.w	05,34,107,34

;	Dc.w	30,27
	Dc.w	30,32

**********************************************************
Cannon_Fodder_Fireseq
	Unpause_Anim
	Start_Anim
	Wait		4
	Fire_Ship	62
	Stop_Anim
	Wait		90
	Branch		Cannon_Fodder_Fireseq
	

Mad_Guardian2Seq
	Abs_MOVE	0,2,10
.Back	Abs_Move	0,1,30
	Abs_Move	0,0,20
	Abs_Move	-1,1,100
	Abs_Move	+1,1,200
	Abs_Move	-1,1,100
	Abs_Move	0,2,20
	Branch		.Back

Secondfireseq1
	Wait		60
	Fire_Ship	45
	Branch		SecondFireseq1
Secondfireseq2
	Wait		60
	Fire_Ship	46
	Branch		SecondFireseq2
Centerright2_Seq
	Wait		70
	Rep 		3
	Fire_Ship	48
	Wait		7
	Fire_Ship	47
	Wait		7
	Fire_Ship	49
	Wait		7
	Fire_Ship	47
	Wait		7
	Fire_Ship	48
	Wait		7	
	Fire_Ship	49
	Repend
	Branch		Centerright2_Seq

Center_Lev2seq
	Stop_Anim
	Wait		20
	Start_Anim
	Wait		10
	Pause_Anim
	Rep		5
	Fire_Ship	50
	Wait		4
	Fire_Ship	51
	Wait		4
	Fire_Ship	52
	Wait		4
	Fire_Ship	53
	Wait		4
	Fire_Ship	202
	Wait		4
	Fire_Ship	203
	Wait		4
	Fire_Ship	204
	Wait		4
	Fire_Ship	204
	Repend
	UnPause_Anim
	Stop_Anim
	Wait		55
	Fire_Ship	54
	Wait		5
	Fire_Ship	55
	Wait		5
	Fire_Ship	56
	Wait		5
	Fire_Ship	57
	Wait		5
	Fire_Ship	58
	Wait		5
	Fire_Ship	59
	Wait		5
	Fire_Ship	59
	Wait		5
	Fire_Ship	58
	Wait		5
	Fire_Ship	57
	Wait		5
	Fire_Ship	56
	Wait		5
	Fire_Ship	55
	Wait		5
	Fire_Ship	54
	Wait		5
	Branch		Center_Lev2seq

Center_Lev2seqNormal
	Stop_Anim
	Branch		Center_Lev2seqNormal

Mid2Track_Seq
	Track	150
.Back	Track	60
	Rep	3
	Fire_Ship	33
	Track	3
	Fire_Ship	34
	Track	3
	Fire_Ship	35
	Track	3
	Fire_Ship	36
	Track	3
	Fire_Ship	37
	Track	3
	Fire_Ship	38
	Track	3
	Fire_Ship	39
	Track	3
	Fire_Ship	40
	Track	3
	Repend
	Branch		.Back
	
Hover_TrackSeq
	Track		$7fff
	Branch		Hover_TrackSeq

Bigtank_Seq
	Animate_Only_If_Moving	
	Branch		Bigtank_Seq

Powerup_FireSeq
	Stop_Anim
	Wait		100
	Rep		3
	Start_Anim
	Wait		5
	Fire_Ship	2
	Stop_Anim
	Wait		50
	Repend
.Hold	Branch		.Hold

Bonus_Sprite_Sequence
	Abs_Move	0,0,50
	End_Seq	

Up_Plane_Seq
	Abs_Move	0,-1,30		
	Abs_Move	0,-2,60		
	Abs_Move	0,-2,60		
	Fire_Ship	29
	Abs_Move	0,-3,2
	Fire_Ship	30
	Abs_Move	0,-3,2
	Fire_Ship	31
	Abs_Move	0,-3,2
	Fire_Ship	32
	Abs_Move	0,-4,30		
	Abs_Move	0,-5,20
	End_Seq
Branch_Seq
	Abs_Move	0,1,300
	End_Seq
Branch_Seq_Power
	Check_Y_Bound	
	End_Seq

Spit_Home_Seq
	Spit_Home
	End_Seq
Fuck_Seq
	End_Seq
Angel_Seq	
	Abs_Move	-2,-1,40
	Rep		6
	Abs_Move	0,-4,20
	Abs_Move	+4,+4,20
	Abs_Move	0,-4,20
	Abs_Move	-4,+4,25
	Repend
	Abs_Move	0,2,140
	End_Seq	

Track_Seq1	
	Set_Angle	$80
.Track_Seq1	
	Track		180
	Fire_Ship	188
	Branch		.Track_Seq1

Do_Nothing_Seq
	Branch	Do_Nothing_Seq


Lev1_Seqa
	Hit		OFF
	Track		110
.Seq28	
	Fire_Ship	24
	Wait		5
	Fire_Ship	25
	Wait		5
	Fire_Ship	26
	Wait		5
	Fire_Ship	27
	Wait		5
	Rep		5
	Track		3
	Fire_Ship	14
	Repend	
	Track		100
	Branch		.Seq28
Lev1_Seqb
	Stop_Anim
	Wait		150
.Seq29	Rep		3
	Start_Anim
	Wait		3
	Fire_Ship	5
	Stop_Anim
	Abs_Move	0,0,03
	Repend
	Wait		150
	Branch		.Seq29
Lev1_Seqc
	Stop_Anim
	Wait		150
.Seq30	Rep		3
	Start_Anim
	Wait		3
	Fire_Ship	6
	Stop_Anim
	Abs_Move	0,0,03
	Repend
	Wait		150
	Branch		.Seq30
Lev1_Seqd
	Stop_Anim
	Wait		150
.Seq31	Rep		3
	Start_Anim
	Wait		3
	Fire_Ship	7
	Stop_Anim
	Abs_Move	0,0,03
	Repend
	Wait		150
	Branch		.Seq31
Lev1_Seqe
	Stop_Anim
	Wait		150
.Seq32	Rep		3
	Start_Anim
	Wait		3
	Fire_Ship	8
	Stop_Anim
	Abs_Move	0,0,03
	Repend
	Wait		150
	Branch		.Seq32

Lev1_Seqaa
	Track		200
.Seq28	
	Fire_Ship	24
	Wait		5
	Fire_Ship	25
	Wait		5
	Fire_Ship	26
	Wait		5
	Fire_Ship	27
	Wait		5
	Rep		5
	Track		3
	Fire_Ship	14
	Repend	
	Track		180
	Branch		.Seq28
Lev1_Seqba
	Stop_Anim
	Wait		250
.Seq29	Rep		3
	Start_Anim
	Wait		3
	Fire_Ship	5
	Stop_Anim
	Abs_Move	0,0,03
	Repend
	Wait		150
	Branch		.Seq29
Lev1_Seqca
	Stop_Anim
	Wait		250
.Seq30	Rep		3
	Start_Anim
	Wait		3
	Fire_Ship	6
	Stop_Anim
	Abs_Move	0,0,03
	Repend
	Wait		150
	Branch		.Seq30
Lev1_Seqda
	Stop_Anim
	Wait		250
.Seq31	Rep		3
	Start_Anim
	Wait		3
	Fire_Ship	7
	Stop_Anim
	Abs_Move	0,0,03
	Repend
	Wait		150
	Branch		.Seq31
Lev1_Seqea
	Stop_Anim
	Wait		250
.Seq32	Rep		3
	Start_Anim
	Wait		3
	Fire_Ship	8
	Stop_Anim
	Abs_Move	0,0,03
	Repend
	Wait		150
	Branch		.Seq32


Powerup_Down_Seq
	Abs_Move	0,2,130
	End_Seq
	
Lev3baddy_turretseq1
	Stop_Anim
	Track	350
	Branch	Turret_seq3Fire
Lev3baddy_turretseq2
	Stop_Anim
	Track	370
	Branch	Turret_seq3Fire
Lev3baddy_turretseq3
	Stop_Anim
	Track	390
	Branch	Turret_seq3Fire
Lev3baddy_turretseq4
	Stop_Anim
	Track	410
	Branch	Turret_seq3Fire

Turret_seq3Fire
	Start_Anim
	Track	27
	Fire_Ship	60
	Pause_Anim
	Track	20
	UnPause_Anim
	Stop_Anim
	Track	120
	Branch	Turret_seq3Fire

Backturrets_Seq3
	Wait	300
Backturrets_Seq3a
	Gosub	Fire_61
	Gosub	Fire_67
	Gosub	Fire_68
Backturrets_Seq3b
	Gosub	Fire_69
	Gosub	Fire_70
	Branch	Backturrets_Seq3a

Fire_61	Start_Anim
	Wait	12
	Fire_Ship	61
	Pause_Anim
	Wait	15
	UnPause_Anim
	Stop_Anim
	Wait	30
	Return
Fire_67	Start_Anim
	Wait	12
	Fire_Ship	67
	Pause_Anim
	Wait	15
	UnPause_Anim
	Stop_Anim
	Wait	30
	Return
Fire_68	Start_Anim
	Wait	12
	Fire_Ship	68
	Pause_Anim
	Wait	15
	UnPause_Anim
	Stop_Anim
	Wait	30
	Return
Fire_69	Start_Anim
	Wait	12
	Fire_Ship	69
	Pause_Anim
	Wait	15
	UnPause_Anim
	Stop_Anim
	Wait	30
	Return
Fire_70	Start_Anim
	Wait	12
	Fire_Ship	70
	Pause_Anim
	Wait	15
	UnPause_Anim
	Stop_Anim
	Wait	30
	Return


MadLev3_Seq
	Track		120
	Rep		6
	Gosub		Level3_Mainfire_Fast
	Repend
	Branch		MadLev3_Seq

NearlyMadLev3_Seq
	Track		100
.NearlyMadLev3_Seq
	Track		150
	Rep		2
	Gosub		Level3_Mainfire
	Repend
	Branch		.NearlyMadLev3_Seq

Level3_Mainfire
	Fire_Ship	63
	Track		5
	Fire_Ship	64
	Track		5
	Fire_Ship	65
	Track		5
	Fire_Ship	66
	Track		5
	Return

Level3_Mainfire_Fast
	Fire_Ship	63
	Track		3
	Fire_Ship	64
	Track		3
	Fire_Ship	65
	Track		3
	Fire_Ship	66
	Track		3
	Return

LEV4_EXTSEQ
	Stop_Anim
	Track	200
	Start_Anim
.Rep2	Unpause_Anim
	Track	14
	Change_Anim	344
.Rep	Rep	3
	Fire_Ship	201
	Track	4
	Fire_Ship	201
	Track	4
	Fire_Ship	201
	Track	4
	Repend
	Change_Anim	343
	Wait_Anim	2
	Change_Anim	175
	Pause_Anim
	Track	80
	Branch	.Rep2
	
Bolty4_Seq	
	Stop_Anim
	Wait	100
.Bolty4_Seq	
	Start_Anim
	Wait_Anim	5
	Pause_Anim
	Rep	5
	Fire_Ship	71
	Wait	6
	Repend
	UnPause_Anim
	Stop_Anim
	Wait	200
	Branch		.Bolty4_Seq	

Bolty4_Seq2
	Stop_Anim
	Wait		200
	Start_Anim
.Rep2	Unpause_Anim
	Wait		14
	Change_Anim	344
.Rep	Rep	2
	Fire_Ship	72
	Wait		8
	Fire_Ship	132
	Wait		8
	Repend
	Change_Anim	343
	Wait_Anim	2
	Change_Anim	175
	Pause_Anim
	Wait	80
	Branch	.Rep2

Bolty4_Seq3	
	Stop_Anim
	Wait		270
	Start_Anim
.Rep2	Unpause_Anim
	Wait		14
	Change_Anim	344
.Rep	Rep	3
	Fire_Ship	73
	Wait		6
	Repend
	Change_Anim	343
	Wait_Anim	2
	Change_Anim	175
	Pause_Anim
	Wait	100
	Branch	.Rep2

Hold_Seq
	Branch		Hold_Seq
	
;Spinny_Seq1
	Wait	200
;Spinny_Seq2
	Change_Anim	196
	Wait	10
	Pause_Anim
	Wait	10
	Fire_Ship	74
	UnPause_Anim
	Wait	10
	Change_Anim	195
	Wait	50
	Branch	Spinny_Seq2

Big_Gun5_Seq
	Stop_Anim
	Wait	210
.Back	Rep	5
	Start_Anim
	Wait	3
	Fire_Ship	75
	Stop_Anim
	Wait		5
	Repend
	Wait	100
	Branch		.Back

Twin_Turret_Fire
	Stop_Anim
	Track	240
.Back	Rep	4
	Start_Anim
	Track	8
	Pause_Anim
	Fire_Ship	76
	UnPause_Anim
	Stop_Anim
	Track	20
	Repend
	Track	100
	Branch	.Back
	
Lev5_Sideshot_Seqb
	Stop_Anim
	Track	210
Lev5_Sideshot_Seq
	Stop_Anim
.Back	Track	50
	Rep	10
	Start_Anim
	Track	8
	Pause_Anim
	Fire_Ship	77
	UnPause_Anim
	Stop_Anim
	Track	100
	Repend
	Branch	.Back
	
		

Mad_4_Seq
	Wait	10
	Fire_Ship	128
	Wait	10
	Fire_Ship	129
	Wait	10
	Fire_Ship	130
	Wait	10
	Fire_Ship	131
	Wait	30
	Fire_Ship	130
	Wait	30
	Fire_Ship	131
	Wait	60
	Fire_Ship	128
	Wait	20
	Fire_Ship	129
	Wait	30
	Branch		Mad_4_Seq

Spinny_Seq1
	Set_Destruct	1
	Add_Guardians
	Abs_Move	0,2,115
	Abs_Move	-1,1,50
	Abs_Move	0,1,60
.Hold	Abs_Move	0,1,1
	Gosub		Spinny_Fire
	Abs_Move	-1,1,40
	Abs_Move	0,1,10
	Abs_Move	0,0,20
	Abs_Move	0,1,1
	Gosub		Spinny_Fire
	Abs_Move	0,2,21
	Abs_Move	0,1,10
	Abs_Move	+1,1,40
	Abs_Move	0,1,10
	Branch		.Hold


Spinny_Seq2
	Set_Destruct	0
	Add_Guardians
	Abs_Move	0,2,115
	Abs_Move	+1,1,50
	Abs_Move	0,1,1
.Hold	
	Abs_Move	0,1,1
	Gosub		Spinny_Fire
	Abs_Move	+1,1,40
	Abs_Move	0,1,10
	Abs_Move	0,0,20
	Abs_Move	0,1,1
	Gosub		Spinny_Fire
	Abs_Move	0,2,21
	Abs_Move	0,1,10
	Abs_Move	-1,1,40
	Abs_Move	0,1,10
	Branch		.Hold


Spinny_Fire
	Stop_Anim
	Abs_Move	0,1,3
	Change_Anim	196
	Start_Anim
	Wait_Anim	3
	Pause_Anim
	Fire_Ship	74
	UnPause_Anim
	Wait_Anim	9
	Change_Anim	195
	Abs_Move	0,1,3
	Return

Backfire1
	Stop_Anim
	Track		250
	Start_Anim
.Loop	Unpause_Anim
	Track		5
	Fire_Ship	146
	Wait_Anim	0
	Pause_Anim
	Track		120
	Branch		.Loop

Spider_Down_Seq
	Add_Spider

Raidens_Last_Fuckoff_Mental
	Stop_Anim
	Wait	40
.Back	Wait	70
	Set_Angle	0
	Start_Anim
	Rep	5
	Track		2
	Fire_Ship	177
	Add_Angle	2
	Fire_Ship	177
	Add_Angle	2
	Fire_Ship	177
	Add_Angle	2
	Fire_Ship	177
	Add_Angle	2
	Fire_Ship	177
	Track		2
	Add_Angle	-2
	Fire_Ship	177
	Add_Angle	-2
	Fire_Ship	177
	Add_Angle	-2
	Fire_Ship	177
	Add_Angle	-2
	Fire_Ship	177
	Add_Angle	-2
	Fire_Ship	177
	Track		2
	Add_Angle	-2
	Fire_Ship	177
	Add_Angle	-2
	Fire_Ship	177
	Add_Angle	-2
	Fire_Ship	177
	Add_Angle	2
	Fire_Ship	177
	Track		2
	Add_Angle	2
	Fire_Ship	177
	Add_Angle	2
	Fire_Ship	177
	Add_Angle	2
	Repend
	Stop_Anim
	Wait	70

	Start_Anim
	Rep		2
	Fire_Ship	173
	Wait		3
	Fire_Ship	174
	Wait		3
	Fire_Ship	175
	Wait		3
	Fire_Ship	176
	Wait		3
	Repend
	Stop_Anim
	Branch	.Back


Track_Seq3
	Set_Angle	$80
.Track_Seq1	
	Track		100
	Fire_Ship	189
	Branch		.Track_Seq1

Track_Seq0
	Set_Angle	$80
.Track_Seq1	
	Track		100
	Fire_Ship	1
	Branch		.Track_Seq1
