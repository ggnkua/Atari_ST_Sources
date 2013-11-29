/* 

	Beschreibung:			
	Autor:						
	Programmiert vom: .. -
*/

int 								vdi_handle;								/* VDI-Handle 			*/
int 								contrl[12];								/* VDI-Contrl				*/
int 								intin[160];								/* VDI-Intin				*/
int 								intout[40];								/* VDI-Intout				*/
int 								ptsin[20];								/* VDI-Ptsin				*/
int 								ptsout[20];								/* VDI-Ptsout				*/
int 								work_in[11];							/* Workstationinfo	*/
int 								work_out[57];							/*          "				*/

/* ---------------------------- */
/* | Virtuelle Arbeitsstation | */
/* ---------------------------- */
open_vwork()
{
register int i;
int dummy;

vdi_handle = graf_handle(&dummy, &dummy, &dummy, &dummy);

for(i = 0; i < 10; work_in[i++] = 1);
work_in[10] = 2;

v_opnvwk(work_in, &vdi_handle, work_out);
}

/* ---------------------------- */
/* | Arbeitsstation schliežen | */
/* ---------------------------- */
cls_vwork()
{
v_clsvwk(vdi_handle);
}

/* ---------------- */
/* | Hauptroutine | */
/* ---------------- */
main()
{
char formula[128];

appl_init();
open_vwork();

graf_mouse(ARROW, 0L);

scanf("%s", formula);
create_formula(formula);

cls_vwork();
appl_exit();
}

create_formula(formula)
char *formula;
{
char one[128];
register int i, j;

i = 0;
j = 0;
while(formula[j])
	{
	if (formula[j] == '(' && i > 0)
		{
		one[i] = 0;
		draw_f(one);
		i = 0;
		}
		
	one[i++] = formula[j];
	}
}

draw_f(ds)
char *ds;
{
if (strlen(ds) == 1)
	paint_ftxt(ds[0]);
}

/* ----------- */
/* | Zeichne | */
/* ----------- */
paint_ftxt(c)
regicter char c;
{
v_gtext(vdi_handle, x, y,
}
