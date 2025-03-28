UNIT TREE; (* Mathematische BÑume *)

INTERFACE

CONST MAXFUNK = 23;
      PLUS    = 1;  
      MINUS   = 2;
      MAL     = 3;  
      DURCH   = 4;
      HOCH    = 5;
      FSIN    = 6;
      FCOS    = 7;
      FTAN    = 8;
      FARCSIN = 9;
      FARCCOS = 10;
      FARCTAN = 11;
      FSINH   = 12; 
      FCOSH   = 13;
      FTANH   = 14;
      FARSINH = 15;
      FARCOSH = 16; 
      FARTANH = 17;
      FEXP    = 18;
      FLN     = 19;
      FSGN    = 20; 
      FSQR    = 21;
      FSQRT   = 22;
      FKLAMMER= 23;
      DefFkt  :array[1..MAXFUNK] of string[6]=   
           ('+','-','*','/','^',
            'SIN','COS','TAN','ARCSIN',
            'ARCCOS','ARCTAN','SINH',
            'COSH','TANH','ARSINH','ARCOSH',
            'ARTANH','EXP','LN','SGN',
                     'SQR','SQRT','');

TYPE
  OpSet      = Set Of Char;
  
  Art_Typ = (Vorzeichen,Operator,Funktion,
            Zahl,Varx,C_Pi);
  FktPtr     = ^Knoten_Typ;
  Knoten_Typ  = Record
                Art         : Art_Typ;
                OpNr        : Integer;
                Wert        : Real;
                Links,Rechts: FktPtr;
               end;

(* Baum aufbauen *)
Function MakeTree(FktStrg : String;
                  Var Error : Integer):FktPtr;
(* Baum lîschen *)
Procedure DeleteTree(Var Fkt : FktPtr);

IMPLEMENTATION

Function MakeTree(FktStrg : String;
                  Var Error : Integer):FktPtr;

Var Fkt : FktPtr;

Function FindFkt(Var p : Integer; Term : String):Boolean;
Var FStrg : String;
    x : Integer;
    Found : Boolean;
Begin
 FindFkt:=false;
 p:=Pos('(',Term);
 If p > 0 Then
 Begin
  FStrg:=copy(term,1,p-1);
  x:=1;
  Found:=FALSE;
  Repeat
   If FStrg = DefFkt[x] Then Found:=TRUE;
   Inc(X);
  Until Found OR (x > MAXFUNK);
  FindFkt:=(Found AND (Term[Ord(Term[0])]=')'));
 End;
End;

Function GetFkt(Term : String):Integer;
Var x:Integer;
Begin
 For x:=1 to MAXFUNK do
  If Term = DefFkt[x] then 
  Begin
   GetFkt:=x; 
   Exit;
  End;
End;

Function FindOp(Ops : OpSet; Var p : Integer;
                              Term : String):Boolean;
Var kl    : Integer;
    Found : boolean;
Begin
 Found:=FALSE; kl:=0; p:=Ord(Term[0]);
 Repeat
  If Term[p] = '(' Then Inc(Kl)
  Else
  If Term[p] = ')' Then Dec(Kl)
  Else
  If (kl = 0) AND (term[p] IN Ops) 
      AND (p > 1) AND  (NOT (Term[p-1] in ['E','^'])) 
    Then Found:=true;
  Dec(p);
 Until Found OR (p <= 0);
 Inc(p);
 FindOp:=Found;
end;

Function FindValue(Var Wert : Real;
                       Term : String):Boolean;
Var Err : Integer;
Begin
 Val(Term,Wert,Err);
 FindValue:=(Err = 0);
End;

Function UpDate(Term : String):String;
Var g  : Integer;
    ch : Char;
    Upterm : String;
Begin
 Upterm:='';
 For g:=1 To Ord(term[0]) Do
 Begin
  ch:=UpCase(term[g]);
  If ch <> ' ' Then Upterm:=Upterm+ch;
 End;
 Update:=Upterm;
End;

Function BuildTree(Term : String):FktPtr;
Var wert : Real;
    k,FktNr : Integer;
    vz : Char;
    Knoten : FktPtr;
Begin
 If (Error = 0) and (Ord(Term[0]) > 0) then
  If FindOp(['+','-'],k,Term) Then
  Begin
   New(Knoten);
   Knoten^.Art:=Operator;
   If (Term[k]='+') Then
    Knoten^.OpNr:=Plus
   Else
    Knoten^.OpNr:=Minus;
   Knoten^.Links:=BuildTree(Copy(Term,1,k-1));
   Knoten^.Rechts:=BuildTree(Copy(Term,k+1,Ord(Term[0])-k));
  End
  Else 
  If FindOp(['*','/'],k,Term) Then
  Begin
   New(Knoten);
   Knoten^.Art:=Operator;
   If (Term[k]='*') Then
    Knoten^.OpNr:=Mal
   Else
    Knoten^.OpNr:=Durch;
   Knoten^.Links:=BuildTree(Copy(Term,1,k-1));
   Knoten^.Rechts:=BuildTree(Copy(Term,k+1,Ord(Term[0])-k));
  End
  Else 
  If (Term[1] IN ['+','-']) Then
  Begin
   Vz:=term[1];
   Delete(Term,1,1);
   Case Vz of
    '+': Knoten:=BuildTree(Term);
    '-': Begin
          New(Knoten);
          Knoten^.Art:=Vorzeichen;
          If Term[1] <> '(' Then
           Knoten^.Rechts:=BuildTree(Term)
          Else
           Knoten^.Rechts:=BuildTree(Copy(Term,2,Ord(Term[0])-2));
          Knoten^.Links:=Nil;
         End;
   End;
  End
  Else 
  If FindOp(['^'],k,Term) Then
  Begin
   New(Knoten);
   Knoten^.Art:=Operator; Knoten^.OpNr:=Hoch;
   Knoten^.Links:=BuildTree(Copy(Term,1,k-1));
   Knoten^.Rechts:=BuildTree(Copy(Term,k+1,Ord(Term[0])-k));
  End
  Else 
  If FindFkt(k,Term) then
  Begin
   FktNr:=GetFkt(Copy(Term,1,k-1));
   if FktNr = FKlammer then
    Knoten:=BuildTree(Copy(Term,k+1,Ord(Term[0])-1-k))
   Else
   Begin
    New(Knoten);
    Knoten^.Art:=Funktion;
    Knoten^.OpNr:=FktNr;
    Knoten^.Rechts:=BuildTree(Copy(Term,k+1,Ord(Term[0])-1-k));
    Knoten^.Links:=Nil;
   End;
  End
  Else 
  If FindValue(wert,term) Then
  Begin
   New(Knoten);
   Knoten^.Art:=Zahl;  Knoten^.Wert:=Wert;
   Knoten^.Links:=Nil; Knoten^.Rechts:=Nil;
  End
  Else 
  If (Term = 'PI') Then (* Speziell fÅr Formel-Graphik *)
  Begin
   New(Knoten);
   Knoten^.Art:=C_Pi; Knoten^.Wert:=Pi;
   Knoten^.Links:=NIL;Knoten^.Rechts:=NIL;
  End
  Else 
  If (Term = 'X') Then
  Begin
   New(Knoten);
   Knoten^.Art:=Varx;
   Knoten^.Links:=Nil; Knoten^.Rechts:=Nil;
  End
  Else
  Begin
   Knoten:=NIL;
   Error:=Error Or 1; (* Fehler im Term *)
  End
  Else
  Begin
   Knoten:=NIL;
   Error:=Error or 1;
  End;
 BuildTree:=Knoten;
End;

Begin
 Error:=0;
 FktStrg:=Update(FktStrg);
 MakeTree:=BuildTree(FktStrg);
end;

Procedure DeleteTree(Var Fkt : FktPtr);
Begin
 If Fkt <> nil then
 Begin
  DeleteTree(Fkt^.Links);
  DeleteTree(Fkt^.Rechts);
  Dispose(Fkt);
  Fkt:=Nil;
 End;
End;

End.
