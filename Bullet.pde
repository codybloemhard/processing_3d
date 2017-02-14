public class Bullet extends GO {
  public float xdir = 0;
  public float ydir = 0;
  public float zdir = 0;
  public float speed = 0;
  public boolean dead = false;
  public float damage = 0;

  public Bullet(float x, float y, float z, float sx, float sy, float sz, float speed) {
    super(x, y, z, sx, sy, sz); 
    this.speed = speed;
  }

  public void SetDirVec(float xd, float yd, float zd) {
    xdir = xd;
    ydir = yd;
    zdir = zd;
  }

  public void UpdateTrans() {
    pushMatrix();
    x += xdir * speed;
    y += ydir * speed;
    z += zdir * speed;
    translate(x, y, z);
    popMatrix();
  }

  public void Kill() {
    x = -1000;
    y = -1000;
    z = -1000;
    xdir = 0;
    ydir = 0;
    zdir = 0;
    speed = 0;
    dead = true;
  }
}