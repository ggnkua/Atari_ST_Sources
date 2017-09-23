{ --- This unit makes lists of files and directories --- }
{ --- (c) 1992 Pure Software GmbH.                   --- }

UNIT DirSearch;

INTERFACE

USES Dos;

TYPE
	FileList = ^FileListItem;
	FileListItem =
		RECORD
			next: FileList;
			time: LongInt;
			size: LongInt;
			name: STRING[12];
		END;

	DirList = ^DirListItem;
	DirListItem =
		RECORD
			next: DirList;
			time: LongInt;
			name:	DirStr;
		END;


FUNCTION ReadDir(dir: DirStr; pat: STRING): FileList;

FUNCTION ReadTree(baseDir: DirStr): DirList;

PROCEDURE DisposeDir(fList: FileList);

PROCEDURE DisposeTree(dList: DirList);

IMPLEMENTATION


{ --- Make a list of files matching pat --- }
FUNCTION ReadDir(dir: DirStr; pat: STRING): FileList;
VAR
	fileRec : SearchRec;
	fList, newFile: FileList;

BEGIN
	fList := nil;
	FindFirst( dir + pat, 0, fileRec );
	WHILE DosError = 0 DO BEGIN
		NEW(newFile);
		newFile^.next := fList;
		fList := newFile;
		newFile^.time := fileRec.time;
		newFile^.size := fileRec.size;
		newFile^.name := fileRec.name;
		FindNext( fileRec );
	END;
	ReadDir := fList;
END;


{ --- Attach list of subdirectories starting at baseDir to dList --- }
FUNCTION InsertTree(baseDir: DirStr; dList: DirList): DirList;
VAR
	fileRec : SearchRec;
	newDir: DirList;

BEGIN
	NEW(newDir);
	newDir^.next := dList;
	newDir^.name := baseDir;
	dList := newDir;
	FindFirst( baseDir + '*.*', Directory, fileRec );
	WHILE DosError = 0 DO BEGIN
		IF	(fileRec.attr = Directory)
		AND (fileRec.name[1] <> '.') THEN
			dList := InsertTree(baseDir + fileRec.name + '\', dList);
		FindNext( fileRec );
	END;
	InsertTree := dList;
END;


{ --- Make a list of subdirectories starting at baseDir --- }
FUNCTION ReadTree(baseDir: DirStr): DirList;
BEGIN
	IF baseDir[LENGTH(baseDir)] <> '\' THEN
		baseDir := baseDir + '\';
	ReadTree := InsertTree(baseDir, NIL);
END;


{ --- Throw away list of files --- }
PROCEDURE DisposeDir(fList: FileList);
VAR f: FileList;
BEGIN
	WHILE fList <> NIL DO BEGIN
		f := fList;
		fList := f^.next;
		DISPOSE(f);
	END;
END;


{ --- Throw away tree of directories --- }
PROCEDURE DisposeTree(dList: DirList);
VAR d: DirList;
BEGIN
	WHILE dList <> NIL DO BEGIN
		d := dList;
		dList := d^.next;
		DISPOSE(d);
	END;
END;

END.
