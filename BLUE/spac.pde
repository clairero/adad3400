class Star {
  float x;
  float y;
  float z;

  float pz;


  Star() {
    x = random(-viewport_w, viewport_h);
    y = random(-viewport_h, viewport_h);
    z = random(viewport_w);
    pz = z;
  }

  void update() {
    z = z - getXSpeed;
    if (z < 3) {
      z = viewport_w;
      x = random(-viewport_w, viewport_w);
      y = random(-viewport_h, viewport_h);
      pz = z;
    }
  }

  void appear() {
    fill(0);
    noStroke();

    float sx = map(x / z, 0, 1, 0, viewport_w);
    float sy = map(y / z, 0, 1, 0, viewport_w);
  

    float r = map(z, 0, viewport_w, 0, 0);
    // ellipse (x, sy, r, r);
    //image (bot, x, y, 30, 30);

    float px =  map(x / pz, 0, 1, 0, viewport_w);
    float py =  map(y / pz, 0, 1, 0, viewport_h);
    
    pz = z;
    stroke(255);
    line(px, py, sx, sy);
    image (cat_img, py, sx, 60, 60);
    imageMode(CENTER);
    

    px = x;
    py = y;
  }
}
