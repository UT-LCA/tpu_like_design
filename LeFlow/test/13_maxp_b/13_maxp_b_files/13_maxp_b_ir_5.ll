; ModuleID = '13_maxp_b_files/13_maxp_b_ir_4.bc'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux_gnu"

@temp0 = global [1 x [10 x [10 x [1 x float]]]] zeroinitializer, align 8
@param0 = global [1 x [32 x [32 x [1 x float]]]] zeroinitializer, align 8

define float @main() #0 {
reduce-window.loop_body.dim.1.lr.ph:
  br label %reduce-window.loop_body.dim.2.lr.ph

reduce-window.loop_body.dim.2.lr.ph:              ; preds = %reduce-window.loop_exit.dim.2, %reduce-window.loop_body.dim.1.lr.ph
  %reduce-window.indvar.dim.130 = phi i64 [ 0, %reduce-window.loop_body.dim.1.lr.ph ], [ %invar.inc1, %reduce-window.loop_exit.dim.2 ]
  br label %reduce-window.inner.loop_body.window.1.lr.ph

reduce-window.inner.loop_body.window.1.lr.ph:     ; preds = %reduce-window.loop_exit.dim.3, %reduce-window.loop_body.dim.2.lr.ph
  %reduce-window.indvar.dim.227 = phi i64 [ 0, %reduce-window.loop_body.dim.2.lr.ph ], [ %invar.inc2, %reduce-window.loop_exit.dim.3 ]
  br label %reduce-window.inner.loop_body.window.2.lr.ph

reduce-window.inner.loop_body.window.2.lr.ph:     ; preds = %reduce-window.inner.loop_exit.window.2, %reduce-window.inner.loop_body.window.1.lr.ph
  %0 = phi float [ 0xFFF0000000000000, %reduce-window.inner.loop_body.window.1.lr.ph ], [ %20, %reduce-window.inner.loop_exit.window.2 ]
  %1 = phi float [ 0xFFF0000000000000, %reduce-window.inner.loop_body.window.1.lr.ph ], [ %21, %reduce-window.inner.loop_exit.window.2 ]
  %reduce-window.inner.indvar.window.119 = phi i64 [ 0, %reduce-window.inner.loop_body.window.1.lr.ph ], [ %invar.inc5, %reduce-window.inner.loop_exit.window.2 ]
  %2 = mul nsw i64 %reduce-window.indvar.dim.130, 3
  %3 = add nsw i64 %reduce-window.inner.indvar.window.119, %2
  %4 = icmp ult i64 %3, 32
  br i1 %4, label %reduce-window.inner.loop_body.window.3.lr.ph.us, label %reduce-window.inner.loop_exit.window.3

reduce-window.inner.loop_exit.window.3.us:        ; preds = %reduce-window.inner.loop_header.window.3.reduce-window.inner.loop_exit.window.3_crit_edge.us-lcssa.us.us, %reduce-window.inner.loop_body.window.3.lr.ph.us
  %5 = phi float [ %18, %reduce-window.inner.loop_header.window.3.reduce-window.inner.loop_exit.window.3_crit_edge.us-lcssa.us.us ], [ %8, %reduce-window.inner.loop_body.window.3.lr.ph.us ]
  %6 = phi float [ %18, %reduce-window.inner.loop_header.window.3.reduce-window.inner.loop_exit.window.3_crit_edge.us-lcssa.us.us ], [ %9, %reduce-window.inner.loop_body.window.3.lr.ph.us ]
  %invar.inc6.us = add nuw nsw i64 %reduce-window.inner.indvar.window.24.us, 1
  %7 = icmp ugt i64 %invar.inc6.us, 2
  br i1 %7, label %reduce-window.inner.loop_exit.window.2, label %reduce-window.inner.loop_body.window.3.lr.ph.us, !llvm.loop !4

reduce-window.inner.loop_body.window.3.lr.ph.us:  ; preds = %reduce-window.inner.loop_exit.window.3.us, %reduce-window.inner.loop_body.window.2.lr.ph
  %8 = phi float [ %5, %reduce-window.inner.loop_exit.window.3.us ], [ %0, %reduce-window.inner.loop_body.window.2.lr.ph ]
  %9 = phi float [ %6, %reduce-window.inner.loop_exit.window.3.us ], [ %1, %reduce-window.inner.loop_body.window.2.lr.ph ]
  %reduce-window.inner.indvar.window.24.us = phi i64 [ %invar.inc6.us, %reduce-window.inner.loop_exit.window.3.us ], [ 0, %reduce-window.inner.loop_body.window.2.lr.ph ]
  %10 = mul nsw i64 %reduce-window.indvar.dim.227, 3
  %11 = add nsw i64 %reduce-window.inner.indvar.window.24.us, %10
  %12 = icmp ult i64 %11, 32
  br i1 %12, label %reduce-window.inner.loop_header.window.3.reduce-window.inner.loop_exit.window.3_crit_edge.us-lcssa.us.us, label %reduce-window.inner.loop_exit.window.3.us

reduce-window.inner.loop_header.window.3.reduce-window.inner.loop_exit.window.3_crit_edge.us-lcssa.us.us: ; preds = %reduce-window.inner.loop_body.window.3.lr.ph.us
  %13 = getelementptr inbounds [1 x [32 x [32 x [1 x float]]]]* @param0, i64 0, i64 0, i64 %3, i64 %11, i64 0
  %14 = load volatile float* %13, align 4
  %15 = fcmp oge float %8, %14
  %16 = fcmp uno float %8, 0.000000e+00
  %17 = or i1 %15, %16
  %18 = select i1 %17, float %8, float %14
  br label %reduce-window.inner.loop_exit.window.3.us

reduce-window.inner.loop_exit.window.3:           ; preds = %reduce-window.inner.loop_exit.window.3, %reduce-window.inner.loop_body.window.2.lr.ph
  %reduce-window.inner.indvar.window.24 = phi i64 [ %invar.inc6, %reduce-window.inner.loop_exit.window.3 ], [ 0, %reduce-window.inner.loop_body.window.2.lr.ph ]
  %invar.inc6 = add nuw nsw i64 %reduce-window.inner.indvar.window.24, 1
  %19 = icmp ugt i64 %invar.inc6, 2
  br i1 %19, label %reduce-window.inner.loop_exit.window.2, label %reduce-window.inner.loop_exit.window.3, !llvm.loop !4

reduce-window.inner.loop_exit.window.2:           ; preds = %reduce-window.inner.loop_exit.window.3, %reduce-window.inner.loop_exit.window.3.us
  %20 = phi float [ %5, %reduce-window.inner.loop_exit.window.3.us ], [ %0, %reduce-window.inner.loop_exit.window.3 ]
  %21 = phi float [ %6, %reduce-window.inner.loop_exit.window.3.us ], [ %1, %reduce-window.inner.loop_exit.window.3 ]
  %invar.inc5 = add nuw nsw i64 %reduce-window.inner.indvar.window.119, 1
  %22 = icmp ugt i64 %invar.inc5, 2
  br i1 %22, label %reduce-window.loop_exit.dim.3, label %reduce-window.inner.loop_body.window.2.lr.ph, !llvm.loop !6

reduce-window.loop_exit.dim.3:                    ; preds = %reduce-window.inner.loop_exit.window.2
  %23 = getelementptr inbounds [1 x [10 x [10 x [1 x float]]]]* @temp0, i64 0, i64 0, i64 %reduce-window.indvar.dim.130, i64 %reduce-window.indvar.dim.227, i64 0
  store volatile float %21, float* %23, align 4
  %invar.inc2 = add nuw nsw i64 %reduce-window.indvar.dim.227, 1
  %24 = icmp ugt i64 %invar.inc2, 9
  br i1 %24, label %reduce-window.loop_exit.dim.2, label %reduce-window.inner.loop_body.window.1.lr.ph, !llvm.loop !7

reduce-window.loop_exit.dim.2:                    ; preds = %reduce-window.loop_exit.dim.3
  %invar.inc1 = add nuw nsw i64 %reduce-window.indvar.dim.130, 1
  %25 = icmp ugt i64 %invar.inc1, 9
  br i1 %25, label %reduce-window.loop_exit.dim.0, label %reduce-window.loop_body.dim.2.lr.ph, !llvm.loop !8

reduce-window.loop_exit.dim.0:                    ; preds = %reduce-window.loop_exit.dim.2
  %leflow_gep = getelementptr inbounds [1 x [10 x [10 x [1 x float]]]]* @temp0, i64 0, i64 0, i64 0, i64 0, i64 0
  %leflow_retval = load volatile float* %leflow_gep, align 4
  ret float %leflow_retval
}

attributes #0 = { "no-frame-pointer-elim"="false" }

!0 = metadata !{i64 4096}
!1 = metadata !{i64 16}
!2 = metadata !{i64 400}
!3 = metadata !{i64 8}
!4 = metadata !{metadata !4, metadata !5}
!5 = metadata !{metadata !"llvm.loop.vectorize.enable", i1 false}
!6 = metadata !{metadata !6, metadata !5}
!7 = metadata !{metadata !7, metadata !5}
!8 = metadata !{metadata !8, metadata !5}
