/********************************************************************/
/* 				MatDigi Window Program - Minimal TIFF Files			*/
/*																	*/
/*------------------------------------------------------------------*/
/*	Status : 14.04.93												*/
/*																	*/
/*  HG - Matrix Daten Systeme, Talstr. 16, W-7155 Oppenweiler		*/
/*																	*/
/********************************************************************/


typedef struct
{
	uword		order ;
	uword		version ;
	ulong		pic_offset ;
} TIFFhead ;


typedef union
{
	byte		ub ;
	uword 		uw ;
	ulong		ul ;
} VAL_OR_ADR ;


typedef enum
{
	COM_BYTE = 1,
	COM_ASCIIZ,
	COM_SHORT,
	COM_LONG,
	COM_REAL,
	COM_RATIONAL
} COM_TYPE ;


typedef struct
{
	uword		command ;
	COM_TYPE	com_type ;
	ulong		length ;
	VAL_OR_ADR	val_or_adr ;
} TIFFcom ;


typedef struct
{
	uword	red_bps ;
	uword	green_bps ;
	uword	blue_bps ;
} BPS_TABLE ;

typedef char SOFTWARE_STRING[16] ;
typedef char MAKE_STRING[32] ;

# define MAX_COM 16
typedef struct
{
	uword			entries ;
	TIFFcom			tiff_com [MAX_COM] ;
	SOFTWARE_STRING	software ;
	MAKE_STRING		make ;
	BPS_TABLE		bps_table ;	
} TIFFdir ;


typedef struct
{
	TIFFhead	*head ;
	TIFFdir		*dir ;
	void		*data ;
} TIFFpic ;


extern int		write_tiff_picture ( char *name, TIFFpic *tiff, int w, int h ) ;
extern void		free_tiff_pic ( TIFFpic *tiff ) ;
extern TIFFpic	*init_tiff ( void *buf, int w, int h, int * result ) ;

 
								  
								  

