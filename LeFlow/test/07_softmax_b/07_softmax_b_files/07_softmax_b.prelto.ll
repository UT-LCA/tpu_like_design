; ModuleID = '07_softmax_b.prelto.bc'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux_gnu"

@temp3 = internal global [64 x float] zeroinitializer, align 8
@temp1 = internal unnamed_addr global [1 x [64 x float]] zeroinitializer, align 8
@param0 = internal global [1 x [64 x float]] zeroinitializer, align 8

; Function Attrs: nounwind
define float @main() #0 {
reduce.inner.loop_body.reduction_dim.1.lr.ph:
  br label %reduce.inner.loop_body.reduction_dim.1

reduce.inner.loop_body.reduction_dim.1:           ; preds = %reduce.inner.loop_body.reduction_dim.1, %reduce.inner.loop_body.reduction_dim.1.lr.ph
  %0 = phi float [ 0xFFF0000000000000, %reduce.inner.loop_body.reduction_dim.1.lr.ph ], [ %6, %reduce.inner.loop_body.reduction_dim.1 ]
  %reduce.inner.indvar.reduction_dim.112 = phi i64 [ 0, %reduce.inner.loop_body.reduction_dim.1.lr.ph ], [ %invar.inc1, %reduce.inner.loop_body.reduction_dim.1 ]
  %1 = getelementptr inbounds [1 x [64 x float]]* @param0, i64 0, i64 0, i64 %reduce.inner.indvar.reduction_dim.112
  %2 = load volatile float* %1, align 4
  %3 = fcmp oge float %0, %2
  %4 = fcmp ueq float %0, 0.000000e+00
  %5 = or i1 %3, %4
  %6 = select i1 %5, float %0, float %2
  %invar.inc1 = add nuw nsw i64 %reduce.inner.indvar.reduction_dim.112, 1
  %exitcond5 = icmp eq i64 %invar.inc1, 64
  br i1 %exitcond5, label %fusion.1.loop_body.dim.1.lr.ph, label %reduce.inner.loop_body.reduction_dim.1, !llvm.loop !0

fusion.1.loop_body.dim.1.lr.ph:                   ; preds = %reduce.inner.loop_body.reduction_dim.1
  %.lcssa1 = phi float [ %6, %reduce.inner.loop_body.reduction_dim.1 ]
  br label %fusion.1.loop_body.dim.1

fusion.1.loop_body.dim.1:                         ; preds = %fusion.1.loop_body.dim.1, %fusion.1.loop_body.dim.1.lr.ph
  %fusion.1.indvar.dim.18 = phi i64 [ 0, %fusion.1.loop_body.dim.1.lr.ph ], [ %invar.inc3, %fusion.1.loop_body.dim.1 ]
  %7 = getelementptr inbounds [1 x [64 x float]]* @param0, i64 0, i64 0, i64 %fusion.1.indvar.dim.18
  %8 = load volatile float* %7, align 4
  %9 = fsub float %8, %.lcssa1
  %10 = call float @expf(float %9)
  %11 = getelementptr inbounds [1 x [64 x float]]* @temp1, i64 0, i64 0, i64 %fusion.1.indvar.dim.18
  store float %10, float* %11, align 4
  %invar.inc3 = add nuw nsw i64 %fusion.1.indvar.dim.18, 1
  %exitcond4 = icmp eq i64 %invar.inc3, 64
  br i1 %exitcond4, label %reduce.1.inner.loop_body.reduction_dim.1, label %fusion.1.loop_body.dim.1, !llvm.loop !2

reduce.1.inner.loop_body.reduction_dim.1:         ; preds = %reduce.1.inner.loop_body.reduction_dim.1, %fusion.1.loop_body.dim.1
  %12 = phi float [ %15, %reduce.1.inner.loop_body.reduction_dim.1 ], [ 0.000000e+00, %fusion.1.loop_body.dim.1 ]
  %reduce.1.inner.indvar.reduction_dim.14 = phi i64 [ %invar.inc6, %reduce.1.inner.loop_body.reduction_dim.1 ], [ 0, %fusion.1.loop_body.dim.1 ]
  %13 = getelementptr inbounds [1 x [64 x float]]* @temp1, i64 0, i64 0, i64 %reduce.1.inner.indvar.reduction_dim.14
  %14 = load float* %13, align 4
  %15 = fadd float %12, %14
  %invar.inc6 = add nuw nsw i64 %reduce.1.inner.indvar.reduction_dim.14, 1
  %exitcond3 = icmp eq i64 %invar.inc6, 64
  br i1 %exitcond3, label %fusion.loop_body.dim.0.lr.ph, label %reduce.1.inner.loop_body.reduction_dim.1, !llvm.loop !3

fusion.loop_body.dim.0.lr.ph:                     ; preds = %reduce.1.inner.loop_body.reduction_dim.1
  %.lcssa = phi float [ %15, %reduce.1.inner.loop_body.reduction_dim.1 ]
  br label %fusion.loop_body.dim.0

fusion.loop_body.dim.0:                           ; preds = %fusion.loop_body.dim.0, %fusion.loop_body.dim.0.lr.ph
  %fusion.indvar.dim.02 = phi i64 [ 0, %fusion.loop_body.dim.0.lr.ph ], [ %invar.inc12, %fusion.loop_body.dim.0 ]
  %16 = getelementptr inbounds [1 x [64 x float]]* @temp1, i64 0, i64 0, i64 %fusion.indvar.dim.02
  %17 = load float* %16, align 4
  %18 = fdiv float %17, %.lcssa
  %19 = getelementptr inbounds [64 x float]* @temp3, i64 0, i64 %fusion.indvar.dim.02
  store volatile float %18, float* %19, align 4
  %invar.inc12 = add nuw nsw i64 %fusion.indvar.dim.02, 1
  %exitcond = icmp eq i64 %invar.inc12, 64
  br i1 %exitcond, label %fusion.loop_exit.dim.0, label %fusion.loop_body.dim.0, !llvm.loop !4

fusion.loop_exit.dim.0:                           ; preds = %fusion.loop_body.dim.0
  %leflow_retval = load volatile float* getelementptr inbounds ([64 x float]* @temp3, i64 0, i64 0), align 4
  ret float %leflow_retval
}

declare float @expf(float)

attributes #0 = { nounwind "no-frame-pointer-elim"="false" }

!0 = metadata !{metadata !0, metadata !1}
!1 = metadata !{metadata !"llvm.loop.vectorize.enable", i1 false}
!2 = metadata !{metadata !2, metadata !1}
!3 = metadata !{metadata !3, metadata !1}
!4 = metadata !{metadata !4, metadata !1}
