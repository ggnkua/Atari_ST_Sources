; MAGNUM FASTRAM-Installation
;
; $Id: magnumst.s,v 1.4 1998/05/14 11:44:36 rincewind Exp $
; 
; $Log: magnumst.s,v $
# Revision 1.4  1998/05/14  11:44:36  rincewind
# shrink memory at start
#
# Revision 1.3  1998/05/14  11:20:20  rincewind
# new memory size detection, switch to 16MHz on STE
#
; Revision 1.2  1997/03/14  00:14:36  rincewind
; working version
;

                IMPORT sleep
resvalid	EQU $426        ;Reset-Vektor Magic
resvector	EQU $42A        ;der Reset-Vektor
_p_cookies	EQU $5A0        ;Zeiger auf das Cookie Jar
memctrl		EQU $424	;Shadow von $ffff8001
phystop		EQU $42E
_resvector	EQU $42a
_resvalid	EQU $426
_shell_p	EQU $4f6
berr_vec	EQU $8          ;Buserror-Vektor
COOKIE		EQU "MAG2"
MAGIC1		EQU "MAGN"
MAGIC2		EQU "WARM"
VME_BASE	EQU $A00000	; VME-Startadresse im STE

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

		dc.b 	"XBRA"
		dc.l	COOKIE
old_reset:	dc.l	0
new_reset:	move.l	#$12345678,_resvalid
		move.l	old_reset,_resvector
		move.l	#reset_stack,sp
		clr.l	_shell_p
		clr.l	_p_cookies
		
		move.l	#new_reset2,berr_vec.w
		nop
		move.l	#$400000,a0

		move.l	#$12345678,$e80000
		move.l	#$87654321,$e80004
		cmp.l	#$12345678,$e80000
		bne.s	new_reset2
		cmp.l	#$87654321,$e80004
		bne.s	new_reset2
		move.l	#$e80000,a0
new_reset2:	move.l  #new_reset2a,berr_vec.w
		nop
	        move.w  $6c4710,d0
new_reset2a:	move.l	#new_reset2b,berr_vec.w
		nop
		move.w  $5d1234,d0
new_reset2b:	move.l	#new_reset2c,berr_vec.w
		nop
		move.w	$6d3148,d0
new_reset2c:	move.l	#new_reset2d,berr_vec.w		
		move.w	$5c0814,d0
new_reset2d:	move.l	#new_reset2e,berr_vec.w	
		nop
		move.w	$6c8810,d0
new_reset2e:	move.l	#new_reset3,berr_vec.w
		nop
		move.l	#MAGIC1,(a0)+
		move.l	#MAGIC2,(a0)
new_reset3:	jmp	(a6)

		ds.l	25
reset_stack:	ds.l 	1
machine:	ds.l	1		; Rechnertyp: MSTE=$00010010
cookie_space:   DS.B    8*1000          ; Platz fÅr max. 1000 Cookies

                dc.b "MAGPATC2"
patch_space:    dc.w    $11             ; Konfiguration:
                                        ; Bit 0: ausfÅhrlicher Ramtest
                                        ; Bit 1: Blitter auf 8MHz
                                        ; Bit 2: Speicher auf 6MB begrenzen
                                        ; Bit 3: kein Ramtest
                                        ; Bit 4: CPU im MSTE auf 16MHz
                dc.w     $19            ; Bitmaske der mîgl. Optionen

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

		PRINTSTR init_text

                SUPEXEC cookie1
                tst.l   sup_ret
                bne     is_inst

		move.w	machine,d0
		beq.s	start2a		; ST oder kein Cookie
		sub.w	#1,d0
		bne	machine_err	; auch kein STE

		btst	#4,patch_space+1
		beq.s	start2a
		SUPEXEC ste_fast
		PRINTSTR ste_fast_txt
		
start2a:	SUPEXEC test_magnum
                btst    #1,sup_ret
                bne     is_mem_err
                btst    #0,sup_ret
                bne     no_magnum

		tst.l	alt_ram_len
		beq.s	no_mem

start4:         bsr     memtest
                tst.l   mem_err_addr
                bne     is_inst3

; bei STE: Blitter abschalten
		cmp.w	#1,machine
		bne.s	start3
		clr.w	-(sp)
		move.w	#$40,-(sp)	; Blitmode(0)
		trap	#14
		addq.l	#4,sp

start3:
                move.l  alt_ram_len(pc),-(SP)
                move.l  alt_ram_start(pc),-(SP)
                move.w  #$14,-(SP)      ; Maddalt(start,len)
                trap    #1
                lea     10(SP),SP
                tst.w   D0
                bne.s   maddalt_error

                lea     ok_txt(PC),A0
                bsr     print

                SUPEXEC cookie2
                SUPEXEC ins_reset

; resident bleiben
                move.l  res_len,D7
                add.l   #$108+cookie_space-start,D7
                clr.w   -(SP)
                move.l  D7,-(SP)
                move.w  #$31,-(SP)
                trap    #1              ;Ptermres()
                illegal


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
machine_err:    lea     machine_txt(PC),A0
                bra.s   is_inst2
is_inst:        lea     is_inst_txt(PC),A0
is_inst2:       bsr.s   print
is_inst3:       move.w  #8,-(sp)        ;Cnecin()
                trap    #1
                addq.l  #2,sp
		clr.w   -(sp)
                trap    #1              ;Pterm0()
                illegal

print:          move.l  a0,a6
print2:         move.b  (a6)+,d0
                beq.s   putc2
                bsr.s   putc
                bra.s   print2

print_dez:	move.b	d0,d7
                cmp.b   #10,d0
                blt.s	print_dez2
                moveq	#'1',d0
                bsr	putc
                move.b	d7,d0
                sub.b   #10,d0
print_dez2:	add.w   #'0',d0
;                bra     putc

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
                bmi.s   cookie1a        ;nicht gefunden
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
                move.l  #new_reset,D1   ;Cookie-Wert
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

; Testen, ob MAGNUM-ST-Karte im Rechner ist
test_magnum:    move.l  berr_vec.w,a5
                move.l  sp,a6
                move.w  sr,d7
                or.w    #$0700,sr
;                movec   cacr,d6
;                move.l  d6,d0
;                bclr    #8,d0            ; disable data cache
;                bset    #11,d0           ; clear data cache
;                movec   d0,cacr

; Test, ob Karte bereits von der Reset-Routine eingeblendet wurde
; -> Warmstart
		move.l	#warm_1,berr_vec.w
		nop
		cmp.l	#MAGIC1,$e80000
		bne.s	warm_1
		cmp.l	#MAGIC2,$e80004
		bne.s	warm_1
		clr.l	$e80000
		move.l	$e80008,alt_ram_start
		move.l	$e8000c,alt_ram_end
		bra.s	warm_2
warm_1:		move.l	#vmetest_1,berr_vec.w
		nop
		lea	$400000,a0
		cmp.l	#MAGIC1,(a0)
		bne.s	vmetest_1
		cmp.l	#MAGIC2,4(a0)
		bne.s	vmetest_1
		clr.l	(a0)
		move.l	$400008,alt_ram_start
		move.l	$40000c,alt_ram_end
warm_2:		bset	#3,patch_space+1	; kein Ramtest
		bsr	enable_card
		bra	test_m_end

; Kaltstart: Auf STE testen, ob Speicher ab $A00000 (VME) vorhanden ist
vmetest_1:	move.l	#$E00000,alt_ram_end
		move.l	#$400000,alt_ram_start
		move.l	#vmetest_2,berr_vec.w
		nop
		lea	VME_BASE,a0
		move.l	(a0),d0
		move.l	a0,alt_ram_end
vmetest_2:

; Test, ob *kein* Speicher ab 4MB liegt
		move.l  #test_m1,berr_vec.w
		nop
                move.l  $400010,d0
; Speicher ist da -> Fehler!
		bset	#1,sup_ret
		bra	test_m_end2
; Jetzt Magnum einblenden                
test_m1:	bsr	enable_card
		
; die Karte ist jetzt eingeblendet -> Testen, wieviel Speicher da ist
; Testen, ob 1MB-4MB eingeblendet wurden
		move.l	phystop,d0
		cmp.l	#$100000,d0
		bgt	test_m6
		
                move.l  #$180000,a0		; Adresse Test 1
                move.l  #$300000,a1		; Adresse Test 2
		move.l	#test_m6,berr_vec.w
		nop
		move.l  #$23456780,(a0)
                move.l  #$12345678,(a1)
                cmp.l   #$23456780,(a0)
                bne.s   test_m6			; kein RAM
                cmp.l   #$12345678,(a1)
                bne.s   test_m6

		move.l  #$100000,alt_ram_start

test_m6:	move.l  #test_m3,berr_vec.w
		nop
                move.l  alt_ram_start(pc),a0	; Startadresse Test
.loop:		move.l	a0,(a0)
		add.l	#$010000,a0		; +1MB
		cmp.l	alt_ram_end(pc),a0
		bne.s	.loop
test_m3:	move.l	a0,alt_ram_end		; Ende bei Buserror
		sub.l	#$010000,a0
.loop:		move.l	a0,(a0)			; Speicher von hinten mit endgÅltigem
		cmp.l	alt_ram_start(pc),a0	; Testmuster fÅllen
		beq.s	test_m4
		sub.l	#$010000,a0
		bra.s	.loop		

test_m4:	move.l	#test_m5,berr_vec.w
		nop
;		move.l	alt_ram_start(pc),a0
.loop:		cmp.l	(a0),a0
		bne.s	test_m5			; ungleich
		add.l	#$010000,a0
		cmp.l	alt_ram_end(pc),a0
		bne.s	.loop

test_m5:	move.l	a0,alt_ram_end

; Altram-Start und Endadresse fÅr Warmstart merken
test_m_end:     move.l	#test_m_end2,berr_vec.w
		nop
		move.l	alt_ram_start,$400008	; das sollte immer gutgehen
		move.l	alt_ram_end,  $40000C
		move.l	alt_ram_start,$e80008	; das geht nur mit UMBs
		move.l	alt_ram_end,  $e8000C
test_m_end2:	move.l  a5,berr_vec.w
;                movec   d6,cacr
                move.l  a6,sp
                move.w  d7,sr
                move.l	alt_ram_end(pc),d0
                sub.l	alt_ram_start(pc),d0
                move.l	d0,alt_ram_len
                rts

; Karte einschalten
enable_card:	move.l	sp,a0
		move.l  #enable_card_a,berr_vec.w
		nop
	        move.w  $6c4710,d0
enable_card_a:	move.l	#enable_card_b,berr_vec.w
		nop
		move.w  $5d1234,d0
enable_card_b:	move.l	#enable_card_c,berr_vec.w
		nop
		move.w	$6d3148,d0
enable_card_c:	move.l	#enable_card_d,berr_vec.w		
		nop
		move.w	$5c0814,d0
enable_card_d:	move.l	#enable_card_e,berr_vec.w	
		nop
		move.w	$6c8810,d0
enable_card_e:	move.l	a0,sp
		rts

ste_fast:	move.b	#$02,$ffff8e21.w
		move.b	#$03,$ffff8e21.w
		rts

testtxt0:       dc.b "MB gefunden",0
testtxt1:       dc.b ", teste: ",13,10,0
testtxt2:	dc.b ", kein Test (Warmstart).",13,10,0
testtxt3:       dc.b 27,'q',13,10
                dc.b " Fehler bei Adresse $",0
testtxt4:       dc.b " - Test abgebrochen!",13,10,0

memtest:	move.w  alt_ram_len(pc),d0
                lsr.l   #4,d0
                bsr	print_dez
		PRINTSTR testtxt0
		
; Ramtest abgeschaltet (Warmstart)?
                btst    #3,patch_space+1
                beq     memtest5
                PRINTSTR testtxt2
                rts

memtest5:	PRINTSTR testtxt1
		PRINTSTR reverse_on
                move.w  alt_ram_len(pc),d7
                lsr.w   #2,d7             ; 8 MB = 32* 256K-Blîcke
                subq.w  #1,d7
memtest2:       PUTC    #' '
                dbra    d7,memtest2
                PUTC    #13
                clr.l   mem_err_addr

                move.l  alt_ram_start(pc),a0
                move.l  a0,a2
                add.l   alt_ram_len(pc),a2

; Adreûtest: gesamten Speicher mit Adresspattern fÅllen
		move.l	a0,a1

do_test1:	REPT 8
		move.l	a1,(a1)+
		ENDM
		cmp.l	a1,a2
		bne.s	do_test1

do_test2:       move.l  a0,a1
                add.l   #256*1024,a1

                bsr     mt_addr
                tst.l   mem_err_addr
                bne     memtest3

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
                bne.s   memtest3

                moveq   #-1,d1
                bsr     mt_refresh1
                tst.l   mem_err_addr
                bne.s   memtest3

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

                PRINTSTR reverse_off
                rts
memtest3:       PRINTSTR testtxt3
                move.l  mem_err_addr,d0
                bsr     print_hex
                PRINTSTR testtxt4
                rts

mt_addr:        move.l  a0,a3
mt_addr2:       REPT    4
		move.l	a3,d1
                cmp.l   (a3)+,d1
                bne.s   mt_addr4
                ENDM
                cmp.l   a3,a1
                bne.s   mt_addr2
                rts
mt_addr4:       subq.l  #4,a3
                move.l  a3,mem_err_addr
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
; 2 = 8MB
; 3 = 16MB
mem_config:     dc.w    0
sup_ret:        dc.l    0
new_cookie_num: dc.l    0
res_len:        dc.l    0
mem_err_addr:   dc.l    0

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
                DC.B "MAGNUM-ST(E)"
                DC.B " Alternate-RAM Installation V1.17 ",27,"q",13,10
                DC.B " Ω 1995-98 Michael Schwingen",13,10,0
machine_txt:	DC.B "Dieser Treiber lÑuft nur auf ST oder STE!",13,10,0
ste_fast_txt:	DC.B "CPU auf 16MHz geschaltet.",13,10,0
                EVEN

ins_reset:	move.l  resvector.w,old_reset
		move.l  resvalid.w,new_reset+2
		move.l  #new_reset,resvector.w
		move.l  #$31415926,resvalid.w
		rts
    
	INCLUDE "cookie.s"

		BSS
alt_ram_start:	ds.l	1
alt_ram_end:	ds.l	1
alt_ram_len:    ds.l    1       ; LÑnge Fastram
		ds.l	100
new_stack:	ds.l	1
                END
