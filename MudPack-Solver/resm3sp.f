c
c     file resm3sp.f
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
c     subroutine resm3sp(nx,ny,nz,nxa,nxb,nyc,nyd,nze,nzf,work,res)
c
c
c ... purpose
c
c
c     subroutine resm3sp computes the fine grid residual in the nx by ny by nz
c     array res after calling mud3sp.  if
c
c          l * p = f
c
c     is the n by n (n = nx*ny*nz) block tri-diagonal linear system resulting
c     from the pde discretization (done internally in mud3sp) and phi is the
c     approximation to p obtained by calling mud3sp, then resm3sp computes
c     the nx by ny by nz residual array
c
c          res = f - l * phi.
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
c          l * e(n) = r(n).
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
c ... assumptions (see mud3sp documentation)
c
c     (1) nx,ny,nz have the same values as iparm(14),iparm(15),iparm(16)
c         (used to set the fine grid resolution when calling mud3sp)
c
c     (2) nxa,nxb,nyc,nyd,nze,nzf have the same values as iparm(2),
c         iparm(3),iparm(4),iparm(5),iparm(6),iparm(7) (used to flag
c         boundary conditions when calling mud3sp).
c
c     (3) work,phi are the same parameters used in calling mud3sp.
c
c     (4) work,phi have not changed since the last call to mud3sp.
c
c     (3) assures a copy of the last approximation phi is contained in work.
c     if (1)-(4) are not true then resm3sp cannot compute the residual.
c
      subroutine resm3sp(nx,ny,nz,nxa,nxb,nyc,nyd,nze,nzf,wk,res)
       !dir$ attributes forceinline :: resm3sp
       !dir$ attributes code_align : 32 :: resm3sp
       !dir$ optimize : 3
      implicit none
      integer nx,ny,nz,nxa,nxb,nyc,nyd,nze,nzf,ir,ix,iy,iz
      real wk(*),res(*)
c
c     set pointers
c
      ir = 1+(nx+2)*(ny+2)*(nz+2)
      ix = ir+nx*ny*nz
      iy = ix+3*nx
      iz = iy+3*ny
      call rem3sp(nx,ny,nz,nxa,nxb,nyc,nyd,nze,nzf,wk,wk(ir),wk(ix),
     +            wk(iy),wk(iz),res)
      return
      end

      subroutine rem3sp(nx,ny,nz,nxa,nxb,nyc,nyd,nze,nzf,phi,
     +                  rhs,cofx,cofy,cofz,resf)
       !dir$ attributes forceinline :: rem3sp
       !dir$ attributes code_align : 32 :: rem3sp
       !dir$ optimize : 3
       !dir$ attributes optimization_parameter: "TARGET_ARCH=skylake_avx512" :: rem3sp
       use omp_lib
      implicit none
      integer nx,ny,nz,nxa,nxb,nyc,nyd,nze,nzf
      integer i,j,k,ist,ifn,jst,jfn,kst,kfn
      real cofx(nx,3),cofy(ny,3),cofz(nz,3)
      real rhs(nx,ny,nz),phi(0:nx+1,0:ny+1,0:nz+1),resf(nx,ny,nz)
c
c     intialize residual to zero and set loop limits
c
!$omp  parallel default(none) private(k,j,i,ist,ifn,jst,jfn,kst,kfn) &
!$omp& shared(nz,ny,nx,nxa,nxb,nyc,nyd,bze,nzf,resf,rhs,cofx,cofy,cofz,phi)
!$omp  do schedule(static,8)
      do k=1,nz
	do j=1,ny
          !dir$ assume_aligned resf:64
          !dir$ vector aligned
          !dir$ vector always
          !dir$ vector nontemporal(resf)
          !dir$ unroll(16)
	  do i=1,nx
	    resf(i,j,k) = 0.0
	  end do
	end do
      end do
!$omp end do
      ist = 1
      if (nxa.eq.1) ist = 2
      ifn = nx
      if (nxb.eq.1) ifn = nx-1
      jst = 1
      if (nyc.eq.1) jst = 2
      jfn = ny
      if (nyd.eq.1) jfn = ny-1
      kst = 1
      if (nze.eq.1) kst = 2
      kfn = nz
      if (nzf.eq.1) kfn = nz-1
c
c     compute residual
c
!$omp do schedule(static,8)
      do k=kst,kfn
	do j=jst,jfn
          !dir$ assume_aligned resf:64
          !dir$ assume_aligned rhs:64
          !dir$ assume_aligned cofx:64
          !dir$ assume_aligned cofy:64
          !dir$ assume_aligned cofz:64
          !dir$ assume_aligned phi:64
          !dir$ ivdep
          !dir$ vector aligned
          !dir$ vector always
	  do i=ist,ifn
	    resf(i,j,k) =  rhs(i,j,k)-(
     +      cofx(i,1)*phi(i-1,j,k)+cofx(i,2)*phi(i+1,j,k) +
     +      cofy(j,1)*phi(i,j-1,k)+cofy(j,2)*phi(i,j+1,k) +
     +      cofz(k,1)*phi(i,j,k-1)+cofz(k,2)*phi(i,j,k+1) +
     +      (cofx(i,3)+cofy(j,3)+cofz(k,3))*phi(i,j,k)  )
	  end do
	end do
      end do
!$omp end do
!$omp end parallel
      return
      end
