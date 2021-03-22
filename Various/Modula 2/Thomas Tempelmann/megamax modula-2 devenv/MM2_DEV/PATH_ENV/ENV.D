DEFINITION MODULE Env;

(* Von Ulrich Kaiser *)

(*$I+,Z+ *)

CONST MaxEnv = 32768; (* arbitrary limit *)

(* Env.Range *)

TYPE Range = [0..(MaxEnv - 1)];

(* Env.Pointer *)

TYPE Pointer = POINTER TO ARRAY Range OF CHAR;

(* Env.Ptr, for C-like main(argc,argv,penv) *)

VAR Ptr: Pointer;

(* Env.Get(), C-like getenv() *)

PROCEDURE Get(REF Var: ARRAY OF CHAR): Pointer;

(* Env.Length() *)

PROCEDURE Length(REF Var: ARRAY OF CHAR): Range;

(* Env.Assign() *)

PROCEDURE Assign(REF Var: ARRAY OF CHAR; VAR Str: ARRAY OF CHAR);

(* Env.Split() *)

TYPE SplitProc = PROCEDURE(REF ARRAY OF CHAR);

PROCEDURE Split(REF Var: ARRAY OF CHAR; Work: SplitProc);

END Env.

