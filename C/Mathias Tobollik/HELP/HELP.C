/*-----------------------------------------------------*/
/* HELP.C                                              */
/* Funktionen fÅr Online-Hilfe "Help!"                 */
/*                                                     */
/* Sprache:  Turbo-C 2.0                               */
/*                                                     */
/* Autor:    (C)1990 Mathias Tobollik                  */
/*-----------------------------------------------------*/
#include <help.h>
#include <help_msg.h>


/* Vergleichsfunktion zum Stringsortieren: */
int stringcmp( char **s1, char **s2 );




/* Hilfefunktion --------------------------------------*/
int help( char *w, char *datei, int mode )
{
char *rs;
long start, len;     /* Dateiposition des Hilfetextes  */
char *text;          /* Zeiger auf Textpuffer          */
int t_lin;           /* Anzahl Zeilen im Text          */
int begline=0;       /* Nummer der obersten Zeile im
                                          Hilfefenster */
int event;           /* Ergebnis evnt_multi()          */
int Msgbuf[8];       /* Message-buffer                 */
char what[REF_LEN];  /* Puffer f. Suchbegriff          */
int cont=TRUE,       /* Semaphoren                     */
    escape=FALSE;

    strcpy( what, w );
    if( 0 != get_index( datei, what, &start, &len ) )
        return(-1);
    if( NULL==( text=get_mem(len) ) )
    {
        form_alert( 1, AL_MEMORY );
        return(-1);
    }
    if( 0 != get_help( datei, text, start, len ) )
        return(-1);
    
    t_lin=count_lin( text, len );
    if(mode==EXTERN) 
    {   h_depth=1;
        open_helpw();  }
    else
    {   h_depth++;
        send_redraw( hlp_win ); }

    /* Maustasten erst loslassen: */
    evnt_button( 2, 3, 0, &m_x, &m_y, &m_but, &key );
    do{
        event=evnt_multi( 
                    MU_KEYBD+MU_BUTTON+MU_MESAG, 2, 3, 1,
                    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, Msgbuf,
                    0, 0, &m_x, &m_y, &m_but, &key,
                    &taste, &clicks );

        if( event & MU_KEYBD )
        {
            if( taste==283 )    /* ESC-Taste ? */
                escape=TRUE;    /* Notausgang! */
        }
        if( (event & MU_BUTTON) && (refno > 0) )
        {
            if( NULL!=(rs=find_ref(m_x, m_y)) )
            {
                if( h_depth==H_DEPTH )
                    form_alert( 1, AL_DEPTH );
                else
                    escape=help(rs,datei,INTERN);
            }
        }
        if( event & MU_MESAG )
        {
            switch( Msgbuf[0] )
            {
            case WM_REDRAW:
                set_vslider( begline, t_lin );
                display_help(text, len, begline, t_lin);
                wind_set( hlp_win, WF_INFO, what );
                break;
            case WM_SIZED:
            case WM_MOVED:
                h_newdim( text, len, begline, t_lin,
                          Msgbuf[4], Msgbuf[5],
                          Msgbuf[6], Msgbuf[7] );
                break;
            case WM_ARROWED:
                switch( Msgbuf[4] )
                {
                case 0:                  /* Seite hoch */
                    h_vscr_page( -1, text, len, &begline,
                                                 t_lin );
                    break;
                case 1:                /* Seite runter */
                    h_vscr_page(  1, text, len, &begline,
                                                 t_lin );
                    break;
                case 2:                  /* Zeile hoch */
                    h_vscr_line( -1, text, len, &begline,
                                                 t_lin );
                    break;
                case 3:                /* Zeile runter */
                    h_vscr_line( 1, text, len, &begline,
                                                 t_lin );
                }
                break;
            case WM_VSLID:
                begline=vslider( Msgbuf[4], t_lin );
                send_redraw( hlp_win );
                break;
            case WM_TOPPED:
            case WM_NEWTOP:
                wind_set( hlp_win, WF_TOP );
                break;
            case WM_FULLED:
                h_fullwind( text, len, begline, t_lin );
                break;
            case AC_CLOSE:
                escape=TRUE;
                break;
            case WM_CLOSED:
                cont=FALSE;
            }
        }
        evnt_timer( 0, 0 );   /* AES-Ringpuffer leeren */
    }while( cont && (escape<=0) );
    fre_mem( text );
    if( mode==EXTERN )
        close_helpw();
    else
        send_redraw( hlp_win );
    h_depth--;
    return( escape );
}



/* Verweise prÅfen ------------------------------------*/
int check_help( char *file )
{
FILE *help, *indx, *error;
char hlp[MAXDIR],        /* Dateiname Hilfe-Quelldatei */
     ndx[MAXDIR],        /* Dateiname Indexdatei       */
     err[MAXDIR];        /* Dateiname Fehlerdatei      */
char key[REF_LEN], key2[REF_LEN];
char line[LINE_LEN], line2[LINE_LEN];
char *k;
long int zeile=1;

    strcpy( err, strcpy( ndx, strcpy(hlp,file) ) );
    change_ext( hlp, HSRC );
    change_ext( ndx, HNDX );
    change_ext( err, HERR );
    if( NULL==( help=fopen( hlp, "r" ) ) )
    {
        printf( "\nCAN'T OPEN FILE %s !", hlp );
        return( -1 );
    }
    if( NULL==( indx=fopen( ndx, "r" ) ) )
    {
        printf( "\nCAN'T OPEN FILE %s !", ndx );
        return( -2 );
    }
    if( NULL==( error=fopen( err, "w" ) ) )
    {
        printf( "\nCAN'T OPEN FILE %s !", err );
        return( -3 );
    }

    printf("\n CHECKING TEXT...\n" );
    while( NULL!=fgets( line, LINE_LEN-1, help ) )
    {
        k=line;
        if( line == strstr( line, "\\@") )     /* Ende */
            break;
            
        while( NULL!=( k=keycpy( key, k ) ) )
        {
            rewind( indx );
            do{
                if(NULL==(fgets(line2,LINE_LEN-1,indx)))
                {
                    fprintf(error,"%li: %s\n",zeile,key);
                    printf( "%li: %s\n", zeile, key );
                    break;
                }
                keycpy( key2, line2 );
            }while( 0!=strcmp( key+2, key2+2 ) );
        }
        zeile++;
    }
    fclose(help); fclose(indx); fclose(error);
    printf(" ...DONE !\n\n" );
    return( 0 );
}



/* Inhaltsverzeichnis erstellen -----------------------*/
int make_contents( char *datei, char **c, char *mem )
{
char ndx[MAXDIR], cnt[MAXDIR];
FILE *indx, *cnts;
long int i=0, n;
char z[LINE_LEN], zz[LINE_LEN];

    strcpy( cnt, strcpy( ndx, datei ) );
    change_ext( ndx, HNDX );
    change_ext( cnt, HCNT );
    if( NULL==( indx=fopen(ndx,"r") ) )
    {
        printf( "\n CAN'T OPEN %s !", ndx );
        return(-1);
    }    
    printf("\n MAKING CONTENTSFILE...\n" );
    while( NULL!=( fgets( zz, LINE_LEN-1, indx ) ) )
    {
        if( i==MAX_SRT )
        {
            printf( "\n CONTENTS OVERFLOW !" );
            return( -3 );
        }
        keycpy( z, zz );
        c[i]=mem;
        mem+=strlen( strcpy(c[i],z) )+1L;
        *(c[i]+1)='<';
        i++;
    }
    fclose( indx );
        
    qsort( (void *)c,(size_t)i,(size_t)4,
           (int(*)(void *, void*))stringcmp ); 
    
    if( NULL==( cnts=fopen(cnt,"w") ) )
    {
        printf("\n CAN'T OPEN %s !", cnt );
        return(-1);
    }
    for( n=0; n<i; n++ )
        fprintf( cnts, "\n%s", c[n] );
    fclose( cnts );
    printf( " ...DONE !\n" );
    return(0);
}

/* Vergleichsfunktion fÅr qsort() ---------------------*/
int stringcmp( char **s1, char **s2 )
{
    return( stricmp( *s1, *s2 ) );
}



/* Index- und Help-Datei erstellen --------------------*/
int make_help( char *file )
{
FILE *source;              /*           Quelltextdatei */
FILE *indx;                /*           Indexdatei     */
FILE *help;                /*           Hilfetextdatei */
char txt[MAXDIR],          /* Dateiname Quelltextdatei */
     ndx[MAXDIR],          /* Dateiname Indexdatei     */
     hlp[MAXDIR];          /* Dateiname Hilfetextdatei */
char z[LINE_LEN],          /* Puffer fÅr eine Zeile */
     t[REF_LEN+3];         /* Puffer fÅr SchlÅssel  */    
 
long index=0,              /* Index                 */
     length=0;             /* AbschnittslÑnge       */
int quit=FALSE;            /* Semaphore             */

    strcpy( hlp, strcpy( ndx, strcpy(txt,file) ) );
    change_ext( ndx, HNDX );
    change_ext( hlp, HHLP );
    if( NULL==( source=fopen(txt,"r") ) )
    {
        printf( "\nCAN'T OPEN FILE %s !", txt );
        getch(); exit(-1);
    }
    if( NULL==( indx=fopen(ndx,"w") ) )
    {
        printf( "\nCAN'T OPEN FILE %s !", ndx );
        getch(); exit(-1);
    }
    if( NULL==( help=fopen(hlp,"wb") ) )
    {
        printf( "\nCAN'T OPEN FILE %s !", hlp );
        getch(); exit(-1);
    }

    printf("\n WRITING INDEX...\n" );
    while( NULL!=fgets(z, LINE_LEN-1, source) && !quit )
    {
        if( z[0]=='\\')
        {
            switch( (int)(z[1]) )
            {
            case (int)'c':
                break;
            case (int)'.':
                ltoa( length-1, t+strlen(t), 10);         
       
                fputs( strcat(t,"\n"), indx );
                length=0;
                break;
            case (int)'@':
                quit=TRUE;
                ltoa( length-1, t+strlen(t), 10);
                fputs( strcat(t,"\n"), indx );
                break;
            case (int)'>':
                keycpy( t, z );
                ltoa( index, t+keylen(t), 10 );
                strcat( t, "," );
            default:
                fputs( z, help );
                index+=(long)strlen( z );
                length+=(long)strlen( z );
                break;
            }
        }
        else
        {
            fputs( z, help );
            index+=(long)strlen( z );
            length+=(long)strlen( z );
        }
        if( quit ) break;
    }
    fclose(help); fclose(indx); fclose(source);
    printf( " ...DONE ! \n\n" );
    return(0);
}



/* Fenster-Arbeitsbereich lîschen ---------------------*/
void cls_wind( int w_handle )
{
int r[4];    /* Rechteck */
    wind_get(w_handle,WF_WORKXYWH, r, r+1L, r+2L, r+3L );
    r[2] += r[0];
    r[3] += r[1];
    vsf_color( handle, 0 );
    vsf_interior( handle, FIS_HOLLOW ); 
    vr_recfl( handle, r );
}



/* Hilfetext anzeigen ---------------------------------*/
void display_help( char *buf, long buflen, int line,
                                           int lines )
{
int x,y,w,h;                           /* Rechteck     */
int n;                                 /* ZeilenzÑhler */
    v_hide_c( handle );
    wind_update( BEG_UPDATE );
    locate_ref( buf, buflen, line );
    wind_get( hlp_win, WF_FIRSTXYWH, &x, &y, &w, &h );
    do{
        if( set_clip( hlp_win, x, y, w, h ) )
        {
            cls_wind( hlp_win );
            for( n=line; n<line+hww_h/char_h; n++ )
                display_line( buf,buflen, line,n,lines );
        }
        wind_get( hlp_win, WF_NEXTXYWH, &x, &y, &w, &h );
    }while( w!=0 );
    wind_update( END_UPDATE );
    v_show_c( handle, 1 );
}



/* Eine Zeile im Fenster ausgeben ---------------------*/
void display_line( char *buf, long buflen, int begline,
                                    int line, int lines )
{
char s[LINE_LEN];       /* Stringpuffer   */
int col,colmn;          /* Spaltennummer  */
int eff,effects;        /* Texteffekte    */
char *p, *q;            /* Zeichenpointer */
    if( line >= begline && line < lines )
    {
        p=go_line( line, buf );     /* Zeilenanfang    */
        col = colmn = 0;            /* Spalte Null     */
        eff = effects = 0;
        q=s;                    /* Anfang Stringpuffer */
        while( p <= buf+buflen )
        {
            if( *p == '\\' )
            {
                if( p[1] != '\\' )
                {
                    switch( (int)p[1] )
                    {
                    case (int)'>': /*------- ErklÑrung */
                        eff = 1;    p += 2;
                        break;
                    case (int)'<': /*--------- Verweis */
                        eff = 9;    p += 2;
                        break;
                    default:       /*---- alles andere */
                        eff = 0;    p++;
                        break;
                    }
                    *q='\0';
                    vst_effects( handle, effects ); 
                    v_gtext( handle,
                        hww_x+char_w*colmn,
                        hww_y+char_h*(line-begline+1),s);
                    colmn = col;    effects = eff;
                    q=s;
                }
                else
                {
                    p++;
                }
            }
            *q=*p;
            if( *p == '\n' || p >= buf+buflen )
            {
                *q='\0';
                vst_effects( handle, effects ); 
                v_gtext( handle,
                    hww_x+char_w*colmn,
                    hww_y+char_h*(line-begline+1),s);
                break;
            }
            q++; p++; col++;
        }
    }
}



/* Verweis invertieren --------------------------------*/
void mark_ref( refer *ref )
{
int rect[4];          /* Rechteck, das invertiert wird */
    v_hide_c( handle );

    rect[0]=ref->x;
    rect[1]=ref->y;
    rect[2]=ref->x + ref->w;
    rect[3]=ref->y + ref->h;
    vswr_mode( handle, MD_XOR );
    vsf_color( handle, 2 ); vsf_style ( handle, 8 );
    vsf_interior( handle, FIS_SOLID );
    vr_recfl( handle, rect );
    vswr_mode( handle, MD_REPLACE );

    v_show_c( handle, 1 );
}



/* Clipping auf öberschneidungsbereich zwischen dem ange-
gebenen Rechteck und dem Arbeitsbereich des Fensters 
setzen ------------------------------------------------*/
int set_clip( int w_handle, int x, int y, int w, int h )
{
int wx, wy, ww, wh;         /* Rechteck Arbeitsbereich */
    wind_get(w_handle, WF_WORKXYWH, &wx, &wy, &ww, &wh);
    if( x >= wx+ww || y >= wy+wh || x+w <= wx 
                                           || y+h <= wy )
        return( FALSE );

    if( x < wx )
        clip[0]=wx;
    else             
        clip[0]=x;

    if( y < wy )
        clip[1]=wy;
    else
        clip[1]=y;

    if( x+w > wx+ww )
        clip[2]=wx+ww-1;
    else
        clip[2]=x+w-1;

    if( y+h > wy+wh )
        clip[3]=wy+wh-1;
    else
        clip[3]=y+h-1;

    vs_clip( handle, 1, clip );
    return( TRUE );
}



/* Arbeitsbereich vertikal verschieben ----------------*/
void wind_vmove( int w_handle, int delta_y )
{
int wx, wy, ww, wh;      /* Fenster-Arbeitsbereich     */
int rec[4];              /* Rechteck                   */
int pxy[8];              /* Quell- und Zielkoordinaten */
MFDB source, destin;     /* Die MFDBs fÅr's Kopieren   */
                         /* im Bildschirmspeicher      */

    wind_get(w_handle, WF_WORKXYWH, &wx, &wy, &ww, &wh);
    wh--;     /* kleine kosmetische Korrektur */
    if( delta_y > 0 )
    {                           /* nach unten */
        pxy[0] = wx;
        pxy[1] = wy;
        pxy[2] = wx + ww;
        pxy[3] = wy + wh - delta_y;
        pxy[4] = wx;
        pxy[5] = wy + delta_y;
        pxy[6] = wx + ww;
        pxy[7] = wy + wh;

        rec[0] = wx;       rec[1] = wy;
        rec[2] = wx + ww;  rec[3] = wy + delta_y;
    }
    else
    {                            /* nach oben */
        pxy[0] = wx;     
        pxy[1] = wy - delta_y;
        pxy[2] = wx + ww;
        pxy[3] = wy + wh - 1;
        pxy[4] = wx;
        pxy[5] = wy;
        pxy[6] = wx + ww;
        pxy[7] = wy + wh + delta_y;

        rec[0] = wx;       rec[1] = wy + wh + delta_y;
        rec[2] = wx + ww;  rec[3] = wy + wh;
    }

    source.fd_addr = destin.fd_addr = NULL;
    vro_cpyfm( handle, S_ONLY, pxy, &source, &destin );

    vsf_color( handle, 0 );
    vsf_interior( handle, FIS_HOLLOW ); 
    vr_recfl( handle, rec );
}



/* Hilfetext in Puffer laden --------------------------*/
int get_help( char *file, char *buf, long start, 
              long length )
{
char hlp[MAXDIR];          /* Dateiname Hilfetextdatei */
FILE *help;
    strcpy( hlp, file );
    change_ext( hlp, HHLP );
    if( NULL == ( help = fopen( hlp, "rb" ) ) )
    {
        form_alert( 1, AL_HLPDAT );
        return(-1);
    }
    fseek( help, start, SEEK_SET );
    fread( buf,(size_t)1,(size_t)length,help );
    fclose( help );
    return( 0 );
}



/* Indexdaten zu SchlÅsselwort liefern ----------------*/
int get_index( char *file, char *key, long *start,
               long *length )
{
char ind[MAXDIR],             /* Dateinmame Indexdatei */
     line[LINE_LEN],          /* Puffer fÅr Zeile      */
     item[REF_LEN];           /* Puffer fÅr SchlÅssel  */
FILE *index;
    change_ext( strcpy( ind, file ) , HNDX );
    if( NULL==( index=fopen( ind, "r" ) ) )
    {
        form_alert( 1, AL_INXDAT );
        return(-2);
    }
    do{               /* passenden Indexeintrag suchen */
        if( NULL==fgets( line, LINE_LEN-1, index ) )
        {
            fclose( index );
            form_alert( 1, AL_UNKNWN );
            return(-1);
        }
    }while( 0!=strcmp( keyw(item,line), key ) );
    fclose( index );
    offset( line, start, length );
    return( 0 );
}



/* Hilfe-Window schlieûen -----------------------------*/
void close_helpw( void )
{
    wind_close( hlp_win );
    wind_delete( hlp_win );
    vs_clip( handle, 0, clip );
}



/* Hilfefenster auf volle Grîûe setzen oder wieder ver-
   kleinern -------------------------------------------*/
void h_fullwind( char *buf, long buflen, int line,
                                         int lines )
{
static int o_x, o_y, o_w, o_h;   /* Fenster(auûen)maûe */
static int first=TRUE;           /* erster Aufruf ?    */ 
/* falls jemand bei voller Fenstergrîûe das FULLER-Symbol
zum ersten Mal anklickt, mÅssen die Fenstermaûe sinnvolle
Werte enthalten. Daher: */
	if( first )
	{ 
	    first=FALSE;
	    o_x = 0;           o_y = cell_h;
	    o_w = x_res / 2;   o_h = y_res / 2 - o_y;
	}

    if( (hwo_w < x_res) || (hwo_h < y_res-cell_h) ) 
    {                       /* auf volle Grîûe bringen */
        o_x = hwo_x;    o_y = hwo_y;
        o_w = hwo_w;    o_h = hwo_h;
        h_newdim( buf, buflen, line, lines,
                  0, cell_h, x_res, y_res - cell_h );
    }
    else
    {                       /* auf alte Grîûe bringen  */
        h_newdim( buf, buflen, line, lines,
                  o_x, o_y, o_w, o_h );
    }
}



/* Hilfefenster auf neue Position/Grîûe setzen --------*/
void h_newdim( char *buf, long buflen, 
               int line, int lines,
               int ox, int oy, int ow, int oh )
{
    hwo_x = ox;  hwo_y = oy;
    hwo_w = ow;  hwo_h = oh;
    if( hwo_w < 4*cell_w )
        hwo_w=4*cell_w;
    wind_set( hlp_win, WF_CURRXYWH,
              hwo_x,  hwo_y,  hwo_w,  hwo_h );
    wind_get( hlp_win, WF_WORKXYWH,
              &hww_x, &hww_y, &hww_w, &hww_h );
    set_vslider( line, lines );        
    set_clip( hlp_win, 0, 0, x_res, y_res );
    locate_ref( buf, buflen, line );
}



/* Hilfefenster vertikal um eine Zeile scrollen -------*/
void h_vscr_line( int up_down, char *buf, long buflen, 
                                  int *line, int lines )
{
    v_hide_c( handle );
    wind_update( BEG_UPDATE );
    /* Clipping: Ganzer Hilfefenster-Arbeitsbereich */
    set_clip( hlp_win, 0, 0, x_res, y_res );
    if( up_down > 0 && *line < lines-hww_h/char_h )
    {                           /* nach oben scrollen  */
        (*line)++;
        wind_vmove( hlp_win, char_h * -1  );
        display_line( buf, buflen, *line,
                       *line+hww_h/char_h-1, lines );
        set_vslider( *line, lines );
        locate_ref( buf, buflen, *line );
    }
    if( up_down < 0 && *line > 0 ) 
    {                           /* nach unten scrollen */
        (*line)--;
        wind_vmove( hlp_win, char_h );
        display_line( buf, buflen, *line, *line, lines );
        set_vslider( *line, lines );
        locate_ref( buf, buflen, *line );       
    }
    wind_update( END_UPDATE );
    v_show_c( handle, 1 );
}



/* Hilfefenster vertikal um eine Seite scrollen -------*/
void h_vscr_page( int up_down, char *buf, long buflen, 
                                  int *line, int lines )
{
    v_hide_c( handle ); 
    wind_update( BEG_UPDATE );
    /* Clipping: Ganzer Hilfefenster-Arbeitsbereich */
    set_clip( hlp_win, 0, 0, x_res, y_res );
    if( up_down > 0 )
        *line+=hww_h/char_h;/* nach oben scrollen  */
    else
        *line-=hww_h/char_h;/* nach unten scrollen */
    if( *line < 0 ) 
        *line = 0;
    if( *line > lines - hww_h/char_h )
        *line = lines - hww_h/char_h;
    set_vslider( *line, lines );        
    display_help( buf, buflen, *line, lines );
    locate_ref( buf, buflen, *line );       
    wind_update( END_UPDATE );
    v_show_c( handle, 1 );
}



/* Hilfe-Window îffnen --------------------------------*/
int open_helpw( void )
{
   if( 0 > ( hlp_win = wind_create( HW_ATTRIB, 0, 0, 
                                 x_res, y_res ) ) )
   {
       form_alert( 1, AL_WINDOW );
       return( hlp_win );
   }
   wind_calc( WC_WORK, HW_ATTRIB,
              hwo_x, hwo_y, hwo_w, hwo_h,
              &hww_x, &hww_y, &hww_w, &hww_h);
   wind_set( hlp_win, WF_NAME, "   Help !  " );
   wind_set( hlp_win, WF_INFO , " ? " );
   wind_open( hlp_win, hwo_x, hwo_y, hwo_w, hwo_h );
   clip[0]=hww_x;         clip[1]=hww_y;
   clip[2]=hww_x+hww_w-1; clip[3]=hww_y+hww_h-1;
   vs_clip( handle, 1, clip );
   return( hlp_win );
}



/* Redraw-Message fÅr Fenster-Arbeitsbereich senden ---*/
void send_redraw( w_handle )
{
int m[8];                         /* Nachrichtenpuffer */
    wind_get(w_handle,WF_WORKXYWH,m+4L,m+5L,m+6L,m+7L);
    m[0]=WM_REDRAW; m[1]=ap_id;
    m[2]=0;         m[3]=w_handle;
    m[4]=hww_x;     m[5]=hww_y;
    m[6]=hww_w;     m[7]=hww_h;
    appl_write( ap_id, 16, m );
}



/* Vertikalen Schieber setzen ---------------------------
   b_lin:   erste Zeile im Fenster
   to_lin:  Gesamtzahl aller Zeilen im Text
   vi_lin:  Anzahl der im Fenster darstellbaren 
            Zeilen */
void set_vslider( int b_lin, int to_lin )
{
float vi_lin;
    vi_lin=(float)hww_h / (float)char_h;

    if( vi_lin>=(float)to_lin )
        wind_set( hlp_win, WF_VSLSIZE, 1000 );
    else
        wind_set( hlp_win, WF_VSLSIZE,
              (int)( 1000.0 * vi_lin / (float)to_lin ) );

    wind_set( hlp_win, WF_VSLIDE,
     (int)(1000.0*(float)b_lin /((float)to_lin-vi_lin)));
}



/* Aus Sliderposition neue Anfangszeile errechnen -----*/
int vslider( int slidepos, int to_lin )
{
float vi_lin;
    vi_lin=(float)hww_h / (float)char_h;
    return( (int)
         ( slidepos/1000.0 * ((float)to_lin-vi_lin) ) );
}



/* Extension in einem Dateipfad Ñndern ----------------*/
char *change_ext( char *name, const char *ext )
{
char *s, *f;
    f=strrchr( name,(int)'\\' );
    s=strrchr(name,(int)'.');
    if( s==NULL )
        return( strcat( name, ext ) );
    if( f==NULL || s > f )
    {
        strcpy( s, ext );
        return( name );
    }
    return( strcat( name, ext ) );
}



/* SchlÅssel suchen / kopieren ------------------------*/
char *keycpy( char *to, char *from )
{
char *s, *d;
    d=to;
    if( NULL !=( s = strchr(from,(int)'\\') ) )
    {
        /*--- Sonderfall: Ein "\\" ist kein SchlÅssel !*/
        if( s[1] == '\\' ) 
        {
            s ++; s++;    /*- Ich liebe Rekursionen ! -*/
        	return( keycpy( to, s ) );
        }
 
        do{
            *d++=*s++;
        }while( *s!='\\' && *s!='\0');

        if( *s=='\0' )
            return( NULL );
        *d++=*s++;
        *d='\0';
        return( s );
    }
    return( NULL );  
}



/* LÑnge eines SchlÅssels ermitteln -------------------*/
size_t keylen( char *keywd )
{
char *s;
size_t len=1;
    s=keywd;
    do{
        s++; len++;
    }while( *s!='\\' && *s!='\0');

    return( len );
}



/* SchlÅsselwort aus SchlÅssel herauskopieren ---------*/
char *keyw( char *to, char *from )
{
char *s, *d;
    s=from+2;
    d=to;
    while( *s!='\\' && *s!='\0' )
        *d++=*s++;
    *d='\0';                     /* String terminieren */
    return( to );
}



/* Indexzeile interpretieren --------------------------*/
void offset( char *zeile, long *index, long *length )
{
char *s;
    s = zeile + 1;  /* Wir beginnen beim 2. Buchstaben */
    while( *s++ != '\\' );    /* hier steht der Offset */
    *index = atol( s );
    while( *s++ != ',' );     /* und hier die LÑnge    */
    *length = atol( s );
}



/* Speicher freigeben ---------------------------------*/
void fre_mem( char *where )
{
    if( where==Mem_AreA )
    {
        LefT = 0L;
        Mfree( (void *)Mem_AreA );
        Mem_AreA = Mem_NexT = NULL;
    }
    else
    {
        LefT += ( Mem_NexT - where );
        Mem_NexT = where;
    }
}



/* Speicher reservieren -------------------------------*/
char *get_mem( long amount )
{
static int first = TRUE;              /* erster Aufruf */
long free;               /* freier Speicher ( GEMDOS ) */
    if( first )
    {
        Mem_AreA = Mem_NexT = NULL; 
        first = FALSE;
    }
    if( Mem_AreA == NULL )
    {
/* 15 kByte reservieren: */
        LefT = MBKSIZE * 1024L;
        free = (long)Malloc( -1L ); 
        if( free < LefT || LefT < amount )
            return( NULL );
        Mem_AreA = (char *)Malloc( LefT );
        Mem_NexT = Mem_AreA + amount;
        LefT -= amount;
        return( Mem_AreA );
    }
    else
    {
        if( LefT < amount )
            return( NULL );
        Mem_NexT += amount;
        LefT -= amount;
        return( Mem_NexT-amount );
    }
}



/* Anzahl der Zeilen im Textpuffer ermitteln ----------*/
int count_lin( char *puf, long puf_len )
{          /* es werden einfach die "Newlines" gezÑhlt */
long n;
int c=0;
    for( n=0; n<=puf_len; n++ )
        if( *puf++ == '\n' ) c++;
    return( ++c );
}



/* Zu Mausposition SchlÅsselwort suchen ---------------*/
char *find_ref( int x, int y )
{
int m;
    for( m=0; m<refno; m++ )
    {
        if( is_inside( x, y, ref[m].x, ref[m].y, 
                             ref[m].w, ref[m].h ) )
        {
            mark_ref( &(ref[m]) );
            return( ref[m].s );
        }
    }
    return( NULL );
}



/* Anfang der Zeile n in Puffer p suchen --------------*/
char *go_line( int n, char *p )
{
static char *puf = NULL;
static char *q;
static int z = -1;

    if( p != puf ) /* der gleiche Puffer wie vorher ? */
        z = -1;
        puf = p;	 /* merken, wo der Puffer zuletzt war */

    if( n == 0 )
    {
        z = -1;
	       return( p );
    }

    if( n == z + 1 )
    {
        p = q;
        z = n;
        while( *p++ != '\n' );
        q = p;
        return( p );    
    }

    if( n == z - 1 && z != 1)
    {
        p = --q;
        z = n;
        while( *(--p) != '\n' );
        q = ++p;
        return( p );
    }

    for( z=0; z<n; z++ )
        while( *p++ != '\n' );
    q = p;
    return( p );
}



/* Feststellen, ob a,b im Rechteck x,y,w,h liegt ------*/
int is_inside( int a, int b, int x, int y, int w, int h )
{
    if( a<x || b<y || a>x+w || b>y+h )
        return( FALSE );
    else
        return( TRUE );
}



/* Verweise im Fenster in Liste eintragen -------------*/
void locate_ref( char *buf, long buflen, int begline )
{
int colmn, line=0; /* Zeile, Spalte */
char *p;
    refno=0;                    /* kein Verweis gÅltig */
    p=go_line( begline, buf );  /* an den Anfang des 
                              angezeigten Textes gehen */
    while( p < buf+buflen && line < hww_h/char_h )
    {
        colmn=0;           /* Bei Spalte Null beginnen */
        while( p < buf+buflen && *p!='\n' )
        {
            if( *p=='\\' )
            {
                switch( (int)p[1] )
                {
                case (int)'\\':
                    colmn++;
                case (int)'>':
                    p += 2;
                    break;
                case (int)'<':
                    if( refno >= MAX_REF )
                    {
                        form_alert( 1,AL_REFNO );
                        p+=2;
                        break;
                    }
                    if( colmn < hww_w/char_w )
                    {
                        keyw( ref[refno].s, p );
                        ref[refno].x =
                                      hww_x+char_w*colmn;
                        ref[refno].y =
                                   hww_y+2+char_h*(line);
                        ref[refno].w =
                      char_w*(int)strlen(ref[refno].s)-1;
                        ref[refno].h = char_h;
                        refno++;
                    }
                    p+=2;
                    break;
                case (int)'\n':
                    break;
                default:
                    p++;
                }
            }
            p++; colmn++;
        }
        p++; line++;
    }
}

/*------------------- Ende HELP.C ---------------------*/
