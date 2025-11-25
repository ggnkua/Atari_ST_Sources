;501-512
;1287,1288
**********************************************************
Turret_Adj	MACRO
	Dc.w	+0,-6
	Dc.w	+0,-6
	Dc.w	+0,-5
	Dc.w	+3,-3
	Dc.w	+3,-2
	Dc.w	+1,-0
	Dc.w	+1,-0
	Dc.w	+1,+1
	Dc.w	+0,+2
	Dc.w	+0,+2
	Dc.w	-2,+1
	Dc.w	-4,-0
	Dc.w	-5,-0
	Dc.w	-4,-2
	Dc.w	-3,-3
	Dc.w	-2,-4
	Endm
Cannon_Adj	Macro
	Dc.w	+3,+2
	Dc.w	+3,+3
	Dc.w	+3,+3
	Dc.w	+3,+1
	Dc.w	+4,+2
	Dc.w	+3,+2
	Dc.w	+3,+3
	Dc.w	+2,+2
	Dc.w	+3,+2
	Dc.w	+3,+2
	Dc.w	+3,+3
	Dc.w	+3,+2
	Dc.w	+3,+3
	Dc.w	+3,+2
	Dc.w	+3,+3
	Dc.w	+2,+2
	Endm

Cannon_Adj2	Macro
	Dc.w	+1,-4
	Dc.w	+1,-3
	Dc.w	+2,-2
	Dc.w	+3,-1
	Dc.w	+4,-0

	Dc.w	+4,+1
	Dc.w	+3,+2
	Dc.w	+2,+2
	Dc.w	+2,+2

	Dc.w	+2,+2
	Dc.w	-1,+2
	Dc.w	-2,+2
	Dc.w	-1,+0

	Dc.w	-1,-1
	Dc.w	+0,-2
	Dc.w	+1,-3
	Endm

;**********************************************************
	Excrt	01,+00,+00
Explosion_And_Crator_Offset_Table
	Excrt	16,+00,+00
	Excrt	16,-02,-02
	Excrt	16,-02,-02
	Excrt	16,-10,-10
	Excrt	28,+00,+00
;92
	Excrt	03,-10,-10
	Excrt	01,-00,-00
	Excrt	01,-05,-05
	Excrt	04,-00,-00
;101
	Excrt	01,-06,-06
	Excrt	19,-00,-00
	Excrt	16,+00,+00
	Excrt	16,-02,-02
;153
	Excrt	09,-00,-00
	Excrt	01,-05,-05

	Excrt	01,-24,-26
	Excrt	19,-00,-00
	Excrt	01,-00,-00
;184
	Excrt	04,-00,-00
	Excrt	12,-06,-06
	Excrt	01,-00,-00
	Excrt	16,-01,-01

	Excrt	01,-05,-20
	Excrt	02,-00,-00
	Excrt	04,-02,-02
	Excrt	06,-00,-00
;230
	Excrt	32,-02,-02
	Excrt	02,-02,-02
	Excrt	01,-10,-10
	Excrt	01,-00,-00
	Excrt	04,-04,-04
	Excrt	02,-04,-04
	Excrt	02,-03,-03
;274
	Excrt	27,-26,-26
;301
	Excrt	2,-04,-04
	Excrt	2,-04,-11
	Excrt	20,-04,-04
;325
	Excrt	02,-02,-02
	Excrt	04,-12,-06
	Excrt	09,-06,-06
	Excrt	01,-13,-13		;;
	Excrt	16,+00,+00
	Excrt	08,-16,-30
;365
	Excrt	08,+00,+00
	Excrt	20,-16,-20
	Excrt	04,-17,-22
	Excrt	08,-02,-02	
	Excrt	03,-12,-12	
	Excrt	09,+00,+00

	Excrt	438-418,+00,+00
	Excrt	3,-10,-10
	Excrt	2,-10,-10
	Excrt	521-443,0,-0
	Excrt	01,-10,-10
	Excrt	560-522,0,-0
	Excrt	07,-20,-20
	Excrt	568-567,0,-0

	Excrt	16,-16,-16

	Excrt	616-584,-6,-6
	Excrt	2,-4,-4
	Excrt	693-618,00,00
	Excrt	03,-8,-8
	Excrt	1118-696,+00,+00
	Excrt	3*9,-10,-10
	Excrt	1289-(1118+(3*9)),+00,+00
	Excrt	02,-8,-8
	Excrt	1302-1291,+00,+00
	Excrt	08,-16,-16
	Excrt	1482-1310,+00,+00
	Excrt	3,-16,-12
	Excrt	30,+00,+00

	Dc.b	0
Dead_Alien_Jump_Table
GG
	Dcb.b	016,0
	Dcb.b	016,21
	Dcb.b	016,6
	
	Dcb.b	002,1
	Dcb.b	001,3
	Dcb.b	013,1
	Dcb.b	002,15
	Dcb.b	014,0
;80
	Dcb.b	010,0
	Dcb.b	001,0
	Dcb.b	001,14
	Dcb.b	003,3
	Dcb.b	001,0
	Dcb.b	001,2
	Dcb.b	004,0
;101
	Dcb.b	001,12
	Dcb.b	019,0
;121
	Dcb.b	16,0
	Dcb.b	16,21
	Dcb.b	09,0
	Dcb.b	001,2
	Dcb.b	001,10
;164
	Dcb.b	003,0
	Dc.b	11,15,15
	Dcb.b	013,0
;183
	Dcb.b	001,13
	Dcb.b	016,0
;200
	Dcb.b	001,0
	Dcb.b 	016,5
	Dcb.b	001,2
	Dcb.b	002,0
	Dcb.b	004,11
	Dcb.b	002,0
	Dcb.b	004,4
;230
	Dcb.b	032,0
	Dcb.b	002,0
	Dcb.b	001,12
	Dcb.b	001,0
	Dcb.b	004,0
	Dcb.b	002,7
	Dcb.b	002,1
;274
	Dcb.b	002,8
	Dcb.b	001,8
	Dcb.b	002,8
	Dcb.b	001,8
	Dcb.b	008,0
;288
	Dcb.b	002,8
	Dcb.b	001,8
	Dcb.b	002,8
	Dcb.b	008,0
;301	
	Dcb.b	001,9
	Dcb.b	001,0
;	Dcb.b	002,9
	Dcb.b	002,17
	Dcb.b	017,0
;	Dcb.b	017,9

	Dcb.b	003,4
;325
	Dcb.b	002,0
	Dcb.b	004,19
	Dcb.b	009,2
	Dcb.b	001,3
	Dcb.b	016,0
	Dcb.b	008,3
;365!	
	Dcb.b	8,18			; Level 3 Quad sprites
	Dcb.b	20,17			; Huge level 3 cannons
	Dcb.b	2,0			; Cant hit these anyway !

	Dcb.b	2,0			; Void sprite 64 !		;393-365
;	Dcb.b	2,17			; Void sprite 64 !		;393-365

	Dcb.b	4,16			; Side bits
	Dcb.b	4,16			; Side bits
	Dcb.b	1,2			; Main bit !
	Dcb.b	2,2
;408
	Dcb.b	09,22
	Dcb.b	01,0

;418	
	Dcb.b	421-418,2
	Dc.b	3
	Dcb.b	438-422,2
	Dcb.b	5,40

	Dcb.b	460-443,3
	Dcb.b	8,0
	Dcb.b	4,0

	Dcb.b	479-472,2
	Dcb.b	4,28
	Dcb.b	4,00
	Dcb.b	4,00
;491
	Dcb.b	1,20
	Dcb.b	497-492,2
	Dcb.b	2,27
	Dcb.b	501-499,0
	Dcb.b	505-501,16
	Dcb.b	8,26
	Dc.b	2
;514
	Dcb.b	7,0
	Dcb.b	13,3
	Dc.b	31

	Ds.b	538-535
	Dc.b	29,29

	Ds.b	560-540
	Dcb.b	7,30

	Ds.b	568-567
	Dcb.b	16,3

	Dcb.b	616-584,0
	Dc.b	2
	Dcb.b	619-617,0
	Dc.b	33
	Dcb.b	628-620,0
	Dc.b	2

	Dcb.b	680-629,0
	Dc.b	2
	Dcb.b	693-681,0
	Dcb.b	3,16
	Dcb.b	700-696,0
	Dcb.b	23,35
	Dc.b	2,2,2
	Dc.b	35,35
	Dcb.b	10,0
	Dcb.b	740-738
	Dcb.b	002,11
;742
HH
	Dcb.b	016,25
	Dcb.b	016,25

	Dcb.b	016,6
;790
	Dcb.b	001,12

	Ds.b	793-791
	Dc.b	24

	Ds.b	800-794		;881
	Dcb.b	001,0
	Dcb.b 	016,5

	Ds.b	881-817
	Dcb.b	001,13
	Dcb.b	016,13

	Ds.b	981-898
	Dc.b	34,34
	Ds.b	985-983
	Dcb.b	016,6
	Dcb.b	032,23			
	Dcb.b	3,35
	Dcb.b	1058-1036,0
	Dc.b	3
	Ds.b	1118-1059
	Dcb.b	9*3,32

	Ds.b	1170-(1118+(9*3))
	Dc.b	2
	Ds.b	1242-1171
	Dc.b	34
	Ds.b	1270-1243
	Dcb.b	001,0
	Dcb.b 	016,5
	Dc.b	39,39
	Dc.b	2,2
	Ds.b	1293-1291
	Dc.b	37,37
	Ds.b	1300-1295
	Dc.b	38,38
	Dcb.b	8,2
	Ds.b	1426-1310
	Dc.b	36,36

	Ds.b	1429-1428
	Dcb.b	25,2
	Dcb.b	1477-1454,0
	Dcb.b	4,0
	Dcb.b	1482-1481,0
	Dcb.b	3,17			; Void sprite 64 !		;393-365
	Dcb.b	50,0


**********************************************************
	Dc.b	0
Enemy_Prioritys				; (0-3!) (0=lowest!-1ST ON SCREEN)
	Dcb.b	16,11			Alien sprites
	Dcb.b	16,1			Tank sprite
	Dcb.b	16,2			Tank turret
	Dcb.b	02,0			Spinny bits for mid2 level tank
	Dcb.b	13,1			Main bits for mid level tank
	Dcb.b	01,0			Spinny bits 2
;64
	Dcb.b	02,15			Energy bolt
	Dcb.b	14,15			Power ups!
	Dcb.b	06,15			Explosions
	Dcb.b	02,15			Angel
	Dcb.b	02,0			Crater
	Dcb.b	01,0			Spiiny bits 2
	Dcb.b	01,1			Tree 
	Dcb.b	03,3			Big tank
	Dcb.b	01,2			Tank wheel
	Dcb.b	01,15			Big plane
	Dcb.b	03,2			Wheels of a tank
	Dcb.b	01,8			Medal
;101
	Dcb.b	01,14			Power-Up ship
	Dcb.b	03,2			Wheels
	Dcb.b	03,15			Huge Explosions
	Dcb.b	01,9			Medal
	Dcb.b	05,15			Rest of Power ups!
	Dcb.b	02,15			Explosions
	Dcb.b	01,1			Wheel
	Dcb.b	01,0			Crator
	Dcb.b	03,15			Explosions
	Dcb.b	16,11			Alien sprites
	Dcb.b	16,1			Tank turret
	Dcb.b	05,14			Power-Up Bits+Boost
	Dcb.b	02,9			Tweeny powerup
;160
	Dcb.b	02,13			Power up whirrys
	Dcb.b	01,15			Big plane
	Dcb.b	04,11			8-waybomb
	Dcb.b	03,15			1-ups
	Dcb.b	04,15			Explosions
	Dcb.b	03,15			Player death anims
	Dcb.b	02,15			Up rockets
	Dcb.b	04,9	…		End level platform
	Dcb.b	01,9			End level guardian
	Dcb.b	04,8			Whirry bits for guardian
	Dcb.b	12,9			Cannons for guardian
	Dcb.b	01,0
	Dcb.b	16,1
	Dcb.b	01,15
	Dcb.b	02,15			Boosters for enlarged alien
	Dcb.b	04,1			Caskets
	Dcb.b	02,9			Pig
	Dcb.b	04,9			Bolts for enlarge
;230
	Dcb.b	32,15			Zooming
	Dcb.b	02,15			Zoomer
	Dcb.b	02,1			Power up boat
	Dcb.b	04,2			Boats u/d/l/r
	Dcb.b	02,9			Car
	Dcb.b	02,1			Bulldozer
	Dcb.b	27,9			Train stuff !
	Dcb.b	2,12			End level bits(2)
	Dcb.b	2,11			End level bits(2)
	Dcb.b	17,13
	Dcb.b	3,14
;325
	Dcb.b	02,1
	Dcb.b	04,9
	Dcb.b	09,1
	Dcb.b	17,1			;!!!!!
	Dcb.b	08,1
;365
	Dcb.b	4,0
	Dcb.b	36,2
	Dc.b	0,1,1	
	Dcb.b	09,9		;9
	Dcb.b	01,15		;1
;418
	Dcb.b	421-418,0
	Dc.b	1
	Dcb.b	428-422,1
	Dcb.b	438-428,7
	Dcb.b	443-438,9
	Dcb.b	446-443,15
	Dcb.b	460-446,1
	Dcb.b	468-460,15
	Dcb.b	513-468,1
	Dc.b	15	

	Dcb.b	534-514,1
	Dc.b	6,7,7,7,3,3
	Dcb.b	12,3
	Dcb.b	08,07
	Dcb.b	07,02

	Dcb.b	568-567,1
	Dcb.b	16,4

	Dcb.b	616-584,10
	Dc.b	15
	Dcb.b	619-617,0
	Dcb.b	9,10

	Dcb.b	680-628,0
	Dcb.b	11,15
	Dcb.b	05,2
	Dcb.b	04,15
	Dcb.b	38,1
	
	Dcb.b	740-738,0
	Dcb.b	2,8
	Dcb.b	48,9
	Dc.b	9
	Dcb.b	798-791,7
	Dc.b	0
	Dcb.b	800-799,9
	Dc.b	0
	Dcb.b	16,1
	Dcb.b	04,2			Boats u/d/l/r
		
	Dcb.b	853-821,0		; Some blank bits
	Dcb.b	8,15
	Dc.b	0
	Dcb.b	881-862,0
	Dc.b	9,8,8,8,8
	Dcb.b	12,9
	Dc.b	14
	Dcb.b	908-899,0
	Dcb.b	2,15
	Dcb.b	2,0
	Dcb.b	8,15
	Dcb.b	7,0
	Dcb.b	6,0
	Dcb.b	12,9
	Dcb.b	4,0

	Ds.b	981-949
	Dcb.b	2,0
	
	Ds.b	985-983
	Dcb.b	48,9
	Dcb.b	3,1
	Dcb.b	9,9

	Dcb.b	1058-(985+60),14
	Dc.b	1
	
	Dcb.b	1090-1059,14
	Dc.b	1,1,1

	Dcb.b	1107-1093,14
	Dcb.b	3,7
	Dcb.b	8,6
	Dcb.b	24,7

	Ds.b	1170-1118-24
	Dcb.b	13,13
	Dc.b	12
	Dcb.b	1221-1184,9
	Dcb.b	17,10
	Dc.b	0,8
	Dc.b	8,8
	Dc.b	3
	Dcb.b	1264-1243,14
	Dcb.b	6,0
	Dc.b	9
	Dcb.b	16,9
	Dc.b	1,1,6,6,1,1,2,2,1,1,1,1,1,1,1,7,7,7,7,7,7,7,7,6,6,6,6,6,6,3,3,3,3,3,3,3,0,0,0,0,8,8,8


	Dcb.b	1426-(1287+43),9
	Dc.b	3,3,3
	Dcb.b	25,9
	Dc.b	11,11,8,8
	Dcb.b	1464-1458,9
	Dc.b	0
	Dc.b	8
		
	Dcb.b	1467-1466,14
	Dc.b	7

	Dcb.b	1474-1468,14
	Dc.b	0,0,0
	Dcb.b	4,0
	Dc.b	0
	Dc.b	2,2,2

	Dcb.b	16,9			;---

	Dc.b	0,0,0,0
	Dc.b	0,0,0,0
	Dc.b	0,0
Enemy_Priorityse			; (0-3!) (0=lowest!-1ST ON SCREEN)

**********************************************************
; 0 = alien Cant hit ya!, 1=this alien can kill!
	Dc.b	0
Alien_Killya_Table
FF
	Dcb.b	16,1
	Dcb.b	16,0
	Dcb.b	16,0
	Dcb.b	16,0			Tank missles!
	Dcb.b	02,1			Energy bolt
	Dcb.b	14,1			Power up
	Dcb.b	06,0			Explosions
	Dcb.b	02,1			Angel
	Dcb.b	04,0			Craters+Tree
	Dcb.b	03,0			Big Tank
	Dcb.b	01,0			Wheel
	Dcb.b	01,1			Big plane
 	Dcb.b	03,0			Wheels
 	Dcb.b	01,1			Medal
	Dcb.b	01,1			Big Power-up ship
	Dcb.b	03,0			Wheels
	Dcb.b	16,0			Lots of stuff !
	Dcb.b	16,1			;121
	Dcb.b	16,0
	Dcb.b	09,0			;153
	Dcb.b	05,1			; Biglane up !,?,8-way+rotary!
	Dcb.b	01,0			Inviso!
	Dcb.b	02,1			1-up
	Dcb.b	04,0			48x48 explosion	;170
	Dcb.b	03,0			ship explosion
	Dcb.b	02,0			up rockets
	Dcb.b	04,0			upper bits for end level guardian
	Dcb.b	01,0			End level guardian		;183
	Dcb.b	16,0			Bits for end level guardian	;184
	Dcb.b	01,0			Cannon base
	Dcb.b	16,0			Cannon turrets
	Dcb.b	01,1			Enlarged alien			;217
	Dcb.b	02,0			Booster for enlarged alien
	Dcb.b	04,0			Caskets
	Dcb.b	02,1			Pig
	Dcb.b	04,1			Energy bolts for enlarged alien

	Dcb.b	34,1			Zooming+Zoomer		;230
	Dcb.b	37,0			Ground stuff+Boats	;264
	Dcb.b	4,1			End level guardian	;301
	Dcb.b	11,0
	Dcb.b	9,1


	Dcb.b	93,0			All level 3 stuff	;325
	Dcb.b	460-418,0
	Dcb.b	8,1	
	Dcb.b	513-468,0
	Dc.b	1

	Dcb.b	584-514,0
	Dcb.b	32,1
	Dc.b	1
	Dcb.b	619-617,0
	Dc.b	1,1,1,1

	Dcb.b	680-623,0
	Dc.b	1

	Ds.b	693-681
	Dc.b	0,0,0

	Ds.b	791-696			;!!!!!!!!!!!!
	Dc.b	1

	Ds.b	1170-792
	dc.b	1,0,1,1,1,1,1,1,1,1,1,1,1
	Dcb.b	1242-1183,0
	Dc.b	0
	Dcb.b	1429-1243,0
	Dcb.b	25,1
	Dcb.b	1477-1454,0
	Dcb.b	4,0
	Dcb.b	1482-1481,0
	Dc.b	0,0,0
	Dcb.b	1501-1485,0
	Dc.b	0,0,0,0
	Dc.b	0,0,0,0
	Dc.b	0,0

**********************************************************
; 1 - kill if weapon hit alien, 0 - Weapon cant affect alien!
	Dc.b	0
WDo_Or_Die
	Dcb.b	16,1	
	Dcb.b	16,1	
	Dcb.b	16,1	
	Dcb.b	02,0
	Dcb.b	01,1			Second LEVEL MID BADDIE!
	Dcb.b	13,0
	Dcb.b	2,0
	Dcb.b	14,0			Power-ups
	Dcb.b	10,0			Explosions/Angel/crater
	Dcb.b	01,0			End Spinny !
	Dcb.b	01,1			TREE
	Dcb.b	2,1			Tank
	Dcb.b	1,0			Tank
	Dc.b	0
	Dc.b	1
	Dcb.b	4,0			Ends with medal
	Dc.b	1			POWER UP MAIN!(101)
	Dcb.b	19,0
	Dcb.b	32,1
	Dcb.b	9,0			153
	Dcb.b	2,1			162
	Dcb.b	3,0
	Dcb.b	01,1			167
	Dcb.b	02,0			168-179
	Dcb.b	07,0			170
	Dcb.b	2,0			177
	Dcb.b	4,0
	Dc.b	1			183
	Dcb.b	16,0
	Dc.b	0			200
	Dcb.b	16,1
	Dc.b	1
	Dcb.b	2,0
	Dcb.b	4,1			Caskets
	Dcb.b	2,0			Pig
	Dcb.b	4,1			Energy bolts

	Dcb.b	305-230,1
	Dcb.b	7,0
	Dcb.b	10,1
	Dcb.b	3,0			;322
	
	Dcb.b	40,1			;325
	
	Dcb.b	8,0			;365
	Dcb.b	20,1
	Dcb.b	2,0			;393
	Dcb.b	2,0			;395
	Dcb.b	2,0			;397
	Dcb.b	2,1			;399
	Dcb.b	2,0			;401
	Dcb.b	2,1			;403
	Dcb.b	1,0			;405
	Dcb.b	2,1			;406

	Dcb.b	4,0
	Dcb.b	4,1
	Dcb.b	1,0
	Dcb.b	1,0
;418
	Dcb.b	3,0
	Dcb.b	438-421,1
	Dcb.b	3,1
	Dcb.b	2,1
	Dcb.b	479-443,$01
	Dcb.b	12,0
	Dc.b	1,0,0,0,0,0
	Dc.b	1,1
	Dc.b	1,0
	Dcb.b	4,0
	Dcb.b	2,1
	Dcb.b	4,0
	Dcb.b	2,1
	Dc.b	1
;514
	Dcb.b	3,1
	Dcb.b	4,0
	Dcb.b	13,1

	Dc.b	1
	Ds.b	538-535
	Dc.b	1,1
	Ds.b	560-540

	Dcb.b	8,1

	Dcb.b	16,1

	Dcb.b	32,1
	Dc.b	1

	Dcb.b	619-617,1
	Dc.b	1,1,1,1

	Dcb.b	628-623,0
	Dcb.b	12,1
	Dcb.b	680-640
	Dc.b	1
	Dcb.b	692-681
	Dc.b	0
	Dcb.b	3,1
	Dcb.b	711-696,1
	Dcb.b	716-711,0
	Dcb.b	718-716,1
	Dcb.b	723-718,0
	Dcb.b	5,1
	Dcb.b	740-728
	Dcb.b	50,1

	Dc.b	1
	Ds.b	799-791
	Dc.b	1

	Dcb.b	01,0			
	Dcb.b	16,1

	Ds.b	880-817
	Dc.b	1,1
	Dcb.b	898-882,0
	Ds.b	950-898

	Ds.b	985-950
	Dcb.b	48,1
	Dcb.b	3,1

	Ds.b	1058-1036
	Dc.b	1

	Ds.b	1118-1059
	Dcb.b	9*3,1

	Ds.b	1170-(1118+(9*3))
	Dc.b	1
	Dc.b	0
	Dcb.b	11,1
	Dcb.b	1242-(1170+13),0
	Dc.b	1
	
	Ds.b	1264-1243
	Dcb.b	6,0
	Dc.b	0
	Dcb.b	16,1

	Ds.b	1287-(1270+17)
	dc.b	1,1
	Dc.b	1,1
	Dc.b	0,0,1,1
	Ds.b	1300-1295
	Dc.b	1,1
	Dcb.b	8,1

	Ds.b	1426-1310
	Dc.b	1,1,0
	Dcb.b	25,1
	Dcb.b	1477-1454,0
	Dcb.b	4,0
	Dc.b	1482-1481,0
	Dcb.b	3,1
	Dcb.b	1501-1485,0
	Dc.b	0,0,0,0	
	Dc.b	0,0,0,0
	Dc.b	0,0


**********************************************************
	Dc.b	$00
Bomb_Kill_Table
ZZ
	Dcb.b	48,$01
	Dcb.b	16,$01
	Dcb.b	02,$01
	Dcb.b	26,$00
	Dcb.b	03,$01
	Dc.b	$01
	Dc.b	$01		Plane
	Dcb.b	03,$01
	Dc.b	$00
	Dc.b	$01

	Dcb.b	2,$01
	Dcb.b	1,$01

	Dcb.b	3,$00
	Dc.b	$00
	Dcb.b	5,$00
	Dcb.b	2,$00
	Dc.b	$00		Wheel!
	Dc.b	$00		Crator
	Dcb.b	3,$00
	Dcb.b	16,$01
	Dcb.b	16,$01		Pump
	Dcb.b	9,$01
	Dc.b	$01
	Dc.b	$01
	Dcb.b	3,$01		8bomb-rots
	Dc.b	0,1,1		;167
	Dcb.b	7,$00
	Dcb.b	2,$01
	Dcb.b	4,$00
	Dc.b	$01
	Dcb.b	16,$01		; End level bits
	Dc.b	$00		; Cannon base
	Dcb.b	16,$01		; Cannon turrets
	Dc.b	$01		; Enlarged alien
	Dcb.b	2,$01		; Boosters !
	Dcb.b	4,$00		; Cascets
	Dcb.b	2,$00		; Pig
	Dcb.b	4,$01		; Energy bolts

	Dcb.b	34,$01		; Zoomer+Zooming
	Dc.b	$01
	Dc.b	$01		; Ship bits
	Dcb.b	4,$01		; Cannon boats
	Dcb.b	4,$01		; Cars+Bulldozers

	Dcb.b	2,$01
	Dc.b	$00
	Dcb.b	2,$01		; Train stuff
	Dc.b	$00
	Dcb.b	8,$00
	Dcb.b	2,$01
	Dc.b	$00
	Dcb.b	2,$01		; Train stuff
	Dcb.b	8,$00
	Dc.b	$01		; Guardian left
	Dcb.b	1,$01

	Dcb.b	2,1
	Dcb.b	11,$00

	Dcb.b	6,$01
	Dcb.b	3,$01
;325
	Dcb.b	02,$00	; Level 3 stuff !
	Dcb.b	04,$01
	Dcb.b	01,$01
	Dcb.b	08,$00
	Dcb.b	01,$01
	Dcb.b	16,$00
	Dcb.b	03,$00
	Dcb.b	01,$01
	Dcb.b	04,$00

	Dcb.b	8,0			;365
	Dcb.b	20,1
	Dcb.b	2,0			;393
	Dcb.b	2,0			;395
	Dcb.b	2,0			;397
	Dcb.b	2,1			;399
	Dcb.b	2,0			;401
	Dcb.b	2,1			;403
	Dcb.b	1,0			;405
	Dcb.b	2,1			;406

	Dcb.b	4,0			;408
	Dcb.b	4,1
	Dcb.b	1,0
	Dcb.b	01,$00
;418

	Dcb.b	3,0
	Dc.b	1
	Dcb.b	438-422,0
	Dcb.b	3,1
	Dcb.b	2,1
	Dcb.b	479-443,$01
	Dcb.b	12,0
	Dc.b	1,0,0,0,0,0
	Dc.b	1,1
	Dc.b	1,0
	Dcb.b	4,0
	Dcb.b	2,1
	Dcb.b	4,0
	Dcb.b	2,1
	Dc.b	1

	Dc.b	1,1,1

	Ds.b	521-517
	Dc.b	1

	Dcb.b	534-522,0
	Dc.b	1

	Ds.b	538-535
	Dc.b	1,1
	Ds.b	560-540

	Dcb.b	8,1

	Dcb.b	16,1

	Dcb.b	616-584,1
	Dc.b	1

	Dcb.b	619-617,1
	Dc.b	1,1,1,1

	Dcb.b	628-623,0
	Dc.b	1,1
	Dcb.b	680-630,0
	Dc.b	1
	Dcb.b	692-681,0
	Dc.b	0,1,1,1
	Dcb.b	740-696,1
	Dcb.b	2,0
	Dcb.b	790-742,1	
	Dc.b	1
	Ds.b	799-791
	Dc.b	1
	Dcb.b	01,0			
	Dcb.b	16,1
	Ds.b	880-817
	Dc.b	1
	Dc.b	1
	Dcb.b	898-882,0
	Ds.b	950-898
	Ds.b	985-950
	Dcb.b	48,1
	Dcb.b	3,1
	Dcb.b	1058-1036,0
	Dc.b	1
	Dcb.b	1118-1059,0
	Dcb.b	9*3,1
	Dcb.b	1170-(1118+(9*3)),0
	Dc.b	1
	Dcb.b	1242-1171,0
	Dc.b	01
	Dcb.b	1264-1243,0
	Dcb.b	6,0
	Dc.b	0
	Dcb.b	1287-1271,1
	Dc.b	1,1
	Dc.b	1,1
	Dc.b	0,0,1,1
	Ds.b	1300-1295
	Dc.b	1,1
	Dcb.b	8,1
	Ds.b	1426-1310
	Dc.b	1,1
	Dc.b	0
	Dcb.b	25,1
	Dcb.b	1477-1454,0
	Dcb.b	4,0
	Dc.b	0
	Dcb.b	3,1
	Dcb.b	1501-1485,0
	Dc.b	0,0,0,0	
	Dc.b	0,0,0,0
	Dc.b	0,0


**********************************************************
	Even
	Dc.w	0,0
Enemy_Sprite_Offsets
	Dcb.w	32*2
	Turret_Adj
	Dcb.w	(2*201)-(2*48)
	Cannon_Adj
	Dcb.w	(2*560)-(2*217),0
	Dcb.l	4,0
	Dc.w	-2,-2
	Dc.w	-3,-3
	Dc.w	-8,-8

	Dcb.w	(2*703)-(2*567),0
	Dcb.l	3,(0<16)+2
	Dcb.w	(2*716)-(2*706),0
	Dc.l	(0<<16)+4
	Dc.l	(0<<16)+4
	Dc.l	(0<<16)+4
	Dc.l	(0<<16)+4
	Dcb.w	(2*733)-(2*720),0
	Dcb.l	5,(0<<16)+2

	Dcb.w	(2*774)-(2*738),0
	Turret_Adj

	Dc.w	0,0
	Dc.w	0,0
	Dc.w	0,0
	Dc.w	-4,-10

	Dcb.w	(2*801)-(2*794),0
	Cannon_Adj2

	Dcb.w	(2*853)-(2*817),0
	Dc.w	-56,-7
	Dc.w	-80,-14
	Dc.w	-16,-11
	Dc.w	-31,-27
	Dc.w	-46,-40
	Dc.w	-46,-40
	Dc.w	-55,-48
	Dc.w	-55,-48
	Dcb.w	(985*2)-(861*2),0
	Turret_Adj

	Dcb.w	(1110-1001)*2,0
	Dc.w	6,0
	Dc.w	0,0
	Dc.w	0,0
	Dc.w	0,0
	Dc.w	6,0
	Dc.w	0,0
	Dc.w	0,0
	Dc.w	0,0

	Dcb.w	(1222-1118)*2,0
	Dc.w	0,0
	Cannon_Adj
	
	Dcb.w	(1271-(1222+17))*2,0
	Cannon_Adj2					; Cannon

	Dcb.w	(1485-(1271+16))*2,0
	Cannon_Adj

	Dcb.w	300*2,0

	Dc.w	-1
Shadow_Tab
	Dc.w	862,863,864,865,866,867,868,869,870,871,872,873,874,875,876,877
	Dcb.w	66-16,-1
	Dc.w	903
	Dc.w	903
	Dc.w	903
	Dc.w	903
	Dc.w	903
	Dc.w	903
	Dc.w	903
	Dc.w	903
	Dc.w	903
	Dc.w	903

	Dc.w	904
	Dc.w	905
	Dc.w	906
	Dc.w	907

	Dcb.w	96-80,-1
	Dc.w	878
	Dcb.w	101-97,-1
	Dc.w	880

	Dcb.w	109-102,-1
	Dc.w	903
	Dc.w	903
	Dc.w	903
	Dc.w	903
	Dc.w	903

	Dcb.w	121-114,-1
	Dc.w	862,863,864,865,866,867,868,869,870,871,872,873,874,875,876,877
	Dcb.w	162-137,-1
	Dc.w	922
	Dc.w	911
	Dcb.w	217-164,-1
	Dc.w	901

	Dcb.w	230-218,-1
	Dc.w	949,950,951,952,953,954,955,956,957,958,959,960,961,962,963,964
	Dc.w	949,950,951,952,953,954,955,956,957,958,959,960,961,962,963,964
	Dc.w	975
	Dc.w	975

	Dcb.w	301-264,-1
	Dc.w	972
	Dcb.w	365-302,-1
	Dcb.w	460-365,-1
	Dc.w	1248,1249,1250,1251,1252,1253,1254,1255
	Dcb.w	497-468,-1
	Dc.w	-1,-1
	Dcb.w	513-499,-1
	Dc.w	1055
	Dcb.w	584-514,-1
	Dc.w	1145,1146,1147,1148,1149,1150,1151,1152,1153,1154,1155,1156,1157,1158,1159,1160
	Dc.w	1145,1146,1147,1148,1149,1150,1151,1152,1153,1154,1155,1156,1157,1158,1159,1160
	Dc.w	977
	Dcb.w	619-617,-1
	Dc.w	1169
	Dcb.w	680-620,-1
	Dc.w	980
	Dcb.w	1170-681,-1
	Dc.w	1171
	Dcb.w	1240-1171,-1
	Dc.w	972
	Dcb.w	1429-1241,-1
	Dcb.w	25,977
	Dcb.w	100,-1

Sprite_Display_Hit_Table
	Dcb.w	50,-1
	Dc.w	984
	Dcb.w	92-51,-1
	Dcb.w	2,921
	Dcb.w	96-94,-1
	Dc.w	899
	Dcb.w	101-97,-1
	Dc.w	945
	Dcb.w	162-102,-1
	Dc.w	920,910
	Dcb.w	183-164,-1
	Dc.w	947
	Dcb.w	217-184,-1
	Dc.w	902

	Dcb.w	264-218,-1
	Dc.w	983

	Dcb.w	301-265,-1
	Dc.w	970
	Dc.w	971
	Dc.w	973
	Dc.w	974

	Dcb.w	327-305,-1
	Dc.w	826,827,828,829
	Dc.w	821
	Dcb.w	365-332,-1
	Dc.w	-1,-1,-1,-1
	Dcb.w	406-369,-1	
	Dc.w	836

	Dcb.w	421-407,-1
	Dc.w	1045
	Dcb.w	446-422,-1
	Dc.w	1048
	Dc.w	1047
	Dcb.w	479-448,-1
	Dc.w	1256,1257,1258,1259
	Dcb.w	497-483,-1
	Dc.w	1050,1051

	Dcb.w	513-499,-1
	Dc.w	1049
	Dc.w	1059,1059,1059
	Dcb.w	521-517,-1
	Dc.w	1060,1061,1062,1062,1063,1064,1065,1066,1067,1068,1069,1070
	Dcb.w	534-(521+12),-1
	Dc.w	1089
	Dcb.w	538-535,-1
	Dc.w	1087,1088
	Dcb.w	560-540,-1
	Dc.w	1093,1094,1095,1096,1097,1098,1099

	Dcb.w	568-567,-1
	Dc.w	1244
	Dcb.w	3,-1
	Dc.w	1245
	Dcb.w	3,-1
	Dc.w	1246
	Dcb.w	3,-1

	Dcb.w	616-580,-1
	Dc.w	976
	Dcb.w	619-617,-1
	Dc.w	1161,1162,1163,1164

	Dcb.w	628-623,-1
	Dc.w	1413,1414,1415,1416,1417,1418,1419,1420,1421,1422,1423,1424
	Dcb.w	680-640,-1
	Dc.w	978

	Dcb.w	790-681,-1
	Dc.w	791
	Dcb.w	881-791,-1
	Dc.w	947

	Dcb.w	1058-882,-1
	Dc.w	1045
	Dcb.w	1118-1059,-1
	Dc.w	1184,1185,1186,1187,1188,1189,1190,1191,1192
	Dc.w	1184,1185,1186,1187,1188,1189,1190,1191,1192
	Dc.w	1184,1185,1186,1187,1188,1189,1190,1191,1192

	Dcb.w	1170-(1118+(3*9)),-1
	Dc.w	1060
	Dc.w	-1
	Dc.w	1061,1062,1063,1064,1065,1066,1067,1068,1069,1070,1071
	Dcb.w	1242-1183
	Dc.w	1243
	Dcb.w	1287-1243,-1
	Dc.w	1373,1374
	Dc.w	1375,1376
	Dc.w	-1,-1,1379,1380
	Dcb.w	1300-1295,-1
	Dc.w	1386,1387		!!!!!!!!!!!!!

	Dc.w	1388,1389,1390,1391,1392,1393,1394,1395
	Dcb.w	1426-1310,-1
	Dc.w	1379,1380
	Dcb.w	200,-1

Sprite_Display_DMG_Table
	Dcb.w	50,-1
	Dc.w	965
	Dcb.w	92-51,-1
	Dcb.w	2,925
	Dcb.w	96-94,-1
	Dc.w	900
	Dcb.w	101-97,-1
	Dc.w	946
	Dcb.w	162-102,-1
	Dc.w	924,-1		923
	Dcb.w	183-164,-1
	Dc.w	948
	Dcb.w	217-184,-1
	Dc.w	926
	Dcb.w	264-218,-1
	Dc.w	792
	
	Dcb.w	301-265,-1
	Dc.w	966
	Dc.w	967
	Dc.w	968
	Dc.w	969


	Dcb.w	331-305,-1
	Dc.w	844

	Dcb.w	365-332,-1
	Dc.w	-1,-1,-1,-1
	Dcb.w	406-369,-1	
	Dc.w	845

	Dcb.w	421-407,-1
	Dc.w	1046
	Dcb.w	446-422,-1
	Dc.w	1056,1057

	Dcb.w	479-448,-1
	Dc.w	1260,1261,1262,1263
	Dcb.w	497-483,-1
	Dc.w	1052,1053
	Dcb.w	513-499,-1
	Dc.w	1054	
	Dcb.w	519-514,-1
	Dc.w	-1,-1
	Dc.w	1072,1073,1074,1074,1075,1076,1077,1078,1079,1080,1081,1082


	Dcb.w	534-(521+12),-1
	Dc.w	1084

	Dcb.w	538-535,-1
	Dc.w	1085,1086
	Dcb.w	560-540,-1
	Dc.w	1100,1101,1102,1103,1104,1105,1106

	Dcb.w	619-567,-1
	Dc.w	1165,1166,1167,1168

	Dcb.w	628-623,-1

	Dcb.w	680-628,-1
	Dc.w	979

	Dcb.w	881-681,-1
	Dc.w	948
	Dcb.w	1058-882,-1
	Dc.w	1046

	Dcb.w	1118-1059,-1
	Dc.w	1195,1196,1197,1198,1199,1200,1201,1202,1203
	Dc.w	1195,1196,1197,1198,1199,1200,1201,1202,1203
	Dc.w	1195,1196,1197,1198,1199,1200,1201,1202,1203
	Dcb.w	1170-(1118+(3*9)),-1
	Dc.w	1072
	Dc.w	-1
	Dc.w	1073,1074,1075,1076,1077,1078,1079,1080,1081,1082,1083
	Dcb.w	1242-1183,-1
	Dc.w	1509
	Dcb.w	1287-1243,-1
	Dc.w	1330,1331
	Dc.w	1332,1333
	Dc.w	-1,-1,1336,1337
	Dcb.w	1300-1295,-1
	Dc.w	1343,1344		!!!!!!!!!!!!!
	Dc.w	1345,1346,1347,1348,1349,1350,1351,1352
	Dcb.w	1426-1310,-1
	Dc.w	1336,1337
	Dcb.w	200,-1

	Dc.w	0
Sprite_Child_Parent_HitDMG_Table ;Prev counts, next counts
	Dcb.w	301,0
	Dc.b	0,1
	Dc.b	1,0
	
	Dcb.w	327-303,0
	Dc.b	0,1
	Dc.b	1,0
	Dc.b	0,1
	Dc.b	1,0

	Dcb.w	365-331,0
	Dc.b	0,21

	Dcb.w	405-366,0
	Dc.b	18,0
	Dcb.w	479-406,0
	Dc.b	0,4			;!!!!

	Dcb.w	499-480,0
	Dc.b	12,0
	Dcb.w	521-500,0
	Dc.b	0,6
	Dc.b	1,5
	Dc.b	2,4
	Dc.b	3,3
	Dc.b	4,2
	Dc.b	5,1
	Dc.b	6,0

	Ds.w	619-528
	Dc.b	0,3
	Dc.b	1,2
	Dc.b	2,1
	Dc.b	3,0
	Dcb.w	628-623				;---
	Dc.b	0,3
	Dc.b	1,2	
	Dcb.w	3,$0201
	Dcb.w	7,$0300

	Dcb.w	981-640
	Dc.b	0,27
	Dcb.w	1170-982
	Dc.b	0,6
	Dc.b	1,5
	Dcb.w	2,$0204
	Dcb.w	2,$0303
	Dcb.w	2,$0402
	Dcb.w	2,$0501
	Dcb.w	2,$0600

	Dcb.w	1287-1182
	Dc.b	0,1
	Dc.b	1,0
	Dcb.w	300,0

