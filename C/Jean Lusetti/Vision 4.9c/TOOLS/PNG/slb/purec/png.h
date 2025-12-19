/*
 * For Pure-C, we still need do redirect some functions
 * that use double arguments and/or return values
 */
#ifdef PNG_FLOATING_POINT_SUPPORTED

#if (defined(__68881__) || defined(_M68881) || defined(__M68881__) || defined(__MATH_68881__))

PNG_FP_EXPORT(32, void, png_pc8_set_rgb_to_gray, (png_structrp png_ptr,
    png_int_t error_action, double red, double green))
#define png_set_rgb_to_gray(ptr, error_action, red, green) png_pc8_set_rgb_to_gray(ptr, error_action, red, green)

PNG_FP_EXPORT(47, void, png_pc8_set_background, (png_structrp png_ptr,
    png_const_color_16p background_color, png_int_t background_gamma_code,
    png_int_t need_expand, double background_gamma))
#define png_set_background(ptr, bg, code, expand, gamma) png_pc8_set_background(ptr, bg, code, expand, gamma)

PNG_FP_EXPORT(50, void, png_pc8_set_gamma, (png_structrp png_ptr,
    double screen_gamma, double override_file_gamma))
#define png_set_gamma(ptr, screen, file) png_pc_set_gamma(ptr, screen, file)

PNG_FP_EXPORT(68, void, png_pc8_set_filter_heuristics, (png_structrp png_ptr,
    png_int_t heuristic_method, png_int_t num_weights, png_const_doublep filter_weights,
    png_const_doublep filter_costs))
#define png_set_filter_heuristics(ptr, method, num, filter, costs) png8_pc_set_filter_heuristics(ptr, method, num, filter, costs)

PNG_FP_EXPORT(125, float, png_pc8_get_pixel_aspect_ratio,
    (png_const_structrp png_ptr, png_const_inforp info_ptr))
#define png_get_pixel_aspect_ratio(ptr, info) png_pc8_get_pixel_aspect_ratio(ptr, info)

PNG_FP_EXPORT(133, png_uint_32, png_pc8_get_cHRM, (png_const_structrp png_ptr,
    png_const_inforp info_ptr, double *white_x, double *white_y, double *red_x,
    double *red_y, double *green_x, double *green_y, double *blue_x,
    double *blue_y))
#define png_get_cHRM(ptr, info, white_x, white_y, red_x, red_y, green_x, green_y, blue_x, blue_y) \
	png_pc8_get_cHRM(ptr, info, white_x, white_y, red_x, red_y, green_x, green_y, blue_x, blue_y)

PNG_FP_EXPORT(135, void, png_pc8_set_cHRM, (png_const_structrp png_ptr,
    png_inforp info_ptr,
    double white_x, double white_y, double red_x, double red_y, double green_x,
    double green_y, double blue_x, double blue_y))
#define png_set_cHRM(ptr, info, white_x, white_y, red_x, red_y, green_x, green_y, blue_x, blue_y) \
	png_pc8_set_cHRM(ptr, info, white_x, white_y, red_x, red_y, green_x, green_y, blue_x, blue_y)

PNG_FP_EXPORT(137, png_uint_32, png_pc8_get_gAMA, (png_const_structrp png_ptr,
    png_const_inforp info_ptr, double *file_gamma))
#define png_get_gAMA(ptr, info, gamma) png_pc8_get_gAMA(ptr, info, gamma)

PNG_FP_EXPORT(139, void, png_pc8_set_gAMA, (png_const_structrp png_ptr,
    png_inforp info_ptr, double file_gamma))
#define png_set_gAMA(ptr, info, gamma) png_pc8_set_gAMA(ptr, info, gamma)

PNG_FP_EXPORT(168, png_uint_32, png_pc8_get_sCAL, (png_const_structrp png_ptr,
    png_const_inforp info_ptr, png_int_t *unit, double *width, double *height))
#define png_get_sCAL(ptr, info, unit, width, height) png_pc8_get_sCAL(ptr, info, unit, width, height)

PNG_FP_EXPORT(170, void, png_pc8_set_sCAL, (png_const_structrp png_ptr,
    png_inforp info_ptr, png_int_t unit, double width, double height))
#define png_set_sCAL(ptr, info, unit, width, height) png_pc8_set_sCAL(ptr, info, unit, width, height)

PNG_FP_EXPORT(196, float, png_pc8_get_x_offset_inches,
    (png_const_structrp png_ptr, png_const_inforp info_ptr))
#define png_get_x_offset_inches(ptr, info) png_pc8_get_x_offset_inches(ptr, info)

PNG_FP_EXPORT(197, float, png_pc8_get_y_offset_inches,
    (png_const_structrp png_ptr, png_const_inforp info_ptr))
#define png_get_y_offset_inches(ptr, info) png_pc8_get_y_offset_inches(ptr, info)

PNG_FP_EXPORT(227, void, png_pc8_set_alpha_mode, (png_structrp png_ptr, png_int_t mode,
    double output_gamma))
#define png_set_alpha_mode(ptr, mode, gama) png_pc8_set_alpha_mode(ptr, mode, gamma)

PNG_FP_EXPORT(230, png_uint_32, png_pc8_get_cHRM_XYZ, (png_const_structrp png_ptr,
    png_const_inforp info_ptr, double *red_X, double *red_Y, double *red_Z,
    double *green_X, double *green_Y, double *green_Z, double *blue_X,
    double *blue_Y, double *blue_Z))
#define png_get_cHRM_XYZ(ptr, info, red_X, red_Y, red_Z, green_X, green_Y, green_Z, blue_X, blue_Y, blue_Z) \
	png_pc8_get_cHRM_XYZ(ptr, info, red_X, red_Y, red_Z, green_X, green_Y, green_Z, blue_X, blue_Y, blue_Z)

PNG_FP_EXPORT(232, void, png_pc8_set_cHRM_XYZ, (png_const_structrp png_ptr,
    png_inforp info_ptr, double red_X, double red_Y, double red_Z,
    double green_X, double green_Y, double green_Z, double blue_X,
    double blue_Y, double blue_Z))
#define png_set_cHRM_XYZ(ptr, info, red_X, red_Y, red_Z, green_X, green_Y, green_Z, blue_X, blue_Y, blue_Z) \
	png_pc8_set_cHRM_XYZ(ptr, info, red_X, red_Y, red_Z, green_X, green_Y, green_Z, blue_X, blue_Y, blue_Z)

#define slb_pnglib_open slb_pnglib_open881
long slb_pnglib_open881(const char *slbpath);
#define slb_pnglib_close slb_pnglib_close881
void slb_pnglib_close881(void);

#else

PNG_FP_EXPORT(32, void, png_pc_set_rgb_to_gray, (png_structrp png_ptr,
    png_int_t error_action, double red, double green))
#define png_set_rgb_to_gray(ptr, error_action, red, green) png_pc_set_rgb_to_gray(ptr, error_action, red, green)

PNG_FP_EXPORT(47, void, png_pc_set_background, (png_structrp png_ptr,
    png_const_color_16p background_color, png_int_t background_gamma_code,
    png_int_t need_expand, double background_gamma))
#define png_set_background(ptr, bg, code, expand, gamma) png_pc_set_background(ptr, bg, code, expand, gamma)

PNG_FP_EXPORT(50, void, png_pc_set_gamma, (png_structrp png_ptr,
    double screen_gamma, double override_file_gamma))
#define png_set_gamma(ptr, screen, file) png_pc_set_gamma(ptr, screen, file)

PNG_FP_EXPORT(68, void, png_pc_set_filter_heuristics, (png_structrp png_ptr,
    png_int_t heuristic_method, png_int_t num_weights, png_const_doublep filter_weights,
    png_const_doublep filter_costs))
#define png_set_filter_heuristics(ptr, method, num, filter, costs) png_pc_set_filter_heuristics(ptr, method, num, filter, costs)

PNG_FP_EXPORT(125, float, png_pc_get_pixel_aspect_ratio,
    (png_const_structrp png_ptr, png_const_inforp info_ptr))
#define png_get_pixel_aspect_ratio(ptr, info) png_pc_get_pixel_aspect_ratio(ptr, info)

PNG_FP_EXPORT(133, png_uint_32, png_pc_get_cHRM, (png_const_structrp png_ptr,
    png_const_inforp info_ptr, double *white_x, double *white_y, double *red_x,
    double *red_y, double *green_x, double *green_y, double *blue_x,
    double *blue_y))
#define png_get_cHRM(ptr, info, white_x, white_y, red_x, red_y, green_x, green_y, blue_x, blue_y) \
	png_pc_get_cHRM(ptr, info, white_x, white_y, red_x, red_y, green_x, green_y, blue_x, blue_y)

PNG_FP_EXPORT(135, void, png_pc_set_cHRM, (png_const_structrp png_ptr,
    png_inforp info_ptr,
    double white_x, double white_y, double red_x, double red_y, double green_x,
    double green_y, double blue_x, double blue_y))
#define png_set_cHRM(ptr, info, white_x, white_y, red_x, red_y, green_x, green_y, blue_x, blue_y) \
	png_pc_set_cHRM(ptr, info, white_x, white_y, red_x, red_y, green_x, green_y, blue_x, blue_y)

PNG_FP_EXPORT(137, png_uint_32, png_pc_get_gAMA, (png_const_structrp png_ptr,
    png_const_inforp info_ptr, double *file_gamma))
#define png_get_gAMA(ptr, info, gamma) png_pc_get_gAMA(ptr, info, gamma)

PNG_FP_EXPORT(139, void, png_pc_set_gAMA, (png_const_structrp png_ptr,
    png_inforp info_ptr, double file_gamma))
#define png_set_gAMA(ptr, info, gamma) png_pc_set_gAMA(ptr, info, gamma)

PNG_FP_EXPORT(168, png_uint_32, png_pc_get_sCAL, (png_const_structrp png_ptr,
    png_const_inforp info_ptr, png_int_t *unit, double *width, double *height))
#define png_get_sCAL(ptr, info, unit, width, height) png_pc_get_sCAL(ptr, info, unit, width, height)

PNG_FP_EXPORT(170, void, png_pc_set_sCAL, (png_const_structrp png_ptr,
    png_inforp info_ptr, png_int_t unit, double width, double height))
#define png_set_sCAL(ptr, info, unit, width, height) png_pc_set_sCAL(ptr, info, unit, width, height)

PNG_FP_EXPORT(196, float, png_pc_get_x_offset_inches,
    (png_const_structrp png_ptr, png_const_inforp info_ptr))
#define png_get_x_offset_inches(ptr, info) png_pc_get_x_offset_inches(ptr, info)

PNG_FP_EXPORT(197, float, png_pc_get_y_offset_inches,
    (png_const_structrp png_ptr, png_const_inforp info_ptr))
#define png_get_y_offset_inches(ptr, info) png_pc_get_y_offset_inches(ptr, info)

PNG_FP_EXPORT(227, void, png_pc_set_alpha_mode, (png_structrp png_ptr, png_int_t mode,
    double output_gamma))
#define png_set_alpha_mode(ptr, mode, gama) png_pc_set_alpha_mode(ptr, mode, gamma)

PNG_FP_EXPORT(230, png_uint_32, png_pc_get_cHRM_XYZ, (png_const_structrp png_ptr,
    png_const_inforp info_ptr, double *red_X, double *red_Y, double *red_Z,
    double *green_X, double *green_Y, double *green_Z, double *blue_X,
    double *blue_Y, double *blue_Z))
#define png_get_cHRM_XYZ(ptr, info, red_X, red_Y, red_Z, green_X, green_Y, green_Z, blue_X, blue_Y, blue_Z) \
	png_pc_get_cHRM_XYZ(ptr, info, red_X, red_Y, red_Z, green_X, green_Y, green_Z, blue_X, blue_Y, blue_Z)

PNG_FP_EXPORT(232, void, png_pc_set_cHRM_XYZ, (png_const_structrp png_ptr,
    png_inforp info_ptr, double red_X, double red_Y, double red_Z,
    double green_X, double green_Y, double green_Z, double blue_X,
    double blue_Y, double blue_Z))
#define png_set_cHRM_XYZ(ptr, info, red_X, red_Y, red_Z, green_X, green_Y, green_Z, blue_X, blue_Y, blue_Z) \
	png_pc_set_cHRM_XYZ(ptr, info, red_X, red_Y, red_Z, green_X, green_Y, green_Z, blue_X, blue_Y, blue_Z)

#endif /* m68881 */
#endif /* PNG_FLOATING_POINT_SUPPORTED */
