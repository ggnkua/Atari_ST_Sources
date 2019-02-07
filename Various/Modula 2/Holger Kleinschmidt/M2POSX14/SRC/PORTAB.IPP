IMPLEMENTATION MODULE PORTAB;
__IMP_SWITCHES__

(*
Yet another system-dependent Module.

UK __DATE__ __TIME__
modified by hk
*)

#ifdef FSTM2
IMPORT SYSTEM;

BEGIN
NULL:= SYSTEM.PTR(0L);
#else
(*empty*)
#endif
END PORTAB.
