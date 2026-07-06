(*$A+*) (*$F-*)
MODULE Format;

FROM SYSTEM  IMPORT ADDRESS, ADR;
FROM Storage IMPORT ALLOCATE, DEALLOCATE, CreateHeap;

IMPORT GEMDOS, XBIOS;

FROM SYSCIO  IMPORT Read, GoToXY, Write, WriteString, WriteInt, WriteCard;

CONST SectorsPerTrack=  9;

VAR InitialData,
    Drive,
    Track,
    Side, MaxSide,
    InterLeave:         CARDINAL;

    FmtBuffer:          ADDRESS;
    BootSector:         ADDRESS;

    IRetCode:           INTEGER;

    CReply:             CHAR;

PROCEDURE Halt;

BEGIN (* Halt *)

  CursorOff;

  IF NOT GEMDOS.Term(1)
     THEN HALT;
  END;

END Halt;

PROCEDURE ClearScreen;

BEGIN (* ClearScreen *)

  Write(CHR(27)); Write('E');

END ClearScreen;

PROCEDURE CursorOn;

BEGIN (* CursorOn *)

  Write(CHR(27)); Write('e');

END CursorOn;

PROCEDURE CursorOff;

BEGIN (* CursorOff *)

  Write(CHR(27)); Write('f');

END CursorOff;

PROCEDURE FormatDisk;

BEGIN (* FormatDisk *)

  CursorOn;

  GoToXY(01, 01); WriteString('Enter the drive (A/B)............... ');
                  REPEAT Read(CReply);
                         IF CReply = CHR(03)
                            THEN Halt;
                            ELSIF (CAP(CReply) # 'A') AND
                                  (CAP(CReply) # 'B')
                                  THEN Write(CHR(07));
                         END;
                  UNTIL (CAP(CReply) = 'A') OR
                        (CAP(CReply) = 'B');
                  Write(CAP(CReply));

  Drive := ORD(CAP(CReply)) - ORD('A');

  GoToXY(01, 02); WriteString('Enter the number of sides (1/2)..... ');
                  REPEAT Read(CReply);
                         IF CReply = CHR(03)
                            THEN Halt;
                            ELSIF (CAP(CReply) # '1') AND
                                  (CAP(CReply) # '2')
                                  THEN Write(CHR(07));
                         END;
                  UNTIL (CAP(CReply) = '1') OR
                        (CAP(CReply) = '2');
                  Write(CAP(CReply));

  MaxSide := ORD(CAP(CReply)) - ORD('1');

  GoToXY(01, 03); WriteString('Enter the sector interleaving (1..9) ');
                  REPEAT Read(CReply);
                         IF CReply = CHR(03)
                            THEN Halt;
                            ELSIF (CAP(CReply) < '1') OR
                                  (CAP(CReply) > '9')
                                  THEN Write(CHR(07));
                         END;
                  UNTIL (CAP(CReply) >= '1') AND
                        (CAP(CReply) <= '9');
                  Write(CAP(CReply));

  InterLeave := ORD(CAP(CReply)) - ORD('0');

  CursorOff;

  GoToXY(01, 05); WriteString('Track Side Error');

  FOR Track := 0 TO 79 DO
      FOR Side := 0 TO MaxSide DO
          IF Track < 2
             THEN InitialData := 0000H;
             ELSE InitialData := 00E5H;
          END;
          IRetCode := XBIOS.FloppyFormat(FmtBuffer,
                                         Drive, SectorsPerTrack,
                                         Track, Side, InterLeave,
                                         InitialData);
          GoToXY(12, 07); WriteInt(IRetCode, 5);
          GoToXY(07, 07); WriteCard(Side,    4);
      END;
      GoToXY(01, 07); WriteCard(Track, 5);
  END;

  XBIOS.PrototypeBootSector(BootSector, 10000000H, MaxSide + 2, 0);

  GoToXY(01, 09);

  WriteString('Writing BootSector, Return Code is');

  IRetCode := XBIOS.FloppyWrite(BootSector, Drive, 1, 0, 0, 1);

  WriteInt(IRetCode, 7);

END FormatDisk;

BEGIN (* Format *)

  IF CreateHeap(1024 * 64, TRUE)
     THEN ALLOCATE(FmtBuffer, 16384);
          IF (LONGCARD(FmtBuffer) MOD 4) # 0
             THEN FmtBuffer := ADDRESS(LONGCARD(FmtBuffer) +
                                       (4 - (LONGCARD(FmtBuffer) MOD 4)));
          END;
          ALLOCATE(BootSector, 2048);
          IF (LONGCARD(BootSector) MOD 4) # 0
             THEN BootSector := ADDRESS(LONGCARD(BootSector) +
                                       (4 - (LONGCARD(BootSector) MOD 4)));
          END;
          REPEAT ClearScreen;
                 FormatDisk;
                 GoToXY(01, 11); WriteString('Format another floppy? (y/n) ');
                                 CursorOn; Read(CReply); CursorOff;
                 Write(CAP(CReply));
          UNTIL CAP(CReply) # 'Y';
  END;

END Format.
