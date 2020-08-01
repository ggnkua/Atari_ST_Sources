/////////////////////////////////////////////////////////////////////////////
//
//  GEMfileselector
//
//  A GEMfileselector is a source of filenames.
//
//  This file is Copyright 1992,1993 by Warwick W. Allison.
//  This file is part of the gem++ library.
//  You are free to copy and modify these sources, provided you acknowledge
//  the origin by retaining this notice, and adhere to the conditions
//  described in the file COPYING.LIB.
//
/////////////////////////////////////////////////////////////////////////////

#ifndef GEMfs_h
#define GEMfs_h

//
//  Glossary:
//
//    filename   E:\usr\gem++\foo.bar
//    filespec   E:\usr\gem++\*.bar   or   *.bar
//    path       E:\usr\gem++\        or   E:\usr\gem++
//    file       foo.bar
//
//  A "file" appears in the "File:" area of file selector.
//  A "filespec" appears in the "Path:" area of the file selector.
//  A "filename" is returns by the Get() method.

class GEMfileselector
{
public:
	GEMfileselector(int maxlen=128);
	GEMfileselector(char* filename);
	virtual ~GEMfileselector();

	// Returns result both ways.  NULL if cancelled.
	const char* Get(const char* prompt, char* into=0);

	// Avoid using the following calls.  Each GEMfileselector should remain
	// at the path the user specified.

	void Path(const char* path);
	// eg. Path("E:\foo"); Path("E:\foo\");

	void File(const char* file);
	const char* File() const;
	// eg. File("foo.bar"); oldgot=File();

	void Filespec(const char* filespec);
	const char* Filespec() const;
	// eg. Filespec("*.bar"); Filespec("E:\foo\*.bar"); oldspec=Filespec();

	void Filename(const char* filename);
	const char* Filename() const;
	// eg. Filename("foo.bar"); Filename("E:\foo\foo.bar"); oldgot=Filename();

	const char* CWD(); // Resets filespec to current work directory.

private:
	void Merge();
	char* filename;
	char* filespec;
	char* file;
	int len;
};


#endif
