; MAGNUM FASTRAM-Installation
;
; $Id: magnum.s,v 1.10 1997/03/14 00:14:30 rincewind Exp $
; 
; $Log: magnum.s,v $
; Revision 1.10  1997/03/14  00:14:30  rincewind
; *** empty log message ***
;
; Revision 1.9  1996/11/28  17:59:48  rincewind
; Ramtest abschaltbar
;
; Revision 1.8  1996/11/28  17:10:58  rincewind
; Angepasst fuer Magnum-ST
;
; Revision 1.7  1995/09/13  18:01:12  rincewind
; changed memory mirror test for new MACH version
; made texts readable in 40-column mode
;
; Revision 1.6  1995/09/13  12:13:26  rincewind
; disable data cache during memory organization check
;
; Revision 1.5  1995/09/08  13:48:40  rincewind
; first working release version
;
; Revision 1.4  1995/08/30  16:41:44  rincewind
; moved patch area in magnum.s
;
; Revision 1.3  1995/08/28  21:31:40  rincewind
; changed cookie to point to structure
;
; Revision 1.2  1995/08/28  20:13:34  rincewind
; first version ... untested
;

                IMPORT sleep
resvalid        EQU $0426       ;Reset-Vektor Magic
resvector       EQU $042A       ;der Reset-Vektor
_p_cookies_     EQU $05A0       ;Zeiger auf das Cookie Jar
berr_vec        EQU $8          ;Buserror-Vektor
COOKIE          EQU "MAGN"

 .IF MAGNUM_F030
; Konfigurationsregister der Karte (Bytezugriff)
MAGCONF1        EQU $FFFF8061
; Belegung: %xxxxxxnn
;                  |+- OverScan Inside - 1 = aktiviert, nach Reset 0
;                  +-- 0 = doublesided / 1 = singlesided RAM
MAGCONF2        EQU $FFFF8063
; Belegung: %xxxxxxnn
;                  |+- Speichergrîûe:  00 nach reset
;                  +-- 00 = 0MB
;                      01 = 4MB
;                      10 = 6MB
;                      11 = 8MB
 .ENDIF

                MACRO SUPEXEC addr
                clr.l   sup_ret
                pea     addr(pc)
                move.w  #38,-(sp)
                trap    #14
                addq.l  #6,sp
                ENDM

                MACRO PRINTSTR string
                lea     string(pc),a0
                bsr     print
                ENDM

                MACRO PUTC val
                move.w  val,d0
                bsr     putc
                ENDM
                
start:          bra     start2


the_cookie:     dc.w    1               ; Versionsnummer
alt_ram_start:  dc.l    0               ; Startadresse Fastram
alt_ram_len:    dc.l    0               ; LÑnge Fastram

cookie_space:   DS.B    8*1000          ; Platz fÅr max. 1000 Cookies

                dc.b "MAGPATC2"
patch_space:    dc.w    $01             ; Konfiguration:
                                        ; Bit 0: ausfÅhrlicher Ramtest
                                        ; Bit 1: Blitter auf 8MHz
                                        ; Bit 2: Speicher auf 6MB begrenzen
                                        ; Bit 3: kein Ramtest

 .IF MAGNUM_ST
                dc.w     9              ; Bitmaske der mîgl. Optionen
 .ENDIF
 .IF MAGNUM_F030
                dc.w    15
 .ENDIF               


start2:         lea     init_text(PC),A0
                bsr     print

                SUPEXEC cookie1
                tst.l   sup_ret
                bne     is_inst

                SUPEXEC test_magnum
                btst    #1,sup_ret
                bne     is_mem_err
                btst    #0,sup_ret
                bne     no_magnum

                move.w  mem_config(pc),d0
                beq     no_mem
                asl.w   #2,d0
                move.l  mem_txt_tab(pc,d0.w),a0
                bsr     print

                bsr     memtest
                tst.l   mem_err_addr
                bne     is_inst3

; bra.s no_err
                move.l  alt_ram_len,-(SP)
                move.l  alt_ram_start,-(SP)
                move.w  #$14,-(SP)      ; Maddalt(start,len)
                trap    #1
                lea     10(SP),SP
                tst.w   D0
                bne.s   maddalt_error

                lea     ok_txt(PC),A0
                bsr     print

 .IF MAGNUM_F030
                SUPEXEC slow_blitter
.ENDIF
                SUPEXEC cookie2
.IF MAGNUM_ST
		clr.l	alt_ram_len ; nicht DMA-fÑhig, in cookie austragen
.ENDIF

                tst.l   res_len
                beq     not_res
; resident bleiben
                move.l  res_len,D7
                add.l   #$108+cookie_space-start,D7
                clr.w   -(SP)
                move.l  D7,-(SP)
                move.w  #$31,-(SP)
                trap    #1              ;Ptermres()
                illegal

mem_txt_tab:    dc.l 0,memtxt1,memtxt2,memtxt3

no_mem:         lea     no_mem_txt(pc),a0
                bra.s   is_inst2
maddalt_error:  lea     maddalt_txt(PC),A0
                bra.s   is_inst2
no_err:         lea     no_err_txt(PC),A0
                bra.s   is_inst2
no_magnum:      lea     no_magnum_txt(PC),A0
                bra.s   is_inst2
is_mem_err:     lea     is_mem_txt(PC),A0
                bra.s   is_inst2
is_inst:        lea     is_inst_txt(PC),A0
is_inst2:       bsr.s   print
is_inst3:       move.w  #8,-(sp)        ;Cnecin()
                trap    #1
                addq.l  #2,sp
not_res:        clr.w   -(SP)
                trap    #1              ;Pterm0()
                illegal

print:          move.l  a0,a6
print2:         move.b  (a6)+,d0
                beq.s   putc2
                bsr.s   putc
                bra.s   print2

putc:           movem.l a0-a2,-(sp)
                move.w  d0,-(sp)
                move.l  #$00030002,-(sp)
                trap    #13
                addq.l  #6,sp
                movem.l (sp)+,a0-a2
putc2:          rts

print_hex:      move.l  d0,d7
                moveq   #7,d6
print_hex2:     rol.l   #4,d7
                move.b  d7,d0
                and.w   #$0f,d0
                move.b  hextab(pc,d0.w),d0
                bsr     putc
                dbra    d6,print_hex2
                rts
hextab:         dc.b    "0123456789ABCDEF"

 .IF MAGNUM_F030
slow_blitter:   btst.b  #1,patch_space+1
                beq.s   slow_blit2
                bclr.b  #2,$FFFF8007.w
slow_blit2:     rts                
 .ENDIF
 
; Cookie-Routinen initialisieren und testen, ob RAM schon installiert ist
cookie1:        moveq   #0,D0
                bsr     hunt_cookie     ;Abschlu·-Cookie suchen
                move.l  D0,D2           ;LÑnge der bisherigen Liste merken
                addq.l  #8,D2           ;8 EintrÑge dazu
                move.l  D2,new_cookie_num

                move.l  #COOKIE,D0
                bsr     hunt_cookie     ;Cookie suchen
                bmi     cookie1a        ;nicht gefunden
                bset    #0,sup_ret
cookie1a:       rts                

; _FRB und MAGN-Cookie anlegen
cookie2:        move.l  new_cookie_num(pc),D2
                lea     cookie_space(PC),A0 ;Zeiger auf das evtl. Cookie Jar
                move.l  #COOKIE,D0
                move.l  #the_cookie,D1  ;Cookie-Wert
                bsr     insert_cookie   ;ins Cookie Jar eintragen
                tst.w   D0              ;RÅckgabewert von insert_cookie()
                beq.s   cookie2a        ;Cookiejar nicht erweitert

                move.l  new_cookie_num,d1
                addq.w  #1,D1
                lsl.l   #3,D1           ;mal 8 (da ein Cookie = 8 Bytes)
                move.l  d1,res_len      ;so viele Bytes resident

cookie2a:       move.l  #'_FRB',D0
                bsr     hunt_cookie     ;Cookie suchen
                bpl.s   cookie2c        ;gefunden => nicht neu anlegen

                move.l  new_cookie_num(pc),D2
                lea     cookie_space(PC),A0 ;Zeiger auf das evtl. Cookie Jar
                move.l  #'_FRB',D0
                move.l  A0,D1           ;Cookie-Wert = Start cookie_space + res_len
                add.l   res_len,D1
                bsr     insert_cookie   ;ins Cookie Jar eintragen
                tst.w   D0              ;RÅckgabewert von insert_cookie()
                beq.s   cookie2b        ;Cookiejar nicht erweitert

                move.l  new_cookie_num,d1
                addq.w  #1,D1
                lsl.l   #3,D1           ;mal 8 (da ein Cookie = 8 Bytes)
                move.l  d1,res_len      ;so viele Bytes resident
                add.l   #cookie_space,D1 ; Startadresse _FRB

                move.l  #'_FRB',D0
                bsr     change_cookie   ; Ñndern
cookie2b:       add.l   #65536,res_len  ; Platz fÅr Fastram-Buffer
cookie2c:       rts                

 .IF MAGNUM_F030
; Testen, ob MAGNUM-F030-Karte im Rechner ist
test_magnum:    move.l  berr_vec,a5
                move.l  sp,a6
                move.w  sr,d7
                or.w    #$0700,sr
                movec   cacr,d6
                move.l  d6,d0
                bclr    #8,d0            ; disable data cache
                bset    #11,d0           ; clear data cache
                movec   d0,cacr
                move.l  #test_m_berr,berr_vec
                bclr    #1,MAGCONF1
                btst    #1,MAGCONF1
                bne     test_m_berr
                bset    #1,MAGCONF1
                btst    #1,MAGCONF1
                beq     test_m_berr
                clr.b   MAGCONF2
                move.b  MAGCONF2,d0
                and.b   #3,d0
                bne     test_m_berr
                move.b  #3,MAGCONF2
                move.b  MAGCONF2,d0
                and.b   #3,d0
                cmp.b   #3,d0
                bne     test_m_berr
; Karte scheint da zu sein. Jetzt Speicher einblenden:
                move.l  #$400000,a0       ; Adresse Test 1
                move.l  a0,alt_ram_start
                move.l  #$800000,a1       ; Adresse Test 2
                move.l  a1,alt_ram_len
                move.b  #3,d0
                btst.b  #2,patch_space+1  ; Limit auf 6MB?
                beq.s   test_m2
                move.l  #$600000,alt_ram_len
                move.b  #2,d0             ; nur 6MB einblenden
test_m2:        move.b  d0,MAGCONF2
                bset    #1,MAGCONF1       ; singlesided versuchen
                move.l  #$23456780,(a0)
                move.l  #$12345678,(a1)
                cmp.l   #$23456780,(a0)
                bne.s   test_m3           ; keine 8MB
                cmp.l   #$12345678,(a1)
                bne.s   test_m3
; Test auf Spiegelung nach 1MB
                move.l  #$500000,a1
                move.l  #$23456780,(a0)
                move.l  #$12345678,(a1)
                cmp.l   #$23456780,(a0)
                bne.s   test_m3           ; keine 8MB
                cmp.l   #$12345678,(a1)
                bne.s   test_m3
; Test auf Spiegelung nach 2MB
                move.l  #$600000,a1
                move.l  #$23456780,(a0)
                move.l  #$12345678,(a1)
                cmp.l   #$23456780,(a0)
                bne.s   test_m3           ; keine 8MB
                cmp.l   #$12345678,(a1) 
                bne.s   test_m3
; stimmt: 8MB singlesided
                move.w  #2,mem_config
                bra.s   test_m_end
test_m3:        bclr    #1,MAGCONF1       ; doublesided versuchen
                move.l  #$800000,a1
                move.l  #$23456780,(a0)
                move.l  #$12345678,(a1)
                cmp.l   #$23456780,(a0)
                bne.s   test_m4           ; keine 8MB
                cmp.l   #$12345678,(a1)   ; stimmt: 8MB doublesided
                bne.s   test_m4
                move.w  #3,mem_config
                bra.s   test_m_end
test_m4:        move.l  #$12345678,(a0)
                move.l  #$23456780,4(a0)
                cmp.l   #$12345678,(a0)
                bne.s   test_m_nomem      ; nichtmal 4MB
                cmp.l   #$23456780,4(a0)
                bne.s   test_m_nomem      ; nichtmal 4MB
                move.w  #1,mem_config     ; nur 4MB gefunden
                move.b  #1,MAGCONF2       ; dann auch nur 4MB einblenden
                move.l  #$400000,alt_ram_len
test_m_end:     move.l  a5,berr_vec
                movec   d6,cacr
                move.l  a6,sp
                move.w  d7,sr
                rts
test_m_berr:    bset    #0,sup_ret
                bra.s   test_m_end
test_m_nomem:   clr.l   alt_ram_len
                clr.w   mem_config
                bra.s   test_m_end                
 .ENDIF

; MAGNUM-ST testen

 .IF MAGNUM_ST
; Testen, ob MAGNUM-ST-Karte im Rechner ist
test_magnum:    move.l  berr_vec,a5
                move.l  sp,a6
                move.w  sr,d7
                or.w    #$0700,sr
;                movec   cacr,d6
;                move.l  d6,d0
;                bclr    #8,d0            ; disable data cache
;                bset    #11,d0           ; clear data cache
;                movec   d0,cacr

; Test, ob *kein* Speicher ab 4MB liegt
                move.l  #test_m1,berr_vec
                move.l  $400010,d0
; Speicher ist da -> Fehler!
		bset	#1,sup_ret
		bra	test_m_end                
; Jetzt Magnum einblenden                
test_m1:	move.l  #test_m1a,berr_vec
	        move.w  $6c4710,d0
test_m1a:	move.l	#test_m1b,berr_vec
		move.w  $5d1234,d0
test_m1b:	move.l	#test_m1c,berr_vec
		move.w	$6d3148,d0
test_m1c:	move.l	#test_m1d,berr_vec		
		;move.w	$5c0814,d0
test_m1d:	move.l	#test_m1e,berr_vec	
		;move.w	$6c8810,d0
test_m1e:
                move.l  #test_m4,berr_vec
; Karte scheint da zu sein. Jetzt Speicher einblenden:
                move.l  #$400000,a0       ; Adresse Test 1
                move.l  a0,alt_ram_start
                move.l  #$800000,a1       ; Adresse Test 2
                move.l  a1,alt_ram_len

test_m3:        move.l  #$23456780,(a0)
                move.l  #$12345678,(a1)
                cmp.l   #$23456780,(a0)
                bne.s   test_m4           ; keine 8MB
                cmp.l   #$12345678,(a1)   ; stimmt: 8MB doublesided
                bne.s   test_m4
                move.w  #3,mem_config
                bra.s   test_m_end
test_m4:        move.l  #test_m_berr,berr_vec
                move.l  #$12345678,(a0)
                move.l  #$23456780,4(a0)
                cmp.l   #$12345678,(a0)
                bne.s   test_m_nomem      ; nichtmal 4MB
                cmp.l   #$23456780,4(a0)
                bne.s   test_m_nomem      ; nichtmal 4MB
                move.w  #1,mem_config     ; nur 4MB gefunden
                move.l  #$400000,alt_ram_len
test_m_end:     move.l  a5,berr_vec
;                movec   d6,cacr
                move.l  a6,sp
                move.w  d7,sr
                rts
test_m_berr:    bset    #0,sup_ret
                bra.s   test_m_end
test_m_nomem:   clr.l   alt_ram_len
                clr.w   mem_config
                bra.s   test_m_end
 .ENDIF
 
memtest:        PRINTSTR testtxt1
                move.w  alt_ram_len,d0
                lsr.l   #4,d0
                add.w   #'0',d0
                bsr     putc
                PRINTSTR testtxt2
                PRINTSTR reverse_on
                move.w  alt_ram_len,d7
                lsr.w   #2,d7             ; 8 MB = 32* 256K-Blîcke
                subq.w  #1,d7
memtest2:       PUTC    #' '
                dbra    d7,memtest2
                PUTC    #13
                clr.l   mem_err_addr

                move.l  alt_ram_start,a0
                move.l  a0,a2
                add.l   alt_ram_len,a2
do_test2:       move.l  a0,a1
                add.l   #256*1024,a1

                btst    #0,patch_space+1
                beq     do_test3
                btst    #3,patch_space+1
                bne     do_test4
                move.l  #$55555555,d1
                bsr     mt_long
                tst.l   mem_err_addr
                bne     memtest3

                move.l  #$aaaaaaaa,d1
                bsr     mt_long
                tst.l   mem_err_addr
                bne     memtest3

                move.l  #$5a5a5a5a,d1
                bsr     mt_long
                tst.l   mem_err_addr
                bne     memtest3

                move.l  #$a5a5a5a5,d1
                bsr     mt_long
                tst.l   mem_err_addr
                bne     memtest3

                move.l  #$47110815,d1
                bsr     mt_long
                tst.l   mem_err_addr
                bne.s   memtest3

                moveq   #-1,d1
                bsr     mt_refresh1
                tst.l   mem_err_addr
                bne.s   memtest3

                moveq   #-1,d1
                bsr     mt_refresh2
                tst.l   mem_err_addr
                bne.s   memtest3

                movem.l d1-d2/a0-a2,-(sp)
                move.l  #$00010002,-(sp)
                trap    #13
                addq.l  #4,sp
                movem.l (sp)+,d1-d2/a0-a2
                cmp.w   #-1,d0
                bne.s   do_test3
                bset    #3,patch_space+1

do_test3:       moveq   #0,d1
                bsr     mt_refresh1
                tst.l   mem_err_addr
                bne.s   memtest3

                moveq   #0,d1
                bsr     mt_refresh2
                tst.l   mem_err_addr
                bne.s   memtest3

do_test4:       tst.l   mem_err_addr
                bne.s   memtest3
                move.l  a1,a0
                PUTC    #'-'
                cmp.l   a0,a2
                bne     do_test2

                PRINTSTR reverse_off
                rts
memtest3:       PRINTSTR testtxt3
                move.l  mem_err_addr,d0
                bsr     print_hex
                PRINTSTR testtxt4
                rts

mt_long:        move.l  a0,a3
mt_long2:       REPT    4
                move.l  d1,(a3)+
                ENDM
                cmp.l   a3,a1
                bne.s   mt_long2
                move.l  a0,a3
mt_long3:       REPT    4
                cmp.l   (a3)+,d1
                bne.s   mt_long4
                ENDM
                cmp.l   a3,a1
                bne.s   mt_long3
                rts
mt_long4:       subq.l  #4,a3
                move.l  a3,mem_err_addr
                rts

mt_refresh1:    move.l  a0,a3
mt_refresh1a:   REPT    16
                move.l  d1,(a3)+
                ENDM
                cmp.l   a3,a1
                bne.s   mt_refresh1a
                rts

mt_refresh2:    move.l  a0,a3
mt_refresh2b:   REPT    16
                cmp.l   (a3)+,d1
                bne.s   mt_refresh2a
                ENDM
                cmp.l   a3,a1
                bne.s   mt_refresh2b
                rts
mt_refresh2a:   subq.l  #4,a3
                move.l  a3,mem_err_addr
                rts
                
; Speicherkonfiguration:
; 0 = kein Speicher gefunden
; 1 = 4MB
; 2 = 8MB singlesided
; 3 = 8MB doublesided
mem_config:     dc.w    0
sup_ret:        dc.l    0
new_cookie_num: dc.l    0
res_len:        dc.l    0
mem_err_addr:   dc.l    0

memtxt1:        dc.b " 4MB (singlesided) gefunden",0
memtxt2:        dc.b " 8MB (singlesided) gefunden",0
memtxt3:        dc.b " 8MB (doublesided) gefunden",0
testtxt1:       dc.b ", teste ",0
testtxt2:       dc.b "MB:",13,10,0
testtxt3:       dc.b 27,'q',13,10
                dc.b " Fehler bei Adresse $",0
testtxt4:       dc.b " - Test abgebrochen!",13,10,0
reverse_on:     dc.b 27,'p',0
reverse_off:    dc.b 27,'q ',0
ok_txt:         dc.b "OK",13,10,0
;                     0123456789012345678901234567890123456789
maddalt_txt:    DC.B 13,10," Fehler bei Maddalt() - kann Alternate",13,10
                DC.B " RAM nicht anmelden!",13,10,0
is_inst_txt:    DC.B " Fehler: MAGNUM ist bereits installiert!",13,10,0
no_magnum_txt:  DC.B " Fehler: keine MAGNUM-Karte gefunden!",13,10,0
is_mem_txt:     DC.B " Fehler: fremder Speicher gefunden - Magnum",13,10
                DC.B " wird nicht installiert!",13,10,0
no_mem_txt:     DC.B " Fehler: kein Speicher auf Magnum-Karte!",13,10,0
no_err_txt:     DC.B " Fehler: kein Fehler gefunden!",13,10,0
init_text:      DC.B 27,'f',13,10,27,"p "
 .IF MAGNUM_ST
                DC.B "MAGNUM-ST"
 .ENDIF
 .IF MAGNUM_F030
                DC.B "MAGNUM-F030"
 .ENDIF               
                DC.B " Alternate-RAM Installation V1.10 ",27,"q",13,10
                DC.B " Ω 1995-97 Michael Schwingen",13,10,0

                EVEN

********************************************************************************
* Routinen, um das "Cookie Jar" (siehe ST-Magazin 3/90) in eigenen Assembler-  *
* Programmen zu verwenden.                                                     *
*                                                                              *
* hunt_cookie(D0.l) - Sucht den Cookie mit dem Namen D0.l im Cookie Jar. Wurde *
*                     er gefunden, steht sein Wert in D0.l. Wurde er nicht ge- *
*                     funden, ist das N(egativ)-Flag des CCR-Registers gesetzt *
*                                                                              *
* insert_cookie(D0.l,D1.l,D2.l,A0.l) -                                         *
*                     TrÑgt einen Cookie mit dem Namen D0.l und dem Wert D1.l  *
*                     im Cookie Jar ein. Falls der Platz im Cookie Jar nicht   *
*                     mehr reicht, oder das Cookie Jar gar nicht existiert,    *
*                     wird es angelegt oder vergrî·ert. Wenn ein Cookie Jar    *
*                     neu angelegt wird, klinkt sich die Routine in den RESET- *
*                     vektor ein, um das Cookie Jar beim RESET zu entfernen.   *
*                     Wurde das Jar neu angelegt oder vergrî·ert, so MUSS das  *
*                     aufrufende Programm RESIDENT bleiben (ist bei Accessorys *
*                     nicht mîglich!!!). FÅr den Fall, da· ein Cookie Jar ein- *
*                     gerichtet werden mu·, mu· man stets in D2.l die LÑnge    *
*                     des eventuellen Cookie Jars in Langworten und in A0.l    *
*                     ein Zeiger auf den Buffer Åbergeben werden.              *
*                                                                              *
* ACHTUNG: beide Routinen mÅssen im Supervisor-Mode aufgerufen werden!!!       *
*                                                                              *
* Am Besten, wenn man sich das Demo-Programm ansieht.                          *
*                                                                              *
* Ω1990 ‰-soft, geschrieben von Markus Fritze fÅr den TurboAss V1.5            *
********************************************************************************
;Cookie mit dem Namen D0.l suchen und auf D1.l setzen
;Parameter:  D0.l : Name des Cookies
;            D1.l : neuer Wert
;            D0.l : Wert des gefundenen Cookies
;             N=1  : Cookie nicht gefunden (D0.l = LÑnge des bisherigen Jars)

change_cookie:  movem.l D1-D3/A0,-(SP)
                move.l  D0,D2           ;gesuchten Namen merken
                move.l  D1,D3           ; neuen Wert merken
                move.l  _p_cookies_.w,D0 ;Zeiger auf das Cookie Jar holen
                beq.s   change_cookie2  ;ist leer => nix gefunden
                movea.l D0,A0
change_cookie1: move.l  (A0)+,D1        ;Namen eines Cookies holen
                move.l  (A0)+,D0        ;und den Wert holen
                cmp.l   D2,D1           ;Eintrag gefunden?
                beq.s   change_cookie4  ;Ja! =>
                tst.l   D1              ;Ende der Liste?
                bne.s   change_cookie1  ;Nein! => weiter vergleichen
change_cookie2: moveq   #-1,D1          ;N-Flag=1, d.h. nix gefunden
change_cookie3: movem.l (SP)+,D1-D3/A0
                rts
change_cookie4: move.l  D3,-(A0)
                bra.s   change_cookie3

;Cookie mit dem Namen D0.l suchen.
;Parameter:  D0.l : Name des Cookies
;            D0.l : Wert des gefundenen Cookies
;             N=1  : Cookie nicht gefunden (D0.l = LÑnge des bisherigen Jars)

hunt_cookie:    movem.l D1-D2/A0,-(SP)
                move.l  D0,D2           ;gesuchten Namen merken
                move.l  _p_cookies_.w,D0 ;Zeiger auf das Cookie Jar holen
                beq.s   hunt_cookie2    ;ist leer => nix gefunden
                movea.l D0,A0
hunt_cookie1:   move.l  (A0)+,D1        ;Namen eines Cookies holen
                move.l  (A0)+,D0        ;und den Wert holen
                cmp.l   D2,D1           ;Eintrag gefunden?
                beq.s   hunt_cookie3    ;Ja! =>
                tst.l   D1              ;Ende der Liste?
                bne.s   hunt_cookie1    ;Nein! => weiter vergleichen
hunt_cookie2:   moveq   #-1,D1          ;N-Flag=1, d.h. nix gefunden
hunt_cookie3:   movem.l (SP)+,D1-D2/A0
                rts

;eigenen Cookie in das Cookie jar
;Parameter:  D0.l : Name des Cookies
;            D1.l : Wert des Cookies
;            D2.l : LÑnge eines eventuell einzurichtenden Cookie Jars (Langworte)
;            A0.l : Adresse eines eventuell einzurichtenden Cookie Jars
;            D0.w : 0 - alles ok, Cookie wurde eingetragen
;                    1 - wie (1), aber nun resetfest, d.h. resident bleiben
;                    2 - wie (2), aber nicht resetfest eingeklinkt
;                   <0 - Fehler aufgetreten, Cookie nicht eingetragen

insert_cookie:  movem.l D2-D5/A1,-(SP)
                move.l  D2,D5           ;LÑnge einer evtl. Liste merken
                move.l  _p_cookies_.w,D3 ;Zeiger auf das Cookie Jar holen
                beq.s   insert_cookie_s ;ist leer => Liste einrichten
                movea.l D3,A1
                moveq   #0,D4           ;Anzahl der Slots
insert_cookie_h:addq.w  #1,D4           ;Slotanzahl erhîhen
                movem.l (A1)+,D2-D3     ;Namen und Wert eines Cookies holen
                tst.l   D2              ;leeren Cookie gefunden?
                bne.s   insert_cookie_h ;Nein => weiter suchen
                cmp.l   D3,D4           ;alle Slots belegt?
                beq.s   insert_cookie_n ;Ja! => neue Liste anlegen
                movem.l D0-D4,-8(A1)    ;neuen Cookie & Listenende einfÅgen
                moveq   #0,D0           ;alles ok!
                bra.s   insert_cookie_x ;und raus

insert_cookie_s:moveq   #2,D4
                cmp.l   D4,D2           ;weniger als 2 EintrÑge?
                blo.s   insert_cookie_e ;das ein Fehler! (Liste zu klein!)
;                move.l  resvector.w,old_resvector
;                move.l  resvalid.w,old_resvalid ;alten Reset-Vektor merken
;               move.l  #cookie_reset,resvector.w
;                move.l  #$31415926,resvalid.w ;und eigenen einsetzen
                move.l  A0,_p_cookies_.w ;Cookie Jar initialisieren
                moveq   #0,D3           ;Markierung: Ende der Cookie-List
                exg     D2,D3           ;Anzahl der Slots nach D3
                movem.l D0-D3,(A0)      ;Namen und Wert des Cookies einsetzen
                moveq   #1,D0           ;Liste resetfest eingerichtet, alles ok
                bra.s   insert_cookie_x ;und raus

insert_cookie_e:moveq   #-1,D0          ;Fehler, Cookie nicht eingetragen
                bra.s   insert_cookie_x ;und raus


insert_cookie_n:cmp.l   D5,D4           ;reicht der Platz?
                ble.s   insert_cookie_e ;Nein => Fehler und raus
                movea.l _p_cookies_.w,A1 ;Anfang der Liste erneut holen
                move.l  A0,_p_cookies_.w ;neuen Cookie Jar eintragen
                subq.w  #2,D4           ;Ende nicht kopieren (-1 fÅr DBRA)
insert_cookie_m:move.l  (A1)+,(A0)+     ;EintrÑge der Liste kopieren
                move.l  (A1)+,(A0)+
                dbra    D4,insert_cookie_m
                move.l  D5,D3           ;Anzahl der Slots
                movem.l D0-D3,(A0)      ;eigenes Element eintragen + Listenende
                moveq   #2,D0           ;alles ok, resident bleiben
insert_cookie_x:movem.l (SP)+,D2-D5/A1
                rts
                END
