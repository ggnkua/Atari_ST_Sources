/*  This file is part of gempy.
 *
 *  gempy - https://github.com/ArmstrongJ/gempy
 *  Copyright (C) 2011 Jeffrey Armstrong
 *  <jeffrey.armstrong@approximatrix.com>
 *
 *  Foobar is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Lesser General Public License as 
 *  published by the Free Software Foundation, either version 3 of 
 *  the License, or (at your option) any later version.
 *
 *  Foobar is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

#include "ldg_Python.h"
#include <gem.h>

PyObject* __CDECL py_v_open_screen(PyObject *self, PyObject *args)
{
int i;
short work_in[16];
short work_out[57];

short vdi_handle;
    
    for(i=1;i<16;i++)
        work_in[i] = (short)0;  /* General Defaults */
        
    work_in[0] = (short)1; /* Current Resolution */
    work_in[10] = (short)2; /* Necessary for screen drawing */
    
    v_opnvwk(work_in, &vdi_handle, work_out);
    
    /* For now, ignore the work_out array */
    
    return Py_BuildValue("i",(int)vdi_handle);
}

PyObject* __CDECL py_v_clsvwk(PyObject *self, PyObject *args)
{
int handle;

    if(!PyArg_ParseTuple(args,"i",&handle))
        return NULL;
        
    v_clsvwk(handle);
    
    Py_INCREF(Py_None);
    return Py_None;
}

PyObject* __CDECL py_v_bar(PyObject *self, PyObject *args)
{
int handle;
int x1, y1, x2, y2;
short pxarray[4];

    if(!PyArg_ParseTuple(args,"i(ii)(ii)",&handle, &x1, &y1, &x2, &y2))
        return NULL;
        
    pxarray[0] = (short)x1;
    pxarray[1] = (short)y1;
    pxarray[2] = (short)x2;
    pxarray[3] = (short)y2;
    
    v_bar(handle,pxarray);
    
    Py_INCREF(Py_None);
    return Py_None;
}

PyObject* __CDECL py_v_ellipse(PyObject *self, PyObject *args)
{
int handle;
int x1, y1, xr, yr;

    if(!PyArg_ParseTuple(args,"i(ii)(ii)",&handle, &x1, &y1, &xr, &yr))
        return NULL;
    
    v_ellipse(handle,x1,y1,xr,yr);
    
    Py_INCREF(Py_None);
    return Py_None;
}

PyObject* __CDECL py_vsf_color(PyObject *self, PyObject *args)
{
int handle;
int index;

    if(!PyArg_ParseTuple(args,"ii",&handle, &index))
        return NULL;
    
    index = vsf_color(handle,index);
    
    return Py_BuildValue("i",index);
}

PyObject* __CDECL py_vs_clip(PyObject *self, PyObject *args)
{
int handle;
int x1, y1, x2, y2;
int enable;
short pxarray[4];

    if(!PyArg_ParseTuple(args,"ii(ii)(ii)",&handle, &enable, &x1, &y1, &x2, &y2))
        return NULL;
        
    pxarray[0] = (short)x1;
    pxarray[1] = (short)y1;
    pxarray[2] = (short)x2;
    pxarray[3] = (short)y2;
    
    vs_clip(handle,enable,pxarray);
    
    Py_INCREF(Py_None);
    return Py_None;
}
