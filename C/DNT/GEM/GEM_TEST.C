/* Exemple de programmation simple des ressources GEM
NulloS pour le DNT-paper 2,en TurboC V2
Seuls quelques appels GEM sont vus,le reste n'est pas important
pour le moment,et sera abord‚ au prochain num‚ro.
L'important ici est de voir comment ‡a marche,et comment c'est
simple si on y regarde de plus prŠs...
Y'a des fonctions et des structures qui devraient normalement
ˆtre dans un module s‚par‚.Cela sera le cas aussi au prochain
num‚ro,qui sera une extension de la bibli GEM classique.Pour le
moment,c'est un peu l‚ger pour en faire une bibli !
*/

#include	<AES.H>			/*Appels et structures AES	*/
#include	<VDI.H>			/*Appels et structures VDI	*/
#include	<STDIO.H>		/*contient sprintf et autres*/
#include	<STRING.H>		/*contient strcat et strcpy */

#include	"GEM_TEST.H"	/*Les d‚finitions du RSC	*/


int		main(void);
int		show_dialog(OBJECT *,int);
int		out_dialog(void);
int		out_info(int);
int		gem_init(void);
void	gem_exit(void);
char	*read_ftext(char *,OBJECT *,int);



typedef	struct	{
				int screen_w;				/*largeur ‚cran				*/
				int	screen_h;				/*hauteur ‚cran				*/
				
				int	nb_color;				/*nb de couleurs simultan‚es*/
				int	nb_planes;				/*nb de plans de couleurs	*/
				int	pal_size;				/*taille de la palette		*/
				}	VWORK_INFO;				/*yeah !					*/



int				work_in[12],work_out[57];	/*Tableaux VDI*/
int				handle;						/*handle   VDI*/
int				appl_id;					/*handle   AES*/
VWORK_INFO		vwk_info;					/*en retour...*/

OBJECT		*tree1,*tree2;					/*les 2 arbres*/
/*Ce sont des pointeurs sur des structures OBJECT,donc sur un tableau
de structures OBJECT.*/
char		*name="GEM_TEST.RSC";			/*Le nom du ressource*/



/*::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
	Initialisations GEM et VDI,remplissage des donn‚es ‚crans
Renvoie TRUE si tout va bien,FALSE s'il faut stopper
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::*/
int gem_init(void)
{
	int	i;
	appl_id=appl_init();		/*init classique de l'AES:on se d‚clare*/
	if (appl_id!=-1)			/*On existe vraiment pour le GEM ?	*/
	{
		for (i=0;i<10;i++)		/*Oui,alors paramŠtres v_opnvwk		*/
			work_in[i]=1;
		work_in[10]=2;
		handle=graf_handle(&i,&i,&i,&i);/*Demande l'id de l'‚cran r‚el	*/
		v_opnvwk(work_in,&handle,work_out);/*On ouvre l'‚cran virtuel	*/
		vwk_info.screen_w=work_out[0];	/*R‚cupŠre dans la structure	*/
		vwk_info.screen_h=work_out[1];	/*globale les infos principale	*/
		vwk_info.nb_color=work_out[13];	/*du VDI (ca sert notament pour	*/
		vwk_info.pal_size=work_out[39];	/*cr‚er des MFDB compatibles	*/
		vq_extnd(handle,1,work_out);	/*avec l'‚cran)					*/
		vwk_info.nb_planes=work_out[4];	/*Demande aussi nombre de plans	*/
		return 1;						/*de bits.//.Tout est OK		*/
	}
	return	0;							/*Erreur*/
}

void gem_exit(void)
{
	v_clsvwk(handle);					/*No comment...*/
	appl_exit();
}



/*:::::::::::::::::::::::::::::::::::::::::::::
 Extraction du texte format‚ dans un TEDINFO,
 renvoie l'adresse de la chaine pass‚e en
 paramŠtre.
 Attention,la chaine dest doit ˆtre assez
 grande pour acceuillir le r‚sultat...
 
 La chaine template comporte le masque de
 saisie (par exemple "________.___" pour un
 fichier).Les caractŠres '_' sont occup‚s
 par du texte (celui rentr‚ par l'utilisateur),
 les autres sont impos‚s et s'insŠrent dans
 le r‚sultat final.
 La chaine valid contient les caractŠres
 autoris‚s dans le texte (p.ex,pour un fichier
 ‡a sera 'F' ou 'p' ou 'P'),et ce caractŠre
 par caractŠre.
 Il y a deux maniŠres de faire:soit on lit
 toute la chaine template,mˆme si le texte
 est fini,soit on s'arrˆte quand on est au
 bout du texte.J'ai choisi la seconde (c'
 est plus logique.Par exemple,avec le template
 de fichier,on pourrait avoir des resultats
 style "NAME____.___" en retour,au lieu de
 trouver "NAME").
 Les espaces sont control‚s et vir‚s s'ils ne
 sont pas admis (car l'AES en met par exemple
 si on rentre [NAME]+[.]+[EXT] on se retrouvera
 avec "NAME    .EXT",alors que les espaces sont
 interdits pour un fichier).
 Dans l'exemple de ressource utilis‚,il peut
 sembler bizarre de voir sortir "EDIT:" devant
 le texte entr‚ par l'utilisateur.Mais c'est
 normal,car EDIT fait partie du template dans
 notre exemple.
:::::::::::::::::::::::::::::::::::::::::::::*/
char *read_ftext(char *dest,OBJECT *tree,int objc)
{
	register char *text,*tmpt,*vlid;
	char	*save=dest;							/*Conserve adresse	*/
	text=tree[objc].ob_spec.tedinfo->te_ptext;	/*adresse des champs*/
	tmpt=tree[objc].ob_spec.tedinfo->te_ptmplt; /*de donn‚es		*/
	vlid=tree[objc].ob_spec.tedinfo->te_pvalid;

	while ( *tmpt && *text)			/*Tant que template non fini*/
	{								/*et texte non fini...		*/
		*dest=*(tmpt++);			/*lire template				*/
		if	( *dest=='_' )			/*si caractŠre "transparant"*/
		{
			*dest=*(text++);		/*alors remplace par texte	*/
			if	( *dest==' ' &&
				  (*vlid=='9' ||
				   (*vlid | 0x20 )=='f' ||
				   (*vlid | 0x20 )=='p'
				  )
				)					/*Si espace non-autoris‚	*/
				dest--;				/*alors saute le caractŠre	*/
			vlid++;					/*Validation suivante		*/
		}
		dest++;						/*un caractŠre de plus !	*/
	}
	*dest=0;						/*Force la fin de chaine	*/
	return	dest;					/*Renvoie l'adresse			*/
}


/*::::::::::::::::::::::::::::::::::::
 Affiche et gŠre une boite de dialogue
::::::::::::::::::::::::::::::::::::*/
int show_dialog(OBJECT *tree,int ed_objc)
{
	int	x,y,w,h,ret;

	form_center(tree,&x,&y,&w,&h);/*Centre le dialogue sur l'‚cran
Cette fontion attend l'adresse de l'arbre sous forme de la valeur
d'un pointeur sur une structure OBJECT,ainsi que 4 pointeurs sur des
int (16 bits) dans lesquels sont retourn‚s les coordonn‚es de l'arbre
une fois centr‚*/

	form_dial(FMD_START,0,0,0,0,x,y,w,h);/*Sauvegarde de l'‚cran
On se sert des paramŠtres renvoy‚s par form_center pour indiquer
la zone concern‚e.Les 4 z‚ros sont des paramŠtres inutilis‚s*/

	form_dial(FMD_GROW,x,y,0,0,x,y,w,h);/*dessin d'un rectangle qui s'ouvre
C'est facultatif,la boite d‚marre de la taille indiqu‚e dans les
4 premiers paramŠtres aprŠs FMD_xxxx (ceux qui ‚taient … z‚ro tout …
l'heure) comme taille du rectangle au d‚part,et des paramŠtres renvoy‚s
par form_center comme taille finale*/

	objc_draw(tree,0,1000,0,0,vwk_info.screen_w,vwk_info.screen_h);
/*Dessin de l'arbre.Cette fonction attend:
   l'adresse de la structure OBJECT formant l'arbre concern‚
   l'index du premier objet (et sa descendance) … dessiner
          (0=tout dessiner)
   la profondeur du dessin (depuis le premier objet.1000 par d‚faut,
           pour tout dessiner,mais toute autre valeur convient)
   rectangle de clipping (dans lequel se fera le dessin).Par d‚faut,
           donne les coordonn‚es de l'‚cran.
Si on voulait dessiner un objet partiulier,ainsi que sa descendance
sur deux g‚n‚rations de profondeur,on indiquerait:
objc_draw(tree,OBJET,2,0,0,vwk_info.screen_w,vwk_info.screen_h);
*/

	ret=form_do(tree,ed_objc);   /*dessin puis gestion du dialogue
form_do attend l'adresse de l'arbre … g‚rer.En effet,nous avons:
       centr‚ l'arbre
       reserv‚ l'‚cran
       affich‚ l'arbre
il ne nous reste plus qu'… le faire interagir avec l'utilisateur.
tree est l'adresse de l'arbre (attention … ne pas afficher un arbre et
… en g‚rer un autre par form_do,y'a de quoi devenir fou (essayez !)),
ainsi que l'index de l'objet ‚ditable sur lequel doit etre plac‚ le
curseur en d‚but de gestion.Si y'a pas d'objet ‚ditable,faut mettre
-1.Et surtout ne pas se gourrer,car si on passe l'index d'un objet
comme un STRING ou n'importe quel objet n'ayant pas de TEDINFO,‡a
risque de planter sec.
form_do renvoie l'objet qui a provoqu‚ la sortie.Attention,le bit
15 est … 1 si la selection a eu lieu sur un double clik (tout du moins
il paraŒt..Personnellement,mon TOS 1.62 refuse cat‚goriquement de me
signaler les doubles cliks.Pourquoi tant de haine ?)*/

	form_dial(FMD_SHRINK,x,y,0,0,x,y,w,h);/*boite qui se ferme*/
	form_dial(FMD_FINISH,0,0,0,0,x,y,w,h);/*restitue l'‚cran
fonctionnement identique (et sym‚trique) aux deux autres appels
de form_dial,et encore une fois FMD_SHRINK est facultatif.*/ 

	return ret;                  /*renvoie objet s‚lectionn‚*/
}


/*:::::::::::::::::::::::::::::::
 gestion de l'arbre de dialogue 1
:::::::::::::::::::::::::::::::*/
int out_dialog(void)
{
	register int	ret;
	ret=show_dialog(tree1,TEDOBJC);	/*gŠre l'arbre 1,le curseur se
									pla‡ant sur l'objet ‚ditable*/
	tree1[ret].ob_state&=(~SELECTED);/*d‚selectionne l'objet qui
	a provoqu‚ la sortie.tree1 est un pointeur d'OBJECT,donc l'
	expression tree1[ret] d‚signe l'objet d'index ret dans l'arbre
	tree1.Ensuite,tree1[ret].ob_state accŠde … la structure de
	l'objet ret.On le masque (&) pour annuler le bit SELECTED
	(car ~SELECTED=NOT SELECTED en bon franglais).
	*/
	return	ret;/*retourne le num‚ro cliqu‚*/
}

/*:::::::::::::::::::::::::::::::::::::::::::::::::::::::::
 Gestion de l'arbre de dialogue 2
 --------------------------------
 Attention,nous faisons des accŠs directs
 aux chaines de caractŠres contenues dans le fichier
 ressource.Or celles-ci sont … la queue-leu-leu en m‚moire,
 et de taille fix‚e lors de la cr‚ation du ressource.Donc
 si on essaye de mettre qqch de trop grand,on ‚crase tout.
 Il faut donc,quand on cr‚e le ressource,mettre des textes
 suffisament longs dans les objets (mˆme si,comme ici,ces
 textes seront remplac‚s.C'est leur taille qui importe).
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::*/
int out_info(int sel)
{
	register int	ret;
	register char	*rbe;

	rbe=tree2[RBE].ob_spec.free_string;
	if	(tree1[RB1].ob_state&SELECTED)
		sprintf(rbe,"CHOIX 1");
	else 
		sprintf(rbe,"CHOIX 2");
	if (tree1[RB3].ob_state&SELECTED)
		strcat(rbe," + CHOIX 3");
	else if	(tree1[RB4].ob_state&SELECTED)
		strcat(rbe," + CHOIX 4");
/*En testant s‚quenciellement les ‚tats des diff‚rents r_button du
formulaire,on construit un chaine de caractŠre.Vous remarquerez que
les radios-boutons sont regroup‚s par 2,et que les 2 de gauches sont
tous deux d‚selectionn‚ au lancement du programme.On aurait pu
mettre plusieurs radio-boutons frŠres … l'‚tat SELECTED:peu importe,
c'est le clik sur l'un d'entre eux qui d‚selectionne les autres*/

	ret=sel&0x7fff;
	rbe=tree2[OS].ob_spec.free_string;
	switch	( ret )
		{
		case	SORTIE1:
			sprintf(rbe,"Bouton TOUCHEXIT");
			break;
		case	SORTIE2:
			sprintf(rbe,"Bouton EXIT");
			break;
		default:
			sprintf(rbe,"Ic“ne");
			break;
		}
/*Maintenant,selon le num‚ro d'objet de sortie de l'autre formulaire,
on affiche un texte diff‚rent.Encore une fois,nous acc‚dons directement
… la chaine dans le RSC,donc il faut qu'elle soit,dŠs la cr‚ation du
formulaire,assez grande.*/
		
	ret=1;
	if	( sel&0x8000 )
		ret=2;
	sprintf(tree2[NC].ob_spec.free_string,"%d",ret);
	tree2[TE].ob_spec.free_string=tree1[TEDOBJC].ob_spec.tedinfo->te_ptext;
	read_ftext(tree2[TF].ob_spec.free_string,tree1,TEDOBJC);
	ret=show_dialog(tree2,-1);/*-1 car ce dialogue n'a pas d'EDITABLE*/
	tree2[ret].ob_state&=(~SELECTED);
	return	( ret!=QUIT );
}
	
	

/*:::::::::::::::::::::::::::::
 Boucle principale du programme
:::::::::::::::::::::::::::::*/
int main(void)
{
	register int	ret;
	if	( gem_init() )
	if	( rsrc_load(name) )
/*Demande le chargement du ressource.TRUE si tout va bien*/
	{
		graf_mouse(3,(MFORM *)0);/*Souris en forme de main*/

		rsrc_gaddr(0,DIALOGUE,(void *)&tree1);/*r‚cupŠre les adresse*/
		rsrc_gaddr(0,INFOS,(void *)&tree2);/*des deux arborescences */
/*le 0 comme 1er paramŠtre indique que l'on veut l'adresse d'un arbre,
il y a d'autres paramŠtrages possibles,mais inutilisables en temps normal*/

		while ( out_info(out_dialog()) );
		/*affiche et gŠre le dialogue principal,dont on passe le	*/
		/*r‚sultat au dialogue d'information						*/
		rsrc_free();			/*Toujours lib‚rer la m‚moire prise
								par le fichier ressource,avant de
								sortir */
		gem_exit();				/*si fini,on se casse*/
	}
	else
		printf("Initialisation impossible");

	return	0;/*retourne 0,pour pas que le TurboC gueule au retour	*/
}