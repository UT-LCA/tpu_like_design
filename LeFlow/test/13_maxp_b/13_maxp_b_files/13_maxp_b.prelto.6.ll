; ModuleID = '13_maxp_b.prelto.6.bc'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux_gnu"

@temp0 = internal global [1 x [10 x [10 x [1 x float]]]] zeroinitializer, align 8
@param0 = internal global [1 x [32 x [32 x [1 x float]]]] zeroinitializer, align 8

; Function Attrs: nounwind
define float @main() #0 {
reduce-window.loop_body.dim.1.lr.ph:
  br label %reduce-window.loop_body.dim.2.lr.ph

reduce-window.loop_body.dim.2.lr.ph:              ; preds = %reduce-window.loop_exit.dim.2, %reduce-window.loop_body.dim.1.lr.ph
  %reduce-window.indvar.dim.130 = phi i64 [ 0, %reduce-window.loop_body.dim.1.lr.ph ], [ %invar.inc1, %reduce-window.loop_exit.dim.2 ]
  %0 = mul nsw i64 %reduce-window.indvar.dim.130, 3
  br label %reduce-window.inner.loop_body.window.1.lr.ph

reduce-window.inner.loop_body.window.1.lr.ph:     ; preds = %reduce-window.loop_exit.dim.3, %reduce-window.loop_body.dim.2.lr.ph
  %reduce-window.indvar.dim.227 = phi i64 [ 0, %reduce-window.loop_body.dim.2.lr.ph ], [ %invar.inc2, %reduce-window.loop_exit.dim.3 ]
  %1 = mul nsw i64 %reduce-window.indvar.dim.227, 3
  br label %reduce-window.inner.loop_body.window.3.lr.ph.us.preheader

reduce-window.inner.loop_body.window.3.lr.ph.us.preheader: ; preds = %reduce-window.inner.loop_exit.window.2, %reduce-window.inner.loop_body.window.1.lr.ph
  %2 = phi float [ 0xFFF0000000000000, %reduce-window.inner.loop_body.window.1.lr.ph ], [ %.lcssa4, %reduce-window.inner.loop_exit.window.2 ]
  %reduce-window.inner.indvar.window.119 = phi i64 [ 0, %reduce-window.inner.loop_body.window.1.lr.ph ], [ %invar.inc5, %reduce-window.inner.loop_exit.window.2 ]
  %3 = add nsw i64 %reduce-window.inner.indvar.window.119, %0
  br label %reduce-window.inner.loop_exit.window.3.us

reduce-window.inner.loop_exit.window.3.us:        ; preds = %reduce-window.inner.loop_exit.window.3.us, %reduce-window.inner.loop_body.window.3.lr.ph.us.preheader
  %4 = phi float [ %11, %reduce-window.inner.loop_exit.window.3.us ], [ %2, %reduce-window.inner.loop_body.window.3.lr.ph.us.preheader ]
  %reduce-window.inner.indvar.window.24.us = phi i64 [ %invar.inc6.us, %reduce-window.inner.loop_exit.window.3.us ], [ 0, %reduce-window.inner.loop_body.window.3.lr.ph.us.preheader ]
  %5 = add nsw i64 %reduce-window.inner.indvar.window.24.us, %1
  %6 = getelementptr inbounds [1 x [32 x [32 x [1 x float]]]]* @param0, i64 0, i64 0, i64 %3, i64 %5, i64 0
  %7 = load volatile float* %6, align 4
  %8 = fcmp oge float %4, %7
  %9 = fcmp ueq float %4, 0.000000e+00
  %10 = or i1 %8, %9
  %11 = select i1 %10, float %4, float %7
  %invar.inc6.us = add nuw nsw i64 %reduce-window.inner.indvar.window.24.us, 1
  %exitcond = icmp eq i64 %invar.inc6.us, 3
  br i1 %exitcond, label %reduce-window.inner.loop_exit.window.2, label %reduce-window.inner.loop_exit.window.3.us, !llvm.loop !0

reduce-window.inner.loop_exit.window.2:           ; preds = %reduce-window.inner.loop_exit.window.3.us
  %.lcssa4 = phi float [ %11, %reduce-window.inner.loop_exit.window.3.us ]
  %invar.inc5 = add nuw nsw i64 %reduce-window.inner.indvar.window.119, 1
  %exitcond6 = icmp eq i64 %invar.inc5, 3
  br i1 %exitcond6, label %reduce-window.loop_exit.dim.3, label %reduce-window.inner.loop_body.window.3.lr.ph.us.preheader, !llvm.loop !2

reduce-window.loop_exit.dim.3:                    ; preds = %reduce-window.inner.loop_exit.window.2
  %.lcssa5 = phi float [ %.lcssa4, %reduce-window.inner.loop_exit.window.2 ]
  %12 = getelementptr inbounds [1 x [10 x [10 x [1 x float]]]]* @temp0, i64 0, i64 0, i64 %reduce-window.indvar.dim.130, i64 %reduce-window.indvar.dim.227, i64 0
  store volatile float %.lcssa5, float* %12, align 4
  %invar.inc2 = add nuw nsw i64 %reduce-window.indvar.dim.227, 1
  %exitcond7 = icmp eq i64 %invar.inc2, 10
  br i1 %exitcond7, label %reduce-window.loop_exit.dim.2, label %reduce-window.inner.loop_body.window.1.lr.ph, !llvm.loop !3

reduce-window.loop_exit.dim.2:                    ; preds = %reduce-window.loop_exit.dim.3
  %invar.inc1 = add nuw nsw i64 %reduce-window.indvar.dim.130, 1
  %exitcond8 = icmp eq i64 %invar.inc1, 10
  br i1 %exitcond8, label %reduce-window.loop_exit.dim.0, label %reduce-window.loop_body.dim.2.lr.ph, !llvm.loop !4

reduce-window.loop_exit.dim.0:                    ; preds = %reduce-window.loop_exit.dim.2
  %leflow_retval = load volatile float* getelementptr inbounds ([1 x [10 x [10 x [1 x float]]]]* @temp0, i64 0, i64 0, i64 0, i64 0, i64 0), align 4
  ret float %leflow_retval
}

attributes #0 = { nounwind "no-frame-pointer-elim"="false" }

!0 = metadata !{metadata !0, metadata !1}
!1 = metadata !{metadata !"llvm.loop.vectorize.enable", i1 false}
!2 = metadata !{metadata !2, metadata !1}
!3 = metadata !{metadata !3, metadata !1}
!4 = metadata !{metadata !4, metadata !1}
