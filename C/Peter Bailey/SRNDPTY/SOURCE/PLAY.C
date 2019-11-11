/* ==================================================================== */
/*	Serendipity: Play a game					*/
/* ==================================================================== */

#include	<osbind.h>
#include	"globals.h"


play_game()
{
	static char m1[] = "YOU WIN! HOW INCREDIBLY DEPRESSING";
	static char m2[] = "I WIN! YA BOO SUCKS TO YOU!";
	static char m3[] = "IT'S A DRAW... BORING";

	int	done,points;

	clear_board();  points = goes = done = me = you = 0;

	mode_1(0);  mode_2(15);  timer = (panic?3000:15000);  draw_pieces();

	game_on = 1;

	loop {
		if (get_move()) points=win(0); else points=0;

		if (points) {
			if (game_type==1) {
				if (game_mode==1)
					{ say(m1); weep_n_wail(); }
				else
					{ say(m2); explosion();   }
				done=1; break;
			} else {
				you += points;
				}
			}

		if (quit_flag||done) break;
		if (goes>63) goto skip_it;

		generate();

		if (points=win(1)) {
			if (game_type==1) {
				if (game_mode==1)
					{ say(m2); explosion();   }
				else
					{ say(m1); weep_n_wail(); }
				done=1; break;
			} else {
				me += points;
				}
			}

		if (done) break;

		++goes;

skip_it:
		if (goes>63) {
			if (game_type==1 || me==you) {
				say(m3); clang_2();
			} else {
				if ((you<me) ^ (game_mode==1))
					{ say(m1); weep_n_wail(); }
				else
					{ say(m2); explosion();   }
				}
			break;
			}
		}

	clr_pieces();  quit_flag = panic = game_on = 0;

	mode_2(0);  mode_1(15);
}


/* -------------------------------------------------------------------- */
/*	Check the specified position					*/
/* -------------------------------------------------------------------- */

win(w)
{
	register char	*p,c;
	register int	a,b;

	c = *(p = &board[i_last][j_last]);  a = b = 0;

	if (p[-1] ==c & p[1] ==c) a=1;
	if (p[-12]==c & p[12]==c) a=1;
	if (p[-13]==c & p[13]==c) a=1;
	if (p[-11]==c & p[11]==c) a=1;

	if (p[-2] ==c & p[-1] ==c) { b++; mark(&p[-1],w);  }
	if (p[2]  ==c & p[1]  ==c) { b++; mark(&p[1],w);   }
	if (p[-24]==c & p[-12]==c) { b++; mark(&p[-12],w); }
	if (p[24] ==c & p[12] ==c) { b++; mark(&p[12],w);  }
	if (p[-26]==c & p[-13]==c) { b++; mark(&p[-13],w); }
	if (p[26] ==c & p[13] ==c) { b++; mark(&p[13],w);  }
	if (p[-22]==c & p[-11]==c) { b++; mark(&p[-11],w); }
	if (p[22] ==c & p[11] ==c) { b++; mark(&p[11],w);  }

	if (a) mark(p,w);

	if (a|b) {
		v_hide_c(handle);  squiggle();
		for (a=0; a<300; ++a) for (b=0; b<1000; ++b);
		v_show_c(handle,1);
		}

	return (a+b);
}


/* -------------------------------------------------------------------- */
/*	Mark a specified square with a winning piece			*/
/* -------------------------------------------------------------------- */

mark(p,w)
	char	*p;
	int	w;
{
	int	i,j;

	i=(int)(p-&board[0][0]);  j=i%12-2;  i=i/12-2;

	display(i,j,4+w);  *p=(w+4);
}


/* -------------------------------------------------------------------- */
/*	Get the human's move						*/
/* -------------------------------------------------------------------- */

get_move()
{
	int	row,col,piece,done;
	int	x,y;

	say("YOUR TURN");  piece=done=0;

	do {	if (!mouse(&x,&y)) return 0;

		switch (which(x,y)) {

		case -1: nowhere();  break;

		case 0:	 if (piece) {
				row=(y-BY)/15;  col=(x-BX)/16;
				if (!board[row+2][col+2]) {
					i_last=row+2;  j_last=col+2;
					board[i_last][j_last]=piece;
					display(row,col,piece);
					done=1;  ++goes;
				} else {
					say("THAT SQUARE'S OCCUPIED, PAL");
					clang_1();
				}
			 } else {
			 	say("YOU HAVEN'T PICKED A PIECE, STUPID");
			 	clang_1();
			 	}
			 break;

		case 1:	 row=(y-PY)/15;  col=(x-PX)/16;  piece=row+1;
			 break;

		case 6:	 game_help();  break;

		case 7:	 if (goes) {
				say("ONLY ON THE FIRST GO, THICKO");
				clang_1();
			 } else
			 	return 0;
			 break;

		case 8:	 hint();  break;

		case 9:	 if (done=abandon_game()) return 0; else break;

		default: invalid();  break;

			}

		} while (!done);

	return 1;
}


/* -------------------------------------------------------------------- */
/*	Abandon the game						*/
/* -------------------------------------------------------------------- */

abandon_game()
{
static char a[] = "[0][ |You give up, Huh?  | ][Yuss|Neah]";

	int	butt;

	butt = form_alert(0,a);

	if (butt==1)
		{ quit_flag=1; say("PATHETIC WIMP");  clang_2(); return 1; }
	else
		{ say("MAKE YOUR MIND UP, DIPSTICK"); clang_1(); return 0; }
}


/* -------------------------------------------------------------------- */
/*	Inactive button clicked						*/
/* -------------------------------------------------------------------- */

invalid()  {  say("THAT'S NO GOOD, IS IT, YOU FOOL");  clang_1(); }


/* -------------------------------------------------------------------- */
/*	Clicked nowhere in particular					*/
/* -------------------------------------------------------------------- */

nowhere()  {  say("CLICK A LITTLE LESS RANDOMLY, IDIOT");  clang_1(); }

/* -------------------------------------------------------------------- */
/*	Generate a hint							*/
/* -------------------------------------------------------------------- */

hint()
{
	int	max,i,j,k,p,si[64],sj[64],sp[64],v;

	say("HANG ON -- I'M THINKING");  max = -9999;  k=0;

	for (i=2; i<10; ++i) {
		for (j=2; j<10; ++j) {
			if (!board[i][j]) {
				v = evaluate(i,j,&p);
				if (v==max) {
					si[k]=i; sj[k]=j; sp[k]=p; ++k;
					}
				if (v>max) {
					k=1; si[0]=i; sj[0]=j; sp[0]=p; max=v;
					}
				}
			}
		}

	if (!k) {
		say("I'M SHORT OF IDEAS MYSELF, ACTUALLY");  bell();
	} else {
		say("HOW ABOUT THIS?");  bell();
		k = ((Random() & 0xffff) % k);
		for (i=0; i<3; ++i) {
			display(si[k]-2,sj[k]-2,sp[k]);
			for (j=0; j<20000; ++j);
			display(si[k]-2,sj[k]-2,-3);
			for (j=0; j<1000; ++j);
			}
		}
}
