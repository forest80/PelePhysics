module transport_module

  use eos_type_module
  use transport_type_module

  implicit none

  character (len=64) :: transport_name = "constant"

contains

  subroutine transport_init
    implicit none
  end subroutine transport_init


  subroutine transport_close
    implicit none
  end subroutine transport_close

  
  subroutine transport(which, coeff)

    use extern_probin_module, only: const_conductivity, const_viscosity,&
         const_bulk_viscosity, const_diffusivity

    implicit none

    type (wtr_t), intent(in   ) :: which
    type (trv_t), intent(inout) :: coeff

    if (which % wtr_get_lam) then
       coeff % lam = const_conductivity
    endif

    if (which % wtr_get_mu) then
       coeff % mu = const_viscosity
    endif

    if (which % wtr_get_xi) then
       coeff % xi = const_bulk_viscosity
    endif

    if (which % wtr_get_Ddiag) then
       coeff % Ddiag = const_diffusivity
    endif

  end subroutine transport
  
  subroutine get_transport_coeffs( &
       lo,hi, &
       massfrac,    mf_lo, mf_hi, &
       temperature,  t_lo,  t_hi, &
       density,      r_lo,  r_hi, &
       D,            D_lo,  D_hi, &
       mu,          mu_lo, mu_hi, &
       xi,          xi_lo, xi_hi, &
       lam,        lam_lo,lam_hi) &
       bind(C, name="get_transport_coeffs")

    use chemistry_module, only: nspecies
    use eos_module

    implicit none

    integer         , intent(in   ) ::     lo(3),    hi(3)
    integer         , intent(in   ) ::  mf_lo(3), mf_hi(3)
    integer         , intent(in   ) ::   t_lo(3),  t_hi(3)
    integer         , intent(in   ) ::   r_lo(3),  r_hi(3)
    integer         , intent(in   ) ::   D_lo(3),  D_hi(3)
    integer         , intent(in   ) ::  mu_lo(3), mu_hi(3)
    integer         , intent(in   ) ::  xi_lo(3), xi_hi(3)
    integer         , intent(in   ) :: lam_lo(3),lam_hi(3)
    real (kind=dp_t), intent(in   ) :: massfrac(mf_lo(1):mf_hi(1),mf_lo(2):mf_hi(2),mf_lo(3):mf_hi(3),nspecies)
    real (kind=dp_t), intent(in   ) :: temperature(t_lo(1):t_hi(1),t_lo(2):t_hi(2),t_lo(3):t_hi(3))
    real (kind=dp_t), intent(in   ) :: density(r_lo(1):r_hi(1),r_lo(2):r_hi(2),r_lo(3):r_hi(3))
    real (kind=dp_t), intent(inout) :: D(D_lo(1):D_hi(1),D_lo(2):D_hi(2),D_lo(3):D_hi(3),nspecies)
    real (kind=dp_t), intent(inout) :: mu(mu_lo(1):mu_hi(1),mu_lo(2):mu_hi(2),mu_lo(3):mu_hi(3))
    real (kind=dp_t), intent(inout) :: xi(xi_lo(1):xi_hi(1),xi_lo(2):xi_hi(2),xi_lo(3):xi_hi(3))
    real (kind=dp_t), intent(inout) :: lam(lam_lo(1):lam_hi(1),lam_lo(2):lam_hi(2),lam_lo(3):lam_hi(3))

    ! local variables
    integer      :: i, j, k, n, np
    type (wtr_t) :: which_trans
    type (trv_t) :: coeff

    np = hi(1)-lo(1)+1
    call build(coeff,np)

    which_trans % wtr_get_xi    = .true.
    which_trans % wtr_get_mu    = .true.
    which_trans % wtr_get_lam   = .true.
    which_trans % wtr_get_Ddiag = .true.

    do k = lo(3),hi(3)
       do j = lo(2),hi(2)

          do i=1,np
             coeff%eos_state(i)%massfrac(1:nspecies) = massfrac(lo(1)+i-1,j,k,1:nspecies)
          end do

          do i=lo(1),hi(1)
             coeff%eos_state(i-lo(1)+1)%T = temperature(i,j,k)
             coeff%eos_state(i-lo(1)+1)%rho = density(i,j,k)
          end do

          call transport(which_trans, coeff)

          do i=lo(1),hi(1)
             mu(i,j,k)  = coeff %  mu(i-lo(1)+1)
             xi(i,j,k)  = coeff %  xi(i-lo(1)+1)
             lam(i,j,k) = coeff % lam(i-lo(1)+1)
          end do
          do n=1,nspecies
             do i=lo(1),hi(1)
                D(i,j,k,n) = coeff % Ddiag(i-lo(1)+1,n)
             end do
          end do

       end do
    end do

    call destroy(coeff)

  end subroutine get_transport_coeffs

end module transport_module

