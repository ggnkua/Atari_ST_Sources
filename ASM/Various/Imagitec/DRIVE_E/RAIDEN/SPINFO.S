	Dc.b	0
Dead_Alien_Jump_Table
	Dcb.b	016,0
	Dcb.b	016,1
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
	Dcb.b	16,6
	Dcb.b	09,0
	Dcb.b	001,2
	Dcb.b	001,10
;164
	Dcb.b	003,0
	Dcb.b	003,11
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

	Dcb.b	003,0
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
	Dcb.b	2,17			; Void sprite 64 !
	Dcb.b	4,16			; Side bits
	Dcb.b	4,16			; Side bits
x16
	Dcb.b	1,2			; Main bit !
	Dcb.b	2,2
;408
	Dcb.b	09,0
	Dcb.b	01,0

;418	
	Dcb.b	479-418,2
	Dcb.b	4,13
	Dcb.b	4,00
	Dcb.b	4,00
;491
	Dcb.b	1,20
	Dcb.b	497-492,2
	Dcb.b	2,2
	Dcb.b	501-499,0
	Dcb.b	513-501,16
	Dc.b	2

**********************************************************
	Dc.b	0
Alien_Save_Table
	Dcb.b	64,1
	Dcb.b	34,1
	Dcb.b	02,0		Bottom left, bottom right
	Dcb.b	04,1
	Dcb.b	01,0
	Dcb.b	11,1
	Dcb.b	01,0		116;Bottom right weel (2)
	Dcb.b	04,1
	Dcb.b	32,1
	Dcb.b	02,1
	Dcb.b	03,0		Middle power up 155
	Dcb.b	04,0		Power up rockets+boosts
	Dcb.b	01,1
	Dcb.b	04,1		Bomb 8 way
	Dcb.b	03,1		1-up
	Dcb.b	04,1		Explosion 48
	Dcb.b	03,0		Ship explosion
	Dcb.b	06,1		End level big thing
	Dcb.b	01,1		Guardian
	Dcb.b	04,1		Whirrys for end level
	Dcb.b	12,0		Cannons for end level
	Dcb.b	20,1		Enlarged,cannons+boosts up
	Dcb.b	10,1		Caskets,pig,enlarged bolts
	
	Dcb.b	95,1		All level 2 stuff
	Dcb.b	40,1		All level 3 stuff
	Dcb.b	08,1
	Dcb.b	20,0		
	Dcb.b	04,0		;393
	Dcb.b	08,0		;397
	Dcb.b	01,0		; Middle bit for level 3 guardian
	Dcb.b	02,1		; Power up bit for level 3
	Dcb.b	09,1		; Open and shut case
	Dcb.b	01,1		; Grid system
	
	Dcb.b	514-418,1
	
	Dcb.b	568-414,1
	

**********************************************************
	Dc.b	0
Enemy_Prioritys				; (0-3!) (0=lowest!-1ST ON SCREEN)
	Dcb.b	16,2			Alien sprites
	Dcb.b	16,1			Tank sprite
	Dcb.b	16,1			Tank turret
	Dcb.b	02,1			Spinny bits for mid2 level tank
	Dcb.b	13,2			Main bits for mid level tank
	Dcb.b	01,1			Spinny bits 2
;64
	Dcb.b	02,3			Energy bolt
	Dcb.b	14,3			Power ups!
	Dcb.b	06,3			Explosions
	Dcb.b	02,3			Angel
	Dcb.b	02,0			Crater
	Dcb.b	01,1			Spiiny bits 2
	Dcb.b	01,1			Tree 
	Dcb.b	03,1			Big tank
	Dcb.b	01,1			Tank wheel
	Dcb.b	01,3			Big plane
	Dcb.b	03,1			Wheels of a tank
	Dcb.b	01,1			Medal
;101
	Dcb.b	01,3			Power-Up ship
	Dcb.b	03,1			Wheels
	Dcb.b	03,3			Huge Explosions
	Dcb.b	01,1			Medal
	Dcb.b	05,3			Rest of Power ups!
	Dcb.b	02,3			Explosions
	Dcb.b	01,1			Wheel
	Dcb.b	01,0			Crator
	Dcb.b	03,3			Explosions
	Dcb.b	16,2			Alien sprites
	Dcb.b	16,1			Tank turret
	Dcb.b	05,3			Power-Up Bits+Boost
	Dcb.b	02,2			Tweeny powerup
;160
	Dcb.b	02,2			Power up whirrys
	Dcb.b	01,3			Big plane
	Dcb.b	04,3			8-waybomb
	Dcb.b	03,1			1-ups
	Dcb.b	04,3			Explosions
	Dcb.b	03,3			Player death anims
	Dcb.b	02,3			Up rockets
	Dcb.b	04,2			End level platform
	Dcb.b	01,1			End level guardian
	Dcb.b	04,0			Whirry bits for guardian
	Dcb.b	12,1			Cannons for guardian
	Dcb.b	01,0
	Dcb.b	16,1
	Dcb.b	01,3
	Dcb.b	02,3			Boosters for enlarged alien
	Dcb.b	06,1			Caskets+Pig
	Dcb.b	04,2			Bolts for enlarge
;230
	Dcb.b	32,3			Zooming
	Dcb.b	02,3			Zoomer
	Dcb.b	02,1			Power up boat
	Dcb.b	04,1			Boats u/d/l/r
	Dcb.b	02,1			Car
	Dcb.b	02,1			Bulldozer
	Dcb.b	27,1			Train stuff !
	Dcb.b	24,3			End level bits(2)
;325
	Dcb.b	02,1
	Dcb.b	04,2
	Dcb.b	09,1
	Dcb.b	17,1
	Dcb.b	08,1
;365
	Dcb.b	43,0
	Dcb.b	09,0		;9
	Dcb.b	01,3		;1
;418
	Dcb.b	514-418,3
	

**********************************************************
; 0 = alien Cant hit ya!, 1=this alien can kill!
	Dc.b	0
Test_Priority
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
	Dcb.b	09,0			;152
	Dcb.b	05,1			; Biglane up !,?,8-way+rotary!
	Dcb.b	03,0			1-up
	Dcb.b	04,0			48x48 explosion
	Dcb.b	03,0			ship explosion
	Dcb.b	02,0			up rockets
	Dcb.b	04,0			upper bits for end level guardian
	Dcb.b	01,0			End level guardian
	Dcb.b	16,0			Bits for end level guardian
	Dcb.b	01,0			Cannon base
	Dcb.b	16,0			Cannon turrets
	Dcb.b	01,1			Enlarged alien
	Dcb.b	02,0			Booster for enlarged alien
	Dcb.b	04,0			Caskets
	Dcb.b	02,1			Pig
	Dcb.b	04,1			Energy bolts for enlarged alien

	Dcb.b	34,1			Zooming+Zoomer
	Dcb.b	37,0			Ground stuff+Boats
	Dcb.b	24,1			End level guardian

	Dcb.b	92,0			All level 3 stuff
	
	Dcb.b	514-418,0		All Level 4 stuff

**********************************************************
	Dc.b	0
Home_Into				; (0-NO,1-YES)
	Dcb.b	16,1
	Dcb.b	16,1
	Dcb.b	16,1
	Dcb.b	16,0
	Dcb.b	12,0
	Dcb.b	16,0	
	Dcb.b	03,1
	Dc.b	0
	Dc.b	1
	Dcb.b	03,0
	Dc.b	0
	Dc.b	1
	Dcb.b	3,0			Wheels
	Dcb.b	16,0			105-Explosions
	Dcb.b	16,1			121-Aliens(2)
	Dcb.b	16,1			137-recoil
	Dcb.b	9,0			Power up bits !
	Dc.b	1			Big plane up !
	Dcb.b	4,1			8-way explosion+rotary
	Dcb.b	03,1			167
	Dcb.b	07,1			170
	Dcb.b	6,0			Rockets+end level bits
	Dc.b	0			End level guardian
	Dcb.b	16,0			Bits for end level guardian
	Dc.b	0			Cannon base
	Dcb.b	16,1			Cannon turret
	Dc.b	1			Enlarged alien
	Dcb.b	2			Boosters for enlarged alien
	Dcb.b	4,1			Caskets
	Dc.b	0,0			Pig
	Dcb.b	4,0			Enlarged bolts

	Dcb.b	92,01			All 2nd level bits
	Dcb.b	03,00			Exept trendy bolts

	Dcb.b	92,1			All level 3 stuff
	
	Dcb.b	514-418,1		All Level 4 stuff

**********************************************************
;2 Bytes
;1st byte : 0-Cant kill with bomb,1-Can
;2nd byte ; 0-No explosion,1-Explosion	
	Even

	Dc.w	$0000
Bomb_Kill_Table
	Dcb.w	48,$0101
	Dcb.w	16,$0101
	Dcb.w	02,$0100
	Dcb.w	26,$0000
	Dcb.w	03,$0101
	Dc.w	$0100
	Dc.w	$0101		Plane
	Dcb.w	03,$0100
	Dc.w	$0000
	Dc.w	$0101
	Dcb.w	3,$0100
	Dcb.w	3,$0000
	Dc.w	$0000
	Dcb.w	5,$0000
	Dcb.w	2,$0000
	Dc.w	$0000		Wheel!
	Dc.w	$0000		Crator
	Dcb.w	3,$0000
	Dcb.w	16,$0101
	Dcb.w	16,$0101	Pump
	Dcb.w	9,$0100
	Dc.w	$0101
	Dc.w	$0101
	Dcb.w	3,$0100		8bomb-rots
	Dcb.w	10,$0000
	Dcb.w	2,$0100
	Dcb.w	4,$0000
	Dc.w	$0101
	Dcb.w	16,$0100	; End level bits
	Dc.w	$0000		; Cannon base
	Dcb.w	16,$0101	; Cannon turrets
	Dc.w	$0101		; Enlarged alien
	Dcb.w	2,$0100		; Boosters !
	Dcb.w	4,$0000		; Cascets
	Dcb.w	2,$0000		; Pig
	Dcb.w	4,$0100		; Energy bolts

	Dcb.w	34,$0101	; Zoomer+Zooming
	Dc.w	$0101
	Dc.w	$0100		; Ship bits
	Dcb.w	4,$0101		; Cannon boats
	Dcb.w	4,$0101		; Cars+Bulldozers

	Dcb.w	2,$0101
	Dc.w	$0000
	Dcb.w	2,$0101		; Train stuff
	Dc.w	$0000
	Dcb.w	8,$0000
	Dcb.w	2,$0101
	Dc.w	$0000
	Dcb.w	2,$0101		; Train stuff
	Dcb.w	8,$0000
	Dc.w	$0101		; Guardian left
	Dcb.w	14,$0000
	Dcb.w	6,$0101
	Dcb.w	3,$0000

	Dcb.w	02,$0000	; Level 3 stuff !
	Dcb.w	04,$0000
	Dcb.w	01,$0101
	Dcb.w	08,$0000
	Dcb.w	01,$0101
	Dcb.w	16,$0101
	Dcb.w	03,$0000
	Dcb.w	01,$0101
	Dcb.w	04,$0000

	Dcb.w	08,$0000
	Dcb.w	20,$0101
	Dcb.w	02,$0000
	Dcb.w	02,$0101
	Dcb.w	04,$0000
	Dcb.w	04,$0101
	Dcb.w	01,$0101
	Dcb.w	02,$0101
	Dcb.w	03,$0000
	Dcb.w	03,$0101
	Dcb.w	03,$0000
	Dcb.w	01,$0000
;418
	Dcb.w	514-418,$0101


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
	Dcb.b	3,1			Tank
	Dc.b	0
	Dc.b	1
	Dcb.b	4,0			Ends with medal
	Dc.b	1			POWER UP MAIN!(101)
	Dcb.b	19,0
	Dcb.b	32,1
	Dcb.b	9,0			153
	Dcb.b	2,1			162
	Dcb.b	3,0
	Dcb.b	03,1			167
	Dcb.b	07,0			170
	Dcb.b	2,0			177
	Dcb.b	4,0
	Dc.b	0			183
	Dcb.b	16,0
	Dc.b	0			200
	Dcb.b	16,1
	Dc.b	1
	Dcb.b	2,0
	Dcb.b	4,1			Caskets
	Dcb.b	2,0			Pig
	Dcb.b	4,1			Energy bolts

	Dcb.b	92,1			;230
	Dcb.b	3,0			;322
	
	Dcb.b	40,1			;325
	
	Dcb.b	8,0			;365
	Dcb.b	20,1
	Dcb.b	2,0
	Dcb.b	2,1
	Dcb.b	2,0
	Dcb.b	2,1
	Dcb.b	2,0
	Dcb.b	2,1
	Dcb.b	3,1

	Dcb.b	3,0
	Dcb.b	3,1
	Dcb.b	3,0
	Dcb.b	1,0
;418
	Dcb.b	3,0
	Dcb.b	479-421,1
	Dcb.b	12,0
;491
	Dcb.b	1,1
	Dcb.b	497-492,0
	Dcb.b	514-497,1
	Even
