;*********************************************************************;
;*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*;
;*~            D‚finition des diff‚rents registres Hard             ~*;
;*~                      des STF/STE/MegaST                         ~*;
;*~                ainsi que des variables systŠmes                 ~*;
;*~                         principales                             ~*;
;*~                                                                 ~*;
;*~                         (c)NulloS 91                            ~*;
;*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*;
;*********************************************************************;



;*********************;
;   Registres vid‚o   ;
;*********************;
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
pcm_mode	equ	$0

spl_starth	equ	$2
spl_startm	equ	$4
spl_startl	equ	$6

spl_counth	equ	$8
spl_countm	equ	$a
spl_countl	equ	$c

spl_endh	equ	$e
spl_endm	equ	$10
spl_endl	equ	$12

pcm_ctrl	equ	$20

mcw_data	equ	$22
mcw_ctrl	equ	$24
mcw_mask	equ	$24

mcw_pmask	equ	$7ff		;mask … envoyer au MicroWire

master_vol	equ	$4c0		;ctrl … envoyer au MicroWire
left_vol	equ	$540
right_vol	equ	$500
treble	equ	$480
bass	equ	$440
pcm_mix	equ	$400

Khz6	equ	0
Khz12	equ	1
Khz25	equ	2
Khz50	equ	3

mono	equ	128
stereo	equ	0

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
;  Variables systŠme  ;
;*********************;
stv_timer	equ	$400
etv_critic	equ	$404
etv_term	equ	$408
etv_xtra	equ	$40C
memvalid	equ	$420
memctrl	equ	$424
revalid	equ	$426
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
prv_clk	equ	$5ac
mouse_vec	equ	$e2e
_timer1	equ	$e4a
_timer2	equ	$e4e
timerc_div	equ	$ea4

