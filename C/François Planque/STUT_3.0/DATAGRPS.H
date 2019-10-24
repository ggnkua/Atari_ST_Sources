/*
 * DataGroups.h
 *
 * Purpose:
 * --------
 * Interface publique pour DATAGROUPS
 *
 * History:
 * --------
 * 02.10.94: fplanque: Created
 */



/*
 * ----------------------- OPERATIONS PUBLIQUES -------------------------
 */

	BOOL	DataGrp_Reset(						/* Out: != FALSE si on a effectu‚ le reset */
			DATAGROUP *	pDataGroup );	/* In:  DataGroup */

	int	sauve_DataGroup(  						/* Out: Indique si la sauvegarde s'est correctement effectuée */
				DATAGROUP	*curr_datagroup );	/* In: DATAGROUP … s‚rialiser */

	SSTATE 	dataGroup_getSavState( 			/* Out: SSTATE correspondant */
									DATAGROUP *datagroup );	/* In: DATAGROUP qui nous int‚resse */

	/*
	 * Etat de sauvegarde de l'ensemble du serveur:
	 */
	SSTATE	get_ServSState( void ); 	/* Out: SSTATE global...*/


	void	DataGroups_SaveAll( void );

	void dataGroup_setSaved(
			DATAGROUP	*	pDataGroup );	/* In: Datagroup qui a ‚t‚ sauv‚ */


	int	DataGrp_MergeFile( 
			DATAGROUP *curr_datagroup );	/* In: DATAGROUP ds lequel on veut charger */



	void	update_datagroup_info( 			/* Out: */
			DATAGROUP *curr_datagroup, /* In: Datagroup ds lequel on a charg‚ */
			int memo );     				/* In: !=0 s'il faut m‚moriser le nom du fichier qui vient d'ˆtre charg‚ pour sauvegarde ult‚rieure */

	void	update_datagroup_filename( 
			DATAGROUP *datagroup );		/* In: Datagroup concern‚ */


	void	group_directload( 
			DATAGROUP *curr_datagroup, /* In: DATAGROUP ds lequel on veut charger */
			int file_type,            	/* In: Type de fichier … charger */
			char *file_access );			/* In: Chemin d'accŠs au fichier */


	void	initialiser( void );

	void	init_serv( void );

	int	efface_datas(   						/* Out Reporte si on a effac‚ ou pas */
			DATAGROUP	*curr_datagroup );	/* In: DATAGROUP … effacer */

	void	init_vars_datagroup( 
			DATAGROUP *datagroup );		/* In: DATAGROUP … initialiser */
