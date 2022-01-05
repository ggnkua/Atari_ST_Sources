*-------------------------------------------------------------------------*
*		STRUCTURE DU XBIOS VIDEO
*-------------------------------------------------------------------------*

		*----------*
		* Variables principale de VIDEO.BRS
		* retourn‚ par Dol_VarsLib
		
		RSRESET

vid_maj_vars	rs.l	1	;pointeur sur les variables principales
vid_cur_vars	rs.l	1	;pointeur sur les variables courantes

vid_shut_down	rs.l	1	;routine d'extinction
vid_wake_up	rs.l	1	;routine de reveil

		*----------*

*-------------------------------------------------------------------------*

		*-------------*
		* VARIABLES COURANTES
		*-------------*

		RSRESET

vid_BUG_DAT	rs.b	1	;erreur de chargement du DAT
vid_new_dat	rs.b	1	;indique si cfg_param pointe sur
vid_OK_VBL	rs.b	1	;valide la VBL
vid_OK_TIMERC	rs.b	1	;valide le TIMERC

vid_monitor	rs.w	1	;type de moniteur connect‚
vid_pal		rs.w	1	;flag pal/ntsc

vid_xbios_mode	rs.w	1	;mode vid‚o systŠme (sans params ‚tendus)
vid_cur_mode	rs.w	1	;mode vid‚o courant

vid_multisync	rs.b	1	;autorise le changement de type d'‚cran
vid_size_comp	rs.b	1	;flag de compatibilit‚: renvoie
				; la taille de l'‚cran par d‚faut
				; au lieu d'attendre un mode code
				; ‚tendu (bit 15 uniquement)

vid_phys_chg	rs.b	1	;flag indiquant qu'une partie de la vid‚o
vid_log_chg	rs.b	1	;a ‚t‚ chang‚e. Utilis‚ par les modules
vid_vid_chg	rs.b	1	;appel‚s et d‚sactiv‚ ensuite.
vid_vdi_chg	rs.b	1	;flag indiquant que la VDI doit etre

vid_col_chg	rs.b	1	;flag pour le changement de palette
vid_palst		rs.b	1	;flag indiquant que l'on est en pal st
		
vid_BIG_FLAG	rs.b	1	;flag indiquant le mode virtuel
vid_SCROLL	rs.b	1	;il faut scroler...
vid_newpos	rs.b	1	;nouvelle coordonn‚e … prendre en compte
vid_freeze	rs.b	1	;interdit … la souris d'agir sur l'‚cran

vid_scroll_mth	rs.w	1	;methode de scrolling de 0 … 2
vid_ECO_FLAG	rs.b	1	;mode ECO actif
		rs.b	1	;r‚serv‚(0)

vid_NIGHT_FLAG	rs.b	1	;flag indiquant que l'‚cran est ‚teint
vid_ENERGY_FLAG	rs.b	1	;ENERGY STAR actif
vid_eco2_extinction	rs.b	1	;passage vers le mode energy star
vid_eco2_night_flag	rs.b	1	;‚cran ‚teint sous energy star

vid_eco_delay	rs.l	1	;dur‚e de l'ECO en 50Š de seconde
vid_eco2_delay	rs.l	1	;d‚lai avant le passage
vid_eco_counter	rs.l	1	;compteur ECO 

*-------------------------------------------------------------------------*

		*-------------*
		* VARIABLES PRINCIPALES
		*-------------*

		RSRESET

vid_dat_adr	rs.l	1	;adresse de chargement du DAT
vid_dat_len	rs.l	1	;taille du DAT
vid_dat_len_MAX	rs.l	1	;taille maximum que le DAT pourra
				; occuper avant de red‚marrer
vid_cfg_adr	rs.l	1	;pointeur sur la liste des r‚sols
max_handle	rs.w	1	;nombre maxi de handle

		*-------------*

vid_cfg_param	rs.l	1	;pointeur sur le mode en cours (0 sinon)

vid_screen_param	rs.l	1	;pointeur sur les params ‚cran
vid_videl_param	rs.l	1	;pointeur sur les params VIDEL

vid_phys_adr	rs.l	1	;adresse physique
vid_log_adr	rs.l	1	:adresse logique

		*-------------*
		
vid_handle	rs.w	1	;handle du mode vid‚o

vid_phys_w	rs.w	1	;largeur phys
vid_phys_h	rs.w	1	;hauteur phys
vid_plan		rs.w	1	;nb de plan
vid_log_w		rs.w	1	;largeur virtuelle (valeur effective)
vid_log_h		rs.w	1	;hauteur virtuelle (valeur effective)
vid_wsize		rs.w	1	;largeur en mm
vid_hsize		rs.w	1	;hauteur en mm

vid_scrn_size	rs.l	1	;taille de l'‚cran en cours
		
		*-------------*

vid_newx		rs.w	1	;nouveau x
vid_newy		rs.w	1	;nouveau y

		*-------------*

*-------------------------------------------------------------------------*

		*-------------*
		* Description du nouveau fichier .DAT
		*  pour les modes ‚tendues
		*-------------*
		* Les modes sont rep‚r‚s par une table de pointeur
		* pour les r‚f‚rencer par handle
		*-------------*

		* Adresses hardware
		
_HHT		EQU	$FFFF8282
_HBB		EQU	$FFFF8284
_HBE		EQU	$FFFF8286
_HDB		EQU	$FFFF8288
_HDE		EQU	$FFFF828A
_HSS		EQU	$FFFF828C
_HFS		EQU	$FFFF828E
_HEE		EQU	$FFFF8290

_VFC		EQU	$FFFF82A0
_VFT		EQU	$FFFF82A2
_VBB		EQU	$FFFF82A4
_VBE		EQU	$FFFF82A6
_VDB		EQU	$FFFF82A8
_VDE		EQU	$FFFF82AA
_VSS		EQU	$FFFF82AC

_VCO		EQU	$FFFF82C0
_VMODE		EQU	$FFFF82C2

_SYNC		EQU	$FFFF820A
_OFFSET		EQU	$FFFF820E
_VWRAP		EQU	$FFFF8210

_SHIFT		EQU	$FFFF8260
_SPSHIFT		EQU	$ffff8266

_HSR		EQU	$FFFF8265

		* num‚ro des bits du mot de code vid‚o
		
flag_80c		EQU	3
flag_vga		EQU	4
flag_pal		EQU	5
flag_over		EQU	6
flag_st		EQU	7
flag_vert		EQU	8
flag_eco2		EQU	9
flag_eco		EQU	10
flag_virt		EQU	11
flag_extclk	EQU	12
flag_ext		EQU	13
flag_std		EQU	14
flag_set		EQU	15

		* masques pour op‚rations logiques
			;FSOPV8NNN
_cols		equ	%000000111
_80c		equ	%000001000
_vga		equ	%000010000
_pal		equ	%000100000
_over		equ	%001000000
_st		equ	%010000000
_vert		equ	%100000000
_eco2		equ	%1000000000
_eco		equ	%10000000000
_virt		equ	%100000000000
_extclk		equ	%1000000000000
_ext		equ	%10000000000000
_std		equ	%100000000000000
_set		equ	%1000000000000000

			;FSOPV8NNN
_setmod		equ	%110111111
_setvga		equ	%110011111
_setrgb		equ	%110101111
_setext		equ	$fe00
_setopt		equ	_set+_eco+_eco2+_virt

		*-------------*
		* struture du DAT
		*-------------*

dat_version	equ	$110	;version du fichier .dat
		
		*-------------*
		* header
		
		RSRESET
dat_id		rs.l	1	;nom du fichier "VDAT"
dat_ver		rs.w	1	;version du format
dat_head		rs.w	1	;offset jusqu'au premier mode
				;cette offset pourra changer de
				; valeur et valoir plus ou moins
				; suivant les versions

dat_multisync	rs.b	1	;utilisation d'un moniteur multisynchro
				;pour passer du TV au VGa et vice-versa
dat_size_comp	rs.b	1	;flag de compatibilit‚: renvoie
				; la taille de l'‚cran par d‚faut
				; au lieu d'attendre un mode code
				; ‚tendu (bit 15 uniquement)
dat_scroll	rs.b	1	;m‚thode de scrolling (3 m‚thodes)
				
				; les flags qui suit ne servent que sous
				; CENTscreen et ne peuvent ˆtre pris
				; en compte sous la Vid‚o de Dolmen.
dat_kbd_on	rs.b	1	;flag activant le reveil au clavier

dat_midi_on	rs.b	1	;idem pour le midi
dat_mouse_on	rs.b	1	;idem pour la souris
dat_joy_on	rs.b	1	;idem_pour les joysticks
dat_tst_eco	rs.b	1	;combinaison de touches pour activer
				;l'‚conomiseur

dat_turbo_on	rs.b	1	;valide le turbo de la souris

dat_turbo_speed	rs.b	1	;vitesse du turbo
				;0: Casimir (comptatibilit‚)
				;1: tortue
				;2: casimir
				;3: liŠvre
dat_conf_end	rs.l	0
		rs.b	128-(dat_conf_end-dat_id)
				;header fix‚ … 128 octets (1.1)
		
		
dat_modes		rs.l	0	;fin du header...

		*-------------*
		* header d'un mode
		
		RSRESET
dat_offset	rs.w	1	;offset au prochain mode
dat_datas		rs.l	0	;datas du modes vid‚o

		*-------------*
		* Description d'un mode vid‚o
		* VERSION 1.1
		
		RSRESET
dat_mode		rs.w	1	;mode code xxxx xxxF SOPV 8NNN
				; STANDARD:
				; bit 0 … 2: NNN (nombre de plan)
				;	0->monochrome
				;	1-> 2 plans
				;	2-> 4 plans
				;	3-> 8 plans
				;	4-> 16 plans (Near True Color)
				; bit 3: Flag 80 colonnes (8)
				; bit 4: Flag VGA (V)
				; bit 5: Flag Pal (P)
				; bit 6: Flag overscan (O)
				; bit 7: Flag ST compatible (S)
				; bit 8: Flag Vertical (F)
				; ETENDU:
				; bit 9: mode energy star actif ou non
				; bit 10: ‚conomiseur actif ou non
				; bit 11: ‚cran virtuel actif ou non
				; bit 12: horloge externe 32/36MHz (CT2)
				;         ne sert plus sur rev B
				; bit 13: validation de l'horloge externe
				; bit 14: r‚solution standard
				;	(non effacable mais modifiable)
				; bit 15: mode vid‚o par d‚faut

dat_physx		rs.w	1	;r‚solution x r‚elle
dat_physy		rs.w	1	;r‚solution y r‚elle
dat_plan		rs.w	1	;nombre de plan
dat_logx		rs.w	1	;r‚solution x virtuelle
dat_logy		rs.w	1	;r‚solution y virtuelle

dat_eco_delay	rs.w	1	;temps en seconde de l'‚conomiseur
dat_eco2_delay	rs.w	1	;temps en seconde du retard avant
				;l'Energy Star

dat_wsize		rs.w	1	;largeur en mm de l'‚cran (1.1)
dat_hsize		rs.w	1	;hauteur en mm de l'‚cran (1.1)
dat_vars_end	rs.l	0

		* registres VIDEL
		*  ordre imperatif pour SPSHIFT,SHIFT et VMODE

		RSSET	64-2
dat_videl		rs.l	0
dat_SPSHIFT	rs.w	1	;...
dat_shift_write	rs.b	1	;valide l'‚criture dans SHIFT
dat_SHIFT		rs.b	1	;... : uniquement en 2 plans(4 couleurs)!!!!
				; et ST Basse
dat_VCO		rs.w	1	;...
dat_VMODE		rs.w	1	;...
dat_Hxx		rs.w	8	;...
dat_Vxx		rs.w	6	;...

dat_regs_end	rs.l	0
		
		RSSET	128-2
dat_name		rs.l	0	;commentaire de taille variable
				; termin‚ par un 0 et align‚ sur
				; un mot … la fin pour le mode suivant.
				; 63 caractŠres+1 null
		RSSET	192-2
dat_maxlength	rs.l	0	;taille maxi d'un mode vid‚o

		*-------------*


*-------------------------------------------------------------------------*

		*-------------------*
		* Structure des paramŠtres utilis‚s dans les fonctions
		* Xbios Vcreate et Vread.
		*-------------------*
		
		RSRESET
V_hdl		rs.w	1	;handle du mode vid‚o

V_mode		rs.w	1	;mode vid‚o flacon

V_physx		rs.w	1	;largeur physique
V_physy		rs.w	1	;hauteur physique
V_plan		rs.w	1	;nombre de plan
V_logx		rs.w	1	;largeur virtuelle
V_logy		rs.w	1	;hauteur virtuelle
V_eco		rs.w	1	;d‚lai de l'‚conomiseur
V_eco2		rs.w	1	;d‚lai pour l'energy star
V_wsize		rs.w	1	;largeur en mm de l'‚cran (1.1)
V_hsize		rs.w	1	;hauteur en mm de l'‚cran (1.1)

V_vars_end	rs.l	0
		
		RSSET	64
V_name		rs.l	0	;nom du mode
		
		RSSET	128
V_length		rs.l	0	;taille du buffer (128 octets)

*-------------------------------------------------------------------------*
