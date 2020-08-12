; ModuleID = '15_thxprlsg.postlto.8.bc'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux_gnu"

%union.ieee_float_shape_type = type { float }

@temp0 = internal global [8 x float] zeroinitializer, align 8
@param0 = internal global [8 x float] zeroinitializer, align 8
@ln2HI31 = internal constant [2 x float] [float 0x3FE62E3000000000, float 0xBFE62E3000000000], align 4
@ln2LO32 = internal constant [2 x float] [float 0x3EE2FEFA20000000, float 0xBEE2FEFA20000000], align 4
@halF33 = internal constant [2 x float] [float 5.000000e-01, float -5.000000e-01], align 4

; Function Attrs: nounwind
define float @main() #0 {
fusion.loop_body.dim.0.lr.ph:
  br label %fusion.loop_body.dim.0

fusion.loop_body.dim.0:                           ; preds = %fusion.loop_body.dim.0, %fusion.loop_body.dim.0.lr.ph
  %fusion.indvar.dim.02 = phi i64 [ 0, %fusion.loop_body.dim.0.lr.ph ], [ %invar.inc, %fusion.loop_body.dim.0 ]
  %0 = getelementptr inbounds [8 x float]* @param0, i64 0, i64 %fusion.indvar.dim.02
  %1 = load volatile float* %0, align 4
  %2 = call float @tanhf(float %1)
  %3 = call float @expf(float %2)
  %4 = fcmp ole float %3, 0.000000e+00
  %.op = fmul float %3, 5.000000e-01
  %5 = select i1 %4, float 0.000000e+00, float %.op
  %6 = call float @tanhf(float %5)
  %7 = fmul float %6, 5.000000e-01
  %8 = fadd float %7, 5.000000e-01
  %9 = getelementptr inbounds [8 x float]* @temp0, i64 0, i64 %fusion.indvar.dim.02
  store volatile float %8, float* %9, align 4
  %invar.inc = add nuw nsw i64 %fusion.indvar.dim.02, 1
  %exitcond = icmp eq i64 %invar.inc, 8
  br i1 %exitcond, label %fusion.loop_exit.dim.0, label %fusion.loop_body.dim.0, !llvm.loop !1

fusion.loop_exit.dim.0:                           ; preds = %fusion.loop_body.dim.0
  %leflow_retval = load volatile float* getelementptr inbounds ([8 x float]* @temp0, i64 0, i64 0), align 4
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
define internal float @expm1f(float %x) #1 {
  %1 = alloca float, align 4
  %2 = alloca float, align 4
  %y = alloca float, align 4
  %hi = alloca float, align 4
  %lo = alloca float, align 4
  %c = alloca float, align 4
  %t = alloca float, align 4
  %e = alloca float, align 4
  %hxs = alloca float, align 4
  %hfx = alloca float, align 4
  %r1 = alloca float, align 4
  %k = alloca i32, align 4
  %xsb = alloca i32, align 4
  %hx = alloca i32, align 4
  %gf_u = alloca %union.ieee_float_shape_type, align 4
  %i = alloca i32, align 4
  %gf_u1 = alloca %union.ieee_float_shape_type, align 4
  %sf_u = alloca %union.ieee_float_shape_type, align 4
  %i2 = alloca i32, align 4
  %sf_u3 = alloca %union.ieee_float_shape_type, align 4
  %gf_u4 = alloca %union.ieee_float_shape_type, align 4
  %sf_u5 = alloca %union.ieee_float_shape_type, align 4
  %i6 = alloca i32, align 4
  %sf_u7 = alloca %union.ieee_float_shape_type, align 4
  %gf_u8 = alloca %union.ieee_float_shape_type, align 4
  %sf_u9 = alloca %union.ieee_float_shape_type, align 4
  store float %x, float* %2, align 4
  br label %3

; <label>:3                                       ; preds = %0
  %4 = load float* %2, align 4
  %5 = bitcast %union.ieee_float_shape_type* %gf_u to float*
  store float %4, float* %5, align 4
  %6 = bitcast %union.ieee_float_shape_type* %gf_u to i32*
  %7 = load i32* %6, align 4
  store i32 %7, i32* %hx, align 4
  br label %8

; <label>:8                                       ; preds = %3
  %9 = load i32* %hx, align 4
  %10 = and i32 %9, -2147483648
  store i32 %10, i32* %xsb, align 4
  %11 = load i32* %xsb, align 4
  %12 = icmp eq i32 %11, 0
  br i1 %12, label %13, label %15

; <label>:13                                      ; preds = %8
  %14 = load float* %2, align 4
  store float %14, float* %y, align 4
  br label %18

; <label>:15                                      ; preds = %8
  %16 = load float* %2, align 4
  %17 = fsub float -0.000000e+00, %16
  store float %17, float* %y, align 4
  br label %18

; <label>:18                                      ; preds = %15, %13
  %19 = load i32* %hx, align 4
  %20 = and i32 %19, 2147483647
  store i32 %20, i32* %hx, align 4
  %21 = load i32* %hx, align 4
  %22 = icmp uge i32 %21, 1100331076
  br i1 %22, label %23, label %60

; <label>:23                                      ; preds = %18
  %24 = load i32* %hx, align 4
  %25 = icmp ugt i32 %24, 2139095040
  br i1 %25, label %26, label %30

; <label>:26                                      ; preds = %23
  %27 = load float* %2, align 4
  %28 = load float* %2, align 4
  %29 = fadd float %27, %28
  store float %29, float* %1
  br label %291

; <label>:30                                      ; preds = %23
  %31 = load i32* %hx, align 4
  %32 = icmp eq i32 %31, 2139095040
  br i1 %32, label %33, label %43

; <label>:33                                      ; preds = %30
  %34 = load i32* %xsb, align 4
  %35 = icmp eq i32 %34, 0
  br i1 %35, label %36, label %39

; <label>:36                                      ; preds = %33
  %37 = load float* %2, align 4
  %38 = fpext float %37 to double
  br label %40

; <label>:39                                      ; preds = %33
  br label %40

; <label>:40                                      ; preds = %39, %36
  %41 = phi double [ %38, %36 ], [ -1.000000e+00, %39 ]
  %42 = fptrunc double %41 to float
  store float %42, float* %1
  br label %291

; <label>:43                                      ; preds = %30
  %44 = load i32* %xsb, align 4
  %45 = icmp eq i32 %44, 0
  br i1 %45, label %46, label %50

; <label>:46                                      ; preds = %43
  %47 = load i32* %hx, align 4
  %48 = icmp ugt i32 %47, 1118925335
  br i1 %48, label %49, label %50

; <label>:49                                      ; preds = %46
  store float 0x7FF0000000000000, float* %1
  br label %291

; <label>:50                                      ; preds = %46, %43
  %51 = load i32* %xsb, align 4
  %52 = icmp ne i32 %51, 0
  br i1 %52, label %53, label %59

; <label>:53                                      ; preds = %50
  %54 = load float* %2, align 4
  %55 = fadd float %54, 0x39B4484C00000000
  %56 = fcmp olt float %55, 0.000000e+00
  br i1 %56, label %57, label %58

; <label>:57                                      ; preds = %53
  store float -1.000000e+00, float* %1
  br label %291

; <label>:58                                      ; preds = %53
  br label %59

; <label>:59                                      ; preds = %58, %50
  br label %60

; <label>:60                                      ; preds = %59, %18
  %61 = load i32* %hx, align 4
  %62 = icmp ugt i32 %61, 1051816472
  br i1 %62, label %63, label %101

; <label>:63                                      ; preds = %60
  %64 = load i32* %hx, align 4
  %65 = icmp ult i32 %64, 1065686418
  br i1 %65, label %66, label %76

; <label>:66                                      ; preds = %63
  %67 = load i32* %xsb, align 4
  %68 = icmp eq i32 %67, 0
  br i1 %68, label %69, label %72

; <label>:69                                      ; preds = %66
  %70 = load float* %2, align 4
  %71 = fsub float %70, 0x3FE62E3000000000
  store float %71, float* %hi, align 4
  store float 0x3EE2FEFA20000000, float* %lo, align 4
  store i32 1, i32* %k, align 4
  br label %75

; <label>:72                                      ; preds = %66
  %73 = load float* %2, align 4
  %74 = fadd float %73, 0x3FE62E3000000000
  store float %74, float* %hi, align 4
  store float 0xBEE2FEFA20000000, float* %lo, align 4
  store i32 -1, i32* %k, align 4
  br label %75

; <label>:75                                      ; preds = %72, %69
  br label %92

; <label>:76                                      ; preds = %63
  %77 = load float* %2, align 4
  %78 = fmul float 0x3FF7154760000000, %77
  %79 = load i32* %xsb, align 4
  %80 = icmp eq i32 %79, 0
  %81 = select i1 %80, float 5.000000e-01, float -5.000000e-01
  %82 = fadd float %78, %81
  %83 = fptosi float %82 to i32
  store i32 %83, i32* %k, align 4
  %84 = load i32* %k, align 4
  %85 = sitofp i32 %84 to float
  store float %85, float* %t, align 4
  %86 = load float* %2, align 4
  %87 = load float* %t, align 4
  %88 = fmul float %87, 0x3FE62E3000000000
  %89 = fsub float %86, %88
  store float %89, float* %hi, align 4
  %90 = load float* %t, align 4
  %91 = fmul float %90, 0x3EE2FEFA20000000
  store float %91, float* %lo, align 4
  br label %92

; <label>:92                                      ; preds = %76, %75
  %93 = load float* %hi, align 4
  %94 = load float* %lo, align 4
  %95 = fsub float %93, %94
  store float %95, float* %2, align 4
  %96 = load float* %hi, align 4
  %97 = load float* %2, align 4
  %98 = fsub float %96, %97
  %99 = load float* %lo, align 4
  %100 = fsub float %98, %99
  store float %100, float* %c, align 4
  br label %115

; <label>:101                                     ; preds = %60
  %102 = load i32* %hx, align 4
  %103 = icmp ult i32 %102, 855638016
  br i1 %103, label %104, label %113

; <label>:104                                     ; preds = %101
  %105 = load float* %2, align 4
  %106 = fadd float 0x46293E5940000000, %105
  store float %106, float* %t, align 4
  %107 = load float* %2, align 4
  %108 = load float* %t, align 4
  %109 = load float* %2, align 4
  %110 = fadd float 0x46293E5940000000, %109
  %111 = fsub float %108, %110
  %112 = fsub float %107, %111
  store float %112, float* %1
  br label %291

; <label>:113                                     ; preds = %101
  store i32 0, i32* %k, align 4
  br label %114

; <label>:114                                     ; preds = %113
  br label %115

; <label>:115                                     ; preds = %114, %92
  %116 = load float* %2, align 4
  %117 = fmul float 5.000000e-01, %116
  store float %117, float* %hfx, align 4
  %118 = load float* %2, align 4
  %119 = load float* %hfx, align 4
  %120 = fmul float %118, %119
  store float %120, float* %hxs, align 4
  %121 = load float* %hxs, align 4
  %122 = load float* %hxs, align 4
  %123 = load float* %hxs, align 4
  %124 = load float* %hxs, align 4
  %125 = load float* %hxs, align 4
  %126 = fmul float %125, 0xBE8AFDB760000000
  %127 = fadd float 0x3ED0CFCA80000000, %126
  %128 = fmul float %124, %127
  %129 = fadd float 0xBF14CE19A0000000, %128
  %130 = fmul float %123, %129
  %131 = fadd float 0x3F5A01A020000000, %130
  %132 = fmul float %122, %131
  %133 = fadd float 0xBFA1111120000000, %132
  %134 = fmul float %121, %133
  %135 = fadd float 1.000000e+00, %134
  store float %135, float* %r1, align 4
  %136 = load float* %r1, align 4
  %137 = load float* %hfx, align 4
  %138 = fmul float %136, %137
  %139 = fsub float 3.000000e+00, %138
  store float %139, float* %t, align 4
  %140 = load float* %hxs, align 4
  %141 = load float* %r1, align 4
  %142 = load float* %t, align 4
  %143 = fsub float %141, %142
  %144 = load float* %2, align 4
  %145 = load float* %t, align 4
  %146 = fmul float %144, %145
  %147 = fsub float 6.000000e+00, %146
  %148 = fdiv float %143, %147
  %149 = fmul float %140, %148
  store float %149, float* %e, align 4
  %150 = load i32* %k, align 4
  %151 = icmp eq i32 %150, 0
  br i1 %151, label %152, label %160

; <label>:152                                     ; preds = %115
  %153 = load float* %2, align 4
  %154 = load float* %2, align 4
  %155 = load float* %e, align 4
  %156 = fmul float %154, %155
  %157 = load float* %hxs, align 4
  %158 = fsub float %156, %157
  %159 = fsub float %153, %158
  store float %159, float* %1
  br label %291

; <label>:160                                     ; preds = %115
  %161 = load float* %2, align 4
  %162 = load float* %e, align 4
  %163 = load float* %c, align 4
  %164 = fsub float %162, %163
  %165 = fmul float %161, %164
  %166 = load float* %c, align 4
  %167 = fsub float %165, %166
  store float %167, float* %e, align 4
  %168 = load float* %hxs, align 4
  %169 = load float* %e, align 4
  %170 = fsub float %169, %168
  store float %170, float* %e, align 4
  %171 = load i32* %k, align 4
  %172 = icmp eq i32 %171, -1
  br i1 %172, label %173, label %179

; <label>:173                                     ; preds = %160
  %174 = load float* %2, align 4
  %175 = load float* %e, align 4
  %176 = fsub float %174, %175
  %177 = fmul float 5.000000e-01, %176
  %178 = fsub float %177, 5.000000e-01
  store float %178, float* %1
  br label %291

; <label>:179                                     ; preds = %160
  %180 = load i32* %k, align 4
  %181 = icmp eq i32 %180, 1
  br i1 %181, label %182, label %197

; <label>:182                                     ; preds = %179
  %183 = load float* %2, align 4
  %184 = fcmp olt float %183, -2.500000e-01
  br i1 %184, label %185, label %191

; <label>:185                                     ; preds = %182
  %186 = load float* %e, align 4
  %187 = load float* %2, align 4
  %188 = fadd float %187, 5.000000e-01
  %189 = fsub float %186, %188
  %190 = fmul float -2.000000e+00, %189
  store float %190, float* %1
  br label %291

; <label>:191                                     ; preds = %182
  %192 = load float* %2, align 4
  %193 = load float* %e, align 4
  %194 = fsub float %192, %193
  %195 = fmul float 2.000000e+00, %194
  %196 = fadd float 1.000000e+00, %195
  store float %196, float* %1
  br label %291

; <label>:197                                     ; preds = %179
  %198 = load i32* %k, align 4
  %199 = icmp sle i32 %198, -2
  br i1 %199, label %203, label %200

; <label>:200                                     ; preds = %197
  %201 = load i32* %k, align 4
  %202 = icmp sgt i32 %201, 56
  br i1 %202, label %203, label %225

; <label>:203                                     ; preds = %200, %197
  %204 = load float* %e, align 4
  %205 = load float* %2, align 4
  %206 = fsub float %204, %205
  %207 = fsub float 1.000000e+00, %206
  store float %207, float* %y, align 4
  br label %208

; <label>:208                                     ; preds = %203
  %209 = load float* %y, align 4
  %210 = bitcast %union.ieee_float_shape_type* %gf_u1 to float*
  store float %209, float* %210, align 4
  %211 = bitcast %union.ieee_float_shape_type* %gf_u1 to i32*
  %212 = load i32* %211, align 4
  store i32 %212, i32* %i, align 4
  br label %213

; <label>:213                                     ; preds = %208
  br label %214

; <label>:214                                     ; preds = %213
  %215 = load i32* %i, align 4
  %216 = load i32* %k, align 4
  %217 = shl i32 %216, 23
  %218 = add nsw i32 %215, %217
  %219 = bitcast %union.ieee_float_shape_type* %sf_u to i32*
  store i32 %218, i32* %219, align 4
  %220 = bitcast %union.ieee_float_shape_type* %sf_u to float*
  %221 = load float* %220, align 4
  store float %221, float* %y, align 4
  br label %222

; <label>:222                                     ; preds = %214
  %223 = load float* %y, align 4
  %224 = fsub float %223, 1.000000e+00
  store float %224, float* %1
  br label %291

; <label>:225                                     ; preds = %200
  store float 1.000000e+00, float* %t, align 4
  %226 = load i32* %k, align 4
  %227 = icmp slt i32 %226, 23
  br i1 %227, label %228, label %257

; <label>:228                                     ; preds = %225
  br label %229

; <label>:229                                     ; preds = %228
  %230 = load i32* %k, align 4
  %231 = ashr i32 16777216, %230
  %232 = sub nsw i32 1065353216, %231
  %233 = bitcast %union.ieee_float_shape_type* %sf_u3 to i32*
  store i32 %232, i32* %233, align 4
  %234 = bitcast %union.ieee_float_shape_type* %sf_u3 to float*
  %235 = load float* %234, align 4
  store float %235, float* %t, align 4
  br label %236

; <label>:236                                     ; preds = %229
  %237 = load float* %t, align 4
  %238 = load float* %e, align 4
  %239 = load float* %2, align 4
  %240 = fsub float %238, %239
  %241 = fsub float %237, %240
  store float %241, float* %y, align 4
  br label %242

; <label>:242                                     ; preds = %236
  %243 = load float* %y, align 4
  %244 = bitcast %union.ieee_float_shape_type* %gf_u4 to float*
  store float %243, float* %244, align 4
  %245 = bitcast %union.ieee_float_shape_type* %gf_u4 to i32*
  %246 = load i32* %245, align 4
  store i32 %246, i32* %i2, align 4
  br label %247

; <label>:247                                     ; preds = %242
  br label %248

; <label>:248                                     ; preds = %247
  %249 = load i32* %i2, align 4
  %250 = load i32* %k, align 4
  %251 = shl i32 %250, 23
  %252 = add nsw i32 %249, %251
  %253 = bitcast %union.ieee_float_shape_type* %sf_u5 to i32*
  store i32 %252, i32* %253, align 4
  %254 = bitcast %union.ieee_float_shape_type* %sf_u5 to float*
  %255 = load float* %254, align 4
  store float %255, float* %y, align 4
  br label %256

; <label>:256                                     ; preds = %248
  br label %288

; <label>:257                                     ; preds = %225
  br label %258

; <label>:258                                     ; preds = %257
  %259 = load i32* %k, align 4
  %260 = sub nsw i32 127, %259
  %261 = shl i32 %260, 23
  %262 = bitcast %union.ieee_float_shape_type* %sf_u7 to i32*
  store i32 %261, i32* %262, align 4
  %263 = bitcast %union.ieee_float_shape_type* %sf_u7 to float*
  %264 = load float* %263, align 4
  store float %264, float* %t, align 4
  br label %265

; <label>:265                                     ; preds = %258
  %266 = load float* %2, align 4
  %267 = load float* %e, align 4
  %268 = load float* %t, align 4
  %269 = fadd float %267, %268
  %270 = fsub float %266, %269
  store float %270, float* %y, align 4
  %271 = load float* %y, align 4
  %272 = fadd float %271, 1.000000e+00
  store float %272, float* %y, align 4
  br label %273

; <label>:273                                     ; preds = %265
  %274 = load float* %y, align 4
  %275 = bitcast %union.ieee_float_shape_type* %gf_u8 to float*
  store float %274, float* %275, align 4
  %276 = bitcast %union.ieee_float_shape_type* %gf_u8 to i32*
  %277 = load i32* %276, align 4
  store i32 %277, i32* %i6, align 4
  br label %278

; <label>:278                                     ; preds = %273
  br label %279

; <label>:279                                     ; preds = %278
  %280 = load i32* %i6, align 4
  %281 = load i32* %k, align 4
  %282 = shl i32 %281, 23
  %283 = add nsw i32 %280, %282
  %284 = bitcast %union.ieee_float_shape_type* %sf_u9 to i32*
  store i32 %283, i32* %284, align 4
  %285 = bitcast %union.ieee_float_shape_type* %sf_u9 to float*
  %286 = load float* %285, align 4
  store float %286, float* %y, align 4
  br label %287

; <label>:287                                     ; preds = %279
  br label %288

; <label>:288                                     ; preds = %287, %256
  br label %289

; <label>:289                                     ; preds = %288
  %290 = load float* %y, align 4
  store float %290, float* %1
  br label %291

; <label>:291                                     ; preds = %289, %222, %191, %185, %173, %152, %104, %57, %49, %40, %26
  %292 = load float* %1
  ret float %292
}

; Function Attrs: nounwind readnone
define internal float @fabsf(float %x) #2 {
  %1 = alloca float, align 4
  %ix = alloca i32, align 4
  %gf_u = alloca %union.ieee_float_shape_type, align 4
  %sf_u = alloca %union.ieee_float_shape_type, align 4
  store float %x, float* %1, align 4
  br label %2

; <label>:2                                       ; preds = %0
  %3 = load float* %1, align 4
  %4 = bitcast %union.ieee_float_shape_type* %gf_u to float*
  store float %3, float* %4, align 4
  %5 = bitcast %union.ieee_float_shape_type* %gf_u to i32*
  %6 = load i32* %5, align 4
  store i32 %6, i32* %ix, align 4
  br label %7

; <label>:7                                       ; preds = %2
  br label %8

; <label>:8                                       ; preds = %7
  %9 = load i32* %ix, align 4
  %10 = and i32 %9, 2147483647
  %11 = bitcast %union.ieee_float_shape_type* %sf_u to i32*
  store i32 %10, i32* %11, align 4
  %12 = bitcast %union.ieee_float_shape_type* %sf_u to float*
  %13 = load float* %12, align 4
  store float %13, float* %1, align 4
  br label %14

; <label>:14                                      ; preds = %8
  %15 = load float* %1, align 4
  ret float %15
}

; Function Attrs: nounwind
define internal float @tanhf(float %x) #1 {
  %1 = alloca float, align 4
  %2 = alloca float, align 4
  %t = alloca float, align 4
  %z = alloca float, align 4
  %jx = alloca i32, align 4
  %ix = alloca i32, align 4
  %gf_u = alloca %union.ieee_float_shape_type, align 4
  store float %x, float* %2, align 4
  br label %3

; <label>:3                                       ; preds = %0
  %4 = load float* %2, align 4
  %5 = bitcast %union.ieee_float_shape_type* %gf_u to float*
  store float %4, float* %5, align 4
  %6 = bitcast %union.ieee_float_shape_type* %gf_u to i32*
  %7 = load i32* %6, align 4
  store i32 %7, i32* %jx, align 4
  br label %8

; <label>:8                                       ; preds = %3
  %9 = load i32* %jx, align 4
  %10 = and i32 %9, 2147483647
  store i32 %10, i32* %ix, align 4
  %11 = load i32* %ix, align 4
  %12 = icmp slt i32 %11, 2139095040
  br i1 %12, label %24, label %13

; <label>:13                                      ; preds = %8
  %14 = load i32* %jx, align 4
  %15 = icmp sge i32 %14, 0
  br i1 %15, label %16, label %20

; <label>:16                                      ; preds = %13
  %17 = load float* %2, align 4
  %18 = fdiv float 1.000000e+00, %17
  %19 = fadd float %18, 1.000000e+00
  store float %19, float* %1
  br label %69

; <label>:20                                      ; preds = %13
  %21 = load float* %2, align 4
  %22 = fdiv float 1.000000e+00, %21
  %23 = fsub float %22, 1.000000e+00
  store float %23, float* %1
  br label %69

; <label>:24                                      ; preds = %8
  %25 = load i32* %ix, align 4
  %26 = icmp slt i32 %25, 1102053376
  br i1 %26, label %27, label %58

; <label>:27                                      ; preds = %24
  %28 = load i32* %ix, align 4
  %29 = icmp slt i32 %28, 603979776
  br i1 %29, label %30, label %35

; <label>:30                                      ; preds = %27
  %31 = load float* %2, align 4
  %32 = load float* %2, align 4
  %33 = fadd float 1.000000e+00, %32
  %34 = fmul float %31, %33
  store float %34, float* %1
  br label %69

; <label>:35                                      ; preds = %27
  %36 = load i32* %ix, align 4
  %37 = icmp sge i32 %36, 1065353216
  br i1 %37, label %38, label %47

; <label>:38                                      ; preds = %35
  %39 = load float* %2, align 4
  %40 = call float @fabsf(float %39) #3
  %41 = fmul float 2.000000e+00, %40
  %42 = call float @expm1f(float %41) #4
  store float %42, float* %t, align 4
  %43 = load float* %t, align 4
  %44 = fadd float %43, 2.000000e+00
  %45 = fdiv float 2.000000e+00, %44
  %46 = fsub float 1.000000e+00, %45
  store float %46, float* %z, align 4
  br label %57

; <label>:47                                      ; preds = %35
  %48 = load float* %2, align 4
  %49 = call float @fabsf(float %48) #3
  %50 = fmul float -2.000000e+00, %49
  %51 = call float @expm1f(float %50) #4
  store float %51, float* %t, align 4
  %52 = load float* %t, align 4
  %53 = fsub float -0.000000e+00, %52
  %54 = load float* %t, align 4
  %55 = fadd float %54, 2.000000e+00
  %56 = fdiv float %53, %55
  store float %56, float* %z, align 4
  br label %57

; <label>:57                                      ; preds = %47, %38
  br label %59

; <label>:58                                      ; preds = %24
  store float 1.000000e+00, float* %z, align 4
  br label %59

; <label>:59                                      ; preds = %58, %57
  %60 = load i32* %jx, align 4
  %61 = icmp sge i32 %60, 0
  br i1 %61, label %62, label %64

; <label>:62                                      ; preds = %59
  %63 = load float* %z, align 4
  br label %67

; <label>:64                                      ; preds = %59
  %65 = load float* %z, align 4
  %66 = fsub float -0.000000e+00, %65
  br label %67

; <label>:67                                      ; preds = %64, %62
  %68 = phi float [ %63, %62 ], [ %66, %64 ]
  store float %68, float* %1
  br label %69

; <label>:69                                      ; preds = %67, %30, %20, %16
  %70 = load float* %1
  ret float %70
}

; Function Attrs: nounwind
define internal float @expf(float %x) #1 {
  %1 = alloca float, align 4
  store float %x, float* %1, align 4
  %2 = load float* %1, align 4
  %3 = call float @__ieee754_expf(float %2) #5
  ret float %3
}

attributes #0 = { nounwind "no-frame-pointer-elim"="false" }
attributes #1 = { nounwind "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { nounwind readnone "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #3 = { nobuiltin nounwind readnone }
attributes #4 = { nobuiltin nounwind }
attributes #5 = { nobuiltin }

!llvm.ident = !{!0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0}

!0 = metadata !{metadata !"clang version 3.5.0 (tags/RELEASE_350/final)"}
!1 = metadata !{metadata !1, metadata !2}
!2 = metadata !{metadata !"llvm.loop.vectorize.enable", i1 false}
