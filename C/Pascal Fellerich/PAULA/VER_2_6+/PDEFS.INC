*************************************************************************
*
*  PDEFS.INC
*  ---------
*
*  Include File for Assembler Parts
*
*
*
*  last modified: 5-Aug-1992
*
*************************************************************************

FSTACK          equ 128                 ; 128 longs fÅr IrqRoutine

FREQTABSIZE     equ 1024                ; maximale Periode beim Amigachip

MAXFRAMESIZE    equ 4192 ;2048          ; grîûte FrameSize (25Hz/50KHz)
                                        ; -> 50 KHz Fsample & 10 Hz Fframe

OVERTICKS       equ 30                  ;Overload: wie lange anhalten?
OVERTRIGGER     equ 15

TOGGLEVOLUME    equ 60                  ;ab wann volumes ignoriert werden (inclusive)
VOLBITS         equ 6                   ; 2^6 = 64

FULLBLOWN_INTERPOLATION equ 1           ;wenn IMMER interpoliert werden soll!!!!

; Default-Taktfrequenz des Amiga-Systems in Hz:
;AMIGACLOCK     equ 7093790    ;PAL! ('Standard'-Stimmung)
AMIGACLOCK      equ 7159090             ;NTSC! (KORREKTE Stimmung)


;
; Errorcodes:
;
E_OK            equ 0
E_ERROR         equ -1
E_MODFILE       equ -2		;corrupted/no modfile
E_FILENOTFOUND  equ -3		;file not found (logical error)
E_MEMORY        equ -4		;no memory
E_FRAMEBUFFER   equ -5		;no mem for frame buffers
E_DMASOUND      equ -6		;no dma sound hardware
E_INFOFILE		equ -7		;error in infofile
E_PHYSDRIVE		equ -8		;physical drive error


TRUE			equ 1
FALSE			equ 0


;
; States des Players
;
P_IDLE          equ 0                   ;inactive, no file loaded
P_STOPPED       equ 1                   ;file loaded, ready to play
P_PLAYING       equ 2                   ;playing.
P_PAUSED        equ 3                   ;paused, ready to resume playing
P_INTERRUPTED   equ 4                   ;interrupted by internal processes
P_HISTATE       equ 4                   ;highest state number

;
; States des Paula-Chip-Emulators:
;
STOPPED			equ -1
RELOAD			equ 0

;
; vom Soundchip abgespielter Bereich: nur der muû im ST-RAM liegen.
; die beiden Puffer (grîûte Ausdehnung!)
; -> WORDS weil pro Kanal ein Byte benutzt wird.
;
                offset 0
buffer1:        ds.w MAXFRAMESIZE
buffer2:        ds.w MAXFRAMESIZE
BUFFERSIZE:     ds 1


;
; Instrumenteneintrag im SONGfile bzw. MODfile
;
                offset 0
INS_NAME:       ds.b 22                 ;Name des Instruments (Samples)
INS_SLEN:       ds.w 1                  ;WortlÑnge des Samples (-> *2 fÅr BytelÑnge)
INS_SVOLUME:    ds.w 1                  ;Default Volume des Samples
INS_REP:        ds.w 1                  ;Repeat-Additive in WORDS
INS_REPLEN:     ds.w 1                  ;repeatlen       in WORDS
Sizeof_INS:     ds   1

*
* öbergabe-Struktur fÅr die Soundchipemulation:
*
* Soundregister sind:
                offset 0
;-- Original Amiga Registers
AUD_START:      ds.l 1                  ;Samplestart-Address
AUD_LEN:        ds.w 1                  ;Samplelength in words
AUD_PER:        ds.w 1                  ;Sampleperiod
AUD_VOL:        ds.w 1                  ;Samplevolume 0..64
;-- Additional Emulator Registers
AUD_LLEN:       ds.w 1
AUD_LSTART:     ds.l 1
;-- internally used variables
AUD_END:        ds.l 1                  ;Ptr to End of sample
AUD_STATE:      ds.w 1                  ;State machine! -> write 0 to reload regs
AUD_OFFSET:     ds.w 1                  ;negative reload offset
AUD_INT:        ds.w 1                  ;work: negative sample offset
AUD_FRAC:       ds.w 1                  ;work: fractional part
Sizeof_AUD:     ds   1



*
* öbergabe-Struktur fÅr SOFTDMA!
*
*
				offset 0
SDMA_magic:		ds.l 1					;'CLPF' oder so
SDMA_SETFRAME:	ds.l 1
SDMA_INIT:		ds.l 1
SDMA_EXIT:		ds.l 1
SDMA_CPULOAD:	ds.l 1
SDMA_SF0:		ds.w 1					;die 4 samplefreqs
SDMA_SF1:		ds.w 1
SDMA_SF2:		ds.w 1
SDMA_SF3:		ds.w 1
SDMA_HOOK:		ds.l 1					;paula addr reinschreiben
SDMA_BOOST:		ds.w 1					;Booster ?
SDMA_SFSTR0:	ds.l 1
SDMA_SFSTR1:	ds.l 1
SDMA_SFSTR2:	ds.l 1
SDMA_SFSTR3:	ds.l 1
sizeof_SDMA:	ds   1




; GEMDOS DEFS:
Malloc          equ 72
Mxalloc         equ 68
Mfree           equ 73
Mshrink			equ 74
Fopen           equ 61
Fclose          equ 62
Fread           equ 63
Fseek           equ 66

; XBIOS Defs
Supexec         equ 38

; system variables:
_sysbase        equ $4f2
_p_cookies      equ $05A0
gpip            equ $FFFFFA01  ;general purpose I/O
aer             equ $FFFFFA03  ;active edge reg
ddr             equ $FFFFFA05  ;data direction reg

*************************************************************************
