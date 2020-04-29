# Before you downloading

> This plugin is under the development and very unstable
> 
> CS.as WON'T work properly, your game will crash like nuts if you don't delete it from addon.as
> 
> Yes, most of addons WILL NOT WORK FINE, please don't ask me why

# Death Match

This is a plugin to help Sven Co-op server owner building thier pvp server.

It aims to provide Sven Co-op with a powerful PVP plugin support, so that PVP server owners can easily create a variety of different PVP game modes.

Most basic, with this plugin, you can play HLDM or OFDM map in Sven Co-op without any other editing.

This plugin avoids using the original classification system to assign teams to players, which means you can play the non team deathmatch without worrying that 13 players will crash the whole game or other glitch caused by using the original classification system.

## To use
1. download or clone the zip file to your computer
2. unzip the file, copy pvp directory into svencoop_addon/scripts/plugins
3. add the code below into bottom of svencoop/default_plugins.txt
```
    "plugin"
	{
		"name" pvp
		"script" pvp/Pvp
	}
```
4. save txt and play

## Command
This plugin with a build-in client command system

core commands are here:

| Module        | Command           | Admin | Description                      |
| ------------- | ----------------- | ----- | -------------------------------- |
| ClientCommand | pvp_help          | None  | List all avaliable commands      |
| Addon         | info_listmodule   | None  | List all used addon modules      |
| Config        | admin_setconfig   | Admin | Set config data                  |
| Gamemode      | info_gamemode     | None  | List all avaliable gamemode      |
| Gamemode      | vote_gamemode     | None  | Vote for changing gamemode       |
| Gamemode      | admin_gamemode    | Admin | Admin change gamemode            |
| Hitbox        | admin_showhitbox  | Admin | Show the hitbox model or not     |
| Hitbox        | player_paniccolor | None  | Change the painc indicator color |
| Lang          | player_language   | None  | Change your language             |
| Lang          | info_syslang      | None  | List all avaliable languages     |
| Team          | admin_showtdmicon | Admin | Show the team icon or not        |

# Known Bugs

1. Players will get stuck if they get close too much.
2. No headshot, No part of injuries.
3. Sometime game will crash when changing gamemode.
4. Projectiles will touch the hitbox and explode wrongly.
5. Plugins require better network than ordinary pvp method, because of the syncing of hitbox.
6. Potential memory leaks.


# ToDo

1. Fix known bug.
2. ~~Rewrite the hook method~~
3. Save the player data to a file or files
4. Save the config
5. Improved plugin performance
6. Better addon module
7. Rewrite the command module to realize the unity of client command and server command 
8. Server CVar module
9. An documents for dev


# For dev

Don't do any dev thing for now.

This plugin is under development and very unstable
