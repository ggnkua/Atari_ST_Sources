/* 	digiblit.h	/	20.10.93 / WA			*/
/*	(c) 1993 Matrix daten Systeme GmbH 		*/
/*  tabs at 4 */

# define DIGdx7191	768
# define DIGdx9051	720
# define DIGdyS		576			/* full Screen	*/
# define DIGdyF		(DIGdyS/2)	/* single frame	*/

# define BYT_PER_NTC_PIX	2

/*
	TImage ( s. a. MFDB )
	data ->		+---------- w ----------+
				|						|
				w						|
				|						|
				+-----------------------+

	TImageWindow = TImage + TRectangle

	i.data ->	+------------ i.W ----------+
				|	   r.x					|
				|		|					|
				|	r.y-+--- r.w ---+		|
			   i.H		|			|		|
				|	   r.h			|		|
				|		|			|		|
				|		+-----------+		|
				+---------------------------+
*/


typedef struct
{
	void 	*data ;
	int 	w, h ;
    int  	planes ;
 
    int		bpl ;
} TImage ;

# define _SizeOf(img)	((long)((img)->h) * (long)((img)->bpl))

typedef struct
{
	TImage		image ;
	TRectangle	window ;
} TImageWindow ;

typedef struct
{
	TImageWindow src ;
	TImageWindow dst ;
} TBlitWindow ;

typedef enum { FIELDnext, FIELDodd, FIELDeven } TFieldType ;
