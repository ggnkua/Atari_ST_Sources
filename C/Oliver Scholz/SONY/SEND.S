
* Senden eines Befehls an ein GerÑt mit
* Sony SIRCS (Control-S) Anschluû
* von Oliver Scholz
* (c) MAXON Computer 1991

MFP         equ $FFFFFA01
INT_ENA_A   equ MFP+$6
INT_PEND_A  equ MFP+$A
INT_MASK_A  equ MFP+$12
TA_CTRL     equ MFP+$18
TA_DATA     equ MFP+$1E

SOUND       equ $FFFF8800

* C-Deklaration:
* VOID send_sony(WORD device, WORD command,
*                WORD times)
*

            .globl  send_sony

send_sony:
    move    d0,device
    move    d1,command
    move    d2,times
        
    movem.l d2-d7/a2-a6,-(sp)

send_loop:
    tst     times       ;entsprechend oft senden
    beq     done
            
    pea     do_send 
    move    #38,-(sp)   ;im Supervisormodus
    trap    #14         ;ausfÅhren
    addq.l  #6,sp
            
    sub     #1,times
    bra     send_loop

done:
    movem.l (sp)+,d2-d7/a2-a6
    rts

            .super

do_send: 
    move    sr,-(sp)
    ori     #$700,sr        ; Interrupts sperren
          
    clr.b   TA_CTRL         ; Timer anhalten
    bclr.b  #5,INT_ENA_A    ; Interrupt disablen
            
    bclr.b  #5,INT_MASK_A   ; Interrupt maskieren
            
    bset.b  #5,INT_ENA_A    ; Interrupt enablen
          
    move    (sp)+,sr        ; Interrupts frei!

* Sony SIRCS Wort senden
    clr     counter         ; ZeitzÑhler lîschen
            
    bsr     set_one         ; Ausgang auf High
    bsr     wait0_6         ; 2.4 ms warten
    bsr     wait0_6         
    bsr     wait0_6         
    bsr     wait0_6         
            
    bsr     set_zero        ; und auf Low: das
    bsr     wait0_6         ; war der Startschuû

    move    command,d0      ; Kommando senden
    move    #6,d1           ; 7 Bits
    bsr     cmd_loop
            
    move    device,d0       ; ZielgerÑtecode
    move    #4,d1           ; senden (5 Bits)
    bsr     cmd_loop
            
fill:
    bsr     wait0_6
    cmp     #75,counter     ; auffÅllen, bis 45ms
    blt     fill

    rts
            
* Bits an GerÑt senden
* Anzahl der Bits minus 1 in D1.w
* Die Bits selbst in D0.w
* Leitung fÅr jedes 1-Bit 1.2ms auf High,
* fÅr Null-Bits nur 0.6ms auf High
* danach 0.6ms auf Low

cmd_loop:
    bsr     set_one         ; Leitung auf high
    bsr     wait0_6         
    btst    #0,d0           ; unterstes Bit
    beq     cmd_zero        ; Bit ist Null
    bsr     wait0_6

cmd_zero:   
    bsr     set_zero
    bsr     wait0_6
    lsr     #1,d0
    dbf     d1,cmd_loop
    rts

* 0.6 ms warten          

wait0_6:
    move.b  #$DF,INT_PEND_A ; Flag lîschen
    move.b  #92,TA_DATA     ; Timer setzen
    move.b  #3,TA_CTRL      ; und einschalten
        
wait:
    btst.b  #5,INT_PEND_A   ; Warten, bis Flag
    beq     wait                        ; gesetzt
          
    clr.b   TA_CTRL         ; Timer wieder stop
    add     #1,counter      ; bisher gewartete
    rts                     ; Intervalle: erhîhen

* Leitung auf eins setzen
set_one:
    move.b  #$F,SOUND       ; Port B schreiben
    move.b  #1,SOUND+2
    rts

set_zero:
    move.b  #$F,SOUND
    move.b  #0,SOUND+2
    rts

            .bss
counter:    ds.w    1
device:     ds.w    1
command:    ds.w    1
times:      ds.w    1

