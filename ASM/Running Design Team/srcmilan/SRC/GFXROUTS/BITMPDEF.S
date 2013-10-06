
; struktur bitmap
BITMAPGFXPTR		equ	0	; pointer auf bitmap (binaerdaten/textur)
BITMAPWIDTH		equ	4	; breite in pixel
BITMAPHEIGHT		equ	6	; hoehe in pixel
BITMAPLINEOFFSET	equ	8	; lineoffset (offscreen: 2 * bitmapwidth, videoram: 2 * width)
BITMAPMASKFLAG		equ	10	; flag, ob die bitmap maskiert werden muss: 0 = nein, 1 = ja
BITMAPVIDEORAMFLAG	equ	12	; flag, ob im videoram abgelegt: 0 = offscreen, 1 = videoram
BITMAPVIDEORAMX		equ	14	; position innerhalb des videorams
BITMAPVIDEORAMY		equ	16
BITMAPBITBLTCOUNTER	equ	18	; counter, wie oft durch bitblt benutzt (long)
BITMAPBYTES		equ	22


		text







		data


; ---------------------------------------------------------
; leere, nicht existente bitmap
bmpNull		dc.l	0
		dc.w	0,0,0,0
		dc.w	0,-1,-1
		dc.l	0


; ---------------------------------------------------------
; 3d border des hauptfensters (13 bitmaps)
bmpMainNw	dc.l	mainNwBmp
		dc.w	14,24,28,1
		dc.w	0,-1,-1
		dc.l	0
mainNwBmp	incbin	"include\3dborder\3dbnw.rbf"

bmpMainN	dc.l	mainNBmp
		dc.w	32,24,64,0
		dc.w	0,-1,-1
		dc.l	0
mainNBmp	incbin	"include\3dborder\3dbn.rbf"

bmpMainNe	dc.l	mainNeBmp
		dc.w	14,24,28,1
		dc.w	0,-1,-1
		dc.l	0
mainNeBmp	incbin	"include\3dborder\3dbne.rbf"

bmpMainNee	dc.l	mainNeeBmp
		dc.w	14,6,28,1
		dc.w	0,-1,-1
		dc.l	0
mainNeeBmp	incbin	"include\3dborder\3dbnee.rbf"

bmpMainE	dc.l	mainEBmp
		dc.w	12,32,24,0
		dc.w	0,-1,-1
		dc.l	0
mainEBmp	incbin	"include\3dborder\3dbe.rbf"

bmpMainSee	dc.l	mainSeeBmp
		dc.w	14,8,28,1
		dc.w	0,-1,-1
		dc.l	0
mainSeeBmp	incbin	"include\3dborder\3dbsee.rbf"

bmpMainSe	dc.l	mainSeBmp
		dc.w	14,24,28,1
		dc.w	0,-1,-1
		dc.l	0
mainSeBmp	incbin	"include\3dborder\3dbse.rbf"

bmpMainSse	dc.l	mainSseBmp
		dc.w	24,24,48,0
		dc.w	0,-1,-1
		dc.l	0
mainSseBmp	incbin	"include\3dborder\3dbsse.rbf"

bmpMainS	dc.l	mainSBmp
		dc.w	60,24,120,0
		dc.w	0,-1,-1
		dc.l	0
mainSBmp	incbin	"include\3dborder\3dbs.rbf"

bmpMainSw	dc.l	mainSwBmp
		dc.w	14,24,28,1
		dc.w	0,-1,-1
		dc.l	0
mainSwBmp	incbin	"include\3dborder\3dbsw.rbf"

bmpMainSww	dc.l	mainSwwBmp
		dc.w	14,8,28,1
		dc.w	0,-1,-1
		dc.l	0
mainSwwBmp	incbin	"include\3dborder\3dbsww.rbf"

bmpMainW	dc.l	mainWBmp
		dc.w	12,32,24,0
		dc.w	0,-1,-1
		dc.l	0
mainWBmp	incbin	"include\3dborder\3dbw.rbf"

bmpMainNww	dc.l	mainNwwBmp
		dc.w	14,6,28,1
		dc.w	0,-1,-1
		dc.l	0
mainNwwBmp	incbin	"include\3dborder\3dbnww.rbf"


; ---------------------------------------------------------
; 3d border der extra-karte (8 bitmaps)
bmpExtraMapUl	dc.l	extraMapUlBmp
		dc.w	3,3,6,0
		dc.w	0,-1,-1
		dc.l	0
extraMapUlBmp	incbin	"include\extramap\extraul.rbf"

bmpExtraMapUs	dc.l	extraMapUsBmp
		dc.w	8,3,16,0
		dc.w	0,-1,-1
		dc.l	0
extraMapUsBmp	incbin	"include\extramap\extraus.rbf"

bmpExtraMapUr	dc.l	extraMapUrBmp
		dc.w	3,3,6,0
		dc.w	0,-1,-1
		dc.l	0
extraMapUrBmp	incbin	"include\extramap\extraur.rbf"

bmpExtraMapRs	dc.l	extraMapRsBmp
		dc.w	3,8,6,0
		dc.w	0,-1,-1
		dc.l	0
extraMapRsBmp	incbin	"include\extramap\extrars.rbf"

bmpExtraMapDr	dc.l	extraMapDrBmp
		dc.w	3,3,6,0
		dc.w	0,-1,-1
		dc.l	0
extraMapDrBmp	incbin	"include\extramap\extradr.rbf"

bmpExtraMapDs	dc.l	extraMapDsBmp
		dc.w	8,3,16,0
		dc.w	0,-1,-1
		dc.l	0
extraMapDsBmp	incbin	"include\extramap\extrads.rbf"

bmpExtraMapDl	dc.l	extraMapDlBmp
		dc.w	3,3,6,0
		dc.w	0,-1,-1
		dc.l	0
extraMapDlBmp	incbin	"include\extramap\extradl.rbf"

bmpExtraMapLs	dc.l	extraMapLsBmp
		dc.w	3,8,6,0
		dc.w	0,-1,-1
		dc.l	0
extraMapLsBmp	incbin	"include\extramap\extrals.rbf"


; ---------------------------------------------------------
; bitmaps zum aufbau der console
bmpCEnergyBk	dc.l	cEnergyBkBmp
		dc.w	18,42,36,0
		dc.w	0,-1,-1
		dc.l	0
cEnergyBkBmp	incbin	"include\console\energybk.rbf"

bmpCEnergyCl	dc.l	cEnergyClBmp
		dc.w	18,42,36,0
		dc.w	0,-1,-1
		dc.l	0
cEnergyClBmp	incbin	"include\console\energycl.rbf"

bmpCEnergyTx	dc.l	cEnergyTxBmp
		dc.w	9,40,18,0
		dc.w	0,-1,-1
		dc.l	0
cEnergyTxBmp	incbin	"include\console\energytx.rbf"

bmpCShieldBk	dc.l	cShieldBkBmp
		dc.w	18,42,36,0
		dc.w	0,-1,-1
		dc.l	0
cShieldBkBmp	incbin	"include\console\shieldbk.rbf"

bmpCShieldCl	dc.l	cShieldClBmp
		dc.w	18,42,36,0
		dc.w	0,-1,-1
		dc.l	0
cShieldClBmp	incbin	"include\console\shieldcl.rbf"

bmpCShieldTx	dc.l	cShieldTxBmp
		dc.w	9,37,18,0
		dc.w	0,-1,-1
		dc.l	0
cShieldTxBmp	incbin	"include\console\shieldtx.rbf"

bmpCBagBk	dc.l	cBagBkBmp
		dc.w	34,34,68,0
		dc.w	0,-1,-1
		dc.l	0
cBagBkBmp	incbin	"include\console\bagbk.rbf"

bmpCBagTx	dc.l	cBagTxBmp
		dc.w	9,23,18,0
		dc.w	0,-1,-1
		dc.l	0
cBagTxBmp	incbin	"include\console\bagtx.rbf"

bmpCWeaponBk	dc.l	cWeaponBkBmp
		dc.w	50,22,100,0
		dc.w	0,-1,-1
		dc.l	0
cWeaponBkBmp	incbin	"include\console\weaponbk.rbf"

bmpCCons01	dc.l	cCons01Bmp
		dc.w	18,22,36,0
		dc.w	0,-1,-1
		dc.l	0
cCons01Bmp	incbin	"include\console\cons01.rbf"

bmpCCons02	dc.l	cCons02Bmp
		dc.w	18,18,36,0
		dc.w	0,-1,-1
		dc.l	0
cCons02Bmp	incbin	"include\console\cons02.rbf"

bmpCCons03s	dc.l	cCons03sBmp
		dc.w	4,18,8,0
		dc.w	0,-1,-1
		dc.l	0
cCons03sBmp	incbin	"include\console\cons03s.rbf"

bmpCCons04	dc.l	cCons04Bmp
		dc.w	10,18,20,0
		dc.w	0,-1,-1
		dc.l	0
cCons04Bmp	incbin	"include\console\cons04.rbf"

bmpCCons05s	dc.l	cCons05sBmp
		dc.w	4,18,8,0
		dc.w	0,-1,-1
		dc.l	0
cCons05sBmp	incbin	"include\console\cons05s.rbf"

bmpCCons06	dc.l	cCons06Bmp
		dc.w	10,18,20,0
		dc.w	0,-1,-1
		dc.l	0
cCons06Bmp	incbin	"include\console\cons06.rbf"

; ikonen fuer waffenstandsanzeige
bmpCWeapon	dc.l	weaponConsole							; liegt in .\src\console\wpcons.s
		dc.w	CONSOLEWEAPONWIDTH,CONSOLEWEAPONHEIGHT,CONSOLEWEAPONWIDTH*2,0
		dc.w	0,-1,-1
		dc.l	0

; itemanzeige
bmpCItems	dc.l	consoleItems							; liegt in .\src\console\items.s
		dc.w	CONSOLEITEMSWIDTH,CONSOLEITEMSHEIGHT,CONSOLEITEMSWIDTH*2,0
		dc.w	0,-1,-1
		dc.l	0

; scanner
bmpCScanBack	dc.l	cScanBackBmp
		dc.w	64,64,128,1
		dc.w	0,-1,-1
		dc.l	0
cScanBackBmp	incbin	"include\console\scanback.rbf"

; geiger
bmpCGeigBack	dc.l	cGeigBackBmp
		dc.w	112,80,224,1
		dc.w	0,-1,-1
		dc.l	0
cGeigBackBmp	incbin	"include\console\geigback.rbf"

; alttab
bmpCAltTab	dc.l	altTabBitmap							; liegt in .\src\console\alttab.s
		dc.w	CALTTABWIDTH,CALTTABHEIGHT,CALTTABLINEOFFSET,1
		dc.w	0,-1,-1
		dc.l	0


; ---------------------------------------------------------
; bitmaps zum aufbau des laptops
bmpLaptop00	dc.l	laptop00Bmp
		dc.w	27,9,54,0
		dc.w	0,-1,-1
		dc.l	0
laptop00Bmp	incbin	"include\laptop\border00.rbf"

bmpLaptop01	dc.l	laptop01Bmp
		dc.w	27,2,54,0
		dc.w	0,-1,-1
		dc.l	0
laptop01Bmp	incbin	"include\laptop\border01.rbf"

bmpLaptop02	dc.l	laptop02Bmp
		dc.w	27,9,54,0
		dc.w	0,-1,-1
		dc.l	0
laptop02Bmp	incbin	"include\laptop\border02.rbf"

bmpLaptop03	dc.l	laptop03Bmp
		dc.w	27,9,54,0
		dc.w	0,-1,-1
		dc.l	0
laptop03Bmp	incbin	"include\laptop\border03.rbf"

bmpLaptop04	dc.l	laptop04Bmp
		dc.w	27,4,54,0
		dc.w	0,-1,-1
		dc.l	0
laptop04Bmp	incbin	"include\laptop\border04.rbf"

bmpLaptop05	dc.l	laptop05Bmp
		dc.w	27,9,54,0
		dc.w	0,-1,-1
		dc.l	0
laptop05Bmp	incbin	"include\laptop\border05.rbf"

bmpLaptop06	dc.l	laptop06Bmp
		dc.w	27,9,54,0
		dc.w	0,-1,-1
		dc.l	0
laptop06Bmp	incbin	"include\laptop\border06.rbf"

bmpLaptop07	dc.l	laptop07Bmp
		dc.w	27,4,54,0
		dc.w	0,-1,-1
		dc.l	0
laptop07Bmp	incbin	"include\laptop\border07.rbf"

bmpLaptop08	dc.l	laptop08Bmp
		dc.w	27,27,54,0
		dc.w	0,-1,-1
		dc.l	0
laptop08Bmp	incbin	"include\laptop\border08.rbf"

bmpLaptop09	dc.l	laptop09Bmp
		dc.w	4,27,8,0
		dc.w	0,-1,-1
		dc.l	0
laptop09Bmp	incbin	"include\laptop\border09.rbf"

bmpLaptop10	dc.l	laptop10Bmp
		dc.w	57,27,114,0
		dc.w	0,-1,-1
		dc.l	0
laptop10Bmp	incbin	"include\laptop\border10.rbf"

bmpLaptop11	dc.l	laptop11Bmp
		dc.w	7,18,14,1
		dc.w	0,-1,-1
		dc.l	0
laptop11Bmp	incbin	"include\laptop\border11.rbf"

bmpLaptop12	dc.l	laptop12Bmp
		dc.w	9,4,18,0
		dc.w	0,-1,-1
		dc.l	0
laptop12Bmp	incbin	"include\laptop\border12.rbf"

bmpLaptop13	dc.l	laptop13Bmp
		dc.w	9,9,18,0
		dc.w	0,-1,-1
		dc.l	0
laptop13Bmp	incbin	"include\laptop\border13.rbf"

bmpLaptop14	dc.l	laptop14Bmp
		dc.w	4,9,8,0
		dc.w	0,-1,-1
		dc.l	0
laptop14Bmp	incbin	"include\laptop\border14.rbf"

