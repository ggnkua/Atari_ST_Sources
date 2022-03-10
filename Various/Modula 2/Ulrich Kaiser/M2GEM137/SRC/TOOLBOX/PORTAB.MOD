IMPLEMENTATION MODULE PORTAB;

(*
Yet another system-dependent Module.

UK __DATE__ __TIME__
*)

(*IMP_SWITCHES*)

IMPORT SYSTEM;

BEGIN
#ifdef FSTM2
NULL:= SYSTEM.PTR(0L);
#endif
END PORTAB.
