#include <ec_gem.h>

int		f_input(char *spruch, char *path, char *name);
void	do_rsc(int fh, char *path);
void	dscmake(void);

void main(void)
{
	e_start_as(PRG, "DSC-Maker");
	if(ap_type == PRG)
		dscmake();
	e_quit();
}

void dscmake(void)
{
	char path[256],path2[256],name[32];
	long	fhl;
	
	strcpy(path,"X:");
	Dgetpath(&(path[2]), 0);
	path[0]=(char)(Dgetdrv()+65);
	strcat(path, "\\*.*");
	strcpy(path2, path);
	name[0]=0;
	
	if(f_input("RSC ausw„hlen", path, name))
	{
		name[0]=0;
		if(f_input("Ziel ausw„hlen", path2, name))
		{
			fhl=Fcreate(path2, 0);
			if(fhl >= 0)
			{
				do_rsc((int)fhl, path);
				Fclose((int)fhl);
			}
			else
				form_alert(1,"[3][Fehler beim Anlegen der Datei!][Abbruch]");
		}
	}
}

void do_rsc(int fh, char *path)
{
	OBJECT *tree;
	int			x, y, w, h, mx,my,k,dum, ob;
	char		name[17];
	
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

	if(ob < 1) return;
	if(tree[ob].ob_type != G_CICON) return;
	
	/* Icondaten schreiben */
	tree[ob].ob_spec.iconblk->ib_wtext=0;
	Fwrite(fh, sizeof(CICONBLK), (CICONBLK*)tree[ob].ob_spec.iconblk);
	Fwrite(fh, 4*32,((CICONBLK*)tree[ob].ob_spec.iconblk)->monoblk.ib_pmask);
	Fwrite(fh, 4*32,((CICONBLK*)tree[ob].ob_spec.iconblk)->monoblk.ib_pdata);
	/* 2 Nullbytes als String */
	x=0;
	Fwrite(fh, 2, &x);

	Fwrite(fh, sizeof(CICON), ((CICONBLK*)tree[ob].ob_spec.iconblk)->mainlist);
	Fwrite(fh, 16*32,((CICONBLK*)tree[ob].ob_spec.iconblk)->mainlist->col_data);
	Fwrite(fh, 4*32,((CICONBLK*)tree[ob].ob_spec.iconblk)->mainlist->col_mask);

	Fwrite(fh, sizeof(CICON), ((CICONBLK*)tree[ob].ob_spec.iconblk)->mainlist->next_res);
	Fwrite(fh, 4*32,((CICONBLK*)tree[ob].ob_spec.iconblk)->mainlist->next_res->col_data);
	Fwrite(fh, 4*32,((CICONBLK*)tree[ob].ob_spec.iconblk)->mainlist->next_res->col_mask);
		
	/* Name eingeben */
	rsrc_load("DSCMAKER.RSC");
	rsrc_gaddr(0,0,&tree);
	strcpy(name, " ");
	tree[3].ob_spec.tedinfo->te_ptext=&(name[1]);
	
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
	if(k==2) return; /* Abbruch */
	
	/* Schreiben */
	Fwrite(fh, 17, name);

	form_alert(1,"[1][Fertig!][OK]");
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
