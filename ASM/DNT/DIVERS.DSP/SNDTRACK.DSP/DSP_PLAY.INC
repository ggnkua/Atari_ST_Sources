*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷D‚finition des structures du tracker÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
	RSRESET
spl_start	rs.l	1	;adresse actuelle du sample.
spl_end	rs.l	1	;offset final du sample.
spl_replen	rs.l	1	;longueur du repeat.
spl_vol	rs.w	1	;volume du sample.
spl_ftune	rs.w	1	;Fine Tune par d‚faut pour le sample

spl_pos	rs.l	1	;position dans le sample.
spl_off	rs.w	1	;offset (9:SampleOffset+=..)
base_freq	rs.w	1	;fr‚quence partition (base des effets)
real_freq	rs.w	1	;fr‚quence actuelle du sample
base_vol	rs.w	1	;volume de base pour les effets
pattlec	rs.w	2	;derniŠre lecture du pattern
instr	rs.w	1	;   "     instrument choisi
freq	rs.w	1	;   "     note choisie
comm	rs.l	1	;   "     commande+le data
port_fin	rs.w	1	;portamento tone:fr‚quence finale
port_sns	rs.b	1	; ""     ""     :sens du slide
port_vit	rs.b	1	; ""     ""     :vitesse du slide
vibr_va	rs.b	1	;vibrato:{vitesse|amplitude}
vibr_off	rs.b	1	;vibrato:offset dans le sinus
trem_va	rs.b	1	;tremolo:{vitesse|amplitude}
trem_off	rs.b	1	;tremolo:offset dans le sinus
vibr_ctrl	rs.b	1	;contr“le de la forme du vibrato
trem_ctrl	rs.b	1	;contr“le du tremolo
glissando	rs.b	1	;pour le glissando (on/off)
funkyou	rs.b	1	;pour le funk repeat
s_offset	rs.b	1	;pour SampleOffset
spl_bal	rs.b	1	;Balance: $00=normal..$40=centre..$7F=inverse
voice_size	rs.b	1

	RSRESET
compteur	rs.w	1		;compteur de VBL
speed	rs.w	1		;vitesse
pat_break0	rs.w	1		;stop pattern,passe au prochain
pat_break1	rs.w	1		;et nouvelle position
pat_break2	rs.w	1		;red‚marre pattern,selon break1
song_pos	rs.w	1		;position actuelle dans partition
song_long	rs.w	1		;longueur partition
song_loop	rs.w	1		;position de bouclage du song
song_base	rs.l	1		;base d'adresse partition
pat_pos	rs.w	1		;idem,mais pour les patterns
pat_adr	rs.l	1		;position,pattern courant,
pat_base	rs.l	1		;base des patterns
pat_delay	rs.b	1		;Delay pour le pattern ?
pat_loop	rs.b	1		;Boucle interne au pattern ?
pat_loopos	rs.w	1		;Point de bouclage (while..)
song_stop	rs.b	1		;Arret total
dma2dsp	rs.b	1		;0={DMA->DSP} / -1={030->DSP}
rundsp	rs.w	1		;Premier envoi ?
master_vol	rs.w	1		;Volume g‚n‚ral.
voice1	rs.b	voice_size		;
voice2	rs.b	voice_size		;datas pour les 4 voix
voice3	rs.b	voice_size		;
voice4	rs.b	voice_size		;
sndtrk_data_size	rs.b	1
ADD_SPL	equ	664+8
