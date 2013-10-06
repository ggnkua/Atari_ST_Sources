

; struktur level
		rsreset
LEVTRAINS	rs.l	1
LEVMONSTERS	rs.l	1
LEVFILES	rs.l	1
LEVFILES512	rs.l	1
LEVBODEN	rs.l	1
LEVSTARTPOINT	rs.l	1
LEVINITDATA	rs.l	1
LEVPISTOL	rs.l	1
LEVINITLEVEL	rs.l	1
LEVCAMERAS	rs.l	1
LEVTIMELIMIT	rs.l	1
LEVGROESSE	rs.l	1
LEVINFOS	rs.l	1
LEVSECSTART	rs.l	1


; struktur levinfos
LIEPISODE	equ	0
LILEVEL		equ	2
LIDSPGENAU	equ	4
LINAMEPTR	equ	6
LILENTXTPTR	equ	10
LILEKTXTPTR	equ	14
LILETTXTPTR	equ	18
LILEQTXTPTR	equ	22
LIAUFTXTPTR	equ	26
LIFILE		equ	30

; struktur levcameras

CAMSEKTOR	equ	0
CAMSX		equ	2
CAMSY		equ	6
CAMSH		equ	10
CAMALPHASTART	equ	14
CAMALPHAEND	equ	16

; struktur levinitdata

		rsreset
INITSKYZOOM	rs.l	1
INITSKYXYOFFSET	rs.l	1
INITSKYTEXTNB	rs.l	1
INITSKYMASK	rs.l	1
INITSKYEFFFLAG	rs.w	1
INITSKYEFFECT	rs.w	1	
INITAS0		rs.l	1
INITAS1		rs.l	1
INITAS2		rs.l	1
INITAS3		rs.l	1
INITAS4		rs.l	1
INITAS5		rs.l	1
INITAS6		rs.l	1
INITAS7		rs.l	1
INITAS8		rs.l	1
INITAS9		rs.l	1
INITVISSECPTR	rs.l	1
INITNEEDEDTT	rs.l	1

IASVBL		equ	0
IASREICHWEITE	equ	2
IASANZAHL	equ	6
IASHOEHE	equ	8
IASPHASEN	equ	10

IASPTEXTNB	equ	0
IASPLINEFLAG3	equ	2

; struktur lvx_startpoint

STARTX		equ	0
STARTY		equ	4
STARTH		equ	8
STARTALPHA	equ	12
STARTSECTOR	equ	16

; struktur lvx_secx

SECAKTION	equ	0
SECLINES	equ	4
SECPOINTS	equ	8
SECDOORS	equ	12
SECLIFT		equ	16
SECTHINGS	equ	20
SECMONLINE	equ	24
SECSWITCHES	equ	28
SECSECT		equ	32
SECOSECT	equ	36
SECEXTLINES	equ	40

; struktur sec_things

THINGLINE	equ	0
THINGBREITE	equ	20
THINGTYPE	equ	22
THINGANIMATION	equ	24
THINGVISTAKEN	equ	28
THINGVISACT	equ	30
THINGSAMPLE	equ	32
THINGACTION	equ	34

; struktur sec_schalter

SWITCHLINE	equ	0
SWITCHWIDTH	equ	28
SWITCHTYPE	equ	30
SWITCHLOOPFLAG	equ	32
SWITCHACTION	equ	34
SWITCHNBACTIONS	equ	36
SWITCHANIMATION	equ	38
SWITCHVISTAKEN	equ	42
SWITCHVISACT	equ	44
SWITCHSAMPLE	equ	46
SWITCHACTIONPTR	equ	48

; struktur timelimit

TIMELIMITFLAG	equ	0
TIMELIMITSEC	equ	2
TIMELIMITVBL	equ	4

; struktur animation
		rsreset
ANIMATIONNB	rs.w	1
ANIMATIONPOS	rs.w	1
ANIMATIONSPEED	rs.w	1
ANIMATIONCOUNT	rs.w	1
ANIMATIONDATA	rs.l	1

; struktur pistol

PISTOLINFO	equ	0
PISTOLFILES	equ	4

PISTOLSAMSHT	equ	0
PISTOLSAMREL	equ	2
PISTOLBRIGHT	equ	4

PIDOFF2		equ	0
PIDOFF3		equ	4
PIDOFF4		equ	8
PIDLENGTH	equ	12
PIDD1		equ	16
PIDD2		equ	24
PIDD3		equ	32
PIDD4		equ	40
PIDDATA		equ	48

; struktur sec_doors

DOORPTS		equ	0
DOORLINE	equ	32
DOORSEC		equ	112
DOOROPSEC	equ	160
DOORSTATUS	equ	192
DOORANGLE	equ	194
DOORNEEDTHING	equ	196
DOORH1		equ	198
DOORH2		equ	200
DOORUNDER	equ	202
DOOROTIME	equ	204
DOORCOUNT	equ	206
DOORAUTOCLOSE	equ	208


; struktur sec_lifts

LIFTPTS		equ	0
LIFTLINE	equ	32
LIFTSECPTR	equ	112
LIFTOPSEC	equ	116
LIFTSTATUS	equ	148
LIFTNEEDTHING	equ	150
LIFTH1		equ	152
LIFTH2		equ	154
LIFTT1		equ	156
LIFTOTIME	equ	158
LIFTCOUNT	equ	160

; struktur initlevel
		rsreset
ILEVWEAPONS	rs.l	1

; unterstruktur initlevel-weapons
		rsreset
ILEVWPNFOOTFLAG	rs.w	1
ILEVWPNACTRAD	rs.l	1
ILEVWPNSTARTFLAG	rs.w	1
ILEVWPNSTART	rs.w	1
ILEVWPNSTATIC	rs.w	1
ILEVWPNMAX	rs.w	1
ILEVWPNBPCKMAX	rs.w	1
ILEVWPNCAPTION	rs.l	1

; struktur lvx_trains
TRNDATA		equ	0
TRNMOVE		equ	4
TRNMAX		equ	8

; struktur lvx_monsters
		rsreset
MONDAT		rs.l	1
MONSDAT		rs.l	1 

;---

		rsreset
MLDEFPTR	rs.l	1
MLFROMSECTOR	rs.w	1
MLTOSECTOR	rs.w	1
MLBYTES		rs.w	1

		rsreset
MLDEFX		rs.l	1
MLDEFY		rs.l	1
MLDEFSH		rs.w	1
MLDEFALPHA	rs.w	1
MLDEFLENGTH	rs.l	1
MLDEFBYTES	rs.w	1

;---

		rsreset
MONLINE		rs.b	20
MONADDFLAGS	rs.b	4		; [31..0]: 31 = hit by dsp/even dead, 30 = change sides, 29 = make transparent
MONGRAPHICTYPE	rs.w	1
MONWALKRADFLAG	rs.b	1
MONWALKINGTYPE	rs.b	1
MONSHOOTTYPE	rs.w	1
MONREACTTIME	rs.w	1
MONSEC		rs.w	1
MONSECML	rs.w	1
MONSECMLLINE	rs.w	1
MONSECMLDIST	rs.w	1
MONACTRADIUS	rs.l	1
MONWALKDIR	rs.w	1
MONFORMERPOS	rs.l	2

MONAWALK	rs.w	1
MONAWALKPOS	rs.w	1
MONASHOOT	rs.w	1
MONASHOOTPOS	rs.w	1
MONAHIT		rs.w	1
MONADIED	rs.w	1
MONADIEDPOS	rs.w	1

MONHEALTH	rs.w	1
MONHEALTHORIG	rs.w	1
MONSNDSHOOT	rs.w	1
MONSNDHIT	rs.w	1
MONSNDDIED	rs.w	1

MONSTRENGTH	rs.w	1
MONSHTACTRAD	rs.w	1
MONSHTTIME1	rs.w	1
MONSHTTIME2	rs.w	1
MONTHINGTYPE	rs.w	2
MONZIVILIAN	rs.w	1
MONSHTCOUNT1000	rs.w	1
MONREACTCOUNT	rs.w	1

;---
		rsreset
SDATWALKPTR	rs.w	1			;equ	0
SDATWALKANZ	rs.w	1			;equ	2
SDATSHOOTPTR	rs.w	1			;equ	4
SDATSHOOTANZ	rs.w	1			;equ	6
SDATSHTDPTR	rs.w	1			;equ	8
SDATSHTDANZ	rs.w	1			;equ	10
SDATHITPTR	rs.w	1			;equ	12
SDATDIEDPTR	rs.w	1			;equ	14
SDATDIEDANZ	rs.w	1			;equ	16
SDATDIEDHPTR	rs.w	1			;equ	18
SDATDIEDHANZ	rs.w	1			;equ	20
SDATSDAT	rs.w	1			;equ	22

;---

tm_pointer_mdat		equ	0
tm_distance		equ	4
tm_abschnitt		equ	6
tm_abschnitt_anz	equ	8
tm_dx			equ	10
tm_dy			equ	12
tm_data_length		equ	14

td_data_length		equ	36*4

mdatc_type		equ	0
mdatc_x			equ	2
mdatc_y			equ	6
mdatc_winkel_start	equ	10
mdatc_winkel_anz	equ	12
mdatc_radius		equ	14
mdatc_winkelgeschw	equ	16

mdat_length		equ	32

mdat_type       EQU 0           ; Typkennzeichnung Linie
mdat_anfang_x   EQU 2
mdat_anfang_y   EQU 6
mdat_rvec_x     EQU 10
mdat_rvec_y     EQU 12
mdat_rvec_len   EQU 14
mdat_rvec_alpha EQU 16
mdat_norm_gesch EQU 18
mdat_anh_flag   EQU 20
mdat_anh_time   EQU 22
mdat_besch_flag EQU 24
mdat_akt_gesch  EQU 26
mdat_verzoeg    EQU 28
mdat_anh_count  EQU 30

;---

SKYZOOM		equ	0
SKYXYOFFSET	equ	4
SKYTEXT		equ	8
SKYMASK		equ	12

;---

LFNBEPISODE	equ	0
LFEPISODEPTR	equ	2

LFNBLEVEL	equ	0
LFLEVELPTR	equ	2

;---

AKTIONTYPE	equ	0
AKTIONFLAG	equ	2
AKTIONONCEFLAG	equ	4
AKTIONVISIBLE	equ	6
AKTIONMLANZ	equ	8
AKTIONOPTARG	equ	10

;---

SFPOINT0	equ	0
SFPOINT1	equ	10
SFPOINT2	equ	20
SFPOINT3	equ	30
SFPOINT4	equ	40
SFSH		equ	48
SFOTHERSEC	equ	50
SFNEEDTHING	equ	52
SFNEEDACT	equ	53
SFNEEDSTRENGTH	equ	54
SFHEIGHT	equ	56
SFENERGY	equ	58
SFFLAGS		equ	60
SFMINX		equ	62
SFMAXX		equ	66
SFMINY		equ	70
SFMAXY		equ	74

SFBYTES		equ	78

;**************************************

mnu_yoffset	equ	22

;**************************************


snd_jump	equ	0-128		; ok
snd_footer	equ	1-128		; ok

snd_menue_act	equ	7-128		; ok
snd_menue_deact	equ	8-128		; ok
snd_menue_up	equ	9-128		; ok
snd_menue_down	equ	9-128		; ok
snd_menue_right	equ	10-128		; ok
snd_menue_left	equ	11-128		; ok
snd_menue_enter	equ	12-128		; ok
snd_menue_item	equ	12-128		; ok

snd_sh_higher   EQU 	0-128		; ok
snd_sh_dieper   EQU 	0-128		; ok

snd_door_locked	equ	6-128		; ok
snd_door_open	equ	4-128		; ok
snd_door_close	equ	4-128		; ok
snd_door_rastet	equ	15-128		; ok

snd_lift_locked	equ	6-128		; ok
snd_lift_open   equ	4-128		; ok
snd_lift_close	equ	4-128		; ok
snd_lift_rastet	equ	15-128		; ok

snd_player_hit	equ	34-128		; ok
snd_player_died	equ	35-128		; ok

snd_need_thing	equ	34-128		; ok

snd_item	equ	5-128		; ok
snd_schalter	equ	5-128		; ok

snd_cameraview	equ	7-128		; ok
snd_teleporter	equ	14-128		; ok

snd_schreibm	equ	13-128		; ok


; sprachsamples mit 8 kHz

snd_adrian	equ	20-128
snd_diehard	equ	21-128
snd_hasta	equ	22-128
snd_asses	equ	23-128
snd_bored	equ	24-128
snd_adios	equ	25-128
snd_welldone	equ	26-128
snd_yipi	equ	27-128
snd_dope	equ	28-128
snd_good	equ	29-128
snd_like	equ	30-128
snd_dont	equ	31-128
snd_nice	equ	32-128
snd_check	equ	33-128
snd_ahh		equ	34-128
snd_arghh	equ	35-128
snd_cool	equ	36-128

snd_ubahn	equ	37-128

snd_end1	equ	38-128
snd_end2	equ	39-128

;**************************************

; struktur sam_dat

spl_length	equ	0	; .l
spl_offset	equ	4	; .l
spl_frac	equ	8	; .l
spl_address	equ	12	; .l
spl_info_pos	equ	16
spl_info_vol_l	equ	17
spl_info_vol_r	equ	18
spl_info_loop	equ	19
spl_x		equ	20	; .l
spl_y		equ	24	; .l
spl_speed	equ	28	; .w
spl_voltab	equ	30	; .l
spl_vorkomma	equ	34	; .l
spl_nachkomma	equ	38	; .w
spl_play_offi	equ	40	; .l
spl_voltab_left	equ	44	; .l

spl_dat_length	equ	48


;**************************************


th_static       EQU 0

th_red_key      EQU 1
th_green_key    EQU 2
th_blue_key     EQU 3
th_yellow_key   EQU 4

th_mun0         EQU 5
th_mun1         EQU 6
th_mun2         EQU 7
th_mun3         EQU 8

th_scanner      EQU 9
th_night	equ 10
th_mask		equ 11
th_smedkit_i	equ	12
th_bmedkit_i	equ	13
th_smedkit	equ	14
th_bmedkit	equ	15
th_sarmor	equ	16
th_barmor	equ	17

th_invul	equ	18
th_invis	equ	19

th_pistol1	equ	20
th_pistol2	equ	21
th_pistol3	equ	22
th_pistol4	equ	23

th_radsuit	equ	24
th_geigercount	equ	25
th_jetpack	equ	26
th_backpack	equ	27

th_mondetector	equ	28
th_plan		equ	29

th_mun0_def	equ	30
th_mun1_def	equ	31
th_mun2_def	equ	32
th_mun3_def	equ	33

th_opendoor	equ	34
th_openlift	equ	35
th_closedoor	equ	36
th_closelift	equ	37

th_teleporter	equ	38
th_cameraview	equ	39
th_terminal	equ	40
th_welder	equ	41

th_time_deact	equ	42
th_verseuch	equ	43
th_level_ende	equ	44
th_sample	equ	45

th_littleplan	equ	46
th_neverget	equ	47
th_sftozero	equ	48
th_changevis	equ	49
th_laserdeact	equ	50

th_message	equ	51
th_sprengstoff	equ	52
th_zuender	equ	53

th_primary	equ	54
th_secondary	equ	55

th_geninvul	equ	56
th_geninvis	equ	57

th_color0	equ	58
th_color1	equ	59
th_color2	equ	60
th_color3	equ	61
th_color4	equ	62
th_color5	equ	63
th_color6	equ	64
th_color7	equ	65
th_color	equ	66

th_bierkrug	equ	67
th_trndetector	equ	68

th_dcolor0	equ	69
th_dcolor1	equ	70
th_dcolor2	equ	71
th_dcolor3	equ	72
th_dcolor4	equ	73
th_dcolor5	equ	74
th_dcolor6	equ	75
th_dcolor7	equ	76
th_dcolor	equ	77

th_secchangevis	equ	78
th_burger	equ	79

th_condom	equ	80
th_idcard	equ	81

th_whichend	equ	82

things_max	equ	83


;**************************************

mon_walk_time   EQU 10
mon_hit_time    EQU 20          ; alle angaben in vbl
mon_died_time   EQU 10
mon_shoot_time  EQU 10

;**************************************

; make_terminal

mt_max_spalten	equ	42
mt_max_reihen	equ	22

mt_offset	equ	640*32+81*2
mt_font_heigth	equ	5

;---

; make_laptop

ml_max_spalten	equ	29
ml_max_reihen	equ	16
ml_aufeinmal	equ	10

ml_offset	equ	640*40+106*2
ml_font_heigth	equ	5

;---

; anzahl an aufnehmbarer munition

munx0_beg	equ	75
munx1_beg	equ	50
munx2_beg	equ	30
munx3_beg	equ	20

; anzahl an aufnehmbarer munition mit backpack

munx0_backpack	equ	100
munx1_backpack	equ	80
munx2_backpack	equ	60
munx3_backpack	equ	40

; anzahl munition bei beginn

mun0_beg	equ	50
mun1_beg	equ	20
mun2_beg	equ	10
mun3_beg	equ	5

; anzahl munition fuer things_typen 30 - 33

mun_0_static	equ	10		
mun_1_static	equ	10		
mun_2_static	equ	10		
mun_3_static	equ	10		

;-----------------------

plr_scanner	equ	0
plr_geiger	equ	1







		text


; ---------------------------------------------------------
; laedt die leveldatei gemaess den variablen
; episode und level in den speicher
; und setzt den pointer auf den level
; episode = episodennummer
; level = levelnummer
loadLevel
		movem.w	episode,d6-d7		; episoden- und levelnummer

		movem.l	d0-a6,-(sp)
		movea.l	screen_2,a0
		move.l	a0,-(sp)
		swap	d6
		move.w	d7,d6
		move.l	d6,-(sp)
		bsr	paintHex
		addq.l	#8,sp
		movem.l	(sp)+,d0-a6

		lea	levelFiles,a0
		movea.l	LFEPISODEPTR(a0,d6.w*4),a0
		movea.l	LFLEVELPTR(a0,d7.w*4),a0
		bsr.s	loadLevelNow

		move.l	#level,levelPtr
		
		rts

; ---------------------------------------------------------
; laedt den in a0 angegebenen level in den speicher
; und ueberarbeitet die pointer
; a0 = dateiname
loadLevelNow
;		IFEQ FINAL
		lea	levelFilename,a0			; todo
;		ENDC

		lea	fileIO,a6
		move.l	a0,FILENAME(a6)
		move.l	#level,FILEBUFFER(a6)
		move.l	#LEVELMAXBYTES,FILEBYTES(a6)
		bsr	loadFile

		rts



		data


;		IFEQ FINAL
levelFilename	dc.b	"data\current.rld",0
		even
;		ENDC


		bss


levelPtr	ds.l	1

