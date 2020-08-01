/*

		This file was created with ACS2.05 (c) Stefan Bachert 1991, 1992
		The contents is based on file: C:\DEVELOP\FORTH\F68KNEU\ATARI\ACS\F68KACS.ACS
		compiled at: Wed Dec 11 11:43:10 1991
*/


/*	 STRINGS	 */



/*	 ICONS	 */



/*	 MENU TREES	 */



/*	 OBJECT TREES	 */



/*	 WINDOWS	 */



extern Adescr ACSdescr;



/*		ANSI-C Prototypes		*/

extern INT16 CDECL A_3Dbutton (PARMBLK* pb);
extern INT16 CDECL A_checkbox (PARMBLK* pb);
extern INT16 Auo_string (OBJECT* entry, INT16 task, void* in_out);
extern void editor_key (Awindow* wi, INT16 kstate, INT16 key);
extern void editor_key_test (Awindow* wi, INT16 kstate, INT16 key);
extern void handle_caps (void);
extern void startupstream (void);


