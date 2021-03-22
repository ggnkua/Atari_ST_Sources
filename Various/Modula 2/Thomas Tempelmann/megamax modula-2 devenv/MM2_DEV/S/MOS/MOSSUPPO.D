DEFINITION MODULE MOSSupport;

(*
 * Internes Modul!
 * Sollte nur von MOS-Modulen importiert werden!
 *)

PROCEDURE CallSuper;
  (*
   * ErhÑlt auf A7 Pointer zur Subroutine, die dann im Supervisormodus
   * (mithilfe GEMDOS.Super()) aufgerufen wird. Aufruf auch im Supervisor-
   * Mode erlaubt.
   * Liefert D0 zurÅck.
   *)

PROCEDURE ToSuper;
PROCEDURE ToUser;
  (*
   * ToSuper benutzt GEMDOS.Super, erwartet dazu auf dem Stack ein
   * reserviertes LONGWORD, worin der alte SSP abgelegt wird (0 bedeutet,
   * daû CPU schon vorher im Supervisor-Mode war).
   *)

END MOSSupport.
