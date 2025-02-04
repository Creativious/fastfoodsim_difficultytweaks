# Difficulty Tweaks Mod for Fast Food Simulator

The Difficulty Tweaks Mod for `Fast Food Simulator`, dynamically adjusts various gameplay elements to elevate the game's challenge. It scales customer numbers based on restaurant level and days played, decreases customer patience as more customers are seated and waiting, and adjusts eating duration based on seating. An in-game command system also allows for real-time adjustments.


## Features

- **Dynamic Customer Management**: Adjust the number of customers based on the restaurant level and total days played, ensuring a nightmarish experience.
- **Configurable Settings**: Easily modify the minimum and maximum possible customers via in-game commands or configuration files (json).
- **Adaptive Customer Patience**: The patience of customers will adjust based on the amount of customers seated and waiting, with a slight boost if all tables are full. This ensures that the game is still possible to complete, but still provides a formidable challenge.
- **Dynamic Eating Duration**: Adjust the eating duration of customers based on the amount of customers seated, with a slight boost if all tables are full. This ensures that the game is still possible to complete, but still provides a formidable challenge.
- **In-Game Command System**: Enter commands directly into the game's chat, receive instant feedback, and adjust settings on the fly.

## Commands
Commands that can set a value, can also show a value by leaving the argument blank
- `/max_customers <number>`  `Default: 500`  Sets|Shows the maximum amount of customers that can be in the restaurant at any given time.
- `/min_customers <number>`  `Default: 25`  Sets|Shows the minimum amount of customers that can be in the restaurant at any given time.
- `/base_patience_multiplier <number>`  `Default: 1.0` Sets|Shows the base patience multiplier.
- `/max_eating_duration <number>` `Default: 30.0` Set the maximum eating duration.
- `/min_eating_duration <number>` `Default: 15.0` Set the minimum eating duration.
- `/eating_duration_tweaks <true/false>` `Default: true` Toggle|Display eating duration tweaks.
- `/patience_tweaks <true/false>` `Default: true` Toggle|Display whether or not the patience tweaks are enabled.

- `/df_reset`: Reset the configuration to default settings.
## Installation

1. Download the latest release from the [Releases page](https://github.com/Creativious/fastfoodsim_difficultytweaks/releases) or from the nexus page (To be linked).
2. Download the latest version of the modloader from the [RE-UE4SS](https://github.com/UE4SS-RE/RE-UE4SS) repository.
3. Copy the contents to the games `\Binaries\Win64` folder, such as `(SteamLibrary)\steamapps\common\Fast Food Simulator\ProjectBakery\Binaries\Win64`
4. Start the game so that the mod loader can generate the required files
5. Extract the mod's zip or 7z file to the mods directory, and suffer through the pain of this mod

## Disclaimer
This mod may be randomly abandoned for no reason (My interests change ig 🤷‍♂️), without notice, or any other changes. USE AT YOUR OWN RISK.


