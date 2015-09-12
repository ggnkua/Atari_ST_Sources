
/* Basic -> 'C' šbersetzung */

#include <b_nach_c.h>

/* Globale Variablen */

int CHAR;

void	p_rubber(void);
void	p_drag(void);
void	p_move(void);
void	p_grow_shrink(void);
unsigned char	wahl_byte;
long	b_long;
long	h_long;
long	i_long;
long	j_long;
long	lx_long;
long	ly_long;
long	mk_long;
long	mx_long;
long	my_long;
long	r_long;
long	x1_long;
long	y1_long;
long	r_long;

void	main()
	{
	r_ein(1);
	CHAR = C_HAR;

	/*  ** Grafik-Bibliothek */
	/*  */
	do
		{
		printf("\33E");
		printf("%cp", *chr(27));
		printf("|  <F1> rubber  |  <F2> drag  |  <F3> move  |  <F4> grow_shrink  |  <F10> quit |\n");
		print_at(1,2);
		printf("%cqF1 und F2 werden durch Rechtsclick abgebrochen\n",*chr(27));
		wahl_byte=inp(2);
		/*  */
		switch(wahl_byte)
			{
			case 187:	/*  F1 */
				p_rubber();
				break;
			case 188:	/*  F2 */
				p_drag();
				break;
			case 189:	/*  F3 */
				p_move();
				break;
			case 190:	/*  F4 */
				p_grow_shrink();
			}
		/*  */
		printf("%cq", *chr(27));
		/*  */
		}
	while(!(wahl_byte==196));	/*  quit mit F10 */
	/*  */
	/*  */
	r_aus(0);
	}

void p_rubber(void)
	{
	g_raphmode( 3);
	deffill( 1,2,4);
	do
		{
		mouse( mx_long,my_long,mk_long);
		if(mk_long &  1)
			{
			x1_long=mx_long;
			y1_long=my_long;
			DUMMY = graf_rubberbox(x1_long,y1_long,16,16,lx_long,ly_long);
			pbox( x1_long,y1_long,x1_long+lx_long,y1_long+ly_long);
			}
		}
	while(!(mk_long &  2));
	}
/*  */

void p_drag(void)
	{
	g_raphmode( 1);
	deffill( 1,2,4);
	do
		{
		mouse( mx_long,my_long,mk_long);
		box( 40,40,440,340);
		if(mk_long &  1)
			{
			DUMMY = graf_dragbox(150,100,mx_long,my_long,40,40,400,300,lx_long,ly_long);
			pbox( lx_long,ly_long,lx_long+150,ly_long+100);
			}
		}
	while(!(mk_long &  2));
	}
/*  */

void p_move(void)
	{
	g_raphmode( 1);
	deffill( 1,2,4);
	b_long=100;
	h_long=100;
	for(i_long=0;i_long<=639-b_long ;i_long+= b_long)
		{
		for(j_long=0;j_long<=399-h_long ;j_long+= h_long)
			{
			DUMMY = graf_movebox(b_long,h_long,i_long,j_long,639-i_long,399-j_long);
			}
		}
	}
/*  */

void p_grow_shrink(void)
	{
	g_raphmode( 1);
	DUMMY = graf_growbox(319,199,16,16,0,0,639,399);
	a_lert( 0,"Das war graf_growbox !",1,"Weiter",r_long);
	DUMMY = graf_shrinkbox(319,199,16,16,0,0,639,399);
	a_lert( 0,"Das war graf_shrinkbox !",1,"Weiter",r_long);
	}
/*  */
/*  fr dragbox und rubberbox sollte die Mausposition ber das GEM-AES */
/*  abgefragt werden, also evnt_button oder on menu button, dann */
/*  gibt es am Anfang nicht diese Flimmereffekte (siehe Handbuch, 11-50) */
