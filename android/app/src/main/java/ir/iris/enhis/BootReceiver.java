package ir.iris.enhis;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

import io.flutter.embedding.engine.loader.FlutterLoader;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.dart.DartExecutor;
import io.flutter.embedding.engine.dart.DartExecutor.DartCallback;
import io.flutter.embedding.engine.dart.DartExecutor.DartEntrypoint;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.view.FlutterCallbackInformation;
import android.os.Looper;
import android.os.Handler;
import io.flutter.plugins.GeneratedPluginRegistrant;

//import io.flutter.embedding.engine.FlutterJNI;
//import io.flutter.view.FlutterNativeView;
//import io.flutter.view.FlutterRunArguments;
//import io.flutter.view.FlutterMain;

//https://github.com/firebase/flutterfire/blob/master/packages/firebase_messaging/firebase_messaging/android/src/main/java/io/flutter/plugins/firebase/messaging/FlutterFirebaseMessagingBackgroundExecutor.java

public class BootReceiver extends BroadcastReceiver {
    @Override
    public void onReceive(Context context, Intent intent) {
        //run(context);
    }
}
