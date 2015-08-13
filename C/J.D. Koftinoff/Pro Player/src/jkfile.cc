/*

 The Pro MIDI Player
 Copyright 1986-1994 By J.D. Koftinoff Software, Ltd.
 Released under the GPL in 2007
 Please see the file 'COPYING' including in this package.
 
*/
 

#include "perform.h"
#pragma hdrstop

#include <jkfile.hh>
#include <fcntl.h>

#ifdef atarist
#include <unixlib.h>
#else
#include <io.h>
#endif

#include <sys/stat.h>

static void _cputs(const char *s)
{
#ifndef _IBM_PC
	while( *s )
		putch( *s++ );
#endif
}


JKFile::JKFile()
{
	*full_path='\0';
	dirty=FALSE;
	untitled=TRUE;
	report_errs=FALSE;
	temporary=FALSE;
	current_mode=io_read;
	handle=-1;              // not opened.
	error_handler=NULL;     // default error handler
}


JKFile::JKFile( char *fname, iomode mode )
{
	strcpy( full_path, fname );
	dirty=FALSE;
	untitled=FALSE;
	report_errs=FALSE;
	temporary=FALSE;
	handle=-1;
	error_handler=NULL;     // default error handler
	Open( mode );
}



JKFile::~JKFile()
{
	if( handle!=-1 )        // if it is opened, close it.
		Close();
	if( temporary )         // if it is temporary, delete it.
		Delete();
}



Boolean JKFile::Exists()
{
	if( handle!=-1 ) return TRUE;
	if( untitled ) return FALSE;

	int h;

	if((h=open( full_path, O_RDONLY ))<0)
	{
		return FALSE;
	}
	else
	{
		close( h );
		return TRUE;
	}
}


FileErr JKFile::MkTemp( char *tmplate, Boolean delete_after )
{
	if( handle!=-1 )
		if( Close()!=NoErr )
			return CreateErr;
	
	SetFilePath( tmplate );
	if( mktemp( full_path ) )
	{
		temporary=delete_after;
		return Create();
	}
	return HandleFileError( CreateErr );
}


FileErr JKFile::Create()
{
	if( handle!=-1 )
		if( Close()!=NoErr )
			return CreateErr;

	if( untitled )
		return HandleFileError( UntitledErr );

	handle=creat( full_path, S_IREAD | S_IWRITE );

	if( handle<0 )
	{
		handle=-1;
		return HandleFileError( CreateErr );
	}

	return NoErr;
}


FileErr JKFile::Open( iomode mode )
{
	if( handle!=-1 )
		if( Close()!=NoErr )
			return OpenErr;

	if( untitled )
		return HandleFileError( UntitledErr );

	short omode;
	switch( mode )
	{
		case io_read:
			omode=O_RDONLY;
			break;
		case io_write:
			omode=O_WRONLY;
			break;
		case io_read_write:
			omode=O_RDWR;
			break;
	}
	handle=open( full_path, omode | O_BINARY );

	if( handle<0 && (mode==io_write || mode==io_read_write) )
	{
		return Create();
	}

	if( handle<0 )
	{
		handle=-1;
		return HandleFileError( OpenErr );
	}

	current_mode=mode;

	return NoErr;
}

FileErr JKFile::Open( char *name, iomode mode )
{
	if( handle!=-1 )
		if( Close()!=NoErr )
			return OpenErr;

	SetFilePath( name );

	return Open( mode );

}


FileErr JKFile::Close()
{
	if( handle==-1 )
		return HandleFileError( NotOpenErr );

	if( close( handle )<0 )
	{
		return HandleFileError( CloseErr );
	}
	handle=-1;
	return NoErr;
}


FileErr JKFile::Delete()
{
	if( handle!=-1 )
		Close();
	if( untitled )
		return HandleFileError( UntitledErr );

	if( unlink( full_path )<0 )
		return HandleFileError( DeleteErr );
	return NoErr;
}


FileErr JKFile::Seek( long offset, seek_pos from )
{
	if( handle==-1 )
		return HandleFileError( NotOpenErr );

	short sfrom;

	switch( from )
	{
		case seek_begin:
			sfrom=SEEK_SET;
			break;
		case seek_current:
			sfrom=SEEK_CUR;
			break;
		case seek_end:
			sfrom=SEEK_END;
			break;
	}

	if( lseek( handle, offset, sfrom )<0 )
		return HandleFileError( SeekErr );

	return NoErr;

}


FileErr JKFile::GetFileLen( long *len )
{
	if( handle==-1 )
		return HandleFileError( NotOpenErr );

#ifdef atarist
	*len = Fseek( 0, handle, seek_end );

	if( *len < 0 )
		return HandleFileError( SeekErr );

	Seek(0);
#endif
#ifdef _IBM_PC
	// TO DO: get file length for IBM PC
#endif
#ifdef _MACINTOSH

	*len=filelength(handle);
#endif
	return NoErr;
}



FileErr JKFile::Read( long size, void *ptr )
{
	if( handle==-1 )
		return HandleFileError( NotOpenErr );
	
	register long len;
	
	len=read(handle,ptr,size);

	if( len==0 )
		return HandleFileError( ReadErr );

	if( len!=size )
		return EOFErr;

	return NoErr;
}


FileErr JKFile::ReadString( char *s, int max_len )
{       // this is a bit of a kludge, but, what the hey...

	if( handle==-1 )
		return HandleFileError( NotOpenErr );

	int cur_len;
	char c;
	long x;


	for( cur_len=0; cur_len<max_len; )
	{
		x=read(handle,&c,1);            // read 1 byte

		if( x==0 )                      // read error?
		{                               // or end of file error?
			s[cur_len]='\0';        // mark end
			return NoErr;           // and return with NO ERR!
		}                               // cuz we can't tell EOF
						// from Read err

		if( c=='\n' || c=='\0' )        // End of line
		{
			s[cur_len]='\0';        // mark with '\0'
			return NoErr;
		}

		if( c!='\r' )                   // skip over all cr's
		{
			s[cur_len]=c;           // all other chars are saved
			cur_len++;              // go to next position
		}
	}

	// we only get here if the buffer is filled.

	s[max_len-1]='\0';                      // mark ending of string
	return NoErr;
}




FileErr JKFile::Write( long size, void *ptr )
{
	if( handle==-1 )
		return HandleFileError( NotOpenErr );

	register long len;

	len=write( handle,ptr,size );
	if( len!=size )
		return HandleFileError( WriteErr );

	return NoErr;
}


FileErr JKFile::WriteString( char *s )
{
	register long len;

	len=strlen(s);

	return HandleFileError( Write( len, s ) );
}



char *JKFile::ErrorName( FileErr err )
{
	switch( err )
	{
		case NoErr:
			return "No Error";
		case OpenErr:
			return "Open Error";
		case CreateErr:
			return "Create Error";
		case CloseErr:
			return "Close Error";
		case ReadErr:
			return "Read Error";
		case WriteErr:
			return "Write Error";
		case SeekErr:
			return "Seek Error";
		case DeleteErr:
			return "Delete Error";
		case TypeErr:
			return "Type Error";
		case NotOpenErr:
			return "Not Open Error";
		case UntitledErr:
			return "Untitled Error";
		case EOFErr:
			return "End Of File Error";
		case ExtendedErr:
			return "Extended Error";
		default:
			return "Unknown Error";
	}

}


FileErr JKFile::HandleFileError( FileErr err )
{
	if( report_errs && err!=NoErr && !error_handler )
	{
	char *s;
		s=ErrorName( err );
		_cputs(s);
		_cputs("--file:");
		_cputs(full_path);
		_cputs("\r\n");
	}

	if( report_errs && err!=NoErr && error_handler )
	{
	char *s;
		s=ErrorName( err );
		(*error_handler)( this, err, s );
	}

	return err;
}


