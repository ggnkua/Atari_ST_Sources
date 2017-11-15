********************************
*                              *
* OUTSIDE V3.51                *
*                              *
* Virtuelle Speicherverwaltung *
*                              *
* fÅr Ataris mit 68030         *
*                              *
* (C) 1991-2000 Uwe Seimet     *
*                              *
********************************


*DEBUG=1


	mc68030
	loadfast
	ttram
	ttmem


	include "SYSTEM.ASM"

*Descriptor-Attribute
INVALID	= 2
USED	= 3
MODIFIED	= 4

LOCKED	= 0	;Page von Benutzer gelockt
RLOCKED	= 1	;residentes Programm von OUTSIDE gelockt
NLOCKED	= 2	;nicht residentes	Programm	von OUTSIDE gelockt
MLOCKED	= 3	;Bereich von MagiC gelockt


magic	= "SWAP"	;fÅr XBRA
version	= "3.51"	;Versionsnummer
ttmagic	= $1357bd13	;Magic fÅr TT-RAM

xfrbver	= $0101


	locoff


	text


begin:
	bra.s start

	dc.l magic
	dc.l version
us1:	dc.b 0	;MagiC nicht schreibschÅtzen
	dcb.b 3,0

	dc.l pars-begin
	dc.l 0	;reserviert

pars:
_drive:	dc.w 0	;Swap-Laufwerk
_size:	dc.w 512	;Speichergrîûe
_method:	dc.w 0	;TT-RAM-Flag
_lock:	dc.w 0	;Flag fÅr MEDIA REMOVAL

_page:	dc.w 16384	;Seitengrîûe

_mem:	dc.l 1048576*2	;ST-RAM-Bereich
_fastrom:dc.w 0	;Flag fÅr ROM ins RAM kopieren
_base:	dc.w 0	;Flag fÅr KompatibilitÑtsmodus
_xfrb:	dc.w 0	;Flag fÅr XFRB


key:	dc.w 0	;Zugriffscode fÅr	XHDI
	dc.l 0	;reserviert
	dc.l pars
cookie:
	dc.l version
ttsize:	dc.l 0	;Grîûe des physikalischen TT-RAM
ramsize:	dc.l 0	;Grîûe des virtuellen Speichers
	dc.l 0	;reserviert
pageadr:	dc.l 0	;Start der Seiten-Deskriptoren
drive:	dc.w 0	;Swap-Laufwerk


start:
	move.l 4(sp),a0
	lea stack+400,sp
	move.l 12(a0),a1	;LÑnge des TEXT-Segments
	add.l 20(a0),a1	;LÑnge des DATA-Segments
	add.l 28(a0),a1	;LÑnge des BSS-Segments
	lea $100(a1),a1	;fÅr Basepage
	move.l a1,prglen
	pea (a1)
	pea (a0)
	clr -(sp)
	move #MSHRINK,-(sp)
	trap #GEMDOS	;ÅberzÑhligen Speicher freigeben
	lea 12(sp),sp

	pea get_cookies(pc)
	move #SUPEXEC,-(sp)
	trap #XBIOS	;cookie jar auswerten
	addq.l #6,sp

	lea cpuerr,a3
	tst.b cpuflg
	beq error	;nicht 68030-

	lea mmuerr,a3
	tst.b mmuflg
	bne error	;MMU bereits aktiv-

	move _drive(pc),drive
	move _page(pc),page+2
	move _page(pc),d0
	move d0,d1
	add d1,d1
	or d1,d0
	add d1,d1
	or d1,d0
	move d0,mask

	clr -(sp)
	pea 25600	;Puffer fÅr Floppyzugriff
	move #MXALLOC,-(sp)
	trap #GEMDOS
	addq.l #8,sp
	lea gemerr,a3
	cmp.l #EINVFN,d0
	beq error	;falsche GEMDOS-Version
	lea ramerr,a3
	move.l d0,flopbuf
	beq error

	move #-1,-(sp)
	move #KBSHIFT,-(sp)
	trap #BIOS
	addq.l #4,sp
	subq.b #3,d0	;Shift links und rechts?
	bne.s .noshift

	lea ign(pc),a0
	move country(pc),d0
	move.l (a0,d0*4),-(sp)
	move #CCONWS,-(sp)
	trap #GEMDOS	;Installation abbrechen?
	addq.l #6,sp

	move #CRAWCIN,-(sp)
	trap #GEMDOS
	addq.l #2,sp
	cmp.b #'j',d0
	beq.s .abort	;Installation abbrechen-
	cmp.b #'y',d0
	beq.s .abort
	cmp.b #'o',d0
	bne.s .noshift

.abort:	move.l d4,-(sp)
	move #SUPER,-(sp)	;zurÅck in
	trap #GEMDOS	;User-Modus
	addq.l #6,sp
	bra noins

.noshift:lea intin,a5
	lea intout,a6
	moveq #APPL_INIT,d0
	move.l #$00010000,d1
	bsr _aes
	tst (a6)
	bmi .noaes
	tst global
	beq .noaes

	moveq #100,d0	;v_opnvwk
	move.l a5,a0
	moveq #9,d1
.opn:	move #1,(a0)+
	dbra d1,.opn
	move #2,(a0)
	lea contrl+2,a3
	clr.l (a3)+
	move #11,(a3)
	move (a6),6(a3)	;graf_handle
	bsr _vdi
	move 6(a3),d5	;VDI-Handle

	move (a6),d7	;horizontale Auflîsung -1
	addq #1,d7
	moveq #0,d0
	move 2(a6),d0	;vertikale Auflîsung -1
	addq #1,d0
	mulu d0,d7

	lea contrl+2,a3
	move.l #$00000006,(a3)+
	move.l #$0001002d,(a3)
	move #1,intin	;erweiterte Parameter
	moveq #102,d0	;vq_extnd
	bsr _vdi
	moveq #0,d6
	move 8(a6),d6	;Zahl der Farbebenen
	mulu.l d6,d7
	lsr.l #3,d7	;Bytes fÅr Bildschirmspeicher

	moveq #101,d0	;v_clsvwk
	lea contrl+2,a3
	clr.l (a3)+
	clr.l (a3)
	bsr _vdi

	moveq #APPL_EXIT,d0
	move.l #$00010000,d1
	bsr _aes

	lea ramerr,a3
	clr -(sp)
	move.l d7,-(sp)
	move #MXALLOC,-(sp)
	trap #GEMDOS
	addq.l #8,sp
	move.l d0,srcbuf
	beq error

	move _xfrb(pc),d0
	beq.s .noxfrb	;keinen XFRB anlegen-
	clr -(sp)
	pea 65536
	move #MXALLOC,-(sp)
	trap #GEMDOS
	addq.l #8,sp
	move.l d0,xfrbpnt
	beq error

.noxfrb:	tst.b falcflg
	beq.s .noaes	;kein Falcon-
	moveq #1,d7
	asl d6,d7
	cmp #257,d7
	bcc.s .noaes	;True Color-

	pea buffer
	move d7,-(sp)	;Zahl der Farben
	clr -(sp)	;Index
	move #VGETRGB,-(sp)
	trap #XBIOS
	lea 10(sp),sp
	clr -(sp)
	move #BLITMODE,-(sp)
	trap #XBIOS	;Blitter abschalten
	addq.l #4,sp
	move d0,-(sp)
	pea buffer
	move d7,-(sp)
	clr -(sp)	;Index
	move #VSETRGB,-(sp)
	trap #XBIOS
	lea 10(sp),sp
	move (sp)+,d0
	bra.s .aes

.noaes:	clr -(sp)
	move #BLITMODE,-(sp)
	trap #XBIOS	;Blitter abschalten
	addq.l #4,sp
.aes:	btst #0,d0
	sne blitflg

	move #KBDVBASE,-(sp)
	trap #XBIOS
	addq.l #2,sp
	move.l d0,kbdvbase

	clr.l -(sp)
	move #SUPER,-(sp)	;in Supervisor-
	trap #GEMDOS	;Modus gehen
	addq.l #6,sp
	move.l d0,d4

	ifd DEBUG
	move.l #begin,d0
	lea _init1,a0
	bsr auxout
	move.l prglen,d0
	lea _init2,a0
	bsr auxout
	endif

	move.l phystop,d0
	sub.l #$100000,d0
	cmp.l _mem(pc),d0
	bcc.s .topok
	move.l d0,_mem	;1 MByte freilassen

.topok:	moveq #0,d7
	cmp.l #ttmagic,_ramvalid
	bne.s .novalid
	move.l _ramtop,d7	;Ende des TT-RAM
	sub.l #$01000000,d7
	bcc *+2
	moveq #0,d7

.novalid:move #1,-(sp)	;TT-RAM
	pea -1
	move #MXALLOC,-(sp)
	trap #GEMDOS
	addq.l #8,sp
	cmp.l d0,d7	;TT-RAM leer?
	seq empty
	bne .nocomp0	;nein-

	move _base(pc),d1	;KompatibilitÑtsmodus?
	beq.s .nocomp	;nein-

	move #1,-(sp)
	move.l d7,-(sp)
	move #MXALLOC,-(sp)
	trap #GEMDOS	;TT-RAM sperren
	addq.l #8,sp

	move.l _mem(pc),ttsize

	move.l phystop,d1	;neue Adresse direkt
	move.l d1,base	;hinter ST-RAM
	move.l ([_sysbase],8),d0
	sub.l d1,d0	;Bereichsgrîûe oberhalb des ST-RAM
	moveq #0,d1
	move _size(pc),d1
	mulu.l #$100000,d1	;Speichergrîûe in Bytes
	cmp.l d0,d1
	bcs.s .ttram
	divu.l #$100000,d0
	move d0,_size	;neue Grîûe des virtuellen Speichers
	bra.s .ttram

.nocomp0:lea comperr,a3
	move _base(pc),d1	;KompatibilitÑtsmodus gewÅnscht?
	bne error	;ja-

.nocomp:	clr _base	;keine ST-KompatibilitÑt mîglich
	move.l d7,ttsize
	bne.s .sizeok	;TT-RAM vorhanden-
	move.l _mem(pc),ttsize
	bra.s .ttram
.sizeok:	clr.l _mem

.ttram:	bsr init_drv	;Swap-Laufwerk initialisieren
	bne error
	bsr init_sec	;KapazitÑt testen
	bne error

	move.l ramsize(pc),d0
	divu.l page,d0	;Zahl der virtuellen Pages
	asl.l #2,d0
	move.l d0,lsectab
	move.l d0,d7
	move.l d0,-(sp)	;fÅr Sektortabelle
	move #MALLOC,-(sp)
	trap #GEMDOS
	addq.l #6,sp
	move.l d0,sectab
	beq error
	add.l d7,d0
	move.l d0,tabend	;Tabellenende

	move _base(pc),d0
	bne.s .stbase	;ST-kompatibel erweitern-

	move.l mbsize,d1
	move.l d1,d0
	mulu.l #$100000,d0
	divu.l page,d0
	asl.l #2,d0	;fÅr Seiten-Deskriptoren
	add.l #15,d1
	and #$fff0,d1	;16 MByte-Blîcke
	asl.l #2,d1	;fÅr Tabellen-Deskriptoren
	add.l d1,d0
	add.l #15,d0
	move.l d0,ldestable
	move.l d0,-(sp)
	move #MALLOC,-(sp)
	trap #GEMDOS
	addq.l #6,sp
	tst.l d0
	beq error
	add.l #15,d0
	and #$fff0,d0
	move.l d0,destable	;Start der Deskriptoren fÅr TT-RAM

.stbase:	move _fastrom(pc),d0
	beq.s .nofast
	move.l ([_sysbase],8),a0
	cmp.l #$00e00000,a0
	bne.s .nofast	;kein ROM-
	move.l a0,a1
	add.l #524288-8,a0	;PrÅfsummen Åberspringen
	move.l -4(a0),d0
.getlen:	cmp.l -(a0),d0  	;Leerbytes
	beq .getlen              	;Åberspringen
	addq.l #4,a0
	sub.l a1,a0
	move.l a0,romlen	;Romgrîûe in Bytes
	add.l page,a0
	pea -1(a0)
	move #MALLOC,-(sp)
	trap #GEMDOS
	addq.l #6,sp
	move.l romlen,a0
	tst.l d0
	beq.s .nofast
	add.l page,d0
	subq.l #1,d0
	and mask,d0
	move.l d0,rombuf
	exg.l d0,a0
	lsr.l #2,d0
	move.l ([_sysbase],8),a1
.copyrom:move.l (a1)+,(a0)+
	subq.l #1,d0
	bne .copyrom

.nofast:	move.l _mem(pc),d0
	beq.s .nost

	move.l phystop,d7	;Grîûe des ST-RAM in Bytes
	move _base(pc),d0
	beq.s .nobase
	move.l #14*$100000,d7
.nobase:	divu.l page,d7	;Zahl der Deskriptoren fÅr ST-RAM
	move.l d7,d0
	asl.l #2,d0
	add.l #15,d0
	move.l d0,lsttab
	move.l d0,-(sp)
	move #MALLOC,-(sp)
	trap #GEMDOS
	addq.l #6,sp
	lea ramerr,a3
	tst.l d0
	beq error
	add.l #15,d0
	and #$fff0,d0
	move.l d0,sttab

	move.l d0,a1
.clrst:	clr.l (a1)+	;ST-RAM Deskriptoren zunÑchst lîschen
	subq.l #1,d7
	bne .clrst

	move.l phystop,d7
	divu.l page,d7
	move.l d0,a1	;Adresse	der neuen Deskriptoren
	lea $00000001,a0
.initst:	move.l a0,(a1)+	;Seiten-Deskriptoren aufbauen
	add.l page,a0
	subq.l #1,d7
	bne .initst
	move.l a1,pageadr	;fÅr virtuelles ST-RAM falls KompatibilitÑt

.nost:	move.l ttsize(pc),d0	;Grîûe des physikalischen RAM
	divu.l page,d0
	mulu.l #12,d0	;Grîûe des Ringpuffers (je 12 Byte)
	move.l d0,ldtable
	move.l d0,-(sp)
	move #MALLOC,-(sp)
	trap #GEMDOS
	addq.l #6,sp
	lea ramerr,a3
	move.l d0,dtable
	beq error
	move.l ttsize(pc),d0
	divu.l page,d0
	mulu.l #3,d0
	add.l dtable,d0	;3/4 Speicher freilassen
	move.l d0,nxtadr

	bsr st_to_tt	;TT-RAM bereitstellen
	bne error
	bsr build_tab	;Deskriptortabelle aufbauen
	bsr init_sec	;Sektortabelle aufbauen

	bsr make_buf	;Ringpuffer aufbauen
	bsr lock_drv	;Wechselplatte verriegeln
	bsr init_mmu	;PMMU neu konfigurieren
	bsr lock_data	;Datenbereiche locken

	ifd DEBUG
	move.l destable,d0
	lea _desadr,a0
	bsr auxout
	move.l sttab,d0
	lea _stadr,a0
	bsr auxout
	move.l pageadr,d0
	lea _pageadr,a0
	bsr auxout
	move.l crpr+4,d0
	lea _crp,a0
	bsr auxout
	endif

	move.l d4,-(sp)
	move #SUPER,-(sp)	;zurÅck in
	trap #GEMDOS	;User-Modus
	addq.l #6,sp

	pea buffer	;fÅr DTA
	move #FSETDTA,-(sp)
	trap #GEMDOS
	addq.l #6,sp

	move #7,-(sp)
	pea infname
	move #FSFIRST,-(sp)
	trap #GEMDOS
	addq.l #8,sp
	tst.l d0
	bne.s .noinf

	move.l buffer+26,-(sp)	;DateilÑnge
	addq.l #1,(sp)
	move #MALLOC,-(sp)
	trap #GEMDOS
	addq.l #6,sp
	move.l d0,infbuf
	beq.s .noinf

	clr -(sp)
	pea infname
	move #FOPEN,-(sp)
	trap #GEMDOS
	addq.l #8,sp
	move.l d0,d7
	bmi.s .noinf

	move.l infbuf,-(sp)
	move.l buffer+26,-(sp)
	move d7,-(sp)
	move #FREAD,-(sp)
	trap #GEMDOS
	lea 12(sp),sp

	move d7,-(sp)
	move #FCLOSE,-(sp)
	trap #GEMDOS
	addq.l #4,sp

	move.l infbuf,a0
	add.l buffer+26,a0
	clr.b (a0)	;Listenende markieren

.noinf:	move.l base,a1
	move.l ramsize(pc),a0
	move.l _mem(pc),d0
	bne.s .nott
	move _base(pc),d0
	bne.s .nott	;KompatibilitÑtsmodus
	move.l ttsize(pc),d0
	add.l d0,a1
	sub.l d0,a0
.nott:	pea (a0)	;Speichergrîûe
	pea (a1)	;neue Speicheradresse
	move #MADDALT,-(sp)	;Speicher bereitstellen
	trap #GEMDOS
	lea 10(sp),sp
	move.l mbsize,d0	;Grîûe des Speichers in MByte
	tst _base
	beq.s .noc	;kein KompatibilitÑtsmodus
	move.l _mem(pc),d0
	divu.l #$100000,d0
	add.l mbsize,d0
.noc:	lea virram1,a0
	bsr int
	move.l mbsize,d0
	lea virram2,a0
	bsr int
	move.l mbsize,d0
	lea virram3,a0
	bsr int
	move drive,d0
	add.b #'A',d0
	move.b d0,virdrv1
	move.b d0,virdrv2
	move.b d0,virdrv3

	pea add_cookies(pc)
	move #SUPEXEC,-(sp)
	trap #XBIOS
	addq.l #6,sp

	lea message,a0
	move country,d0
	move.l (a0,d0*4),-(sp)
	move #CCONWS,-(sp)
	trap #GEMDOS	;OUTSIDE ist installiert
	addq.l #6,sp
	clr -(sp)
	move.l prglen,-(sp)
	move #PTERMRES,-(sp)	;Programm
	trap #GEMDOS	;resident halten

error:
	move.l d4,-(sp)
	move #SUPER,-(sp)	;zurÅck in
	trap #GEMDOS	;User-Modus
	addq.l #6,sp
	move country,d0
	move.l (a3,d0*4),-(sp)
	move #CCONWS,-(sp)
	trap #GEMDOS	;Fehlermeldung ausgeben
	addq.l #6,sp
noins:	lea inserr,a0
	move country,d0
	move.l (a0,d0*4),-(sp)
	move #CCONWS,-(sp)
	trap #GEMDOS	;nicht installiert
	addq.l #6,sp
	clr -(sp)
	trap #GEMDOS


*Deskriptortabellen aufbauen
build_tab:
	pmove tc,tcr
	pmove crp,crpr
	move.l #newtab+15,d0
	and #$fff0,d0
	move.l d0,newadr	;Start der Basis-Deskriptoren
	move.l d0,a1

*Alte Deskriptoren kopieren

	move.l crpr+4,a0	;Deskriptor-Basis
	moveq #63,d0	;64 Deskriptoren
.copy:	move.l (a0)+,d1
	btst #1,d1	;Tabellen-Deskriptor?
	beq.s .notdes	;nein-
	sub.l crpr+4,d1
	add.l newadr,d1
.notdes:	move.l d1,(a1)+
	dbra d0,.copy

*Tabellen Deskriptoren fÅr TT-RAM initialisieren

	move _base(pc),d0
	bne .lowmem

	move.l base,a0
	ptestr #7,(a0),#7,a0
	sub.l crpr+4,a0
	add.l newadr,a0

	move.l mbsize,d0	;Blîcke zu 1 MByte
	add.l #15,d0
	lsr.l #4,d0	;Blîcke zu 16 MByte
	cmp #16,d0
	bcs.s .no256	;nicht mehr als 240 MByte-

	sub #16,d0
	move.l newadr,a1
	lea 256(a1),a1
	move.l destable,d1
	add.l #15*64+2,d1
.init6:	move.l d1,(a1)+	;Deskriptoren fÅr die zweiten 256 MByte
	add.l #64,d1
	dbra d0,.init6
	move.l newadr,a1
	move.l a1,d1
	add.l #256+2,d1
	move.l d1,4(a1)
	moveq #15,d0

.no256:	subq.l #1,d0
	move.l destable,d1
	or #2,d1
.init0:	move.l d1,(a0)+	;neue Tabellen-Deskriptoren fÅr TT-RAM
	add.l #64,d1	;weitere 16 MByte
	dbra d0,.init0


*Tabellen-Deskriptoren fÅr physikalischen und virtuellen Speicher erzeugen

.nottram:move.l destable,a1	;Start der Deskriptoren fÅr TT-RAM
	move.l base,a0
	addq.l #1,a0	;Kennzeichen fÅr Deskriptor
	move.l mbsize,d0	;Blîcke zu 1 MByte
	add.l #15,d0
	and #$fff0,d0	;in 16 MByte-Vielfachen
	subq.l #1,d0
.init1:	move.l a0,(a1)+	;Tabellen-Deskriptoren
	lea ($00100000,a0),a0	;nÑchstes MByte
	dbra d0,.init1
	move.l a1,pageadr
	move.l a1,d1
	or #$02,d1

*Tabellen-Deskriptoren fÅr virtuellen Speicher erzeugen

	move.l destable,a1
	move.l #$100000,d2
	divu.l page,d2	;Seiten-Deskriptoren pro MByte
	move.l mbsize,d0	;Blîcke zu 1 MByte
	subq.l #1,d0
	asl.l #2,d2
.init2:	move.l d1,(a1)+	;Tabellen-Deskriptoren
	add.l d2,d1	;nÑchstes MByte
	dbra d0,.init2
	bra.s .himem

*Adressraum auf 16 Bit beschrÑnken

.lowmem:	move.l newadr,a0
	move.l (a0)+,d1
	moveq #14,d0
.fix1:	move.l d1,(a0)+
	dbra d0,.fix1

	move.l (a0)+,d1
	moveq #14,d0
.fix2:	move.l d1,(a0)+
	dbra d0,.fix2

	clr.l _ramtop	

*Seiten-Deskriptoren fÅr physikalisch vorhandenen Bereich erzeugen

.himem:	move.l pageadr,a0
	move.l ttsize,d0
	divu.l page,d0	;Zahl der Seiten-Deskriptoren
	subq.l #1,d0
	move.l base,d1
	addq.l #1,d1	;Kennzeichen fÅr Seiten-Deskriptor
	tst.b empty
	bne.s .init3	;TT-RAM leer-
	bset #MODIFIED,d1
.init3:	move.l d1,(a0)+	;Default-Seiten-Deskriptoren
	add.l page,d1
	dbra d0,.init3

*Seiten-Deskriptoren fÅr virtuellen Bereich erzeugen

	move.l ramsize(pc),d0
	sub.l ttsize(pc),d0	;ergibt rein logische Speichergrîûe
	divu.l page,d0
.init4:	clr.l (a0)+	;ungÅltige Deskriptoren lîschen
	subq.l #1,d0
	bne .init4

	move.l _mem(pc),d1
	beq .nost	;kein ST-RAM benutzen-

*Tabellen Deskriptoren fÅr ST-RAM initialisieren

	ptestr #7,$00000000,#7,a0	;bisherige Adresse des ST-RAM
	sub.l crpr+4,a0
	add.l newadr,a0
	move.l sttab,a1	;Adresse	der neuen Deskriptoren
	addq.l #2,a1	;Tabellen-Deskriptoren
	move.l #$100000,d3
	divu.l page,d3	;Seiten-Deskriptoren pro MByte
	asl.l #2,d3
	move.l phystop,d0
	divu.l #$100000,d0
	subq.l #1,d0
	move _base(pc),d2
	beq.s .initst
	moveq #13,d0
.initst:	move.l a1,(a0)+	;Tabellen-Deskriptoren fÅr ST-RAM
	add.l d3,a1
	dbra d0,.initst

*ST-RAM in TT-RAM umwandeln

	divu _page(pc),d1	;benîtigte Speicherseiten +1
	subq #1,d1
	move.l pageadr(pc),a0	;Start der TT-RAM Seiten-Deskriptoren
	move.l stbuf,d0	;Start des ST-RAM-Puffers
	divu.l page,d0
	asl.l #2,d0
	add.l sttab,d0
	move.l d0,a1
.remap:	move.l (a1)+,(a0)+	;RAM ummappen
	bset #2,-1(a1)	;und schreibschÅtzen
	dbra d1,.remap

	move.l ramsize(pc),d1
	sub.l _mem(pc),d1
	divu _page(pc),d1
	subq #1,d1
.map0:	clr.l (a0)+	;rein virtuelle Pages entfernen
	dbra d1,.map0

.nost:	rts

*Ringpuffer aufbauen
make_buf:
	move.l base,a2
	move.l pageadr(pc),a1	;Start der Seiten-Deskriptoren
	move.l dtable,a0
	move.l ttsize(pc),d0
	divu.l page,d0
	subq.l #1,d0	;letzte physikalische Page	aussparen
.cat:	move.l a0,(a0)
	add.l #12,(a0)+	;Verkettung nach vorne
	move.l a1,(a0)+	;Deskriptoradresse
	move.l a2,(a0)+	;logische Adresse
	add.l page,a2
	addq.l #4,a1
	subq.l #1,d0
	bne .cat
	move.l dtable,-12(a0)
	rts


*PMMU neu konfigurieren
init_mmu:
	movec vbr,a0

	move.l a0,oldbus
	addq.l #8,oldbus	;Pointer	auf Busfehler-Vektor
	move.l #vectors+15,d0
	and #$fff0,d0
	move.l d0,a1
	move.l d0,a2
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	move.w #253,d0
.copyv:	move.l #newvec,(a1)+
	dbra d0,.copyv

	move.l #buserr,$08(a2)
	move.l #gemdos,$84(a2)
	move.l #xbios,$b8(a2)
	tst.b blitflg
	beq.s .noblit	;Blitter ist nicht aktiv-
	move.l #vdi,$88(a2)
.noblit:	movec a2,vbr

	move.l tcr,d0
	and.l #%11111100000000001111111111110000,d0
	moveq #12,d1	;Bits fÅr PS
	moveq #8,d3	;Bits fÅr TID
	move.l page,a2
	lea 4096,a3
.getps:	addq #1,d1
	subq #1,d3
	add.l a3,a3
	cmp.l a2,a3
	bne .getps
	swap d1
	asl.l #4,d1
	or.l d1,d0	;TC mit PS-Bits verknÅpfen
	or d3,d0	;TC mit TID-Bits verknÅpfen
	move.l d0,tcr
	move.l newadr,crpr+4
	move.l #$80000002,crpr	;kurze Deskriptoren
	pmove tt0reg,tc
	pmove tt0reg,tt0	;keine transparente öbersetzung
	move _base(pc),d0
	beq.s .nocomp
	pmove tt0reg,tt1	;kein VME-Bus im KompatibilitÑtsmodus
.nocomp:	pmove crpr,crp
	pflusha
	pmove tcr,tc

	move.l rombuf(pc),d0	;ROM nicht ins RAM-
	beq.s .ret
	move.l d0,a1
	or #1,d0
	btst #1,_fastrom+1	;Schreiberlaubnis?
	bne.s .read	;ja-
	or #4,d0
.read:	move.l _sysbase,a0
	ptestr #7,([8,a0]),#7,a0
	move.l d0,(a0)	;ROM-Kopie aktivieren

*neue DMA-Routinen

.ret:	move.l ([_sysbase],8),a1
	move.l hdv_rw,a0
	move.l a0,o_rw
.xhrw:	move.l a0,sys_rw
	cmp.l #"XBRA",-12(a0)
	bne.s .nohrwx
	move.l -4(a0),a0
	cmp.l a1,a0	;zeigt nÑchster Vektor ins System?
	bcs .xhrw	;nein-
.nohrwx:	move.l #hrw,hdv_rw
	move.l hdv_bpb,o_bpb
	move.l #hbpb,hdv_bpb
	move.l #reset,resvector
	move.l #$31415926,resvalid
	rts

*Datenbereiche locken
lock_data:

	ifd DEBUG
	move.l base,d0
	lea _vram,a0
	bsr auxout
	endif

	move.l romlen,-(sp)
	move.l rombuf(pc),-(sp)
	pea 1	;SwapInhibit
	moveq #1,d0
	bsr pmmu	;ROM-Kopie locken
	lea 12(sp),sp

	move.l #stack+400,d0
	sub.l base,d0
	bcs.s .nolock	;nicht in TT-RAM-
	move.l d0,-(sp)
	move.l base,-(sp)
	pea 1
	moveq #1,d0
	bsr pmmu	;belegtes TT-RAM locken
	lea 12(sp),sp	

.nolock:
	tst.b magicflg
	beq.s .nomag
	move.b us1(pc),d0
	bne.s .nomag	;MagiC nicht schreibschÅtzen-

	move.l _sysbase,a0
	move.l 8(a0),a1
	cmp.l base,a1
	bcc.s .ttram
	move.l 20(a0),a2
	cmp.l #$87654321,(a2)+
	beq.s .aes
	lea 12(a0),a2
.aes:	move.l (a2),a2
	bra.s .stram
.ttram:	move.l _____md,a2
.stram:

	ifd DEBUG
	move.l a1,d0
	lea _mbase,a0
	bsr auxout
	move.l a2,d0
	lea _mend,a0
	bsr auxout
	endif

	move.l a2,d0
	sub.l a1,d0
	and mask,d0
	subq.l #1,d0
	move.l d0,-(sp)
	pea (a1)
	pea 3
	moveq #1,d0
	bsr pmmu	;MagiC schreibschÅtzen, nicht auslagern
	lea 12(sp),sp

.nomag:	move.l ldtable,-(sp)
	move.l dtable,-(sp)
	pea 1
	moveq #1,d0
	bsr pmmu	;Ringpuffer locken
	lea 12(sp),sp

	move.l lsectab,-(sp)
	move.l sectab,-(sp)
	pea 1
	moveq #1,d0
	bsr pmmu	;Sektortabelle locken
	lea 12(sp),sp

	move.l lsttab,-(sp)
	move.l sttab,-(sp)
	pea 1
	moveq #1,d0
	bsr pmmu	;ST-RAM Deskriptoren locken
	lea 12(sp),sp

	move.l ldestable,-(sp)
	move.l destable,-(sp)
	pea 1
	moveq #1,d0
	bsr pmmu	;TT-RAM Deskriptoren locken
	lea 12(sp),sp

	rts


	align.l

newvec:
	move.l 4(sp),-(sp)
	and.l #$fff,(sp)	;Vektoroffset isolieren
	move.l ([sp]),(sp)
	rts


	ifd DEBUG
auxout:
	movem.l a0-a6/d0-d7,-(sp)

	move.l d0,d7
.mess:	clr d0
	move.b (a0)+,d0
	beq.s .cont
	pea (a0)
	move d0,-(sp)
	move d0,-(sp)
	jsr ([$582])
	addq.l #4,sp
	move.l (sp)+,a0
	bra .mess

.cont:	moveq #7,d6
.loop:	moveq #0,d2
	add.l d7,d7
	roxl #1,d2
	add.l d7,d7
	roxl #1,d2	
	add.l d7,d7
	roxl #1,d2
	add.l d7,d7
	roxl #1,d2
	cmp #10,d2
	bcc.s .nodig
	add.b #'0',d2
	bra.s .dig
.nodig:	add.b #'A'-10,d2
.dig:	move d2,-(sp)
	move d2,-(sp)
	jsr ([$582])
	addq.l #4,sp
	addq.l #1,a5
	dbra d6,.loop
	movem.l (sp)+,a0-a6/d0-d7
	rts

auxout1:
	movem.l a0-a6/d0-d7,-(sp)

	move.l d0,d7
.mess:	clr d0
	move.b (a0)+,d0
	beq.s .cont
	pea (a0)
	move d0,-(sp)
	move d0,-(sp)
	jsr ([$582])
	addq.l #4,sp
	move.l (sp)+,a0
	bra .mess

.cont:	movem.l (sp)+,a0-a6/d0-d7
	rts

	endif


*Neue Busfehler-Behandlung zur virtuellen Speicherverwaltung

	align.l

buserr:
	movem.l a0-a6/d0-d7,-(sp)
	lea 60(sp),a6

	ifd DEBUG
	move.l 16(a6),d0
	lea _buserr,a0
	bsr auxout
	moveq #0,d0
	move 10(a6),d0
	lea _status,a0
	bsr auxout
	move.l 2(a6),d0
	lea _pc,a0
	bsr auxout
	endif

	move.l 16(a6),d0
	sub.l base,d0
	bcs busold0
	cmp.l ramsize(pc),d0
	bcc busold0

	cmp #$1008,6(a6)	;Throwaway-Stackframe?
	bne is_isp	;nein-
	movec msp,a6
is_isp:	move.b 11(a6),d0	;FC2-FC0
	movec d0,dfc
	ptestr dfc,([16,a6]),#7	;Deskriptor testen
	subq.l #2,sp
	pmove psr,(sp)
	btst #INVALID,(sp)+	;I-Bit testen
	beq busold0	;Busfehler-

skipdes:	move sr,-(sp)
	ori #$0700,sr	;keine Interrrupts
	move.l nxtadr,a0	;nÑchstes Tabellenelement
.finddes:movem.l (a0),a1-a2/a5	;Deskriptor
	move 2(a2),d0
	bclr #USED,3(a2)
	and #$0f08,d0	;LOCKED, RLOCKED, NLOCKED, MLOCKED, USED?
	beq.s .unused	;nein-
	move.l a1,a0	;nÑchster
	bra .finddes	;Deskriptor-
.unused:	move.l a1,nxtadr
	move (sp)+,sr

	ifd DEBUG
	pea (a0)
	move.l a5,d0
	lea _test,a0
	bsr auxout
	move.l (sp)+,a0
	endif

	move.l page,d0

	move.l 2(a6),d1
	and mask,d1
	cmp.l a5,d1	;PC-Seite?
	beq skipdes	;ja-
	sub.l d0,d1
	cmp.l a5,d1	;Page unter PC?
	beq skipdes	;ja-
	add.l d0,d1
	add.l d0,d1
	cmp.l a5,d1	;Page Åber PC?
	beq skipdes	;ja-

	movec isp,d1
	and mask,d1
	cmp.l a5,d1	;Stack-Page?
	beq skipdes
	sub.l d0,d1
	cmp.l a5,d1	;Page unter Stack?
	beq skipdes
	add.l d0,d1
	add.l d0,d1
	cmp.l a5,d1	;Page Åber Stack?
	beq skipdes

	movec msp,d1
	and mask,d1
	cmp.l a5,d1	;Stack-Page?
	beq skipdes
	sub.l d0,d1
	cmp.l a5,d1	;Page unter Stack?
	beq skipdes
	add.l d0,d1
	add.l d0,d1
	cmp.l a5,d1	;Page Åber Stack?
	beq skipdes

	move.l a0,a4

	move.l _vblqueue,a0
	ptestr dfc,(a0),#7
	subq.l #2,sp
	pmove psr,(sp)
	btst #INVALID,(sp)+
	bne.s novbl	;ausgelagert-

	ifd DEBUG
	lea _vbl,a0
	bsr auxout1
	move.l _vblqueue,a0
	endif

	move nvbls,d0
	subq #1,d0
testv:	move.l (a0)+,d1
	beq.s tcont
	and mask,d1
	cmp.l a5,d1
	beq skipdes
tcont:	dbra d0,testv

	ifd DEBUG
	lea _ok,a0
	bsr auxout1
	endif

novbl:
	ifd DEBUG
	lea _auto,a0
	bsr auxout1
	endif

	move.l oldbus,a0
	lea 88(a0),a0	;Spurious Interrupt, Autovektor-Interrupts
	moveq #7,d0
test0:	move.l (a0)+,a3
xbra1:	move.l a3,d1
	beq.s acont
	and mask,d1	;Vektoradressen testen
	cmp.l a5,d1
	beq skipdes

	ptestr dfc,(a3),#7
	subq.l #2,sp
	pmove psr,(sp)
	btst #INVALID,(sp)+
	bne.s acont	;ausgelagert-

	ptestr dfc,-12(a3),#7
	subq.l #2,sp
	pmove psr,(sp)
	btst #INVALID,(sp)+
	bne.s acont	;ausgelagert-

	cmp.l #"XBRA",-12(a3)
	bne.s acont
	cmp.l -4(a3),a3
	beq.s acont
	move.l -4(a3),a3
	bra xbra1
acont:	dbra d0,test0

	ifd DEBUG
	lea _ok,a0
	bsr auxout1
	endif

	ifd DEBUG
	lea _mfp1,a0
	bsr auxout1
	endif

	lea 256,a0	;MFP-Interrupts
	moveq #15,d0
testm:	move.l (a0)+,a3
xmfp:	move.l a3,d1
	sub.l base,d1
	bcs.s mcont
	cmp.l ramsize(pc),d1
	bcc.s mcont
	move.l a3,d1
	and mask,d1
	cmp.l a5,d1
	beq skipdes

	ptestr dfc,(a3),#7
	subq.l #2,sp
	pmove psr,(sp)
	btst #INVALID,(sp)+
	bne.s mcont	;ausgelagert-

	ptestr dfc,-12(a3),#7
	subq.l #2,sp
	pmove psr,(sp)
	btst #INVALID,(sp)+
	bne.s mcont	;ausgelagert-

	cmp.l #"XBRA",-12(a3)
	bne.s mcont
	cmp.l -4(a3),a3
	beq.s mcont
	move.l -4(a3),a3
	bra xmfp
mcont:	dbra d0,testm

	ifd DEBUG
	lea _ok,a0
	bsr auxout1
	endif

	ifd DEBUG
	lea _mfp2,a0
	bsr auxout1
	endif

	lea 320,a0	;MFP-, SCC-Interrupts
	moveq #31,d0
tests:	move.l (a0)+,a3
xscc:	move.l a3,d1
	sub.l base,d1
	bcs.s m2cont
	cmp.l ramsize(pc),d1
	bcc.s m2cont
	move.l a3,d1
	and mask,d1
	cmp.l a5,d1
	beq skipdes

	ptestr dfc,(a3),#7
	subq.l #2,sp
	pmove psr,(sp)
	btst #INVALID,(sp)+
	bne.s m2cont	;ausgelagert-

	ptestr dfc,-12(a3),#7
	subq.l #2,sp
	pmove psr,(sp)
	btst #INVALID,(sp)+
	bne.s m2cont	;ausgelagert-

	cmp.l #"XBRA",-12(a3)
	bne.s m2cont
	cmp.l -4(a3),a3
	beq.s m2cont
	move.l -4(a3),a3
	bra xscc
m2cont:	dbra d0,tests

	ifd DEBUG
	lea _ok,a0
	bsr auxout1
	endif

	move.l oldbus,a0
	move.l 268(a0),a3	;System-Interrupt
xbra6:	move.l a3,d1
	beq.s scont
	and mask,d1
	cmp.l a5,d1
	beq skipdes

	ptestr dfc,(a3),#7
	subq.l #2,sp
	pmove psr,(sp)
	btst #INVALID,(sp)+
	bne.s scont	;ausgelagert-

	ptestr dfc,-12(a3),#7
	subq.l #2,sp
	pmove psr,(sp)
	btst #INVALID,(sp)+
	bne.s scont	;ausgelagert-

	cmp.l #"XBRA",-12(a3)
	bne.s scont
	cmp.l -4(a4),a3
	beq.s scont
	move.l -4(a3),a3
	bra xbra6

scont:
	ifd DEBUG
	pea (a0)
	lea _ikbd,a0
	bsr auxout1
	move.l (sp)+,a0
	endif

	move.l 272(a0),a3	;IKBD-Interrupt
xbra5:	move.l a3,d1
	beq.s icont
	and mask,d1
	cmp.l a5,d1
	beq skipdes

	ptestr dfc,(a3),#7
	subq.l #2,sp
	pmove psr,(sp)
	btst #INVALID,(sp)+
	bne.s icont	;ausgelagert-

	ptestr dfc,-12(a3),#7
	subq.l #2,sp
	pmove psr,(sp)
	btst #INVALID,(sp)+
	bne.s icont	;ausgelagert-

	cmp.l #"XBRA",-12(a3)
	bne.s icont
	cmp.l -4(a3),a3
	beq.s icont
	move.l -4(a3),a3
	bra xbra5

icont:
	ifd DEBUG
	lea _ok,a0
	bsr auxout1
	endif

	ifd DEBUG
	lea _etv,a0
	bsr auxout1
	endif

	lea etv_timer,a0
	moveq #2,d0
test2:	move.l (a0)+,a3
xbra2:	move.l a3,d1
	beq ticont
	and mask,d1
	cmp.l a5,d1
	beq skipdes

	ptestr dfc,(a3),#7
	subq.l #2,sp
	pmove psr,(sp)
	btst #INVALID,(sp)+
	bne.s ticont	;ausgelagert-

	ptestr dfc,-12(a3),#7
	subq.l #2,sp
	pmove psr,(sp)
	btst #INVALID,(sp)+
	bne.s ticont	;ausgelagert-

	cmp.l #"XBRA",-12(a3)
	bne.s ticont
	cmp.l -4(a3),a3
	beq ticont
	move.l -4(a3),a3
	bra xbra2
ticont:	dbra d0,test2

	ifd DEBUG
	lea _ok,a0
	bsr auxout1
	endif

	ifd DEBUG
	lea _color,a0
	bsr auxout1
	endif

	move.l colorptr,d1
	beq nocol
	and mask,d1
	cmp.l a5,d1
	beq skipdes

nocol:
	ifd DEBUG
	lea _ok,a0
	bsr auxout1
	endif


	ifd DEBUG
	lea _kbdv,a0
	bsr auxout1
	endif

	move.l kbdvbase,a0
	moveq #8,d0
test4:	move.l (a0)+,a3
xbra4:	move.l a3,d1
	beq.s nok
	and mask,d1
	cmp.l a5,d1
	beq skipdes
	add.l page,d1
	cmp.l a5,d1
	beq skipdes

	ptestr dfc,(a3),#7
	subq.l #2,sp
	pmove psr,(sp)
	btst #INVALID,(sp)+
	bne.s nok	;ausgelagert-

	ptestr dfc,-12(a3),#7
	subq.l #2,sp
	pmove psr,(sp)
	btst #INVALID,(sp)+
	bne.s nok	;ausgelagert-

	cmp.l #"XBRA",-12(a3)
	bne.s nok
	cmp.l -4(a3),a3
	beq nok
	move.l -4(a3),a3
	bra xbra4
nok:	dbra d0,test4

	ifd DEBUG
	lea _ok,a0
	bsr auxout1
	endif

	ifd DEBUG
	move.l (a2),d0
	clr.b d0
	lea _oldadr,a0
	bsr auxout
	endif

	move.l (a2),d0	;zu verwerfender Deskriptor
	move _method(pc),d1	;TT-RAM einbeziehen?
	bne ttplus1	;ja, immer zurÅckschreiben-
	bclr #MODIFIED,d0
	beq notmod	;Seite unverÑndert-
	bra ttplus2

ttplus1:	move.l a2,d1
	sub.l pageadr(pc),d1
	move.l specsec,([sectab],d1.l)

ttplus2:	movem.l d0/a2/a6,-(sp)
	sub.l pageadr(pc),a2
	move.l ([sectab],a2.l),a6

	cmp.l _datrec-2,a6
	bcs secerr	;Verwaltungssektor-
	move status,-(sp)
	move sr,-(sp)
	pea (a6)

	ifd DEBUG
	move.l d0,-(sp)
	move.l a6,d0
	lea _write,a0
	bsr auxout
	move.l (sp)+,d0
	endif

	move drive,-(sp)
	move #-1,-(sp)
	move secpage,-(sp)	;Sektoren pro Page
	clr.b d0

	tst.b scsiflg
	bne.s scsi1

	move.l a2,d0
	lsr.l #2,d0
	mulu.l page,d0
	add.l base,d0	;ergibt logische Pageadresse
	
scsi1:	move.l d0,-(sp)	;Pufferadresse
	move wflags,-(sp)

	st status
	tst.b iplflg
	bne rw0
	andi #$fbff,sr
rw0:	jsr ([sys_rw])	;Page schreiben
	lea 16(sp),sp
	move (sp)+,sr
	move (sp)+,status

	ifd DEBUG
	move.l d0,-(sp)
	move.l a6,d0
	lea _ok,a0
	bsr auxout1
	move.l (sp)+,d0
	endif

	tst.l d0
	movem.l (sp)+,d0/a2/a6	;Flags beibehalten
	bpl notmod

	sub.l pageadr(pc),a2
secerr:	move.l ([sectab],a2.l),d0
	lea wsec,a0
	move country,d1
	move.l (a0,d1*4),a0
	bsr int
	clr.b (a0)
	lea wrterr,a0
	move country,d0
	move.l (a0,d0*4),a0
	bra alert	;Schreibfehler-

notmod:	move.l a2,d1
	sub.l pageadr(pc),d1
	lsr.l #2,d1
	mulu _page(pc),d1
	add.l base,d1
	move.l d1,a0	;zeigt auf logische Adresse

	ptestr dfc,([16,a6]),#7,a1
	move.l (a1),d1	;alter Deskriptor
	clr.b d1
	and.l #%01000100,(a1)	;Seite verwerfen
	and.b #%00000001,d0	;CI, M, U, WP lîschen
	or.l d0,(a1)	;neuer Deskriptor
	pflush #0,#0,([16,a6])
	ploadr dfc,([16,a6])
	and.b #%01000100,3(a2)	;Seite verwerfen, CI/WP erhalten
	move.l a1,4(a4)	;Deskriptoradresse

	move.l d0,-(sp)
	move.l 16(a6),d0
	and mask,d0
	move.l d0,8(a4)	;logische Adresse
	move.l (sp)+,d0

	sub.l pageadr(pc),a1
	move.l ([sectab],a1.l),specsec
	tst.l d1
	beq noload	;neu eingerichtet-

	move status,-(sp)
	move sr,-(sp)
	move.l specsec,-(sp)

	ifd DEBUG
	move.l d0,-(sp)
	move.l specsec,d0
	lea _read,a0
	bsr auxout
	move.l (sp)+,d0
	endif

	move drive,-(sp)
	move #-1,-(sp)
	move secpage,-(sp)	;Sektoren pro Page
	clr.b d0

	tst.b scsiflg
	bne scsi2

	move.l 16(a6),d0	;Busfehler-Adresse
	and mask,d0

scsi2:	move.l d0,-(sp)	;Ladeadresse
	move rflags,-(sp)
	st status
	tst.b iplflg
	bne rw1
	andi #$fbff,sr
rw1:	jsr ([sys_rw])	;Page lesen
	lea 16(sp),sp
	move (sp)+,sr
	move (sp)+,status

	ifd DEBUG
	move.l d0,-(sp)
	move.l specsec,d0
	lea _ok,a0
	bsr auxout1
	move.l (sp)+,d0
	endif

	tst.l d0
	bpl noload

	move.l specsec,d0
	lea rsec,a0
	move country,d1
	move.l (a0,d1*4),a0
	bsr int
	clr.b (a0)
	lea readerr,a0
	move country,d0
	move.l (a0,d0*4),a0
	bra alert	;Lesefehler-

noload:	bmi busold	;Fehler-
	movem.l (sp)+,a0-a6/d0-d7
	rte	;Befehl wiederholen
busold0:	tst.b 11(a6)	;RWM-Cyclus, Bit 7?
	bpl busold	;nein-
	ploadr dfc,([16,a6])	;ATC auffrischen
	movem.l (sp)+,a0-a6/d0-d7
	rte
busold:	movem.l (sp)+,a0-a6/d0-d7
	move.l ([oldbus]),-(sp)
	rts	;weiter im System


	align.l

*Mit NVDI: Null als Blitterstatus zurÅckliefern, sonst wahrer Status
xbios:
	lea 8(sp),a0	;Supervisor-
	btst #5,(sp)	;Modus?
	bne.s .super	;ja-
	move.l usp,a0
.super:	cmp #BLITMODE,(a0)
	bne.s .noblit

	move.l _p_cookies,d0
	beq.s .xbios	;kein cookie jar-
	move.l d0,a1
.nonvdi:	movem.l (a1)+,d0-d1
	tst.l d0
	beq.s .xbios	;Ende des cookie jar-
	cmp.l #"NVDI",d0
	bne .nonvdi

	clr 2(a0)
.xbios:	jmp ([$b8])	;Blitter abschalten

.noblit:	cmp #FLOPVER,(a0)
	beq.s .ver
	cmp #FLOPRD,(a0)
	bne.s .nord

.ver:	move 18(a0),d0	;count
	beq .cont	;keine öbertragung-
	move.l 2(a0),d1
	sub.l base,d1
	bcs .cont
	cmp.l ramsize(pc),d1
	bcc .cont
	
	move 6(sp),d1	;Vektoroffset
	move (a0),-(sp)
	move d0,-(sp)
	move.l 2(a0),-(sp)	;Pufferadresse
	move d0,-(sp)	;count
	move 16(a0),-(sp)	;sideno
	move 14(a0),-(sp)	;trackno
	move 12(a0),-(sp)	;sectno
	move 10(a0),-(sp)	;devno
	move.l 6(a0),-(sp)	;filler
	move.l flopbuf,-(sp)
	move (a0),-(sp)
	move d1,-(sp)	;Vektoroffset
	pea .retrd(pc)
	move sr,-(sp)
	jmp ([$b8])
.retrd:	lea 20(sp),sp
	move.l (sp)+,a0	;Pufferadresse
	move (sp)+,d1
	cmp #FLOPVER,(sp)+
	beq.s .ret
	asl #7,d1
	subq #1,d1
	move.l flopbuf,a1
.copyrd:	move.l (a1)+,(a0)+
	dbra d1,.copyrd
.ret:	rte

.nord:	cmp #FLOPWR,(a0)
	bne.s .nowr

	move 18(a0),d0	;count
	beq .cont	;keine öbertragung-
	move.l 2(a0),d1
	sub.l base,d1
	bcs .cont
	cmp.l ramsize(pc),d1
	bcc .cont

	asl #7,d0
	subq #1,d0
	pea (a0)
	move.l 2(a0),a0
	move.l flopbuf,a1
.copywr:	move.l (a0)+,(a1)+
	dbra d0,.copywr
	move.l (sp)+,a0
	move 6(sp),d1	;Vektoroffset
	move 18(a0),-(sp)	;count
	move 16(a0),-(sp)	;sideno
	move 14(a0),-(sp)	;trackno
	move 12(a0),-(sp)	;sectno
	move 10(a0),-(sp)	;devno
	move.l 6(a0),-(sp)	;filler
	move.l flopbuf,-(sp)
	move (a0),-(sp)
	move d1,-(sp)	;Vektoroffset
	pea .retwr(pc)
	move sr,-(sp)
	jmp ([$b8])
.retwr:	lea 20(sp),sp
	rte

.nowr:	cmp #FLOPFMT,(a0)
	bne.s .cont

	move.l 2(a0),d0
	sub.l base,d0
	bcs.s .cont
	cmp.l ramsize(pc),d0
	bcc.s .cont

	move 6(sp),d0	;Vektoroffset
	pea (a0)
	move 24(a0),-(sp)	;virgin
	move.l 20(a0),-(sp)	;magic
	move 18(a0),-(sp)	;interlv
	move 16(a0),-(sp)	;sideno
	move 14(a0),-(sp)	;trackno
	move 12(a0),-(sp)	;spt
	move 10(a0),-(sp)	;devno
	move.l 6(a0),-(sp)	;filler
	move.l flopbuf,-(sp)
	move (a0),-(sp)
	move d0,-(sp)	;Vektoroffset
	pea .retfmt(pc)
	move sr,-(sp)
.cont:	jmp ([$b8])
.retfmt:	lea 26(sp),sp
	move.l (sp)+,a0

	moveq #127,d1	;kurze Liste defekter Sektoren
	move.l 2(a0),a0
	move.l flopbuf,a1
.copyfmt:move.l (a1)+,(a0)+
	dbra d1,.copyfmt

	rte


	align.l

vdi:
	cmp #$73,d0
	beq.s .vdi
.jvdi:	jmp ([$88])

.vdi:	movem.l a0-a2/d1-d2,vdipar
	cmp #1,([d1.l])	;v_openwk
	bne .nowk
	cmp #11,([4,d1.l])
	bcc .jvdi	;keine Bildschirm-Workstation-

	clr -(sp)	;Blitter abschalten
	move #BLITMODE,-(sp)
	move 10(sp),-(sp)	;Vektoroffset
	pea .blitoff(pc)
	move sr,-(sp)
	jmp ([$b8])

.blitoff:addq.l #4,sp
	btst #0,d0
	bne.s .blit	;Blitter ist weiterhin an-

	tst.l srcbuf
	beq.s .noblit

	move.l srcbuf,-(sp)
	move #MFREE,-(sp)
	trap #GEMDOS
	addq.l #6,sp
	clr.l srcbuf

.noblit:	movec vbr,a0
	move.l #newvec,$88(a0)	;aus VDI ausklinken
	bra.s .cvdi

.blit:	move 6(sp),-(sp)	;Vektoroffset
	pea .wk(pc)
	move sr,-(sp)
.cvdi:	movem.l vdipar,a0-a2/d1-d2
	moveq #$73,d0
	jmp ([$88])

.wk:	movem.l vdipar,a0-a2/d1-d2
	move.l (d1.l),a1	;Pointer auf CONTROL-Array
	lea contrl,a0
	move #102,(a0)+	;vq_extnd
	move.l #$00000006,(a0)+
	move.l #$0001002d,(a0)+
	move.l 10(a1),(a0)	;handle
	move #1,intin	;erweiterte Parameter
	move 6(sp),-(sp)	;Vektoroffset
	pea .extnd(pc)
	move sr,-(sp)
	move.l #vdipb,d1
	moveq #$73,d0
	jmp ([$88])

.extnd:	movem.l vdipar,a0-a2/d1-d2
	move.l (12,d1.l),a0	;Pointer auf INTOUT-Array
	move (a0)+,d0
	addq #1,d0
	move (a0),d1
	addq #1,d1
	mulu d1,d0
	moveq #0,d1
	move intout+8,d1	;Zahl der Farbebenen
	mulu.l d1,d0
	lsr.l #3,d0	;Platz fÅr Bildschirmspeicher
	clr -(sp)
	move.l d0,-(sp)
	move #MXALLOC,-(sp)
	trap #GEMDOS
	addq.l #8,sp
	move.l d0,srcbuf
	movem.l vdipar,a0-a2/d1-d2
	rte

.nowk:	cmp #2,([d1.l])	;v_clswk
	bne .nocw

	move.l d1,-(sp)

	lea contrl,a0
	move #102,(a0)+	;vq_extnd
	move.l #$00000006,(a0)+
	move.l #$0001002d,(a0)+
	move.l ([d1.l],10),(a0)	;handle
	move #1,intin	;erweiterte Parameter
	move.l #vdipb,d1
	move 10(sp),-(sp)	;Vektoroffset
	pea .ext(pc)
	move sr,-(sp)
	jmp ([$88])
.ext:	move.l (sp)+,d1
	moveq #$73,d0

	tst intout
	beq .cvdi	;keine Bildschirm-Workstation-
	tst.l srcbuf
	beq .cvdi	;kein Puffer reserviert-

	move 6(sp),-(sp)	;Vektoroffset
	pea .cw(pc)
	move sr,-(sp)
	jmp ([$88])
.cw:	move.l srcbuf,-(sp)
	move #MFREE,-(sp)
	trap #GEMDOS
	addq.l #6,sp
	clr.l srcbuf
	movem.l vdipar,a0-a2/d1-d2
	rte

.nocw:	cmp #109,([d1.l])	;vro_cpyfm
	beq.s .vro
	cmp #121,([d1.l])	;vrt_cpyfm
	bne.s .novrt

.vro:	move.l (d1.l),a0	;Pointer auf CONTROL-Array
	move.l ([14,a0]),d2
	sub.l base,d2
	bcs.s .nosrc
	cmp.l ramsize(pc),d2
	bcs.s .split	;Source in virtuellem RAM-
.nosrc:	move.l ([18,a0]),d2
	sub.l base,d2
	bcs.s .novrt
	cmp.l ramsize(pc),d2
	bcs.s .split
.novrt:	movem.l vdipar,a0-a2/d1-d2
	jmp ([$88])	;kein virtuelles RAM angesprochen-

*VDI-Array kopieren

.split:	move.l d1,-(sp)
	move.l d1,a0
	move.l (a0),a1
	lea contrl,a2
	moveq #10,d0
.cntrl:	move (a1)+,(a2)+	;contrl-Array
	dbra d0,.cntrl
	move.l 4(a0),a1
	move (a1)+,intin	;intin-Array
	move.l (a1),intin+2
	move.l 8(a0),a1
	lea ptsin,a2
	moveq #3,d0
.ptsin:	move.l (a1)+,(a2)+	;ptsin-Array
	dbra d0,.ptsin

	move.l (d1.l),a0
	move.l 14(a0),a1
	move.l a1,psrcmfdb	;Pointer auf Source Originaldaten
	addq.l #4,a1
	lea srcdata,a2
	move.l srcbuf,(a2)+
	moveq #3,d0
.cpsrc:	move.l (a1)+,(a2)+
	dbra d0,.cpsrc
	move.l 18(a0),a1
	move.l a1,pdesmfdb	;Pointer auf Destination Originaldaten
	addq.l #4,a1
	lea dstdata,a2
	move.l srcbuf,(a2)+
	moveq #3,d0
.cpdst:	move.l (a1)+,(a2)+
	dbra d0,.cpdst

*Blittertransfer in Verbindung mit virtuellem RAM
*Prinzip: Daten in Blîcke aufspalten und getrennt blitten.
*Die Blîcke werden in einen Puffer kopiert, anschlieûend werden
*die y-Koordinaten fÅr den Blit an die Blockgrîûe angepasst.

	move.l (sp),d1

	move.l ([d1.l],14),a1	;psrcMFDB
	move.l (a1),d2
	sub.l base,d2
	bcs.s .nosrc1
	cmp.l ramsize(pc),d2
	bcc.s .nosrc1	;Source nicht virtuell-

	lea srcdata,a0	;neuer Source MFDB
	move.l a0,contrl+14
	lea ptsin,a2
	bsr copymfdb

.nosrc1:	move.l ([d1.l],18),a1	;pdesMFDB
	move.l (a1),d2
	sub.l base,d2
	bcs.s .nodst1
	cmp.l ramsize(pc),d2
	bcc.s .nodst1	;Destination nicht virtuell-

	lea dstdata,a0
	move.l a0,contrl+18	;neuer Destination MFDB

	move.l ([d1.l],14),a0
	move.l ([d1.l],18),a1
	cmpm.l (a0)+,(a1)+
	beq bliterr	;Blit im Speicher-

.nodst1:	move 10(sp),-(sp)	;Vektoroffset
	pea .ret(pc)
	move sr,-(sp)
	move.l #vdipb,d1
	moveq #$73,d0
	jmp ([$88])

.ret:	move.l (sp)+,d1
	move.l ([pdesmfdb]),d2
	sub.l base,d2
	bcs.s .nodst
	cmp.l ramsize(pc),d2
	bcc.s .nodst	;Destination nicht virtuell-

	move.l pdesmfdb,a0
	lea dstdata,a1
	lea ptsin,a2
	bsr.s copymfdb	;Koordinaten sind schon angepasst

.nodst:	movem.l vdipar,a0-a2/d1-d2
	rte


*Sourcedaten fÅr Blit in Blitterpuffer schreiben
*A0: Pointer auf Source MFDB
*A1: Pointer auf Original-MFDB
*A2: Pointer auf Koordinaten
*D1 nicht verÑndern!
copymfdb:
	move 6(a0),d0
	mulu 12(a0),d0	;fd_planes
	mulu 8(a0),d0	;fd_wwidth

	move.l (a0),a0
	move.l (a1),a1
	lsr.l #1,d0
	scs d2
	beq.s .word
	
.copy:	move.l (a1)+,(a0)+
	subq.l #1,d0
	bne .copy
.word:	tst.b d2
	beq.s .ret
	move (a1),(a0)

.ret:	rts


	align.l

gemdos:
	lea 8(sp),a0
	btst #5,(sp)	;Supervisor-Modus?
	bne.s .super	;ja-
	move.l usp,a0
.super:	movem.l a1-a2/d1-d2,-(sp)	;Registerzahl, Vektoroffset beachten
	move.l #reset,resvector
	cmp #PTERMRES,(a0)
	bne nlock

	move.l 2(a0),d0	;Grîûe des residenten Teils
	move.l ([_sysbase],40),a1
	move.l (a1),a1	;zeigt auf Basepage
	moveq #RLOCKED,d1

lock:	cmp.l base,a1	;liegt Programm im TT-RAM?
	bcs noterm	;nein-

	move.l a1,a2
	move.l a1,d2
	and mask,d2
	move.l d2,a1
	add.l d0,a2
	add.l page,a2
	subq.l #1,a2
	move.l a2,d2
	and mask,d2
	move.l d2,a2
	
.dolock:
	ifd DEBUG
	move.l a1,d0
	lea _lockadr,a0
	bsr auxout
	endif

	ptestr #7,(a1),#7,a0
	bset d1,2(a0)	;Programm gegen Auslagern sperren
	tst.b (a1)	;Seite bei Bedarf nachladen

	ifd DEBUG
	move.l (a0),d0
	and mask,d0
	lea _physadr,a0
	bsr auxout
	endif

	add.l page,a1
	cmp.l a1,a2
	bne .dolock
	bra noterm

nlock:	cmp #PEXEC,(a0)
	bne .nexec
	tst 2(a0)
	beq.s .exec
	cmp #200,2(a0)
	seq gemflg
	cmp #100,2(a0)
	bne noterm

.exec:	move.l a0,d2	;Pointer auf Parameter
	move.l ([_sysbase],36),a1	;kbshift
	move.b (a1),d1
	btst #3,d1	;Alternate-Taste?
	bne.s .dolock	;ja-
	tst.l infbuf
	beq noterm	;keine INF-Datei-

	move.l 4(a0),a0	;Pointer auf Dateinamen
	move.l a0,a1
.name:	tst.b (a0)+
	bne .name
.find:	cmp.l a0,a1
	beq.s .start
	cmp.b #'\',-(a0)
	bne .find
	addq.l #1,a0
.start:	move.l a0,a2	;Beginn des Dateinamens
	move.l infbuf,a1
	tst.b (a1)
	beq noterm	;Ende der Liste-

.loop:	move.l a2,a0
.comp:	tst.b (a0)
	beq.s .dolock	;Datei gefunden-
	cmpm.b (a0)+,(a1)+
	beq .comp
.next:	tst.b (a1)
	beq noterm
	cmp.b #$0a,(a1)+
	bne .next
	bra .loop

.dolock:	move 6+16(sp),d0	;Vektoroffset
	move.l d2,a0
	pea (a0)
	move.l 12(a0),-(sp)
	move.l 8(a0),-(sp)
	move.l 4(a0),-(sp)
	move #3,-(sp)
	move #PEXEC,-(sp)
	move d0,-(sp)	;Vektoroffset
	pea .retex(pc)
	move sr,-(sp)
	jmp ([$84])
.retex:	lea 16(sp),sp
	move.l (sp)+,a0
	move.l d0,8(a0)
	addq #6,2(a0)

	move.l d0,a1
	move.l 12(a1),d0	;LÑnge des TEXT-Segments
	add.l 20(a1),d0	;auch DATA- und BSS-Segment
	add.l 28(a1),d0	;locken
	moveq #NLOCKED,d1
	bra lock

.nexec:	cmp #MSHRINK,(a0)
	bne.s .nshrink

	tst.b gemflg
	beq noterm
	clr.b gemflg

	move.l 4(a0),a1	;Start des residenten Blocks
	move.l 8(a0),d0	;Grîûe des residenten Blocks
	moveq #NLOCKED,d1
	bra lock

.nshrink:tst (a0)
	beq.s .term
	cmp #PTERM,(a0)
	bne.s noterm

.term:	move.l ([_sysbase],40),a1
	move.l (a1),a1	;zeigt auf Basepage
	cmp.l base,a1	;liegt Programm im TT-RAM?
	bcs noterm	;nein-

	move.l 12(a1),d0	;Grîûe des residenten Teils
	add.l 20(a1),d0
	add.l 28(a1),d0
	move.l a1,d2
	and mask,d2
	move.l d2,a1
	add.l page,d0
	subq.l #1,d0
	and mask,d0
.unlock:	ptestr #7,(a1),#7,a0
	bclr #NLOCKED,2(a0)	;Pages freigeben
	add.l page,a1
	sub.l page,d0
	bne .unlock
noterm:	movem.l (sp)+,a1-a2/d1-d2
	jmp ([$84])

bliterr:	lea blit,a0
	move country,d0
	move.l (a0,d0*4),-(sp)
	move #CCONWS,-(sp)
	trap #GEMDOS
	addq.l #6,sp

*Fehlermeldung nach Schreib-/Lesefehler
alert:
	clr.l memvalid
	pea (a0)
	move #CCONWS,-(sp)
	trap #GEMDOS
	addq.l #6,sp
	lea wait,a0
	move country,d0
	move.l (a0,d0*4),-(sp)
	move #CCONWS,-(sp)
	trap #GEMDOS
	addq.l #6,sp
	move #CRAWCIN,-(sp)
	trap #GEMDOS
	addq.l #2,sp
	jmp ([$04])	;Reset


reset:
	clr.l resvalid
	clr.l _shell_p
	clr.l pun_ptr
	jmp (a6)


*Einschub in Harddisk-DMA-Routinen
*Lesen/Schreiben in Blîcken

rwflag	= 8      ;Flag fÅr Lesen/Schreiben
buf	= 10     ;Pufferadresse
count	= 14     ;Sektorzahl
secno	= 16     ;erster  Sektor
dev	= 18     ;Laufwerksnummer
extno	= 20     ;erweiterte Sektornummer

counter	= -2     ;zÑhlt Sektoren


	dc.l "XBRA"
	dc.l magic
o_rw:	dc.l 0
hrw:
	move dev-4(sp),d0
	cmp drive,d0	;Swap-Laufwerk?
	bne nowrt	;nein-
	btst #0,rwflag+1-4(sp)	;Schreiben?
	beq.s nowrt	;nein-
	btst #3,rwflag+1-4(sp)
	bne.s nowrt	;physikalischer Modus-

.loop:	move dev-4(sp),d1
	moveq #-13,d0
	and #$1f,d1
	move d1,-(sp)
	move d0,-(sp)
	move.l etv_critic,a0
	jsr (a0)
	addq.l #4,sp
	cmp.l #$10000,d0
	beq .loop
	rts

nowrt:
	tst count-4(sp)
	beq cont
	move.l buf-4(sp),d0	;Pufferadresse
	beq cont
	sub.l base,d0
	bcs cont	;ST-RAM-
	cmp.l ramsize(pc),d0
	bcc cont	;kein TT-RAM- 
	link a6,#counter
rwloop:	pea (a6)
	move.l extno(a6),-(sp)
	move dev(a6),d1
	move d1,-(sp)
	move secno(a6),-(sp)
	moveq #0,d0
	move count(a6),d0	;Sektorzahl
	btst #3,rwflag+1(a6)
	bne.s phys	;physikalischer Zugriff-
	cmp (secs,d1*2),d0	;nicht mehr als
	bls countok	;die Puffergrîûe-
	move (secs,d1*2),d0	;Sektormaximum
	bra countok
phys:	cmp #65536/512,d0
	bls countok
	move #65536/512,d0
countok:	move d0,counter(a6)
	sub d0,count(a6)	;ergibt verbleibende Sektoren
	move d0,-(sp)	;Sektorzahl
	cmp #-1,secno(a6)
	beq ext
	add d0,secno(a6)	;nÑchste
	bra noext	;Sektornummer
ext:	add.l d0,extno(a6)
noext:	btst #0,rwflag+1(a6)
	beq read	;lesen-
	move.l buf(a6),a0	;Startadresse
	lea buffer,a1	;in Puffer
	bsr dcopy	;kopieren
read:	pea buffer	;Pufferadresse
	move rwflag(a6),-(sp)
	jsr ([o_rw])	;Sektoren lesen/schreiben
	lea 16(sp),sp
	move.l (sp)+,a6
	tst.l d0
	bmi err	;Fehler-
	btst #0,rwflag+1(a6)
	bne write	;schreiben-
	move.l buf(a6),a1	;Startadresse
	lea buffer,a0	;Daten aus
	bsr dcopy	;Puffer holen
write:	move #512,d0	;physikalische Sektorgrîûe
	btst #3,rwflag+1(a6)	;physikalischer Zugriff?
	bne phys0	;ja-
	move dev(a6),d1
	move (seclens,d1*2),d0
phys0:	mulu counter(a6),d0
	add.l d0,buf(a6)	;neue Pufferadresse
	tst count(a6)	;fertig?
	bne rwloop	;nein-
	moveq #0,d0
err:	unlk a6
	rts
cont:	jmp ([o_rw])	;weiter wie gehabt-

*Daten zwischen DMA-Puffer und TT-RAM verschieben
dcopy:
	move #512,d0
	btst #3,rwflag+1(a6)
	bne.s .phys
	move dev(a6),d1
	move (seclens,d1*2),d0	;SektorlÑnge
.phys:	mulu counter(a6),d0	;Sektorzahl
	lsr.l #8,d0	;Blîcke zu 256 Bytes
	subq.l #1,d0
.copy:	repeat
	move.l (a0)+,(a1)+
	until #63
	dbra d0,.copy
	rts


	dc.l "XBRA"
	dc.l magic
o_bpb:	dc.l 0
hbpb:
	move 4(sp),-(sp)	;Drivenummer
	move 6(sp),-(sp)	;nochmal
	jsr ([o_bpb])
	addq.l #2,sp
	move (sp)+,d2
	tst.l d0
	beq bpberr
	move.l d0,a0
	move (a0),(seclens,d2*2)	;Sektorgrîûe
	move.l #65536,d1
	divu (a0),d1	;SektorkapazitÑt von DMA-Puffer
	move d1,(secs,d2*2)	;merken
bpberr:	rts


*dezimale Ausgabe
int:
	tst.l d0
	beq int5	;Null-
	moveq #5,d7
	move.l a0,a1
	move.l #100000,d2	;Startwert fÅr Subtraktion
int1:	moveq #-1,d1	;zÑhlt Subtraktionen
int0:	addq.b #1,d1
	sub.l d2,d0	;so oft wie mîglich subtrahieren
	bcc int0
	add.l d2,d0
	divu #10,d2	;nÑchste	Stelle
	tst.b d1
	bne int3
	cmp.l a1,a0
	beq int4
int3:	add.b #"0",d1	;Ziffer nach ASCII wandeln
	move.b d1,(a0)+
int4:	dbra d7,int1
	rts
int5:	move.b #"0",(a0)+
	rts


*ST-RAM in TT-RAM umwandeln
st_to_tt:
	move.l base,stbuf
	move.l _mem(pc),d0
	beq.s .ttram	;kein ST-Puffer angefordert-
	add.l page,d0
	subq.l #1,d0

	clr -(sp)
	move.l d0,-(sp)
	move #MXALLOC,-(sp)
	trap #GEMDOS
	addq.l #8,sp
	lea ramerr,a3
	tst.l d0
	beq.s .error	;zu wenig Alternate RAM-

	add.l page,d0
	subq.l #1,d0
	and mask,d0	;Startadresse fÅr virtuelles RAM
	move.l d0,stbuf

.ttram:	moveq #0,d0
	rts
.error:	moveq #-1,d0
	rts


*Swap-Laufwerk initialisieren
init_drv:
	move #512,seclens	;fÅr Floppies
	move #512,seclens+2
	move #65536/512,secs
	move #65536/512,secs+2

	lea drverr,a3
	move drive,d0
	cmp #2,d0
	bcs .error
	move.l _drvbits,d7
	btst d0,d7	;Swap-Laufwerk vorhanden?
	beq .error	;nein-

	moveq #2,d5	;Start mit Laufwerk C
.getdrv:	btst d5,d7
	beq .nodrive	;Laufwerk nicht vorhanden-

	move d5,-(sp)
	move #GETBPB,-(sp)
	trap #BIOS
	addq.l #4,sp
	tst.l d0
	beq .nodrive	;BPB ungÅltig-

	move.l d0,a6
	move (a6),(seclens,d5*2)	;Sektorgrîûe merken
	move.l #65536,d0
	divu (a6),d0
	move d0,(secs,d5*2)	;SektorkapazitÑt von DMA-Puffer merken
	cmp drive,d5	;Swap-Laufwerk?
	bne .nodrive	;nein-

	move recsiz(a6),_recsiz
	move clsiz(a6),_clsiz
	moveq #0,d1
	move clsizb(a6),d1
	move d1,_clsizb
	divu _page(pc),d1	;Sektoren fÅr eine Page
	move datrec(a6),_datrec
	move numcl(a6),d0
	sub d1,d0	;vorsichtshalber eine Page freilassen
	move d0,_numcl
	
	tst.l xhdipnt	;XHDI aktiv?
	beq .noxhdi1	;nein-
	cmp.l #$27011992,([xhdipnt],-4)
	bne .noxhdi1

	pea maxipl
	clr.l -(sp)
	clr.l -(sp)
	clr.l -(sp)
	clr.l -(sp)
	move d5,-(sp)
	move #XHInqDriver,-(sp)
	jsr ([xhdipnt])
	lea 24(sp),sp
	cmp #EDRIVE,d0
	beq.s .noxhdi1
	cmp #6,maxipl
	scc iplflg

	clr.l -(sp)
	clr.l -(sp)
	pea minor
	pea major
	move d5,-(sp)
	move #XHInqDev,-(sp)	;GerÑtenummern erfragen
	jsr ([xhdipnt])
	lea 20(sp),sp
	tst d0
	bmi.s .noxhdi1
	cmp #16,major
	bcc.s .xhdi	;kein SCSI-
	cmp #8,major
	scc scsiflg
	bra.s .xhdi

.noxhdi1:cmp #16,d5
	bcc.s .error	;ohne XHDI maximal bis P:
	move.l pun_ptr,d0
	beq.s .xhdi
	move.l d0,a0
	move.b 2(a0,d5),d0
	bmi .error
	cmp.b #16,d0
	bcc.s .xhdi	;kein SCSI-
	cmp.b #8,d0
	scc scsiflg

.xhdi:	lea faterr,a3
	btst #0,bflags+1(a6)
	beq .error	;12-Bit-FAT-

	move fsiz(a6),d0
	mulu recsiz(a6),d0
	cmp.l #65536,d0
	bcs.s .lenok
	move.l #65536,d0
.lenok:	divu recsiz(a6),d0
	move d5,-(sp)
	move fatrec(a6),-(sp)
	move d0,-(sp)
	pea buffer	;Puffer fÅr FAT
	clr -(sp)
	move #RWABS,-(sp)	;FAT einlesen
	trap #BIOS
	lea 14(sp),sp
	tst.l d0
	bne.s .error

.nodrive:addq #1,d5	;bis zu 32
	cmp #32,d5	;Laufwerke testen
	bne .getdrv
	rts

.error:	moveq #-1,d0
	rts


*Wechselplatte verriegeln
lock_drv:
	move _lock(pc),d0	;Medium verriegeln?
	beq .noxhdi	;nein-
	tst.l xhdipnt	;XHDI aktiv?
	beq .noxhdi	;nein-
	cmp.l #$27011992,([xhdipnt],-4)
	bne .noxhdi

	clr.l -(sp)
	pea flags
	clr.l -(sp)
	move minor,-(sp)
	move major,-(sp)
	move #XHInqTarget,-(sp)
	jsr ([xhdipnt])
	lea 18(sp),sp
	tst d0
	bmi.s .noxhdi
	btst #2,flags+3	;kann GerÑt verriegelt werden?
	beq .noxhdi	;nein-
	tst.l flags
	bmi.s .noxhdi	;GerÑt reserviert-

	clr -(sp)	;Dummy-Key
	move #1,-(sp)	;GerÑt reservieren
	move minor,-(sp)	;GerÑt
	move major,-(sp)	;Target
	move #XHReserve,-(sp)
	jsr ([xhdipnt])
	lea 10(sp),sp
	cmp #EACCDN,d0
	beq.s .noxhdi
	move d0,key

	move d0,-(sp)	;Key
	move #1,-(sp)	;Cartridge verriegeln
	move minor,-(sp)
	move major,-(sp)
	move #XHLock,-(sp)
	jsr ([xhdipnt])
	lea 10(sp),sp

.noxhdi:	rts


*Sektortabelle aufbauen
init_sec:
	move.l page,d6
	divu _recsiz,d6
	ext.l d6
	bne *+2
	moveq #1,d6
	move d6,secpage	;Sektoren pro Page
	lea buffer+4,a4
	move.l sectab,a5
	move _method(pc),d0	;Speichermaximum?
	beq.s .nomax	;nein-

	move.l ttsize(pc),d0
	divu.l page,d0
	asl.l #2,d0
	add.l d0,a5	;keine TabelleneintrÑge fÅr vorhandenes RAM

.nomax:	moveq #2,d7	;zÑhlt Cluster
.alloc:	move.l d7,d0
	moveq #0,d3	;zÑhlt Datenbytes
.init:	cmp _numcl,d7
	bcc.s .end	;letzter	Cluster erreicht-
	addq #1,d7

	tst (a4)+	;Cluster	belegt oder defekt?
	bne .alloc	;ja-

.useswp:	add _clsizb,d3
	cmp _page(pc),d3	;eine volle Page?
	bcs .init	;nein-

	divu _page(pc),d3	;Zahl der Pages pro Cluster
	subq #1,d3

	subq.l #2,d0
	mulu _clsiz,d0
	add.l _datrec-2,d0	;aktueller Datensektor
.tab0:	tst.b secflg
	beq.s .notab0
	move.l d0,(a5)	;Sektortabelle aufbauen
.notab0:	addq.l #4,a5
	tst.b secflg
	beq.s .ctab	;noch nicht aufbauen-
	cmp.l tabend,a5	;Tabellenende?
	bcc.s .end	;nein-
.ctab:	add.l d6,d0
	dbra d3,.tab0
	bra .alloc

.end:	move _method(pc),d1	;inklusive TT-RAM?
	beq.s .ttplus3	;nein-
	move.l -(a5),specsec	;Ersatzsektoren fÅr eine Page
.ttplus3:move.l a5,d1
	sub.l sectab,d1
	lsr.l #2,d1
	mulu.l page,d1	;ergibt gesamten virtuellen Speicher
	lea caperr,a3
	cmp.l ttsize(pc),d1
	bcs.s .error
	lea conferr,a3
	moveq #0,d0

	move _size(pc),d0	;vorgegebene Speichergrîûe
	beq.s .error
	cmp #497,d0
	bcs.s .no512
	move #496,d0
.no512:	mulu.l #$100000,d0
	cmp.l ttsize(pc),d0
	beq.s .error
	bcs.s .error

	cmp.l d0,d1
	bcs *+2	;Speichergrîûe OK-
	move.l d0,d1
	move.l d1,ramsize	;Gesamtgrîûe des virtuellen Speichers
	add.l #$fffff,d1
	divu.l #$100000,d1
	move.l d1,mbsize	;Zahl der Blîcke zu 1 MByte
	st secflg	;beim nÑchsten Durchlauf aufbauen

	moveq #0,d0
	rts
.error:	moveq #-1,d0
	rts


*Cookies	auswerten
get_cookies:
	move.l ([_sysbase],8),a0
	move $1c(a0),d0
	lsr #1,d0
	cmp #7,d0	;SWF?
	bne *+2
	moveq #2,d0	;FRA
	cmp #8,d0	;SWG?
	bne *+2
	moveq #1,d0	;FRG
	cmp #3,d0
	bcs *+2
	clr d0	;sonst UK
	move d0,country

	move.l _p_cookies,d0
	beq .endjar	;kein cookie jar-
	move.l d0,a0
.nocpu:	movem.l (a0)+,d0-d1
	tst.l d0
	beq .endjar	;Ende des cookie jar-
	cmp.l #"XFRB",d0
	bne.s .noxfrb
	st xfrbflg
	bra .nocpu
.noxfrb:	cmp.l #"MagX",d0
	bne.s .nomag
	move.l _sysbase,a1
	move.l 20(a1),a1	;Zeiger auf GEM-Parameterblock
	cmp.l #$87654321,(a1)
	bne.s .nomag
	cmp.l #"MAGX",12(a1)
	bne.s .nomag
	cmp #$0200,48(a1)
	scc magicflg
	bra .nocpu
.nomag:	cmp.l #"PMMU",d0
	bne.s .nommu
.smtt:	st mmuflg
	bra .nocpu
.nommu:	cmp.l #"SMTT",d0
	beq .smtt
	cmp.l #"XHDI",d0
	bne.s .noxhdi
	move.l d1,xhdipnt
	bra .nocpu
.noxhdi:	cmp.l #"_AKP",d0
	bne.s .noakp
	lsr #8,d1
	cmp #7,d1	;SWF?
	bne *+2
	moveq #2,d1	;FRA
	cmp #8,d1	;SWG?
	bne *+2
	moveq #1,d1	;FRG
	cmp #3,d1
	bcs *+2
	clr d1	;sonst UK
	move d1,country
	bra .nocpu
.noakp:	cmp.l #"_MCH",d0
	bne.s .nomch
	swap d1
	subq #3,d1
	seq falcflg
	bra .nocpu
.nomch:	cmp.l #"_CPU",d0
	bne .nocpu
	cmp #30,d1	;68030?
	seq cpuflg
	bra .nocpu
.endjar:	rts


add_cookies:
	move.l _p_cookies,a0
.loop:	movem.l (a0)+,d0-d1
	tst.l d0
	bne .loop
	move.l a0,d2
	sub.l _p_cookies,d2
	lsr.l #3,d2	;ergibt Zahl der cookies bisher
	addq.l #2,d2	;zwei cookies fÅr OUTSIDE
	tst.l rombuf
	beq *+2	;keine ROM-Kopie-
	addq.l #1,d2
	tst.b xfrbflg
	bne.s .xfrb	;XFRB bereits vorhanden-
	tst _xfrb
	beq *+2	;kein XFRB-
	addq.l #1,d2
.xfrb:	cmp.l d1,d2	;cookie jar voll?
	bcs.s .nofull	;nein-

	addq.l #8,d2	;8 weitere cookies
	asl.l #3,d2
	clr -(sp)	;ST-RAM
	move.l d2,-(sp)
	move #MXALLOC,-(sp)
	trap #GEMDOS
	addq.l #8,sp
	tst.l d0
	beq.s .err
	move.l _p_cookies,a1
	move.l d0,a0
	move.l d0,a2
.copy:	movem.l (a1)+,d0-d1
	movem.l d0-d1,(a0)
	addq.l #8,a0
	tst.l d0
	bne .copy
	move.l a2,_p_cookies

.nofull:	subq.l #8,a0
	move.l #"PMMU",(a0)+
	move.l #pmmu,(a0)+	;PMMU-Handler
	move.l #magic,(a0)+
	move.l #cookie,(a0)+
	move.l rombuf(pc),d2
	beq.s .nousrs
	move.l #"USRS",(a0)+
	move.l #rombuf-4,(a0)+
.nousrs:	tst.b xfrbflg
	bne.s .noxfrb
	move _xfrb(pc),d2
	beq.s .noxfrb
	move.l #"XFRB",(a0)+
	move.l #xfrb,(a0)+	
.noxfrb:	movem.l d0-d1,(a0)
.err:	rts

_aes:
	lea contrl,a0
	move d0,(a0)
	movep.l d1,3(a0)
	move.l #aespb,d1
	move #$c8,d0
	trap #2
	rts

_vdi:
	lea contrl,a0
	move d0,(a0)
	move d5,12(a0)
	move.l #vdipb,d1
	moveq #$73,d0
	trap #2
	rts

pmmu:
	link a6,#0
	movem.l a0-a5/d1-d7,-(sp)
	move d0,d1
	moveq #-1,d0
	move sr,d2
	btst #13,d2	;Supervisor-Modus?
	beq pmmuret	;nein-
	cmp #7,d1	;korrekte Funktionsnummer?
	bcc pmmuret	;nein-
	jsr ([pmmutab,d1*4])
pmmuret:	movem.l (sp)+,a0-a5/d1-d7
	unlk a6
	rts

PMMUVersion:
	ifd DEBUG
	lea _pmmu0,a0
	move.l #$0101,d0
	bsr auxout
	endif

	move #$0101,d0	;Versionsnummer
	rts

SetPageMode:

.flags	= 8
.start	= 12
.length	= 16

	ifd DEBUG
	lea _pmmu1,a0
	move.l .start(a6),d0
	bsr auxout
	lea _pmmul,a0
	move.l .length(a6),d0
	bsr auxout
	lea _pmmum,a0
	move.l .flags(a6),d0
	bsr auxout
	endif

	move.l .flags(a6),d0	;Modus
	move.l .start(a6),a1	;Startadresse
	move.l a1,d2
	sub.l base,d2	;Offset zum Beginn des virtuellen RAM
	bcs .err
	move.l .length(a6),d1	;BereichslÑnge
	beq .ret
	add.l d1,d2	;relative Endadresse
	cmp.l ramsize(pc),d2
	ble.s .cont
	move.l ramsize(pc),d1
.cont:	move.l a1,d2
	and mask,d2
	move.l d2,a1
	add.l page,d1
	subq.l #1,d1
	and mask,d1
.loop:	ptestr #7,(a1),#7,a0
	btst #0,d0
	beq.s .nolock
	bset #LOCKED,2(a0)
	tst.b (a1)	;Seite bei Bedarf nachladen
.nolock:	btst #1,d0
	beq.s .nowp
	bset #2,3(a0)
.nowp:	btst #2,d0
	beq.s .noused
	bset #3,3(a0)
.noused:	btst #3,d0
	beq.s .nomod
	bset #4,3(a0)
.nomod:	btst #4,d0
	beq.s .nocache
	bset #6,3(a0)
.nocache:tst.l d0
	bpl.s .nomag
	bset #MLOCKED,2(a0)
.nomag:	add.l page,a1
	sub.l page,d1
	bne .loop
.ret:	moveq #0,d0
.err:	rts

ClearPageMode:

.flags	= 8
.start	= 12
.length	= 16

	ifd DEBUG
	lea _pmmu2,a0
	move.l .start(a6),d0
	bsr auxout
	lea _pmmul,a0
	move.l .length(a6),d0
	bsr auxout
	lea _pmmum,a0
	move.l .flags(a6),d0
	bsr auxout
	endif

	move.l .flags(a6),d0	;Modus
	move.l .start(a6),d2	;Startadresse
	move.l a1,d2
	sub.l base,d2	;Offset zu Beginn des virtuellen RAM
	bcs .err
	move.l .length(a6),d1	;BereichslÑnge
	beq.s .ret
	add.l d1,d2	;relative Endadresse
	cmp.l ramsize(pc),d2
	ble.s .cont
	move.l ramsize(pc),d1
.cont:	move.l a1,d2
	and mask,d2
	move.l d2,a1
	add.l page,d1
	subq.l #1,d1
	and mask,d1
.loop:	ptestr #7,(a1),#7,a0
	btst #0,d0
	beq.s .nolock
	bclr #LOCKED,2(a0)
.nolock:	btst #1,d0
	beq.s .nowp
	bclr #2,3(a0)
.nowp:	btst #2,d0
	beq.s .noused
	bclr #3,3(a0)
.noused:	btst #3,d0
	beq.s .nomod
	bclr #4,3(a0)
.nomod:	btst #4,d0
	beq.s .nocache
	bclr #6,3(a0)
.nocache:tst.l d0
	bpl.s .nomag
	bclr #MLOCKED,2(a0)
.nomag:	add.l page,a1
	sub.l page,d1
	bne .loop
.ret:	moveq #0,d0
.err:	rts

GetPageSize:
	ifd DEBUG
	move.l page,d0
	lea _pmmu3,a0
	bsr auxout
	endif

	move.l page,d0
	rts

GetHdvInUse:
	ifd DEBUG
	move.l #status,d0
	lea _pmmu4,a0
	bsr auxout
	endif

	move.l #status,d0
	rts

pmmu5:
	ifd DEBUG
	move.l ramsize(pc),d0
	lea _pmmu5,a0
	bsr auxout
	endif

	move.l ramsize(pc),d0
	rts

pmmu6:
	ifd DEBUG
	move.l ttsize(pc),d0
	lea _pmmu6,a0
	bsr auxout
	endif

	move.l ttsize(pc),d0
	rts      


	data

base:	dc.l $01000000	;Basisadresse des virtuellen RAM

pmmutab:	dc.l PMMUVersion
	dc.l SetPageMode
	dc.l ClearPageMode
	dc.l GetPageSize
	dc.l GetHdvInUse
	dc.l pmmu5
	dc.l pmmu6

message:	dc.l message2,message1,message3
mmuerr:	dc.l mmuerr2,mmuerr1,mmuerr3
ign:	dc.l ign2,ign1,ign3
cpuerr:	dc.l cpuerr2,cpuerr1,cpuerr3
ramerr:	dc.l ramerr2,ramerr1,ramerr3
caperr:	dc.l caperr2,caperr1,caperr3
gemerr:	dc.l gemerr2,gemerr1,gemerr3
drverr:	dc.l drverr2,drverr1,drverr3
conferr:	dc.l conferr2,conferr1,conferr3
faterr:	dc.l faterr2,faterr1,faterr3
comperr:	dc.l comperr2,comperr1,comperr3
inserr:	dc.l inserr2,inserr1,inserr3
readerr:	dc.l readerr2,readerr1,readerr3
wrterr:	dc.l wrterr2,wrterr1,wrterr3
rsec:	dc.l rsec2,rsec1,rsec3
wsec:	dc.l wsec2,wsec1,wsec3
blit:	dc.l blit2,blit1,blit3
wait:	dc.l wait2,wait1,wait3

aespb::	dc.l contrl,global,intin,intout,addrin,addrout

vdipb::	dc.l contrl,intin,ptsin,intout,ptsout

	dc.l version
rombuf:	dc.l 0	;zeigt auf Puffer fÅr ROM-Kopie

secpage:	dc.w 0	;Sektoren pro Page

rflags:	dc.w 18	;RWABS-Modus fÅr Lesen

wflags:	dc.w 19	;RWABS-Modus fÅr Schreiben

xfrb:	dc.w xfrbver	;XFRB-Version
	dc.l xflock	;xflock
xfrbpnt:	dc.l 0	;Pufferadresse
	dc.l 65536	;Puffergrîûe
	dc.l 0	;Pointer auf nÑchsten Puffer
xflock:	dc.b 0


	even

message1:dc.b $0d,$0a,$1b,"pVirtuelle Speicherverwaltung OUTSIDE V"
         dc.l version
         dc.b " installiert",$1b,"q",$0d,$0a
         dc.b "Ω 1991-2000 Uwe Seimet",$0d,$0a
         dc.b "Virtuelles RAM auf Laufwerk "
virdrv1: dc.b "X: "
virram1: dc.b "    MByte",$0d,$0a,0

         even

message2:dc.b $0d,$0a,$1b,"pVirtual memory manager OUTSIDE V"
         dc.l version
         dc.b " installed",$1b,"q",$0d,$0a
         dc.b "Ω 1991-2000 Uwe Seimet",$0d,$0a
         dc.b "Virtual RAM on drive "
virdrv2: dc.b "X: "
virram2: dc.b "    MByte",$0d,$0a,0

         even

	dc.b 0
message3:dc.b $0d,$0a,$1b,"pGestion de la mÇmoire virtuelle OUTSIDE V"
         dc.l version
         dc.b " installÇ",$1b,"q",$0d,$0a
         dc.b "Ω 1991-2000 Uwe Seimet",$0d,$0a
         dc.b "RAM virtuelle sur lecteur "
virdrv3: dc.b "X: "
virram3: dc.b "    Moctets",$0d,$0a,0


*Diverse Fehlermeldungen

ign1:	dc.b $0d,$0a,"Installation von OUTSIDE abbrechen?",0
ign2:	dc.b $0d,$0a,"Stop installation of OUTSIDE?",0
ign3:	dc.b $0d,$0a,"Stopper installation d'OUTSIDE?",0

cpuerr1:	dc.b $0d,$0a,"OUTSIDE benîtigt eine 68030 CPU!",0
cpuerr2:	dc.b $0d,$0a,"OUTSIDE requires a 68030 CPU!",0
cpuerr3:	dc.b $0d,$0a,"OUTSIDE a besoin d'un CPU 68030!",0

ramerr1:	dc.b $0d,$0a,"Nicht genug ST-kompatibler Speicher!",0
ramerr2:	dc.b $0d,$0a,"Not enough ST compatible memory!",0
ramerr3:	dc.b $0d,$0a,"Pas assez de mÇmoire compatible ST!",0

gemerr1: dc.b $0d,$0a,"Falsche GEMDOS-Version!",0
gemerr2: dc.b $0d,$0a,"Wrong GEMDOS version!",0
gemerr3: dc.b $0d,$0a,"Mauvaise version GEMDOS!",0

drverr1: dc.b $0d,$0a,"UngÅltiges Swap-Laufwerk!",0
drverr2: dc.b $0d,$0a,"Illegal swap drive!",0
drverr3: dc.b $0d,$0a,"Lecteur swap non valable!",0

conferr1:dc.b $0d,$0a,"Fehlerhafte Konfiguration!",0
conferr2:dc.b $0d,$0a,"Bad configuration!",0
conferr3:dc.b $0d,$0a,"Configuration incorrecte!",0

caperr1:	dc.b $0d,$0a,"Zu geringe freie PlattenkapazitÑt!",0
caperr2:	dc.b $0d,$0a,"Not enough free disk space!",0
caperr3:	dc.b $0d,$0a,"Pas assez de capacitÇ du disc libre!",0

faterr1: dc.b $0d,$0a,"Fehler beim Lesen der FAT!",0
faterr2: dc.b $0d,$0a,"Couldn't read FAT!",0
faterr3: dc.b $0d,$0a,"Erreur lors de la lecture du FAT!",0

mmuerr1: dc.b $0d,$0a,"Es ist bereits ein PMMU-Programm aktiv!",0
mmuerr2: dc.b $0d,$0a,"PMMU already in use!",0
mmuerr3: dc.b $0d,$0a,"Un programme PMMU est dÇjÖ active!",0

comperr1:dc.b $0d,$0a,"Kein KompatibilitÑtsmodus mîglich!",0
comperr2:dc.b $0d,$0a,"Compatibility mode not possible!",0
comperr3:dc.b $0d,$0a,"Aucun mode de compatibilitÇ possible!",0

blit1:	dc.b $0d,$0a,27,"EIllegaler Blitter-Transfer!",0
blit2:	dc.b $0d,$0a,27,"EIllegal blitter transfer!",0
blit3:	dc.b $0d,$0a,27,"ETransfer-blitter illÇgal!",0

wait1:   dc.b $0d,$0a,"Kaltstart nach Tastendruck ...",7,0
wait2:   dc.b $0d,$0a,"Press any key to reboot ...",7,0
wait3:   dc.b $0d,$0a,"Reset Ö froid apräs appui sur touche ...",7,0

readerr1:dc.b 27,"ELesefehler bei Sektor "
rsec1:   dc.b "000000",0
readerr2:dc.b 27,"EError reading sector "
rsec2:   dc.b "000000",0
readerr3:dc.b 27,"EErreur de lecture au secteur "
rsec3:   dc.b "000000",0

wrterr1: dc.b 27,"ESchreibfehler bei Sektor "
wsec1:   dc.b "000000",0
wrterr2: dc.b 27,"EError writing sector "
wsec2:   dc.b "000000",0
wrterr3: dc.b 27,"EErreur de l'Çcriture au secteur "
wsec3:   dc.b "000000",0

         even

	dc.b 0
inserr1: dc.b $0d,$0a,"OUTSIDE V"
         dc.l version
         dc.b " nicht installiert!",$0d,$0a,0

	even

	dc.b 0
inserr2: dc.b $0d,$0a,"OUTSIDE V"
         dc.l version
         dc.b " not installed!",$0d,$0a,0

	even

	dc.b 0
inserr3: dc.b $0d,$0a,"OUTSIDE V"
         dc.l version
         dc.b " pas installÇe!",$0d,$0a,0


infname:	dc.b "c:\outside.inf",0


	ifd DEBUG
_init1:	dc.b $0d,$0a,$0a,"Programmstart: $",0
_init2:	dc.b $0d,$0a,"ProgrammlÑnge: $",0
_buserr:	dc.b $0d,$0a,"Busfehler: $",0
_status:	dc.b ", SSR: $",0
_pc:	dc.b ", PC: $",0
_desadr:	dc.b $0d,$0a,"TT-Tabellen: $",0
_pageadr:dc.b ", TT-Seiten: $",0
_stadr:	dc.b ", ST-Tabellen: $",0
_test:	dc.b $0d,$0a,"PrÅfen von log. $",0
_oldadr:	dc.b $0d,$0a,"Auslagern von phys. $",0
_lockadr:dc.b $0d,$0a,"Locken ab: $",0
_physadr:dc.b " = $",0
_pmmu0:	dc.b $0d,$0a,"PMMUversion: $",0
_pmmu1:	dc.b $0d,$0a,"SetPageMode: Start $",0
_pmmu2:	dc.b $0d,$0a,"ClearPageMode: Start $",0
_pmmu3:	dc.b $0d,$0a,"GetPageSize: $",0
_pmmu4:	dc.b $0d,$0a,"GetHdvInUse: $",0
_pmmu5:	dc.b $0d,$0a,"vmem_size: $",0
_pmmu6:	dc.b $0d,$0a,"pmem_size: $",0
_pmmul:	dc.b ", LÑnge $",0
_pmmum:	dc.b ", Flags $",0
_act:	dc.b $0d,$0a,0
_mbase:	dc.b $0d,$0a,"MagiC-Start: $",0
_mend:	dc.b ", MagiC-Ende: $",0
_vram:	dc.b $0d,$0a,"Virtuelles RAM ab: $",0
_read:	dc.b $0d,$0a,"Lesen von Sektor: $",0
_write:	dc.b $0d,$0a,"Schreiben von Sektor: $",0
_crp:	dc.b $0d,$0a,"CRP: $",0
_vbl:	dc.b $0d,$0a,"Teste VBL Vektoren",0
_auto:	dc.b $0d,$0a,"Teste Autovektoren",0
_mfp1:	dc.b $0d,$0a,"Teste MFP1-Vektoren",0
_mfp2:	dc.b $0d,$0a,"Teste MFP2-Vektoren",0
_ikbd:	dc.b $0d,$0a,"Teste IKBD-Vektoren",0
_etv:	dc.b $0d,$0a,"Teste etv-Vektoren",0
_color:	dc.b $0d,$0a,"Teste colptr",0
_kbdv:	dc.b $0d,$0a,"Teste kbdv-Vektoren",0
_ok:	dc.b ", OK",0
	endif


	bss

vectors:	ds.b 1024+15	;Exception-Vektoren

newtab:	ds.b 256	;neue Basis-Deskriptoren
	ds.b 64	;Bereich fÅr die zweiten 256 MByte
	ds.b 15

	align.l

dtable:	ds.l 1	;Ringpuffer fÅr physikalisches RAM
ldtable:	ds.l 1	;Grîûe

nxtadr:	ds.l 1	;zeigt auf nÑchsten Page-Kandidaten

newadr:	ds.l 1	;Start der Basisdeskriptoren

destable:ds.l 1	;Start der Deskriptortabellen
ldestable:ds.l 1	;Grîûe

sttab:	ds.l 1	;Seiten-Deskriptoren fÅr ST-RAM
lsttab:	ds.l 1	;Grîûe

sectab:	ds.l 1	;Start der Sektortabelle
tabend:	ds.l 1	;Ende der Sektortabelle
lsectab:	ds.l 1	;LÑnge

oldbus:	ds.l 1	;Pointer auf Busfehler-Vektor

kbdvbase:ds.l 1

specsec:	ds.l 1	;Ersatzsektoren-Nummer

prglen:	ds.l 1	;ProgrammlÑnge

tt0reg:	ds.l 1

xhdipnt:	ds.l 1	;zeigt auf Routine fÅr MEDIA REMOVAL

psrcmfdb:ds.l 1

pdesmfdb:ds.l 1

srcdata:	ds.l 5

dstdata:	ds.l 5

stbuf:	ds.l 1	;Anfangsadresse des phys. RAM

srcbuf:	ds.l 1	;Blitterpuffer fÅr Source

flopbuf:	ds.l 1	;Floppypuffer fÅr XBIOS

romlen:	ds.l 1

page:	ds.l 1

tcr:	ds.l 1	;fÅr TCR

crpr:	ds.l 2	;fÅr CRP

flags:	ds.l 1

mbsize:	ds.l 1	;Zahl der Blîcke zu 1 MByte

sys_rw:	ds.l 1	;Vektor fÅr Direkteinsprung in Treiber

blocksize:ds.l 1

infbuf:	ds.l 1

mask:	ds.w 1

secs:	ds.w 32	;Sektoren pro DMA-Puffer

seclens:	ds.w 32	;Sektorgrîûen

status:	ds.w 1	;Auslagerungs-Status

major:	ds.w 1

minor:	ds.w 1

maxipl:	ds.w 1

_recsiz:	ds.w 1
_clsiz:	ds.w 1
_clsizb:	ds.w 1
	ds.w 1	;zur Erweiterung von _datrec auf Langwort
_datrec:	ds.w 1
_numcl:	ds.w 1

country:	ds.w 1            	;Sprachcode

empty:	ds.b 1

scsiflg:	ds.b 1

falcflg:	ds.b 1	;Flag fÅr Falcon

mmuflg:	ds.b 1

xfrbflg:	ds.b 1	;Flag fÅr XFRB

magicflg:ds.b 1	;Flag fÅr MagiC

cpuflg:	ds.b 1

blitflg:	ds.b 1

iplflg:	ds.b 1            	;Flag fÅr IPL6 bei XHDI-Treiber

secflg:	ds.b 1

gemflg:	ds.b 1

	align.l

partid:	ds.b 4
pstart:	ds.l 1
plen:	ds.l 1

buffer:	ds.b 65536

vdipar:	ds.l 5

intin:	ds.w 64 

intout:	ds.w 64
 
contrl:	ds.w 11 

global:	ds.w 15
 
ptsin:	ds.w 32
 
ptsout:	ds.w 32

addrin:	ds.l 16
 
addrout:	ds.l 16

stack:	ds.l 100	;muss als letztes stehen, wegen Locking