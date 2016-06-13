/****************************************************************
 * aoctree.c:
 ****************************************************************/

/******
  Copyright (C) 1995 by Klaus Ehrenfried. 

  Permission to use, copy, modify, and distribute this software
  is hereby granted, provided that the above copyright notice appears 
  in all copies and that the software is available to all free of charge. 
  The author disclaims all warranties with regard to this software, 
  including all implied warranties of merchant-ability and fitness. 
  The code is simply distributed as it is.
  *******/

/*******
  This program is based on the Octree algorithm described 
  by Michael Gervautz and Werner Purgathofer (Technical University 
  Vienna, Austria) in the article "A Simple Method for Color Quantization:
  Octree Quantization" published in Graphic Gems edited by Andrew Glassner
  pp. 287 ff.
  *******/

#include <stdio.h>
#include <math.h>
#include <string.h>
#include <stdlib.h>
#include "apro.h"

#define BIGVAL 0x10000000

typedef struct node *OCTREE;

struct node
{
  UBYTE leaf;
  UBYTE level;
  UBYTE color;
  UBYTE rgb[3];
  UBYTE sub_count;
  ULONG pixels_low;
  ULONG pixels_high;
  ULONG red_sum_low;
  ULONG red_sum_high;
  ULONG green_sum_low;
  ULONG green_sum_high;
  ULONG blue_sum_low;
  ULONG blue_sum_high;
  OCTREE sub[8];
  OCTREE next_reduceable;
  OCTREE next_alloc;
};

static void search_colors(OCTREE tree);
static void scan_large_tree(OCTREE tree);
static void reduce_large_octree();
static void norm_tree(OCTREE tree);
static void shorten_list();

#define RED 0
#define GREEN 1
#define BLUE 2

#define TRUE		1
#define FALSE		0

static LONG palette[FLI_MAX_COLORS];

static int octree_size;
static int reduce_level;
static int leaf_level;
static int reduce_start;

static OCTREE basetree;
static OCTREE reduce_list;
static int node_count[MAXDEPTH + 2];
static int reduce_count[MAXDEPTH + 1];
static int tree_count;
static OCTREE alloc_list=NULL;
static UBYTE b_field[]={128,64,32,16,8,4,2,1};

static double color_factor;
static int color_count;

/************************************************************************
 * clr_quantize
 ************************************************************************/

int clr_quantize(PMS *input, UBYTE *p_output, LONG *color)
{
  UBYTE b_red, b_green, b_blue, branch, btest;
  UBYTE *pp;
  OCTREE tree, next_tree, sub_tree;
  int i,j,jmin,d1,d2,d3,dtest,dmin,unexpected;
  double ratio;

  pp = input->pixels;

  unexpected=0;

  for (i=0; i < input->len; i++)
    {
      b_red = *(pp++);
      b_green = *(pp++);
      b_blue = *(pp++);

      tree=basetree;
      next_tree=NULL;

      while (tree->leaf == 0)
	{
	  btest=b_field[tree->level];
	  branch=((b_red & btest) == 0) ? (UBYTE) 0 : (UBYTE) 4;
	  if ((b_green & btest) != 0) branch += (UBYTE) 2;
	  if ((b_blue & btest) != 0) branch += (UBYTE) 1;
	  next_tree=tree->sub[branch];
	  if (next_tree == NULL) break;
	  tree=next_tree;
	}

      if (next_tree == 0)
	{
	  unexpected++;
	  while (tree->leaf == 0)
	    {
	      jmin=-1;
	      dmin=0;
	      for (j=0; j < 8; j++)
		{
		  sub_tree=tree->sub[j];
		  if (sub_tree == NULL) continue;

		  d1=abs((int)sub_tree->rgb[RED] - (int)b_red);
		  d2=abs((int)sub_tree->rgb[GREEN] - (int)b_green);
		  d3=abs((int)sub_tree->rgb[BLUE] - (int)b_blue);

		  dtest=(d1 > d2) ? d1 : d2;
		  dtest=(d3 > dtest) ? d3 : dtest;

		  if ((jmin == -1) || (dtest < dmin))
		    {
		      dmin=dtest;
		      jmin=j;
		    }
		}
	      if (jmin == -1)
		{
		  fprintf(stdout,"Warning: %d\n",i);
		  break;
		}
	      tree=tree->sub[jmin];
	    }
	}

      *(p_output++) = tree->color;
    }

  if (unexpected > 0)
    {
      ratio = 100.0 * unexpected/input->len;
      fprintf(stdout," Quantize: %d non-fitting pixel(s) = %.4f %%\n",
	      unexpected, ratio);
    }

  for (i=0; i < FLI_MAX_COLORS; i++)
    color[i]=palette[i];

  return(color_count);
}

/************************************************************************
 * prepare_quantize                                                     *
 ************************************************************************/

void prepare_quantize()
{
  int i;

  /* final reduction */
  for (i=0; i <= MAXDEPTH; i++)
    {
      reduce_count[i]=0;
    }

  reduce_start = leaf_level - 1;
  for (i = 1; i < leaf_level; i++)
    {
      if (node_count[i] >= max_colors)
	{
	  reduce_start = i - 1;
	  break;
	}
    }

  reduce_level = reduce_start + reduce_dynamics;
  if (reduce_level >= leaf_level)
    {
      reduce_level = leaf_level - 1;
      reduce_start = reduce_level - reduce_dynamics;
      if (reduce_start < 0) reduce_start = 0;
    }
  else
    {
      leaf_level = reduce_level + 1;
    }

  /*
     if (verbose_flag > 1)
     { 
     fprintf(stdout,"  octree reduction in levels %d to %d\n",
     reduce_start,
     reduce_level);
     }
     */

  octree_size=0;
  reduce_list=NULL;
  scan_large_tree(basetree);
  shorten_list();
  while (octree_size > max_colors)
    {
      /* fprintf(stderr,"%d\n",octree_size); */
      reduce_large_octree();
    }
  /***
  if (verbose_flag > 1)
    {
      fprintf(stdout," Octree - reduce count:");
      for (i=0; i <= MAXDEPTH; i++)
	{
	  if ((i >= reduce_start) && (i <= reduce_level))
	    {
	      fprintf(stdout," %d", reduce_count[i]);
	    }
	  else
	    {
	      fprintf(stdout," -");
	    }
	}
      fprintf(stdout,"\n");
    }
    ****/

  /* now the colors */

  for (i = 0; i < FLI_MAX_COLORS; i++)          /* init palette */
    palette[i] = 0;

  color_count = 0;
  color_factor = (double) ((1 << color_depth) - 1) / 0xFF;

  for (i=0; i <= (MAXDEPTH+1); i++)
    {node_count[i] = 0;}

  search_colors(basetree);
  if (verbose_flag > 0)
    fprintf(stdout," Number of colors: %d\n",color_count);
  if (verbose_flag > 1)
    {
      fprintf(stdout," Octree - leaf count (%d):", leaf_level);
      for (i=0; i <= (MAXDEPTH + 1); i++)
	{
	  fprintf(stdout," %d",node_count[i]);
	}
      fprintf(stdout,"\n");
    }


  for (i = color_count; i < FLI_MAX_COLORS; i++) /* no extra 0 0 0 */
    palette[i] = palette[0];
}

/************************************************************************
 * scan_rgb_image                                                       *
 ************************************************************************/

void scan_rgb_image(char *file_name)
{
  PMS input;

  fprintf(stdout,"Scanning '%s'\n",file_name);

  input.pixels = (UBYTE *) NULL;
  if (!read_image(&input, file_name))
    {
      fprintf(stderr,"Error processing '%s'\n",file_name);
      exitialise(1);
      exit(1);
    }

  add_to_large_octree(&input);
  tree_count = 0;
  norm_tree(basetree);
  if (verbose_flag > 1)
    {
      fprintf(stdout," Octree - total size: %d\n",tree_count);
    }

  free_pms(&input);
}

/************************************************************************
 * add_to_large_octree
 ************************************************************************/

void add_to_large_octree(PMS *image)
{
  UBYTE b_red, b_green, b_blue, branch, btest;
  UBYTE *pp;
  OCTREE tree, *p_tree;
  int i, depth, new_flag;

  pp = image->pixels;

  for (i=0; i < image->len; i++)
    {
      b_red = *(pp++);
      b_green = *(pp++);
      b_blue = *(pp++);

      p_tree = &basetree;
      new_flag = 0;

      for (depth = 0; depth <= leaf_level; depth++)
	{
	  if (*p_tree == NULL)            /* init new node */
	    {
	      tree = (OCTREE) calloc(1, sizeof(struct node));
	      if (tree == NULL)
		{
		  printf("Out of memory");
		  exit(1);
		}
	      tree->next_alloc=alloc_list;
	      alloc_list=tree;
	      tree->level = depth;
	      (node_count[depth])++;
	      new_flag = 1;
	      *p_tree = tree;
	    }
	  else
	    tree = *p_tree;

	  tree->pixels_low++;
	  tree->red_sum_low += b_red;
	  tree->green_sum_low += b_green;
	  tree->blue_sum_low += b_blue;

	  if (depth < leaf_level)
	    {
	      btest=b_field[depth];
	      branch=((b_red & btest) == 0) ? (UBYTE) 0 : (UBYTE) 4;
	      if ((b_green & btest) != 0) branch += (UBYTE) 2;
	      if ((b_blue & btest) != 0) branch += (UBYTE) 1;

	      if (tree->sub[branch] == NULL)
		tree->sub_count++;
	      p_tree=&(tree->sub[branch]);
	    }
	}

      if (new_flag)
	{
	  for (depth = 0; depth < leaf_level; depth++)
	    {
	      if (node_count[depth] >= node_limit)     /* reduce octree */
		{
		  leaf_level=depth;
		  break;
		}
	    }
	}
    }

  for (depth = (leaf_level+1); depth <= (MAXDEPTH+1) ;depth++)
    node_count[depth] = 0;

  if (verbose_flag > 1)
    {
      fprintf(stdout," Octree - node count (%d):", leaf_level);
      for (i=0; i <= (MAXDEPTH + 1); i++)
	{
	  fprintf(stdout," %d",node_count[i]);
	}
      fprintf(stdout,"\n");
    }

}

/************************************************************************
 * clear_octree                                                         *
 ************************************************************************/

void clear_octree()
{
  OCTREE next_node;
  int i;

  for (i=0; i <= MAXDEPTH+1; i++)
    {
      node_count[i]=0;
    }
  leaf_level = MAXDEPTH + 1;

  basetree=NULL;

  while (alloc_list != NULL)
    {
      next_node=alloc_list->next_alloc;
      free(alloc_list);
      alloc_list=next_node;
    }
}

/************************************************************************
 * output_palette
 ************************************************************************/

int output_palette()
{
  LONG rgb_value;
  int i, red, green, blue;

  fprintf(output,"P3\n");
  fprintf(output,"%d 1\n",color_count);
  fprintf(output,"255\n");
  fprintf(output,"#   r   g   b    index\n");
  fprintf(output,"#---------------------\n");

  for (i = 0; i < color_count; i++)
    {
      rgb_value = palette[i];
      red=rgb_value % 256;
      rgb_value=(rgb_value - red)/256;
      green=rgb_value % 256;
      rgb_value=(rgb_value - green)/256;
      blue=rgb_value % 256;
 
      fprintf(output,"  %3d %3d %3d  # %d\n",red, green, blue, i);
    }
 
  return(1);
}

/************************************************************************
 * search_colors
 ************************************************************************/

static void search_colors(OCTREE tree)
{
  int j;
  LONG rgb_value;
  double dhelp0, dhelp1;

  if (tree == NULL) return;

  dhelp0=(double) tree->pixels_high * (double) BIGVAL
    +(double) tree->pixels_low;

  dhelp0=color_factor / dhelp0;

  dhelp1=
    (double) tree->red_sum_high * (double) BIGVAL
      +(double) tree->red_sum_low;
  tree->rgb[RED] = (char) (dhelp0 * dhelp1 + 0.5);

  dhelp1=
    (double) tree->green_sum_high * (double) BIGVAL
      +(double) tree->green_sum_low;
  tree->rgb[GREEN] = (char) (dhelp0 * dhelp1 + 0.5);

  dhelp1=
    (double) tree->blue_sum_high * (double) BIGVAL
      +(double) tree->blue_sum_low;
  tree->rgb[BLUE] = (char) (dhelp0 * dhelp1 + 0.5);

  if (tree->leaf || tree->level == leaf_level)
    {
      rgb_value=(long int) tree->rgb[BLUE];
      rgb_value=256L * rgb_value + (long int) tree->rgb[GREEN];
      rgb_value=256L * rgb_value + (long int) tree->rgb[RED];

      palette[color_count] = rgb_value;

      tree->color = color_count;
      tree->leaf = TRUE;
      color_count++;
      (node_count[tree->level])++;
    }
  else
    {
      for (j = 0; j < 8; j++)
	search_colors(tree->sub[j]);
    }
}

/************************************************************************
 * scan_large_tree                                                       *
 ************************************************************************/

static void scan_large_tree(OCTREE tree)
{
  int j;

  if (tree == NULL) return;
  if ((tree->level <= reduce_level) && 
      (tree->level >= reduce_start))
    {
      if (tree->sub_count > 0)
	{
	  tree->next_reduceable = reduce_list;
	  reduce_list = tree;
	}
    }

  if (tree->level == leaf_level)
    {
      tree->leaf = TRUE;
      octree_size++;
    }
  else
    {
      tree->leaf = FALSE;
      for (j = 0; j < 8; j++)
	scan_large_tree(tree->sub[j]);
    }
}

/************************************************************************
 * shorten_list()
 ************************************************************************/

static void shorten_list()
{
  int i, flag, depth, n;
  OCTREE tree, sub_tree, *p_tree;

  p_tree = &reduce_list;
  n = 0;
  
  while ((tree = *p_tree) != NULL)
    {
      if (tree->sub_count == 1)
	{
	  flag = 1;
	  for (i=0; i < 8; i++)
	    {
	      sub_tree=tree->sub[i];
	      if (sub_tree != NULL)
		{ if (sub_tree->leaf == 0) {flag = 0;} }
	    }

	  if (flag == 1)
	    {
	      tree->leaf = 1;
	      depth = tree->level;
	      (reduce_count[depth])++;
	      *p_tree=tree->next_reduceable;
	      n++;
	    }
	  else
	    {
	      p_tree=&(tree->next_reduceable);
	    }
	}
      else
	{
	  p_tree=&(tree->next_reduceable);
	}
    }

  /***
  if ((verbose_flag > 1) && (n > 0))
    {
      fprintf(stdout," Octree - drop   count:");
      for (i=0; i <= MAXDEPTH; i++)
	{
	  if ((i >= reduce_start) && (i <= reduce_level))
	    { fprintf(stdout," %d", reduce_count[i]);}
	  else
	    { fprintf(stdout," -");}
	}
      fprintf(stdout,"\n");
    }
    ****/
}

/************************************************************************
 * reduce_large_octree
 ************************************************************************/

static void reduce_large_octree()
{
  int i, flag, depth;
  ULONG min_high, min_low;
  OCTREE tree, sub_tree, *p_tree, *p_min;

  if (reduce_list == NULL)
    {
      fprintf(stderr,"Internal error: ZERO reduce\n");
      exit(1);
    }

  p_min = &reduce_list;
  min_high = reduce_list->pixels_high;
  min_low = reduce_list->pixels_low;
  p_tree = &(reduce_list->next_reduceable);

  while ((tree = *p_tree) != NULL)
    {
      flag = 1;
      for (i=0; i < 8; i++)
	{
	  sub_tree=tree->sub[i];
	  if (sub_tree != NULL)
	    { if (sub_tree->leaf == 0) {flag = 0;} }
	}
      if (flag == 1)
	{
	  if ((tree->pixels_high < min_high) ||
	      ((tree->pixels_high == min_high) &&
	       (tree->pixels_low < min_low)))
	    {
	      p_min = p_tree;
	      min_high=tree->pixels_high;
	      min_low=tree->pixels_low;
	    }
	}
      p_tree=&(tree->next_reduceable);
    }

  tree = *p_min;
  *p_min=tree->next_reduceable;
  tree->leaf = 1;
  octree_size = octree_size - tree->sub_count + 1;
  depth = tree->level;
  (reduce_count[depth])++;
}

/************************************************************************
 * norm_tree                                                            *
 ************************************************************************/

static void norm_tree(OCTREE tree)
{
  OCTREE subtree;
  int i;

  tree_count++;

  while (tree->pixels_low >= BIGVAL)
    {
      tree->pixels_low -= BIGVAL;
      tree->pixels_high++;
    }

  while (tree->red_sum_low >= BIGVAL)
    {
      tree->red_sum_low -= BIGVAL;
      tree->red_sum_high++;
    }

  while (tree->green_sum_low >= BIGVAL)
    {
      tree->green_sum_low -= BIGVAL;
      tree->green_sum_high++;
    }

  while (tree->blue_sum_low >= BIGVAL)
    {
      tree->blue_sum_low -= BIGVAL;
      tree->blue_sum_high++;
    }

  if (tree->leaf == FALSE && tree->level < leaf_level)
    {
      for (i=0; i < 8; i++)
	{
	  subtree=tree->sub[i];
	  if (subtree != NULL)
	    norm_tree(subtree);
	}
    }
}


/*** - FIN - ****************************************************************/
