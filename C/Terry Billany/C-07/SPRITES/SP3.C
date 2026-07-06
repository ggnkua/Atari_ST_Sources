#include <d:stdio.h>
#include <d:osbind.h>

#define SPRITES 5
#define TOP 40
#define BOTTOM 183
#define LEFT 0
#define RIGHT 623
#define BACKSIZE 266

char background[SPRITES*BACKSIZE];
int x[SPRITES],y[SPRITES];
int i;

int sprite[]={0,0,0,0,1,
0xffff,0xffff,0xffff,0x8001,0xffff,0x8001,0xffff,0x8001,
0xffff,0x8551,0xffff,0x8aa1,0xffff,0x8551,0xffff,0x8aa1,
0xffff,0x8551,0xffff,0x8aa1,0xffff,0x8551,0xffff,0x8aa1,
0xffff,0x8001,0xffff,0x8001,0xffff,0x8001,0xffff,0xffff};

int xi[]={1,0,1,1,0,2,2,0,3};
int yi[]={1,1,0,2,2,0,1,3,0};

main()
{
 int c;
 c=0;
 init_linea();
 for(i=0;i<SPRITES;i++)
 { 
   x[i]=i*22;y[i]=i*16+40;
 }
 while(c<1500)
 {
   c++;
   sp_draw();
   sp_move();
   Vsync();
   sp_erase();
 }
}

sp_draw()
{
 for(i=0;i<SPRITES;i++)
  draw_sprite(x[i],y[i],&sprite,&background[i*BACKSIZE]);
}

sp_move()
{
 for(i=0;i<SPRITES;i++)
 {
   x[i]+=xi[i]; y[i]+=yi[i];
   if(x[i]>RIGHT || x[i]<LEFT)
     { xi[i]=-xi[i]; x[i]+=xi[i]; x[i]+=xi[i]; }
   if(y[i]>BOTTOM || y[i]<TOP)
     { yi[i]=-yi[i]; y[i]+=yi[i]; y[i]+=yi[i]; }
 }
}

sp_erase()
{
 for(i=SPRITES-1;i>=0;i--)
   erase_sprite(&background[i*BACKSIZE]);
}
