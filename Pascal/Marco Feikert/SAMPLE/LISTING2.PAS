(* Kurzes Beispielprogram zum Testen  *)
(* der Sample-Unit                    *)
{$X+}
PROGRAM test_sample;
 
USES gem,sample;

VAR 
    s1, s2, s3: STRING;
    len, i, x: INTEGER;
    freq, m_s: INTEGER;

BEGIN 
  REPEAT
    s1:='';
    s2:='';
(* Sample ausw„hlen *)
    fsel_input(s1,s2,i);
    IF (i<>0) AND (s2<>'') THEN BEGIN 
      len:=LENGTH(s1);
      WHILE COPY(s1,len,1)<>'\' DO
        DEC(len);
      s2:=COPY(s1,1,len)+s2;
(* Laden *)
      x:=sam_load(s2);
      IF x>=0 THEN BEGIN (* Laden erfolgreich *)
(* ACHTUNG: Bei Verwendung von Write's in der *)
(* niedrigen oder mittleren Aufl”sung gibt es *)
(* einen Runtimeerror in Pure Pascal (Version *)
(* 13.Aug) in Verbindung mit NVDI 2.1 !       *)
        write('Frequenz: (0-3):');
        readln(freq);
        write('Stereo/Mono (0-1):');
        readln(m_s);
(* und abspielen *)
        sam_play(x,einmal,freq,m_s);
        sam_free(x);
      END;
    END;
  UNTIL (i=0) OR (s2=''); 
END.
