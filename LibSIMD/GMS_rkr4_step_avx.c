

#include "GMS_rkr4_step_avx.h"
#include "GMS_simd_utils.h"


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


                        __m256d
			rkr4_step_ymm4r8(__m256d(*f)(__m256d,
			                             __m256d),
					 __m256d y0,
					 __m256d x0,
					 const __m256d h,
					 const int32_t n) {

			     const __m256d a2    = _mm256_set1_pd(0.40);
			     const __m256d h2    = _mm256_mul_pd(a2,h);
			     const __m256d a3    = _mm256_set1_pd(0.4557372542187894323578);
			     const __m256d h3    = _mm256_mul_pd(a3,h);
			     const __m256d b31   = _mm256_set1_pd(0.2969776092477535968389);
			     const __m256d b32   = _mm256_set1_pd(0.1587596449710358355189);
			     const __m256d b41   = _mm256_set1_pd(0.2181003882259204667927);
			     const __m256d b42   = _mm256_set1_pd(−3.0509651486929308025876);
			     const __m256d b43   = _mm256_set1_pd(3.8328647604670103357948);
			     const __m256d g1    = _mm256_set1_pd(0.1747602822626903712242);
			     const __m256d g2    = _mm256_set1_pd(−0.5514806628787329399404);
			     const __m256d g3    = _mm256_set1_pd(1.2055355993965235343777);
			     const __m256d g4    = _mm256_set1_pd(0.1711847812195190343385);
			     __m256d k1,k2,k3,k4;
			     __m256d t0,t1,t2;

			     while(--n >= 0) {
                                   k1 = f(x0,y0);
				   k2 = f(_mm256_add_pd(x0,h2),
				          _mm256_fmadd_pd(h2,k1,y0));
				   t0 = _mm256_fmadd_pd(h,_mm256_fmadd_pd(b31,k2,_mm256_mul_pd(b32,k2)),y0);
				   k3 = f(_mm256_add_pd(x0,h3),t0);
				   x0 = _mm256_add_pd(x0,h);
				   t1 = _mm256_fmadd_pd(h,_mm256_fmadd_pd(b41,k1,
				                                      _mm256_fmadd_pd(b42,k2,
								                  _mm256_mul_pd(b43,k3)),y0));
				   k4 = f(x0,t0);
				   t2 = _mm256_fmadd_pd(g1,k1,
				                    _mm256_fmadd_pd(g2,k2,
						                _mm256_fmadd_pd(g3,k3,
								            _mm256_mul_pd(g4,k4))));
				   y0 = _mm256_fmadd_pd(h0,t2,y0);
			     }
			     return (y0);
		      }


		        __m256
			rkr4_step_ymm8r4(__m256(*f)(__m256,
			                             __m256),
					 __m256 y0,
					 __m256 x0,
					 const __m256 h,
					 const int32_t n) {

			     const __m256 a2    = _mm256_set1_ps(0.40F);
			     const __m256 h2    = _mm256_mul_ps(a2,h);
			     const __m256 a3    = _mm256_set1_ps(0.4557372542187894323578F);
			     const __m256 h3    = _mm256_mul_ps(a3,h);
			     const __m256 b31   = _mm256_set1_ps(0.2969776092477535968389F);
			     const __m256 b32   = _mm256_set1_ps(0.1587596449710358355189F);
			     const __m256 b41   = _mm256_set1_ps(0.2181003882259204667927F);
			     const __m256 b42   = _mm256_set1_ps(−3.0509651486929308025876F);
			     const __m256 b43   = _mm256_set1_ps(3.8328647604670103357948F);
			     const __m256 g1    = _mm256_set1_ps(0.1747602822626903712242F);
			     const __m256 g2    = _mm256_set1_ps(−0.5514806628787329399404F);
			     const __m256 g3    = _mm256_set1_ps(1.2055355993965235343777F);
			     const __m256 g4    = _mm256_set1_ps(0.1711847812195190343385F);
			     __m256 k1,k2,k3,k4;
			     __m256 t0,t1,t2;

			     while(--n >= 0) {
                                   k1 = f(x0,y0);
				   k2 = f(_mm256_add_ps(x0,h2),
				          _mm256_fmadd_ps(h2,k1,y0));
				   t0 = _mm256_fmadd_ps(h,_mm256_fmadd_ps(b31,k2,_mm256_mul_ps(b32,k2)),y0);
				   k3 = f(_mm256_add_ps(x0,h3),t0);
				   x0 = _mm256_add_ps(x0,h);
				   t1 = _mm256_fmadd_ps(h,_mm256_fmadd_ps(b41,k1,
				                                      _mm256_fmadd_ps(b42,k2,
								                  _mm256_mul_ps(b43,k3)),y0));
				   k4 = f(x0,t0);
				   t2 = _mm256_fmadd_ps(g1,k1,
				                    _mm256_fmadd_ps(g2,k2,
						                _mm256_fmadd_ps(g3,k3,
								            _mm256_mul_ps(g4,k4))));
				   y0 = _mm256_fmadd_ps(h0,t2,y0);
			     }
			     return (y0);
		      }



		        __m256d
			rkr4_richardson_ymm4r8(__m256d(*f)(__m256d,
			                                     __m256d),
						 __m256d y0,
						 __m256d x0,
						 const __m256d h,
						 const int32_t n,
						 int32_t n_cols) {

			   __ATTR_ALIGN__(32) const __m256d richardson[] = {_mm256_set1_pd(1.0/15.0),
			                                                    _mm256_set1_pd(1.0/31.0),
								            _mm256_set1_pd(1.0/63.0),
								            _mm256_set1_pd(1.0/127.0),
								            _mm256_set1_pd(1.0/255.0),
									    _mm256_set1_pd(1.0/511.0)};
									    
			   constexpr int32_t MAX_COLS = 7;
			   __ATTR_ALIGN__(32) __m256d dt[MAX_COLS];
			   const __m256d _1_2 = _mm256_set1_pd(0.5);
			   __m256d integral,delta,h_used;
			   int32_t n_subints;
			   n_cols = max(1,min(MAX_COLS,n_cols));
			   while(--n >= 0) {
                                 h_used = h;
				 n_subints = 1;
				 #pragma loop_count min(1),max(6),avg(3)
				 for(int32_t j = 0; j < n_cols; ++j) {
                                     integral = rkr4_step_ymm4r8(f,y0,x0,h_used,n_subints);
				     for(int32_t k = 0; k < j; ++k) {
                                         delta = _mm256_sub_pd(integral,dt[k]);
					 dt[k] = integral;
					 integral = _mm256_fmadd_pd(richardson[k],delta,integral);
				     }
				     dt[j] = integral;
				     h_used = _mm256_mul_pd(h_used,_1_2);
				     n_subints += n_subints;
				 }
				 y0 = integral;
				 x0 = _mm256_add_pd(x0,h);
			   }
			   return (y0);
		    }


		        
			__m256
			rkr4_richardson_ymm8r4(__m256(*f)(__m256,
			                                     __m256),
						 __m256 y0,
						 __m256 x0,
						 const __m256 h,
						 const int32_t n,
						 int32_t n_cols) {

			   __ATTR_ALIGN__(32) const __m256 richardson[] = { _mm256_set1_ps(1.0f/15.0f),
			                                                    _mm256_set1_ps(1.0f/31.0f),
								            _mm256_set1_ps(1.0f/63.0f),
								            _mm256_set1_ps(1.0f/127.0f),
								            _mm256_set1_ps(1.0f/255.0f),
									    _mm256_set1_pd(1.0f/511.0f)};
									    
			   constexpr int32_t MAX_COLS = 7;
			   __ATTR_ALIGN__(32) __m256 dt[MAX_COLS];
			   const __m256 _1_2 = _mm256_set1_ps(0.5f);
			   __m256 integral,delta,h_used;
			   int32_t n_subints;
			   n_cols = max(1,min(MAX_COLS,n_cols));
			   while(--n >= 0) {
                                 h_used = h;
				 n_subints = 1;
				 #pragma loop_count min(1),max(6),avg(3)
				 for(int32_t j = 0; j < n_cols; ++j) {
                                     integral = rkr4_step_ymm8r4(f,y0,x0,h_used,n_subints);
				     for(int32_t k = 0; k < j; ++k) {
                                         delta = _mm256_sub_ps(integral,dt[k]);
					 dt[k] = integral;
					 integral = _mm256_fmadd_ps(richardson[k],delta,integral);
				     }
				     dt[j] = integral;
				     h_used = _mm256_mul_ps(h_used,_1_2);
				     n_subints += n_subints;
				 }
				 y0 = integral;
				 x0 = _mm256_add_ps(x0,h);
			   }
			   return (y0);
		    }

