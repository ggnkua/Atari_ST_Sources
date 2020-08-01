/*
 * main functions of CLIB for F68KANS
 */
 
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>
#include "loader.h" 


/* date and time */
char* 	cdecl _asctime();
long	cdecl _clk_tck();
long 	cdecl _clock(); 
char*	cdecl _ctime();
/*		cdecl _difftime(); */
void*	cdecl _gmtime();
void*	cdecl _localtime();
long	cdecl _mktime();
long	cdecl _strftime();
long	cdecl _time();
long	cdecl _timezone();

/* memory */
void* cdecl _calloc();
void cdecl _free();
void* cdecl _malloc();
void* cdecl _realloc();

/* I/O */
void cdecl _clearerr();
long cdecl _close();
long cdecl _creat();
long cdecl _fclose();
long cdecl _feof();
long cdecl _ferror();
long cdecl _fflush();
long cdecl _fgetc();
long cdecl _fgetpos();
char* cdecl _fgets();
long cdecl _fileno();
void* cdecl _fopen();
long cdecl _fputc();
long cdecl _fputs();
long cdecl _fread();
void* cdecl _freopen();
long cdecl _fseek();
long cdecl _fsetpos();
long cdecl _ftell();
long cdecl _fwrite();
long cdecl _getc();
long cdecl _getchar();
char* cdecl _gets();
long cdecl _lseek();
long cdecl _open();
void cdecl _perror();
long cdecl _putc();
long cdecl _putchar();
long cdecl _puts();
long cdecl _read();
long cdecl _remove();
long cdecl _rename();
void cdecl _rewind();
void cdecl _setbuf();
long cdecl _setvbuf();
char* cdecl _strerror();
char* cdecl _tmpnam();
void* cdecl _tmpfile();
long cdecl _ungetc();
long cdecl _write();
long cdecl _unlink();
long cdecl _errno();
void* cdecl _stdout();
void* cdecl _stdin();
void* cdecl _stderr();
void* cdecl _stdaux();
void* cdecl _stdprn();

/* misc */
void cdecl _srand();
long cdecl _rand();
long cdecl _random();




SI_funcarr SI_CLIB_fa[] = {
	_asctime, 
	_clk_tck,
	_clock, 
	_ctime,
/*	_difftime,	*/
	_gmtime, 
	_localtime,
	_mktime,
	_strftime,
	_time,
	_timezone,
	
	_calloc, _free, _malloc, _realloc,
	
	_clearerr, _close, _creat, _fclose,
	_feof, _ferror, _fflush, _fgetc,
	_fgetpos, _fgets, _fileno, _fopen,
	_fputc, _fputs, _fread,   _freopen,
  _fseek,
  _fsetpos,
  _ftell,
  _fwrite,
  _getc,
  _getchar,
  _gets,
  _lseek,
  _open,
  _perror,
  _putc,
  _putchar,
  _puts,
  _read,
  _remove,
  _rename,
  _rewind,
  _setbuf,
  _setvbuf,
  _strerror,
  _tmpnam,
  _tmpfile,
  _ungetc,
  _write,
  _unlink,
  _errno,
  _stdout, _stdin, _stderr, _stdaux, _stdprn,
  
  _srand, _rand, _random
};



/* date and time */
 
char* cdecl _asctime( void *tblock )
{ return asctime((struct tm *)tblock); }


long cdecl _clk_tck()
{ return CLK_TCK; }


long cdecl _clock()
{ return clock(); }


char* cdecl _ctime( void *timer )
{ return ctime( (time_t*)timer); }


/* _difftime returns a double. 
Will be inserted,  when floathandling is clear 
*/


void* cdecl _gmtime( long *clock )
{ return (void*)gmtime( (time_t*)clock ); }


void* cdecl _localtime( long *clock )
{ return (void*)localtime( (time_t*)clock ); }


long cdecl _mktime( void *tblock )
{ return (long)mktime((struct tm *)tblock); }


long cdecl _strftime( char *s, long maxsz, char *frmt, long len, void *timeptr)
{ 
char str[256];

	memcpy( str, frmt, (size_t)len );
	str[len] = '\0'; 

	return strftime( s, maxsz, str, (struct tm *)timeptr); 
}

long cdecl _time()
{ return time( NULL ); }


long cdecl _timezone()
{ return timezone; }



/* dynamic memory management */

void* cdecl _calloc( unsigned long nitems, unsigned long size )
{ return calloc( (size_t)nitems, (size_t)size); }


void cdecl _free( void *a )
{ free( a ); }


void* cdecl _malloc( unsigned long size )
{ return malloc( (size_t)size); }


void* cdecl _realloc( void *block, unsigned long size )
{ return realloc( block, (size_t)size); }




/****************************************************/
/* I/O												*/
/****************************************************/


void cdecl _clearerr( void *file )
{ clearerr( (FILE*) file ); }


long cdecl _close( long handle )
{ return (long)close( (int)handle ); }


long cdecl _creat( char *filename, long len )
{ 
char str[256];

	memcpy( str, filename, (size_t)len );
	str[len] = '\0'; 

	return (long)creat( str ); 
}


long cdecl _fclose( void *file )
{ return (long)fclose( (FILE*)file ); }


long cdecl _feof( void *file )
{ return (long)feof( (FILE*)file ); }


long cdecl _ferror( void *file )
{ return (long)ferror( (FILE*)file ); }


long cdecl _fflush( void *file )
{ return (long)fflush( (FILE*)file ); }


long cdecl _fgetc( void *file )
{ return (long)fgetc( (FILE*)file ); }


long cdecl _fgetpos( void *file, long *pos)
{ return (long)fgetpos( (FILE*)file, (fpos_t*)pos ); }


char* cdecl _fgets( char *str, long n, void *file )
{ return fgets( str, (int)n, (FILE*) file ); }


long cdecl _fileno( void *file )
{ return (long)fileno( (FILE*)file ); }


void *cdecl _fopen( char *filename, long len, char *mode, long mlen )
{ 
char str1[256];
char str2[256];

	memcpy( str1, filename, (size_t)len );
	str1[len] = '\0'; 

	memcpy( str2, mode, (size_t)mlen );
	str2[mlen] = '\0'; 

	return (void *)fopen( str1, str2 ); 
}


long cdecl _fputc( long ch, void *file )
{ return (long)fputc( (int)ch, (FILE*)file ); }


long cdecl _fputs( char *s, long len, void *file )
{ 
char str[256];

	memcpy( str, s, (size_t)len );
	str[len] = '\0'; 

	return (long)fputs( str, (FILE*)file ); 
}



long cdecl _fread( void *ptr, long size, long count, void *file )
{ return (long)fread( ptr, (size_t)size, (size_t)count, (FILE*)file ); }




void *cdecl _freopen( char *filename, long len, 
					  char *mode, long mlen, void *file )
{ 
char str1[256];
char str2[256];

	memcpy( str1, filename, (size_t)len );
	str1[len] = '\0'; 

	memcpy( str2, mode, (size_t)mlen );
	str2[mlen] = '\0'; 

	return (void *)freopen( str1, str2, (FILE*)file ); 
}



long cdecl _fseek( void *file, long offset, long mode )
{ return (long)fseek( (FILE*)file, offset, (int)mode); }



long cdecl _fsetpos( void *file, long *pos )
{ return (long)fsetpos( (FILE*)file, (fpos_t*)pos); }



long cdecl _ftell( void *file )
{ return ftell( (FILE*)file ); }



long cdecl _fwrite( void *ptr, long size, long count, void *file )
{ return (long)fwrite( ptr, (size_t)size, (size_t)count, (FILE*)file ); }



long cdecl _getc( void *file )
{ return (long)getc( (FILE*)file ); }



long cdecl _getchar()
{ return (long)getchar( ); }



char* cdecl _gets( char *str )
{ return gets( str ); }



long cdecl _lseek( long handle, long offset, long whence )
{ return (long)lseek( (int)handle, (size_t)offset, (int)whence ); }



long cdecl _open( char* filen, long len, long access )
{ 
char str[256];

	memcpy( str, filen, (size_t)len );
	str[len] = '\0'; 

	return (long)open( str, (int)access ); 
}



void cdecl _perror( char* s, long len )
{ 
char str[256];

	memcpy( str, s, (size_t)len );
	str[len] = '\0'; 

	perror( str ); 
}



long cdecl _putc( long c, void *file )
{ return (long)putc( (int)c, (FILE*)file ); }



long cdecl _putchar( long c )
{ return (long)putchar( (int)c ); }



long cdecl _puts( char* s, long len )
{ 
char str[256];

	memcpy( str, s, (size_t)len );
	str[len] = '\0'; 

	return (long)puts( str ); 
}



long cdecl _read( long handle, void* buf, long len )
{ return (long)read( (int)handle, buf, (size_t)len ); }



long cdecl _remove( char* filename, long len )
{ 
char str[256];

	memcpy( str, filename, (size_t)len );
	str[len] = '\0'; 

	return (long)remove( str ); 
}



long cdecl _rename( char* oldname, long olen, char* newname, long nlen)
{ 
char str1[256];
char str2[256];

	memcpy( str1, oldname, (size_t)olen );
	str1[olen] = '\0'; 

	memcpy( str2, newname, (size_t)nlen );
	str2[nlen] = '\0'; 

	return (long)rename( str1, str2 ); 
}



void cdecl _rewind( void* file )
{ rewind( (FILE*)file ); }


void cdecl _setbuf( void* file, void* buf )
{ setbuf( (FILE*)file, buf ); }



long cdecl _setvbuf( void* file, void* buf, long type, long size )
{ return (long)setvbuf( (FILE*)file, buf, (int)type, (size_t)size ); }



char* cdecl _strerror( long errnum )
{ return strerror( (int)errnum ); }



char* cdecl _tmpnam( char *s )
{ return tmpnam( s ); }



void* cdecl _tmpfile()
{ return (void*)tmpfile(); }



long cdecl _ungetc( long c, void *file ) 
{ return (long)ungetc( (int)c, (FILE*)file ); }



long cdecl _write( long handle, void* buf, long len )
{ return (long)write( (int)handle, buf, (size_t)len ); }



long cdecl _unlink( char* filename, long len )
{ 
char str[256];

	memcpy( str, filename, (size_t)len );
	str[len] = '\0'; 

	return (long)unlink( str ); 
}


/* some I/O variables and constants */

long cdecl _errno()
{ return (long)errno; }


void* cdecl _stdout()
{ return (void*)stdout; }


void* cdecl _stdin()
{ return (void*)stdin; }


void* cdecl _stderr()
{ return (void*)stderr; }


void* cdecl _stdaux()
{ return (void*)stdaux; }


void* cdecl _stdprn()
{ return (void*)stdprn; }




/*
 * misc
 */

void cdecl _srand( long seed )
{ srand( (unsigned) seed ); }


long cdecl _rand()
{ return (long)rand(); }


long cdecl _random( long max )
{ return (long)random( (int)max ); }





