; ModuleID = 'classificationMNIST.postlto.8.bc'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux_gnu"

%union.ieee_float_shape_type = type { float }

@temp3 = internal global [10 x float] zeroinitializer, align 8
@temp1 = internal unnamed_addr global [1 x [10 x float]] zeroinitializer, align 8
@temp0 = internal unnamed_addr global [1 x [10 x float]] zeroinitializer, align 8
@param2 = internal global [1 x [784 x float]] zeroinitializer, align 8
@param1 = internal global [784 x [10 x float]] zeroinitializer, align 8
@param0 = internal global [10 x float] zeroinitializer, align 8
@ln2HI31 = internal constant [2 x float] [float 0x3FE62E3000000000, float 0xBFE62E3000000000], align 4
@ln2LO32 = internal constant [2 x float] [float 0x3EE2FEFA20000000, float 0xBEE2FEFA20000000], align 4
@halF33 = internal constant [2 x float] [float 5.000000e-01, float -5.000000e-01], align 4

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
  %.lcssa2 = phi float [ %6, %dot.loop_body.reduction ]
  %7 = getelementptr inbounds [1 x [10 x float]]* @temp0, i64 0, i64 0, i64 %dot.indvar.rhs.122
  store float %.lcssa2, float* %7, align 4
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
  br i1 %exitcond8, label %fusion.1.loop_body.dim.1.lr.ph, label %reduce.inner.loop_body.reduction_dim.1, !llvm.loop !5

fusion.1.loop_body.dim.1.lr.ph:                   ; preds = %reduce.inner.loop_body.reduction_dim.1
  %.lcssa1 = phi float [ %20, %reduce.inner.loop_body.reduction_dim.1 ]
  br label %fusion.1.loop_body.dim.1

fusion.1.loop_body.dim.1:                         ; preds = %fusion.1.loop_body.dim.1, %fusion.1.loop_body.dim.1.lr.ph
  %fusion.1.indvar.dim.18 = phi i64 [ 0, %fusion.1.loop_body.dim.1.lr.ph ], [ %invar.inc8, %fusion.1.loop_body.dim.1 ]
  %21 = getelementptr inbounds [1 x [10 x float]]* @temp0, i64 0, i64 0, i64 %fusion.1.indvar.dim.18
  %22 = load float* %21, align 4
  %23 = getelementptr inbounds [10 x float]* @param0, i64 0, i64 %fusion.1.indvar.dim.18
  %24 = load volatile float* %23, align 4
  %25 = fadd float %22, %24
  %26 = fsub float %25, %.lcssa1
  %27 = call float @expf(float %26)
  %28 = getelementptr inbounds [1 x [10 x float]]* @temp1, i64 0, i64 0, i64 %fusion.1.indvar.dim.18
  store float %27, float* %28, align 4
  %invar.inc8 = add nuw nsw i64 %fusion.1.indvar.dim.18, 1
  %exitcond7 = icmp eq i64 %invar.inc8, 10
  br i1 %exitcond7, label %reduce.1.inner.loop_body.reduction_dim.1, label %fusion.1.loop_body.dim.1, !llvm.loop !6

reduce.1.inner.loop_body.reduction_dim.1:         ; preds = %reduce.1.inner.loop_body.reduction_dim.1, %fusion.1.loop_body.dim.1
  %29 = phi float [ %32, %reduce.1.inner.loop_body.reduction_dim.1 ], [ 0.000000e+00, %fusion.1.loop_body.dim.1 ]
  %reduce.1.inner.indvar.reduction_dim.14 = phi i64 [ %invar.inc11, %reduce.1.inner.loop_body.reduction_dim.1 ], [ 0, %fusion.1.loop_body.dim.1 ]
  %30 = getelementptr inbounds [1 x [10 x float]]* @temp1, i64 0, i64 0, i64 %reduce.1.inner.indvar.reduction_dim.14
  %31 = load float* %30, align 4
  %32 = fadd float %29, %31
  %invar.inc11 = add nuw nsw i64 %reduce.1.inner.indvar.reduction_dim.14, 1
  %exitcond6 = icmp eq i64 %invar.inc11, 10
  br i1 %exitcond6, label %fusion.loop_body.dim.0.lr.ph, label %reduce.1.inner.loop_body.reduction_dim.1, !llvm.loop !7

fusion.loop_body.dim.0.lr.ph:                     ; preds = %reduce.1.inner.loop_body.reduction_dim.1
  %.lcssa = phi float [ %32, %reduce.1.inner.loop_body.reduction_dim.1 ]
  br label %fusion.loop_body.dim.0

fusion.loop_body.dim.0:                           ; preds = %fusion.loop_body.dim.0, %fusion.loop_body.dim.0.lr.ph
  %fusion.indvar.dim.02 = phi i64 [ 0, %fusion.loop_body.dim.0.lr.ph ], [ %invar.inc17, %fusion.loop_body.dim.0 ]
  %33 = getelementptr inbounds [1 x [10 x float]]* @temp1, i64 0, i64 0, i64 %fusion.indvar.dim.02
  %34 = load float* %33, align 4
  %35 = fdiv float %34, %.lcssa
  %36 = getelementptr inbounds [10 x float]* @temp3, i64 0, i64 %fusion.indvar.dim.02
  store volatile float %35, float* %36, align 4
  %invar.inc17 = add nuw nsw i64 %fusion.indvar.dim.02, 1
  %exitcond = icmp eq i64 %invar.inc17, 10
  br i1 %exitcond, label %fusion.loop_exit.dim.0, label %fusion.loop_body.dim.0, !llvm.loop !8

fusion.loop_exit.dim.0:                           ; preds = %fusion.loop_body.dim.0
  %leflow_retval = load volatile float* getelementptr inbounds ([10 x float]* @temp3, i64 0, i64 0), align 4
  ret float %leflow_retval
}

; Function Attrs: nounwind
define internal float @__ieee754_expf(float %x) #1 {
  %1 = alloca float, align 4
  %2 = alloca float, align 4
  %y = alloca float, align 4
  %hi = alloca float, align 4
  %lo = alloca float, align 4
  %c = alloca float, align 4
  %t = alloca float, align 4
  %k = alloca i32, align 4
  %xsb = alloca i32, align 4
  %sx = alloca i32, align 4
  %hx = alloca i32, align 4
  %gf_u = alloca %union.ieee_float_shape_type, align 4
  %hy = alloca i32, align 4
  %gf_u1 = alloca %union.ieee_float_shape_type, align 4
  %sf_u = alloca %union.ieee_float_shape_type, align 4
  %hy2 = alloca i32, align 4
  %gf_u3 = alloca %union.ieee_float_shape_type, align 4
  %sf_u4 = alloca %union.ieee_float_shape_type, align 4
  store float %x, float* %2, align 4
  store i32 0, i32* %k, align 4
  br label %3

; <label>:3                                       ; preds = %0
  %4 = load float* %2, align 4
  %5 = bitcast %union.ieee_float_shape_type* %gf_u to float*
  store float %4, float* %5, align 4
  %6 = bitcast %union.ieee_float_shape_type* %gf_u to i32*
  %7 = load i32* %6, align 4
  store i32 %7, i32* %sx, align 4
  br label %8

; <label>:8                                       ; preds = %3
  %9 = load i32* %sx, align 4
  %10 = ashr i32 %9, 31
  %11 = and i32 %10, 1
  store i32 %11, i32* %xsb, align 4
  %12 = load i32* %sx, align 4
  %13 = and i32 %12, 2147483647
  store i32 %13, i32* %hx, align 4
  %14 = load i32* %hx, align 4
  %15 = icmp ugt i32 %14, 2139095040
  br i1 %15, label %16, label %20

; <label>:16                                      ; preds = %8
  %17 = load float* %2, align 4
  %18 = load float* %2, align 4
  %19 = fadd float %17, %18
  store float %19, float* %1
  br label %180

; <label>:20                                      ; preds = %8
  %21 = load i32* %hx, align 4
  %22 = icmp eq i32 %21, 2139095040
  br i1 %22, label %23, label %33

; <label>:23                                      ; preds = %20
  %24 = load i32* %xsb, align 4
  %25 = icmp eq i32 %24, 0
  br i1 %25, label %26, label %29

; <label>:26                                      ; preds = %23
  %27 = load float* %2, align 4
  %28 = fpext float %27 to double
  br label %30

; <label>:29                                      ; preds = %23
  br label %30

; <label>:30                                      ; preds = %29, %26
  %31 = phi double [ %28, %26 ], [ 0.000000e+00, %29 ]
  %32 = fptrunc double %31 to float
  store float %32, float* %1
  br label %180

; <label>:33                                      ; preds = %20
  %34 = load i32* %sx, align 4
  %35 = icmp sgt i32 %34, 1118925335
  br i1 %35, label %36, label %37

; <label>:36                                      ; preds = %33
  store float 0x7FF0000000000000, float* %1
  br label %180

; <label>:37                                      ; preds = %33
  %38 = load i32* %sx, align 4
  %39 = icmp slt i32 %38, 0
  br i1 %39, label %40, label %44

; <label>:40                                      ; preds = %37
  %41 = load i32* %hx, align 4
  %42 = icmp ugt i32 %41, 1120924085
  br i1 %42, label %43, label %44

; <label>:43                                      ; preds = %40
  store float 0.000000e+00, float* %1
  br label %180

; <label>:44                                      ; preds = %40, %37
  %45 = load i32* %hx, align 4
  %46 = icmp ugt i32 %45, 1051816472
  br i1 %46, label %47, label %85

; <label>:47                                      ; preds = %44
  %48 = load i32* %hx, align 4
  %49 = icmp ult i32 %48, 1065686418
  br i1 %49, label %50, label %63

; <label>:50                                      ; preds = %47
  %51 = load float* %2, align 4
  %52 = load i32* %xsb, align 4
  %53 = getelementptr inbounds [2 x float]* @ln2HI31, i32 0, i32 %52
  %54 = load float* %53, align 4
  %55 = fsub float %51, %54
  store float %55, float* %hi, align 4
  %56 = load i32* %xsb, align 4
  %57 = getelementptr inbounds [2 x float]* @ln2LO32, i32 0, i32 %56
  %58 = load float* %57, align 4
  store float %58, float* %lo, align 4
  %59 = load i32* %xsb, align 4
  %60 = sub nsw i32 1, %59
  %61 = load i32* %xsb, align 4
  %62 = sub nsw i32 %60, %61
  store i32 %62, i32* %k, align 4
  br label %81

; <label>:63                                      ; preds = %47
  %64 = load float* %2, align 4
  %65 = fmul float 0x3FF7154760000000, %64
  %66 = load i32* %xsb, align 4
  %67 = getelementptr inbounds [2 x float]* @halF33, i32 0, i32 %66
  %68 = load float* %67, align 4
  %69 = fadd float %65, %68
  %70 = fptosi float %69 to i32
  store i32 %70, i32* %k, align 4
  %71 = load i32* %k, align 4
  %72 = sitofp i32 %71 to float
  store float %72, float* %t, align 4
  %73 = load float* %2, align 4
  %74 = load float* %t, align 4
  %75 = load float* getelementptr inbounds ([2 x float]* @ln2HI31, i32 0, i32 0), align 4
  %76 = fmul float %74, %75
  %77 = fsub float %73, %76
  store float %77, float* %hi, align 4
  %78 = load float* %t, align 4
  %79 = load float* getelementptr inbounds ([2 x float]* @ln2LO32, i32 0, i32 0), align 4
  %80 = fmul float %78, %79
  store float %80, float* %lo, align 4
  br label %81

; <label>:81                                      ; preds = %63, %50
  %82 = load float* %hi, align 4
  %83 = load float* %lo, align 4
  %84 = fsub float %82, %83
  store float %84, float* %2, align 4
  br label %97

; <label>:85                                      ; preds = %44
  %86 = load i32* %hx, align 4
  %87 = icmp ult i32 %86, 830472192
  br i1 %87, label %88, label %96

; <label>:88                                      ; preds = %85
  %89 = load float* %2, align 4
  %90 = fadd float 0x46293E5940000000, %89
  %91 = fcmp ogt float %90, 1.000000e+00
  br i1 %91, label %92, label %95

; <label>:92                                      ; preds = %88
  %93 = load float* %2, align 4
  %94 = fadd float 1.000000e+00, %93
  store float %94, float* %1
  br label %180

; <label>:95                                      ; preds = %88
  br label %96

; <label>:96                                      ; preds = %95, %85
  br label %97

; <label>:97                                      ; preds = %96, %81
  %98 = load float* %2, align 4
  %99 = load float* %2, align 4
  %100 = fmul float %98, %99
  store float %100, float* %t, align 4
  %101 = load float* %2, align 4
  %102 = load float* %t, align 4
  %103 = load float* %t, align 4
  %104 = load float* %t, align 4
  %105 = load float* %t, align 4
  %106 = load float* %t, align 4
  %107 = fmul float %106, 0x3E66376980000000
  %108 = fadd float 0xBEBBBD41C0000000, %107
  %109 = fmul float %105, %108
  %110 = fadd float 0x3F11566AA0000000, %109
  %111 = fmul float %104, %110
  %112 = fadd float 0xBF66C16C20000000, %111
  %113 = fmul float %103, %112
  %114 = fadd float 0x3FC5555560000000, %113
  %115 = fmul float %102, %114
  %116 = fsub float %101, %115
  store float %116, float* %c, align 4
  %117 = load i32* %k, align 4
  %118 = icmp eq i32 %117, 0
  br i1 %118, label %119, label %129

; <label>:119                                     ; preds = %97
  %120 = load float* %2, align 4
  %121 = load float* %c, align 4
  %122 = fmul float %120, %121
  %123 = load float* %c, align 4
  %124 = fsub float %123, 2.000000e+00
  %125 = fdiv float %122, %124
  %126 = load float* %2, align 4
  %127 = fsub float %125, %126
  %128 = fsub float 1.000000e+00, %127
  store float %128, float* %1
  br label %180

; <label>:129                                     ; preds = %97
  %130 = load float* %lo, align 4
  %131 = load float* %2, align 4
  %132 = load float* %c, align 4
  %133 = fmul float %131, %132
  %134 = load float* %c, align 4
  %135 = fsub float 2.000000e+00, %134
  %136 = fdiv float %133, %135
  %137 = fsub float %130, %136
  %138 = load float* %hi, align 4
  %139 = fsub float %137, %138
  %140 = fsub float 1.000000e+00, %139
  store float %140, float* %y, align 4
  br label %141

; <label>:141                                     ; preds = %129
  %142 = load i32* %k, align 4
  %143 = icmp sge i32 %142, -125
  br i1 %143, label %144, label %161

; <label>:144                                     ; preds = %141
  br label %145

; <label>:145                                     ; preds = %144
  %146 = load float* %y, align 4
  %147 = bitcast %union.ieee_float_shape_type* %gf_u1 to float*
  store float %146, float* %147, align 4
  %148 = bitcast %union.ieee_float_shape_type* %gf_u1 to i32*
  %149 = load i32* %148, align 4
  store i32 %149, i32* %hy, align 4
  br label %150

; <label>:150                                     ; preds = %145
  br label %151

; <label>:151                                     ; preds = %150
  %152 = load i32* %hy, align 4
  %153 = load i32* %k, align 4
  %154 = shl i32 %153, 23
  %155 = add i32 %152, %154
  %156 = bitcast %union.ieee_float_shape_type* %sf_u to i32*
  store i32 %155, i32* %156, align 4
  %157 = bitcast %union.ieee_float_shape_type* %sf_u to float*
  %158 = load float* %157, align 4
  store float %158, float* %y, align 4
  br label %159

; <label>:159                                     ; preds = %151
  %160 = load float* %y, align 4
  store float %160, float* %1
  br label %180

; <label>:161                                     ; preds = %141
  br label %162

; <label>:162                                     ; preds = %161
  %163 = load float* %y, align 4
  %164 = bitcast %union.ieee_float_shape_type* %gf_u3 to float*
  store float %163, float* %164, align 4
  %165 = bitcast %union.ieee_float_shape_type* %gf_u3 to i32*
  %166 = load i32* %165, align 4
  store i32 %166, i32* %hy2, align 4
  br label %167

; <label>:167                                     ; preds = %162
  br label %168

; <label>:168                                     ; preds = %167
  %169 = load i32* %hy2, align 4
  %170 = load i32* %k, align 4
  %171 = add nsw i32 %170, 100
  %172 = shl i32 %171, 23
  %173 = add i32 %169, %172
  %174 = bitcast %union.ieee_float_shape_type* %sf_u4 to i32*
  store i32 %173, i32* %174, align 4
  %175 = bitcast %union.ieee_float_shape_type* %sf_u4 to float*
  %176 = load float* %175, align 4
  store float %176, float* %y, align 4
  br label %177

; <label>:177                                     ; preds = %168
  %178 = load float* %y, align 4
  %179 = fmul float %178, 0x39B0000000000000
  store float %179, float* %1
  br label %180

; <label>:180                                     ; preds = %177, %159, %119, %92, %43, %36, %30, %16
  %181 = load float* %1
  ret float %181
}

; Function Attrs: nounwind
define internal float @expf(float %x) #1 {
  %1 = alloca float, align 4
  store float %x, float* %1, align 4
  %2 = load float* %1, align 4
  %3 = call float @__ieee754_expf(float %2) #2
  ret float %3
}

attributes #0 = { nounwind "no-frame-pointer-elim"="false" }
attributes #1 = { nounwind "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { nobuiltin }

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
