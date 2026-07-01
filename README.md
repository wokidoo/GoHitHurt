![GoHitHurt](icon.svg)

# GoHitHurt

A small Godot addon for building hit/hurtbox interactions with plain scene composition, in both 2D and 3D.

GoHitHurt provides a matched pair of nodes - a **hitbox** that scans for targets and a **hurtbox** that receives hits - that report collisions through signals and pass arbitrary data along with each hit, all configured from the inspector.

---

## 🤔 Why use GoHitHurt?

If you find yourself hand-rolling `Area2D`/`Area3D` overlap plumbing for every attack, projectile, and damageable body, this addon moves that logic into a couple of reusable, drop-in nodes.

It is especially useful when you want:

- consistent hit detection across many entities
- attacks that carry their own data (damage, knockback, status effects)
- toggling hitboxes on and off per animation frame or attack window
- the same workflow in 2D and 3D
- collision behavior configured in scenes rather than in many custom scripts

---

## ✨ What it includes

- `GoHitbox2D` / `GoHitbox3D`
  * scan for hurtboxes each physics frame (`ShapeCast2D` in 2D)
  * emit `hit_detected` and notify each hurtbox on contact
  * carry a `hit_data` dictionary merged into every reported collision
  * throttle scanning with `frame_delay`
  * enable, disable, or toggle for a fixed duration
  * trigger a manual query on demand with `query_hit()`
- `GoHurtbox2D` / `GoHurtbox3D`
  * passive, detectable regions that receive hits from a hitbox
  * re-emit incoming hits through `hit_detected` for game code to consume
  * enable, disable, or toggle for a fixed duration

---

## 🧠 How it works

Hitboxes and hurtboxes play complementary roles:

- A **hitbox** is active. It scans its shape against the physics space and, for every overlapping hurtbox, emits `hit_detected` and calls the hurtbox's `receive_hit()`. Non-hurtbox colliders are added as exceptions so they are skipped on later scans.
- A **hurtbox** is passive. It performs no scanning of its own — it is *monitorable* so a hitbox can find it, and it reacts only when a hitbox hands it a hit, re-emitting the collision through its own `hit_detected` signal.

When a hit lands, the hitbox's `hit_data` is merged into the collision dictionary along with a `source` key pointing back at the hitbox, so a single dictionary carries everything a listener needs.

---

## ⚙️ Installation

1. Copy the `addons/gohithurt` folder into your Godot project.
2. Open `Project > Project Settings > Plugins`.
3. Enable `GoHitHurt`.

---

## 🚀 Getting started

### Set up a hurtbox

1. Add a `GoHurtbox2D` (or `GoHurtbox3D`) node to the entity that can be hit.
2. Give it a `CollisionShape2D`/`CollisionShape3D` child.
3. Connect its `hit_detected` signal to your damage/health logic.

### Set up a hitbox

1. Add a `GoHitbox2D` (or `GoHitbox3D`) node to the attacker.
2. Give it a collision shape covering the attack's reach.
3. Fill in `hit_data` from the inspector (for example `{ "damage": 10 }`).
4. Enable it during the active frames of your attack.

When the hitbox overlaps a hurtbox, the hurtbox's `hit_detected` fires with the merged collision data.

### Time an attack window

Use `enable_temporarily()` to open the hitbox for a fixed duration, or `enable()` / `disable()` to gate it against animation frames:

```gdscript
$GoHitbox2D.enable_temporarily(0.2)
```

### Poll on demand

Call `query_hit()` to run a single scan this frame regardless of the hitbox's enabled state — handy for instantaneous checks driven by code rather than the per-frame loop.

---

## 🧩 Example

```
Player
 ├─ GoHurtbox2D            (hit_detected → Player._on_hit)
 │    └─ CollisionShape2D
 └─ Sword
      └─ GoHitbox2D        (hit_data = { "damage": 10 }, enabled during swing)
           └─ CollisionShape2D

Enemy
 └─ GoHurtbox2D            (hit_detected → Enemy._on_hit)
      └─ CollisionShape2D
```

When the sword's hitbox is enabled and overlaps the enemy's hurtbox, the enemy's `hit_detected` fires carrying `damage`, the originating `source` hitbox, and the collision data.

---

## 💡 Use cases

- melee attacks with per-frame active windows
- projectiles that deal damage on contact
- environmental hazards (spikes, lava, traps)
- passing damage, knockback, or status effects with each hit
- momentarily invulnerable targets by disabling a hurtbox
- code-driven hit checks via `query_hit()`

---

## 📌 Notes

- A hurtbox does nothing on its own until a hitbox hands it a hit.
- `frame_delay` on a hitbox must be `>= 1`.
- `query_hit()` bypasses the hitbox's enabled state, but a disabled hurtbox still ignores the hit.
- A disabled hurtbox remains detectable; the hit is simply ignored on arrival rather than prevented at the shape-cast level.
- The 2D and 3D variants share the same API, pick the pair that matches your game.

---

## 🤝 Contributing

If you want to add features, improve documentation, or suggest enhancements, please open an issue. Feedback is welcome and appreciated!