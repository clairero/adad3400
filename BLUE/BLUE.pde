/*

  CVCExampleBasic
  
  Shows using CVClient (ComputerVisionClient) to connect to VideoTracker, 
  read blob data and some different ideas to render it.
  
  Dependencies: controlP5, cvc.jar (included in code folder) & bbc_utils.jar (included in code folder)
  this implementaion and the jar file dependences  are not currently openscourced
  and are owned by Brad Miller 
  and can only be used without permission for class ADAD3402 @ UNSW 2017
*/
Star[] stars = new Star[100];
import beads.*;
import java.util.Arrays; 

AudioContext ac;
Glide carrierFreq, modFreqRatio;

import java.util.Map;
import controlP5.*;
import cvc.CVClient;
import cvc.events.TrackingEvent;
import cvc.blobs.TrackingBlob;
import com.thomasdiewald.pixelflow.java.DwPixelFlow;
import com.thomasdiewald.pixelflow.java.fluid.DwFluid2D;
import processing.core.*;
import processing.opengl.PGraphics2D;
import processing.sound.*;

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
int     DISPLAY_fluid_texture_mode = 1; // 1 particles only
boolean DISPLAY_PARTICLES          = true;
boolean CVC_DEBUG_RENDER           = true; // true


  
  int viewport_w = 900;
  int viewport_h = 900; //600
  int viewport_x = 930;  //230
  int viewport_y = 900; //0
  
  int gui_w = 500;
  int gui_x = 500;
  int gui_y = 500;
  


PImage cat_img;
  
  int fluidgrid_scale = 2; //2
  DwFluid2D fluid;
  // render targets
  PGraphics2D pg_fluid;
  //texture-buffer, for adding obstacles
  //PGraphics2D pg_obstacles;
  // custom particle system
  MyParticleSystem particles;
  

    
  public void settings() {
    
    size(viewport_w-100, viewport_h-100, P2D);
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
  {
    ac = new AudioContext();
    carrierFreq = new Glide(ac, 500);
  modFreqRatio = new Glide(ac, 1);
  Function modFreq = new Function(carrierFreq, modFreqRatio) {
    public float calculate() {
      return x[0] * x[1];
    }
  };
  WavePlayer freqModulator = new WavePlayer(ac, modFreq, Buffer.SINE);
  Function carrierMod = new Function(freqModulator, carrierFreq) {
    public float calculate() {
      return x[0] * 50.0 + x[1];    
    }
  };
  WavePlayer wp = new WavePlayer(ac, carrierMod, Buffer.SINE);
  Gain g = new Gain(ac, 1, 0.1);
  g.addInput(wp);
  ac.out.addInput(g);
  ac.start();
}

 cat_img = loadImage ("cat-head.png");
 for (int i = 1; i < stars.length; i++) {
     stars[i] = new Star();
 }
    
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
    fluid.param.dissipation_density     = 0.999f; //0.999
    fluid.param.dissipation_velocity    = 0.1f;//0.99
    fluid.param.dissipation_temperature = 0.1f; //0.8
    fluid.param.vorticity               = 0.1f;//0.1
    
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
color poop = color(0);
color opp = color(0);

void draw() {
  
{
    
 
    
    cvc.update();
    
    if(CVC_DEBUG_RENDER) { 
      cvc.drawImage(0,0,0,0, true); // debug show copy of the image
    }
    pg_fluid.beginDraw();
    pg_fluid.background(BACKGROUND_COLOR);
    pg_fluid.endDraw();
    
    
    // render fluid stuff
    if(DISPLAY_FLUID_TEXTURES){
      // render: density (0), temperature (1), pressure (2), velocity (3)
      fluid.renderFluidTextures(pg_fluid, DISPLAY_fluid_texture_mode);
    }
    
    
   loadPixels();
  //set the background
  Arrays.fill(pixels, poop);
  //scan across the pixels
  for(int i = 0; i < width; i++) {
    //for each pixel work out where in the current audio buffer we are
    int buffIndex = i * ac.getBufferSize() / width;
    //then work out the pixel height of the audio data at that point
    int vOffset = (int)((1 + ac.out.getValue(0, buffIndex)) * viewport_x / 2);
    //draw into Processing's convenient 1-D array of pixels
    vOffset = min(vOffset, height);
    pixels[vOffset * height + i] = opp;
  }
  
     //background(0);  
      getXSpeed =map(mouseX+100, 0, width, 0, 2);


  
  for (int i = 1; i < stars.length; i++) {
    stars[i].update();
    stars[i].appear();
  }
  
  updatePixels();

  carrierFreq.setValue((float)mouseY / width * 1000 + 50);
  modFreqRatio.setValue((1 - (float)mouseX / height) * 10 + 0.1);
}

    
    if(DISPLAY_FLUID_VECTORS){
      // render: velocity vector field
      fluid.renderFluidVectors(pg_fluid, #E52CE3);
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
    
   
  
    println("blob x speed: " + blob.getXSpeed());
    println("motion speed: " + blob.getMotionSpeed());
    
  
  //particles  
     //setting up floats for all future use
        float px, py, vx, vy, radius, vscale, temperature, cr, cg, cb;

        my_x = blob.getPos().x;
        my_y = blob.getPos().y;
      
      // add impulse: density + velocity, particles
   //   if(mouseButton == LEFT){
        radius = random(10, 10); //size of particle explosion!
        vscale = random(-100, 100); //velocity scale?
        cr = random(1.5f, 1.0f);
        cg = random(1.5f, 1.0f);
        cb = random(0.1f, 1.0f);
        px     = my_x;
        py     = height - my_y;
        
        
        vx     = random(-3.5, 3.5) * +vscale; // note the random(-5, 5) produces a number 
        vy     = random(-3.5, 3.5) * -vscale;
        
        //   addDensity(float px, float py, float radius, float r, float g, float b, float intensity) 
        fluid.addDensity(px, py, radius/2, 5.1, cg, cb, 10.0f);
        println(cr);
        fluid.addVelocity(px, py, radius, vx, vy);
        particles.spawn(fluid, px, py, radius/2, 1); // last argument drive brightness and length of life

  
  }

  
  popStyle();
  
}
  
void removeTrackingBlobs( TrackingEvent event ) {
  // event.removed_blob_ids ArrayList of ints of the ids of blobs removed.
  // You can use this to remove your own blobs if you have created some

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
