package com.theoriongd.lifevault

import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity : FlutterFragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Privacy Defense: Hide vault screens and sensitive documents from App Switcher / Recents preview
        window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
    }
}
