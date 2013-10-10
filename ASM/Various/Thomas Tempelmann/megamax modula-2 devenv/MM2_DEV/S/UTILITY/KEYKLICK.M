MODULE KEYKLICK;

(*$N+  kein Runtime-Import (wird hier nicht benîtigt) *)

FROM SYSTEM IMPORT ASSEMBLER;

(*
 * Dies Mini-Programm schaltet das Bit 0 der 'conterm'-Systemvariable
 * um, sodaû damit der Klick beim TastendrÅcken ein-/ausgeschaltet
 * wird.
 *
 * Es muû ohne M2Init gelinkt werden und kann dann in den AUTO-Ordner
 * kopiert werden, um immer den Klick abzuschalten (normalerweise ist
 * er eingeschaltet).
 *)

BEGIN
  ASSEMBLER
        ; zuerst in den Supervisor-Modus gelangen, damit auf die
        ; Systemvariable ohne Bus-Error zugegriffen werden kann.
        CLR.L   -(A7)
        MOVE.W  #$20,-(A7)
        TRAP    #1
        ; Nun das Bit 0 von 'conterm' invertieren
        BCHG    #0,$484
        ; Programmende
        CLR     (A7)
        TRAP    #1
  END
END KEYKLICK.
