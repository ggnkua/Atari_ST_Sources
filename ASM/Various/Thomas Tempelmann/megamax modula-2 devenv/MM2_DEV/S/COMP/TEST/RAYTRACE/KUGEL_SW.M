MODULE Kugel_Sw;

(*$ R- *)
(*$ E MOS *)
IMPORT TOSIO;

FROM SYSTEM IMPORT ASSEMBLER;

FROM RayTrace IMPORT Ebene1schn,Ebene1weiter,Kugel1schn,Kugel1weiter,Plot_Sw,
                     Plot,Unendlich,LFeld;
FROM MathLib0 IMPORT sin,cos,tan,sqrt,power,pi,entier;

FROM InOut    IMPORT Write,WritePg,Read,KeyPressed;

VAR Xreso,Yreso,Halbxreso,Halbyreso,Kug1pktx,Kug1pkty,Kug1pktz,Radius,
    Kug1rquad,Startpktx,Startpkty,Startpktz,Endpktx,Endpkty,Endpktz,
    Alphahor,Alphaver,Blivecx,Blivecy,Blivecz,Blilen,Horivecx,Horivecy,
    Horivecz,Vertvecx,Vertvecy,Vertvecz,Horilen,Horilen1,Vertlen,Vertlen1,
    Ykoor,Xkoor,Vecx,Vecy,Vecz,Pktx,Pkty,Pktz,Lambdamin,Objektanzahl:LONGREAL;
    Index,Farbe,Farbversch,Untersuchungsende,Weiter:INTEGER;
    Lambda:LFeld;
    key:CHAR;

BEGIN
  WritePg;
  Xreso:=320.0;
  Yreso:=200.0;
  Halbxreso:=Xreso/2.0;
  Halbyreso:=Yreso/2.0;
  (* Zahl der vorhanden K”rper + Fl„chen *)
  Objektanzahl:=2.0;
  (* Daten fr Kugel 1 festlegen *)
  Kug1pktx:=0.0;
  Kug1pkty:=0.0;
  Kug1pktz:=1.2;
  Radius:=1.2;
  Kug1rquad:=power(Radius,2.0);
  
  (* Blickrichtung festlegen, die notwendigen Vektoren fr weitere *)
  (* Berechnungen errechnen *)
  Startpktx:=4.0;
  Startpkty:=-7.0;
  Startpktz:=2.5;
  Endpktx:=0.0;
  Endpkty:=0.0;
  Endpktz:=1.0;
  (* horiz. Blickwinkel in Grad *)
  Alphahor:=16.0;
  (* in Bogenmaž umgewandeln *)
  Alphahor:=Alphahor*pi/180.0;
  (* vertikaler Blickwinkel entspechend der Aufl”sung *)
  Alphaver:=(Alphahor/Xreso*Yreso)*1.05;
  (* Blickvektor und darauf senkrecht stehende Seitenvektoren *)
  Blivecx:=Endpktx-Startpktx;
  Blivecy:=Endpkty-Startpkty;
  Blivecz:=Endpktz-Startpktz;
  Blilen:=sqrt(power(Blivecx,2.0)+power(Blivecy,2.0)+power(Blivecz,2.0));
  (* Horizontaler Seitenvektor *)
  Horivecx:=Blivecy;
  Horivecy:=-Blivecx;
  Horivecz:=0.0;
  (* vertikaler Seitenvektor *)
  Vertvecx:=Blivecz*Horivecy-Blivecy*Horivecz;
  Vertvecy:=Blivecx*Horivecz-Blivecz*Horivecx;
  Vertvecz:=Blivecy*Horivecx-Blivecx*Horivecy;
  (* L„nge des horizontalen Seitenvektor bestimmen *)
  Horilen:=sqrt(power(Horivecx,2.0)+power(Horivecy,2.0));
  Horilen1:=tan(Alphahor)*2.0/Xreso*Blilen;
  Horivecx:=Horivecx/Horilen*Horilen1;
  Horivecy:=Horivecy/Horilen*Horilen1;
  (* L„nge des vertikalen Seitenvektors bestimmen *)
  Vertlen:=sqrt(power(Vertvecx,2.0)+power(Vertvecy,2.0)+power(Vertvecz,2.0));
  Vertlen1:=tan(Alphaver)*2.0/Yreso*Blilen;
  Vertvecx:=Vertvecx/Vertlen*Vertlen1;
  Vertvecy:=Vertvecy/Vertlen*Vertlen1;
  Vertvecz:=Vertvecz/Vertlen*Vertlen1;
  
  
  (* Hauptprogramm: berechnet fr jeden darzustellenden Punkt eine *)
  (*   Blickgerade; diese wird mit allen zur Verfgung stehenden *)
  (*   Fl„chen und K”rpern geschnitten; der K”rper mit der krzesten *)
  (*   positiven Entfernung zum Blickpunkt wird zum Weiterrechnen *)
  (*   verwendet *)
  
  (* Schleifen fr alle darzustellenden Punkte *)
  Ykoor:=-Halbyreso;
  REPEAT
    Xkoor:=-Halbxreso;
    REPEAT
      (* momentanen Blickgerade errechnen *)
      Vecx:=Blivecx+Horivecx*Xkoor+Vertvecx*Ykoor;
      Vecy:=Blivecy+Horivecy*Xkoor+Vertvecy*Ykoor;
      Vecz:=Blivecz+Horivecz*Xkoor+Vertvecz*Ykoor;
      Pktx:=Startpktx;
      Pkty:=Startpkty;
      Pktz:=Startpktz;
      Untersuchungsende:=0;
      Farbe:=0;
      Farbversch:=0;
      REPEAT
        (* Blickgerade mit allen K”rpern schneiden *)
        Index:=0;
        Ebene1schn (Pktz,Vecz,Index,Lambda);
        Kugel1schn (Pktx,Pkty,Pktz,Vecx,Vecy,Vecz,
                    Kug1pktx,Kug1pkty,Kug1pktz,Kug1rquad,
                    Lambda,Index);
        (* Schnittpunkt mit kleinstem Abstand zum Blickpunkt suchen *)
        Lambdamin:=Unendlich;
        ASSEMBLER BREAK END;
        FOR Index:=1 TO SHORT(entier(Objektanzahl)) DO END;
        FOR Index:=1 TO SHORT(VAL(LONGINT,Objektanzahl)) DO END;
        FOR Index:=1 TO VAL(INTEGER,Objektanzahl) DO
          IF ((Lambda[Index]>0.0) AND (Lambda[Index]<Lambdamin)) THEN
            Lambdamin:=Lambda[Index];
            Weiter:=Index
          END
        END;
        (* Exit wenn kein Schnittpkt. gefunden *)
        IF NOT (Lambdamin=Unendlich) THEN
          (* Fortsetzung der Behandlung beim Objekt in kleinster Entfernung *)
          Index:=Weiter;
          CASE Weiter OF
               1 : Ebene1weiter (Pktx,Pkty,Vecx,Vecy,Lambda,Index,Farbe,
                                 Untersuchungsende)
             | 2 : Kugel1weiter (Pktx,Pkty,Pktz,Vecx,Vecy,Vecz,
                                 Kug1pktx,Kug1pkty,Kug1pktz,Kug1rquad,
                                 Lambda,Index,Farbversch)
          END;
        END
      UNTIL ((Untersuchungsende=-1) OR (Farbversch>3) OR (Lambdamin=Unendlich));
      (* Ausgabe des errechneten Punktes *)
      IF (Farbe+Farbversch<>0) THEN
        Plot_Sw (SHORT(VAL(LONGINT,Halbxreso+Xkoor)),
                 SHORT(VAL(LONGINT,Halbyreso-Ykoor)),
                 SHORT(VAL(LONGINT,Farbe+Farbversch)))
      END;
    Xkoor:=Xkoor+1.0
    UNTIL (Xkoor>=Halbxreso);
  Ykoor:=Ykoor+1.0;
  IF KeyPressed() THEN HALT;END
  UNTIL (Ykoor>=Halbyreso);
  REPEAT
    Read (key)
  UNTIL (ORD(key)=27)
END Kugel_Sw.
