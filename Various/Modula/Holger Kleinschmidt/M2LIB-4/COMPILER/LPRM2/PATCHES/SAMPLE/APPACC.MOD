MODULE AppAcc;

(* Kann durch Umbenennen sowohl als ACC als auch als Programm
 * ausgefuehrt werden.
 *)
FROM SYSTEM IMPORT ADR;
FROM LPRTERMINATION IMPORT IsAPP;
FROM GEMAESbase IMPORT AccessoryOpen;
FROM AAS IMPORT ApplInitialise, EventMessage, MenuRegister, FormAlert,
                ApplExit, EventTimer;
(* Heisst im Original AES, mein System ist aber fuer die Verwendung von
 * 'crystal' bzw. 'M2GEM' von Ulrich Kaiser gepatched.
 *)

VAR AppId    : INTEGER;
    AccId    : INTEGER;
    AccTitle : ARRAY [0..20] OF CHAR;
    msg      : ARRAY [0..40] OF CHAR;
    mbuf     : ARRAY [0..7] OF INTEGER;
    ret      : INTEGER;

BEGIN
 AppId := ApplInitialise();
 IF IsAPP() THEN
   IF AppId >= 0 THEN
     msg := "[1][Als|Applikation|gestartet][OK]";
     ret := FormAlert(1, msg);
     ApplExit;
   END;
 ELSE
   AccTitle := "  LPR-ACC ";
   AccId    := MenuRegister(AppId, AccTitle);
   IF AccId >= 0 THEN
     msg := "[1][Als|ACC|gestartet][OK]";
     LOOP
       EventMessage(ADR(mbuf));
       IF mbuf[0] = AccessoryOpen THEN
         ret := FormAlert(1, msg);
       END;
     END;
   ELSE
     LOOP
       EventTimer(0, 32000);
     END;
   END;
 END;
END AppAcc.
