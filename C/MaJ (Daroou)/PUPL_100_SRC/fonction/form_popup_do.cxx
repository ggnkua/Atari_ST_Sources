


LONG form_popup_do( CHAR *tab[], ULONG nb_element, ULONG pop_select, LONG pop_x, LONG pop_y, ULONG pop_w )
{
	OBJECT *adr_formulaire;
	ULONG	position;
	WORD	objet,old_objet;
	WORD	x,y;
	WORD	event,bouton;
	UWORD	dummy;




	/* Petite v‚rification ... */
	if( pop_select>=nb_element)
	{
		pop_select=0;
	}


/*	sprintf(texte,"largeur Pop=%ld , select=%ld", pop_w, pop_select );
	v_gtext(vdihandle,1*8,2*16,texte);
	sprintf(texte,"Pop x=%ld , pop y=%ld", pop_x, pop_y );
	v_gtext(vdihandle,1*8,3*16,texte);*/

/*	for( dummy=0; dummy<nb_element; dummy++)
	{
		sprintf(texte,"[%d] {%s} ", dummy, tab[dummy] );
		v_gtext(vdihandle,1*8,(3+dummy)*16,texte);
	}*/







	/* adresse du formulaire PopUp */
	rsrc_gaddr( R_TREE, FORM_POPUP, &adr_formulaire );



	/* Nombre d'‚l‚ment ? */
	if( nb_element < (POPUP_LIGNE20-POPUP_LIGNE01+1+1) )
	{
		/* on cache le slider */
		SET_BIT( (adr_formulaire+POP_SLIDEBOX)->ob_flags, OF_HIDETREE, 1);
		adr_formulaire->ob_width = pop_w;

		for( dummy=POPUP_LIGNE01; dummy<=(POPUP_LIGNE01+nb_element); dummy++)
		{
			SET_BIT( (adr_formulaire+dummy)->ob_flags, OF_HIDETREE, 0);
			SET_BIT( (adr_formulaire+dummy)->ob_state, OS_SELECTED, 0);
		}

		for( dummy=POPUP_LIGNE01+nb_element; dummy<=POPUP_LIGNE20; dummy++)
		{
			SET_BIT( (adr_formulaire+dummy)->ob_flags, OF_HIDETREE, 1);
		}

		adr_formulaire->ob_height = (adr_formulaire+nb_element+POPUP_LIGNE01)->ob_y+2;
		(adr_formulaire+POP_FOND_TEXTE)->ob_height = (adr_formulaire+nb_element+POPUP_LIGNE01)->ob_y+1;

	}
	else
	{
		/* on affiche le slider */
		SET_BIT( (adr_formulaire+POP_SLIDEBOX)->ob_flags, OF_HIDETREE, 0);
		adr_formulaire->ob_width = pop_w+(adr_formulaire+POP_SLIDEBOX)->ob_width;
		(adr_formulaire+POP_SLIDEBOX)->ob_x=pop_w+1;
		(adr_formulaire+POP_SLIDEBOX)->ob_y=0;
	}


	for( dummy=0; dummy<=(POPUP_LIGNE20-POPUP_LIGNE01); dummy++)
	{
		if( dummy<nb_element )
		{
			sprintf( (adr_formulaire+POPUP_LIGNE01+dummy)->ob_spec.tedinfo->te_ptext, "  %s", tab[dummy] );
			(adr_formulaire+POPUP_LIGNE01+dummy)->ob_width = pop_w-2;

			if( dummy==pop_select )
			{
				SET_BIT( (adr_formulaire+POPUP_LIGNE01+dummy)->ob_state, OS_CHECKED, 1);
			}
			else
			{
				SET_BIT( (adr_formulaire+POPUP_LIGNE01+dummy)->ob_state, OS_CHECKED, 0);
			}
		}
	}


/*	for( dummy=POPUP_LIGNE01; dummy<=POPUP_LIGNE20; dummy++)
	{
		sprintf( (adr_formulaire+dummy)->ob_spec.tedinfo->te_ptext, "  %4d", dummy );
		(adr_formulaire+dummy)->ob_width = pop_w;
	}*/

	/* Positionnement sur l'axe horizontale (x) */
	position=MAX( 1, pop_x );
	position=MIN( (LONG)position, (w_desktop-adr_formulaire->ob_width-2) );
	adr_formulaire->ob_x = position;

	/* Positionnement sur l'axe verticale (y) */
	pop_y=pop_y-(adr_formulaire+POPUP_LIGNE01+pop_select)->ob_y;
	position=MAX( (y_desktop+1), pop_y );
	position=MIN( (LONG)position, (y_desktop+h_desktop-adr_formulaire->ob_height-2) );
	adr_formulaire->ob_y = position;


	(adr_formulaire+POP_FOND_TEXTE)->ob_width = pop_w;




	wind_update(BEG_UPDATE);
	wind_update(BEG_MCTRL);


	form_dial(0, 0,0,0,0, adr_formulaire->ob_x-2, adr_formulaire->ob_y-2, adr_formulaire->ob_width+8, adr_formulaire->ob_height+8 );

   	v_hide_c( vdihandle );


	/* on demande … l'AES de tracer le formulaire */
	objc_draw( adr_formulaire, 0, 4, x_desktop, y_desktop, w_desktop, h_desktop);



	v_show_c(vdihandle,TRUE);

	no_mouse_bouton();



	/* aucune ligne de s‚lectionn‚ dans le PopUp */
	old_objet=0;


	do
	{

		event=evnt_multi(MU_BUTTON|MU_TIMER,EVENT_BCLICK,3,0,
						0,0,0,0,0,
						0,0,0,0,0,
						buffer_aes,50,
						&souris.g_x,&souris.g_y,&bouton,&dummy,
						&dummy,&dummy);

		objet=objc_find( adr_formulaire, 0 , 4, souris.g_x, souris.g_y);

/*		sprintf(texte,"Objet = %d old_objet=%d  bouton=%d  ",objet, old_objet, bouton );
		v_gtext(vdihandle,61*8,6*16,texte);*/


		if( objet!=old_objet )
		{
			/* Si l'ancien objet est une des ligne du pop_up ... */
			if( old_objet>=POPUP_LIGNE01 && old_objet<=POPUP_LIGNE20 )
			{
				/* et si la ligne est s‚lectionn‚ ... */
				if( (adr_formulaire+old_objet)->ob_state & OS_SELECTED )
				{
					/* on la d‚selectionne. */
					SET_BIT( (adr_formulaire+old_objet)->ob_state, OS_SELECTED, 0);
					objc_offset(adr_formulaire,old_objet,&x,&y);
					objc_draw( adr_formulaire,0/*old_objet*/,4,x,y,(adr_formulaire+old_objet)->ob_width, (adr_formulaire+old_objet)->ob_height );
				}
			}

			/* Si la nouvelle ligne est une des ligne du pop_up ... */
			if( objet>=POPUP_LIGNE01 && old_objet<=POPUP_LIGNE20 )
			{
				/* on la d‚selectionne. */
				SET_BIT( (adr_formulaire+objet)->ob_state, OS_SELECTED, 1);
				objc_offset(adr_formulaire,objet,&x,&y);
				objc_draw( adr_formulaire,0/*objet*/,4,x,y,(adr_formulaire+objet)->ob_width, (adr_formulaire+objet)->ob_height );
			}

			old_objet=objet;

		}

/*		sprintf(texte,"bouton= %d ",bouton);
		v_gtext(vdihandle,61*8,6*16,texte);
		sprintf(texte," event & MU_BUTTON= %d ", event & MU_BUTTON);
		v_gtext(vdihandle,61*8,7*16,texte);
*/

	} while( (event & MU_BUTTON)==0 ); /*|| event == MU_TIMER );*/



	if( bouton==1 && objet>=POPUP_LIGNE01 && old_objet<=POPUP_LIGNE20 )
	{
		objet=objet-POPUP_LIGNE01;
	}
	else
	{
		objet=-1;
	}



	rsrc_gaddr( R_TREE, FORM_POPUP, &adr_formulaire );
	form_dial(3, 0,0,0,0, adr_formulaire->ob_x-2, adr_formulaire->ob_y-2, adr_formulaire->ob_width+8, adr_formulaire->ob_height+8 );


	wind_update(END_MCTRL);
	wind_update(END_UPDATE);



/*	sprintf(texte,"return( Objet = %d old_objet=%d )  ",objet, old_objet );
	v_gtext(vdihandle,61*8,7*16,texte);*/

	return(objet);

}

