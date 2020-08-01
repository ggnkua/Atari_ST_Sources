MODULE CommandLine; (* 1993 by Dirk Theisen. Version 10.10.93      *)
                    (* email : dirk_theisen@su.maus.de            *)

(* Module for reading the command line arguments according to the *)
(* ARGV specifications. If ARGV is not used, the normal           *)
(* Commandline will be evaluated.                                 *)

(* Details: *)

(* arg first points to the first argument. Use PROCEDURE Next to  *)
(* move to the next argument.                                     *)
(* You may for example COPY arg^ for further use.                 *)
(* arg is NIL if there is no more argument left.                  *)

(* Reset resets the Module. Should only be called in case of a    *)
(* canged command line! Do only ONE pass!                         *)

(* prgName points to the programs name (ARGV[0]). NIL, if ARGV is *)
(* not used. *)

IMPORT SYSTEM, Sys(*, IO  for test only! *) ;


TYPE

  String   = POINTER TO ARRAY 256 OF CHAR;

  SwitchProc* = PROCEDURE (s : CHAR; f : ARRAY OF CHAR): BOOLEAN;


VAR
  arg-     : String; (*  points always to next arg or NIL *)
  prgName- : String;
  command  : ARRAY 256 OF CHAR;


  PROCEDURE Next*();
  BEGIN
    IF arg # NIL THEN
      REPEAT
        INC(arg);
      UNTIL arg[0]=0X;
      INC(arg);
      WHILE (arg[0] = " ") OR (arg[0] = 0DX) DO INC(arg) END; (* <<< *)
      IF arg[0]=0X THEN
        arg:=NIL;
      END(*IF*);
    END(*IF*);
  END Next;


  PROCEDURE Reset*;
    VAR
      i : SHORTINT;
  BEGIN
    arg:=Sys.Basepage.Env;
    WHILE (arg#NIL) & ~( (arg[0] = "A") (* ist wohl das effizienteste *)
                       & (arg[1] = "R")
                       & (arg[2] = "G")
                       & (arg[3] = "V")
                       & (arg[4] = "=") ) DO
      Next;
    END(*WHILE*);
    IF arg#NIL THEN
      arg[0]:=0X; (* cut env from args *)
    END(*IF*);
    IF (arg#NIL) & (Sys.Basepage.ComLen=127) THEN (* ARGV found *)
      Next;
      prgName:=arg;
      Next;
    ELSE (* ARGV not found. Use BP.Command *)
      IF Sys.Basepage.Command[0] = 0X THEN (* <<< *)
        arg := NIL                         (* <<< *)
      ELSE
        arg := SYSTEM.ADR(command);
        COPY(Sys.Basepage.Command,arg^);
        i:=0;
        WHILE arg[i]#0X DO
          IF (arg[i]=" ") OR (arg[i] = 0DX) THEN
            arg[i]:=0X;
            INC(i);
            WHILE (arg[i] = " ") OR (arg[i] = 0DX) DO INC(i) END; (* <<< *)
          ELSE
            INC(i)
          END(*IF*);
        END(*WHILE*);
        arg[i+1]:=0X; (* terminate *)
      END;
    END(*IF*);
  END Reset;


  PROCEDURE Evaluate*(evalSwitch: SwitchProc);
  (*
   *  Evaluate passes through the commandline and scanns for single
   *  switches (like -a -b11 help or -a-b11 help or -ab11 help) and
   *  calls evalSwitch for each. If a switch has been detected, the
   *  CHAR holds the switch and the string holds the rest of the
   *  actual parameter. If not, CHAR is 0X and the string is the
   *  full parameter (i.e. "help" or a filename).
   *  evalSwitch should return TRUE, if it took the rest as switch-parameter .
   *
   *  Example for switchProc (from browser):
   *
   *  PROCEDURE GetSwitch(switch: CHAR; f: ARRAY OF CHAR): BOOLEAN;
   *  BEGIN
   *    IF switch#0X THEN
   *      CASE CAP(switch) OF
   *         "H" : hyper    :=TRUE;
   *               IO.WriteString("Including hyper-text information.");
   *               IO.WriteLn;
   *       | "C" : comments :=TRUE;
   *               IO.WriteString("Including comments.");
   *               IO.WriteLn;
   *       | "O" : overwrite:=TRUE;
   *       | "I" : IF (f[0]<="9")&(f[0]>="0") THEN
   *                 ind:=SHORT(ORD(f[0])-ORD("0"));
   *                 RETURN TRUE;
   *               END(*IF*);
   *      ELSE
   *        Error("WARNING : Unknown option detected.");
   *        IO.WriteChar(switch);
   *      END(*CASE*);
   *      RETURN FALSE; (* nothing of f consumed *)
   *    ELSE
   *      IF fileName="" THEN
   *        (* 1st file is SYM-File *)
   *        COPY(f,fileName);
   *      ELSE
   *        (* 2nd filename is defPath (DEF-file) *)
   *        NEW(defPath);
   *        COPY(f,defPath.Path);
   *      END(*IF*);
   *      RETURN TRUE; (* rest consumed *)
   *    END(*IF*);
   *  END GetSwitch;
   *
   *)
  VAR
    i    : INTEGER;
    rest : String;
  BEGIN
    WHILE arg#NIL DO
      IF (arg[0]="-") THEN
        (* avaluate switches *)
        i:=1;
        LOOP
          IF arg[i]=0X THEN
            EXIT;
          ELSIF arg[i]#"-" THEN
            rest:=arg;
            INC(rest,i+1);
            IF evalSwitch(arg[i],rest^) THEN
              EXIT; (* parameter of switch has been consumed *)
            END(*IF*);
          END(*IF*);
          INC(i); (* skip the switch *)
        END(*WHILE*);
      ELSE
         IF evalSwitch(0X,arg^) THEN END(*IF*);
      END(*IF*);
      Next();
    END(*WHILE*);
  END Evaluate;


BEGIN
  Reset();
  (* arg points now to the arg-Strings! *)

END CommandLine.


(*
  (* Testprozedur: Gibt die aktuelle Kommandozeile aus: *)

  IO.WriteString("Programmname: ");
  IF prgName#NIL THEN
    IO.WriteString(prgName^);
  END(*IF*);
  IO.WriteLn;

  WHILE arg # NIL DO
    IO.WriteString(arg^);
    IO.WriteLn;
    Next();
  END(*WHILE*);
  REPEAT UNTIL IO.KeyPressed();

END CommandLine.
*)