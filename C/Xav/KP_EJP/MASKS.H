/*
**	masks.h
**	ÿÿÿÿÿÿÿ
**	By Xav
**	ÿÿÿÿÿÿ
**
**	To accompany the series on Enhanced Joystick Ports in
**	Atari Computing, issue 5
*/


/*
**	Definitions of the write masks for standard joypad ports. 
**
**	Remember:	Group1	=	Fire A, Up, Down, Left, Right, Pause
**				Group2	=	Fire B, *, 7, 4, 1
**				Group3	=	Fire C, 0, 8, 5, 2
**				Group4	=	Option, #, 9, 6, 3
*/


#define	PORTA_GROUP1	0xFFFE	/*	...11111110	*/
#define	PORTA_GROUP2	0xFFFD	/*	...11111101	*/
#define	PORTA_GROUP3	0xFFFB	/*	...11111011	*/
#define	PORTA_GROUP4	0xFFF7	/*	...11110111	*/

#define	PORTB_GROUP1	0xFFEF	/*	...11101111	*/
#define	PORTB_GROUP2	0xFFDF	/*	...11011111	*/
#define	PORTB_GROUP3	0xFFBF	/*	...10111111	*/
#define	PORTB_GROUP4	0xFF7F	/*	...01111111	*/

