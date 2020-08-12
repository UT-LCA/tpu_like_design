; ModuleID = 'classificationMNIST.postlto.bc'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux_gnu"

@temp3 = internal global [10 x float] zeroinitializer, align 8
@temp1 = internal unnamed_addr global [1 x [10 x float]] zeroinitializer, align 8
@temp0 = internal unnamed_addr global [1 x [10 x float]] zeroinitializer, align 8
@param2 = internal global [1 x [784 x float]] zeroinitializer, align 8
@param1 = internal global [784 x [10 x float]] zeroinitializer, align 8
@param0 = internal global [10 x float] zeroinitializer, align 8
@ln2HI31 = internal unnamed_addr constant [2 x float] [float 0x3FE62E3000000000, float 0xBFE62E3000000000], align 4
@ln2LO32 = internal unnamed_addr constant [2 x float] [float 0x3EE2FEFA20000000, float 0xBEE2FEFA20000000], align 4
@halF33 = internal unnamed_addr constant [2 x float] [float 5.000000e-01, float -5.000000e-01], align 4

; Function Attrs: nounwind
define float @main() #0 {
dot.loop_body.rhs.1.lr.ph:
  br label %dot.loop_body.reduction.lr.ph

dot.loop_body.reduction.lr.ph:                    ; preds = %dot.loop_exit.reduction, %dot.loop_body.rhs.1.lr.ph
  %dot.indvar.rhs.122 = phi i64 [ 0, %dot.loop_body.rhs.1.lr.ph ], [ %invar.inc1, %dot.loop_exit.reduction ]
  br label %dot.loop_body.reduction

dot.loop_body.reduction:                          ; preds = %dot.loop_body.reduction, %dot.loop_body.reduction.lr.ph
  %0 = phi float [ 0.000000e+00, %dot.loop_body.reduction.lr.ph ], [ %6, %dot.loop_body.reduction ]
  %dot.indvar.reduction20 = phi i64 [ 0, %dot.loop_body.reduction.lr.ph ], [ %invar.inc2, %dot.loop_body.reduction ]
  %1 = getelementptr inbounds [1 x [784 x float]]* @param2, i64 0, i64 0, i64 %dot.indvar.reduction20
  %2 = load volatile float* %1, align 4
  %3 = getelementptr inbounds [784 x [10 x float]]* @param1, i64 0, i64 %dot.indvar.reduction20, i64 %dot.indvar.rhs.122
  %4 = load volatile float* %3, align 4
  %5 = fmul float %2, %4
  %6 = fadd float %0, %5
  %invar.inc2 = add nuw nsw i64 %dot.indvar.reduction20, 1
  %exitcond10 = icmp eq i64 %invar.inc2, 784
  br i1 %exitcond10, label %dot.loop_exit.reduction, label %dot.loop_body.reduction, !llvm.loop !1

dot.loop_exit.reduction:                          ; preds = %dot.loop_body.reduction
  %.lcssa52 = phi float [ %6, %dot.loop_body.reduction ]
  %7 = getelementptr inbounds [1 x [10 x float]]* @temp0, i64 0, i64 0, i64 %dot.indvar.rhs.122
  store float %.lcssa52, float* %7, align 4
  %invar.inc1 = add nuw nsw i64 %dot.indvar.rhs.122, 1
  %exitcond11 = icmp eq i64 %invar.inc1, 10
  br i1 %exitcond11, label %fusion.2.loop_body.dim.1, label %dot.loop_body.reduction.lr.ph, !llvm.loop !3

fusion.2.loop_body.dim.1:                         ; preds = %fusion.2.loop_body.dim.1, %dot.loop_exit.reduction
  %fusion.2.indvar.dim.116 = phi i64 [ %invar.inc4, %fusion.2.loop_body.dim.1 ], [ 0, %dot.loop_exit.reduction ]
  %8 = getelementptr inbounds [1 x [10 x float]]* @temp0, i64 0, i64 0, i64 %fusion.2.indvar.dim.116
  %9 = load float* %8, align 4
  %10 = getelementptr inbounds [10 x float]* @param0, i64 0, i64 %fusion.2.indvar.dim.116
  %11 = load volatile float* %10, align 4
  %12 = fadd float %9, %11
  %13 = getelementptr inbounds [1 x [10 x float]]* @temp1, i64 0, i64 0, i64 %fusion.2.indvar.dim.116
  store float %12, float* %13, align 4
  %invar.inc4 = add nuw nsw i64 %fusion.2.indvar.dim.116, 1
  %exitcond9 = icmp eq i64 %invar.inc4, 10
  br i1 %exitcond9, label %reduce.inner.loop_body.reduction_dim.1, label %fusion.2.loop_body.dim.1, !llvm.loop !4

reduce.inner.loop_body.reduction_dim.1:           ; preds = %reduce.inner.loop_body.reduction_dim.1, %fusion.2.loop_body.dim.1
  %14 = phi float [ %20, %reduce.inner.loop_body.reduction_dim.1 ], [ 0xFFF0000000000000, %fusion.2.loop_body.dim.1 ]
  %reduce.inner.indvar.reduction_dim.112 = phi i64 [ %invar.inc6, %reduce.inner.loop_body.reduction_dim.1 ], [ 0, %fusion.2.loop_body.dim.1 ]
  %15 = getelementptr inbounds [1 x [10 x float]]* @temp1, i64 0, i64 0, i64 %reduce.inner.indvar.reduction_dim.112
  %16 = load float* %15, align 4
  %17 = fcmp oge float %14, %16
  %18 = fcmp ueq float %14, 0.000000e+00
  %19 = or i1 %17, %18
  %20 = select i1 %19, float %14, float %16
  %invar.inc6 = add nuw nsw i64 %reduce.inner.indvar.reduction_dim.112, 1
  %exitcond8 = icmp eq i64 %invar.inc6, 10
  br i1 %exitcond8, label %fusion.1.loop_body.dim.1.preheader, label %reduce.inner.loop_body.reduction_dim.1, !llvm.loop !5

fusion.1.loop_body.dim.1.preheader:               ; preds = %reduce.inner.loop_body.reduction_dim.1
  %.lcssa51 = phi float [ %20, %reduce.inner.loop_body.reduction_dim.1 ]
  br label %fusion.1.loop_body.dim.1

fusion.1.loop_body.dim.1:                         ; preds = %expf.exit, %fusion.1.loop_body.dim.1.preheader
  %lo.i.i.0 = phi float [ %lo.i.i.3, %expf.exit ], [ undef, %fusion.1.loop_body.dim.1.preheader ]
  %hi.i.i.0 = phi float [ %hi.i.i.3, %expf.exit ], [ undef, %fusion.1.loop_body.dim.1.preheader ]
  %fusion.1.indvar.dim.18 = phi i64 [ %invar.inc8, %expf.exit ], [ 0, %fusion.1.loop_body.dim.1.preheader ]
  %21 = getelementptr inbounds [1 x [10 x float]]* @temp0, i64 0, i64 0, i64 %fusion.1.indvar.dim.18
  %22 = load float* %21, align 4
  %23 = getelementptr inbounds [10 x float]* @param0, i64 0, i64 %fusion.1.indvar.dim.18
  %24 = load volatile float* %23, align 4
  %25 = fadd float %22, %24
  %26 = fsub float %25, %.lcssa51
  %27 = bitcast float %26 to i32
  %28 = lshr i32 %27, 31
  %29 = and i32 %27, 2147483647
  %30 = icmp ugt i32 %29, 2139095040
  br i1 %30, label %31, label %33

; <label>:31                                      ; preds = %fusion.1.loop_body.dim.1
  %32 = fadd float %26, %26
  br label %expf.exit

; <label>:33                                      ; preds = %fusion.1.loop_body.dim.1
  %34 = icmp eq i32 %29, 2139095040
  br i1 %34, label %35, label %37

; <label>:35                                      ; preds = %33
  %36 = icmp eq i32 %28, 0
  %. = select i1 %36, float %26, float 0.000000e+00
  br label %expf.exit

; <label>:37                                      ; preds = %33
  %38 = icmp sgt i32 %27, 1118925335
  br i1 %38, label %expf.exit, label %39

; <label>:39                                      ; preds = %37
  %40 = icmp slt i32 %27, 0
  %41 = icmp ugt i32 %29, 1120924085
  %or.cond = and i1 %40, %41
  br i1 %or.cond, label %expf.exit, label %thread-pre-split

thread-pre-split:                                 ; preds = %39
  %42 = icmp ugt i32 %29, 1051816472
  br i1 %42, label %43, label %67

; <label>:43                                      ; preds = %thread-pre-split
  %44 = icmp ult i32 %29, 1065686418
  br i1 %44, label %45, label %54

; <label>:45                                      ; preds = %43
  %46 = sext i32 %28 to i64
  %47 = getelementptr inbounds [2 x float]* @ln2HI31, i64 0, i64 %46
  %48 = load float* %47, align 4
  %49 = fsub float %26, %48
  %50 = getelementptr inbounds [2 x float]* @ln2LO32, i64 0, i64 %46
  %51 = load float* %50, align 4
  %52 = sub nsw i32 1, %28
  %53 = sub nsw i32 %52, %28
  br label %65

; <label>:54                                      ; preds = %43
  %55 = fmul float %26, 0x3FF7154760000000
  %56 = sext i32 %28 to i64
  %57 = getelementptr inbounds [2 x float]* @halF33, i64 0, i64 %56
  %58 = load float* %57, align 4
  %59 = fadd float %55, %58
  %60 = fptosi float %59 to i32
  %61 = sitofp i32 %60 to float
  %62 = fmul float %61, 0x3FE62E3000000000
  %63 = fsub float %26, %62
  %64 = fmul float %61, 0x3EE2FEFA20000000
  br label %65

; <label>:65                                      ; preds = %54, %45
  %k.i.i.0 = phi i32 [ %53, %45 ], [ %60, %54 ]
  %lo.i.i.1 = phi float [ %51, %45 ], [ %64, %54 ]
  %hi.i.i.1 = phi float [ %49, %45 ], [ %63, %54 ]
  %66 = fsub float %hi.i.i.1, %lo.i.i.1
  br label %73

; <label>:67                                      ; preds = %thread-pre-split
  %68 = icmp ult i32 %29, 830472192
  %69 = fadd float %26, 0x46293E5940000000
  %70 = fcmp ogt float %69, 1.000000e+00
  %or.cond54 = and i1 %68, %70
  br i1 %or.cond54, label %71, label %73

; <label>:71                                      ; preds = %67
  %72 = fadd float %26, 1.000000e+00
  br label %expf.exit

; <label>:73                                      ; preds = %67, %65
  %k.i.i.1 = phi i32 [ %k.i.i.0, %65 ], [ 0, %67 ]
  %lo.i.i.2 = phi float [ %lo.i.i.1, %65 ], [ %lo.i.i.0, %67 ]
  %hi.i.i.2 = phi float [ %hi.i.i.1, %65 ], [ %hi.i.i.0, %67 ]
  %.048 = phi float [ %66, %65 ], [ %26, %67 ]
  %74 = fmul float %.048, %.048
  %75 = fmul float %74, 0x3E66376980000000
  %76 = fadd float %75, 0xBEBBBD41C0000000
  %77 = fmul float %74, %76
  %78 = fadd float %77, 0x3F11566AA0000000
  %79 = fmul float %74, %78
  %80 = fadd float %79, 0xBF66C16C20000000
  %81 = fmul float %74, %80
  %82 = fadd float %81, 0x3FC5555560000000
  %83 = fmul float %74, %82
  %84 = fsub float %.048, %83
  %85 = icmp eq i32 %k.i.i.1, 0
  %86 = fmul float %.048, %84
  br i1 %85, label %87, label %92

; <label>:87                                      ; preds = %73
  %88 = fadd float %84, -2.000000e+00
  %89 = fdiv float %86, %88
  %90 = fsub float %89, %.048
  %91 = fsub float 1.000000e+00, %90
  br label %expf.exit

; <label>:92                                      ; preds = %73
  %93 = fsub float 2.000000e+00, %84
  %94 = fdiv float %86, %93
  %95 = fsub float %lo.i.i.2, %94
  %96 = fsub float %95, %hi.i.i.2
  %97 = fsub float 1.000000e+00, %96
  %98 = icmp sgt i32 %k.i.i.1, -126
  %99 = bitcast float %97 to i32
  %100 = shl i32 %k.i.i.1, 23
  br i1 %98, label %101, label %104

; <label>:101                                     ; preds = %92
  %102 = add i32 %99, %100
  %103 = bitcast i32 %102 to float
  br label %expf.exit

; <label>:104                                     ; preds = %92
  %105 = add i32 %100, 838860800
  %106 = add i32 %99, %105
  %107 = bitcast i32 %106 to float
  %108 = fmul float %107, 0x39B0000000000000
  br label %expf.exit

expf.exit:                                        ; preds = %104, %101, %87, %71, %39, %37, %35, %31
  %lo.i.i.3 = phi float [ %lo.i.i.0, %31 ], [ %lo.i.i.2, %87 ], [ %lo.i.i.2, %101 ], [ %lo.i.i.2, %104 ], [ %lo.i.i.0, %71 ], [ %lo.i.i.0, %37 ], [ %lo.i.i.0, %35 ], [ %lo.i.i.0, %39 ]
  %hi.i.i.3 = phi float [ %hi.i.i.0, %31 ], [ %hi.i.i.2, %87 ], [ %hi.i.i.2, %101 ], [ %hi.i.i.2, %104 ], [ %hi.i.i.0, %71 ], [ %hi.i.i.0, %37 ], [ %hi.i.i.0, %35 ], [ %hi.i.i.0, %39 ]
  %.0 = phi float [ %32, %31 ], [ %91, %87 ], [ %103, %101 ], [ %108, %104 ], [ %72, %71 ], [ 0x7FF0000000000000, %37 ], [ %., %35 ], [ 0.000000e+00, %39 ]
  %109 = getelementptr inbounds [1 x [10 x float]]* @temp1, i64 0, i64 0, i64 %fusion.1.indvar.dim.18
  store float %.0, float* %109, align 4
  %invar.inc8 = add nuw nsw i64 %fusion.1.indvar.dim.18, 1
  %exitcond7 = icmp eq i64 %invar.inc8, 10
  br i1 %exitcond7, label %reduce.1.inner.loop_body.reduction_dim.1, label %fusion.1.loop_body.dim.1, !llvm.loop !6

reduce.1.inner.loop_body.reduction_dim.1:         ; preds = %reduce.1.inner.loop_body.reduction_dim.1, %expf.exit
  %110 = phi float [ %113, %reduce.1.inner.loop_body.reduction_dim.1 ], [ 0.000000e+00, %expf.exit ]
  %reduce.1.inner.indvar.reduction_dim.14 = phi i64 [ %invar.inc11, %reduce.1.inner.loop_body.reduction_dim.1 ], [ 0, %expf.exit ]
  %111 = getelementptr inbounds [1 x [10 x float]]* @temp1, i64 0, i64 0, i64 %reduce.1.inner.indvar.reduction_dim.14
  %112 = load float* %111, align 4
  %113 = fadd float %110, %112
  %invar.inc11 = add nuw nsw i64 %reduce.1.inner.indvar.reduction_dim.14, 1
  %exitcond6 = icmp eq i64 %invar.inc11, 10
  br i1 %exitcond6, label %fusion.loop_body.dim.0.preheader, label %reduce.1.inner.loop_body.reduction_dim.1, !llvm.loop !7

fusion.loop_body.dim.0.preheader:                 ; preds = %reduce.1.inner.loop_body.reduction_dim.1
  %.lcssa = phi float [ %113, %reduce.1.inner.loop_body.reduction_dim.1 ]
  br label %fusion.loop_body.dim.0

fusion.loop_body.dim.0:                           ; preds = %fusion.loop_body.dim.0, %fusion.loop_body.dim.0.preheader
  %fusion.indvar.dim.02 = phi i64 [ %invar.inc17, %fusion.loop_body.dim.0 ], [ 0, %fusion.loop_body.dim.0.preheader ]
  %114 = getelementptr inbounds [1 x [10 x float]]* @temp1, i64 0, i64 0, i64 %fusion.indvar.dim.02
  %115 = load float* %114, align 4
  %116 = fdiv float %115, %.lcssa
  %117 = getelementptr inbounds [10 x float]* @temp3, i64 0, i64 %fusion.indvar.dim.02
  store volatile float %116, float* %117, align 4
  %invar.inc17 = add nuw nsw i64 %fusion.indvar.dim.02, 1
  %exitcond = icmp eq i64 %invar.inc17, 10
  br i1 %exitcond, label %fusion.loop_exit.dim.0, label %fusion.loop_body.dim.0, !llvm.loop !8

fusion.loop_exit.dim.0:                           ; preds = %fusion.loop_body.dim.0
  %leflow_retval = load volatile float* getelementptr inbounds ([10 x float]* @temp3, i64 0, i64 0), align 8
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
!6 = metadata !{metadata !6, metadata !2}
!7 = metadata !{metadata !7, metadata !2}
!8 = metadata !{metadata !8, metadata !2}
