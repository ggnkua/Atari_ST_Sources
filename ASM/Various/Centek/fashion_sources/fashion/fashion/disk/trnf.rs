
		********
		
		; description des structures
		; locales du transformeur...
		
		rsreset

_TX_SPTR	rs.l	1	; adresse bitmap source
_TX_SW		rs.l	1	; largeur source
_TX_SH		rs.l	1	; hauteur source
_TX_SBPP	rs.w	1	; bits/pixel
_TX_SFORM	rs.w	1	; format source

_TX_DPTR	rs.l	1	; adresse bitmap cible
_TX_DW		rs.l	1	; largeur cible
_TX_DH		rs.l	1	; hauteur cible
_TX_DBPP	rs.w	1	; bits/pixel
_TX_DFORM	rs.w	1	; format cible

_TX_SPALOB	rs.l	1	; pointeur sur objet palette source
_TX_DPALOB	rs.l	1	; pointeur sur objet palette destination

_TX_WRKSPC	rs.l	1	; pointeur sur bloc m‚moire de travail
_TX_DIT		rs.w	1	; mode de tramage

_TX_GETNEXT	rs.l	1	; pointe sur la routine de lecture
_TX_PUTNEXT	rs.l	1	; pointe sur la routine d'‚criture

_TX_SLINE	rs.l	1	; adresse buffer de 1 ligne en r/v/b 24 bits
_TX_DLINE	rs.l	1	; adresse buffer de 1 ligne enind‚x‚ (8  bits)

_TX_ICMAP	rs.l	1	; pointeur de palette inverse
_TX_MAGIC	rs.l	1	; pointeur de table magique
_TX_LIMIT	rs.l	1	; pointeur de table d'‚cr‚tage

_TX_SNXTLPTR	rs.l	1	; pointe sur prochaine ligne source
_TX_SNXTLOFF	rs.l	1	; espace entre les d‚buts de 2 lignes source
_TX_DNXTLPTR	rs.l	1	; pointe sur la prochaine ligne destination
_TX_DNXTLOFF	rs.l	1	; espace entre les d‚buts de 2 lignes cible

_TX_XCOUNT	rs.l	1	; compteur horizontal
_TX_YCOUNT	rs.l	1	; compteur vertical

_TX_SCOLNUM	rs.w	1	; nombre d'index dans la palette source
_TX_DCOLNUM	rs.w	1	; nombre d'index dans la palette destination

_TX_PTR1		rs.l	1	; pointeurs … usage multiple
_TX_PTR2		rs.l	1
_TX_PTR3		rs.l	1
_TX_PTR4		rs.l	1
_TX_PTR5		rs.l	1
_TX_PTR6		rs.l	1
_TX_PTR7		rs.l	1
_TX_PTR8		rs.l	1

_TX_SPAL		rs.l	1	; pointeur lut source
_TX_DPAL		rs.l	1	; pointeur lut cible

_TX_VAR1		rs.l	1	; variables suppl‚mentaires
_TX_VAR2		rs.l	1

_TX_SBITOFF	rs.l	1	; offset de plan source (utilis‚ en vdi)
_TX_DBITOFF	rs.l	1	; offset de plan cible (utilis‚ en vdi)

_TX_STATUS	rs.w	1	; code status:
				; -----------------------
				; | bit |   0   |   1   |
				; -----------------------
				; |  0  | norm  | init  |
				; |  1  | norm  | stop  |
				; -----------------------

_TX_PROC		rs.l	1	; pointeur sur routine de tramage/remapping
_TX_SPEED		rs.l	1	; facteur vitesse = nombre max de lignes par appel

_TX_STRUCTSIZE	rs	0

		********
