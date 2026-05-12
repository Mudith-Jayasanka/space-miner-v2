# Visuals and Audio

## Art Style
- **Perspective:** 2D Top-Down.
- **Vibe:** Industrial/Sci-fi.

## UI/UX
- **Connection Lines:** Visible lines between buildings to show grid connectivity.
    - **Color Coding:** 
        - Cyan: Powered and healthy.
        - Orange: Low power (Brownout).
        - Red (Dashed/Flickering): No power / Shutdown.

## Power Flow Aesthetics
- **Pulse-Based Illumination (The "Power Surge"):**
    - Standard buildings (Miners) use standard cyan connection lines.
    - **High-Load Events:** When a Pulse building (e.g., Laser Weapon) fires, it triggers a visual "Surge."
    - **Visual Surge:** A bright, thick, glowing animation travels from the power sources along the connection lines to the pulsing building.
    - **Duration:** The illumination lasts only as long as the high-load event (e.g., while the weapon is charging/firing).
- **Source-to-Sink Pathing:** 
    - The surge follows the shortest path back to the primary power source(s) that are satisfying the building's current demand.

## Audio
- **Pulse Sound:** High-energy hum/electrical crackle during a "Power Surge" event.
- **Shutdown:** Low-frequency powered-down sound when a building hits the <20% threshold.
