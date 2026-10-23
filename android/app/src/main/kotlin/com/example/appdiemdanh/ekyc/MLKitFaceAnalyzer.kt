package com.example.appdiemdanh.ekyc

import android.annotation.SuppressLint
import android.graphics.*
import android.os.SystemClock
import android.util.Base64
import android.util.Log
import androidx.camera.core.ImageAnalysis
import androidx.camera.core.ImageProxy
import com.google.mlkit.vision.common.InputImage
import com.google.mlkit.vision.face.*
import java.io.ByteArrayOutputStream

class MLKitFaceAnalyzer(
    private val onTelemetry: (FaceTelemetry) -> Unit,
    private val onBestFrame: (String) -> Unit
) : ImageAnalysis.Analyzer {

    private val detector: FaceDetector by lazy {
        val options = FaceDetectorOptions.Builder()
            .setPerformanceMode(FaceDetectorOptions.PERFORMANCE_MODE_FAST)
            .setLandmarkMode(FaceDetectorOptions.LANDMARK_MODE_ALL)
            .setClassificationMode(FaceDetectorOptions.CLASSIFICATION_MODE_ALL)
            .setContourMode(FaceDetectorOptions.CONTOUR_MODE_ALL)
            .enableTracking()
            .build()
        FaceDetection.getClient(options)
    }

    private var lastInferenceTime = 0L
    private val inferenceInterval = 50L // ~20 FPS cho trải nghiệm mượt mà
    @Volatile private var isFinalFrameCaptured = false

    // Giữ khuôn mặt 2.0 giây (2000ms) kết hợp grace period 350ms chống giật/chớp mắt
    private var validHoldStartTime = 0L
    private var lastValidTime = 0L
    private val REQUIRED_HOLD_DURATION_MS = 2000L
    private val GRACE_PERIOD_MS = 350L

    @SuppressLint("UnsafeOptInUsageError")
    override fun analyze(imageProxy: ImageProxy) {
        val currentTime = SystemClock.elapsedRealtime()

        if (isFinalFrameCaptured || currentTime - lastInferenceTime < inferenceInterval) {
            imageProxy.close()
            return
        }

        val mediaImage = imageProxy.image
        if (mediaImage == null) {
            imageProxy.close()
            return
        }

        val rotationDegrees = imageProxy.imageInfo.rotationDegrees
        val image = InputImage.fromMediaImage(mediaImage, rotationDegrees)

        detector.process(image)
            .addOnSuccessListener { faces ->
                lastInferenceTime = SystemClock.elapsedRealtime()

                // YÊU CẦU: Kiểm tra số lượng khuôn mặt
                if (faces.size == 1 && !isFinalFrameCaptured) {
                    val face = faces[0]

                    // 1. Phân tích điều kiện & tính tiến trình (progress 0.0 - 1.0)
                    val progress = checkFaceValidAndGetProgress(face, imageProxy)

                    // 2. Trích xuất Telemetry cho Flutter
                    val telemetry = extractTelemetry(face, imageProxy, progress, faceCount = 1)
                    onTelemetry(telemetry)

                    // 3. Chụp và CROP Best Face khi giữ đủ 2.0s
                    if (progress >= 1.0f && !isFinalFrameCaptured) {
                        captureCroppedBestFrame(face, imageProxy)
                    }
                } else if (faces.size > 1) {
                    // Phát hiện nhiều hơn 1 mặt -> Báo lỗi trên UI
                    validHoldStartTime = 0L
                    lastValidTime = 0L
                    val telemetry = FaceTelemetry(
                        id = null,
                        rect = emptyMap(),
                        pose = emptyMap(),
                        prob = emptyMap(),
                        contours = emptyMap(),
                        progress = 0f,
                        faceCount = faces.size
                    )
                    onTelemetry(telemetry)
                } else {
                    // Không tìm thấy mặt (0 mặt)
                    validHoldStartTime = 0L
                    lastValidTime = 0L
                    val telemetry = FaceTelemetry(
                        id = null,
                        rect = emptyMap(),
                        pose = emptyMap(),
                        prob = emptyMap(),
                        contours = emptyMap(),
                        progress = 0f,
                        faceCount = 0
                    )
                    onTelemetry(telemetry)
                }
            }
            .addOnFailureListener { e ->
                validHoldStartTime = 0L
                lastValidTime = 0L
                Log.e("MLKitAnalyzer", "Lỗi phân tích AI: ${e.message}")
            }
            .addOnCompleteListener {
                imageProxy.close()
            }
    }

    private fun extractTelemetry(face: Face, proxy: ImageProxy, progress: Float, faceCount: Int): FaceTelemetry {
        val isRotated = proxy.imageInfo.rotationDegrees == 90 || proxy.imageInfo.rotationDegrees == 270
        val frameW = if (isRotated) proxy.height.toFloat() else proxy.width.toFloat()
        val frameH = if (isRotated) proxy.width.toFloat() else proxy.height.toFloat()

        return FaceTelemetry(
            id = face.trackingId,
            rect = mapOf(
                "l" to face.boundingBox.left / frameW,
                "t" to face.boundingBox.top / frameH,
                "r" to face.boundingBox.right / frameW,
                "b" to face.boundingBox.bottom / frameH
            ),
            pose = mapOf(
                "x" to face.headEulerAngleX,
                "y" to face.headEulerAngleY,
                "z" to face.headEulerAngleZ
            ),
            prob = mapOf(
                "smile" to (face.smilingProbability ?: 0f),
                "lEye" to (face.leftEyeOpenProbability ?: 1f),
                "rEye" to (face.rightEyeOpenProbability ?: 1f)
            ),
            contours = face.allContours.associate { c ->
                "c_${c.faceContourType}" to c.points.map { listOf(it.x / frameW, it.y / frameH) }
            },
            progress = progress,
            faceCount = faceCount
        )
    }

    private fun checkFaceValidAndGetProgress(face: Face, proxy: ImageProxy): Float {
        // Góc nghiêng/quay mặt linh hoạt (15 độ)
        val isStraight = Math.abs(face.headEulerAngleY) < 15.0 &&
                         Math.abs(face.headEulerAngleX) < 15.0 &&
                         Math.abs(face.headEulerAngleZ) < 15.0

        val lEye = face.leftEyeOpenProbability ?: 1f
        val rEye = face.rightEyeOpenProbability ?: 1f
        val eyesOpen = lEye >= 0.35f && rEye >= 0.35f

        val isRotated = proxy.imageInfo.rotationDegrees == 90 || proxy.imageInfo.rotationDegrees == 270
        val frameW = if (isRotated) proxy.height.toFloat() else proxy.width.toFloat()
        val frameH = if (isRotated) proxy.width.toFloat() else proxy.height.toFloat()

        val l = face.boundingBox.left / frameW
        val t = face.boundingBox.top / frameH
        val r = face.boundingBox.right / frameW
        val b = face.boundingBox.bottom / frameH

        val faceWidth = Math.abs(r - l)
        val faceHeight = Math.abs(b - t)
        val faceCenterX = (l + r) / 2f
        val faceCenterY = (t + b) / 2f

        val isCentered = faceCenterX in 0.20f..0.80f &&
                         faceCenterY in 0.15f..0.80f &&
                         faceWidth in 0.20f..0.85f &&
                         faceHeight in 0.22f..0.90f

        val isValid = isStraight && eyesOpen && isCentered
        val now = SystemClock.elapsedRealtime()

        if (isValid) {
            if (validHoldStartTime == 0L) {
                validHoldStartTime = now
            }
            lastValidTime = now

            val elapsed = now - validHoldStartTime
            return (elapsed.toFloat() / REQUIRED_HOLD_DURATION_MS).coerceIn(0f, 1f)
        } else {
            // Grace period: Nếu mất valid dưới 350ms thì giữ progress
            if (validHoldStartTime != 0L && (now - lastValidTime) < GRACE_PERIOD_MS) {
                val elapsed = lastValidTime - validHoldStartTime
                return (elapsed.toFloat() / REQUIRED_HOLD_DURATION_MS).coerceIn(0f, 1f)
            } else {
                validHoldStartTime = 0L
                lastValidTime = 0L
                return 0f
            }
        }
    }

    /**
     * QUY TRÌNH CROP VÙNG MẶT (CROP FACE) TRƯỚC KHI GỬI API:
     * 1. Lấy bounding box của khuôn mặt.
     * 2. Mở rộng biên (padding) khoảng 18% xung quanh để lấy trọn trán, cằm và 2 tai.
     * 3. Cắt (Crop) chính xác vùng chữ nhật khuôn mặt từ ảnh gốc.
     * 4. Xoay và lật (mirror) vùng mặt đã crop, nén JPEG và chuyển sang Base64 gửi lên Backend C#.
     */
    private fun captureCroppedBestFrame(face: Face, proxy: ImageProxy) {
        isFinalFrameCaptured = true
        try {
            val nv21 = yuv420ToNv21Safe(proxy)
            val yuvImage = YuvImage(nv21, ImageFormat.NV21, proxy.width, proxy.height, null)
            val out = ByteArrayOutputStream()
            yuvImage.compressToJpeg(Rect(0, 0, proxy.width, proxy.height), 85, out)
            val imageBytes = out.toByteArray()

            val originalBitmap = BitmapFactory.decodeByteArray(imageBytes, 0, imageBytes.size)
                ?: run {
                    isFinalFrameCaptured = false
                    return
                }

            // Lấy Bounding Box của khuôn mặt từ ML Kit
            val box = face.boundingBox
            val w = box.width()
            val h = box.height()

            // Mở rộng lề (padding) 18% để lấy trọn vẹn trán, cằm, hai tai (tránh bị cắt cụt)
            val padX = (w * 0.18f).toInt()
            val padY = (h * 0.18f).toInt()

            val cropLeft = (box.left - padX).coerceAtLeast(0)
            val cropTop = (box.top - padY).coerceAtLeast(0)
            val cropRight = (box.right + padX).coerceAtMost(originalBitmap.width)
            val cropBottom = (box.bottom + padY).coerceAtMost(originalBitmap.height)

            val cropWidth = cropRight - cropLeft
            val cropHeight = cropBottom - cropTop

            if (cropWidth <= 0 || cropHeight <= 0) {
                originalBitmap.recycle()
                isFinalFrameCaptured = false
                return
            }

            // 1. CẮT (CROP) DUY NHẤT VÙNG MẶT TỪ ẢNH GỐC
            val croppedFaceBitmap = Bitmap.createBitmap(
                originalBitmap, cropLeft, cropTop, cropWidth, cropHeight
            )

            // 2. XOAY VÀ LẬT (MIRROR) CHO CAMERA TRƯỚC
            val matrix = Matrix()
            matrix.postRotate(proxy.imageInfo.rotationDegrees.toFloat())
            matrix.postScale(-1f, 1f, cropWidth / 2f, cropHeight / 2f)

            val finalFaceBitmap = Bitmap.createBitmap(
                croppedFaceBitmap, 0, 0, cropWidth, cropHeight, matrix, true
            )

            if (finalFaceBitmap != croppedFaceBitmap) {
                croppedFaceBitmap.recycle()
            }
            if (originalBitmap != finalFaceBitmap) {
                originalBitmap.recycle()
            }

            // 3. NÉN JPEG VÀ CHUYỂN ĐỔI SANG BASE64
            val finalOut = ByteArrayOutputStream()
            finalFaceBitmap.compress(Bitmap.CompressFormat.JPEG, 85, finalOut)
            val base64 = Base64.encodeToString(finalOut.toByteArray(), Base64.NO_WRAP)

            finalFaceBitmap.recycle()
            onBestFrame(base64)
        } catch (e: Exception) {
            isFinalFrameCaptured = false
            Log.e("MLKitAnalyzer", "Lỗi Crop & nén ảnh BestFrame: ${e.message}")
        }
    }

    private fun yuv420ToNv21Safe(image: ImageProxy): ByteArray {
        val width = image.width
        val height = image.height
        val yPlane = image.planes[0]
        val uPlane = image.planes[1]
        val vPlane = image.planes[2]

        val yBuffer = yPlane.buffer
        val uBuffer = uPlane.buffer
        val vBuffer = vPlane.buffer

        val ySize = yBuffer.remaining()
        val nv21 = ByteArray(width * height * 3 / 2)

        yBuffer.get(nv21, 0, ySize)

        val vRowStride = vPlane.rowStride
        val vPixelStride = vPlane.pixelStride
        val uRowStride = uPlane.rowStride
        val uPixelStride = uPlane.pixelStride

        var nv21Index = ySize
        val uvHeight = height / 2
        val uvWidth = width / 2

        val vBufferPos = vBuffer.position()
        val uBufferPos = uBuffer.position()

        for (row in 0 until uvHeight) {
            for (col in 0 until uvWidth) {
                val vIndex = row * vRowStride + col * vPixelStride
                val uIndex = row * uRowStride + col * uPixelStride

                nv21[nv21Index++] = vBuffer.get(vBufferPos + vIndex)
                nv21[nv21Index++] = uBuffer.get(uBufferPos + uIndex)
            }
        }
        return nv21
    }

    fun stop() {
        try {
            detector.close()
        } catch (e: Exception) {
            Log.e("MLKitAnalyzer", "Lỗi đóng FaceDetector: ${e.message}")
        }
    }
}
