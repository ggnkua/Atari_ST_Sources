/*	Programma om het ID nummer en/of naam van een GDOS font file te 
	veranderen.
						Door: Ernst Blok
								Schoolstraat 40
								3241Ct Middelharnis
	Public Domain.

	Er zijn nogal wat library functies gebruikt, vooral bij opstarten zal
	elke C programmeur zijn eigen functie hebben.
	Bij problemen, stuur een bericht naar mij via STer BBS 01880-40035.

	In deze versie 1.2 is t.o.v. 1.0 bijgekomen de mogelijkheid om een
	gesorteerde ascii-file met de namen van de fontfiles te maken.
	Deze is te gebruiken voor het aanmaken van een ASSYGN.SYS.
*/

#include <all.h>
#include <basic.h>

 main()
 {	static WORD medpal[] = {0x777,0x700,0x234,0x000};
	gem_init();
	if(!Getrez()) { Kleuren(); Wit_op_zwart(); }
	if(Getrez()==1) Setpalette(medpal);
	prog();
	Stop();
   }
/*****************/
 prog()     /* naam in verschillende functies */
 {	WORD end=FALSE,but;
	cls;
	do
	{	Show_mouse();
		but=form_alert(2,
		"[2][ Edit programma voor|     ID nummers en namen|          van GemDOS fonts.| Door Ernst Blok (PD!) V.1.2   ][LIJST|VERANDEREN|STOPPEN]");
		Hide_mouse();cls;
		switch(but)
		{	case 2:	fntedit();	break;
			case 1:	fntlist();	break;
			case 3:	end=TRUE;	break;
		}
	} while(!end);
 }

 fntedit()
 {	if(fntinfo())
		if(change())
			save_change();
 }

typedef struct fontidname {
   WORD   face_id;    /*  0 Font face identifier  1 == system font  */
   WORD   size;       /*  2 Font size in points                     */
   char   name[32];   /*  4 Face name                               */
 } FNTIDNAME;

FNTIDNAME fnt_id;
BYTE filename[64]="", path[64]="";

 fntinfo()
 {	register BYTE fpath[64],*backslash;
	register WORD ii=0;
	WORD button,file_id;
	if(!path[0])
	{	strcpy(path,"C:\\*.FNT");
		path[0]=Dgetdrv()+'A';
	}
/*printf("\033Efilename=%s\n",filename);Cnecin();cls;*/
	Show_mouse();
	fsel_input(path,filename,&button);

	strcpy(fpath,path);
	backslash=rindex(fpath,'\\');
	*(backslash+1)=0;
	strcat(fpath,filename);
	if(button)
	{	if((file_id=Fopen(fpath,0))>=0)
		{	if(Fread(file_id,36L,&fnt_id)<0)
				form_alert(1,"[3][ | Reading error!! ][Urgh]");
			Fclose(file_id);
		}
		else
		{	form_alert(1,"[3][ | Cannot open file!! ][Urgh]");
			Hide_mouse();
			return(FALSE);
		}
	}
	else
	{	cls; return(FALSE); }
	Hide_mouse();
	cls;
/*printf("path=%s\n,filename=%s\n\n",path,filename);*/
										/* CONTROLE */
	if(!(fnt_id.face_id>>8))
	{	form_alert(1,"[3][ | File is geen GDOS fnt file!!][OK]");
		return(FALSE);
	}
	do
	{	if(!isprint(fnt_id.name[ii]))
		{	form_alert(1,"[3][ |File is geen GDOS font file!!][OK]");
			return(FALSE);
		}
	} while(fnt_id.name[++ii]);

	printf("\n\n");
	printf("\t%s:\t ID = %d,\t Naam = %s.\n\n",
		filename,fnt_id.face_id>>8, fnt_id.name);
	return(TRUE);
 }

 change()
 {	BYTE c,inp$[64];
	WORD ander=FALSE;
	input$("\tNieuwe ID   (RETURN = geen verandering) : \033p ",inp$,3);
	printf(" \033q\n");
	if(*inp$) 
	{	fnt_id.face_id=atoi(inp$);
		fnt_id.face_id <<= 8;
/*printf("\n\t\tfnt_id.face_id>>8 = %d\n",fnt_id.face_id>>8);*/
		ander=TRUE;
	}
	input$("\tNieuwe naam (   ''   =  ''      ''    ) : \033p ",inp$,32);
	printf(" \033q\n");
	if(*inp$)
	{	strcpy(fnt_id.name,inp$);
/*printf("\n\t\t%s\n", fnt_id.name);*/
		ander=TRUE;
	}
	return(ander);
 }

 save_change()
 {	register WORD file_id,button;
	register BYTE *backslash,fpath[64],c;
	Show_mouse();
	button=form_alert(1,"[3][ | Veranderingen wegschrijven??][JA|NEE]");
	Hide_mouse();
	if(button==2) return;

	strcpy(fpath,path);
	backslash=rindex(fpath,'\\');
	*(backslash+1)=0;
	strcat(fpath,filename);
	if((file_id=Fopen(fpath,0))>=0)
	{	if(Fwrite(file_id,36L,&fnt_id)<0)
			form_alert(1,"[3][ | Write error!! ][Urgh]");
		Fclose(file_id);
	}
	else	form_alert(1,"[3][ | Cannot open file!! ][Urgh]");
 }

#define MAXFNT 100
WORD printer=FALSE;
#define NAMELENGHT 13

 fntlist()
 {	register BYTE 	fnames[MAXFNT][NAMELENGHT], prnt$[80], c;
	register WORD ii,numfnt;
	WORD button=0;
	if(!path[0])
	{	strcpy(path,"C:\\*.FNT");
		path[0]=Dgetdrv()+'A';
	}
	Show_mouse();
	fsel_input(path,fnames[0],&button);
	Hide_mouse();cls;
	if(!button) return;

	if( !(numfnt=dir(fnames,MAXFNT)) ) return;

	qsort$(fnames,0,numfnt,8);

	Show_mouse();
	button=form_alert(2,
		"[2][Namen FNT-files  |  wegschrijven als| |  'FN_NAMES.ASC' ?][ja?|NEEN]");
	Hide_mouse();
	if(button==1) saveASCfnt(fnames);

	Show_mouse();
	button=form_alert(1,"[2][ | Uitvoer naar       ][ SCHERM | PRINTER ]");
	Hide_mouse();
	if(button==2)
	{	printer=TRUE;
		Printertest();
		Lprint("** Lijst van GDOS FNT files met ID en naam. **\n\n");
		sprintf(prnt$,"Path: %s\n\n",path);
		Lprint(prnt$);
		sprintf(prnt$,"   File,           ID,   Naam.\n\n");
		Lprint(prnt$);
	}

	printf("\033E   File,            ID,   Naam.\n\n");
	while(*fnames[ii])
	{	info_out(fnames[ii++]);
		if(!(ii%21))
		{	printf("\033p More? \033q Return=stop\n");
			if((BYTE)Cnecin()==0xD && !printer) break;
			printf("\033E   File,            ID,   Naam.\n\n");
		}
	}
	if(printer)
	{	sprintf(prnt$,"\n\t%d fontfiles.\014",ii);	/*+formfeed*/
		Lprint(prnt$);
	}
	printf("      %d fontfiles\n\033p    Nomore!   \033q\n",ii);
	printer=FALSE;
	Cnecin();cls;
 }

 info_out(finames)
 register BYTE finames[];
 {	BYTE fpath[64],*backslash,fntinfo$[255];
	WORD file_id;
	strcpy(fpath,path);
	backslash=rindex(fpath,'\\');
	*(backslash+1)=0;
	strcat(fpath,finames);
	if((file_id=Fopen(fpath,0))>=0)
	{	if(Fread(file_id,36L,&fnt_id)<0)
			form_alert(1,"[3][ | Reading error!! ][Urgh]");
		Fclose(file_id);
	}
	else
	{	form_alert(1,"[3][ | Cannot open file!! ][Urgh]");
		Hide_mouse();
		return(FALSE);
	}
	sprintf(fntinfo$,
		" %13s,   %3d,   %s\n",
			finames,fnt_id.face_id>>8,fnt_id.name);
	if(printer) Lprint(fntinfo$);
	printf(" %s",fntinfo$);
 }

typedef struct f_attr
 {	BYTE 	f_syst[21];
	BYTE 	f_attr;
	UWORD f_time;
	UWORD f_date;
	LONG 	f_size;
	BYTE	f_name[13];
 } DTA;

 dir(finames,maxnum)
 register BYTE finames[][NAMELENGHT];
 register WORD maxnum;
 {	DTA dtabuf;
	LONG savedta;
	register WORD ii=0,button;
	savedta=Fgetdta();
	Fsetdta(&dtabuf);
	if(Fsfirst(path,0))
	{	Show_mouse();
		form_alert(1,"[3][ |No *.FNT files found!][ Huh? ]");
		Hide_mouse();
		return(FALSE);
	}
	do
	{	strcpy(finames[ii++],dtabuf.f_name);
	} while(!Fsnext() && ii<maxnum);
	if(ii>=maxnum-1)
		form_alert(1,
		"[3][ There are more then | |        100 FNT-files.][Tooo much]");
	*finames[ii]=0;
	Fsetdta((BYTE*)savedta);
	return(ii-1);
 }

 saveASCfnt(finames)
 register BYTE finames[][NAMELENGHT];
 {	register WORD file_id,ii=0;
	register BYTE *backslash,fpath[64],Ret[4];
	strcpy(fpath,path);
	backslash=rindex(fpath,'\\');
	*(backslash+1)=0;
	strcat(fpath,"FN_NAMES.ASC");

	Ret[0]=0xD, Ret[1]=0xA,	/* return + linefeed */
	Ret[3]=0x0;

	if((file_id=Fcreate(fpath,0))>=0)
	{	while(*finames[ii])
		{	if(Fwrite(file_id,12L,finames[ii++])<=0L)
			{	form_alert(1,"[3][ | Write error!!!|  (finames)][Urgh]");
				break;
			}
			if(Fwrite(file_id,2L,Ret)<=0L)
			{	form_alert(1,"[3][ | Write error!!!| (Ret)][Urgh]");
				break;
			}
		}
		Fclose(file_id);
	}
	else	form_alert(1,"[3][ | Cannot creat file!! ][Urgh]");
 }

 qsort$(fnames,start,end,depth)
 register BYTE fnames[][NAMELENGHT];
 WORD start,end,depth;
 {	register BYTE temp[NAMELENGHT],mid[NAMELENGHT];
	register WORD lo=start,hi=end;
	strcpy(mid,fnames[(lo+hi)/2]);
	gotoxy(1,1);
	printf("SORTING\n");
	do
	{	while(strncmp(fnames[lo],mid,depth)<0)	lo++;
		while(strncmp(fnames[hi],mid,depth)>0)	hi--;
/*
gotoxy(2,1);
printf("lo=%d, hi=%d\n",lo,hi);
*/
		if(lo>hi) break;
		strcpy(temp,fnames[lo]);
		strcpy(fnames[lo],fnames[hi]);
		strcpy(fnames[hi],temp);
	} while(++lo<=--hi);
	if(start<hi)qsort$(fnames,start,hi,depth);
	if(lo<end)	qsort$(fnames,lo,end,depth);
 }
