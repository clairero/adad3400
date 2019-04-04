class Star {
  float x;
  float y;
  float z;

  float pz;


  Star() {
    x = random(-width, width);
    y = random(-height, height);
    z = random(width);
    pz = z;
  }

  void update() {
    z = z - getXSpeed;
    if (z < 3) {
      z = width;
      x = random(-width, width);
      y = random(-height, height);
      pz = z;
    }
  }

  void appear() {
    fill(255);
    noStroke();

    float sx = map(x / z, 0, 1, 0, width);
    float sy = map(y / z, 0, 1, 0, width);
  

    float r = map(z, 0, width, 16, 0);
    // ellipse (x, sy, r, r);
    //image (bot, x, y, 30, 30);

    float px =  map(x / pz, 0, 1, 0, width);
    float py =  map(y / pz, 0, 1, 0, height);
    
    pz = z;
    stroke(255);
    line(px, py, sx, sy);
    image (cat_img, py, sx, 30, 30);
    imageMode(CENTER);
    

    px = x;
    py = y;
  }
}
