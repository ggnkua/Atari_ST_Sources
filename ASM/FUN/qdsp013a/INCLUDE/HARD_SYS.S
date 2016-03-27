;*********************************************************************;
;*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*;
;*~            D‚finition des diff‚rents registres Hard             ~*;
;*~                      des STF/STE/MegaST                         ~*;
;*~                ainsi que des variables systŠmes                 ~*;
;*~                         principales                             ~*;
;*~                                                                 ~*;
;*~                   (C)oderight NulloS 90/91/92                   ~*;
;*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*;
;*********************************************************************;

	IFND	__hardsys
;*********************;
;   Registres vid‚o   ;
;*********************;
v_base	equ	$ffff8200
v_base_h	equ	$ffff8201
v_base_m	equ	$ffff8203
v_base_l	equ	$ffff820d

v_count_h	equ	$ffff8205
v_count_m	equ	$ffff8207
v_count_l	equ	$ffff8209

v_synch	equ	$ffff820a
v_resol	equ	$ffff8260

v_linewid	equ	$ffff820f
v_hscroll	equ	$ffff8265

v_color	equ	$ffff8240
v_color0	equ	$ffff8240
v_color1	equ	$ffff8242
v_color2	equ	$ffff8244
v_color3	equ	$ffff8246
v_color4	equ	$ffff8248
v_color5	equ	$ffff824a
v_color6	equ	$ffff824c
v_color7	equ	$ffff824e
v_color8	equ	$ffff8250
v_color9	equ	$ffff8252
v_color10	equ	$ffff8254
v_color11	equ	$ffff8256
v_color12	equ	$ffff8258
v_color13	equ	$ffff825a
v_color14	equ	$ffff825c
v_color15	equ	$ffff825e

;Sp‚cial Falcon030
v_Wide	equ	$ffff820e
v_Wrap	equ	$ffff8210
v_Shift	equ	$ffff8260
v_SpShift	equ	$ffff8266
v_CO	equ	$ffff82C0
v_Mode	equ	$ffff82C2
v_HHT	equ	$ffff8282
v_HBB	equ	$ffff8284
v_HBE	equ	$ffff8286
v_HDB	equ	$ffff8288
v_HDE	equ	$ffff828A
v_HSS	equ	$ffff828C
v_HFS	equ	$ffff828E
v_HEE	equ	$ffff8290
v_VFT	equ	$ffff82A2
v_VBB	equ	$ffff82A4
v_VBE	equ	$ffff82A6
v_VDB	equ	$ffff82A8
v_VDE	equ	$ffff82AA
v_VSS	equ	$ffff82AC

v_color030	equ	$ffff9800

;*********************;
;  Registres DMA disk ;
;*********************;
dma_ctrl	equ	$ffff8606
dma_data	equ	$ffff8604
dma_low	equ	$ffff860d
dma_mid	equ	$ffff860b
dma_high	equ	$ffff8609
;*********************;
;   Registres Yamaha  ;
;*********************;
yam_ctrl	equ	$ffff8800
yam_read	equ	$ffff8800
yam_write	equ	$ffff8802
;*********************;
;    Registres PCM    ;
;*********************;
PCM_base	equ	$ffff8900
pcm_irq	equ	$0
pcm_mode	equ	$1
spl_starth	equ	$3
spl_startm	equ	$5
spl_startl	equ	$7

spl_counth	equ	$9
spl_countm	equ	$b
spl_countl	equ	$d

spl_endh	equ	$f
spl_endm	equ	$11
spl_endl	equ	$13

pcm_ptrk	equ	$20
pcm_rtrk	equ	$36
pcm_ctrl	equ	$21

mcw_data	equ	$22
mcw_ctrl	equ	$24
mcw_mask	equ	$24

mpx_src	equ	$30
mpx_dst	equ	$32
mpx_clk	equ	$34

dsp_gpc	equ	$41
dsp_gpd	equ	$43

cdc_add	equ	$37
cdc_inp	equ	$38
cdc_att	equ	$39
cad_amp	equ	$3a

_mcw_pmask	equ	$7ff

_master_vol	equ	$4c0
_left_vol	equ	$540
_right_vol	equ	$500
_treble	equ	$480
_bass	equ	$440
_pcm_mix	equ	$400

_Khz6	equ	0
_Khz12	equ	1
_Khz25	equ	2
_Khz50	equ	3

_mono	equ	128
_stereo	equ	0

_spl_off	equ	0
_spl_one	equ	1
_spl_many	equ	3

;*********************;
; DSP Host            ;
;*********************;
HST_base	equ	$ffffa200
hicr	equ	$0
hcvr	equ	$1
hisr	equ	$2
hivr	equ	$3
hrx	equ	$4
hrxh	equ	$5
hrxm	equ	$6
hrxl	equ	$7
htx	equ	$4
htxh	equ	$5
htxm	equ	$6
htxl	equ	$7

;*********************;
; Joystick STE        ;
;*********************;
joy_fire	equ	$ffff9200
joy_pos	equ	$ffff9202
joy0_x	equ	$ffff9210
joy0_y	equ	$ffff9212
joy1_x	equ	$ffff9214
joy1_y	equ	$ffff9216
joy2_x	equ	$ffff9220
joy2_y	equ	$ffff9222

;*********************;
;    Registres MFP    ;
;*********************;
MFP_base	equ	$fffffa01
GPIP	equ	$0
AER	equ	$2
DDR	equ	$4
IERA	equ	$6
IERB	equ	$8
IPRA	equ	$a
IPRB	equ	$c
ISRA	equ	$e
ISRB	equ	$10
IMRA	equ	$12
IMRB	equ	$14
VR	equ	$16
TACR	equ	$18
TBCR	equ	$1a
TCDCR	equ	$1c
TADR	equ	$1e
TBDR	equ	$20
TCDR	equ	$22
TDDR	equ	$24
SCR	equ	$26
UCR	equ	$28
RSR	equ	$2a
TSR	equ	$2c
UDR	equ	$2e

V_CTNX	equ	$100
V_RSport	equ	$104
V_RScts	equ	$108
V_BLIT	equ	$10C
V_TD	equ	$110
V_TC	equ	$114
V_ACIA	equ	$118
V_DMA	equ	$11C
V_TB	equ	$120
V_RSouterr	equ	$124
V_RSempty	equ	$128
V_RSinerr	equ	$12C
V_RSinfull	equ	$130
V_TA	equ	$134
V_RSring	equ	$138
V_MONO	equ	$13C
;*********************;
;   Registres ACIAs   ;
;*********************;
KBD_ctrl	equ	$fffffc00
KBD_stat	equ	$fffffc00
KBD_data	equ	$fffffc02
MIDI_ctrl	equ	$fffffc04
MIDI_stat	equ	$fffffc04
MIDI_data	equ	$fffffc06
;*********************;
;  Registres Blitter  ;
;*********************;
BLIT_base	equ	$ffff8a00
b_raster	equ	$0
b_src_xinc	equ	$20
b_src_yinc	equ	$22
b_src_adr	equ	$24
b_mask1	equ	$28
b_mask2	equ	$2a
b_mask3	equ	$2c
b_dst_xinc	equ	$2e
b_dst_yinc	equ	$30
b_dst_adr	equ	$32
b_x_count	equ	$36
b_y_count	equ	$38
b_hop	equ	$3a
b_op	equ	$3b
b_ctrl	equ	$3c
b_mode	equ	$3d
;*********************;
;  Registres Horloge  ;
;*********************;
HORL_base	equ	$fffffc21
sec_l	equ	$0
sec_h	equ	$2
min_l	equ	$4
min_h	equ	$6
hour_l	equ	$8
hour_h	equ	$a
in_week	equ	$c
day_l	equ	$e
day_h	equ	$10
month_l	equ	$12
month_h	equ	$14
year_l	equ	$16
year_h	equ	$18
;*********************;
; Variables de Line_A ;
;*********************;
	RSRESET
v_planes	rs.w	1
v_lin_wr	rs.w	1
CONTRL	rs.l	1
INTIN	rs.l	1
PTSIN	rs.l	1
INTOUT	rs.l	1
PTSOUT	rs.l	1
_FG_BP_1	rs.w	1
_FG_BP_2	rs.w	1
_FG_BP_3	rs.w	1
_FG_BP_4	rs.w	1
_LSTLIN	rs.w	1
_LN_MASK	rs.w	1
_WRT_MODE	rs.w	1

_X1	rs.w	1
_Y1	rs.w	1
_X2	rs.w	1
_Y2	rs.w	1

_patptr	rs.l	1
_patmsk	rs.w	1
_multifill	rs.w	1

_CLIP	rs.w	1
_XMN_CLIP	rs.w	1
_YMN_CLIP	rs.w	1
_XMX_CLIP	rs.w	1
_YMX_CLIP	rs.w	1

_XACC_DDA	rs.w	1
_DDA_INC	rs.w	1
_T_SCLSTS	rs.w	1
_MONO_STATUS	rs.w	1
_SOURCEX	rs.w	1
_SOURCEY	rs.w	1
_DESTX	rs.w	1
_DESTY	rs.w	1
_DELX	rs.w	1
_DELY	rs.w	1
_FBASE	rs.l	1
_FWIDTH	rs.w	1
_STYLE	rs.w	1
_LITEMASK	rs.w	1
_SKEWMASK	rs.w	1
_WEIGHT	rs.w	1
_R_OFF	rs.w	1
_L_OFF	rs.w	1
_SCALE	rs.w	1
_CHUP	rs.w	1
_TEXT_FG	rs.w	1
_scrtchp	rs.l	1
_scrpt2	rs.w	1
_TEXT_BG	rs.w	1
_COPYTRAN	rs.w	1
_FILL_ABORT	rs.l	1

	RSSET	-906
CUR_FONT	rs.l	1
	RSSET	-856
M_POS_HX	rs.w	1
M_POS_HY	rs.w	1
M_PLANES	rs.w	1
M_CDB_BG	rs.w	1
M_CDB_FG	rs.w	1
MASK_FORM	rs.w	32
INQ_TAB	rs.w	45
DEV_TAB	rs.w	45
G_CURX	rs.w	1
G_CURY	rs.w	1
M_HID_CT	rs.w	1
MOUSE_BT	rs.w	1
REQ_COL	rs.w	48
SIZ_TAB	rs.w	15
	rs.w	1
	rs.w	1
CUR_WORK	rs.l	1
DEF_FONT	rs.l	1
FONT_RING	rs.l	4
FONT_COUNT	rs.w	1
	RSSET	-348
CUR_MS_STAT	rs.b	1
	rs.b	1
V_HID_CNT	rs.w	1
CUR_X	rs.w	1
CUR_Y	rs.w	1
CUR_FLAG	rs.b	1
MOUSE_FLAG	rs.b	1
	rs.l	1
V_SAV_X	rs.w	1
V_SAV_Y	rs.w	1
SAVE_LEN	rs.w	1
SAVE_ADR	rs.l	1
SAVE_STAT	rs.w	1
SAVE_AREA	rs.w	128

USER_TIM	rs.l	1
NEXT_TIM	rs.l	1
USER_BUT	rs.l	1
USER_CUR	rs.l	1
USER_MOT	rs.l	1

V_CEL_HT	rs.w	1
V_CEL_MX	rs.w	1
V_CEL_MY	rs.w	1
V_CEL_WR	rs.w	1
V_COL_BG	rs.w	1
V_COL_FG	rs.w	1
V_CUR_AD	rs.l	1
V_CUR_OF	rs.w	1

V_CUR_X	rs.w	1
V_CUR_Y	rs.w	1
V_PERIOD	rs.b	1
V_CUR_CT	rs.b	1

V_FNTAD	rs.l	1
V_FNT_ND	rs.w	1
V_FNT_ST	rs.w	1
V_FNT_WD	rs.w	1
V_REZ_HZ	rs.w	1
V_OFF_AD	rs.l	1
	rs.w	1
V_REZ_VT	rs.w	1
BYTES_LN	rs.w	1
;*********************;
;  Variables systŠme  ;
;*********************;
stv_timer	equ	$400
etv_critic	equ	$404
etv_term	equ	$408
etv_xtra	equ	$40C
memvalid	equ	$420
memctrl	equ	$424
resvalid	equ	$426
resvector	equ	$42a
phystop	equ	$42e
_membot	equ	$432
_memtop	equ	$436
memval2	equ	$43a
flock	equ	$43e
seekrate	equ	$440
_timer_ms	equ	$442
_fverify	equ	$444
_bootdev	equ	$446
palmode	equ	$448
defshiftmd	equ	$44a
sshiftmd	equ	$44c
_v_bas_ad	equ	$44e
vblsem	equ	$452
nvbls	equ	$454
_vblqueue	equ	$456
colorptr	equ	$45a
screenpt	equ	$45e
_vbclock	equ	$462
_frclock	equ	$466
hdv_init	equ	$46a
swv_vec	equ	$46e
hdv_bpb	equ	$472
hdv_rw	equ	$476
hdv_boot	equ	$47a
hdv_mediach	equ	$47e
_cmdload	equ	$482
conterm	equ	$484
themd	equ	$48e
____md	equ	$49e
savptr	equ	$4a2
_nflops	equ	$4a6
con_state	equ	$4a8
save_row	equ	$4ac
sav_context	equ	$4ae
_bufl	equ	$4b2
_hz_200	equ	$4ba
the_env	equ	$4be
_drvbits	equ	$4c2
_dskbufp	equ	$4c6
_autopath	equ	$4ca
_vbl_list	equ	$4ce
_dumpflg	equ	$4ee
_sysbase	equ	$4f2
_shell_p	equ	$4f6
end_os	equ	$4fa
exec_os	equ	$4fe
dump_vec	equ	$502
prt_stat	equ	$506
prt_vec	equ	$50a
aux_stat	equ	$50e
aux_vec	equ	$512
pun_ptr	equ	$516
memval3	equ	$51a
bconstat_vec	equ	$51e
bconin_vec	equ	$53e
bcostat_vec	equ	$55e
bconout_vec	equ	$57e
proc_type	equ	$59e
cookie_jar	equ	$5a0
phystop2	equ	$5a4
memval4	equ	$5a8
prv_clk	equ	$5ac
mouse_vec	equ	$e2e
_timer1	equ	$e4a
_timer2	equ	$e4e
timerc_div	equ	$ea4

__hardsys	equ	-1
	ENDC
