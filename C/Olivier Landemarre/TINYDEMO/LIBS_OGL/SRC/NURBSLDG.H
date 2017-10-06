/* $Id: nurbs.h,v 1.3 1997/05/27 03:18:23 brianp Exp $ */

/*
 * Mesa 3-D graphics library
 * Version:  2.3
 * Copyright (C) 1995-1997  Brian Paul
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this library; if not, write to the Free
 * Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */


/*
 * $Log: nurbs.h,v $
 * Revision 1.3  1997/05/27 03:18:23  brianp
 * minor clean-up
 *
 * Revision 1.2  1997/05/27 03:00:16  brianp
 * incorporated Bogdan's new NURBS code
 *
 * Revision 1.1  1996/09/27 01:19:39  brianp
 * Initial revision
 *
 */


/*
 * NURBS implementation written by Bogdan Sikorski (bogdan@cira.it)
 * See README2 for more info.
 */


#ifndef NURBS_H
#define NURBS_H


#define EPSILON 1e-06 /* epsilon for double precision compares */

typedef enum
{
	GLU_NURBS_CURVE, GLU_NURBS_SURFACE, GLU_NURBS_TRIM, GLU_NURBS_NO_TRIM,
	GLU_NURBS_TRIM_DONE, GLU_NURBS_NONE
} GLU_nurbs_enum;

typedef enum
{
	GLU_TRIM_NURBS, GLU_TRIM_PWL
} GLU_trim_enum;

typedef struct
{
	GLint	sknot_count;
	GLfloat	*sknot;
	GLint	tknot_count;
	GLfloat	*tknot;
	GLint	s_stride;
	GLint	t_stride;
	GLfloat	*ctrlarray;
	GLint	sorder;
	GLint	torder;
	GLint	dim;
	GLenum	type;
} surface_attribs;

typedef struct
{
	surface_attribs	geom;
	surface_attribs	color;
	surface_attribs	texture;
	surface_attribs	normal;
} nurbs_surface;

typedef struct
{
	GLint			knot_count;
	GLfloat			*knot;
	GLint			stride;
	GLfloat			*ctrlarray;
	GLint			order;
	GLint			dim;
	GLenum			type;
} curve_attribs;

typedef struct
{
	GLint			pt_count;
	GLfloat			*ctrlarray;
	GLint			stride;
	GLint			dim;
	GLenum			type;
} pwl_curve_attribs;

typedef struct
{
	curve_attribs	geom;
	curve_attribs	color;
	curve_attribs	texture;
	curve_attribs	normal;
} nurbs_curve;

typedef struct trim_list_str
{
	GLU_trim_enum			trim_type;
	union
	{
		pwl_curve_attribs	pwl_curve;
		curve_attribs		nurbs_curve;
	}						curve;
	struct trim_list_str	*next;
} trim_list;

typedef struct seg_trim_str
{
	GLfloat 			*points;
	GLint				pt_cnt,seg_array_len;
	struct seg_trim_str	*next;
} trim_segments;

typedef struct nurbs_trim_str
{
	trim_list				*trim_loop;
	trim_segments			*segments;
	struct nurbs_trim_str	*next;
} nurbs_trim;

typedef struct
{
	GLfloat model[16],proj[16],viewport[4];
} culling_and_sampling_str;

typedef struct {
	GLboolean		culling;
	GLenum			error;
	void			(CALLBACK *error_callback)( GLenum err );
	GLenum			display_mode;
	GLU_nurbs_enum	nurbs_type;
	GLboolean		auto_load_matrix;
	culling_and_sampling_str
					sampling_matrices;
	GLenum			sampling_method;
	GLfloat			sampling_tolerance;
	GLfloat			parametric_tolerance;
	GLint			u_step, v_step;
	nurbs_surface	surface;
	nurbs_curve		curve;
	nurbs_trim		*trim;
} GLUnurbsObj ;

typedef struct
{
	GLfloat		*knot;
	GLint		nknots;
	GLfloat		*unified_knot;
	GLint		unified_nknots;
	GLint		order;
	GLint		t_min,t_max;
	GLint		delta_nknots;
	GLboolean	open_at_begin,open_at_end;
	GLfloat		*new_knot;
	GLfloat		*alpha;
} knot_str_type;

typedef struct
{
	GLfloat	*geom_ctrl;
	GLint	geom_s_stride,geom_t_stride;
	GLfloat	**geom_offsets;
	GLint	geom_s_pt_cnt,geom_t_pt_cnt;
	GLfloat	*color_ctrl;
	GLint	color_s_stride,color_t_stride;
	GLfloat	**color_offsets;
	GLint	color_s_pt_cnt,color_t_pt_cnt;
	GLfloat *normal_ctrl;
	GLint	normal_s_stride,normal_t_stride;
	GLfloat	**normal_offsets;
	GLint	normal_s_pt_cnt,normal_t_pt_cnt;
	GLfloat	*texture_ctrl;
	GLint	texture_s_stride,texture_t_stride;
	GLfloat	**texture_offsets;
	GLint	texture_s_pt_cnt,texture_t_pt_cnt;
	GLint	s_bezier_cnt,t_bezier_cnt;
} new_ctrl_type;


#endif
