*
*	For GEM/AES calls
*
** .globl	_crystal
** _crystal:
** 	move.l	4(a7),d1
** 	move.w	#200,d0
** 	trap	#2
** 	rts
** 
*
*	control array for vdibind
*
	.data
    	.even
.globl	_ctrl_cnts
_ctrl_cnts:

*	application manager
	.dc.b	0, 1, 0			* function 10		
    	.dc.b	2, 1, 1			* function 11		
    	.dc.b	2, 1, 1 		* function 12		
	.dc.b	0, 1, 1			* function 13		
	.dc.b	2, 1, 1			* function 14		
	.dc.b	1, 1, 1			* function 15		
	.dc.b	0, 0, 0			* function 16		
	.dc.b	0, 0, 0			* function 17		
	.dc.b	0, 0, 0			* function 8		
	.dc.b	0, 1, 0			* function 19		

*	event manager
	.dc.b	0, 1, 0			* function 20		
	.dc.b	3, 5, 0			* function 21		
	.dc.b	5, 5, 0			* function 22		
	.dc.b	0, 1, 1			* function 23		
	.dc.b	2, 1, 0			* function 24		
	.dc.b	16, 7, 1 		* function 25		
	.dc.b	2, 1, 0			* function 26		
	.dc.b	0, 0, 0			* function 27		
	.dc.b	0, 0, 0			* function 28		
	.dc.b	0, 0, 0			* function 9		

*	menu manager
	.dc.b	1, 1, 1			* function 30		
	.dc.b	2, 1, 1			* function 31		
	.dc.b	2, 1, 1			* function 32		
	.dc.b	2, 1, 1			* function 33		
	.dc.b	1, 1, 2			* function 34		
	.dc.b	1, 1, 1			* function 5		
	.dc.b	0, 0, 0			* function 6		
	.dc.b	0, 0, 0			* function 7		
	.dc.b	0, 0, 0			* function 8		
	.dc.b	0, 0, 0			* function 9		

*	object manager
	.dc.b	2, 1, 1			* function 40		
	.dc.b	1, 1, 1			* function 41		
  	.dc.b	6, 1, 1			* function 42		
	.dc.b	4, 1, 1			* function 43		
	.dc.b	1, 3, 1			* function 44		
	.dc.b	2, 1, 1			* function 45		
	.dc.b	4, 2, 1			* function 46		
	.dc.b	8, 1, 1			* function 47		
	.dc.b	0, 0, 0			* function 48		
	.dc.b	0, 0, 0			* function 49		

*	form manager
	.dc.b	1, 1, 1			* function 50		
	.dc.b	9, 1, 1			* function 51		
	.dc.b	1, 1, 1			* function 2		
	.dc.b	1, 1, 0			* function 3		
	.dc.b	0, 5, 1			* function 4		
	.dc.b	0, 0, 0			* function 5		
	.dc.b	0, 0, 0			* function 6		
	.dc.b	0, 0, 0			* function 7		
	.dc.b	0, 0, 0			* function 8		
	.dc.b	0, 0, 0			* function 9		

*	dialog manager
	.dc.b	0, 0, 0			* function 60		
	.dc.b	0, 0, 0			* function 61		
	.dc.b	0, 0, 0			* function 62		
	.dc.b	0, 0, 0			* function 3		
	.dc.b	0, 0, 0			* function 4		
	.dc.b	0, 0, 0			* function 5		
	.dc.b	0, 0, 0			* function 6		
	.dc.b	0, 0, 0			* function 7		
	.dc.b	0, 0, 0			* function 8		
	.dc.b	0, 0, 0			* function 9		

*	graphics manager
	.dc.b	4, 3, 0			* function 70		
	.dc.b	8, 3, 0			* function 71		
	.dc.b	6, 1, 0			* function 72		
	.dc.b	8, 1, 0			* function 73		
	.dc.b	8, 1, 0			* function 74		
	.dc.b	4, 1, 1			* function 75		
	.dc.b	3, 1, 1			* function 76		
	.dc.b	0, 5, 0			* function 77		
	.dc.b	1, 1, 1			* function 78		
	.dc.b	0, 5, 0			* function 9		

*	scrap manager
	.dc.b	0, 1, 1			* function 80		
	.dc.b	0, 1, 1			* function 81		
	.dc.b	0, 0, 0			* function 82		
	.dc.b	0, 0, 0			* function 83		
	.dc.b	0, 0, 0			* function 84		
	.dc.b	0, 0, 0			* function 5		
	.dc.b	0, 0, 0			* function 6		
	.dc.b	0, 0, 0			* function 7		
	.dc.b	0, 0, 0			* function 8		
	.dc.b	0, 0, 0			* function 9		

*	fseler manager
	.dc.b	0, 2, 2			* function 90		
	.dc.b	0, 0, 0			* function 91		
	.dc.b	0, 0, 0			* function 92		
	.dc.b	0, 0, 0			* function 3		
	.dc.b	0, 0, 0			* function 4		
	.dc.b	0, 0, 0			* function 5		
	.dc.b	0, 0, 0			* function 6		
	.dc.b	0, 0, 0			* function 7		
	.dc.b	0, 0, 0			* function 8		
	.dc.b	0, 0, 0 		* function 9		

*	window manager
	.dc.b	5, 1, 0			* function 100		
	.dc.b	5, 1, 0			* function 101		
	.dc.b	1, 1, 0			* function 102		
	.dc.b	1, 1, 0			* function 103		
	.dc.b	2, 5, 0			* function 104		
	.dc.b	6, 1, 0			* function 105		
	.dc.b	2, 1, 0			* function 106		
	.dc.b	1, 1, 0			* function 107		
	.dc.b	6, 5, 0			* function 108		
	.dc.b	0, 0, 0 		* function 9		

*	resource manger
	.dc.b	0, 1, 1			* function 110		
	.dc.b	0, 1, 0			* function 111		
	.dc.b	2, 1, 0			* function 112		
	.dc.b	2, 1, 1			* function 113		
	.dc.b	1, 1, 1			* function 114		
	.dc.b	0, 0, 0			* function 115		
	.dc.b	0, 0, 0			* function 6
	.dc.b	0, 0, 0			* function 7
	.dc.b	0, 0, 0			* function 8
	.dc.b	0, 0, 0			* function 9

*	shell manager
	.dc.b	0, 1, 2			* function 120
	.dc.b	3, 1, 2			* function 121
	.dc.b	1, 1, 1			* function 122
	.dc.b	1, 1, 1			* function 123
	.dc.b	0, 1, 1			* function 124
	.dc.b	0, 1, 2			* function 125

	.end
