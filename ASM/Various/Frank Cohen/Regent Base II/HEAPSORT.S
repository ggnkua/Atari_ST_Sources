**********************************************
*         HEAPSORT SORTING ALGORITHM         *
*       Program by Frank Cohen (c) 1988      *
* ------------------------------------------ *
*       Based on an algorithm listed in      *
*              NUMERICAL RECIPES             *
* by Press,  Flannery, Teukolsky, Vetterling *
*          Cambridge Press, New York         *
* ------------------------------------------ *
* Heapsort is a N log2 N sorting method that *
* works well with large arrays of data.      *
* Heapsort is a true "in-place" sort, that   *
* requires no auxiliary storage.             *
* ------------------------------------------ *
* In this program the an array of data is    *
* sorted in ascending order.                 *
* ------------------------------------------ *
* Enter this routine with the following:     *
*   A0 = pointer to start of POINTER TABLE   *
*   D0 = number of elements                  *
* ------------------------------------------ *
* On return the POINTER TABLE will be        *
* arranged in ascending order of the data.   *
**********************************************

* For easier reading, the following registers are used:

* A0_PTR EQU A0
* HS_N EQU D0
* HS_L EQU D1
* HS_RRA EQU D2
* HS_IR EQU D3
* HS_I EQU D4
* HS_J EQU D5

* The index L will be decremented from its initial value down to 1
* during the "hiring" (heap creation) phase.  Once it reaches 1,
* the index IR will be decremented from its initial value down
* to 1 during the "retirement-and-promotion" (heap selection) phase.

HEAPSORT CLR.L D1     ;Init registers
 CLR.L D2
 CLR.L D3
 CLR.L D4
 CLR.L D5

 MOVE D0,D1           ;LET L=N/2+1
 LSR #1,D1
 ADD #1,D1

 MOVE D0,D3           ;IR=N

HS_10 CMP #1,D1       ;IF (L.GT.1) THEN
 BLE HS_100

 SUB #1,D1            ;  L=L-1      Still in hiring phase
 CLR.L D7             ;  RRA=RA(L)
 MOVE D1,D7
 SUB #1,D7
 LSL #2,D7
 MOVE.L A0,A1
 ADD.L D7,A1
 MOVE.L (A1),D2
 JMP HS_101

HS_100 CLR.L D7       ;ELSE         In retirement-and-promotion phase
 MOVE D3,D7           ;  RRA=RA(IR) Clear a space at the end of array.
 SUB #1,D7
 LSL #2,D7
 MOVE.L A0,A1
 ADD.L D7,A1
 MOVE.L (A1),D2

 MOVE.L (A0),(A1)     ;  RA(IR)=RA(1) Retire the top of the heap onto it.

 SUB #1,D3            ;  IR=IR-1    Decrease the size of the company.

 CMP #1,D3            ;  IF (IR.EQ.1) THEN   Done with the company?
 BNE HS_101
 MOVE.L D2,(A0)       ;    RA(1)=RRA  Retire the least competient worker
 JMP HS_RETURN        ;    RETURN

HS_101 MOVE D1,D4     ;I=L  Regardless of the phase, sift down RRA

 CLR.L D5             ;J=L+L
 ADD D1,D5
 ADD D1,D5

HS_20 CMP D3,D5       ;IF (J.LE.IR) THEN
 BGT HS_104

 BEQ HS_102           ;  IF (J.LT.IR) THEN

 CLR.L D7             ;    IF (RA(J).LT.RA(J+1))  Compare to the better
 MOVE D5,D7  ;J                                   underling.
 SUB #1,D7
 LSL #2,D7
 MOVE.L A0,A1
 ADD.L D7,A1
 MOVE.L (A1),A1

 CLR.L D7
 MOVE D5,D7  ;J+1
 LSL #2,D7
 MOVE.L A0,A2
 ADD.L D7,A2
 MOVE.L (A2),A2

* INSERT YOUR OWN TESTING CODE HERE
* A1 = PTR TO RA(J)  A2 = PTR TO RA(J+1)
* SET D7=1 IF (A1)<(A2)

 MOVE (A1),D7
 CMP (A2),D7
 BGE HS_102

 ADD #1,D5            ;    J=J+1

HS_102 CLR.L D7       ;  IF (RRA.LT.RA(J))  Demote RRA
 MOVE D5,D7
 SUB #1,D7
 LSL #2,D7
 MOVE.L A0,A2
 ADD.L D7,A2
 MOVE.L (A2),A2

 MOVE.L D2,A1

 MOVE (A1),D7
 CMP (A2),D7
 BGE HS_103

 CLR.L D7             ; RA(I)=RA(J)
 MOVE D5,D7
 SUB #1,D7
 LSL #2,D7
 MOVE.L A0,A1
 ADD.L D7,A1
 CLR.L D7
 MOVE D4,D7
 SUB #1,D7
 LSL #2,D7
 MOVE.L A0,A2
 ADD.L D7,A2
 MOVE.L (A1),(A2)

 MOVE D5,D4           ; I=J
 ADD D5,D5            ; J=J+J

HS_103 MOVE D3,D5     ; ELSE J=IR+1  This is RRA's level. Set J to terminate
 ADD #1,D5            ;              the sift-down.
 JMP HS_20

HS_104 CLR.L D7       ; RA(I)=RRA    Put RRA into its new slot.
 MOVE D4,D7
 SUB #1,D7
 LSL #2,D7
 MOVE.L A0,A1
 ADD.L D7,A1
 MOVE.L D2,(A1)

 JMP HS_10            ;   GOTO 10

HS_RETURN RTS

 END
