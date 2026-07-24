package com.astratechnologies.mewtionary_teacher3d

import android.content.Context
import android.graphics.Color
import android.view.Gravity
import android.view.View
import android.widget.FrameLayout
import android.widget.TextView
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import io.flutter.plugin.common.StandardMessageCodec

class MewtionaryTeacher3DPlugin :
    FlutterPlugin,
    MethodChannel.MethodCallHandler {

    private lateinit var channel: MethodChannel

    override fun onAttachedToEngine(
        binding: FlutterPlugin.FlutterPluginBinding
    ) {
        channel = MethodChannel(
            binding.binaryMessenger,
            "mewtionary/teacher3d"
        )
        channel.setMethodCallHandler(this)

        binding.platformViewRegistry.registerViewFactory(
            "mewtionary/teacher3d_view",
            Teacher3DViewFactory()
        )
    }

    override fun onMethodCall(
        call: MethodCall,
        result: MethodChannel.Result
    ) {
        when (call.method) {
            "isUnityAvailable" -> {
                result.success(UnityReflection.isAvailable())
            }

            "bridgeInfo" -> {
                result.success(
                    mapOf(
                        "pluginVersion" to "2.2.0",
                        "unityAvailable" to UnityReflection.isAvailable(),
                        "platformView" to "mewtionary/teacher3d_view",
                        "transport" to "reflection_UnitySendMessage"
                    )
                )
            }

            "unitySendMessage" -> {
                val gameObject = call.argument<String>("gameObject")
                val method = call.argument<String>("method")
                val message = call.argument<String>("message") ?: ""

                if (gameObject.isNullOrBlank() || method.isNullOrBlank()) {
                    result.error(
                        "INVALID_ARGUMENTS",
                        "gameObject and method are required.",
                        null
                    )
                    return
                }

                try {
                    UnityReflection.sendMessage(
                        gameObject,
                        method,
                        message
                    )
                    result.success(true)
                } catch (error: Throwable) {
                    result.error(
                        "UNITY_SEND_FAILED",
                        error.message,
                        error.stackTraceToString()
                    )
                }
            }

            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(
        binding: FlutterPlugin.FlutterPluginBinding
    ) {
        channel.setMethodCallHandler(null)
    }
}

private object UnityReflection {
    private const val unityPlayerClass =
        "com.unity3d.player.UnityPlayer"

    fun isAvailable(): Boolean {
        return try {
            Class.forName(unityPlayerClass)
            true
        } catch (_: Throwable) {
            false
        }
    }

    fun sendMessage(
        gameObject: String,
        method: String,
        message: String
    ) {
        val player = Class.forName(unityPlayerClass)
        val unitySendMessage = player.getMethod(
            "UnitySendMessage",
            String::class.java,
            String::class.java,
            String::class.java
        )
        unitySendMessage.invoke(
            null,
            gameObject,
            method,
            message
        )
    }

    fun createPlayerView(context: Context): View? {
        return try {
            val playerClass = Class.forName(unityPlayerClass)
            val constructor = playerClass.constructors.firstOrNull {
                val parameters = it.parameterTypes
                parameters.size == 1 &&
                    Context::class.java.isAssignableFrom(parameters[0])
            } ?: return null

            val player = constructor.newInstance(context)
            when (player) {
                is View -> player
                else -> {
                    val getView = playerClass.methods.firstOrNull {
                        it.name == "getView" &&
                            it.parameterTypes.isEmpty()
                    }
                    getView?.invoke(player) as? View
                }
            }
        } catch (_: Throwable) {
            null
        }
    }
}

private class Teacher3DViewFactory :
    PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    override fun create(
        context: Context,
        viewId: Int,
        args: Any?
    ): PlatformView {
        return Teacher3DPlatformView(context)
    }
}

private class Teacher3DPlatformView(
    context: Context
) : PlatformView {

    private val root = FrameLayout(context)

    init {
        root.setBackgroundColor(Color.rgb(190, 228, 234))

        val unityView = UnityReflection.createPlayerView(context)
        if (unityView != null) {
            root.addView(
                unityView,
                FrameLayout.LayoutParams(
                    FrameLayout.LayoutParams.MATCH_PARENT,
                    FrameLayout.LayoutParams.MATCH_PARENT
                )
            )
        } else {
            val fallback = TextView(context).apply {
                text = "Unity 3D Teacher library is not embedded.\n" +
                    "The app is running in safe fallback mode."
                gravity = Gravity.CENTER
                textSize = 16f
                setTextColor(Color.rgb(23, 57, 92))
                setPadding(32, 32, 32, 32)
            }
            root.addView(
                fallback,
                FrameLayout.LayoutParams(
                    FrameLayout.LayoutParams.MATCH_PARENT,
                    FrameLayout.LayoutParams.MATCH_PARENT
                )
            )
        }
    }

    override fun getView(): View = root

    override fun dispose() {
        root.removeAllViews()
    }
}
