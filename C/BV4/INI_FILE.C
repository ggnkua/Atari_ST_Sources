/*******************************************************************************
	Bitmap view Copyright (c) 1995 by	Christophe BOYANIQUE
													http://www.raceme.org
													tof@raceme.org
********************************************************************************
	This program is free software; you can redistribute it and/or modify it
	under the terms of the GNU General Public License as published by the Free
	Software Foundation; either version 2 of the License, or any later version.
	This program is distributed in the hope that it will be useful, but WITHOUT
	ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
	FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
	more details.
	You should have received a copy of the GNU General Public License along
	with this program; if not, write to the Free Software Foundation, Inc.,
	59 Temple Place - Suite 330, Boston, MA 02111, USA.
********************************************************************************
	TABULATION: 3 CARACTERES
*******************************************************************************/

#include		"PROTO.H"

/*******************************************************************************
	FUNCTIONS
*******************************************************************************/
static void	_parINI		(char *tit,char *buf,char *p);
static void	_parINIwin	(char *tit,char *buf,char *p,window *win);
static void _outINI		(char *txt);


/*******************************************************************************
	VARIABLES
*******************************************************************************/
static int	his1,his2;
static long	badr,blen,boff;


/*******************************************************************************
	This function reads the INI file containing EGlib configuration
*******************************************************************************/
void _loadINI(int code)
{
	window	win;
	FILE		*ha;
	int		eof;
	char		tit[256],buf[256],*p,*q;

	ha=fopen(glb.opt.INI_File,"r");

	his1=his2=0;
	if (ha)
	{
		do
		{
			if (!fgets(tit,256,ha))
				goto fileclose;
		}	while (tit[0]!='[');
		q=tit+strlen(tit)-1;
		*q=0;
		do
		{
			if (tit[0]=='[')
			{
				_cls((long)&win,sizeof(window));
				do
				{
					eof=!fgets(buf,256,ha);
					q=buf+strlen(buf)-1;
					*q=0;
					p=strchr(buf,'=');
					if (p)
					{
						*p++=0;
						if (code)
							_parINIwin(tit,buf,p,&win);
						else
							_parINI(tit,buf,p);
					}
				}	while (p);
				if (eof)
					goto fileclose;
				strcpy(tit,buf);
				while (tit[0]!='[')
				{
					if (!fgets(tit,256,ha))
						goto fileclose;
				}
				q=tit+strlen(tit)-1;
				*q=0;
			}
		}	while (ha);
fileclose:
		fclose(ha);
	}
	glb.aes.x=-1;

}


/*******************************************************************************
	This function inits the variables
*******************************************************************************/
static void _parINI(char *tit,char *buf,char *p)
{

	if (!strcmp(tit,"[Parx]"))
	{
		if (!strcmp(buf,"Path"))
		{
			strcpy(glb.div.log,p);
			glb.div.log[strlen(p)-1L]='\0';
			if (_dexist(glb.div.log))
				strcpy(glb.parx.Path,p);
		}
		else
		if (!strcmp(buf,"Mask"))
			glb.parx.Mask=atoi(p);
		else
		if (!strcmp(buf,"Def_Rim"))
			strcpy(glb.parx.def_rim,p);
		else
		if (!strcmp(buf,"Def_Wim"))
			strcpy(glb.parx.def_wim,p);
		else
		if (!strcmp(buf,"Def_Ifx"))
			strcpy(glb.parx.def_ifx,p);
		else
		if (!strcmp(buf,"Def_Trm"))
			glb.parx.d_trm=atoi(p);
		else
		if (!strcmp(buf,"Def_dim"))
			glb.parx.def_dim=atoi(p);
		else
		if (!strcmp(buf,"Def_Xdim"))
			glb.parx.def_xdim=atoi(p);
		else
		if (!strcmp(buf,"Def_Ydim"))
			glb.parx.def_ydim=atoi(p);
	}
	else
	if (!strcmp(tit,"[Options]"))
	{
		if (!strcmp(buf,"Use_Extensions"))
			glb.opt.useExt=atoi(p);
		else
		if (!strcmp(buf,"Use_Paths"))
			glb.opt.usePat=atoi(p);
		else
		if (!strcmp(buf,"Update_Paths"))
			glb.opt.MAJ=atoi(p);
		else
		if (!strcmp(buf,"GFXcard"))
			glb.opt.gfx=atoi(p);
		else
		if (!strcmp(buf,"Load_to_icon"))
			glb.opt.zap=atoi(p);
		else
		if (!strcmp(buf,"Force_Palette"))
			glb.opt.pal=atoi(p);
		else
		if (!strcmp(buf,"Dithering"))
			glb.opt.trm=atoi(p);
		else
		if (!strcmp(buf,"Desk_Full"))
			glb.opt.deskfull=atoi(p);
		else
		if (!strcmp(buf,"Log_File"))
		{
			glb.opt.baklog=atoi(p);
			if (glb.opt.log!=LOG_FORCE)
				glb.opt.log=glb.opt.baklog;
		}
		else
		if (!strcmp(buf,"Log_Mask"))
		{
			glb.opt.baklogmask=atol(p);
			if (glb.opt.log!=LOG_FORCE)
				glb.opt.logmask=glb.opt.baklogmask;
		}
		else
		if (!strcmp(buf,"Save_Config"))
			glb.opt.Save_Config=atoi(p);
		else
		if (!strcmp(buf,"Win_Num"))
			glb.opt.Win_Num=atoi(p);
	}
	else
	if (!strcmp(tit,"[Interface]"))
	{
		if (!strcmp(buf,"Flash_PopUp"))
			glb.opt.Flash_PopUp=atoi(p);
		else
		if (!strcmp(buf,"Mouse_Form"))
			glb.opt.Mouse_Form=atoi(p);
		else
		if (!strcmp(buf,"Close_Win"))
			glb.opt.win=atoi(p);
		else
		if (!strcmp(buf,"Language"))
			glb.opt.Language=atoi(p);
		else
		if (!strcmp(buf,"Auto_Icon"))
			glb.opt.Auto_Icon=atoi(p);
		else
		if (!strcmp(buf,"Rev_Horiz"))
			glb.opt.Rev_Horiz=atoi(p);
		else
		if (!strcmp(buf,"Rev_Verti"))
			glb.opt.Rev_Verti=atoi(p);
		else
		if (!strcmp(buf,"Swap_Path"))
		{
			strcpy(glb.div.log,p);
			glb.div.log[strlen(p)-1L]='\0';
			if (_dexist(glb.div.log))
				strcpy(glb.div.SWP_Path,p);
		}
		else
		if (!strcmp(buf,"Log_File"))
		{
			strcpy(glb.div.log,p);
			glb.div.log[strlen(p)-1L]='\0';
			strcpy(glb.opt.LOG_File,p);
		}
		else
		if (!strcmp(buf,"Memory"))
			glb.opt.Mem_Boot=atoi(p);
		else
		if (!strcmp(buf,"Desk_Color2"))
			glb.aes.desk.color2=atoi(p);
		else
		if (!strcmp(buf,"Desk_Color4"))
			glb.aes.desk.color4=atoi(p);
		else
		if (!strcmp(buf,"Desk_Trame1"))
			glb.aes.desk.trame1=atoi(p);
		else
		if (!strcmp(buf,"Desk_Trame2"))
			glb.aes.desk.trame2=atoi(p);
		else
		if (!strcmp(buf,"Desk_Trame4"))
			glb.aes.desk.trame4=atoi(p);
		else
		if (!strcmp(buf,"Def_Trm"))
			glb.opt.d_trm=atoi(p);
	}
	else
	if (!strcmp(tit,"[Print]"))
	{
		if (!strcmp(buf,"Device"))
			glb.print.dev=atoi(p);
		else
		if (!strcmp(buf,"Max_Size"))
			glb.print.max=atoi(p);
		else
		if (!strcmp(buf,"Eject"))
			glb.print.out=atoi(p);
		else
		if (!strcmp(buf,"Xcenter"))
			glb.print.xcenter=atoi(p);
		else
		if (!strcmp(buf,"Ycenter"))
			glb.print.ycenter=atoi(p);
	}
	else
	if (!strcmp(tit,"[Selectric_Ext]"))
		strcpy(glb.opt.ext[atoi(buf)],p);
	else
	if (!strcmp(tit,"[Selectric_Path]"))
		strcpy(glb.opt.pat[atoi(buf)],p);
	else
	if (!strcmp(tit,"[Slide]"))
	{
		if (!strcmp(buf,"Path"))
			strcpy(glb.opt.sl_path,p);
		else
		if (!strcmp(buf,"Name"))
			strcpy(glb.opt.sl_name,p);
		else
		if (!strcmp(buf,"Pfname"))
			strcpy(glb.opt.sl_pfname,p);
		else
		if (!strcmp(buf,"Pause"))
			glb.opt.sl_pause=atoi(p);
		else
		if (!strcmp(buf,"PTime"))
			glb.opt.sl_ptime=atoi(p);
		else
		if (!strcmp(buf,"TurboVeille"))
			glb.opt.sl_tv=atoi(p);
		else
		if (!strcmp(buf,"LedPanel"))
			glb.opt.sl_led=atoi(p);
		else
		if (!strcmp(buf,"Info"))
			glb.opt.sl_info=atoi(p);
		else
		if (!strcmp(buf,"Loop"))
			glb.opt.sl_loop=atoi(p);
		else
		if (!strcmp(buf,"Recursive"))
			glb.opt.sl_rec=atoi(p);
		else
		if (!strcmp(buf,"Zinc"))
			glb.opt.sl_zinc=atoi(p);
		else
		if (!strcmp(buf,"Zdec"))
			glb.opt.sl_zdec=atoi(p);
	}
	else
	if (!strcmp(tit,"[Convert]"))
	{
		if (!strcmp(buf,"Delete"))
			glb.opt.cnv_del=atoi(p);
		else
		if (!strcmp(buf,"Force"))
			glb.opt.cnv_col=atoi(p);
		else
		if (!strcmp(buf,"Src_Path"))
			strcpy(glb.opt.cnv_path,p);
		else
		if (!strcmp(buf,"Src_Name"))
			strcpy(glb.opt.cnv_name,p);
		else
		if (!strcmp(buf,"Src_Pfname"))
			strcpy(glb.opt.cnv_pfname,p);
		else
		if (!strcmp(buf,"Dst_Path"))
			strcpy(glb.opt.cnv_dst,p);
	}
	else
	if (!strcmp(tit,"[Zoom]"))
	{
		if (!strcmp(buf,"High_Quality"))
			glb.opt.zoom_hq=atoi(p);
		else
		if (!strcmp(buf,"Replace"))
			glb.opt.zoom_rep=atoi(p);
	}
}
static void _parINIwin(char *tit,char *buf,char *p,window *win)
{
	int	i;

	if (!strcmp(tit,"[WinForm]"))
	{
		if (!strcmp(buf,"Name"))
			strcpy(win->name,p);
		else
		if (!strcmp(buf,"SName"))
			strcpy(win->sname,p);
		else
		if (!strcmp(buf,"Gadget"))
			win->gadget=atoi(p);
		else
		if (!strcmp(buf,"X-Gadget"))
			win->xgadget=atoi(p);
		else
		if (!strcmp(buf,"Tree"))
			win->id=atoi(p);
		else
		if (!strcmp(buf,"Icon"))
			win->icon=atoi(p);
		else
		if (!strcmp(buf,"Tree_Icon"))
			win->ic_tree=atoi(p);
		else
		if (!strcmp(buf,"xwind"))
			glb.aes.x=(int)((float)atoi(p)*(float)glb.aes.desk.w/(float)1000);
		else
		if (!strcmp(buf,"ywind"))
			glb.aes.y=(int)((float)atoi(p)*(float)glb.aes.desk.h/(float)1000);
		else
		if (!strcmp(buf,"wwind"))
			glb.aes.w=atoi(p);
		else
		if (!strcmp(buf,"hwind"))
			glb.aes.h=atoi(p);
		else
		if (!strcmp(buf,"Small"))
		{
			i=_winForm(win->id,win->name,win->sname,win->ic_tree,win->icon,win->gadget,win->xgadget);
			_clearAesBuffer();
			if (atoi(p))
				_winSmall(i);
			_clearAesBuffer();
		}
	}
}


/*******************************************************************************
	This function writes the INI file containing EGlib configuration
*******************************************************************************/
void _saveINI()
{
	char		txt[128];
	OBJECT	*tree;
	int		i,ha;

	graf_mouse(BUSYBEE,0);

	blen=glb.mem.tfre/2L;
	ha=_mAlloc(blen,0);
	if (ha==NO_MEMORY)
		return;
	badr=glb.mem.adr[ha];
	boff=0L;

	_outINI("[System]\n");
	sprintf(txt,"Prog_Name=%s\n",PRG_NAME);
	_outINI(txt);
	sprintf(txt,"Version=%s\n",RELEASE);
	_outINI(txt);
	_outINI("\n");

	_outINI("[Parx]\n");
	sprintf(txt,"Path=%s\n",glb.parx.Path);
	_outINI(txt);
	sprintf(txt,"Mask=%i\n",glb.parx.Mask);
	_outINI(txt);
	sprintf(txt,"Def_Rim=%s\n",glb.parx.def_rim);
	_outINI(txt);
	sprintf(txt,"Def_Wim=%s\n",glb.parx.def_wim);
	_outINI(txt);
	sprintf(txt,"Def_Ifx=%s\n",glb.parx.def_ifx);
	_outINI(txt);
	sprintf(txt,"Def_Trm=%i\n",glb.parx.d_trm);
	_outINI(txt);
	sprintf(txt,"Def_dim=%i\n",glb.parx.def_dim);
	_outINI(txt);
	sprintf(txt,"Def_Xdim=%i\n",glb.parx.def_xdim);
	_outINI(txt);
	sprintf(txt,"Def_Ydim=%i\n",glb.parx.def_ydim);
	_outINI(txt);
	_outINI("\n");

	_outINI("[Options]\n");
	sprintf(txt,"Use_Extensions=%i\n",glb.opt.useExt);
	_outINI(txt);
	sprintf(txt,"Use_Paths=%i\n",glb.opt.usePat);
	_outINI(txt);
	sprintf(txt,"Update_Paths=%i\n",glb.opt.MAJ);
	_outINI(txt);
	sprintf(txt,"GFXcard=%i\n",glb.opt.gfx);
	_outINI(txt);
	sprintf(txt,"Load_to_icon=%i\n",glb.opt.zap);
	_outINI(txt);
	sprintf(txt,"Force_Palette=%i\n",glb.opt.pal);
	_outINI(txt);
	sprintf(txt,"Dithering=%i\n",glb.opt.trm);
	_outINI(txt);
	sprintf(txt,"Desk_Full=%i\n",glb.opt.deskfull);
	_outINI(txt);
	sprintf(txt,"Log_File=%i\n",glb.opt.baklog);
	_outINI(txt);
	sprintf(txt,"Log_Mask=%li\n",glb.opt.baklogmask);
	_outINI(txt);
	sprintf(txt,"Save_Config=%i\n",glb.opt.Save_Config);
	_outINI(txt);
	sprintf(txt,"Win_Num=%i\n",glb.opt.Win_Num);
	_outINI(txt);
	_outINI("\n");

	_outINI("[Interface]\n");
	sprintf(txt,"Flash_PopUp=%i\n",glb.opt.Flash_PopUp);
	_outINI(txt);
	sprintf(txt,"Mouse_Form=%i\n",glb.opt.Mouse_Form);
	_outINI(txt);
	sprintf(txt,"Close_Win=%i\n",glb.opt.win);
	_outINI(txt);
	sprintf(txt,"Language=%i\n",glb.opt.Language);
	_outINI(txt);
	sprintf(txt,"Auto_Icon=%i\n",glb.opt.Auto_Icon);
	_outINI(txt);
	sprintf(txt,"Rev_Horiz=%i\n",glb.opt.Rev_Horiz);
	_outINI(txt);
	sprintf(txt,"Rev_Verti=%i\n",glb.opt.Rev_Verti);
	_outINI(txt);
	sprintf(txt,"Swap_Path=%s\n",glb.div.SWP_Path);
	_outINI(txt);
	sprintf(txt,"Log_File=%s\n",glb.opt.LOG_File);
	_outINI(txt);
	sprintf(txt,"Memory=%i\n",glb.opt.Mem_Boot);
	_outINI(txt);
	sprintf(txt,"Desk_Color2=%i\n",glb.aes.desk.color2);
	_outINI(txt);
	sprintf(txt,"Desk_Color4=%i\n",glb.aes.desk.color4);
	_outINI(txt);
	sprintf(txt,"Desk_Trame1=%i\n",glb.aes.desk.trame1);
	_outINI(txt);
	sprintf(txt,"Desk_Trame2=%i\n",glb.aes.desk.trame2);
	_outINI(txt);
	sprintf(txt,"Desk_Trame4=%i\n",glb.aes.desk.trame4);
	_outINI(txt);
	sprintf(txt,"Def_Trm=%i\n",glb.opt.d_trm);
	_outINI(txt);
	_outINI("\n");

	_outINI("[Print]\n");
	sprintf(txt,"Device=%i\n",glb.print.dev);
	_outINI(txt);
	sprintf(txt,"Max_Size=%i\n",glb.print.max);
	_outINI(txt);
	sprintf(txt,"Eject=%i\n",glb.print.out);
	_outINI(txt);
	sprintf(txt,"Xcenter=%i\n",glb.print.xcenter);
	_outINI(txt);
	sprintf(txt,"Ycenter=%i\n",glb.print.ycenter);
	_outINI(txt);
	_outINI("\n");

	_outINI("[Selectric_Path]\n");
	for (i=0;i<11;i++)
	{
		sprintf(txt,"%02i=%s\n",i,glb.opt.pat[i]);
		_outINI(txt);
	}
	_outINI("\n");

	_outINI("[Selectric_Ext]\n");
	for (i=0;i<11;i++)
	{
		sprintf(txt,"%02i=%s\n",i,glb.opt.ext[i]);
		_outINI(txt);
	}
	_outINI("\n");

	_outINI("[Slide]\n");
	sprintf(txt,"Path=%s\n",glb.opt.sl_path);
	_outINI(txt);
	sprintf(txt,"Name=%s\n",glb.opt.sl_name);
	_outINI(txt);
	sprintf(txt,"Pfname=%s\n",glb.opt.sl_pfname);
	_outINI(txt);
	sprintf(txt,"Pause=%i\n",glb.opt.sl_pause);
	_outINI(txt);
	sprintf(txt,"PTime=%i\n",glb.opt.sl_ptime);
	_outINI(txt);
	sprintf(txt,"TurboVeille=%i\n",glb.opt.sl_tv);
	_outINI(txt);
	sprintf(txt,"LedPanel=%i\n",glb.opt.sl_led);
	_outINI(txt);
	sprintf(txt,"Info=%i\n",glb.opt.sl_info);
	_outINI(txt);
	sprintf(txt,"Loop=%i\n",glb.opt.sl_loop);
	_outINI(txt);
	sprintf(txt,"Recursive=%i\n",glb.opt.sl_rec);
	_outINI(txt);
	sprintf(txt,"Zinc=%i\n",glb.opt.sl_zinc);
	_outINI(txt);
	sprintf(txt,"Zdec=%i\n",glb.opt.sl_zdec);
	_outINI(txt);
	_outINI("\n");

	_outINI("[Convert]\n");
	sprintf(txt,"Delete=%i\n",glb.opt.cnv_del);
	_outINI(txt);
	sprintf(txt,"Force=%i\n",glb.opt.cnv_col);
	_outINI(txt);
	sprintf(txt,"Src_Path=%s\n",glb.opt.cnv_path);
	_outINI(txt);
	sprintf(txt,"Src_Name=%s\n",glb.opt.cnv_name);
	_outINI(txt);
	sprintf(txt,"Src_Pfname=%s\n",glb.opt.cnv_pfname);
	_outINI(txt);
	sprintf(txt,"Dst_Path=%s\n",glb.opt.cnv_dst);
	_outINI(txt);
	_outINI("\n");

	_outINI("[Zoom]\n");
	sprintf(txt,"High_Quality=%i\n",glb.opt.zoom_hq);
	_outINI(txt);
	sprintf(txt,"Replace=%i\n",glb.opt.zoom_rep);
	_outINI(txt);
	_outINI("\n");

	for (i=0;i<glb.opt.Win_Num;i++)
		if (W[i].type==TW_FORM && W[i].handle>=0)
		{
			tree=glb.rsc.head.trindex[W[i].id];
			if (!(tree->ob_state&STATE9))
			{
				_outINI("[WinForm]\n");
				sprintf(txt,"Name=%s\n",W[i].name);
				_outINI(txt);
				sprintf(txt,"SName=%s\n",W[i].sname);
				_outINI(txt);
				sprintf(txt,"Gadget=%i\n",W[i].save_gadget);
				_outINI(txt);
				sprintf(txt,"X-Gadget=%i\n",W[i].save_xgadget);
				_outINI(txt);
				sprintf(txt,"Tree=%i\n",W[i].id);
				_outINI(txt);
				sprintf(txt,"Tree_Icon=%i\n",W[i].ic_tree);
				_outINI(txt);
				sprintf(txt,"Icon=%i\n",W[i].icon);
				_outINI(txt);
				sprintf(txt,"xwind=%i\n",(int)((float)W[i].xwork*(float)1000/(float)glb.aes.desk.w));
				_outINI(txt);
				sprintf(txt,"ywind=%i\n",(int)((float)W[i].ywork*(float)1000/(float)glb.aes.desk.h));
				_outINI(txt);
				sprintf(txt,"wwind=%i\n",(int)((float)W[i].wwork*(float)1000/(float)glb.aes.desk.w));
				_outINI(txt);
				sprintf(txt,"hwind=%i\n",(int)((float)W[i].hwork*(float)1000/(float)glb.aes.desk.h));
				_outINI(txt);
				sprintf(txt,"Small=%i\n",W[i].smallflag==1);
				_outINI(txt);
				_outINI("\n");
			}
		}

	ha=(int)Fcreate(glb.opt.INI_File,0);
	if (ha>=0)
	{
		Fwrite(ha,boff,(void *)badr);
		Fclose(ha);
	}
	_mSpecFree(badr);
	graf_mouse(ARROW,0);
}

static void _outINI(char *txt)
{
	char	*p;

	if (boff+2L*strlen(txt)<blen)
	{
		p=(char *)(badr+boff);
		while (*txt!=0)
		{
			if (*txt=='\n')
			{
				*p++='\r';
				*p++='\n';
				boff+=2L;
			}
			else
			{
				*p++=*txt;
				boff+=1L;
			}
			txt++;
		}
	}
}
