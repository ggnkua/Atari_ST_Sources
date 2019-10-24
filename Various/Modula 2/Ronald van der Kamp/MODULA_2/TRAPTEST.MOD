(****************************************
*                                       *
*    TrapTest   (program)               *
*   **********************************  *
*                                       *
*    How to use the TRAP's of the       *
*    68000 CPU in the Atari ST          *
*    computers.                         *
*                                       *
*                                       * 
*                                       *
*                                       * 
*  Written for TDI Modula 2             *
*  compiler and linker of release       *
*  3 of april 1987 by:                  *
*  R.J.van der Kamp                     *
*  Stichting Modula Nederland           *
*  Bakkersteeg 9a                       *
*  2311 RH Leiden-Holland               *
****************************************)
MODULE TrapTest;(*to catch your own traps *)

IMPORT GEMDOS;
IMPORT Program; (* for all needed shut-down actions *)
FROM SYSTEM IMPORT ADDRESS,CODE,ADR,SETREG,REGISTER,TSIZE;
FROM BIOS IMPORT SetException,GetException;
FROM CPUMode IMPORT Mode;

(****************************************************)
(* The following TRAP's are in use when the program *)
(* starts up in a newly powered up ST machine with  *)
(* only TOS in ROM and no boot-disk in the drive and*)
(* also no extra cartridges in the ROM port etc.    *)
(*                                                  *)
(* TRAP 0 not in use                                *)
(* TRAP 1 GEMDOS interface                          *)
(* TRAP 2 BDOS (GEM,GSX)                            *)
(* TRAP 3->4 free                                   *)
(* TRAP 5  IOTRANSFER of TDI Modula runtime system  *)
(* TRAP 6  reserved for runtime system              *)
(* TRAP 7  TRANSFER of TDI runtime system           *)
(* TRAP 8  modula runtime errors                    *)
(* TRAP 9->12 free                                  *)
(* TRAP 13 GEMBIOS                                  *)
(* TRAP 14 BIOS extensions                          *)
(* TRAP 15 possible use for TOS directory bug       *)
(****************************************************)
(* in this program TRAP 11 is used                  *)

CONST trap11VectorNr = 43; (* =172 div 4 *)
      VectorNr5= 5 ;
      trap11 = 4E40h + 0Bh; (* assembler code TRAP #11 *)
      A0=8; A7=15; D5=5; D7=7; (* reg nrs according to TDI *)
TYPE 
  (* names of the bits in the status register of CPU60000:  *)
  status = ( carry,overflow,zero,negative,extend,
             res1,res2,res3, int1,int2,int3,
             res4,res5,supervisor,res6,trace ) ;

  statusRegister = SET OF status;

  (* an exception places info on the system stack in the form: *)
  exceptionFrame = RECORD
                     stat:statusRegister; (* as before exception *)
                     PC:ADDRESS (* Program Counter: address of last instr*)
                   END;

(* For a bus- or and address error the system stack is different: *)
(* This is true for our CPU68000, but not For a CPU68010 
  accessType = (b15,b14,b13,b12,b11,b10,b9,b8,b7,b6,b5,
                readAborted,exceptionProcessing,functionCode);
  instructionRegister = WORD;
  functionFrame = RECORD
                    access: SET OF accessType;
                    toCurrentCycle: ADDRESS;
                    instruction: instructionRegister;
                    status : statusRegister;)
                    PC : ADDRESS; 
                  END;

*)

(* Before doing a trap it is a normal thing to give the       *)
(* traphandler some info about its params and wanted actions. *)
(* The code that wants the trap to be activated should,       *)
(* according to good programming rules for the TOS system,    *)
(* place its params simply on the stack. Here only one number *)
(* is visualised to be on the stack. Is there more, make the  *)
(* function frame according to your wishes:                   *)

  functionFrame = RECORD
                    fNr:CARDINAL; (* function number, according   *)
                                  (*to the TOS way of doing trap s*)
                                  (*the first to have on the stack*)
                    (* other stuff on stack , mostly parameters   *)
                  END;

(* In principle a trap should be reentrant. So make your own *)
(* stack space; do not count on enough space on the system   *)
(* stack :                                                   *)

  regStack = RECORD 
               heap :ARRAY [0..255] OF ADDRESS; (* stackspace*)
               SP:ADDRESS (* my own current stack pointer *)
             END;


VAR oldTrap11,       (* restore in the end the old status *)
    errorVector      : ADDRESS;(* for making a runtime error *)
    savedExcFrame    : exceptionFrame;(* we make a copy *)
    toExceptionFrame : POINTER TO exceptionFrame;
    toFunctionFrame  : POINTER TO functionFrame;
    regSaved         : regStack; (* we save all used reg in traphandler *)
    savedD5          : ADDRESS;(* SETREG destoys D5 *)
    savedSSP,dummy   : ADDRESS;(* for switching user-supermode and back *)
    ch : CHAR;
    i : INTEGER;

PROCEDURE InitRegisterStack;
(* to set the initial stackpointer for the stack that is used to
   save the registers during a trap *)
BEGIN
  WITH regSaved DO SP:= ADR(SP) END
END InitRegisterStack;
    
(*$P- *) 
PROCEDURE NewTrap11();
(*************************************************)
(* New Handler for TRAP #11                      *)
(* Always executed in supervisor mode            *)
(* There is on the stack :                       *)
(*                       .. ..                   *)
(*                       stuff on stack          *)
(* given StackPtr     -> 0  function number      *)
(*                                               *)
(*                       ..  ..                  *)
(*                       PC0 PC1  --|            *)
(*                       PC2 PC3    | exc. frame *)
(*       SSP (A7)     -> SRH SRL  --|            *)
(*                                               *)
(*  SSP= system (supervisor) Stack Pointer       *)
(*  given Stackptr=stack pointer from caller     *)
(*                =SSP+6 als caller in supermode *)
(*                =USP (user stack ptr)(usermode)*)
(*************************************************)
BEGIN (* CPU in supervisor mode *)
  SETREG(A0,regSaved.SP);(* save used regs *)
  CODE(48E0h,047Eh); (* MOVEM.L D5/A1-A6 -(A0) *)
  regSaved.SP:=REGISTER(A0);

  (* now get the pointer to the exception frame *)
  toExceptionFrame:=REGISTER(A7); (* SSP *)

  (* now get the pointer to the function frame  *)
  IF supervisor IN toExceptionFrame^.stat THEN
    (* the frame is also on the supervisorstack *)
    CODE(204Fh); (* MOVE.L A7 A0 *) (* A7=SSP *)
    CODE(0D0FCh,TSIZE(exceptionFrame)); (* ADDA.W size,A0 *)
  ELSE (* on user stack, so very simple: *)
    CODE(4E68h); (* MOVE USP A0 *)(*priviliged instr*)
  END;
  toFunctionFrame := REGISTER(A0);

(* what kind of action is to be done? *)
(* we have put a word on the stack to indicate *)
  IF toFunctionFrame^.fNr <> 19 THEN
    (* do the trap in the old manner *)
    SETREG(A0,regSaved.SP);   (* set all regs back      *)
    CODE(4CD8h,7E20h);        (* MOVEM.L (A0)+ D5/A1-A6 *)
    savedD5:=REGISTER(D5);    (* next statement uses D5 *)
    regSaved.SP:=REGISTER(A0);(*  set stackpointer back *)
    SETREG(D5,savedD5);  (* D5 got smashed in last instr*)
    SETREG(A0,errorVector);(* normally oldtrap11handler *)
    (*force a Modula  runtime error handler active now  *)
    CODE(4ED0h); (* JUMP (A0) *)
    (* instead of this,you could always jump to the old *)
    (* traphandler that was inexistence before your own *)
    (* handler was installed. This can be very useful,  *)
    (* because you can now catch for instance the system*)
    (* trap number 1 function 5 ( prit a character to  *)
    (* the standard (parallel ) printer port) and switch*)
    (* the output to a disk file while retaining all the*)
    (* other BDOS functions.                            *)
  ELSE (* my special trap catcher: *)
    (* --------------------- *)
    (* depending on the kind of function, the amount of info *)
    (* that was placed on the stack can de different.        *)
    (* get stuff from stack with yyy:= toFunctionFrame^.xx   *)

    IF supervisor IN toExceptionFrame^.stat THEN
      (* the function frame is 'in' the exception frame *)
      savedExcFrame := toExceptionFrame^; (* save exception frame *)
      (* remove the function frame from the super system stack*) 
      CODE( 0DEFCH, TSIZE(functionFrame)); (* ADDA.W size, A7 *)
      toExceptionFrame := REGISTER(A7); (* replace frame pointer *)
      toExceptionFrame^ := savedExcFrame;(* replace exceptionframe *)
    ELSE (* remove the function frame from user stack *)
      CODE(4E68h); (* MOVE USP A0 *) (* privileged instr *)
      CODE(0D0FCh, TSIZE(functionFrame)); (* ADDA.W size, A0 *)
      CODE(4E60h); (* MOVE A0 USP *) (* can only be done in super mode *) 
    END;
    (* now both the two stacks are in the good state to continue, and *)
    (* ending this proc  with a RTE instruction is possible later on. *)
    (* do your things ( trap handling actions ) here *)
    (*------------*)
    FOR i := 1 TO 80 DO GEMDOS.ConOut('*') END;
    (*------------*)

    (* get old regs back, restore CPU to old state *)
    SETREG(A0,regSaved.SP);
    CODE(4CD8h,7E20h); (* MOVEM.L (A0)+ D5\A1-A6 *)
    savedD5 := REGISTER(D5);(* next statement destroys D5 *)
    regSaved.SP := REGISTER(A0);
    SETREG(D5,savedD5);
    (* and return from this exception with a clean stack *)
    CODE(70FFh); (* MOVEQ #-1, D0 *) (* set a return error code *)
    CODE(4E73h); (* RTE *) (* and the stacks are ok for this *)
  END;  
END NewTrap11;
(*$P+ *) 

(* the next procedure should always be activated when this *)
(* trap test program ends , either normally or abnormally *)
PROCEDURE ResetTrap11; (* this is a decent thing to do : *)
(* never leave an address of a procedure that is not     *)
(* available after this program ends *)
BEGIN
  SetException(trap11VectorNr,PROC(oldTrap11))
END ResetTrap11;

BEGIN
  InitRegisterStack;
  oldTrap11 := GetException(trap11VectorNr);
  errorVector := GetException(VectorNr5);
  SetException(trap11VectorNr,NewTrap11);
  Program.AddShutDowner(ResetTrap11);  

  savedSSP := Mode(0); (* to super mode here *)

  SETREG(D7,19);(* a normal trap *)
  CODE(3F07h); (* MOVE.W D7, -(A7) *)
  CODE(trap11);(* TRAP   #11       *)
  CODE(548Fh) ;(* ADDQ.L #2, A7 *)

  SETREG(D7,15); (* a runtime error is done *)
  CODE(3F07h); (* MOVE.W D7, -(A7) *)
  CODE(trap11);(* TRAP   #11       *)
  CODE(548Fh) ;(* ADDQ.L #2, A7 *)

  dummy := Mode(savedSSP);(* back to user mode*)

  Program.NormalExit;
END TrapTest.

