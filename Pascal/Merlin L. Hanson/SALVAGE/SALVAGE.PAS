{A program to aid in the salvage of the text portions of a floppy disk.
Applies to a disk where the directory or FAT tables are trashed.
Phase 1 helps identify, rapidly, which sectors contain text.  Phase two of
the program copies selected sectors to a file on a different disk.

                  Author        : Merlin L. Hanson
                  Genie address : M.L.HANSON
                  Language      : Personal Pascal II
                  Date          : Feb 1990
                  Version       : 1.0   }

PROGRAM Salvage;
(*$I GEMSUBS.PAS*)
TYPE
  C_String = PACKED ARRAY[0..255] OF char;

(*$I AUXSUBS.PAS*)  

PROCEDURE DoIt;
  TYPE
    T1 = PACKED ARRAY[1..512]OF char;
  VAR
    SectorNbr,LastSector,junk : integer;
    MyBuffer  : T1;
    Status    : long_integer;
    S         : string;

{$P-}
  PROCEDURE LoadDisk;
  
    PROCEDURE GetNumberLastSector(VAR N:integer);
      TYPE 
        T1 = ^T2;
        T2 = ARRAY[1..9] OF integer;
      VAR
        MyPtr   : T1;
        liar : RECORD
                 CASE {tagid} integer OF
                   1 : (a : long_integer);
                   2 : (b : T1);
               END {record};    
    
      FUNCTION GetBPB(Device:integer):long_integer;
        {Result is actually a pointer to an integer array in TOS's area.}
        BIOS(7);
        
      BEGIN {getnumberlastsector}
        liar.a := GetBPB(0  {Drive A}  );
        N := liar.b^[7] + liar.b^[8] * 2 - 1;
      END {getnumberlastsector};

    BEGIN {loaddisk}
      junk := DO_ALERT(
        '[0][Load the subject disk|    in drive A:\][ OK ]',1);
      GetNumberLastSector(LastSector);
    END {loaddisk};
{$P+}    

  PROCEDURE ReadOneSector(Sector:integer;  VAR Error:boolean);
    {Read the specified logical sector.  It there is an error
    make one retry. If error on second try, show an error message
    and set the error flag to TRUE.  I noted a lot of errors with my drive
    on the first access after coming up to speed, as though there wasn't 
    a sufficient time allownce. But the error code was -14, Diskette 
    was changed!?}
    VAR
      Retry  : boolean;
    
    FUNCTION RWABS(rwflag:integer; VAR Buffer:T1 ; NbrSectors,RecordNbr,Device:integer)
            : long_integer;
      BIOS(4);
      
    BEGIN {readonesector}  
      Retry := FALSE;
      Error := FALSE;
      REPEAT
        Error :=  RWABS(0      {read sector},
                  MyBuffer,
                  1            {number of sectors},
                  Sector,
                  0            {drive A})      <> 0;
        IF Error 
          THEN
            CASE Retry OF
              TRUE : {This _was_ retry. Error indicator is already set.}
                     WriteLn('Error on reading sector.  BIOS error code :',Error);
              FALSE : Retry := TRUE;   {Try a second time.}
            END {case};  
      UNTIL (NOT Error) OR Retry;      
    END {readonesector};

  PROCEDURE ReadTheFile;
    VAR
      ErrorFlag : boolean;

    PROCEDURE DisplayRecord;
      VAR i:integer;
      BEGIN
        Write(SectorNbr,':');
        FOR i := 1 TO 70 DO
          IF (MyBuffer[i] >= ' ') AND (MyBuffer[i] <= '~')
            THEN Write(MyBuffer[i])
            ELSE Write(' ');
        WriteLn;    
      END {displayrecord};
      
      BEGIN {readthefile}
        junk := DO_ALERT(
          '[0][^S and ^Q control scrolling|       ^C to abort][ Fascinating! ]',1);
        SectorNbr := 0;
        ClrScr;
        WHILE SectorNbr <= LastSector DO
          BEGIN
            ReadOneSector(SectorNbr,ErrorFlag);
            IF NOT ErrorFlag
              THEN DisplayRecord;
            SectorNbr := SectorNbr + 1;
          END {while};    
      END {readthefile};
    
  PROCEDURE CopySectors;
    VAR
      Duplicate : {FILE OF} text;  
      MyError   : boolean;
      SectorNbr,First,Last,i,FileNumber : integer;
 
    PROCEDURE IntegerToString(N:integer; VAR S:string);
      {Convert numbers up to 99 to a 3 character string
      with leading zeros _not_ suppressed.}
      VAR Tens,Units : integer;
      BEGIN
        IF N < 10
          THEN
            BEGIN
              S    := '00';
              S[3] := CHR(N + 48);
            END
          ELSE
            BEGIN
              Tens  := N DIV 10;
              Units := N MOD 10;
              S[1] := '0';
              S[2] := CHR(Tens  + 48);
              S[3] := CHR(Units + 48);
            END;  
        S[0] := CHR(3);  {Give the string a length.}    
      END {integertostring};
           
    PROCEDURE GetOutputFile;
      VAR
        FileName,PathName : path_name;
      BEGIN
        GoToXY(3,29);
        InverseVideo; WriteLn(' Select New file '); NormVideo;
        PathName := 'E:\';
        IntegerToString(FileNumber,FileName);
        FileName := CONCAT(FileName,'.RCV');
        IF GET_IN_FILE(PathName,FileName)
          THEN 
            IF PathName[1] = 'A'
              THEN
                BEGIN
                  junk := DO_ALERT(
                    '[3][Can''t overwrite disk A:\|    Sorry][ Oh, Oh ]',1);
                  HALT;
                END                        
              ELSE REWRITE(Duplicate,FileName)
          ELSE HALT;  {user cancel}
      END {getoutputfile};

    PROCEDURE GetSectorNumbers;
      VAR OK : boolean;
      BEGIN
        REPEAT
          GoToXY(9,34);
          ClrScr;
          GoToXY(6,27);
          Write('First sector to save? ');  ReadLn(First);
          GoToXY(7,27);
          Write('Last  sector to save? ');  ReadLn(Last); 
          OK := (First > 0) AND (Last >= First) AND (Last <= LastSector);
          IF NOT OK THEN junk := DO_ALERT(
            '[0][Unaccptble choices!][ Forgive me ]',1);
        UNTIL OK 
      END {getsectornumbers};
            
    BEGIN {copysectors}
      FileNumber := 1;
      junk := DO_ALERT('[0][Choose CANCEL after the last file][ OK ]',1);
      REPEAT
      ClrScr;        
      GetOutputFile;
      GetSectorNumbers;
      GoToXY(9,35);   WriteLn('Working ...');
      FOR SectorNbr := First TO Last DO
        BEGIN
          ReadOneSector(SectorNbr,MyError);
          IF NOT MyError
            THEN Write(Duplicate,MyBuffer)
            ELSE {writeblanks}
              BEGIN
                FOR i := 1 TO 512 DO MyBuffer[i] := ' ';
                Write(Duplicate,MyBuffer);
              END; 
        END {do};
      junk := DO_ALERT('[0][ File Written ][ OK ]',1);
      FileNumber := FileNumber + 1;
      UNTIL FALSE;  {Exit via file selector CANCEL choice.}  
    END {copysectors};
    
  BEGIN {doit}
    LoadDisk;
    IF DO_ALERT(
      '[2][Read file first?][ Yes | No ]',1) = 1       
      THEN ReadTheFile;
    IF DO_ALERT(
      '[2][Copy sectors to|  another disk?][ Yes | No]',1) = 1
      THEN CopySectors;
  END {doit};

BEGIN  {main}
  IF INIT_GEM >= 0 THEN
    BEGIN
      DoIt;
      EXIT_GEM;
    END;  
END {program}.
(*           ************ program structure ************
   12 PROGRAM Salvage;
   13 (*$I GEMSUBS.PAS*)
   17 (*$I AUXSUBS.PAS*)  
   19 PROCEDURE DoIt;
   29  |PROCEDURE LoadDisk;
   31  | |PROCEDURE GetNumberLastSector(VAR N:integer);
   43  | | |FUNCTION GetBPB(Device:integer):long_integer;
   47  | | |BEGIN {getnumberlastsector}
   52  | |BEGIN {loaddisk}
   59  |PROCEDURE ReadOneSector(Sector:integer;  VAR Error:boolean);
   69  | |FUNCTION RWABS(rwflag:integer; VAR Buffer:T1 ; NbrSectors,RecordNbr,Device:integer)
   73  | |BEGIN {readonesector}  
   92  |PROCEDURE ReadTheFile;
   96  | |PROCEDURE DisplayRecord;
  107  | | |BEGIN {readthefile}
  121  |PROCEDURE CopySectors;
  127  | |PROCEDURE IntegerToString(N:integer; VAR S:string);
  149  | |PROCEDURE GetOutputFile;
  171  | |PROCEDURE GetSectorNumbers;
  187  | |BEGIN {copysectors}
  211  |BEGIN {doit}
  221 BEGIN  {main}                   *)
 
