; RAIDEN EQUATES AND DATA STRUCTURE RESERVES

DSP_ALL	Equ	$3f
DSP_MUSIC	Equ	$f
DSP_SFX	Equ	$30


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


Score_BoardY		Equ	2
;Screen_Height		Equ	226		;---!!
Screen_Width		Equ	322+2
Panel_Width		Equ	100+16
;Playfield_Height	Equ	226  Screen_Height
Playfield_Width		Equ	Screen_Width-Panel_Width+10

Scoreboard_Left	Equ	02
Scoreboard_Mid	Equ	(Screen_Width/2)-42
Scoreboard_Right	Equ	Screen_Width-(90)
ScoreBoard_Width	Equ	Screen_Width	
ScoreBoard_Height	Equ	16*3
End_Level_GFX_Left	Equ	14
End_Level_GFX_Right	Equ	Screen_Width-160
End_Level_GFX_Mid	Equ	(Screen_Width/2)-76
End_Level_GFX_Y		Equ	56
End_Level_Medal_X	Equ	20
End_Level_Bomb_X	Equ	20
End_Level_Medal_Y	Equ	21
End_Level_Bomb_Y	Equ	43
End_Level_Score_X	Equ	30
End_Level_Score_y	Equ	70



Height		Equ	200
Load_Buff_Size	Equ	1150000
Null_Sprite	Equ	-1
Maximum_Amount_Of_Sprites	Equ	1520
Maximum_Amount_Of_Player_Sprites	Equ	295
Frame_Rate	Equ	2
Max_Aliens	Equ 	160
Byteswide	Equ	480		
Max_Weapons	Equ	50 
Ded_Delay	Equ	100
Pow_Del		Equ	140
Track_Amount	Equ	2
Max_Homes	Equ	24
Tank_Anm_Set	Equ	7
Turret_Anm_Set	Equ	8
Bomb8_Anm_Set	Equ	54
Rotary_Anm_Set	Equ	55
Powerup_Anm_Set0	Equ	10
Powerup_Anm_Set1	Equ	56
Player_Explosion_Delay	Equ	2
Boosterdn_anm_set	Equ	11
Boosterup_anm_set	Equ	12
Whirry_anm_set		Equ	13
PlaneDn_anm_Set		Equ	32
Planeup_anm_Set		Equ	33
Big_Tank_Anm_Set	Equ	39
Wheel_Anm_Set1		Equ	40
Wheel_Anm_Set2		Equ	41
Wheel_Anm_Set3		Equ	42
Wheel_Anm_Set4		Equ	57
End_Level_Anm_Set	Equ	58
End_Level_Wirry_anm_Set	Equ	59
Cannon_Anm_Set1		Equ	60
Cannon_Anm_Set2		Equ	61
Cannon_Anm_Set3		Equ	62
Cannon_Anm_Set4		Equ	63
Enlarged_Ship_Anm_Set	Equ	64
Enlarged_Boost_Anm_Set	Equ	65
Cannon_Base_Anm_Set	Equ	66
Cannon_Anm_Set		Equ	67
Casket1_Anm_Set		Equ	34
Casket2_Anm_Set		Equ	35
Bolt_Anm_Set		Equ	49
Pig_Anm_Set		Equ	50
Guardian_Xpl_delay	Equ	4
Bomb_Kill_Delay		Equ	4
Zooming_Anm_Set		Equ	51
Zoomer_Anm_Set		Equ	68
Tankboat_Anm_Set	Equ	69
Tankboat_bit_Anm_Set	Equ	70
Boatup_Anm_Set		Equ	71
Boatrt_Anm_Set		Equ	72
Boatdn_Anm_Set		Equ	73
Boatlt_Anm_Set		Equ	74
Car_Anm_Set		Equ	75
Bull1_Anm_set		Equ	76
Bull2_Anm_set		Equ	77
Front_Train_Anm_Set	Equ	78
Back_Train_Anm_Set	Equ	79
Front_Carraige_Anm_Set	Equ	80
Back_Carraige_Anm_Set	Equ	81
Front_Fire_Anm_Set	Equ	82
Diagonal_Front_Anm_Set	Equ	83
Diagonal_Back_Anm_Set	Equ	84
Diagonal_Carraige_Anm_Set	Equ	85
Diagpnal_Fire_Anm_Set_Anm_Set	Equ	86
End_Level_Guardian_Left_Anm_Set	Equ	87
End_Level_Guardian_Right_Anm_Set	Equ	88
End_Level_Wing_Left_Anm_Set	Equ	89
End_Level_Wing_Right_Anm_Set	Equ	90
End_Level_Boosters_Anm_Set	Equ	91
Guardian_Bits_Anm_Set		Equ	92
Guardian_Shoots_Anm_Set		Equ	93
Left_Transform_Anm_Set		Equ	94
Right_Transform_Anm_Set		Equ	95
Trendy_Bolts_Anm_Set		Equ	96
Scafolding_Right_Anm_Set1	Equ	99
Scafolding_Right_Anm_Set21		Equ	100
Scafolding_Left_Anm_Set1	Equ	101
Scafolding_Left_Anm_Set2	Equ	102
Travel_boat_Anmset		Equ	103
Travel_boat_Anmset1		Equ	104
Travel_boat_Anmset2		Equ	105
Monstrous_Anmset1		Equ	106
Monstrous_Anmset2		Equ	107
Jeep_Anmset1			Equ	108
Jeep_Anmset2			Equ	109
Jeep_Anmset3			Equ	110
Guardian_Lev3_Anmset1		Equ	111
Guardian_Lev3_Anmset2		Equ	112
Guardian_Lev3_Anmset3		Equ	113
Guardian_Lev3_Anmset4		Equ	114
Guardian_Lev3_Anmset5		Equ	115
Guardian_Lev3_Anmset6		Equ	116
Guardian_Lev3_Anmset7		Equ	117
Guardian_Lev3_Anmset8		Equ	118
Mid_Anmset			Equ	14

	Rsreset
Wep_Dmg		Rs.b	1
Wep_Sprite_Num	Rs.b	1
Wep_Anim	Rs.b	1
Wep_Delay	Rs.b	1
Wep_X		Rs.w	1
Wep_Y		Rs.w	1
Wep_Home_Sine	Rs.w	0
Wep_XV		Rs.w	1
Wep_Home_Vel	Rs.w	0
Wep_YV		Rs.w	1
Wep_Sprite	Rs.b	1
Wep_Sine_Val	Rs.b	1
Wep_Sine_Scale	Rs.b	1
Wep_Sine_Speed	Rs.b	1
Is_Weapon_A_Rocket	Rs.b	1
Is_Weapon_A_Homing_Missle	Rs.b	1
Wep_FractionX	Rs.w	1
Wep_FractionY	Rs.w	1
Wep_Box		Rs.w	4
Wep_Explosion_Num	Rs.w	1
Wep_End		Rs.b	0



	Rsreset
Aln_Dmg		Rs.w	1
Aln_Anim	Rs.b	1
Aln_Delay	Rs.b	1
Aln_AnmSet	Rs.w	1
Aln_Wave	Rs.w	1
Aln_X		Rs.w	1
Aln_Y		Rs.w	1
Aln_Shite	Rs.b	24
Aln_X_Offseted	Rs.w	1
Aln_Y_Offseted	Rs.w	1

Aln_Collision_Box	Rs.w	4
Aln_Shadsprite	Rs.w	1
Aln_Half_Damage	Rs.w	1
Aln_Pauseflag	Rs.b	1
Aln_AnimFlag	Rs.b	1 
Aln_AnimFlipdel	Rs.b	1
Aln_AnimFlipFlg	Rs.b	1
Aln_AnimCont	Rs.b	1
Aln_POWNUM	Rs.b	1
Aln_Track_val	Rs.b	1
Aln_Hitoveride	Rs.b	1
Aln_ChildX	Rs.w	1
Aln_ChildY	Rs.w	1

Aln_PrevLink	Rs.l	1
Aln_Link	Rs.l	1

Aln_Seqdec	Rs.w	1
Aln_Seqp	Rs.l	1
Aln_Replocate	Rs.l	1
Aln_Repeat	Rs.w	1
Aln_Stack	Rs.l	1
Aln_Sprite	Rs.w	1

Aln_Rotnumber		Rs.b	1
ALN_SPR_Priority	Rs.b	1
ALN_Killplayer		Rs.b	1
ALN_Hit			Rs.b	1
Aln_Weaponeffect	Rs.b	1
Aln_DMG_Dec		Rs.b	1
Aln_Base_Sprite		Rs.w	1
Aln_Init		Rs.b	1
Aln_Its_A_Child		Rs.b	1

Aln_Itsonscreen		Rs.b	1
Aln_Trackdec		Rs.b	1
Aln_Unique_fire		Rs.w	1

Aln_End		Rs.b	0


	Rsreset
Spr_Use		Rs.w	1
Spr_Yadd	Rs.w	1
spr_Addr	Rs.l	1		; Weapon sprite structure
Spr_Height	Rs.w	1
Spr_Plane	Rs.w	1
Spr_Width	Rs.w	1
Spr_MaxShift	Rs.w	1
Spr_E		Rs.w	0

BACKDROP_MEM	EQU	Byteswide*16*19
	