	opt	l2
	XDEF	Antenne2
	include	define.s

xoffset1	equ	-20
yoffset1	equ	-40
xoffset2	equ	-60
yoffset2	equ	-25

Antenne2:	dc.l	P_antenne2
	dc.l	0
	dc.l	Antenne2

P_antenne2:	dc.w	72+38-1
;
; 2
;
	dc.w	xoffset1,yoffset1,-$0a			; 0
	dc.w	xoffset1+60,yoffset1,-$0a		; 1
	dc.w	xoffset1+60,yoffset1+24,-$0a		; 2
	dc.w	xoffset1+14,yoffset1+24,-$0a		; 3
	dc.w	xoffset1+40,yoffset1+24,-$0a		; 4
	dc.w	xoffset1+56,yoffset1+52,-$0a		; 5
	dc.w	xoffset1+28,yoffset1+52,-$0a		; 6
	dc.w	xoffset1+36,yoffset1+86,-$0a		; 7
	dc.w	xoffset1+58,yoffset1+64,-$0a		; 8
	dc.w	xoffset1+42,yoffset1+86,-$0a		; 9
	dc.w	xoffset1+48,yoffset1+84,-$0a		; 10
	dc.w	xoffset1+52,yoffset1+80,-$0a		; 11
	dc.w	xoffset1+56,yoffset1+72,-$0a		; 12
	dc.w	xoffset1+28,yoffset1+56,-$0a		; 13
	dc.w	xoffset1+20,yoffset1+58,-$0a		; 14
	dc.w	xoffset1+24,yoffset1+83,-$0a		; 15
	dc.w	xoffset1+4,yoffset1+52,-$0a		; 16
	dc.w	xoffset1+4,yoffset1+73,-$0a		; 17

	dc.w	xoffset1,yoffset1,+$0a			; 0
	dc.w	xoffset1+60,yoffset1,+$0a		; 1
	dc.w	xoffset1+60,yoffset1+24,+$0a		; 2
	dc.w	xoffset1+14,yoffset1+24,+$0a		; 3
	dc.w	xoffset1+40,yoffset1+24,+$0a		; 4
	dc.w	xoffset1+56,yoffset1+52,+$0a		; 5
	dc.w	xoffset1+28,yoffset1+52,+$0a		; 6
	dc.w	xoffset1+36,yoffset1+86,+$0a		; 7
	dc.w	xoffset1+58,yoffset1+64,+$0a		; 8
	dc.w	xoffset1+42,yoffset1+86,+$0a		; 9
	dc.w	xoffset1+48,yoffset1+84,+$0a		; 10
	dc.w	xoffset1+52,yoffset1+80,+$0a		; 11
	dc.w	xoffset1+56,yoffset1+72,+$0a		; 12
	dc.w	xoffset1+28,yoffset1+56,+$0a		; 13
	dc.w	xoffset1+20,yoffset1+58,+$0a		; 14
	dc.w	xoffset1+24,yoffset1+83,+$0a		; 15
	dc.w	xoffset1+4,yoffset1+52,+$0a		; 16
	dc.w	xoffset1+4,yoffset1+73,+$0a		; 17

	dc.w	xoffset1+26,yoffset1+59,-$0a		; 36
	dc.w	xoffset1+26,yoffset1+59,+$0a		; 37
;
; fin du 2
;
;
; debut du A
;
	dc.w	xoffset2+41,yoffset2+2*19,-10		; 0 (+38)
	dc.w	xoffset2+40,yoffset2+2*20,-10		; 1 (+38)
	dc.w	xoffset2+36,yoffset2+41,-10		; 2 (+38)
	dc.w	xoffset2+32,yoffset2+2*20,-10		; 3 (+38)
	dc.w	xoffset2+22,yoffset2+2*17,-10		; 4 (+38)
	dc.w	xoffset2+8,yoffset2+2*10,-10		; 5 (+38)
	dc.w	xoffset2+2,yoffset2+2*5,-10		; 6 (+38)
	dc.w	xoffset2+0,yoffset2+2*2,-10		; 7 (+38)
	dc.w	xoffset2+2,yoffset2+2*0,-10		; 8 (+38)
	dc.w	xoffset2+8,yoffset2+2*0,-10		; 9 (+38)
	dc.w	xoffset2+14,yoffset2+2*2,-10		; 10 (+38)
	dc.w	xoffset2+26,yoffset2+2*7,-10		; 11 (+38)
	dc.w	xoffset2+26,yoffset2+2*4,-10		; 12 (+38)
	dc.w	xoffset2+30,yoffset2+2*2,-10		; 13 (+38)
	dc.w	xoffset2+40,yoffset2+2*0,-10		; 14 (+38)
	dc.w	xoffset2+60,yoffset2+2*1,-10		; 15 (+38)
	dc.w	xoffset2+90,yoffset2+2*6,-10		; 16 (+38)
	dc.w	xoffset2+120,yoffset2+2*12,-10		; 17 (+38)
	dc.w	xoffset2+130,yoffset2+2*15,-10		; 18 (+38)
	dc.w	xoffset2+128,yoffset2+2*16,-10		; 19 (+38)
	dc.w	xoffset2+120,yoffset2+2*14,-10		; 20 (+38)
	dc.w	xoffset2+90,yoffset2+2*8,-10		; 21 (+38)
	dc.w	xoffset2+60,yoffset2+2*4,-10		; 22 (+38)
	dc.w	xoffset2+40,yoffset2+2*3,-10		; 23 (+38)
	dc.w	xoffset2+32,yoffset2+2*5,-10		; 24 (+38)
	dc.w	xoffset2+32,yoffset2+2*7,-10		; 25 (+38)
	dc.w	xoffset2+38,yoffset2+2*12,-10		; 26 (+38)
	dc.w	xoffset2+38,yoffset2+2*14,-10		; 27 (+38)
	dc.w	xoffset2+34,yoffset2+2*14,-10		; 28 (+38)
	dc.w	xoffset2+8,yoffset2+2*3,-10		; 29 (+38)
	dc.w	xoffset2+6,yoffset2+7,-10		; 30 (+38)
	dc.w	xoffset2+12,yoffset2+2*8,-10		; 31 (+38)
	dc.w	xoffset2+26,yoffset2+2*15,-10		; 32 (+38)
	dc.w	xoffset2+32,yoffset2+2*17,-10		; 33 (+38)
	dc.w	xoffset2+36,yoffset2+2*18,-10		; 34 (+38)
	dc.w	xoffset2+38,yoffset2+2*17,-10		; 35 (+38)

	dc.w	xoffset2+41,yoffset2+38,10		; 36 (+38)
	dc.w	xoffset2+40,yoffset2+40,10		; 37 (+38)
	dc.w	xoffset2+36,yoffset2+41,10		; 38 (+38)
	dc.w	xoffset2+32,yoffset2+40,10		; 39 (+38)
	dc.w	xoffset2+22,yoffset2+34,10		; 40 (+38)
	dc.w	xoffset2+8,yoffset2+20,10		; 41 (+38)
	dc.w	xoffset2+2,yoffset2+10,10		; 42 (+38)
	dc.w	xoffset2+0,yoffset2+4,10		; 43 (+38)
	dc.w	xoffset2+2,yoffset2+0,10		; 44 (+38)
	dc.w	xoffset2+8,yoffset2+0,10		; 45 (+38)
	dc.w	xoffset2+14,yoffset2+4,10		; 46 (+38)
	dc.w	xoffset2+26,yoffset2+14,10		; 47 (+38)
	dc.w	xoffset2+26,yoffset2+8,10		; 48 (+38)
	dc.w	xoffset2+30,yoffset2+4,10		; 49 (+38)
	dc.w	xoffset2+40,yoffset2+0,10		; 50 (+38)
	dc.w	xoffset2+60,yoffset2+2,10		; 51 (+38)
	dc.w	xoffset2+90,yoffset2+12,10		; 52 (+38)
	dc.w	xoffset2+120,yoffset2+24,10		; 53 (+38)
	dc.w	xoffset2+130,yoffset2+30,10		; 54 (+38)
	dc.w	xoffset2+128,yoffset2+32,10		; 55 (+38)
	dc.w	xoffset2+120,yoffset2+28,10		; 56 (+38)
	dc.w	xoffset2+90,yoffset2+16,10		; 57 (+38)
	dc.w	xoffset2+60,yoffset2+8,10		; 58 (+38)
	dc.w	xoffset2+40,yoffset2+6,10		; 59 (+38)
	dc.w	xoffset2+32,yoffset2+10,10		; 60 (+38)
	dc.w	xoffset2+32,yoffset2+14,10		; 61 (+38)
	dc.w	xoffset2+38,yoffset2+24,10		; 62 (+38)
	dc.w	xoffset2+38,yoffset2+28,10		; 63 (+38)
	dc.w	xoffset2+34,yoffset2+28,10		; 64 (+38)
	dc.w	xoffset2+8,yoffset2+6,10		; 65 (+38)
	dc.w	xoffset2+6,yoffset2+7,10		; 66 (+38)
	dc.w	xoffset2+12,yoffset2+16,10		; 67 (+38)
	dc.w	xoffset2+26,yoffset2+30,10		; 68 (+38)
	dc.w	xoffset2+32,yoffset2+34,10		; 69 (+38)
	dc.w	xoffset2+36,yoffset2+36,10		; 70 (+38)
	dc.w	xoffset2+38,yoffset2+34,10		; 71 (+38)
;
; fin du A
;
	dc.l	F_Antenne2

F_Antenne2:
;
; epaisseur du 2
;
	VERTICES	0,1,19,18,-1,-1,-1,-1
	COLOR	5
	dc.l	0
	VERTICES	1,2,20,19,-1,-1,-1,-1
	COLOR	5
	dc.l	0
	VERTICES	2,4,22,20,-1,-1,-1,-1
	COLOR	5
	dc.l	0
	VERTICES	4,5,23,22,-1,-1,-1,-1
	COLOR	5
	dc.l	0
	VERTICES	5,8,26,23,-1,-1,-1,-1
	COLOR	5
	dc.l	0
	VERTICES	8,12,30,26,-1,-1,-1,-1
	COLOR	5
	dc.l	0
	VERTICES	12,11,29,30,-1,-1,-1,-1
	COLOR	5
	dc.l	0
	VERTICES	11,10,28,29,-1,-1,-1,-1
	COLOR	5
	dc.l	0
	VERTICES	10,9,27,28,-1,-1,-1,-1
	COLOR	5
	dc.l	0
	VERTICES	9,7,25,27,-1,-1,-1,-1
	COLOR	5
	dc.l	0
	VERTICES	7,15,33,25,-1,-1,-1,-1
	COLOR	5
	dc.l	0
	VERTICES	15,17,35,33,-1,-1,-1,-1
	COLOR	5
	dc.l	0
	VERTICES	17,16,34,35,-1,-1,-1,-1
	COLOR	5
	dc.l	0
	VERTICES	16,14,32,34,-1,-1,-1,-1
	COLOR	5
	dc.l	0
	VERTICES	14,36,37,32,-1,-1,-1,-1
	COLOR	5
	dc.l	0
	VERTICES	36,13,31,37,-1,-1,-1,-1
	COLOR	5
	dc.l	0
	VERTICES	13,6,24,31,-1,-1,-1,-1
	COLOR	5
	dc.l	0
	VERTICES	6,0,18,24,-1,-1,-1,-1
	COLOR	5
	dc.l	0
;
; epaisseur du A
;
	VERTICES	(38+35),(38+0),(38+36),(38+71),-1,-1,-1,-1
	COLOR	5
	dc.l	0
	VERTICES	(38+0),(38+1),(38+37),(38+36),-1,-1,-1,-1
	COLOR	5
	dc.l	0
	VERTICES	(38+1),(38+2),(38+38),(38+37),-1,-1,-1,-1
	COLOR	5
	dc.l	0
	VERTICES	(38+2),(38+3),(38+39),(38+38),-1,-1,-1,-1
	COLOR	5
	dc.l	0
	VERTICES	(38+3),(38+4),(38+40),(38+39),-1,-1,-1,-1
	COLOR	5
	dc.l	0
	VERTICES	(38+4),(38+5),(38+41),(38+40),-1,-1,-1,-1
	COLOR	5
	dc.l	0
	VERTICES	(38+5),(38+6),(38+42),(38+41),-1,-1,-1,-1
	COLOR	5
	dc.l	0
	VERTICES	(38+6),(38+7),(38+43),(38+42),-1,-1,-1,-1
	COLOR	5
	dc.l	0
	VERTICES	(38+7),(38+8),(38+44),(38+43),-1,-1,-1,-1
	COLOR	5
	dc.l	0
	VERTICES	(38+8),(38+9),(38+45),(38+44),-1,-1,-1,-1
	COLOR	5
	dc.l	0
	VERTICES	(38+9),(38+10),(38+46),(38+45),-1,-1,-1,-1
	COLOR	5
	dc.l	0
	VERTICES	(38+10),(38+11),(38+47),(38+46),-1,-1,-1,-1
	COLOR	5
	dc.l	0
	VERTICES	(38+11),(38+12),(38+48),(38+47),-1,-1,-1,-1
	COLOR	5
	dc.l	0
	VERTICES	(38+12),(38+13),(38+49),(38+48),-1,-1,-1,-1
	COLOR	5
	dc.l	0
	VERTICES	(38+13),(38+14),(38+50),(38+49),-1,-1,-1,-1
	COLOR	5
	dc.l	0
	VERTICES	(38+14),(38+15),(38+51),(38+50),-1,-1,-1,-1
	COLOR	5
	dc.l	0
	VERTICES	(38+15),(38+16),(38+52),(38+51),-1,-1,-1,-1
	COLOR	5                                     
	dc.l	0
	VERTICES	(38+16),(38+17),(38+53),(38+52),-1,-1,-1,-1
	COLOR	5
	dc.l	0
	VERTICES	(38+17),(38+18),(38+54),(38+53),-1,-1,-1,-1
	COLOR	5
	dc.l	0
	VERTICES	(38+18),(38+19),(38+55),(38+54),-1,-1,-1,-1
	COLOR	5
	dc.l	0
	VERTICES	(38+19),(38+20),(38+56),(38+55),-1,-1,-1,-1
	COLOR	5
	dc.l	0
	VERTICES	(38+20),(38+21),(38+57),(38+56),-1,-1,-1,-1
	COLOR	5
	dc.l	0
	VERTICES	(38+21),(38+22),(38+58),(38+57),-1,-1,-1,-1
	COLOR	5
	dc.l	0
	VERTICES	(38+22),(38+23),(38+59),(38+58),-1,-1,-1,-1
	COLOR	5
	dc.l	0
	VERTICES	(38+23),(38+24),(38+60),(38+59),-1,-1,-1,-1
	COLOR	5
	dc.l	0
	VERTICES	(38+24),(38+25),(38+61),(38+60),-1,-1,-1,-1
	COLOR	5
	dc.l	0
	VERTICES	(38+25),(38+26),(38+62),(38+61),-1,-1,-1,-1
	COLOR	5
	dc.l	0
	VERTICES	(38+26),(38+27),(38+63),(38+62),-1,-1,-1,-1
	COLOR	5
	dc.l	0
	VERTICES	(38+27),(38+28),(38+64),(38+63),-1,-1,-1,-1
	COLOR	5
	dc.l	0
	VERTICES	(38+28),(38+29),(38+65),(38+64),-1,-1,-1,-1
	COLOR	5
	dc.l	0
	VERTICES	(38+29),(38+30),(38+66),(38+65),-1,-1,-1,-1
	COLOR	5
	dc.l	0
	VERTICES	(38+30),(38+31),(38+67),(38+66),-1,-1,-1,-1
	COLOR	5
	dc.l	0
	VERTICES	(38+31),(38+32),(38+68),(38+67),-1,-1,-1,-1
	COLOR	5
	dc.l	0
	VERTICES	(38+32),(38+33),(38+69),(38+68),-1,-1,-1,-1
	COLOR	5
	dc.l	0
	VERTICES	(38+33),(38+34),(38+70),(38+69),-1,-1,-1,-1
	COLOR	5
	dc.l	0
	VERTICES	(38+34),(38+35),(38+71),(38+70),-1,-1,-1,-1
	COLOR	5
	dc.l	0
;
; face de devant du 2
;
	VERTICES	3,2,1,0,-1,-1,-1,-1
	COLOR	14
	dc.l	0
	VERTICES	6,5,4,0,-1,-1,-1,-1
	COLOR	14
	dc.l	0
	VERTICES	7,8,5,6,-1,-1,-1,-1
	COLOR	14
	dc.l	0
	VERTICES	8,7,9,10,11,12,-1,-1
	COLOR	14
	dc.l	0	
	VERTICES	7,8,6,13,-1,-1,-1,-1
	COLOR	14
	dc.l	0
	VERTICES	36,15,7,13,-1,-1,-1,-1
	COLOR	14
	dc.l	0
	VERTICES	36,14,15,7,-1,-1,-1,-1
	COLOR	14
	dc.l	0
	VERTICES	14,16,17,15,-1,-1,-1,-1
	COLOR	14
	dc.l	0
;
; face de devant du A
;
	VERTICES	(38+35),(38+34),(38+1),(38+0),-1,-1,-1,-1
	COLOR	6
	dc.l	0
	VERTICES	(38+34),(38+2),(38+1),(38+0),-1,-1,-1,-1
	COLOR	6
	dc.l	0
	VERTICES	(38+34),(38+33),(38+3),(38+2),-1,-1,-1,-1
	COLOR	6
	dc.l	0
	VERTICES	(38+33),(38+32),(38+4),(38+3),-1,-1,-1,-1
	COLOR	6
	dc.l	0
	VERTICES	(38+32),(38+31),(38+5),(38+4),-1,-1,-1,-1
	COLOR	6
	dc.l	0
	VERTICES	(38+31),(38+30),(38+6),(38+5),-1,-1,-1,-1
	COLOR	6
	dc.l	0
	VERTICES	(38+30),(38+8),(38+7),(38+6),-1,-1,-1,-1
	COLOR	6
	dc.l	0
	VERTICES	(38+29),(38+10),(38+9),(38+8),(38+30),-1,-1,-1
	COLOR	6
	dc.l	0
	VERTICES	(38+29),(38+28),(38+27),(38+26),(38+11),(38+10),(38+9),-1
	COLOR	6
	dc.l	0
	VERTICES	(38+26),(38+25),(38+11),-1,-1,-1,-1,-1
	COLOR	6
	dc.l	0
	VERTICES	(38+25),(38+24),(38+12),(38+11),-1,-1,-1,-1
	COLOR	6
	dc.l	0
	VERTICES	(38+24),(38+23),(38+14),(38+13),(38+12),-1,-1,-1
	COLOR	6
	dc.l	0
	VERTICES	(38+23),(38+22),(38+15),(38+14),-1,-1,-1,-1
	COLOR	6
	dc.l	0
	VERTICES	(38+22),(38+21),(38+16),(38+15),-1,-1,-1,-1
	COLOR	6
	dc.l	0
	VERTICES	(38+21),(38+20),(38+17),(38+16),-1,-1,-1,-1
	COLOR	6
	dc.l	0
	VERTICES	(38+20),(38+19),(38+18),(38+17),-1,-1,-1,-1
	COLOR	6
	dc.l	0
;
; face de derriere du 2
;
	VERTICES	18,19,20,21,-1,-1,-1,-1
	COLOR	14
	dc.l	0
	VERTICES	18,22,23,24,-1,-1,-1,-1
	COLOR	14
	dc.l	0
	VERTICES	24,23,26,25,-1,-1,-1,-1
	COLOR	14
	dc.l	0
	VERTICES	25,26,30,29,28,27,-1,-1
	COLOR	14
	dc.l	0
	VERTICES	24,26,25,31,-1,-1,-1,-1
	COLOR	14
	dc.l	0
	VERTICES	31,25,33,37,-1,-1,-1,-1
	COLOR	14
	dc.l	0
	VERTICES	25,33,32,37,-1,-1,-1,-1
	COLOR	14
	dc.l	0
	VERTICES	33,35,34,32,-1,-1,-1,-1
	COLOR	14
	dc.l	0
;
;face de derriere du A
;
	VERTICES	(38+36),(38+37),(38+70),(38+71),-1,-1,-1,-1
	COLOR	6
	dc.l	0
	VERTICES	(38+70),(38+36),(38+37),(38+38),-1,-1,-1,-1
	COLOR	6
	dc.l	0
	VERTICES	(38+38),(38+39),(38+69),(38+70),-1,-1,-1,-1
	COLOR	6
	dc.l	0
	VERTICES	(38+39),(38+40),(38+68),(38+69),-1,-1,-1,-1
	COLOR	6
	dc.l	0
	VERTICES	(38+40),(38+41),(38+67),(38+68),-1,-1,-1,-1
	COLOR	6
	dc.l	0
	VERTICES	(38+41),(38+42),(38+66),(38+67),-1,-1,-1,-1
	COLOR	6
	dc.l	0
	VERTICES	(38+42),(38+43),(38+44),(38+66),-1,-1,-1,-1
	COLOR	6
	dc.l	0
	VERTICES	(38+66),(38+44),(38+45),(38+46),(38+65),-1,-1,-1
	COLOR	6
	dc.l	0
	VERTICES	(38+65),(38+45),(38+46),(38+47),(38+62),(38+63),(38+64),-1
	COLOR	6
	dc.l	0
	VERTICES	(38+47),(38+61),(38+62),-1,-1,-1,-1,-1
	COLOR	6
	dc.l	0
	VERTICES	(38+47),(38+48),(38+60),(38+61),-1,-1,-1,-1
	COLOR	6
	dc.l	0
	VERTICES	(38+49),(38+50),(38+59),(38+60),(38+48),-1,-1,-1
	COLOR	6
	dc.l	0
	VERTICES	(38+50),(38+51),(38+58),(38+59),-1,-1,-1,-1
	COLOR	6
	dc.l	0
	VERTICES	(38+51),(38+52),(38+57),(38+58),-1,-1,-1,-1
	COLOR	6
	dc.l	0
	VERTICES	(38+52),(38+53),(38+56),(38+57),-1,-1,-1,-1
	COLOR	6
	dc.l	0
	VERTICES	(38+53),(38+54),(38+55),(38+56),-1,-1,-1,-1
	COLOR	6
	dc.l	0

	dc.w	-1

