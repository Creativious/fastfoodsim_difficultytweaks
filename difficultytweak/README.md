# Difficulty Tweaks Mod for Fast Food Simulator

The Difficulty Tweaks Mod for `Fast Food Simulator`, dynamically adjusts various gameplay elements to elevate the game's challenge. It scales customer numbers based on restaurant level and days played, decreases customer patience as more customers are seated and waiting, and adjusts eating duration based on seating. An in-game command system also allows for real-time adjustments.


## Features

- **Dynamic Customer Management**: Adjust the number of customers based on the restaurant level and total days played, ensuring a nightmarish experience.
- **Configurable Settings**: Easily modify the minimum and maximum possible customers via in-game commands or configuration files (json).
- **Adaptive Customer Patience**: The patience of customers will adjust based on the amount of customers seated and waiting, with a slight boost if all tables are full. This ensures that the game is still possible to complete, but still provides a formidable challenge.
- **Dynamic Eating Duration**: Adjust the eating duration of customers based on the amount of customers seated, with a slight boost if all tables are full. This ensures that the game is still possible to complete, but still provides a formidable challenge.
- **In-Game Command System**: Enter commands directly into the game's chat, receive instant feedback, and adjust settings on the fly.

## Commands

- `/set_max_customers <number>`: Set the maximum number of customers. `Default: 500`
- `/set_min_customers <number>`: Set the minimum number of customers. `Default: 25`
- `/set_base_patience_multiplier <number>`: Set the base patience multiplier. `Default: 1.0`
- `/df_reset`: Reset the configuration to default settings.
- `/show_min_customers`: Display the current minimum customers setting.
- `/show_max_customers`: Display the current maximum customers setting.
- `/show_base_patience_multiplier`: Display the current base patience multiplier.
- `/set_max_eating_duration <number>`: Set the maximum eating duration. `Default: 30.0`
- `/set_min_eating_duration <number>`: Set the minimum eating duration. `Default: 15.0`
- `/show_min_eating_duration`: Display the current minimum eating duration setting.
- `/show_max_eating_duration`: Display the current maximum eating duration setting.
- `/set_eating_duration_tweaks <true/false>`: Enable or disable dynamic eating duration adjustments. `Default: true`
- `/show_eating_duration_tweaks`: Display the current status of dynamic eating duration adjustments.
- `/set_patience_tweaks <true/false>`: Enable or disable dynamic patience adjustments. `Default: true`
- `/show_patience_tweaks`: Display the current status of dynamic patience adjustments.
## Installation

1. Download the latest release from the [Releases page](https://github.com/creativious/DifficultyTweaksMod/releases) or from the nexus page (To be linked).
2. Download the latest version of the modloader from the [RE-UE4SS](https://github.com/UE4SS-RE/RE-UE4SS) repository.
3. Copy the contents to the games `\Binaries\Win64` folder, such as `(SteamLibrary)\steamapps\common\Fast Food Simulator\ProjectBakery\Binaries\Win64`
4. Start the game so that the mod loader can generate the required files
5. Extract the mod's zip or 7z file to the mods directory, and suffer through the pain of this mod

## Disclaimer
This mod may be randomly abandoned for no reason (My interests change ig 🤷‍♂️), without notice, or any other changes. USE AT YOUR OWN RISK.


