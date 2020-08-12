; ModuleID = 'classificationMNIST_files/classificationMNIST_ir_4.bc'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux_gnu"

@temp3 = global [10 x float] zeroinitializer, align 8
@temp2 = global float zeroinitializer, align 8
@temp1 = global [1 x [10 x float]] zeroinitializer, align 8
@temp0 = global [1 x [10 x float]] zeroinitializer, align 8
@param2 = global [1 x [784 x float]] zeroinitializer, align 8
@param1 = global [784 x [10 x float]] zeroinitializer, align 8
@param0 = global [10 x float] zeroinitializer, align 8

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
  %7 = icmp ugt i64 %invar.inc2, 783
  br i1 %7, label %dot.loop_exit.reduction, label %dot.loop_body.reduction, !llvm.loop !5

dot.loop_exit.reduction:                          ; preds = %dot.loop_body.reduction
  %8 = getelementptr inbounds [1 x [10 x float]]* @temp0, i64 0, i64 0, i64 %dot.indvar.rhs.122
  store float %6, float* %8, align 4
  %invar.inc1 = add nuw nsw i64 %dot.indvar.rhs.122, 1
  %9 = icmp ugt i64 %invar.inc1, 9
  br i1 %9, label %fusion.2.loop_body.dim.1.lr.ph, label %dot.loop_body.reduction.lr.ph, !llvm.loop !7

fusion.2.loop_body.dim.1.lr.ph:                   ; preds = %dot.loop_exit.reduction
  br label %fusion.2.loop_body.dim.1

fusion.2.loop_body.dim.1:                         ; preds = %fusion.2.loop_body.dim.1, %fusion.2.loop_body.dim.1.lr.ph
  %fusion.2.indvar.dim.116 = phi i64 [ 0, %fusion.2.loop_body.dim.1.lr.ph ], [ %invar.inc4, %fusion.2.loop_body.dim.1 ]
  %10 = getelementptr inbounds [1 x [10 x float]]* @temp0, i64 0, i64 0, i64 %fusion.2.indvar.dim.116
  %11 = load float* %10, align 4
  %12 = getelementptr inbounds [10 x float]* @param0, i64 0, i64 %fusion.2.indvar.dim.116
  %13 = load volatile float* %12, align 4
  %14 = fadd float %11, %13
  %15 = getelementptr inbounds [1 x [10 x float]]* @temp1, i64 0, i64 0, i64 %fusion.2.indvar.dim.116
  store float %14, float* %15, align 4
  %invar.inc4 = add nuw nsw i64 %fusion.2.indvar.dim.116, 1
  %16 = icmp ugt i64 %invar.inc4, 9
  br i1 %16, label %reduce.inner.loop_body.reduction_dim.1.lr.ph, label %fusion.2.loop_body.dim.1, !llvm.loop !9

reduce.inner.loop_body.reduction_dim.1.lr.ph:     ; preds = %fusion.2.loop_body.dim.1
  br label %reduce.inner.loop_body.reduction_dim.1

reduce.inner.loop_body.reduction_dim.1:           ; preds = %reduce.inner.loop_body.reduction_dim.1, %reduce.inner.loop_body.reduction_dim.1.lr.ph
  %17 = phi float [ 0xFFF0000000000000, %reduce.inner.loop_body.reduction_dim.1.lr.ph ], [ %23, %reduce.inner.loop_body.reduction_dim.1 ]
  %reduce.inner.indvar.reduction_dim.112 = phi i64 [ 0, %reduce.inner.loop_body.reduction_dim.1.lr.ph ], [ %invar.inc6, %reduce.inner.loop_body.reduction_dim.1 ]
  %18 = getelementptr inbounds [1 x [10 x float]]* @temp1, i64 0, i64 0, i64 %reduce.inner.indvar.reduction_dim.112
  %19 = load float* %18, align 4
  %20 = fcmp oge float %17, %19
  %21 = fcmp uno float %17, 0.000000e+00
  %22 = or i1 %20, %21
  %23 = select i1 %22, float %17, float %19
  %invar.inc6 = add nuw nsw i64 %reduce.inner.indvar.reduction_dim.112, 1
  %24 = icmp ugt i64 %invar.inc6, 9
  br i1 %24, label %fusion.1.loop_body.dim.1.lr.ph, label %reduce.inner.loop_body.reduction_dim.1, !llvm.loop !10

fusion.1.loop_body.dim.1.lr.ph:                   ; preds = %reduce.inner.loop_body.reduction_dim.1
  store float %23, float* @temp2, align 4
  br label %fusion.1.loop_body.dim.1

fusion.1.loop_body.dim.1:                         ; preds = %fusion.1.loop_body.dim.1, %fusion.1.loop_body.dim.1.lr.ph
  %fusion.1.indvar.dim.18 = phi i64 [ 0, %fusion.1.loop_body.dim.1.lr.ph ], [ %invar.inc8, %fusion.1.loop_body.dim.1 ]
  %25 = getelementptr inbounds [1 x [10 x float]]* @temp0, i64 0, i64 0, i64 %fusion.1.indvar.dim.18
  %26 = load float* %25, align 4
  %27 = getelementptr inbounds [10 x float]* @param0, i64 0, i64 %fusion.1.indvar.dim.18
  %28 = load volatile float* %27, align 4
  %29 = fadd float %26, %28
  %30 = load float* @temp2, align 4
  %31 = fsub float %29, %30
  %32 = call float @llvm.exp.f32(float %31)
  %33 = getelementptr inbounds [1 x [10 x float]]* @temp1, i64 0, i64 0, i64 %fusion.1.indvar.dim.18
  store float %32, float* %33, align 4
  %invar.inc8 = add nuw nsw i64 %fusion.1.indvar.dim.18, 1
  %34 = icmp ugt i64 %invar.inc8, 9
  br i1 %34, label %reduce.1.inner.loop_body.reduction_dim.1, label %fusion.1.loop_body.dim.1, !llvm.loop !11

reduce.1.inner.loop_body.reduction_dim.1:         ; preds = %reduce.1.inner.loop_body.reduction_dim.1, %fusion.1.loop_body.dim.1
  %35 = phi float [ %38, %reduce.1.inner.loop_body.reduction_dim.1 ], [ 0.000000e+00, %fusion.1.loop_body.dim.1 ]
  %reduce.1.inner.indvar.reduction_dim.14 = phi i64 [ %invar.inc11, %reduce.1.inner.loop_body.reduction_dim.1 ], [ 0, %fusion.1.loop_body.dim.1 ]
  %36 = getelementptr inbounds [1 x [10 x float]]* @temp1, i64 0, i64 0, i64 %reduce.1.inner.indvar.reduction_dim.14
  %37 = load float* %36, align 4
  %38 = fadd float %35, %37
  %invar.inc11 = add nuw nsw i64 %reduce.1.inner.indvar.reduction_dim.14, 1
  %39 = icmp ugt i64 %invar.inc11, 9
  br i1 %39, label %fusion.loop_body.dim.0.lr.ph, label %reduce.1.inner.loop_body.reduction_dim.1, !llvm.loop !12

fusion.loop_body.dim.0.lr.ph:                     ; preds = %reduce.1.inner.loop_body.reduction_dim.1
  store float %38, float* @temp2, align 4
  br label %fusion.loop_body.dim.0

fusion.loop_body.dim.0:                           ; preds = %fusion.loop_body.dim.0, %fusion.loop_body.dim.0.lr.ph
  %fusion.indvar.dim.02 = phi i64 [ 0, %fusion.loop_body.dim.0.lr.ph ], [ %invar.inc17, %fusion.loop_body.dim.0 ]
  %40 = getelementptr inbounds [1 x [10 x float]]* @temp1, i64 0, i64 0, i64 %fusion.indvar.dim.02
  %41 = load float* %40, align 4
  %42 = load float* @temp2, align 4
  %43 = fdiv float %41, %42
  %44 = getelementptr inbounds [10 x float]* @temp3, i64 0, i64 %fusion.indvar.dim.02
  store volatile float %43, float* %44, align 4
  %invar.inc17 = add nuw nsw i64 %fusion.indvar.dim.02, 1
  %45 = icmp ugt i64 %invar.inc17, 9
  br i1 %45, label %fusion.loop_exit.dim.0, label %fusion.loop_body.dim.0, !llvm.loop !13

fusion.loop_exit.dim.0:                           ; preds = %fusion.loop_body.dim.0
  %leflow_gep = getelementptr inbounds [10 x float]* @temp3, i64 0, i64 0
  %leflow_retval = load volatile float* %leflow_gep, align 4
  ret float %leflow_retval
}

; Function Attrs: nounwind readnone
declare float @llvm.exp.f32(float) #1

attributes #0 = { "no-frame-pointer-elim"="false" }
attributes #1 = { nounwind readnone }

!0 = metadata !{i64 40}
!1 = metadata !{i64 8}
!2 = metadata !{i64 31360}
!3 = metadata !{i64 16}
!4 = metadata !{i64 3136}
!5 = metadata !{metadata !5, metadata !6}
!6 = metadata !{metadata !"llvm.loop.vectorize.enable", i1 false}
!7 = metadata !{metadata !7, metadata !6}
!8 = metadata !{i64 52}
!9 = metadata !{metadata !9, metadata !6}
!10 = metadata !{metadata !10, metadata !6}
!11 = metadata !{metadata !11, metadata !6}
!12 = metadata !{metadata !12, metadata !6}
!13 = metadata !{metadata !13, metadata !6}
