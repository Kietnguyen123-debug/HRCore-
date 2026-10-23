package com.example.appdiemdanh.ekyc

import android.content.Context
import android.util.Log
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import androidx.camera.core.AspectRatio
import androidx.camera.core.CameraSelector
import androidx.camera.core.ImageAnalysis
import androidx.camera.core.Preview
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.camera.view.PreviewView
import androidx.core.content.ContextCompat
import androidx.lifecycle.LifecycleOwner
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import java.util.concurrent.Executors

class NativeCameraView(
    private val context: Context,
    private val lifecycleOwner: LifecycleOwner,
    messenger: BinaryMessenger,
    id: Int
) : PlatformView {

    private val container = FrameLayout(context)
    private val previewView: PreviewView = PreviewView(context)
    private val methodChannel = MethodChannel(messenger, "com.example.app/face_engine_$id")
    private val eventChannel = EventChannel(messenger, "com.example.app/face_telemetry_$id")
    private var eventSink: EventChannel.EventSink? = null

    private val analysisExecutor = Executors.newSingleThreadExecutor()
    private var analyzer: MLKitFaceAnalyzer? = null

    private var isDisposed = false

    init {
        previewView.implementationMode = PreviewView.ImplementationMode.COMPATIBLE
        previewView.layoutParams = FrameLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.MATCH_PARENT
        )
        container.addView(previewView)

        eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(args: Any?, sink: EventChannel.EventSink?) {
                eventSink = sink
            }
            override fun onCancel(args: Any?) {
                eventSink = null
            }
        })

        previewView.post {
            if (!isDisposed) startCamera()
        }
    }

    private fun startCamera() {
        val cameraProviderFuture = ProcessCameraProvider.getInstance(context)
        cameraProviderFuture.addListener({
            try {
                val cameraProvider = cameraProviderFuture.get()

                val preview = Preview.Builder()
                    .setTargetAspectRatio(AspectRatio.RATIO_4_3)
                    .build()
                    .also {
                        it.setSurfaceProvider(previewView.surfaceProvider)
                    }

                // Khởi tạo analyzer và lưu lại instance
                analyzer = MLKitFaceAnalyzer(
                    onTelemetry = { telemetry ->
                        previewView.post { eventSink?.success(telemetry.toMap()) }
                    },
                    onBestFrame = { base64 ->
                        previewView.post { methodChannel.invokeMethod("onCaptured", base64) }
                    }
                )

                val imageAnalysis = ImageAnalysis.Builder()
                    .setBackpressureStrategy(ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
                    .setTargetAspectRatio(AspectRatio.RATIO_4_3)
                    .build()
                    .also { it.setAnalyzer(analysisExecutor, analyzer!!) }

                val cameraSelector = CameraSelector.DEFAULT_FRONT_CAMERA

                cameraProvider.unbindAll()
                cameraProvider.bindToLifecycle(
                    lifecycleOwner,
                    cameraSelector,
                    preview,
                    imageAnalysis
                )
            } catch (e: Exception) {
                Log.e("NativeCamera", "Error starting camera: ${e.message}")
            }
        }, ContextCompat.getMainExecutor(context))
    }

    override fun getView(): View = container

    override fun dispose() {
        isDisposed = true
        eventSink = null

        // FIX LỖI 5: Giải phóng ML Kit FaceDetector và Executor
        analyzer?.stop()
        analysisExecutor.shutdown()

        val cameraProviderFuture = ProcessCameraProvider.getInstance(context)
        cameraProviderFuture.addListener({
            try {
                cameraProviderFuture.get().unbindAll()
            } catch (e: Exception) {
                Log.e("NativeCamera", "Error unbinding on dispose: ${e.message}")
            }
        }, ContextCompat.getMainExecutor(context))
    }
}