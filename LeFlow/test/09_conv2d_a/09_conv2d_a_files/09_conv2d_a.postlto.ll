; ModuleID = '09_conv2d_a.postlto.bc'
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
  %convolution.indvar.dim.126 = phi i64 [ 0, %convolution.loop_body.dim.1.lr.ph ], [ %invar.inc1, %convolution.loop_exit.dim.2 ]
  %0 = add i64 %convolution.indvar.dim.126, -1
  br label %convolution.loop_body.dim.3.lr.ph

convolution.loop_body.dim.3.lr.ph:                ; preds = %convolution.loop_exit.dim.3, %convolution.loop_body.dim.2.lr.ph
  %convolution.indvar.dim.223 = phi i64 [ 0, %convolution.loop_body.dim.2.lr.ph ], [ %invar.inc2, %convolution.loop_exit.dim.3 ]
  %1 = add i64 %convolution.indvar.dim.223, -1
  br label %convolution.inner.loop_body.k0.lr.ph

convolution.inner.loop_body.k0.lr.ph:             ; preds = %convolution.inner.loop_exit.k0, %convolution.loop_body.dim.3.lr.ph
  %convolution.indvar.dim.320 = phi i64 [ 0, %convolution.loop_body.dim.3.lr.ph ], [ %invar.inc3, %convolution.inner.loop_exit.k0 ]
  br label %convolution.inner.loop_body.k1.lr.ph

convolution.inner.loop_body.k1.lr.ph:             ; preds = %convolution.inner.loop_exit.k1, %convolution.inner.loop_body.k0.lr.ph
  %2 = phi float [ 0.000000e+00, %convolution.inner.loop_body.k0.lr.ph ], [ %18, %convolution.inner.loop_exit.k1 ]
  %3 = phi float [ 0.000000e+00, %convolution.inner.loop_body.k0.lr.ph ], [ %19, %convolution.inner.loop_exit.k1 ]
  %convolution.inner.indvar.k016 = phi i64 [ 0, %convolution.inner.loop_body.k0.lr.ph ], [ %invar.inc4, %convolution.inner.loop_exit.k1 ]
  %4 = add i64 %0, %convolution.inner.indvar.k016
  %5 = icmp ult i64 %4, 8
  br i1 %5, label %convolution.inner.loop_body.iz.lr.ph.us, label %convolution.inner.loop_exit.k1

convolution.inner.loop_exit.iz.us:                ; preds = %convolution.inner.loop_header.iz.convolution.inner.loop_exit.iz_crit_edge.us-lcssa.us.us, %convolution.inner.loop_body.iz.lr.ph.us
  %6 = phi float [ %17, %convolution.inner.loop_header.iz.convolution.inner.loop_exit.iz_crit_edge.us-lcssa.us.us ], [ %8, %convolution.inner.loop_body.iz.lr.ph.us ]
  %7 = phi float [ %17, %convolution.inner.loop_header.iz.convolution.inner.loop_exit.iz_crit_edge.us-lcssa.us.us ], [ %9, %convolution.inner.loop_body.iz.lr.ph.us ]
  %invar.inc5.us = add nuw nsw i64 %convolution.inner.indvar.k14.us, 1
  %exitcond = icmp eq i64 %invar.inc5.us, 3
  br i1 %exitcond, label %convolution.inner.loop_exit.k1, label %convolution.inner.loop_body.iz.lr.ph.us, !llvm.loop !1

convolution.inner.loop_body.iz.lr.ph.us:          ; preds = %convolution.inner.loop_exit.iz.us, %convolution.inner.loop_body.k1.lr.ph
  %8 = phi float [ %6, %convolution.inner.loop_exit.iz.us ], [ %2, %convolution.inner.loop_body.k1.lr.ph ]
  %9 = phi float [ %7, %convolution.inner.loop_exit.iz.us ], [ %3, %convolution.inner.loop_body.k1.lr.ph ]
  %convolution.inner.indvar.k14.us = phi i64 [ %invar.inc5.us, %convolution.inner.loop_exit.iz.us ], [ 0, %convolution.inner.loop_body.k1.lr.ph ]
  %10 = add i64 %1, %convolution.inner.indvar.k14.us
  %11 = icmp ult i64 %10, 8
  br i1 %11, label %convolution.inner.loop_header.iz.convolution.inner.loop_exit.iz_crit_edge.us-lcssa.us.us, label %convolution.inner.loop_exit.iz.us

convolution.inner.loop_header.iz.convolution.inner.loop_exit.iz_crit_edge.us-lcssa.us.us: ; preds = %convolution.inner.loop_body.iz.lr.ph.us
  %12 = getelementptr inbounds [3 x [3 x [1 x [2 x float]]]]* @param1, i64 0, i64 %convolution.inner.indvar.k016, i64 %convolution.inner.indvar.k14.us, i64 0, i64 %convolution.indvar.dim.320
  %13 = load volatile float* %12, align 4
  %14 = getelementptr inbounds [1 x [8 x [8 x [1 x float]]]]* @param0, i64 0, i64 0, i64 %4, i64 %10, i64 0
  %15 = load volatile float* %14, align 4
  %16 = fmul float %13, %15
  %17 = fadd float %8, %16
  br label %convolution.inner.loop_exit.iz.us

convolution.inner.loop_exit.k1:                   ; preds = %convolution.inner.loop_exit.iz.us, %convolution.inner.loop_body.k1.lr.ph
  %18 = phi float [ %2, %convolution.inner.loop_body.k1.lr.ph ], [ %6, %convolution.inner.loop_exit.iz.us ]
  %19 = phi float [ %3, %convolution.inner.loop_body.k1.lr.ph ], [ %7, %convolution.inner.loop_exit.iz.us ]
  %invar.inc4 = add nuw nsw i64 %convolution.inner.indvar.k016, 1
  %exitcond6 = icmp eq i64 %invar.inc4, 3
  br i1 %exitcond6, label %convolution.inner.loop_exit.k0, label %convolution.inner.loop_body.k1.lr.ph, !llvm.loop !3

convolution.inner.loop_exit.k0:                   ; preds = %convolution.inner.loop_exit.k1
  %.lcssa4 = phi float [ %19, %convolution.inner.loop_exit.k1 ]
  %20 = getelementptr inbounds [1 x [8 x [8 x [2 x float]]]]* @temp0, i64 0, i64 0, i64 %convolution.indvar.dim.126, i64 %convolution.indvar.dim.223, i64 %convolution.indvar.dim.320
  store volatile float %.lcssa4, float* %20, align 4
  %invar.inc3 = add nuw nsw i64 %convolution.indvar.dim.320, 1
  %21 = icmp eq i64 %convolution.indvar.dim.320, 0
  br i1 %21, label %convolution.inner.loop_body.k0.lr.ph, label %convolution.loop_exit.dim.3, !llvm.loop !4

convolution.loop_exit.dim.3:                      ; preds = %convolution.inner.loop_exit.k0
  %invar.inc2 = add nuw nsw i64 %convolution.indvar.dim.223, 1
  %exitcond7 = icmp eq i64 %invar.inc2, 8
  br i1 %exitcond7, label %convolution.loop_exit.dim.2, label %convolution.loop_body.dim.3.lr.ph, !llvm.loop !5

convolution.loop_exit.dim.2:                      ; preds = %convolution.loop_exit.dim.3
  %invar.inc1 = add nuw nsw i64 %convolution.indvar.dim.126, 1
  %exitcond8 = icmp eq i64 %invar.inc1, 8
  br i1 %exitcond8, label %convolution.loop_exit.dim.0, label %convolution.loop_body.dim.2.lr.ph, !llvm.loop !6

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
