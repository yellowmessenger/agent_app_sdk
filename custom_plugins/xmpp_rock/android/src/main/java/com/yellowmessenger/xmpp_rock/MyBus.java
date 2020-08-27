package com.yellowmessenger.xmpp_rock;

public class MyBus {

    private final RxBus bus;

    private static MyBus myBusInstance;
    private MyBus(){bus = new RxBus();}

    public static MyBus getInstance(){
        if(myBusInstance == null){
            myBusInstance = new MyBus();
        }
        return myBusInstance;
    }
    public RxBus bus() {
        return bus;
    }

}