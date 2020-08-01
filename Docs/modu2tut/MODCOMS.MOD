(* This is a comment that is prior to the start of the
   program itself. *)

MODULE ModComs;

FROM InOut IMPORT WriteLn, WriteString;

                     (* This is a block
                        of comments that
                        illustrate one way
                        to format some of
                        your comments.    *)

BEGIN  (* This is the beginning of the main program *)

   WriteString("This is a comments demo program.");
   WriteLn;
(* WriteString("This will not be output.");
   WriteString("Nor will this."); *)

END ModComs.  (* This is the end of the main program *)

(* This is a comment after the end of the program *)
