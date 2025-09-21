/**************************************************************************/
/* Headerfile fÅr die Line-Axxx Grafikbefehle der ALIB-Bibliothek         */
/**************************************************************************/
/* Befehle der Bibliothek:                                                */
/*                                                                        */
/*   a_init();                             - Initialisiert die Routinen   */
/*   put_pixel(x,y,color);                 - setzt Punkt auf x,y mit der  */
/*                                           Farbe color                  */
/*   var = get_pixel(x,y);                 - gibt Farbe des Punktes x,y   */
/*   line(x1,y1,x2,y2,col1,col2,col3,col4,wr_mode,maske);                 */
/*                                         - zieht Linie von x1,y1 nach   */
/*                                           x2,y2 mit den Farben col1-4  */
/*                                           und dem Schreibmodus wr_mode */
/*                                           wobei das Linienmuster maske */
/*                                           verwendet wird               */
/*   hline(x1,y1,x2,col1,col2,col3,col4,wr_mode,patptr,patmask);          */
/*                                         - zieht horizontale Linie von  */
/*                                           x1,y1 nach x2,y1 mit dem Mus-*/
/*                                           ter, wobei patptr den Pointer*/
/*                                           auf die Maske und patmask die*/
/*                                           Verarbeitung der Wîrter der  */
/*                                           Maske darstellt. Sonst wie   */
/*                                           oben                         */
/*   set_clipping(flag,x1,y1,x2,y2);       - setzt Begrenzung der folgen- */
/*                                           den Grafikroutinen auf ein   */
/*                                           bestimmtes Rechteck, wobei   */
/*                                           die Begrenzung mit flag =    */
/*                                           TRUE ein- und mit flag =     */
/*                                           FALSE ausgeschalten wird     */
/*   fill_rectangle(x1,y1,x2,y2,col1,col2,col3,col4,wr_mode,patptr,patmask); */
/*                                         - fÅllt ein Rechteck mit Muster*/
/*                                           auf. Parameter siehe oben    */
/*   fill_polygon(xyarray,anz,y,col1,col2,col3,col4,wr_mode,patptr,patmask); */
/*                                         - fÅllt Polygon, wobei die X-Y */
/*                                           Koordinaten im xyarray und   */
/*                                           Anzahl der Linien in anz ge- */
/*                                           speichert sind               */
/*   put_char(zeichen,x,y);                - setzt ein Zeichen            */
/*                                           (vor diesem Aufruf sollte der*/
/*                                            Befehl set_font kommen!)    */
/*   set_font(fontnr,style,angle,scale_on,wr_mode);                       */
/*                                         - setzt nîtige Zeichenausgabe- */
/*                                           parameter.                   */
/*   put_string(string,x,y,abstand);       - setzt einen String mit dem   */
/*                                           Abstand abstand zwischen den */
/*                                           Zeichen                      */
/*   show_mouse();                         - zeigt die Maus               */
/*   hide_mouse();                         - lîscht Maus                  */
/*   new_mouse(cursor,mask);               - zeichnet neue Maus           */
/*   draw_sprite(x,y,data,ss_buf);         - zeichnet Sprite, wobei die   */
/*                                           erforderlichen Daten in data */
/*                                           gespeichert sind; ss_buff ist*/
/*                                           ein Array, in dem der Hinter-*/
/*                                           grund derweil gespeichert    */
/*                                           wird; seine Grîûe berechnet  */
/*                                           sich: Anzahl_Planes*32+5 Word*/
/*   undraw_sprite(ss_buf);                - lîscht Sprite wieder, wobei  */
/*                                           ss_buf die gleiche Adresse   */
/*                                           haben muû! wie oben!         */
/**************************************************************************/

/**************************************************************************/
/* folgende Structur 'sprite' kann fÅr eigene Spritedaten verwendet werden*/
/**************************************************************************/

struct a_daten {
     int back;
     int front;
};

struct sprite {
     int xoff;                       /* Offset vom Hot Spot */
     int yoff;
     int flag;                       /* 0 = VDI; 1 = Xor    */
     int col1;                       /* Hintergrundfarbe    */
     int col2;                       /* Vordergrundfarbe    */
     struct a_daten data[16];        /* 16 * (Back) & (Front) Spritedaten */
};

