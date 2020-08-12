; ModuleID = '07_softmax_b.bc'
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
  br label %fusion.1.loop_body.dim.1

fusion.1.loop_body.dim.1:                         ; preds = %expf.exit, %fusion.1.loop_body.dim.1.preheader
  %lo.i.i.0 = phi float [ %lo.i.i.3, %expf.exit ], [ undef, %fusion.1.loop_body.dim.1.preheader ]
  %hi.i.i.0 = phi float [ %hi.i.i.3, %expf.exit ], [ undef, %fusion.1.loop_body.dim.1.preheader ]
  %fusion.1.indvar.dim.18 = phi i64 [ %89, %expf.exit ], [ 0, %fusion.1.loop_body.dim.1.preheader ]
  %scevgep7 = getelementptr [1 x [64 x float]]* @temp1, i64 0, i64 0, i64 %fusion.1.indvar.dim.18
  %scevgep8 = getelementptr [1 x [64 x float]]* @param0, i64 0, i64 0, i64 %fusion.1.indvar.dim.18
  %7 = load volatile float* %scevgep8, align 4
  %8 = fsub float %7, %5
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
  br i1 %24, label %25, label %47

; <label>:25                                      ; preds = %thread-pre-split
  %26 = icmp ult i32 %11, 1065686418
  br i1 %26, label %27, label %35

; <label>:27                                      ; preds = %25
  %28 = zext i32 %10 to i64
  %29 = getelementptr inbounds [2 x float]* @ln2HI31, i64 0, i64 %28
  %30 = load float* %29, align 4
  %31 = getelementptr inbounds [2 x float]* @ln2LO32, i64 0, i64 %28
  %32 = load float* %31, align 4
  %33 = xor i32 %10, 1
  %34 = sub nsw i32 %33, %10
  br label %45

; <label>:35                                      ; preds = %25
  %36 = fmul float %8, 0x3FF7154760000000
  %37 = zext i32 %10 to i64
  %38 = getelementptr inbounds [2 x float]* @halF33, i64 0, i64 %37
  %39 = load float* %38, align 4
  %40 = fadd float %36, %39
  %41 = fptosi float %40 to i32
  %42 = sitofp i32 %41 to float
  %43 = fmul float %42, 0x3FE62E3000000000
  %44 = fmul float %42, 0x3EE2FEFA20000000
  br label %45

; <label>:45                                      ; preds = %35, %27
  %k.i.i.0 = phi i32 [ %34, %27 ], [ %41, %35 ]
  %lo.i.i.1 = phi float [ %32, %27 ], [ %44, %35 ]
  %.pn = phi float [ %30, %27 ], [ %43, %35 ]
  %hi.i.i.1 = fsub float %8, %.pn
  %46 = fsub float %hi.i.i.1, %lo.i.i.1
  br label %53

; <label>:47                                      ; preds = %thread-pre-split
  %48 = icmp ult i32 %11, 830472192
  %49 = fadd float %8, 0x46293E5940000000
  %50 = fcmp ogt float %49, 1.000000e+00
  %or.cond52 = and i1 %48, %50
  br i1 %or.cond52, label %51, label %53

; <label>:51                                      ; preds = %47
  %52 = fadd float %8, 1.000000e+00
  br label %expf.exit

; <label>:53                                      ; preds = %47, %45
  %k.i.i.1 = phi i32 [ %k.i.i.0, %45 ], [ 0, %47 ]
  %lo.i.i.2 = phi float [ %lo.i.i.1, %45 ], [ %lo.i.i.0, %47 ]
  %hi.i.i.2 = phi float [ %hi.i.i.1, %45 ], [ %hi.i.i.0, %47 ]
  %.048 = phi float [ %46, %45 ], [ %8, %47 ]
  %54 = fmul float %.048, %.048
  %55 = fmul float %54, 0x3E66376980000000
  %56 = fadd float %55, 0xBEBBBD41C0000000
  %57 = fmul float %54, %56
  %58 = fadd float %57, 0x3F11566AA0000000
  %59 = fmul float %54, %58
  %60 = fadd float %59, 0xBF66C16C20000000
  %61 = fmul float %54, %60
  %62 = fadd float %61, 0x3FC5555560000000
  %63 = fmul float %54, %62
  %64 = fsub float %.048, %63
  %65 = icmp eq i32 %k.i.i.1, 0
  %66 = fmul float %.048, %64
  br i1 %65, label %67, label %72

; <label>:67                                      ; preds = %53
  %68 = fadd float %64, -2.000000e+00
  %69 = fdiv float %66, %68
  %70 = fsub float %69, %.048
  %71 = fsub float 1.000000e+00, %70
  br label %expf.exit

; <label>:72                                      ; preds = %53
  %73 = fsub float 2.000000e+00, %64
  %74 = fdiv float %66, %73
  %75 = fsub float %lo.i.i.2, %74
  %76 = fsub float %75, %hi.i.i.2
  %77 = fsub float 1.000000e+00, %76
  %78 = icmp sgt i32 %k.i.i.1, -126
  %79 = bitcast float %77 to i32
  %80 = shl i32 %k.i.i.1, 23
  br i1 %78, label %81, label %84

; <label>:81                                      ; preds = %72
  %82 = add i32 %79, %80
  %83 = bitcast i32 %82 to float
  br label %expf.exit

; <label>:84                                      ; preds = %72
  %85 = add i32 %80, 838860800
  %86 = add i32 %79, %85
  %87 = bitcast i32 %86 to float
  %88 = fmul float %87, 0x39B0000000000000
  br label %expf.exit

expf.exit:                                        ; preds = %84, %81, %67, %51, %21, %19, %17, %13
  %lo.i.i.3 = phi float [ %lo.i.i.0, %13 ], [ %lo.i.i.2, %67 ], [ %lo.i.i.2, %81 ], [ %lo.i.i.2, %84 ], [ %lo.i.i.0, %51 ], [ %lo.i.i.0, %19 ], [ %lo.i.i.0, %17 ], [ %lo.i.i.0, %21 ]
  %hi.i.i.3 = phi float [ %hi.i.i.0, %13 ], [ %hi.i.i.2, %67 ], [ %hi.i.i.2, %81 ], [ %hi.i.i.2, %84 ], [ %hi.i.i.0, %51 ], [ %hi.i.i.0, %19 ], [ %hi.i.i.0, %17 ], [ %hi.i.i.0, %21 ]
  %.0 = phi float [ %14, %13 ], [ %71, %67 ], [ %83, %81 ], [ %88, %84 ], [ %52, %51 ], [ 0x7FF0000000000000, %19 ], [ %., %17 ], [ 0.000000e+00, %21 ]
  store float %.0, float* %scevgep7, align 4
  %89 = add nuw nsw i64 %fusion.1.indvar.dim.18, 1
  %exitcond6 = icmp eq i64 %89, 64
  br i1 %exitcond6, label %reduce.1.inner.loop_body.reduction_dim.1.preheader, label %fusion.1.loop_body.dim.1, !llvm.loop !3

reduce.1.inner.loop_body.reduction_dim.1.preheader: ; preds = %expf.exit
  br label %reduce.1.inner.loop_body.reduction_dim.1

reduce.1.inner.loop_body.reduction_dim.1:         ; preds = %reduce.1.inner.loop_body.reduction_dim.1, %reduce.1.inner.loop_body.reduction_dim.1.preheader
  %90 = phi float [ %92, %reduce.1.inner.loop_body.reduction_dim.1 ], [ 0.000000e+00, %reduce.1.inner.loop_body.reduction_dim.1.preheader ]
  %reduce.1.inner.indvar.reduction_dim.14 = phi i64 [ %93, %reduce.1.inner.loop_body.reduction_dim.1 ], [ 0, %reduce.1.inner.loop_body.reduction_dim.1.preheader ]
  %scevgep3 = getelementptr [1 x [64 x float]]* @temp1, i64 0, i64 0, i64 %reduce.1.inner.indvar.reduction_dim.14
  %91 = load float* %scevgep3, align 4
  %92 = fadd float %90, %91
  %93 = add nuw nsw i64 %reduce.1.inner.indvar.reduction_dim.14, 1
  %exitcond = icmp eq i64 %93, 64
  br i1 %exitcond, label %fusion.loop_body.dim.0.preheader, label %reduce.1.inner.loop_body.reduction_dim.1, !llvm.loop !4

fusion.loop_body.dim.0.preheader:                 ; preds = %reduce.1.inner.loop_body.reduction_dim.1
  br label %fusion.loop_body.dim.0

fusion.loop_body.dim.0:                           ; preds = %fusion.loop_body.dim.0, %fusion.loop_body.dim.0.preheader
  %fusion.indvar.dim.02 = phi i64 [ %96, %fusion.loop_body.dim.0 ], [ 0, %fusion.loop_body.dim.0.preheader ]
  %scevgep = getelementptr [64 x float]* @temp3, i64 0, i64 %fusion.indvar.dim.02
  %scevgep2 = getelementptr [1 x [64 x float]]* @temp1, i64 0, i64 0, i64 %fusion.indvar.dim.02
  %94 = load float* %scevgep2, align 4
  %95 = fdiv float %94, %92
  store volatile float %95, float* %scevgep, align 4
  %96 = add nuw nsw i64 %fusion.indvar.dim.02, 1
  %exitcond1 = icmp eq i64 %96, 64
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
