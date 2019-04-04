Star[] stars = new Star[100];

import java.util.Map;

import controlP5.*;

import cvc.CVClient;
import cvc.events.TrackingEvent;
import cvc.blobs.TrackingBlob;


CVClient cvc;

float getXSpeed;

boolean CVC_DEBUG_RENDER = true;

int drawing_mode = 0; 

PImage cat_img;
PImage dog_img;

void setup() {
  
    size(1280, 400, P3D);
    
    cvc = new CVClient(this);
    
    cvc.setMinimalLogging(); // Dont show so much in the console
     
    cvc.init(); // initialise CVC
    
    cvc.registerEvents(this); // register for the blob tracking events, your code must have methods updateTrackingBlobs & removeTrackingBlobs 
    
    // Setup VideoTracker server connection and connect
    cvc.setTrackingServer("192.168.1.118", 11002); // ip, port
    
    cvc.showControlPanel(10, height-165);
    
    cat_img = loadImage("cat-head.png");
    dog_img = loadImage("dog-head.png");
     cat_img = loadImage ("cat-head.png");
 for (int i = 1; i < stars.length; i++) {
     stars[i] = new Star();
 }
    
}

void draw() {
  getXSpeed =map(mouseX, 0, width, 0, 40);
  background(0);
  fill(0, 3);
  rect(0, 0, width, height);
  
  for (int i = 1; i < stars.length; i++) {
    stars[i].update();
    stars[i].appear();
  
}

    
    if(CVC_DEBUG_RENDER) { 
      cvc.drawImage(5, 5, 160, 120, true); // debug show copy of the image
    }
    
    cvc.update();

    if(CVC_DEBUG_RENDER) {
      cvc.render(0,0); // render the debug graphics
    }
    

}

void updateTrackingBlobs(TrackingEvent event) {
  
  pushStyle();
 
  
  // Loop through all the Tracking blobs found in event.update_blobs
  
  for(Map.Entry<Integer,TrackingBlob> entry : event.updated_blobs.entrySet()) {  // This is how we loop thru a ConcurrentHashMap (which CVC uses to be thread safe)
    
    TrackingBlob blob = entry.getValue(); // See notes below on methods to access TrackingBlob    
    
    if(drawing_mode == 0) { 
      
      // Make a cicle the same area as our blob at the centroid position
      
      float radius = PApplet.sqrt( blob.getArea() / PApplet.PI ); // A/π = r2
      ellipse( blob.getPos().x, blob.getPos().y, radius*2, radius*2 );
    
    }else if(drawing_mode == 1 || drawing_mode == 2) {
      
      // Draw a cat or dog
      
      boolean draw_cat = blob.getID() % 2 == 0; // Draw cats on even number ids and dogs on odd
      
      PImage img = draw_cat ? cat_img : dog_img;
      
      if(drawing_mode == 1) { 
    
        // draw it in the centroid of the blob
        imageMode(CENTER);
        image(img, blob.getPos().x, blob.getPos().y);
      
    }else{ 
        
        // draw it stretched to the rect of the blob
        image(img, blob.getRect().x, blob.getRect().y, blob.getRect().width, blob.getRect().height);
      
    }
      
    }
    
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
  
  if(key == ' ') {  // SPACE. Advance the mode
    if(++drawing_mode > 2) drawing_mode = 0;
  }
  
}

/*

  Useful public methods of the cvc.blobs.TrackingBlob class
  
  RectangleF getRect() // bounding box of blob
  float getArea() // of rect
  
  PVector getPos() // location of centroid
  PVector getDecPos() // a normalised position vector 0..1  
  
  int getID()
  
  boolean hasOutlines()
  float[] getOutlines() // array of [x,y,x,y,x,y...] coordinates  
  int getOutlinesCount()  
  
  long getAge(){ // how old in milliseconds this blob is  
  long getStagnation(){ // how long it has been still
  
  float getXSpeed() // X velocity
  float getYSpeed() // the Y velocity
  float getMotionSpeed()
  float getMotionAccel()
   
  boolean isMoving()
    
  int getState() // possible values: TracingBlob.ADDED, TracingBlob.ACCELERATING, TracingBlob.DECELERATING, TracingBlob.STOPPED, TracingBlob.REMOVED

  String getStateString() // small readable version of the state: 
  
*/
