

#ifndef __GMS_BDRF_AVX512_H__
#define __GMS_BDRF_AVX512_H__ 220720221235



/*MIT License
Copyright (c) 2020 Bernard Gingold
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

/*
      Adapted from the DISORT "BDREF.f" file.
*/



    const unsigned int GMS_BDREF_AVX512_MAJOR = 1U;
    const unsigned int GMS_BDREF_AVX512_MINOR = 0U;
    const unsigned int GMS_BDREF_AVX512_MICRO = 0U;
    const unsigned int GMS_BDREF_AVX512_FULLVER =
      1000U*GMS_BDREF_AVX512_MAJOR+
      100U*GMS_BDREF_AVX512_MINOR+
      10U*GMS_BDREF_AVX512_MICRO;
    const char * const GMS_BDREF_AVX512_CREATION_DATE = "22-07-2022 12:35 PM +00200 (FRI 22 JUL 2022 GMT+2)";
    const char * const GMS_BDREF_AVX512_BUILD_DATE    = __DATE__ ":" __TIME__;
    const char * const GMS_BDREF_AVX512_AUTHOR        = "Programmer: Bernard Gingold, contact: beniekg@gmail.com";
    const char * const GMS_BDREF_AVX512_DESCRIPTION   = "Vectorized (AVX512) BDREF functions."




#include <immintrin.h>
#include <stdint.h>
#include <stdbool.h>



                        __m512d
			bdrf_hapke_zmm8r8(const __m512d,
			                  const __m512d,
					  const __m512d,
					  const __m512d,
					  const __m512d,
					  const __m512d,
					  const __m512d) __attribute__((noinline))
			                                 __attribute__((hot))
				                         __attribute__((regcall))
				                         __attribute__((aligned(32)));


			__m512
			bdrf_hapke_zmm16r4(const __m512,
			                   const __m512,
					   const __m512,
					   const __m512,
					   const __m512,
					   const __m512,
					   const __m512d) __attribute__((noinline))
			                                  __attribute__((hot))
				                          __attribute__((regcall))
				                          __attribute__((aligned(32)));


			__m512d
			bdrf_rpv_zmm8r8(const __m512d,
			                const __m512d,
					const __m512d,
					const __m512d,
					const __m512d,
					const __m512d,
					const __m512d)    __attribute__((noinline))
			                                  __attribute__((hot))
				                          __attribute__((regcall))
				                          __attribute__((aligned(32)));


			__m512
			bdrf_rpv_zmm16r4(const __m512,
			                 const __m512,
					 const __m512,
					 const __m512,
					 const __m512,
					 const __m512,
					 const __m512)    __attribute__((noinline))
			                                  __attribute__((hot))
				                          __attribute__((regcall))
				                          __attribute__((aligned(32)));


			__m512d
			bdrf_rossli_zmm8r8(const __m512d,
			                   const __m512d,
					   const __m512d,
					   const __m512d,
					   const __m512d,
					   const __m512d,
					   const __m512d)  __attribute__((noinline))
			                                  __attribute__((hot))
				                          __attribute__((regcall))
				                          __attribute__((aligned(32)));

                        __m512d
			bdrf_rossli_zmm16r4(const __m512,
			                    const __m512,
					    const __m512,
					    const __m512,
					    const __m512,
					    const __m512,
					    const __m512d)  __attribute__((noinline))
			                                    __attribute__((hot))
				                            __attribute__((regcall))
				                            __attribute__((aligned(32)));


			__m512d
			brdf_ocean_zmm8r8(const bool,
			                  const __m512d,
					  const __m512d,
					  const __m512d,
					  const __m512d,
					  const __m512d)    __attribute__((noinline))
			                                    __attribute__((hot))
				                            __attribute__((regcall))
				                            __attribute__((aligned(32)));
		       
                        __m512
			brdf_ocean_zmm16r4(const bool,
			                  const __m512,
					  const __m512,
					  const __m512,
					  const __m512,
					  const __m512)    __attribute__((noinline))
			                                    __attribute__((hot))
				                            __attribute__((regcall))
				                            __attribute__((aligned(32)));


			__m512d
			shadow_eta_zmm8r8(const __m512d cos_theta,
			                  const __m512d sigma_sq,
					  const __m512d pi)  __attribute__((noinline))
			                                    __attribute__((hot))
				                            __attribute__((regcall))
				                            __attribute__((aligned(32)));


			__m512
			shadow_eta_zmm16r4(const __m512 cos_theta,
			                   const __m512 sigma_sq,
					   const __m512 pi)  __attribute__((noinline))
			                                    __attribute__((hot))
				                            __attribute__((regcall))
				                            __attribute__((aligned(32)));




							    


#emdif /*__GMS_BDRF_AVX512_H__*/
