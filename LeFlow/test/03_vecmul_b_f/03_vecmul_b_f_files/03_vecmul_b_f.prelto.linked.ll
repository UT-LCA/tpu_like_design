; ModuleID = '03_vecmul_b_f.prelto.linked.bc'
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux_gnu"

@temp0 = global [64 x float] zeroinitializer, align 8
@param1 = global [64 x float] zeroinitializer, align 8
@param0 = global [64 x float] zeroinitializer, align 8

define float @main() #0 {
multiply.loop_body.dim.0.lr.ph:
  %0 = getelementptr inbounds [64 x float]* @param1, i64 0, i64 0
  %1 = load volatile float* %0, align 4
  %2 = getelementptr inbounds [64 x float]* @param0, i64 0, i64 0
  %3 = load volatile float* %2, align 4
  %4 = fmul float %1, %3
  %5 = getelementptr inbounds [64 x float]* @temp0, i64 0, i64 0
  store volatile float %4, float* %5, align 4
  %6 = getelementptr inbounds [64 x float]* @param1, i64 0, i64 1
  %7 = load volatile float* %6, align 4
  %8 = getelementptr inbounds [64 x float]* @param0, i64 0, i64 1
  %9 = load volatile float* %8, align 4
  %10 = fmul float %7, %9
  %11 = getelementptr inbounds [64 x float]* @temp0, i64 0, i64 1
  store volatile float %10, float* %11, align 4
  %12 = getelementptr inbounds [64 x float]* @param1, i64 0, i64 2
  %13 = load volatile float* %12, align 4
  %14 = getelementptr inbounds [64 x float]* @param0, i64 0, i64 2
  %15 = load volatile float* %14, align 4
  %16 = fmul float %13, %15
  %17 = getelementptr inbounds [64 x float]* @temp0, i64 0, i64 2
  store volatile float %16, float* %17, align 4
  %18 = getelementptr inbounds [64 x float]* @param1, i64 0, i64 3
  %19 = load volatile float* %18, align 4
  %20 = getelementptr inbounds [64 x float]* @param0, i64 0, i64 3
  %21 = load volatile float* %20, align 4
  %22 = fmul float %19, %21
  %23 = getelementptr inbounds [64 x float]* @temp0, i64 0, i64 3
  store volatile float %22, float* %23, align 4
  %24 = getelementptr inbounds [64 x float]* @param1, i64 0, i64 4
  %25 = load volatile float* %24, align 4
  %26 = getelementptr inbounds [64 x float]* @param0, i64 0, i64 4
  %27 = load volatile float* %26, align 4
  %28 = fmul float %25, %27
  %29 = getelementptr inbounds [64 x float]* @temp0, i64 0, i64 4
  store volatile float %28, float* %29, align 4
  %30 = getelementptr inbounds [64 x float]* @param1, i64 0, i64 5
  %31 = load volatile float* %30, align 4
  %32 = getelementptr inbounds [64 x float]* @param0, i64 0, i64 5
  %33 = load volatile float* %32, align 4
  %34 = fmul float %31, %33
  %35 = getelementptr inbounds [64 x float]* @temp0, i64 0, i64 5
  store volatile float %34, float* %35, align 4
  %36 = getelementptr inbounds [64 x float]* @param1, i64 0, i64 6
  %37 = load volatile float* %36, align 4
  %38 = getelementptr inbounds [64 x float]* @param0, i64 0, i64 6
  %39 = load volatile float* %38, align 4
  %40 = fmul float %37, %39
  %41 = getelementptr inbounds [64 x float]* @temp0, i64 0, i64 6
  store volatile float %40, float* %41, align 4
  %42 = getelementptr inbounds [64 x float]* @param1, i64 0, i64 7
  %43 = load volatile float* %42, align 4
  %44 = getelementptr inbounds [64 x float]* @param0, i64 0, i64 7
  %45 = load volatile float* %44, align 4
  %46 = fmul float %43, %45
  %47 = getelementptr inbounds [64 x float]* @temp0, i64 0, i64 7
  store volatile float %46, float* %47, align 4
  %48 = getelementptr inbounds [64 x float]* @param1, i64 0, i64 8
  %49 = load volatile float* %48, align 4
  %50 = getelementptr inbounds [64 x float]* @param0, i64 0, i64 8
  %51 = load volatile float* %50, align 4
  %52 = fmul float %49, %51
  %53 = getelementptr inbounds [64 x float]* @temp0, i64 0, i64 8
  store volatile float %52, float* %53, align 4
  %54 = getelementptr inbounds [64 x float]* @param1, i64 0, i64 9
  %55 = load volatile float* %54, align 4
  %56 = getelementptr inbounds [64 x float]* @param0, i64 0, i64 9
  %57 = load volatile float* %56, align 4
  %58 = fmul float %55, %57
  %59 = getelementptr inbounds [64 x float]* @temp0, i64 0, i64 9
  store volatile float %58, float* %59, align 4
  %60 = getelementptr inbounds [64 x float]* @param1, i64 0, i64 10
  %61 = load volatile float* %60, align 4
  %62 = getelementptr inbounds [64 x float]* @param0, i64 0, i64 10
  %63 = load volatile float* %62, align 4
  %64 = fmul float %61, %63
  %65 = getelementptr inbounds [64 x float]* @temp0, i64 0, i64 10
  store volatile float %64, float* %65, align 4
  %66 = getelementptr inbounds [64 x float]* @param1, i64 0, i64 11
  %67 = load volatile float* %66, align 4
  %68 = getelementptr inbounds [64 x float]* @param0, i64 0, i64 11
  %69 = load volatile float* %68, align 4
  %70 = fmul float %67, %69
  %71 = getelementptr inbounds [64 x float]* @temp0, i64 0, i64 11
  store volatile float %70, float* %71, align 4
  %72 = getelementptr inbounds [64 x float]* @param1, i64 0, i64 12
  %73 = load volatile float* %72, align 4
  %74 = getelementptr inbounds [64 x float]* @param0, i64 0, i64 12
  %75 = load volatile float* %74, align 4
  %76 = fmul float %73, %75
  %77 = getelementptr inbounds [64 x float]* @temp0, i64 0, i64 12
  store volatile float %76, float* %77, align 4
  %78 = getelementptr inbounds [64 x float]* @param1, i64 0, i64 13
  %79 = load volatile float* %78, align 4
  %80 = getelementptr inbounds [64 x float]* @param0, i64 0, i64 13
  %81 = load volatile float* %80, align 4
  %82 = fmul float %79, %81
  %83 = getelementptr inbounds [64 x float]* @temp0, i64 0, i64 13
  store volatile float %82, float* %83, align 4
  %84 = getelementptr inbounds [64 x float]* @param1, i64 0, i64 14
  %85 = load volatile float* %84, align 4
  %86 = getelementptr inbounds [64 x float]* @param0, i64 0, i64 14
  %87 = load volatile float* %86, align 4
  %88 = fmul float %85, %87
  %89 = getelementptr inbounds [64 x float]* @temp0, i64 0, i64 14
  store volatile float %88, float* %89, align 4
  %90 = getelementptr inbounds [64 x float]* @param1, i64 0, i64 15
  %91 = load volatile float* %90, align 4
  %92 = getelementptr inbounds [64 x float]* @param0, i64 0, i64 15
  %93 = load volatile float* %92, align 4
  %94 = fmul float %91, %93
  %95 = getelementptr inbounds [64 x float]* @temp0, i64 0, i64 15
  store volatile float %94, float* %95, align 4
  %96 = getelementptr inbounds [64 x float]* @param1, i64 0, i64 16
  %97 = load volatile float* %96, align 4
  %98 = getelementptr inbounds [64 x float]* @param0, i64 0, i64 16
  %99 = load volatile float* %98, align 4
  %100 = fmul float %97, %99
  %101 = getelementptr inbounds [64 x float]* @temp0, i64 0, i64 16
  store volatile float %100, float* %101, align 4
  %102 = getelementptr inbounds [64 x float]* @param1, i64 0, i64 17
  %103 = load volatile float* %102, align 4
  %104 = getelementptr inbounds [64 x float]* @param0, i64 0, i64 17
  %105 = load volatile float* %104, align 4
  %106 = fmul float %103, %105
  %107 = getelementptr inbounds [64 x float]* @temp0, i64 0, i64 17
  store volatile float %106, float* %107, align 4
  %108 = getelementptr inbounds [64 x float]* @param1, i64 0, i64 18
  %109 = load volatile float* %108, align 4
  %110 = getelementptr inbounds [64 x float]* @param0, i64 0, i64 18
  %111 = load volatile float* %110, align 4
  %112 = fmul float %109, %111
  %113 = getelementptr inbounds [64 x float]* @temp0, i64 0, i64 18
  store volatile float %112, float* %113, align 4
  %114 = getelementptr inbounds [64 x float]* @param1, i64 0, i64 19
  %115 = load volatile float* %114, align 4
  %116 = getelementptr inbounds [64 x float]* @param0, i64 0, i64 19
  %117 = load volatile float* %116, align 4
  %118 = fmul float %115, %117
  %119 = getelementptr inbounds [64 x float]* @temp0, i64 0, i64 19
  store volatile float %118, float* %119, align 4
  %120 = getelementptr inbounds [64 x float]* @param1, i64 0, i64 20
  %121 = load volatile float* %120, align 4
  %122 = getelementptr inbounds [64 x float]* @param0, i64 0, i64 20
  %123 = load volatile float* %122, align 4
  %124 = fmul float %121, %123
  %125 = getelementptr inbounds [64 x float]* @temp0, i64 0, i64 20
  store volatile float %124, float* %125, align 4
  %126 = getelementptr inbounds [64 x float]* @param1, i64 0, i64 21
  %127 = load volatile float* %126, align 4
  %128 = getelementptr inbounds [64 x float]* @param0, i64 0, i64 21
  %129 = load volatile float* %128, align 4
  %130 = fmul float %127, %129
  %131 = getelementptr inbounds [64 x float]* @temp0, i64 0, i64 21
  store volatile float %130, float* %131, align 4
  %132 = getelementptr inbounds [64 x float]* @param1, i64 0, i64 22
  %133 = load volatile float* %132, align 4
  %134 = getelementptr inbounds [64 x float]* @param0, i64 0, i64 22
  %135 = load volatile float* %134, align 4
  %136 = fmul float %133, %135
  %137 = getelementptr inbounds [64 x float]* @temp0, i64 0, i64 22
  store volatile float %136, float* %137, align 4
  %138 = getelementptr inbounds [64 x float]* @param1, i64 0, i64 23
  %139 = load volatile float* %138, align 4
  %140 = getelementptr inbounds [64 x float]* @param0, i64 0, i64 23
  %141 = load volatile float* %140, align 4
  %142 = fmul float %139, %141
  %143 = getelementptr inbounds [64 x float]* @temp0, i64 0, i64 23
  store volatile float %142, float* %143, align 4
  %144 = getelementptr inbounds [64 x float]* @param1, i64 0, i64 24
  %145 = load volatile float* %144, align 4
  %146 = getelementptr inbounds [64 x float]* @param0, i64 0, i64 24
  %147 = load volatile float* %146, align 4
  %148 = fmul float %145, %147
  %149 = getelementptr inbounds [64 x float]* @temp0, i64 0, i64 24
  store volatile float %148, float* %149, align 4
  %150 = getelementptr inbounds [64 x float]* @param1, i64 0, i64 25
  %151 = load volatile float* %150, align 4
  %152 = getelementptr inbounds [64 x float]* @param0, i64 0, i64 25
  %153 = load volatile float* %152, align 4
  %154 = fmul float %151, %153
  %155 = getelementptr inbounds [64 x float]* @temp0, i64 0, i64 25
  store volatile float %154, float* %155, align 4
  %156 = getelementptr inbounds [64 x float]* @param1, i64 0, i64 26
  %157 = load volatile float* %156, align 4
  %158 = getelementptr inbounds [64 x float]* @param0, i64 0, i64 26
  %159 = load volatile float* %158, align 4
  %160 = fmul float %157, %159
  %161 = getelementptr inbounds [64 x float]* @temp0, i64 0, i64 26
  store volatile float %160, float* %161, align 4
  %162 = getelementptr inbounds [64 x float]* @param1, i64 0, i64 27
  %163 = load volatile float* %162, align 4
  %164 = getelementptr inbounds [64 x float]* @param0, i64 0, i64 27
  %165 = load volatile float* %164, align 4
  %166 = fmul float %163, %165
  %167 = getelementptr inbounds [64 x float]* @temp0, i64 0, i64 27
  store volatile float %166, float* %167, align 4
  %168 = getelementptr inbounds [64 x float]* @param1, i64 0, i64 28
  %169 = load volatile float* %168, align 4
  %170 = getelementptr inbounds [64 x float]* @param0, i64 0, i64 28
  %171 = load volatile float* %170, align 4
  %172 = fmul float %169, %171
  %173 = getelementptr inbounds [64 x float]* @temp0, i64 0, i64 28
  store volatile float %172, float* %173, align 4
  %174 = getelementptr inbounds [64 x float]* @param1, i64 0, i64 29
  %175 = load volatile float* %174, align 4
  %176 = getelementptr inbounds [64 x float]* @param0, i64 0, i64 29
  %177 = load volatile float* %176, align 4
  %178 = fmul float %175, %177
  %179 = getelementptr inbounds [64 x float]* @temp0, i64 0, i64 29
  store volatile float %178, float* %179, align 4
  %180 = getelementptr inbounds [64 x float]* @param1, i64 0, i64 30
  %181 = load volatile float* %180, align 4
  %182 = getelementptr inbounds [64 x float]* @param0, i64 0, i64 30
  %183 = load volatile float* %182, align 4
  %184 = fmul float %181, %183
  %185 = getelementptr inbounds [64 x float]* @temp0, i64 0, i64 30
  store volatile float %184, float* %185, align 4
  %186 = getelementptr inbounds [64 x float]* @param1, i64 0, i64 31
  %187 = load volatile float* %186, align 4
  %188 = getelementptr inbounds [64 x float]* @param0, i64 0, i64 31
  %189 = load volatile float* %188, align 4
  %190 = fmul float %187, %189
  %191 = getelementptr inbounds [64 x float]* @temp0, i64 0, i64 31
  store volatile float %190, float* %191, align 4
  %192 = getelementptr inbounds [64 x float]* @param1, i64 0, i64 32
  %193 = load volatile float* %192, align 4
  %194 = getelementptr inbounds [64 x float]* @param0, i64 0, i64 32
  %195 = load volatile float* %194, align 4
  %196 = fmul float %193, %195
  %197 = getelementptr inbounds [64 x float]* @temp0, i64 0, i64 32
  store volatile float %196, float* %197, align 4
  %198 = getelementptr inbounds [64 x float]* @param1, i64 0, i64 33
  %199 = load volatile float* %198, align 4
  %200 = getelementptr inbounds [64 x float]* @param0, i64 0, i64 33
  %201 = load volatile float* %200, align 4
  %202 = fmul float %199, %201
  %203 = getelementptr inbounds [64 x float]* @temp0, i64 0, i64 33
  store volatile float %202, float* %203, align 4
  %204 = getelementptr inbounds [64 x float]* @param1, i64 0, i64 34
  %205 = load volatile float* %204, align 4
  %206 = getelementptr inbounds [64 x float]* @param0, i64 0, i64 34
  %207 = load volatile float* %206, align 4
  %208 = fmul float %205, %207
  %209 = getelementptr inbounds [64 x float]* @temp0, i64 0, i64 34
  store volatile float %208, float* %209, align 4
  %210 = getelementptr inbounds [64 x float]* @param1, i64 0, i64 35
  %211 = load volatile float* %210, align 4
  %212 = getelementptr inbounds [64 x float]* @param0, i64 0, i64 35
  %213 = load volatile float* %212, align 4
  %214 = fmul float %211, %213
  %215 = getelementptr inbounds [64 x float]* @temp0, i64 0, i64 35
  store volatile float %214, float* %215, align 4
  %216 = getelementptr inbounds [64 x float]* @param1, i64 0, i64 36
  %217 = load volatile float* %216, align 4
  %218 = getelementptr inbounds [64 x float]* @param0, i64 0, i64 36
  %219 = load volatile float* %218, align 4
  %220 = fmul float %217, %219
  %221 = getelementptr inbounds [64 x float]* @temp0, i64 0, i64 36
  store volatile float %220, float* %221, align 4
  %222 = getelementptr inbounds [64 x float]* @param1, i64 0, i64 37
  %223 = load volatile float* %222, align 4
  %224 = getelementptr inbounds [64 x float]* @param0, i64 0, i64 37
  %225 = load volatile float* %224, align 4
  %226 = fmul float %223, %225
  %227 = getelementptr inbounds [64 x float]* @temp0, i64 0, i64 37
  store volatile float %226, float* %227, align 4
  %228 = getelementptr inbounds [64 x float]* @param1, i64 0, i64 38
  %229 = load volatile float* %228, align 4
  %230 = getelementptr inbounds [64 x float]* @param0, i64 0, i64 38
  %231 = load volatile float* %230, align 4
  %232 = fmul float %229, %231
  %233 = getelementptr inbounds [64 x float]* @temp0, i64 0, i64 38
  store volatile float %232, float* %233, align 4
  %234 = getelementptr inbounds [64 x float]* @param1, i64 0, i64 39
  %235 = load volatile float* %234, align 4
  %236 = getelementptr inbounds [64 x float]* @param0, i64 0, i64 39
  %237 = load volatile float* %236, align 4
  %238 = fmul float %235, %237
  %239 = getelementptr inbounds [64 x float]* @temp0, i64 0, i64 39
  store volatile float %238, float* %239, align 4
  %240 = getelementptr inbounds [64 x float]* @param1, i64 0, i64 40
  %241 = load volatile float* %240, align 4
  %242 = getelementptr inbounds [64 x float]* @param0, i64 0, i64 40
  %243 = load volatile float* %242, align 4
  %244 = fmul float %241, %243
  %245 = getelementptr inbounds [64 x float]* @temp0, i64 0, i64 40
  store volatile float %244, float* %245, align 4
  %246 = getelementptr inbounds [64 x float]* @param1, i64 0, i64 41
  %247 = load volatile float* %246, align 4
  %248 = getelementptr inbounds [64 x float]* @param0, i64 0, i64 41
  %249 = load volatile float* %248, align 4
  %250 = fmul float %247, %249
  %251 = getelementptr inbounds [64 x float]* @temp0, i64 0, i64 41
  store volatile float %250, float* %251, align 4
  %252 = getelementptr inbounds [64 x float]* @param1, i64 0, i64 42
  %253 = load volatile float* %252, align 4
  %254 = getelementptr inbounds [64 x float]* @param0, i64 0, i64 42
  %255 = load volatile float* %254, align 4
  %256 = fmul float %253, %255
  %257 = getelementptr inbounds [64 x float]* @temp0, i64 0, i64 42
  store volatile float %256, float* %257, align 4
  %258 = getelementptr inbounds [64 x float]* @param1, i64 0, i64 43
  %259 = load volatile float* %258, align 4
  %260 = getelementptr inbounds [64 x float]* @param0, i64 0, i64 43
  %261 = load volatile float* %260, align 4
  %262 = fmul float %259, %261
  %263 = getelementptr inbounds [64 x float]* @temp0, i64 0, i64 43
  store volatile float %262, float* %263, align 4
  %264 = getelementptr inbounds [64 x float]* @param1, i64 0, i64 44
  %265 = load volatile float* %264, align 4
  %266 = getelementptr inbounds [64 x float]* @param0, i64 0, i64 44
  %267 = load volatile float* %266, align 4
  %268 = fmul float %265, %267
  %269 = getelementptr inbounds [64 x float]* @temp0, i64 0, i64 44
  store volatile float %268, float* %269, align 4
  %270 = getelementptr inbounds [64 x float]* @param1, i64 0, i64 45
  %271 = load volatile float* %270, align 4
  %272 = getelementptr inbounds [64 x float]* @param0, i64 0, i64 45
  %273 = load volatile float* %272, align 4
  %274 = fmul float %271, %273
  %275 = getelementptr inbounds [64 x float]* @temp0, i64 0, i64 45
  store volatile float %274, float* %275, align 4
  %276 = getelementptr inbounds [64 x float]* @param1, i64 0, i64 46
  %277 = load volatile float* %276, align 4
  %278 = getelementptr inbounds [64 x float]* @param0, i64 0, i64 46
  %279 = load volatile float* %278, align 4
  %280 = fmul float %277, %279
  %281 = getelementptr inbounds [64 x float]* @temp0, i64 0, i64 46
  store volatile float %280, float* %281, align 4
  %282 = getelementptr inbounds [64 x float]* @param1, i64 0, i64 47
  %283 = load volatile float* %282, align 4
  %284 = getelementptr inbounds [64 x float]* @param0, i64 0, i64 47
  %285 = load volatile float* %284, align 4
  %286 = fmul float %283, %285
  %287 = getelementptr inbounds [64 x float]* @temp0, i64 0, i64 47
  store volatile float %286, float* %287, align 4
  %288 = getelementptr inbounds [64 x float]* @param1, i64 0, i64 48
  %289 = load volatile float* %288, align 4
  %290 = getelementptr inbounds [64 x float]* @param0, i64 0, i64 48
  %291 = load volatile float* %290, align 4
  %292 = fmul float %289, %291
  %293 = getelementptr inbounds [64 x float]* @temp0, i64 0, i64 48
  store volatile float %292, float* %293, align 4
  %294 = getelementptr inbounds [64 x float]* @param1, i64 0, i64 49
  %295 = load volatile float* %294, align 4
  %296 = getelementptr inbounds [64 x float]* @param0, i64 0, i64 49
  %297 = load volatile float* %296, align 4
  %298 = fmul float %295, %297
  %299 = getelementptr inbounds [64 x float]* @temp0, i64 0, i64 49
  store volatile float %298, float* %299, align 4
  %300 = getelementptr inbounds [64 x float]* @param1, i64 0, i64 50
  %301 = load volatile float* %300, align 4
  %302 = getelementptr inbounds [64 x float]* @param0, i64 0, i64 50
  %303 = load volatile float* %302, align 4
  %304 = fmul float %301, %303
  %305 = getelementptr inbounds [64 x float]* @temp0, i64 0, i64 50
  store volatile float %304, float* %305, align 4
  %306 = getelementptr inbounds [64 x float]* @param1, i64 0, i64 51
  %307 = load volatile float* %306, align 4
  %308 = getelementptr inbounds [64 x float]* @param0, i64 0, i64 51
  %309 = load volatile float* %308, align 4
  %310 = fmul float %307, %309
  %311 = getelementptr inbounds [64 x float]* @temp0, i64 0, i64 51
  store volatile float %310, float* %311, align 4
  %312 = getelementptr inbounds [64 x float]* @param1, i64 0, i64 52
  %313 = load volatile float* %312, align 4
  %314 = getelementptr inbounds [64 x float]* @param0, i64 0, i64 52
  %315 = load volatile float* %314, align 4
  %316 = fmul float %313, %315
  %317 = getelementptr inbounds [64 x float]* @temp0, i64 0, i64 52
  store volatile float %316, float* %317, align 4
  %318 = getelementptr inbounds [64 x float]* @param1, i64 0, i64 53
  %319 = load volatile float* %318, align 4
  %320 = getelementptr inbounds [64 x float]* @param0, i64 0, i64 53
  %321 = load volatile float* %320, align 4
  %322 = fmul float %319, %321
  %323 = getelementptr inbounds [64 x float]* @temp0, i64 0, i64 53
  store volatile float %322, float* %323, align 4
  %324 = getelementptr inbounds [64 x float]* @param1, i64 0, i64 54
  %325 = load volatile float* %324, align 4
  %326 = getelementptr inbounds [64 x float]* @param0, i64 0, i64 54
  %327 = load volatile float* %326, align 4
  %328 = fmul float %325, %327
  %329 = getelementptr inbounds [64 x float]* @temp0, i64 0, i64 54
  store volatile float %328, float* %329, align 4
  %330 = getelementptr inbounds [64 x float]* @param1, i64 0, i64 55
  %331 = load volatile float* %330, align 4
  %332 = getelementptr inbounds [64 x float]* @param0, i64 0, i64 55
  %333 = load volatile float* %332, align 4
  %334 = fmul float %331, %333
  %335 = getelementptr inbounds [64 x float]* @temp0, i64 0, i64 55
  store volatile float %334, float* %335, align 4
  %336 = getelementptr inbounds [64 x float]* @param1, i64 0, i64 56
  %337 = load volatile float* %336, align 4
  %338 = getelementptr inbounds [64 x float]* @param0, i64 0, i64 56
  %339 = load volatile float* %338, align 4
  %340 = fmul float %337, %339
  %341 = getelementptr inbounds [64 x float]* @temp0, i64 0, i64 56
  store volatile float %340, float* %341, align 4
  %342 = getelementptr inbounds [64 x float]* @param1, i64 0, i64 57
  %343 = load volatile float* %342, align 4
  %344 = getelementptr inbounds [64 x float]* @param0, i64 0, i64 57
  %345 = load volatile float* %344, align 4
  %346 = fmul float %343, %345
  %347 = getelementptr inbounds [64 x float]* @temp0, i64 0, i64 57
  store volatile float %346, float* %347, align 4
  %348 = getelementptr inbounds [64 x float]* @param1, i64 0, i64 58
  %349 = load volatile float* %348, align 4
  %350 = getelementptr inbounds [64 x float]* @param0, i64 0, i64 58
  %351 = load volatile float* %350, align 4
  %352 = fmul float %349, %351
  %353 = getelementptr inbounds [64 x float]* @temp0, i64 0, i64 58
  store volatile float %352, float* %353, align 4
  %354 = getelementptr inbounds [64 x float]* @param1, i64 0, i64 59
  %355 = load volatile float* %354, align 4
  %356 = getelementptr inbounds [64 x float]* @param0, i64 0, i64 59
  %357 = load volatile float* %356, align 4
  %358 = fmul float %355, %357
  %359 = getelementptr inbounds [64 x float]* @temp0, i64 0, i64 59
  store volatile float %358, float* %359, align 4
  %360 = getelementptr inbounds [64 x float]* @param1, i64 0, i64 60
  %361 = load volatile float* %360, align 4
  %362 = getelementptr inbounds [64 x float]* @param0, i64 0, i64 60
  %363 = load volatile float* %362, align 4
  %364 = fmul float %361, %363
  %365 = getelementptr inbounds [64 x float]* @temp0, i64 0, i64 60
  store volatile float %364, float* %365, align 4
  %366 = getelementptr inbounds [64 x float]* @param1, i64 0, i64 61
  %367 = load volatile float* %366, align 4
  %368 = getelementptr inbounds [64 x float]* @param0, i64 0, i64 61
  %369 = load volatile float* %368, align 4
  %370 = fmul float %367, %369
  %371 = getelementptr inbounds [64 x float]* @temp0, i64 0, i64 61
  store volatile float %370, float* %371, align 4
  %372 = getelementptr inbounds [64 x float]* @param1, i64 0, i64 62
  %373 = load volatile float* %372, align 4
  %374 = getelementptr inbounds [64 x float]* @param0, i64 0, i64 62
  %375 = load volatile float* %374, align 4
  %376 = fmul float %373, %375
  %377 = getelementptr inbounds [64 x float]* @temp0, i64 0, i64 62
  store volatile float %376, float* %377, align 4
  %378 = getelementptr inbounds [64 x float]* @param1, i64 0, i64 63
  %379 = load volatile float* %378, align 4
  %380 = getelementptr inbounds [64 x float]* @param0, i64 0, i64 63
  %381 = load volatile float* %380, align 4
  %382 = fmul float %379, %381
  %383 = getelementptr inbounds [64 x float]* @temp0, i64 0, i64 63
  store volatile float %382, float* %383, align 4
  %leflow_gep = getelementptr inbounds [64 x float]* @temp0, i64 0, i64 0
  %leflow_retval = load volatile float* %leflow_gep, align 4
  ret float %leflow_retval
}

attributes #0 = { "no-frame-pointer-elim"="false" }
