Function Peek(Adresse : Long_Integer) : Byte;
External;

Procedure Poke(Adresse : Long_Integer;
               Wert    : Byte);
External;

Function LPeek(Adresse : Long_Integer) : Long_Integer;
External;

Procedure LPoke(Adresse : Long_Integer;
                Wert    : Long_Integer);
External;

Procedure Movebytes(Start,Ziel,Anzahl : Long_Integer);
External;

Procedure Movelongs(Start,Ziel,Anzahl : Long_Integer);
External;

Procedure Fillbytes(Start,Anzahl : Long_Integer;
                    Wert         : Byte);
External;

Procedure Erasebytes(Start,Anzahl : Long_Integer);
External;

Function Searchstring(    Start,Laenge : Long_Integer;
                      Var s            : String) : Long_Integer;
External;

Function Comparebytes(Links,Rechts,Anzahl : Long_Integer) : Boolean;
External;

Procedure Swapbytes(Links,Rechts,Anzahl : Long_Integer);
External;

Procedure Getlow(Start,Ziel,Laenge : Long_Integer);
External;

Procedure Gethigh(Start,Ziel,Laenge : Long_Integer);
External;

Procedure Storelow(Quelle,Ziel,Anzahl : Long_Integer);
External;

Procedure Storehigh(Quelle,Ziel,Anzahl : Long_Integer);
External;

Function WPeek (Adr : Long_Integer) : Integer;
Begin
 WPeek:=Peek(Adr)*256+Peek(Adr+1)
End;

