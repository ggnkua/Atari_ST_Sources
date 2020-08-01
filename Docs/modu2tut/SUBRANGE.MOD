                                        (* Chapter 10 - Program 2 *)
MODULE Subrange;

TYPE Days = (mon,tue,wed,thu,fri,sat,sun);
     Work = [mon..fri];
     Rest = [sat..sun];

VAR  Day      : Days;  (* This is any day of the week *)
     Workday  : Work;  (* These are the working days  *)
     Weekend  : Rest;  (* The two weekend days only   *)
     Index    : [1..12];
     Alphabet : ['a'..'z'];
     Start    : ['a'..'e'];

BEGIN    (* Main program *)
(*  The following statements are commented out because they
    contain various errors that will halt compilation.

   Workday := sat;   sat is not part of Workday's subrange.
   Rest := fri;      fri is not part of Rest's subrange.
   Index := 13;      Index is only allowed to go up to 12,
   Index := -1;        and down to 1.
   Alphabet := 'A';  Alphabet, as defined, includes only the
                       lowercase alphabet.
   Start := 'h';     h is not in the first five letters.

   End of the commented out section of program.
*)

   Workday := tue;
   Weekend := sat;
   Day := Workday;
   Day := Weekend;
   Index := 3 + 2 * 2;
   Start := 'd';
   Alphabet := Start;
                            (* Since Alphabet is 'd'     *)
   INC(Alphabet);           (*   and now 'e'             *)
   Start := Alphabet;       (* Start will be 'e'         *)
   DEC(Start,2);            (* Start will be 'c'         *)
   Day := wed;
   INC(Day);                (* Day will now be 'thu'     *)
   INC(Day);                (* Day will now be 'fri'     *)
   Index := ORD(Day);       (* Index will be 4 (fri = 4) *)

END Subrange.
