/*
**	masks.h
**	ÿÿÿÿÿÿÿ
**	By Xav
**	ÿÿÿÿÿÿ
**
**	To accompany the series on Enhanced Joystick Ports in
**	Atari Computing
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


/*
**	Definitions of the write masks for the Team Tap ports.
**	
**	Note that those beginning PORTAA_ are identical to those
**	beginning PORTA_ above. If you are just writing your first
**	EJP program, please use PORTAA_ because the others are just
**	included so that this file can replace the old version from
**	AC issue 5 without breaking any existing programs. Note that
**	this also applies to the prefixes PORTAB_ and PORTB_
**
**	Please refer to the articles in Atari Computing to get a better
**	idea of how best to incorporate the Team Tap into your own
**	games. Also, _PLEASE_ write your programs to use any of the
**	Team Tap ports, even if the logic of your game only requires
**	one or two joypads.
**
**	Finally you should note that PORTAB_ refers to the first port
**	on the computer or games console (port A on the STe and Falcon,
**	port 1 on the Jaguar) and the second port on the Team Tap.
**	Therefore the four prefixes for the Team Tap attached to the
**	first port are PORTAA_, PORTAB_, PORTAC_ and PORTAD_. The
**	prefixes for the Team Tap attached to the second port are
**	PORTBA_, PORTBB_, PORTBC_ and PORTBD.
**
*/

#define	PORTAA_GROUP4	0xFFFE	/*	...11111110	*/
#define	PORTAA_GROUP3	0xFFFD	/*	...11111101	*/
#define	PORTAA_GROUP2	0xFFFB	/*	...11111011	*/
#define	PORTAA_GROUP1	0xFFF7	/*	...11110111	*/

#define	PORTAB_GROUP4	0xFFF0	/*	...11110000	*/
#define	PORTAB_GROUP3	0xFFF1	/*	...11110001	*/
#define	PORTAB_GROUP2	0xFFF2	/*	...11110010	*/
#define	PORTAB_GROUP1	0xFFF3	/*	...11110011	*/

#define	PORTAC_GROUP4	0xFFF4	/*	...11110100	*/
#define	PORTAC_GROUP3	0xFFF5	/*	...11110101	*/
#define	PORTAC_GROUP2	0xFFF6	/*	...11110110	*/
#define	PORTAC_GROUP1	0xFFF8	/*	...11111000	*/

#define	PORTAD_GROUP4	0xFFF9	/*	...11111001	*/
#define	PORTAD_GROUP3	0xFFFA	/*	...11111010	*/
#define	PORTAD_GROUP2	0xFFFC	/*	...11111100	*/
#define	PORTAD_GROUP1	0xFFFF	/*	...11111111	*/



#define	PORTBA_GROUP4	0xFFEF	/*	...11101111	*/
#define	PORTBA_GROUP3	0xFFDF	/*	...11011111	*/
#define	PORTBA_GROUP2	0xFFBF	/*	...10111111	*/
#define	PORTBA_GROUP1	0xFF7F	/*	...01111111	*/

#define	PORTBB_GROUP4	0xFF0F	/*	...00001111	*/
#define	PORTBB_GROUP3	0xFF1F	/*	...00011111	*/
#define	PORTBB_GROUP2	0xFF2F	/*	...00101111	*/
#define	PORTBB_GROUP1	0xFF3F	/*	...00111111	*/

#define	PORTBC_GROUP4	0xFF4F	/*	...01001111	*/
#define	PORTBC_GROUP3	0xFF5F	/*	...01011111	*/
#define	PORTBC_GROUP2	0xFF6F	/*	...01101111	*/
#define	PORTBC_GROUP1	0xFF8F	/*	...10001111	*/

#define	PORTBD_GROUP4	0xFF9F	/*	...10011111	*/
#define	PORTBD_GROUP3	0xFFAF	/*	...10101111	*/
#define	PORTBD_GROUP2	0xFFCF	/*	...11001111	*/
#define	PORTBD_GROUP1	0xFFFF	/*	...11111111	*/
