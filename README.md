# F3F Ballast Manager - EdgeTX Widget
Color and touch-screen widget for EdgeTX radios (TX16S, TX16S MKII, etc.) designed specifically for F3F glider pilots.

It calculates in real-time the optimal loading plan (distribution across ballast bays) based on wind speed, while minimizing Center of Gravity (CG) deviation from your target.

#✨ Main Features
Dynamic Dashboard: Instant visualization of wind speed, calculated target weight, current total weight, and CG deviation with a visual indicator (Green / Red).

- Customizable Ballast Curve: Free definition of a Min point (e.g., 3 m/s at empty weight) and a Max point to linearly interpolate weight according to weather conditions.

- CG Optimization Algorithm: Adds slugs bay by bay, choosing at each step the slug that least disturbs the target CG.

- Dynamic Bay Manager: Add, remove, and configure ballast bays (max slugs, unit weight, distance to CG) directly from the radio.

- Multi-Model Management: Clone, create, and delete glider profiles (Freestyler, Jazz, etc.).

- Data Persistence: Automatic configuration backup on the SD card in /CONFIG/ballast_cfg.txt.

- Touch & Rotary Interface: Smooth page navigation, selection, and direct editing of values with red highlighting.

#📁 Installation
Download or clone this repository.

Copy the ballast folder into the /WIDGETS/ directory of your SD card:
SD/

└── WIDGETS/

    └── ballast/
    
        ├── main.lua
        

Make sure to manually create a folder named CONFIG at the root of your SD card.
While the widget automatically creates and updates the configuration file inside it, it cannot write to the SD card if the CONFIG folder itself is missing.

SD/

├── CONFIG/                 

    └── ballast_cfg.txt     

└── WIDGETS/

    └── ballast/
    
        ├── main.lua
