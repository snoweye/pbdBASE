#' rpdgeqpf
#' 
#' QR.
#' 
#' For advanced users only. See pbdDMAT for high-level functions.
#' 
#' @param tol 
#' Numerical tolerance for the QR.
#' @param m,n
#' Problem size.
#' @param x
#' Matrix.
#' @param descx
#' ScaLAPACK descriptor array.
#' @param comm
#' An MPI (not BLACS) communicator.
#' @return A list contains QR results.
#' 
#' @useDynLib pbdBASE R_PDGEQPF
#' @export
base.rpdgeqpf <- function(tol, m, n, x, descx, comm = .pbd_env$SPMD.CT$comm)
{
  if (!is.double(x))
    storage.mode(x) <- "double"

  ret <- .Call(R_PDGEQPF, as.double(tol), as.integer(m), as.integer(n), x, as.integer(descx))
  if (comm.rank(comm) != 0)
    rank <- 0L
  else
    rank <- ret$rank
  
  ret$rank <- pbdMPI::allreduce(rank, comm=comm)
  
  if (ret$INFO!=0)
    pbdMPI::comm.warning(paste("ScaLAPACK returned INFO=", ret$INFO, "; returned solution is likely invalid", sep=""), comm=comm)
  
  ret
}



#' rpdorgqr
#' 
#' Recover Q.
#' 
#' For advanced users only. See pbdDMAT for high-level functions.
#' 
#' @param m,n
#' Problem size.
#' @param k
#' Number of elementary reflectors.
#' @param qr
#' QR decomposition.
#' @param descqr
#' ScaLAPACK descriptor array.
#' @param tau
#' Elementary reflectors.
#' @return Q matrix of the QR decomposition.
#' 
#' @useDynLib pbdBASE R_PDORGQR
#' @export
base.rpdorgqr <- function(m, n, k, qr, descqr, tau)
{
  if (!is.double(qr))
    storage.mode(qr) <- "double"
  
  if (!is.double(tau))
    storage.mode(tau) <- "double"
  
  out <- .Call(R_PDORGQR,
            as.integer(m), as.integer(n), as.integer(k),
            qr, as.integer(dim(qr)), as.integer(descqr), tau)
  
  if (out$INFO!=0)
    pbdMPI::comm.warning(paste("ScaLAPACK returned INFO=", out$INFO, "; returned solution is likely invalid", sep=""))
  
  ret <- out$A
  
  ret
}



#' rpdormqr
#' 
#' op(Q) * y.
#' 
#' For advanced users only. See pbdDMAT for high-level functions.
#' 
#' @param side
#' 'L' or 'R', for left or righth application of Q matrix.
#' @param trans
#' Q or Q^T.
#' @param m,n
#' Problem size.
#' @param k
#' Number of elementary reflectors.
#' @param qr
#' QR decomposition.
#' @param descqr
#' ScaLAPACK descriptor array.
#' @param tau
#' Elementary reflectors.
#' @param c
#' Vector.
#' @param descc
#' ScaLAPACK descriptor array.
#' 
#' @useDynLib pbdBASE R_PDORMQR
#' @export
base.rpdormqr <- function(side, trans, m, n, k, qr, descqr, tau, c, descc)
{
  # FIXME adjustment for weird lda issue
  mxlda <- pbdMPI::allreduce(descqr[9], op='max')
  mxldb <- pbdMPI::allreduce(descc[9], op='max')
  
  if (descqr[9]==1)
    descqr[9] <- mxlda
  if (descc[9]==1)
    descc[9] <- mxldb
  
  if (!is.double(qr))
    storage.mode(qr) <- "double"
  if (!is.double(c))
    storage.mode(c) <- "double"
  if (!is.double(tau))
    storage.mode(tau) <- "double"
  
  out <- .Call(R_PDORMQR,
            as.character(side), as.character(trans),
            as.integer(m), as.integer(n), as.integer(k),
            qr, as.integer(dim(qr)), as.integer(descqr),
            tau,
            c, as.integer(dim(c)), as.integer(descc))
  
  if (out$INFO!=0)
    pbdMPI::comm.warning(paste("ScaLAPACK returned INFO=", out$INFO, "; returned solution is likely invalid", sep=""))
  
  out$B
}



# -----------------------------------------------------------------------------
# LQ
# -----------------------------------------------------------------------------

#' rpdgelqf
#' 
#' LQ.
#' 
#' For advanced users only. See pbdDMAT for high-level functions.
#' 
#' @param m,n
#' Problem size.
#' @param x
#' Matrix.
#' @param descx
#' ScaLAPACK descriptor array.
#' 
#' @useDynLib pbdBASE R_PDGELQF
#' @export
base.rpdgelqf <- function(m, n, x, descx)
{
  if (!is.double(x))
    storage.mode(x) <- "double"
  
  ret <- .Call(R_PDGELQF, as.integer(m), as.integer(n), x, as.integer(descx))
  
  if (ret$INFO!=0)
    pbdMPI::comm.warning(paste("ScaLAPACK returned INFO=", ret$INFO, "; returned solution is likely invalid", sep=""))
  
  ret
}



#' rpdorglq
#' 
#' Recover Q.
#' 
#' For advanced users only. See pbdDMAT for high-level functions.
#' 
#' @param m,n
#' Problem size.
#' @param k
#' Number of elementary reflectors.
#' @param lq
#' QR decomposition.
#' @param desc
#' ScaLAPACK descriptor array.
#' @param tau
#' Elementary reflectors.
#' @return Q matrix of the QR decomposition.
#' 
#' @useDynLib pbdBASE R_PDORGLQ
#' @export
base.rpdorglq <- function(m, n, k, lq, desc, tau)
{
  if (!is.double(lq))
    storage.mode(lq) <- "double"
  
  if (!is.double(tau))
    storage.mode(tau) <- "double"
  
  out <- 
    .Call(R_PDORGLQ, as.integer(m), as.integer(n), as.integer(k), lq, as.integer(desc), tau)
  
  if (out$INFO!=0)
    pbdMPI::comm.warning(paste("ScaLAPACK returned INFO=", out$INFO, "; returned solution is likely invalid", sep=""))
  
  out$A
}
