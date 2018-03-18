#! /bin/sh

mpvCommand () {
	echo '{ "command": ['$1'] }' | socat - /tmp/mpv.socket | jq -r "$2"  
}


option="${1}"
case ${option} in
	"-a"|"add") file="${2}"
		#title="`youtube-dl -e ${2}`"
		#echo $title
		mpvCommand '"loadfile", "'$file'", "append-play"' '.error'
		;;
	"-a4"|"add-fm4")
		mpvCommand '"loadfile", "http://mp3fm4.apasf.sf.apa.at/", "append-play"' '.error'
		;;


	"-l"|"ls"|"list") paused=`mpvCommand '"get_property", "pause"' '.data'`
		mpvCommand '"get_property", "playlist"' '.data | [.[]] | try map({current: .current, filename: .filename, title: .title, "media-title": ."media-title" }) | (map(keys) | add | unique) as $cols | map(. as $row | $cols | map($row[.])) as $rows | $rows[] | @tsv ' | if [ $paused = true ]; then sed 's/true/paused/g'; else sed 's/true/playing/g'; fi | nl -v 0 -w 4 -
		# mpvCommand '"get_property", "playlist"' '.data | [.[]] | flatten | (map(keys) | add | unique) as $cols | map(. as $row | $cols | map($row[.])) as $rows | $rows[] | @tsv ' | if [ $paused = true ]; then sed 's/true/paused/g'; else sed 's/true/playing/g'; fi | nl -v 0 -w 4 -
		;;
	"-i"|"info")
		file_path=`mpvCommand '"get_property", "path"' '.data'`
		if [ $file_path ]; then	
			paused=`mpvCommand '"get_property", "pause"' '.data'`
			media_title=`mpvCommand '"get_property", "media-title"' '.data'`
			percent_pos=`mpvCommand '"get_property", "percent-pos"' '.data' | xargs printf "%.*f\n" 2`
			time_pos=`mpvCommand '"get_property", "time-pos"' '.data' | xargs -I seconds date -u +"%T" -d @seconds`
			duration=`mpvCommand '"get_property", "duration"' '.data' | xargs -I seconds date -u +"%T" -d @seconds`
			mpv_volume=`mpvCommand '"get_property", "volume"' '.data'`
			pulse_volume=`ponymix get-volume`

			if [ "$file_path" != "$media_title" ]; then
				echo "Title: $media_title"
			fi;

			echo "File: $file_path"
			echo "Volume: mpv $mpv_volume% / pulseaudio $pulse_volume%"
			echo ""

			if [ $paused = true ]; then
				echo "  (paused)   $time_pos / $duration		$percent_pos%"
			else
				echo "  (playing)  $time_pos / $duration		$percent_pos%"
			fi;
		else
			echo "Currently no item selected for playback"
		fi;
		;;
	"-n"|"next")
		mpvCommand '"playlist-next"' '.error'
		;;
	"-P"|"prev")
		mpvCommand '"playlist-prev"' '.error'
		;;
	"-j"|"jump") jump="${2}"
		mpvCommand '"set_property", "playlist-pos", '$jump '.error'
		;;
	"-S"|"shuffle")
		mpvCommand '"playlist-shuffle"' '.error'
		;;
	"-p"|"pause")
		mpvCommand '"cycle", "pause"' '.error'
		;;
	"-s"|"seek") seek="${2}"; options="${3}"
		mpvCommand '"seek", '$(($seek))', "'$options'"' '.error'
		;;
	"-r"|"rm") key="${2}"
		mpvCommand '"playlist-remove", "'$key'"' '.error'
		;;
	"-m"|"mv") index1="${2}" index2="${3}"
		if [ $index1 -lt $index2 ]; then index2=$((index2+1)); fi
		mpvCommand '"playlist-move", "'$index1'", "'$index2'"' '.error'
		;;


	"-v"|"volume") volume="${2}"
		if [ $volume ]; then
			ponymix set-volume $volume
		else
			ponymix get-volume
		fi
		;;
	"-o"|"output") output="${2}"
		if [ $output ]; then
			ponymix set-profile output:$output
		else
			ponymix list-profiles
		fi
		;;
	"-vv"|"volume-mpv") volume="${2}"
		if [ $volume ]; then
			mpvCommand '"set_property", "volume", '$volume '.error'
		else
			mpvCommand '"get_property", "volume"' '.data'
		fi
		;;


	"start"|"stop"|"restart"|"status"|"enable"|"disable")
		systemctl --user $option mpv
		;;

	"symlink-mpvctl")
		sudo ln -s `readlink -f "${0}"` /usr/bin/mpvctl
		;;
	"symlink-systemd")
		ln -s `readlink -f "${0}" | sed 's/mpv.sh/mpv.service/'` ~/.config/systemd/user/mpv.service
		;;


	*)
		basename=`basename ${0}`
		echo "$basename – CLI controlled mpv"
		echo ""
		echo "Usage: $basename [arguments]"
	      	echo ""
		echo "Arguments:"
		echo "	-a, add [file]			Play file"
		echo "	-l, ls, list			List playlist items"
		echo "	-i, info			Playback information"
		echo "	-n, next			Jump to next playlist item"
		echo "	-P, prev			Jump to previous playlist item"
		echo "	-j, jump [index]		Jump to specified playlist item"
		echo "	-S, shuffle			Shuffle all playlist items"
		echo "	-p, pause			Pause/resume playback"
		echo "	-s, seek [seconds] <options>	Change playback position (+/-)"
		echo "					<relative|absolute|absolute-percent>"
		echo "	-r, rm [current|index]		Remove current or specified playlist item"
		echo "	-m, mv [index1] [index2]	Move playlist item at index1 to index2"
		echo "	-v, volume <0-100>		Get/set pulseaudio volume"
		echo "	-vv, volume-mpv <0-130>		Get/set mpv volume"
		echo "	-o, output <profile>		Get/set pulseaudio output profile"
		echo "	-a4, add-fm4			Add FM4 livestream to playlist"
		echo ""
		echo "	start|stop|restart		Use systemctl command on mpv.service"
		echo "	status|enable|disable"
		echo ""
		echo "	symlink-mpvctl			Create symlink at /usr/bin/mpvctl"
		echo "	symlink-systemd			Create symlink at ~/.config/systemd/user/mpv.service"
		exit 1
		;;
esac
