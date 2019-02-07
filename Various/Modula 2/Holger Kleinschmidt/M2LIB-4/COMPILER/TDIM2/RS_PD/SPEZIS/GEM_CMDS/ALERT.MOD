MODULE Alert;  (* šbersetzung des Alert-ACCs von Thorsten Otto nach Modula.*)
(* ½ 1996 by ROLF SCHRADER. * 21.2.96 *)
(*$T-,$S-,$Q+*)

IMPORT AEB, SX, BIOX, GDB, MiNT;
FROM   AEB   IMPORT IG,LI,BS, MSG,TIC, ACCOPEN;
FROM   MiNT  IMPORT RDWR, ALLOW, CREAT,TRUNF,NDELAY, FSETFD;

CONST  MAXSTRLEN = 1024;
TYPE   ALERT = ARRAY [0..MAXSTRLEN] OF CHAR;
VAR    ApId, vMiNT: IG;

PROCEDURE Init;
   VAR val: LI;
 BEGIN IF (0 > BIOX.GetCookie ("MiNT", val)) THEN vMiNT := 0;
       ELSE vMiNT := SHORT (val) END;
   ApId := AEB.ApplInit (); END Init;

PROCEDURE DoIt;
   VAR PipeFd, apid, MenuId, b,c: IG; Sens: AEB.EvSensor; Eve: BS;
       WhyNot: SX.STR; AlBuf: ALERT; RtxFound: BOOLEAN; Msg: AEB.MsgPipeR;
 BEGIN WhyNot := ""; PipeFd := -1;
       RtxFound := (AEB.Global.Count # 1);
   IF (~ AEB.ApplIsAcc () & ~ RtxFound) THEN
       b := AEB.FormAlert (1, "[1][| I can only run as an .ACC! ][ Abort ]");
       RETURN;
   ELSE apid := AEB.ApplFind ("ALERT") END;
   IF  (apid >= 0) & (apid # ApId) THEN  (* Application is already running.*)
       AEB.A4 (Msg, ACCOPEN, ApId, 0,0);
       AEB.A4 (Msg.Area, 0,0,0,0);
       AEB.ApplWrite (apid, 16, Msg);
       RETURN; END (*I*);
   MenuId := AEB.MenuRegist (ApId, "  MiNT Alerts ");
   IF (vMiNT <= 0) THEN                        (* MiNT missing - you loose.*)
        WhyNot := "[1][| MiNT is not running! ][  Exit  ]";
   ELSE PipeFd := MiNT.Fopen ("U:\PIPE\ALERT",RDWR+CREAT+TRUNF+NDELAY+ALLOW);
     IF PipeFd < 0 THEN
        WhyNot := "[1][| Couldn't create Alert pipe! ][  Exit  ]";
     ELSIF (PipeFd >= 32) THEN b := GDB.Close (PipeFd);
        WhyNot := "[1][| File descriptor out of range! ][  Exit  ]"; END END;
   IF  (WhyNot[0] # 0c) THEN
     IF ~ AEB.ApplIsAcc () THEN b := AEB.FormAlert (1, WhyNot); RETURN;
     ELSE LOOP AEB.EventMessage (Msg);
            IF (Msg.Type = ACCOPEN) THEN b := AEB.FormAlert (1, WhyNot) END;
            END END END (*L,E,I*);
(* Cause Acc running now, the file's owner is GEM, hence we must clear the *)
(*  close-on-exec flag, or GEM will raise a BUS-Error when executing progs.*)
   MiNT.Fcntl (PipeFd, 0, FSETFD);
   AlBuf := "";
   AEB.Ae (Sens, {MSG,TIC}, 0,0,0, 0,0,0,0,0, 0,0,0,0,0, 500,0);
   LOOP Eve := AEB.EventMulti (Sens);
     IF (TIC IN Eve) THEN c := SHORT (GDB.ReadN (PipeFd, MAXSTRLEN, AlBuf));
        IF (c >1) & (AlBuf[0] = '[') & (AlBuf[c-2] = ']') & (AlBuf[c-1] = 0c)
        THEN b := AEB.FormAlert (1, AlBuf) END; END (*I*);
     IF (MSG IN Eve) & (Sens.Msg.Type = ACCOPEN) THEN
        IF (AlBuf[0] = 0c) THEN
             b := AEB.FormAlert (1, "[1][| No alerts yet... ][   OK   ]");
        ELSE b := AEB.FormAlert (1, AlBuf) END;
        END END (*I,L*); END DoIt;

BEGIN Init; DoIt; AEB.ApplExit END Alert.
