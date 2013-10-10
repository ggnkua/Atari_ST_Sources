MODULE Empty;
(*$N+*)

(*
 * Dies ist ein leeres Programm, das schlicht dazu da ist, bei einem
 * Warmstart des TOS den Speicher lîschen zu lassen, weil es sonst
 * evtl. Probleme mit dem GEM (AbstÅrze) gibt. Es wird nur benîtigt,
 * wenn sich eine TOS-Version >= 1.4 im Rechner befindet und wenn 
 * sonst ALLE im AUTO-Ordner gestarteten Programme das Fastload-Flag
 * setzt haben.
 * Statt dieses Programm zu verwenden, kann natÅrlich auch bei einem
 * der anderen AUTO-Ordner-Programme das Fastload-Flag gelîscht werden.
 *
 * Anwendung:
 * Ohne irgendwelche Treiber (auch kein M2Init!) und ohne Fastload-Flag
 * vollst. optimiert linken und in den AUTO-Ordner damit!
 *)

FROM SYSTEM IMPORT ASSEMBLER;

BEGIN
  ASSEMBLER
        CLR.W   -(A7)
        TRAP    #1
  END
END Empty.
