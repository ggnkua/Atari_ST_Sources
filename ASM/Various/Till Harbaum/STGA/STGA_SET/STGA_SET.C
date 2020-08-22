#include <aes.h>
#include <stddef.h>
#include <cpxdata.h>
#include <string.h>
#include <tos.h>
#include <ext.h>
#include <ctype.h>
#include "resource.h"
#include "resource.c"

CPXINFO *cdecl cpx_init(XCPB *Xcpb);
WORD     cdecl cpx_call(GRECT *rect);
int      modul_off, mode;

extern int detect_vga(void);
extern void reboot(void);

XCPB *xcpb;
CPXINFO cpxinfo = 
{
  cpx_call, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
};

char stga_lib[40]="a:\\auto\\stga_res.lib";
char stga_set[]="a:\\auto\\stga_mnu.inf";

const char empty[]="kein STGA-VDI installiert";
const char *popup[]={ "    VGA ","   Mono ","  Color ", };
const char *modes[]={ "VGA","Mono","Color","???" };
const char *pop2[]={ "  An ","  Aus " };
const char *on[]={ "An","Aus" };
const char *names[]={ "keine","VOFA","STGA" };
char  **vdi_modes;

int get_val(void) {
	int ret;
	long sp=Super(0l);
	if( *(long*)0x3fa != 0x12345678l ) 
		ret=-1;
	else
		ret=*(int*)0x3fe;
	Super((void*)sp);

	return ret;
}

void set_val(int val) {
	long sp=Super(0l);
	*(long*)0x3fa=0x12345678l; 
	*(int*)0x3fe=val;
	Super((void*)sp);
}
	
CPXINFO *cdecl cpx_init(XCPB *Xcpb)
{
	WORD i;
	long stack;

	xcpb=Xcpb;

	/* Bootvorgang? CPX sollerscheinen */
	if(xcpb->booting) return((CPXINFO*)1);
	
	/* LASTOB sollte wirklich letztes sein */
	if(!xcpb->SkipRshFix) {
		i=0; 
		do
			(*xcpb->rsh_obfix)(tree0_obj,i);
		while(!(tree0_obj[i++].ob_flags&LASTOB));
	}

	/* ist ueberhaupt ein Modul da? */
  	if( *(long*)0xfa0018 == 0x53544741 ) {  /* STGA */
  		i=*(int*)0xfa0026;    /* STGA-MOD-Version */
  		tree0_obj[VERSION].ob_spec.free_string[1]='0'+i/256;
  		tree0_obj[VERSION].ob_spec.free_string[3]='0'+i%256;
		tree0_obj[REBOOT].ob_state &= ~DISABLED;
		tree0_obj[MMODE].ob_state  &= ~DISABLED;
		tree0_obj[MON].ob_state    &= ~DISABLED;
  	} else {
  	  	strcpy(tree0_obj[VERSION].ob_spec.free_string,"???");
		tree0_obj[REBOOT].ob_state |= DISABLED;
		tree0_obj[MMODE].ob_state  |= DISABLED;
		tree0_obj[MON].ob_state    |= DISABLED;
	}

	/* Bibliotheken-Pfad vervollstaendigen */
   	stack=Super(0l);
   	stga_lib[0]=*((char*)0x446l)+'A';
   	if(stga_lib[0]=='A')
		stga_lib[0]=*((char*)0x447l)+'A';
   	Super((void*)stack);
	stga_set[0]=stga_lib[0];

	/* keine/STGA/VOFA testen */
	tree0_obj[CNAME].ob_spec.free_string = names[detect_vga()];

	/* magic auswerten */
	if(get_val()<0) {  /* kein Magic */
		mode=0;        /* VGA */
		modul_off=0;   /* An */
		set_val(0);
	} else {
		if((mode=get_val()&3)>2) mode=0;
		modul_off=(get_val()&4)?1:0;
	}

	tree0_obj[MMODE].ob_spec.tedinfo->te_ptext=modes[mode];
	tree0_obj[MON].ob_spec.tedinfo->te_ptext=on[modul_off];

	return &cpxinfo;
}

WORD cdecl cpx_call(GRECT *rect)
{
	WORD msg[8],obj,i,anz;
	GRECT obi;
	int  fhandle,vmode=0,von=0;
	long flen;
	char chr;
	
	tree0_obj[ROOT].ob_x=rect->g_x;
	tree0_obj[ROOT].ob_y=rect->g_y;
	
	/* aktuellen Modus lesen */
	if((fhandle=Fopen(stga_set,FO_READ))<0) {
		tree0_obj[VON].ob_state   |= DISABLED;
		tree0_obj[VMODE].ob_state |= DISABLED;		
		tree0_obj[VMODE].ob_spec.free_string = empty;				
		flen=0;
	} else {
		/* von lesen */
		do {
			Fread(fhandle,1,&chr);
			if(isdigit(chr)) {
				von*=10;
				von+=(chr-'0');
			}
		} while(isdigit(chr));
		von=!von;
	
		/* vmode lesen */
		do {
			Fread(fhandle,1,&chr);
			if(isdigit(chr)) {
				vmode*=10;
				vmode+=(chr-'0');
			}
		} while(isdigit(chr));
		
		/* Bibliothekenname lesen */
		flen=Fread(fhandle,sizeof(stga_lib)-3,&stga_lib[3]);
		stga_lib[3+flen]=0;
		Fclose(fhandle);

		/* Bibliotheken laden */
		fhandle=Fopen(stga_lib,FO_READ);
		if(fhandle<0) {
			tree0_obj[VON].ob_state   |= DISABLED;
			tree0_obj[VMODE].ob_state |= DISABLED;		
			tree0_obj[VMODE].ob_spec.free_string = empty;
			flen=0;
		} else {
			flen=Fseek(0,fhandle,2);
			anz=(flen-76)/72;
			vdi_modes=Malloc(sizeof(char*)*anz);
			Fseek(76,fhandle,0);
			for(i=0;i<anz;i++) {
				vdi_modes[i]=Malloc(27);
				Fread(fhandle,24,&vdi_modes[i][2]);
				vdi_modes[i][0]=vdi_modes[i][1]=' ';
				vdi_modes[i][26]=0;
				Fseek(72-24,fhandle,1);
			}
			Fclose(fhandle);
			tree0_obj[VMODE].ob_spec.free_string = &vdi_modes[vmode][2];
			tree0_obj[VON].ob_spec.tedinfo->te_ptext=on[von];
		}
	}

	objc_draw(tree0_obj, ROOT, MAX_DEPTH, 
		rect->g_x, rect->g_y, rect->g_w, rect->g_h);
		
	do {
		obj=(*xcpb->Xform_do)(tree0_obj,0,msg);
		switch(obj) {
			case -1:
				if(msg[0]==AC_CLOSE)  obj=ABBRUCH;
				if(msg[0]==WM_CLOSED) obj=OK;
				break;
		
			case MMODE: 
				if(!(tree0_obj[MMODE].ob_state&DISABLED)) {
					objc_offset(tree0_obj,MMODE,&obi.g_x,&obi.g_y);
					obi.g_w=tree0_obj[MMODE].ob_width;
					obi.g_h=tree0_obj[MMODE].ob_height;
					if((i=(*xcpb->Popup)(popup,3,mode,3,&obi,&tree0_obj[ROOT].ob_x))>=0) {
						tree0_obj[MMODE].ob_spec.tedinfo->te_ptext=modes[i];
						objc_draw(tree0_obj, MMODE, MAX_DEPTH, 
								rect->g_x, rect->g_y, rect->g_w, rect->g_h);
						mode=i;
					}
				}
				break;
				
			case MON: 
				if(!(tree0_obj[MON].ob_state&DISABLED)) {
					objc_offset(tree0_obj,MON,&obi.g_x,&obi.g_y);
					obi.g_w=tree0_obj[MON].ob_width;
					obi.g_h=tree0_obj[MON].ob_height;
					if((i=(*xcpb->Popup)(pop2,2,modul_off,3,&obi,&tree0_obj[ROOT].ob_x))>=0) {
						tree0_obj[MON].ob_spec.tedinfo->te_ptext=on[i];
						objc_draw(tree0_obj, MON, MAX_DEPTH, 
								rect->g_x, rect->g_y, rect->g_w, rect->g_h);
						modul_off=i;
					}
				}
				break;

			case VMODE: 
				if(!(tree0_obj[VMODE].ob_state&DISABLED)) {
					objc_offset(tree0_obj,VMODE,&obi.g_x,&obi.g_y);
					obi.g_w=tree0_obj[VMODE].ob_width;
					obi.g_h=tree0_obj[VMODE].ob_height;
					if((i=(*xcpb->Popup)(vdi_modes,anz,vmode,3,&obi,&tree0_obj[ROOT].ob_x))>=0) {
						tree0_obj[VMODE].ob_spec.free_string=&vdi_modes[i][2];
						objc_draw(tree0_obj, VMODE, MAX_DEPTH, 
								rect->g_x, rect->g_y, rect->g_w, rect->g_h);
						vmode=i;
					}
				}
				break;

			case VON: 
				if(!(tree0_obj[VON].ob_state&DISABLED)) {
					objc_offset(tree0_obj,VON,&obi.g_x,&obi.g_y);
					obi.g_w=tree0_obj[VON].ob_width;
					obi.g_h=tree0_obj[VON].ob_height;
					if((i=(*xcpb->Popup)(pop2,2,von,3,&obi,&tree0_obj[ROOT].ob_x))>=0) {
						tree0_obj[VON].ob_spec.tedinfo->te_ptext=on[i];
						objc_draw(tree0_obj, VON, MAX_DEPTH, 
								rect->g_x, rect->g_y, rect->g_w, rect->g_h);
						von=i;
					}
				}
				break;

			case OK:
			case REBOOT:
				/* Modul konfigurieren */
			  	if( *(long*)0xfa0018 == 0x53544741 ) {  /* STGA */
					if(modul_off)
						set_val(mode|4);
					else
						set_val(mode);
				}

				/* VDI konfigurieren */
				if((fhandle=Fopen(stga_set,FO_WRITE))<0) {
					(*xcpb->XGen_Alert)(FILE_ERR);
				} else {
					chr=(von)?'0':'1';
					Fwrite(fhandle,1,&chr);
					Fwrite(fhandle,1,",");
					if(vmode>=10) {
						chr=(vmode/10)+'0';
						Fwrite(fhandle,1,&chr);
					}
					chr=(vmode%10)+'0';
					Fwrite(fhandle,1,&chr);
					Fwrite(fhandle,1,",");
					for(i=3;stga_lib[i];i)
						Fwrite(fhandle,1,&stga_lib[i++]);
				
					Fclose(fhandle);
					
					if(obj==REBOOT) {
						/* geben wir einem Cache ggf. eine Sekunde */
						sleep(1);
						/* und ab ... */
						reboot();
					}
				}
				break;
		}
	} while((obj!=OK)&&(obj!=ABBRUCH));
	
	/* Speicher freigeben */
	if(flen>0) {
		for(i=0;i<anz;i++)
			Mfree(vdi_modes[i]);
		Mfree(vdi_modes);
	}

	return 0;
}

