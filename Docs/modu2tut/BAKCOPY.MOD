MODULE BakCopy;

(* This program is used to actually copy the files from the fixed  *)
(* disk to the floppy disks.  It uses the file FULLDISK.LST as the *)
(* basis for its copying.  That file is generated using the sister *)
(* program BAKLIST, and after generation, it can be modified with  *)
(* any text editor to allow elimination of any files or directories*)
(* that you do not wish to back up.                                *)
(*                                                                 *)
(*            Copywrite (c) 1987 - Coronado Enterprises            *)

(* Note that this is a preliminary version of this example program *)
(* and as such, it is not completely refined as it would need to   *)
(* be for a full production system.  Since it was never intended   *)
(* to compete with the full production backup systems available,   *)
(* but was meant only to illustrate the method of building up a    *)
(* significant sized program, it is considered to have attained    *)
(* the original goal.  It can be used as a backup system if you    *)
(* don't mind the following problems.                              *)
(*                                                                 *)
(* 1. The date and time of the files on the copy are the date and  *)
(*    time that the copies are made, not the date and time of the  *)
(*    original files.  The date and time of the original can be    *)
(*    read and copied to the copy using interrupt 21 - function    *)
(*    call 57H if you can figure out how to get the file handle.   *)
(*                                                                 *)
(* 2. This system does not copy hidden files.                      *)
(*                                                                 *)
(* 3. This system does not copy files that are too big to fit on   *)
(*    one floppy disk.                                             *)
(*                                                                 *)
(* 4. The filesize and the room remaining on the disk are handled  *)
(*    using floating point numbers instead of CARDINAL which would *)
(*    be a much needed improvement.  The floating point numbers on *)
(*    this system use enough significant digits to allow this,     *)
(*    but changing to CARDINAL would be an improvement.  Keep in   *)
(*    mind if you attempt this, that the upper limit on a CARDINAL *)
(*    is 65535 so it would require the use of two CARDINALS for    *)
(*    filesize and two for room on disk.                           *)

FROM InOut         IMPORT WriteString, WriteCard, WriteLn,
                          Write, Read;
FROM RealInOut     IMPORT WriteReal;
FROM FileSystem    IMPORT Lookup, Close, File, Response, ReadByte;
FROM Strings       IMPORT Copy, Insert, Delete;
FROM DiskDirectory IMPORT CurrentDrive;
FROM SYSTEM        IMPORT ADR;
FROM DirHelps      IMPORT GetDiskStatistics, ChangeToDirectory,
                          CopyFile, FileData, FileDataPointer,
                          ReadFileStats;

TYPE CharArray = ARRAY[0..100] OF CHAR;

VAR  InputFile         : File;
     SourceDrive       : CHAR;
     SourceFile        : CharArray;
     TargetDrive       : CHAR;
     TargetFile        : CharArray;
     InputLine         : CharArray;
     WorkingDirectory  : CharArray;
     Char              : CHAR;
     Index             : CARDINAL;
     SectorsPerCluster : CARDINAL;
     FreeClusters      : CARDINAL;
     BytesPerSector    : CARDINAL;
     TotalClusters     : CARDINAL;
     ErrorRet          : BOOLEAN;
     ErrorCode         : CARDINAL;
     FileSize          : REAL;
     RoomOnDisk        : REAL;
     RoomOnNewDisk     : REAL;
     DataForFile       : FileData;
     PointToData       : FileDataPointer;
     DiskNumber        : CARDINAL;
     EndOfCopy         : BOOLEAN;


(* This procedure is used to read in one full line from the input  *)
(* file.                                                           *)

PROCEDURE ReadALine;
BEGIN
   Index := 0;
   REPEAT        (* Read one line of input data *)
      ReadByte(InputFile,Char);
      IF Char <> 15C THEN
         InputLine[Index] := Char;
         INC(Index);
      END;
   UNTIL (Index = 100) OR (Char = 12C) OR InputFile.eof;
   InputLine[Index - 1] := 000C;
END ReadALine;



(* This procedure calls the actual copying routine after it checks *)
(* to see if there is enough room on the target floppy.  If there  *)
(* is not, it requests a blank floppy to be loaded.                *)

PROCEDURE CopyTheFile;
BEGIN
   Delete(InputLine,0,1);                  (* Remove leading blank *)
   SourceFile := InputLine;
   Insert(SourceDrive,SourceFile,0);
   Insert(':',SourceFile,1);
   TargetFile := InputLine;
   Insert(TargetDrive,TargetFile,0);
   Insert(':',TargetFile,1);
                           (* See if the file will fit on the disk *)
   PointToData := ADR(DataForFile);
   ReadFileStats(SourceFile,TRUE,PointToData,ErrorRet);
   FileSize := PointToData^.Size;
   GetDiskStatistics(TargetDrive,SectorsPerCluster,FreeClusters,
                     BytesPerSector,TotalClusters);
   RoomOnDisk := FLOAT(SectorsPerCluster) *
                 FLOAT(FreeClusters) *
                 FLOAT(BytesPerSector);
   IF RoomOnDisk >= FileSize THEN
      CopyFile(SourceFile,TargetFile,FileSize,ErrorCode);
   ELSIF RoomOnNewDisk >= FileSize THEN
      WriteString("Install a new disk, hit return to continue");
      WriteString(", or hit Q to stop backup");
      WriteLn;
      Read(Char);
      IF Char = 'Q' THEN
         EndOfCopy := TRUE;
      ELSE
         INC(DiskNumber);
         WriteString("Beginning disk number ");
         WriteCard(DiskNumber,3);
         WriteLn;
         ChangeToDirectory(WorkingDirectory,TRUE,ErrorRet);
         GetDiskStatistics(TargetDrive,SectorsPerCluster,FreeClusters,
                           BytesPerSector,TotalClusters);
         RoomOnDisk := FLOAT(SectorsPerCluster) *
                       FLOAT(FreeClusters) *
                       FLOAT(BytesPerSector);

         IF RoomOnDisk >= FileSize THEN
            CopyFile(SourceFile,TargetFile,FileSize,ErrorCode);
         ELSE
            WriteString("File too big for this system");
         END;
      END;
   ELSE
      WriteString("File too big for this system");
   END;
END CopyTheFile;



(* This procedure makes the calls to change the directories of both*)
(* the source and target directories.                              *)

PROCEDURE ChangeBothDirectories;
BEGIN
   Insert(SourceDrive,InputLine,0);
   Insert(':',InputLine,1);
   ChangeToDirectory(InputLine,FALSE,ErrorRet);
   IF ErrorRet THEN
      WriteString(InputLine);
      WriteString("  Cannot change to source directory");
      WriteLn;
   END;
   InputLine[0] := TargetDrive;
   WorkingDirectory := InputLine;
   ChangeToDirectory(InputLine,TRUE,ErrorRet);
   IF ErrorRet THEN
      WriteString(InputLine);
      WriteString("  Cannot change to target directory");
      WriteLn;
   END;
END ChangeBothDirectories;



BEGIN (* Main program *)
   DiskNumber := 1;
   EndOfCopy := FALSE;
   WriteString("Enter the target drive, one letter ---> ");
   Read(TargetDrive);
   TargetDrive := CAP(TargetDrive);
   Write(TargetDrive);
   WriteLn;
   WriteString("Beginning disk number   1");
   WriteLn;
   GetDiskStatistics(TargetDrive, SectorsPerCluster, FreeClusters,
                     BytesPerSector, TotalClusters);
   IF BytesPerSector > 0 THEN                 (* Valid drive found *)
      RoomOnNewDisk := FLOAT(SectorsPerCluster) *
                       FLOAT(TotalClusters) *
                       FLOAT(BytesPerSector);
      Copy("C:\FULLDISK.LST",0,100,SourceFile);
      CurrentDrive(SourceDrive);       (* Get current drive letter *)
      SourceFile[0] := SourceDrive;  (* Open FULLDISK.LST for read *)
      Lookup(InputFile,SourceFile,FALSE);
      IF InputFile.res = done THEN
         LOOP
            ReadALine;
            IF InputFile.eof THEN
               EXIT;
            ELSE
               IF InputLine[0] = ' ' THEN              (* Filename *)
                  CopyTheFile;
                  IF EndOfCopy THEN EXIT END;
               ELSIF InputLine[0] = 000C THEN
                              (* Empty line, not a directory entry *)
               ELSE                                   (* Directory *)
                  ChangeBothDirectories;
                  WriteString(" Directory ---> ");
                  WriteString(InputLine);
                  WriteLn;
               END
            END;
         END; (* LOOP *)
         Close(InputFile);
      ELSE
         WriteString("FULLDISK.LST not available for reading.");
         WriteLn;
         WriteString("Program terminated");
         WriteLn;
      END;
      WriteString("End of Backup copy program");
      WriteLn;
   END; (* Drive test *)
END BakCopy.

