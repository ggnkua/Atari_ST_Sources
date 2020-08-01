MODULE TimeDate;

(* Note - DOSCALL calls interrupt 21(hex) = 33(dec) which is the   *)
(*        general purpose BIOS interrupt.  It is used for many     *)
(*        operations on the disks, and other peripherals.  See     *)
(*        your DOS manual for details.  Some DOS manuals don't     *)
(*        have any information on this so your next best bet is    *)
(*        Peter Norton's book "Programmers Guide to the IBM-PC.    *)

FROM SYSTEM IMPORT DOSCALL;
FROM InOut IMPORT WriteString, WriteCard, WriteLn;

VAR MonthDay, Year, Month, Day        : CARDINAL;
    HourMinute, SecondMillisec        : CARDINAL;
    Hour, Minute, Second, Millisecond : CARDINAL;
    Index, Count, Stuff               : CARDINAL;

BEGIN
   FOR Index := 1 TO 15 DO

      DOSCALL(2AH,Year,MonthDay);    (* Year is alone in a word    *)
      Month := MonthDay DIV 256;     (* Month is in top half       *)
      Day := MonthDay MOD 256;       (* Day is in bottom half      *)

      DOSCALL(2CH,HourMinute,SecondMillisec);
      Hour := HourMinute DIV 256;
      Minute := HourMinute MOD 256;
      Second := SecondMillisec DIV 256;
      Millisecond := 10*(SecondMillisec MOD 256); (* actually this *)
                                    (* is in hundredths of seconds *)

      WriteString("The time is ");
      WriteCard(Hour,2);
      WriteString(":");
      WriteCard(Minute,2);
      WriteString(":");
      WriteCard(Second,2);
      WriteString(":");
      WriteCard(Millisecond,3);
      WriteString("   ");
      WriteCard(Month,2);
      WriteString("/");
      WriteCard(Day,2);
      WriteString("/");
      WriteCard(Year,4);
      WriteLn;

               (* The following loop takes about one second to  *)
               (* finish its full count on an IBM-PC at normal  *)
               (* speed.  It may vary in time for your system.  *)

      FOR Count := 1 TO 13300 DO
         Stuff := 32000 DIV Count;
      END;
   END;
END TimeDate.
