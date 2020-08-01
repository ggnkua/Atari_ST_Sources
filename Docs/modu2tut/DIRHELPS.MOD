IMPLEMENTATION MODULE DirHelps;

(*           Copyright (c) 1987 - Coronado Enterprises             *)

FROM InOut      IMPORT WriteString,Write,WriteLn;
FROM FileSystem IMPORT Lookup, Close, File, Response,
                       ReadNBytes, WriteNBytes;
FROM SYSTEM     IMPORT AX,BX,CX,DX,DS,SWI,GETREG,SETREG,
                       ADDRESS,ADR;

VAR DiskTransAdr : ARRAY[1..43] OF CHAR;         (* Must be Global *)

(*******************************************************************)
PROCEDURE ReadFileStats(FileName      : ARRAY OF CHAR;
                        FirstFile     : BOOLEAN;
                        VAR FilePt    : FileDataPointer;
                        VAR FileError : BOOLEAN);

VAR MaskAddr     : ADDRESS;
    Error        : CARDINAL;
    Index        : CARDINAL;
BEGIN
   IF FirstFile THEN
      FOR Index := 1 TO 43 DO                 (* Clear out the DTA *)
         DiskTransAdr[Index] := " ";
      END;

      SETREG(AX,01A00H);       (* Set up the Disk Transfer Address *)
      MaskAddr := ADR(DiskTransAdr);
      SETREG(DS,MaskAddr.SEGMENT);
      SETREG(DX,MaskAddr.OFFSET);
      SWI(021H);

      MaskAddr := ADR(FileName);
      SETREG(AX,04E00H);                         (* Get first file *)
      SETREG(DS,MaskAddr.SEGMENT);
      SETREG(DX,MaskAddr.OFFSET);
      SETREG(CX,017H);                  (* Attribute for all files *)
      SWI(021H);
   ELSE
      SETREG(AX,04F00H);                   (* Get additional files *)
      SWI(021H);
   END;
   GETREG(AX, Error);
   Error := Error MOD 256;                 (* Logical AND with 255 *)
   IF Error = 0 THEN
      FileError := FALSE;  (* Good read, put data in the structure *)
      FOR Index := 0 TO 13 DO    (* Put all blanks in the filename *)
         FilePt^.Name[Index] := ' ';
      END;
      Index := 0;
      REPEAT                            (* Copy filename to record *)
         FilePt^.Name[Index] := DiskTransAdr[Index + 31];
         Index := Index + 1;
      UNTIL (Index > 11) OR (DiskTransAdr[Index + 31] = 000C);
      FilePt^.Name[12] := 000C;               (* ASCIIZ terminator *)

      FilePt^.Attr := ORD(DiskTransAdr[22]);
      FilePt^.Time := 0;                            (* Ignore Time *)
      FilePt^.Date := 0;                            (* Ignore Date *)
      FilePt^.Size := 65536.0 * FLOAT(ORD(DiskTransAdr[29]))
                      + 256.0 * FLOAT(ORD(DiskTransAdr[28]))
                      +         FLOAT(ORD(DiskTransAdr[27]));
      FilePt^.Left := NIL;
      FilePt^.Right := NIL;
   ELSE
      FileError := TRUE;
   END; (* of IF Error = 0 *)

END ReadFileStats;



(*******************************************************************)
PROCEDURE GetDiskStatistics(Drive          : CHAR;
                            VAR SectorsPerCluster : CARDINAL;
                            VAR FreeClusters      : CARDINAL;
                            VAR BytesPerSector    : CARDINAL;
                            VAR TotalClusters     : CARDINAL);
VAR DriveCode : INTEGER;
BEGIN
   DriveCode := INTEGER(ORD(Drive)) - 64;
   IF (DriveCode > 17) OR (DriveCode < 0) THEN
      WriteString("Error - Drive code invalid ---> ");
      Write(Drive);
      WriteLn;
      SectorsPerCluster := 0;
      FreeClusters := 0;
      BytesPerSector := 0;
      TotalClusters := 0;
   ELSE
      SETREG(AX,03600H);
      SETREG(DX,DriveCode);
      SWI(021H);
      GETREG(BX,FreeClusters);
      GETREG(AX,SectorsPerCluster);
      GETREG(CX,BytesPerSector);
      GETREG(DX,TotalClusters);
      IF SectorsPerCluster = 0FFFFH THEN
         WriteString("Error - Drive doesn't exist ---> ");
         Write(Drive);
         WriteLn;
         SectorsPerCluster := 0;
         FreeClusters := 0;
         BytesPerSector := 0;
         TotalClusters := 0;
      END;
   END;
END GetDiskStatistics;




(*******************************************************************)
PROCEDURE ChangeToDirectory(Directory : ARRAY OF CHAR;
                            CreateIt : BOOLEAN;
                            VAR ErrorReturn : BOOLEAN);

VAR MaskAddr : ADDRESS;
    Good     : CARDINAL;

     PROCEDURE CHDIR(Path : ARRAY OF CHAR;
                     VAR Error : CARDINAL);
     BEGIN
        MaskAddr := ADR(Path);
        SETREG(AX,03B00H);
        SETREG(DX,MaskAddr.OFFSET);
        SETREG(DS,MaskAddr.SEGMENT);
        SWI(021H);
        GETREG(AX,Error);
        Error := Error MOD 256;
     END CHDIR;

     PROCEDURE MKDIR(Path : ARRAY OF CHAR;
                     VAR Error : CARDINAL);
     BEGIN
        MaskAddr := ADR(Path);
        SETREG(AX,03900H);
        SETREG(DX,MaskAddr.OFFSET);
        SETREG(DS,MaskAddr.SEGMENT);
        SWI(021H);
        GETREG(AX,Error);
        Error := Error MOD 256;
     END MKDIR;

     PROCEDURE CreateAndChangeDirectory(Directory : ARRAY OF CHAR);
     VAR SubDir  : ARRAY[0..64] OF CHAR;
         Index   : CARDINAL;
         Correct : CARDINAL;
     BEGIN
        Index := 0;
        REPEAT                        (* Find the terminating zero *)
           SubDir[Index] := Directory[Index];
           Index := Index + 1;
        UNTIL (Directory[Index] = 000C) OR (Index = 64);
        SubDir[Index] := 000C;
        REPEAT                            (* Remove a subdirectory *)
           SubDir[Index] := 000C;
           IF Index > 2 THEN
              Index := Index - 1;
           END;
        UNTIL (Index = 2) OR (SubDir[Index] = '\');
        IF Index > 2 THEN
           SubDir[Index] := 000C;          (* Blank out trailing \ *)
        END;
        CHDIR(SubDir,Correct);
        IF (Correct <> 0) AND         (* SubDir Doesn't exist, AND *)
                   (Index > 2) THEN       (* subdirs still in list *)
           CreateAndChangeDirectory(SubDir);
           MKDIR(SubDir,Correct);         (* Make the subdirectory *)
           CHDIR(SubDir,Correct);       (* Change the subdirectory *)
        END;
     END CreateAndChangeDirectory;
BEGIN
   CHDIR(Directory,Good);
   IF Good = 0 THEN                  (* Change to dir if it exists *)
      ErrorReturn := FALSE;
   ELSIF CreateIt THEN              (* Create and change directory *)
      CreateAndChangeDirectory(Directory);
      MKDIR(Directory,Good);
      CHDIR(Directory,Good);
      ErrorReturn := FALSE;
   ELSE                      (* Dir doesn't exist, return an error *)
      ErrorReturn := TRUE;
   END;
END ChangeToDirectory;




(*******************************************************************)
PROCEDURE CopyFile(SourceFile       : ARRAY OF CHAR;
                   DestinationFile  : ARRAY OF CHAR;
                   FileSize         : REAL;
                   VAR ResultOfCopy : CARDINAL);


TYPE BufferType = ARRAY [1..1024] OF CHAR;

VAR InputFile  : File;
    OutputFile : File;
    Buffer     : BufferType;
    BufferPtr  : POINTER TO BufferType;
    BlockSize  : CARDINAL;
    Number     : CARDINAL;
BEGIN
   Lookup(InputFile,SourceFile,FALSE);
   IF InputFile.res = done THEN
      Lookup(OutputFile,DestinationFile,TRUE);
      IF OutputFile.res = done THEN
         BufferPtr := ADR(Buffer[1]);
         WHILE FileSize > 0.0 DO
            IF FileSize > 1024.0 THEN
               BlockSize := 1024;
               FileSize := FileSize - 1024.0;
            ELSE
               BlockSize := TRUNC(FileSize);
               FileSize := 0.0;
            END;
            ReadNBytes(InputFile,BufferPtr,BlockSize,Number);
            WriteNBytes(OutputFile,BufferPtr,BlockSize,Number);
         END;
         ResultOfCopy := 0;                   (* Good copy made *)
         Close(OutputFile);
      ELSE
         ResultOfCopy := 2;        (* Cannot open destination file *)
         WriteString("Unable to open Destination file ---> ");
         WriteString(DestinationFile);
         WriteLn;
      END;
      Close(InputFile);
   ELSE
      ResultOfCopy := 1;
      WriteString("Unable to open Source file ---> ");
      WriteString(SourceFile);
      WriteLn;
   END;
END CopyFile;


BEGIN
END DirHelps.
