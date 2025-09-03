;-----   Die Teile des Betriebssystems   -----

GEMDOS      = 1
GEM         = 2
BIOS        = 13
XBIOS       = 14

VDI         = $73
AES         = $c8


;-----   Funktionen des GEMDOS   -----

CCONOUT     = $00000002
CRAWIO      = $00000006
CRAWCIN     = $00000007
CCONWS      = $00000009
DSETDRV     = $0000000e
FSETDTA     = $1a
DGETDRV     = $19
SUPER       = $20
TGETDATE    = $2a
TSETDATE    = $2b
TGETTIME    = $2c
TSETTIME    = $2d
FGETDTA     = $2f
DFREE       = $36
DCREATE     = $39
DSETPATH    = $3b
FCREATE     = $3c
FOPEN       = $3d
FCLOSE      = $3e
FREAD       = $3f
FWRITE      = $40
FDELETE     = $41
FSEEK       = $42
DGETPATH    = $47
MALLOC      = $48
MFREE       = $49
MSHRINK     = $4a
FSFIRST     = $4e
FSNEXT      = $4f
FRENAME     = $56


;-----   Funktionen des BIOS   -----

BCONSTAT    = 1
BCONIN      = 2
BCONOUT     = 3
RWABS       = 4
GETBPB      = 7
BCOSTAT     = 8
MEDIACH     = 9
DRVMAP      = 10
KBSHIFT     = 11


;-----   Funktionen des XBIOS   -----

PHYSBASE    = 2
LOGBASE     = 3
GETREZ      = 4
SETSCREEN   = 5
SETPALETTE  = 6
SETCOLOR    = 7
IOREC       = 14
RSCONF      = 15
RANDOM      = 17
CURSCONF    = 21
SETTIME     = 22
SETPRT      = 33
KBDVBASE    = 34
WAIT_VBL    = 37
SUPEXEC     = 38


;-----   Systemadressen / Systemvariablen   -----

LINE_A      = $28
IPL_4       = $70
TRAP_2      = $88
TRAP_13     = $b4
TIMER_C     = $114
TASTATUR    = $118

ETV_CRITIC  = $404
MEMVALID    = $420
MEMCTRL     = $424
RESVALID    = $426
RESVECTOR   = $42a
PHYSTOP     = $42e
MEMTOP      = $436
MEMVAL2     = $43a
FLOCK       = $43e
BOOTDEV     = $446
SSHIFTMD    = $44c
V_BAS_AD    = $44e
NVBLS       = $454
VBLQUEUE    = $456
SCREENPT    = $45e
FRCLOCK     = $466
HDV_BPB     = $472
HDV_RW      = $476
HDV_MEDIACH           = $47e
CONTERM     = $484
SAVPTR      = $4a2
HZ_200      = $4ba
DRVBITS     = $4c2
DSKBUFP     = $4c6
DUMP_VEC    = $502
PRT_STAT    = $506
PRT_VEC     = $50a

MPB         = $56ec   ;ROM-TOS
MPB_B       = $7e8e   ;Blitter-TOS
FONT_16     = $607e   ;Pointer auf 8*16 Font (ROM-TOS)
FONT_16B    = $8820   ;dito Blitter-TOS
FONT_8      = $41a8   ;Pointer auf 8*8 Font (ROM-TOS)
FONT_8B     = $694a   ;dito Blitter-TOS

OS_RESET    = $fc0020

MMU_KONF    = $ff8001
V_RAM_HB    = $ff8201
V_RAM_MB    = $ff8203
V_CNT_MB    = $ff8207
V_CNT_LB    = $ff8209
VSYNC       = $ff820a
PAL_ADDR    = $ff8240
REZ_ADDR    = $ff8260
YM_SELECT   = $ff8800
MFP_IO      = $fffa01


;-----   Sonstiges   -----

SCR_LEN     = 32*1024


;-----   Font-Daten   -----

F_DATA      = 76      ;Offset fÅr Pointer auf Font-Daten


;-----   AES Bibliothek   -----

APPL_INIT   = 10
APPL_EXIT   = 19
EVNT_MESAG  = 23
EVNT_MULTI  = 25
MENU_REGISTER         = 35
OBJC_DRAW   = 42
OBJC_OFFSET           = 44
OBJC_CHANGE           = 47
FORM_DO     = 50
FORM_DIAL   = 51
FORM_ALERT  = 52
FORM_CENTER           = 54
GRAF_MOVEBOX          = 72
GRAF_GROWBOX          = 73
GRAF_SHRINKBOX        = 74
GRAF_SLIDEBOX         = 76
GRAF_HANDLE           = 77
GRAF_MOUSE  = 78
GRAF_MKSTATE          = 79
FSEL_INPUT  = 90
WIND_UPDATE           = 107
RSRC_LOAD   = 110
RSRC_GADDR  = 112


;-----   VDI Bibliothek   -----

V_ESC       = 5
V_GTEXT     = 8
V_OPNVWK    = 100
V_CLSVWK    = 101
V_GET_PIXEL           = 105
VRO_CPYFORM           = 109
VQ_MOUSE    = 124
VEX_BUTV    = 125
VS_CLIP     = 129

V_SFONT     = 102     ;Unterfunktion VDI Escape


;-----   Sonstige Konstanten   -----
;-----------------------------------

;-----   GerÑte   -----

PRT         = 0
AUX         = 1
CON         = 2
CCON        = 5


;-----   Steuerzeichen   -----

NO_CHR      = 1       ;wird bei der Ausgabe ignoriert
BEL         = 7
BS          = 8
LF          = 10
FFEED       = 12
CR          = 13
ESC         = 27


;-----   RSC Definitionen   -----

R_TREE      = 0

G_BOXTEXT   = 22
G_BUTTON    = 26
G_STRING    = 28


;-----   Baumstruktur   -----

ROOT        = 0
MAX_DEPTH   = 8


;-----   FORM Manager   -----

FMD_START   = 0
FMD_GROW    = 1
FMD_SHRINK  = 2
FMD_FINISH  = 3


;-----   Mausformen   -----

ARROW       = 0
POINT_HAND  = 3

MOUSE_OFF   = 256
MOUSE_ON    = 257

CURS_OFF    = 0
CURS_ON     = 1
CURS_BLINK  = 2
CURS_STAND  = 3


;-----   Objekt Flags   -----

NORMAL      = 0
SELECTED    = 1
CROSSED     = 2
CHECKED     = 4
DISABLED    = 8
OUTLINED    = 16


;-----   EVENT Manager   -----

AC_OPEN     = 40
AC_CLOSE    = 41


;-----   Windows   -----

END_UPDATE  = 0
BEG_UPDATE  = 1
END_MCTRL   = 2
BEG_MCTRL   = 3

;-----   -----   -----   -----   -----



            .END 

