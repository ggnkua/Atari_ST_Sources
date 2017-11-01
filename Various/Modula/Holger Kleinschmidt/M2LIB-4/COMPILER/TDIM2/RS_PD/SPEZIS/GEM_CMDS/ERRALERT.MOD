MODULE ErrAlert;    (* Trafo of Th.Otto's Alert-ACC to M2 & few extensions.*)
(* ½ 1996 by ROLF SCHRADER.                             * 24.2.96 + 4.3.96 *)
(*$Q+,$T-,$S- no checks.*)

IMPORT AEB, AEM,AEZ, (* FSel, *) SX, BIOX, GDB, FoFi, MiNz;
FROM   AEB  IMPORT IG,LI,BS, ARR, MSG,TIC, ACCOPEN;
FROM   MiNz IMPORT RDWR, ALLOW,CREAT,TRUNF, NDELAY, FSETFD;

CONST  SELT = " Choose Error-Dump-File: ";
       DUMP = "ERRALERT.DMP";
       MAXL = 1024;

TYPE   ALST = ARRAY [0..MAXL] OF CHAR;
       PATH = ARRAY [0.. 064] OF CHAR;

VAR    ApId,vMiNT:  IG;
       MyOwnName:   SX.S12;
       Drive:       CHAR;
       InP, InS,
       AlDump:      PATH;

PROCEDURE Init;
   VAR val: LI;
 BEGIN IF (0 > BIOX.GetCookie ("MiNT", val)) THEN vMiNT := 0;
       ELSE vMiNT := SHORT (val) END;
(**)   GDB.GetAbsPath (InP); SX.Apd (InP, "\*.*"); InS := DUMP;
       AlDump := DUMP; Drive := InP[0] (* 0c *);
   ApId := AEB.ApplInit ();
(* FSel.Accredit (AlDump, "",DUMP, SELT, 0); *)
   AEB.GrafMouseDef (ARR);
   AEB.ApplName (MyOwnName); END Init;

PROCEDURE Join (n: LI; VAR Buf: ARRAY OF CHAR);
   VAR b: IG;
 BEGIN AEZ.WindUpd (+AEB.UPDATE);
       IF (n # GDB.Join (AlDump, n, SX.Adr(Buf))) THEN
         b := AEB.FormAlert (1, "[1][| Could not dump error!][  Ugh  ]") END;
       AEZ.WindUpd (0);
       AEM.ShellUpd (Drive); END Join;

PROCEDURE DoIt;
   VAR PipeFd, apid, MenuId, b,c: IG; Sens: AEB.EvSensor; Msg: AEB.MsgPipeR;
       WhyNot: SX.STR; isACC, RtxFound: BOOLEAN; Eve: BS; AlBuf: ALST;
 BEGIN WhyNot := "";   isACC := AEB.ApplIsAcc ();  (* PipeFd := -1; *)
       RtxFound := (AEB.Global.Count # 1);
   IF ( ~ isACC & ~ RtxFound) THEN
        b := AEB.FormAlert (1, "[1][| I can run only as an ACC! ][ Abort ]");
        RETURN;
   ELSE apid := AEB.ApplFind (MyOwnName) END;
   IF  (apid >= 00) & (apid # ApId) THEN (* Application is already running.*)
        AEB.A4 (Msg, ACCOPEN, ApId, 0,0);
        AEB.A4 (Msg.Area, 0,0,0,0);
        AEB.ApplWrite (apid, 16, Msg);
        IF ~ isACC OR RtxFound THEN RETURN END;
        WhyNot := "[1][| Acc. double not installed! ][   Ugh   ]"; END (*I*);
   MenuId := AEB.MenuRegist (ApId, "  M's Error Alerts ");
   IF (vMiNT <= 0) THEN                        (* MiNT missing - you loose.*)
        WhyNot := "[1][| MiNT is not running! ][  Exit  ]";
   ELSE PipeFd := MiNz.Fopen ("U:\PIPE\ALERT",RDWR+CREAT+TRUNF+NDELAY+ALLOW);
     IF PipeFd < 0 THEN
        WhyNot := "[1][| Couldn't create Alert pipe! ][  Exit  ]";
     ELSIF (PipeFd < 6) OR (PipeFd > 31) THEN (* Kommt dies berhaupt vor? *)
            b := GDB.Close (PipeFd);
        WhyNot := "[1][| File descriptor out of range! ][  Exit  ]"; END END;
   IF  (WhyNot[0] # 0c) THEN
     IF ~ isACC THEN b := AEB.FormAlert (1, WhyNot); RETURN;
     ELSE LOOP AEB.EventMessage (Msg);
            IF (Msg.Type = ACCOPEN) THEN b := AEB.FormAlert (1, WhyNot) END;
            END END END (*L,E,I*);
(* Cause Acc running now, the file's owner is GEM, hence we must clear the *)
(*  close-on-exec flag, or GEM will raise a BUS-Error when executing progs.*)
   MiNz.Fcntl (PipeFd, 0, FSETFD);
   AlBuf := "";
   AEB.Ae (Sens, {MSG,TIC}, 0,0,0, 0,0,0,0,0, 0,0,0,0,0, 500,0);
   LOOP Eve := AEB.EventMulti (Sens);
     IF (TIC IN Eve) THEN c := SHORT (GDB.ReadN (PipeFd, MAXL, AlBuf));
        IF (c >1) & (AlBuf[0] = '[') & (AlBuf[c-2] = ']') & (AlBuf[c-1] = 0c)
        THEN b := AEB.FormAlert (1, AlBuf);  Join (LONG (c), AlBuf) END; END;
     IF (MSG IN Eve) & (Sens.Msg.Type = ACCOPEN) THEN
        IF (AlBuf[0] # 0c) THEN b := AEB.FormAlert (1, AlBuf);
(*      ELSIF (1 = FSel.ExInput (AlDump)) THEN Drive := AlDump[0]; *)
        ELSIF (1 = AEB.FSelInput (SELT, InP,InS)) THEN SX.Asg (AlDump, InP);
          FoFi.WagTail (AlDump, InS, FALSE,FALSE); Drive := InP[0];
          END END END (*E,I,Ananta*); END DoIt;


BEGIN Init; DoIt; AEB.ApplExit END ErrAlert .
