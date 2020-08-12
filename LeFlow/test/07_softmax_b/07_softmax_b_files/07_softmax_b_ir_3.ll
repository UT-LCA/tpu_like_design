; ModuleID = '07_softmax_b_files/07_softmax_b_ir_3.bc'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux_gnu"

define void @cluster_0__XlaCompiledKernel_true__XlaNumConstantArgs_0__XlaNumResourceArgs_0_.v15(i8* nocapture align 8 dereferenceable(8) %retval, i8* noalias nocapture readnone %run_options, i8** noalias nocapture readonly %params, i8** noalias nocapture readonly %temps, i64* noalias nocapture readnone %prof_counters) #0 {
reduce.inner.loop_body.reduction_dim.1.lr.ph:
  %arg0.untyped = load i8** %params, align 8, !dereferenceable !0, !align !1
  %bitcast = bitcast i8* %arg0.untyped to [1 x [64 x float]]*
  %0 = load i8** %temps, align 8, !dereferenceable !0, !align !1
  br label %reduce.inner.loop_body.reduction_dim.1

reduce.inner.loop_body.reduction_dim.1:           ; preds = %reduce.inner.loop_body.reduction_dim.1, %reduce.inner.loop_body.reduction_dim.1.lr.ph
  %1 = phi float [ 0xFFF0000000000000, %reduce.inner.loop_body.reduction_dim.1.lr.ph ], [ %7, %reduce.inner.loop_body.reduction_dim.1 ]
  %reduce.inner.indvar.reduction_dim.112 = phi i64 [ 0, %reduce.inner.loop_body.reduction_dim.1.lr.ph ], [ %invar.inc1, %reduce.inner.loop_body.reduction_dim.1 ]
  %2 = getelementptr inbounds [1 x [64 x float]]* %bitcast, i64 0, i64 0, i64 %reduce.inner.indvar.reduction_dim.112
  %3 = load float* %2, align 4
  %4 = fcmp oge float %1, %3
  %5 = fcmp uno float %1, 0.000000e+00
  %6 = or i1 %4, %5
  %7 = select i1 %6, float %1, float %3
  %invar.inc1 = add nuw nsw i64 %reduce.inner.indvar.reduction_dim.112, 1
  %8 = icmp ugt i64 %invar.inc1, 63
  br i1 %8, label %fusion.1.loop_body.dim.1.lr.ph, label %reduce.inner.loop_body.reduction_dim.1, !llvm.loop !2

fusion.1.loop_body.dim.1.lr.ph:                   ; preds = %reduce.inner.loop_body.reduction_dim.1
  %9 = bitcast i8* %0 to float*
  store float %7, float* %9, align 4
  %10 = getelementptr inbounds i8** %temps, i64 9
  %11 = load i8** %10, align 8, !dereferenceable !4, !align !1
  %fusion.1 = bitcast i8* %11 to [1 x [64 x float]]*
  br label %fusion.1.loop_body.dim.1

fusion.1.loop_body.dim.1:                         ; preds = %fusion.1.loop_body.dim.1, %fusion.1.loop_body.dim.1.lr.ph
  %fusion.1.indvar.dim.18 = phi i64 [ 0, %fusion.1.loop_body.dim.1.lr.ph ], [ %invar.inc3, %fusion.1.loop_body.dim.1 ]
  %12 = getelementptr inbounds [1 x [64 x float]]* %bitcast, i64 0, i64 0, i64 %fusion.1.indvar.dim.18
  %13 = load float* %12, align 4
  %14 = bitcast i8* %0 to float*
  %15 = load float* %14, align 4
  %16 = fsub float %13, %15
  %17 = call float @llvm.exp.f32(float %16)
  %18 = getelementptr inbounds [1 x [64 x float]]* %fusion.1, i64 0, i64 0, i64 %fusion.1.indvar.dim.18
  store float %17, float* %18, align 4
  %invar.inc3 = add nuw nsw i64 %fusion.1.indvar.dim.18, 1
  %19 = icmp ugt i64 %invar.inc3, 63
  br i1 %19, label %reduce.1.inner.loop_body.reduction_dim.1.lr.ph, label %fusion.1.loop_body.dim.1, !llvm.loop !5

reduce.1.inner.loop_body.reduction_dim.1.lr.ph:   ; preds = %fusion.1.loop_body.dim.1
  %20 = getelementptr inbounds i8* %11, i64 256
  br label %reduce.1.inner.loop_body.reduction_dim.1

reduce.1.inner.loop_body.reduction_dim.1:         ; preds = %reduce.1.inner.loop_body.reduction_dim.1, %reduce.1.inner.loop_body.reduction_dim.1.lr.ph
  %21 = phi float [ 0.000000e+00, %reduce.1.inner.loop_body.reduction_dim.1.lr.ph ], [ %24, %reduce.1.inner.loop_body.reduction_dim.1 ]
  %reduce.1.inner.indvar.reduction_dim.14 = phi i64 [ 0, %reduce.1.inner.loop_body.reduction_dim.1.lr.ph ], [ %invar.inc6, %reduce.1.inner.loop_body.reduction_dim.1 ]
  %22 = getelementptr inbounds [1 x [64 x float]]* %fusion.1, i64 0, i64 0, i64 %reduce.1.inner.indvar.reduction_dim.14
  %23 = load float* %22, align 4
  %24 = fadd float %21, %23
  %invar.inc6 = add nuw nsw i64 %reduce.1.inner.indvar.reduction_dim.14, 1
  %25 = icmp ugt i64 %invar.inc6, 63
  br i1 %25, label %fusion.loop_body.dim.0.lr.ph, label %reduce.1.inner.loop_body.reduction_dim.1, !llvm.loop !6

fusion.loop_body.dim.0.lr.ph:                     ; preds = %reduce.1.inner.loop_body.reduction_dim.1
  %26 = bitcast i8* %20 to float*
  store float %24, float* %26, align 4
  %fusion = bitcast i8* %0 to [64 x float]*
  br label %fusion.loop_body.dim.0

fusion.loop_body.dim.0:                           ; preds = %fusion.loop_body.dim.0, %fusion.loop_body.dim.0.lr.ph
  %fusion.indvar.dim.02 = phi i64 [ 0, %fusion.loop_body.dim.0.lr.ph ], [ %invar.inc12, %fusion.loop_body.dim.0 ]
  %27 = getelementptr inbounds [1 x [64 x float]]* %fusion.1, i64 0, i64 0, i64 %fusion.indvar.dim.02
  %28 = load float* %27, align 4
  %29 = bitcast i8* %20 to float*
  %30 = load float* %29, align 4
  %31 = fdiv float %28, %30
  %32 = getelementptr inbounds [64 x float]* %fusion, i64 0, i64 %fusion.indvar.dim.02
  store float %31, float* %32, align 4
  %invar.inc12 = add nuw nsw i64 %fusion.indvar.dim.02, 1
  %33 = icmp ugt i64 %invar.inc12, 63
  br i1 %33, label %fusion.loop_exit.dim.0, label %fusion.loop_body.dim.0, !llvm.loop !7

fusion.loop_exit.dim.0:                           ; preds = %fusion.loop_body.dim.0
  %34 = bitcast i8* %retval to i8**
  store i8* %0, i8** %34, align 8
  ret void
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
