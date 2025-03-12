;************************************************
;* Datei: HD_PARK.S                             *
;* -------------------------------------------- *
;* Modul: DISK.CPX                 Version 1.00 *
;* (C) 1990 by MAXON Computer                   *
;* Autoren: Uwe Hax & Oliver Scholz             *
;* -------------------------------------------- *
;* Mehr oder weniger (eigentlich weniger) frei  *
;* nach Claus Brod: "Scheibenkleister",         *
;* Seite 325 ff. (Das Buch ist fast noch besser *
;* als HITCHHIKER u. DISCWORLD zusammen!)       *
;************************************************


;C-Deklaration: WORD hd_park(BYTE controller, 
;                            BYTE unit);
;controller = 0-7 (in Register d0)
;unit = 0-7 (in Register d1)


GEMDOS          = 1
SUPER           = $20

flock           = $43e
hz_200          = $4ba

dmodus          = $ff8606
daccess         = $ff8604
gpip            = $fffa01


                EXPORT hd_park
                TEXT

hd_park:        ;man weiû ja nie...
                movem.l d1-a6,-(sp)

                ;Parameter retten
                clr.l   d2
                clr.l   d3
                move.b  d0,d2    
                move.b  d1,d3

                ;RÅckgabewert: kein Fehler
                clr     d5          
                
                ;Supervisor-Modus einschalten
                clr.l   -(sp)          
                move    #SUPER,-(sp)
                trap    #GEMDOS
                addq.l  #6,sp
                move.l  d0,d6
                
                ;Floppy-VBL ausschalten
                st      flock          
                
                ;auf dem Bus kurz mal klingeln
                move    #$88,dmodus  
                nop                   
                
                ;Controller-ID in Befehl einbauen
                move.l  #$001b0088,d4   
                lsl.l   #5,d2
                swap    d2
                or.l    d2,d4

                ;erstes Kommandobyte Åbergeben
                move.l  d4,daccess      
                nop
             
                ;auf BestÑtigung warten
                bsr     zeiteisen      
                bmi     error          
                
                ;Laufwerks-ID in Befehl einbauen
                move.l  #$0000008a,d4   
                lsl.l   #5,d3
                swap    d3
                or.l    d3,d4

                ;alle weiteren Kommandobytes
                ;Åbergeben
                move.l  d4,daccess   
                nop
                bsr     zeiteisen      
                bmi     error          
                
                move.l  #$0000008a,daccess      
                nop
                bsr     zeiteisen      
                bmi     error         
                
                move.l  #$0000008a,daccess      
                nop
                bsr     zeiteisen       
                bmi     error           
                
                move.l  #$0001008a,daccess      
                nop
                bsr     zeiteisen      
                bmi     error          
                
                ;letztes Kommandobyte Åbergeben
                move.l  #$0000000a,daccess      
                nop                     
                bsr     wait_for_com    
                bmi     error          
                
                ;ACSI-Bus selektieren
                move    #$8a,dmodus  
                nop     
                
                ;ACSI-Status holen
                move    daccess,d0

                ;nur Statusbits auswerten
                andi    #$001f,d0       
                
                ;kein Fehler
                beq     error          

                ;Fehler: RÅckgabewert -1
                move    #-1,d5          
                
error:          ;auf FDC umschalten
                move    #$80,dmodus 
                nop
                
                ;Floppy-VBL einschalten
                clr     flock          

                ;Supervisor-Modus ausschalten
                move.l  d6,-(sp)        
                move    #SUPER,-(sp)
                trap    #GEMDOS
                addq.l  #6,sp

                ;RÅckgabe: -1 = Fehler, 0 sonst
                move    d5,d0        
                movem.l (sp)+,d1-a6
                rts
                
                
wait_for_com:   ;immer schîn vorsichtig
                movem.l d0/d1/a2,-(sp) 

                ;Default: kein Fehler
                clr     d0           

                ;800 Ticks warten
                move.l  #800,d1  
                bra     get_timer


zeiteisen:      ;wie oben
                movem.l d0/d1/a2,-(sp)  
                
                ;Default: kein Fehler
                clr     d0           

                ;20 Ticks warten
                moveq   #20,d1  

get_timer:      ;200-Hz-ZÑhler addieren
                add.l   hz_200,d1      

zeita:          ;auf HDC-IRQ testen
                btst    #5,gpip    

                ;ist angekommen, dann fertig
                beq     fix_und_fertig  

                ;Timer-Zielwert erreicht?
                cmp.l   hz_200,d1       
                bne     zeita        

                ;Fehlermeldung
                moveq   #-1,d0        
                move    d0,d5         
                
fix_und_fertig: ;N-Flag aktualisieren
                tst     d0           

                movem.l (sp)+,d0/d1/a2  
                rts                     
                

