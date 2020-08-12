; ModuleID = '07_softmax_b_files/07_softmax_b_ir_4.bc'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux_gnu"

@temp3 = global [64 x float] zeroinitializer, align 8
@temp2 = global float zeroinitializer, align 8
@temp1 = global [1 x [64 x float]] zeroinitializer, align 8
@temp0 = global float zeroinitializer, align 8
@param0 = global [1 x [64 x float]] zeroinitializer, align 8

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
  %7 = icmp ugt i64 %invar.inc1, 63
  br i1 %7, label %fusion.1.loop_body.dim.1.lr.ph, label %reduce.inner.loop_body.reduction_dim.1, !llvm.loop !2

fusion.1.loop_body.dim.1.lr.ph:                   ; preds = %reduce.inner.loop_body.reduction_dim.1
  store float %6, float* @temp0, align 4
  br label %fusion.1.loop_body.dim.1

fusion.1.loop_body.dim.1:                         ; preds = %fusion.1.loop_body.dim.1, %fusion.1.loop_body.dim.1.lr.ph
  %fusion.1.indvar.dim.18 = phi i64 [ 0, %fusion.1.loop_body.dim.1.lr.ph ], [ %invar.inc3, %fusion.1.loop_body.dim.1 ]
  %8 = getelementptr inbounds [1 x [64 x float]]* @param0, i64 0, i64 0, i64 %fusion.1.indvar.dim.18
  %9 = load volatile float* %8, align 4
  %10 = load float* @temp0, align 4
  %11 = fsub float %9, %10
  %12 = call float @llvm.exp.f32(float %11)
  %13 = getelementptr inbounds [1 x [64 x float]]* @temp1, i64 0, i64 0, i64 %fusion.1.indvar.dim.18
  store float %12, float* %13, align 4
  %invar.inc3 = add nuw nsw i64 %fusion.1.indvar.dim.18, 1
  %14 = icmp ugt i64 %invar.inc3, 63
  br i1 %14, label %reduce.1.inner.loop_body.reduction_dim.1.lr.ph, label %fusion.1.loop_body.dim.1, !llvm.loop !5

reduce.1.inner.loop_body.reduction_dim.1.lr.ph:   ; preds = %fusion.1.loop_body.dim.1
  br label %reduce.1.inner.loop_body.reduction_dim.1

reduce.1.inner.loop_body.reduction_dim.1:         ; preds = %reduce.1.inner.loop_body.reduction_dim.1, %reduce.1.inner.loop_body.reduction_dim.1.lr.ph
  %15 = phi float [ 0.000000e+00, %reduce.1.inner.loop_body.reduction_dim.1.lr.ph ], [ %18, %reduce.1.inner.loop_body.reduction_dim.1 ]
  %reduce.1.inner.indvar.reduction_dim.14 = phi i64 [ 0, %reduce.1.inner.loop_body.reduction_dim.1.lr.ph ], [ %invar.inc6, %reduce.1.inner.loop_body.reduction_dim.1 ]
  %16 = getelementptr inbounds [1 x [64 x float]]* @temp1, i64 0, i64 0, i64 %reduce.1.inner.indvar.reduction_dim.14
  %17 = load float* %16, align 4
  %18 = fadd float %15, %17
  %invar.inc6 = add nuw nsw i64 %reduce.1.inner.indvar.reduction_dim.14, 1
  %19 = icmp ugt i64 %invar.inc6, 63
  br i1 %19, label %fusion.loop_body.dim.0.lr.ph, label %reduce.1.inner.loop_body.reduction_dim.1, !llvm.loop !6

fusion.loop_body.dim.0.lr.ph:                     ; preds = %reduce.1.inner.loop_body.reduction_dim.1
  store float %18, float* @temp2, align 4
  br label %fusion.loop_body.dim.0

fusion.loop_body.dim.0:                           ; preds = %fusion.loop_body.dim.0, %fusion.loop_body.dim.0.lr.ph
  %fusion.indvar.dim.02 = phi i64 [ 0, %fusion.loop_body.dim.0.lr.ph ], [ %invar.inc12, %fusion.loop_body.dim.0 ]
  %20 = getelementptr inbounds [1 x [64 x float]]* @temp1, i64 0, i64 0, i64 %fusion.indvar.dim.02
  %21 = load float* %20, align 4
  %22 = load float* @temp2, align 4
  %23 = fdiv float %21, %22
  %24 = getelementptr inbounds [64 x float]* @temp3, i64 0, i64 %fusion.indvar.dim.02
  store volatile float %23, float* %24, align 4
  %invar.inc12 = add nuw nsw i64 %fusion.indvar.dim.02, 1
  %25 = icmp ugt i64 %invar.inc12, 63
  br i1 %25, label %fusion.loop_exit.dim.0, label %fusion.loop_body.dim.0, !llvm.loop !7

fusion.loop_exit.dim.0:                           ; preds = %fusion.loop_body.dim.0
  %leflow_gep = getelementptr inbounds [64 x float]* @temp3, i64 0, i64 0
  %leflow_retval = load volatile float* %leflow_gep, align 4
  ret float %leflow_retval
}

; Function Attrs: nounwind readnone
declare float @llvm.exp.f32(float) #1

attributes #0 = { "no-frame-pointer-elim"="false" }
attributes #1 = { nounwind readnone }

!0 = metadata !{i64 256}
!1 = metadata !{i64 8}
!2 = metadata !{metadata !2, metadata !3}
!3 = metadata !{metadata !"llvm.loop.vectorize.enable", i1 false}
!4 = metadata !{i64 260}
!5 = metadata !{metadata !5, metadata !3}
!6 = metadata !{metadata !6, metadata !3}
!7 = metadata !{metadata !7, metadata !3}
