; ModuleID = '__compute_module'
source_filename = "__compute_module"
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux_gnu"

@0 = private constant float 0xFFF0000000000000, align 4

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

define void @cluster_0__XlaCompiledKernel_true__XlaNumConstantArgs_0__XlaNumResourceArgs_0_.v6(i8* align 8 dereferenceable(8) %retval, i8* noalias %run_options, i8** noalias %params, i8** noalias %temps, i64* noalias %prof_counters) #0 {
entry:
  %reducer_function_parameter_addresses = alloca i8*, i32 2
  %reducer_function_return_value_address = alloca float, i64 1, align 4
  %reduce-window.inner.invar_address.window.3 = alloca i64
  %reduce-window.inner.invar_address.window.2 = alloca i64
  %reduce-window.inner.invar_address.window.1 = alloca i64
  %reduce-window.inner.invar_address.window.0 = alloca i64
  %reduce_window_accumulator_address = alloca float, align 4
  %reduce-window.invar_address.dim.3 = alloca i64
  %reduce-window.invar_address.dim.2 = alloca i64
  %reduce-window.invar_address.dim.1 = alloca i64
  %reduce-window.invar_address.dim.0 = alloca i64
  %0 = getelementptr inbounds i8*, i8** %params, i64 0
  %arg0.untyped = load i8*, i8** %0, !dereferenceable !1, !align !2
  %1 = bitcast i8* %arg0.untyped to [1 x [32 x [32 x [1 x float]]]]*
  %2 = getelementptr inbounds i8*, i8** %temps, i64 1
  %3 = load i8*, i8** %2, !dereferenceable !3, !align !4
  %reduce-window = bitcast i8* %3 to [1 x [10 x [10 x [1 x float]]]]*
  store i64 0, i64* %reduce-window.invar_address.dim.0
  br label %reduce-window.loop_header.dim.0

reduce-window.loop_header.dim.0:                  ; preds = %reduce-window.loop_exit.dim.1, %entry
  %reduce-window.indvar.dim.0 = load i64, i64* %reduce-window.invar_address.dim.0
  %4 = icmp uge i64 %reduce-window.indvar.dim.0, 1
  br i1 %4, label %reduce-window.loop_exit.dim.0, label %reduce-window.loop_body.dim.0

reduce-window.loop_body.dim.0:                    ; preds = %reduce-window.loop_header.dim.0
  store i64 0, i64* %reduce-window.invar_address.dim.1
  br label %reduce-window.loop_header.dim.1

reduce-window.loop_header.dim.1:                  ; preds = %reduce-window.loop_exit.dim.2, %reduce-window.loop_body.dim.0
  %reduce-window.indvar.dim.1 = load i64, i64* %reduce-window.invar_address.dim.1
  %5 = icmp uge i64 %reduce-window.indvar.dim.1, 10
  br i1 %5, label %reduce-window.loop_exit.dim.1, label %reduce-window.loop_body.dim.1

reduce-window.loop_body.dim.1:                    ; preds = %reduce-window.loop_header.dim.1
  store i64 0, i64* %reduce-window.invar_address.dim.2
  br label %reduce-window.loop_header.dim.2

reduce-window.loop_header.dim.2:                  ; preds = %reduce-window.loop_exit.dim.3, %reduce-window.loop_body.dim.1
  %reduce-window.indvar.dim.2 = load i64, i64* %reduce-window.invar_address.dim.2
  %6 = icmp uge i64 %reduce-window.indvar.dim.2, 10
  br i1 %6, label %reduce-window.loop_exit.dim.2, label %reduce-window.loop_body.dim.2

reduce-window.loop_body.dim.2:                    ; preds = %reduce-window.loop_header.dim.2
  store i64 0, i64* %reduce-window.invar_address.dim.3
  br label %reduce-window.loop_header.dim.3

reduce-window.loop_header.dim.3:                  ; preds = %reduce-window.inner.loop_exit.window.0, %reduce-window.loop_body.dim.2
  %reduce-window.indvar.dim.3 = load i64, i64* %reduce-window.invar_address.dim.3
  %7 = icmp uge i64 %reduce-window.indvar.dim.3, 1
  br i1 %7, label %reduce-window.loop_exit.dim.3, label %reduce-window.loop_body.dim.3

reduce-window.loop_body.dim.3:                    ; preds = %reduce-window.loop_header.dim.3
  %8 = load float, float* @0
  store float %8, float* %reduce_window_accumulator_address
  store i64 0, i64* %reduce-window.inner.invar_address.window.0
  br label %reduce-window.inner.loop_header.window.0

reduce-window.inner.loop_header.window.0:         ; preds = %reduce-window.inner.loop_exit.window.1, %reduce-window.loop_body.dim.3
  %reduce-window.inner.indvar.window.0 = load i64, i64* %reduce-window.inner.invar_address.window.0
  %9 = icmp uge i64 %reduce-window.inner.indvar.window.0, 1
  br i1 %9, label %reduce-window.inner.loop_exit.window.0, label %reduce-window.inner.loop_body.window.0

reduce-window.inner.loop_body.window.0:           ; preds = %reduce-window.inner.loop_header.window.0
  store i64 0, i64* %reduce-window.inner.invar_address.window.1
  br label %reduce-window.inner.loop_header.window.1

reduce-window.inner.loop_header.window.1:         ; preds = %reduce-window.inner.loop_exit.window.2, %reduce-window.inner.loop_body.window.0
  %reduce-window.inner.indvar.window.1 = load i64, i64* %reduce-window.inner.invar_address.window.1
  %10 = icmp uge i64 %reduce-window.inner.indvar.window.1, 3
  br i1 %10, label %reduce-window.inner.loop_exit.window.1, label %reduce-window.inner.loop_body.window.1

reduce-window.inner.loop_body.window.1:           ; preds = %reduce-window.inner.loop_header.window.1
  store i64 0, i64* %reduce-window.inner.invar_address.window.2
  br label %reduce-window.inner.loop_header.window.2

reduce-window.inner.loop_header.window.2:         ; preds = %reduce-window.inner.loop_exit.window.3, %reduce-window.inner.loop_body.window.1
  %reduce-window.inner.indvar.window.2 = load i64, i64* %reduce-window.inner.invar_address.window.2
  %11 = icmp uge i64 %reduce-window.inner.indvar.window.2, 3
  br i1 %11, label %reduce-window.inner.loop_exit.window.2, label %reduce-window.inner.loop_body.window.2

reduce-window.inner.loop_body.window.2:           ; preds = %reduce-window.inner.loop_header.window.2
  store i64 0, i64* %reduce-window.inner.invar_address.window.3
  br label %reduce-window.inner.loop_header.window.3

reduce-window.inner.loop_header.window.3:         ; preds = %in-bounds-after, %reduce-window.inner.loop_body.window.2
  %reduce-window.inner.indvar.window.3 = load i64, i64* %reduce-window.inner.invar_address.window.3
  %12 = icmp uge i64 %reduce-window.inner.indvar.window.3, 1
  br i1 %12, label %reduce-window.inner.loop_exit.window.3, label %reduce-window.inner.loop_body.window.3

reduce-window.inner.loop_body.window.3:           ; preds = %reduce-window.inner.loop_header.window.3
  %13 = mul nsw i64 %reduce-window.indvar.dim.0, 1
  %14 = add nsw i64 %13, %reduce-window.inner.indvar.window.0
  %15 = sub nsw i64 %14, 0
  %16 = icmp ult i64 %15, 1
  %17 = mul nsw i64 %reduce-window.indvar.dim.1, 3
  %18 = add nsw i64 %17, %reduce-window.inner.indvar.window.1
  %19 = sub nsw i64 %18, 0
  %20 = icmp ult i64 %19, 32
  %21 = and i1 %16, %20
  %22 = mul nsw i64 %reduce-window.indvar.dim.2, 3
  %23 = add nsw i64 %22, %reduce-window.inner.indvar.window.2
  %24 = sub nsw i64 %23, 0
  %25 = icmp ult i64 %24, 32
  %26 = and i1 %21, %25
  %27 = mul nsw i64 %reduce-window.indvar.dim.3, 1
  %28 = add nsw i64 %27, %reduce-window.inner.indvar.window.3
  %29 = sub nsw i64 %28, 0
  %30 = icmp ult i64 %29, 1
  %31 = and i1 %26, %30
  br i1 %31, label %in-bounds-true, label %in-bounds-false

in-bounds-after:                                  ; preds = %in-bounds-false, %in-bounds-true
  %invar.inc7 = add nuw nsw i64 %reduce-window.inner.indvar.window.3, 1
  store i64 %invar.inc7, i64* %reduce-window.inner.invar_address.window.3
  br label %reduce-window.inner.loop_header.window.3, !llvm.loop !5

reduce-window.inner.loop_exit.window.3:           ; preds = %reduce-window.inner.loop_header.window.3
  %invar.inc6 = add nuw nsw i64 %reduce-window.inner.indvar.window.2, 1
  store i64 %invar.inc6, i64* %reduce-window.inner.invar_address.window.2
  br label %reduce-window.inner.loop_header.window.2, !llvm.loop !7

reduce-window.inner.loop_exit.window.2:           ; preds = %reduce-window.inner.loop_header.window.2
  %invar.inc5 = add nuw nsw i64 %reduce-window.inner.indvar.window.1, 1
  store i64 %invar.inc5, i64* %reduce-window.inner.invar_address.window.1
  br label %reduce-window.inner.loop_header.window.1, !llvm.loop !8

reduce-window.inner.loop_exit.window.1:           ; preds = %reduce-window.inner.loop_header.window.1
  %invar.inc4 = add nuw nsw i64 %reduce-window.inner.indvar.window.0, 1
  store i64 %invar.inc4, i64* %reduce-window.inner.invar_address.window.0
  br label %reduce-window.inner.loop_header.window.0, !llvm.loop !9

reduce-window.inner.loop_exit.window.0:           ; preds = %reduce-window.inner.loop_header.window.0
  %32 = load float, float* %reduce_window_accumulator_address
  %33 = getelementptr inbounds [1 x [10 x [10 x [1 x float]]]], [1 x [10 x [10 x [1 x float]]]]* %reduce-window, i64 0, i64 0, i64 %reduce-window.indvar.dim.1, i64 %reduce-window.indvar.dim.2, i64 0
  store float %32, float* %33
  %invar.inc3 = add nuw nsw i64 %reduce-window.indvar.dim.3, 1
  store i64 %invar.inc3, i64* %reduce-window.invar_address.dim.3
  br label %reduce-window.loop_header.dim.3, !llvm.loop !10

reduce-window.loop_exit.dim.3:                    ; preds = %reduce-window.loop_header.dim.3
  %invar.inc2 = add nuw nsw i64 %reduce-window.indvar.dim.2, 1
  store i64 %invar.inc2, i64* %reduce-window.invar_address.dim.2
  br label %reduce-window.loop_header.dim.2, !llvm.loop !11

reduce-window.loop_exit.dim.2:                    ; preds = %reduce-window.loop_header.dim.2
  %invar.inc1 = add nuw nsw i64 %reduce-window.indvar.dim.1, 1
  store i64 %invar.inc1, i64* %reduce-window.invar_address.dim.1
  br label %reduce-window.loop_header.dim.1, !llvm.loop !12

reduce-window.loop_exit.dim.1:                    ; preds = %reduce-window.loop_header.dim.1
  %invar.inc = add nuw nsw i64 %reduce-window.indvar.dim.0, 1
  store i64 %invar.inc, i64* %reduce-window.invar_address.dim.0
  br label %reduce-window.loop_header.dim.0, !llvm.loop !13

reduce-window.loop_exit.dim.0:                    ; preds = %reduce-window.loop_header.dim.0
  %tuple.1 = bitcast i8* %retval to [1 x i8*]*
  %34 = getelementptr inbounds [1 x i8*], [1 x i8*]* %tuple.1, i64 0, i64 0
  %35 = bitcast [1 x [10 x [10 x [1 x float]]]]* %reduce-window to i8*
  store i8* %35, i8** %34
  ret void

in-bounds-true:                                   ; preds = %reduce-window.inner.loop_body.window.3
  %36 = getelementptr inbounds [1 x [32 x [32 x [1 x float]]]], [1 x [32 x [32 x [1 x float]]]]* %1, i64 0, i64 0, i64 %19, i64 %24, i64 0
  %reducer_function_parameter_0_address_as_i8ptr = bitcast float* %reduce_window_accumulator_address to i8*
  %37 = getelementptr inbounds i8*, i8** %reducer_function_parameter_addresses, i64 0
  store i8* %reducer_function_parameter_0_address_as_i8ptr, i8** %37
  %reducer_function_parameter_1_address_as_i8ptr = bitcast float* %36 to i8*
  %38 = getelementptr inbounds i8*, i8** %reducer_function_parameter_addresses, i64 1
  store i8* %reducer_function_parameter_1_address_as_i8ptr, i8** %38
  %39 = bitcast float* %reducer_function_return_value_address to i8*
  call void @max_float_.v3(i8* %39, i8* %run_options, i8** %reducer_function_parameter_addresses, i8** %temps, i64* %prof_counters)
  %reducer_function_return_value = load float, float* %reducer_function_return_value_address
  store float %reducer_function_return_value, float* %reduce_window_accumulator_address
  br label %in-bounds-after

in-bounds-false:                                  ; preds = %reduce-window.inner.loop_body.window.3
  br label %in-bounds-after
}

attributes #0 = { "no-frame-pointer-elim"="false" }

!0 = !{i64 4}
!1 = !{i64 4096}
!2 = !{i64 16}
!3 = !{i64 400}
!4 = !{i64 8}
!5 = distinct !{!5, !6}
!6 = !{!"llvm.loop.vectorize.enable", i1 false}
!7 = distinct !{!7, !6}
!8 = distinct !{!8, !6}
!9 = distinct !{!9, !6}
!10 = distinct !{!10, !6}
!11 = distinct !{!11, !6}
!12 = distinct !{!12, !6}
!13 = distinct !{!13, !6}
