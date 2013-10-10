IMPLEMENTATION MODULE B;

FROM MOSGlobals IMPORT MemArea;

FROM ResCtrl IMPORT RemovalCarrier, CatchRemoval;

IMPORT C;

IMPORT Terminal;

VAR wait: CHAR;
    rCarrier: RemovalCarrier;
    wsp: MemArea;
    
PROCEDURE b;
  BEGIN
    Terminal.WriteString( 'Hallo hier ist Modul B');
    Terminal.WriteLn;
  END b;
  
PROCEDURE Removal;
  BEGIN
    Terminal.WriteString( 'B.Removal');
    Terminal.WriteLn;
    C.c;
    Terminal.Read( wait)
  END Removal;
  
BEGIN
  Terminal.WriteString( 'Modulrumpf von B wird ausgefÅhrt');
  Terminal.WriteLn;
  wsp.bottom:= 0;
  CatchRemoval( rCarrier, Removal, wsp);
END B.
