IMPLEMENTATION MODULE C;

FROM MOSGlobals IMPORT MemArea;

FROM ResCtrl IMPORT RemovalCarrier, CatchRemoval;

IMPORT Terminal;

VAR wait: CHAR;
    rCarrier: RemovalCarrier;
    wsp: MemArea;
    
PROCEDURE c;
  BEGIN
    Terminal.WriteString( 'Hallo hier ist Modul C');
    Terminal.WriteLn;
  END c;
  
PROCEDURE Removal;
  BEGIN
    Terminal.WriteString( 'C.Removal');
    Terminal.WriteLn;
    Terminal.Read( wait)
  END Removal;
  
BEGIN
  Terminal.WriteString( 'Modulrumpf von C wird ausgefÅhrt');
  Terminal.WriteLn;
  wsp.bottom:= 0;
  CatchRemoval( rCarrier, Removal, wsp);
END C.
