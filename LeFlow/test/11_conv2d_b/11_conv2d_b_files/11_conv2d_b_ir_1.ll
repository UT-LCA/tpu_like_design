; ModuleID = '__compute_module'
source_filename = "__compute_module"
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux_gnu"

define void @cluster_0__XlaCompiledKernel_true__XlaNumConstantArgs_0__XlaNumResourceArgs_0_.v6(i8* align 8 dereferenceable(8) %retval, i8* noalias %run_options, i8** noalias %params, i8** noalias %temps, i64* noalias %prof_counters) #0 {
entry:
  %convolution.inner.invar_address.iz = alloca i64
  %convolution.inner.invar_address.k1 = alloca i64
  %convolution.inner.invar_address.k0 = alloca i64
  %convolution_sum_address = alloca float, align 4
  %convolution.invar_address.dim.3 = alloca i64
  %convolution.invar_address.dim.2 = alloca i64
  %convolution.invar_address.dim.1 = alloca i64
  %convolution.invar_address.dim.0 = alloca i64
  %0 = getelementptr inbounds i8*, i8** %params, i64 0
  %arg0.untyped = load i8*, i8** %0, !dereferenceable !0, !align !1
  %1 = bitcast i8* %arg0.untyped to [1 x [64 x [64 x [1 x float]]]]*
  %2 = getelementptr inbounds i8*, i8** %params, i64 1
  %arg1.untyped = load i8*, i8** %2, !dereferenceable !2, !align !3
  %3 = bitcast i8* %arg1.untyped to [3 x [3 x [1 x [2 x float]]]]*
  %4 = getelementptr inbounds i8*, i8** %temps, i64 0
  %5 = load i8*, i8** %4, !dereferenceable !4, !align !1
  %convolution = bitcast i8* %5 to [1 x [64 x [64 x [2 x float]]]]*
  store i64 0, i64* %convolution.invar_address.dim.0
  br label %convolution.loop_header.dim.0

convolution.loop_header.dim.0:                    ; preds = %convolution.loop_exit.dim.1, %entry
  %convolution.indvar.dim.0 = load i64, i64* %convolution.invar_address.dim.0
  %6 = icmp uge i64 %convolution.indvar.dim.0, 1
  br i1 %6, label %convolution.loop_exit.dim.0, label %convolution.loop_body.dim.0

convolution.loop_body.dim.0:                      ; preds = %convolution.loop_header.dim.0
  store i64 0, i64* %convolution.invar_address.dim.1
  br label %convolution.loop_header.dim.1

convolution.loop_header.dim.1:                    ; preds = %convolution.loop_exit.dim.2, %convolution.loop_body.dim.0
  %convolution.indvar.dim.1 = load i64, i64* %convolution.invar_address.dim.1
  %7 = icmp uge i64 %convolution.indvar.dim.1, 64
  br i1 %7, label %convolution.loop_exit.dim.1, label %convolution.loop_body.dim.1

convolution.loop_body.dim.1:                      ; preds = %convolution.loop_header.dim.1
  store i64 0, i64* %convolution.invar_address.dim.2
  br label %convolution.loop_header.dim.2

convolution.loop_header.dim.2:                    ; preds = %convolution.loop_exit.dim.3, %convolution.loop_body.dim.1
  %convolution.indvar.dim.2 = load i64, i64* %convolution.invar_address.dim.2
  %8 = icmp uge i64 %convolution.indvar.dim.2, 64
  br i1 %8, label %convolution.loop_exit.dim.2, label %convolution.loop_body.dim.2

convolution.loop_body.dim.2:                      ; preds = %convolution.loop_header.dim.2
  store i64 0, i64* %convolution.invar_address.dim.3
  br label %convolution.loop_header.dim.3

convolution.loop_header.dim.3:                    ; preds = %convolution.inner.loop_exit.k0, %convolution.loop_body.dim.2
  %convolution.indvar.dim.3 = load i64, i64* %convolution.invar_address.dim.3
  %9 = icmp uge i64 %convolution.indvar.dim.3, 2
  br i1 %9, label %convolution.loop_exit.dim.3, label %convolution.loop_body.dim.3

convolution.loop_body.dim.3:                      ; preds = %convolution.loop_header.dim.3
  store float 0.000000e+00, float* %convolution_sum_address
  store i64 0, i64* %convolution.inner.invar_address.k0
  br label %convolution.inner.loop_header.k0

convolution.inner.loop_header.k0:                 ; preds = %convolution.inner.loop_exit.k1, %convolution.loop_body.dim.3
  %convolution.inner.indvar.k0 = load i64, i64* %convolution.inner.invar_address.k0
  %10 = icmp uge i64 %convolution.inner.indvar.k0, 3
  br i1 %10, label %convolution.inner.loop_exit.k0, label %convolution.inner.loop_body.k0

convolution.inner.loop_body.k0:                   ; preds = %convolution.inner.loop_header.k0
  store i64 0, i64* %convolution.inner.invar_address.k1
  br label %convolution.inner.loop_header.k1

convolution.inner.loop_header.k1:                 ; preds = %convolution.inner.loop_exit.iz, %convolution.inner.loop_body.k0
  %convolution.inner.indvar.k1 = load i64, i64* %convolution.inner.invar_address.k1
  %11 = icmp uge i64 %convolution.inner.indvar.k1, 3
  br i1 %11, label %convolution.inner.loop_exit.k1, label %convolution.inner.loop_body.k1

convolution.inner.loop_body.k1:                   ; preds = %convolution.inner.loop_header.k1
  store i64 0, i64* %convolution.inner.invar_address.iz
  br label %convolution.inner.loop_header.iz

convolution.inner.loop_header.iz:                 ; preds = %in-bounds-after, %convolution.inner.loop_body.k1
  %convolution.inner.indvar.iz = load i64, i64* %convolution.inner.invar_address.iz
  %12 = icmp uge i64 %convolution.inner.indvar.iz, 1
  br i1 %12, label %convolution.inner.loop_exit.iz, label %convolution.inner.loop_body.iz

convolution.inner.loop_body.iz:                   ; preds = %convolution.inner.loop_header.iz
  %13 = mul nsw i64 %convolution.indvar.dim.1, 1
  %14 = mul nsw i64 %convolution.inner.indvar.k0, 1
  %15 = add nsw i64 %13, %14
  %16 = sub nsw i64 %15, 1
  %17 = mul nsw i64 %convolution.indvar.dim.2, 1
  %18 = mul nsw i64 %convolution.inner.indvar.k1, 1
  %19 = add nsw i64 %17, %18
  %20 = sub nsw i64 %19, 1
  %21 = icmp ult i64 %16, 64
  %22 = srem i64 %16, 1
  %23 = icmp eq i64 %22, 0
  %24 = and i1 %21, %23
  %25 = and i1 true, %24
  %26 = icmp ult i64 %20, 64
  %27 = srem i64 %20, 1
  %28 = icmp eq i64 %27, 0
  %29 = and i1 %26, %28
  %30 = and i1 %25, %29
  %31 = sdiv i64 %16, 1
  %32 = sdiv i64 %20, 1
  br i1 %30, label %in-bounds-true, label %in-bounds-false

in-bounds-after:                                  ; preds = %in-bounds-false, %in-bounds-true
  %invar.inc6 = add nuw nsw i64 %convolution.inner.indvar.iz, 1
  store i64 %invar.inc6, i64* %convolution.inner.invar_address.iz
  br label %convolution.inner.loop_header.iz, !llvm.loop !5

convolution.inner.loop_exit.iz:                   ; preds = %convolution.inner.loop_header.iz
  %invar.inc5 = add nuw nsw i64 %convolution.inner.indvar.k1, 1
  store i64 %invar.inc5, i64* %convolution.inner.invar_address.k1
  br label %convolution.inner.loop_header.k1, !llvm.loop !7

convolution.inner.loop_exit.k1:                   ; preds = %convolution.inner.loop_header.k1
  %invar.inc4 = add nuw nsw i64 %convolution.inner.indvar.k0, 1
  store i64 %invar.inc4, i64* %convolution.inner.invar_address.k0
  br label %convolution.inner.loop_header.k0, !llvm.loop !8

convolution.inner.loop_exit.k0:                   ; preds = %convolution.inner.loop_header.k0
  %33 = load float, float* %convolution_sum_address
  %34 = getelementptr inbounds [1 x [64 x [64 x [2 x float]]]], [1 x [64 x [64 x [2 x float]]]]* %convolution, i64 0, i64 0, i64 %convolution.indvar.dim.1, i64 %convolution.indvar.dim.2, i64 %convolution.indvar.dim.3
  store float %33, float* %34
  %invar.inc3 = add nuw nsw i64 %convolution.indvar.dim.3, 1
  store i64 %invar.inc3, i64* %convolution.invar_address.dim.3
  br label %convolution.loop_header.dim.3, !llvm.loop !9

convolution.loop_exit.dim.3:                      ; preds = %convolution.loop_header.dim.3
  %invar.inc2 = add nuw nsw i64 %convolution.indvar.dim.2, 1
  store i64 %invar.inc2, i64* %convolution.invar_address.dim.2
  br label %convolution.loop_header.dim.2, !llvm.loop !10

convolution.loop_exit.dim.2:                      ; preds = %convolution.loop_header.dim.2
  %invar.inc1 = add nuw nsw i64 %convolution.indvar.dim.1, 1
  store i64 %invar.inc1, i64* %convolution.invar_address.dim.1
  br label %convolution.loop_header.dim.1, !llvm.loop !11

convolution.loop_exit.dim.1:                      ; preds = %convolution.loop_header.dim.1
  %invar.inc = add nuw nsw i64 %convolution.indvar.dim.0, 1
  store i64 %invar.inc, i64* %convolution.invar_address.dim.0
  br label %convolution.loop_header.dim.0, !llvm.loop !12

convolution.loop_exit.dim.0:                      ; preds = %convolution.loop_header.dim.0
  %tuple.1 = bitcast i8* %retval to [1 x i8*]*
  %35 = getelementptr inbounds [1 x i8*], [1 x i8*]* %tuple.1, i64 0, i64 0
  %36 = bitcast [1 x [64 x [64 x [2 x float]]]]* %convolution to i8*
  store i8* %36, i8** %35
  ret void

in-bounds-true:                                   ; preds = %convolution.inner.loop_body.iz
  %37 = getelementptr inbounds [3 x [3 x [1 x [2 x float]]]], [3 x [3 x [1 x [2 x float]]]]* %3, i64 0, i64 %convolution.inner.indvar.k0, i64 %convolution.inner.indvar.k1, i64 0, i64 %convolution.indvar.dim.3
  %38 = load float, float* %37
  %39 = getelementptr inbounds [1 x [64 x [64 x [1 x float]]]], [1 x [64 x [64 x [1 x float]]]]* %1, i64 0, i64 0, i64 %31, i64 %32, i64 0
  %40 = load float, float* %39
  %41 = fmul float %40, %38
  %42 = load float, float* %convolution_sum_address
  %43 = fadd float %42, %41
  store float %43, float* %convolution_sum_address
  br label %in-bounds-after

in-bounds-false:                                  ; preds = %convolution.inner.loop_body.iz
  br label %in-bounds-after
}

attributes #0 = { "no-frame-pointer-elim"="false" }

!0 = !{i64 16384}
!1 = !{i64 16}
!2 = !{i64 72}
!3 = !{i64 8}
!4 = !{i64 32768}
!5 = distinct !{!5, !6}
!6 = !{!"llvm.loop.vectorize.enable", i1 false}
!7 = distinct !{!7, !6}
!8 = distinct !{!8, !6}
!9 = distinct !{!9, !6}
!10 = distinct !{!10, !6}
!11 = distinct !{!11, !6}
!12 = distinct !{!12, !6}
