MODULE C;
(*
 * hier wird getestet, ob wirklich jedesmal der richtige Bez. exportiert wird
 * die alte LOCXP-routine konnte das nicht.
 *)

MODULE G;
  EXPORT B;
  TYPE A = CARDINAL;
       B = A;
  END G;

VAR b: B;

MODULE H;
  EXPORT A;
  TYPE A = CARDINAL;
       B = A;
  END H;

VAR a: A;

END C.

