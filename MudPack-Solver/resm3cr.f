c
c     file resm3cr.f
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
c     subroutine resm3cr(nx,ny,nz,icros,work,res)
c
c ... purpose
c
c
c     subroutine resm3cr computes the fine grid residual in the nx by ny by nz
c     array res after calling mud3cr.  if
c
c          L * p = f
c
c     is the n by n (n = nx*ny*nz) block tri-diagonal linear system resulting
c     from the pde discretization (done internally in mud3cr) and phi
c     is the approximation to p obtained by calling mud3cr, then resm3cr computes
c     the nx by ny by nz residual array
c
c          res = f - L * phi.
c
c     one of the vector norms of res,
c
c          || res ||
c
c     can be computed as a "measure" of how well phi satisfies the
c     discretization equations.  for example, the following statements
c     will compute the location and size of the maximum residual in res
c     on cray computers:
c
c          ijk = isamax(nx*ny*nz,res,1)
c
c          kmax = (ijk-1)/(nx*ny) + 1
c
c          jmax = (ijk-(kmax-1)*nx*ny-1)/nx + 1
c
c          imax = ij - nx*((kmax-1)*ny-jmax+1)
c
c          resmax = abs(res(imax,jmax,kmax))
c
c ... see documentation and test files provided in this distribution
c
c ... notes
c
c     let pe be the exact continuous solution to the elliptic pde
c     evaluated on the nx by ny by nz discretization grid;
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
c ... assumptions (see mud3 or mud3sa documentation)
c
c     (1) nx,ny,nz have the same values as iparm(14),iparm(15),iparm(16)
c         (used to set the fine grid resolution when calling mud3cr
c
c     (2) icros,work,phi are the same arguments used in calling mud3cr
c
c     (3) icros,work,phi have not changed since the last call to mud3cr
c
c     (3) assures a copy of the last approximation phi and the discretization
c     coefficients are contained in work.  If these assumptions are not
c     true then resm3cr cannot compute the residual in res.
c
      subroutine resm3cr(nx,ny,nz,icros,wk,res)
        !dir$ attributes forceinline :: resm3cr
       !dir$ attributes code_align : 32 :: resm3cr
       !dir$ optimize : 3
c
c     compute fine grid residual in res after calling mud3cr
c
      implicit none
      integer nx,ny,nz,ic,ir,ixy,ixz,iyz,kxy,kxz,kyz
      integer icros(3)
      real wk(*),res(nx,ny,nz)
c
c     set fine grid pointers for wk
c
      kxy = icros(1)
      kxz = icros(2)
      kyz = icros(3)
      ic = 1+(nx+2)*(ny+2)*(nz+2)
      ir = ic+7*nx*ny*nz
      ixy = ir + nx*ny*nz
      ixz = ixy + kxy*nx*ny*nz
      iyz = ixz + kxz*nx*ny*nz
      call rem3cr(nx,ny,nz,wk,wk(ir),wk(ic),wk(ixy),wk(ixz),wk(iyz),
     +            kxy,kxz,kyz,res)
      return
      end

      subroutine rem3cr(nx,ny,nz,phi,rhs,cof,coxy,coxz,coyz,
     +                  kxy,kxz,kyz,resf)
       !dir$ attributes forceinline :: rem3cr
       !dir$ attributes code_align : 32 :: rem3cr
       !dir$ optimize : 3
       !dir$ attributes optimization_parameter: "TARGET_ARCH=skylake_avx512" :: rem3cr
      use omp_lib
      implicit none
      integer nx,ny,nz,i,j,k,kxy,kxz,kyz
      real phi(0:nx+1,0:ny+1,0:nz+1),rhs(nx,ny,nz),resf(nx,ny,nz)
      real cof(nx,ny,nz,7),coxy(nx,ny,nz),coxz(nx,ny,nz),coyz(nx,ny,nz)
!$omp parallel default(none) private(k,j,i)   &
!$omp& shared(nz,ny,nx,resf,rhs,phi,coxy,kxy,kxz,coxz,kyz,coyz)
!$omp do schedule(static,8)
      do k=1,nz
	do j=1,ny
          !dir$ assume_aligned rhs:64
          !dir$ assume_aligned cof:64
          !dir$ assume_aligned phi:64
          !dir$ ivdep
          !dir$ vector aligned
          !dir$ vector always
	  do i=1,nx
	    resf(i,j,k) =  rhs(i,j,k)-(
     +                     cof(i,j,k,1)*phi(i-1,j,k)+
     +                     cof(i,j,k,2)*phi(i+1,j,k)+
     +                     cof(i,j,k,3)*phi(i,j-1,k)+
     +                     cof(i,j,k,4)*phi(i,j+1,k)+
     +                     cof(i,j,k,5)*phi(i,j,k-1)+
     +                     cof(i,j,k,6)*phi(i,j,k+1)+
     +                     cof(i,j,k,7)*phi(i,j,k))
	  end do
	end do
      end do
!$omp end do
c
c   adjust residual with cross coefs as necessary on interior
c
      if (kxy .eq. 1) then
!$omp do schedule(static,8)
	do k=2,nz-1
	  do j=2,ny-1
          !dir$ assume_aligned rhs:64
          !dir$ assume_aligned coxy:64
          !dir$ assume_aligned phi:64
          !dir$ ivdep
          !dir$ vector aligned
          !dir$ vector always
	    do i=2,nx-1
	    resf(i,j,k) =  resf(i,j,k) - coxy(i,j,k)*(
     +                     phi(i+1,j+1,k)+phi(i-1,j-1,k) -(
     +                     phi(i+1,j-1,k)+phi(i-1,j+1,k)))
	    end do
	  end do
	end do
!$omp end do
      end if
      if (kxz .eq. 1) then
!$omp do schedule(static,8)
	do k=2,nz-1
	  do j=2,ny-1
           !dir$ assume_aligned rhs:64
          !dir$ assume_aligned coxz:64
          !dir$ assume_aligned phi:64
          !dir$ ivdep
          !dir$ vector aligned
          !dir$ vector always
	    do i=2,nx-1
	    resf(i,j,k) =  resf(i,j,k) - coxz(i,j,k)*(
     +                     phi(i+1,j,k+1)+phi(i-1,j,k-1) -(
     +                     phi(i+1,j,k-1)+phi(i-1,j,k+1)))
	    end do
	  end do
	end do
!$omp end do
      end if
      if (kyz .eq. 1) then
!$omp do schedule(static,8)
	do k=2,nz-1
	  do j=2,ny-1
          !dir$ assume_aligned rhs:64
          !dir$ assume_aligned coyz:64
          !dir$ assume_aligned phi:64
          !dir$ ivdep
          !dir$ vector aligned
          !dir$ vector always
	    do i=2,nx-1
	    resf(i,j,k) =  resf(i,j,k) - coyz(i,j,k)*(
     +                     phi(i,j+1,k+1)+phi(i,j-1,k-1) - (
     +                     phi(i,j+1,k-1)+phi(i,j-1,k+1)))
	    end do
	  end do
	end do
!$omp end do
      end if
!$omp end parallel
      return
      end
