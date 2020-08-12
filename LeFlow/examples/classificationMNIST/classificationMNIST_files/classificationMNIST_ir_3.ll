; ModuleID = 'classificationMNIST_files/classificationMNIST_ir_3.bc'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux_gnu"

define void @cluster_0__XlaCompiledKernel_true__XlaNumConstantArgs_0__XlaNumResourceArgs_0_.v23(i8* nocapture align 8 dereferenceable(8) %retval, i8* noalias nocapture readnone %run_options, i8** noalias nocapture readonly %params, i8** noalias nocapture readonly %temps, i64* noalias nocapture readnone %prof_counters) #0 {
dot.loop_body.rhs.1.lr.ph:
  %0 = getelementptr inbounds i8** %params, i64 1
  %arg1.untyped = load i8** %0, align 8, !dereferenceable !0, !align !1
  %1 = bitcast i8* %arg1.untyped to [10 x float]*
  %arg0.untyped = load i8** %params, align 8, !dereferenceable !2, !align !3
  %2 = bitcast i8* %arg0.untyped to [784 x [10 x float]]*
  %3 = getelementptr inbounds i8** %params, i64 2
  %arg2.untyped = load i8** %3, align 8, !dereferenceable !4, !align !3
  %4 = bitcast i8* %arg2.untyped to [1 x [784 x float]]*
  %5 = getelementptr inbounds i8** %temps, i64 2
  %6 = load i8** %5, align 8, !dereferenceable !0, !align !1
  %dot = bitcast i8* %6 to [1 x [10 x float]]*
  br label %dot.loop_body.reduction.lr.ph

dot.loop_body.reduction.lr.ph:                    ; preds = %dot.loop_exit.reduction, %dot.loop_body.rhs.1.lr.ph
  %dot.indvar.rhs.122 = phi i64 [ 0, %dot.loop_body.rhs.1.lr.ph ], [ %invar.inc1, %dot.loop_exit.reduction ]
  br label %dot.loop_body.reduction

dot.loop_body.reduction:                          ; preds = %dot.loop_body.reduction, %dot.loop_body.reduction.lr.ph
  %7 = phi float [ 0.000000e+00, %dot.loop_body.reduction.lr.ph ], [ %13, %dot.loop_body.reduction ]
  %dot.indvar.reduction20 = phi i64 [ 0, %dot.loop_body.reduction.lr.ph ], [ %invar.inc2, %dot.loop_body.reduction ]
  %8 = getelementptr inbounds [1 x [784 x float]]* %4, i64 0, i64 0, i64 %dot.indvar.reduction20
  %9 = load float* %8, align 4
  %10 = getelementptr inbounds [784 x [10 x float]]* %2, i64 0, i64 %dot.indvar.reduction20, i64 %dot.indvar.rhs.122
  %11 = load float* %10, align 4
  %12 = fmul float %9, %11
  %13 = fadd float %7, %12
  %invar.inc2 = add nuw nsw i64 %dot.indvar.reduction20, 1
  %14 = icmp ugt i64 %invar.inc2, 783
  br i1 %14, label %dot.loop_exit.reduction, label %dot.loop_body.reduction, !llvm.loop !5

dot.loop_exit.reduction:                          ; preds = %dot.loop_body.reduction
  %15 = getelementptr inbounds [1 x [10 x float]]* %dot, i64 0, i64 0, i64 %dot.indvar.rhs.122
  store float %13, float* %15, align 4
  %invar.inc1 = add nuw nsw i64 %dot.indvar.rhs.122, 1
  %16 = icmp ugt i64 %invar.inc1, 9
  br i1 %16, label %fusion.2.loop_body.dim.1.lr.ph, label %dot.loop_body.reduction.lr.ph, !llvm.loop !7

fusion.2.loop_body.dim.1.lr.ph:                   ; preds = %dot.loop_exit.reduction
  %17 = getelementptr inbounds i8** %temps, i64 11
  %18 = load i8** %17, align 8, !dereferenceable !8, !align !1
  %fusion.2 = bitcast i8* %18 to [1 x [10 x float]]*
  br label %fusion.2.loop_body.dim.1

fusion.2.loop_body.dim.1:                         ; preds = %fusion.2.loop_body.dim.1, %fusion.2.loop_body.dim.1.lr.ph
  %fusion.2.indvar.dim.116 = phi i64 [ 0, %fusion.2.loop_body.dim.1.lr.ph ], [ %invar.inc4, %fusion.2.loop_body.dim.1 ]
  %19 = getelementptr inbounds [1 x [10 x float]]* %dot, i64 0, i64 0, i64 %fusion.2.indvar.dim.116
  %20 = load float* %19, align 4
  %21 = getelementptr inbounds [10 x float]* %1, i64 0, i64 %fusion.2.indvar.dim.116
  %22 = load float* %21, align 4
  %23 = fadd float %20, %22
  %24 = getelementptr inbounds [1 x [10 x float]]* %fusion.2, i64 0, i64 0, i64 %fusion.2.indvar.dim.116
  store float %23, float* %24, align 4
  %invar.inc4 = add nuw nsw i64 %fusion.2.indvar.dim.116, 1
  %25 = icmp ugt i64 %invar.inc4, 9
  br i1 %25, label %reduce.inner.loop_body.reduction_dim.1.lr.ph, label %fusion.2.loop_body.dim.1, !llvm.loop !9

reduce.inner.loop_body.reduction_dim.1.lr.ph:     ; preds = %fusion.2.loop_body.dim.1
  %26 = getelementptr inbounds i8* %18, i64 48
  br label %reduce.inner.loop_body.reduction_dim.1

reduce.inner.loop_body.reduction_dim.1:           ; preds = %reduce.inner.loop_body.reduction_dim.1, %reduce.inner.loop_body.reduction_dim.1.lr.ph
  %27 = phi float [ 0xFFF0000000000000, %reduce.inner.loop_body.reduction_dim.1.lr.ph ], [ %33, %reduce.inner.loop_body.reduction_dim.1 ]
  %reduce.inner.indvar.reduction_dim.112 = phi i64 [ 0, %reduce.inner.loop_body.reduction_dim.1.lr.ph ], [ %invar.inc6, %reduce.inner.loop_body.reduction_dim.1 ]
  %28 = getelementptr inbounds [1 x [10 x float]]* %fusion.2, i64 0, i64 0, i64 %reduce.inner.indvar.reduction_dim.112
  %29 = load float* %28, align 4
  %30 = fcmp oge float %27, %29
  %31 = fcmp uno float %27, 0.000000e+00
  %32 = or i1 %30, %31
  %33 = select i1 %32, float %27, float %29
  %invar.inc6 = add nuw nsw i64 %reduce.inner.indvar.reduction_dim.112, 1
  %34 = icmp ugt i64 %invar.inc6, 9
  br i1 %34, label %fusion.1.loop_body.dim.1.lr.ph, label %reduce.inner.loop_body.reduction_dim.1, !llvm.loop !10

fusion.1.loop_body.dim.1.lr.ph:                   ; preds = %reduce.inner.loop_body.reduction_dim.1
  %35 = bitcast i8* %26 to float*
  store float %33, float* %35, align 4
  br label %fusion.1.loop_body.dim.1

fusion.1.loop_body.dim.1:                         ; preds = %fusion.1.loop_body.dim.1, %fusion.1.loop_body.dim.1.lr.ph
  %fusion.1.indvar.dim.18 = phi i64 [ 0, %fusion.1.loop_body.dim.1.lr.ph ], [ %invar.inc8, %fusion.1.loop_body.dim.1 ]
  %36 = getelementptr inbounds [1 x [10 x float]]* %dot, i64 0, i64 0, i64 %fusion.1.indvar.dim.18
  %37 = load float* %36, align 4
  %38 = getelementptr inbounds [10 x float]* %1, i64 0, i64 %fusion.1.indvar.dim.18
  %39 = load float* %38, align 4
  %40 = fadd float %37, %39
  %41 = bitcast i8* %26 to float*
  %42 = load float* %41, align 4
  %43 = fsub float %40, %42
  %44 = call float @llvm.exp.f32(float %43)
  %45 = getelementptr inbounds [1 x [10 x float]]* %fusion.2, i64 0, i64 0, i64 %fusion.1.indvar.dim.18
  store float %44, float* %45, align 4
  %invar.inc8 = add nuw nsw i64 %fusion.1.indvar.dim.18, 1
  %46 = icmp ugt i64 %invar.inc8, 9
  br i1 %46, label %reduce.1.inner.loop_body.reduction_dim.1.lr.ph, label %fusion.1.loop_body.dim.1, !llvm.loop !11

reduce.1.inner.loop_body.reduction_dim.1.lr.ph:   ; preds = %fusion.1.loop_body.dim.1
  br label %reduce.1.inner.loop_body.reduction_dim.1

reduce.1.inner.loop_body.reduction_dim.1:         ; preds = %reduce.1.inner.loop_body.reduction_dim.1, %reduce.1.inner.loop_body.reduction_dim.1.lr.ph
  %47 = phi float [ 0.000000e+00, %reduce.1.inner.loop_body.reduction_dim.1.lr.ph ], [ %50, %reduce.1.inner.loop_body.reduction_dim.1 ]
  %reduce.1.inner.indvar.reduction_dim.14 = phi i64 [ 0, %reduce.1.inner.loop_body.reduction_dim.1.lr.ph ], [ %invar.inc11, %reduce.1.inner.loop_body.reduction_dim.1 ]
  %48 = getelementptr inbounds [1 x [10 x float]]* %fusion.2, i64 0, i64 0, i64 %reduce.1.inner.indvar.reduction_dim.14
  %49 = load float* %48, align 4
  %50 = fadd float %47, %49
  %invar.inc11 = add nuw nsw i64 %reduce.1.inner.indvar.reduction_dim.14, 1
  %51 = icmp ugt i64 %invar.inc11, 9
  br i1 %51, label %fusion.loop_body.dim.0.lr.ph, label %reduce.1.inner.loop_body.reduction_dim.1, !llvm.loop !12

fusion.loop_body.dim.0.lr.ph:                     ; preds = %reduce.1.inner.loop_body.reduction_dim.1
  %52 = bitcast i8* %26 to float*
  store float %50, float* %52, align 4
  %fusion = bitcast i8* %6 to [10 x float]*
  br label %fusion.loop_body.dim.0

fusion.loop_body.dim.0:                           ; preds = %fusion.loop_body.dim.0, %fusion.loop_body.dim.0.lr.ph
  %fusion.indvar.dim.02 = phi i64 [ 0, %fusion.loop_body.dim.0.lr.ph ], [ %invar.inc17, %fusion.loop_body.dim.0 ]
  %53 = getelementptr inbounds [1 x [10 x float]]* %fusion.2, i64 0, i64 0, i64 %fusion.indvar.dim.02
  %54 = load float* %53, align 4
  %55 = bitcast i8* %26 to float*
  %56 = load float* %55, align 4
  %57 = fdiv float %54, %56
  %58 = getelementptr inbounds [10 x float]* %fusion, i64 0, i64 %fusion.indvar.dim.02
  store float %57, float* %58, align 4
  %invar.inc17 = add nuw nsw i64 %fusion.indvar.dim.02, 1
  %59 = icmp ugt i64 %invar.inc17, 9
  br i1 %59, label %fusion.loop_exit.dim.0, label %fusion.loop_body.dim.0, !llvm.loop !13

fusion.loop_exit.dim.0:                           ; preds = %fusion.loop_body.dim.0
  %60 = bitcast i8* %retval to i8**
  store i8* %6, i8** %60, align 8
  ret void
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
