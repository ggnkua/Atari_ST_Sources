/********************************************************************/
/*																	*/
/* 	ScreenEye Interface : image / window definitions				*/
/*																	*/
/*	digiblit.h / 15.4.94											*/
/*																	*/
/*  (c) 1994 Matrix Daten Systeme GmbH								*/
/*		Talstr. 16, D-71570 Oppenweiler								*/
/*																	*/
/********************************************************************/

# define DIGdx9051		720				/*...... PAL / SECAM / NTSC ...*/

# define DIGdx7191		768				/*...... PAL / SECAM ..........*/
# define DIGdyS			576				/* full Screen	*/
# define DIGdyF			(DIGdyS/2)		/* single frame	*/

# define DIGdx7191ntsc	640				/*...... NTSC .................*/
# define DIGdySntsc		480				/* full Screen	*/
# define DIGdyFntsc		(DIGdySntsc/2)	/* single frame	*/

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

typedef unsigned TComponentWidths ;

	/* 		values			meaning						*/
	/*--------------------------------------------------*/
	/*	1, 2, 4, 7, 8		used palette entries		*/
	/*	16					planes ( -> 555 rgb )		*/
	/*	48, 88				yc values					*/
	/*  332, 555, 565, 888	rgb, yc ( = yuv ) values	*/

typedef enum { PIOdefault, PIOpacked, PIOplanes, PIOmix16 } TFormatOrder ;
typedef enum { PITdefault, PITcolor,  PITgrey, 	 PITyc 	  } TFormatType ;

typedef unsigned TPictureFormat ;

/*	15,14,13,12,11,10,09,08,07,06,05,04,03,02,01,00		*/
/* |  type  | order	 |		   widths			   |	*/
/* |  0..7  | 0..7	 |		   0..1023			   |	*/

# define _PictureFormat(type,order,width)	((unsigned)(((type)<<13)|((order)<<10)|(width)))
# define _FormatType(format)				((TFormatType)(((unsigned)format)>>13))
# define _FormatOrder(format)				((TFormatOrder)((((unsigned)format)>>10)&7))
# define _ComponentWidths(format)			((unsigned)((format)&1023))

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
