;*************************************************************************
;* Source zum Erzeugen der Symboltabelle SYMBOL.SYM, welche alle System- *
;* Symbole enth„lt. Original-Datei aus dem TurboAss-Paket. Erweiterungen *
;* von Robert Federle fr das Symbol-Treiber-Paket                       *
;*************************************************************************

              OUTPUT 'SYSTEM.SYM'
reset         EQU $04
bus_err       EQU $08
addr_err      EQU $0C
illegal       EQU $10
div_zero      EQU $14
CHK_com       EQU $18
TRAPV_com     EQU $1C
privilege     EQU $20
trace         EQU $24
Line_A        EQU $28
Line_F        EQU $2C
spurious      EQU $60

auto_i_1      EQU $64
auto_i_2_hbl  EQU $68
auto_i_3      EQU $6C
auto_i_4_vbl  EQU $70
auto_i_5      EQU $74
auto_i_6_mfp  EQU $78
auto_i_7      EQU $7C

trap0         EQU $80
trap1         EQU $84
trap2         EQU $88
trap3         EQU $8C
trap4         EQU $90
trap5         EQU $94
trap6         EQU $98
trap7         EQU $9C
trap8         EQU $A0
trap9         EQU $A4
trap10        EQU $A8
trap11        EQU $AC
trap12        EQU $B0
trap13        EQU $B4
trap14        EQU $B8
trap15        EQU $BC

busy_int      EQU $0100
dcd_int       EQU $0104
cts_int       EQU $0108
gpu_done      EQU $010C
baudrate      EQU $0110
timer200      EQU $0114
IKBD_MIDI     EQU $0118
FDC_ACSI      EQU $011C
display_enable EQU $0120
rs232_send_err EQU $0124
rs232_send_empty EQU $0128
rs232_rcv_err EQU $012C
rs232_rcv_empty EQU $0130
ring_ind      EQU $0138
monochrome    EQU $013C

tt_mfp        EQU $0140
tt_scc        EQU $0180

proc_lives    EQU $0380
proc_dregs    EQU $0384
proc_aregs    EQU $03A4
proc_enum     EQU $03C4       ; proc_pc ??
proc_usp      EQU $03C8
proc_stk      EQU $03CC

; BIOS Variables
etv_timer     EQU $0400       ;vector for timer interrupt chain
etv_critic    EQU $0404       ;vector for critical error chain
etv_term      EQU $0408       ;vector for process terminate
etv_xtra      EQU $040C       ;5 reserved vectors
memvalid      EQU $0420       ;indicates system state on RESET
memcntrl      EQU $0424       ;mem controller config nibble
resvalid      EQU $0426       ;validates 'resvector'
resvector     EQU $042A       ;[RESET] bailout vector
phystop       EQU $042E       ;physical top of RAM
_membot       EQU $0432       ;bottom of available memory;
_memtop       EQU $0436       ;top of available memory;
memval2       EQU $043A       ;validates 'memcntlr' and 'memconf'
flock         EQU $043E       ;floppy disk/FIFO lock variable
seekrate      EQU $0440       ;default floppy seek rate
_timr_ms      EQU $0442       ;system timer calibration (in ms)
_fverify      EQU $0444       ;nonzero: verify on floppy write
_bootdev      EQU $0446       ;default boot device
palmode       EQU $0448       ;nonzero ==> PAL mode
defshiftmd    EQU $044A       ;default video rez (first byte)
sshiftmd      EQU $044C       ;shadow for 'shiftmd' register
_v_bas_adr    EQU $044E       ;pointer to base of screen memory
vblsem        EQU $0452       ;semaphore to enforce mutex in vbl
nvbls         EQU $0454       ;number of deferred vectors
_vblqueue     EQU $0456       ;pointer to vector of deferred vfuncs
colorptr      EQU $045A       ;pointer to palette setup (or NULL)
screenpt      EQU $045E       ;pointer to screen base setup (|NULL)
_vbclock      EQU $0462       ;count of vblank interrupts
_frclock      EQU $0466       ;count of unblocked vblanks (not blocked by vblsem)
hdv_init      EQU $046A       ;hard disk initialization
swv_vec       EQU $046E       ;video change-resolution bailout
hdv_bpb       EQU $0472       ;disk "get BPB"
hdv_rw        EQU $0476       ;disk read/write
hdv_boot      EQU $047A       ;disk "get boot sector"
hdv_mediach   EQU $047E       ;disk media change detect
_cmdload      EQU $0482       ;nonzero: load COMMAND.COM from boot
conterm       EQU $0484       ;console/vt52 bitSwitches (%%0..%%2)
trp14ret      EQU $0486       ;saved return addr for _trap14
criticret     EQU $048A       ;saved return addr for _critic
themd         EQU $048E       ;memory descriptor (MD)
__md          EQU $049E       ;(more MD)
savptr        EQU $04A2       ;pointer to register save area
_nflops       EQU $04A6       ;number of disks attached (0, 1+)
con_state     EQU $04A8       ;state of conout() parser
sav_row       EQU $04AC       ;saved row# for cursor X-Y addressing
sav_context   EQU $04AE       ;pointer to saved processor context
_bufl         EQU $04B2       ;two buffer-list headers
_bufl2        EQU $04B6
_hz_200       EQU $04BA       ;200hz raw system timer tick
the_env       EQU $04BE       ;Pointer to System-Environment
_drvbits      EQU $04C2       ;bit vector of "live" block devices
_dskbufp      EQU $04C6       ;pointer to common disk buffer
_autopath     EQU $04CA       ;pointer to autoexec path (or NULL)
_vbl_list     EQU $04CE       ;initial _vblqueue (to $4ee)
prt_cnt       EQU $04EE       ;screen-dump flag (non-zero abort screen dump)
_prtabt       EQU $04F0       ;printer abort flag
_sysbase      EQU $04F2       ;-> base of OS
_shell_p      EQU $04F6       ;-> global shell info
end_os        EQU $04FA       ;-> end of OS memory usage
exec_os       EQU $04FE       ;-> address of shell to exec on startup
scr_dump      EQU $0502       ;-> screen dump code
prv_lsto      EQU $0506       ;-> _lstostat()
prv_lst       EQU $050A       ;-> _lstout()
prv_auxo      EQU $050E       ;-> _auxostat()
prv_aux       EQU $0512       ;-> _auxout()
pun_ptr       EQU $0516
memval3       EQU $051A       ;validates 'memcntlr' and 'memconf'
xconstat      EQU $051E
xconin        EQU $053E
xcostat       EQU $055E
xconout       EQU $057E
_longframe    EQU $059E
_p_cookies    EQU $05A0
remtop        EQU $05A4
remvalid      EQU $05A8
bell_hook     EQU $05AC       ; ab TOS 1.06
kcl_hook      EQU $05B0       ; ab TOS 1.06

_is_prt       EQU xconstat
_is_aux       EQU $0522
_is_con       EQU $0526
_is_midi      EQU $052A
_is_ikbd      EQU $052E
_is_rawcon    EQU $0532
_is_dev6      EQU $0536
_is_dev7      EQU $053A

_i_prt        EQU xconin
_i_aux        EQU $0542
_i_con        EQU $0546
_i_midi       EQU $054A
_i_ikbd       EQU $054E
_i_rawcon     EQU $0552
_i_dev6       EQU $0556
_i_dev7       EQU $055A

_os_prt       EQU xcostat
_os_aux       EQU $0562
_os_con       EQU $0566
_os_midi      EQU $056A
_os_ikbd      EQU $056E
_os_rawcon    EQU $0572
_os_dev6      EQU $0576
_os_dev7      EQU $057A

_o_prt        EQU xconout
_o_aux        EQU $0582
_o_con        EQU $0586
_o_midi       EQU $058A
_o_ikbd       EQU $058E
_o_rawcon     EQU $0592
_o_dev6       EQU $0596
_o_dev7       EQU $059A

cart_port     EQU $FFFA0000

os_start_old  EQU $FFFC0000
os_start_new  EQU $FFE00000

; Speicherkonfiguration:

memconf       EQU $FFFF8001   ;memory configuration

; Videocontroller:

dbaseh        EQU $FFFF8201
dbasel        EQU $FFFF8203   ;Video base address

vcounthi      EQU $FFFF8205
vcountmid     EQU $FFFF8207
vcountlow     EQU $FFFF8209   ;Video display counter

syncmode      EQU $FFFF820A   ;video sync mode

dbaselow      EQU $FFFF820D   ;Video base address (lo; STE only)

linewid       EQU $FFFF820F   ;Width of a scan-line (Words, minus 1; STE only)

palette       EQU $FFFF8240   ;color registers 0..15
color0        EQU $FFFF8240
color1        EQU $FFFF8242
color2        EQU $FFFF8244
color3        EQU $FFFF8246
color4        EQU $FFFF8248
color5        EQU $FFFF824A
color6        EQU $FFFF824C
color7        EQU $FFFF824E
color8        EQU $FFFF8250
color9        EQU $FFFF8252
color10       EQU $FFFF8254
color11       EQU $FFFF8256
color12       EQU $FFFF8258
color13       EQU $FFFF825A
color14       EQU $FFFF825C
color15       EQU $FFFF825E

shiftmd       EQU $FFFF8260   ;Resolution mode (0=320x200,1=640x200,2=640x400)

shift_tt      EQU $FFFF8262   ; TT-Shift-Mode-Register

hscroll       EQU $FFFF8265   ; Horizontal scroll count (0..15; STE only)

stacydsp      EQU $FFFF827E   ; STACY Display-Steuerung

; TT-Farbpalettenregister:

TT_col0       EQU $FFFF8400
TT_col1       EQU $FFFF8402
TT_col2       EQU $FFFF8404
TT_col3       EQU $FFFF8406
TT_col4       EQU $FFFF8408
TT_col5       EQU $FFFF840A
TT_col6       EQU $FFFF840C
TT_col7       EQU $FFFF840E
TT_col8       EQU $FFFF8410
TT_col9       EQU $FFFF8412
TT_col10      EQU $FFFF8414
TT_col11      EQU $FFFF8416
TT_col12      EQU $FFFF8418
TT_col13      EQU $FFFF841A
TT_col14      EQU $FFFF841C
TT_col15      EQU $FFFF841E

; DMA-Controller:

diskctl       EQU $FFFF8604   ;disk controller data access
fifo          EQU $FFFF8606   ;DMA mode control
dmahigh       EQU $FFFF8609
dmamid        EQU $FFFF860B
dmalow        EQU $FFFF860D   ;DMA base address

; SCSI-DMA:

tt_dmabas     EQU $FFFF8701
tt_dmabas1    EQU $FFFF8703
tt_dmabas2    EQU $FFFF8705
tt_dmabas3    EQU $FFFF8707
tt_dmacnt     EQU $FFFF8709
tt_dmacnt1    EQU $FFFF870B
tt_dmacnt2    EQU $FFFF870D
tt_dmacnt3    EQU $FFFF870F
tt_dmarsd     EQU $FFFF8710
tt_dmarsdlo   EQU $FFFF8712
tt_dmactl     EQU $FFFF8714

; SCSI-Controller 5380:

s_data        EQU $FFFF8781
s_icr         EQU $FFFF8783
s_mode        EQU $FFFF8785
s_tcr         EQU $FFFF8787
s_idstat      EQU $FFFF8789
s_dmastat     EQU $FFFF878B
s_targrcv     EQU $FFFF878D
s_inircv      EQU $FFFF878F

; Soundchip AY-3-8910:

giselect      EQU $FFFF8800   ;(W) sound chip register select
giread        EQU $FFFF8800   ;(r) sound chip read-data
giwrite       EQU $FFFF8802   ;(W) sound chip write-data

; DMA-Sound-Subsystem:

sndmactl      EQU $FFFF8900
sndbashi      EQU $FFFF8902
sndbasmi      EQU $FFFF8904
sndbaslo      EQU $FFFF8906
sndadrhi      EQU $FFFF8908
sndadrmi      EQU $FFFF890A
sndadrlo      EQU $FFFF890C
sndendhi      EQU $FFFF890E
sndendmi      EQU $FFFF8910
sndendlo      EQU $FFFF8912
sndmide       EQU $FFFF8920
MWDATA        EQU $FFFF8922
MWMASK        EQU $FFFF8924

; Uhrenchip des TT:

rtc_rnr       EQU $FFFF8961
rtc_data      EQU $FFFF8963

; Blitter:

Halftone      EQU $FFFF8A00
Src_Xinc      EQU $FFFF8A20
Src_Yinc      EQU $FFFF8A22
Src_addr      EQU $FFFF8A24
Endmask1      EQU $FFFF8A28
Endmask2      EQU $FFFF8A2A
Endmask3      EQU $FFFF8A2C
Dst_Xinc      EQU $FFFF8A2E
Dst_Yinc      EQU $FFFF8A30
Dst_addr      EQU $FFFF8A32
X_Count       EQU $FFFF8A36
Y_Count       EQU $FFFF8A38
HOP           EQU $FFFF8A3A
OP            EQU $FFFF8A3B
Line_Num      EQU $FFFF8A3C
Skew          EQU $FFFF8A3D

; SCC-DMA:

scdmabas      EQU $FFFF8C01
scdmabas1     EQU $FFFF8C03
scdmabas2     EQU $FFFF8C05
scdmabas3     EQU $FFFF8C07
scdmacnt      EQU $FFFF8C09
scdmacnt1     EQU $FFFF8C0B
scdmacnt2     EQU $FFFF8C0D
scdmacnt3     EQU $FFFF8C0F
scdmarsd      EQU $FFFF8C10
scdmarsd1     EQU $FFFF8C12
scdmactl      EQU $FFFF8C14

; Serial Communications Controller (SCC):

sccctl_a      EQU $FFFF8C81
sccdat_a      EQU $FFFF8C83
sccctl_b      EQU $FFFF8C85
sccdat_b      EQU $FFFF8C87

; System Control Unit (SCU):

sys_mask      EQU $FFFF8E01
sys_stat      EQU $FFFF8E03
sys_int       EQU $FFFF8E05
vme_int       EQU $FFFF8E07
scu_gp1       EQU $FFFF8E09
scu_gp2       EQU $FFFF8E0B
vme_mask      EQU $FFFF8E0D
vme_stat      EQU $FFFF8E0F
ste_ctl       EQU $FFFF8E21

; Joystickports beim STE:

PADDL0        EQU $FFFF9210
PADDL1        EQU $FFFF9212
PADDL2        EQU $FFFF9214
PADDL3        EQU $FFFF9216
XPEN          EQU $FFFF9220
YPEN          EQU $FFFF9222

; Multifunktionsbaustein MFP MC68901:

mfp           EQU $FFFFFA00   ;mfp base
gpip          EQU mfp+1       ;general purpose I/O
aer           EQU mfp+3       ;active edge reg
ddr           EQU mfp+5       ;data direction reg
iera          EQU mfp+7       ;interrupt enable A & B
ierb          EQU mfp+9
ipra          EQU mfp+$0B     ;interrupt pending A & B
iprb          EQU mfp+$0D
isra          EQU mfp+$0F     ;interrupt inService A & B
isrb          EQU mfp+$11
imra          EQU mfp+$13     ;interrupt mask A & B
imrb          EQU mfp+$15
vr            EQU mfp+$17     ;interrupt vector base
tacr          EQU mfp+$19     ;timer A control
tbcr          EQU mfp+$1B     ;timer B control
tcdcr         EQU mfp+$1D     ;timer C & D control
tadr          EQU mfp+$1F     ;timer A data
tbdr          EQU mfp+$21     ;timer B data
tcdr          EQU mfp+$23     ;timer C data
tddr          EQU mfp+$25     ;timer D data
scr           EQU mfp+$27     ;sync char
ucr           EQU mfp+$29     ;USART control reg
rsr           EQU mfp+$2B     ;receiver status
tsr           EQU mfp+$2D     ;transmit status
udr           EQU mfp+$2F     ;USART data

; Floating Point Processor MC68881 (SFP004):

FPstat        EQU $FFFFFA40
FPctl         EQU $FFFFFA42
FPsave        EQU $FFFFFA44
FPrestor      EQU $FFFFFA46
FPcmd         EQU $FFFFFA4A
FPccr         EQU $FFFFFA4E
FPop          EQU $FFFFFA50
FPselct       EQU $FFFFFA54
FPiadr        EQU $FFFFFA58

; TT-MFP MFP MC68901:

MFP_TT        EQU $FFFFFA80   ;mfp base
GPIP_TT       EQU MFP_TT+1    ;general purpose I/O
AER_TT        EQU MFP_TT+3    ;active edge reg
DDR_TT        EQU MFP_TT+5    ;data direction reg
IERA_TT       EQU MFP_TT+7    ;interrupt enable A & B
IERB_TT       EQU MFP_TT+9
IPRA_TT       EQU MFP_TT+$0B  ;interrupt pending A & B
IPRB_TT       EQU MFP_TT+$0D
ISRA_TT       EQU MFP_TT+$0F  ;interrupt inService A & B
ISRB_TT       EQU MFP_TT+$11
IMRA_TT       EQU MFP_TT+$13  ;interrupt mask A & B
IMRB_TT       EQU MFP_TT+$15
VR_TT         EQU MFP_TT+$17  ;interrupt vector base
TACR_TT       EQU MFP_TT+$19  ;timer A control
TBCR_TT       EQU MFP_TT+$1B  ;timer B control
TCDCR_TT      EQU MFP_TT+$1D  ;timer C & D control
TADR_TT       EQU MFP_TT+$1F  ;timer A data
TBDR_TT       EQU MFP_TT+$21  ;timer B data
TCDR_TT       EQU MFP_TT+$23  ;timer C data
TDDR_TT       EQU MFP_TT+$25  ;timer D data
SCR_TT        EQU MFP_TT+$27  ;sync char
UCR_TT        EQU MFP_TT+$29  ;USART control reg
RSR_TT        EQU MFP_TT+$2B  ;receiver status
TSR_TT        EQU MFP_TT+$2D  ;transmit status
UDR_TT        EQU MFP_TT+$2F  ;USART data

; Tastatur-ACIA:

keyctl        EQU $FFFFFC00   ;keyboard ACIA control
keybd         EQU $FFFFFC02   ;keyboard data
midictl       EQU $FFFFFC04   ;MIDI ACIA control
midi          EQU $FFFFFC06   ;MIDI data

; Clock registers:
s_units       EQU $FFFFFC21
s_tens        EQU $FFFFFC23
m_units       EQU $FFFFFC25
m_tens        EQU $FFFFFC27
h_units       EQU $FFFFFC29
h_tens        EQU $FFFFFC2B
weekday       EQU $FFFFFC2D
day_units     EQU $FFFFFC2F
day_tens      EQU $FFFFFC31
mon_units     EQU $FFFFFC33
mon_tens      EQU $FFFFFC35
yr_units      EQU $FFFFFC37
yr_tens       EQU $FFFFFC39
cl_mod        EQU $FFFFFC3B
cl_test       EQU $FFFFFC3D
cl_reset      EQU $FFFFFC3F
              END
