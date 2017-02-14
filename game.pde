import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

import java.lang.Math;
import processing.sound.*;

int x = 300;
int y = 300;
int z = 130;
float speed = 1;
float sideSpeedMul = 0.5f;

float xangle;
float yangle;
float lookX;
float lookY;
float lookZ;
float rightDirX = 0;
float leftDirX = 0;
float backDirX = 0;
float rightDirY = 0;
float leftDirY = 0;
float backDirY = 0;

boolean[] keys;
boolean leftM, rightM;
boolean ctrl, shift;

boolean canGoForward = true;
boolean canGoLeft = true;
boolean canGoRight = true;
boolean canGoBackwards = true;

boolean shot = false;
boolean walking = false;

int size = 100;
int blocks = 64;
int[][] prepworld1;
int[][] prepworld2;
int[][] world;

Bullet[] bullets;
int bulletCount = 0;
float recoilCounter = 0;
float recoilRecover = 1f;

int gun = 0;
Gun[] guns;
boolean scoped = false;
HitEffect hit;

PFont f = createFont("Arial", 32, true);

PImage crosshair;

Minim m;
AudioPlayer hitSound;
AudioPlayer pistolSound;

int stroke = 1;

void setup() {
  size(1920, 1080, P3D);
  strokeWeight(stroke);
  smooth();

  frameRate(60);
  keys = new boolean[256];

  crosshair = loadImage("cross_normal.png");

  m = new Minim(this);
  pistolSound = m.loadFile("pistol_shoot.wav");
  hitSound = m.loadFile("hit.wav");

  bullets = new Bullet[200];
  for (int i = 0; i < 200; i++) {
    bullets[i] = new Bullet(-1000, -1000, -1000, 0, 0, 0, 0);
    bullets[i].sx = 10;
    bullets[i].sy = 10;
    bullets[i].sz = 10;
  }
  //name, wait, dam, acc, speed, audio, image, scope, scopeAcc, auto, walkspeed
  guns = new Gun[2];
  guns[0] = new Gun("pistol", 15, 20, 0.2f, 10, pistolSound, crosshair, 1.0f, 1.5f, 0, 1.3f);
  guns[1] = new Gun("as", 15, 20, 0.2f, 10, pistolSound, crosshair, 1.0f, 1.5f, 1, 1.3f);
  
  hit = new HitEffect();

  prepworld1 = new int[blocks][blocks];
  prepworld2 = new int[blocks][blocks];
  world = new int[blocks][blocks];

  for (int xx = 0; xx < blocks; xx+=4) {
    for (int zz = 0; zz < blocks; zz+=4) {
      if (random(1) > 0.9)
        for (int i = 0; i < 4; i++) {
          for (int j = 0; j < 4; j++) {
            prepworld1[xx + i][zz + j] = 1000;
          }
        }
    }
  }

  for (int xx = 0; xx < blocks; xx+=2) {
    for (int zz = 0; zz < blocks; zz+=2) {
      if (random(1) > 0.8)
        for (int i = 0; i < 2; i++) {
          for (int j = 0; j < 2; j++) {
            prepworld2[xx + i][zz + j] = 500 + prepworld1[xx + i][zz + j];
          }
        }
    }
  }

  for (int xx = 0; xx < blocks; xx++) {
    for (int zz = 0; zz < blocks; zz++) {
      if (random(1) > 0.75)
        world[xx][zz] = 200 + prepworld2[xx][zz];
      if (random(1) > 0.75)
        world[xx][zz] += 200;
      if (world[xx][zz] <= 200)
        world[xx][zz] = 0;
      else if (world[xx][zz] <= 400)
        world[xx][zz] = 200;
    }
  }
}

void draw() {
  //println((int)frameRate);
  background(0, 0, 0);
  //ambientLight(255, 255, 255);
  ambientLight(70, 70, 70);
  spotLight(127, 127, 127, x - lookX, z, y - lookY, lookX, 0, lookY, PI/1, 1);
  spotLight(190, 190, 190, x - lookX, z, y - lookY, lookX, 0, lookY, PI/6, 2);

  updateCam();
  updateControls();
  updateBullets();
  hit.Update();
  updateGeometry();
  hit.DrawEffects();

  render2D();
  useCam();
}

public void updateGeometry() {
  fill(127, 127, 127, 255);
  pushMatrix();
  translate(0, 0, 0);
  box(100000, 2, 100000);
  popMatrix();

  fill(30, 127, 255, 255);
  for (int xx = 0; xx < blocks; xx++) {
    for (int zz = 0; zz < blocks; zz++) {
      if (world[xx][zz] != 0) {
        pushMatrix();
        translate(size * xx, world[xx][zz] / 2, size * zz);
        box(size, world[xx][zz], size);
        popMatrix();
      }
    }
  }
}

public void updateCam() {
  xangle = map(-mouseX, 0, width, 0, 360);
  //lookZ = map(mouseY, 0, height, 180, 10);
  yangle = map(mouseY, 0, height, 101, -101) + recoilCounter;
  if (yangle > 32)
    yangle = 32;
  else if (yangle < -32)
    yangle = -32;

  lookX = sin(xangle * 0.05f) * 10;
  lookY = -cos(xangle * 0.05f) * 10;
  lookZ = tan(yangle * 0.05f) * 10;

  rightDirX = sin((xangle + 90) * 0.05f) * 10;
  rightDirY = -cos((xangle + 90) * 0.05f) * 10;
  leftDirX = sin((xangle - 90) * 0.05f) * 10;
  leftDirY = -cos((xangle - 90) * 0.05f) * 10;
  backDirX = sin((xangle - 180) * 0.05f) * 10;
  backDirY = -cos((xangle - 180) * 0.05f) * 10;
}

public void useCam() {
  float fov;

  if (!scoped) {
    fov = 1f; //+- pi/3
  } else {
    fov = 1/guns[gun].scope;
  }

  float cameraZ = (height/2.0) / tan(fov/2.0);
  frustum(-10, 0, 0, 10, 10, 10000);
  perspective(fov, float(width)/float(height), cameraZ/1000, cameraZ*10000);
  camera(x, z, y, x + lookX, lookZ + z, y + lookY, 0, -1, 0);
}

public void render2D() {
  float fov = PI/3;
  float cameraZ = (height/2.0) / tan(fov/2.0); 
  perspective(fov, float(width)/float(height), cameraZ/1000, cameraZ*1000);
  camera();
  hint(DISABLE_DEPTH_TEST);
  noLights();
  textMode(MODEL);

  textFont(f, 32);
  fill(255);
  text(frameRate, 20, 20 + textAscent());
  text("Gun: " + guns[gun].name, width / 20, height / 10 * 9 + textAscent());
  text("Ammo: " + guns[gun].bullets, width / 6, height / 10 * 9 + textAscent());

  float imgsize = width/3;
  image(guns[gun].cross, width/2 - imgsize/2, height/2 - imgsize/2, imgsize, imgsize);

  hint(ENABLE_DEPTH_TEST);
}

public void keyPressed() {
  if (key == 'w')
    keys['w'] = true;
  if (key == 's')
    keys['s'] = true;
  if (key == 'a')
    keys['a'] = true;
  if (key == 'd')
    keys['d'] = true;
  if (key == 'c')
    keys['c'] = true;
  if (keyCode == SHIFT)
    shift = true;
  if (keyCode == CONTROL)
    ctrl = true;
}

public void keyReleased() {
  if (key == 'w')
    keys['w'] = false;
  if (key == 's')
    keys['s'] = false;
  if (key == 'a')
    keys['a'] = false;
  if (key == 'd')
    keys['d'] = false;
  if (key == 'q') {
    if (gun < guns.length - 1)
      gun++;
    else
      gun = 0;
  }
  if (key == 'r') {
  }
  if (key == 'c')
    keys['c'] = false;
  if (keyCode == SHIFT)
    shift = false;
  if (keyCode == CONTROL)
    ctrl = false;
}

public void mousePressed() {
  if (mouseButton == LEFT)
    leftM = true;
  if (mouseButton == RIGHT)
    rightM = true;
}

public void mouseReleased() {
  if (mouseButton == LEFT)
    leftM = false;
  if (mouseButton == RIGHT)
    rightM = false;
}

public void updateControls() {
  canGoForward = !checkCollisions(x + (lookX * speed * 5.5), y + (lookY * speed * 5.5), z);
  canGoLeft = !checkCollisions(x + (leftDirX * speed * sideSpeedMul * 5.5), y + (leftDirY * speed * sideSpeedMul * 5.5), z);
  canGoRight = !checkCollisions(x + (rightDirX * speed * sideSpeedMul * 5.5), y + (rightDirY * speed * sideSpeedMul * 5.5), z);
  canGoBackwards = !checkCollisions(x + (lookX * speed * sideSpeedMul * 5.5), y + (lookY * speed * sideSpeedMul * 5.5), z);

  float walkMul, aimMul;

  if (scoped)
    aimMul = 0.5f;
  else
    aimMul = 1f;

  if (walking)
    walkMul = 0.5f;
  else
    walkMul = 1f;


  shot = false;
  walking = false;

  guns[gun].UpdateGun();

  if (rightM)
    scoped = true;
  else
    scoped = false;

  if(!leftM)
    guns[gun].canshoot = true;

  if (keys['a'] && canGoLeft) {
    x += leftDirX * speed * guns[gun].walkSpeed * walkMul * aimMul;
    y += leftDirY * speed * guns[gun].walkSpeed * walkMul * aimMul;
    walking = true;
  }
  if (keys['d'] && canGoRight) {
    x += rightDirX * speed * guns[gun].walkSpeed * walkMul * aimMul;
    y += rightDirY * speed * guns[gun].walkSpeed * walkMul * aimMul;
    walking = true;
  }
  if (keys['w'] && canGoForward) {
    x += lookX * speed * guns[gun].walkSpeed * walkMul * aimMul;
    y += lookY * speed * guns[gun].walkSpeed * walkMul * aimMul;
    walking = true;
  }  
  if (keys['s'] && canGoBackwards) {
    x -= lookX * speed * guns[gun].walkSpeed * walkMul * aimMul;
    y -= lookY * speed * guns[gun].walkSpeed * walkMul * aimMul;
    walking = true;
  } 

  if (leftM) {
     float[] accNow = guns[gun].tryFire();
     if(accNow[0] != 0 && accNow[1] != 0 && accNow[2] != 0 && accNow[0] != -1 && accNow[1] != -1 && accNow[2] != -1){
     shot = true;
     if(bulletCount > 198)
     bulletCount = 0;
     bullets[bulletCount].SetPosition(x,z,y);
     
     if(!scoped && !walking)
     bullets[bulletCount].SetDirVec(lookX + accNow[0],lookZ + accNow[1],lookY + accNow[2]);
     else if(scoped && !walking)
     bullets[bulletCount].SetDirVec(lookX + accNow[0]/guns[gun].scopeAcc,lookZ + accNow[1]/guns[gun].scopeAcc,lookY + accNow[2]/guns[gun].scopeAcc);
     else if(!scoped && walking)
     bullets[bulletCount].SetDirVec(lookX + (accNow[0])*1.3f,lookZ + (accNow[1])*1.3f,lookY + (accNow[2])*1.3f);
     else if(scoped && walking)
     bullets[bulletCount].SetDirVec(lookX + (accNow[0]/guns[gun].scopeAcc)*1.3f,lookZ + (accNow[1]/guns[gun].scopeAcc)*1.3f,lookY + (accNow[2]/guns[gun].scopeAcc)*1.3f);
     
     bullets[bulletCount].dead = false;
     bullets[bulletCount].speed = guns[gun].bulletSpeed;
     bullets[bulletCount].damage = guns[gun].damage;
     
     println("shot: " + bulletCount);
     bulletCount++;   
   }
  }
  canGoForward = true;
  canGoLeft = true;
  canGoRight = true;
  canGoBackwards = true;
}

public boolean checkCollisions(float checkx, float checky, float z) {
  for (int xx = 0; xx < blocks; xx++) {
    for (int yy = 0; yy < blocks; yy++) {
      if (checkx > (xx * size) - (size/2) && checkx < (xx * size) + (size/2) &&
        checky > (yy * size) - (size/2) && checky < (yy * size) + (size/2)
        && world[xx][yy] > 0 && z < world[xx][yy])
        return true;
    }
  }
  return false;
}

public void updateBullets() {
  strokeWeight(0);
  for (int i = 0; i < 200; i++) {
    if (!bullets[i].dead) {
      if (checkCollisions(bullets[i].x, bullets[i].z, bullets[i].y)) {
        hit.SpawnEffect(bullets[i].x - bullets[i].xdir * guns[gun].bulletSpeed, bullets[i].y - bullets[i].ydir * guns[gun].bulletSpeed, bullets[i].z - bullets[i].zdir * guns[gun].bulletSpeed);
        bullets[i].Kill();
        hitSound.rewind();
        hitSound.play();
      }
      bullets[i].UpdateTrans();
      bullets[i].DrawAsBox(255, 255, 255, 127);
    }
  }
  strokeWeight(stroke);
}