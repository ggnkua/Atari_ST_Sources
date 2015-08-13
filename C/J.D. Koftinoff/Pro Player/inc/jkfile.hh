
#ifndef __JKFILE_HH
#define __JKFILE_HH

#ifndef SEEK_SET
#define SEEK_SET 0
#define SEEK_CUR 1
#define SEEK_END 2
#endif


enum
{
	NoErr, OpenErr, CreateErr, CloseErr, ReadErr, WriteErr,
	SeekErr, DeleteErr, TypeErr, NotOpenErr, UntitledErr, EOFErr,
	MemFullErr, ExtendedErr
};

typedef int FileErr;    // this way, the enum's are extendable.


enum iomode
{
	io_read=0,io_write,io_read_write
};

enum seek_pos
{
	seek_begin=0,seek_current,seek_end
};



class JKFile
{
private:
	char    full_path[80];
	Boolean dirty, untitled, report_errs, temporary;
	iomode  current_mode;
	int     handle;

	void    (*error_handler)( JKFile *, FileErr, char *  );

	// called : (*)( JKFile *this, FileErr err, char *string )

public:
			JKFile();                // new untitled file, not opened
			JKFile( char *, iomode );// sets file name, and opens
	virtual         ~JKFile();               // automatically closes file if opened


//
// High-level file instance control methods
//

	inline  void    SetFilePath( char *s )
					{strcpy( full_path, s );untitled=FALSE;}
	inline  void    GetFilePath( char *s )
					{strcpy( s,full_path);}
	inline  void    SetDirty( Boolean d)
					{dirty=d;}
	inline  Boolean IsDirty()
					{return dirty;}

	inline  void    SetUntitled( Boolean u )
					{untitled=u;}
	inline  Boolean IsUntitled()
					{return untitled;}

	inline  void    SetReportErrs( Boolean r )
					{report_errs=r;}

	inline  void    SetErrorHandler( void *e )
					{((void *)error_handler)=e;}
//
// File open/close methods
//

		Boolean Exists();
		FileErr MkTemp( char * tmplate = "aaXXXXXX", Boolean = TRUE );
		FileErr Create();
		FileErr Open( iomode = io_read );       // may create the file
		FileErr Open( char *, iomode = io_read );
		FileErr Close();
		FileErr Delete();

		FileErr Seek( long, seek_pos mode= seek_begin );
		FileErr GetFileLen( long * );

//
// Data transfer functions
//

		FileErr Read( long, void * );
		FileErr ReadString( char *, int );
		FileErr ReadLong( long *l )
					{return Read( sizeof( long ), l );}

		FileErr Write( long, void * );
		FileErr WriteString( char * );
		FileErr WriteLong( long l )
					{return Write( sizeof( long ), &l );}
//
// Error handling
//
	virtual char*   ErrorName( FileErr );
	virtual FileErr HandleFileError( FileErr );

};






#endif


