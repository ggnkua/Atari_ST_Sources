/*-------------------------------------------------------------------------

		 Triangle Bounder/Smoother for POV-Ray
		    Copyright (c) 1993 Steve Anger

    A number of C routines that can be used to generate POV-Ray ray tracer
 files from triangle data.  Supports generation of smooth triangles and an
 optimal set of bounding shapes for much faster traces.  Output files are
 compatible with POV-Ray v1.0.  This program may be freely modified and
 distributed.
					   Compuserve: 70714,3113
					    YCCMR BBS: (708)358-5611

--------------------------------------------------------------------------*/

#if !defined(__GNUC__) && !defined(applec) && !defined(THINK_C)
#include <alloc.h>
#endif

#include <stdio.h>
/* #include <portab.h> */
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <math.h>
#include "vect.h"
#include "rayopt.h"

#if defined(applec) || defined(THINK_C)
#include "RAW2POV.mac.h"
#else
#define COOPERATE
#endif

#define HASHSIZE  1000          /* Size of hash table for vertex lookup */
#define DEGEN_TOL (1e-8)        /* float comparison tolerance for checking */
				/* for degenerate triangles */
#define MAX_TEX   400           /* Maximum allowable number of texture */
				/* declarations */

#define POV10   0
#define POV20   1
#define VIVID   2
#define POLYRAY 3

#ifndef MAXFLOAT
#define MAXFLOAT (1e37)
#endif

typedef struct {
    float red;
    float green;
    float blue;
} Palette;

typedef char *Texture;

typedef struct {
    unsigned vert[3];
    unsigned text_index;
    char     text_type;
    char     flag;
} Triangle;


/* Linked list of triangles */
typedef struct TList {
    Triangle     *tri;
    struct TList *next;
} TriList;


/* Double linked list of triangles */
typedef struct TList2 {
    Triangle      *tri;
    struct TList2 *prev;
    struct TList2 *next;
} TriList2;


/* List of triangle vertices */
typedef struct VList {
    unsigned     vert;
    struct VList *next;
} VertList;


/* List of triangle groups */
typedef struct GTree {
    TriList2     *index[3];    /* Triangles indexed by x, y, and z coord */
    Vector       vmin;         /* min/max extents of triangle vertices */
    Vector       vmax;         /*    "       "     "     "        "     */
    float        area;         /* Total surface area of bounding region */
    unsigned     obj_cnt;      /* Total number of triangles in group */
    int          child_cnt;    /* Number of children */
    int          split_cnt;    /* Number of times this node has been split */
    struct GTree *parent;      /* Parent of this node */
    struct GTree *next;        /* Next node at this level */
    struct GTree *child;       /* First child of this ndoe */
} GroupTree;

static Palette   *ptable;      /* Palette table */
static unsigned  pmax;         /* Maximum size of table */
static unsigned  psize;        /* Current size */

static Texture   *ttable;      /* Named texture table */
static unsigned  tmax;         /* Maximum size of table */
static unsigned  tsize;        /* Current size */

static Vector    *vtable;      /* Vertice table */
static unsigned  vmax;         /* Maximum size of table */
static unsigned  vsize;        /* Current size */

static Vector    gmin = {+MAXFLOAT, +MAXFLOAT, +MAXFLOAT};
static Vector    gmax = {-MAXFLOAT, -MAXFLOAT, -MAXFLOAT};

static Matrix    trans_matrix;
static int       use_transform = 0;

static VertList  **vert_hash;    /* Hash table for looking up vertices */
static TriList   **tri_index;    /* Index for smooth triangle generation */

static GroupTree *groot;         /* Tree representing the object hierarchy */

static int       initialized  = 0;
static int       quiet_mode   = 0;
static int       bound_mode   = 0;
static float     smooth_angle = 0.0;
static unsigned  vert_init    = 0;
static int       dec_point    = 4;
static int       out_format   = POV10;

static char      out_file[64] = "rayopt.pov";
static char      inc_file[64] = "rayopt.inc";

static unsigned  tot_bounds   = 0;
static unsigned  object_cnt   = 0;

static Vector    last_vmin = {0.0, 0.0, 0.0};
static Vector    last_vmax = {0.0, 0.0, 0.0};
static unsigned  last_vert_cnt = 0;
static unsigned  last_tri_cnt = 0;
static float     last_index = 0.0;
static unsigned  last_bounds = 0;

static Palette   last_pal;
static char      last_texture[64] = "";
static unsigned  texture_index;
static char      texture_type;
static char      object_name[64] = "";

static float     orig_tpr;    /* Number of Tests Per Ray before optimization */
static float     final_tpr;   /*    "   "    "    "   "  after optimization */
static float     bound_cost;  /* Cost of testing a bound relative to testing */
			      /* a triangle */

/* Function prototypes */
/* RAYOPT.C 07/03/93 00.38.56 */
void init_object (void);
void cleanup_object (void);
float calc_tpr (GroupTree *gnode);
GroupTree *create_group (void);
void delete_tree (GroupTree *gnode);
void optimize_tree (GroupTree *gnode);
void test_split (GroupTree *gnode, int axis, float *best_rtpr, TriList2 **
	best_loc);
void split_group (GroupTree *gnode, int axis, TriList2 *split_loc, GroupTree *
	*group_a, GroupTree **group_b);
void write_file (void);
void write_pov10_tree (FILE *f, GroupTree *gnode, int level);
void write_pov10_texture (FILE *f, Triangle *tri);
void write_pov10_transform (FILE *f, Matrix matrix);
void write_pov10_header (FILE *f);
void write_pov10_triangle (FILE *f, Triangle *tri, int one_texture);
void write_pov10_bound (FILE *f, GroupTree *gnode);
void write_pov20_tree (FILE *f, GroupTree *gnode);
void write_pov20_transform (FILE *f, Matrix matrix);
void write_pov20_texture (FILE *f, Triangle *tri);
void write_pov20_header (FILE *f);
void write_pov20_triangle (FILE *f, Triangle *tri);
void write_vivid_tree (FILE *f, GroupTree *gnode);
void write_vivid_transform (FILE *f, Matrix matrix);
void write_vivid_texture (FILE *f, Triangle *tri);
void write_vivid_header (FILE *f);
void write_vivid_triangle (FILE *f, Triangle *tri);
void write_polyray_tree (FILE *f, GroupTree *gnode);
void write_polyray_transform (FILE *f, Matrix matrix);
void write_polyray_texture (FILE *f, Triangle *tri);
void write_polyray_header (FILE *f);
void write_polyray_triangle (FILE *f, Triangle *tri);
void update_node (GroupTree *gnode);
void sort_indexes (GroupTree *gnode);
void quick_sort (TriList2 *start, TriList2 *end, int axis);
float surf_area (float a, float b, float c);
float max_vertex (Triangle *tri, int axis);
float min_vertex (Triangle *tri, int axis);
float avg_vertex (Triangle *tri, int axis);
void build_tri_index (void);
void dump_tri_index (void);
void vert_normal (Triangle *t, Vector *norm);
void tri_normal (Triangle *t, Vector normal);
unsigned pal_lookup (float red, float green, float blue);
unsigned texture_lookup (char *texture_name);
unsigned vert_lookup (float x, float y, float z);
int degen_tri (float ax, float ay, float az, float bx, float by, float bz,
	 float cx, float cy, float cz);
void abortmsg (char *msg, int exit_code);
float fmin (float a, float b);
float fmax (float a, float b);
void add_ext (char *fname, char *ext, int force);
void cleanup_name (char *name);


void opt_set_format (int format)
{
    if (format != POV10 && format != POV20 && format != VIVID && format != POLYRAY)
	abortmsg ("ERROR: Invalid parameter passed to opt_set_format.", 1);

    out_format = format;
}


void opt_set_fname (char *out_name, char *inc_name)
{
    FILE *f;

    strcpy (out_file, out_name);

    if (strlen(inc_name) > 0)
	strcpy (inc_file, inc_name);
    else {
	strcpy (inc_file, out_file);

	switch (out_format) {
	    case POV10:
	    case POV20:   add_ext (inc_file, "inc", 1);
			  break;
	    case VIVID:   add_ext (inc_file, "vo", 1);
			  break;
	    case POLYRAY: add_ext (inc_file, "inc", 1);
			  break;
	}
    }

    if (strcmp (out_file, inc_file) == 0)
	abortmsg ("Main file and include file cannot have the same name", 1);

    if ((f = fopen (out_file, "w")) == NULL) {
	printf ("Cannot open output file %s\n", out_file);
	exit (1);
    }

    fclose (f);

    if ((f = fopen (inc_file, "w")) == NULL) {
	printf ("Cannot open output file %s\n", inc_file);
	exit (1);
    }

    fclose (f);
}


void opt_set_quiet (int quiet)
{
    if (quiet != 0 && quiet != 1)
	abortmsg ("ERROR: Invalid parameter passed to opt_set_quiet.", 1);

    quiet_mode = quiet;
}


void opt_set_bound (int bound)
{
    if (bound != 0 && bound != 1 && bound != 2)
	abortmsg ("ERROR: Invalid parameter passed to opt_set_bound.", 1);

    bound_mode = bound;
}


void opt_set_smooth (float  smooth)
{
    if (smooth < 0.0 || smooth > 180.0)
	abortmsg ("ERROR: Invalid parameter passed to opt_set_smooth.", 1);

    smooth_angle = smooth;
}


void opt_set_vert (unsigned vert)
{
    vert_init = vert;
}


void opt_set_dec (int dec)
{
    if (dec < 0 || dec > 9)
	abortmsg ("ERROR: Invalid parameter passed to opt_set_dec.", 1);

    dec_point = dec;
}


void opt_set_color (float  red, float  green, float  blue)
{
    if (!initialized)
	init_object();

    if (last_pal.red != red || last_pal.green != green ||
			       last_pal.blue != blue || psize == 0)
    {
	last_pal.red   = red;
	last_pal.green = green;
	last_pal.blue  = blue;

	texture_index = pal_lookup (red, green, blue);
    }

    texture_type = 0;   /* An RGB texture */
}


void opt_set_texture (char *texture_name)
{
    char new_texture[64];

    if (!initialized)
	init_object();

    strcpy (new_texture, texture_name);
    cleanup_name (new_texture);

    if (strcmp (last_texture, new_texture) != 0) {
	strcpy (last_texture, new_texture);
	texture_index = texture_lookup (new_texture);
    }

    texture_type = 1;   /* A named texture */
}


/* Set a transformation matrix for the next object */
void opt_set_transform (Matrix mx)
{
    int i, j;

    for (i = 0; i < 4; i++) {
	for (j = 0; j < 3; j++)
	    trans_matrix[i][j] = mx[i][j];
    }

    use_transform = 1;
}


void opt_clear_transform()
{
    use_transform = 0;
}


/* Add a new triangle to the database */
int opt_add_tri (float  ax, float  ay, float  az,
		 float  bx, float  by, float  bz,
		 float  cx, float  cy, float  cz)
{
    TriList2 *new_node;
    Triangle *new_tri;
    int      i;

    /* Check if the triangle is degenerate (zero area), if so return -1 */
    if (degen_tri (ax, ay, az, bx, by, bz, cx, cy, cz))
	return -1;

    if (!initialized)
	init_object();

    /* Allocate memory for the new triangle */
    new_tri = malloc (sizeof(Triangle));
    if (new_tri == NULL)
	abortmsg ("Insufficient memory for new triangles.", 1);

    /* Look up the vertex and texture indexes */
    new_tri->vert[0] = vert_lookup (ax, ay, az);
    new_tri->vert[1] = vert_lookup (bx, by, bz);
    new_tri->vert[2] = vert_lookup (cx, cy, cz);

    new_tri->text_index = texture_index;
    new_tri->text_type  = texture_type;

    new_tri->flag = 0;

    for (i = 0; i < 3; i++) {
	/* Create a new index node */
	new_node = malloc (sizeof(TriList2));
	if (new_node == NULL)
	    abortmsg ("Insufficient memory for triangles.", 1);

	/* Point the index entry to the new triangle */
	new_node->tri = new_tri;

	/* Insert the new index node into the list */
	new_node->next = groot->index[i];
	new_node->prev = groot->index[i]->prev;
	groot->index[i]->prev->next = new_node;
	groot->index[i]->prev = new_node;
    }

    ++(groot->obj_cnt);

    return 0;
}


/* For compatability */
void opt_write_pov (char *obj_name)
{
    opt_write_file (obj_name);
}


/* Optimize and write file */
void opt_write_file (char *obj_name)
{
    VertList *temp;
    int      i;

    if (out_format != POV10)
	bound_mode = 2;

    if (!initialized || groot->obj_cnt == 0) {
	orig_tpr = 1.0;
	final_tpr = 0.0;
	tot_bounds = 0;
	return;   /* No triangles where ever added, nothing to write */
    }

    strcpy (object_name, obj_name);
    cleanup_name (object_name);

    ++object_cnt;

    /* Dump the hash table, don't need it any more */
    for (i = 0; i < HASHSIZE; i++) {
	while (vert_hash[i] != NULL) {
	    temp = vert_hash[i];
	    vert_hash[i] = vert_hash[i]->next;
	    free (temp);
	}
    }

    /* Build the vertice index */
    build_tri_index();

    if (bound_mode != 2) {
	if (!quiet_mode)
	    printf ("Building indexes\n");

	sort_indexes (groot);
    }

    update_node (groot);

    if (!quiet_mode) {
	printf ("Adding bounds (1)\r");
	fflush(stdout);;
    }

    /* Optimize the tree */
    orig_tpr = calc_tpr (groot);

    if (bound_mode != 2)
	optimize_tree (groot);

    final_tpr = calc_tpr (groot);

    /* Write the file */
    write_file();

    /* Free up the vertex index */
    dump_tri_index();

    cleanup_object();
}


void opt_finish()
{
    FILE *f;

    f = fopen (out_file, "a");

    switch (out_format) {
	case POV10:
	    fprintf (f, "composite {  /* All Objects */\n");
	    fprintf (f, "    #include \"%s\"\n", inc_file);

	    if (object_cnt > 2) {
		fprintf (f, "\n");
		fprintf (f, "    bounded_by {\n");
		fprintf (f, "        box { <%.4f %.4f %.4f> <%.4f %.4f %.4f> }\n",
					 gmin[X], gmin[Y], gmin[Z],
					 gmax[X], gmax[Y], gmax[Z]);
		fprintf (f, "    }\n");
	    }

	    fprintf (f, "\n");
	    fprintf (f, "    /*\n");
	    fprintf (f, "        Scene extents\n");
	    fprintf (f, "        X - Min: %8.4f  Max: %8.4f\n", gmin[X], gmax[X]);
	    fprintf (f, "        Y - Min: %8.4f  Max: %8.4f\n", gmin[Y], gmax[Y]);
	    fprintf (f, "        Z - Min: %8.4f  Max: %8.4f\n", gmin[Z], gmax[Z]);
	    fprintf (f, "    */\n");

	    fprintf (f, "}\n\n");
	    break;

	case POV20:
	    fprintf (f, "#include \"%s\"\n", inc_file);

	    fprintf (f, "\n");
	    fprintf (f, "/*\n");
	    fprintf (f, "    Scene extents\n");
	    fprintf (f, "    X - Min: %8.4f  Max: %8.4f\n", gmin[X], gmax[X]);
	    fprintf (f, "    Y - Min: %8.4f  Max: %8.4f\n", gmin[Y], gmax[Y]);
	    fprintf (f, "    Z - Min: %8.4f  Max: %8.4f\n", gmin[Z], gmax[Z]);
	    fprintf (f, "*/\n");
	    break;

	case VIVID:
	    fprintf (f, "#include %s\n\n", inc_file);
	    fprintf (f, "/*\n");
	    fprintf (f, "    Scene extents\n");
	    fprintf (f, "    X - Min: %8.4f  Max: %8.4f\n", gmin[X], gmax[X]);
	    fprintf (f, "    Y - Min: %8.4f  Max: %8.4f\n", gmin[Y], gmax[Y]);
	    fprintf (f, "    Z - Min: %8.4f  Max: %8.4f\n", gmin[Z], gmax[Z]);
	    fprintf (f, "*/\n\n");
	    break;

	case POLYRAY:
	    fprintf (f, "include \"%s\"\n\n", inc_file);
	    fprintf (f, "//\n");
	    fprintf (f, "//  Scene extents\n");
	    fprintf (f, "//  X - Min: %8.4f  Max: %8.4f\n", gmin[X], gmax[Z]);
	    fprintf (f, "//  Y - Min: %8.4f  Max: %8.4f\n", gmin[Y], gmax[Y]);
	    fprintf (f, "//  Z - Min: %8.4f  Max: %8.4f\n", gmin[Z], gmax[Z]);
	    fprintf (f, "//\n\n");
	    break;
    }

    fclose (f);
}



void opt_get_limits (float  *min_x, float  *min_y, float  *min_z,
		     float  *max_x, float  *max_y, float  *max_z)
{
    *min_x = last_vmin[X];
    *min_y = last_vmin[Y];
    *min_z = last_vmin[Z];

    *max_x = last_vmax[X];
    *max_y = last_vmax[Y];
    *max_z = last_vmax[Z];
}


void opt_get_glimits (float  *min_x, float  *min_y, float  *min_z,
		      float  *max_x, float  *max_y, float  *max_z)
{
    *min_x = gmin[X];
    *min_y = gmin[Y];
    *min_z = gmin[Z];

    *max_x = gmax[X];
    *max_y = gmax[Y];
    *max_z = gmax[Z];
}


unsigned opt_get_vert_cnt()
{
    return last_vert_cnt;
}


unsigned opt_get_tri_cnt()
{
    return last_tri_cnt;
}


float  opt_get_index()
{
    return last_index;
}


unsigned opt_get_bounds()
{
    return last_bounds;
}


void init_object()
{
    int i;

    last_pal.red   = 0.0;
    last_pal.green = 0.0;
    last_pal.blue  = 0.0;

    strcpy (last_texture, "");

    bound_cost = 1.6;

    /* Allocate memory for palette lookup table */
    pmax   = 10;
    psize  = 0;
    ptable = malloc (pmax * sizeof(Palette));
    if (ptable == NULL)
	abortmsg ("Insufficient memory for palette.", 1);

    /* Allocate memory for texture table */
    tmax   = 10;
    tsize  = 0;
    ttable = malloc (tmax * sizeof(Texture));
    if (ttable == NULL)
	abortmsg ("Insufficient memory for textures.", 1);

    /* Allocate memory for vertex lookup table */
    vmax = (vert_init > 0) ? vert_init : 1000;
    vsize  = 0;
    vtable = malloc (vmax * sizeof(Vector));
    if (vtable == NULL)
	abortmsg ("Insufficient memory for vertices.", 1);

    /* Allocate memory for vertex hash table */
    vert_hash = malloc (sizeof(VertList*)*HASHSIZE);
    if (vert_hash == NULL)
	abortmsg ("Insufficient memory for vertex hash table.", 1);

    /* Initialize the vertex lookup hash table */
    for (i = 0; i < HASHSIZE; i++)
	vert_hash[i] = NULL;

    /* Start with an empty root node */
    groot = create_group();

    tot_bounds = 1;
    initialized = 1;
}


void cleanup_object()
{
    int i;
    Vector corners[8];  /* Corners of box */

    last_vert_cnt = vsize;
    last_tri_cnt  = groot->obj_cnt;
    last_index    = orig_tpr/final_tpr;
    last_bounds   = tot_bounds;

    vect_copy (last_vmin, groot->vmin);
    vect_copy (last_vmax, groot->vmax);

    /* Calculate the corners of the bounding box */
    corners[0][X] =  groot->vmin[X];
    corners[0][Y] =  groot->vmin[Y];
    corners[0][Z] =  groot->vmin[Z];

    corners[1][X] =  groot->vmin[X];
    corners[1][Y] =  groot->vmin[Y];
    corners[1][Z] =  groot->vmax[Z];

    corners[2][X] =  groot->vmax[X];
    corners[2][Y] =  groot->vmin[Y];
    corners[2][Z] =  groot->vmin[Z];

    corners[3][X] =  groot->vmax[X];
    corners[3][Y] =  groot->vmin[Y];
    corners[3][Z] =  groot->vmax[Z];

    corners[4][X] =  groot->vmin[X];
    corners[4][Y] =  groot->vmax[Y];
    corners[4][Z] =  groot->vmin[Z];

    corners[5][X] =  groot->vmax[X];
    corners[5][Y] =  groot->vmax[Y];
    corners[5][Z] =  groot->vmin[Z];

    corners[6][X] =  groot->vmin[X];
    corners[6][Y] =  groot->vmax[Y];
    corners[6][Z] =  groot->vmax[Z];

    corners[7][X] =  groot->vmax[X];
    corners[7][Y] =  groot->vmax[Y];
    corners[7][Z] =  groot->vmax[Z];

    /* Include any transformation in the box calcs */
    if (use_transform) {
	for (i = 0; i < 8; i++)
	    vect_transform (corners[i], corners[i], trans_matrix);
    }

    for (i = 0; i < 8; i++) {
	gmin[X] = (corners[i][X] < gmin[X]) ? corners[i][X] : gmin[X];
	gmin[Y] = (corners[i][Y] < gmin[Y]) ? corners[i][Y] : gmin[Y];
	gmin[Z] = (corners[i][Z] < gmin[Z]) ? corners[i][Z] : gmin[Z];

	gmax[X] = (corners[i][X] > gmax[X]) ? corners[i][X] : gmax[X];
	gmax[Y] = (corners[i][Y] > gmax[Y]) ? corners[i][Y] : gmax[Y];
	gmax[Z] = (corners[i][Z] > gmax[Z]) ? corners[i][Z] : gmax[Z];
    }

    free (ptable);
    free (vtable);

    for (i = 0; i < tsize; i++)
	free (ttable[i]);

    free (ttable);

    delete_tree (groot);

    initialized = 0;
}


/* Calculate the number of Tests Per Ray (tpr) required for this group */
float  calc_tpr (GroupTree *gnode)
{
    GroupTree *g;
    float     tpr;

    if (gnode->child_cnt == 0)
	return gnode->obj_cnt;

    tpr = bound_cost * gnode->child_cnt;

    for (g = gnode->child; g != NULL; g = g->next)
	tpr = tpr + (g->area/gnode->area) * calc_tpr(g);

    return tpr;
}


/* Create an empty group node */
GroupTree *create_group()
{
    GroupTree *new_group;
    int       i;

    new_group = malloc (sizeof(GroupTree));
    if (new_group == NULL)
	abortmsg ("Insufficient memory for group list.", 1);

    for (i = 0; i < 3; i++) {
	new_group->index[i] = malloc (sizeof(TriList2));
	if (new_group->index[i] == NULL)
	    abortmsg ("Insufficient memory for tree.", 1);

	new_group->index[i]->tri = NULL;
	new_group->index[i]->prev = new_group->index[i];
	new_group->index[i]->next = new_group->index[i];
    }

    vect_init (new_group->vmin, +MAXFLOAT, +MAXFLOAT, +MAXFLOAT);
    vect_init (new_group->vmax, -MAXFLOAT, -MAXFLOAT, -MAXFLOAT);
    new_group->area      = 0.0;
    new_group->obj_cnt   = 0;
    new_group->child_cnt = 0;
    new_group->split_cnt = 0;
    new_group->parent    = NULL;
    new_group->next      = NULL;
    new_group->child     = NULL;

    return new_group;
}


/* Delete this node and all sub-nodes of tree */
void delete_tree (GroupTree *gnode)
{
    GroupTree *g, *g_temp;
    TriList2  *t, *t_temp;
    int       i;

    for (g = gnode->child; g != NULL; ) {
	g_temp = g->next;
	delete_tree (g);
	g = g_temp;
    }

    /* Free the indexes for this node (if any exist) */
    for (i = 0; i < 3; i++) {
	if ((gnode->index[i] != NULL) && (gnode->index[i]->prev != NULL)) {
	    /* Drop a link so the list isn't circular any more */
	    gnode->index[i]->prev->next = NULL;

	    /* Delete the list */
	    for (t = gnode->index[i]; t != NULL; ) {
		if (i == 0 && (t->tri != NULL))
		    free (t->tri);

		t_temp = t;
		t = t->next;
		free (t_temp);
	    }
	}
    }

    /* And finally free the root node */
    free (gnode);
}


/* Optimize the bounds for this sub-tree */
void optimize_tree (GroupTree *gnode)
{
    GroupTree *group_a, *group_b;
    int axis, best_axis;
    float     best_rtpr, new_rtpr;
    TriList2  *best_loc, *new_loc;

    best_rtpr = 0.0;
    best_loc  = NULL;
    best_axis = -1;

    /* Try splitting the group in each of the three axis' (x,y,z) */
    for (axis = 0; axis < 3; axis++) {
	test_split (gnode, axis, &new_rtpr, &new_loc);

	if (new_rtpr < best_rtpr) {
	    best_rtpr = new_rtpr;
	    best_loc  = new_loc;
	    best_axis = axis;
	}
    }

    if (best_axis != -1) {
	/* Split this node into two nodes */
	split_group (gnode, best_axis, best_loc, &group_a, &group_b);

	optimize_tree (group_a);
	optimize_tree (group_b);
    }
}



/* Test the effectiveness of splitting this group (but don't do it yet) */
void test_split (GroupTree *gnode, int axis, float  *best_rtpr,
		 TriList2 **best_loc)
{
    float    dim1, dim2;
    float    area1, area2, p_area;
    float    new_min1, new_max1, new_min2, new_max2;
    float    best_index, new_index;
    TriList2 *t;
    int      cnt, best_cnt;

    *best_loc  = NULL;
    best_index = +MAXFLOAT ;
    best_cnt   = 0;
    cnt = 0;

    dim1 = gnode->vmax[(axis+1) % 3] - gnode->vmin[(axis+1) % 3];
    dim2 = gnode->vmax[(axis+2) % 3] - gnode->vmin[(axis+2) % 3];

    for (t = gnode->index[axis]->next; t != gnode->index[axis]; t = t->next) {
	if (t->next == gnode->index[axis])
	    break;

	++cnt;

	/* Make an estimate of the new min/max limits, doing the full */
	/* calculation is just tooooo slooowww. */
	new_min1 = gnode->vmin[axis];
	new_max1 = max_vertex (t->tri, axis);
	new_min2 = min_vertex (t->next->tri, axis);
	new_max2 = gnode->vmax[axis];

	/* Calculate the surface area of the new groups */
	area1 = surf_area (dim1, dim2, new_max1 - new_min1);
	area2 = surf_area (dim1, dim2, new_max2 - new_min2);

	new_index = (cnt * area1) + ((gnode->obj_cnt - cnt) * area2);

	/* Keep track of the best one */
	if (new_index < best_index) {
	    best_index = new_index;
	    *best_loc  = t->next;
	    best_cnt   = cnt;
	}
    }

    /* The former was just an estimate, verify the numbers */
    if (*best_loc != NULL) {
	new_min1 = gnode->vmin[axis];
	new_max1 = -MAXFLOAT;
	new_min2 = +MAXFLOAT;
	new_max2 = gnode->vmax[axis];

	for (t = gnode->index[axis]->next; t != *best_loc; t = t->next)
	    new_max1 = fmax (new_max1, max_vertex (t->tri, axis));

	for (t = *best_loc; t != gnode->index[axis]; t = t->next)
	    new_min2 = fmin (new_min2, min_vertex (t->tri, axis));

	area1 = surf_area (dim1, dim2, new_max1 - new_min1);
	area2 = surf_area (dim1, dim2, new_max2 - new_min2);

	best_index = (best_cnt * area1) +
		     ((gnode->obj_cnt - best_cnt) * area2);
    }

    if (gnode->parent == NULL || gnode->split_cnt >= 2) {
	p_area = gnode->area;

	*best_rtpr = -1.0*((gnode->area/p_area) * gnode->obj_cnt) +
		     (gnode->area/p_area) * ((best_index/p_area) +
		     2.0*bound_cost);
    }
    else {
	p_area = gnode->parent->area;

	*best_rtpr = -1.0*((gnode->area/p_area) * gnode->obj_cnt) +
		     (best_index/p_area) + bound_cost;
    }
}


/* Split the group along the specified axis into two sub-groups */
void split_group (GroupTree *gnode, int axis, TriList2 *split_loc,
		  GroupTree **group_a, GroupTree **group_b)
{
    GroupTree *new_a, *new_b;
    TriList2  *t, *next_t, *new_index;
    char      new_flag;
    int       i;

    COOPERATE	/* support multitasking */

    /* Mark the triangles as to which group they will belong */
    new_flag = 0;
    for (t = gnode->index[axis]->next; t != gnode->index[axis]; t = t->next) {
	if (t == split_loc)
	    new_flag = 1;

	t->tri->flag = new_flag;
    }

    new_a = create_group();
    new_b = create_group();

    for (i = 0; i < 3; i++) {
	t = gnode->index[i]->next;

	while (t != gnode->index[i]) {
	    next_t = t->next;

	    if (t->tri->flag == 0)
		new_index = new_a->index[i];
	    else
		new_index = new_b->index[i];

	    /* Remove this node from the list */
	    t->prev->next = t->next;
	    t->next->prev = t->prev;

	    /* Insert node into its new group */
	    t->prev = new_index->prev;
	    t->next = new_index;
	    new_index->prev->next = t;
	    new_index->prev = t;

	    t = next_t;
	}
    }

    for (i = 0; i < 3; i++) {
	free (gnode->index[i]);
	gnode->index[i] = NULL;
    }

    if (gnode->parent == NULL || gnode->split_cnt >= 2) {
	/* Add the new groups as children of original */
	gnode->child  = new_a;
	new_a->parent = gnode;
	new_a->next   = new_b;
	new_b->parent = gnode;

	new_a->split_cnt = 0;
	new_b->split_cnt = 0;

	tot_bounds = tot_bounds + 2;
    }
    else {
	/* Remove the original group and replace with the new groups */
	for (i = 0; i < 3; i++)
	    gnode->index[i] = new_a->index[i];

	free (new_a);
	new_a = gnode;

	new_b->next = new_a->next;
	new_a->next = new_b;

	new_a->parent = gnode->parent;
	new_b->parent = gnode->parent;

	new_a->split_cnt = gnode->split_cnt + 1;
	new_b->split_cnt = gnode->split_cnt + 1;

	tot_bounds = tot_bounds + 1;
    }

    update_node (new_a);
    update_node (new_b);

    if (new_a->parent != NULL)
	update_node (new_a->parent);

    if (!quiet_mode) {
	printf ("Adding bounds (%d)\r", tot_bounds);
	fflush(stdout);
    }

    *group_a = new_a;
    *group_b = new_b;
}


/* Write the optimized POV file */
void write_file()
{
    FILE  *f;

    if (!quiet_mode)
	printf ("\nWriting files %s and %s\n", out_file, inc_file);

    f = fopen (out_file, "a");
    if (f == NULL)
	abortmsg ("Error opening output file.", 1);

    switch (out_format) {
	case POV10:   write_pov10_header (f);
		      break;
	case POV20:   write_pov20_header (f);
		      break;
	case VIVID:   write_vivid_header (f);
		      break;
	case POLYRAY: write_polyray_header (f);
		      break;
    }

    fclose (f);

    f = fopen (inc_file, "a");
    if (f == NULL)
	abortmsg ("Error opening output file.", 1);

    switch (out_format) {
	case POV10:   write_pov10_tree (f, groot, 1);
		      break;
	case POV20:   write_pov20_tree (f, groot);
		      break;
	case VIVID:   write_vivid_tree (f, groot);
		      break;
	case POLYRAY: write_polyray_tree (f, groot);
		      break;
    }

    fclose (f);

    if (!quiet_mode) {
	printf ("Triangles: %u, ", groot->obj_cnt);
	printf ("Vertices: %u, ", vsize);
	printf ("Bounding index: %.2f\n\n", orig_tpr/final_tpr);
    }
}


/* Write a sub-tree to file */
void write_pov10_tree (FILE *f, GroupTree *gnode, int level)
{
    GroupTree *g;
    TriList2  *t;
    Triangle  *first_tri;
    int       one_texture;

    if (level == 1)
	fprintf (f, "\n/* Object '%s' */\n", object_name);

    fprintf (f, "composite {\n");

    if (gnode->child != NULL) {
	for (g = gnode->child; g != NULL; g = g->next)
	    write_pov10_tree (f, g, level+1);
    }
    else {
	first_tri = gnode->index[0]->next->tri;
	one_texture = 1;

	for (t = gnode->index[0]->next; t != gnode->index[0]; t = t->next) {
	    if (t->tri->text_index != first_tri->text_index ||
		t->tri->text_type  != first_tri->text_type) {
		   one_texture = 0;
		   break;
	    }
	}

	if (one_texture) {
	    fprintf (f, "\tobject {\n");
	    fprintf (f, "\t\tunion {\n");
	}

	for (t = gnode->index[0]->next; t != gnode->index[0]; t = t->next)
	    write_pov10_triangle (f, t->tri, one_texture);

	if (one_texture) {
	    fprintf (f, "\t\t}\n\n\t\t");
	    write_pov10_texture (f, first_tri);
	    fprintf (f, "\n\t}\n");
	}
    }

    write_pov10_bound (f, gnode);

    if (level == 1 && use_transform)
	write_pov10_transform (f, trans_matrix);

    fprintf (f, "}\n");
}


void write_pov10_texture (FILE *f, Triangle *tri)
{
    if (tri->text_type == 1)
	fprintf (f, "texture { %s }", ttable[tri->text_index]);
    else if (psize < MAX_TEX)
	fprintf (f, "texture { %s_%u }",
		 object_name, tri->text_index + 1);
    else
	fprintf (f, "texture { %s color red %.3f green %.3f blue %.3f }",
		 object_name, ptable[tri->text_index].red,
		 ptable[tri->text_index].green, ptable[tri->text_index].blue);
}


/*
   Writes a transformation matrix as separate POV-Ray scale< >,
   rotate< >, and translate< > commands
*/
void write_pov10_transform (FILE *f, Matrix matrix)
{
    Vector scale, shear, rotate, transl;

    /* Decode the matrix into separate operations */
    mx_decode (matrix, scale, shear, rotate, transl);

    fprintf (f, "\n\t/* Object transformation */\n");

    if (fabs(scale[X] - 1.0) > 0.001 || fabs(scale[Y] - 1.0) > 0.001 || fabs(scale[Z] - 1.0) > 0.001)
	fprintf (f, "\tscale <%.3f %.3f %.3f>\n", scale[X], scale[Y], scale[Z]);

    if (fabs(rotate[X]) > 0.01 || fabs(rotate[Y]) > 0.01 || fabs(rotate[Z]) > 0.01)
	fprintf (f, "\trotate <%.2f %.2f %.2f>\n", rotate[X], rotate[Y], rotate[Z]);

    if (fabs(transl[X]) > 0.0001 || fabs(transl[Y]) > 0.0001 || fabs(transl[Z]) > 0.0001)
	fprintf (f, "\ttranslate <%.4f %.4f %.4f>\n", transl[X], transl[Y], transl[Z]);

    /* Can't handle shear but warn if it's there */
    if (fabs(shear[X]) > 0.01 || fabs(shear[Y]) > 0.01 || fabs(shear[Z]) > 0.01)
	printf ("Warning: Significant shear in transformation (ignored)\n");
}


/* Write the POV file header */
void write_pov10_header (FILE *f)
{
    int i;

    if (psize >= MAX_TEX) {
	fprintf (f, "/* Too many textures, textures generated in-line */\n\n");
	fprintf (f, "#declare %s = texture {\n", object_name);
	fprintf (f, "    ambient 0.1\n");
	fprintf (f, "    diffuse 0.7\n");
	fprintf (f, "    phong 1.0\n");
	fprintf (f, "    phong_size 70.0\n");
	fprintf (f, "}\n\n");
    }
    else {
	if (psize > 0)
	    fprintf (f, "/* Texture declarations for object '%s' */\n", object_name);

	for (i = 0; i < psize; i++) {
	    fprintf (f, "#declare %s_%u = texture {\n", object_name, i + 1);
	    fprintf (f, "    ambient 0.1\n");
	    fprintf (f, "    diffuse 0.7\n");
	    fprintf (f, "    phong 1.0\n");
	    fprintf (f, "    phong_size 70.0\n");
	    fprintf (f, "    color red %.3f green %.3f blue %.3f\n",
		     ptable[i].red, ptable[i].green, ptable[i].blue);
	    fprintf (f, "}\n\n");
	}
    }
}


/* Write a triangle (smooth or regular) */
void write_pov10_triangle (FILE *f, Triangle *tri, int one_texture)
{
    Vector norm[3];
    int    no_smooth = 0;

    COOPERATE	/* support multitasking */

    if (one_texture)
	fprintf (f, "\t\t");
    else
	fprintf (f, "\tobject { ");

    if (smooth_angle > 0.0) {
	vert_normal (tri, norm);

	if (vect_equal (norm[0], norm[1]) && vect_equal (norm[1], norm[2]))
	    no_smooth = 1;
    }

    if (smooth_angle > 0.0 && !no_smooth) {
	fprintf (f, "smooth_triangle { <");
	vect_print (f, vtable[tri->vert[0]], dec_point, ' ');
	fprintf (f, "> <");
	vect_print (f, norm[0], 3, ' ');
	fprintf (f, "> <");
	vect_print (f, vtable[tri->vert[1]], dec_point, ' ');
	fprintf (f, "> <");
	vect_print (f, norm[1], 3, ' ');
	fprintf (f, "> <");
	vect_print (f, vtable[tri->vert[2]], dec_point, ' ');
	fprintf (f, "> <");
	vect_print (f, norm[2], 3, ' ');
	fprintf (f, "> }");
    }
    else {
	fprintf (f, "triangle { <");
	vect_print (f, vtable[tri->vert[0]], dec_point, ' ');
	fprintf (f, "> <");
	vect_print (f, vtable[tri->vert[1]], dec_point, ' ');
	fprintf (f, "> <");
	vect_print (f, vtable[tri->vert[2]], dec_point, ' ');
	fprintf (f, "> }");
    }

    if (!one_texture) {
	fprintf (f, " ");
	write_pov10_texture (f, tri);
	fprintf (f, " }");
    }

    fprintf (f, "\n");
}


/* Write a bounding shape */
void write_pov10_bound (FILE *f, GroupTree *gnode)
{
    if (gnode->obj_cnt > 1) {
	fprintf (f, "\n\tbounded_by { box { <");
	vect_print (f, gnode->vmin, dec_point + 1, ' ');
	fprintf (f, "> <");
	vect_print (f, gnode->vmax, dec_point + 1, ' ');
	fprintf (f, "> } }\n");
    }
}


/* Write a sub-tree to file */
void write_pov20_tree (FILE *f, GroupTree *gnode)
{
    TriList2  *t;

    fprintf (f, "\n/* Object '%s' */\n", object_name);

    if (gnode->child != NULL)
	abortmsg ("Internal error", 1);

    fprintf (f, "union {\n");

    for (t = gnode->index[0]->next; t != gnode->index[0]; t = t->next)
	write_pov20_triangle (f, t->tri);

    if (use_transform)
	write_pov20_transform (f, trans_matrix);

    fprintf (f, "}\n");
}


/*
   Writes a transformation matrix as separate POV-Ray scale< >,
   rotate< >, and translate< > commands
*/
void write_pov20_transform (FILE *f, Matrix matrix)
{
    Vector scale, shear, rotate, transl;

    /* Decode the matrix into separate operations */
    mx_decode (matrix, scale, shear, rotate, transl);

    fprintf (f, "\n\t/* Object transformation */\n");

    if (fabs(scale[X] - 1.0) > 0.001 || fabs(scale[Y] - 1.0) > 0.001 || fabs(scale[Z] - 1.0) > 0.001)
	fprintf (f, "\tscale <%.3f, %.3f, %.3f>\n", scale[X], scale[Y], scale[Z]);

    if (fabs(rotate[X]) > 0.01 || fabs(rotate[Y]) > 0.01 || fabs(rotate[Z]) > 0.01)
	fprintf (f, "\trotate <%.2f, %.2f, %.2f>\n", rotate[X], rotate[Y], rotate[Z]);

    if (fabs(transl[X]) > 0.0001 || fabs(transl[Y]) > 0.0001 || fabs(transl[Z]) > 0.0001)
	fprintf (f, "\ttranslate <%.4f, %.4f, %.4f>\n", transl[X], transl[Y], transl[Z]);

    /* Can't handle shear but warn if it's there */
    if (fabs(shear[X]) > 0.01 || fabs(shear[Y]) > 0.01 || fabs(shear[Z]) > 0.01)
	printf ("Warning: Significant shear in transformation (ignored)\n");
}


void write_pov20_texture (FILE *f, Triangle *tri)
{
    if (tri->text_type == 1)
	fprintf (f, "texture { %s }", ttable[tri->text_index]);
    else if (psize < MAX_TEX)
	fprintf (f, "texture { %s_%u }",
		 object_name, tri->text_index + 1);
    else
	fprintf (f, "texture { %s pigment { color red %.3f green %.3f blue %.3f } }",
		 object_name, ptable[tri->text_index].red,
		 ptable[tri->text_index].green, ptable[tri->text_index].blue);
}


/* Write the POV file header */
void write_pov20_header (FILE *f)
{
    int i;

    if (psize >= MAX_TEX) {
	fprintf (f, "/* Too many textures, textures generated in-line */\n\n");
	fprintf (f, "#declare %s = texture {\n", object_name);
	fprintf (f, "    finish {\n");
	fprintf (f, "        ambient 0.1\n");
	fprintf (f, "        diffuse 0.7\n");
	fprintf (f, "        phong 1.0\n");
	fprintf (f, "        phong_size 70.0\n");
	fprintf (f, "    }\n");
	fprintf (f, "}\n\n");
    }
    else {
	if (psize > 0)
	    fprintf (f, "/* Texture declarations for object '%s' */\n", object_name);

	for (i = 0; i < psize; i++) {
	    fprintf (f, "#declare %s_%u = texture {\n", object_name, i + 1);
	    fprintf (f, "    finish {\n");
	    fprintf (f, "        ambient 0.1\n");
	    fprintf (f, "        diffuse 0.7\n");
	    fprintf (f, "        phong 1.0\n");
	    fprintf (f, "        phong_size 70.0\n");
	    fprintf (f, "    }\n");
	    fprintf (f, "    pigment { color red %.3f green %.3f blue %.3f }\n",
		     ptable[i].red, ptable[i].green, ptable[i].blue);
	    fprintf (f, "}\n\n");
	}
    }
}


/* Write a triangle (smooth or regular) */
void write_pov20_triangle (FILE *f, Triangle *tri)
{
    Vector norm[3];
    int    no_smooth = 0;

    COOPERATE	/* support multitasking */

    if (smooth_angle > 0.0) {
	vert_normal (tri, norm);

	if (vect_equal (norm[0], norm[1]) && vect_equal (norm[1], norm[2]))
	    no_smooth = 1;
    }

    if (smooth_angle > 0.0 && !no_smooth) {
	fprintf (f, "\tsmooth_triangle {\n");
	fprintf (f, "\t\t<");
	vect_print (f, vtable[tri->vert[0]], dec_point, ',');
	fprintf (f, ">, <");
	vect_print (f, norm[0], 3, ',');
	fprintf (f, ">,\n\t\t<");
	vect_print (f, vtable[tri->vert[1]], dec_point, ',');
	fprintf (f, ">, <");
	vect_print (f, norm[1], 3, ',');
	fprintf (f, ">,\n\t\t<");
	vect_print (f, vtable[tri->vert[2]], dec_point, ',');
	fprintf (f, ">, <");
	vect_print (f, norm[2], 3, ',');
	fprintf (f, ">\n\t\t");

	write_pov20_texture (f, tri);

	fprintf (f, "\n\t}\n");
    }
    else {
	fprintf (f, "\ttriangle {\n");
	fprintf (f, "\t\t<");
	vect_print (f, vtable[tri->vert[0]], dec_point, ',');
	fprintf (f, ">,\n\t\t<");
	vect_print (f, vtable[tri->vert[1]], dec_point, ',');
	fprintf (f, ">,\n\t\t<");
	vect_print (f, vtable[tri->vert[2]], dec_point, ',');
	fprintf (f, ">\n\t\t");

	write_pov20_texture (f, tri);

	fprintf (f, "\n\t}\n");
    }

    fprintf (f, "\n");
}


/* Write a sub-tree to file */
void write_vivid_tree (FILE *f, GroupTree *gnode)
{
    TriList2  *t;
    int       last_index, last_type;

    last_index = -1;
    last_type  = -1;

    fprintf (f, "\n/* Object '%s' */\n", object_name);

    if (use_transform)
	write_vivid_transform (f, trans_matrix);

    if (gnode->child != NULL)
	abortmsg ("Internal error", 1);

    for (t = gnode->index[0]->next; t != gnode->index[0]; t = t->next) {
	if (t->tri->text_index != last_index ||
	    t->tri->text_type != last_type)
	{
	    write_vivid_texture (f, t->tri);
	    last_index = t->tri->text_index;
	    last_type  = t->tri->text_type;
	}

	write_vivid_triangle (f, t->tri);
    }

    if (use_transform)
	fprintf (f, "transform_pop\n\n");
}


/*
   Writes a transformation matrix as separate Vivid scale,
   rotate, and translate commands
*/
void write_vivid_transform (FILE *f, Matrix matrix)
{
    Vector scale, shear, rotate, transl;

    /* Decode the matrix into separate operations */
    mx_decode (matrix, scale, shear, rotate, transl);

    fprintf (f, "\n/* Object transformation */\n");

    fprintf (f, "transform {\n");

    if (fabs(scale[X] - 1.0) > 0.001 || fabs(scale[Y] - 1.0) > 0.001 || fabs(scale[Z] - 1.0) > 0.001)
	fprintf (f, "\tscale %.3f %.3f %.3f\n", scale[X], scale[Y], scale[Z]);

    if (fabs(rotate[X]) > 0.01 || fabs(rotate[Y]) > 0.01 || fabs(rotate[Z]) > 0.01)
	fprintf (f, "\trotate %.2f %.2f %.2f\n", rotate[X], rotate[Y], rotate[Z]);

    if (fabs(transl[X]) > 0.0001 || fabs(transl[Y]) > 0.0001 || fabs(transl[Z]) > 0.0001)
	fprintf (f, "\ttranslate %.4f %.4f %.4f\n", transl[X], transl[Y], transl[Z]);

    /* Can't handle shear but warn if it's there */
    if (fabs(shear[X]) > 0.01 || fabs(shear[Y]) > 0.01 || fabs(shear[Z]) > 0.01)
	printf ("Warning: Significant shear in transformation (ignored)\n");

    fprintf (f, "}\n\n");
}


void write_vivid_texture (FILE *f, Triangle *tri)
{
    if (tri->text_type == 1)
	fprintf (f, "\n%s /* New texture */\n\n", ttable[tri->text_index]);
    else
	fprintf (f, "\n%s_%u /* New texture */\n\n",
		 object_name, tri->text_index + 1);
}


/* Write the Vivid file header */
void write_vivid_header (FILE *f)
{
    int i;

    if (psize > 0)
	fprintf (f, "/* Texture declarations for object '%s' */\n", object_name);

    for (i = 0; i < psize; i++) {
	fprintf (f, "#define %s_%u \\ \n", object_name, i + 1);
	fprintf (f, "    surface {           \\ \n");
	fprintf (f, "        diffuse %.3f %.3f %.3f \\ \n",
		    ptable[i].red, ptable[i].green, ptable[i].blue);
	fprintf (f, "        shine 70 white  \\ \n");
	fprintf (f, "    }\n\n");
    }
}


/* Write a Vivid triangle patch */
void write_vivid_triangle (FILE *f, Triangle *tri)
{
    Vector norm[3];

    COOPERATE	/* support multitasking */

    vert_normal (tri, norm);

    fprintf (f, "patch {\n");
    fprintf (f, "\tvertex ");
    vect_print (f, vtable[tri->vert[0]], dec_point, ' ');
    fprintf (f, " normal ");
    vect_print (f, norm[0], 3, ' ');
    fprintf (f, "\n");

    fprintf (f, "\tvertex ");
    vect_print (f, vtable[tri->vert[1]], dec_point, ' ');
    fprintf (f, " normal ");
    vect_print (f, norm[1], 3, ' ');
    fprintf (f, "\n");

    fprintf (f, "\tvertex ");
    vect_print (f, vtable[tri->vert[2]], dec_point, ' ');
    fprintf (f, " normal ");
    vect_print (f, norm[2], 3, ' ');
    fprintf (f, "\n");

    fprintf (f, "}\n\n");
}


/* Write a sub-tree to file */
void write_polyray_tree (FILE *f, GroupTree *gnode)
{
    TriList2  *t;

    fprintf (f, "\n// Object '%s'\n\n", object_name);

    fprintf (f, "object {\n");

    if (gnode->child != NULL)
	abortmsg ("Internal error", 1);

    for (t = gnode->index[0]->next; t != gnode->index[0]; t = t->next) {
	if (t != gnode->index[0]->next)
	    fprintf (f, "\t+\n");

	write_polyray_triangle (f, t->tri);

	write_polyray_texture (f, t->tri);
    }

    if (use_transform)
	write_polyray_transform (f, trans_matrix);

    fprintf (f, "}\n\n");
}


/*
   Writes a transformation matrix as separate Polyray scale< >,
   rotate< >, and translate< > commands
*/
void write_polyray_transform (FILE *f, Matrix matrix)
{
    Vector scale, shear, rotate, transl;

    /* Decode the matrix into separate operations */
    mx_decode (matrix, scale, shear, rotate, transl);

    fprintf (f, "\n\t// Object transformation\n");

    if (fabs(scale[X] - 1.0) > 0.001 || fabs(scale[Y] - 1.0) > 0.001 || fabs(scale[Z] - 1.0) > 0.001)
	fprintf (f, "\tscale <%.3f, %.3f, %.3f>\n", scale[X], scale[Y], scale[Z]);

    if (fabs(rotate[X]) > 0.01 || fabs(rotate[Y]) > 0.01 || fabs(rotate[Z]) > 0.01)
	fprintf (f, "\trotate <%.2f, %.2f, %.2f>\n", rotate[X], rotate[Y], rotate[Z]);

    if (fabs(transl[X]) > 0.0001 || fabs(transl[Y]) > 0.0001 || fabs(transl[Z]) > 0.0001)
	fprintf (f, "\ttranslate <%.4f, %.4f, %.4f>\n", transl[X], transl[Y], transl[Z]);

    /* Can't handle shear but warn if it's there */
    if (fabs(shear[X]) > 0.01 || fabs(shear[Y]) > 0.01 || fabs(shear[Z]) > 0.01)
	printf ("Warning: Significant shear in transformation (ignored)\n");
}


void write_polyray_texture (FILE *f, Triangle *tri)
{
    if (tri->text_type == 1)
	fprintf (f, "\t\t%s\n\t}\n\n", ttable[tri->text_index]);
    else
	fprintf (f, "\t\t%s_%u\n\t}\n\n",
		 object_name, tri->text_index + 1);
}


/* Write the Polyray file header */
void write_polyray_header (FILE *f)
{
    int i;

    if (psize > 0)
	fprintf (f, "// Texture declarations for object '%s'\n", object_name);

    for (i = 0; i < psize; i++) {
	fprintf (f, "define %s_%u\n", object_name, i + 1);
	fprintf (f, "texture {\n");
	fprintf (f, "    surface {\n");
	fprintf (f, "        ambient <%.3f, %.3f, %.3f>, 0.1\n",
		    ptable[i].red, ptable[i].green, ptable[i].blue);
	fprintf (f, "        diffuse <%.3f, %.3f, %.3f>, 0.7\n",
		    ptable[i].red, ptable[i].green, ptable[i].blue);
	fprintf (f, "        specular white, 1.0\n");
	fprintf (f, "        microfacet Reitz 10\n");
	fprintf (f, "    }\n");
	fprintf (f, "}\n\n");
    }
}


/* Write a Polyray triangle patch */
void write_polyray_triangle (FILE *f, Triangle *tri)
{
    Vector norm[3];

    COOPERATE	/* support multitasking */

    vert_normal (tri, norm);

    fprintf (f, "\tobject {\n");

    fprintf (f, "\t\tpatch\t <");
    vect_print (f, vtable[tri->vert[0]], dec_point, ',');
    fprintf (f, ">, <");
    vect_print (f, norm[0], 3, ',');
    fprintf (f, ">,\n");

    fprintf (f, "\t\t\t <");
    vect_print (f, vtable[tri->vert[1]], dec_point, ',');
    fprintf (f, ">, <");
    vect_print (f, norm[1], 3, ',');
    fprintf (f, ">,\n");

    fprintf (f, "\t\t\t <");
    vect_print (f, vtable[tri->vert[2]], dec_point, ',');
    fprintf (f, ">, <");
    vect_print (f, norm[2], 3, ',');
    fprintf (f, ">\n");
}


/* Update the stats (area, vmin/vmax, child_cnt, etc.) for this node */
void update_node (GroupTree *gnode)
{
    GroupTree *g;
    TriList2  *t;
    int       i;

    vect_init (gnode->vmin, +MAXFLOAT, +MAXFLOAT, +MAXFLOAT);
    vect_init (gnode->vmax, -MAXFLOAT, -MAXFLOAT, -MAXFLOAT);

    gnode->obj_cnt   = 0;
    gnode->child_cnt = 0;

    if (gnode->index[0] == NULL) {
	/* Not a leaf node, calc the info from the child nodes */

	for (g = gnode->child; g != NULL; g = g->next) {
	    ++(gnode->child_cnt);

	    gnode->obj_cnt += g->obj_cnt;

	    for (i = 0; i < 3; i++) {
		gnode->vmin[i] = fmin (gnode->vmin[i], g->vmin[i]);
		gnode->vmax[i] = fmax (gnode->vmax[i], g->vmax[i]);
	    }
	}
    }
    else {
	/* A leaf node, calc the info from the triangle list */

	for (t = gnode->index[0]->next; t != gnode->index[0]; t = t->next) {
	    ++(gnode->obj_cnt);

	    for (i = 0; i < 3; i++) {
		gnode->vmin[i] = fmin (gnode->vmin[i], min_vertex (t->tri, i));
		gnode->vmax[i] = fmax (gnode->vmax[i], max_vertex (t->tri, i));
	    }
	}
    }

    /* Update total surface area of region */
    gnode->area = surf_area (gnode->vmax[X] - gnode->vmin[X],
			     gnode->vmax[Y] - gnode->vmin[Y],
			     gnode->vmax[Z] - gnode->vmin[Z]);
}


void sort_indexes (GroupTree *gnode)
{
    int i;

    for (i = 0; i < 3; i++)
	quick_sort (gnode->index[i]->next, gnode->index[i]->prev, i);
}


void quick_sort (TriList2 *start, TriList2 *end, int axis)
{
    TriList2 *a, *b;
    Triangle *temp;
    float  middle;

    if (start == end)
	return;

    a = start;
    b = end;
    middle = avg_vertex (a->tri, axis);

    do {
	while (avg_vertex (b->tri, axis) >= middle && a != b)
	    b = b->prev;

	if (a != b) {
	    temp   = a->tri;
	    a->tri = b->tri;
	    b->tri = temp;

	    while (avg_vertex (a->tri, axis) <= middle && a != b)
		a = a->next;

	    if (a != b) {
		temp   = a->tri;
		a->tri = b->tri;
		b->tri = temp;
	    }
	}
    } while (a != b);

    if (a != start)
	quick_sort (start, a->prev, axis);

    if (b != end)
	quick_sort (b->next, end, axis);
}


/* Calculate the surface area of a box */
float surf_area (float  a, float  b, float  c)
{
    return 2.0*(a*b + b*c + c*a);
}


float max_vertex (Triangle *tri, int axis)
{
    float  max_v, val;
    int i;

    max_v = -MAXFLOAT;

    for (i = 0; i < 3; i++) {
	val = vtable[tri->vert[i]][axis];

	if (val > max_v)
	    max_v = val;
    }

    return max_v;
}


float min_vertex (Triangle *tri, int axis)
{
    float  min_v, val;
    int i;

    min_v = +MAXFLOAT;

    for (i = 0; i < 3; i++) {
	val = vtable[tri->vert[i]][axis];

	if (val < min_v)
	    min_v = val;
    }

    return min_v;
}


float avg_vertex (Triangle *tri, int axis)
{
    float  avg;

    avg = (vtable[tri->vert[0]][axis] + vtable[tri->vert[1]][axis] +
	   vtable[tri->vert[2]][axis])/3.0;

    return avg;
}


/* Build an index of which triangles touch each vertex.  Used to */
/* speed up smooth triangle normal calculations. */
void build_tri_index()
{
    GroupTree *g;
    TriList   *temp;
    TriList2  *t;
    unsigned  i, vert_no;

    if (vsize == 0)
	return;

    tri_index = malloc (vsize * sizeof(TriList));
    if (tri_index == NULL)
	abortmsg ("Insufficient memory for smooth triangles.", 1);

    for (i = 0; i < vsize; i++)
	tri_index[i] = NULL;

    for (g = groot; g != NULL; g = g->next) {
	for (t = g->index[0]->next; t != g->index[0]; t = t->next) {
	    for (i = 0; i < 3; i++) {
		vert_no = t->tri->vert[i];
		temp = tri_index[vert_no];
		tri_index[vert_no] = malloc (sizeof(TriList));
		if (tri_index[vert_no] == NULL)
		    abortmsg ("Insufficient memory for smooth triangles.\n", 1);

		tri_index[vert_no]->tri = t->tri;
		tri_index[vert_no]->next = temp;
	    }
	}
    }

}


void dump_tri_index()
{
    TriList *temp;
    int     i;

    for (i = 0; i < vsize; i++) {
	while (tri_index[i] != NULL) {
	    temp = tri_index[i];
	    tri_index[i] = tri_index[i]->next;
	    free (temp);
	}
    }

    free (tri_index);
}


/* Calculates the smooth triangle normal for this vertex */
void vert_normal (Triangle *t, Vector *norm)
{
    Vector  curr_norm, new_norm;
    TriList *p;
    int     i;

    tri_normal (t, curr_norm);

    for (i = 0; i < 3; i++) {
	vect_init (norm[i], 0.0, 0.0, 0.0);

	for (p = tri_index[t->vert[i]]; p != NULL; p = p->next) {
	    tri_normal (p->tri, new_norm);
	    if (vect_angle (curr_norm, new_norm) < smooth_angle)
		vect_add (norm[i], norm[i], new_norm);
	}

	vect_normalize (norm[i]);
    }
}


/* Calculates the normal to the specified triangle */
void tri_normal (Triangle *t, Vector normal)
{
    Vector ab, ac;

    vect_sub (ab, vtable[t->vert[1]], vtable[t->vert[0]]);
    vect_sub (ac, vtable[t->vert[2]], vtable[t->vert[0]]);
    vect_cross (normal, ac, ab);

    vect_normalize (normal);
}


/* Find the specified rgb values in the palette table */
unsigned pal_lookup (float  red, float  green, float  blue)
{
    int i;

    /* The palette table is usually small so just do a simple linear search */
    for (i = psize-1; i >= 0; i--) {
	if (ptable[i].red   == red &&
	    ptable[i].green == green &&
	    ptable[i].blue  == blue)
	  break;
    }

    if (i >= 0)
	return i;    /* found, return the table index */

    /* not found, insert the new palette into the table */
    ++psize;
    if (psize > pmax) {
	/* table not big enough, resize it */
	pmax = pmax + 10;
	ptable = realloc (ptable, pmax * sizeof(Palette));
	if (ptable == NULL)
	    abortmsg ("Insufficient memory to expand palette table.", 1);
    }

    ptable[psize-1].red   = red;
    ptable[psize-1].green = green;
    ptable[psize-1].blue  = blue;

    return (psize-1);
}


/* Find the specified named texture in the texture table */
unsigned texture_lookup (char *texture_name)
{
    int i;

    /* The texture table is usually small so just do a simple linear search */
    for (i = tsize-1; i >= 0; i--) {
	if (strcmp (ttable[i], texture_name) == 0)
	    break;
    }

    if (i >= 0)
	return i;    /* found, return the table index */

    /* not found, insert the new texture into the table */
    ++tsize;
    if (tsize > tmax) {
	/* table not big enough, resize it */
	tmax = tmax + 10;
	ttable = realloc (ttable, tmax * sizeof(Texture));
	if (ttable == NULL)
	    abortmsg ("Insufficient memory to expand palette table.", 1);
    }

    ttable[tsize-1] = malloc (strlen(texture_name) + 1);
    if (ttable[tsize-1] == NULL)
	abortmsg ("Insufficient memory for texture name.", 1);

    strcpy (ttable[tsize-1], texture_name);

    return (tsize-1);
}


/* Find the specified vertex in the vertex table */
unsigned vert_lookup (float  x, float  y, float  z)
{
    VertList *p, *new_node;
    unsigned hash;

    /* Vertex table is usually very large, use hash lookup */
    hash = (unsigned)((int)(326.4*x) ^ (int)(694.7*y) ^ (int)(1423.6*z)) % HASHSIZE;

    for (p = vert_hash[hash]; p != NULL; p = p->next) {
	if (vtable[p->vert][0] == x && vtable[p->vert][1] == y &&
	    vtable[p->vert][2] == z) break;
    }

    if (p != NULL)
	return (p->vert);   /* found, return the table index */

    /* not found, insert the new vertex into the table */
    ++vsize;
    if (vsize > vmax) {
	/* table not big enough, expand it */
	vmax = vmax + 100;
	vtable = realloc (vtable, vmax * sizeof(Vector));
	if (vtable == NULL)
	    abortmsg ("Insufficient memory for vertices.\n", 1);
    }

    vect_init (vtable[vsize-1], x, y, z);

    new_node = malloc (sizeof(VertList));
    if (new_node == NULL)
	abortmsg ("Insufficient memory for hash table.", 1);

    new_node->vert  = vsize-1;
    new_node->next  = vert_hash[hash];
    vert_hash[hash] = new_node;

    return (vsize-1);
}


/* Checks if triangle is degenerate (zero area) */
int  degen_tri (float  ax, float  ay, float  az,
		float  bx, float  by, float  bz,
		float  cx, float  cy, float  cz)
{
    Vector  ab, ac, norm;
    double  mag, fact;

    fact = pow (10.0, dec_point);

    /* Round the coords off to the output precision before checking */
    ax = floor((ax*fact) + 0.5)/fact;
    ay = floor((ay*fact) + 0.5)/fact;
    az = floor((az*fact) + 0.5)/fact;
    bx = floor((bx*fact) + 0.5)/fact;
    by = floor((by*fact) + 0.5)/fact;
    bz = floor((bz*fact) + 0.5)/fact;
    cx = floor((cx*fact) + 0.5)/fact;
    cy = floor((cy*fact) + 0.5)/fact;
    cz = floor((cz*fact) + 0.5)/fact;

    vect_init (ab, ax-bx, ay-by, az-bz);
    vect_init (ac, ax-cx, ay-cy, az-cz);
    vect_cross (norm, ab, ac);

    mag = vect_mag(norm);

    return (mag < DEGEN_TOL);
}


void abortmsg (char *msg, int exit_code)
{
    printf ("\n%s\n", msg);
    exit (exit_code);
}


float  fmin (float  a, float  b)
{
    if (a < b)
	return a;
    else
	return b;
}


float  fmax (float  a, float  b)
{
    if (a > b)
	return a;
    else
	return b;
}


void add_ext (char *fname, char *ext, int force)
{
    int i;

    for (i = 0; i < strlen(fname); i++)
	if (fname[i] == '.') break;

    if (fname[i] == '\0' || force) {
	if (strlen(ext) > 0)
	    fname[i++] = '.';

	strcpy (&fname[i], ext);
    }
}


void cleanup_name (char *name)
{
    char *tmp = malloc (strlen(name)+1);
    int  i;

    /* Remove any leading blanks or quotes */
    i = 0;
    while ((name[i] == ' ' || name[i] == '"') && name[i] != '\0')
	i++;

    strcpy (tmp, &name[i]);

    /* Remove any trailing blanks or quotes */
    for (i = strlen(tmp)-1; i >= 0; i--) {
	if (isprint(tmp[i]) && !isspace(tmp[i]) && tmp[i] != '"')
	    break;
	else
	    tmp[i] = '\0';
    }

    strcpy (name, tmp);

    /* Prefix the letter 'N' to materials that begin with a digit */
    if (!isdigit (name[0]))
       strcpy (tmp, name);
    else {
       tmp[0] = 'N';
       strcpy (&tmp[1], name);
    }

    /* Replace all illegal charaters in name with underscores */
    for (i = 0; tmp[i] != '\0'; i++) {
       if (!isalnum(tmp[i]))
	   tmp[i] = '_';
    }

    strcpy (name, tmp);

    free (tmp);
}


