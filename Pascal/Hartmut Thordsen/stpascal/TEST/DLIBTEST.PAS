PROGRAM date_library_test;  {V2.0 Hartmut Thordsen, Februar 1987 }

VAR t, m, j, diff,
    wday, doy, rem  : INTEGER;
    dat, dat1, dat2 : REAL;
    gestern, heute, morgen : REAL;
    ldat	    : LONG_INTEGER;
    s		    : STRING;

{$I lib\datelib.inc}

PROCEDURE write_b (b : BOOLEAN);
BEGIN
IF b
  THEN write(' TRUE  ')
  ELSE write(' FALSE ');
END;

BEGIN
dat := get_date;
  writeln ('GET_DATE (Systemdatum als real) : ', dat:10:6);
dmy_date (24,12,1987,dat1);
  writeln ('DMY_DATE codiertes Weihnachten ''87 : ', dat1:10:6);
t := 0; m := 0; j := 0;
date_dmy (dat1,t,m,j);
  writeln ('...und mit DATE_DMY decodiert : Tag=',
  t, ' Monat=', m, ' Jahr=', j);
set_date (dat1);
  dat2 := get_date;
  writeln ('mit SET_DATE gesetzt, GET_DATE ergibt : ', dat2:10:6);
set_date (dat);
  dat2 := get_date;
  writeln ('SET_DATE altes Datum, GET_DATE ergibt : ', dat2:10:6);
  writeln (' SYSDATE_DATE und DATE_SYSDATE werden im Test');
  writeln (' durch den Erfolg von GET_DATE und SET_DATE bestaetigt.');
ldat := julian_date(28.081940);
  writeln ('JULIAN_DATE des 28.8.1940 (erwartet 2429870)', ldat);
dat2 := gregorian_date(ldat);
  writeln('...und zurueck mit GREGORIAN_DATE : ', dat2:10:6);
diff := date_difference(dat1,dat);
  writeln ('Tage bis Weihnachten mit DATE_DIFFERENCE : ', diff:6);
  diff := date_difference(dat,dat1);
  writeln ('Tage bis Weihnachten (negativ) : ', diff:6);
wday := weekday(dat1);
  writeln ('WEEKDAY Weihnachten : ', wday:1);
weekday_str (wday,0,s);
  writeln ('WEEKDAY_STR : Weihnachten ist ein ',s,'.');
  weekday_str (wday,2,s);
  write ('2 Zeichen *',s,'*  12 Zeichen *');
  weekday_str (wday,12,s);
  writeln (s,'*');
dat2 := related_date(dat,20);
  date_str(dat2,10,s);
  write ('RELATED_DATE : In 20 Tagen ist der ',s,' ein ');
  weekday_str (weekday(dat2),0,s);
  writeln(s,'.');
doy := day_of_year(dat);
  writeln('DAY_OF_YEAR : Heute ist der ', doy, '. Tag in diesem Jahr.');
dat2 := doy_date(100,1986);
  date_str(dat2,6,s);
  write ('DOY_DATE : Der hundertste Tag in diesem Jahr ist der ',s);
  weekday_str (weekday(dat2),2,s);
  writeln(' (',s,').');
rem := remaining_days(dat);
  writeln('REMAINING_DAYS : In diesem Jahr verbleiben noch ', rem, ' Tage.');
writeln ('Weiter mit ENTER.'); readln(s); write (chr(27),'E');

heute := dat;
gestern := related_date(heute,-1);
morgen := related_date(heute,1);
writeln('Die Boole''schen Funktionen liefern fuer gestern, heute und morgen:');
write ('DATE_EARLIER gestern heute :');
  write_b (date_earlier(gestern,heute));
  writeln;
write ('DATE_EARLIER morgen heute  :');
  write_b (date_earlier(morgen,heute));
  writeln;
write ('DATE_EARLIER heute heute   :');
  write_b (date_earlier(heute,heute));
  writeln;
write('DATE_FUTURE : ');
  write_b (date_future(gestern));
  write_b (date_future(heute));
  write_b (date_future(morgen));
  writeln;
write('DATE_PAST   : ');
  write_b (date_past(gestern));
  write_b (date_past(heute));
  write_b (date_past(morgen));
  writeln;

writeln ('DATE_STR mit width 5, 6, 9, 12:');
  date_str(dat,5,s);	 writeln('*',s,'*');
  date_str(dat,6,s);	 writeln('*',s,'*');
  date_str(dat,9,s);	 writeln('*',s,'*');
  date_str(dat,12,s);	 writeln('*',s,'*');
writeln ('STR_DATE :');
  dat1 := 0;
  s:='250162'	 ; write(s); write_b(str_date(s,dat1)); writeln(dat1:10:6);
  s:='26021963'  ; write(s); write_b(str_date(s,dat1)); writeln(dat1:10:6);
  s:='27.03.64'  ; write(s); write_b(str_date(s,dat1)); writeln(dat1:10:6);
  s:='28.4.1965' ; write(s); write_b(str_date(s,dat1)); writeln(dat1:10:6);
  s:='66/5/29'	 ; write(s); write_b(str_date(s,dat1)); writeln(dat1:10:6);
  s:='1967/06/30'; write(s); write_b(str_date(s,dat1)); writeln(dat1:10:6);
  s:='29.02.1987'; write(s); write_b(str_date(s,dat1)); write(dat1:10:6);
   writeln(' wenn false, dann sind DATE_OK und DATE_EQUAL ok.');
  s:='2903870'	 ; write(s); write_b(str_date(s,dat1)); writeln(dat1:10:6);
  s:='29.021987' ; write(s); write_b(str_date(s,dat1)); writeln(dat1:10:6);
  s:='88/10 01'  ; write(s); write_b(str_date(s,dat1)); writeln(dat1:10:6);
writeln ('Weiter mit ENTER.'); readln(s); write (chr(27),'E');
END.
