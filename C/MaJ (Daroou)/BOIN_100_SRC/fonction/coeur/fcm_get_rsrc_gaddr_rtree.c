/* **[Fonction Coeur]*********** */
/* *                           * */
/* * 21/02/2024 MaJ 22/02/2024 * */
/* ***************************** */



/* Fonction recherchant toutes les adresses des R_TREE et    */
/* R_STRING du RSC. Ceci afin de supprimer tous les appels   */
/* AES rsrc_gaddr() . Le RSC est statique en RAM normalement */


/*
 * Probleme:
 * ----------------------------------------------------------------
 * D'après le Compendium et TOSHYP, rsrc_gaddr() renvoie 1 si
 * l'objet est trouvé, 0 si absent...
 * Le TOS et EmuTOS renvoie toujours 1...
 * MyAES 0.96 a tout bon, 0 en cas d'erreur
 * XaAES 1.6.4b a presque tout bon, 0 en cas d'erreur, mais affiche
 * une saleté d'alerte '[...]rsrc_gaddr : invalid pointer[...]'...
 * mais pourquoi donc ???
 *
 * Solution du jour:
 * ----------------------------------------------------------------
 * Comme le TOS renvoie toujours 1... et que l'on a pas accès à l'arbre
 * des Objets (R_TREE, R_STRING, etc...) a ma connaissance, et je tiens
 * a avoir les adresses des R_xxxx dans un tableau (moins d'appel AES,
 * et parfois une amelioration du code), faut magouiller...
 *
 * Solution 1: Ajouter dans le RSC, pour chaque type d'objet, un objet
 * supplémentaire avec le nom special (LAST_R_TREE, LAST_R_STRING, ...)
 *
 * Solution 2: lire l'entete du RSC et recuperer les valeurs,
 * voir struct RSHDR mt_gem.h (champ nb_xxxxx).
 *
 * J'opte pour la solution 2, ajouter des objets inutiles dans le RSC ne
 * me convient pas. Le header du RSC est récupéré au moment de charger
 * le RSC (Fcm_charge_rsc.c)
 *
 */




/*
 *
 *   R_TREE(0)           Dialogue (G_BOX / G_IBOX)     OBJECT *adr_dialogue => OBJECT *adr_dialogue
 *   R_STRING(5)         Alert / FreeString            OBJECT *adr_dialogue => char *
 *   R_IMAGEDATA(6)      G_IMAGE                       OBJECT *adr_dialogue => ???
 *
 */


void Fcm_get_rsrc_gaddr_rtree( void )
{
	OBJECT *adr_dialogue;
	char   *free_string;
	RSHDR  *rshdr_header;
	int16   index_rtree;
	//int16   erreur;


	FCM_LOG_PRINT(CRLF"* Fcm_get_rsrc_gaddr_rtree"CRLF);


	rshdr_header = (RSHDR *)Fcm_header_rsc;

	//FCM_CONSOLE_ADD2("Fcm_header_rsc %p", Fcm_header_rsc, G_YELLOW );
	//FCM_CONSOLE_ADD2("rshdr_header %p", rshdr_header, G_YELLOW );

	//FCM_CONSOLE_ADD2("sizeof Fcm_header_rsc %ld", sizeof(Fcm_header_rsc), G_CYAN );
	//FCM_CONSOLE_ADD2("Fcm_header_rsc 0 =%d", Fcm_header_rsc[0], G_CYAN );
	//FCM_CONSOLE_ADD2("Fcm_header_rsc 10 =%d", Fcm_header_rsc[10], G_CYAN );

/*
	FCM_CONSOLE_ADD2("rsh_vrsn=%d", rshdr_header->rsh_vrsn, G_CYAN );
	FCM_CONSOLE_ADD2("rsh_nobs=%d", rshdr_header->rsh_nobs, G_CYAN );
	FCM_CONSOLE_ADD2("rsh_ntree=%d", rshdr_header->rsh_ntree, G_CYAN );
	FCM_CONSOLE_ADD2("rsh_nted=%d", rshdr_header->rsh_nted, G_CYAN );
	FCM_CONSOLE_ADD2("rsh_nib=%d", rshdr_header->rsh_nib, G_CYAN );
	FCM_CONSOLE_ADD2("rsh_nbb=%d", rshdr_header->rsh_nbb, G_CYAN );
	FCM_CONSOLE_ADD2("rsh_nstring=%d", rshdr_header->rsh_nstring, G_CYAN );
	FCM_CONSOLE_ADD2("rsh_nimages=%d", rshdr_header->rsh_nimages, G_CYAN );
	FCM_CONSOLE_ADD2("rsh_rssize=%d", rshdr_header->rsh_rssize, G_CYAN );
*/



	//FCM_CONSOLE_ADD("* get R_TREE", G_CYAN );
	//FCM_CONSOLE_ADD2("  %d R_TREE", rshdr_header->rsh_ntree, G_WHITE );

	/* Si le dernier element du tableau n'est pas vide ... */
	if( rshdr_header->rsh_ntree  >  FCM_RSRC_GADDR_RTREE_MAX )
	{
		FCM_CONSOLE_DEBUG("Fcm_get_rsrc_gaddr_rtree() : Tableau Fcm_adr_RTREE[] trop petit");
	}

	for( index_rtree=0; index_rtree < FCM_RSRC_GADDR_RTREE_MAX; index_rtree++ )
	{
		if( index_rtree  <  rshdr_header->rsh_ntree )
		{
			rsrc_gaddr( R_TREE, index_rtree, &adr_dialogue );
//FCM_CONSOLE_DEBUG2("index RTREE=%d  adr_dialogue=%p", index_rtree, adr_dialogue);
			Fcm_adr_RTREE[index_rtree] = adr_dialogue;
		}
		else
		{
			Fcm_adr_RTREE[index_rtree] = (OBJECT *)0L;
		}
	}



	//FCM_CONSOLE_ADD(" ", 0 );
	//FCM_CONSOLE_ADD("* get R_STRING", G_YELLOW );
	//FCM_CONSOLE_ADD2("  %d R_STRING", rshdr_header->rsh_nstring, G_WHITE );

	/* Si le dernier element du tableau n'est pas vide ... */
	if( rshdr_header->rsh_nstring  >  FCM_RSRC_GADDR_RSTRING_MAX )
	{
		FCM_CONSOLE_DEBUG("Fcm_get_rsrc_gaddr_rtree() : Tableau Fcm_adr_RSTRING[] trop petit");
	}

	for( index_rtree=0; index_rtree < FCM_RSRC_GADDR_RSTRING_MAX; index_rtree++ )
	{
		if( index_rtree  <  rshdr_header->rsh_nstring )
		{
//FCM_CONSOLE_DEBUG1("index_rtree=%d ", index_rtree );
			/*erreur = */rsrc_gaddr( R_STRING, index_rtree, &free_string );
			//FCM_CONSOLE_DEBUG1("erreur=%d ", erreur );
//FCM_CONSOLE_DEBUG2("free_string=[%p] {%s}", free_string, free_string );
			Fcm_adr_RSTRING[index_rtree] = free_string;
		}
		else
		{
			Fcm_adr_RSTRING[index_rtree] = (char  *)0L;
		}
	}

	return;

}



/*  bench
	{
		OBJECT *adr_dial;
		int16 index;
		uint32 time;


		FCM_LOG_PRINT( CRLF"* Bench" );

		rsrc_gaddr( R_TREE, DL_INFO_PRG, &adr_dial );

		time=Fcm_get_timer();
		for( index=1000; index >0; index-- )
		{
			rsrc_gaddr( R_TREE, DL_INFO_PRG, &adr_dial );
			sprintf( adr_dial[INFO_PRG_DATE].ob_spec.free_string, "%d", index );
		}
		time=Fcm_get_timer()-time;
		FCM_CONSOLE_DEBUG1("rsrc_gaddr  %ld", time);


		adr_dial=Fcm_adr_RTREE[DL_INFO_PRG];

		time=Fcm_get_timer();
		for( index=1000; index >0; index-- )
		{
			adr_dial=Fcm_adr_RTREE[DL_INFO_PRG];
			sprintf( adr_dial[INFO_PRG_DATE].ob_spec.free_string, "%d", index );
		}
		time=Fcm_get_timer()-time;
		FCM_CONSOLE_DEBUG1("Fcm_adr_RTREE  %ld", time);

	}
*/


	/*
	 * 10.000 boucles 
	 *                        AES    Tableau   sprintf
	 * --------------------------------------------------------------
	 * EmuTOS 0.9.12          475    176       174
	 * STE TOS  2.06          518    176       174
	 *
	 */


/*
	move.l #1000,%d2
	moveq #40,%d5
	add.l %sp,%d5
	lea _sprintf,%a3
.L1135:
	pea _aes_global
	move.l %d5,-(%sp)
	pea 1.w
	clr.l -(%sp)
	jsr (%a4)                 // _mt_rsrc_gaddr
	move.l %d2,-(%sp)
	pea .LC66
	move.l 64(%sp),%a0
	move.l 228(%a0),-(%sp)
	jsr (%a3)                 // sprintf
	subq.l #1,%d2
	lea (28,%sp),%sp
	jne .L1135

[...]

	move.w #1000,%a4
.L1136:
	move.l _Fcm_adr_RTREE+4,%a0  // tableau
	move.l %a0,40(%sp)
	move.l %a4,-(%sp)
	pea .LC66
	move.l 228(%a0),-(%sp)
	jsr (%a3)                // sprintf
	subq.l #1,%a4
	lea (12,%sp),%sp
	cmp.w #0,%a4
	jne .L1136
*/

