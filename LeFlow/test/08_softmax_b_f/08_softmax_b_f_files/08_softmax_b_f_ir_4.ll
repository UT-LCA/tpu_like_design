; ModuleID = '08_softmax_b_f_files/08_softmax_b_f_ir_4.bc'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux_gnu"

define void @cluster_0__XlaCompiledKernel_true__XlaNumConstantArgs_0__XlaNumResourceArgs_0_.v15(i8* nocapture align 8 dereferenceable(8) %retval, i8* noalias nocapture readnone %run_options, i8** noalias nocapture readonly %params, i8** noalias nocapture readonly %temps, i64* noalias nocapture readnone %prof_counters) #0 {
reduce.inner.loop_body.reduction_dim.1.lr.ph:
  %arg0.untyped = load i8** %params, align 8, !dereferenceable !0, !align !1
  %bitcast = bitcast i8* %arg0.untyped to [1 x [64 x float]]*
  %0 = load i8** %temps, align 8, !dereferenceable !0, !align !1
  %1 = getelementptr inbounds [1 x [64 x float]]* %bitcast, i64 0, i64 0, i64 0
  %2 = load float* %1, align 4
  %3 = fcmp oge float 0xFFF0000000000000, %2
  %4 = select i1 %3, float 0xFFF0000000000000, float %2
  %5 = getelementptr inbounds [1 x [64 x float]]* %bitcast, i64 0, i64 0, i64 1
  %6 = load float* %5, align 4
  %7 = fcmp oge float %4, %6
  %8 = fcmp uno float %4, 0.000000e+00
  %9 = or i1 %7, %8
  %10 = select i1 %9, float %4, float %6
  %11 = getelementptr inbounds [1 x [64 x float]]* %bitcast, i64 0, i64 0, i64 2
  %12 = load float* %11, align 4
  %13 = fcmp oge float %10, %12
  %14 = fcmp uno float %10, 0.000000e+00
  %15 = or i1 %13, %14
  %16 = select i1 %15, float %10, float %12
  %17 = getelementptr inbounds [1 x [64 x float]]* %bitcast, i64 0, i64 0, i64 3
  %18 = load float* %17, align 4
  %19 = fcmp oge float %16, %18
  %20 = fcmp uno float %16, 0.000000e+00
  %21 = or i1 %19, %20
  %22 = select i1 %21, float %16, float %18
  %23 = getelementptr inbounds [1 x [64 x float]]* %bitcast, i64 0, i64 0, i64 4
  %24 = load float* %23, align 4
  %25 = fcmp oge float %22, %24
  %26 = fcmp uno float %22, 0.000000e+00
  %27 = or i1 %25, %26
  %28 = select i1 %27, float %22, float %24
  %29 = getelementptr inbounds [1 x [64 x float]]* %bitcast, i64 0, i64 0, i64 5
  %30 = load float* %29, align 4
  %31 = fcmp oge float %28, %30
  %32 = fcmp uno float %28, 0.000000e+00
  %33 = or i1 %31, %32
  %34 = select i1 %33, float %28, float %30
  %35 = getelementptr inbounds [1 x [64 x float]]* %bitcast, i64 0, i64 0, i64 6
  %36 = load float* %35, align 4
  %37 = fcmp oge float %34, %36
  %38 = fcmp uno float %34, 0.000000e+00
  %39 = or i1 %37, %38
  %40 = select i1 %39, float %34, float %36
  %41 = getelementptr inbounds [1 x [64 x float]]* %bitcast, i64 0, i64 0, i64 7
  %42 = load float* %41, align 4
  %43 = fcmp oge float %40, %42
  %44 = fcmp uno float %40, 0.000000e+00
  %45 = or i1 %43, %44
  %46 = select i1 %45, float %40, float %42
  %47 = getelementptr inbounds [1 x [64 x float]]* %bitcast, i64 0, i64 0, i64 8
  %48 = load float* %47, align 4
  %49 = fcmp oge float %46, %48
  %50 = fcmp uno float %46, 0.000000e+00
  %51 = or i1 %49, %50
  %52 = select i1 %51, float %46, float %48
  %53 = getelementptr inbounds [1 x [64 x float]]* %bitcast, i64 0, i64 0, i64 9
  %54 = load float* %53, align 4
  %55 = fcmp oge float %52, %54
  %56 = fcmp uno float %52, 0.000000e+00
  %57 = or i1 %55, %56
  %58 = select i1 %57, float %52, float %54
  %59 = getelementptr inbounds [1 x [64 x float]]* %bitcast, i64 0, i64 0, i64 10
  %60 = load float* %59, align 4
  %61 = fcmp oge float %58, %60
  %62 = fcmp uno float %58, 0.000000e+00
  %63 = or i1 %61, %62
  %64 = select i1 %63, float %58, float %60
  %65 = getelementptr inbounds [1 x [64 x float]]* %bitcast, i64 0, i64 0, i64 11
  %66 = load float* %65, align 4
  %67 = fcmp oge float %64, %66
  %68 = fcmp uno float %64, 0.000000e+00
  %69 = or i1 %67, %68
  %70 = select i1 %69, float %64, float %66
  %71 = getelementptr inbounds [1 x [64 x float]]* %bitcast, i64 0, i64 0, i64 12
  %72 = load float* %71, align 4
  %73 = fcmp oge float %70, %72
  %74 = fcmp uno float %70, 0.000000e+00
  %75 = or i1 %73, %74
  %76 = select i1 %75, float %70, float %72
  %77 = getelementptr inbounds [1 x [64 x float]]* %bitcast, i64 0, i64 0, i64 13
  %78 = load float* %77, align 4
  %79 = fcmp oge float %76, %78
  %80 = fcmp uno float %76, 0.000000e+00
  %81 = or i1 %79, %80
  %82 = select i1 %81, float %76, float %78
  %83 = getelementptr inbounds [1 x [64 x float]]* %bitcast, i64 0, i64 0, i64 14
  %84 = load float* %83, align 4
  %85 = fcmp oge float %82, %84
  %86 = fcmp uno float %82, 0.000000e+00
  %87 = or i1 %85, %86
  %88 = select i1 %87, float %82, float %84
  %89 = getelementptr inbounds [1 x [64 x float]]* %bitcast, i64 0, i64 0, i64 15
  %90 = load float* %89, align 4
  %91 = fcmp oge float %88, %90
  %92 = fcmp uno float %88, 0.000000e+00
  %93 = or i1 %91, %92
  %94 = select i1 %93, float %88, float %90
  %95 = getelementptr inbounds [1 x [64 x float]]* %bitcast, i64 0, i64 0, i64 16
  %96 = load float* %95, align 4
  %97 = fcmp oge float %94, %96
  %98 = fcmp uno float %94, 0.000000e+00
  %99 = or i1 %97, %98
  %100 = select i1 %99, float %94, float %96
  %101 = getelementptr inbounds [1 x [64 x float]]* %bitcast, i64 0, i64 0, i64 17
  %102 = load float* %101, align 4
  %103 = fcmp oge float %100, %102
  %104 = fcmp uno float %100, 0.000000e+00
  %105 = or i1 %103, %104
  %106 = select i1 %105, float %100, float %102
  %107 = getelementptr inbounds [1 x [64 x float]]* %bitcast, i64 0, i64 0, i64 18
  %108 = load float* %107, align 4
  %109 = fcmp oge float %106, %108
  %110 = fcmp uno float %106, 0.000000e+00
  %111 = or i1 %109, %110
  %112 = select i1 %111, float %106, float %108
  %113 = getelementptr inbounds [1 x [64 x float]]* %bitcast, i64 0, i64 0, i64 19
  %114 = load float* %113, align 4
  %115 = fcmp oge float %112, %114
  %116 = fcmp uno float %112, 0.000000e+00
  %117 = or i1 %115, %116
  %118 = select i1 %117, float %112, float %114
  %119 = getelementptr inbounds [1 x [64 x float]]* %bitcast, i64 0, i64 0, i64 20
  %120 = load float* %119, align 4
  %121 = fcmp oge float %118, %120
  %122 = fcmp uno float %118, 0.000000e+00
  %123 = or i1 %121, %122
  %124 = select i1 %123, float %118, float %120
  %125 = getelementptr inbounds [1 x [64 x float]]* %bitcast, i64 0, i64 0, i64 21
  %126 = load float* %125, align 4
  %127 = fcmp oge float %124, %126
  %128 = fcmp uno float %124, 0.000000e+00
  %129 = or i1 %127, %128
  %130 = select i1 %129, float %124, float %126
  %131 = getelementptr inbounds [1 x [64 x float]]* %bitcast, i64 0, i64 0, i64 22
  %132 = load float* %131, align 4
  %133 = fcmp oge float %130, %132
  %134 = fcmp uno float %130, 0.000000e+00
  %135 = or i1 %133, %134
  %136 = select i1 %135, float %130, float %132
  %137 = getelementptr inbounds [1 x [64 x float]]* %bitcast, i64 0, i64 0, i64 23
  %138 = load float* %137, align 4
  %139 = fcmp oge float %136, %138
  %140 = fcmp uno float %136, 0.000000e+00
  %141 = or i1 %139, %140
  %142 = select i1 %141, float %136, float %138
  %143 = getelementptr inbounds [1 x [64 x float]]* %bitcast, i64 0, i64 0, i64 24
  %144 = load float* %143, align 4
  %145 = fcmp oge float %142, %144
  %146 = fcmp uno float %142, 0.000000e+00
  %147 = or i1 %145, %146
  %148 = select i1 %147, float %142, float %144
  %149 = getelementptr inbounds [1 x [64 x float]]* %bitcast, i64 0, i64 0, i64 25
  %150 = load float* %149, align 4
  %151 = fcmp oge float %148, %150
  %152 = fcmp uno float %148, 0.000000e+00
  %153 = or i1 %151, %152
  %154 = select i1 %153, float %148, float %150
  %155 = getelementptr inbounds [1 x [64 x float]]* %bitcast, i64 0, i64 0, i64 26
  %156 = load float* %155, align 4
  %157 = fcmp oge float %154, %156
  %158 = fcmp uno float %154, 0.000000e+00
  %159 = or i1 %157, %158
  %160 = select i1 %159, float %154, float %156
  %161 = getelementptr inbounds [1 x [64 x float]]* %bitcast, i64 0, i64 0, i64 27
  %162 = load float* %161, align 4
  %163 = fcmp oge float %160, %162
  %164 = fcmp uno float %160, 0.000000e+00
  %165 = or i1 %163, %164
  %166 = select i1 %165, float %160, float %162
  %167 = getelementptr inbounds [1 x [64 x float]]* %bitcast, i64 0, i64 0, i64 28
  %168 = load float* %167, align 4
  %169 = fcmp oge float %166, %168
  %170 = fcmp uno float %166, 0.000000e+00
  %171 = or i1 %169, %170
  %172 = select i1 %171, float %166, float %168
  %173 = getelementptr inbounds [1 x [64 x float]]* %bitcast, i64 0, i64 0, i64 29
  %174 = load float* %173, align 4
  %175 = fcmp oge float %172, %174
  %176 = fcmp uno float %172, 0.000000e+00
  %177 = or i1 %175, %176
  %178 = select i1 %177, float %172, float %174
  %179 = getelementptr inbounds [1 x [64 x float]]* %bitcast, i64 0, i64 0, i64 30
  %180 = load float* %179, align 4
  %181 = fcmp oge float %178, %180
  %182 = fcmp uno float %178, 0.000000e+00
  %183 = or i1 %181, %182
  %184 = select i1 %183, float %178, float %180
  %185 = getelementptr inbounds [1 x [64 x float]]* %bitcast, i64 0, i64 0, i64 31
  %186 = load float* %185, align 4
  %187 = fcmp oge float %184, %186
  %188 = fcmp uno float %184, 0.000000e+00
  %189 = or i1 %187, %188
  %190 = select i1 %189, float %184, float %186
  %191 = getelementptr inbounds [1 x [64 x float]]* %bitcast, i64 0, i64 0, i64 32
  %192 = load float* %191, align 4
  %193 = fcmp oge float %190, %192
  %194 = fcmp uno float %190, 0.000000e+00
  %195 = or i1 %193, %194
  %196 = select i1 %195, float %190, float %192
  %197 = getelementptr inbounds [1 x [64 x float]]* %bitcast, i64 0, i64 0, i64 33
  %198 = load float* %197, align 4
  %199 = fcmp oge float %196, %198
  %200 = fcmp uno float %196, 0.000000e+00
  %201 = or i1 %199, %200
  %202 = select i1 %201, float %196, float %198
  %203 = getelementptr inbounds [1 x [64 x float]]* %bitcast, i64 0, i64 0, i64 34
  %204 = load float* %203, align 4
  %205 = fcmp oge float %202, %204
  %206 = fcmp uno float %202, 0.000000e+00
  %207 = or i1 %205, %206
  %208 = select i1 %207, float %202, float %204
  %209 = getelementptr inbounds [1 x [64 x float]]* %bitcast, i64 0, i64 0, i64 35
  %210 = load float* %209, align 4
  %211 = fcmp oge float %208, %210
  %212 = fcmp uno float %208, 0.000000e+00
  %213 = or i1 %211, %212
  %214 = select i1 %213, float %208, float %210
  %215 = getelementptr inbounds [1 x [64 x float]]* %bitcast, i64 0, i64 0, i64 36
  %216 = load float* %215, align 4
  %217 = fcmp oge float %214, %216
  %218 = fcmp uno float %214, 0.000000e+00
  %219 = or i1 %217, %218
  %220 = select i1 %219, float %214, float %216
  %221 = getelementptr inbounds [1 x [64 x float]]* %bitcast, i64 0, i64 0, i64 37
  %222 = load float* %221, align 4
  %223 = fcmp oge float %220, %222
  %224 = fcmp uno float %220, 0.000000e+00
  %225 = or i1 %223, %224
  %226 = select i1 %225, float %220, float %222
  %227 = getelementptr inbounds [1 x [64 x float]]* %bitcast, i64 0, i64 0, i64 38
  %228 = load float* %227, align 4
  %229 = fcmp oge float %226, %228
  %230 = fcmp uno float %226, 0.000000e+00
  %231 = or i1 %229, %230
  %232 = select i1 %231, float %226, float %228
  %233 = getelementptr inbounds [1 x [64 x float]]* %bitcast, i64 0, i64 0, i64 39
  %234 = load float* %233, align 4
  %235 = fcmp oge float %232, %234
  %236 = fcmp uno float %232, 0.000000e+00
  %237 = or i1 %235, %236
  %238 = select i1 %237, float %232, float %234
  %239 = getelementptr inbounds [1 x [64 x float]]* %bitcast, i64 0, i64 0, i64 40
  %240 = load float* %239, align 4
  %241 = fcmp oge float %238, %240
  %242 = fcmp uno float %238, 0.000000e+00
  %243 = or i1 %241, %242
  %244 = select i1 %243, float %238, float %240
  %245 = getelementptr inbounds [1 x [64 x float]]* %bitcast, i64 0, i64 0, i64 41
  %246 = load float* %245, align 4
  %247 = fcmp oge float %244, %246
  %248 = fcmp uno float %244, 0.000000e+00
  %249 = or i1 %247, %248
  %250 = select i1 %249, float %244, float %246
  %251 = getelementptr inbounds [1 x [64 x float]]* %bitcast, i64 0, i64 0, i64 42
  %252 = load float* %251, align 4
  %253 = fcmp oge float %250, %252
  %254 = fcmp uno float %250, 0.000000e+00
  %255 = or i1 %253, %254
  %256 = select i1 %255, float %250, float %252
  %257 = getelementptr inbounds [1 x [64 x float]]* %bitcast, i64 0, i64 0, i64 43
  %258 = load float* %257, align 4
  %259 = fcmp oge float %256, %258
  %260 = fcmp uno float %256, 0.000000e+00
  %261 = or i1 %259, %260
  %262 = select i1 %261, float %256, float %258
  %263 = getelementptr inbounds [1 x [64 x float]]* %bitcast, i64 0, i64 0, i64 44
  %264 = load float* %263, align 4
  %265 = fcmp oge float %262, %264
  %266 = fcmp uno float %262, 0.000000e+00
  %267 = or i1 %265, %266
  %268 = select i1 %267, float %262, float %264
  %269 = getelementptr inbounds [1 x [64 x float]]* %bitcast, i64 0, i64 0, i64 45
  %270 = load float* %269, align 4
  %271 = fcmp oge float %268, %270
  %272 = fcmp uno float %268, 0.000000e+00
  %273 = or i1 %271, %272
  %274 = select i1 %273, float %268, float %270
  %275 = getelementptr inbounds [1 x [64 x float]]* %bitcast, i64 0, i64 0, i64 46
  %276 = load float* %275, align 4
  %277 = fcmp oge float %274, %276
  %278 = fcmp uno float %274, 0.000000e+00
  %279 = or i1 %277, %278
  %280 = select i1 %279, float %274, float %276
  %281 = getelementptr inbounds [1 x [64 x float]]* %bitcast, i64 0, i64 0, i64 47
  %282 = load float* %281, align 4
  %283 = fcmp oge float %280, %282
  %284 = fcmp uno float %280, 0.000000e+00
  %285 = or i1 %283, %284
  %286 = select i1 %285, float %280, float %282
  %287 = getelementptr inbounds [1 x [64 x float]]* %bitcast, i64 0, i64 0, i64 48
  %288 = load float* %287, align 4
  %289 = fcmp oge float %286, %288
  %290 = fcmp uno float %286, 0.000000e+00
  %291 = or i1 %289, %290
  %292 = select i1 %291, float %286, float %288
  %293 = getelementptr inbounds [1 x [64 x float]]* %bitcast, i64 0, i64 0, i64 49
  %294 = load float* %293, align 4
  %295 = fcmp oge float %292, %294
  %296 = fcmp uno float %292, 0.000000e+00
  %297 = or i1 %295, %296
  %298 = select i1 %297, float %292, float %294
  %299 = getelementptr inbounds [1 x [64 x float]]* %bitcast, i64 0, i64 0, i64 50
  %300 = load float* %299, align 4
  %301 = fcmp oge float %298, %300
  %302 = fcmp uno float %298, 0.000000e+00
  %303 = or i1 %301, %302
  %304 = select i1 %303, float %298, float %300
  %305 = getelementptr inbounds [1 x [64 x float]]* %bitcast, i64 0, i64 0, i64 51
  %306 = load float* %305, align 4
  %307 = fcmp oge float %304, %306
  %308 = fcmp uno float %304, 0.000000e+00
  %309 = or i1 %307, %308
  %310 = select i1 %309, float %304, float %306
  %311 = getelementptr inbounds [1 x [64 x float]]* %bitcast, i64 0, i64 0, i64 52
  %312 = load float* %311, align 4
  %313 = fcmp oge float %310, %312
  %314 = fcmp uno float %310, 0.000000e+00
  %315 = or i1 %313, %314
  %316 = select i1 %315, float %310, float %312
  %317 = getelementptr inbounds [1 x [64 x float]]* %bitcast, i64 0, i64 0, i64 53
  %318 = load float* %317, align 4
  %319 = fcmp oge float %316, %318
  %320 = fcmp uno float %316, 0.000000e+00
  %321 = or i1 %319, %320
  %322 = select i1 %321, float %316, float %318
  %323 = getelementptr inbounds [1 x [64 x float]]* %bitcast, i64 0, i64 0, i64 54
  %324 = load float* %323, align 4
  %325 = fcmp oge float %322, %324
  %326 = fcmp uno float %322, 0.000000e+00
  %327 = or i1 %325, %326
  %328 = select i1 %327, float %322, float %324
  %329 = getelementptr inbounds [1 x [64 x float]]* %bitcast, i64 0, i64 0, i64 55
  %330 = load float* %329, align 4
  %331 = fcmp oge float %328, %330
  %332 = fcmp uno float %328, 0.000000e+00
  %333 = or i1 %331, %332
  %334 = select i1 %333, float %328, float %330
  %335 = getelementptr inbounds [1 x [64 x float]]* %bitcast, i64 0, i64 0, i64 56
  %336 = load float* %335, align 4
  %337 = fcmp oge float %334, %336
  %338 = fcmp uno float %334, 0.000000e+00
  %339 = or i1 %337, %338
  %340 = select i1 %339, float %334, float %336
  %341 = getelementptr inbounds [1 x [64 x float]]* %bitcast, i64 0, i64 0, i64 57
  %342 = load float* %341, align 4
  %343 = fcmp oge float %340, %342
  %344 = fcmp uno float %340, 0.000000e+00
  %345 = or i1 %343, %344
  %346 = select i1 %345, float %340, float %342
  %347 = getelementptr inbounds [1 x [64 x float]]* %bitcast, i64 0, i64 0, i64 58
  %348 = load float* %347, align 4
  %349 = fcmp oge float %346, %348
  %350 = fcmp uno float %346, 0.000000e+00
  %351 = or i1 %349, %350
  %352 = select i1 %351, float %346, float %348
  %353 = getelementptr inbounds [1 x [64 x float]]* %bitcast, i64 0, i64 0, i64 59
  %354 = load float* %353, align 4
  %355 = fcmp oge float %352, %354
  %356 = fcmp uno float %352, 0.000000e+00
  %357 = or i1 %355, %356
  %358 = select i1 %357, float %352, float %354
  %359 = getelementptr inbounds [1 x [64 x float]]* %bitcast, i64 0, i64 0, i64 60
  %360 = load float* %359, align 4
  %361 = fcmp oge float %358, %360
  %362 = fcmp uno float %358, 0.000000e+00
  %363 = or i1 %361, %362
  %364 = select i1 %363, float %358, float %360
  %365 = getelementptr inbounds [1 x [64 x float]]* %bitcast, i64 0, i64 0, i64 61
  %366 = load float* %365, align 4
  %367 = fcmp oge float %364, %366
  %368 = fcmp uno float %364, 0.000000e+00
  %369 = or i1 %367, %368
  %370 = select i1 %369, float %364, float %366
  %371 = getelementptr inbounds [1 x [64 x float]]* %bitcast, i64 0, i64 0, i64 62
  %372 = load float* %371, align 4
  %373 = fcmp oge float %370, %372
  %374 = fcmp uno float %370, 0.000000e+00
  %375 = or i1 %373, %374
  %376 = select i1 %375, float %370, float %372
  %377 = getelementptr inbounds [1 x [64 x float]]* %bitcast, i64 0, i64 0, i64 63
  %378 = load float* %377, align 4
  %379 = fcmp oge float %376, %378
  %380 = fcmp uno float %376, 0.000000e+00
  %381 = or i1 %379, %380
  %382 = select i1 %381, float %376, float %378
  %383 = bitcast i8* %0 to float*
  store float %382, float* %383, align 4
  %384 = getelementptr inbounds i8** %temps, i64 9
  %385 = load i8** %384, align 8, !dereferenceable !2, !align !1
  %fusion.1 = bitcast i8* %385 to [1 x [64 x float]]*
  %386 = load float* %1, align 4
  %387 = fsub float %386, %382
  %388 = call float @llvm.exp.f32(float %387)
  %389 = getelementptr inbounds [1 x [64 x float]]* %fusion.1, i64 0, i64 0, i64 0
  store float %388, float* %389, align 4
  %390 = load float* %5, align 4
  %391 = load float* %383, align 4
  %392 = fsub float %390, %391
  %393 = call float @llvm.exp.f32(float %392)
  %394 = getelementptr inbounds [1 x [64 x float]]* %fusion.1, i64 0, i64 0, i64 1
  store float %393, float* %394, align 4
  %395 = load float* %11, align 4
  %396 = load float* %383, align 4
  %397 = fsub float %395, %396
  %398 = call float @llvm.exp.f32(float %397)
  %399 = getelementptr inbounds [1 x [64 x float]]* %fusion.1, i64 0, i64 0, i64 2
  store float %398, float* %399, align 4
  %400 = load float* %17, align 4
  %401 = load float* %383, align 4
  %402 = fsub float %400, %401
  %403 = call float @llvm.exp.f32(float %402)
  %404 = getelementptr inbounds [1 x [64 x float]]* %fusion.1, i64 0, i64 0, i64 3
  store float %403, float* %404, align 4
  %405 = load float* %23, align 4
  %406 = load float* %383, align 4
  %407 = fsub float %405, %406
  %408 = call float @llvm.exp.f32(float %407)
  %409 = getelementptr inbounds [1 x [64 x float]]* %fusion.1, i64 0, i64 0, i64 4
  store float %408, float* %409, align 4
  %410 = load float* %29, align 4
  %411 = load float* %383, align 4
  %412 = fsub float %410, %411
  %413 = call float @llvm.exp.f32(float %412)
  %414 = getelementptr inbounds [1 x [64 x float]]* %fusion.1, i64 0, i64 0, i64 5
  store float %413, float* %414, align 4
  %415 = load float* %35, align 4
  %416 = load float* %383, align 4
  %417 = fsub float %415, %416
  %418 = call float @llvm.exp.f32(float %417)
  %419 = getelementptr inbounds [1 x [64 x float]]* %fusion.1, i64 0, i64 0, i64 6
  store float %418, float* %419, align 4
  %420 = load float* %41, align 4
  %421 = load float* %383, align 4
  %422 = fsub float %420, %421
  %423 = call float @llvm.exp.f32(float %422)
  %424 = getelementptr inbounds [1 x [64 x float]]* %fusion.1, i64 0, i64 0, i64 7
  store float %423, float* %424, align 4
  %425 = load float* %47, align 4
  %426 = load float* %383, align 4
  %427 = fsub float %425, %426
  %428 = call float @llvm.exp.f32(float %427)
  %429 = getelementptr inbounds [1 x [64 x float]]* %fusion.1, i64 0, i64 0, i64 8
  store float %428, float* %429, align 4
  %430 = load float* %53, align 4
  %431 = load float* %383, align 4
  %432 = fsub float %430, %431
  %433 = call float @llvm.exp.f32(float %432)
  %434 = getelementptr inbounds [1 x [64 x float]]* %fusion.1, i64 0, i64 0, i64 9
  store float %433, float* %434, align 4
  %435 = load float* %59, align 4
  %436 = load float* %383, align 4
  %437 = fsub float %435, %436
  %438 = call float @llvm.exp.f32(float %437)
  %439 = getelementptr inbounds [1 x [64 x float]]* %fusion.1, i64 0, i64 0, i64 10
  store float %438, float* %439, align 4
  %440 = load float* %65, align 4
  %441 = load float* %383, align 4
  %442 = fsub float %440, %441
  %443 = call float @llvm.exp.f32(float %442)
  %444 = getelementptr inbounds [1 x [64 x float]]* %fusion.1, i64 0, i64 0, i64 11
  store float %443, float* %444, align 4
  %445 = load float* %71, align 4
  %446 = load float* %383, align 4
  %447 = fsub float %445, %446
  %448 = call float @llvm.exp.f32(float %447)
  %449 = getelementptr inbounds [1 x [64 x float]]* %fusion.1, i64 0, i64 0, i64 12
  store float %448, float* %449, align 4
  %450 = load float* %77, align 4
  %451 = load float* %383, align 4
  %452 = fsub float %450, %451
  %453 = call float @llvm.exp.f32(float %452)
  %454 = getelementptr inbounds [1 x [64 x float]]* %fusion.1, i64 0, i64 0, i64 13
  store float %453, float* %454, align 4
  %455 = load float* %83, align 4
  %456 = load float* %383, align 4
  %457 = fsub float %455, %456
  %458 = call float @llvm.exp.f32(float %457)
  %459 = getelementptr inbounds [1 x [64 x float]]* %fusion.1, i64 0, i64 0, i64 14
  store float %458, float* %459, align 4
  %460 = load float* %89, align 4
  %461 = load float* %383, align 4
  %462 = fsub float %460, %461
  %463 = call float @llvm.exp.f32(float %462)
  %464 = getelementptr inbounds [1 x [64 x float]]* %fusion.1, i64 0, i64 0, i64 15
  store float %463, float* %464, align 4
  %465 = load float* %95, align 4
  %466 = load float* %383, align 4
  %467 = fsub float %465, %466
  %468 = call float @llvm.exp.f32(float %467)
  %469 = getelementptr inbounds [1 x [64 x float]]* %fusion.1, i64 0, i64 0, i64 16
  store float %468, float* %469, align 4
  %470 = load float* %101, align 4
  %471 = load float* %383, align 4
  %472 = fsub float %470, %471
  %473 = call float @llvm.exp.f32(float %472)
  %474 = getelementptr inbounds [1 x [64 x float]]* %fusion.1, i64 0, i64 0, i64 17
  store float %473, float* %474, align 4
  %475 = load float* %107, align 4
  %476 = load float* %383, align 4
  %477 = fsub float %475, %476
  %478 = call float @llvm.exp.f32(float %477)
  %479 = getelementptr inbounds [1 x [64 x float]]* %fusion.1, i64 0, i64 0, i64 18
  store float %478, float* %479, align 4
  %480 = load float* %113, align 4
  %481 = load float* %383, align 4
  %482 = fsub float %480, %481
  %483 = call float @llvm.exp.f32(float %482)
  %484 = getelementptr inbounds [1 x [64 x float]]* %fusion.1, i64 0, i64 0, i64 19
  store float %483, float* %484, align 4
  %485 = load float* %119, align 4
  %486 = load float* %383, align 4
  %487 = fsub float %485, %486
  %488 = call float @llvm.exp.f32(float %487)
  %489 = getelementptr inbounds [1 x [64 x float]]* %fusion.1, i64 0, i64 0, i64 20
  store float %488, float* %489, align 4
  %490 = load float* %125, align 4
  %491 = load float* %383, align 4
  %492 = fsub float %490, %491
  %493 = call float @llvm.exp.f32(float %492)
  %494 = getelementptr inbounds [1 x [64 x float]]* %fusion.1, i64 0, i64 0, i64 21
  store float %493, float* %494, align 4
  %495 = load float* %131, align 4
  %496 = load float* %383, align 4
  %497 = fsub float %495, %496
  %498 = call float @llvm.exp.f32(float %497)
  %499 = getelementptr inbounds [1 x [64 x float]]* %fusion.1, i64 0, i64 0, i64 22
  store float %498, float* %499, align 4
  %500 = load float* %137, align 4
  %501 = load float* %383, align 4
  %502 = fsub float %500, %501
  %503 = call float @llvm.exp.f32(float %502)
  %504 = getelementptr inbounds [1 x [64 x float]]* %fusion.1, i64 0, i64 0, i64 23
  store float %503, float* %504, align 4
  %505 = load float* %143, align 4
  %506 = load float* %383, align 4
  %507 = fsub float %505, %506
  %508 = call float @llvm.exp.f32(float %507)
  %509 = getelementptr inbounds [1 x [64 x float]]* %fusion.1, i64 0, i64 0, i64 24
  store float %508, float* %509, align 4
  %510 = load float* %149, align 4
  %511 = load float* %383, align 4
  %512 = fsub float %510, %511
  %513 = call float @llvm.exp.f32(float %512)
  %514 = getelementptr inbounds [1 x [64 x float]]* %fusion.1, i64 0, i64 0, i64 25
  store float %513, float* %514, align 4
  %515 = load float* %155, align 4
  %516 = load float* %383, align 4
  %517 = fsub float %515, %516
  %518 = call float @llvm.exp.f32(float %517)
  %519 = getelementptr inbounds [1 x [64 x float]]* %fusion.1, i64 0, i64 0, i64 26
  store float %518, float* %519, align 4
  %520 = load float* %161, align 4
  %521 = load float* %383, align 4
  %522 = fsub float %520, %521
  %523 = call float @llvm.exp.f32(float %522)
  %524 = getelementptr inbounds [1 x [64 x float]]* %fusion.1, i64 0, i64 0, i64 27
  store float %523, float* %524, align 4
  %525 = load float* %167, align 4
  %526 = load float* %383, align 4
  %527 = fsub float %525, %526
  %528 = call float @llvm.exp.f32(float %527)
  %529 = getelementptr inbounds [1 x [64 x float]]* %fusion.1, i64 0, i64 0, i64 28
  store float %528, float* %529, align 4
  %530 = load float* %173, align 4
  %531 = load float* %383, align 4
  %532 = fsub float %530, %531
  %533 = call float @llvm.exp.f32(float %532)
  %534 = getelementptr inbounds [1 x [64 x float]]* %fusion.1, i64 0, i64 0, i64 29
  store float %533, float* %534, align 4
  %535 = load float* %179, align 4
  %536 = load float* %383, align 4
  %537 = fsub float %535, %536
  %538 = call float @llvm.exp.f32(float %537)
  %539 = getelementptr inbounds [1 x [64 x float]]* %fusion.1, i64 0, i64 0, i64 30
  store float %538, float* %539, align 4
  %540 = load float* %185, align 4
  %541 = load float* %383, align 4
  %542 = fsub float %540, %541
  %543 = call float @llvm.exp.f32(float %542)
  %544 = getelementptr inbounds [1 x [64 x float]]* %fusion.1, i64 0, i64 0, i64 31
  store float %543, float* %544, align 4
  %545 = load float* %191, align 4
  %546 = load float* %383, align 4
  %547 = fsub float %545, %546
  %548 = call float @llvm.exp.f32(float %547)
  %549 = getelementptr inbounds [1 x [64 x float]]* %fusion.1, i64 0, i64 0, i64 32
  store float %548, float* %549, align 4
  %550 = load float* %197, align 4
  %551 = load float* %383, align 4
  %552 = fsub float %550, %551
  %553 = call float @llvm.exp.f32(float %552)
  %554 = getelementptr inbounds [1 x [64 x float]]* %fusion.1, i64 0, i64 0, i64 33
  store float %553, float* %554, align 4
  %555 = load float* %203, align 4
  %556 = load float* %383, align 4
  %557 = fsub float %555, %556
  %558 = call float @llvm.exp.f32(float %557)
  %559 = getelementptr inbounds [1 x [64 x float]]* %fusion.1, i64 0, i64 0, i64 34
  store float %558, float* %559, align 4
  %560 = load float* %209, align 4
  %561 = load float* %383, align 4
  %562 = fsub float %560, %561
  %563 = call float @llvm.exp.f32(float %562)
  %564 = getelementptr inbounds [1 x [64 x float]]* %fusion.1, i64 0, i64 0, i64 35
  store float %563, float* %564, align 4
  %565 = load float* %215, align 4
  %566 = load float* %383, align 4
  %567 = fsub float %565, %566
  %568 = call float @llvm.exp.f32(float %567)
  %569 = getelementptr inbounds [1 x [64 x float]]* %fusion.1, i64 0, i64 0, i64 36
  store float %568, float* %569, align 4
  %570 = load float* %221, align 4
  %571 = load float* %383, align 4
  %572 = fsub float %570, %571
  %573 = call float @llvm.exp.f32(float %572)
  %574 = getelementptr inbounds [1 x [64 x float]]* %fusion.1, i64 0, i64 0, i64 37
  store float %573, float* %574, align 4
  %575 = load float* %227, align 4
  %576 = load float* %383, align 4
  %577 = fsub float %575, %576
  %578 = call float @llvm.exp.f32(float %577)
  %579 = getelementptr inbounds [1 x [64 x float]]* %fusion.1, i64 0, i64 0, i64 38
  store float %578, float* %579, align 4
  %580 = load float* %233, align 4
  %581 = load float* %383, align 4
  %582 = fsub float %580, %581
  %583 = call float @llvm.exp.f32(float %582)
  %584 = getelementptr inbounds [1 x [64 x float]]* %fusion.1, i64 0, i64 0, i64 39
  store float %583, float* %584, align 4
  %585 = load float* %239, align 4
  %586 = load float* %383, align 4
  %587 = fsub float %585, %586
  %588 = call float @llvm.exp.f32(float %587)
  %589 = getelementptr inbounds [1 x [64 x float]]* %fusion.1, i64 0, i64 0, i64 40
  store float %588, float* %589, align 4
  %590 = load float* %245, align 4
  %591 = load float* %383, align 4
  %592 = fsub float %590, %591
  %593 = call float @llvm.exp.f32(float %592)
  %594 = getelementptr inbounds [1 x [64 x float]]* %fusion.1, i64 0, i64 0, i64 41
  store float %593, float* %594, align 4
  %595 = load float* %251, align 4
  %596 = load float* %383, align 4
  %597 = fsub float %595, %596
  %598 = call float @llvm.exp.f32(float %597)
  %599 = getelementptr inbounds [1 x [64 x float]]* %fusion.1, i64 0, i64 0, i64 42
  store float %598, float* %599, align 4
  %600 = load float* %257, align 4
  %601 = load float* %383, align 4
  %602 = fsub float %600, %601
  %603 = call float @llvm.exp.f32(float %602)
  %604 = getelementptr inbounds [1 x [64 x float]]* %fusion.1, i64 0, i64 0, i64 43
  store float %603, float* %604, align 4
  %605 = load float* %263, align 4
  %606 = load float* %383, align 4
  %607 = fsub float %605, %606
  %608 = call float @llvm.exp.f32(float %607)
  %609 = getelementptr inbounds [1 x [64 x float]]* %fusion.1, i64 0, i64 0, i64 44
  store float %608, float* %609, align 4
  %610 = load float* %269, align 4
  %611 = load float* %383, align 4
  %612 = fsub float %610, %611
  %613 = call float @llvm.exp.f32(float %612)
  %614 = getelementptr inbounds [1 x [64 x float]]* %fusion.1, i64 0, i64 0, i64 45
  store float %613, float* %614, align 4
  %615 = load float* %275, align 4
  %616 = load float* %383, align 4
  %617 = fsub float %615, %616
  %618 = call float @llvm.exp.f32(float %617)
  %619 = getelementptr inbounds [1 x [64 x float]]* %fusion.1, i64 0, i64 0, i64 46
  store float %618, float* %619, align 4
  %620 = load float* %281, align 4
  %621 = load float* %383, align 4
  %622 = fsub float %620, %621
  %623 = call float @llvm.exp.f32(float %622)
  %624 = getelementptr inbounds [1 x [64 x float]]* %fusion.1, i64 0, i64 0, i64 47
  store float %623, float* %624, align 4
  %625 = load float* %287, align 4
  %626 = load float* %383, align 4
  %627 = fsub float %625, %626
  %628 = call float @llvm.exp.f32(float %627)
  %629 = getelementptr inbounds [1 x [64 x float]]* %fusion.1, i64 0, i64 0, i64 48
  store float %628, float* %629, align 4
  %630 = load float* %293, align 4
  %631 = load float* %383, align 4
  %632 = fsub float %630, %631
  %633 = call float @llvm.exp.f32(float %632)
  %634 = getelementptr inbounds [1 x [64 x float]]* %fusion.1, i64 0, i64 0, i64 49
  store float %633, float* %634, align 4
  %635 = load float* %299, align 4
  %636 = load float* %383, align 4
  %637 = fsub float %635, %636
  %638 = call float @llvm.exp.f32(float %637)
  %639 = getelementptr inbounds [1 x [64 x float]]* %fusion.1, i64 0, i64 0, i64 50
  store float %638, float* %639, align 4
  %640 = load float* %305, align 4
  %641 = load float* %383, align 4
  %642 = fsub float %640, %641
  %643 = call float @llvm.exp.f32(float %642)
  %644 = getelementptr inbounds [1 x [64 x float]]* %fusion.1, i64 0, i64 0, i64 51
  store float %643, float* %644, align 4
  %645 = load float* %311, align 4
  %646 = load float* %383, align 4
  %647 = fsub float %645, %646
  %648 = call float @llvm.exp.f32(float %647)
  %649 = getelementptr inbounds [1 x [64 x float]]* %fusion.1, i64 0, i64 0, i64 52
  store float %648, float* %649, align 4
  %650 = load float* %317, align 4
  %651 = load float* %383, align 4
  %652 = fsub float %650, %651
  %653 = call float @llvm.exp.f32(float %652)
  %654 = getelementptr inbounds [1 x [64 x float]]* %fusion.1, i64 0, i64 0, i64 53
  store float %653, float* %654, align 4
  %655 = load float* %323, align 4
  %656 = load float* %383, align 4
  %657 = fsub float %655, %656
  %658 = call float @llvm.exp.f32(float %657)
  %659 = getelementptr inbounds [1 x [64 x float]]* %fusion.1, i64 0, i64 0, i64 54
  store float %658, float* %659, align 4
  %660 = load float* %329, align 4
  %661 = load float* %383, align 4
  %662 = fsub float %660, %661
  %663 = call float @llvm.exp.f32(float %662)
  %664 = getelementptr inbounds [1 x [64 x float]]* %fusion.1, i64 0, i64 0, i64 55
  store float %663, float* %664, align 4
  %665 = load float* %335, align 4
  %666 = load float* %383, align 4
  %667 = fsub float %665, %666
  %668 = call float @llvm.exp.f32(float %667)
  %669 = getelementptr inbounds [1 x [64 x float]]* %fusion.1, i64 0, i64 0, i64 56
  store float %668, float* %669, align 4
  %670 = load float* %341, align 4
  %671 = load float* %383, align 4
  %672 = fsub float %670, %671
  %673 = call float @llvm.exp.f32(float %672)
  %674 = getelementptr inbounds [1 x [64 x float]]* %fusion.1, i64 0, i64 0, i64 57
  store float %673, float* %674, align 4
  %675 = load float* %347, align 4
  %676 = load float* %383, align 4
  %677 = fsub float %675, %676
  %678 = call float @llvm.exp.f32(float %677)
  %679 = getelementptr inbounds [1 x [64 x float]]* %fusion.1, i64 0, i64 0, i64 58
  store float %678, float* %679, align 4
  %680 = load float* %353, align 4
  %681 = load float* %383, align 4
  %682 = fsub float %680, %681
  %683 = call float @llvm.exp.f32(float %682)
  %684 = getelementptr inbounds [1 x [64 x float]]* %fusion.1, i64 0, i64 0, i64 59
  store float %683, float* %684, align 4
  %685 = load float* %359, align 4
  %686 = load float* %383, align 4
  %687 = fsub float %685, %686
  %688 = call float @llvm.exp.f32(float %687)
  %689 = getelementptr inbounds [1 x [64 x float]]* %fusion.1, i64 0, i64 0, i64 60
  store float %688, float* %689, align 4
  %690 = load float* %365, align 4
  %691 = load float* %383, align 4
  %692 = fsub float %690, %691
  %693 = call float @llvm.exp.f32(float %692)
  %694 = getelementptr inbounds [1 x [64 x float]]* %fusion.1, i64 0, i64 0, i64 61
  store float %693, float* %694, align 4
  %695 = load float* %371, align 4
  %696 = load float* %383, align 4
  %697 = fsub float %695, %696
  %698 = call float @llvm.exp.f32(float %697)
  %699 = getelementptr inbounds [1 x [64 x float]]* %fusion.1, i64 0, i64 0, i64 62
  store float %698, float* %699, align 4
  %700 = load float* %377, align 4
  %701 = load float* %383, align 4
  %702 = fsub float %700, %701
  %703 = call float @llvm.exp.f32(float %702)
  %704 = getelementptr inbounds [1 x [64 x float]]* %fusion.1, i64 0, i64 0, i64 63
  store float %703, float* %704, align 4
  %705 = getelementptr inbounds i8* %385, i64 256
  %706 = load float* %389, align 4
  %707 = fadd float 0.000000e+00, %706
  %708 = load float* %394, align 4
  %709 = fadd float %707, %708
  %710 = load float* %399, align 4
  %711 = fadd float %709, %710
  %712 = load float* %404, align 4
  %713 = fadd float %711, %712
  %714 = load float* %409, align 4
  %715 = fadd float %713, %714
  %716 = load float* %414, align 4
  %717 = fadd float %715, %716
  %718 = load float* %419, align 4
  %719 = fadd float %717, %718
  %720 = load float* %424, align 4
  %721 = fadd float %719, %720
  %722 = load float* %429, align 4
  %723 = fadd float %721, %722
  %724 = load float* %434, align 4
  %725 = fadd float %723, %724
  %726 = load float* %439, align 4
  %727 = fadd float %725, %726
  %728 = load float* %444, align 4
  %729 = fadd float %727, %728
  %730 = load float* %449, align 4
  %731 = fadd float %729, %730
  %732 = load float* %454, align 4
  %733 = fadd float %731, %732
  %734 = load float* %459, align 4
  %735 = fadd float %733, %734
  %736 = load float* %464, align 4
  %737 = fadd float %735, %736
  %738 = load float* %469, align 4
  %739 = fadd float %737, %738
  %740 = load float* %474, align 4
  %741 = fadd float %739, %740
  %742 = load float* %479, align 4
  %743 = fadd float %741, %742
  %744 = load float* %484, align 4
  %745 = fadd float %743, %744
  %746 = load float* %489, align 4
  %747 = fadd float %745, %746
  %748 = load float* %494, align 4
  %749 = fadd float %747, %748
  %750 = load float* %499, align 4
  %751 = fadd float %749, %750
  %752 = load float* %504, align 4
  %753 = fadd float %751, %752
  %754 = load float* %509, align 4
  %755 = fadd float %753, %754
  %756 = load float* %514, align 4
  %757 = fadd float %755, %756
  %758 = load float* %519, align 4
  %759 = fadd float %757, %758
  %760 = load float* %524, align 4
  %761 = fadd float %759, %760
  %762 = load float* %529, align 4
  %763 = fadd float %761, %762
  %764 = load float* %534, align 4
  %765 = fadd float %763, %764
  %766 = load float* %539, align 4
  %767 = fadd float %765, %766
  %768 = load float* %544, align 4
  %769 = fadd float %767, %768
  %770 = load float* %549, align 4
  %771 = fadd float %769, %770
  %772 = load float* %554, align 4
  %773 = fadd float %771, %772
  %774 = load float* %559, align 4
  %775 = fadd float %773, %774
  %776 = load float* %564, align 4
  %777 = fadd float %775, %776
  %778 = load float* %569, align 4
  %779 = fadd float %777, %778
  %780 = load float* %574, align 4
  %781 = fadd float %779, %780
  %782 = load float* %579, align 4
  %783 = fadd float %781, %782
  %784 = load float* %584, align 4
  %785 = fadd float %783, %784
  %786 = load float* %589, align 4
  %787 = fadd float %785, %786
  %788 = load float* %594, align 4
  %789 = fadd float %787, %788
  %790 = load float* %599, align 4
  %791 = fadd float %789, %790
  %792 = load float* %604, align 4
  %793 = fadd float %791, %792
  %794 = load float* %609, align 4
  %795 = fadd float %793, %794
  %796 = load float* %614, align 4
  %797 = fadd float %795, %796
  %798 = load float* %619, align 4
  %799 = fadd float %797, %798
  %800 = load float* %624, align 4
  %801 = fadd float %799, %800
  %802 = load float* %629, align 4
  %803 = fadd float %801, %802
  %804 = load float* %634, align 4
  %805 = fadd float %803, %804
  %806 = load float* %639, align 4
  %807 = fadd float %805, %806
  %808 = load float* %644, align 4
  %809 = fadd float %807, %808
  %810 = load float* %649, align 4
  %811 = fadd float %809, %810
  %812 = load float* %654, align 4
  %813 = fadd float %811, %812
  %814 = load float* %659, align 4
  %815 = fadd float %813, %814
  %816 = load float* %664, align 4
  %817 = fadd float %815, %816
  %818 = load float* %669, align 4
  %819 = fadd float %817, %818
  %820 = load float* %674, align 4
  %821 = fadd float %819, %820
  %822 = load float* %679, align 4
  %823 = fadd float %821, %822
  %824 = load float* %684, align 4
  %825 = fadd float %823, %824
  %826 = load float* %689, align 4
  %827 = fadd float %825, %826
  %828 = load float* %694, align 4
  %829 = fadd float %827, %828
  %830 = load float* %699, align 4
  %831 = fadd float %829, %830
  %832 = fadd float %831, %703
  %833 = bitcast i8* %705 to float*
  store float %832, float* %833, align 4
  %fusion = bitcast i8* %0 to [64 x float]*
  %834 = load float* %389, align 4
  %835 = fdiv float %834, %832
  %836 = getelementptr inbounds [64 x float]* %fusion, i64 0, i64 0
  store float %835, float* %836, align 4
  %837 = load float* %394, align 4
  %838 = load float* %833, align 4
  %839 = fdiv float %837, %838
  %840 = getelementptr inbounds [64 x float]* %fusion, i64 0, i64 1
  store float %839, float* %840, align 4
  %841 = load float* %399, align 4
  %842 = load float* %833, align 4
  %843 = fdiv float %841, %842
  %844 = getelementptr inbounds [64 x float]* %fusion, i64 0, i64 2
  store float %843, float* %844, align 4
  %845 = load float* %404, align 4
  %846 = load float* %833, align 4
  %847 = fdiv float %845, %846
  %848 = getelementptr inbounds [64 x float]* %fusion, i64 0, i64 3
  store float %847, float* %848, align 4
  %849 = load float* %409, align 4
  %850 = load float* %833, align 4
  %851 = fdiv float %849, %850
  %852 = getelementptr inbounds [64 x float]* %fusion, i64 0, i64 4
  store float %851, float* %852, align 4
  %853 = load float* %414, align 4
  %854 = load float* %833, align 4
  %855 = fdiv float %853, %854
  %856 = getelementptr inbounds [64 x float]* %fusion, i64 0, i64 5
  store float %855, float* %856, align 4
  %857 = load float* %419, align 4
  %858 = load float* %833, align 4
  %859 = fdiv float %857, %858
  %860 = getelementptr inbounds [64 x float]* %fusion, i64 0, i64 6
  store float %859, float* %860, align 4
  %861 = load float* %424, align 4
  %862 = load float* %833, align 4
  %863 = fdiv float %861, %862
  %864 = getelementptr inbounds [64 x float]* %fusion, i64 0, i64 7
  store float %863, float* %864, align 4
  %865 = load float* %429, align 4
  %866 = load float* %833, align 4
  %867 = fdiv float %865, %866
  %868 = getelementptr inbounds [64 x float]* %fusion, i64 0, i64 8
  store float %867, float* %868, align 4
  %869 = load float* %434, align 4
  %870 = load float* %833, align 4
  %871 = fdiv float %869, %870
  %872 = getelementptr inbounds [64 x float]* %fusion, i64 0, i64 9
  store float %871, float* %872, align 4
  %873 = load float* %439, align 4
  %874 = load float* %833, align 4
  %875 = fdiv float %873, %874
  %876 = getelementptr inbounds [64 x float]* %fusion, i64 0, i64 10
  store float %875, float* %876, align 4
  %877 = load float* %444, align 4
  %878 = load float* %833, align 4
  %879 = fdiv float %877, %878
  %880 = getelementptr inbounds [64 x float]* %fusion, i64 0, i64 11
  store float %879, float* %880, align 4
  %881 = load float* %449, align 4
  %882 = load float* %833, align 4
  %883 = fdiv float %881, %882
  %884 = getelementptr inbounds [64 x float]* %fusion, i64 0, i64 12
  store float %883, float* %884, align 4
  %885 = load float* %454, align 4
  %886 = load float* %833, align 4
  %887 = fdiv float %885, %886
  %888 = getelementptr inbounds [64 x float]* %fusion, i64 0, i64 13
  store float %887, float* %888, align 4
  %889 = load float* %459, align 4
  %890 = load float* %833, align 4
  %891 = fdiv float %889, %890
  %892 = getelementptr inbounds [64 x float]* %fusion, i64 0, i64 14
  store float %891, float* %892, align 4
  %893 = load float* %464, align 4
  %894 = load float* %833, align 4
  %895 = fdiv float %893, %894
  %896 = getelementptr inbounds [64 x float]* %fusion, i64 0, i64 15
  store float %895, float* %896, align 4
  %897 = load float* %469, align 4
  %898 = load float* %833, align 4
  %899 = fdiv float %897, %898
  %900 = getelementptr inbounds [64 x float]* %fusion, i64 0, i64 16
  store float %899, float* %900, align 4
  %901 = load float* %474, align 4
  %902 = load float* %833, align 4
  %903 = fdiv float %901, %902
  %904 = getelementptr inbounds [64 x float]* %fusion, i64 0, i64 17
  store float %903, float* %904, align 4
  %905 = load float* %479, align 4
  %906 = load float* %833, align 4
  %907 = fdiv float %905, %906
  %908 = getelementptr inbounds [64 x float]* %fusion, i64 0, i64 18
  store float %907, float* %908, align 4
  %909 = load float* %484, align 4
  %910 = load float* %833, align 4
  %911 = fdiv float %909, %910
  %912 = getelementptr inbounds [64 x float]* %fusion, i64 0, i64 19
  store float %911, float* %912, align 4
  %913 = load float* %489, align 4
  %914 = load float* %833, align 4
  %915 = fdiv float %913, %914
  %916 = getelementptr inbounds [64 x float]* %fusion, i64 0, i64 20
  store float %915, float* %916, align 4
  %917 = load float* %494, align 4
  %918 = load float* %833, align 4
  %919 = fdiv float %917, %918
  %920 = getelementptr inbounds [64 x float]* %fusion, i64 0, i64 21
  store float %919, float* %920, align 4
  %921 = load float* %499, align 4
  %922 = load float* %833, align 4
  %923 = fdiv float %921, %922
  %924 = getelementptr inbounds [64 x float]* %fusion, i64 0, i64 22
  store float %923, float* %924, align 4
  %925 = load float* %504, align 4
  %926 = load float* %833, align 4
  %927 = fdiv float %925, %926
  %928 = getelementptr inbounds [64 x float]* %fusion, i64 0, i64 23
  store float %927, float* %928, align 4
  %929 = load float* %509, align 4
  %930 = load float* %833, align 4
  %931 = fdiv float %929, %930
  %932 = getelementptr inbounds [64 x float]* %fusion, i64 0, i64 24
  store float %931, float* %932, align 4
  %933 = load float* %514, align 4
  %934 = load float* %833, align 4
  %935 = fdiv float %933, %934
  %936 = getelementptr inbounds [64 x float]* %fusion, i64 0, i64 25
  store float %935, float* %936, align 4
  %937 = load float* %519, align 4
  %938 = load float* %833, align 4
  %939 = fdiv float %937, %938
  %940 = getelementptr inbounds [64 x float]* %fusion, i64 0, i64 26
  store float %939, float* %940, align 4
  %941 = load float* %524, align 4
  %942 = load float* %833, align 4
  %943 = fdiv float %941, %942
  %944 = getelementptr inbounds [64 x float]* %fusion, i64 0, i64 27
  store float %943, float* %944, align 4
  %945 = load float* %529, align 4
  %946 = load float* %833, align 4
  %947 = fdiv float %945, %946
  %948 = getelementptr inbounds [64 x float]* %fusion, i64 0, i64 28
  store float %947, float* %948, align 4
  %949 = load float* %534, align 4
  %950 = load float* %833, align 4
  %951 = fdiv float %949, %950
  %952 = getelementptr inbounds [64 x float]* %fusion, i64 0, i64 29
  store float %951, float* %952, align 4
  %953 = load float* %539, align 4
  %954 = load float* %833, align 4
  %955 = fdiv float %953, %954
  %956 = getelementptr inbounds [64 x float]* %fusion, i64 0, i64 30
  store float %955, float* %956, align 4
  %957 = load float* %544, align 4
  %958 = load float* %833, align 4
  %959 = fdiv float %957, %958
  %960 = getelementptr inbounds [64 x float]* %fusion, i64 0, i64 31
  store float %959, float* %960, align 4
  %961 = load float* %549, align 4
  %962 = load float* %833, align 4
  %963 = fdiv float %961, %962
  %964 = getelementptr inbounds [64 x float]* %fusion, i64 0, i64 32
  store float %963, float* %964, align 4
  %965 = load float* %554, align 4
  %966 = load float* %833, align 4
  %967 = fdiv float %965, %966
  %968 = getelementptr inbounds [64 x float]* %fusion, i64 0, i64 33
  store float %967, float* %968, align 4
  %969 = load float* %559, align 4
  %970 = load float* %833, align 4
  %971 = fdiv float %969, %970
  %972 = getelementptr inbounds [64 x float]* %fusion, i64 0, i64 34
  store float %971, float* %972, align 4
  %973 = load float* %564, align 4
  %974 = load float* %833, align 4
  %975 = fdiv float %973, %974
  %976 = getelementptr inbounds [64 x float]* %fusion, i64 0, i64 35
  store float %975, float* %976, align 4
  %977 = load float* %569, align 4
  %978 = load float* %833, align 4
  %979 = fdiv float %977, %978
  %980 = getelementptr inbounds [64 x float]* %fusion, i64 0, i64 36
  store float %979, float* %980, align 4
  %981 = load float* %574, align 4
  %982 = load float* %833, align 4
  %983 = fdiv float %981, %982
  %984 = getelementptr inbounds [64 x float]* %fusion, i64 0, i64 37
  store float %983, float* %984, align 4
  %985 = load float* %579, align 4
  %986 = load float* %833, align 4
  %987 = fdiv float %985, %986
  %988 = getelementptr inbounds [64 x float]* %fusion, i64 0, i64 38
  store float %987, float* %988, align 4
  %989 = load float* %584, align 4
  %990 = load float* %833, align 4
  %991 = fdiv float %989, %990
  %992 = getelementptr inbounds [64 x float]* %fusion, i64 0, i64 39
  store float %991, float* %992, align 4
  %993 = load float* %589, align 4
  %994 = load float* %833, align 4
  %995 = fdiv float %993, %994
  %996 = getelementptr inbounds [64 x float]* %fusion, i64 0, i64 40
  store float %995, float* %996, align 4
  %997 = load float* %594, align 4
  %998 = load float* %833, align 4
  %999 = fdiv float %997, %998
  %1000 = getelementptr inbounds [64 x float]* %fusion, i64 0, i64 41
  store float %999, float* %1000, align 4
  %1001 = load float* %599, align 4
  %1002 = load float* %833, align 4
  %1003 = fdiv float %1001, %1002
  %1004 = getelementptr inbounds [64 x float]* %fusion, i64 0, i64 42
  store float %1003, float* %1004, align 4
  %1005 = load float* %604, align 4
  %1006 = load float* %833, align 4
  %1007 = fdiv float %1005, %1006
  %1008 = getelementptr inbounds [64 x float]* %fusion, i64 0, i64 43
  store float %1007, float* %1008, align 4
  %1009 = load float* %609, align 4
  %1010 = load float* %833, align 4
  %1011 = fdiv float %1009, %1010
  %1012 = getelementptr inbounds [64 x float]* %fusion, i64 0, i64 44
  store float %1011, float* %1012, align 4
  %1013 = load float* %614, align 4
  %1014 = load float* %833, align 4
  %1015 = fdiv float %1013, %1014
  %1016 = getelementptr inbounds [64 x float]* %fusion, i64 0, i64 45
  store float %1015, float* %1016, align 4
  %1017 = load float* %619, align 4
  %1018 = load float* %833, align 4
  %1019 = fdiv float %1017, %1018
  %1020 = getelementptr inbounds [64 x float]* %fusion, i64 0, i64 46
  store float %1019, float* %1020, align 4
  %1021 = load float* %624, align 4
  %1022 = load float* %833, align 4
  %1023 = fdiv float %1021, %1022
  %1024 = getelementptr inbounds [64 x float]* %fusion, i64 0, i64 47
  store float %1023, float* %1024, align 4
  %1025 = load float* %629, align 4
  %1026 = load float* %833, align 4
  %1027 = fdiv float %1025, %1026
  %1028 = getelementptr inbounds [64 x float]* %fusion, i64 0, i64 48
  store float %1027, float* %1028, align 4
  %1029 = load float* %634, align 4
  %1030 = load float* %833, align 4
  %1031 = fdiv float %1029, %1030
  %1032 = getelementptr inbounds [64 x float]* %fusion, i64 0, i64 49
  store float %1031, float* %1032, align 4
  %1033 = load float* %639, align 4
  %1034 = load float* %833, align 4
  %1035 = fdiv float %1033, %1034
  %1036 = getelementptr inbounds [64 x float]* %fusion, i64 0, i64 50
  store float %1035, float* %1036, align 4
  %1037 = load float* %644, align 4
  %1038 = load float* %833, align 4
  %1039 = fdiv float %1037, %1038
  %1040 = getelementptr inbounds [64 x float]* %fusion, i64 0, i64 51
  store float %1039, float* %1040, align 4
  %1041 = load float* %649, align 4
  %1042 = load float* %833, align 4
  %1043 = fdiv float %1041, %1042
  %1044 = getelementptr inbounds [64 x float]* %fusion, i64 0, i64 52
  store float %1043, float* %1044, align 4
  %1045 = load float* %654, align 4
  %1046 = load float* %833, align 4
  %1047 = fdiv float %1045, %1046
  %1048 = getelementptr inbounds [64 x float]* %fusion, i64 0, i64 53
  store float %1047, float* %1048, align 4
  %1049 = load float* %659, align 4
  %1050 = load float* %833, align 4
  %1051 = fdiv float %1049, %1050
  %1052 = getelementptr inbounds [64 x float]* %fusion, i64 0, i64 54
  store float %1051, float* %1052, align 4
  %1053 = load float* %664, align 4
  %1054 = load float* %833, align 4
  %1055 = fdiv float %1053, %1054
  %1056 = getelementptr inbounds [64 x float]* %fusion, i64 0, i64 55
  store float %1055, float* %1056, align 4
  %1057 = load float* %669, align 4
  %1058 = load float* %833, align 4
  %1059 = fdiv float %1057, %1058
  %1060 = getelementptr inbounds [64 x float]* %fusion, i64 0, i64 56
  store float %1059, float* %1060, align 4
  %1061 = load float* %674, align 4
  %1062 = load float* %833, align 4
  %1063 = fdiv float %1061, %1062
  %1064 = getelementptr inbounds [64 x float]* %fusion, i64 0, i64 57
  store float %1063, float* %1064, align 4
  %1065 = load float* %679, align 4
  %1066 = load float* %833, align 4
  %1067 = fdiv float %1065, %1066
  %1068 = getelementptr inbounds [64 x float]* %fusion, i64 0, i64 58
  store float %1067, float* %1068, align 4
  %1069 = load float* %684, align 4
  %1070 = load float* %833, align 4
  %1071 = fdiv float %1069, %1070
  %1072 = getelementptr inbounds [64 x float]* %fusion, i64 0, i64 59
  store float %1071, float* %1072, align 4
  %1073 = load float* %689, align 4
  %1074 = load float* %833, align 4
  %1075 = fdiv float %1073, %1074
  %1076 = getelementptr inbounds [64 x float]* %fusion, i64 0, i64 60
  store float %1075, float* %1076, align 4
  %1077 = load float* %694, align 4
  %1078 = load float* %833, align 4
  %1079 = fdiv float %1077, %1078
  %1080 = getelementptr inbounds [64 x float]* %fusion, i64 0, i64 61
  store float %1079, float* %1080, align 4
  %1081 = load float* %699, align 4
  %1082 = load float* %833, align 4
  %1083 = fdiv float %1081, %1082
  %1084 = getelementptr inbounds [64 x float]* %fusion, i64 0, i64 62
  store float %1083, float* %1084, align 4
  %1085 = load float* %704, align 4
  %1086 = load float* %833, align 4
  %1087 = fdiv float %1085, %1086
  %1088 = getelementptr inbounds [64 x float]* %fusion, i64 0, i64 63
  store float %1087, float* %1088, align 4
  %1089 = bitcast i8* %retval to i8**
  store i8* %0, i8** %1089, align 8
  ret void
}

; Function Attrs: nounwind readnone
declare float @llvm.exp.f32(float) #1

attributes #0 = { "no-frame-pointer-elim"="false" }
attributes #1 = { nounwind readnone }

!0 = metadata !{i64 256}
!1 = metadata !{i64 8}
!2 = metadata !{i64 260}
