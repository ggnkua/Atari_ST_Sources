
* Senden eines Befehls im RC5 Code
* von Oliver Scholz
* (c) 1992 MAXON Computer

MFP         equ $FFFFFA01
INT_ENA_A   equ MFP+$6
INT_PEND_A  equ MFP+$A
INT_MASK_A  equ MFP+$12
TA_CTRL     equ MFP+$18
TA_DATA     equ MFP+$1E

SOUND       equ $FFFF8800

* C-Deklaration:
* VOID send_rc5(WORD device, WORD command,
*               WORD times)
* GerÑtenummern: 0..31
* Befehle:       0..63
*

            .globl  send_rc5

send_rc5:
    and     #$1f,d0     ;GerÑt: 5 Bits maskieren
    
    and     #$3f,d1     ;Befehl: 6 Bits maskieren
    
    asl     #6,d0
    or      d0,d1       ;zusammensetzen...
    
    eor     #$ffff,c_bit
    btst.b  #0,c_bit    ;C-Bit setzen ?
    beq     no_cbit
    bset    #11,d1      ;ja...
    
no_cbit:
    or      #$3000,d1   ;2 Startbits dazu
    move    d1,command
    
    move    d2,times
        
    movem.l d2-d7/a2-a6,-(sp)

    pea     do_send 
    move    #38,-(sp)   ;im Supervisormodus
    trap    #14         ;ausfÅhren
    addq.l  #6,sp

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

* RC5 Wort senden
send_loop:
    tst     times       ;entsprechend oft senden
    beq     done
    
    move    command,d0      ;Kommandowort holen
    move    #13,d1          ;14 Bits
cmd_loop:
    btst    d1,d0
    beq     bit_zero
    
    bsr     send_one        ;Eins senden
    bra     bit_done
    
bit_zero:
    bsr     send_zero       ;Null senden
    
bit_done:
    dbf     d1,cmd_loop
    
    bsr     set_zero        ;Leitung rÅcksetzen
            
    move    #95,d0          ;48 Bitzeiten
fill:
    bsr     wait_halfbit    ;warten
    dbf     d0,fill

    sub     #1,times
    bra     send_loop

done:
    rts
            
* Eine biphasencodierte Eins senden
send_one:
    bsr     set_zero
    bsr     wait_halfbit
    bsr     set_one
    bsr     wait_halfbit
    rts
    
* Dasselbe fÅr Null...
send_zero:
    bsr     set_one
    bsr     wait_halfbit
    bsr     set_zero
    bsr     wait_halfbit
    rts
            
* eine halbe Bitzeit (0.85ms) warten          

wait_halfbit:
    move.b  #$DF,INT_PEND_A ; Flag lîschen
    move.b  #131,TA_DATA    ; Timer setzen
    move.b  #3,TA_CTRL      ; und einschalten
        
wait:
    btst.b  #5,INT_PEND_A   ; Warten, bis Flag
    beq     wait            ; gesetzt
          
    clr.b   TA_CTRL         ; Timer wieder stop
    rts

* Leitung auf eins setzen
set_one:
    move.b  #$F,SOUND       ; Port B schreiben
    move.b  #1,SOUND+2
    rts

set_zero:
    move.b  #$F,SOUND
    move.b  #0,SOUND+2
    rts

            .data
c_bit:      dc.w    0

            .bss
command:    ds.w    1
times:      ds.w    1

