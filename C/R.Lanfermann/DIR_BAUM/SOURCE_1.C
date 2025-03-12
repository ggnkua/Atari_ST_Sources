/* 
	Zwischenstruktur fr die Verzeichnisstruktur
*/	

typedef struct _zwi {
	char z_name[14];		/* Name des Ordners */
 	int  z_vater;			/* Nummer des 'Vaters' */
	int  z_tflag;			/* Testflag 1=Baum auf S”hne getestet */
	}ZWI;
	