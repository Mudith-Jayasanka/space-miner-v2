# Gameplay Mechanics

## Core Loop
1. Survey Level for Asteroids
2. Place Core (Initial State)
3. Expand Power Grid using Transmission Nodes
4. Place Miners to Extract Resources
5. Advance to Next Level

## Level Structure
- The game is level-based.
- Each level contains static "Asteroids" at set locations.
- Asteroids contain a fixed amount of resources; larger asteroids contain more resources.

## Building System
- Buildings can be placed anywhere on the map.
- **Collision Rule:** A building cannot be placed if it intersects with an existing object (asteroids or other buildings).

### Building Types (MVP)

#### 1. Core
- The starting building of every level.
- **Power Production:** 100 units/second (fixed).
- **Power Range:** 150 units for transmission to nearby nodes or buildings.

#### 2. Miner
- Extracts resources from asteroids.
- **Power Consumption:** 20 units/second.
- **Mining Range:** 100 units. It picks one asteroid within this range and begins extraction.
- **Requirement:** Must be within the power transmission range of a Core or Transmission Node to operate.

#### 3. Power Transmitter (Transmission Node)
- Extends the reach of the power grid.
- **Power Consumption:** 0 units/second (Passive).
- **Transmission Distance:** 200 units. It connects to power sources (Core or other Nodes) within this range.
- Provides power to power-consuming buildings (like Miners) within its transmission range.

## Resource System (MVP)

### Asteroids
- **Type:** Iron (Only one type for MVP).
- **Behavior:** Static locations, vary in size.
- **Capacity:** Larger asteroids contain more Iron.

### Power Sources
- **Core:** The primary, high-output power source.
- **Solar Panels / Generators:** Additional buildings that can be placed to increase the grid's total capacity.
- **Connectivity:** Sources must be connected to the grid (directly or via Transmission Nodes) to contribute to the global power pool.

### Grid Fragmentation & Sub-Grids
The network is not a single entity but a collection of **Grids**.
- **The Main Grid:** Any cluster of buildings connected to the **Core**. The UI "Total Power" indicator reflects this grid.
- **Sub-Grids:** If a connection is destroyed, any cluster of buildings containing at least one power source (e.g., a Solar Panel) becomes a self-sustaining Sub-Grid.
- **Independent Operation:** Sub-grids follow the exact same "Edge-Starvation" rules as the Main Grid, using their local sources to satisfy their local demand.
- **Isolation:** Buildings with no connection to any power source (Core, Solar, or Generator) will deactivate immediately.

### Power Consumption Types
- **Steady-State:** Buildings like Miners that consume a constant amount of power. These do not trigger special visual effects under normal operation.
- **High-Load Pulse:** Specialized buildings (e.g., Laser Weapons, Heavy Industrial Tools) that consume massive amounts of power in short bursts or pulses.
- **Power Surges:** When a Pulse building activates, it draws power from the network, causing a visual "surge" through the transmission lines back to the source.
- **Full Speed:** If a building receives 100% of its required power, it operates at 100% efficiency.
- **Reduced Efficiency:** If supply is insufficient, buildings at the "edges" of the grid (furthest from the Core) receive partial power, reducing their operational speed proportionally.
- **Deactivation Threshold:** If a building's power satisfaction drops below **20%**, it will automatically deactivate (shutdown) to protect the grid. It will remain inactive until the grid can provide at least 20% power again.
