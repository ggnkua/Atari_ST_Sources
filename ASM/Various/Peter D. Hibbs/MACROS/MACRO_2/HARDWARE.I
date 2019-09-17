* Hardware Addresses *
**********************

;
; Documented system variables and port addresses
;

; MEMORY and SHIFTER:

memconf      = $ffff8001                    ; Memory configuration
dbaseh       = $ffff8201                    ; High byte of screen address
dbasel       = $ffff8203                    ; Mid byte of screen address
vcounthi     = $ffff8205                    ; High byte of video address counter
vcountmid    = $ffff8207                    ; Midbyte         -"-
vcountlow    = $ffff8209                    ; Lowbyte         -"-
syncmode     = $ffff820a                    ; Synchronisation mode
color0       = $ffff8240                    ; Shifter- colour register 0-15
color1       = $ffff8242
color2       = $ffff8244
color3       = $ffff8246
color4       = $ffff8248
color5       = $ffff824a
color6       = $ffff824c
color7       = $ffff824e
color8       = $ffff8250
color9       = $ffff8252
color10      = $ffff8254
color11      = $ffff8256
color12      = $ffff8258
color13      = $ffff825a
color14      = $ffff825c
color15      = $ffff825e
shiftmd      = $ffff8260                    ; Picture resolution

; DMA and DISK:

diskctrl     = $ffff8604                    ; Disk controller register selection
DMAmode      = $ffff8606                    ; DMA-Status/-Mode
DMAhigh      = $ffff8609                    ; DMA Base and counter: high
DMAmid       = $ffff860b                    ;         -"-         : mid
DMAlow       = $ffff860d                    ;         -"-         : low

; 1770-REGISTER:

cmdreg       = $80     ; 1770/FIFO command register selection
trackreg     = $82     ; 1770/FIFO track register selection
sectorreg    = $84     ; 1770/FIFO sector register selection
datareg      = $86     ; 1770/FIFO data register selection

; SOUND CHIP:

PSGselect    = $ffff8800                    ; (W) register selection
PSGread      = $ffff8800                    ; (R) read data
PSGwrite     = $ffff8802                    ; (W) write data
PSGtoneAf    = 0       ; Channel A: fine adjustment
PSGtoneAc    = 1       ;  -"-    A: rough adjustment
PSGtoneBf    = 2       ; Channel B
PSGtoneBc    = 3
PSGtoneCf    = 4       ; Channel C
PSGtoneCc    = 5
PSGnoise     = 6       ; Noise generator
PSGmixer     = 7       ; I/O-control, mixer
PSGampA      = 8       ; Channel A, B, C: amplitude
PSGampB      = 9
PSGampC      = $a
PSGenvlpf    = $b      ; Envelope curve : fine adjustment
PSGenvlpc    = $c      ;        -"-     : rough adjustment
PSGportA     = $e      ; PORT A (output only)
PSGportB     = $f      ; PORT B (Centronics-output)

; Bits in "PSGportA":

RTSout       = 8       ; RTS output
DTRout       = $10     ; DTR output
STROBE       = $20     ; Centronics strobe output
             .OUT      ;= $40     ; "general purpose" output

; DMA - Sound:	stf 47
DMAcontrol	= $ffff8900	; 0 set to start
				; 1 set to repeat-play
DMAstart_high	= $ffff8902	; high address byte
DMAstart_mid	= $ffff8904	; middle address byte
DMAstart_low	= $ffff8906	; low address byte
DMAcount_high	= $ffff8908	; high counter byte
DMAcount_mid	= $ffff890a	; middle counter byte
DMAcount_low	= $ffff890c	; low counter byte
DMAend_high	= $ffff890e	; high address byte
DMAend_mid	= $ffff8910	; middle address byte
DMAend_low	= $ffff8912	; low address byte
DMAsound_mode	= $ffff8920	;   7 set for mono/clear for stereo
				; 0-1 	00= 6.258KHz
				;	01=12.517KHz
				;	10=25.033KHz
				;	11=50.066KHz

; Blitter:	stf 47

BLITram_0	= $ffff8a00	; 16 Half-Tone Ram Registers (1 word each)
BLITram_1	= $ffff8a02	; used for special effects
BLITram_2	= $ffff8a04
BLITram_3	= $ffff8a06
BLITram_4	= $ffff8a08
BLITram_5	= $ffff8a0a
BLITram_6	= $ffff8a0c
BLITram_7	= $ffff8a0e
BLITram_8	= $ffff8a10
BLITram_9	= $ffff8a12
BLITram_A	= $ffff8a14
BLITram_B	= $ffff8a16
BLITram_C	= $ffff8a18
BLITram_D	= $ffff8a1a
BLITram_E	= $ffff8a1c
BLITram_F	= $ffff8a1e
BLITsrce_x_inc	= $ffff8a20	; number of bytes to next source word (8 or 2)
BLITsrce_y_inc	= $ffff8a22	; number of bytes from end of one line to start of next
BLITsrce_addr	= $ffff8a24
BLITleft_mask	= $ffff8a28	; $ffff right shifted by skew
BLITmiddle_mask	= $ffff8a2a	; $ffff
BLITright_mask	= $ffff8a2c	; $ffff NOT (left mask)
				; to ensure backgrounds not overdrawn 
				; beyond edge of sprite
BLITdest_x_inc	= $ffff8a2e	; as src_inc
BLITdest_y_inc	= $ffff8a30
BLITdest_addr	= $ffff8a32
BLITdest_width	= $ffff8a36	; sprite width in words + 1 (for overlap) or 
				; sprite width in words *4 for word-aligned colour
BLITdest_height	= $ffff8a38	; sprite height in pixels	
BLIThalftone_op	= $ffff8a3a
BLITlogical_op	= $ffff8a3b	; as in VRO_CPYFM
BLITflag1	= $ffff8a3c	; 0-3 line number
				;   4
				;   5 smudge
				;   6 hog - set before use
				;   7 busy - set to start
BLITflag2	= $ffff8a3d	; 0-3 skew - bits past last word boundary
				; 4-5
				;   6 NFSR
				;   7 FXSR

; 68901 (MFP):

MFP          = $fffffa00                    ; Register-Base
MFPgpio      = $fffffa00+1                  ; I/O
MFPaer       = $fffffa00+3                  ; active edge
MFPddr       = $fffffa00+5                  ; Data direction
MFPiera      = $fffffa00+7                  ; interrupt enable A
MFPierb      = $fffffa00+9                  ;       -"-        B
MFPipra      = $fffffa00+$b                 ; interrupt pending A
MFPiprb      = $fffffa00+$d                 ;       -"-         B
MFPisra      = $fffffa00+$f                 ; interrupt inService A
MFPisrb      = $fffffa00+$11                ;       -"-           B
MFPimra      = $fffffa00+$13                ; interrupt mask A
MFPimrb      = $fffffa00+$15                ;       -"-      B
MFPvr        = $fffffa00+$17                ; Vector-Register
MFPtacr      = $fffffa00+$19                ; timer A control
MFPtbcr      = $fffffa00+$1b                ; timer B control
MFPtcdcr     = $fffffa00+$1d                ; timer C & D control
MFPtadr      = $fffffa00+$1f                ; timer A data
MFPtbdr      = $fffffa00+$21                ; timer B data
MFPtcdr      = $fffffa00+$23                ; timer C data
MFPtddr      = $fffffa00+$25                ; timer D data
MFPscr       = $fffffa00+$27                ; sync char
MFPucr       = $fffffa00+$29                ; USART control reg
MFPrsr       = $fffffa00+$2b                ; receiver status
MFPtsr       = $fffffa00+$2d                ; transmit status
MFPudr       = $fffffa00+$2f                ; USART data

; ACIA's 6850:

ACIAkeyctrl  = $fffffc00                    ; keyboard ACIA control
ACIAkeydr    = $fffffc02                    ; keyboard data
ACIAmidicr   = $fffffc04                    ; MIDI ACIA control
ACIAmididr   = $fffffc06                    ; MIDI data

; Documented bios variables

etv_timer    = $400
etv_critic   = $404
etv_term     = $408
etv_xtra     = $40c
memvalid     = $420
memcntlr     = $424
resvalid     = $426
resvector    = $42a
phystop      = $42e
_membot      = $432
_memtop      = $436
memval2      = $43a
flock        = $43e
seekrate     = $440
_timr_ms     = $442
_fverify     = $444
_bootdev     = $446
palmode      = $448
defshiftmd   = $44a
sshiftmd     = $44c
_v_bas_ad    = $44e
vblsem       = $452
nvbls        = $454
_vblqueue    = $456
colorptr     = $45a
screenpt     = $45e
_vbclock     = $462
_frclock     = $466
hdv_init     = $46a
swv_vec      = $46e
hdv_bpb      = $472
hdv_rw       = $476
hdv_boot     = $47a
hdv_mediach  = $47e
_cmdload     = $482
conterm      = $484
trp14ret     = $486
criticret    = $48a
themd        = $48e
_____md      = $49e
savptr       = $4a2
_nflops      = $4a6
con_state    = $4a8
save_row     = $4ac
sav_context  = $4ae
_bufl        = $4b2
_hz_200      = $4ba
_drvbits     = $4c2
_dskbufp     = $4c6
_autopath    = $4ca
_vbl_list    = $4ce
_dumpflg     = $4ee
_prtabt      = $4f0
_sysbase     = $4f2
_shell_p     = $4f6
end_os       = $4fa
exec_os      = $4fe
scr_dump     = $502
prv_lsto     = $506
prv_lst      = $50a
prv_auxo     = $50e
prv_aux      = $512

; Device numbers

PRT          = 0       ; Printer
AUX          = 1       ; RS-232
CON          = 2       ; Screen (vt-52 Emulator)
MIDI         = 3       ; MIDI
IKBD         = 4       ; Keyboard
RAWCON       = 5       ; Screen (raw ASCII-chars from 0 to 255)
             .END 

