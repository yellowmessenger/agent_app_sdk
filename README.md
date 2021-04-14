# Agent App SDK Integration 

## Step 1
Download and unzip the local maven repo from the following link.
https://github.com/yellowmessenger/agent_app_sdk/blob/master/repo_v1.0.16.zip

## Step 2 
Consuming the Module  
1. Open \<host>/app/build.gradle 
2. Ensure you have the repositories configured, otherwise add them:   
```gradle
    repositories {        
        maven {           
    	     url 'PATH-TO-THE-LOCAL-REPO'       
         }        
        maven {            
    	    url 'https://storage.googleapis.com/download.flutter.io'        
        }      
    }
```
  
3. Make the host app depend on the Flutter module:    
``` gradle
dependencies {          
implementation 'com.yellowmessenger.agent_app_flutter_sdk:flutter_release:1.0'    
}  
```
4. Add the `profile` build type:   
``` gradle 
android {      
    buildTypes {        
        profile {          
            initWith debug        
        }     
    }   
 }
 ```

## Step 3 
In **MainActivity.java** file add the following inside onCreateMethod
``` java
public class MainActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        Toolbar toolbar = findViewById(R.id.toolbar);
        setSupportActionBar(toolbar);

        FloatingActionButton fab = findViewById(R.id.fab);
        
        //Initialising the SDK (Should be called when the app starts to initiate the login flow in SDK)
        YMAgent.initialize(this);
        
         //Setting notification handler
        YMAgent.setNotificationCallback((HashMap<String, Object> payLoadData) -> {
            Log.d("New message", "This is a local notification from ticketId: " + payLoadData.get("ticketId").toString());
        });

        fab.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
            
//               YMAgent.setTicketId("102565"); // Setting ticket ID to open Chat page directly.
                //Starting Agent SDK.
                YMAgent.showChatView();

            }
        });
    }
...
...
}
```

## Step 4
Create a java class **FlutterViewActivity**
``` java
package com.rara.delivery.dev;


import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.function.Function;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.FlutterEngineCache;
import io.flutter.embedding.engine.dart.DartExecutor;
import io.flutter.plugin.common.MethodChannel;

public class FlutterViewActivity extends FlutterActivity {
    private static final String CHANNEL = "com.yellowmessenger.support_agent/data";
    public static String ticketId;
    public static Function notificationCallBack;
    public static boolean initializing = false;

    @Override
    public FlutterEngine provideFlutterEngine(Context context) {
        return FlutterEngineCache.getInstance().get("ym_partner_sdk");
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {

        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL).setMethodCallHandler(
                (call, result) -> {
                    if (call.method.equals("getConfig")) {
                        JSONObject json = new JSONObject();
                        try {
                            json.put("username", "{{USERNAME}}");
                            json.put("password", "{{PASSWORD}}");
                            json.put("botId", "{{BOT-ID}");
                        } catch (JSONException e) {
                            e.printStackTrace();
                        }
                        result.success(json.toString());
                    } else if (call.method.equals("close-module")) {
                        initializing = false;
                        this.finish();
                    } else if (call.method.equals("send-notification")) {
                        Log.d("Local Notification", "This is a local notification ");
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                            notificationCallBack.apply(call.argument("payload"));
                        }

                    } else if (call.method.equals("getCurrentTicket")) {
                        result.success(FlutterViewActivity.ticketId);
                    } else if (call.method.equals("setCurrentTicket")) {
                        FlutterViewActivity.ticketId = null;
                        result.success(true);
                    } else if (call.method.equals("isInitializeSDK")) {
                        result.success(FlutterViewActivity.initializing);
                    } else {
                        result.notImplemented();
                    }
                }
        );
    }


}

class YMAgent {
    
    static Context context;
    FlutterEngine flutterEngine;

    private YMAgent(Context ctx) {
        // Instantiate a FlutterEngine.
        flutterEngine = new FlutterEngine(ctx);
        // Start executing Dart code to pre-warm the FlutterEngine.
        flutterEngine.getDartExecutor().executeDartEntrypoint(
                DartExecutor.DartEntrypoint.createDefault()
        );
        // Cache the FlutterEngine to be used by FlutterActivity.
        FlutterEngineCache
                .getInstance()
                .put("ym_partner_sdk", flutterEngine);
        context = ctx;
    }


    public static boolean setTicketId(String ticketId) {
        FlutterViewActivity.ticketId = ticketId;
        return true;
    }

    public static boolean initialize(Context ctx) {
        new YMAgent(ctx);
        FlutterViewActivity.initializing = true;

        Intent flutterIntent;
        flutterIntent = new Intent(context, FlutterViewActivity.class);
        context.startActivity(flutterIntent);
        return true;
    }

    public static boolean showChatView() {
        FlutterViewActivity.initializing = false;
        Intent flutterIntent;
        flutterIntent = new Intent(context, FlutterViewActivity.class);
        context.startActivity(flutterIntent);
        return true;
    }


    @RequiresApi(api = Build.VERSION_CODES.N)
    public static void setNotificationCallback(Function<HashMap<String, Object>, Boolean> callBack) {
        FlutterViewActivity.notificationCallBack = callBack;
    }
}
```

## Step 5
Add the following activity inside application in **AndroidManifest.xml** file.
``` xml
    <activity
            android:name=".FlutterViewActivity"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:theme="@style/AppTheme.NoActionBar"
            android:windowSoftInputMode="adjustResize">
            <intent-filter>
                <action android:name="FLUTTER_NOTIFICATION_CLICK" />
                <category android:name="android.intent.category.DEFAULT" />
            </intent-filter>
     </activity>
```
