PROCEDURE make_pstring(VAR cs : CString; VAR ps : Str128);
EXTERNAL;

PROCEDURE make_cstring(VAR ps : Str128; VAR cs : CString);
EXTERNAL;

PROCEDURE beauty_path(VAR cst : CString);
EXTERNAL;

{ Metafile-Zeugs }

PROCEDURE m_opnwk(VAR handle : INTEGER);
EXTERNAL;

PROCEDURE m_clswk(handle : INTEGER);
EXTERNAL;

PROCEDURE m_updwk(handle : INTEGER);
EXTERNAL;

PROCEDURE m_meta_extents(handle,min_x,min_y,max_x,max_y : INTEGER);
EXTERNAL;

PROCEDURE m_gtext(handle,x,y : INTEGER; VAR cs : CString);
EXTERNAL;

PROCEDURE m_line(handle,x1,y1,x2,y2 : INTEGER);
EXTERNAL;

PROCEDURE m_filename(handle : INTEGER; VAR cs : CString);
EXTERNAL;

PROCEDURE m_pagesize(handle,b,h : INTEGER);
EXTERNAL;

PROCEDURE m_coords(handle,llx,lly,urx,ury : INTEGER);
EXTERNAL;
