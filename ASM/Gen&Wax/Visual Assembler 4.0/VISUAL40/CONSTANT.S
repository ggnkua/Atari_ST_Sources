;---------------------------------------------------------------------------
;		Variables personnelles
;---------------------------------------------------------------------------
dos		= 1
bios		= 13
xbios		= 14

esc		= 27
lf		= 10
rc		= 13	; format Atari : rc lf
ff		= 12
bspc		= 8

read		= 0	; pour file open, write ...
write		= 1
read_write		= 2

RAM_ST=0
RAM_TT=1
RAM_ST_TT=2
RAM_TT_ST=3

; 0=BPS1 1=BPS2 2=BPS4 3=BPS8 4=BPS16 7=NUMCOLS
; 0=col40 8=col80 tv=0 vga=$10 pal=$20 overscan=$40 STmodes=$80 Vertflag=$100
res64048016		= $3a	; pour set mode : tout est en PAL/VGA
res640480256	= $3b
res320480tc		= $34
res32020016		= $1b2	; compatible basse
res32024016		= $132
res32048016		= $32
res320240256	= $133
res320240tc		= $134

freq8		= %00001011
freq10		= %00001001
freq12		= %00000111
freq16		= %00000101
freq20		= %00000100
freq25		= %00000011
freq33		= %00000010
freq49		= %00000001

;---------------------------------------------------------------------------

ETV_CRITIC		= $404
HDV_BPB		= $472
HDV_RW		= $476
HDV_MEDIAC		= $47E
_DRVBITS		= $4C2

ecran		= $44e
futur_ecran 	= $45e
vbl_cpt		= $466
cpt_200		= $4ba
vblqueue		= $4ce+4
enable_vbl  	= $452
hbl		= $68
palette		= $ffff8240
palette256		= $ffff9800
chipsonore		= $ffff8800
chipvideo		= $ffff8205
clavier		= $fffffc02
dma		= $ffff8604
datac		= $fffffa23
datad		= $fffffa25
ctrlcd		= $fffffa1d
timera		= $134
dataa		= $fffffa1f
ctrla		= $fffffa19
timerb		= $120
datab		= $fffffa21
ctrlb		= $fffffa1b

zilog8530A		= $ffff8c81
zilogrsA		= $ffff8c83	; zilog send/receive register
zilog8530B		= $ffff8c85
zilogrsB		= $ffff8c87

dsp_host_isr	= $ffffa202
dsp_host		= $ffffa204
codec_freq		= $ffff8935
;-------------------------------------------------------------------------
GWVA_WIND_TYPE_CUSTOM	= 1
GWVA_WIND_TYPE_TEXT	= 2
GWVA_WIND_TYPE_FORM	= 3
GWVA_WIND_TYPE_BITMAP	= 4
;-------------------------------------------------------------------------
GWVA_FORM_WIND_OBJECT_TEXT	= 1
GWVA_FORM_WIND_OBJECT_BUTTON	= 2
GWVA_FORM_WIND_OBJECT_MENU_POPUP	= 3
GWVA_FORM_WIND_OBJECT_RADIO_BUTTON	= 4
GWVA_FORM_WIND_OBJECT_ROLL_POPUP	= 5
GWVA_FORM_WIND_OBJECT_ROLL_RADIO_B	= 6
GWVA_FORM_WIND_OBJECT_PROGRESS_BAR	= 7
GWVA_FORM_WIND_OBJECT_SLIDER	= 8
;-------------------------------------------------------------------------
GWVA_EVNT_CLICK	= 1	; boutons (exit, touch-exit) ou texte (touch-exit) mais pas texte editable
GWVA_EVNT_DCLICK	= 2	; "" idem sauf pour le champs texte editable pour lequel le seul evnt est le double click
GWVA_EVNT_GOTFOCUS	= 3	; champs ‚ditable
GWVA_EVNT_LOSTFOCUS	= 4	; champs ‚ditable
GWVA_EVNT_SELECTED	= 5	; radio bouton, bouton selectable mais non exit
GWVA_EVNT_UNSELECTED	= 6	; "" idem
GWVA_EVNT_CHANGED	= 7	; popup, champs ‚ditable, dropdown list
;-------------------------------------------------------------------------
GWVA_ERROR_GENERIC		= -1
GWVA_ERROR_READ		= -11
GWVA_ERROR_MALLOC		= -39

GWVA_ERROR_WIND_BAD_HANDLE	= -1000
GWVA_ERROR_WIND_OPEN		= -1001
GWVA_ERROR_WIND_USER_CANCEL_OPEN	= -1002
GWVA_ERROR_WIND_ALREADY_CREATED	= -1010
GWVA_ERROR_WIND_VA_BUFF_FULL	= -1011
GWVA_ERROR_WIND_BAD_STRUCTURE	= -1012
GWVA_ERROR_WIND_BAD_COLOR_NBR	= -1013
GWVA_ERROR_WIND_BAD_INC_DEF	= -1014
GWVA_ERROR_WIND_GEM_CREATE	= -1020
GWVA_ERROR_WIND_USER_CANCEL_CREATE	= -1021
;-------------------------------------------------------------------------
GWVA_WIN_BIT_FULL		= 0
GWVA_WIN_BIT_OPEN		= 1
GWVA_WIN_BIT_CURS		= 2
GWVA_WIN_BIT_ICON		= 3
GWVA_WIN_BIT_NAMIFIED		= 4

GWVA_WIN_BIT_ATOOLBAR		= 0
GWVA_WIN_BIT_AMENU		= 1
GWVA_WIN_BIT_CTRLC		= 2
GWVA_WIN_BIT_CTRLV		= 3
GWVA_WIN_BIT_CTRLX		= 4
GWVA_WIN_BIT_COPYXY		= 8
GWVA_WIN_BIT_AUTODEL		= 9
GWVA_WIN_BIT_FREEPTR1		= 10
GWVA_WIN_BIT_FREEPTR2		= 11
GWVA_WIN_BIT_FREEDATA		= 12
GWVA_WIN_BIT_FREEPAL		= 13
GWVA_WIN_BIT_FREEFORM		= 14
;-------------------------------------------------------------------------
GWVA_APP_BIT_RSC_IN_MEM		= 0
GWVA_APP_BIT_RSC_MULTI_RES	= 1
GWVA_APP_BIT_BACKGROUND		= 2
GWVA_APP_BIT_BACKGROUND_CENTER	= 3
;-------------------------------------------------------------------------
;		Variables Document‚es GEM/AES/Autre
;-------------------------------------------------------------------------

AV_PROTOKOLL	= $4700
VA_PROTOSTATUS	= $4701
AV_GETSTATUS	= $4703
AV_STATUS		= $4704
VA_SETSTATUS	= $4705
AV_SENDKEY		= $4710
VA_START		= $4711
AV_ASKFILEFONT	= $4712
VA_FILEFONT		= $4713
AV_ASKCONFONT	= $4714
VA_CONFONT		= $4715
AV_ASKOBJECT	= $4716
VA_OBJECT		= $4717
AV_OPENCONSOLE	= $4718
VA_CONSOLEOPEN	= $4719
AV_OPENWIND		= $4720
VA_WINDOPEN		= $4721
AV_STARTPROG	= $4722
VA_PROGSTART	= $4723
AV_ACCWINDOPEN	= $4724
VA_DRAGACCWIND	= $4725
AV_ACCWINDCLOSED	= $4726
AV_COPY_DRAGGED	= $4728
VA_COPY_COMPLETE	= $4729
AV_PATH_UPDATE	= $4730
AV_WHAT_IZIT	= $4732
VA_THAT_IZIT	= $4733
AV_DRAG_ON_WINDOW	= $4734
AV_EXIT		= $4736

VA_OB_UNKNOWN	= 0
VA_OB_TRASHCAN	= 1
VA_OB_SHREDDER	= 2
VA_OB_CLIPBOARD	= 3
VA_OB_FILE		= 4
VA_OB_FOLDER	= 5
VA_OB_DRIVE		= 6
VA_OB_WINDOW	= 7

;-------------------------------------------------------------------------
; VISUAL
WM_BEFORE		= 0	; before doit ˆtre plus petit que after
WM_AFTER		= 1024

; Type de message GEM
MN_SELECTED		= 10
WM_REDRAW		= 20
WM_TOPPED		= 21
WM_CLOSED		= 22
WM_FULLED		= 23
WM_ARROWED		= 24
WM_HSLID		= 25
WM_VSLID		= 26
WM_SIZED		= 27
WM_MOVED		= 28
WM_NEWTOP		= 29
WM_UNTOPPED		= 30
WM_ONTOP		= 31
WM_BOTTOM		= 33
WM_ICONIFY		= 34
WM_UNICONIFY	= 35
WM_ALLICONIFY	= 36
WM_TOOLBAR		= 37
AC_OPEN		= 40
AC_CLOSE		= 41
AP_TERM		= 50
AP_TFAIL		= 51
AP_RESCHG		= 57
SHUT_COMPLETED	= 60
RESCH_COMPLETED	= 61
AP_DRAGDROP		= 63
SH_WDRAW		= 72
CH_EXIT		= 90

; Type de message GEM GWVA
WM_GWVA_REDRAW	= 20+1<<14	; Message interne pour les redraws du GWVA
WM_GWVA_NEWIND	= 29+1<<14	; Message re‡u … la cr‚ation d'une nouvelle fenˆtre, avant son 1er redraw
WM_GWVA_OPENED	= 31+1<<14	; Message re‡u … l'ouverture d'une fenˆtre, avant et/ou apres son 1er redraw


; Sous type pour le message WM_ARROWED
WA_UPPAGE		= 0
WA_DNPAGE		= 1
WA_UPLINE		= 2
WA_DNLINE		= 3
WA_LFPAGE		= 4
WA_RTPAGE		= 5
WA_LFLINE		= 6
WA_RTLINE		= 7

; mode pour le wind_set et wind_get
WF_NAME		= 2
WF_INFO		= 3
WF_WORKXYWH		= 4
WF_CURRXYWH		= 5
WF_PREVXYWH		= 6
WF_FULLXYWH		= 7
WF_HSLIDE		= 8
WF_VSLIDE		= 9
WF_TOP		= 10
WF_FIRSTXYWH	= 11
WF_NEXTXYWH		= 12
WF_NEWDESK		= 14
WF_HSLSIZE		= 15
WF_VSLSIZE		= 16
WF_SCREEN		= 17
WF_COLOR		= 18
WF_DCOLOR		= 19
WF_OWNER		= 20
WF_BEVENT		= 24
WF_BOTTOM		= 25
WF_ICONIFY		= 26
WF_UNICONIFY	= 27
WF_UNICONIFYXYWH	= 28
WF_TOOLBAR		= 30
WF_FTOOLBAR		= 31
WF_NTOOLBAR		= 32

; Paramˆtres pour le wind_update
END_UPDATE		= 0
BEG_UPDATE		= 1
END_MCTRL		= 2
BEG_MCTRL		= 3

; Liste des bit pour evnt_multi
EVNT_KEYBD		= 0	; attend une touche
EVNT_BUTTON		= 1	; attend un bouton de la souris
EVNT_MOUSE1		= 2	; attend la souris vers/dans une zone
EVNT_MOUSE2		= 3	; idem (2Šme zone)
EVNT_MESAG		= 4	; ‚vŠnement GEM
EVNT_TIMER		= 5	; timers

; Types d'objet graphique
G_BOX		= 20
G_TEXT		= 21
G_BOXTEXT		= 22
G_IMAGE		= 23
G_PROGDEF		= 24
G_IBOX		= 25
G_BUTTON		= 26
G_BOXCHAR		= 27
G_STRING		= 28
G_FTEXT		= 29
G_FBOXTEXT		= 30
G_ICON		= 31
G_TITLE		= 32
G_CICON		= 33

; ParamŠtres pour la fonction graf_mouse #type<,adresse>
ARROW		= 0
TEXT_CRSR		= 1
BUSY_BEE		= 2
POINT_HAND		= 3
FLAT_HAND		= 4
THIN_CROSS		= 5
THICK_CROSS		= 6
OUTLN_CROSS		= 7
USER_DEF		= 255	; + adresse
M_OFF		= 256
M_ON		= 257
M_SAVE		= 258	; + adresse ?
M_LAST		= 259	; + adresse ?
M_RESTORE		= 260	; + adresse ?

;-------------------------------------------------------------------------

; Mode d'affichage VDI
MD_REPLACE		= 1
