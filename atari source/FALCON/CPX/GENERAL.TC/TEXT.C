/* TEXT.C
 *==========================================================================
 * DATE: April 30, 1990
 * DESCRIPTION: Text strings for Active Country
 */
 
#include "country.h"
 

/* COUNTRY: USA | UK
 *==========================================================================
 */
#if USA | UK

/* Block2.C */
					/* STE Speed and TT Speaker   */
char *block2_title[] = { " ",		/* Neither PResent	      */
			 "Speaker",     /* TT Speaker Present	      */
			 "CPU Speed"	/* STE with 8/16 toggle       */
		       };

char *STE_Text[] =   { " 8 MHz - No Cache",
		       "16 MHz - No Cache",
		       "16 MHz - Cache"
		     };
		     
char *STE_Speed[] =  { "8 MHz",
		       "16 MHz",
		       "16 MHz"
		     };


/* TTBLIT.C */
					/* Title of Block ONE		*/
					/* Blitter/Cache or Both        */
char *Chip_Title[] = { " ",		/* 0 - no blitter / no 030 cache*/
		       "Blitter",	/* 1 - Blitter       		*/
		       "Cache",		/* 2 - TT/ 030 Cache 		*/
		       "Chip Select"	/* 3 - Blitter and TT/030 Cache */
		     };
		     
		     
char *chip1_text[] = { "On",		/* Good for Blitter and 030 Cache*/
		       "Off"		/* and TT SPeaker		 */
		     };			/* Also good for button text     */
		     
		     
		    		        /* Blitter and CAche Present  */
char *chip2_text[] = { "Blit/Cache Off",/* Both BLitter and Cache off */
		       "Blitter On",    /* Blitter On		      */
		       "Cache On",	/* Cache On		      */
		       "Blit/Cache On"  /* Blitter AND Cache On	      */
		     };
		
		
char *chip_button[] = { "Both Off",
			"Blit On",
			"Cache On",
			"Both On"
		      };
#endif



/* COUNTRY: ITALY
 *==========================================================================
 */
#if ITALY

/* Block2.C */
					/* STE Speed and TT Speaker   */
char *block2_title[] = { " ",		/* Neither PResent	      */
			 "Altoparlante",     /* TT Speaker Present	      */
			 "Velocit…"	/* STE with 8/16 toggle       */
		       };

char *STE_Text[] =   { " 8 MHz - senza cache",
		       "16 MHz - senza cache",
		       "16 MHz - con cache"
		     };
		     
char *STE_Speed[] =  { "8 MHz",
		       "16 MHz",
		       "16 MHz"
		     };

/* TTBLIT.C */
					/* Title of Block ONE		*/
					/* Blitter/Cache or Both        */
char *Chip_Title[] = { " ",		/* 0 - no blitter / no 030 cache*/
		       "Blitter",	/* 1 - Blitter       		*/
		       "Cache",		/* 2 - TT/ 030 Cache 		*/
		       "Chip Select"	/* 3 - Blitter and TT/030 Cache */
		     };
		     
		     
char *chip1_text[] = { "Si",		/* Good for Blitter and 030 Cache*/
		       "No"		/* and TT SPeaker		 */
		     };			/* Also good for button text     */
		     
		     
		    		        /* Blitter and CAche Present  */
char *chip2_text[] = { "Blit/Cache Off",/* Both BLitter and Cache off */
		       "Blitter On",    /* Blitter On		      */
		       "Cache On",	/* Cache On		      */
		       "Blit/Cache On"  /* Blitter AND Cache On	      */
		     };
		
		
char *chip_button[] = { "Both Off",
			"Blit On",
			"Cache On",
			"Both On"
		      };
#endif



/* COUNTRY: GERMAN
 *==========================================================================
 */
#if GERMAN

/* Block2.C */
					/* STE Speed and TT Speaker   */
char *block2_title[] = { " ",		/* Neither PResent	      */
			 "Lautsprecher",/* TT Speaker Present	      */
			 "Systemtakt"	/* STE with 8/16 toggle       */
		       };

char *STE_Text[] =   { " 8 MHz - Cache aus",
		       "16 MHz - Cache aus",
		       "16 MHz - Cache an"
		     };
		     
char *STE_Speed[] =  { "8 MHz",
		       "16 MHz",
		       "16 MHz"
		     };

/* TTBLIT.C */
					/* Title of Block ONE		*/
					/* Blitter/Cache or Both        */
char *Chip_Title[] = { " ",		/* 0 - no blitter / no 030 cache*/
		       "Blitter",	/* 1 - Blitter       		*/
		       "Cache",		/* 2 - TT/ 030 Cache 		*/
		       "Chip Select"	/* 3 - Blitter and TT/030 Cache */
		     };
		     
		     
char *chip1_text[] = { "An",		/* Good for Blitter and 030 Cache*/
		       "Aus"		/* and TT SPeaker		 */
		     };			/* Also good for button text     */
		     
		     
		    		        /* Blitter and CAche Present  */
char *chip2_text[] = { "Blit/Cache aus",/* Both BLitter and Cache off */
		       "Blitter an",    /* Blitter On		      */
		       "Cache an",	/* Cache On		      */
		       "Blit/Cache an"  /* Blitter AND Cache On	      */
		     };
		
		
char *chip_button[] = { "Both aus",
			"Blit an",
			"Cache an",
			"Both an"
		      };
#endif




/* COUNTRY: FRENCH
 *==========================================================================
 */
#if FRENCH

/* Block2.C */
					/* STE Speed and TT Speaker   */
char *block2_title[] = { " ",		/* Neither PResent	      */
			 "Haut-Parleur",/* TT Speaker Present	      */
			 "Vitesse"	/* STE with 8/16 toggle       */
		       };

char *STE_Text[] =   { " 8 MHz - Sans Cache",
		       "16 MHz - Sans Cache",
		       "16 MHz - Avec Cache"
		     };
		     
char *STE_Speed[] =  { "8 MHz",
		       "16 MHz",
		       "16 MHz"
		     };

/* TTBLIT.C */
					/* Title of Block ONE		*/
					/* Blitter/Cache or Both        */
char *Chip_Title[] = { " ",		/* 0 - no blitter / no 030 cache*/
		       "Blitter",	/* 1 - Blitter       		*/
		       "Cache",		/* 2 - TT/ 030 Cache 		*/
		       "Chip Select"	/* 3 - Blitter and TT/030 Cache */
		     };
		     
		     
char *chip1_text[] = { "Oui",		/* Good for Blitter and 030 Cache*/
		       "Non"		/* and TT SPeaker		 */
		     };			/* Also good for button text     */
		     
		     
		    		        /* Blitter and CAche Present  */
char *chip2_text[] = { "Blit/Cache Non",/* Both BLitter and Cache off */
		       "Blitter Oui",    /* Blitter On		      */
		       "Cache Oui",	/* Cache On		      */
		       "Blit/Cache Oui"  /* Blitter AND Cache On	      */
		     };
		
		
char *chip_button[] = { "Both Non",
			"Blit Oui",
			"Cache Oui",
			"Both Oui"
		      };
#endif



/* COUNTRY: SPAIN
 *==========================================================================
 */
#if SPAIN

/* Block2.C */
					/* STE Speed and TT Speaker   */
char *block2_title[] = { " ",		/* Neither PResent	      */
			 "Altavoz",     /* TT Speaker Present	      */
			 "Frec. Reloj"	/* STE with 8/16 toggle       */
		       };
		       
char *STE_Text[] =   { " 8 MHz - Cach‚ Off",
		       "16 MHz - Cach‚ Off",
		       "16 MHz - Cach‚ On"
		     };
		     
char *STE_Speed[] =  { "8 MHz",
		       "16 MHz",
		       "16 MHz"
		     };


/* TTBLIT.C */
					/* Title of Block ONE		*/
					/* Blitter/Cache or Both        */
char *Chip_Title[] = { " ",		/* 0 - no blitter / no 030 cache*/
		       "Blitter",	/* 1 - Blitter       		*/
		       "Cach‚",		/* 2 - TT/ 030 Cache 		*/
		       "Chip Select"	/* 3 - Blitter and TT/030 Cache */
		     };
		     
		     
char *chip1_text[] = { "On",		/* Good for Blitter and 030 Cache*/
		       "Off"		/* and TT SPeaker		 */
		     };			/* Also good for button text     */
		     
		     
		    		        /* Blitter and CAche Present  */
char *chip2_text[] = { "Blit/Cach‚ Off",/* Both BLitter and Cache off */
		       "Blitter On",    /* Blitter On		      */
		       "Cach‚ On",	/* Cache On		      */
		       "Blit/Cach‚ On"  /* Blitter AND Cache On	      */
		     };
		
		
char *chip_button[] = { "Both Off",
			"Blit On",
			"Cach‚ On",
			"Both On"
		      };
#endif






/* COUNTRY: SWEDEN
 *==========================================================================
 */
#if SWEDEN

/* Block2.C */
					/* STE Speed and TT Speaker   */
char *block2_title[] = { " ",		/* Neither PResent	      */
			 "H”gtalare",     /* TT Speaker Present	      */
			 "Hastighet"	/* STE with 8/16 toggle       */
		       };

char *STE_Text[] =   { " 8 MHz - Cache av",
		       "16 MHz - Cache av",
		       "16 MHz - Cache p\206"
		     };
		     
char *STE_Speed[] =  { "8 MHz",
		       "16 MHz",
		       "16 MHz"
		     };

/* TTBLIT.C */
					/* Title of Block ONE		*/
					/* Blitter/Cache or Both        */
char *Chip_Title[] = { " ",		/* 0 - no blitter / no 030 cache*/
		       "Blitter",	/* 1 - Blitter       		*/
		       "Cache",		/* 2 - TT/ 030 Cache 		*/
		       "Chip Select"	/* 3 - Blitter and TT/030 Cache */
		     };
		     
		     
char *chip1_text[] = { "P\206",		/* Good for Blitter and 030 Cache*/
		       "Av"		/* and TT SPeaker		 */
		     };			/* Also good for button text     */
		     
		     
		    		        /* Blitter and CAche Present  */
char *chip2_text[] = { "Blit/Cache Off",/* Both BLitter and Cache off */
		       "Blitter On",    /* Blitter On		      */
		       "Cache On",	/* Cache On		      */
		       "Blit/Cache On"  /* Blitter AND Cache On	      */
		     };
		
		
char *chip_button[] = { "Both Off",
			"Blit On",
			"Cache On",
			"Both On"
		      };
#endif





