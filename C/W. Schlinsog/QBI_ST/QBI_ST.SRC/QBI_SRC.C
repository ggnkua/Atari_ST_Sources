
/*-------------------------------------------- Gem_Frame -----------------*/
int work_in[128],
    work_out[128];
int handle,
    phys_handle;
int gl_hchar,
    gl_wchar,
    gl_hbox,
    gl_wbox;
int gl_apid;
int xy[4];
typedef enum
	{
    FALSE,
    TRUE
	}
	boolean;
/*------------------------------------------------------------------*/
int Res_x,Res_y;							/* Bildschirm_Maže */
int Z_b,Z_h,B_b,B_h;						/* Zeichensatz_Maže */
int M_col;
int C_planes;
/*------------------------------------------- include --------------------*/

#include <vdi.h>
#include <aes.h>
#include <stdio.h>
#include <stdlib.h>
# include <math.h>
# include <tos.h>
# include <ext.h>
/*-----------------------------------------------------------------*/
/*--------------------------------------- Standard GEM_Frame ---------*/
boolean open_vwork( void )
	{
   	register int i;
   	if (( gl_apid = appl_init() ) != -1 )
   		{
      	for ( i = 1; i < 103; work_in[i++] = 1 );
      	work_in[10] = 2;
      	phys_handle = graf_handle( &gl_wchar, &gl_hchar, &gl_wbox, &gl_hbox );
      	work_in[0]  = handle = phys_handle;
      	v_opnvwk( work_in, &handle, work_out );
      	return ( TRUE );
   		}
   else
      	return ( FALSE );
	}
void close_vwork( void )
	{
   	v_clsvwk( handle );
   	appl_exit( );
	}
/*------------------------------------- Standard GEM_Routinen --------- */
void mouseon(void)
	{
	v_show_c(handle,1);
	}	
void mouseoff(void)
	{
	v_hide_c(handle);
	}		
void mouseform(int form)
	{
	graf_mouse(form,0);
	}
int fillcolor(int color)
	{
	vsf_interior(handle,1);                 
	return(vsf_color(handle,color));
	}
int fillstyle(int muster,int schraffur)
	{
	if(schraffur)
		{
		vsf_interior(handle,3);
		return(vsf_style(handle,muster));             /* 1 - 12   		*/
		}
	else
		{
		vsf_interior(handle,2);
		return(vsf_style(handle,muster));             /* 1 - 24   		*/
		}
	}
int umrandung(int mode)
	{
	return(vsf_perimeter(handle,mode));
	}
void pbox(int x,int y,int wx,int wy)
	{
	int pb_xy[4];
	
	pb_xy[0] = x;
	pb_xy[1] = y;
	pb_xy[2] = x+wx;
	pb_xy[3] = y+wy;
	v_bar(handle,pb_xy);
	}	
void mode(int mode)
	{
	vswr_mode(handle,mode);
	}
/*------------------------------------- Standard DSP_Routinen --------*/

# define Dsp_GetWordSize()			(int)xbios(96+7)	
# define Dsp_DoBlock(a,b,c,d)		(void)xbios(96,a,b,c,d)
# define Dsp_BlkUnpacked(a,b,c,d)	(void)xbios(96+2,a,b,c,d) 
# define Dsp_BlkWords(a,b,c,d)		(void)xbios(96+27,a,b,c,d) 
# define Dsp_BlkBytes(a,b,c,d)		(void)xbios(96+28,a,b,c,d) 
# define Dsp_BlkHandshake(a,b,c,d)	(void)xbios(96+1,a,b,c,d) 
# define Dsp_InStream(a,b,c,d)		(void)xbios(96+3,a,b,c,d) 
# define Dsp_OutStream(a,b,c,d)		(void)xbios(96+4,a,b,c,d) 
# define Dsp_IOStream(a,b,c,d,e,f)	(void)xbios(96+5,a,b,c,d,e,f) 
# define Dsp_RemoveInterrupts(a)	(void)xbios(96+6,a) 
# define Dsp_HStat()				(char)xbios(96+29) 
# define Dsp_SetVectors(a,b)		(void)xbios(96+30,a,b) 
# define Dsp_Hf0(a)					(int)xbios(96+23,a) 
# define Dsp_Hf1(a)					(int)xbios(96+24,a) 
# define Dsp_Hf2()					(int)xbios(96+25) 
# define Dsp_Hf3()					(int)xbios(96+26) 
# define Dsp_Lock()					(int)xbios(96+8) 
# define Dsp_Unlock()				(void)xbios(96+9) 
# define Dsp_Available(a,b)			(void)xbios(96+10,a,b) 
# define Dsp_Reserve(a,b)			(int)xbios(96+11,a,b) 
# define Dsp_RequestUniqueAbility()	(int)xbios(96+17) 
# define Dsp_GetProgAbility()		(int)xbios(96+18) 
# define Dsp_LoadProg(a,b,c)		(int)xbios(96+12,a,b,c) 
# define Dsp_LodToBinary(a,b)		(long)xbios(96+15,a,b) 
# define Dsp_ExecProg(a,b,c)		(void)xbios(96+13,a,b,c) 
# define Dsp_ExecBoot(a,b,c)		(void)xbios(96+14,a,b,c) 
# define Dsp_LoadSubroutine(a,b,c)	(int)xbios(96+20,a,b,c) 
# define Dsp_InqSubrAbility(a)		(int)xbios(96+21,a) 
# define Dsp_FlushSubroutines()		(void)xbios(96+19) 
# define Dsp_RunSubroutines(a)		(int)xbios(96+22,a) 
# define Dsp_TriggerHC(a)			(void)xbios(96+16,a)
/*-----------------------------------------------------------------*/
/*------------------------------------------------Globals QBIST ---*/	
# define NUM_TRANSFORMS 	36
# define NUM_REGISTERS 		6
# define TOTAL_TRANSFORMS	9
# define PIXELS_PER_RUN		400

int Dsp_word_size		= 0;

typedef struct
	{
	float x,y,z;
	}
	Vector;

typedef struct
	{
	int v,h;
	}
	Point;

typedef void Transform(Vector *source,Vector *control,Vector *dest);
Transform *(TransformList[TOTAL_TRANSFORMS]);

short TransformSequence[9][NUM_TRANSFORMS],
	  Source[9][NUM_TRANSFORMS],
	  Control[9][NUM_TRANSFORMS],
	  Dest[9][NUM_TRANSFORMS];

Vector **Reg/*[NUM_REGISTERS]*/;		/* wird von allen 9 Bildern benutzt */

short Gx,Gy,GVariation;					/* fr asynchrones draw */

short Coarseness = 2;					/* medium */
Point Position[] = {{1,1},{0,0},{1,0},{2,0},
					{2,1},{2,2},{1,2},{0,2},{0,1}};
boolean Ready;
int PicWidth,
	PicHeight;

int *Rot,*Gruen,*Blau,*Tab_sum;

struct grauwert
	{
	int a,b;
	}
	Grw[12] = {{8,0},{7,0},{6,0},{5,0},{4,0},{3,0},{2,0},
				{1,0},{15,0},{15,0},{15,0},{15,0}};

int Fuellmuster[16][16];

long *Sintab;
/*-------------------------------------- DSP Variablen --------*/	
char Sin_cmd[4]  = { 0x00, 0x00, 0x04, 0 }; 
char Gvar_cmd[4] = { 0x00, 0x00, 0x02, 0 };      
char Trsf_cmd[4] = { 0x00, 0x00, 0x01, 0 };      
char Recv_cmd[4] = { 0x00, 0x01, 0x00, 0 };      

long O_x,								/* plotte vorherige Position */
	 O_y;
unsigned long int Rand_next = 1;
	 
/*------------------------------------------------ DSP -----------*/	
int set_dsp_prg(int ability,char *lod_file);
void dsp_exit(void);
int dsp_init(long *x_available,long *y_available);	/* ret: dsp_word_size */

int send_dsp_gVar(int variation);
/*------------------------------------------------ QBIST ---------*/	
void draw(boolean fromStart);
void initBaseTransform(void);
void initTransforms(void);
void makeVariations(int basevar);
void plot_9(int int_x,int int_y,int farbe,int c_planes,
								int *scrn_base,int blk_w,int blk_h);
int get_color(int int_x,int int_y,int c_planes,
								int *scrn_base,int blk_w,int blk_h);
int myrand(void);
void mysrand(unsigned int seed);

double wandle32(long h32);
long make32(double dh);

int initSintab(void);
int fuellmuster_init(void);

int get_col_number(int *rogrbl);
int save_pic(char *R_pfad_name);	
int open_pic(char *R_pfad_name);
/*---------------------------------------------------------------*/	
void main( void )
	{                                  /* .... Deklarationen .......*/

	int i;
	int work_o[128];
	int rgb[8];
	
/* .............................................. GEM Start .........*/
  	if ( open_vwork( ) == FALSE )
  		{
    	fprintf( stderr, "Fehler bei der Programminitialisierung!" );
    	exit ( -1 );
 		}
/* .............................................. Globale ..........*/
  	Res_x = work_out[0];
  	Res_y = work_out[1];
  	
	Z_h = gl_hbox;
	Z_b = gl_wbox;
	
/* .............................................. Programm ..........*/

		mouseon();
		mouseform(0);
									/*........... DSP_Init .............*/

		if(set_dsp_prg(-1/*Ability*/,"TRANSFRM.LOD") > 0)
			{
			}
		else
			{
			mouseon();
			form_alert(1,"[2][ | Fehler bei  DSP_Init ! "
						 "| evtl. \"TRANSFRM.LOD\" | nicht gefunden. ]"
   			   	         "[  OK  ]");
			}	
		
		Reg = (Vector **)calloc(NUM_REGISTERS,sizeof(Vector *));
		for(i = 0;i < NUM_REGISTERS;i++)
			Reg[i] = (Vector *)calloc(1,sizeof(Vector));
			
		Sintab	= (long *)calloc(680,sizeof(long));
		if(!Sintab)
			{
			close_vwork();
			exit (-1);
			}
		initSintab();
							
							/* (int *)Sintab, wird in fix_24 gewandelt */
		if(Dsp_word_size)
			{
			Dsp_BlkHandshake((long *)Sin_cmd,1L,NULL,0L);
		    Dsp_BlkWords((int *)Sintab,628L*2L,NULL,0L);
    		}

		
		vq_extnd(handle,1,work_o);
		C_planes = work_o[4];

		if(C_planes == 1)
			fuellmuster_init();

		
		M_col = 1;
		for(i = 0;(i < work_o[4]) && (i < 8);i++)
			{
			M_col *= 2;
			}
		Rot 	= (int *)calloc(M_col+4,sizeof(int));
		Gruen 	= (int *)calloc(M_col+4,sizeof(int));
		Blau 	= (int *)calloc(M_col+4,sizeof(int));
		
		if(!Rot || !Gruen || !Blau )
			{
			if(Dsp_word_size)
				dsp_exit();
			
			close_vwork();
			exit (-1);
			}

		for(i = 0;i < M_col;i++)			/* Farb_werte merken */
			{
			vq_color(handle,i,0,rgb);
			Rot[i] 	 = rgb[0];				/* >>2 -> 0 - 256 Range */
			Gruen[i] = rgb[1];
			Blau[i]  = rgb[2];
			}
		if(work_o[4] > 8)
			{
			M_col = 32000;					/* True_Color */
			}
							/* ..........init ...................*/	

		Coarseness 	= 3;
		PicWidth 	= (Res_x+1)/3;
		PicHeight 	= (Res_y+1)/3;
			
		initTransforms();

		mysrand(1);
		initBaseTransform();
		makeVariations(0);
		
		if(Dsp_word_size)
			send_dsp_gVar(0);				/*.....send_dsp_gVar.....*/
		
		Ready = 1;							
		
		mouseoff();
		draw(1);
		while(!Ready)					/*....... draw_action ..........*/
			{
			draw(0);
			
			if(kbhit())					/* Tastendruck */
				Ready = 1;
			}
		mouseon();
		
		while(!kbhit());
/* ................................................ Menu Ende .....*/

		for(i = 0;i < NUM_REGISTERS;i++)
			{
			free(Reg[i]);
			}
		free(Reg);
		free(Sintab);
		free(Rot);
		free(Gruen);
		free(Blau);
	
		if(Dsp_word_size)
			dsp_exit();
		
/* ................................................ GEM Ende .....*/
	close_vwork( );
	exit ( 0 );
	}
/*.................................................. main end .....*/
/*--------------------------------------------------------------------*/
/*----------------------------------------------- TRANSFORMS ---------*/
/*---------------------------------------------------------------------*/
void projection(Vector *source, Vector *control,Vector *dest)
	{
	float scalarProd;
	
	scalarProd = source->x * control->x +
					source->y * control->y + source->z * control->z;
	dest->x = scalarProd * source->x;
	dest->y = scalarProd * source->y;
	dest->z = scalarProd * source->z;
	}
/*----------------------------------------------------------------*/
void shift(Vector *source, Vector *control,Vector *dest)
	{
	dest->x = source->x + control->x;
	if(dest->x >= 1.0)
		dest->x -= 1.0;
	dest->y = source->y + control->y;
	if(dest->y >= 1.0)
		dest->y -= 1.0;
	dest->z = source->z + control->z;
	if(dest->z >= 1.0)
		dest->z -= 1.0;
	}				
/*----------------------------------------------------------------*/
void shiftBack(Vector *source, Vector *control,Vector *dest)
	{
	dest->x = source->x - control->x;
	if(dest->x <= 0.0)
		dest->x += 1.0;
	dest->y = source->y - control->y;
	if(dest->y <= 0.0)
		dest->y += 1.0;
	dest->z = source->z - control->z;
	if(dest->z <= 0.0)
		dest->z += 1.0;
	}				
/*----------------------------------------------------------------*/
void rotate(Vector *source, Vector *control,Vector *dest)
	{
	dest->x = source->y;
	dest->y = source->z;
	dest->z = source->x;
	}
/*----------------------------------------------------------------*/
void rotate2(Vector *source, Vector *control,Vector *dest)
	{
	dest->x = source->z;
	dest->y = source->x;
	dest->z = source->y;
	}
/*----------------------------------------------------------------*/
void multiply(Vector *source, Vector *control,Vector *dest)
	{
	dest->x = source->x * control->x;
	dest->y = source->y * control->y;
	dest->z = source->z * control->z;
	}
/*----------------------------------------------------------------*/
void sine(Vector *source, Vector *control,Vector *dest)
	{
	dest->x = 0.5 + 0.5 * sin(20.0 * source->x * control->x);
	dest->y = 0.5 + 0.5 * sin(20.0 * source->y * control->y);
	dest->z = 0.5 + 0.5 * sin(20.0 * source->z * control->z);
	}
/*----------------------------------------------------------------*/
void conditional(Vector *source, Vector *control,Vector *dest)
	{
	if(control->x+control->y+control->z > 0.5)
		{
		dest->x = source->x;
		dest->y = source->y;
		dest->z = source->z;
		}
	else
		{
		dest->x = control->x;
		dest->y = control->y;
		dest->z = control->z;
		}
	}
/*----------------------------------------------------------------*/
void complement(Vector *source, Vector *control,Vector *dest)
	{
	dest->x	= 1.0 - source->x;
	dest->y	= 1.0 - source->y;
	dest->z	= 1.0 - source->z;
	}
/*----------------------------------------------------------------*/
/*----------------------------------------------------------------*/
double wandle32(long h32)
	{
	double dh;
	
	dh = (double)h32 / (65536F);
	return(dh);	
	}
/*---------------------------------------------------------------*/	
long make32(double dh)
	{	
	long h;
	
	h = 65536F * dh;
	return(h);
	}		
/*----------------------------------------------------------------*/
int initSintab(void)
	{
	int i;
	float f,addf;
	addf = 0.01002;				/* optimale Aufteilung */
		
	/* dest->x = 0.5 + 0.5 * sin(20.0 * source->x * control->x); */
	/* Sintab[(source->x*control->x)/20*100] */
	
	for(i = 0,f = 0.0;i < 628;i++,f += addf)	
		{
		Sintab[i] = 0x7fffL + make32(0.5 * sin(f));
		}
		
	return(1);	
	}
/*----------------------------------------------------------------*/
void initTransforms(void)
	{
	TransformList[0] = projection;
	TransformList[1] = shift;
	TransformList[2] = shiftBack;
	TransformList[3] = rotate;
	TransformList[4] = rotate2;
	TransformList[5] = multiply;
	TransformList[6] = sine;
	TransformList[7] = conditional;
	TransformList[8] = complement;
	}
/*----------------------------------------------------------------*/
void initBaseTransform(void)
	{
	int i;
	
	for(i = 0;i < NUM_TRANSFORMS;i++)
		{
		TransformSequence[0][i] = myrand()%TOTAL_TRANSFORMS;
		Source[0][i] = myrand()%NUM_REGISTERS;
		Control[0][i] = myrand()%NUM_REGISTERS;
		Dest[0][i] = myrand()%NUM_REGISTERS;
		}	
	}
/*----------------------------------------------------------------*/
void makeVariations(int basevar)
	{
	short i,k;	
	
	if(basevar)
		{	
		for(i = 0;i < NUM_TRANSFORMS;i++)
			{
			TransformSequence[0][i] = TransformSequence[basevar][i];
			Source[0][i] 	= Source[basevar][i];
			Control[0][i] 	= Control[basevar][i];
			Dest[0][i]		= Dest[basevar][i];
			}
		}
		
	for(k = 1;k <= 8;k++)
		{
		for(i = 0;i < NUM_TRANSFORMS;i++)
			{
			TransformSequence[k][i] = TransformSequence[0][i];
			Source[k][i] 	= Source[0][i];
			Control[k][i] 	= Control[0][i];
			Dest[k][i]		= Dest[0][i];
			}		
		
		switch(Coarseness)
			{
			case 3:						/* coarse */
				
				TransformSequence[k][myrand()%NUM_TRANSFORMS] = 
														myrand()%TOTAL_TRANSFORMS;
				Source[k][myrand()%NUM_TRANSFORMS] = myrand()%NUM_REGISTERS;
				Control[k][myrand()%NUM_TRANSFORMS] = myrand()%NUM_REGISTERS;
				Dest[k][myrand()%NUM_TRANSFORMS] = myrand()%NUM_REGISTERS;
	
				/*kein break;*/
			
			case 2:						/* medium */
	
				TransformSequence[k][myrand()%NUM_TRANSFORMS] = 
														myrand()%TOTAL_TRANSFORMS;
				Source[k][myrand()%NUM_TRANSFORMS] = myrand()%NUM_REGISTERS;
				Control[k][myrand()%NUM_TRANSFORMS] = myrand()%NUM_REGISTERS;
				Dest[k][myrand()%NUM_TRANSFORMS] = myrand()%NUM_REGISTERS;
				
				break;
			
			case 1:						/* fine */
				
				switch(myrand()%4)
					{
					case 0:
						TransformSequence[k][myrand()%NUM_TRANSFORMS] = 
														myrand()%TOTAL_TRANSFORMS;
						break;
	
					case 1:
						Source[k][myrand()%NUM_TRANSFORMS] = myrand()%NUM_REGISTERS;
						break;
	
					case 2:
						Control[k][myrand()%NUM_TRANSFORMS] = myrand()%NUM_REGISTERS;
						break;
	
					case 3:
						Dest[k][myrand()%NUM_TRANSFORMS] = myrand()%NUM_REGISTERS;
					}
				break;
			}
		}
	}
/*----------------------------------------------------------------*/
void draw(boolean fromStart)
	{
	short i,j,k,g;
	int rogrbl[3];
	int col;
	int *scrn_ptr;
	int x,y;
	long h1,h2;
	float fh1,fh2;
	int dsp_send_r[20];
	
	scrn_ptr = (int *)Logbase();

	if(fromStart)
		{
		Gx = Gy = GVariation = 0;
		Ready = FALSE;
		
			
		O_x = Position[GVariation].v * PicWidth;	/*..... DSP_Trsf_cmd ....*/
		O_y = Position[GVariation].h * PicHeight;

		if(Dsp_word_size)
			{
			for(j = 0;j < 18;j++)
				dsp_send_r[j++] = 0;
	
			Dsp_BlkHandshake((long *)Trsf_cmd,1L,NULL,0L);
			Dsp_BlkWords(dsp_send_r,18L,NULL,0L);
			}	
		}
	if(Ready)
		return;
	
	for(k = 0;k < PIXELS_PER_RUN;k++)
		{
		x = Position[GVariation].v	* PicWidth + Gx;
		y = Position[GVariation].h	* PicHeight + Gy;
				
	
		if(Dsp_word_size)
			{
			h1 = (long)((long)Gx * 1000L) / (long)PicWidth;
			h2 = (long)((long)Gy * 1000L) / (long)PicHeight;
			}
		else
			{
			fh1 = ((float)Gx / (float)PicWidth);
			fh2 = ((float)Gy / (float)PicHeight);
			}	

							/*..........Dsp_empfangen/senden.............*/
		if(Dsp_word_size)
			{
			for(j = 0,i = 0;j < NUM_REGISTERS;j++)
				{
				dsp_send_r[i++] = (int)h1;
				dsp_send_r[i++] = (int)h2;
				dsp_send_r[i++] = (int)((long)((long)(j) * 1000L) 
									/ (long)NUM_REGISTERS);
				}

			while (Dsp_Hf2());       				/* DSP fertig ? */  
	      							 				/* Daten abholen */  
			Dsp_BlkHandshake((long *)Recv_cmd,1L,NULL,0L);
		    Dsp_BlkWords(NULL,0L,rogrbl,3L);
													/* ... senden ... */
			Dsp_BlkHandshake((long *)Trsf_cmd,1L,NULL,0L);
			Dsp_BlkWords(dsp_send_r,18L,NULL,0L);
			}
		else					/* (nicht DSP).... TRANSFORMS ........ */
			{
			for(j = 0;j < NUM_REGISTERS;j++)
				{
				Reg[j]->x = fh1;
				Reg[j]->y = fh2;
				Reg[j]->z = ((float)j) / ((float)NUM_REGISTERS);
				}
			for(i = 0;i < NUM_TRANSFORMS;i++)
				{
				TransformList[TransformSequence[GVariation][i]]
							((Reg[Source [GVariation][i]]),
							 (Reg[Control[GVariation][i]]),
							 (Reg[Dest   [GVariation][i]]));
				}
			rogrbl[0] = ((unsigned short)(0x3e8 * Reg[0]->x));
			rogrbl[1] = ((unsigned short)(0x3e8 * Reg[0]->y));
			rogrbl[2] = ((unsigned short)(0x3e8 * Reg[0]->z));
			}
				
		for(i = 0;i < 3;i++)
			{
										/* Wie Sinuswelle +1000 ... -1000 */

			if(Dsp_word_size)
				{
				rogrbl[i] = (abs(rogrbl[i]))%0x800;
				
				if(rogrbl[i] > 0x400)
					{
					rogrbl[i] -= 0x400;
					rogrbl[i] = 0x400 - rogrbl[i];
					}
				if(rogrbl[i] == 0x400)
					rogrbl[i]--;
				}
			else
				{
				rogrbl[i] = rogrbl[i]%2000;
				if(rogrbl[i] > 1000)
					{
					rogrbl[i] -= 1000;
					rogrbl[i] = 1000 - rogrbl[i];
					}
				}
			}
					/*.............  plotten ................*/
		
		if(M_col <= 256)
			{
			if(M_col == 2)
				{
				g = (rogrbl[0]+rogrbl[1]+rogrbl[2]) / 300;	/* Graustufen */
				
				if(g < 0)
					g = 0;
				if(g > 10)
					g = 10;
				
				col = 0;
				if(Fuellmuster[g][y%16] & (0x8000 >> (x%16)))
					col = 1;
				}
			else
				{
				/* col = ((rogrbl[0]+rogrbl[1]+rogrbl[2]) / 187) +16; */
													 /* 16 Graustufen */
				col = get_col_number(rogrbl); 
				}
			}
		else
			{
			col	= 	 ((rogrbl[0]>>5) << (11)) | 
			  		(((rogrbl[1]>>5) << (6)) & 0x7e0/*7c0*/)  |
			  		(((rogrbl[2]>>5)) & 0x1f);
			}
			
										/*....plot().......*/
		if(Dsp_word_size)
			{
			plot_9((int)O_x,(int)O_y,col,C_planes,
								scrn_ptr,
								Res_x+1,
								Res_y+1);
			}
		else
			{
			plot_9(x,y,col,C_planes,
								scrn_ptr,
								Res_x+1,
								Res_y+1);
			}
						/*........................................*/		

		if(Dsp_word_size)
			{
			O_x = x;
			O_y = y;
			}
		Gy++;
		if(Gy == PicHeight)
			{
			Gy = 0;
			Gx++;
			if(Gx == PicWidth)
				{
				Gx = 0;
				
				if(++GVariation == 9)
					{
					Ready = TRUE;
					return;
					}
				if(Dsp_word_size)
					send_dsp_gVar(GVariation);	/*.....send_dsp_GVar.....*/
				}
			}		
		}
	}			
/*----------------------------------------------------------------*/
int myrand(void)
	{
	Rand_next = Rand_next * 1103515245L + 12345L;
	return((unsigned int)((Rand_next/65536L)%32768L));
	}
/*----------------------------------------------------------------*/
void mysrand(unsigned int seed)
	{
	Rand_next = seed;
	}
/*----------------------------------------------------------------*/
void plot_9(int int_x,int int_y,int farbe,int c_planes,
								int *scrn_base,int blk_w,int blk_h)
	{
	long x,y;
	long index;
	unsigned int mask;
	long i;
	
	x = (long)int_x;
	y = (long)int_y;
	
	if(y > blk_h)
		return;

	if(c_planes == 16)
		{
		index = (long)((long)y * (long)blk_w + (long)x);
		scrn_base[index] = farbe;
		return;
		}
		
	index = (long)((long)y * (long)(blk_w/16) * (long)c_planes) + 
									(long)((long)(x / 16L)*(long)c_planes);
	mask = 0x8000 >> (x%16);
		
	for(i = 0;i < c_planes;i++)
		{
		if(farbe & (0x01 << i))
			scrn_base[index + (i)] |=  mask;
		else
			scrn_base[index + (i)] &=  ~(mask);
		}
	}			
/*-----------------------------------------------------------------*/
/*-----------------------------------------------------------------*/
int dsp_init(long *x_available,long *y_available)
	{
	int word_size,test;
	
	word_size = Dsp_GetWordSize();		
	
	if(word_size != 3)
		return(0);

	if(Dsp_Lock() != 0)
		{
		mouseon();
		test = form_alert(1,"[2][ |    DSP ist benutzt!  |"
						        " |    freigeben?  ]"
	       			   	        "[  JA  | NEIN ]");
	 	if(test == 1)
	 		{
	 		dsp_exit();
	 		Dsp_Lock();
	 		}
	 	else
	 		return(0);
	 	}
	
	Dsp_Available(x_available,y_available); 	
	
	return(word_size);
	}
/*----------------------------------------------------------------*/
int set_dsp_prg(int abil,char *lod_file)
	{
	int ability;
	char *buffer;
	long x_available,y_available;
	
	
											/* Programm l„uft noch ? */
	ability = Dsp_RequestUniqueAbility() & 0xff;
	if(abil == ability)	
		return(ability);
	
		
							/*......Init und Starten DSP_Programm........*/

	if((Dsp_word_size = dsp_init(&x_available,&y_available)) == 0)
		{
		return(-1);
		}
	if((x_available < 16000) || (y_available < 16000))
		Dsp_FlushSubroutines();
		
	if(Dsp_Reserve(x_available,y_available /*200L,200L*/) == -1)
		{
		dsp_exit();
		return(-1);
		}	
  	
	buffer = malloc(x_available+y_available /*2000L*/); /* Puffer fr DSP-Programm einrichten */

									/* Laden->Umwandeln->Starten */
									
	if(Dsp_LoadProg(lod_file,ability,buffer) == -1) 
		{
		dsp_exit();
		return(-1);
		}
	
	free(buffer); 	
	return(ability);
	}
/*-----------------------------------------------------------------*/	
void dsp_exit(void)
	{
	Dsp_Unlock();
	}
/*----------------------------------------------------------------*/
int send_dsp_gVar(int gvariation)
	{
	static int gVar[40];
	int i,trnsf_sequ,source_reg,contrl_reg,dest_reg;;

	for(i = 0;i < NUM_TRANSFORMS;i++)
		{
		trnsf_sequ = TransformSequence[gvariation][i] << 12;/* 0 bis 8 */
		source_reg = Source[gvariation][i] 			  << 8;	/* 0 bis 5 */
		contrl_reg = Control[gvariation][i]           << 4;
		dest_reg   = Dest[gvariation][i] ;
		
		gVar[i] = trnsf_sequ | source_reg | contrl_reg | dest_reg;
		}
	
	while (Dsp_Hf2());       				/* DSP fertig ? */
								
	Dsp_BlkHandshake((long *)Gvar_cmd,1L,NULL,0L);
    Dsp_BlkWords(gVar,36L,NULL,0L);
	
	return(1);
	}
/*----------------------------------------------------------------*/
int fuellmuster_init(void)
	{
	int i,k;
	int save[16];
	int *scrn;
	
	scrn = (int *)Logbase();
	
	for(i = 0;i < 16;i++)
		{
		save[i] = *(scrn + ((long)i * (long)(Res_x+1) / (long)16));
		}
	
	fillcolor(1);
	umrandung(0);
	mode(1);
	
	for(i = 0;i < 12;i++)
		{
		fillcolor(1);
		fillstyle(Grw[i].a,Grw[i].b);
		pbox(0,0,16,16);

		for(k = 0;k < 16;k++)
			{
			Fuellmuster[i][k] = *(scrn + ((long)k * 
											(long)(Res_x+1) / (long)16));
			}
		fillcolor(0);
		pbox(0,0,16,16);
		
		}
	
	for(i = 0;i < 16;i++)
		{
		*(scrn + ((long)i * (long)(Res_x+1) / (long)16)) = save[i];
		}

	return(1);
	}
/*------------------------------------------------------------------*/
int get_col_number(int *rogrbl)
	{
	int l,col,dif,odif;

	col = 0;
	odif = 3000;
	
	for(l = 0;l < M_col;l++)
		{
		dif = abs(Rot[l]   - rogrbl[0]);
		if(dif < odif)
			{
			dif += abs(Gruen[l] - rogrbl[1]);
			if(dif < odif)
				{	
				dif += abs(Blau[l]  - rogrbl[2]);

				if(dif < odif)
					{
					col = l;
					if(!dif)
						return(col);
						
					odif = dif;
					}
				}	
			}
		}
	return(col);
	}
/*---------------------------------------------------------------------*/

/************************************************************************
Zur Beschreibung des DO9_Formates, lesen Sie bitte die save/open_
Routinen durch.
Es erinnert stark an DOODLE, nur ist die Gr”že flexibel, und Farbnummern
ber 1 kann man eben auch speichern.
(Eigendlich mžte noch die RGB_Farbtabelle folgen, Atari_Standard.)
Bei True_Color bleibt das Word einfach unver„ndert.
/*---------------------------------------------------------------------*/
int save_pic(char *R_pfad_name)
	{
	FILE *datei;
	char char_feld[8];
	int *int_feld,*mem_int_feld;
	int *buf,*mem_buf;
	unsigned int mask;
	int buf_w,buf_h,x,y;
	int feld_cnt;
	int write_cnt;
	int color;
	int i;
	long l_h;
	int max_file = 16000;

	buf = (int *)Logbase();					/*........ zur Demo ........ */
	buf_w = Res_x+1;
	buf_h = Res_y+1;	


	if((datei = fopen(R_pfad_name,"wb")) != NULL)
		{
		mem_int_feld = int_feld = (int *)calloc(max_file+8,sizeof(int));
		if(!int_feld)
			{
			fclose(datei);
			return(0);
			}
			
		char_feld[0] = 'D';
		char_feld[1] = 'O';
		char_feld[2] = '9';
		char_feld[3] = '*';
		fwrite(&char_feld[0],sizeof(char),4,datei);
		
		int_feld[0] = buf_w;
		int_feld[1] = buf_h;
		int_feld[2] = C_planes;
		int_feld[3] = 0;
		fwrite(&int_feld[0],sizeof(int),4,datei);
		
							/*................................*/
		
		int_feld = mem_int_feld;
		*int_feld = 0;
		feld_cnt = 0;
		mem_buf = buf;
		mask = 0x8000;
		
		mouseon();
		mouseform(2);

		for(y = 0;y < buf_h;y++)
			{
			buf = mem_buf;
			write_cnt = 0;
			*int_feld = 0;
			
			l_h = (long)((long)y * (long)(buf_w/16) * (long)C_planes);
			/*mask = 0x8000;*/
			buf += l_h;
				
			for(x = 0;x < buf_w;x++)
				{
				color = 0;
				if(C_planes < 16)
					{	
					for(i = 0;i < C_planes;i++)
						{
						if(*(buf+i) & mask)
							color |= (0x1 << i);
						}
					if(!(mask >>= 1))
						{
						mask = 0x8000;
						buf += C_planes;
						}
					}
				else
					{
					color = *(buf);
					buf++;
					}		
				
					
				(*int_feld) |= color;
				if((write_cnt += C_planes) >= 16)
					{
					if(++feld_cnt >= max_file)
						{
						fwrite(&mem_int_feld[0],sizeof(int),feld_cnt,datei);
		
						int_feld = mem_int_feld;
						feld_cnt = 0;
						}
					else
						{	
						int_feld++;
						}
					*int_feld = 0;
					write_cnt = 0;
					}
				else
					{
					(*int_feld) <<= C_planes;
					}	
				}
								/*..... neue Zeile, neues Byte ......*/
			
			if((write_cnt != 0) && (C_planes < 16))
				{
				while((write_cnt) < 16)
					{
					(*int_feld) <<= C_planes;
					write_cnt += C_planes;
					}
				
				if(++feld_cnt >= max_file)
					{
					fwrite(&mem_int_feld[0],sizeof(int),feld_cnt,datei);
	
					int_feld = mem_int_feld;
					feld_cnt = 0;
					}
				else
					{	
					int_feld++;
					}
				}
			}

		fwrite(&mem_int_feld[0],sizeof(int),feld_cnt,datei);
		free(int_feld);			
		
		mouseform(0);

		return(fclose(datei));
		}

	return(0);
	}
/*---------------------------------------------------------------------*/
int open_pic(char *R_pfad_name)
	{
	FILE *datei;
	char char_feld[8];
	int *int_feld,*mem_int_feld;
	int *buf;
	unsigned int mask,c_mask;
	unsigned int uhelp;
	int buf_w,buf_h,x,y;
	int feld_cnt;
	int read_cnt;
	unsigned int color;
	int rogrbl[8];
	int c_planes;
	int i;
	int ret;
	int max_file = 16000;
	long l_h;
	
	int *ziel_buf = (int *Logbase();		/*........ zur Demo ........ */
	int ziel_buf_w;
	
	if((datei = fopen(R_pfad_name,"rb")) != NULL)
		{
		fread(&char_feld[0],sizeof(char),4,datei);
		char_feld[4] = '\0';

		if((strcmp(char_feld,"DO9*") != 0))
			{
			form_alert(1,"[2][ | Keine *.DO9 Datei! ][  OK  ]");
			fclose(datei);
			return(0);
			}
		
		mem_int_feld = int_feld = (int *)calloc(max_file+8,sizeof(int));
		if(!int_feld)
			{
			fclose(datei);
			return(0);
			}

		fread(&int_feld[0],sizeof(int),4,datei);

		buf_w = int_feld[0];		
		buf_h = int_feld[1];			
		c_planes = int_feld[2];
		
										/*........ Demo, sonst hier ... */
		ziel_buf_w = buf_w+15;			/*........ ziel_buf init ...... */
		ziel_buf_w -= (ziel_buf_w%16);

		int_feld = mem_int_feld;
		fread(&int_feld[0],sizeof(int),max_file,datei);
		feld_cnt = 0;

		switch(c_planes)
			{
			case 1:
				c_mask = 0x1;
				break;
			case 2:
				c_mask = 0x3;
				break;
			case 4:
				c_mask = 0xf;
				break;
			case 8:
				c_mask = 0xff;
				break;
			}	
		
		mouseon();
		mouseform(2);
		
		for(y = 0;y < buf_h;y++)
			{
			if(feld_cnt >= max_file)
				{
				int_feld = mem_int_feld;
				fread(&int_feld[0],sizeof(int),max_file,datei);
				feld_cnt = 0;
				}
			
			read_cnt = 0;
			mask = 0x8000;
			l_h = (long)((long)y*(long)(ziel_buf_w/16)*(long)C_planes);
			buf = ziel_buf + l_h;

			for(x = 0;x < buf_w;x++)
				{
										/*........color.........*/	
				if(c_planes < 16)
					{
					read_cnt += c_planes;
					color = *int_feld;
					color >>= (16-read_cnt);
					color &= c_mask;

					if((read_cnt) >= 16)
						{
						read_cnt = 0;
						if(++feld_cnt >= max_file)
							{
							int_feld = mem_int_feld;
							fread(&int_feld[0],sizeof(int),max_file,datei);
							feld_cnt = 0;
							}
						else
							{
							int_feld++;
							}	
						}
					}
				else	/* ... c_planes == 16 ... */
					{
					if(C_planes < 16)
						{
						uhelp = (unsigned int)*int_feld;
						
		       			rogrbl[0] = ((uhelp >> 11) & 0x1f) << 5;
		       			rogrbl[1] = ((uhelp >> 6)  & 0x1f) << 5;
		       			rogrbl[2] = ((uhelp)       & 0x1f) << 5;
						
						if(C_planes == 1)
							{
							color = (rogrbl[0]+rogrbl[1]+rogrbl[2])/300;
							}
						else
							{	
							color = get_col_number(rogrbl);
							}
						
						
						if(++feld_cnt >= max_file)
							{
							int_feld = mem_int_feld;
							fread(&int_feld[0],sizeof(int),max_file,datei);
							feld_cnt = 0;
							}
						else
							{
							int_feld++;
							}							
						}
					}
										/*........zeichnen.........*/	
				if(C_planes < 16)
					{
					if((C_planes == 1) && (c_planes != 1))
						{
						switch(c_planes)
							{
							case 2:
								if(color == 0)
									i = 10;
								else
									i = (color * 25)/10;
								break;
							case 4:
								if(color == 0)
									i = 10;
								else
									i = (color * 6)/10;
								break;
							case 8:
								if(color == 0)
									i = 10;
								else
									i = (color / 25);
								break;
							default:					/* true color */
								i = color;
								break;	
							}

						if(i < 0)
							i = 0;
						if(i > 10)
							i = 10;
						if(Fuellmuster[i][y%16] & (0x8000 >> (x%16)))
							*(buf) |= mask;
						else
							*(buf) &= ~mask;
						}
					else
						{		
						for(i = 0;i < C_planes;i++)
							{
							if(color & (0x1 << i))
								*(buf+i) |= mask;
							else
								*(buf+i) &= ~mask;	
							}
						}	
					if(!(mask >>= 1))
						{
						mask = 0x8000;
						buf += C_planes;
						}
					
					}
				else		/*...C_planes == 16...*/
					{
					if(c_planes == 16)
						{
						*(buf) = *(int_feld);
						if(++feld_cnt >= max_file)
							{
							int_feld = mem_int_feld;
							fread(&int_feld[0],sizeof(int),max_file,datei);
							feld_cnt = 0;
							}
						else
							int_feld++;
							
						buf++;
						}
					else
						{
						*(buf) = ((Rot[color]  >>5) << 11) | 
								   (((Gruen[color]>>5) << 6) & 0x7e0/*7c0*/)  |
								   (((Blau[color] >>5)) & 0x1f);
						buf++;
						}	
					}			
				}
								/*..... neue Zeile, neues Byte ......*/
								
			if((read_cnt != 0) /*&& (C_planes < 16) && (c_planes < 16)*/)
				{	
				if((++feld_cnt) >= max_file)
					{
					int_feld = mem_int_feld;
					fread(&int_feld[0],sizeof(int),max_file,datei);
					feld_cnt = 0;
					}
				else
					{
					int_feld++;
					}
				}
												
			}
		mouseoff();
		mouseform(0);
		
		free(mem_int_feld);
		ret = fclose(datei);
		}
	
	return(ret);	
	}
/*---------------------------------------------------------------------*/
*****************************************************/		
/***************************************************
Um mit QBI_ST zusammen zu arbeiten, sollte das DSP Program
"TRANSFRM.LOD" heižen, und wie in den folgenden Routinen
Anweisungen entgegennehmen, und reagieren.
Qbi_ST erwartet Werte zwischen 0 und 1024(0x400) als RGB_Farbwerte.

							;*** char Sin_cmd[4]  = { 0x00, 0x00, 0x04, 0 }; 
							;*** char Gvar_cmd[4] = { 0x00, 0x00, 0x02, 0 };      
							;*** char Trsf_cmd[4] = { 0x00, 0x00, 0x01, 0 };      
							;*** char Recv_cmd[4] = { 0x00, 0x01, 0x00, 0 };      

		
;------------------------------------------------
; Hauptschleife  
;------------------------------------------------
mainloop                                         
    	jclr    #0,X:HSR,mainloop     ; Kommando vom     
	    movep   X:HRX,X0              ; Host-Prozessor   
	    jset    #0,X0,transfrm          ; entgegennehmen, transformieren 
	    jset    #1,X0,gvar_init         ; grafik_variation entgegennehmen. 
	    jset    #2,X0,sin_init          ; sinustabelle entgegennehmen.   
	    jset    #8,X0,send_data         ; zuruecksenden                          
	    jmp     mainloop  
;------------------------------------------------
		
;-------------------------------------------------
transfrm
	    movep   #$08,X:HCR          ; busy-flag setzen  
	
	    jsr     get_data			; Transformationsdaten entgegennehmen
	    jsr		run_trnsf			; Transformationen ausfuehren
	    jsr		aufbereiten			; Register 0-2 als Farbwerte
	
	    movep   #$00,X:HCR          ; busy-flag loeschen
	    jmp     mainloop 
;------------------------------------------------
***********************************************************/		
