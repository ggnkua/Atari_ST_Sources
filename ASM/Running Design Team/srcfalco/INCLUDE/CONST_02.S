

true		equ	640

max_play_buffer	equ	126
rgb_play_buffer	equ	124
vga_play_buffer	equ	104
main_vol	equ	64
dma_per_vbl	equ	4

dsp_genauigkeit	equ	8

max_sh_change	equ	24*2
max_sh_fall	equ	32
player_pix_hgt	equ	52

shoot_length_0	equ	48*8

animation_max	equ	48
anim_doors_max	equ	16
anim_lifts_max	equ	8
monsters_max	equ	32
vis_sectors_max	equ	16

foot_time	equ	30

karte_fig_einh	equ	$80
message_time	equ	150

bored_vbl	equ	50*15

per_vga		equ	22000
per_rgb		equ	19500

player_height_1	equ	$60
player_height_2	equ	$10

init_txt_offset	equ	32*2

tsa_time_value	equ	3*50
tsa_anz_value	equ	9

tts_anz		equ	32

;---------------
             
hhc             EQU $FFFF8280
hht             EQU $FFFF8282
hbb             EQU $FFFF8284
hbe             EQU $FFFF8286
hdb             EQU $FFFF8288
hde             EQU $FFFF828A
hss             EQU $FFFF828C
hfs             EQU $FFFF828E
hee             EQU $FFFF8290

vfc             EQU $FFFF82A0
vft             EQU $FFFF82A2
vbb             EQU $FFFF82A4
vbe             EQU $FFFF82A6
vdb             EQU $FFFF82A8
vde             EQU $FFFF82AA
vss             EQU $FFFF82AC

;**************************************

; struktur levelx_data

lev_trains	equ	0
lev_monsters	equ	4
lev_files	equ	8
lev_boden	equ	12
lev_startpoint	equ	16
lev_init_data	equ	20
lev_color_tab	equ	24
lev_pistol	equ	28
lev_initlevel	equ	32
lev_cameras	equ	36
lev_timelimit	equ	40
lev_groesse	equ	44
lev_infos	equ	48
lev_sec_start	equ	52

; struktur level_infos

li_episode	equ	0
li_level	equ	2
li_dsp_genau	equ	4
li_name_ptr	equ	6
li_len_txt_ptr	equ	10
li_lek_txt_ptr	equ	14
li_let_txt_ptr	equ	18
li_leq_txt_ptr	equ	22
li_auftrag_ptr	equ	26
li_file		equ	30

; struktur cameras

cam_sektor	equ	0
cam_sx		equ	2
cam_sy		equ	6
cam_sh		equ	10
cam_alpha_start	equ	14
cam_alpha_end	equ	16

; struktur lvx_init_data

init_dsp_data	equ	0
init_as0	equ	16
init_as1	equ	20
init_as2	equ	24
init_as3	equ	28
init_as4	equ	32
init_vissec_ptr	equ	36
init_needed_tt	equ	40

ias_vbl		equ	0
ias_reichweite	equ	2
ias_anzahl	equ	6
ias_hoehe	equ	8
ias_phasen	equ	10

iasp_textnb	equ	0
iasp_lineflag3	equ	2


; struktur lvx_startpoint

start_x         EQU 0
start_y         EQU 4
start_h         EQU 8
start_alpha     EQU 12
start_sector    EQU 16

; struktur lvx_secx

sec_aktion	equ	0
sec_lines	equ	4
sec_points	equ	8
sec_doors	equ	12
sec_lift	equ	16
sec_things	equ	20
sec_mon_line	equ	24
sec_schalter	equ	28
sec_sect	equ	32
sec_osect	equ	36
sec_ext_lines	equ	40

; struktur sec_things

thing_line      EQU	0
thing_breite    EQU 	20
thing_type      EQU	22
thing_animation	equ	24
thing_vistaken	equ	28
thing_visact	equ	30
thing_sample	equ	32
thing_action    equ	34

; struktur sec_schalter

sch_line	equ	0
sch_breite	equ	28
sch_type	equ	30
sch_loopflag	equ	32
sch_zustand	equ	34
sch_zustand_anz	equ	36
sch_animation	equ	38
sch_vistaken	equ	42
sch_visact	equ	44
sch_sample	equ	46
sch_action_ptr	equ	48

; struktur timelimit

timelimit_flag	equ	0
timelimit_sec	equ	2
timelimit_vbl	equ	4

; struktur animation

animation_anz	equ 0
animation_pos	equ 2
animation_speed	equ 4
animation_count	equ 6
animation_data	equ 8

; struktur pistol

pistol_info	equ	0
pistol_files	equ	4

pistol_sam_sht	equ	0
pistol_sam_rel	equ	2
pistol_hellig	equ	4

pid_off2	equ	0
pid_off3	equ	4
pid_off4	equ	8
pid_length	equ	12
pid_d1		equ	16
pid_d2		equ	24
pid_d3		equ	32
pid_d4		equ	40
pid_data	equ	48

; struktur sec_doors

door_pts        EQU 0
door_line       EQU 32
door_sec        EQU 112
door_op_sec     EQU 168
door_status     EQU 200
door_angle      EQU 202
door_need_thing EQU 204
door_h1         EQU 206
door_h2         EQU 208
door_under      EQU 210
door_otime      EQU 212
door_count      EQU 214
door_auto_clo   EQU 216

; struktur sec_lifts

lift_pts        EQU 0
lift_line       EQU 32
lift_sec_ptr    EQU 112
lift_op_sec     EQU 116
lift_status     EQU 148
lift_need_thing	equ 150
lift_h1         EQU 152
lift_h2         EQU 154
lift_t1         EQU 156
lift_otime      EQU 158
lift_count      EQU 160

; struktur initlevel

ilev_lostthings	equ	0
ilev_munition	equ	4

; struktur lvx_trains

trn_data        EQU 0
trn_move        EQU 4
trn_max_anz     EQU 8

; struktur lvx_monsters

mon_dat         EQU 0
mon_sdat        EQU 4

;---

ml_ptr		equ	0
ml_sektor_von	equ	4
ml_sektor_nach	equ	6

ml_x		equ	0
ml_y		equ	4
ml_sh		equ	9
ml_alpha	equ	11
ml_length	equ	14

;---

mon_line        EQU 0
mon_grafik_typ  EQU 24
mon_walkradflag	equ	26
mon_walking_typ EQU 27
mon_shoot_typ   EQU 28
mon_react_time	equ 30
mon_sec         EQU 32
mon_sec_dir     EQU 34
mon_sec_line    EQU 36
mon_sec_dist    EQU 38
mon_act_radius  EQU 40
mon_walk_dir    EQU 44

mon_former_pos  EQU 46

mon_a_walk      EQU 54
mon_a_walk_pos  EQU 56
mon_a_shoot     EQU 58
mon_a_shoot_pos EQU 60
mon_a_hit       EQU 62
mon_a_died      EQU 64
mon_a_died_pos  EQU 66

mon_health      EQU 68
mon_health_orig EQU 70
mon_shoot_snd   EQU 72
mon_hit_snd     EQU 74
mon_died_snd    EQU 76

mon_staerke	equ	78
mon_sht_actrad	equ	80
mon_sht_time1	equ	82
mon_sht_time2	equ	84
mon_thing_typ	equ	86
mon_zivilist	equ	90
mon_sht_count	equ	92
mon_react_count	equ	94

 ;---

sdat_walk_ptr   EQU 0
sdat_walk_anz   EQU 2
sdat_shoot_ptr  EQU 4
sdat_shoot_anz  EQU 6
sdat_sht_d_ptr  EQU 8
sdat_sht_d_anz  EQU 10
sdat_hit_ptr    EQU 12
sdat_died_ptr   EQU 14
sdat_died_anz   EQU 16
sdat_died_h_ptr EQU 18
sdat_died_h_anz EQU 20
sdat_sdat       EQU 22

;---

tm_pointer_mdat		equ	0
tm_distance		equ	4
tm_abschnitt		equ	6
tm_abschnitt_anz	equ	8
tm_dx			equ	10
tm_dy			equ	12
tm_data_length		equ	14

td_data_length		equ	36*4

mdatc_type		equ	0
mdatc_x			equ	2
mdatc_y			equ	6
mdatc_winkel_start	equ	10
mdatc_winkel_anz	equ	12
mdatc_radius		equ	14
mdatc_winkelgeschw	equ	16

mdat_length		equ	32

mdat_type       EQU 0           ; Typkennzeichnung Linie
mdat_anfang_x   EQU 2
mdat_anfang_y   EQU 6
mdat_rvec_x     EQU 10
mdat_rvec_y     EQU 12
mdat_rvec_len   EQU 14
mdat_rvec_alpha EQU 16
mdat_norm_gesch EQU 18
mdat_anh_flag   EQU 20
mdat_anh_time   EQU 22
mdat_besch_flag EQU 24
mdat_akt_gesch  EQU 26
mdat_verzoeg    EQU 28
mdat_anh_count  EQU 30

;---

sky_zoom        EQU 0
sky_xyoffi      EQU 4
sky_text        EQU 8
sky_and_maske   EQU 12

;---

lf_nb_episode	equ	0
lf_episode_ptr	equ	2

lf_nb_level	equ	0
lf_level_ptr	equ	2

;---

aktion_type	equ	0
aktion_flag	equ	2
aktion_onceflag	equ	4
aktion_visible	equ	6
aktion_mlanz	equ	8
aktion_optarg	equ	10

;**************************************


pd_sx           EQU 0
pd_sy           EQU pd_sx+4
pd_sh           EQU pd_sy+4
pd_sh_real      EQU pd_sh+4
pd_alpha        EQU pd_sh_real+4

pd_player_height EQU pd_alpha+4

pd_as_flag	equ	pd_player_height+4
pd_as_pos	equ	pd_as_flag+4*2
pd_as_count	equ	pd_as_pos+4*2
pd_as_send_flag	equ	pd_as_count+4*2

pd_mun_type	equ	pd_as_send_flag+4*2
pd_mun0_anz	equ	pd_mun_type+2
pd_mun1_anz	equ	pd_mun0_anz+2
pd_mun2_anz	equ	pd_mun1_anz+2
pd_mun3_anz	equ	pd_mun2_anz+2
pd_munx0_anz	equ	pd_mun3_anz+2
pd_munx1_anz	equ	pd_munx0_anz+2
pd_munx2_anz	equ	pd_munx1_anz+2
pd_munx3_anz	equ	pd_munx2_anz+2

pd_last_strafe  EQU pd_munx3_anz+2
pd_last_step    EQU pd_last_strafe+4
pd_last_alpha   EQU pd_last_step+4

pd_width        EQU pd_last_alpha+4
pd_width_last   EQU pd_width+2
pd_heigth       EQU pd_width_last+2
pd_heigth_last  EQU pd_heigth+2
pd_x_flag       EQU pd_heigth_last+2
pd_x_flag_last  EQU pd_x_flag+2
pd_paint_x_offi EQU pd_x_flag_last+2
pd_full_screen  EQU pd_paint_x_offi+2

pd_akt_sector   EQU pd_full_screen+2
pd_wall_anim_sec equ pd_akt_sector+2
pd_last_sector	equ pd_wall_anim_sec+2

pd_a_walk       EQU pd_last_sector+2
pd_a_walk_pos   EQU pd_a_walk+2
pd_a_shoot      EQU pd_a_walk_pos+2
pd_a_shoot_pos  EQU pd_a_shoot+2
pd_a_hit        EQU pd_a_shoot_pos+2
pd_a_died       EQU pd_a_hit+2
pd_a_died_pos   EQU pd_a_died+2
pd_a_died_hard  EQU pd_a_died_pos+2

pd_anim_stufe   EQU pd_a_died_hard+2

pd_fig_number   EQU pd_anim_stufe+2
pd_anim_typ     EQU pd_fig_number+2

pd_control      EQU pd_anim_typ+2

pd_akt_ss_ptr   EQU pd_control+2
pd_in_akt_ss_ptr EQU pd_akt_ss_ptr+4

pd_hat_gesch    EQU pd_in_akt_ss_ptr+4
pd_hat_geschri  EQU pd_hat_gesch+4
pd_getroffen    EQU pd_hat_geschri+2 ; pd_getroffen ist long !!!

pd_train_hit    EQU pd_getroffen+4

;---

pd_things_ptr   EQU pd_train_hit+2

pd_health       EQU pd_things_ptr+4
pd_armor        EQU pd_health+2

pd_invul	equ	pd_armor+2
pd_invis	equ	pd_invul+2

;---

pd_things_pos   EQU pd_invis+2
pd_things_flag  EQU pd_things_pos+2

pd_jump_flag	equ	pd_things_flag+2
pd_jump_pos	equ	pd_jump_flag+2
pd_jump_startsh	equ	pd_jump_pos+2

;---

pd_cursor_flag	equ	pd_jump_startsh+4
pd_killed_flag	equ	pd_cursor_flag+2
pd_quit_flag	equ	pd_killed_flag+2
pd_timeout_flag	equ	pd_quit_flag+2

pd_time_limit1	equ	pd_timeout_flag+2
pd_time_limit2	equ	pd_time_limit1+2
pd_time_limit3	equ	pd_time_limit2+2
pd_time_limit4	equ	pd_time_limit3+2

pd_time_flag	equ	pd_time_limit4+2
pd_time_limit	equ	pd_time_flag+2

pd_episode	equ	pd_time_limit+4
pd_level	equ	pd_episode+2

pd_pistol1	equ	pd_level+2
pd_pistol2	equ	pd_pistol1+2
pd_pistol3	equ	pd_pistol2+2
pd_pistol4	equ	pd_pistol3+2

pd_dsp_exponent	equ	pd_pistol4+2
pd_inter_entf1	equ	pd_dsp_exponent+2
pd_inter_entf2	equ	pd_inter_entf1+4

pd_duke_talk	equ	pd_inter_entf2+4

pd_primary	equ	pd_duke_talk+2
pd_secondary	equ	pd_primary+2

pd_on_terminal	equ	pd_secondary+2
pd_which_end	equ	pd_on_terminal+2

;**************************************

sf_point0	equ	0
sf_point1	equ	12
sf_point2	equ	24
sf_point3	equ	36
sf_point4	equ	48
sf_sh		equ	56
sf_other_sec	equ	58
sf_need_thing	equ	60
sf_need_act	equ	61
sf_need_staerke	equ	62
sf_height	equ	64
sf_energy	equ	66

sf_cluster	equ	68

;**************************************

mnu_yoffset	equ	22

;**************************************


snd_jump	equ	0-128		; ok
snd_footer	equ	1-128		; ok

snd_menue_act	equ	7-128		; ok
snd_menue_deact	equ	8-128		; ok
snd_menue_up	equ	9-128		; ok
snd_menue_down	equ	9-128		; ok
snd_menue_right	equ	10-128		; ok
snd_menue_left	equ	11-128		; ok
snd_menue_enter	equ	12-128		; ok
snd_menue_item	equ	12-128		; ok

snd_sh_higher   EQU 	0-128		; ok
snd_sh_dieper   EQU 	0-128		; ok

snd_door_locked	equ	6-128		; ok
snd_door_open	equ	4-128		; ok
snd_door_close	equ	4-128		; ok
snd_door_rastet	equ	15-128		; ok

snd_lift_locked	equ	6-128		; ok
snd_lift_open   equ	4-128		; ok
snd_lift_close	equ	4-128		; ok
snd_lift_rastet	equ	15-128		; ok

snd_player_hit	equ	34-128		; ok
snd_player_died	equ	35-128		; ok

snd_need_thing	equ	34-128		; ok

snd_item	equ	5-128		; ok
snd_schalter	equ	5-128		; ok

snd_cameraview	equ	7-128		; ok
snd_teleporter	equ	14-128		; ok

snd_schreibm	equ	13-128		; ok


; sprachsamples mit 8 kHz

snd_adrian	equ	20-128
snd_diehard	equ	21-128
snd_hasta	equ	22-128
snd_asses	equ	23-128
snd_bored	equ	24-128
snd_adios	equ	25-128
snd_welldone	equ	26-128
snd_yipi	equ	27-128
snd_dope	equ	28-128
snd_good	equ	29-128
snd_like	equ	30-128
snd_dont	equ	31-128
snd_nice	equ	32-128
snd_check	equ	33-128
snd_ahh		equ	34-128
snd_arghh	equ	35-128
snd_cool	equ	36-128

snd_ubahn	equ	37-128

snd_end1	equ	38-128
snd_end2	equ	39-128

;**************************************

; struktur sam_dat

spl_length	equ	0	; .l
spl_offset	equ	4	; .l
spl_frac	equ	8	; .l
spl_address	equ	12	; .l
spl_info_pos	equ	16
spl_info_vol_l	equ	17
spl_info_vol_r	equ	18
spl_info_loop	equ	19
spl_x		equ	20	; .l
spl_y		equ	24	; .l
spl_speed	equ	28	; .w
spl_voltab	equ	30	; .l
spl_vorkomma	equ	34	; .l
spl_nachkomma	equ	38	; .w
spl_play_offi	equ	40	; .l
spl_voltab_left	equ	44	; .l

spl_dat_length	equ	48


;**************************************


th_static       EQU 0

th_red_key      EQU 1
th_green_key    EQU 2
th_blue_key     EQU 3
th_yellow_key   EQU 4

th_mun0         EQU 5
th_mun1         EQU 6
th_mun2         EQU 7
th_mun3         EQU 8

th_scanner      EQU 9
th_night	equ 10
th_mask		equ 11
th_smedkit_i	equ	12
th_bmedkit_i	equ	13
th_smedkit	equ	14
th_bmedkit	equ	15
th_sarmor	equ	16
th_barmor	equ	17

th_invul	equ	18
th_invis	equ	19

th_pistol1	equ	20
th_pistol2	equ	21
th_pistol3	equ	22
th_pistol4	equ	23

th_radsuit	equ	24
th_geigercount	equ	25
th_jetpack	equ	26
th_backpack	equ	27

th_mondetector	equ	28
th_plan		equ	29

th_mun0_def	equ	30
th_mun1_def	equ	31
th_mun2_def	equ	32
th_mun3_def	equ	33

th_opendoor	equ	34
th_openlift	equ	35
th_closedoor	equ	36
th_closelift	equ	37

th_teleporter	equ	38
th_cameraview	equ	39
th_terminal	equ	40
th_welder	equ	41

th_time_deact	equ	42
th_verseuch	equ	43
th_level_ende	equ	44
th_sample	equ	45

th_littleplan	equ	46
th_neverget	equ	47
th_sftozero	equ	48
th_changevis	equ	49
th_laserdeact	equ	50

th_message	equ	51
th_sprengstoff	equ	52
th_zuender	equ	53

th_primary	equ	54
th_secondary	equ	55

th_geninvul	equ	56
th_geninvis	equ	57

th_color0	equ	58
th_color1	equ	59
th_color2	equ	60
th_color3	equ	61
th_color4	equ	62
th_color5	equ	63
th_color6	equ	64
th_color7	equ	65
th_color	equ	66

th_bierkrug	equ	67
th_trndetector	equ	68

th_dcolor0	equ	69
th_dcolor1	equ	70
th_dcolor2	equ	71
th_dcolor3	equ	72
th_dcolor4	equ	73
th_dcolor5	equ	74
th_dcolor6	equ	75
th_dcolor7	equ	76
th_dcolor	equ	77

th_secchangevis	equ	78
th_burger	equ	79

th_condom	equ	80
th_idcard	equ	81

th_whichend	equ	82

things_max	equ	83


;**************************************

mon_walk_time   EQU 10
mon_hit_time    EQU 20          ; alle angaben in vbl
mon_died_time   EQU 10
mon_shoot_time  EQU 10

;**************************************

; make_terminal

mt_max_spalten	equ	42
mt_max_reihen	equ	22

mt_offset	equ	640*32+81*2
mt_font_heigth	equ	5

;---

; make_laptop

ml_max_spalten	equ	29
ml_max_reihen	equ	16
ml_aufeinmal	equ	10

ml_offset	equ	640*40+106*2
ml_font_heigth	equ	5

;---

; anzahl an aufnehmbarer munition

munx0_beg	equ	75
munx1_beg	equ	50
munx2_beg	equ	30
munx3_beg	equ	20

; anzahl an aufnehmbarer munition mit backpack

munx0_backpack	equ	100
munx1_backpack	equ	80
munx2_backpack	equ	60
munx3_backpack	equ	40

; anzahl munition bei beginn

mun0_beg	equ	50
mun1_beg	equ	20
mun2_beg	equ	10
mun3_beg	equ	5

; anzahl munition fuer things_typen 30 - 33

mun_0_static	equ	10		
mun_1_static	equ	10		
mun_2_static	equ	10		
mun_3_static	equ	10		

;-----------------------

plr_scanner	equ	0
plr_geiger	equ	1


