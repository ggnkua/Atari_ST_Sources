GLOBL		scroll_lr;
GLOBL		scroll_ou;
  
scroll_lr:	movea.l 4(SP),A0 		 ;Adr. der Struktur
      			move.w  (A0),words   ;Vars aus Struktur in
        	  		                 ;in Register schieben
      			move.l  2(A0),offset 
      			move.w  6(A0),zeilen 
      			move.l  8(A0),quelle ;Adresse des Blocks
      			move.w  12(SP),D2  
      			subq.w  #1,D2
anzahl:			move.l  8(SP),D3 
pause1:			dbf     D3,pause1     ;Pause 
            							       	;Scrollgeschwindigkeit absolut
       			movea.l quelle,A0       
       			move.w  zeilen,D1       
       			cmpi.w  #1,14(SP)		  ;TRUE = linksherum
       			beq.s   links1            
rechts1:		move.w  -2(A0),D0 
       			roxr.w  #1,D0 
       			move.w  words,D0      ;worte pro Zeile  
       			suba.l  offset,A0     ;Ptr auf Zeilenanf.
rechts2:		roxr.w  (A0)+         ;alle Bytes 1
                             			;Pixel weiterrollen
       			dbf     D0,rechts2  
       			suba.l  #80,A0        ;==> 1 Zeile h”her
       			dbf     D1,rechts1
       			dbf     D2,anzahl
       			bra.s   end           ;das war's schon
       
links1:			move.w  (A0),D0  
       			roxl.w  #1,D0
       			move.w  words,D0         
       			adda.l  offset,A0       
links2:			roxl.w  -(A0)
       			dbf     D0,links2
       			adda.l  #80,A0        ;==> n„chste Zeile
       			dbf     D1,links1
       			dbf     D2,anzahl
end:       	rts


scroll_ou:	movea.l 4(SP),A0  		;Adr. der Struktur
		       	move.w  (A0),words  
		       	move.l  2(A0),offset
		       	move.w  6(A0),zeilen 
		       	movea.l 8(A0),A1      ;Adresse des Blocks
		       	movea.l A1,A3 
		       	move.w  zeilen,D0     ;==> Zeilenzahl * 80
		       	mulu.w  #80,D0        ;==> anpassen
		       	cmpi.w  #1,14(SP) 
		       	beq.s   add              
		       	suba.l  D0,A3         ;Adr der 1. Zeile
		       	bra.s   cont
add:				adda.l  D0,A3         ;Adr der letzten 
		        	                    ;Zeile fr hochsrollen
cont:  			move.l  A1,anfang     ;Anfangs-Adr. buffern
		       	move.l  A3,ende       ;last_line buffern
		       	move.w  12(SP),D3     ;Gesamtdurchl„ufe
		       	subq.w  #1,D3
z1:    			move.w  zeilen,D1     ;1. Schleife: 
            		                  ;Gesamtdurchl„ufe
       			movea.l anfang,A2     ;Laufptr auf Anfang
       			movea.l anfang,A1     ;Adr. der ersten
                         ;und letzten Zeile laden
  		      move.l  ende,A3
z: 		      move.l  8(SP),D0      ;2. Schleife:
		                               ;zeilenweise
pause: 			dbf     D0,pause       ;Pause...
		       	move.w  words,D2       ;Worte pro Zeile
		       	cmpi.w  #1,14(SP)
		       	beq.s   wo 
		        					             ; nach unten:
wu:    			move.w  -82(A2),-(A2)  ;==> 3.Schleife:
		 ;Jede Zeile wortweise eine Zeile tiefer schieben
		       	dbf     D2,wu      
		     	  adda.l  offset,A2     
		      	suba.l  #80,A2         ;==> n„chste Zeile
		       	dbf     D1,z
		       	move.w  words,D2  ;letzte Zeile in erste
ll:    			move.w  -(A1),-(A3)  
		       	dbf     D2,ll
		       	dbf     D3,z1 
		       	bra.s   end2     ;fertig
		        	               ;nach oben:
wo:    			move.w  80(A2),(A2)+   ;==>
		  ;jede Zeile wortweise eine Zeile h”her schieben
		        dbf     D2,wo  
		       	sub.l   offset,A2 
		       	add.l   #80,A2         ;==> n„chste Zeile
		       	dbf     D1,z
		       	move.w  words,D2 
fl:    			move.w  (A1)+,(A3)+
		        						        ;erste Zeile in die letzte Zeile
		       	dbf     D2,fl 
		       	dbf     D3,z1
end2:      	rts



quelle:			ds.p	1
anfang:			ds.p	1
ende:				ds.p	1
zeilen:			ds.w	1
words:			ds.w	1
offset:			ds.l	1

						.END         

