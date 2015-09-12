
/* Basic -> 'C' šbersetzung */

#include <b_nach_c.h>

/* Globale Variablen */

int CHAR;

long	*r_long_f;
long	abbruch_long;
long	ausgabe_long;
long	ex_long;
long	form1_long;
long	h_long;
long	i_long;
long	ikon1_long;
long	nac_long;
long	ok_long;
long	ort_long;
long	radio_long;
long	str_long;
long	tree_adr_long;
long	vor_long;
long	w_long;
long	x_long;
long	y_long;
long	radio_long;
char	nachnamchar[C_HAR];
char	*nachnam_char;
char	ortchar[C_HAR];
char	*ort_char;
char	strassechar[C_HAR];
char	*strasse_char;
char	vornamechar[C_HAR];
char	*vorname_char;
char	ortchar[C_HAR];
char	*ort_char;

void	main()
	{
	r_ein(1);
	CHAR = C_HAR;

	nachnam_char = &nachnamchar[0];
	ort_char = &ortchar[0];
	strasse_char = &strassechar[0];
	vorname_char = &vornamechar[0];
	ort_char = &ortchar[0];
	/*  ** Dialogbox-Verwaltung */
	/*  */
	if((r_long_f = (long *)calloc((size_t)(3+1),(size_t)sizeof(long ))) == 0L)
			f_ehler(0);
		else
			SPEICHER[SP++] = (char *)r_long_f;
	/*  */
	form1_long=0;	/*  Dialog */
	ikon1_long=1;	/*  ICON in Baum FORM1 */
	vor_long=2;	/*  FTEXT in Baum FORM1 */
	nac_long=3;	/*  FTEXT in Baum FORM1 */
	str_long=4;	/*  FTEXT in Baum FORM1 */
	ort_long=5;	/*  FTEXT in Baum FORM1 */
	abbruch_long=6;	/*  BUTTON in Baum FORM1 */
	ok_long=7;	/*  BUTTON in Baum FORM1 */
	r_long_f[(int)(1)]=8;	/*  BUTTON in Baum FORM1 */
	r_long_f[(int)(2)]=9;	/*  BUTTON in Baum FORM1 */
	r_long_f[(int)(3)]=10;	/*  BUTTON in Baum FORM1 */
	ausgabe_long=11;	/*  STRING in Baum FORM1 */
	/*  */
	DUMMY = rsrc_free();
	DUMMY = rsrc_load("A:\\GFA_TEST\\DIALOG.RSC");	/*  Resource laden */
	DUMMY = rsrc_gaddr(0,0,tree_adr_long);	/*  Adresse des Objektbaumes ermitteln */
	DUMMY = form_center(tree_adr_long,x_long,y_long,w_long,h_long);	/*  Objektbaumkoordinaten zentrieren */
	/*  */
	/*  Texte in den Edit-Feldern vorbelegen */
	(void) c_har(l_ong(ob_spec(tree_adr_long,vor_long),0,0),"Johann Sebastian",1);
	(void) c_har(l_ong(ob_spec(tree_adr_long,nac_long),0,0),"Bach",1);
	(void) c_har(l_ong(ob_spec(tree_adr_long,str_long),0,0),"Kantatengasse 77",1);
	(void) c_har(l_ong(ob_spec(tree_adr_long,ort_long),0,0),"Dresden",1);
	/*  */
	DUMMY = objc_draw(tree_adr_long,0,1,x_long,y_long,w_long,h_long);	/*  Objektbaum zeichnen */
	/*  */
	do
		{
		HVA = form_do(tree_adr_long,0);
		ex_long=HVA;	/*  Objekt mit Exit-Status angeklickt ? */
		/*  */
		/*  Texte aus den Edit-Feldern in entsprechende Strings einlesen */
		msprintf(vorname_char,"%s",c_har(l_ong(ob_spec(tree_adr_long,vor_long),0,0),0,0));
		msprintf(nachnam_char,"%s",c_har(l_ong(ob_spec(tree_adr_long,nac_long),0,0),0,0));
		msprintf(strasse_char,"%s",c_har(l_ong(ob_spec(tree_adr_long,str_long),0,0),0,0));
		msprintf(ort_char,"%s",c_har(l_ong(ob_spec(tree_adr_long,ort_long),0,0),0,0));
		/*  */
		for(i_long=1;i_long<=3;i_long++)
			{
			if(btst(ob_state(tree_adr_long,r_long_f[(int)(i_long)]),0))	/*  welcher radio-button */
				{
				radio_long=r_long_f[(int)(i_long)];	/*  wurde angeklickt ? */
				}
			}
		}
	while(!(ex_long==ok_long |  ex_long==abbruch_long));
	/*  */
	DUMMY = rsrc_free();	/*  reservierten Speicherplatz wieder freigeben */
	/*  */
	printf("\33E");
	printf("Ende mit : %ld\n",ex_long);
	printf("Vorname  : %s\n",vorname_char);
	printf("Nachname : %s\n",nachnam_char);
	printf("Strasse  : %s\n",strasse_char);
	printf("Ort      : %s\n",ort_char);
	printf("Radio    : %ld\n",radio_long);
	r_aus(0);
	}