
/* *************************************************** */
/* * Fonction d'extraction d'une chaåne de caractäre * */
/* * avec un dÇlimiteur.                             * */
/* *  21/02/2002 # 21/02/2002                        * */
/* *************************************************** */

VOID get_string( CHAR *pt_textin, CHAR *pt_textout, CHAR *delimiteur )
{

/*	UWORD dummy;*/

/*	sprintf(texte," contenu textin : {%s} ", pt_textin );
	v_gtext(vdihandle,1*8,20*16,texte);
*/

/*	sprintf(texte," contenu textout: {%s} ", pt_textout );
	v_gtext(vdihandle,1*8,21*16,texte);*/

/*	sprintf(texte," contenu delimiteur : {%s} ", delimiteur );
	v_gtext(vdihandle,1*8,22*16,texte);*/

/*	CHAR *pt_txt=pt_textout;*/



/*	dummy=2;*/
	do
	{
		/* on copie la chaåne tant que l'on arrive */
		/* pas sur le dÇlimiteur */

/*		sprintf(texte,"%c-<", *pt_textin );
		v_gtext(vdihandle,(1+dummy)*8,32*16,texte);
		evnt_timer(400);
		dummy++;*/

		if( (*pt_textin!=*delimiteur) && (*pt_textin!=0xD) )
		{
			*pt_textout++ = *pt_textin++;
		}

/*	evnt_timer(400);
	sprintf(texte," contenu textin : {%c} ", *pt_textin );
	v_gtext(vdihandle,1*8,23*16,texte);*/

	} while( (*pt_textin!=*delimiteur) && (*pt_textin!=0xD) );

	*pt_textout=0;


/*	#ifdef LOG_FILE
	sprintf( buf_log, "%s|"CRLF,pt_txt );
	log_print(FALSE);
	#endif*/

}
