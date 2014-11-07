
#ifndef BLAS_WRAPPERS
#define BLAS_WRAPPERS

template <class real_type>
inline void init_data(boost::multi_array_ref<real_type, 3> &x,
		      const sl_int nx, const sl_int ny, const sl_int nz)
{
  //sl_int n = nx * ny * nz;
#pragma omp parallel for shared(x) firstprivate(nx, ny, nz) schedule(dynamic)
  for (sl_int i = 0; i < nx; i++) {
    real_type *xptr = assume_aligned(&(x[i][0][0]), real_type);
    for (sl_int j = 0; j < ny * nz; j++)
      xptr[j] = 0.0;
  }
}

template <class real_type>
inline void scal_y(const real beta, boost::multi_array_ref<real_type, 3> &y,
		   const sl_int nx, const sl_int ny, const sl_int nz)
{
  // y = beta * y
  real_type b = real_type(beta);
#pragma omp parallel for shared(y) firstprivate(nx, ny, nz, b) schedule(dynamic)
  for (sl_int i = 0; i < nx; i++) {
    real_type *yptr = assume_aligned(&(y[i][0][0]), real_type);
    for (sl_int j = 0; j < ny * nz; j++)
      yptr[j] *= b;
  }
}

inline voxel_type norm_voxels(const voxel_data &v, const sl_int nx,
			      const sl_int ny, const sl_int nz)
{
  voxel_type norm = 0.0;
#pragma omp parallel for shared(v, norm) firstprivate(nx, ny, nz) schedule(dynamic)
  for (sl_int i = 0; i < nx; i++) {
    voxel_type n1 = 0.0;
    for (sl_int j = 0; j < ny; j++) {
      voxel_type n2 = 0.0;
      voxel_type *vptr = assume_aligned(&(v[i][j][0]), voxel_type);
      for (sl_int k = 0; k < nz; k++)
	n2 += vptr[k] * vptr[k];
      n1 += n2;
    }
#pragma omp atomic
    norm += n1;
  }
  return norm;
}

inline void norm_voxels(const voxel_data &v, const sl_int nx, const sl_int ny,
			const sl_int nz, voxel_1d &norm)
{
  for (int k = 0; k < nz; k++)
    norm[k] = 0.0;
#pragma omp parallel for shared(v, norm) firstprivate(nx, ny, nz) schedule(dynamic)
  for (sl_int i = 0; i < nx; i++) {
    voxel_1d n2(nz);
    for (sl_int k = 0; k < nz; k++)
      n2[k] = 0.0;
    for (sl_int j = 0; j < ny; j++) {
      voxel_type *vptr = assume_aligned(&(v[i][j][0]), voxel_type);
      for (sl_int k = 0; k < nz; k++)
	n2[k] += vptr[k] * vptr[k];
    }
    for (sl_int k = 0; k < nz; k++)
#pragma omp atomic
      norm[k] += n2[k];
  }
}

inline voxel_type norm_voxels(const voxel_data &v1, const voxel_data &v2,
			      const sl_int nx, const sl_int ny, const sl_int nz)
{
  voxel_type norm = 0.0;
#pragma omp parallel for shared(v1, v2, norm) firstprivate(nx, ny, nz) schedule(dynamic)
  for (sl_int i = 0; i < nx; i++) {
    voxel_type n1 = 0.0;
    for (sl_int j = 0; j < ny; j++) {
      voxel_type n2 = 0.0;
      voxel_type *v1ptr = assume_aligned(&(v1[i][j][0]), voxel_type);
      voxel_type *v2ptr = assume_aligned(&(v2[i][j][0]), voxel_type);
      for (sl_int k = 0; k < nz; k++)
	n2 += v1ptr[k] * v2ptr[k];
      n1 += n2;
    }
#pragma omp atomic
    norm += n1;
  }
  return norm;
}

inline pixel_type norm_pixels(const pixel_data &p, const sl_int na,
			      const sl_int nv, const sl_int nh)
{
  pixel_type norm = 0.0;
#pragma omp parallel for shared(p, norm) firstprivate(na, nv, nh) schedule(dynamic)
  for (sl_int i = 0; i < na; i++) {
    pixel_type n1 = 0.0;
    for (sl_int j = 0; j < nh; j++) {
      pixel_type n2 = 0.0;
      pixel_type *pptr = assume_aligned(&(p[i][j][0]), pixel_type);
      for (sl_int k = 0; k < nv; k++)
	n2 += pptr[k] * pptr[k];
      n1 += n2;
    }
#pragma omp atomic
    norm += n1;
  }
  return norm;
}

inline void norm_pixels(const pixel_data &p, const sl_int na, const sl_int nv,
			const sl_int nh, pixel_1d &norm)
{
  for (int k = 0; k < nv; k++)
    norm[k] = 0.0;
#pragma omp parallel for shared(p, norm) firstprivate(na, nh, nv) schedule(dynamic)
  for (sl_int i = 0; i < na; i++) {
    voxel_1d n2(nv);
    for (sl_int k = 0; k < nv; k++)
      n2[k] = 0.0;
    for (sl_int j = 0; j < nh; j++) {
      pixel_type *pptr = assume_aligned(&(p[i][j][0]), pixel_type);
      for (sl_int k = 0; k < nv; k++)
	n2[k] += pptr[k] * pptr[k];
    }
    for (sl_int k = 0; k < nv; k++)
#pragma omp atomic
      norm[k] += n2[k];
  }
}

template <class real_type>
inline void sum_axpy(const real alpha,
		     const boost::multi_array_ref<real_type, 3> &x,
		     boost::multi_array_ref<real_type, 3> &y, const sl_int nx,
		     const sl_int ny, const sl_int nz)
{
  // y += alpha * x
  real_type a = real_type(alpha);
#pragma omp parallel for shared(x, y) firstprivate(nx, ny, nz, a) schedule(dynamic)
  for (sl_int i = 0; i < nx; i++) {
    real_type *xptr = assume_aligned(&(x[i][0][0]), real_type);
    real_type *yptr = assume_aligned(&(y[i][0][0]), real_type);
    for (sl_int j = 0; j < ny * nz; j++)
      yptr[j] += a * xptr[j];
  }
}

template <class real_type>
inline void sum_axpy(const pixel_1d &alpha,
		     const boost::multi_array_ref<real_type, 3> &x,
		     boost::multi_array_ref<real_type, 3> &y, const sl_int nx,
		     const sl_int ny, const sl_int nz)
{
  // y += alpha * x
#pragma omp parallel for shared(x, y, alpha) firstprivate(nx, ny, nz) schedule(dynamic)
  for (sl_int i = 0; i < nx; i++) {
    for (sl_int j = 0; j < ny; j++) {
      real_type *xptr = assume_aligned(&(x[i][j][0]), real_type);
      real_type *yptr = assume_aligned(&(y[i][j][0]), real_type);
      pixel_type *aptr = assume_aligned(&(alpha[0]), pixel_type);
      for (sl_int k = 0; k < nz; k++)
	yptr[k] += aptr[k] * xptr[k];
    }
  }
}

template <class real_type>
inline void sub_axpy(const pixel_1d &alpha,
		     const boost::multi_array_ref<real_type, 3> &x,
		     boost::multi_array_ref<real_type, 3> &y, const sl_int na,
		     const sl_int nv, const sl_int nh, const int ppv)
{
  // y -= alpha * x
#pragma omp parallel for shared(x, y, alpha) firstprivate(na, nv, nh, ppv) schedule(dynamic)
  for (sl_int i = 0; i < na; i++) {
    for (sl_int j = 0; j < nh; j++) {
      real_type *xptr = assume_aligned(&(x[i][j][0]), real_type);
      real_type *yptr = assume_aligned(&(y[i][j][0]), real_type);
      pixel_type *aptr = assume_aligned(&(alpha[0]), pixel_type);
      for (sl_int k = 0; k < nv; k++)
	yptr[j] -= aptr[k / ppv] * xptr[k];
    }
  }
}

template <class real_type>
inline void scal_xby(const boost::multi_array_ref<real_type, 3> &x,
		     const real beta, boost::multi_array_ref<real_type, 3> &y,
		     const sl_int nx, const sl_int ny, const sl_int nz)
{
  // y = x + beta * y
  real_type b = real_type(beta);
#pragma omp parallel for shared(x, y) firstprivate(nx, ny, nz, b) schedule(dynamic)
  for (sl_int i = 0; i < nx; i++) {
    real_type *xptr = assume_aligned(&(x[i][0][0]), real_type);
    real_type *yptr = assume_aligned(&(y[i][0][0]), real_type);
    for (sl_int j = 0; j < ny * nz; j++)
      yptr[j] = b * yptr[j] + xptr[j];
  }
}

template <class real_type>
inline void scal_xby(const boost::multi_array_ref<real_type, 3> &x,
		     const voxel_1d &beta,
		     boost::multi_array_ref<real_type, 3> &y,
		     const sl_int nx, const sl_int ny, const sl_int nz)
{
  // y = x + beta * y
#pragma omp parallel for shared(x, y, beta) firstprivate(nx, ny, nz) schedule(dynamic)
  for (sl_int i = 0; i < nx; i++) {
    for (sl_int j = 0; j < ny; j++) {
      real_type *xptr = assume_aligned(&(x[i][j][0]), real_type);
      real_type *yptr = assume_aligned(&(y[i][j][0]), real_type);
      voxel_type *bptr = assume_aligned(&(beta[0]), voxel_type);
      for (sl_int k = 0; k < nz; k++)
	yptr[k] = bptr[k] * yptr[k] + xptr[k];
    }
  }
}

template <class real_type>
inline void sum_xbyz(const boost::multi_array_ref<real_type, 3> &x,
		     const real beta,
		     const boost::multi_array_ref<real_type, 3> &y,
		     boost::multi_array_ref<real_type, 3> &z,
		     const sl_int nx, const sl_int ny, const sl_int nz)
{
  // z = x + b * y
  real_type b = real_type(beta);
#pragma omp parallel for shared(x, y) firstprivate(nx, ny, nz, b) schedule(dynamic)
  for (sl_int i = 0; i < nx; i++) {
    real_type *xptr = assume_aligned(&(x[i][0][0]), real_type);
    real_type *yptr = assume_aligned(&(y[i][0][0]), real_type);
    real_type *zptr = assume_aligned(&(z[i][0][0]), real_type);
    for (sl_int j = 0; j < ny * nz; j++)
      zptr[j] = b * yptr[j] + xptr[j];
  }
}

template <class real_type>
inline void diff_xyz(const boost::multi_array_ref<real_type, 3> &x,
		     const boost::multi_array_ref<real_type, 3> &y,
		     boost::multi_array_ref<real_type, 3> &z,
		     const sl_int nx, const sl_int ny, const sl_int nz)
{
  sum_xbyz(x, -1.0, y, z, nx, ny, nz);
  /*
  // z = x - y
  sl_int n = nx * ny * nz;
#pragma omp parallel for shared(x, y) firstprivate(n) schedule(dynamic)
  for (sl_int i = 0; i < n; i++)
    (z.data())[i] = (x.data())[i] - (y.data())[i];
  */
}

inline voxel_type dot_prod(const voxel_data &x, const voxel_data &y,
			   const sl_int nx, const sl_int ny, const sl_int nz)
{
  voxel_type norm = 0.0;
#pragma omp parallel for shared(x, y, norm) firstprivate(nx, ny, nz) schedule(dynamic)
  for (sl_int i = 0; i < nx; i++) {
    voxel_type n1 = 0.0;
    for (sl_int j = 0; j < ny; j++) {
      voxel_type n2 = 0.0;
      voxel_type *xptr = assume_aligned(&(x[i][j][0]), voxel_type);
      voxel_type *yptr = assume_aligned(&(y[i][j][0]), voxel_type);
      for (sl_int k = 0; k < nz; k++)
	n2 += xptr[k] * yptr[k];
      n1 += n2;
    }
#pragma omp atomic
    norm += n1;
  }
  return norm;
}

template <class real_type>
inline void copy(const boost::multi_array_ref<real_type, 3> &x,
		 boost::multi_array_ref<real_type, 3> &y,
		 const sl_int nx, const sl_int ny, const sl_int nz)
{
  // y = x
#pragma omp parallel for shared(x, y) firstprivate(nx, ny, nz) schedule(dynamic)
  for (sl_int i = 0; i < nx; i++) {
    real_type *xptr = assume_aligned(&(x[i][0][0]), real_type);
    real_type *yptr = assume_aligned(&(y[i][0][0]), real_type);
    for (sl_int j = 0; j < ny * nz; j++)
      yptr[j] = xptr[j];
  }
}

#if defined(MKL_ILP64)

#include "mkl_cblas.h"

template <>
inline void scal_y(const real beta, boost::multi_array_ref<float, 3> &y,
		   const sl_int nx, const sl_int ny, const sl_int nz)
{
  sl_int n = nx * ny * nz;
  cblas_sscal(n, float(beta), y.data(), 1);
}

template <>
inline void scal_y(const real beta, boost::multi_array_ref<double, 3> &y,
		   const sl_int nx, const sl_int ny, const sl_int nz)
{
  sl_int n = nx * ny * nz;
  cblas_dscal(n, double(beta), y.data(), 1);
}

template <>
inline void sum_axpy(const real alpha,
		     const boost::multi_array_ref<float, 3> &x,
		     boost::multi_array_ref<float, 3> &y, const sl_int nx,
		     const sl_int ny, const sl_int nz)
{
  // y += alpha * x
  sl_int n = nx * ny * nz;
  cblas_saxpy(n, float(alpha), x.data(), 1, y.data(), 1);
}

template <>
inline void sum_axpy(const real alpha,
		     const boost::multi_array_ref<double, 3> &x,
		     boost::multi_array_ref<double, 3> &y, const sl_int nx,
		     const sl_int ny, const sl_int nz)
{
  // y += alpha * x
  sl_int n = nx * ny * nz;
  cblas_daxpy(n, double(alpha), x.data(), 1, y.data(), 1);
}

template <> inline
void copy(const boost::multi_array_ref<float, 3> &x,
	  boost::multi_array_ref<float, 3> &y, const sl_int nx,
	  const sl_int ny, const sl_int nz)
{
  cblas_scopy(nx * ny * nz, x.data(), 1, y.data(), 1);
}

template <> inline
void copy(const boost::multi_array_ref<double, 3> &x,
	  boost::multi_array_ref<double, 3> &y, const sl_int nx,
	  const sl_int ny, const sl_int nz)
{
  cblas_dcopy(nx * ny * nz, x.data(), 1, y.data(), 1);
}

#endif // MKL

#endif // BLAS_WRAPPERS
