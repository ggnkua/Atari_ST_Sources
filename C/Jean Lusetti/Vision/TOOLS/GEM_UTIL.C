#include <STDIO.H>
#include <EXT.H>
#include <GFA.H>
#include <GEM_UTIL.H>       /*INCLUS AES.H, VDI.H*/

int  contrl[12],         /* Ces tableaux doivent TOUJOURS ˆtre */
     intin[128],         /* d‚clar‚s dans les programmes destin‚s */
     ptsin[128],         /* … exploiter les fonctions VDI */
     intout[128],
     ptsout[128];

int  ap_id=0,                    /* Variables utilisables dans */
	handle=0,                 /* chaque application */
    x_max=0,
    y_max=0,
    nbr_color=0,
    pred_color=0;
     
char chem_clipboard[100];
DTA *buffer_dta=NULL, *mem_dta=NULL;
COOKIE *multitos=NULL, *reseau=NULL, *type_machine=NULL;

PARA_IMG_RSC para_img_rsc={"", 0, 0,
							{NULL, 0, 0, 0, 0, 0, 0, 0, 0},
							NULL
						  };

void gem_init(void) /* Appel‚ une fois au d‚but */
{	int  work_in[11],   /* Ces tableaux sont n‚cessaires … v_opnvwk */
     	 work_out[57],                                    
     	 i;                      /* Variable de stockage temporaire */
	AESPB aespb;
	
		
	/*ap_id = appl_init();*/                        /* Initialise l'AES */
  
  	_GemParBlk.contrl[0]=10;
  	_GemParBlk.contrl[2]=1;
  	aespb.contrl=_GemParBlk.contrl;
    aespb.global=_GemParBlk.global;
    aespb.intin=_GemParBlk.intin;
    aespb.intout=_GemParBlk.intout;
    aespb.addrin=(int*)_GemParBlk.addrin;
    aespb.addrout=(int*)_GemParBlk.addrout;
  	_crystal(&aespb);
	ap_id=_GemParBlk.intout[0];
	
	
	for (i=0; i<10; work_in[i++] = 1);             /* [0-9] mis … 1 */
	work_in[10] = 2;/* Drapeau de coordonn‚es, doit toujours ˆtre 2 */

	v_opnvwk (work_in, &handle, work_out);    /* Initialise la VDI */

	x_max = work_out[0];                      /* Stocker la r‚solution */
	y_max = work_out[1];
	pred_color= work_out[13];
	nbr_color= work_out[39];
	
	multitos=get_cookie_p('MiNT');	/*VERIFIE SI ON EST EN MULTITACHE*/ 
	reseau=get_cookie_p('_NET');      /*VERIFIE SI ON EST EN RESEAU*/
	type_machine=get_cookie_p('_MCH');/*TYPE DE MACHINE ST, STE, STBOOK, TT, FALCON*/ 
			
	scrp_read(chem_clipboard);      /*LECTURE DU CHEMIN DU CLIPBOARD*/
	if(strlen(chem_clipboard)==0)               /*SI PAS INITIALISER*/
	{	strcpy(chem_clipboard,"C:\\CLIPBRD\\");   /*ON IMPOSE LE STD*/
		scrp_write(chem_clipboard);
	}
	
	buffer_dta=(DTA*)calloc(1,sizeof(DTA));	/*PREPARE LE BUFFER DTA*/	
	mem_dta=Fgetdta();					/*MEMORISE L'ANCIENNE DTA*/ 
}

void gem_exit()              /* N'appeler cette fonction qu'… la fin */
{                            /* de l'application */
	Fsetdta(mem_dta);		 /*mise en place de l'ancienne dta*/ 
	free(buffer_dta);
	
	v_clsvwk(handle);
	appl_exit(); 
}

/*************************************/
COOKIE *get_cookie_p(long id)                   /*RECHERCHE UN COOCKIE*/
{	COOKIE *p;
	
	p=fcookie();                                   /*PREMIER COOCKIE*/
	while(p)                              /*SI IL Y A UN COOCKIE JAR*/
	{	if(p->ident==id)                  /*REGARDE SI IL CORRESPOND*/
			return p;      /*SI OUI ON RENVOIE L'ADR DE LA STRUCTURE*/
		p=ncookie(p);                         /*SINON COOKIE SUIVANT*/
	}
	return(COOKIE*)0;          /*PAS TROUVER DE COOKIE CORRESPONDANT*/
}

COOKIE *fcookie(void)       /*RECHERCHE COOKIE JAR ET PREMIER COOKIE*/
{	COOKIE *p;
	long stack;
	
	stack=Super(0);                           /*PASSE EN SUPERVISEUR*/
	p=*(COOKIE**)0x5a0;                  /*LIT ADRESSE DU COOKIE JAR*/
	Super((void*)stack);                      /*PASSE EN UTILISATEUR*/
	
	if(!p)
		return(COOKIE*)0;
	return p;
}

COOKIE *ncookie(COOKIE *p)                   /*LIT LE COOKIE SUIVANT*/
{	if(!p->ident)
		return 0;
	return ++p;
}

/***************************/
void write_champ(OBJECT arbre[],int index,char string[],int len)
{	TEDINFO *ted;   /*SORTIR PTR DE STRUCT TEDINFO, DE LA STRUCT OB_SPEC QUI CE*/
	ted=(TEDINFO *) (arbre[index].ob_spec).tedinfo; /*TROUVE DANS STRUCT ARBRE[INDEX]*/   
	debug_strncpy(ted->te_ptext,string,len);	
}

void read_champ(OBJECT arbre[],int index,char string[],bool cat)
{	TEDINFO *ted;
	ted=(TEDINFO *) (arbre[index].ob_spec).tedinfo; 
	if(cat)
		strcat(string,ted->te_ptext);
	else
		strcpy(string,ted->te_ptext);	
}

void write_masque(OBJECT arbre[],int index,char string[],int len)
{	TEDINFO *ted;   /*SORTIR PTR DE STRUCT TEDINFO, DE LA STRUCT OB_SPEC QUI CE*/
	ted=(TEDINFO *) (arbre[index].ob_spec).tedinfo; /*TROUVE DANS STRUCT ARBRE[INDEX]*/   
	debug_strncpy(ted->te_ptmplt,string,len);	
}

void read_masque(OBJECT arbre[],int index,char string[],bool cat)
{	TEDINFO *ted;
	ted=(TEDINFO *) (arbre[index].ob_spec).tedinfo; 
	if(cat)
		strcat(string,ted->te_ptmplt);
	else
		strcpy(string,ted->te_ptmplt);	
}

void write_button(OBJECT arbre[],int index,char string[],int len)
{	char *txt;
	txt=(arbre[index].ob_spec).free_string;
	debug_strncpy(txt,string,len);	
}

void read_button(OBJECT arbre[],int index,char string[],bool cat)
{	char *txt;
	txt=(arbre[index].ob_spec).free_string;
	if(cat)
		strcat(string,txt);
	else
		strcpy(string,txt);	
}

void write_string(OBJECT arbre[], int index, char string[], int len)
{	debug_strncpy(arbre[index].ob_spec.free_string, string, len);
}/*write_string*/

void read_string(OBJECT arbre[], int index, char string[], bool cat)
{	if(cat)
		strcat(string, arbre[index].ob_spec.free_string);
	else
		strcpy(string, arbre[index].ob_spec.free_string);	
}/*read_string*/

void taille_font(OBJECT arbre[],int index,int taille)
{	TEDINFO *ted;
	ted=(TEDINFO *) (arbre[index].ob_spec).tedinfo; 
	ted->te_font=taille;   /*3 ou 5*/	
}

int tstetat(OBJECT arbre[],int index)
{	return (int) arbre[index].ob_state;
}

void etat(OBJECT arbre[],int index,char etat)
{	arbre[index].ob_state=etat;
}

void flags(OBJECT arbre[],int index,char flag)
{	arbre[index].ob_flags=flag;
}


void taille_obj(OBJECT arbre[],int index,int w,int h)
{	arbre[index].ob_width=w;
	arbre[index].ob_height=h;
}

void coord_obj(OBJECT arbre[],int index,int x,int y)
{	arbre[index].ob_x=x;
	arbre[index].ob_y=y;
}

void centre_newdesk(OBJECT arbre[],
					int lst_obj_ct[], int nb_obj_ct,
					int lst_obj_dt[], int nb_obj_dt
					)
{	register int i, pos_x, pos_ct=x_max, pos_tp, ind;

		
	for(i=0; i<nb_obj_ct; i++)
	{	ind=lst_obj_ct[i];
		pos_x=(int)(x_max-arbre[ind].ob_width)/2;
		arbre[ind].ob_x=pos_x;
	}/*for*/

	for(i=0; i<nb_obj_dt; i++)
	{	ind=lst_obj_dt[i];
		pos_tp=x_max-(int)(arbre[ind].ob_width/2)-5;
		if(pos_ct>pos_tp)
			pos_ct=pos_tp;
	}/*for*/
	
	for(i=0; i<nb_obj_dt; i++)
	{	ind=lst_obj_dt[i];
		pos_x=pos_ct-(int)(arbre[ind].ob_width/2);
		arbre[ind].ob_x=pos_x;
	}/*for*/
}/*centre_newdesk*/

void change_fill(OBJECT arbre[],int index,unsigned pattern)
{	arbre[index].ob_spec.obspec.fillpattern=pattern;
}

void set_color_txt(OBJECT arbre[],int index,int color)
{	TEDINFO *ted;
	BFOB *modif;
	
	ted=(TEDINFO *) (arbre[index].ob_spec).tedinfo; 
	modif=(BFOB *) &ted->te_color;
	modif->textcol=color;
}

char get_color_txt(OBJECT arbre[],int index)
{	TEDINFO *ted;
	BFOB *modif;
	
	ted=(TEDINFO *) (arbre[index].ob_spec).tedinfo; 
	modif=(BFOB *) &ted->te_color;
	return modif->textcol;
}

ICONBLK* read_icn(OBJECT arbre[],int index)
{	ICONBLK *icn;
	icn=(ICONBLK *) (arbre[index].ob_spec).iconblk;
	return icn; 
}

void write_icn(OBJECT arbre[],int index,ICONBLK *source)
{	ICONBLK *dest;
	dest=(ICONBLK *) (arbre[index].ob_spec).iconblk;
	memcpy(dest,source,sizeof(ICONBLK));
}

CICONBLK* read_cicn(OBJECT arbre[],int index)
{	CICONBLK *cicn;
	cicn=(CICONBLK *) (arbre[index].ob_spec).ciconblk;
	return cicn; 
}

void write_cicn(OBJECT arbre[],int index,CICONBLK *source)
{	CICONBLK *dest;
	dest=(CICONBLK *) (arbre[index].ob_spec).ciconblk;
	memcpy(dest,source,sizeof(CICONBLK));
}


void objc_routine(OBJECT *arbre, int objet, int cdecl (*routine)(struct __parmblk *parmblock))
{	arbre[objet].ob_spec.userblk->ub_code=routine;
}/*objc_routine*/

int cdecl charg_img_rscs(PARMBLK *parmblock)
{	char buffer[9], fic[80];
	int pxyarray_c[4], pxyarray_i[8], plan;
	long numero;
	MFDB screen, *out;
	
/*POUR SIMPLIFIER L'ECRITURE*/
	out=&para_img_rsc.img_en_cours;	
	numero=para_img_rsc.numero_en_cours;
	
/* CLIPPING */
	pxyarray_c[0]=parmblock->pb_xc;
	pxyarray_c[1]=parmblock->pb_yc;
	pxyarray_c[2]=pxyarray_c[0]+parmblock->pb_wc;
	pxyarray_c[3]=pxyarray_c[1]+parmblock->pb_hc;
	vs_clip(handle, 1, pxyarray_c);
	
/*DETERMINE LES COORDONNES DE LA SOURCE*/
	pxyarray_i[0]=0;
	pxyarray_i[1]=0;
	pxyarray_i[2]=parmblock->pb_w;
	pxyarray_i[3]=parmblock->pb_h;

/*DETERMINE LES COORDONNES DE LA DESTINATION*/
	pxyarray_i[4]=parmblock->pb_x;
	pxyarray_i[5]=parmblock->pb_y;
	pxyarray_i[6]=pxyarray_i[4]+parmblock->pb_w;
	pxyarray_i[7]=pxyarray_i[5]+parmblock->pb_h;

/*CHARGE L'IMAGE SI PAS DEJA FAIT*/
	if(numero!=parmblock->pb_parm)
	{	if(out->fd_addr!=NULL)
		{	free(out->fd_addr);
			out->fd_addr=NULL;
		}/*if*/
		plan=para_img_rsc.nb_plan*2;
		numero=parmblock->pb_parm;
	/*TANT QU'ON NE TROUVE PAS L'IMAGE AU NB PLAN CORRESPONDANT*/
	/*ON DESCEND EN NB DE COULEUR*/	
		do	
		{	if(out->fd_addr==NULL)
				plan/=2;
			strcpy(fic, para_img_rsc.chemin);
			ltoa(numero, buffer, 10);
			strcat(fic, buffer);
			strcat(fic, "_");
			itoa(plan, buffer, 10);
			strcat(fic, buffer);
			strcat(fic, ".IMG");
			para_img_rsc.load_img(fic, out);
		}while(out->fd_addr==NULL && plan>1);
		para_img_rsc.numero_en_cours=numero;
	}/*if*/

/*ADRESSE DESTINATION ECRAN & COPY*/
	if(out->fd_addr!=NULL)
	{	screen.fd_addr=0;
		vro_cpyfm(handle, S_ONLY, pxyarray_i, out, &screen);
	}/*if*/

/*FIN DU CLIPPING*/	
	vs_clip(handle, 0, pxyarray_c);
	
	return (int)0;
}/*charg_img_rscs*/

int determine_nb_plan(int nb_couleur)
{	int nb_plan;
	
	switch(nb_couleur)
	{	case 1:		nb_plan=1; break;
		case 4: 	nb_plan=2; break;
		case 16:	nb_plan=4; break;
		case 256:	nb_plan=8; break;
	}/*switch*/
	
	return nb_plan;
}/*determine_nb_plan*/
/*************************************/
void en_page(OBJECT *arbre,char obj1,char obj2,char *liste[],int nbelem,int pg,int len)
{	char i;
	int ind;
	
	for(i=obj1;i<=obj2;i++)         /*met en place dans le selecteur*/
	{	ind=i-obj1+(obj2-obj1+1)*pg;
		if(ind<nbelem)
		{	write_champ(arbre,i,liste[ind],len);
			flags(arbre, i, SELECTABLE|RBUTTON|TOUCHEXIT);
		}
		else                       /*si plus d'element on met rien*/
		{	write_champ(arbre,i,"",len);
			flags(arbre, i, NONE);
		}/*if*/
	}/*for*/
}/*en_page*/

int fileselect(char path[],char nom[])
{	int confirmer;
	fsel_input(path,nom,&confirmer);
	return confirmer;
}

/*void vide_mouse(void)
{	int ev_mwhich;
	
	do
	{	ev_mwhich=vide_buffer_aes(MU_BUTTON, 30);
	}while(ev_mwhich!=MU_BUTTON);
	
}/*vide_mouse*/
*/

void vide_mouse(void)
{	int gr_mkmx,gr_mkmy,gr_mkmstate,gr_mkkstate;
	
	do
	{	graf_mkstate(&gr_mkmx,&gr_mkmy,&gr_mkmstate,&gr_mkkstate);
	}while(gr_mkmstate>0);
}/*vide_mouse*/

int vide_buffer_aes(int ev_mflags, int ev_mtlocount)
{	int ev_mwhich, ev_mflags2,
		ev_mgpbuff[8], ev_mmox=0, ev_mmoy=0, 
		ev_mmbutton=0, ev_mmokstate=0,
        ev_mkreturn=0, ev_mbreturn=0;
	
	ev_mflags2=ev_mflags;
	ev_mflags2|=MU_TIMER;

	do
	{	ev_mwhich=evnt_multi(	ev_mflags2,
								2, 1, 1,
								0, 0, 0, 0, 0,
								0, 0, 0, 0, 0,
								ev_mgpbuff,
								ev_mtlocount, 0,
								&ev_mmox, &ev_mmoy, &ev_mmbutton, &ev_mmokstate,
        						&ev_mkreturn, &ev_mbreturn
        			 		);
	}while(ev_mwhich==ev_mflags);

	return ev_mwhich;
}/*vide_buffer_aes*/

void swappe_icn(OBJECT *arbre_cible,int cible,OBJECT *arbre_source,int source)
{	ICONBLK *icn_swap;
	
	icn_swap=read_icn(arbre_source,source);
	write_icn(arbre_cible,cible,icn_swap);           /*COPIE ICONBLK*/
	redraw_icone(arbre_cible,cible,1);       /*OBLIGER DE LE FAIRE 2*/
	redraw_icone(arbre_cible,cible,0);    /*FOIS (ALLUMEZ ET ETEINT)*/
}

void swappe_cicn(OBJECT *arbre_cible,int cible,OBJECT *arbre_source,int source)
{	CICONBLK *cicn_swap;
	
	cicn_swap=read_cicn(arbre_source,source);
	write_cicn(arbre_cible,cible,cicn_swap);           /*COPIE ICONBLK*/
	redraw_icone(arbre_cible,cible,1);       /*OBLIGER DE LE FAIRE 2*/
	redraw_icone(arbre_cible,cible,0);    /*FOIS (ALLUMEZ ET ETEINT)*/
}


void redraw_icone(OBJECT arbre[],int objet,int etat)
{	int rx,ry,rw,rh;
		
	if(arbre[objet].ob_state!=etat)/*VERIFIE SI ON CHANGE BIEN D'ETAT*/
	{	v_hide_c(handle);                           /*PLUS DE SOURIS*/
		wind_update(1);             /*BLOQUE LA LISTE DES RECTANGLES*/
			 
		arbre[objet].ob_state=etat;                  /*CHANGE D'ETAT*/	
	
		wind_get(0,11,&rx,&ry,&rw,&rh);        /*0=HANDLE DE NEWDESK*/
	 							                 /*PREMIER RECTANGLE*/
		while(rw!=0)                                /*SI LARGEUR !=0*/
		{	objc_draw(arbre,objet,objet,rx,ry,rw,rh);			  		  
												  
	 		wind_get(0,12,&rx,&ry,&rw,&rh);      /*RECTANGLE SUIVANT*/
		}
		wind_update(0);
		v_show_c(handle,1);
	}
}

int ident_dbclic(int retour,bool moins)
{	int valeur;

	valeur=retour & 32767;
	if(moins)
		valeur=-valeur;
	
	return valeur;
}

/***************************** POPUP *****************************/
/*******************************************************/
/** GESTION DES POPUPS & SOUS POPUPS SELON LA MACHINE **/
/** **arbre est un tableau de pointeur sur les popups **/
/** le 1er est le popup pŠre, les autres sont les     **/
/** fils eventuelles. item_subm est un tableau qui    **/
/** contient les numeros d'items du pŠre auquel sont  **/
/** attach‚s les fils. nb_subm indique le nombre de   **/
/** fils(pour arbre, il y a le pŠre en plus). L'ordre **/
/** des popups dans arbres est celui des items du     **/
/** pŠre. Si nb_subm=0, il n'y a pas de sous_menu et  **/
/** seul le pŠre est affich‚.                         **/
/*******************************************************/
size_t gest_pop_up(OBJECT **arbre, int item_subm[], int nb_subm, int x, int y,
				   int item, int scroll
				   )
{	int w=0, h=0, retour, i, sub_attached;
	int selct_item, sub_pop, num;
	bool trouver=false;
	size_t resultat;
	MENU pp_menu1, pp_menu2, *pp_subm;	
	
	
	if(type_machine!=NULL && type_machine->v.l==0x30000l)
	{	pp_menu1.mn_tree=arbre[0];
		pp_menu1.mn_menu=ROOT;
		pp_menu1.mn_item=item;
		pp_menu1.mn_scroll=scroll;
		
		if(nb_subm)
		{	pp_subm=(MENU*)calloc(nb_subm, sizeof(MENU));
			for(i=0; i<nb_subm; i++)
			{	pp_subm[i].mn_tree=arbre[i+1];
				pp_subm[i].mn_menu=ROOT;
				pp_subm[i].mn_item=1;
				pp_subm[i].mn_scroll=scroll;
				
				sub_attached=menu_attach(1, pp_menu1.mn_tree, item_subm[i], &pp_subm[i]);
			
				if(sub_attached==0)
					ding();
			}/*for*/
		}/*if*/
		
	/*GESTION AES DU POPUP*/	
		retour=menu_popup(&pp_menu1, x, y, &pp_menu2);
	
	/*TRAITE LES RESULTATS*/	
		if(retour==0)
			resultat=0ul;
		else
		{	if(nb_subm==0)
				resultat=(size_t)pp_menu2.mn_item;
			else
			{	selct_item=pp_menu2.mn_item;
				sub_pop=0;
				for(i=0; i<=nb_subm; i++)
				{	if(arbre[i]==pp_menu2.mn_tree)
						sub_pop=i;
				}/*for*/
					
				resultat=(size_t)sub_pop;
				resultat<<=16;
				resultat|=(size_t)selct_item;
			}/*if*/
		}/*if*/
	
/*	/*DETACHE LES SOUS MENUS*/
		for(i=0; i<nb_subm; i++)
			menu_attach(2, pp_menu1.mn_tree, item_subm[i], &pp_subm[i]);
*/
	/*LIBERE LA MEM*/
		if(nb_subm)
			free(pp_subm);
	
	/*RENVOIE LES RESULTATS*/
		return resultat;
	}
	else
	{	if(x+arbre[0]->ob_width>x_max)
			x=x_max-arbre[0]->ob_width-5;

		if(y+arbre[0]->ob_height>y_max)
			y=y_max-arbre[0]->ob_height-5;

		arbre[0]->ob_x=x;
		arbre[0]->ob_y=y;
		w=arbre[0]->ob_width+2;
		h=arbre[0]->ob_height+2;
		
		form_dial(0,x-1,y-1,w+2,h+2,x-1,y-1,w+4,h+4);
		objc_draw(arbre[0],0,100,x-1,y-1,w+4,h+4);
		retour=form_do(arbre[0],0);
		objc_change(arbre[0],retour,0,x-1,y-1,w+4,h+4,NORMAL,1);
		form_dial(3,x-1,y-1,w+2,h+2,x-1,y-1,w+4,h+4);

		for(i=0; i<nb_subm; i++)
		{	if(item_subm[i]==retour)
			{	num=i+1;
				trouver=true;
			}/*if*/
		}/*for*/
		
		if(trouver)
		{	if(x+arbre[num]->ob_width>x_max)
			x=x_max-arbre[num]->ob_width-5;

			if(y+arbre[num]->ob_height>y_max)
				y=y_max-arbre[num]->ob_height-5;

			arbre[num]->ob_x=x;
			arbre[num]->ob_y=y;
			w=arbre[num]->ob_width;
			h=arbre[num]->ob_height;

			form_dial(0,x-1,y-1,w+2,h+2,x-1,y-1,w+4,h+4);
			objc_draw(arbre[num],0,100,x-1,y-1,w+4,h+4);
			retour=form_do(arbre[num],0);
			objc_change(arbre[num],retour,0,x-1,y-1,w+4,h+4,NORMAL,1);
			form_dial(3,x-1,y-1,w+2,h+2,x-1,y-1,w+4,h+4);
		
			resultat=(size_t)num;
			resultat<<=16;
			resultat|=(size_t)retour;
		}
		else
			resultat=retour;
		
		return resultat;
		
	}/*if*/
}/*gest_pop_up*/

/******************************************/
/** FABRIQUE DE TOUTE PIECE UN POPUP QUI **/
/** NE SERAIT PAS DANS LE RSC            **/
/******************************************/
OBJECT *creer_pop_up(int nb_objets, int nb_cara)
{	int i;
	OBJECT *pop_up;
	
	pop_up = (OBJECT *)calloc((nb_objets + 1), sizeof (OBJECT));
	
	if( pop_up )
	{/*DEFINITION DU PERE ([0])*/
		pop_up->ob_next = -1;
		pop_up->ob_head = 1;
		pop_up->ob_tail = nb_objets;
		pop_up->ob_type = G_BOX;
		pop_up->ob_flags = NONE;
		pop_up->ob_state = SHADOWED;
		pop_up->ob_spec.obspec.framesize = -1;
		pop_up->ob_spec.obspec.framecol = 1;
		pop_up->ob_spec.obspec.textcol = 1;
		pop_up->ob_spec.obspec.fillpattern = 0;
		pop_up->ob_x = 0;
		pop_up->ob_y = 0;
		pop_up->ob_width = nb_cara*8;
		pop_up->ob_height = nb_objets*16;

	/*DEFINITION DU PREMIER FILS*/
		pop_up[1].ob_next = 0;
		pop_up[1].ob_head = -1;
		pop_up[1].ob_tail = -1;
		pop_up[1].ob_type = G_STRING;
		pop_up[1].ob_flags = TOUCHEXIT|LASTOB;
		pop_up[1].ob_state = NORMAL;
		pop_up[1].ob_spec.free_string = calloc(nb_cara, sizeof(char));
		pop_up[1].ob_x = 0;
		pop_up[1].ob_y = 0;
		pop_up[1].ob_width = nb_cara*8;
		pop_up[1].ob_height = 16;
	
	/*DEFINITION DES AUTRES FILS*/	
		if(nb_objets > 1)
		{	for(i = 2; i <= nb_objets; i++)
			{	pop_up[i-1].ob_next = i;
				pop_up[i].ob_next = 0;
				pop_up[i].ob_head = -1;
				pop_up[i].ob_tail = -1;
				pop_up[i].ob_type = G_STRING;
				pop_up[i-1].ob_flags = TOUCHEXIT|NONE;
				pop_up[i].ob_flags = TOUCHEXIT|LASTOB;
				pop_up[i].ob_state = NORMAL;
				pop_up[i].ob_spec.free_string = calloc(nb_cara, sizeof(char));
				pop_up[i].ob_x = 0;
				pop_up[i].ob_y = (i -1)*16;
				pop_up[i].ob_width = nb_cara*8;
				pop_up[i].ob_height = 16;
			}/*for*/
		}/*if*/
	}/*if*/	
	
	return pop_up;
}/*creer_pop_up*/

/******************************************/
/** DETRUIT LE POPUP CONSTRUIT PLUS HAUT **/
/******************************************/
void detruire_pop_up(OBJECT *pop_up, int nb_objets)
{	int i;

	if(pop_up!=NULL)
	{	for(i=1; i<=nb_objets; i++)
			if(pop_up[i].ob_spec.free_string!=NULL)
				free(pop_up[i].ob_spec.free_string);
		free(pop_up);
	}/*if*/
}/*detruire_pop_up*/
/********************************************/

int gest_formulaire(OBJECT *arbre,GEST_FORMULAIRE *info_gest)
{	int i,x=0,y=0,w=0,h=0,retour=0;
		
	if(info_gest->center)
		form_center(arbre,&x,&y,&w,&h);
	else
	{	x=arbre->ob_x;      /* x-Koordinate des Objekts      */
        y=arbre->ob_y;      /* y-Koordinate des Objekts      */
        w=arbre->ob_width;  /* Breite des Objekts            */
        h=arbre->ob_height; /* H”he des Objekts              */
	}
	
	if(info_gest->s_fond)
	{	form_dial(0,x,y,w,h,x,y,w,h);
		if(info_gest->g_box)
			form_dial(1,x,y,1,1,x,y,w,h);
	}
	
	if(info_gest->nb_obj_redraw>0)
	{	for(i=0; i<info_gest->nb_obj_redraw*2; i+=2)
			objc_draw(arbre,info_gest->lst_objet[i],info_gest->lst_objet[i+1],x,y,w,h);
		
		free(info_gest->lst_objet);	
		info_gest->lst_objet=NULL;
		info_gest->nb_obj_redraw=0;
	}
	
	if(info_gest->change)
		objc_change(arbre,info_gest->num_change,0,x,y,w,h,0,1);

/***/	
	if(info_gest->exe_form_do)
	{	retour=form_do(arbre,info_gest->pos_curseur);
		retour=ident_dbclic(retour,false);
	}
	
/***/
	if(info_gest->r_fond)
	{	form_dial(3,x,y,w,h,x,y,w,h);
		if(info_gest->g_box)
			form_dial(2,x,y,1,1,x,y,w,h);
	}
	
	return retour;
}/*gest_formulaire*/

void prepare_gest_form(GEST_FORMULAIRE *info_gest, bool i_center,
					   bool i_s_fond, bool i_r_fond, bool i_g_box,
					   bool i_exe_form_do, bool i_change,
					   int num_obj_change, int i_pos_curseur
					   )
{	info_gest->center=i_center;				/*DOIT_ON CENTRER*/
	info_gest->s_fond=i_s_fond;				/*DOIT_ON SAUVER LE FOND*/
	info_gest->r_fond=i_r_fond;				/*DOIT_ON RESTITUER LE FOND*/
	info_gest->g_box=i_g_box;				/*GROW_BOX?*/
	info_gest->exe_form_do=i_exe_form_do;	/*ON DONNE LA MAIN A L'AES*/
	info_gest->change=i_change;				/*DOIT_ON FAIRE UN OBJECT_CHANGE*/
	info_gest->num_change=num_obj_change;
	info_gest->pos_curseur=i_pos_curseur;	/*POS DU CURSEUR*/
}/*prepare_gest_form*/

void prep_list_redraw(GEST_FORMULAIRE *info_gest, int num_obj1, int num_obj2)
{	if(info_gest->lst_objet!=NULL || info_gest->nb_obj_redraw==0)
		info_gest->lst_objet=(int*)ralloue_tab(info_gest->lst_objet,
							 sizeof(int), (info_gest->nb_obj_redraw+1)*2,
							 info_gest->nb_obj_redraw*2
							 );
	else
	{	info_gest->lst_objet=(int*)calloc(1*2,sizeof(int));
		info_gest->nb_obj_redraw=0;
	}
	

	/*if(info_gest->lst_objet!=NULL || info_gest->nb_obj_redraw==0)
		info_gest->lst_objet=(int*)calloc(512,sizeof(int));
	*/
	
	info_gest->lst_objet[info_gest->nb_obj_redraw*2]=num_obj1;
	info_gest->lst_objet[(info_gest->nb_obj_redraw*2)+1]=num_obj2;
	info_gest->nb_obj_redraw++;
}/*prep_list_redraw*/


/******************/
void anim_mouse(OBJECT arbre[])
{	MFORM mfstr;
	ICONBLK *forme=NULL;
	static int objet=1;
	
	objet++;
	if(objet>16)
		objet=1;
		
	forme=read_icn(arbre,objet);
	
	mfstr.mf_xhot=8;                   /*INITIALISE LA STRUCTURE*/
	mfstr.mf_yhot=8;    /*POUR COPIER L'ICONE DANS LE PTR SOURIS*/
	mfstr.mf_nplanes=1;
	mfstr.mf_fg=0;
	mfstr.mf_bg=1;
	memcpy(&mfstr.mf_mask, forme->ib_pmask, 32);        /*CPY*/
	memcpy(&mfstr.mf_data, forme->ib_pdata, 32);
	graf_mouse(255, &mfstr);         /*COMMUNIQUE L'ADR & AFFICHE*/
}/*anim_mouse*/

/*TESTE MOT DE PASSE*/
bool test_passe(OBJECT *arbre, 
				int num_champ_titre, int num_champ_passe,
				char titre[], char mot_de_passe[]
				)
{	int x=0, y=0, w=0, h=0, touche, clavier;
	char mot[51], tampon[51], pos=0, cara;	
	bool on_fait_ding=false, ok=false;
	
	if(strlen(mot_de_passe)>0)
	{	write_champ(arbre, num_champ_titre, titre, 50);
		write_champ(arbre, num_champ_passe, "", 20);
	
		form_center(arbre,&x,&y,&w,&h);
		form_dial(0,x,y,w,h,x,y,w,h);
		form_dial(1,x,y,1,1,x,y,w,h);
		objc_draw(arbre,0,12,x,y,w,h);
		
		do
		{	clavier=evnt_keybd();
			cara=(char)clavier;
			touche=clavier>>8;
			
		/*SI BACKSPACE*/
			if(touche==BACKSP)
			{	pos--;
				mot[pos]='\0';
				tampon[pos]='\0';
			}
			
		/*SI ESC*/
			else if(touche==ESC)
			{	pos=0;
				mot[pos]='\0';
				tampon[pos]='\0';
			}
			
		/*SI CARACTERE NORMAL*/
			else if(touche!=HOME && touche!=CUR_DOWN && touche!=CUR_UP && 
		   			touche!=CUR_RIGHT && touche!=CUR_LEFT && touche!=DELETE &&
		   			touche!=INSERT && touche!=TAB && touche!=UNDO && touche!=HELP &&
		   			touche!=RETURN && touche!=ENTER
		   			)
			{	mot[pos]=cara;
				mot[pos+1]='\0';
			
				tampon[pos]=10;
				tampon[pos+1]='\0';
			
				pos++;
			}
			
		/*SI RIEN DE TOUT €A*/
			else if(touche!=RETURN && touche!=ENTER)
				on_fait_ding=true;
			
			if(on_fait_ding)
			{	on_fait_ding=false;
				ding();
			}
			else
			{	write_champ(arbre, num_champ_passe, tampon, 20);
				objc_draw(arbre,num_champ_passe,num_champ_passe,x,y,w,h);
			}/*if*/
	
		}while(touche!=RETURN && touche!=ENTER);
		
		if(strcmp(mot, mot_de_passe)==0)
			ok=true;
		else
			ok=false;
		
		form_dial(3,x,y,w,h,x,y,w,h);
		form_dial(2,x,y,1,1,x,y,w,h);
	
	}/*if*/
	else
		ok=true;
	
	return ok;
}/*test_passe*/

/**PASSE EN MODE 640*480 256 COULEURS ET REVIENT AU MODE INITIALE**/ 
void change_res(bool mode_256)
{	int new_mode;
	long taille_screen;
	static int old_mode=0;
	static void *new_screen=NULL, *log=NULL, *phys=NULL;
	static bool changer=false;

/**/
	if((x_max+1==640 && y_max+1==480) && (pred_color<256 && mode_256==true))
	{	old_mode=Vsetmode(-1);					/*STOCKE RES. COURANTE*/
		new_mode=old_mode & (VGA_FALCON | PAL);
		if(new_mode & VGA_FALCON)				/*SI ON EST SUR VGA*/
			new_mode|=(COL80 | BPS8);			/*PASSE EN 256 COULEURS*/
		else									/*SI RVB*/		
			new_mode|=(COL80 | BPS8 | VERTFLAG | OVERSCAN);	/*PASSE EN 256 COULEURS + OVERSCAN*/
		
		taille_screen=VgetSize(new_mode);		/*DEMANDE LA TAILLE DU FUTURE ECRAN*/
		new_screen=calloc(taille_screen, 1);	/*RESERVE LE BUFFER*/
		if(new_screen!=NULL)					/*S'IL Y A LA PLACE*/
		{	changer=true;
			log=Logbase();						/*RECUPERE LE PTR DE L'ECRAN LOGIQUE*/
			phys=Physbase();					/*RECUPERE LE PTR DE L'ECRAN PHYSIQUE*/
												/*MET EN PLACE LA NOUVELLE RES.*/
			xbios(5, (long)new_screen, (long)new_screen, 3, new_mode);	
		}
		else
		{	ding();
			form_alert(1,"[3][Il n'y a pas assez de m‚moire|pour changer de r‚solution.][CONFIRMER]");
		}/*if*/
	}
	else if(changer==true)
	{	xbios(5, (long)log, (long)phys, 3, old_mode);		/*REMET EN PLACE LA RES. COURANTE*/
  		free(new_screen);						/*LIBERE LE BUFFER*/
  		changer=false;
	}/*if*/

}/*change_res*/

/**FERMETURE POUR RESEAU AVEC BOUCLE D'ATTENTE***/
int reseau_lock(FILE *pf,int mode)
{	int retour=1;
	long reponse;

	do
	{	reponse=Flock(pf->Handle,mode,0L,1L);
	}while(reponse!=0);

return retour;
}/*reseau_lock*/

/* ouverture fichier sur le reseau*/
FILE *reseau_fopen(char *nomfic,const char *mode)
{	FILE *pf=NULL;
	int i=0,reponse=1;

/*printat(1,1);printf("ouverture fichier %s\n",nomfic);*/

	pf = fopen(nomfic,mode);
	
	if (pf==NULL && existos(nomfic) && reseau!=NULL)
		do
		{	evnt_timer(500,0);
			pf = fopen(nomfic,mode);
			i++;
			if (i>90)
			{	i=0;
				reponse=form_alert(1,"[1][Ouverture de fichier impossible][REESSAYER|ANNULER]");
			}
		}while( pf==NULL && reponse==1);

/*printf("boucle pf null num=%d\n",i);*/
	
	if (pf!=NULL)
	{	if (reseau!=NULL)
			do 
				i=(int)Flock(pf->Handle,BLOQUER,0L,1L);
			while (i==58);
/*		printf("Flock=%d\n",i);*/
	}
	
	return pf;
}/*reseau_fopen*/


/* fermeture du fichier sur le reseau */
int reseau_fclose(FILE *pf)
{	int retour=0,reponse=0;
	
	if (reseau!=NULL)
		reponse= (int) Flock(pf->Handle,LIBERER,0L,1L);

	retour=fclose(pf);
	
/*printf("fermer\nflock=%d fclose=%d\n",reponse,retour);*/
	if (reponse!=0)
		return reponse;
	else
		return retour;
}/*reseau_fclose*/

