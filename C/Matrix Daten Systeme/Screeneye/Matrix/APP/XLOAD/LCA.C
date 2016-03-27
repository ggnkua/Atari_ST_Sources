/* lca.cpp / MATRIX / WA / 1.4.93 */

# include <stdio.h>
# include <string.h>

# include <global.h>

# include "d:\pc\app\xload\global.h"

# include "d:\pc\app\xload\lca.h"
# include "d:\pc\app\xload\lca_dev.h"
# include "d:\pc\app\xload\lcaload.h"

# define MAXlineSize 1024

# define DUMMYpattern	0xffff

# define INHIBIToutput	0

/*----------------------------------------- Error ------------------*/
void Error ( char *format, ... )
{
	fprintf  ( stderr, "* error : " ) ;
	vfprintf ( stderr, format, ... ) ;
	fprintf ( stderr, "\n" ) ;
#if 0
	PressReturn();
	exit ( 1 ) ;
# endif
}

/*----------------------------------------- LineError ------------------*/
int LineError ( int line, char *format, ... )
{
	fprintf  ( stderr, "* error in line %d : ", line ) ;
	vfprintf ( stderr, format, ... ) ;
	fprintf ( stderr, "\n" ) ;
	
	return LCAfileLoadError ;
#if 0
	PressReturn();
	exit ( 1 ) ;
# endif
}


LCAdevice LcaTable[] =
{
/*		number,	gates, clbs,  iobs, ffs, bits, frames	*/
	{   3020,	2000,	 64,    64,	256,   75,	197 },
	{	3030,	3000,	100,	80,	360,   92,	241	},
	{	3042,	4200,	144,	96,	480,  108,	285	},
	{	3064,	6400,	224,   120, 688,  140,	329	},
	{	3090,	9000,	320,   144, 928,  172,	373 },
	{      0 }
} ;

/*.................... LCAdevice ...........................................*/

long ProgDataSize ( PLCAdevice lca )		{ return (long)lca->bits * (long)lca->frames + 4 ; } ;
long PromSize ( PLCAdevice lca )			{ return ProgDataSize(lca) + 40 ;	  } ;
BYTE *MallocDataBuffer ( PLCAdevice lca ) 	{ return (BYTE *)malloc ( (unsigned)( ( PromSize(lca) + 7L ) / 8L ) ) ; } ;

/*------------------------------------------- LCAdevice::Print ------------*/
void Print ( PLCAdevice lca )
{
	printf ( "n=%d, gates=%d, clbs=%d, iobs=%d ffs=%d, bits=%d, frames=%d\n",
				lca->number,	lca->gates, lca->clbs, lca->iobs, lca->ffs, lca->bits, lca->frames ) ;
	printf ( "ProgDataSize=%ld, PromSize=%ld\n",
				ProgDataSize(lca), PromSize(lca) ) ;
}


/*------------------- GetLcaFromNumber ------------------*/
LCAdevice *GetLcaFromNumber ( int number )
{
	LCAdevice *lca ;
	for ( lca = LcaTable ; lca->number > 0 ; lca++ )
		if ( lca->number == number )
			return lca ;
	return NULL ;
}

/*.................... LCAchip ...........................................*/

/*------------------------------------------- LCAchipFree ------------*/
void Free ( PLCAchip lcac )
{
	if ( lcac->Buffer != NULL ) free ( lcac->Buffer ) ;
	lcac->Buffer = NULL ;
}


/*------------------------------------------- LCAchipPrint ------------*/
void LCAchipPrint ( PLCAchip lcac )
{
	int n ;
	BYTE *pb ;

	printf ( "device : " ) ;
	if ( lcac->Lca != NULL )
		Print ( lcac->Lca ) ;
	else
		printf ( "<NULL>\n" ) ;
	if ( lcac->Buffer != NULL )
	{
		printf ( "Buffer = $%p, Current = $%p, BitCount = %ld",
					lcac->Buffer, lcac->Current, lcac->BitCount ) ;
/*
	printf ( "data = " ) ;
*/
		for ( pb = lcac->Buffer, n = 0 ; n < 75 ; n++ )
		{
			if ( pb >= lcac->Current )
			break ;
			if ( ( n & 15 ) == 0 )
				printf ( "\n%5d :", n ) ;
			printf ( " %02x", *pb++ ) ;
		}
		printf ( "\n" ) ;
	}
	else
		printf ( "buffer empty !\n" ) ;
}


/*------------------------------------------- LCAchipStore ------------*/
void LCAchipStore ( PLCAchip lcac, char *codfilnam, char *info )
{
	long n ;
	unsigned bytes, bi ;
	BYTE *pb ;
	FILE *cofi ;
	unsigned char c ;

	if ( ( cofi = fopen ( codfilnam, "w" ) ) != NULL )
	{
		if ( lcac->Lca != NULL )
		{
			bytes = (unsigned) ( ( lcac->BitCount + 7L ) / 8L ) ;
			fprintf ( cofi, "# define BYTESinMAP	%u\n"
							"\n"
							"/* info : %s */\n"
							"\n"
							"# include \"lcaload.h\"\n"
							"\n"
							"LCAdata lca_data =\n"
							"{\n"
							"	%u,\n"
							"	BYTESinMAP,\n"
							"	{\n"
							"		",
							bytes,
							info != NULL ? info : "<NULL>",
							lcac->Lca->number ) ;
			if ( lcac->Buffer != NULL )
			{
				for ( pb = lcac->Buffer, n = 0, bi = bytes ; ; )
				{
					c = *pb++ ;
					fprintf ( cofi, " 0x%02x", c ) ;
					n++ ;
					bi-- ;
					if ( bi > 0 )
					{
						if ( ( n & 0xf ) == 0 )
							fprintf ( cofi, ",\n		" ) ;
						else
							fprintf ( cofi, "," ) ;
					}
					else
						break ;
				}
				fprintf ( cofi, "\n	}\n"
								"} ;"  ) ;
			}
		}
		else
			printf ( "* LCA undefined\n" ) ;
		fclose ( cofi ) ;
	}
	else
		printf ( "* Can't create %s\n", codfilnam ) ;
}


/*----------------------------------- PrintStatus ------------*/
void PrintStatus ( unsigned port )
{
	printf ( "signal             (init)\n" ) ;
	printf ( "-------------------------\n" ) ;
	printf ( "done/-program : %c  (1)\n", GetLCAdnp ( port )	? '1' : '0' ) ;
	printf ( "-reset        : %c  (1)\n", GetLCAnreset ( port ) ? '1' : '0' ) ;
	printf ( "-init         : %c  (1)\n", GetLCAninit ( port )  ? '1' : '0' ) ;
	printf ( "ready/-busy   : %c  (1)\n", GetLCAready ( port )  ? '1' : '0' ) ;
}


/*----------------------------------- LoadChip ------------*/
int LoadChip ( PLCAchip lcac, unsigned lcaport )
{
	int result ;
	result = LoadLCA ( lcac->Lca->number, lcaport, lcac->Buffer,
					 (unsigned) ( ( lcac->BitCount + 7L ) / 8L ) ) ;
	switch ( result )
	{
case LCAbusyTimeOut	:		Error ( "LCA busy time out" ) ;					break ;
case LCAsignalsDone :		Error ( "LCA signals done before load end" ) ;	break ;
case LCAnoDoneSignal :		Error ( "no done signal from LCA !" ) ;			break ;
case LCAearlyDoneSignal	: 	Error ( "LCA signals done before loading" ) ;	break ;
case LCAbufferEmpty : 		Error ( "chip data buffer empty" ) ;			break ;
	}
    return result ;
}

/*--------------------------------- AddDataLine -----------------*/
void AddDataLine ( PLCAchip lcac, char *line )
{
	char *s ;

	for ( s = line ; *s == '0' || *s == '1' ; )
	{
		if ( ( ( lcac->BitCount++ ) & 7 ) == 0 )
		{
			lcac->Current++ ;	/* to next byte	*/
			*lcac->Current = DUMMYpattern ;
		}
		if ( *s++ & 1 )
			*lcac->Current = ( *lcac->Current >> 1 ) | 0x80 ;	/* 1	*/
		else
			*lcac->Current = ( *lcac->Current >> 1 ) & 0x7f ;	/* 0	*/
	}
}

/*----------------------------------------- LoadFromFile -----------------*/
int LoadFromFile ( PLCAchip lcac, char *rbtfile )
{
	char Line[MAXlineSize+1] ;
	char *extension ;
	int  number = 0 ;
/*	int  dataline ;
*/
	FILE *InFile = NULL ;
	int  LineNumber ;
	int  result = LOADok ;
	
	lcac->Lca    = NULL ;
	lcac->Buffer = NULL ;
	InFile = fopen ( rbtfile, "r" ) ;
	if ( InFile != NULL )
	{
/*		dataline = 0 ;
*/
		for ( LineNumber = 0 ; result == LOADok && fgets ( Line, MAXlineSize, InFile ) ; )
		{
			LineNumber++ ;

/*			int linlen = strlen ( Line ) ;
			printf ( "%d (%3d) : %s", LineNumber, linlen, Line ) ;
*/
			switch ( Line[0] )
			{
	case 'X' :	/* Xilinx LCA CDLCAR.LCA 3030PC84	*/
				extension = strstr ( Line, ".LCA" ) ;
				if ( extension != NULL )
				{
					number = atoi ( extension + 5 ) ;
					lcac->Lca = GetLcaFromNumber ( number ) ;
					if ( lcac->Lca != NULL )
					{
						if ( verbose )
							printf ( "device : %d\n", lcac->Lca->number ) ;
						lcac->Buffer = MallocDataBuffer ( lcac->Lca ) ;
						if ( lcac->Buffer != NULL )
						{
							lcac->BitCount = 0 ;
							lcac->Current = lcac->Buffer - 1 ;
						}
						else
							result = LineError ( LineNumber, "no memory for buffer" ) ;
					}
					else
						result = LineError ( LineNumber, "device number %d not in lca table", number ) ;
				}
				else
					result = LineError ( LineNumber, "device code not found" ) ;
				break ;
	case '0' :
	case '1' :	if ( lcac->Buffer == NULL )
				{
					result = LineError ( LineNumber, "no device specified" ) ;
					break ;
				}
				AddDataLine ( lcac, Line ) ;
# if 0
				switch ( dataline++ )
				{
		case   0 /* 10 */ :			printf ( "start record  : %d digits found\n", linlen-1 ) ;
									break ;
		case 242 /* 252 */	:		printf ( "end record    : %d digits found\n", linlen-1 ) ;
									break ;
		case   1 /* 11 ??? */ :		printf ( "data record 1 : %d digits found\n", linlen-1 ) ;
									break ;
		default /* 11 .. 251 */ :	break ;
				}
# endif
				break ;
	default :	/* header, comments etc.	*/
				if ( verbose && strlen ( Line ) > 2 )	
					printf ( "%d : %s", LineNumber, Line ) ;
			}
    	}
		fclose ( InFile ) ;
		if ( verbose )
			printf ( "file '%s' loaded : %d lines, %ld bits\n",
							 rbtfile, LineNumber, lcac->BitCount ) ;
	}
	else
		result = LineError ( LineNumber, "can't open input file '%s'", rbtfile ) ;

	return result ;
}


/*------------------------------------------------------ ProgramLcaFromFile -----*/
int ProgramLcaFromFile  ( char *filename, unsigned lcaport )
{
	LCAchip lca ;
	int     result ;
	
	if ( ( result = LoadFromFile ( &lca, filename ) ) == LOADok )
	{
		LoadChip ( &lca, lcaport );
		Free ( &lca ) ;
	}
	return result ;
}

