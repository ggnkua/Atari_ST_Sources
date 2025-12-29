IMPLEMENTATION MODULE GetFile;
FROM GEMDOS IMPORT GetDrv,GetPath;
FROM pSTRING IMPORT SLEN,ASSIGN,DELETE,APPEND,RPOSCHR,CONCAT;
IMPORT FSelMgr;

PROCEDURE GetPathAndFile( FileWildCards, Label : ARRAY OF CHAR; VAR PathName,
                          FileName : ARRAY OF CHAR):BOOLEAN;
VAR FileSelectOK : BOOLEAN;
    LastBackslash : INTEGER;
    Drive : CARDINAL;
    DrvName  : ARRAY[0..2] OF CHAR;
BEGIN
    IF (SLEN(PathName) = 0) THEN
       GetDrv(Drive);
       DrvName[0]:=CHR(65+Drive);DrvName[1]:=':';
       DrvName[2]:=0C;       
       GetPath(PathName,0);
       CONCAT(DrvName,PathName,PathName);
       APPEND('\',PathName); 
    END (*IF*); 
    (* Wildcards fÅr die File-Select-Box an den Pfadnamen anhÑngen *)
    APPEND(FileWildCards,PathName);
    FileSelectOK:=FSelMgr.FSelInput(PathName,FileName,Label);

    (* Die Wildcards wieder vom Pfadnamen abschneiden ! *)
    LastBackslash:= RPOSCHR(255,"\",PathName);
    DELETE(LastBackslash+1,SLEN(PathName),PathName);
    RETURN FileSelectOK
END GetPathAndFile;                           

PROCEDURE StripExtension(VAR fName : ARRAY OF CHAR);
BEGIN
    (* alles hinter dem letzten Punk abschneiden *)
    DELETE(RPOSCHR(255,".",fName),SLEN(fName),fName);
    (* das Funktioniert natÅrlich nur wenn der Dateiname *)
    (* auch eine Extension hatte sonst ..... *)
END StripExtension;

END GetFile.