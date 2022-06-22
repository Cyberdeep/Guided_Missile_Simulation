c
c     file resm2.f
c
c     * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
c     *                                                               *
c     *                  copyright (c) 2008 by UCAR                   *
c     *                                                               *
c     *       University Corporation for Atmospheric Research         *
c     *                                                               *
c     *                      all rights reserved                      *
c     *                                                               *
c     *                     MUDPACK  version 5.0.1                    *
c     *                                                               *
c     *                 A Fortran Package of Multigrid                *
c     *                                                               *
c     *                Subroutines and Example Programs               *
c     *                                                               *
c     *      for Solving Elliptic Partial Differential Equations      *
c     *                                                               *
c     *                             by                                *
c     *                                                               *
c     *                         John Adams                            *
c     *                                                               *
c     *                             of                                *
c     *                                                               *
c     *         the National Center for Atmospheric Research          *
c     *                                                               *
c     *                Boulder, Colorado  (80307)  U.S.A.             *
c     *                                                               *
c     *                   which is sponsored by                       *
c     *                                                               *
c     *              the National Science Foundation                  *
c     *                                                               *
c     * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
c
c     subroutine resm2(nx,ny,work,res)
c
c
c ... purpose
c
c
c     subroutine resm2 computes the fine grid residual in the nx by ny array
c     res after calling mud2 or muh2 or mud2sa.  if
c
c          L * p = f
c
c     is the n by n (n = nx*ny) block tri-diagonal linear system resulting
c     from the pde discretization (done internally in the mudpack solver)
c     then resm2 computes the nx by ny residual array
c
c          res = f - L * p
c
c     one of the vector norms of res,
c
c          || res ||
c
c     can be computed as a "measure" of how well the approximation satisfies
c     the discretization equations.  for example, the following statements
c     will compute the location and size of the maximum residual in res
c     on cray computers:
c
c          ij = isamax(nx*ny,res,1)
c
c          jmax = (ij-1)/nx + 1
c
c          imax = ij - (jmax-1)*nx
c
c          resmax = abs(res(imax,jmax))
c
c ... see documentation and test files provided in this distribution
c
c ... notes
c
c     let pe be the exact continuous solution to the elliptic pde
c     evaluated on the nx by ny discretization grid;
c
c     let p be the exact solution to the linear discretization;
c
c     let phi be the approximation to p generated by the mudpack solver;
c
c     then discretization level error is defined by the condition
c
c          || phi - p || < || p - pe ||.
c                        =
c
c     a common measure of multigrid efficieny is that discretization level
c     error is reached in one full multigrid cycle (see references [2,9] in
c     the mudpack file "readme").  this can happen before the residual is
c     reduced to the level of roundoff error.  consequently, || res || is
c     a conservative measure of accuracy which can be wasteful if multi-
c     grid cycles are executed until it reaches the level of roundoff error.
c
c     || res || can be used to estimate the convergence rate of multigrid
c     iteration.  let r(n) be the residual and e(n) be the error after
c     executing n cycles.  they are related by the residual equation
c
c          L * e(n) = r(n).
c
c     it follows that the ratio
c
c          || r(n+1) || / || r(n) ||
c
c     estimates
c
c          || e(n+1) || / || e(n) ||
c
c     which in turn estimates the convergence rate
c
c          c = max || e(k+1) || / || e(k) ||.
c               k
c
c     notice
c                         n
c          || e(n) || <  c  || e(0) ||.
c
c
c ... assumptions (see mud2 or muh2d or mud2sa documentation)
c
c     (1) nx,ny have the same values as iparm(10),iparm(11) (used
c         to set the fine grid resolution)
c
c     (2) work is the same argument used in calling the solver.
c
c     (3) work have not changed since the last call to the solver.
c
c     (3) assures a copy of the last approximation phi is contained in work.
c     if these assumptions are not true then resm2 cannot compute the
c     residual in res.
c
      subroutine resm2(nx,ny,work,res)
       !dir$ attributes forceinline :: resm2
       !dir$ attributes code_align : 32 :: resm2
       !dir$ optimize : 3
      implicit none
      integer nx,ny,ic
      real work(*),res(nx,ny)
c
c     set approximation and coefficient pointers
c
      ic = 1+(nx+2)*(ny+2)
      call rem2(nx,ny,work,work(ic),res)
      return
      end

      subroutine rem2(nx,ny,phi,cof,res)
       !dir$ attributes forceinline :: rem2
       !dir$ attributes code_align : 32 :: rem2
       !dir$ optimize : 3
       !dir$ attributes optimization_parameter: "TARGET_ARCH=skylake_avx512" :: rem2
      implicit none
      integer nx,ny,i,j
      real phi(0:nx+1,0:ny+1),cof(nx,ny,6),res(nx,ny)
c
c     compute residual over entire x,y grid
c
      !dir$ assume_aligned res:64
      !dir$ assume_aligned cof:64
      !dir$ assume_aligned phi:64
      do j=1,ny
        !dir$ ivdep
        !dir$ vector aligned
        !dir$ vector always
	do i=1,nx
	  res(i,j) =  cof(i,j,6)-(
     +                cof(i,j,1)*phi(i-1,j)+
     +                cof(i,j,2)*phi(i+1,j)+
     +                cof(i,j,3)*phi(i,j-1)+
     +                cof(i,j,4)*phi(i,j+1)+
     +                cof(i,j,5)*phi(i,j))
	end do
      end do
      return
      end
