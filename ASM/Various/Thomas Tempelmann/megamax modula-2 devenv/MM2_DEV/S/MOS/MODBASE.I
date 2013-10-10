IMPLEMENTATION MODULE ModBase; (* V#236 *)
(*$Y+,V+,P-,C+,R-*)

(*
 * 11.10.87: Release erweitert: Setzt Init-Zustand bei Loaded-Mods zurÅck
 * 15.04.88: CallEnvelopes: kein LinkOut, wenn INTEGER(level) negativ.
 * 14.05.88: ModLoaded: Kann Namen > 8 Zeichen erkennen. Einzige Macke:
 *           Moduldateinamen ohne Suffix sind nicht ladbar. Abhilfe:
 *           Von SplitModName ausgehend muû der 'sfx' immer incl. dem
 *           Punkt verwendet werden und AppendSfx darf in dem Fall
 *           nix anhÑngen.
 * 08.06.88: Body: Abfrage, ob Link-Daten vorhanden sind, sonst Abbruch.
 * 10.06.88: Wenn keine Link-Daten, Terminate-Aufruf
 * 28.08.88: Remove-Routine v. installiertem Modul wird nicht aufgerufen,
 *           wenn dieses gelinkt ist.
 * 30.09.88: CreateList mit Sys; DeleteList nur, wenn Prg nicht resident
 * 21.10.88: Auch ModRefs werden bei Programmende freigegeben
 * 25.10.88: termWsp-Stack von 2000 auf 1000 reduziert; CatchRemoval-Aufruf
 *           und Removal-Info bei Release
 * 05.11.88: Release nach Loader ausgelagert.
 * 09.12.88: RemoveInfo-Aufruf verhindert erneuten ReleaseModule-Aufruf
 * 21.12.88: FreeMod gibt bei Programmende (removal) auch geladene, gelinkte,
 *           Programme vollstÑndig frei.
 * 05.06.89: FreeMod ruft nicht mehr DEALLOCATE fÅr 'client^.codeAddr' auf, da
 *           diese bei Modulen kein eigener Blockanfang ist.
 * 04.07.89: Release / removal Åberarbeitet
 * 27.07.89: Clear nun schnell
 * 12.01.90: AppendSfx & SplitModName nicht mehr exportiert - ModLoaded
 *           verbessert, sodaû nun hoffentlich Probleme mit Laden von
 *           Modulen mit IMP-Suffix behoben sind
 * 25.11.90: Envelopes mit level = -1 werden nun nie automatisch entfernt;
 *           ModLoaded: Beim importierten Modulen wird der Filename nicht
 *           mehr gesucht, sondern nur der echte Name.
 * 04.02.92: 'prepare' erwartet p_bbase/p_dbase nicht mehr in A4/A5 sondern
 *           holt sie nun auf offizielle Art aus der Base Page.
 * 12.12.93: CreateBasePage: 'prgFlags'-Parm neu. Wird ab GEMDOS $19 benutzt.
 * 11.04.95: ExecProcess: Caches werden geflushed. Ist nîtig bei 68040 nach
 *           Relozierung vom Loader.
 *)

FROM SYSTEM IMPORT ASSEMBLER, ADR, WORD, ADDRESS, TSIZE, LONGWORD;

FROM Strings IMPORT Assign, Upper, StrEqual, Length, Append, Empty;

FROM Storage IMPORT SysAlloc, DEALLOCATE;

FROM MOSConfig IMPORT DftSfx, ImpSfx;

FROM MOSCtrl IMPORT PtrPDB, GetPDB, PushPDB, PopPDB, PDB, TermList, EnvList,
  ProcessID, BaseResident, SetProcessState, EnvEntry,
  ActPDB, EnvRoot, CallSub;

FROM SysTypes IMPORT PtrBP;

FROM ResCtrl IMPORT RemovalCarrier, CatchRemoval;

FROM PrgCtrl IMPORT TermCarrier, CatchProcessTerm, TermProcess;

FROM MOSGlobals IMPORT IllegalState, IllegalCall, MemArea, OutOfMemory,
        OutOfStack;

FROM Lists IMPORT SysCreateList, ResetList, AppendEntry, RemoveEntry,
  FindEntry, List, ScanEntries, CurrentEntry, NextEntry, DeleteList,
  PrevEntry, LDir, LCarrier;

IMPORT SystemError;

IMPORT SysInfo;

FROM MOSSupport IMPORT ToSuper, ToUser;

FROM Block IMPORT Clear;

(*
  FROM Terminal IMPORT WriteLn, WriteString, Read;
*)

CONST Trace = FALSE;
      Trace2 = FALSE;

(*$ ? Trace OR Trace2:
  VAR inch: CHAR;
*)

TYPE RemList = POINTER TO RemField;
     RemField = RECORD
                  Call : PROC;
                  Next : RemList
                END;

VAR  error, ok: BOOLEAN;
     termwsp: MemArea;
     pro: ADDRESS;
     LinkedModList: POINTER TO ARRAY [1..65000] OF ModEntry;
     rCarrier: RemovalCarrier;
     tCarrier: TermCarrier;


PROCEDURE callSub2 ( subRoutine: PROC; v,w:WORD; VAR code:INTEGER; VAR wsp: MemArea );
  (*$L-*)
  BEGIN
    ASSEMBLER
        MOVEM.L D3/D4,-(A7)
        MOVE.L  -(A3),A0                ; ^wsp
        MOVE.L  -(A3),D4                ; ^code
        MOVE.W  -(A3),D3                ; w
        MOVE.W  -(A3),D1                ; v
        MOVE.L  -(A3),A1                ; subRoutine
        
        MOVE.L  A3,-(A7)                ; A3 retten
        MOVE.L  A7,A2                   ; alten SP laden zum Retten
        
        MOVE.L  MemArea.bottom(A0),D0   ; neuen SP-Bottom
        BEQ     useOld                  ; alten SP verwenden
        MOVE.L  MemArea.length(A0),D2
        BEQ     useOld                  ; alten SP verwenden
        
        CMPI.L  #20,D2
        BCS     noStack                 ; Stack zu klein
        
        ; neuen SP verwenden
        MOVE.L  D0,A3
        ADD.L   D2,D0
        MOVE.L  D0,A7
        
      useOld
        MOVE.L  A2,-(A7)                ; alten SP retten
        
        MOVE    D1,(A3)+
        MOVE    D3,(A3)+
        MOVE.L  D4,(A3)+
        MOVE.L  D4,A0
        CLR.W   (A0)
        JSR     (A1)
        
        MOVE.L  (A7)+,A7
      rtn0
        MOVE.L  (A7)+,A3
        MOVEM.L (A7)+,D3/D4
        RTS
        
      noStack
        TRAP    #6
        DC.W    OutOfStack       ; out of stack space
        MOVEQ   #OutOfStack,D0
        BRA     rtn0
    END
  END callSub2;
  (*$L+*)


PROCEDURE SplitModName ( REF source: ARRAY OF CHAR;
                         VAR name, sfx: ARRAY OF CHAR ): BOOLEAN;
          (* -> TRUE: Name enthielt Path oder Suffix *)
  (*$L-*)
  BEGIN
    ASSEMBLER
        LINK    A5,#0
        MOVEM.W D3/D4/D5,-(A7)
        
        MOVE    -(A3),D2
        MOVE.L  -(A3),A2        ; ADR (sfx)
        MOVE    -(A3),D1
        MOVE.L  -(A3),A1        ; ADR (name)
        MOVE    -(A3),D0
        MOVE.L  -(A3),A0        ; ADR (source)
        
        MOVEQ   #1,D5
        
        MOVE.L  A0,(A3)+
        MOVE.W  D0,(A3)+
        MOVEM.L D0-D2/A0-A2,-(A7)
        JSR     Length
        MOVEM.L (A7)+,D0-D2/A0-A2
        MOVE    -(A3),D3
        BEQ     ende0
      lupo:
        MOVE.B  -1(A0,D3.W),D4
        CMPI.B  #':',D4
        BEQ     ende0
        CMPI.B  #'\',D4
        BEQ     ende0
        SUBQ    #1,D3
        BNE     lupo
        MOVEQ   #0,D5           ; bisher kein Path o. Suffix
      ende0:
        
        ADDQ    #1,D0
        SUB     D3,D0
        ADDA.W  D3,A0           ; A0 hinter Path
        
        ADDQ    #1,D1
        
        CMPI    #2,D2           ; HIGH (sfx)
        BEQ     OK4
        BHI     OK5
        ADDQ    #1,D2
        BRA     OK6
      OK5:
        CLR.B   3(A2)
      OK4:
        MOVEQ   #3,D2
      OK6:
        
      L1:
        SUBQ    #1,D0
        BCS     EMPTY0
        MOVE.B  (A0)+,D3
        BEQ     EMPTY0
        CMPI.B  #'.',D3
        BEQ     POINT
        SUBQ    #1,D1
        BMI     L1
        MOVE.B  D3,(A1)+        ; Name fÅllen
        BRA     L1
        
      POINT:
        MOVEQ   #1,D5           ; suffix im Namen enthalten
        SUBQ    #1,D0
        BCS     EMPTY0
        MOVE.B  (A0)+,D3
        BEQ     EMPTY0
        SUBQ    #1,D2
        BCS     EMPTY0
        MOVE.B  D3,(A2)+
        BRA     POINT
        
      EMPTY0:
        TST     D1
        BLE     EM1
        CLR.B   (A1)
      EM1:
        TST     D2
        BLE     EM2
        CLR.B   (A2)
      EM2:
        
        MOVE    D5,(A3)+
        MOVEM.W (A7)+,D3/D4/D5
        UNLK    A5
    END
  END SplitModName;
  (*$L=*)

PROCEDURE ModLoaded (REF fname: ARRAY OF CHAR; import: BOOLEAN;
                     VAR mname: ARRAY OF CHAR; VAR ref: ModRef): BOOLEAN;
  (*
   * Erkennt, ob 'fname' schon geladen ist.
   * 'fname' kann entw. Modulname sein; dann darf aber kein Suffix dran sein.
   * Sowas immer kommt vor, wenn importierte module nachgeladen werden und
   * es kann vorkommen bei Call/Load/UnloadModule.
   * Wenn 'fname' einen Suffix enthÑlt, kann dies nur von Call/Load/UnloadModule
   * kommen; dann wird angenommen, daû das Modul, falls es schon geladen ist,
   * auch vorher schon unter diesem Namen geladen wurde - dann wird es unter
   * seinem Dateinamen, aber ohne Suffix, gesucht.
   * In 'mname' wird der echte Modulname geliefert, falls Modul
   * gefunden, sonst der Dateiname, der zum Laden geeignet ist.
   *)
  VAR sfx: ARRAY [0..2] OF CHAR; search: SearchDesc;
  BEGIN
    IF NOT SplitModName (fname,mname,sfx) THEN
                                      (* ...Modulname hat keinen Path/Suffix *)
      (* Nach echtem Modnamen (case-less) suchen *)
      search.mname:= ADR (mname);
      search.mode:= modName;
      GetModRef (search,ref);
      IF ref # NIL THEN
        Assign (ref^.codeName^, mname, ok); (* Name m. richtiger G/K-Schreibung *)
        RETURN TRUE
      END;
    END;
    (* bei Importen nicht noch extra nach Dateinamen suchen, weil
     * dies 1. sowieso nicht vorkommen dÅrfte und 2. sonst ggf. beim
     * Start von "MM2Shell" der Import "MM2ShellRsc" hier Åber die
     * Filename-Suche "MM2SHELL" finden wÅrde, was aber das Hauptmodul
     * und nicht etwa das Rsc-Modul wÑre (passiert bei ModLoad: Test,
     * indem MM2Shell gestartet wird. Dann wÅrde die Meldung kommen,
     * daû der Key von "MM2Shell" beim import in "MM2Shell" nicht paût. *)
    IF NOT import THEN
      (* 'mname' enthÑlt nun Dateinamen ohne Path/Suffix *)
      (* Nach Filename (ohne Suffix) suchen *)
      IF HIGH (mname) >= 8 THEN mname [8]:= 0C END;
      search.mode:= fileName;
      search.fname:= ADR (mname);
      GetModRef (search,ref);
      IF ref # NIL THEN
        (* Name des Moduls ermitteln *)
        Assign (ref^.codeName^, mname, ok);
        RETURN TRUE
      END;
    END;
    (* Modul nicht geladen -> in 'mname' Dateinamen zum Laden liefern *)
    IF mname[0] # 0C THEN
      Assign (fname, mname, ok); (* Pfad mit Åbernehmen *)
      IF sfx[0] = 0C THEN
        (* wenn kein Suffix dran war, dann nun "MOD" bzw. "IMP" anhÑngen *)
        Append ('.',mname,ok);
        IF import THEN
          Append (ImpSfx,mname,ok)
        ELSE
          Append (DftSfx,mname,ok)
        END
      END
    END;
    RETURN FALSE
  END ModLoaded;


PROCEDURE LinkOutEnvlp (p:EnvList);
  BEGIN
    ASSEMBLER
        ; next^.prev:= prev;
        ; prev^.next:= next
        MOVE.L  p(A6),A0
        MOVE.L  EnvEntry.next(A0),A1
        MOVE.L  EnvEntry.prev(A0),A2
        MOVE.L  A2,EnvEntry.prev(A1)
        MOVE.L  A1,EnvEntry.next(A2)
    END
  END LinkOutEnvlp;

PROCEDURE CallEnvelopes (start:BOOLEAN;new:BOOLEAN):INTEGER;
  VAR p, pn: EnvList; res: INTEGER;
  BEGIN
    IF start THEN
      p:= EnvRoot.next;
      WHILE p # ADR(EnvRoot) DO
        WITH p^ DO
          IF INTEGER (level) >= 0 THEN INC (level) END;
          callSub2 (call,TRUE,new,res,wsp);
          IF res#0 THEN RETURN res END;
          p := next
        END
      END
    ELSE
      (*$? Trace2: WriteLn; WriteString ('CallEnv '); IF new THEN WriteString ('in') ELSE WriteString ('out') END; *)
      p:= EnvRoot.prev;
      WHILE p # ADR(EnvRoot) DO
        WITH p^ DO
          pn:= prev;
          IF level = 0 THEN
            (*$? Trace2: WriteLn; WriteString ('  LinkOut'); *)
            (* Level der Anmeldung wird beendet *)
            LinkOutEnvlp (p)
          ELSE
            (* das darf nicht gemacht werden, weil sonst ModLoad seine
               Envelopes beim 2. Mal verliert:
              IF level < 0 THEN
                IF ~new THEN level:= 0 END
              ELSE...
            *)
            (*$? Trace2: WriteLn; WriteString ('  call...'); *)
            (* Env.-Start war aufgerufen worden *)
            callSub2 (call,FALSE,new,res,wsp);
            IF INTEGER (level) > 0 THEN DEC (level) END;
            IF res#0 THEN RETURN res END;
          END;
          p:= pn
        END
      END
    END;
    RETURN 0
  END CallEnvelopes;

PROCEDURE MarkState ( client: ModRef; pen: ModState );
  (*$L-*)(*!!! nicht mehr benzutzt:
  VAR j: ModRef; n: CARDINAL;
  BEGIN
    IF client^.imports # NIL THEN
      n:=0;
      LOOP
        j:= client^.imports^[n];
        IF j=NIL THEN EXIT END;
        IF ~(linked IN j^.state) & ~(pen IN j^.state) THEN
          INCL (j^.state,pen);
          MarkState (j,pen)
        END;
        INC (n)
      END
    END
  *)
  (*$L+*)END MarkState;


PROCEDURE FreeMod (VAR client: ModRef);
  VAR bp: PtrBP;
  BEGIN
    IF client # NIL THEN
      IF program IN client^.state THEN
        DEALLOCATE (client^.varRef,0);  (* Data-Save-Bereich freigeben *)
        bp:= client^.codeStart;
        DEALLOCATE (bp^.p_env,0); (* Environment freigeben *)
        DEALLOCATE (bp,0);        (* TPA / Prg. *)
        DEALLOCATE (client,0L)
      ELSIF NOT (linked IN client^.state) THEN
        (*!!!ist unnîtig DEALLOCATE (client^.codeAddr,0L); *)
        DEALLOCATE (client,0L) (* Zuletzt ! Sonst ist Importliste weg *)
      END
    END
  END FreeMod;


PROCEDURE SimpleRelease (VAR client: ModRef; unload, deinstall: BOOLEAN);
  BEGIN
    ASSEMBLER
        TRAP    #6
        DC.W    IllegalState    ; darf nur noch in Loader aufgerufen werden!
    END
  END SimpleRelease;


PROCEDURE FindRef ( ad: ADDRESS; VAR ref: ModRef );
  VAR s:SearchDesc;
  BEGIN
    s.mode:= codeAddr;
    s.addr:= ad;
    GetModRef (s,ref)
  END FindRef;


(*
PROCEDURE IllCall (s:ARRAY OF CHAR);
  (*$L-*)
  BEGIN
    ASSEMBLER
        MOVE    -(A3),D0
        MOVE.L  -(A3),A0
        BRA     c
        
      m ACZ     'ModCtrl'
      n ACZ     'Illegal call'
      o
      c LEA     m(PC),A1
        MOVE.L  A1,(A3)+
        MOVE    #n-m-1,(A3)+
        MOVE.L  A0,(A3)+
        MOVE    D0,(A3)+
        LEA     n(PC),A1
        MOVE.L  A1,(A3)+
        MOVE    #o-n-1,(A3)+
        JSR     SystemError
    END;
  END;
  (*$L+*)
*)

(*
        Criterion = ( modName,     (* Suche nach Modulname *)
                      codeAddr,    (* Suche bez. einer Code-Adresse *)
                      varAddr,     (* Suche bez. Adr. einer globalen Variablen *)
                      user,        (* Suche nach allen, die "ref" importieren *)
                      loadedMod ); (* Suche nach 'geladenen' Moduln *)

        SearchInfo = RECORD
                       CASE mode: Criterion OF
                          modName:            name: POINTER TO ModStr|
                          codeAddr, varAddr:  addr: ADDRESS|
                          user:               uCnt: ADDRESS;
                                              ref : ModRef|
                          loadedMod:          lCnt: ADDRESS
                        END
                      END;
*)

PROCEDURE Imported (mod0, main: ModRef): BOOLEAN;
  VAR r:ModRef; i:CARDINAL;
  BEGIN
    i:=0;
    IF main^.imports=NIL THEN RETURN FALSE END;
    LOOP
      r:= main^.imports^[i];
      IF r=NIL THEN RETURN FALSE END;
      IF r=mod0 THEN RETURN TRUE END;
      INC (i)
    END
  END Imported;


VAR what: POINTER TO SearchDesc; entry: ModRef;

PROCEDURE scanMod (e, w:ADDRESS): BOOLEAN;
  (*$L-*)
  BEGIN
    ASSEMBLER
        MOVE.L  -(A3),A2        ; what
        MOVE.L  -(A3),A1        ; entry
        CMPI    #modName,SearchDesc.mode(A2)
        BNE     notName
        ; modul-name prÅfen
        MOVE.L  SearchDesc.mname(A2),A0
        MOVE.B  (A0),D0
        CMP.B   ModRef.codeNameUp(A1),D0
        BNE     false
        MOVE.L  A0,(A3)+
        MOVE    #39,(A3)+
        LEA     ModRef.codeNameUp(A1),A0
        MOVE.L  A0,(A3)+
        MOVE    #39,(A3)+
        JMP     StrEqual
      notName
        CMPI    #fileName,SearchDesc.mode(A2)
        BNE     notFile
        ; file-name prÅfen
        MOVE.L  SearchDesc.fname(A2),A0
        MOVE.B  (A0),D0
        CMP.B   ModRef.fileName(A1),D0
        BNE     false
        MOVE.L  A0,(A3)+
        MOVE    #7,(A3)+
        LEA     ModRef.fileName(A1),A0
        MOVE.L  A0,(A3)+
        MOVE    #7,(A3)+
        JMP     StrEqual
      false
        CLR     (A3)+
        RTS
      notFile
        MOVE.L  A2,what
        MOVE.L  A1,entry
    END;
    CASE what^.mode OF
      (* modName:  RETURN StrEqual (entry^.codeNameUp,what^.mname^)| *)
      (* fileName: RETURN StrEqual (entry^.fileName,what^.fname^)| *)
      codeAddr: ok:=  (what^.addr >= entry^.codeStart)
                    & (what^.addr < entry^.codeStart + entry^.codeLen)|
      varAddr:  ok:=  (what^.addr >= entry^.varRef)
                    & (what^.addr < entry^.varRef + entry^.varLen)|
      user: ok:= Imported (what^.ref,entry)|
      loadedMod: ok:= loaded IN entry^.state
    END;
    ASSEMBLER
        MOVE    ok,(A3)+
    END
  END scanMod;
  (*$L=*)

PROCEDURE GetModRef ( VAR what: SearchDesc; VAR ref: ModRef );
  VAR cnt:BOOLEAN; l:List; s:ModStr;
  BEGIN
    cnt:= FALSE;
    l:= ModLst;
    ResetList (l);
    IF (what.mode = user) OR (what.mode = loadedMod) THEN
      cnt:= TRUE;
      IF what.uCnt # NIL THEN
        l.current:= LCarrier (what.uCnt)
      END
    ELSIF (what.mode = modName) OR (what.mode = fileName) THEN
      IF (what.mode = fileName) THEN
        Assign (what.fname^,s,ok)
      ELSE
        Assign (what.mname^,s,ok)
      END;
      Upper (s);
      IF s[0] = 0C THEN
        ref:= NIL;
        RETURN
      END;
      what.mname:= ADR(s)
    END;
    ScanEntries (l, forward, scanMod, ADR (what), ok);
    IF cnt THEN what.uCnt:= ADDRESS (l.current) END;
    ref:= CurrentEntry (l)
  END GetModRef;


PROCEDURE pexec ( mode: CARDINAL; path, com: LONGWORD ): LONGINT;
  (*$L-*)
  BEGIN
    ASSEMBLER
        CLR.L   -(A7)           ; env
        MOVE.L  -(A3),-(A7)     ; com
        MOVE.L  -(A3),-(A7)     ; path / prgflags
        MOVE.W  -(A3),-(A7)     ; mode
        MOVE    #$4B,-(A7)
        TRAP    #1
        ADDA.W  #16,A7
        MOVE.L  D0,(A3)+
    END
  END pexec;
  (*$L=*)

PROCEDURE prepare;
  (*$L-*)
  CONST tpa_hi = 4;
        datastart = 16;
        bssstart  = 24;
  BEGIN
    ASSEMBLER
        MOVE.L  4(A7),A4                ; A4: base page
        MOVE.L  datastart(A4),A5        ; p_dbase = ADDRESS (call)
        MOVE.L  bssstart(A4),A3         ; p_bbase = workSpace.bottom
        
        MOVE.L  #tCarrier,(A3)+
        LEA     termLocal(PC),A0
        MOVE.L  A0,(A3)+
        LEA     termwsp,A0
        MOVE.L  (A0)+,(A3)+
        MOVE.L  (A0),(A3)+
        JSR     CatchProcessTerm
        
        MOVE    #1,(A3)+
        JSR     SetProcessState
        
        MOVE    #1,(A3)+
        MOVE    #1,(A3)+
        JSR     CallEnvelopes
        MOVE    -(A3),D0
        BNE     err2
        
        MOVE    #2,(A3)+
        JSR     SetProcessState
        
        JSR     (A5)    ; p_dbase
        
        CLR     (A3)+
        JMP     TermProcess
      err
        MOVEQ   #OutOfMemory,D0
      err2
        MOVE    D0,(A3)+
        JMP     TermProcess
        
      termLocal
        CLR     (A3)+
        MOVE    #1,(A3)+
        JSR     CallEnvelopes
        MOVE    -(A3),D0
        BNE     err2            ; rekursiver TermProcess-Aufruf
    END
  END prepare;
  (*$L=*)

PROCEDURE Mshrink (addr: ADDRESS; newAmount: LONGCARD): INTEGER;
  (*$L-*)
  BEGIN
    ASSEMBLER
        MOVE.L  -(A3),-(A7)
        MOVE.L  -(A3),-(A7)
        CLR.W   -(A7)
        MOVE    #$4A,-(A7)
        TRAP    #1
        ADDA.W  #12,A7
        MOVE.W  D0,(A3)+
    END
  END Mshrink;
  (*$L=*)

PROCEDURE Mfree (addr: ADDRESS);
  (*$L-*)
  BEGIN
    ASSEMBLER
        MOVE.L  -(A3),-(A7)
        MOVE    #$49,-(A7)
        TRAP    #1
        ADDQ.L  #6,A7
    END
  END Mfree;
  (*$L=*)

PROCEDURE CreateBasePage (VAR bp: PtrBP; stacksize: LONGCARD;
                          name: ADDRESS; prgFlags: LONGWORD): BOOLEAN;
  VAR noStr: CHAR; n, vers: CARDINAL;
  BEGIN
    IF stacksize = 0 THEN
      stacksize:= 64;  (* wg. MiNT 0.92 *)
    END;
    noStr:= 0C;
    bp:= PtrBP (pexec (7, prgFlags, ADR (noStr)));
    IF LONGINT (bp) = -32 THEN
      bp:= PtrBP (pexec (5, name, ADR (noStr)));
    END;
    IF LONGINT (bp)>0L THEN
      IF Mshrink (bp, 256 + stacksize) >= 0 THEN
        WITH bp^ DO
          p_lowtpa:= ADDRESS(bp)+256; (* Ist nur wg. MiNT nîtig *)
          p_hitpa:= p_lowtpa+stacksize; (* hitpa stand am Ende vor Mshrink *)
          Clear (p_lowtpa, stacksize)
        END;
        RETURN TRUE
      ELSE
        Mfree (bp^.p_env);
        Mfree (bp)
      END;
    END;
    RETURN FALSE
  END CreateBasePage;

(*$X+*)
PROCEDURE FlushCPUCache ();
  BEGIN
    ASSEMBLER
        JSR     SysInfo.CPU
        SUBQ.L  #4,A7
        JSR     ToSuper
        MOVE.L  -(A3),D0
        CMPI.L  #68020,D0
        BCS     ende
        CMPI.L  #68040,D0
        BCS     fl30
        NOP
        DC.W    $F4F8           ; CPUSHA BC
        BRA     ende
  fl30: MOVEC   CACR,D0
        ORI     #$0808,D0
        MOVEC   D0,CACR
  ende: JSR     ToUser
        ADDQ.L  #4,A7
    END
  END FlushCPUCache;
(*$X=*)

PROCEDURE ExecProcess (bp: PtrBP; call: PROC; name: ADDRESS; prgFlags: LONGWORD;
                       VAR termState: CARDINAL; VAR exitCode: INTEGER);
  VAR pdb0: PDB; ec: INTEGER; oldCarrier: TermCarrier;
  BEGIN
    WITH bp^ DO
      p_tbase := ADDRESS (prepare);
      p_tlen  := 0L;
      p_dbase := ADDRESS (call);
      p_dlen  := 0L;
      p_bbase := p_lowtpa;
      p_blen  := p_hitpa - p_lowtpa;
      p_parent:= ProcessID^;
    END;
    FlushCPUCache ();
    (*$ ? Trace: WriteLn; WriteString ('CallEnvelopes (TRUE,FALSE)'); *)
    exitCode:= CallEnvelopes (TRUE,FALSE);
    IF exitCode # 0 THEN
      termState:= 0;
    ELSE
      Clear (ADR (pdb0), SIZE (pdb0));
      pdb0.layout:= ActPDB^.layout;
      pdb0.basePageAddr:= bp;
      pdb0.bottomOfStack:= LONGWORD (bp^.p_lowtpa);
      pdb0.topOfStack:= LONGWORD (bp^.p_hitpa);
      oldCarrier:= tCarrier;
      PushPDB (ADR (pdb0), bp);
      (*$R-*)
      (*$ ? Trace: WriteLn; WriteString ('pexec (4,name,bp)'); *)
      exitCode:= SHORT (pexec (4, name, bp));
      (*$R=*)
      tCarrier:= oldCarrier;
      termState:= pdb0.termState; (* 1..3 *)
      PopPDB
    END;
    (*$ ? Trace: WriteLn; WriteString ('CallEnvelopes (FALSE,FALSE)'); *)
    ec:= CallEnvelopes (FALSE,FALSE);
    IF (termState=2) & (ec#0) THEN exitCode:= ec END;
  END ExecProcess;


PROCEDURE removal;
  VAR i:ModRef;
  BEGIN
    ResetList (ModLst);
    LOOP
      i:= PrevEntry (ModLst);
      IF i=NIL THEN EXIT END;
      IF installed IN i^.state THEN
        EXCL (i^.state,installed); (* Falls ReleaseModule aufger. wird *)
        (*
         * Module, die sich mit ReleaseModule installiert haben,
         * Åber ihre zwangsweise Freigabe informieren:
         *)
        CallSub (i^.removeInfo,i^.removeWsp);
      END
    END;
    ResetList (ModLst);
    i:= PrevEntry (ModLst);
    REPEAT
      i:= CurrentEntry (ModLst);
      FreeMod (i);
      RemoveEntry (ModLst,error)  (* Alle Entries lîschen *)
    UNTIL error;
    DEALLOCATE (LinkedModList,0L);
    DeleteList (ModLst,error)     (* Nun Liste freigeben *)
  END removal;

VAR pdbp : PtrPDB;
    i: CARDINAL;
    siz: LONGCARD;
    pl: POINTER TO LONGCARD;

BEGIN (* ModBase *)
  CatchRemoval (rCarrier,removal,termwsp);
  Release:= SimpleRelease;
  SysCreateList (ModLst,error);
  IF error THEN SystemError.OutOfMemory END;
  GetPDB (pdbp,pro);
  IF pdbp^.modNo > 0 THEN
    (* Modlst der residenten Moduln erstellen *)
    siz:= TSIZE (ModEntry) * LONG (pdbp^.modNo);
    SysAlloc (LinkedModList,siz);
    IF LinkedModList=NIL THEN SystemError.OutOfMemory END;
    Clear (LinkedModList,siz);
    ResetList (ModLst);
    FOR i:=1 TO pdbp^.modNo DO
      AppendEntry(ModLst, ADR (LinkedModList^[i]),error);
      IF error THEN SystemError.OutOfMemory END;
      WITH pdbp^.modLst^ [i] DO
        WITH LinkedModList^[i] DO
          header:= head0;
          varRef:= var0;
          varLen:= varlen0;
          codeName:= ADDRESS (header) + header^.codeName;
          codeNameUp:= codeName^;
          Upper (codeNameUp);
          Assign (codeNameUp, fileName, ok);
          codeStart:= ADDRESS (header) + header^.codeStart;
          codeLen:= header^.modEnd - header^.codeStart;
          state:= ModStates {initialized,linked,running};
          IF 0 IN flags THEN INCL (state, procSym) END;
          IF 1 IN flags THEN INCL (state, crunched) END;
          IF NOT (2 IN flags) THEN INCL (state, reentrant) END;
          IF 3 IN flags THEN INCL (state, mainMod) END;
          (*
           * Importliste aufbauen:
           * Vom Linker wurden die Index-Nummern Åbergeben, nun werden sie
           * in ModRef-Ptr umgewandelt.
           *)
          IF header^.importList # 0 THEN
            imports:= ADDRESS (header) + header^.importList;
            pl:= ADDRESS (imports);
            WHILE pl^ # 0 DO
              pl^:= ADR (LinkedModList^[SHORT(pl^)]);
              INC (pl, 4)
            END;
          END;
        END
      END
    END
  END
END ModBase.
 
(* $FFAD4838$FFAD4838$FFAD4838$FFAD4838$FFAD4838$FFAD4838$FFAD4838$FFAD4838$FFAD4838$FFAD4838$FFAD4838$00000C37$FFAD4838$000062B6$FFAD4838$FFAD4838$FFAD4838$FFAD4838$FFAD4838$FFAD4838$FFAD4838$FFAD4838$FFAD4838$FFAD4838$FFAD4838$FFAD4838$FFAD4838$FFAD4838$FFAD4838$FFAD4838$FFAD4838$FFAD4838$FFAD4838$FFAD4838$FFAD4838$FFAD4838$FFAD4838$FFAD4838$FFAD4838$FFAD4838$FFAD4838$FFAD4838Ä$00000000T.......T.......T.......T.......T.......T.......T.......T.......T.......T.......$FFAD4838$FFAD4838$FFAD4838$FFAD4838$FFAD4838$FFAD4838$FFAD4838$FFAD4838$FFAD4838$FFAD4838$FFAD4838$FFAD4838$FFAD4838$FFAD4838$FFAD4838$FFAD4838ÄÄÅ*)
