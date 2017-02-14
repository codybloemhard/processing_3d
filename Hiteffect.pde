public class HitEffect {
  public GO[] effects;
  public byte[] lives;
  public int count = 0;

  public HitEffect() {
    lives = new byte[1000];
    effects = new GO[1000];
    for (int i = 0; i < 1000; i++) {
      effects[i] = new GO(0, 0, 0, 50, 50, 50);
    }
  }

  public void Update() {
    for (int i = 0; i < 1000; i++) {
      if (lives[i] > 0) {
        effects[i].sx --;
        effects[i].sy --;
        effects[i].sz --;
        lives[i] --;
      } else if (lives[i] == 0) {
        effects[i].x = -1000;
        effects[i].y = -1000;
        effects[i].z = -1000;
      }
    }
  }

  public void SpawnEffect(float x, float y, float z) {
    effects[count].x = x;
    effects[count].y = y;
    effects[count].z = z;
    lives[count] = 20;
    effects[count].sx = 50;
    effects[count].sy = 50;
    effects[count].sz = 50;
    if (count < 998)count ++;
    else count = 0;
  }

  public void DrawEffects() {
    strokeWeight(0);
    for (int i = 0; i < 1000; i++) {
      if (lives[i] > 0) {
        effects[i].DrawAsBox(255, 0, 0, 100);
      }
    }
    strokeWeight(stroke);
  }
}