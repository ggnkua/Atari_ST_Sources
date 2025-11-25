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

	Ds.l	190-130	

Lev5_Endbaddy_Link
	Dc.l	.Lev5_add
	V_Ent	$7fff,187,300,-10,Big_Gun5_Seq
	V_Ent	$7fff,188,300,-10,Hold_Seq
	V_Ent	$7fff,189,300,-10,Hold_Seq

	V_Ent	$7fff,191,300,-10,Twin_Turret_Fire
	V_Ent	$7fff,190,300,-10,Twin_Turret_Fire

	V_Ent	$7fff,192,300,-10,Lev5_Sideshot_Seqb
	V_Ent	$7fff,192,300,-10,Lev5_Sideshot_Seqb

	V_Ent	$7fff,192,300,-10,Lev5_Sideshot_Seqb
	V_Ent	$7fff,192,300,-10,Lev5_Sideshot_Seqb

	V_Ent	$7fff,193,300,-10,Lev5_Sideshot_Seqb
	V_Ent	$7fff,193,300,-10,Lev5_Sideshot_Seqb

	V_Ent	$7fff,194,300,-10,Hold_Seq
	V_Ent	$7fff,194,300,-10,Hold_Seq

	V_Ent	$7fff,195,300,-10,Spinny_Seq1
	V_Ent	$7fff,195,300,-10,Spinny_Seq2

	Dc.l	-1
.Lev5_add
	Dc.w	16,20
	Dc.w	-64,30,64,30
	Dc.w	-32,44,64,44
	Dc.w	-48,32,-32,32
	Dc.w	64+16,32,64+32,32
	Dc.w	03,83,48,83
	Dc.w	04,45,52,45

	Dc.w	04,90,80,90
	
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

Track_Tank_Link
	Dc.l	.Track_ext
	V_Ent	$7fff,178,300,-10,Hold_Seq
	Dc.l	-1
.Track_Ext
	Dc.w	08,09

Lev4_Extlink2
	Dc.l	.Lev4_Ext
	V_Ent	$7fff,175,300,-10,LEV4_EXTSEQ
	Dc.l	-1
.Lev4_Ext
	Dc.w	14,14

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
	V_Ent	20,175,300,-10,Bolty4_Seq
	V_Ent	20,175,300,-10,Bolty4_Seq

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
	V_Ent	$7fff,3,300,-10,Do_Nothing_Seq
	V_Ent	$7fff,5,300,-10,Do_Nothing_Seq
	V_Ent	$7fff,147,300,-10,Do_Nothing_Seq
	V_Ent	$7fff,150,300,-10,Do_Nothing_Seq
	V_Ent	$7fff,151,300,-10,Do_Nothing_Seq
	V_Ent	$7fff,148,300,-10,Do_Nothing_Seq
	V_Ent	$7fff,149,300,-10,Do_Nothing_Seq
	Dc.l	-1

.Powerup_holdAdd
	Dc.w	-80,12
	Dc.w	+107,12

	Dc.w	16,11
	Dc.w	-56,07
	Dc.w	+55,07
	Dc.w	-88,2
	Dc.w	+100,2


	
Terrain_Rightlink
	Dc.l	.Terrainup_Add
	V_Ent	$7fff,143,300,-10,Do_Nothing_Seq
	V_Ent	$7fff,144,300,-10,Do_Nothing_Seq
	V_Ent	$7fff,145,300,-10,Do_Nothing_Seq
	Dc.l	-1
.Terrainup_Add
	Dc.w	07,12
	Dc.w	14,28
	Dc.w	14,0

Terrain_Uplink
	Dc.l	.Terrainup_Add
	V_Ent	$7fff,140,300,-10,Do_Nothing_Seq
	V_Ent	$7fff,141,300,-10,Do_Nothing_Seq
	V_Ent	$7fff,142,300,-10,Do_Nothing_Seq
	Dc.l	-1

.Terrainup_Add
	Dc.w	15,4
	Dc.w	1,13,36,13

Humongous_Tanklink
	Dc.l	.Humong_add
	V_Ent	$7fff,134,300,-10,Do_Nothing_Seq
	V_Ent	$7fff,135,300,-10,Do_Nothing_Seq
	V_Ent	$7fff,136,300,-10,Do_Nothing_Seq
	V_Ent	$7fff,137,300,-10,Do_Nothing_Seq
	Dc.l	-1
	
.Humong_add
	Dc.w	02,48
	Dc.w	46,48
	Dc.w	04,07
	Dc.w	40,07



Floaty_Link	
	Dc.l	.Float_Add
	V_Ent	$7fff,132,300,-10,Do_Nothing_Seq
	Dc.l	-1
	
.Float_Add
	Dc.w	18,18

Boat_Turret_Link		;74
Tank_Link
	Dc.l	-1
.Turret_Link
	V_Ent	02,008,0,0,Track_Seq1
	Dc.w	-1

Powerup_Link
	Dc.l	.Powerup_Add
.Powerup_Link
	V_Ent	$7fff,56,300,-10,Powerup_FireSeq
	V_Ent	$7fff,11,300,-10,Do_Nothing_Seq
	V_Ent	$7fff,11,300,-10,Do_Nothing_Seq
	V_Ent	$7fff,23,300,-10,Do_Nothing_Seq
	V_Ent	$7fff,23,300,-10,Do_Nothing_Seq
	V_Ent	$7fff,11,300,-10,Do_Nothing_Seq
	V_Ent	$7fff,11,300,-10,Do_Nothing_Seq	
	Dc.w	-1
.Powerup_Add
	Dc.w	16,9,8,-6,24,-6,0,11,32,11
	DC.W	0,0,32,0

Mid_2_Link
	Dc.l	Temp_Mid2_Add+Data
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
Mid2_Add
	Dc.w	-05,3,16,3
	Dc.w	-12,8,32,6
	Dc.w	01,-03,17,-03
	Dc.w	03,42,19,42
	Dc.w	$8000
	
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
	Dc.w	39,45,8,45

Bigtank_Link
	Dc.l	.Bigtank_Add
.Big_Tank_Link
	V_Ent	$7fff,40,300,-10,Bigtank_Seq
	V_Ent	$7fff,41,300,-10,Bigtank_Seq
	V_Ent	$7fff,42,300,-10,Bigtank_Seq
	V_Ent	$7fff,57,300,-10,Bigtank_Seq
	Dc.w	-1
.Bigtank_Add
	Dc.w	0,0,+32,0,1,+34,+32,+34
Bomb_Link
	Dc.l	.Rot_Add	
.Bomb_Link
	V_Ent	15,55,232,-64,Do_Nothing_Seq
	Dc.w	-1
.Rot_Add	
	Dc.w	-7,-28

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
	V_Ent	$7fff,67,100,-64,Lev1_Seqa
	Dc.w	-1
.Level1_Add
	Dc.w	-6,4,+53,4,-6,48,53,+48
	Dc.w	+10,+48,-01,+35,+63,+35,+53,+48
	Dc.w	+24,+27
Enlarged_Link
.Enlarged_Link
	Dc.l	.Enlarged_Add
	V_Ent	$7fff,65,100,-64,Do_Nothing_Seq
	V_Ent	$7fff,65,100,-64,Do_Nothing_Seq
	Dc.w	-1
.Enlarged_Add
	Dc.w	06,-30,28,-30
Cannon_Link
	Dc.l	-1
.Cannon_Link
	V_Ent	07,67,100,-64,Track_Seq1
	Dc.w	-1

Powerup_Boat_Link		;69
	Dc.l	.Bigboat_Add
.Boat_Bit_Link
	V_Ent	02,070,0,0,Track_Seq1
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
	V_Ent	$7fff,82,100,-64,Track_Seq1
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
	V_Ent	$7fff,86,100,-64,Track_Seq1
	Dc.w	-1
.Diagonal_Carraige_Add
	Dc.w	8,7

Guardian2_Link
	Dc.l	.Level2_Add
.End_Lev2_Link
	V_Ent	$7fff,88,0,0,Centerright2_Seq
	V_Ent	$7fff,91,0,0,Do_Nothing_Seq
	V_Ent	$7fff,91,0,0,Do_Nothing_Seq
	V_Ent	$7fff,92,0,0,Center_Lev2seqNormal
	V_Ent	10,89,0,0,Secondfireseq1
	V_Ent	10,90,0,0,Secondfireseq2
	Dc.w	-1
.Level2_Add
	Dc.w	48,0,81,46,0,46,+41,+21,-48,+30,95,+30

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
	Dc.l	TempTravel_Add+Data
.Boat3_Link
	V_Ent	10,104,340,-52,Hover_TrackSeq
	V_Ent	10,105,340,-52,Do_Nothing_Seq
	V_Ent	10,105,340,-52,Do_Nothing_Seq
	Dc.w	-1
Travel_Add
	Dc.w	16,14,9,47,32,47,$8000


Monstrous_Tank_Link
	Dc.l	.Mon_Add
.Mons_Link
	V_Ent	10,107,200,-32,Track_Seq1
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
	Dc.l	Temp_Level3_Add+Data
.End_Lev3_Link
	V_Ent	$7fff,112,100,-200,Do_Nothing_Seq
	V_Ent	50,113,100,-200,Do_Nothing_Seq
	V_Ent	50,114,100,-200,Do_Nothing_Seq
	V_Ent	50,115,100,-200,Do_Nothing_Seq
	V_Ent	50,116,100,-200,Do_Nothing_Seq
	V_Ent	50,117,100,-200,Do_Nothing_Seq
	V_Ent	50,118,100,-200,Do_Nothing_Seq

	V_Ent	75,121,100,-200,Backturrets_Seq3
	V_Ent	75,122,100,-200,Backturrets_Seq3B
	
	V_Ent	10,120,100,-200,Lev3baddy_turretseq1
	V_Ent	10,120,100,-200,Lev3baddy_turretseq2
	V_Ent	10,120,100,-200,Lev3baddy_turretseq3
	V_Ent	10,120,100,-200,Lev3baddy_turretseq4
	V_Ent	10,120,100,-200,Lev3baddy_turretseq1
	V_Ent	10,120,100,-200,Lev3baddy_turretseq2
	V_Ent	10,120,100,-200,Lev3baddy_turretseq3
	V_Ent	10,120,100,-200,Lev3baddy_turretseq4
	
	V_Ent	50,123,100,-200,NearlyMadLev3_Seq

	Dc.w	-1


LeveL3_Add
	Dc.w	64,0,00,64,64,64
	Dc.w	0,32,64,32
	Dc.w	0,96,64,96

	Dc.w	67,7,16,7

	Dc.w	24,42
	Dc.w	24,60
	Dc.w	24,78
	Dc.w	24,96

	Dc.w	24+32,42
	Dc.w	24+32,60
	Dc.w	24+32,78
	Dc.w	24+32,96
	Dc.w	40,13
	Dc.w	$8000

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
.Back	Abs_Move	0,0,30
	Abs_Move	0,-1,80
	Abs_Move	-1,0,100
	Abs_Move	+1,0,200
	Abs_Move	-1,0,100
	Abs_Move	0,1,80
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
	Rep		4
	Fire_Ship	50
	Wait		5
	Fire_Ship	51
	Wait		5
	Fire_Ship	52
	Wait		5
	Fire_Ship	53
	Wait		5
	Repend
	UnPause_Anim
	Stop_Anim
	Wait		60
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
	Track	1
	Fire_Ship	34
	Track	1
	Fire_Ship	35
	Track	1
	Fire_Ship	36
	Track	1
	Fire_Ship	37
	Track	1
	Fire_Ship	38
	Track	1
	Fire_Ship	39
	Track	1
	Fire_Ship	40
	Track	1
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
	Abs_Move	0,2,50
	End_Seq	

Up_Plane_Seq
	Abs_Move	0,-2,60		
	Abs_Move	0,-3,60		
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
Spit_Home_Seq
	Spit_Home
	End_Seq
Fuck_Seq
	End_Seq
Angel_Seq	
	Abs_Move	0,-4,20
	Abs_Move	+4,+4,20
	Abs_Move	0,-4,20
	Abs_Move	-4,+4,20
	Branch		Angel_Seq
Track_Seq1	
	Track		80
	Fire_Ship	1
	Branch		Track_Seq1
Do_Nothing_Seq
	Branch	Do_Nothing_Seq
Lev1_Seqa
	Track		96
.Seq28	
	Fire_Ship	24
	Wait		3
	Fire_Ship	25
	Wait		3
	Fire_Ship	26
	Wait		3
	Fire_Ship	27
	Wait		3
	Rep		5
	Track		3
	Fire_Ship	14
	Repend	
	Track		80
	Branch		.Seq28
Lev1_Seqb
	Stop_Anim
	Wait		100
.Seq29	Rep		3
	Start_Anim
	Wait		3
	Fire_Ship	5
	Stop_Anim
	Abs_Move	0,0,03
	Repend
	Wait		100
	Branch		.Seq29
Lev1_Seqc
	Stop_Anim
	Wait		100
.Seq30	Rep		3
	Start_Anim
	Wait		3
	Fire_Ship	6
	Stop_Anim
	Abs_Move	0,0,03
	Repend
	Wait		100
	Branch		.Seq30
Lev1_Seqd
	Stop_Anim
	Wait		100
.Seq31	Rep		3
	Start_Anim
	Wait		3
	Fire_Ship	7
	Stop_Anim
	Abs_Move	0,0,03
	Repend
	Wait		100
	Branch		.Seq31
Lev1_Seqe
	Stop_Anim
	Wait		100
.Seq32	Rep		3
	Start_Anim
	Wait		3
	Fire_Ship	8
	Stop_Anim
	Abs_Move	0,0,03
	Repend
	Wait		100
	Branch		.Seq32

Powerup_Down_Seq
	Abs_Move	0,2,130
	End_Seq
	
Lev3baddy_turretseq1
	Stop_Anim
	Track	200
	Branch	Turret_seq3Fire
Lev3baddy_turretseq2
	Stop_Anim
	Track	210
	Branch	Turret_seq3Fire
Lev3baddy_turretseq3
	Stop_Anim
	Track	220
	Branch	Turret_seq3Fire
Lev3baddy_turretseq4
	Stop_Anim
	Wait	230
	Branch	Turret_seq3Fire

Turret_seq3Fire
	Start_Anim
	Track	10
	Fire_Ship	60
	Stop_Anim
	Track	120
	Branch	Turret_seq3Fire

Backturrets_Seq3
	Gosub	Fire_61
	Gosub	Fire_67
	Gosub	Fire_68
Backturrets_Seq3b
	Gosub	Fire_69
	Gosub	Fire_70
	Branch	Backturrets_Seq3

Fire_61	Start_Anim
	Wait	10
	Fire_Ship	61
	Stop_Anim
	Wait	30
	Return
Fire_67	Start_Anim
	Wait	10
	Fire_Ship	67
	Stop_Anim
	Wait	30
	Return
Fire_68	Start_Anim
	Wait	10
	Fire_Ship	68
	Stop_Anim
	Wait	30
	Return
Fire_69	Start_Anim
	Wait	10
	Fire_Ship	69
	Stop_Anim
	Wait	30
	Return
Fire_70	Start_Anim
	Wait	10
	Fire_Ship	70
	Stop_Anim
	Wait	30
	Return

MadLev3_Seq
	Track		150
	Rep		6
	Gosub		Level3_Mainfire
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
	Track		2
	Fire_Ship	64
	Track		2
	Fire_Ship	65
	Track		2
	Fire_Ship	66
	Track		2
	Return

LEV4_EXTSEQ
	Stop_Anim
	Track	200
.Rep2	Start_Anim
	Track	14
	Pause_Anim
.Rep	Rep	3
	Fire_Ship	0
	Track	4
	Fire_Ship	0
	Track	4
	Fire_Ship	0
	Track	4
	Repend
	UnPause_Anim
	Stop_Anim
	Track	40
	Branch	.Rep2
	
Bolty4_Seq	
	Stop_Anim
	Wait	100
.Bolty4_Seq	
	Start_Anim
	Wait	14
	Pause_Anim
	Rep	6
	Fire_Ship	71
	Wait	5
	Repend
	UnPause_Anim
	Stop_Anim
	Wait	150
	Branch		.Bolty4_Seq	

Bolty4_Seq2
	Stop_Anim
	Wait	200
.Bolty4_Seq	
	Start_Anim
	Wait	14
	Pause_Anim
	Rep	3
	Fire_Ship	72
	Wait	5
	Repend
	UnPause_Anim
	Stop_Anim
	Wait	250
	Branch		.Bolty4_Seq	

Bolty4_Seq3	
	Stop_Anim
	Wait	270
.Bolty4_Seq	
	Start_Anim
	Wait	14
	Pause_Anim
	Rep	4
	Fire_Ship	73
	Wait	5
	Repend
	UnPause_Anim
	Stop_Anim
	Wait	100
	Branch		.Bolty4_Seq	

Hold_Seq
	Branch		Hold_Seq
	
Spinny_Seq1
	Wait	100
Spinny_Seq2
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
.Back	Wait	100
	Rep	5
	Start_Anim
	Wait	3
	Fire_Ship	75
	Stop_Anim
	Wait		5
	Repend
	Branch		.Back

Twin_Turret_Fire
	Stop_Anim
.Back	Track	100
	Rep	4
	Start_Anim
	Track	8
	Pause_Anim
	Fire_Ship	76
	UnPause_Anim
	Stop_Anim
	Track	20
	Repend
	Branch	.Back
	
Lev5_Sideshot_Seqb
	Stop_Anim
	Track	150

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
	Track	10
	Repend
	Branch	.Back
	
		

