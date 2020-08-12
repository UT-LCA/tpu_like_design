; ModuleID = '09_conv2d_a.1.bc'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux_gnu"

@temp0 = internal global [1 x [8 x [8 x [2 x float]]]] zeroinitializer, align 8
@param1 = internal global [3 x [3 x [1 x [2 x float]]]] zeroinitializer, align 8
@param0 = internal global [1 x [8 x [8 x [1 x float]]]] zeroinitializer, align 8

; Function Attrs: nounwind
define float @main() #0 {
convolution.loop_body.dim.1.lr.ph:
  br label %convolution.loop_body.dim.2.lr.ph

convolution.loop_body.dim.2.lr.ph:                ; preds = %convolution.loop_exit.dim.2, %convolution.loop_body.dim.1.lr.ph
  %convolution.indvar.dim.126 = phi i64 [ 0, %convolution.loop_body.dim.1.lr.ph ], [ %24, %convolution.loop_exit.dim.2 ]
  %0 = add i64 %convolution.indvar.dim.126, -1
  br label %convolution.loop_body.dim.3.lr.ph

convolution.loop_body.dim.3.lr.ph:                ; preds = %convolution.loop_exit.dim.3, %convolution.loop_body.dim.2.lr.ph
  %convolution.indvar.dim.223 = phi i64 [ 0, %convolution.loop_body.dim.2.lr.ph ], [ %23, %convolution.loop_exit.dim.3 ]
  %1 = add i64 %convolution.indvar.dim.223, -1
  %2 = add i64 %convolution.indvar.dim.223, -1
  br label %convolution.inner.loop_body.k0.lr.ph

convolution.inner.loop_body.k0.lr.ph:             ; preds = %convolution.inner.loop_exit.k0, %convolution.loop_body.dim.3.lr.ph
  %3 = phi i64 [ 0, %convolution.loop_body.dim.3.lr.ph ], [ %invar.inc3, %convolution.inner.loop_exit.k0 ]
  %scevgep8 = getelementptr [1 x [8 x [8 x [2 x float]]]]* @temp0, i64 0, i64 0, i64 %convolution.indvar.dim.126, i64 %convolution.indvar.dim.223, i64 %3
  br label %convolution.inner.loop_body.k1.lr.ph

convolution.inner.loop_body.k1.lr.ph:             ; preds = %convolution.inner.loop_exit.k1, %convolution.inner.loop_body.k0.lr.ph
  %4 = phi float [ 0.000000e+00, %convolution.inner.loop_body.k0.lr.ph ], [ %20, %convolution.inner.loop_exit.k1 ]
  %5 = phi float [ 0.000000e+00, %convolution.inner.loop_body.k0.lr.ph ], [ %21, %convolution.inner.loop_exit.k1 ]
  %convolution.inner.indvar.k016 = phi i64 [ 0, %convolution.inner.loop_body.k0.lr.ph ], [ %22, %convolution.inner.loop_exit.k1 ]
  %6 = add i64 %0, %convolution.inner.indvar.k016
  %7 = icmp ult i64 %6, 8
  br i1 %7, label %convolution.inner.loop_body.iz.lr.ph.us.preheader, label %convolution.inner.loop_exit.k1

convolution.inner.loop_body.iz.lr.ph.us.preheader: ; preds = %convolution.inner.loop_body.k1.lr.ph
  br label %convolution.inner.loop_body.iz.lr.ph.us

convolution.inner.loop_exit.iz.us:                ; preds = %convolution.inner.loop_header.iz.convolution.inner.loop_exit.iz_crit_edge.us-lcssa.us.us, %convolution.inner.loop_body.iz.lr.ph.us
  %8 = phi float [ %19, %convolution.inner.loop_header.iz.convolution.inner.loop_exit.iz_crit_edge.us-lcssa.us.us ], [ %11, %convolution.inner.loop_body.iz.lr.ph.us ]
  %9 = phi float [ %19, %convolution.inner.loop_header.iz.convolution.inner.loop_exit.iz_crit_edge.us-lcssa.us.us ], [ %12, %convolution.inner.loop_body.iz.lr.ph.us ]
  %10 = add nuw nsw i64 %convolution.inner.indvar.k14.us, 1
  %exitcond2 = icmp eq i64 %10, 3
  br i1 %exitcond2, label %convolution.inner.loop_exit.k1.loopexit, label %convolution.inner.loop_body.iz.lr.ph.us, !llvm.loop !1

convolution.inner.loop_body.iz.lr.ph.us:          ; preds = %convolution.inner.loop_exit.iz.us, %convolution.inner.loop_body.iz.lr.ph.us.preheader
  %11 = phi float [ %8, %convolution.inner.loop_exit.iz.us ], [ %4, %convolution.inner.loop_body.iz.lr.ph.us.preheader ]
  %12 = phi float [ %9, %convolution.inner.loop_exit.iz.us ], [ %5, %convolution.inner.loop_body.iz.lr.ph.us.preheader ]
  %convolution.inner.indvar.k14.us = phi i64 [ %10, %convolution.inner.loop_exit.iz.us ], [ 0, %convolution.inner.loop_body.iz.lr.ph.us.preheader ]
  %13 = add i64 %1, %convolution.inner.indvar.k14.us
  %scevgep3 = getelementptr [1 x [8 x [8 x [1 x float]]]]* @param0, i64 0, i64 0, i64 %6, i64 %13, i64 0
  %14 = add i64 %2, %convolution.inner.indvar.k14.us
  %scevgep = getelementptr [3 x [3 x [1 x [2 x float]]]]* @param1, i64 0, i64 %convolution.inner.indvar.k016, i64 %convolution.inner.indvar.k14.us, i64 0, i64 %3
  %15 = icmp ult i64 %14, 8
  br i1 %15, label %convolution.inner.loop_header.iz.convolution.inner.loop_exit.iz_crit_edge.us-lcssa.us.us, label %convolution.inner.loop_exit.iz.us

convolution.inner.loop_header.iz.convolution.inner.loop_exit.iz_crit_edge.us-lcssa.us.us: ; preds = %convolution.inner.loop_body.iz.lr.ph.us
  %16 = load volatile float* %scevgep, align 4
  %17 = load volatile float* %scevgep3, align 4
  %18 = fmul float %16, %17
  %19 = fadd float %11, %18
  br label %convolution.inner.loop_exit.iz.us

convolution.inner.loop_exit.k1.loopexit:          ; preds = %convolution.inner.loop_exit.iz.us
  %.lcssa1 = phi float [ %9, %convolution.inner.loop_exit.iz.us ]
  %.lcssa = phi float [ %8, %convolution.inner.loop_exit.iz.us ]
  br label %convolution.inner.loop_exit.k1

convolution.inner.loop_exit.k1:                   ; preds = %convolution.inner.loop_exit.k1.loopexit, %convolution.inner.loop_body.k1.lr.ph
  %20 = phi float [ %4, %convolution.inner.loop_body.k1.lr.ph ], [ %.lcssa, %convolution.inner.loop_exit.k1.loopexit ]
  %21 = phi float [ %5, %convolution.inner.loop_body.k1.lr.ph ], [ %.lcssa1, %convolution.inner.loop_exit.k1.loopexit ]
  %22 = add nuw nsw i64 %convolution.inner.indvar.k016, 1
  %exitcond = icmp eq i64 %22, 3
  br i1 %exitcond, label %convolution.inner.loop_exit.k0, label %convolution.inner.loop_body.k1.lr.ph, !llvm.loop !3

convolution.inner.loop_exit.k0:                   ; preds = %convolution.inner.loop_exit.k1
  %.lcssa4 = phi float [ %21, %convolution.inner.loop_exit.k1 ]
  store volatile float %.lcssa4, float* %scevgep8, align 4
  %invar.inc3 = add nuw nsw i64 %3, 1
  %exitcond6 = icmp ne i64 %invar.inc3, 2
  br i1 %exitcond6, label %convolution.inner.loop_body.k0.lr.ph, label %convolution.loop_exit.dim.3, !llvm.loop !4

convolution.loop_exit.dim.3:                      ; preds = %convolution.inner.loop_exit.k0
  %23 = add nuw nsw i64 %convolution.indvar.dim.223, 1
  %exitcond9 = icmp eq i64 %23, 8
  br i1 %exitcond9, label %convolution.loop_exit.dim.2, label %convolution.loop_body.dim.3.lr.ph, !llvm.loop !5

convolution.loop_exit.dim.2:                      ; preds = %convolution.loop_exit.dim.3
  %24 = add nuw nsw i64 %convolution.indvar.dim.126, 1
  %exitcond12 = icmp eq i64 %24, 8
  br i1 %exitcond12, label %convolution.loop_exit.dim.0, label %convolution.loop_body.dim.2.lr.ph, !llvm.loop !6

convolution.loop_exit.dim.0:                      ; preds = %convolution.loop_exit.dim.2
  %leflow_retval = load volatile float* getelementptr inbounds ([1 x [8 x [8 x [2 x float]]]]* @temp0, i64 0, i64 0, i64 0, i64 0, i64 0), align 8
  ret float %leflow_retval
}

attributes #0 = { nounwind "no-frame-pointer-elim"="false" }

!llvm.ident = !{!0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0}

!0 = metadata !{metadata !"clang version 3.5.0 (tags/RELEASE_350/final)"}
!1 = metadata !{metadata !1, metadata !2}
!2 = metadata !{metadata !"llvm.loop.vectorize.enable", i1 false}
!3 = metadata !{metadata !3, metadata !2}
!4 = metadata !{metadata !4, metadata !2}
!5 = metadata !{metadata !5, metadata !2}
!6 = metadata !{metadata !6, metadata !2}
