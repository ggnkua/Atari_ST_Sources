#include <tos.h>
#include <stdlib.h>

#include <image.h>

/*
	int load_ximg(char *name,MFDB *mfdb,IMG_COLOR **coltab)
	int load_img(char *name,MFDB *mfdb)

lade gem-image datei

rÅckgabewerte
	0  -> ok
	<0 -> os-error
	>0 -> 3: format falsch
	   -> 2: speicher reicht nicht
	   -> 1: allg error

coltab wird auf 0l gesetzt wenn keine XIMG datei geladen wird
speicher fÅr bilddaten und farbtabelle wird mit malloc alloziert
*/

#define BUF_SIZE		2048

static int f_id;
static char *w_buf;
static int z,z1;
static long l;

static int init_get_byte(long len)
{
	l=len;
	z=0;
	w_buf=malloc(BUF_SIZE);
	if ( !w_buf )
		return IMG_MEMORY;
	return IMG_OK;
}

static int get_byte(char *byte)
{
long len;
long ret;
	if ( z==0 ) {
		if ( l<BUF_SIZE ) {
			len=l;
		}
		else {
			len=BUF_SIZE;
			l-=BUF_SIZE;
		}
		if ( (ret=Fread(f_id,len,w_buf))!=len ) {
			if ( ret<0 )
				return (int)ret;
			else
				return IMG_ERROR;
		}
		z=(int)len;
		z1=0;
	}
	*byte=w_buf[z1];
	z1++;
	z--;
	return IMG_OK;
}

static int get_block(char *buf,int len)
{
int ret;

	for ( ; len>0; len-- )
		if ( (ret=get_byte(buf++))!=IMG_OK )
			return ret;
	return IMG_OK;
}

static int do_ld_img(char *buffer,char *line_buf,IMG_HEADER *head)
{				/* return: <0 -> os-error, IMG_FORMAT falsches datenformat, IMG_ERROR tosfehler, 0 ok */
char *line,*h,*h1;
char byte,l_cnt,b_cnt;
char muster[16];
int lline_len,line_len;
long pl_len;
int planes,lines,bytes,i;

	line_len=head->pix_num/8;
	if ( head->pix_num%8 )
		line_len++;
	lline_len=line_len*head->plane_num;
	pl_len=(long)line_len*head->scan_num;
	if ( line_len&1 )
		pl_len+=head->scan_num;

	line=buffer;
	h=line_buf;
	bytes=lines=0;
	l_cnt=1;		/* anzahl von zeilenwiederholungen */

	while (1) {
		if ( bytes>=lline_len ) {	/* ganze zeile eingelesen */
			for ( ; l_cnt>0; l_cnt-- ) {
				h1=line_buf;
				for ( planes=0; planes<head->plane_num; planes++ ) {
					for ( i=0,h=line+planes*pl_len; i<line_len; i++ )
						*h++=*h1++;
					if ( line_len&1 )
						*h++=0;
				}
				lines++;
				line+=line_len;
				if ( line_len&1 )
					line++;
			}
			if ( lines>=head->scan_num )
				return IMG_OK;
			l_cnt=1;
			h=line_buf;
			bytes=0;
		}

		if ( get_byte(&byte)!=IMG_OK )
			return IMG_ERROR;
		if ( byte==0 ) {
			if ( get_byte(&byte)!=IMG_OK )
				return IMG_ERROR;
			if ( byte==0 ) {
				if ( get_byte(&byte)!=IMG_OK )
					return IMG_ERROR;
				if ( byte!=0xFF )
					return IMG_FORMAT;
				if ( get_byte(&l_cnt)!=IMG_OK )
					return IMG_ERROR;
			}
			else {
				for ( i=0; i<head->pat_len; i++ )
					if ( get_byte(muster+i)!=IMG_OK )
						return IMG_ERROR;
				for ( ; byte>0; byte-- ) {
					for ( i=0; i<head->pat_len; i++ ) {
						*h++=muster[i];
						bytes++;
						if ( bytes>lline_len )
							return IMG_FORMAT;
					}
				}
			}
		}
		else if ( byte==0x80 ) {
			if ( get_byte(&b_cnt)!=IMG_OK )
				return IMG_ERROR;
			for ( ; b_cnt>0; b_cnt-- ) {
				if ( get_byte(h++)!=IMG_OK )
					return IMG_ERROR;
				bytes++;
				if ( bytes>lline_len )
					return IMG_FORMAT;
			}
		}
		else {
		  int set=0;
			if ( byte&0x80 ) {
				byte&=0x7F;
				set=0xFF;
			}
			for ( ; byte>0; byte-- ) {
				*h++=set;
				bytes++;
				if ( bytes>lline_len )
					return IMG_FORMAT;
			}
		}
	}
}

static IMG_ERR do_load_ximg(IMG_HEADER *head,char *name,MFDB *picture,IMG_COLOR **coltab)
{
long len,llen;
int line_len;
IMG_ERR ret;
char *line_buf;
char byte;

	picture->fd_addr=0l;

	f_id=Fopen(name,0);
	if ( f_id<0 )
		return f_id;

	if ( (len=Fseek(0,f_id,2))<0 ) {
		Fclose(f_id);
		return (int)len;
	}
	if ( Fseek(0,f_id,0)!=0l ) {
		Fclose(f_id);
		return IMG_ERROR;
	}

	if ( init_get_byte(len)!=IMG_OK )
		return IMG_MEMORY;

	/*
			lese header
	*/
	if ( (ret=get_block((char*)head,(int)sizeof(IMG_HEADER)))!=IMG_OK ) {
		Fclose(f_id);
		return ret;
	}

	head->head_len*=2;	/* head_len in bytes, nicht words */
	len-=head->head_len;
	head->head_len-=(int)sizeof(IMG_HEADER);

	*coltab=0l;
	if ( head->head_len>sizeof(IMG_HEADER) ) {		/* zus. header Åberlesen */
	  struct {									/* ximg-header lesen */
		long id;
		int col_flag;
	  } ximg;
	  int col_len;

		if ( head->head_len>sizeof(ximg) ) {
			if ( get_block((char*)&ximg,(int)sizeof(ximg))!=IMG_OK ) {
				Fclose(f_id);
				return IMG_ERROR;
			}
			head->head_len-=(int)sizeof(ximg);
			if ( ximg.id=='XIMG' && ximg.col_flag==0 ) {
				col_len=(int)sizeof(IMG_COLOR)*1<<head->plane_num;
				*coltab=malloc(col_len);
				if ( *coltab==0l ) {
					Fclose(f_id);
					return IMG_MEMORY;
				}
				if ( col_len<=head->head_len ) {
					if ( get_block((char*)*coltab,col_len)!=IMG_OK ) {
						Fclose(f_id);
						return IMG_ERROR;
					}
					head->head_len-=(int)col_len;
				}
				else {
					free(*coltab);
				}
			}
		}
	}

	if ( head->head_len>0 ) {
		while ( head->head_len-- ) {
			if ( (ret=get_byte(&byte))!=IMG_OK ) {
				Fclose(f_id);
				return ret;
			}
		}
	}
	else if ( head->head_len<0 ) {
		Fclose(f_id);
		return IMG_FORMAT;
	}

	if ( head->plane_num>8 || head->pat_len>8 ) {
		Fclose(f_id);
		return IMG_FORMAT;
	}

	picture->fd_h=head->scan_num;
	picture->fd_nplanes=head->plane_num;
	picture->fd_stand=1;

	line_len=head->pix_num/8;
	if ( head->pix_num%8 )
		line_len++;
	picture->fd_wdwidth=line_len/2;
	if ( line_len&1 )
		picture->fd_wdwidth++;
	
	picture->fd_w=head->pix_num;

	len=(long)picture->fd_wdwidth*2*(long)head->scan_num*(long)head->plane_num;

	picture->fd_addr=malloc(len);
	if ( picture->fd_addr==0l ) {
		Fclose(f_id);
		return IMG_MEMORY;
	}

	llen=(long)head->pix_num*head->plane_num/8;
	line_buf=malloc(llen);
	if ( !line_buf ) {
		Fclose(f_id);
		return IMG_MEMORY;
	}

	ret=do_ld_img(picture->fd_addr,line_buf,head);

	Fclose(f_id);
	free(line_buf);
	free(w_buf);

	return ret;
}


static IMG_ERR do_load_img(IMG_HEADER *head,char *name,MFDB *picture)
{
long len,llen;
int line_len;
IMG_ERR ret;
char *line_buf;
char byte;

	picture->fd_addr=0l;

	f_id=Fopen(name,0);
	if ( f_id<0 )
		return f_id;

	if ( (len=Fseek(0,f_id,2))<0 ) {
		Fclose(f_id);
		return (int)len;
	}
	if ( Fseek(0,f_id,0)!=0l ) {
		Fclose(f_id);
		return IMG_ERROR;
	}

	if ( init_get_byte(len)!=IMG_OK )
		return IMG_MEMORY;

	/*
			lese header
	*/
	if ( (ret=get_block((char*)head,(int)sizeof(IMG_HEADER)))!=IMG_OK ) {
		Fclose(f_id);
		return ret;
	}

	head->head_len*=2;	/* head_len in bytes, nicht words */
	len-=head->head_len;
	head->head_len-=(int)sizeof(IMG_HEADER);

	if ( head->head_len>0 ) {
		while ( head->head_len-- ) {
			if ( (ret=get_byte(&byte))!=IMG_OK ) {
				Fclose(f_id);
				return ret;
			}
		}
	}
	else if ( head->head_len<0 ) {
		Fclose(f_id);
		return IMG_FORMAT;
	}

	if ( head->plane_num>8 || head->pat_len>8 ) {
		Fclose(f_id);
		return IMG_FORMAT;
	}

	picture->fd_h=head->scan_num;
	picture->fd_nplanes=head->plane_num;
	picture->fd_stand=1;

	line_len=head->pix_num/8;
	if ( head->pix_num%8 )
		line_len++;
	picture->fd_wdwidth=line_len/2;
	if ( line_len&1 )
		picture->fd_wdwidth++;
	
	picture->fd_w=head->pix_num;

	len=(long)picture->fd_wdwidth*2*(long)head->scan_num*(long)head->plane_num;

	picture->fd_addr=malloc(len);
	if ( picture->fd_addr==0l ) {
		Fclose(f_id);
		return IMG_MEMORY;
	}

	llen=(long)head->pix_num*head->plane_num/8;
	line_buf=malloc(llen);
	if ( !line_buf ) {
		Fclose(f_id);
		return IMG_MEMORY;
	}

	ret=do_ld_img(picture->fd_addr,line_buf,head);

	Fclose(f_id);
	free(line_buf);
	free(w_buf);

	return ret;
}


IMG_ERR xload_ximg(IMG_HEADER *head,char *name,MFDB *picture,IMG_COLOR **coltab)
{
IMG_ERR ret;

	ret=do_load_ximg(head,name,picture,coltab);
	if ( ret!=IMG_OK ) {
		if ( picture->fd_addr ) {
			free(picture->fd_addr);
			picture->fd_addr=0l;
		}
		if ( *coltab ) {
			free(*coltab);
			*coltab=0l;
		}
		if ( w_buf )
			free(w_buf);
	}
	return ret;
}

IMG_ERR xload_img(IMG_HEADER *head,char *name,MFDB *picture)
{
IMG_ERR ret;

	ret=do_load_img(head,name,picture);
	if ( ret!=IMG_OK ) {
		if ( picture->fd_addr ) {
			free(picture->fd_addr);
			picture->fd_addr=0l;
		}
		if ( w_buf )
			free(w_buf);
	}
	return ret;
}

IMG_ERR load_ximg(char *name,MFDB *picture,IMG_COLOR **coltab)
{
IMG_HEADER head;

	return xload_ximg(&head,name,picture,coltab);
}

IMG_ERR load_img(char *name,MFDB *picture)
{
IMG_HEADER head;

	return xload_img(&head,name,picture);
}
