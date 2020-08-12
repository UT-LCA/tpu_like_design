; ModuleID = '__compute_module'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux_gnu"

@0 = private constant float 0.000000e+00, align 4
@1 = private constant float 0xFFF0000000000000, align 4

define internal void @max_float_.v3(i8* align 4 dereferenceable(4) %retval, i8* noalias %run_options, i8** noalias %params, i8** noalias %temps, i64* noalias %prof_counters) #0 {
entry:
  %0 = getelementptr inbounds i8** %params, i64 1
  %y.untyped = load i8** %0, !dereferenceable !0, !align !0
  %1 = bitcast i8* %y.untyped to float*
  %2 = getelementptr inbounds i8** %params, i64 0
  %x.untyped = load i8** %2, !dereferenceable !0, !align !0
  %3 = bitcast i8* %x.untyped to float*
  %maximum = bitcast i8* %retval to float*
  %4 = load float* %3
  %5 = load float* %1
  %6 = fcmp oge float %4, %5
  %7 = fcmp une float %4, %4
  %8 = or i1 %6, %7
  %9 = select i1 %8, float %4, float %5
  store float %9, float* %maximum
  ret void
}

define internal void @add_float_.v3(i8* align 4 dereferenceable(4) %retval, i8* noalias %run_options, i8** noalias %params, i8** noalias %temps, i64* noalias %prof_counters) #0 {
entry:
  %0 = getelementptr inbounds i8** %params, i64 1
  %y.1.untyped = load i8** %0, !dereferenceable !0, !align !0
  %1 = bitcast i8* %y.1.untyped to float*
  %2 = getelementptr inbounds i8** %params, i64 0
  %x.1.untyped = load i8** %2, !dereferenceable !0, !align !0
  %3 = bitcast i8* %x.1.untyped to float*
  %add = bitcast i8* %retval to float*
  %4 = load float* %3
  %5 = load float* %1
  %6 = fadd float %4, %5
  store float %6, float* %add
  ret void
}

define void @cluster_0__XlaCompiledKernel_true__XlaNumConstantArgs_0__XlaNumResourceArgs_0_.v23(i8* align 8 dereferenceable(8) %retval, i8* noalias %run_options, i8** noalias %params, i8** noalias %temps, i64* noalias %prof_counters) #0 {
entry:
  %fusion.invar_address.dim.0 = alloca i64
  %reduce_function_parameter_addresses13 = alloca i8*, i32 2
  %reduce_function_return_value_address12 = alloca float, i64 1, align 4
  %reduce.1.inner.invar_address.reduction_dim.1 = alloca i64
  %accumulator10 = alloca float, align 4
  %reduce.1.invar_address.dim.0 = alloca i64
  %fusion.1.invar_address.dim.1 = alloca i64
  %fusion.1.invar_address.dim.0 = alloca i64
  %reduce_function_parameter_addresses = alloca i8*, i32 2
  %reduce_function_return_value_address = alloca float, i64 1, align 4
  %reduce.inner.invar_address.reduction_dim.1 = alloca i64
  %accumulator = alloca float, align 4
  %reduce.invar_address.dim.0 = alloca i64
  %fusion.2.invar_address.dim.1 = alloca i64
  %fusion.2.invar_address.dim.0 = alloca i64
  %accum_address = alloca float
  %dot.invar_address.reduction = alloca i64
  %dot.invar_address.rhs.1 = alloca i64
  %dot.invar_address.lhs.0 = alloca i64
  %0 = getelementptr inbounds i8** %params, i64 1
  %arg1.untyped = load i8** %0, !dereferenceable !1, !align !2
  %1 = bitcast i8* %arg1.untyped to [10 x float]*
  %2 = getelementptr inbounds i8** %params, i64 0
  %arg0.untyped = load i8** %2, !dereferenceable !3, !align !4
  %3 = bitcast i8* %arg0.untyped to [784 x [10 x float]]*
  %4 = getelementptr inbounds i8** %params, i64 2
  %arg2.untyped = load i8** %4, !dereferenceable !5, !align !4
  %5 = bitcast i8* %arg2.untyped to [1 x [784 x float]]*
  %6 = getelementptr inbounds i8** %temps, i64 2
  %7 = load i8** %6, !dereferenceable !1, !align !2
  %dot = bitcast i8* %7 to [1 x [10 x float]]*
  store i64 0, i64* %dot.invar_address.lhs.0
  br label %dot.loop_header.lhs.0

dot.loop_header.lhs.0:                            ; preds = %dot.loop_exit.rhs.1, %entry
  %dot.indvar.lhs.0 = load i64* %dot.invar_address.lhs.0
  %8 = icmp uge i64 %dot.indvar.lhs.0, 1
  br i1 %8, label %dot.loop_exit.lhs.0, label %dot.loop_body.lhs.0

dot.loop_body.lhs.0:                              ; preds = %dot.loop_header.lhs.0
  store i64 0, i64* %dot.invar_address.rhs.1
  br label %dot.loop_header.rhs.1

dot.loop_header.rhs.1:                            ; preds = %dot.loop_exit.reduction, %dot.loop_body.lhs.0
  %dot.indvar.rhs.1 = load i64* %dot.invar_address.rhs.1
  %9 = icmp uge i64 %dot.indvar.rhs.1, 10
  br i1 %9, label %dot.loop_exit.rhs.1, label %dot.loop_body.rhs.1

dot.loop_body.rhs.1:                              ; preds = %dot.loop_header.rhs.1
  store i64 0, i64* %dot.invar_address.reduction
  store float 0.000000e+00, float* %accum_address
  br label %dot.loop_header.reduction

dot.loop_header.reduction:                        ; preds = %dot.loop_body.reduction, %dot.loop_body.rhs.1
  %dot.indvar.reduction = load i64* %dot.invar_address.reduction
  %10 = icmp uge i64 %dot.indvar.reduction, 784
  br i1 %10, label %dot.loop_exit.reduction, label %dot.loop_body.reduction

dot.loop_body.reduction:                          ; preds = %dot.loop_header.reduction
  %11 = getelementptr inbounds [1 x [784 x float]]* %5, i64 0, i64 0, i64 %dot.indvar.reduction
  %12 = load float* %11
  %13 = getelementptr inbounds [784 x [10 x float]]* %3, i64 0, i64 %dot.indvar.reduction, i64 %dot.indvar.rhs.1
  %14 = load float* %13
  %15 = load float* %accum_address
  %16 = fmul float %12, %14
  %17 = fadd float %15, %16
  store float %17, float* %accum_address
  %invar.inc2 = add nuw nsw i64 %dot.indvar.reduction, 1
  store i64 %invar.inc2, i64* %dot.invar_address.reduction
  br label %dot.loop_header.reduction, !llvm.loop !6

dot.loop_exit.reduction:                          ; preds = %dot.loop_header.reduction
  %18 = load float* %accum_address
  %19 = getelementptr inbounds [1 x [10 x float]]* %dot, i64 0, i64 0, i64 %dot.indvar.rhs.1
  store float %18, float* %19
  %invar.inc1 = add nuw nsw i64 %dot.indvar.rhs.1, 1
  store i64 %invar.inc1, i64* %dot.invar_address.rhs.1
  br label %dot.loop_header.rhs.1, !llvm.loop !8

dot.loop_exit.rhs.1:                              ; preds = %dot.loop_header.rhs.1
  %invar.inc = add nuw nsw i64 %dot.indvar.lhs.0, 1
  store i64 %invar.inc, i64* %dot.invar_address.lhs.0
  br label %dot.loop_header.lhs.0, !llvm.loop !9

dot.loop_exit.lhs.0:                              ; preds = %dot.loop_header.lhs.0
  %20 = getelementptr inbounds i8** %temps, i64 11
  %21 = load i8** %20, !dereferenceable !10, !align !2
  %fusion.2 = bitcast i8* %21 to [1 x [10 x float]]*
  store i64 0, i64* %fusion.2.invar_address.dim.0
  br label %fusion.2.loop_header.dim.0

fusion.2.loop_header.dim.0:                       ; preds = %fusion.2.loop_exit.dim.1, %dot.loop_exit.lhs.0
  %fusion.2.indvar.dim.0 = load i64* %fusion.2.invar_address.dim.0
  %22 = icmp uge i64 %fusion.2.indvar.dim.0, 1
  br i1 %22, label %fusion.2.loop_exit.dim.0, label %fusion.2.loop_body.dim.0

fusion.2.loop_body.dim.0:                         ; preds = %fusion.2.loop_header.dim.0
  store i64 0, i64* %fusion.2.invar_address.dim.1
  br label %fusion.2.loop_header.dim.1

fusion.2.loop_header.dim.1:                       ; preds = %fusion.2.loop_body.dim.1, %fusion.2.loop_body.dim.0
  %fusion.2.indvar.dim.1 = load i64* %fusion.2.invar_address.dim.1
  %23 = icmp uge i64 %fusion.2.indvar.dim.1, 10
  br i1 %23, label %fusion.2.loop_exit.dim.1, label %fusion.2.loop_body.dim.1

fusion.2.loop_body.dim.1:                         ; preds = %fusion.2.loop_header.dim.1
  %24 = mul nuw nsw i64 %fusion.2.indvar.dim.1, 1
  %25 = add nuw nsw i64 0, %24
  %26 = udiv i64 %25, 10
  %27 = mul nuw nsw i64 %fusion.2.indvar.dim.0, 1
  %28 = add nuw nsw i64 0, %27
  %29 = mul nuw nsw i64 %25, 1
  %30 = add nuw nsw i64 0, %29
  %31 = udiv i64 %30, 10
  %32 = getelementptr inbounds [1 x [10 x float]]* %dot, i64 0, i64 0, i64 %30
  %33 = load float* %32
  %34 = getelementptr inbounds [10 x float]* %1, i64 0, i64 %25
  %35 = load float* %34
  %36 = fadd float %33, %35
  %37 = getelementptr inbounds [1 x [10 x float]]* %fusion.2, i64 0, i64 0, i64 %fusion.2.indvar.dim.1
  store float %36, float* %37
  %invar.inc4 = add nuw nsw i64 %fusion.2.indvar.dim.1, 1
  store i64 %invar.inc4, i64* %fusion.2.invar_address.dim.1
  br label %fusion.2.loop_header.dim.1, !llvm.loop !11

fusion.2.loop_exit.dim.1:                         ; preds = %fusion.2.loop_header.dim.1
  %invar.inc3 = add nuw nsw i64 %fusion.2.indvar.dim.0, 1
  store i64 %invar.inc3, i64* %fusion.2.invar_address.dim.0
  br label %fusion.2.loop_header.dim.0, !llvm.loop !12

fusion.2.loop_exit.dim.0:                         ; preds = %fusion.2.loop_header.dim.0
  %38 = getelementptr inbounds i8** %temps, i64 11
  %39 = load i8** %38, !dereferenceable !10, !align !2
  %40 = getelementptr inbounds i8* %39, i64 48
  %reduce = bitcast i8* %40 to [1 x float]*
  store i64 0, i64* %reduce.invar_address.dim.0
  br label %reduce.loop_header.dim.0

reduce.loop_header.dim.0:                         ; preds = %reduce.inner.loop_exit.reduction_dim.1, %fusion.2.loop_exit.dim.0
  %reduce.indvar.dim.0 = load i64* %reduce.invar_address.dim.0
  %41 = icmp uge i64 %reduce.indvar.dim.0, 1
  br i1 %41, label %reduce.loop_exit.dim.0, label %reduce.loop_body.dim.0

reduce.loop_body.dim.0:                           ; preds = %reduce.loop_header.dim.0
  %42 = load float* @1
  store float %42, float* %accumulator
  store i64 0, i64* %reduce.inner.invar_address.reduction_dim.1
  br label %reduce.inner.loop_header.reduction_dim.1

reduce.inner.loop_header.reduction_dim.1:         ; preds = %reduce.inner.loop_body.reduction_dim.1, %reduce.loop_body.dim.0
  %reduce.inner.indvar.reduction_dim.1 = load i64* %reduce.inner.invar_address.reduction_dim.1
  %43 = icmp uge i64 %reduce.inner.indvar.reduction_dim.1, 10
  br i1 %43, label %reduce.inner.loop_exit.reduction_dim.1, label %reduce.inner.loop_body.reduction_dim.1

reduce.inner.loop_body.reduction_dim.1:           ; preds = %reduce.inner.loop_header.reduction_dim.1
  %44 = getelementptr inbounds [1 x [10 x float]]* %fusion.2, i64 0, i64 0, i64 %reduce.inner.indvar.reduction_dim.1
  %reduce_function_parameter_0_address_as_i8ptr = bitcast float* %accumulator to i8*
  %45 = getelementptr inbounds i8** %reduce_function_parameter_addresses, i64 0
  store i8* %reduce_function_parameter_0_address_as_i8ptr, i8** %45
  %reduce_function_parameter_1_address_as_i8ptr = bitcast float* %44 to i8*
  %46 = getelementptr inbounds i8** %reduce_function_parameter_addresses, i64 1
  store i8* %reduce_function_parameter_1_address_as_i8ptr, i8** %46
  %47 = bitcast float* %reduce_function_return_value_address to i8*
  call void @max_float_.v3(i8* %47, i8* %run_options, i8** %reduce_function_parameter_addresses, i8** %temps, i64* %prof_counters)
  %reduce_function_return_value = load float* %reduce_function_return_value_address
  store float %reduce_function_return_value, float* %accumulator
  %invar.inc6 = add nuw nsw i64 %reduce.inner.indvar.reduction_dim.1, 1
  store i64 %invar.inc6, i64* %reduce.inner.invar_address.reduction_dim.1
  br label %reduce.inner.loop_header.reduction_dim.1, !llvm.loop !13

reduce.inner.loop_exit.reduction_dim.1:           ; preds = %reduce.inner.loop_header.reduction_dim.1
  %48 = load float* %accumulator
  %49 = getelementptr inbounds [1 x float]* %reduce, i64 0, i64 0
  store float %48, float* %49
  %invar.inc5 = add nuw nsw i64 %reduce.indvar.dim.0, 1
  store i64 %invar.inc5, i64* %reduce.invar_address.dim.0
  br label %reduce.loop_header.dim.0, !llvm.loop !14

reduce.loop_exit.dim.0:                           ; preds = %reduce.loop_header.dim.0
  %50 = getelementptr inbounds i8** %temps, i64 11
  %51 = load i8** %50, !dereferenceable !10, !align !2
  %fusion.1 = bitcast i8* %51 to [1 x [10 x float]]*
  store i64 0, i64* %fusion.1.invar_address.dim.0
  br label %fusion.1.loop_header.dim.0

fusion.1.loop_header.dim.0:                       ; preds = %fusion.1.loop_exit.dim.1, %reduce.loop_exit.dim.0
  %fusion.1.indvar.dim.0 = load i64* %fusion.1.invar_address.dim.0
  %52 = icmp uge i64 %fusion.1.indvar.dim.0, 1
  br i1 %52, label %fusion.1.loop_exit.dim.0, label %fusion.1.loop_body.dim.0

fusion.1.loop_body.dim.0:                         ; preds = %fusion.1.loop_header.dim.0
  store i64 0, i64* %fusion.1.invar_address.dim.1
  br label %fusion.1.loop_header.dim.1

fusion.1.loop_header.dim.1:                       ; preds = %fusion.1.loop_body.dim.1, %fusion.1.loop_body.dim.0
  %fusion.1.indvar.dim.1 = load i64* %fusion.1.invar_address.dim.1
  %53 = icmp uge i64 %fusion.1.indvar.dim.1, 10
  br i1 %53, label %fusion.1.loop_exit.dim.1, label %fusion.1.loop_body.dim.1

fusion.1.loop_body.dim.1:                         ; preds = %fusion.1.loop_header.dim.1
  %54 = mul nuw nsw i64 %fusion.1.indvar.dim.1, 1
  %55 = add nuw nsw i64 0, %54
  %56 = udiv i64 %55, 10
  %57 = mul nuw nsw i64 %fusion.1.indvar.dim.0, 1
  %58 = add nuw nsw i64 0, %57
  %59 = mul nuw nsw i64 %55, 1
  %60 = add nuw nsw i64 0, %59
  %61 = udiv i64 %60, 10
  %62 = getelementptr inbounds [1 x [10 x float]]* %dot, i64 0, i64 0, i64 %60
  %63 = load float* %62
  %64 = getelementptr inbounds [10 x float]* %1, i64 0, i64 %55
  %65 = load float* %64
  %66 = fadd float %63, %65
  %67 = getelementptr inbounds [1 x float]* %reduce, i64 0, i64 0
  %68 = load float* %67
  %69 = fsub float %66, %68
  %70 = call float @llvm.exp.f32(float %69)
  %71 = getelementptr inbounds [1 x [10 x float]]* %fusion.1, i64 0, i64 0, i64 %fusion.1.indvar.dim.1
  store float %70, float* %71
  %invar.inc8 = add nuw nsw i64 %fusion.1.indvar.dim.1, 1
  store i64 %invar.inc8, i64* %fusion.1.invar_address.dim.1
  br label %fusion.1.loop_header.dim.1, !llvm.loop !15

fusion.1.loop_exit.dim.1:                         ; preds = %fusion.1.loop_header.dim.1
  %invar.inc7 = add nuw nsw i64 %fusion.1.indvar.dim.0, 1
  store i64 %invar.inc7, i64* %fusion.1.invar_address.dim.0
  br label %fusion.1.loop_header.dim.0, !llvm.loop !16

fusion.1.loop_exit.dim.0:                         ; preds = %fusion.1.loop_header.dim.0
  %72 = getelementptr inbounds i8** %temps, i64 11
  %73 = load i8** %72, !dereferenceable !10, !align !2
  %74 = getelementptr inbounds i8* %73, i64 48
  %reduce.1 = bitcast i8* %74 to [1 x float]*
  store i64 0, i64* %reduce.1.invar_address.dim.0
  br label %reduce.1.loop_header.dim.0

reduce.1.loop_header.dim.0:                       ; preds = %reduce.1.inner.loop_exit.reduction_dim.1, %fusion.1.loop_exit.dim.0
  %reduce.1.indvar.dim.0 = load i64* %reduce.1.invar_address.dim.0
  %75 = icmp uge i64 %reduce.1.indvar.dim.0, 1
  br i1 %75, label %reduce.1.loop_exit.dim.0, label %reduce.1.loop_body.dim.0

reduce.1.loop_body.dim.0:                         ; preds = %reduce.1.loop_header.dim.0
  %76 = load float* @0
  store float %76, float* %accumulator10
  store i64 0, i64* %reduce.1.inner.invar_address.reduction_dim.1
  br label %reduce.1.inner.loop_header.reduction_dim.1

reduce.1.inner.loop_header.reduction_dim.1:       ; preds = %reduce.1.inner.loop_body.reduction_dim.1, %reduce.1.loop_body.dim.0
  %reduce.1.inner.indvar.reduction_dim.1 = load i64* %reduce.1.inner.invar_address.reduction_dim.1
  %77 = icmp uge i64 %reduce.1.inner.indvar.reduction_dim.1, 10
  br i1 %77, label %reduce.1.inner.loop_exit.reduction_dim.1, label %reduce.1.inner.loop_body.reduction_dim.1

reduce.1.inner.loop_body.reduction_dim.1:         ; preds = %reduce.1.inner.loop_header.reduction_dim.1
  %78 = getelementptr inbounds [1 x [10 x float]]* %fusion.1, i64 0, i64 0, i64 %reduce.1.inner.indvar.reduction_dim.1
  %reduce_function_parameter_0_address_as_i8ptr14 = bitcast float* %accumulator10 to i8*
  %79 = getelementptr inbounds i8** %reduce_function_parameter_addresses13, i64 0
  store i8* %reduce_function_parameter_0_address_as_i8ptr14, i8** %79
  %reduce_function_parameter_1_address_as_i8ptr15 = bitcast float* %78 to i8*
  %80 = getelementptr inbounds i8** %reduce_function_parameter_addresses13, i64 1
  store i8* %reduce_function_parameter_1_address_as_i8ptr15, i8** %80
  %81 = bitcast float* %reduce_function_return_value_address12 to i8*
  call void @add_float_.v3(i8* %81, i8* %run_options, i8** %reduce_function_parameter_addresses13, i8** %temps, i64* %prof_counters)
  %reduce_function_return_value16 = load float* %reduce_function_return_value_address12
  store float %reduce_function_return_value16, float* %accumulator10
  %invar.inc11 = add nuw nsw i64 %reduce.1.inner.indvar.reduction_dim.1, 1
  store i64 %invar.inc11, i64* %reduce.1.inner.invar_address.reduction_dim.1
  br label %reduce.1.inner.loop_header.reduction_dim.1, !llvm.loop !17

reduce.1.inner.loop_exit.reduction_dim.1:         ; preds = %reduce.1.inner.loop_header.reduction_dim.1
  %82 = load float* %accumulator10
  %83 = getelementptr inbounds [1 x float]* %reduce.1, i64 0, i64 0
  store float %82, float* %83
  %invar.inc9 = add nuw nsw i64 %reduce.1.indvar.dim.0, 1
  store i64 %invar.inc9, i64* %reduce.1.invar_address.dim.0
  br label %reduce.1.loop_header.dim.0, !llvm.loop !18

reduce.1.loop_exit.dim.0:                         ; preds = %reduce.1.loop_header.dim.0
  %84 = getelementptr inbounds i8** %temps, i64 2
  %85 = load i8** %84, !dereferenceable !1, !align !2
  %fusion = bitcast i8* %85 to [10 x float]*
  store i64 0, i64* %fusion.invar_address.dim.0
  br label %fusion.loop_header.dim.0

fusion.loop_header.dim.0:                         ; preds = %fusion.loop_body.dim.0, %reduce.1.loop_exit.dim.0
  %fusion.indvar.dim.0 = load i64* %fusion.invar_address.dim.0
  %86 = icmp uge i64 %fusion.indvar.dim.0, 10
  br i1 %86, label %fusion.loop_exit.dim.0, label %fusion.loop_body.dim.0

fusion.loop_body.dim.0:                           ; preds = %fusion.loop_header.dim.0
  %87 = mul nuw nsw i64 %fusion.indvar.dim.0, 1
  %88 = add nuw nsw i64 0, %87
  %89 = udiv i64 %88, 10
  %90 = getelementptr inbounds [1 x [10 x float]]* %fusion.1, i64 0, i64 0, i64 %88
  %91 = load float* %90
  %92 = getelementptr inbounds [1 x float]* %reduce.1, i64 0, i64 0
  %93 = load float* %92
  %94 = fdiv float %91, %93
  %95 = getelementptr inbounds [10 x float]* %fusion, i64 0, i64 %fusion.indvar.dim.0
  store float %94, float* %95
  %invar.inc17 = add nuw nsw i64 %fusion.indvar.dim.0, 1
  store i64 %invar.inc17, i64* %fusion.invar_address.dim.0
  br label %fusion.loop_header.dim.0, !llvm.loop !19

fusion.loop_exit.dim.0:                           ; preds = %fusion.loop_header.dim.0
  %tuple.1 = bitcast i8* %retval to [1 x i8*]*
  %96 = getelementptr inbounds [1 x i8*]* %tuple.1, i64 0, i64 0
  %97 = bitcast [10 x float]* %fusion to i8*
  store i8* %97, i8** %96
  ret void
}

; Function Attrs: nounwind readnone speculatable
declare float @llvm.exp.f32(float) #1

attributes #0 = { "no-frame-pointer-elim"="false" }
attributes #1 = { nounwind readnone }

!0 = metadata !{i64 4}
!1 = metadata !{i64 40}
!2 = metadata !{i64 8}
!3 = metadata !{i64 31360}
!4 = metadata !{i64 16}
!5 = metadata !{i64 3136}
!6 = metadata !{metadata !6, metadata !7}
!7 = metadata !{metadata !"llvm.loop.vectorize.enable", i1 false}
!8 = metadata !{metadata !8, metadata !7}
!9 = metadata !{metadata !9, metadata !7}
!10 = metadata !{i64 52}
!11 = metadata !{metadata !11, metadata !7}
!12 = metadata !{metadata !12, metadata !7}
!13 = metadata !{metadata !13, metadata !7}
!14 = metadata !{metadata !14, metadata !7}
!15 = metadata !{metadata !15, metadata !7}
!16 = metadata !{metadata !16, metadata !7}
!17 = metadata !{metadata !17, metadata !7}
!18 = metadata !{metadata !18, metadata !7}
!19 = metadata !{metadata !19, metadata !7}
