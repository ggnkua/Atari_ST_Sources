IMPLEMENTATION MODULE Salad;
(* ½ 1991-94 ROLF SCHRADER. * 25.4.91 ++ 9.8.93 ~ 26.9.94 *)
(*$S-,$T-,$Q+*)
(* Fr's TeDeum:
IMPORT VE, VN;
*)
FROM   SYSTEM  IMPORT ADDRESS, CODE, REGISTER;

CONST  INIT = 0A000H; A0 = 8; A1 = 9; A2 = 10;

PROCEDURE Init;
 VAR   a: ADDRESS;
 BEGIN CODE (INIT);                    (* Line-A-Basisadresse nach A0 & D0.*)
       a := REGISTER (A0);
   aLinAVars := a;
   aNegAVars := a -38EH;
   aCurFont  := a -38AH;
      pNpl   := a -30EH +8;
   aDefFont  := a -1CCH;
   a6x6Font  := a -1C8H;
   a8x8Font  := a -1C4H;
      pMoSem := a -15AH;
      pAlfaM := a - 2CH;
      pAlfaC := a - 1CH;
      pWmax  := a - 12;
      pHmax  := a -  4;
      pRBW   := a -  2;
      pFonts := REGISTER (A1);
      pVecs  := REGISTER (A2); END Init;

(*žž*)
BEGIN Init END Salad.
*)

TYPE nVarsRec = RECORD

(*-38EH*) Res6:        ADDRESS;
(*-38AH*) aCurFont:    ADDRESS;                (* -> Header des akt. Fonts.*)
          Res5:        ARRAY [0..22] OF INTEGER;
(*-358H*) xHot,yHot:   INTEGER;                            (* Maus-HotSpot.*)
(*-354H*) mPl:         INTEGER;      (* 1: Replace-, -1: Xor-Modus f. Maus.*)
(*-352H*) mBGB,mFGB:   CARDINAL;     (* Hinter- & Vordergrundfarbe f. Maus.*)
(*-34EH*) mForm:       ARRAY [0..31] OF BITSET;     (* Maus-Figur & -Maske.*)
(*-30EH*) xInqTab:     ARRAY [0..44] OF CARDINAL;   (* Infos f. ext.Inqire.*)
(*-2B4H*) DevTab:      ARRAY [0..44] OF CARDINAL;   (* Infos fr OpenVWork.*)
(*-25AH*) gCx,gCy:     INTEGER;                      (* Akt. Maus-Position.*)
(*-256H*) mHideCount:  INTEGER;           (* # erfolgter HideMouse-Aufrufe.*)
(*-254H*) mButt:       BITSET;                   (* Status der Maus-Kn”pfe.*)
(*-252H*) ReqCol:      ARRAY [0..2],[0..15] OF CARDINAL;  (* -> Inq.Colour.*)
(*-1F2H*) SizeTab:     ARRAY [0..14] OF CARDINAL;     (* Infos f. OpenWork.*)
          Res4:        ARRAY [0.. 1] OF CARDINAL;
(*-1D0H*) aCurWork:    ADDRESS;    (* -> Attribute der akt. V.-Workstation.*)
(*-1CCH*) aDefFont:    ADDRESS;    (* -> Header Default-System-Zeichensatz.*)
(*-1C8H*) FontRingA:   ARRAY [0..3] OF ADDRESS;                  (* -> Lit.*)
(*-1B8H*) FontCount:   CARDINAL;                   (* # Zeichens„tze darin.*)
          Res3:        ARRAY [0..44] OF CARDINAL;
(*-15CH*) mCurStat:    CHAR;                                     (* -> Lit.*)
          Res2:        CHAR;
(*-15AH*) vHideCount:  INTEGER;                   (* # Hide-Cursor-Aufrufe.*)
(*-158H*) xCur,yCur:   INTEGER;                           (* Maus-Position.*)
(*-154H*) CurFlag:     CHAR;     (* #0, wenn M.-Cursor neu zu zeichnen ist.*)
(*-153H*) MouseFlag:   CHAR;                   (* #0 bei Musus Interruptus.*)
          Res1:        ADDRESS;
(*-14EH*) vSavx,vSavy: INTEGER;         (* Gerettete xy-Koord. des Cursors.*)
(*-14AH*) SaveLen:     CARDINAL;           (* # der gebunkerten Bildzeilen.*)
(*-148H*) SaveAdr:     ADDRESS;  (* -> 1. gepuffertes Byte im Bildspeicher.*)
(*-144H*) SaveStat:    BITSET;        (* Bit0: Puffer gltig? Bit1: Longs? *)
(*-142H*) SaveArea:    ARRAY [0..3],[0..15] OF LONGCARD; (* Unter der Maus.*)
(*-042H*) UserTim,                          (* Akt. Timer-Interrupt-Vektor.*)
(*-03EH*) NextTim:     ADDRESS;             (* Alter  "       "       "   .*)
(*-03AH*) UserBut,                                    (* Maustasten-Vektor.*)
(*-036H*) UserCur,                                  (* Maus-Zeichenroutine.*)
(*-032H*) UserMot:     ADDRESS;                     (* Mausbewegungsvektor.*)
(*-02EH*) vCell:       RECORD ht,mX,mY,wr: CARDINAL END;         (* -> Lit.*)
(*-026H*) vCBG,vCFG:   CARDINAL;             (* Hinter- & Vordergrundfarbe.*)
(*-022H*) vCurAd:      ADDRESS (*??*);    (* Adr. der akt. Cursor-Position.*)
(*-01EH*) vCurOs:      INTEGER;       (* Offset im Alfa-Schirm, -> Esc 101.*)
(*-01CH*) vCurX,vCurY: INTEGER;            (* XY-Position des Alfa-Cursors.*)
(*-018H*) vPeriod:     CHAR;           (* Blink-Intervall  "   "      "   .*)
(*-017H*) vCurCount:   CHAR;                        (* Z„hler frs Blinken.*)
(*-016H*) vFontAd:     ADDRESS;       (* -> System-Zeichensatz, -> Esc 102.*)
(*-012H*) vFontEnd,                     (* ASCII-Wert des letzten Zeichens.*)
(*-010H*) vFont1st,                     (*   "    "    "  ersten     "    .*)
(*-00EH*) vFontW:      CARDINAL;        (* Breite des Font-Images in Bytes.*)
(*-00CH*) vRezHorz:    CARDINAL;        (* Breite des Bildschirms in Pixel.*)
(*-00AH*) vOffAd:      ADDRESS;   (* -> Z.-satz-Offset-Tabelle, -> Esc 102.*)
(*-006H*) Res0:        BITSET;              (* Im alten TOS: Cursor-Status.*)
(*-004H*) vRezVert,                              (* # Scan-Zeilen aufm Sch.*)
(*-002H*) BpSL:        CARDINAL;                 (* # Bytes pro Scan-Zeile.*)

          END (*R*);


MODULE TESTandDEMO;
FROM   VE  IMPORT wTxt, Home, Fw,Up,Ln, ClrE, Mus0,Mus1, Font;
FROM   VN  IMPORT wDecW, wDecL, Pause;
IMPORT F6x6,F8x8,F8x16, pFonts, nVarsRec, aNegAVars, aLinAVars,
       pNpl,pWmax,pHmax,pRBW, pAlfaC;
EXPORT TeDeum;

PROCEDURE wT (VAR s: ARRAY OF CHAR); BEGIN Ln; Fw; wTxt (s); Fw END wT;

PROCEDURE Info;
 VAR   pNegAVars: POINTER TO nVarsRec; k: CARDINAL;
 BEGIN pNegAVars := aNegAVars;
  WITH pNegAVars^ DO
   Ln; wT (" aNegAVars,aLinAVars: ");
       wDecL(aNegAVars, 1); Fw; wDecL (aLinAVars, 1);
   Ln; wT (" Npl,Wmax,Hmax,BPL:   "); wDecW (pNpl^, 1); Fw;
       wDecW (pWmax^, 1); Fw; wDecW (pHmax^, 1); Fw; wDecW (pRBW^, 1);
       wT (" # Pixel pro Scan-Z.: "); wDecW (vRezHorz, 1);
       wT (" # der Scan-Zeilen:   "); wDecW (vRezVert, 1);
       wT (" # Bytes pro Scan-Z.: "); wDecW (BpSL, 1);
       wT (" # Pl., Xmax, # Col.: "); wDecW (xInqTab[4], 1);
       Fw; wDecW (DevTab[0], 1); Fw;  wDecW (DevTab[39], 1);
   Ln; wT (" graf.Cursor-Pos.:    ");
       wDecW (gCx,  1); Fw; wDecW (gCy,  1);
       wT (" Maus-Position:       ");
       wDecW (xCur, 1); Fw; wDecW (yCur, 1);
       wT (" MouseHideCount:      "); wDecW (mHideCount, 1);
   Ln; wT (" # System-Fonts:      "); wDecW (FontCount, 1); Fw;
       wT (" FontRing:            ");
       FOR k := 0 TO 3 DO wDecL (FontRingA[k], 1); Fw END;
       wT (" aDefFont:            "); wDecL (aDefFont, 1);
       wT (" aCurFont:            "); wDecL (aCurFont, 1);
       wT (" vFont: Ad,End,1st,W: ");
       wDecL (vFontAd, 1);  Fw; wDecW (vFontEnd, 1); Fw;
       wDecW (vFont1st, 1); Fw; wDecW (vFontW, 1);
   Ln; wT (" vCell.ht,mX,mY,wr:   ");
       wDecW (vCell.ht, 1); Fw; wDecW (vCell.mX, 1); Fw;
       wDecW (vCell.mY, 1); Fw; wDecW (vCell.wr, 1);
   Ln; wT (" Alfa-Cursor-Pos.:    ");
       wDecW (vCurX, 1); Fw; wDecW (vCurY, 1);
       wT (" AlfaCursor (X,Y):    ");
       wDecW (pAlfaC^.X, 1); Fw; wDecW (pAlfaC^.Y, 1);
   END (*W*); END Info;

PROCEDURE TeDeum;
 BEGIN    Mus0; Home;     Info; Pause; Home; ClrE;
   Font (pFonts^[F6x6]);  Info; Pause; Home; ClrE;
   Font (pFonts^[F8x8]);  Info;
   Font (pFonts^[F8x16]);
   Up; wT (" sodele.");
   Mus1 (300, 180);
   Pause; END TeDeum;

END (*M*) TESTandDEMO;

BEGIN Init; TeDeum END Salad.
