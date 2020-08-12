; ModuleID = 'classificationMNIST.bc'
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
  %dot.indvar.rhs.122 = phi i64 [ 0, %dot.loop_body.rhs.1.lr.ph ], [ %6, %dot.loop_exit.reduction ]
  %scevgep23 = getelementptr [1 x [10 x float]]* @temp0, i64 0, i64 0, i64 %dot.indvar.rhs.122
  br label %dot.loop_body.reduction

dot.loop_body.reduction:                          ; preds = %dot.loop_body.reduction, %dot.loop_body.reduction.lr.ph
  %0 = phi float [ 0.000000e+00, %dot.loop_body.reduction.lr.ph ], [ %4, %dot.loop_body.reduction ]
  %dot.indvar.reduction20 = phi i64 [ 0, %dot.loop_body.reduction.lr.ph ], [ %5, %dot.loop_body.reduction ]
  %scevgep19 = getelementptr [784 x [10 x float]]* @param1, i64 0, i64 %dot.indvar.reduction20, i64 %dot.indvar.rhs.122
  %scevgep20 = getelementptr [1 x [784 x float]]* @param2, i64 0, i64 0, i64 %dot.indvar.reduction20
  %1 = load volatile float* %scevgep20, align 4
  %2 = load volatile float* %scevgep19, align 4
  %3 = fmul float %1, %2
  %4 = fadd float %0, %3
  %5 = add nuw nsw i64 %dot.indvar.reduction20, 1
  %exitcond18 = icmp eq i64 %5, 784
  br i1 %exitcond18, label %dot.loop_exit.reduction, label %dot.loop_body.reduction, !llvm.loop !1

dot.loop_exit.reduction:                          ; preds = %dot.loop_body.reduction
  store float %4, float* %scevgep23, align 4
  %6 = add nuw nsw i64 %dot.indvar.rhs.122, 1
  %exitcond21 = icmp eq i64 %6, 10
  br i1 %exitcond21, label %fusion.2.loop_body.dim.1.preheader, label %dot.loop_body.reduction.lr.ph, !llvm.loop !3

fusion.2.loop_body.dim.1.preheader:               ; preds = %dot.loop_exit.reduction
  br label %fusion.2.loop_body.dim.1

fusion.2.loop_body.dim.1:                         ; preds = %fusion.2.loop_body.dim.1, %fusion.2.loop_body.dim.1.preheader
  %fusion.2.indvar.dim.116 = phi i64 [ %10, %fusion.2.loop_body.dim.1 ], [ 0, %fusion.2.loop_body.dim.1.preheader ]
  %scevgep15 = getelementptr [1 x [10 x float]]* @temp1, i64 0, i64 0, i64 %fusion.2.indvar.dim.116
  %scevgep16 = getelementptr [10 x float]* @param0, i64 0, i64 %fusion.2.indvar.dim.116
  %scevgep17 = getelementptr [1 x [10 x float]]* @temp0, i64 0, i64 0, i64 %fusion.2.indvar.dim.116
  %7 = load float* %scevgep17, align 4
  %8 = load volatile float* %scevgep16, align 4
  %9 = fadd float %7, %8
  store float %9, float* %scevgep15, align 4
  %10 = add nuw nsw i64 %fusion.2.indvar.dim.116, 1
  %exitcond14 = icmp eq i64 %10, 10
  br i1 %exitcond14, label %reduce.inner.loop_body.reduction_dim.1.preheader, label %fusion.2.loop_body.dim.1, !llvm.loop !4

reduce.inner.loop_body.reduction_dim.1.preheader: ; preds = %fusion.2.loop_body.dim.1
  br label %reduce.inner.loop_body.reduction_dim.1

reduce.inner.loop_body.reduction_dim.1:           ; preds = %reduce.inner.loop_body.reduction_dim.1, %reduce.inner.loop_body.reduction_dim.1.preheader
  %11 = phi float [ %16, %reduce.inner.loop_body.reduction_dim.1 ], [ 0xFFF0000000000000, %reduce.inner.loop_body.reduction_dim.1.preheader ]
  %reduce.inner.indvar.reduction_dim.112 = phi i64 [ %17, %reduce.inner.loop_body.reduction_dim.1 ], [ 0, %reduce.inner.loop_body.reduction_dim.1.preheader ]
  %scevgep13 = getelementptr [1 x [10 x float]]* @temp1, i64 0, i64 0, i64 %reduce.inner.indvar.reduction_dim.112
  %12 = load float* %scevgep13, align 4
  %13 = fcmp oge float %11, %12
  %14 = fcmp ueq float %11, 0.000000e+00
  %15 = or i1 %13, %14
  %16 = select i1 %15, float %11, float %12
  %17 = add nuw nsw i64 %reduce.inner.indvar.reduction_dim.112, 1
  %exitcond12 = icmp eq i64 %17, 10
  br i1 %exitcond12, label %fusion.1.loop_body.dim.1.preheader, label %reduce.inner.loop_body.reduction_dim.1, !llvm.loop !5

fusion.1.loop_body.dim.1.preheader:               ; preds = %reduce.inner.loop_body.reduction_dim.1
  br label %fusion.1.loop_body.dim.1

fusion.1.loop_body.dim.1:                         ; preds = %expf.exit, %fusion.1.loop_body.dim.1.preheader
  %lo.i.i.0 = phi float [ %lo.i.i.3, %expf.exit ], [ undef, %fusion.1.loop_body.dim.1.preheader ]
  %hi.i.i.0 = phi float [ %hi.i.i.3, %expf.exit ], [ undef, %fusion.1.loop_body.dim.1.preheader ]
  %fusion.1.indvar.dim.18 = phi i64 [ %102, %expf.exit ], [ 0, %fusion.1.loop_body.dim.1.preheader ]
  %scevgep5 = getelementptr [1 x [10 x float]]* @temp1, i64 0, i64 0, i64 %fusion.1.indvar.dim.18
  %scevgep6 = getelementptr [10 x float]* @param0, i64 0, i64 %fusion.1.indvar.dim.18
  %scevgep7 = getelementptr [1 x [10 x float]]* @temp0, i64 0, i64 0, i64 %fusion.1.indvar.dim.18
  %18 = load float* %scevgep7, align 4
  %19 = load volatile float* %scevgep6, align 4
  %20 = fadd float %18, %19
  %21 = fsub float %20, %16
  %22 = bitcast float %21 to i32
  %23 = lshr i32 %22, 31
  %24 = and i32 %22, 2147483647
  %25 = icmp ugt i32 %24, 2139095040
  br i1 %25, label %26, label %28

; <label>:26                                      ; preds = %fusion.1.loop_body.dim.1
  %27 = fadd float %21, %21
  br label %expf.exit

; <label>:28                                      ; preds = %fusion.1.loop_body.dim.1
  %29 = icmp eq i32 %24, 2139095040
  br i1 %29, label %30, label %32

; <label>:30                                      ; preds = %28
  %31 = icmp eq i32 %23, 0
  %. = select i1 %31, float %21, float 0.000000e+00
  br label %expf.exit

; <label>:32                                      ; preds = %28
  %33 = icmp sgt i32 %22, 1118925335
  br i1 %33, label %expf.exit, label %34

; <label>:34                                      ; preds = %32
  %35 = icmp slt i32 %22, 0
  %36 = icmp ugt i32 %24, 1120924085
  %or.cond = and i1 %35, %36
  br i1 %or.cond, label %expf.exit, label %thread-pre-split

thread-pre-split:                                 ; preds = %34
  %37 = icmp ugt i32 %24, 1051816472
  br i1 %37, label %38, label %60

; <label>:38                                      ; preds = %thread-pre-split
  %39 = icmp ult i32 %24, 1065686418
  br i1 %39, label %40, label %48

; <label>:40                                      ; preds = %38
  %41 = zext i32 %23 to i64
  %42 = getelementptr inbounds [2 x float]* @ln2HI31, i64 0, i64 %41
  %43 = load float* %42, align 4
  %44 = getelementptr inbounds [2 x float]* @ln2LO32, i64 0, i64 %41
  %45 = load float* %44, align 4
  %46 = xor i32 %23, 1
  %47 = sub nsw i32 %46, %23
  br label %58

; <label>:48                                      ; preds = %38
  %49 = fmul float %21, 0x3FF7154760000000
  %50 = zext i32 %23 to i64
  %51 = getelementptr inbounds [2 x float]* @halF33, i64 0, i64 %50
  %52 = load float* %51, align 4
  %53 = fadd float %49, %52
  %54 = fptosi float %53 to i32
  %55 = sitofp i32 %54 to float
  %56 = fmul float %55, 0x3FE62E3000000000
  %57 = fmul float %55, 0x3EE2FEFA20000000
  br label %58

; <label>:58                                      ; preds = %48, %40
  %k.i.i.0 = phi i32 [ %47, %40 ], [ %54, %48 ]
  %lo.i.i.1 = phi float [ %45, %40 ], [ %57, %48 ]
  %.pn = phi float [ %43, %40 ], [ %56, %48 ]
  %hi.i.i.1 = fsub float %21, %.pn
  %59 = fsub float %hi.i.i.1, %lo.i.i.1
  br label %66

; <label>:60                                      ; preds = %thread-pre-split
  %61 = icmp ult i32 %24, 830472192
  %62 = fadd float %21, 0x46293E5940000000
  %63 = fcmp ogt float %62, 1.000000e+00
  %or.cond54 = and i1 %61, %63
  br i1 %or.cond54, label %64, label %66

; <label>:64                                      ; preds = %60
  %65 = fadd float %21, 1.000000e+00
  br label %expf.exit

; <label>:66                                      ; preds = %60, %58
  %k.i.i.1 = phi i32 [ %k.i.i.0, %58 ], [ 0, %60 ]
  %lo.i.i.2 = phi float [ %lo.i.i.1, %58 ], [ %lo.i.i.0, %60 ]
  %hi.i.i.2 = phi float [ %hi.i.i.1, %58 ], [ %hi.i.i.0, %60 ]
  %.048 = phi float [ %59, %58 ], [ %21, %60 ]
  %67 = fmul float %.048, %.048
  %68 = fmul float %67, 0x3E66376980000000
  %69 = fadd float %68, 0xBEBBBD41C0000000
  %70 = fmul float %67, %69
  %71 = fadd float %70, 0x3F11566AA0000000
  %72 = fmul float %67, %71
  %73 = fadd float %72, 0xBF66C16C20000000
  %74 = fmul float %67, %73
  %75 = fadd float %74, 0x3FC5555560000000
  %76 = fmul float %67, %75
  %77 = fsub float %.048, %76
  %78 = icmp eq i32 %k.i.i.1, 0
  %79 = fmul float %.048, %77
  br i1 %78, label %80, label %85

; <label>:80                                      ; preds = %66
  %81 = fadd float %77, -2.000000e+00
  %82 = fdiv float %79, %81
  %83 = fsub float %82, %.048
  %84 = fsub float 1.000000e+00, %83
  br label %expf.exit

; <label>:85                                      ; preds = %66
  %86 = fsub float 2.000000e+00, %77
  %87 = fdiv float %79, %86
  %88 = fsub float %lo.i.i.2, %87
  %89 = fsub float %88, %hi.i.i.2
  %90 = fsub float 1.000000e+00, %89
  %91 = icmp sgt i32 %k.i.i.1, -126
  %92 = bitcast float %90 to i32
  %93 = shl i32 %k.i.i.1, 23
  br i1 %91, label %94, label %97

; <label>:94                                      ; preds = %85
  %95 = add i32 %92, %93
  %96 = bitcast i32 %95 to float
  br label %expf.exit

; <label>:97                                      ; preds = %85
  %98 = add i32 %93, 838860800
  %99 = add i32 %92, %98
  %100 = bitcast i32 %99 to float
  %101 = fmul float %100, 0x39B0000000000000
  br label %expf.exit

expf.exit:                                        ; preds = %97, %94, %80, %64, %34, %32, %30, %26
  %lo.i.i.3 = phi float [ %lo.i.i.0, %26 ], [ %lo.i.i.2, %80 ], [ %lo.i.i.2, %94 ], [ %lo.i.i.2, %97 ], [ %lo.i.i.0, %64 ], [ %lo.i.i.0, %32 ], [ %lo.i.i.0, %30 ], [ %lo.i.i.0, %34 ]
  %hi.i.i.3 = phi float [ %hi.i.i.0, %26 ], [ %hi.i.i.2, %80 ], [ %hi.i.i.2, %94 ], [ %hi.i.i.2, %97 ], [ %hi.i.i.0, %64 ], [ %hi.i.i.0, %32 ], [ %hi.i.i.0, %30 ], [ %hi.i.i.0, %34 ]
  %.0 = phi float [ %27, %26 ], [ %84, %80 ], [ %96, %94 ], [ %101, %97 ], [ %65, %64 ], [ 0x7FF0000000000000, %32 ], [ %., %30 ], [ 0.000000e+00, %34 ]
  store float %.0, float* %scevgep5, align 4
  %102 = add nuw nsw i64 %fusion.1.indvar.dim.18, 1
  %exitcond4 = icmp eq i64 %102, 10
  br i1 %exitcond4, label %reduce.1.inner.loop_body.reduction_dim.1.preheader, label %fusion.1.loop_body.dim.1, !llvm.loop !6

reduce.1.inner.loop_body.reduction_dim.1.preheader: ; preds = %expf.exit
  br label %reduce.1.inner.loop_body.reduction_dim.1

reduce.1.inner.loop_body.reduction_dim.1:         ; preds = %reduce.1.inner.loop_body.reduction_dim.1, %reduce.1.inner.loop_body.reduction_dim.1.preheader
  %103 = phi float [ %105, %reduce.1.inner.loop_body.reduction_dim.1 ], [ 0.000000e+00, %reduce.1.inner.loop_body.reduction_dim.1.preheader ]
  %reduce.1.inner.indvar.reduction_dim.14 = phi i64 [ %106, %reduce.1.inner.loop_body.reduction_dim.1 ], [ 0, %reduce.1.inner.loop_body.reduction_dim.1.preheader ]
  %scevgep3 = getelementptr [1 x [10 x float]]* @temp1, i64 0, i64 0, i64 %reduce.1.inner.indvar.reduction_dim.14
  %104 = load float* %scevgep3, align 4
  %105 = fadd float %103, %104
  %106 = add nuw nsw i64 %reduce.1.inner.indvar.reduction_dim.14, 1
  %exitcond = icmp eq i64 %106, 10
  br i1 %exitcond, label %fusion.loop_body.dim.0.preheader, label %reduce.1.inner.loop_body.reduction_dim.1, !llvm.loop !7

fusion.loop_body.dim.0.preheader:                 ; preds = %reduce.1.inner.loop_body.reduction_dim.1
  br label %fusion.loop_body.dim.0

fusion.loop_body.dim.0:                           ; preds = %fusion.loop_body.dim.0, %fusion.loop_body.dim.0.preheader
  %fusion.indvar.dim.02 = phi i64 [ %109, %fusion.loop_body.dim.0 ], [ 0, %fusion.loop_body.dim.0.preheader ]
  %scevgep = getelementptr [10 x float]* @temp3, i64 0, i64 %fusion.indvar.dim.02
  %scevgep2 = getelementptr [1 x [10 x float]]* @temp1, i64 0, i64 0, i64 %fusion.indvar.dim.02
  %107 = load float* %scevgep2, align 4
  %108 = fdiv float %107, %105
  store volatile float %108, float* %scevgep, align 4
  %109 = add nuw nsw i64 %fusion.indvar.dim.02, 1
  %exitcond1 = icmp eq i64 %109, 10
  br i1 %exitcond1, label %fusion.loop_exit.dim.0, label %fusion.loop_body.dim.0, !llvm.loop !8

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
