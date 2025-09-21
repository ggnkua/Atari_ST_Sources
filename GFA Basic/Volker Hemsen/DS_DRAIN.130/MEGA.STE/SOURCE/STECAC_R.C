
OBJECT TDIAL[] = {
/*0*/	{-1,1,18,G_BOX,0x0,0x0,(void *)0x11100,0,0,40,15},
/*1*/	{2,-1,-1,G_BUTTON,0x0,0x20,"MEGA STE - Cache Change", 2,1,36,2},
/*2*/	{3,-1,-1,G_BOXCHAR,0x1,0x0,(void *)0xff1100,3,4,2,1},
/*3*/	{4,-1,-1,G_STRING,0x0,0x0,"16 MHz", 6,4,6,1},
/*4*/	{5,-1,-1,G_BOXCHAR,0x1,0x0,(void *)0xff1100,20,4,2,1},
/*5*/	{6,-1,-1,G_STRING,0x0,0x0,"Tastatur-Klick", 23,4,14,1},
/*6*/	{7,-1,-1,G_BOXCHAR,0x1,0x0,(void *)0xff1100,3,6,2,1},
/*7*/	{8,-1,-1,G_STRING,0x0,0x0,"Cache an", 6,6,8,1},
/*8*/	{9,-1,-1,G_BOXCHAR,0x1,0x0,(void *)0xff1100,20,6,2,1},
/*9*/	{10,-1,-1,G_STRING,0x0,0x0,"Tastatur-Repeat", 23,6,15,1},
/*10*/	{11,-1,-1,G_BOXCHAR,0x1,0x0,(void *)0xff1100,3,8,2,1},
/*11*/	{12,-1,-1,G_STRING,0x0,0x0,"Blitter", 6,8,7,1},
/*12*/	{13,-1,-1,G_BOXCHAR,0x1,0x0,(void *)0xff1100,20,8,2,1},
/*13*/	{14,-1,-1,G_STRING,0x0,0x0,"Ton bei asc(7)", 23,8,14,1},
/*14*/	{15,-1,-1,G_BOXCHAR,0x1,0x0,(void *)0xff1100,3,10,2,1},
/*15*/	{16,-1,-1,G_STRING,0x0,0x0,"fverify", 6,10,7,1},
/*16*/	{17,-1,-1,G_BUTTON,0x7,0x0,"OK", 2,13,10,1},
/*17*/	{18,-1,-1,G_BUTTON,0x5,0x0,"sichern", 15,13,10,1},
/*18*/	{0,-1,-1,G_BUTTON,0x25,0x0,"Abbruch", 28,13,10,1},
};



static void fix_tree(OBJECT *s,int max)
{
	int i;

	for(i=0; i<=max; i++)
		rsrc_obfix(s,i);
}

void rsrc_init(void)
{
	fix_tree(TDIAL,18);
}
