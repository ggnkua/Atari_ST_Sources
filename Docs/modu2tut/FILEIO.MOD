                                         (* Chapter 8 - Program 3 *)
MODULE FileIO;

FROM InOut IMPORT WriteString, WriteInt, WriteLn, Write, Read,
                  OpenInput, OpenOutput, CloseInput, CloseOutput,
                  Done;

IMPORT Terminal;                 (* This is used for monitor output *)
                                 (* and InOut is used for the file  *)
                                 (* input and output.               *)

VAR Character : CHAR;

BEGIN
   REPEAT                                    (* open the input file *)
      Terminal.WriteString("Enter Input filename  - ");
      OpenInput("MOD");
   UNTIL Done;                      (* Quit when open is successful *)

   REPEAT                                   (* open the output file *)
      Terminal.WriteString("Enter Output filename - ");
      OpenOutput("DOG");
   UNTIL Done;                  (* quit when the open is successful *)

   REPEAT                (* character read/write loop - quit at EOF *)
      Read(Character);
      IF Done THEN                           (* Done = FALSE at EOF *)
         Write(Character);
      END;
   UNTIL NOT Done;
   CloseInput;
   CloseOutput;

END FileIO.
