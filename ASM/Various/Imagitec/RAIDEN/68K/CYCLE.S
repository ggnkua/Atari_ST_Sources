; 1st Intens (COLOUR -1 terminates !)
; 2nd Cycle (Colour, Direction -1 terminates!)
; 3rd ( Flash colour, -1 terminates!)
	
	Dc.l	End_ScreenC
Level_Color_Tables
	Dc.l	Level1C
	Dc.l	Level2C
	Dc.l	Level3C
	Dc.l	Level4C
	Dc.l	Level5C
	Dc.l	Level6C
	Dc.l	Level7C
	Dc.l	Level8C

End_ScreenC
	Dc.w	-1
	Dc.w	1,15,-1
	Dc.w	-1	
	Dc.w	-1	

Level1C	
	Dc.w	-1
	Dc.w	124,-4,-1
	Dc.w	4,5,15,75,200
	Dc.w	201,202,203,204,205,206,207,208,209,210,211,212,213,214,-1
Level2C
	Dc.w	140
	Dc.w	-1
	Dc.w	-1
	Dc.w	-1
Level3C
	Dc.w	208,209,210,211,212,213,214,215,216,217,218,219,220,221,222,223,-1
	Dc.w	-1
	Dc.w	-1
Level4C
	Dc.w	192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207,-1
	Dc.w	208,8,216,4,220,4,-1
	Dc.w	-1
Level5C
	Dc.w	95,96,97,98,99,100,101,102,103,104,105,106
	Dc.w	-1
	Dc.w	-1
	Dc.w	-1
Level6C
	Dc.w	-1
	Dc.w	(256-7),7,-1
	Dc.w	-1
Level7C
	Dc.w	170,171,172,173,174,175,176,177,178,179,180,181,182,-1	
	dc.w	-1
	dc.w	-1
Level8C
	Dc.w	192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207,-1
	Dc.w	80,8,-1
	Dc.w	-1
