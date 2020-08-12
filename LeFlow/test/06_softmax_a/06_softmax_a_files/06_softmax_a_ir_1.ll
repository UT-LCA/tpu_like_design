; ModuleID = '__compute_module'
source_filename = "__compute_module"
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux_gnu"

@0 = private constant float 0.000000e+00, align 4
@1 = private constant float 0xFFF0000000000000, align 4

define internal void @max_float_.v3(i8* align 4 dereferenceable(4) %retval, i8* noalias %run_options, i8** noalias %params, i8** noalias %temps, i64* noalias %prof_counters) #0 {
entry:
  %0 = getelementptr inbounds i8*, i8** %params, i64 1
  %y.untyped = load i8*, i8** %0, !dereferenceable !0, !align !0
  %1 = bitcast i8* %y.untyped to float*
  %2 = getelementptr inbounds i8*, i8** %params, i64 0
  %x.untyped = load i8*, i8** %2, !dereferenceable !0, !align !0
  %3 = bitcast i8* %x.untyped to float*
  %maximum = bitcast i8* %retval to float*
  %4 = load float, float* %3
  %5 = load float, float* %1
  %6 = fcmp oge float %4, %5
  %7 = fcmp une float %4, %4
  %8 = or i1 %6, %7
  %9 = select i1 %8, float %4, float %5
  store float %9, float* %maximum
  ret void
}

define internal void @add_float_.v3(i8* align 4 dereferenceable(4) %retval, i8* noalias %run_options, i8** noalias %params, i8** noalias %temps, i64* noalias %prof_counters) #0 {
entry:
  %0 = getelementptr inbounds i8*, i8** %params, i64 1
  %y.1.untyped = load i8*, i8** %0, !dereferenceable !0, !align !0
  %1 = bitcast i8* %y.1.untyped to float*
  %2 = getelementptr inbounds i8*, i8** %params, i64 0
  %x.1.untyped = load i8*, i8** %2, !dereferenceable !0, !align !0
  %3 = bitcast i8* %x.1.untyped to float*
  %add = bitcast i8* %retval to float*
  %4 = load float, float* %3
  %5 = load float, float* %1
  %6 = fadd float %4, %5
  store float %6, float* %add
  ret void
}

define void @cluster_0__XlaCompiledKernel_true__XlaNumConstantArgs_0__XlaNumResourceArgs_0_.v15(i8* align 8 dereferenceable(8) %retval, i8* noalias %run_options, i8** noalias %params, i8** noalias %temps, i64* noalias %prof_counters) #0 {
entry:
  %fusion.invar_address.dim.0 = alloca i64
  %reduce_function_parameter_addresses8 = alloca i8*, i32 2
  %reduce_function_return_value_address7 = alloca float, i64 1, align 4
  %reduce.1.inner.invar_address.reduction_dim.1 = alloca i64
  %accumulator5 = alloca float, align 4
  %reduce.1.invar_address.dim.0 = alloca i64
  %fusion.1.invar_address.dim.1 = alloca i64
  %fusion.1.invar_address.dim.0 = alloca i64
  %reduce_function_parameter_addresses = alloca i8*, i32 2
  %reduce_function_return_value_address = alloca float, i64 1, align 4
  %reduce.inner.invar_address.reduction_dim.1 = alloca i64
  %accumulator = alloca float, align 4
  %reduce.invar_address.dim.0 = alloca i64
  %0 = getelementptr inbounds i8*, i8** %params, i64 0
  %arg0.untyped = load i8*, i8** %0, !dereferenceable !1, !align !2
  %1 = bitcast i8* %arg0.untyped to [8 x float]*
  %bitcast = bitcast [8 x float]* %1 to [1 x [8 x float]]*
  %2 = getelementptr inbounds i8*, i8** %temps, i64 0
  %3 = load i8*, i8** %2, !dereferenceable !1, !align !2
  %reduce = bitcast i8* %3 to [1 x float]*
  store i64 0, i64* %reduce.invar_address.dim.0
  br label %reduce.loop_header.dim.0

reduce.loop_header.dim.0:                         ; preds = %reduce.inner.loop_exit.reduction_dim.1, %entry
  %reduce.indvar.dim.0 = load i64, i64* %reduce.invar_address.dim.0
  %4 = icmp uge i64 %reduce.indvar.dim.0, 1
  br i1 %4, label %reduce.loop_exit.dim.0, label %reduce.loop_body.dim.0

reduce.loop_body.dim.0:                           ; preds = %reduce.loop_header.dim.0
  %5 = load float, float* @1
  store float %5, float* %accumulator
  store i64 0, i64* %reduce.inner.invar_address.reduction_dim.1
  br label %reduce.inner.loop_header.reduction_dim.1

reduce.inner.loop_header.reduction_dim.1:         ; preds = %reduce.inner.loop_body.reduction_dim.1, %reduce.loop_body.dim.0
  %reduce.inner.indvar.reduction_dim.1 = load i64, i64* %reduce.inner.invar_address.reduction_dim.1
  %6 = icmp uge i64 %reduce.inner.indvar.reduction_dim.1, 8
  br i1 %6, label %reduce.inner.loop_exit.reduction_dim.1, label %reduce.inner.loop_body.reduction_dim.1

reduce.inner.loop_body.reduction_dim.1:           ; preds = %reduce.inner.loop_header.reduction_dim.1
  %7 = getelementptr inbounds [1 x [8 x float]], [1 x [8 x float]]* %bitcast, i64 0, i64 0, i64 %reduce.inner.indvar.reduction_dim.1
  %reduce_function_parameter_0_address_as_i8ptr = bitcast float* %accumulator to i8*
  %8 = getelementptr inbounds i8*, i8** %reduce_function_parameter_addresses, i64 0
  store i8* %reduce_function_parameter_0_address_as_i8ptr, i8** %8
  %reduce_function_parameter_1_address_as_i8ptr = bitcast float* %7 to i8*
  %9 = getelementptr inbounds i8*, i8** %reduce_function_parameter_addresses, i64 1
  store i8* %reduce_function_parameter_1_address_as_i8ptr, i8** %9
  %10 = bitcast float* %reduce_function_return_value_address to i8*
  call void @max_float_.v3(i8* %10, i8* %run_options, i8** %reduce_function_parameter_addresses, i8** %temps, i64* %prof_counters)
  %reduce_function_return_value = load float, float* %reduce_function_return_value_address
  store float %reduce_function_return_value, float* %accumulator
  %invar.inc1 = add nuw nsw i64 %reduce.inner.indvar.reduction_dim.1, 1
  store i64 %invar.inc1, i64* %reduce.inner.invar_address.reduction_dim.1
  br label %reduce.inner.loop_header.reduction_dim.1, !llvm.loop !3

reduce.inner.loop_exit.reduction_dim.1:           ; preds = %reduce.inner.loop_header.reduction_dim.1
  %11 = load float, float* %accumulator
  %12 = getelementptr inbounds [1 x float], [1 x float]* %reduce, i64 0, i64 0
  store float %11, float* %12
  %invar.inc = add nuw nsw i64 %reduce.indvar.dim.0, 1
  store i64 %invar.inc, i64* %reduce.invar_address.dim.0
  br label %reduce.loop_header.dim.0, !llvm.loop !5

reduce.loop_exit.dim.0:                           ; preds = %reduce.loop_header.dim.0
  %13 = getelementptr inbounds i8*, i8** %temps, i64 9
  %14 = load i8*, i8** %13, !dereferenceable !6, !align !2
  %fusion.1 = bitcast i8* %14 to [1 x [8 x float]]*
  store i64 0, i64* %fusion.1.invar_address.dim.0
  br label %fusion.1.loop_header.dim.0

fusion.1.loop_header.dim.0:                       ; preds = %fusion.1.loop_exit.dim.1, %reduce.loop_exit.dim.0
  %fusion.1.indvar.dim.0 = load i64, i64* %fusion.1.invar_address.dim.0
  %15 = icmp uge i64 %fusion.1.indvar.dim.0, 1
  br i1 %15, label %fusion.1.loop_exit.dim.0, label %fusion.1.loop_body.dim.0

fusion.1.loop_body.dim.0:                         ; preds = %fusion.1.loop_header.dim.0
  store i64 0, i64* %fusion.1.invar_address.dim.1
  br label %fusion.1.loop_header.dim.1

fusion.1.loop_header.dim.1:                       ; preds = %fusion.1.loop_body.dim.1, %fusion.1.loop_body.dim.0
  %fusion.1.indvar.dim.1 = load i64, i64* %fusion.1.invar_address.dim.1
  %16 = icmp uge i64 %fusion.1.indvar.dim.1, 8
  br i1 %16, label %fusion.1.loop_exit.dim.1, label %fusion.1.loop_body.dim.1

fusion.1.loop_body.dim.1:                         ; preds = %fusion.1.loop_header.dim.1
  %17 = getelementptr inbounds [1 x [8 x float]], [1 x [8 x float]]* %bitcast, i64 0, i64 0, i64 %fusion.1.indvar.dim.1
  %18 = load float, float* %17
  %19 = getelementptr inbounds [1 x float], [1 x float]* %reduce, i64 0, i64 0
  %20 = load float, float* %19
  %21 = fsub float %18, %20
  %22 = call float @llvm.exp.f32(float %21)
  %23 = getelementptr inbounds [1 x [8 x float]], [1 x [8 x float]]* %fusion.1, i64 0, i64 0, i64 %fusion.1.indvar.dim.1
  store float %22, float* %23
  %invar.inc3 = add nuw nsw i64 %fusion.1.indvar.dim.1, 1
  store i64 %invar.inc3, i64* %fusion.1.invar_address.dim.1
  br label %fusion.1.loop_header.dim.1, !llvm.loop !7

fusion.1.loop_exit.dim.1:                         ; preds = %fusion.1.loop_header.dim.1
  %invar.inc2 = add nuw nsw i64 %fusion.1.indvar.dim.0, 1
  store i64 %invar.inc2, i64* %fusion.1.invar_address.dim.0
  br label %fusion.1.loop_header.dim.0, !llvm.loop !8

fusion.1.loop_exit.dim.0:                         ; preds = %fusion.1.loop_header.dim.0
  %24 = getelementptr inbounds i8*, i8** %temps, i64 9
  %25 = load i8*, i8** %24, !dereferenceable !6, !align !2
  %26 = getelementptr inbounds i8, i8* %25, i64 32
  %reduce.1 = bitcast i8* %26 to [1 x float]*
  store i64 0, i64* %reduce.1.invar_address.dim.0
  br label %reduce.1.loop_header.dim.0

reduce.1.loop_header.dim.0:                       ; preds = %reduce.1.inner.loop_exit.reduction_dim.1, %fusion.1.loop_exit.dim.0
  %reduce.1.indvar.dim.0 = load i64, i64* %reduce.1.invar_address.dim.0
  %27 = icmp uge i64 %reduce.1.indvar.dim.0, 1
  br i1 %27, label %reduce.1.loop_exit.dim.0, label %reduce.1.loop_body.dim.0

reduce.1.loop_body.dim.0:                         ; preds = %reduce.1.loop_header.dim.0
  %28 = load float, float* @0
  store float %28, float* %accumulator5
  store i64 0, i64* %reduce.1.inner.invar_address.reduction_dim.1
  br label %reduce.1.inner.loop_header.reduction_dim.1

reduce.1.inner.loop_header.reduction_dim.1:       ; preds = %reduce.1.inner.loop_body.reduction_dim.1, %reduce.1.loop_body.dim.0
  %reduce.1.inner.indvar.reduction_dim.1 = load i64, i64* %reduce.1.inner.invar_address.reduction_dim.1
  %29 = icmp uge i64 %reduce.1.inner.indvar.reduction_dim.1, 8
  br i1 %29, label %reduce.1.inner.loop_exit.reduction_dim.1, label %reduce.1.inner.loop_body.reduction_dim.1

reduce.1.inner.loop_body.reduction_dim.1:         ; preds = %reduce.1.inner.loop_header.reduction_dim.1
  %30 = getelementptr inbounds [1 x [8 x float]], [1 x [8 x float]]* %fusion.1, i64 0, i64 0, i64 %reduce.1.inner.indvar.reduction_dim.1
  %reduce_function_parameter_0_address_as_i8ptr9 = bitcast float* %accumulator5 to i8*
  %31 = getelementptr inbounds i8*, i8** %reduce_function_parameter_addresses8, i64 0
  store i8* %reduce_function_parameter_0_address_as_i8ptr9, i8** %31
  %reduce_function_parameter_1_address_as_i8ptr10 = bitcast float* %30 to i8*
  %32 = getelementptr inbounds i8*, i8** %reduce_function_parameter_addresses8, i64 1
  store i8* %reduce_function_parameter_1_address_as_i8ptr10, i8** %32
  %33 = bitcast float* %reduce_function_return_value_address7 to i8*
  call void @add_float_.v3(i8* %33, i8* %run_options, i8** %reduce_function_parameter_addresses8, i8** %temps, i64* %prof_counters)
  %reduce_function_return_value11 = load float, float* %reduce_function_return_value_address7
  store float %reduce_function_return_value11, float* %accumulator5
  %invar.inc6 = add nuw nsw i64 %reduce.1.inner.indvar.reduction_dim.1, 1
  store i64 %invar.inc6, i64* %reduce.1.inner.invar_address.reduction_dim.1
  br label %reduce.1.inner.loop_header.reduction_dim.1, !llvm.loop !9

reduce.1.inner.loop_exit.reduction_dim.1:         ; preds = %reduce.1.inner.loop_header.reduction_dim.1
  %34 = load float, float* %accumulator5
  %35 = getelementptr inbounds [1 x float], [1 x float]* %reduce.1, i64 0, i64 0
  store float %34, float* %35
  %invar.inc4 = add nuw nsw i64 %reduce.1.indvar.dim.0, 1
  store i64 %invar.inc4, i64* %reduce.1.invar_address.dim.0
  br label %reduce.1.loop_header.dim.0, !llvm.loop !10

reduce.1.loop_exit.dim.0:                         ; preds = %reduce.1.loop_header.dim.0
  %36 = getelementptr inbounds i8*, i8** %temps, i64 0
  %37 = load i8*, i8** %36, !dereferenceable !1, !align !2
  %fusion = bitcast i8* %37 to [8 x float]*
  store i64 0, i64* %fusion.invar_address.dim.0
  br label %fusion.loop_header.dim.0

fusion.loop_header.dim.0:                         ; preds = %fusion.loop_body.dim.0, %reduce.1.loop_exit.dim.0
  %fusion.indvar.dim.0 = load i64, i64* %fusion.invar_address.dim.0
  %38 = icmp uge i64 %fusion.indvar.dim.0, 8
  br i1 %38, label %fusion.loop_exit.dim.0, label %fusion.loop_body.dim.0

fusion.loop_body.dim.0:                           ; preds = %fusion.loop_header.dim.0
  %39 = mul nuw nsw i64 %fusion.indvar.dim.0, 1
  %40 = add nuw nsw i64 0, %39
  %41 = udiv i64 %40, 8
  %42 = getelementptr inbounds [1 x [8 x float]], [1 x [8 x float]]* %fusion.1, i64 0, i64 0, i64 %40
  %43 = load float, float* %42
  %44 = getelementptr inbounds [1 x float], [1 x float]* %reduce.1, i64 0, i64 0
  %45 = load float, float* %44
  %46 = fdiv float %43, %45
  %47 = getelementptr inbounds [8 x float], [8 x float]* %fusion, i64 0, i64 %fusion.indvar.dim.0
  store float %46, float* %47
  %invar.inc12 = add nuw nsw i64 %fusion.indvar.dim.0, 1
  store i64 %invar.inc12, i64* %fusion.invar_address.dim.0
  br label %fusion.loop_header.dim.0, !llvm.loop !11

fusion.loop_exit.dim.0:                           ; preds = %fusion.loop_header.dim.0
  %tuple.1 = bitcast i8* %retval to [1 x i8*]*
  %48 = getelementptr inbounds [1 x i8*], [1 x i8*]* %tuple.1, i64 0, i64 0
  %49 = bitcast [8 x float]* %fusion to i8*
  store i8* %49, i8** %48
  ret void
}

; Function Attrs: nounwind readnone speculatable
declare float @llvm.exp.f32(float) #1

attributes #0 = { "no-frame-pointer-elim"="false" }
attributes #1 = { nounwind readnone speculatable }

!0 = !{i64 4}
!1 = !{i64 32}
!2 = !{i64 8}
!3 = distinct !{!3, !4}
!4 = !{!"llvm.loop.vectorize.enable", i1 false}
!5 = distinct !{!5, !4}
!6 = !{i64 36}
!7 = distinct !{!7, !4}
!8 = distinct !{!8, !4}
!9 = distinct !{!9, !4}
!10 = distinct !{!10, !4}
!11 = distinct !{!11, !4}
