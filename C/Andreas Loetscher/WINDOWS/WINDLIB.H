/*----------------------------------------------------------------*/
/* 								 Header-Datei zur Window-Library    			    	*/
/*																																*//* 										Autor: Andreas Loetscher  									*//* 									(c) 1992 Maxon Computer GmbH									*/
/*----------------------------------------------------------------*/

typedef enum
{
    FALSE,
    TRUE
}
boolean;

typedef struct w_d					/* Fenster-Struktur							 */
{
  GRECT max;      					/* Maximalgroesse                */
  GRECT work;			 		    	/* Arbeitsbereichgroesse 				 */  int   elements; 					/* Bestandteile des Fensters     */
  int   align;					    /* Faktor zur hor. Ausrichtung   */
  int   snap; 		  				/* Fenster snappen (TRUE/FALSE)  */
  int   full;			 		    	/* Full-Flag (TRUE/FALSE)        */
  int   scroll_x;					  /* Scrollwert fuer X-Achse			 */  int   scroll_y;					 	/* Scrollwert fuer Y-Achse			 */  int   doc_x;    					/* X-Position des Dokumentes     */  int   doc_y;		  		  	/* Y-Position des Dokumentes		 */  long  doc_length; 				/* Dokumentslaenge               */  int   doc_width;  				/* Dokumentsbreite               */  void  (*w_redraw)(void);  /* Pointer auf Redraw-Funktion	 */
  char  name[80];					 	/* Fenstername                   */
} WIND_DATA;


/*-----------------------------------*/
/* erweiterte open_window()-Funktion *//*-----------------------------------*/

int  open_window(char *w_name,								 /* Ptr auf Namensstring    */
								 void (*redraw)(),								 /* Ptr auf Redraw-Funktion */
								 int was,											 /* Liste der Elemente      */
								 int algn,										 /* align-Wert 						 */
								 boolean snp,									 /* snappen? (TRUE/FALSE)   */
								 int s_x, int s_y,						 /* Scrollwerte X/Y         */
								 int doc_l,int doc_w,					 /* Dokumentslaenge/-breite */
								 int x1,int y1,int w1,int h1,	 /* Startkoordinaten				 */                 int mx,int my,int mw,int mh); /* Maximalkoordinaten			 */

/*------------------------------*//* allgemeine Fensterverwaltung *//*------------------------------*/
void	handle_window(int buffer[]);