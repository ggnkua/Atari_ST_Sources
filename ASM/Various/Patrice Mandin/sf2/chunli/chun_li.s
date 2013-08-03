; ------------------------------
;	Chun li
; ------------------------------
;	85 sprites

	output	e:\patrice\sf2\chunli.prg

base_sautopp_y	equ	100
base_y	equ	187

lowpunchb	equ	0
midpunchb	equ	4
higpunchb	equ	8
lowkickb	equ	12
midkickb	equ	16
higkickb	equ	20

; ----------------------------------
;	Macros
; ----------------------------------

SEQUENCE	macro	joueur,seq,spr
	IFEQ	NARG-3
	move.l	\2,seq_cur\1
	move.l	\3,seq_spr\1
	ELSE
	move.l	\1,seq_cur(a6)
	move.l	\2,seq_spr(a6)
	ENDC
	endm

SEQUENCE2	macro	joueur,seq,spr
	IFEQ	NARG-3
	move.l	\2,seq_cur2\1
	move.l	\3,seq_spr2\1
	ELSE
	move.l	\1,seq_cur2(a6)
	move.l	\2,seq_spr2(a6)
	ENDC
	endm

SAMPLE	macro	nom_spl
	move.l	#snd_\1+128,snd_adr(a6)
	move.l	#snde_\1-snd_\1-128,snd_res(a6)
	endm

; ----------------------------------
;	Initialisations
; ----------------------------------

	dc.l	vbl_debout	; premiere routine
	dc.l	debout_rien	; sprites de cette routine
	dc.l	adr_sprites	; adresse des sprites

; ----------------------------------
;	Gestion perso
; ----------------------------------

	include	pdebout.s
	include	pchange.s	
	include	pmarche.s
	include	pbaisse.s
	include	preleve.s
	include	psauth.s
	include	psautav.s
	include	psautar.s
	include	psautop.s

; ----------------------------------
;	Coups
; ----------------------------------

	include	cdebout.s
	include	cbas.s
	include	csauth.s
	include	csautdg.s
	include	csautop.s
	include	cwhirl.s
	
; ----------------------------------
;	Impacts
; ----------------------------------

	include	idebout.s
	include	isin.s

; ----------------------------------
;	Protection
; ----------------------------------
	
	include	protect.s

; ----------------------------------
;	Fin de la gestion
; ----------------------------------
	nop

finjoueur	rts
		
; ---------------------------------------------------------
;	S‚quences : sprite … afficher
;		80000000 symetrique oui/non
;		40000000 fauchage bas
;		20000000 frappe debout milieu
;		10000000 frappe debout haut
;		08000000 prise
;		00FF0000 nb de vbls
;		0000FF00 pos rel x
;		000000FF pos rel y
;	si 0 alors retour d‚but s‚quence
; ---------------------------------------------------------

; -- Debout

debout_rien	dc.l	s00,$000e0000,s01,$000c0000,s02,$000c0000
	dc.l	s01,$000c0000,0

chg_cote_debout	dc.l	s12,$00030000,0

marche	dc.l	s03,$00050000,s04,$00050000,s05,$00050000
	dc.l	s06,$00050000,s07,$00050000,s06,$00050000
	dc.l	s05,$00050000,s04,$00050000,0

baisse	dc.l	s0a,$00040000,s0b,$00040100,0

chg_cote_bas	dc.l	s49,$00030000,0

releve	dc.l	s0b,$00040100,s0a,$00040000,0

; -- Sauts

fin_de_saut	dc.l	s0a,$00020000,0

saute_haut	dc.l	s0a,$00030000,s08,$000e0000,s09,$001000e0
	dc.l	s08,$000e0000,s0a,$00020000,0

saute_avant	dc.l	s0a,$00030000,s08,$00040000,s0c,$000500f8
	dc.l	s11,$000700e0,s0e,$800a00e0,s0d,$000700e0
	dc.l	s0f,$000610f0,s08,$00050000,s0a,$00020000,0

saute_arriere	dc.l	s0a,$00030000,s08,$00040000,s0f,$000500f0
	dc.l	s0d,$000700e0,s0e,$800a00e0,s11,$000700e0
	dc.l	s0c,$000600f8,s08,$00040000,s0a,$00020000,0

saute_oppose	dc.l	s10,$80020000,s08,$00040000,s0c,$000500f8
	dc.l	s11,$000800e0,s0e,$800800e0,s0d,$000700e0
	dc.l	s0f,$000600f0,s08,$00030000,s0a,$00020000,0

; ----------------------------------
;	Coups
; ----------------------------------

; -- debout

lowpunch	dc.l	s2a,$10040800,s2b,$10040400,s2a,$10040800,0
midpunch	dc.l	s2c,$00060800,s2d,$20061001,s2c,$00060800,0
higpunch	dc.l	s2e,$00080800,s2f,$10080e02,s2e,$00080800,0
lowkick	dc.l	s30,$0004fe00,s20,$00040100,s21,$20051400
	dc.l	s20,$00040100,s30,$0004fe00,0
midkick	dc.l	s30,$0006fe00,s20,$00060100,s22,$10070800
	dc.l	s20,$00060100,s30,$0006fe00,0
higkick	dc.l	s23,$00080600,s24,$10080f00,s25,$00080800
	dc.l	s26,$00080000,0

; -- bas

lowpunchdown	dc.l	s13,$00040400,s14,$20041200,s13,$00040400,0
midpunchdown	dc.l	s13,$00060400,s14,$20061200,s13,$00060400,0
higpunchdown	dc.l	s13,$00080400,s14,$20081200,s13,$00080400,0
lowkickdown	dc.l	s15,$00040400,s16,$20041400,s15,$00040400,0
midkickdown	dc.l	s17,$00061500,s18,$20062300,s19,$00061a00,0
higkickdown	dc.l	s1a,$00080100,s1b,$40081100,s1a,$00080100,0
	
; -- saut haut

lowpunchhaut	dc.l	s1e,$000400ea,s1f,$103009f0,0
midpunchhaut	dc.l	s1e,$000400ea,s1f,$101809f0,0
higpunchhaut	dc.l	s1e,$000400ea,s1f,$100e09f0,0
lowkickhaut	dc.l	s27,$000400f4,s28,$100408f8,s29,$102800f8
	dc.l	s28,$100408f8,s27,$000400f4,0
midkickhaut	dc.l	s27,$000400f4,s28,$100508f8,s29,$101a00f8
	dc.l	s28,$100508f8,s27,$000400f4,0
higkickhaut	dc.l	s33,$10060af2,s34,$100618b0,s0e,$800600b0
	dc.l	s11,$0006f0b0,s0c,$0006f0e0,0
midkicktodownh	dc.l	s1c,$1040fcfa,0
	
; -- saut diag

lowpunchdg	dc.l	s1e,$000400f0,s1f,$102808f0,0
midpunchdg	dc.l	s1e,$000400f0,s1f,$101c08f0,s09,$000800f0
	dc.l	s08,$00180010,0
higpunchdg	dc.l	s1e,$000400f0,s1f,$100c08f0,s09,$000800f0
	dc.l	s08,$00200010,0
lowkickdg	dc.l	s1d,$102800e8,s1a,$000800e8,0
midkickdg	dc.l	s1d,$101c00e8,s1a,$000600e8,s09,$000600e8
	dc.l	s08,$002000f8,0
higkickdg	dc.l	s27,$000400f4,s28,$100508f8,s29,$100600f8
	dc.l	s28,$100508f8,s27,$000400f4,s31,$100508fc
	dc.l	s32,$10060000,s31,$100508fc,s27,$00040000,0
midkicktodowndg	dc.l	s1c,$10400000,0

; -- speedkick

lowspeedkick	dc.l	s39,$1003fc00,s3a,$10030000,s3b,$2003ff00
	dc.l	s3c,$2003ff00,s3d,$20030000,s3e,$20030200
	dc.l	s3f,$2003fa00,s3c,$2003ff00,0
midspeedkick	dc.l	s39,$1002fc00,s3a,$10020000,s3b,$0002ff00
	dc.l	s3c,$2002ff00,s3d,$20020000,s3e,$00020200
	dc.l	s3f,$2002fa00,s3c,$2002ff00,0
higspeedkick	dc.l	s39,$1001fc00,s3a,$10010000,s3b,$2001ff00
	dc.l	s3c,$2001ff00,s3d,$20010000,s3e,$20010200
	dc.l	s3f,$2001fa00,s3c,$2001ff00
	dc.l	s39,$1001fc00,s3a,$10010000,s3b,$2001ff00
	dc.l	s3c,$2001ff00,s3d,$20010000,s3e,$20010200
	dc.l	s3f,$2001fa00,s3c,$2001ff00,0

; -- whirlwind

lowwhirlwind	dc.l	s0c,$00080000,s0d,$800800e8,s0e,$800810f0
	dc.l	s35,$80081000,s0e,$800810f0,s38,$000810ec
	dc.l	s36,$900810ec,s37,$000710ec,s36,$100610ec
	dc.l	s38,$000510ec,s36,$900410ec,s37,$000510ec
	dc.l	s36,$100610ec,s38,$000710ec,s36,$900810ec
	dc.l	s37,$000810ec,s0e,$800810f0,s35,$80081000
	dc.l	s0e,$800810f0,s0d,$800800e8,s0c,$00080000,0

midwhirlwind	dc.l	s0c,$00080000,s0d,$800800e8,s0e,$800810f0
	dc.l	s35,$80081000,s0e,$800810f0,s38,$000810ec
	dc.l	s36,$900810ec,s37,$000710ec,s36,$100610ec
	dc.l	s38,$000510ec,s36,$900410ec,s37,$000410ec
	dc.l	s36,$100410ec,s38,$000410ec,s36,$900410ec
	dc.l	s37,$000410ec,s36,$100410ec,s38,$000410ec
	dc.l	s36,$900410ec,s37,$000510ec,s36,$100610ec
	dc.l	s38,$000710ec,s36,$900810ec,s37,$000810ec
	dc.l	s0e,$800810f0,s35,$80081000,s0e,$800810f0
	dc.l	s0d,$800800e8,s0c,$00080000,0

higwhirlwind	dc.l	s0c,$00080000,s0d,$800800e8,s0e,$800810f0
	dc.l	s35,$80081000,s0e,$800810f0,s38,$000810ec
	dc.l	s36,$900810ec,s37,$000710ec,s36,$100610ec
	dc.l	s38,$000510ec,s36,$900410ec,s37,$000410ec
	dc.l	s36,$100410ec,s38,$000410ec,s36,$900410ec
	dc.l	s37,$000410ec,s36,$100410ec,s38,$000410ec
	dc.l	s36,$900410ec,s37,$000410ec,s36,$100410ec
	dc.l	s38,$000410ec,s36,$900410ec,s37,$000410ec
	dc.l	s36,$100410ec,s38,$000410ec,s36,$900410ec
	dc.l	s37,$000510ec,s36,$100610ec,s38,$000710ec
	dc.l	s36,$900810ec,s37,$000810ec,s0e,$800810f0
	dc.l	s35,$80081000,s0e,$800810f0,s0d,$800800e8
	dc.l	s0c,$00080000,0

; -- Prise

prise	dc.l	s4c,$08060002,s4d,$08060800,s4e,$08081000
	dc.l	s4d,$08060800,s4c,$08060002,0
	
; -- Pousse

pousse	dc.l	s50,$00060600,s4f,$20080a00,s50,$00060600,0

; ----------------------------------
;	Impacts
; ----------------------------------

imp_debhaut	dc.l	s43,$00040000,s44,$00040000,s45,$00040000
	dc.l	s44,$00040000,s43,$00040000,0
imp_debmilieu	dc.l	s40,$00040000,s41,$00040000,s42,$00040000
	dc.l	s41,$00040000,s40,$00040000,0
imp_bas	dc.l	s46,$00040000,s47,$00040000,s48,$00040000
	dc.l	s47,$00040000,s46,$00040000,0

fauchage	dc.l	s51,$000c0000,s52,$00180000,s53,$000a0804
	dc.l	s54,$00040808,0

imp_deb_prise	dc.l	s43,$000614fc,s0f,$00060800,s53,$00081008
	dc.l	s0f,$00120000,s53,$000e0008,s54,$00080008,0

; ----------------------------------
;	Protection
; ----------------------------------

protection_deb	dc.l	s4a,$00000000,0
protection_bas	dc.l	s4b,$00000000,0

; ----------------------------------
;	Sprite d‚finition
; ----------------------------------
;taille x.W,y.W	( puis x en mots)
;adr.L du masque
;adr.L du symetrique
;adr.L du masque
;taille x.W,y.W (backup)
;donn‚es du sprite
; ----------------------------------

adr_sprites	dc.l	s00,s01,s02,s03,s04,s05,s06,s07
	dc.l	s08,s09,s0a,s0b,s0c,s0d,s0e,s0f
	dc.l	s10,s11,s12,s13,s14,s15,s16,s17
	dc.l	s18,s19,s1a,s1b,s1c,s1d,s1e,s1f
	dc.l	s20,s21,s22,s23,s24,s25,s26,s27
	dc.l	s28,s29,s2a,s2b,s2c,s2d,s2e,s2f
	dc.l	s30,s31,s32,s33,s34,s35,s36,s37
	dc.l	s38,s39,s3a,s3b,s3c,s3d,s3e,s3f
	dc.l	s40,s41,s42,s43,s44,s45,s46,s47
	dc.l	s48,s49,s4a,s4b,s4c,s4d,s4e,s4f
	dc.l	s50,s51,s52,s53,s54
	dc.l	0

; ----------------------------------
;	D‚placements
; ----------------------------------

s00	dc.w	44,75	; rien,43
	ds.l	4
	incbin	spr\00.bin
s01	dc.w	42,76
	ds.l	4
	incbin	spr\01.bin
s02	dc.w	42,77
	ds.l	4
	incbin	spr\02.bin

s03	dc.w	45,72	; marche
	ds.l	4
	incbin	spr\03.bin
s04	dc.w	42,75
	ds.l	4
	incbin	spr\04.bin
s05	dc.w	37,77
	ds.l	4
	incbin	spr\05.bin
s06	dc.w	42,75
	ds.l	4
	incbin	spr\06.bin
s07	dc.w	48,74
	ds.l	4
	incbin	spr\07.bin

s08	dc.w	29,95	; baisse
	ds.l	4
	incbin	spr\08.bin
s09	dc.w	35,58
	ds.l	4
	incbin	spr\09.bin

s0a	dc.w	44,64	; sauts h
	ds.l	4
	incbin	spr\0a.bin
s0b	dc.w	42,58
	ds.l	4
	incbin	spr\0b.bin

s0c	dc.w	52,74	; sauts diag
	ds.l	4	; penche en avant
	incbin	spr\0c.bin	
s0d	dc.w	63,70	; diagonal, tete bas
	ds.l	4
	incbin	spr\0d.bin
s0e	dc.w	31,92	; tete en bas,vertical
	ds.l	4
	incbin	spr\0e.bin
s0f	dc.w	71,63	; horizontal
	ds.l	4
	incbin	spr\0f.bin
s11	dc.w	64,77	; penche avant 2
	ds.l	4
	incbin	spr\11.bin

s10	dc.w	27,54	; chg cote dans saut
	ds.l	4
	incbin	spr\10.bin

s12	dc.w	41,85	; chg cote debout
	ds.l	4
	incbin	spr\12.bin

s49	dc.w	45,57	; chg cote bas
	ds.l	4
	incbin	spr\49.bin

; ----------------------------------
;	Coups
; ----------------------------------

s13	dc.w	50,59	; punch bas
	ds.l	4
	incbin	spr\13.bin
s14	dc.w	73,59
	ds.l	4
	incbin	spr\14.bin
	
s15	dc.w	38,51	; low kick bas
	ds.l	4
	incbin	spr\15.bin
s16	dc.w	62,42
	ds.l	4
	incbin	spr\16.bin
	
s17	dc.w	47,55	; mid kick bas
	ds.l	4
	incbin	spr\17.bin
s18	dc.w	67,44
	ds.l	4
	incbin	spr\18.bin
s19	dc.w	44,54
	ds.l	4
	incbin	spr\19.bin

s1a	dc.w	43,54	; high kick bas
	ds.l	4
	incbin	spr\1a.bin
s1b	dc.w	75,61
	ds.l	4
	incbin	spr\1b.bin
	
s1c	dc.w	38,87	; coup pied vers bas
	ds.l	4
	incbin	spr\1c.bin
s1d	dc.w	65,49	; coup pied saut‚
	ds.l	4
	incbin	spr\1d.bin
s31	dc.w	50,81	; high kick diag
	ds.l	4
	incbin	spr\31.bin
s32	dc.w	37,86
	ds.l	4
	incbin	spr\32.bin

s1e	dc.w	34,80	; punch air
	ds.l	4
	incbin	spr\1e.bin
s1f	dc.w	52,68
	ds.l	4
	incbin	spr\1f.bin

s30	dc.w	40,78	; start kick debout
	ds.l	4
	incbin	spr\30.bin
s20	dc.w	43,82	; kick debout start
	ds.l	4
	incbin	spr\20.bin
s21	dc.w	62,85	; low
	ds.l	4
	incbin	spr\21.bin
s22	dc.w	64,83	; middle
	ds.l	4
	incbin	spr\22.bin
s23	dc.w	42,79	; high
	ds.l	4
	incbin	spr\23.bin
s24	dc.w	72,86
	ds.l	4
	incbin	spr\24.bin
s25	dc.w	60,74
	ds.l	4
	incbin	spr\25.bin
s26	dc.w	41,72
	ds.l	4
	incbin	spr\26.bin

s27	dc.w	36,83	; coup pied haut
	ds.l	4
	incbin	spr\27.bin
s28	dc.w	50,82
	ds.l	4
	incbin	spr\28.bin
s29	dc.w	38,86
	ds.l	4
	incbin	spr\29.bin
s33	dc.w	51,80	; high kick haut
	ds.l	4
	incbin	spr\33.bin
s34	dc.w	65,63
	ds.l	4
	incbin	spr\34.bin

s2a	dc.w	60,78	; coups poings debout low
	ds.l	4
	incbin	spr\2a.bin
s2b	dc.w	51,85
	ds.l	4
	incbin	spr\2b.bin	; medium
s2c	dc.w	60,74
	ds.l	4
	incbin	spr\2c.bin
s2d	dc.w	83,71
	ds.l	4
	incbin	spr\2d.bin	; high
s2e	dc.w	60,74
	ds.l	4
	incbin	spr\2e.bin
s2f	dc.w	76,67
	ds.l	4
	incbin	spr\2f.bin
	
; ----------------------------------
;	Whirlwind kick
; ----------------------------------

s35	dc.w	32,101	; start
	ds.l	4
	incbin	spr\35.bin
s36	dc.w	85,61	; cote
	ds.l	4
	incbin	spr\36.bin
s37	dc.w	31,62	; avant
	ds.l	4
	incbin	spr\37.bin
s38	dc.w	28,60	; arriere
	ds.l	4
	incbin	spr\38.bin

; ----------------------------------
;	Speed kick
; ----------------------------------

s39	dc.w	65,83	; high1
	ds.l	4
	incbin	spr\39.bin
s3a	dc.w	73,86	; high2
	ds.l	4
	incbin	spr\3a.bin
s3b	dc.w	71,81	; low high 1
	ds.l	4
	incbin	spr\3b.bin
s3c	dc.w	73,81	; low high 2 (x72)
	ds.l	4
	incbin	spr\3c.bin
s3d	dc.w	71,83	; mid 1
	ds.l	4
	incbin	spr\3d.bin
s3e	dc.w	77,81	; mid 2
	ds.l	4
	incbin	spr\3e.bin
s3f	dc.w	59,83	; low
	ds.l	4
	incbin	spr\3f.bin

; ----------------------------------
;	Impacts
; ----------------------------------

s40	dc.w	42,66	; debout milieu
	ds.l	4
	incbin	spr\40.bin
s41	dc.w	44,63
	ds.l	4
	incbin	spr\41.bin
s42	dc.w	43,62
	ds.l	4
	incbin	spr\42.bin

s43	dc.w	43,81	; debout haut
	ds.l	4
	incbin	spr\43.bin
s44	dc.w	51,79
	ds.l	4
	incbin	spr\44.bin
s45	dc.w	60,74
	ds.l	4
	incbin	spr\45.bin
	
s46	dc.w	42,59	; bas
	ds.l	4
	incbin	spr\46.bin
s47	dc.w	44,58
	ds.l	4
	incbin	spr\47.bin
s48	dc.w	53,53
	ds.l	4
	incbin	spr\48.bin
	
; ----------------------------------
;	Protection
; ----------------------------------

s4a	dc.w	49,74	; debout
	ds.l	4
	incbin	spr\4a.bin
s4b	dc.w	45,59	; bas
	ds.l	4
	incbin	spr\4b.bin

; ----------------------------------
;	Prise
; ----------------------------------

s4c	dc.w	42,84	; debout
	ds.l	4
	incbin	spr\4c.bin
s4d	dc.w	58,58	; prend
	ds.l	4
	incbin	spr\4d.bin
s4e	dc.w	65,48	; envoie loin
	ds.l	4
	incbin	spr\4e.bin
	
; ----------------------------------
;	Pousse
; ----------------------------------

s4f	dc.w	60,73	; approche
	ds.l	4
	incbin	spr\4f.bin
s50	dc.w	50,76	; pousse
	ds.l	4
	incbin	spr\50.bin
	
; ----------------------------------
;	Fauchage
; ----------------------------------

s51	dc.w	50,52	; En arriere
	ds.l	4
	incbin	spr\51.bin
s52	dc.w	56,62	; Chute cote
	ds.l	4
	incbin	spr\52.bin
s53	dc.w	80,33	; Etale par terre
	ds.l	4
	incbin	spr\53.bin
s54	dc.w	62,53	; Start releve
	ds.l	4
	incbin	spr\54.bin

; ----------------------------------
;	Divers
; ----------------------------------

sinus	incbin	sinus.bin	; saut h
sinus2	incbin	sinus2.bin	; saut av,ar
sinus3	incbin	sinus3.bin	; saut op

lowwhirltab	dc.w	40,0,72,2,40,0
midwhirltab	dc.w	40,0,42,2,20,3,42,2,40,0
higwhirltab	dc.w	40,0,42,2,52,3,42,2,40,0

; ----------------------------------
;	Samples
; ----------------------------------

snd_speed	incbin	avr\cl2.avr
snde_speed
snd_whirlwind	incbin	avr\cl1.avr
snde_whirlwind

snd_fx1	incbin	avr\fx1.avr
snde_fx1
snd_fx2	incbin	avr\fx2.avr
snde_fx2
snd_fx3	incbin	avr\fx3.avr
snde_fx3
snd_fx4	incbin	avr\fx4.avr
snde_fx4

snd_fx6	incbin	avr\fx6.avr
snde_fx6
snd_fx7	incbin	avr\fx7.avr
snde_fx7
snd_fx8	incbin	avr\fx8.avr
snde_fx8

snd_endjump	incbin	avr\fx12.avr
snde_endjump

; ----------------------------------
	BSS
; ----------------------------------

infos_joueur	equ	*

xn	equ	*-infos_joueur
	ds.w	1	; position courante
yn	equ	*-infos_joueur
	ds.w	1
dn	equ	*-infos_joueur
	ds.w	1	; dir courante
attack	equ	*-infos_joueur
	ds.w	1	; flag attaque
defense	equ	*-infos_joueur
	ds.w	1	; flag defense

saut	equ	*-infos_joueur
	ds.w	1	; sens du saut
			; flag pour saut
			; flag si marche/debout
bord	equ	*-infos_joueur
	ds.w	1	; flag bord
bt_nmb	equ	*-infos_joueur
	ds.w	1	; nb bouton pour protect

seq_cpt	equ	*-infos_joueur
	ds.w	1	; idem
seq_cur	equ	*-infos_joueur
	ds.l	1	; sequence courante
seq_vbl	equ	*-infos_joueur
	ds.w	1	; compteur ds sequence
seq_spr	equ	*-infos_joueur
	ds.l	1	; pointeur courant ds seq

seq_cur2	equ	*-infos_joueur
	ds.l	1	; sequence courante
seq_vbl2	equ	*-infos_joueur
	ds.w	1	; idem
seq_spr2	equ	*-infos_joueur
	ds.l	1	; si interrupt

collision	equ	*-infos_joueur
	ds.w	1	; flag collision
minecrx	equ	*-infos_joueur
	ds.w	1	; minimum x deplacement
maxecrx	equ	*-infos_joueur
	ds.w	1	; maximum x deplacement

last_bt	equ	*-infos_joueur
	ds.w	1	; dernier bouton appuye par autre joueur
			; ( puissance : 1,2,3 )
energie	equ	*-infos_joueur
	ds.w	1	; energie restante
touche	equ	*-infos_joueur
	ds.w	1	; flag touche par autre
snd_adr	equ	*-infos_joueur
	ds.l	1	; adr courante son
snd_res	equ	*-infos_joueur
	ds.l	1	; taille restante
