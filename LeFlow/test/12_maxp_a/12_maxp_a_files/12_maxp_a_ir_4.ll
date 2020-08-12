; ModuleID = '12_maxp_a_files/12_maxp_a_ir_4.bc'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux_gnu"

define void @cluster_0__XlaCompiledKernel_true__XlaNumConstantArgs_0__XlaNumResourceArgs_0_.v6(i8* nocapture align 8 dereferenceable(8) %retval, i8* noalias nocapture readnone %run_options, i8** noalias nocapture readonly %params, i8** noalias nocapture readonly %temps, i64* noalias nocapture readnone %prof_counters) #0 {
reduce-window.loop_body.dim.1.lr.ph:
  %arg0.untyped = load i8** %params, align 8, !dereferenceable !0, !align !1
  %0 = bitcast i8* %arg0.untyped to [1 x [8 x [8 x [1 x float]]]]*
  %1 = getelementptr inbounds i8** %temps, i64 1
  %2 = load i8** %1, align 8, !dereferenceable !2, !align !1
  %reduce-window = bitcast i8* %2 to [1 x [2 x [2 x [1 x float]]]]*
  br label %reduce-window.loop_body.dim.2.lr.ph

reduce-window.loop_body.dim.2.lr.ph:              ; preds = %reduce-window.loop_exit.dim.2, %reduce-window.loop_body.dim.1.lr.ph
  %reduce-window.indvar.dim.130 = phi i64 [ 0, %reduce-window.loop_body.dim.1.lr.ph ], [ %invar.inc1, %reduce-window.loop_exit.dim.2 ]
  br label %reduce-window.inner.loop_body.window.1.lr.ph

reduce-window.inner.loop_body.window.1.lr.ph:     ; preds = %reduce-window.loop_exit.dim.3, %reduce-window.loop_body.dim.2.lr.ph
  %reduce-window.indvar.dim.227 = phi i64 [ 0, %reduce-window.loop_body.dim.2.lr.ph ], [ %invar.inc2, %reduce-window.loop_exit.dim.3 ]
  br label %reduce-window.inner.loop_body.window.2.lr.ph

reduce-window.inner.loop_body.window.2.lr.ph:     ; preds = %reduce-window.inner.loop_exit.window.2, %reduce-window.inner.loop_body.window.1.lr.ph
  %3 = phi float [ 0xFFF0000000000000, %reduce-window.inner.loop_body.window.1.lr.ph ], [ %23, %reduce-window.inner.loop_exit.window.2 ]
  %4 = phi float [ 0xFFF0000000000000, %reduce-window.inner.loop_body.window.1.lr.ph ], [ %24, %reduce-window.inner.loop_exit.window.2 ]
  %reduce-window.inner.indvar.window.119 = phi i64 [ 0, %reduce-window.inner.loop_body.window.1.lr.ph ], [ %invar.inc5, %reduce-window.inner.loop_exit.window.2 ]
  %5 = mul nsw i64 %reduce-window.indvar.dim.130, 3
  %6 = add nsw i64 %reduce-window.inner.indvar.window.119, %5
  %7 = icmp ult i64 %6, 8
  br i1 %7, label %reduce-window.inner.loop_body.window.3.lr.ph.us, label %reduce-window.inner.loop_exit.window.3

reduce-window.inner.loop_exit.window.3.us:        ; preds = %reduce-window.inner.loop_header.window.3.reduce-window.inner.loop_exit.window.3_crit_edge.us-lcssa.us.us, %reduce-window.inner.loop_body.window.3.lr.ph.us
  %8 = phi float [ %21, %reduce-window.inner.loop_header.window.3.reduce-window.inner.loop_exit.window.3_crit_edge.us-lcssa.us.us ], [ %11, %reduce-window.inner.loop_body.window.3.lr.ph.us ]
  %9 = phi float [ %21, %reduce-window.inner.loop_header.window.3.reduce-window.inner.loop_exit.window.3_crit_edge.us-lcssa.us.us ], [ %12, %reduce-window.inner.loop_body.window.3.lr.ph.us ]
  %invar.inc6.us = add nuw nsw i64 %reduce-window.inner.indvar.window.24.us, 1
  %10 = icmp ugt i64 %invar.inc6.us, 2
  br i1 %10, label %reduce-window.inner.loop_exit.window.2, label %reduce-window.inner.loop_body.window.3.lr.ph.us, !llvm.loop !3

reduce-window.inner.loop_body.window.3.lr.ph.us:  ; preds = %reduce-window.inner.loop_exit.window.3.us, %reduce-window.inner.loop_body.window.2.lr.ph
  %11 = phi float [ %8, %reduce-window.inner.loop_exit.window.3.us ], [ %3, %reduce-window.inner.loop_body.window.2.lr.ph ]
  %12 = phi float [ %9, %reduce-window.inner.loop_exit.window.3.us ], [ %4, %reduce-window.inner.loop_body.window.2.lr.ph ]
  %reduce-window.inner.indvar.window.24.us = phi i64 [ %invar.inc6.us, %reduce-window.inner.loop_exit.window.3.us ], [ 0, %reduce-window.inner.loop_body.window.2.lr.ph ]
  %13 = mul nsw i64 %reduce-window.indvar.dim.227, 3
  %14 = add nsw i64 %reduce-window.inner.indvar.window.24.us, %13
  %15 = icmp ult i64 %14, 8
  br i1 %15, label %reduce-window.inner.loop_header.window.3.reduce-window.inner.loop_exit.window.3_crit_edge.us-lcssa.us.us, label %reduce-window.inner.loop_exit.window.3.us

reduce-window.inner.loop_header.window.3.reduce-window.inner.loop_exit.window.3_crit_edge.us-lcssa.us.us: ; preds = %reduce-window.inner.loop_body.window.3.lr.ph.us
  %16 = getelementptr inbounds [1 x [8 x [8 x [1 x float]]]]* %0, i64 0, i64 0, i64 %6, i64 %14, i64 0
  %17 = load float* %16, align 4
  %18 = fcmp oge float %11, %17
  %19 = fcmp uno float %11, 0.000000e+00
  %20 = or i1 %18, %19
  %21 = select i1 %20, float %11, float %17
  br label %reduce-window.inner.loop_exit.window.3.us

reduce-window.inner.loop_exit.window.3:           ; preds = %reduce-window.inner.loop_exit.window.3, %reduce-window.inner.loop_body.window.2.lr.ph
  %reduce-window.inner.indvar.window.24 = phi i64 [ %invar.inc6, %reduce-window.inner.loop_exit.window.3 ], [ 0, %reduce-window.inner.loop_body.window.2.lr.ph ]
  %invar.inc6 = add nuw nsw i64 %reduce-window.inner.indvar.window.24, 1
  %22 = icmp ugt i64 %invar.inc6, 2
  br i1 %22, label %reduce-window.inner.loop_exit.window.2, label %reduce-window.inner.loop_exit.window.3, !llvm.loop !3

reduce-window.inner.loop_exit.window.2:           ; preds = %reduce-window.inner.loop_exit.window.3, %reduce-window.inner.loop_exit.window.3.us
  %23 = phi float [ %8, %reduce-window.inner.loop_exit.window.3.us ], [ %3, %reduce-window.inner.loop_exit.window.3 ]
  %24 = phi float [ %9, %reduce-window.inner.loop_exit.window.3.us ], [ %4, %reduce-window.inner.loop_exit.window.3 ]
  %invar.inc5 = add nuw nsw i64 %reduce-window.inner.indvar.window.119, 1
  %25 = icmp ugt i64 %invar.inc5, 2
  br i1 %25, label %reduce-window.loop_exit.dim.3, label %reduce-window.inner.loop_body.window.2.lr.ph, !llvm.loop !5

reduce-window.loop_exit.dim.3:                    ; preds = %reduce-window.inner.loop_exit.window.2
  %26 = getelementptr inbounds [1 x [2 x [2 x [1 x float]]]]* %reduce-window, i64 0, i64 0, i64 %reduce-window.indvar.dim.130, i64 %reduce-window.indvar.dim.227, i64 0
  store float %24, float* %26, align 4
  %invar.inc2 = add nuw nsw i64 %reduce-window.indvar.dim.227, 1
  %27 = icmp eq i64 %reduce-window.indvar.dim.227, 0
  br i1 %27, label %reduce-window.inner.loop_body.window.1.lr.ph, label %reduce-window.loop_exit.dim.2, !llvm.loop !6

reduce-window.loop_exit.dim.2:                    ; preds = %reduce-window.loop_exit.dim.3
  %invar.inc1 = add nuw nsw i64 %reduce-window.indvar.dim.130, 1
  %28 = icmp eq i64 %reduce-window.indvar.dim.130, 0
  br i1 %28, label %reduce-window.loop_body.dim.2.lr.ph, label %reduce-window.loop_exit.dim.0, !llvm.loop !7

reduce-window.loop_exit.dim.0:                    ; preds = %reduce-window.loop_exit.dim.2
  %29 = bitcast i8* %retval to i8**
  store i8* %2, i8** %29, align 8
  ret void
}

attributes #0 = { "no-frame-pointer-elim"="false" }

!0 = metadata !{i64 256}
!1 = metadata !{i64 8}
!2 = metadata !{i64 16}
!3 = metadata !{metadata !3, metadata !4}
!4 = metadata !{metadata !"llvm.loop.vectorize.enable", i1 false}
!5 = metadata !{metadata !5, metadata !4}
!6 = metadata !{metadata !6, metadata !4}
!7 = metadata !{metadata !7, metadata !4}
