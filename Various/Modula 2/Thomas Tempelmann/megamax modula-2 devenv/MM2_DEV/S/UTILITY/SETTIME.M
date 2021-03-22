MODULE SetTime;

(*
 * Dies Programm ist nÅtzlich fÅr jeden Atari ohne batteriegepufferte Uhr.
 * Es muû compiliert und gelinkt (nur M2Init.MOD aktivieren, vollst. opti-
 * mieren) werden und in den AUTO-Ordner der Bootdisk oder Harddisk kopiert
 * werden. Beim Kaltstart des Rechners fragt das Programm dann nach der
 * Eingabe von Datum und Zeit. Wird spÑter ein Warmstart (Neustart durch
 * Reset-Knopf) ausgelîst, wird die Zeit automatisch neu gesetzt, ohne daû
 * sie erneut eingegeben werden muû (das geht, weil es zwei Uhren im Rechner
 * gibt und die eine davon nicht gelîscht wird).
 *)

(*$R-,S-  keine FehlerprÅfungen - sind unnîtig *)

FROM SYSTEM IMPORT BYTE, ADDRESS, WORD;

FROM Terminal IMPORT Write, Read, WriteLn, WriteString, ReadString, GotoXY;

FROM Clock IMPORT PackDate, Time, Date, CurrentTime, CurrentDate,
        UnpackDate, GetDateAndTime, SetDateAndTime;

FROM TimeConvert IMPORT TimeToText, DateToText, TextToTime, TextToDate;

FROM Strings IMPORT Empty;

FROM SysUtil1 IMPORT SuperPeek;


TYPE PtrTOSHead = POINTER TO TOSHead;
     TOSHead    = RECORD
                    jmp_instr: WORD;
                    version: CARDINAL;
                    os_init1: ADDRESS;
                    os_start: ADDRESS;
                    unknown: ADDRESS;
                    os_init2: ADDRESS;
                    res_valid: POINTER TO LONGCARD;
                    make_day: BYTE;
                    make_month: BYTE;
                    make_year: CARDINAL;
                    packed_time: CARDINAL;
                    packed_date: CARDINAL;
                  END;

VAR selection: CHAR;
    s: ARRAY [0..31] OF CHAR;
    ok: BOOLEAN;
    th: PtrTOSHead;
    t: Time;
    d: Date;

PROCEDURE enter;
  BEGIN
    LOOP
      WriteLn;
      WriteString ('Datum? ');
      ReadString (s);
      IF Empty (s) THEN RETURN END;
      TextToDate (s,0,d,ok);
      IF ok THEN
        LOOP
          WriteLn;
          WriteString ('Zeit?  ');
          ReadString (s);
          IF Empty (s) THEN EXIT END;
          TextToTime (s,t,ok);
          IF ok THEN
            SetDateAndTime (d,t);
            RETURN
          END
        END;
      END
    END
  END enter;

BEGIN
  WriteLn;
  WriteString ('SetTime von Thomas Tempelmann in Megamax Modula-2');
  GetDateAndTime (d,t);  (* Kbd-Uhr auslesen *)
  SetDateAndTime (d,t);  (* Und GEMDOS-Uhr setzen *)
  SuperPeek ($4F2L, th);  (* Zeiger auf TOS-Header ermitteln *)
  IF (CARDINAL (d.day) = 0)
  OR (CARDINAL (d.month) = 0)
  OR (PackDate (d) <= th^.packed_date) THEN
    (* Uhr noch nicht gestellt -> Eingeben lassen *)
    enter;
  END;
  (* Zuletzt eingestellte Zeit anzeigen *)
  WriteLn;
  DateToText (CurrentDate (), '', s);
  WriteString (s);
  WriteString (' / ');
  TimeToText (CurrentTime (), '', s);
  WriteString (s);
  WriteLn;
END SetTime.
