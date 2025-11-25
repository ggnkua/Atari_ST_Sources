;0-Shot
;1-Laser
;2-Rockets
;3-Homing missle
;4-Big Powerup
;5-Pig
;6-Medal
;7-Tree Fairy
;8-Bomb
;9-Medal or pig !

Powerup_Event_Pointers
	Dc.l	PLV1
	Dc.l	PLV2
	Dc.l	PLV3
	Dc.l	PLV4
	Dc.l	PLV5
	Dc.l	PLV6
	Dc.l	PLV7
	Dc.l	PLV8

PLV1	Dc.b	0,1,6,2,6,6
	Dc.b	6,9,2,6,6
	Dc.b	0,8,7,1,6,6,0,0,1,6,6

PLV2	Dc.b	6,6,1
	Dc.b	0				;----
	Dc.b	6,6,5,6
	Dc.b	0
	Dc.b	1				;----
	Dc.b	6,6,6,6,3
	Dc.b	2				;----
	Dc.b	1
	Dc.b	2,6,6,6,6,6,6
;	Dc.b	6,6,1,6,1
	Dc.b	6,6,6
	Dc.b	2,6,1

PLV3	
	Dc.b	3,6,6,1
	Dc.b	0				;----
	Dc.b	6,1
	Dc.b	4,6,6,6,6,6,5,1,1

PLV4	Dc.b	1
	Dc.b	1			;---
	Dc.b	6,3,6,6,6
	Dc.b	2			;----
	Dc.b	6,6,1
	Dc.b	0			;----
	Dc.b	0,6,6,6,6,6,6,6,6,6
;	Dc.b	6
	Dc.b	0,6,6,6,6,6,6,3,2

PLV5	Dc.b	1
	Dc.b	0			;----
	Dc.b	6,6,6,6,0,6,6,6,6
	Dc.b	2			;----
	Dc.b	0,6,6,6,3,6,6,6,6,6,6,4,3,0,1,1,6,6,0
	Dc.b	0			;----

PLV6	

	Dc.b	1,0			4
	Dc.b	0			;----

	Dc.b	6,6,6,6,6,6,0,3
	Dc.b	2			;----

	Dc.b	6,6,1

	Dc.b	1			;----

	Dc.b	6,1,6,6,6
	
	Dc.b	3			;----

	Dc.b	6,6,6,2

	Dc.b	3			;----

	Dc.b	0		


PLV7	Dc.b	1,4,6,6,6,6,6,6,6,6,0,6,6,6,0,6,6,6,6,0,1,1,0

PLV8
	Dc.b	1

	Dc.b	0		;-----
	
	Dc.b	6,6,6,6,2
	
	Dc.b	2		;-----

	Dc.b	6,0,6,6,6

	Dc.b	3		;-----
	
	Dc.b	6,6,6,0

	Dc.b	4		;-----

	Dc.b	3,0,6

	Dc.b	3		;-----
	
	Dc.b	6,1

	Dc.b	1		;-----

	Dc.b	6,6,6,6,6,6,6,6,6,6,0

	Dc.b	0		;-----

	Dc.b	6,6

	Even
