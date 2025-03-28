         PROGRAM LOGIMIN (INPUT,OUTPUT,OD);

(******************************************************)
(*                                                    *)
(* LOGIMIN MINIMIERT EINE BOOLE'SCHE FUNKTION NACH DEM*)
(* QUINE & McCLUSKEY-VERFAHREN MIT PRIMIMPLIKANTEN-   *)
(* TABELLE.                                           *)
(*                                                    *)
(*             RAINER STORN, OKT. 1989                *)
(*             (c) MAXON Computer GmbH                *)
(*                                                    *)
(* PROZEDUREN: SORT, QMC, WRTAB, WRLIN, CONV, ERR1,   *)
(*             ERR2, CAS, WRTABP, WRLINP              *)
(*                                                    *)
(******************************************************)

         CONST
             BIT=32; (* WORTLAENGE FUER DEN DATENTYP LONG_INTEGER *)
             BH=20;
             LS=2;
             LZ=17000; (* LZmin = 2**(ZAHL DER EINGANGSVARIABLEN) *)
             LKON=200;
             LZP=100;
             CLEN=45;
             VNUM=10;
         TYPE
             ARY1=ARRAY [1..LZ,1..LS] OF LONG_INTEGER;
             ARY2=ARRAY [0..BH] OF LONG_INTEGER;
             ARY3=ARRAY [1..LKON] OF LONG_INTEGER;
             ARY4=ARRAY [1..LZP] OF LONG_INTEGER;
         VAR
             OD:TEXT;
             ARY:ARY1;
             A,C:ARY2;
             KONJ:ARY3;
             PIMP:ARY4;
             LEN,I,J,NVAR,NMAX,MR,MC,B,N,M:LONG_INTEGER;
             LINU,LINO,MKO,IKO,MDC,IP,LIM:LONG_INTEGER;
             IPARTS,MPARTS,START,STOP:LONG_INTEGER;
             CH1,CH2:CHAR;



         FUNCTION MDL (A,B:LONG_INTEGER):LONG_INTEGER;

(*************************************************)
(*                                               *)
(* MDL IST EINE SPEZIELLE MODULO-FUNKTION DIE    *)
(* BERUECKSICHTIGT, DASS FELDER VOM TYP ARY1 MIT *)
(* DEM FELDINDEX 1 BEGINNEN.                     *)
(*                                               *)
(*************************************************)

         BEGIN
           IF ( A > B ) THEN MDL:= (A MOD B) + 1
           ELSE MDL:=A;
         END;

       FUNCTION IPOT (A,B:LONG_INTEGER):LONG_INTEGER;
       
(*************************************************)
(*                                               *)
(*       IPOT(A,B) berechnet A hoch B.           *)
(*                                               *)
(*************************************************)

       VAR X, I : LONG_INTEGER;

       BEGIN
         X := 1;
         FOR I:=1 TO B DO
            X := X*A;
         IPOT:=X;
       END;
       
       FUNCTION RPOT (A:REAL; B:LONG_INTEGER):REAL;
       
(*************************************************)
(*                                               *)
(*       RPOT(A,B) berechnet A hoch B.           *)
(*                                               *)
(*************************************************)

       VAR I : LONG_INTEGER;
           X : REAL;

       BEGIN
         X := 1.0;
         FOR I:=1 TO B DO
            X := X*A;
         RPOT:=X;
       END;
       


         PROCEDURE ERR1;

(********************************)
(*                              *)
(* PROZEDUR FUER FEHLERMELDUNG. *)
(*                              *)
(********************************)

         BEGIN
           WRITELN;
           WRITELN('ERROR! OBERE ZEILENNUMMER KLEINER ALS UNTERE');
           WRITELN;
         END;


         PROCEDURE ERR2;

(********************************)
(*                              *)
(* PROZEDUR FUER FEHLERMELDUNG. *)
(*                              *)
(********************************)

         BEGIN
           WRITELN;
           WRITELN('ERROR! ZEILENINTERVALL NICHT IM ERLAUBTEN BEREICH');
           WRITELN;
         END;


         PROCEDURE CAS (VAR CH:CHAR; VAR J:LONG_INTEGER; NMAX:LONG_INTEGER; VAR ARY:ARY1);

(*******************************************************************)
(*                                                                 *)
(* CAS MACHT DIE FALLUNTERSCHEIDUNG FUER '0','1','X' BEI DER WER-  *)
(* TETABELLENEINGABE.                                              *)
(*                                                                 *)
(*******************************************************************)

         BEGIN
           CASE CH OF
            '0': BEGIN
                   IF (J < NMAX) THEN
                     BEGIN
                       J:=J+1;
                       ARY[J,1]:=0;
                     END;
                 END;

            '1': BEGIN
                   IF (J < NMAX) THEN
                     BEGIN
                       J:=J+1;
                       ARY[J,1]:=1;
                     END;
                 END;

            'X': BEGIN
                   IF (J < NMAX) THEN
                     BEGIN
                       J:=J+1;
                       ARY[J,1]:=2;
                     END;
                 END;


           OTHERWISE :CH:='E';
           END;
         END;


         PROCEDURE CONV (B,N:LONG_INTEGER; VAR M:LONG_INTEGER; VAR A:ARY2);

(*****************************************************************)
(*                                                               *)
(* CONV GENERIERT ZU EINER POSITIVEN GANZEN ZAHL N DIE ZIFFERN   *)
(* FUER DIE DARSTELLUNG IM ZAHLENSYSTEM MIT DER BASIS B.         *)
(* DIE ZIFFERN WERDEN NACH AUFSTEIGENDER WERTIGKEIT IM FELD A    *)
(* VON ADRESSE 0..M ABGELEGT.                                    *)
(*                                                               *)
(*****************************************************************)

         VAR
           N1,I,DIGIT:LONG_INTEGER;

         BEGIN
           N1:=N;
           M:=-1;
           WHILE (N1 > 0) DO
            BEGIN
              M:=M+1;
              DIGIT:=N1 MOD B;
              A[M]:=DIGIT;
              N1:=N1 DIV B;
            END;
         END;


         PROCEDURE WRTAB (NVAR:LONG_INTEGER);

(************************************************)
(*                                              *)
(* WRTAB SCHREIBT DIE KOPFZEILE DER WERTETAFEL. *)
(*                                              *)
(************************************************)

         VAR J:LONG_INTEGER;

         BEGIN
          WRITELN(' ');
          WRITE(' ZEILE  ');
          IF (NVAR > VNUM) THEN
            BEGIN
              FOR J:=NVAR DOWNTO 1 DO WRITE(' ');
              WRITELN('   Y ');
              WRITE('--------');
              FOR J:=1 TO NVAR DO WRITE('-');
              WRITELN('-----');
              WRITELN;
            END              
          ELSE
            BEGIN
              FOR J:=NVAR DOWNTO 1 DO WRITE(' X',J:2,' ');
              WRITELN('   Y ');
              WRITE('--------');
              FOR J:=1 TO NVAR DO WRITE('-----');
              WRITELN('-----');
              WRITELN;
            END;
         END;


         PROCEDURE WRLIN (I,NVAR:LONG_INTEGER; A:ARY2);

(*********************************************)
(*                                           *)
(* WRLIN SCHREIBT EINE ZEILE DER WERTETAFEL. *)
(*                                           *)
(* PROZEDUREN: CONV                          *)
(*                                           *)
(*********************************************)

         VAR J,M:LONG_INTEGER;

         BEGIN
           CONV(2,I,M,A);
           IF (NVAR > VNUM) THEN
             BEGIN
               WRITE(I:6,'  ');
               FOR J:=1 TO NVAR-M-1 DO WRITE('0');
               FOR J:=M DOWNTO 0 DO WRITE(A[J]:1);
               WRITE('   ');
             END
           ELSE
             BEGIN
               WRITE(I:4,'    ');
               FOR J:=1 TO NVAR-M-1 DO WRITE(' 0   ');
               FOR J:=M DOWNTO 0 DO WRITE(' ',A[J]:1,'   ');
               WRITE('   ');
             END;               
         END;

         
         PROCEDURE WRTABP (NVAR:LONG_INTEGER);

(************************************************)
(*                                              *)
(* WRTABP DRUCKT DIE KOPFZEILE DER WERTETAFEL.  *)
(*                                              *)
(************************************************)

         VAR J:LONG_INTEGER;

         BEGIN
          WRITELN(OD,' ');
          WRITE(OD,' ZEILE  ');
          IF (NVAR > VNUM) THEN
            BEGIN
              FOR J:=NVAR DOWNTO 1 DO WRITE(OD,' ');
              WRITELN(OD,'   Y ');
              WRITE(OD,'--------');
              FOR J:=1 TO NVAR DO WRITE(OD,'-');
              WRITELN(OD,'-----');
              WRITELN(OD);
            END              
          ELSE
            BEGIN
              FOR J:=NVAR DOWNTO 1 DO WRITE(OD,' X',J:2,' ');
              WRITELN(OD,'   Y ');
              WRITE(OD,'--------');
              FOR J:=1 TO NVAR DO WRITE(OD,'-----');
              WRITELN(OD,'-----');
              WRITELN(OD);
            END;
         END;


         PROCEDURE WRLINP (I,NVAR:LONG_INTEGER; A:ARY2);

(*********************************************)
(*                                           *)
(* WRLINP DRUCKT EINE ZEILE DER WERTETAFEL.  *)
(*                                           *)
(* PROZEDUREN: CONV                          *)
(*                                           *)
(*********************************************)

         VAR J,M:LONG_INTEGER;

         BEGIN
           CONV(2,I,M,A);
           IF (NVAR > VNUM) THEN
             BEGIN
               WRITE(OD,I:6,'  ');
               FOR J:=1 TO NVAR-M-1 DO WRITE(OD,'0');
               FOR J:=M DOWNTO 0 DO WRITE(OD,A[J]:1);
               WRITE(OD,'   ');
             END
           ELSE
             BEGIN
               WRITE(OD,I:4,'    ');
               FOR J:=1 TO NVAR-M-1 DO WRITE(OD,' 0   ');
               FOR J:=M DOWNTO 0 DO WRITE(OD,' ',A[J]:1,'   ');
               WRITE(OD,'   ');
             END;               
         END;



         PROCEDURE SORT (VAR A:ARY1; MR,MC:LONG_INTEGER);

(*************************************************************)
(*                                                           *)
(* SORT IST EINE SHELL-SORT PROZEDUR. SIE SORTIERT DIE       *)
(* ZEILEN DES ZWEIDIMENSIONALEN INTEGER-FELDES A NACH DER    *)
(* GROESSE DES JEWEILS ERSTEN ELEMENTES DER ZEILEN (AUFSTEI- *)
(* GENDE REIHENFOLGE).                                       *)
(* DER ZWECK IST, DIE ZUR DURCHFUEHRUNG DES QMC-VERFAHRENS   *)
(* BENOETIGTEN VOLLKONJUNKTIONEN NACH DER ANZAHL DER EINSEN  *)
(* ZU ORDNEN.                                                *)
(*                                                           *)
(* MR             : BENUTZTE ZEILENLAENGE VON A              *)
(* MC             : BENUTZTE SPALTENLAENGE VON A             *)
(*                                                           *)
(*************************************************************)

         VAR
            DONE:BOOLEAN;
            HELP,JUMP,I,J,K:LONG_INTEGER;

         BEGIN
          JUMP:=MR;
          WHILE (JUMP > 1) DO
            BEGIN
              JUMP:=JUMP DIV 2;
              REPEAT
                DONE:=TRUE;
                FOR J:=1 TO MR-JUMP DO
                  BEGIN
                    I:=J+JUMP;
                    IF (A[J,1] > A[I,1]) THEN
                       BEGIN
                         FOR K:=1 TO MC DO     (* VERTAUSCHUNG *)
                           BEGIN
                             HELP:=A[I,K];
                             A[I,K]:=A[J,K];
                             A[J,K]:=HELP;
                           END;
                         DONE:=FALSE;
                       END;                    (* IF *)
                  END;                         (* FOR *)
              UNTIL DONE
            END;                               (* WHILE *)
        END;                                   (* PROZEDUR-ENDE *)


         PROCEDURE QMC (VAR KONJ:ARY3; VAR PIMP:ARY4; VAR ARY:ARY1;
                       LEN,MKO,MDC:LONG_INTEGER; VAR IP:LONG_INTEGER);

(*********************************************************************)
(*                                                                   *)
(* QMC FUEHRT EINE QMC-MINIMIERUNG ANHAND DER EINGEGEBENEN MINTERME  *)
(* UND DON'T CARE TERME DURCH.                                       *)
(* NACH ABLAUF DER PROZEDUR STEHEN ALLE UEBRIGGEBLIEBENEN PRIMIMPLI- *)
(* KANTEN IM FELD PIMP.                                              *)
(*                                                                   *)
(* BENOETIGTE PROZEDUR: SORT                                         *)
(*                                                                   *)
(* KONJ           : FELD FUER DIE MINTERME UND DON'T CARE TERME.     *)
(* PIMP           : FELD FUER PRIMIMPLIKANTEN                        *)
(* ARY            : ZWEIDIMENSIONALES INTEGER-FELD ZUR AUFNAHME DER  *)
(*                  ENTSTEHENDEN LISTEN DES QMC-VERFAHENS. WIRD ALS  *)
(*                  RINGSPEICHER VERWENDET (MODULO LZ).              *)
(* LEN            : VARIABLE ZUR AUFNAHME DES PARAMETERS LZ.         *)
(* MKO            : ANZAHL DER MINTERME.                             *)
(* MDC            : ANZAHL DER DON'T CARE TERME.                     *)
(* IP             : ANZAHL DER PRIMIMPLIKANTEN IN PIMP.              *)
(*                                                                   *)
(*********************************************************************)

         VAR
           POINT:ARRAY[0..30,1..2] OF LONG_INTEGER;
           HELP,TERN,WORD1,WORD2:LONG_INTEGER;
           I,ONE,ADD,OFSW,OFSR:LONG_INTEGER;
           MONE,J,START,M,M1,K,K1:LONG_INTEGER;
           L6,L7,STO,J1,P,CT,LAST,OFLOW:LONG_INTEGER;

         BEGIN
          OFLOW:=0;                             (* UEBERLAUFFLAG *)

          FOR I:=1 TO MKO+MDC DO                (* FESTSTELLUNG DER ANZAHL   *)
            BEGIN                               (* AN EINSEN EINES MINTERMS, *)
              ONE:=0;                           (* TERNAERCODIERUNG DES MIN- *)
              WORD1:=KONJ[I];                   (* TERMS.                    *)
              TERN:=0;                          
              J:=-1;                            

               WHILE (WORD1 > 0) DO
                BEGIN
                  J:=J+1;
                  ONE:=ONE+(WORD1 MOD 2);
                  TERN:=TERN+(WORD1 MOD 2)*IPOT(3,J);
                  WORD1:=WORD1 DIV 2;
                END;

              ARY[I,1]:=ONE;                    (* ANZAHL EINSEN *)
              ARY[I,2]:=TERN;                   (* TERNAERCODIERUNG *)
            END;                                (* FOR I:=1... *)

          SORT(ARY,MKO+MDC,2);                  (* SORTIERUNG NACH EINSEN *)

          MONE:=ARY[MKO+MDC,1];                 (* MAXIMALE ANZAHL EINSEN *)
          FOR I:=1 TO 30 DO 
             BEGIN
               POINT[I,1]:=0;
               POINT[I,2]:=0;
             END;

          FOR I:=1 TO (MKO+MDC-1) DO            (* POINTER-FELD ZUR LISTEN- *)
            BEGIN                               (* TRENNUNG BESETZEN        *)
              IF (ARY[I,1] <> ARY[I+1,1]) THEN
                BEGIN
                  POINT[ARY[I,1],1]:=I;
                  POINT[ARY[I,1],2]:=1;
                END;
              ARY[I,1]:=0;                      (* INFORMATION UEBER ANZAHL *)
            END;                                (* EINSEN LOESCHEN          *)

           POINT[ARY[MKO+MDC,1],1]:=MKO+MDC;
           POINT[ARY[MKO+MDC,1],2]:=1;
           ARY[MKO+MDC,1]:=0;


           ADD:=MONE;                            (* INITIALISIERUNG *)
           IP:=0;
           OFSW:=MKO+MDC;
           OFSR:=0;
           LAST:=1;

(********************************************************************)
(*                                                                  *)
(*            KERN DES QUINE McCLUSKEY-VERFAHRENS                   *)
(*                                                                  *)
(********************************************************************)

           WHILE (ADD >= 1) DO
             BEGIN
               START:=OFSR+1;
               ADD:=ADD-1;
               OFSR:=OFSW;
               I:=0;
               WHILE (I <= ADD) DO
                BEGIN

                  IF ((POINT[I,2] = 1) AND (POINT[I+1,2] = 1)) THEN
                    BEGIN
                      POINT[I,2]:=0;
                      M:=0;

                      FOR J:=START TO POINT[I,1] DO             (* 1. GRUPPE *)
                        BEGIN
                          J1:=MDL(J,LEN);

                          FOR K:=(POINT[I,1]+1) TO POINT[I+1,1] DO (* 2. GRUPPE *)
                            BEGIN
                              K1:=MDL(K,LEN);
                              HELP:=0;
                              CT:=0;
                              M1:=0;
                              WORD1:=ARY[J1,2];
                              WORD2:=ARY[K1,2];

                              WHILE (((WORD1 > 0) OR (WORD2 > 0)) AND
                                     (CT <= 1)) DO
                                BEGIN
                                  IF ((WORD1 MOD 3) <> (WORD2 MOD 3)) THEN
                                    BEGIN
                                      HELP:=HELP+2*IPOT(3,M1);
                                      CT:=CT+1;
                                    END
                                  ELSE HELP:=HELP+(WORD1 MOD 3)*IPOT(3,M1);

                                  M1:=M1+1;
                                  WORD1:=WORD1 DIV 3;
                                  WORD2:=WORD2 DIV 3;
                                END;

                                 IF (CT <= 1) THEN
                                BEGIN
                                  ARY[J1,1]:=1;
                                  ARY[K1,1]:=1;
                                  STO:=0;
                                  M1:=1;

                                  WHILE (M1 <= M) DO
                                    BEGIN
                                      IF (HELP = ARY[MDL(OFSW+M1,LEN),2])
                                      THEN STO:=1;
                                      M1:=M1+1;
                                    END;

                                  IF (STO = 0) THEN
                                    BEGIN
                                      POINT[I,2]:=1;
                                      M:=M+1;
                                      P:=MDL(OFSW+M,LEN);
                                      IF (ABS(OFSW+M-K) >= LEN) THEN OFLOW:=1;
                                      ARY[P,1]:=0;
                                      ARY[P,2]:=HELP;
                                    END;
                                END;      (* IF (CT... *)
                            END;          (* FOR K:=   *)

                            IF (ARY[J1,1] = 0) THEN
                              BEGIN
                                IP:=IP+1;
                                PIMP[IP]:=ARY[J1,2];
                              END;

                        END;              (* FOR J:=   *)


                      START:=POINT[I,1]+1;
                      LAST:=START;
                      POINT[I,1]:=OFSW+M;
                      OFSW:=OFSW+M;

                    END;                  (* IF ((POINT[... *)

                  I:=I+1;

                END;                      (* WHILE (I <= ADD) *)

                I:=I-1;
                FOR K:=START TO POINT[I+1,1] DO
                  BEGIN             (* AUFFINDEN NICHT BENUTZTER TERME  *)
                    K1:=MDL(K,LEN); (* DER LETZTEN GRUPPE.              *)
                    IF (ARY[K1,1] = 0) THEN
                      BEGIN
                        IP:=IP+1;
                        PIMP[IP]:=ARY[K1,2];
                      END;
                  END;

            END;                          (* WHILE (ADD >= 1) *)

           FOR K:=LAST TO OFSW DO
            BEGIN
              K1:=MDL(K,LEN);
              IF (ARY[K1,1] = 0) THEN
                BEGIN
                  M:=0;
                  FOR J:=1 TO IP DO IF (ARY[K1,2] = PIMP[J]) THEN M:=1;
                  IF (M = 0) THEN
                    BEGIN
                      IP:=IP+1;
                      PIMP[IP]:=ARY[K1,2];
                    END;
                END;
            END;

           IF (OFLOW = 1) THEN
            BEGIN
              WRITELN;
              WRITELN('KONSTANTE LZ FUER FELD ARY ZU KURZ --> ERGEBNIS');
              WRITELN('DES VERFAHRENS VERMUTLICH FALSCH.');
              WRITELN;
            END;

         END; (* PROZEDURENDE *)


(****************************************************************************)
(*                                                                          *)
(*                     H A U P T P R O G R A M M                            *)
(*                                                                          *)
(****************************************************************************)

           BEGIN
           REWRITE(OD,'OUTPUT.DAT');
   WRITELN;
   WRITELN;
   WRITELN;
   WRITELN(' ******************************************');
   WRITELN(' *                                        *');
   WRITELN(' *            PROGRAMM LOGIMIN            *');
   WRITELN(' *                                        *');
   WRITELN(' *   von        Rainer Storn              *');
   WRITELN(' *                                        *');
   WRITELN(' *               Okt. 1989                *');
   WRITELN(' *                                        *');
   WRITELN(' ******************************************');
   WRITELN;
   WRITELN;
   WRITELN;                 
           WRITE(' Funktionsbeschreibung erwuenscht ? (J/N) :');
           READLN(CH1);
           IF ((CH1 = 'J') OR (CH1 = 'j')) THEN
            BEGIN
              WRITELN;
              WRITELN;
              WRITELN;
              WRITELN;
              WRITELN('LOGIMIN ist ein Programm zur Aufwandsminimierung einer');
              WRITELN('Boole`schen Funktion. Es bedient sich dabei des Ver-');
              WRITELN('fahrens von QUINE & McCLUSKEY mit PRIMIMPLIKANTEN-');
              WRITELN('TABELLE.');
              WRITELN('(Siehe auch Hoernes,G.E. und Heilweil,M.F.: Boolesche');
              WRITELN('            Algebra und Logik-Entwurf, R.Oldenbourg) ');
              WRITELN;
              WRITELN('Die Primimplikantentabelle wird auf dem File OUTPUT.DAT');
              WRITELN('abgelegt.');
              WRITELN;
              WRITELN;
              WRITELN;
           IF ((CH1 = 'J') OR (CH1 = 'j')) THEN              

                BEGIN
                   WRITE('Weiter ? (J/N) :');
                   READLN(CH1);
                END;
           IF ((CH1 = 'J') OR (CH1 = 'j')) THEN

              BEGIN
              WRITELN;
              WRITELN;
              WRITELN;
              WRITELN('Benoetigt wird eine Wahrheitstabelle der zu realisie-');
              WRITELN('renden Boole`schen Funktion.');
              WRITELN('Zu diesem Zweck muss die Ausgangsvariable Y zu jeder ');
              WRITELN('Zeile dieser Tabelle, welche sukzessive auf dem Bild-');
              WRITELN('schirm erscheint, eingegeben werden.');
              WRITELN;
              WRITELN('Zulaessige Eingaben sind:');
              WRITELN;
              WRITELN(' 0       : logische 0');
              WRITELN(' 1       : logische 1');
              WRITELN(' X       : don`t care position');
              WRITELN;
              WRITELN('Neben dem Haupteingabemodus stehen noch weitere Modi');
              WRITELN('zur Verfuegung:');
              END;
              WRITELN;
              WRITELN;
              WRITELN;
           IF ((CH1 = 'J') OR (CH1 = 'j')) THEN
                BEGIN
                   WRITE('Weiter ? (J/N) :');
                   READLN(CH1);
                END;
           IF ((CH1 = 'J') OR (CH1 = 'j')) THEN
              BEGIN
              WRITELN;
              WRITELN;
              WRITELN;
              WRITELN;
              WRITELN(' F       : FUELL-MODUS. Hierbei kann die Ausgangsva-');
              WRITELN('           riable Y in einem waehlbaren Zeilenbereich');
              WRITELN('           der Wertetabelle auf einen bestimmten Wert');
              WRITELN('           gesetzt werden.');
              WRITELN('           Jeder andere Character als 0,1 oder X fuehrt');
              WRITELN('           wieder in den Haupteingabemodus.');
              WRITELN('           Y ist standardmaessig stets auf 0 vorbesetzt.');
               WRITELN;
              WRITELN(' K       : KORREKTUR-MODUS. Es koennen die Werte der ');
              WRITELN('           Ausgangsvariablen Y im bereits besetzten Be-');
              WRITELN('           reich der Wertetabelle korrigiert werden.');
              WRITELN('           Jeder andere Character als 0,1 oder X fuehrt');
              WRITELN('           wieder in den Haupteingabemodus.');
              END;
              WRITELN;
              WRITELN;
              WRITELN;
           IF ((CH1 = 'J') OR (CH1 = 'j')) THEN
                BEGIN
                   WRITE('Weiter ? (J/N) :');
                   READLN(CH1);
                END;
           IF ((CH1 = 'J') OR (CH1 = 'j')) THEN
              BEGIN
              WRITELN;
              WRITELN;
              WRITELN;
              WRITELN(' L       : LIST-MODUS. In diesem Modus koennen Ausschnitte');
              WRITELN('           aus der Wertetabelle auf dem Bildschirm');
              WRITELN('           betrachtet werden.');
              WRITELN;
              WRITELN;
              WRITELN(' E       : EXIT. Dieser oder jeder andere Character ausser');
              WRITELN('           0,1,X,F,K und L fuehrt zur Beendigung des');
              WRITELN('           Haupteingabemodus.');
              END;
             END;

          WRITELN;
          WRITE('Wieviele Eingangsvariablen liegen vor  ? : ');
          READLN(NVAR);
          NVAR:=ABS(NVAR);
          IF (NVAR > VNUM) THEN
            BEGIN
              WRITELN;
              WRITELN('HOHE VARIABLENZAHL !');
              WRITELN('Wertetabelle wird aus PlatzgrÅnden');
              WRITELN('komprimiert ausgegeben.');
              WRITELN;
            END;
          LIM:=TRUNC(LN(RPOT(2.0,(BIT-1)))/LN(3));
          WRITELN;
          WRITELN;
          WRITELN;

           IF (NVAR <= LIM) THEN
             BEGIN
               CH1:='0';
               NMAX:=IPOT(2,NVAR);
               FOR I:=1 TO LZ DO ARY[I,1]:=0;
               I:=0;
             END
          ELSE
            BEGIN
              NMAX:=1;
              CH1:='E';
              WRITELN;
              WRITELN('ZAHL DER EINGANGSVARIABLEN ZU HOCH !');
              WRITELN('MAXIMAL ',LIM:2,' EINGANGSVARIABLE ZULAESSIG.');
              WRITELN;
            END;

            IF (NMAX > LZ) THEN
              BEGIN
                WRITELN;
                WRITELN('KONSTANTE LZ FUER ARY ZU KLEIN.');
                WRITELN('LZmin = ',NMAX:20);
                NMAX:=LZ;
                CH1:='E';
              END;

           WHILE (CH1 <> 'E') DO
            BEGIN
              IF (I < NMAX) THEN
                BEGIN
                  IF ((I MOD BH) = 0) THEN WRTAB(NVAR);
                  WRLIN(I,NVAR,A);
                  READLN(CH1);
                END
              ELSE
                BEGIN
                  WRITELN;
                  WRITELN;
                  WRITELN('Wertetabelle vollstaendig. Zur Fortsetzung des');
                  WRITELN('Verfahrens E druecken, falls keine Veraenderungen');
                  WRITELN('der Tabelle mehr erwuenscht sind.');
                  WRITELN;
                  WRITE('Naechstes Kommando ? : ');
                  READLN(CH1);
                END;

       IF (CH1 = 'f') THEN CH1:='F';
       IF (CH1 = 'k') THEN CH1:='K';       
       IF (CH1 = 'l') THEN CH1:='L';
       IF (CH1 = 'x') THEN CH1:='X';
       IF (CH1 = 'e') THEN CH1:='E';
       
               CH2:=CH1;
               CASE CH1 OF            
                '0' : CAS(CH2,I,NMAX,ARY);

                '1' : CAS(CH2,I,NMAX,ARY);

                'X' : CAS(CH2,I,NMAX,ARY);

                'F' : BEGIN
                        WRITELN;
                        WRITELN;
                        WRITE('Besetze ab Zeile ');
                        READLN(LINU);
                        WRITE('bis Zeile ');
                        READLN(LINO);
                        WRITE('mit ');
                        READLN(CH2);
                        IF (CH2 = 'x') THEN CH2 := 'X';
                        WRITELN;
                        WRITELN;

                        IF (LINO < LINU) THEN
                          BEGIN
                            ERR1;
                            CH2:='E';
                          END;
                        IF (((LINU < 0) OR (LINO < 0)) OR (LINO > NMAX-1)) THEN
                          BEGIN
                            ERR2;
                               CH2:='E';
                          END;

                        J:=LINU;
                        IF (((CH2 <> '0') AND (CH2 <> '1')) AND (CH2 <> 'X')) 
                        THEN CH2:='E';
                        WHILE ((CH2 <> 'E') AND (J <= LINO)) DO
                          BEGIN
                            IF ((J MOD BH) = 0) THEN WRTAB(NVAR);
                            WRLIN(J,NVAR,A);
                            WRITELN(CH2);
                            CAS(CH2,J,NMAX,ARY);
                          END;
                        IF (CH2 <> 'E') THEN IF (J > I) THEN I:=J;
                      END;

                'K' : BEGIN
                        WRITELN;
                        WRITELN;
                        WRITE('Korrektur ab Zeile ');
                        READLN(LINU);
                        WRITELN;
                        CH2:='0';
                        IF ((LINU >= I) OR (LINU < 0)) THEN
                          BEGIN
                            ERR2;
                            CH2:='E';
                          END;

                        J:=LINU;
                        WHILE ((CH2 <> 'E') AND (J < I)) DO
                          BEGIN
                            IF ((J MOD BH) = 0) THEN WRTAB(NVAR);
                             WRLIN(J,NVAR,A);
                            READLN(CH2);
                            IF (CH2 = 'x') THEN CH2 := 'X';
                            CAS(CH2,J,NMAX,ARY);
                          END;
                        WRITELN;
                        WRITELN;
                        WRITELN('EXIT! Normalmodus eingeschaltet');
                        WRITELN;
                      END;

                'L' : BEGIN
                        WRITELN;
                        WRITELN;
                        WRITE('Liste ab Zeile ');
                        READLN(LINU);
                        WRITE('bis Zeile ');
                        READLN(LINO);
                        WRITELN;

                        IF (LINO < LINU) THEN
                          BEGIN
                            ERR1;
                            CH2:='E';
                          END;

                        IF ((LINU > NMAX-1) OR (LINO < 0)) THEN
                          BEGIN
                            ERR2;
                            CH2:='E';
                          END;

                        IF (LINU < 0) THEN LINU:=0;
                        IF (LINO > NMAX-1) THEN LINO:=NMAX-1;

                        IF (CH2 <> 'E') THEN
                          BEGIN
                            FOR J:=LINU TO LINO DO
                              BEGIN
                                IF ((J MOD BH) = 0) THEN WRTAB(NVAR);
                                WRLIN(J,NVAR,A);
                                
                                CASE ARY[J+1,1] OF
                                  0 : WRITELN('0');
                                  1 : WRITELN('1');
                                  2 : WRITELN('X');
                                OTHERWISE :WRITELN('E');
                                END;
                              END;
                          END;
                        WRITELN;
                        WRITELN;
                      END;                   (* L *)
                'E' : WRITELN;   
                OTHERWISE : BEGIN
                              WRITELN('Eingabe unzulaessig !');
                              WRITELN;
                            END;  
                END;                         (* CASE CH1 *)

            END;                             (* WHILE CH1 ... *)

          WRITELN;
          WRITELN('P druecken, falls Wertetabelle auf File OUTPUT.DAT');
          WRITE('abgelegt werden soll. Ansonsten E druecken : ');
          READLN(CH1);
          IF (CH1 = 'p') THEN CH1:='P';
          CH2 := CH1;
          IF (CH1 = 'P') THEN
            BEGIN
              WRITELN;
              WRITELN;
              WRITE('Drucke ab Zeile ');
              READLN(LINU);
              WRITE('bis Zeile ');
              READLN(LINO);
              WRITELN;

              IF (LINO < LINU) THEN
                BEGIN
                  ERR1;
                  CH2:='E';
                END;

              IF ((LINU > NMAX-1) OR (LINO < 0)) THEN
                BEGIN
                  ERR2;
                  CH2:='E';
                END;

              IF (LINU < 0) THEN LINU:=0;
              IF (LINO > NMAX-1) THEN LINO:=NMAX-1;

              IF (CH2 <> 'E') THEN
                BEGIN
                  FOR J:=LINU TO LINO DO
                    BEGIN
                      IF ((J MOD BH) = 0) THEN WRTABP(NVAR);
                      WRLINP(J,NVAR,A);
                                
                      CASE ARY[J+1,1] OF
                        0 : WRITELN(OD,'0');
                        1 : WRITELN(OD,'1');
                        2 : WRITELN(OD,'X');
                      OTHERWISE :WRITELN(OD,'E');
                      END;
                    END;
                END;
                WRITELN;
                WRITELN;
            END;                   (* Print-Block *)
          
(* AUSSORTIEREN DER MINTERME UND DON`T CARE TERME *)

          MKO:=0;
          MDC:=0;
          FOR I:=1 TO NMAX DO
            BEGIN
              IF ( ARY[I,1] = 1) THEN
                BEGIN
                  MKO:=MKO+1;
                  KONJ[MKO]:=I-1;
                END;
            END;
          FOR I:=1 TO NMAX DO
            BEGIN
              IF ( ARY[I,1] = 2) THEN
                BEGIN
                  MDC:=MDC+1;
                  KONJ[MKO+MDC]:=I-1;
                END;
            END;

(* TEST AUF SINNVOLLE WERTETABELLE (MINDESTENS 1 MINTERM) *)

          IF (MKO <= 0) THEN
            BEGIN
              WRITELN;
              WRITELN;
              WRITELN('KEINE MINTERME VORHANDEN !');
              WRITELN;
            END
          ELSE
            BEGIN                           (* QUINE-McCLUSKEY MINIMIERUNG *)
              QMC (KONJ,PIMP,ARY,LZ,MKO,MDC,IP);
              MPARTS:=MKO DIV CLEN;
              IF ( (MKO MOD CLEN) <> 0) THEN MPARTS:=MPARTS+1;
              START := 1;
              FOR IPARTS:=1 TO MPARTS DO
                BEGIN
                  IF (IPARTS = MPARTS) THEN IKO := MKO MOD CLEN
                                       ELSE IKO := CLEN;
                  STOP := START + (IKO-1);
                  WRITELN(OD);
                  WRITELN(OD);                       
                  WRITE(OD,'PRIMIMPLIKANTENTABELLE');(**********************)
                  WRITELN(OD,' Teil: ',IPARTS);      (*                    *)
                  FOR I:=1 TO 22 DO WRITE(OD,'-');   (* AUSDRUCK DER PRIM- *)
                  WRITELN(OD);                       (* IMPLIKANTENTABELLE.*)
                  WRITELN(OD);                       (*                    *)
                                                     (**********************)
                  FOR I:=1 TO IP DO
                    BEGIN
                      CONV(3,PIMP[I],M,A); (* TERNAERWANDLUNG PRIMIMPLIKANT *)
                      IF (M < (NVAR-1)) THEN FOR J:=(M+1) TO (NVAR-1) DO A[J]:=0;
                      (* WRITE(OD,PIMP[I]:4,' '); *)
                      FOR J:=(NVAR-1) DOWNTO 0 DO
                        BEGIN
                          IF (A[J] <> 2) THEN WRITE(OD,A[J]:1)
                          ELSE WRITE(OD,'-');
                        END;
                      WRITE(OD,' ');

                      FOR J:=START TO STOP DO
                        BEGIN
                          CONV(2,KONJ[J],M,C);  (* BINAERWANDLUNG MINTERM *)
                          IF (M < (NVAR-1)) THEN FOR N:=(M+1) TO (NVAR-1) DO 
                          C[N]:=0;
                          B:=1;
                          FOR N:=0 TO (NVAR-1) DO
                          IF ((A[N] <> 2) AND (A[N] <> C[N])) THEN B:=0;
                          WRITE(OD,B:1);
                        END;
                      WRITELN(OD);
                    END; (* FOR I:=1 ... *)
                    START := STOP + 1;
                    WRITELN(OD);
                    WRITELN(OD);
                END; (* FOR IPARTS:=1 ... *)    
            END; (* IF (MKO <= 0) THEN *)
         END.

