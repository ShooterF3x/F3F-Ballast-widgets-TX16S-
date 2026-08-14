# F3F Ballast Manager - EdgeTX Widget
Color and touch-screen widget for EdgeTX radios (TX16S, TX16S MKII, etc.) designed specifically for F3F glider pilots.

It calculates in real-time the optimal loading plan (distribution across ballast bays) based on wind speed, while minimizing Center of Gravity (CG) deviation from your target.

# ✨ Main Features
Dynamic Dashboard: Instant visualization of wind speed, calculated target weight, current total weight, and CG deviation with a visual indicator (Green / Red).

- Customizable Ballast Curve: Free definition of a Min point (e.g., 3 m/s at empty weight) and a Max point to linearly interpolate weight according to weather conditions.

- CG Optimization Algorithm: Adds slugs bay by bay, choosing at each step the slug that least disturbs the target CG.

- Dynamic Bay Manager: Add, remove, and configure ballast bays (max slugs, unit weight, distance to CG) directly from the radio.

- Multi-Model Management: Clone, create, and delete glider profiles (Freestyler, Jazz, etc.).

- Data Persistence: Automatic configuration backup on the SD card in WIDGETS/ballast/ballast_cfg.txt.

- Touch & Rotary Interface: Smooth page navigation, selection, and direct editing of values with red highlighting.

# 📁 Installation
Download or clone this repository.

Copy the ballast folder into the /WIDGETS/ directory of your SD card:
SD/

└── WIDGETS/

    └── ballast/
    
        ├── main.lua
        └── ballast_cfg.txt
        



<img width="783" height="291" alt="Capture d&#39;écran 2026-08-14 090016" src="https://github.com/user-attachments/assets/55cd2f59-17db-4559-9ee7-56fdbc5b86f7" />
<img width="789" height="288" alt="Capture d&#39;écran 2026-08-14 085956" src="https://github.com/user-attachments/assets/1921c5a3-a529-4c08-b221-ef36ebadea80" />
<img width="788" height="288" alt="Capture d&#39;écran 2026-08-14 090047" src="https://github.com/user-attachments/assets/1616e671-b3a8-42d1-9db6-8fa65b39b8ea" />
<img width="790" height="294" alt="Capture d&#39;écran 2026-08-14 090118" src="https://github.com/user-attachments/assets/cca31580-0871-4616-9142-47b33afd7093" />


