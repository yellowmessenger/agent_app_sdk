# Agent App SDK Integration 

## Step 1
Download and unzip the local maven repo from the following link.
https://github.com/yellowmessenger/agent_app_sdk/blob/master/repo_v1.0.0.zip

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
debugImplementation 'com.yellowmessenger.agent_app_flutter_sdk:flutter_debug:1.0'      
profileImplementation 'com.yellowmessenger.agent_app_flutter_sdk:flutter_profile:1.0'      
releaseImplementation 'com.yellowmessenger.agent_app_flutter_sdk:flutter_release:1.0'    
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
        // Instantiate a FlutterEngine.
        FlutterEngine flutterEngine = new FlutterEngine(this);

        // Start executing Dart code to pre-warm the FlutterEngine.
        flutterEngine.getDartExecutor().executeDartEntrypoint(
                DartExecutor.DartEntrypoint.createDefault()
        );

        // Cache the FlutterEngine to be used by FlutterActivity.
        FlutterEngineCache
                .getInstance()
                .put("my_engine_id", flutterEngine);

        fab.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                FlutterViewActivity.setTicketId("<Ticket-ID>"); // to open chat page directly set ticket id 
                Intent flutterIntent;
                flutterIntent = new Intent(MainActivity.this, FlutterViewActivity.class);
                startActivity(flutterIntent);
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
package com.yellowmessenger.agentappsdk;


import android.content.Context;
import android.os.Bundle;
import android.util.Log;

import androidx.annotation.NonNull;

import org.json.JSONException;
import org.json.JSONObject;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.FlutterEngineCache;

import io.flutter.plugin.common.MethodChannel;



public class FlutterViewActivity extends FlutterActivity {
    private static final String CHANNEL = "com.yellowmessenger.support_agent/data";
    public static String ticketId;

    @Override
    public FlutterEngine provideFlutterEngine(Context context) {
        return FlutterEngineCache.getInstance().get("my_engine_id");
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
                json.put("username", "priyank@yellowmessenger.com");
                json.put("password", "P@$$9333172315");
                json.put("botId", "x1553936559750");
            } catch (JSONException e) {
                e.printStackTrace();
            }
            result.success(json.toString());
        } else if (call.method.equals("close-module")) {
                        this.finish();
                    }
          else if (call.method.equals("getCurrentTicket")) {
                        result.success(FlutterViewActivity.ticketId);
                    }
          else if (call.method.equals("setCurrentTicket")) {
                        FlutterViewActivity.ticketId = null;
                        result.success(true);
                    }
        else {
            result.notImplemented();
        }
                }
        );
    }

    public static boolean setTicketId (String ticketId){
        FlutterViewActivity.ticketId = ticketId;
        return true;
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
