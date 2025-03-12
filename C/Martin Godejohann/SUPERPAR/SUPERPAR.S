 ; superpar.s - Aufruf einer Routine im Supervi-
 ; sor-Modus mit Parametern aus dem Usermodus
 ; fÅr MAS-68k in Verbindung mit Turbo-C
 ; Martin Godejohann
 ; Dernburgstr. 51
 ; 1000 Berlin 19
 ; V 2 - 04.05.90, 09.10.90

    .GLOBL superpar         ; fÅr Export

superpar:
    ; long cdecl superpar(long (*funktion)(),
    ;                     long par1, long par2);
    ; ParameterÅbergabe Åber Stack erzwingen!
    move.l  12(sp),-(sp)    ; par1 unter Return-
    move.l  12(sp),-(sp)    ; Adresse holen
    move.l  12(sp),-(sp)    ; funktion
    move.w  #38,-(sp)       ; Supexec
    trap    #14             ; Xbios
                            ; RÅckgabewert in d0
    lea     14(sp),sp       ; Stackorrektur
    rts

 ; DEMO-Programmsegment, fÅr Supexec mit Parame-
 ; tern aus Assembler aufgerufen
 ; nicht lauffÑhig, nur zur Veranschaulichung!!!
 ;   .
 ;   .
 ;   move.l    #$440,-(sp)    Systemvar.seek_rate
 ;   pea       peek_word      diese Routine soll
 ;                            mit Super laufen
 ;   move.w    #38,-(sp)      Opcode fÅr Supexec
 ;                            auf Stack
 ;   trap      #14            XBIOS
 ;   lea       10(sp),sp      Stackkorrektur
 ;   .                        Inhalt v. seek_rate
 ;   .                        ist jetzt in d0
 ;   .
 ;--------
 ; peek_word:           dies ist besagte Routine
 ;   move.l    8(sp),a0       Adresse $440 vom 
 ;                            Stack holen
 ;   move.w    (a0),d0        und Inhalt nach d0
 ;   rts                      und zurÅck
