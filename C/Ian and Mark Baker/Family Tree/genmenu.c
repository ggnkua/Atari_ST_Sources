/* see Atari Copmpendium p6.26 for menu structure		*/
/* see Lattice User Manual p361 for OBJECT structure	*/
OBJECT assoc_menu[4] = { { -1,  1,  4, G_IBOX,  0, 0, NULL, 0, 0, 0, 0 },		/* 0 root		*/
						 {  4,  2,  2, G_BOX,   0, 0, NULL, 0, 0, 0, 0 },		/* 1 bar		*/
						 {  1,  3,  3, G_IBOX,  0, 0, NULL, 0, 0, 0, 0 },		/* 2 active		*/
						 {  2, -1, -1, G_TITLE, 0, 0, NULL, 0, 0, 0, 0 },		/* 3 title		*/
						 {  0,  5,  5, G_IBOX,  0, 0, NULL, 0, 0, 0, 0 },		/* 4 dropdowns	*/
						 {  4, -1, -1, G_BOX,   ,  , NULL, 0, 0, 0, 0 } } ;		/* 5 box		*/
						 
void initialise_assoc_menu( void )
{
	assoc_menu[0].ob_width = deskbox.g_w ;		/* root		*/
	assoc_menu[0].ob_height = deskbox.g_h ;

	assoc_menu[1].ob_width = deskbox.g_w ;		/* bar		*/
	assoc_menu[1].ob_height = hchar + 2 ;
	
	assoc_menu[2].ob_width = deskbox.g_w ;		/* active	*/
	assoc_menu[2].ob_height = hchar ;
	
	assoc_menu[3].ob_width = deskbox.g_w ;		/* title	*/
	assoc_menu[3].ob_height = hchar ;
}
