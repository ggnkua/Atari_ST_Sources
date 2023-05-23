*
*	STRIMAGE.S	ST Star-Raiders MISCELLANEOUS Image Data
*

*
*	PUBLIC SYMBOLS
*
	.globl	rplimages
	.globl	xorimages
	.globl	solidimgs

*	Offsets to Individual Animation Groups w/in the Image-Table

	.globl	surgimg
surgimg	.equ	0
	.globl	radoimg
radoimg	.equ	surgimg+12
	.globl	hypsimg
hypsimg	.equ	radoimg+8
	.globl	hyplimg
hyplimg	.equ	hypsimg+2
	.globl	warpimg
warpimg	.equ	hyplimg+6
	.globl	swrpimg
swrpimg	.equ	warpimg+2
	.globl	shldimg
shldimg	.equ	swrpimg+2
	.globl	bshlimg
bshlimg	.equ	shldimg+2
	.globl	shbzimg
shbzimg	.equ	bshlimg+4
	.globl	shefimg
shefimg	.equ	shbzimg+8
	.globl	vgunimg
vgunimg	.equ	shefimg+16
	.globl	hgunimg
hgunimg	.equ	vgunimg+3
	.globl	bnukimg
bnukimg	.equ	hgunimg+3
	.globl	dnukimg
dnukimg	.equ	bnukimg+2
	.globl	snukimg
snukimg	.equ	dnukimg+4
	.globl	scanimg
scanimg	.equ	snukimg+5
	.globl	gmapimg
gmapimg	.equ	scanimg+4
	.globl	aftvimg
aftvimg	.equ	gmapimg+2
	.globl	aretimg
aretimg	.equ	aftvimg+4
	.globl	vlapimg
vlapimg	.equ	aretimg+2
	.globl	lrscimg
lrscimg	.equ	vlapimg+2
	.globl	gcsrimg
gcsrimg	.equ	lrscimg+10
	.globl	plotimg
plotimg	.equ	gcsrimg+1
	.globl	triimg
triimg	.equ	plotimg+13
	.globl	acmpimg
acmpimg	.equ	triimg+2
	.globl	dedcimg
dedcimg	.equ	acmpimg+11
	.globl	bzfcimg
bzfcimg	.equ	dedcimg+1
	.globl	bzncimg
bzncimg	.equ	bzfcimg+16
	.globl	alifimg
alifimg	.equ	bzncimg+16

	.globl	shotimg
shotimg	.equ	alifimg+8
	.globl	shatimg
shatimg	.equ	shotimg+64

	.globl	shutimg
shutimg	.equ	shatimg+64
	.globl	baseimg
baseimg	.equ	shutimg+16
	.globl	rockimg
rockimg	.equ	baseimg+64

	.globl	shipimg
shipimg	.equ	rockimg+64

*
*	Solid Images
*		Image Width(Pixels),Image Index
*
solidimgs:
	.dc.w	$0a,shbzimg
	.dc.w	$0a,shbzimg+1
	.dc.w	$0a,shbzimg+2
	.dc.w	$0a,shbzimg+3
	.dc.w	$0a,shbzimg+4
	.dc.w	$0a,shbzimg+5
	.dc.w	$0a,shbzimg+6
	.dc.w	$0a,shbzimg+7
	.dc.w	$13,dedcimg
	.dc.w	$13,bzncimg
	.dc.w	$13,bzncimg+1
	.dc.w	$13,bzncimg+2
	.dc.w	$13,bzncimg+3
	.dc.w	$13,bzncimg+4
	.dc.w	$13,bzncimg+5
	.dc.w	$13,bzncimg+6
	.dc.w	$13,bzncimg+7
	.dc.w	$13,bzncimg+8
	.dc.w	$13,bzncimg+9
	.dc.w	$13,bzncimg+10
	.dc.w	$13,bzncimg+11
	.dc.w	$13,bzncimg+12
	.dc.w	$13,bzncimg+13
	.dc.w	$13,bzncimg+14
	.dc.w	$13,bzncimg+15
	.dc.w	$13,bzfcimg
	.dc.w	$13,bzfcimg+1
	.dc.w	$13,bzfcimg+2
	.dc.w	$13,bzfcimg+3
	.dc.w	$13,bzfcimg+4
	.dc.w	$13,bzfcimg+5
	.dc.w	$13,bzfcimg+6
	.dc.w	$13,bzfcimg+7
	.dc.w	$13,bzfcimg+8
	.dc.w	$13,bzfcimg+9
	.dc.w	$13,bzfcimg+10
	.dc.w	$13,bzfcimg+11
	.dc.w	$13,bzfcimg+12
	.dc.w	$13,bzfcimg+13
	.dc.w	$13,bzfcimg+14
	.dc.w	$13,bzfcimg+15
	.dc.w	$1a,shldimg
	.dc.w	$1a,shldimg+1
	.dc.w	$9,alifimg
	.dc.w	$9,alifimg+1
	.dc.w	$9,alifimg+2
	.dc.w	$9,alifimg+3
	.dc.w	$9,alifimg+4
	.dc.w	$9,alifimg+5
	.dc.w	$9,alifimg+6
	.dc.w	$9,alifimg+7
	.dc.w	$15,radoimg
	.dc.w	$15,radoimg+1
	.dc.w	$15,radoimg+2
	.dc.w	$15,radoimg+3
	.dc.w	$15,radoimg+4
	.dc.w	$15,radoimg+5
	.dc.w	$15,radoimg+6
	.dc.w	$15,radoimg+7
	.dc.w	$13,warpimg
	.dc.w	$13,warpimg+1
	.dc.w	$8,bshlimg
	.dc.w	$15,hypsimg
	.dc.w	$15,hypsimg+1
	.dc.w	$13,dnukimg
	.dc.w	$13,dnukimg+1
	.dc.w	$13,dnukimg+2
	.dc.w	$13,dnukimg+3
	.dc.w	$13,snukimg
	.dc.w	$13,snukimg+1
	.dc.w	$13,snukimg+2
	.dc.w	$13,snukimg+3
	.dc.w	$13,snukimg+4
	.dc.w	$15,aftvimg+3
	.dc.w	$15,scanimg+3
	.dc.w	$88,vlapimg+1
	.dc.l	0		* E.O. List Marker

*
*	Image data and tables
*		Xoffset,Yoffset (pixels)
*		Height (lines), Width (words)
*		Image_Data
*

	.data
	.even

rplimages:			* REPLACE Images Pointer Table
xorimages:			* XOR Images Pointer Table
	.dc.l	srgimg0		* Surge-Energy Indicator Busy-Box
	.dc.l	srgimg1
	.dc.l	srgimg2
	.dc.l	srgimg3
	.dc.l	srgimg4
	.dc.l	srgimg5
	.dc.l	srgimg6
	.dc.l	srgimg7
	.dc.l	srgimg8
	.dc.l	srgimg9
	.dc.l	srgimga
	.dc.l	srgimgb
	.dc.l	radimg0		* Sub-Space Radio Carrier Busy-Box
	.dc.l	radimg1
	.dc.l	radimg2
	.dc.l	radimg3
	.dc.l	radimg4
	.dc.l	radimg5
	.dc.l	radimg6
	.dc.l	radimg7
	.dc.l	hypimg0		* Hyper-Drive Switch (off)
	.dc.l	hypimg1
	.dc.l	hypimg2		* Hyper-Drive Spinning Light
	.dc.l	hypimg3
	.dc.l	hypimg4
	.dc.l	hypimg5
	.dc.l	hypimg6
	.dc.l	hypimg7
	.dc.l	wrpimg0		* Warp-Drive Panel
	.dc.l	wrpimg1
	.dc.l	wrpimg2		* Warp-Drive Selector
	.dc.l	wrpimg3
	.dc.l	shdimg0		* Shield Switch (off)
	.dc.l	shdimg1
	.dc.l	shdimg2		* Shield Light (black,green,red,yellow)
	.dc.l	shdimg3
	.dc.l	shdimg4
	.dc.l	shdimg5
	.dc.l	bshimg7		* Shield On Buzy Box
	.dc.l	bshimg6
	.dc.l	bshimg5
	.dc.l	bshimg4
	.dc.l	bshimg3
	.dc.l	bshimg2
	.dc.l	bshimg1
	.dc.l	bshimg0
	.dc.l	eshimg0		* Shield On Effect
	.dc.l	eshimg1
	.dc.l	eshimg2
	.dc.l	eshimg3
	.dc.l	eshimg4
	.dc.l	eshimg5
	.dc.l	eshimg6
	.dc.l	eshimg7
	.dc.l	ashimg7		* Shield On Effect (AFT)
	.dc.l	ashimg6
	.dc.l	ashimg5
	.dc.l	ashimg4
	.dc.l	ashimg3
	.dc.l	ashimg2
	.dc.l	ashimg1
	.dc.l	ashimg0
	.dc.l	gunimg0		* Vertical Gun Light (green,red,yellow)
	.dc.l	gunimg2
	.dc.l	gunimg1
	.dc.l	gunimg3		* Horizontal Gun Light (green,red,yellow)
	.dc.l	gunimg5
	.dc.l	gunimg4
	.dc.l	nukimg0		* Nuke Light (Yellow)
	.dc.l	nukimg1
	.dc.l	nukimg2		* Nuke Door
	.dc.l	nukimg3
	.dc.l	nukimg4
	.dc.l	nukimg5
	.dc.l	nukimg6		* Nuke Switch
	.dc.l	nukimg7
	.dc.l	nukimg8
	.dc.l	nukimg9
	.dc.l	nukimg10
	.dc.l	scnimg0		* Scanner Select (white,purple,red,black)
	.dc.l	scnimg1
	.dc.l	scnimg2
	.dc.l	scnimg3
	.dc.l	mapimg0		* Galactic Map Select (white,purple)
	.dc.l	mapimg1
	.dc.l	aftimg0		* Aft-View Select (white,purple,red,black)
	.dc.l	aftimg1
	.dc.l	aftimg2
	.dc.l	aftimg3
	.dc.l	artimg0		* Aft-Viewer Reticle
	.dc.l	artimg1
	.dc.l	vlpimg0		* Overlapped with the Window
	.dc.l	vlpimg1
	.dc.l	lrsimg0		* Long-Range Scanner Graphics
	.dc.l	lrsimg1
	.dc.l	lrsimg2		* (Red, Green, Yellow Triangles)
	.dc.l	lrsimg3
	.dc.l	lrsimg4
	.dc.l	lrsimg5		* (Red, Green, Yellow Diamonds)
	.dc.l	lrsimg6
	.dc.l	lrsimg7
	.dc.l	lrsimg8		* Your Ship
	.dc.l	lrsimg9		* LR Scanner Reticle
	.dc.l	gcsimg0		* Galactic Map Cursor
	.dc.l	lrsimg5		* Galactic Map Plotting Markers (down)
	.dc.l	gmpimg1
	.dc.l	gmpimg2
	.dc.l	gmpimg3
	.dc.l	gmpimg4
	.dc.l	gmpimg5
	.dc.l	gmpimg6
	.dc.l	gmpimg7		* Galactic Map Plotting Markers (up)
	.dc.l	gmpimg8
	.dc.l	gmpimg9
	.dc.l	gmpimga
	.dc.l	gmpimgb
	.dc.l	gmpimgc
	.dc.l	dntrimg		* You-Are-Here Triangles
	.dc.l	uptrimg
	.dc.l	acmimg0		* Attack Computer Reticles
	.dc.l	acmimg1
	.dc.l	acmimg2
	.dc.l	acmimg2		* dummy
	.dc.l	acmimg3
	.dc.l	acmimg4
	.dc.l	acmimg5
	.dc.l	acmimg5		* dummy
	.dc.l	acmimg6
	.dc.l	acmimg7
	.dc.l	acmimg8
	.dc.l	cmpimg0		* Dead Computer
	.dc.l	cmpimg1		* Working Computer (Off)
	.dc.l	cmpimg2
	.dc.l	cmpimg3
	.dc.l	cmpimg4
	.dc.l	cmpimg5
	.dc.l	cmpimg6
	.dc.l	cmpimg7
	.dc.l	cmpimg8
	.dc.l	cmpimg9
	.dc.l	cmpimg10
	.dc.l	cmpimg11
	.dc.l	cmpimg12
	.dc.l	cmpimg13
	.dc.l	cmpimg14
	.dc.l	cmpimg15
	.dc.l	cmpimg16
	.dc.l	cmpimg17	* Working Computer (On)
	.dc.l	cmpimg18
	.dc.l	cmpimg19
	.dc.l	cmpimg20
	.dc.l	cmpimg21
	.dc.l	cmpimg22
	.dc.l	cmpimg23
	.dc.l	cmpimg24
	.dc.l	cmpimg25
	.dc.l	cmpimg26
	.dc.l	cmpimg27
	.dc.l	cmpimg28
	.dc.l	cmpimg29
	.dc.l	cmpimg30
	.dc.l	cmpimg31
	.dc.l	cmpimg32

	.dc.l	lifimg0		* Life-Support Busy Box
	.dc.l	lifimg1
	.dc.l	lifimg2
	.dc.l	lifimg3
	.dc.l	lifimg4
	.dc.l	lifimg5
	.dc.l	lifimg6
	.dc.l	lifimg7


*
*	Missile Graphics
*
	.dc.l	shtimg07
	.dc.l	shtimg17
	.dc.l	shtimg27
	.dc.l	shtimg37
	.dc.l	shtimg47
	.dc.l	shtimg57
	.dc.l	shtimg67
	.dc.l	shtimg77
	.dc.l	shtimg06
	.dc.l	shtimg16
	.dc.l	shtimg26
	.dc.l	shtimg36
	.dc.l	shtimg46
	.dc.l	shtimg56
	.dc.l	shtimg66
	.dc.l	shtimg76
	.dc.l	shtimg05
	.dc.l	shtimg15
	.dc.l	shtimg25
	.dc.l	shtimg35
	.dc.l	shtimg45
	.dc.l	shtimg55
	.dc.l	shtimg65
	.dc.l	shtimg75
	.dc.l	shtimg04
	.dc.l	shtimg14
	.dc.l	shtimg24
	.dc.l	shtimg34
	.dc.l	shtimg44
	.dc.l	shtimg54
	.dc.l	shtimg64
	.dc.l	shtimg74
	.dc.l	shtimg03
	.dc.l	shtimg13
	.dc.l	shtimg23
	.dc.l	shtimg33
	.dc.l	shtimg43
	.dc.l	shtimg53
	.dc.l	shtimg63
	.dc.l	shtimg73
	.dc.l	shtimg02
	.dc.l	shtimg12
	.dc.l	shtimg22
	.dc.l	shtimg32
	.dc.l	shtimg42
	.dc.l	shtimg52
	.dc.l	shtimg62
	.dc.l	shtimg72
	.dc.l	shtimg01
	.dc.l	shtimg11
	.dc.l	shtimg21
	.dc.l	shtimg31
	.dc.l	shtimg41
	.dc.l	shtimg51
	.dc.l	shtimg61
	.dc.l	shtimg71
	.dc.l	shtimg00
	.dc.l	shtimg10
	.dc.l	shtimg20
	.dc.l	shtimg30
	.dc.l	shtimg40
	.dc.l	shtimg50
	.dc.l	shtimg60
	.dc.l	shtimg70

	.dc.l	eshimg07
	.dc.l	eshimg17
	.dc.l	eshimg27
	.dc.l	eshimg37
	.dc.l	eshimg47
	.dc.l	eshimg57
	.dc.l	eshimg67
	.dc.l	eshimg77
	.dc.l	eshimg06
	.dc.l	eshimg16
	.dc.l	eshimg26
	.dc.l	eshimg36
	.dc.l	eshimg46
	.dc.l	eshimg56
	.dc.l	eshimg66
	.dc.l	eshimg76
	.dc.l	eshimg05
	.dc.l	eshimg15
	.dc.l	eshimg25
	.dc.l	eshimg35
	.dc.l	eshimg45
	.dc.l	eshimg55
	.dc.l	eshimg65
	.dc.l	eshimg75
	.dc.l	eshimg04
	.dc.l	eshimg14
	.dc.l	eshimg24
	.dc.l	eshimg34
	.dc.l	eshimg44
	.dc.l	eshimg54
	.dc.l	eshimg64
	.dc.l	eshimg74
	.dc.l	eshimg03
	.dc.l	eshimg13
	.dc.l	eshimg23
	.dc.l	eshimg33
	.dc.l	eshimg43
	.dc.l	eshimg53
	.dc.l	eshimg63
	.dc.l	eshimg73
	.dc.l	eshimg02
	.dc.l	eshimg12
	.dc.l	eshimg22
	.dc.l	eshimg32
	.dc.l	eshimg42
	.dc.l	eshimg52
	.dc.l	eshimg62
	.dc.l	eshimg72
	.dc.l	eshimg01
	.dc.l	eshimg11
	.dc.l	eshimg21
	.dc.l	eshimg31
	.dc.l	eshimg41
	.dc.l	eshimg51
	.dc.l	eshimg61
	.dc.l	eshimg71
	.dc.l	eshimg00
	.dc.l	eshimg10
	.dc.l	eshimg20
	.dc.l	eshimg30
	.dc.l	eshimg40
	.dc.l	eshimg50
	.dc.l	eshimg60
	.dc.l	eshimg70

*
*	StarBase Graphics
*
	.dc.l	shut00
	.dc.l	shut01
	.dc.l	shut02
	.dc.l	shut03
	.dc.l	shut04
	.dc.l	shut05
	.dc.l	shut06
	.dc.l	shut07
	.dc.l	shut08
	.dc.l	shut09
	.dc.l	shut10
	.dc.l	shut11
	.dc.l	shut12
	.dc.l	shut13
	.dc.l	shut14
	.dc.l	shut15

	.dc.l	base00
	.dc.l	base10
	.dc.l	base20
	.dc.l	base30
	.dc.l	base40
	.dc.l	base50
	.dc.l	base60
	.dc.l	base70
	.dc.l	base01
	.dc.l	base11
	.dc.l	base21
	.dc.l	base31
	.dc.l	base41
	.dc.l	base51
	.dc.l	base61
	.dc.l	base71
	.dc.l	base02
	.dc.l	base12
	.dc.l	base22
	.dc.l	base32
	.dc.l	base42
	.dc.l	base52
	.dc.l	base62
	.dc.l	base72
	.dc.l	base03
	.dc.l	base13
	.dc.l	base23
	.dc.l	base33
	.dc.l	base43
	.dc.l	base53
	.dc.l	base63
	.dc.l	base73
	.dc.l	base04
	.dc.l	base14
	.dc.l	base24
	.dc.l	base34
	.dc.l	base44
	.dc.l	base54
	.dc.l	base64
	.dc.l	base74
	.dc.l	base05
	.dc.l	base15
	.dc.l	base25
	.dc.l	base35
	.dc.l	base45
	.dc.l	base55
	.dc.l	base65
	.dc.l	base75
	.dc.l	base06
	.dc.l	base16
	.dc.l	base26
	.dc.l	base36
	.dc.l	base46
	.dc.l	base56
	.dc.l	base66
	.dc.l	base76
	.dc.l	base07
	.dc.l	base17
	.dc.l	base27
	.dc.l	base37
	.dc.l	base47
	.dc.l	base57
	.dc.l	base67
	.dc.l	base77

*
*	Asteroid Images
*
	.dc.l	rock00
	.dc.l	rock10
	.dc.l	rock20
	.dc.l	rock30
	.dc.l	rock40
	.dc.l	rock50
	.dc.l	rock60
	.dc.l	rock70
	.dc.l	rock01
	.dc.l	rock11
	.dc.l	rock21
	.dc.l	rock31
	.dc.l	rock41
	.dc.l	rock51
	.dc.l	rock61
	.dc.l	rock71
	.dc.l	rock02
	.dc.l	rock12
	.dc.l	rock22
	.dc.l	rock32
	.dc.l	rock42
	.dc.l	rock52
	.dc.l	rock62
	.dc.l	rock72
	.dc.l	rock03
	.dc.l	rock13
	.dc.l	rock23
	.dc.l	rock33
	.dc.l	rock43
	.dc.l	rock53
	.dc.l	rock63
	.dc.l	rock73
	.dc.l	rock04
	.dc.l	rock14
	.dc.l	rock24
	.dc.l	rock34
	.dc.l	rock44
	.dc.l	rock54
	.dc.l	rock64
	.dc.l	rock74
	.dc.l	rock05
	.dc.l	rock15
	.dc.l	rock25
	.dc.l	rock35
	.dc.l	rock45
	.dc.l	rock55
	.dc.l	rock65
	.dc.l	rock75
	.dc.l	rock06
	.dc.l	rock16
	.dc.l	rock26
	.dc.l	rock36
	.dc.l	rock46
	.dc.l	rock56
	.dc.l	rock66
	.dc.l	rock76
	.dc.l	rock07
	.dc.l	rock17
	.dc.l	rock27
	.dc.l	rock37
	.dc.l	rock47
	.dc.l	rock57
	.dc.l	rock67
	.dc.l	rock77

*
*	Alien Ships
*
	.dc.l	eshipf
	.dc.l	eshipe
	.dc.l	eshipd
	.dc.l	eshipc
	.dc.l	eshipb
	.dc.l	eshipa
	.dc.l	eship9
	.dc.l	eship8
	.dc.l	eship7
	.dc.l	eship6
	.dc.l	eship5
	.dc.l	eship4
	.dc.l	eship3
	.dc.l	eship2
	.dc.l	eship1
	.dc.l	eship0
	.dc.l	ashipf
	.dc.l	ashipe
	.dc.l	ashipd
	.dc.l	ashipc
	.dc.l	ashipb
	.dc.l	ashipa
	.dc.l	aship9
	.dc.l	aship8
	.dc.l	aship7
	.dc.l	aship6
	.dc.l	aship5
	.dc.l	aship4
	.dc.l	aship3
	.dc.l	aship2
	.dc.l	aship1
	.dc.l	aship0
	.dc.l	bshipf
	.dc.l	bshipe
	.dc.l	bshipd
	.dc.l	bshipc
	.dc.l	bshipb
	.dc.l	bshipa
	.dc.l	bship9
	.dc.l	bship8
	.dc.l	bship7
	.dc.l	bship6
	.dc.l	bship5
	.dc.l	bship4
	.dc.l	bship3
	.dc.l	bship2
	.dc.l	bship1
	.dc.l	bship0
	.dc.l	shipf
	.dc.l	shipe
	.dc.l	shipd
	.dc.l	shipc
	.dc.l	shipb
	.dc.l	shipa
	.dc.l	ship9
	.dc.l	ship8
	.dc.l	ship7
	.dc.l	ship6
	.dc.l	ship5
	.dc.l	ship4
	.dc.l	ship3
	.dc.l	ship2
	.dc.l	ship1
	.dc.l	ship0
	.dc.l	fshipf
	.dc.l	fshipe
	.dc.l	fshipd
	.dc.l	fshipc
	.dc.l	fshipb
	.dc.l	fshipa
	.dc.l	fship9
	.dc.l	fship8
	.dc.l	fship7
	.dc.l	fship6
	.dc.l	fship5
	.dc.l	fship4
	.dc.l	fship3
	.dc.l	fship2
	.dc.l	fship1
	.dc.l	fship0
	.dc.l	dshipf
	.dc.l	dshipe
	.dc.l	dshipd
	.dc.l	dshipc
	.dc.l	dshipb
	.dc.l	dshipa
	.dc.l	dship9
	.dc.l	dship8
	.dc.l	dship7
	.dc.l	dship6
	.dc.l	dship5
	.dc.l	dship4
	.dc.l	dship3
	.dc.l	dship2
	.dc.l	dship1
	.dc.l	dship0
	.dc.l	cshipf
	.dc.l	cshipe
	.dc.l	cshipd
	.dc.l	cshipc
	.dc.l	cshipb
	.dc.l	cshipa
	.dc.l	cship9
	.dc.l	cship8
	.dc.l	cship7
	.dc.l	cship6
	.dc.l	cship5
	.dc.l	cship4
	.dc.l	cship3
	.dc.l	cship2
	.dc.l	cship1
	.dc.l	cship0
	.dc.l	ushipf
	.dc.l	ushipe
	.dc.l	ushipd
	.dc.l	ushipc
	.dc.l	ushipb
	.dc.l	ushipa
	.dc.l	uship9
	.dc.l	uship8
	.dc.l	uship7
	.dc.l	uship6
	.dc.l	uship5
	.dc.l	uship4
	.dc.l	uship3
	.dc.l	uship2
	.dc.l	uship1
	.dc.l	uship0

	.dc.l	0		* EOList Marker

*
*	IMAGE DATA
*

*
*	CONTROL PANEL SWITCHES AND INDICATORS
*
lifimg0:		* Life-Support (Right-Hand Box)
	.dc.w	0,0
	.dc.w	20,1
	.dc.w	$2A00,$4F00,$0F00,$7000,$1500,$2780,$0780,$3800
	.dc.w	$0A80,$1380,$0380,$1C00,$0500,$0980,$0180,$0E00
	.dc.w	$0280,$0480,$0080,$0700,$0100,$0200,$0000,$0380
	.dc.w	$0080,$0100,$0000,$0180,$0000,$0680,$0000,$0080
	.dc.w	$0000,$0200,$0000,$0000,$4000,$0300,$0000,$0000
	.dc.w	$2000,$0000,$0000,$0000,$0000,$5000,$5000,$0000
	.dc.w	$0000,$A800,$2800,$8000,$8000,$5400,$1400,$C000
	.dc.w	$4000,$2A00,$0A00,$E000,$2000,$9500,$8500,$7000
	.dc.w	$1000,$4A80,$4280,$3800,$8800,$A500,$A100,$1C00
	.dc.w	$4400,$5280,$5080,$0E00,$A200,$A900,$A800,$0700
lifimg1:		* Life-Support (Right-Hand Box)
	.dc.w	0,0
	.dc.w	20,1
	.dc.w	$2A00,$4F00,$0F00,$7000,$1500,$2780,$0780,$3800
	.dc.w	$0A80,$1380,$0380,$1C00,$0500,$0980,$0180,$0E00
	.dc.w	$0280,$0480,$0080,$0700,$0100,$0200,$0000,$0380
	.dc.w	$0080,$0100,$0000,$0180,$0C00,$0C80,$0000,$0080
	.dc.w	$0400,$0400,$0000,$0000,$0600,$0600,$0000,$0000
	.dc.w	$0000,$0000,$2000,$2000,$0000,$1000,$1000,$0000
	.dc.w	$0800,$A000,$2000,$8000,$8000,$5400,$1400,$C000
	.dc.w	$4000,$2A00,$0A00,$E000,$2000,$9500,$8500,$7000
	.dc.w	$1000,$4A80,$4280,$3800,$8800,$A500,$A100,$1C00
	.dc.w	$4400,$5280,$5080,$0E00,$A200,$A900,$A800,$0700
lifimg2:		* Life-Support (Right-Hand Box)
	.dc.w	0,0
	.dc.w	20,1
	.dc.w	$2A00,$4F00,$0F00,$7000,$1500,$2780,$0780,$3800
	.dc.w	$0A80,$1380,$0380,$1C00,$0500,$0980,$0180,$0E00
	.dc.w	$0280,$0480,$0080,$0700,$0100,$0200,$0000,$0380
	.dc.w	$0080,$0100,$1C00,$0180,$0000,$0080,$0000,$0080
	.dc.w	$0000,$0000,$0A00,$0000,$0000,$0000,$4000,$4000
	.dc.w	$0000,$0000,$2700,$2000,$0000,$5000,$5000,$0000
	.dc.w	$0000,$A000,$2800,$8800,$8000,$5400,$1400,$C000
	.dc.w	$4200,$2800,$0800,$E000,$2100,$9400,$8400,$7000
	.dc.w	$1000,$4A80,$4280,$3800,$8800,$A500,$A100,$1C00
	.dc.w	$4400,$5280,$5080,$0E00,$A200,$A900,$A800,$0700
lifimg3:		* Life-Support (Right-Hand Box)
	.dc.w	0,0
	.dc.w	20,1
	.dc.w	$2A00,$4F00,$0F00,$7000,$1500,$2780,$0780,$3800
	.dc.w	$0A80,$1380,$0380,$1C00,$0500,$0980,$0180,$0E00
	.dc.w	$0280,$0480,$0080,$0700,$1900,$0200,$1800,$0380
	.dc.w	$0080,$0100,$1400,$0180,$1200,$0080,$1200,$0080
	.dc.w	$0000,$0000,$0000,$0000,$0900,$0000,$4900,$4000
	.dc.w	$0000,$0000,$2500,$2000,$4300,$1000,$1300,$0000
	.dc.w	$0000,$A000,$2800,$8800,$8000,$5400,$1400,$C000
	.dc.w	$4000,$2800,$0A00,$E200,$2000,$9400,$8500,$7100
	.dc.w	$1000,$4A80,$4280,$3800,$8800,$A500,$A100,$1C00
	.dc.w	$4400,$5280,$5080,$0E00,$A200,$A900,$A800,$0700
lifimg4:		* Life-Support (Right-Hand Box)
	.dc.w	0,0
	.dc.w	20,1
	.dc.w	$2A00,$4F00,$0F00,$7000,$1500,$2780,$0780,$3800
	.dc.w	$0A80,$1380,$0380,$1C00,$0500,$0980,$0180,$0E00
	.dc.w	$0280,$3C80,$3880,$3F00,$0100,$2600,$2400,$2780
	.dc.w	$0080,$2300,$2200,$2380,$0000,$0080,$0000,$0080
	.dc.w	$0000,$1100,$1100,$1100,$0000,$0000,$4000,$4000
	.dc.w	$0000,$0880,$2880,$2880,$0000,$1480,$5480,$4480
	.dc.w	$0000,$A380,$2B80,$8B80,$9000,$4400,$0400,$C000
	.dc.w	$4800,$2000,$0200,$E200,$2400,$9000,$8100,$7100
	.dc.w	$1000,$4A80,$4280,$3800,$8800,$A500,$A100,$1C00
	.dc.w	$4400,$5280,$5080,$0E00,$A200,$A900,$A800,$0700
lifimg5:		* Life-Support (Right-Hand Box)
	.dc.w	0,0
	.dc.w	20,1
	.dc.w	$2A00,$4F00,$0F00,$7000,$1500,$2780,$0780,$3800
	.dc.w	$0A80,$1380,$0380,$1C00,$7500,$0980,$7180,$7E00
	.dc.w	$4280,$0480,$7880,$4700,$4100,$0200,$6400,$4380
	.dc.w	$0080,$0100,$2200,$0180,$2100,$0080,$2100,$2180
	.dc.w	$0000,$0000,$1100,$0000,$1080,$0000,$5080,$5080
	.dc.w	$0000,$0000,$2880,$2000,$0000,$1000,$5480,$4000
	.dc.w	$0000,$A000,$2B80,$8800,$8180,$4400,$1580,$D180
	.dc.w	$4000,$2000,$0A00,$EA00,$2000,$9000,$8500,$7500
	.dc.w	$1000,$4A80,$4280,$3800,$8900,$A400,$A000,$1C00
	.dc.w	$4480,$5200,$5000,$0E00,$A200,$A900,$A800,$0700
lifimg6:		* Life-Support (Right-Hand Box)
	.dc.w	0,0
	.dc.w	20,1
	.dc.w	$2A00,$4F00,$0F00,$7000,$1500,$2780,$0780,$3800
	.dc.w	$0A80,$1380,$0380,$1C00,$7500,$0980,$7180,$0E00
	.dc.w	$4280,$3C80,$4080,$0700,$4100,$2600,$4000,$0380
	.dc.w	$0080,$2300,$0000,$0180,$2100,$0080,$2100,$0080
	.dc.w	$0000,$1100,$0000,$0000,$1080,$0000,$5080,$4000
	.dc.w	$0000,$0880,$2000,$2000,$0000,$1480,$5000,$4000
	.dc.w	$0000,$A380,$2800,$8800,$8180,$4400,$1580,$D000
	.dc.w	$4000,$2000,$0A00,$EA00,$2000,$9000,$8500,$7500
	.dc.w	$1000,$4A80,$4280,$3800,$8900,$A400,$A000,$1C00
	.dc.w	$4480,$5200,$5000,$0E00,$A200,$A900,$A800,$0700
lifimg7:		* Life-Support (Right-Hand Box)
	.dc.w	0,0
	.dc.w	20,1
	.dc.w	$2A00,$4F00,$0F00,$7000,$1500,$2780,$0780,$3800
	.dc.w	$0A80,$1380,$0380,$1C00,$7500,$7980,$0180,$0E00
	.dc.w	$4280,$4480,$0080,$0700,$4100,$4200,$0000,$0380
	.dc.w	$0080,$0100,$0000,$0180,$2100,$2180,$0000,$0080
	.dc.w	$0000,$0200,$0000,$0000,$1080,$1080,$4000,$4000
	.dc.w	$0000,$0000,$2000,$2000,$0000,$1000,$5000,$4000
	.dc.w	$0000,$A000,$2800,$8800,$8180,$4580,$1400,$D000
	.dc.w	$4000,$2000,$0A00,$EA00,$2000,$9000,$8500,$7500
	.dc.w	$1000,$4A80,$4280,$3800,$8900,$A400,$A000,$1C00
	.dc.w	$4480,$5200,$5000,$0E00,$A200,$A900,$A800,$0700

gcsimg0:		* Galactic Map Cursor
	.dc.w	2,2
	.dc.w	5,1
	.dc.w	$2000,$0000,$0000,$0000,$2000,$0000,$0000,$0000
	.dc.w	$D800,$0000,$0000,$0000,$2000,$0000,$0000,$0000
	.dc.w	$2000,$0000,$0000,$0000

lrsimg0:		* Long-Range Scanner Graphics (enemy ship RED)
	.dc.w	1,0
	.dc.w	2,1
	.dc.w	$0000,$E000,$E000,$E000,$0000,$4000,$4000,$4000
lrsimg1:		* Long-Range Scanner Graphics (enemy ship GREEN)
	.dc.w	1,0
	.dc.w	2,1
	.dc.w	$0000,$0000,$E000,$E000,$0000,$0000,$4000,$4000
lrsimg2:		* Long-Range Scanner Graphics (enemy ship YELLOW)
	.dc.w	1,0
	.dc.w	2,1
	.dc.w	$E000,$0000,$E000,$E000,$4000,$0000,$4000,$4000
lrsimg3:		* Long-Range Scanner Graphics (starbase RED)
	.dc.w	3,1
	.dc.w	3,1
	.dc.w	$0000,$3800,$3800,$3800,$0000,$FE00,$FE00,$FE00
	.dc.w	$0000,$3800,$3800,$3800
lrsimg4:		* Long-Range Scanner Graphics (starbase GREEN)
	.dc.w	3,1
	.dc.w	3,1
	.dc.w	$0000,$0000,$3800,$3800,$0000,$0000,$FE00,$FE00
	.dc.w	$0000,$0000,$3800,$3800
lrsimg5:		* Long-Range Scanner Graphics (starbase YELLOW)
	.dc.w	3,1
	.dc.w	3,1
	.dc.w	$3800,$0000,$3800,$3800,$FE00,$0000,$FE00,$FE00
	.dc.w	$3800,$0000,$3800,$3800
lrsimg6:		* Long-Range Scanner Graphics (Our Shots)
	.dc.w	0,0
	.dc.w	1,1
	.dc.w	$8000,$8000,$0000,$8000
lrsimg7:		* Long-Range Scanner Graphics (enemy shots)
	.dc.w	0,0
	.dc.w	1,1
	.dc.w	$0000,$8000,$8000,$8000
lrsimg8:		* Long-Range Scanner Graphics (Our Ship)
	.dc.w	1,2
	.dc.w	4,1
	.dc.w	$4000,$0000,$0000,$0000,$4000,$0000,$0000,$0000
	.dc.w	$E000,$0000,$0000,$0000,$A000,$0000,$0000,$0000
lrsimg9:		* Long-Range Scanner Reticle
	.dc.w	0,0
	.dc.w	3,8
	.dc.w	$0000,$0000,$AAAA,$AAAA,$0000,$0000,$AAAA,$AAAA
	.dc.w	$0000,$0000,$AAAA,$AAAA,$0000,$0000,$AAAA,$AAAA
	.dc.w	$0000,$0000,$AAAA,$AAAA,$0000,$0000,$AAAA,$AAAA
	.dc.w	$0000,$0000,$AAAA,$AAAA,$0000,$0000,$AAA8,$AAA8
	.dc.w	$0000,$0000,$8204,$8204,$0000,$0000,$0810,$0810
	.dc.w	$0000,$0000,$2040,$2040,$0000,$0000,$8102,$8102
	.dc.w	$0000,$0000,$0408,$0408,$0000,$0000,$1020,$1020
	.dc.w	$0000,$0000,$4081,$4081,$0000,$0000,$0208,$0208
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0002,$0002
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000

vlpimg0:		* Overlapped Life-Support Piece
	.dc.w	0,0
	.dc.w	4,1
	.dc.w	$1400,$1E00,$1E00,$0000,$2800,$3A00,$3A00,$0400
	.dc.w	$5400,$7200,$7200,$0C00,$AC00,$E200,$E200,$1C00
vlpimg1:		* Overlapped Viewer-Top Piece
	.dc.w	0,0
	.dc.w	4,9
	.dc.w	$FFFF,$FFFF,$7FFF,$8000,$FFF0,$FFF0,$FFF0,$000F
	.dc.w	$0000,$0000,$0000,$FFFF,$01FF,$0000,$0000,$FFFF
	.dc.w	$FFFF,$0000,$0000,$FFFF,$C000,$3FFF,$0000,$FFFF
	.dc.w	$0007,$FFFF,$0000,$FFFF,$FFFF,$FFFF,$0000,$FFFF
	.dc.w	$FF00,$FF00,$0000,$FF00,$C000,$C000,$0000,$C000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$0000,$0000,$0000,$0000,$0300,$0300,$0000,$0300
	.dc.w	$DFFF,$DFFF,$0FFF,$D000,$C001,$C000,$C000,$3FFF
	.dc.w	$FFF0,$000F,$0000,$FFFF,$007F,$FFFF,$0000,$FFFF
	.dc.w	$FFFF,$FFFF,$0000,$FFFF,$000F,$FFF0,$0000,$FFFF
	.dc.w	$FF80,$0000,$0000,$FFFF,$03FF,$03FF,$03FF,$FC00
	.dc.w	$FB00,$FB00,$F000,$0B00,$DFFF,$DFFF,$07FF,$D800
	.dc.w	$C001,$C000,$C000,$3FFF,$FFF0,$000F,$0000,$FFFF
	.dc.w	$007F,$FFFF,$0000,$FFFF,$FFFF,$FFFF,$0000,$FFFF
	.dc.w	$000F,$FFF0,$0000,$FFFF,$FF80,$0000,$0000,$FFFF
	.dc.w	$03FF,$03FF,$03FF,$FC00,$FB00,$FB00,$E000,$1B00

artimg0:		* Aft-Viewer Reticle (wide)
	.dc.w	0,0
	.dc.w	2,5
	.dc.w	$0000,$0000,$8208,$8208,$0000,$0000,$2082,$2082
	.dc.w	$0000,$0000,$0008,$0008,$0000,$0000,$2082,$2082
	.dc.w	$0000,$0000,$0820,$0820,$0000,$0000,$8208,$9249
	.dc.w	$0000,$0000,$2082,$2492,$0000,$0000,$0008,$2089
	.dc.w	$0000,$0000,$2082,$2492,$0000,$0000,$0820,$4920
artimg1:		* Aft-Viewer Reticle (tall)
	.dc.w	0,0
	.dc.w	25,1
	.dc.w	$0000,$0000,$E000,$E000,$0000,$0000,$0000,$0000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$2000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$0000,$0000,$6000,$6000,$0000,$0000,$0000,$0000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$2000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$2000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$0000,$0000,$3000,$3000,$0000,$0000,$0000,$0000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$2000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$0000,$0000,$3800,$3800

scnimg0:		* Scanner Select (white)
	.dc.w	0,0
	.dc.w	7,2
	.dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$F800,$F800
	.dc.w	$20F1,$0000,$DF0E,$DF0E,$E000,$0000,$1800,$1800
	.dc.w	$208A,$0000,$DF75,$DF75,$0000,$0000,$F800,$F800
	.dc.w	$20F1,$0000,$DF0E,$DF0E,$C000,$0000,$3800,$3800
	.dc.w	$2090,$0000,$DF6F,$DF6F,$2000,$0000,$D800,$D800
	.dc.w	$3E8B,$0000,$C174,$C174,$C000,$0000,$3800,$3800
	.dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$F800,$F800
scnimg1:		* Scanner Select (purple)
	.dc.w	0,0
	.dc.w	7,2
	.dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$F800,$F800
	.dc.w	$0000,$20F1,$FFFF,$DF0E,$0000,$E000,$F800,$1800
	.dc.w	$0000,$208A,$FFFF,$DF75,$0000,$0000,$F800,$F800
	.dc.w	$0000,$20F1,$FFFF,$DF0E,$0000,$C000,$F800,$3800
	.dc.w	$0000,$2090,$FFFF,$DF6F,$0000,$2000,$F800,$D800
	.dc.w	$0000,$3E8B,$FFFF,$C174,$0000,$C000,$F800,$3800
	.dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$F800,$F800
scnimg2:		* Scanner Select (red)
	.dc.w	0,0
	.dc.w	7,2
	.dc.w	$0000,$FFFF,$FFFF,$FFFF,$0000,$F800,$F800,$F800
	.dc.w	$0000,$FFFF,$FFFF,$DF0E,$0000,$F800,$F800,$1800
	.dc.w	$0000,$FFFF,$FFFF,$DF75,$0000,$F800,$F800,$F800
	.dc.w	$0000,$FFFF,$FFFF,$DF0E,$0000,$F800,$F800,$3800
	.dc.w	$0000,$FFFF,$FFFF,$DF6F,$0000,$F800,$F800,$D800
	.dc.w	$0000,$FFFF,$FFFF,$C174,$0000,$F800,$F800,$3800
	.dc.w	$0000,$FFFF,$FFFF,$FFFF,$0000,$F800,$F800,$F800
scnimg3:		* Scanner Select (black)
	.dc.w	0,0
	.dc.w	7,2
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$0000,$20F1,$20F1,$0000,$0000,$E000,$E000,$0000
	.dc.w	$0000,$208A,$208A,$0000,$0000,$0000,$0000,$0000
	.dc.w	$0000,$20F1,$20F1,$0000,$0000,$C000,$C000,$0000
	.dc.w	$0000,$2090,$2090,$0000,$0000,$2000,$2000,$0000
	.dc.w	$0000,$3E8B,$3E8B,$0000,$0000,$C000,$C000,$0000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
mapimg0:		* Galactic Map Select (white)
	.dc.w	0,0
	.dc.w	7,2
	.dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$F800,$F800
	.dc.w	$2273,$0000,$DD8C,$DD8C,$C000,$0000,$3800,$3800
	.dc.w	$368A,$0000,$C975,$C975,$2000,$0000,$D800,$D800
	.dc.w	$2AFB,$0000,$D504,$D504,$C000,$0000,$3800,$3800
	.dc.w	$228A,$0000,$DD75,$DD75,$0000,$0000,$F800,$F800
	.dc.w	$228A,$0000,$DD75,$DD75,$0000,$0000,$F800,$F800
	.dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$F800,$F800
mapimg1:		* Galactic Map Select (purple)
	.dc.w	0,0
	.dc.w	7,2
	.dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$F800,$F800
	.dc.w	$0000,$2273,$FFFF,$DD8C,$0000,$C000,$F800,$3800
	.dc.w	$0000,$368A,$FFFF,$C975,$0000,$2000,$F800,$D800
	.dc.w	$0000,$2AFB,$FFFF,$D504,$0000,$C000,$F800,$3800
	.dc.w	$0000,$228A,$FFFF,$DD75,$0000,$0000,$F800,$F800
	.dc.w	$0000,$228A,$FFFF,$DD75,$0000,$0000,$F800,$F800
	.dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$F800,$F800
aftimg0:		* Aft-View Select (white)
	.dc.w	0,0
	.dc.w	7,2
	.dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$F800,$F800
	.dc.w	$1CFB,$0000,$E304,$E304,$E000,$0000,$1800,$1800
	.dc.w	$2280,$0000,$DD7F,$DD7F,$8000,$0000,$7800,$7800
	.dc.w	$3EF0,$0000,$C10F,$C10F,$8000,$0000,$7800,$7800
	.dc.w	$2280,$0000,$DD7F,$DD7F,$8000,$0000,$7800,$7800
	.dc.w	$2280,$0000,$DD7F,$DD7F,$8000,$0000,$7800,$7800
	.dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$F800,$F800
aftimg1:		* Aft-View Select (purple)
	.dc.w	0,0
	.dc.w	7,2
	.dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$F800,$F800
	.dc.w	$0000,$1CFB,$FFFF,$E304,$0000,$E000,$F800,$1800
	.dc.w	$0000,$2280,$FFFF,$DD7F,$0000,$8000,$F800,$7800
	.dc.w	$0000,$3EF0,$FFFF,$C10F,$0000,$8000,$F800,$7800
	.dc.w	$0000,$2280,$FFFF,$DD7F,$0000,$8000,$F800,$7800
	.dc.w	$0000,$2280,$FFFF,$DD7F,$0000,$8000,$F800,$7800
	.dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$F800,$F800
aftimg2:		* Aft-View Select (red)
	.dc.w	0,0
	.dc.w	7,2
	.dc.w	$0000,$FFFF,$FFFF,$FFFF,$0000,$F800,$F800,$F800
	.dc.w	$0000,$FFFF,$FFFF,$E304,$0000,$F800,$F800,$1800
	.dc.w	$0000,$FFFF,$FFFF,$DD7F,$0000,$F800,$F800,$7800
	.dc.w	$0000,$FFFF,$FFFF,$C10F,$0000,$F800,$F800,$7800
	.dc.w	$0000,$FFFF,$FFFF,$DD7F,$0000,$F800,$F800,$7800
	.dc.w	$0000,$FFFF,$FFFF,$DD7F,$0000,$F800,$F800,$7800
	.dc.w	$0000,$FFFF,$FFFF,$FFFF,$0000,$F800,$F800,$F800
aftimg3:		* Aft-View Select (black)
	.dc.w	0,0
	.dc.w	7,2
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$0000,$1CFB,$1CFB,$0000,$0000,$E000,$E000,$0000
	.dc.w	$0000,$2280,$2280,$0000,$0000,$8000,$8000,$0000
	.dc.w	$0000,$3EF0,$3EF0,$0000,$0000,$8000,$8000,$0000
	.dc.w	$0000,$2280,$2280,$0000,$0000,$8000,$8000,$0000
	.dc.w	$0000,$2280,$2280,$0000,$0000,$8000,$8000,$0000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000

nukimg0:		* Nuke Light (Yellow)
	.dc.w	0,0
	.dc.w	6,1
	.dc.w	$7E00,$8200,$FC00,$7E00,$3800,$0000,$3800,$3800
	.dc.w	$1000,$0000,$1000,$1000,$EE00,$0000,$EE00,$EE00
	.dc.w	$C600,$0000,$C600,$C600,$4400,$8200,$C600,$4400
nukimg1:		* Nuke Light (Red)
	.dc.w	0,0
	.dc.w	6,1
	.dc.w	$0200,$FE00,$FC00,$7E00,$0000,$3800,$3800,$3800
	.dc.w	$0000,$1000,$1000,$1000,$0000,$EE00,$EE00,$EE00
	.dc.w	$0000,$C600,$C600,$C600,$0000,$C600,$C600,$4400
nukimg2:		* Nuke Door (full closed)
	.dc.w	0,0
	.dc.w	21,2
	.dc.w	$0000,$8888,$8888,$8888,$0000,$8000,$8000,$8000
	.dc.w	$0000,$1111,$1111,$1111,$0000,$0000,$0000,$0000
	.dc.w	$1C41,$3E3F,$3E22,$23FF,$0000,$2000,$2000,$2000
	.dc.w	$1823,$5C5F,$5C44,$67FF,$8000,$C000,$4000,$C000
	.dc.w	$0700,$8F89,$8F88,$B8FF,$0000,$8000,$8000,$8000
	.dc.w	$0800,$1911,$1911,$3113,$8000,$8000,$0000,$8000
	.dc.w	$0000,$2A23,$2A22,$3223,$8000,$A000,$2000,$A000
	.dc.w	$0000,$6C47,$4C46,$7445,$8000,$C000,$4000,$C000
	.dc.w	$0000,$A889,$8888,$B88B,$0000,$8000,$8000,$8000
	.dc.w	$0AEA,$33F9,$13F9,$3D17,$8000,$8000,$0000,$8000
	.dc.w	$09D8,$33FB,$23FA,$3E27,$8000,$A000,$2000,$A000
	.dc.w	$0AAA,$57FD,$47FC,$5C47,$0000,$4000,$4000,$4000
	.dc.w	$0000,$8888,$8888,$8888,$0000,$8000,$8000,$8000
	.dc.w	$0000,$1111,$1111,$1111,$0000,$0000,$0000,$0000
	.dc.w	$0000,$2222,$2222,$2222,$0000,$2000,$2000,$2000
	.dc.w	$0000,$4444,$4444,$4444,$0000,$4000,$4000,$4000
	.dc.w	$0000,$8888,$8888,$8888,$0000,$8000,$8000,$8000
	.dc.w	$0000,$1111,$1111,$1111,$0000,$0000,$0000,$0000
	.dc.w	$0000,$2222,$2222,$2222,$0000,$2000,$2000,$2000
	.dc.w	$0000,$4444,$4444,$4444,$0000,$4000,$4000,$4000
	.dc.w	$0000,$FFFF,$FFFF,$FFFF,$0000,$E000,$E000,$E000
nukimg3:		* Nuke Door (partly closed)
	.dc.w	0,0
	.dc.w	21,2
	.dc.w	$0000,$4444,$4444,$4444,$0000,$4000,$4000,$4000
	.dc.w	$0000,$8888,$8888,$8888,$0000,$8000,$8000,$8000
	.dc.w	$0C62,$1D1F,$1D11,$13FF,$0000,$0000,$0000,$0000
	.dc.w	$1C41,$3E3F,$3E22,$23FF,$8000,$A000,$2000,$A000
	.dc.w	$0B80,$4FC5,$4FC4,$747F,$8000,$C000,$4000,$C000
	.dc.w	$0000,$8889,$8888,$B88B,$0000,$8000,$8000,$8000
	.dc.w	$0000,$3913,$1913,$3111,$8000,$8000,$0000,$8000
	.dc.w	$0000,$2A23,$2A22,$3223,$8000,$A000,$2000,$A000
	.dc.w	$0800,$6C45,$4C44,$7447,$8000,$C000,$4000,$C000
	.dc.w	$0262,$ABF9,$8BF8,$BC8F,$0000,$8000,$8000,$8000
	.dc.w	$2AEA,$33F9,$13F9,$3D17,$8000,$8000,$0000,$8000
	.dc.w	$08C8,$33FB,$23FA,$3E27,$0000,$2000,$2000,$2000
	.dc.w	$0000,$4444,$4444,$4444,$0000,$4000,$4000,$4000
	.dc.w	$0000,$FFFF,$FFFF,$FFFF,$0000,$E000,$E000,$E000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
nukimg4:		* Nuke Door (partly open)
	.dc.w	0,0
	.dc.w	14,2
	.dc.w	$0000,$1111,$1111,$1111,$0000,$0000,$0000,$0000
	.dc.w	$0000,$2222,$2222,$2222,$0000,$2000,$2000,$2000
	.dc.w	$1823,$5C5F,$5C44,$47FF,$0000,$4000,$4000,$4000
	.dc.w	$1463,$9C9F,$9C88,$ABFF,$0000,$8000,$8000,$8000
	.dc.w	$0E80,$1F91,$1F91,$317F,$8000,$8000,$0000,$8000
	.dc.w	$0800,$2A23,$2A22,$3223,$8000,$A000,$2000,$A000
	.dc.w	$0000,$6C47,$4C46,$7445,$8000,$C000,$4000,$C000
	.dc.w	$0000,$FFFF,$FFFF,$FFFF,$0000,$E000,$E000,$E000
	.dc.w	$0800,$2801,$0800,$3003,$8000,$8000,$0000,$8000
	.dc.w	$0AEA,$23F9,$03F8,$3C07,$8000,$8000,$0000,$8000
	.dc.w	$2BFA,$33F9,$03F8,$3C07,$8000,$8000,$0000,$8000
	.dc.w	$0AEA,$13F9,$03F8,$1C07,$0000,$0000,$0000,$0000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
nukimg5:		* Nuke Door (almost full open)
	.dc.w	0,0
	.dc.w	8,2
	.dc.w	$0000,$1111,$1111,$1111,$0000,$0000,$0000,$0000
	.dc.w	$0000,$2222,$2222,$2222,$0000,$2000,$2000,$2000
	.dc.w	$1823,$5C5F,$5C44,$47FF,$0000,$4000,$4000,$4000
	.dc.w	$0000,$FFFF,$FFFF,$FFFF,$0000,$E000,$E000,$E000
	.dc.w	$0F80,$0F81,$0F80,$307F,$8000,$8000,$0000,$8000
	.dc.w	$0800,$0801,$0800,$3003,$8000,$8000,$0000,$8000
	.dc.w	$0000,$2803,$0802,$3001,$8000,$8000,$0000,$8000
	.dc.w	$0000,$2803,$0802,$3001,$8000,$8000,$0000,$8000
nukimg6:		* Nuke Switch (door open, full up)
	.dc.w	0,0
	.dc.w	4,2
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$1C63,$1C1F,$1C00,$03FF,$0000,$0000,$0000,$0000
	.dc.w	$1C63,$1C1F,$1C00,$23FF,$8000,$8000,$0000,$8000
nukimg7:		* Nuke Switch (partly up)
	.dc.w	0,-2
	.dc.w	10,2
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$1C63,$1C1F,$1C00,$03FF,$0000,$0000,$0000,$0000
	.dc.w	$1C63,$1C1F,$1C00,$23FF,$8000,$8000,$0000,$8000
	.dc.w	$0F80,$0F81,$0F80,$307F,$8000,$8000,$0000,$8000
	.dc.w	$0800,$2801,$0800,$3003,$8000,$8000,$0000,$8000
	.dc.w	$0AEA,$23F9,$03F8,$3803,$8000,$8000,$0000,$8000
	.dc.w	$2BFA,$33F9,$03F8,$3803,$8000,$8000,$0000,$8000
	.dc.w	$0AEA,$13F9,$03F8,$1803,$0000,$0000,$0000,$0000
nukimg8:		* Nuke Switch (middle)
	.dc.w	0,-5
	.dc.w	7,2
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$1C63,$1C1F,$1C00,$03FF,$0000,$0000,$0000,$0000
	.dc.w	$1C63,$1C1F,$1C00,$23FF,$8000,$8000,$0000,$8000
	.dc.w	$0F80,$0F81,$0F80,$307F,$8000,$8000,$0000,$8000
	.dc.w	$0575,$09FC,$01FC,$0C01,$0000,$8000,$0000,$8000
nukimg9:		* Nuke Switch (partly down)
	.dc.w	0,-8
	.dc.w	8,2
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$0AEA,$13F9,$03F8,$1803,$0000,$0000,$0000,$0000
	.dc.w	$2BFA,$33F9,$03F8,$3803,$8000,$8000,$0000,$8000
	.dc.w	$0AEA,$23F9,$03F8,$3803,$8000,$8000,$0000,$8000
	.dc.w	$0800,$2801,$0800,$3003,$8000,$8000,$0000,$8000
	.dc.w	$0F80,$0F81,$0F80,$307F,$8000,$8000,$0000,$8000
	.dc.w	$1C63,$1C1F,$1C00,$23FF,$8000,$8000,$0000,$8000
	.dc.w	$1C63,$1C1F,$1C00,$03FF,$0000,$0000,$0000,$0000
nukimg10:		* Nuke Switch (full down)
	.dc.w	0,-9
	.dc.w	10,2
	.dc.w	$0AEA,$13F9,$03F8,$1C07,$0000,$0000,$0000,$0000
	.dc.w	$2BFA,$33F9,$03F8,$3C07,$8000,$8000,$0000,$8000
	.dc.w	$0AEA,$23F9,$03F8,$3C07,$8000,$8000,$0000,$8000
	.dc.w	$0800,$2801,$0800,$3003,$8000,$8000,$0000,$8000
	.dc.w	$0000,$2803,$0802,$3001,$8000,$8000,$0000,$8000
	.dc.w	$0000,$2803,$0802,$3001,$8000,$8000,$0000,$8000
	.dc.w	$0800,$0801,$0800,$3003,$8000,$8000,$0000,$8000
	.dc.w	$0F80,$0F81,$0F80,$307F,$8000,$8000,$0000,$8000
	.dc.w	$1C63,$1C1F,$1C00,$23FF,$8000,$8000,$0000,$8000
	.dc.w	$1C63,$1C1F,$1C00,$03FF,$0000,$0000,$0000,$0000

gunimg0:		* Vertical Gun Light (green)
	.dc.w	0,0
	.dc.w	8,1
	.dc.w	$0000,$0000,$E000,$E000,$0000,$0000,$E000,$E000
	.dc.w	$0000,$0000,$E000,$E000,$0000,$0000,$E000,$E000
	.dc.w	$0000,$0000,$E000,$E000,$0000,$0000,$E000,$E000
	.dc.w	$0000,$0000,$E000,$E000,$0000,$0000,$E000,$E000
gunimg1:		* Vertical Gun Light (red)
	.dc.w	0,0
	.dc.w	8,1
	.dc.w	$0000,$E000,$E000,$E000,$0000,$E000,$E000,$E000
	.dc.w	$0000,$E000,$E000,$E000,$0000,$E000,$E000,$E000
	.dc.w	$0000,$E000,$E000,$E000,$0000,$E000,$E000,$E000
	.dc.w	$0000,$E000,$E000,$E000,$0000,$E000,$E000,$E000
gunimg2:		* Vertical Gun Light (yellow)
	.dc.w	0,0
	.dc.w	8,1
	.dc.w	$E000,$0000,$E000,$E000,$E000,$0000,$E000,$E000
	.dc.w	$E000,$0000,$E000,$E000,$E000,$0000,$E000,$E000
	.dc.w	$E000,$0000,$E000,$E000,$E000,$0000,$E000,$E000
	.dc.w	$E000,$0000,$E000,$E000,$E000,$0000,$E000,$E000
gunimg3:		* Horizontal Gun Light (green)
	.dc.w	0,0
	.dc.w	5,1
	.dc.w	$7FF0,$7070,$4010,$3FE0,$E038,$C038,$9FC8,$5FF0
	.dc.w	$E030,$6038,$1FC0,$FFF8,$6018,$2000,$1FC0,$FFF8
	.dc.w	$3FE0,$BFE8,$BFE8,$4010
gunimg4:		* Horizontal Gun Light (red)
	.dc.w	0,0
	.dc.w	5,1
	.dc.w	$7FF0,$7070,$4010,$3FE0,$E038,$DFF8,$9FC8,$5FF0
	.dc.w	$E030,$7FF8,$1FC0,$FFF8,$6018,$3FC0,$1FC0,$FFF8
	.dc.w	$3FE0,$BFE8,$BFE8,$4010
gunimg5:		* Horizontal Gun Light (yellow)
	.dc.w	0,0
	.dc.w	5,1
	.dc.w	$7FF0,$7070,$4010,$3FE0,$FFF8,$C038,$9FC8,$5FF0
	.dc.w	$FFF0,$6038,$1FC0,$FFF8,$7FD8,$2000,$1FC0,$FFF8
	.dc.w	$3FE0,$BFE8,$BFE8,$4010

shdimg0:		* Shield Switch (off)
	.dc.w	0,0
	.dc.w	11,2
	.dc.w	$FEF7,$FEB7,$FE87,$0070,$FFC0,$FFC0,$FFC0,$0000
	.dc.w	$0158,$FD2B,$FD03,$00E8,$0000,$FFC0,$FFC0,$0000
	.dc.w	$FD6B,$1D18,$1D00,$E0FB,$FFC0,$0000,$0000,$FFC0
	.dc.w	$FD3B,$1D08,$1D00,$E0FB,$FDC0,$0200,$0200,$FFC0
	.dc.w	$FD83,$1D80,$1D80,$E07B,$FDC0,$0200,$0200,$FFC0
	.dc.w	$82F7,$62F0,$7EF0,$E007,$F040,$0F80,$0F80,$FFC0
	.dc.w	$FF6F,$0F60,$0F60,$F00F,$FDC0,$0200,$0200,$FFC0
	.dc.w	$FF0F,$0600,$0600,$F96F,$FDC0,$0200,$0200,$FFC0
	.dc.w	$FF6F,$0F0F,$0F0F,$F060,$FFC0,$FE00,$FE00,$01C0
	.dc.w	$F70F,$1F68,$1B08,$E467,$FDC0,$0F00,$0300,$FCC0
	.dc.w	$E400,$3C00,$3000,$CC60,$0CC0,$0F80,$0180,$0E40
shdimg1:		* Shield Switch (on)
	.dc.w	0,0
	.dc.w	11,2
	.dc.w	$FFFB,$FFFA,$FFFA,$0001,$DFC0,$DFC0,$1FC0,$C000
	.dc.w	$0005,$FFF4,$FFF4,$0003,$6000,$AFC0,$0FC0,$A000
	.dc.w	$FFF5,$0074,$0074,$FF83,$AFC0,$6000,$0000,$EFC0
	.dc.w	$FFF4,$0074,$0074,$FF83,$EDC0,$2200,$0200,$EFC0
	.dc.w	$FFF6,$0076,$0076,$FF81,$0DC0,$0200,$0200,$EFC0
	.dc.w	$83FB,$7C7B,$7C7B,$FF80,$D040,$CF80,$CF80,$1FC0
	.dc.w	$FFFD,$003D,$003D,$FFC0,$BDC0,$8200,$8200,$3FC0
	.dc.w	$FFFC,$0018,$0018,$FFE5,$3DC0,$0200,$0200,$BFC0
	.dc.w	$FFFD,$07FC,$07FC,$F801,$BFC0,$3E00,$3E00,$81C0
	.dc.w	$F7CC,$1C0D,$180C,$E7F1,$3DC0,$AF00,$2300,$9CC0
	.dc.w	$E400,$3C00,$3000,$CC01,$0CC0,$0F80,$0180,$8E40
shdimg2:		* Shield Button (black)
	.dc.w	0,0
	.dc.w	2,1
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
shdimg3:		* Shield Button (green)
	.dc.w	0,0
	.dc.w	2,1
	.dc.w	$0000,$0000,$FF00,$FF00,$0000,$0000,$FF00,$FF00
shdimg4:		* Shield Button (red)
	.dc.w	0,0
	.dc.w	2,1
	.dc.w	$0000,$FF00,$FF00,$FF00,$0000,$FF00,$FF00,$FF00
shdimg5:		* Shield Button (yellow)
	.dc.w	0,0
	.dc.w	2,1
	.dc.w	$FF00,$0000,$FF00,$FF00,$FF00,$0000,$FF00,$FF00
bshimg0:		* Shield Busy Box
	.dc.w	0,0
	.dc.w	21,1
	.dc.w	$F500,$FC80,$1C00,$E380,$EA00,$3900,$3800,$C700
	.dc.w	$D400,$F200,$F000,$0E00,$A800,$E400,$E000,$1C00
	.dc.w	$5000,$C800,$C000,$3800,$A440,$9000,$8000,$7440
	.dc.w	$4000,$2000,$0000,$E000,$8000,$4000,$0000,$C000
	.dc.w	$0000,$8000,$0000,$8000,$0000,$0000,$0000,$0000
	.dc.w	$0000,$0080,$0000,$0000,$0000,$0100,$0000,$0000
	.dc.w	$0000,$0240,$0000,$0040,$4440,$0080,$0000,$44C0
	.dc.w	$0080,$0100,$0000,$01C0,$0140,$1240,$0040,$0380
	.dc.w	$0280,$24C0,$00C0,$0700,$0500,$49C0,$0180,$0E40
	.dc.w	$0AC0,$1300,$0300,$1CC0,$1400,$2640,$0640,$3980
	.dc.w	$2B00,$4F80,$0F80,$7040
bshimg1:		* Shield Busy Box
	.dc.w	0,0
	.dc.w	21,1
	.dc.w	$F500,$FC80,$1C00,$E380,$EA00,$3900,$3800,$C700
	.dc.w	$D400,$F200,$F000,$0E00,$A800,$E400,$E000,$1C00
	.dc.w	$5400,$CC00,$C000,$3C00,$A440,$9000,$8000,$7000
	.dc.w	$4480,$2480,$0000,$E480,$8000,$4500,$0000,$C500
	.dc.w	$0080,$8080,$0000,$8000,$0100,$0100,$0000,$0000
	.dc.w	$0200,$0200,$0000,$0000,$0000,$1400,$0000,$1400
	.dc.w	$2400,$2440,$0000,$2440,$5440,$1080,$0000,$00C0
	.dc.w	$A480,$A500,$0000,$85C0,$4140,$4240,$0040,$0380
	.dc.w	$0280,$04C0,$00C0,$0700,$0500,$09C0,$0180,$0E40
	.dc.w	$0AC0,$1300,$0300,$1CC0,$1400,$2640,$0640,$3980
	.dc.w	$2B00,$4F80,$0F80,$7040
bshimg2:		* Shield Busy Box
	.dc.w	0,0
	.dc.w	21,1
	.dc.w	$F500,$FC80,$1C00,$E380,$EA00,$3900,$3800,$C700
	.dc.w	$D400,$F200,$F000,$0E00,$AA00,$E600,$E200,$1C00
	.dc.w	$5000,$C800,$C000,$3A00,$A200,$9000,$8000,$7200
	.dc.w	$4000,$2000,$0000,$E040,$8000,$4500,$0080,$C500
	.dc.w	$0600,$8600,$0100,$8600,$0400,$0000,$0200,$0000
	.dc.w	$0C00,$0C00,$0000,$0C00,$2000,$1400,$0000,$3400
	.dc.w	$0000,$0040,$1000,$4040,$8840,$8080,$A000,$08C0
	.dc.w	$0080,$0100,$4000,$09C0,$0940,$0A40,$0840,$0380
	.dc.w	$0280,$04C0,$00C0,$0700,$0500,$09C0,$0180,$0E40
	.dc.w	$0AC0,$1300,$0300,$1CC0,$1400,$2640,$0640,$3980
	.dc.w	$2B00,$4F80,$0F80,$7040
bshimg3:		* Shield Busy Box
	.dc.w	0,0
	.dc.w	21,1
	.dc.w	$F500,$FC80,$1C00,$E380,$EA40,$3940,$3840,$C700
	.dc.w	$D400,$F200,$F000,$0E00,$A800,$E400,$E000,$1C80
	.dc.w	$5000,$C800,$C000,$3800,$A100,$9000,$8000,$7100
	.dc.w	$4080,$2000,$0080,$E080,$8100,$4200,$0100,$C300
	.dc.w	$0200,$8000,$0200,$8200,$5540,$4E40,$4040,$3F80
	.dc.w	$0000,$0000,$0000,$0000,$1000,$0800,$1000,$1800
	.dc.w	$2000,$0040,$2000,$2040,$5040,$0080,$4000,$50C0
	.dc.w	$0080,$0100,$0000,$01C0,$0140,$0240,$0040,$2380
	.dc.w	$0280,$04C0,$00C0,$0700,$4500,$49C0,$4180,$0E40
	.dc.w	$0AC0,$1300,$0300,$1CC0,$1400,$2640,$0640,$3980
	.dc.w	$2B00,$4F80,$0F80,$7040
bshimg4:		* Shield Busy Box
	.dc.w	0,0
	.dc.w	21,1
	.dc.w	$F500,$FC80,$1C00,$E380,$EA00,$3900,$3800,$C700
	.dc.w	$D400,$F200,$F000,$0E00,$A800,$E400,$E000,$1C00
	.dc.w	$5000,$C800,$C000,$3800,$A080,$9000,$8080,$7000
	.dc.w	$4100,$2000,$0100,$E000,$8A00,$4800,$0A00,$C000
	.dc.w	$0600,$8000,$0000,$8E00,$0000,$0400,$0000,$0400
	.dc.w	$1C00,$0000,$1000,$0E00,$2200,$0200,$2200,$0000
	.dc.w	$4000,$0040,$4000,$1040,$2040,$2080,$2000,$00C0
	.dc.w	$0080,$0100,$0000,$01C0,$0140,$0240,$0040,$0380
	.dc.w	$0280,$04C0,$00C0,$0700,$0500,$09C0,$0180,$0E40
	.dc.w	$0AC0,$1300,$0300,$1CC0,$1400,$2640,$0640,$3980
	.dc.w	$2B00,$4F80,$0F80,$7040
bshimg5:		* Shield Busy Box
	.dc.w	0,0
	.dc.w	21,1
	.dc.w	$F500,$FC80,$1C00,$E380,$EA00,$3900,$3800,$C700
	.dc.w	$D400,$F200,$F000,$0E00,$A800,$E400,$E000,$1C00
	.dc.w	$5000,$C800,$C080,$3800,$A000,$9000,$8100,$7000
	.dc.w	$4000,$2000,$0200,$E000,$8500,$4500,$0500,$C000
	.dc.w	$0000,$8000,$0000,$8600,$0400,$0000,$1000,$0400
	.dc.w	$0000,$0000,$2000,$0C00,$1400,$1400,$5400,$0000
	.dc.w	$0000,$0040,$0000,$0040,$0040,$0080,$0000,$00C0
	.dc.w	$0080,$0100,$0000,$01C0,$0140,$0240,$0040,$0380
	.dc.w	$0280,$04C0,$00C0,$0700,$0500,$09C0,$0180,$0E40
	.dc.w	$0AC0,$1300,$0300,$1CC0,$1400,$2640,$0640,$3980
	.dc.w	$2B00,$4F80,$0F80,$7040
bshimg6:		* Shield Busy Box
	.dc.w	0,0
	.dc.w	21,1
	.dc.w	$F500,$FC80,$1C00,$E380,$EA00,$3900,$3800,$C700
	.dc.w	$D400,$F200,$F000,$0E00,$A880,$E480,$E000,$1C00
	.dc.w	$5100,$C900,$C000,$3800,$A200,$9200,$8000,$7000
	.dc.w	$4000,$2000,$0000,$E000,$8200,$4200,$0200,$C000
	.dc.w	$1000,$9000,$0000,$8000,$2A00,$2A00,$0A00,$0400
	.dc.w	$4000,$4000,$0000,$0000,$0800,$0800,$0800,$0000
	.dc.w	$0000,$0040,$0000,$0040,$0040,$0080,$0000,$00C0
	.dc.w	$0080,$0100,$0000,$01C0,$0140,$0240,$0040,$0380
	.dc.w	$0280,$04C0,$00C0,$0700,$0500,$09C0,$0180,$0E40
	.dc.w	$0AC0,$1300,$0300,$1CC0,$1400,$2640,$0640,$3980
	.dc.w	$2B00,$4F80,$0F80,$7040
bshimg7:		* Shield Busy Box
	.dc.w	0,0
	.dc.w	21,1
	.dc.w	$F500,$FC80,$1C00,$E380,$EA00,$3900,$3800,$C700
	.dc.w	$D400,$F280,$F000,$0E00,$A800,$E500,$E000,$1C00
	.dc.w	$5000,$CA00,$C000,$3800,$A000,$9000,$8000,$7000
	.dc.w	$4000,$2000,$0000,$E000,$8000,$5000,$0000,$C000
	.dc.w	$0000,$A000,$0000,$8000,$0400,$4400,$0400,$0000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$0000,$0040,$0000,$0040,$0040,$0080,$0000,$00C0
	.dc.w	$0080,$0100,$0000,$01C0,$0140,$0240,$0040,$0380
	.dc.w	$0280,$04C0,$00C0,$0700,$0500,$09C0,$0180,$0E40
	.dc.w	$0AC0,$1300,$0300,$1CC0,$1400,$2640,$0640,$3980
	.dc.w	$2B00,$4F80,$0F80,$7040
eshimg0:		* Shield Effect
	.dc.w	4,4
	.dc.w	9,1
	.dc.w	$0800,$0000,$0000,$0800,$0000,$0000,$0000,$0000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$8080,$0000,$0000,$8080,$0000,$0000,$0000,$0000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$0800,$0000,$0000,$0800
eshimg1:		* Shield Effect
	.dc.w	6,6
	.dc.w	11,1
	.dc.w	$0400,$0400,$0000,$0400,$0400,$0000,$0000,$0000
	.dc.w	$0400,$0400,$0000,$0400,$0000,$0400,$0000,$0400
	.dc.w	$0000,$0000,$0000,$0000,$E0E0,$B1A0,$0000,$B1A0
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0400,$0000,$0400
	.dc.w	$0400,$0400,$0000,$0400,$0400,$0000,$0000,$0000
	.dc.w	$0400,$0400,$0000,$0400
eshimg2:		* Shield Effect
	.dc.w	5,5
	.dc.w	11,1
	.dc.w	$0200,$0200,$0200,$0000,$0000,$0000,$0000,$0200
	.dc.w	$0200,$0000,$0000,$0200,$0000,$0400,$0000,$0400
	.dc.w	$A400,$8400,$8000,$6400,$0E00,$1B00,$0000,$1B00
	.dc.w	$04A0,$0420,$0020,$04C0,$0000,$0400,$0000,$0400
	.dc.w	$0800,$0000,$0000,$0800,$0000,$0000,$0000,$0800
	.dc.w	$0800,$0800,$0800,$0000
eshimg3:		* Shield Effect
	.dc.w	4,4
	.dc.w	9,1
	.dc.w	$8080,$8080,$8080,$0000,$0000,$0000,$0000,$4100
	.dc.w	$2200,$0000,$0000,$2200,$0000,$1400,$0000,$1400
	.dc.w	$0800,$0800,$0000,$0800,$0000,$1400,$0000,$1400
	.dc.w	$2200,$0000,$0000,$2200,$0000,$0000,$0000,$4100
	.dc.w	$8080,$8080,$8080,$0000
eshimg4:		* Shield Effect
	.dc.w	3,3
	.dc.w	7,1
	.dc.w	$2000,$2000,$2000,$0000,$0000,$0000,$0000,$2000
	.dc.w	$1200,$0200,$0200,$1400,$2800,$1000,$0000,$3800
	.dc.w	$9000,$8000,$8000,$5000,$0000,$0000,$0000,$0800
	.dc.w	$0800,$0800,$0800,$0000
eshimg5:		* Shield Effect
	.dc.w	2,2
	.dc.w	5,1
	.dc.w	$2000,$2000,$2000,$0000,$0000,$0000,$0000,$2000
	.dc.w	$A800,$8800,$8800,$7000,$0000,$0000,$0000,$2000
	.dc.w	$2000,$2000,$2000,$0000
eshimg6:		* Shield Effect
	.dc.w	1,1
	.dc.w	3,1
	.dc.w	$A000,$A000,$A000,$0000,$0000,$0000,$0000,$4000
	.dc.w	$A000,$A000,$A000,$0000
eshimg7:		* Shield Effect
	.dc.w	0,0
	.dc.w	1,1
	.dc.w	$8000,$8000,$8000,$0000
ashimg0:		* Shield Effect (AFT)
	.dc.w	0,0
	.dc.w	1,1
	.dc.w	$8000,$8000,$8000,$0000
ashimg1:		* Shield Effect (AFT)
	.dc.w	1,1
	.dc.w	3,1
	.dc.w	$A000,$A000,$A000,$0000,$0000,$0000,$0000,$4000
	.dc.w	$A000,$A000,$A000,$0000
ashimg2:		* Shield Effect (AFT)
	.dc.w	2,2
	.dc.w	5,1
	.dc.w	$2000,$2000,$2000,$0000,$0000,$0000,$0000,$2000
	.dc.w	$A800,$8800,$8800,$7000,$0000,$0000,$0000,$2000
	.dc.w	$2000,$2000,$2000,$0000
ashimg3:		* Shield Effect (AFT)
	.dc.w	3,3
	.dc.w	7,1
	.dc.w	$2000,$2000,$2000,$0000,$0000,$0000,$0000,$2000
	.dc.w	$1200,$0200,$0200,$1400,$2800,$1000,$0000,$3800
	.dc.w	$9000,$8000,$8000,$5000,$0000,$0000,$0000,$0800
	.dc.w	$0800,$0800,$0800,$0000
ashimg4:		* Shield Effect (AFT)
	.dc.w	3,3
	.dc.w	7,1
	.dc.w	$8200,$8200,$8200,$0000,$0000,$0000,$0000,$4400
	.dc.w	$2800,$0000,$0000,$2800,$0000,$1000,$0000,$1000
	.dc.w	$2800,$0000,$0000,$2800,$0000,$0000,$0000,$4400
	.dc.w	$8200,$8200,$8200,$0000
ashimg5:		* Shield Effect (AFT)
	.dc.w	3,3
	.dc.w	7,1
	.dc.w	$0800,$0800,$0800,$0000,$0000,$0000,$0000,$0800
	.dc.w	$9000,$8000,$8000,$5000,$2800,$1000,$0000,$3800
	.dc.w	$1200,$0200,$0200,$1400,$0000,$0000,$0000,$2000
	.dc.w	$2000,$2000,$2000,$0000
ashimg6:		* Shield Effect (AFT)
	.dc.w	3,3
	.dc.w	7,1
	.dc.w	$1000,$1000,$1000,$0000,$0000,$0000,$0000,$1000
	.dc.w	$1000,$0000,$0000,$1000,$AA00,$8200,$8200,$6C00
	.dc.w	$1000,$0000,$0000,$1000,$0000,$0000,$0000,$1000
	.dc.w	$1000,$1000,$1000,$0000
ashimg7:		* Shield Effect (AFT)
	.dc.w	2,2
	.dc.w	5,1
	.dc.w	$0000,$0000,$0000,$2000,$0000,$0000,$0000,$0000
	.dc.w	$0000,$0000,$0000,$8800,$0000,$0000,$0000,$0000
	.dc.w	$0000,$0000,$0000,$2000

wrpimg0:		* Warp-Drive Panel (green)
	.dc.w	0,0
	.dc.w	62,2
	.dc.w	$FFFF,$FFFF,$FFFF,$0000,$E000,$F000,$F000,$0000
	.dc.w	$0000,$3FFF,$3FFF,$0000,$0000,$E000,$E000,$0000
	.dc.w	$1040,$377F,$327F,$0D80,$0000,$E000,$E000,$0000
	.dc.w	$1040,$357F,$307F,$0D80,$0000,$E000,$E000,$0000
	.dc.w	$1440,$317F,$307F,$0D80,$0000,$E000,$E000,$0000
	.dc.w	$1540,$347C,$307F,$0D83,$0000,$2000,$E000,$C000
	.dc.w	$1F40,$3E78,$347B,$0B83,$0000,$2000,$6000,$4000
	.dc.w	$1F58,$3E64,$3467,$0B9B,$0000,$2000,$E000,$C000
	.dc.w	$1F40,$3E44,$3444,$0B80,$0000,$2000,$6000,$4000
	.dc.w	$1FC0,$3FFF,$307F,$0F80,$0000,$2000,$6000,$4000
	.dc.w	$1DC0,$3DFF,$3DFF,$0000,$0000,$6000,$6000,$0000
	.dc.w	$1040,$357F,$307F,$0D80,$0000,$E000,$E000,$0000
	.dc.w	$1058,$3567,$3063,$0D9C,$0000,$E000,$E000,$0000
	.dc.w	$1040,$3547,$3047,$0D80,$0000,$E000,$E000,$0000
	.dc.w	$1040,$357F,$307F,$0D80,$0000,$E000,$E000,$0000
	.dc.w	$1040,$357F,$307F,$0D80,$0000,$E000,$E000,$0000
	.dc.w	$1040,$357F,$307F,$0D80,$0000,$E000,$E000,$0000
	.dc.w	$1058,$3567,$3063,$0D9C,$0000,$E000,$E000,$0000
	.dc.w	$1040,$3547,$3047,$0D80,$0000,$E000,$E000,$0000
	.dc.w	$1540,$307F,$307F,$0D80,$0000,$E000,$E000,$0000
	.dc.w	$15C0,$35FD,$317F,$0C82,$0000,$E000,$E000,$0000
	.dc.w	$1FC0,$3FF9,$357B,$0A82,$0000,$E000,$E000,$0000
	.dc.w	$1FD8,$3FE4,$34E7,$0B1B,$0000,$2000,$E000,$C000
	.dc.w	$1F40,$3F44,$3546,$0A82,$0000,$2000,$E000,$C000
	.dc.w	$1FC0,$3FF8,$307B,$0F83,$0000,$2000,$E000,$C000
	.dc.w	$1DC0,$3DF8,$3DF8,$0000,$0000,$6000,$6000,$0000
	.dc.w	$1540,$307F,$307F,$0D80,$0000,$E000,$E000,$0000
	.dc.w	$154C,$3073,$3073,$0D8C,$0000,$E000,$E000,$0000
	.dc.w	$1540,$3047,$3047,$0D80,$0000,$E000,$E000,$0000
	.dc.w	$1540,$307F,$307F,$0D80,$0000,$E000,$E000,$0000
	.dc.w	$1540,$307F,$307F,$0D80,$0000,$E000,$E000,$0000
	.dc.w	$1540,$307F,$307F,$0D80,$0000,$E000,$E000,$0000
	.dc.w	$1558,$3067,$3063,$0D9C,$0000,$E000,$E000,$0000
	.dc.w	$1540,$3047,$3047,$0D80,$0000,$E000,$E000,$0000
	.dc.w	$1540,$347F,$347F,$0980,$0000,$E000,$E000,$0000
	.dc.w	$1FC0,$3FFC,$387F,$0783,$0000,$2000,$E000,$C000
	.dc.w	$1FC0,$3FF8,$35F8,$0A00,$0000,$2000,$E000,$C000
	.dc.w	$1F58,$3F64,$3565,$0A99,$0000,$6000,$E000,$8000
	.dc.w	$1F40,$3F46,$3546,$0A80,$0000,$2000,$E000,$C000
	.dc.w	$1FC0,$3FFC,$387F,$0783,$0000,$2000,$E000,$C000
	.dc.w	$15C0,$35F8,$35F8,$0800,$0000,$6000,$6000,$0000
	.dc.w	$1540,$307F,$307F,$0D80,$0000,$E000,$E000,$0000
	.dc.w	$1058,$3567,$3063,$0D9C,$0000,$E000,$E000,$0000
	.dc.w	$1040,$3567,$3067,$0D80,$0000,$E000,$E000,$0000
	.dc.w	$1040,$357F,$307F,$0D80,$0000,$E000,$E000,$0000
	.dc.w	$1040,$357F,$307F,$0D80,$0000,$E000,$E000,$0000
	.dc.w	$1040,$357F,$307F,$0D80,$0000,$E000,$E000,$0000
	.dc.w	$1058,$3567,$3063,$0D9C,$0000,$E000,$E000,$0000
	.dc.w	$1040,$3567,$3067,$0D80,$0000,$E000,$E000,$0000
	.dc.w	$1540,$307F,$307F,$0D80,$0000,$E000,$E000,$0000
	.dc.w	$1FC0,$3FFC,$307F,$0F83,$0000,$2000,$E000,$C000
	.dc.w	$1DC0,$3DF8,$3CFA,$0102,$0000,$2000,$6000,$4000
	.dc.w	$1FD0,$3FE4,$39E6,$0612,$0000,$2000,$E000,$C000
	.dc.w	$1DC0,$3DC4,$3CC6,$0102,$0000,$2000,$E000,$C000
	.dc.w	$1FC0,$3FF8,$307B,$0F83,$0000,$2000,$E000,$C000
	.dc.w	$1DC0,$3DF8,$3DF8,$0000,$0000,$6000,$6000,$0000
	.dc.w	$1040,$357F,$307F,$0D80,$0000,$E000,$E000,$0000
	.dc.w	$1040,$377F,$327F,$0D80,$0000,$E000,$E000,$0000
	.dc.w	$1040,$377F,$327F,$0D80,$0000,$E000,$E000,$0000
	.dc.w	$1040,$377F,$327F,$0D80,$0000,$E000,$E000,$0000
	.dc.w	$1040,$377F,$327F,$0D80,$0000,$E000,$E000,$0000
	.dc.w	$0000,$3FFF,$3FFF,$0000,$0000,$E000,$E000,$0000
wrpimg1:		* Warp-Drive Panel (red)
	.dc.w	0,0
	.dc.w	62,2
	.dc.w	$FFFF,$FFFF,$FFFF,$0000,$E000,$F000,$F000,$0000
	.dc.w	$0000,$3FFF,$3FFF,$0000,$0000,$E000,$E000,$0000
	.dc.w	$1040,$377F,$327F,$0D80,$0000,$E000,$E000,$0000
	.dc.w	$1040,$357F,$307F,$0D80,$0000,$E000,$E000,$0000
	.dc.w	$1440,$317F,$307F,$0D80,$0000,$E000,$E000,$0000
	.dc.w	$1540,$347F,$307F,$0D83,$0000,$E000,$E000,$C000
	.dc.w	$1F40,$3E7B,$347B,$0B83,$0000,$6000,$6000,$4000
	.dc.w	$1F58,$3E67,$3467,$0B9B,$0000,$E000,$E000,$C000
	.dc.w	$1F40,$3E44,$3444,$0B80,$0000,$6000,$6000,$4000
	.dc.w	$1FC0,$3FFF,$307F,$0F80,$0000,$6000,$6000,$4000
	.dc.w	$1DC0,$3DFF,$3DFF,$0000,$0000,$6000,$6000,$0000
	.dc.w	$1040,$357F,$307F,$0D80,$0000,$E000,$E000,$0000
	.dc.w	$1058,$3567,$3063,$0D9C,$0000,$E000,$E000,$0000
	.dc.w	$1040,$3547,$3047,$0D80,$0000,$E000,$E000,$0000
	.dc.w	$1040,$357F,$307F,$0D80,$0000,$E000,$E000,$0000
	.dc.w	$1040,$357F,$307F,$0D80,$0000,$E000,$E000,$0000
	.dc.w	$1040,$357F,$307F,$0D80,$0000,$E000,$E000,$0000
	.dc.w	$1058,$3567,$3063,$0D9C,$0000,$E000,$E000,$0000
	.dc.w	$1040,$3547,$3047,$0D80,$0000,$E000,$E000,$0000
	.dc.w	$1540,$307F,$307F,$0D80,$0000,$E000,$E000,$0000
	.dc.w	$15C0,$35FF,$317F,$0C82,$0000,$E000,$E000,$0000
	.dc.w	$1FC0,$3FFB,$357B,$0A82,$0000,$E000,$E000,$0000
	.dc.w	$1FD8,$3FE7,$34E7,$0B1B,$0000,$E000,$E000,$C000
	.dc.w	$1F40,$3F46,$3546,$0A82,$0000,$E000,$E000,$C000
	.dc.w	$1FC0,$3FFB,$307B,$0F83,$0000,$E000,$E000,$C000
	.dc.w	$1DC0,$3DF8,$3DF8,$0000,$0000,$6000,$6000,$0000
	.dc.w	$1540,$307F,$307F,$0D80,$0000,$E000,$E000,$0000
	.dc.w	$154C,$3073,$3073,$0D8C,$0000,$E000,$E000,$0000
	.dc.w	$1540,$3047,$3047,$0D80,$0000,$E000,$E000,$0000
	.dc.w	$1540,$307F,$307F,$0D80,$0000,$E000,$E000,$0000
	.dc.w	$1540,$307F,$307F,$0D80,$0000,$E000,$E000,$0000
	.dc.w	$1540,$307F,$307F,$0D80,$0000,$E000,$E000,$0000
	.dc.w	$1558,$3067,$3063,$0D9C,$0000,$E000,$E000,$0000
	.dc.w	$1540,$3047,$3047,$0D80,$0000,$E000,$E000,$0000
	.dc.w	$1540,$347F,$347F,$0980,$0000,$E000,$E000,$0000
	.dc.w	$1FC0,$3FFF,$387F,$0783,$0000,$E000,$E000,$C000
	.dc.w	$1FC0,$3FF8,$35F8,$0A00,$0000,$E000,$E000,$C000
	.dc.w	$1F58,$3F65,$3565,$0A99,$0000,$E000,$E000,$8000
	.dc.w	$1F40,$3F46,$3546,$0A80,$0000,$E000,$E000,$C000
	.dc.w	$1FC0,$3FFF,$387F,$0783,$0000,$E000,$E000,$C000
	.dc.w	$15C0,$35F8,$35F8,$0800,$0000,$6000,$6000,$0000
	.dc.w	$1540,$307F,$307F,$0D80,$0000,$E000,$E000,$0000
	.dc.w	$1058,$3567,$3063,$0D9C,$0000,$E000,$E000,$0000
	.dc.w	$1040,$3567,$3067,$0D80,$0000,$E000,$E000,$0000
	.dc.w	$1040,$357F,$307F,$0D80,$0000,$E000,$E000,$0000
	.dc.w	$1040,$357F,$307F,$0D80,$0000,$E000,$E000,$0000
	.dc.w	$1040,$357F,$307F,$0D80,$0000,$E000,$E000,$0000
	.dc.w	$1058,$3567,$3063,$0D9C,$0000,$E000,$E000,$0000
	.dc.w	$1040,$3567,$3067,$0D80,$0000,$E000,$E000,$0000
	.dc.w	$1540,$307F,$307F,$0D80,$0000,$E000,$E000,$0000
	.dc.w	$1FC0,$3FFF,$307F,$0F83,$0000,$E000,$E000,$C000
	.dc.w	$1DC0,$3DFA,$3CFA,$0102,$0000,$6000,$6000,$4000
	.dc.w	$1FD0,$3FE6,$39E6,$0612,$0000,$E000,$E000,$C000
	.dc.w	$1DC0,$3DC6,$3CC6,$0102,$0000,$E000,$E000,$C000
	.dc.w	$1FC0,$3FFB,$307B,$0F83,$0000,$E000,$E000,$C000
	.dc.w	$1DC0,$3DF8,$3DF8,$0000,$0000,$6000,$6000,$0000
	.dc.w	$1040,$357F,$307F,$0D80,$0000,$E000,$E000,$0000
	.dc.w	$1040,$377F,$327F,$0D80,$0000,$E000,$E000,$0000
	.dc.w	$1040,$377F,$327F,$0D80,$0000,$E000,$E000,$0000
	.dc.w	$1040,$377F,$327F,$0D80,$0000,$E000,$E000,$0000
	.dc.w	$1040,$377F,$327F,$0D80,$0000,$E000,$E000,$0000
	.dc.w	$0000,$3FFF,$3FFF,$0000,$0000,$E000,$E000,$0000
wrpimg2:		* Warp-Drive Selector (green)
	.dc.w	0,0
	.dc.w	7,1
	.dc.w	$0000,$0F80,$0F80,$0000,$0A80,$18C0,$18C0,$0700
	.dc.w	$1FC0,$E038,$FFF8,$1FC0,$F078,$0000,$FFF8,$FFF8
	.dc.w	$1FC0,$E038,$FFF8,$1FC0,$0A80,$18C0,$18C0,$0700
	.dc.w	$0000,$0F80,$0F80,$0000
wrpimg3:		* Warp-Drive Selector (red)
	.dc.w	0,0
	.dc.w	7,1
	.dc.w	$0000,$0F80,$0F80,$0000,$0A80,$18C0,$18C0,$0700
	.dc.w	$1FC0,$E038,$FFF8,$1FC0,$F078,$0F80,$FFF8,$FFF8
	.dc.w	$1FC0,$E038,$FFF8,$1FC0,$0A80,$18C0,$18C0,$0700
	.dc.w	$0000,$0F80,$0F80,$0000

hypimg0:		* Hyper-Drive Switch (off)
	.dc.w	0,0
	.dc.w	16,2
	.dc.w	$1EDB,$01DC,$01DC,$1E03,$C000,$0000,$0000,$C000
	.dc.w	$1EDB,$01DC,$01DC,$1E03,$C000,$0000,$0000,$C000
	.dc.w	$1E03,$0104,$0104,$1EDB,$C000,$0000,$0000,$C000
	.dc.w	$1E03,$0104,$0104,$1EDB,$C000,$0000,$0000,$C000
	.dc.w	$1EDB,$0104,$0104,$1EDB,$C000,$0000,$0000,$C000
	.dc.w	$1EDB,$0104,$0104,$1EDB,$C000,$0000,$0000,$C000
	.dc.w	$1E03,$01DC,$0104,$1EDB,$C000,$0000,$0000,$C000
	.dc.w	$1EDB,$01DC,$0104,$1EDB,$C000,$0000,$0000,$C000
	.dc.w	$1E03,$01DC,$01DC,$1E03,$C000,$0000,$0000,$C000
	.dc.w	$0154,$FF27,$FF07,$00F8,$0000,$F800,$F800,$0000
	.dc.w	$7376,$F0C8,$F000,$0FCF,$7000,$7800,$7800,$8000
	.dc.w	$7336,$F0F8,$F000,$0FFF,$7000,$7800,$7800,$8000
	.dc.w	$0154,$FF27,$FF07,$00F8,$0000,$F800,$F800,$0000
	.dc.w	$1E03,$03DC,$03DC,$1C03,$C000,$0000,$0000,$C000
	.dc.w	$1EDB,$07DC,$07DC,$1803,$C000,$0000,$0000,$C000
	.dc.w	$1E03,$0FDC,$0FDC,$1003,$C000,$0000,$0000,$C000
hypimg1:		* Hyper-Drive Switch (on)
	.dc.w	0,0
	.dc.w	16,2
	.dc.w	$1EDB,$01DC,$01DC,$1E03,$C000,$0000,$0000,$C000
	.dc.w	$1EDB,$01DC,$01DC,$1E03,$C000,$0000,$0000,$C000
	.dc.w	$1E03,$01DC,$01DC,$1E03,$C000,$0000,$0000,$C000
	.dc.w	$0154,$FF27,$FF07,$00F8,$0000,$F800,$F800,$0000
	.dc.w	$7376,$F0C8,$F000,$0FCF,$7000,$7800,$7800,$8000
	.dc.w	$7336,$F0F8,$F000,$0FFF,$7000,$7800,$7800,$8000
	.dc.w	$0154,$FF27,$FF07,$00F8,$0000,$F800,$F800,$0000
	.dc.w	$1E03,$03DC,$03DC,$1C03,$C000,$0000,$0000,$C000
	.dc.w	$1EDB,$07DC,$07DC,$1803,$C000,$0000,$0000,$C000
	.dc.w	$1EDB,$0FC4,$0FC4,$101B,$C000,$0000,$0000,$C000
	.dc.w	$1EDB,$1F84,$1F84,$005B,$C000,$0000,$0000,$C000
	.dc.w	$1E03,$1F04,$1F04,$00DB,$C000,$0000,$0000,$C000
	.dc.w	$1E03,$1D04,$1D04,$02DB,$C000,$0000,$0000,$C000
	.dc.w	$1EDB,$19DC,$19DC,$0603,$C000,$0000,$0000,$C000
	.dc.w	$1EDB,$11DC,$11DC,$0E03,$C000,$0000,$0000,$C000
	.dc.w	$1E03,$01DC,$01DC,$1E03,$C000,$0000,$0000,$C000
hypimg2:		* Hyper-Drive Spinning Light
	.dc.w	0,0
	.dc.w	6,1
	.dc.w	$7C00,$8200,$FE00,$0000,$3E00,$0600,$FE00,$0000
	.dc.w	$1E00,$0E00,$FE00,$0000,$EE00,$FE00,$0E00,$0000
	.dc.w	$C600,$FE00,$0600,$0000,$4400,$FE00,$8600,$0000
hypimg3:		* Hyper-Drive Spinning Light
	.dc.w	0,0
	.dc.w	6,1
	.dc.w	$0000,$8200,$FE00,$0000,$C600,$C000,$3E00,$0000
	.dc.w	$EE00,$E000,$1E00,$0000,$1E00,$FE00,$1E00,$0000
	.dc.w	$3E00,$FE00,$3E00,$0000,$3C00,$FE00,$BE00,$0000
hypimg4:		* Hyper-Drive Spinning Light
	.dc.w	0,0
	.dc.w	6,1
	.dc.w	$7C00,$FE00,$8200,$0000,$3800,$F800,$0600,$0000
	.dc.w	$1000,$F000,$0E00,$0000,$FE00,$F000,$FE00,$0000
	.dc.w	$FE00,$F800,$FE00,$0000,$7C00,$FA00,$FE00,$0000
hypimg5:		* Hyper-Drive Spinning Light
	.dc.w	0,0
	.dc.w	6,1
	.dc.w	$0000,$FE00,$8200,$0000,$C600,$FE00,$C000,$0000
	.dc.w	$EE00,$FE00,$E000,$0000,$F000,$E000,$FE00,$0000
	.dc.w	$F800,$C000,$FE00,$0000,$7800,$C200,$FE00,$0000
hypimg6:		* Hyper-Drive Spinning Light
	.dc.w	0,0
	.dc.w	6,1
	.dc.w	$7C00,$FE00,$FE00,$0000,$F800,$FE00,$F800,$0000
	.dc.w	$F000,$FE00,$F000,$0000,$EE00,$0E00,$F000,$0000
	.dc.w	$C600,$0600,$F800,$0000,$4400,$8600,$FA00,$0000
hypimg7:		* Hyper-Drive Spinning Light
	.dc.w	0,0
	.dc.w	6,1
	.dc.w	$7C00,$FE00,$FE00,$0000,$FE00,$3E00,$FE00,$0000
	.dc.w	$FE00,$1E00,$FE00,$0000,$1000,$1E00,$E000,$0000
	.dc.w	$3800,$3E00,$C000,$0000,$3800,$BE00,$C200,$0000

radimg0:		* Sub-Space Radio Carrier Busy-Box
	.dc.w	0,0
	.dc.w	6,2
	.dc.w	$0000,$1111,$1111,$1111,$0000,$1000,$1000,$1000
	.dc.w	$0000,$8888,$AAAA,$AAAA,$0000,$8800,$A800,$A800
	.dc.w	$1000,$4444,$4444,$4444,$0000,$4000,$4000,$4000
	.dc.w	$0800,$2222,$2222,$2222,$0000,$2000,$2000,$2000
	.dc.w	$0000,$1111,$5555,$5555,$0000,$1000,$5000,$5000
	.dc.w	$0000,$0888,$0888,$0888,$0000,$8800,$8800,$8800
radimg1:		* Sub-Space Radio Carrier Busy-Box
	.dc.w	0,0
	.dc.w	6,2
	.dc.w	$0000,$0000,$2222,$2222,$0000,$0000,$2000,$2000
	.dc.w	$0000,$4444,$5555,$5555,$0000,$4000,$5000,$5000
	.dc.w	$0020,$0000,$8888,$8888,$0000,$0000,$8800,$8800
	.dc.w	$0010,$0000,$4444,$4444,$0000,$0000,$4000,$4000
	.dc.w	$0000,$8888,$AAAA,$AAAA,$0000,$8800,$A800,$A800
	.dc.w	$0000,$0000,$1111,$1111,$0000,$0000,$1000,$1000
radimg2:		* Sub-Space Radio Carrier Busy-Box
	.dc.w	0,0
	.dc.w	6,2
	.dc.w	$0000,$4444,$4444,$4444,$0000,$4000,$4000,$4000
	.dc.w	$8888,$2222,$AAAA,$AAAA,$8800,$2000,$A800,$A800
	.dc.w	$0000,$1111,$1111,$1111,$0000,$1000,$1000,$1000
	.dc.w	$0000,$8888,$8888,$8888,$0000,$8800,$8800,$8800
	.dc.w	$1111,$4444,$5555,$5555,$1000,$4000,$5000,$5000
	.dc.w	$0000,$2222,$2222,$2222,$0000,$2000,$2000,$2000
radimg3:		* Sub-Space Radio Carrier Busy-Box
	.dc.w	0,0
	.dc.w	6,2
	.dc.w	$8888,$0000,$8888,$8888,$8800,$0000,$8800,$8800
	.dc.w	$4444,$1111,$5555,$5555,$4000,$1000,$5000,$5000
	.dc.w	$222A,$0000,$2222,$2222,$2000,$0000,$2000,$2000
	.dc.w	$1115,$0000,$1111,$1111,$1000,$0000,$1000,$1000
	.dc.w	$8888,$2222,$AAAA,$AAAA,$8800,$2000,$A800,$A800
	.dc.w	$4444,$0000,$4444,$4444,$4000,$0000,$4000,$4000
radimg4:		* Sub-Space Radio Carrier Busy-Box
	.dc.w	0,0
	.dc.w	6,2
	.dc.w	$0000,$1111,$1111,$1111,$0000,$1000,$1000,$1000
	.dc.w	$0000,$8888,$AAAA,$AAAA,$0000,$8800,$A800,$A800
	.dc.w	$0000,$4444,$4444,$4444,$0000,$4000,$4000,$4000
	.dc.w	$0000,$2222,$2222,$2222,$0000,$2000,$2000,$2000
	.dc.w	$0000,$1111,$5555,$5555,$0000,$1000,$5000,$5000
	.dc.w	$0000,$0888,$0888,$0888,$0000,$8800,$8800,$8800
radimg5:		* Sub-Space Radio Carrier Busy-Box
	.dc.w	0,0
	.dc.w	6,2
	.dc.w	$0000,$0000,$2222,$2222,$0000,$0000,$2000,$2000
	.dc.w	$0000,$4444,$5555,$5555,$0000,$4000,$5000,$5000
	.dc.w	$0000,$0000,$8888,$8888,$2000,$0000,$8800,$8800
	.dc.w	$0000,$0000,$4444,$4444,$1000,$0000,$4000,$4000
	.dc.w	$0000,$8888,$AAAA,$AAAA,$0000,$8800,$A800,$A800
	.dc.w	$0000,$0000,$1111,$1111,$0000,$0000,$1000,$1000
radimg6:		* Sub-Space Radio Carrier Busy-Box
	.dc.w	0,0
	.dc.w	6,2
	.dc.w	$0000,$4444,$4444,$4444,$0000,$4000,$4000,$4000
	.dc.w	$8888,$2222,$AAAA,$AAAA,$8800,$2000,$A800,$A800
	.dc.w	$0400,$1111,$1111,$1111,$0000,$1000,$1000,$1000
	.dc.w	$0200,$8888,$8888,$8888,$0000,$8800,$8800,$8800
	.dc.w	$1111,$4444,$5555,$5555,$1000,$4000,$5000,$5000
	.dc.w	$0000,$2222,$2222,$2222,$0000,$2000,$2000,$2000
radimg7:		* Sub-Space Radio Carrier Busy-Box
	.dc.w	0,0
	.dc.w	6,2
	.dc.w	$8888,$0000,$8888,$8888,$8800,$0000,$8800,$8800
	.dc.w	$4444,$1111,$5555,$5555,$4000,$1000,$5000,$5000
	.dc.w	$222A,$0000,$2222,$2222,$2000,$0000,$2000,$2000
	.dc.w	$1115,$0000,$1111,$1111,$1000,$0000,$1000,$1000
	.dc.w	$8888,$2222,$AAAA,$AAAA,$8800,$2000,$A800,$A800
	.dc.w	$4444,$0000,$4444,$4444,$4000,$0000,$4000,$4000

srgimg0:		* Surge-Energy Indicator Busy-Box (GREEN)
	.dc.w	0,0
	.dc.w	7,2
	.dc.w	$FFFF,$8000,$FFFF,$7FFF,$8000,$8000,$8000,$0000
	.dc.w	$FFFF,$0000,$FFFF,$FFFF,$8000,$0000,$8000,$8000
	.dc.w	$7FFD,$8007,$7FF8,$7FF8,$8000,$0000,$8000,$8000
	.dc.w	$FFFD,$C07F,$3F82,$3F80,$8000,$8000,$0000,$0000
	.dc.w	$5B42,$CE7D,$B1BF,$1102,$0000,$8000,$8000,$0000
	.dc.w	$9A3F,$4E40,$F5FF,$803F,$8000,$0000,$8000,$8000
	.dc.w	$C47F,$BB80,$FFFF,$447F,$8000,$8000,$8000,$0000
srgimg1:		* Surge-Energy Indicator Busy-Box (GREEN)
	.dc.w	0,0
	.dc.w	7,2
	.dc.w	$FFFF,$8000,$FFFF,$7FFF,$8000,$8000,$8000,$0000
	.dc.w	$FFFF,$0000,$FFFF,$FFFF,$8000,$0000,$8000,$8000
	.dc.w	$FFBF,$06E0,$F91F,$F91F,$8000,$0000,$8000,$8000
	.dc.w	$F9BF,$1FF0,$E64F,$E00F,$8000,$0000,$8000,$8000
	.dc.w	$D656,$99B3,$6FEC,$4644,$0000,$8000,$0000,$0000
	.dc.w	$8FE6,$9013,$7FFD,$0FE0,$0000,$8000,$8000,$0000
	.dc.w	$9FF1,$E00E,$FFFF,$1FF1,$8000,$8000,$8000,$0000
srgimg2:		* Surge-Energy Indicator Busy-Box (GREEN)
	.dc.w	0,0
	.dc.w	7,2
	.dc.w	$FFFF,$8000,$FFFF,$7FFF,$8000,$8000,$8000,$0000
	.dc.w	$FFFF,$0000,$FFFF,$FFFF,$8000,$0000,$8000,$8000
	.dc.w	$FFFF,$3A00,$C5FF,$C5FF,$8000,$0000,$8000,$8000
	.dc.w	$CBFF,$FF01,$30FE,$00FE,$8000,$8000,$0000,$0000
	.dc.w	$316D,$CF39,$FEC6,$3044,$0000,$8000,$8000,$0000
	.dc.w	$FE68,$0139,$FFD7,$FE00,$8000,$0000,$8000,$8000
	.dc.w	$FF11,$80EE,$FFFF,$7F11,$8000,$8000,$8000,$0000
srgimg3:		* Surge-Energy Indicator Busy-Box (GREEN)
	.dc.w	0,0
	.dc.w	7,2
	.dc.w	$F8FF,$8700,$F8FF,$78FF,$8000,$8000,$8000,$0000
	.dc.w	$F1FF,$0F80,$F27F,$F07F,$8000,$0000,$8000,$8000
	.dc.w	$7A0F,$9D18,$67E7,$6207,$8000,$0000,$8000,$8000
	.dc.w	$176F,$989F,$EFF0,$0700,$8000,$8000,$0000,$0000
	.dc.w	$8F90,$706F,$FFFF,$8F90,$0000,$8000,$8000,$0000
	.dc.w	$FFFF,$0000,$FFFF,$FFFF,$8000,$0000,$8000,$8000
	.dc.w	$FFFF,$8000,$FFFF,$7FFF,$8000,$8000,$8000,$0000
srgimg4:		* Surge-Energy Indicator Busy-Box (YELLOW)
	.dc.w	0,0
	.dc.w	7,2
	.dc.w	$FFFF,$8000,$FFFF,$7FFF,$8000,$8000,$8000,$0000
	.dc.w	$BFE7,$E038,$1FC7,$1FC7,$8000,$0000,$8000,$8000
	.dc.w	$ADA7,$E73C,$58D3,$0883,$8000,$0000,$8000,$8000
	.dc.w	$4D15,$A72C,$FAFB,$4011,$0000,$0000,$8000,$0000
	.dc.w	$E239,$1DC4,$FFFF,$E238,$0000,$0000,$8000,$0000
	.dc.w	$FFFC,$0003,$FFFF,$FFFC,$0000,$8000,$8000,$0000
	.dc.w	$FFFF,$8000,$FFFF,$7FFF,$8000,$8000,$8000,$0000
srgimg5:		* Surge-Energy Indicator Busy-Box (YELLOW)
	.dc.w	0,0
	.dc.w	7,2
	.dc.w	$FFFF,$8000,$FFFF,$7FFF,$8000,$8000,$8000,$0000
	.dc.w	$FE7F,$0380,$FC7F,$FC7F,$0000,$8000,$0000,$0000
	.dc.w	$DA7F,$73C1,$8D3E,$883E,$0000,$8000,$0000,$0000
	.dc.w	$515D,$72C1,$AFBE,$011C,$0000,$8000,$8000,$0000
	.dc.w	$239C,$5C41,$FFFF,$2388,$8000,$0000,$8000,$8000
	.dc.w	$7FD5,$802A,$FFFF,$7FC9,$8000,$0000,$8000,$8000
	.dc.w	$FFE3,$801C,$FFFF,$7FE3,$8000,$8000,$8000,$0000
srgimg6:		* Surge-Energy Indicator Busy-Box (YELLOW)
	.dc.w	0,0
	.dc.w	7,2
	.dc.w	$FFFF,$8000,$FFFF,$7FFF,$8000,$8000,$8000,$0000
	.dc.w	$FFFF,$0000,$FFFF,$FFFF,$0000,$8000,$0000,$0000
	.dc.w	$DFCF,$7071,$8F8E,$8F8E,$0000,$8000,$0000,$0000
	.dc.w	$574D,$7079,$AFA6,$0704,$0000,$8000,$8000,$0000
	.dc.w	$2728,$5059,$FFF7,$2220,$8000,$0000,$8000,$8000
	.dc.w	$7571,$8A8E,$FFFF,$7271,$8000,$0000,$8000,$8000
	.dc.w	$F8FF,$8700,$FFFF,$78FF,$8000,$8000,$8000,$0000
srgimg7:		* Surge-Energy Indicator Busy-Box (YELLOW)
	.dc.w	0,0
	.dc.w	7,2
	.dc.w	$FFFF,$8000,$FFFF,$7FFF,$8000,$8000,$8000,$0000
	.dc.w	$7F3F,$80E0,$7F1F,$7F1F,$8000,$0000,$8000,$8000
	.dc.w	$7F2D,$C1E7,$3E58,$3E08,$8000,$0000,$8000,$8000
	.dc.w	$5D45,$C1A7,$BEFA,$1C40,$0000,$0000,$8000,$0000
	.dc.w	$9CE2,$411D,$FFFF,$88E2,$0000,$0000,$8000,$0000
	.dc.w	$D5FF,$2A00,$FFFF,$C9FF,$0000,$8000,$8000,$0000
	.dc.w	$E3FF,$9C00,$FFFF,$63FF,$8000,$8000,$8000,$0000
srgimg8:		* Surge-Energy Indicator Busy-Box (RED)
	.dc.w	0,0
	.dc.w	7,2
	.dc.w	$F7FF,$8800,$FFFF,$7FFF,$8000,$8000,$8000,$0000
	.dc.w	$F7FF,$0800,$FFFF,$EBFF,$8000,$0000,$8000,$8000
	.dc.w	$D5FF,$0800,$FFFF,$C1FF,$0000,$0000,$8000,$0000
	.dc.w	$C9EF,$5505,$BEFA,$88EA,$0000,$0000,$8000,$0000
	.dc.w	$5D65,$E3A7,$3E58,$1C40,$0000,$8000,$8000,$0000
	.dc.w	$3E20,$C1F7,$7F1D,$3E00,$8000,$0000,$8000,$8000
	.dc.w	$FF15,$80EA,$FFBF,$7F15,$8000,$8000,$8000,$0000
srgimg9:		* Surge-Energy Indicator Busy-Box (RED)
	.dc.w	0,0
	.dc.w	7,2
	.dc.w	$FDFF,$8200,$FFFF,$7FFF,$8000,$8000,$8000,$0000
	.dc.w	$FDFF,$0200,$FFFF,$FAFF,$8000,$0000,$8000,$8000
	.dc.w	$757D,$0208,$FFF7,$7075,$8000,$0000,$8000,$8000
	.dc.w	$7269,$5559,$AFA6,$2220,$8000,$0000,$8000,$8000
	.dc.w	$5741,$F8FB,$8F8E,$0700,$0000,$8000,$0000,$0000
	.dc.w	$8F8A,$7075,$DFDF,$8F8A,$0000,$8000,$0000,$0000
	.dc.w	$DFDF,$A020,$FFFF,$5FDF,$8000,$8000,$8000,$0000
srgimga:		* Surge-Energy Indicator Busy-Box (RED)
	.dc.w	0,0
	.dc.w	7,2
	.dc.w	$FFF7,$8008,$FFFF,$7FFF,$8000,$8000,$8000,$0000
	.dc.w	$FFF7,$0008,$FFFF,$FFEB,$8000,$0000,$8000,$8000
	.dc.w	$7FD5,$0008,$FFFF,$7FC1,$8000,$0000,$8000,$8000
	.dc.w	$7BC9,$5055,$AFBE,$2B88,$8000,$0000,$8000,$8000
	.dc.w	$535D,$F2E3,$8D3E,$011C,$0000,$8000,$0000,$0000
	.dc.w	$823E,$77C1,$DC7F,$803E,$0000,$8000,$0000,$0000
	.dc.w	$D47F,$AB80,$FEFF,$547F,$8000,$8000,$8000,$0000
srgimgb:		* Surge-Energy Indicator Busy-Box (RED)
	.dc.w	0,0
	.dc.w	7,2
	.dc.w	$FFFF,$8000,$FFFF,$7FFF,$8000,$8000,$8000,$0000
	.dc.w	$FFFF,$0000,$FFFF,$FFFE,$8000,$0000,$8000,$8000
	.dc.w	$FF7D,$0000,$FFFF,$FF7C,$0000,$0000,$8000,$0000
	.dc.w	$EF3C,$0505,$FAFB,$EA38,$0000,$0000,$8000,$0000
	.dc.w	$ED35,$A7AE,$58D3,$4011,$0000,$8000,$8000,$0000
	.dc.w	$A8A3,$F77C,$1DC7,$0083,$8000,$0000,$8000,$8000
	.dc.w	$95C7,$EA38,$BFEF,$15C7,$8000,$8000,$8000,$0000

*
*	Galactic Map Markers
*
gmpimg1:		* Galactic Map Marker (1 Alien Ships)
	.dc.w	2,1
	.dc.w	2,1
	.dc.w	$0000,$C000,$C000,$C000,$0000,$C000,$C000,$C000
gmpimg2:		* Galactic Map Marker (2 Alien Ships)
	.dc.w	3,1
	.dc.w	3,1
	.dc.w	$0000,$C000,$C000,$C000,$0000,$CC00,$CC00,$CC00
	.dc.w	$0000,$0C00,$0C00,$0C00
gmpimg3:		* Galactic Map Marker (3 Alien Ships)
	.dc.w	3,1
	.dc.w	5,1
	.dc.w	$0000,$0600,$0600,$0600,$0000,$C600,$C600,$C600
	.dc.w	$0000,$C000,$C000,$C000,$0000,$1800,$1800,$1800
	.dc.w	$0000,$1800,$1800,$1800
gmpimg4:		* Galactic Map Marker (4 Alien Ships)
	.dc.w	3,2
	.dc.w	6,1
	.dc.w	$0000,$3000,$3000,$3000,$0000,$3000,$3000,$3000
	.dc.w	$0000,$C600,$C600,$C600,$0000,$C600,$C600,$C600
	.dc.w	$0000,$1800,$1800,$1800,$0000,$1800,$1800,$1800
gmpimg5:		* Galactic Map Marker (5 Alien Ships)
	.dc.w	4,2
	.dc.w	7,1
	.dc.w	$0000,$C180,$C180,$C180,$0000,$D980,$D980,$D980
	.dc.w	$0000,$1800,$1800,$1800,$0000,$0600,$0600,$0600
	.dc.w	$0000,$0600,$0600,$0600,$0000,$1800,$1800,$1800
	.dc.w	$0000,$1800,$1800,$1800
gmpimg6:		* Galactic Map Marker (6 Alien Ships)
	.dc.w	4,2
	.dc.w	7,1
	.dc.w	$0000,$CC00,$CC00,$CC00,$0000,$CD80,$CD80,$CD80
	.dc.w	$0000,$3180,$3180,$3180,$0000,$3600,$3600,$3600
	.dc.w	$0000,$0600,$0600,$0600,$0000,$1800,$1800,$1800
	.dc.w	$0000,$1800,$1800,$1800
gmpimg7:		* Galactic Map Marker (1 Alien Ships)
	.dc.w	0,1
	.dc.w	2,1
	.dc.w	$0000,$C000,$C000,$C000,$0000,$C000,$C000,$C000
gmpimg8:		* Galactic Map Marker (2 Alien Ships)
	.dc.w	2,1
	.dc.w	3,1
	.dc.w	$0000,$1800,$1800,$1800,$0000,$D800,$D800,$D800
	.dc.w	$0000,$C000,$C000,$C000
gmpimg9:		* Galactic Map Marker (3 Alien Ships)
	.dc.w	3,2
	.dc.w	4,1
	.dc.w	$0000,$3000,$3000,$3000,$0000,$3600,$3600,$3600
	.dc.w	$0000,$C600,$C600,$C600,$0000,$C000,$C000,$C000
gmpimga:		* Galactic Map Marker (4 Alien Ships)
	.dc.w	3,2
	.dc.w	5,1
	.dc.w	$0000,$1800,$1800,$1800,$0000,$D800,$D800,$D800
	.dc.w	$0000,$C600,$C600,$C600,$0000,$3600,$3600,$3600
	.dc.w	$0000,$3000,$3000,$3000
gmpimgb:		* Galactic Map Marker (5 Alien Ships)
	.dc.w	3,4
	.dc.w	7,1
	.dc.w	$0000,$1800,$1800,$1800,$0000,$1800,$1800,$1800
	.dc.w	$0000,$C000,$C000,$C000,$0000,$D800,$D800,$D800
	.dc.w	$0000,$1B00,$1B00,$1B00,$0000,$3300,$3300,$3300
	.dc.w	$0000,$3000,$3000,$3000
gmpimgc:		* Galactic Map Marker (6 Alien Ships)
	.dc.w	4,4
	.dc.w	7,1
	.dc.w	$0000,$0C00,$0C00,$0C00,$0000,$0C00,$0C00,$0C00
	.dc.w	$0000,$3600,$3600,$3600,$0000,$3600,$3600,$3600
	.dc.w	$0000,$C180,$C180,$C180,$0000,$D980,$D980,$D980
	.dc.w	$0000,$1800,$1800,$1800
uptrimg:		* You-Are-Here Triangle (Up)
	.dc.w	9,6
	.dc.w	10,2
	.dc.w	$0040,$0000,$0040,$0040,$0000,$0000,$0000,$0000
	.dc.w	$00A0,$0000,$00A0,$00A0,$0000,$0000,$0000,$0000
	.dc.w	$0150,$0000,$0150,$0150,$0000,$0000,$0000,$0000
	.dc.w	$0208,$0000,$0208,$0208,$0000,$0000,$0000,$0000
	.dc.w	$0404,$0000,$0404,$0404,$0000,$0000,$0000,$0000
	.dc.w	$0802,$0000,$0802,$0802,$0000,$0000,$0000,$0000
	.dc.w	$1001,$0000,$1001,$1001,$0000,$0000,$0000,$0000
	.dc.w	$2000,$0000,$2000,$2000,$8000,$0000,$8000,$8000
	.dc.w	$5001,$0000,$5001,$5001,$4000,$0000,$4000,$4000
	.dc.w	$AAAA,$0000,$AAAA,$AAAA,$A000,$0000,$A000,$A000
dntrimg:		* You-Are-Here Triangle (Down)
	.dc.w	9,3
	.dc.w	10,2
	.dc.w	$AAAA,$0000,$AAAA,$AAAA,$A000,$0000,$A000,$A000
	.dc.w	$5001,$0000,$5001,$5001,$4000,$0000,$4000,$4000
	.dc.w	$2000,$0000,$2000,$2000,$8000,$0000,$8000,$8000
	.dc.w	$1001,$0000,$1001,$1001,$0000,$0000,$0000,$0000
	.dc.w	$0802,$0000,$0802,$0802,$0000,$0000,$0000,$0000
	.dc.w	$0404,$0000,$0404,$0404,$0000,$0000,$0000,$0000
	.dc.w	$0208,$0000,$0208,$0208,$0000,$0000,$0000,$0000
	.dc.w	$0150,$0000,$0150,$0150,$0000,$0000,$0000,$0000
	.dc.w	$00A0,$0000,$00A0,$00A0,$0000,$0000,$0000,$0000
	.dc.w	$0040,$0000,$0040,$0040,$0000,$0000,$0000,$0000

*
*	ATTACK COMPUTER GRAPHICS
*
cmpimg0:		* Attack Computer Damaged
	.dc.w	0,0
	.dc.w	15,2
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$FFFF,$FFFF,$FFFF,$0000,$E000,$E000,$E000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$FFFF,$FFFF,$FFFF,$0000,$E000,$E000,$E000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$FFFF,$FFFF,$FFFF,$0000,$E000,$E000,$E000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$576C,$0000,$0000,$576C,$0000,$0000,$0000,$0000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$6BAD,$0000,$0000,$6BAD,$C000,$0000,$0000,$C000
cmpimg1:		* Attack Computer Working (Off)
	.dc.w	0,0
	.dc.w	15,2
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$FFFF,$FFFF,$FFFF,$0000,$E000,$E000,$E000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$FFFF,$DFFF,$FFFF,$2000,$E000,$E000,$E000,$0000
	.dc.w	$7924,$8924,$D924,$D000,$8000,$8000,$8000,$0000
	.dc.w	$6924,$4924,$6924,$2000,$8000,$8000,$8000,$0000
	.dc.w	$FFFF,$FFFF,$FFFF,$0000,$E000,$E000,$E000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$506C,$0700,$0700,$576C,$0000,$0000,$0000,$0000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$6BAD,$6BAD,$6BAD,$0000,$C000,$C000,$C000,$0000
cmpimg2:		* Attack Computer Working (Off)
	.dc.w	0,0
	.dc.w	15,2
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$FFFF,$FFFF,$FFFF,$0000,$E000,$E000,$E000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$FFFF,$F7FF,$FFFF,$0800,$E000,$E000,$E000,$0000
	.dc.w	$9D24,$6124,$F524,$7400,$8000,$8000,$8000,$0000
	.dc.w	$4924,$4124,$4924,$0800,$8000,$8000,$8000,$0000
	.dc.w	$FFFF,$FFFF,$FFFF,$0000,$E000,$E000,$E000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$506C,$0700,$0700,$576C,$0000,$0000,$0000,$0000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$0000,$0000,$0000,$6BAD,$0000,$0000,$0000,$C000
cmpimg3:		* Attack Computer Working (Off)
	.dc.w	0,0
	.dc.w	15,2
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$FFFF,$FFFF,$FFFF,$0000,$E000,$E000,$E000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$FFFF,$FDFF,$FFFF,$0200,$E000,$E000,$E000,$0000
	.dc.w	$6724,$1824,$FD24,$1D00,$8000,$8000,$8000,$0000
	.dc.w	$4B24,$4924,$4B24,$0200,$8000,$8000,$8000,$0000
	.dc.w	$FFFF,$FFFF,$FFFF,$0000,$E000,$E000,$E000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$576C,$0000,$0000,$576C,$0000,$0000,$0000,$0000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$6BAD,$0000,$0000,$6BAD,$C000,$0000,$0000,$C000
cmpimg4:		* Attack Computer Working (Off)
	.dc.w	0,0
	.dc.w	15,2
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$FFFF,$FFFF,$FFFF,$0000,$E000,$E000,$E000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$FFFF,$FF7F,$FFFF,$0080,$E000,$E000,$E000,$0000
	.dc.w	$99E4,$8624,$7F64,$0740,$8000,$8000,$8000,$0000
	.dc.w	$49A4,$4924,$49A4,$0080,$8000,$8000,$8000,$0000
	.dc.w	$FFFF,$FFFF,$FFFF,$0000,$E000,$E000,$E000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$576C,$0000,$0000,$576C,$0000,$0000,$0000,$0000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$0000,$0000,$0000,$6BAD,$0000,$0000,$0000,$C000
cmpimg5:		* Attack Computer Working (Off)
	.dc.w	0,0
	.dc.w	15,2
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$FFFF,$FFFF,$FFFF,$0000,$E000,$E000,$E000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$FFFF,$FFDF,$FFFF,$0020,$E000,$E000,$E000,$0000
	.dc.w	$6674,$E184,$1FD4,$01D0,$8000,$8000,$8000,$0000
	.dc.w	$4924,$4904,$4924,$0020,$8000,$8000,$8000,$0000
	.dc.w	$FFFF,$FFFF,$FFFF,$0000,$E000,$E000,$E000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$506C,$0700,$0700,$576C,$0000,$0000,$0000,$0000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$6BAD,$6BAD,$6BAD,$0000,$C000,$C000,$C000,$0000
cmpimg6:		* Attack Computer Working (Off)
	.dc.w	0,0
	.dc.w	15,2
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$FFFF,$FFFF,$FFFF,$0000,$E000,$E000,$E000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$FFFF,$FFF7,$FFFF,$0008,$E000,$E000,$E000,$0000
	.dc.w	$199C,$7860,$07F4,$0074,$8000,$8000,$8000,$0000
	.dc.w	$492C,$4924,$492C,$0008,$8000,$8000,$8000,$0000
	.dc.w	$FFFF,$FFFF,$FFFF,$0000,$E000,$E000,$E000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$506C,$0700,$0700,$576C,$0000,$0000,$0000,$0000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$0000,$0000,$0000,$6BAD,$0000,$0000,$0000,$C000
cmpimg7:		* Attack Computer Working (Off)
	.dc.w	0,0
	.dc.w	15,2
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$FFFF,$FFFF,$FFFF,$0000,$E000,$E000,$E000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$FFFF,$FFFD,$FFFF,$0002,$E000,$E000,$E000,$0000
	.dc.w	$4667,$5E18,$41FD,$001D,$8000,$8000,$8000,$0000
	.dc.w	$4926,$4924,$4926,$0002,$8000,$8000,$8000,$0000
	.dc.w	$FFFF,$FFFF,$FFFF,$0000,$E000,$E000,$E000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$576C,$0000,$0000,$576C,$0000,$0000,$0000,$0000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$6BAD,$0000,$0000,$6BAD,$C000,$0000,$0000,$C000
cmpimg8:		* Attack Computer Working (Off)
	.dc.w	0,0
	.dc.w	15,2
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$FFFF,$FFFF,$FFFF,$0000,$E000,$E000,$E000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$FFFF,$FFFF,$FFFF,$0000,$E000,$6000,$E000,$8000
	.dc.w	$4999,$4F86,$487F,$0007,$C000,$0000,$4000,$4000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$0000,$8000,$8000
	.dc.w	$FFFF,$FFFF,$FFFF,$0000,$E000,$E000,$E000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$0000,$0000,$0000,$576C,$0000,$0000,$0000,$0000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$6BAD,$0000,$0000,$6BAD,$C000,$0000,$0000,$C000
cmpimg9:		* Attack Computer Working (Off)
	.dc.w	0,0
	.dc.w	15,2
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$FFFF,$FFFF,$FFFF,$0000,$E000,$E000,$E000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$FFFF,$FFFF,$FFFF,$0000,$E000,$C000,$E000,$2000
	.dc.w	$4866,$49E1,$481F,$0001,$6000,$8000,$C000,$C000
	.dc.w	$4924,$4924,$4924,$0000,$A000,$8000,$A000,$2000
	.dc.w	$FFFF,$FFFF,$FFFF,$0000,$E000,$E000,$E000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$506C,$576C,$576C,$0700,$0000,$0000,$0000,$0000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$6BAD,$0000,$0000,$6BAD,$C000,$0000,$0000,$C000
cmpimg10:		* Attack Computer Working (Off)
	.dc.w	0,0
	.dc.w	15,2
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$FFFF,$FFFF,$FFFF,$0000,$E000,$E000,$E000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$FFFF,$FFFF,$FFFF,$0000,$E000,$E000,$E000,$0000
	.dc.w	$4919,$4978,$4907,$0000,$8000,$6000,$E000,$6000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$FFFF,$FFFF,$FFFF,$0000,$E000,$E000,$E000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$0000,$0700,$0700,$576C,$0000,$0000,$0000,$0000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$6BAD,$0000,$0000,$6BAD,$C000,$0000,$0000,$C000
cmpimg11:		* Attack Computer Working (Off)
	.dc.w	0,0
	.dc.w	15,2
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$FFFF,$FFFF,$FFFF,$0000,$E000,$E000,$E000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$FFFF,$FFFF,$FFFF,$0000,$E000,$E000,$E000,$0000
	.dc.w	$4926,$493E,$4921,$0000,$6000,$0000,$E000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$FFFF,$FFFF,$FFFF,$0000,$E000,$E000,$E000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$576C,$0000,$0000,$576C,$0000,$0000,$0000,$0000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$6BAD,$0000,$0000,$6BAD,$C000,$0000,$0000,$C000
cmpimg12:		* Attack Computer Working (Off)
	.dc.w	0,0
	.dc.w	15,2
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$FFFF,$FFFF,$FFFF,$0000,$E000,$E000,$E000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$FFFF,$FFFF,$FFFF,$0000,$E000,$E000,$E000,$0000
	.dc.w	$4921,$4927,$4920,$0000,$8000,$8000,$6000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$FFFF,$FFFF,$FFFF,$0000,$E000,$E000,$E000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$576C,$0000,$0000,$576C,$0000,$0000,$0000,$0000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$0000,$0000,$0000,$6BAD,$0000,$0000,$0000,$C000
cmpimg13:		* Attack Computer Working (Off)
	.dc.w	0,0
	.dc.w	15,2
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$FFFF,$FFFF,$FFFF,$0000,$E000,$E000,$E000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$FFFF,$FFFF,$FFFF,$0000,$E000,$E000,$E000,$0000
	.dc.w	$4924,$4925,$4924,$0000,$6000,$E000,$0000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$FFFF,$FFFF,$FFFF,$0000,$E000,$E000,$E000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$506C,$0700,$0700,$576C,$0000,$0000,$0000,$0000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$6BAD,$6BAD,$6BAD,$0000,$C000,$C000,$C000,$0000
cmpimg14:		* Attack Computer Working (Off)
	.dc.w	0,0
	.dc.w	15,2
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$FFFF,$FFFF,$FFFF,$0000,$E000,$E000,$E000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$FFFF,$FFFF,$FFFF,$0000,$E000,$E000,$E000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$E000,$8000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$FFFF,$FFFF,$FFFF,$0000,$E000,$E000,$E000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$506C,$0700,$0700,$576C,$0000,$0000,$0000,$0000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$0000,$0000,$0000,$6BAD,$0000,$0000,$0000,$C000
cmpimg15:		* Attack Computer Working (Off)
	.dc.w	0,0
	.dc.w	15,2
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$FFFF,$FFFF,$FFFF,$0000,$E000,$E000,$E000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$FFFF,$FFFF,$FFFF,$0000,$E000,$E000,$E000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$FFFF,$FFFF,$FFFF,$0000,$E000,$E000,$E000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$576C,$0000,$0000,$576C,$0000,$0000,$0000,$0000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$6BAD,$0000,$0000,$6BAD,$C000,$0000,$0000,$C000
cmpimg16:		* Attack Computer Working (Off)
	.dc.w	0,0
	.dc.w	15,2
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$FFFF,$FFFF,$FFFF,$0000,$E000,$E000,$E000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$FFFF,$7FFF,$FFFF,$8000,$E000,$E000,$E000,$0000
	.dc.w	$C924,$0924,$4924,$4000,$8000,$8000,$8000,$0000
	.dc.w	$C924,$4924,$C924,$8000,$8000,$8000,$8000,$0000
	.dc.w	$FFFF,$FFFF,$FFFF,$0000,$E000,$E000,$E000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$4924,$4924,$4924,$0000,$8000,$8000,$8000,$0000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$576C,$0000,$0000,$576C,$0000,$0000,$0000,$0000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$0000,$0000,$0000,$6BAD,$0000,$0000,$0000,$C000
cmpimg17:		* Attack Computer Working (On)
	.dc.w	0,0
	.dc.w	15,2
	.dc.w	$0000,$0000,$4924,$4924,$0000,$0000,$8000,$8000
	.dc.w	$0000,$0000,$4924,$4924,$0000,$0000,$8000,$8000
	.dc.w	$0000,$0E00,$FFFF,$FFFF,$0000,$0000,$E000,$E000
	.dc.w	$2000,$1180,$79A4,$59A4,$0000,$0000,$8000,$8000
	.dc.w	$0000,$0040,$4964,$0964,$0000,$0000,$8000,$8000
	.dc.w	$8000,$0020,$7FFF,$7FFF,$2000,$2000,$C000,$C000
	.dc.w	$0000,$0018,$493C,$493C,$8000,$0000,$C000,$0000
	.dc.w	$0000,$0007,$4927,$4927,$0000,$0000,$8000,$8000
	.dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$E000,$E000
	.dc.w	$0000,$0000,$4924,$4924,$0000,$0000,$8000,$8000
	.dc.w	$0000,$0000,$4924,$4924,$0000,$0000,$8000,$8000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$6800,$03AD,$03AD,$6000,$0000,$C000,$C000,$0000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$576D,$0000,$0000,$576D,$0000,$0000,$0000,$0000
cmpimg18:		* Attack Computer Working (On)
	.dc.w	0,0
	.dc.w	15,2
	.dc.w	$0000,$0000,$4924,$4924,$0000,$0000,$8000,$8000
	.dc.w	$0000,$0000,$4924,$4924,$0000,$0000,$8000,$8000
	.dc.w	$0000,$1C00,$FFFF,$FFFF,$0000,$0000,$E000,$E000
	.dc.w	$6000,$0300,$2B24,$0B24,$0000,$0000,$8000,$8000
	.dc.w	$8000,$0080,$C9A4,$C9A4,$2000,$2000,$8000,$8000
	.dc.w	$0000,$0040,$FFFF,$FFFF,$0000,$0000,$E000,$A000
	.dc.w	$0000,$0031,$4935,$4935,$8000,$0000,$8000,$0000
	.dc.w	$0000,$000E,$492E,$492E,$0000,$0000,$8000,$8000
	.dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$E000,$E000
	.dc.w	$0000,$0000,$4924,$4924,$0000,$0000,$8000,$8000
	.dc.w	$0000,$0000,$4924,$4924,$0000,$0000,$8000,$8000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$6B80,$002D,$002D,$6800,$0000,$C000,$C000,$0000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$576D,$0000,$0000,$576D,$0000,$0000,$0000,$0000
cmpimg19:		* Attack Computer Working (On)
	.dc.w	0,0
	.dc.w	15,2
	.dc.w	$0000,$0000,$4924,$4924,$0000,$0000,$8000,$8000
	.dc.w	$0000,$0000,$4924,$4924,$0000,$0000,$8000,$8000
	.dc.w	$2000,$1800,$DFFF,$DFFF,$0000,$0000,$E000,$E000
	.dc.w	$C000,$8600,$4F24,$4F24,$2000,$2000,$8000,$8000
	.dc.w	$0000,$0100,$4924,$4924,$0000,$0000,$C000,$8000
	.dc.w	$0000,$0080,$FFFF,$FFFF,$8000,$0000,$E000,$6000
	.dc.w	$0000,$0063,$4967,$4967,$0000,$0000,$8000,$8000
	.dc.w	$0000,$001C,$493C,$493C,$0000,$0000,$8000,$8000
	.dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$E000,$E000
	.dc.w	$0000,$0000,$4924,$4924,$0000,$0000,$8000,$8000
	.dc.w	$0000,$0000,$4924,$4924,$0000,$0000,$8000,$8000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$6BA0,$000D,$000D,$6B80,$0000,$C000,$C000,$0000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$576D,$0000,$0000,$576D,$0000,$0000,$0000,$0000
cmpimg20:		* Attack Computer Working (On)
	.dc.w	0,0
	.dc.w	15,2
	.dc.w	$0000,$0000,$4924,$4924,$0000,$0000,$8000,$8000
	.dc.w	$0000,$0000,$4924,$4924,$0000,$0000,$8000,$8000
	.dc.w	$3000,$0000,$EFFF,$AFFF,$0000,$0000,$E000,$E000
	.dc.w	$8000,$8C00,$4D24,$4D24,$2000,$2000,$C000,$8000
	.dc.w	$0000,$0200,$4B24,$4B24,$8000,$0000,$8000,$0000
	.dc.w	$0000,$0101,$FFFF,$FFFF,$0000,$0000,$E000,$E000
	.dc.w	$0000,$00C6,$49E6,$49E6,$0000,$0000,$8000,$8000
	.dc.w	$0000,$0038,$493C,$493C,$0000,$0000,$8000,$8000
	.dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$E000,$E000
	.dc.w	$0000,$0000,$4924,$4924,$0000,$0000,$8000,$8000
	.dc.w	$0000,$0000,$4924,$4924,$0000,$0000,$8000,$8000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$6BAC,$0001,$0001,$6BA0,$0000,$C000,$C000,$0000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$0000,$0000,$0000,$576D,$0000,$0000,$0000,$0000
cmpimg21:		* Attack Computer Working (On)
	.dc.w	0,0
	.dc.w	15,2
	.dc.w	$0000,$0000,$4924,$4924,$0000,$0000,$8000,$8000
	.dc.w	$0000,$0000,$4924,$4924,$0000,$0000,$8000,$8000
	.dc.w	$A000,$8000,$7FFF,$1FFF,$2000,$2000,$C000,$C000
	.dc.w	$1800,$0000,$5124,$5124,$8000,$0000,$C000,$0000
	.dc.w	$0000,$0401,$4D25,$4D25,$0000,$0000,$8000,$8000
	.dc.w	$0000,$0202,$FFFF,$FFFF,$0000,$0000,$E000,$E000
	.dc.w	$0000,$018C,$49AC,$49AC,$0000,$0000,$8000,$8000
	.dc.w	$0000,$0070,$4974,$4974,$0000,$0000,$8000,$8000
	.dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$E000,$E000
	.dc.w	$0000,$0000,$4924,$4924,$0000,$0000,$8000,$8000
	.dc.w	$0000,$0000,$4924,$4924,$0000,$0000,$8000,$8000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$6BAD,$0000,$0000,$6BAC,$C000,$0000,$0000,$0000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$576D,$576D,$576D,$0000,$0000,$0000,$0000,$0000
cmpimg22:		* Attack Computer Working (On)
	.dc.w	0,0
	.dc.w	15,2
	.dc.w	$0000,$0000,$4924,$4924,$0000,$0000,$8000,$8000
	.dc.w	$0000,$0000,$4924,$4924,$0000,$0000,$8000,$8000
	.dc.w	$8000,$8000,$7FFF,$3FFF,$2000,$2000,$C000,$8000
	.dc.w	$2000,$1001,$7925,$5925,$8000,$0000,$8000,$0000
	.dc.w	$0800,$0002,$4926,$4926,$0000,$0000,$8000,$8000
	.dc.w	$0400,$0004,$FBFF,$FBFF,$0000,$0000,$E000,$E000
	.dc.w	$0000,$0318,$4B3C,$4B3C,$0000,$0000,$8000,$8000
	.dc.w	$0000,$00E0,$49E4,$49E4,$0000,$0000,$8000,$8000
	.dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$E000,$E000
	.dc.w	$0000,$0000,$4924,$4924,$0000,$0000,$8000,$8000
	.dc.w	$0000,$0000,$4924,$4924,$0000,$0000,$8000,$8000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$6BAD,$6BAD,$6BAD,$0000,$C000,$C000,$C000,$0000
	.dc.w	$6BAD,$0000,$0000,$6BAD,$C000,$0000,$0000,$C000
	.dc.w	$0000,$5764,$5764,$0000,$0000,$0000,$0000,$0000
cmpimg23:		* Attack Computer Working (On)
	.dc.w	0,0
	.dc.w	15,2
	.dc.w	$0000,$0000,$4924,$4924,$0000,$0000,$8000,$8000
	.dc.w	$0000,$0000,$4924,$4924,$0000,$0000,$8000,$8000
	.dc.w	$8000,$8000,$7FFF,$7FFF,$A000,$2000,$C000,$0000
	.dc.w	$2000,$0003,$6927,$0927,$0000,$0000,$8000,$8000
	.dc.w	$0000,$1004,$5924,$5924,$0000,$0000,$8000,$8000
	.dc.w	$0800,$0008,$FFFF,$FFFF,$0000,$0000,$E000,$E000
	.dc.w	$0400,$0230,$4B34,$4B34,$0000,$0000,$8000,$8000
	.dc.w	$0000,$01C0,$49E4,$49E4,$0000,$0000,$8000,$8000
	.dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$E000,$E000
	.dc.w	$0000,$0000,$4924,$4924,$0000,$0000,$8000,$8000
	.dc.w	$0000,$0000,$4924,$4924,$0000,$0000,$8000,$8000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$4000,$1764,$1764,$0000,$0000,$0000,$0000,$0000
	.dc.w	$6BAD,$6BAD,$6BAD,$0000,$C000,$C000,$C000,$0000
	.dc.w	$6BAD,$0000,$0000,$6BAD,$C000,$0000,$0000,$C000
cmpimg24:		* Attack Computer Working (On)
	.dc.w	0,0
	.dc.w	15,2
	.dc.w	$0000,$0000,$4924,$4924,$0000,$0000,$8000,$8000
	.dc.w	$0000,$0000,$4924,$4924,$0000,$0000,$8000,$8000
	.dc.w	$0000,$0001,$FFFF,$FFFF,$8000,$0000,$E000,$2000
	.dc.w	$8000,$8006,$4926,$0926,$2000,$2000,$8000,$8000
	.dc.w	$2000,$0008,$692C,$492C,$0000,$0000,$8000,$8000
	.dc.w	$0000,$1010,$FFFF,$FFFF,$0000,$0000,$E000,$E000
	.dc.w	$0000,$0C60,$4D64,$4D64,$0000,$0000,$8000,$8000
	.dc.w	$0300,$0080,$4AA4,$4AA4,$0000,$0000,$8000,$8000
	.dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$E000,$E000
	.dc.w	$0000,$0000,$4924,$4924,$0000,$0000,$8000,$8000
	.dc.w	$0000,$0000,$4924,$4924,$0000,$0000,$8000,$8000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$5000,$0764,$0764,$4000,$0000,$0000,$0000,$0000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$6BAD,$0000,$0000,$6BAD,$C000,$0000,$0000,$C000
cmpimg25:		* Attack Computer Working (On)
	.dc.w	0,0
	.dc.w	15,2
	.dc.w	$0000,$0000,$4924,$4924,$0000,$0000,$8000,$8000
	.dc.w	$0000,$0000,$4924,$4924,$0000,$0000,$8000,$8000
	.dc.w	$0000,$0003,$FFFF,$FFFF,$8000,$0000,$E000,$6000
	.dc.w	$8000,$800C,$492C,$492C,$2000,$2000,$C000,$8000
	.dc.w	$0000,$0010,$4934,$0934,$0000,$0000,$8000,$8000
	.dc.w	$2000,$0020,$FFFF,$DFFF,$0000,$0000,$E000,$E000
	.dc.w	$00C0,$1800,$59A4,$59A4,$0000,$0000,$8000,$8000
	.dc.w	$0000,$0700,$4F24,$4F24,$0000,$0000,$8000,$8000
	.dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$E000,$E000
	.dc.w	$0000,$0000,$4924,$4924,$0000,$0000,$8000,$8000
	.dc.w	$0000,$0000,$4924,$4924,$0000,$0000,$8000,$8000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$5700,$0064,$0064,$5000,$0000,$0000,$0000,$0000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$6BAD,$0000,$0000,$6BAD,$C000,$0000,$0000,$C000
cmpimg26:		* Attack Computer Working (On)
	.dc.w	0,0
	.dc.w	15,2
	.dc.w	$0000,$0000,$4924,$4924,$0000,$0000,$8000,$8000
	.dc.w	$0000,$0000,$4924,$4924,$0000,$0000,$8000,$8000
	.dc.w	$0000,$0007,$FFFF,$FFFF,$0000,$0000,$E000,$E000
	.dc.w	$0000,$0018,$493C,$493C,$8000,$0000,$C000,$0000
	.dc.w	$8020,$8000,$4904,$4904,$2000,$2000,$8000,$8000
	.dc.w	$0040,$0000,$FFFF,$BFFF,$0000,$0000,$E000,$E000
	.dc.w	$2000,$1180,$79A4,$59A4,$0000,$0000,$8000,$8000
	.dc.w	$0000,$0E00,$4F24,$4F24,$0000,$0000,$8000,$8000
	.dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$E000,$E000
	.dc.w	$0000,$0000,$4924,$4924,$0000,$0000,$8000,$8000
	.dc.w	$0000,$0000,$4924,$4924,$0000,$0000,$8000,$8000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$5760,$000C,$000C,$5700,$0000,$0000,$0000,$0000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$6BAD,$0000,$0000,$6BAD,$C000,$0000,$0000,$C000
cmpimg27:		* Attack Computer Working (On)
	.dc.w	0,0
	.dc.w	15,2
	.dc.w	$0000,$0000,$4924,$4924,$0000,$0000,$8000,$8000
	.dc.w	$0000,$0000,$4924,$4924,$0000,$0000,$8000,$8000
	.dc.w	$0000,$000E,$FFFF,$FFFF,$0000,$0000,$E000,$E000
	.dc.w	$0030,$0001,$4925,$4925,$8000,$0000,$8000,$0000
	.dc.w	$0000,$0040,$4964,$4964,$0000,$0000,$C000,$8000
	.dc.w	$8000,$8080,$7FFF,$7FFF,$2000,$2000,$C000,$C000
	.dc.w	$2000,$0300,$6B24,$0B24,$0000,$0000,$8000,$8000
	.dc.w	$0000,$1C00,$5D24,$5D24,$0000,$0000,$8000,$8000
	.dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$E000,$E000
	.dc.w	$0000,$0000,$4924,$4924,$0000,$0000,$8000,$8000
	.dc.w	$0000,$0000,$4924,$4924,$0000,$0000,$8000,$8000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$576C,$0000,$0000,$5760,$0000,$0000,$0000,$0000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$0000,$0000,$0000,$6BAD,$0000,$0000,$0000,$C000
cmpimg28:		* Attack Computer Working (On)
	.dc.w	0,0
	.dc.w	15,2
	.dc.w	$0000,$0000,$4924,$4924,$0000,$0000,$8000,$8000
	.dc.w	$0000,$0000,$4924,$4924,$0000,$0000,$8000,$8000
	.dc.w	$0018,$0004,$FFF7,$FFF7,$0000,$0000,$E000,$E000
	.dc.w	$0000,$0063,$4967,$4967,$0000,$0000,$8000,$8000
	.dc.w	$0000,$0080,$49A4,$49A4,$8000,$0000,$8000,$0000
	.dc.w	$0000,$0100,$FFFF,$FFFF,$0000,$0000,$E000,$A000
	.dc.w	$8000,$8600,$4F24,$0F24,$2000,$2000,$8000,$8000
	.dc.w	$2000,$1800,$7924,$5924,$0000,$0000,$8000,$8000
	.dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$E000,$E000
	.dc.w	$0000,$0000,$4924,$4924,$0000,$0000,$8000,$8000
	.dc.w	$0000,$0000,$4924,$4924,$0000,$0000,$8000,$8000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$576D,$0000,$0000,$576C,$0000,$0000,$0000,$0000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$6BAD,$6BAD,$6BAD,$0000,$C000,$C000,$C000,$0000
cmpimg29:		* Attack Computer Working (On)
	.dc.w	0,0
	.dc.w	15,2
	.dc.w	$0000,$0000,$4924,$4924,$0000,$0000,$8000,$8000
	.dc.w	$0000,$0000,$4924,$4924,$0000,$0000,$8000,$8000
	.dc.w	$0008,$0030,$FFFF,$FFFF,$0000,$0000,$E000,$E000
	.dc.w	$0004,$00C2,$49E2,$49E2,$0000,$0000,$8000,$8000
	.dc.w	$0000,$0101,$4925,$4925,$0000,$0000,$8000,$8000
	.dc.w	$0000,$0200,$FFFF,$FFFF,$8000,$0000,$E000,$6000
	.dc.w	$8000,$8C00,$4D24,$4D24,$2000,$2000,$C000,$8000
	.dc.w	$2000,$1000,$7924,$1924,$0000,$0000,$8000,$8000
	.dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$E000,$E000
	.dc.w	$0000,$0000,$4924,$4924,$0000,$0000,$8000,$8000
	.dc.w	$0000,$0000,$4924,$4924,$0000,$0000,$8000,$8000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$576D,$576D,$576D,$0000,$0000,$0000,$0000,$0000
	.dc.w	$576D,$0000,$0000,$576D,$0000,$0000,$0000,$0000
	.dc.w	$0000,$6BAD,$6BAD,$0000,$0000,$C000,$C000,$0000
cmpimg30:		* Attack Computer Working (On)
	.dc.w	0,0
	.dc.w	15,2
	.dc.w	$0000,$0000,$4924,$4924,$0000,$0000,$8000,$8000
	.dc.w	$0000,$0000,$4924,$4924,$0000,$0000,$8000,$8000
	.dc.w	$0000,$0070,$FFFF,$FFFF,$0000,$0000,$E000,$E000
	.dc.w	$0000,$018C,$49AC,$49AC,$0000,$0000,$8000,$8000
	.dc.w	$0002,$0200,$4B26,$4B26,$0000,$0000,$8000,$8000
	.dc.w	$0001,$0400,$FFFE,$FFFE,$0000,$0000,$E000,$E000
	.dc.w	$0000,$1800,$5924,$5924,$8000,$0000,$C000,$0000
	.dc.w	$A000,$8000,$6924,$0924,$2000,$2000,$8000,$8000
	.dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$E000,$E000
	.dc.w	$0000,$0000,$4924,$4924,$0000,$0000,$8000,$8000
	.dc.w	$0000,$0000,$4924,$4924,$0000,$0000,$8000,$8000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$0000,$6BAD,$6BAD,$0000,$0000,$C000,$C000,$0000
	.dc.w	$576D,$576D,$576D,$0000,$0000,$0000,$0000,$0000
	.dc.w	$576D,$0000,$0000,$576D,$0000,$0000,$0000,$0000
cmpimg31:		* Attack Computer Working (On)
	.dc.w	0,0
	.dc.w	15,2
	.dc.w	$0000,$0000,$4924,$4924,$0000,$0000,$8000,$8000
	.dc.w	$0000,$0000,$4924,$4924,$0000,$0000,$8000,$8000
	.dc.w	$0000,$01C0,$FFFF,$FFFF,$0000,$0000,$E000,$E000
	.dc.w	$0000,$0630,$4F34,$4F34,$0000,$0000,$8000,$8000
	.dc.w	$0000,$0808,$492C,$492C,$0000,$0000,$8000,$8000
	.dc.w	$0000,$1004,$FFFF,$FFFF,$0000,$0000,$E000,$E000
	.dc.w	$2001,$0002,$6927,$0927,$0000,$0000,$8000,$8000
	.dc.w	$8000,$8000,$4924,$4924,$A000,$2000,$4000,$0000
	.dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$E000,$E000
	.dc.w	$0000,$0000,$4924,$4924,$0000,$0000,$8000,$8000
	.dc.w	$0000,$0000,$4924,$4924,$0000,$0000,$8000,$8000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$0000,$6BAD,$6BAD,$0000,$0000,$C000,$C000,$0000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$576D,$0000,$0000,$576D,$0000,$0000,$0000,$0000
cmpimg32:		* Attack Computer Working (On)
	.dc.w	0,0
	.dc.w	15,2
	.dc.w	$0000,$0000,$4924,$4924,$0000,$0000,$8000,$8000
	.dc.w	$0000,$0000,$4924,$4924,$0000,$0000,$8000,$8000
	.dc.w	$0000,$0380,$FFFF,$FFFF,$0000,$0000,$E000,$E000
	.dc.w	$0000,$0C60,$4D64,$4D64,$0000,$0000,$8000,$8000
	.dc.w	$0000,$1010,$5934,$5934,$0000,$0000,$8000,$8000
	.dc.w	$2000,$0008,$FFFF,$DFFF,$0000,$0000,$E000,$E000
	.dc.w	$8000,$8006,$4926,$0926,$2000,$0000,$8000,$8000
	.dc.w	$0000,$0001,$4925,$4925,$C000,$0000,$C000,$4000
	.dc.w	$0000,$0000,$FFFF,$FFFF,$0000,$0000,$E000,$E000
	.dc.w	$0000,$0000,$4924,$4924,$0000,$0000,$8000,$8000
	.dc.w	$0000,$0000,$4924,$4924,$0000,$0000,$8000,$8000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$6000,$0BAD,$0BAD,$0000,$0000,$C000,$C000,$0000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	.dc.w	$576D,$0000,$0000,$576D,$0000,$0000,$0000,$0000
acmimg0:		* Attack Computer Reticle (None)
	.dc.w	7,7
	.dc.w	15,1
	.dc.w	$0000,$0000,$0100,$0100,$0000,$0000,$0100,$0100
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0280,$0280
	.dc.w	$0000,$0000,$0820,$0820,$0000,$0000,$1010,$1010
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$D016,$D016
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$1010,$1010
	.dc.w	$0000,$0000,$0820,$0820,$0000,$0000,$0280,$0280
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0100,$0100
	.dc.w	$0000,$0000,$0100,$0100
acmimg1:		* Attack Computer Reticle (Up)
	.dc.w	4,7
	.dc.w	12,1
	.dc.w	$0000,$0000,$0800,$0800,$0000,$0000,$1C00,$1C00
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$1400,$1400
	.dc.w	$0000,$0000,$4100,$4100,$0000,$0000,$8080,$8080
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$8080,$8080
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$8080,$8080
	.dc.w	$0000,$0000,$4100,$4100,$0000,$0000,$1400,$1400
acmimg2:		* Attack Computer Reticle (Down)
	.dc.w	4,4
	.dc.w	12,1
	.dc.w	$0000,$0000,$1400,$1400,$0000,$0000,$4100,$4100
	.dc.w	$0000,$0000,$8080,$8080,$0000,$0000,$0000,$0000
	.dc.w	$0000,$0000,$8080,$8080,$0000,$0000,$0000,$0000
	.dc.w	$0000,$0000,$8080,$8080,$0000,$0000,$4100,$4100
	.dc.w	$0000,$0000,$1400,$1400,$0000,$0000,$0000,$0000
	.dc.w	$0000,$0000,$1C00,$1C00,$0000,$0000,$0800,$0800
acmimg3:		* Attack Computer Reticle (Left)
	.dc.w	8,4
	.dc.w	9,1
	.dc.w	$0000,$0000,$0140,$0140,$0000,$0000,$0410,$0410
	.dc.w	$0000,$0000,$0808,$0808,$0000,$0000,$4000,$4000
	.dc.w	$0000,$0000,$C808,$C808,$0000,$0000,$4000,$4000
	.dc.w	$0000,$0000,$0808,$0808,$0000,$0000,$0410,$0410
	.dc.w	$0000,$0000,$0140,$0140
acmimg4:		* Attack Computer Reticle (Up-Left)
	.dc.w	8,7
	.dc.w	12,1
	.dc.w	$0000,$0000,$0080,$0080,$0000,$0000,$01C0,$01C0
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0140,$0140
	.dc.w	$0000,$0000,$0410,$0410,$0000,$0000,$0808,$0808
	.dc.w	$0000,$0000,$4000,$4000,$0000,$0000,$C808,$C808
	.dc.w	$0000,$0000,$4000,$4000,$0000,$0000,$0808,$0808
	.dc.w	$0000,$0000,$0410,$0410,$0000,$0000,$0140,$0140
acmimg5:		* Attack Computer Reticle (Down-Left)
	.dc.w	8,4
	.dc.w	12,1
	.dc.w	$0000,$0000,$0140,$0140,$0000,$0000,$0410,$0410
	.dc.w	$0000,$0000,$0808,$0808,$0000,$0000,$4000,$4000
	.dc.w	$0000,$0000,$C808,$C808,$0000,$0000,$4000,$4000
	.dc.w	$0000,$0000,$0808,$0808,$0000,$0000,$0410,$0410
	.dc.w	$0000,$0000,$0140,$0140,$0000,$0000,$0000,$0000
	.dc.w	$0000,$0000,$01C0,$01C0,$0000,$0000,$0080,$0080
acmimg6:		* Attack Computer Reticle (Right)
	.dc.w	4,4
	.dc.w	9,1
	.dc.w	$0000,$0000,$1400,$1400,$0000,$0000,$4100,$4100
	.dc.w	$0000,$0000,$8080,$8080,$0000,$0000,$0010,$0010
	.dc.w	$0000,$0000,$8098,$8098,$0000,$0000,$0010,$0010
	.dc.w	$0000,$0000,$8080,$8080,$0000,$0000,$4100,$4100
	.dc.w	$0000,$0000,$1400,$1400
acmimg7:		* Attack Computer Reticle (Up-Right)
	.dc.w	4,7
	.dc.w	12,1
	.dc.w	$0000,$0000,$0800,$0800,$0000,$0000,$1C00,$1C00
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$1400,$1400
	.dc.w	$0000,$0000,$4100,$4100,$0000,$0000,$8080,$8080
	.dc.w	$0000,$0000,$0010,$0010,$0000,$0000,$8098,$8098
	.dc.w	$0000,$0000,$0010,$0010,$0000,$0000,$8080,$8080
	.dc.w	$0000,$0000,$4100,$4100,$0000,$0000,$1400,$1400
acmimg8:		* Attack Computer Reticle (Down-Right)
	.dc.w	4,4
	.dc.w	12,1
	.dc.w	$0000,$0000,$1400,$1400,$0000,$0000,$4100,$4100
	.dc.w	$0000,$0000,$8080,$8080,$0000,$0000,$0010,$0010
	.dc.w	$0000,$0000,$8098,$8098,$0000,$0000,$0010,$0010
	.dc.w	$0000,$0000,$8080,$8080,$0000,$0000,$4100,$4100
	.dc.w	$0000,$0000,$1400,$1400,$0000,$0000,$0000,$0000
	.dc.w	$0000,$0000,$1C00,$1C00,$0000,$0000,$0800,$0800


	.end
