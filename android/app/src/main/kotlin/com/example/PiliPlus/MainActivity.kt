package com.example.piliplusx

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.ryanheise.audioservice.AudioServiceActivity
import android.content.ComponentName
import android.content.Intent
import android.content.res.Configuration
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import android.view.WindowManager.LayoutParams
import kotlin.system.exitProcess

class MainActivity : AudioServiceActivity() {
    private lateinit var methodChannel: MethodChannel

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "PiliPlus")
        methodChannel.setMethodCallHandler { call, result ->
            if (call.method == "back") {
                back()
            } else if (call.method == "biliSendCommAntifraud") {
                try {
                    val action = call.argument<Int>("action") ?: 0
                    val oid = call.argument<Number>("oid") ?: 0L
                    val type = call.argument<Int>("type") ?: 0
                    val rpid = call.argument<Number>("rpid") ?: 0L
                    val root = call.argument<Number>("root") ?: 0L
                    val parent = call.argument<Number>("parent") ?: 0L
                    val ctime = call.argument<Number>("ctime") ?: 0L
                    val commentText = call.argument<String>("comment_text") ?: ""
                    val pictures = call.argument<String?>("pictures")
                    val sourceId = call.argument<String>("source_id") ?: ""
                    val uid = call.argument<Number>("uid") ?: 0L
                    val cookies = call.argument<List<String>>("cookies") ?: emptyList<String>()

                    val intent = Intent().apply {
                        component = ComponentName("icu.freedomIntrovert.biliSendCommAntifraud", "icu.freedomIntrovert.biliSendCommAntifraud.ByXposedLaunchedActivity")
                        putExtra("action", action)
                        putExtra("oid", oid.toLong())
                        putExtra("type", type)
                        putExtra("rpid", rpid.toLong())
                        putExtra("root", root.toLong())
                        putExtra("parent", parent.toLong())
                        putExtra("ctime", ctime.toLong())
                        putExtra("comment_text", commentText)
                        if(pictures != null)
                            putExtra("pictures", pictures)
                        putExtra("source_id", sourceId)
                        putExtra("uid", uid.toLong())
                        putStringArrayListExtra("cookies", ArrayList(cookies))
                    }
                    startActivity(intent)
                } catch (e: Exception) {}
            } else if (call.method == "linkVerifySettings") {
                try {
                    val intent = Intent(android.provider.Settings.ACTION_APP_OPEN_BY_DEFAULT_SETTINGS,
                        Uri.parse("package:" + context.packageName))
                    context.startActivity(intent)
                } catch (t: Throwable) {
                    try {
                        val intent = Intent("android.intent.action.MAIN", Uri.parse("package:" + context.packageName))
                        intent.setClassName("com.android.settings", "com.android.settings.applications.InstalledAppOpenByDefaultActivity")
                        context.startActivity(intent)
                    } catch (t2: Throwable) {
                        val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
                            Uri.parse("package:" + context.packageName))
                        context.startActivity(intent)
                    }
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun back() {
        val intent = Intent(Intent.ACTION_MAIN).apply {
            addCategory(Intent.CATEGORY_HOME)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
        }
        startActivity(intent)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            window.attributes.layoutInDisplayCutoutMode =
                LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        android.os.Process.killProcess(android.os.Process.myPid())
        exitProcess(0)
    }

    override fun onUserLeaveHint() {
        super.onUserLeaveHint()
        methodChannel.invokeMethod("onUserLeaveHint", null)
    }

    override fun onPictureInPictureModeChanged(isInPictureInPictureMode: Boolean, newConfig: Configuration?) {
        super.onPictureInPictureModeChanged(isInPictureInPictureMode, newConfig)
        MethodChannel(
            flutterEngine!!.getDartExecutor()!!.getBinaryMessenger(),
            "floating"
        ).invokeMethod("onPipChanged", isInPictureInPictureMode)
    }
}
