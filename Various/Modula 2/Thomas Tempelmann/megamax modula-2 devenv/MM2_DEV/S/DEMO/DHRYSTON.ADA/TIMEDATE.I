IMPLEMENTATION MODULE TimeDate ;(*$R-,S-*)

FROM XBIOS      IMPORT SuperExec;
FROM SYSTEM     IMPORT ADDRESS;

VAR hz200: LONGCARD;

PROCEDURE readTimer;
  VAR p: POINTER TO LONGCARD;
  BEGIN
    p:= ADDRESS (04BAH);  (* Adr. des 200 Hz-Timers beim ST *)
    hz200:= p^
  END readTimer;

PROCEDURE Clock (VAR Time: LONGINT);
  (* Diese Funktion liest den 200 Hz-Timer des ST aus *)
  BEGIN
    SuperExec (readTimer);
    Time:= hz200
  END Clock;

END TimeDate.
