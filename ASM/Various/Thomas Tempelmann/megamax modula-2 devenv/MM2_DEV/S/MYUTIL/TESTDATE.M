MODULE TestDate;

  (* Test-Module fÅr 'DateUti'. *)
  
  FROM InOut IMPORT ReadCard, WriteCard, Read, WriteString, WriteLn,
                    WriteInt;
  
  FROM DateUti IMPORT WkDayType, mkDate, WeekDay, AddDays, DaysBetween;
  
  VAR
    d1 : mkDate;
    d2 : mkDate;
    wd : WkDayType;
    c  : CHAR;
    
BEGIN
  REPEAT
    WriteLn;
    WriteLn;
    WriteString ('Tag 1   := ');
    ReadCard (d1.day);
    WriteString ('Monat 1 := ');
    ReadCard (d1.month);
    WriteString ('Jahr 1  := ');
    ReadCard (d1.year);
    WriteLn;
    WriteString ('Tag 2   := ');
    ReadCard (d2.day);
    WriteString ('Monat 2 := ');
    ReadCard (d2.month);
    WriteString ('Jahr 2  := ');
    ReadCard (d2.year);
    
    WriteLn;
    WriteInt (DaysBetween (d1, d2), 1);
    WriteString (' Tage sind dazwischen.');
    WriteLn;
    
    WriteString ('Das 1. Datum plus 100 Tage ergibt den ');
    d1 := AddDays (d1, 100);
    WriteCard (d1.day, 1);
    WriteString ('.');
    WriteCard (d1.month, 1);
    WriteString ('.');
    WriteCard (d1.year, 1);
    WriteString ('.');
    WriteLn;
    WriteString ('Der ');
    WriteCard (d1.day, 1);
    WriteString ('.');
    WriteCard (d1.month, 1);
    WriteString ('.');
    WriteCard (d1.year, 1);
    WriteString (' ist ein ');
    
    CASE WeekDay (d1) OF
      mon : WriteString ('Montag')|
      tue : WriteString ('Dienstag')|
      wed : WriteString ('Mittwoch')|
      thu : WriteString ('Donnerstag')|
      fri : WriteString ('Freitag')|
      sat : WriteString ('Samstag')|
      sun : WriteString ('Sonntag')|
    END;
    WriteString ('.');
    WriteLn;
    WriteLn;
    WriteString ('Nochmal (j,n) ? ');
    Read (c);
  UNTIL (c = 'n');
END TestDate.
(* $FFF81D90$FFF81D90$FFF81D90$FFF81D90$FFF81D90$FFF81D90$FFF81D90$FFF81D90$FFF81D90$FFF81D90$FFF81D90$FFF81D90$FFF81D90$FFF81D90$FFF81D90$0000053C$FFF81D90$FFF81D90$FFF81D90$FFF81D90$FFF81D90$FFF81D90$FFF81D90$FFF81D90$FFF81D90$FFF81D90$FFF81D90$FFF81D90$FFF81D90$FFF81D90$FFF81D90$FFF81D90$FFF81D90$FFF81D90$FFF81D90$FFF81D90$FFF81D90$FFF81D90$FFF81D90$FFF81D90$FFF81D90$FFF81D90Ä$000002F7T.T.T.T.T.T.T.T.T.T.T.T.T.......................................................$0000053F$00000382$0000045B$00000523$0000067B$000002F7$00000480$FFF81D90$00000681$0000058D$000005B8$000005DD$00000603$0000062C$00000651$0000067BòÄÄ*)
