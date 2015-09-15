/* Demonstratieprogramma om GDOS font te laden en te gebruiken.
	Werkt alleen als GDOS met booten is geladen.

	Door:	Ernst Blok
			Schoolstraat 40
			3241CT Middelharnis
	
	Er zijn nogal wat library functies gebruikt, vooral bij opstarten zal
	elke C programmeur zijn eigen functie hebben.
	Bij problemen, stuur een bericht naar mij via STer BBS 01880-40035.
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
 {	register WORD but,end=FALSE;
	if(!test_gdos())
	{	Show_mouse();
		but=form_alert(1,
			"[2][ Dit prog. werkt alleen | als GDOS bij het booten | geladen is. |   Public Domain door E.Blok][SSHIT..&*@<>?!!!]");
		Hide_mouse();
		return;
	}
	do
	{	Show_mouse();
		but=form_alert(2,
			"[2][ Loading FoNTs,  | Using them | or dump them |       and stop][Load|Use|Dump]");
		Hide_mouse();cls;
		switch(but)
		{	case 1:	loadfnt();
						break;
			case 2:	usefnt();
						break;
			case 3:	vst_unload_fnt(handle,0); end=TRUE;
						break;
		}
	} while(!end);
 }
 #define MAXFNT 25
 WORD fntID[MAXFNT];
 BYTE fnt_name[MAXFNT][32];
 
 loadfnt()
 {	register WORD ii;
	printf("\n Vrij geheugen: %ldKb.\n\n",Malloc(-1L)/1024);
 	while(vst_load_fnts(handle,0));
	vq_extnd(handle,0,work_out);
	printf(" Aantal beschikbare karaktersets=%d\n\n\n",work_out[10]);
	for(ii=1;ii<=work_out[10];ii++)
	{	fntID[ii]=vqt_name(handle,ii,fnt_name[ii]);
		printf(" ID=%2d,  fnt_name[%d]=%s\n",fntID[ii],ii,fnt_name[ii]);
	}
	printf("\n Vrij geheugen: %ldKb.\n\n",Malloc(-1L)/1024);
	printf("\n\033p KEY \033q\n");
	Cnecin();
 }

 usefnt()
 {	register BYTE inp$[5],promt$[80];
	register WORD newfnt,ii,fntno,res;
	if((res=Getrez())!=2) res=1;
	cls;
	sprintf(promt$,"Welk font wil je gebruiken 1 t/m %d : ",work_out[10]);
	input$(promt$,inp$,2);
	fntno=atoi(inp$);
	newfnt=vst_font(handle,fntID[fntno]);
	NEWLINE;
	for(ii=4;ii<=32;ii++)
	{	vst_height(handle,ii,&gl_wkar,&gl_hkar,&gl_wbox,&gl_hbox);
		cls;
		printf(" Fntno.: %d\tID = %3d\tname: %s\n Character size is %d\n",
								fntno,newfnt,fnt_name[fntno],ii);
		Text(6-ii/(8*res),0,"ABCDEFGHIJKLMNOPQRSTUVWXYZ.<>{}[]1234567890");
		Text(7-ii/(8*res),0,"abcdefghijklmnopqrstuvwxyz.1234567890");
		gotoxy(23,1);
		printf(" \033p KEY \033q  Return = stop.\n");
		if((BYTE)Cnecin()==0xD) break;
	}
 }
