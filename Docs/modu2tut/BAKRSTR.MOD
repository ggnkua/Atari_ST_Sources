MODULE BakRstr;

(* This program is used to restore the files from the floppy disks *)
(* to the hard disk.  This program is loaded into the root direc-  *)
(* tory of the hard disk and executed from there.  The files are   *)
(* read from the floppy and copied into the same directory of the  *)
(* hard disk as they are in on the floppy, the directories being   *)
(* created as needed on the hard disk.  To restore additional      *)
(* disks, simply rerun this program once for each disk.            *)
(*                                                                 *)
(*               Copywrite 1987 - Coronado Enterprises             *)

FROM InOut         IMPORT WriteString,Read,Write,WriteLn;
FROM DiskDirectory IMPORT CurrentDrive,CurrentDirectory;
FROM Strings       IMPORT Concat,Copy,Insert,Delete,Length,
                          CompareStr;
FROM Storage       IMPORT ALLOCATE,DEALLOCATE;
FROM FileSystem    IMPORT File;
FROM SYSTEM        IMPORT ADDRESS,TSIZE,SIZE;
FROM DirHelps      IMPORT ReadFileStats,FileDataPointer,FileData,
                          CopyFile,ChangeToDirectory;

VAR SourceDrive  : CHAR;
    TargetDrive  : CHAR;
    StartingPath : ARRAY[0..64] OF CHAR;
    FileList     : File;
    DiskTransAdr : ARRAY[1..43] OF CHAR;




PROCEDURE Initialize();
VAR StorageFile : ARRAY[0..20] OF CHAR;
BEGIN
   WriteString("Enter the source drive, one letter ---> ");
   Read(SourceDrive);
   SourceDrive := CAP(SourceDrive);
   Write(SourceDrive);
   WriteLn;
   CurrentDrive(TargetDrive);
   TargetDrive := 'A';
   Copy("A:",0,64,StartingPath);
   StartingPath[0] := SourceDrive;
END Initialize;



(* This procedure is used to copy the files from the floppy to the *)
(* hard disk while making a list of subdirectories found in order  *)
(* to copy each of them also.                                      *)

PROCEDURE StoreData(NewData         : FileDataPointer;
                    VAR Directories : FileDataPointer);
     PROCEDURE AddToTree(VAR RootOfTree : FileDataPointer;
                         VAR NewNode    : FileDataPointer);
     VAR Result : INTEGER;
     BEGIN
        Result := CompareStr(RootOfTree^.Name,NewNode^.Name);
        IF Result = 1 THEN
           IF RootOfTree^.Left = NIL THEN
              RootOfTree^.Left := NewNode;
           ELSE
              AddToTree(RootOfTree^.Left,NewNode);
           END;
        ELSE
           IF RootOfTree^.Right = NIL THEN
              RootOfTree^.Right := NewNode;
           ELSE
              AddToTree(RootOfTree^.Right,NewNode);
           END;
        END;
     END AddToTree;

VAR  Error      : CARDINAL;
     SourceFile : ARRAY[0..20] OF CHAR;
     DestFile   : ARRAY[0..20] OF CHAR;
BEGIN
   IF NewData^.Attr = 010H THEN         (* Attr = 10 for directory *)
      IF NewData^.Name[0] <> "." THEN
         IF Directories = NIL THEN
            Directories := NewData;
         ELSE
            AddToTree(Directories,NewData);
         END;
      END;
   ELSE                                    (* Otherwise a filename *)
      WriteString("Copyfile ---> ");
      WriteString(NewData^.Name);
      WriteLn;
      Copy(NewData^.Name,0,20,SourceFile);
      Insert(SourceDrive,SourceFile,0);
      Insert(':',SourceFile,1);
      Copy(NewData^.Name,0,20,DestFile);
      Insert(TargetDrive,DestFile,0);
      Insert(':',DestFile,1);
      CopyFile(SourceFile,DestFile,NewData^.Size,Error);
      IF Error <> 0 THEN
         WriteString("Error copying file ---> ");
         WriteString(SourceFile);
         WriteLn;
      END;
   END;
END StoreData;



(* This procedure reads the file statistics from DOS and stores    *)
(* the data in a record for further use.                           *)

PROCEDURE ReadFileStatistics(VAR Directories : FileDataPointer;
                             PathToFiles : ARRAY OF CHAR);
TYPE MaskStore = ARRAY[0..70] OF CHAR;
VAR MaskAndFile  : MaskStore;         (* Used for file search name *)
    ModifiedPath : MaskStore;
    MaskAddr     : ADDRESS;
    Error        : BOOLEAN;
    Index        : CARDINAL;
    NewData      : FileDataPointer;
    FirstFile    : BOOLEAN;
BEGIN
   WriteString("Changepath ---> ");
   WriteString(PathToFiles);
   WriteLn;
   Copy(PathToFiles,0,64,ModifiedPath);
   IF ModifiedPath[2] = 000C THEN
      ModifiedPath[2] := '\';
      ModifiedPath[3] := 000C;
   END;
   ModifiedPath[0] := TargetDrive;
   ChangeToDirectory(ModifiedPath,TRUE,Error);
   IF Error THEN
      WriteString("Cannot change target directory ---> ");
      WriteString(ModifiedPath);
      WriteLn;
   END;
   ModifiedPath[0] := SourceDrive;
   ChangeToDirectory(ModifiedPath,FALSE,Error);
   IF Error THEN
      WriteString("Cannot change source directory ---> ");
      WriteString(ModifiedPath);
      WriteLn;
   END;
   ALLOCATE(NewData,TSIZE(FileData));
   FirstFile := TRUE;
   Concat(PathToFiles,"/*.*",MaskAndFile);
   ReadFileStats(MaskAndFile,FirstFile,NewData,Error);
   IF NOT Error THEN
      StoreData(NewData,Directories);
   END;

   REPEAT
      ALLOCATE(NewData,TSIZE(FileData));
      FirstFile := FALSE;
      ReadFileStats(MaskAndFile,FirstFile,NewData,Error);
      IF NOT Error THEN
         StoreData(NewData,Directories);
      END;
   UNTIL Error;

END ReadFileStatistics;



(* This procedure searches all subdirectory names found in a       *)
(* search of a subdirectory for additional files and subdirector-  *)
(* ies.  The search is recursive.                                  *)

PROCEDURE DoAllSubdirectories(StartPath : ARRAY OF CHAR;
                              Directories : FileDataPointer);
VAR NewPath : ARRAY[0..64] OF CHAR;
    Index   : CARDINAL;
BEGIN
   IF Directories <> NIL THEN
      IF Directories^.Left <> NIL THEN
         DoAllSubdirectories(StartPath,Directories^.Left);
      END;
      IF Directories^.Name[0] <> '.' THEN
         Copy(StartPath,0,64,NewPath);
         Insert('\',NewPath,Length(NewPath));
         Concat(NewPath,Directories^.Name,NewPath);
         FOR Index := (SIZE(NewPath)-1) TO 1 BY -1 DO
            IF NewPath[Index] = ' ' THEN
               NewPath[Index] := 000C;
            END;
         END;
         GetAllFilesAndDirectories(NewPath);
      END;
      IF Directories^.Right <> NIL THEN
         DoAllSubdirectories(StartPath,Directories^.Right);
      END;
   END;
END DoAllSubdirectories;



(* This procedure deletes a tree after it is no longer needed.     *)

PROCEDURE DeleteTree(Point : FileDataPointer);
BEGIN
   IF Point <> NIL THEN
      DeleteTree(Point^.Left);
      DeleteTree(Point^.Right);
      DEALLOCATE(Point,TSIZE(FileData));
   END;
END DeleteTree;



PROCEDURE GetAllFilesAndDirectories(ThisPath : ARRAY OF CHAR);
VAR DirExists   : BOOLEAN;           (* Temporary - use logic later*)
    Directories : FileDataPointer;   (* Point to root of Dir tree  *)
BEGIN
   Directories := NIL;
   ReadFileStatistics(Directories,ThisPath);
   DoAllSubdirectories(ThisPath,Directories);
   DeleteTree(Directories);
END GetAllFilesAndDirectories;




BEGIN   (* Main program - BakRstr, Backup restore *)
  Initialize;
  GetAllFilesAndDirectories(StartingPath);
END BakRstr.

