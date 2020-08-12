; ModuleID = '08_softmax_b_f_files/08_softmax_b_f_ir_4.bc'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux_gnu"

@temp3 = global [64 x float] zeroinitializer, align 8
@temp2 = global float zeroinitializer, align 8
@temp1 = global [1 x [64 x float]] zeroinitializer, align 8
@temp0 = global float zeroinitializer, align 8
@param0 = global [1 x [64 x float]] zeroinitializer, align 8

define float @main() #0 {
reduce.inner.loop_body.reduction_dim.1.lr.ph:
  %0 = getelementptr inbounds [1 x [64 x float]]* @param0, i64 0, i64 0, i64 0
  %1 = load volatile float* %0, align 4
  %2 = fcmp oge float 0xFFF0000000000000, %1
  %3 = select i1 %2, float 0xFFF0000000000000, float %1
  %4 = getelementptr inbounds [1 x [64 x float]]* @param0, i64 0, i64 0, i64 1
  %5 = load volatile float* %4, align 4
  %6 = fcmp oge float %3, %5
  %7 = fcmp uno float %3, 0.000000e+00
  %8 = or i1 %6, %7
  %9 = select i1 %8, float %3, float %5
  %10 = getelementptr inbounds [1 x [64 x float]]* @param0, i64 0, i64 0, i64 2
  %11 = load volatile float* %10, align 4
  %12 = fcmp oge float %9, %11
  %13 = fcmp uno float %9, 0.000000e+00
  %14 = or i1 %12, %13
  %15 = select i1 %14, float %9, float %11
  %16 = getelementptr inbounds [1 x [64 x float]]* @param0, i64 0, i64 0, i64 3
  %17 = load volatile float* %16, align 4
  %18 = fcmp oge float %15, %17
  %19 = fcmp uno float %15, 0.000000e+00
  %20 = or i1 %18, %19
  %21 = select i1 %20, float %15, float %17
  %22 = getelementptr inbounds [1 x [64 x float]]* @param0, i64 0, i64 0, i64 4
  %23 = load volatile float* %22, align 4
  %24 = fcmp oge float %21, %23
  %25 = fcmp uno float %21, 0.000000e+00
  %26 = or i1 %24, %25
  %27 = select i1 %26, float %21, float %23
  %28 = getelementptr inbounds [1 x [64 x float]]* @param0, i64 0, i64 0, i64 5
  %29 = load volatile float* %28, align 4
  %30 = fcmp oge float %27, %29
  %31 = fcmp uno float %27, 0.000000e+00
  %32 = or i1 %30, %31
  %33 = select i1 %32, float %27, float %29
  %34 = getelementptr inbounds [1 x [64 x float]]* @param0, i64 0, i64 0, i64 6
  %35 = load volatile float* %34, align 4
  %36 = fcmp oge float %33, %35
  %37 = fcmp uno float %33, 0.000000e+00
  %38 = or i1 %36, %37
  %39 = select i1 %38, float %33, float %35
  %40 = getelementptr inbounds [1 x [64 x float]]* @param0, i64 0, i64 0, i64 7
  %41 = load volatile float* %40, align 4
  %42 = fcmp oge float %39, %41
  %43 = fcmp uno float %39, 0.000000e+00
  %44 = or i1 %42, %43
  %45 = select i1 %44, float %39, float %41
  %46 = getelementptr inbounds [1 x [64 x float]]* @param0, i64 0, i64 0, i64 8
  %47 = load volatile float* %46, align 4
  %48 = fcmp oge float %45, %47
  %49 = fcmp uno float %45, 0.000000e+00
  %50 = or i1 %48, %49
  %51 = select i1 %50, float %45, float %47
  %52 = getelementptr inbounds [1 x [64 x float]]* @param0, i64 0, i64 0, i64 9
  %53 = load volatile float* %52, align 4
  %54 = fcmp oge float %51, %53
  %55 = fcmp uno float %51, 0.000000e+00
  %56 = or i1 %54, %55
  %57 = select i1 %56, float %51, float %53
  %58 = getelementptr inbounds [1 x [64 x float]]* @param0, i64 0, i64 0, i64 10
  %59 = load volatile float* %58, align 4
  %60 = fcmp oge float %57, %59
  %61 = fcmp uno float %57, 0.000000e+00
  %62 = or i1 %60, %61
  %63 = select i1 %62, float %57, float %59
  %64 = getelementptr inbounds [1 x [64 x float]]* @param0, i64 0, i64 0, i64 11
  %65 = load volatile float* %64, align 4
  %66 = fcmp oge float %63, %65
  %67 = fcmp uno float %63, 0.000000e+00
  %68 = or i1 %66, %67
  %69 = select i1 %68, float %63, float %65
  %70 = getelementptr inbounds [1 x [64 x float]]* @param0, i64 0, i64 0, i64 12
  %71 = load volatile float* %70, align 4
  %72 = fcmp oge float %69, %71
  %73 = fcmp uno float %69, 0.000000e+00
  %74 = or i1 %72, %73
  %75 = select i1 %74, float %69, float %71
  %76 = getelementptr inbounds [1 x [64 x float]]* @param0, i64 0, i64 0, i64 13
  %77 = load volatile float* %76, align 4
  %78 = fcmp oge float %75, %77
  %79 = fcmp uno float %75, 0.000000e+00
  %80 = or i1 %78, %79
  %81 = select i1 %80, float %75, float %77
  %82 = getelementptr inbounds [1 x [64 x float]]* @param0, i64 0, i64 0, i64 14
  %83 = load volatile float* %82, align 4
  %84 = fcmp oge float %81, %83
  %85 = fcmp uno float %81, 0.000000e+00
  %86 = or i1 %84, %85
  %87 = select i1 %86, float %81, float %83
  %88 = getelementptr inbounds [1 x [64 x float]]* @param0, i64 0, i64 0, i64 15
  %89 = load volatile float* %88, align 4
  %90 = fcmp oge float %87, %89
  %91 = fcmp uno float %87, 0.000000e+00
  %92 = or i1 %90, %91
  %93 = select i1 %92, float %87, float %89
  %94 = getelementptr inbounds [1 x [64 x float]]* @param0, i64 0, i64 0, i64 16
  %95 = load volatile float* %94, align 4
  %96 = fcmp oge float %93, %95
  %97 = fcmp uno float %93, 0.000000e+00
  %98 = or i1 %96, %97
  %99 = select i1 %98, float %93, float %95
  %100 = getelementptr inbounds [1 x [64 x float]]* @param0, i64 0, i64 0, i64 17
  %101 = load volatile float* %100, align 4
  %102 = fcmp oge float %99, %101
  %103 = fcmp uno float %99, 0.000000e+00
  %104 = or i1 %102, %103
  %105 = select i1 %104, float %99, float %101
  %106 = getelementptr inbounds [1 x [64 x float]]* @param0, i64 0, i64 0, i64 18
  %107 = load volatile float* %106, align 4
  %108 = fcmp oge float %105, %107
  %109 = fcmp uno float %105, 0.000000e+00
  %110 = or i1 %108, %109
  %111 = select i1 %110, float %105, float %107
  %112 = getelementptr inbounds [1 x [64 x float]]* @param0, i64 0, i64 0, i64 19
  %113 = load volatile float* %112, align 4
  %114 = fcmp oge float %111, %113
  %115 = fcmp uno float %111, 0.000000e+00
  %116 = or i1 %114, %115
  %117 = select i1 %116, float %111, float %113
  %118 = getelementptr inbounds [1 x [64 x float]]* @param0, i64 0, i64 0, i64 20
  %119 = load volatile float* %118, align 4
  %120 = fcmp oge float %117, %119
  %121 = fcmp uno float %117, 0.000000e+00
  %122 = or i1 %120, %121
  %123 = select i1 %122, float %117, float %119
  %124 = getelementptr inbounds [1 x [64 x float]]* @param0, i64 0, i64 0, i64 21
  %125 = load volatile float* %124, align 4
  %126 = fcmp oge float %123, %125
  %127 = fcmp uno float %123, 0.000000e+00
  %128 = or i1 %126, %127
  %129 = select i1 %128, float %123, float %125
  %130 = getelementptr inbounds [1 x [64 x float]]* @param0, i64 0, i64 0, i64 22
  %131 = load volatile float* %130, align 4
  %132 = fcmp oge float %129, %131
  %133 = fcmp uno float %129, 0.000000e+00
  %134 = or i1 %132, %133
  %135 = select i1 %134, float %129, float %131
  %136 = getelementptr inbounds [1 x [64 x float]]* @param0, i64 0, i64 0, i64 23
  %137 = load volatile float* %136, align 4
  %138 = fcmp oge float %135, %137
  %139 = fcmp uno float %135, 0.000000e+00
  %140 = or i1 %138, %139
  %141 = select i1 %140, float %135, float %137
  %142 = getelementptr inbounds [1 x [64 x float]]* @param0, i64 0, i64 0, i64 24
  %143 = load volatile float* %142, align 4
  %144 = fcmp oge float %141, %143
  %145 = fcmp uno float %141, 0.000000e+00
  %146 = or i1 %144, %145
  %147 = select i1 %146, float %141, float %143
  %148 = getelementptr inbounds [1 x [64 x float]]* @param0, i64 0, i64 0, i64 25
  %149 = load volatile float* %148, align 4
  %150 = fcmp oge float %147, %149
  %151 = fcmp uno float %147, 0.000000e+00
  %152 = or i1 %150, %151
  %153 = select i1 %152, float %147, float %149
  %154 = getelementptr inbounds [1 x [64 x float]]* @param0, i64 0, i64 0, i64 26
  %155 = load volatile float* %154, align 4
  %156 = fcmp oge float %153, %155
  %157 = fcmp uno float %153, 0.000000e+00
  %158 = or i1 %156, %157
  %159 = select i1 %158, float %153, float %155
  %160 = getelementptr inbounds [1 x [64 x float]]* @param0, i64 0, i64 0, i64 27
  %161 = load volatile float* %160, align 4
  %162 = fcmp oge float %159, %161
  %163 = fcmp uno float %159, 0.000000e+00
  %164 = or i1 %162, %163
  %165 = select i1 %164, float %159, float %161
  %166 = getelementptr inbounds [1 x [64 x float]]* @param0, i64 0, i64 0, i64 28
  %167 = load volatile float* %166, align 4
  %168 = fcmp oge float %165, %167
  %169 = fcmp uno float %165, 0.000000e+00
  %170 = or i1 %168, %169
  %171 = select i1 %170, float %165, float %167
  %172 = getelementptr inbounds [1 x [64 x float]]* @param0, i64 0, i64 0, i64 29
  %173 = load volatile float* %172, align 4
  %174 = fcmp oge float %171, %173
  %175 = fcmp uno float %171, 0.000000e+00
  %176 = or i1 %174, %175
  %177 = select i1 %176, float %171, float %173
  %178 = getelementptr inbounds [1 x [64 x float]]* @param0, i64 0, i64 0, i64 30
  %179 = load volatile float* %178, align 4
  %180 = fcmp oge float %177, %179
  %181 = fcmp uno float %177, 0.000000e+00
  %182 = or i1 %180, %181
  %183 = select i1 %182, float %177, float %179
  %184 = getelementptr inbounds [1 x [64 x float]]* @param0, i64 0, i64 0, i64 31
  %185 = load volatile float* %184, align 4
  %186 = fcmp oge float %183, %185
  %187 = fcmp uno float %183, 0.000000e+00
  %188 = or i1 %186, %187
  %189 = select i1 %188, float %183, float %185
  %190 = getelementptr inbounds [1 x [64 x float]]* @param0, i64 0, i64 0, i64 32
  %191 = load volatile float* %190, align 4
  %192 = fcmp oge float %189, %191
  %193 = fcmp uno float %189, 0.000000e+00
  %194 = or i1 %192, %193
  %195 = select i1 %194, float %189, float %191
  %196 = getelementptr inbounds [1 x [64 x float]]* @param0, i64 0, i64 0, i64 33
  %197 = load volatile float* %196, align 4
  %198 = fcmp oge float %195, %197
  %199 = fcmp uno float %195, 0.000000e+00
  %200 = or i1 %198, %199
  %201 = select i1 %200, float %195, float %197
  %202 = getelementptr inbounds [1 x [64 x float]]* @param0, i64 0, i64 0, i64 34
  %203 = load volatile float* %202, align 4
  %204 = fcmp oge float %201, %203
  %205 = fcmp uno float %201, 0.000000e+00
  %206 = or i1 %204, %205
  %207 = select i1 %206, float %201, float %203
  %208 = getelementptr inbounds [1 x [64 x float]]* @param0, i64 0, i64 0, i64 35
  %209 = load volatile float* %208, align 4
  %210 = fcmp oge float %207, %209
  %211 = fcmp uno float %207, 0.000000e+00
  %212 = or i1 %210, %211
  %213 = select i1 %212, float %207, float %209
  %214 = getelementptr inbounds [1 x [64 x float]]* @param0, i64 0, i64 0, i64 36
  %215 = load volatile float* %214, align 4
  %216 = fcmp oge float %213, %215
  %217 = fcmp uno float %213, 0.000000e+00
  %218 = or i1 %216, %217
  %219 = select i1 %218, float %213, float %215
  %220 = getelementptr inbounds [1 x [64 x float]]* @param0, i64 0, i64 0, i64 37
  %221 = load volatile float* %220, align 4
  %222 = fcmp oge float %219, %221
  %223 = fcmp uno float %219, 0.000000e+00
  %224 = or i1 %222, %223
  %225 = select i1 %224, float %219, float %221
  %226 = getelementptr inbounds [1 x [64 x float]]* @param0, i64 0, i64 0, i64 38
  %227 = load volatile float* %226, align 4
  %228 = fcmp oge float %225, %227
  %229 = fcmp uno float %225, 0.000000e+00
  %230 = or i1 %228, %229
  %231 = select i1 %230, float %225, float %227
  %232 = getelementptr inbounds [1 x [64 x float]]* @param0, i64 0, i64 0, i64 39
  %233 = load volatile float* %232, align 4
  %234 = fcmp oge float %231, %233
  %235 = fcmp uno float %231, 0.000000e+00
  %236 = or i1 %234, %235
  %237 = select i1 %236, float %231, float %233
  %238 = getelementptr inbounds [1 x [64 x float]]* @param0, i64 0, i64 0, i64 40
  %239 = load volatile float* %238, align 4
  %240 = fcmp oge float %237, %239
  %241 = fcmp uno float %237, 0.000000e+00
  %242 = or i1 %240, %241
  %243 = select i1 %242, float %237, float %239
  %244 = getelementptr inbounds [1 x [64 x float]]* @param0, i64 0, i64 0, i64 41
  %245 = load volatile float* %244, align 4
  %246 = fcmp oge float %243, %245
  %247 = fcmp uno float %243, 0.000000e+00
  %248 = or i1 %246, %247
  %249 = select i1 %248, float %243, float %245
  %250 = getelementptr inbounds [1 x [64 x float]]* @param0, i64 0, i64 0, i64 42
  %251 = load volatile float* %250, align 4
  %252 = fcmp oge float %249, %251
  %253 = fcmp uno float %249, 0.000000e+00
  %254 = or i1 %252, %253
  %255 = select i1 %254, float %249, float %251
  %256 = getelementptr inbounds [1 x [64 x float]]* @param0, i64 0, i64 0, i64 43
  %257 = load volatile float* %256, align 4
  %258 = fcmp oge float %255, %257
  %259 = fcmp uno float %255, 0.000000e+00
  %260 = or i1 %258, %259
  %261 = select i1 %260, float %255, float %257
  %262 = getelementptr inbounds [1 x [64 x float]]* @param0, i64 0, i64 0, i64 44
  %263 = load volatile float* %262, align 4
  %264 = fcmp oge float %261, %263
  %265 = fcmp uno float %261, 0.000000e+00
  %266 = or i1 %264, %265
  %267 = select i1 %266, float %261, float %263
  %268 = getelementptr inbounds [1 x [64 x float]]* @param0, i64 0, i64 0, i64 45
  %269 = load volatile float* %268, align 4
  %270 = fcmp oge float %267, %269
  %271 = fcmp uno float %267, 0.000000e+00
  %272 = or i1 %270, %271
  %273 = select i1 %272, float %267, float %269
  %274 = getelementptr inbounds [1 x [64 x float]]* @param0, i64 0, i64 0, i64 46
  %275 = load volatile float* %274, align 4
  %276 = fcmp oge float %273, %275
  %277 = fcmp uno float %273, 0.000000e+00
  %278 = or i1 %276, %277
  %279 = select i1 %278, float %273, float %275
  %280 = getelementptr inbounds [1 x [64 x float]]* @param0, i64 0, i64 0, i64 47
  %281 = load volatile float* %280, align 4
  %282 = fcmp oge float %279, %281
  %283 = fcmp uno float %279, 0.000000e+00
  %284 = or i1 %282, %283
  %285 = select i1 %284, float %279, float %281
  %286 = getelementptr inbounds [1 x [64 x float]]* @param0, i64 0, i64 0, i64 48
  %287 = load volatile float* %286, align 4
  %288 = fcmp oge float %285, %287
  %289 = fcmp uno float %285, 0.000000e+00
  %290 = or i1 %288, %289
  %291 = select i1 %290, float %285, float %287
  %292 = getelementptr inbounds [1 x [64 x float]]* @param0, i64 0, i64 0, i64 49
  %293 = load volatile float* %292, align 4
  %294 = fcmp oge float %291, %293
  %295 = fcmp uno float %291, 0.000000e+00
  %296 = or i1 %294, %295
  %297 = select i1 %296, float %291, float %293
  %298 = getelementptr inbounds [1 x [64 x float]]* @param0, i64 0, i64 0, i64 50
  %299 = load volatile float* %298, align 4
  %300 = fcmp oge float %297, %299
  %301 = fcmp uno float %297, 0.000000e+00
  %302 = or i1 %300, %301
  %303 = select i1 %302, float %297, float %299
  %304 = getelementptr inbounds [1 x [64 x float]]* @param0, i64 0, i64 0, i64 51
  %305 = load volatile float* %304, align 4
  %306 = fcmp oge float %303, %305
  %307 = fcmp uno float %303, 0.000000e+00
  %308 = or i1 %306, %307
  %309 = select i1 %308, float %303, float %305
  %310 = getelementptr inbounds [1 x [64 x float]]* @param0, i64 0, i64 0, i64 52
  %311 = load volatile float* %310, align 4
  %312 = fcmp oge float %309, %311
  %313 = fcmp uno float %309, 0.000000e+00
  %314 = or i1 %312, %313
  %315 = select i1 %314, float %309, float %311
  %316 = getelementptr inbounds [1 x [64 x float]]* @param0, i64 0, i64 0, i64 53
  %317 = load volatile float* %316, align 4
  %318 = fcmp oge float %315, %317
  %319 = fcmp uno float %315, 0.000000e+00
  %320 = or i1 %318, %319
  %321 = select i1 %320, float %315, float %317
  %322 = getelementptr inbounds [1 x [64 x float]]* @param0, i64 0, i64 0, i64 54
  %323 = load volatile float* %322, align 4
  %324 = fcmp oge float %321, %323
  %325 = fcmp uno float %321, 0.000000e+00
  %326 = or i1 %324, %325
  %327 = select i1 %326, float %321, float %323
  %328 = getelementptr inbounds [1 x [64 x float]]* @param0, i64 0, i64 0, i64 55
  %329 = load volatile float* %328, align 4
  %330 = fcmp oge float %327, %329
  %331 = fcmp uno float %327, 0.000000e+00
  %332 = or i1 %330, %331
  %333 = select i1 %332, float %327, float %329
  %334 = getelementptr inbounds [1 x [64 x float]]* @param0, i64 0, i64 0, i64 56
  %335 = load volatile float* %334, align 4
  %336 = fcmp oge float %333, %335
  %337 = fcmp uno float %333, 0.000000e+00
  %338 = or i1 %336, %337
  %339 = select i1 %338, float %333, float %335
  %340 = getelementptr inbounds [1 x [64 x float]]* @param0, i64 0, i64 0, i64 57
  %341 = load volatile float* %340, align 4
  %342 = fcmp oge float %339, %341
  %343 = fcmp uno float %339, 0.000000e+00
  %344 = or i1 %342, %343
  %345 = select i1 %344, float %339, float %341
  %346 = getelementptr inbounds [1 x [64 x float]]* @param0, i64 0, i64 0, i64 58
  %347 = load volatile float* %346, align 4
  %348 = fcmp oge float %345, %347
  %349 = fcmp uno float %345, 0.000000e+00
  %350 = or i1 %348, %349
  %351 = select i1 %350, float %345, float %347
  %352 = getelementptr inbounds [1 x [64 x float]]* @param0, i64 0, i64 0, i64 59
  %353 = load volatile float* %352, align 4
  %354 = fcmp oge float %351, %353
  %355 = fcmp uno float %351, 0.000000e+00
  %356 = or i1 %354, %355
  %357 = select i1 %356, float %351, float %353
  %358 = getelementptr inbounds [1 x [64 x float]]* @param0, i64 0, i64 0, i64 60
  %359 = load volatile float* %358, align 4
  %360 = fcmp oge float %357, %359
  %361 = fcmp uno float %357, 0.000000e+00
  %362 = or i1 %360, %361
  %363 = select i1 %362, float %357, float %359
  %364 = getelementptr inbounds [1 x [64 x float]]* @param0, i64 0, i64 0, i64 61
  %365 = load volatile float* %364, align 4
  %366 = fcmp oge float %363, %365
  %367 = fcmp uno float %363, 0.000000e+00
  %368 = or i1 %366, %367
  %369 = select i1 %368, float %363, float %365
  %370 = getelementptr inbounds [1 x [64 x float]]* @param0, i64 0, i64 0, i64 62
  %371 = load volatile float* %370, align 4
  %372 = fcmp oge float %369, %371
  %373 = fcmp uno float %369, 0.000000e+00
  %374 = or i1 %372, %373
  %375 = select i1 %374, float %369, float %371
  %376 = getelementptr inbounds [1 x [64 x float]]* @param0, i64 0, i64 0, i64 63
  %377 = load volatile float* %376, align 4
  %378 = fcmp oge float %375, %377
  %379 = fcmp uno float %375, 0.000000e+00
  %380 = or i1 %378, %379
  %381 = select i1 %380, float %375, float %377
  store float %381, float* @temp0, align 4
  %382 = load float* %0, align 4
  %383 = fsub float %382, %381
  %384 = call float @llvm.exp.f32(float %383)
  %385 = getelementptr inbounds [1 x [64 x float]]* @temp1, i64 0, i64 0, i64 0
  store float %384, float* %385, align 4
  %386 = load float* %4, align 4
  %387 = load float* @temp0, align 4
  %388 = fsub float %386, %387
  %389 = call float @llvm.exp.f32(float %388)
  %390 = getelementptr inbounds [1 x [64 x float]]* @temp1, i64 0, i64 0, i64 1
  store float %389, float* %390, align 4
  %391 = load float* %10, align 4
  %392 = load float* @temp0, align 4
  %393 = fsub float %391, %392
  %394 = call float @llvm.exp.f32(float %393)
  %395 = getelementptr inbounds [1 x [64 x float]]* @temp1, i64 0, i64 0, i64 2
  store float %394, float* %395, align 4
  %396 = load float* %16, align 4
  %397 = load float* @temp0, align 4
  %398 = fsub float %396, %397
  %399 = call float @llvm.exp.f32(float %398)
  %400 = getelementptr inbounds [1 x [64 x float]]* @temp1, i64 0, i64 0, i64 3
  store float %399, float* %400, align 4
  %401 = load float* %22, align 4
  %402 = load float* @temp0, align 4
  %403 = fsub float %401, %402
  %404 = call float @llvm.exp.f32(float %403)
  %405 = getelementptr inbounds [1 x [64 x float]]* @temp1, i64 0, i64 0, i64 4
  store float %404, float* %405, align 4
  %406 = load float* %28, align 4
  %407 = load float* @temp0, align 4
  %408 = fsub float %406, %407
  %409 = call float @llvm.exp.f32(float %408)
  %410 = getelementptr inbounds [1 x [64 x float]]* @temp1, i64 0, i64 0, i64 5
  store float %409, float* %410, align 4
  %411 = load float* %34, align 4
  %412 = load float* @temp0, align 4
  %413 = fsub float %411, %412
  %414 = call float @llvm.exp.f32(float %413)
  %415 = getelementptr inbounds [1 x [64 x float]]* @temp1, i64 0, i64 0, i64 6
  store float %414, float* %415, align 4
  %416 = load float* %40, align 4
  %417 = load float* @temp0, align 4
  %418 = fsub float %416, %417
  %419 = call float @llvm.exp.f32(float %418)
  %420 = getelementptr inbounds [1 x [64 x float]]* @temp1, i64 0, i64 0, i64 7
  store float %419, float* %420, align 4
  %421 = load float* %46, align 4
  %422 = load float* @temp0, align 4
  %423 = fsub float %421, %422
  %424 = call float @llvm.exp.f32(float %423)
  %425 = getelementptr inbounds [1 x [64 x float]]* @temp1, i64 0, i64 0, i64 8
  store float %424, float* %425, align 4
  %426 = load float* %52, align 4
  %427 = load float* @temp0, align 4
  %428 = fsub float %426, %427
  %429 = call float @llvm.exp.f32(float %428)
  %430 = getelementptr inbounds [1 x [64 x float]]* @temp1, i64 0, i64 0, i64 9
  store float %429, float* %430, align 4
  %431 = load float* %58, align 4
  %432 = load float* @temp0, align 4
  %433 = fsub float %431, %432
  %434 = call float @llvm.exp.f32(float %433)
  %435 = getelementptr inbounds [1 x [64 x float]]* @temp1, i64 0, i64 0, i64 10
  store float %434, float* %435, align 4
  %436 = load float* %64, align 4
  %437 = load float* @temp0, align 4
  %438 = fsub float %436, %437
  %439 = call float @llvm.exp.f32(float %438)
  %440 = getelementptr inbounds [1 x [64 x float]]* @temp1, i64 0, i64 0, i64 11
  store float %439, float* %440, align 4
  %441 = load float* %70, align 4
  %442 = load float* @temp0, align 4
  %443 = fsub float %441, %442
  %444 = call float @llvm.exp.f32(float %443)
  %445 = getelementptr inbounds [1 x [64 x float]]* @temp1, i64 0, i64 0, i64 12
  store float %444, float* %445, align 4
  %446 = load float* %76, align 4
  %447 = load float* @temp0, align 4
  %448 = fsub float %446, %447
  %449 = call float @llvm.exp.f32(float %448)
  %450 = getelementptr inbounds [1 x [64 x float]]* @temp1, i64 0, i64 0, i64 13
  store float %449, float* %450, align 4
  %451 = load float* %82, align 4
  %452 = load float* @temp0, align 4
  %453 = fsub float %451, %452
  %454 = call float @llvm.exp.f32(float %453)
  %455 = getelementptr inbounds [1 x [64 x float]]* @temp1, i64 0, i64 0, i64 14
  store float %454, float* %455, align 4
  %456 = load float* %88, align 4
  %457 = load float* @temp0, align 4
  %458 = fsub float %456, %457
  %459 = call float @llvm.exp.f32(float %458)
  %460 = getelementptr inbounds [1 x [64 x float]]* @temp1, i64 0, i64 0, i64 15
  store float %459, float* %460, align 4
  %461 = load float* %94, align 4
  %462 = load float* @temp0, align 4
  %463 = fsub float %461, %462
  %464 = call float @llvm.exp.f32(float %463)
  %465 = getelementptr inbounds [1 x [64 x float]]* @temp1, i64 0, i64 0, i64 16
  store float %464, float* %465, align 4
  %466 = load float* %100, align 4
  %467 = load float* @temp0, align 4
  %468 = fsub float %466, %467
  %469 = call float @llvm.exp.f32(float %468)
  %470 = getelementptr inbounds [1 x [64 x float]]* @temp1, i64 0, i64 0, i64 17
  store float %469, float* %470, align 4
  %471 = load float* %106, align 4
  %472 = load float* @temp0, align 4
  %473 = fsub float %471, %472
  %474 = call float @llvm.exp.f32(float %473)
  %475 = getelementptr inbounds [1 x [64 x float]]* @temp1, i64 0, i64 0, i64 18
  store float %474, float* %475, align 4
  %476 = load float* %112, align 4
  %477 = load float* @temp0, align 4
  %478 = fsub float %476, %477
  %479 = call float @llvm.exp.f32(float %478)
  %480 = getelementptr inbounds [1 x [64 x float]]* @temp1, i64 0, i64 0, i64 19
  store float %479, float* %480, align 4
  %481 = load float* %118, align 4
  %482 = load float* @temp0, align 4
  %483 = fsub float %481, %482
  %484 = call float @llvm.exp.f32(float %483)
  %485 = getelementptr inbounds [1 x [64 x float]]* @temp1, i64 0, i64 0, i64 20
  store float %484, float* %485, align 4
  %486 = load float* %124, align 4
  %487 = load float* @temp0, align 4
  %488 = fsub float %486, %487
  %489 = call float @llvm.exp.f32(float %488)
  %490 = getelementptr inbounds [1 x [64 x float]]* @temp1, i64 0, i64 0, i64 21
  store float %489, float* %490, align 4
  %491 = load float* %130, align 4
  %492 = load float* @temp0, align 4
  %493 = fsub float %491, %492
  %494 = call float @llvm.exp.f32(float %493)
  %495 = getelementptr inbounds [1 x [64 x float]]* @temp1, i64 0, i64 0, i64 22
  store float %494, float* %495, align 4
  %496 = load float* %136, align 4
  %497 = load float* @temp0, align 4
  %498 = fsub float %496, %497
  %499 = call float @llvm.exp.f32(float %498)
  %500 = getelementptr inbounds [1 x [64 x float]]* @temp1, i64 0, i64 0, i64 23
  store float %499, float* %500, align 4
  %501 = load float* %142, align 4
  %502 = load float* @temp0, align 4
  %503 = fsub float %501, %502
  %504 = call float @llvm.exp.f32(float %503)
  %505 = getelementptr inbounds [1 x [64 x float]]* @temp1, i64 0, i64 0, i64 24
  store float %504, float* %505, align 4
  %506 = load float* %148, align 4
  %507 = load float* @temp0, align 4
  %508 = fsub float %506, %507
  %509 = call float @llvm.exp.f32(float %508)
  %510 = getelementptr inbounds [1 x [64 x float]]* @temp1, i64 0, i64 0, i64 25
  store float %509, float* %510, align 4
  %511 = load float* %154, align 4
  %512 = load float* @temp0, align 4
  %513 = fsub float %511, %512
  %514 = call float @llvm.exp.f32(float %513)
  %515 = getelementptr inbounds [1 x [64 x float]]* @temp1, i64 0, i64 0, i64 26
  store float %514, float* %515, align 4
  %516 = load float* %160, align 4
  %517 = load float* @temp0, align 4
  %518 = fsub float %516, %517
  %519 = call float @llvm.exp.f32(float %518)
  %520 = getelementptr inbounds [1 x [64 x float]]* @temp1, i64 0, i64 0, i64 27
  store float %519, float* %520, align 4
  %521 = load float* %166, align 4
  %522 = load float* @temp0, align 4
  %523 = fsub float %521, %522
  %524 = call float @llvm.exp.f32(float %523)
  %525 = getelementptr inbounds [1 x [64 x float]]* @temp1, i64 0, i64 0, i64 28
  store float %524, float* %525, align 4
  %526 = load float* %172, align 4
  %527 = load float* @temp0, align 4
  %528 = fsub float %526, %527
  %529 = call float @llvm.exp.f32(float %528)
  %530 = getelementptr inbounds [1 x [64 x float]]* @temp1, i64 0, i64 0, i64 29
  store float %529, float* %530, align 4
  %531 = load float* %178, align 4
  %532 = load float* @temp0, align 4
  %533 = fsub float %531, %532
  %534 = call float @llvm.exp.f32(float %533)
  %535 = getelementptr inbounds [1 x [64 x float]]* @temp1, i64 0, i64 0, i64 30
  store float %534, float* %535, align 4
  %536 = load float* %184, align 4
  %537 = load float* @temp0, align 4
  %538 = fsub float %536, %537
  %539 = call float @llvm.exp.f32(float %538)
  %540 = getelementptr inbounds [1 x [64 x float]]* @temp1, i64 0, i64 0, i64 31
  store float %539, float* %540, align 4
  %541 = load float* %190, align 4
  %542 = load float* @temp0, align 4
  %543 = fsub float %541, %542
  %544 = call float @llvm.exp.f32(float %543)
  %545 = getelementptr inbounds [1 x [64 x float]]* @temp1, i64 0, i64 0, i64 32
  store float %544, float* %545, align 4
  %546 = load float* %196, align 4
  %547 = load float* @temp0, align 4
  %548 = fsub float %546, %547
  %549 = call float @llvm.exp.f32(float %548)
  %550 = getelementptr inbounds [1 x [64 x float]]* @temp1, i64 0, i64 0, i64 33
  store float %549, float* %550, align 4
  %551 = load float* %202, align 4
  %552 = load float* @temp0, align 4
  %553 = fsub float %551, %552
  %554 = call float @llvm.exp.f32(float %553)
  %555 = getelementptr inbounds [1 x [64 x float]]* @temp1, i64 0, i64 0, i64 34
  store float %554, float* %555, align 4
  %556 = load float* %208, align 4
  %557 = load float* @temp0, align 4
  %558 = fsub float %556, %557
  %559 = call float @llvm.exp.f32(float %558)
  %560 = getelementptr inbounds [1 x [64 x float]]* @temp1, i64 0, i64 0, i64 35
  store float %559, float* %560, align 4
  %561 = load float* %214, align 4
  %562 = load float* @temp0, align 4
  %563 = fsub float %561, %562
  %564 = call float @llvm.exp.f32(float %563)
  %565 = getelementptr inbounds [1 x [64 x float]]* @temp1, i64 0, i64 0, i64 36
  store float %564, float* %565, align 4
  %566 = load float* %220, align 4
  %567 = load float* @temp0, align 4
  %568 = fsub float %566, %567
  %569 = call float @llvm.exp.f32(float %568)
  %570 = getelementptr inbounds [1 x [64 x float]]* @temp1, i64 0, i64 0, i64 37
  store float %569, float* %570, align 4
  %571 = load float* %226, align 4
  %572 = load float* @temp0, align 4
  %573 = fsub float %571, %572
  %574 = call float @llvm.exp.f32(float %573)
  %575 = getelementptr inbounds [1 x [64 x float]]* @temp1, i64 0, i64 0, i64 38
  store float %574, float* %575, align 4
  %576 = load float* %232, align 4
  %577 = load float* @temp0, align 4
  %578 = fsub float %576, %577
  %579 = call float @llvm.exp.f32(float %578)
  %580 = getelementptr inbounds [1 x [64 x float]]* @temp1, i64 0, i64 0, i64 39
  store float %579, float* %580, align 4
  %581 = load float* %238, align 4
  %582 = load float* @temp0, align 4
  %583 = fsub float %581, %582
  %584 = call float @llvm.exp.f32(float %583)
  %585 = getelementptr inbounds [1 x [64 x float]]* @temp1, i64 0, i64 0, i64 40
  store float %584, float* %585, align 4
  %586 = load float* %244, align 4
  %587 = load float* @temp0, align 4
  %588 = fsub float %586, %587
  %589 = call float @llvm.exp.f32(float %588)
  %590 = getelementptr inbounds [1 x [64 x float]]* @temp1, i64 0, i64 0, i64 41
  store float %589, float* %590, align 4
  %591 = load float* %250, align 4
  %592 = load float* @temp0, align 4
  %593 = fsub float %591, %592
  %594 = call float @llvm.exp.f32(float %593)
  %595 = getelementptr inbounds [1 x [64 x float]]* @temp1, i64 0, i64 0, i64 42
  store float %594, float* %595, align 4
  %596 = load float* %256, align 4
  %597 = load float* @temp0, align 4
  %598 = fsub float %596, %597
  %599 = call float @llvm.exp.f32(float %598)
  %600 = getelementptr inbounds [1 x [64 x float]]* @temp1, i64 0, i64 0, i64 43
  store float %599, float* %600, align 4
  %601 = load float* %262, align 4
  %602 = load float* @temp0, align 4
  %603 = fsub float %601, %602
  %604 = call float @llvm.exp.f32(float %603)
  %605 = getelementptr inbounds [1 x [64 x float]]* @temp1, i64 0, i64 0, i64 44
  store float %604, float* %605, align 4
  %606 = load float* %268, align 4
  %607 = load float* @temp0, align 4
  %608 = fsub float %606, %607
  %609 = call float @llvm.exp.f32(float %608)
  %610 = getelementptr inbounds [1 x [64 x float]]* @temp1, i64 0, i64 0, i64 45
  store float %609, float* %610, align 4
  %611 = load float* %274, align 4
  %612 = load float* @temp0, align 4
  %613 = fsub float %611, %612
  %614 = call float @llvm.exp.f32(float %613)
  %615 = getelementptr inbounds [1 x [64 x float]]* @temp1, i64 0, i64 0, i64 46
  store float %614, float* %615, align 4
  %616 = load float* %280, align 4
  %617 = load float* @temp0, align 4
  %618 = fsub float %616, %617
  %619 = call float @llvm.exp.f32(float %618)
  %620 = getelementptr inbounds [1 x [64 x float]]* @temp1, i64 0, i64 0, i64 47
  store float %619, float* %620, align 4
  %621 = load float* %286, align 4
  %622 = load float* @temp0, align 4
  %623 = fsub float %621, %622
  %624 = call float @llvm.exp.f32(float %623)
  %625 = getelementptr inbounds [1 x [64 x float]]* @temp1, i64 0, i64 0, i64 48
  store float %624, float* %625, align 4
  %626 = load float* %292, align 4
  %627 = load float* @temp0, align 4
  %628 = fsub float %626, %627
  %629 = call float @llvm.exp.f32(float %628)
  %630 = getelementptr inbounds [1 x [64 x float]]* @temp1, i64 0, i64 0, i64 49
  store float %629, float* %630, align 4
  %631 = load float* %298, align 4
  %632 = load float* @temp0, align 4
  %633 = fsub float %631, %632
  %634 = call float @llvm.exp.f32(float %633)
  %635 = getelementptr inbounds [1 x [64 x float]]* @temp1, i64 0, i64 0, i64 50
  store float %634, float* %635, align 4
  %636 = load float* %304, align 4
  %637 = load float* @temp0, align 4
  %638 = fsub float %636, %637
  %639 = call float @llvm.exp.f32(float %638)
  %640 = getelementptr inbounds [1 x [64 x float]]* @temp1, i64 0, i64 0, i64 51
  store float %639, float* %640, align 4
  %641 = load float* %310, align 4
  %642 = load float* @temp0, align 4
  %643 = fsub float %641, %642
  %644 = call float @llvm.exp.f32(float %643)
  %645 = getelementptr inbounds [1 x [64 x float]]* @temp1, i64 0, i64 0, i64 52
  store float %644, float* %645, align 4
  %646 = load float* %316, align 4
  %647 = load float* @temp0, align 4
  %648 = fsub float %646, %647
  %649 = call float @llvm.exp.f32(float %648)
  %650 = getelementptr inbounds [1 x [64 x float]]* @temp1, i64 0, i64 0, i64 53
  store float %649, float* %650, align 4
  %651 = load float* %322, align 4
  %652 = load float* @temp0, align 4
  %653 = fsub float %651, %652
  %654 = call float @llvm.exp.f32(float %653)
  %655 = getelementptr inbounds [1 x [64 x float]]* @temp1, i64 0, i64 0, i64 54
  store float %654, float* %655, align 4
  %656 = load float* %328, align 4
  %657 = load float* @temp0, align 4
  %658 = fsub float %656, %657
  %659 = call float @llvm.exp.f32(float %658)
  %660 = getelementptr inbounds [1 x [64 x float]]* @temp1, i64 0, i64 0, i64 55
  store float %659, float* %660, align 4
  %661 = load float* %334, align 4
  %662 = load float* @temp0, align 4
  %663 = fsub float %661, %662
  %664 = call float @llvm.exp.f32(float %663)
  %665 = getelementptr inbounds [1 x [64 x float]]* @temp1, i64 0, i64 0, i64 56
  store float %664, float* %665, align 4
  %666 = load float* %340, align 4
  %667 = load float* @temp0, align 4
  %668 = fsub float %666, %667
  %669 = call float @llvm.exp.f32(float %668)
  %670 = getelementptr inbounds [1 x [64 x float]]* @temp1, i64 0, i64 0, i64 57
  store float %669, float* %670, align 4
  %671 = load float* %346, align 4
  %672 = load float* @temp0, align 4
  %673 = fsub float %671, %672
  %674 = call float @llvm.exp.f32(float %673)
  %675 = getelementptr inbounds [1 x [64 x float]]* @temp1, i64 0, i64 0, i64 58
  store float %674, float* %675, align 4
  %676 = load float* %352, align 4
  %677 = load float* @temp0, align 4
  %678 = fsub float %676, %677
  %679 = call float @llvm.exp.f32(float %678)
  %680 = getelementptr inbounds [1 x [64 x float]]* @temp1, i64 0, i64 0, i64 59
  store float %679, float* %680, align 4
  %681 = load float* %358, align 4
  %682 = load float* @temp0, align 4
  %683 = fsub float %681, %682
  %684 = call float @llvm.exp.f32(float %683)
  %685 = getelementptr inbounds [1 x [64 x float]]* @temp1, i64 0, i64 0, i64 60
  store float %684, float* %685, align 4
  %686 = load float* %364, align 4
  %687 = load float* @temp0, align 4
  %688 = fsub float %686, %687
  %689 = call float @llvm.exp.f32(float %688)
  %690 = getelementptr inbounds [1 x [64 x float]]* @temp1, i64 0, i64 0, i64 61
  store float %689, float* %690, align 4
  %691 = load float* %370, align 4
  %692 = load float* @temp0, align 4
  %693 = fsub float %691, %692
  %694 = call float @llvm.exp.f32(float %693)
  %695 = getelementptr inbounds [1 x [64 x float]]* @temp1, i64 0, i64 0, i64 62
  store float %694, float* %695, align 4
  %696 = load float* %376, align 4
  %697 = load float* @temp0, align 4
  %698 = fsub float %696, %697
  %699 = call float @llvm.exp.f32(float %698)
  %700 = getelementptr inbounds [1 x [64 x float]]* @temp1, i64 0, i64 0, i64 63
  store float %699, float* %700, align 4
  %701 = load float* %385, align 4
  %702 = fadd float 0.000000e+00, %701
  %703 = load float* %390, align 4
  %704 = fadd float %702, %703
  %705 = load float* %395, align 4
  %706 = fadd float %704, %705
  %707 = load float* %400, align 4
  %708 = fadd float %706, %707
  %709 = load float* %405, align 4
  %710 = fadd float %708, %709
  %711 = load float* %410, align 4
  %712 = fadd float %710, %711
  %713 = load float* %415, align 4
  %714 = fadd float %712, %713
  %715 = load float* %420, align 4
  %716 = fadd float %714, %715
  %717 = load float* %425, align 4
  %718 = fadd float %716, %717
  %719 = load float* %430, align 4
  %720 = fadd float %718, %719
  %721 = load float* %435, align 4
  %722 = fadd float %720, %721
  %723 = load float* %440, align 4
  %724 = fadd float %722, %723
  %725 = load float* %445, align 4
  %726 = fadd float %724, %725
  %727 = load float* %450, align 4
  %728 = fadd float %726, %727
  %729 = load float* %455, align 4
  %730 = fadd float %728, %729
  %731 = load float* %460, align 4
  %732 = fadd float %730, %731
  %733 = load float* %465, align 4
  %734 = fadd float %732, %733
  %735 = load float* %470, align 4
  %736 = fadd float %734, %735
  %737 = load float* %475, align 4
  %738 = fadd float %736, %737
  %739 = load float* %480, align 4
  %740 = fadd float %738, %739
  %741 = load float* %485, align 4
  %742 = fadd float %740, %741
  %743 = load float* %490, align 4
  %744 = fadd float %742, %743
  %745 = load float* %495, align 4
  %746 = fadd float %744, %745
  %747 = load float* %500, align 4
  %748 = fadd float %746, %747
  %749 = load float* %505, align 4
  %750 = fadd float %748, %749
  %751 = load float* %510, align 4
  %752 = fadd float %750, %751
  %753 = load float* %515, align 4
  %754 = fadd float %752, %753
  %755 = load float* %520, align 4
  %756 = fadd float %754, %755
  %757 = load float* %525, align 4
  %758 = fadd float %756, %757
  %759 = load float* %530, align 4
  %760 = fadd float %758, %759
  %761 = load float* %535, align 4
  %762 = fadd float %760, %761
  %763 = load float* %540, align 4
  %764 = fadd float %762, %763
  %765 = load float* %545, align 4
  %766 = fadd float %764, %765
  %767 = load float* %550, align 4
  %768 = fadd float %766, %767
  %769 = load float* %555, align 4
  %770 = fadd float %768, %769
  %771 = load float* %560, align 4
  %772 = fadd float %770, %771
  %773 = load float* %565, align 4
  %774 = fadd float %772, %773
  %775 = load float* %570, align 4
  %776 = fadd float %774, %775
  %777 = load float* %575, align 4
  %778 = fadd float %776, %777
  %779 = load float* %580, align 4
  %780 = fadd float %778, %779
  %781 = load float* %585, align 4
  %782 = fadd float %780, %781
  %783 = load float* %590, align 4
  %784 = fadd float %782, %783
  %785 = load float* %595, align 4
  %786 = fadd float %784, %785
  %787 = load float* %600, align 4
  %788 = fadd float %786, %787
  %789 = load float* %605, align 4
  %790 = fadd float %788, %789
  %791 = load float* %610, align 4
  %792 = fadd float %790, %791
  %793 = load float* %615, align 4
  %794 = fadd float %792, %793
  %795 = load float* %620, align 4
  %796 = fadd float %794, %795
  %797 = load float* %625, align 4
  %798 = fadd float %796, %797
  %799 = load float* %630, align 4
  %800 = fadd float %798, %799
  %801 = load float* %635, align 4
  %802 = fadd float %800, %801
  %803 = load float* %640, align 4
  %804 = fadd float %802, %803
  %805 = load float* %645, align 4
  %806 = fadd float %804, %805
  %807 = load float* %650, align 4
  %808 = fadd float %806, %807
  %809 = load float* %655, align 4
  %810 = fadd float %808, %809
  %811 = load float* %660, align 4
  %812 = fadd float %810, %811
  %813 = load float* %665, align 4
  %814 = fadd float %812, %813
  %815 = load float* %670, align 4
  %816 = fadd float %814, %815
  %817 = load float* %675, align 4
  %818 = fadd float %816, %817
  %819 = load float* %680, align 4
  %820 = fadd float %818, %819
  %821 = load float* %685, align 4
  %822 = fadd float %820, %821
  %823 = load float* %690, align 4
  %824 = fadd float %822, %823
  %825 = load float* %695, align 4
  %826 = fadd float %824, %825
  %827 = fadd float %826, %699
  store float %827, float* @temp2, align 4
  %828 = load float* %385, align 4
  %829 = fdiv float %828, %827
  %830 = getelementptr inbounds [64 x float]* @temp3, i64 0, i64 0
  store volatile float %829, float* %830, align 4
  %831 = load float* %390, align 4
  %832 = load float* @temp2, align 4
  %833 = fdiv float %831, %832
  %834 = getelementptr inbounds [64 x float]* @temp3, i64 0, i64 1
  store volatile float %833, float* %834, align 4
  %835 = load float* %395, align 4
  %836 = load float* @temp2, align 4
  %837 = fdiv float %835, %836
  %838 = getelementptr inbounds [64 x float]* @temp3, i64 0, i64 2
  store volatile float %837, float* %838, align 4
  %839 = load float* %400, align 4
  %840 = load float* @temp2, align 4
  %841 = fdiv float %839, %840
  %842 = getelementptr inbounds [64 x float]* @temp3, i64 0, i64 3
  store volatile float %841, float* %842, align 4
  %843 = load float* %405, align 4
  %844 = load float* @temp2, align 4
  %845 = fdiv float %843, %844
  %846 = getelementptr inbounds [64 x float]* @temp3, i64 0, i64 4
  store volatile float %845, float* %846, align 4
  %847 = load float* %410, align 4
  %848 = load float* @temp2, align 4
  %849 = fdiv float %847, %848
  %850 = getelementptr inbounds [64 x float]* @temp3, i64 0, i64 5
  store volatile float %849, float* %850, align 4
  %851 = load float* %415, align 4
  %852 = load float* @temp2, align 4
  %853 = fdiv float %851, %852
  %854 = getelementptr inbounds [64 x float]* @temp3, i64 0, i64 6
  store volatile float %853, float* %854, align 4
  %855 = load float* %420, align 4
  %856 = load float* @temp2, align 4
  %857 = fdiv float %855, %856
  %858 = getelementptr inbounds [64 x float]* @temp3, i64 0, i64 7
  store volatile float %857, float* %858, align 4
  %859 = load float* %425, align 4
  %860 = load float* @temp2, align 4
  %861 = fdiv float %859, %860
  %862 = getelementptr inbounds [64 x float]* @temp3, i64 0, i64 8
  store volatile float %861, float* %862, align 4
  %863 = load float* %430, align 4
  %864 = load float* @temp2, align 4
  %865 = fdiv float %863, %864
  %866 = getelementptr inbounds [64 x float]* @temp3, i64 0, i64 9
  store volatile float %865, float* %866, align 4
  %867 = load float* %435, align 4
  %868 = load float* @temp2, align 4
  %869 = fdiv float %867, %868
  %870 = getelementptr inbounds [64 x float]* @temp3, i64 0, i64 10
  store volatile float %869, float* %870, align 4
  %871 = load float* %440, align 4
  %872 = load float* @temp2, align 4
  %873 = fdiv float %871, %872
  %874 = getelementptr inbounds [64 x float]* @temp3, i64 0, i64 11
  store volatile float %873, float* %874, align 4
  %875 = load float* %445, align 4
  %876 = load float* @temp2, align 4
  %877 = fdiv float %875, %876
  %878 = getelementptr inbounds [64 x float]* @temp3, i64 0, i64 12
  store volatile float %877, float* %878, align 4
  %879 = load float* %450, align 4
  %880 = load float* @temp2, align 4
  %881 = fdiv float %879, %880
  %882 = getelementptr inbounds [64 x float]* @temp3, i64 0, i64 13
  store volatile float %881, float* %882, align 4
  %883 = load float* %455, align 4
  %884 = load float* @temp2, align 4
  %885 = fdiv float %883, %884
  %886 = getelementptr inbounds [64 x float]* @temp3, i64 0, i64 14
  store volatile float %885, float* %886, align 4
  %887 = load float* %460, align 4
  %888 = load float* @temp2, align 4
  %889 = fdiv float %887, %888
  %890 = getelementptr inbounds [64 x float]* @temp3, i64 0, i64 15
  store volatile float %889, float* %890, align 4
  %891 = load float* %465, align 4
  %892 = load float* @temp2, align 4
  %893 = fdiv float %891, %892
  %894 = getelementptr inbounds [64 x float]* @temp3, i64 0, i64 16
  store volatile float %893, float* %894, align 4
  %895 = load float* %470, align 4
  %896 = load float* @temp2, align 4
  %897 = fdiv float %895, %896
  %898 = getelementptr inbounds [64 x float]* @temp3, i64 0, i64 17
  store volatile float %897, float* %898, align 4
  %899 = load float* %475, align 4
  %900 = load float* @temp2, align 4
  %901 = fdiv float %899, %900
  %902 = getelementptr inbounds [64 x float]* @temp3, i64 0, i64 18
  store volatile float %901, float* %902, align 4
  %903 = load float* %480, align 4
  %904 = load float* @temp2, align 4
  %905 = fdiv float %903, %904
  %906 = getelementptr inbounds [64 x float]* @temp3, i64 0, i64 19
  store volatile float %905, float* %906, align 4
  %907 = load float* %485, align 4
  %908 = load float* @temp2, align 4
  %909 = fdiv float %907, %908
  %910 = getelementptr inbounds [64 x float]* @temp3, i64 0, i64 20
  store volatile float %909, float* %910, align 4
  %911 = load float* %490, align 4
  %912 = load float* @temp2, align 4
  %913 = fdiv float %911, %912
  %914 = getelementptr inbounds [64 x float]* @temp3, i64 0, i64 21
  store volatile float %913, float* %914, align 4
  %915 = load float* %495, align 4
  %916 = load float* @temp2, align 4
  %917 = fdiv float %915, %916
  %918 = getelementptr inbounds [64 x float]* @temp3, i64 0, i64 22
  store volatile float %917, float* %918, align 4
  %919 = load float* %500, align 4
  %920 = load float* @temp2, align 4
  %921 = fdiv float %919, %920
  %922 = getelementptr inbounds [64 x float]* @temp3, i64 0, i64 23
  store volatile float %921, float* %922, align 4
  %923 = load float* %505, align 4
  %924 = load float* @temp2, align 4
  %925 = fdiv float %923, %924
  %926 = getelementptr inbounds [64 x float]* @temp3, i64 0, i64 24
  store volatile float %925, float* %926, align 4
  %927 = load float* %510, align 4
  %928 = load float* @temp2, align 4
  %929 = fdiv float %927, %928
  %930 = getelementptr inbounds [64 x float]* @temp3, i64 0, i64 25
  store volatile float %929, float* %930, align 4
  %931 = load float* %515, align 4
  %932 = load float* @temp2, align 4
  %933 = fdiv float %931, %932
  %934 = getelementptr inbounds [64 x float]* @temp3, i64 0, i64 26
  store volatile float %933, float* %934, align 4
  %935 = load float* %520, align 4
  %936 = load float* @temp2, align 4
  %937 = fdiv float %935, %936
  %938 = getelementptr inbounds [64 x float]* @temp3, i64 0, i64 27
  store volatile float %937, float* %938, align 4
  %939 = load float* %525, align 4
  %940 = load float* @temp2, align 4
  %941 = fdiv float %939, %940
  %942 = getelementptr inbounds [64 x float]* @temp3, i64 0, i64 28
  store volatile float %941, float* %942, align 4
  %943 = load float* %530, align 4
  %944 = load float* @temp2, align 4
  %945 = fdiv float %943, %944
  %946 = getelementptr inbounds [64 x float]* @temp3, i64 0, i64 29
  store volatile float %945, float* %946, align 4
  %947 = load float* %535, align 4
  %948 = load float* @temp2, align 4
  %949 = fdiv float %947, %948
  %950 = getelementptr inbounds [64 x float]* @temp3, i64 0, i64 30
  store volatile float %949, float* %950, align 4
  %951 = load float* %540, align 4
  %952 = load float* @temp2, align 4
  %953 = fdiv float %951, %952
  %954 = getelementptr inbounds [64 x float]* @temp3, i64 0, i64 31
  store volatile float %953, float* %954, align 4
  %955 = load float* %545, align 4
  %956 = load float* @temp2, align 4
  %957 = fdiv float %955, %956
  %958 = getelementptr inbounds [64 x float]* @temp3, i64 0, i64 32
  store volatile float %957, float* %958, align 4
  %959 = load float* %550, align 4
  %960 = load float* @temp2, align 4
  %961 = fdiv float %959, %960
  %962 = getelementptr inbounds [64 x float]* @temp3, i64 0, i64 33
  store volatile float %961, float* %962, align 4
  %963 = load float* %555, align 4
  %964 = load float* @temp2, align 4
  %965 = fdiv float %963, %964
  %966 = getelementptr inbounds [64 x float]* @temp3, i64 0, i64 34
  store volatile float %965, float* %966, align 4
  %967 = load float* %560, align 4
  %968 = load float* @temp2, align 4
  %969 = fdiv float %967, %968
  %970 = getelementptr inbounds [64 x float]* @temp3, i64 0, i64 35
  store volatile float %969, float* %970, align 4
  %971 = load float* %565, align 4
  %972 = load float* @temp2, align 4
  %973 = fdiv float %971, %972
  %974 = getelementptr inbounds [64 x float]* @temp3, i64 0, i64 36
  store volatile float %973, float* %974, align 4
  %975 = load float* %570, align 4
  %976 = load float* @temp2, align 4
  %977 = fdiv float %975, %976
  %978 = getelementptr inbounds [64 x float]* @temp3, i64 0, i64 37
  store volatile float %977, float* %978, align 4
  %979 = load float* %575, align 4
  %980 = load float* @temp2, align 4
  %981 = fdiv float %979, %980
  %982 = getelementptr inbounds [64 x float]* @temp3, i64 0, i64 38
  store volatile float %981, float* %982, align 4
  %983 = load float* %580, align 4
  %984 = load float* @temp2, align 4
  %985 = fdiv float %983, %984
  %986 = getelementptr inbounds [64 x float]* @temp3, i64 0, i64 39
  store volatile float %985, float* %986, align 4
  %987 = load float* %585, align 4
  %988 = load float* @temp2, align 4
  %989 = fdiv float %987, %988
  %990 = getelementptr inbounds [64 x float]* @temp3, i64 0, i64 40
  store volatile float %989, float* %990, align 4
  %991 = load float* %590, align 4
  %992 = load float* @temp2, align 4
  %993 = fdiv float %991, %992
  %994 = getelementptr inbounds [64 x float]* @temp3, i64 0, i64 41
  store volatile float %993, float* %994, align 4
  %995 = load float* %595, align 4
  %996 = load float* @temp2, align 4
  %997 = fdiv float %995, %996
  %998 = getelementptr inbounds [64 x float]* @temp3, i64 0, i64 42
  store volatile float %997, float* %998, align 4
  %999 = load float* %600, align 4
  %1000 = load float* @temp2, align 4
  %1001 = fdiv float %999, %1000
  %1002 = getelementptr inbounds [64 x float]* @temp3, i64 0, i64 43
  store volatile float %1001, float* %1002, align 4
  %1003 = load float* %605, align 4
  %1004 = load float* @temp2, align 4
  %1005 = fdiv float %1003, %1004
  %1006 = getelementptr inbounds [64 x float]* @temp3, i64 0, i64 44
  store volatile float %1005, float* %1006, align 4
  %1007 = load float* %610, align 4
  %1008 = load float* @temp2, align 4
  %1009 = fdiv float %1007, %1008
  %1010 = getelementptr inbounds [64 x float]* @temp3, i64 0, i64 45
  store volatile float %1009, float* %1010, align 4
  %1011 = load float* %615, align 4
  %1012 = load float* @temp2, align 4
  %1013 = fdiv float %1011, %1012
  %1014 = getelementptr inbounds [64 x float]* @temp3, i64 0, i64 46
  store volatile float %1013, float* %1014, align 4
  %1015 = load float* %620, align 4
  %1016 = load float* @temp2, align 4
  %1017 = fdiv float %1015, %1016
  %1018 = getelementptr inbounds [64 x float]* @temp3, i64 0, i64 47
  store volatile float %1017, float* %1018, align 4
  %1019 = load float* %625, align 4
  %1020 = load float* @temp2, align 4
  %1021 = fdiv float %1019, %1020
  %1022 = getelementptr inbounds [64 x float]* @temp3, i64 0, i64 48
  store volatile float %1021, float* %1022, align 4
  %1023 = load float* %630, align 4
  %1024 = load float* @temp2, align 4
  %1025 = fdiv float %1023, %1024
  %1026 = getelementptr inbounds [64 x float]* @temp3, i64 0, i64 49
  store volatile float %1025, float* %1026, align 4
  %1027 = load float* %635, align 4
  %1028 = load float* @temp2, align 4
  %1029 = fdiv float %1027, %1028
  %1030 = getelementptr inbounds [64 x float]* @temp3, i64 0, i64 50
  store volatile float %1029, float* %1030, align 4
  %1031 = load float* %640, align 4
  %1032 = load float* @temp2, align 4
  %1033 = fdiv float %1031, %1032
  %1034 = getelementptr inbounds [64 x float]* @temp3, i64 0, i64 51
  store volatile float %1033, float* %1034, align 4
  %1035 = load float* %645, align 4
  %1036 = load float* @temp2, align 4
  %1037 = fdiv float %1035, %1036
  %1038 = getelementptr inbounds [64 x float]* @temp3, i64 0, i64 52
  store volatile float %1037, float* %1038, align 4
  %1039 = load float* %650, align 4
  %1040 = load float* @temp2, align 4
  %1041 = fdiv float %1039, %1040
  %1042 = getelementptr inbounds [64 x float]* @temp3, i64 0, i64 53
  store volatile float %1041, float* %1042, align 4
  %1043 = load float* %655, align 4
  %1044 = load float* @temp2, align 4
  %1045 = fdiv float %1043, %1044
  %1046 = getelementptr inbounds [64 x float]* @temp3, i64 0, i64 54
  store volatile float %1045, float* %1046, align 4
  %1047 = load float* %660, align 4
  %1048 = load float* @temp2, align 4
  %1049 = fdiv float %1047, %1048
  %1050 = getelementptr inbounds [64 x float]* @temp3, i64 0, i64 55
  store volatile float %1049, float* %1050, align 4
  %1051 = load float* %665, align 4
  %1052 = load float* @temp2, align 4
  %1053 = fdiv float %1051, %1052
  %1054 = getelementptr inbounds [64 x float]* @temp3, i64 0, i64 56
  store volatile float %1053, float* %1054, align 4
  %1055 = load float* %670, align 4
  %1056 = load float* @temp2, align 4
  %1057 = fdiv float %1055, %1056
  %1058 = getelementptr inbounds [64 x float]* @temp3, i64 0, i64 57
  store volatile float %1057, float* %1058, align 4
  %1059 = load float* %675, align 4
  %1060 = load float* @temp2, align 4
  %1061 = fdiv float %1059, %1060
  %1062 = getelementptr inbounds [64 x float]* @temp3, i64 0, i64 58
  store volatile float %1061, float* %1062, align 4
  %1063 = load float* %680, align 4
  %1064 = load float* @temp2, align 4
  %1065 = fdiv float %1063, %1064
  %1066 = getelementptr inbounds [64 x float]* @temp3, i64 0, i64 59
  store volatile float %1065, float* %1066, align 4
  %1067 = load float* %685, align 4
  %1068 = load float* @temp2, align 4
  %1069 = fdiv float %1067, %1068
  %1070 = getelementptr inbounds [64 x float]* @temp3, i64 0, i64 60
  store volatile float %1069, float* %1070, align 4
  %1071 = load float* %690, align 4
  %1072 = load float* @temp2, align 4
  %1073 = fdiv float %1071, %1072
  %1074 = getelementptr inbounds [64 x float]* @temp3, i64 0, i64 61
  store volatile float %1073, float* %1074, align 4
  %1075 = load float* %695, align 4
  %1076 = load float* @temp2, align 4
  %1077 = fdiv float %1075, %1076
  %1078 = getelementptr inbounds [64 x float]* @temp3, i64 0, i64 62
  store volatile float %1077, float* %1078, align 4
  %1079 = load float* %700, align 4
  %1080 = load float* @temp2, align 4
  %1081 = fdiv float %1079, %1080
  %1082 = getelementptr inbounds [64 x float]* @temp3, i64 0, i64 63
  store volatile float %1081, float* %1082, align 4
  %leflow_gep = getelementptr inbounds [64 x float]* @temp3, i64 0, i64 0
  %leflow_retval = load volatile float* %leflow_gep, align 4
  ret float %leflow_retval
}

; Function Attrs: nounwind readnone
declare float @llvm.exp.f32(float) #1

attributes #0 = { "no-frame-pointer-elim"="false" }
attributes #1 = { nounwind readnone }

!0 = metadata !{i64 256}
!1 = metadata !{i64 8}
!2 = metadata !{i64 260}
