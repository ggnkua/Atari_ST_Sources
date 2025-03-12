/* PROGRAM */
/* ------- */

#define NONE 0
#define HOME 1
#define AWAY 2

#define TEAM_MIN 2	/* Fixed by algorithm */
#define TEAM_MAX 24	/* Variable */

#define DIV_MIN 1	/* Fixed by algorithm */
/* DIV_MAX determined at input time as TOP_DIV */

#define WEEK_MAX 52	/* Variable */

#define NOT_BOOKED 0
#define BOOKED 1	/* for Pitch */

#define Week_Of(a,b) League[a][b]
/* used instead of a function */

#define abs(a) ((a>0) ? (a):(-a))

typedef struct team
	{
	unsigned short Team_Num;
	unsigned short Pitch_Num;
	unsigned short Div_Num;
	} TEAM;
typedef unsigned short LEAGUE;
/* League table arranged as a matrix of the form [home][away] 
containing the week number of each match (or zero for no match)
Note that all tables actually go from 0 to TEAM_MAX-1 */
typedef unsigned short PITCH;

TEAM    Team[TEAM_MAX];
LEAGUE  League[TEAM_MAX][TEAM_MAX];
PITCH   Pitch[TEAM_MAX][WEEK_MAX];

unsigned short Top_Team;	/* filled in by input */
unsigned short Top_Div;		/* filled in by input */

/* SUBROUTINES */
void Input_Teams();
short Make_League();
void Empty_League();
short Week_Test(unsigned short,unsigned short,unsigned short);
short Playing(unsigned short,unsigned short,unsigned short);
unsigned short Play_Status(unsigned short,unsigned short);
void Print_League();

void main()
{
Input_Teams();	/* Implementation Specific */
Make_League();	/* Generic Routine */
Print_League();	/* Implementation Specific */
}

/*===================================================================*/

short Make_League()
{
unsigned short Home_Team,Away_Team;
unsigned short Home_Week;	/* Current Week */

Empty_League();	/* Initialise League Table and Pitches */

for(Home_Team=0;Home_Team<Top_Team;Home_Team++)
	{
	for(Away_Team=0;Away_Team<Top_Team;Away_Team++)
		{
		if((Home_Team!=Away_Team)
		&&(Team[Home_Team].Div_Num==Team[Away_Team].Div_Num))
			{
			/* THEN ..... */
			Home_Week=1;	/* first try is week 1! */
			while((Week_Test(Home_Team,Away_Team,Home_Week)==-1)
			&&(Home_Week<WEEK_MAX))
				Home_Week++;
			if(Home_Week==WEEK_MAX) return -1;	/* ABORT - Not Enough Weeks */
			/* All tests are done in Week_Test for clarity */	
			Pitch[Team[Home_Team].Pitch_Num][Home_Week]=BOOKED;	/* Book Pitch */
			League[Home_Team][Away_Team]=Home_Week;	/* Set Match Week */
			}
		} /* NEXT AWAY_TEAM */
	} /* NEXT HOME_TEAM */
return 1;
}

void Empty_League()
{
unsigned short Home_Team,Away_Team,Week;
for(Home_Team=0;Home_Team<TEAM_MAX;Home_Team++)
	{
	for(Week=0;Week<WEEK_MAX;Week++)
		Pitch[Team[Home_Team].Pitch_Num][Week]=NOT_BOOKED;
	for(Away_Team=0;Away_Team<TEAM_MAX;Away_Team++)
		League[Home_Team][Away_Team]=0;
	}
}

short Week_Test(Home_Team,Away_Team,Home_Week)
unsigned short Home_Team,Away_Team,Home_Week;
{
unsigned short Away_Week;

Away_Week=Week_Of(Away_Team,Home_Team);
if(Away_Week!=0)
	if(abs(Home_Week-Away_Week)<(Top_Team-1))
		return -1;

if(Home_Week>2)	/* else last two matches don't exist! */
	{
	if((Play_Status(Home_Team,(unsigned short) (Home_Week-1))==HOME)
	&&(Play_Status(Home_Team,(unsigned short) (Home_Week-2))==HOME))
		return -1;

	if((Play_Status(Away_Team,(unsigned short) (Home_Week-1))==AWAY)
	&&(Play_Status(Away_Team,(unsigned short) (Home_Week-2))==AWAY))
		return -1;
	}
	
if(Pitch[Team[Home_Team].Pitch_Num][Home_Week]==BOOKED)
	return -1;

return (Playing(Home_Team,Away_Team,Home_Week));
}

short Playing(Home,Away,Week)
unsigned short Home,Away,Week;
{
/* find out if either team already playing */
unsigned short x;
for(x=0;x<Top_Team;x++)
        {
        if ((League[Home][x]==Week)||(League[Away][x]==Week)||(League[x][Home]==Week)||(League[x][Away]==Week))
                return -1;
        }
return 0;
}

unsigned short Play_Status(Team,Week)
unsigned short Team,Week;
{
unsigned short Home_Team,Away_Team;

for(Home_Team=0;Home_Team<Top_Team;Home_Team++)
	for(Away_Team=0;Away_Team<Top_Team;Away_Team++)
		{
		if((Team==Home_Team)&&(Week_Of(Home_Team,Away_Team)==Week)) return HOME;
		if((Team==Away_Team)&&(Week_Of(Home_Team,Away_Team)==Week)) return AWAY;
		}
return NONE;
}
/*===================================================================*/

void Input_Teams()	/* does not check for duplicate entries */
{
int Team_Num,Pitch_Num,Div_Num;
putch(12);	/* clear screen */
printf("Enter Team Details separated by commas or 0,0,0 to End\n\n");
printf("| Team No. | Pitch No. | Division |\n");
Top_Team=0;
do
        {
        scanf("%2d,%2d,%2d\n",&Team_Num,&Pitch_Num,&Div_Num);
				Team[Top_Team].Team_Num=Team_Num;
				Team[Top_Team].Pitch_Num=Pitch_Num;
				Team[Top_Team].Div_Num=Div_Num;
        putch(27); putch('A'); putch(27); putch('o');
        /* up cursor & erase to start of line */
        printf("|    %2u    |     %2u    |     %2u   |\n",Team[Top_Team].Team_Num,Team[Top_Team].Pitch_Num,Team[Top_Team].Div_Num);
        Top_Team++;
        } while((Top_Team<TEAM_MAX) && (Team[Top_Team-1].Team_Num!=0));
}

void Print_League()
{
unsigned short Home_Team,Away_Team;
putch(12);
printf("| Home | Away | Division | Week |\n");
printf("|------|------|----------|------|\n");
for(Home_Team=0;Home_Team<Top_Team;Home_Team++)
        {
        for(Away_Team=0;Away_Team<Top_Team;Away_Team++)
                {
                if (League[Home_Team][Away_Team]!=0)
                        printf("|  %2d  |  %2d  |    %1d     |  %2d  |\n",Team[Home_Team].Team_Num,Team[Away_Team].Team_Num,Team[Home_Team].Div_Num,League[Home_Team][Away_Team]);
                }
        }
}
