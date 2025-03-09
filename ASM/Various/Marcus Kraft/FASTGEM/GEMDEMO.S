;-----------------------------------------------------------------------------
;
;              GEM-Demo 3
;
;              Autor          : Marcus Kraft
;              Letzte énderung : 06.03.1990
;
;-----------------------------------------------------------------------------
               .TEXT 

               .INCLUDE 'GEMLIB.IS'     ; GEM-Bibliothek einbinden

               appl_init                ; Applikation anmelden

               graf_handle              ; Bildschirm-Handle holen

               v_opnvwk   handle        ; Virtuellen Arbeitsplatz îffnen

               graf_mouse               #255,#maus_form     ; Mausform 1 setzen

               graf_mouse               #256,#maus_form     ; Hidemouse

               vsf_color  handle,#1     ;FÅllfarbe wÑhlen

               vswr_mode  handle,#1     ;Zeichenmodus Replace

               vsf_interior             handle,#2 ;FÅllart Muster

               vsf_perimeter            handle,#0 ;keine Umrahmung

               vsf_style  handle,#9     ;Mauermuster

               v_bar      handle,fullscreen       ;ganzen Bildschirm fÅllen

               move.w     #100,d6
               move.w     #200,d5
               moveq.l    #8,d7
loop:          
               vsf_style  handle,d7     ;FÅllmuster

               addi.w     #20,pxyarray
               addi.w     #20,pxyarray+2
               subi.w     #20,pxyarray+4
               subi.w     #20,pxyarray+6

               v_circle   handle,pxyarray,pxyarray+2,d6
               v_circle   handle,pxyarray+4,pxyarray+2,d6
               v_circle   handle,pxyarray,pxyarray+6,d6
               v_circle   handle,pxyarray+4,pxyarray+6,d6
               subi.w     #10,d6

               v_circle   handle,#320,#200,d5
               subi.w     #20,d5

               subq.w     #2,d7
               cmpi.w     #0,d7
               bne        loop

               vsf_style  handle,#9

               v_fillarea               handle,#13,polygon ;Polygon zeichnen

               vsl_width  handle,#5     ;Linienbreite 5

               vsl_ends   handle,#2,#2  ;abgerundete Linienenden

               v_pline    handle,#13,polygon      ;Polygonumrahmung zeichnen

               vsf_interior             handle,#0 ;FÅllart leer

               vsf_perimeter            handle,#1 ;Umrahmung einschalten

               v_rfbox    handle,pxyarray         ;abgerundetes Rechteck 

               vst_effects              handle,#%10000      ; OUTLINE

               vst_height               handle,#40          ; Texthîhe 40

               v_gtext    handle,#200,#210,#demotext        ; Textausgabe

               graf_mouse               #257,#maus_form     ;Showmouse

               evnt_keybd               ; Auf eine Taste warten

               vsl_width  handle,#1

               vst_height               handle,#13

               vst_effects              handle,#0

               v_clsvwk   handle        ; Virtuellen Arbeitsplatz schlieûen

               appl_exit  ; Applikation abmelden

               clr.w      -(sp)         ; Programm beenden
               trap       #1


               .DATA 

demotext:      .DC.b "GEM fÅr Alle!",0
               .EVEN 
fullscreen:    .DC.w 0,0,640,400
pxyarray:      .DC.w 85,85,555,315
polygon:       .DC.w 134,120,265,160,342,70,400,150,525,125,477,210
               .DC.w 515,288,340,242,292,327,227,241,111,272,160,200,134,120

maus_form:     .DC.w $0000,$0008,$0001,$0000,$0001
               .DC.w $0000,$1fff,$3fff,$7fff      ; Hintergrundmaske
               .DC.w $ffff,$f0f0,$f8f0,$7cf0
               .DC.w $3ef0,$1ff0,$0ff0,$fff0
               .DC.w $fef0,$fcf0,$f8f0,$0000
               .DC.w $0000,$0000,$1ffe,$3ffe      ; Vordergrundmaske
               .DC.w $7060,$6060,$7060,$3860
               .DC.w $1c60,$0e60,$0660,$0e60
               .DC.w $7c60,$7860,$0000,$0000


               .END 

