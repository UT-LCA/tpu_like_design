; ModuleID = '04_dense_a.postlto.bc'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux_gnu"

@temp1 = internal global [8 x float] zeroinitializer, align 8
@temp0 = internal unnamed_addr global [1 x [8 x float]] zeroinitializer, align 8
@param2 = internal global float 0.000000e+00, align 8
@param1 = internal global [8 x float] zeroinitializer, align 8
@param0 = internal global [1 x [8 x float]] zeroinitializer, align 8

; Function Attrs: nounwind
define float @main() #0 {
dot.loop_body.rhs.1.lr.ph:
  br label %dot.loop_exit.reduction

dot.loop_exit.reduction:                          ; preds = %dot.loop_exit.reduction, %dot.loop_body.rhs.1.lr.ph
  %dot.indvar.rhs.16 = phi i64 [ 0, %dot.loop_body.rhs.1.lr.ph ], [ %invar.inc1, %dot.loop_exit.reduction ]
  %.phi.trans.insert = getelementptr inbounds [1 x [8 x float]]* @param0, i64 0, i64 0, i64 %dot.indvar.rhs.16
  %.pre = load volatile float* %.phi.trans.insert, align 4
  %.pre10 = load volatile float* @param2, align 8
  %0 = fmul float %.pre10, %.pre
  %1 = fadd float %0, 0.000000e+00
  %2 = getelementptr inbounds [1 x [8 x float]]* @temp0, i64 0, i64 0, i64 %dot.indvar.rhs.16
  store float %1, float* %2, align 4
  %invar.inc1 = add nuw nsw i64 %dot.indvar.rhs.16, 1
  %exitcond1 = icmp eq i64 %invar.inc1, 8
  br i1 %exitcond1, label %fusion.loop_body.dim.0, label %dot.loop_exit.reduction, !llvm.loop !1

fusion.loop_body.dim.0:                           ; preds = %fusion.loop_body.dim.0, %dot.loop_exit.reduction
  %fusion.indvar.dim.02 = phi i64 [ %invar.inc3, %fusion.loop_body.dim.0 ], [ 0, %dot.loop_exit.reduction ]
  %3 = getelementptr inbounds [8 x float]* @param1, i64 0, i64 %fusion.indvar.dim.02
  %4 = load volatile float* %3, align 4
  %5 = getelementptr inbounds [1 x [8 x float]]* @temp0, i64 0, i64 0, i64 %fusion.indvar.dim.02
  %6 = load float* %5, align 4
  %7 = fadd float %4, %6
  %8 = getelementptr inbounds [8 x float]* @temp1, i64 0, i64 %fusion.indvar.dim.02
  store volatile float %7, float* %8, align 4
  %invar.inc3 = add nuw nsw i64 %fusion.indvar.dim.02, 1
  %exitcond = icmp eq i64 %invar.inc3, 8
  br i1 %exitcond, label %fusion.loop_exit.dim.0, label %fusion.loop_body.dim.0, !llvm.loop !3

fusion.loop_exit.dim.0:                           ; preds = %fusion.loop_body.dim.0
  %leflow_retval = load volatile float* getelementptr inbounds ([8 x float]* @temp1, i64 0, i64 0), align 8
  ret float %leflow_retval
}

attributes #0 = { nounwind "no-frame-pointer-elim"="false" }

!llvm.ident = !{!0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0}

!0 = metadata !{metadata !"clang version 3.5.0 (tags/RELEASE_350/final)"}
!1 = metadata !{metadata !1, metadata !2}
!2 = metadata !{metadata !"llvm.loop.vectorize.enable", i1 false}
!3 = metadata !{metadata !3, metadata !2}
