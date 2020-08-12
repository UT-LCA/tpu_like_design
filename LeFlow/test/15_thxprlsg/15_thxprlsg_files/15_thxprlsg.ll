; ModuleID = '15_thxprlsg.bc'
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
  %fusion.indvar.dim.02 = phi i64 [ 0, %fusion.loop_body.dim.0.lr.ph ], [ %87, %expf.exit ]
  %scevgep = getelementptr [8 x float]* @temp0, i64 0, i64 %fusion.indvar.dim.02
  %scevgep2 = getelementptr [8 x float]* @param0, i64 0, i64 %fusion.indvar.dim.02
  %0 = load volatile float* %scevgep2, align 4
  %1 = call fastcc float @tanhf(float %0)
  %2 = bitcast float %1 to i32
  %3 = lshr i32 %2, 31
  %4 = and i32 %2, 2147483647
  %5 = icmp ugt i32 %4, 2139095040
  br i1 %5, label %6, label %8

; <label>:6                                       ; preds = %fusion.loop_body.dim.0
  %7 = fadd float %1, %1
  br label %expf.exit

; <label>:8                                       ; preds = %fusion.loop_body.dim.0
  %9 = icmp eq i32 %4, 2139095040
  br i1 %9, label %10, label %12

; <label>:10                                      ; preds = %8
  %11 = icmp eq i32 %3, 0
  %. = select i1 %11, float %1, float 0.000000e+00
  br label %expf.exit

; <label>:12                                      ; preds = %8
  %13 = icmp sgt i32 %2, 1118925335
  br i1 %13, label %expf.exit, label %14

; <label>:14                                      ; preds = %12
  %15 = icmp slt i32 %2, 0
  %16 = icmp ugt i32 %4, 1120924085
  %or.cond = and i1 %15, %16
  br i1 %or.cond, label %expf.exit, label %thread-pre-split

thread-pre-split:                                 ; preds = %14
  %17 = icmp ugt i32 %4, 1051816472
  br i1 %17, label %18, label %40

; <label>:18                                      ; preds = %thread-pre-split
  %19 = icmp ult i32 %4, 1065686418
  br i1 %19, label %20, label %28

; <label>:20                                      ; preds = %18
  %21 = zext i32 %3 to i64
  %22 = getelementptr inbounds [2 x float]* @ln2HI31, i64 0, i64 %21
  %23 = load float* %22, align 4
  %24 = getelementptr inbounds [2 x float]* @ln2LO32, i64 0, i64 %21
  %25 = load float* %24, align 4
  %26 = xor i32 %3, 1
  %27 = sub nsw i32 %26, %3
  br label %38

; <label>:28                                      ; preds = %18
  %29 = fmul float %1, 0x3FF7154760000000
  %30 = zext i32 %3 to i64
  %31 = getelementptr inbounds [2 x float]* @halF33, i64 0, i64 %30
  %32 = load float* %31, align 4
  %33 = fadd float %29, %32
  %34 = fptosi float %33 to i32
  %35 = sitofp i32 %34 to float
  %36 = fmul float %35, 0x3FE62E3000000000
  %37 = fmul float %35, 0x3EE2FEFA20000000
  br label %38

; <label>:38                                      ; preds = %28, %20
  %k.i.i.0 = phi i32 [ %27, %20 ], [ %34, %28 ]
  %lo.i.i.1 = phi float [ %25, %20 ], [ %37, %28 ]
  %.pn = phi float [ %23, %20 ], [ %36, %28 ]
  %hi.i.i.1 = fsub float %1, %.pn
  %39 = fsub float %hi.i.i.1, %lo.i.i.1
  br label %46

; <label>:40                                      ; preds = %thread-pre-split
  %41 = icmp ult i32 %4, 830472192
  %42 = fadd float %1, 0x46293E5940000000
  %43 = fcmp ogt float %42, 1.000000e+00
  %or.cond50 = and i1 %41, %43
  br i1 %or.cond50, label %44, label %46

; <label>:44                                      ; preds = %40
  %45 = fadd float %1, 1.000000e+00
  br label %expf.exit

; <label>:46                                      ; preds = %40, %38
  %k.i.i.1 = phi i32 [ %k.i.i.0, %38 ], [ 0, %40 ]
  %lo.i.i.2 = phi float [ %lo.i.i.1, %38 ], [ %lo.i.i.0, %40 ]
  %hi.i.i.2 = phi float [ %hi.i.i.1, %38 ], [ %hi.i.i.0, %40 ]
  %.048 = phi float [ %39, %38 ], [ %1, %40 ]
  %47 = fmul float %.048, %.048
  %48 = fmul float %47, 0x3E66376980000000
  %49 = fadd float %48, 0xBEBBBD41C0000000
  %50 = fmul float %47, %49
  %51 = fadd float %50, 0x3F11566AA0000000
  %52 = fmul float %47, %51
  %53 = fadd float %52, 0xBF66C16C20000000
  %54 = fmul float %47, %53
  %55 = fadd float %54, 0x3FC5555560000000
  %56 = fmul float %47, %55
  %57 = fsub float %.048, %56
  %58 = icmp eq i32 %k.i.i.1, 0
  %59 = fmul float %.048, %57
  br i1 %58, label %60, label %65

; <label>:60                                      ; preds = %46
  %61 = fadd float %57, -2.000000e+00
  %62 = fdiv float %59, %61
  %63 = fsub float %62, %.048
  %64 = fsub float 1.000000e+00, %63
  br label %expf.exit

; <label>:65                                      ; preds = %46
  %66 = fsub float 2.000000e+00, %57
  %67 = fdiv float %59, %66
  %68 = fsub float %lo.i.i.2, %67
  %69 = fsub float %68, %hi.i.i.2
  %70 = fsub float 1.000000e+00, %69
  %71 = icmp sgt i32 %k.i.i.1, -126
  %72 = bitcast float %70 to i32
  %73 = shl i32 %k.i.i.1, 23
  br i1 %71, label %74, label %77

; <label>:74                                      ; preds = %65
  %75 = add i32 %72, %73
  %76 = bitcast i32 %75 to float
  br label %expf.exit

; <label>:77                                      ; preds = %65
  %78 = add i32 %73, 838860800
  %79 = add i32 %72, %78
  %80 = bitcast i32 %79 to float
  %81 = fmul float %80, 0x39B0000000000000
  br label %expf.exit

expf.exit:                                        ; preds = %77, %74, %60, %44, %14, %12, %10, %6
  %lo.i.i.3 = phi float [ %lo.i.i.0, %6 ], [ %lo.i.i.2, %60 ], [ %lo.i.i.2, %74 ], [ %lo.i.i.2, %77 ], [ %lo.i.i.0, %44 ], [ %lo.i.i.0, %12 ], [ %lo.i.i.0, %10 ], [ %lo.i.i.0, %14 ]
  %hi.i.i.3 = phi float [ %hi.i.i.0, %6 ], [ %hi.i.i.2, %60 ], [ %hi.i.i.2, %74 ], [ %hi.i.i.2, %77 ], [ %hi.i.i.0, %44 ], [ %hi.i.i.0, %12 ], [ %hi.i.i.0, %10 ], [ %hi.i.i.0, %14 ]
  %.0 = phi float [ %7, %6 ], [ %64, %60 ], [ %76, %74 ], [ %81, %77 ], [ %45, %44 ], [ 0x7FF0000000000000, %12 ], [ %., %10 ], [ 0.000000e+00, %14 ]
  %82 = fcmp ole float %.0, 0.000000e+00
  %.op = fmul float %.0, 5.000000e-01
  %83 = select i1 %82, float 0.000000e+00, float %.op
  %84 = call fastcc float @tanhf(float %83)
  %85 = fmul float %84, 5.000000e-01
  %86 = fadd float %85, 5.000000e-01
  store volatile float %86, float* %scevgep, align 4
  %87 = add nuw nsw i64 %fusion.indvar.dim.02, 1
  %exitcond1 = icmp eq i64 %87, 8
  br i1 %exitcond1, label %fusion.loop_exit.dim.0, label %fusion.loop_body.dim.0, !llvm.loop !1

fusion.loop_exit.dim.0:                           ; preds = %expf.exit
  %leflow_retval = load volatile float* getelementptr inbounds ([8 x float]* @temp0, i64 0, i64 0), align 8
  ret float %leflow_retval
}

; Function Attrs: nounwind readnone
define internal fastcc float @expm1f(float %x) #1 {
  %1 = bitcast float %x to i32
  %2 = icmp sgt i32 %1, -1
  br i1 %2, label %4, label %3

; <label>:3                                       ; preds = %0
  br label %4

; <label>:4                                       ; preds = %3, %0
  %5 = and i32 %1, 2147483647
  %6 = icmp ugt i32 %5, 1100331075
  br i1 %6, label %7, label %thread-pre-split

; <label>:7                                       ; preds = %4
  %8 = icmp ugt i32 %5, 2139095040
  br i1 %8, label %9, label %11

; <label>:9                                       ; preds = %7
  %10 = fadd float %x, %x
  br label %123

; <label>:11                                      ; preds = %7
  %12 = icmp eq i32 %5, 2139095040
  br i1 %12, label %13, label %14

; <label>:13                                      ; preds = %11
  %x. = select i1 %2, float %x, float -1.000000e+00
  ret float %x.

; <label>:14                                      ; preds = %11
  br i1 %2, label %15, label %.thread

; <label>:15                                      ; preds = %14
  %16 = icmp ugt i32 %5, 1118925335
  br i1 %16, label %123, label %thread-pre-split

.thread:                                          ; preds = %14
  %17 = fadd float %x, 0x39B4484C00000000
  %18 = fcmp olt float %17, 0.000000e+00
  br i1 %18, label %123, label %thread-pre-split

thread-pre-split:                                 ; preds = %.thread, %15, %4
  %19 = icmp ugt i32 %5, 1051816472
  br i1 %19, label %20, label %40

; <label>:20                                      ; preds = %thread-pre-split
  %21 = icmp ult i32 %5, 1065686418
  br i1 %21, label %22, label %27

; <label>:22                                      ; preds = %20
  br i1 %2, label %23, label %25

; <label>:23                                      ; preds = %22
  %24 = fadd float %x, 0xBFE62E3000000000
  br label %36

; <label>:25                                      ; preds = %22
  %26 = fadd float %x, 0x3FE62E3000000000
  br label %36

; <label>:27                                      ; preds = %20
  %28 = fmul float %x, 0x3FF7154760000000
  %29 = select i1 %2, float 5.000000e-01, float -5.000000e-01
  %30 = fadd float %28, %29
  %31 = fptosi float %30 to i32
  %32 = sitofp i32 %31 to float
  %33 = fmul float %32, 0x3FE62E3000000000
  %34 = fsub float %x, %33
  %35 = fmul float %32, 0x3EE2FEFA20000000
  br label %36

; <label>:36                                      ; preds = %27, %25, %23
  %k.0 = phi i32 [ %31, %27 ], [ -1, %25 ], [ 1, %23 ]
  %lo.0 = phi float [ %35, %27 ], [ 0xBEE2FEFA20000000, %25 ], [ 0x3EE2FEFA20000000, %23 ]
  %hi.0 = phi float [ %34, %27 ], [ %26, %25 ], [ %24, %23 ]
  %37 = fsub float %hi.0, %lo.0
  %38 = fsub float %hi.0, %37
  %39 = fsub float %38, %lo.0
  br label %46

; <label>:40                                      ; preds = %thread-pre-split
  %41 = icmp ult i32 %5, 855638016
  br i1 %41, label %42, label %46

; <label>:42                                      ; preds = %40
  %43 = fadd float %x, 0x46293E5940000000
  %44 = fsub float %43, %43
  %45 = fsub float %x, %44
  br label %123

; <label>:46                                      ; preds = %40, %36
  %k.1 = phi i32 [ %k.0, %36 ], [ 0, %40 ]
  %c.0 = phi float [ %39, %36 ], [ undef, %40 ]
  %.062 = phi float [ %37, %36 ], [ %x, %40 ]
  %47 = fmul float %.062, 5.000000e-01
  %48 = fmul float %.062, %47
  %49 = fmul float %48, 0xBE8AFDB760000000
  %50 = fadd float %49, 0x3ED0CFCA80000000
  %51 = fmul float %48, %50
  %52 = fadd float %51, 0xBF14CE19A0000000
  %53 = fmul float %48, %52
  %54 = fadd float %53, 0x3F5A01A020000000
  %55 = fmul float %48, %54
  %56 = fadd float %55, 0xBFA1111120000000
  %57 = fmul float %48, %56
  %58 = fadd float %57, 1.000000e+00
  %59 = fmul float %58, %47
  %60 = fsub float 3.000000e+00, %59
  %61 = fsub float %58, %60
  %62 = fmul float %.062, %60
  %63 = fsub float 6.000000e+00, %62
  %64 = fdiv float %61, %63
  %65 = fmul float %48, %64
  %66 = icmp eq i32 %k.1, 0
  br i1 %66, label %67, label %71

; <label>:67                                      ; preds = %46
  %68 = fmul float %.062, %65
  %69 = fsub float %68, %48
  %70 = fsub float %.062, %69
  br label %123

; <label>:71                                      ; preds = %46
  %72 = fsub float %65, %c.0
  %73 = fmul float %.062, %72
  %74 = fsub float %73, %c.0
  %75 = fsub float %74, %48
  switch i32 %k.1, label %90 [
    i32 -1, label %76
    i32 1, label %80
  ]

; <label>:76                                      ; preds = %71
  %77 = fsub float %.062, %75
  %78 = fmul float %77, 5.000000e-01
  %79 = fadd float %78, -5.000000e-01
  br label %123

; <label>:80                                      ; preds = %71
  %81 = fcmp olt float %.062, -2.500000e-01
  br i1 %81, label %82, label %86

; <label>:82                                      ; preds = %80
  %83 = fadd float %.062, 5.000000e-01
  %84 = fsub float %75, %83
  %85 = fmul float %84, -2.000000e+00
  br label %123

; <label>:86                                      ; preds = %80
  %87 = fsub float %.062, %75
  %88 = fmul float %87, 2.000000e+00
  %89 = fadd float %88, 1.000000e+00
  br label %123

; <label>:90                                      ; preds = %71
  %k.1.off = add i32 %k.1, 1
  %91 = icmp ugt i32 %k.1.off, 57
  br i1 %91, label %92, label %100

; <label>:92                                      ; preds = %90
  %93 = fsub float %75, %.062
  %94 = fsub float 1.000000e+00, %93
  %95 = bitcast float %94 to i32
  %96 = shl i32 %k.1, 23
  %97 = add nsw i32 %95, %96
  %98 = bitcast i32 %97 to float
  %99 = fadd float %98, -1.000000e+00
  br label %123

; <label>:100                                     ; preds = %90
  %101 = icmp slt i32 %k.1, 23
  br i1 %101, label %102, label %112

; <label>:102                                     ; preds = %100
  %103 = lshr i32 16777216, %k.1
  %104 = sub nsw i32 1065353216, %103
  %105 = bitcast i32 %104 to float
  %106 = fsub float %75, %.062
  %107 = fsub float %105, %106
  %108 = bitcast float %107 to i32
  %109 = shl i32 %k.1, 23
  %110 = add nsw i32 %108, %109
  %111 = bitcast i32 %110 to float
  br label %123

; <label>:112                                     ; preds = %100
  %113 = sub nsw i32 127, %k.1
  %114 = shl i32 %113, 23
  %115 = bitcast i32 %114 to float
  %116 = fadd float %75, %115
  %117 = fsub float %.062, %116
  %118 = fadd float %117, 1.000000e+00
  %119 = bitcast float %118 to i32
  %120 = shl i32 %k.1, 23
  %121 = add nsw i32 %119, %120
  %122 = bitcast i32 %121 to float
  br label %123

; <label>:123                                     ; preds = %112, %102, %92, %86, %82, %76, %67, %42, %.thread, %15, %9
  %.0 = phi float [ %10, %9 ], [ %70, %67 ], [ %79, %76 ], [ %85, %82 ], [ %89, %86 ], [ %99, %92 ], [ %45, %42 ], [ 0x7FF0000000000000, %15 ], [ -1.000000e+00, %.thread ], [ %111, %102 ], [ %122, %112 ]
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
  %12 = icmp ult i32 %2, 1102053376
  br i1 %12, label %13, label %33

; <label>:13                                      ; preds = %11
  %14 = icmp ult i32 %2, 603979776
  br i1 %14, label %15, label %18

; <label>:15                                      ; preds = %13
  %16 = fadd float %x, 1.000000e+00
  %17 = fmul float %16, %x
  br label %37

; <label>:18                                      ; preds = %13
  %19 = icmp ugt i32 %2, 1065353215
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
