
; indexwerte zum direkten zugriff

SNDJUMP		equ	0-128
SNDSHHIGHER	equ	0-128
SNDSHDEEPER	equ	0-128

SNDFOOTER	equ	1-128

;todo snd_menue_act	equ	7-128		; ok
;snd_menue_deact	equ	8-128		; ok
;snd_menue_up	equ	9-128		; ok
;snd_menue_down	equ	9-128		; ok
;snd_menue_right	equ	10-128		; ok
;snd_menue_left	equ	11-128		; ok
;snd_menue_enter	equ	12-128		; ok
;snd_menue_item	equ	12-128		; ok


SNDDOORLOCKED	equ	6-128
SNDDOOROPEN	equ	4-128
SNDDOORCLOSE	equ	4-128
SNDDOORRASTET	equ	15-128

SNDLIFTLOCKED	equ	6-128
SNDLIFTOPEN	equ	4-128
SNDLIFTCLOSE	equ	4-128
SNDLIFTRASTET	equ	15-128

SNDPLAYERHIT	equ	34-128
SNDPLAYERDIED	equ	35-128

SNDNEEDTHING	equ	34-128
SNDITEM		equ	5-128
SNDSWITCH	equ	5-128

SNDCAMERAVIEW	equ	7-128
SNDTELEPORTER	equ	14-128

SNDSCHREIBM	equ	13-128

SNDADRIAN	equ	20-128
SNDDIEHARD	equ	21-128
SNDHASTA	equ	22-128
SNDASSES	equ	23-128
SNDBORED	equ	24-128
SNDADIOS	equ	25-128
SNDWELLDONE	equ	26-128
SNDYIPI		equ	27-128
SNDDOPE		equ	28-128
SNDGOOD		equ	29-128
SNDLIKE		equ	30-128
SNDDONT		equ	31-128
SNDNICE		equ	32-128
SNDCHECK	equ	33-128
SNDAHH		equ	34-128
SNDARGHH	equ	35-128
SNDCOOL		equ	36-128
SNDUBAHN	equ	37-128
SNDEND1		equ	38-128
SNDEND2		equ	39-128



; struktur samples (splxx/interne samples)/levelsamples (externe samples)
SAMPLEMODE		equ	0
SAMPLEADDRESSLEFT	equ	2
SAMPLEADDRESSRIGHT	equ	6
SAMPLELENGTH		equ	10
SAMPLESPEEDINDEX	equ	14
SAMPLEFILENAME		equ	16
SAMPLEBYTES		equ	20

; definition samplemode
SAMPLEMODEBITSTEREO	equ	0	; bit 0: 0 = mono, 1 = stereo
SAMPLEMODEBITINRAM	equ	1	; bit 1: 0 = nicht im speicher eingeladen, 1 = im speicher bereits eingeladen
SAMPLEMODEBITUNDEFINED	equ	15	; bit 15: 0 = eintrag/struktur gueltig, 1 (also negativ) = eintrag ungueltig (z. b. noch nicht eingeladen)




SAMPLES		equ	0




		data


; ---------------------------------------------------------
; interne samples
;  0 = kein sample fuer den index vorhanden
; -1 = ende des array erreicht
samples		dc.l	sample00		; spieler springt (jump)
		dc.l	sample01		; spieler tritt zu (footer)
		dc.l	sample02		; schuss 1
		dc.l	sample03		; schuss 2
;		dc.l	sample04
;		dc.l	sample05
;		dc.l	sample06
;		dc.l	sample07
;		dc.l	sample08
;		dc.l	sample09
;		dc.l	sample10
;		dc.l	sample11
;		dc.l	sample12
;		dc.l	sample13
;		dc.l	sample14
;		dc.l	sample15
;		dc.l	sample16
;		dc.l	sample17
;		dc.l	sample18
;		dc.l	sample19
;		dc.l	sample20
;		dc.l	sample21
;		dc.l	sample22
;		dc.l	sample23
;		dc.l	sample24
;		dc.l	sample25
;		dc.l	sample26
;		dc.l	sample27
;		dc.l	sample28
;		dc.l	sample29
;		dc.l	sample30
;		dc.l	sample31
;		dc.l	sample32
;		dc.l	sample33
;		dc.l	sample34
;		dc.l	sample35
;		dc.l	sample36
;		dc.l	sample37
;		dc.l	sample38
;		dc.l	sample39
		dc.l	-1			; flag fuer ende

; ungueltiger sampleeintrag
sampleIncorrect	dc.w	%1000000000000000
		dc.l	0
		dc.l	0
		dc.l	0
		dc.w	0
		dc.l	0


sample00	dc.w	%0000000000000010
		dc.l	sample00Binary
		dc.l	sample00Binary
		dc.l	sample00BinaryE-sample00Binary
		dc.w	12
		dc.l	0

sample01	dc.w	%0000000000000010
		dc.l	sample01Binary
		dc.l	sample01Binary
		dc.l	sample01BinaryE-sample01Binary
		dc.w	19
		dc.l	0

sample02	dc.w	%0000000000000010
		dc.l	sample02Binary
		dc.l	sample02Binary
		dc.l	sample02BinaryE-sample02Binary
		dc.w	19
		dc.l	0

sample03	dc.w	%0000000000000010
		dc.l	sample03Binary
		dc.l	sample03Binary
		dc.l	sample03BinaryE-sample03Binary
		dc.w	19
		dc.l	0



sample00Binary	incbin	"include\samples\player\jump.sam"
sample00BinaryE
sample01Binary	incbin	"include\samples\player\footer.sam"
sample01BinaryE
sample02Binary	incbin	"include\samples\weapon\pistol1.sam"
sample02BinaryE
sample03Binary	incbin	"include\samples\weapon\pistol2.sam"
sample03BinaryE

		even



		ifne SAMPLES
sam_s4          incbin	"samples\misc\open5.sam"
sam_s5          incbin	"samples\misc\get.sam"
sam_s6          incbin	"samples\misc\locked.sam"
sam_s7		incbin	"samples\menu\mnuon.sam"
sam_s8		incbin	"samples\menu\mnuoff.sam"
sam_s9		incbin	"samples\menu\mnuclick.sam"
sam_s10		incbin	"samples\menu\mnuright.sam"
sam_s11		incbin	"samples\menu\mnuleft.sam"
sam_s12		incbin	"samples\menu\mnuchoos.sam"
sam_s13		incbin	"samples\computer\tasta030.sam"
sam_s14		incbin	"samples\misc\teleporter.sam"
sam_s15		incbin	"samples\misc\eingeras.sam"
sam_s16

; "Angriff"-Samples
sam_s20		incbin	"samples\angriff\adrian3.sam"
sam_s21		incbin	"samples\angriff\diehard.sam"
sam_s22		incbin	"samples\angriff\hasta.sam"

; "Boring"-Samples
sam_s23		incbin	"samples\boring\asses.sam"
sam_s24		incbin	"samples\boring\bored.sam"
sam_s25		

; "Medizin"-Samples
sam_s28		incbin	"samples\medizin\dope.sam"
sam_s29		incbin	"samples\medizin\good2.sam"
sam_s30		incbin	"samples\medizin\like.sam"

; "Waffe"-Samples
sam_s31		incbin	"samples\waffe\dont.sam"
sam_s32		incbin	"samples\waffe\nice.sam"
sam_s33		incbin	"samples\waffe\check2.sam"

; "Other"-Samples
sam_s34		incbin	"samples\other\ahh.sam"
sam_s35		incbin	"samples\other\arghh.sam"
sam_s36		incbin	"samples\other\cool.sam"

sam_s37		incbin	"samples\misc\ubahn.sam"
sam_s38

sam_end
		even

		else

		dc.l	0,3008,19		; 0
		dc.l	0,2265,19		; 1
		dc.l	0,2553,19		; 2
		dc.l	0,16470,19		; 3
		dc.l	0,12171,19		; 4
		dc.l	0,1845,19		; 5
		dc.l	0,3089,19
		dc.l	0,2800,19
		dc.l	0,2672,19
		dc.l	0,468,19
		dc.l	0,1939,19		; 10
		dc.l	0,2058,19
		dc.l	0,8480,19
		dc.l	0,804,19
		dc.l	0,7038,19
		dc.l	0,6158,19		; 15
		dc.l	0,0,19
		dc.l	0,0,19
		dc.l	0,0,19
		dc.l	0,0,19
		dc.l	0,11807,19		; 20
		dc.l	0,6268,19
		dc.l	0,11806,19
		dc.l	0,12515,19
		dc.l	0,22683,19
		dc.l	0,-12931,19		; 25
		dc.l	0,-7316,19
		dc.l	0,-9798,19
		dc.l	0,14194,19
		dc.l	0,19108,19
		dc.l	0,8926,19		; 30
		dc.l	0,10788,19
		dc.l	0,9917,19
		dc.l	0,6730,19
		dc.l	0,3904,19
		dc.l	0,7490,19		; 35
		dc.l	0,21848,19
		dc.l	0,6318,19
		dc.l	0,-14461,19		; 38
		dc.l	0,-63098,19
		dc.l	-1

		endc



		even