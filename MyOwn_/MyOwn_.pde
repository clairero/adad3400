

import java.util.Map;

import controlP5.*;

import cvc.CVClient;
import cvc.events.TrackingEvent;
import cvc.blobs.TrackingBlob;



CVClient cvc;

boolean CVC_DEBUG_RENDER = false;

void setup() {
  
      size(800, 600, P3D);
      
          cvc = new CVClient(this);
    
    cvc.setMinimalLogging(); // Dont show so much in the console
     
    cvc.init(); // initialise CVC
    
    cvc.registerEvents(this); // register for the blob tracking events, your code must have methods updateTrackingBlobs & removeTrackingBlobs 
    
    // Setup VideoTracker server connection and connect
    cvc.setTrackingServer("192.168.1.118", 11002); // ip, port
    
    cvc.showControlPanel(10, height-165);
    
    }
    
    void draw() {
    
    background(0);
    
    if(CVC_DEBUG_RENDER) { 
      // cvc.drawImage(5, 5, 160, 120, true); // debug show copy of the image
    }
    
        cvc.update();
        
         if(CVC_DEBUG_RENDER) {
      cvc.render(0,0); // render the debug graphics
        
            }
    
    // Show the current frameRate
    fill(255);
    text(frameRate, 2, 18);
}

void updateTrackingBlobs(TrackingEvent event) {
  
  pushStyle();
  fill(255);
  
    for(Map.Entry<Integer,TrackingBlob> entry : event.updated_blobs.entrySet()) {  // This is how we loop thru a ConcurrentHashMap (which CVC uses to be thread safe)
    
    TrackingBlob blob = entry.getValue(); // See notes below on methods to access TrackingBlob    
   
    float x = blob.getPos().x;
    float y = blob.getPos().y;
    
    float vscale = 14;
    float radius = 14;
    
    float px     = x;
    float py     = height - y;
    
    float  vx     = (x - blob.getPrevPos().x) * -vscale;
    float  vy     = (y - blob.getPrevPos().y) * vscale;
    
   // float vx     = random(4, x/4); 
   // float vy     = random(4, y/4);
   
    
    }
   
  
  popStyle();
  
}
  
void removeTrackingBlobs( TrackingEvent event ) {
  // event.removed_blob_ids ArrayList of ints of the ids of blobs removed.
  // You can use this to remove your own blobs if you have created some

}

void keyPressed() {
  
  // Toggle the CVC debug rendering
  if(key == 'D' || key == 'd') CVC_DEBUG_RENDER = !CVC_DEBUG_RENDER; 
  
  if(key == 'C' || key == 'c') cvc.toggleControlPanel();
  
  
}
