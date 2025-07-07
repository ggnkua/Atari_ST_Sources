; ATARI.S       Equate and macro file for atari ST      RMS
;               Extended and Improved: 8/11/88 - RJZ
;               Combined and Extended and Improved: 09/16/88 - RMS
;

save_rs:        EQU ^^RSCOUNT   ;RS-Counter merken

; File header structure
                RSRESET
FILE_ID:        RS.W 1
TSIZE:          RS.L 1
DSIZE:          RS.L 1
BSIZE:          RS.L 1
SSIZE:          RS.L 1
XXX1:           RS.L 1
XXX2:           RS.L 1
XXX3:           RS.W 1
HEADSIZE:       EQU ^^RSCOUNT

; base page structure
                RSRESET
LOWTPA:         RS.L 1
HITPA:          RS.L 1
TBASE:          RS.L 1
TLEN:           RS.L 1
DBASE:          RS.L 1
DLEN:           RS.L 1
BBASE:          RS.L 1
BLEN:           RS.L 1
DTA:            RS.L 1
PARENT:         RS.L 1
XXXX:           RS.L 1
ENVIR:          RS.L 21
CMDLINE:        RS.B 128

; defines
TEXTSZ:         EQU TLEN
DATASZ:         EQU DLEN
BSSSZ:          EQU BLEN
BPSZ:           EQU ^^RSCOUNT
MYDTA:          EQU DTA
                RSSET save_rs   ;RS-Counter wieder zurcksetzen

CR:             EQU $0D
LF:             EQU $0A
TAB:            EQU $09

****
****  This is a preliminary equates file for the Atari ST;
****  not all the equates may be here, there may be typos
****  we haven't caught, and not all the macros for Gemdos
****  and the BIOS have been defined.
****

;
; Atari ST hardware locations
;
memconf:        EQU $FFFF8001   ;memory configuration
vbasehi:        EQU $FFFF8201
vbasemid:       EQU $FFFF8203   ;Video base address
vcounthi:       EQU $FFFF8205
vcountmid:      EQU $FFFF8207
vcountlo:       EQU $FFFF8209   ;Video display counter
syncmode:       EQU $FFFF820A   ;video sync mode
vbaselo:        EQU $FFFF820D   ;Video base address (lo; STE only)
linewid:        EQU $FFFF820F   ;Width of a scan-line (Words, minus 1; STE only)
palette:        EQU $FFFF8240   ;color registers 0..15
rezmode:        EQU $FFFF8260   ;Resolution mode (0=320x200,1=640x200,2=640x400)
hscroll:        EQU $FFFF8265   ;Horizontal scroll count (0..15; STE only)

diskctl:        EQU $FFFF8604   ;disk controller data access
fifo:           EQU $FFFF8606   ;DMA mode control
dmahi:          EQU $FFFF8609
dmamid:         EQU $FFFF860B
dmalo:          EQU $FFFF860D   ;DMA base address

cmdreg:         EQU $80         ;1770/FIFO command register select
trkreg:         EQU $82         ;1770/FIFO track register select
secreg:         EQU $84         ;1770/FIFO sector register select
datareg:        EQU $86         ;1770/FIFO data register select

; GI ("psg") sound chip:
giselect:       EQU $FFFF8800   ;(W) sound chip register select
giread:         EQU $FFFF8800   ;(R) sound chip read-data
giwrite:        EQU $FFFF8802   ;(W) sound chip write-data
gitoneaf:       EQU 0           ;channel A fine/coarse tune
gitoneac:       EQU 1
gitonebf:       EQU 2           ;channel B
gitonebc:       EQU 3
gitonecf:       EQU 4           ;channel C
gitonecc:       EQU 5
ginoise:        EQU 6           ;noise generator control
gimixer:        EQU 7           ;I/O control/volume control register
giaamp:         EQU 8           ;channel A, B, C amplitude
gibamp:         EQU 9
gicamp:         EQU $0A
gifienvlp:      EQU $0B         ;envelope period fine, coarse tune
gicrnvlp:       EQU $0C
giporta:        EQU $0E         ;GI register# for I/O port A
giportb:        EQU $0F         ;Centronics output register

; Bits in "giporta":
xrts:           EQU 8           ;RTS output
dtr:            EQU $10         ;DTR output
strobe:         EQU $20         ;Centronics strobe output
gpo:            EQU $40         ;"general purpose" output

; 68901 ("mfp") sticky chip:
mfp:            EQU $FFFFFA00   ;mfp base
gpip:           EQU mfp+1       ;general purpose I/O
aer:            EQU mfp+3       ;active edge reg
ddr:            EQU mfp+5       ;data direction reg
iera:           EQU mfp+7       ;interrupt enable A & B
ierb:           EQU mfp+9
ipra:           EQU mfp+$0B     ;interrupt pending A & B
iprb:           EQU mfp+$0D
isra:           EQU mfp+$0F     ;interrupt inService A & B
isrb:           EQU mfp+$11
imra:           EQU mfp+$13     ;interrupt mask A & B
imrb:           EQU mfp+$15
vr:             EQU mfp+$17     ;interrupt vector base
tacr:           EQU mfp+$19     ;timer A control
tbcr:           EQU mfp+$1B     ;timer B control
tcdcr:          EQU mfp+$1D     ;timer C & D control
tadr:           EQU mfp+$1F     ;timer A data
tbdr:           EQU mfp+$21     ;timer B data
tcdr:           EQU mfp+$23     ;timer C data
tddr:           EQU mfp+$25     ;timer D data
scr:            EQU mfp+$27     ;sync char
ucr:            EQU mfp+$29     ;USART control reg
rsr:            EQU mfp+$2B     ;receiver status
tsr:            EQU mfp+$2D     ;transmit status
udr:            EQU mfp+$2F     ;USART data

; 6850 registers:
keyctl:         EQU $FFFFFC00   ;keyboard ACIA control
keybd:          EQU $FFFFFC02   ;keyboard data
midictl:        EQU $FFFFFC04   ;MIDI ACIA control
midi:           EQU $FFFFFC06   ;MIDI data

; BIOS Variables
etv_timer:      EQU $0400       ;vector for timer interrupt chain
etv_critic:     EQU $0404       ;vector for critical error chain
etv_term:       EQU $0408       ;vector for process terminate
etv_xtra:       EQU $040C       ;5 reserved vectors
memvalid:       EQU $0420       ;indicates system state on RESET
memcntlr:       EQU $0424       ;mem controller config nibble
resvalid:       EQU $0426       ;validates 'resvector'
resvector:      EQU $042A       ;[RESET] bailout vector
phystop:        EQU $042E       ;physical top of RAM
_membot:        EQU $0432       ;bottom of available memory;
_memtop:        EQU $0436       ;top of available memory;
memval2:        EQU $043A       ;validates 'memcntlr' and 'memconf'
flock:          EQU $043E       ;floppy disk/FIFO lock variable
seekrate:       EQU $0440       ;default floppy seek rate
_timr_ms:       EQU $0442       ;system timer calibration (in ms)
_fverify:       EQU $0444       ;nonzero: verify on floppy write
_bootdev:       EQU $0446       ;default boot device
palmode:        EQU $0448       ;nonzero ==> PAL mode
defshiftmd:     EQU $044A       ;default video rez (first byte)
sshiftmd:       EQU $044C       ;shadow for 'shiftmd' register
_v_bas_ad:      EQU $044E       ;pointer to base of screen memory
vblsem:         EQU $0452       ;semaphore to enforce mutex in vbl
nvbls:          EQU $0454       ;number of deferred vectors
_vblqueue:      EQU $0456       ;pointer to vector of deferred vfuncs
colorptr:       EQU $045A       ;pointer to palette setup (or NULL)
screenpt:       EQU $045E       ;pointer to screen base setup (|NULL)
_vbclock:       EQU $0462       ;count of vblank interrupts
_frclock:       EQU $0466       ;count of unblocked vblanks (not blocked by vblsem)
hdv_init:       EQU $046A       ;hard disk initialization
swv_vec:        EQU $046E       ;video change-resolution bailout
hdv_bpb:        EQU $0472       ;disk "get BPB"
hdv_rw:         EQU $0476       ;disk read/write
hdv_boot:       EQU $047A       ;disk "get boot sector"
hdv_mediach:    EQU $047E       ;disk media change detect
_cmdload:       EQU $0482       ;nonzero: load COMMAND.COM from boot
conterm:        EQU $0484       ;console/vt52 bitSwitches (%%0..%%2)
trp14ret:       EQU $0486       ;saved return addr for _trap14
criticret:      EQU $048A       ;saved return addr for _critic
themd:          EQU $048E       ;memory descriptor (MD)
_____md:        EQU $049E       ;(more MD)
savptr:         EQU $04A2       ;pointer to register save area
_nflops:        EQU $04A6       ;number of disks attached (0, 1+)
constate:       EQU $04A8       ;state of conout() parser
save_row:       EQU $04AC       ;saved row# for cursor X-Y addressing
sav_context:    EQU $04AE       ;pointer to saved processor context
_bufl:          EQU $04B2       ;two buffer-list headers
_hz_200:        EQU $04BA       ;200hz raw system timer tick
_drvbits:       EQU $04C2       ;bit vector of "live" block devices
_dskbufp:       EQU $04C6       ;pointer to common disk buffer
_autopath:      EQU $04CA       ;pointer to autoexec path (or NULL)
_vbl_list:      EQU $04CE       ;initial _vblqueue (to $4ee)
_prt_cnt:       EQU $04EE       ;screen-dump flag (non-zero abort screen dump)
_prtabt:        EQU $04F0       ;printer abort flag
_sysbase:       EQU $04F2       ;-> base of OS
_shell_p:       EQU $04F6       ;-> global shell info
end_os:         EQU $04FA       ;-> end of OS memory usage
exec_os:        EQU $04FE       ;-> address of shell to exec on startup
scr_dump:       EQU $0502       ;-> screen dump code
prv_lsto:       EQU $0506       ;-> _lstostat()
prv_lst:        EQU $050A       ;-> _lstout()
prv_auxo:       EQU $050E       ;-> _auxostat()
prv_aux:        EQU $0512       ;-> _auxout()
