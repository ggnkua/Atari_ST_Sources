// ### Winlaby: Zeichen-Funktionen ###

#include <aes.h>
#include <vdi.h>

/* Externe Variablen: */
extern int xy[];
extern int vhandle;
extern GRECT wnd;
extern int xpos, ypos;
extern int zielx, ziely;
extern unsigned char orttyp[21][21];
extern int richtung;
extern int pmode;

/* ****Diese Funktion zeichnet eine Seitenwand des Ganges**** */
void draw_wall(int z, int lr, int mx, int my, int x_b, int y_h)
{
 x_b=x_b*3/2 ; y_h=y_h*3/2;
 xy[0]=mx+lr*x_b/z		; xy[1]=my-y_h/z;
 xy[2]=xy[0]				; xy[3]=my+y_h/z;
 xy[4]=mx+lr*x_b/(z+1) ; xy[5]=my+y_h/(z+1);
 xy[6]=xy[4]				; xy[7]=my-y_h/(z+1);
 xy[8]=xy[0]				; xy[9]=xy[1];
 switch(pmode)
  {
   case 1: v_pline(vhandle,5,xy); break;
   case 2: v_fillarea(vhandle,5,xy); break;
  }
}


/* ****Nun kommt die Funktion, die einen Seitengang zeichnet**** */
void draw_corridor(int z, int lr, int mx, int my, int x_b, int y_h)
{
 x_b=x_b*3/2 ; y_h=y_h*3/2;
 xy[0]=mx+lr*x_b/z		; xy[1]=my-y_h/(z+1);
 xy[2]=mx+lr*x_b/(z+1) ; xy[3]=xy[1];
 xy[4]=xy[2]				; xy[5]=my+y_h/(z+1);
 xy[6]=xy[0]				; xy[7]=xy[5];
 switch(pmode)
  {
   case 1: v_pline(vhandle,4,xy); break;
   case 2: v_fillarea(vhandle,4,xy); break;
  }
}


/* ****Labyausgang zeichnen**** */
void draw_exit(int z, int mx, int my, int x_b, int y_h)
{
 x_b=x_b*3/2 ; y_h=y_h*3/2;
 xy[0]=mx+x_b/z		; xy[1]=my+y_h/z;
 xy[2]=mx+x_b/(z+1) ; xy[3]=my+y_h/(z+1);
 xy[4]=mx-x_b/(z+1) ; xy[5]=xy[3];
 xy[6]=mx-x_b/z		; xy[7]=xy[1];
 vsf_interior(vhandle,2); vsf_style(vhandle,1);
 v_fillarea(vhandle,4,xy);
 vsf_interior(vhandle,0); vsf_style(vhandle,0);
}


/* ****Labyrinth zeichnen, Hauptfunktion**** */
void draw_laby()
{
 int wand_z=0; 			/* Variable fÅr LÑnge des Ganges */
 int i;					/* ZÑhlvariable	  */
 int mx,my,max_w,max_h;

 switch(pmode)			/* Fenster lîschen */
  {
   case 1:
	  xy[0]=wnd.g_x;			xy[1]=wnd.g_y;
	  xy[2]=wnd.g_x+wnd.g_w-1;	xy[3]=wnd.g_y+wnd.g_h-1;
	  v_bar(vhandle,xy);
	  break;
   case 2:
	  vsf_interior(vhandle,2); vsf_style(vhandle,2); vsf_color(vhandle,2);
	  xy[0]=wnd.g_x;			xy[1]=wnd.g_y;
	  xy[2]=wnd.g_x+wnd.g_w-1;	xy[3]=wnd.g_y+wnd.g_h/2;
	  v_bar(vhandle,xy);
	  vsf_interior(vhandle,2); vsf_style(vhandle,6); vsf_color(vhandle,3);
	  xy[1]=wnd.g_y+wnd.g_h/2 ;	xy[3]=wnd.g_y+wnd.g_h-1;
	  v_bar(vhandle,xy);
	  break;
  }

 max_w=wnd.g_w/2; 	max_h=wnd.g_h/2;
 mx=wnd.g_x+max_w;	my=wnd.g_y+max_h;

 vsf_color(vhandle,1); vsf_interior(vhandle,0); vsf_style(vhandle,0);

 /*--- Gang zeichnen ---*/
 switch(richtung)
 {
  case 1:
	 for(i=ypos;i>0;i--)
	  {
		wand_z++;
		if(orttyp[xpos][i]==1) break;
		if(xpos==zielx && i==ziely)  draw_exit(wand_z,mx,my,max_w,max_h);
		switch(orttyp[xpos-1][i])
		 {
		  case 1: draw_wall(wand_z, -1, mx, my, max_w, max_h); break;
		  default: draw_corridor(wand_z, -1, mx, my, max_w, max_h); break;
		 }
		switch(orttyp[xpos+1][i])
		 {
		  case 1: draw_wall(wand_z, 1, mx,my,max_w,max_h); break;
		  default: draw_corridor(wand_z, 1, mx,my,max_w,max_h); break;
		 }
	  }
	 break;
  case 2:
	 for(i=xpos;i<=20;i++)
	  {
		wand_z++;
		if(orttyp[i][ypos]==1)	break;
		if(ypos==ziely && i==zielx)  draw_exit(wand_z,mx,my,max_w,max_h);
		switch(orttyp[i][ypos-1])
		 {
		  case 1: draw_wall(wand_z, -1, mx,my,max_w,max_h); break;
		  default: draw_corridor(wand_z, -1, mx,my,max_w,max_h); break;
		 }
		switch(orttyp[i][ypos+1])
		 {
		  case 1: draw_wall(wand_z, 1, mx,my,max_w,max_h); break;
		  default: draw_corridor(wand_z,1, mx,my,max_w,max_h); break;
		 }
	  }
	 break;
  case 3:
	 for(i=ypos;i<=20;i++)
	  {
		wand_z++;
		if(orttyp[xpos][i]==1)	break;
		if(xpos==zielx && i==ziely)  draw_exit(wand_z,mx,my,max_w,max_h);
		switch(orttyp[xpos+1][i])
		 {
		  case 1: draw_wall(wand_z, -1, mx,my,max_w,max_h); break;
		  default: draw_corridor(wand_z, -1, mx,my,max_w,max_h); break;
		 }
		switch(orttyp[xpos-1][i])
		 {
		  case 1: draw_wall(wand_z, 1, mx,my,max_w,max_h); break;
		  default: draw_corridor(wand_z, 1, mx,my,max_w,max_h); break;
		 }
	  }
	 break;
  case 4:
	 for(i=xpos;i>0;i--)
	  {
		wand_z++;
		if(orttyp[i][ypos]==1)	break;
		if(ypos==ziely && i==zielx)  draw_exit(wand_z,mx,my,max_w,max_h);
		switch(orttyp[i][ypos+1])
		 {
		  case 1: draw_wall(wand_z, -1, mx,my,max_w,max_h); break;
		  default: draw_corridor(wand_z, -1, mx,my,max_w,max_h); break;
		 }
		switch(orttyp[i][ypos-1])
		 {
		  case 1: draw_wall(wand_z, 1, mx,my,max_w,max_h); break;
		  default: draw_corridor(wand_z, 1, mx,my,max_w,max_h); break;
		 }
	  }
	 break;
 }

 xy[0]=mx-max_w*3/2/wand_z;
 xy[1]=my-max_h*3/2/wand_z;	/* Koordinaten fÅr Gangende ausrechnen */
 xy[2]=mx+max_w*3/2/wand_z;
 xy[3]=my+max_h*3/2/wand_z;
 v_bar(vhandle,xy);			/* Gangende zeichnen */
}
