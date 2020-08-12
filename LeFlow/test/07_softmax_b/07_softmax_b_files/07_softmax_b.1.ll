; ModuleID = '07_softmax_b.1.bc'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux_gnu"

@temp3 = internal global [64 x float] zeroinitializer, align 8
@temp1 = internal unnamed_addr global [1 x [64 x float]] zeroinitializer, align 8
@param0 = internal global [1 x [64 x float]] zeroinitializer, align 8
@ln2HI31 = internal unnamed_addr constant [2 x float] [float 0x3FE62E3000000000, float 0xBFE62E3000000000], align 4
@ln2LO32 = internal unnamed_addr constant [2 x float] [float 0x3EE2FEFA20000000, float 0xBEE2FEFA20000000], align 4
@halF33 = internal unnamed_addr constant [2 x float] [float 5.000000e-01, float -5.000000e-01], align 4

; Function Attrs: nounwind
define float @main() #0 {
reduce.inner.loop_body.reduction_dim.1.lr.ph:
  br label %reduce.inner.loop_body.reduction_dim.1

reduce.inner.loop_body.reduction_dim.1:           ; preds = %reduce.inner.loop_body.reduction_dim.1, %reduce.inner.loop_body.reduction_dim.1.lr.ph
  %0 = phi float [ 0xFFF0000000000000, %reduce.inner.loop_body.reduction_dim.1.lr.ph ], [ %5, %reduce.inner.loop_body.reduction_dim.1 ]
  %reduce.inner.indvar.reduction_dim.112 = phi i64 [ 0, %reduce.inner.loop_body.reduction_dim.1.lr.ph ], [ %6, %reduce.inner.loop_body.reduction_dim.1 ]
  %scevgep10 = getelementptr [1 x [64 x float]]* @param0, i64 0, i64 0, i64 %reduce.inner.indvar.reduction_dim.112
  %1 = load volatile float* %scevgep10, align 4
  %2 = fcmp oge float %0, %1
  %3 = fcmp ueq float %0, 0.000000e+00
  %4 = or i1 %2, %3
  %5 = select i1 %4, float %0, float %1
  %6 = add nuw nsw i64 %reduce.inner.indvar.reduction_dim.112, 1
  %exitcond9 = icmp eq i64 %6, 64
  br i1 %exitcond9, label %fusion.1.loop_body.dim.1.preheader, label %reduce.inner.loop_body.reduction_dim.1, !llvm.loop !1

fusion.1.loop_body.dim.1.preheader:               ; preds = %reduce.inner.loop_body.reduction_dim.1
  %.lcssa50 = phi float [ %5, %reduce.inner.loop_body.reduction_dim.1 ]
  br label %fusion.1.loop_body.dim.1

fusion.1.loop_body.dim.1:                         ; preds = %expf.exit, %fusion.1.loop_body.dim.1.preheader
  %lo.i.i.0 = phi float [ %lo.i.i.3, %expf.exit ], [ undef, %fusion.1.loop_body.dim.1.preheader ]
  %hi.i.i.0 = phi float [ %hi.i.i.3, %expf.exit ], [ undef, %fusion.1.loop_body.dim.1.preheader ]
  %fusion.1.indvar.dim.18 = phi i64 [ %91, %expf.exit ], [ 0, %fusion.1.loop_body.dim.1.preheader ]
  %scevgep7 = getelementptr [1 x [64 x float]]* @temp1, i64 0, i64 0, i64 %fusion.1.indvar.dim.18
  %scevgep8 = getelementptr [1 x [64 x float]]* @param0, i64 0, i64 0, i64 %fusion.1.indvar.dim.18
  %7 = load volatile float* %scevgep8, align 4
  %8 = fsub float %7, %.lcssa50
  %9 = bitcast float %8 to i32
  %10 = lshr i32 %9, 31
  %11 = and i32 %9, 2147483647
  %12 = icmp ugt i32 %11, 2139095040
  br i1 %12, label %13, label %15

; <label>:13                                      ; preds = %fusion.1.loop_body.dim.1
  %14 = fadd float %8, %8
  br label %expf.exit

; <label>:15                                      ; preds = %fusion.1.loop_body.dim.1
  %16 = icmp eq i32 %11, 2139095040
  br i1 %16, label %17, label %19

; <label>:17                                      ; preds = %15
  %18 = icmp eq i32 %10, 0
  %. = select i1 %18, float %8, float 0.000000e+00
  br label %expf.exit

; <label>:19                                      ; preds = %15
  %20 = icmp sgt i32 %9, 1118925335
  br i1 %20, label %expf.exit, label %21

; <label>:21                                      ; preds = %19
  %22 = icmp slt i32 %9, 0
  %23 = icmp ugt i32 %11, 1120924085
  %or.cond = and i1 %22, %23
  br i1 %or.cond, label %expf.exit, label %thread-pre-split

thread-pre-split:                                 ; preds = %21
  %24 = icmp ugt i32 %11, 1051816472
  br i1 %24, label %25, label %49

; <label>:25                                      ; preds = %thread-pre-split
  %26 = icmp ult i32 %11, 1065686418
  br i1 %26, label %27, label %36

; <label>:27                                      ; preds = %25
  %28 = sext i32 %10 to i64
  %29 = getelementptr inbounds [2 x float]* @ln2HI31, i64 0, i64 %28
  %30 = load float* %29, align 4
  %31 = fsub float %8, %30
  %32 = getelementptr inbounds [2 x float]* @ln2LO32, i64 0, i64 %28
  %33 = load float* %32, align 4
  %34 = sub nsw i32 1, %10
  %35 = sub nsw i32 %34, %10
  br label %47

; <label>:36                                      ; preds = %25
  %37 = fmul float %8, 0x3FF7154760000000
  %38 = sext i32 %10 to i64
  %39 = getelementptr inbounds [2 x float]* @halF33, i64 0, i64 %38
  %40 = load float* %39, align 4
  %41 = fadd float %37, %40
  %42 = fptosi float %41 to i32
  %43 = sitofp i32 %42 to float
  %44 = fmul float %43, 0x3FE62E3000000000
  %45 = fsub float %8, %44
  %46 = fmul float %43, 0x3EE2FEFA20000000
  br label %47

; <label>:47                                      ; preds = %36, %27
  %k.i.i.0 = phi i32 [ %35, %27 ], [ %42, %36 ]
  %lo.i.i.1 = phi float [ %33, %27 ], [ %46, %36 ]
  %hi.i.i.1 = phi float [ %31, %27 ], [ %45, %36 ]
  %48 = fsub float %hi.i.i.1, %lo.i.i.1
  br label %55

; <label>:49                                      ; preds = %thread-pre-split
  %50 = icmp ult i32 %11, 830472192
  %51 = fadd float %8, 0x46293E5940000000
  %52 = fcmp ogt float %51, 1.000000e+00
  %or.cond52 = and i1 %50, %52
  br i1 %or.cond52, label %53, label %55

; <label>:53                                      ; preds = %49
  %54 = fadd float %8, 1.000000e+00
  br label %expf.exit

; <label>:55                                      ; preds = %49, %47
  %k.i.i.1 = phi i32 [ %k.i.i.0, %47 ], [ 0, %49 ]
  %lo.i.i.2 = phi float [ %lo.i.i.1, %47 ], [ %lo.i.i.0, %49 ]
  %hi.i.i.2 = phi float [ %hi.i.i.1, %47 ], [ %hi.i.i.0, %49 ]
  %.048 = phi float [ %48, %47 ], [ %8, %49 ]
  %56 = fmul float %.048, %.048
  %57 = fmul float %56, 0x3E66376980000000
  %58 = fadd float %57, 0xBEBBBD41C0000000
  %59 = fmul float %56, %58
  %60 = fadd float %59, 0x3F11566AA0000000
  %61 = fmul float %56, %60
  %62 = fadd float %61, 0xBF66C16C20000000
  %63 = fmul float %56, %62
  %64 = fadd float %63, 0x3FC5555560000000
  %65 = fmul float %56, %64
  %66 = fsub float %.048, %65
  %67 = icmp eq i32 %k.i.i.1, 0
  %68 = fmul float %.048, %66
  br i1 %67, label %69, label %74

; <label>:69                                      ; preds = %55
  %70 = fadd float %66, -2.000000e+00
  %71 = fdiv float %68, %70
  %72 = fsub float %71, %.048
  %73 = fsub float 1.000000e+00, %72
  br label %expf.exit

; <label>:74                                      ; preds = %55
  %75 = fsub float 2.000000e+00, %66
  %76 = fdiv float %68, %75
  %77 = fsub float %lo.i.i.2, %76
  %78 = fsub float %77, %hi.i.i.2
  %79 = fsub float 1.000000e+00, %78
  %80 = icmp sgt i32 %k.i.i.1, -126
  %81 = bitcast float %79 to i32
  %82 = shl i32 %k.i.i.1, 23
  br i1 %80, label %83, label %86

; <label>:83                                      ; preds = %74
  %84 = add i32 %81, %82
  %85 = bitcast i32 %84 to float
  br label %expf.exit

; <label>:86                                      ; preds = %74
  %87 = add i32 %82, 838860800
  %88 = add i32 %81, %87
  %89 = bitcast i32 %88 to float
  %90 = fmul float %89, 0x39B0000000000000
  br label %expf.exit

expf.exit:                                        ; preds = %86, %83, %69, %53, %21, %19, %17, %13
  %lo.i.i.3 = phi float [ %lo.i.i.0, %13 ], [ %lo.i.i.2, %69 ], [ %lo.i.i.2, %83 ], [ %lo.i.i.2, %86 ], [ %lo.i.i.0, %53 ], [ %lo.i.i.0, %19 ], [ %lo.i.i.0, %17 ], [ %lo.i.i.0, %21 ]
  %hi.i.i.3 = phi float [ %hi.i.i.0, %13 ], [ %hi.i.i.2, %69 ], [ %hi.i.i.2, %83 ], [ %hi.i.i.2, %86 ], [ %hi.i.i.0, %53 ], [ %hi.i.i.0, %19 ], [ %hi.i.i.0, %17 ], [ %hi.i.i.0, %21 ]
  %.0 = phi float [ %14, %13 ], [ %73, %69 ], [ %85, %83 ], [ %90, %86 ], [ %54, %53 ], [ 0x7FF0000000000000, %19 ], [ %., %17 ], [ 0.000000e+00, %21 ]
  store float %.0, float* %scevgep7, align 4
  %91 = add nuw nsw i64 %fusion.1.indvar.dim.18, 1
  %exitcond6 = icmp eq i64 %91, 64
  br i1 %exitcond6, label %reduce.1.inner.loop_body.reduction_dim.1.preheader, label %fusion.1.loop_body.dim.1, !llvm.loop !3

reduce.1.inner.loop_body.reduction_dim.1.preheader: ; preds = %expf.exit
  br label %reduce.1.inner.loop_body.reduction_dim.1

reduce.1.inner.loop_body.reduction_dim.1:         ; preds = %reduce.1.inner.loop_body.reduction_dim.1, %reduce.1.inner.loop_body.reduction_dim.1.preheader
  %92 = phi float [ %94, %reduce.1.inner.loop_body.reduction_dim.1 ], [ 0.000000e+00, %reduce.1.inner.loop_body.reduction_dim.1.preheader ]
  %reduce.1.inner.indvar.reduction_dim.14 = phi i64 [ %95, %reduce.1.inner.loop_body.reduction_dim.1 ], [ 0, %reduce.1.inner.loop_body.reduction_dim.1.preheader ]
  %scevgep3 = getelementptr [1 x [64 x float]]* @temp1, i64 0, i64 0, i64 %reduce.1.inner.indvar.reduction_dim.14
  %93 = load float* %scevgep3, align 4
  %94 = fadd float %92, %93
  %95 = add nuw nsw i64 %reduce.1.inner.indvar.reduction_dim.14, 1
  %exitcond = icmp eq i64 %95, 64
  br i1 %exitcond, label %fusion.loop_body.dim.0.preheader, label %reduce.1.inner.loop_body.reduction_dim.1, !llvm.loop !4

fusion.loop_body.dim.0.preheader:                 ; preds = %reduce.1.inner.loop_body.reduction_dim.1
  %.lcssa = phi float [ %94, %reduce.1.inner.loop_body.reduction_dim.1 ]
  br label %fusion.loop_body.dim.0

fusion.loop_body.dim.0:                           ; preds = %fusion.loop_body.dim.0, %fusion.loop_body.dim.0.preheader
  %fusion.indvar.dim.02 = phi i64 [ %98, %fusion.loop_body.dim.0 ], [ 0, %fusion.loop_body.dim.0.preheader ]
  %scevgep = getelementptr [64 x float]* @temp3, i64 0, i64 %fusion.indvar.dim.02
  %scevgep2 = getelementptr [1 x [64 x float]]* @temp1, i64 0, i64 0, i64 %fusion.indvar.dim.02
  %96 = load float* %scevgep2, align 4
  %97 = fdiv float %96, %.lcssa
  store volatile float %97, float* %scevgep, align 4
  %98 = add nuw nsw i64 %fusion.indvar.dim.02, 1
  %exitcond1 = icmp eq i64 %98, 64
  br i1 %exitcond1, label %fusion.loop_exit.dim.0, label %fusion.loop_body.dim.0, !llvm.loop !5

fusion.loop_exit.dim.0:                           ; preds = %fusion.loop_body.dim.0
  %leflow_retval = load volatile float* getelementptr inbounds ([64 x float]* @temp3, i64 0, i64 0), align 8
  ret float %leflow_retval
}

attributes #0 = { nounwind "no-frame-pointer-elim"="false" }

!llvm.ident = !{!0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0}

!0 = metadata !{metadata !"clang version 3.5.0 (tags/RELEASE_350/final)"}
!1 = metadata !{metadata !1, metadata !2}
!2 = metadata !{metadata !"llvm.loop.vectorize.enable", i1 false}
!3 = metadata !{metadata !3, metadata !2}
!4 = metadata !{metadata !4, metadata !2}
!5 = metadata !{metadata !5, metadata !2}
