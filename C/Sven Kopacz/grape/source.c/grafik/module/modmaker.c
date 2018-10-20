#include <ec_gem.h>
#include <moddef.h>

int		f_input(char *spruch, char *path, char *name);
int		do_rsc(char *path, MODULEBLK *mblock);
void	modmake(void);
MODULEBLK *find_mod_magic(uchar *mem, long len);

void main(void)
{
	e_start_as(PRG, "Module-Maker");
	if(ap_type == PRG)
		modmake();
	e_quit();
}

void modmake(void)
{
	char path[256],path2[256],name[32];
	long	fhl, len;
	uchar	*base;
	MODULEBLK *mb;
		
	strcpy(path,"X:");
	Dgetpath(&(path[2]), 0);
	path[0]=(char)(Dgetdrv()+65);
	strcat(path, "\\*.*");
	strcpy(path2, path);
	name[0]=0;
	
	if(f_input("RSC ausw„hlen", path, name))
	{
		name[0]=0;
		if(f_input("Zielmodul ausw„hlen", path2, name))
		{
			fhl=Fopen(path2, FO_READ);
			if(fhl >= 0)
			{
				len=Fseek(0,(int)fhl, 2);
				Fseek(0,(int)fhl, 0);
				base=malloc(len);
				if(!base)
				{
					form_alert(1,"[3][Kein Speicher!][Abbruch]");
					Fclose((int)fhl);
					return;
				}
				Fread((int)fhl, len, base);
				Fclose((int)fhl);
				mb=find_mod_magic(base, len);
				if(mb)
				{
					if(do_rsc(path, mb))
					{
						fhl=Fcreate(path2, 0);
						if(fhl > 0)
						{
							Fwrite((int)fhl, len, base);
							Fclose((int)fhl);
							form_alert(1,"[1][Fertig!][OK]");
						}
						else
							form_alert(1,"[3][Fehler beim Anlegen der Moduldatei!][Abbruch]");
					}
				}
				else
					form_alert(1,"[3][Das ist kein Modul][Abbruch]");
				free(base);
			}
			else
				form_alert(1,"[3][Fehler beim ™ffnen der Moduldatei!][Abbruch]");
		}
	}
}

int do_rsc(char *path, MODULEBLK *mb)
{
	OBJECT *tree;
	int			x, y, w, h, mx,my,k,dum, ob, a;
	
	rsrc_load(path);
	rsrc_gaddr(0,0,&tree);
	
	wind_update(BEG_UPDATE);
	wind_update(BEG_MCTRL);
	form_center(tree, &x, &y, &w, &h);
	form_dial(FMD_START, x,y,w,h,x,y,w,h);
	
	objc_draw(tree,0,8,x,y,w,h);
	k=0;
	
	while(!(k&3))
		graf_mkstate(&mx,&my,&k,&dum);
	ob=objc_find(tree,0,8,mx,my);
	form_dial(FMD_FINISH, x,y,w,h,x,y,w,h);
	wind_update(END_MCTRL);
	wind_update(END_UPDATE);

	if((ob < 1) ||  (tree[ob].ob_type != G_CICON))
	{ /* 2. Tree anbieten */
		rsrc_gaddr(0,1,&tree);
		
		wind_update(BEG_UPDATE);
		wind_update(BEG_MCTRL);
		form_center(tree, &x, &y, &w, &h);
		form_dial(FMD_START, x,y,w,h,x,y,w,h);
		
		objc_draw(tree,0,8,x,y,w,h);
		k=0;
		
		while(!(k&3))
			graf_mkstate(&mx,&my,&k,&dum);
		ob=objc_find(tree,0,8,mx,my);
		form_dial(FMD_FINISH, x,y,w,h,x,y,w,h);
		wind_update(END_MCTRL);
		wind_update(END_UPDATE);
	}
		
	if((ob < 1) ||  (tree[ob].ob_type != G_CICON))
		return(0);
	
	/* Icondaten schreiben */
	mb->_16x16=*((CICONBLK*)tree[ob].ob_spec.iconblk);
	for(a=0; a < 2*16; ++a)
		mb->mono_mask[a]=(((CICONBLK*)tree[ob].ob_spec.iconblk)->monoblk.ib_pmask)[a];
	for(a=0; a < 2*16; ++a)
		mb->mono_data[a]=(((CICONBLK*)tree[ob].ob_spec.iconblk)->monoblk.ib_pdata)[a];
	mb->mono_text[0]=mb->mono_text[1]=0;
	
	mb->cicon=*(((CICONBLK*)tree[ob].ob_spec.iconblk)->mainlist);
	for(a=0; a < 8*16; ++a)
		mb->col_data[a]=(((CICONBLK*)tree[ob].ob_spec.iconblk)->mainlist->col_data)[a];
	for(a=0; a < 2*16; ++a)
		mb->col_mask[a]=(((CICONBLK*)tree[ob].ob_spec.iconblk)->mainlist->col_mask)[a];

	/* Name eingeben */
	rsrc_load("MODMAKER.RSC");
	rsrc_gaddr(0,0,&tree);
	strcpy(mb->name, " ");
	tree[3].ob_spec.tedinfo->te_ptext=&(mb->name[1]);
	
	wind_update(BEG_UPDATE);
	wind_update(BEG_MCTRL);
	form_center(tree, &x, &y, &w, &h);
	form_dial(FMD_START, x,y,w,h,x,y,w,h);
	
	objc_draw(tree,0,8,x,y,w,h);
	k=form_do(tree, 3);
	
	form_dial(FMD_FINISH, x,y,w,h,x,y,w,h);
	wind_update(END_MCTRL);
	wind_update(END_UPDATE);

	rsrc_free();
	if(k==2) return(0); /* Abbruch */
	return(1);
}

int	f_input(char *spruch, char *path, char *name)
{
	/* ™ffnet Fileselector und schreibt den Zugriffspfad
		 des Auswahlergebnisses in path */
		 
	char	*backslash;
	int		gb0, button, back;
	long	dum;
	
	gb0=_GemParBlk.global[0];
	wind_update(BEG_UPDATE);
	if ((gb0 >= 0x0140) || find_cookie('FSEL', &dum))
		back=fsel_exinput(path, name, &button, spruch);
	else
		back=fsel_input(path, name, &button);		
	wind_update(END_UPDATE);
	
	if (back)
	{
		if (button)
		{
			if (path[strlen(path)-1] != '\\')
			{
				backslash=strrchr(path, '\\');
				*(++backslash)=0;
			}
			
			strcat(path, name);
		}
		else
			back=0;
	}
	
	return(back);
}

MODULEBLK *find_mod_magic(uchar *mem, long len)
{
	do
	{
		if(*mem=='G')
		{
			if(!strncmp((char*)mem, "GRAPEMODULE", 11))
				return((MODULEBLK*)mem);
		}
		++mem;
		--len;
	}while(len);
	return(NULL);
}
