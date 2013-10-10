IMPLEMENTATION MODULE A;

FROM MOSGlobals IMPORT MemArea;

FROM ResCtrl IMPORT RemovalCarrier, CatchRemoval;

IMPORT C;

IMPORT Terminal;

VAR wait: CHAR;
    rCarrier: RemovalCarrier;
    wsp: MemArea;
    
PROCEDURE a;
  BEGIN
    Terminal.WriteString( 'Hallo hier ist Modul A');
    Terminal.WriteLn;
  END a;
  
PROCEDURE Removal;
  BEGIN
    Terminal.WriteString( 'A.Removal');
    Terminal.WriteLn;
    C.c;
    Terminal.Read( wait)
  END Removal;
  
BEGIN
  Terminal.WriteString( 'Modulrumpf von A wird ausgefÅhrt');
  Terminal.WriteLn;
  wsp.bottom:= 0;
  CatchRemoval( rCarrier, Removal, wsp);
END A.
