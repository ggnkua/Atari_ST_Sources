IMPLEMENTATION MODULE RayTrace;

(*$ R- *)

FROM MathLib0 IMPORT sqrt,power,entier;
FROM LineA    IMPORT LineAVars, PtrLineAVars,
                     PutPixel, LineAVariables;
FROM GrafBase IMPORT WritingMode,Pnt;
FROM XBIOS    IMPORT GetResolution;

VAR   vars : PtrLineAVars;
      res,y_res: INTEGER;

      
(* ------------------------------------------------ *)

PROCEDURE Ebene1schn (VAR Pktz,Vecz:LONGREAL ; VAR Index:INTEGER ;
                      VAR Lambda:LFeld );
   
BEGIN
  (* Schnitt Basisebene - Blickgerade *)
  INC (Index);
  IF (Vecz=0.0) THEN
    Lambda[Index]:=Unendlich
  ELSE
    Lambda[Index]:=-Pktz/Vecz
  END (* IF *)
END Ebene1schn;


PROCEDURE Ebene1weiter (VAR Pktx,Pkty,Vecx,Vecy:LONGREAL ;
                        VAR Lambda:LFeld ;
                        VAR Index,Farbe,Untersuchungsende:INTEGER );
                        
VAR Spktx,Spkty:LONGREAL;
                        
BEGIN
  (* Farbe errechnen, die sich durch Schnitt mit Ebene 1 ergibt *)
  (* Schnittpkt.-Koordinaten *)
  Spktx:=Pktx+Lambda[Index]*Vecx;
  Spkty:=Pkty+Lambda[Index]*Vecy;
  (* Farbe an der Stelle des Schnittpunktes ermitteln (Karo-Muster) *)
  IF ((ABS(Spktx)>5.0) OR (ABS(Spkty)>5.0)) THEN
    Farbe:=0
  ELSE
    (* ---- In der folgenden Zeile tritt der Fehler auf ---- *)
    Farbe:=SHORT(entier(Spktx*1.6))+SHORT(entier(Spkty*1.6))+32;
    Farbe:=SHORT (VAL(LONGINT,Spktx*1.6))+SHORT (VAL(LONGINT,Spkty*1.6))+32;
    Farbe:=(Farbe MOD 2)+1
  END; (* IF *)
  Untersuchungsende:=-1
END Ebene1weiter;

PROCEDURE Kugel1schn (VAR Pktx,Pkty,Pktz,Vecx,Vecy,Vecz,
                          Kug1pktx,Kug1pkty,Kug1pktz,Kug1rquad:LONGREAL;
                      VAR Lambda:LFeld;
                      VAR Index :INTEGER );
                      
VAR A,B,C,D,E,Disk:LONGREAL;

BEGIN
  (* Schnitt Kugel - Blickgerade  *)
  INC (Index);
  A:=Pktx-Kug1pktx;
  B:=Pkty-Kug1pkty;
  C:=Pktz-Kug1pktz;
  D:=power(Vecx,2.0)+power(Vecy,2.0)+power(Vecz,2.0);
  E:=Vecx*A+Vecy*B+Vecz*C;
  Disk:=power(E,2.0)-D*(power(A,2.0)+power(B,2.0)+power(C,2.0)-Kug1rquad);
  IF (Disk<0.0) THEN
    (* kein Schnittpunkt vorhanden *)
    Lambda[Index]:=Unendlich
  ELSE
    Lambda[Index]:=(-E-sqrt(Disk))/D;
    IF (Lambda[Index]<0.001) THEN
      (* Schnittpunkt in falscher Richtung vorhanden, unbrauchbar *)
      Lambda[Index]:=Unendlich
    END (* IF *)
  END (* IF *)
END Kugel1schn;


PROCEDURE Kugel1weiter (VAR Pktx,Pkty,Pktz,Vecx,Vecy,Vecz,
                            Kug1pktx,Kug1pkty,Kug1pktz,Kug1rquad:LONGREAL;
                        VAR Lambda:LFeld;
                        VAR Index,Farbversch:INTEGER );
                        
VAR F,Mvecx,Mvecy,Mvecz:LONGREAL;

BEGIN
  (* neue Punkt-Richtungs-Gerade errechnen (durch Spiegelung) *)
  (* Schnittpunkt *)
  Pktx:=Pktx+Lambda[Index]*Vecx;
  Pkty:=Pkty+Lambda[Index]*Vecy;
  Pktz:=Pktz+Lambda[Index]*Vecz;
  (* Vektor Mittelpunkt-Schnittpunkt *)
  Mvecx:=Pktx-Kug1pktx;
  Mvecy:=Pkty-Kug1pkty;
  Mvecz:=Pktz-Kug1pktz;
  F:=(Mvecx*Vecx+Mvecy*Vecy+Mvecz*Vecz)/Kug1rquad;
  (* neuer Richtungsvektor *)
  Vecx:=Vecx-2.0*F*Mvecx;
  Vecy:=Vecy-2.0*F*Mvecy;
  Vecz:=Vecz-2.0*F*Mvecz;
  INC(Farbversch,2)
END Kugel1weiter;

PROCEDURE Ebene2schn ( VAR Pktx,Pkty,Pktz,Vecx,Vecy,Vecz,
                           Zyl1pktx,Zyl1pkty,Zyl1rquad,Zyl1hoehe:LONGREAL ;
                       VAR Lambda:LFeld;
                       VAR Index :INTEGER );
                       
VAR Abstandquad,Xko,Yko:LONGREAL;
                        
BEGIN
  (* Schnitt Ebene 2 (d.i. der Deckel des Zylinders) mit Blickgerade *)
  INC (Index);
  IF (Vecz=0.0) THEN
    Lambda[Index]:=Unendlich
  ELSE
    Lambda[Index]:=(Zyl1hoehe-Pktz)/Vecz;
    Xko:=Pktx+Lambda[Index]*Vecx;
    Yko:=Pkty+Lambda[Index]*Vecy;
    Abstandquad:=power((Zyl1pktx-Xko),2.0)+power((Zyl1pkty-Yko),2.0);
    IF (Abstandquad>Zyl1rquad) THEN
      Lambda[Index]:=Unendlich
    END (* IF *)
  END (* IF *)
END Ebene2schn;


PROCEDURE Ebene2weiter ( VAR Untersuchungsende,Farbe:INTEGER );

BEGIN
  (* Farbe errechnen, die sich durch Schnitt mit Ebene 2 ergibt *)
  Untersuchungsende:=-1;
  Farbe:=4
END Ebene2weiter;

PROCEDURE Glasz1schn (VAR Pktx,Pkty,Pktz,Vecx,Vecy,Vecz,
                          Zyl1pktx,Zyl1pkty,Zyl1rquad,Zyl1hoehe:LONGREAL;
                      VAR Lambda:LFeld;
                      VAR Index :INTEGER );
                      
VAR A,B,C,D,E,Disk:LONGREAL;
                      
BEGIN
(* Schnitt Glaszylinder - Blickgerade von aužen *)
  INC (Index);
  A:=Pktx-Zyl1pktx;
  C:=Pkty-Zyl1pkty;
  D:=power(Vecx,2.0)+power(Vecy,2.0);
  E:=Vecx*A+Vecy*C;
  Disk:=power(E,2.0)-D*(power(A,2.0)+power(C,2.0)-Zyl1rquad);
  IF (Disk<0.0) THEN
    (* kein Schnittpunkt vorhanden *)
    Lambda[Index]:=Unendlich
  ELSE
    Lambda[Index]:=(-E-sqrt(Disk))/D;
    IF ((Lambda[Index]<0.001) OR (Pktz+Lambda[Index]*Vecz>Zyl1hoehe)) THEN
      (* der Schnittpunkt ist entweder in der falschen Richtung oder *)
      (* zu hoch, daher zweiten Schnittpunkt errechnen *)
      Lambda[Index]:=(-E+sqrt(Disk))/D;
      IF ((Lambda[Index]<=0.001) OR (Pktz+Lambda[Index]*Vecz>Zyl1hoehe)) THEN
        (* auch der zweite Schnittpunkt entspricht nicht den Forderungen *)
        Lambda[Index]:=Unendlich
      END (* IF *)
    END (* IF *)
  END (* IF *)
END Glasz1schn;


PROCEDURE Glasz1weiter (VAR Pktx,Pkty,Pktz,Vecx,Vecy,Vecz,
                            Zyl1pktx,Zyl1pkty,Zyl1rquad,
                            Brechindex:LONGREAL;
                        VAR Lambda:LFeld;
                        VAR Index,Farbversch:INTEGER );
                      
VAR F,Veclenquad,Veclenquad1,Veclen,Veclen1,Projvecx,Projvecy,Projlenquad,
    Projlen,Projlen1,Constquad,Laenge,Ende,Mvecx,Mvecy:LONGREAL;
    
BEGIN
  (* neue Punkt-Richtungs-Gerade errechnen (durch Brechung) *)
  Pktx:=Pktx+Lambda[Index]*Vecx;
  Pkty:=Pkty+Lambda[Index]*Vecy;
  Pktz:=Pktz+Lambda[Index]*Vecz;
  (* L„nge Blickvektor *)
  Veclenquad:=power(Vecx,2.0)+power(Vecy,2.0);
  Veclen:=sqrt(Veclenquad);
  (* Vektor zur Drehachse des Zylinders *)
  Mvecx:=Pktx-Zyl1pktx;
  Mvecy:=Pkty-Zyl1pkty;
  F:=(Mvecx*Vecx+Mvecy*Vecy)/Zyl1rquad;
  (* Bilckvektor auf Mvec projezieren *)
  Projvecx:=F*Mvecx;
  Projvecy:=F*Mvecy;
  Projlenquad:=power(Projvecx,2.0)+power(Projvecy,2.0);
  Projlen:=sqrt(Projlenquad);
  (* Konstante *)
  Constquad:=Veclenquad-Projlenquad;
  Veclen1:=Veclen*Brechindex;
  Veclenquad1:=power(Veclen1,2.0);
  IF (Veclenquad1<Constquad) THEN
    (* Totalrefelxion *)
    Ende:=-1.0
  ELSE
    (* Normale Brechung *)
    Projlen1:=sqrt(Veclenquad1-Constquad);
    (* Faktor fr Verl„ngerung *)
    Laenge:=Projlen1-Projlen;
    (* neuer Richtungsvektor *)
    Vecx:=Vecx+Laenge*Projvecx/Projlen;
    Vecy:=Vecy+Laenge*Projvecy/Projlen;
    Brechindex:=1.0/Brechindex;
    INC(Farbversch)
  END (* IF *)
END Glasz1weiter;


PROCEDURE Zylin1schn (VAR Pktx,Pkty,Pktz,Vecx,Vecy,Vecz,
                          Zyl1pktx,Zyl1pkty,Zyl1hoehe,Zyl1rquad:LONGREAL;
                      VAR Lambda:LFeld;
                      VAR Index :INTEGER );
                      
VAR A,B,C,D,E,Disk,Hoehe:LONGREAL;

BEGIN
  (* Schnitt Zylinder - Blickgerade *)
  INC (Index);
  A:=Pktx-Zyl1pktx;
  B:=Pkty-Zyl1pkty;
  D:=power(Vecx,2.0)+power(Vecy,2.0);
  E:=Vecx*A+Vecy*B;
  Disk:=power(E,2.0)-D*(power(A,2.0)+power(B,2.0)-Zyl1rquad);
  IF (Disk<0.0) THEN
    (* kein Schnittpunkt vorhanden *)
    Lambda[Index]:=Unendlich
  ELSE
    Lambda[Index]:=(-E-sqrt(Disk))/D;
    Hoehe:=Pktz+Vecz*Lambda[Index];
    IF Hoehe>Zyl1hoehe THEN
      (* Schnittpunkt liegt zu hoch *)
      Lambda[Index]:=Unendlich
    END (* IF *)
  END (* IF *)
END Zylin1schn;


PROCEDURE Zylin1weiter (VAR Pktx,Pkty,Pktz,Vecx,Vecy,Vecz,
                            Zyl1pktx,Zyl1pkty,Zyl1rquad:LONGREAL;
                        VAR Lambda:LFeld;
                        VAR Farbversch,Index:INTEGER );
                        
VAR F,Mvecx,Mvecy:LONGREAL;

BEGIN
  (* neue Punkt-Richtungs-Gerade errechnen (ergibt sich durch Spiegelung) *)
  Pktx:=Pktx+Lambda[Index]*Vecx;
  Pkty:=Pkty+Lambda[Index]*Vecy;
  Pktz:=Pktz+Lambda[Index]*Vecz;
  Mvecx:=Pktx-Zyl1pktx;
  Mvecy:=Pkty-Zyl1pkty;
  F:=(Mvecx*Vecx+Mvecy*Vecy)/Zyl1rquad;
  Vecx:=Vecx-2.0*F*Mvecx;
  Vecy:=Vecy-2.0*F*Mvecy;
  INC(Farbversch,2)
END Zylin1weiter;


PROCEDURE Drehk1schn (VAR Pktx,Pkty,Pktz,Vecx,Vecy,Vecz,
                          Dk1pktx,Dk1pkty,Dk1stquad,Dk1hoehe:LONGREAL;
                      VAR Lambda:LFeld;
                      VAR Index :INTEGER );
                      
VAR A,B,C,D,E,Disk,Hoehe:LONGREAL;

BEGIN
  (* Schnitt Drehkegel - Blickgerade *)
  INC (Index);
  A:=Pktx-Dk1pktx;
  B:=Pkty-Dk1pkty;
  C:=Pktz;
  D:=power(Vecx,2.0)+power(Vecy,2.0)-power(Vecz,2.0)/Dk1stquad;
  E:=Vecx*A+Vecy*B-Vecz*C/Dk1stquad;
  Disk:=power(E,2.0)-D*(power(A,2.0)+power(B,2.0)-power(C,2.0)/Dk1stquad);
  IF (Disk<0.0) THEN
    (* kein Schnittpunkt vorhanden *)
    Lambda[Index]:=Unendlich
  ELSE
    Lambda[Index]:=(-E-sqrt(Disk))/D;
    Hoehe:=Pktz+Vecz*Lambda[Index];
    IF (Hoehe>Dk1hoehe) THEN
      (* Schnittpunkt zu hoch *)
      Lambda[Index]:=Unendlich
    END (* IF *)
  END (* IF *)
END Drehk1schn;


PROCEDURE Drehk1weiter (VAR Pktx,Pkty,Pktz,Vecx,Vecy,Vecz,
                            Dk1pktx,Dk1pkty,Dk1steig:LONGREAL;
                        VAR Lambda:LFeld;
                        VAR Index,Farbversch:INTEGER);
                        
VAR F,Radiusquad,Mvecx,Mvecy,Mvecz,Mlen:LONGREAL;

BEGIN
  (* neue Punkt-Richtungs-Gerade errechnen (ergibt sich durch Spiegelung) *)
  Pktx:=Pktx+Lambda[Index]*Vecx;
  Pkty:=Pkty+Lambda[Index]*Vecy;
  Pktz:=Pktz+Lambda[Index]*Vecz;
  Mvecx:=Pktx-Dk1pktx;
  Mvecy:=Pkty-Dk1pkty;
  Radiusquad:=power(Mvecx,2.0)+power(Mvecy,2.0);
  Mvecz:=-sqrt(Radiusquad)/Dk1steig;
  Mlen:=Radiusquad+power(Mvecz,2.0);
  F:=(Mvecx*Vecx+Mvecy*Vecy+Mvecz*Vecz)/Mlen;
  Vecx:=Vecx-2.0*F*Mvecx;
  Vecy:=Vecy-2.0*F*Mvecy;
  Vecz:=Vecz-2.0*F*Mvecz;
  INC(Farbversch,2)
END Drehk1weiter;

PROCEDURE Plot_Sw (X,Y,Farbe:INTEGER);
  (* Unterprogramm, um Pixel in 5 Graustufen zu zeichnen *)
  (* Koordinaten in X/Y, Farbinformation in Farbe *)
  (* Koordinaten verdoppeln *)
BEGIN
  X:=X*2;
  Y:=Y*2;
  IF Farbe>=1 THEN
    PutPixel (Pnt(X,Y),1);
    IF Farbe>=2 THEN
      PutPixel (Pnt(X+1,Y+1),1);
      IF Farbe>=3 THEN
        PutPixel (Pnt(X+1,Y),1);
        IF Farbe>=4 THEN
          PutPixel (Pnt(X,Y+1),1)
        END (* IF *)
      END (* IF *)
    END (* IF *)
  END (* IF *)
END Plot_Sw;


PROCEDURE Plot (X,Y,Farbe:INTEGER);

BEGIN
  PutPixel (Pnt(X,Y),VAL(CARDINAL,Farbe))
END Plot;


(* -------------------------------------------------- *)


BEGIN
  res:=GetResolution();    (* Aufl”sung bestimmen *)
  CASE res OF
             2:y_res:=399  (* ST Hoch   *)
           | 4:y_res:=479  (* TT Mittel *)
           ELSE HALT       (* Sonst Ende *)
  END; (* Case *)
  vars:=LineAVariables ();
  WITH vars^ DO
    writingMode:=replaceWrt;
    plane1:=TRUE;
    lineMask:=$FFFF;
    lastLine:=TRUE;
    clipping:=TRUE;
    minClip:=Pnt(0,0);
    maxClip:=Pnt(639,y_res)
  END
END RayTrace.
