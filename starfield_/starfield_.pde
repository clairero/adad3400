Star[] stars = new Star[100];


PImage bot;
float speed;


void setup() {
 size(800,800);
 bot = loadImage ("cat-head.png");
 for (int i = 0; i < stars.length; i++) {
     stars[i] = new Star();
}

}

void draw() {
  speed =map(mouseX, 0, width, 0, 20);
  background(0);
  translate(width/2, height/2);
  for (int i = 0; i < stars.length; i++) {
    stars[i].update();
    stars[i].show();
  
}
}
