#include <easy_gem.h>

typedef struct 
{
	int hoehe;
	int breite;
	int daten[10];
}Stad_buffer;

void put_buffer(int x,int y,int mode,void *adr)
{
	Stad_buffer *p;
	
	p=(Stad_buffer *)adr;
	form_to_screen(x,y,p->breite-1,p->hoehe-1,mode,p->daten);
}