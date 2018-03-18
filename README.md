# mpvctl
CLI controlled mpv

## Install

Make sure all dependencies are installed e.g. under ArchLinux:

```
sudo pacman -S mpv socat jq ponymix
```

Once all dependencies are install, clone the git repo to your desired location and setup mpvctl

```
git clone https://github.com/burnoutberni/mpvctl.git
cd mpvctl
./mpv.sh symlink-mpvctl			# Symlink mpv.sh to /usr/bin/mpvctl
./mpv.sh symlink-systemd		# Symlink mpv.service to ~/.config/systemd/user/mpv.service
./mpv.sh enable && ./mpv.sh start	# Enable & start mpv.service
```

## Usage

```
mpvctl – CLI controlled mpv

Usage: mpvctl [arguments]

Arguments:
	-a, add [file]			Play file
	-l, ls, list			List playlist items
	-i, info			Playback information
	-n, next			Jump to next playlist item
	-P, prev			Jump to previous playlist item
	-j, jump [index]		Jump to specified playlist item
	-S, shuffle			Shuffle all playlist items
	-p, pause			Pause/resume playback
	-s, seek [seconds] <options>	Change playback position (+/-)
					<relative|absolute|absolute-percent>
	-r, rm [current|index]		Remove current or specified playlist item
	-m, mv [index1] [index2]	Move playlist item at index1 to index2
	-v, volume <0-100>		Get/set pulseaudio volume
	-vv, volume-mpv <0-130>		Get/set mpv volume
	-o, output <profile>		Get/set pulseaudio output profile
	-a4, add-fm4			Add FM4 livestream to playlist

	start|stop|restart		Use systemctl command on mpv.service
	status|enable|disable

	symlink-mpvctl			Create symlink at /usr/bin/mpvctl
	symlink-systemd			Create symlink at ~/.config/systemd/user/mpv.service
```

## About

This project is licensed under the GNU General Public License v3.0 (see LICENSE) by [Bernhard Hayden](https://github.com/burnoutberni).


