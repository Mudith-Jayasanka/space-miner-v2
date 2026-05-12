# Technical Specification

## Engine
Godot Engine 4.2.2

## Architectural Principles

### 1. Signal-Driven Communication
To maintain decoupling, the project uses a tiered signal system:
- **Global Event Bus (`GameEvents.gd` Autoload):** For system-wide events (e.g., `iron_collected`, `grid_updated`).
- **Component Signals:** For internal building logic (e.g., a `PowerReceiver` notifying its parent `Miner` of efficiency changes).
- **Manager Signals:** The `GridManager` emits signals like `surge_visual_requested(path)` for visual feedback.

### 2. Component-Based Design
Buildings are composed of modular "Component" nodes:
- `PowerReceiver`: Handles power intake and deactivation logic.
- `PowerSource`: Handles power contribution logic (used by Core).
- `HealthComponent`: Manages durability and destruction.
- `ResourceExtractor`: Handles mining timers and Iron asteroid interaction.

## Core Systems

### Power Grid Logic
- **Graph Representation:** Undirected graph managed by `GridManager`.
- **Distribution:** Multi-source BFS with parent-tracking for pathing.
- **Island Detection:** Handles disconnected sub-grids.

### Resource System (MVP)
- **Collection:** `Miner` -> `ResourceExtractor` -> `GameEvents.iron_collected`.
- **Storage:** `ResourceManager` (Autoload) tracks total Iron.

## Project Structure
```text
res://
├── autoloads/
│   ├── GameEvents.gd
│   └── ResourceManager.gd
├── systems/
│   ├── grid/
│   └── levels/
├── components/
│   ├── PowerReceiver.tscn
│   ├── PowerSource.tscn
│   └── HealthComponent.tscn
├── buildings/
│   ├── core/
│   ├── miner/
│   └── power_transmitter/
├── entities/
│   └── asteroid/
├── ui/
└── assets/
```
