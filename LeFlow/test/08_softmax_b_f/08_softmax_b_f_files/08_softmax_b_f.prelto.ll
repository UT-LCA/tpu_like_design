; ModuleID = '08_softmax_b_f.prelto.bc'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux_gnu"

@temp3 = internal global [64 x float] zeroinitializer, align 8
@temp1.0 = internal unnamed_addr global [64 x float] zeroinitializer, align 8
@param0 = internal global [1 x [64 x float]] zeroinitializer, align 8

; Function Attrs: nounwind
define float @main() #0 {
reduce.inner.loop_body.reduction_dim.1.lr.ph:
  %0 = load volatile float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 0), align 4
  %1 = fcmp oge float 0xFFF0000000000000, %0
  %2 = select i1 %1, float 0xFFF0000000000000, float %0
  %3 = load volatile float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 1), align 4
  %4 = fcmp oge float %2, %3
  %5 = fcmp ueq float %2, 0.000000e+00
  %6 = or i1 %4, %5
  %7 = select i1 %6, float %2, float %3
  %8 = load volatile float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 2), align 4
  %9 = fcmp oge float %7, %8
  %10 = fcmp ueq float %7, 0.000000e+00
  %11 = or i1 %9, %10
  %12 = select i1 %11, float %7, float %8
  %13 = load volatile float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 3), align 4
  %14 = fcmp oge float %12, %13
  %15 = fcmp ueq float %12, 0.000000e+00
  %16 = or i1 %14, %15
  %17 = select i1 %16, float %12, float %13
  %18 = load volatile float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 4), align 4
  %19 = fcmp oge float %17, %18
  %20 = fcmp ueq float %17, 0.000000e+00
  %21 = or i1 %19, %20
  %22 = select i1 %21, float %17, float %18
  %23 = load volatile float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 5), align 4
  %24 = fcmp oge float %22, %23
  %25 = fcmp ueq float %22, 0.000000e+00
  %26 = or i1 %24, %25
  %27 = select i1 %26, float %22, float %23
  %28 = load volatile float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 6), align 4
  %29 = fcmp oge float %27, %28
  %30 = fcmp ueq float %27, 0.000000e+00
  %31 = or i1 %29, %30
  %32 = select i1 %31, float %27, float %28
  %33 = load volatile float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 7), align 4
  %34 = fcmp oge float %32, %33
  %35 = fcmp ueq float %32, 0.000000e+00
  %36 = or i1 %34, %35
  %37 = select i1 %36, float %32, float %33
  %38 = load volatile float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 8), align 4
  %39 = fcmp oge float %37, %38
  %40 = fcmp ueq float %37, 0.000000e+00
  %41 = or i1 %39, %40
  %42 = select i1 %41, float %37, float %38
  %43 = load volatile float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 9), align 4
  %44 = fcmp oge float %42, %43
  %45 = fcmp ueq float %42, 0.000000e+00
  %46 = or i1 %44, %45
  %47 = select i1 %46, float %42, float %43
  %48 = load volatile float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 10), align 4
  %49 = fcmp oge float %47, %48
  %50 = fcmp ueq float %47, 0.000000e+00
  %51 = or i1 %49, %50
  %52 = select i1 %51, float %47, float %48
  %53 = load volatile float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 11), align 4
  %54 = fcmp oge float %52, %53
  %55 = fcmp ueq float %52, 0.000000e+00
  %56 = or i1 %54, %55
  %57 = select i1 %56, float %52, float %53
  %58 = load volatile float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 12), align 4
  %59 = fcmp oge float %57, %58
  %60 = fcmp ueq float %57, 0.000000e+00
  %61 = or i1 %59, %60
  %62 = select i1 %61, float %57, float %58
  %63 = load volatile float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 13), align 4
  %64 = fcmp oge float %62, %63
  %65 = fcmp ueq float %62, 0.000000e+00
  %66 = or i1 %64, %65
  %67 = select i1 %66, float %62, float %63
  %68 = load volatile float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 14), align 4
  %69 = fcmp oge float %67, %68
  %70 = fcmp ueq float %67, 0.000000e+00
  %71 = or i1 %69, %70
  %72 = select i1 %71, float %67, float %68
  %73 = load volatile float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 15), align 4
  %74 = fcmp oge float %72, %73
  %75 = fcmp ueq float %72, 0.000000e+00
  %76 = or i1 %74, %75
  %77 = select i1 %76, float %72, float %73
  %78 = load volatile float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 16), align 4
  %79 = fcmp oge float %77, %78
  %80 = fcmp ueq float %77, 0.000000e+00
  %81 = or i1 %79, %80
  %82 = select i1 %81, float %77, float %78
  %83 = load volatile float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 17), align 4
  %84 = fcmp oge float %82, %83
  %85 = fcmp ueq float %82, 0.000000e+00
  %86 = or i1 %84, %85
  %87 = select i1 %86, float %82, float %83
  %88 = load volatile float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 18), align 4
  %89 = fcmp oge float %87, %88
  %90 = fcmp ueq float %87, 0.000000e+00
  %91 = or i1 %89, %90
  %92 = select i1 %91, float %87, float %88
  %93 = load volatile float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 19), align 4
  %94 = fcmp oge float %92, %93
  %95 = fcmp ueq float %92, 0.000000e+00
  %96 = or i1 %94, %95
  %97 = select i1 %96, float %92, float %93
  %98 = load volatile float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 20), align 4
  %99 = fcmp oge float %97, %98
  %100 = fcmp ueq float %97, 0.000000e+00
  %101 = or i1 %99, %100
  %102 = select i1 %101, float %97, float %98
  %103 = load volatile float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 21), align 4
  %104 = fcmp oge float %102, %103
  %105 = fcmp ueq float %102, 0.000000e+00
  %106 = or i1 %104, %105
  %107 = select i1 %106, float %102, float %103
  %108 = load volatile float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 22), align 4
  %109 = fcmp oge float %107, %108
  %110 = fcmp ueq float %107, 0.000000e+00
  %111 = or i1 %109, %110
  %112 = select i1 %111, float %107, float %108
  %113 = load volatile float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 23), align 4
  %114 = fcmp oge float %112, %113
  %115 = fcmp ueq float %112, 0.000000e+00
  %116 = or i1 %114, %115
  %117 = select i1 %116, float %112, float %113
  %118 = load volatile float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 24), align 4
  %119 = fcmp oge float %117, %118
  %120 = fcmp ueq float %117, 0.000000e+00
  %121 = or i1 %119, %120
  %122 = select i1 %121, float %117, float %118
  %123 = load volatile float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 25), align 4
  %124 = fcmp oge float %122, %123
  %125 = fcmp ueq float %122, 0.000000e+00
  %126 = or i1 %124, %125
  %127 = select i1 %126, float %122, float %123
  %128 = load volatile float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 26), align 4
  %129 = fcmp oge float %127, %128
  %130 = fcmp ueq float %127, 0.000000e+00
  %131 = or i1 %129, %130
  %132 = select i1 %131, float %127, float %128
  %133 = load volatile float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 27), align 4
  %134 = fcmp oge float %132, %133
  %135 = fcmp ueq float %132, 0.000000e+00
  %136 = or i1 %134, %135
  %137 = select i1 %136, float %132, float %133
  %138 = load volatile float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 28), align 4
  %139 = fcmp oge float %137, %138
  %140 = fcmp ueq float %137, 0.000000e+00
  %141 = or i1 %139, %140
  %142 = select i1 %141, float %137, float %138
  %143 = load volatile float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 29), align 4
  %144 = fcmp oge float %142, %143
  %145 = fcmp ueq float %142, 0.000000e+00
  %146 = or i1 %144, %145
  %147 = select i1 %146, float %142, float %143
  %148 = load volatile float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 30), align 4
  %149 = fcmp oge float %147, %148
  %150 = fcmp ueq float %147, 0.000000e+00
  %151 = or i1 %149, %150
  %152 = select i1 %151, float %147, float %148
  %153 = load volatile float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 31), align 4
  %154 = fcmp oge float %152, %153
  %155 = fcmp ueq float %152, 0.000000e+00
  %156 = or i1 %154, %155
  %157 = select i1 %156, float %152, float %153
  %158 = load volatile float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 32), align 4
  %159 = fcmp oge float %157, %158
  %160 = fcmp ueq float %157, 0.000000e+00
  %161 = or i1 %159, %160
  %162 = select i1 %161, float %157, float %158
  %163 = load volatile float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 33), align 4
  %164 = fcmp oge float %162, %163
  %165 = fcmp ueq float %162, 0.000000e+00
  %166 = or i1 %164, %165
  %167 = select i1 %166, float %162, float %163
  %168 = load volatile float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 34), align 4
  %169 = fcmp oge float %167, %168
  %170 = fcmp ueq float %167, 0.000000e+00
  %171 = or i1 %169, %170
  %172 = select i1 %171, float %167, float %168
  %173 = load volatile float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 35), align 4
  %174 = fcmp oge float %172, %173
  %175 = fcmp ueq float %172, 0.000000e+00
  %176 = or i1 %174, %175
  %177 = select i1 %176, float %172, float %173
  %178 = load volatile float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 36), align 4
  %179 = fcmp oge float %177, %178
  %180 = fcmp ueq float %177, 0.000000e+00
  %181 = or i1 %179, %180
  %182 = select i1 %181, float %177, float %178
  %183 = load volatile float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 37), align 4
  %184 = fcmp oge float %182, %183
  %185 = fcmp ueq float %182, 0.000000e+00
  %186 = or i1 %184, %185
  %187 = select i1 %186, float %182, float %183
  %188 = load volatile float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 38), align 4
  %189 = fcmp oge float %187, %188
  %190 = fcmp ueq float %187, 0.000000e+00
  %191 = or i1 %189, %190
  %192 = select i1 %191, float %187, float %188
  %193 = load volatile float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 39), align 4
  %194 = fcmp oge float %192, %193
  %195 = fcmp ueq float %192, 0.000000e+00
  %196 = or i1 %194, %195
  %197 = select i1 %196, float %192, float %193
  %198 = load volatile float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 40), align 4
  %199 = fcmp oge float %197, %198
  %200 = fcmp ueq float %197, 0.000000e+00
  %201 = or i1 %199, %200
  %202 = select i1 %201, float %197, float %198
  %203 = load volatile float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 41), align 4
  %204 = fcmp oge float %202, %203
  %205 = fcmp ueq float %202, 0.000000e+00
  %206 = or i1 %204, %205
  %207 = select i1 %206, float %202, float %203
  %208 = load volatile float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 42), align 4
  %209 = fcmp oge float %207, %208
  %210 = fcmp ueq float %207, 0.000000e+00
  %211 = or i1 %209, %210
  %212 = select i1 %211, float %207, float %208
  %213 = load volatile float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 43), align 4
  %214 = fcmp oge float %212, %213
  %215 = fcmp ueq float %212, 0.000000e+00
  %216 = or i1 %214, %215
  %217 = select i1 %216, float %212, float %213
  %218 = load volatile float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 44), align 4
  %219 = fcmp oge float %217, %218
  %220 = fcmp ueq float %217, 0.000000e+00
  %221 = or i1 %219, %220
  %222 = select i1 %221, float %217, float %218
  %223 = load volatile float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 45), align 4
  %224 = fcmp oge float %222, %223
  %225 = fcmp ueq float %222, 0.000000e+00
  %226 = or i1 %224, %225
  %227 = select i1 %226, float %222, float %223
  %228 = load volatile float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 46), align 4
  %229 = fcmp oge float %227, %228
  %230 = fcmp ueq float %227, 0.000000e+00
  %231 = or i1 %229, %230
  %232 = select i1 %231, float %227, float %228
  %233 = load volatile float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 47), align 4
  %234 = fcmp oge float %232, %233
  %235 = fcmp ueq float %232, 0.000000e+00
  %236 = or i1 %234, %235
  %237 = select i1 %236, float %232, float %233
  %238 = load volatile float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 48), align 4
  %239 = fcmp oge float %237, %238
  %240 = fcmp ueq float %237, 0.000000e+00
  %241 = or i1 %239, %240
  %242 = select i1 %241, float %237, float %238
  %243 = load volatile float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 49), align 4
  %244 = fcmp oge float %242, %243
  %245 = fcmp ueq float %242, 0.000000e+00
  %246 = or i1 %244, %245
  %247 = select i1 %246, float %242, float %243
  %248 = load volatile float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 50), align 4
  %249 = fcmp oge float %247, %248
  %250 = fcmp ueq float %247, 0.000000e+00
  %251 = or i1 %249, %250
  %252 = select i1 %251, float %247, float %248
  %253 = load volatile float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 51), align 4
  %254 = fcmp oge float %252, %253
  %255 = fcmp ueq float %252, 0.000000e+00
  %256 = or i1 %254, %255
  %257 = select i1 %256, float %252, float %253
  %258 = load volatile float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 52), align 4
  %259 = fcmp oge float %257, %258
  %260 = fcmp ueq float %257, 0.000000e+00
  %261 = or i1 %259, %260
  %262 = select i1 %261, float %257, float %258
  %263 = load volatile float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 53), align 4
  %264 = fcmp oge float %262, %263
  %265 = fcmp ueq float %262, 0.000000e+00
  %266 = or i1 %264, %265
  %267 = select i1 %266, float %262, float %263
  %268 = load volatile float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 54), align 4
  %269 = fcmp oge float %267, %268
  %270 = fcmp ueq float %267, 0.000000e+00
  %271 = or i1 %269, %270
  %272 = select i1 %271, float %267, float %268
  %273 = load volatile float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 55), align 4
  %274 = fcmp oge float %272, %273
  %275 = fcmp ueq float %272, 0.000000e+00
  %276 = or i1 %274, %275
  %277 = select i1 %276, float %272, float %273
  %278 = load volatile float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 56), align 4
  %279 = fcmp oge float %277, %278
  %280 = fcmp ueq float %277, 0.000000e+00
  %281 = or i1 %279, %280
  %282 = select i1 %281, float %277, float %278
  %283 = load volatile float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 57), align 4
  %284 = fcmp oge float %282, %283
  %285 = fcmp ueq float %282, 0.000000e+00
  %286 = or i1 %284, %285
  %287 = select i1 %286, float %282, float %283
  %288 = load volatile float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 58), align 4
  %289 = fcmp oge float %287, %288
  %290 = fcmp ueq float %287, 0.000000e+00
  %291 = or i1 %289, %290
  %292 = select i1 %291, float %287, float %288
  %293 = load volatile float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 59), align 4
  %294 = fcmp oge float %292, %293
  %295 = fcmp ueq float %292, 0.000000e+00
  %296 = or i1 %294, %295
  %297 = select i1 %296, float %292, float %293
  %298 = load volatile float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 60), align 4
  %299 = fcmp oge float %297, %298
  %300 = fcmp ueq float %297, 0.000000e+00
  %301 = or i1 %299, %300
  %302 = select i1 %301, float %297, float %298
  %303 = load volatile float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 61), align 4
  %304 = fcmp oge float %302, %303
  %305 = fcmp ueq float %302, 0.000000e+00
  %306 = or i1 %304, %305
  %307 = select i1 %306, float %302, float %303
  %308 = load volatile float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 62), align 4
  %309 = fcmp oge float %307, %308
  %310 = fcmp ueq float %307, 0.000000e+00
  %311 = or i1 %309, %310
  %312 = select i1 %311, float %307, float %308
  %313 = load volatile float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 63), align 4
  %314 = fcmp oge float %312, %313
  %315 = fcmp ueq float %312, 0.000000e+00
  %316 = or i1 %314, %315
  %317 = select i1 %316, float %312, float %313
  %318 = load float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 0), align 4
  %319 = fsub float %318, %317
  %320 = call float @expf(float %319)
  store float %320, float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 0), align 4
  %321 = load float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 1), align 4
  %322 = fsub float %321, %317
  %323 = call float @expf(float %322)
  store float %323, float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 1), align 4
  %324 = load float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 2), align 4
  %325 = fsub float %324, %317
  %326 = call float @expf(float %325)
  store float %326, float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 2), align 4
  %327 = load float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 3), align 4
  %328 = fsub float %327, %317
  %329 = call float @expf(float %328)
  store float %329, float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 3), align 4
  %330 = load float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 4), align 4
  %331 = fsub float %330, %317
  %332 = call float @expf(float %331)
  store float %332, float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 4), align 4
  %333 = load float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 5), align 4
  %334 = fsub float %333, %317
  %335 = call float @expf(float %334)
  store float %335, float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 5), align 4
  %336 = load float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 6), align 4
  %337 = fsub float %336, %317
  %338 = call float @expf(float %337)
  store float %338, float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 6), align 4
  %339 = load float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 7), align 4
  %340 = fsub float %339, %317
  %341 = call float @expf(float %340)
  store float %341, float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 7), align 4
  %342 = load float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 8), align 4
  %343 = fsub float %342, %317
  %344 = call float @expf(float %343)
  store float %344, float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 8), align 4
  %345 = load float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 9), align 4
  %346 = fsub float %345, %317
  %347 = call float @expf(float %346)
  store float %347, float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 9), align 4
  %348 = load float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 10), align 4
  %349 = fsub float %348, %317
  %350 = call float @expf(float %349)
  store float %350, float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 10), align 4
  %351 = load float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 11), align 4
  %352 = fsub float %351, %317
  %353 = call float @expf(float %352)
  store float %353, float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 11), align 4
  %354 = load float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 12), align 4
  %355 = fsub float %354, %317
  %356 = call float @expf(float %355)
  store float %356, float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 12), align 4
  %357 = load float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 13), align 4
  %358 = fsub float %357, %317
  %359 = call float @expf(float %358)
  store float %359, float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 13), align 4
  %360 = load float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 14), align 4
  %361 = fsub float %360, %317
  %362 = call float @expf(float %361)
  store float %362, float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 14), align 4
  %363 = load float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 15), align 4
  %364 = fsub float %363, %317
  %365 = call float @expf(float %364)
  store float %365, float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 15), align 4
  %366 = load float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 16), align 4
  %367 = fsub float %366, %317
  %368 = call float @expf(float %367)
  store float %368, float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 16), align 4
  %369 = load float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 17), align 4
  %370 = fsub float %369, %317
  %371 = call float @expf(float %370)
  store float %371, float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 17), align 4
  %372 = load float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 18), align 4
  %373 = fsub float %372, %317
  %374 = call float @expf(float %373)
  store float %374, float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 18), align 4
  %375 = load float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 19), align 4
  %376 = fsub float %375, %317
  %377 = call float @expf(float %376)
  store float %377, float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 19), align 4
  %378 = load float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 20), align 4
  %379 = fsub float %378, %317
  %380 = call float @expf(float %379)
  store float %380, float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 20), align 4
  %381 = load float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 21), align 4
  %382 = fsub float %381, %317
  %383 = call float @expf(float %382)
  store float %383, float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 21), align 4
  %384 = load float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 22), align 4
  %385 = fsub float %384, %317
  %386 = call float @expf(float %385)
  store float %386, float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 22), align 4
  %387 = load float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 23), align 4
  %388 = fsub float %387, %317
  %389 = call float @expf(float %388)
  store float %389, float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 23), align 4
  %390 = load float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 24), align 4
  %391 = fsub float %390, %317
  %392 = call float @expf(float %391)
  store float %392, float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 24), align 4
  %393 = load float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 25), align 4
  %394 = fsub float %393, %317
  %395 = call float @expf(float %394)
  store float %395, float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 25), align 4
  %396 = load float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 26), align 4
  %397 = fsub float %396, %317
  %398 = call float @expf(float %397)
  store float %398, float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 26), align 4
  %399 = load float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 27), align 4
  %400 = fsub float %399, %317
  %401 = call float @expf(float %400)
  store float %401, float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 27), align 4
  %402 = load float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 28), align 4
  %403 = fsub float %402, %317
  %404 = call float @expf(float %403)
  store float %404, float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 28), align 4
  %405 = load float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 29), align 4
  %406 = fsub float %405, %317
  %407 = call float @expf(float %406)
  store float %407, float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 29), align 4
  %408 = load float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 30), align 4
  %409 = fsub float %408, %317
  %410 = call float @expf(float %409)
  store float %410, float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 30), align 4
  %411 = load float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 31), align 4
  %412 = fsub float %411, %317
  %413 = call float @expf(float %412)
  store float %413, float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 31), align 4
  %414 = load float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 32), align 4
  %415 = fsub float %414, %317
  %416 = call float @expf(float %415)
  store float %416, float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 32), align 4
  %417 = load float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 33), align 4
  %418 = fsub float %417, %317
  %419 = call float @expf(float %418)
  store float %419, float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 33), align 4
  %420 = load float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 34), align 4
  %421 = fsub float %420, %317
  %422 = call float @expf(float %421)
  store float %422, float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 34), align 4
  %423 = load float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 35), align 4
  %424 = fsub float %423, %317
  %425 = call float @expf(float %424)
  store float %425, float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 35), align 4
  %426 = load float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 36), align 4
  %427 = fsub float %426, %317
  %428 = call float @expf(float %427)
  store float %428, float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 36), align 4
  %429 = load float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 37), align 4
  %430 = fsub float %429, %317
  %431 = call float @expf(float %430)
  store float %431, float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 37), align 4
  %432 = load float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 38), align 4
  %433 = fsub float %432, %317
  %434 = call float @expf(float %433)
  store float %434, float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 38), align 4
  %435 = load float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 39), align 4
  %436 = fsub float %435, %317
  %437 = call float @expf(float %436)
  store float %437, float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 39), align 4
  %438 = load float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 40), align 4
  %439 = fsub float %438, %317
  %440 = call float @expf(float %439)
  store float %440, float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 40), align 4
  %441 = load float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 41), align 4
  %442 = fsub float %441, %317
  %443 = call float @expf(float %442)
  store float %443, float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 41), align 4
  %444 = load float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 42), align 4
  %445 = fsub float %444, %317
  %446 = call float @expf(float %445)
  store float %446, float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 42), align 4
  %447 = load float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 43), align 4
  %448 = fsub float %447, %317
  %449 = call float @expf(float %448)
  store float %449, float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 43), align 4
  %450 = load float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 44), align 4
  %451 = fsub float %450, %317
  %452 = call float @expf(float %451)
  store float %452, float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 44), align 4
  %453 = load float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 45), align 4
  %454 = fsub float %453, %317
  %455 = call float @expf(float %454)
  store float %455, float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 45), align 4
  %456 = load float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 46), align 4
  %457 = fsub float %456, %317
  %458 = call float @expf(float %457)
  store float %458, float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 46), align 4
  %459 = load float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 47), align 4
  %460 = fsub float %459, %317
  %461 = call float @expf(float %460)
  store float %461, float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 47), align 4
  %462 = load float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 48), align 4
  %463 = fsub float %462, %317
  %464 = call float @expf(float %463)
  store float %464, float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 48), align 4
  %465 = load float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 49), align 4
  %466 = fsub float %465, %317
  %467 = call float @expf(float %466)
  store float %467, float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 49), align 4
  %468 = load float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 50), align 4
  %469 = fsub float %468, %317
  %470 = call float @expf(float %469)
  store float %470, float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 50), align 4
  %471 = load float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 51), align 4
  %472 = fsub float %471, %317
  %473 = call float @expf(float %472)
  store float %473, float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 51), align 4
  %474 = load float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 52), align 4
  %475 = fsub float %474, %317
  %476 = call float @expf(float %475)
  store float %476, float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 52), align 4
  %477 = load float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 53), align 4
  %478 = fsub float %477, %317
  %479 = call float @expf(float %478)
  store float %479, float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 53), align 4
  %480 = load float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 54), align 4
  %481 = fsub float %480, %317
  %482 = call float @expf(float %481)
  store float %482, float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 54), align 4
  %483 = load float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 55), align 4
  %484 = fsub float %483, %317
  %485 = call float @expf(float %484)
  store float %485, float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 55), align 4
  %486 = load float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 56), align 4
  %487 = fsub float %486, %317
  %488 = call float @expf(float %487)
  store float %488, float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 56), align 4
  %489 = load float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 57), align 4
  %490 = fsub float %489, %317
  %491 = call float @expf(float %490)
  store float %491, float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 57), align 4
  %492 = load float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 58), align 4
  %493 = fsub float %492, %317
  %494 = call float @expf(float %493)
  store float %494, float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 58), align 4
  %495 = load float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 59), align 4
  %496 = fsub float %495, %317
  %497 = call float @expf(float %496)
  store float %497, float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 59), align 4
  %498 = load float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 60), align 4
  %499 = fsub float %498, %317
  %500 = call float @expf(float %499)
  store float %500, float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 60), align 4
  %501 = load float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 61), align 4
  %502 = fsub float %501, %317
  %503 = call float @expf(float %502)
  store float %503, float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 61), align 4
  %504 = load float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 62), align 4
  %505 = fsub float %504, %317
  %506 = call float @expf(float %505)
  store float %506, float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 62), align 4
  %507 = load float* getelementptr inbounds ([1 x [64 x float]]* @param0, i64 0, i64 0, i64 63), align 4
  %508 = fsub float %507, %317
  %509 = call float @expf(float %508)
  store float %509, float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 63), align 4
  %510 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 0), align 4
  %511 = fadd float 0.000000e+00, %510
  %512 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 1), align 4
  %513 = fadd float %511, %512
  %514 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 2), align 4
  %515 = fadd float %513, %514
  %516 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 3), align 4
  %517 = fadd float %515, %516
  %518 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 4), align 4
  %519 = fadd float %517, %518
  %520 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 5), align 4
  %521 = fadd float %519, %520
  %522 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 6), align 4
  %523 = fadd float %521, %522
  %524 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 7), align 4
  %525 = fadd float %523, %524
  %526 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 8), align 4
  %527 = fadd float %525, %526
  %528 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 9), align 4
  %529 = fadd float %527, %528
  %530 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 10), align 4
  %531 = fadd float %529, %530
  %532 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 11), align 4
  %533 = fadd float %531, %532
  %534 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 12), align 4
  %535 = fadd float %533, %534
  %536 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 13), align 4
  %537 = fadd float %535, %536
  %538 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 14), align 4
  %539 = fadd float %537, %538
  %540 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 15), align 4
  %541 = fadd float %539, %540
  %542 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 16), align 4
  %543 = fadd float %541, %542
  %544 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 17), align 4
  %545 = fadd float %543, %544
  %546 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 18), align 4
  %547 = fadd float %545, %546
  %548 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 19), align 4
  %549 = fadd float %547, %548
  %550 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 20), align 4
  %551 = fadd float %549, %550
  %552 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 21), align 4
  %553 = fadd float %551, %552
  %554 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 22), align 4
  %555 = fadd float %553, %554
  %556 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 23), align 4
  %557 = fadd float %555, %556
  %558 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 24), align 4
  %559 = fadd float %557, %558
  %560 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 25), align 4
  %561 = fadd float %559, %560
  %562 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 26), align 4
  %563 = fadd float %561, %562
  %564 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 27), align 4
  %565 = fadd float %563, %564
  %566 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 28), align 4
  %567 = fadd float %565, %566
  %568 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 29), align 4
  %569 = fadd float %567, %568
  %570 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 30), align 4
  %571 = fadd float %569, %570
  %572 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 31), align 4
  %573 = fadd float %571, %572
  %574 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 32), align 4
  %575 = fadd float %573, %574
  %576 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 33), align 4
  %577 = fadd float %575, %576
  %578 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 34), align 4
  %579 = fadd float %577, %578
  %580 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 35), align 4
  %581 = fadd float %579, %580
  %582 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 36), align 4
  %583 = fadd float %581, %582
  %584 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 37), align 4
  %585 = fadd float %583, %584
  %586 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 38), align 4
  %587 = fadd float %585, %586
  %588 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 39), align 4
  %589 = fadd float %587, %588
  %590 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 40), align 4
  %591 = fadd float %589, %590
  %592 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 41), align 4
  %593 = fadd float %591, %592
  %594 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 42), align 4
  %595 = fadd float %593, %594
  %596 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 43), align 4
  %597 = fadd float %595, %596
  %598 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 44), align 4
  %599 = fadd float %597, %598
  %600 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 45), align 4
  %601 = fadd float %599, %600
  %602 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 46), align 4
  %603 = fadd float %601, %602
  %604 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 47), align 4
  %605 = fadd float %603, %604
  %606 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 48), align 4
  %607 = fadd float %605, %606
  %608 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 49), align 4
  %609 = fadd float %607, %608
  %610 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 50), align 4
  %611 = fadd float %609, %610
  %612 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 51), align 4
  %613 = fadd float %611, %612
  %614 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 52), align 4
  %615 = fadd float %613, %614
  %616 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 53), align 4
  %617 = fadd float %615, %616
  %618 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 54), align 4
  %619 = fadd float %617, %618
  %620 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 55), align 4
  %621 = fadd float %619, %620
  %622 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 56), align 4
  %623 = fadd float %621, %622
  %624 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 57), align 4
  %625 = fadd float %623, %624
  %626 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 58), align 4
  %627 = fadd float %625, %626
  %628 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 59), align 4
  %629 = fadd float %627, %628
  %630 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 60), align 4
  %631 = fadd float %629, %630
  %632 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 61), align 4
  %633 = fadd float %631, %632
  %634 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 62), align 4
  %635 = fadd float %633, %634
  %636 = fadd float %635, %509
  %637 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 0), align 4
  %638 = fdiv float %637, %636
  store volatile float %638, float* getelementptr inbounds ([64 x float]* @temp3, i64 0, i64 0), align 4
  %639 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 1), align 4
  %640 = fdiv float %639, %636
  store volatile float %640, float* getelementptr inbounds ([64 x float]* @temp3, i64 0, i64 1), align 4
  %641 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 2), align 4
  %642 = fdiv float %641, %636
  store volatile float %642, float* getelementptr inbounds ([64 x float]* @temp3, i64 0, i64 2), align 4
  %643 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 3), align 4
  %644 = fdiv float %643, %636
  store volatile float %644, float* getelementptr inbounds ([64 x float]* @temp3, i64 0, i64 3), align 4
  %645 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 4), align 4
  %646 = fdiv float %645, %636
  store volatile float %646, float* getelementptr inbounds ([64 x float]* @temp3, i64 0, i64 4), align 4
  %647 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 5), align 4
  %648 = fdiv float %647, %636
  store volatile float %648, float* getelementptr inbounds ([64 x float]* @temp3, i64 0, i64 5), align 4
  %649 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 6), align 4
  %650 = fdiv float %649, %636
  store volatile float %650, float* getelementptr inbounds ([64 x float]* @temp3, i64 0, i64 6), align 4
  %651 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 7), align 4
  %652 = fdiv float %651, %636
  store volatile float %652, float* getelementptr inbounds ([64 x float]* @temp3, i64 0, i64 7), align 4
  %653 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 8), align 4
  %654 = fdiv float %653, %636
  store volatile float %654, float* getelementptr inbounds ([64 x float]* @temp3, i64 0, i64 8), align 4
  %655 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 9), align 4
  %656 = fdiv float %655, %636
  store volatile float %656, float* getelementptr inbounds ([64 x float]* @temp3, i64 0, i64 9), align 4
  %657 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 10), align 4
  %658 = fdiv float %657, %636
  store volatile float %658, float* getelementptr inbounds ([64 x float]* @temp3, i64 0, i64 10), align 4
  %659 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 11), align 4
  %660 = fdiv float %659, %636
  store volatile float %660, float* getelementptr inbounds ([64 x float]* @temp3, i64 0, i64 11), align 4
  %661 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 12), align 4
  %662 = fdiv float %661, %636
  store volatile float %662, float* getelementptr inbounds ([64 x float]* @temp3, i64 0, i64 12), align 4
  %663 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 13), align 4
  %664 = fdiv float %663, %636
  store volatile float %664, float* getelementptr inbounds ([64 x float]* @temp3, i64 0, i64 13), align 4
  %665 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 14), align 4
  %666 = fdiv float %665, %636
  store volatile float %666, float* getelementptr inbounds ([64 x float]* @temp3, i64 0, i64 14), align 4
  %667 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 15), align 4
  %668 = fdiv float %667, %636
  store volatile float %668, float* getelementptr inbounds ([64 x float]* @temp3, i64 0, i64 15), align 4
  %669 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 16), align 4
  %670 = fdiv float %669, %636
  store volatile float %670, float* getelementptr inbounds ([64 x float]* @temp3, i64 0, i64 16), align 4
  %671 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 17), align 4
  %672 = fdiv float %671, %636
  store volatile float %672, float* getelementptr inbounds ([64 x float]* @temp3, i64 0, i64 17), align 4
  %673 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 18), align 4
  %674 = fdiv float %673, %636
  store volatile float %674, float* getelementptr inbounds ([64 x float]* @temp3, i64 0, i64 18), align 4
  %675 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 19), align 4
  %676 = fdiv float %675, %636
  store volatile float %676, float* getelementptr inbounds ([64 x float]* @temp3, i64 0, i64 19), align 4
  %677 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 20), align 4
  %678 = fdiv float %677, %636
  store volatile float %678, float* getelementptr inbounds ([64 x float]* @temp3, i64 0, i64 20), align 4
  %679 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 21), align 4
  %680 = fdiv float %679, %636
  store volatile float %680, float* getelementptr inbounds ([64 x float]* @temp3, i64 0, i64 21), align 4
  %681 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 22), align 4
  %682 = fdiv float %681, %636
  store volatile float %682, float* getelementptr inbounds ([64 x float]* @temp3, i64 0, i64 22), align 4
  %683 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 23), align 4
  %684 = fdiv float %683, %636
  store volatile float %684, float* getelementptr inbounds ([64 x float]* @temp3, i64 0, i64 23), align 4
  %685 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 24), align 4
  %686 = fdiv float %685, %636
  store volatile float %686, float* getelementptr inbounds ([64 x float]* @temp3, i64 0, i64 24), align 4
  %687 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 25), align 4
  %688 = fdiv float %687, %636
  store volatile float %688, float* getelementptr inbounds ([64 x float]* @temp3, i64 0, i64 25), align 4
  %689 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 26), align 4
  %690 = fdiv float %689, %636
  store volatile float %690, float* getelementptr inbounds ([64 x float]* @temp3, i64 0, i64 26), align 4
  %691 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 27), align 4
  %692 = fdiv float %691, %636
  store volatile float %692, float* getelementptr inbounds ([64 x float]* @temp3, i64 0, i64 27), align 4
  %693 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 28), align 4
  %694 = fdiv float %693, %636
  store volatile float %694, float* getelementptr inbounds ([64 x float]* @temp3, i64 0, i64 28), align 4
  %695 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 29), align 4
  %696 = fdiv float %695, %636
  store volatile float %696, float* getelementptr inbounds ([64 x float]* @temp3, i64 0, i64 29), align 4
  %697 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 30), align 4
  %698 = fdiv float %697, %636
  store volatile float %698, float* getelementptr inbounds ([64 x float]* @temp3, i64 0, i64 30), align 4
  %699 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 31), align 4
  %700 = fdiv float %699, %636
  store volatile float %700, float* getelementptr inbounds ([64 x float]* @temp3, i64 0, i64 31), align 4
  %701 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 32), align 4
  %702 = fdiv float %701, %636
  store volatile float %702, float* getelementptr inbounds ([64 x float]* @temp3, i64 0, i64 32), align 4
  %703 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 33), align 4
  %704 = fdiv float %703, %636
  store volatile float %704, float* getelementptr inbounds ([64 x float]* @temp3, i64 0, i64 33), align 4
  %705 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 34), align 4
  %706 = fdiv float %705, %636
  store volatile float %706, float* getelementptr inbounds ([64 x float]* @temp3, i64 0, i64 34), align 4
  %707 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 35), align 4
  %708 = fdiv float %707, %636
  store volatile float %708, float* getelementptr inbounds ([64 x float]* @temp3, i64 0, i64 35), align 4
  %709 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 36), align 4
  %710 = fdiv float %709, %636
  store volatile float %710, float* getelementptr inbounds ([64 x float]* @temp3, i64 0, i64 36), align 4
  %711 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 37), align 4
  %712 = fdiv float %711, %636
  store volatile float %712, float* getelementptr inbounds ([64 x float]* @temp3, i64 0, i64 37), align 4
  %713 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 38), align 4
  %714 = fdiv float %713, %636
  store volatile float %714, float* getelementptr inbounds ([64 x float]* @temp3, i64 0, i64 38), align 4
  %715 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 39), align 4
  %716 = fdiv float %715, %636
  store volatile float %716, float* getelementptr inbounds ([64 x float]* @temp3, i64 0, i64 39), align 4
  %717 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 40), align 4
  %718 = fdiv float %717, %636
  store volatile float %718, float* getelementptr inbounds ([64 x float]* @temp3, i64 0, i64 40), align 4
  %719 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 41), align 4
  %720 = fdiv float %719, %636
  store volatile float %720, float* getelementptr inbounds ([64 x float]* @temp3, i64 0, i64 41), align 4
  %721 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 42), align 4
  %722 = fdiv float %721, %636
  store volatile float %722, float* getelementptr inbounds ([64 x float]* @temp3, i64 0, i64 42), align 4
  %723 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 43), align 4
  %724 = fdiv float %723, %636
  store volatile float %724, float* getelementptr inbounds ([64 x float]* @temp3, i64 0, i64 43), align 4
  %725 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 44), align 4
  %726 = fdiv float %725, %636
  store volatile float %726, float* getelementptr inbounds ([64 x float]* @temp3, i64 0, i64 44), align 4
  %727 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 45), align 4
  %728 = fdiv float %727, %636
  store volatile float %728, float* getelementptr inbounds ([64 x float]* @temp3, i64 0, i64 45), align 4
  %729 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 46), align 4
  %730 = fdiv float %729, %636
  store volatile float %730, float* getelementptr inbounds ([64 x float]* @temp3, i64 0, i64 46), align 4
  %731 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 47), align 4
  %732 = fdiv float %731, %636
  store volatile float %732, float* getelementptr inbounds ([64 x float]* @temp3, i64 0, i64 47), align 4
  %733 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 48), align 4
  %734 = fdiv float %733, %636
  store volatile float %734, float* getelementptr inbounds ([64 x float]* @temp3, i64 0, i64 48), align 4
  %735 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 49), align 4
  %736 = fdiv float %735, %636
  store volatile float %736, float* getelementptr inbounds ([64 x float]* @temp3, i64 0, i64 49), align 4
  %737 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 50), align 4
  %738 = fdiv float %737, %636
  store volatile float %738, float* getelementptr inbounds ([64 x float]* @temp3, i64 0, i64 50), align 4
  %739 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 51), align 4
  %740 = fdiv float %739, %636
  store volatile float %740, float* getelementptr inbounds ([64 x float]* @temp3, i64 0, i64 51), align 4
  %741 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 52), align 4
  %742 = fdiv float %741, %636
  store volatile float %742, float* getelementptr inbounds ([64 x float]* @temp3, i64 0, i64 52), align 4
  %743 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 53), align 4
  %744 = fdiv float %743, %636
  store volatile float %744, float* getelementptr inbounds ([64 x float]* @temp3, i64 0, i64 53), align 4
  %745 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 54), align 4
  %746 = fdiv float %745, %636
  store volatile float %746, float* getelementptr inbounds ([64 x float]* @temp3, i64 0, i64 54), align 4
  %747 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 55), align 4
  %748 = fdiv float %747, %636
  store volatile float %748, float* getelementptr inbounds ([64 x float]* @temp3, i64 0, i64 55), align 4
  %749 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 56), align 4
  %750 = fdiv float %749, %636
  store volatile float %750, float* getelementptr inbounds ([64 x float]* @temp3, i64 0, i64 56), align 4
  %751 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 57), align 4
  %752 = fdiv float %751, %636
  store volatile float %752, float* getelementptr inbounds ([64 x float]* @temp3, i64 0, i64 57), align 4
  %753 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 58), align 4
  %754 = fdiv float %753, %636
  store volatile float %754, float* getelementptr inbounds ([64 x float]* @temp3, i64 0, i64 58), align 4
  %755 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 59), align 4
  %756 = fdiv float %755, %636
  store volatile float %756, float* getelementptr inbounds ([64 x float]* @temp3, i64 0, i64 59), align 4
  %757 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 60), align 4
  %758 = fdiv float %757, %636
  store volatile float %758, float* getelementptr inbounds ([64 x float]* @temp3, i64 0, i64 60), align 4
  %759 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 61), align 4
  %760 = fdiv float %759, %636
  store volatile float %760, float* getelementptr inbounds ([64 x float]* @temp3, i64 0, i64 61), align 4
  %761 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 62), align 4
  %762 = fdiv float %761, %636
  store volatile float %762, float* getelementptr inbounds ([64 x float]* @temp3, i64 0, i64 62), align 4
  %763 = load float* getelementptr inbounds ([64 x float]* @temp1.0, i32 0, i64 63), align 4
  %764 = fdiv float %763, %636
  store volatile float %764, float* getelementptr inbounds ([64 x float]* @temp3, i64 0, i64 63), align 4
  %leflow_retval = load volatile float* getelementptr inbounds ([64 x float]* @temp3, i64 0, i64 0), align 4
  ret float %leflow_retval
}

declare float @expf(float)

attributes #0 = { nounwind "no-frame-pointer-elim"="false" }
