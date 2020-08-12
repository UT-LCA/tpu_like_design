; ModuleID = '04_dense_a.prelto.linked.bc'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux_gnu"

@temp1 = global [8 x float] zeroinitializer, align 8
@temp0 = global [1 x [8 x float]] zeroinitializer, align 8
@param2 = global float 0.000000e+00, align 8
@param1 = global [8 x float] zeroinitializer, align 8
@param0 = global [1 x [8 x float]] zeroinitializer, align 8

define float @main() #0 {
dot.loop_body.rhs.1.lr.ph:
  br label %dot.loop_exit.reduction

dot.loop_exit.reduction:                          ; preds = %dot.loop_exit.reduction, %dot.loop_body.rhs.1.lr.ph
  %dot.indvar.rhs.16 = phi i64 [ 0, %dot.loop_body.rhs.1.lr.ph ], [ %invar.inc1, %dot.loop_exit.reduction ]
  %.phi.trans.insert = getelementptr inbounds [1 x [8 x float]]* @param0, i64 0, i64 0, i64 %dot.indvar.rhs.16
  %.pre = load volatile float* %.phi.trans.insert, align 4
  %.pre10 = load volatile float* @param2, align 4
  %0 = fmul float %.pre10, %.pre
  %1 = fadd float %0, 0.000000e+00
  %2 = getelementptr inbounds [1 x [8 x float]]* @temp0, i64 0, i64 0, i64 %dot.indvar.rhs.16
  store float %1, float* %2, align 4
  %invar.inc1 = add nuw nsw i64 %dot.indvar.rhs.16, 1
  %3 = icmp ugt i64 %invar.inc1, 7
  br i1 %3, label %fusion.loop_body.dim.0.lr.ph, label %dot.loop_exit.reduction, !llvm.loop !0

fusion.loop_body.dim.0.lr.ph:                     ; preds = %dot.loop_exit.reduction
  br label %fusion.loop_body.dim.0

fusion.loop_body.dim.0:                           ; preds = %fusion.loop_body.dim.0, %fusion.loop_body.dim.0.lr.ph
  %fusion.indvar.dim.02 = phi i64 [ 0, %fusion.loop_body.dim.0.lr.ph ], [ %invar.inc3, %fusion.loop_body.dim.0 ]
  %4 = getelementptr inbounds [8 x float]* @param1, i64 0, i64 %fusion.indvar.dim.02
  %5 = load volatile float* %4, align 4
  %6 = getelementptr inbounds [1 x [8 x float]]* @temp0, i64 0, i64 0, i64 %fusion.indvar.dim.02
  %7 = load float* %6, align 4
  %8 = fadd float %5, %7
  %9 = getelementptr inbounds [8 x float]* @temp1, i64 0, i64 %fusion.indvar.dim.02
  store volatile float %8, float* %9, align 4
  %invar.inc3 = add nuw nsw i64 %fusion.indvar.dim.02, 1
  %10 = icmp ugt i64 %invar.inc3, 7
  br i1 %10, label %fusion.loop_exit.dim.0, label %fusion.loop_body.dim.0, !llvm.loop !2

fusion.loop_exit.dim.0:                           ; preds = %fusion.loop_body.dim.0
  %leflow_gep = getelementptr inbounds [8 x float]* @temp1, i64 0, i64 0
  %leflow_retval = load volatile float* %leflow_gep, align 4
  ret float %leflow_retval
}

attributes #0 = { "no-frame-pointer-elim"="false" }

!0 = metadata !{metadata !0, metadata !1}
!1 = metadata !{metadata !"llvm.loop.vectorize.enable", i1 false}
!2 = metadata !{metadata !2, metadata !1}
