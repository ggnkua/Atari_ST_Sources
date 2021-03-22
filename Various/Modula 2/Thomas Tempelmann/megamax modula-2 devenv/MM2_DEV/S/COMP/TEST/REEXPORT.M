(*
 Folg. Modul lÑût sich nicht Åbersetzen, da ADDRESS offenbar falsch
 behandelt wird.
*)
MODULE A;

FROM SYSTEM IMPORT ADDRESS;

TYPE EEE = CARDINAL;

  MODULE B;
  
  IMPORT EEE, ADDRESS;
  
  EXPORT T;
  
  TYPE T = ADDRESS;
  
  END B;

END A.
