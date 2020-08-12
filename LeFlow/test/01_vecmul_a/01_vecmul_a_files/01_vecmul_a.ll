; ModuleID = '01_vecmul_a.bc'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux_gnu"

@temp0 = internal global [8 x float] zeroinitializer, align 8
@param1 = internal global [8 x float] zeroinitializer, align 8
@param0 = internal global [8 x float] zeroinitializer, align 8

; Function Attrs: nounwind
define float @main() #0 {
multiply.loop_body.dim.0.lr.ph:
  br label %multiply.loop_body.dim.0

multiply.loop_body.dim.0:                         ; preds = %multiply.loop_body.dim.0, %multiply.loop_body.dim.0.lr.ph
  %multiply.indvar.dim.02 = phi i64 [ 0, %multiply.loop_body.dim.0.lr.ph ], [ %3, %multiply.loop_body.dim.0 ]
  %scevgep = getelementptr [8 x float]* @temp0, i64 0, i64 %multiply.indvar.dim.02
  %scevgep2 = getelementptr [8 x float]* @param0, i64 0, i64 %multiply.indvar.dim.02
  %scevgep3 = getelementptr [8 x float]* @param1, i64 0, i64 %multiply.indvar.dim.02
  %0 = load volatile float* %scevgep3, align 4
  %1 = load volatile float* %scevgep2, align 4
  %2 = fmul float %0, %1
  store volatile float %2, float* %scevgep, align 4
  %3 = add nuw nsw i64 %multiply.indvar.dim.02, 1
  %exitcond1 = icmp eq i64 %3, 8
  br i1 %exitcond1, label %multiply.loop_exit.dim.0, label %multiply.loop_body.dim.0, !llvm.loop !1

multiply.loop_exit.dim.0:                         ; preds = %multiply.loop_body.dim.0
  %leflow_retval = load volatile float* getelementptr inbounds ([8 x float]* @temp0, i64 0, i64 0), align 8
  ret float %leflow_retval
}

attributes #0 = { nounwind "no-frame-pointer-elim"="false" }

!llvm.ident = !{!0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0}

!0 = metadata !{metadata !"clang version 3.5.0 (tags/RELEASE_350/final)"}
!1 = metadata !{metadata !1, metadata !2}
!2 = metadata !{metadata !"llvm.loop.vectorize.enable", i1 false}
