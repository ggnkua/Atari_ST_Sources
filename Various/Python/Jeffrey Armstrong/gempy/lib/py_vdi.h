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

#ifndef __PY_VDI_HEADERS
#define __PY_VDI_HEADERS

#include "ldg_Python.h"

PyObject* __CDECL py_v_open_screen(PyObject *self, PyObject *args);
PyObject* __CDECL py_v_clsvwk(PyObject *self, PyObject *args);
PyObject* __CDECL py_v_bar(PyObject *self, PyObject *args);
PyObject* __CDECL py_v_ellipse(PyObject *self, PyObject *args);
PyObject* __CDECL py_vsf_color(PyObject *self, PyObject *args);
PyObject* __CDECL py_vs_clip(PyObject *self, PyObject *args);

#endif /* __PY_VDI_HEADERS */
