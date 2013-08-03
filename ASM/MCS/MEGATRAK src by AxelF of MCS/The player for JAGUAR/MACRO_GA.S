;
;
;	STRUCTURES UTILISEES DANS LE JEU
;
;


*-----------------------------------------------------------------------------------------------


; Donn‚es des players 

		offset 0	
pl_posx:	ds.w 1
pl_posy:	ds.w 1
pl_rec:		ds.l 1
pl_pas_inc:	ds.l 1
pl_tempo_anim:	ds.w 1
pl_orientation:	ds.w 1
pl_vie:		ds.w 1
pl_old_vie:	ds.w 1
pl_score:	ds.l 1
pl_ricochet:	ds.l 1
pl_explosion:	ds.l 1
pl_lst_tir:	ds.l 2*10


*-----------------------------------------------------------------------------------------------


; Donn‚es des tirs

		offset 0
dt_cur_tempo_d:	ds.b 1		; tempo actuelle avant nouveau d‚placement
dt_tempo_d:	ds.b 1		; reference tempo deplacement
dt_type_depl:	ds.w 1		; type de deplacement
dt_depl_data1:	ds.l 1		; donn‚es 1 suivant le type de d‚placement
dt_depl_data2:	ds.l 1		; donn‚es 2
dt_x_frac:	ds.l 1		; deplacement fractionnaire en X
dt_y_frac:	ds.l 1		; deplacement fractionnaire en X

dt_cur_tempo_a:	ds.l 1		; tempo actuelle de l'anim
dt_cur_anim:	ds.l 1		; pointeur sur la prochaine anim
dt_anim:	ds.l 1		; reference de l'anim (bouclage)

dt_degat:	ds.l 1		; coefficient de degat 

dt_rx1:		ds.b 1		; offset x1 rectangle de collision 
dt_ry1:		ds.b 1		; offset y1 rectangle de collision 
dt_rx2:		ds.b 1		; offset x2 rectangle de collision 
dt_ry2:		ds.b 1		; offset y2 rectangle de collision 
dt_ricochet:	ds.l 1		; adr. de la structure ricochet		 
dt_explosion:	ds.l 1		; adr. de la structure explosion
dt_size:	ds.w 0


; Definition des tir

		offset 0
st_tempo:	ds.b 1		; tempo cadence du tir
st_tempo_d:	ds.b 1		; tempo deplacement
st_type_d:	ds.w 1		; type de deplacement
st_d_data1:	ds.l 1		; donn‚es 1 deplacement
st_d_data2:	ds.l 1		; donn‚es 2 deplacement

st_anim:	ds.l 1		; str. anim demarrage
st_anim_bcl:	ds.l 1		; str. anim bouclage

st_degat:	ds.l 1		; coeff. degat

st_data:	ds.l 1		; adr sprite
st_width:	ds.w 1		; largeur
st_height:	ds.w 1		; hauteur
st_ofs_x:	ds.w 1		; offset x du tir par rapport au vaisseau
st_ofs_y:	ds.w 1		; offset y
st_index:	ds.l 1		; index couleur

st_rx1:		ds.b 1		; offset x1 rectangle de collision 
st_rx2:		ds.b 1		; offset x2 rectangle de collision 
st_ry1:		ds.b 1		; offset y1 rectangle de collision 
st_ry2:		ds.b 1		; offset y2 rectangle de collision 
st_ricochet:	ds.l 1		; adr. de la structure ricochet		 
st_explosion:	ds.l 1		; adr. de la structure explosion
	


*-----------------------------------------------------------------------------------------------


; Donn‚es ennemis 

		offset 0
dn_cur_tempo_d:	ds.b 1		; tempo actuelle avant nouveau d‚placement
dn_tempo_d:	ds.b 1		; reference tempo deplacement
dn_type_depl:	ds.w 1		; type de deplacement
dn_depl_data1:	ds.l 1		; donn‚es 1 suivant le type de d‚placement
dn_depl_data2:	ds.l 1		; donn‚es 2
dn_x_frac:	ds.l 1		; deplacement fractionnaire en X
dn_y_frac:	ds.l 1		; deplacement fractionnaire en X

dn_cur_anim:	ds.l 1		; tempo actuelle de l'anim	
dn_anim:	ds.l 1		; ptr sur structure anim de depart
dn_anim_bcl:	ds.l 1		; ptr sur structure anim de bouclage

dn_rx1:		ds.b 1		; offset x1 rectangle de collision 
dn_rx2:		ds.b 1		; offset x2 rectangle de collision 
dn_ry1:		ds.b 1		; offset y1 rectangle de collision 
dn_ry2:		ds.b 1		; offset y2 rectangle de collision 
dn_ricochet:	ds.l 1		; adr. de sa structure ricochet		 
dn_explosion:	ds.l 1		; adr. de sa structure explosion		 

dn_vie:		ds.w 1		; vie initiale
dn_degat:	ds.w 1		; coefficient de degat	
dn_score:	ds.w 1		; donn‚es pour le calcul du score 
dn_bonus:	ds.w 1		; si largage d'un bonus apres sa destruction

dn_tempo1:	ds.l 1		; tempo du tir 1		 
dn_deftir1:	ds.l 1		; definition du tir 1 		 
dn_tempo2:	ds.l 1		 
dn_deftir2:	ds.l 1		; ...		 
dn_tempo3:	ds.l 1		 
dn_deftir3:	ds.l 1		 
dn_end_tir:	ds.l 1		; fin liste des tirs 
dn_size:	ds.l 0


; Definition d'un ennemi et de ses tirs associ‚s

		offset 0
sn_tempo:	ds.b 1		; tempo 
sn_tempo_d:	ds.b 1		; tempo de deplacement
sn_type_d:	ds.w 1		; type de deplacement
sn_d_data1:	ds.l 1		; donn‚es 1 de deplacement
sn_d_data2:	ds.l 1		; donn‚es 2 de deplacement
sn_anim:	ds.l 1		; ptr sur structure anim de depart
sn_anim_bcl:	ds.l 1		; ptr sur structure anim de bouclage
sn_data:	ds.l 1		; sprite
sn_width:	ds.w 1		; largeur du sprite
sn_height:	ds.w 1		; Hauteur du sprite
sn_rx1:		ds.b 1		; offset x1 rectangle de collision 
sn_rx2:		ds.b 1		; offset x2 rectangle de collision 
sn_ry1:		ds.b 1		; offset y1 rectangle de collision 
sn_ry2:		ds.b 1		; offset y2 rectangle de collision 
sn_ricochet:	ds.l 1		; adr. de sa structure ricochet		 
sn_explosion:	ds.l 1		 
sn_vie:		ds.w 1		; compteur de vie initial
sn_degat:	ds.w 1		; si un player le touche il perd dn_degat de vie
sn_score:	ds.w 1		; le score allou‚ quand il meurt
sn_bonus:	ds.w 1		; ce qu'il libere
sn_deftir1:	ds.l 2		; definition des tirs ennemis		 
sn_deftir2:	ds.l 2		; et -1 pour fin		 
sn_deftir3:	ds.l 2


*-----------------------------------------------------------------------------------------------


; Donn‚es des bonus

		offset 0
db_cur_tempo_a:	ds.l 1		; tempo actuelle de l'anim
db_cur_anim:	ds.l 1		; pointeur sur la prochaine anim
db_anim:	ds.l 1		; reference de l'anim (bouclage)

db_cur_tempo_d:	ds.b 1		; tempo actuelle avant nouveau d‚placement
db_ref_tempo_d:	ds.b 1		; reference tempo deplacement
db_type_depl:	ds.w 1		; type de deplacement
db_depl_data1:	ds.l 1		; donn‚es 1 suivant le type de d‚placement
db_depl_data2:	ds.l 1		; donn‚es 2
db_x_frac:	ds.l 1		; deplacement fractionnaire en X
db_y_frac:	ds.l 1		; deplacement fractionnaire en X

db_rx1:		ds.b 1		; offset x1 rectangle de collision 
db_ry1:		ds.b 1		; offset y1 rectangle de collision 
db_rx2:		ds.b 1		; offset x2 rectangle de collision 
db_ry2:		ds.b 1		; offset y2 rectangle de collision 
db_size:	ds.w 0


; Definition des bonus

		offset 0
sb_height:	ds.w 1		; hauteur
sb_iwidth:	ds.w 1		; largeur bit
sb_width:	ds.w 1		; largeur pix
sb_index:	ds.w 1		; index couleur

sb_anim:	ds.l 1		; str. anim demarrage
sb_anim_bcl:	ds.l 1		; str. anim bouclage

sb_cur_tempo_d:	ds.b 1		; tempo deplacement
sb_ref_tempo_d:	ds.b 1		; tempo deplacement
sb_type_d:	ds.w 1		; type de deplacement
sb_d_data1:	ds.l 1		; donn‚es 1 deplacement
sb_d_data2:	ds.l 1		; donn‚es 2 deplacement

sb_rx1:		ds.b 1		; offset x1 rectangle de collision 
sb_rx2:		ds.b 1		; offset x2 rectangle de collision 
sb_ry1:		ds.b 1		; offset y1 rectangle de collision 
sb_ry2:		ds.b 1		; offset y2 rectangle de collision 
	



*-----------------------------------------------------------------------------------------------


; donn‚es des objets non collisionnable

		offset 0
de_cur_iter:	ds.l 1

de_cur_tempo_a: ds.l 1
de_ptr_anim:	ds.l 1
de_anim_bcl: 	ds.l 1

de_cur_tempo_d:	ds.b 1		; tempo actuelle avant nouveau d‚placement
de_tempo_d:	ds.b 1		; reference tempo deplacement
de_type_depl:	ds.w 1		; type de deplacement
de_depl_data1:	ds.l 1		; donn‚es 1 suivant le type de d‚placement
de_depl_data2:	ds.l 1		; donn‚es 2
de_x_frac:	ds.l 1		; deplacement fractionnaire en X
de_y_frac:	ds.l 1		; deplacement fractionnaire en X

de_size:	ds.w 0



; Definition des objets non collisionnable 	

		offset 0
se_iter:	ds.l 1		; nb d'iteration de l'anim
se_height:	ds.w 1
se_iwidth:	ds.w 1
se_width:	ds.l 1		
se_ofs_x:	ds.w 1		; offset de centrage 
se_ofs_y:	ds.w 1
se_anim:	ds.l 1		
se_anim_bcl: 	ds.l 1
se_tempo:	ds.b 1		; tempo 
se_tempo_d:	ds.b 1		; tempo de deplacement
se_type_d:	ds.w 1		; type de deplacement
se_depl_data1:	ds.l 1
se_depl_data2:	ds.l 1






