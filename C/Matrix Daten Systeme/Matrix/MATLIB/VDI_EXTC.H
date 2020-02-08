/*
		vdi_extc.h

        extended GEM VDI constant definitions

        TC-VDI 0.7 / 10.5.92

        Copyright (c) MATRIX Daten Systeme GmbH 1992
*/


							/*..... vro_cpyfm blit modes .......*/

							/* one pixel treated as unit ( long value )	*/
# define 	S_ADD_D		16	/*	add :				 S + D					*/
# define 	S_ADDS_D	17	/*	add saturated :		 min ( S + D, 1...1 )	*/
# define 	S_SUB_D		18	/*	subtract :			 S - D					*/
# define 	S_SUBS_D	19	/*	subtract saturated : max ( S + D, 0...0 )	*/
# define 	S_MAX_D		20	/*	maximum :			 max ( S, D )			*/
# define 	S_MIN_D		21	/*	minimum :			 min ( S, D )			*/

							/* pixels components calc'd separate ( a,R,G,B ) */
# define 	CS_ADD_D	22	/*	add :				 S + D					*/
# define 	CS_ADDS_D	23	/*	add saturated :		 min ( S + D, 1...1 )	*/
# define 	CS_SUB_D	24	/*	subtract :			 S - D					*/
# define 	CS_SUBS_D	25	/*	subtract saturated : max ( S + D, 0...0 )	*/
# define 	CS_MAX_D	26	/*	maximum :			 max ( S, D )			*/
# define 	CS_MIN_D	27	/*	minimum :			 min ( S, D )			*/

# define	MAXblitOP	27

							/* note : S_xyz == CS_xyz for bpp <= 8	*/

							/*..... MFDB formats ...........*/
# define DEV_FORM 0
# define STD_FORM 1
# define PCK_FORM 2			/* new : packed pixel format in 1,8,16,24,32 bpp	*/

