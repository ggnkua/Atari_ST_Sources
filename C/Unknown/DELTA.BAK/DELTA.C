#include <osbind.h>



extern long gemdos(),xbios();
#define printtext(a) Cconws(a)

long compress(savedata,page1,page2)
long savedata,page1,page2;
	{
	long dataend;
asm			{
			movea.l	savedata(A6),A0
			movea.l	page1(A6),A1
			movea.l	page2(A6),A2
			clr.w	D0
sd_0loop:	move.w	#158,D1
cmp_loop:	move.w	0(A2,D1.W),D2
			cmp.w	0(A1,D1.W),D2
			bne.s	not_equal
			subq.w	#2,D1
			bpl.s	cmp_loop
			bra.s	next_line
not_equal:	move.w	D0,D1
			mulu	#160,D1
			move.w	D1,(A0)+
			movea.l	A0,A3
			adda.l	#10,A0
			move.w	#8,D2
sd_1loop:	move.w	#15,D1
			clr.w	D3
sd_2loop:	cmpm.w	(A1)+,(A2)+
			beq.s	equal_word
			bset	D1,D3
			move.w	-2(A2),(A0)+
equal_word:	dbf		D1,sd_2loop
			move.w	D3,0(A3,D2.W)
			subq.w	#2,D2
			bpl.s	sd_1loop
			bra.s	next_2line
next_line:	adda.l	#160,A1
			adda.l	#160,A2
next_2line:	addq.w	#1,D0
			cmp.w	#200,D0
			blt.s	sd_0loop
			move.w	#0xffff,(A0)+
			move.l	A0,dataend(A6)
			}
	return(dataend);
	}


long transform(data,page)
long data,page;
	{
	long dataend;
	asm		{
			movea.l	data(A6),A0
			movea.l	page(A6),A1
load_delta:	move.w	(A0)+,D3
			bmi.s	ld_end
			move.l	A0,A2
			adda.l	#10,A0
			move.w	#8,D0
ld_1loop:	move.w	0(A2,D0.W),D1
			bne.s	change
			add.l	#32,D3
			bra.s	no_change
change:		move.w	#15,D2
ld_2loop:	btst	D2,D1
			beq.s	no_write
			move.w	(A0)+,0(A1,D3.W)
no_write:	addq.w	#2,D3
			dbf		D2,ld_2loop
no_change:	subq.w	#2,D0
			bpl.s	ld_1loop
			bra.s	load_delta
ld_end:		move.l	A0,dataend(A6)
			}
	return(dataend);
	}

int load_degas(name,pallete,page)
char *name;
int *pallete;
long page;
	{
	int handle;
	handle=(int) Fopen(name,0);
	if(handle>=0)
		{
		Fseek(2L,handle,0);
		Fread(handle,32L,pallete);
		Fread(handle,32000L,page);
		Fclose(handle);
		return(1);
		}
	else
		return(0);
	}

char dname[] = "BILDA.PI1";

copy_screen(quelle,ziel)
long *quelle,*ziel;
	{
	asm	{
		movea.l	quelle(A6),A0
		movea.l	ziel(A6),A1
		move.w	#7999,D0
cpy_lp:	move.l	(A0)+,(A1)+
		dbf		D0,cpy_lp
		}
	}

char animname[] = "ANIM_0.DLT";

make_animation()
	{
	long picbuf,screen,animbuf,bufptr,buflen;
	int pallete[16],i,handle,*intptr,bilder,namenr;
	screen=xbios(2);
	picbuf=Malloc(32000L);
	buflen=Malloc(-1L)-10000;	animbuf=Malloc(buflen);
	if((animbuf>0)&&(screen>0))
		{
		do	{
			printtext("\n\rZahl der Bilder (max. 26): \033e");
			bilder=getnum();
		} while((bilder<2)||(bilder>26));
		do	{
			printtext("\n\rWelche Animationsdatei (0-9): \033e");
			namenr=getnum();
		} while((namenr<0)||(namenr>9));
		animname[5]=0x30+namenr;
		printtext("\033f\n\r");
		bufptr=animbuf;
		printtext("Starte Komprimierung\n\r");
		intptr=(int *)bufptr;
		*intptr=bilder;
		bufptr+=2;
		load_degas("BILDA.PI1",bufptr,bufptr+32);
		Setscreen(-1L,-1L,0);
		Setpallete(bufptr);
		load_degas("BILDA.PI1",pallete,screen);
		bufptr+=32032;
		for(i=1;i<bilder;i++)
			{
			dname[4]=0x41+i;
			load_degas(dname,pallete,picbuf);
			bufptr=compress(bufptr,screen,picbuf);
			copy_screen(picbuf,screen);
			}
		handle=(int) Fcreate(animname,0);
		Fwrite(handle,bufptr-animbuf,animbuf);
		Fclose(handle);
		Mfree(picbuf);
		Mfree(animbuf);
		}
	else
		printtext("Nicht genug Speicher!\n\r");
		gemdos(7);
	}

play_animation()
	{
	long animbuf,screen,tmpptr,wait,pause,buflen;
	int key,handle,i,*intptr,bilder,namenr;
	screen=xbios(2);
	buflen=Malloc(-1L)-10000;	animbuf=Malloc(buflen);
	if(animbuf>0)
		{
		do	{
			printtext("\n\rWelche Animationsdatei (0-9): \033e");
			namenr=getnum();
		} while((namenr<0)||(namenr>9));
		animname[5]=0x30+namenr;
		do	{
			printtext("\n\rPausenwert (0 bis 10) : \033e");
			pause=(long) getnum();
			} while((pause<0)||(pause>10));
		printtext("\033f\n\r");
		pause*=5000;
		handle=(int) Fopen(animname,0);
		Fread(handle,buflen,animbuf);	Fclose(handle);
		intptr=(int *)animbuf;
		bilder=*intptr;
		Setscreen(-1L,-1L,0);
		Setpallete(animbuf+2);
		do
			{
			for(wait=0;wait<pause;wait++);
			xbios(37);
			copy_screen(animbuf+34,screen);
			tmpptr=animbuf+32034;
			for(i=1;i<bilder;i++)
				{
				for(wait=0;wait<pause;wait++);
				xbios(37);
				tmpptr=transform(tmpptr,screen);
				}
			key=Cconis();
			} while(key==0);
		Mfree(animbuf);
		}
	else
		printtext("Zu wenig Speicher\n\r");
		gemdos(7);
	}

main()
	{
	int input;
	int oldres;
	oldres=Getrez();
	if(oldres==2)
		{
		printtext("Programm arbeitet nur mit Farbmonitor\n\r");
		gemdos(7);
		gemdos(0);
		}
	asm	{	dc.w	0xa00a	}
	do
	{
	Setscreen(-1L,-1L,1);
	printtext("\n\r\033E");
	printtext("\n\rDelta-Compression-Demo");
	printtext("\n\rVon Frank Mathy fuer Happy-Computer, 9/87");
	printtext("\n\r\n\r1) Demo generieren");
	printtext("\n\r2) Demo abspielen");
	printtext("\n\r3) Beenden\033e");
	printtext("\n\r\n\r>");
	do
		{
		input=getnum();
		} while((input<1)||(input>3));
	printtext("\n\r\033f");
	if(input==1)
		make_animation();
	if(input==2)
		play_animation();
	}while(input!=3);
	asm	{	dc.w	0xa009	}
	Setscreen(-1L,-1L,oldres);
	}

int getnum()
	{
	char text[10];
	int wert;
	text[0]=2;
	text[1]=0;
	text[2]=0;
	Cconrs(text);
	if(text[1]>0)
		if((text[2]>=0x30)&&(text[2]<0x3a))
			wert=text[2]-0x30;
		else
			return(-1);
	if((text[1]>1)&&(text[3]>=0x30)&&(text[3]<0x3a))
		wert=10*wert+text[3]-0x30;
	return(wert);
	}