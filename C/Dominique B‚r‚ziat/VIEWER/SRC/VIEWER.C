/*
 *  Viewer under WinDom2
 */

#include <av.h>
#include <windom.h>
#include <scancode.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <tos.h>
#include <dragdrop.h>
#include <time.h>

#include "viewer.h"
#include "error.h"

#define CONTROL_A 0x01
#define CONTROL_B 0x02
#define CONTROL_C 0x03
#define CONTROL_E 0x05	/* editor */
#define CONTROL_F 0x06
#define CONTROL_G 0x07
#define CONTROL_I 0x09	/* iconify */
#define CONTROL_K 0x0b	/* fuller */
#define CONTROL_L 0x0c
#define	CONTROL_M 0x0d
#define CONTROL_O 0x0f
#define CONTROL_P 0x10
#define CONTROL_Q 0x11
#define CONTROL_U 0x15
#define CONTROL_V 0x16
#define CONTROL_W 0x17
#define CONTROL_HELP	0x62

#define AP_QUIT	0x4444
#define AP_LOAD 0x4445

int mnu2key[] = {0,1,
				CONTROL_B,CONTROL_O,CONTROL_U,CONTROL_W,CONTROL_I,
				CONTROL_K,CONTROL_E,CONTROL_C,CONTROL_P,CONTROL_F,
				CONTROL_G,CONTROL_M,CONTROL_V,CONTROL_HELP,CONTROL_L,
				CONTROL_Q};

#define ON 	1
#define OFF 0

#define CODE_ESCAPE ON

#define TE_NORMAL   	0x00	/* '@' 01000000 */
#define TE_GRAS			0x01	/* 'A' 01000001 */
#define TE_LEGER		0x02	/* 'B' 01000010 */
#define TE_ITALIQUE		0x04	/* 'D' 01000100 */
#define TE_SOULIGNE		0x08	/* 'H' 01001000 */
#define TE_EXPOSANT 	0x10	/* 'P' 01010000 */
#define TE_INDICE		0x20	/* '`' 01100000 */

#define WE_NORMAL		'@'
#define WE_ESCAPE		''
#define WE_COLOR		'#'
#define WE_FONT			'%'
#define WE_SIZE			'('
#define WE_SETNAMEFONT	'&'
#define WE_ENDOFSTRING  '.'
#define WE_BGCOLOR		'$'
#define WE_TABSIZE		'!'

typedef  char FONTNAME[33];

typedef struct {
		char 	*buff;
		long	bsize;
		long  	maxline;
		char	**line;
		char    name[255];
		char	info[255];
		int		edit;
		int		offset;
		int 	mode;
		int 	help;
		int		wcar, hcar;
		int		wcell, hcell;		/* Taille cellule de caractere */
		int 	lb1, cb1, lb2, cb2;	/* bloc management */
#if CODE_ESCAPE
		int 	bckgrd;
		int		flagfont;
		int		IdFont;
		int 	tab;
		FONTNAME *TableFont;
#endif
	} BUFFER;

typedef struct {
		int xwin, ywin, wwin, hwin;
		int dx, dy;
		int tab;
		int bckgrd;
		int text_color;
		int text_font;
		int text_size;
		int NumFont;
		int IdFont;
	} GLBL;

#define GET_BUFFER(win)	((BUFFER *)((win)->data))

/* Mode pour le champ edit */
#define NOEDIT 		0
#define SEARCH 		1
#define GOTOLINE 	2

#define MODE_HEXA	0x1
#define MODE_MACRO	0x2

GLBL global;
int  error, nosetup=0, DisplayEscapeCode=0;
char name[14] = "\0";
char path[255] = "\0";
WINDOW *WinHelp = NULL;
char colorpath[255] = "color.prg"; 
char macrospath[255] = "";
char editor[255] = "";
int color_silent = 0;
int editor_av=0;
int gdos, fgdos;

void SetInfo( WINDOW *);
WINDOW *BufferOpen( BUFFER *);

/************************* Buffers **************************/

/*
 *	Load a text in buffer
 */

BUFFER *BufferLoad( char *name)
{
	int fd;
	char *p, **line;
	long count, c;
	BUFFER *text;
		
	error = NO_ERROR;
	fd = (int)Fopen( name, FO_READ);
	if( fd < 0)
	{
		error = FILE_NOT_FOUND;
		return NULL;
	}
	text = (BUFFER*)malloc( sizeof(BUFFER));
	if( text == NULL)
	{
		error = MALLOC_STRUCT_ERR;
		return NULL;
	}

	text -> bsize = Fseek( 0L, fd, 2);
	strcpy( text->name, name);
	Fseek( 0L, fd, 0);
	
	text -> buff  = (char*)malloc( sizeof(char)*(text->bsize+1));

	if( text -> buff == NULL)
	{
		error = MALLOC_BUFFER_ERR;
		free( text);
		return NULL;
	}
	count = Fread( fd, text->bsize, text->buff);
	if( count != text->bsize)
		error = FILE_READ_ERR;
	Fclose( fd);
	text->mode = 0;
	text -> maxline = 1L;
	for( p=text->buff,c=0; c<count; c ++, p++)
	{
		switch( *p){
		case '\r':
			if( *(p+1) == '\n')
				continue;
		case '\n':
		case '\0':
			text->maxline ++;
			break;
		}
		if( *p>0 && *p < 9)
			text->mode = MODE_HEXA;
		if( c % 1400 == 0)
			MouseWork();
	}

	text -> line = (char **)malloc( sizeof(char *)*(text->maxline));
	if( text->line == NULL)
	{
		error = MALLOC_LINE_ERR;
		free( text->buff);
		free( text);
		return NULL;
	}
	line = text->line;
	*line++ = text->buff;
	for( p=text->buff, c=0; c<count; c ++, p++)
	{
		switch( *p){
		case '\r':
			if ( *(p+1) == '\n')
				continue;
		case '\n':
		case '\0':
			*line++ = p+1;
			break;
		}
		if( c % 700 == 0)
			MouseWork();
	}	
	*p = '\0';
	graf_mouse( ARROW, 0L);
	
	if( error != NO_ERROR)
		form_alert( 1, "[1][Erreur de chargement][Ok]");
	return text;
}

void BufferFree( BUFFER *text)
{
	free( (char **)text->line);
	free( (char*)text->buff);
	free( (BUFFER*)text);
}

/*
 *	Find string in buffer
 */

char *memstr( char *mem, char *str, size_t size)
{
	register char *p = mem;
	size_t len = strlen( str);
	
	while( p < mem+size) {
		if( *p == *str) {
			while( *str)
				if( *p++ != *str++) 
					return NULL;
			return p-len;
		}
		p++;
	}
	return NULL;
}

int BufferFind( BUFFER *text, char *str, size_t pos)
{
	char line[255];
	size_t len;
	
	while( pos < text->maxline)
	{
		
		len = min(254L, (pos+1 == text->maxline)? 
						strlen(text->line[pos]):
						text->line[pos+1]-text->line[pos]);
		strncpy( line, text->line[pos], len);
		if( strstr( line, str) != NULL)
			return ((int)pos);
		pos ++;
	
	}
	return -1;

/*
	char *pos;
	
	pos = text->line[line];
	pos = memstr( pos, str, text->bsize);
	if( pos == NULL)
		return -1;
	while( line < text->maxline) {
		if( text->line[line] < pos)
			line ++;
	}
	return (int)line; */
}

/*
 *	Display in info window a find error
 */

void FindError( WINDOW *win)
{
	static char buff_info[60];
	char *string;
			
			/* message: "%s" non trouv‚ */
	rsrc_gaddr( 5, FIND_MESSAGE, &string);
	sprintf( buff_info, string, GET_BUFFER(win)->info+GET_BUFFER(win)->offset);
	WindSet( win, WF_INFO, buff_info);
}

/*
 *	Skip escape code
 */

size_t skip_esc( char *p)
{
	size_t pos = 1;
	
	p++;
	switch( *p){
	case WE_ESCAPE:
		break;
	case WE_NORMAL:
		pos ++;
		break;
	case WE_COLOR:
	case WE_BGCOLOR:
	case WE_FONT:
	case WE_SIZE:
	case WE_TABSIZE:
		pos +=2;
		break;
	case WE_SETNAMEFONT:
		while (*p++ != WE_ESCAPE)
			pos ++;
		pos++;
		break;
	default:
		if( *p & WE_NORMAL)	/* standart attribut */
			pos ++;
	}
	return pos;
}

/*
 * convertit les tabulations en espace
 */

char *tab2spc( int tab, register char *dest, register char *src)
{
	register size_t i, count = 0, count2;
	char *beg = dest;
	
	while( *src != '\0' && 
		   *src != '\n' &&
		   *src != '\r' )
	{
		if( *src == '\t')
		{
			count2=0;
			i=(size_t)(dest-beg);
			while( /*i==count || (i % tab) != 0*/ i<count+tab)
			{
				*dest++ = ' ';
				i++;
			}
			src ++;
			count += tab;
		}
		else
		{/*
			if( *src == WE_ESCAPE && !DisplayEscapeCode)
			{
				i = skip_esc( src);
				while( i--)
					*dest++ = *src++; 
			} else*/
			{
				*dest++ = *src++; 
				count2 ++; 
				if( count2 % tab == 0)
					count += tab;
			}
		}
	}
	*dest = '\0';
	return beg;
}

char *str_cpy( char *dest, char *src, char *end)
{
	char *p;
	
	p = strpbrk( src, end);
	if( p)
		return( strcpy( dest, src));
	else {
		strncmp( dest, src, p - src);
		dest[p-src]='\0';
	}
	return dest;	
}

/*
 *	Extract filename from a complet path
 */

char *GetFileName( char *path)
{
	char *p = strrchr( path, '\\');
	
	if( p)
		return( p + 1);
	else
	return path;
}

/*
 *	Extract pathname from a complet filename
 */

void GetPath( char *path, char *filename)
{
	char *p;
	
	strcpy( path, filename);
	if ( (p = strrchr( path, '\\')) != NULL)
		*p = '\0';
	else
		*path = '\0';
	
}

/*********************** Windows ***********************/

/*
 *	Drawing window
 */


/*
 *	Draw a bloc in buffer
 */

void draw_bloc( WINDOW *win, int l1, int c1, int l2, int c2)
{
	int x, y, w, h;
	int pxy[4];
	int line;
		
	/* l1<=l2 */
	/* c1<=c2 */
	if( l1>l2)
	{
		x = l1;
		l1=l2;
		l2=x;
	}
	if( c1>c2)
	{
		x = c1;
		c1=c2;
		c2=x;
	}
	WindGet( win, WF_WORKXYWH, &x, &y, &w, &h);
	vswr_mode( win->graf.handle, MD_XOR);
	vsf_color( win->graf.handle, 1);
	line = l1;
	while( line <= l2)
	{
		if( line == l1)
		{
			pxy[0]=x+(c1-win->xpos)*GET_BUFFER(win)->wcell;
		}
		else
		{
			pxy[0]=x;
		}
		pxy[1]=y+(line-win->ypos)*GET_BUFFER(win)->hcell;
		pxy[2]=(line==l2)?(pxy[0]+(c2-c1+1)*GET_BUFFER(win)->wcell+1):(x+w-1);
		pxy[3]=pxy[1]+GET_BUFFER(win)->hcell+1;
		line++;
		graf_mouse( M_OFF, 0L);
		v_bar( win->graf.handle, pxy);
		graf_mouse( M_ON, 0L);
	}
	vsf_color( win->graf.handle,global.bckgrd);
	vswr_mode( win->graf.handle, MD_REPLACE);
}

void draw_icon( WINDOW *win)
{
	int x,y,w,h;
	OBJECT *tree;
	
	WindGet( win, WF_WORKXYWH, &x, &y, &w, &h);	
	rsrc_gaddr( 0, 0, &tree);
	tree->ob_x=x;
	tree->ob_y=y;
	strncpy( tree[1].ob_spec.ciconblk->monoblk.ib_ptext, GetFileName(((BUFFER*)win->data)->name), 13);
	objc_draw( tree, 0, 8, clip.g_x, clip.g_y, clip.g_w, clip.g_h);
}

#if !CODE_ESCAPE

/*
 * Affichage du Texte
 * ------------------
 * Cette fonction est d‚clench‚ par EvntWindom() sur 
 * reception du message WM_REDRAW. Attention, EvntWindom()
 * se charge lui meme de clipper la zone a redessiner suivant
 * la liste des rectangle de l'AES, donc on ne clippe jamais
 * ici, on se contente juste de dessiner le texte ...
 *
 * Variable utilises:
 *  win->xpos, win ->ypos represente la position des donn‚es
 *		(donc du texte ici) dans la fenetre.
 *  clip: la variable (GRECT) qui contient les coordonn‚es de
 *	      la zone clipp‚ par EvntWindom()
 */

void draw_text( WINDOW *win)
{
	int x,y,w,h;
	int i;
	int pxy[4];
	BUFFER *ptext = (BUFFER *)win->data;
	char buff[255];
	
	WindGet( win, WF_WORKXYWH, &x, &y, &w, &h);

	/* On affiche le fond de la fenˆtre */	
	vswr_mode( win->graf.handle, MD_REPLACE);
	pxy[0]=x; pxy[1]=y; pxy[2]=x+w-1;pxy[3]=y+h-1;
	v_bar( win->graf.handle, pxy);

	/* Le texte maintenant */
	vswr_mode( win->graf.handle, MD_TRANS);
	w = ptext -> hcell - ptext -> hcar;  		/* offset verticale du texte */
	for( i=win->ypos; i<ptext->maxline ; i++)	/* ptext->maxline == win->ypos_max		*/
	{											/* win->ypos_max est la valeur maximale	*/
		y += ptext->hcell;						/* admissible de win->ypos */
		if( y < clip.g_y)
			continue;  /* Ici on sort de la zone de clippage
						* donc pour optimiser le redraw on s'arrete ici */
		tab2spc( global.tab, buff, ptext->line[ i]); /* on converti les 
					   								  * les tab en espace */

		if( strlen( buff) > win->xpos) /* la ligne est-elle dans la fenetre? */
			v_gtext(win->graf.handle, x, y - w, buff + win->xpos);
		if (y > min(pxy[3], clip.g_y + clip.g_h-1)) /* sort-on de la zone clipp‚? */
			break;
	}
}

#else

/********************************************************************************************/

/*
	0 -> fonte par d‚faut
	1 -> font sytŠme
	les autres valeurs d‚pendent de l'utilisateur.
*/

void std_txt_drw( WINDOW *win)
{
	int x, y, w, h, effect=0, IdFont;
	int xy[4], pxy[8], quit, pos, winx, dum;
	register size_t i;
	char buff[256], *p, *q, NameFont[33];
	BUFFER *ptext;
	
	ptext = (BUFFER *)win->data;

	WindGet( win, WF_WORKXYWH, &x, &y, &w, &h);
	vswr_mode( win -> graf . handle, MD_REPLACE);
	vsf_color( win -> graf . handle, ptext -> bckgrd);

	xy[0]=x;xy[1]=y;xy[2]=x+w-1;xy[3]=y+h-1;
	v_bar( win->graf.handle, xy);

	vswr_mode( win -> graf . handle, MD_TRANS);
	w = ptext -> hcell - ptext -> hcar;
	
	for( i=win->ypos; i<ptext->maxline ; i++)
	{
		y += ptext->hcell;
		if( y < clip.g_y)
			continue;
		/* convertion des tabulation en espace */
		tab2spc( ptext->tab, buff, ptext->line[ i]);
		q = buff;
		quit = pos = 0;
		winx = win->xpos;
		
		if( DisplayEscapeCode)
		{
			if( strlen( buff) > win->xpos)
				v_gtext(win->graf.handle, x, y - w, buff + win->xpos);
		}
		else
		while(1)
		{
			/* q pointe sur une chaine sans s‚quence */
			
			p = strchr( q, WE_ESCAPE);

			if ( p == NULL)
			{
				quit = 1;
				p = q + strlen( q);
			}
			if( *(p+1) == WE_ESCAPE)
				p++;
			*p = '\0';

			if( strlen( q) > winx)
			{
				if( fgdos)
					v_ftext( win->graf.handle, x+pos, y-w, q + winx);
				else
					v_gtext( win->graf.handle, x+pos, y-w, q + winx);
				vqt_extent( win->graf.handle, q+winx, pxy);
				pos += (pxy[2] - pxy[0]);
			}
			winx = max(0,winx-(int)strlen( q));
			
			if( quit)
				break;
			
			if(*(p-1) != WE_ESCAPE)
			{
				switch( *++p) {
				case WE_COLOR:
					p++;
					if( app.color >= 16)
						vst_color( win->graf.handle, *p - '0');
					break;
				case WE_BGCOLOR:
					p++;
					if( app.color >= 16 && ptext -> bckgrd != *p - '0')
					{
						ptext -> bckgrd = *p - '0';
						snd_rdw( win);
						return;
					}
					break;
				case WE_TABSIZE:
					p++;
					if( ptext -> tab != *p - '0')
					{
						ptext -> tab = *p - '0';
						snd_rdw( win);
						return;
					}
					break;
				case WE_FONT:
					p++;
					if( !gdos) break;
					if( ! ptext -> flagfont)
						ptext -> flagfont = vst_load_fonts( win -> graf.handle, 0);
					if( *p == '0')	/* font par d‚faut */
					{
						vst_font( win -> graf.handle, ptext->IdFont);
						break;
					}
					if( ptext -> TableFont && ptext -> TableFont[ *p - '0'][0] != '\0')
					{
						int count;
					
						for( count=0; count<ptext->flagfont; count ++)
						{
							IdFont = vqt_name( win->graf.handle, count, NameFont);
							if( !strncmp( NameFont, ptext -> TableFont[*p-'0'], 33))
								break;
						}
					}
					else
						IdFont = vqt_name( win -> graf.handle, *p-'0', NameFont);
					vst_font( win -> graf.handle, IdFont);
					break;
				case WE_SIZE:
					p++;
					vst_height( win -> graf.handle, *p=='0'?(ptext->hcar):(*p-'0'),
								&dum, &dum, &dum, &dum);
					break;
				case WE_SETNAMEFONT:
				{
					char *s;
		
					/* Initialisation de la table des fontes - si gdos() - */
					
					if( gdos)
					{
						p++;
						IdFont = *p -'0';
						if( !ptext -> TableFont)
						{
							if( ! ptext -> flagfont)
								ptext -> flagfont = vst_load_fonts( win -> graf.handle, 0);
							ptext -> TableFont = (FONTNAME*) calloc( ptext -> flagfont ,
													sizeof( FONTNAME));
						}
					}
					p++;
					s=p;
					p = strchr( s, WE_ESCAPE); /* recherche de la fin de la string */
					if( p == NULL)	/* erreur */
					{
						p=s;
						p++;
						break;
					}
					*p='\0';
					if( gdos)
						strcpy( ptext->TableFont[IdFont], s);
					p++; /* skip '.' */
				}
				break;
				case WE_NORMAL:
					vst_alignment( win->graf.handle, 0, 0, &dum, &dum);
					effect = TE_NORMAL;
					vst_effects( win->graf.handle, effect);
					break;
				default:
					if( (*p & WE_NORMAL) == 0)
						break;
					*p &= 0xbf;
					if( *p & TE_EXPOSANT)
					{
						vst_alignment( win->graf.handle, 0, 2, &dum, &dum);
						break;
					}
					if( *p & TE_INDICE)
					{
						vst_alignment( win->graf.handle, 0, 4, &dum, &dum);
						break;
					}
					if( *p & TE_GRAS)
						effect |= TE_GRAS;
					if( *p & TE_LEGER)
						effect |= TE_LEGER;
					if( *p & TE_ITALIQUE)
						effect |= TE_ITALIQUE;
					if( *p & TE_SOULIGNE)
						effect |= TE_SOULIGNE;
					/* on verra + tard les cas exp et ind */
					vst_effects( win->graf.handle, effect);
				}
			}
			p ++;
			q = p;
		}
		if (y > min(xy[3], clip.g_y + clip.g_h-1))
			break;
	}
	if( ptext->lb1 != -1)
		draw_bloc( win, ptext->lb1, ptext->cb1, ptext->lb2, ptext->cb2);
}

#endif

#define SIZE_HEXA	15

void draw_hexa(WINDOW *win)
{
	int x, y, w, h, xy[4];
	char line[SIZE_HEXA*4+10],c;
	size_t i,j;
	BUFFER *ptext;

	ptext = (BUFFER *)win->data;

	WindGet( win, WF_WORKXYWH, &x, &y, &w, &h);
	vswr_mode( win -> graf . handle, MD_REPLACE);
	vsf_color( win -> graf . handle, ptext -> bckgrd);

	xy[0]=x;xy[1]=y;xy[2]=x+w-1;xy[3]=y+h-1;
	v_bar( win->graf.handle, xy);

	vswr_mode( win -> graf . handle, MD_TRANS);
	w = ptext -> hcell - ptext -> hcar;

	for( i=win->ypos; i<win->ypos_max; i++)
	{
		y += ptext->hcell;
		memset(line, ' ', SIZE_HEXA*4+10);
		for(j=0;j<SIZE_HEXA;j++)
		{
			if( i*SIZE_HEXA+j>=ptext->bsize)
				break;
				
			c = (ptext->buff[i*SIZE_HEXA+j]&0xF0)>>4;
			line[3*j]   = ((c<10)?'0':'7')+c;
			c = ptext->buff[i*SIZE_HEXA+j]&0x0F;
			line[3*j+1] = ((c<10)?'0':'7')+c;
			line[3*j+2] = ' ';
			line[3*SIZE_HEXA+j+1] = (ptext->buff[i*SIZE_HEXA+j]==0)?'.':ptext->buff[i*SIZE_HEXA+j];
		}
		line[SIZE_HEXA*3] = ' ';
		line[SIZE_HEXA*4+1] = '\0';
		v_gtext(win->graf.handle, x, y - w, line + win->xpos);
		if (y > min(xy[3], clip.g_y + clip.g_h-1)) /* sort-on de la zone clipp‚? */
			break;
	}
}

/*
 *	killing window
 */

void text_destroy( WINDOW *win)
{
	if( global.NumFont != -1)
		vst_unload_fonts( win -> graf.handle, 0);
	if( win == WinHelp)
		WinHelp = NULL;
	WindClose( win);
	BufferFree( (BUFFER *)win->data);
	WindDelete( win);
	if( wglb.first == NULL)
		snd_msg( NULL, AP_QUIT,0,0,0,0);
}

/*
 *	Keyboard evnts
 */
 
void text_keybd( WINDOW *win)
{
	int x, y;
	void command( WINDOW *win, int cmd);
	
	if( win->status & WS_ICONIFY)
		return;
	graf_mkstate( &x, &x, &x, &y);
	switch( evnt.keybd >> 8){
	case SC_UPARW:
		if( y & (K_LSHIFT | K_RSHIFT))
			snd_arrw( win, WA_UPPAGE);
		else 
			snd_arrw( win, WA_UPLINE);
		break;
	case SC_DWARW:
		if( y & (K_LSHIFT | K_RSHIFT))
			snd_arrw( win, WA_DNPAGE);
		else 
			snd_arrw( win, WA_DNLINE);
		break;
	case SC_RTARW:
		if( y & (K_LSHIFT | K_RSHIFT))
			snd_arrw( win, WA_RTPAGE);
		else
			snd_arrw( win, WA_RTLINE); 
		break;
	case SC_LFARW:
		if( y & (K_LSHIFT | K_RSHIFT))
			snd_arrw( win, WA_LFPAGE);
		else
			snd_arrw( win, WA_LFLINE);
		break;
	case SC_SPACE:
		if( y & (K_LSHIFT | K_RSHIFT))
			snd_arrw( win, WA_UPPAGE);
		else
			snd_arrw( win, WA_DNPAGE);
		break;
	case SC_HOME:
		if( y & (K_LSHIFT | K_RSHIFT))
		{
			wind_get( win->handle, WF_WORKXYWH, &x, &x, &x, &y);
			if( win->ypos + y/win->h_u < win->ypos_max);
			{
				win->ypos = win->ypos_max - y/win->h_u;
				snd_rdw( win);
				WindSlider( win, VSLIDER);
			}
		}
		else
		{
			if( win -> ypos )
			{
				win -> ypos = 0;
				snd_rdw( win);
				WindSlider( win, VSLIDER);
			}
		}
		break;
	default:
		command( win, evnt.keybd & 0xFF);
	}
}

/*
 *	buflen - return a string len accoording with 
 *	tabulation caractere
 *	used by draw_bloc
 */

int buflen( char *str)
{
	int i=0;
	
	while( *str)
	{
		if( *str == 9)
			i += global.tab;
		else
			i++;
		str ++;
	}
	return i;
}

/* mouse coord -> position in buffer */

void get_blocpos( WINDOW *win, int *l, int *c)
{
	int x, y, w, h;
	int len;
	
	WindGet( win, WF_WORKXYWH, &x, &y, &w, &h);
	*l = (evnt.my - y)/GET_BUFFER(win)->hcell + win->ypos;
	*c = (evnt.mx - x)/GET_BUFFER(win)->wcell + win->xpos;
	if( *l > win->ypos_max)
	{
		*c = 0;
		*l = win->ypos_max;
		return;
	}
	if( *l<0) *l = 0;
	len = buflen( ((BUFFER*)win->data)->line[*l]);
	*c = (*c>len)?len:*c;
	if( *c<0) *c = 0;
}

/*
 *	routine li‚ au evnt button (select a bloc)
 */

void text_but( WINDOW *win)
{
	char *string;
	BUFFER *text = (BUFFER*)win->data;
	int l,c;
	
	if( evnt.mbut & 0x02 || (text->mode & MODE_HEXA))
		return;
	graf_mkstate( &evnt.mx, &evnt.my, &evnt.mbut, &evnt.mkstate);
	if( !evnt.mbut)
	{
		text->lb1 = -1;
		snd_rdw( win);
		return ;
	}
	
	if( text->lb1 != -1)
	{
		text->lb1 = -1;
		snd_rdw( win);
		EvntWindom( MU_MESAG);
	}
	wind_update( BEG_MCTRL);
	get_blocpos( win, &text->lb1, &text->cb1);
	text->lb2 = text->lb1;
	text->cb2 = text->cb1; 
	while( evnt.mbut)
	{
		graf_mkstate( &evnt.mx, &evnt.my, &evnt.mbut, &evnt.mkstate); 
		get_blocpos( win, &l, &c);
		if( l != text->lb2 || c != text->cb2)
		{
			rsrc_gaddr( 5, INFO_BLOC, &string);
			sprintf( text->info, string, text->lb1, text->cb1, l, c);
			WindSet( win, WF_INFO, text->info);
			/* draw new bloc */
			draw_bloc( win, l, c, text->lb2, 
					((c>text->cb2)?(text->cb2+1):(text->cb2)));
			/* new bloc size */
			text->lb2 = l;
			text->cb2 = c;
		}
	}
/*	draw_bloc( win, text->lb1, text->cb1, text->lb2, text->cb2);*/
	
	
	rsrc_gaddr( 5, INFO_COPY, &string);
	sprintf( text->info, string);
	WindSet( win, WF_INFO, text->info);
	wind_update( END_MCTRL);
}

/*
 * Display Info about buffer in window
 */

void SetInfo( WINDOW *win)
{
	BUFFER *text = (BUFFER *) win->data;
	char *string;
	
	if( !text->edit) {
		rsrc_gaddr( 5, INFO_BUFFER, &string);
		sprintf( text->info, string, GetFileName( text->name), 
					win->ypos, win->ypos_max, text->bsize, ((text->mode & MODE_HEXA)?"hexa":"ascii"));
	}
	WindSet( win, WF_INFO, text->info);
}

/*
 *	Perform edition in info window
 */

char template[]="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOQRSTUVWXYZ 0123456789‚Š‡…—";

void edit_info( WINDOW *win, int c)
{
	BUFFER *ptext = win->data;
	char ascii[2];
	int pos;
	
	if(  (c&0x00FF) == 0 || !ptext->edit)
		return;
	switch( c>>8) {
	case 0x52:
	case 0x47:
	case 0x48:
	case 0x50:
	case 0x4B:
	case 0x4D:
		return;
	}
	ascii[1] = '\0';
	ascii[0] = (char) c;
	switch( ascii[0]){
	case 8:	/* backspace */
		if( strlen( ptext->info) > ptext->offset)
			ptext->info[ strlen( ptext->info)-1] = '\0';
		break;
	case 127:
		break;
	case 13:	/* return */
	case 27:	/* escape */
		ptext->edit = 0;			/* fin du mode d'‚dition */
		WindSlider( win, VSLIDER);
		break;
	default:
		if( strchr( template, ascii[0]) ) {
			strcat( ptext->info, ascii);
			if( ptext->edit == SEARCH)
				pos = BufferFind( ptext, ptext->info+ptext->offset, win->ypos);
			else 
				pos = min( win->ypos_max-1, atoi( ptext->info+ptext->offset));
			if( pos != -1)	/* ocurrence trouv‚ */
			{
				win->ypos = pos;
				snd_rdw( win);
				WindSlider( win, VSLIDER);
			}
			else {
				FindError( win);
				return;
			}
		}
	}
	SetInfo( win);
}

/*
 *	Create and open a buffer window 
 */
 
WINDOW* BufferOpen( BUFFER *ptext)
{
	WINDOW *win;
	static int i=0;
	int h,dum;
	int attrib[10];
	
	win = WindCreate( WAT_ALL, app.x, app.y, app.w, app.h);
	if( win == NULL)
		return NULL;

#if CODE_ESCAPE
	ptext -> bckgrd = global.bckgrd;
	ptext -> tab = global.tab;
	ptext -> TableFont = NULL;
	ptext -> flagfont = 0;
#endif

	/*
	 *	Gestion de la fonte
	 */

	if( global.NumFont != -1 && gdos)
	{
		char NameFont[33];
		
		ptext -> flagfont = vst_load_fonts( win -> graf.handle, 0);
		global.IdFont = vqt_name( win -> graf.handle, global.NumFont, NameFont);
		ptext -> IdFont = global.IdFont;
		vst_font( win -> graf.handle, global.IdFont);
		if( global.text_size != -1)
			vst_height( win -> graf.handle, global.text_size, &dum, &dum, &dum, &dum);
	}

	vqt_attributes( win->graf.handle, attrib);
	ptext->wcar  = attrib[ 6];
	ptext->hcar  = attrib[ 7];
	ptext->wcell = attrib[ 8];
	ptext->hcell = attrib[ 9];
	
	win -> icon.draw = draw_icon;
	win -> destroy = text_destroy;
	win -> keyhited = text_keybd;
	win -> clicked = text_but;
	/* Les autres fonctions de gestions des evenements sont
	 * standart donc inutile de les r‚‚crire ...
	 */
	rsrc_gaddr( 5, ICON_TITLE, &win->icon.name);
	vsf_interior( win->graf.handle, 1);
	vsf_color( win->graf.handle, global.bckgrd);
	vst_color( win->graf.handle, global.text_color);
	
	win->data = ptext;  						/* ici on lie les donn‚es (le texte) … la fenetre */
	win->h_min = win->h_u = ptext->hcell;	    /* win->h_u represente de decalage en pixel
							     				 * lors d'un scroll verticale */
	win->w_min = win->w_u = ptext->wcell;     /* idem pour scroll horizontale */
	win->status |= WS_GROW;
	/*
	 *	La bonne initialisation des champs h_u, w_u, xpos_max et ypos_max
	 *  permet la gestion automatique des evenements sliders des fenetres 
	 *	( voir doc WinDom)
	 */
	
	if( global.hwin == -1) {
		h = (int)ptext->maxline*win->h_u;
		h = min(h,app.h);
		WindCalc( WC_BORDER, win, app.x, app.y, global.wwin, h, &dum, &dum, &dum, &h);
		h = min( h, app.h);
	} 
	else h = global.hwin;
	
	WindOpen( win, global.xwin+i*global.dx, global.ywin+i*global.dy, global.wwin, h);
	i++;
	WindSet( win, WF_NAME, ptext->name);
	
	((BUFFER*)win->data)->edit = 0;
	ptext -> lb1 = -1;
	ptext -> help = INFO_HELP1;
	
	if( ((BUFFER *)win->data)->mode & MODE_HEXA)
	{
		if( global.NumFont != -1 && gdos)
			vst_font( win -> graf.handle, 0);

		win->redraw = draw_hexa;
		win->xpos = win->ypos=0;
		win->xpos_max=SIZE_HEXA*3;
		win->ypos_max=(int)((BUFFER *)win->data)->bsize/SIZE_HEXA;
	}
	else
	{
		if( global.NumFont != -1 && gdos)
			vst_font( win -> graf.handle, global.IdFont);
#if CODE_ESCAPE
		win -> redraw = std_txt_drw;
#else
		win -> redraw = draw_text;
#endif
		win->xpos = win->ypos=0;
		win->xpos_max=255;
		win->ypos_max=(int)((BUFFER *)win->data)->maxline;	
	}
	WindSlider( win, HSLIDER|VSLIDER);	
	SetInfo( win);

	return win;
}

void BufferReopen( BUFFER *ptext, WINDOW *win)
{
#if CODE_ESCAPE
	ptext -> bckgrd = global.bckgrd;
	ptext -> tab = global.tab;
	ptext -> TableFont = NULL;
	ptext -> flagfont = 0;
#endif
	vsf_color( win->graf.handle, global.bckgrd);
	vst_color( win->graf.handle, global.text_color);

	BufferFree( (BUFFER*)win->data);	
	win->data = ptext;  		/* ici on lie les donn‚es (le texte) … la fenetre */
	win->ypos_max = (int)ptext->maxline;	/* voir remarque dans draw_text */
	win->xpos_max = 255;
	win->xpos=win->ypos=0;
	WindSlider( win, HSLIDER|VSLIDER);
	WindSet( win, WF_NAME, ptext->name);
	SetInfo( win);
	
	((BUFFER*)win->data)->edit = 0;
	ptext -> lb1 = -1;
	ptext -> help = INFO_HELP1;
	snd_rdw( win);
}

/****************************************************************************/

int ExecGemApp( char *prg, char *cmd, int av)
{
	char name[14], *p;
	char aesid[9];
	char ext[4];
	char file[255];
	int id_app, msg[8];

	p = strrchr( prg, '\\');
	strcpy( name, p+1);
	p = strrchr( name, '.');
	*p = '\0';
	strcpy( ext, p+1);
	
	strcpy( file, " ");
	strcat( file, cmd);
	p = strrchr( file, '\\');
	
	if( av) {
		strcpy( aesid, "        ");
		strncpy( aesid, name, strlen( name));
		strupr( aesid);
		id_app = appl_find( aesid);
		if( id_app >= 0) {
			msg[0] = VA_START;
			msg[1] = app.id;
			msg[2] = 0;
			*(char **)&msg[3] = file;
		    msg[5] = 0;
    	    msg[6] = 0;
    	    msg[7] = 0;
    	    appl_write(id_app, 16, msg);
    	    return 1;
		}
	} 
	if( !stricmp( ext, "acc") ||
		!stricmp( ext, "acx") ) {
			return 0; /* … executer comme accesoire */
		}
	else
		return (shel_write(1,1,100, prg, file));
}

/*
 *	Reading setup
 */

void ReadSetUp( void)
{
	char dum[40];
	
	global.xwin=20;
	global.ywin=20;
	global.wwin=350;
	global.hwin=250;
	global.tab=5;
	global.bckgrd=0;
	global.text_color=1;
	global.dx=global.dy=10;
	global.NumFont = -1;
	global.text_size = -1;
	
	if( nosetup) return;
	
	ConfInquire( "window", "%d,%d,%d,%d", &global.xwin, &global.ywin,
										  &global.wwin, &global.hwin);
	ConfInquire( "next", "%d,%d", &global.dx, &global.dy);
	ConfInquire( "tabulator", "%d", &global.tab);
	if( app.color >= 16) {
		ConfInquire( "text_color", "%d", &global.text_color);
		ConfInquire( "background", "%d", &global.bckgrd);
	}
	if( gdos)
		ConfInquire( "font",  "%d,%d", &global.NumFont, &global.text_size);
	ConfInquire( "colorpath", "%s", colorpath);
	ConfInquire( "macrospath","%s", macrospath);
	if( ConfInquire( "color_opt", "%s", dum))
		if( !strcmp( dum, "silent"))
			color_silent = 1;
	ConfInquire( "editorpath", "%s", editor);
	ConfInquire( "editorav", "%b", &editor_av);
}

/*
 *	Ouvre une liste de buffer
 *	list est la liste des nom de fichiers s‚parer par un espace
 *	utiliser pour les message VA et D&D et selectric?
 */

void OpenList( char *list)
{
	BUFFER *text;
	WINDOW *win = NULL;
	char *p, *q;
	int stop = 0;
	
	p = q = list;
	
	do{
		if( *q == '-' && *(q+1) == 'f') { /* Protocol -f  */
			form_alert( 1, "[1][Protocol -f][Ok]");
			continue;
		}

		p = strchr( q, ' ');
		if( p == NULL || *p == '\0')
			stop = 1;
		else
			*p = '\0';
		text = BufferLoad( q);
		GetPath( path, q);
		if( text)
		{
			win = BufferOpen( text);
			SetInfo( win);
			EvntWindom( MU_MESAG);
		}
		if( !stop) q = p + 1;
	} while( !stop);
}

/*
 *	Menu functions
 */

void menu_new_buffer( WINDOW *win)
{
	BUFFER *text;
	char *string;
	char filename[255];
	
	name[0] = '\0';
	if( FselInput( path, name, "*.*", "Load new buffer") && *name != '\0' )
	{
		strcpy( filename, path);
		strcat( filename, name);
		text = BufferLoad( filename);
		if( text == NULL)
		{
			rsrc_gaddr( 5, ERR_BUFF_LOAD, &string);
			form_alert( 1, string);
			return;
		}
		BufferReopen( text, win);
	}
}

int menu_new_frame( void)
{
	BUFFER *text;
	WINDOW *win;
	char *string;
	char filename[255];
	
	*name='\0';
	if( FselInput( path, name, "*.*", "Load new frame") && *name )
	{
		strcpy( filename, path);
		strcat( filename, name);
		text = BufferLoad( filename);
		if( text == NULL)
		{
			rsrc_gaddr( 5, ERR_BUFF_LOAD, &string);
			form_alert( 1, string);
			return 0;
		}
		else
		{
			win = BufferOpen( text);
			SetInfo( win);
			return 1;
		}
	}
	return 0;
}

void import_clipbrd( void)
{
	BUFFER *text;
	WINDOW *win;
	char filename[255], *string;

	if( scrp_read( filename) != 0) {
		strcat( filename, "scrap.txt");
		text = BufferLoad( filename);
		if( text == NULL) {
			rsrc_gaddr( 5, ERR_BUFF_LOAD, &string);
			form_alert( 1, string);
		} else	{
			win = BufferOpen( text);
			SetInfo( win);
		}
	}
}

void menu_copy( WINDOW *win)
{
	BUFFER *text;
	size_t line, begin;
	FILE *fp;
	char scrapdir[255];
	
	if( scrp_read( scrapdir))
	{
						
		text = (BUFFER*)win->data;
		strcat( scrapdir, "SCRAP.TXT");
		fp = fopen( scrapdir, "w");
		if( text->lb1 == -1)	/* pas de bloc */
		{
			begin = 0;
			text->lb2 = (int)text->maxline;
			text->cb1 = 0;
			text->cb2 = 255;
		}
		else
			begin = text->lb1;
		for( line = begin; line < text->lb2; line++)
		{
		/*	if( line == text->lb2-1)
				strncpy( scrapdir, text->line[ line], text->cb2);
			fprintf( fp, "%s\n", scrapdir+(line==begin)?text->cb1:0); */
			
			tab2spc( text->tab, scrapdir, text->line[ line]);
	/*		str_cpy( scrapdir, text->line[ line], "\r\n"); */
			fprintf( fp, "%s\n", scrapdir);
		}
		fclose( fp);
	}
}

void menu_find( WINDOW *win)
{
	if( GET_BUFFER( win)->edit != SEARCH) {
		GET_BUFFER( win)->edit = SEARCH;
		strcpy( GET_BUFFER( win)->info, "search: ");
		GET_BUFFER( win)->offset = (int)strlen( "search: ");
		WindSet( win, WF_INFO, GET_BUFFER( win)->info);
	}
}

void goto_line( WINDOW *win)
{
	if( GET_BUFFER( win)->edit != GOTOLINE) {
		GET_BUFFER( win)->edit = GOTOLINE;
		strcpy( GET_BUFFER( win)->info, "goto-line: ");
		GET_BUFFER( win)->offset = (int)strlen( "goto-line: ");
		WindSet( win, WF_INFO, GET_BUFFER( win)->info);
	}
}

void menu_mode( WINDOW *win)
{
	((BUFFER *)win->data)->mode ^= MODE_HEXA;
	if( ((BUFFER *)win->data)->mode & MODE_HEXA)
	{
		if( global.NumFont != -1 && gdos)
			vst_font( win -> graf.handle, 0);

		win->redraw = draw_hexa;
		win->xpos = win->ypos=0;
		win->xpos_max=SIZE_HEXA*3;
		win->ypos_max=(int)((BUFFER *)win->data)->bsize/SIZE_HEXA;
	}
	else
	{
		if( global.NumFont != -1 && gdos)
			vst_font( win -> graf.handle, global.IdFont);

		win->redraw = std_txt_drw;
		win->xpos = win->ypos=0;
		win->xpos_max=255;
		win->ypos_max=(int)((BUFFER *)win->data)->maxline;	
	}
	WindSlider( win, HSLIDER|VSLIDER);
	snd_rdw(win);
	SetInfo( win);
}

void menu_find_again( WINDOW *win)
{
	int dum;
	
	if( ((BUFFER*)win->data)->edit == SEARCH)
	{
		dum = BufferFind( (BUFFER *)win->data, GET_BUFFER(win)->info+GET_BUFFER(win)->offset , win -> ypos+1);
		if( dum != -1)
		{
			win -> ypos = dum;
			snd_rdw( win);
			WindSlider( win, VSLIDER);
		}	
		else
			FindError( win);
	}
}

void menu_help( WINDOW *win)
{
	char *string;
	BUFFER *text;
	
	if( WinHelp)
		snd_msg( WinHelp, WM_TOPPED,0,0,0,0);
	else
	{
		text = BufferLoad( "viewer.hlp");
		if( text)
			WinHelp = BufferOpen( text);
		else
		{
			rsrc_gaddr( 5, HELP_ERROR, &string);
			WindSet( win, WF_INFO, string);
		}
	}
}

void cycle_windows( void)
{
	if( wglb.appfront && wglb.appfront->next)
		WindSet( NULL, WF_TOP, wglb.appfront->next->handle,0,0,0);
	else
		WindSet( NULL, WF_TOP, wglb.first->handle, 0, 0, 0);
}

void switch_macro_colors( WINDOW *win)
{
	char cmd[255];
	long res;
	BUFFER *ptext = (BUFFER*)win->data;
	
	if( !(ptext->mode & MODE_MACRO)) {
		cmd[0] = ' ';
		cmd[1] = '\0';
		if( *macrospath) {
			strcat( cmd, "-d ");
			strcat( cmd, macrospath);
			strcat( cmd, " ");	
		}
		if( color_silent) strcat( cmd, "-silent ");
		strcat( cmd, GET_BUFFER(win)->name);

		res = Pexec( 0, colorpath, (void*)cmd, NULL);
		
		if( res == 0) {
			char temp[255];
			
			/* On y wa */
			strcpy( cmd, ptext->name);
			strcpy( temp, macrospath);
			strcat( temp, "TEMP");
			ptext = BufferLoad( temp);
			BufferReopen( ptext, win);
			ptext -> mode |= MODE_MACRO;
			strcpy( ptext->name, cmd);
			WindSet( win, WF_NAME, ptext->name);
		}
	} else {
		ptext = BufferLoad( ptext->name);
		BufferReopen( ptext, win);
		ptext -> mode &= ~MODE_MACRO;
	}
}

int prn_check (int wait_time)
{
	int		ok = 0;
	long	timer;

	while (!ok)
	{
		timer = 200 * wait_time + clock();
		ok = (Cprnos() == -1);
		while (!ok && (timer > clock()))
			ok = (Cprnos() == -1);
		/* if (ok == 0) imprimante non prete */
	}
	return (ok);
}


void print_buffer( WINDOW *win)
{
	BUFFER *ptext = win->data;
	size_t line;
	char *p;
	int end;
	
	strcpy( GET_BUFFER(win)->info, "print-buffer: check printer ...");
	WindSet( win, WF_INFO, GET_BUFFER(win)->info);
	if( /*prn_check( 5) == 0*/ Cprnos() == 0) {
		strcpy( GET_BUFFER(win)->info, "print-buffer: warning, printer not ready!");
		WindSet( win, WF_INFO, GET_BUFFER(win)->info);
		return;
	}
	else
		strcpy( GET_BUFFER(win)->info, "print-buffer: print in progress ...");

	WindSet( win, WF_INFO, GET_BUFFER(win)->info);
	
	
	for( line = 0; line < ptext->maxline; line ++) {
		p = ptext->line[line];
		end = 0;
		while(!end) {
			switch( *p) {
			case '\0':
			case '\n':
			case '\r':
				Cprnout( 13);
				Cprnout( 10);
				end = 1;
				break;
			case WE_ESCAPE:
				p += skip_esc( p);
				break;
			default:
				Cprnout( *p);
				p++;
				break;
			}
		}
	}
	SetInfo( win);
}

void command( WINDOW *win, int cmd)
{
	switch( cmd){
	case CONTROL_E:
		if( *editor)
			ExecGemApp( editor, GET_BUFFER(win)->name, editor_av);
		break;
	case CONTROL_B:
		menu_new_buffer( win);
		break;
	case CONTROL_O:
		menu_new_frame();
		break;
	case CONTROL_C:
		menu_copy( win);
		break;
	case CONTROL_F:
		menu_find( win);
		break;
	case CONTROL_G:
		menu_find_again( win);
		break;
	case CONTROL_U:
		snd_msg( win, WM_CLOSED, 0, 0, 0, 0);
		break;
	case CONTROL_Q:
		snd_msg( NULL, AP_QUIT, 0, 0, 0, 0);
		break;
	case CONTROL_W:
		cycle_windows();
		break;
	case CONTROL_M:
		if( (evnt.keybd>>8) != 0x72 &&
			(evnt.keybd>>8) != 0x1C)
			menu_mode( win);
		break;
	case CONTROL_V:
		import_clipbrd();
		break;
	case CONTROL_L:	/* goto line */
		goto_line( win);
		break;
	case CONTROL_A:
		switch_macro_colors( win);
		break;
	case CONTROL_P:
		print_buffer( win);
		break;
	case CONTROL_K:
		snd_msg( win, WM_FULLED, 0, 0, 0, 0);
		break;
	case CONTROL_I:				
		if( win->status & WS_ICONIFY)
			snd_msg( win, WM_UNICONIFY, 
							 win->icon.x,
							 win->icon.y,
							 win->icon.w,
							 win->icon.h);
		else {
			int x,y,w,h;
			give_iconifyxywh(&x,&y,&w,&h);
			snd_msg( win, WM_ICONIFY, x, y, w, h);
		}
				
		break;
	case CONTROL_HELP:
		menu_help( win);
		break;
	default:
		edit_info( win, evnt.keybd);
		if( evnt.keybd == 0x6200) {
			int dum,state;
		
			graf_mkstate( &dum, &dum, &dum, &state);
			if( state & K_CTRL)
				menu_help( win);
			else {
				char *string;
					
				rsrc_gaddr( 5, GET_BUFFER(win)->help, &string);
				strcpy( GET_BUFFER(win)->info, string);
				WindSet( win, WF_INFO, ((BUFFER*)win->data)->info);
				GET_BUFFER(win)->help = (GET_BUFFER(win)->help>=INFO_HELP3)?
										INFO_HELP1:GET_BUFFER(win)->help+1;
			}
		}
	}
}

/*
 *	Main function
 *
 *	viewer [-nosetup] file1 file2 ...
 *			-nosetup: don't read viewer.cnf
 *		accept AV_PROTOCOL (DRAG and DROP, -f)
 *		(accept MulTitos Drag and Drop from desktop)
 */

int main( int argc, char *argv[])
{
	char *string;
	BUFFER *text;
	int ev, dum, end = 0;
	OBJECT *tree;
	WINDOW *win;

	if( !_app)
		app.flag |= NOPALETTE;
	ApplInit();
	
	if( !rsrc_load( "viewer.rsc"))
	{
		form_alert( 1, "[3][can't find viewer.rsc][ OK ]");
		ApplExit();
		return -2;
	}
	if( _AESnumapps == -1 || !_app)
	{
		rsrc_gaddr( 5, MENU_TITLE, &string);
		menu_register( app.id, string);
	} else	if( _AESnumapps == 1) {
		rsrc_gaddr( 0, MENU_ACC, &tree);
		MenuBar( tree, 1);
	}
	
	for( dum=1; dum < argc; dum ++)
		if( !strcmp( argv[ dum], "-nosetup"))
		{
			nosetup = 1;
			break;
		}

	gdos = vq_gdos();
	fgdos = (vq_vgdos() == '_FSM');

	ReadSetUp();
	
	for( dum=1; dum < argc; dum ++)
	{
		if( !strcmp( argv[ dum], "-help"))
		{
			rsrc_gaddr( 5, USAGE, &string);
			form_alert( 1, string);
			rsrc_free();
			ApplExit();
			return 0;
		}
		
		if( !strcmp( argv[ dum], "-noesc"))
			DisplayEscapeCode = 1;
			
		if( argv[ dum][0] == '-')
			continue;

		text = BufferLoad( argv[ dum]);
		if( text == NULL)
		{
			rsrc_gaddr( 5, ERR_BUFF_LOAD, &string);
			form_alert( 1, string);
			continue;
		}
		win = BufferOpen( text);
		SetInfo( win);
		EvntWindom( MU_MESAG);
		GetPath( path, argv[dum]);
	}
	
	evnt.bclick = 258;
	evnt.bmask = 0x1|0x2;
	evnt.bstate = 0;

	if( argc == 1 && _app) snd_msg( NULL, AP_LOAD, 0, 0, 0, 0);

	do {
		
		ev = EvntWindom( MU_MESAG|MU_BUTTON|MU_KEYBD);
		win = WindHandle( wind_find( evnt.mx, evnt.my));
		if( ev & MU_BUTTON)
		{
			if( win && evnt.nb_click == 1 && evnt.mbut & 0x02
				&& !(win->status & WS_ICONIFY))
			{
				rsrc_gaddr( 0, 1, &tree);
				dum = MenuPopUp( tree, evnt.mx, evnt.my, 0, 0, -1, P_RGTH|P_WNDW);
				if( dum != -1) command( win, mnu2key[dum]);
			}
		}
		
		if( ev & MU_MESAG)
		{
			switch( evnt.buff[0])
			{
			case VA_START:
				if( wglb.first == NULL && *(char **)&evnt.buff[3] == NULL)
					menu_new_frame();
				else
					OpenList( *(char **)&evnt.buff[3]);
				break;
			case AC_OPEN:
				menu_new_frame();
				break;
			case AP_DRAGDROP:
				{
					char file[128], name[ 128], *buff;
					int dd_hdl, dd_msg; /* pipe-handle */
					LONG size;
					char ext[32];

					/* on accepte le drag&drop */
					dd_hdl = ddopen( evnt.buff[7], DD_OK);
					if( dd_hdl<0)	break;	/* erreur, pipe non ouvert */
					
					/*	On envoit notre liste de prefs:
					 *	Notre liste de prefs se borne au type ARGS
					 *	qui a une signification sp‚ciale: on attends
					 *	une liste de nom de fichiers dans le pipe
					 */
					strnset( ext, '\0', 32);
					strcpy( ext, "ARGS");
					dd_msg = ddsexts( dd_hdl, ext);
					if( dd_msg<0)	break;	/* erreur lecture du pipe */
					
					/* Lectures des infos re‡us */	
					dd_msg = ddrtry( dd_hdl, name, file, ext, &size);
					if( !strncmp( ext, "ARGS", 4))
					{
						/* on accepte les donn‚es */
						ddreply(dd_hdl, DD_OK);
						/* On lit les "size" octets des donn‚es dans le pipe */
						buff = (char*)malloc(sizeof(char)*size);
						if( Fread( dd_hdl, size, buff) == size)
							OpenList( buff);
						else
							/* erreur lecture pipe */
							;
						free( buff);
						ddclose( dd_hdl);	/* fin du protocole */
					}	
					else
						ddreply(dd_hdl, DD_NAK); 
					
					ddclose( dd_hdl);	/* fin du protocole */
					 
				}
				break;
			case AP_TERM:
				end = 1;
				break;
			case AP_QUIT:
				if( _app)
					end = 1;
				break;
			case AP_LOAD:
				menu_new_frame();
				break;
			case MN_SELECTED:
				dum = evnt.buff[3];
				switch( evnt.buff[4]) {
					case MENU_ACC_INFO:
						rsrc_gaddr( 5, USAGE, &string);
						form_alert( 1, string);
						break;
					case MENU_ACC_QUIT:
						end = 1;
						break;
				}
				MenuTnormal( NULL, dum, 1);
				break;
							
			default:
				if( wglb.appfront && evnt.buff[0] > 100 && !GET_BUFFER(wglb.appfront)->edit) {
					char name[9];
					
					ApplName( name, evnt.buff[1]);
					sprintf( ((BUFFER*)wglb.appfront->data)->info, 
							"viewer say 'i received %d (0x%X) mesag from %s'.",
							evnt.buff[0], evnt.buff[0], name);
					WindSet( wglb.appfront, WF_INFO, ((BUFFER*)wglb.appfront->data)->info);
				}
			}
			if( win) SetInfo( win);
		}
	}while( !end);
	
	while( wglb.first ) {
		snd_msg( wglb.first, WM_CLOSED,0,0,0,0);
		EvntWindom(MU_MESAG);
	}

	rsrc_free();
	ApplExit();
	return 0;
}