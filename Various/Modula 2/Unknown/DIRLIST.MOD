MODULE DirList;

FROM SYSTEM  IMPORT ADR;

FROM Storage IMPORT ALLOCATE, CreateHeap;

IMPORT GEMDOS;

FROM SYSCIO  IMPORT WriteString, WriteLn, Write, Read, GoToXY;

TYPE DirFileAttributes  = (ReadWrite, WriteProt, HiddenEntry, HiddenSystem,
                           Volume, SubDirectory, Archive);
     DirEntryPtr        = POINTER TO DirEntryDef;
     DirEntryDef        = RECORD
       Name:            ARRAY[0..13] OF CHAR;
       Attr:            DirFileAttributes;
       Time:            CARDINAL;
       Date:            CARDINAL;
       Size:            LONGCARD;
       Library:         DirEntryPtr;
       Owner:           DirEntryPtr;
       Back:            DirEntryPtr;
       Next:            DirEntryPtr;
       Left:            DirEntryPtr;
       Right:           DirEntryPtr;
     END;

VAR DirListHead:        DirEntryPtr;
    DirFirst:           DirEntryPtr;
    DirLast:            DirEntryPtr;

    CurrentLibrary:     DirEntryPtr;

PROCEDURE MoveName(VAR To, From : ARRAY OF CHAR);

VAR Len:                CARDINAL;
    i:                  CARDINAL;

BEGIN (* MoveName *)

  Len := HIGH(From);

  IF Len > HIGH(To)
     THEN Len := HIGH(To);
  END;

  FOR i := 0 TO Len DO
      To[i] := From[i];
      IF To[i] = 0C
         THEN RETURN;
      END;
  END;

END MoveName;

PROCEDURE GetNextDirEntry(VAR Entry : DirEntryPtr);

BEGIN (* GetNextDirEntry *)

  IF Entry = NIL
     THEN Entry := DirFirst;
     ELSE Entry := Entry^.Next;
  END;

END GetNextDirEntry;

PROCEDURE GetPrevDirEntry(VAR Entry : DirEntryPtr);

BEGIN (* GetPrevDirEntry *)

  IF Entry = NIL
     THEN Entry := DirLast;
     ELSE Entry := Entry^.Back;
  END;

END GetPrevDirEntry;

PROCEDURE BuildDirList(VAR Name : ARRAY OF CHAR;
                       LibraryLevel : CARDINAL) : BOOLEAN;

VAR DTABuffer:          RECORD
      SysReserved:      ARRAY[0..20] OF CHAR;
      FileAttr:         CHAR;
      Time:             CARDINAL;
      Date:             CARDINAL;
      Size:             LONGCARD;
      DirName:          ARRAY[0..13] OF CHAR;
    END;
    Result:             INTEGER;

  PROCEDURE MakeEntry(VAR Entry      : DirEntryPtr;
                          OwnerEntry : DirEntryPtr);

  BEGIN (* MakeEntry *)

    NEW(Entry);

    WITH Entry^ DO
         MoveName(Name, DTABuffer.DirName);
         Attr    := DirFileAttributes(DTABuffer.FileAttr);
         Time    := DTABuffer.Time;
         Date    := DTABuffer.Date;
         Size    := DTABuffer.Size;
         Library := CurrentLibrary;
         Owner   := OwnerEntry;
         IF Owner = NIL
            THEN DirFirst := Entry;
                 DirLast  := Entry;
                 Back     := NIL;
                 Next     := NIL;
            ELSE IF Entry = Owner^.Left
                    THEN Next        := Owner;
                         Back        := Owner^.Back;
                         Owner^.Back := Entry;
                         IF Back = NIL
                            THEN DirFirst   := Entry;
                            ELSE Back^.Next := Entry;
                         END;
                    ELSE Back        := Owner;
                         Next        := Owner^.Next;
                         Owner^.Next := Entry;
                         IF Next = NIL
                            THEN DirLast    := Entry;
                            ELSE Next^.Back := Entry;
                         END;
                 END;
         END;
         Left  := NIL;
         Right := NIL;
    END;

  END MakeEntry;

  PROCEDURE CompEntries(Entry : DirEntryPtr) : INTEGER;

  VAR i:                CARDINAL;
      DataA, DataB:     CHAR;

  BEGIN (* CompEntries *)

    i := 0;

    LOOP DataA := Entry^.Name[i];
         DataB := DTABuffer.DirName[i];

(* Assumption: 0C is the lowest possible value *)

         IF       DataA < DataB THEN RETURN -1;
            ELSIF DataA > DataB THEN RETURN  1;
            ELSIF DataA = 0C
                  THEN RETURN 0;
                  ELSE INC(i);
                       IF i > 13
                          THEN RETURN 0;
                       END;
         END;
    END;

  END CompEntries;

  PROCEDURE PlaceEntry(VAR Entry : DirEntryPtr;
                           OwnerEntry : DirEntryPtr);

  BEGIN (* PlaceEntry *)

    IF Entry = NIL
       THEN MakeEntry(Entry, OwnerEntry);
       ELSE CASE CompEntries(Entry) OF
              -1 : PlaceEntry(Entry^.Right, Entry);
            |  0 : ;
            |  1 : PlaceEntry(Entry^.Left,  Entry);
            END;
    END;

  END PlaceEntry;

BEGIN (* BuildDirList *)

  DirListHead := NIL;
  DirFirst    := NIL;
  DirLast     := NIL;

  CurrentLibrary := NIL;

  GEMDOS.SetDTA(ADR(DTABuffer));

  GEMDOS.SFirst(Name, CARDINAL(3FH), Result);

  WHILE Result = 0 DO
        WriteString('Read -> '); WriteString(DTABuffer.DirName); WriteLn;
        PlaceEntry(DirListHead, NIL);
        GEMDOS.SNext(Result);
  END;

  IF DirListHead = NIL
     THEN RETURN FALSE;
     ELSE RETURN TRUE;
  END;

END BuildDirList;

PROCEDURE ClrScr;

BEGIN (* ClrScr *)

  Write(CHR(27)); Write('E');

END ClrScr;

VAR Entry:              DirEntryPtr;
    Reply:              CHAR;
    EntryCount:         CARDINAL;
    i:                  CARDINAL;

BEGIN (* DirList *)

  IF NOT CreateHeap(256 * 1024, TRUE)
     THEN HALT;
  END;

  IF BuildDirList('D:*.*', 0)
     THEN ClrScr;
          Entry := NIL;
          EntryCount := 0;
          GetNextDirEntry(Entry);
          WHILE Entry # NIL DO
                i := 0;
                WHILE (Entry^.Name[i] # 0C) AND
                      (i < 14)              DO
                      Write(Entry^.Name[i]);
                      INC(i);
                END;
                INC(EntryCount);
                IF (EntryCount MOD 4) = 0
                   THEN WriteLn;
                   ELSE WHILE i < 20 DO
                              Write(' '); INC(i);
                        END;
                END;
                GetNextDirEntry(Entry);
          END;
  END;

  Read(Reply);

END DirList.
