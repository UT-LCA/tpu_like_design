; ModuleID = '__compute_module'
source_filename = "__compute_module"
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux_gnu"

define void @cluster_0__XlaCompiledKernel_true__XlaNumConstantArgs_0__XlaNumResourceArgs_0_.v6(i8* align 8 dereferenceable(8) %retval, i8* noalias %run_options, i8** noalias %params, i8** noalias %temps, i64* noalias %prof_counters) #0 {
entry:
  %multiply.invar_address.dim.0 = alloca i64
  %0 = getelementptr inbounds i8*, i8** %params, i64 1
  %arg1.untyped = load i8*, i8** %0, !dereferenceable !0, !align !1
  %1 = bitcast i8* %arg1.untyped to [64 x float]*
  %2 = getelementptr inbounds i8*, i8** %params, i64 0
  %arg0.untyped = load i8*, i8** %2, !dereferenceable !0, !align !1
  %3 = bitcast i8* %arg0.untyped to [64 x float]*
  %4 = getelementptr inbounds i8*, i8** %temps, i64 0
  %5 = load i8*, i8** %4, !dereferenceable !0, !align !1
  %multiply = bitcast i8* %5 to [64 x float]*
  store i64 0, i64* %multiply.invar_address.dim.0
  br label %multiply.loop_header.dim.0

multiply.loop_header.dim.0:                       ; preds = %multiply.loop_body.dim.0, %entry
  %multiply.indvar.dim.0 = load i64, i64* %multiply.invar_address.dim.0
  %6 = icmp uge i64 %multiply.indvar.dim.0, 64
  br i1 %6, label %multiply.loop_exit.dim.0, label %multiply.loop_body.dim.0

multiply.loop_body.dim.0:                         ; preds = %multiply.loop_header.dim.0
  %7 = getelementptr inbounds [64 x float], [64 x float]* %3, i64 0, i64 %multiply.indvar.dim.0
  %8 = load float, float* %7
  %9 = getelementptr inbounds [64 x float], [64 x float]* %1, i64 0, i64 %multiply.indvar.dim.0
  %10 = load float, float* %9
  %11 = fmul float %8, %10
  %12 = getelementptr inbounds [64 x float], [64 x float]* %multiply, i64 0, i64 %multiply.indvar.dim.0
  store float %11, float* %12
  %invar.inc = add nuw nsw i64 %multiply.indvar.dim.0, 1
  store i64 %invar.inc, i64* %multiply.invar_address.dim.0
  br label %multiply.loop_header.dim.0, !llvm.loop !2

multiply.loop_exit.dim.0:                         ; preds = %multiply.loop_header.dim.0
  %tuple.1 = bitcast i8* %retval to [1 x i8*]*
  %13 = getelementptr inbounds [1 x i8*], [1 x i8*]* %tuple.1, i64 0, i64 0
  %14 = bitcast [64 x float]* %multiply to i8*
  store i8* %14, i8** %13
  ret void
}

attributes #0 = { "no-frame-pointer-elim"="false" }

!0 = !{i64 256}
!1 = !{i64 8}
!2 = distinct !{!2, !3}
!3 = !{!"llvm.loop.vectorize.enable", i1 false}
