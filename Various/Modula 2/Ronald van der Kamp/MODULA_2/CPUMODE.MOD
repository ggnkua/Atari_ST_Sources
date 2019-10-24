(****************************************
*                                       *
*     CPUMode  (imp)                    *
*     ******************************    *
*                                       *
*      Implementation for ATARI ST      *
*                                       *
*      To switch you from user mode     *
*      into supervisor mode with a      *
*      choice of stack (USP/SSP).       *
*                                       *
*                                       *
*     Version 0.3 of 17.4.86            *
*                                       *
*     Stichting MODULA Nederland        *
*     Bakkersteeg 9 A                   *
*     2311 RH LEIDEN                    *
*                                       *
*+++++++++++++++++++++++++++++++++++++++*
*                                       *
*  Author: R.J. van der Kamp            *
****************************************)
  
IMPLEMENTATION MODULE CPUMode;
(* in the manuals of GEMDOS there is no mention of function number 
   32 ( 20h ). This function brings you into or out of supervisor 
   mode.
*)

FROM SYSTEM IMPORT ADDRESS,REGISTER,SETREG,CODE;

CONST
  D0 = 0 ; D1 = 1 ; (* modula reg numbers *)
  trap1 = 4E41h; (* TRAP #1 *)
  cleard0 = 7000h ; (* MOVEQ.L #0.D0  *)
  stackd1 = 2F01h ; (* MOVE.L D1,-(SP) = *)
  stackfunctionnumber = 3F3Ch ; (* MOVE.W #xxxx,-(SP) *)

PROCEDURE Mode ( stack : ADDRESS ) : ADDRESS ;
BEGIN
  CODE(cleard0);
  SETREG(D1,stack);
  CODE(stackd1);
  CODE(stackfunctionnumber,20h);
  CODE(trap1);
  RETURN REGISTER (D0);
END Mode;

BEGIN
  (* no initialising actions *)
END CPUMode.

