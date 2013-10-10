/***********************************************************************/
/* F”rs”k till att skapa en 2D/3D labyrint skapare                     */
/*                                                                     */
/*                                                                     */
/*                                                                     */
/***********************************************************************/	
#include <stdio.h>
#include <stdlib.h>
#include <mode.h>
#include <osbind.h>

#define NOLL        0
#define FALSE       0
#define TRUE        !FALSE
#define FAIL        -1
#define MAX_XYZ     4
#define MAX_XYZ2    (1<<MAX_XYZ)
#define TEXT_BITS   6
#define BOX_SIZE    12

#define WHITE       65535
#define BLACK       0
#define RED         63488
#define GREEN       2016
#define BLUE        31
#define YELLOW      65504
#define PURPLE      63519
#define CYAN        2047

#define MAX_CONN    19

#define WALL_NONE   0
#define WALL_T1     1
#define WALL_T2     2
#define WALL_T3     3
#define WALL_T4     4
#define WALL_T5     5
#define WALL_T6     6
#define WALL_T7     7
#define WALL_STOP   ((1<<(TEXT_BITS-1))-1)

#define D_NORTH     0
#define D_EAST      1
#define D_SOUTH     2
#define D_WEST      3
#define D_UP        4
#define D_DOWN      5

typedef struct screen
{
	unsigned int old_screen;
	unsigned int *old_view;
	unsigned int *old_draw;
	unsigned short int *view_adr;
	unsigned short int *draw_adr;
} screen;


typedef struct MAZE
{
  unsigned  west   :TEXT_BITS,
            north  :TEXT_BITS,
            down   :TEXT_BITS,
            spec   :TEXT_BITS;
}MAZE;

typedef struct MAZE2
{
  int       x,y,z;
  unsigned  west   :TEXT_BITS,
            north  :TEXT_BITS,
            east   :TEXT_BITS,
            south  :TEXT_BITS,
            up     :TEXT_BITS,
            down   :TEXT_BITS,
            spec   :TEXT_BITS,
            used   :1;
}MAZE2;

typedef struct TEXTURE
{
  char      *texture[64];
}TEXTURE;

typedef struct BOX
{
  int  x0,y0,
       x1,y1,
       x2,y2,
       x3,y3;
}BOX;
screen sc_data;

unsigned int color[]={BLACK,WHITE,RED,GREEN,BLUE,YELLOW,PURPLE,RED,RED,RED,RED,RED,RED,RED,RED,RED,
                      RED,RED,RED,RED,RED,RED,RED,RED,RED,RED,RED,RED,RED,RED,RED,RED,};
char     *dirs[]=    {"North","East","South","West","Up","Down",};

MAZE *init_maze();

void  deinit_maze(MAZE *);
MAZE* checkroom(MAZE *, int, int, int);
void  checkcoords(MAZE *, MAZE *, int *, int *, int *);
MAZE2 getroom(MAZE *, int, int, int);
void  putroom(MAZE *, MAZE2);
int   init_screen(void);
void  deinit_screen(void);
void  plot(int, int, int);
void  cplot(int, int, int, int, int);
void  hline(int, int, int, int);
void  vline(int, int, int, int);
void  dline(int, int, int, int,int);
void  draw_board(void);
void  draw_maze(MAZE *);
void  random_maze(MAZE *, int);
void  view_maze(MAZE *maze,int threedee);
void  fbox(int ,int ,int ,int ,int );
/***********************************************************************/
/*                                                                     */
/***********************************************************************/
int main()
{
  MAZE *maze;
  
  srand(time());
  maze=(MAZE *)init_maze();
  if(maze==NOLL)
    return -1;
  clear_maze(maze);
  if(!init_screen())
    return -2;
  draw_maze(maze);
  deinit_screen();
  deinit_maze(maze);
  return 0;
}
/***********************************************************************/
/***********************************************************************/
void draw_board(void)
{
	int counter;
	for(counter=NOLL; counter<=MAX_XYZ2; counter++)
	{
		hline(NOLL,counter*BOX_SIZE,BOX_SIZE<<MAX_XYZ,WHITE);
   	    vline(counter*BOX_SIZE,NOLL,BOX_SIZE<<MAX_XYZ,WHITE);
   	}

}
/***********************************************************************/
/***********************************************************************/
void draw_maze(MAZE *maze)
{
  int  bottom=0,a=NOLL,b=NOLL,c=NOLL,w1,w2,w3,w4,draw=TRUE,exit=FALSE;
  int  filecounter=0,threedee;
  char key;
  MAZE *room;
  FILE *file;
  char filename[15]="",filepath[255]="*.MAP";
  short testar;
  
  do
  {
    if(draw)
    {
      for(a=NOLL;a<MAX_XYZ2;a++)
      {
        for(b=NOLL;b<MAX_XYZ2;b++)
        {
          if(bottom==0) /* rita i x/y-plan*/
          {
            room=checkroom(maze,a,b,c);
            w1=room->west;
            w2=room->north;
            w3=room->down;
            w4=room->spec;
          }
          else if(bottom==1) /* rita i z/y-plan */
          {
            room=checkroom(maze,a,b,c);
          }
          else if(bottom==2) /* rita i z/x-plan */
          {
          }
          if((b<MAX_XYZ2-1)&&(a<MAX_XYZ2-1))
          {
            fbox(a*BOX_SIZE+1,b*BOX_SIZE+1,BOX_SIZE-1,BOX_SIZE-1,color[0]);
//            fbox(a*BOX_SIZE+1,b*BOX_SIZE+1,BOX_SIZE-1,BOX_SIZE-1,color[w3]);
          } 
          if((b<MAX_XYZ2-1)&&(c<MAX_XYZ2-1))
          {
            if(w1!=0)
              vline(a*BOX_SIZE,b*BOX_SIZE,b*BOX_SIZE+BOX_SIZE,color[w1]);
            else
            {
              vline(a*BOX_SIZE,b*BOX_SIZE,b*BOX_SIZE+BOX_SIZE,color[0]);
//              vline(a*BOX_SIZE,b*BOX_SIZE,b*BOX_SIZE+BOX_SIZE,color[1]);
//              hline(a*BOX_SIZE-BOX_SIZE/2+1,b*BOX_SIZE+BOX_SIZE/2,a*BOX_SIZE+BOX_SIZE/2,color[w1]);
            }
          }
          if((a<MAX_XYZ2-1)&&(c<MAX_XYZ2-1))
          {
            if(w2!=0)
              hline(a*BOX_SIZE,b*BOX_SIZE,a*BOX_SIZE+BOX_SIZE,color[w2]);
            else
            {
              hline(a*BOX_SIZE,b*BOX_SIZE,a*BOX_SIZE+BOX_SIZE,color[0]);
//              hline(a*BOX_SIZE,b*BOX_SIZE,a*BOX_SIZE+BOX_SIZE,color[1]);
//              vline(a*BOX_SIZE+BOX_SIZE/2,b*BOX_SIZE-BOX_SIZE/2+1,b*BOX_SIZE+BOX_SIZE/2,color[w2]);
            } 
          }
          if((b<MAX_XYZ2-1)&&(a<MAX_XYZ2-1))
          {
//            fbox(a*BOX_SIZE+3,b*BOX_SIZE+3,BOX_SIZE-5,BOX_SIZE-5,color[w4+1]);
          } 
        }
      }
    }
    draw=FALSE;
    key=getch();
    switch(key)
    {
      case 'R':
        draw=TRUE;
        clear_maze(maze);
        threedee=TRUE;
        random_maze(maze,threedee);
        break;
      case 'r':
        draw=TRUE;
        clear_maze(maze);
        threedee=FALSE;
        random_maze(maze,threedee);
        break;
      case 's':
      case 'S':
        sprintf(filename,"maze%04d.map",filecounter);
        file=fopen(filename,"wb");
        if(file)
        {
          fwrite(maze,1<<MAX_XYZ<<MAX_XYZ<<MAX_XYZ<<TEXT_BITS>>1,1,file);
          fclose(file);
          filecounter++;
        }
        break;
      case 'o':
      case 'O':
        deinit_screen();
        fsel_exinput(filepath, filename, &testar,"Load MAP");
        if(testar)
        {
          file=fopen(filename,"rb");
          if(file)
          {
            fread(maze,1<<MAX_XYZ<<MAX_XYZ<<MAX_XYZ<<TEXT_BITS>>1,1,file);
            fclose(file);
          }
        }
        init_screen();
        draw=TRUE;
        break;
      case 'v':
      case 'V':
        view_maze(maze,threedee);
        break;
      case '+':
        if(c<MAX_XYZ2-2)
          c++, draw=TRUE;
        break;
      case '-':
        if(c>NOLL)
          c--, draw=TRUE;
        break;
      case '*': exit=TRUE;
        break;
    }
  }while(!exit);
}
/***********************************************************************/
/***********************************************************************/
void draw_pointer(int x, int y,int col)
{
	fbox(1+x*BOX_SIZE,1+y*BOX_SIZE,2,2,col);
}
/***********************************************************************/
/***********************************************************************/
/***********************************************************************/
MAZE* init_maze()
{
  return((MAZE *) Malloc(1<<MAX_XYZ<<MAX_XYZ<<MAX_XYZ<<TEXT_BITS>>1));
}
/***********************************************************************/
/***********************************************************************/
void deinit_maze(MAZE *maze)
{
	Mfree(maze);
}
/***********************************************************************/
/***********************************************************************/
MAZE* checkroom(MAZE *maze,int x,int y,int z)
{
	MAZE *temp;
	temp=maze;
	temp+=x;
	temp+=y<<MAX_XYZ;
	temp+=z<<MAX_XYZ<<MAX_XYZ;
	return(temp);
}
/***********************************************************************/
/***********************************************************************/
void checkcoords(MAZE *maze, MAZE *room, int *x, int *y, int *z)
{
  *x=(room-maze)&(MAX_XYZ2-1);
  *y=((room-maze)>>MAX_XYZ)&(MAX_XYZ2-1);
  *z=((room-maze)>>MAX_XYZ>>MAX_XYZ)&(MAX_XYZ2-1);
}
/***********************************************************************/
/***********************************************************************/
MAZE2 getroom(MAZE* maze, int x, int y, int z)
{
  MAZE2 roominfo;
  MAZE  *room;
  roominfo.x=x;
  roominfo.y=y;
  roominfo.z=z;
  room=checkroom(maze,x,y,z);
  roominfo.spec=room->spec;
  roominfo.west=room->west;
  roominfo.north=room->north;
  roominfo.down=room->down;
  room=checkroom(maze,x,y,z+1);
  roominfo.up=room->down; 
  room=checkroom(maze,x,y+1,z);
  roominfo.south=room->north; 
  room=checkroom(maze,x+1,y,z);
  roominfo.east=room->west; 
  return roominfo;
}
/***********************************************************************/
/***********************************************************************/
void putroom(MAZE *maze,MAZE2 roominfo)
{
  MAZE *room;
  room=checkroom(maze,roominfo.x,roominfo.y,roominfo.z);
  room->spec=roominfo.spec;
  room->west=roominfo.west;
  room->north=roominfo.north;
  room->down=roominfo.down;
  room=checkroom(maze,roominfo.x,roominfo.y,roominfo.z+1);
  room->down=roominfo.up;
  room=checkroom(maze,roominfo.x,roominfo.y+1,roominfo.z);
  room->north=roominfo.south;
  room=checkroom(maze,roominfo.x+1,roominfo.y,roominfo.z);
  room->west=roominfo.east;
}
/***********************************************************************/
/***********************************************************************/
int init_screen(void)
{
    int counter;
	sc_data.view_adr=sc_data.draw_adr=NULL;
    graf_mouse(256,0);
	sc_data.view_adr=(unsigned short int *)Malloc(256000);
	sc_data.draw_adr=sc_data.view_adr; /*(unsigned short int *)Malloc(128000);*/
	if(sc_data.draw_adr==NULL)
	  return(FALSE);
	for(counter=NOLL;counter<=200;counter++)
	  hline(NOLL,counter,319,BLACK);
	sc_data.old_view=Physbase();
	sc_data.old_draw=Logbase();
	Setscreen(sc_data.draw_adr,sc_data.draw_adr,-1);
	sc_data.old_screen=Vsetmode(BPS16);
    return(TRUE);
}
/***********************************************************************/
/***********************************************************************/
void deinit_screen(void)
{
	Vsetmode(sc_data.old_screen);
	Setscreen(sc_data.old_view,sc_data.old_draw,-1);
	if(sc_data.view_adr!=NULL)
		Mfree(sc_data.view_adr),sc_data.view_adr=NULL;
	if(sc_data.draw_adr!=NULL)
		Mfree(sc_data.draw_adr),sc_data.view_adr=NULL;
	graf_mouse(257,0);
}

/***********************************************************************/
/***********************************************************************/
void plot(int x,int y,int col)
{
	sc_data.draw_adr[x+(y<<6)+(y<<8)]=col;
}

/***********************************************************************/
/***********************************************************************/
void cplot(int x,int y,int r,int g,int b)
{
	sc_data.draw_adr[x+(y<<6)+(y<<8)]=(r<<11)|(g<<5)|b;
}

/***********************************************************************/
/***********************************************************************/
void hline(int x1,int y,int x2,int col)
{
	for(;x1<=x2;x1++)
	  sc_data.draw_adr[x1+(y<<6)+(y<<8)]=col;
}
/***********************************************************************/
/***********************************************************************/
void vline(int x,int y1,int y2,int col)
{
	for(;y1<=y2;y1++)
	  sc_data.draw_adr[x+(y1<<6)+(y1<<8)]=col;
}
/***********************************************************************/
/***********************************************************************/
void dline(int x0,int y0,int x1,int y1,int col)
{
	plot(x0,y0,col);
	plot(x0+1,y0,col);
	plot(x0,y0+1,col);
	plot(x0-1,y0,col);
	plot(x0,y0-1,col);

	plot(x1,y1,col);
	plot(x1+1,y1,col);
	plot(x1,y1+1,col);
	plot(x1-1,y1,col);
	plot(x1,y1-1,col);
}
/***********************************************************************/
/***********************************************************************/
void fbox(int x,int y,int w,int h,int col)
{
    int x1,y1,w1,h1;
	for(w1=w,x1=x;w1>0;x1++,w1--)
		for(h1=h,y1=y;h1>0;y1++,h1--)
			sc_data.draw_adr[x1+(y1<<6)+(y1<<8)]=col;
}

/***********************************************************************/
/***********************************************************************/
void fcbox(int x,int y,int w,int h,int r,int g,int b)
{
    int x1,y1,w1,h1;
	for(w1=w,x1=x;w1>0;x1++,w1--)
		for(h1=h,y1=y;h1>0;y1++,h1--)
			sc_data.draw_adr[x1+(y1<<6)+(y1<<8)]=(r<<11)|(g<<5)|b;
}

/***********************************************************************/
/***********************************************************************/
void texture(BOX *box,char *texture)
{
  dline(box->x0,box->y0,box->x1,box->y1,WHITE);
  dline(box->x1,box->y1,box->x2,box->y2,WHITE);
  dline(box->x2,box->y2,box->x3,box->y3,WHITE);
  dline(box->x3,box->y3,box->x0,box->y0,WHITE);
}

/***********************************************************************/
/***********************************************************************/
void clear_maze(MAZE *maze)
{
	int x,y,z,max=MAX_XYZ2-1;
    MAZE *pointer=maze;
	for(x=NOLL;x<=max;x++)
		for(y=NOLL;y<=max;y++)
			for(z=NOLL;z<=max;z++)
            {
              pointer->west=WALL_T1;
              pointer->north=WALL_T1;
              pointer->down=WALL_T1;
              pointer->spec=NOLL;
              pointer++;
            }
}
/***********************************************************************/
/***********************************************************************/
#define MAX_UP    12
#define MIN_UP    12
#define MAX_DOWN  11
#define MIN_DOWN  11
#define MAX_RIGHT 10
#define MIN_RIGHT 10
#define MAX_LEFT  9
#define MIN_LEFT  9
#define MAX_CORR  8
#define MIN_CORR  8
MAZE *move_forward(MAZE *,int *, int *, int *, int);
void turn_left(int *);
void turn_right(int *);
void turn_up(int *);
void turn_down(int *);
/***********************************************************************/
void random_maze(MAZE *maze,int threedee)
{
  int x=NOLL,y=NOLL,z=NOLL;
  MAZE *old_room=maze,*new_room;
  MAZE2 roominfo,connections[MAX_CONN+1];
  int d,old_d, slump;
  int Finnished=FALSE;
  
  y=(MAX_XYZ2>>1)-1;
  if(threedee)
    z=(MAX_XYZ2>>1)-1;
  new_room=checkroom(maze,x,y,z);
  memset(connections,0,sizeof(connections));

  /* Set start coordinate 1 */
  if(threedee)
    roominfo=getroom(maze,0,(MAX_XYZ2>>1)-1,(MAX_XYZ2>>1)-1);
  else
    roominfo=getroom(maze,0,(MAX_XYZ2>>1)-1,0);
  roominfo.east=2;
  roominfo.north=2;
  roominfo.south=2;
  roominfo.west=3;
  if(threedee)
  {
    roominfo.down=2;
    roominfo.up=2;
  }
  roominfo.used=TRUE;
  connections[0]=roominfo;
  putroom(maze,roominfo);

  /* Set start coordinate 2 */
  if(threedee)
    roominfo=getroom(maze,(MAX_XYZ2>>1)-1,0,(MAX_XYZ2>>1)-1);
  else
    roominfo=getroom(maze,(MAX_XYZ2>>1)-1,0,0);
  roominfo.east=2;
  roominfo.west=2;
  roominfo.south=2;
  roominfo.north=3;
  if(threedee)
  {
    roominfo.down=2;
    roominfo.up=2;
  }
  roominfo.used=TRUE;
  connections[1]=roominfo;
  putroom(maze,roominfo);

  /* Set start coordinate 3 */
  if(threedee)
    roominfo=getroom(maze,(MAX_XYZ2>>1)-1,(MAX_XYZ2-2),(MAX_XYZ2>>1)-1);
  else
    roominfo=getroom(maze,(MAX_XYZ2>>1)-1,(MAX_XYZ2-2),0);
  roominfo.east=2;
  roominfo.west=2;
  roominfo.north=2;
  roominfo.south=3;
  if(threedee)
  {
    roominfo.down=2;
    roominfo.up=2;
  }
  roominfo.used=TRUE;
  connections[2]=roominfo;
  putroom(maze,roominfo);

  /* Set start coordinate 4 */
  if(threedee)
    roominfo=getroom(maze,MAX_XYZ2-2,(MAX_XYZ2>>1)-1,(MAX_XYZ2>>1)-1);
  else
    roominfo=getroom(maze,MAX_XYZ2-2,(MAX_XYZ2>>1)-1,0);
  roominfo.south=2;
  roominfo.west=2;
  roominfo.north=2;
  roominfo.east=3;
  if(threedee)
  {
    roominfo.down=2;
    roominfo.up=2;
  }
  roominfo.used=TRUE;
  connections[3]=roominfo;
  putroom(maze,roominfo);
  slump=0;
  d=D_EAST;
//Vsetmode(sc_data.old_screen);
//Setscreen(sc_data.old_view,sc_data.old_draw,-1);
  while(!Finnished)
  {
//printf("slump=%d",slump);
    if((slump>=MIN_CORR)&&(slump<=MAX_CORR))
    {
      int trest=FALSE,c,slumping=0;
      slumping=rand()%(1<<6-1)+1;
      for(c=0; c<=MAX_CONN; c++)
      {
        if(!connections[c].used)
        {
          roominfo=getroom(maze,x,y,z);
          if((roominfo.north==1)&&(y>0)&&(slumping&1))
            roominfo.north=2,trest=TRUE;
          if((roominfo.west==1)&&(x>0)&&(slumping&2))
            roominfo.west=2,trest=TRUE;
          if((roominfo.south==1)&&(y<MAX_XYZ2-2)&&(slumping&4))
            roominfo.south=2,trest=TRUE;
          if((roominfo.east==1)&&(x<MAX_XYZ2-2)&&(slumping&8))
            roominfo.east=2,trest=TRUE;
          if(threedee)
          {
            if((roominfo.down==1)&&(z>0)&&(slumping&16))
              roominfo.down=2,trest=TRUE;
            if((roominfo.up==1)&&(z<MAX_XYZ2-2)&&(slumping&32))
              roominfo.up=2,trest=TRUE;
          }
          if(trest)
            roominfo.used=TRUE;
          putroom(maze,roominfo);
          connections[c]=roominfo;
          break;
        }
      }
      while((slump>=MIN_CORR)&&(slump<=MAX_CORR))
      {
        if(threedee)
          slump=rand()%(MAX_UP+1);
        else
          slump=rand()%(MAX_RIGHT+1);
      }
    }
    if((slump>=MIN_UP)&&(slump<=MAX_UP))
    {
      old_d=d;
      turn_up(&d);
      old_room=new_room;
      new_room=move_forward(maze,&x,&y,&z,d);
      if(new_room==old_room)
        d=old_d;
    }  
    else if((slump>=MIN_DOWN)&&(slump<=MAX_DOWN))
    {
      old_d=d;
      turn_down(&d);
      old_room=new_room;
      new_room=move_forward(maze,&x,&y,&z,d);
      if(new_room==old_room)
        d=old_d;
    }
    else if((slump>=MIN_RIGHT)&&(slump<=MAX_RIGHT))
    {
      old_d=d;
      turn_right(&d);
      old_room=new_room;
      new_room=move_forward(maze,&x,&y,&z,d);
      if(new_room==old_room)
        d=old_d;
    }
    else if((slump>=MIN_LEFT)&&(slump<=MAX_LEFT))
    {
      old_d=d;
      turn_left(&d);
      old_room=new_room;
      new_room=move_forward(maze,&x,&y,&z,d);
      if(new_room==old_room)
        d=old_d;
    }
    else
    {
      new_room=move_forward(maze,&x,&y,&z,d);
    }
    if(threedee)
      slump=rand()%(MAX_UP+1);
    else
      slump=rand()%(MAX_RIGHT+1);
    if(kbhit())
    {
      Finnished=TRUE;
    }
    if(new_room->spec>1)
    {
      int c=0,trest=FALSE;
      new_room=0;
      for(c=0; c<=MAX_CONN; c++)
      {
        if(connections[c].used)
        {
          x=connections[c].x;
          y=connections[c].y;
          z=connections[c].z;
          roominfo=getroom(maze,x,y,z);
          new_room=checkroom(maze,x,y,z);
          trest=FALSE;
          if(roominfo.north==2)
          {
            d=D_NORTH;
            trest=TRUE;
          }
          if(roominfo.west==2)
          {
            d=D_WEST;
            trest=TRUE;
          }
          if(roominfo.south==2)
          {
            d=D_SOUTH;
            trest=TRUE;
          }
          if(roominfo.east==2)
          {
            d=D_EAST;
            trest=TRUE;
          }
          if((roominfo.up==2)&&(threedee))
          {
            d=D_UP;
            trest=TRUE;
          }
          if((roominfo.down==2)&&(threedee))
          {
            d=D_DOWN;
            trest=TRUE;
          }
          if(!trest)
          {
            connections[c].used=FALSE;
          }
          putroom(maze,roominfo);
          slump=0;
          break;
        }
      }
      if(!new_room)
        Finnished=TRUE;
    }
  }
  new_room=maze;
  for(x=NOLL;x<MAX_XYZ2;x++)
    for(y=NOLL;y<MAX_XYZ2;y++)
      for(z=NOLL;z<MAX_XYZ2;z++)
      {
//        new_room->spec=NOLL;
        new_room++;
      }

}

/***********************************************************************/
/***********************************************************************/
MAZE* move_forward(MAZE *maze,int *x, int *y, int *z,int d)
{
  MAZE *new_room=0,*old_room=0;
  old_room=checkroom(maze,*x,*y,*z);
  new_room=old_room;
  switch(d)
  {
    case D_NORTH:
      if(*y>0)
      {
        new_room=checkroom(maze,*x,*y-1,*z);
        old_room->north=0;
        (*y)--;
      }
      break;
    case D_WEST:
      if(*x>0)
      {
        new_room=checkroom(maze,*x-1,*y,*z);
        old_room->west=0;
        (*x)--;
      }
      break;
    case D_DOWN:
      if(*z>0)
      {
        new_room=checkroom(maze,*x,*y,*z-1);
        old_room->down=0;
        (*z)--;
      }
      break;
   case D_SOUTH:
      if(*y<MAX_XYZ2-2)
      {
        new_room=checkroom(maze,*x,*y+1,*z);
        new_room->north=0;
        (*y)++;
      }
      break;
    case D_EAST:
      if(*x<MAX_XYZ2-2)
      {
        new_room=checkroom(maze,*x+1,*y,*z);
        new_room->west=0;
        (*x)++;
      }
      break;
    case D_UP:
      if(*z<MAX_XYZ2-2)
      {
        new_room=checkroom(maze,*x,*y,*z+1);
        new_room->down=0;
        (*z)++;
      }
      break;
  }
  if(new_room!=old_room)
  {
    new_room->spec++;
    old_room->spec++;
  }
  return new_room;
}
/***********************************************************************/
void turn_left(int *d)
{
  switch(*d)
  {
    case D_NORTH:   *d=D_WEST;   break;
    case D_WEST:    *d=D_SOUTH;  break;
    case D_SOUTH:   *d=D_EAST;   break;
    case D_EAST:    *d=D_NORTH;  break;
    case D_UP:
    case D_DOWN:    *d=D_WEST;   break;
  }
}
/***********************************************************************/
void turn_right(int *d)
{
  switch(*d)
  {
    case D_NORTH:   *d=D_EAST;   break;
    case D_WEST:    *d=D_NORTH;  break;
    case D_SOUTH:   *d=D_WEST;   break;
    case D_EAST:    *d=D_SOUTH;  break;
    case D_UP:
    case D_DOWN:    *d=D_EAST;   break;
  }
}
/***********************************************************************/
void turn_up(int *d)
{
  switch(*d)
  {
    case D_NORTH:
    case D_WEST:
    case D_SOUTH:
    case D_EAST:    *d=D_UP;     break;
    case D_UP:      *d=D_NORTH;  break;
    case D_DOWN:    *d=D_SOUTH;  break;
  }
}
/***********************************************************************/
void turn_down(int *d)
{
  switch(*d)
  {
    case D_NORTH:
    case D_WEST:
    case D_SOUTH:
    case D_EAST:    *d=D_DOWN;   break;
    case D_UP:      *d=D_NORTH;  break;
    case D_DOWN:    *d=D_SOUTH;  break;
  }
}

/***********************************************************************/
/* view_maze(...)  visar labyrinten i "3D"                             */
/***********************************************************************/
void view_maze(MAZE *maze,int threedee)
{
/*
  int x=0,y=0,z=0,dir=0;

  y=(MAX_XYZ2>>1)-1;
  if(threedee)
    z=(MAX_XYZ2>>1)-1;

  create_viewlist()
  calculate_points()
  calculate_visible();
*/  
}