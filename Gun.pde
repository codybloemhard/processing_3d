public class Gun {
  public String name;
  int index = 0;
  public int waitToFire = 0;
  public int damage = 0;
  public float accuracy = 0;
  public float bulletSpeed = 0;

  public AudioPlayer sound;
  public PImage cross;
  public float scope = 0f;
  public float scopeAcc = 0;
  public int auto = 0;
  public float walkSpeed = 0;

  int bullets = 0;
  boolean canshoot = true;
  
  public Gun(String name, int wait, int dam, float acc, float speed, AudioPlayer s, PImage cross,
    float scope, float scopedAccDiv, int auto, float walkSpeed) {
    this.name = name;
    waitToFire = wait;
    damage = dam;
    bulletSpeed = speed;
    sound = s;
    this.cross = cross;
    this.scope = scope;
    scopeAcc = scopedAccDiv;
    this.auto = auto;
    this.walkSpeed = walkSpeed;
    bullets = 50;
  }

  public float[] tryFire() {
    if (index > waitToFire && canshoot && bullets > 0) {
      index = 0;
      if (auto == 0)canshoot = false;
      sound.rewind();
      sound.play(); 
      bullets--;
      return new float[] {random(accuracy * 2) - accuracy, random(accuracy * 2) - accuracy, random(accuracy * 2) - accuracy};
    }
    return new float[] {0, 0, 0};
  }

  public void UpdateGun() {
    index++;
  }
}