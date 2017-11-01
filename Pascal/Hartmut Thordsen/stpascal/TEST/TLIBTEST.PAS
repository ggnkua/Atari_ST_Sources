PROGRAM time_library_test;  { V1.0 Hartmut Thordsen, Maerz 1987 }

VAR h, m, sec	       : INTEGER;
    time, time1, time2 : REAL;
    s		       : STRING;

{$I lib\timelib.inc}

PROCEDURE write_b (b : BOOLEAN);
BEGIN
IF b
  THEN write(' TRUE  ')
  ELSE write(' FALSE ');
END;

BEGIN
time := get_time;
  writeln ('GET_TIME (Systemzeit als Real) : ', time:10:4);
hms_time (23,45,56,time1);
  writeln ('HMS_TIME codiert 23:45:56 : ', time1:10:4);
h := 0; m := 0; sec := 0;
time_hms (time1,h,m,sec);
  writeln ('...und mit TIME_HMS decodiert : Stunden=',
  h, ' Minuten=', m, ' Sekunden=', sec);
set_time (time1);
  time2 := get_time;
  writeln ('mit SET_TIME gesetzt, GET_TIME ergibt : ', time2:10:4);
set_time (time);
  time2 := get_time;
  writeln ('SET_TIME alte Zeit, GET_TIME ergibt : ', time2:10:4);
  writeln (' SYSTIME_TIME und TIME_SYSTIME werden im Test');
  writeln (' durch den Erfolg von GET_TIME und SET_TIME bestaetigt.');
time := time_dec (time);
  writeln ('mit TIME_DEC in eine Dezimalzahl umgewandelt : ', time:10:4);
time := dec_time (time);
  writeln ('mit DEC_TIME wieder in eine Zeit hh.mmss	 : ', time:10:4);
time2 := add_time (time, time1);
  writeln ('ADD_TIME von Systemzeit und 23:45:56   : ', time2:10:4);
time2 := sub_time (time1, time);
  writeln ('SUB_TIME von 23:45:56 und Systemzeit   : ', time2:10:4);
time2 := sub_time (time, time1);
  writeln ('SUB_TIME von Systemzeit und 23:45:56   : ', time2:10:4);
time2 := sub_time (-35.1853,-13.2517);
  writeln ('SUB_TIME von -35:18:53 und -13:25:17   : ', time2:10:4);
writeln ('Weiter mit ENTER.'); readln(s); write (chr(27),'E');

writeln ('TIME_STR mit width 3, 7, 10:');
  time_str(time,3,s);	  writeln('*',s,'*');
  time_str(time,7,s);	  writeln('*',s,'*');
  time_str(time,10,s);	  writeln('*',s,'*');
writeln ('STR_TIME :');
  time1 := 0;
  s:='1347'	 ; write(s); write_b(str_time(s,time1)); writeln(time1:10:4);
  s:='14:48'	 ; write(s); write_b(str_time(s,time1)); writeln(time1:10:4);
  s:='154901'	 ; write(s); write_b(str_time(s,time1)); writeln(time1:10:4);
  s:='16:50:02'  ; write(s); write_b(str_time(s,time1)); writeln(time1:10:4);
  s:='1:12:57'	 ; write(s); write_b(str_time(s,time1)); writeln(time1:10:4);
  s:='2978.19'	 ; write(s); write_b(str_time(s,time1)); writeln(time1:10:4);
  s:='3:19:88'	 ; write(s); write_b(str_time(s,time1)); writeln(time1:10:4);
  s:='17:61:05'  ; write(s); write_b(str_time(s,time1)); write(time1:10:4);
   writeln(' wenn false, dann ist TIME_OK ok.');
  s:='2203110'	 ; write(s); write_b(str_time(s,time1)); writeln(time1:10:4);
  s:='378.67'	 ; write(s); write_b(str_time(s,time1)); writeln(time1:10:4);
  s:='4: 2:01'	 ; write(s); write_b(str_time(s,time1)); writeln(time1:10:4);
writeln ('Weiter mit ENTER.'); readln(s); write (chr(27),'E');
END.
