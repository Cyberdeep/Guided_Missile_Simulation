

module eos_sensor


!======================================================!
! Various characteristics of Electro-Optical Systems   !
! Based mainly on Miroshenko M.M book (rus):           !
! "Mathematical Theory of Electro-Optical Sensors"     !
!======================================================!
!===================================================================================85
 !---------------------------- DESCRIPTION ------------------------------------------85
 !
 !
 !
 !          Module  name:
 !                         eos_sensor
 !          
 !          Purpose:
 !                        Various characteristics of Electro-Optical Sensors   
 !                        Based mainly on Based mainly on Miroshenko M.M book (rus):          
 !                        "Mathematical Theory of Electro-Optical Sensors".
 !          History:
 !                        Date: 09-08-2022
 !                        Time: 09:44 GMT+2
 !                        
 !          Version:
 !
 !                      Major: 1
 !                      Minor: 0
 !                      Micro: 0
 !
 !          Author:  
 !                      Bernard Gingold
 !          
 !                 
 !          References:
 !         
 !                       Miroshenko M.M book (rus):          
 !                      "Mathematical Theory of Electro-Optical Sensors"     
 !         
 !          E-mail:
 !                  
 !                      beniekg@gmail.com
!==================================================================================85
    ! Tab:5 col - Type and etc.. definitions
    ! Tab:10,11 col - Type , function and subroutine code blocks.
   
   use mod_kinds,    only : i4,sp,dp
   !use mod_vectypes, only : YMM8r4_t, YMM4r8_t, ZMM16r4_t, ZMM8r8_t
   public
   implicit none

     ! Major version
     integer(kind=i4),  parameter :: EOS_SENSOR_MAJOR = 1
     ! Minor version
     integer(kind=i4),  parameter :: EOS_SENSOR_MINOR = 0
     ! Micro version
     integer(kind=i4),  parameter :: EOS_SENSOR_MICRO = 0
     ! Full version
     integer(kind=i4),  parameter :: EOS_SENSOR_FULLVER =   &
            1000*EOS_SENSOR_MAJOR+100*EOS_SENSOR_MINOR+10*EOS_SENSOR_MICRO
     ! Module creation date
     character(*),        parameter :: EOS_SENSOR_CREATE_DATE = "09-08-2022 09:44 +00200 (TUE 09 AUG 2022 GMT+2)"
     ! Module build date
     character(*),        parameter :: EOS_SENSOR_BUILD_DATE  = __DATE__ " " __TIME__
     ! Module author info
     character(*),        parameter :: EOS_SENSOR_AUTHOR      = "Programmer: Bernard Gingold, contact: beniekg@gmail.com"
     ! Short description
     character(*),        parameter :: EOS_SENSOR_SYNOPSIS    = "EO Sensors characteristics and models."


     ! Scanning mirror derived type
     
     type, public :: scanning_mirror

           sequence
           real(kind=sp) :: gamma ! angle of mirror position relative to obiective optical axis (p. 53, 1.2)
           real(kind=sp) :: gamma0 ! angle of fixing
           real(kind=sp) :: phi   ! sensor fov
           real(kind=sp) :: F     ! Focal length
           real(kind=sp) :: H     ! distance from the focal length to target image
           real(kind=sp) :: Dmax  ! size of mirror vertical plane
           real(kind=sp) :: Dmin  ! size of mirror horizontal plane
           
     end type scanning_mirror


     contains

     
     subroutine param_gamma_r4(sm)
        !dir$ optimize:3
        !dir$ attributes code_align : 32 :: param_gamma_r4
        !dir$ attributes forceinline :: param_gamma_r4
        type(scanning_mirror), intent(inout) :: sm
        sm.gamma = 0.5_sp*sm.phi*0.5_sp
     end subroutine param_gamma_r4

     ! Formula 1, p.54
     !Тогда длина перпендикуляра SN, опущенного из 
     !светящейся точки на плоскость зеркала
     pure elemental function compute_SN_r4(R,phi,gamma) result(SN)
        !dir$ optimize:3
        !dir$ attributes code_align : 32 :: compute_SN_r4
        !dir$ attributes forceinline :: compute_SN_r4
        real(kind=sp),  intent(in) :: R
        real(kind=sp),  intent(in), optional :: phi
        real(kind=sp),  intent(in), optional :: gamma
        real(kind=sp) :: SN
        if(present(phi)) then
            SN = R*sin(phi)
        else if(present(gamma)) then
            SN = R*cos(gamma)
        end if
     end function compute_SN_r4


     pure elemental function compute_SN_r8(R,phi,gamma) result(SN)
        !dir$ optimize:3
        !dir$ attributes code_align : 32 :: compute_SN_r8
        !dir$ attributes forceinline :: compute_SN_r8
        real(kind=dp),  intent(in) :: R
        real(kind=dp),  intent(in), optional :: phi
        real(kind=dp),  intent(in), optional :: gamma
        real(kind=dp) :: SN
        if(present(phi)) then
            SN = R*sin(phi)
        else if(present(gamma)) then
            SN = R*cos(gamma)
        end if
     end function compute_SN_r8


   

     ! Formula 2, p. 54
     ! расстояние SM от светящейся точки до ее изображения
     pure elemental function compute_SM_r4(R,phi,gamma) result(SM)
        !dir$ optimize:3
        !dir$ attributes code_align : 32 :: compute_SM_r4
        !dir$ attributes forceinline :: compute_SM_r4
        real(kind=sp), intent(in) :: R
        real(kind=sp), intent(in) :: phi
        real(kind=sp), intent(in) :: gamma
        real(kind=sp) :: SM
        SM = 2.0_sp*compute_SN_r4(R,phi,gamma)
     end function compute_SM_r4
 

     pure elemental function compute_SM_r8(R,phi,gamma) result(SM)
        !dir$ optimize:3
        !dir$ attributes code_align : 32 :: compute_SM_r8
        !dir$ attributes forceinline :: compute_SM_r8
        real(kind=dp), intent(in) :: R
        real(kind=dp), intent(in) :: phi
        real(kind=dp), intent(in) :: gamma
        real(kind=dp) :: SM
        SM = 2.0_sp*compute_SN_r8(R,phi,gamma)
     end function compute_SM_r8

     
   


     !Сканирующее зеркало для обеспечения осмотра всего поля
     !обзора ф необходимо повернуть на угол, обеспечивающий 
     !совмещение края изображения источника излучения с отверстием 
     !диафрагмы а, находящимся в центре поля. Для этого необходимо 
     !повернуть изображение светящейся точки S на угол ф/2
     ! Formula 1, p. 56
     pure elemental function ratio_FH_r4(psi,phi) result(FH)
        !dir$ optimize:3
        !dir$ attributes code_align : 32 :: ratio_FH_r4
        !dir$ attributes forceinline :: ratio_FH_r4
        real(kind=sp),  intent(in) :: psi
        real(kind=sp),  intent(in) :: phi
        real(kind=sp) :: FH
        real(kind=sp), automatic :: hpsi,hphi
        hpsi = 0.5_sp*psi
        hphi = 0.5_sp*phi
        FH   = tan(hpsi)/tan(hphi)
     end function ratio_FH_r4


     pure elemental function ratio_FH_r8(psi,phi) result(FH)
        !dir$ optimize:3
        !dir$ attributes code_align : 32 :: ratio_FH_r8
        !dir$ attributes forceinline :: ratio_FH_r8
        real(kind=dp),  intent(in) :: psi
        real(kind=dp),  intent(in) :: phi
        real(kind=dp) :: FH
        real(kind=dp), automatic :: hpsi,hphi
        hpsi = 0.5_dp*psi
        hphi = 0.5_dp*phi
        FH   = tan(hpsi)/tan(hphi)
     end function ratio_FH_r8


   


     ! следовательно, угол установки сканирующего зеркала
     ! Formula 4, p. 56
     pure elemental function scan_mirror_ang_r4(gam0,psi,phi,dir) result(gamma)
        !dir$ optimize:3
        !dir$ attributes code_align : 32 :: scan_mirror_ang_r4
        !dir$ attributes forceinline :: scan_mirror_ang_r4
        real(kind=sp),  intent(in) :: gam0
        real(kind=sp),  intent(in) :: psi
        real(kind=sp),  intent(in) :: phi
        character(len=3), intent(in) :: dir
        real(kind=sp) :: gamma
        real(kind=sp), automatic :: t0
        if(dir=="pos") then
           t0 = gam0+0.5_sp*phi*0.5_sp
           gamma = t0*ratio_FH_r4(psi,phi) 
        else if(dir=="neg") then
           t0 = gam0-0.5_sp*phi*0.5_sp
           gamma = t0*ratio_FH_r4(psi,phi)
        end if
     end function scan_mirror_ang_r4


     pure elemental function scan_mirror_ang_r8(gam0,psi,phi,dir) result(gamma)
        !dir$ optimize:3
        !dir$ attributes code_align : 32 :: scan_mirror_ang_r8
        !dir$ attributes forceinline :: scan_mirror_ang_r8
        real(kind=dp),  intent(in) :: gam0
        real(kind=dp),  intent(in) :: psi
        real(kind=dp),  intent(in) :: phi
        character(len=3), intent(in) :: dir
        real(kind=dp) :: gamma
        real(kind=dp), automatic :: t0
        if(dir=="pos") then
           t0 = gam0+0.5_dp*phi*0.5_dp
           gamma = t0*ratio_FH_r8(psi,phi) 
        else if(dir=="neg") then
           t0 = gam0-0.5_dp*phi*0.5_dp
           gamma = t0*ratio_FH_r8(psi,phi)
        end if
     end function scan_mirror_ang_r8


    

     ! Maximum size of (verical) diameter of scanning mirror.
     ! Formula 2, page. 56, part: 1.3
     ! Anax = [h tg (6/2) + do6/2] [2 cos y' + sin yf {tg (у' + 6/2) +
     !+ tg(Y'-6/2)}].
     pure function compute_Dmax_r4(h,delta,d_ob,gamma) result(Dmax)
        !dir$ optimize:3
        !dir$ attributes code_align : 32 :: compute_Dmax_r4
        !dir$ attributes forceinline :: compute_Dmax_r4
        real(kind=sp),  intent(in) :: h
        real(kind=sp),  intent(in) :: delta
        real(kind=sp),  intent(in) :: d_ob
        real(kind=sp),  intent(in) :: gamma
        real(kind=sp) :: Dmax
        real(kind=sp), automatic :: delta2,d_ob2,cosg,sing,t0,t1,t2,tant0,tant1
        real(kind=sp), automatic :: t3,t4,t5
        delta2 = 0.5_sp*delta
        d_ob2  = 0.5_sp*d_ob
        cosg   = cos(gamma)
        if(delta<=gamma) then
           t0  = h*delta+d_ob
           Dmax= t0/cosg
        end if
        t0     = gamma+delta2
        t1     = gamma-delta2
        sing   = sin(gamma)
        tant1  = tan(t0)
        tant2  = tan(t1)
        t3     = h*tan(delta2)+d_ob2
        t4     = 2.0_sp*cosg+sing
        t5     = tant1+tant2
        Dmax   = t3*t4*t5
     end function compute_Dmax_r4


     pure function compute_Dmax_r8(h,delta,d_ob,gamma) result(Dmax)
        !dir$ optimize:3
        !dir$ attributes code_align : 32 :: compute_Dmax_r8
        !dir$ attributes forceinline :: compute_Dmax_r8
        real(kind=dp),  intent(in) :: h
        real(kind=dp),  intent(in) :: delta
        real(kind=dp),  intent(in) :: d_ob
        real(kind=dp),  intent(in) :: gamma
        real(kind=dp) :: Dmax
        real(kind=dp), automatic :: delta2,d_ob2,cosg,sing,t0,t1,t2,tant0,tant1
        real(kind=dp), automatic :: t3,t4,t5
        delta2 = 0.5_dp*delta
        d_ob2  = 0.5_dp*d_ob
        cosg   = cos(gamma)
        if(delta<=gamma) then
           t0  = h*delta+d_ob
           Dmax= t0/cosg
        end if 
        t0     = gamma+delta2
        t1     = gamma-delta2
        sing   = sin(gamma)
        tant1  = tan(t0)
        tant2  = tan(t1)
        t3     = h*tan(delta2)+d_ob2
        t4     = 2.0_dp*cosg+sing
        t5     = tant1+tant2
        Dmax   = t3*t4*t5
     end function compute_Dmax_r8


     ! Размер зеркала в направлении, перпендикулярном плоскости
     ! чертежа, приблизительно равен
     ! Formula 2, p. 58
     pure function compute_Dmin_r4(h,delta,d_ob) result(Dmin)
          !dir$ optimize:3
          !dir$ attributes code_align : 32 :: compute_Dmin_r4
          !dir$ attributes forceinline :: compute_Dmin_r4
          real(kind=sp),  intent(in) :: h
          real(kind=sp),  intent(in) :: delta
          real(kind=sp),  intent(in) :: d_ob
          real(kind=sp) :: Dmin
          Dmin = h*delta+d_ob
     end function compute_Dmin_r4


     pure function compute_Dmin_r8(h,delta,d_ob) result(Dmin)
          !dir$ optimize:3
          !dir$ attributes code_align : 32 :: compute_Dmin_r8
          !dir$ attributes forceinline :: compute_Dmin_r8
          real(kind=dp),  intent(in) :: h
          real(kind=dp),  intent(in) :: delta
          real(kind=dp),  intent(in) :: d_ob
          real(kind=dp) :: Dmin
          Dmin = h*delta+d_ob
     end function compute_Dmin_r8


     !Если зеркало осуществляет сканирование в пространстве
     !изображений его размеры
     ! Formula 7, p. 58
     pure function Dmax_imag_scan_r4(H,F,B,d_ob,gamma, &
                                     psi,phi,d) result(Dmax)
          !dir$ optimize:3
          !dir$ attributes code_align : 32 :: Dmax_imag_scan_r4
          !dir$ attributes forceinline :: Dmax_imag_scan_r4
          real(kind=sp),  intent(in) :: H
          real(kind=sp),  intent(in) :: F
          real(kind=sp),  intent(in) :: B
          real(kind=sp),  intent(in) :: d_ob
          real(kind=sp),  intent(in) :: gamma
          real(kind=sp),  intent(in) :: psi
          real(kind=sp),  intent(in) :: phi
          real(kind=sp),  intent(in) :: d
          real(kind=sp) :: Dmax
          real(kind=sp), automatic :: t0,t1,t2,t3
          real(kind=sp), automatic :: cosg,sing,tanp1,tanp2,psi2,phi2
          psi2  = 0.5_sp*psi
          if(psi2<=gamma .and. &
             B<=d) then
             phi2 = 0.5_sp*phi
             t0   = (F+F)*tan(phi2)
             t1   = (H/F)*d_ob
             t2   = sin(gamma)
             Dmax = (t0+t1)*t2
          end if
          t0    = (H/F)*(d_ob-B)+B
          cosg  = cos(gamma)
          tanp1 = gamma+psi2
          tanp2 = gamma-psi2
          sing  = sin(gamma)
          t1    = 2.0_sp*cosg+sing
          t2    = tan(tanp1)+tan(tanp2)
          t3    = 0.5_sp*t1*t2
          Dmax  = t0*t3
     end function Dmax_imag_scan_r4


     pure function Dmax_imag_scan_r8(H,F,B,d_ob,gamma, &
                                     psi,phi,d) result(Dmax)
          !dir$ optimize:3
          !dir$ attributes code_align : 32 :: Dmax_imag_scan_r8
          !dir$ attributes forceinline :: Dmax_imag_scan_r8
          real(kind=dp),  intent(in) :: H
          real(kind=dp),  intent(in) :: F
          real(kind=dp),  intent(in) :: B
          real(kind=dp),  intent(in) :: d_ob
          real(kind=dp),  intent(in) :: gamma
          real(kind=dp),  intent(in) :: psi
          real(kind=dp),  intent(in) :: phi
          real(kind=dp),  intent(in) :: d
          real(kind=dp) :: Dmax
          real(kind=dp), automatic :: t0,t1,t2,t3
          real(kind=dp), automatic :: cosg,sing,tanp1,tanp2,psi2,phi2
          psi2  = 0.5_dp*psi
          if(psi2<=gamma .and. &
             B<=d) then
             phi2 = 0.5_dp*phi
             t0   = (F+F)*tan(phi2)
             t1   = (H/F)*d_ob
             t2   = sin(gamma)
             Dmax = (t0+t1)*t2
          end if
          t0    = (H/F)*(d_ob-B)+B
          cosg  = cos(gamma)
          tanp1 = gamma+psi2
          tanp2 = gamma-psi2
          sing  = sin(gamma)
          t1    = 2.0_dp*cosg+sing
          t2    = tan(tanp1)+tan(tanp2)
          t3    = 0.5_dp*t1*t2
          Dmax  = t0*t3
     end function Dmax_imag_scan_r8


     pure function Dmin_imag_scan_r4(H,F,d_ob,B) result(Dmin)
          !dir$ optimize:3
          !dir$ attributes code_align : 32 :: Dmin_imag_scan_r4
          !dir$ attributes forceinline :: Dmin_imag_scan_r4
          real(kind=sp),     intent(in) :: H
          real(kind=sp),     intent(in) :: F
          real(kind=sp),     intent(in) :: d_ob
          real(kind=sp),     intent(in) :: B
          real(kind=sp) :: Dmin
          real(kind=sp), automatic :: t0,t1
          t0   = H/F
          t1   = (d_ob-B)+B
          Dmin = t0*t1 
     end function Dmin_imag_scan_r4


     pure function Dmin_imag_scan_r8(H,F,d_ob,B) result(Dmin)
          !dir$ optimize:3
          !dir$ attributes code_align : 32 :: Dmin_imag_scan_r8
          !dir$ attributes forceinline :: Dmin_imag_scan_r8
          real(kind=dp),     intent(in) :: H
          real(kind=dp),     intent(in) :: F
          real(kind=dp),     intent(in) :: d_ob
          real(kind=dp),     intent(in) :: B
          real(kind=dp) :: Dmin
          real(kind=dp), automatic :: t0,t1
          t0   = H/F
          t1   = (d_ob-B)+B
          Dmin = t0*t1 
     end function Dmin_imag_scan_r8


    !величина расфокусировки
    !Formula 1, p. 59
    pure elemental function defocus_cof_r4(l2,alpha,O,inf) result(dc)
          !dir$ optimize:3
          !dir$ attributes code_align : 32 :: defocus_cof_r4
          !dir$ attributes forceinline :: defocus_cof_r4
          real(kind=sp),    intent(in) :: l2
          real(kind=sp),    intent(in) :: alpha
          real(kind=sp),    intent(in) :: O
          logical(kind=i4), intent(in) :: inf
          real(kind=sp) :: df
          real(kind=sp), automatic :: cos2a,icos
          cos2a = cos(alpha+alpha)
          icos  = 1.0_sp/cos2a
          if(inf) then
             df    = l2/(icos-1.0_sp)*O
          else
             df    = l2/(icos-1.0_sp)
          end if
    end function defocus_cof_r4


    pure elemental function defocus_cof_r8(l2,alpha,O,inf) result(dc)
          !dir$ optimize:3
          !dir$ attributes code_align : 32 :: defocus_cof_r8
          !dir$ attributes forceinline :: defocus_cof_r8
          real(kind=dp),    intent(in) :: l2
          real(kind=dp),    intent(in) :: alpha
          real(kind=dp),    intent(in) :: O
          logical(kind=i4), intent(in) :: inf
          real(kind=dp) :: df
          real(kind=dp), automatic :: cos2a,icos
          cos2a = cos(alpha+alpha)
          icos  = 1.0_dp/cos2a
          if(inf) then
             df    = l2/(icos-1.0_dp)*O
          else
             df    = l2/(icos-1.0_dp)
          end if
    end function defocus_cof_r8


   

    ! Диаметр кружка рассеяния р
    ! Formula 3, p.59
    pure elemental function circle_dispersion_r4(d,l1,l2,alpha,O,inf) result(rho)
          !dir$ optimize:3
          !dir$ attributes code_align : 32 :: circle_dispersion_r4
          !dir$ attributes forceinline :: circle_dispersion_r4
          real(kind=sp),    intent(in) :: d
          real(kind=sp),    intent(in) :: l1
          real(kind=sp),    intent(in) :: l2
          real(kind=sp),    intent(in) :: alpha
          real(kind=sp),    intent(in) :: O
          logical(kind=i4), intent(in) :: inf
          real(kind=sp) :: rho
          real(kind=sp), automatic :: t0,t1
          t0  = d/(l1+l2)
          t1  = defocus_cof_r4(l2,alpha,O,inf)
          rho = t0*t1
    end function circle_dispersion_r4


    pure elemental function circle_dispersion_r8(d,l1,l2,alpha,O,inf) result(rho)
          !dir$ optimize:3
          !dir$ attributes code_align : 32 :: circle_dispersion_r8
          !dir$ attributes forceinline :: circle_dispersion_r8
          real(kind=dp),    intent(in) :: d
          real(kind=dp),    intent(in) :: l1
          real(kind=dp),    intent(in) :: l2
          real(kind=dp),    intent(in) :: alpha
          real(kind=dp),    intent(in) :: O
          logical(kind=i4), intent(in) :: inf
          real(kind=dp) :: rho
          real(kind=dp), automatic :: t0,t1
          t0  = d/(l1+l2)
          t1  = defocus_cof_r8(l2,alpha,O,inf)
          rho = t0*t1
    end function circle_dispersion_r8


  

      
     !Formula 2, p. 59
     pure elemental function circ_dispers_diam_r4(l1,l2,alpha,O,inf) result(ratio)
         !dir$ optimize:3
         !dir$ attributes code_align : 32 :: circ_dispers_diam_r4
         !dir$ attributes forceinline :: circ_dispers_diam_r4
         real(kind=sp),    intent(in) :: l1
         real(kind=sp),    intent(in) :: l2
         real(kind=sp),    intent(in) :: alpha
         real(kind=sp),    intent(in) :: O
         logical(kind=i4), intent(in) :: inf
         real(kind=sp) :: ratio
         real(kind=sp), automatic :: t0,t1
         t0    = l1+l2
         t1    = defocus_cos_r4(l2,alpha,O,inf)
         ratio = t1/t0
     end function circ_dispers_diam_r4


     pure elemental function circ_dispers_diam_r4(l1,l2,alpha,O,inf) result(ratio)
         !dir$ optimize:3
         !dir$ attributes code_align : 32 :: circ_dispers_diam_r8
         !dir$ attributes forceinline :: circ_dispers_diam_r8
         real(kind=dp),    intent(in) :: l1
         real(kind=dp),    intent(in) :: l2
         real(kind=dp),    intent(in) :: alpha
         real(kind=dp),    intent(in) :: O
         logical(kind=i4), intent(in) :: inf
         real(kind=dp) :: ratio
         real(kind=dp), automatic :: t0,t1
         t0    = l1+l2
         t1    = defocus_cos_r4(l2,alpha,O,inf)
         ratio = t1/t0
     end function circ_dispers_diam_r4


    
      
       
     pure elemental function defocus_small_ang_r4(O,l2,alpha) result(rho)
         !dir$ optimize:3
         !dir$ attributes code_align : 32 :: defocus_small_ang_r4
         !dir$ attributes forceinline :: defocus_small_ang_r4
         use mod_fpcompare, only : Compare_Float
         real(kind=sp),   intent(in) :: O
         real(kind=sp),   intent(in) :: L2
         real(kind=sp),   intent(in) :: alpha
         real(kind=sp) :: rho
         real(kind=sp), automatic :: t0,t1,t2,alpha2
         alpha2 = alpha+alpha
         t0     = cos(alpha2)
         t1     = 1.0_sp-alpha2*alpha2*0.5_sp
         if(Compare_FLoat(t0,t1)) then
            t2  = l2*0.5_sp
            rho = O*t2*alpha2*alpha2
         end if
         rho = tiny(1.0_sp)
      end function defocus_small_ang_r4


      pure elemental function defocus_small_ang_r8(O,l2,alpha) result(rho)
         !dir$ optimize:3
         !dir$ attributes code_align : 32 :: defocus_small_ang_r8
         !dir$ attributes forceinline :: defocus_small_ang_r8
         use mod_fpcompare, only : Compare_Float
         real(kind=dp),   intent(in) :: O
         real(kind=dp),   intent(in) :: L2
         real(kind=dp),   intent(in) :: alpha
         real(kind=dp) :: rho
         real(kind=dp), automatic :: t0,t1,t2,alpha2
         alpha2 = alpha+alpha
         t0     = cos(alpha2)
         t1     = 1.0_dp-alpha2*alpha2*0.5_dp
         if(Compare_FLoat(t0,t1)) then
            t2  = l2*0.5_dp
            rho = O*t2*alpha2*alpha2
         end if
         rho = tiny(1.0_dp)
      end function defocus_small_ang_r8


      pure elemental function traj_scan_dxdt_r4(dx,dt) result(dxdt)
         !dir$ optimize:3
         !dir$ attributes code_align : 32 :: traj_scan_dxdt_r4
         !dir$ attributes forceinline :: traj_scan_dxdt_r4
         real(kind=sp), dimension(0:1), intent(in) :: dx
         real(kind=sp), dimension(0:1), intent(in) :: dt
         real(kind=sp) :: dxdt
         dxdt = dx(1)-dx(0)/(dt(1)-dt(0))
      end function traj_scan_dxdt_r4


      pure elemental function traj_scan_dxdt_r8(dx,dt) result(dxdt)
         !dir$ optimize:3
         !dir$ attributes code_align : 32 :: traj_scan_dxdt_r8
         !dir$ attributes forceinline :: traj_scan_dxdt_r8
         real(kind=dp), dimension(0:1), intent(in) :: dx
         real(kind=dp), dimension(0:1), intent(in) :: dt
         real(kind=dp) :: dxdt
         dxdt = dx(1)-dx(0)/(dt(1)-dt(0))
      end function traj_scan_dxdt_r8


      pure elemental function traj_scan_dydt_r4(dy,dt) result(dydt)
         !dir$ optimize:3
         !dir$ attributes code_align : 32 :: traj_scan_dydt_r4
         !dir$ attributes forceinline :: traj_scan_dydt_r4
         real(kind=sp), dimension(0:1), intent(in) :: dy
         real(kind=sp), dimension(0:1), intent(in) :: dt
         real(kind=sp) :: dydt
         dxdt = dy(1)-dy(0)/(dt(1)-dt(0))
      end function traj_scan_dydt_r4

       
      pure elemental function traj_scan_dydt_r8(dy,dt) result(dydt)
         !dir$ optimize:3
         !dir$ attributes code_align : 32 :: traj_scan_dydt_r8
         !dir$ attributes forceinline :: traj_scan_dydt_r8
         real(kind=dp), dimension(0:1), intent(in) :: dx=y
         real(kind=dp), dimension(0:1), intent(in) :: dt
         real(kind=dp) :: dydt
         dxdt = dy(1)-dy(0)/(dt(1)-dt(0))
      end function traj_scan_dydt_r8


      ! СКАНИРОВАНИЕ ЗЕРКАЛОМ, ВРАЩАЮЩИМСЯ
      ! ВОКРУГ ОСИ, НЕПЕРПЕНДИКУЛЯРНОЙ К НЕМУ
      ! Formula 1, p. 100
      pure elemental function fov_x_axis_r4(H,delta,gamma) result(ax)
         !dir$ optimize:3
         !dir$ attributes code_align : 32 :: fov_x_axis_r4
         !dir$ attributes forceinline :: fov_x_axis_r4
         real(kind=sp),  intent(in) :: H
         real(kind=sp),  intent(in) :: delta
         real(kind=sp),  intent(in) :: gamma
         real(kind=sp) :: ax
         real(kind=sp), automatic :: gamm2,tdel
         gamm2 = 0.5_sp*gamma
         tdel  = tan(delta)
         ax    = H*tdel/cos(gamm2)
      end function fov_x_axis_r4


      pure elemental function fov_x_axis_r8(H,delta,gamma) result(ax)
         !dir$ optimize:3
         !dir$ attributes code_align : 32 :: fov_x_axis_r8
         !dir$ attributes forceinline :: fov_x_axis_r8
         real(kind=dp),  intent(in) :: H
         real(kind=dp),  intent(in) :: delta
         real(kind=dp),  intent(in) :: gamma
         real(kind=dp) :: ax
         real(kind=dp), automatic :: gamm2,tdel
         gamm2 = 0.5_dp*gamma
         tdel  = tan(delta)
         ax    = H*tdel/cos(gamm2)
      end function fov_x_axis_r8


      pure elemental function fov_y_axis_r4(H,delta,gamma) result(ay)
         !dir$ optimize:3
         !dir$ attributes code_align : 32 :: fov_y_axis_r4
         !dir$ attributes forceinline :: fov_y_axis_r4
         real(kind=sp),  intent(in) :: H
         real(kind=sp),  intent(in) :: delta
         real(kind=sp),  intent(in) :: gamma
         real(kind=sp) :: ay
         real(kind=sp) :: ax,t0
         t0 = 0.5_sp*gamma
         ax = fov_x_axis_r4(H,delta,gamma)
         ay = t0*ax
      end function fov_y_axis_r4


      pure elemental function fov_y_axis_r8(H,delta,gamma) result(ay)
         !dir$ optimize:3
         !dir$ attributes code_align : 32 :: fov_y_axis_r8
         !dir$ attributes forceinline :: fov_y_axis_r8
         real(kind=dp),  intent(in) :: H
         real(kind=dp),  intent(in) :: delta
         real(kind=dp),  intent(in) :: gamma
         real(kind=dp) :: ay
         real(kind=dp) :: ax,t0
         t0 = 0.5_dp*gamma
         ax = fov_x_axis_r8(H,delta,gamma)
         ay = t0*ax
      end function fov_y_axis_r8


   


     
       

     


      !Если рабочая зона сканирования ограничена углом G, то
      !ширина захвата
      !Formula 3, p. 100
     pure elemental function scan_width_r4(H,gamma,theta) result(B)
         !dir$ optimize:3
         !dir$ attributes code_align : 32 :: scan_width_r4
         !dir$ attributes forceinline :: scan_width_r4
         real(kind=sp),   intent(in) :: H
         real(kind=sp),   intent(in) :: gamma
         real(kind=sp),   intent(in) :: theta
         real(kind=sp) :: B
         real(kind=sp), automatic :: gam2,th2,t0,t1
         gam2  = 0.5_sp*gamma
         th2   = 0.5_sp*theta
         t0    = tan(gam2)
         t1    = sin(th2)
         B     = (H+H)*t0*t1
      end function scan_width_r4


      pure elemental function scan_width_r8(H,gamma,theta) result(B)
         !dir$ optimize:3
         !dir$ attributes code_align : 32 :: scan_width_r8
         !dir$ attributes forceinline :: scan_width_r8
         real(kind=dp),   intent(in) :: H
         real(kind=dp),   intent(in) :: gamma
         real(kind=dp),   intent(in) :: theta
         real(kind=dp) :: B
         real(kind=dp), automatic :: gam2,th2,t0,t1
         gam2  = 0.5_dp*gamma
         th2   = 0.5_dp*theta
         t0    = tan(gam2)
         t1    = sin(th2)
         B     = (H+H)*t0*t1
      end function scan_width_r8


   


      !Плоскопараллельная пластинка, установленная за 
      !объективом, изменяет ход лучей таким образом, что изображение
      ! светящейся точки отодвигается и его положение зависит от угла у
      !между оптической осью и нормалью N к поверхности пластинки
      ! Formula 7,8 p. 106
      pure elemental function refract_shift_r4(i1,delta,alfa,gamma,n) result(l)
         !dir$ optimize:3
         !dir$ attributes code_align : 32 :: refract_shift_r4
         !dir$ attributes forceinline :: refract_shift_r4
         use mod_fpcompare, only : Compare_Float
         real(kind=sp),   intent(in) :: i1
         real(kind=sp),   intent(in) :: delta
         real(kind=sp),   intent(in) :: alfa
         real(kind=sp),   intent(in) :: gamma
         real(kind=sp),   intent(in) :: n
         real(kind=sp) :: l
         real(kind=sp), automatic :: ag,num,den,sin2,sag,t0,t1
         ag  = alfa-gamma
         if(Compare_Float(i1,ag)) then
            sag  = sin(ag)
            t0   = delta*sag
            sin2 = sag*sag
            num  = 1.0_sp-sag
            den  = n*n-sag
            t1   = 1.0_sp-sqrt(num/den)
            l    = t0*t2
         else if(alfa==0.0_sp) then
            sag  = sin(gamma)
            t0   = -delta*sag
            sin2 = sag*sag
            num  = 1.0_sp-sin2
            den  = n*n-sin2
            t1   = 1.0_sp-sqrt(num/den)
            l    = t0*t1
         else
            sag  = sin(i1)
            t0   = delta*sag
            sin2 = sag*sag
            num  = 1.0_sp-sin2
            den  = n*n-sin2
            t1   = 1.0_sp-sqrt(num/den)
            l    = t0*t1
         end if
      end function refract_shift_r4


      pure elemental function refract_shift_r8(i1,delta,alfa,gamma,n) result(l)
         !dir$ optimize:3
         !dir$ attributes code_align : 32 :: refract_shift_r8
         !dir$ attributes forceinline :: refract_shift_r8
         use mod_fpcompare, only : Compare_Float
         real(kind=dp),   intent(in) :: i1
         real(kind=dp),   intent(in) :: delta
         real(kind=dp),   intent(in) :: alfa
         real(kind=dp),   intent(in) :: gamma
         real(kind=dp),   intent(in) :: n
         real(kind=dp) :: l
         real(kind=dp), automatic :: ag,num,den,sin2,sag,t0,t1
         ag  = alfa-gamma
         if(Compare_Float(i1,ag)) then
            sag  = sin(ag)
            t0   = delta*sag
            sin2 = sag*sag
            num  = 1.0_dp-sag
            den  = n*n-sag
            t1   = 1.0_dp-sqrt(num/den)
            l    = t0*t2
         else if(alfa==0.0_dp) then
            sag  = sin(gamma)
            t0   = -delta*sag
            sin2 = sag*sag
            num  = 1.0_dp-sin2
            den  = n*n-sin2
            t1   = 1.0_dp-sqrt(num/den)
            l    = t0*t1
         else
            sag  = sin(i1)
            t0   = delta*sag
            sin2 = sag*sag
            num  = 1.0_dp-sin2
            den  = n*n-sin2
            t1   = 1.0_dp-sqrt(num/den)
            l    = t0*t1
         end if
     end function refract_shift_r8

       
    

          
       

      !Formula 1, p. 108
      subroutine project_xy_axis_r4(l,alpha,xl,yl)
         !dir$ optimize:3
         !dir$ attributes code_align : 32 :: project_xy_axis_r4
         !dir$ attributes forceinline :: project_xy_axis_r4
         real(kind=sp),  intent(in)  :: l
         real(kind=sp),  intent(in)  :: alpha
         real(kind=sp),  intent(out) :: xl
         real(kind=sp),  intent(out) :: yl
         real(kind=sp), automatic :: absl
         absl = abs(l)
         xl = absl*cos(alpha)
         yl = absl*sin(alpha)
      end subroutine project_xy_axis_r4
 

      subroutine project_xy_axis_r8(l,alpha,xl,yl)
         !dir$ optimize:3
         !dir$ attributes code_align : 32 :: project_xy_axis_r8
         !dir$ attributes forceinline :: project_xy_axis_r8
         real(kind=dp),  intent(in)  :: l
         real(kind=dp),  intent(in)  :: alpha
         real(kind=dp),  intent(out) :: xl
         real(kind=dp),  intent(out) :: yl
         real(kind=dp), automatic :: absl
         absl = abs(l)
         xl = absl*cos(alpha)
         yl = absl*sin(alpha)
     end subroutine project_xy_axis_r8


    

       
      !Величину смещения луча s вдоль перпендикуляра к 
      !поверхности пластинки
      ! Formula 2, p. 108
      pure elemental function s_shift_r4(l,alpha,gamma) result(s)
         !dir$ optimize:3
         !dir$ attributes code_align : 32 ::s_shift_r4
         !dir$ attributes forceinline :: s_shift_r4
         real(kind=sp),   intent(in) :: l
         real(kind=sp),   intent(in) :: alpha
         real(kind=sp),   intent(in) :: gamma
         real(kind=sp) :: s
         real(kind=sp), automatic :: ag,sag
         ag = alpha-gamma
         sag= sin(ag)
         s  = l/sag
      end function s_shift_r4


      pure elemental function s_shift_r8(l,alpha,gamma) result(s)
         !dir$ optimize:3
         !dir$ attributes code_align : 32 ::s_shift_r8
         !dir$ attributes forceinline :: s_shift_r8
         real(kind=dp),   intent(in) :: l
         real(kind=dp),   intent(in) :: alpha
         real(kind=dp),   intent(in) :: gamma
         real(kind=dp) :: s
         real(kind=dp), automatic :: ag,sag
         ag = alpha-gamma
         sag= sin(ag)
         s  = l/sag
      end function s_shift_r8


    

      ! Проекции s на оси координат равны
      ! Formula 4, p. 108
      subroutine project_s_xy_r4(s,gamma,xs,ys)
         !dir$ optimize:3
         !dir$ attributes code_align : 32 :: project_s_xy_r4
         !dir$ attributes forceinline :: project_s_xy_r4
         real(kind=sp),   intent(in)  :: s
         real(kind=sp),   intent(in)  :: gamma
         real(kind=sp),   intent(out) :: xs
         real(kind=sp),   intent(in)  :: ys
         xs = s*cos(gamma)
         ys = s*sin(gamma)
      end subroutine project_s_xy_r4


      subroutine project_s_xy_r8(s,gamma,xs,ys)
         !dir$ optimize:3
         !dir$ attributes code_align : 32 :: project_s_xy_r8
         !dir$ attributes forceinline :: project_s_xy_r8
         real(kind=dp),   intent(in)  :: s
         real(kind=dp),   intent(in)  :: gamma
         real(kind=dp),   intent(out) :: xs
         real(kind=dp),   intent(in)  :: ys
         xs = s*cos(gamma)
         ys = s*sin(gamma)
      end subroutine project_s_xy_r8


    

      ! что расстояния от начала координат О до точек
      ! пересечения лучей, образующих с горизонталью угла ±а, с 
      ! перпендикуляром к пластинке
      ! Formula 1, p. 110
      pure elemental function ray_intercept_pa_r4(delta,alpha,gamma,n) result(sp)
         !dir$ optimize:3
         !dir$ attributes code_align : 32 :: ray_intercept_pa_r4
         !dir$ attributes forceinline :: ray_intercept_pa_r4
         real(kind=sp),   intent(in) :: delta
         real(kind=sp),   intent(in) :: alpha
         real(kind=sp),   intent(in) :: gamma
         real(kind=sp),   intent(in) :: n
         real(kind=sp) :: sp
         real(kind=sp), automatic :: ag,num,den,n2,sag,sin2
         ag  = abs(alpha)-gamma
         n2  = n*n
         num = cos(ag)
         sag = sin(ag)
         sin2= sag*sag
         den = sqrt(n2-sin2)
         sp  = delta*1.0_sp-(num/den)
      end function ray_intercept_pa_r4


      pure elemental function ray_intercept_pa_r8(delta,alpha,gamma,n) result(sp)
         !dir$ optimize:3
         !dir$ attributes code_align : 32 :: ray_intercept_pa_r8
         !dir$ attributes forceinline :: ray_intercept_pa_r8
         real(kind=dp),   intent(in) :: delta
         real(kind=dp),   intent(in) :: alpha
         real(kind=dp),   intent(in) :: gamma
         real(kind=dp),   intent(in) :: n
         real(kind=dp) :: sp
         real(kind=dp), automatic :: ag,num,den,n2,sag,sin2
         ag  = abs(alpha)-gamma
         n2  = n*n
         num = cos(ag)
         sag = sin(ag)
         sin2= sag*sag
         den = sqrt(n2-sin2)
         sp  = delta*1.0_dp-(num/den)
      end function ray_intercept_pa_r8


    


      pure elemental function ray_intercept_na_r4(delta,alpha,gamma,n) result(sn)
         !dir$ optimize:3
         !dir$ attributes code_align : 32 :: ray_intercept_na_r4
         !dir$ attributes forceinline :: ray_intercept_na_r4
         real(kind=sp),   intent(in) :: delta
         real(kind=sp),   intent(in) :: alpha
         real(kind=sp),   intent(in) :: gamma
         real(kind=sp),   intent(in) :: n
         real(kind=sp) :: sn
         real(kind=sp), automatic :: ag,num,den,n2,sag,sin2
         ag  = abs(alpha)+gamma
         n2  = n*n
         num = cos(ag)
         sag = sin(ag)
         sin2= sag*sag
         den = sqrt(n2-sin2)
         sn  = delta*1.0_sp-(num/den)
      end function ray_intercept_na_r4


      pure elemental function ray_intercept_na_r8(delta,alpha,gamma,n) result(sn)
         !dir$ optimize:3
         !dir$ attributes code_align : 32 :: ray_intercept_na_r8
         !dir$ attributes forceinline :: ray_intercept_na_r8
         real(kind=dp),   intent(in) :: delta
         real(kind=dp),   intent(in) :: alpha
         real(kind=dp),   intent(in) :: gamma
         real(kind=dp),   intent(in) :: n
         real(kind=dp) :: sn
         real(kind=dp), automatic :: ag,num,den,n2,sag,sin2
         ag  = abs(alpha)+gamma
         n2  = n*n
         num = cos(ag)
         sag = sin(ag)
         sin2= sag*sag
         den = sqrt(n2-sin2)
         sn  = delta*1.0_dp-(num/den)
      end function ray_intercept_na_r8


    


       ! Formula 3, p. 110
       pure function ray_diff_r4(delta,alpha,gamma,n,u) result(ds)
           !dir$ optimize:3
           !dir$ attributes code_align : 32 :: ray_diff_r4
           !dir$ attributes forceinline :: ray_diff_r4
           real(kind=sp),   intent(in) :: delta
           real(kind=sp),   intent(in) :: alpha
           real(kind=sp),   intent(in) :: gamma
           real(kind=sp),   intent(in) :: n
           real(kind=sp),   intent(in) :: u
           real(kind=sp) :: ds
           real(kind=sp), automatic :: t0,t1,u2,u2g,su2,sg,t2,n2,t3,t4,t5
           n   = n*n
           u2  = u*0.5_sp
           u2g = u2-gamma
           t2  = sin(u2g)
           su2 = t2*t2
           if(n2>=su2) then
              t3 = (-2.0_sp*delta)/n
              t4 = sin(u2)
              t5 = sin(gamma)
              ds = t3*t4*t5
           else
              t0  = ray_intercept_pa_r4(delta,alpha,gamma,n)
              t1  = ray_intercept_na_r4(delta,alpha,gamma,n)
              ds  = t0-t1
           end if
       end function ray_diff_r4

         
       pure function ray_diff_r8(delta,alpha,gamma,n,u) result(ds)
           !dir$ optimize:3
           !dir$ attributes code_align : 32 :: ray_diff_r8
           !dir$ attributes forceinline :: ray_diff_r8
           real(kind=dp),   intent(in) :: delta
           real(kind=dp),   intent(in) :: alpha
           real(kind=dp),   intent(in) :: gamma
           real(kind=dp),   intent(in) :: n
           real(kind=dp),   intent(in) :: u
           real(kind=dp) :: ds
           real(kind=dp), automatic :: t0,t1,u2,u2g,su2,sg,t2,n2,t3,t4,t5
           n   = n*n
           u2  = u*0.5_dp
           u2g = u2-gamma
           t2  = sin(u2g)
           su2 = t2*t2
           if(n2>=su2) then
              t3 = (-2.0_dp*delta)/n
              t4 = sin(u2)
              t5 = sin(gamma)
              ds = t3*t4*t5
           else
           t0  = ray_intercept_pa_r8(delta,alpha,gamma,n)
           t1  = ray_intercept_na_r8(delta,alpha,gamma,n)
           ds  = t0-t1
        end function ray_diff_r8


      
         
        !Поле точек пересечения лучей, преломленных пластинкой,
        !относительно оси Ох (рис. 87) имеет симметрию, поэтому 
        !упростим обозначения и выполним расчет соответствующих 
        !координат на основании
        ! Formula 6,7, p. 111
        subroutine compute_dxdy_r4(alpha,beta,delta,gamma,n,u,dx,dy)
           !dir$ optimize:3
           !dir$ attributes code_align : 32 ::  compute_dxdy_r4
           !dir$ attributes forceinline ::  compute_dxdy_r4
           real(kind=sp),    intent(in)  :: alpha
           real(kind=sp),    intent(in)  :: beta
           real(kind=sp),    intent(in)  :: delta
           real(kind=sp),    intent(in)  :: gamma
           real(kind=sp),    intent(in)  :: n
           real(kind=sp),    intent(in)  :: u
           real(kind=sp),    intent(out) :: dx
           real(kind=sp),    intent(out) :: dy
           real(kind=sp), automatic :: ag,ds,t0,t1,t2
           ag  = alpha+gamma
           ds  = ray_diff_r4(delta,alfa,gamma,n,u)
           t0  = sin(ag)
           t1  = 2.0_sp*sin(alpha)
           t2  = 2.0_sp*cos(alpha)
           dx  = t0/t1*ds
           dy  = t0/t2*ds
        end subroutine compute_dxdy_r4


        subroutine compute_dxdy_r8(alpha,beta,delta,gamma,n,u,dx,dy)
           !dir$ optimize:3
           !dir$ attributes code_align : 32 ::  compute_dxdy_r8
           !dir$ attributes forceinline ::  compute_dxdy_r8
           real(kind=dp),    intent(in)  :: alpha
           real(kind=dp),    intent(in)  :: beta
           real(kind=dp),    intent(in)  :: delta
           real(kind=dp),    intent(in)  :: gamma
           real(kind=dp),    intent(in)  :: n
           real(kind=dp),    intent(in)  :: u
           real(kind=dp),    intent(out) :: dx
           real(kind=dp),    intent(out) :: dy
           real(kind=dp), automatic :: ag,ds,t0,t1,t2
           ag  = alpha+gamma
           ds  = ray_diff_r8(delta,alfa,gamma,n,u)
           t0  = sin(ag)
           t1  = 2.0_dp*sin(alpha)
           t2  = 2.0_dp*cos(alpha)
           dx  = t0/t1*ds
           dy  = t0/t2*ds
       end subroutine compute_dxdy_r8


     

        ! Formula 7,8  p. 111
        subroutine compute_xy_r4(alpha,beta,delta,gamma,n,u,x,y)
           !dir$ optimize:3
           !dir$ attributes code_align : 32 ::  compute_xy_r4
           !dir$ attributes forceinline ::  compute_xy_r4
           real(kind=sp),    intent(in)  :: alpha
           real(kind=sp),    intent(in)  :: beta
           real(kind=sp),    intent(in)  :: delta
           real(kind=sp),    intent(in)  :: gamma
           real(kind=sp),    intent(in)  :: n
           real(kind=sp),    intent(in)  :: u
           real(kind=sp),    intent(out) :: x
           real(kind=sp),    intent(out) :: y
           real(kind=sp), automatic :: sag,cag,pa,dx,dy,xs,ys
           sag  = sin(gamma)
           cag  = cos(gamma)
           pa   = ray_intercept_pa_r4(delta,alpha,gamma,n)
           xs   = pa*sag
           ys   = pa*cag
           call compute_dxdy_r4(alpha,beta,delta,gamma,n,u,dx,dy)
           x    = xs+dx
           y    = ys+dx
        end subroutine compute_xy_r4

    
        subroutine compute_xy_r8(alpha,beta,delta,gamma,n,u,x,y)
           !dir$ optimize:3
           !dir$ attributes code_align : 32 ::  compute_xy_r8
           !dir$ attributes forceinline ::  compute_xy_r8
           real(kind=dp),    intent(in)  :: alpha
           real(kind=dp),    intent(in)  :: beta
           real(kind=dp),    intent(in)  :: delta
           real(kind=dp),    intent(in)  :: gamma
           real(kind=dp),    intent(in)  :: n
           real(kind=dp),    intent(in)  :: u
           real(kind=dp),    intent(out) :: x
           real(kind=dp),    intent(out) :: y
           real(kind=dp), automatic :: sag,cag,pa,dx,dy,xs,ys
           sag  = sin(gamma)
           cag  = cos(gamma)
           pa   = ray_intercept_pa_r8(delta,alpha,gamma,n)
           xs   = pa*sag
           ys   = pa*cag
           call compute_dxdy_r8(alpha,beta,delta,gamma,n,u,dx,dy)
           x    = xs+dx
           y    = ys+dx
        end subroutine compute_xy_r8


       


        subroutine compute_xdyd_r4(gamma,u,n,xd,yd)
           !dir$ optimize:3
           !dir$ attributes code_align : 32 ::  compute_xdyd_r4
           !dir$ attributes forceinline ::  compute_xdyd_r4
           real(kind=sp),  intent(in)  :: gamma
           real(kind=sp),  intent(in)  :: u
           real(kind=sp),  intent(in)  :: n
           real(kind=sp),  intent(out) :: xd
           real(kind=sp),  intent(out) :: yd
           real(kind=sp), automatic :: cosg,sing,sin2s,sin2d,u2,u2gs,u2gd,n2,t0,t1,t2,t3,t4
           cosg = cos(gamma)
           sing = sin(gamma)
           u2   = u*0.5_sp
           n2   = n*n
           u2gs = u2+gamma
           ungd = u2-gamma
           t0   = sin(u2gs)
           sin2s= t0*t0
           t1   = sin(u2gd)
           sin2d= t1*t1
           t2   = 1.0_sp/(4.0_sp*sin(u2))
           t3   = sqrt(n2-sin2s)
           t0   = sin2s/t3
           t4   = sqrt(n2-sin2d)
           t1   = sin2d/t4
           dx   = cosg-t2*(t0+t1)
           t2   = 1.0_sp/(4.0_sp*cos(u2)
           dy   = sing-t2*(t0-t1)
        end subroutine compute_xdyd_r4


       subroutine compute_xdyd_r8(gamma,u,n,xd,yd)
           !dir$ optimize:3
           !dir$ attributes code_align : 32 ::  compute_xdyd_r8
           !dir$ attributes forceinline ::  compute_xdyd_r8
           real(kind=dp),  intent(in)  :: gamma
           real(kind=dp),  intent(in)  :: u
           real(kind=dp),  intent(in)  :: n
           real(kind=dp),  intent(out) :: xd
           real(kind=dp),  intent(out) :: yd
           real(kind=dp), automatic :: cosg,sing,sin2s,sin2d,u2,u2gs,u2gd,n2,t0,t1,t2,t3,t4
           cosg = cos(gamma)
           sing = sin(gamma)
           u2   = u*0.5_dp
           n2   = n*n
           u2gs = u2+gamma
           ungd = u2-gamma
           t0   = sin(u2gs)
           sin2s= t0*t0
           t1   = sin(u2gd)
           sin2d= t1*t1
           t2   = 1.0_dp/(4.0_dp*sin(u2))
           t3   = sqrt(n2-sin2s)
           t0   = sin2s/t3
           t4   = sqrt(n2-sin2d)
           t1   = sin2d/t4
           dx   = cosg-t2*(t0+t1)
           t2   = 1.0_dp/(4.0_dp*cos(u2)
           dy   = sing-t2*(t0-t1)
        end subroutine compute_xdyd_r8


       

        subroutine paraxial_xdyd_r4(gamma,alpha,n,xd,yd)
           !dir$ optimize:3
           !dir$ attributes code_align : 32 ::  paraxial_xdyd_r4
           !dir$ attributes forceinline ::  paraxial_xdyd_r4 
           real(kind=sp),  intent(in)  :: gamma
           real(kind=sp),  intent(in)  :: alpha
           real(kind=sp),  intent(in)  :: n
           real(kind=sp),  intent(out) :: xd
           real(kind=sp),  intent(out) :: yd
           real(kind=sp), automatic :: n2,cosg,sing,sin4g,sin2g,num,den,cos2g,t0,t1
           n2    = n*n
           cosg  = cos(gamma)
           cos2g = cos(gamma+gamma)
           sing  = sin(gamma)
           sin4g = sing*sing*sing*sing
           num   = n2*cos2g+sin4g
           den   = (n2-sing*sing)**1.5_sp
           xd    = cosg-num/den
           t0    = sqrt(n2-sing*sing)
           t1    = 1.0_sp-cosg/t0
           yd    = sing*t1
        end subroutine paraxial_xdyd_r4

     
        subroutine paraxial_xdyd_r8(gamma,alpha,n,xd,yd)
           !dir$ optimize:3
           !dir$ attributes code_align : 32 ::  paraxial_xdyd_r8
           !dir$ attributes forceinline ::  paraxial_xdyd_r8
           real(kind=dp),  intent(in)  :: gamma
           real(kind=dp),  intent(in)  :: alpha
           real(kind=dp),  intent(in)  :: n
           real(kind=dp),  intent(out) :: xd
           real(kind=dp),  intent(out) :: yd
           real(kind=dp), automatic :: n2,cosg,sing,sin4g,sin2g,num,den,cos2g,t0,t1
           n2    = n*n
           cosg  = cos(gamma)
           cos2g = cos(gamma+gamma)
           sing  = sin(gamma)
           sin4g = sing*sing*sing*sing
           num   = n2*cos2g+sin4g
           den   = (n2-sing*sing)**1.5_dp
           xd    = cosg-num/den
           t0    = sqrt(n2-sing*sing)
           t1    = 1.0_dp-cosg/t0
           yd    = sing*t1
        end subroutine paraxial_xdyd_r8


        subroutine paraxial_xdyd_zmm16r4(gamma,alpha,n,xd,yd)
            !dir$ optimize:3
            !dir$ attributes code_align : 32 :: paraxial_xdyd_zmm16r4
            !dir$ attributes forceinline ::  paraxial_xdyd_zmm16r4
            !dir$ attributes optimization_parameter:"target_arch=skylake-avx512" ::  paraxial_xdyd_zmm16r4
            type(ZMM16r4_t),   intent(in)  :: gamma
            type(ZMM16r4_t),   intent(in)  :: alpha
            type(ZMM16r4_t),   intent(in)  :: n
            type(ZMM16r4_t),   intent(out) :: xd
            type(ZMM16r4_t),   intent(out) :: yd
            type(ZMM16r4_t), parameter :: one = ZMM16r4_t(1.0_sp)
            type(ZMM16r4_t), automatic :: n2,cosg,sing,sin4g,sin2g,num,den,cos2g,t0,t1
            n2    = n.v*n.v
            cosg  = cos(gamma.v)
            cos2g = cos(gamma.v+gamma.v)
            sing  = sin(gamma.v)
            sin4g = sing.v*sing.v*sing.v*sing.v
            num   = n2.v*cos2g.v+sin4g.v
            den   = (n2.v-sing.v*sing.v)**1.5_sp
            xd    = cosg.v-num.v/den.v
            t0    = sqrt(n2.v-sing.v*sing.v)
            t1    = one.v-cosg.v/t0.v
            yd    = sing.v*t1.v
        end subroutine paraxial_xdyd_zmm16r4
        
        
        subroutine paraxial_xdyd_zmm8r8(gamma,alpha,n,xd,yd)
            !dir$ optimize:3
            !dir$ attributes code_align : 32 :: paraxial_xdyd_zmm8r8
            !dir$ attributes forceinline ::  paraxial_xdyd_zmm8r8
            !dir$ attributes optimization_parameter:"target_arch=skylake-avx512" ::  paraxial_xdyd_zmm8r8
            type(ZMM8r8_t),   intent(in)  :: gamma
            type(ZMM8r8_t),   intent(in)  :: alpha
            type(ZMM8r8_t),   intent(in)  :: n
            type(ZMM8r8_t),   intent(out) :: xd
            type(ZMM8r8_t),   intent(out) :: yd
            type(ZMM8r8_t), parameter :: one = ZMM8r8_t(1.0_dp)
            type(ZMM8r8_t), automatic :: n2,cosg,sing,sin4g,sin2g,num,den,cos2g,t0,t1
            n2    = n.v*n.v
            cosg  = cos(gamma.v)
            cos2g = cos(gamma.v+gamma.v)
            sing  = sin(gamma.v)
            sin4g = sing.v*sing.v*sing.v*sing.v
            num   = n2.v*cos2g.v+sin4g.v
            den   = (n2.v-sing.v*sing.v)**1.5_dp
            xd    = cosg.v-num.v/den.v
            t0    = sqrt(n2.v-sing.v*sing.v)
            t1    = one.v-cosg.v/t0.v
            yd    = sing.v*t1.v
        end subroutine paraxial_xdyd_zmm8r8


        !СКАНИРОВАНИЕ ВРАЩАЮЩИМИСЯ ОБЪЕКТИВАМИ
        !Formula 1, p. 121
        subroutine fov_axay_r4(H,delx,dely,phi,ax,ay)
           !dir$ optimize:3
           !dir$ attributes code_align : 32 ::  fov_axay_r4
           !dir$ attributes forceinline ::  fov_axay_r4  
           real(kind=sp),  intent(in) :: H
           real(kind=sp),  intent(in) :: delx
           real(kind=sp),  intent(in) :: dely
           real(kind=sp),  intent(in) :: phi
           real(kind=sp),  intent(out):: ax
           real(kind=sp),  intent(out):: ay
           real(kind=sp), automatic :: sec2,phi2,t0,t1,sec
           phi2  = 0.5_sp*phi
           sec   = 1.0_sp/cos(phi2)
           sec2  = sec*sec
           ax    = H*delx*sec2
           ay    = H*dely*sec
        end subroutine fov_axay_r4
        
        
        subroutine fov_axay_r8(H,delx,dely,phi,ax,ay)
           !dir$ optimize:3
           !dir$ attributes code_align : 32 ::  fov_axay_r8
           !dir$ attributes forceinline ::  fov_axay_r8  
           real(kind=dp),  intent(in) :: H
           real(kind=dp),  intent(in) :: delx
           real(kind=dp),  intent(in) :: dely
           real(kind=dp),  intent(in) :: phi
           real(kind=dp),  intent(out):: ax
           real(kind=dp),  intent(out):: ay
           real(kind=dp), automatic :: sec2,phi2,t0,t1,sec
           phi2  = 0.5_dp*phi
           sec   = 1.0_dp/cos(phi2)
           sec2  = sec*sec
           ax    = H*delx*sec2
           ay    = H*dely*sec
        end subroutine fov_axay_r8
        
        
       
        
        
        subroutine  fov_dxdy_r4(x,y,F,phi,dx,dy)
           !dir$ optimize:3
           !dir$ attributes code_align : 32 ::  fov_dxdy_r4
           !dir$ attributes forceinline ::  fov_dxdy_r4  
           real(kind=sp),   intent(in) :: x
           real(kind=sp),   intent(in) :: y
           real(kind=sp),   intent(in) :: F
           real(kind=sp),   intent(in) :: phi
           real(kind=sp),   intent(out):: dx
           real(kind=sp),   intent(out):: dy
           real(kind=sp), automatic :: d0x,d0y,phi2
           d0y   = y/F
           phi2  = 0.5_sp*phi
           d0x   = x/F
           dy    = d0y
           dx    = d0x*cos(phi2)
        end subroutine fov_dxdy_r4
        
        
        subroutine  fov_dxdy_r8(x,y,F,phi,dx,dy)
           !dir$ optimize:3
           !dir$ attributes code_align : 32 ::  fov_dxdy_r8
           !dir$ attributes forceinline ::  fov_dxdy_r8  
           real(kind=dp),   intent(in) :: x
           real(kind=dp),   intent(in) :: y
           real(kind=dp),   intent(in) :: F
           real(kind=dp),   intent(in) :: phi
           real(kind=dp),   intent(out):: dx
           real(kind=dp),   intent(out):: dy
           real(kind=dp), automatic :: d0x,d0y,phi2
           d0y   = y/F
           phi2  = 0.5_dp*phi
           d0x   = x/F
           dy    = d0y
           dx    = d0x*cos(phi2)
        end subroutine fov_dxdy_r8
        
        
       
        
        subroutine volt_impulse_uxuy_r4(u,om1,om2,t,ux,uy)
           !dir$ optimize:3
           !dir$ attributes code_align : 32 ::  volt_impulse_uxuy_r4
           !dir$ attributes forceinline ::  volt_impulse_uxuy_r4
           real(kind=sp),   intent(in) :: u
           real(kind=sp),   intent(in) :: om1
           real(kind=sp),   intent(in) :: om2
           real(kind=sp),   intent(in) :: t
           real(kind=sp),   intent(out):: ux
           real(kind=sp),   intent(out):: uy
           real(kind=sp), automatic :: om1t,om2t,t0,t1
           om1t = om1*t
           om2t = om2*t
           t0   = sin(om1t)+sin(om2t)
           t1   = cos(om1t)+cos(om2t)
           ux   = u*t0
           uy   = u*t1
        end subroutine volt_impulse_uxuy_r4
        
        
        subroutine volt_impulse_uxuy_r8(u,om1,om2,t,ux,uy)
           !dir$ optimize:3
           !dir$ attributes code_align : 32 ::  volt_impulse_uxuy_r8
           !dir$ attributes forceinline ::  volt_impulse_uxuy_r8
           real(kind=dp),   intent(in) :: u
           real(kind=dp),   intent(in) :: om1
           real(kind=dp),   intent(in) :: om2
           real(kind=dp),   intent(in) :: t
           real(kind=dp),   intent(out):: ux
           real(kind=dp),   intent(out):: uy
           real(kind=dp), automatic :: om1t,om2t,t0,t1
           om1t = om1*t
           om2t = om2*t
           t0   = sin(om1t)+sin(om2t)
           t1   = cos(om1t)+cos(om2t)
           ux   = u*t0
           uy   = u*t1
        end subroutine volt_impulse_uxuy_r8


       


        ! Phase Modulation
        ! Formula 1, p. 143
        ! растрового анализатора со 
        !скрещивающимися осями, выполненного в виде надетой на вращающийся 
        !барабан тонкой пленки, прозрачность которой изменяется по 
        !синусоидальному закону 
        pure elemental function raster_transparency_r4(rho_avg,rho_max,    &
                                                       rho_min,l,L,N) result(rho)
           !dir$ optimize:3
           !dir$ attributes code_align : 32 ::  raster_transparency_r4
           !dir$ attributes forceinline ::  raster_transparency_r4
           real(kind=sp),    intent(in) :: rho_avg
           real(kind=sp),    intent(in) :: rho_max
           real(kind=sp),    intent(in) :: rho_min
           real(kind=sp),    intent(in) :: l
           real(kind=sp),    intent(in) :: L
           real(kind=sp),    intent(in) :: N
           real(kind=sp) :: rho
           real(kind=sp), parameter :: twopi = 6.283185307179586476925286766559_sp
           real(kind=sp), automatic :: t0,t1,t2
           t0  = 0.5_sp*(rho_max-rho_min)
           t1  = L/N
           t2  = sin(twopi*l*t1)
           rho = rho_avg+t0*t2
        end function raster_transparency_r4


       pure elemental function raster_transparency_r8(rho_avg,rho_max,    &
                                                       rho_min,l,L,N) result(rho)
           !dir$ optimize:3
           !dir$ attributes code_align : 32 ::  raster_transparency_r8
           !dir$ attributes forceinline ::  raster_transparency_r8
           real(kind=dp),    intent(in) :: rho_avg
           real(kind=dp),    intent(in) :: rho_max
           real(kind=dp),    intent(in) :: rho_min
           real(kind=dp),    intent(in) :: l
           real(kind=dp),    intent(in) :: L
           real(kind=dp),    intent(in) :: N
           real(kind=dp) :: rho
           real(kind=dp), parameter :: twopi = 6.283185307179586476925286766559_dp
           real(kind=dp), automatic :: t0,t1,t2
           t0  = 0.5_dp*(rho_max-rho_min)
           t1  = L/N
           t2  = sin(twopi*l*t1)
           rho = rho_avg+t0*t2
        end function raster_transparency_r8


        !СТРУКТУРА И СПЕКТР МОДУЛИРОВАННОГО ПОТОКА
        !ИЗЛУЧЕНИЯ
        !Formula 1, p. 178
        ! Ф(*) = Int rp(z,t)E(z,t) dsig
        subroutine raster_flux_integral_omp_r8(rhoE,absc,n,t,xlo,xup,Phit_x,ier)
                                             
                                        
           !dir$ optimize:3
           !dir$ attributes code_align : 32 ::  raster_flux_integral_omp_r8
           use quadpack, only : davint
           real(kind=dp),    dimension(1:n,t), intent(in) :: rhoE
           real(kind=dp),    dimension(1:n),   intent(in) :: absc
           integer(kind=i4),                   intent(in) :: n
           integer(kind=i4),                   intent(in) :: t
           real(kind=dp),                      intent(in) :: xlo
           real(kind=dp),                      intent(in) :: xup
           real(kind=dp),    dimension(t),     intent(out):: Phit
           integer(kind=i4), dimension(t),     intent(out):: ier
          
           real(kind=dp) :: ans_x
           integer(kind=i4)  :: i
           integer(kind=i4)  :: err_x
           !dir$ assume_aligned rhoE:64
           !dir$ assume_aligned absc:64
           !dir$ assume_aligned Phit:64
           !dir$ assume_aligned ier:64
!$omp parallel do schedule(runtime) default(none) &
!$omp private(i,ans,err)          &
!$omp shared(t,rhoE,absc,n,xlo,xup)
           do i=1, t ! for 't' time of scanning of radiance field
              call davint(rhoE(:,i),absc,n,xlo,xup,ans,err)
              Phit(i) = ans
              ier(i)  = err
           end do
!$omp end parallel do
        end subroutine raster_flux_integral_omp_r8


        subroutine raster_flux_integral_r8(rhoE,absc,n,t,xlo,xup,Phit,ier)
                                          
                                        
           !dir$ optimize:3
           !dir$ attributes code_align : 32 ::  raster_flux_integral_r8
           use quadpack, only : davint
           real(kind=dp),    dimension(1:n,t), intent(in) :: rhoE
           real(kind=dp),    dimension(1:n),   intent(in) :: absc
           integer(kind=i4),                   intent(in) :: n
           integer(kind=i4),                   intent(in) :: t
           real(kind=dp),                      intent(in) :: xlo
           real(kind=dp),                      intent(in) :: xup
           real(kind=dp),    dimension(t),     intent(out):: Phit
           integer(kind=i4), dimension(t),     intent(out):: ier
          
           real(kind=dp) :: ans
           integer(kind=i4)  :: i
           integer(kind=i4)  :: err
           !dir$ assume_aligned rhoE:64
           !dir$ assume_aligned absc:64
           !dir$ assume_aligned Phit:64
           !dir$ assume_aligned ier:64

           do i=1, t ! for 't' time of scanning of radiance field
              call davint(rhoE(:,i),absc,n,xlo,xup,ans,err)
              Phit(i) = ans
              ier(i)  = err
           end do

         end subroutine raster_flux_integral_r8


         subroutine raster_flux_integral_omp_r4(rhoE,absc,n,t,xlo,xup,Phit,ier)
                                              
                                        
           !dir$ optimize:3
           !dir$ attributes code_align : 32 ::  raster_flux_integral_omp_r4
           use quadpack, only : savint
           real(kind=sp),    dimension(1:n,t), intent(in) :: rhoE
           real(kind=sp),    dimension(1:n),   intent(in) :: absc
           integer(kind=i4),                   intent(in) :: n
           integer(kind=i4),                   intent(in) :: t
           real(kind=sp),                      intent(in) :: xlo
           real(kind=sp),                      intent(in) :: xup
           real(kind=sp),    dimension(t),     intent(out):: Phit
           integer(kind=i4), dimension(t),     intent(out):: ier
       
           real(kind=sp) :: ans
           integer(kind=i4)  :: i
           integer(kind=i4)  :: err 
           !dir$ assume_aligned rhoE:64
           !dir$ assume_aligned Phit:64
           !dir$ assume_aligned absc:64
           !dir$ assume_aligned ier:64
!$omp parallel do schedule(runtime) default(none) &
!$omp private(i,ans,err)          &
!$omp shared(t,rhoE,absc,n,xlo,xup,Phit,ier)
           do i=1, t ! for 't' time of scanning of radiance field
              call savint(rhoE(:,i),absc,n,xlo,xup,ans,err)
              Phit(i) = ans
              ier(i)  = err
            end do
!$omp end parallel do
        end subroutine raster_flux_integral_omp_r4


        subroutine raster_flux_integral_r4(rhoE,absc,n,t,xlo,xup,Phit,ier)
                                           
                                        
           !dir$ optimize:3
           !dir$ attributes code_align : 32 ::  raster_flux_integral_r4
           use quadpack, only : savint
           real(kind=sp),    dimension(1:n,t), intent(in) :: rhoE
           real(kind=sp),    dimension(1:n),   intent(in) :: absc
           integer(kind=i4),                   intent(in) :: n
           integer(kind=i4),                   intent(in) :: t
           real(kind=sp),                      intent(in) :: xlo
           real(kind=sp),                      intent(in) :: xup
           real(kind=sp),    dimension(t),     intent(out):: Phit
           integer(kind=i4), dimension(t),     intent(out):: ier
          
           real(kind=sp) :: ans
           integer(kind=i4)  :: i
           integer(kind=i4)  :: err
           !dir$ assume_aligned rhoE:64
           !dir$ assume_aligned Phit:64
           !dir$ assume_aligned absc:64
           !dir$ assume_aligned ier:64
           do i=1, t ! for 't' time of scanning of radiance field
              call savint(rhoE(:,i),absc,n,xlo,xup,ans,err)
              Phit(i) = ans
              ier(i)  = err
             
           end do

        end subroutine raster_flux_integral_r4



        ! Formula 3, p. 180
        subroutine raster_opacity_integral_omp_r8(invs,rhophi,absc,n,t,xlo,xup,rho,ier)
                                              

            !dir$ optimize:3
            !dir$ attributes code_align : 32 ::  raster_opacity_integral_omp_r8
            use quadpack, only : davint
            real(kind=dp),                      intent(in) :: invs
            real(kind=dp), dimension(1:n,t),    intent(in) :: rhophi
            real(kind=dp), dimension(1:n),      intent(in) :: absc
            integer(kind=i4),                   intent(in) :: n
            integer(kind=i4),                   intent(in) :: t
            real(kind=dp),                      intent(in) :: xlo
            real(kind=dp),                      intent(in) :: xup
            real(kind=dp),    dimension(t),     intent(out):: rho
            integer(kind=i4), dimension(t),     intent(out):: ier
            
            real(kind=dp) :: ans
            integer(kind=i4)  :: i
            integer(kind=i4)  :: err_x
            !dir$ assume_aligned rhophi:64
            !dir$ assume_aligned absc:64
            !dir$ assume_aligned ier:64
            !dir$ assume_aligned rho:64


!$omp parallel do schedule(runtime)default(none) &
!$omp private(i,ans,err,ans)         &
!$omp shared(t,rhophi,absc,n,xlo,xup) &
!$omp shared(rho,ier)
            do i=1, t
               call davint(rhophi(:,t),absc,n,xlo,xup,ans,err)
               rho(i) = invs*ans
               ier(i) = err
             
            end do
!$omp end parallel do
       end subroutine raster_opacity_integral_omp_r8


       subroutine raster_opacity_integral_r8(invs,rhophi,absc,n,t,xlo,xup,rho,ier) 
                                              

            !dir$ optimize:3
            !dir$ attributes code_align : 32 ::  raster_opacity_integral_r8
            use quadpack, only : davint
            real(kind=dp),                      intent(in) :: invs
            real(kind=dp), dimension(1:n,t),    intent(in) :: rhophi
            real(kind=dp), dimension(1:n),      intent(in) :: absc
            integer(kind=i4),                   intent(in) :: n
            integer(kind=i4),                   intent(in) :: t
            real(kind=dp),                      intent(in) :: xlo
            real(kind=dp),                      intent(in) :: xup
            real(kind=dp),    dimension(t),     intent(out):: rho
            integer(kind=i4), dimension(t),     intent(out):: ier
         
            real(kind=dp) :: ans
            integer(kind=i4)  :: i
            integer(kind=i4)  :: err
            !dir$ assume_aligned rhophi:64
            !dir$ assume_aligned absc:64
            !dir$ assume_aligned rho:64
            !dir$ assume_aligned ier:64

            do i=1, t
               call davint(rhophi(:,t),absc,n,xlo,xup,ans,err)
               rho(i) = invs*ans
               ier(i) = err
              
            end do

       end subroutine raster_opacity_integral_r8


       subroutine raster_opacity_integral_omp_r4(invs,rhophi_x,rhophi_y,absc,n,t,xlo, &
                                               xup,rho_x,rho_y,ier_x,ier_y)

            !dir$ optimize:3
            !dir$ attributes code_align : 32 ::  raster_opacity_integral_omp_r4
            use quadpack, only : savint
            real(kind=sp),                      intent(in) :: invs
            real(kind=sp), dimension(1:n,t),    intent(in) :: rhophi_x
            real(kind=sp), dimension(1:n,t),    intent(in) :: rhophi_y
            real(kind=sp), dimension(1:n),      intent(in) :: absc
            integer(kind=i4),                   intent(in) :: n
            integer(kind=i4),                   intent(in) :: t
            real(kind=sp),                      intent(in) :: xlo
            real(kind=sp),                      intent(in) :: xup
            real(kind=sp),    dimension(t),     intent(out):: rho_x
            real(kind=sp),    dimension(t),     intent(out):: rho_y
            integer(kind=i4), dimension(t),     intent(out):: ier_x
            integer(kind=i4), dimension(t),     intent(out):: ier_y
            real(kind=sp) :: ans_x,ans_y
            integer(kind=i4)  :: i
            integer(kind=i4)  :: err_x,err_y 
            !dir$ assume_aligned rhophi_x:64
            !dir$ assume_aligned rhophi_y:64
            !dir$ assume_aligned absc:64
            !dir$ assume_aligned rho_x:64
            !dir$ assume_aligned rho_y:64


!$omp parallel do schedule(runtime)default(none) &
!$omp private(i,ans_x,err_x,ans_y,err_y)         &
!$omp shared(t,rhophi_x,rhophi_y,ansc,n,xlo,xup) &
!$omp shared(rho_x,rho_y,ier_x,ier_y)
            do i=1, t
               call savint(rhophi_x(:,t),absc,n,xlo,xup,ans_x,err_x)
               rho_x(i) = invs*ans_x
               ier_x(i) = err_x
               call savint(rhophi_y(:,t),absc,n,xlo,xup,ans_y,err_y)
               rho_y(i) = invs*ans_y
               ier_y(i) = err_y
            end do
!$omp end parallel do
       end subroutine raster_opacity_integral_omp_r4


       subroutine raster_opacity_integral_r4(invs,rhophi,absc,n,t,xlo, &
                                               xup,rho,ier_x)

            !dir$ optimize:3
            !dir$ attributes code_align : 32 ::  raster_opacity_integral_r4
            use quadpack, only : savint
            real(kind=sp),                      intent(in) :: invs
            real(kind=sp), dimension(1:n,t),    intent(in) :: rhophi
            real(kind=sp), dimension(1:n),      intent(in) :: absc
            integer(kind=i4),                   intent(in) :: n
            integer(kind=i4),                   intent(in) :: t
            real(kind=sp),                      intent(in) :: xlo
            real(kind=sp),                      intent(in) :: xup
            real(kind=sp),    dimension(t),     intent(out):: rho
            integer(kind=i4), dimension(t),     intent(out):: ier
         
            real(kind=sp) :: ans
            integer(kind=i4)  :: i
            integer(kind=i4)  :: err
            !dir$ assume_aligned rhophi:64
            !dir$ assume_aligned absc:64
            !dir$ assume_aligned rho:64
            !dir$ assume_aligned ier:64

            do i=1, t
               call savint(rhophi(:,t),absc,n,xlo,xup,ans,err)
               rho(i) = invs*ans
               ier(i) = err
              
            end do

       end subroutine raster_opacity_integral_r4

              
 
       subroutine cos_series_unroll_16x_r4(om0,n,coss,k)
           !dir$ optimize:3
           !dir$ attributes code_align : 32 ::  cos_series_unroll_16x_r4
           !dir$ attributes forceinline ::  cos_series_unroll_16x_r4
           !dir$ attributes optimization_parameter:"target_arch=skylake-avx512" :: cos_series_unroll_16x_r4
           real(kind=sp),                 intent(in)  :: om0
           integer(kind=i4),              intent(in)  :: n
           real(kind=sp), dimension(1:n), intent(out) :: coss
           real(kind=sp),                 intent(in)  :: k
           real(kind=sp) :: arg0,arg1,arg2,arg3,arg4,arg,arg6,arg7
           real(kind=sp) :: arg8,arg9,arg10,arg11,arg12,arg13,arg14,arg15
           real(kind=sp) :: t0,t1,t2,t3,t4,t5,t6,t7
           real(kind=sp) :: t8,t9,t10,t11,t12,t13,t14,t15
           real(kind=sp) :: kom0
           integer(kind=i4) :: i,m,m1
           kom0 = k*om0
           m = mod(n,16)
           if(m /= 0) then
              do i=1, m
                 t0      = real(i,kind=sp)
                 arg0    = kom0*t0
                 coss(i) = cos(arg0)
              end do
              if(n<16) return
           end if
           m1 = m+1
            !dir$ assume_aligned coss:64
            !dir$ vector aligned
            !dir$ ivdep
            !dir$ vector vectorlength(4)
            !dir$ vector multiple_gather_scatter_by_shuffles 
            !dir$ vector always
           do i=m1,n,16
              t0        = real(i+0,kind=sp)
              arg0      = kom0*t0
              coss(i+0) = cos(arg0)
              t1        = real(i+1,kind=sp)
              arg1      = kom0*t1
              coss(i+1) = cos(arg1)
              t2        = real(i+2,kind=sp)
              arg2      = kom0*t2
              coss(i+2) = cos(arg2)
              t3        = real(i+3,kind=sp)
              arg3      = kom0*t3
              coss(i+3) = cos(arg3)
              t4        = real(i+4,kind=sp)
              arg4      = kom0*t4
              coss(i+4) = cos(arg4)
              t5        = real(i+5,kind=sp)
              arg5      = kom0*t5
              coss(i+5) = cos(arg5)
              t6        = real(i+6,kind=sp)
              arg6      = kom0*t6
              coss(i+6) = cos(arg6)
              t7        = real(i+7,kind=sp)
              arg7      = kom0*t7
              coss(i+7) = cos(arg7)
              t8        = real(i+8,kind=sp)
              arg8      = kom0*t8
              coss(i+8) = cos(arg8)
              t9        = real(i+9,kind=sp)
              arg9      = kom0*t9
              coss(i+9) = cos(arg9)
              t10       = real(i+10,kind=sp)
              arg10     = kom0*t10
              coss(i+10)= cos(arg10)
              t11       = real(i+11,kind=sp)
              arg11     = kom0*t11
              coss(i+11)= cos(arg11)
              t12       = real(i+12,kind=sp)
              arg12     = kom0*t12
              coss(i+12)= cos(arg12)
              t13       = real(i+13,kind=sp)
              arg13     = kom0*t13
              coss(i+13)= cos(arg13)
              t14       = real(i+14,kind=sp)
              arg14     = kom0*t14
              coss(i+14)= cos(arg14)
              t15       = real(i+15,kind=sp)
              arg15     = kom0*t15
              coss(i+15)= cos(arg15)
           end do
           
       end subroutine cos_series_unroll_16x_r4


       subroutine cos_series_unroll_16x_r8(om0,n,coss,k)
           !dir$ optimize:3
           !dir$ attributes code_align : 32 ::  cos_series_unroll_16x_r8
           !dir$ attributes forceinline ::  cos_series_unroll_16x_r8
           !dir$ attributes optimization_parameter:"target_arch=skylake-avx512" :: cos_series_unroll_16x_r8
           real(kind=dp),                 intent(in)  :: om0
           integer(kind=i4),              intent(in)  :: n
           real(kind=dp), dimension(1:n), intent(out) :: coss
           real(kind=dp),                 intent(in)  :: k
           real(kind=dp) :: arg0,arg1,arg2,arg3,arg4,arg,arg6,arg7
           real(kind=dp) :: arg8,arg9,arg10,arg11,arg12,arg13,arg14,arg15
           real(kind=dp) :: t0,t1,t2,t3,t4,t5,t6,t7
           real(kind=dp) :: t8,t9,t10,t11,t12,t13,t14,t15
           real(kind=dp) :: kom0
           integer(kind=i4) :: i,m,m1
           kom0 = k*om0
           m = mod(n,16)
           if(m /= 0) then
              do i=1, m
                 t0      = real(i,kind=sp)
                 arg0    = kom0*t0
                 coss(i) = cos(arg0)
              end do
              if(n<16) return
           end if
           m1 = m+1
            !dir$ assume_aligned coss:64
            !dir$ vector aligned
            !dir$ ivdep
            !dir$ vector vectorlength(8)
            !dir$ vector multiple_gather_scatter_by_shuffles 
            !dir$ vector always
           do i=m1,n,16
              t0        = real(i+0,kind=dp)
              arg0      = kom0*t0
              coss(i+0) = cos(arg0)
              t1        = real(i+1,kind=dp)
              arg1      = kom0*t1
              coss(i+1) = cos(arg1)
              t2        = real(i+2,kind=dp)
              arg2      = kom0*t2
              coss(i+2) = cos(arg2)
              t3        = real(i+3,kind=dp)
              arg3      = kom0*t3
              coss(i+3) = cos(arg3)
              t4        = real(i+4,kind=dp)
              arg4      = kom0*t4
              coss(i+4) = cos(arg4)
              t5        = real(i+5,kind=dp)
              arg5      = kom0*t5
              coss(i+5) = cos(arg5)
              t6        = real(i+6,kind=dp)
              arg6      = kom0*t6
              coss(i+6) = cos(arg6)
              t7        = real(i+7,kind=dp)
              arg7      = kom0*t7
              coss(i+7) = cos(arg7)
              t8        = real(i+8,kind=dp)
              arg8      = kom0*t8
              coss(i+8) = cos(arg8)
              t9        = real(i+9,kind=dp)
              arg9      = kom0*t9
              coss(i+9) = cos(arg9)
              t10       = real(i+10,kind=dp)
              arg10     = kom0*t10
              coss(i+10)= cos(arg10)
              t11       = real(i+11,kind=dp)
              arg11     = kom0*t11
              coss(i+11)= cos(arg11)
              t12       = real(i+12,kind=dp)
              arg12     = kom0*t12
              coss(i+12)= cos(arg12)
              t13       = real(i+13,kind=dp)
              arg13     = kom0*t13
              coss(i+13)= cos(arg13)
              t14       = real(i+14,kind=dp)
              arg14     = kom0*t14
              coss(i+14)= cos(arg14)
              t15       = real(i+15,kind=dp)
              arg15     = kom0*t15
              coss(i+15)= cos(arg15)
           end do
           
       end subroutine cos_series_unroll_16x_r8


      subroutine cos_series_unroll_8x_r4(om0,n,coss,k)
           !dir$ optimize:3
           !dir$ attributes code_align : 32 ::  cos_series_unroll_8x_r4
           !dir$ attributes forceinline ::  cos_series_unroll_8x_r4
           !dir$ attributes optimization_parameter:"target_arch=skylake-avx512" :: cos_series_unroll_8x_r4
           real(kind=sp),                 intent(in)  :: om0
           integer(kind=i4),              intent(in)  :: n
           real(kind=sp), dimension(1:n), intent(out) :: coss
           real(kind=sp),                 intent(in)  :: k
           real(kind=sp) :: arg0,arg1,arg2,arg3,arg4,arg,arg6,arg7
           real(kind=sp) :: t0,t1,t2,t3,t4,t5,t6,t7
           real(kind=sp) :: kom0
           integer(kind=i4) :: i,m,m1
           kom0 = k*om0
           m = mod(n,8)
           if(m /= 0) then
              do i=1, m
                 t0      = real(i,kind=sp)
                 arg0    = kom0*t0
                 coss(i) = cos(arg0)
              end do
              if(n<8) return
           end if
           m1 = m+1
            !dir$ assume_aligned coss:64
            !dir$ vector aligned
            !dir$ ivdep
            !dir$ vector vectorlength(4)
            !dir$ vector multiple_gather_scatter_by_shuffles 
            !dir$ vector always
           do i=m1,n,8
              t0        = real(i+0,kind=sp)
              arg0      = kom0*t0
              coss(i+0) = cos(arg0)
              t1        = real(i+1,kind=sp)
              arg1      = kom0*t1
              coss(i+1) = cos(arg1)
              t2        = real(i+2,kind=sp)
              arg2      = kom0*t2
              coss(i+2) = cos(arg2)
              t3        = real(i+3,kind=sp)
              arg3      = kom0*t3
              coss(i+3) = cos(arg3)
              t4        = real(i+4,kind=sp)
              arg4      = kom0*t4
              coss(i+4) = cos(arg4)
              t5        = real(i+5,kind=sp)
              arg5      = kom0*t5
              coss(i+5) = cos(arg5)
              t6        = real(i+6,kind=sp)
              arg6      = kom0*t6
              coss(i+6) = cos(arg6)
              t7        = real(i+7,kind=sp)
              arg7      = kom0*t7
              coss(i+7) = cos(arg7)
          end do
           
       end subroutine cos_series_unroll_8x_r4


       subroutine cos_series_unroll_8x_r8(om0,n,coss,k)
           !dir$ optimize:3
           !dir$ attributes code_align : 32 ::  cos_series_unroll_8x_r8
           !dir$ attributes forceinline ::  cos_series_unroll_8x_r8
           !dir$ attributes optimization_parameter:"target_arch=skylake-avx512" :: cos_series_unroll_8x_r8
           real(kind=dp),                 intent(in)  :: om0
           integer(kind=i4),              intent(in)  :: n
           real(kind=dp), dimension(1:n), intent(out) :: coss
           real(kind=dp),                 intent(in)  :: k
           real(kind=dp) :: arg0,arg1,arg2,arg3,arg4,arg,arg6,arg7
           real(kind=dp) :: t0,t1,t2,t3,t4,t5,t6,t7
           real(kind=dp) :: kom0
           integer(kind=i4) :: i,m,m1
           kom0 = k*om0
           m = mod(n,8)
           if(m /= 0) then
              do i=1, m
                 t0      = real(i,kind=sp)
                 arg0    = kom0*t0
                 coss(i) = cos(arg0)
              end do
              if(n<8) return
           end if
           m1 = m+1
            !dir$ assume_aligned coss:64
            !dir$ vector aligned
            !dir$ ivdep
            !dir$ vector vectorlength(8)
            !dir$ vector multiple_gather_scatter_by_shuffles 
            !dir$ vector always
           do i=m1,n,8
              t0        = real(i+0,kind=dp)
              arg0      = kom0*t0
              coss(i+0) = cos(arg0)
              t1        = real(i+1,kind=dp)
              arg1      = kom0*t1
              coss(i+1) = cos(arg1)
              t2        = real(i+2,kind=dp)
              arg2      = kom0*t2
              coss(i+2) = cos(arg2)
              t3        = real(i+3,kind=dp)
              arg3      = kom0*t3
              coss(i+3) = cos(arg3)
              t4        = real(i+4,kind=dp)
              arg4      = kom0*t4
              coss(i+4) = cos(arg4)
              t5        = real(i+5,kind=dp)
              arg5      = kom0*t5
              coss(i+5) = cos(arg5)
              t6        = real(i+6,kind=dp)
              arg6      = kom0*t6
              coss(i+6) = cos(arg6)
              t7        = real(i+7,kind=dp)
              arg7      = kom0*t7
              coss(i+7) = cos(arg7)
          end do
     
       end subroutine cos_series_unroll_8x_r8


       subroutine cos_series_unroll_4x_r4(om0,n,coss,k)
           !dir$ optimize:3
           !dir$ attributes code_align : 32 ::  cos_series_unroll_4x_r4
           !dir$ attributes forceinline ::  cos_series_unroll_4x_r4
           !dir$ attributes optimization_parameter:"target_arch=skylake-avx512" :: cos_series_unroll_4x_r4
           real(kind=sp),                 intent(in)  :: om0
           integer(kind=i4),              intent(in)  :: n
           real(kind=sp), dimension(1:n), intent(out) :: coss
           real(kind=sp),                 intent(in)  :: k
           real(kind=sp) :: arg0,arg1,arg2,arg3
           real(kind=sp) :: t0,t1,t2,t3
           real(kind=sp) :: kom0
           integer(kind=i4) :: i,m,m1
           kom0 = k*om0
           m = mod(n,4)
           if(m /= 0) then
              do i=1, m
                 t0      = real(i,kind=sp)
                 arg0    = kom0*t0
                 coss(i) = cos(arg0)
              end do
              if(n<4) return
           end if
           m1 = m+1
            !dir$ assume_aligned coss:64
            !dir$ vector aligned
            !dir$ ivdep
            !dir$ vector vectorlength(4)
            !dir$ vector multiple_gather_scatter_by_shuffles 
            !dir$ vector always
           do i=m1,n,4
              t0        = real(i+0,kind=sp)
              arg0      = kom0*t0
              coss(i+0) = cos(arg0)
              t1        = real(i+1,kind=sp)
              arg1      = kom0*t1
              coss(i+1) = cos(arg1)
              t2        = real(i+2,kind=sp)
              arg2      = kom0*t2
              coss(i+2) = cos(arg2)
              t3        = real(i+3,kind=sp)
              arg3      = kom0*t3
              coss(i+3) = cos(arg3)
           end do
           
       end subroutine cos_series_unroll_4x_r4


       subroutine cos_series_unroll_4x_r8(om0,n,coss,k)
           !dir$ optimize:3
           !dir$ attributes code_align : 32 ::  cos_series_unroll_4x_r8
           !dir$ attributes forceinline ::  cos_series_unroll_4x_r8
           !dir$ attributes optimization_parameter:"target_arch=skylake-avx512" :: cos_series_unroll_4x_r8
           real(kind=dp),                 intent(in)  :: om0
           integer(kind=i4),              intent(in)  :: n
           real(kind=dp), dimension(1:n), intent(out) :: coss
           real(kind=dp),                 intent(in)  :: k
           real(kind=dp) :: arg0,arg1,arg2,arg3
           real(kind=dp) :: t0,t1,t2,t3
           real(kind=dp) :: kom0
           integer(kind=i4) :: i,m,m1
           kom0 = k*om0
           m = mod(n,4)
           if(m /= 0) then
              do i=1, m
                 t0      = real(i,kind=sp)
                 arg0    = kom0*t0
                 coss(i) = cos(arg0)
              end do
              if(n<4) return
           end if
           m1 = m+1
            !dir$ assume_aligned coss:64
            !dir$ vector aligned
            !dir$ ivdep
            !dir$ vector vectorlength(8)
            !dir$ vector multiple_gather_scatter_by_shuffles 
            !dir$ vector always
           do i=m1,n,4
              t0        = real(i+0,kind=dp)
              arg0      = kom0*t0
              coss(i+0) = cos(arg0)
              t1        = real(i+1,kind=dp)
              arg1      = kom0*t1
              coss(i+1) = cos(arg1)
              t2        = real(i+2,kind=dp)
              arg2      = kom0*t2
              coss(i+2) = cos(arg2)
              t3        = real(i+3,kind=dp)
              arg3      = kom0*t3
              coss(i+3) = cos(arg3)
            
          end do
     
       end subroutine cos_series_unroll_4x_r8


        subroutine cos_series_unroll_2x_r4(om0,n,coss,k)
           !dir$ optimize:3
           !dir$ attributes code_align : 32 ::  cos_series_unroll_2x_r4
           !dir$ attributes forceinline ::  cos_series_unroll_2x_r4
           !dir$ attributes optimization_parameter:"target_arch=skylake-avx512" :: cos_series_unroll_2x_r4
           real(kind=sp),                 intent(in)  :: om0
           integer(kind=i4),              intent(in)  :: n
           real(kind=sp), dimension(1:n), intent(out) :: coss
           real(kind=sp),                 intent(in)  :: k
           real(kind=sp) :: arg0,arg1
           real(kind=sp) :: t0,t1
           real(kind=sp) :: kom0
           integer(kind=i4) :: i,m,m1
           kom0 = k*om0
           m = mod(n,2)
           if(m /= 0) then
              do i=1, m
                 t0      = real(i,kind=sp)
                 arg0    = kom0*t0
                 coss(i) = cos(arg0)
              end do
              if(n<2) return
           end if
           m1 = m+1
            !dir$ assume_aligned coss:64
            !dir$ vector aligned
            !dir$ ivdep
            !dir$ vector vectorlength(4)
            !dir$ vector multiple_gather_scatter_by_shuffles 
            !dir$ vector always
           do i=m1,n,2
              t0        = real(i+0,kind=sp)
              arg0      = kom0*t0
              coss(i+0) = cos(arg0)
              t1        = real(i+1,kind=sp)
              arg1      = kom0*t1
              coss(i+1) = cos(arg1)
           end do
           
       end subroutine cos_series_unroll_2x_r4


       subroutine cos_series_unroll_2x_r8(om0,n,coss,k)
           !dir$ optimize:3
           !dir$ attributes code_align : 32 ::  cos_series_unroll_2x_r8
           !dir$ attributes forceinline ::  cos_series_unroll_2x_r8
           !dir$ attributes optimization_parameter:"target_arch=skylake-avx512" :: cos_series_unroll_2x_r8
           real(kind=dp),                 intent(in)  :: om0
           integer(kind=i4),              intent(in)  :: n
           real(kind=dp), dimension(1:n), intent(out) :: coss
           real(kind=dp),                 intent(in)  :: k
           real(kind=dp) :: arg0,arg1
           real(kind=dp) :: t0,t1
           real(kind=dp) :: kom0
           integer(kind=i4) :: i,m,m1
           kom0 = k*om0
           m = mod(n,2)
           if(m /= 0) then
              do i=1, m
                 t0      = real(i,kind=sp)
                 arg0    = kom0*t0
                 coss(i) = cos(arg0)
              end do
              if(n<2) return
           end if
           m1 = m+1
            !dir$ assume_aligned coss:64
            !dir$ vector aligned
            !dir$ ivdep
            !dir$ vector vectorlength(8)
            !dir$ vector multiple_gather_scatter_by_shuffles 
            !dir$ vector always
           do i=m1,n,2
              t0        = real(i+0,kind=dp)
              arg0      = kom0*t0
              coss(i+0) = cos(arg0)
              t1        = real(i+1,kind=dp)
              arg1      = kom0*t1
              coss(i+1) = cos(arg1)
                       
          end do
     
       end subroutine cos_series_unroll_2x_r8


       


      

       !==========================================================================================
       
         subroutine sin_series_unroll_16x_r4(om0,n,sins,k)
           !dir$ optimize:3
           !dir$ attributes code_align : 32 ::  sin_series_unroll_16x_r4
           !dir$ attributes forceinline ::  sin_series_unroll_16x_r4
           !dir$ attributes optimization_parameter:"target_arch=skylake-avx512" :: sin_series_unroll_16x_r4
           real(kind=sp),                 intent(in)  :: om0
           integer(kind=i4),              intent(in)  :: n
           real(kind=sp), dimension(1:n), intent(out) :: sins
           real(kind=sp),                 intent(in)  :: k
           real(kind=sp) :: arg0,arg1,arg2,arg3,arg4,arg,arg6,arg7
           real(kind=sp) :: arg8,arg9,arg10,arg11,arg12,arg13,arg14,arg15
           real(kind=sp) :: t0,t1,t2,t3,t4,t5,t6,t7
           real(kind=sp) :: t8,t9,t10,t11,t12,t13,t14,t15
           real(kind=sp) :: kom0
           integer(kind=i4) :: i,m,m1
           kom0 = k*om0
           m = mod(n,16)
           if(m /= 0) then
              do i=1, m
                 t0        = real(i+0,kind=sp)
                 arg0      = kom0*t0
                 sins(i+0) = sin(arg0)
              end do
              if(n<16) return
           end if
           m1 = m+1
            !dir$ assume_aligned sins:64
            !dir$ vector aligned
            !dir$ ivdep
            !dir$ vector vectorlength(4)
            !dir$ vector multiple_gather_scatter_by_shuffles 
            !dir$ vector always
           do i=m1,n,16
              t0        = real(i+0,kind=sp)
              arg0      = kom0*t0
              sins(i+0) = sin(arg0)
              t1        = real(i+1,kind=sp)
              arg1      = kom0*t1
              sins(i+1) = sin(arg1)
              t2        = real(i+2,kind=sp)
              arg2      = kom0*t2
              sins(i+2) = sin(arg2)
              t3        = real(i+3,kind=sp)
              arg3      = kom0*t3
              sins(i+3) = sin(arg3)
              t4        = real(i+4,kind=sp)
              arg4      = kom0*t4
              sins(i+4) = sin(arg4)
              t5        = real(i+5,kind=sp)
              arg5      = kom0*t5
              sins(i+5) = sin(arg5)
              t6        = real(i+6,kind=sp)
              arg6      = kom0*t6
              sins(i+6) = sin(arg6)
              t7        = real(i+7,kind=sp)
              arg7      = kom0*t7
              sins(i+7) = sin(arg7)
              t8        = real(i+8,kind=sp)
              arg8      = kom0*t8
              sins(i+8) = sin(arg8)
              t9        = real(i+9,kind=sp)
              arg9      = kom0*t9
              sins(i+9) = sin(arg9)
              t10       = real(i+10,kind=sp)
              arg10     = kom0*t10
              sins(i+10)= sin(arg10)
              t11       = real(i+11,kind=sp)
              arg11     = kom0*t11
              sins(i+11)= sin(arg11)
              t12       = real(i+12,kind=sp)
              arg12     = kom0*t12
              sins(i+12)= sin(arg12)
              t13       = real(i+13,kind=sp)
              arg13     = kom0*t13
              sins(i+13)= sin(arg13)
              t14       = real(i+14,kind=sp)
              arg14     = kom0*t14
              sins(i+14)= sin(arg14)
              t15       = real(i+15,kind=sp)
              arg15     = kom0*t15
              sins(i+15)= sin(arg15)
           end do
          
       end subroutine sin_series_unroll_16x_r4


       subroutine sin_series_unroll_16x_r8(om0,n,sins,k)
           !dir$ optimize:3
           !dir$ attributes code_align : 32 ::  sin_series_unroll_16x_r8
           !dir$ attributes forceinline ::  sin_series_unroll_16x_r8
           !dir$ attributes optimization_parameter:"target_arch=skylake-avx512" :: sin_series_unroll_16x_r8
           real(kind=dp),                 intent(in)  :: om0
           integer(kind=i4),              intent(in)  :: n
           real(kind=dp), dimension(1:n), intent(out) :: sins
           real(kind=dp),                 intent(in)  :: k
           real(kind=dp) :: arg0,arg1,arg2,arg3,arg4,arg,arg6,arg7
           real(kind=dp) :: arg8,arg9,arg10,arg11,arg12,arg13,arg14,arg15
           real(kind=dp) :: t0,t1,t2,t3,t4,t5,t6,t7
           real(kind=dp) :: t8,t9,t10,t11,t12,t13,t14,t15
           real(kind=dp) :: kom0
           integer(kind=i4) :: i,m,m1
           kom0 = k*om0
           m = mod(n,16)
           if(m /= 0) then
              do i=1, m
                 t0        = real(i,kind=dp)
                 arg0      = kom0*t0
                 sins(i)   = sin(arg0)
              end do
              if(n<16) return
           end if
           m1 = m+1
            !dir$ assume_aligned sins:64
            !dir$ vector aligned
            !dir$ ivdep
            !dir$ vector vectorlength(8)
            !dir$ vector multiple_gather_scatter_by_shuffles 
            !dir$ vector always
           do i=m1,n,16
              t0        = real(i+0,kind=dp)
              arg0      = kom0*t0
              sins(i+0) = sin(arg0)
              t1        = real(i+1,kind=dp)
              arg1      = kom0*t1
              sins(i+1) = sin(arg1)
              t2        = real(i+2,kind=dp)
              arg2      = kom0*t2
              sins(i+2) = sin(arg2)
              t3        = real(i+3,kind=dp)
              arg3      = kom0*t3
              sins(i+3) = sin(arg3)
              t4        = real(i+4,kind=dp)
              arg4      = kom0*t4
              sins(i+4) = sin(arg4)
              t5        = real(i+5,kind=dp)
              arg5      = kom0*t5
              sins(i+5) = sin(arg5)
              t6        = real(i+6,kind=dp)
              arg6      = kom0*t6
              sins(i+6) = sin(arg6)
              t7        = real(i+7,kind=dp)
              arg7      = kom0*t7
              sins(i+7) = sin(arg7)
              t8        = real(i+8,kind=dp)
              arg8      = kom0*t8
              sins(i+8) = sin(arg8)
              t9        = real(i+9,kind=dp)
              arg9      = kom0*t9
              sins(i+9) = sin(arg9)
              t10       = real(i+10,kind=dp)
              arg10     = kom0*t10
              sins(i+10)= sin(arg10)
              t11       = real(i+11,kind=dp)
              arg11     = kom0*t11
              sins(i+11)= sin(arg11)
              t12       = real(i+12,kind=dp)
              arg12     = kom0*t12
              sins(i+12)= sin(arg12)
              t13       = real(i+13,kind=dp)
              arg13     = kom0*t13
              sins(i+13)= sin(arg13)
              t14       = real(i+14,kind=dp)
              arg14     = kom0*t14
              sins(i+14)= sin(arg14)
              t15       = real(i+15,kind=dp)
              arg15     = kom0*t15
              sins(i+15)= sin(arg15)
           end do
          
       end subroutine sin_series_unroll_16x_r8


      




       subroutine sin_series_unroll_8x_r4(om0,n,sins,k)
           !dir$ optimize:3
           !dir$ attributes code_align : 32 ::  sin_series_unroll_8x_r4
           !dir$ attributes forceinline ::  sin_series_unroll_8x_r4
           !dir$ attributes optimization_parameter:"target_arch=skylake-avx512" :: sin_series_unroll_8x_r4
           real(kind=sp),                 intent(in)  :: om0
           integer(kind=i4),              intent(in)  :: n
           real(kind=sp), dimension(1:n), intent(out) :: sins
           real(kind=sp),                 intent(in)  :: k
           real(kind=sp) :: arg0,arg1,arg2,arg3,arg4,arg,arg6,arg7
           real(kind=sp) :: t0,t1,t2,t3,t4,t5,t6,t7
           real(kind=sp) :: kom0
           integer(kind=i4) :: i,m,m1
           kom0 = k*om0
           m = mod(n,8)
           if(m /= 0) then
              do i=1, m
                 t0        = real(i,kind=sp)
                 arg0      = kom0*t0
                 sins(i)   = sin(arg0)
              end do
              if(n<8) return
           end if
           m1 = m+1
            !dir$ assume_aligned coss:64
            !dir$ vector aligned
            !dir$ ivdep
            !dir$ vector vectorlength(4)
            !dir$ vector multiple_gather_scatter_by_shuffles 
            !dir$ vector always
           do i=1,m1,8
              t0        = real(i+0,kind=sp)
              arg0      = kom0*t0
              sins(i+0) = sin(arg0)
              t1        = real(i+1,kind=sp)
              arg1      = kom0*t1
              sins(i+1) = sin(arg1)
              t2        = real(i+2,kind=sp)
              arg2      = kom0*t2
              sins(i+2) = sin(arg2)
              t3        = real(i+3,kind=sp)
              arg3      = kom0*t3
              sins(i+3) = sin(arg3)
              t4        = real(i+4,kind=sp)
              arg4      = kom0*t4
              sins(i+4) = sin(arg4)
              t5        = real(i+5,kind=sp)
              arg5      = kom0*t5
              sins(i+5) = sin(arg5)
              t6        = real(i+6,kind=sp)
              arg6      = kom0*t6
              sins(i+6) = sin(arg6)
              t7        = real(i+7,kind=sp)
              arg7      = kom0*t7
              sins(i+7) = sin(arg7)
           end do
           
       end subroutine sin_series_unroll_8x_r4
  

       subroutine sin_series_unroll_8x_r8(om0,n,sins,k)
           !dir$ optimize:3
           !dir$ attributes code_align : 32 ::  sin_series_unroll_8x_r8
           !dir$ attributes forceinline ::  sin_series_unroll_8x_r8
           !dir$ attributes optimization_parameter:"target_arch=skylake-avx512" :: sin_series_unroll_8x_r8
           real(kind=dp),                 intent(in)  :: om0
           integer(kind=i4),              intent(in)  :: n
           real(kind=dp), dimension(1:n), intent(out) :: sins
           real(kind=dp),                 intent(in)  :: k
           real(kind=dp) :: arg0,arg1,arg2,arg3,arg4,arg,arg6,arg7
           real(kind=dp) :: t0,t1,t2,t3,t4,t5,t6,t7
           real(kind=dp) :: kom0
           integer(kind=i4) :: i,m,m1
           kom0 = k*om0
           m = mod(n,8)
           if(m /= 0) then
              do i=1, m
                 t0        = real(i,kind=dp)
                 arg0      = kom0*t0
                 sins(i)   = sin(arg0)
              end do
              if(n<8) return
           end if
           m1 = m+1
            !dir$ assume_aligned coss:64
            !dir$ vector aligned
            !dir$ ivdep
            !dir$ vector vectorlength(8)
            !dir$ vector multiple_gather_scatter_by_shuffles 
            !dir$ vector always
           do i=1,m1,8
              t0        = real(i+0,kind=dp)
              arg0      = kom0*t0
              sins(i+0) = sin(arg0)
              t1        = real(i+1,kind=dp)
              arg1      = kom0*t1
              sins(i+1) = sin(arg1)
              t2        = real(i+2,kind=dp)
              arg2      = kom0*t2
              sins(i+2) = sin(arg2)
              t3        = real(i+3,kind=dp)
              arg3      = kom0*t3
              sins(i+3) = sin(arg3)
              t4        = real(i+4,kind=dp)
              arg4      = kom0*t4
              sins(i+4) = sin(arg4)
              t5        = real(i+5,kind=dp)
              arg5      = kom0*t5
              sins(i+5) = sin(arg5)
              t6        = real(i+6,kind=dp)
              arg6      = kom0*t6
              sins(i+6) = sin(arg6)
              t7        = real(i+7,kind=dp)
              arg7      = kom0*t7
              sins(i+7) = sin(arg7)
           end do
           
       end subroutine sin_series_unroll_8x_r8
  

       subroutine sin_series_unroll_4x_r4(om0,n,sins,k)
           !dir$ optimize:3
           !dir$ attributes code_align : 32 ::  sin_series_unroll_8x_r4
           !dir$ attributes forceinline ::  sin_series_unroll_8x_r4
           !dir$ attributes optimization_parameter:"target_arch=skylake-avx512" :: sin_series_unroll_8x_r4
           real(kind=sp),                 intent(in)  :: om0
           integer(kind=i4),              intent(in)  :: n
           real(kind=sp), dimension(1:n), intent(out) :: sins
           real(kind=sp),                 intent(in)  :: k
           real(kind=sp) :: arg0,arg1,arg2,arg3
           real(kind=sp) :: t0,t1,t2,t3,t4
           real(kind=sp) :: kom0
           integer(kind=i4) :: i,m,m1
           kom0 = k*om0
           m = mod(n,4)
           if(m /= 0) then
              do i=1, m
                 t0        = real(i,kind=sp)
                 arg0      = kom0*t0
                 sins(i)   = sin(arg0)
              end do
              if(n<4) return
           end if
           m1 = m+1
            !dir$ assume_aligned coss:64
            !dir$ vector aligned
            !dir$ ivdep
            !dir$ vector vectorlength(4)
            !dir$ vector multiple_gather_scatter_by_shuffles 
            !dir$ vector always
           do i=1,m1,4
              t0        = real(i+0,kind=sp)
              arg0      = kom0*t0
              sins(i+0) = sin(arg0)
              t1        = real(i+1,kind=sp)
              arg1      = kom0*t1
              sins(i+1) = sin(arg1)
              t2        = real(i+2,kind=sp)
              arg2      = kom0*t2
              sins(i+2) = sin(arg2)
              t3        = real(i+3,kind=sp)
              arg3      = kom0*t3
              sins(i+3) = sin(arg3)
           end do
           
       end subroutine sin_series_unroll_4x_r4


       subroutine sin_series_unroll_4x_r8(om0,n,sins,k)
           !dir$ optimize:3
           !dir$ attributes code_align : 32 ::  sin_series_unroll_8x_r8
           !dir$ attributes forceinline ::  sin_series_unroll_8x_r8
           !dir$ attributes optimization_parameter:"target_arch=skylake-avx512" :: sin_series_unroll_8x_r8
           real(kind=dp),                 intent(in)  :: om0
           integer(kind=i4),              intent(in)  :: n
           real(kind=dp), dimension(1:n), intent(out) :: sins
           real(kind=dp),                 intent(in)  :: k
           real(kind=dp) :: arg0,arg1,arg2,arg3
           real(kind=dp) :: t0,t1,t2,t3,t4
           real(kind=dp) :: kom0
           integer(kind=i4) :: i,m,m1
           kom0 = k*om0
           m = mod(n,4)
           if(m /= 0) then
              do i=1, m
                 t0        = real(i,kind=dp)
                 arg0      = kom0*t0
                 sins(i)   = sin(arg0)
              end do
              if(n<4) return
           end if
           m1 = m+1
            !dir$ assume_aligned coss:64
            !dir$ vector aligned
            !dir$ ivdep
            !dir$ vector vectorlength(4)
            !dir$ vector multiple_gather_scatter_by_shuffles 
            !dir$ vector always
           do i=1,m1,4
              t0        = real(i+0,kind=dp)
              arg0      = kom0*t0
              sins(i+0) = sin(arg0)
              t1        = real(i+1,kind=dp)
              arg1      = kom0*t1
              sins(i+1) = sin(arg1)
              t2        = real(i+2,kind=dp)
              arg2      = kom0*t2
              sins(i+2) = sin(arg2)
              t3        = real(i+3,kind=dp)
              arg3      = kom0*t3
              sins(i+3) = sin(arg3)
           end do
           
       end subroutine sin_series_unroll_4x_r8


       
       subroutine sin_series_unroll_2x_r4(om0,n,sins,k)
           !dir$ optimize:3
           !dir$ attributes code_align : 32 ::  sin_series_unroll_2x_r4
           !dir$ attributes forceinline ::  sin_series_unroll_2x_r4
           !dir$ attributes optimization_parameter:"target_arch=skylake-avx512" :: sin_series_unroll_2x_r4
           real(kind=sp),                 intent(in)  :: om0
           integer(kind=i4),              intent(in)  :: n
           real(kind=sp), dimension(1:n), intent(out) :: sins
           real(kind=sp),                 intent(in)  :: k
           real(kind=sp) :: arg0,arg1
           real(kind=sp) :: t0,t1,t2
           real(kind=sp) :: kom0
           integer(kind=i4) :: i,m,m1
           kom0 = k*om0
           m = mod(n,2)
           if(m /= 0) then
              do i=1, m
                 t0        = real(i,kind=sp)
                 arg0      = kom0*t0
                 sins(i)   = sin(arg0)
              end do
              if(n<2) return
           end if
           m1 = m+1
            !dir$ assume_aligned coss:64
            !dir$ vector aligned
            !dir$ ivdep
            !dir$ vector vectorlength(4)
            !dir$ vector multiple_gather_scatter_by_shuffles 
            !dir$ vector always
           do i=1,m1,2
              t0        = real(i+0,kind=sp)
              arg0      = kom0*t0
              sins(i+0) = sin(arg0)
              t1        = real(i+1,kind=sp)
              arg1      = kom0*t1
              sins(i+1) = sin(arg1)
             
           end do
           
       end subroutine sin_series_unroll_2x_r4


       subroutine sin_series_unroll_2x_r8(om0,n,sins,k)
           !dir$ optimize:3
           !dir$ attributes code_align : 32 ::  sin_series_unroll_2x_r8
           !dir$ attributes forceinline ::  sin_series_unroll_2x_r8
           !dir$ attributes optimization_parameter:"target_arch=skylake-avx512" :: sin_series_unroll_2x_r8
           real(kind=dp),                 intent(in)  :: om0
           integer(kind=i4),              intent(in)  :: n
           real(kind=dp), dimension(1:n), intent(out) :: sins
           real(kind=dp),                 intent(in)  :: k
           real(kind=dp) :: arg0,arg1
           real(kind=dp) :: t0,t1,t2
           real(kind=dp) :: kom0
           integer(kind=i4) :: i,m,m1
           kom0 = k*om0
           m = mod(n,2)
           if(m /= 0) then
              do i=1, m
                 t0        = real(i,kind=dp)
                 arg0      = kom0*t0
                 sins(i)   = sin(arg0)
              end do
              if(n<2) return
           end if
           m1 = m+1
            !dir$ assume_aligned coss:64
            !dir$ vector aligned
            !dir$ ivdep
            !dir$ vector vectorlength(4)
            !dir$ vector multiple_gather_scatter_by_shuffles 
            !dir$ vector always
           do i=1,m1,2
              t0        = real(i+0,kind=dp)
              arg0      = kom0*t0
              sins(i+0) = sin(arg0)
              t1        = real(i+1,kind=dp)
              arg1      = kom0*t1
              sins(i+1) = sin(arg1)
             
           end do
           
       end subroutine sin_series_unroll_2x_r8
     

         
       !Спектр модулированного потока излучения можно вычислить
       !с помощью прямого преобразования Фурье
       ! Last formula, p. 181
       subroutine radiation_flux_spectrum(Phi_in,Phi_out,dim_len,data_len,status)
           !dir$ optimize:3
           !dir$ attributes code_align : 32 ::  radiation_flux_spectrum
           use mkl_dfti
           use mkl_fft_wrappers, only : create_desc_r_c_1D,  &
                                        exec_fft_r_c_1D
           real(kind=dp),    dimension(data_len),  intent(in)  :: Phi_in
           complex(kind=sp), dimension(data_len),  intent(out) :: Phi_out
           integer(kind=i4),                       intent(in)  :: dim_len
           integer(kind=i4),                       intent(in)  :: data_len
           integer(kind=i4),                       intent(out) :: status
           type(DFTI_DESCRIPTOR), pointer :: handle
           logical(kind=i4), automatic :: callstack
           callstack = .true.
           call create_desc_r_c_1D(handle,dim_len,data_len,callstack,status)
           if(0 == status) then
              call exec_fft_r_c_1D(handle,Phi_in,Phi_out,data_len,1,callstack,status)
           end if
        end subroutine radiation_flux_spectrum


        ! форма импульса потока излучения описывается,
        ! например, косинус-квадратной зависимостью
        ! Formula 3, p. 184
        subroutine squared_cos_flux_unroll_16x_r4(Phi0t,Phi0,n,tin)
           !dir$ optimize:3
           !dir$ attributes code_align : 32 ::  squared_cos_flux_unroll_16x_r4
           !dir$ attributes forceinline ::   squared_cos_flux_unroll_16x_r4
           !dir$ attributes optimization_parameter:"target_arch=skylake-avx512" ::  squared_cos_flux_unroll_16x_r4
           
           real(kind=sp), dimension(1:n),  intent(out) :: Phi0t
           real(kind=sp),                  intent(in)  :: Phi0 !radiation flux of constant intensity
           integer(kind=i4),               intent(in)  :: n
           real(kind=sp),                  intent(in)  :: tin  ! pulse length
           integer(kind=i4) :: i,m,m1
           real(kind=sp), parameter :: hpi = 1.57079632679489661923132169164_sp
           real(kind=sp), automatic :: tin2,t0,t1,t2,t3,t4,t5,t6,t7
           real(kind=sp), automatic :: t8,t9,t10,t11,t12,t13,t14,t15
           real(kind=sp), automatic :: arg0,arg1,arg2,arg3,arg4,arg5,arg6,arg7
           real(kind=sp), automatic :: arg8,arg9,arg10,arg11,arg12,arg13,arg14,arg15
           real(kind=sp), automatic :: c0,c1,c2,c3,c4,c5,c6,c7
           real(kind=sp), automatic :: c8,c9,c10,c11,c12,c13,c14,c15
           tin2 = 0.5_sp*tin
           m    = mod(n,16)
           if(m /= 0) then
              do i=1, m
                 t0         = real(i+0,kind=sp)
                 arg0       = hpi*t0/tin2
                 c0         = cos(arg0)
                 Phi0t(i+0) = c0*c0
              end do
              if(n<16) return
            end if
            m1 = m+1
           !dir$ assume_aligned Phi0t:64
           !dir$ vector aligned
           !dir$ ivdep
           !dir$ vector vectorlength(4)
           !dir$ vector multiple_gather_scatter_by_shuffles 
           !dir$ vector always
           do i=1,m1,16
              t0         = real(i+0,kind=sp)
              arg0       = hpi*t0/tin2
              c0         = cos(arg0)
              Phi0t(i+0) = c0*c0
              t1         = real(i+1,kind=sp)
              arg1       = hpi*t1/tin2
              c1         = cos(arg1)
              Phi0t(i+1) = c1*c1
              t2         = real(i+2,kind=sp)
              arg2       = hpi*t2/tin2
              c2         = cos(arg2)
              Phi0t(i+2) = c2*c2
              t3         = real(i+3,kind=sp)
              arg3       = hpi*t3/tin2
              c3         = cos(arg3)
              Phi0t(i+3) = c3*c3
              t4         = real(i+4,kind=sp)
              arg4       = hpi*t4/tin2
              c4         = cos(arg4)
              Phi0t(i+4) = c4*c4
              t5         = real(i+5,kind=sp)
              arg5       = hpi*t5/tin2
              c5         = cos(arg5)
              Phi0t(i+5) = c5*c5
              t6         = real(i+6,kind=sp)
              arg6       = hpi*t6/tin2
              c6         = cos(arg6)
              Phi0t(i+6) = c6*c6
              t7         = real(i+7,kind=sp)
              arg7       = hpi*t7/tin2
              c7         = cos(arg7)
              Phi0t(i+7) = c7*c7
              t8         = real(i+8,kind=sp)
              arg8       = hpi*t8/tin2
              c8         = cos(arg8)
              Phi0t(i+8) = c8*c8
              t9         = real(i+9,kind=sp)
              arg9       = hpi*t9/tin2
              c9         = cos(arg9)
              Phi0t(i+9) = c9*c9
              t10        = real(i+10,kind=sp)
              arg10      = hpi*t10/tin2
              c10        = cos(arg10)
              Phi0t(i+10)= c10*c10
              t11        = real(i+11,kind=sp)
              arg11      = hpi*t11/tin2
              c11        = cos(arg11)
              Phi0t(i+11)= c11*c11
              t12        = real(i+12,kind=sp)
              arg12      = hpi*t12/tin2
              c12        = cos(arg12)
              Phi0t(i+12)= c12*c12
              t13        = real(i+13,kind=sp)
              arg13      = hpi*t13/tin2
              c13        = cos(arg13)
              Phi0t(i+13)= c13*c13
              t14        = real(i+14,kind=sp)
              arg14      = hpi*t14/tin2
              c14        = cos(arg14)
              Phi0t(i+14)= c14*c14
              t15        = real(i+15,kind=sp)
              arg15      = hpi*t15/tin2
              c15        = cos(arg15)
              Phi0t(i+15)= c15*c15
           end do
         
        end subroutine squared_cos_flux_unroll_16x_r4


        subroutine squared_cos_flux_unroll_16x_r8(Phi0t,Phi0,n,tin)
           !dir$ optimize:3
           !dir$ attributes code_align : 32 ::  squared_cos_flux_unroll_16x_r8
           !dir$ attributes forceinline ::   squared_cos_flux_unroll_16x_r8
           !dir$ attributes optimization_parameter:"target_arch=skylake-avx512" ::  squared_cos_flux_unroll_16x_r8
           
           real(kind=dp), dimension(1:n),  intent(out) :: Phi0t
           real(kind=dp),                  intent(in)  :: Phi0 !radiation flux of constant intensity
           integer(kind=i4),               intent(in)  :: n
           real(kind=dp),                  intent(in)  :: tin  ! pulse length
           integer(kind=i4) :: i,m,m1
           real(kind=dp), parameter :: hpi = 1.57079632679489661923132169164_dp
           real(kind=dp), automatic :: tin2,t0,t1,t2,t3,t4,t5,t6,t7
           real(kind=dp), automatic :: t8,t9,t10,t11,t12,t13,t14,t15
           real(kind=dp), automatic :: arg0,arg1,arg2,arg3,arg4,arg5,arg6,arg7
           real(kind=dp), automatic :: arg8,arg9,arg10,arg11,arg12,arg13,arg14,arg15
           real(kind=dp), automatic :: c0,c1,c2,c3,c4,c5,c6,c7
           real(kind=dp), automatic :: c8,c9,c10,c11,c12,c13,c14,c15
           tin2 = 0.5_dp*tin
           m    = mod(n,16)
           if(m /= 0) then
              do i=1, m
                 t0         = real(i+0,kind=dp)
                 arg0       = hpi*t0/tin2
                 c0         = cos(arg0)
                 Phi0t(i+0) = c0*c0
              end do
              if(n<16) return
            end if
            m1 = m+1
           !dir$ assume_aligned Phi0t:64
           !dir$ vector aligned
           !dir$ ivdep
           !dir$ vector vectorlength(8)
           !dir$ vector multiple_gather_scatter_by_shuffles 
           !dir$ vector always
           do i=1,m1,16
              t0         = real(i+0,kind=dp)
              arg0       = hpi*t0/tin2
              c0         = cos(arg0)
              Phi0t(i+0) = c0*c0
              t1         = real(i+1,kind=dp)
              arg1       = hpi*t1/tin2
              c1         = cos(arg1)
              Phi0t(i+1) = c1*c1
              t2         = real(i+2,kind=dp)
              arg2       = hpi*t2/tin2
              c2         = cos(arg2)
              Phi0t(i+2) = c2*c2
              t3         = real(i+3,kind=dp)
              arg3       = hpi*t3/tin2
              c3         = cos(arg3)
              Phi0t(i+3) = c3*c3
              t4         = real(i+4,kind=dp)
              arg4       = hpi*t4/tin2
              c4         = cos(arg4)
              Phi0t(i+4) = c4*c4
              t5         = real(i+5,kind=dp)
              arg5       = hpi*t5/tin2
              c5         = cos(arg5)
              Phi0t(i+5) = c5*c5
              t6         = real(i+6,kind=dp)
              arg6       = hpi*t6/tin2
              c6         = cos(arg6)
              Phi0t(i+6) = c6*c6
              t7         = real(i+7,kind=dp)
              arg7       = hpi*t7/tin2
              c7         = cos(arg7)
              Phi0t(i+7) = c7*c7
              t8         = real(i+8,kind=dp)
              arg8       = hpi*t8/tin2
              c8         = cos(arg8)
              Phi0t(i+8) = c8*c8
              t9         = real(i+9,kind=dp)
              arg9       = hpi*t9/tin2
              c9         = cos(arg9)
              Phi0t(i+9) = c9*c9
              t10        = real(i+10,kind=dp)
              arg10      = hpi*t10/tin2
              c10        = cos(arg10)
              Phi0t(i+10)= c10*c10
              t11        = real(i+11,kind=dp)
              arg11      = hpi*t11/tin2
              c11        = cos(arg11)
              Phi0t(i+11)= c11*c11
              t12        = real(i+12,kind=sp)
              arg12      = hpi*t12/tin2
              c12        = cos(arg12)
              Phi0t(i+12)= c12*c12
              t13        = real(i+13,kind=dp)
              arg13      = hpi*t13/tin2
              c13        = cos(arg13)
              Phi0t(i+13)= c13*c13
              t14        = real(i+14,kind=dp)
              arg14      = hpi*t14/tin2
              c14        = cos(arg14)
              Phi0t(i+14)= c14*c14
              t15        = real(i+15,kind=dp)
              arg15      = hpi*t15/tin2
              c15        = cos(arg15)
              Phi0t(i+15)= c15*c15
           end do
         
        end subroutine squared_cos_flux_unroll_16x_r8


       subroutine squared_cos_flux_unroll_8x_r4(Phi0t,Phi0,n,tin)
           !dir$ optimize:3
           !dir$ attributes code_align : 32 ::  squared_cos_flux_unroll_8x_r4
           !dir$ attributes forceinline ::   squared_cos_flux_unroll_8x_r4
           !dir$ attributes optimization_parameter:"target_arch=skylake-avx512" ::  squared_cos_flux_unroll_8x_r4
           
           real(kind=sp), dimension(1:n),  intent(out) :: Phi0t
           real(kind=sp),                  intent(in)  :: Phi0 !radiation flux of constant intensity
           integer(kind=i4),               intent(in)  :: n
           real(kind=sp),                  intent(in)  :: tin  ! pulse length
           integer(kind=i4) :: i,m,m1
           real(kind=sp), parameter :: hpi = 1.57079632679489661923132169164_sp
           real(kind=sp), automatic :: tin2,t0,t1,t2,t3,t4,t5,t6,t7
           real(kind=sp), automatic :: arg0,arg1,arg2,arg3,arg4,arg5,arg6,arg7
           real(kind=sp), automatic :: c0,c1,c2,c3,c4,c5,c6,c7
          
           tin2 = 0.5_sp*tin
           m    = mod(n,8)
           if(m /= 0) then
              do i=1, m
                 t0         = real(i+0,kind=sp)
                 arg0       = hpi*t0/tin2
                 c0         = cos(arg0)
                 Phi0t(i+0) = c0*c0
              end do
              if(n<8) return
            end if
            m1 = m+1
           !dir$ assume_aligned Phi0t:64
           !dir$ vector aligned
           !dir$ ivdep
           !dir$ vector vectorlength(4)
           !dir$ vector multiple_gather_scatter_by_shuffles 
           !dir$ vector always
           do i=1,m1,8
              t0         = real(i+0,kind=sp)
              arg0       = hpi*t0/tin2
              c0         = cos(arg0)
              Phi0t(i+0) = c0*c0
              t1         = real(i+1,kind=sp)
              arg1       = hpi*t1/tin2
              c1         = cos(arg1)
              Phi0t(i+1) = c1*c1
              t2         = real(i+2,kind=sp)
              arg2       = hpi*t2/tin2
              c2         = cos(arg2)
              Phi0t(i+2) = c2*c2
              t3         = real(i+3,kind=sp)
              arg3       = hpi*t3/tin2
              c3         = cos(arg3)
              Phi0t(i+3) = c3*c3
              t4         = real(i+4,kind=sp)
              arg4       = hpi*t4/tin2
              c4         = cos(arg4)
              Phi0t(i+4) = c4*c4
              t5         = real(i+5,kind=sp)
              arg5       = hpi*t5/tin2
              c5         = cos(arg5)
              Phi0t(i+5) = c5*c5
              t6         = real(i+6,kind=sp)
              arg6       = hpi*t6/tin2
              c6         = cos(arg6)
              Phi0t(i+6) = c6*c6
              t7         = real(i+7,kind=sp)
              arg7       = hpi*t7/tin2
              c7         = cos(arg7)
              Phi0t(i+7) = c7*c7
          end do
         
        end subroutine squared_cos_flux_unroll_8x_r4


        
        subroutine squared_cos_flux_unroll_8x_r8(Phi0t,Phi0,n,tin)
           !dir$ optimize:3
           !dir$ attributes code_align : 32 ::  squared_cos_flux_unroll_8x_r8
           !dir$ attributes forceinline ::   squared_cos_flux_unroll_8x_r8
           !dir$ attributes optimization_parameter:"target_arch=skylake-avx512" ::  squared_cos_flux_unroll_8x_r8
           
           real(kind=dp), dimension(1:n),  intent(out) :: Phi0t
           real(kind=dp),                  intent(in)  :: Phi0 !radiation flux of constant intensity
           integer(kind=i4),               intent(in)  :: n
           real(kind=dp),                  intent(in)  :: tin  ! pulse length
           integer(kind=i4) :: i,m,m1
           real(kind=dp), parameter :: hpi = 1.57079632679489661923132169164_dp
           real(kind=dp), automatic :: tin2,t0,t1,t2,t3,t4,t5,t6,t7
           real(kind=dp), automatic :: arg0,arg1,arg2,arg3,arg4,arg5,arg6,arg7
           real(kind=dp), automatic :: c0,c1,c2,c3,c4,c5,c6,c7
          
           tin2 = 0.5_dp*tin
           m    = mod(n,8)
           if(m /= 0) then
              do i=1, m
                 t0         = real(i+0,kind=dp)
                 arg0       = hpi*t0/tin2
                 c0         = cos(arg0)
                 Phi0t(i+0) = c0*c0
              end do
              if(n<8) return
            end if
            m1 = m+1
           !dir$ assume_aligned Phi0t:64
           !dir$ vector aligned
           !dir$ ivdep
           !dir$ vector vectorlength(8)
           !dir$ vector multiple_gather_scatter_by_shuffles 
           !dir$ vector always
           do i=1,m1,8
              t0         = real(i+0,kind=dp)
              arg0       = hpi*t0/tin2
              c0         = cos(arg0)
              Phi0t(i+0) = c0*c0
              t1         = real(i+1,kind=dp)
              arg1       = hpi*t1/tin2
              c1         = cos(arg1)
              Phi0t(i+1) = c1*c1
              t2         = real(i+2,kind=dp)
              arg2       = hpi*t2/tin2
              c2         = cos(arg2)
              Phi0t(i+2) = c2*c2
              t3         = real(i+3,kind=dp)
              arg3       = hpi*t3/tin2
              c3         = cos(arg3)
              Phi0t(i+3) = c3*c3
              t4         = real(i+4,kind=dp)
              arg4       = hpi*t4/tin2
              c4         = cos(arg4)
              Phi0t(i+4) = c4*c4
              t5         = real(i+5,kind=dp)
              arg5       = hpi*t5/tin2
              c5         = cos(arg5)
              Phi0t(i+5) = c5*c5
              t6         = real(i+6,kind=dp)
              arg6       = hpi*t6/tin2
              c6         = cos(arg6)
              Phi0t(i+6) = c6*c6
              t7         = real(i+7,kind=dp)
              arg7       = hpi*t7/tin2
              c7         = cos(arg7)
              Phi0t(i+7) = c7*c7
          end do
         
        end subroutine squared_cos_flux_unroll_8x_r8



        subroutine squared_cos_flux_unroll_4x_r4(Phi0t,Phi0,n,tin)
           !dir$ optimize:3
           !dir$ attributes code_align : 32 ::  squared_cos_flux_unroll_4x_r4
           !dir$ attributes forceinline ::   squared_cos_flux_unroll_4x_r4
           !dir$ attributes optimization_parameter:"target_arch=skylake-avx512" ::  squared_cos_flux_unroll_4x_r4
           
           real(kind=sp), dimension(1:n),  intent(out) :: Phi0t
           real(kind=sp),                  intent(in)  :: Phi0 !radiation flux of constant intensity
           integer(kind=i4),               intent(in)  :: n
           real(kind=sp),                  intent(in)  :: tin  ! pulse length
           integer(kind=i4) :: i,m,m1
           real(kind=sp), parameter :: hpi = 1.57079632679489661923132169164_sp
           real(kind=sp), automatic :: tin2,t0,t1,t2,t3
           real(kind=sp), automatic :: arg0,arg1,arg2,arg3
           real(kind=sp), automatic :: c0,c1,c2,c3
          
           tin2 = 0.5_sp*tin
           m    = mod(n,4)
           if(m /= 0) then
              do i=1, m
                 t0         = real(i+0,kind=sp)
                 arg0       = hpi*t0/tin2
                 c0         = cos(arg0)
                 Phi0t(i+0) = c0*c0
              end do
              if(n<4) return
            end if
            m1 = m+1
           !dir$ assume_aligned Phi0t:64
           !dir$ vector aligned
           !dir$ ivdep
           !dir$ vector vectorlength(4)
           !dir$ vector multiple_gather_scatter_by_shuffles 
           !dir$ vector always
           do i=1,m1,4
              t0         = real(i+0,kind=sp)
              arg0       = hpi*t0/tin2
              c0         = cos(arg0)
              Phi0t(i+0) = c0*c0
              t1         = real(i+1,kind=sp)
              arg1       = hpi*t1/tin2
              c1         = cos(arg1)
              Phi0t(i+1) = c1*c1
              t2         = real(i+2,kind=sp)
              arg2       = hpi*t2/tin2
              c2         = cos(arg2)
              Phi0t(i+2) = c2*c2
              t3         = real(i+3,kind=sp)
              arg3       = hpi*t3/tin2
              c3         = cos(arg3)
              Phi0t(i+3) = c3*c3
           end do
         
        end subroutine squared_cos_flux_unroll_4x_r4


       subroutine squared_cos_flux_unroll_4x_r8(Phi0t,Phi0,n,tin)
           !dir$ optimize:3
           !dir$ attributes code_align : 32 ::  squared_cos_flux_unroll_4x_r8
           !dir$ attributes forceinline ::   squared_cos_flux_unroll_4x_r8
           !dir$ attributes optimization_parameter:"target_arch=skylake-avx512" ::  squared_cos_flux_unroll_4x_r8
           
           real(kind=dp), dimension(1:n),  intent(out) :: Phi0t
           real(kind=dp),                  intent(in)  :: Phi0 !radiation flux of constant intensity
           integer(kind=i4),               intent(in)  :: n
           real(kind=dp),                  intent(in)  :: tin  ! pulse length
           integer(kind=i4) :: i,m,m1
           real(kind=dp), parameter :: hpi = 1.57079632679489661923132169164_dp
           real(kind=dp), automatic :: tin2,t0,t1,t2,t3
           real(kind=dp), automatic :: arg0,arg1,arg2,arg3
           real(kind=dp), automatic :: c0,c1,c2,c3
          
           tin2 = 0.5_dp*tin
           m    = mod(n,4)
           if(m /= 0) then
              do i=1, m
                 t0         = real(i+0,kind=dp)
                 arg0       = hpi*t0/tin2
                 c0         = cos(arg0)
                 Phi0t(i+0) = c0*c0
              end do
              if(n<4) return
            end if
            m1 = m+1
           !dir$ assume_aligned Phi0t:64
           !dir$ vector aligned
           !dir$ ivdep
           !dir$ vector vectorlength(8)
           !dir$ vector multiple_gather_scatter_by_shuffles 
           !dir$ vector always
           do i=1,m1,4
              t0         = real(i+0,kind=dp)
              arg0       = hpi*t0/tin2
              c0         = cos(arg0)
              Phi0t(i+0) = c0*c0
              t1         = real(i+1,kind=dp)
              arg1       = hpi*t1/tin2
              c1         = cos(arg1)
              Phi0t(i+1) = c1*c1
              t2         = real(i+2,kind=dp)
              arg2       = hpi*t2/tin2
              c2         = cos(arg2)
              Phi0t(i+2) = c2*c2
              t3         = real(i+3,kind=dp)
              arg3       = hpi*t3/tin2
              c3         = cos(arg3)
              Phi0t(i+3) = c3*c3
           end do
         
        end subroutine squared_cos_flux_unroll_4x_r8


        
       subroutine squared_cos_flux_unroll_2x_r4(Phi0t,Phi0,n,tin)
           !dir$ optimize:3
           !dir$ attributes code_align : 32 ::  squared_cos_flux_unroll_2x_r4
           !dir$ attributes forceinline ::   squared_cos_flux_unroll_2x_r4
           !dir$ attributes optimization_parameter:"target_arch=skylake-avx512" ::  squared_cos_flux_unroll_2x_r4
           
           real(kind=sp), dimension(1:n),  intent(out) :: Phi0t
           real(kind=sp),                  intent(in)  :: Phi0 !radiation flux of constant intensity
           integer(kind=i4),               intent(in)  :: n
           real(kind=sp),                  intent(in)  :: tin  ! pulse length
           integer(kind=i4) :: i,m,m1
           real(kind=sp), parameter :: hpi = 1.57079632679489661923132169164_sp
           real(kind=sp), automatic :: tin2,t0,t1
           real(kind=sp), automatic :: arg0,arg1
           real(kind=sp), automatic :: c0,c1
          
           tin2 = 0.5_sp*tin
           m    = mod(n,2)
           if(m /= 0) then
              do i=1, m
                 t0         = real(i+0,kind=sp)
                 arg0       = hpi*t0/tin2
                 c0         = cos(arg0)
                 Phi0t(i+0) = c0*c0
              end do
              if(n<2) return
            end if
            m1 = m+1
           !dir$ assume_aligned Phi0t:64
           !dir$ vector aligned
           !dir$ ivdep
           !dir$ vector vectorlength(4)
           !dir$ vector multiple_gather_scatter_by_shuffles 
           !dir$ vector always
           do i=1,m1,2
              t0         = real(i+0,kind=sp)
              arg0       = hpi*t0/tin2
              c0         = cos(arg0)
              Phi0t(i+0) = c0*c0
              t1         = real(i+1,kind=sp)
              arg1       = hpi*t1/tin2
              c1         = cos(arg1)
              Phi0t(i+1) = c1*c1
           end do
         
        end subroutine squared_cos_flux_unroll_2x_r4


        
        subroutine squared_cos_flux_unroll_2x_r8(Phi0t,Phi0,n,tin)
           !dir$ optimize:3
           !dir$ attributes code_align : 32 ::  squared_cos_flux_unroll_2x_r8
           !dir$ attributes forceinline ::   squared_cos_flux_unroll_2x_r8
           !dir$ attributes optimization_parameter:"target_arch=skylake-avx512" ::  squared_cos_flux_unroll_2x_r8
           
           real(kind=dp), dimension(1:n),  intent(out) :: Phi0t
           real(kind=dp),                  intent(in)  :: Phi0 !radiation flux of constant intensity
           integer(kind=i4),               intent(in)  :: n
           real(kind=dp),                  intent(in)  :: tin  ! pulse length
           integer(kind=i4) :: i,m,m1
           real(kind=dp), parameter :: hpi = 1.57079632679489661923132169164_dp
           real(kind=dp), automatic :: tin2,t0,t1
           real(kind=dp), automatic :: arg0,arg1
           real(kind=dp), automatic :: c0,c1
          
           tin2 = 0.5_dp*tin
           m    = mod(n,2)
           if(m /= 0) then
              do i=1, m
                 t0         = real(i+0,kind=dp)
                 arg0       = hpi*t0/tin2
                 c0         = cos(arg0)
                 Phi0t(i+0) = c0*c0
              end do
              if(n<2) return
            end if
            m1 = m+1
           !dir$ assume_aligned Phi0t:64
           !dir$ vector aligned
           !dir$ ivdep
           !dir$ vector vectorlength(8)
           !dir$ vector multiple_gather_scatter_by_shuffles 
           !dir$ vector always
           do i=1,m1,2
              t0         = real(i+0,kind=dp)
              arg0       = hpi*t0/tin2
              c0         = cos(arg0)
              Phi0t(i+0) = c0*c0
              t1         = real(i+1,kind=dp)
              arg1       = hpi*t1/tin2
              c1         = cos(arg1)
              Phi0t(i+1) = c1*c1
           end do
         
        end subroutine squared_cos_flux_unroll_2x_r8

       
       


        subroutine const_flux_spectr_unroll_16x_r4(Phi0f,Phi0,freq,n,T)
           !dir$ optimize:3
           !dir$ attributes code_align : 32 ::  const_flux_spectr_unroll_16x_r4
           !dir$ attributes forceinline ::   const_flux_spectr_unroll_16x_r4
           !dir$ attributes optimization_parameter:"target_arch=skylake-avx512" ::  const_flux_spectr_unroll_16x_r4
           real(kind=sp),  dimension(1:n), intent(out) :: Phi0f
           real(kind=sp),                  intent(in)  :: Phi0
           real(kind=sp),  dimension(1:n), intent(in)  :: freq
           integer(kind=i4),               intent(in)  :: n
           real(kind=sp),                  intent(in)  :: T
           real(kind=sp), parameter :: twopi = 6.283185307179586476925286766559_sp
           real(kind=sp) :: arg0,arg1,arg2,arg3,arg4,arg5,arg6,arg7
           real(kind=sp) :: arg8,arg9,arg10,arg11,arg12,arg13,arg14,arg15
           real(kind=sp) :: f0,f1,f2,f3,f4,f5,f6,f7
           real(kind=sp) :: f8,f9,f10,f11,f12,f13,f14,f15
           real(kind=sp) :: c0,c1,c2,c3,c4,c5,c6,c7
           real(kind=sp) :: c8,c9,c10,c11,c12,c13,c14,c15
           real(kind=sp) :: sa0,sa1,sa2,sa3,sa4,sa,sa6,sa7
           real(kind=sp) :: sa8,sa9,sa10,sa11,sa12,sa13,sa14,sa15
           real(kind=sp), automatic :: hT,Phi0T
           integer(kind=i4) :: i,m,m1
           hT    = 0.5_sp*T
           Phi0T = Phi0*hT
           m = mod(n,16)
           if(m /= 0) then
              do i=1, m
                 f0         = freq(i+0)
                 c0         = twopi*f0*hT
                 sa0        = sin(c0)/c0
                 arg0       = 1.0_sp-(f0*hT*f0*hT)
                 Phi0f(i+0) = Phi0T*(sa0/arg0)
              end do
              if(n<16) return
           end if
           m1 = m+1
           !dir$ assume_aligned Phi0f:64
           !dir$ assume_aligned freq:64
           !dir$ vector aligned
           !dir$ ivdep
           !dir$ vector vectorlength(4)
           !dir$ vector multiple_gather_scatter_by_shuffles 
           !dir$ vector always
           do i=1,m1,16
              f0         = freq(i+0)
              c0         = twopi*f0*hT
              sa0        = sin(c0)/c0
              arg0       = 1.0_sp-(f0*hT*f0*hT)
              Phi0f(i+0) = Phi0T*(sa0/arg0)
              f1         = freq(i+1)
              c1         = twopi*f1*hT
              sa1        = sin(c1)/c1
              arg1       = 1.0_sp-(f1*hT*f1*hT)
              Phi0f(i+1) = Phi0T*(sa1/arg1)
              f2         = freq(i+2)
              c2         = twopi*f2*hT
              sa2        = sin(c2)/c2
              arg2       = 1.0_sp-(f2*hT*f2*hT)
              Phi0f(i+2) = Phi0T*(sa2/arg2)
              f3         = freq(i+3)
              c3         = twopi*f3*hT
              sa3        = sin(c3)/c3
              arg3       = 1.0_sp-(f3*hT*f3*hT)
              Phi0f(i+3) = Phi0T*(sa3/arg3)
              f4         = freq(i+4)
              c4         = twopi*f4*hT
              sa4        = sin(c4)/c4
              arg4       = 1.0_sp-(f4*hT*f4*hT)
              Phi0f(i+4) = Phi0T*(sa4/arg4)
              f5         = freq(i+5)
              c5         = twopi*f5*hT
              sa5        = sin(c5)/c5
              arg5       = 1.0_sp-(f5*hT*f5*hT)
              Phi0f(i+5) = Phi0T*(sa5/arg5)
              f6         = freq(i+6)
              c6         = twopi*f6*hT
              sa6        = sin(c6)/c6
              arg6       = 1.0_sp-(f6*hT*f6*hT)
              Phi0f(i+6) = Phi0T*(sa6/arg6)
              f7         = freq(i+7)
              c7         = twopi*f7*hT
              sa7        = sin(c7)/c7
              arg7       = 1.0_sp-(f7*hT*f7*hT)
              Phi0f(i+7) = Phi0T*(sa7/arg7)
              f8         = freq(i+8)
              c8         = twopi*f8*hT
              sa8        = sin(c8)/c8
              arg8       = 1.0_sp-(f8*hT*f8*hT)
              Phi0f(i+8) = Phi0T*(sa8/arg8)
              f9         = freq(i+9)
              c9         = twopi*f9*hT
              sa9        = sin(c9)/c9
              arg9       = 1.0_sp-(f9*hT*f9*hT)
              Phi0f(i+9) = Phi0T*(sa9/arg9)
              f10        = freq(i+10)
              c10        = twopi*f10*hT
              sa10       = sin(c10)/c10
              arg10      = 1.0_sp-(f10*hT*f10*hT)
              Phi0f(i+10)= Phi0T*(sa10/arg10)
              f11        = freq(i+11)
              c11        = twopi*f11*hT
              sa11       = sin(c11)/c11
              arg11      = 1.0_sp-(f11*hT*f11*hT)
              Phi0f(i+11)= Phi0T*(sa11/arg11)
              f12        = freq(i+12)
              c12        = twopi*f12*hT
              sa12       = sin(c12)/c12
              arg12      = 1.0_sp-(f12*hT*f12*hT)
              Phi0f(i+12)= Phi0T*(sa12/arg12)
              f13        = freq(i+13)
              c13        = twopi*f13*hT
              sa13       = sin(c13)/c13
              arg13      = 1.0_sp-(f13*hT*f13*hT)
              Phi0f(i+13) = Phi0T*(sa13/arg13)
              f14        = freq(i+14)
              c14        = twopi*f14*hT
              sa14       = sin(c14)/c14
              arg14      = 1.0_sp-(f14*hT*f14*hT)
              Phi0f(i+14)= Phi0T*(sa14/arg14)
              f15        = freq(i+15)
              c15        = twopi*f15*hT
              sa15       = sin(c15)/c15
              arg15      = 1.0_sp-(f15*hT*f15*hT)
              Phi0f(i+15)= Phi0T*(sa15/arg15)
           end do
          
       end subroutine const_flux_spectr_unroll_16x_r4


       subroutine const_flux_spectr_unroll_16x_r8(Phi0f,Phi0,freq,n,T)
           !dir$ optimize:3
           !dir$ attributes code_align : 32 ::  const_flux_spectr_unroll_16x_r8
           !dir$ attributes forceinline ::   const_flux_spectr_unroll_16x_r8
           !dir$ attributes optimization_parameter:"target_arch=skylake-avx512" ::  const_flux_spectr_unroll_16x_r8
           real(kind=dp),  dimension(1:n), intent(out) :: Phi0f
           real(kind=dp),                  intent(in)  :: Phi0
           real(kind=dp),  dimension(1:n), intent(in)  :: freq
           integer(kind=i4),               intent(in)  :: n
           real(kind=dp),                  intent(in)  :: T
           real(kind=dp), parameter :: twopi = 6.283185307179586476925286766559_dp
           real(kind=dp) :: arg0,arg1,arg2,arg3,arg4,arg5,arg6,arg7
           real(kind=dp) :: arg8,arg9,arg10,arg11,arg12,arg13,arg14,arg15
           real(kind=dp) :: f0,f1,f2,f3,f4,f5,f6,f7
           real(kind=dp) :: f8,f9,f10,f11,f12,f13,f14,f15
           real(kind=dp) :: c0,c1,c2,c3,c4,c5,c6,c7
           real(kind=dp) :: c8,c9,c10,c11,c12,c13,c14,c15
           real(kind=dp) :: sa0,sa1,sa2,sa3,sa4,sa,sa6,sa7
           real(kind=dp) :: sa8,sa9,sa10,sa11,sa12,sa13,sa14,sa15
           real(kind=dp), automatic :: hT,Phi0T
           integer(kind=i4) :: i,m,m1
           hT    = 0.5_dp*T
           Phi0T = Phi0*hT
           m = mod(n,16)
           if(m /= 0) then
              do i=1, m
                 f0         = freq(i+0)
                 c0         = twopi*f0*hT
                 sa0        = sin(c0)/c0
                 arg0       = 1.0_dp-(f0*hT*f0*hT)
                 Phi0f(i+0) = Phi0T*(sa0/arg0)
              end do
              if(n<16) return
           end if
           m1 = m+1
           !dir$ assume_aligned Phi0f:64
           !dir$ assume_aligned freq:64
           !dir$ vector aligned
           !dir$ ivdep
           !dir$ vector vectorlength(8)
           !dir$ vector multiple_gather_scatter_by_shuffles 
           !dir$ vector always
           do i=1,m1,16
              f0         = freq(i+0)
              c0         = twopi*f0*hT
              sa0        = sin(c0)/c0
              arg0       = 1.0_dp-(f0*hT*f0*hT)
              Phi0f(i+0) = Phi0T*(sa0/arg0)
              f1         = freq(i+1)
              c1         = twopi*f1*hT
              sa1        = sin(c1)/c1
              arg1       = 1.0_dp-(f1*hT*f1*hT)
              Phi0f(i+1) = Phi0T*(sa1/arg1)
              f2         = freq(i+2)
              c2         = twopi*f2*hT
              sa2        = sin(c2)/c2
              arg2       = 1.0_dp-(f2*hT*f2*hT)
              Phi0f(i+2) = Phi0T*(sa2/arg2)
              f3         = freq(i+3)
              c3         = twopi*f3*hT
              sa3        = sin(c3)/c3
              arg3       = 1.0_dp-(f3*hT*f3*hT)
              Phi0f(i+3) = Phi0T*(sa3/arg3)
              f4         = freq(i+4)
              c4         = twopi*f4*hT
              sa4        = sin(c4)/c4
              arg4       = 1.0_dp-(f4*hT*f4*hT)
              Phi0f(i+4) = Phi0T*(sa4/arg4)
              f5         = freq(i+5)
              c5         = twopi*f5*hT
              sa5        = sin(c5)/c5
              arg5       = 1.0_dp-(f5*hT*f5*hT)
              Phi0f(i+5) = Phi0T*(sa5/arg5)
              f6         = freq(i+6)
              c6         = twopi*f6*hT
              sa6        = sin(c6)/c6
              arg6       = 1.0_dp-(f6*hT*f6*hT)
              Phi0f(i+6) = Phi0T*(sa6/arg6)
              f7         = freq(i+7)
              c7         = twopi*f7*hT
              sa7        = sin(c7)/c7
              arg7       = 1.0_dp-(f7*hT*f7*hT)
              Phi0f(i+7) = Phi0T*(sa7/arg7)
              f8         = freq(i+8)
              c8         = twopi*f8*hT
              sa8        = sin(c8)/c8
              arg8       = 1.0_dp-(f8*hT*f8*hT)
              Phi0f(i+8) = Phi0T*(sa8/arg8)
              f9         = freq(i+9)
              c9         = twopi*f9*hT
              sa9        = sin(c9)/c9
              arg9       = 1.0_dp-(f9*hT*f9*hT)
              Phi0f(i+9) = Phi0T*(sa9/arg9)
              f10        = freq(i+10)
              c10        = twopi*f10*hT
              sa10       = sin(c10)/c10
              arg10      = 1.0_dp-(f10*hT*f10*hT)
              Phi0f(i+10)= Phi0T*(sa10/arg10)
              f11        = freq(i+11)
              c11        = twopi*f11*hT
              sa11       = sin(c11)/c11
              arg11      = 1.0_dp-(f11*hT*f11*hT)
              Phi0f(i+11)= Phi0T*(sa11/arg11)
              f12        = freq(i+12)
              c12        = twopi*f12*hT
              sa12       = sin(c12)/c12
              arg12      = 1.0_dp-(f12*hT*f12*hT)
              Phi0f(i+12)= Phi0T*(sa12/arg12)
              f13        = freq(i+13)
              c13        = twopi*f13*hT
              sa13       = sin(c13)/c13
              arg13      = 1.0_dp-(f13*hT*f13*hT)
              Phi0f(i+13) = Phi0T*(sa13/arg13)
              f14        = freq(i+14)
              c14        = twopi*f14*hT
              sa14       = sin(c14)/c14
              arg14      = 1.0_dp-(f14*hT*f14*hT)
              Phi0f(i+14)= Phi0T*(sa14/arg14)
              f15        = freq(i+15)
              c15        = twopi*f15*hT
              sa15       = sin(c15)/c15
              arg15      = 1.0_dp-(f15*hT*f15*hT)
              Phi0f(i+15)= Phi0T*(sa15/arg15)
           end do
          
       end subroutine const_flux_spectr_unroll_16x_r8

       
       subroutine const_flux_spectr_unroll_8x_r8(Phi0f,Phi0,freq,n,T)
           !dir$ optimize:3
           !dir$ attributes code_align : 32 ::  const_flux_spectr_unroll_8x_r8
           !dir$ attributes forceinline ::   const_flux_spectr_unroll_8x_r8
           !dir$ attributes optimization_parameter:"target_arch=skylake-avx512" ::  const_flux_spectr_unroll_8x_r8
           real(kind=dp),  dimension(1:n), intent(out) :: Phi0f
           real(kind=dp),                  intent(in)  :: Phi0
           real(kind=dp),  dimension(1:n), intent(in)  :: freq
           integer(kind=i4),               intent(in)  :: n
           real(kind=dp),                  intent(in)  :: T
           real(kind=dp), parameter :: twopi = 6.283185307179586476925286766559_dp
           real(kind=dp) :: arg0,arg1,arg2,arg3,arg4,arg5,arg6,arg7
           real(kind=dp) :: f0,f1,f2,f3,f4,f5,f6,f7
           real(kind=dp) :: c0,c1,c2,c3,c4,c5,c6,c7
           real(kind=dp) :: sa0,sa1,sa2,sa3,sa4,sa,sa6,sa7
           real(kind=dp), automatic :: hT,Phi0T
           integer(kind=i4) :: i,m,m1
           hT    = 0.5_dp*T
           Phi0T = Phi0*hT
           m = mod(n,8)
           if(m /= 0) then
              do i=1, m
                 f0         = freq(i+0)
                 c0         = twopi*f0*hT
                 sa0        = sin(c0)/c0
                 arg0       = 1.0_dp-(f0*hT*f0*hT)
                 Phi0f(i+0) = Phi0T*(sa0/arg0)
              end do
              if(n<8) return
           end if
           m1 = m+1
           !dir$ assume_aligned Phi0f:64
           !dir$ assume_aligned freq:64
           !dir$ vector aligned
           !dir$ ivdep
           !dir$ vector vectorlength(8)
           !dir$ vector multiple_gather_scatter_by_shuffles 
           !dir$ vector always
           do i=1,m1,8
              f0         = freq(i+0)
              c0         = twopi*f0*hT
              sa0        = sin(c0)/c0
              arg0       = 1.0_dp-(f0*hT*f0*hT)
              Phi0f(i+0) = Phi0T*(sa0/arg0)
              f1         = freq(i+1)
              c1         = twopi*f1*hT
              sa1        = sin(c1)/c1
              arg1       = 1.0_dp-(f1*hT*f1*hT)
              Phi0f(i+1) = Phi0T*(sa1/arg1)
              f2         = freq(i+2)
              c2         = twopi*f2*hT
              sa2        = sin(c2)/c2
              arg2       = 1.0_dp-(f2*hT*f2*hT)
              Phi0f(i+2) = Phi0T*(sa2/arg2)
              f3         = freq(i+3)
              c3         = twopi*f3*hT
              sa3        = sin(c3)/c3
              arg3       = 1.0_dp-(f3*hT*f3*hT)
              Phi0f(i+3) = Phi0T*(sa3/arg3)
              f4         = freq(i+4)
              c4         = twopi*f4*hT
              sa4        = sin(c4)/c4
              arg4       = 1.0_dp-(f4*hT*f4*hT)
              Phi0f(i+4) = Phi0T*(sa4/arg4)
              f5         = freq(i+5)
              c5         = twopi*f5*hT
              sa5        = sin(c5)/c5
              arg5       = 1.0_dp-(f5*hT*f5*hT)
              Phi0f(i+5) = Phi0T*(sa5/arg5)
              f6         = freq(i+6)
              c6         = twopi*f6*hT
              sa6        = sin(c6)/c6
              arg6       = 1.0_dp-(f6*hT*f6*hT)
              Phi0f(i+6) = Phi0T*(sa6/arg6)
              f7         = freq(i+7)
              c7         = twopi*f7*hT
              sa7        = sin(c7)/c7
              arg7       = 1.0_dp-(f7*hT*f7*hT)
              Phi0f(i+7) = Phi0T*(sa7/arg7)
          end do
          
       end subroutine const_flux_spectr_unroll_8x_r8


       subroutine const_flux_spectr_unroll_4x_r8(Phi0f,Phi0,freq,n,T)
           !dir$ optimize:3
           !dir$ attributes code_align : 32 ::  const_flux_spectr_unroll_4x_r8
           !dir$ attributes forceinline ::   const_flux_spectr_unroll_4x_r8
           !dir$ attributes optimization_parameter:"target_arch=skylake-avx512" ::  const_flux_spectr_unroll_4x_r8
           real(kind=dp),  dimension(1:n), intent(out) :: Phi0f
           real(kind=dp),                  intent(in)  :: Phi0
           real(kind=dp),  dimension(1:n), intent(in)  :: freq
           integer(kind=i4),               intent(in)  :: n
           real(kind=dp),                  intent(in)  :: T
           real(kind=dp), parameter :: twopi = 6.283185307179586476925286766559_dp
           real(kind=dp) :: arg0,arg1,arg2,arg3
           real(kind=dp) :: f0,f1,f2,f3
           real(kind=dp) :: c0,c1,c2,c3
           real(kind=dp) :: sa0,sa1,sa2,sa3
           real(kind=dp), automatic :: hT,Phi0T
           integer(kind=i4) :: i,m,m1
           hT    = 0.5_dp*T
           Phi0T = Phi0*hT
           m = mod(n,4)
           if(m /= 0) then
              do i=1, m
                 f0         = freq(i+0)
                 c0         = twopi*f0*hT
                 sa0        = sin(c0)/c0
                 arg0       = 1.0_dp-(f0*hT*f0*hT)
                 Phi0f(i+0) = Phi0T*(sa0/arg0)
              end do
              if(n<4) return
           end if
           m1 = m+1
           !dir$ assume_aligned Phi0f:64
           !dir$ assume_aligned freq:64
           !dir$ vector aligned
           !dir$ ivdep
           !dir$ vector vectorlength(8)
           !dir$ vector multiple_gather_scatter_by_shuffles 
           !dir$ vector always
           do i=1,m1,4
              f0         = freq(i+0)
              c0         = twopi*f0*hT
              sa0        = sin(c0)/c0
              arg0       = 1.0_dp-(f0*hT*f0*hT)
              Phi0f(i+0) = Phi0T*(sa0/arg0)
              f1         = freq(i+1)
              c1         = twopi*f1*hT
              sa1        = sin(c1)/c1
              arg1       = 1.0_dp-(f1*hT*f1*hT)
              Phi0f(i+1) = Phi0T*(sa1/arg1)
              f2         = freq(i+2)
              c2         = twopi*f2*hT
              sa2        = sin(c2)/c2
              arg2       = 1.0_dp-(f2*hT*f2*hT)
              Phi0f(i+2) = Phi0T*(sa2/arg2)
              f3         = freq(i+3)
              c3         = twopi*f3*hT
              sa3        = sin(c3)/c3
              arg3       = 1.0_dp-(f3*hT*f3*hT)
              Phi0f(i+3) = Phi0T*(sa3/arg3)
          end do
          
       end subroutine const_flux_spectr_unroll_4x_r8

       
       subroutine const_flux_spectr_unroll_2x_r8(Phi0f,Phi0,freq,n,T)
           !dir$ optimize:3
           !dir$ attributes code_align : 32 ::  const_flux_spectr_unroll_2x_r8
           !dir$ attributes forceinline ::   const_flux_spectr_unroll_2x_r8
           !dir$ attributes optimization_parameter:"target_arch=skylake-avx512" ::  const_flux_spectr_unroll_2x_r8
           real(kind=dp),  dimension(1:n), intent(out) :: Phi0f
           real(kind=dp),                  intent(in)  :: Phi0
           real(kind=dp),  dimension(1:n), intent(in)  :: freq
           integer(kind=i4),               intent(in)  :: n
           real(kind=dp),                  intent(in)  :: T
           real(kind=dp), parameter :: twopi = 6.283185307179586476925286766559_dp
           real(kind=dp) :: arg0,arg1
           real(kind=dp) :: f0,f1
           real(kind=dp) :: c0,c1
           real(kind=dp) :: sa0,sa1
           real(kind=dp), automatic :: hT,Phi0T
           integer(kind=i4) :: i,m,m1
           hT    = 0.5_dp*T
           Phi0T = Phi0*hT
           m = mod(n,4)
           if(m /= 0) then
              do i=1, m
                 f0         = freq(i+0)
                 c0         = twopi*f0*hT
                 sa0        = sin(c0)/c0
                 arg0       = 1.0_dp-(f0*hT*f0*hT)
                 Phi0f(i+0) = Phi0T*(sa0/arg0)
              end do
              if(n<2) return
           end if
           m1 = m+1
           !dir$ assume_aligned Phi0f:64
           !dir$ assume_aligned freq:64
           !dir$ vector aligned
           !dir$ ivdep
           !dir$ vector vectorlength(8)
           !dir$ vector multiple_gather_scatter_by_shuffles 
           !dir$ vector always
           do i=1,m1,2
              f0         = freq(i+0)
              c0         = twopi*f0*hT
              sa0        = sin(c0)/c0
              arg0       = 1.0_dp-(f0*hT*f0*hT)
              Phi0f(i+0) = Phi0T*(sa0/arg0)
              f1         = freq(i+1)
              c1         = twopi*f1*hT
              sa1        = sin(c1)/c1
              arg1       = 1.0_dp-(f1*hT*f1*hT)
              Phi0f(i+1) = Phi0T*(sa1/arg1)
            end do
          
       end subroutine const_flux_spectr_unroll_2x_r8

       

       

      
     
        !Идеальный гармонический модулятор
        !Formula 1,2 p. 187
        subroutine ideal_modulator_unroll_16x_r4(rhot_s,rhot_c,n,f0,phi0,rho0,rho1)
           !dir$ optimize:3
           !dir$ attributes code_align : 32 ::  ideal_modulator_unroll_16x_r4
           !dir$ attributes forceinline ::   ideal_modulator_unroll_16x_r4
           !dir$ attributes optimization_parameter:"target_arch=skylake-avx512" ::  ideal_modulator_unroll_16x_r4
           real(kind=sp), dimension(1:n), intent(out) :: rhot_s
           real(kind=sp), dimension(1:n), intent(out) :: rhot_c
           integer(kind=i4),              intent(in)  :: n
           real(kind=sp),                 intent(in)  :: f0
           real(kind=sp),                 intent(in)  :: phi0
           real(kind=sp),                 intent(in)  :: rho0
           real(kind=sp),                 intent(in)  :: rho1
           real(kind=sp), parameter :: twopi = 6.283185307179586476925286766559_sp
           real(kind=sp) :: t0,t1,t2,t3,t4,t5,t6,t7
           real(kind=sp) :: t8,t9,t10,t11,t12,t13,t14,t15
           real(kind=sp) :: s0,s1,s2,s3,s4,s5,s6,s7
           real(kind=sp) :: s8,s9,s10,s11,s12,s13,s14,s15
           real(kind=sp) :: c0,c1,c2,c3,c4,c5,c6,c7
           real(kind=sp) :: c8,c9,c10,c11,c12,c13,c14,c15
           real(kind=sp) :: psi0,psi1,psi2,psi3,psi4,psi5,psi6,psi7
           real(kind=sp) :: psi8,psi9,psi10,psi11,psi12,psi13,psi14,psi15
           real(kind=sp) :: om0
           integer(kind=i4) :: i,m,m1
           om0 = twopi*f0
           m=mod(n,16)
           if(m /= 0) then
              do i=1, m
                 t0        = real(i,kind=sp)
                 psi0      = om0*t0+phi0
                 s0        = rho0+rho1*sin(psi0)
                 rhot_s(i) = s0
                 c0        = rho0+rho1*cos(psi0)
                 rhot_c(i) = c0
              end do
              if(n<16) return
           end if
           m1 = m+1
           !dir$ assume_aligned rhot_s:64           
           !dir$ assume_aligned rhot_c:64
           !dir$ vector aligned
           !dir$ ivdep
           !dir$ vector vectorlength(4)
           !dir$ vector multiple_gather_scatter_by_shuffles 
           !dir$ vector always
           do i=1,m1,16
              t0          = real(i+0,kind=sp)
              psi0        = om0*t0+phi0
              s0          = rho0+rho1*sin(psi0)
              rhot_s(i+0) = s0
              c0          = rho0+rho1*cos(psi0)
              rhot_c(i+0) = c0
              t1          = real(i+1,kind=sp)
              psi1        = om0*t1+phi0
              s1          = rho0+rho1*sin(psi1)
              rhot_s(i+1) = s1
              c0          = rho0+rho1*cos(psi1)
              rhot_c(i+1) = c1
              t2          = real(i+2,kind=sp)
              psi2        = om0*t2+phi0
              s2          = rho0+rho1*sin(psi2)
              rhot_s(i+2) = s2
              c2          = rho0+rho1*cos(psi2)
              rhot_c(i+2) = c2
              t3          = real(i+3,kind=sp)
              psi3        = om0*t3+phi0
              s3          = rho0+rho1*sin(psi3)
              rhot_s(i+3) = s3
              c3          = rho0+rho1*cos(psi3)
              rhot_c(i+3) = c3
              t4          = real(i+4,kind=sp)
              psi4        = om0*t4+phi0
              s4          = rho0+rho1*sin(psi4)
              rhot_s(i+4) = s4
              c4          = rho0+rho1*cos(psi4)
              rhot_c(i+4) = c4
              t5          = real(i+5,kind=sp)
              psi5        = om0*t5+phi0
              s5          = rho0+rho1*sin(psi5)
              rhot_s(i+5) = s5
              c5          = rho0+rho1*cos(psi5)
              rhot_c(i+5) = c5
              t6          = real(i+6,kind=sp)
              psi6        = om0*t6+phi0
              s6          = rho0+rho1*sin(psi6)
              rhot_s(i+6) = s6
              c6          = rho0+rho1*cos(psi6)
              rhot_c(i+6) = c6
              t7          = real(i+7,kind=sp)
              psi7        = om0*t7+phi0
              s7          = rho0+rho1*sin(psi7)
              rhot_s(i+7) = s7
              c7          = rho0+rho1*cos(psi7)
              rhot_c(i+7) = c7
              t8          = real(i+8,kind=sp)
              psi8        = om0*t8+phi0
              s8          = rho0+rho1*sin(psi8)
              rhot_s(i+8) = s8
              c8          = rho0+rho1*cos(psi8)
              rhot_c(i+8) = c8
              t9          = real(i+9,kind=sp)
              psi9        = om0*t9+phi0
              s9          = rho0+rho1*sin(psi9)
              rhot_s(i+9) = s9
              c9          = rho0+rho1*cos(psi9)
              rhot_c(i+9) = c9
              t10         = real(i+10,kind=sp)
              psi10       = om0*t10+phi0
              s10         = rho0+rho1*sin(psi10)
              rhot_s(i+10)= s10
              c10         = rho0+rho1*cos(psi10)
              rhot_c(i+10)= c10
              t11         = real(i+11,kind=sp)
              psi11       = om0*t11+phi0
              s11         = rho0+rho1*sin(psi11)
              rhot_s(i+11)= s11
              c11         = rho0+rho1*cos(psi11)
              rhot_c(i+11)= c11
              t12         = real(i+12,kind=sp)
              psi12       = om0*t12+phi0
              s12         = rho0+rho1*sin(psi12)
              rhot_s(i+12)= s12
              c4          = rho0+rho1*cos(psi12)
              rhot_c(i+12)= c12
              t13         = real(i+13,kind=sp)
              psi13       = om0*t13+phi0
              s13         = rho0+rho1*sin(psi13)
              rhot_s(i+13)= s13
              c13         = rho0+rho1*cos(psi13)
              rhot_c(i+13)= c13
              t14         = real(i+14,kind=sp)
              psi14       = om0*t14+phi0
              s14         = rho0+rho1*sin(psi14)
              rhot_s(i+14)= s14
              c14         = rho0+rho1*cos(psi14)
              rhot_c(i+14)= c14
              t15         = real(i+15,kind=sp)
              psi15       = om0*t15+phi0
              s15         = rho0+rho1*sin(psi15)
              rhot_s(i+15)= s15
              c15         = rho0+rho1*cos(psi15)
              rhot_c(i+15)= c15
              
           end do
        
       end subroutine ideal_modulator_unroll_16x_r4


       subroutine ideal_modulator_unroll_8x_r4(rhot_s,rhot_c,n,f0,phi0,rho0,rho1)
           !dir$ optimize:3
           !dir$ attributes code_align : 32 ::  ideal_modulator_unroll_8x_r4
           !dir$ attributes forceinline ::   ideal_modulator_unroll_8x_r4
           !dir$ attributes optimization_parameter:"target_arch=skylake-avx512" ::  ideal_modulator_unroll_8x_r4
           real(kind=sp), dimension(1:n), intent(out) :: rhot_s
           real(kind=sp), dimension(1:n), intent(out) :: rhot_c
           integer(kind=i4),              intent(in)  :: n
           real(kind=sp),                 intent(in)  :: f0
           real(kind=sp),                 intent(in)  :: phi0
           real(kind=sp),                 intent(in)  :: rho0
           real(kind=sp),                 intent(in)  :: rho1
           real(kind=sp), parameter :: twopi = 6.283185307179586476925286766559_sp
           real(kind=sp) :: t0,t1,t2,t3,t4,t5,t6,t7
           real(kind=sp) :: s0,s1,s2,s3,s4,s5,s6,s7
           real(kind=sp) :: c0,c1,c2,c3,c4,c5,c6,c7
           real(kind=sp) :: psi0,psi1,psi2,psi3,psi4,psi5,psi6,psi7
           real(kind=sp) :: om0
           integer(kind=i4) :: i,m,m1
           om0 = twopi*f0
           m=mod(n,8)
           if(m /= 0) then
              do i=1, m
                 t0        = real(i,kind=sp)
                 psi0      = om0*t0+phi0
                 s0        = rho0+rho1*sin(psi0)
                 rhot_s(i) = s0
                 c0        = rho0+rho1*cos(psi0)
                 rhot_c(i) = c0
              end do
              if(n<8) return
           end if
           m1 = m+1
           !dir$ assume_aligned rhot_s:64           
           !dir$ assume_aligned rhot_c:64
           !dir$ vector aligned
           !dir$ ivdep
           !dir$ vector vectorlength(4)
           !dir$ vector multiple_gather_scatter_by_shuffles 
           !dir$ vector always
           do i=1,m1,8
              t0          = real(i+0,kind=sp)
              psi0        = om0*t0+phi0
              s0          = rho0+rho1*sin(psi0)
              rhot_s(i+0) = s0
              c0          = rho0+rho1*cos(psi0)
              rhot_c(i+0) = c0
              t1          = real(i+1,kind=sp)
              psi1        = om0*t1+phi0
              s1          = rho0+rho1*sin(psi1)
              rhot_s(i+1) = s1
              c0          = rho0+rho1*cos(psi1)
              rhot_c(i+1) = c1
              t2          = real(i+2,kind=sp)
              psi2        = om0*t2+phi0
              s2          = rho0+rho1*sin(psi2)
              rhot_s(i+2) = s2
              c2          = rho0+rho1*cos(psi2)
              rhot_c(i+2) = c2
              t3          = real(i+3,kind=sp)
              psi3        = om0*t3+phi0
              s3          = rho0+rho1*sin(psi3)
              rhot_s(i+3) = s3
              c3          = rho0+rho1*cos(psi3)
              rhot_c(i+3) = c3
              t4          = real(i+4,kind=sp)
              psi4        = om0*t4+phi0
              s4          = rho0+rho1*sin(psi4)
              rhot_s(i+4) = s4
              c4          = rho0+rho1*cos(psi4)
              rhot_c(i+4) = c4
              t5          = real(i+5,kind=sp)
              psi5        = om0*t5+phi0
              s5          = rho0+rho1*sin(psi5)
              rhot_s(i+5) = s5
              c5          = rho0+rho1*cos(psi5)
              rhot_c(i+5) = c5
              t6          = real(i+6,kind=sp)
              psi6        = om0*t6+phi0
              s6          = rho0+rho1*sin(psi6)
              rhot_s(i+6) = s6
              c6          = rho0+rho1*cos(psi6)
              rhot_c(i+6) = c6
              t7          = real(i+7,kind=sp)
              psi7        = om0*t7+phi0
              s7          = rho0+rho1*sin(psi7)
              rhot_s(i+7) = s7
              c7          = rho0+rho1*cos(psi7)
              rhot_c(i+7) = c7
           end do
        
       end subroutine ideal_modulator_unroll_8x_r4


       subroutine ideal_modulator_unroll_4x_r4(rhot_s,rhot_c,n,f0,phi0,rho0,rho1)
           !dir$ optimize:3
           !dir$ attributes code_align : 32 ::  ideal_modulator_unroll_4x_r4
           !dir$ attributes forceinline ::   ideal_modulator_unroll_4x_r4
           !dir$ attributes optimization_parameter:"target_arch=skylake-avx512" ::  ideal_modulator_unroll_4x_r4
           real(kind=sp), dimension(1:n), intent(out) :: rhot_s
           real(kind=sp), dimension(1:n), intent(out) :: rhot_c
           integer(kind=i4),              intent(in)  :: n
           real(kind=sp),                 intent(in)  :: f0
           real(kind=sp),                 intent(in)  :: phi0
           real(kind=sp),                 intent(in)  :: rho0
           real(kind=sp),                 intent(in)  :: rho1
           real(kind=sp), parameter :: twopi = 6.283185307179586476925286766559_sp
           real(kind=sp) :: t0,t1,t2,t3
           real(kind=sp) :: s0,s1,s2,s3
           real(kind=sp) :: c0,c1,c2,c3
           real(kind=sp) :: psi0,psi1,psi2,psi3
           real(kind=sp) :: om0
           integer(kind=i4) :: i,m,m1
           om0 = twopi*f0
           m=mod(n,4)
           if(m /= 0) then
              do i=1, m
                 t0        = real(i,kind=sp)
                 psi0      = om0*t0+phi0
                 s0        = rho0+rho1*sin(psi0)
                 rhot_s(i) = s0
                 c0        = rho0+rho1*cos(psi0)
                 rhot_c(i) = c0
              end do
              if(n<4) return
           end if
           m1 = m+1
           !dir$ assume_aligned rhot_s:64           
           !dir$ assume_aligned rhot_c:64
           !dir$ vector aligned
           !dir$ ivdep
           !dir$ vector vectorlength(4)
           !dir$ vector multiple_gather_scatter_by_shuffles 
           !dir$ vector always
           do i=1,m1,4
              t0          = real(i+0,kind=sp)
              psi0        = om0*t0+phi0
              s0          = rho0+rho1*sin(psi0)
              rhot_s(i+0) = s0
              c0          = rho0+rho1*cos(psi0)
              rhot_c(i+0) = c0
              t1          = real(i+1,kind=sp)
              psi1        = om0*t1+phi0
              s1          = rho0+rho1*sin(psi1)
              rhot_s(i+1) = s1
              c0          = rho0+rho1*cos(psi1)
              rhot_c(i+1) = c1
              t2          = real(i+2,kind=sp)
              psi2        = om0*t2+phi0
              s2          = rho0+rho1*sin(psi2)
              rhot_s(i+2) = s2
              c2          = rho0+rho1*cos(psi2)
              rhot_c(i+2) = c2
              t3          = real(i+3,kind=sp)
              psi3        = om0*t3+phi0
              s3          = rho0+rho1*sin(psi3)
              rhot_s(i+3) = s3
              c3          = rho0+rho1*cos(psi3)
              rhot_c(i+3) = c3
            end do
        
       end subroutine ideal_modulator_unroll_4x_r4


       subroutine ideal_modulator_unroll_2x_r4(rhot_s,rhot_c,n,f0,phi0,rho0,rho1)
           !dir$ optimize:3
           !dir$ attributes code_align : 32 ::  ideal_modulator_unroll_2x_r4
           !dir$ attributes forceinline ::   ideal_modulator_unroll_2x_r4
           !dir$ attributes optimization_parameter:"target_arch=skylake-avx512" ::  ideal_modulator_unroll_2x_r4
           real(kind=sp), dimension(1:n), intent(out) :: rhot_s
           real(kind=sp), dimension(1:n), intent(out) :: rhot_c
           integer(kind=i4),              intent(in)  :: n
           real(kind=sp),                 intent(in)  :: f0
           real(kind=sp),                 intent(in)  :: phi0
           real(kind=sp),                 intent(in)  :: rho0
           real(kind=sp),                 intent(in)  :: rho1
           real(kind=sp), parameter :: twopi = 6.283185307179586476925286766559_sp
           real(kind=sp) :: t0,t1
           real(kind=sp) :: s0,s1
           real(kind=sp) :: c0,c1
           real(kind=sp) :: psi0,psi1
           real(kind=sp) :: om0
           integer(kind=i4) :: i,m,m1
           om0 = twopi*f0
           m=mod(n,2)
           if(m /= 0) then
              do i=1, m
                 t0        = real(i,kind=sp)
                 psi0      = om0*t0+phi0
                 s0        = rho0+rho1*sin(psi0)
                 rhot_s(i) = s0
                 c0        = rho0+rho1*cos(psi0)
                 rhot_c(i) = c0
              end do
              if(n<2) return
           end if
           m1 = m+1
           !dir$ assume_aligned rhot_s:64           
           !dir$ assume_aligned rhot_c:64
           !dir$ vector aligned
           !dir$ ivdep
           !dir$ vector vectorlength(4)
           !dir$ vector multiple_gather_scatter_by_shuffles 
           !dir$ vector always
           do i=1,m1,2
              t0          = real(i+0,kind=sp)
              psi0        = om0*t0+phi0
              s0          = rho0+rho1*sin(psi0)
              rhot_s(i+0) = s0
              c0          = rho0+rho1*cos(psi0)
              rhot_c(i+0) = c0
              t1          = real(i+1,kind=sp)
              psi1        = om0*t1+phi0
              s1          = rho0+rho1*sin(psi1)
              rhot_s(i+1) = s1
              c0          = rho0+rho1*cos(psi1)
              rhot_c(i+1) = c1
           end do
        
       end subroutine ideal_modulator_unroll_2x_r4


       subroutine ideal_modulator_unroll_16x_r8(rhot_s,rhot_c,n,f0,phi0,rho0,rho1)
           !dir$ optimize:3
           !dir$ attributes code_align : 32 ::  ideal_modulator_unroll_16x_r8
           !dir$ attributes forceinline ::   ideal_modulator_unroll_16x_r8
           !dir$ attributes optimization_parameter:"target_arch=skylake-avx512" ::  ideal_modulator_unroll_16x_r8
           real(kind=dp), dimension(1:n), intent(out) :: rhot_s
           real(kind=dp), dimension(1:n), intent(out) :: rhot_c
           integer(kind=i4),              intent(in)  :: n
           real(kind=dp),                 intent(in)  :: f0
           real(kind=dp),                 intent(in)  :: phi0
           real(kind=dp),                 intent(in)  :: rho0
           real(kind=dp),                 intent(in)  :: rho1
           real(kind=dp), parameter :: twopi = 6.283185307179586476925286766559_dp
           real(kind=dp) :: t0,t1,t2,t3,t4,t5,t6,t7
           real(kind=dp) :: t8,t9,t10,t11,t12,t13,t14,t15
           real(kind=dp) :: s0,s1,s2,s3,s4,s5,s6,s7
           real(kind=dp) :: s8,s9,s10,s11,s12,s13,s14,s15
           real(kind=dp) :: c0,c1,c2,c3,c4,c5,c6,c7
           real(kind=dp) :: c8,c9,c10,c11,c12,c13,c14,c15
           real(kind=dp) :: psi0,psi1,psi2,psi3,psi4,psi5,psi6,psi7
           real(kind=dp) :: psi8,psi9,psi10,psi11,psi12,psi13,psi14,psi15
           real(kind=dp) :: om0
           integer(kind=i4) :: i,m,m1
           om0 = twopi*f0
           m=mod(n,16)
           if(m /= 0) then
              do i=1, m
                 t0        = real(i,kind=sp)
                 psi0      = om0*t0+phi0
                 s0        = rho0+rho1*sin(psi0)
                 rhot_s(i) = s0
                 c0        = rho0+rho1*cos(psi0)
                 rhot_c(i) = c0
              end do
              if(n<16) return
           end if
           m1 = m+1
           !dir$ assume_aligned rhot_s:64           
           !dir$ assume_aligned rhot_c:64
           !dir$ vector aligned
           !dir$ ivdep
           !dir$ vector vectorlength(8)
           !dir$ vector multiple_gather_scatter_by_shuffles 
           !dir$ vector always
           do i=1,m1,16
              t0          = real(i+0,kind=dp)
              psi0        = om0*t0+phi0
              s0          = rho0+rho1*sin(psi0)
              rhot_s(i+0) = s0
              c0          = rho0+rho1*cos(psi0)
              rhot_c(i+0) = c0
              t1          = real(i+1,kind=dp)
              psi1        = om0*t1+phi0
              s1          = rho0+rho1*sin(psi1)
              rhot_s(i+1) = s1
              c0          = rho0+rho1*cos(psi1)
              rhot_c(i+1) = c1
              t2          = real(i+2,kind=dp)
              psi2        = om0*t2+phi0
              s2          = rho0+rho1*sin(psi2)
              rhot_s(i+2) = s2
              c2          = rho0+rho1*cos(psi2)
              rhot_c(i+2) = c2
              t3          = real(i+3,kind=dp)
              psi3        = om0*t3+phi0
              s3          = rho0+rho1*sin(psi3)
              rhot_s(i+3) = s3
              c3          = rho0+rho1*cos(psi3)
              rhot_c(i+3) = c3
              t4          = real(i+4,kind=dp)
              psi4        = om0*t4+phi0
              s4          = rho0+rho1*sin(psi4)
              rhot_s(i+4) = s4
              c4          = rho0+rho1*cos(psi4)
              rhot_c(i+4) = c4
              t5          = real(i+5,kind=dp)
              psi5        = om0*t5+phi0
              s5          = rho0+rho1*sin(psi5)
              rhot_s(i+5) = s5
              c5          = rho0+rho1*cos(psi5)
              rhot_c(i+5) = c5
              t6          = real(i+6,kind=dp)
              psi6        = om0*t6+phi0
              s6          = rho0+rho1*sin(psi6)
              rhot_s(i+6) = s6
              c6          = rho0+rho1*cos(psi6)
              rhot_c(i+6) = c6
              t7          = real(i+7,kind=dp)
              psi7        = om0*t7+phi0
              s7          = rho0+rho1*sin(psi7)
              rhot_s(i+7) = s7
              c7          = rho0+rho1*cos(psi7)
              rhot_c(i+7) = c7
              t8          = real(i+8,kind=dp)
              psi8        = om0*t8+phi0
              s8          = rho0+rho1*sin(psi8)
              rhot_s(i+8) = s8
              c8          = rho0+rho1*cos(psi8)
              rhot_c(i+8) = c8
              t9          = real(i+9,kind=dp)
              psi9        = om0*t9+phi0
              s9          = rho0+rho1*sin(psi9)
              rhot_s(i+9) = s9
              c9          = rho0+rho1*cos(psi9)
              rhot_c(i+9) = c9
              t10         = real(i+10,kind=dp)
              psi10       = om0*t10+phi0
              s10         = rho0+rho1*sin(psi10)
              rhot_s(i+10)= s10
              c10         = rho0+rho1*cos(psi10)
              rhot_c(i+10)= c10
              t11         = real(i+11,kind=dp)
              psi11       = om0*t11+phi0
              s11         = rho0+rho1*sin(psi11)
              rhot_s(i+11)= s11
              c11         = rho0+rho1*cos(psi11)
              rhot_c(i+11)= c11
              t12         = real(i+12,kind=dp)
              psi12       = om0*t12+phi0
              s12         = rho0+rho1*sin(psi12)
              rhot_s(i+12)= s12
              c4          = rho0+rho1*cos(psi12)
              rhot_c(i+12)= c12
              t13         = real(i+13,kind=dp)
              psi13       = om0*t13+phi0
              s13         = rho0+rho1*sin(psi13)
              rhot_s(i+13)= s13
              c13         = rho0+rho1*cos(psi13)
              rhot_c(i+13)= c13
              t14         = real(i+14,kind=dp)
              psi14       = om0*t14+phi0
              s14         = rho0+rho1*sin(psi14)
              rhot_s(i+14)= s14
              c14         = rho0+rho1*cos(psi14)
              rhot_c(i+14)= c14
              t15         = real(i+15,kind=dp)
              psi15       = om0*t15+phi0
              s15         = rho0+rho1*sin(psi15)
              rhot_s(i+15)= s15
              c15         = rho0+rho1*cos(psi15)
              rhot_c(i+15)= c15
              
           end do
        
       end subroutine ideal_modulator_unroll_16x_r8


       subroutine ideal_modulator_unroll_8x_r8(rhot_s,rhot_c,n,f0,phi0,rho0,rho1)
           !dir$ optimize:3
           !dir$ attributes code_align : 32 ::  ideal_modulator_unroll_8x_r8
           !dir$ attributes forceinline ::   ideal_modulator_unroll_8x_r8
           !dir$ attributes optimization_parameter:"target_arch=skylake-avx512" ::  ideal_modulator_unroll_8x_r8
           real(kind=dp), dimension(1:n), intent(out) :: rhot_s
           real(kind=dp), dimension(1:n), intent(out) :: rhot_c
           integer(kind=i4),              intent(in)  :: n
           real(kind=dp),                 intent(in)  :: f0
           real(kind=dp),                 intent(in)  :: phi0
           real(kind=dp),                 intent(in)  :: rho0
           real(kind=dp),                 intent(in)  :: rho1
           real(kind=dp), parameter :: twopi = 6.283185307179586476925286766559_dp
           real(kind=dp) :: t0,t1,t2,t3,t4,t5,t6,t7
           real(kind=dp) :: s0,s1,s2,s3,s4,s5,s6,s7
           real(kind=dp) :: c0,c1,c2,c3,c4,c5,c6,c7
           real(kind=dp) :: psi0,psi1,psi2,psi3,psi4,psi5,psi6,psi7
           real(kind=dp) :: om0
           integer(kind=i4) :: i,m,m1
           om0 = twopi*f0
           m=mod(n,8)
           if(m /= 0) then
              do i=1, m
                 t0        = real(i,kind=dp)
                 psi0      = om0*t0+phi0
                 s0        = rho0+rho1*sin(psi0)
                 rhot_s(i) = s0
                 c0        = rho0+rho1*cos(psi0)
                 rhot_c(i) = c0
              end do
              if(n<8) return
           end if
           m1 = m+1
           !dir$ assume_aligned rhot_s:64           
           !dir$ assume_aligned rhot_c:64
           !dir$ vector aligned
           !dir$ ivdep
           !dir$ vector vectorlength(8)
           !dir$ vector multiple_gather_scatter_by_shuffles 
           !dir$ vector always
           do i=1,m1,8
              t0          = real(i+0,kind=dp)
              psi0        = om0*t0+phi0
              s0          = rho0+rho1*sin(psi0)
              rhot_s(i+0) = s0
              c0          = rho0+rho1*cos(psi0)
              rhot_c(i+0) = c0
              t1          = real(i+1,kind=dp)
              psi1        = om0*t1+phi0
              s1          = rho0+rho1*sin(psi1)
              rhot_s(i+1) = s1
              c0          = rho0+rho1*cos(psi1)
              rhot_c(i+1) = c1
              t2          = real(i+2,kind=dp)
              psi2        = om0*t2+phi0
              s2          = rho0+rho1*sin(psi2)
              rhot_s(i+2) = s2
              c2          = rho0+rho1*cos(psi2)
              rhot_c(i+2) = c2
              t3          = real(i+3,kind=dp)
              psi3        = om0*t3+phi0
              s3          = rho0+rho1*sin(psi3)
              rhot_s(i+3) = s3
              c3          = rho0+rho1*cos(psi3)
              rhot_c(i+3) = c3
              t4          = real(i+4,kind=dp)
              psi4        = om0*t4+phi0
              s4          = rho0+rho1*sin(psi4)
              rhot_s(i+4) = s4
              c4          = rho0+rho1*cos(psi4)
              rhot_c(i+4) = c4
              t5          = real(i+5,kind=dp)
              psi5        = om0*t5+phi0
              s5          = rho0+rho1*sin(psi5)
              rhot_s(i+5) = s5
              c5          = rho0+rho1*cos(psi5)
              rhot_c(i+5) = c5
              t6          = real(i+6,kind=dp)
              psi6        = om0*t6+phi0
              s6          = rho0+rho1*sin(psi6)
              rhot_s(i+6) = s6
              c6          = rho0+rho1*cos(psi6)
              rhot_c(i+6) = c6
              t7          = real(i+7,kind=dp)
              psi7        = om0*t7+phi0
              s7          = rho0+rho1*sin(psi7)
              rhot_s(i+7) = s7
              c7          = rho0+rho1*cos(psi7)
              rhot_c(i+7) = c7
           end do
        
       end subroutine ideal_modulator_unroll_8x_r8


       subroutine ideal_modulator_unroll_4x_r8(rhot_s,rhot_c,n,f0,phi0,rho0,rho1)
           !dir$ optimize:3
           !dir$ attributes code_align : 32 ::  ideal_modulator_unroll_4x_r8
           !dir$ attributes forceinline ::   ideal_modulator_unroll_4x_r8
           !dir$ attributes optimization_parameter:"target_arch=skylake-avx512" ::  ideal_modulator_unroll_4x_r8
           real(kind=dp), dimension(1:n), intent(out) :: rhot_s
           real(kind=dp), dimension(1:n), intent(out) :: rhot_c
           integer(kind=i4),              intent(in)  :: n
           real(kind=dp),                 intent(in)  :: f0
           real(kind=dp),                 intent(in)  :: phi0
           real(kind=dp),                 intent(in)  :: rho0
           real(kind=dp),                 intent(in)  :: rho1
           real(kind=dp), parameter :: twopi = 6.283185307179586476925286766559_dp
           real(kind=dp) :: t0,t1,t2,t3
           real(kind=dp) :: s0,s1,s2,s3
           real(kind=dp) :: c0,c1,c2,c3
           real(kind=dp) :: psi0,psi1,psi2,psi3
           real(kind=dp) :: om0
           integer(kind=i4) :: i,m,m1
           om0 = twopi*f0
           m=mod(n,4)
           if(m /= 0) then
              do i=1, m
                 t0        = real(i,kind=dp)
                 psi0      = om0*t0+phi0
                 s0        = rho0+rho1*sin(psi0)
                 rhot_s(i) = s0
                 c0        = rho0+rho1*cos(psi0)
                 rhot_c(i) = c0
              end do
              if(n<4) return
           end if
           m1 = m+1
           !dir$ assume_aligned rhot_s:64           
           !dir$ assume_aligned rhot_c:64
           !dir$ vector aligned
           !dir$ ivdep
           !dir$ vector vectorlength(8)
           !dir$ vector multiple_gather_scatter_by_shuffles 
           !dir$ vector always
           do i=1,m1,4
              t0          = real(i+0,kind=dp)
              psi0        = om0*t0+phi0
              s0          = rho0+rho1*sin(psi0)
              rhot_s(i+0) = s0
              c0          = rho0+rho1*cos(psi0)
              rhot_c(i+0) = c0
              t1          = real(i+1,kind=dp)
              psi1        = om0*t1+phi0
              s1          = rho0+rho1*sin(psi1)
              rhot_s(i+1) = s1
              c0          = rho0+rho1*cos(psi1)
              rhot_c(i+1) = c1
              t2          = real(i+2,kind=dp)
              psi2        = om0*t2+phi0
              s2          = rho0+rho1*sin(psi2)
              rhot_s(i+2) = s2
              c2          = rho0+rho1*cos(psi2)
              rhot_c(i+2) = c2
              t3          = real(i+3,kind=dp)
              psi3        = om0*t3+phi0
              s3          = rho0+rho1*sin(psi3)
              rhot_s(i+3) = s3
              c3          = rho0+rho1*cos(psi3)
              rhot_c(i+3) = c3
            end do
        
       end subroutine ideal_modulator_unroll_4x_r8


       subroutine ideal_modulator_unroll_2x_r8(rhot_s,rhot_c,n,f0,phi0,rho0,rho1)
           !dir$ optimize:3
           !dir$ attributes code_align : 32 ::  ideal_modulator_unroll_2x_r8
           !dir$ attributes forceinline ::   ideal_modulator_unroll_2x_r8
           !dir$ attributes optimization_parameter:"target_arch=skylake-avx512" ::  ideal_modulator_unroll_2x_r8
           real(kind=dp), dimension(1:n), intent(out) :: rhot_s
           real(kind=dp), dimension(1:n), intent(out) :: rhot_c
           integer(kind=i4),              intent(in)  :: n
           real(kind=dp),                 intent(in)  :: f0
           real(kind=dp),                 intent(in)  :: phi0
           real(kind=dp),                 intent(in)  :: rho0
           real(kind=dp),                 intent(in)  :: rho1
           real(kind=dp), parameter :: twopi = 6.283185307179586476925286766559_dp
           real(kind=dp) :: t0,t1
           real(kind=dp) :: s0,s1
           real(kind=dp) :: c0,c1
           real(kind=dp) :: psi0,psi1
           real(kind=dp) :: om0
           integer(kind=i4) :: i,m,m1
           om0 = twopi*f0
           m=mod(n,2)
           if(m /= 0) then
              do i=1, m
                 t0        = real(i,kind=dp)
                 psi0      = om0*t0+phi0
                 s0        = rho0+rho1*sin(psi0)
                 rhot_s(i) = s0
                 c0        = rho0+rho1*cos(psi0)
                 rhot_c(i) = c0
              end do
              if(n<2) return
           end if
           m1 = m+1
           !dir$ assume_aligned rhot_s:64           
           !dir$ assume_aligned rhot_c:64
           !dir$ vector aligned
           !dir$ ivdep
           !dir$ vector vectorlength(8)
           !dir$ vector multiple_gather_scatter_by_shuffles 
           !dir$ vector always
           do i=1,m1,2
              t0          = real(i+0,kind=dp)
              psi0        = om0*t0+phi0
              s0          = rho0+rho1*sin(psi0)
              rhot_s(i+0) = s0
              c0          = rho0+rho1*cos(psi0)
              rhot_c(i+0) = c0
              t1          = real(i+1,kind=dp)
              psi1        = om0*t1+phi0
              s1          = rho0+rho1*sin(psi1)
              rhot_s(i+1) = s1
              c0          = rho0+rho1*cos(psi1)
              rhot_c(i+1) = c1
           end do
        
       end subroutine ideal_modulator_unroll_2x_r8





       

! To be correctly reimplemented.
       

    

        !Ошибни изготовления растра —
        !модулятора излучения
        !Formula 2, p. 189
        subroutine rect_pulse_flux_unroll_16x_r4(Phik,fk,Phi0,n,Tin)
           !dir$ optimize:3
           !dir$ attributes code_align : 32 ::  rect_pulse_flux_unroll_16x_r4
           !dir$ attributes forceinline ::   rect_pulse_flux_unroll_16x_r4
           !dir$ attributes optimization_parameter:"target_arch=skylake-avx512" ::  rect_pulse_flux_unroll_16x_r4
           real(kind=sp), dimension(1:n), intent(out) :: Phik
           real(kind=sp), dimension(1:n), intent(in)  :: fk
           real(kind=sp),                 intent(in)  :: Phi0
           integer(kind=i4),              intent(in)  :: n
           real(kind=sp),                 intent(in)  :: Tin
           real(kind=sp), parameter :: twopi = 6.283185307179586476925286766559_sp
           real(kind=sp) :: fk0,fk1,fk2,fk3,fk4,fk5,fk6,fk7
           real(kind=sp) :: fk8,fk9,fk10,fk11,fk12,fk13,fk14,fk15
           real(kind=sp) :: sinc0,sinc1,sinc2,sinc3,sinc4,sinc5,sinc6,sinc7
           real(kind=sp) :: sinc8,sinc9,sinc10,sinc11,sinc12,sinc13,sinc14,sinc15
           real(kind=sp) :: arg0,arg1,arg2,arg3,arg4,arg,arg6,arg7
           real(kind=sp) :: arg1,arg9,arg10,arg11,arg12,arg13,arg14,arg15
           real(kind=sp) :: hTin,Phi0fk
           integer(kind=i4) :: i,m,m1
           hTin   = 0.5_sp*Tin
           Phi0fk = Phi0*Tin 
           m=mod(n,16)
           if(m /= 0) then
              do i=1, m
                 fk0       = fk(i+0)
                 arg0      = twopi*fk0*hTin
                 sinc0     = sin(arg0)/arg0
                 Phik(i+0) = Phi0fk*sinc0
              end do
              if(n<16) return
           end if
           m1 = m+1
           !dir$ assume_aligned Phik:64
           !dir$ assume_aligned fk:64
           !dir$ vector aligned
           !dir$ ivdep
           !dir$ vector vectorlength(4)
           !dir$ vector multiple_gather_scatter_by_shuffles 
           !dir$ vector always
           do i=1,m1,16
                fk0       = fk(i+0)
                arg0      = twopi*fk0*hTin
                sinc0     = sin(arg0)/arg0
                Phik(i+0) = Phi0fk*sinc0
                fk1       = fk(i+1)
                arg1      = twopi*fk1*hTin
                sinc1     = sin(arg1)/arg1
                Phik(i+1) = Phi0fk*sinc1
                fk2       = fk(i+2)
                arg2      = twopi*fk2*hTin
                sinc2     = sin(arg2)/arg2
                Phik(i+2) = Phi0fk*sinc2
                fk3       = fk(i+3)
                arg3      = twopi*fk3*hTin
                sinc3     = sin(arg3)/arg3
                Phik(i+3) = Phi0fk*sinc3
                fk4       = fk(i+4)
                arg4      = twopi*fk4*hTin
                sinc4     = sin(arg4)/arg4
                Phik(i+4) = Phi0fk*sinc4
                fk5       = fk(i+5)
                arg5      = twopi*fk5*hTin
                sinc5     = sin(arg5)/arg5
                Phik(i+5) = Phi0fk*sinc5
                fk6       = fk(i+6)
                arg6      = twopi*fk6*hTin
                sinc6     = sin(arg6)/arg6
                Phik(i+6) = Phi0fk*sinc6
                fk7       = fk(i+7)
                arg7      = twopi*fk7*hTin
                sinc7     = sin(arg7)/arg7
                Phik(i+7) = Phi0fk*sinc7
                fk8       = fk(i+8)
                arg8      = twopi*fk8*hTin
                sinc8     = sin(arg8)/arg8
                Phik(i+8) = Phi0fk*sinc8
                fk9       = fk(i+9)
                arg9      = twopi*fk9*hTin
                sinc9     = sin(arg9)/arg9
                Phik(i+9) = Phi0fk*sinc1
                fk10      = fk(i+10)
                arg10     = twopi*fk10*hTin
                sinc10    = sin(arg10)/arg10
                Phik(i+10)= Phi0fk*sinc10
                fk11      = fk(i+11)
                arg11     = twopi*fk11*hTin
                sinc11    = sin(arg11)/arg11
                Phik(i+11)= Phi0fk*sinc3
                fk12      = fk(i+12)
                arg12     = twopi*fk12*hTin
                sinc12    = sin(arg12)/arg12
                Phik(i+12)= Phi0fk*sinc12
                fk13      = fk(i+13)
                arg13     = twopi*fk13*hTin
                sinc13    = sin(arg13)/arg13
                Phik(i+13)= Phi0fk*sinc13
                fk14      = fk(i+14)
                arg14     = twopi*fk14*hTin
                sinc14    = sin(arg14)/arg14
                Phik(i+14)= Phi0fk*sinc14
                fk15      = fk(i+15)
                arg15     = twopi*fk15*hTin
                sinc15    = sin(arg15)/arg15
                Phik(i+15)= Phi0fk*sinc15
           end do
          
        end subroutine rect_pulse_flux_unroll_16x_r4


        subroutine rect_pulse_flux_unroll_8x_r4(Phik,fk,Phi0,n,Tin)
           !dir$ optimize:3
           !dir$ attributes code_align : 32 ::  rect_pulse_flux_unroll_8x_r4
           !dir$ attributes forceinline ::   rect_pulse_flux_unroll_8x_r4
           !dir$ attributes optimization_parameter:"target_arch=skylake-avx512" ::  rect_pulse_flux_unroll_8x_r4
           real(kind=sp), dimension(1:n), intent(out) :: Phik
           real(kind=sp), dimension(1:n), intent(in)  :: fk
           real(kind=sp),                 intent(in)  :: Phi0
           integer(kind=i4),              intent(in)  :: n
           real(kind=sp),                 intent(in)  :: Tin
           real(kind=sp), parameter :: twopi = 6.283185307179586476925286766559_sp
           real(kind=sp) :: fk0,fk1,fk2,fk3,fk4,fk5,fk6,fk7
           real(kind=sp) :: sinc0,sinc1,sinc2,sinc3,sinc4,sinc5,sinc6,sinc7
           real(kind=sp) :: arg0,arg1,arg2,arg3,arg4,arg,arg6,arg7
           real(kind=sp) :: hTin,Phi0fk
           integer(kind=i4) :: i,m,m1
           hTin   = 0.5_sp*Tin
           Phi0fk = Phi0*Tin 
           m=mod(n,8)
           if(m /= 0) then
              do i=1, m
                 fk0       = fk(i)
                 arg0      = twopi*fk0*hTin
                 sinc0     = sin(arg0)/arg0
                 Phik(i) = Phi0fk*sinc0
              end do
              if(n<8) return
           end if
           m1 = m+1
           !dir$ assume_aligned Phik:64
           !dir$ assume_aligned fk:64
           !dir$ vector aligned
           !dir$ ivdep
           !dir$ vector vectorlength(4)
           !dir$ vector multiple_gather_scatter_by_shuffles 
           !dir$ vector always
           do i=1,m1,8
                fk0       = fk(i+0)
                arg0      = twopi*fk0*hTin
                sinc0     = sin(arg0)/arg0
                Phik(i+0) = Phi0fk*sinc0
                fk1       = fk(i+1)
                arg1      = twopi*fk1*hTin
                sinc1     = sin(arg1)/arg1
                Phik(i+1) = Phi0fk*sinc1
                fk2       = fk(i+2)
                arg2      = twopi*fk2*hTin
                sinc2     = sin(arg2)/arg2
                Phik(i+2) = Phi0fk*sinc2
                fk3       = fk(i+3)
                arg3      = twopi*fk3*hTin
                sinc3     = sin(arg3)/arg3
                Phik(i+3) = Phi0fk*sinc3
                fk4       = fk(i+4)
                arg4      = twopi*fk4*hTin
                sinc4     = sin(arg4)/arg4
                Phik(i+4) = Phi0fk*sinc4
                fk5       = fk(i+5)
                arg5      = twopi*fk5*hTin
                sinc5     = sin(arg5)/arg5
                Phik(i+5) = Phi0fk*sinc5
                fk6       = fk(i+6)
                arg6      = twopi*fk6*hTin
                sinc6     = sin(arg6)/arg6
                Phik(i+6) = Phi0fk*sinc6
                fk7       = fk(i+7)
                arg7      = twopi*fk7*hTin
                sinc7     = sin(arg7)/arg7
                Phik(i+7) = Phi0fk*sinc7
             end do
          
        end subroutine rect_pulse_flux_unroll_8x_r4


        subroutine rect_pulse_flux_unroll_4x_r4(Phik,fk,Phi0,n,Tin)
           !dir$ optimize:3
           !dir$ attributes code_align : 32 ::  rect_pulse_flux_unroll_4x_r4
           !dir$ attributes forceinline ::   rect_pulse_flux_unroll_4x_r4
           !dir$ attributes optimization_parameter:"target_arch=skylake-avx512" ::  rect_pulse_flux_unroll_4x_r4
           real(kind=sp), dimension(1:n), intent(out) :: Phik
           real(kind=sp), dimension(1:n), intent(in)  :: fk
           real(kind=sp),                 intent(in)  :: Phi0
           integer(kind=i4),              intent(in)  :: n
           real(kind=sp),                 intent(in)  :: Tin
           real(kind=sp), parameter :: twopi = 6.283185307179586476925286766559_sp
           real(kind=sp) :: fk0,fk1,fk2,fk3
           real(kind=sp) :: sinc0,sinc1,sinc2,sinc3
           real(kind=sp) :: arg0,arg1,arg2,arg3
           real(kind=sp) :: hTin,Phi0fk
           integer(kind=i4) :: i,m,m1
           hTin   = 0.5_sp*Tin
           Phi0fk = Phi0*Tin 
           m=mod(n,4)
           if(m /= 0) then
              do i=1, m
                 fk0       = fk(i)
                 arg0      = twopi*fk0*hTin
                 sinc0     = sin(arg0)/arg0
                 Phik(i) = Phi0fk*sinc0
              end do
              if(n<4) return
           end if
           m1 = m+1
           !dir$ assume_aligned Phik:64
           !dir$ assume_aligned fk:64
           !dir$ vector aligned
           !dir$ ivdep
           !dir$ vector vectorlength(4)
           !dir$ vector multiple_gather_scatter_by_shuffles 
           !dir$ vector always
           do i=1,m1,4
                fk0       = fk(i+0)
                arg0      = twopi*fk0*hTin
                sinc0     = sin(arg0)/arg0
                Phik(i+0) = Phi0fk*sinc0
                fk1       = fk(i+1)
                arg1      = twopi*fk1*hTin
                sinc1     = sin(arg1)/arg1
                Phik(i+1) = Phi0fk*sinc1
                fk2       = fk(i+2)
                arg2      = twopi*fk2*hTin
                sinc2     = sin(arg2)/arg2
                Phik(i+2) = Phi0fk*sinc2
                fk3       = fk(i+3)
                arg3      = twopi*fk3*hTin
                sinc3     = sin(arg3)/arg3
                Phik(i+3) = Phi0fk*sinc3
             end do
          
        end subroutine rect_pulse_flux_unroll_4x_r4


        subroutine rect_pulse_flux_unroll_2x_r4(Phik,fk,Phi0,n,Tin)
           !dir$ optimize:3
           !dir$ attributes code_align : 32 ::  rect_pulse_flux_unroll_2x_r4
           !dir$ attributes forceinline ::   rect_pulse_flux_unroll_2x_r4
           !dir$ attributes optimization_parameter:"target_arch=skylake-avx512" ::  rect_pulse_flux_unroll_2x_r4
           real(kind=sp), dimension(1:n), intent(out) :: Phik
           real(kind=sp), dimension(1:n), intent(in)  :: fk
           real(kind=sp),                 intent(in)  :: Phi0
           integer(kind=i4),              intent(in)  :: n
           real(kind=sp),                 intent(in)  :: Tin
           real(kind=sp), parameter :: twopi = 6.283185307179586476925286766559_sp
           real(kind=sp) :: fk0,fk1
           real(kind=sp) :: sinc0,sinc1
           real(kind=sp) :: arg0,arg1
           real(kind=sp) :: hTin,Phi0fk
           integer(kind=i4) :: i,m,m1
           hTin   = 0.5_sp*Tin
           Phi0fk = Phi0*Tin 
           m=mod(n,2)
           if(m /= 0) then
              do i=1, m
                 fk0       = fk(i)
                 arg0      = twopi*fk0*hTin
                 sinc0     = sin(arg0)/arg0
                 Phik(i) = Phi0fk*sinc0
              end do
              if(n<2) return
           end if
           m1 = m+1
           !dir$ assume_aligned Phik:64
           !dir$ assume_aligned fk:64
           !dir$ vector aligned
           !dir$ ivdep
           !dir$ vector vectorlength(4)
           !dir$ vector multiple_gather_scatter_by_shuffles 
           !dir$ vector always
           do i=1,m1,2
                fk0       = fk(i+0)
                arg0      = twopi*fk0*hTin
                sinc0     = sin(arg0)/arg0
                Phik(i+0) = Phi0fk*sinc0
                fk1       = fk(i+1)
                arg1      = twopi*fk1*hTin
                sinc1     = sin(arg1)/arg1
                Phik(i+1) = Phi0fk*sinc1
     
             end do
          
        end subroutine rect_pulse_flux_unroll_2x_r4


        
       subroutine rect_pulse_flux_unroll_16x_r8(Phik,fk,Phi0,n,Tin)
           !dir$ optimize:3
           !dir$ attributes code_align : 32 ::  rect_pulse_flux_unroll_16x_r8
           !dir$ attributes forceinline ::   rect_pulse_flux_unroll_16x_r8
           !dir$ attributes optimization_parameter:"target_arch=skylake-avx512" ::  rect_pulse_flux_unroll_16x_r8
           real(kind=dp), dimension(1:n), intent(out) :: Phik
           real(kind=dp), dimension(1:n), intent(in)  :: fk
           real(kind=dp),                 intent(in)  :: Phi0
           integer(kind=i4),              intent(in)  :: n
           real(kind=dp),                 intent(in)  :: Tin
           real(kind=dp), parameter :: twopi = 6.283185307179586476925286766559_dp
           real(kind=dp) :: fk0,fk1,fk2,fk3,fk4,fk5,fk6,fk7
           real(kind=dp) :: fk8,fk9,fk10,fk11,fk12,fk13,fk14,fk15
           real(kind=dp) :: sinc0,sinc1,sinc2,sinc3,sinc4,sinc5,sinc6,sinc7
           real(kind=dp) :: sinc8,sinc9,sinc10,sinc11,sinc12,sinc13,sinc14,sinc15
           real(kind=dp) :: arg0,arg1,arg2,arg3,arg4,arg,arg6,arg7
           real(kind=dp) :: arg1,arg9,arg10,arg11,arg12,arg13,arg14,arg15
           real(kind=dp) :: hTin,Phi0fk
           integer(kind=i4) :: i,m,m1
           hTin   = 0.5_dp*Tin
           Phi0fk = Phi0*Tin 
           m=mod(n,16)
           if(m /= 0) then
              do i=1, m
                 fk0       = fk(i)
                 arg0      = twopi*fk0*hTin
                 sinc0     = sin(arg0)/arg0
                 Phik(i)   = Phi0fk*sinc0
              end do
              if(n<16) return
           end if
           m1 = m+1
           !dir$ assume_aligned Phik:64
           !dir$ assume_aligned fk:64
           !dir$ vector aligned
           !dir$ ivdep
           !dir$ vector vectorlength(8)
           !dir$ vector multiple_gather_scatter_by_shuffles 
           !dir$ vector always
           do i=1,m1,16
                fk0       = fk(i+0)
                arg0      = twopi*fk0*hTin
                sinc0     = sin(arg0)/arg0
                Phik(i+0) = Phi0fk*sinc0
                fk1       = fk(i+1)
                arg1      = twopi*fk1*hTin
                sinc1     = sin(arg1)/arg1
                Phik(i+1) = Phi0fk*sinc1
                fk2       = fk(i+2)
                arg2      = twopi*fk2*hTin
                sinc2     = sin(arg2)/arg2
                Phik(i+2) = Phi0fk*sinc2
                fk3       = fk(i+3)
                arg3      = twopi*fk3*hTin
                sinc3     = sin(arg3)/arg3
                Phik(i+3) = Phi0fk*sinc3
                fk4       = fk(i+4)
                arg4      = twopi*fk4*hTin
                sinc4     = sin(arg4)/arg4
                Phik(i+4) = Phi0fk*sinc4
                fk5       = fk(i+5)
                arg5      = twopi*fk5*hTin
                sinc5     = sin(arg5)/arg5
                Phik(i+5) = Phi0fk*sinc5
                fk6       = fk(i+6)
                arg6      = twopi*fk6*hTin
                sinc6     = sin(arg6)/arg6
                Phik(i+6) = Phi0fk*sinc6
                fk7       = fk(i+7)
                arg7      = twopi*fk7*hTin
                sinc7     = sin(arg7)/arg7
                Phik(i+7) = Phi0fk*sinc7
                fk8       = fk(i+8)
                arg8      = twopi*fk8*hTin
                sinc8     = sin(arg8)/arg8
                Phik(i+8) = Phi0fk*sinc8
                fk9       = fk(i+9)
                arg9      = twopi*fk9*hTin
                sinc9     = sin(arg9)/arg9
                Phik(i+9) = Phi0fk*sinc1
                fk10      = fk(i+10)
                arg10     = twopi*fk10*hTin
                sinc10    = sin(arg10)/arg10
                Phik(i+10)= Phi0fk*sinc10
                fk11      = fk(i+11)
                arg11     = twopi*fk11*hTin
                sinc11    = sin(arg11)/arg11
                Phik(i+11)= Phi0fk*sinc3
                fk12      = fk(i+12)
                arg12     = twopi*fk12*hTin
                sinc12    = sin(arg12)/arg12
                Phik(i+12)= Phi0fk*sinc12
                fk13      = fk(i+13)
                arg13     = twopi*fk13*hTin
                sinc13    = sin(arg13)/arg13
                Phik(i+13)= Phi0fk*sinc13
                fk14      = fk(i+14)
                arg14     = twopi*fk14*hTin
                sinc14    = sin(arg14)/arg14
                Phik(i+14)= Phi0fk*sinc14
                fk15      = fk(i+15)
                arg15     = twopi*fk15*hTin
                sinc15    = sin(arg15)/arg15
                Phik(i+15)= Phi0fk*sinc15
           end do
          
        end subroutine rect_pulse_flux_unroll_16x_r8


        subroutine rect_pulse_flux_unroll_8x_r8(Phik,fk,Phi0,n,Tin)
           !dir$ optimize:3
           !dir$ attributes code_align : 32 ::  rect_pulse_flux_unroll_8x_r8
           !dir$ attributes forceinline ::   rect_pulse_flux_unroll_8x_r8
           !dir$ attributes optimization_parameter:"target_arch=skylake-avx512" ::  rect_pulse_flux_unroll_8x_r8
           real(kind=dp), dimension(1:n), intent(out) :: Phik
           real(kind=dp), dimension(1:n), intent(in)  :: fk
           real(kind=dp),                 intent(in)  :: Phi0
           integer(kind=i4),              intent(in)  :: n
           real(kind=dp),                 intent(in)  :: Tin
           real(kind=dp), parameter :: twopi = 6.283185307179586476925286766559_dp
           real(kind=dp) :: fk0,fk1,fk2,fk3,fk4,fk5,fk6,fk7
           real(kind=dp) :: sinc0,sinc1,sinc2,sinc3,sinc4,sinc5,sinc6,sinc7
           real(kind=dp) :: arg0,arg1,arg2,arg3,arg4,arg,arg6,arg7
           real(kind=dp) :: hTin,Phi0fk
           integer(kind=i4) :: i,m,m1
           hTin   = 0.5_dp*Tin
           Phi0fk = Phi0*Tin 
           m=mod(n,8)
           if(m /= 0) then
              do i=1, m
                 fk0       = fk(i)
                 arg0      = twopi*fk0*hTin
                 sinc0     = sin(arg0)/arg0
                 Phik(i)   = Phi0fk*sinc0
              end do
              if(n<8) return
           end if
           m1 = m+1
           !dir$ assume_aligned Phik:64
           !dir$ assume_aligned fk:64
           !dir$ vector aligned
           !dir$ ivdep
           !dir$ vector vectorlength(8)
           !dir$ vector multiple_gather_scatter_by_shuffles 
           !dir$ vector always
           do i=1,m1,8
                fk0       = fk(i+0)
                arg0      = twopi*fk0*hTin
                sinc0     = sin(arg0)/arg0
                Phik(i+0) = Phi0fk*sinc0
                fk1       = fk(i+1)
                arg1      = twopi*fk1*hTin
                sinc1     = sin(arg1)/arg1
                Phik(i+1) = Phi0fk*sinc1
                fk2       = fk(i+2)
                arg2      = twopi*fk2*hTin
                sinc2     = sin(arg2)/arg2
                Phik(i+2) = Phi0fk*sinc2
                fk3       = fk(i+3)
                arg3      = twopi*fk3*hTin
                sinc3     = sin(arg3)/arg3
                Phik(i+3) = Phi0fk*sinc3
                fk4       = fk(i+4)
                arg4      = twopi*fk4*hTin
                sinc4     = sin(arg4)/arg4
                Phik(i+4) = Phi0fk*sinc4
                fk5       = fk(i+5)
                arg5      = twopi*fk5*hTin
                sinc5     = sin(arg5)/arg5
                Phik(i+5) = Phi0fk*sinc5
                fk6       = fk(i+6)
                arg6      = twopi*fk6*hTin
                sinc6     = sin(arg6)/arg6
                Phik(i+6) = Phi0fk*sinc6
                fk7       = fk(i+7)
                arg7      = twopi*fk7*hTin
                sinc7     = sin(arg7)/arg7
                Phik(i+7) = Phi0fk*sinc7
              
           end do
          
        end subroutine rect_pulse_flux_unroll_8x_r8



        subroutine rect_pulse_flux_unroll_4x_r8(Phik,fk,Phi0,n,Tin)
           !dir$ optimize:3
           !dir$ attributes code_align : 32 ::  rect_pulse_flux_unroll_4x_r8
           !dir$ attributes forceinline ::   rect_pulse_flux_unroll_4x_r8
           !dir$ attributes optimization_parameter:"target_arch=skylake-avx512" ::  rect_pulse_flux_unroll_4x_r8
           real(kind=dp), dimension(1:n), intent(out) :: Phik
           real(kind=dp), dimension(1:n), intent(in)  :: fk
           real(kind=dp),                 intent(in)  :: Phi0
           integer(kind=i4),              intent(in)  :: n
           real(kind=dp),                 intent(in)  :: Tin
           real(kind=dp), parameter :: twopi = 6.283185307179586476925286766559_dp
           real(kind=dp) :: fk0,fk1,fk2,fk3
           real(kind=dp) :: sinc0,sinc1,sinc2,sinc3
           real(kind=dp) :: arg0,arg1,arg2,arg3
           real(kind=dp) :: hTin,Phi0fk
           integer(kind=i4) :: i,m,m1
           hTin   = 0.5_dp*Tin
           Phi0fk = Phi0*Tin 
           m=mod(n,4)
           if(m /= 0) then
              do i=1, m
                 fk0       = fk(i)
                 arg0      = twopi*fk0*hTin
                 sinc0     = sin(arg0)/arg0
                 Phik(i)   = Phi0fk*sinc0
              end do
              if(n<4) return
           end if
           m1 = m+1
           !dir$ assume_aligned Phik:64
           !dir$ assume_aligned fk:64
           !dir$ vector aligned
           !dir$ ivdep
           !dir$ vector vectorlength(8)
           !dir$ vector multiple_gather_scatter_by_shuffles 
           !dir$ vector always
           do i=1,m1,4
                fk0       = fk(i+0)
                arg0      = twopi*fk0*hTin
                sinc0     = sin(arg0)/arg0
                Phik(i+0) = Phi0fk*sinc0
                fk1       = fk(i+1)
                arg1      = twopi*fk1*hTin
                sinc1     = sin(arg1)/arg1
                Phik(i+1) = Phi0fk*sinc1
                fk2       = fk(i+2)
                arg2      = twopi*fk2*hTin
                sinc2     = sin(arg2)/arg2
                Phik(i+2) = Phi0fk*sinc2
                fk3       = fk(i+3)
                arg3      = twopi*fk3*hTin
                sinc3     = sin(arg3)/arg3
                Phik(i+3) = Phi0fk*sinc3
                            
           end do
          
        end subroutine rect_pulse_flux_unroll_4x_r8


        subroutine rect_pulse_flux_unroll_2x_r8(Phik,fk,Phi0,n,Tin)
           !dir$ optimize:3
           !dir$ attributes code_align : 32 ::  rect_pulse_flux_unroll_2x_r8
           !dir$ attributes forceinline ::   rect_pulse_flux_unroll_2x_r8
           !dir$ attributes optimization_parameter:"target_arch=skylake-avx512" ::  rect_pulse_flux_unroll_2x_r8
           real(kind=dp), dimension(1:n), intent(out) :: Phik
           real(kind=dp), dimension(1:n), intent(in)  :: fk
           real(kind=dp),                 intent(in)  :: Phi0
           integer(kind=i4),              intent(in)  :: n
           real(kind=dp),                 intent(in)  :: Tin
           real(kind=dp), parameter :: twopi = 6.283185307179586476925286766559_dp
           real(kind=dp) :: fk0,fk1
           real(kind=dp) :: sinc0,sinc1
           real(kind=dp) :: arg0,arg1
           real(kind=dp) :: hTin,Phi0fk
           integer(kind=i4) :: i,m,m1
           hTin   = 0.5_dp*Tin
           Phi0fk = Phi0*Tin 
           m=mod(n,2)
           if(m /= 0) then
              do i=1, m
                 fk0       = fk(i)
                 arg0      = twopi*fk0*hTin
                 sinc0     = sin(arg0)/arg0
                 Phik(i)   = Phi0fk*sinc0
              end do
              if(n<2) return
           end if
           m1 = m+1
           !dir$ assume_aligned Phik:64
           !dir$ assume_aligned fk:64
           !dir$ vector aligned
           !dir$ ivdep
           !dir$ vector vectorlength(8)
           !dir$ vector multiple_gather_scatter_by_shuffles 
           !dir$ vector always
           do i=1,m1,4
                fk0       = fk(i+0)
                arg0      = twopi*fk0*hTin
                sinc0     = sin(arg0)/arg0
                Phik(i+0) = Phi0fk*sinc0
                fk1       = fk(i+1)
                arg1      = twopi*fk1*hTin
                sinc1     = sin(arg1)/arg1
                Phik(i+1) = Phi0fk*sinc1
                                          
           end do
          
        end subroutine rect_pulse_flux_unroll_2x_r8

      

        subroutine rect_pulse_amp_unroll_16x_r4(Ak,Phik,Phi0,n,T,k,tin)
           !dir$ optimize:3
           !dir$ attributes code_align : 32 ::  rect_pulse_amp_unroll_16x_r4
           !dir$ attributes forceinline ::   rect_pulse_amp_unroll_16x_r4
           !dir$ attributes optimization_parameter:"target_arch=skylake-avx512" ::  rect_pulse_amp_unroll_16x_r4
           use mod_fpcompare, only : Compare_Float
           real(kind=sp), dimension(1:n),  intent(out) :: Ak
           real(kind=sp), dimension(1:n),  intent(in)  :: Phik
           real(kind=sp),                  intent(in)  :: Phi0
           integer(kind=i4),               intent(in)  :: n
           real(kind=sp),                  intent(in)  :: T
           real(kind=sp), dimension(1:n),  intent(in)  :: k
           real(kind=sp),                  intent(in)  :: tin
           real(kind=sp), parameter :: pi2 = 1.5707963267948966192313216916398_sp
           real(kind=sp) :: phik0,phik1,phik2,phik3,phik4,phik5,phik6,phik7
           real(kind=sp) :: phik8,phik9,phik10,phik11,phik12,phik13,phik14,phik15
           real(kind=sp) :: arg0,arg1,arg2,arg3,arg4,arg5,arg6,arg7
           real(kind=sp) :: arg8,arg9,arg10,arg11,arg12,arg13,arg14,arg15
           real(kind=sp) :: k0,k1,k2,k3,k4,k5,k6,k7
           real(kind=sp) :: k8,k9,k10,k11,k12,k13,k14,k15
           real(kind=sp) :: twoT,kpi2
           integer(kind=i4) :: i,m,m1
           twoT = 2.0_sp/T
           if(Compare_Float(tin,twoT)) then
               m=mod(n,16)
               if(m /= 0) then
                  do i=1,m
                      k0    = k(i)
                      arg0  = k0*pi2
                      Ak(i) = Phi0*(sin(arg0)/arg0) 
                  end do
                  if(n<16) return
                end if
                m1 = m+1
               !dir$ assume_aligned Ak:64
               !dir$ assume_aligned k:64
               !dir$ vector aligned
               !dir$ ivdep
               !dir$ vector vectorlength(4)
               !dir$ vector multiple_gather_scatter_by_shuffles 
               !dir$ vector always
               do i=1,m1,16
                    k0      = k(i+0)
                    arg0    = k0*pi2
                    Ak(i+0) = Phi0*(sin(arg0)/arg0) 
                    k1      = k(i+1)
                    arg1    = k1*pi2
                    Ak(i+1) = Phi0*(sin(arg1)/arg1) 
                    k2      = k(i+2)
                    arg2    = k2*pi2
                    Ak(i+2) = Phi0*(sin(arg2)/arg2) 
                    k3      = k(i+3)
                    arg3    = k3*pi2
                    Ak(i+3) = Phi0*(sin(arg3)/arg3) 
                    k4      = k(i+4)
                    arg4    = k4*pi2
                    Ak(i+4) = Phi0*(sin(arg4)/arg4) 
                    k5      = k(i+5)
                    arg5    = k5*pi2
                    Ak(i+5) = Phi0*(sin(arg5)/arg5) 
                    k6      = k(i+6)
                    arg6    = k6*pi2
                    Ak(i+6) = Phi0*(sin(arg6)/arg6)
                    k7      = k(i+7)
                    arg7    = k7*pi2
                    Ak(i+7) = Phi0*(sin(arg7)/arg7)   
                    k08     = k(i+8)
                    arg8    = k8*pi2
                    Ak(i+8) = Phi0*(sin(arg8)/arg8) 
                    k9      = k(i+9)
                    arg9    = k9*pi2
                    Ak(i+9) = Phi0*(sin(arg9)/arg9) 
                    k10     = k(i+10)
                    arg10   = k10*pi2
                    Ak(i+10)= Phi0*(sin(arg10)/arg10) 
                    k11     = k(i+11)
                    arg11   = k11*pi2
                    Ak(i+11)= Phi0*(sin(arg11)/arg11) 
                    k12     = k(i+12)
                    arg12   = k12*pi2
                    Ak(i+12)= Phi0*(sin(arg12)/arg12) 
                    k13     = k(i+13)
                    arg13   = k13*pi2
                    Ak(i+13)= Phi0*(sin(arg13)/arg13) 
                    k14     = k(i+14)
                    arg14   = k14*pi2
                    Ak(i+14)= Phi0*(sin(arg14)/arg14)
                    k15     = k(i+15)
                    arg155  = k15*pi2
                    Ak(i+15)= Phi0*(sin(arg15)/arg15)   
               end do
             
           else
               m=mod(n,16)
               if(m /= 0) then
                  do i=1,m
                      phik0 = Phik(i)
                      Ak(i) = twoT*phik0
                  end do
                  if(n<16) return
                end if
               m1 = m+1
               !dir$ assume_aligned Ak:64
               !dir$ assume_aligned Phik:64
               !dir$ vector aligned
               !dir$ ivdep
               !dir$ vector vectorlength(4)
               !dir$ vector multiple_gather_scatter_by_shuffles 
               !dir$ vector always
               do i=1,m1,16
                    phik0   = Phik(i+0)
                    Ak(i+0) = twoT*phik0
                    phik1   = Phik(i+1)
                    Ak(i+1) = twoT*phik1
                    phik2   = Phik(i+2)
                    Ak(i+2) = twoT*phik2
                    phik3   = Phik(i+3)
                    Ak(i+3) = twoT*phik3
                    phik4   = Phik(i+4)
                    Ak(i+4) = twoT*phik4
                    phik5   = Phik(i+5)
                    Ak(i+5) = twoT*phik5
                    phik6   = Phik(i+6)
                    Ak(i+6) = twoT*phik6
                    phik7   = Phik(i+7)
                    Ak(i+7) = twoT*phik7
                    phik8   = Phik(i+8)
                    Ak(i+8) = twoT*phik8
                    phik9   = Phik(i+9)
                    Ak(i+9) = twoT*phik9
                    phik10  = Phik(i+10)
                    Ak(i+10)= twoT*phik10
                    phik11  = Phik(i+11)
                    Ak(i+11)= twoT*phik11
                    phik12  = Phik(i+12)
                    Ak(i+12)= twoT*phik12
                    phik13  = Phik(i+13)
                    Ak(i+13)= twoT*phik13
                    phik14  = Phik(i+14)
                    Ak(i+14)= twoT*phik14
                    phik15  = Phik(i+15)
                    Ak(i+15) = twoT*phik15
              end do
             
          end if
       end subroutine rect_pulse_amp_unroll_16x_r4


       subroutine rect_pulse_amp_unroll_8x_r4(Ak,Phik,Phi0,n,T,k,tin)
           !dir$ optimize:3
           !dir$ attributes code_align : 32 ::  rect_pulse_amp_unroll_8x_r4
           !dir$ attributes forceinline ::   rect_pulse_amp_unroll_8x_r4
           !dir$ attributes optimization_parameter:"target_arch=skylake-avx512" ::  rect_pulse_amp_unroll_8x_r4
           use mod_fpcompare, only : Compare_Float
           real(kind=sp), dimension(1:n),  intent(out) :: Ak
           real(kind=sp), dimension(1:n),  intent(in)  :: Phik
           real(kind=sp),                  intent(in)  :: Phi0
           integer(kind=i4),               intent(in)  :: n
           real(kind=sp),                  intent(in)  :: T
           real(kind=sp), dimension(1:n),  intent(in)  :: k
           real(kind=sp),                  intent(in)  :: tin
           real(kind=sp), parameter :: pi2 = 1.5707963267948966192313216916398_sp
           real(kind=sp) :: phik0,phik1,phik2,phik3,phik4,phik5,phik6,phik7
           real(kind=sp) :: arg0,arg1,arg2,arg3,arg4,arg5,arg6,arg7
           real(kind=sp) :: k0,k1,k2,k3,k4,k5,k6,k7
           real(kind=sp) :: twoT,kpi2
           integer(kind=i4) :: i,m,m1
           twoT = 2.0_sp/T
           if(Compare_Float(tin,twoT)) then
               m=mod(n,8)
               if(m /= 0) then
                  do i=1,m
                      k0    = k(i)
                      arg0  = k0*pi2
                      Ak(i) = Phi0*(sin(arg0)/arg0) 
                  end do
                  if(n<8) return
                end if
                m1 = m+1
               !dir$ assume_aligned Ak:64
               !dir$ assume_aligned k:64
               !dir$ vector aligned
               !dir$ ivdep
               !dir$ vector vectorlength(4)
               !dir$ vector multiple_gather_scatter_by_shuffles 
               !dir$ vector always
               do i=1,m1,8
                    k0      = k(i+0)
                    arg0    = k0*pi2
                    Ak(i+0) = Phi0*(sin(arg0)/arg0) 
                    k1      = k(i+1)
                    arg1    = k1*pi2
                    Ak(i+1) = Phi0*(sin(arg1)/arg1) 
                    k2      = k(i+2)
                    arg2    = k2*pi2
                    Ak(i+2) = Phi0*(sin(arg2)/arg2) 
                    k3      = k(i+3)
                    arg3    = k3*pi2
                    Ak(i+3) = Phi0*(sin(arg3)/arg3) 
                    k4      = k(i+4)
                    arg4    = k4*pi2
                    Ak(i+4) = Phi0*(sin(arg4)/arg4) 
                    k5      = k(i+5)
                    arg5    = k5*pi2
                    Ak(i+5) = Phi0*(sin(arg5)/arg5) 
                    k6      = k(i+6)
                    arg6    = k6*pi2
                    Ak(i+6) = Phi0*(sin(arg6)/arg6)
                    k7      = k(i+7)
                    arg7    = k7*pi2
                    Ak(i+7) = Phi0*(sin(arg7)/arg7)   
                end do
             
           else
               m=mod(n,8)
               if(m /= 0) then
                  do i=1,m
                      phik0 = Phik(i)
                      Ak(i) = twoT*phik0
                  end do
                  if(n<8) return
                end if
               m1 = m+1
               !dir$ assume_aligned Ak:64
               !dir$ assume_aligned Phik:64
               !dir$ vector aligned
               !dir$ ivdep
               !dir$ vector vectorlength(4)
               !dir$ vector multiple_gather_scatter_by_shuffles 
               !dir$ vector always
               do i=1,m1,8
                    phik0   = Phik(i+0)
                    Ak(i+0) = twoT*phik0
                    phik1   = Phik(i+1)
                    Ak(i+1) = twoT*phik1
                    phik2   = Phik(i+2)
                    Ak(i+2) = twoT*phik2
                    phik3   = Phik(i+3)
                    Ak(i+3) = twoT*phik3
                    phik4   = Phik(i+4)
                    Ak(i+4) = twoT*phik4
                    phik5   = Phik(i+5)
                    Ak(i+5) = twoT*phik5
                    phik6   = Phik(i+6)
                    Ak(i+6) = twoT*phik6
                    phik7   = Phik(i+7)
                    Ak(i+7) = twoT*phik7
                   
              end do
             
          end if
       end subroutine rect_pulse_amp_unroll_8x_r4


       subroutine rect_pulse_amp_unroll_4x_r4(Ak,Phik,Phi0,n,T,k,tin)
           !dir$ optimize:3
           !dir$ attributes code_align : 32 ::  rect_pulse_amp_unroll_4x_r4
           !dir$ attributes forceinline ::   rect_pulse_amp_unroll_4x_r4
           !dir$ attributes optimization_parameter:"target_arch=skylake-avx512" ::  rect_pulse_amp_unroll_4x_r4
           use mod_fpcompare, only : Compare_Float
           real(kind=sp), dimension(1:n),  intent(out) :: Ak
           real(kind=sp), dimension(1:n),  intent(in)  :: Phik
           real(kind=sp),                  intent(in)  :: Phi0
           integer(kind=i4),               intent(in)  :: n
           real(kind=sp),                  intent(in)  :: T
           real(kind=sp), dimension(1:n),  intent(in)  :: k
           real(kind=sp),                  intent(in)  :: tin
           real(kind=sp), parameter :: pi2 = 1.5707963267948966192313216916398_sp
           real(kind=sp) :: phik0,phik1,phik2,phik3
           real(kind=sp) :: arg0,arg1,arg2,arg3
           real(kind=sp) :: k0,k1,k2,k3
           real(kind=sp) :: twoT,kpi2
           integer(kind=i4) :: i,m,m1
           twoT = 2.0_sp/T
           if(Compare_Float(tin,twoT)) then
               m=mod(n,4)
               if(m /= 0) then
                  do i=1,m
                      k0    = k(i)
                      arg0  = k0*pi2
                      Ak(i) = Phi0*(sin(arg0)/arg0) 
                  end do
                  if(n<4) return
                end if
                m1 = m+1
               !dir$ assume_aligned Ak:64
               !dir$ assume_aligned k:64
               !dir$ vector aligned
               !dir$ ivdep
               !dir$ vector vectorlength(4)
               !dir$ vector multiple_gather_scatter_by_shuffles 
               !dir$ vector always
               do i=1,m1,4
                    k0      = k(i+0)
                    arg0    = k0*pi2
                    Ak(i+0) = Phi0*(sin(arg0)/arg0) 
                    k1      = k(i+1)
                    arg1    = k1*pi2
                    Ak(i+1) = Phi0*(sin(arg1)/arg1) 
                    k2      = k(i+2)
                    arg2    = k2*pi2
                    Ak(i+2) = Phi0*(sin(arg2)/arg2) 
                    k3      = k(i+3)
                    arg3    = k3*pi2
                    Ak(i+3) = Phi0*(sin(arg3)/arg3) 
                 
                end do
             
           else
               m=mod(n,4)
               if(m /= 0) then
                  do i=1,m
                      phik0 = Phik(i)
                      Ak(i) = twoT*phik0
                  end do
                  if(n<4) return
                end if
               m1 = m+1
               !dir$ assume_aligned Ak:64
               !dir$ assume_aligned Phik:64
               !dir$ vector aligned
               !dir$ ivdep
               !dir$ vector vectorlength(4)
               !dir$ vector multiple_gather_scatter_by_shuffles 
               !dir$ vector always
               do i=1,m1,4
                    phik0   = Phik(i+0)
                    Ak(i+0) = twoT*phik0
                    phik1   = Phik(i+1)
                    Ak(i+1) = twoT*phik1
                    phik2   = Phik(i+2)
                    Ak(i+2) = twoT*phik2
                    phik3   = Phik(i+3)
                    Ak(i+3) = twoT*phik3
                                     
              end do
             
          end if
       end subroutine rect_pulse_amp_unroll_4x_r4


       subroutine rect_pulse_amp_unroll_2x_r4(Ak,Phik,Phi0,n,T,k,tin)
           !dir$ optimize:3
           !dir$ attributes code_align : 32 ::  rect_pulse_amp_unroll_2x_r4
           !dir$ attributes forceinline ::   rect_pulse_amp_unroll_2x_r4
           !dir$ attributes optimization_parameter:"target_arch=skylake-avx512" ::  rect_pulse_amp_unroll_2x_r4
           use mod_fpcompare, only : Compare_Float
           real(kind=sp), dimension(1:n),  intent(out) :: Ak
           real(kind=sp), dimension(1:n),  intent(in)  :: Phik
           real(kind=sp),                  intent(in)  :: Phi0
           integer(kind=i4),               intent(in)  :: n
           real(kind=sp),                  intent(in)  :: T
           real(kind=sp), dimension(1:n),  intent(in)  :: k
           real(kind=sp),                  intent(in)  :: tin
           real(kind=sp), parameter :: pi2 = 1.5707963267948966192313216916398_sp
           real(kind=sp) :: phik0,phik1
           real(kind=sp) :: arg0,arg1
           real(kind=sp) :: k0,k1
           real(kind=sp) :: twoT,kpi2
           integer(kind=i4) :: i,m,m1
           twoT = 2.0_sp/T
           if(Compare_Float(tin,twoT)) then
               m=mod(n,2)
               if(m /= 0) then
                  do i=1,m
                      k0    = k(i)
                      arg0  = k0*pi2
                      Ak(i) = Phi0*(sin(arg0)/arg0) 
                  end do
                  if(n<2) return
                end if
                m1 = m+1
               !dir$ assume_aligned Ak:64
               !dir$ assume_aligned k:64
               !dir$ vector aligned
               !dir$ ivdep
               !dir$ vector vectorlength(4)
               !dir$ vector multiple_gather_scatter_by_shuffles 
               !dir$ vector always
               do i=1,m1,2
                    k0      = k(i+0)
                    arg0    = k0*pi2
                    Ak(i+0) = Phi0*(sin(arg0)/arg0) 
                    k1      = k(i+1)
                    arg1    = k1*pi2
                    Ak(i+1) = Phi0*(sin(arg1)/arg1) 
               end do
             
           else
               m=mod(n,2)
               if(m /= 0) then
                  do i=1,m
                      phik0 = Phik(i)
                      Ak(i) = twoT*phik0
                  end do
                  if(n<2) return
                end if
               m1 = m+1
               !dir$ assume_aligned Ak:64
               !dir$ assume_aligned Phik:64
               !dir$ vector aligned
               !dir$ ivdep
               !dir$ vector vectorlength(4)
               !dir$ vector multiple_gather_scatter_by_shuffles 
               !dir$ vector always
               do i=1,m1,2
                    phik0   = Phik(i+0)
                    Ak(i+0) = twoT*phik0
                    phik1   = Phik(i+1)
                    Ak(i+1) = twoT*phik1
                                                        
              end do
             
          end if
       end subroutine rect_pulse_amp_unroll_2x_r4



       subroutine rect_pulse_amp_unroll_16x_r8(Ak,Phik,Phi0,n,T,k,tin)
           !dir$ optimize:3
           !dir$ attributes code_align : 32 ::  rect_pulse_amp_unroll_16x_r8
           !dir$ attributes forceinline ::   rect_pulse_amp_unroll_16x_r8
           !dir$ attributes optimization_parameter:"target_arch=skylake-avx512" ::  rect_pulse_amp_unroll_16x_r8
           use mod_fpcompare, only : Compare_Float
           real(kind=dp), dimension(1:n),  intent(out) :: Ak
           real(kind=dp), dimension(1:n),  intent(in)  :: Phik
           real(kind=dp),                  intent(in)  :: Phi0
           integer(kind=i4),               intent(in)  :: n
           real(kind=dp),                  intent(in)  :: T
           real(kind=dp), dimension(1:n),  intent(in)  :: k
           real(kind=dp),                  intent(in)  :: tin
           real(kind=dp), parameter :: pi2 = 1.5707963267948966192313216916398_dp
           real(kind=dp) :: phik0,phik1,phik2,phik3,phik4,phik5,phik6,phik7
           real(kind=dp) :: phik8,phik9,phik10,phik11,phik12,phik13,phik14,phik15
           real(kind=dp) :: arg0,arg1,arg2,arg3,arg4,arg5,arg6,arg7
           real(kind=dp) :: arg8,arg9,arg10,arg11,arg12,arg13,arg14,arg15
           real(kind=dp) :: k0,k1,k2,k3,k4,k5,k6,k7
           real(kind=dp) :: k8,k9,k10,k11,k12,k13,k14,k15
           real(kind=dp) :: twoT,kpi2
           integer(kind=i4) :: i,m,m1
           twoT = 2.0_dp/T
           if(Compare_Float(tin,twoT)) then
               m=mod(n,16)
               if(m /= 0) then
                  do i=1,m
                      k0    = k(i)
                      arg0  = k0*pi2
                      Ak(i) = Phi0*(sin(arg0)/arg0) 
                  end do
                  if(n<16) return
                end if
                m1 = m+1
               !dir$ assume_aligned Ak:64
               !dir$ assume_aligned k:64
               !dir$ vector aligned
               !dir$ ivdep
               !dir$ vector vectorlength(8)
               !dir$ vector multiple_gather_scatter_by_shuffles 
               !dir$ vector always
               do i=1,m1,16
                    k0      = k(i+0)
                    arg0    = k0*pi2
                    Ak(i+0) = Phi0*(sin(arg0)/arg0) 
                    k1      = k(i+1)
                    arg1    = k1*pi2
                    Ak(i+1) = Phi0*(sin(arg1)/arg1) 
                    k2      = k(i+2)
                    arg2    = k2*pi2
                    Ak(i+2) = Phi0*(sin(arg2)/arg2) 
                    k3      = k(i+3)
                    arg3    = k3*pi2
                    Ak(i+3) = Phi0*(sin(arg3)/arg3) 
                    k4      = k(i+4)
                    arg4    = k4*pi2
                    Ak(i+4) = Phi0*(sin(arg4)/arg4) 
                    k5      = k(i+5)
                    arg5    = k5*pi2
                    Ak(i+5) = Phi0*(sin(arg5)/arg5) 
                    k6      = k(i+6)
                    arg6    = k6*pi2
                    Ak(i+6) = Phi0*(sin(arg6)/arg6)
                    k7      = k(i+7)
                    arg7    = k7*pi2
                    Ak(i+7) = Phi0*(sin(arg7)/arg7)   
                    k08     = k(i+8)
                    arg8    = k8*pi2
                    Ak(i+8) = Phi0*(sin(arg8)/arg8) 
                    k9      = k(i+9)
                    arg9    = k9*pi2
                    Ak(i+9) = Phi0*(sin(arg9)/arg9) 
                    k10     = k(i+10)
                    arg10   = k10*pi2
                    Ak(i+10)= Phi0*(sin(arg10)/arg10) 
                    k11     = k(i+11)
                    arg11   = k11*pi2
                    Ak(i+11)= Phi0*(sin(arg11)/arg11) 
                    k12     = k(i+12)
                    arg12   = k12*pi2
                    Ak(i+12)= Phi0*(sin(arg12)/arg12) 
                    k13     = k(i+13)
                    arg13   = k13*pi2
                    Ak(i+13)= Phi0*(sin(arg13)/arg13) 
                    k14     = k(i+14)
                    arg14   = k14*pi2
                    Ak(i+14)= Phi0*(sin(arg14)/arg14)
                    k15     = k(i+15)
                    arg155  = k15*pi2
                    Ak(i+15)= Phi0*(sin(arg15)/arg15)   
               end do
             
           else
               m=mod(n,16)
               if(m /= 0) then
                  do i=1,m
                      phik0 = Phik(i)
                      Ak(i) = twoT*phik0
                  end do
                  if(n<16) return
                end if
               m1 = m+1
               !dir$ assume_aligned Ak:64
               !dir$ assume_aligned Phik:64
               !dir$ vector aligned
               !dir$ ivdep
               !dir$ vector vectorlength(8)
               !dir$ vector multiple_gather_scatter_by_shuffles 
               !dir$ vector always
               do i=1,m1,16
                    phik0   = Phik(i+0)
                    Ak(i+0) = twoT*phik0
                    phik1   = Phik(i+1)
                    Ak(i+1) = twoT*phik1
                    phik2   = Phik(i+2)
                    Ak(i+2) = twoT*phik2
                    phik3   = Phik(i+3)
                    Ak(i+3) = twoT*phik3
                    phik4   = Phik(i+4)
                    Ak(i+4) = twoT*phik4
                    phik5   = Phik(i+5)
                    Ak(i+5) = twoT*phik5
                    phik6   = Phik(i+6)
                    Ak(i+6) = twoT*phik6
                    phik7   = Phik(i+7)
                    Ak(i+7) = twoT*phik7
                    phik8   = Phik(i+8)
                    Ak(i+8) = twoT*phik8
                    phik9   = Phik(i+9)
                    Ak(i+9) = twoT*phik9
                    phik10  = Phik(i+10)
                    Ak(i+10)= twoT*phik10
                    phik11  = Phik(i+11)
                    Ak(i+11)= twoT*phik11
                    phik12  = Phik(i+12)
                    Ak(i+12)= twoT*phik12
                    phik13  = Phik(i+13)
                    Ak(i+13)= twoT*phik13
                    phik14  = Phik(i+14)
                    Ak(i+14)= twoT*phik14
                    phik15  = Phik(i+15)
                    Ak(i+15) = twoT*phik15
              end do
             
          end if
       end subroutine rect_pulse_amp_unroll_16x_r8


       subroutine rect_pulse_amp_unroll_8x_r8(Ak,Phik,Phi0,n,T,k,tin)
           !dir$ optimize:3
           !dir$ attributes code_align : 32 ::  rect_pulse_amp_unroll_8x_r8
           !dir$ attributes forceinline ::   rect_pulse_amp_unroll_8x_r8
           !dir$ attributes optimization_parameter:"target_arch=skylake-avx512" ::  rect_pulse_amp_unroll_8x_r8
           use mod_fpcompare, only : Compare_Float
           real(kind=dp), dimension(1:n),  intent(out) :: Ak
           real(kind=dp), dimension(1:n),  intent(in)  :: Phik
           real(kind=dp),                  intent(in)  :: Phi0
           integer(kind=i4),               intent(in)  :: n
           real(kind=dp),                  intent(in)  :: T
           real(kind=dp), dimension(1:n),  intent(in)  :: k
           real(kind=dp),                  intent(in)  :: tin
           real(kind=dp), parameter :: pi2 = 1.5707963267948966192313216916398_dp
           real(kind=dp) :: phik0,phik1,phik2,phik3,phik4,phik5,phik6,phik7
           real(kind=dp) :: arg0,arg1,arg2,arg3,arg4,arg5,arg6,arg7
           real(kind=dp) :: k0,k1,k2,k3,k4,k5,k6,k7
           real(kind=dp) :: twoT,kpi2
           integer(kind=i4) :: i,m,m1
           twoT = 2.0_dp/T
           if(Compare_Float(tin,twoT)) then
               m=mod(n,8)
               if(m /= 0) then
                  do i=1,m
                      k0    = k(i)
                      arg0  = k0*pi2
                      Ak(i) = Phi0*(sin(arg0)/arg0) 
                  end do
                  if(n<8) return
                end if
                m1 = m+1
               !dir$ assume_aligned Ak:64
               !dir$ assume_aligned k:64
               !dir$ vector aligned
               !dir$ ivdep
               !dir$ vector vectorlength(8)
               !dir$ vector multiple_gather_scatter_by_shuffles 
               !dir$ vector always
               do i=1,m1,8
                    k0      = k(i+0)
                    arg0    = k0*pi2
                    Ak(i+0) = Phi0*(sin(arg0)/arg0) 
                    k1      = k(i+1)
                    arg1    = k1*pi2
                    Ak(i+1) = Phi0*(sin(arg1)/arg1) 
                    k2      = k(i+2)
                    arg2    = k2*pi2
                    Ak(i+2) = Phi0*(sin(arg2)/arg2) 
                    k3      = k(i+3)
                    arg3    = k3*pi2
                    Ak(i+3) = Phi0*(sin(arg3)/arg3) 
                    k4      = k(i+4)
                    arg4    = k4*pi2
                    Ak(i+4) = Phi0*(sin(arg4)/arg4) 
                    k5      = k(i+5)
                    arg5    = k5*pi2
                    Ak(i+5) = Phi0*(sin(arg5)/arg5) 
                    k6      = k(i+6)
                    arg6    = k6*pi2
                    Ak(i+6) = Phi0*(sin(arg6)/arg6)
                    k7      = k(i+7)
                    arg7    = k7*pi2
                    Ak(i+7) = Phi0*(sin(arg7)/arg7)   
                end do
             
           else
               m=mod(n,8)
               if(m /= 0) then
                  do i=1,m
                      phik0 = Phik(i)
                      Ak(i) = twoT*phik0
                  end do
                  if(n<8) return
                end if
               m1 = m+1
               !dir$ assume_aligned Ak:64
               !dir$ assume_aligned Phik:64
               !dir$ vector aligned
               !dir$ ivdep
               !dir$ vector vectorlength(8)
               !dir$ vector multiple_gather_scatter_by_shuffles 
               !dir$ vector always
               do i=1,m1,8
                    phik0   = Phik(i+0)
                    Ak(i+0) = twoT*phik0
                    phik1   = Phik(i+1)
                    Ak(i+1) = twoT*phik1
                    phik2   = Phik(i+2)
                    Ak(i+2) = twoT*phik2
                    phik3   = Phik(i+3)
                    Ak(i+3) = twoT*phik3
                    phik4   = Phik(i+4)
                    Ak(i+4) = twoT*phik4
                    phik5   = Phik(i+5)
                    Ak(i+5) = twoT*phik5
                    phik6   = Phik(i+6)
                    Ak(i+6) = twoT*phik6
                    phik7   = Phik(i+7)
                    Ak(i+7) = twoT*phik7
                   
              end do
             
          end if
       end subroutine rect_pulse_amp_unroll_8x_r8


       subroutine rect_pulse_amp_unroll_4x_r8(Ak,Phik,Phi0,n,T,k,tin)
           !dir$ optimize:3
           !dir$ attributes code_align : 32 ::  rect_pulse_amp_unroll_4x_r8
           !dir$ attributes forceinline ::   rect_pulse_amp_unroll_4x_r8
           !dir$ attributes optimization_parameter:"target_arch=skylake-avx512" ::  rect_pulse_amp_unroll_4x_r8
           use mod_fpcompare, only : Compare_Float
           real(kind=dp), dimension(1:n),  intent(out) :: Ak
           real(kind=dp), dimension(1:n),  intent(in)  :: Phik
           real(kind=dp),                  intent(in)  :: Phi0
           integer(kind=i4),               intent(in)  :: n
           real(kind=dp),                  intent(in)  :: T
           real(kind=dp), dimension(1:n),  intent(in)  :: k
           real(kind=dp),                  intent(in)  :: tin
           real(kind=dp), parameter :: pi2 = 1.5707963267948966192313216916398_dp
           real(kind=dp) :: phik0,phik1,phik2,phik3
           real(kind=dp) :: arg0,arg1,arg2,arg3
           real(kind=dp) :: k0,k1,k2,k3
           real(kind=dp) :: twoT,kpi2
           integer(kind=i4) :: i,m,m1
           twoT = 2.0_dp/T
           if(Compare_Float(tin,twoT)) then
               m=mod(n,4)
               if(m /= 0) then
                  do i=1,m
                      k0    = k(i)
                      arg0  = k0*pi2
                      Ak(i) = Phi0*(sin(arg0)/arg0) 
                  end do
                  if(n<4) return
                end if
                m1 = m+1
               !dir$ assume_aligned Ak:64
               !dir$ assume_aligned k:64
               !dir$ vector aligned
               !dir$ ivdep
               !dir$ vector vectorlength(8)
               !dir$ vector multiple_gather_scatter_by_shuffles 
               !dir$ vector always
               do i=1,m1,4
                    k0      = k(i+0)
                    arg0    = k0*pi2
                    Ak(i+0) = Phi0*(sin(arg0)/arg0) 
                    k1      = k(i+1)
                    arg1    = k1*pi2
                    Ak(i+1) = Phi0*(sin(arg1)/arg1) 
                    k2      = k(i+2)
                    arg2    = k2*pi2
                    Ak(i+2) = Phi0*(sin(arg2)/arg2) 
                    k3      = k(i+3)
                    arg3    = k3*pi2
                    Ak(i+3) = Phi0*(sin(arg3)/arg3) 
                end do
             
           else
               m=mod(n,4)
               if(m /= 0) then
                  do i=1,m
                      phik0 = Phik(i)
                      Ak(i) = twoT*phik0
                  end do
                  if(n<4) return
                end if
               m1 = m+1
               !dir$ assume_aligned Ak:64
               !dir$ assume_aligned Phik:64
               !dir$ vector aligned
               !dir$ ivdep
               !dir$ vector vectorlength(8)
               !dir$ vector multiple_gather_scatter_by_shuffles 
               !dir$ vector always
               do i=1,m1,4
                    phik0   = Phik(i+0)
                    Ak(i+0) = twoT*phik0
                    phik1   = Phik(i+1)
                    Ak(i+1) = twoT*phik1
                    phik2   = Phik(i+2)
                    Ak(i+2) = twoT*phik2
                    phik3   = Phik(i+3)
                    Ak(i+3) = twoT*phik3
                                    
              end do
             
          end if
       end subroutine rect_pulse_amp_unroll_4x_r8


       subroutine rect_pulse_amp_unroll_2x_r8(Ak,Phik,Phi0,n,T,k,tin)
           !dir$ optimize:3
           !dir$ attributes code_align : 32 ::  rect_pulse_amp_unroll_2x_r8
           !dir$ attributes forceinline ::   rect_pulse_amp_unroll_2x_r8
           !dir$ attributes optimization_parameter:"target_arch=skylake-avx512" ::  rect_pulse_amp_unroll_2x_r8
           use mod_fpcompare, only : Compare_Float
           real(kind=dp), dimension(1:n),  intent(out) :: Ak
           real(kind=dp), dimension(1:n),  intent(in)  :: Phik
           real(kind=dp),                  intent(in)  :: Phi0
           integer(kind=i4),               intent(in)  :: n
           real(kind=dp),                  intent(in)  :: T
           real(kind=dp), dimension(1:n),  intent(in)  :: k
           real(kind=dp),                  intent(in)  :: tin
           real(kind=dp), parameter :: pi2 = 1.5707963267948966192313216916398_dp
           real(kind=dp) :: phik0,phik1
           real(kind=dp) :: arg0,arg1
           real(kind=dp) :: k0,k1
           real(kind=dp) :: twoT,kpi2
           integer(kind=i4) :: i,m,m1
           twoT = 2.0_dp/T
           if(Compare_Float(tin,twoT)) then
               m=mod(n,2)
               if(m /= 0) then
                  do i=1,m
                      k0    = k(i)
                      arg0  = k0*pi2
                      Ak(i) = Phi0*(sin(arg0)/arg0) 
                  end do
                  if(n<2) return
                end if
                m1 = m+1
               !dir$ assume_aligned Ak:64
               !dir$ assume_aligned k:64
               !dir$ vector aligned
               !dir$ ivdep
               !dir$ vector vectorlength(8)
               !dir$ vector multiple_gather_scatter_by_shuffles 
               !dir$ vector always
               do i=1,m1,2
                    k0      = k(i+0)
                    arg0    = k0*pi2
                    Ak(i+0) = Phi0*(sin(arg0)/arg0) 
                    k1      = k(i+1)
                    arg1    = k1*pi2
                    Ak(i+1) = Phi0*(sin(arg1)/arg1) 
                end do
             
           else
               m=mod(n,2)
               if(m /= 0) then
                  do i=1,m
                      phik0 = Phik(i)
                      Ak(i) = twoT*phik0
                  end do
                  if(n<2) return
                end if
               m1 = m+1
               !dir$ assume_aligned Ak:64
               !dir$ assume_aligned Phik:64
               !dir$ vector aligned
               !dir$ ivdep
               !dir$ vector vectorlength(8)
               !dir$ vector multiple_gather_scatter_by_shuffles 
               !dir$ vector always
               do i=1,m1,2
                    phik0   = Phik(i+0)
                    Ak(i+0) = twoT*phik0
                    phik1   = Phik(i+1)
                    Ak(i+1) = twoT*phik1
                                                      
              end do
             
          end if
       end subroutine rect_pulse_amp_unroll_2x_r8



        

end module eos_sensor
