UNIT M_Time;

INTERFACE

FUNCTION EncodeDate (day, month, year: WORD): WORD;
PROCEDURE DecodeDate (date: WORD; VAR day, month, year: WORD);
FUNCTION DateInNum (date: WORD): LONGINT; 
FUNCTION NumInDate (number: LONGINT): WORD;
PROCEDURE DateString (date: WORD; VAR str: STRING);
FUNCTION DayOfYear (date: WORD): WORD;
FUNCTION WeekOfYear (date: WORD): WORD;
FUNCTION DayOfWeek (date: WORD): WORD;

TYPE Language = (German, English, French);

PROCEDURE NameOfDay (lang: Language; day: WORD; VAR name: STRING);
PROCEDURE NameOfMonth (lang: Language; month: WORD; VAR name: STRING);
FUNCTION EncodeTime (hour, minute, second: WORD): WORD;
PROCEDURE DecodeTime (time: WORD; VAR hour, minute, second: WORD);
FUNCTION TimeInNum (time: WORD): LONGINT;
FUNCTION NumInTime (num: LONGINT): WORD;
PROCEDURE TimeString (time: WORD; VAR str: STRING);

IMPLEMENTATION

USES M_Sys, M_Strings, Basics;


VAR cp: CSTRING;

FUNCTION EncodeDate (day, month, year: WORD): WORD;
BEGIN
 App^.MagicPB^.IntIn[0]:= day;
 App^.MagicPB^.IntIn[1]:= month;
 App^.MagicPB^.IntIn[2]:= year;
 CallMagic (2100);
 EncodeDate:= App^.MagicPB^.IntOut[0];
END (*EncodeDate*);

PROCEDURE DecodeDate (date: WORD; VAR day, month, year: WORD);
BEGIN
 App^.MagicPB^.IntIn[0]:= date;
 CallMagic (2101);
 day:= App^.MagicPB^.IntOut[0];
 month:= App^.MagicPB^.IntOut[1];
 year:= App^.MagicPB^.IntOut[2];
END (*DecodeDate*);

FUNCTION DateInNum (date: WORD): LONGINT; 
BEGIN
 App^.MagicPB^.IntIn[0]:= date;
 CallMagic (2102);
 DateInNum:= App^.MagicPB^.LongOut[0];
END (*DateInNum*);

FUNCTION NumInDate (number: LONGINT): WORD;
BEGIN
 App^.MagicPB^.LongIn[0]:= number;
 CallMagic (2103);
 NumInDate:= App^.MagicPB^.IntOut[0];
END (*NumInDate*);

PROCEDURE DateString (date: WORD; VAR str: STRING);
BEGIN
 App^.MagicPB^.AddrIn[0]:= @cp;
 App^.MagicPB^.IntIn[0]:= date;
 CallMagic (2104);
 str:= StrPas (cp);
END (*DateString*);

FUNCTION DayOfYear (date: WORD): WORD;
BEGIN
 App^.MagicPB^.IntIn[0]:= date;
 CallMagic (2105);
 DayOfYear:= App^.MagicPB^.IntOut[0];
END (*DayOfYear*);

FUNCTION WeekOfYear (date: WORD): WORD;
BEGIN
 App^.MagicPB^.IntIn[0]:= date;
 CallMagic (2106);
 WeekOfYear:= App^.MagicPB^.IntOut[0];
END (*WeekOfYear*);

FUNCTION DayOfWeek (date: WORD): WORD;
BEGIN
 App^.MagicPB^.IntIn[0]:= date;
 CallMagic (2107);
 DayOfWeek:= App^.MagicPB^.IntOut[0];
END (*DayOfWeek*);

PROCEDURE NameOfDay (lang: Language; day: WORD; VAR name: STRING);
BEGIN
 App^.MagicPB^.IntIn[0]:= ORD (lang);
 App^.MagicPB^.IntIn[1]:= day;
 App^.MagicPB^.AddrIn[0]:= @cp;
 CallMagic (2108);
 name:= StrPas(cp);
END (*NameOfDay*);

PROCEDURE NameOfMonth (lang: Language; month: WORD; VAR name: STRING);
BEGIN
 App^.MagicPB^.IntIn[0]:= ORD (lang);
 App^.MagicPB^.IntIn[1]:= month;
 App^.MagicPB^.AddrIn[0]:= @cp;
 CallMagic (2109);
 name:= StrPas(cp);
END (*NameOfMonth*);

FUNCTION EncodeTime (hour, minute, second: WORD): WORD;
BEGIN
 App^.MagicPB^.IntIn[0]:= hour;
 App^.MagicPB^.IntIn[1]:= minute;
 App^.MagicPB^.IntIn[2]:= second;
 CallMagic (2110);
 EncodeTime:= App^.MagicPB^.IntOut[0];
END (*EncodeTime*);

PROCEDURE DecodeTime (time: WORD; VAR hour, minute, second: WORD);
BEGIN
 App^.MagicPB^.IntIn[0]:= time;
 CallMagic (2111);
 hour:= App^.MagicPB^.IntOut[0];
 minute:= App^.MagicPB^.IntOut[1];
 second:= App^.MagicPB^.IntOut[2];
END (*DecodeTime*);

FUNCTION TimeInNum (time: WORD): LONGINT;
BEGIN
 App^.MagicPB^.IntIn[0]:= time;
 CallMagic (2112);
 TimeInNum:= App^.MagicPB^.LongOut[0];
END (*TimeInNum*);

FUNCTION NumInTime (num: LONGINT): WORD;
BEGIN
 App^.MagicPB^.LongIn[0]:= num;
 CallMagic (2113);
 NumInTime:= App^.MagicPB^.IntOut[0];
END (*NumInTime*);

PROCEDURE TimeString (time: WORD; VAR str: STRING);
BEGIN
 App^.MagicPB^.IntIn[0]:= time;
 App^.MagicPB^.AddrIn[0]:= @cp;
 CallMagic (2114);
 str:= StrPas(cp);
END (*TimeString*);

END (*M_Time*).
