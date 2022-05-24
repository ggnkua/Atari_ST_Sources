/* ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
   บ               Program Documentation                                  บ
   ฬออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออน
   บ    Title       : Temperature Module (graph routine)                  บ
   บ    Written by  : Neil Evans                                          บ
   บ    Tutor       : Mike Smith                                          บ
   บ    Ass Cat     : ICS                                                 บ
   บ    Ass due     : 29/1/93                                             บ
   บ    Copyright   : (c) Neil Evans 1993                                 บ
   บ    Modification: Written in MS QuickC not TurboC                     บ
   บ                                                                      บ
   บ                                                                      บ
   บ                                                                      บ
   บ                                                                      บ
   บ                                                                      บ
   ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/

#include <stdio.h>
#include <graph.h>
void exit(void);
void axis_title(void);
void plot_point(int,float,int);
void main()
{
	FILE *fp;
	int t,p,average;
	float shift_a[20];

	axis_title();
	t=0;

	if ((fp=fopen("d:tempdat.dat","rb"))==NULL)
		{
		printf("cannot open file\n");
		exit();
		}
		while(!feof(fp))

		{
			fscanf(fp,"%f\n",&shift_a[t]);
			t++;
		}

		fclose(fp);
		p=t;
		average=610/p;
		for (t=0;t<p;t++)
		{
		plot_point(t,shift_a[t],average);
		}


}

void axis_title()
{
_setvideomode(_VRES16COLOR);
_settextcolor(_WHITE);
_moveto(50,105);
_lineto(50,450);
_moveto(30,380);
_lineto(640,380);
_moveto(50,380);
/*Insert Text positioning Here */
_settextposition(15,0);
printf("Temp\nin C");
_settextposition(25,38);
printf("time");
_settextposition(25,6);
printf("0");
_settextposition(3,30);
printf("Graph showing time against temp");
}

void plot_point(int time,float temp,int aver)
{
int ypos,xpos,temp3;
float temp2;
_settextcolor(_WHITE);

xpos = (time*aver)+50;

temp2 = temp*10.0;
temp3 =(int)temp2;
ypos = 380-((temp3)/2);
_lineto(xpos,ypos);
}
