/*             Transformer:      *.RSC   ->   *.CX                 */


#include	<define.h>
#include	<stdio.h>
#include	<gemdefs.h>
#include	<obdefs.h>
#include	<osbind.h>
#include	"rsc_to_c.h"
#include	"rsc_to_c.cx"

extern FILE	*fopen();


#define		NIL		-1

int		handle;
int		vdi_handle;
int 	work_in[11],work_out[57];
int 	contrl[12],intin[128],ptsin[128],intout[128],ptsout[128];

RSHDR	header;
int		r_strings[4000];
		
			

main()
{
	FILE	*stream;
	int		dx, dy,
			object_type,
			i, lauf, ll,
			zaehl,
			ret,
			error,
			hndl,
			end_string;
	int		*pi;
	long	memory,
			mem,
			marker,
			rel_adr;
	char	*pc,
			*str;
	char	path[80],
			file[20],
			hilf[200];
			
			
	for (i=0; i<10; work_in[i++]=1)
		;
	work_in[10]=2;
	v_opnvwk (work_in, &vdi_handle, work_out);
		
	appl_init();
	
	if (rsrc_load ("RSC_TO_C.RSC"))
	{
		dx = dy = 3;
		if (Getrez() == 2)
			dy =4;
			
		for (lauf = 0; lauf < 4000; lauf++)
		{
			r_strings[lauf] = 0L;
		}
		
		fsel_exten (0, "*.RSC");
		fsel_exten (1, "*.C");
		fsel_exten (2, "*.H");
		fsel_exten (3, "*.DEF");
		strcpy (path, "A:\\*.RSC");
		strcpy (file, "");
		
		if (fsel_in (path, file, "Laden der Resource"))
		{
			strcpy (hilf, path);
			for (i = strlen(hilf); hilf[i] != '\\'; i--)
				hilf[i] = '\0';
			strcat (hilf, file);
		
			if ((hndl = Fopen(hilf,0)) < 0)
			{
				form_alert (1, "[1][ | Fehler beim ”ffnen | der Datei. ][  OK  ]");
				goto ENDE;
			}
			Fread (hndl, (long) sizeof(RSHDR), &header);
			print_rshdr (&header);
			
			memory = ((mem = Malloc( (long) header.rsh_rssize)) + 1) & 0xfffffffe;
			if (memory != 0)
			{
				Fseek (0L, hndl, 0);
				Fread (hndl, (long) header.rsh_rssize, memory);
				
				Fclose (hndl);
					
				for (i = strlen(path); path[i] != '\\'; i--)
					path[i] = '\0';
				strcat (path, "*.CX");
				lauf = strlen (file);
				file[lauf - 3] = 'C';
				file[lauf - 2] = 'X';
				file[lauf - 1] = '\0';
				pc = file;
				str = hilf;
				for (lauf = 0; lauf < 8; lauf++)
					if (*pc != '.')
						*str++ = *pc++;
					else
						*str++ = ' ';
				pc++;
				for (lauf = 0; lauf < 3; lauf++)
					*str++ = *pc++;
				
				if (fsel_in (path, hilf, "Speichern der C-Source"))
				{
				for (i = strlen(path); path[i] != '\\'; i--)
					path[i] = '\0';
				strcat (path, hilf);
				
				stream = fopen (path, "w");
				
				
				
 	/*
 	*		Vorspann :
	*/
				fprintf (stream, "/*                      Copyright  1988 by Dieter Fiebelkorn                 */\n\n\n");
				fprintf (stream, "#include	<tos.h>\n");
				fprintf (stream, "#include	<aes.h>\n\n");
				lauf = strlen (hilf);
				for (pc = file + lauf; pc > file; pc--)
					if (*pc == '.')
						break;
				if (*pc == '.')
					*pc = '\0';
				strcat (file, ".H");
				fprintf (stream, "#include	\"%s\"\n\n", file);
	
				fprintf (stream, "#define		WHITEBAK	NORMAL\n");
				fprintf (stream, "#define		HIGH		2\n\n");
	
				fprintf (stream, "extern int	*global = _GemParBlk.global;\n");
				fprintf (stream, "static int	rsrcload_flag = 0;\n\n\n");
	
	
				fprintf (stream,"\n");
				pi = (int *) (memory + header.rsh_trindex);
				for (lauf = 1; lauf <= header.rsh_ntree; lauf++)
				{
					rel_adr = 65536 * (*pi++) + (*pi++);
					zaehl = (((int)rel_adr) - ((int)header.rsh_object))/24;
					fprintf (stream, "#define T%dOBJ	%d;\n", lauf-1, zaehl);
				}
				
				fprintf (stream, "#define NOBS		%d;\n",header.rsh_nobs);
				fprintf (stream, "#define NTREE		%d;\n",header.rsh_ntree);
				fprintf (stream, "#define NTED		%d;\n",header.rsh_nted);
				fprintf (stream, "#define NIB			%d;\n",header.rsh_nib);
				fprintf (stream, "#define NBB			%d;\n",header.rsh_nbb);
				fprintf (stream, "#define NSTRING		%d;\n",header.rsh_nstring);
				fprintf (stream, "#define NIMAGES		%d;\n",header.rsh_nimages);
				fprintf (stream,"\n\n\n");
	
	
 	/*
 	*		Do	String			
	*/
				lauf = 0;
				
				end_string = header.rsh_object;
				if (header.rsh_tedinfo < end_string)
					end_string = header.rsh_tedinfo;
				if (header.rsh_iconblk < end_string)
					end_string = header.rsh_iconblk;
				if (header.rsh_bitblk < end_string)
					end_string = header.rsh_bitblk;
				if (header.rsh_frstr < end_string)
					end_string = header.rsh_frstr;
				if (header.rsh_imdata < end_string)
					end_string = header.rsh_imdata;
				if (header.rsh_frimg < end_string)
					end_string = header.rsh_frimg;
				if (header.rsh_trindex < end_string)
					end_string = header.rsh_trindex;
				
				fprintf (stream, "char   *rs_strings[] = {\n");
				pc = (char *) (memory + header.rsh_string);
				
				while (pc < (char *) (memory + end_string))
				{
					r_strings[lauf++] = (int) pc - memory;
					fprintf (stream, "          /*%04x*/     \"",lauf-1);
					while (*pc != '\0')
						if ((unsigned int) *pc < 32) 
							fprintf (stream, "\\%03o", (char) ((int)*pc++ & 0x000000ff));
						else
							fprintf (stream, "%c", *pc++);
					pc++;
					if (pc < (char *) (memory + end_string))
						fprintf (stream, "\", \n");
					else
						fprintf (stream, "\"");
				}
				if (lauf == 1)
					fprintf (stream, "\"\"");
				fprintf (stream, "};\n\n");
				
				
 	/*
 	*		Do	Images
	*/
				end_string = header.rsh_object;
				if ((header.rsh_tedinfo < end_string) && (header.rsh_imdata <= header.rsh_tedinfo))
					end_string = header.rsh_tedinfo;
				if ((header.rsh_iconblk < end_string) && (header.rsh_imdata <= header.rsh_iconblk))
					end_string = header.rsh_iconblk;
				if ((header.rsh_bitblk < end_string) && (header.rsh_imdata <= header.rsh_bitblk))
					end_string = header.rsh_bitblk;
				if ((header.rsh_frstr < end_string) && (header.rsh_imdata <= header.rsh_frstr))
					end_string = header.rsh_frstr;
				if ((header.rsh_frimg < end_string) && (header.rsh_imdata <= header.rsh_frimg))
					end_string = header.rsh_frimg;
				if ((header.rsh_trindex < end_string) && (header.rsh_imdata <= header.rsh_trindex))
					end_string = header.rsh_trindex;
				
				
				fprintf (stream, "struct IMDATA {\n");
				fprintf (stream, "       int     image;\n");
				fprintf (stream, "       } rs_imdata[] = {\n");
				header.rsh_imdata = (header.rsh_imdata + 1) & 0xfffffffe;
				pi = (int *) (memory + header.rsh_imdata);
				
				for (lauf = 1; pi < (int *)(memory + end_string); lauf+=2)
				{
					if ((lauf-1) % 4 == 0)
					{
						if ((lauf-1) % 16 == 0)
							fprintf (stream, "          /*%04x*/     ",lauf-1);
						else
							fprintf (stream, "                       ");
					}
					fprintf (stream, "0x%04x, ",*pi++);
					fprintf (stream, "0x%04x",*pi++);
					if (pi < (int *)(memory + end_string))
						fprintf (stream, ", ");
					if ((lauf+1) % 4 == 0)
						fprintf (stream, "\n");
				}
				if ((int *) (memory + header.rsh_imdata) == (int *)(memory + end_string))
					fprintf (stream, "          0  ");
				fprintf (stream, "};\n\n");
				
				
 	/*
 	*		Do	BitBlocks	(BitImages)
	*/			
				fprintf (stream, "BITBLK rs_bitblk[] = {\n");
				pi = (int *) (memory + header.rsh_bitblk);
				
				for (lauf = 1; lauf <= header.rsh_nbb; lauf++)
				{
					fprintf (stream, "          /*%04x*/     ",lauf-1);
					rel_adr = 65536 * (*pi++) + (*pi++);
					zaehl = (((int)rel_adr) - ((int)header.rsh_imdata))/2;
					fprintf (stream, "0x%04xL, ",zaehl);
					fprintf (stream, "%d, ",*pi++);
					fprintf (stream, "%d, ",*pi++);
					fprintf (stream, "%d, ",*pi++);
					fprintf (stream, "%d, ",*pi++);
					fprintf (stream, "%d",*pi++);
					if (lauf < header.rsh_nbb)
						fprintf (stream, ", \n");
				}
				if (header.rsh_nbb == 0)
					fprintf (stream, "          0  ");
				fprintf (stream, "};\n\n");
				
				
 	/*
 	*		Do IconBlocks
	*/			
				fprintf (stream, "ICONBLK rs_iconblk[] = {\n");
				pi = (int *) (memory + header.rsh_iconblk);
				
				for (lauf = 1; lauf <= header.rsh_nib; lauf++)
				{
					fprintf (stream, "          /*%04x*/     ",lauf-1);
					rel_adr = 65536 * (*pi++) + (*pi++);
					zaehl = (((int)rel_adr) - ((int)header.rsh_imdata))/2;
					fprintf (stream, "0x%04xL, ",zaehl);
					rel_adr = 65536 * (*pi++) + (*pi++);
					zaehl = (((int)rel_adr) - ((int)header.rsh_imdata))/2;
					fprintf (stream, "0x%04xL, ",zaehl);
					rel_adr = 65536 * (*pi++) + (*pi++);
					for (zaehl = 0; r_strings[zaehl] != rel_adr; zaehl++)
						;
					fprintf (stream, "0x%04xL, ",zaehl);
					fprintf (stream, "%d, ",*pi++);
					fprintf (stream, "%d, ",*pi++);
					fprintf (stream, "%d, ",*pi++);
					fprintf (stream, "%d, ",*pi++);
					fprintf (stream, "%d, ",*pi++);
					fprintf (stream, "%d, ",*pi++);
					fprintf (stream, "%d, ",*pi++);
					fprintf (stream, "%d, ",*pi++);
					fprintf (stream, "%d, ",*pi++);
					fprintf (stream, "%d, ",*pi++);
					fprintf (stream, "%d",*pi++);
					if (lauf < header.rsh_nib)
						fprintf (stream, ", \n");
				}
				if (header.rsh_nib == 0)
					fprintf (stream, "          0  ");
				fprintf (stream, "};\n\n");
				
				
 	/*
 	*		Do	TextInfos
	*/
				fprintf (stream, "TEDINFO rs_tedinfo[] = {\n");
				pi = (int *) (memory + header.rsh_tedinfo);
				
				for (lauf = 1; lauf <= header.rsh_nted; lauf++)
				{
					fprintf (stream, "          /*%04x*/     ",lauf-1);
					rel_adr = 65536 * (*pi++) + (*pi++);
					for (zaehl = 0; r_strings[zaehl] != rel_adr; zaehl++)
						;
					fprintf (stream, "0x%04xL, ",zaehl);
					rel_adr = 65536 * (*pi++) + (*pi++);
					if (rel_adr == 0L)
						fprintf (stream, "0x%04xL, ", 0x0000);
					else
					{
						for (zaehl = 0; r_strings[zaehl] != rel_adr; zaehl++)
							;
						fprintf (stream, "0x%04xL, ",zaehl);
					}
					rel_adr = 65536 * (*pi++) + (*pi++);
					for (zaehl = 0; r_strings[zaehl] != rel_adr; zaehl++)
						;
					fprintf (stream, "0x%04xL, ",zaehl);
					fprintf (stream, "%d, ",*pi++);
					fprintf (stream, "%d, ",*pi++);
					fprintf (stream, "%d, ",*pi++);
					fprintf (stream, "%d, ",*pi++);
					fprintf (stream, "%d, ",*pi++);
					fprintf (stream, "%d, ",*pi++);
					fprintf (stream, "%d, ",*pi++);
					fprintf (stream, "%d",*pi++);
					if (lauf < header.rsh_nted)
						fprintf (stream, ", \n");
				}
				if (header.rsh_nted == 0)
					fprintf (stream, "          0  ");
				fprintf (stream, "};\n\n");
				
				
 	/*
 	*		Do	Objects
	*/
				fprintf (stream, "OBJECT rs_object[] = {\n");
				pi = (int *) (memory + header.rsh_object);
				
				for (lauf = 1, ll = 0; lauf <= header.rsh_nobs; lauf++, ll++)
				{
					if (*pi == -1)
						ll = 0;
					fprintf (stream, "          /*%04d*/     ",ll);
					fprintf (stream, "%d, ",*pi++);
					fprintf (stream, "%d, ",*pi++);
					fprintf (stream, "%d, ",*pi++);
					switch (object_type = *pi++)
					{
						case G_BOX      : fprintf (stream, "G_BOX     , ");
					                  	break;
						case G_TEXT     : fprintf (stream, "G_TEXT    , ");
					                  	break;
						case G_BOXTEXT  : fprintf (stream, "G_BOXTEXT , ");
					                  	break;
						case G_IMAGE    : fprintf (stream, "G_IMAGE   , ");
					                  	break;
						case G_USERDEF  : fprintf (stream, "G_PROGDEF , ");
					                  	break;
						case G_IBOX     : fprintf (stream, "G_IBOX    , ");
					                  	break;
						case G_BUTTON   : fprintf (stream, "G_BUTTON  , ");
					                  	break;
						case G_BOXCHAR  : fprintf (stream, "G_BOXCHAR , ");
					                  	break;
						case G_STRING   : fprintf (stream, "G_STRING  , ");
					                  	break;
						case G_FTEXT    : fprintf (stream, "G_FTEXT   , ");
					                  	break;
						case G_FBOXTEXT : fprintf (stream, "G_FBOXTEXT, ");
					                  	break;
						case G_ICON     : fprintf (stream, "G_ICON    , ");
					                  	break;
						case G_TITLE    : fprintf (stream, "G_TITLE   , ");
					                  	break;
					}	     
					fprintf (stream, "0x%04x, ",*pi++);
					fprintf (stream, "0x%04x, ",*pi++);
					rel_adr = 65536 * (*pi++) + (*pi++);
					
					if (rel_adr == 0L)
						fprintf (stream, "0x%08lxL, ",rel_adr);
					else
					{
						switch (object_type)
						{
							case G_FTEXT    :
							case G_BOXTEXT  :
							case G_FBOXTEXT :
							case G_TEXT     :
							{
								zaehl = (((int)rel_adr) - ((int)header.rsh_tedinfo))/28;
								fprintf (stream, "0x%04xL    , ",zaehl);
								break;
							}
							case G_BUTTON   :
							case G_TITLE    :
							case G_STRING   :
							{
								for (zaehl = 0; r_strings[zaehl] != rel_adr; zaehl++)
									;
								fprintf (stream, "0x%04xL    , ",zaehl);
								break;
							}
							case G_ICON     :
							{
								zaehl = (((int)rel_adr) - ((int)header.rsh_iconblk))/34;
								fprintf (stream, "0x%04xL    , ",zaehl);
								break;
							}
							case G_IMAGE    :
							{
								zaehl = (((int)rel_adr) - ((int)header.rsh_bitblk))/14;
								fprintf (stream, "0x%04xL    , ",zaehl);
								break;
							}
							default:
								fprintf (stream, "0x%08lxL, ",rel_adr);
						}
					}
					fprintf (stream, "%d, ",*pi);
					pi++;
					fprintf (stream, "%d, ",*pi);
					pi++;
					fprintf (stream, "%d, ",*pi);
					pi++;
					fprintf (stream, "%d",*pi);
					pi++;
					if (lauf < header.rsh_nobs)
						fprintf (stream, ", \n");
				}
				if (header.rsh_nobs == 0)
					fprintf (stream, "          0  ");
				fprintf (stream, "};\n\n");
				
				
 	/*
 	*		Do Trees
	*/
				fprintf (stream, "long   rs_trindex[] = {\n");
				pi = (int *) (memory + header.rsh_trindex);
				for (lauf = 1; lauf <= header.rsh_ntree; lauf++)
				{
					fprintf (stream, "          /*%04d*/     ",lauf-1);
					rel_adr = 65536 * (*pi++) + (*pi++);
					zaehl = (((int)rel_adr) - ((int)header.rsh_object))/24;
					fprintf (stream, "0x%04xL",zaehl);
					if (lauf < header.rsh_ntree)
						fprintf (stream, ",\n");				
				}
				if (header.rsh_ntree == 0)
					fprintf (stream,"          0  ");
				fprintf (stream, "};\n\n");
				
				
				fprintf (stream, "\n\n\n\n\n/*                       Entnommen aus der ST-Computer 12'87                  */\n\n");
				fprintf (stream, "/*                      Modifiziert 1988 by Dieter Fiebelkorn                 */\n\n\n\n");
				fprintf (stream, "/*                    ========= Resource-Load-Segment =========               */\n\n");
				fprintf (stream, "int	rsrc_load (RscFile)\n");
				fprintf (stream, "	char	*RscFile;\n");
				fprintf (stream, "{\n");
				fprintf (stream, "	int		dx,\n");
				fprintf (stream, "			dy,\n");
				fprintf (stream, "			Obj;\n\n");
				
				fprintf (stream, "	OBJECT	**GEM_rsc;\n\n");
		
				fprintf (stream, "	GEM_rsc = (OBJECT **) &global[5];\n");
				fprintf (stream, "	*GEM_rsc = (OBJECT *) &rs_trindex[0];\n\n");
				fprintf (stream, "	if (rsrcload_flag == 0)\n");
				fprintf (stream, "	{\n");
				fprintf (stream, "	rsrcload_flag = 1;\n");
				fprintf (stream, "	dx = dy = 3;\n");
				fprintf (stream, "	if (Getrez() == HIGH)\n");
				fprintf (stream, "		dy = 4;\n\n");
			
				fprintf (stream, " /*\n");
				fprintf (stream, " *	Do Objects\n");
				fprintf (stream, "*/\n");
				fprintf (stream, "	for (Obj = 0; Obj < NOBS; Obj++)\n");
				fprintf (stream, "	{\n");
				fprintf (stream, "		rs_object[Obj].ob_x = ((rs_object[Obj].ob_x & 0x00ff) << dx) +\n");
				fprintf (stream, "		                       (rs_object[Obj].ob_x >> 8);\n");
				fprintf (stream, "		rs_object[Obj].ob_y = ((rs_object[Obj].ob_y & 0x00ff) << dy) +\n");
				fprintf (stream, "		                       (rs_object[Obj].ob_y >> 8);\n");
				fprintf (stream, "		rs_object[Obj].ob_width = ((rs_object[Obj].ob_width & 0x00ff) << dx) +\n");
				fprintf (stream, "		                           (rs_object[Obj].ob_width >> 8);\n");
				fprintf (stream, "		rs_object[Obj].ob_height = ((rs_object[Obj].ob_height & 0x00ff) << dy) +\n");
				fprintf (stream, "		                            (rs_object[Obj].ob_height >> 8);\n");
				fprintf (stream, "		switch (rs_object[Obj].ob_type)\n");
				fprintf (stream, "		{\n");
				fprintf (stream, "			case G_FTEXT    :\n");
				fprintf (stream, "			case G_BOXTEXT  :\n");
				fprintf (stream, "			case G_FBOXTEXT :\n");
				fprintf (stream, "			case G_TEXT     :\n");
				fprintf (stream, "				rs_object[Obj].ob_spec = (long) &rs_tedinfo[(int) rs_object[Obj].ob_spec];\n");
				fprintf (stream, "				break;\n");
				fprintf (stream, "			case G_BUTTON   :\n");
				fprintf (stream, "			case G_TITLE    :\n");
				fprintf (stream, "			case G_STRING   :\n");
				fprintf (stream, "				rs_object[Obj].ob_spec = (long) rs_strings[(int) rs_object[Obj].ob_spec];\n");
				fprintf (stream, "				break;\n");
				fprintf (stream, "			case G_ICON     :\n");
				fprintf (stream, "				rs_object[Obj].ob_spec = (long) &rs_iconblk[(int) rs_object[Obj].ob_spec];\n");
				fprintf (stream, "				break;\n");
				fprintf (stream, "			case G_IMAGE    :\n");
				fprintf (stream, "				rs_object[Obj].ob_spec = (long) &rs_bitblk[(int) rs_object[Obj].ob_spec];\n");
				fprintf (stream, "				break;\n");
				fprintf (stream, "		}\n");
				fprintf (stream, "	}\n\n");
		
				fprintf (stream, " /*\n");
				fprintf (stream, " *	Do TextInfos\n");
				fprintf (stream, "*/\n");
				fprintf (stream, "	for (Obj = 0; Obj < NTED; Obj++)\n");
				fprintf (stream, "	{\n");
				fprintf (stream, "		rs_tedinfo[Obj].te_ptext  = (char *)rs_strings[(int) rs_tedinfo[Obj].te_ptext];\n");
				fprintf (stream, "		rs_tedinfo[Obj].te_ptmplt = (char *)rs_strings[(int) rs_tedinfo[Obj].te_ptmplt];\n");
				fprintf (stream, "		rs_tedinfo[Obj].te_pvalid = (char *)rs_strings[(int) rs_tedinfo[Obj].te_pvalid];\n");
				fprintf (stream, "	}\n\n");
		
				fprintf (stream, " /*\n");
				fprintf (stream, " *	Do IconBlocks\n");
				fprintf (stream, "*/\n");
				fprintf (stream, "	for (Obj = 0; Obj < NIB; Obj++)\n");
				fprintf (stream, "	{\n");
				fprintf (stream, "		rs_iconblk[Obj].ib_pmask = (int *)&rs_imdata[(int) rs_iconblk[Obj].ib_pmask];\n");
				fprintf (stream, "		rs_iconblk[Obj].ib_pdata = (int *)&rs_imdata[(int) rs_iconblk[Obj].ib_pdata];\n");
				fprintf (stream, "		rs_iconblk[Obj].ib_ptext = (int *)rs_strings[(int) rs_iconblk[Obj].ib_ptext];\n");
				fprintf (stream, "	}\n\n");
		
				fprintf (stream, " /*\n");
				fprintf (stream, " *	Do BitImages\n");
				fprintf (stream, "*/\n");
				fprintf (stream, "	for (Obj = 0; Obj < NBB; Obj++)\n");
				fprintf (stream, "		rs_bitblk[Obj].bi_pdata = (int *)&rs_imdata[(int) rs_bitblk[Obj].bi_pdata];\n\n");
			
				fprintf (stream, " /*\n");
				fprintf (stream, " *	Do TreeIndex\n");
				fprintf (stream, "*/\n");
				fprintf (stream, "	for (Obj = 0; Obj < NTREE; Obj++)\n");
				fprintf (stream, "		rs_trindex[Obj] = (long) &rs_object[(int) rs_trindex[Obj]];\n\n");
	
				fprintf (stream, "  }\n");
				fprintf (stream, "	return(1);\n");
				fprintf (stream, "}\n\n\n\n");
	
	
				fprintf (stream, "rsrc_free()\n");
				fprintf (stream, "{\n");
				fprintf (stream, "	return (1);\n");
				fprintf (stream, "}\n");
							
			
				fclose (stream);
				}
				Mfree (mem);
			}
			else
				form_alert (1, "[1][ | Kein Speicher vorhanden !   ][  OK  ]");
		}
		rsrc_free();
	}
ENDE:
	appl_exit();
	v_clsvwk(vdi_handle);
}



int print_rshdr(h)
RSHDR	*h;
{
	OBJECT	*o;
	long	tree;
	int		i,
			x, y, w, hg;
	char	hilf[20];
	
	rsrc_gaddr (0, 0, &tree);
	o = (OBJECT *) tree;
	i = STRINGS;
	sprintf (hilf, "RSH_VRSN    = %d",h->rsh_vrsn);
	strcpy ((o + (i++))->ob_spec, hilf);
	sprintf (hilf, "RSH_OBJECT  = %d",h->rsh_object);
	strcpy ((o + (i++))->ob_spec, hilf);
	sprintf (hilf, "RSH_TEDINFO = %d",h->rsh_tedinfo);
	strcpy ((o + (i++))->ob_spec, hilf);
	sprintf (hilf, "RSH_ICONBLK = %d",h->rsh_iconblk);
	strcpy ((o + (i++))->ob_spec, hilf);
	sprintf (hilf, "RSH_BITBLK  = %d",h->rsh_bitblk);
	strcpy ((o + (i++))->ob_spec, hilf);
	sprintf (hilf, "RSH_STRING  = %d",h->rsh_string);
	strcpy ((o + (i++))->ob_spec, hilf);
	sprintf (hilf, "RSH_IMDATA  = %d",h->rsh_imdata);
	strcpy ((o + (i++))->ob_spec, hilf);
	sprintf (hilf, "RSH_FRIMG   = %d",h->rsh_frimg);
	strcpy ((o + (i++))->ob_spec, hilf);
	sprintf (hilf, "RSH_TRINDEX = %d",h->rsh_trindex);
	strcpy ((o + (i++))->ob_spec, hilf);
	sprintf (hilf, "RSH_NOBS    = %d",h->rsh_nobs);
	strcpy ((o + (i++))->ob_spec, hilf);
	sprintf (hilf, "RSH_NTREE   = %d",h->rsh_ntree);
	strcpy ((o + (i++))->ob_spec, hilf);
	sprintf (hilf, "RSH_NTED    = %d",h->rsh_nted);
	strcpy ((o + (i++))->ob_spec, hilf);
	sprintf (hilf, "RSH_NIB     = %d",h->rsh_nib);
	strcpy ((o + (i++))->ob_spec, hilf);
	sprintf (hilf, "RSH_NBB     = %d",h->rsh_nbb);
	strcpy ((o + (i++))->ob_spec, hilf);
	sprintf (hilf, "RSH_NSTRING = %d",h->rsh_nstring);
	strcpy ((o + (i++))->ob_spec, hilf);
	sprintf (hilf, "RSH_NIMAGES = %d",h->rsh_nimages);
	strcpy ((o + (i++))->ob_spec, hilf);
	sprintf (hilf, "RSH_RSSIZE  = %d",h->rsh_rssize);
	strcpy ((o + (i++))->ob_spec, hilf);
	form_center (o, &x, &y, &w, &hg);
	form_dial (0, 0, 0, 2, 2, x, y, w, hg);
	form_dial (1, 0, 0, 2, 2, x, y, w, hg);
	objc_draw (o, 0, 8, x, y, w, hg);
	form_do (o, 0);
	form_dial (2, 0, 0, 2, 2, x, y, w, hg);
	form_dial (3, 0, 0, 2, 2, x, y, w, hg);
}
			
