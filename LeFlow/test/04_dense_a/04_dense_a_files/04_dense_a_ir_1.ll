; ModuleID = '__compute_module'
source_filename = "__compute_module"
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux_gnu"

define void @cluster_0__XlaCompiledKernel_true__XlaNumConstantArgs_0__XlaNumResourceArgs_0_.v12(i8* align 8 dereferenceable(8) %retval, i8* noalias %run_options, i8** noalias %params, i8** noalias %temps, i64* noalias %prof_counters) #0 {
entry:
  %fusion.invar_address.dim.0 = alloca i64
  %accum_address = alloca float
  %dot.invar_address.reduction = alloca i64
  %dot.invar_address.rhs.1 = alloca i64
  %dot.invar_address.lhs.0 = alloca i64
  %0 = getelementptr inbounds i8*, i8** %params, i64 1
  %arg1.untyped = load i8*, i8** %0, !dereferenceable !0, !align !1
  %1 = bitcast i8* %arg1.untyped to [1 x [8 x float]]*
  %2 = getelementptr inbounds i8*, i8** %params, i64 0
  %arg0.untyped = load i8*, i8** %2, !dereferenceable !2, !align !1
  %3 = bitcast i8* %arg0.untyped to [1 x [1 x float]]*
  %4 = getelementptr inbounds i8*, i8** %params, i64 2
  %arg2.untyped = load i8*, i8** %4, !dereferenceable !0, !align !1
  %5 = bitcast i8* %arg2.untyped to [8 x float]*
  %6 = getelementptr inbounds i8*, i8** %temps, i64 5
  %7 = load i8*, i8** %6, !dereferenceable !0, !align !1
  %dot = bitcast i8* %7 to [1 x [8 x float]]*
  store i64 0, i64* %dot.invar_address.lhs.0
  br label %dot.loop_header.lhs.0

dot.loop_header.lhs.0:                            ; preds = %dot.loop_exit.rhs.1, %entry
  %dot.indvar.lhs.0 = load i64, i64* %dot.invar_address.lhs.0
  %8 = icmp uge i64 %dot.indvar.lhs.0, 1
  br i1 %8, label %dot.loop_exit.lhs.0, label %dot.loop_body.lhs.0

dot.loop_body.lhs.0:                              ; preds = %dot.loop_header.lhs.0
  store i64 0, i64* %dot.invar_address.rhs.1
  br label %dot.loop_header.rhs.1

dot.loop_header.rhs.1:                            ; preds = %dot.loop_exit.reduction, %dot.loop_body.lhs.0
  %dot.indvar.rhs.1 = load i64, i64* %dot.invar_address.rhs.1
  %9 = icmp uge i64 %dot.indvar.rhs.1, 8
  br i1 %9, label %dot.loop_exit.rhs.1, label %dot.loop_body.rhs.1

dot.loop_body.rhs.1:                              ; preds = %dot.loop_header.rhs.1
  store i64 0, i64* %dot.invar_address.reduction
  store float 0.000000e+00, float* %accum_address
  br label %dot.loop_header.reduction

dot.loop_header.reduction:                        ; preds = %dot.loop_body.reduction, %dot.loop_body.rhs.1
  %dot.indvar.reduction = load i64, i64* %dot.invar_address.reduction
  %10 = icmp uge i64 %dot.indvar.reduction, 1
  br i1 %10, label %dot.loop_exit.reduction, label %dot.loop_body.reduction

dot.loop_body.reduction:                          ; preds = %dot.loop_header.reduction
  %11 = getelementptr inbounds [1 x [1 x float]], [1 x [1 x float]]* %3, i64 0, i64 0, i64 0
  %12 = load float, float* %11
  %13 = getelementptr inbounds [1 x [8 x float]], [1 x [8 x float]]* %1, i64 0, i64 0, i64 %dot.indvar.rhs.1
  %14 = load float, float* %13
  %15 = load float, float* %accum_address
  %16 = fmul float %12, %14
  %17 = fadd float %15, %16
  store float %17, float* %accum_address
  %invar.inc2 = add nuw nsw i64 %dot.indvar.reduction, 1
  store i64 %invar.inc2, i64* %dot.invar_address.reduction
  br label %dot.loop_header.reduction, !llvm.loop !3

dot.loop_exit.reduction:                          ; preds = %dot.loop_header.reduction
  %18 = load float, float* %accum_address
  %19 = getelementptr inbounds [1 x [8 x float]], [1 x [8 x float]]* %dot, i64 0, i64 0, i64 %dot.indvar.rhs.1
  store float %18, float* %19
  %invar.inc1 = add nuw nsw i64 %dot.indvar.rhs.1, 1
  store i64 %invar.inc1, i64* %dot.invar_address.rhs.1
  br label %dot.loop_header.rhs.1, !llvm.loop !5

dot.loop_exit.rhs.1:                              ; preds = %dot.loop_header.rhs.1
  %invar.inc = add nuw nsw i64 %dot.indvar.lhs.0, 1
  store i64 %invar.inc, i64* %dot.invar_address.lhs.0
  br label %dot.loop_header.lhs.0, !llvm.loop !6

dot.loop_exit.lhs.0:                              ; preds = %dot.loop_header.lhs.0
  %20 = getelementptr inbounds i8*, i8** %temps, i64 0
  %21 = load i8*, i8** %20, !dereferenceable !0, !align !1
  %fusion = bitcast i8* %21 to [8 x float]*
  store i64 0, i64* %fusion.invar_address.dim.0
  br label %fusion.loop_header.dim.0

fusion.loop_header.dim.0:                         ; preds = %fusion.loop_body.dim.0, %dot.loop_exit.lhs.0
  %fusion.indvar.dim.0 = load i64, i64* %fusion.invar_address.dim.0
  %22 = icmp uge i64 %fusion.indvar.dim.0, 8
  br i1 %22, label %fusion.loop_exit.dim.0, label %fusion.loop_body.dim.0

fusion.loop_body.dim.0:                           ; preds = %fusion.loop_header.dim.0
  %23 = getelementptr inbounds [8 x float], [8 x float]* %5, i64 0, i64 %fusion.indvar.dim.0
  %24 = load float, float* %23
  %25 = mul nuw nsw i64 %fusion.indvar.dim.0, 1
  %26 = add nuw nsw i64 0, %25
  %27 = udiv i64 %26, 8
  %28 = getelementptr inbounds [1 x [8 x float]], [1 x [8 x float]]* %dot, i64 0, i64 0, i64 %26
  %29 = load float, float* %28
  %30 = fadd float %24, %29
  %31 = getelementptr inbounds [8 x float], [8 x float]* %fusion, i64 0, i64 %fusion.indvar.dim.0
  store float %30, float* %31
  %invar.inc3 = add nuw nsw i64 %fusion.indvar.dim.0, 1
  store i64 %invar.inc3, i64* %fusion.invar_address.dim.0
  br label %fusion.loop_header.dim.0, !llvm.loop !7

fusion.loop_exit.dim.0:                           ; preds = %fusion.loop_header.dim.0
  %tuple.1 = bitcast i8* %retval to [1 x i8*]*
  %32 = getelementptr inbounds [1 x i8*], [1 x i8*]* %tuple.1, i64 0, i64 0
  %33 = bitcast [8 x float]* %fusion to i8*
  store i8* %33, i8** %32
  ret void
}

attributes #0 = { "no-frame-pointer-elim"="false" }

!0 = !{i64 32}
!1 = !{i64 8}
!2 = !{i64 4}
!3 = distinct !{!3, !4}
!4 = !{!"llvm.loop.vectorize.enable", i1 false}
!5 = distinct !{!5, !4}
!6 = distinct !{!6, !4}
!7 = distinct !{!7, !4}
