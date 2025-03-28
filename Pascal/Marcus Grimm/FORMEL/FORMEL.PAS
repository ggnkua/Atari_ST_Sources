(* Routinen zur Graphischen Formel-Darstellung *)
(* von Marcus Grimm                            *)
UNIT FORMEL;

INTERFACE

USES GEMDECL,GEMVDI,GEMAES,GEM,TREE;

TYPE
    LeftRight = (Left,Right);
    ObjTypen  = (Strich,ZKette,KlammerL,
                 KlammerR,Wurzel);
    GFPtr     = ^Formel_Liste;
    (* Listen-Element : *)
    Formel_Liste = Record
     Next     : GFPtr;    (* NÑchstes Objekt *)
     (* Zum Zeichnen benîtigte Daten : *)
     Case ObjektTyp : ObjTypen Of
      Strich   : (Xs,Ys,Bs : Integer);
      ZKette   : (Xz,Yz,Ch : Integer;
                       Str : String[10]);
      KlammerL,
      KlammerR : (Xk,Yk,Hk : Integer);
      Wurzel   : (Xw,Yw,Bw,Hw : Integer);
    End;
    (* Header der Liste *)
    Formel_Graphik = Record
     Breite,  (* Breite *)
     HTop,    (* Abstand Mittellinie-Oberkante *)
     HAbs : Integer;   (* Absolute Hîhe *)
     Formel : GFPtr;   (* Pointer auf Liste *)
    End;
    
(* Erzeugt eine Objekt-Liste der Formel        *)
(* Fkt = Funktion als Baum                     *)
Procedure MakeFormelList(Fkt : FktPtr;
                 Var FktListe : Formel_Graphik);

(* Ausgabe der Formel                          *)
(* x0,y0 = linke obere Ecke der Formel         *)
Procedure PlotFormelList(X0,Y0 : Integer;
                 Var FktListe : Formel_Graphik);

(* Lîschen der Objekt-Liste                    *)
Procedure DelFormelList(
                 Var FktListe : Formel_Graphik);

IMPLEMENTATION
CONST  (* Pixel-Grîûen normale Schrift :       *)
       BIGCB   = 8; (* Zeichen Breite          *)
       BIGCH   = 13;(* Zeichen-Hîhe            *)
       (* Pixel-Grîûen kleine Schrift :        *)
       SMALLCB = 8; (* Zeichen-Breite          *)
       SMALLCH = 7; (* Zeichen-Hîhe            *)

(* Stellt fest, ob Aufgrund des Operator Typs  *)
(* eine Klammer nîtig ist. Z.B.: (X+1)*(X-1)   *)
Function KlNoetig(Var Fkt : FktPtr;
                  Wo : LeftRight):Boolean;
Var LrPtr : FktPtr;
Begin
 KlNoetig:=False;
 If Wo = Left Then LrPtr:=Fkt^.Links
 Else LrPtr:=Fkt^.Rechts;
 If Fkt^.Art = Operator Then
 Case Fkt^.OpNr Of
  Minus,Mal : If LrPtr^.Art = Operator Then
              If LrPtr^.OpNr IN [Plus,Minus] Then
                KlNoetig:=True;
  Hoch      : If LrPtr^.Art = Operator Then
               If LrPtr^.OpNr
                IN [Plus,Minus,Mal,Durch,Hoch] 
                Then KlNoetig:=True
               Else
              Else
              If LrPtr^.Art = Vorzeichen Then 
               KlNoetig:=True;
 End (* Case *)
 Else
 If Fkt^.Art = Vorzeichen Then
  If LrPtr^.Art = Operator Then
   If LrPtr^.OpNr IN [Plus,Minus] Then 
    KlNoetig:=True;
End;

Procedure MakeFormelList( Fkt : FktPtr;
                Var FktListe : Formel_Graphik);
CONST
     (* Standart Funktionen, vgl. UNIT TREE    *)
     funk : array[1..MAXFUNK] of string[6]=
            ('+','-','*','/','^',
             'Sin','Cos','Tan',
             'ArcSin','ArcCos','ArcTan',
             'Sinh','Cosh','Tanh','ArSinh',
             'ArCosh','ArTanh','Exp','Ln','Sgn',
             'Sqr','Sqrt','');
       
Var  Charh,Charb, (* aktuelle Zeichen-Grîûen   *)
     breite,hoehe : Integer;
     yunten,X0,Y0 : Integer;
     ZahlStr : String;
     EndPtr,StartPtr : GFPtr;

(* FÅgt neues Objekt in Liste ein              *)
Procedure NewObjekt(Art : ObjTypen;
                    Xo,Yo,Bo,Ho : Integer;
                    Zk : String);
Var HelpPtr : GFPtr;
Begin
 New(HelpPtr);
 With HelpPtr^ Do
 Begin
  objektTyp:=art;
  Case Art Of
   Strich : Begin (* Bruchstrich  *)
             Xs:=Xo; Ys:=Yo; Bs:=Bo;
            End;
   Zkette : Begin (* Zeichenkette *)
             Xz:=Xo; Yz:=Yo; CH:=CharH;
             Str:=Zk;
            End;
   KlammerR,
   KlammerL: Begin (* Klammerung *)
              Xk:=Xo; Yk:=Yo; Hk:=Ho;
             End;
   Wurzel : Begin
             Xw:=Xo; Yw:=Yo; Bw:=Bo; Hw:=Ho;
            End;
  End;(* CASE *)
  Next:=NIL;
 End;(* With *)
 If EndPtr = NIL Then (* Liste ist noch leer *)
 Begin
  EndPtr:=HelpPtr;
  StartPtr:=HelpPtr;
 End
 Else (* sonst am Ende anhÑngen *)
 Begin
  EndPtr^.Next:=HelpPtr;
  EndPtr:=EndPtr^.Next;
 End;
End; 

(* ôffnende Klammer ,Hîhe H , an X,Y           *)
Procedure LBrak(Var X : Integer; Y,H : Integer;
                Draw : Boolean);
Begin
 If Draw Then NewObjekt(KlammerL,X,Y+1,0,H,'');
 Inc(X,4);
End;

(* Schlieûende Klammer                         *)
Procedure RBrak(Var X,Y,H : Integer;
                Draw :Boolean);
Begin
 Inc(X,2);
 If Draw Then NewObjekt(KlammerR,X,Y+1,0,H,'');
 Inc(H,4); Inc(Y,2);
 Inc(X,2);
End;

(* WÅhlt sich rekursiv durch Fkt.-Baum         *)
(* Berechnet zuerst die Grîûen von TeilbÑumen  *)
(* (Draw = False) und trÑgt sie dann in die    *)
(* Liste (Draw = True) ein.                    *)
(* Y,Y = Startposition. B,H = Errechnete Maûe  *)
(* YMin = Unterster Punkt der Formel           *)
Procedure MakeList(Fkt : FktPtr;X,Y : Integer;
                   Var B,H,YMin : Integer;
                   Draw : Boolean);
Var kl : Boolean;
    C1,C2,B1,B2,H1,H2,Y1,Y2 : Integer;
Begin
 If Fkt <> NIL Then
 Begin
  Case Fkt^.Art Of
  C_Pi : 
   Begin(* Pi als Graphik-Zeichen *)
    If Draw Then 
     NewObjekt(ZKette,X,Y,0,0,#$E3);
    B:=CharB; H:=CharH;
    YMin:=Y;
   End;
  Zahl : 
   Begin
    If Int(fkt^.Wert) = Fkt^.Wert Then
     Str(Trunc(fkt^.wert),ZahlStr)
    Else Str(fkt^.Wert:2:4,ZahlStr);
    If ZahlStr[1] = ' ' Then Delete(ZahlStr,1,1);
    If Draw Then (* In Liste eintragen *)
     NewObjekt(ZKette,X,Y,0,0,Zahlstr);
    B:=Ord(ZahlStr[0])*CharB; (* Ausmaûe *)
    H:=CharH; YMin:=Y;
   End;
  Varx :
    Begin (* Trivial... *)
     If Draw Then NewObjekt(ZKette,X,Y,0,0,'X');
     H:=Charh; B:=CharB; Ymin:=Y;
    End;
  vorzeichen : (* Z.B.: -(X+1)  *)
    begin
     kl:=KlNoetig(Fkt,Right);(* Klammer ? *)
     If Draw Then NewObjekt(ZKette,X,Y,0,0,'-');
     Inc(X,CharB+1); (* Platz machen *)
     If Kl Then (* ôffnende Klammer *)
     Begin (* Erst Ausmaûe bestimmen... *)
      MakeList(Fkt^.Rechts,X,Y,B1,H,YMin,False);
      LBrak(X,YMin,H,Draw);
     End;
     MakeList(Fkt^.Rechts,X,Y,B1,H,YMin,Draw);
     Inc(X,B1);
     If kl Then (* Klammer schlieûen *)
     Begin
      RBrak(X,YMin,H,Draw);
      Inc(B1,CharB+1);
     End;
     B:=B1+CharB;
    End;
  Funktion :
    If Fkt^.OpNr = FSQRT Then
    Begin (* Wurzel Zeichnen *)
     MakeList(Fkt^.Rechts,X,Y,B,H,YMin,False);
     If Draw Then 
      NewObjekt(Wurzel,X,YMin+2,B+13,H+4,'');
     Inc(X,11);
     MakeList(fkt^.Rechts,X,Y,B,H,YMin,Draw);
     Inc(YMin,2); Inc(B,15); Inc(H,5);
    End
    Else
    Begin (* Standart Funktion *)
     If Draw Then 
      NewObjekt(ZKette,X,Y,0,0,Funk[Fkt^.OpNr]);
     B1:=Length(funk[Fkt^.OpNr])*CharB+1;
     Inc(X,B1);(* Ausmaûe fÅr Klammer bestimmen*)
     MakeList(Fkt^.Rechts,X,Y,B2,H2,Y2,False);
     LBrak(X,Y2,H2,Draw);
     MakeList(Fkt^.Rechts,X,Y,B2,H,YMin,Draw);
     Inc(X,B2);
     RBrak(X,YMin,H,Draw);
     B:=B1+B2+CharB;
    End;
  Operator : Case Fkt^.OpNr Of
    Mal : 
     Begin (* Zuerst den 'Linken' Faktor...  *)
      kl:=KlNoetig(Fkt,Left);(* Klammer ? *)
      If Kl Then
      Begin
       MakeList(Fkt^.Links,X,Y,B1,H1,Y1,FALSE);
       LBrak(X,Y1,H1,Draw);
      End;
      MakeList(Fkt^.Links,X,Y,B1,H1,Y1,Draw);
      Inc(X,B1);
      If kl Then
      Begin
       RBrak(X,Y1,H1,Draw);
       Inc(B1,Charb);
      End;
      Y2:=Y; (* 'MAL'-Punkt : *)
      If CharH = BIGCH Then Dec(Y2,4)
      Else Dec(Y2,2);
      If Draw Then 
       NewObjekt(ZKette,X-2,Y2,0,0,'.');
      Inc(X,5);
      Kl:=KLNoetig(Fkt,Right);(*Rechter Faktor*)
      If Kl Then
      Begin
       MakeList(Fkt^.Rechts,X,Y,B2,H2,Y2,FALSE);
       LBrak(X,Y2,H2,Draw);
      End;
      MakeList(Fkt^.Rechts,X,Y,B2,H2,Y2,Draw);
      Inc(X,B2);
      If Kl Then
      Begin
       RBrak(X,Y2,H2,Draw);
       Inc(B2,CharB);
      End;
      C1:=Y2-H2; C2:=Y1-H1;(* Ausmaûe... *)
      If C1 > C2 Then C1:=C2;
      If Y2 > Y1 Then YMin:=Y2
       Else YMin:=Y1;
      H:=YMin-C1;
      B:=B1+B2+5;
     End;
   Durch :
    Begin
     Y:=Y-(CharH Div 2)-1; (* anheben... *)
     Inc(X);
     (* Gesamt-Maûe bestimmen : *)
     MakeList(Fkt^.Links,X,Y,B1,H1,Y1,FALSE);
     MakeList(Fkt^.Rechts,X,Y,B2,H2,Y2,FALSE);
     If B1 > B2 Then
     Begin (* Nenner Zentrieren *)
      C1:=X+1;
      C2:=X+(B1 DIV 2)-(B2 DIV 2)+1;
      B:=B1+2;
     End
     Else
     Begin (* ZÑhler Zentrieren *)
      C1:=X+(B2 DIV 2)-(B1 DIV 2)+1;
      C2:=X+1;
      B:=B2+2;
     End;
     If Draw Then NewObjekt(Strich,x-1,y,b,0,'');
     Y1:=2*Y-Y1;
     MakeList(Fkt^.Links,C1,Y1-3,B1,H1,Y1,Draw);
     Y2:=2*Y+H2-Y2;
     MakeList(Fkt^.Rechts,C2,Y2+1,B2,H2,Y2,Draw);
     H:=Y2-Y1+H1;
     YMin:=Y2; Inc(B,2);
    End;
  Hoch  : 
    Begin (* Zuerst die Basis... *)
     kl:=KlNoetig(Fkt,Left);
     If Kl Then
     Begin
      MakeList(Fkt^.Links,X,Y,B1,H1,Y1,False);
      LBrak(X,Y1,H1,Draw);
     End;
     MakeList(Fkt^.Links,X,Y,B1,H1,Y1,Draw);
     Inc(X,B1);
     If Kl Then
     Begin
      RBrak(X,Y1,H1,Draw);
      Inc(B1,CharB);
     End;
     (* Exponent mit kleinem Zeichensatz : *)
     C1:=CharH;(*  Aktuelle Grîûen merken  *)
     C2:=CharB;
     CharH:=SMALLCH;
     CharB:=SMALLCB;
     Y:=Y1-H1;       (* Hochstellen...  *)
     MakeList(Fkt^.Rechts,X,Y,B2,H2,Y2,Draw);
     CharH:=C1;   CharB:=C2;
     H:=Y1-Y2+H2; B:=B1+B2;
     YMin:=Y1;
    End;
   Plus,Minus :
    Begin
     kl:=KlNoetig(Fkt,Right);
     MakeList(Fkt^.Links,X,Y,B1,H1,Y1,Draw);
     Inc(X,B1);
     If Draw Then 
      NewObjekt(ZKette,X,Y,0,0,funk[fkt^.OpNr]);
     Inc(B1,CharB+1);
     Inc(X,Charb+1);
     If Kl Then
     Begin
      MakeList(Fkt^.Rechts,X,Y,B2,H2,Y2,False);
      LBrak(X,Y2,H2,Draw);
     End;
     MakeList(Fkt^.Rechts,X,Y,B2,H2,Y2,Draw);
     Inc(X,B2);
     If Kl Then
     Begin
      RBrak(X,Y2,H2,Draw);
      Inc(B2,Charb);
     End;
     C1:=Y2-H2; C2:=Y1-H1; (* Gesamt Maûe... *)
     If C1 > C2 Then C1:=C2;
     If Y2 > Y1 Then YMin:=Y2 
     Else YMin:=Y1;
     H:=YMin-C1;
     B:=B1+B2;
    End;
   End;(* Case Operator *)
  End;(* Case Art *)
 End;
End;

Begin
 CharH:=BIGCH;(* Buchstaben Hîhe   *)
 CharB:=BIGCB;(* Buchstaben Breite *)
 EndPtr:=NIL;
 X0:=0;(* Relativer Start-Punkt *)
 Y0:=0;
 (*---- F(X)= einfuegen -----*)
 NewObjekt(ZKette,X0,Y0,40,0,'F(X)=');
 Inc(X0,42);
 FktListe.Breite:=42;
 MakeList(Fkt,X0,Y0,Breite,Hoehe,YUnten,TRUE);
 FktListe.Breite:=FktListe.Breite+Breite+2;
 FktListe.HTop:=Hoehe-YUnten;
 FktListe.HAbs:=Hoehe+2;
 FktListe.Formel:=StartPtr;
End;

Procedure PlotFormelList(X0,Y0 : Integer;
                  Var FktListe : Formel_Graphik);
Var OldCharH,d : Integer;
    FormelPtr : GFPtr;

(* ôffnende Klammer *)
Procedure OpenBrak(X,Y,H : Integer);
Begin
  Line(X,Y,X,Y-H);(* 'Line' aus der Gem-Unit *)
  Line(X+1,Y,X+1,Y-H);
  Line(X,Y-H,X+2,Y-H-2);
  Line(X,Y,X+2,Y+2);
End;

(* Schlieûende Klammer *)
Procedure CloseBrak(X,Y,H : Integer);
Begin
  Line(X,Y,X,Y-H);
  Line(X-1,Y,X-1,Y-H);
  Line(X-2,Y-H-2,X,Y-H);
  Line(X-2,Y+2,X,Y);
End;

(* Wurzel *)
Procedure SqRoot(X,Y,B,H : Integer);
Var Y1 : Integer;
Begin
 Y1:=Y-2*(H DIV 3);
 Line(X,Y1,X+3,Y1);
 Line(X+3,y1,x+7,Y);
 Line(X+7,Y,X+7,Y-H);
 Line(X+7,Y-H,X+B,Y-H);
 Line(X+B,Y-H,X+B,Y-H+3);
End;

Begin
 vswr_mode(VDI_Handle, MD_TRANS);
 vst_color(VDI_Handle, BLACK);
 OldCharH:=0;
 FormelPtr:=FktListe.Formel;
 Y0:=Y0+FktListe.HTop;(* Anfangs-Position *)
 Inc(X0);
 While FormelPtr <> NIL Do
 Begin
  With FormelPtr^ Do
  Case ObjektTyp Of
   ZKette   : 
    Begin
     If Ch <> OldCharH Then
     Begin (* Neue Grîûe *)
      OldCharH:=Ch;
      If Ch = BIGCH Then 
       vst_height(Vdi_Handle,13,d,d,d,d)
      Else 
       vst_height(Vdi_Handle,6,d,d,d,d);
     End;
     v_gtext(Vdi_Handle,Xz+X0,Yz+Y0,Str);
    End;
   Strich   : Line(Xs+X0,Ys+Y0,Xs+X0+Bs,Ys+Y0);
   KlammerL : OpenBrak(Xk+X0,Yk+Y0,Hk);
   KlammerR : CloseBrak(Xk+X0,Yk+Y0,Hk);
   Wurzel   : SqRoot(Xw+X0,Yw+Y0,Bw,Hw);
  End;(* Case *)
  FormelPtr:=FormelPtr^.Next;(* NÑchster... *)
 End;
 vswr_mode(VDI_handle, MD_REPLACE);
End;

Procedure DelFormelList(
            Var FktListe : Formel_Graphik);
Var HelpPtr,Help2 : GFPtr;
Begin
 With FktListe Do
 Begin
  HelpPtr:=Formel;
  While HelpPtr <> NIL Do
  Begin
   Help2:=HelpPtr^.Next;
   Dispose(HelpPtr);
   HelpPtr:=Help2;
  End;
  Formel:=NIL;
 End;
End;

End.
