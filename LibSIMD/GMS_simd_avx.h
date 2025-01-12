
#ifndef __GMS_SIMD_AVX_H__
#define __GMS_SIMD_AVX_H__

// File version number granularity
const int gSIMD_AVX_MAJOR = 1;

const int gSIMD_AVX_MINOR = 0;

const int gSIMD_AVX_MICRO = 0;

//const int gSIMD_AVX_FULLVER = 1000*gSIMD_AVX_MAJOR+100*gSIMD_AVX_MINOR+10*gSIMD_AVX_MICRO;

const char * const gSIMD_AVX_CREATE_DATE = "22-12-2018 11:08 + 00200 (SAT 22 DEC 2018 GMT+2)";

const char * const gSIMD_AVX_BUILD_DATE = __DATE__ ":" __TIME__;

const char * const gSIMD_AVX_AUTHOR = "Programmer: Bernard Gingold, contact: beniekg@gmail.com";

const char * const gSIMD_AVX_SYNOPSIS = "Callable from Fortran C wrappers for Intel AVX Intrinsics.";

//#if defined (__cplusplus)

//extern "C" {
	
	// Interoparable with coresponding Fortran derived type.
	typedef struct __declspec(align(32)) v4f64 {
		double v[4];
	}v4f64;

	// Vector addition
	// Calls: _mm256_add_pd
	v4f64 vec4f64_add_vec4f64(v4f64, v4f64);

	// Vector subtraction
	// Calls: _mm256_sub_pd
	v4f64 vec4f64_sub_vec4f64(v4f64, v4f64);

	// Vector multiplication
	// Calls: _mm256_mul_pd
	v4f64 vec4f64_mul_vec4f64(v4f64, v4f64);

	// Vector division
	// Calls: _mm256_div_pd
	v4f64 vec4f64_div_vec4f64(v4f64, v4f64);

    // Vector alternate addition-subtraction
	// Calls: _mm256_addsub_pd
	v4f64 vec4f64_addsub_vec4f64(v4f64, v4f64);

	// Vector bitwise AND
	// Calls: _mm256_and_pd
	v4f64 vec4f64_and_vec4f64(v4f64, v4f64);

	// Vector bitwise AND-NOT
    // Calls: _mm256_andnot_pd
	v4f64 vec4f64_andnot_vec4f64(v4f64, v4f64);

	// Vector blend
	// Calls: _mm256_blend_pd
	v4f64 vec4f64_blend0_vec4f64(v4f64, v4f64);

	v4f64 vec4f64_blend1_vec4f64(v4f64, v4f64);

	// Vector blend
	// Calls: _mm256_blendv_pd
	v4f64 vec4f64_blendv_vec4f64(v4f64, v4f64, v4f64);

	// Vector ceil
	// Calls: _mm256_ceil_pd
	v4f64 vec4f64_ceil_vec4f64(v4f64);

	// Vector compare
	// Calls: _mm256_cmp_pd
	v4f64 vec4f64_cmp_eqoq_vec4f64(v4f64, v4f64);

	v4f64 vec4f64_cmp_ltoq_vec4f64(v4f64, v4f64);

	v4f64 vec4f64_cmp_leoq_vec4f64(v4f64, v4f64);

	v4f64 vec4f64_cmp_neqoq_vec4f64(v4f64,v4f64);

	v4f64 vec4f64_cmp_gtoq_vec4f64(v4f64,v4f64);

	v4f64 vec4f64_cmp_geoq_vec4f64(v4f64,v4f64);

    // Vector floor
	// Calls: _mm256_floor_pd
	v4f64 vec4f64_floor_vec4f64(v4f64);

	// Vector FMADD
	// Calls: _mm256_fmadd_pd
	v4f64 vec4f64_fmadd_vec4f64(v4f64, v4f64, v4f64);

	// Vector FMADDSUB
	// Calls: _mm256_fmaddsub_pd
	v4f64 vec4f64_fmaddsub_vec4f64(v4f64, v4f64, v4f64);

	// Vector FMSUB
	// Calls: _mm256_fmsub_pd
	v4f64 vec4f64_fmsub_vec4f64(v4f64, v4f64, v4f64);

	// Vector FMSUBADD
	// Calls: _mm256_fmsubadd_pd
	v4f64 vec4f64_fmsubadd_vec4f64(v4f64, v4f64, v4f64);

	// Vector FNMADD
	// Calls: _mm256_fnmadd_pd
	v4f64 vec4f64_fnmadd_vec4f64(v4f64, v4f64, v4f64);

	// Vector FNMSUB
	// Calls: _mm256_fnmsub_pd
	v4f64 vec4f64_fnmsub_vec4f64(v4f64, v4f64, v4f64);

   // Vector HADD
   // Calls: _mm256_hadd_pd
	v4f64 vec4f64_hadd_vec4f64(v4f64, v4f64);

   // Vector HSUB
   // Calls: _mm256_hsub_pd
	v4f64 vec4f64_hsub_vec4f64(v4f64, v4f64);

   // Vector MAX
   // Calls: _mm256_max_pd
	v4f64 vec4f64_max_vec4f64(v4f64, v4f64);

   // Vector MIN
   // Calls: _mm256_min_pd
	v4f64 vec4f64_min_vec4f64(v4f64,v4f64);

   // Vector MOVEDUP
   // Calls: _mm256_movedup_pd
	v4f64 vec4f64_movedup_vec4f64(v4f64);

   // Vector MOVEMASK
   // Calls: _mm256_movemask_pd
	int vec4f64_movemask_vec4f64(v4f64);

	// Vector bitwise OR
	// Calls: _mm256_or_pd
	v4f64 vec4f64_or_vec4f64(v4f64, v4f64);

	

    //
	// The same functionality implememted as void functions
	//

	// Vector addition
	// Calls: _mm256_add_pd
	void vec4f64_add_pd(double * __restrict, double * __restrict, double * __restrict);

	// Vector subtraction
	// Calls: _mm256_sub_pd
	void vec4f64_sub_pd(double * __restrict, double * __restrict, double * __restrict);

	// Vector multiplication
	// Calls: _mm256_mul_pd
	void vec4f64_mul_pd(double * __restrict, double * __restrict, double * __restrict);

	// Vector division
	// Calls: _mm256_div_pd
	void vec4f64_div_pd(double * __restrict, double * __restrict, double * __restrict);

	// Vector alternate addition-subtraction
	// Calls: _mm256_addsub_pd
	void vec4f64_addsub_pd(double * __restrict, double * __restrict, double * __restrict);

	// Vector bitwise AND
	// Calls: _mm256_and_pd
	void vec4f64_and_pd(double * __restrict, double * __restrict, double * __restrict);

	// Vector bitwise AND-NOT
	// Calls: _mm256_andnot_pf
	void vec4f64_andnot_pd(double * __restrict, double * __restrict, double * __restrict);

	

	// Vector blend
	// Calls: _mm256_blendv_pd
	void vec4f64_blendv_pd(double * __restrict, double * __restrict, double * __restrict, double * __restrict);

	// Vector ceil
	// Calls: _mm256_ceil_pd
	void vec4f64_ceil_pd(double * __restrict, double * __restrict);

	// Vector compare
	// Calls: _mm256_cmp_pd
	void vec4f64_cmpeq_pd(double * __restrict, double * __restrict, double * __restrict);

	void vec4f64_cmpneq_pd(double * __restrict, double * __restrict, double * __restrict);

	void vec4f64_cmplt_pd(double * __restrict, double * __restrict, double * __restrict);

	void vec4f64_cmple_pd(double * __restrict, double * __restrict, double * __restrict);

	void vec4f64_cmpgt_pd(double * __restrict, double * __restrict, double * __restrict);

	void vec4f64_cmpge_pd(double * __restrict, double * __restrict, double * __restrict);


	// Vector floor
	// Calls: _mm256_floor_pd
	void vec4f64_floor_pd(double * __restrict, double * __restrict);

	// Vector FMADD
	// Calls: _mm256_fmadd_pd
	void vec4f64_fmadd_pd(double * __restrict, double * __restrict, double * __restrict, double * __restrict);

	// Vector FMADDSUB
	// Calls: _mm256_fmaddsub_pd
	void vec4f64_fmaddsub_pd(double * __restrict, double * __restrict, double * __restrict, double * __restrict);

	// Vector FMSUB
	// Calls: _mm256_fmsub_pd
	void vec4f64_fmsub_pd(double * __restrict, double * __restrict, double * __restrict, double * __restrict);

	// Vector FMSUBADD
	// Calls: _mm256_fmsubadd_pd
	void vec4f64_fmsubadd_pd(double * __restrict, double * __restrict, double * __restrict, double * __restrict);

	// Vector FNMADD
	// Calls: _mm256_fnmadd_pd
	void vec4f64_fnmadd_pd(double * __restrict, double * __restrict, double * __restrict, double * __restrict);

	// Vector FNMSUB
	// Calls: _mm256_fnmsub_pd
	void vec4f64_fnmsub_pd(double * __restrict, double * __restrict, double * __restrict, double * __restrict);

	// Vector HADD
	// Calls: _mm256_hadd_pd
	void vec4f64_hadd_pd(double * __restrict, double * __restrict, double * __restrict);

	// Vector HSUB
	// Calls: _mm256_hsub_pd
	void vec4f64_hsub_pd(double * __restrict, double * __restrict, double * __restrict);

	// Vector MAX
	// Calls: _mm256_max_pd
	void vec4f64_max_pd(double * __restrict, double * __restrict, double * __restrict);

	// Vector MIN
	// Calls: _mm256_min_pd
	void vec4f64_min_pd(double * __restrict, double * __restrict, double * __restrict);

	// Vector MOVEDUP
	// Calls: _mm256_movedup_pd
	void vec4f64_movedup_pd(double * __restrict, double * __restrict);

	// Vector MOVEMASK
	// Calls: _mm256_movemask_pd
	void vecf64_movemask_pd(double * __restrict, int *);

	// Vector bitwise OR
	// Calls: _mm256_or_pd
	void vec4f64_or_pd(double * __restrict, double * __restrict, double * __restrict);

	

	// Calls: _mm256_cvtpd_ps
	void vec4f64_cvtpd_ps(float * __restrict, double * __restrict);

	// Calls: _mm256_cvtps_pd
	void vec4f64_cvtps_pd(double * __restrict, float * __restrict);

	// Calls: _mm256_sqrt_pd
	void vec4f64_sqrt_pd(double * __restrict, double * __restrict);

	// Calls: _mm256_undefined_pd
	void vec4f64_undefined_pd(double * __restrict);

	// Calls: _mm256_zeroall
	void vec_zeroall(void);

	// Calls: _mm256_zeroupper
	void vec_zeroupper(void);

	// Calls: _mm256_broadcast_pd
	void vec4f64_broadcast_pd(double * __restrict, double * __restrict);

	// Calls: _mm256_broadcast_sd
	void vec4f64_broadcast_sd(double * __restrict,  const double * __restrict);

	// Calls: _mm256_testc_pd
	void vec4f64_testc_pd(int *, double * __restrict, double * __restrict);

	// Calls: _mm256_testnzc_pd
	void vec4f64_testnzc_pd(int *, double * __restrict, double * __restrict);

	// Calls: _mm256_testz_pd
	void vec4f64_testz_pd(int *, double * __restrict, double * __restrict);

	// Calls: _mm256_round_pd
	void vec4f64_round_nearest_pd(double * __restrict, double * __restrict);

	void vec4f64_round_down_pd(double * __restrict, double * __restrict);

	void vec4f64_round_up_pd(double * __restrict, double * __restrict);

	void vec4f64_round_truncate_pd(double * __restrict, double * __restrict);

	// Calls: _mm256_stream_pd
	void vec4f64_stream_pd(double * __restrict, double * __restrict);

	// Calls: _mm256_unpacklo_pd
	void vec4f64_unpacklo_pd(double * __restrict, double * __restrict, double * __restrict);

	// Calls: _mm256_unpackhi_pd
	void vec4f64_unpackhi_pd(double * __restrict, double * __restrict, double * __restrict);

	

	

	// Calls: _mm_acos_pd
	void vec2f64_acos_pd(double * __restrict, const double  * __restrict);

	// Calls: _mm256_acos_pd
	void vec4f64_acos_pd(double * __restrict, const double  * __restrict);

	// Calls: _mm_acosh_pd
	void vec2f64_acosh_pd(double * __restrict, const double * __restrict);

	// Calls: _mm256_acosh_pd
	void vec4f64_acosh_pd(double * __restrict, const double * __restrict);

	// Calls: _mm_asin_pd
	void vec2f64_asin_pd(double * __restrict, const double * __restrict);

	// Calls: _mm256_asin_pd
	void vec4f64_asin_pd(double * __restrict, const double * __restrict);

	// Calls: _mm_asinh_pd
	void vec2f64_asinh_pd(double * __restrict, const double * __restrict);

	// Calls: _mm256_asinh_pd
	void vec4f64_asinh_pd(double * __restrict, const double * __restrict);

	// Calls: _mm_atan2_pd
	void vec2f64_atan2_pd(double * __restrict, const double * __restrict, const double * __restrict);

	void vec4f64_atan2_pd(double * __restrict, const double * __restrict, const double * __restrict);

	void vec2f64_atan_pd(double * __restrict, const double * __restrict);

	void vec4f64_atan_pd(double * __restrict, const double * __restrict);

	void vec2f64_atanh_pd(double * __restrict, const double * __restrict);

	void vec4f64_atanh_pd(double * __restrict, const double * __restrict);

	void vec2f64_cbrt_pd(double * __restrict, const double * __restrict);

	void vec4f64_cbrt_pd(double * __restrict, const double * __restrict);

	void vec2f64_cdfnorm_pd(double * __restrict, const double * __restrict);

	void vec4f64_cdfnorm_pd(double * __restrict, const double * __restrict);

	void vec2f64_cdfnorminv_pd(double * __restrict, const double * __restrict);

	void vec4f64_cdfnorminv_pd(double * __restrict, const double * __restrict);

	void vec2f64_cos_pd(double * __restrict, const double * __restrict);

	void vec4f64_cos_pd(double * __restrict, const double * __restrict);

	void vec2f64_cosh_pd(double * __restrict, const double * __restrict);

	void vec4f64_cosh_pd(double * __restrict, const double * __restrict);

	void vec2f64_erf_pd(double * __restrict, const double * __restrict);

	void vec4f64_erf_pd(double * __restrict, const double * __restrict);

	void vec2f64_erfc_pd(double * __restrict, const double * __restrict);

	void vec4f64_erfc_pd(double * __restrict, const double * __restrict);

	void vec2f64_erfcinv_pd(double * __restrict, const double * __restrict);

	void vec4f64_erfcinv_pd(double * __restrict, const double * __restrict);

	void vec2f64_erfinv_pd(double * __restrict, const double * __restrict);

	void vec4f64_erfinv_pd(double * __restrict, const double * __restrict);

	void vec2f64_exp10_pd(double * __restrict, const double * __restrict);

	void vec4f64_exp10_pd(double * __restrict, const double * __restrict);

	void vec2f64_exp2_pd(double * __restrict, const double * __restrict);

	void vec4f64_exp2_pd(double * __restrict, const double * __restrict);

	void vec2f64_exp_pd(double * __restrict, const double * __restrict);

	void vec4f64_exp_pd(double * __restrict, const double * __restrict);

	void vec2f64_expm1_pd(double * __restrict, const double * __restrict);

	void vec4f64_expm1_pd(double * __restrict, const double * __restrict);

	void vec2f6_hypot_pd(double * __restrict, const double * __restrict, const double * __restrict);

	void vec4f64_hypot_pd(double * __restrict, const double * __restrict, const double * __restrict);

	void vec2f64_invcbrt_pd(double * __restrict, const double * __restrict);

	void vec4f64_invcbrt_pd(double * __restrict, const double * __restrict);

	void vec2f64_invsqrt_pd(double * __restrict, const double * __restrict);

	void vec4f64_invsqrt_pd(double * __restrict, const double * __restrict);

	void vec2f64_log10_pd(double * __restrict, const double * __restrict);

	void vec4f64_log10_pd(double * __restrict, const double * __restrict);

	void vec2f64_log1p_pd(double * __restrict, const double * __restrict);

	void vec4f64_log1p_pd(double * __restrict, const double * __restrict);

	void vec2f64_log2_pd(double * __restrict, const double * __restrict);

	void vec4f64_log2_pd(double * __restrict, const double * __restrict);

	void vec2f64_log_pd(double * __restrict, const double * __restrict);

	void vec4f64_log_pd(double * __restrict, const double * __restrict);

	void vec2f64_logb_pd(double * __restrict, const double * __restrict);

	void vec4f64_logb_pd(double * __restrict, const double * __restrict);

	void vec2f64_pow_pd(double * __restrict, const double * __restrict);

	void vec4f64_pow_pd(double * __restrict, const double * __restrict);

	void vec2f64_sin_pd(double * __restrict, const double * __restrict);

	void vec4f64_sin_pd(double * __restrict, const double * __restrict);

	void vec2f64_sincos_pd(double * __restrict, const double * __restrict, const double * __restrict);

	void vec4f64_sincos_pd(double * __restrict, const double * __restrict, const double * __restrict);

	void vec2f64_sind_pd(double * __restrict, const double * __restrict);

	void vec4f64_sind_pd(double * __restrict, const double * __restrict);

	void vec2f64_sinh_pd(double * __restrict, const double * __restrict);

	void vec4f64_sinh_pd(double * __restrict, const double * __restrict);

	void vec2f64_tan_pd(double * __restrict, const double * __restrict);

	void vec4f64_tan_pd(double * __restrict, const double * __restrict);

	void vec2f64_tand_pd(double * __restrict, const double * __restrict);

	void vec4f64_tand_pd(double * __restrict, const double * __restrict);

	void vec2f64_tanh_pd(double * __restrict, const double * __restrict);

	void vec4f64_tanh_pd(double * __restrict, const double * __restrict);

	void vec2f64_trunc_pd(double * __restrict, const double * __restrict);

	void vec4f64_trunc_pd(double * __restrict, const double * __restrict);

	void vecf64_setzero_pd(double * __restrict);

	void vecf64_set1_pd(double * __restrict, const double);

	void vecf64_set_m128d(double * __restrict, const double * __restrict, const double * __restrict);

	void vec4f64_set_pd(double * __restrict, const double, const double, const double, const double);

	void vecf64_setr_m128d(double * __restrict, const double * __restrict, const double * __restrict);

	void vec4f64_setr_pd(double * __restrict, const double, const double, const double, const double);

	void allow_cpu_features(unsigned __int64 );

	void may_i_use_cpu_feature(int *, unsigned __int64);

	// Optimized arithmetic operations

	void vecf32_divps_acc_24bit(float * __restrict, 
							    const float * __restrict, 
								const float * __restrict, 
								const long long int);

	void vecf32_rcpps_acc_11bit(float* __restrict, 
								const float * __restrict, 
								const float * __restrict, 
								const long long int);

	void vecf32_rcpps_mulps_acc_22bit(float * __restrict , 
									  const float * __restrict , 
									  const float * __restrict, 
									  const long long int);



//} // extern "C" end of



//#endif






#endif /*__GMS_SIMD_AVX_H__*/
