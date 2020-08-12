; ModuleID = '09_conv2d_a.prelto.1.bc'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux_gnu"

@temp0 = global [1 x [8 x [8 x [2 x float]]]] zeroinitializer, align 8
@param1 = global [3 x [3 x [1 x [2 x float]]]] zeroinitializer, align 8
@param0 = global [1 x [8 x [8 x [1 x float]]]] zeroinitializer, align 8

define float @main() #0 {
convolution.loop_body.dim.1.lr.ph:
  br label %convolution.loop_body.dim.2.lr.ph

convolution.loop_body.dim.2.lr.ph:                ; preds = %convolution.loop_exit.dim.2, %convolution.loop_body.dim.1.lr.ph
  %convolution.indvar.dim.126 = phi i64 [ 0, %convolution.loop_body.dim.1.lr.ph ], [ %invar.inc1, %convolution.loop_exit.dim.2 ]
  br label %convolution.loop_body.dim.3.lr.ph

convolution.loop_body.dim.3.lr.ph:                ; preds = %convolution.loop_exit.dim.3, %convolution.loop_body.dim.2.lr.ph
  %convolution.indvar.dim.223 = phi i64 [ 0, %convolution.loop_body.dim.2.lr.ph ], [ %invar.inc2, %convolution.loop_exit.dim.3 ]
  br label %convolution.inner.loop_body.k0.lr.ph

convolution.inner.loop_body.k0.lr.ph:             ; preds = %convolution.inner.loop_exit.k0, %convolution.loop_body.dim.3.lr.ph
  %convolution.indvar.dim.320 = phi i64 [ 0, %convolution.loop_body.dim.3.lr.ph ], [ %invar.inc3, %convolution.inner.loop_exit.k0 ]
  br label %convolution.inner.loop_body.k1.lr.ph

convolution.inner.loop_body.k1.lr.ph:             ; preds = %convolution.inner.loop_exit.k1, %convolution.inner.loop_body.k0.lr.ph
  %0 = phi float [ 0.000000e+00, %convolution.inner.loop_body.k0.lr.ph ], [ %20, %convolution.inner.loop_exit.k1 ]
  %1 = phi float [ 0.000000e+00, %convolution.inner.loop_body.k0.lr.ph ], [ %21, %convolution.inner.loop_exit.k1 ]
  %convolution.inner.indvar.k016 = phi i64 [ 0, %convolution.inner.loop_body.k0.lr.ph ], [ %invar.inc4, %convolution.inner.loop_exit.k1 ]
  %2 = add i64 %convolution.indvar.dim.126, -1
  %3 = add i64 %2, %convolution.inner.indvar.k016
  %4 = icmp ult i64 %3, 8
  %5 = add i64 %convolution.indvar.dim.223, -1
  br i1 %4, label %convolution.inner.loop_body.iz.lr.ph.us, label %convolution.inner.loop_exit.iz

convolution.inner.loop_exit.iz.us:                ; preds = %convolution.inner.loop_header.iz.convolution.inner.loop_exit.iz_crit_edge.us-lcssa.us.us, %convolution.inner.loop_body.iz.lr.ph.us
  %6 = phi float [ %18, %convolution.inner.loop_header.iz.convolution.inner.loop_exit.iz_crit_edge.us-lcssa.us.us ], [ %9, %convolution.inner.loop_body.iz.lr.ph.us ]
  %7 = phi float [ %18, %convolution.inner.loop_header.iz.convolution.inner.loop_exit.iz_crit_edge.us-lcssa.us.us ], [ %10, %convolution.inner.loop_body.iz.lr.ph.us ]
  %invar.inc5.us = add nuw nsw i64 %convolution.inner.indvar.k14.us, 1
  %8 = icmp ugt i64 %invar.inc5.us, 2
  br i1 %8, label %convolution.inner.loop_exit.k1, label %convolution.inner.loop_body.iz.lr.ph.us, !llvm.loop !0

convolution.inner.loop_body.iz.lr.ph.us:          ; preds = %convolution.inner.loop_exit.iz.us, %convolution.inner.loop_body.k1.lr.ph
  %9 = phi float [ %6, %convolution.inner.loop_exit.iz.us ], [ %0, %convolution.inner.loop_body.k1.lr.ph ]
  %10 = phi float [ %7, %convolution.inner.loop_exit.iz.us ], [ %1, %convolution.inner.loop_body.k1.lr.ph ]
  %convolution.inner.indvar.k14.us = phi i64 [ %invar.inc5.us, %convolution.inner.loop_exit.iz.us ], [ 0, %convolution.inner.loop_body.k1.lr.ph ]
  %11 = add i64 %5, %convolution.inner.indvar.k14.us
  %12 = icmp ult i64 %11, 8
  br i1 %12, label %convolution.inner.loop_header.iz.convolution.inner.loop_exit.iz_crit_edge.us-lcssa.us.us, label %convolution.inner.loop_exit.iz.us

convolution.inner.loop_header.iz.convolution.inner.loop_exit.iz_crit_edge.us-lcssa.us.us: ; preds = %convolution.inner.loop_body.iz.lr.ph.us
  %13 = getelementptr inbounds [3 x [3 x [1 x [2 x float]]]]* @param1, i64 0, i64 %convolution.inner.indvar.k016, i64 %convolution.inner.indvar.k14.us, i64 0, i64 %convolution.indvar.dim.320
  %14 = load volatile float* %13, align 4
  %15 = getelementptr inbounds [1 x [8 x [8 x [1 x float]]]]* @param0, i64 0, i64 0, i64 %3, i64 %11, i64 0
  %16 = load volatile float* %15, align 4
  %17 = fmul float %14, %16
  %18 = fadd float %9, %17
  br label %convolution.inner.loop_exit.iz.us

convolution.inner.loop_exit.iz:                   ; preds = %convolution.inner.loop_exit.iz, %convolution.inner.loop_body.k1.lr.ph
  %convolution.inner.indvar.k14 = phi i64 [ %invar.inc5, %convolution.inner.loop_exit.iz ], [ 0, %convolution.inner.loop_body.k1.lr.ph ]
  %invar.inc5 = add nuw nsw i64 %convolution.inner.indvar.k14, 1
  %19 = icmp ugt i64 %invar.inc5, 2
  br i1 %19, label %convolution.inner.loop_exit.k1, label %convolution.inner.loop_exit.iz, !llvm.loop !0

convolution.inner.loop_exit.k1:                   ; preds = %convolution.inner.loop_exit.iz, %convolution.inner.loop_exit.iz.us
  %20 = phi float [ %6, %convolution.inner.loop_exit.iz.us ], [ %0, %convolution.inner.loop_exit.iz ]
  %21 = phi float [ %7, %convolution.inner.loop_exit.iz.us ], [ %1, %convolution.inner.loop_exit.iz ]
  %invar.inc4 = add nuw nsw i64 %convolution.inner.indvar.k016, 1
  %22 = icmp ugt i64 %invar.inc4, 2
  br i1 %22, label %convolution.inner.loop_exit.k0, label %convolution.inner.loop_body.k1.lr.ph, !llvm.loop !2

convolution.inner.loop_exit.k0:                   ; preds = %convolution.inner.loop_exit.k1
  %23 = getelementptr inbounds [1 x [8 x [8 x [2 x float]]]]* @temp0, i64 0, i64 0, i64 %convolution.indvar.dim.126, i64 %convolution.indvar.dim.223, i64 %convolution.indvar.dim.320
  store volatile float %21, float* %23, align 4
  %invar.inc3 = add nuw nsw i64 %convolution.indvar.dim.320, 1
  %24 = icmp eq i64 %convolution.indvar.dim.320, 0
  br i1 %24, label %convolution.inner.loop_body.k0.lr.ph, label %convolution.loop_exit.dim.3, !llvm.loop !3

convolution.loop_exit.dim.3:                      ; preds = %convolution.inner.loop_exit.k0
  %invar.inc2 = add nuw nsw i64 %convolution.indvar.dim.223, 1
  %25 = icmp ugt i64 %invar.inc2, 7
  br i1 %25, label %convolution.loop_exit.dim.2, label %convolution.loop_body.dim.3.lr.ph, !llvm.loop !4

convolution.loop_exit.dim.2:                      ; preds = %convolution.loop_exit.dim.3
  %invar.inc1 = add nuw nsw i64 %convolution.indvar.dim.126, 1
  %26 = icmp ugt i64 %invar.inc1, 7
  br i1 %26, label %convolution.loop_exit.dim.0, label %convolution.loop_body.dim.2.lr.ph, !llvm.loop !5

convolution.loop_exit.dim.0:                      ; preds = %convolution.loop_exit.dim.2
  %leflow_gep = getelementptr inbounds [1 x [8 x [8 x [2 x float]]]]* @temp0, i64 0, i64 0, i64 0, i64 0, i64 0
  %leflow_retval = load volatile float* %leflow_gep, align 4
  ret float %leflow_retval
}

attributes #0 = { "no-frame-pointer-elim"="false" }

!0 = metadata !{metadata !0, metadata !1}
!1 = metadata !{metadata !"llvm.loop.vectorize.enable", i1 false}
!2 = metadata !{metadata !2, metadata !1}
!3 = metadata !{metadata !3, metadata !1}
!4 = metadata !{metadata !4, metadata !1}
!5 = metadata !{metadata !5, metadata !1}
