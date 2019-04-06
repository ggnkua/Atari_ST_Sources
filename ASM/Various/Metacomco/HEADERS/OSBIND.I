**************************************************************************
*                                                                        *
*                               OSBIND.I                                 *
*                                                                        *
* This header file contains equates for use with the Atari GEMDOS, BIOS  *
* and XBIOS traps. It contains the function number equates for the three *
* traps as well as some useful constants. It also contains the addresses *
* of the system variables and the offsets into system data structures.   *
*                                                                        *
**************************************************************************

* Trap numbers

gemdos           EQU    1
bios             EQU    13
xbios            EQU    14

* GEMDOS functions  

pterm0           EQU    $0
cconin           EQU    $1
cconout          EQU    $2
cauxin           EQU    $3
cauxout          EQU    $4
cprnout          EQU    $5
crawio           EQU    $6
crawcin          EQU    $7
cnecin           EQU    $8
cconws           EQU    $9
cconrs           EQU    $0A
cconis           EQU    $0B
dsetdrv          EQU    $0E
cconos           EQU    $10
cprnos           EQU    $11
cauxis           EQU    $12
cauxos           EQU    $13
dgetdrv          EQU    $19
fsetdta          EQU    $1A
super            EQU    $20
tgetdate         EQU    $2A
tsetdate         EQU    $2B
tgettime         EQU    $2C
tsettime         EQU    $2D
fgetdta          EQU    $2F
sversion         EQU    $30
ptermres         EQU    $31
dfree            EQU    $36
dcreate          EQU    $39
ddelete          EQU    $3A
dsetpath         EQU    $3B
fcreate          EQU    $3C
fopen            EQU    $3D
fclose           EQU    $3E
fread            EQU    $3F
fwrite           EQU    $40
fdelete          EQU    $41
fseek            EQU    $42
fattrib          EQU    $43
fdup             EQU    $45
fforce           EQU    $46
dgetpath         EQU    $47
malloc           EQU    $48
mfree            EQU    $49
mshrink          EQU    $4A
pexec            EQU    $4B
pterm            EQU    $4C
fsfirst          EQU    $4E
fsnext           EQU    $4F
frename          EQU    $56
fdatime          EQU    $57

* BIOS functions

getmpb           EQU    0
bconstat         EQU    1
bconin           EQU    2
bconout          EQU    3
rwabs            EQU    4
setexc           EQU    5
tickcal          EQU    6
getbpb           EQU    7
bcostat          EQU    8
mediach          EQU    9
drvmap           EQU    10
kbshift          EQU    11

* XBIOS functions

initmous         EQU    0
ssbrk            EQU    1
physbase         EQU    2
logbase          EQU    3
getrez           EQU    4
setscreen        EQU    5
setpallete       EQU    6
setcolor         EQU    7
floprd           EQU    8
flopwr           EQU    9
flopfmt          EQU    10
midiws           EQU    12
mfpint           EQU    13
iorec            EQU    14
rsconf           EQU    15
keytbl           EQU    16
random           EQU    17
protobt          EQU    18
flopver          EQU    19
scrdmp           EQU    20
cursconf         EQU    21
settime          EQU    22
gettime          EQU    23
bioskeys         EQU    24
ikbdws           EQU    25
jdisint          EQU    26
jenabint         EQU    27
giaccess         EQU    28
offgibit         EQU    29
ongibit          EQU    30
xbtimer          EQU    31
dosound          EQU    32
setprt           EQU    33
kbdvbase         EQU    34
kbrate           EQU    35
prtblk           EQU    36
vsync            EQU    37
supexec          EQU    38
puntaes          EQU    39

* GEMDOS constants

* Drive numbers for dfree and dgetpath functions

DRV_DEFAULT      EQU    0
DRV_FLOPPYA      EQU    1
DRV_FLOPPYB      EQU    2

* Attributes for the fattrib, fcreate and fsfirst functions

A_READWRITE      EQU    $00
A_READONLY       EQU    $01
A_HIDDEN         EQU    $02
A_SYSTEM         EQU    $04
A_VOLUME         EQU    $08
A_DIRECTORY      EQU    $10
A_WRITECLOSED    EQU    $20

* Open modes for the fopen function

OPEN_READ        EQU    0
OPEN_WRITE       EQU    1
OPEN_RW          EQU    2

* Seek modes for the fseek function

SEEK_BEGIN       EQU    0
SEEK_HERE        EQU    1
SEEK_END         EQU    2

* Execute modes for the pexec function

EXEC_LOAD_AND_GO     EQU    0
EXEC_LOAD_NO_GO      EQU    3
EXEC_JUST_GO         EQU    4
EXEC_CREATE_BASEPAGE EQU    5

* BIOS constants

* Devices for the bconstat, bconin, bcostat, mediach and bconout routines

DEV_PRT          EQU    0
DEV_AUX          EQU    1
DEV_CON          EQU    2
DEV_MIDI         EQU    3
DEV_KEYBOARD     EQU    4
DEV_RAWCONOUT    EQU    5

* Read/Write modes for the rwabs function

RW_READ          EQU    0
RW_WRITE         EQU    1
RW_READ_NMC      EQU    2
RW_WRITE_NMC     EQU    3

* Device numbers for the rwabs, getbpb and mediach functions

DEV_FLOPPYA      EQU    0
DEV_FLOPPYB      EQU    1

* Return values for the mediach function

MEDIA_NOTCHANGED EQU    0
MEDIA_MAYCHANGED EQU    1
MEDIA_HASCHANGED EQU    2

* XBIOS constants

* Mouse actions for the initmous procedure 

MOUSE_DISABLE    EQU    0
MOUSE_ENABLE_REL EQU    1
MOUSE_ENABLE_ABS EQU    2
MOUSE_UNUSED     EQU    3
MOUSE_ENABLE_KEY EQU    4

* Return values for the getrez function 

LOW_RES          EQU    0
MED_RES          EQU    1
HIGH_RES         EQU    2

* Device numbers for use with the iorec function 

IOREC_RS232      EQU    0
IOREC_KEYBOARD   EQU    1
IOREC_MIDI       EQU    2

* Baud rates for use with the rsconf procedure 

BAUD_19200       EQU     0
BAUD_9600        EQU     1
BAUD_4800        EQU     2
BAUD_3600        EQU     3
BAUD_2400        EQU     4
BAUD_2000        EQU     5
BAUD_1800        EQU     6
BAUD_1200        EQU     7
BAUD_600         EQU     8
BAUD_300         EQU     9
BAUD_200         EQU    10
BAUD_150         EQU    11
BAUD_134         EQU    12
BAUD_110         EQU    13
BAUD_75          EQU    14
BAUD_50          EQU    15

* Flow control protocols for use with the rsconf procedure 

RSCONF_NONE      EQU    0
RSCONF_XON       EQU    1
RSCONF_RTS       EQU    2

* Boot sector type flags for the protobt procedure 

EXEC_NO          EQU     0
EXEC_YES         EQU     1
EXEC_UNCHANGED   EQU    -1

* Disk types for the protobt procedure 

SINGLE_40        EQU    0
DOUBLE_40        EQU    1
SINGLE_80        EQU    2
DOUBLE_80        EQU    3

* Function numbers to determine the action of the cursconf function 

CURSOR_DISABLE   EQU    0
CURSOR_ENABLE    EQU    1
CURSOR_BLINK     EQU    2
CURSOR_NOBLINK   EQU    3
CURSOR_SETRATE   EQU    4
CURSOR_GETRATE   EQU    5

* Multi-Function Peripheral (MFP) timers for the xbtimer procedure 

TIMERA           EQU    0
TIMERB           EQU    1
TIMERC           EQU    2
TIMERD           EQU    3

* Printer configuration word bit masks for the setprt function 

BIT_TYPE         EQU    %000001
BIT_COLOUR       EQU    %000010
BIT_MAKE         EQU    %000100
BIT_MODE         EQU    %001000
BIT_PORT         EQU    %010000
BIT_FEED         EQU    %100000

* Date and time shifts and masks for use with the gettime function 

MASK_SEC         EQU    $0000001F
MASK_MIN         EQU    $0000007E
MASK_HOUR        EQU    $0000F800
MASK_DAY         EQU    $001F0000
MASK_MONTH       EQU    $01E00000
MASK_YEAR        EQU    $FE000000

SHIFT_MIN        EQU    5
SHIFT_HOUR       EQU    11
SHIFT_DAY        EQU    16
SHIFT_MONTH      EQU    21
SHIFT_YEAR       EQU    25

* Base page offsets

p_lowtpa         EQU    $00    Base of Transient Program Area (TPA)
p_hitpa          EQU    $04    End of TPA
p_tbase          EQU    $08    Base of text segment
p_tlen           EQU    $0C    Size of text segment
p_dbase          EQU    $10    Base of data segment
p_dlen           EQU    $14    Size of data segment
p_bbase          EQU    $18    Base of BSS segment
p_blen           EQU    $1C    Size of BSS segment
p_dta            EQU    $20    Disk Transfer Address
p_parent         EQU    $24    Address of parent's basepage
* reserved              $28    Reserved
p_env            EQU    $2C    Address of environment string
p_cmdlin         EQU    $80    Commandline image

* BIOS parameter block (BPB) offsets

bpb_recsiz       EQU    0      Sector size in bytes
bpb_clsiz        EQU    2      Cluster size in sectors
bpb_clsizb       EQU    4      Cluster size in bytes
bpb_rdlen        EQU    6      Directory length in sectors
bpb_fsiz         EQU    8      FAT size in sectors
bpb_fatrec       EQU    10     Sector number of second FAT
bpb_datrec       EQU    12     Sector number of first data cluster
bpb_numcl        EQU    14     Number of data clusters on the disk
bpb_bflags       EQU    16     Miscellaneous flags

* Disk Transfer Address (DTA) offsets

dta_reserved     EQU    0      First 21 bytes reserved
dta_attributes   EQU    21     File attribute bits
dta_timestamp    EQU    22     Time stamp
dta_datestamp    EQU    24     Date stamp
dta_filesize     EQU    26     File size
dta_filename     EQU    30     14-byte filename and extension

* System variables

* Post-mortem dump area

proc_lives       EQU    $380   $12345678 if valid
proc_dregs       EQU    $384   Saved D0 to D7
proc_aregs       EQU    $3A4   Saved A0 to A6 and SSP
proc_enum        EQU    $3C4   Exception number (1st byte)
proc_usp         EQU    $3C8   USP
proc_stk         EQU    $3CC   Sixteen words from SSP

* Other system variables

etv_timer        EQU    $400   GEM's event timer vector
etv_critic       EQU    $404   GEM's critical error handler
etv_term         EQU    $408   GEM's program termination code
etv_xtra         EQU    $40C   Five unused GEM vectors
memvalid         EQU    $420   Memory controller config valid if $752019F3
memcntlr         EQU    $424   Memory controller configuration value
resvalid         EQU    $426   Jump to resvector at reset if $31415926
resvector        EQU    $42A   Reset vector used if resvalid = $31415926
phystop          EQU    $42E   Top of physical memory
_membot          EQU    $432   Bottom of user memory
_memtop          EQU    $436   Top of user memory
memval2          EQU    $43A   Memory controller config valid if $237698AA
flock            EQU    $43E   Disk access in progress if non-zero
seekrate         EQU    $440   Seek rate (0=6ms, 1=12ms, 2=2ms, 3=3ms)
_timr_ms         EQU    $442   Timer resolution
_fverify         EQU    $444   Perform verify after disk write if non-zero
_bootdev         EQU    $446   Device number of boot device
palmode          EQU    $448   System in PAL mode if non-zero (else NTSC)
defshiftmd       EQU    $44A   Default colour screen reolution (0=low, 1=med)
sshiftmd         EQU    $44C   Copy of the shiftmd hardware register
_v_bas_ad        EQU    $44E   Pointer to base of screen memory
vblsem           EQU    $452   Flag to enable(1)/disable(0) VBI handler
nvbls            EQU    $454   Number of Vertical Blank Interrupt handlers
_vblqueue        EQU    $456   Pointer to table of VBI handlers
colorptr         EQU    $45A   Colour palette to be loaded at next VBI (or 0)
screenpt         EQU    $45E   Pointer to the base of screen memory
_vbclock         EQU    $462   Number of VBIs
_frclock         EQU    $466   Number of VBIs actually processed
hdv_init         EQU    $46A   Pointer to hard disk initialisation code
swv_vec          EQU    $46E   Handler for screen resolution change
hdv_bpb          EQU    $472   Pointer to getbpb routine for hard disk
hdv_rw           EQU    $476   Pointer to rwabs routine for hard disk
hdv_boot         EQU    $47A   Pointer to boot routine for hard disk
hdv_mediach      EQU    $47E   Pointer to mediach routine for hard disk
_cmdload         EQU    $482   If non-zero attempt to exec command.prg
conterm          EQU    $484   Attribute bits for the console system
trp14ret         EQU    $486   Return address for a trap #14
criticret        EQU    $48A   Return address for the critical error handler
themd            EQU    $48E   Memory descriptor fileed by getmpb call
savptr           EQU    $4A2   Pointer to BIOS register save area
_nflops          EQU    $4A6   Number of floppy disks attached to the system
sav_context      EQU    $4AE   Pointer to saved processor context
_bufl            EQU    $4B4   Two pointers to GEMDOS buffers
_hz_200          EQU    $4BC   Counter for 200Hz system clock
the_env          EQU    $4BE   Default environment string
_drvbits         EQU    $4C2   Bit map of connected drives
_dskbufp         EQU    $4C6   Pointer to 1K disk buffer
_autopath        EQU    $4CA   Pointer to auto execute path
_vbl_list        EQU    $4CE   List of up to 8 VBL interrupt handlers
_prt_cnt         EQU    $4EE   Count of number of Alt Help requests
_sysbase         EQU    $4F2   Pointer to the base of the OS
_shell_p         EQU    $4F6   Pointer to shell specific context information
end_os           EQU    $4FA   Pointer to the first byte after the OS
exec_os          EQU    $4FE   Pointer to the start of the AES

* $FF8000 Memory configuration

memory_config       EQU $FF8001           8 bits

* $FF8200 Video display registers (VDR)

vdr_screen_high     EQU $FF8201           8 bits
vdr_screen_low      EQU $FF8203           8 bits
vdr_video_high      EQU $FF8205           8 bits
vdr_video_mid       EQU $FF8207           8 bits
vdr_video_low       EQU $FF8209           8 bits
vdr_sync_mode       EQU $FF820A           2 bits
vdr_colour_0        EQU $FF8240           16 bits
vdr_colour_1        EQU $FF8242           16 bits
vdr_colour_2        EQU $FF8244           16 bits
vdr_colour_3        EQU $FF8246           16 bits
vdr_colour_4        EQU $FF8248           16 bits
vdr_colour_5        EQU $FF824A           16 bits
vdr_colour_6        EQU $FF824C           16 bits
vdr_colour_7        EQU $FF824E           16 bits
vdr_colour_8        EQU $FF8250           16 bits
vdr_colour_9        EQU $FF8252           16 bits
vdr_colour_10       EQU $FF8254           16 bits
vdr_colour_11       EQU $FF8256           16 bits
vdr_colour_12       EQU $FF8258           16 bits
vdr_colour_13       EQU $FF825A           16 bits
vdr_colour_14       EQU $FF825C           16 bits
vdr_colour_15       EQU $FF825E           16 bits
vdr_resolution      EQU $FF8260           2 bits

* $FF8600 Direct memory access (DMA) and floppy disk controller (FDC)

fdc_reserved        EQU $FF8600           16 bits
fdc_access          EQU $FF8604           16 bits
dma_mode            EQU $FF8606           16 bits
dma_basis_high      EQU $FF8609           8 bits
dma_basis_mid       EQU $FF860B           8 bits
dma_basis_low       EQU $FF860D           8 bits

* $FF8800 YM-2149 sound chip

ym_read_data        EQU $FF8800           8 bits
ym_write_data       EQU $FF8802           8 bits

* $FFFA00 68901 Multi function peripheral (MFP)

mfp_par_port        EQU $FFFA01           8 bits
mfp_active_edge     EQU $FFFA03           8 bits
mfp_data_dir        EQU $FFFA05           8 bits
mfp_int_enable_A    EQU $FFFA07           8 bits
mfp_int_enable_B    EQU $FFFA09           8 bits
mfp_int_pend_A      EQU $FFFA0B           8 bits
mfp_int_pend_B      EQU $FFFA0D           8 bits
mfp_int_doing_A     EQU $FFFA0F           8 bits
mfp_int_doing_B     EQU $FFFA11           8 bits
mfp_int_mask_A      EQU $FFFA13           8 bits
mfp_int_mask_B      EQU $FFFA15           8 bits
mfp_vector_reg      EQU $FFFA17           8 bits
mfp_timerA_control  EQU $FFFA19           8 bits
mfp_timerB_control  EQU $FFFA1B           8 bits
mfp_timerCD_control EQU $FFFA1D           8 bits
mfp_timerA_data     EQU $FFFA1F           8 bits
mfp_timerB_data     EQU $FFFA21           8 bits
mfp_timerC_data     EQU $FFFA23           8 bits
mfp_timerD_data     EQU $FFFA25           8 bits
mfp_sync_char       EQU $FFFA27           8 bits
mfp_USART_control   EQU $FFFA29           8 bits
mfp_rec_data        EQU $FFFA2B           8 bits
mfp_trans_data      EQU $FFFA2D           8 bits
mfp_USART_data      EQU $FFFA2F

* $FFFC00 Keyboard and MIDI ACIAs

acia_key_control    EQU $FFFC00           8 bits
acia_key_data       EQU $FFFC02           8 bits
acia_MIDI_control   EQU $FFFC04           8 bits
acia_MIDI_data      EQU $FFFC06           8 bits

* End of OSBIND.I
