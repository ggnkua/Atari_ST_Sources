;* atari.i Label und Systemvariablen des Atari
;*
;* $Id: atari.i,v 1.5 1996/02/14 11:35:44 Steffen_Engel Exp Steffen_Engel $
;*
;* $Log: atari.i,v $
;* Revision 1.5  1996/02/14  11:35:44  Steffen_Engel
;* *** empty log message ***
;*
;* Revision 1.4  1996/01/22  22:34:18  S_Engel
;* Revision_4.55
;*
;* Revision 1.3  1995/12/14  16:21:38  S_Engel
;* *** empty log message ***
;*
;* Revision 1.2  1995/11/28  19:11:50  S_Engel
;* Revision 4.50
;*
;# Revision 1.1  1995/03/04  18:10:26  S_Engel
;# Initial revision
;#

; Vektoren

tr1             EQU $84         ; Trap 1
tr2             EQU $88         ; Trap 2

criterr         EQU $0404       ; -> Critical Error Handler
RESMAGIC        EQU $31415926
resvalid        EQU $0426
resvector       EQU $042a
phystop         EQU $042E       ; ende des ST-RAM
flock           EQU $043E       ; _flock
fverify         EQU $0444       ; Verify-Flag
bootdev         EQU $0446       ; Bootdevice
hdv_bpb         EQU $0472       ; BPB-Vektor
hdv_rw          EQU $0476       ; RWABS-Vektor
hdv_media       EQU $047E       ; MEDIACH-Vektor
nflops          EQU $04A6       ; Anzahl der Laufwerke
bufl1           EQU $04B2       ; zwei Zeiger auf BCBs
bufl2           EQU $04B6
hz_200          EQU $04BA       ; 200-Hz-ZÑhler
drvbits         EQU $04C2       ; Laufwerks-Bitmap
dskbufp         EQU $04C6       ; -> TOS-Diskpuffer
sysbase         EQU $04F2       ; Zeiger auf TOS-Header
exec_os         EQU $04FE       ; Zeiger auf AES-Einsprung
punptr          EQU $0516       ; punptr-Zeiger
longframe       EQU $059E
cookiejar       EQU $05a0



; *** Hardwareadressen ***

ttpalette       EQU $FFFF8400   ; Adresse der TT-Farbpalette
snd             EQU $FFFF8800   ; Soundchip
sndwrt          EQU $FFFF8802   ; Schreibfenster


MFP     equ     $FFFFFA01
MFP2    equ     $FFFFFA81

;ierb            EQU $FFFFFA09
;iera2           EQU $FFFFFA07
;gpip2           EQU $FFFFFA81   ; GPIP von MFP 2

; Registeroffsets im MFP
GPIP    equ     $00
AER     equ     $02
DDR     equ     $04
IERA    equ     $06
IERB    equ     $08
IPRA    equ     $0A
IPRB    equ     $0C
ISRA    equ     $0E
ISRB    equ     $10
IMRA    equ     $12
IMRB    equ     $14
VR      equ     $16
TACR    equ     $18
TBCR    equ     $1A
TCDCR   equ     $1C
TADR    equ     $1E
TBDR    equ     $20
TCDR    equ     $22
TDDR    equ     $24
SCR     equ     $26
UCR     equ     $28
RSR     equ     $2A
TSR     equ     $2C
UDR     equ     $2E



; Register ACSI
daccess         EQU $FFFF8604   ; DMA-Fensterregister
dmodus          EQU $FFFF8606   ; DMA-Modusregister
gpip            EQU $FFFFFA01   ; MFP-GPIP
dlow            EQU $FFFF860D   ; DMA-AdreûzÑhler, Lowbyte
dmid            EQU $FFFF860B   ; DMA-AdreûzÑhler, Midbyte
dhigh           EQU $FFFF8609   ; DMA-AdreûzÑhler, Highbyte
dhighhigh       EQU $FFFF8608   ; DMA-AdreûzÑhler, Highestbyte (Medusa)

; Registerdefinitionen fÅr den Falcon:
;
WDC             EQU $FFFF8604;
WDL             EQU $FFFF8606;
WDSR            EQU $FFFF860F;       (* Select Register             *)

bSPSCSI         EQU $00000088;       (* base of SCSI bus            *)

SPODR           EQU bSPSCSI+0;       (* W  Output Data Register        *)
SPCSD           EQU bSPSCSI+0;       (* R  Current SCSI Data           *)
SPICR           EQU bSPSCSI+1;       (* RW Initiator Command Register  *)
SPMR2           EQU bSPSCSI+2;       (* RW Mode Register 2             *)
SPTCR           EQU bSPSCSI+3;       (* RW Target Command Register     *)
SPSER           EQU bSPSCSI+4;       (* W  Select Enable Register      *)
SPCSB           EQU bSPSCSI+4;       (* R  Current SCSI Bus Status     *)
SPBSR           EQU bSPSCSI+5;       (* R  Bus and Status              *)
SPSDS           EQU bSPSCSI+5;       (* W  Start DMA Send              *)
SPSDT           EQU bSPSCSI+6;       (* W  Start DMA Target Receive    *)
SPIDR           EQU bSPSCSI+6;       (* R  Input Data Register         *)
SPSDI           EQU bSPSCSI+7;       (* W  Start DMA Initiator Receive *)
SPRPI           EQU bSPSCSI+7;       (* R  Reset Parity/Interrupts     *)



; Register TT-SCSI
sdmapnt         EQU $FFFF8701   ; SCSI-DMA-Pointer
sdmapntuh       EQU $FFFF8701
sdmapntlh       EQU $FFFF8703
sdmapntul       EQU $FFFF8705
sdmapntll       EQU $FFFF8707
sdmacnt         EQU $FFFF8709   ; SCSI-DMA-BytezÑhler
sdmaresidue     EQU $FFFF8710   ; SCSI-DMA-Datenrest
sdmactrl        EQU $FFFF8715   ; SCSI-DMA-Kontrollregister

NCR     = $FFFF8781
datareg         EQU $FFFF8781   ; Datenregister
icmdreg         EQU $FFFF8783   ; Initiator-Kommandoregister
modereg         EQU $FFFF8785   ; Modusregister
tcmdreg         EQU $FFFF8787   ; Target-Kommandoregister
ctrlreg         EQU $FFFF8789   ; Kontrollregister
statreg         EQU $FFFF878B   ; Statusregister
tdmareg         EQU $FFFF878D   ; Target-DMA-Register
idmareg         EQU $FFFF878F   ; Initiator-DMA-Register

TTODR           EQU  0          ; W  Output Data Register
TTCSD           EQU  0          ; R  Current SCSI Data
TTICR           EQU  2          ; RW Initiator Command Register
TTMR2           EQU  4          ; RW Mode Register 2
TTTCR           EQU  6          ; RW Target Command Register
TTSER           EQU  8          ; W  Select Enable Register
TTCSB           EQU  8          ; R  Current SCSI Bus Status
TTBSR           EQU 10          ; R  Bus and Status
TTSDS           EQU 10          ; W  Start DMA Send
TTSDT           EQU 12          ; W  Start DMA Target Receive
TTIDR           EQU 12          ; R  Input Data Register
TTSDI           EQU 14          ; W  Start DMA Initiator Receive
TTRPI           EQU 14          ; R  Reset Parity/Interrupts

        OFFSET
bpb_recsiz:     ds.w    1
bpb_clsiz:      ds.w    1
bpb_clsizb:     ds.w    1
bpb_rdlen:      ds.w    1
bpb_fsiz:       ds.w    1
bpb_fatrec:     ds.w    1
bpb_datrec:     ds.w    1
bpb_numcl:      ds.w    1
bpb_bflags:     ds.w    1
bpb_len:        ds.w    0

        TEXT
