; ModuleID = '07_softmax_b.postlto.bc'
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
  %0 = phi float [ 0xFFF0000000000000, %reduce.inner.loop_body.reduction_dim.1.lr.ph ], [ %6, %reduce.inner.loop_body.reduction_dim.1 ]
  %reduce.inner.indvar.reduction_dim.112 = phi i64 [ 0, %reduce.inner.loop_body.reduction_dim.1.lr.ph ], [ %invar.inc1, %reduce.inner.loop_body.reduction_dim.1 ]
  %1 = getelementptr inbounds [1 x [64 x float]]* @param0, i64 0, i64 0, i64 %reduce.inner.indvar.reduction_dim.112
  %2 = load volatile float* %1, align 4
  %3 = fcmp oge float %0, %2
  %4 = fcmp ueq float %0, 0.000000e+00
  %5 = or i1 %3, %4
  %6 = select i1 %5, float %0, float %2
  %invar.inc1 = add nuw nsw i64 %reduce.inner.indvar.reduction_dim.112, 1
  %exitcond5 = icmp eq i64 %invar.inc1, 64
  br i1 %exitcond5, label %fusion.1.loop_body.dim.1.preheader, label %reduce.inner.loop_body.reduction_dim.1, !llvm.loop !1

fusion.1.loop_body.dim.1.preheader:               ; preds = %reduce.inner.loop_body.reduction_dim.1
  %.lcssa50 = phi float [ %6, %reduce.inner.loop_body.reduction_dim.1 ]
  br label %fusion.1.loop_body.dim.1

fusion.1.loop_body.dim.1:                         ; preds = %expf.exit, %fusion.1.loop_body.dim.1.preheader
  %lo.i.i.0 = phi float [ %lo.i.i.3, %expf.exit ], [ undef, %fusion.1.loop_body.dim.1.preheader ]
  %hi.i.i.0 = phi float [ %hi.i.i.3, %expf.exit ], [ undef, %fusion.1.loop_body.dim.1.preheader ]
  %fusion.1.indvar.dim.18 = phi i64 [ %invar.inc3, %expf.exit ], [ 0, %fusion.1.loop_body.dim.1.preheader ]
  %7 = getelementptr inbounds [1 x [64 x float]]* @param0, i64 0, i64 0, i64 %fusion.1.indvar.dim.18
  %8 = load volatile float* %7, align 4
  %9 = fsub float %8, %.lcssa50
  %10 = bitcast float %9 to i32
  %11 = lshr i32 %10, 31
  %12 = and i32 %10, 2147483647
  %13 = icmp ugt i32 %12, 2139095040
  br i1 %13, label %14, label %16

; <label>:14                                      ; preds = %fusion.1.loop_body.dim.1
  %15 = fadd float %9, %9
  br label %expf.exit

; <label>:16                                      ; preds = %fusion.1.loop_body.dim.1
  %17 = icmp eq i32 %12, 2139095040
  br i1 %17, label %18, label %20

; <label>:18                                      ; preds = %16
  %19 = icmp eq i32 %11, 0
  %. = select i1 %19, float %9, float 0.000000e+00
  br label %expf.exit

; <label>:20                                      ; preds = %16
  %21 = icmp sgt i32 %10, 1118925335
  br i1 %21, label %expf.exit, label %22

; <label>:22                                      ; preds = %20
  %23 = icmp slt i32 %10, 0
  %24 = icmp ugt i32 %12, 1120924085
  %or.cond = and i1 %23, %24
  br i1 %or.cond, label %expf.exit, label %thread-pre-split

thread-pre-split:                                 ; preds = %22
  %25 = icmp ugt i32 %12, 1051816472
  br i1 %25, label %26, label %50

; <label>:26                                      ; preds = %thread-pre-split
  %27 = icmp ult i32 %12, 1065686418
  br i1 %27, label %28, label %37

; <label>:28                                      ; preds = %26
  %29 = sext i32 %11 to i64
  %30 = getelementptr inbounds [2 x float]* @ln2HI31, i64 0, i64 %29
  %31 = load float* %30, align 4
  %32 = fsub float %9, %31
  %33 = getelementptr inbounds [2 x float]* @ln2LO32, i64 0, i64 %29
  %34 = load float* %33, align 4
  %35 = sub nsw i32 1, %11
  %36 = sub nsw i32 %35, %11
  br label %48

; <label>:37                                      ; preds = %26
  %38 = fmul float %9, 0x3FF7154760000000
  %39 = sext i32 %11 to i64
  %40 = getelementptr inbounds [2 x float]* @halF33, i64 0, i64 %39
  %41 = load float* %40, align 4
  %42 = fadd float %38, %41
  %43 = fptosi float %42 to i32
  %44 = sitofp i32 %43 to float
  %45 = fmul float %44, 0x3FE62E3000000000
  %46 = fsub float %9, %45
  %47 = fmul float %44, 0x3EE2FEFA20000000
  br label %48

; <label>:48                                      ; preds = %37, %28
  %k.i.i.0 = phi i32 [ %36, %28 ], [ %43, %37 ]
  %lo.i.i.1 = phi float [ %34, %28 ], [ %47, %37 ]
  %hi.i.i.1 = phi float [ %32, %28 ], [ %46, %37 ]
  %49 = fsub float %hi.i.i.1, %lo.i.i.1
  br label %56

; <label>:50                                      ; preds = %thread-pre-split
  %51 = icmp ult i32 %12, 830472192
  %52 = fadd float %9, 0x46293E5940000000
  %53 = fcmp ogt float %52, 1.000000e+00
  %or.cond52 = and i1 %51, %53
  br i1 %or.cond52, label %54, label %56

; <label>:54                                      ; preds = %50
  %55 = fadd float %9, 1.000000e+00
  br label %expf.exit

; <label>:56                                      ; preds = %50, %48
  %k.i.i.1 = phi i32 [ %k.i.i.0, %48 ], [ 0, %50 ]
  %lo.i.i.2 = phi float [ %lo.i.i.1, %48 ], [ %lo.i.i.0, %50 ]
  %hi.i.i.2 = phi float [ %hi.i.i.1, %48 ], [ %hi.i.i.0, %50 ]
  %.048 = phi float [ %49, %48 ], [ %9, %50 ]
  %57 = fmul float %.048, %.048
  %58 = fmul float %57, 0x3E66376980000000
  %59 = fadd float %58, 0xBEBBBD41C0000000
  %60 = fmul float %57, %59
  %61 = fadd float %60, 0x3F11566AA0000000
  %62 = fmul float %57, %61
  %63 = fadd float %62, 0xBF66C16C20000000
  %64 = fmul float %57, %63
  %65 = fadd float %64, 0x3FC5555560000000
  %66 = fmul float %57, %65
  %67 = fsub float %.048, %66
  %68 = icmp eq i32 %k.i.i.1, 0
  %69 = fmul float %.048, %67
  br i1 %68, label %70, label %75

; <label>:70                                      ; preds = %56
  %71 = fadd float %67, -2.000000e+00
  %72 = fdiv float %69, %71
  %73 = fsub float %72, %.048
  %74 = fsub float 1.000000e+00, %73
  br label %expf.exit

; <label>:75                                      ; preds = %56
  %76 = fsub float 2.000000e+00, %67
  %77 = fdiv float %69, %76
  %78 = fsub float %lo.i.i.2, %77
  %79 = fsub float %78, %hi.i.i.2
  %80 = fsub float 1.000000e+00, %79
  %81 = icmp sgt i32 %k.i.i.1, -126
  %82 = bitcast float %80 to i32
  %83 = shl i32 %k.i.i.1, 23
  br i1 %81, label %84, label %87

; <label>:84                                      ; preds = %75
  %85 = add i32 %82, %83
  %86 = bitcast i32 %85 to float
  br label %expf.exit

; <label>:87                                      ; preds = %75
  %88 = add i32 %83, 838860800
  %89 = add i32 %82, %88
  %90 = bitcast i32 %89 to float
  %91 = fmul float %90, 0x39B0000000000000
  br label %expf.exit

expf.exit:                                        ; preds = %87, %84, %70, %54, %22, %20, %18, %14
  %lo.i.i.3 = phi float [ %lo.i.i.0, %14 ], [ %lo.i.i.2, %70 ], [ %lo.i.i.2, %84 ], [ %lo.i.i.2, %87 ], [ %lo.i.i.0, %54 ], [ %lo.i.i.0, %20 ], [ %lo.i.i.0, %18 ], [ %lo.i.i.0, %22 ]
  %hi.i.i.3 = phi float [ %hi.i.i.0, %14 ], [ %hi.i.i.2, %70 ], [ %hi.i.i.2, %84 ], [ %hi.i.i.2, %87 ], [ %hi.i.i.0, %54 ], [ %hi.i.i.0, %20 ], [ %hi.i.i.0, %18 ], [ %hi.i.i.0, %22 ]
  %.0 = phi float [ %15, %14 ], [ %74, %70 ], [ %86, %84 ], [ %91, %87 ], [ %55, %54 ], [ 0x7FF0000000000000, %20 ], [ %., %18 ], [ 0.000000e+00, %22 ]
  %92 = getelementptr inbounds [1 x [64 x float]]* @temp1, i64 0, i64 0, i64 %fusion.1.indvar.dim.18
  store float %.0, float* %92, align 4
  %invar.inc3 = add nuw nsw i64 %fusion.1.indvar.dim.18, 1
  %exitcond4 = icmp eq i64 %invar.inc3, 64
  br i1 %exitcond4, label %reduce.1.inner.loop_body.reduction_dim.1, label %fusion.1.loop_body.dim.1, !llvm.loop !3

reduce.1.inner.loop_body.reduction_dim.1:         ; preds = %reduce.1.inner.loop_body.reduction_dim.1, %expf.exit
  %93 = phi float [ %96, %reduce.1.inner.loop_body.reduction_dim.1 ], [ 0.000000e+00, %expf.exit ]
  %reduce.1.inner.indvar.reduction_dim.14 = phi i64 [ %invar.inc6, %reduce.1.inner.loop_body.reduction_dim.1 ], [ 0, %expf.exit ]
  %94 = getelementptr inbounds [1 x [64 x float]]* @temp1, i64 0, i64 0, i64 %reduce.1.inner.indvar.reduction_dim.14
  %95 = load float* %94, align 4
  %96 = fadd float %93, %95
  %invar.inc6 = add nuw nsw i64 %reduce.1.inner.indvar.reduction_dim.14, 1
  %exitcond3 = icmp eq i64 %invar.inc6, 64
  br i1 %exitcond3, label %fusion.loop_body.dim.0.preheader, label %reduce.1.inner.loop_body.reduction_dim.1, !llvm.loop !4

fusion.loop_body.dim.0.preheader:                 ; preds = %reduce.1.inner.loop_body.reduction_dim.1
  %.lcssa = phi float [ %96, %reduce.1.inner.loop_body.reduction_dim.1 ]
  br label %fusion.loop_body.dim.0

fusion.loop_body.dim.0:                           ; preds = %fusion.loop_body.dim.0, %fusion.loop_body.dim.0.preheader
  %fusion.indvar.dim.02 = phi i64 [ %invar.inc12, %fusion.loop_body.dim.0 ], [ 0, %fusion.loop_body.dim.0.preheader ]
  %97 = getelementptr inbounds [1 x [64 x float]]* @temp1, i64 0, i64 0, i64 %fusion.indvar.dim.02
  %98 = load float* %97, align 4
  %99 = fdiv float %98, %.lcssa
  %100 = getelementptr inbounds [64 x float]* @temp3, i64 0, i64 %fusion.indvar.dim.02
  store volatile float %99, float* %100, align 4
  %invar.inc12 = add nuw nsw i64 %fusion.indvar.dim.02, 1
  %exitcond = icmp eq i64 %invar.inc12, 64
  br i1 %exitcond, label %fusion.loop_exit.dim.0, label %fusion.loop_body.dim.0, !llvm.loop !5

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
