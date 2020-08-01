MODULE BakList;

(* This program is used to generate a list of all files in all     *)
(* subdirectories except for the DOS files and the list file which *)
(* this program generates.  The file FULLDISK.LST is created and   *)
(* filled in the root directory of the default drive containing    *)
(* the entire tree from the default subdirectory to all end points.*)
(* If this program is called from the root directory, the tree for *)
(* the entire default directory will be listed.  The resulting file*)
(* can then be edited with any text editor to allow copying of all *)
(* files or only selected files.                                   *)
(*                                                                 *)
(*            Copywrite (c) 1987 - Coronado Enterprises            *)


FROM InOut         IMPORT WriteString,WriteCard,Write,WriteLn;
FROM RealInOut     IMPORT WriteReal;
FROM Real2Fil      IMPORT WriteStringFile,WriteLnFile;
FROM DiskDirectory IMPORT CurrentDrive,CurrentDirectory;
FROM Strings       IMPORT Concat,Copy,Length,Insert,CompareStr,
                          Delete;
FROM FileSystem    IMPORT Lookup,Close,File,Response;
FROM SYSTEM        IMPORT AX,BX,CX,DX,SI,DI,ES,DS,CS,SS,SIZE,TSIZE,
                          ADR,ADDRESS,GETREG,SETREG,SWI;
FROM Storage       IMPORT ALLOCATE,DEALLOCATE;
FROM DirHelps      IMPORT ReadFileStats,FileDataPointer,FileData;

VAR Drive        : CHAR;
    StartingPath : ARRAY[0..64] OF CHAR;
    FileList     : File;
    DiskTransAdr : ARRAY[1..43] OF CHAR;




(* This procedure selects the current drive and directory and opens*)
(* the file named FULLDISK.LST to be used for recording all sub-   *)
(* directories and filenames.                                      *)

PROCEDURE Initialize() : BOOLEAN;
VAR StorageFile : ARRAY[0..20] OF CHAR;
BEGIN
   CurrentDrive(Drive);                 (* This generates the path *)
   CurrentDirectory(Drive,StartingPath);(* used for the start of   *)
   Insert(Drive,StartingPath,0);        (* the search.  It uses    *)
   Insert(':',StartingPath,1);          (* the current drive and   *)
   IF StartingPath[2] <> 000C THEN      (* path.                   *)
      Insert('\',StartingPath,2);
   END;

   StorageFile := ":\FULLDISK.LST";     (* This opens the file used*)
   Insert(Drive,StorageFile,0);         (* to store the file-list. *)
   Lookup(FileList,StorageFile,TRUE);   (* It is forced into the   *)
   IF FileList.res = done THEN          (* root of the current     *)
      RETURN(TRUE);                     (* directory.              *)
   ELSE
      RETURN(FALSE);
   END;
END Initialize;




(* This procedure is used to store all of the data found into a    *)
(* B-tree structure to be used in sorting the files and subdirec-  *)
(* tories alphabetically.                                          *)

PROCEDURE StoreData(NewData         : FileDataPointer;
                    VAR Files       : FileDataPointer;
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

     PROCEDURE GoodFile(FileName : ARRAY OF CHAR) : BOOLEAN;
     BEGIN
        IF    CompareStr(FileName,"COMMAND.COM ") = 0 THEN
           RETURN(FALSE);
        ELSIF CompareStr(FileName,"IBMBIO.COM  ") = 0 THEN
           RETURN(FALSE);
        ELSIF CompareStr(FileName,"IBMDOS.COM  ") = 0 THEN
           RETURN(FALSE);
        ELSIF CompareStr(FileName,"FULLDISK.LST") = 0 THEN
           RETURN(FALSE);
        ELSE
           RETURN(TRUE);
        END;
     END GoodFile;

VAR  Index   : CARDINAL;
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
      IF GoodFile(NewData^.Name) THEN
         IF Files = NIL THEN
            Files := NewData;
         ELSE
            AddToTree(Files,NewData);
         END;
      ELSE
         WriteString("File ignored here --->");
         WriteString(NewData^.Name);
         WriteLn;
      END;
   END;
END StoreData;




(* This procedure reads the file statistics from DOS and stores the*)
(* data in a record for further use.                               *)

PROCEDURE ReadFileStatistics(VAR Files : FileDataPointer;
                             VAR Directories : FileDataPointer;
                             PathToFiles : ARRAY OF CHAR);
TYPE MaskStore = ARRAY[0..70] OF CHAR;
VAR SmallMask   : MaskStore;  (* Used for Directory output to file *)
    MaskAndFile : MaskStore;          (* Used for file search name *)
    MaskAddr    : ADDRESS;
    Error       : BOOLEAN;
    Index       : CARDINAL;
    NewData     : FileDataPointer;
    FirstFile   : BOOLEAN;
BEGIN
   WriteString(PathToFiles);
   WriteLn;
   Copy(PathToFiles,0,SIZE(PathToFiles),SmallMask);
   Delete(SmallMask,0,2);
   WriteStringFile(FileList,SmallMask);
   WriteLnFile(FileList);
   ALLOCATE(NewData,TSIZE(FileData));
   FirstFile := TRUE;
   Concat(PathToFiles,"/*.*",MaskAndFile);
   ReadFileStats(MaskAndFile,FirstFile,NewData,Error);
   IF NOT Error THEN
      StoreData(NewData,Files,Directories);
   END;

   REPEAT
      ALLOCATE(NewData,TSIZE(FileData));
      FirstFile := FALSE;
      ReadFileStats(MaskAndFile,FirstFile,NewData,Error);
      IF NOT Error THEN
         StoreData(NewData,Files,Directories);
      END;
   UNTIL Error;

END ReadFileStatistics;




(* This procedure lists all of the filenames alphabetically by     *)
(* recursively tracing the B-tree described above.                 *)

PROCEDURE ListAllFiles(Files : FileDataPointer);
VAR TempString : ARRAY[0..5] OF CHAR;
BEGIN
   IF Files <> NIL THEN
      IF Files^.Left <> NIL THEN
         ListAllFiles(Files^.Left);
      END;
         TempString := " ";
         WriteStringFile(FileList,TempString);
         WriteStringFile(FileList,Files^.Name);
         WriteLnFile(FileList);
      IF Files^.Right <> NIL THEN
         ListAllFiles(Files^.Right);
      END;
   END;
END ListAllFiles;




(* This procedure searches all Subdirectory names found in a       *)
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



(* This procedure deletes a tree after it has completed its task   *)
(* and is no longer of any use.                                    *)

PROCEDURE DeleteTree(Point : FileDataPointer);
BEGIN
   IF Point <> NIL THEN
      DeleteTree(Point^.Left);
      DeleteTree(Point^.Right);
      DEALLOCATE(Point,TSIZE(FileData));
   END;
END DeleteTree;



(* This procedure searches a subdirectory for all files names and  *)
(* additional subdirectories.                                      *)

PROCEDURE GetAllFilesAndDirectories(ThisPath : ARRAY OF CHAR);
VAR DirExists   : BOOLEAN;           (* Temporary - use logic later*)
    Files       : FileDataPointer;   (* Point to root of File tree *)
    Directories : FileDataPointer;   (* Point to root of Dir tree  *)
BEGIN
   Files := NIL;
   Directories := NIL;
   ReadFileStatistics(Files,Directories,ThisPath);
   ListAllFiles(Files);           (* List to a file for later use. *)
   DoAllSubdirectories(ThisPath,Directories);
   DeleteTree(Files);
   DeleteTree(Directories);
END GetAllFilesAndDirectories;




BEGIN   (* Main program - BakList, Backup list *)
   IF Initialize() THEN
      GetAllFilesAndDirectories(StartingPath);
      Close(FileList);
   ELSE
      WriteString("File named FULLDISK.LST cannot be opened");
      WriteLn;
   END;
END BakList.
