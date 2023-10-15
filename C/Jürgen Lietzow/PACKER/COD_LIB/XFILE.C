/************************************************************************/
/*																		*/
/*																		*/
/*		>>>>>>>>>>>  TOS - Magazin   Ausgabe 4/93  <<<<<<<<<<<<<		*/
/*																		*/
/*																		*/
/*		P R O J E C T	:	Beispiele fr Codieralgorithmen				*/
/*							CODING.TTP									*/
/*																		*/
/*		M O D U L E		:	XFILE.C										*/
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
#include <string.h>
#include <ctype.h>
#include <errno.h>
#include <stdlib.h>

#define __XFILE
#include "..\cod_lib.h"

		XFILE	*xfp_err;
		
static	XFILE	*xfile[MAX_XFILE] = { NULL };
static	char	*tpf[MAX_XFILE] = { NULL };

#ifdef remove
#undef remove
#endif



/*
*	FixPath
*
*	fixes path, that only another dir or file name has to be added
*	with no further file seperator
*	'a:'      -> 'a:'
*	''        -> ''
*	'xxx'     -> 'xxx\'
*	'AUX:'    -> 'AUX:'
*	returns 0 if path is 'AUX:' or 'CON:', ...
*/

int	FixPath( char *path )
{
	char	*p;
	
	p = strrchr( path, F_SEP );
	if ( !p )
	{
		if ( path[0] == EOS )
			return ( -1 );
		p = path + strlen( path );
		if ( p[-1] == ':' )
		{
			if ( path[1] == ':' )
				return ( -1 );
			else
				return ( 0 );
		}
		*p++ = F_SEP;
		*p++ = EOS;
	}
	else
	{
		if ( p[1] != EOS )
		{
			while ( *p++ );
			p[-1] = F_SEP;
			p[0] = EOS;
		}
	}
	return ( -1 );
}


/*
*	AppendPath()
*
*	appends <dir> to <path>. <type> == 0 signals <dir> is a file name, else
*	a directory.
*/

void	AppendPath( char *path, char *dir, int type )
{
	if ( *dir == F_SEP )
		dir++;
	
	if ( !FixPath( path ) )
		return;
	strcat( path, dir );	
	
	if ( !type )
		FixPath( path );
}

/*
*	PathExists()
*
*	returns 0 if <path> does not exist
*/

int		PathExists( const char *path )
{
	struct ffblk	fb;
	char			p[128];
	
	strcpy( p, path );
	AppendPath( p, F_SPEC, 1 );
	
	if ( !findfirst( p, &fb, FA_ATTRIB ) )
		return ( -1 );
	else
		return ( 0 );
}

/*
*	FileExists()
*
*	returns 0 if <fname> does not exist
*	'CON:', 'AUX:', ... always exist
*/

int		FileExists( const char *fname )
{
	struct ffblk	fb;
	char			*p;
	
	p = strrchr( fname, F_SEP );
	if ( p )
	{
		if ( p[1] == EOS )
			return ( 0 );
	}
	else
	{
		p = strrchr( fname, ':' );
		if ( p && p[1] == EOS )
		{
			if ( p == fname + 1 )
				return ( 0 );
			else
				return ( 1 );
		}
	}
	return ( !findfirst( fname, &fb, FA_ATTRIB ^ FA_DIREC ) );
}

/*
*	Is this a file name?
*/

int		IsFName( char *fname )
{
	char	*p;

	p = fname + strlen( fname );
	
	if ( p[-1] == F_SEP || ( p[-1] == ':' && p == fname + 2 ) )
		return ( 0 );
	return ( 1 );
}

/*
*	Is this a path name
*/

int		IsPName( char *pname )
{
	char	*p;

	p = pname + strlen( pname );
	
	if ( p[-1] == F_SEP || ( p[-1] == ':' && p == pname + 2 ) )
		return ( 1 );
	return ( 0 );
}
	

/*
*	Give a not existing file name within the path of <file>
*/

int	TempFileName( char *file, char *new )
{
	char			*p;
	int				i = 0;
	struct ffblk	fb;
	
	strcpy( new, file );
	if ( ( p = strrchr( new, F_SEP ) ) == NULL )
	{
		if ( new[1] == ':' )
			p = new + 2;
		else
			p = new;
	}
	else
		p++;
	
	do
	{
		sprintf( p, "TPF%03d.$$$", i );
		if ( findfirst( new, &fb, FA_HIDDEN | FA_RDONLY | FA_SYSTEM ) )
			return ( 0 );
	} while ( ++i < 999 );
	return ( EEXIST );
}

static	char	src[128], dest[128], spec[18];

static	FLIST	*ScanFiles( FLIST *fl, int *max, int mode )
{
	struct ffblk 	fb;
	char			*d, *s;
	int				d_type;
	FLIST			*flt;
	int				i;

	d_type = FixPath( dest );
	s = src + strlen( src );
	d = dest + strlen( dest );
		
	strcpy( s, spec );

	if ( !findfirst( src, &fb, FA_ATTRIB ^ FA_DIREC ) )
	{
		do
		{
			if ( d_type )
				strcpy( d, fb.ff_name );
			strcpy( s, fb.ff_name );
			if ( fl->n_files >= *max )
			{
				*max += 16;
				flt = realloc( fl, sizeof (FLIST) + *max * sizeof (SD) );
				if ( flt == NULL )
				{
					free( fl );
					return ( flt );
				}
				fl = flt;
			}
			i = fl->n_files++;
			strcpy( fl->sd[i].dest, dest );
			strcpy( fl->sd[i].src, src );
			fl->sd[i].attrib = fb.ff_attrib;
			fl->sd[i].ftime = fb.ff_ftime;
			fl->sd[i].fdate = fb.ff_fdate;
			fl->sd[i].len = fb.ff_fsize;
			fl->flen += fb.ff_fsize;
		} while ( !findnext( &fb ) );
	}
	if ( mode )
	{
		strcpy( s, F_SPEC );
		if ( !findfirst( src, &fb, FA_ATTRIB ) )
		{
			do
			{
				if ( !(fb.ff_attrib & FA_DIREC) )
					continue;
				if ( fb.ff_name[0] == '.' )
					continue;

				if ( d_type )
				{
					strcpy( d, fb.ff_name );
					strcat( d, "\\" );
				}
				strcpy( s, fb.ff_name );
				strcat( s, "\\" );
				fl->n_dirs++;
				if ( ( fl = ScanFiles( fl, max, mode ) ) == NULL )
					return ( NULL );
			} while ( !findnext( &fb ) );
		}
	}
	return ( fl );
}

/*
*	Generate a list of all files specified
*/

FLIST	*FileList( const char *src_spec, const char *dest_path, int mode )
{
	char			*p;
	FLIST			*fl;
	int				num = 16;
	struct ffblk	fb;
	
	strcpy( dest, dest_path );
	strcpy( src, src_spec );
	
	if ( ( fl = malloc( sizeof(FLIST) + num * sizeof (SD) ) ) == NULL )
		return ( fl );

	fl->n_files = 0;
	fl->n_dirs = 0;
	fl->flen = 0L;

	p = src + strlen( src );
	if ( p == src || p[-1] == F_SEP || ( p[-1] == ':' && p == src + 2 ) )
		strcpy( spec, F_SPEC );
	else
	{
		if ( !strpbrk( src, "*?[]" ) && !findfirst( src, &fb, FA_ATTRIB ^ FA_DIREC ) )
		{
			strcpy( fl->sd[0].src, src );
			p = dest + strlen( dest );
			if ( p == dest || p[-1] == F_SEP || ( p[-1] == ':' && p == dest + 2 ) )
			{
				FixPath( dest );
				strcat( dest, fb.ff_name );
			}
			strcpy( fl->sd[0].dest, dest );
			fl->n_files++;
			fl->sd[0].attrib = fb.ff_attrib;
			fl->sd[0].ftime = fb.ff_ftime;
			fl->sd[0].fdate = fb.ff_fdate;
			fl->sd[0].len = fb.ff_fsize;
			fl->flen += fb.ff_fsize;
			return ( fl );
		}
		if ( !FileExists( src ) )
		{
			*p++ = F_SEP;
			*p = EOS;
			strcpy( spec, F_SPEC );
		}
		else
		{
			while ( *--p != F_SEP && p >= src && *p != ':' );
			if ( p >= src )
			{
				if ( *p == F_SEP || *p == ':' )
					p++;
			}
			else
				p++;
			strcpy( spec, p );
			*p = EOS;
		}
	}
	return ( ScanFiles( fl, &num, mode ) );
}

/*
*	ANSI checksum
*/

static	crc_table	ct;

static	void InitCRCTable( void )
{
	static	int		first = 1;
		    uint	i, j, r;
	
	if ( !first )
		return;
		
	for ( i = 0; i <= UCHAR_MAX; i++ )
	{
		r = i;
		for ( j = 0; j < CHAR_BIT; j++ )
			if ( r & 1 )
				r = (r >> 1) ^ CRCPOLY;
			else
				r >>= 1;
		ct[i] = r;
	}
	first = 0;
}

/*
*	Generate checksum
*/

crc_type	CRCSum( char *buf, long len, crc_type last )
{
	long	l;
	
	for ( l = (len >> 3); --l >= 0; )
	{
		UPDATE_CRC(last,*buf++);
		UPDATE_CRC(last,*buf++);
		UPDATE_CRC(last,*buf++);
		UPDATE_CRC(last,*buf++);
		UPDATE_CRC(last,*buf++);
		UPDATE_CRC(last,*buf++);
		UPDATE_CRC(last,*buf++);
		UPDATE_CRC(last,*buf++);
	}
	for ( len &= 0x7; --len >= 0; )
		UPDATE_CRC(last,*buf++);

	return ( last );
}

/*
*	Flush the bit buffer
*/

void	XBitsFlush( XFILE *xfp )
{
	ulong	map;
	
	if ( xfp->mode & (XF_WRITE|XF_TEMP|XF_APPEND)  )
	{
		if ( xfp->num_bits < 32 )
		{
			if ( xfp->bb_pos >= XFP_BUFFER )
			{
				XWrite( xfp->bit_buf, xfp->bb_pos, xfp );
				xfp->bb_pos = xfp->bb_max = 0;
			}
			map = xfp->bitmap;
			map <<= xfp->num_bits;
			*(ulong*)(xfp->bit_buf + xfp->bb_pos) = map;
			xfp->bb_pos += (int) sizeof (long);
		}
		if ( xfp->bb_pos )
			XWrite( xfp->bit_buf, xfp->bb_pos, xfp );
		xfp->num_bits = 32;
	}
	else
	{
		xfp->num_bits = 0;
		fseek( xfp->fp, -(xfp->bb_max - xfp->bb_pos), SEEK_CUR );
	}
	xfp->bb_pos = xfp->bb_max = 0;
	xfp->bitmap = 0;
}

static	void	EndXFile( void )
{
	int		i;
	XFILE	*xfp;
	
	for ( i = 0; i < MAX_XFILE; i++ )
	{
		if ( ( xfp = xfile[i] ) == NULL )
			continue;
		XBitsFlush( xfp );
		fclose( xfp->fp );
		if ( xfp->mode & XF_TEMP )
			remove( xfp->fname );
		free( xfp );
		xfile[i] = NULL;
	}
	for ( i = 0; i < MAX_XFILE; i++ )
	{
		if ( tpf[i] )
		{
			remove( tpf[i] );
			tpf[i] = NULL;
		}
	}
}

/*
*	Open a file
*/

XFILE	*XOpen( char *fname, int mode, jmp_buf *error, void (*cntmes)(long) )
{
	static	int		first = 0;
			char	*fmode;
			int		i;
			XFILE	*xfp;
			char	*p;
	
	if ( first )
	{
		first = 0;
		atexit ( EndXFile );
	}
	
	for ( i = 0; i < MAX_XFILE; i++ )
		if ( xfile[i] == NULL )
			break;
	if ( i >= MAX_XFILE ||
		 ( xfile[i] = xfp = malloc( sizeof (XFILE) ) ) == NULL )
	{
		errno = ENOMEM;
		if ( xfp->jmpbuf )
		{	
			xfp_err = NULL;
			longjmp( xfp->jmpbuf, ENOMEM );
		}
		return ( NULL );
	}
	xfp->p_handle = i;
	xfp->limit = -1L;
	xfp->bb_pos = 0;
	xfp->bb_max = 0;
	xfp->mode = mode;
	xfp->jmpbuf = error;
	xfp->cntmes = cntmes;
	xfp->cnt = 0L;

	if ( mode & XF_READ )
	{
		fmode = "rb";
		xfp->num_bits = 0;	
	}
	else
	{
		if ( mode & XF_APPEND )
			fmode = "r+b";
		else
			fmode = "wb";
		xfp->num_bits = 32;	
	}
	strcpy( xfp->fname, fname );
	
	if ( ( xfp->fp = fopen( xfp->fname, fmode ) ) == NULL )
	{
		xfile[xfp->p_handle] = NULL;
		free( xfp );
		xfp_err = NULL;
		if ( xfp->jmpbuf )
			longjmp( xfp->jmpbuf, errno );
		return ( NULL );
	}
	if ( mode & XF_TEMP )
	{
		for ( i = 0; i < MAX_XFILE; i++ )
			if ( !tpf[i] )
				if ( ( p = malloc( strlen( fname ) + 1 ) ) != NULL )
				{
					tpf[i] = p;
					strcpy( p, fname );
				}
	}
	InitCRCTable();
	xfp->crc = INIT_CRC;
	return ( xfp );
}

/*
*	Close a file
*/

int		XClose( XFILE *xfp )
{
	int		ret;
	
	XBitsFlush( xfp );
	ret = fclose( xfp->fp );
	if ( ret == EOF && xfp->jmpbuf )
	{
		xfp_err = xfp;
		longjmp( xfp->jmpbuf, ret );
	}
	xfile[xfp->p_handle] = NULL;
	free( xfp );
	return ( ret );
}

/*
*	read from file
*/

size_t	XRead( void *buf, size_t len, XFILE *xfp )
{
	long	nl;
	
	if ( ( nl = xfp->limit ) >= 0L )
	{
		if ( ( len = Min( len, nl ) ) == 0L )
		{
			if ( xfp->jmpbuf )
			{
				xfp_err = xfp;
				longjmp( xfp->jmpbuf, LIMIT_ERR );
			}
			else
				return ( 0L );
		}
		nl = fread( buf, 1, len, xfp->fp );
		xfp->limit -= nl;
		if ( nl != len && xfp->jmpbuf )
		{
			xfp_err = xfp;
			longjmp( xfp->jmpbuf, errno ? errno : EIO );
		}
	}
	else
		nl = fread( buf, 1, len, xfp->fp );

	if ( (xfp->cnt & 0xffffe000L) != ((xfp->cnt += nl) & 0xffffe000L)
		 && xfp->cntmes )
		xfp->cntmes( xfp->cnt );
	
	if ( xfp->mode & XF_CRCSUM )	
		xfp->crc = CRCSum( buf, nl, xfp->crc );
	
	return ( nl );
}

/*
*	write to file
*/
	
size_t	XWrite( void *buf, size_t len, XFILE *xfp )
{
	long	nl;
	
	if ( ( nl = xfp->limit ) >= 0L )
	{
		if ( ( len = Min( len, nl ) ) == 0L )
		{
			if ( xfp->jmpbuf )
			{
				xfp_err = xfp;
				longjmp( xfp->jmpbuf, LIMIT_ERR );
			}
			else
				return ( 0L );
		}
		nl = fwrite( buf, 1, len, xfp->fp );
		xfp->limit -= nl;
	}
	else
		nl = fwrite( buf, 1, len, xfp->fp );

	
	if ( (xfp->cnt & 0xffffe000L) != ((xfp->cnt += nl) & 0xffffe000L)
		 && xfp->cntmes )
		xfp->cntmes( xfp->cnt );

	if ( nl != len && xfp->jmpbuf )
	{
		xfp_err = xfp;
		longjmp( xfp->jmpbuf, errno ? errno : EIO );
	}
	if ( xfp->mode & XF_CRCSUM )	
		xfp->crc = CRCSum( buf, nl, xfp->crc );
	
	return ( nl );
}

/*
*	start with new check sum
*/

crc_type	XStartCRC( XFILE *xfp )
{
	crc_type	crc;
	
	XBitsFlush( xfp );
	crc = xfp->crc;
	xfp->crc = INIT_CRC;
	xfp->mode |= XF_CRCSUM;
	
	return ( crc );
}

/*
*	return current check sum
*/

crc_type	XEndCRC( XFILE *xfp )
{
	crc_type	crc;
	
	XBitsFlush( xfp );
	crc = xfp->crc;
	xfp->crc = INIT_CRC;
	xfp->mode &= ~XF_CRCSUM;
	
	return ( crc );
}

/*
*	file seek
*/

int		XSeek( XFILE *xfp, long offset, int mode )
{
	XBitsFlush( xfp );
	if ( ( mode = fseek( xfp->fp, offset, mode ) ) != 0 )
	{
		if ( xfp->jmpbuf )
		{
			xfp_err = xfp;
			longjmp( xfp->jmpbuf, ESPIPE );
		}
	}
	return ( mode );	
}

/*
*	get some bits from bit buffer
*/

uint	XGetBits( int num, XFILE *xfp )
{
	int		n = xfp->num_bits; /* number of free bits */
	ulong	map = xfp->bitmap;
	uint	val;
	
	if ( n >= num )
	{
		n -= num;
		val = (uint) (map >> n);
	}
	else
	{
		num -= n;
		val = (uint) (map << num);

		if ( xfp->bb_pos >= xfp->bb_max )
		{
			xfp->bb_max = (int) XRead( (char *) xfp->bit_buf, XFP_BUFFER, xfp );
			ConvLong( xfp->bit_buf, xfp->bb_max );
			xfp->bb_pos = 0;
		}
		map = *(ulong*)(xfp->bit_buf + xfp->bb_pos);
		xfp->bb_pos += (int) sizeof (long);
		n = 32 - num;
		val |= (uint) (map >> n);
	}
	xfp->num_bits = n;
	n = 32 - n;
	map <<= n;
	map >>= n;
	xfp->bitmap = map;
	return ( val );
}

/*
*	write some bits to bit buffer
*/

void	XPutBits( int num, uint bits, XFILE *xfp )
{
	int		n = xfp->num_bits; /* number of free bits */
	ulong	map = xfp->bitmap;
	
	if ( num <= n )
	{
		map <<= num;
		(uint) map |= bits;
		if ( ( n -= num ) == 0 )
		{
			n = 32;
			*(ulong*)(xfp->bit_buf + xfp->bb_pos) = map;
			xfp->bb_pos += (int) sizeof (long);
			if ( xfp->bb_pos >= XFP_BUFFER )
			{
				ConvLong( xfp->bit_buf, xfp->bb_pos );
				XWrite( (char *) xfp->bit_buf, xfp->bb_pos, xfp );
				xfp->bb_pos = 0;
			}
		}
	}
	else
	{
		map <<= n;
		num -= n;
		(uint) map |= bits >> num;
		n = 32 - num;
		*(ulong*)(xfp->bit_buf + xfp->bb_pos) = map;
		(uint) map = bits;
		xfp->bb_pos += (int) sizeof (long);
		if ( xfp->bb_pos >= XFP_BUFFER )
		{
			ConvLong( xfp->bit_buf, xfp->bb_pos );
			XWrite( (char *) xfp->bit_buf, xfp->bb_pos, xfp );
			xfp->bb_pos = 0;
		}
	}
	xfp->bitmap = map;
	xfp->num_bits = n;
}

/*
*	copy a file
*/

long	XCopy( XFILE *sxfp, XFILE *dxfp, long len )
{
	long	l, nl, cnt = 0L;
	
	XBitsFlush( sxfp );
	XBitsFlush( dxfp );
	
	while ( len )
	{
		if ( ( l = Min( (long) XFP_BUFFER, len ) ) == 0L )
			break;
		if ( ( nl = XRead( sxfp->bit_buf, l, sxfp ) ) < l )
		{
			if ( sxfp->jmpbuf )
			{
				xfp_err = sxfp;
				longjmp( sxfp->jmpbuf, errno ? errno : ERANGE );
			}
			break;
		}
		if ( ( l = XWrite( sxfp->bit_buf, nl, dxfp ) ) < nl )
		{
			if ( dxfp->jmpbuf )
			{
				xfp_err = dxfp;
				longjmp( dxfp->jmpbuf, errno ? errno : ERANGE );
			}
			break;
		}
		cnt += l;
		len -= l;
	}
	return ( cnt );
}

/*
*	delete a file
*/

int	XRemove( const char *fname )
{
	int		i;
	char	*p;
	
	for ( i = 0; i < MAX_XFILE; i++ )
		if ( ( p = tpf[i] ) != NULL && !strcmp( p, fname ) )
		{
			tpf[i] = NULL;
			free( p );
		}
	return ( remove( fname ) );
}
	