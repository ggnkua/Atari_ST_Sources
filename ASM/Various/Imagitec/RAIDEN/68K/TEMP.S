atarilo.s 25: ;	Move.w	#Screen_Height/2,d1
boot.s 34: Screen_Height		Equ		222
carrier.s 260: 	Dc.b	Screen_Height+Max_Scroll_Speed-200,1
carrier.s 279: 	Dc.b	Screen_Height+Max_Scroll_Speed-200,1
carrier.s 319: 	Dc.b	Screen_Height+Max_Scroll_Speed-200,1
carrier.s 346: 	Dc.b	Screen_Height+Max_Scroll_Speed-200,1
carrier.s 386: 	Dc.b	Screen_Height+Max_Scroll_Speed-200,1
carrier.s 730: 	Cmp.w	#Screen_Height,d1
carrier.s 743: 	Cmp.w	#Screen_Height,d1
carrier.s 878: 	Cmp.w	#Screen_Height+Max_Scroll_Speed-1,d7
carrier.s 894: ;	Move.w	#Screen_Height+Max_Scroll_Speed-1,d3
carrier.s 895: 	Move.w	#Screen_Height+Max_Scroll_Speed,d3
carrier.s 916: 	Move.w	#Screen_Height,d3
carrier.s 932: 	Cmp.w	#Screen_Height+Max_Scroll_Speed-1,d7
carrier.s 948: ;	Move.w	#Screen_Height+Max_Scroll_Speed-1,d3
carrier.s 949: 	Move.w	#Screen_Height+Max_Scroll_Speed,d3
carrier.s 970: 	Move.w	#Screen_Height,d3
carrier.s 979: 	Move.w	#Screen_Height+Max_Scroll_Speed,-(sp)
carrier.s 1016: 	Move.w	#Screen_Height+Max_Scroll_Speed-1,Map_Line_Offset0(a4)
carrier.s 1120: 	Move.w	#Screen_Height+Max_Scroll_Speed-1,Map_Line_Offset1(a4)
carrier.s 1147: 	Sub.w	#Screen_Height+100,d2
carrier.s 1171: 	Cmp.w	#Screen_Height,d2
carrier.s 1215: 	Cmp.w	#Screen_Height,d1
equates.s 24: Screen_Height		Equ	226
equates.s 27: Playfield_Height	Equ	Screen_Height
intro.s 143: 	Move.w	#-Screen_Height+40-32,Rdlogo_coard+2
intro.s 145: 	Move.w	#Screen_Height,-(sp)
intro.s 629: 	Move.w	#Screen_Height-27-24+8,d1
intro.s 1093: 	Move.w	#Screen_Height,-(sp)
intro.s 1214: 	Move.w	#Screen_Height-40,d1
intro.s 1396: 	Add.w	#Screen_Height/2,d1
raiden.s 618: ;	Move.w	#Screen_Height,d1
raiden.s 1247: ;	Move.w	#(Screen_Height-40)&$fffe,d7
raiden.s 1807: ;	Cmp.w	#Screen_Height,d1
raiden.s 2035: ;	Move.w	#Screen_Height/2,d1
raiden.s 2190: ;	Move.w	#Screen_Height/2,d1		; Middle of screen
raiden.s 2227: ;	Move.w	#(Screen_Height/2)+30,d1		; Middle of screen
raiden.s 2266: ;	Move.w	#Screen_Height/2,d1		; Middle of screen
raiden.s 2350: ;	Add.w	#Screen_Height,d3
raiden.s 3306: ;	Sub.w	#(Screen_Height-20)/2,d1
raiden.s 3390: ;	Cmp.w	#Screen_Height,d1
raiden.s 3393: ;	Move.w	#Screen_Height,d1
raiden.s 3402: ;	Cmp.w	#Screen_Height/2,d1
raiden.s 3715: ;	Cmp.w	#Screen_Height,d1
raiden.s 3738: ;	Cmp.w	#Screen_Height,d1
raiden.s 3754: ;	Cmp.w	#Screen_Height,d1
raiden.s 4187: ;	Cmp.w	#Screen_Height-120,d1
raiden.s 4212: ;	Cmp.w	#Screen_Height-120,d1
raiden.s 5074: ;	Cmp.w	#Screen_Height-120,d1
raiden.s 7721: ;	Move.w	#Screen_Height,Aln_Seqdec(a6)
raiden.s 8714: ;	Cmp.w	#Screen_Height-16,d1
raiden.s 8750: ;	Cmp.w	#Screen_Height-16,d1
raiden.s 8855: ;	Cmp.w	#Screen_Height,d1
raiden.s 9327: ;	Cmp.w	#Screen_Height,d1
raiden.s 9414: ;	Cmp.w	#Screen_Height,d1
raiden.s 10405: ;	Cmp.w	#Screen_Height,d2
raiden.s 10578: 	Move.w	#Screen_Height-4,d1
raiden.s 11749: ;	Move.w	#Screen_Height,-(sp)
raiden.s 12305: ;	Move.w	#Screen_Height+100,Shipxy+2(a3)
raiden.s 13367: ;	Cmp.w	#Screen_Height-32,d1
video.s 18: disp_height	equ	Screen_Height	;this is in lines
