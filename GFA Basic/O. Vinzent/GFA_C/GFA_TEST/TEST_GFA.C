
/* Basic -> 'C' öbersetzung */

#include <b_nach_c.h>

/* Globale Variablen */

int CHAR;

double	*zeit_doub_f;
void	p_s_top(void);
void	p_intro(void);
void	p_schleifen(void);
void	p_benchmarks(void);
void	p_f_iles(void);
void	p_grafik(void);
long	back_long;
long	c_long;
long	d_adr_long;
long	h_long;
long	i_long;
long	j_long;
long	s_long;
long	s_adr_long;
long	z_long;
long	i_long;
double	a_doub;
double	c_doub;
char	achar[C_HAR];
char	*a_char;
char	bchar[C_HAR];
char	*b_char;
char	bildchar[32000];	/* manuell auf 32000 Byte erhîht */
char	*bild_char;
char	cchar[C_HAR];
char	*c_char;
char	dchar[C_HAR];
char	*d_char;
char	dateichar[C_HAR];
char	*datei_char;
char	echar[C_HAR];
char	*e_char;
char	fchar[C_HAR];
char	*f_char;
char	zchar[C_HAR];
char	*z_char;
char	bildchar[32000];	/* manuell auf 32000 Byte erhîht */
char	*bild_char;

void	main()
	{
	r_ein(1);
	CHAR = C_HAR;

	a_char = &achar[0];
	b_char = &bchar[0];
	bild_char = &bildchar[0];
	c_char = &cchar[0];
	d_char = &dchar[0];
	datei_char = &dateichar[0];
	e_char = &echar[0];
	f_char = &fchar[0];
	z_char = &zchar[0];
	bild_char = &bildchar[0];
	/*  */
	/*  DEMO-PROGRAMM : Wandlung von GFA-BASIC-Quelltext nach 'C' */
	/*  */
	/*  Aufbau: */
	/*  1. Stringbehandlung */
	/*  2. Schleifen */
	/*  3. Filehandling */
	/*  4. Grafik */
	/*  */
	/*  Ω-1989: O. VINZENT und PROF. DR. H.-J. PATT,   UniversitÑt des Saarlandes, */
	/*          Fachbereich Physik, Geb.8,  D-6600 SaarbrÅcken, Tel. 0681/302-3773 */
	/*          GFA-Systemtechnik GmbH, Heerdter Sandberg 30, D-4000 DÅsseldorf 11 */
	/*  */
	if((zeit_doub_f = (double *)calloc((size_t)(10+1),(size_t)sizeof(double ))) == 0L)
			f_ehler(0);
		else
			SPEICHER[SP++] = (char *)zeit_doub_f;
	msprintf(z_char," <<< Taste >>> ");
	chdrive( 0);
	p_intro();
	p_schleifen();
	p_benchmarks();
	p_f_iles();
	p_grafik();
	deftext( 1,17,0,32);
	text( 288,75,-1,"ENDE");
	text( 208,150,-1,"DEMO: B_NACH_C");
	pause( 100);
	printf("\33E");
	r_aus(0);
	}

void p_s_top(void)
	{
	s_long=2;
	z_long=0;
	do
		{
		if(even(s_long))
			{
			print_at(s_long-1,72);
			printf(" %s ",z_char);
			}
		else
			{
			print_at(s_long,72);
			printf("%cp%s%cq",*chr(27),z_char,*chr(27));
			}
		pause( 10);
		if(gemdos(11) != 0)
			{
			z_long=gemdos(1);
			}
		if(z_long==0)
			{
			++s_long;
			z_long=d_iv(s_long,65);
			}
		else if(z_long==1)
			{
			--s_long;
			if(s_long==2)
				{
				z_long=0;
				}
			}
		pause( 10);
		if(bios(1,2) != 0)
			{
			z_long=inp(2);
			}
		}
	while(!(z_long>1));
	}

void p_intro(void)
	{
	print_at(1,2);
	printf("\n");
	printf("              %cp<<< ES IST SOWEIT !!!  %c B_NACH_C %c IST DA !!! >>>%cq\n",*chr(27),*chr(42),*chr(42),*chr(27));
	print_at(8,5);
	printf("%cp<<< DAS TRANSFORMATIONSPROGRAMM 'GFA-BASIC-KONVERTER-NACH-C' >>>%cq\n",*chr(27),*chr(27));
	print_at(1,8);
	printf("\n");
	printf("  Mit Hilfe dieses Programms kînnen folgende Aufgaben optimal gelîst werden :\n");
	printf("\n");
	printf("  1. Entwicklung eines Programms im kompfortablen GFA-BASIC,\n");
	printf("  2. Austesten des Programms in einem Interpreter (Turn-Around-Zeit !),\n");
	printf("  3. Programmtransformation in die weltweit verbreitete Computersprache 'C',\n");
	printf("  4. Portierung auf unterschiedlichste Rechner und Betriebssysteme,\n");
	printf("  5. Programmierung auf einem ATARI und Anwendung auf einer UNIX-Workstation,\n");
	printf("  6. Mîgliche Steigerung der Geschwindigkeiten durch deren C-Compiler.\n");
	print_at(3,20);
	printf("Ω-1989: O. VINZENT und PROF. DR. H.-J. PATT,   UniversitÑt des Saarlandes,\n");
	print_at(11,21);
	printf("Fachbereich Physik, Geb.8,  D-6600 SaarbrÅcken, Tel. 0681/302-3773\n");
	print_at(11,22);
	printf("GFA-Systemtechnik GmbH, Heerdter Sandberg 30, D-4000 DÅsseldorf 11\n");
	p_s_top();
	printf("\33E");
	msprintf(a_char," DEMO-PROGRAMM FöR 'B_NACH_C.PRG' ");
	msprintf(b_char,"B_NACH_C WANDELT GFA-BASIC IM ASCII-FORMAT  IN EINEN C-QUELLTEXT");
	msprintf(c_char,"Ein GFA-BASIC-Listing wird nach 'C' gewandelt und ist ");
	msprintf(d_char,"sofort compilierbar !");
	msprintf(e_char,"%s%s",c_char,d_char);
	msprintf(f_char,"%s",right(a_char,16));
	print_at(24,2);
	printf("%cp%s%cq\n",*chr(27),a_char,*chr(27));
	print_at(9,4);
	printf("%s\n",b_char);
	print_at(3,6);
	printf("%s\n",e_char);
	print_at(33,8);
	printf("%cp%s%cq\n",*chr(27),f_char,*chr(27));
	print_at(26,10);
	printf("transformiert GFA-BASIC nach C\n");
	}

void p_schleifen(void)
	{
	print_at(2,12);
	printf("1. DEMO: Schleifen\n");
	print_at(1,14);
	printf("    FOR - NEXT\n");
	for(i_long=2;i_long<=79;i_long++)
		{
		print_at(i_long,15);
		printf("%c\n",*chr(41+i_long));
		}
	print_at(1,17);
	printf("    REPEAT - UNTIL\n");
	i_long=2;
	do
		{
		print_at(i_long,18);
		printf("%c\n",*chr(123-i_long));
		++i_long;
		}
	while(!(i_long==80));
	print_at(1,20);
	printf("    WHILE - WEND\n");
	i_long=2;
	while(i_long <= 79)
		{
		print_at(i_long,21);
		printf("%c\n",*chr(64+(fmod((i_long-1) ,26))));
		++i_long;
		}
	print_at(1,23);
	printf("    DO - LOOP\n");
	i_long=2;
	do
		{
		print_at(i_long,24);
		printf("%c",*chr(96+(fmod((i_long-1) ,26))));
		++i_long;
		if(i_long==80)
			goto M1;
		}
	while(1);
	M1:
	p_s_top();
	printf("\33E");
	}

void p_benchmarks(void)
	{
	print_at(2,2);
	printf("2. DEMO: Einige Benchmarks\n");
	print_at(2,4);
	printf("1. Integerberechnung:\n");
	print_at(5,6);
	printf("10000 Schleifen zur Erhîhung eines Integerwertes\n");
	i_long=0;
	print_at(5,7);
	printf("... rechne\n");
	c_doub=timer();
	while(i_long<10000)
		{
		++i_long;
		}
	zeit_doub_f[(int)(1)]=(timer()-c_doub)/200;
	print_at(5,8);
	printf("%ld Schleifen gerechnet 	und ... %G s benîtigt\n",i_long,zeit_doub_f[(int)(1)]);
	print_at(2,10);
	printf("2. Integer- und Floatberechnung:\n");
	print_at(5,12);
	printf("10000 Schleifen zur Erhîhung eines Integerwertes\n");
	print_at(5,13);
	printf("und Berechnung einer Floatvariablen\n");
	i_long=0;
	a_doub=0;
	print_at(5,14);
	printf("... rechne\n");
	c_doub=timer();
	while(i_long<10000)
		{
		++i_long;
		a_doub=a_doub+1;
		}
	zeit_doub_f[(int)(2)]=(timer()-c_doub)/200;
	print_at(5,16);
	printf("%ld Schleifen gerechnet 	und ... %G s benîtigt\n",i_long,zeit_doub_f[(int)(2)]);
	msprintf(datei_char,"A:\\GFA_TEST\\TEST.DAT");
	print_at(5,18);
	printf("Speichere die Ergebnisse in der Datei >>%s<< ab ...\n",datei_char);
	if((FP[1] = fopen(datei_char,"w")) == NULL)
		{
		printf("\nFehler beim ôffnen der Datei !");
		getchar();
		r_aus(-1);
		}
	for(i_long=0;i_long<=5;i_long++)
		{
		fprintf(FP[1],"%G\n",zeit_doub_f[(int)(i_long)]);
		}
	fclose(FP[1]);
	print_at(5,20);
	printf("Lade zur Kontrolle die Daten wieder aus der Datei >>%s<<\n",datei_char);
	if((FP[1] = fopen(datei_char,"r")) == NULL)
		{
		printf("\nFehler beim ôffnen der Datei !");
		getchar();
		r_aus(-1);
		}
	for(i_long=0;i_long<=5;i_long++)
		{
		fscanf(FP[1],"%lg",&zeit_doub_f[(int)(i_long)]);
		}
	fclose(FP[1]);
	print_at(5,22);
	printf("Benchmark fÅr die Integerberechnung                 : %G s\n",zeit_doub_f[(int)(1)]);
	print_at(5,23);
	printf("Benchmark fÅr die Integerberechnung/Floatberechnung : %G s\n",zeit_doub_f[(int)(2)]);
	p_s_top();
	printf("\33E");
	}

void p_f_iles(void)
	{
	print_at(2,2);
	printf("3. DEMO: Filehandling\n");
	print_at(2,4);
	printf("   Fileselectorbox, Alertbox, Auslesen eines Files, RELSEEK, SEEK, LOF, LOC ..\n");
	bild_char = sget(bild_char);
	chdrive(1);
	msprintf(a_char,"*.LST");
	msprintf(b_char,"A:\\GFA_TEST\\");
	chdir( b_char);
	fileselect(mstrcat( b_char,a_char),a_char,c_char);
	sput( bild_char);
	if(strcmp(c_char,""))
		{
		if((FP[1] = fopen(c_char,"r")) == NULL)
			{
			printf("\nFehler beim ôffnen der Datei !");
			getchar();
			r_aus(-1);
			}
		c_long=lof(FP[1]);
		msprintf(c_char,"%s",mid(c_char,rinstr(c_char,"\\")+1,-1));
		print_at(5,6);
		printf("LÑnge der Datei %c%s%c%s: %ld\n",*chr(34),c_char,*chr(34),space(15-strlen(c_char)),c_long);
		relseek(FP[1],10);
		print_at(5,7);
		printf("Suche Position                   : %ld\n",loc(FP[1]));
		relseek(FP[1],10);
		print_at(5,8);
		printf("Erhîhe den Filepointer um 10 Byte: %ld\n",loc(FP[1]));
		seek(FP[1],10);
		print_at(5,9);
		printf("Stelle den Pointer auf Position  : %ld\n",loc(FP[1]));
		print_at(5,11);
		printf("Auslesen und Anzeigen der Datei >>%s<< (Stop/Abbruch: Taste)\n",c_char);
		p_s_top();
		printf("\33E");
		do
			{
			printf("%c", *chr(fgetc(FP[1])));
			if(strcmp(inkey(),""))
				{
				a_lert( 2,"Abbruch",2,"JA|NEIN",back_long);
				if(back_long==1)
					{
					goto raus;
					}
				}
			if(feof(FP[1]))
				goto M2;
			}
		while(1);
		M2:
		raus:

		print_at(5,25);
		printf("Ausgelesen bis Position: %ld%s\n",loc(FP[1]),space(54-strlen(ltoab(loc(FP[1]),-1,-1))));
		fclose(FP[1]);
		}
	else
		{
		print_at(5,6);
		printf("Sie haben keine Datei ausgewÑhlt!\n");
		}
	p_s_top();
	printf("\33E");
	}

void p_grafik(void)
	{
	deftext( 1,24,0,32);
	text( 174,200,-1,"4. DEMO: GRAFIK");
	p_s_top();
	printf("\33E");
	deftext( -1,1,0,13);
	for(h_long=1;h_long<=2;h_long++)
		{
		for(j_long=4;j_long<=24 ;j_long+= 4)
			{
			for(i_long=0;i_long<=5;i_long++)
				{
				deftext( -1,pow(2,i_long),-1,-1);
				text( 320,50+i_long*(16+j_long*2),-1,"B_NACH_C");
				}
			pause( 10);
			printf("\33E");
			deftext( -1,-1,-1,j_long);
			}
		deftext( -1,-1,h_long*1800,-1);
		}
	deftext( -1,1,-1,13);
	for(h_long=1;h_long<=4;h_long++)
		{
		for(i_long=2;i_long<=3;i_long++)
			{
			for(j_long=0;j_long<=2;j_long++)
				{
				defline( h_long,i_long,j_long,j_long);
				draw(100+50*j_long,50+25*j_long , 539-50*j_long,50+25*j_long);
				box( 50+50*j_long,150,320-50*j_long,350);
				circle( 480,250,20+40*j_long);
				}
			pause( 10);
			printf("\33E");
			}
		}
	defline( 1,2,1,1);
	deffill( 1,1,1);
	for(i_long=2;i_long<=3;i_long++)
		{
		for(j_long=1;j_long<=20;j_long++)
			{
			deffill( 1,i_long,j_long);
			pbox( 16*j_long-16,10,655-16*j_long,190);
			pcircle( 160,299,105-5*j_long);
			pellipse( 480,299,5*j_long,105-5*j_long);
			}
		if(j_long>20 &  i_long==2)
			{
			bild_char = sget(bild_char);
			}
		}
	pause( 50);
	s_adr_long=(long)(bild_char);
	d_adr_long=xbios(2);
	for(i_long=1;i_long<=1000;i_long++)
		{
		rc_copy(s_adr_long,(int)((double)rand()*(10)/32767)*64,(int)((double)rand()*(10)/32767)*40,64,40 ,d_adr_long,(int)((double)rand()*(10)/32767)*64,(int)((double)rand()*(10)/32767)*40,	-1);
		}
	pause( 100);
	printf("\33E");
	sput( bild_char);
	deffill( 1,1,1);
	}
