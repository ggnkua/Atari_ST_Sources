/********************************************************************/
/*																	*/
/* 	ScreenEye Interface : decoder definitions						*/
/*																	*/
/*	digitise.h / 15.4.94											*/
/*																	*/
/*  (c) 1994 Matrix Daten Systeme GmbH								*/
/*		Talstr. 16, D-71570 Oppenweiler								*/
/*																	*/
/********************************************************************/

# define NOdmsd		    0
# define DEFdmsdType 9051

# if DEFdmsdType == 9051
# define ALTdmsdType 7191
# else
# define ALTdmsdType 9051
# endif

# define PUP_AUTO 0
# define PUP_PAL 1
# define PUP_NTSC 2
# define PUP_SECAM 3
# define PUP_RS170 4
# define PUP_VTR 0
# define PUP_TV 1
# define PUP_SVHS 1
# define PUP_FBAS 2
# define PUP_CVBS PUP_FBAS
# define PUP_BAS 3

typedef struct
{
	int	dmsd ;
	int signal ;
	int source ;
	int standard ;
} TDmsdParameter ;

