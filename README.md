# Operation Zero

Operation Zero is a 2D top-down tactical shooter prototype built with Godot 4.7.
The current build is a local, single-player PvE prototype; its gameplay scripts
are a reconstruction from the available scenes, not recovered original code.

## Run

Open `project.godot` in Godot 4.7 or later and run the main scene, or launch
`play.bat` from this project folder. If Godot is installed elsewhere, set the
`GODOT4` environment variable to its executable path before using the launcher.
The player can move during the briefing; enemies and squad AI begin when the
operation starts.

## Controls

- **WASD**: move; **Shift**: sprint
- **Mouse**: aim; **left mouse**: fire; **right mouse**: move the squad to a mark
- **E**: interact; **R**: reload; **G**: throw a flashbang
- **C / X / V**: crouch / prone / stand
- **F**: operative ability; **1–4**: Pointman / Recon / Gunner / Infiltrator
- **Z**: split the squad; use the Squad menu for regroup, move, breach, cover,
  hold position, hold fire, target Alpha, and split-element orders
- Select **Extraction** or **Elimination** from the mission briefing. Auto-fire
  can be toggled from the right-side controls.

Touch devices use dual virtual sticks and on-screen fire, ability, stance, and
reload controls.

## Current gameplay systems

- Directional field of view, wall-blocked visibility, close-range awareness,
  Recon scans, and dynamic enemy concealment
- Enemy vision cones, sound investigation, quiet crouch movement, loud sprinting,
  and suppressed Infiltrator fire
- Four AI operatives, squad movement orders, door stacking, target focus, and
  split-element positioning
- Stand/crouch/prone movement and aim tradeoffs, armor plates, recoil/spread,
  hitscan-style projectiles, and penetration through designated soft cover
- Operative roles with distinct abilities, locked-door picking/breaching, and
  extraction or timed elimination rounds
- Two extraction zones, mission briefings, round timer, and win/defeat screens

Roles provide a flashbang/breach focus (Pointman), a wider cone and temporary
recon scan (Recon), heavier slower fire and suppression (Gunner), or quiet
fire and a short-range heartbeat pulse (Infiltrator).

## Not yet implemented

This prototype does not include online PvP/PvE networking, dedicated authoritative
servers, client-side prediction, 3D/multi-floor verticality, procedural map
generation, thermal rendering, drone/heartbeat visual UI, hostages, or persistent
progression. Those require separate design and validation work beyond the current
2D local prototype.
