/* ==========================================================
	Modul:	EX_TENIS.C  
				Playing tennis
	Author:	Ch. Hoofe
	Source:	based on the model decribed in:
				Star,Smith,Bleloch  How to model it McGraw-Hill
				1990, p. 70 
	Version:	1.0  20.8.91
   ========================================================== */
#define SIM_END 	5
#define TRUE 		1
#define FALSE 		0
 
#define PLAYER1	0
#define PLAYER2	1

#define WIN_SETS	2		/* number of sets to win a game */
/*#define DISPLAY 0*/
#undef DISPLAY
    
		/* global variables */
int matches_player1=0;		/* matches won by player 1 */
int matches_player2=0;		/* matches won by player 2 */ 

char name_player1[32];	/* name of player 1 */
char name_player2[32];	/* name of player 2 */

double win_probability_player1 = 154.0 / 230.0; 
double win_probability_player2 = 149.0 / 230.0;

int service = PLAYER1;
/* ==========================================================
	Function:	game()
					Play a game by using the random generator.
					This model is based on the assumption that we
					know the win probability of the serving player.	
	Parameter:	double win_probability = winning probability for
									      		 player 1 who service.
					int *points_player1 = pointer to the points of
												 player 1 (service)
					int *points_player2 = pointer to the points of
												 player 2
	Return:		int	TRUE=service wins or FALSE
   ========================================================== */
int game(double win_probability,int *points_player1,int *points_player2)
{
	int ini=0;

	while(TRUE)
	{
		if(random(&ini) < win_probability) 	/* point for player 1 */
			++*points_player1; /* increment the value where points_player1 */
									 /* points to */ 
		else											/* point for player 2 */
			++*points_player2; /* increment the value where points_player2 */
									 /* points to */
		
															/* Player 1 wins the game */		
		if(*points_player1 >= 4 && *points_player1 >= *points_player2+2)
		{
			return TRUE;
		} 
															/* Player 2 wins the game */				
		else if(*points_player2 >= 4 && *points_player2 >= *points_player1+2)
		{ 
			return FALSE;
		} 
	}
}
/* ==========================================================
	Function:	set()
					Play a set.	
	Parameter:	int service =	1st service from PLAYER1 or PLAYER2	
	Return:		int = the winner of the set PLAYER1 or PLAYER2 
   ========================================================== */
int set()
{
	int games_player1=0,games_player2=0,winner,points1,points2;
	
	while(TRUE)
	{
		points1=0;
		points2=0;
		 
		if(service==PLAYER1)
		{
			#ifdef DISPLAY 
			printf("\n service: %s",&name_player1[0]);
			#endif
			 
			if(game(win_probability_player1,&points1,&points2)==TRUE)
			{
				#ifdef DISPLAY
				printf("\n points %s %d  %s %d",
						 &name_player1[0],points1,&name_player2[0],points2); 
				#endif
				 
				games_player1++;
			} 
			else
			{
				#ifdef DISPLAY
				printf("\n points %s %d %s %d",
						 &name_player2[0],points2,&name_player1[0],points1);  
				#endif
				 
				games_player2++;
			} 
					
			service = PLAYER2;	
		}
		else						/* service of PLAYER2 */
		{
			#ifdef DISPLAY 
			printf("\n service: %s",&name_player2[0]); 
			#endif
			 
			if(game(win_probability_player2,&points1,&points2)==TRUE)
			{ 
				#ifdef DISPLAY
				printf("\n points %s %d     %s %d",
						 &name_player2[0],points1,&name_player1[0],points2); 
				#endif
							 
				games_player2++;
			} 
			else
			{ 
				#ifdef DISPLAY
				printf("\n points %s %d     %s %d",
						 &name_player2[0],points1,&name_player1[0],points2); 
				#endif
				 
				games_player1++;
			} 
				
			service = PLAYER1;
		}
		
 		/* Player 1 wins the set */		
		if(games_player1 >= 6 && games_player1 >= games_player2+2)
		{
			printf("\nset %d:%d",games_player1,games_player2);
	   	
			return PLAYER1;
		}
		/* Player 2 wins the set */				
		else if(games_player2 >= 6 && games_player2 >= games_player1+2)
		{
			printf("\nset %d:%d",games_player1,games_player2);
			return PLAYER2;
		}
	}
	return ret;
}
/* ==========================================================
	Function:	match()
					Play a tennis match.	
	Parameter:		
	Return:		int = the winner of the match PLAYER1 or PLAYER2 
   ========================================================== */
int match(void)
{
	int winner,sets_player1=0,sets_player2=0;

	while(TRUE)
	{
		winner=set();

		if(winner==PLAYER1)
			sets_player1++;
		else
			sets_player2++;				 
		
 		/* Player 1 wins the match */		
		if(sets_player1 == WIN_SETS || sets_player1 >= set_player2+2)
		{
			printf("\nmatch %s: %d  %s: %d",&name_player1[0],sets_player1,
	   									      &name_player2[0],sets_player2);
	   	
			return PLAYER1;
		}
		/* Player 2 wins the set */				
		else if(sets_player2 == WIN_SETS || sets_player2 >= set_player1+2)
		{
			printf("\nmatch %s: %d  %s: %d",&name_player1[0],sets_player1,
	   									      &name_player2[0],sets_player2);
			return PLAYER2;
		}
	}

} 
/* ==========================================================
	Function:	simulation()
	
	Parameter:	void
	Return:		void
   ========================================================== */
void simulation(void)
{
	 
	if(match()==PLAYER1)
		matches_player1++;
	else
		matches_player2++; 
}
/* ==========================================================
	Function:	initialization()
	
	Parameter:	void
	Return:		void
   ========================================================== */
void initialization(void)
{
	length=SIM_END;
	
	strcpy(&name_player1[0],"Steffi");
	strcpy(&name_player2[0],"Gabriela"); 
}
/* ==========================================================
	Function:	main()
				
	Parameter:	void
	Return:		void
   ========================================================== */
void main(void)
{

							/* initialization */
	initialization();
							/* simulation call */
	simulation();

	printf("Number of games %ld\n%s: %d   %s: %d",t,&name_player1[0],
			 matches_player1,&name_player2[0],matches_player2); 
 

}
