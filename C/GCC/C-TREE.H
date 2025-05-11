/* Definitions for C parsing and type checking.
   Copyright (C) 1987 Free Software Foundation, Inc.

This file is part of GNU CC.

GNU CC is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY.  No author or distributor
accepts responsibility to anyone for the consequences of using it
or for whether it serves any particular purpose or works at all,
unless he says so in writing.  Refer to the GNU CC General Public
License for full details.

Everyone is granted permission to copy, modify and redistribute
GNU CC, but only under the conditions described in the
GNU CC General Public License.   A copy of this license is
supposed to have been given to you along with GNU CC so you
can know your rights and responsibilities.  It should be in a
file named COPYING.  Among other things, the copyright notice
and this notice must be preserved on all copies.  */

/* Nonzero means reject anything that ANSI standard C forbids.  */
extern int pedantic;

/* In a RECORD_TYPE or UNION_TYPE, nonzero if any component is read-only.  */
#define C_TYPE_FIELDS_READONLY(type) TYPE_SEP_UNIT (type)

/* in typecheck.c */
extern tree build_component_ref(), build_conditional_expr(), build_compound_expr();
extern tree build_unary_op(), build_binary_op(), build_function_call();
extern tree build_binary_op_nodefault ();
extern tree build_indirect_ref(), build_array_ref(), build_c_cast();
extern tree build_modify_expr();
extern tree c_sizeof (), c_alignof ();
extern void store_init_value ();
extern tree digest_init ();
extern tree c_expand_start_case ();
extern tree default_conversion ();

/* Given two integer or real types, return the type for their sum.
   Given two compatible ANSI C types, returns the merged type.  */

extern tree commontype ();

/* in decl.c */
extern tree build_label ();

extern int start_function ();
extern void finish_function ();
extern void store_parm_decls ();
extern tree get_parm_info ();

extern void pushlevel(), poplevel();

extern tree groktypename(), lookup_name();

extern tree lookup_label(), define_label();

extern tree implicitly_declare(), getdecls(), gettags ();

extern tree start_decl();
extern void finish_decl();

extern tree start_struct(), finish_struct(), xref_tag();
extern tree grokfield();

extern tree start_enum(), finish_enum();
extern tree build_enumerator();

extern tree make_index_type ();

extern tree double_type_node, long_double_type_node, float_type_node;
extern tree char_type_node, unsigned_char_type_node, signed_char_type_node;

extern tree short_integer_type_node, short_unsigned_type_node;
extern tree long_integer_type_node, long_unsigned_type_node;
extern tree unsigned_type_node;
extern tree string_type_node, char_array_type_node, int_array_type_node;

extern int current_function_returns_value;
extern int current_function_returns_null;

extern void yyerror();
extern int lineno;

extern tree ridpointers[];

/* Points to the FUNCTION_DECL of the function whose body we are reading. */
extern tree current_function_decl;
