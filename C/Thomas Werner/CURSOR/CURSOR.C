/*----------------------------------------------------------------*/
/*							Routine zur (Grafik-)Text-Eingabe 								*/
/*																																*/
/* Originalroutine in GFA-BASIC von Tom Quellenberg 							*/
/* C-Konvertierung: Thomas Werner																	*/
/* (c) 1992 Maxon Computer GmbH																		*/
/*----------------------------------------------------------------*/

#include <aes.h>
#include <vdi.h>


typedef enum
{
    FALSE,
    TRUE
}
boolean;


extern	int	handle;

int		Cd_x, Cd_y, Xpos, Ypos, C_x, C_y, X, Y;


/*----------------------------------------------------------------*/
/*	Parameter:																										*/
/*				Modus: Ausgabemodus fr Text														*/
/*----------------------------------------------------------------*/

void Gem_Text(int Modus)
{
	int		k, d, Stelle, x1, y1;
	char	Z, Text[100];
	
	void	Cursor(void);
	void	Zeichengroesse(void);

	Zeichengroesse();
  vsf_color(handle, 1);
	vsf_interior(handle,FIS_SOLID);
	vsf_perimeter(handle, 0);
	vswr_mode(handle, MD_XOR);
	graf_mouse(ARROW,0);
	do
	{
		graf_mkstate(&Xpos, &Ypos, &k, &d);
		graf_mouse(M_OFF,0);
		Cursor();
		graf_mouse(M_ON,0);
	
		do
		{
			do
				graf_mkstate(&x1, &y1, &k, &d);
			while ((!(k&1)) && (!(k&2)) && (x1 == Xpos) && (y1 == Ypos));
			
			graf_mouse(M_OFF,0);
			Cursor();
			graf_mouse(M_ON,0);
			Xpos = x1;
			Ypos = y1;
			graf_mouse(M_OFF,0);
			Cursor();
			graf_mouse(M_ON,0);
		} while ((!(k&1)) && (!(k&2)));
		
		graf_mouse(M_OFF,0);
		Cursor();
		if (!(k&2))
		{
			Stelle = 0;
			Text[Stelle] = 0;
			do
			{
				Cursor();
				Z = (char) evnt_keybd() & 0x00ff;
				Cursor();
				if ((Z != 13) && (Z != 0) && (Z != 8))
				{
					Text[Stelle++] = Z;
					Text[Stelle] = 0;
					v_gtext(handle, Xpos, Ypos, &Text[Stelle-1]);
					Xpos += X;
					Ypos += Y;
				}
				if ((Z == 8) && (Stelle > 0))
				{
					Xpos -= X;
					Ypos -= Y;
					v_gtext(handle, Xpos, Ypos, &Text[Stelle-1]);
					Text[--Stelle] = 0;
				}
			} while (Z != 13);
			if (Stelle > 0)
			{
				vswr_mode(handle, Modus);
				for (--Stelle; Stelle >= 0; Stelle--)
				{
					Xpos -= X;
					Ypos -= Y;
					v_gtext(handle, Xpos, Ypos, &Text[Stelle]);
					Text[Stelle] = 0;
				}
				vswr_mode(handle, MD_XOR);
			}
		}
		graf_mouse(M_ON,0);
	} while (!(k&2));
	
	vswr_mode(handle, MD_REPLACE);
	vsf_perimeter(handle, 1);
}


void	Cursor(void)
{
	int		xy[10];
	
	xy[0] = Xpos+Cd_x;
	xy[1] = Ypos+Cd_y;
	xy[2] = Xpos+Cd_x+C_x;
	xy[3] = Ypos+Cd_y;
	xy[4] = Xpos+Cd_x+C_x;
	xy[5] = Ypos+Cd_y+C_y;
	xy[6] = Xpos+Cd_x;
	xy[7] = Ypos+Cd_y+C_y;
	xy[8] = Xpos+Cd_x;
	xy[9] = Ypos+Cd_y;
	
	v_pline(handle, 5, xy);
}


void	Zeichengroesse(void)
{
	int	attr[10];
	
	
	vqt_attributes(handle,attr);
	
	switch(attr[2])
	{
		case 0:
				X = attr[8];
				Y = 0;
				C_x = X - 1;
				C_y = -attr[9] + 1;
				Cd_x = 0;
				Cd_y = attr[9] - attr[7] - 1; 
		break;
		
		case 900:
				X = 0;
				Y = -attr[8];
				C_x = -attr[9] + 1;
				C_y = Y + 1;
				Cd_x = attr[9] - attr[7] - 1;
				Cd_y = 0; 
		break;

		case 1800:
				X = -attr[8];
				Y = 0;
				C_x = X + 1;
				C_y = attr[9] - 1;
				Cd_x = 0;
				Cd_y = -(attr[9] - attr[7]) + 1; 
		break;
		
		case 2700:
				X = 0;
				Y = attr[8];
				C_x = attr[9] - 1;
				C_y = Y - 1;
				Cd_x = -(attr[9] - attr[7]) + 1;
				Cd_y = 0; 
		break;
	}
}