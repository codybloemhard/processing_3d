public class GO {
  public float x = 0;
  public float y = 0;
  public float z = 0;
  public float sx = 0;
  public float sy = 0;
  public float sz = 0;

  public GO() {
  }

  public GO(float x, float y, float z, float sx, float sy, float sz) {
    this.x = x;
    this.y = y;
    this.z = z;
    this.sx = sx;
    this.sy = sy;
    this.sz = sz;
  }

  public void SetPosition(float x, float y, float z) {
    this.x = x;
    this.y = y;
    this.z = z;
  }

  public void SetSize(float sx, float sy, float sz) {
    this.sx = sx;
    this.sy = sy;
    this.sz = sz;
  }

  public void DrawAsBox(float r, float g, float b, float a) {
    fill(r, g, b, a);
    pushMatrix();
    translate(x, y, z);
    box(sx, sy, sz);
    popMatrix();
  }
}