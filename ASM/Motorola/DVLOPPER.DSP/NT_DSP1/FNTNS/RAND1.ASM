;
; This program originally available on the Motorola DSP bulletin board.
; It is provided under a DISCLAIMER OF WARRANTY available from
; Motorola DSP Operation, 6501 Wm. Cannon Drive W., Austin, Tx., 78735.
; 
; Last Update 16 Apr 87   Version 1.1
;
                                                                                                                               
;
;       RANDOM NUMBER GENERATOR USING A 15 BIT SHIFT REGISTER
;
;
;
;
        PAGE    132,66,0,10
        ORG     X:0
NSTATE  DS      1               ;STATE OF NOISE GENERATOR (SHIFT REG)

        ORG     P:$100
INIT
        MOVE    #$FF,X0         ;INITIAL STATE OF NOISE GENERATOR
        MOVE    X0,X:NSTATE
GET
        DO      #100,_EGET
        JSR     NOISE           ;GENERATE NOISE SAMPLE
        MOVE    X:NSTATE,A      ;GET NOISE
        MOVEP   A1,Y:$FFFF      ;OUTPUT NOISE SAMPLE
_EGET
;
;       DONE WITH PROGRAM
;
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
;       NOISE GENERATION ROUTINE.  THIS ROUTINE USES A 15 BIT SHIFT
;       REGISTER LEFT JUSTIFIED IN THE VARIABLE "NSTATE".  AFTER THE STATE
;       IS LOADED, IT IS CHECKED TO SEE IF IT IS NORMALIZED.  IF IT IS
;       NORMALIZED (TOP TWO BITS ARE DIFFERENT), A 1 IS SET AS THE INPUT
;       TO THE SHIFT REGISTER AND THE REGISTER IS SHIFTED AND SAVED.
;
;         B23     B22                            B9      B8
;        ______________________________________________
;       | S14   | S13 |                        | S0   |
;       |       |     |      . . .             |      |<----------
;       |_______|_____|________________________|_______          |
;           |      |                                             |
;            \    /                                              |
;              XOR                                               |
;               \_________________________________________________
;
;
;       ASSUMES SCALING MODE IS OFF
;
NOISE                                   ;DO NOISE GENERATION LOOP
        CLR     B       X:NSTATE,A      ;GET A ZERO IN B
        TST     A   #>$000100,X0        ;CHECK A, GET A 1 IN LSB POSITION
        TNR     X0,B                    ;IF NORMALIZED, THEN XOR=1
        ADD     B,A                     ;SET LSB
        ASL     A                       ;SHIFT BITS
        MOVE    A1,X:NSTATE             ;SAVE STATE
        RTS                             ;RETURN WITH STATE
        END

