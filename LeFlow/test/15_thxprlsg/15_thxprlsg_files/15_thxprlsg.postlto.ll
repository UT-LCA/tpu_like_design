; ModuleID = '15_thxprlsg.postlto.bc'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux_gnu"

@temp0 = internal global [8 x float] zeroinitializer, align 8
@param0 = internal global [8 x float] zeroinitializer, align 8
@ln2HI31 = internal unnamed_addr constant [2 x float] [float 0x3FE62E3000000000, float 0xBFE62E3000000000], align 4
@ln2LO32 = internal unnamed_addr constant [2 x float] [float 0x3EE2FEFA20000000, float 0xBEE2FEFA20000000], align 4
@halF33 = internal unnamed_addr constant [2 x float] [float 5.000000e-01, float -5.000000e-01], align 4

; Function Attrs: nounwind
define float @main() #0 {
fusion.loop_body.dim.0.lr.ph:
  br label %fusion.loop_body.dim.0

fusion.loop_body.dim.0:                           ; preds = %expf.exit, %fusion.loop_body.dim.0.lr.ph
  %lo.i.i.0 = phi float [ undef, %fusion.loop_body.dim.0.lr.ph ], [ %lo.i.i.3, %expf.exit ]
  %hi.i.i.0 = phi float [ undef, %fusion.loop_body.dim.0.lr.ph ], [ %hi.i.i.3, %expf.exit ]
  %fusion.indvar.dim.02 = phi i64 [ 0, %fusion.loop_body.dim.0.lr.ph ], [ %invar.inc, %expf.exit ]
  %0 = getelementptr inbounds [8 x float]* @param0, i64 0, i64 %fusion.indvar.dim.02
  %1 = load volatile float* %0, align 4
  %2 = call fastcc float @tanhf(float %1)
  %3 = bitcast float %2 to i32
  %4 = lshr i32 %3, 31
  %5 = and i32 %3, 2147483647
  %6 = icmp ugt i32 %5, 2139095040
  br i1 %6, label %7, label %9

; <label>:7                                       ; preds = %fusion.loop_body.dim.0
  %8 = fadd float %2, %2
  br label %expf.exit

; <label>:9                                       ; preds = %fusion.loop_body.dim.0
  %10 = icmp eq i32 %5, 2139095040
  br i1 %10, label %11, label %13

; <label>:11                                      ; preds = %9
  %12 = icmp eq i32 %4, 0
  %. = select i1 %12, float %2, float 0.000000e+00
  br label %expf.exit

; <label>:13                                      ; preds = %9
  %14 = icmp sgt i32 %3, 1118925335
  br i1 %14, label %expf.exit, label %15

; <label>:15                                      ; preds = %13
  %16 = icmp slt i32 %3, 0
  %17 = icmp ugt i32 %5, 1120924085
  %or.cond = and i1 %16, %17
  br i1 %or.cond, label %expf.exit, label %thread-pre-split

thread-pre-split:                                 ; preds = %15
  %18 = icmp ugt i32 %5, 1051816472
  br i1 %18, label %19, label %43

; <label>:19                                      ; preds = %thread-pre-split
  %20 = icmp ult i32 %5, 1065686418
  br i1 %20, label %21, label %30

; <label>:21                                      ; preds = %19
  %22 = sext i32 %4 to i64
  %23 = getelementptr inbounds [2 x float]* @ln2HI31, i64 0, i64 %22
  %24 = load float* %23, align 4
  %25 = fsub float %2, %24
  %26 = getelementptr inbounds [2 x float]* @ln2LO32, i64 0, i64 %22
  %27 = load float* %26, align 4
  %28 = sub nsw i32 1, %4
  %29 = sub nsw i32 %28, %4
  br label %41

; <label>:30                                      ; preds = %19
  %31 = fmul float %2, 0x3FF7154760000000
  %32 = sext i32 %4 to i64
  %33 = getelementptr inbounds [2 x float]* @halF33, i64 0, i64 %32
  %34 = load float* %33, align 4
  %35 = fadd float %31, %34
  %36 = fptosi float %35 to i32
  %37 = sitofp i32 %36 to float
  %38 = fmul float %37, 0x3FE62E3000000000
  %39 = fsub float %2, %38
  %40 = fmul float %37, 0x3EE2FEFA20000000
  br label %41

; <label>:41                                      ; preds = %30, %21
  %k.i.i.0 = phi i32 [ %29, %21 ], [ %36, %30 ]
  %lo.i.i.1 = phi float [ %27, %21 ], [ %40, %30 ]
  %hi.i.i.1 = phi float [ %25, %21 ], [ %39, %30 ]
  %42 = fsub float %hi.i.i.1, %lo.i.i.1
  br label %49

; <label>:43                                      ; preds = %thread-pre-split
  %44 = icmp ult i32 %5, 830472192
  %45 = fadd float %2, 0x46293E5940000000
  %46 = fcmp ogt float %45, 1.000000e+00
  %or.cond50 = and i1 %44, %46
  br i1 %or.cond50, label %47, label %49

; <label>:47                                      ; preds = %43
  %48 = fadd float %2, 1.000000e+00
  br label %expf.exit

; <label>:49                                      ; preds = %43, %41
  %k.i.i.1 = phi i32 [ %k.i.i.0, %41 ], [ 0, %43 ]
  %lo.i.i.2 = phi float [ %lo.i.i.1, %41 ], [ %lo.i.i.0, %43 ]
  %hi.i.i.2 = phi float [ %hi.i.i.1, %41 ], [ %hi.i.i.0, %43 ]
  %.048 = phi float [ %42, %41 ], [ %2, %43 ]
  %50 = fmul float %.048, %.048
  %51 = fmul float %50, 0x3E66376980000000
  %52 = fadd float %51, 0xBEBBBD41C0000000
  %53 = fmul float %50, %52
  %54 = fadd float %53, 0x3F11566AA0000000
  %55 = fmul float %50, %54
  %56 = fadd float %55, 0xBF66C16C20000000
  %57 = fmul float %50, %56
  %58 = fadd float %57, 0x3FC5555560000000
  %59 = fmul float %50, %58
  %60 = fsub float %.048, %59
  %61 = icmp eq i32 %k.i.i.1, 0
  %62 = fmul float %.048, %60
  br i1 %61, label %63, label %68

; <label>:63                                      ; preds = %49
  %64 = fadd float %60, -2.000000e+00
  %65 = fdiv float %62, %64
  %66 = fsub float %65, %.048
  %67 = fsub float 1.000000e+00, %66
  br label %expf.exit

; <label>:68                                      ; preds = %49
  %69 = fsub float 2.000000e+00, %60
  %70 = fdiv float %62, %69
  %71 = fsub float %lo.i.i.2, %70
  %72 = fsub float %71, %hi.i.i.2
  %73 = fsub float 1.000000e+00, %72
  %74 = icmp sgt i32 %k.i.i.1, -126
  %75 = bitcast float %73 to i32
  %76 = shl i32 %k.i.i.1, 23
  br i1 %74, label %77, label %80

; <label>:77                                      ; preds = %68
  %78 = add i32 %75, %76
  %79 = bitcast i32 %78 to float
  br label %expf.exit

; <label>:80                                      ; preds = %68
  %81 = add i32 %76, 838860800
  %82 = add i32 %75, %81
  %83 = bitcast i32 %82 to float
  %84 = fmul float %83, 0x39B0000000000000
  br label %expf.exit

expf.exit:                                        ; preds = %80, %77, %63, %47, %15, %13, %11, %7
  %lo.i.i.3 = phi float [ %lo.i.i.0, %7 ], [ %lo.i.i.2, %63 ], [ %lo.i.i.2, %77 ], [ %lo.i.i.2, %80 ], [ %lo.i.i.0, %47 ], [ %lo.i.i.0, %13 ], [ %lo.i.i.0, %11 ], [ %lo.i.i.0, %15 ]
  %hi.i.i.3 = phi float [ %hi.i.i.0, %7 ], [ %hi.i.i.2, %63 ], [ %hi.i.i.2, %77 ], [ %hi.i.i.2, %80 ], [ %hi.i.i.0, %47 ], [ %hi.i.i.0, %13 ], [ %hi.i.i.0, %11 ], [ %hi.i.i.0, %15 ]
  %.0 = phi float [ %8, %7 ], [ %67, %63 ], [ %79, %77 ], [ %84, %80 ], [ %48, %47 ], [ 0x7FF0000000000000, %13 ], [ %., %11 ], [ 0.000000e+00, %15 ]
  %85 = fcmp ole float %.0, 0.000000e+00
  %.op = fmul float %.0, 5.000000e-01
  %86 = select i1 %85, float 0.000000e+00, float %.op
  %87 = call fastcc float @tanhf(float %86)
  %88 = fmul float %87, 5.000000e-01
  %89 = fadd float %88, 5.000000e-01
  %90 = getelementptr inbounds [8 x float]* @temp0, i64 0, i64 %fusion.indvar.dim.02
  store volatile float %89, float* %90, align 4
  %invar.inc = add nuw nsw i64 %fusion.indvar.dim.02, 1
  %exitcond = icmp eq i64 %invar.inc, 8
  br i1 %exitcond, label %fusion.loop_exit.dim.0, label %fusion.loop_body.dim.0, !llvm.loop !1

fusion.loop_exit.dim.0:                           ; preds = %expf.exit
  %leflow_retval = load volatile float* getelementptr inbounds ([8 x float]* @temp0, i64 0, i64 0), align 8
  ret float %leflow_retval
}

; Function Attrs: nounwind readnone
define internal fastcc float @expm1f(float %x) #1 {
  %1 = bitcast float %x to i32
  %2 = and i32 %1, -2147483648
  %3 = icmp eq i32 %2, 0
  br i1 %3, label %6, label %4

; <label>:4                                       ; preds = %0
  %5 = fsub float -0.000000e+00, %x
  br label %6

; <label>:6                                       ; preds = %4, %0
  %storemerge = phi float [ %5, %4 ], [ %x, %0 ]
  %7 = and i32 %1, 2147483647
  %8 = icmp ugt i32 %7, 1100331075
  br i1 %8, label %9, label %thread-pre-split

; <label>:9                                       ; preds = %6
  %10 = icmp ugt i32 %7, 2139095040
  br i1 %10, label %11, label %13

; <label>:11                                      ; preds = %9
  %12 = fadd float %x, %x
  br label %126

; <label>:13                                      ; preds = %9
  %14 = icmp eq i32 %7, 2139095040
  br i1 %14, label %15, label %16

; <label>:15                                      ; preds = %13
  %x. = select i1 %3, float %x, float -1.000000e+00
  ret float %x.

; <label>:16                                      ; preds = %13
  br i1 %3, label %17, label %.thread

; <label>:17                                      ; preds = %16
  %18 = icmp ugt i32 %7, 1118925335
  br i1 %18, label %126, label %thread-pre-split

.thread:                                          ; preds = %16
  %19 = fadd float %x, 0x39B4484C00000000
  %20 = fcmp olt float %19, 0.000000e+00
  br i1 %20, label %126, label %thread-pre-split

thread-pre-split:                                 ; preds = %.thread, %17, %6
  %21 = icmp ugt i32 %7, 1051816472
  br i1 %21, label %22, label %42

; <label>:22                                      ; preds = %thread-pre-split
  %23 = icmp ult i32 %7, 1065686418
  br i1 %23, label %24, label %29

; <label>:24                                      ; preds = %22
  br i1 %3, label %25, label %27

; <label>:25                                      ; preds = %24
  %26 = fadd float %x, 0xBFE62E3000000000
  br label %38

; <label>:27                                      ; preds = %24
  %28 = fadd float %x, 0x3FE62E3000000000
  br label %38

; <label>:29                                      ; preds = %22
  %30 = fmul float %x, 0x3FF7154760000000
  %31 = select i1 %3, float 5.000000e-01, float -5.000000e-01
  %32 = fadd float %30, %31
  %33 = fptosi float %32 to i32
  %34 = sitofp i32 %33 to float
  %35 = fmul float %34, 0x3FE62E3000000000
  %36 = fsub float %x, %35
  %37 = fmul float %34, 0x3EE2FEFA20000000
  br label %38

; <label>:38                                      ; preds = %29, %27, %25
  %k.0 = phi i32 [ %33, %29 ], [ -1, %27 ], [ 1, %25 ]
  %lo.0 = phi float [ %37, %29 ], [ 0xBEE2FEFA20000000, %27 ], [ 0x3EE2FEFA20000000, %25 ]
  %hi.0 = phi float [ %36, %29 ], [ %28, %27 ], [ %26, %25 ]
  %39 = fsub float %hi.0, %lo.0
  %40 = fsub float %hi.0, %39
  %41 = fsub float %40, %lo.0
  br label %48

; <label>:42                                      ; preds = %thread-pre-split
  %43 = icmp ult i32 %7, 855638016
  br i1 %43, label %44, label %48

; <label>:44                                      ; preds = %42
  %45 = fadd float %x, 0x46293E5940000000
  %46 = fsub float %45, %45
  %47 = fsub float %x, %46
  br label %126

; <label>:48                                      ; preds = %42, %38
  %k.1 = phi i32 [ %k.0, %38 ], [ 0, %42 ]
  %c.0 = phi float [ %41, %38 ], [ undef, %42 ]
  %.062 = phi float [ %39, %38 ], [ %x, %42 ]
  %49 = fmul float %.062, 5.000000e-01
  %50 = fmul float %.062, %49
  %51 = fmul float %50, 0xBE8AFDB760000000
  %52 = fadd float %51, 0x3ED0CFCA80000000
  %53 = fmul float %50, %52
  %54 = fadd float %53, 0xBF14CE19A0000000
  %55 = fmul float %50, %54
  %56 = fadd float %55, 0x3F5A01A020000000
  %57 = fmul float %50, %56
  %58 = fadd float %57, 0xBFA1111120000000
  %59 = fmul float %50, %58
  %60 = fadd float %59, 1.000000e+00
  %61 = fmul float %60, %49
  %62 = fsub float 3.000000e+00, %61
  %63 = fsub float %60, %62
  %64 = fmul float %.062, %62
  %65 = fsub float 6.000000e+00, %64
  %66 = fdiv float %63, %65
  %67 = fmul float %50, %66
  %68 = icmp eq i32 %k.1, 0
  br i1 %68, label %69, label %73

; <label>:69                                      ; preds = %48
  %70 = fmul float %.062, %67
  %71 = fsub float %70, %50
  %72 = fsub float %.062, %71
  br label %126

; <label>:73                                      ; preds = %48
  %74 = fsub float %67, %c.0
  %75 = fmul float %.062, %74
  %76 = fsub float %75, %c.0
  %77 = fsub float %76, %50
  switch i32 %k.1, label %92 [
    i32 -1, label %78
    i32 1, label %82
  ]

; <label>:78                                      ; preds = %73
  %79 = fsub float %.062, %77
  %80 = fmul float %79, 5.000000e-01
  %81 = fadd float %80, -5.000000e-01
  br label %126

; <label>:82                                      ; preds = %73
  %83 = fcmp olt float %.062, -2.500000e-01
  br i1 %83, label %84, label %88

; <label>:84                                      ; preds = %82
  %85 = fadd float %.062, 5.000000e-01
  %86 = fsub float %77, %85
  %87 = fmul float %86, -2.000000e+00
  br label %126

; <label>:88                                      ; preds = %82
  %89 = fsub float %.062, %77
  %90 = fmul float %89, 2.000000e+00
  %91 = fadd float %90, 1.000000e+00
  br label %126

; <label>:92                                      ; preds = %73
  %93 = icmp slt i32 %k.1, -1
  %94 = icmp sgt i32 %k.1, 56
  %or.cond = or i1 %93, %94
  br i1 %or.cond, label %95, label %103

; <label>:95                                      ; preds = %92
  %96 = fsub float %77, %.062
  %97 = fsub float 1.000000e+00, %96
  %98 = bitcast float %97 to i32
  %99 = shl i32 %k.1, 23
  %100 = add nsw i32 %98, %99
  %101 = bitcast i32 %100 to float
  %102 = fadd float %101, -1.000000e+00
  br label %126

; <label>:103                                     ; preds = %92
  %104 = icmp slt i32 %k.1, 23
  br i1 %104, label %105, label %115

; <label>:105                                     ; preds = %103
  %106 = lshr i32 16777216, %k.1
  %107 = sub nsw i32 1065353216, %106
  %108 = bitcast i32 %107 to float
  %109 = fsub float %77, %.062
  %110 = fsub float %108, %109
  %111 = bitcast float %110 to i32
  %112 = shl i32 %k.1, 23
  %113 = add nsw i32 %111, %112
  %114 = bitcast i32 %113 to float
  br label %126

; <label>:115                                     ; preds = %103
  %116 = sub nsw i32 127, %k.1
  %117 = shl i32 %116, 23
  %118 = bitcast i32 %117 to float
  %119 = fadd float %77, %118
  %120 = fsub float %.062, %119
  %121 = fadd float %120, 1.000000e+00
  %122 = bitcast float %121 to i32
  %123 = shl i32 %k.1, 23
  %124 = add nsw i32 %122, %123
  %125 = bitcast i32 %124 to float
  br label %126

; <label>:126                                     ; preds = %115, %105, %95, %88, %84, %78, %69, %44, %.thread, %17, %11
  %.0 = phi float [ %12, %11 ], [ %72, %69 ], [ %81, %78 ], [ %87, %84 ], [ %91, %88 ], [ %102, %95 ], [ %47, %44 ], [ 0x7FF0000000000000, %17 ], [ -1.000000e+00, %.thread ], [ %114, %105 ], [ %125, %115 ]
  ret float %.0
}

; Function Attrs: nounwind readnone
define internal fastcc float @tanhf(float %x) #1 {
  %1 = bitcast float %x to i32
  %2 = and i32 %1, 2147483647
  %3 = icmp ult i32 %2, 2139095040
  br i1 %3, label %11, label %4

; <label>:4                                       ; preds = %0
  %5 = icmp sgt i32 %1, -1
  %6 = fdiv float 1.000000e+00, %x
  br i1 %5, label %7, label %9

; <label>:7                                       ; preds = %4
  %8 = fadd float %6, 1.000000e+00
  br label %37

; <label>:9                                       ; preds = %4
  %10 = fadd float %6, -1.000000e+00
  br label %37

; <label>:11                                      ; preds = %0
  %12 = icmp slt i32 %2, 1102053376
  br i1 %12, label %13, label %33

; <label>:13                                      ; preds = %11
  %14 = icmp slt i32 %2, 603979776
  br i1 %14, label %15, label %18

; <label>:15                                      ; preds = %13
  %16 = fadd float %x, 1.000000e+00
  %17 = fmul float %x, %16
  br label %37

; <label>:18                                      ; preds = %13
  %19 = icmp sgt i32 %2, 1065353215
  %20 = bitcast i32 %2 to float
  br i1 %19, label %21, label %27

; <label>:21                                      ; preds = %18
  %22 = fmul float %20, 2.000000e+00
  %23 = call fastcc float @expm1f(float %22) #2
  %24 = fadd float %23, 2.000000e+00
  %25 = fdiv float 2.000000e+00, %24
  %26 = fsub float 1.000000e+00, %25
  br label %33

; <label>:27                                      ; preds = %18
  %28 = fmul float %20, -2.000000e+00
  %29 = call fastcc float @expm1f(float %28) #2
  %30 = fsub float -0.000000e+00, %29
  %31 = fadd float %29, 2.000000e+00
  %32 = fdiv float %30, %31
  br label %33

; <label>:33                                      ; preds = %27, %21, %11
  %storemerge1 = phi float [ %32, %27 ], [ %26, %21 ], [ 1.000000e+00, %11 ]
  %34 = icmp sgt i32 %1, -1
  br i1 %34, label %37, label %35

; <label>:35                                      ; preds = %33
  %36 = fsub float -0.000000e+00, %storemerge1
  br label %37

; <label>:37                                      ; preds = %35, %33, %15, %9, %7
  %.0 = phi float [ %17, %15 ], [ %8, %7 ], [ %10, %9 ], [ %36, %35 ], [ %storemerge1, %33 ]
  ret float %.0
}

attributes #0 = { nounwind "no-frame-pointer-elim"="false" }
attributes #1 = { nounwind readnone "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { nobuiltin nounwind }

!llvm.ident = !{!0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0}

!0 = metadata !{metadata !"clang version 3.5.0 (tags/RELEASE_350/final)"}
!1 = metadata !{metadata !1, metadata !2}
!2 = metadata !{metadata !"llvm.loop.vectorize.enable", i1 false}
