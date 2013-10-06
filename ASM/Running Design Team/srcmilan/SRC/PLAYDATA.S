
		rsreset
PDSX		rs.l	1		;equ	0		; .l
PDSY		rs.l	1		;equ	PDSX+4		; .l
PDSH		rs.w	1		;equ	PDSY+4		; .w
PDSHREAL	rs.w	1		;equ	PDSH+2		; .w
PDALPHA		rs.w	1		;equ	PDSHREAL+2	; .w

PDPLAYERHEIGHT	rs.w	1		;equ	PDALPHA+2	; .w

PDCURRENTSECTOR	rs.w	1		;equ	PDPLAYERHEIGHT+2
PDLASTSECTOR	rs.w	1		;equ	PDCURRENTSECTOR+2

PDHASSHOT	rs.w	1		;equ	PDLASTSECTOR+2

PDRUNMODE	rs.w	1		;equ	PDHASSHOT+2
PDHASMOVED	rs.w	1		;equ	PDRUNMODE+2
PDHASTURNED	rs.w	1		;equ	PDHASMOVED+2

PDLASTSTEP	rs.l	1		;equ	PDHASTURNED+2
PDLASTSTRAFE	rs.l	1		;equ	PDLASTSTEP+4
PDLASTALPHA	rs.l	1		;equ	PDLASTSTRAFE+4

PDTESTSX	rs.l	1		;equ	PDLASTALPHA+4
PDTESTSY	rs.l	1		;equ	PDTESTSX+4

PDJUMPFLAG	rs.w	1		;equ	PDTESTSY+4
PDJUMPPOS	rs.w	1		;equ	PDJUMPFLAG+2
PDJUMPSTARTSH	rs.w	1		;equ	PDJUMPPOS+2

PDINTERDIST1	rs.l	1		;equ	PDJUMPSTARTSH+2
PDINTERDIST2	rs.l	1		;equ	PDINTERDIST1+4
PDDSPEXPONENT	rs.w	1		;equ	PDINTERDIST2+4

; waffenverwaltung
PDMUNTYPE	rs.w	1		; aktuelle waffe
PDPISTOL0	rs.w	1		; flags, ob jeweilige waffen vorhanden sind
PDPISTOL1	rs.w	1
PDPISTOL2	rs.w	1
PDPISTOL3	rs.w	1
PDPISTOL4	rs.w	1
PDPISTOL5	rs.w	1
PDPISTOL6	rs.w	1
PDPISTOL7	rs.w	1
PDPISTOL8	rs.w	1
PDPISTOL9	rs.w	1
PDMUN0ANZ	rs.w	1		; anzahl an jeweiliger munition
PDMUN1ANZ	rs.w	1
PDMUN2ANZ	rs.w	1
PDMUN3ANZ	rs.w	1
PDMUN4ANZ	rs.w	1
PDMUN5ANZ	rs.w	1
PDMUN6ANZ	rs.w	1
PDMUN7ANZ	rs.w	1
PDMUN8ANZ	rs.w	1
PDMUN9ANZ	rs.w	1
PDMUNX0ANZ	rs.w	1		; maximalanzahl jeweils moeglicher munition
PDMUNX1ANZ	rs.w	1
PDMUNX2ANZ	rs.w	1
PDMUNX3ANZ	rs.w	1
PDMUNX4ANZ	rs.w	1
PDMUNX5ANZ	rs.w	1
PDMUNX6ANZ	rs.w	1
PDMUNX7ANZ	rs.w	1
PDMUNX8ANZ	rs.w	1
PDMUNX9ANZ	rs.w	1

PDCURRENTITEM	rs.w	1

PDTIMELIMIT1	rs.w	1		;equ	PDMUNX9ANZ+2
PDTIMELIMIT2	rs.w	1		;equ	PDTIMELIMIT1+2
PDTIMELIMIT3	rs.w	1		;equ	PDTIMELIMIT2+2
PDTIMELIMIT4	rs.w	1		;equ	PDTIMELIMIT3+2
PDTIMEFLAG	rs.w	1		;equ	PDTIMELIMIT4+2
PDTIMELIMIT	rs.w	1		;equ	PDTIMEFLAG+2

PDCURSORFLAG	rs.w	1		;equ	PDTIMELIMIT+2

PDKILLEDFLAG	rs.w	1		;equ	PDCURSORFLAG+2
PDQUITFLAG	rs.w	1		;equ	PDKILLEDFLAG+2
PDTIMEOUTFLAG	rs.w	1		;equ	PDQUITFLAG+2

PDHEALTH	rs.w	1		; [0..100] * 256
PDARMOR		rs.w	1		; [0..100] * 256

PDINVUL		rs.w	1
PDINVIS		rs.w	1

PDPRIMARY	rs.w	1		;equ	PDINVIS+2
PDSECONDARY	rs.w	1		;equ	PDPRIMARY+2

PDONTERMINAL	rs.w	1		;equ	PDSECONDARY+2
PDWHICHEND	rs.w	1		;equ	PDONTERMINAL+2

PDCURRENTSFPTR	rs.l	1		;equ	PDTHINGSPOS+2
PDPROVISSFPTR	rs.l	1		;equ	PDCURRENTSFPTR+4

PDMAPZOOM	rs.w	1		;equ	PDPROVISSFPTR+4


PDBYTES		rs.w	1		;equ	6000





;pd_as_flag	equ	PDPLAYERHEIGHT+4
;pd_as_pos	equ	pd_as_flag+4*2
;pd_as_count	equ	pd_as_pos+4*2
;pd_as_send_flag	equ	pd_as_count+4*2



;pd_width        EQU pd_last_alpha+4
;pd_width_last   EQU pd_width+2
;pd_heigth       EQU pd_width_last+2
;pd_heigth_last  EQU pd_heigth+2
;pd_x_flag       EQU pd_heigth_last+2
;pd_x_flag_last  EQU pd_x_flag+2
;pd_paint_x_offi EQU pd_x_flag_last+2
;pd_full_screen  EQU pd_paint_x_offi+2
;
;
;pd_wall_anim_sec equ PDLASTSECTOR+2
;
;pd_a_walk       EQU pd_wall_anim_sec+2
;pd_a_walk_pos   EQU pd_a_walk+2
;pd_a_shoot      EQU pd_a_walk_pos+2
;pd_a_shoot_pos  EQU pd_a_shoot+2
;pd_a_hit        EQU pd_a_shoot_pos+2
;pd_a_died       EQU pd_a_hit+2
;pd_a_died_pos   EQU pd_a_died+2
;pd_a_died_hard  EQU pd_a_died_pos+2
;
;pd_anim_stufe   EQU pd_a_died_hard+2
;
;pd_fig_number   EQU pd_anim_stufe+2
;pd_anim_typ     EQU pd_fig_number+2
;
;pd_control      EQU pd_anim_typ+2
;
;
;pd_hat_gesch    EQU pd_in_akt_ss_ptr+4
;pd_hat_geschri  EQU pd_hat_gesch+4
;pd_getroffen    EQU pd_hat_geschri+2 ; pd_getroffen ist long !!!
;
;pd_train_hit    EQU pd_getroffen+4
;
;;---
;
;pd_things_ptr   EQU pd_train_hit+2
;
;
;
;;---
;
;
;
;;---
;
;



;
;pd_duke_talk	equ	pd_inter_entf2+4
;


		data

playerDataPtr	dc.l	playerData
