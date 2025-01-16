 
 ;**************************************************
 ;* An example 68000 Routine to Invert your Screen *
 ;* This Routine should be called from GFA-BASIC   *
 ;**************************************************

start         pea inverter(pc)     ;Push Address of Routine
              move.w #38,-(sp)     ;XBIOS Superx Function
              trap #14             ;And Call it in Supervisor Mode
              addq.l #6,sp         ;Tidy Stack
exit          rts                  ;& Return Control to GFA-BASIC

inverter      move.l $44e,a0       ;Get Screen Address
              moveq #0,d0          ;Clear D0
              move.b #$7d,d0
              rol.w #8,d0          ;Setup 32000 Size in D0 
invertloop    not.l 0(a0,d0.l)     ;Invert Longword
              subq.l #4,d0         ;Decrement Size by Longword
              bpl.s invertloop     ;Do this until 32000 Bytes Inverted
              rts                  ;Return to exit above
     