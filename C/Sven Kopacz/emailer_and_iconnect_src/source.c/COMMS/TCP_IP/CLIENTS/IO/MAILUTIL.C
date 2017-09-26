#include <ec_gem.h>
#include "io.h"
#include "ioglobal.h"
#include "iversion.h"
#include "anhang.h"
#include "indexer.h"

extern int no_at_warning;

/* ISO-8859-1 to Atari */
char	iso8859_1[]={
	0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15,
	16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31,
  32, '\!', '\"', '\#', '\$', '\%', '\&', '\'', '\(', '\)', '\*', '\+', '\,', '\-', '\.', '\/',
  '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '\:', '\;', '\<', '\=', '\>', '\?',
  '@', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O',
  'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', '\[', '\\', '\]', '\^', '\_',
  '\`', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o',
  'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', '\{', '\|', '\}', '\~', 127,
  
  128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,
  144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159,
  
  /* 160-175 */
 /* NS, 173, 155, 156, Cu, 157, BB ,188 ,185, 189, -a ,174, NO ,'-' ,190, '- */
  '_', 173, 155, 156, 159, 157, '?' ,221 ,185, 189, 237 ,174, '!' ,'-' ,190, 255,

	/* 176-191 */
 /* 248, 241, 253, 254, 96 ,230, 227, .M ', 1S -o ,175, 172, 171, 34 ,168,*/
  248, 241, 253, 254, 96 ,230, 227, 250, 199, 252, 229 ,175, 172, 171, '?' ,168,

	/* 192-207 */
/*  182, A' A> ,183, 142, 143, 146, 128, E! 144, E> E: I! I' I> I:*/
  182, 160, 131 ,183, 142, 143, 146, 128, 138, 144, 136, 137, 141, 161, 140, 139,

	/* 208-223 */
/*  D- ,165, O! O' O> ,184, 153, *X ,178, U! U' U> ,154, Y! TH ,'û',*/
  '?' ,165, 149, 162, 147 ,184, 153, '*' ,178, 151, 163, 150 ,154, 'Y', '?' ,'û',

	/* 224-239 */
  133, 160, 131, 176, 132, 134, 145, 135, 138, 130, 136, 137, 141, 161, 140, 139,

	/* 240-255 */
/*  d- ,164, 149, 162, 147, 177, 148, 246, 179, 151, 163, 150, 129, y', th , 152*/
  '?' ,164, 149, 162, 147, 177, 148, 246, 179, 151, 163, 150, 129, 'y', '?' ,152
};

/* Atari to ISO-8859-1 */
char r_iso8859_1[]=
{
	0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15,
	16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31,
  32, '\!', '\"', '\#', '\$', '\%', '\&', '\'', '\(', '\)', '\*', '\+', '\,', '\-', '\.', '\/',
  '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '\:', '\;', '\<', '\=', '\>', '\?',
  '@', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O',
  'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', '\[', '\\', '\]', '\^', '\_',
  '\`', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o',
  'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', '\{', '\|', '\}', '\~', 127,
  
	/* 128-143 */
	199, 252, 233, 226, 228, 224, 229, 231, 234, 235, 232, 239, 238, 236, 196, 197,
	/* 144-159 */
	201, 230, 198, 244, 246, 242, 251, 249, 255, 214, 220, 162, 163, 165, 223, 'f',
	/* 160-175 */
	225, 237, 243, 250, 241, 209, 'a', 'o', 191, '-', '-', 189, 188, 161, 171, 187,
	/* 176-191 */
	227, 245, 216, 248, 'o', 'O', 192, 195, 213, 168, 180, '+', 167, 169, 174, '?',
	/* 192-207 */
	'i', 'I', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', 
	/* 208-223 */
	'?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', 167, '\^', '?',
	/* 224-239 */
	'?', 223, '?', 182, '?', '?', 181, '?', '?', '?', '?', '?', '?', '?', '?', '?',
	/* 240-255 */
	'?', 177, '>', '<', '?', '?', 247, '=', 176, 176, '.', '?', '?', 178, 179, 175
};

char	base64_encode[]=
{
 'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q',
 'R','S','T','U','V','W','X','Y','Z',
 'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q',
 'r','s','t','u','v','w','x','y','z',
 '0','1','2','3','4','5','6','7','8','9','+','/'
};

uchar base64_decode[]=
{
	/* \0 wird wie '=' als Ende-Zeichen erkannt */
	65,
	
	/* 42 unbenutzte */
	0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,
	0,0,
	/* '+' */
	62,
	/* 3 unbenutzte */
	0,0,0,
	/* '/' */
	63,
	/* 0-9 */
	52,53,54,55,56,57,58,59,60,61,
	/* 3 unbenutzte , Erkennungscode fÅr '=', 3 unbenutzte */
	0,0,0,65,0,0,0,
	/* A-Z */
	0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,
	/* 6 unbenutzte */
	0,0,0,0,0,0,
	/* a-z */
	26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,
	48,49,50,51
};

char *get_timezone(void)
{ /* Liefert Zeitzone als "+HHMM"-String zurÅck oder NULL */
/*
 Cookie heiût 'GMTC', Inhalt:

Wert: 0xcccsdddd

wobei:
  ccc  codiert fÅr das CPX die Stadt (Anzeige mehrere StÑdte in einer
       Zeitzone)
  s    ist 1, wenn Sommerzeit, 0 wenn Winterzeit
  dddd gibt die Differenz zu GMT in Minuten an. (Minuten wegen
       Indischer Zeit: +5,5 Stunden) Sommerzeit ist hier nicht
       beachtet.
*/

	long	tz;
	int		t, hour, min;
	static char zone[6];
		
	if(find_cookie('GMTC', &tz)==0) return(NULL);
	t=*(int*)&(((char*)&tz)[2]);
	if(t > 0)
		strcpy(zone, "+");
	else
	{
		strcpy(zone, "-");
		t*=-1;
	}
	hour=t/60;
	min=t-hour*60;
	if(((char*)&tz)[1] & 1) ++hour;	/* Sommerzeit */
	if(hour < 10) strcat(zone, "0");
	itoa(hour, &(zone[strlen(zone)]), 10);
	if(min < 10) strcat(zone, "0");
	itoa(min, &(zone[strlen(zone)]), 10);
	return(zone);
}

char	*get_head_field(char *f)
{/* PrÅft, ob der Header der aktuell geladenen Datei das Feld
		<f> enhÑlt (Groû-/Kleinschreibung egal) und gibt Zeiger
		auf Inhalt ohne fÅhrende Whitespace zurÅck oder NULL.
		Hinweis: Bei leerem Eintrag wird "" und nicht NULL geliefert! 
		<f> muû den Doppelpunkt enthalten !
		*/

	char	*i=loadm.header;
	long	c=0, flen=strlen(f);

	if(i==NULL) return(NULL);
	while(c < loadm.head_len)
	{
		if(strnicmp(i, f, flen)==0) goto _found;
		c+=strlen(i)+1;
		i+=strlen(i)+1;
	}
	return(NULL);

_found:
	i+=flen; c+=flen;
	while((c < loadm.head_len) && ((*i==' ')||(*i==9)))
	{ ++c; ++i;}
	return(i);
}

char	hctoi(char c)
{/* Hex-Character in 0-15 wandeln, groû/klein egal */
	if((c>='0')&&(c<='9')) return(c-'0');
	if(c < 'a') return(c-'A'+10);
	return(c-'a'+10);
}

void decode_iso_8859_1(char *d)
{
	uchar *c=(uchar*)d;
	
	while(*c)
	{
		*c=iso8859_1[*c];
		++c;
	}
}

void decode_quoted_printable_general(char *c, int header)
{/* c ist 0-terminiert und wird mit der decodierten Version
		Åberschrieben 
		header=0: Decode body, d.h. underscore bleibt erhalten
		header=1: Decode header, d.h. underscore wird durch space ersetzt */
	char *d, *e;
	int	 code1, code2;
	
	d=c;
	while(*c)
	{
		switch(*c)
		{
			case '=':
				if(*(c+1)==0)
				{
					*d=0; ++c;
				}
				else if(*(c+1)==13)
				{
					++c;
					do{++c;}while(*c==10);
				}
				else
				{
					/* PrÅfen, ob Zeichen gÅltig sind */					
					code1=hctoi(*(c+1)); 
					code2=hctoi(*(c+2));
					if( (code1>=0) && (code1<=15) &&
							(code2>=0) && (code2<=15)  )
					{
						code1<<=4;
						code1+=code2;
						*(uchar*)d=iso8859_1[code1];
						++d;
						c+=3;
					}
					else
						*d++=*c++;
				}
			break;
			case 9:	/* Trailing TABs und Spaces werden abgeschnitten! */
			case ' ':
				e=c;
				while((*e==9)||(*e==' '))++e;
				if((*e==10)||(*e==13))
				{
					c=e;
					while((*c==13)||(*c==10)) *d++=*c++;
				}
				else
					*d++=*c++;
			break;
/* Lauf RFC 1521 ist in quoted-printable-text die uncodierte
   öbertragung div. Zeichen erlaubt, darunter der Underscore.
   Nach RFC1342 ist aber in einem q-p-encoded Header-Feld der
   Underscore IMMER durch ein Space zu ersetzen */
			case '_':
				if(header)	*d++=' ';
				else *d++='_';
				++c;
			break;
			default:
				*d++=*c++;
			break;
		}
	}
	*d=0;
}

void decode_quoted_printable(char *c)
{
	decode_quoted_printable_general(c, 0);
}

void decode_quoted_printable_header(char *c)
{
	decode_quoted_printable_general(c, 1);
}


long decode_base_64(char *s)
{/* c ist 0-terminiert und wird mit der decodierten Version
		Åberschrieben. Gibt die Anzahl der erzeugten Bytes zurÅck. */
		
	uchar c1,c2,c3,c4, *c=(uchar*)s, *d=c;
	long	bytes=0;
	
	while(1)
	{
		while(*c && ((*c<'+')||(*c>'z')))++c;
		c1=base64_decode[*c++];  if(c1==65) break;
		while(*c && ((*c<'+')||(*c>'z')))++c;
		c2=base64_decode[*c++];  if(c2==65) break;
		while(*c && ((*c<'+')||(*c>'z')))++c;
		c3=base64_decode[*c++];  if(c3==65) goto _decode;
		while(*c && ((*c<'+')||(*c>'z')))++c;
		c4=base64_decode[*c++];
_decode:
		c1<<=2;
		c1|=c2>>4;
		*d++=c1; ++bytes;
		if(c3==65) break;
		c2<<=4;
		c2|=c3>>2;
		*d++=c2; ++bytes;
		if(c4==65) break;
		c3<<=6;
		c3|=c4;
		*d++=c3; ++bytes;
	}
	*d=0;
	return(bytes);
}

/* ------------------------------------------- */

long atx_maxlen(MAIL_ATX	*atx)
{
	long max=0;
	
	while(atx)
	{
		if(atx->file_name[0])
		{if(strlen(atx->file_name) > max) max=strlen(atx->file_name);}
		else
		{if(strlen(atx->mime_type) > max) max=strlen(atx->mime_type);}
		atx=atx->next;
	}
	return(max);
}

int count_atx(MAIL_ATX *atx)
{
	int c=0;
	
	while(atx)
	{
		++c;
		atx=atx->next;
	}
	return(c);
}

int atx_popup(int show_save)
{/* show_save: 1=show, 0=save. Gibt Index ab 1 zurÅck */
	OBJECT 	*tree, *root;
	MAIL_ATX	*atx=loadm.first;
	char		*strings, *titel;
	int			a, num=count_atx(loadm.first), mx, my, kbs;
	long		slen;

	if(num==0) return(-1);
	++num;	/* FÅr Titel */	
	graf_mkstate(&mx, &my, &a, &kbs);
	if(show_save)
		titel=gettext(ATX_SHOW);
	else
		titel=gettext(ATX_SAVE);
	
	rsrc_gaddr(0, POPVORL, &root);
	slen=atx_maxlen(loadm.first)+4; /* Zwei Space vorne, eins hinten, eine 0 */
	if(slen < strlen(titel)+1)
		slen=strlen(titel)+1;
	
	tree=malloc((num+1)*sizeof(OBJECT)+num*slen);
	if(tree==NULL) {form_alert(1, gettext(NOMEM)); return(0);}
	strings=(char*)&(tree[num+1]);
	tree[0]=root[0];
	tree[0].ob_tail=num;
	tree[0].ob_height=root[1].ob_height*num;
	tree[0].ob_width=(int)slen*8;	/* *** Nix so doll *** */
	for(a=1; a <= num; ++a)
	{
		tree[a]=root[1];
		tree[a].ob_next=a+1;
		tree[a].ob_flags &=(~LASTOB);
		tree[a].ob_spec.free_string=strings;
		tree[a].ob_width=tree[0].ob_width;
		strcpy(strings, "  ");
		if(atx->file_name[0])
			strcat(strings, atx->file_name);
		else
			strcat(strings, atx->mime_type);
		strings+=slen;
		tree[a].ob_y=root[1].ob_height*(a-1);
		if(a > 1) atx=atx->next;
	}
	tree[num].ob_next=0;
	tree[num].ob_flags|=LASTOB;
	/* Titel */
	strcpy(tree[1].ob_spec.free_string, titel);
	tree[1].ob_flags &= (~SELECTABLE);
	a=form_popup(tree, mx, my-(tree[1].ob_height*3)/2);
	free(tree);

	return(a-1);
}

void save_cr_as_crlf(int fh, char *c)
{
	char buf[2048], *d;
	long cp;
	
	cp=0;
	d=buf;
	while(*c)
	{
		if(*c!=13)
		{
			*d++=*c++; ++cp;
		}
		else
		{
			*d++=*c++; *d++=10; cp+=2;
		}
		if(cp > 2045)
		{
			Fwrite(fh, cp, buf);
			cp=0; d=buf;
		}
	}
	if(cp) Fwrite(fh, cp, buf);
}

void atx_select(void)
{
	OBJECT		*tree;
	MAIL_ATX	*atx=loadm.first;
	int		mx, my, res, pop_sel, atx_show=0;

	if(Kbshift(-1)&4) 
		res=1;	/* Ctrl=Zeigen */
	else if(Kbshift(-1)&8)
		res=3;	/* Alt=Sichern */
	else
	{
		rsrc_gaddr(0, MATXPOPUP, &tree);
		graf_mkstate(&mx, &my, &res, &res);
		res=form_popup(tree, mx, my);
	}
	if(res < 1) return;
	if(res < 3) atx_show=1;
	if(res > 4) 
	{/* Fenster fÅr Anhang */
		if(anh_win.open) w_top(&anh_win);
		else anhang_win();
		return;
	}
	pop_sel=atx_popup(atx_show);	
	if(pop_sel < 1) return;
	while(--pop_sel) atx=atx->next;
	
	extract_atx(atx, atx_show);
}

/* ------------------------------------------- */

void save_original_as(void)
{/* Speichert aktuelle Nachricht unter Auswahl */
	char bpath[256], path[256], *buf;
	char	name[64];
	long	fhl;
	int		sh, dh;
	
	if((fld==NULL)||(fld_c <= ios.list_sel)||(ios.list_sel < 0)) return;

	name[0]=0;
	if(f_sinput(gettext(FILE_SAVE_AS),ios.file_save_as_path, name)==0) return;
	make_path(path, ios.file_save_as_path, name);
	fhl=Fopen(path, FO_READ);
	if(fhl > -1)
	{
		Fclose((int)fhl);
		if(form_alert(1, gettext(FILE_EXIST))==2) return;
	}

	if(db_mode)
	{
		Idx_extract_to(fld[ios.list_sel].idx, path);
		return;
	}
	
	strcpy(bpath, db_path);
	switch(ios.list)
	{
		case 0:
			strcat(bpath, "\\PM\\");
		break;
		case 1:
			if((fld==NULL)||(fld[0].ftype!=FLD_BAK)) return;
			strcat(bpath, "\\OM\\");
			strcat(bpath, act_fold);
			strcat(bpath, "\\");
		break;
		case 2:
			if((fld==NULL)||(fld[0].ftype!=FLD_BAK)) return;
			strcat(bpath, "\\ORD\\");
			strcat(bpath, act_fold);
			strcat(bpath, "\\");
		break;
		case 3:
			strcat(bpath, "\\DEL\\");
		break;
	}
	strcat(bpath, fld[ios.list_sel].fspec.fname);

	if(!stricmp(path, bpath)) return;	/* Quelle/Ziel identisch */
	fhl=Fcreate(path, 0);
	if(fhl < 0) {gemdos_alert(gettext(CREATEERR), fhl); return;}
	dh=(int)fhl;
	fhl=Fopen(bpath, FO_READ);
	if(fhl < 0) {gemdos_alert(gettext(NOOPEN), fhl); Fclose(dh); return;}
	sh=(int)fhl;
	fhl=Fseek(0, sh, 2); Fseek(0, sh, 0);
	buf=malloc(fhl);
	if(buf==NULL)
	{
		while((fhl=Fread(sh, 256, bpath)) > 0)
			Fwrite(dh, fhl, bpath);
	}
	else
	{
		Fread(sh, fhl, buf);
		Fwrite(dh, fhl, buf);
		free(buf);
	}
	Fclose(sh);
	Fclose(dh);
}

/* ------------------------------------------- */

void show_orgfile(void)
{/* Original zur aktuell selektierten Nachricht zeigen */
static char	bpath[256];

	if((fld==NULL)||(fld_c <= ios.list_sel)||(ios.list_sel < 0)) return;

	if(db_mode && (fld[ios.list_sel].ftype != FLD_SND))
	{
		form_alert(1, gettext(NOFILESHOW));
		return;
	}

	strcpy(bpath, db_path);

	switch(ios.list)
	{
		case 0:
			strcat(bpath, "\\PM\\");
		break;
		case 1:
			if((fld==NULL)||(fld[0].ftype!=FLD_BAK)) return;
			strcat(bpath, "\\OM\\");
			strcat(bpath, act_fold);
			strcat(bpath, "\\");
		break;
		case 2:
			if((fld==NULL)||(fld[0].ftype!=FLD_BAK)) return;
			strcat(bpath, "\\ORD\\");
			strcat(bpath, act_fold);
			strcat(bpath, "\\");
		break;
		case 3:
			strcat(bpath, "\\DEL\\");
		break;
	}

	pbuf[0]=AV_XWIND;
	pbuf[1]=ap_id;
	pbuf[2]=0;
	*((char**)(&pbuf[3]))=bpath;
	*(char**)(&(pbuf[5]))=fld[ios.list_sel].fspec.fname;
	pbuf[7]=3;	/* Top & select statt neu îffnen und ausblenden */

	appl_write(0, 16, pbuf);
}

/* ------------------------------------------- */

void show_original(void)
{/* Original zur aktuell selektierten Nachricht zeigen */
static char	bpath[256];

	if((fld==NULL)||(fld_c <= ios.list_sel)||(ios.list_sel < 0)) return;
	if(db_mode && (fld[ios.list_sel].ftype != FLD_SND))
	{
		strcpy(bpath, db_path);	strcat(bpath, "\\TMP\\");
		strcat(bpath, get_free_file(bpath));
		switch(fld[ios.list_sel].ftype)
		{
			case FLD_SNT: strcat(bpath, ".SNT"); break;
			case FLD_NEW: strcat(bpath, ".NEW"); break;
			case FLD_RED: strcat(bpath, ".RED"); break;
		}
		Idx_extract_to(fld[ios.list_sel].idx, bpath);
	}
	else
	{
		strcpy(bpath, db_path);
	
		switch(ios.list)
		{
			case 0:
				strcat(bpath, "\\PM\\");
			break;
			case 1:
				if((fld==NULL)||(fld[0].ftype!=FLD_BAK)) return;
				strcat(bpath, "\\OM\\");
				strcat(bpath, act_fold);
				strcat(bpath, "\\");
			break;
			case 2:
				if((fld==NULL)||(fld[0].ftype!=FLD_BAK)) return;
				strcat(bpath, "\\ORD\\");
				strcat(bpath, act_fold);
				strcat(bpath, "\\");
			break;
			case 3:
				strcat(bpath, "\\DEL\\");
			break;
		}
		strcat(bpath, fld[ios.list_sel].fspec.fname);
	}
	
	pbuf[0]=AV_STARTPROG;
	pbuf[1]=ap_id;
	pbuf[2]=0;
	*((char**)(&pbuf[3]))=bpath;
	pbuf[5]=pbuf[6]=0;
	appl_write(0, 16, pbuf);
}

/* ------------------------------------------- */

void Fhdencode(int fh, char *line)
{
	uchar *c=(uchar*)line, *d, buf[68+15], x, y, cnt;
	
	while(*c) {if((*c < 32) || (*c > 127)) goto _encode; ++c;}
	/* Standard-Ascii */
	Fwrite(fh, strlen(line), line);
	return;

_encode:
	strcpy((char*)buf, "=?ISO-8859-1?Q?");
	c=(uchar*)line; d=&buf[15]; cnt=15;
	while(*c)
	{
		if((*c > 31)&&(*c < 128)) {*d++=*c++; ++cnt;}
		else
		{
			x=r_iso8859_1[*c++];
			y=x>>4;
			x-=y<<4;
			*d++='=';
			if(y > 9)
				*d++=y-10+'A';
			else
				*d++=y+'0';
			if(x > 9)
				*d++=x-10+'A';
			else
				*d++=x+'0';
			cnt+=3;
		}
		if(cnt > 59) /* Flush buffer */
		{
			*d=0;
			strcat((char*)buf, "?=\r\n ");
			Fwrite(fh, strlen((char*)buf), buf);
			strcpy((char*)buf, "=?ISO-8859-1?Q?");
			d=&buf[15]; cnt=15;
		}
	}
	*d=0;
	Fwrite(fh, strlen((char*)buf), buf);
	Fwrite(fh, 2, "?=");
}

void F8bitencode(int fh, EDIT_OB *edob)
{
	ED_LIN	*el=edob->first;
	int		cnt;
	uchar *c, *d, buf[1024];
	
	d=buf; cnt=0;
	while(el)
	{
		c=(uchar*)(el->line);
		if(el->quoted) {*d++='>'; ++cnt;}
		while(*c)
		{
			if(*c==13) {*d++=*c++; *d++=10; cnt+=2;}
			else {*d++=r_iso8859_1[*c++];}
			++cnt;
			if(cnt > 1020)
			{/* Flush buffer */
				*d=0;
				Fwrite(fh, strlen((char*)buf), buf);
				d=buf; cnt=0;
			}
		}
		/*Editor-Umbruch als Hard-linebreak? */
		if((ios.cut_oeff)&&((char*)c!=el->line)&&(*(c-1)!=13))
			{*d++=13;*d++=10;cnt+=2;}
		el=el->next;
	}	
	*d=0;
	Fwrite(fh, strlen((char*)buf), buf);
}

void Fqpencode(int fh, EDIT_OB *edob)
{
	ED_LIN	*el=edob->first;
	uchar *c, *d, buf[90], x, y, cnt, nl;
	
	d=buf; cnt=0; nl=1;
	while(el)
	{
		c=(uchar*)(el->line);
		if(nl && el->quoted) {*d++='>'; ++cnt;}
		while(*c)
		{
			nl=0;
			if((*c!='_')&&(*c!='=')/*&&(*c!='.')*/&&(*c > 31)&&(*c < 128)) {*d++=*c++; ++cnt;}
			else if(*c!=13)
			{
				x=r_iso8859_1[*c++];
				y=x>>4;
				x-=y<<4;
				*d++='=';
				if(y > 9)
					*d++=y-10+'A';
				else
					*d++=y+'0';
				if(x > 9)
					*d++=x-10+'A';
				else
					*d++=x+'0';
				cnt+=3;
			}
			else /* 13=Zeilenumbruch */
			{
				if(cnt)
				{
					if(*(c-1)==' ') {*(d-1)='=';*d++='2';*d++='0';cnt+=2;}
					else if(*(c-1)=='.') {*(d-1)='=';*d++='2';*d++='E';cnt+=2;}
					else if(*(c-1)==9) {*(d-1)='=';*d++='0';*d++='9';cnt+=2;}
				}
				++c;
				*d++=13; *d++=10; cnt+=2;
				nl=1;
			}
			if((cnt > 70) && (!(ios.cut_pers)))
			{/* Flush buffer */
				*d++='=';	/* soft break */
				*d++=13;
				*d++=10;
				*d=0;
				Fwrite(fh, strlen((char*)buf), buf);
				d=buf; cnt=0;
				nl=1;
			}
		}
		if(ios.cut_pers)
		{/* ZeilenlÑnge Åbernehmen */
				 /* *d++='=';	*/ /* soft break ausgebaut, dann sollte Mail wir im Editor aussehen */
				if(cnt && (*(d-1)!=10))
				{/* Zeilenumbruch einfÅgen, falls nicht schon einer drin ist */
					*d++=13;
					*d++=10;
				}
				*d=0;
				Fwrite(fh, strlen((char*)buf), buf);
				d=buf; cnt=0;
		}
		el=el->next;
	}	
	*d=0;
	Fwrite(fh, strlen((char*)buf), buf);
}

void F8bitatxencode(int fh, MAIL_ATX *atx)
{
	uchar *c, *d, buf[1024];
	int		bcnt;
	long 	cnt=atx->atx_len;

	d=buf; bcnt=0;
	c=(uchar*)(atx->atx);

	while(cnt > 0)
	{
		if(*c==13) {*d++=*c++; *d++=10; bcnt+=2; --cnt;}
		else {*d++=r_iso8859_1[*c++]; ++bcnt; --cnt;}
		if(bcnt > 1020)
		{/* Flush buffer */
			*d=0;
			Fwrite(fh, strlen((char*)buf), buf);
			d=buf; bcnt=0;
		}
	}	
	*d=0;
	Fwrite(fh, strlen((char*)buf), buf);
}

void Fqpatxencode(int fh, MAIL_ATX *atx)
{
	uchar *c, *d, buf[2070], x, y, bcnt;
	long 	cnt=atx->atx_len, filled;

	d=buf; bcnt=0; filled=0;
	c=(uchar*)(atx->atx);

	while(cnt > 0)
	{
		if((*c!='_')&&(*c!='=')&&(*c!='.')&&(*c > 32)&&(*c < 128)) {*d++=*c++; ++bcnt; --cnt;}
		else if((*c!=13)&&(*c!=10))
		{
			x=r_iso8859_1[*c++]; --cnt;
			y=x>>4;
			x-=y<<4;
			*d++='=';
			if(y > 9)
				*d++=y-10+'A';
			else
				*d++=y+'0';
			if(x > 9)
				*d++=x-10+'A';
			else
				*d++=x+'0';
			bcnt+=3;
		}
		else /* 10/13=Zeilenumbruch */
		{
			if(*c==13)
			{	/* Folgende LF Åbergehen */
				++c; --cnt;
				while(*c==10) {++c; --cnt;}
			}
			else
			{	++c; --cnt;} /* Nur LF, jedes zÑhlt */
			*d++=13; *d++=10; bcnt+=2;
		}
		if(bcnt > 70)
		{/* Flush buffer */
			*d++='=';	/* soft break */
			*d++=13;
			*d++=10;
			filled+=bcnt+3;
			bcnt=0;
			if(filled > 1990)
			{
				*d=0;
				Fwrite(fh, strlen((char*)buf), buf);
				d=buf; filled=0;
			}
		}
	}	
	*d=0;
	Fwrite(fh, strlen((char*)buf), buf);
}

void Fb64encode(int fh, MAIL_ATX *atx)
{
	long	cnt, filled;
	int		bcnt;
	uchar	buf[2072], *c, *d;
	uchar	x, x1, x2, x3, x4;
	
	bcnt=0; c=(uchar*)(atx->atx); d=buf, filled=0;
	cnt=atx->atx_len;

	while(cnt > 0)
	{
		if(cnt >= 3)
		{
			x=*c++;
			x1=x>>2;
			x2=(x&3)<<4; x=*c++;
			x2|=x>>4;
			x3=(x&15)<<2; x=*c++;
			x3|=x>>6;
			x4=x&63;
			*d++=base64_encode[x1];			
			*d++=base64_encode[x2];			
			*d++=base64_encode[x3];			
			*d++=base64_encode[x4];			
			bcnt+=4;
			cnt-=3;
		}
		else if(cnt==2)
		{
			x=*c++;
			x1=x>>2;
			x2=(x&3)<<4; x=*c++;
			x2|=x>>4;
			x3=(x&15)<<2;
			*d++=base64_encode[x1];			
			*d++=base64_encode[x2];			
			*d++=base64_encode[x3];			
			*d++='=';			
			bcnt+=4;
			cnt=0;
		}
		else /* cnt==1 */
		{
			x=*c++;
			x1=x>>2;
			x2=(x&3)<<4; 
			*d++=base64_encode[x1];			
			*d++=base64_encode[x2];			
			*d++='=';			
			*d++='=';			
			bcnt+=4;
			cnt=0;
		}
		if(bcnt==72)
		{
			*d++=13;
			*d++=10;
			filled+=bcnt+2;
			bcnt=0;
			if(filled > 1980)
			{
				*d=0;
				Fwrite(fh, strlen((char*)buf), buf);
				d=buf; filled=0;
			}
		}
	}
	*d++=13;
	*d++=10;
	*d=0;
	Fwrite(fh, strlen((char*)buf), buf);
}

/* ------------------------------------------- */

void too_much_quote_check(EDIT_OB *edob)
{
	ED_LIN	*el=edob->first;
	
	long cnt=0, qot=0;
	
	while(el)
	{
		++cnt;
		if(el->quoted) ++qot;
		el=el->next;
	}
	
	if(qot > cnt/2)
		form_alert(1, gettext(MUCHQUOTE));
}

int save_mail(WINDOW *win)
{	
	return(save_mail_as(((EDIT_OB*)(win->user))->file, win));
}

char *set_clam(char *adr)
{/* FÅgt jedem (Komma-getrenntem) Eintrag "<>"-Klammern hinzu */
	static char	buf[512];
	char		*x, *y, mem;
	
	buf[0]=0;
	x=adr;
	while(*x)
	{
		y=x;
		while(*y && (*y!=',')) ++y;
		mem=*y;*y=0;
		if(x[0]!='<') strcat(buf, "<");
		strcat(buf, x);
		if(x[strlen(x)-1]!='>') strcat(buf, ">");
		if(mem) strcat(buf, ",");
		*y=mem;
		while(*y==',')++y;
		x=y;
	}
	return(buf);
}

int check_fincr_edob(EDIT_OB *edob)
{/* Returns 1 if edob ends with CR, else 0 */
	ED_LIN	*el=edob->first;
	int cr=0;
		
	while(el)
	{
		if(strlen(el->line))
		{
			if(el->line[strlen(el->line)-1]==13) cr=1;
			else cr=0;
		}
		el=el->next;
	}
	return(cr);
}

int check_fincr_atx(MAIL_ATX *atx)
{/* Returns 1 if atx ends with CR, else 0 */
	if( (atx->atx[atx->atx_len-1]==13) || (atx->atx[atx->atx_len-1]==10))
		return(1);
	return(0);
}

int save_mail_as(char *path, WINDOW *win)
{	/* 1=Ok, 0=Fehler */
#define Fswrite(a, b) Fwrite(a, strlen(b), b);
	MAIL_ATX	*atx, dum_atx;
	EDIT_OB	*edob=win->user;
	long	fhl;
	int		fh, res, fin_cr=0;
	char	*adr, bound[60];
	time_t	tm;

	too_much_quote_check(edob);

	res=adr_resolve(xted(win->dinfo->tree, ETO)->te_ptext, &adr);
	if(res==-1) {form_alert(1, gettext(ADR_REKURS)); return(0);}
	if(res==0) {form_alert(1, gettext(NOMEM)); return(0);}
	if(adr)free(adr);
	res=adr_resolve(xted(win->dinfo->tree, ECC)->te_ptext, &adr);
	if(res==-1) {form_alert(1, gettext(ADR_REKURS)); return(0);}
	if(res==0) {form_alert(1, gettext(NOMEM)); return(0);}
	if(adr)free(adr);
	res=adr_resolve(xted(win->dinfo->tree, EBCC)->te_ptext, &adr);
	if(res==-1) {form_alert(1, gettext(ADR_REKURS)); return(0);}
	if(res==0) {form_alert(1, gettext(NOMEM)); return(0);}
	if(adr)free(adr);
		
	bound[0]=0;	
	fhl=Fcreate(path, 0);
	if(fhl < 0) {gemdos_alert(gettext(CREATEERR), fhl); return(0);}
	fh=(int)fhl;
	
	/* Header schreiben */
	
	Fswrite(fh, "From: <local>\r\n");
	
	if(xted(win->dinfo->tree, ETO)->te_ptext[0])
	{
		if(edob->pm_om)
		{/* OM */
			Fswrite(fh, "Newsgroups: ");
			Fswrite(fh, xted(win->dinfo->tree, ETO)->te_ptext);
		}
		else
		{
			Fswrite(fh, "To: ");
			res=adr_resolve(xted(win->dinfo->tree, ETO)->te_ptext, &adr);
			if(adr)
			{
				Fswrite(fh, set_clam(adr));
				if(!strchr(adr, '@')) no_at_warning=1;
				free(adr);
			}
			else
			{
				Fswrite(fh, set_clam(xted(win->dinfo->tree, ETO)->te_ptext));
				if(!strchr(xted(win->dinfo->tree, ETO)->te_ptext, '@')) no_at_warning=1;
			}
		}
		Fswrite(fh, "\r\n");
	}
	
	if(xted(win->dinfo->tree, ECC)->te_ptext[0])
	{
		Fswrite(fh, "Cc: ");
		res=adr_resolve(xted(win->dinfo->tree, ECC)->te_ptext, &adr);
		if(adr)
		{
			Fswrite(fh, set_clam(adr));
			free(adr);
		}
		else
			Fswrite(fh, set_clam(xted(win->dinfo->tree, ECC)->te_ptext));
		Fswrite(fh, "\r\n");
	}

	if(xted(win->dinfo->tree, EBCC)->te_ptext[0])
	{
		Fswrite(fh, "Bcc: ");
		res=adr_resolve(xted(win->dinfo->tree, EBCC)->te_ptext, &adr);
		if(adr)
		{
			Fswrite(fh, set_clam(adr));
			free(adr);
		}
		else
			Fswrite(fh, set_clam(xted(win->dinfo->tree, EBCC)->te_ptext));
		Fswrite(fh, "\r\n");
	}

	if(edob->reply_to[0])
	{
		Fswrite(fh, "Reply-To: ");
		Fswrite(fh, edob->reply_to);
		Fswrite(fh, "\r\n");
	}
	
	Fswrite(fh, "Subject: ");
	if(xted(win->dinfo->tree, ESUBJECT)->te_ptext[0])
		Fhdencode(fh, xted(win->dinfo->tree, ESUBJECT)->te_ptext);
	else
		Fswrite(fh, "<no subject>");
	Fswrite(fh, "\r\n");
	
	Fswrite(fh, "Date: ");
	tm=time(NULL);
	adr=ctime(&tm);
	Fwrite(fh, 3, adr);				/* <day> */
	Fwrite(fh, 2, ", ");
	Fwrite(fh, 3, &(adr[8])); /* dd+' ' */
	Fwrite(fh, 4, &(adr[4])); /* <month>+' ' */
	Fwrite(fh, 4, &(adr[20])); /* yyyy */
	Fwrite(fh, 10, &(adr[10])); /* ' '+hh:mm:ss+' ' */
	if((adr=get_timezone())!=NULL)
		Fwrite(fh, 5, adr);
	else
		Fwrite(fh, 3, "GMT");
	Fwrite(fh,2,"\r\n");

	if(edob->references[0])
	{
		if(edob->pm_om)	/* OM */
			Fwrite(fh, 12,"References: ");
		else
			Fwrite(fh, 13,"In-Reply-To: ");
		Fswrite(fh, edob->references);
		Fwrite(fh, 2, "\r\n");
	}

	Fswrite(fh, "X-Mailer: ASH Emailer ");
	Fswrite(fh, EMAILER_VERSION);
	Fswrite(fh, "\r\n");
	Fswrite(fh, "MIME-Version: 1.0\r\nContent-Type: ");
	if( (count_atx(edob->atx_first) > 1) ||
			((count_atx(edob->atx_first) == 1) && (edob->first) && (edob->first->line[0]))
		)
	{
		Fswrite(fh, "multipart/mixed; boundary=\"");
		srand((uint)time(NULL));
		strcpy(bound, "--XB--");
		itoa(rand(), &(bound[strlen(bound)]), 16);
		itoa(rand(), &(bound[strlen(bound)]), 16);
		itoa(rand(), &(bound[strlen(bound)]), 16);
		Fswrite(fh, bound);
		Fswrite(fh, "\"\r\n\r\n");
		Fswrite(fh, "--");
		Fswrite(fh, bound);
		Fswrite(fh, "\r\nContent-type: ");
	}

	graf_mouse(BUSYBEE, NULL);
	
	if(edob->first && edob->first->line[0])
	{
		Fswrite(fh, "text/plain; charset=iso-8859-1\r\n");
		if(edob->pm_om)
		{
			Fswrite(fh, "Content-transfer-encoding: 8bit\r\n\r\n");
			F8bitencode(fh, edob);
			fin_cr=check_fincr_edob(edob);
		}
		else
		{
			Fswrite(fh, "Content-transfer-encoding: quoted-printable\r\n\r\n");
			Fqpencode(fh, edob);
			fin_cr=check_fincr_edob(edob);
		}
		if(	(sw_mode && (win->dinfo->tree[EDSIG].ob_spec.iconblk==ovorl[ED_SW_SIG].ob_spec.iconblk)) ||
				(!sw_mode && !(win->dinfo->tree[EDSIG].ob_state & SELECTED)) )
		{
			switch(win->dinfo->tree[EDSIG].ob_spec.iconblk->ib_ptext[0])
			{
				case '1': dum_atx.atx=ios.sig1;	break;
				case '2': dum_atx.atx=ios.sig2;	break;
				case '3': dum_atx.atx=ios.sig3;	break;
			}
			if((dum_atx.atx_len=strlen(dum_atx.atx)) > 0)
			{
				if(edob->pm_om)
					F8bitatxencode(fh, &dum_atx);
				else
					Fqpatxencode(fh, &dum_atx);
				fin_cr=check_fincr_atx(&dum_atx);
			}
		}
		if(fin_cr==0)	Fswrite(fh, "\r\n");
		if(bound[0])
		{
			Fswrite(fh, "--");
			Fswrite(fh, bound);
			Fswrite(fh, "\r\nContent-type: ");
		}
	}
	atx=edob->atx_first;
	while(atx)
	{
		Fswrite(fh, atx->mime_type);
		if(!strncmp(atx->mime_type, "text/", 5))
		{
			Fswrite(fh, "; charset=iso-8859-1; name=\"");
			Fswrite(fh, atx->file_name);
			Fswrite(fh, "\"\r\nContent-transfer-encoding: quoted-printable\r\n\r\n");
			Fqpatxencode(fh, atx);
		}
		else
		{
			Fswrite(fh, "; name=\"");
			Fswrite(fh, atx->file_name);
			Fswrite(fh, "\"\r\nContent-transfer-encoding: base64\r\n\r\n");
			Fb64encode(fh, atx);
		}
		atx=atx->next;
		if(bound[0])
		{
			Fwrite(fh, 2, "--");
			Fswrite(fh, bound);
			if(atx==NULL) Fwrite(fh, 4, "--\r\n");
			else	Fwrite(fh, 16, "\r\nContent-type: ");
		}
	}

	Fclose(fh);
	graf_mouse(ARROW, NULL);
	return(1);
#undef Fswrite
}