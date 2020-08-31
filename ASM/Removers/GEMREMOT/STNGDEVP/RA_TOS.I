;----------------------------------------------------------------------------
;File name:	RA_TOS.S		Revision date:	2000.07.02
;Creator:	Ulf Ronald Andersson	Creation date:	1991.01.02
;(c)1991 by:	Ulf Ronald Andersson	All rights reserved
;Released as:	FREEWARE		(NB: commercial sales forbidden!)
;----------------------------------------------------------------------------
;Purpose:	Symbol & Macro library for GEMDOS, XBIOS, and BIOS functions
;----------------------------------------------------------------------------
;	Condition ensures inclusion once per pass only
;
	IFND	RA_TOS_defined
RA_TOS_defined	set	1
;----------------------------------------------------------------------------
	include	RA_SYS.I
	include	RA_ERR.I
	include	RA_STRUC.I
;----------------------------------------------------------------------------
;	Special argument code definitions:
;
__ARG_minus_1	=	$ffdecaff
__ARG_fast_0	=	$ffdeca00
__ARG_plus_1	=	$ffdeca01
__ARG__on_stack	=	$ffdeca02
;
;These are not used in the DEVPAC version, but are needed in the PASM one,
;to implement extended macro argument modes.  They are present here only
;for compatibility reasons, to make future conditionals easy to transfer.
;----------------------------------------------------------------------------
;	The TRAP_def macro is useful to define trap function dispatch codes
;
TRAP_def	MACRO	trapnum,op,argc,pmask,lmask,mnem
trap__\6	=	\1
op__\6		=	\2
ac__\6		=	\3
pm__\6		=	\4
lm__\6		=	\5
		IFNE	(\2<4096)
\6		=	((\1<<24)|(\3<<20)|(\4<<16)|(\5<<12)|\2)
		ELSEIF
\6		=	\2
		ENDC
		ENDM
;----------------------------------------------------------------------------
;	GEMDOS DEFINITIONS
;
	TRAP_def  $1,$00,0,$0,$0,Pterm0
	TRAP_def  $1,$01,0,$0,$0,Cconin
	TRAP_def  $1,$02,1,$0,$0,Cconout
	TRAP_def  $1,$03,0,$0,$0,Cauxin
	TRAP_def  $1,$04,1,$0,$0,Cauxout
	TRAP_def  $1,$05,1,$0,$0,Cprnout
	TRAP_def  $1,$06,1,$0,$0,Crawio
	TRAP_def  $1,$07,0,$0,$0,Crawcin
	TRAP_def  $1,$08,0,$0,$0,Cnecin
	TRAP_def  $1,$09,1,$1,$0,Cconws
	TRAP_def  $1,$0A,1,$1,$0,Cconrs
	TRAP_def  $1,$0B,0,$0,$0,Cconis
;
	TRAP_def  $1,$0E,1,$0,$0,Dsetdrv
;
	TRAP_def  $1,$10,0,$0,$0,Cconos
	TRAP_def  $1,$11,0,$0,$0,Cprnos
	TRAP_def  $1,$12,0,$0,$0,Cauxis
	TRAP_def  $1,$13,0,$0,$0,Cauxos
	TRAP_def  $1,$14,2,$1,$2,Maddalt
	TRAP_def  $1,$15,1,$0,$1,Srealloc	;very new TOS only
	TRAP_def  $1,$16,5,$1B,$4,Slbopen	;\/ MagiC Shared libraries
	TRAP_def  $1,$17,1,$1,$0,Slbclose	;/\ also BetaDOS>3.0 & MetaDOS>2.74
;
	TRAP_def  $1,$19,0,$0,$0,Dgetdrv
	TRAP_def  $1,$1A,1,$1,$0,Fsetdta
;
	TRAP_def  $1,$20,1,$1,$0,Super
;
	TRAP_def  $1,$2A,0,$0,$0,Tgetdate
	TRAP_def  $1,$2B,1,$0,$0,Tsetdate
	TRAP_def  $1,$2C,0,$0,$0,Tgettime
	TRAP_def  $1,$2D,1,$0,$0,Tsettime
;
	TRAP_def  $1,$2F,0,$0,$0,Fgetdta
	TRAP_def  $1,$30,0,$0,$0,Sversion
	TRAP_def  $1,$31,2,$0,$1,Ptermres
;
	TRAP_def  $1,$33,2,$0,$2,Sconfig	;MagiC-only
;
	TRAP_def  $1,$36,2,$1,$0,Dfree
;
	TRAP_def  $1,$39,1,$1,$0,Dcreate
	TRAP_def  $1,$3A,1,$1,$0,Ddelete
	TRAP_def  $1,$3B,1,$1,$0,Dsetpath
	TRAP_def  $1,$3C,2,$1,$0,Fcreate
	TRAP_def  $1,$3D,2,$1,$0,Fopen
	TRAP_def  $1,$3E,1,$0,$0,Fclose
	TRAP_def  $1,$3F,3,$4,$2,Fread
	TRAP_def  $1,$40,3,$4,$2,Fwrite
	TRAP_def  $1,$41,1,$1,$0,Fdelete
	TRAP_def  $1,$42,3,$0,$1,Fseek
	TRAP_def  $1,$43,3,$1,$0,Fattrib
	TRAP_def  $1,$44,2,$0,$1,Mxalloc	;very modern TOS only
	TRAP_def  $1,$45,1,$0,$0,Fdup
	TRAP_def  $1,$46,2,$0,$0,Fforce
	TRAP_def  $1,$47,2,$1,$0,Dgetpath
	TRAP_def  $1,$48,1,$0,$1,Malloc
	TRAP_def  $1,$49,1,$1,$0,Mfree
	TRAP_def  $1,$4A,3,$2,$4,Mshrink
	TRAP_def  $1,$4B,4,$E,$0,Pexec
	TRAP_def  $1,$4C,1,$0,$0,Pterm
;
	TRAP_def  $1,$4E,2,$1,$0,Fsfirst
	TRAP_def  $1,$4F,0,$0,$0,Fsnext
;
	TRAP_def  $1,$56,3,$6,$0,Frename
	TRAP_def  $1,$57,3,$1,$0,Fdatime
;
	TRAP_def  $1,$5C,4,$0,$C,Flock
;
	TRAP_def  $1,$FF,0,$0,$0,Syield		;MiNT CPU yield command
	TRAP_def  $1,256,1,$1,$0,Fpipe
	TRAP_def  $1,260,3,$0,$2,Fcntl
	TRAP_def  $1,261,1,$0,$0,Finstat
	TRAP_def  $1,262,1,$0,$0,Foutstat
	TRAP_def  $1,263,2,$0,$0,Fgetchar
	TRAP_def  $1,264,3,$0,$0,Fputchar
	TRAP_def  $1,265,0,$0,$0,Pwait
	TRAP_def  $1,266,1,$0,$0,Pnice
	TRAP_def  $1,267,0,$0,$0,Pgetpid
	TRAP_def  $1,268,0,$0,$0,Pgetppid
	TRAP_def  $1,269,0,$0,$0,Pgetpgrp
	TRAP_def  $1,270,2,$0,$0,Psetpgrp
	TRAP_def  $1,271,0,$0,$0,Pgetuid
	TRAP_def  $1,272,1,$0,$0,Psetuid
	TRAP_def  $1,273,2,$0,$0,Pkill
	TRAP_def  $1,274,2,$0,$2,Psignal
;NB: although arg 2 above is handled as a long, it is normally an address
	TRAP_def  $1,275,0,$0,$0,Pvfork
	TRAP_def  $1,276,0,$0,$0,Pgetgid
	TRAP_def  $1,277,1,$0,$0,Psetgid
	TRAP_def  $1,278,1,$0,$1,Psigblock
	TRAP_def  $1,279,1,$0,$1,Psigsetmask
	TRAP_def  $1,280,1,$0,$1,Pusrval
	TRAP_def  $1,281,1,$0,$0,Pdomain
	TRAP_def  $1,282,0,$0,$0,Psigreturn
	TRAP_def  $1,283,0,$0,$0,Pfork
	TRAP_def  $1,284,2,$2,$0,Pwait3
	TRAP_def  $1,285,4,$6,$8,Fselect
	TRAP_def  $1,286,1,$0,$1,Prusage
	TRAP_def  $1,287,2,$0,$2,Psetlimit
	TRAP_def  $1,288,1,$0,$1,Talarm
	TRAP_def  $1,289,0,$0,$0,Pause
	TRAP_def  $1,290,1,$0,$0,Sysconf
	TRAP_def  $1,291,0,$0,$0,Psigpending
	TRAP_def  $1,292,2,$1,$0,Dpathconf
	TRAP_def  $1,293,3,$4,$2,Pmsg
	TRAP_def  $1,294,3,$0,$0,Fmidipipe
	TRAP_def  $1,295,2,$0,$0,Prenice
	TRAP_def  $1,296,2,$1,$0,Dopendir
	TRAP_def  $1,297,3,$4,$2,Dreaddir
	TRAP_def  $1,298,1,$0,$1,Drewinddir
	TRAP_def  $1,299,1,$0,$1,Dclosedir
	TRAP_def  $1,300,3,$6,$0,Fxattr
	TRAP_def  $1,301,2,$3,$0,Flink
	TRAP_def  $1,302,2,$3,$0,Fsymlink
	TRAP_def  $1,303,3,$6,$0,Freadlink
	TRAP_def  $1,304,3,$2,$4,Dcntl
	TRAP_def  $1,305,3,$1,$0,Fchown
	TRAP_def  $1,306,2,$1,$0,Fchmod
	TRAP_def  $1,307,1,$0,$0,Pumask
	TRAP_def  $1,308,3,$0,$6,Psemaphore
	TRAP_def  $1,309,2,$0,$0,Dlock
	TRAP_def  $1,310,1,$0,$1,Psigpause
	TRAP_def  $1,311,3,$6,$0,Psigaction
	TRAP_def  $1,312,0,$0,$0,Pgeteuid
	TRAP_def  $1,313,0,$0,$0,Pgetegid
	TRAP_def  $1,314,3,$4,$0,Pwaitpid
	TRAP_def  $1,315,3,$1,$0,Dgetcwd
	TRAP_def  $1,316,1,$1,$0,Salert
;
	TRAP_def  $1,322,5,$1c,$2,Dxreaddir
;
	TRAP_def  $1,325,1,$0,$0,Psetauid
	TRAP_def  $1,326,0,$0,$0,Pgetauid
;
	TRAP_def  $1,329,5,0,$1F,Tsetitimer
;
	TRAP_def  $1,336,0,$0,$0,Ssync
;
	TRAP_def  $1,338,3,$3,$0,Dreadlabel
	TRAP_def  $1,339,2,$3,$0,Dwritelabel
;
;----------------------------------------------------------------------------
;	BIOS DEFINITIONS
;
	TRAP_def  $D,$000,1,$1,$0,Getmpb
	TRAP_def  $D,$001,1,$0,$0,Bconstat
	TRAP_def  $D,$002,1,$0,$0,Bconin
	TRAP_def  $D,$003,2,$0,$0,Bconout
	TRAP_def  $D,$004,5,$2,$0,Rwabs
	TRAP_def  $D,$005,2,$2,$0,Setexc
	TRAP_def  $D,$006,0,$0,$0,Tickal
	TRAP_def  $D,$007,1,$0,$0,Getbpb
	TRAP_def  $D,$008,1,$0,$0,Bcostat
	TRAP_def  $D,$009,1,$0,$0,Mediach
	TRAP_def  $D,$00A,0,$0,$0,Drvmap
	TRAP_def  $D,$00B,1,$0,$0,Kbshift
;
;----------------------------------------------------------------------------
;	XBIOS DEFINITIONS
;
	TRAP_def  $E,$000,3,$6,$0,Initmous
	TRAP_def  $E,$001,2,$0,$0,Ssbrk
	TRAP_def  $E,$002,0,$0,$0,Physbase
	TRAP_def  $E,$003,0,$0,$0,Logbase
	TRAP_def  $E,$004,0,$0,$0,Getrez
	TRAP_def  $E,$005,3,$3,$0,Setscreen
	TRAP_def  $E,$006,1,$1,$0,Setpallete
	TRAP_def  $E,$006,1,$1,$0,Setpalette
	TRAP_def  $E,$007,2,$0,$0,Setcolor
	TRAP_def  $E,$008,7,$1,$2,Floprd
	TRAP_def  $E,$009,7,$1,$2,Flopwr
	TRAP_def  $E,$00A,7,$1,$F,Flopfmt
;; CLR_D0		equ	$E0000B
	TRAP_def  $E,$00C,2,$2,$0,Midiws
	TRAP_def  $E,$00D,2,$2,$0,Mfpint
	TRAP_def  $E,$00E,1,$0,$0,Iorec
	TRAP_def  $E,$00F,6,$0,$0,Rsconf
	TRAP_def  $E,$010,3,$7,$0,Keytbl
	TRAP_def  $E,$011,0,$0,$0,Random
	TRAP_def  $E,$012,4,$1,$2,Protobt
	TRAP_def  $E,$013,7,$1,$2,Flopver
	TRAP_def  $E,$014,0,$0,$0,Scrdmp
	TRAP_def  $E,$015,2,$0,$0,Cursconf
	TRAP_def  $E,$016,1,$0,$1,Settime
	TRAP_def  $E,$017,0,$0,$0,Gettime
	TRAP_def  $E,$018,0,$0,$0,Bioskeys
	TRAP_def  $E,$019,2,$2,$0,Ikbdws
	TRAP_def  $E,$01A,1,$0,$0,Jdisint
	TRAP_def  $E,$01B,1,$0,$0,Jenabint
	TRAP_def  $E,$01C,2,$0,$0,Giaccess
	TRAP_def  $E,$01D,1,$0,$0,Offgibit
	TRAP_def  $E,$01E,1,$0,$0,Ongibit
	TRAP_def  $E,$01F,4,$8,$0,Xbtimer
	TRAP_def  $E,$020,1,$1,$0,Dosound
	TRAP_def  $E,$021,1,$0,$0,Setprt
	TRAP_def  $E,$022,0,$0,$0,Kbdvbase
	TRAP_def  $E,$023,2,$0,$0,Kbrate
	TRAP_def  $E,$024,1,$1,$0,Prtblk
	TRAP_def  $E,$025,0,$0,$0,Vsync
	TRAP_def  $E,$026,1,$1,$0,Supexec
	TRAP_def  $E,$027,0,$0,$0,Puntaes
	TRAP_def  $E,$029,2,$0,$0,Floprate
	TRAP_def  $E,$02A,4,$4,$1,DMAread
	TRAP_def  $E,$02B,4,$4,$1,DMAwrite
	TRAP_def  $E,$02C,1,$0,$0,Bconmap	;???	;-2=>struct  -1=>currdev  0=>test  6=>ST-port  7=>SCC_B  8=>TTMFP  9=>SCC_A
;-------------------------------------
	TRAP_def  $E,$02E,4,$8,$0,NVMaccess
;-------------------------------------
;0 VOID Metainit ( META_INFO_1 *buffer );
;1 LONG Metaopen ( SHORT drive, META_DRVINFO *buffer );
;2 LONG Metaclose ( SHORT drive );
;3 LONG Metaread ( SHORT drive, VOID *buffer, LONG blockno, SHORT count );
;4 LONG Metawrite ( SHORT drive, VOID *buffer, LONG blockno, SHORT count );
;5
;6 LONG Metastatus ( SHORT drive, VOID *buffer );
;7 LONG Metaioctl ( SHORT drive, LONG magic, SHORT opcode, VOID *buffer );
;8
;9
;A
;B LONG Metastartaudio ( SHORT drive, SHORT flag, UBYTE *bytes_p);
;C LONG Metastopaudio ( SHORT drive );
;D LONG Metasetsongtime (SHORT drive,SHORT repeat,LONG starttime,LONG endtime );
;E LONG Metagettoc ( SHORT drive, SHORT flag, CD_TOC_ENTRY *buffer );
;F LONG Metadiscinfo ( SHORT drive, CD_DISC_INFO *p );
;-------------------------------------
	TRAP_def  $E,$030,1,$1,$0,Metainit
	TRAP_def  $E,$031,2,$2,$0,Metaopen
	TRAP_def  $E,$032,1,$0,$0,Metaclose
	TRAP_def  $E,$033,4,$2,$4,Metaread
	TRAP_def  $E,$034,4,$2,$4,Metawrite
;code $35 is unknown
	TRAP_def  $E,$036,2,$2,$0,Metastatus
	TRAP_def  $E,$037,4,$8,$2,Metaioctl
;code $38 is unknown
;code $39 is unknown
;code $3A is unknown
	TRAP_def  $E,$03B,3,$4,$0,Metastartaudio	;use: flag=0  bytes_p[2]={songs,startsong}
	TRAP_def  $E,$03C,1,$0,$0,Metastopaudio
	TRAP_def  $E,$03D,4,$0,$C,Metasetsongtime
	TRAP_def  $E,$03E,3,$4,$0,Metagettoc
	TRAP_def  $E,$03F,2,$2,$0,Metadiscinfo
;-------------------------------------
	struct	META_INFO_1
	uint32	MI1_drivemap
	char_p	MI1_version
	uint32	MI1_reserved
	struc_p	MI1_meta_info_2
	d_end	META_INFO_1
;
	struct	META_INFO_2
	uint16	MI2_version
	uint32	MI2_magic	;'_MET'
	char_p	MI2_log2phys
	d_end	META_INFO_2
;-------------------------------------
	TRAP_def  $E,$040,1,$0,$0,Blitmode	;all late TOS
;-------------------------------------
;	TT030 Video functions
;
	TRAP_def  $E,$050,1,$0,$0,EsetShift	;TT only
	TRAP_def  $E,$051,0,$0,$0,EgetShift	;TT only
	TRAP_def  $E,$052,1,$0,$0,EsetBank	;TT only
	TRAP_def  $E,$053,2,$0,$0,EsetColor	;TT only
	TRAP_def  $E,$054,3,$4,$0,EsetPalette	;TT only
	TRAP_def  $E,$055,3,$4,$0,EgetPalette	;TT only
	TRAP_def  $E,$056,1,$0,$0,EsetGray	;TT only
	TRAP_def  $E,$057,1,$0,$0,EsetSmear	;TT only
;-------------------------------------
;	F030 Video functions
;
	TRAP_def  $E,$058,1,$0,$0,VsetMode	;word(word mode)
	TRAP_def  $E,$059,0,$0,$0,Mon_type	;word(void)  0=SM, 1=SC, 2=VGA, 3=TV
	TRAP_def  $E,$05A,1,$0,$0,VsetSync	;void(word syncmode)
	TRAP_def  $E,$05B,1,$0,$0,VgetSize	;long(word mode)
;
	TRAP_def  $E,$05D,3,$4,$0,VsetRGB		;void(word index,word count,long *array)
	TRAP_def  $E,$05E,3,$4,$0,VgetRGB		;void(word index,word count,long *array)
;
;-------------------------------------
;	DSP functions
;
	TRAP_def  $E,$060,4,$5,$A,Dsp_DoBlock
	TRAP_def  $E,$061,4,$5,$A,Dsp_BlkHandShake
	TRAP_def  $E,$062,4,$5,$A,Dsp_BlkUnpacked	;void(long *TxBf, long TxSz, long *RxBf, long RxSz)
	TRAP_def  $E,$063,4,$9,$6,Dsp_InStream	;void(Dwrd *TxBf, long BkSz, long BkCt, long *OkCt)
	TRAP_def  $E,$064,4,$9,$6,Dsp_OutStream	;void(Dwrd *RxBf, long BkSz, long BkCt, long *OkCt)
	TRAP_def  $E,$065,6,$23,$1C,Dsp_IOStream
	TRAP_def  $E,$066,1,$0,$0,Dsp_RemoveInterrupts	;void(word mask)  bit_0 = Tx_off  bit_1 = Rx_off
	TRAP_def  $E,$067,0,$0,$0,Dsp_GetWordSize	;word(void)  => size in bytes
	TRAP_def  $E,$068,0,$0,$0,Dsp_Lock	;word(void)  => E~OK/E~ERROR
	TRAP_def  $E,$069,0,$0,$0,Dsp_Unlock	;void(void)
	TRAP_def  $E,$06A,2,$3,$0,Dsp_Available	;void(*xinfo, *yinfo)
	TRAP_def  $E,$06B,2,$0,$3,Dsp_Reserve	;word(xsize, ysize)  => E~OK/E~ERROR
	TRAP_def  $E,$06C,3,$5,$0,Dsp_LoadProg	;word(*file, word able, *buffer)  =>E~OK/E~ERROR
	TRAP_def  $E,$06D,3,$1,$2,Dsp_ExecProg	;void(*base, long size, word able)
	TRAP_def  $E,$06E,3,$1,$2,Dsp_ExecBoot	;void(*base, long size, word able)
	TRAP_def  $E,$06F,2,$3,$0,Dsp_LodToBinary	;long(*file, *dest)  => length/negative error
	TRAP_def  $E,$070,1,$0,$0,Dsp_TriggerHC	;void(word vector)  => DSP acts on vector (13/14 normally)
	TRAP_def  $E,$071,0,$0,$0,Dsp_RequestUniqueAbility	;word(void)  => ability code
	TRAP_def  $E,$072,0,$0,$0,Dsp_GetProgAbility	;word(void)  => ability code
	TRAP_def  $E,$073,0,$0,$0,Dsp_FlushSubroutines	;void(void)
	TRAP_def  $E,$074,3,$1,$2,Dsp_LoadSubroutine	;void(*base, long size, word able) => handle/0
	TRAP_def  $E,$075,1,$0,$0,Dsp_InqSubrAbility	;word(word able)  => handle/0
	TRAP_def  $E,$076,1,$0,$0,Dsp_RunSubroutine	;word(word handle)  => E~OK/error_code
	TRAP_def  $E,$077,1,$0,$0,Dsp_Hf0	;word(word flag)  => set/clr/get HSR_3
	TRAP_def  $E,$078,1,$0,$0,Dsp_Hf1	;word(word flag)  => set/clr/get HSR_4
	TRAP_def  $E,$079,0,$0,$0,Dsp_Hf2	;word(void)  => get HCR_3
	TRAP_def  $E,$07A,0,$0,$0,Dsp_Hf3	;word(void)  => get HCR_4
	TRAP_def  $E,$07B,4,$5,$A,Dsp_BlockWords
	TRAP_def  $E,$07C,4,$5,$A,BlkBytes
	TRAP_def  $E,$07D,0,$0,$0,Dsp_HStat	;byte(void)  => get ISR
	TRAP_def  $E,$07E,2,$3,$0,Dsp_SetVectors	;void(*Rx, *Tx)  NULL => no transfer
	TRAP_def  $E,$07F,4,$C,$3,Dsp_MultBlocks
;
;-------------------------------------
;	Sound functions
;
	TRAP_def  $E,$080,0,$0,$0,Snd_LockSnd	;long(void)  => E_OK/E_ERROR		***
	TRAP_def  $E,$081,0,$0,$0,Snd_UnlockSnd	;long(void)  => E_OK/E_ERROR		***
	TRAP_def  $E,$082,2,$0,$0,Snd_SoundCmd	;long(word mode,word data)
	TRAP_def  $E,$083,3,$6,$0,Snd_SetBuffer	;long(word reg,void *beg_p,void *end_p)
	TRAP_def  $E,$084,1,$0,$0,Snd_SetMode	;long(word mode)  0:8b Stereo  1:16b stereo  2:8b mono
	TRAP_def  $E,$085,2,$0,$0,Snd_SetTracks	;long(word playtracks,word rectracks) NB: use tracks-1
	TRAP_def  $E,$086,1,$0,$0,Snd_SetMonTracks	;long(word montrack)
	TRAP_def  $E,$087,2,$0,$0,Snd_SetInterrupt	;long(word how,word when)  0,0 => disable interrupts
	TRAP_def  $E,$088,1,$0,$0,Snd_BufOper	;long(word)
	TRAP_def  $E,$089,2,$0,$0,Snd_Tristate	;long(word dsptx_f,word dsprx_f)
	TRAP_def  $E,$08A,2,$0,$0,Snd_Gpio	;long(word mode,word data)
	TRAP_def  $E,$08B,5,$0,$0,Snd_DevConnect	;long(word src,word dst,word clk,word presc,word pcol)
;		src=  0:DMA_out  1:DSP_out  2:Ext_inp  3:AD_mic
;		dst=  0:DMA_inp  1:DSP_inp  2:Ext_out  3:DA_spk
;		clk=  0:Int_25175_kHz  1:Ext_Clk  2:Int_32000kHz
;		presc=  ((clk_fq/256)/datarate)-1
;		pcol=   0:Handshake  1:none
;
	TRAP_def  $E,$08C,1,$0,$0,Snd_SndStatus	;long(word reset_f)  1 => reset AD & DA
	TRAP_def  $E,$08D,1,$1,$0,Snd_BufPtr	;long(long *destblk)
;
;-------------------------------------
;	more Video functions
;
	TRAP_def  $E,$096,3,$0,$0,VsetMask	;void(word ormask,word andmask,word overlay)
;----------------------------------------------------------------------------
;	standard handles
;
STDIN		= 0
STDOUT		= 1
STDAUX		= 2
STDPRN		= 3
STDHDL4		= 4
STDHDL5		= 5
;----------------------------------------------------------------------------
;	standard file attribute bytes
;	used by Fattrib/Fsfirst
;
FA_RDONLY	=	$01
FA_HIDDEN	=	$02
FA_SYSTEM	=	$04
FA_LABEL	=	$08
FA_VFAT		=	$0F	;special
FA_DIR		=	$10
FA_SUBDIR	=	$10
FA_CHANGED	=	$20
FA_SYMLINK	=	$40	;MagiC only
;
b_FA_RDONLY	=	0
b_FA_HIDDEN	=	1
b_FA_SYSTEM	=	2
b_FA_LABEL	=	3
b_FA_DIR	=	4
b_FA_SUBDIR	=	4
b_FA_CHANGED	=	5
b_FA_SYMLINK	=	6	;MagiC only
;----------------------------------------------------------------------------
;	extended attribute structure
;	used by Fxattr/Dxreaddir
;
	struct	XATTR
	uint16	XATTR_mode		;file mode and access permissions
;bits 12-15:	file types
S_IFMT		=	$F000		;mask to select file type
S_IFCHR		=	$2000		;BIOS special file
S_IFDIR		=	$4000		;directory file
S_IFREG 	=	$8000		;regular file
S_IFIFO 	=	$A000		;FIFO
S_IMEM		=	$C000		;memory region or process
S_IFLNK		=	$E000		;symbolic link
;
;bits 9-11:	setuid, setgid, sticky bit
S_ISUID		=	04000
S_ISGID 	=	02000
S_ISVTX		=	01000

;bits 0-8:	file access modes for user, group, and other
S_IRUSR		=	$100
S_IWUSR 	=	$080
S_IXUSR 	=	$040
S_IRGRP 	=	$020
S_IWGRP		=	$010
S_IXGRP		=	$008
S_IROTH		=	$004
S_IWOTH		=	$002
S_IXOTH		=	$001
DEFAULT_DIRMODE	=	$1FF
DEFAULT_MODE	=	$1B6
	long	XATTR_index		;inode equivalent number
	uint16	XATTR_dev		;device number, 0..31 are normal gemdos devices
	uint16	XATTR_reserved1		;
	uint16	XATTR_nlink		;number of links
	uint16	XATTR_uid		;user id
	uint16	XATTR_gid		;group id
	long	XATTR_size		;file size
	long	XATTR_blksize		;block size
	long	XATTR_nblocks		;used blocks
	int16	XATTR_mtime		;\/ Modification time
	int16	XATTR_mdate		;/\ and date
	int16	XATTR_atime		;\/ Access time
	int16	XATTR_adate		;/\ and date
	int16	XATTR_ctime		;\/ Creation time
	int16	XATTR_cdate		;/\ and date
	int16	XATTR_attr		;standard attribute word
	int16	XATTR_reserved2		;
	char	reserved3,8		;
	d_end	XATTR
;----------------------------------------------------------------------------
;	Boot sector offsets
;
	struct	boot_sector
	d_w	bs_codebra	;$00  w $60xx
	char	bs_filler,6	;$02 6b
	char	bs_serial,3	;$08 3b
	d_ow	bs_sectbytes	;$0b iw
	d_b	bs_clust_sects	;$0d  b
	d_ow	bs_boot_sects	;$0e iw
	d_b	bs_disk_FATs	;$10  b
	d_ow	bs_root_files	;$11 iw
	d_ow	bs_disk_sects	;$13 iw
	d_b	bs_media	;$15  b
	d_w	bs_FAT_sects	;$16 iw
	d_w	bs_track_sects	;$18 iw
	d_w	bs_disk_sides	;$1a iw
	d_w	bs_hide_sects	;$1c iw
; next follows the part used only by executable boots
	d_alias	bs_textbeg	;$1e program
; next follow definitions used only by executable boots of a special kind
	d_w	bs_execflg	;$1e   w
	d_w	bs_ldmode	;$20   w
	d_w	bs_ssect	;$22   w
	d_w	bs_sectcnt	;$24   w
	d_l	bs_ldaddr	;$26   L
	d_l	bs_fatbuf	;$2a   L
	char	bs_fname,11	;$2e 11b
	d_b	bs_fname_end	;$39   b
	char	bs_bootprog,510-bs_bootprog	;$3a .. $1ff
	d_w	bs_checksum	;$1FE  w checksum
	d_end	boot_sector
;
;NB:	A boot sector is considered executable if the 16-bit
;	sum of all 256 words is equal to $1234. The last of
;	those 256 words is therefore used to adjust the sum
;	so as to make a boot sector executable.
;----------------------------------------------------------------------------
;	BPB offsets
;
	struct	bpb_struct
	d_w	bpb_sect_bytes	;typ:  512
	d_w	bpb_clust_sects	;typ:    2
	d_w	bpb_clust_bytes	;typ: 1024
	d_w	bpb_root_sects	;typ:    7
	d_w	bpb_FAT_sects	;typ:    5
	d_w	bpb_FAT2_start	;typ:    6
	d_w	bpb_data_start	;typ:   18 = 2*5 + 7 + 1
	d_w	bpb_data_clusts	;typ:  711 = 720 - 18/2
	d_w	bpb_flag	;b0==16bit_FAT/12bit_FAT typ: 0
	d_alias	bpb_size
	d_end	bpb_struct
;
;NB: data_start = FAT_sects*2 + root_sects + 1  rounded up for clust_sects alignment
;NB: data_clusts= Total_clusts - data_start/clust_sect
;----------------------------------------------------------------------------
;	Directory offsets
;
	struct	dir_struct
	char	dir_fname,8	;first char $00==unused $E5==erased
	char	dir_fext,3
	d_b	dir_fattr
	char	dir_reserved,10
	d_w	dir_ftime	;iw
	d_w	dir_fdate	;iw
	d_w	dir_fcluster	;iw
	d_l	dir_fsize	;il
	d_alias	dir_size
	d_end	dir_struct
;----------------------------------------------------------------------------
;	DTA offsets
;
	struct	dta_struct
	d_alias	dta_reserved	;this contains dta_gname..dta_gattr
	char	dta_gname,12
	d_l	dta_drive
	d_w	dta_dbpos
	d_w	dta_dsec0
	d_b	dta_gattr
	d_b	dta_fattr	;this is the first 'standard' element
	d_w	dta_ftime
	d_w	dta_fdate
	d_l	dta_fsize
	char	dta_fname,14
	d_alias	dta_size
	d_end	dta_struct
;----------------------------------------------------------------------------
;	Program file header offsets
;
	struct	program_header
	d_w	ph_codebra	;always $601A
	d_l	ph_textlen
	d_l	ph_datalen
	d_l	ph_bss_len
	d_l	ph_symblen
	d_l	ph_res1
	d_alias	ph_flag		;only TOS >= 1.4: bit 0 == fastload
	d_l	ph_res2
	d_w	ph_res3
	d_alias	ph_textbeg
	d_alias	ph_size
	d_end	program_header
;----------------------------------------------------------------------------
;	Buffer Control Block offsets
;
	struct	bcb_struct
	d_l	bcb_link_p
	d_w	bcb_drive
	d_w	bcb_type
	d_w	bcb_record
	d_w	bcb_dirty
	d_l	bcb_dm_p
	d_l	bcb_data_p
	d_alias	bcb_size
	d_end	bcb_struct
;----------------------------------------------------------------------------
;	Basepage offsets
;
	struct	BasePage
	d_l	bp_selfbeg_p
	d_l	bp_selfend_p
	d_l	bp_textbeg_p
	d_l	bp_textlen
	d_l	bp_databeg_p
	d_l	bp_datalen
	d_l	bp_bss_beg_p
	d_l	bp_bss_len
	d_l	bp_dta_p
	d_l	bp_parent_p
	d_l	bp_reserved
	d_l	bp_environ_p
	char	bp_undef,80
	d_b	bp_arglen
	char	bp_argstring,127
	d_end	BasePage
;----------------------------------------------------------------------------
;	MiNT SIGNAL DEFINITIONS (some also used under MagiC)
;
SIGNULL		= 0	;Null-Signal (nicht maskierbar)
SIGHUP		= 1	;Hangup
SIGINT		= 2	;ausgelîst durch Control-C
SIGQUIT		= 3	;ausgelîst durch Control-\
SIGILL		= 4	;Illegaler Instruction
SIGTRAP		= 5	;Trace-Trap
SIGABRT		= 6	;Abort (Programmabbruch durch abort)
SIGPRIV		= 7	;Privileg-Verletzung
SIGFPE		= 8	;Division durch Null
SIGKILL		= 9	;Programm sofort beenden (nicht maskierbar)
SIGBUS		= 10	;Bus Error
SIGSEGV		= 11	;UngÅltiger Speicherzugriff
SIGSYS		= 12	;falsches Argument fÅr einen Systemaufruf
SIGPIPE		= 13	;Pipeline-Fehler (broken pipe)
SIGALRM		= 14	;Weck-Signal
SIGTERM		= 15	;Programm beenden (abfangbar)
SIGURG		= 16	;dringende Aktion an einem I/O-Kanal nîtig
SIGSTOP		= 17	;Stop (kein Terminal, nicht maskierbar)
SIGTSTP		= 18	;Stop (Terminal)
SIGCONT		= 19	;gestoppten Prozess fortsetzen (nicht maskb.)
SIGCHLD		= 20	;Child gestoppt oder beendet
SIGTTIN		= 21	;Hintergrund-Prozess mîchte lesen
SIGTTOU		= 22	;Hintergrund-Prozess mîchte schreiben
SIGIO		= 23	;I/O an einem Deskriptor mîglich
SIGXCPU		= 24	;CPU-Zeit Åberschritten
SIGXFSZ		= 25	;maximale Dateigrîûe Åberschritten
SIGVTALRM	= 26	;Alarm eines virtuellen Timers
SIGPROF		= 27	;ausgelîst durch Timing eines Profilers
SIGWINCH	= 28	;(Text-)Fenstergrîûe wurde verÑndert
SIGUSR1		= 29	;vom Benutzer frei definierbar
SIGUSR2		= 30	;vom Benutzer frei definierbar
;----------------------------------------------------------------------------
;	MACRO DEFINITIONS
;
gemdos	MACRO	op,v2,v3,v4,v5,v6,v7
	TOS__args.\0	\1,<\2>,<\3>,<\4>,<\5>,<\6>,<\7>
	trap	#TOS__TR
	ifne	TOS__OP-(Pterm0&$ff)
	ifne	TOS__OP-(Pterm&$ff)
	ifne	TOS__OP-(Ptermres&$ff)
	ifne	(TOS__AS>0)&(TOS__STkeep=0)
	ifne	(TOS__AS>8)|TOS_DUMBcomp
	lea	TOS__AS(sp),sp
	elseif
	addq	#TOS__AS,sp
	endc
	endc
	endc
	endc
	endc
	ENDM	;gemdos
;------------------------------------
sub_gemdos	MACRO	op,v2,v3,v4,v5,v6,v7
	TOS__args.\0	\1,<\2>,<\3>,<\4>,<\5>,<\6>,<\7>
	bsr	gemdos_sub
	ifne	TOS__OP-(Pterm0&$ff)
	ifne	TOS__OP-(Pterm&$ff)
	ifne	TOS__OP-(Ptermres&$ff)
	ifne	(TOS__AS>0)&(TOS__STkeep=0)
	ifne	(TOS__AS>8)|TOS_DUMBcomp
	lea	TOS__AS(sp),sp
	elseif
	addq	#TOS__AS,sp
	endc
	endc
	endc
	endc
	endc
	ENDM	;sub_gemdos
;------------------------------------
bios	MACRO	op,v2,v3,v4,v5,v6
	TOS__args.\0	\1,<\2>,<\3>,<\4>,<\5>,<\6>
	trap	#TOS__TR
	ifne	(TOS__AS>0)&(TOS__STkeep=0)
	ifne	(TOS__AS>8)|TOS_DUMBcomp
	lea	TOS__AS(sp),sp
	elseif
	addq	#TOS__AS,sp
	endc
	endc
	ENDM	;bios
;------------------------------------
sub_bios	MACRO	op,v2,v3,v4,v5,v6
	TOS__args.\0	\1,<\2>,<\3>,<\4>,<\5>,<\6>
	bsr	bios_sub
	ifne	(TOS__AS>0)&(TOS__STkeep=0)
	ifne	(TOS__AS>8)|TOS_DUMBcomp
	lea	TOS__AS(sp),sp
	elseif
	addq	#TOS__AS,sp
	endc
	endc
	ENDM	;sub_bios
;------------------------------------
xbios	MACRO	op,v2,v3,v4,v5,v6,v7,v8,v9,v10
	TOS__args.\0	\1,<\2>,<\3>,<\4>,<\5>,<\6>,<\7>,<\8>,<\9>,<\a>
	trap	#TOS__TR
	ifne	(TOS__AS>0)&(TOS__STkeep=0)
	ifne	(TOS__AS>8)|TOS_DUMBcomp
	lea	TOS__AS(sp),sp
	elseif
	addq	#TOS__AS,sp
	endc
	endc
	ENDM	;xbios
;------------------------------------
sub_xbios	MACRO	op,v2,v3,v4,v5,v6,v7,v8,v9,v10
	TOS__args.\0	\1,<\2>,<\3>,<\4>,<\5>,<\6>,<\7>,<\8>,<\9>,<\a>
	bsr	xbios_sub
	ifne	(TOS__AS>0)&(TOS__STkeep=0)
	ifne	(TOS__AS>8)|TOS_DUMBcomp
	lea	TOS__AS(sp),sp
	elseif
	addq	#TOS__AS,sp
	endc
	endc
	ENDM	;sub_xbios
;------------------------------------
TOS__args	MACRO	op,v2,v3,v4,v5,v6,v7,v8,v9,v10
TOS__IF	set	(\1)&_ind
	IFC	'i','\0'
TOS__IF	set	_ind
	ELSEIF
	IFC	'I','\0'
TOS__IF	set	_ind
	ENDC
	ENDC
TOS__TR	set	(trap__\1&~_ind)
TOS__AC	set	(ac__\1&~_ind)
TOS__PF	set	(pm__\1&~_ind)
TOS__LF	set	(lm__\1&~_ind)
TOS__OP	set	(op__\1&~_ind)
TOS__AS	set	-TOS__SToffs
	IFNE	TOS__AC>0
	IFNE	TOS__AC>1
	IFNE	TOS__AC>2
	IFNE	TOS__AC>3
	IFNE	TOS__AC>4
	IFNE	TOS__AC>5
	IFNE	TOS__AC>6
	IFNE	TOS__AC>7
	IFNE	TOS__AC>8
	IFNE	TOS__LF=15
TOS__LF	set	130
	ENDC
	TOS__arg	8,<\a>,\1
	elseif
	ifnc	'','\a'
	fail	More than 8 args in '\1 \2,\3,\4,\5,\6,\7,\8,\9,\a'
	endc
	ENDC
	TOS__arg	7,<\9>,\1
	elseif
	ifnc	'','\9'
	fail	More than 7 args in '\1 \2,\3,\4,\5,\6,\7,\8,\9'
	endc
	ENDC
	TOS__arg	6,<\8>,\1
	elseif
	ifnc	'','\8'
	fail	More than 6 args in '\1 \2,\3,\4,\5,\6,\7,\8'
	endc
	ENDC
	TOS__arg	5,<\7>,\1
	elseif
	ifnc	'','\7'
	fail	More than 5 args in '\1 \2,\3,\4,\5,\6,\7'
	endc
	ENDC
	TOS__arg	4,<\6>,\1
	elseif
	ifnc	'','\6'
	fail	More than 4 args in '\1 \2,\3,\4,\5,\6'
	endc
	ENDC
	TOS__arg	3,<\5>,\1
	elseif
	ifnc	'','\5'
	fail	More than 3 args in '\1 \2,\3,\4,\5'
	endc
	ENDC
	TOS__arg	2,<\4>,\1
	elseif
	ifnc	'','\4'
	fail	More than 2 args in '\1 \2,\3,\4'
	endc
	ENDC
	TOS__arg	1,<\3>,\1
	elseif
	ifnc	'','\3'
	fail	More than 1 arg in '\1 \2,\3'
	endc
	ENDC
	TOS__arg	0,<\2>,\1
	elseif
	ifnc	'','\2'
	fail	More than 0 args in '\1 \2'
	endc
	ENDC
TOS__AS	set	TOS__AS+2
	IF	1&TOS__AS		
	FAIL	Stack offset is odd in \1
	ENDIF
	ifgt	TOS__AS
	MOVE	#TOS__OP,-(sp)
	elseif
	ifeq	TOS__AS
	move	#TOS__OP,(sp)
	elseif
	FAIL	Stack offset is too large in \1
	endc
	endc
	ENDM	;TOS__args
;------------------------------------
;This macro handles all argument checking for bios, xbios & gemdos functions
;special argument cases are:
;no argument = FAIL error
;'()'	= Assumes argument is on stack already
;'!'	= Places 0 on stack using "clr"
;'?'	= Places -1 on stack
TOS__arg	MACRO	v1,v2,op
TOS__AS	set	TOS__AS+2
	IFNE	(1<<\1)&(TOS__PF|TOS__LF)
TOS__AS	set	TOS__AS+2
	ENDC
	ifne	1&TOS__AS
	FAIL	Stack offset is odd for arg \1 in \3 call
	endc
	IFC	'','\2'
	FAIL	Missing operand \1 in \3 call
	MEXIT
	ENDC
	IFC	'()','\2'
	MEXIT
	ENDC
	ifgt	TOS__AS
	IFNE	(1<<\1)&TOS__PF
	iflt	TOS__AS-4
	FAIL	Ptr arg \1 crosses stack offset in \3 call
	endc
	IFC	'!','\2'
	clr.l	-(sp)
	MEXIT
	ENDC
	IFC	'?','\2'
	pea	(-1).w
	MEXIT
	ENDC
	IFC	'!1','\2'
	pea	(1).w
	MEXIT
	ENDC
	IFEQ	TOS__IF
	pea	\2
	MEXIT
	ENDC
	move.l	\2,-(sp)
	MEXIT
	ENDC			;ends pointer case
	IFNE	(1<<\1)&TOS__LF
	iflt	TOS__AS-4
	FAIL	Long arg \1 crosses stack offset in \3 call
	endc
	IFC	'!','\2'
	clr.l	-(sp)
	MEXIT
	ENDC
	IFC	'?','\2'
	pea	(-1).w
	MEXIT
	ENDC
	IFC	'!1','\2'
	pea	(1).w
	MEXIT
	ENDC
	move.l	\2,-(sp)
	MEXIT
	ENDC			;ends long case
	IFC	'!','\2'
	clr	-(sp)
	MEXIT
	ENDC
	IFC	'?','\2'
	move	#-1,-(sp)
	MEXIT
	ENDC
	IFC	'!1','\2'
	move	#1,-(sp)
	MEXIT
	ENDC
	move	\2,-(sp)	;ends word case
	MEXIT
	elseif		;start stack offset cases	
	ifeq	TOS__AS
	IFNE	(1<<\1)&TOS__PF
	IFC	'!','\2'
	clr.l	(sp)
	MEXIT
	ENDC
	IFC	'?','\2'
	move.l	#-1,(sp)
	MEXIT
	ENDC
	IFC	'!1','\2'
	move.l	#1,(sp)
	MEXIT
	ENDC
	IFEQ	TOS__IF
	addq	#4,sp
	pea	\2
	MEXIT
	ENDC
	move.l	\2,(sp)
	MEXIT
	ENDC			;ends pointer case
	IFNE	(1<<\1)&TOS__LF
	IFC	'!','\2'
	clr.l	(sp)
	MEXIT
	ENDC
	IFC	'?','\2'
	move.l	#-1,(sp)
	MEXIT
	ENDC
	IFC	'!1','\2'
	move.l	#1,(sp)
	MEXIT
	ENDC
	move.l	\2,(sp)
	MEXIT
	ENDC			;ends long case
	IFC	'!','\2'
	clr	(sp)
	MEXIT
	ENDC
	IFC	'?','\2'
	move	#-1,(sp)
	MEXIT
	ENDC
	IFC	'!1','\2'
	move	#1,(sp)
	MEXIT
	ENDC
	move	\2,(sp)	;ends word case
	MEXIT
	elseif		;handle negative offset levels
	IFNE	(1<<\1)&TOS__PF
	IFC	'!','\2'
	clr.l	-TOS__AS(sp)
	MEXIT
	ENDC
	IFC	'?','\2'
	move.l	#-1,-TOS__AS(sp)
	MEXIT
	ENDC
	IFC	'!1','\2'
	move.l	#1,-TOS__AS(sp)
	MEXIT
	ENDC
	IFEQ	TOS__IF
	move.l	#\2,-TOS__AS(sp)
	MEXIT
	ENDC
	move.l	\2,-TOS__AS(sp)
	MEXIT
	ENDC			;ends pointer case
	IFNE	(1<<\1)&TOS__LF
	IFC	'!','\2'
	clr.l	-TOS__AS(sp)
	MEXIT
	ENDC
	IFC	'?','\2'
	move.l	#-1,-TOS__AS(sp)
	MEXIT
	ENDC
	IFC	'!1','\2'
	move.l	#1,-TOS__AS(sp)
	MEXIT
	ENDC
	move.l	\2,-TOS__AS(sp)
	MEXIT
	ENDC			;ends long case
	IFC	'!','\2'
	clr	-TOS__AS(sp)
	MEXIT
	ENDC
	IFC	'?','\2'
	move	#-1,-TOS__AS(sp)
	MEXIT
	ENDC
	IFC	'!1','\2'
	move	#1,-TOS__AS(sp)
	MEXIT
	ENDC
	move	\2,-TOS__AS(sp)	;ends word case
	MEXIT
	endc
	endc
	ENDM	;TOS__arg
;------------------------------------
TOS__AS		set	0
TOS__SToffs	set	0
TOS__STkeep	set	0
TOS_DUMBcomp	set	0
;----------------------------------------------------------------------------
	ENDC	;RA_TOS_defined
;----------------------------------------------------------------------------
;End of file:	RA_TOS.S
;----------------------------------------------------------------------------
