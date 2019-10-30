; resource set indices for DEMO
;
MENU     equ 0 ; menu
INFOS    equ 7 ; STRING in MENU
OUVRE    equ 16 ; STRING in MENU
QUITTE   equ 17 ; STRING in MENU

BOITE    equ 1 ; form/dialog
SAISIE   equ 2 ; FTEXT in BOITE
BUTA     equ 3 ; BUTTON in BOITE
BUTB     equ 4 ; BUTTON in BOITE
OK       equ 5 ; BUTTON in BOITE
TEDDY    equ 6 ; ICON in BOITE

	.data

string_0:	dc.b " Bureau",0
string_1:	dc.b " Options",0
string_2:	dc.b "  Informations... ",0
string_3:	dc.b "------------------",0
string_4:	dc.b "  Accessoire  1   ",0
string_5:	dc.b "  Accessoire  2   ",0
string_6:	dc.b "  Accessoire  3   ",0
string_7:	dc.b "  Accessoire  4   ",0
string_8:	dc.b "  Accessoire  5   ",0
string_9:	dc.b "  Accessoire  6   ",0
string_10:	dc.b "  Ouvrir  ",0
string_11:	dc.b "  Quitter ",0
string_12:	dc.b "EXEMPLE DE BOITE",0
string_13:	dc.b 0
string_14:	dc.b 0
string_15:	dc.b "..............",0
string_16:	dc.b "Saisie : ______________",0
string_17:	dc.b "X",0
string_18:	dc.b "A",0
string_19:	dc.b "B",0
string_20:	dc.b "OK",0
string_21:	dc.b " TEDDY BEAR",0


IMAGE0:	dc.w $0000,$0000,$0000,$0000,$0FC0,$03F0,$1FF0,$0FF8
	dc.w $3FF8,$1FFC,$7FFF,$FFFE,$7FFF,$FFFE,$7FFF,$FFFE
	dc.w $7FC0,$03FE,$7F80,$01FE,$7F00,$00FE,$3C0E,$703C
	dc.w $3C1F,$F83C,$381F,$F81C,$781F,$F81E,$787F,$FE1E
	dc.w $F3FF,$FFCF,$F7FF,$FFEF,$EFE7,$E7F7,$EFC3,$C3F7
	dc.w $EFC0,$03F7,$E3C0,$03C7,$F3E7,$E7CF,$F3FF,$FFCF
	dc.w $7BFF,$FFDE,$7F7E,$7EFE,$3FFC,$3FFC,$1FFC,$3FF8
	dc.w $03FF,$FFC0,$001F,$F800,$000F,$F000,$0000,$0000


IMAGE1:	dc.w $0000,$0000,$0000,$0000,$0000,$0000,$0780,$01E0
	dc.w $0860,$0610,$1010,$0808,$231F,$F8C4,$2480,$0124
	dc.w $2500,$00A4,$2200,$0044,$1000,$0008,$0800,$0010
	dc.w $1004,$2008,$100A,$5008,$100A,$5008,$200A,$5004
	dc.w $203F,$FC04,$41C3,$C382,$4201,$8042,$4400,$0022
	dc.w $4080,$0102,$4100,$0082,$4180,$0182,$2143,$C284
	dc.w $203C,$3C04,$1010,$0808,$0E10,$0870,$01E8,$1780
	dc.w $0008,$1000,$0007,$E000,$0000,$0000,$0000,$0000



rs_frstr:	dc.l 0


rs_frimg:	dc.l 0


rs_iconblk:	dc.l IMAGE0,IMAGE1
	dc.l string_21
	dc.w 4096,13,11,20,0,32,32,0,32,72,8


rs_tedinfo:	dc.l string_12,string_13,string_14
	dc.w 3,6,2,$1180,$0,-1,17,1
	dc.l string_15,string_16,string_17
	dc.w 3,6,2,$1180,$0,-1,15,24


rs_object:	dc.w -1,1,5,25,$0000,$0000
	dc.l $0
	dc.w 0,0,160,25
	dc.w 5,2,2,20,$0000,$0000
	dc.l $1100
	dc.w 0,0,160,513
	dc.w 1,3,4,25,$0000,$0000
	dc.l $0
	dc.w 2,0,17,769
	dc.w 4,-1,-1,32,$0000,$0000
	dc.l string_0
	dc.w 0,0,8,769
	dc.w 2,-1,-1,32,$0000,$0000
	dc.l string_1
	dc.w 8,0,9,769
	dc.w 0,6,15,25,$0000,$0000
	dc.l $0
	dc.w 0,769,160,23
	dc.w 15,7,14,20,$0000,$0000
	dc.l $FF1100
	dc.w 2,0,18,8
	dc.w 8,-1,-1,28,$0000,$0000
	dc.l string_2
	dc.w 0,0,18,1
	dc.w 9,-1,-1,28,$0000,$0008
	dc.l string_3
	dc.w 0,1,18,1
	dc.w 10,-1,-1,28,$0000,$0000
	dc.l string_4
	dc.w 0,2,18,1
	dc.w 11,-1,-1,28,$0000,$0000
	dc.l string_5
	dc.w 0,3,18,1
	dc.w 12,-1,-1,28,$0000,$0000
	dc.l string_6
	dc.w 0,4,18,1
	dc.w 13,-1,-1,28,$0000,$0000
	dc.l string_7
	dc.w 0,5,18,1
	dc.w 14,-1,-1,28,$0000,$0000
	dc.l string_8
	dc.w 0,6,18,1
	dc.w 6,-1,-1,28,$0000,$0000
	dc.l string_9
	dc.w 0,7,18,1
	dc.w 5,16,17,20,$0000,$0000
	dc.l $FF1100
	dc.w 10,0,10,2
	dc.w 17,-1,-1,28,$0000,$0000
	dc.l string_10
	dc.w 0,0,10,1
	dc.w 15,-1,-1,28,$0020,$0000
	dc.l string_11
	dc.w 0,1,10,1

	dc.w -1,1,6,20,$0000,$0020
	dc.l $11100
	dc.w 0,0,27,11
	dc.w 2,-1,-1,22,$0000,$0020
	dc.l rs_tedinfo+0*28
	dc.w 5,1,17,1
	dc.w 3,-1,-1,29,$0008,$0000
	dc.l rs_tedinfo+1*28
	dc.w 2,4,23,1
	dc.w 4,-1,-1,26,$0011,$0001
	dc.l string_18
	dc.w 7,6,5,1
	dc.w 5,-1,-1,26,$0011,$0000
	dc.l string_19
	dc.w 14,6,5,1
	dc.w 6,-1,-1,26,$0007,$0000
	dc.l string_20
	dc.w 17,9,8,1
	dc.w 0,-1,-1,31,$0020,$0000
	dc.l rs_iconblk+0*34
	dc.w 2,8,18432,10240


rs_trindex:	dc.l rs_object+0*24
	dc.l rs_object+18*24


rs_nstrings  equ 22 ; total number of strings
rs_nuser     equ 0 ; total number of USERBLKs
rs_nfrstr    equ 0 ; number of free strings
rs_nimages   equ 2 ; total number of images
rs_nbb       equ 0 ; number of BITBLKs
rs_nfrimg    equ 0 ; number of free images
rs_nib       equ 1 ; number of ICONBLKs
rs_nted      equ 2 ; number of TEDINFOs
rs_nobs      equ 25 ; total number of OBJECTs
rs_ntree     equ 2 ; number of OBJECT trees

rs_name: dc.b "DEMO.RSC",0
	dc.b 0