IMPLEMENTATION MODULE VDN;
(* Ω 1993-95 ROLF SCHRADER.   * .. 9.10.93 ~ 9.12.93 + 9.6.94 ++ 1.2.95 *)
(* Problem:  Die von NVDI angeblich zurÅckgelieferten Iex kommen nicht an! *)
(*$Q+,$T-,$S- CoOps.: Short jumps, no stack & no range checks.*)

(* FÅr's TeDeum: 
IMPORT VDB, VD1, VT,VN;
*)
FROM SYSTEM IMPORT ADR, ADDRESS, WORD, BYTE, REGISTER;
FROM   VDB  IMPORT IG, Pb, CallVDI, InqExtended;

VAR  ReqBez: INTEGER;

PROCEDURE OpenBitmap (VAR BmMFDB,WorkIn,WorkOut: ARRAY OF WORD; VAR Hdl: IG);
 VAR   a,b,c: ADDRESS; p: POINTER TO ADDRESS;
 BEGIN WITH Pb DO
   a := pIin; pIin := ADR (WorkIn);
   b := pIex; pIex := ADR (WorkOut);
   c := pPex; pPex := ADR (WorkOut[45]);
   p := ADR (Ctl[7]); p^ := ADR (BmMFDB);
   CallVDI (1, 100,1, 20,0); pIin := a; pIex := b; pPex := c;
   Hdl := Ctl[6]; END (*Pb*); END OpenBitmap;

PROCEDURE CloseBitmap (Hdl: INTEGER);
 BEGIN CallVDI (Hdl, 101,1, 0,0) END CloseBitmap;

PROCEDURE InqScrn (Hdl: INTEGER; VAR WorkOut: ARRAY OF WORD);
 VAR   a: ADDRESS;
 BEGIN WITH Pb DO Iin[0] := 2; a := pIex; pIex := ADR (WorkOut);
         CallVDI (Hdl, 102,1, 1,0);       pIex := a; END; END InqScrn;

PROCEDURE BezLine (Hdl, n: IG; VAR P: ARRAY OF WORD; VAR B: ARRAY OF BYTE;
                   VAR E: ARRAY (*4*) OF WORD; VAR Calcs,Gaps: INTEGER);
 VAR   a,b, e: ADDRESS; m: INTEGER; p,q: POINTER TO CHAR;
 BEGIN WITH Pb DO a := pPin; pPin := ADR (P); m := (n+1) DIV 2;
                  b := pPex; pPex := ADR (E);
                  e := pIin; p := e; INC (e, n); q := ADR(B) +1;
         WHILE (p < e) DO p^ := q^; INC (p); DEC (q);     (* INTEL-Format! *)
                          p^ := q^; INC (p); INC (q, 3); END;
         CallVDI (Hdl, 6,13, m,n);
         Calcs := Iex[0]; Gaps := Iex[1];
         pPin := a; pPex := b; END (*Pb*); END BezLine;

PROCEDURE BezFill (Hdl, n: IG; VAR P: ARRAY OF WORD; VAR B: ARRAY OF BYTE;
                   VAR E: ARRAY (*4*) OF WORD; VAR Calcs,Gaps: INTEGER);
 VAR   a,b, e: ADDRESS; m: INTEGER; p,q: POINTER TO CHAR;
 BEGIN WITH Pb DO a := pPin; pPin := ADR (P); m := (n+1) DIV 2;
                  b := pPex; pPex := ADR (E);
                  e := pIin; p := e; INC (e, n); q := ADR(B) +1;
         WHILE (p < e) DO p^ := q^; INC (p); DEC (q);     (* INTEL-Format! *)
                          p^ := q^; INC (p); INC (q, 3); END;
         CallVDI (Hdl, 9,13, m,n);
         Calcs := Iex[0]; Gaps := Iex[1];
         pPin := a; pPex := b; END (*Pb*); END BezFill;

PROCEDURE SetBezQ (Hdl, Wanted: INTEGER): (*Realized:*) INTEGER;
 BEGIN Pb.Iin[0] := 32; Pb.Iin[1] := 1; Pb.Iin[2] := Wanted;
       CallVDI (Hdl, 5,99, 3,0);           ReqBez := Wanted;
(**)   RETURN IG (REGISTER (0)); (**)
       RETURN Pb.Iex[0]; END SetBezQ;

PROCEDURE SetBezF (Hdl, OnOff: INTEGER): (*Depth:*) INTEGER;
             (* Setzt das Bezier-Flag fÅr's ganze VDI (d.h. fÅr PolyLine & *)
             (* FillArea). NVDI empfiehlt: Nicht anwenden auûer in IsBezzy.*)
 BEGIN (**) Pb.Iin[0] := 100; Pb.Iex[0] := 12345; (**)
       CallVDI (Hdl, 11,13, ORD(OnOff=1),0);
       RETURN Pb.Iex[0]; END SetBezF;

PROCEDURE IsBezzy (Hdl: INTEGER): BOOLEAN;
 VAR   Out: ARRAY [0..56] OF INTEGER; m,n: INTEGER;
 BEGIN InqExtended (Hdl, 1, Out);
       IF (1 IN BITSET (Out[28])) THEN RETURN TRUE END;
       m := ReqBez; Pb.Iex[0] := 0;
       n := SetBezQ (Hdl, 100);
       m := SetBezQ (Hdl, m);
       RETURN (n # 0); END IsBezzy;
(*
PROCEDURE SetBezB (Hdl, Len16: IG; VAR Buffer: ARRAY (* 16*Len16 *) OF WORD);
 (* Ersetzt lokal den 16kB-Bez-Puffer im GDOS. NVDI empfiehlt: Ignorieren! *)
 VAR   p: POINTER TO ADDRESS;
 BEGIN p := ADR (Pb.Iin); p^ := ADR (Buffer); Pb.Iin[2] := Len16;
       CallVDI (Hdl, -1,6, 3,0); END SetBezB;
*)
(*ûû*)
BEGIN ReqBez := 100 END VDN.                                     TESTandDEMO:
*)

CONST PRASTERCOO = 2; NORMDEVCOO = 0; SF = 40 (* 1: PRC, 40: NDC *);

PROCEDURE OpenVWork  (VAR WorkOutA: ARRAY OF INTEGER): (*Hdl:*) INTEGER;
 VAR   GDev, j: INTEGER; In: ARRAY [0..19] OF INTEGER;
 BEGIN GDev := VDB.GDEV;
   FOR j := 00 TO 09 DO In[j] := 1 END;
   IF (SF = 1) THEN In[10] := PRASTERCOO ELSE In[10] := NORMDEVCOO END;
(* In[00] := BIOX.GetRez () +2; *)
   VDB.WorkOpen (VDB.VIRT, In, WorkOutA, GDev);
   RETURN GDev; END OpenVWork;

PROCEDURE OpenBWork (xMax,yMax: INTEGER; VAR Bm: VDB.MFDB;
                     VAR WorkOutA: ARRAY OF INTEGER): (*Hdl:*) INTEGER;
 VAR   GDev, j: INTEGER; In: ARRAY [0..19] OF INTEGER;
 BEGIN GDev := VDB.GDEV;
   FOR j := 00 TO 09 DO In[j] := 1 END;
   IF (SF = 1) THEN In[10] := PRASTERCOO ELSE In[10] := NORMDEVCOO END;
   In[11] := xMax; In[12] := yMax;
   In[13] := 0; In[14] := 0;       (* Pixelmaûe des Bildschirms Åbernehmen.*)
   FOR j := 15 TO 19 DO In[j] := 0 END;
   OpenBitmap (Bm, In, WorkOutA, GDev);
(* VDB.WorkClear (GDev); 3 Bombs! *)
   RETURN GDev; END OpenBWork;

VAR SHdl,BHdl: INTEGER;
    SOut,BOut: ARRAY [0..127] OF INTEGER;

PROCEDURE ClipBitmap;
 VAR   P: VDB.PxyArr;
 BEGIN VDB.Asg4 (P, 0,0, SF*BOut[0],SF*BOut[1]);
       VDB.SetClipping (BHdl, P); END ClipBitmap;

PROCEDURE ClipScreen;
 VAR   P: VDB.PxyArr;
 BEGIN VDB.Asg4 (P, 0,0, SF*SOut[0],SF*SOut[1]);
       VDB.SetClipping (SHdl, P); END ClipScreen;

PROCEDURE Scale (VAR P: ARRAY OF WORD; N,S: CARDINAL);       (* PRC -> NDC.*)
 BEGIN IF (S = 1) THEN RETURN END;
       IF (0 = N) THEN N := 1+ HIGH (P) END;
   REPEAT DEC (N); P[N] := WORD (S* CARDINAL(P[N])) UNTIL (N = 0); END Scale;

PROCEDURE Draw;
 CONST N = 256;
 VAR   E: VDB.PxyArr;  Calcs,Gaps, d: INTEGER;
       P: ARRAY [0..N] OF RECORD x,y: INTEGER END;
       B: ARRAY [0..N] OF CHAR;
 BEGIN
(*     d := VDB.SetFillType  (BHdl, 3);
       d := VDB.SetFillColor (BHdl, 3);
       d := VDB.SetWritMode  (BHdl, 1);
       d := VDB.SetFillStyle (BHdl, 1);
       d := VDB.SetFillPerim (BHdl, 1);
*)     VDB.SetFillAtts (BHdl, VDB.HATCH,VDB.GREEN,VDB.RPL, 1(*Plain*),1);
       VDB.Asg4 (P, 0,0, 250,250); Scale (P, 4, SF);
       VDB.DrawBar (BHdl, P);
       VDB.SetFillAtts (BHdl, -1,VDB.BLACK,-1, 3,-1);
   IF ~ IsBezzy (BHdl) THEN
       VDB.GrafText (1, 0,13, "Not Bezzy"); (* RETURN *) END;

   d := SetBezF (BHdl, 1);
VT.GoXY (2,2);
VT.wT (" BezQual: ");
VN.wDecW (d, 1);
   d := SetBezQ (BHdl,  30);
VN.wDecW (d, 4);
   d := SetBezQ (BHdl, 100);
VN.wDecW (d, 4);

   VDB.Asg4 (B, 0100H,0000H, 0300H,0000H); B[8] := 0c; (* 8 BezierBytes +0.*)
   VDB.Asg8 (P,    100,100, 400,100, 400,400, 100,400);
   VDB.Asg8 (P[4], 200,200, 300,200, 300,300, 200,300);
   Scale (P, 16, SF);
(* VDB.FillArea (BHdl, 8, P); *)
(* VDB.PolyLine (BHdl, 8, P); *)
   BezFill (BHdl, 8, P, B, E, Calcs, Gaps);

VT.wT ("  Calcs: "); VN.wDecW (Calcs, 1);
VT.wT ("   Gaps: "); VN.wDecW (Gaps,  1);
   d := SetBezF (BHdl, 0);
d := VDB.SetWritMode  (BHdl, 1);     (* Dies nur, um die korrekte Funktion *)
VT.wT ("  wMode: "); VN.wDecW (d, 1);       (* des Bindings zu ÅberprÅfen! *)

   VDB.GrafText (BHdl, 30*SF,70*SF, "Text!"); END Draw;

PROCEDURE TeDeum;
 VAR   AreaS,AreaB: VDB.PxyRec; Bm: VDB.MFDB; aS: ADDRESS;
 BEGIN
(*     GDB.Alloc (128*1024, aS); *)
       SHdl := OpenVWork (SOut);
       IF (SHdl = 0) THEN VDB.GrafText (1, 0,12, "No Screen"); RETURN END;
       ClipScreen;
       WITH Bm DO Ad := (*aS;*) 0; (* Der Speicher wird vom NVDI alloziert.*)
                  nP := 0; END;    (* # der Farbebenen wie beim Bildschirm.*)
       BHdl := OpenBWork (607, 431, Bm, BOut);
       IF (BHdl = 0) THEN VDB.GrafText (1, 0,12, "No Bitmap"); RETURN END;
       ClipBitmap;
   VDB.MouseCursor (VDB.CURSEX);
   Draw;    (* Auf der OffScreen-Bitmap zeichnen; und zum Schirm kopieren: *)
   VDB.Asg4 (AreaB,  0, 0, 607,431); Scale (AreaB, 4, SF);
   VDB.Asg4 (AreaS, 50,50, 707,531); Scale (AreaS, 4, SF);
   VDB.CopyOpaque (SHdl, 3, AreaB,AreaS, ADR (Bm), 0); (* ADR (VDB.SCR0)); *)
   CloseBitmap (BHdl);
   VDB.WorkClose (SHdl, VDB.VIRT);
   VDB.Pause;
(* IF GDB.DoFree (aS) THEN END; *)
   VDB.MouseCursor (VDB.CURSON); END TeDeum;

BEGIN ReqBez := 0; TeDeum END VDN.
