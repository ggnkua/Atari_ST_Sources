/*
	this code is used to arrange voices withing a voice bank and to
	also edit it as best as can be possibly done in a crude
	public domain editor
*/

#include <osbind.h>
#include <obdefs.h>
#include <gemdefs.h>
#include <string.h>
#include "dx.h"
#include "dxed.h"
#include <stdio.h>

char alert1[] = "[3][You must click | on voice to | replace first][OK]";

typedef struct {
	int flag;
	int object;
} ARFLG;

arrange(vw,buff,pbuff)
int vw;
char *buff,*pbuff;	/*	buffer bulk voice is in	*/
{
	/*
		this is the main part of the program that handles the
		voice arrangement
	*/
	OBJECT *box;
	int x,y,w,h,form_result,index,exit;
	ARFLG arrg[2];
	char in_file[128],temp_f[128],*tp;
	char vces[32][11];	/*	voice names	*/
	char t[11];
	extern char file_path[128];
	int fd;	/*	i/o file descriptor	*/

	rsrc_gaddr(R_TREE,ARRANGE,&box);
	get_names(buff,vces);	/*	get voice names from buffer	*/
	set_names(box,vces);	/*	put voice names in dialog box	*/
	form_center(box,&x,&y,&w,&h);
	form_dial(FMD_START,x,y,0,0,x,y,w,h);
	form_dial(FMD_GROW,x,y,0,0,x,y,w,h);
	objc_draw(box,0,2,x,y,w,h);
	index = 0;
	exit = 0;
	do
	{
		form_result = form_do(box,0);
		switch(form_result)
		{
			case AR_VN01:
			case AR_VN02:
			case AR_VN03:
			case AR_VN04:
			case AR_VN05:
			case AR_VN06:
			case AR_VN07:
			case AR_VN08:
			case AR_VN09:
			case AR_VN10:
			case AR_VN11:
			case AR_VN12:
			case AR_VN13:
			case AR_VN14:
			case AR_VN15:
			case AR_VN16:
			case AR_VN17:
			case AR_VN18:
			case AR_VN19:
			case AR_VN20:
			case AR_VN21:
			case AR_VN22:
			case AR_VN23:
			case AR_VN24:
			case AR_VN25:
			case AR_VN26:
			case AR_VN27:
			case AR_VN28:
			case AR_VN29:
			case AR_VN30:
			case AR_VN31:
			case AR_VN32:
				objc_change(box,form_result,0,x,y,w,h,SELECTED,1);
				arrg[index].object = form_result;
				arrg[index].flag = convert(form_result);
				++index;
				if(index == 2)
				{
					index = 0;	/*	reset index back to zero	*/
					swap_bulk(arrg[0].flag,arrg[1].flag,buff,pbuff);
					strcpy(t,vces[arrg[0].flag]);
					strcpy(vces[arrg[0].flag],vces[arrg[1].flag]);
					strcpy(vces[arrg[1].flag],t);
					objc_draw(box,ARR_VBOX,2,x,y,w,h);
					objc_change(box,arrg[0].object,0,x,y,w,h,NORMAL,1);
					objc_change(box,arrg[1].object,0,x,y,w,h,NORMAL,1);
				}
				break;
			case AR_SAVE:
				if(get_file(temp_f) != 0)
				{
					join_fname(in_file,file_path,temp_f);
					if((fd = Fcreate(in_file,0)) < 0)
					{
						form_alert(1,"[3][Cannot open file][OK]");
					}
					else
					{
						Fwrite(fd,4096L,buff);
						Fclose(fd);
						tp = (char *)rindex(in_file,'.');
						*tp = '\0';
						strcat(in_file,".per");
						fd = Fcreate(in_file,0);
						Fwrite(fd,4096L,pbuff);
						Fclose(fd);
					}
				}
				objc_change(box,AR_SAVE,0,x,y,w,h,NORMAL,1);
				objc_draw(box,0,2,x,y,w,h);	/*	redrwaw our box	*/
				break;
			case AR_LDVCE:
				if (index == 0)
				{
					form_alert(1,alert1);
				}
				else
				{
					get_vce(arrg[0].flag,buff,pbuff,vw);
					get_names(buff,vces);	/*	get voice names from buffer	*/
					set_names(box,vces);	/*	put voice names in dialog box	*/
					objc_change(box,arrg[0].object,0,x,y,w,h,NORMAL,1);
					index = 0;
				}
				objc_change(box,AR_LDVCE,0,x,y,w,h,NORMAL,1);
				objc_draw(box,0,2,x,y,w,h);	/*	redrwaw our box	*/
				break;
			case AR_LDBNK:
				if(get_file(temp_f) != 0)
				{
					join_fname(in_file,file_path,temp_f);
					if((fd = Fopen(in_file,0)) < 0)
					{
						form_alert(1,"[3][Cannot open file][OK]");
					}
					else
					{
						Fread(fd,4096L,buff);
						Fclose(fd);
						tp = (char *)rindex(in_file,'.');
						*tp = '\0';
						strcat(in_file,".per");
						if((fd = Fopen(in_file,0)) > 0)
						{
							Fread(fd,4096L,pbuff);
							Fclose(fd);
						}
						get_names(buff,vces);	/*	get voice names from buffer	*/
						set_names(box,vces);	/*	put voice names in dialog box	*/
					}
				}
				objc_change(box,AR_LDBNK,0,x,y,w,h,NORMAL,1);
				objc_draw(box,0,2,x,y,w,h);	/*	redrwaw our box	*/
				break;
			case AR_EXIT:
				objc_change(box,AR_EXIT,0,x,y,w,h,NORMAL,1);
				exit = 1;
				break;
		}
	}while(!exit);
	form_dial(FMD_SHRINK,x,y,0,0,x,y,w,h);
	form_dial(FMD_FINISH,x,y,0,0,x,y,w,h);
}

get_vce(i,bulk_buff,p_bulk,vw)
int i;	/*	index into bulk buffer	*/
char bulk_buff[],p_bulk[];	/*	bulk buffer	*/
int vw;
{
	extern char file_path[128];
	char in_file[128],temp_f[128];
	int fd;	/*	input file descriptor	*/
	int index;
	char *buff,*ptr,*ptr1,*pbuff;
	long d,e;
	register int j;

	if(get_file(temp_f) == 0)
		return;
	join_fname(in_file,file_path,temp_f);
	if((fd = Fopen(in_file,0)) < 0)
	{
		form_alert(1,"[3][Cannot open file][OK]");
		return(0);
	}
	if(((d=Malloc(4096l)) == -1) || ((e=Malloc(4096l)) == -1))
	{
		form_alert(1,"[3][Memory alloc error][OK]");
		return;
	}
	buff = (char *)(d);
	pbuff = (char *)(e);
	Fread(fd,4096L,buff);
	Fclose(fd);
	if((ptr = rindex(in_file,'.')) == NULL)
	{
		sprintf(temp_f,"[1][File Name|%s][OK]",in_file);
		form_alert(1,temp_f);
		strcat(in_file,".PER");		/*	performance file name	*/
	}
	else
	{
		*ptr = '\0';
		strcat(in_file,".PER");		/*	performance file name	*/
	}
	if((fd = Fopen(in_file,0)) > 0)
	{
		Fread(fd,4096L,pbuff);
		Fclose(fd);
	}
	index = voice_sel(in_file,buff,vw);
	ptr = &buff[index * 128];	/*	get pointer to voice	*/
	ptr1 = &bulk_buff[i * 128];
	for(j=0;j<128;++j)
		ptr1[j] = ptr[j];
	ptr = &pbuff[index * 64];
	ptr1 = &p_bulk[i * 64];
	for(j=0;j<64;++j)
		ptr1[j] = ptr[j];
	Mfree(e);	/*	free up allocated ram	*/
	Mfree(d);
}

int reverse(val)
int val;
{
	/*
		takes val as an index into voice buffer and converts it 
		to an index into an object tree
	*/
	switch(val)
	{
		case 0: return(AR_VN01);
		case 1: return(AR_VN02);
		case 2: return(AR_VN03);
		case 3: return(AR_VN04);
		case 4: return(AR_VN05);
		case 5: return(AR_VN06);
		case 6: return(AR_VN07);
		case 7: return(AR_VN08);
		case 8: return(AR_VN09);
		case 9: return(AR_VN10);
		case 10: return(AR_VN11);
		case 11: return(AR_VN12);
		case 12: return(AR_VN13);
		case 13: return(AR_VN14);
		case 14: return(AR_VN15);
		case 15: return(AR_VN16);
		case 16: return(AR_VN17);
		case 17: return(AR_VN18);
		case 18: return(AR_VN19);
		case 19: return(AR_VN20);
		case 20: return(AR_VN21);
		case 21: return(AR_VN22);
		case 22: return(AR_VN23);
		case 23: return(AR_VN24);
		case 24: return(AR_VN25);
		case 25: return(AR_VN26);
		case 26: return(AR_VN27);
		case 27: return(AR_VN28);
		case 28: return(AR_VN29);
		case 29: return(AR_VN30);
		case 30: return(AR_VN31);
		case 31: return(AR_VN32);
	}
	return(0);
}

int convert(val)
int val;
{
	switch(val)
	{
		case AR_VN01:
			return(0);
		case AR_VN02:
			return(1);
		case AR_VN03:
			return(2);
		case AR_VN04:
			return(3);
		case AR_VN05:
			return(4);
		case AR_VN06:
			return(5);
		case AR_VN07:
			return(6);
		case AR_VN08:
			return(7);
		case AR_VN09:
			return(8);
		case AR_VN10:
			return(9);
		case AR_VN11:
			return(10);
		case AR_VN12:
			return(11);
		case AR_VN13:
			return(12);
		case AR_VN14:
			return(13);
		case AR_VN15:
			return(14);
		case AR_VN16:
			return(15);
		case AR_VN17:
			return(16);
		case AR_VN18:
			return(17);
		case AR_VN19:
			return(18);
		case AR_VN20:
			return(19);
		case AR_VN21:
			return(20);
		case AR_VN22:
			return(21);
		case AR_VN23:
			return(22);
		case AR_VN24:
			return(23);
		case AR_VN25:
			return(24);
		case AR_VN26:
			return(25);
		case AR_VN27:
			return(26);
		case AR_VN28:
			return(27);
		case AR_VN29:
			return(28);
		case AR_VN30:
			return(29);
		case AR_VN31:
			return(30);
		case AR_VN32:
			return(31);
	}
	return(0);
}

set_names(box,names)
OBJECT *box;
char names[32][11];
{
	int i,j;

	for(i=0;i<32;++i)
	{
		j = reverse(i);
		box[j].ob_spec = names[i];
	}
}

