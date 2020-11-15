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

/* Dynamic Libraries for FreeMiNT (LDG) */

#include <Python.h>
#include "importdl.h"
#include <ldg.h>

#define PY_API_FCOUNT   14

const struct filedescr _PyImport_DynLoadFiletab[] = {
    {".ldg", "rb", C_EXTENSION},
    {"module.ldg", "rb", C_EXTENSION},
    {0, 0, 0}
};

//PyObject *Py_InitModule(char *name, PyMethodDef *methods);

dl_funcptr _PyImport_GetDynLoadFunc(const char *fqname, const char *shortname,
                                    const char *pathname, FILE *fp)
{
    dl_funcptr p;
    LDG *library;
    short aes_gl;
    char errBuf[256];
    
    char funcname[258];
    
    /* For assigning callbacks to the module */
    void (*assign_pycalls)(void *);
    void *callbacks[PY_API_FCOUNT];

    PyOS_snprintf(funcname, sizeof(funcname), "init%.200s", shortname);

    p = NULL;

    library = ldg_open(pathname, &aes_gl);

    /* Proceed on success */
    if(library != NULL) {
        
        /* Initialize the callbacks */
        assign_pycalls = ldg_find("assign_pycalls",library);
        if(assign_pycalls == NULL) { 
            PyOS_snprintf(errBuf, sizeof(errBuf),
                          "Could not find function assign_pycalls");
            PyErr_SetString(PyExc_ImportError, errBuf);
        } else {
            
            callbacks[0] = &Py_InitModule4;
            callbacks[1] = &PyArg_ParseTuple;
            callbacks[2] = &Py_BuildValue;
            callbacks[3] = &PyErr_NewException;
            callbacks[4] = &PyErr_SetString;
            callbacks[5] = &PyModule_AddObject;
            callbacks[6] = &PyCapsule_New;
            callbacks[7] = &PyCapsule_GetPointer;
            callbacks[8] = &Py_IncRef;
            callbacks[9] = &Py_DecRef;
            callbacks[10] = Py_None;
            callbacks[11] = &PyArg_ParseTupleAndKeywords;
            callbacks[12] = &PyString_Type;
            callbacks[13] = &PyString_AsString;
            
            assign_pycalls(callbacks);
        
            p = (dl_funcptr)ldg_find(funcname,library);
            if(p == NULL) { 
                PyOS_snprintf(errBuf, sizeof(errBuf),
                              "Could not find function %s",funcname);
               PyErr_SetString(PyExc_ImportError, errBuf);
            }
        }   
         
    } else {
        PyOS_snprintf(errBuf, sizeof(errBuf),
                      "LDG load failed with error code %d",
                      ldg_error());
        PyErr_SetString(PyExc_ImportError, errBuf);
    }

    return p;
}