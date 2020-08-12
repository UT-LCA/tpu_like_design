; ModuleID = '__compute_module'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux_gnu"

@0 = private constant float 0.000000e+00, align 4
@1 = private constant float 5.000000e-01, align 4

define void @cluster_0__XlaCompiledKernel_true__XlaNumConstantArgs_0__XlaNumResourceArgs_0_.v13(i8* align 8 dereferenceable(8) %retval, i8* noalias %run_options, i8** noalias %params, i8** noalias %temps, i64* noalias %prof_counters) #0 {
entry:
  %fusion.invar_address.dim.0 = alloca i64
  %0 = getelementptr inbounds i8** %params, i64 0
  %arg0.untyped = load i8** %0, !dereferenceable !0, !align !1
  %1 = bitcast i8* %arg0.untyped to [8 x float]*
  %2 = getelementptr inbounds i8** %temps, i64 0
  %3 = load i8** %2, !dereferenceable !0, !align !1
  %fusion = bitcast i8* %3 to [8 x float]*
  store i64 0, i64* %fusion.invar_address.dim.0
  br label %fusion.loop_header.dim.0

fusion.loop_header.dim.0:                         ; preds = %fusion.loop_body.dim.0, %entry
  %fusion.indvar.dim.0 = load i64* %fusion.invar_address.dim.0
  %4 = icmp uge i64 %fusion.indvar.dim.0, 8
  br i1 %4, label %fusion.loop_exit.dim.0, label %fusion.loop_body.dim.0

fusion.loop_body.dim.0:                           ; preds = %fusion.loop_header.dim.0
  %5 = load float* @1
  %6 = load float* @0
  %7 = getelementptr inbounds [8 x float]* %1, i64 0, i64 %fusion.indvar.dim.0
  %8 = load float* %7
  %9 = call float @tanhf(float %8)
  %10 = call float @llvm.exp.f32(float %9)
  %11 = fcmp oge float %6, %10
  %12 = fcmp une float %6, %6
  %13 = or i1 %11, %12
  %14 = select i1 %13, float %6, float %10
  %15 = fmul float %5, %14
  %16 = call float @tanhf(float %15)
  %17 = fmul float %5, %16
  %18 = fadd float %5, %17
  %19 = getelementptr inbounds [8 x float]* %fusion, i64 0, i64 %fusion.indvar.dim.0
  store float %18, float* %19
  %invar.inc = add nuw nsw i64 %fusion.indvar.dim.0, 1
  store i64 %invar.inc, i64* %fusion.invar_address.dim.0
  br label %fusion.loop_header.dim.0, !llvm.loop !2

fusion.loop_exit.dim.0:                           ; preds = %fusion.loop_header.dim.0
  %tuple.1 = bitcast i8* %retval to [1 x i8*]*
  %20 = getelementptr inbounds [1 x i8*]* %tuple.1, i64 0, i64 0
  %21 = bitcast [8 x float]* %fusion to i8*
  store i8* %21, i8** %20
  ret void
}

; Function Attrs: nounwind readnone
declare float @tanhf(float) #1

; Function Attrs: nounwind readnone speculatable
declare float @llvm.exp.f32(float) #2

attributes #0 = { "no-frame-pointer-elim"="false" }
attributes #1 = { nounwind readnone }
attributes #2 = { nounwind readnone }

!0 = metadata !{i64 32}
!1 = metadata !{i64 8}
!2 = metadata !{metadata !2, metadata !3}
!3 = metadata !{metadata !"llvm.loop.vectorize.enable", i1 false}
