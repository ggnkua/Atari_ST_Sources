* EXCEPTION VEKTORS

vec_reset	= $0
reset_pc	= $4
vec_buserr	= $8
vec_adrerr	= $c
vec_illegal	= $10
vec_div0	= $14
vec_chk		= $18
vec_trapv	= $1c
vec_privilege	= $20
vec_trace	= $24
vec_linea	= $28
vec_linef	= $2c
vec_unini	= $3c
vec_spurious	= $60
vec_level1	= $64

vec_HBI		= $68		;Hblank
vec_level2	= vec_HBI
vec_level3	= $6c
vec_VBI		= $70		;Vblank
vec_level4	= vec_VBI
vec_SCC		= $74
vec_level5	= vec_SCC
vec_MFP		= $78		;MFP interrupts
vec_level6	= vec_MFP
vec_level7	= $7c		;Non Maskable Interrupts
vec_trap0	= $80
vec_trap1	= $84		;GEMDOS
vec_trap2	= $88		;AES/VDI
vec_trap3	= $8c
vec_trap4	= $90
vec_trap5	= $94
vec_trap6	= $98
vec_trap7	= $9c
vec_trap8	= $a0
vec_trap9	= $a4
vec_trap10	= $a8
vec_trap11	= $ac
vec_trap12	= $b0
vec_trap13	= $b4		;BIOS
vec_trap14	= $b8		;XBIOS
vec_trap15	= $bc

*********	ST MFP INTERRUPT VECTORS
mfp_b0vect	= $100	;MFP I/O port bit 0, bit 0 in IERB. Centronics busy interrpupt vector
vec_centbusy	= mfp_b0vect

mfp_b1vect	= $104	;MFP I/O port bit 1, bit 1 in IERB. RS232 Carrier Detect vector (Falcon030, parallel acknowledge)
vec_rs232_cd	= mfp_b1vect

mfp_b2vect	= $108	;MFP I/O port bit 2, bit 2 in IERB. RS232 CTS (Not used on Falcon030)
vec_rs232_cts	= mfp_b2vect

mfp_b3vect	= $10c	;MFP I/O port bit 3. bit 3 in IERB. Blitter operation complete interrupt vector
vec_blitterdone	= mfp_b3vect

mfp_b4vect	= $110	;	     Bit 4 in IERB. Timer D interrupt vector (RS232 baud rate generator, not used in Falcon030)
vec_timer_d	= mfp_b4vect

mfp_b5vect	= $114	;	     Bit 5 in IERB. Timer C interrupt vector (200Hz system clock)
vec_timer_c	= mfp_b5vect

mfp_b6vect	= $118	;MFP I/O port bit 4, bit 6 in IERB. Keyboard and Midi Acia interrup vector
vec_acia	= mfp_b6vect

mfp_b7vect	= $11c	;MFP I/O port bit 5, bit 7 in IERB. ASCI DMA and Floppy disk controller interrupt
vec_hdcontroller= mfp_b7vect

mfp_a0vect	= $120	;	     bit 0 in IERA. Timer B (Horizontal blank counter)
vec_timer_b	= mfp_a0vect
vec_hbl		= mfp_a0vect

mfp_a1vect	= $124	;	     bit 1 in IERA. RS232 transmit error interrupt vector (not used in Falcon030)
vec_rs232_te	= mfp_a1vect

mfp_a2vect	= $128	;	     bit 2 in IERA. RS232 transmit buffer error interrupt vector (not used in Falcon030)
vec_rs232_tbe	= mfp_a2vect

mfp_a3vect	= $12c	;	     bit 3 in IERA. RS232 receive error interrupt (not used in Falcon030)
vec_rs232_re	= mfp_a3vect

mfp_a4vect	= $130	;	     bit 4 in IERA. RS232 Reveive buffer full interrupt (not used in Falcon030)
vec_rs232_rbf	= mfp_a4vect
	
mfp_a5vect	= $134	;	     bit 5 in IERA. Timer A (DMA sound complete)
vec_timer_a	= mfp_a5vect

mfp_a6vect	= $138	;MFP I/O port bit 6, bit 6 in IERA. RS232 ring indicator
vec_rs232_ri	= mfp_a6vect

mfp_a7vect	= $13c	;MFP I/O port bit 7, bit 7 in IERA. Monochrome monitor detect
vec_monodetect	= mfp_a7vect

*********	TT MFP INTERRUPT VECTORS
mfptt_b0vect	= $140	;Genral purpose I/O pin interrupt vector
mfptt_b1vect	= $144	;Genral purpose I/O pin interrupt vector
mfptt_b2vect	= $148	;SCC DMAC interrupt vector
mfptt_b3vect	= $14c	;RS232 ring indicator
mfptt_b4vect	= $150	;Timer D interrupt vector (RS232 baud rate generator, not used in Falcon030)
mfptt_b5vect	= $154	;Timer C interrupt vector (SCC TRxCB)
mfptt_b6vect	= $158	;Reserved
mfptt_b7vect	= $15c	;SCSI DMAC interrupt vector
mfptt_a0vect	= $160	;Timer B (Unassigned)
mfptt_a1vect	= $164	;RS232 transmit error interrupt vector
mfptt_a2vect	= $168	;RS232 transmit buffer error interrupt vector
mfptt_a3vect	= $16c	;RS232 receive error interrupt
mfptt_a4vect	= $170	;RS232 Reveive buffer full interrupt
mfptt_a5vect	= $174	;Timer A (Reserved)
mfptt_a6vect	= $178	;RTC IRQ interrupt vector
mfptt_a7vect	= $17c	;SCSI Controller IRQ interrupt vector

vec_mfpTT_gpi0	= mfptt_b0vect
vec_mfpTT_gpi1	= mfptt_b1vect
vec_SCC_dmac	= mfptt_b2vect
vec_TTrs232_ri	= mfptt_b3vect
vec_TTtimer_d	= mfptt_b4vect
vec_TTtimer_c	= mfptt_b5vect
vec_TT_resrved	= mfptt_b6vect
vec_SCSII_dma	= mfptt_b7vect
vec_TTtimer_b	= mfptt_a0vect
vec_TTrs232_te	= mfptt_a1vect
vec_TTrs232_tbe	= mfptt_a2vect
vec_TTrs232_re	= mfptt_a3vect
vec_TTrs232_rbf	= mfptt_a4vect
vec_TTtimer_a	= mfptt_a5vect
vec_RTCIRQ	= mfptt_a6vect
vec_SCSII	= mfptt_a7vect

*********	Zilog 85C30 (SCC) INTERRUPT VECTORS
scc_pbtbe	= $180	;SCC Port B Transmit buffer empty interrupt vector
scc_pbesc	= $188	;SCC Port B External Status Change interrupt Vector
scc_pbrca	= $190	;SCC Port B Receive Character Available interrupt vector
scc_pbsrc	= $198	;SCC Port B Special Receive Condition interrupt vector

scc_patbe	= $1a0	;SCC Port A Transmit buffer empty interrupt vector
scc_paesc	= $1a8	;SCC Port A External Status Change interrupt Vector
scc_parca	= $1b0	;SCC Port A Receive Character Available interrupt vector
scc_pasrc	= $1b8	;SCC Port A Special Receive Condition interrupt vector

*********	PROCESSOR STATE SAVE AREA
proc_lives	= $380	;(L) If, after a chrash, this contain 0x12345678, the system managed to save
			;(L) the processor status in the below table
proc_dregs	= $384	;(L) Data registers
proc_aregs	= $3a4	;(L) Address registers
proc_pc		= $3c4	;(L) Program counter (First byte indicates the exception # that occured)
proc_usp	= $3c8	;(L) User stack
proc_stk	= $3cc	;(W) Top 16 words of the super stack

*********	SYSTEM VARIABLES
etv_timer	= $400	;(L) System Timer Handoff Vector
etv_critic	= $404	;(L) Critical Error Handoff Vector
etv_term	= $408	;(L) Process Termination Handler
etv_xtra	= $40c	;(L)
memvalid	= $420	;(L) If this varib = $752019F3 and MEMVAL2 ($43A) is also correct, the last coldstart
			;    was successful and MEMCNTLR ($424) is valid. As of TOS 1.02 MEMVAL3 ($51A) must also be correct.
memcntlr	= $424	;(W) Bits 11-8 of this word contains the memory controller state.
resmagic	= $31415926
resvalid	= $426	;(L) If this location contains the magic number RESMAGIC, the system will jump through RESVECTOR on system reset.
resvector	= $42a	;(L) The system will jump through the address here if _RESVALID is set properly. Return address in A6
phystop		= $42e	;(L) Physical top of ST compatible RAM.
_membot		= $432	;(L) Points to the lowest memory location available for the system heap. Used to initialize GEMDOS free memory.
_memtop		= $436	;(L) Points to the highest memory location available for the system heap. Used to initialize GEMDOS free memory.
memval2		= $43a	;(L) This value will equal $237698AA if coldstart was successful.
flock		= $43e	;(W) Set this word to non-zero prior to DMA register access to prevent other DMA accesses at the same time
seekrate	= $440	;(W) Floppy drive seek rate. 0=6ms, 1=12ms, 2=2ms, 3=3ms(defoult)
_timr_ms	= $442	;(W) Indicates the time between system timer ticks in milliseconds. Current machines have the value of 20 equating to 50 timer updates per second.
			;    This value is returned by the BIOS function TICKCAL() and is placed on the stack prior to jumping through the timer handoff vector ($400).
_fverify	= $444	;(W) When non-zero, all floppy writes are verified, otherwise, no verification is done.
_bootdev	= $446	;(W) The device from which the system was booted (0=A, 1=B, etc.)
palmode		= $448	;(W) A value of 0 indicates that NTSC video is being used, otherwise PAL.
defshiftmd	= $44a	;(W) The default video shifter mode.
sshiftmd	= $44c	;(W) This value is a copy of the hardware register at 0x00FF82690 which indicates the current ST shifter mode.
_v_bas_ad	= $44e	;(L) Starting address of physical screen RAM. Prior to TOS 1.06, screen RAM had to have been 256 byte aligned. As of TOS 1.06, it may be WORD aligned.
_v_bas_2	= $44f
_v_bas_1	= $450
_v_bas_0	= $451
vblsem		= $452	;(W) A value of 0 here disable all vertical blank processing while a value of 1 enables it.
nvbls		= $454	;(W) Indicates the number of slots in the deferred vertical blank handler list. If all table slots are full and your application needs to install a handler,
			;    it may allocate a new, larger list, update this value and the pointer below.
_vblqueue	= $456	;(L) Pointer to a list of pointers to the deferred vertical blank handlers. Each pointer is JSR'ed through at each vertical blank. 0 address terminates the list.
colorptr	= $45a	;(L) If this value is non-zero then at the next vertical blank, the 16 color register pointed to by this value will be loaded into the hardware registers.
screenpt	= $45e	;(L) If this value is non-zero then at the next vertical blank, the value stored here will be loaded into the hardware register which point to the base of the physical screen.
_vbclock	= $462	;(L) Number of vertical blanks that have been processed since the last reset.
_frclock	= $466	;(L) Number of vertical blanks regardless of whether they were processed or not.
hdv_init	= $46a	;(L) Pointer to the hard disk initialization routine or is 0 ti indicate that no hard disk is installed.
swv_vec		= $46e	;(L) Pointer to a routine that is called when the system detects a change in monitors
hdv_bpb		= $472	;(L) This address is used when GETBPB() is called. A value of 0 indicates that no hard disk (or other devices) is attached
hdv_rw		= $476	;(L) 
hdv_boot	= $47a	;(L)
hdv_mediach	= $47e	;(L)
_cmdload	= $482	;(W)
conterm		= $484	;(B)
trp14ret	= $486	;(L)
criticret	= $48a	;(L)
themd		= $48e	;(B)
_md		= $49e	;(L)
savptr		= $4a2	;(L)
_nflops		= $4a6	;(W)
con_state	= $4a8	;(L)
save_row	= $4ac	;(W)
sav_context	= $4ae	;(L)
_bufl1		= $4b2	;(L)
_bufl2		= $4b6	;(L)
_hz_200		= $4ba	;(L)
the_env		= $4bc	;(L)
_drvbits	= $4c2	;(L)
_dskbufp	= $4c6	;(L)
_autopath	= $4ca	;(L)
_vbl_list	= $4ce	;(L)
_prt_cnt	= $4ee	;(W)
_prtabt		= $4f0	;(W)
_sysbase	= $4f2	;(L)
_shell_p	= $4f6	;(L)
end_os		= $4fa	;(L)
exec_os		= $4fe	;(L)
scr_dump	= $502	;(L)
prv_lsto	= $506	;(L)
prv_lst		= $50a	;(L)
prv_auxo	= $50e	;(L)
prv_aux		= $512	;(L)
pun_ptr		= $516	;(L)
memval3		= $51a	;(L)
xconstat	= $51e	;(L)
xconin		= $53e	;(L)
xcostat		= $55e	;(L)
xconout		= $57e	;(L)
_longframe	= $59e	;(L)
_p_cookies	= $5a0	;(L)
ramtop		= $5a4	;(L)
ramvalid	= $5a8	;(L)
bell_hook	= $5ac	;(L)
kcl_hook	= $5b0	;(L)

* Line A Variables

A_init		= $a000
A_putpix	= $a001
A_getpix	= $a002
A_abline	= $a003
A_habline	= $a004
A_rectfill	= $a005
A_polyfill	= $a006
A_bitblt	= $a007
A_textblt	= $a008
A_showcur	= $a009
A_hidecur	= $a00a
A_chgcur	= $a00b
A_drsprite	= $a00c
A_unsprite	= $a00d
A_copyrstr	= $a00e
A_seedfill	= $a00f

* HARDWARE I/O REGISTERS

*********	MEMORY MANAGEMENT UNIT
hw_memconf	= $ffff8001	;(B) All Ataris

hw_f30_mon_type	= $ffff8006	;(B) Falcon030
hw_f30_cntrl	= $ffff8007	;(B) Faclon030

*********	SHIFTER
hw_vbasehi	= $ffff8201	;(B) All Ataris
hw_vbasemd	= $ffff8203	;(B) All Ataris
hw_vbaselo	= $ffff820c	;(B) STE, Mega STE, TT, Falcon030	

hw_vposhi	= $ffff8205	;(B) All Ataris	
hw_vposmd	= $ffff8207	;(B) All Ataris
hw_vposlo	= $ffff8209	;(B) All Ataris

hw_linewid_f	= $ffff820e	;(W) Falcon030
hw_linewid	= $ffff820f	;(B) STE, Mega STE, TT
hw_linewid_f1	= $ffff8210	;(W)Falcon030

hw_hscroll	= $ffff8265	;(B) STE, Mega STE, TT, Falcon030

hw_syncmode	= $ffff820a	;(B) All Ataris
hw_shiftmd	= $ffff8260	;(B) All Ataris
hw_shiftmd_tt	= $ffff8262	;(B) TT
hw_shiftctrl	= $ffff8266	;(W)Falcon030
hw_stacydisp	= $ffff827e	;(B) Stacy

hw_hht_sync	= $ffff8282	;(W) Falcon030
hw_hbb_eol	= $ffff8284	;(W) Falcon030
hw_hbe_sol	= $ffff8286	;(W) Falcon030
hw_hdb_lov	= $ffff8288	;(W) Falcon030
hw_hde_rov	= $ffff828a	;(W) Falcon030
hw_hss_sync	= $ffff828c	;(W) Falcon030
hw_hfs		= $ffff828e	;(W) Falcon030
hw_hee		= $ffff8290	;(W) Falcon030

hw_vft_sync	= $ffff82a2	;(W) Falcon030
hw_vbb_eoi	= $ffff82a4	;(W) Falcon030
hw_vbe_soi	= $ffff82a6	;(W) Falcon030
hw_vbd_tov	= $ffff82a8	;(W) Falcon030
hw_vde_bov	= $ffff82aa	;(W) Falcon030
hw_vss_sync	= $ffff82ac	;(W) Falcon030

hw_vco_ctrl	= $ffff82c2	;(W) Falcon030

hw_color0	= $ffff8240	;(W) All Ataris
hw_color1	= $ffff8242	;(W) All Ataris
hw_color2	= $ffff8244	;(W) All Ataris
hw_color3	= $ffff8246	;(W) All Ataris
hw_color4	= $ffff8248	;(W) All Ataris
hw_color5	= $ffff824a	;(W) All Ataris
hw_color6	= $ffff824c	;(W) All Ataris
hw_color7	= $ffff824e	;(W) All Ataris
hw_color8	= $ffff8250	;(W) All Ataris
hw_color9	= $ffff8252	;(W) All Ataris
hw_color10	= $ffff8254	;(W) All Ataris
hw_color11	= $ffff8256	;(W) All Ataris
hw_color12	= $ffff8258	;(W) All Ataris
hw_color13	= $ffff825a	;(W) All Ataris
hw_color14	= $ffff825c	;(W) All Ataris
hw_color15	= $ffff825e	;(W) All Ataris

hw_ttcol0	= $ffff8400	;(W) TT

*********	ASCI DMA and FLOPPY DISK CONROLLER
hw_a_ctrl	= $ffff8604	;(W) All Ataris	
hw_a_status	= $ffff8606	;(W) All Ataris
hw_a_dmahi	= $ffff8609	;(B) All Ataris
hw_a_dmamd	= $ffff860b	;(B) All Ataris
hw_a_dmalo	= $ffff860d	;(B) All Ataris

cmdreg		= $80	; 1770/FIFO command register select
trkreg		= $82	; 1770/FIFO track register select
secreg		= $84	; 1770/FIFO sector register select
datareg		= $86	; 1770/FIFO data register select

*********	SCSI DMA CONTROL
hw_sc_dmapu	= $ffff8701	;(B) TT
hw_sc_dmapumd	= $ffff8703	;(B) TT
hw_sc_dmaplmd	= $ffff8705	;(B) TT
hw_sc_dmapl	= $ffff8707	;(B) TT
hw_sc_bcntu	= $ffff8709	;(B) TT
hw_sc_bcntlmd	= $ffff870d	;(B) TT
hw_sc_bcntl	= $ffff870f	;(B) TT
hw_sc_dmadrhi	= $ffff8710	;(W) TT
hw_sc_dmadrlo	= $ffff8712	;(W) TT
hw_sc_dmactrl	= $ffff8715	;(B) TT

*********	SCSI CONTROLLER REGISTERS
hw_sc_data	= $ffff8781	;(B) TT
hw_sc_incmnd	= $ffff8783	;(B) TT
hw_sc_mode	= $ffff8785	;(B) TT
hw_sc_tcmd	= $ffff8787	;(B) TT
hw_sc_ctrl	= $ffff8789	;(B) TT
hw_sc_start	= $ffff878b	;(B) TT
hw_sc_treciv	= $ffff878d	;(B) TT
hw_sc_ireciv	= $ffff878f	;(B) TT

*********	PROGRAMMABLE SOUND GENERATOR (YM-2149)
hw_giselect	= $ffff8800	;(B) All Ataris
hw_giread	= hw_giselect	;(B) All Ataris
hw_giwrite	= $ffff8802	;(B) All Ataris
* PSG REGISTER NAMES
gitaf		= 0	;channel A fine/coarse tune
gitac		= 1
gitbf		= 2	;channel B
gitbc		= 3
gitcf		= 4	;channel C
gitcc		= 5
ginoise		= 6	;noise generator control
gimix		= 7	;I/O control/volume control register
giavol		= 8	;Channel A volume
gibvol		= 9	;Channel B volume
gicvol		= $a	;Channel C volume
gisuslo		= $b	;Sustain low byte
gisushi		= $c	;Sustain hi byte
gienv		= $d	;Waveform
giporta		= $e	;GI register# for I/O port A
giportb		= $f	;Centronics output register

*********	DMA SOUND SYSTEM
hw_snddmactrlf	= $ffff8900	;(B) Falcon030
hw_snddmacrtl	= $ffff8901	;(B) STE, Mega STE, TT, Falcon030
hw_sndfbahi	= $ffff8903	;(B) STE, Mega STE, TT, Falcon030
hw_sndfbamd	= $ffff8905	;(B) STE, Mega STE, TT, Falcon030
hw_sndfbalo	= $ffff8907	;(B) STE, Mega STE, TT, Falcon030
hw_sndfachi	= $ffff8909	;(B) STE, Mega STE, TT, Falcon030
hw_sndfacmd	= $ffff890b	;(B) STE, Mega STE, TT, Falcon030
hw_sndfaclo	= $ffff890d	;(B) STE, Mega STE, TT, Falcon030
hw_sndfeahi	= $ffff890f	;(B) STE, Mega STE, TT, Falcon030
hw_sndfeamd	= $ffff8911	;(B) STE, Mega STE, TT, Falcon030
hw_sndfealo	= $ffff8913	;(B) STE, Mega STE, TT, Falcon030
hw_sndmodctrlf	= $ffff8920	;(B) Falcon030
hw_sndmodctrl	= $ffff8921	;(B) STE, Mega STE, TT, Falcon030

*********	MICROWIRE
hw_microdata	= $ffff8922	;(W) STE, Mega STE, TT
hw_micromask	= $ffff8924	;(W) STE, Mega STE, TT

*********	FALCON030 DSP/DMA CONTROLLER
hw_f30dmacos	= $ffff8930	;(W) Falcon030	
hw_f30dmacis	= $ffff8932	;(W) Falcon030
hw_f30fdivex	= $ffff8934	;(B) Falcon030
hw_f30fdivin	= $ffff8935	;(B) Falcon030
hw_f30rtrks	= $ffff8936	;(B) Falcon030
hw_f30codeci	= $ffff8937	;(B) Falcon030
hw_f30cadci	= $ffff8938	;(B) Falcon030
hw_f30gain	= $ffff8939	;(B) Falcon030
hw_f30att	= $ffff893a	;(B) Falcon030
hw_f30gpiodd	= $ffff8941	;(B) Falcon030
hw_f30gpiodata	= $ffff8943	;(B) Falcon030

*********	REAL TIME CLOCK (146818A)
hw_rtcaddr	= $ffff8961	;(B) Mega STE, TT, Falcon030
hw_rtcdata	= $ffff8963	;(B) Mega STE, TT, Falcon030

*********	BLITTER BIT-BLOCK TRANSFER PROCESSOR
hw_blthtr0	= $ffff8a00	;(W) All Ataris with blitter installed
hw_blthtr1	= $ffff8a02	;(W) All Ataris with blitter installed
hw_blthtr2	= $ffff8a04	;(W) All Ataris with blitter installed
hw_blthtr3	= $ffff8a06	;(W) All Ataris with blitter installed
hw_blthtr4	= $ffff8a08	;(W) All Ataris with blitter installed
hw_blthtr5	= $ffff8a0a	;(W) All Ataris with blitter installed
hw_blthtr6	= $ffff8a0c	;(W) All Ataris with blitter installed
hw_blthtr7	= $ffff8a0e	;(W) All Ataris with blitter installed
hw_blthtr8	= $ffff8a10	;(W) All Ataris with blitter installed
hw_blthtr9	= $ffff8a12	;(W) All Ataris with blitter installed
hw_blthtr10	= $ffff8a14	;(W) All Ataris with blitter installed
hw_blthtr11	= $ffff8a16	;(W) All Ataris with blitter installed
hw_blthtr12	= $ffff8a18	;(W) All Ataris with blitter installed
hw_blthtr13	= $ffff8a1a	;(W) All Ataris with blitter installed
hw_blthtr14	= $ffff8a1c	;(W) All Ataris with blitter installed
hw_blthtr15	= $ffff8a1e	;(W) All Ataris with blitter installed

hw_bltsxinc	= $ffff8a20	;(W) All Ataris with blitter installed
hw_bltsyinc	= $ffff8a22	;(W) All Ataris with blitter installed

hw_bltsadrhi	= $ffff8a24	;(W) All Ataris with blitter installed
hw_bltsadrlo	= $ffff8a26	;(W) All Ataris with blitter installed

hw_bltendm1	= $ffff8a28	;(W) All Ataris with blitter installed
hw_bltendm2	= $ffff8a2a	;(W) All Ataris with blitter installed
hw_bltendm3	= $ffff8a2c	;(W) All Ataris with blitter installed

hw_bltdxinc	= $ffff8a2e	;(W) All Ataris with blitter installed
hw_bltdyinc	= $ffff8a30	;(W) All Ataris with blitter installed

hw_bltdadrhi	= $ffff8a32	;(W) All Ataris with blitter installed
hw_bltdadrlo	= $ffff8a34	;(W) All Ataris with blitter installed

hw_bltxcount	= $ffff8a36	;(W) All Ataris with blitter installed
hw_bltycount	= $ffff8a38	;(W) All Ataris with blitter installed
hw_blthop	= $ffff8a3a	;(B) All Ataris with blitter installed
hw_bltop	= $ffff8a3b	;(B) All Ataris with blitter installed
hw_bltconf	= $ffff8a3c	;(B) All Ataris with blitter installed
hw_bltskew	= $ffff8a3d	;(B) All Ataris with blitter installed

*********	SCC DMA REGISTERS
hw_sccdmapu	= $ffff8c01	;(B) Mega STE, TT, Falcon030
hw_sccdmapumd	= $ffff8c03	;(B) Mega STE, TT, Falcon030
hw_sccdmaplmd	= $ffff8c05	;(B) Mega STE, TT, Falcon030
hw_sccdmapl	= $ffff8c07	;(B) Mega STE, TT, Falcon030
hw_sccbcu	= $ffff8c09	;(B) Mega STE, TT, Falcon030
hw_sccbcumd	= $ffff8c0b	;(B) Mega STE, TT, Falcon030
hw_sccbclmd	= $ffff8c0d	;(B) Mega STE, TT, Falcon030
hw_sccbcl	= $ffff8c0f	;(B) Mega STE, TT, Falcon030
hw_sccdrhi	= $ffff8c10	;(W) Mega STE, TT, Falcon030
hw_sccdrlo	= $ffff8c12	;(W) Mega STE, TT, Falcon030
hw_sccdmactrl	= $ffff8c15	;(B) Mega STE, TT, Falcon030

*********	SCC PORTS (85C30)
hw_sccactrl	= $ffff8c81	;(B) Mega STE, TT, Falcon030
hw_sccadata	= $ffff8c83	;(B) Mega STE, TT, Falcon030
hw_sccbctrl	= $ffff8c85	;(B) Mega STE, TT, Falcon030
hw_sccbdata	= $ffff8c87	;(B) Mega STE, TT, Falcon030

*********	SYSTEM CONTROL UNIT
hw_scusysim	= $ffff8e01	;(B) Mega STE, TT
hw_scusysis	= $ffff8e03	;(B) Mega STE, TT
hw_scusysint	= $ffff8e05	;(B) Mega STE, TT
hw_scuvmeint	= $ffff8e07	;(B) Mega STE, TT
hw_scugpr1	= $ffff8e09	;(B) Mega STE, TT
hw_scugpr2	= $ffff8e0b	;(B) Mega STE, TT
hw_scuvmeim	= $ffff8e0d	;(B) Mega STE, TT
hw_scuvmeis	= $ffff8e0f	;(B) Mega STE, TT

*********	MEGA STE CACHE/PROCESSOR CONTROL
hw_mstecacr	= $ffff8e21	;(B) Mega STE

*********	EXTENDED JOYSTICK/PADDLE/LIGHTGUN PORTS
hw_joyfire	= $ffff9200	;(W) STE, Falcon030
hw_joydir	= $ffff9202	;(W) STE, Falcon030
hw_pad0xdir	= $ffff9210	;(W) STE, Falcon030
hw_pad0ydir	= $ffff9212	;(W) STE, Falcon030
hw_pad1xdir	= $ffff9214	;(W) STE, Falcon030
hw_pad1ydir	= $ffff9216	;(W) STE, Falcon030
hw_lgpenxpos	= $ffff9220	;(W) STE, Falcon030
hw_lgpenypos	= $ffff9222	;(W) STE, Falcon030

*********	FALCON030 VIDEL PALETTE REGISTERS
hw_f30col0	= $ffff9800	;(L) Falcon030

*********	ST MULTI FUNCTIONAL PERIPHERAL PORT (68901)
hw_mfp		= $fffffa00	;Base address
hw_mfpgpip	= $fffffa01	;(B) All Ataris
hw_mfpaer	= $fffffa03	;(B) All Ataris
hw_mfpddr	= $fffffa05	;(B) All Ataris
hw_mfpiera	= $fffffa07	;(B) All Ataris
hw_mfpierb	= $fffffa09	;(B) All Ataris
hw_mfpipra	= $fffffa0b	;(B) All Ataris
hw_mfpiprb	= $fffffa0d	;(B) All Ataris
hw_mfpisra	= $fffffa0f	;(B) All Ataris
hw_mfpisrb	= $fffffa11	;(B) All Ataris
hw_mfpimra	= $fffffa13	;(B) All Ataris
hw_mfpimrb	= $fffffa15	;(B) All Ataris
hw_mfpvr	= $fffffa17	;(B) All Ataris
hw_mfptacr	= $fffffa19	;(B) All Ataris
hw_mfptbcr	= $fffffa1b	;(B) All Ataris
hw_mfptcdcr	= $fffffa1d	;(B) All Ataris
hw_mfptadr	= $fffffa1f	;(B) All Ataris
hw_mfptbdr	= $fffffa21	;(B) All Ataris
hw_mfptcdr	= $fffffa23	;(B) All Ataris
hw_mfptddr	= $fffffa25	;(B) All Ataris
hw_mfpscr	= $fffffa27	;(B) All Ataris
hw_mfpucr	= $fffffa29	;(B) All Ataris
hw_mfprsr	= $fffffa2b	;(B) All Ataris
hw_mfptsr	= $fffffa2d	;(B) All Ataris
hw_mfpudr	= $fffffa2f	;(B) All Ataris

******************* MFP offsets from BASE ADDRESS
gpip		= $1	;(B) All Ataris
aer		= $3	;(B) All Ataris
ddr		= $5	;(B) All Ataris
iera		= $7	;(B) All Ataris
ierb		= $9	;(B) All Ataris
ipra		= $b	;(B) All Ataris
iprb		= $d	;(B) All Ataris
isra		= $f	;(B) All Ataris
isrb		= $11	;(B) All Ataris
imra		= $13	;(B) All Ataris
imrb		= $15	;(B) All Ataris
vr		= $17	;(B) All Ataris
tacr		= $19	;(B) All Ataris
tbcr		= $1b	;(B) All Ataris
tcdcr		= $1d	;(B) All Ataris
tadr		= $1f	;(B) All Ataris
tbdr		= $21	;(B) All Ataris
tcdr		= $23	;(B) All Ataris
tddr		= $25	;(B) All Ataris
scr		= $27	;(B) All Ataris
ucr		= $29	;(B) All Ataris
rsr		= $2b	;(B) All Ataris
tsr		= $2d	;(B) All Ataris
udr		= $2f	;(B) All Ataris

*********	TT MULTI FUNCTIONAL PERIPHERAL PORT (68901)
hw_mfptt	= $fffffa80	;Base address
hw_mfpttgpip	= $fffffa81	;(B) TT
hw_mfpttaer	= $fffffa83	;(B) TT
hw_mfpttddr	= $fffffa85	;(B) TT
hw_mfpttiera	= $fffffa87	;(B) TT
hw_mfpttierb	= $fffffa89	;(B) TT
hw_mfpttipra	= $fffffa8b	;(B) TT
hw_mfpttiprb	= $fffffa8d	;(B) TT
hw_mfpttisra	= $fffffa8f	;(B) TT
hw_mfpttisrb	= $fffffa91	;(B) TT
hw_mfpttimra	= $fffffa93	;(B) TT
hw_mfpttimrb	= $fffffa95	;(B) TT
hw_mfpttvr	= $fffffa97	;(B) TT
hw_mfptttacr	= $fffffa99	;(B) TT
hw_mfptttbcr	= $fffffa9b	;(B) TT
hw_mfptttcdcr	= $fffffa9d	;(B) TT
hw_mfptttadr	= $fffffa9f	;(B) TT
hw_mfptttbdr	= $fffffaa1	;(B) TT
hw_mfptttcdr	= $fffffaa3	;(B) TT
hw_mfptttddr	= $fffffaa5	;(B) TT
hw_mfpttscr	= $fffffaa7	;(B) TT
hw_mfpttucr	= $fffffaa9	;(B) TT
hw_mfpttrsr	= $fffffaab	;(B) TT
hw_mfptttsr	= $fffffaad	;(B) TT
hw_mfpttudr	= $fffffaaf	;(B) TT

*********	KEYBOARD ACIA REGISTERS
hw_keyacia	= $fffffc00
hw_keyctl	= $fffffc00	;(B) All Ataris
hw_keybd	= $fffffc02	;(B) All Ataris

aciactl		= 0
aciadat		= 2

*********	MIDI ACIA REGISTERS
hw_midiacia	= $fffffc04
hw_midictl	= $fffffc04	;(B) All Ataris
hw_midi		= $fffffc06	;(B) All Ataris

********	68881 MATH CO-PROCESSOR IN PERIPHERAL MODE
hw_fpcir	= $fffffa40	;(W) Mega ST, Mega STE
hw_fpctl	= $fffffa42	;(W) Mega ST, Mega STE
hw_fpsav	= $fffffa44	;(W) Mega ST, Mega STE
hw_fprest	= $fffffa46	;(W) Mega ST, Mega STE
hw_fpopr	= $fffffa48	;(W) Mega ST, Mega STE
hw_fpcmd	= $fffffa4a	;(W) Mega ST, Mega STE
hw_fpres	= $fffffa4c	;(W) Mega ST, Mega STE
hw_fpccr	= $fffffa4e	;(W) Mega ST, Mega STE
hw_fpop		= $fffffa50	;(L) Mega ST, Mega STE
hw_fpslct	= $fffffa54	;(W) Mega ST, Mega STE
hw_fpiadr	= $fffffa58	;(L) Mega ST, Mega STE
hw_fpoadr	= $fffffa5c	;(L) Mega ST, Mega STE
