/************************************************************************/
/*																		*/
/*																		*/
/*		>>>>>>>>>>>  TOS - Magazin   Ausgabe 4/93  <<<<<<<<<<<<<		*/
/*																		*/
/*																		*/
/*		P R O J E C T	:	Beispiele fr Codieralgorithmen				*/
/*							CODING.TTP									*/
/*																		*/
/*		M O D U L E		:	CODING.C									*/
/*																		*/
/*																		*/
/*		Author			:	Jrgen Lietzow fr TOS-Magazin				*/
/*																		*/
/*		System/Compiler	:	Atari ST/TT, TOS 4.01, Pure C				*/
/*																		*/
/*		Last Update		:	26.02.93 (JL)								*/
/*																		*/
/*																		*/
/************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <errno.h>

#include "cod_lib.h"
#include "messages.h"

#define	MAGIC		'_COD'

#define EINTERNAL	4099

typedef struct
{
		long	magic;
		long	first;
		long	len;
#ifdef BIG_ENDIAN
		int		time;
		int		date;
#else
		int		date;
		int		time;
#endif
#ifdef BIG_ENDIAN
		int		attrib;
		int		head_len;
#else
		int		head_len;
		int		attrib;
#endif
#ifdef BIG_ENDIAN
		int		crc;
		int		code_type;
#else
		int		code_type;
		int		crc;
#endif
		long	res0;
}	FHEAD;

/*	default options */

static	int		hold = 0;
static	int		auto_answer = 0;
static	int		delete = 0;
static	int		output = 1;
static	int		command;

static	char	dest_path[128];

static	void	message( char *fmt, ... )
{
	va_list		args;
	
	va_start( args, fmt );
	
	if ( output )
		vfprintf( stdout, fmt, args );

	va_end( args );
	
}

void	error( int num, ... )
{
	char	*ptr;
	va_list	args;
	int		flag = 0;
	
	va_start( args, num );
	
	switch ( num )
	{
		case EPERM:		ptr = MSG_EPERM;
						break;
		case ENOENT:	ptr = MSG_ENOENT;
						break;
		case ENFILE:
		case EMFILE:
		case EIO:		ptr = MSG_EIO;
						break;
		case EILLSPE:	ptr = MSG_EILLSPE;
						break;
		case ENOMEM:	ptr = MSG_ENOMEM;
						break;
		case EACCES:	ptr = MSG_EACCES;
						break;
		case EEXIST:	ptr = MSG_EEXIST;
						break;
		case ENOTDIR:	ptr = MSG_ENOTDIR;
						break;
		case ENOSPC:	ptr = MSG_ENOSPC;
						break;
		case ECRCSUM:	ptr = MSG_ECRCSUM;
						break;
		case ESPIPE:	ptr = MSG_ESPIPE;
						break;
		case LIMIT_ERR:
		case EROFS:		case EPLFMT:
		case ENODEV:	case EINVAL:	case EINVMEM:
		case EBADF:		case EDOM:		case ERANGE:
		case EINTERNAL:
						default:

						ptr = MSG_EINTERNAL;
						flag = 1;
						break;
	}
	if ( output )
		if ( flag )
			fprintf( stderr, ptr, num );
		else
		{
			if ( xfp_err )
				vfprintf( stderr, ptr, xfp_err->fname );
			else
				vfprintf( stderr, ptr, args );
		}
	if ( hold )
	{
		message( MSG_PRESS );
		getch();
	}
	exit( num );
}
	
static	int		ask( char *fmt, ... )
{
	va_list		args;
	int			answ;
	
	if ( auto_answer )
		return ( AN_YES );
		
	va_start( args, fmt );
	
	if ( output )
		vfprintf( stdout, fmt, args );

	va_end( args );
	
	answ = tolower( getch() );
	if ( answ == AN_ALL )
	{
		auto_answer = 1;
		answ = AN_YES;
	}
	return ( answ );
}


static	void	usage( void )
{
	fprintf( stdout, MSG_ENTRY );
	fprintf( stdout, MSG_USAGE );
	getch();
	exit( 0 );
}

static	int GetOptions( int argc, char *argv[] )
{
	char	*p;
	int		i = 1;
	int		c;
	
	if ( argc < 2 )
		usage();
	
	p = argv[i++];
	
	if ( *p == '-' )
		p++;
	switch ( c = toupper( *p++ ) )
	{
		case 'F' :	
		case 'L' :
		case 'N' :
		case 'E' :	command = c;	break;
		default:	usage(); break;
	}
	while ( 1 )
	{
		while ( ( c = toupper( *p++ ) ) != '\0' )
		{
			switch ( c )
			{
				case 'H':	hold = 1;			break;
				case 'Y':	auto_answer = 1;	break;
				case 'D':	delete = 1;			break;
				case 'S':	output = 0;			break;
				default:		usage();			break;
			}
		}
		if ( argv[i][0] != '-' || i >= argc )
			break;
		p = argv[i++];
	}
	if ( i >= argc )
		usage();
	
	return ( i );
}

static	void	mes8K( long cnt )
{
	message( MSG_NXTKB, cnt >> 10 );
}

	
static	jmp_buf	errbuf;

static	int	extract( FLIST *fl )
{
	int			i;
	XFILE		*sxfp, *dxfp;
	SD			*sd;
	int			ret;
	FHEAD		hd;
	crc_type	crc;
	char		temp[128];
	
	if ( ( ret = setjmp( errbuf ) ) != 0 )
	{	
		if ( xfp_err )
			error( ret, xfp_err->fname );
		else
			error( ret );
	}
		

	for ( i = 0; i < fl->n_files; i++ )
	{
		sd = &(fl->sd[i]);
		sxfp = XOpen( sd->src, XF_READ, errbuf, NOMES );
		XRead( &hd, sizeof (FHEAD), sxfp );
		ConvLong( &hd, sizeof (FHEAD) / sizeof (long));
		if ( hd.magic != MAGIC )
		{
			message( MSG_NOCODE, sxfp->fname );
			XClose( sxfp );
			continue;
		}
		XSeek( sxfp, hd.head_len, SEEK_SET );
		if ( TempFileName( sd->dest, temp ) )
		{
			XClose( sxfp );
			message( MSG_EEXIST, "TEMP_FILE" );
			ret = ask( ASK_CONTINUE );
			if ( ret == AN_NO )
				exit( 1 );
			continue;
		}
		dxfp = XOpen( temp, XF_WRITE|XF_CRCSUM|XF_TEMP , errbuf, mes8K );
		XStartCRC( dxfp );
		switch ( hd.code_type )
		{
			case 'F' :	message( MSG_EXTRACT, hd.code_type, sd->src );
						RLHuffDecode( sxfp, dxfp, hd.len );
						break;
			case 'L' :	message( MSG_EXTRACT, hd.code_type, sd->src );
						LZHDecodeInit( sxfp, dxfp );
						LZHDecode( hd.len );
						LZHExit();
						break;
			case 'N' :	message( MSG_EXTRACT, hd.code_type, sd->src );
						XCopy( sxfp, dxfp, hd.len );
						break;
			default:	message( MSG_ILLMODE, hd.code_type, sxfp->fname );
						XClose( sxfp );
						XClose( dxfp );
						remove( temp );
						continue;
		}
		mes8K( hd.len + 1023L );
		crc = XEndCRC( dxfp );
		XClose( dxfp );
		XClose( sxfp );
		if ( crc != hd.crc )
		{
			message( MSG_ECRCSUM, sd->dest );
			ret = ask( ASK_GENERATE );
			if ( ret == AN_QUIT )
			{
				remove( temp );
				exit ( 1 );
			}
			if ( ret == AN_NO )
			{
				remove( temp );
				continue;
			}
		}
		if ( delete )
		{
			if ( sd->attrib & FA_RDONLY )
			{
				message( MSG_PROTECT, sd->src );
				ret = ask( ASK_DELETE );
				if ( ret == AN_QUIT )
					exit( 1 );
				if ( ret == AN_SKIP )
				{
					remove( temp );
					continue;
				}
				_chmode( sd->src, 1, sd->attrib ^ FA_RDONLY );
			}
da:			if ( remove( sd->src ) )
			{
				remove( temp );
				message( MSG_EPERM, sd->src );
				ret = ask( ASK_CONTINUE );
				if ( ret == AN_NO )
					exit ( 1 );
				continue;
			}
		}
		if ( rename( temp, sd->dest ) )
		{
			message( MSG_EREN, sd->dest );
			if ( !delete && FileExists( sd->dest ) )
			{
				ret = ask( ASK_DELETE );
				if ( ret == AN_QUIT )
					exit( 1 );
				if ( ret == AN_SKIP )
				{
					remove( temp );
					continue;
				}
				goto da;
			}
			remove( temp );
			ret = ask( ASK_CONTINUE );
			if ( ret == AN_NO )
				exit( 1 );
			continue;
		}
		_chmode( sd->dest, 1, sd->attrib );
		message( MSG_FINISH );
	}
	return ( 0 );
}

static	compress( FLIST *fl )
{
	int			i;
	XFILE		*sxfp, *dxfp;
	SD			*sd;
	int			ret;
	FHEAD		hd;
	crc_type	crc;
	char		temp[128];
	
	if ( ( ret = setjmp( errbuf ) ) != 0 )
	{
		if ( xfp_err )
			error( ret, xfp_err->fname );
		else
			error( ret );
	}

	for ( i = 0; i < fl->n_files; i++ )
	{
		sd = &(fl->sd[i]);
		sxfp = XOpen( sd->src, XF_READ | XF_CRCSUM, errbuf, mes8K );
		XRead( &hd, sizeof (FHEAD), sxfp );
		ConvLong( &hd, sizeof (FHEAD) / sizeof (long));
		if ( hd.magic == MAGIC )
		{
			message( MSG_ALREADY, sxfp->fname );
			XClose( sxfp );
			continue;
		}
		XSeek( sxfp, 0, SEEK_SET );
		XStartCRC( sxfp );
		if ( TempFileName( sd->dest, temp ) )
		{
			XClose( sxfp );
			message( MSG_EEXIST, "TEMP_FILE" );
			ret = ask( ASK_CONTINUE );
			if ( ret == AN_NO )
				exit( 1 );
			continue;
		}
		dxfp = XOpen( temp, XF_WRITE|XF_TEMP, errbuf, NOMES );
		hd.first = hd.magic;
		hd.magic = MAGIC;
		hd.len = sd->len;
		hd.time = sd->ftime;
		hd.date = sd->fdate;
		hd.attrib = sd->attrib;
		hd.head_len = (int) sizeof (FHEAD);
		hd.code_type = command;
		hd.res0 = 0L;
		ConvLong( &hd, sizeof (FHEAD) / sizeof (long));
		XWrite( &hd, sizeof (FHEAD), dxfp );
		ConvLong( &hd, sizeof (FHEAD) / sizeof (long));
		switch ( hd.code_type )
		{
			case 'F' :	message( MSG_COMPRESS, hd.code_type, sd->dest );
						RLHuffEncode( sxfp, dxfp, hd.len );
						break;
			case 'L' :	message( MSG_COMPRESS, hd.code_type, sd->dest );
						LZHEncodeInit( sxfp, dxfp );
						LZHEncode( hd.len );
						LZHExit();
						break;
			case 'N' :	message( MSG_COMPRESS, hd.code_type, sd->dest );
						XCopy( sxfp, dxfp, hd.len );
						break;
			default:	error( EINTERNAL, 1 );
						continue;
		}
		mes8K( hd.len + 1023L );
		crc = XEndCRC( sxfp );
		XSeek( dxfp, 0, SEEK_SET );
		hd.crc = crc;
		ConvLong( &hd, sizeof (FHEAD) / sizeof (long));
		XWrite( &hd, sizeof (FHEAD), dxfp );
		ConvLong( &hd, sizeof (FHEAD) / sizeof (long));
		XClose( dxfp );
		XClose( sxfp );
		if ( ( ret = open( sd->dest, O_RDWR ) ) >= 0 )
		{
			setftime( ret, (struct ftime *) &(sd->ftime) );
			close( ret );
		}
		else
		{
		}
		if ( delete )
		{
			if ( sd->attrib & FA_RDONLY )
			{
				message( MSG_PROTECT, sd->src );
				ret = ask( ASK_DELETE );
				if ( ret == AN_QUIT )
					exit( 1 );
				if ( ret == AN_SKIP )
				{
					remove( temp );
					continue;
				}
				_chmode( sd->src, 1, sd->attrib ^ FA_RDONLY );
			}
da:			if ( remove( sd->src ) )
			{
				remove( temp );
				message( MSG_EPERM, sd->src );
				ret = ask( ASK_CONTINUE );
				if ( ret == AN_NO )
					exit ( 1 );
				continue;
			}
		}
		if ( rename( temp, sd->dest ) )
		{
			message( MSG_EREN, sd->dest );
			if ( !delete && FileExists( sd->dest ) )
			{
				ret = ask( ASK_DELETE );
				if ( ret == AN_QUIT )
					exit( 1 );
				if ( ret == AN_SKIP )
				{
					remove( temp );
					continue;
				}
				goto da;
			}
			remove( temp );
			ret = ask( ASK_CONTINUE );
			if ( ret == AN_NO )
				exit( 1 );
			continue;
		}
		_chmode( sd->dest, 1, sd->attrib );
		message( MSG_FINISH );
	}
	return ( 0 );
}

int		main( int argc, char *argv[] )
{
	int		i;
	FLIST	*fl;
	
	i = GetOptions( argc, argv );
	
	if ( output )
		fprintf( stdout, MSG_ENTRY );
	
	if ( i == argc - 1 )
		strcpy( dest_path, ".\\" );
	else
	{
		if ( IsFName( argv[argc-1] ) )
			if ( !FileExists( argv[argc-1] ) )
				strcpy( dest_path, argv[--argc] );
			else
				strcpy( dest_path, ".\\" );
		else
			strcpy( dest_path, argv[--argc] );
	}

	while ( i < argc )
	{
		fl = FileList( argv[i++], dest_path, 0 );
		if ( !fl )
			error( ENOMEM );
		switch ( command )
		{
			case 'E' :	extract( fl );
						break;
			case 'F' :
			case 'L' :
			case 'N' :	compress( fl );
						break;
			default:	error( EINTERNAL );
						break;
		}
		free ( fl );
	}
	if ( hold )
	{
		message( MSG_PRESS );
		getch();
	}
	return ( 0 );
}
	
	