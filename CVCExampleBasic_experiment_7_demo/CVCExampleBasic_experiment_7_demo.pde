/*

  CVCExampleBasic
  
  Shows using CVClient (ComputerVisionClient) to connect to VideoTracker, 
  read blob data and some different ideas to render it.
  
  Dependencies: controlP5, cvc.jar (included in code folder) & bbc_utils.jar (included in code folder)
  this implementaion and the jar file dependences  are not currently openscourced
  and are owned by Brad Miller 
  and can only be used without permission for class ADAD3402 @ UNSW 2017
*/

import java.util.Map;
import controlP5.*;
import cvc.CVClient;
import cvc.events.TrackingEvent;
import cvc.blobs.TrackingBlob;
import com.thomasdiewald.pixelflow.java.DwPixelFlow;
import com.thomasdiewald.pixelflow.java.fluid.DwFluid2D;
import processing.core.*;
import processing.opengl.PGraphics2D;

CVClient cvc;



int drawing_mode = 0; // 0 = circles, 1 = cats n dogs normal, 2 = cat n dogs stretched


float my_x;
float my_y;
float getXSpeed;
float getMotionSpeed;
float getYSpeed;
// some state variables for the GUI/display
int     BACKGROUND_COLOR           = 0;
boolean UPDATE_FLUID               = true;
boolean DISPLAY_FLUID_TEXTURES     = false;
boolean DISPLAY_FLUID_VECTORS      = false; //false
int     DISPLAY_fluid_texture_mode = 2; // 1 particles only
boolean DISPLAY_PARTICLES          = true;
boolean CVC_DEBUG_RENDER           = true; // true


  
  int viewport_w = 1000;
  int viewport_h = 900; //600
  int viewport_x = 230;  //230
  int viewport_y = 0; //0
  
  int gui_w = 200;
  int gui_x = 20;
  int gui_y = 2;
  
  int fluidgrid_scale = 2; //2
  DwFluid2D fluid;
  // render targets
  PGraphics2D pg_fluid;
  //texture-buffer, for adding obstacles
  //PGraphics2D pg_obstacles;
  // custom particle system
  MyParticleSystem particles;
  

    
  public void settings() {
    
    size(viewport_w, viewport_h, P2D);
    pixelDensity(1);
    //pixelDensity(displayDensity());
    //fullScreen(P2D);
    smooth(1);
  }
  
 //particle system
  private class MyFluidData implements DwFluid2D.FluidData{
    
    // update() is called during the fluid-simulation update step.
    @Override
    public void update(DwFluid2D fluid) {
     
  }
   
}

void setup() {
    cvc = new CVClient(this);
    cvc.setMinimalLogging(); // Dont show so much in the console
    cvc.init(); // initialise CVC
    cvc.registerEvents(this); // register for the blob tracking events, your code must have methods updateTrackingBlobs & removeTrackingBlobs 
    // Setup VideoTracker server connection and connect
    cvc.setTrackingServer("192.168.1.120", 11002); // ip, port
    
    cvc.showControlPanel(10, height-165);

    
    
  
    
    
    
 //particle system   
    // main library context
    DwPixelFlow context = new DwPixelFlow(this);
    context.print();
    context.printGL();

    // fluid simulation
    fluid = new DwFluid2D(context, width, height, fluidgrid_scale);
  
    // set some simulation parameters
    //fluid.param.dissipation_density     = 0.999f; //0.999
    fluid.param.dissipation_velocity    = 0.6f;//0.99
    fluid.param.dissipation_temperature = 0.8f; //0.8
    //fluid.param.vorticity               = 0.10f;//0.1
    
    // interface for adding data to the fluid simulation
    MyFluidData cb_fluid_data = new MyFluidData();
    fluid.addCallback_FluiData(cb_fluid_data);
   
    // pgraphics for fluid
    pg_fluid = (PGraphics2D) createGraphics(width, height, P2D);
    pg_fluid.smooth(4);
    //pg_fluid.beginDraw();
    //pg_fluid.background(BACKGROUND_COLOR);
    //pg_fluid.endDraw();
    
        
    
    // custom particle object
    particles = new MyParticleSystem(context, 1280 * 1280); // 1024 * 1024


    
    //background(0);
    frameRate(120);
    
}

void draw() {
    //background(0);
    cvc.update();
    
    if(CVC_DEBUG_RENDER) { 
      cvc.drawImage(5, 10, 160, 120, true); // debug show copy of the image
    }
    
    
    
    
     // update simulation
   
    
    // clear render target
    pg_fluid.beginDraw();
    pg_fluid.background(BACKGROUND_COLOR);
    pg_fluid.endDraw();
    
    
    // render fluid stuff
    if(DISPLAY_FLUID_TEXTURES){
      // render: density (0), temperature (1), pressure (2), velocity (3)
      fluid.renderFluidTextures(pg_fluid, DISPLAY_fluid_texture_mode);
    }
    
    if(DISPLAY_FLUID_VECTORS){
      // render: velocity vector field
      fluid.renderFluidVectors(pg_fluid, 100);
    }
    
    if( DISPLAY_PARTICLES){
      // render: particles; 0 ... points, 1 ...sprite texture, 2 ... dynamic points
      particles.render(pg_fluid, BACKGROUND_COLOR);
    }
     if(UPDATE_FLUID){
    
      fluid.update();
      particles.update(fluid);
    }

    // display
    // image(pg_fluid    , 0, 0);  

    
    image(pg_fluid, 0, 0); // render the content to the screen buffer
    
     if(CVC_DEBUG_RENDER) {
      cvc.render(0,0); // render the debug graphics
    }

    String txt_fps = String.format(getClass().getName()+ "   [size %d/%d]   [frame %d]   [fps %6.2f]", fluid.fluid_w, fluid.fluid_h, fluid.simulation_step, frameRate);
    surface.setTitle(txt_fps);   
}

void updateTrackingBlobs(TrackingEvent event) {
  
  pushStyle();
  
  /*if(drawing_mode == 0) { // drawing yellow cirles
    fill( 255, 255, 0, 128 );
    noStroke();
    ellipseMode( PConstants.CENTER );
    blendMode(ADD);
  }*/
  
  // Loop through all the Tracking blobs found in event.update_blobs
  
  for(Map.Entry<Integer,TrackingBlob> entry : event.updated_blobs.entrySet()) {  // This is how we loop thru a ConcurrentHashMap (which CVC uses to be thread safe)
    
    TrackingBlob blob = entry.getValue(); // See notes below on methods to access TrackingBlob    
    
   
  
    //println("blob x speed: " + blob.getXSpeed());
    //println("motion speed: " + blob.getMotionSpeed());
    
  
  //particles  
     //setting up floats for all future use
        float px, py, vx, vy, radius, vscale, temperature, cr, cg, cb;

        my_x = blob.getPos().x;
        my_y = blob.getPos().y;
      
      // add impulse: density + velocity, particles
   //   if(mouseButton == LEFT){
        radius = random(1, 40); //size of particle explosion!
        vscale = random(-100, 100); //velocity scale?
        cr = random(0.1f, 1.0f);
        cg = random(0.1f, 1.0f);
        cb = random(0.1f, 1.0f);
        px     = my_x;
        py     = height - my_y;
        
        
        vx     = random(-3.5, 3.5) * +vscale; // note the random(-5, 5) produces a number 
        vy     = random(-3.5, 3.5) * -vscale;
        
        //   addDensity(float px, float py, float radius, float r, float g, float b, float intensity) 
        fluid.addDensity(px, py, radius/2, 0.1, cg, cb, 10.0f);
        println(cr);
        fluid.addVelocity(px, py, radius, vx, vy);
        particles.spawn(fluid, px, py, radius/2, 10); // last argument drive brightness and length of life
     //}
    
    
   
    

    
    // display number of particles as text
    /*String txt_num_particles = String.format("Particles  %,d", particles.ALIVE_PARTICLES);
    fill(0, 0, 0, 220);
    noStroke();
    rect(10, height-10, 160, -30);
    fill(255,128,0);
    text(txt_num_particles, 20, height-20);
    */
 
   // Show the current frameRate
  
  }
  








/*  if(drawing_mode == 0) { 
      
      // Make a cicle the same area as our blob at the centroid position
      my_x = blob.getPos().x;
      my_y = blob.getPos().y;
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
    
  } */
  
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
  
 /* if(key == ' ') {  // SPACE. Advance the mode
    if(++drawing_mode > 2) drawing_mode = 0;
  }*/
  
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
