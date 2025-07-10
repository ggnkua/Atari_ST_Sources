/* ========================================================
	Modul:	EX_LYNX.C  
				Rabbit model.
	Author:	Ch. Hoofe
	Source:	H. Rauch Modelle der Wirklichkeit p. 41
	Version:	1.0  20.4.91
   ======================================================== */
#define SIM_END 61
					/* global simulation variables */
long		length;
long		t;
double 	dt;

			/* simulation variables declaration */
double Rabbit[SIM_END];	
double Lynx[SIM_END];	

			/* global variables */

			/* parameter */
#define BIRTH_RATE_RABBIT 	0.50	/* birth rate rabbits	*/ 
#define DEATH_RATE_LYNX 	0.25	/* death rate lynx		*/  
#define RABBITxLYNX			0.05	/* death rate Rabbit meets lynx */
#define LYNXxRABBIT			0.01	/* birth rate Lynx meets Rabbit */

/* ========================================================
	Function:	initialization()
	
	Parameter:	void
	Return:		void
   ======================================================== */
void initialization(void)
{
	length = SIM_END;
	t = 1;
	dt = 0.25;
	
	Rabbit[0]=20;
	Lynx[0]=7;
}
/* ========================================================
	Function:	integration_rk4()
	
	Parameter:	void
	Return:		void
   ======================================================== */
void integration_rk4(void)
{
	double mult = Rabbit[t] * Lynx[t];
	double R_birth,R_death,L_birth,L_death;
	
	R_birth = BIRTH_RATE_RABBIT * Rabbit[t];
	R_death = RABBITxLYNX * mult;	
	L_birth = LYNXxRABBIT * mult;	
	L_death = DEATH_RATE_LYNX * Lynx[t];	

	Lynx[t]	  ~= L_birth - L_death;
	Rabbit[t]  ~= R_birth - R_death;
}
/* ========================================================
	Function:	simulation()
	
	Parameter:	void
	Return:		void
   ======================================================== */
void simulation(void)
{

	Rabbit[t]=Rabbit[t-1];
	Lynx[t]=Lynx[t-1];
		
	integration_rk4();

	if(Rabbit[t]<0 || Lynx[t]<0)
		exit();
}
/* ========================================================
	Function:	main()
				
	Parameter:	void
	Return:		void
   ======================================================== */
void main(void)
{

							/* initialization */
	initialization();
							/* simulation call */
	simulation();

}

/* =============================================================
	Copy the following commands to the
	Command window to display the results
				
	simgraf("Rabbit-Lynx Rabbits %f  Lynxs %f ",&Rabbit[0],&Lynx[0]);
	simlist("Rabbit-Lynx Rabbits %10.6f  Lynxs %10.6f ",&Rabbit[0],&Lynx[0]);
   ============================================================= */


