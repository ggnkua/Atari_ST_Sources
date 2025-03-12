***********************************************
* Datei: LIESDIPS.S     Version 1.00          *
* ------------------------------------------- *
* (C) 1991 by MAXON Computer                  *
* Autoren: Oliver Scholz & Uwe Hax            *
* Einstellung der DIP-Schalter lesen (nicht   *
* die des Cookies !                           *
***********************************************

BERR        EQU   8  
DIP_HW      EQU   $FFFF9200 
cookie_jar  EQU   $5A0

            GLOBL get_switches,set_switches

get_switches:
            move.l  #$ff,switches

* in Supervisormodus wechseln
            clr.l   -(sp)
            move    #$20,-(sp) ;Super
            trap    #1
            addq.l  #6,sp
            move.l  d0,_ssp

* Rechner auf Bus-Error vorbereiten
            move.l  sp,save_sp
            move.l  BERR,a0
            move.l  #zurueck,BERR
            
* DIP-Schalter lesen
            clr.l   d0
            move.w  DIP_HW,d0
            lsr.w   #8,d0 
            move.l  d0,switches

* alten Bus-Error-Vektor wiederherstellen       
zurueck:    move.l  a0,BERR
            move.l  save_sp,sp
            move.l  _ssp,-(sp)
            move    #$20,-(sp)
            trap    #1
            addq.l  #6,sp
            
            move.l  switches,d0
            rts

***********************************************
* Cookie _SWI auf gewÅnschten Wert setzen,    *
* falls _SWI Cookie Åberhaupt vorhanden ist   *
***********************************************

set_switches:
* Parameter merken
            move.l  d0,switches
            
* in Supervisormode gehen
            clr.l   -(sp)
            move    #$20,-(sp)
            trap    #1
            addq.l  #6,sp
            move.l  d0,_ssp

* Cookie Jar vorhanden / Adresse holen
            move.l  cookie_jar,d0
            beq     exit

* _SWI suchen           
            move.l  d0,a0
loop:       move.l  (a0)+,d0
            beq     exit
            cmp.l   #'_SWI',d0
            beq     found
            addq.l  #4,a0
            bra     loop
            
* Cookie gefunden!
found:      move.l  switches,(a0)

* zurÅck in Usermode
exit:       move.l  _ssp,-(sp)
            move    #$20,-(sp)
            trap    #1
            addq.l  #6,sp
            rts
            
            .data
switches:   ds.l    1
_ssp:       ds.l    1
save_sp:    ds.l    1


