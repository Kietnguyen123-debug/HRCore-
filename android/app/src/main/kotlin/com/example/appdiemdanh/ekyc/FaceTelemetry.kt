package com.example.appdiemdanh.ekyc

/**
 * Đóng gói dữ liệu khuôn mặt mỏng nhẹ để gửi qua EventChannel
 * Tất cả kiểu dữ liệu số thực được chuyển thành Double để tương thích hoàn toàn với StandardMessageCodec của Flutter, tránh văng app.
 */
data class FaceTelemetry(
    val id: Int?,
    val rect: Map<String, Float>,
    val pose: Map<String, Float>,
    val prob: Map<String, Float>,
    val contours: Map<String, List<List<Float>>>,
    val progress: Float = 0f,
    val faceCount: Int = 1
) {
    fun toMap(): Map<String, Any?> = mapOf(
        "id" to id,
        "rect" to rect.mapValues { it.value.toDouble() },
        "pose" to pose.mapValues { it.value.toDouble() },
        "prob" to prob.mapValues { it.value.toDouble() },
        "contours" to contours.mapValues { entry ->
            entry.value.map { point -> point.map { it.toDouble() } }
        },
        "progress" to progress.toDouble(),
        "faceCount" to faceCount
    )
}
