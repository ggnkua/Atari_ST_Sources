GEMDOS    equ       1

Pterm	=		76
Ptermres  =         $31
Mshrink   =         $4a
Super     =         32

res_valid equ       $426                * Reset-Vektor-Magic
res_vec   equ       $42A                * Reset-Vektor

cookies   equ       $5a0

basepag   equ       4
text_sg   equ       12
data_sg   equ       20
bss_sg    equ       28

kennung   equ       'STip'              * XBRA-Kennung
stacksize equ       300                 * Programm-Stackgrîûe

prgstart: move.l    basepag(a7),a0      * Startadresse des Programms nach a0
          clr.l     d0
          move.w    #$100,d0            * ProgrammlÑnge: 256 Bytes Base-Page
          add.l     text_sg(a0),d0      * + LÑnge des Text-Segments
          add.l     data_sg(a0),d0      * + LÑnge des Data-Segments
          add.l     bss_sg(a0),d0       * + LÑnge des BSS-Segments
          move.l    d0,bedarf           * Speicherbedarf merken
          lea       stacktop,a7         * Stack setzen...

          move.l    bedarf,-(a7)        * Mshrink(prgstart-256,bedarf)
          move.l    #prgstart-256,-(a7)
          clr.w     -(a7)
          move.w    #Mshrink,-(a7)
          trap      #GEMDOS
          adda.w    #12,a7

          bsr       super_on
          bsr		check_cookie		* Cookie schon da?
          bsr       super_off
          tst.w	d0
          bne		terminate			* Ja: terminieren

          bsr       super_on
          bsr       inst_cookie         * Cookie eintragen
          bsr       super_off
          
          pea       message             * Meldung ausgeben
          move.w    #9,-(a7)            * Cconws
          trap      #GEMDOS
          addq.l    #6,a7

          clr.w     -(a7)               * Return-Code 0
          move.l    bedarf,-(a7)        * Speicherbedarf
          move.w    #Ptermres,-(a7)     * Ptermres
          trap      #GEMDOS             * ausfÅhren => Programmende

terminate:
          pea       message2            * Meldung ausgeben
          move.w    #9,-(a7)            * Cconws
          trap      #GEMDOS
          addq.l    #6,a7

          clr.w     -(a7)               * Return-Code 0
          move.w    #Pterm,-(a7)     	* Ptermres
          trap      #GEMDOS             * ausfÅhren => Programmende

		* Test, ob eigener Cookie schon da ist
		
check_cookie:
		lea		cookies,a0		* Adresse des Cookie-Jars
		tst.l	(a0)				* ist schon ein Jar da?
		bne		search_cookie		* Ja: Cookie suchen
		clr.w	d0				* Nein: kein Cookie gefunden!
		rts

search_cookie:
          move.l    (a0),a0             * Jar-Adresse holen
se_next:  tst.l     (a0)                * Jar schon zu Ende?
          beq       se_end              * Ja -> nicht weitersuchen
          cmp.l	#kennung,(a0)		* ist es der eigene Cookie
          beq		se_found
          addq.l    #8,a0               * Zeiger auf nÑchsten Cookie setzen
          bra       se_next             * nÑchsten Eintrag prÅfen

se_end:	clr.w	d0				* Cookie nicht gefunden!
		rts
		
se_found:	move.l	(a0),d0			* Cookie gefunden!
		rts

          * eigenen Cookie installieren

inst_cookie:
          lea       my_cookies,a0       * eigenen Cookie-Jar initialisieren
          clr.l     (a0)
          addq.l    #4,a0
          move.l    #20,(a0)

          lea       cookies,a0          * Adresse des Cookie-Jars
          tst.l     (a0)                * ist schon ein Jar da?
          beq       new_jar             * Nein -> neuen installieren

          * Cookie-EintrÑge zÑhlen

          moveq.l   #0,d1               * Cookie-ZÑhler
          move.l    (a0),a0             * Jar-Adresse holen
cj_next:  addq.l    #1,d1               * mitzÑhlen
          tst.l     (a0)                * Jar schon zu Ende?
          beq       cj_end              * Ja -> nicht weitersuchen
          addq.l    #8,a0               * Zeiger auf nÑchsten Cookie setzen
          bra       cj_next             * nÑchsten Eintrag prÅfen

new_jar:  move.l    #my_cookies,cookies
          move.l    res_vec,old_res     * alten Resetvektor merken
          move.l    #my_reset,res_vec   * eigenen Resetvektor eintragen
          move.l    res_valid,old_val   * alter Magic-Wert
          move.l    #$31415926,res_valid
          add.l     #160,bedarf         * Jar mit 20 Cookies braucht 160 Bytes
          bra       cj_inst             * Cookie eintragen

cj_end:   addq.l    #1,d1               * ein weiterer Cookie (fÅr uns)
          cmp.l     4(a0),d1            * ist genug Platz im Jar?
          blt       cj_inst             * Ja -> Cookie eintragen

          * Cookie-Jar kopieren, da nicht genug Platz im alten Jar war

          lea       my_cookies,a1       * Zielzeiger
          move.l    cookies,a0          * Quellzeiger
cj_copy:  move.l    4(a0),4(a1)         * Value kopieren
          move.l    (a0),(a1)           * Kennung kopieren
          beq       cj_copex            * bei 0-Eintrag ist der Jar zuende
          addq.l    #8,a0               * Quellzeiger erhîhen
          addq.l    #8,a1               * Zielzeiger erhîhen
          bra       cj_copy             * nÑchsten Cookie kopieren

cj_copex: move.l    #20,d0              * Platz fÅr 20 neue Cookies
          add.l     4(a1),d0            * alte Jar-Grîûe addieren
          move.l    d0,4(a1)            * neue Grîûe eintragen
          move.l    #my_cookies,cookies * Adresse eintragen
          lsr.l     #3,d0               * mal 8: Grîûe in Bytes
          add.l     d0,bedarf           * Speicher mitreservieren

cj_inst:  move.l    #kennung,d0         * eigene Kennung
          move.l    #0,d1       		* Wert erstmal 0
          bsr       push_cookie         * Cookie eintragen

          rts

          * ein Cookie (ID:D0, Val:D1) in den Jar eintragen (Platz muû da sein !)
push_cookie:
          move.l    cookies,A0          * Keksdosenzeiger holen
ic_next:  tst.l     (A0)                * schon am Ende ?
          beq       ic_found            * Sprung wenn ja
          addq.l    #8,A0               * Zeiger weitersetzen
          bra       ic_next             * nÑchsten Eintrag untersuchen
ic_found: move.l    4(A0),D2            * Anzahl holen
          move.l    D0,(A0)             * ID eintragen
          move.l    D1,4(A0)            * Value eintragen
          clr.l     8(A0)               * neuer Anzahl-Cookie
          move.l    D2,12(A0)           * Anzahl eintragen
          rts

old_val:  dc.l      0
          dc.b      'XBRA'
          dc.b      'CHBT'
old_res:  dc.l      0
my_reset:
          clr.l     cookies             * alten Cookie-Zeiger lîschen
          move.l    old_val(PC),res_valid * alten magic-Wert zurÅck
          move.l    old_res(PC),res_vec * alten Vektor zurÅck
          move.l    $04,A0              * System-Resetvektor holen
          jmp       (A0)                * und anspringen

super_on: movem.l   a0-a6/d0-d7,-(a7)
          clr.l     -(sp)               * Supervisormode an
          move.w    #Super,-(sp)
          trap      #GEMDOS
          addq.l    #6,sp
          move.l    d0,save_ssp
          movem.l   (a7)+,a0-a6/d0-d7
          rts

super_off:movem.l   a0-a6/d0-d7,-(a7)
          move.l    save_ssp,-(sp)      * Supervisormode aus
          move.w    #Super,-(sp)
          trap      #GEMDOS
          addq.l    #6,sp
          movem.l   (a7)+,a0-a6/d0-d7
          rts


          data
          even
message:  dc.b      $0d,$0a,"Auto STip 1.0 installiert!",$0d,$0a,$0d,$0a,$00
		even
message2: dc.b      $0d,$0a,"Auto STip 1.0 ist bereits installiert!",$0d,$0a,$0d,$0a,$00


          bss
          even
bedarf:   ds.l      1                   * Speicherbedarf des Programms
save_ssp: ds.l      1                   * Supervisorstackpointerzwischenspeicher
		ds.w      stacksize/2         * Speicher fÅr Programm-Stack
stacktop: ds.w      1

my_cookies:
          ds.l      1
          ds.l      1


          end
