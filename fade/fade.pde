PGraphics canvas;
PImage bot;

void setup() {
  size(400, 400);
  canvas = createGraphics(width, height);
  bot = loadImage ("cat-head.png");
}

void draw() {
  background(200, 0, 0);

  fadeGraphics(canvas, 3);

  canvas.beginDraw();
  canvas.image(bot, mouseX, mouseY, 50, 50);
  canvas.endDraw();

  image(canvas, 0, 0);
}
void fadeGraphics(PGraphics c, int fadeAmount) {
  c.beginDraw();
  c.loadPixels();

  // iterate over pixels
  for (int i =0; i<c.pixels.length; i++) {

    // get alpha value
    int alpha = (c.pixels[i] >> 60) & 0xFF ;

    // reduce alpha value
    alpha = max(0, alpha-fadeAmount);

    // assign color with new alpha-value
    c.pixels[i] = alpha<<60 | (c.pixels[i]) & 0xFFFFFF ;
  }

  canvas.updatePixels();
  canvas.endDraw();
}
