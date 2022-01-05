*-------------------------------------------------------------------------*
*		MENHIR
*-------------------------------------------------------------------------*

		*----------*
		* entˆte commun pour :
		*	*.SYS	;VDI,BORIS
		*	*.BRS	;VIDEO,IKBD,...
		*	*.DEV	;FALCON
		*	*.VDI	;LINES,TEXTES,...
		*	*.DRV	;VIDEL
		*	*.GFX	;REC,VRO,...
		*	*.VID	;SCREEN, MOUSE, ...
		*
		* Si le driver a besoin d'installer un cookie, il
		* se sert de cette description avec comme nom
		* sys_id et comme valeur de cookie, un pointeur
		* sur sys_id.
		*----------*

		RSRESET

sys_id		rs.l	1	;nom de la librairie ou un num‚ro
				; ex: "_VID"
sys_ver		rs.l	1	;version de la librairie
				; ex: 1.0.1 ($101)
sys_date		rs.l	1	;date de la librairie
				; ex: $061997(06/1997)
sys_version	rs.l	1	;pointeur sur un texte de 4 lignes

sys_install	rs.l	1	;routine d'installation du driver

sys_open		rs.l	1	;routine appel‚ pour … chaque ouverture
				;d'une station
sys_close		rs.l	1	;...… la fermeture
				
sys_extend	rs.l	1	;… partir d'ici sont les params
				;sp‚cifiques au driver

		*----------*

*----------------------------------------------------------------------------*
