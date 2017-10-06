/*****************************************************************************
*
*											  7UP
*									  Modul: MENUIKEY.C
*									 (c) by TheoSoft '90
*
*****************************************************************************/
#include <portab.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#if GEMDOS
#include <tos.h>
#include <ext.h>
#else
extern unsigned char b_keycod[];
#endif
#include <aes.h>

#if GEMDOS
#define  F1		0x3b
#define  F10	0x44
#define  F11	0x54
#define  F20	0x5d

#define  K_CAPS	0x10
#define  K_SHIFT	0x03
#define  K_SCAN	0x8000
#define  K_NUM		0x4000
#else
#define  F1		0x68
#define  F10	0x71
#define  F11	0x72
#define  F20	0x7B
#endif

#define FLAGS15 0x8000

int SysKey=FALSE;

#if GEMDOS
static KEYTAB *pkeytbl=NULL;
#endif

extern int ydesk;

static int test_entry(char *str, int kstate, int key, int ob_flags)
{
	char *pchar, vchr;
	int ret=0,zahl;

	pchar = str;
	while(*pchar)
		pchar++;
	while(*--pchar == ' ')
		;
	vchr=tolower(*pchar);

	if(vchr == tolower((char)key) && !(key & 0x8000))/* 0x8000 = Scancode */
	{
		pchar-=2;
		if((*pchar==1	&& *(pchar+1)=='^' && kstate==(K_CTRL|K_LSHIFT)) ||
			(*pchar==1	&& *(pchar+1)== 7  && kstate==(K_ALT |K_LSHIFT)))
			return(TRUE);

		if((*pchar==' ' && *(pchar+1)=='^' && kstate==K_CTRL) ||
			(*pchar==' ' && *(pchar+1)== 7  && kstate==K_ALT))
			return(TRUE);

		if(((*pchar==' ' && *(pchar+1)=='^' && kstate==(K_CTRL|K_LSHIFT)) ||
			 (*pchar==' ' && *(pchar+1)== 7  && kstate==(K_ALT |K_LSHIFT))) &&
			(ob_flags & FLAGS15))
			return(TRUE);
	}
	if(key & 0x8000) /* Funktionstaste */
	{
		if(*pchar =='\'' && (kstate & (K_CTRL|K_ALT))==0)
		{
			pchar--;
			vchr=tolower(*pchar);
			if(vchr==key && *(pchar-1)=='\'')
				ret=1;
		}
		else
		{
			if(*pchar >= '0' && *pchar <= '9')
			{
				zahl=*pchar-'0';
				pchar--;
				if(*pchar >= '0' && *pchar <= '9')
				{
					zahl+=(*pchar-'0')*10;
					pchar--;
				}
				if(*pchar == 'F')
				{
				   key&=0x00FF;
					if(*(pchar-1)=='') /* z.B.: F4 */
						zahl+=10;
					if((zahl>=1) && (zahl<=10))
						if(zahl==(key-F1+1))
							ret=1;
					if((zahl>=11) && (zahl<=20))
						if(zahl==(key-F11+11))
							ret=1;
				}
			}
      }
   }
	return(ret);
}

int menu_ikey(OBJECT *m_tree, int kstate, int key, int *menu, int *item)
{
	int do_quit=0, desk=1;
	register int m_title, c_title, m_entry, c_entry;
	int msgbuf[8];
   
	if(!(kstate & (K_CTRL|K_ALT)) || tolower((char)key)=='y')
		return(FALSE);         /* keine Sondertaste > kein Shortcut */

	msgbuf[4]=0;

	m_title=(m_tree+m_tree->ob_head)->ob_head;
	c_title=(m_tree+m_title)->ob_head;
	m_entry=(m_tree+m_tree->ob_tail)->ob_head;
	c_entry=(m_tree+m_entry)->ob_head;
	while(!do_quit)
	{
		if(((m_tree +c_title)->ob_state & DISABLED) == 0)
		{
			while(!do_quit && c_entry != m_entry && c_entry != -1)
			{
				if( ((m_tree+c_entry)->ob_type != G_USERDEF) &&
					(((m_tree+c_entry)->ob_state & DISABLED) == 0) &&
					 ((m_tree+c_entry)->ob_type == G_STRING ||
					  (m_tree+c_entry)->ob_type == G_BUTTON))
					do_quit=test_entry((char *)(m_tree+c_entry)->ob_spec.index,
									kstate,key,(m_tree+c_entry)->ob_flags);
				if(do_quit)
				{
					msgbuf[0]=MN_SELECTED;
					msgbuf[1]=_GemParBlk.global[2];
					msgbuf[2]=0;
					*menu=msgbuf[3]=c_title;
				   *item=msgbuf[4]=c_entry;
					wind_update(BEG_UPDATE);
					wind_update(END_UPDATE);
					menu_tnormal(m_tree,c_title,0);
					appl_write(msgbuf[1],16,msgbuf);
				}
				c_entry=(m_tree+c_entry)->ob_next;
				if(desk)
				{
					c_entry=m_entry;
					desk=0;
				}
			}
		}
		c_title=(m_tree+c_title)->ob_next;
		m_entry=(m_tree+m_entry)->ob_next;
		c_entry=(m_tree+m_entry)->ob_head;
		if(c_title==m_title)
		{
			do_quit=1;
		}
	}
	return(msgbuf[4]);
}

int MapKey(int *kstate, int *key)
{
	register int ks,sc,ret;

	if(!pkeytbl)
		pkeytbl=Keytbl(-1L,-1L,-1L);

	sc=((*key)>>8)&0xFF;
	ks=(int)Kbshift(-1);

   /* ALT 1 - ALT ž -> runterrechnen auf 2 - 13 */
   if((ks&K_ALT) && (sc>=0x78) && (sc<=0x83))
	   sc-=0x76;

	if(ks&K_CAPS && !(ks&K_SHIFT))
		ret=pkeytbl->capslock[sc];
	else
	{
		if(ks&K_SHIFT)
      {
         if (( sc >= 0x54 ) && ( sc <= 0x5d ))
            ret= pkeytbl->shift[sc - 0x19];
         else if (( sc == 0x47 ) || ( sc == 0x48 ) || ( sc == 0x4b ) ||
               ( sc == 0x4d ) || ( sc == 0x50 ) || ( sc == 0x52 ))
                  /* Ins, Clr, Cursor - fehlt im Profibuch */
            ret = 0;
         else
            ret = pkeytbl->shift[sc];
      }
      else
         ret = pkeytbl->unshift[sc];
	}
	if(!ret)
		ret=sc|K_SCAN;
	else  /* Ziffernblock markieren */
		if((sc==0x4A) || (sc==0x4E) || ((sc>=0x63) && (sc<=0x72)))
			ret|=K_NUM;

	if(ks & K_RSHIFT)
	{
		ks &= ~K_RSHIFT;
		ks |=  K_LSHIFT;
	}

   ks&=~K_CAPS; /* CAPSLOCK ausblenden */

	*kstate=ks;
	*key=((ks<<8)|ret);
/*
   sonderzeichen(kstate,key);
*/
/*
printf("\33H%3d|$%0004X|$%0004X|%c|",sc,*kstate,*key,(char)(*key));
*/
	return(*key);
}

