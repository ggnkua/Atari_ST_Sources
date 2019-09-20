; MAGNUM FASTRAM-Installation
;
; $Id: himem.s,v 1.2 1998/05/14 11:44:00 rincewind Exp $
; 
; $Log: himem.s,v $
; Revision 1.2  1998/05/14  11:44:00  rincewind
; shrink memory at start, check for machine cookie
;
; Revision 1.1  1997/03/14  00:13:56  rincewind
; Initial revision
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
_p_cookies      EQU $05A0       ;Zeiger auf das Cookie Jar
memctrl		EQU $0424	;Shadow von $ffff8001
phystop		EQU $042E
berr_vec        EQU $8          ;Buserror-Vektor
COOKIE          EQU "HMEM"
MAGIC1		EQU "MAGN"
MAGIC2		EQU "WARM"

BLK1_START	EQU $e80000
BLK1_LEN	EQU $080000
BLK2_START	EQU $f20000
BLK2_LEN	EQU $080000

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
_alt_ram_start:  dc.l    0               ; Startadresse Fastram
_alt_ram_len:    dc.l    0               ; LÑnge Fastram

cookie_space:   DS.B    8*1000          ; Platz fÅr max. 1000 Cookies

                dc.b "MAGPATC2"
patch_space:    dc.w    $01             ; Konfiguration:
                                        ; Bit 0: ausfÅhrlicher Ramtest
                                        ; Bit 1: Blitter auf 8MHz
                                        ; Bit 2: Speicher auf 6MB begrenzen
                                        ; Bit 3: kein Ramtest
                dc.w     9              ; Bitmaske der mîgl. Optionen

start2:         move.l	4(sp),a0
		lea	new_stack(pc),sp
		move.l	#$10100,d0	; 64K fÅr FRB plus Basepage
		add.l	$c(a0),d0
		add.l	$14(a0),d0
		add.l	$1c(a0),d0
		move.l	d0,-(sp)
		move.l	a0,-(sp)
		clr.w	-(sp)
		move.w	#$4a,-(sp)
		trap	#1
		lea	12(sp),sp
		
		lea     init_text(PC),A0
                bsr     print

                SUPEXEC cookie1
                tst.l   sup_ret
                bne     is_inst


		move.w	machine,d0
		beq.s	start2a		; ST oder kein Cookie
		sub.w	#1,d0
		bne	machine_err	; auch kein STE

start2a:        SUPEXEC test_magnum
                btst    #0,sup_ret
                bne     no_magnum

		cmp.l	#MAGIC1,save_magic
		bne.s	start3
		cmp.l	#MAGIC2,save_magic+4
		bne.s	start3
		bset	#3,patch_space+1

start3:		bsr     memtest
                tst.l   mem_err_addr
                bne     is_inst2

		move.l	#BLK1_START,a1
		lea	save_magic(pc),a0
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+

                move.l  #BLK1_LEN-16,-(SP)
                move.l  #BLK1_START+16,-(SP)
                move.w  #$14,-(SP)      ; Maddalt(start,len)
                trap    #1
                lea     10(SP),SP
                tst.w   D0
                bne.s   maddalt_error

                move.l  #BLK2_LEN,-(SP)
                move.l  #BLK2_START,-(SP)
                move.w  #$14,-(SP)      ; Maddalt(start,len)
                trap    #1
                lea     10(SP),SP
                tst.w   D0
                bne.s   maddalt_error

                lea     ok_txt(PC),A0
                bsr     print

                SUPEXEC cookie2

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

maddalt_error:  lea     maddalt_txt(PC),A0
                bra.s   is_inst2
no_magnum:      lea     no_magnum_txt(PC),A0
                bra.s   is_inst2
machine_err:    lea     machine_txt(PC),A0
                bra.s   is_inst2
is_inst:        lea     is_inst_txt(PC),A0
is_inst2:       bsr.s   print
                move.w  #8,-(sp)        ;Cnecin()
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
cookie1a:	clr.l	machine
		move.l	#"_MCH",d0
		bsr	hunt_cookie
		bmi.s	cookie1b
		move.l	d0,machine
cookie1b:	rts                

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

; Testen, ob MAGNUM-UMB im Rechner vorhanden ist
test_magnum:    move.l  berr_vec,a5
                move.l  sp,a6
                move.w  sr,d7
                or.w    #$0700,sr
;                movec   cacr,d6
;                move.l  d6,d0
;                bclr    #8,d0            ; disable data cache
;                bset    #11,d0           ; clear data cache
;                movec   d0,cacr

                move.l  #BLK1_START+16,a0    ; Adresse Test 1
                move.l  #BLK2_START,a1    ; Adresse Test 2
		move.l	#test_m_berr,berr_vec
		
		move.l  #$23456780,(a0)
                move.l  #$12345678,(a1)
                cmp.l   #$23456780,(a0)
                bne     test_m_berr       ; kein Speicher
                cmp.l   #$12345678,(a1)   
                bne     test_m_berr

		move.l	#BLK1_START,a0
		lea	save_magic(pc),a1
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+

test_m_end:     move.l  a5,berr_vec
;                movec   d6,cacr
                move.l  a6,sp
                move.w  d7,sr
                rts
test_m_berr:    bset    #0,sup_ret
                bra.s   test_m_end
 
memtest:        PRINTSTR testtxt
                PRINTSTR reverse_on
                moveq   #7,d7		; 1 MB = 8 Blîcke * 128 K
memtest2:       PUTC    #' '
                dbra    d7,memtest2
                PUTC    #13
                clr.l   mem_err_addr

                move.l  #BLK1_START,a0
                move.l	#BLK1_START+BLK1_LEN,a2
;                move.l  a0,a2
;                add.l   alt_ram_len,a2
do_test2:       move.l  a0,a1
                add.l   #128*1024,a1

                btst    #3,patch_space+1
                bne     do_test4
                btst    #0,patch_space+1
                beq     do_test3
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
                bne     memtest3

                moveq   #-1,d1
                bsr     mt_refresh1
                tst.l   mem_err_addr
                bne	memtest3

                moveq   #-1,d1
                bsr     mt_refresh2
                tst.l   mem_err_addr
                bne.s   memtest3

do_test3:       movem.l d1-d2/a0-a2,-(sp)
                move.l  #$00010002,-(sp)
                trap    #13
                addq.l  #4,sp
                movem.l (sp)+,d1-d2/a0-a2
                cmp.w   #-1,d0
                bne.s   do_test5
                bset    #3,patch_space+1

do_test5:       moveq   #0,d1
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

		cmp.l	#BLK2_LEN+BLK2_START,a2
		beq.s	do_test4a
                move.l  #BLK2_START,a0
                move.l	#BLK2_LEN+BLK2_START,a2
		bra	do_test2	; test 2nd block

do_test4a:	PRINTSTR reverse_off
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
                
sup_ret:        dc.l    0
new_cookie_num: dc.l    0
res_len:        dc.l    0
mem_err_addr:   dc.l    0
save_magic:	ds.l	4

testtxt:       dc.b " UMBs gefunden, teste 1024KB:",13,10,0
testtxt3:       dc.b 27,'q',13,10
                dc.b " Fehler bei Adresse $",0
testtxt4:       dc.b " - Test abgebrochen!",13,10,0
reverse_on:     dc.b 27,'p',0
reverse_off:    dc.b 27,'q ',0
ok_txt:         dc.b "OK",13,10,0
;                     0123456789012345678901234567890123456789
maddalt_txt:    DC.B 13,10," Fehler bei Maddalt() - kann UMBs",13,10
                DC.B " nicht anmelden!",13,10,0
is_inst_txt:    DC.B " Fehler: HIMEM ist bereits installiert!",13,10,0
no_magnum_txt:  DC.B " Fehler: keine MAGNUM-Karte oder keine UMBs gefunden!",13,10,0
machine_txt:	DC.B "Dieser Treiber lÑuft nur auf ST oder STE!",13,10,0
init_text:      DC.B 27,'f',13,10,27,"p "
                DC.B "HIMEM: MAGNUM-ST(E) UMB Installation V1.1 ",27,"q",13,10
                DC.B " Ω 1997-98 Michael Schwingen",13,10,0

                EVEN
	INCLUDE "cookie.s"
		BSS
machine:	ds.l	1
		ds.l	100
new_stack:	ds.l	1
                END
