/*****************************************************************************/
/*      File    : SORT.C                        Copyright (c) 1992           */
/*                                                                           */
/*      Author  : Kenneth W. Hartlen                                         */
/*      Address : Box 37, Site 6, RR#3                                       */
/*                Armdale, Nova Scotia                                       */
/*                B3L 4J3 Canada                                             */
/*                                                                           */
/*      Purpose : Simple program that uses graphics commands and can be      */
/*                be compiled in Lattice C, Sozobon C and Turbo C.	     */
/*                                                                           */
/*                This programs show, graphically, how the bubble sort,      */
/*                insertion sort, selection sort and quick sort work.        */
/*                                                                           */
/*                Insertion sort and selection sort algorithms from:         */
/*                "Data Structures and Progam Design", Robert L. Kruse       */
/*                                                                           */
/*                Quick sort algorithm from:                                 */
/*                "The C Programming Language", 2nd Ed., Kernighan & Ritchie */
/*****************************************************************************/
/*      Compiling with Lattice C:                                            */
/*              lc.ttp -fm sort.c                                            */
/*              clink.ttp c.o+sort.o                                         */
/*                      LIB graphics.lib+lcm.lib+lcg.lib+lc.lib              */
/*                      TO sort.prg                                          */
/*                                                                           */
/*      Compiling with Sozobon C:                                            */
/*              cc -c sort.c                                                 */
/*              cc -o sort.prg -r sort.o graphics.a aesfast.a vdifast.a      */
/*                                                                           */
/*	Compiling with Heat & Serve Sozobon C v1.33i:			     */
/*		cc -c lines.c						     */
/*		cc -o lines.prg lines.o graphics.a libm.a aesfast.a \	     */
/*				vdifast.a				     */
/*                                                                           */
/*      Compile with Turbo C:                                                */
/*              Use Turbo C's IDE                                            */
/*                                                                           */
/*****************************************************************************/

#ifdef	SOZOBON
#define __MAIN_SRC__                    /* to be included with user's source */
#endif

#include <stdio.h>                      /* common header files */
#include <graphics.h>

#ifndef	SOZOBON				/* includes for Lattice and Turbo */
#include <stdlib.h>
#include <dos.h>
#endif

#ifndef	__TURBOC__			/* includes for Lattice and Sozobon */
#include <osbind.h>
#endif

/*****************************************************************************/
/*  Main program loop                                                        */
/*****************************************************************************/

#define NUMPOINTS       100             /* maximum # of lines to display */

int     maxX,                           /* save getmaxx() result */
        maxY,                           /* save getmaxy() result */
        numcolours,
        width,
        points[NUMPOINTS],              /* array holding values */
        seed;                           /* random number seed */

#ifdef __TURBOC__
struct time now;
#endif

/*****************************************************************************/
/*      Function prototypes                                                  */
void build_list();
void display_graph();
void update_graph();
void pause();

int maxkey();
void swap();

void bubble_sort();
void insertion_sort();
void selection_sort();

void q_sort();
void quick_sort();

/*****************************************************************************/
void main()
{
int     graphdriver = DETECT, graphmode;


    /* initialize graphics */
    initgraph(&graphdriver,&graphmode,"");

    maxX = getmaxx();                   /* save values to eliminate     */
    maxY = getmaxy() - textheight("H"); /* function call in the do loop */
    numcolours = getmaxcolor();
    width = maxX / NUMPOINTS;

    /* Display Title screen */
    setcolor(WHITE);
    settextjustify(CENTER_TEXT,TOP_TEXT);
    outtextxy(maxX/2,maxY/3,"SORT DEMO");
    outtextxy(maxX/2,maxY/3+textheight("H")*2,"by Kenneth W. Hartlen");
    outtextxy(maxX/2,maxY/3+textheight("H")*4,"Copyright (c) 1992");
    outtextxy(maxX/2,maxY/3+textheight("H")*7,"press a key to continue");
    rectangle(0,0,maxX,maxY);
    getch();

    /* initialize variables */
    #ifdef __TURBOC__                   /* get system time for use as the */
    gettime(&now);                      /* random number generator seed   */
    seed = now.ti_sec;
    #else
    seed = Tgettime();
    #endif

    build_list(seed,points,NUMPOINTS);
    display_graph(points,NUMPOINTS,"Bubble Sort");
    bubble_sort(points,NUMPOINTS);
    pause("Press any key to continue...");

    build_list(seed,points,NUMPOINTS);
    display_graph(points,NUMPOINTS,"Insertion Sort");
    insertion_sort(points,NUMPOINTS);
    pause("Press any key to continue...");

    build_list(seed,points,NUMPOINTS);
    display_graph(points,NUMPOINTS,"Selection Sort");
    selection_sort(points,NUMPOINTS);
    pause("Press any key to continue...");

    build_list(seed,points,NUMPOINTS);
    display_graph(points,NUMPOINTS,"Quick Sort");
    quick_sort(points,NUMPOINTS);
    pause("Demo finished. Press any key...");
    
    closegraph();                       /* close graphics */
    return;
        
} /* main */

/*****************************************************************************/
/*      Generate a list of random number to sort                             */
void build_list(seed, points, num)
int seed, points[], num;
{
int     i;

    srand(seed);    
    for(i=0;i<num;i++)
        points[i] = rand() % maxY;

}

/*****************************************************************************/
/*      Display a graph of the list                                          */
void display_graph(points, num, name)
int points[], num;
char *name;
{
int     i,pat,col;
    
    cleardevice();
    rectangle(0,0,(width*num)+2,maxY);
    settextjustify(LEFT_TEXT,TOP_TEXT);
    outtextxy(0,maxY+1,"0");
    outtextxy( (width*num)-textwidth("99"),maxY+1,"99");
    settextjustify(CENTER_TEXT,TOP_TEXT);
    outtextxy((width*num)/2,maxY+1,name);
        
    for(i=0;i<num;i++) {
        if (numcolours == 1) {
            pat=((points[i] * 12) / maxY ) + 1;
            setfillstyle(pat,WHITE);
        }
        else {
            col=((points[i] * numcolours) / maxY ) + 1;
            setfillstyle(SOLID_FILL,col);
        }
        bar((i*width)+1,maxY-points[i],((i+1)*width)-1,maxY);
    }
    
}

/*****************************************************************************/
/*      Update the graph                                                     */
void update_graph(points, i)
int points[], i;
{
int     pat,col;
    
    if (numcolours == 1) {
        pat=((points[i] * 12) / maxY ) + 1;
        setfillstyle(pat,WHITE);
    }
    else {
        col=((points[i] * numcolours) / maxY ) + 1;
        setfillstyle(SOLID_FILL,col);
    }
    bar((i*width)+1,maxY-points[i],((i+1)*width)-1,maxY);

    setfillstyle(SOLID_FILL, BLACK);
    bar((i*width)+1,1,((i+1)*width)-1,maxY-points[i]-1);
    
}

/*****************************************************************************/
/*      Wait for user to press a key                                         */

void pause(msg)
char *msg;
{
    settextjustify(CENTER_TEXT,TOP_TEXT);
    outtextxy(maxX/2,10,msg);
    getch();
}

/*****************************************************************************/
/*      Various support functions for sort routines                          */
int maxkey(L, low, high)
int L[], low, high;
{
int     m,j;

    m = low;
    for (j=low+1;j<=high;j++) {
        if (L[m] < L[j])
            m = j;
    }
    return m;
    
}

void swap(L, x, y)
int L[], x, y;
{
int     t;

    t = L[x];
    L[x] = L[y];
    L[y] = t;
    update_graph(L,x);
    update_graph(L,y);
    
}
    
/*****************************************************************************/
/*      Perform a bubble sort on the list                                    */
void bubble_sort(L, n)
int L[], n;
{
int     i,j;

    for (i=0;i<n;i++)
        for (j=i+1;j<n;j++)
            if (L[i] > L[j])
                swap(L,i,j);
                
}

/*****************************************************************************/
/*      Perform an insertion sort on the list                                */
void insertion_sort(L, n)
int L[], n;
{
int     i,j,found,t;

    for(i=1;i<n;i++) {
        if (L[i] < L[i-1]) {
            j = i;
            t = L[i];
            do {
                j = j - 1;
                L[j+1] = L[j];
                update_graph(L,j+1);
                if (j==0)
                    found = 1;
                else
                    found = (L[j-1] <= t);
            } while (!found);
            L[j] = t;
            update_graph(L,j);
        }
    }
                    
}

/*****************************************************************************/
/*      Perform a selection sort on the list                                 */
void selection_sort(L, n)
int L[], n;
{
int     i,m;

    for(i=n-1;i>=1;i--) {
        m = maxkey(L,0,i);
        swap(L,m,i);
    }
}

/*****************************************************************************/
/*      Perform a quick sort on the list                                     */
void quick_sort(points, num)
int points[], num;
{
        q_sort(points,0,num-1);
}

void q_sort(v, left, right)
int v[], left, right;
{
int     i,last;

    if (left >= right)
        return;
        
    swap(v,left,right);
    last = left;
    for (i=left+1;i<=right;i++)
        if (v[i] < v[left])
            swap(v,++last,i);
    swap(v,left,last);
    q_sort(v,left,last-1);
    q_sort(v,last+1,right);
    
}

