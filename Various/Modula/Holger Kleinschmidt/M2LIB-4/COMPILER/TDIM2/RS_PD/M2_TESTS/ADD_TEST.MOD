MODULE Test;
(* 1993 ROLF SCHRADER. * 7.12.93 *)

(* Dieses kleine ProgrÑmmle stÅrzt den Compiler in den arithmet. öber-Fluû.*)
(* Hinweis auf einen Bug in GEMX.FSUB/FADD? Oder bloû im Parser? *)
(* Umgehung: r := - (123.0 + 0.123) .*)

VAR   r: REAL;

BEGIN r := - 123.0 - 0.123 END Test.
