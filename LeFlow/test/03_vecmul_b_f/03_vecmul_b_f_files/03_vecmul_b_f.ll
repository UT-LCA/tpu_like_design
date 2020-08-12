; ModuleID = '03_vecmul_b_f.bc'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux_gnu"

@temp0 = internal global [64 x float] zeroinitializer, align 8
@param1 = internal global [64 x float] zeroinitializer, align 8
@param0 = internal global [64 x float] zeroinitializer, align 8

; Function Attrs: nounwind
define float @main() #0 {
multiply.loop_body.dim.0.lr.ph:
  %0 = load volatile float* getelementptr inbounds ([64 x float]* @param1, i64 0, i64 0), align 8
  %1 = load volatile float* getelementptr inbounds ([64 x float]* @param0, i64 0, i64 0), align 8
  %2 = fmul float %0, %1
  store volatile float %2, float* getelementptr inbounds ([64 x float]* @temp0, i64 0, i64 0), align 8
  %3 = load volatile float* getelementptr inbounds ([64 x float]* @param1, i64 0, i64 1), align 4
  %4 = load volatile float* getelementptr inbounds ([64 x float]* @param0, i64 0, i64 1), align 4
  %5 = fmul float %3, %4
  store volatile float %5, float* getelementptr inbounds ([64 x float]* @temp0, i64 0, i64 1), align 4
  %6 = load volatile float* getelementptr inbounds ([64 x float]* @param1, i64 0, i64 2), align 8
  %7 = load volatile float* getelementptr inbounds ([64 x float]* @param0, i64 0, i64 2), align 8
  %8 = fmul float %6, %7
  store volatile float %8, float* getelementptr inbounds ([64 x float]* @temp0, i64 0, i64 2), align 8
  %9 = load volatile float* getelementptr inbounds ([64 x float]* @param1, i64 0, i64 3), align 4
  %10 = load volatile float* getelementptr inbounds ([64 x float]* @param0, i64 0, i64 3), align 4
  %11 = fmul float %9, %10
  store volatile float %11, float* getelementptr inbounds ([64 x float]* @temp0, i64 0, i64 3), align 4
  %12 = load volatile float* getelementptr inbounds ([64 x float]* @param1, i64 0, i64 4), align 8
  %13 = load volatile float* getelementptr inbounds ([64 x float]* @param0, i64 0, i64 4), align 8
  %14 = fmul float %12, %13
  store volatile float %14, float* getelementptr inbounds ([64 x float]* @temp0, i64 0, i64 4), align 8
  %15 = load volatile float* getelementptr inbounds ([64 x float]* @param1, i64 0, i64 5), align 4
  %16 = load volatile float* getelementptr inbounds ([64 x float]* @param0, i64 0, i64 5), align 4
  %17 = fmul float %15, %16
  store volatile float %17, float* getelementptr inbounds ([64 x float]* @temp0, i64 0, i64 5), align 4
  %18 = load volatile float* getelementptr inbounds ([64 x float]* @param1, i64 0, i64 6), align 8
  %19 = load volatile float* getelementptr inbounds ([64 x float]* @param0, i64 0, i64 6), align 8
  %20 = fmul float %18, %19
  store volatile float %20, float* getelementptr inbounds ([64 x float]* @temp0, i64 0, i64 6), align 8
  %21 = load volatile float* getelementptr inbounds ([64 x float]* @param1, i64 0, i64 7), align 4
  %22 = load volatile float* getelementptr inbounds ([64 x float]* @param0, i64 0, i64 7), align 4
  %23 = fmul float %21, %22
  store volatile float %23, float* getelementptr inbounds ([64 x float]* @temp0, i64 0, i64 7), align 4
  %24 = load volatile float* getelementptr inbounds ([64 x float]* @param1, i64 0, i64 8), align 8
  %25 = load volatile float* getelementptr inbounds ([64 x float]* @param0, i64 0, i64 8), align 8
  %26 = fmul float %24, %25
  store volatile float %26, float* getelementptr inbounds ([64 x float]* @temp0, i64 0, i64 8), align 8
  %27 = load volatile float* getelementptr inbounds ([64 x float]* @param1, i64 0, i64 9), align 4
  %28 = load volatile float* getelementptr inbounds ([64 x float]* @param0, i64 0, i64 9), align 4
  %29 = fmul float %27, %28
  store volatile float %29, float* getelementptr inbounds ([64 x float]* @temp0, i64 0, i64 9), align 4
  %30 = load volatile float* getelementptr inbounds ([64 x float]* @param1, i64 0, i64 10), align 8
  %31 = load volatile float* getelementptr inbounds ([64 x float]* @param0, i64 0, i64 10), align 8
  %32 = fmul float %30, %31
  store volatile float %32, float* getelementptr inbounds ([64 x float]* @temp0, i64 0, i64 10), align 8
  %33 = load volatile float* getelementptr inbounds ([64 x float]* @param1, i64 0, i64 11), align 4
  %34 = load volatile float* getelementptr inbounds ([64 x float]* @param0, i64 0, i64 11), align 4
  %35 = fmul float %33, %34
  store volatile float %35, float* getelementptr inbounds ([64 x float]* @temp0, i64 0, i64 11), align 4
  %36 = load volatile float* getelementptr inbounds ([64 x float]* @param1, i64 0, i64 12), align 8
  %37 = load volatile float* getelementptr inbounds ([64 x float]* @param0, i64 0, i64 12), align 8
  %38 = fmul float %36, %37
  store volatile float %38, float* getelementptr inbounds ([64 x float]* @temp0, i64 0, i64 12), align 8
  %39 = load volatile float* getelementptr inbounds ([64 x float]* @param1, i64 0, i64 13), align 4
  %40 = load volatile float* getelementptr inbounds ([64 x float]* @param0, i64 0, i64 13), align 4
  %41 = fmul float %39, %40
  store volatile float %41, float* getelementptr inbounds ([64 x float]* @temp0, i64 0, i64 13), align 4
  %42 = load volatile float* getelementptr inbounds ([64 x float]* @param1, i64 0, i64 14), align 8
  %43 = load volatile float* getelementptr inbounds ([64 x float]* @param0, i64 0, i64 14), align 8
  %44 = fmul float %42, %43
  store volatile float %44, float* getelementptr inbounds ([64 x float]* @temp0, i64 0, i64 14), align 8
  %45 = load volatile float* getelementptr inbounds ([64 x float]* @param1, i64 0, i64 15), align 4
  %46 = load volatile float* getelementptr inbounds ([64 x float]* @param0, i64 0, i64 15), align 4
  %47 = fmul float %45, %46
  store volatile float %47, float* getelementptr inbounds ([64 x float]* @temp0, i64 0, i64 15), align 4
  %48 = load volatile float* getelementptr inbounds ([64 x float]* @param1, i64 0, i64 16), align 8
  %49 = load volatile float* getelementptr inbounds ([64 x float]* @param0, i64 0, i64 16), align 8
  %50 = fmul float %48, %49
  store volatile float %50, float* getelementptr inbounds ([64 x float]* @temp0, i64 0, i64 16), align 8
  %51 = load volatile float* getelementptr inbounds ([64 x float]* @param1, i64 0, i64 17), align 4
  %52 = load volatile float* getelementptr inbounds ([64 x float]* @param0, i64 0, i64 17), align 4
  %53 = fmul float %51, %52
  store volatile float %53, float* getelementptr inbounds ([64 x float]* @temp0, i64 0, i64 17), align 4
  %54 = load volatile float* getelementptr inbounds ([64 x float]* @param1, i64 0, i64 18), align 8
  %55 = load volatile float* getelementptr inbounds ([64 x float]* @param0, i64 0, i64 18), align 8
  %56 = fmul float %54, %55
  store volatile float %56, float* getelementptr inbounds ([64 x float]* @temp0, i64 0, i64 18), align 8
  %57 = load volatile float* getelementptr inbounds ([64 x float]* @param1, i64 0, i64 19), align 4
  %58 = load volatile float* getelementptr inbounds ([64 x float]* @param0, i64 0, i64 19), align 4
  %59 = fmul float %57, %58
  store volatile float %59, float* getelementptr inbounds ([64 x float]* @temp0, i64 0, i64 19), align 4
  %60 = load volatile float* getelementptr inbounds ([64 x float]* @param1, i64 0, i64 20), align 8
  %61 = load volatile float* getelementptr inbounds ([64 x float]* @param0, i64 0, i64 20), align 8
  %62 = fmul float %60, %61
  store volatile float %62, float* getelementptr inbounds ([64 x float]* @temp0, i64 0, i64 20), align 8
  %63 = load volatile float* getelementptr inbounds ([64 x float]* @param1, i64 0, i64 21), align 4
  %64 = load volatile float* getelementptr inbounds ([64 x float]* @param0, i64 0, i64 21), align 4
  %65 = fmul float %63, %64
  store volatile float %65, float* getelementptr inbounds ([64 x float]* @temp0, i64 0, i64 21), align 4
  %66 = load volatile float* getelementptr inbounds ([64 x float]* @param1, i64 0, i64 22), align 8
  %67 = load volatile float* getelementptr inbounds ([64 x float]* @param0, i64 0, i64 22), align 8
  %68 = fmul float %66, %67
  store volatile float %68, float* getelementptr inbounds ([64 x float]* @temp0, i64 0, i64 22), align 8
  %69 = load volatile float* getelementptr inbounds ([64 x float]* @param1, i64 0, i64 23), align 4
  %70 = load volatile float* getelementptr inbounds ([64 x float]* @param0, i64 0, i64 23), align 4
  %71 = fmul float %69, %70
  store volatile float %71, float* getelementptr inbounds ([64 x float]* @temp0, i64 0, i64 23), align 4
  %72 = load volatile float* getelementptr inbounds ([64 x float]* @param1, i64 0, i64 24), align 8
  %73 = load volatile float* getelementptr inbounds ([64 x float]* @param0, i64 0, i64 24), align 8
  %74 = fmul float %72, %73
  store volatile float %74, float* getelementptr inbounds ([64 x float]* @temp0, i64 0, i64 24), align 8
  %75 = load volatile float* getelementptr inbounds ([64 x float]* @param1, i64 0, i64 25), align 4
  %76 = load volatile float* getelementptr inbounds ([64 x float]* @param0, i64 0, i64 25), align 4
  %77 = fmul float %75, %76
  store volatile float %77, float* getelementptr inbounds ([64 x float]* @temp0, i64 0, i64 25), align 4
  %78 = load volatile float* getelementptr inbounds ([64 x float]* @param1, i64 0, i64 26), align 8
  %79 = load volatile float* getelementptr inbounds ([64 x float]* @param0, i64 0, i64 26), align 8
  %80 = fmul float %78, %79
  store volatile float %80, float* getelementptr inbounds ([64 x float]* @temp0, i64 0, i64 26), align 8
  %81 = load volatile float* getelementptr inbounds ([64 x float]* @param1, i64 0, i64 27), align 4
  %82 = load volatile float* getelementptr inbounds ([64 x float]* @param0, i64 0, i64 27), align 4
  %83 = fmul float %81, %82
  store volatile float %83, float* getelementptr inbounds ([64 x float]* @temp0, i64 0, i64 27), align 4
  %84 = load volatile float* getelementptr inbounds ([64 x float]* @param1, i64 0, i64 28), align 8
  %85 = load volatile float* getelementptr inbounds ([64 x float]* @param0, i64 0, i64 28), align 8
  %86 = fmul float %84, %85
  store volatile float %86, float* getelementptr inbounds ([64 x float]* @temp0, i64 0, i64 28), align 8
  %87 = load volatile float* getelementptr inbounds ([64 x float]* @param1, i64 0, i64 29), align 4
  %88 = load volatile float* getelementptr inbounds ([64 x float]* @param0, i64 0, i64 29), align 4
  %89 = fmul float %87, %88
  store volatile float %89, float* getelementptr inbounds ([64 x float]* @temp0, i64 0, i64 29), align 4
  %90 = load volatile float* getelementptr inbounds ([64 x float]* @param1, i64 0, i64 30), align 8
  %91 = load volatile float* getelementptr inbounds ([64 x float]* @param0, i64 0, i64 30), align 8
  %92 = fmul float %90, %91
  store volatile float %92, float* getelementptr inbounds ([64 x float]* @temp0, i64 0, i64 30), align 8
  %93 = load volatile float* getelementptr inbounds ([64 x float]* @param1, i64 0, i64 31), align 4
  %94 = load volatile float* getelementptr inbounds ([64 x float]* @param0, i64 0, i64 31), align 4
  %95 = fmul float %93, %94
  store volatile float %95, float* getelementptr inbounds ([64 x float]* @temp0, i64 0, i64 31), align 4
  %96 = load volatile float* getelementptr inbounds ([64 x float]* @param1, i64 0, i64 32), align 8
  %97 = load volatile float* getelementptr inbounds ([64 x float]* @param0, i64 0, i64 32), align 8
  %98 = fmul float %96, %97
  store volatile float %98, float* getelementptr inbounds ([64 x float]* @temp0, i64 0, i64 32), align 8
  %99 = load volatile float* getelementptr inbounds ([64 x float]* @param1, i64 0, i64 33), align 4
  %100 = load volatile float* getelementptr inbounds ([64 x float]* @param0, i64 0, i64 33), align 4
  %101 = fmul float %99, %100
  store volatile float %101, float* getelementptr inbounds ([64 x float]* @temp0, i64 0, i64 33), align 4
  %102 = load volatile float* getelementptr inbounds ([64 x float]* @param1, i64 0, i64 34), align 8
  %103 = load volatile float* getelementptr inbounds ([64 x float]* @param0, i64 0, i64 34), align 8
  %104 = fmul float %102, %103
  store volatile float %104, float* getelementptr inbounds ([64 x float]* @temp0, i64 0, i64 34), align 8
  %105 = load volatile float* getelementptr inbounds ([64 x float]* @param1, i64 0, i64 35), align 4
  %106 = load volatile float* getelementptr inbounds ([64 x float]* @param0, i64 0, i64 35), align 4
  %107 = fmul float %105, %106
  store volatile float %107, float* getelementptr inbounds ([64 x float]* @temp0, i64 0, i64 35), align 4
  %108 = load volatile float* getelementptr inbounds ([64 x float]* @param1, i64 0, i64 36), align 8
  %109 = load volatile float* getelementptr inbounds ([64 x float]* @param0, i64 0, i64 36), align 8
  %110 = fmul float %108, %109
  store volatile float %110, float* getelementptr inbounds ([64 x float]* @temp0, i64 0, i64 36), align 8
  %111 = load volatile float* getelementptr inbounds ([64 x float]* @param1, i64 0, i64 37), align 4
  %112 = load volatile float* getelementptr inbounds ([64 x float]* @param0, i64 0, i64 37), align 4
  %113 = fmul float %111, %112
  store volatile float %113, float* getelementptr inbounds ([64 x float]* @temp0, i64 0, i64 37), align 4
  %114 = load volatile float* getelementptr inbounds ([64 x float]* @param1, i64 0, i64 38), align 8
  %115 = load volatile float* getelementptr inbounds ([64 x float]* @param0, i64 0, i64 38), align 8
  %116 = fmul float %114, %115
  store volatile float %116, float* getelementptr inbounds ([64 x float]* @temp0, i64 0, i64 38), align 8
  %117 = load volatile float* getelementptr inbounds ([64 x float]* @param1, i64 0, i64 39), align 4
  %118 = load volatile float* getelementptr inbounds ([64 x float]* @param0, i64 0, i64 39), align 4
  %119 = fmul float %117, %118
  store volatile float %119, float* getelementptr inbounds ([64 x float]* @temp0, i64 0, i64 39), align 4
  %120 = load volatile float* getelementptr inbounds ([64 x float]* @param1, i64 0, i64 40), align 8
  %121 = load volatile float* getelementptr inbounds ([64 x float]* @param0, i64 0, i64 40), align 8
  %122 = fmul float %120, %121
  store volatile float %122, float* getelementptr inbounds ([64 x float]* @temp0, i64 0, i64 40), align 8
  %123 = load volatile float* getelementptr inbounds ([64 x float]* @param1, i64 0, i64 41), align 4
  %124 = load volatile float* getelementptr inbounds ([64 x float]* @param0, i64 0, i64 41), align 4
  %125 = fmul float %123, %124
  store volatile float %125, float* getelementptr inbounds ([64 x float]* @temp0, i64 0, i64 41), align 4
  %126 = load volatile float* getelementptr inbounds ([64 x float]* @param1, i64 0, i64 42), align 8
  %127 = load volatile float* getelementptr inbounds ([64 x float]* @param0, i64 0, i64 42), align 8
  %128 = fmul float %126, %127
  store volatile float %128, float* getelementptr inbounds ([64 x float]* @temp0, i64 0, i64 42), align 8
  %129 = load volatile float* getelementptr inbounds ([64 x float]* @param1, i64 0, i64 43), align 4
  %130 = load volatile float* getelementptr inbounds ([64 x float]* @param0, i64 0, i64 43), align 4
  %131 = fmul float %129, %130
  store volatile float %131, float* getelementptr inbounds ([64 x float]* @temp0, i64 0, i64 43), align 4
  %132 = load volatile float* getelementptr inbounds ([64 x float]* @param1, i64 0, i64 44), align 8
  %133 = load volatile float* getelementptr inbounds ([64 x float]* @param0, i64 0, i64 44), align 8
  %134 = fmul float %132, %133
  store volatile float %134, float* getelementptr inbounds ([64 x float]* @temp0, i64 0, i64 44), align 8
  %135 = load volatile float* getelementptr inbounds ([64 x float]* @param1, i64 0, i64 45), align 4
  %136 = load volatile float* getelementptr inbounds ([64 x float]* @param0, i64 0, i64 45), align 4
  %137 = fmul float %135, %136
  store volatile float %137, float* getelementptr inbounds ([64 x float]* @temp0, i64 0, i64 45), align 4
  %138 = load volatile float* getelementptr inbounds ([64 x float]* @param1, i64 0, i64 46), align 8
  %139 = load volatile float* getelementptr inbounds ([64 x float]* @param0, i64 0, i64 46), align 8
  %140 = fmul float %138, %139
  store volatile float %140, float* getelementptr inbounds ([64 x float]* @temp0, i64 0, i64 46), align 8
  %141 = load volatile float* getelementptr inbounds ([64 x float]* @param1, i64 0, i64 47), align 4
  %142 = load volatile float* getelementptr inbounds ([64 x float]* @param0, i64 0, i64 47), align 4
  %143 = fmul float %141, %142
  store volatile float %143, float* getelementptr inbounds ([64 x float]* @temp0, i64 0, i64 47), align 4
  %144 = load volatile float* getelementptr inbounds ([64 x float]* @param1, i64 0, i64 48), align 8
  %145 = load volatile float* getelementptr inbounds ([64 x float]* @param0, i64 0, i64 48), align 8
  %146 = fmul float %144, %145
  store volatile float %146, float* getelementptr inbounds ([64 x float]* @temp0, i64 0, i64 48), align 8
  %147 = load volatile float* getelementptr inbounds ([64 x float]* @param1, i64 0, i64 49), align 4
  %148 = load volatile float* getelementptr inbounds ([64 x float]* @param0, i64 0, i64 49), align 4
  %149 = fmul float %147, %148
  store volatile float %149, float* getelementptr inbounds ([64 x float]* @temp0, i64 0, i64 49), align 4
  %150 = load volatile float* getelementptr inbounds ([64 x float]* @param1, i64 0, i64 50), align 8
  %151 = load volatile float* getelementptr inbounds ([64 x float]* @param0, i64 0, i64 50), align 8
  %152 = fmul float %150, %151
  store volatile float %152, float* getelementptr inbounds ([64 x float]* @temp0, i64 0, i64 50), align 8
  %153 = load volatile float* getelementptr inbounds ([64 x float]* @param1, i64 0, i64 51), align 4
  %154 = load volatile float* getelementptr inbounds ([64 x float]* @param0, i64 0, i64 51), align 4
  %155 = fmul float %153, %154
  store volatile float %155, float* getelementptr inbounds ([64 x float]* @temp0, i64 0, i64 51), align 4
  %156 = load volatile float* getelementptr inbounds ([64 x float]* @param1, i64 0, i64 52), align 8
  %157 = load volatile float* getelementptr inbounds ([64 x float]* @param0, i64 0, i64 52), align 8
  %158 = fmul float %156, %157
  store volatile float %158, float* getelementptr inbounds ([64 x float]* @temp0, i64 0, i64 52), align 8
  %159 = load volatile float* getelementptr inbounds ([64 x float]* @param1, i64 0, i64 53), align 4
  %160 = load volatile float* getelementptr inbounds ([64 x float]* @param0, i64 0, i64 53), align 4
  %161 = fmul float %159, %160
  store volatile float %161, float* getelementptr inbounds ([64 x float]* @temp0, i64 0, i64 53), align 4
  %162 = load volatile float* getelementptr inbounds ([64 x float]* @param1, i64 0, i64 54), align 8
  %163 = load volatile float* getelementptr inbounds ([64 x float]* @param0, i64 0, i64 54), align 8
  %164 = fmul float %162, %163
  store volatile float %164, float* getelementptr inbounds ([64 x float]* @temp0, i64 0, i64 54), align 8
  %165 = load volatile float* getelementptr inbounds ([64 x float]* @param1, i64 0, i64 55), align 4
  %166 = load volatile float* getelementptr inbounds ([64 x float]* @param0, i64 0, i64 55), align 4
  %167 = fmul float %165, %166
  store volatile float %167, float* getelementptr inbounds ([64 x float]* @temp0, i64 0, i64 55), align 4
  %168 = load volatile float* getelementptr inbounds ([64 x float]* @param1, i64 0, i64 56), align 8
  %169 = load volatile float* getelementptr inbounds ([64 x float]* @param0, i64 0, i64 56), align 8
  %170 = fmul float %168, %169
  store volatile float %170, float* getelementptr inbounds ([64 x float]* @temp0, i64 0, i64 56), align 8
  %171 = load volatile float* getelementptr inbounds ([64 x float]* @param1, i64 0, i64 57), align 4
  %172 = load volatile float* getelementptr inbounds ([64 x float]* @param0, i64 0, i64 57), align 4
  %173 = fmul float %171, %172
  store volatile float %173, float* getelementptr inbounds ([64 x float]* @temp0, i64 0, i64 57), align 4
  %174 = load volatile float* getelementptr inbounds ([64 x float]* @param1, i64 0, i64 58), align 8
  %175 = load volatile float* getelementptr inbounds ([64 x float]* @param0, i64 0, i64 58), align 8
  %176 = fmul float %174, %175
  store volatile float %176, float* getelementptr inbounds ([64 x float]* @temp0, i64 0, i64 58), align 8
  %177 = load volatile float* getelementptr inbounds ([64 x float]* @param1, i64 0, i64 59), align 4
  %178 = load volatile float* getelementptr inbounds ([64 x float]* @param0, i64 0, i64 59), align 4
  %179 = fmul float %177, %178
  store volatile float %179, float* getelementptr inbounds ([64 x float]* @temp0, i64 0, i64 59), align 4
  %180 = load volatile float* getelementptr inbounds ([64 x float]* @param1, i64 0, i64 60), align 8
  %181 = load volatile float* getelementptr inbounds ([64 x float]* @param0, i64 0, i64 60), align 8
  %182 = fmul float %180, %181
  store volatile float %182, float* getelementptr inbounds ([64 x float]* @temp0, i64 0, i64 60), align 8
  %183 = load volatile float* getelementptr inbounds ([64 x float]* @param1, i64 0, i64 61), align 4
  %184 = load volatile float* getelementptr inbounds ([64 x float]* @param0, i64 0, i64 61), align 4
  %185 = fmul float %183, %184
  store volatile float %185, float* getelementptr inbounds ([64 x float]* @temp0, i64 0, i64 61), align 4
  %186 = load volatile float* getelementptr inbounds ([64 x float]* @param1, i64 0, i64 62), align 8
  %187 = load volatile float* getelementptr inbounds ([64 x float]* @param0, i64 0, i64 62), align 8
  %188 = fmul float %186, %187
  store volatile float %188, float* getelementptr inbounds ([64 x float]* @temp0, i64 0, i64 62), align 8
  %189 = load volatile float* getelementptr inbounds ([64 x float]* @param1, i64 0, i64 63), align 4
  %190 = load volatile float* getelementptr inbounds ([64 x float]* @param0, i64 0, i64 63), align 4
  %191 = fmul float %189, %190
  store volatile float %191, float* getelementptr inbounds ([64 x float]* @temp0, i64 0, i64 63), align 4
  %leflow_retval = load volatile float* getelementptr inbounds ([64 x float]* @temp0, i64 0, i64 0), align 8
  ret float %leflow_retval
}

attributes #0 = { nounwind "no-frame-pointer-elim"="false" }

!llvm.ident = !{!0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0, !0}

!0 = metadata !{metadata !"clang version 3.5.0 (tags/RELEASE_350/final)"}
