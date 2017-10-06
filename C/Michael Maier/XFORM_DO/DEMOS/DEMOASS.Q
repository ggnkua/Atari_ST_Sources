TREE1   EQU     1

        include include\types.i
        include include\xform.i
        include include\gem.i
        
_STKSIZ EQU     4096

        include lib\start.o             ; StartUp-Sequenz von ER!
        
MAIN:
        lea     BASE6(PC),A6            ; Basisregister
        move.l  #appl_init,D0           ; Applikation anmelden
        bsr     aes                     ;
        
        lea     rscname(PC),A0          ; Resource-Datei
        bsr     open_res                ;
        beq     .error                  ; = 0? Fehler -> Abbruch

        bsr     half_on                 ;
        
        clr.w   intin(A6)               ; Adresse des Baumes ermitteln
        move.w  #TREE1,intin+2(A6)
        move.w  #$0001,contrl+8(A6)
        move.l  #$70020100,D0
        bsr     aes                     ; rsrc_gaddr

        move.l  addrout(A6),A5          ; Baum merken
        move.l  A5,A0                   ;
        bsr     fix_objs                ; Objekte fixieren

        lea     info(PC),A1     ; Zeiger auf info
        move.l  A5,A0           ; Zeiger auf Baum
        moveq   #1,D0           ; Positionieren
        bsr     open_dia        ; Dialog îffnen

        move.l  A5,A0           ; Zeiger auf Baum
        lea     info(PC),A1     ; Zeiger auf DIAINFO-Struktur
        clr.l   D0              ; Kein Objekt
        bsr     xform_do        ;

        move.l  A5,A0           ; das Åbliche
        lea     info(PC),A1     ;
        bsr     clse_dia        ; Dialog schlieûen
        bsr     clse_res        ; Resourcen schlieûen

.error:

        move.l  #appl_exit,D0   ; Applikation abmelden
        bsr     aes             ;
        rts                     ; und zurÅck

        include xform_do.lib    ; ASS-Version!!!
        
        SECTION DATA

rscname:        dc.b    "DEMOASS.RSC",0         ; Resource-Datei
                even

        SECTION BSS
info:           ds.b    di_size         ; eine DIAINFO-Struktur

;
; AES-Infos
;
appl_init           EQU       $0A000100
appl_exit           EQU       $13000100
graf_handle         EQU       $4D000500
rsrc_load           EQU       $6E000101
rsrc_free           EQU       $6F000100
objc_draw           EQU       $2A060101

