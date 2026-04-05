/* **[Fonction Commune]********** */
/* *                            * */
/* * 29/12/2012 MaJ 18/02/2024  * */
/* ****************************** */


#ifndef __FCM_GET_OBJET_PARENT_C__
#define __FCM_GET_OBJET_PARENT_C__

#define WORD  int16


WORD get_par_daroou(OBJECT *tree, WORD obj, WORD *pnobj);
WORD get_par_emutos(OBJECT *tree, WORD obj, WORD *pnobj);




WORD get_par_daroou(OBJECT *tree, WORD obj, WORD *pnobj)
{
//FCM_CONSOLE_ADD2("-- get_par_daroou -- obj=%d", obj, G_YELLOW );

#if NIL != (-1)
 #error "NIL error in get_par()"
#endif

	/* if obj == ROOT   ob_next == -1   =>   NIL  */
	/* if objet is wrong ?  obj < 0 ? */
	/* ob_next peut être le parent si obj est le dernier objet du niveau */
	/* c'est voulu, voir ob_delete */
	*pnobj = tree[obj].ob_next;


    if ( obj > ROOT ) /* if obj < 0 ? crash ? */
    {

        while(1)
        {
			/* on cherche l'objet parent */

//FCM_CONSOLE_ADD5("tree[%d].ob_next=%d  tree[ tree[%d].ob_next ].ob_tail=%d", obj, tree[obj].ob_next, obj, tree[ tree[obj].ob_next ].ob_tail, G_YELLOW );

			/* if obj is the last child object
			 * objet[obj].ob_next        = idx_parent
			 * objet[idx_parent].ob_tail = obj
			 *
			 * objet[ objec[obj].ob_next ].ob_tail == obj
			 *
			 */
			if( tree[ tree[obj].ob_next ].ob_tail == obj )
			{
	            obj = tree[obj].ob_next;
				break;
			}

            obj = tree[obj].ob_next;

			/* if wrong object tree ? */
			//if( obj < 0 )
			{
				/* Houston ! we have a problem... */
				/* infinite loop */
			}
        }
    }
	else
	{
		/* obj <= ROOT */
		obj = NIL;
	}


//FCM_CONSOLE_ADD3("=> obj=%d  *pnobj=%d", obj, *pnobj, G_YELLOW );

	//if( *pnobj == obj )
	{
		/* first next objet est également l'objet parent */
	}

    return obj;
}


/*
 * Routine that will find the parent of a given object.  The
 * idea is to walk to the end of our siblings and return
 * our parent.  If object is the root then return NIL as parent.
 * Also have this routine return the immediate next object of
 * this object.
 */
WORD get_par_emutos(OBJECT *tree, WORD obj, WORD *pnobj)
{
    WORD    pobj = NIL, nobj = NIL;
    OBJECT  *objptr, *pobjptr;

//FCM_CONSOLE_ADD2("-- get_par_emutos -- obj=%d", obj, G_WHITE );

    if (obj != ROOT)
    {
        while(1)
        {
            objptr = tree + obj;

            pobj = objptr->ob_next;

            if (nobj == NIL)        /* first time */
                nobj = pobj;

            if (pobj < ROOT)
                break;

            pobjptr = tree + pobj;

//FCM_CONSOLE_ADD5("pobjptr=%p  pobjptr->ob_tail=%d pobj=%d obj=%d", pobjptr, pobjptr->ob_tail, pobj, obj, G_WHITE );

            if ( pobjptr->ob_tail == obj )
                break;


            obj = pobj;
        }
    }

//FCM_CONSOLE_ADD5("=> pobjptr=%p  pobjptr->ob_tail=%d pobj=%d obj=%d", pobjptr, pobjptr->ob_tail, pobj, obj, G_WHITE );

    *pnobj = nobj;
    return pobj;
}


int16 Fcm_get_objet_parent( OBJECT *tree, int16 objet )
{
	//int16 objet_next;
	//int16 objet_tail;
	//int16 objet_head;

	FCM_LOG_PRINT2("* Fcm_get_objet_parent(%8p,%d)", tree, objet );
/*
	{
		int16 reponse, nextobjet;
	
	reponse = get_par_emutos(tree, objet, &nextobjet);
	FCM_CONSOLE_ADD3("Emutos: reponse=%d nextobjet=%d", reponse, nextobjet, G_WHITE );

	reponse = get_par_daroou(tree, objet, &nextobjet);
	FCM_CONSOLE_ADD3("Daroou: reponse=%d nextobjet=%d", reponse, nextobjet, G_WHITE );

	}*/


	//FCM_CONSOLE_ADD3("#Fcm_get_objet_parent(%8p,%d)", tree, objet, G_GREEN );

	/* l'exemple du compendium est faux */
	/* objet     head   tail    next */
	/*   0        1      5       -1   */   /* ROOT  */
	/*   1       -1     -1        2   */   /* +--Titre */
	/*   2        3      4        5   */   /* +--G_BOX */
	/*   3       -1     -1        4   */   /*    +--Bouton Screen  dans G_BOX */
	/*   4       -1     -1        2   */   /*    +--Bouton Printer dans G_BOX */
	/*   5       -1     -1        0   */   /* +--Bouton OK */

	/* --- ob_head --- */
	/* Si l'objet a au moins un objet enfant, ob_head designe */
	/* le num‚ro d'objet du __premier__enfant__               */
	/* Si l'objet n'a pas d'objet enfant, ob_head = -1        */

	/* --- ob_tail --- */
	/* Si l'objet a au moins un objet enfant, ob_tail designe */
	/* le num‚ro d'objet du __dernier__enfant__               */
	/* Si l'objet n'a pas d'objet enfant, ob_tail = -1        */

	/* --- ob_next --- */
	/* ob_next pointe sur le prochain objet __frŠre__  */
	/* si l'objet est le dernier objet frere, il designe l'objet pere */
	/* si l'objet est ROOT, ob_next=-1 */


	/* si idx est le dernier objet du niveau     */
	/* objet[idx].ob_next        = idx du parent */
	/* objet[idx_parent].ob_tail = idx           */
	/* objet[ objec[idx].ob_next ].ob_tail = idx */


	/* Les valeurs index objet ne sont pas forcement   */
	/* consecutive dans un meme niveau, si des enfants */
	/* sont intercallés , voir exemple ci-dessus.      */
	/* Par contre l'index objet parent est toujours    */
	/* inferieur a l'index de l'objet si le RSC est trié */


    if ( objet > ROOT )
    {

        while(1)
        {
			/* on cherche l'objet parent */

//FCM_CONSOLE_ADD5("tree[%d].ob_next=%d  tree[ tree[%d].ob_next ].ob_tail=%d", objet, tree[objet].ob_next, objet, tree[ tree[objet].ob_next ].ob_tail, G_YELLOW );

			if( tree[ tree[objet].ob_next ].ob_tail == objet )
			{
	            objet = tree[objet].ob_next;
				break;
			}

            objet = tree[objet].ob_next;

			/* if wrong object tree ? */
			if( objet < 0 )
			{
				/* Houston ! we have a problem... */
				/* infinite loop */
				FCM_CONSOLE_DEBUG1("Fcm_get_objet_parent() : objet < 0  (%d)", objet);
				objet = ROOT;
				break;
			}
        }
    }
	else
	{
		/* objet <= ROOT */
		FCM_CONSOLE_DEBUG1("Fcm_get_objet_parent() : objet incorrect (%d)", objet);
		objet = ROOT;
	}

//FCM_CONSOLE_DEBUG1("Fcm_get_objet_parent() : return (%d)", objet);

	return(objet);


}


#endif   /*   __FCM_GET_OBJET_PARENT_C__   */

