; ModuleID = 'classificationMNIST.prelto.6.bc'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux_gnu"

@temp3 = internal global [10 x float] zeroinitializer, align 8
@temp1 = internal unnamed_addr global [1 x [10 x float]] zeroinitializer, align 8
@temp0 = internal unnamed_addr global [1 x [10 x float]] zeroinitializer, align 8
@param2 = internal global [1 x [784 x float]] zeroinitializer, align 8
@param1 = internal global [784 x [10 x float]] zeroinitializer, align 8
@param0 = internal global [10 x float] zeroinitializer, align 8

; Function Attrs: nounwind
define float @main() #0 {
dot.loop_body.rhs.1.lr.ph:
  br label %dot.loop_body.reduction.lr.ph

dot.loop_body.reduction.lr.ph:                    ; preds = %dot.loop_exit.reduction, %dot.loop_body.rhs.1.lr.ph
  %dot.indvar.rhs.122 = phi i64 [ 0, %dot.loop_body.rhs.1.lr.ph ], [ %invar.inc1, %dot.loop_exit.reduction ]
  br label %dot.loop_body.reduction

dot.loop_body.reduction:                          ; preds = %dot.loop_body.reduction, %dot.loop_body.reduction.lr.ph
  %0 = phi float [ 0.000000e+00, %dot.loop_body.reduction.lr.ph ], [ %6, %dot.loop_body.reduction ]
  %dot.indvar.reduction20 = phi i64 [ 0, %dot.loop_body.reduction.lr.ph ], [ %invar.inc2, %dot.loop_body.reduction ]
  %1 = getelementptr inbounds [1 x [784 x float]]* @param2, i64 0, i64 0, i64 %dot.indvar.reduction20
  %2 = load volatile float* %1, align 4
  %3 = getelementptr inbounds [784 x [10 x float]]* @param1, i64 0, i64 %dot.indvar.reduction20, i64 %dot.indvar.rhs.122
  %4 = load volatile float* %3, align 4
  %5 = fmul float %2, %4
  %6 = fadd float %0, %5
  %invar.inc2 = add nuw nsw i64 %dot.indvar.reduction20, 1
  %exitcond10 = icmp eq i64 %invar.inc2, 784
  br i1 %exitcond10, label %dot.loop_exit.reduction, label %dot.loop_body.reduction, !llvm.loop !0

dot.loop_exit.reduction:                          ; preds = %dot.loop_body.reduction
  %.lcssa5 = phi float [ %6, %dot.loop_body.reduction ]
  %7 = getelementptr inbounds [1 x [10 x float]]* @temp0, i64 0, i64 0, i64 %dot.indvar.rhs.122
  store float %.lcssa5, float* %7, align 4
  %invar.inc1 = add nuw nsw i64 %dot.indvar.rhs.122, 1
  %exitcond11 = icmp eq i64 %invar.inc1, 10
  br i1 %exitcond11, label %fusion.2.loop_body.dim.1, label %dot.loop_body.reduction.lr.ph, !llvm.loop !2

fusion.2.loop_body.dim.1:                         ; preds = %fusion.2.loop_body.dim.1, %dot.loop_exit.reduction
  %fusion.2.indvar.dim.116 = phi i64 [ %invar.inc4, %fusion.2.loop_body.dim.1 ], [ 0, %dot.loop_exit.reduction ]
  %8 = getelementptr inbounds [1 x [10 x float]]* @temp0, i64 0, i64 0, i64 %fusion.2.indvar.dim.116
  %9 = load float* %8, align 4
  %10 = getelementptr inbounds [10 x float]* @param0, i64 0, i64 %fusion.2.indvar.dim.116
  %11 = load volatile float* %10, align 4
  %12 = fadd float %9, %11
  %13 = getelementptr inbounds [1 x [10 x float]]* @temp1, i64 0, i64 0, i64 %fusion.2.indvar.dim.116
  store float %12, float* %13, align 4
  %invar.inc4 = add nuw nsw i64 %fusion.2.indvar.dim.116, 1
  %exitcond9 = icmp eq i64 %invar.inc4, 10
  br i1 %exitcond9, label %reduce.inner.loop_body.reduction_dim.1, label %fusion.2.loop_body.dim.1, !llvm.loop !3

reduce.inner.loop_body.reduction_dim.1:           ; preds = %reduce.inner.loop_body.reduction_dim.1, %fusion.2.loop_body.dim.1
  %14 = phi float [ %20, %reduce.inner.loop_body.reduction_dim.1 ], [ 0xFFF0000000000000, %fusion.2.loop_body.dim.1 ]
  %reduce.inner.indvar.reduction_dim.112 = phi i64 [ %invar.inc6, %reduce.inner.loop_body.reduction_dim.1 ], [ 0, %fusion.2.loop_body.dim.1 ]
  %15 = getelementptr inbounds [1 x [10 x float]]* @temp1, i64 0, i64 0, i64 %reduce.inner.indvar.reduction_dim.112
  %16 = load float* %15, align 4
  %17 = fcmp oge float %14, %16
  %18 = fcmp ueq float %14, 0.000000e+00
  %19 = or i1 %17, %18
  %20 = select i1 %19, float %14, float %16
  %invar.inc6 = add nuw nsw i64 %reduce.inner.indvar.reduction_dim.112, 1
  %exitcond8 = icmp eq i64 %invar.inc6, 10
  br i1 %exitcond8, label %fusion.1.loop_body.dim.1.lr.ph, label %reduce.inner.loop_body.reduction_dim.1, !llvm.loop !4

fusion.1.loop_body.dim.1.lr.ph:                   ; preds = %reduce.inner.loop_body.reduction_dim.1
  %.lcssa4 = phi float [ %20, %reduce.inner.loop_body.reduction_dim.1 ]
  br label %fusion.1.loop_body.dim.1

fusion.1.loop_body.dim.1:                         ; preds = %fusion.1.loop_body.dim.1, %fusion.1.loop_body.dim.1.lr.ph
  %fusion.1.indvar.dim.18 = phi i64 [ 0, %fusion.1.loop_body.dim.1.lr.ph ], [ %invar.inc8, %fusion.1.loop_body.dim.1 ]
  %21 = getelementptr inbounds [1 x [10 x float]]* @temp0, i64 0, i64 0, i64 %fusion.1.indvar.dim.18
  %22 = load float* %21, align 4
  %23 = getelementptr inbounds [10 x float]* @param0, i64 0, i64 %fusion.1.indvar.dim.18
  %24 = load volatile float* %23, align 4
  %25 = fadd float %22, %24
  %26 = fsub float %25, %.lcssa4
  %27 = call float @expf(float %26)
  %28 = getelementptr inbounds [1 x [10 x float]]* @temp1, i64 0, i64 0, i64 %fusion.1.indvar.dim.18
  store float %27, float* %28, align 4
  %invar.inc8 = add nuw nsw i64 %fusion.1.indvar.dim.18, 1
  %exitcond7 = icmp eq i64 %invar.inc8, 10
  br i1 %exitcond7, label %reduce.1.inner.loop_body.reduction_dim.1, label %fusion.1.loop_body.dim.1, !llvm.loop !5

reduce.1.inner.loop_body.reduction_dim.1:         ; preds = %reduce.1.inner.loop_body.reduction_dim.1, %fusion.1.loop_body.dim.1
  %29 = phi float [ %32, %reduce.1.inner.loop_body.reduction_dim.1 ], [ 0.000000e+00, %fusion.1.loop_body.dim.1 ]
  %reduce.1.inner.indvar.reduction_dim.14 = phi i64 [ %invar.inc11, %reduce.1.inner.loop_body.reduction_dim.1 ], [ 0, %fusion.1.loop_body.dim.1 ]
  %30 = getelementptr inbounds [1 x [10 x float]]* @temp1, i64 0, i64 0, i64 %reduce.1.inner.indvar.reduction_dim.14
  %31 = load float* %30, align 4
  %32 = fadd float %29, %31
  %invar.inc11 = add nuw nsw i64 %reduce.1.inner.indvar.reduction_dim.14, 1
  %exitcond6 = icmp eq i64 %invar.inc11, 10
  br i1 %exitcond6, label %fusion.loop_body.dim.0.lr.ph, label %reduce.1.inner.loop_body.reduction_dim.1, !llvm.loop !6

fusion.loop_body.dim.0.lr.ph:                     ; preds = %reduce.1.inner.loop_body.reduction_dim.1
  %.lcssa = phi float [ %32, %reduce.1.inner.loop_body.reduction_dim.1 ]
  br label %fusion.loop_body.dim.0

fusion.loop_body.dim.0:                           ; preds = %fusion.loop_body.dim.0, %fusion.loop_body.dim.0.lr.ph
  %fusion.indvar.dim.02 = phi i64 [ 0, %fusion.loop_body.dim.0.lr.ph ], [ %invar.inc17, %fusion.loop_body.dim.0 ]
  %33 = getelementptr inbounds [1 x [10 x float]]* @temp1, i64 0, i64 0, i64 %fusion.indvar.dim.02
  %34 = load float* %33, align 4
  %35 = fdiv float %34, %.lcssa
  %36 = getelementptr inbounds [10 x float]* @temp3, i64 0, i64 %fusion.indvar.dim.02
  store volatile float %35, float* %36, align 4
  %invar.inc17 = add nuw nsw i64 %fusion.indvar.dim.02, 1
  %exitcond = icmp eq i64 %invar.inc17, 10
  br i1 %exitcond, label %fusion.loop_exit.dim.0, label %fusion.loop_body.dim.0, !llvm.loop !7

fusion.loop_exit.dim.0:                           ; preds = %fusion.loop_body.dim.0
  %leflow_retval = load volatile float* getelementptr inbounds ([10 x float]* @temp3, i64 0, i64 0), align 4
  ret float %leflow_retval
}

; Function Attrs: nounwind readnone
declare float @llvm.exp.f32(float) #1

declare float @expf(float)

attributes #0 = { nounwind "no-frame-pointer-elim"="false" }
attributes #1 = { nounwind readnone }

!0 = metadata !{metadata !0, metadata !1}
!1 = metadata !{metadata !"llvm.loop.vectorize.enable", i1 false}
!2 = metadata !{metadata !2, metadata !1}
!3 = metadata !{metadata !3, metadata !1}
!4 = metadata !{metadata !4, metadata !1}
!5 = metadata !{metadata !5, metadata !1}
!6 = metadata !{metadata !6, metadata !1}
!7 = metadata !{metadata !7, metadata !1}
