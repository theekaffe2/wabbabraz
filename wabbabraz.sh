#!/bin/bash
#set -v -x	
set -e

if [ ! -d "$HOME"/_output/ ]; then
	mkdir "$HOME"/_output
fi
curdir=$(pwd)
dumb=("Amateur" "Ballerina" "Woman.20-29" "Big.Tits.Worship" "Browse By Categories" "Tags")


curlstuff ()
{
txtname=$(basename "$*")
curl -b "$curdir/cookies.txt" -L "$*" -o /tmp/"$txtname".txt

## Get file name
URLActors=$(sed -n -e '/scene-page/,/scene-nav-tab/ p' ""/tmp/$txtname.txt"")
URLActors=$(echo -n "$URLActors" | grep -Po '">\K.*?(?=</)') # |sed ':a;N;$!ba;s/\n/, /g')

OIFS=$IFS
IFS=$'\n'
for name in $URLActors; do
	echo "$name"
	ATags+=($(echo "$name" | tr " " .))
	read -p "Should "$name" be in title?" -n 1 -r
	echo ""
		if [[ $REPLY =~ ^[Yy]$ ]]; then
			if [[ "$Actors" == "" ]]; then
			Actors="$name"
			else
			Actors="$Actors, $name"
			fi
		fi
done
IFS=$OIFS
Title=$(grep -E "scene-page" ""/tmp/$txtname.txt"")
Title=$(echo -n "$Title" | awk -F "<" '{ print $1 }' | sed -e 's/^[[:space:]]*//'| sed -e 's/[[:space:]]*$//'|sed ':a;N;$!ba;s/\n/, /g'| sed -e 's/^,*//'| sed -e 's/,[[:space:]],[[:space:]],[[:space:]]*$//')
echo "$Title"
Site=$(grep -m 1 -E "label-text" ""/tmp/$txtname.txt"")
Site=$(echo -n "$Site" | awk -F "[<>]" '{ print $3 }')
Site=$(echo -n "$Site" | tr -d '[:space:]')
echo "$Site"
Date=$(grep -m 1 -E "<time>" ""/tmp/$txtname.txt"")
Date=$(echo -n "$Date" | awk -F "[<>]" '{ print $3 }')
echo "$Date"
Filename="[$Site] $Actors - $Title ($Date)"
Filename="${Filename//:}"
echo "$Filename"
Title2="$Title"2
## Get description and tags.
Description=$(sed -n -e '/description-tags-placeholder/,/<\/p>/ p' ""/tmp/$txtname.txt"")
Description=$(echo -n "$Description" | grep -m 1 -E "<\/p>")
Description=$(echo -n "$Description" | awk -F "[<>]" '{ print $1 }' | sed -e 's/^[[:space:]]*//' | sed -e 's/[[:space:]]*$//')
Description="$Site Description \n [i]$Description[/i]"
echo "$Description"



URLTags=$(sed -n -e '/ <span>Tags/,/<\/div>/ p' ""/tmp/$txtname.txt"")
Tags=$(echo "$URLTags" | grep -E "href")
Tags=$(echo "$Tags" | awk -F "[<>]" '{ print $3 }'| sed -e 's/^[[:space:]]*//' | sed '/^$/d' | sed -e 's/[[:space:]]*$//'|sed ':a;N;$!ba;s/\n/, /g'| sed -e 's/^,*//'| sed -e 's/,[[:space:]],[[:space:]],[[:space:]]*$//')
Tags=$(echo "$Tags" | sed 's/Browse by Categories, //g')
Tags="Sex acts and tags: $Tags"

URLTags=$(echo "$URLTags" | grep -E "href")
URLTags=$(echo "$URLTags" | awk -F "[<>]" '{ print $3 }'| sed -e 's/^[[:space:]]*//'| sed -e 's/[[:space:]]*$//'| sed -e 's/^,*//'| sed -e 's/,[[:space:]],[[:space:]],[[:space:]]*$//')
URLTags=$(echo "$URLTags" |  sed '/^$/d' )

OIFS=$IFS
IFS=$'\n'
for tag in $URLTags; do
	ATags+=("$tag")
done
IFS=$OIFS

timetags=$(grep -E "timelineData" ""/tmp/$txtname.txt"")
if [ "$timetags" ]; then
	timetags=$(echo -n "$timetags" | grep -Po '"tag_name":"\K.*?(?=","tag_times")')
	OIFS=$IFS
	IFS=$'\n'
	for tag in $timetags; do
		ATags+=("$tag")
	done
	IFS=$OIFS
	echo "$timetags"
fi
for (( i = 0 ; i < ${#ATags[@]} ; i++ )); do
	ATags[$i]=$(echo "${ATags[$i]}" | sed 's/ -//g')
	ATags[$i]=$(echo "${ATags[$i]}" | sed 's/(//g')
	ATags[$i]=$(echo "${ATags[$i]}" | sed 's/)//g')
	ATags[$i]=$(echo "${ATags[$i]}" | sed 's,/ ,,g')
	ATags[$i]=$(echo "${ATags[$i]}" | tr " " .)
done
ATags+=("brazzers.com")
ATags+=("$Site.com")
ATags+=("mp4")
ATags+=("se7enseas")

for dummy in "${dumb[@]}"; do
  for (( i = 0 ; i < ${#ATags[@]} ; i++ )); do
    if [[ ${ATags[i]} = "$dummy" ]]; then
      unset "ATags[$i]"
    fi
	if [[ ${ATags[i]} = Fit.Athletic ]]; then
		ATags[$i]=athletic.body
	fi
	if [[ ${ATags[i]} = "2.on.1.2.Males" ]]; then
		ATags[$i]=mmf
	fi
	if [[ ${ATags[i]} = Big.Boobs.Implants ]]; then
		ATags[$i]=big.fake.tits
	fi
	if [[ ${ATags[i]} = Big.Boobs.Natural ]]; then
		ATags[$i]=big.natural.tits
	fi
	if [[ ${ATags[i]} = Group.Sex.4+ ]]; then
		ATags[$i]=group
	fi
	if [[ ${ATags[i]} = Mature.30+ ]]; then
		ATags[$i]=mature
	fi
	if [[ ${ATags[i]} = Teen.18-19 ]]; then
		ATags[$i]=teen
	fi
	if [[ ${ATags[i]} = Finger.Banging ]]; then
		ATags[$i]=fingering
	fi
	if [[ ${ATags[i]} = Sex ]]; then
		ATags[$i]=hardcore
	fi
	if [[ ${ATags[i]} = "threesome.2.females" ]]; then
		ATags[$i]=ffm
	fi
  done
done

echo "$Tags"
echo "${ATags[@]}"
array2=($(printf "%s\n" "${ATags[@]}" | sort -u));
finaltags="${array2[@]}"
echo "$finaltags"



downloadvids ()
{

## Download videos
DownloadLinks=$(awk -F[\"] '/\/download\// {print $2}' ""/tmp/$txtname.txt"" )
echo "$DownloadLinks"
def1=$(echo "$DownloadLinks" | awk  'FNR==1 {print $0}')
def2=$(echo "$DownloadLinks" | awk  'FNR==2 {print $0}')
def3=$(echo "$DownloadLinks" | awk  'FNR==3 {print $0}')
def1="https://ma.brazzers.com$def1"
def2="https://ma.brazzers.com$def2"
def3="https://ma.brazzers.com$def3"
echo "$def1"
echo "$def2"
echo "$def3"

if [ -z "$Title" ]; then
	exit
fi

if [ -f "$curdir/$Filename 480p.mp4" ]; then
   echo "File $curdir/$Filename 480p.mp4 exists."
else
   echo "Downloading $Filename 480p.mp4"
   curl -b "$curdir/cookies.txt" -L "$def3" -o "$curdir/$Filename 480p.mp4"
fi
if [ -f "$curdir/$Filename 720p.mp4" ]; then
   echo "File $curdir/$Filename 720p.mp4 exists."
else
   echo "Downloading $Filename 720p.mp4"
   curl -b "$curdir/cookies.txt" -L "$def2" -o "$curdir/$Filename 720p.mp4"
fi
if [ -f "$curdir/$Filename 1080p.mp4" ]; then
   echo "File $curdir/$Filename 1080p.mp4 exists."
else
   echo "Downloading $Filename 1080p.mp4"
   curl -b "$curdir/cookies.txt" -L "$def1" -o "$curdir/$Filename 1080p.mp4"
fi

ivideo+=("$curdir/$Filename 480p.mp4")
ivideo+=("$curdir/$Filename 720p.mp4")
ivideo+=("$curdir/$Filename 1080p.mp4")
}

downloadvids

texts+=("$Description")
texts+=("$Tags")
}

echo "Curl Stuff"

while getopts ":i:a:" opt; do
	case $opt in
		i)
			echo "adding $0 to bashrc as \"makegif\""
			sdir=$(readlink -f "$0")
			echo "alias makegif='$sdir'" >> ~/.bashrc
			echo "Installing mtn"
			if [ ! -f ~/.mtn/mtn ]; then
			mkdir ~/.mtn
			cd ~/.mtn
			wget -O mtn.tgz http://sourceforge.net/projects/moviethumbnail/files/movie%20thumbnailer%20linux%20binary/mtn-200808a-linux/mtn-200808a-linux.tgz/download
			tar xzf mtn.tgz
			mv mtn-*/mtn .
			chmod +x mtn
			rm -rf mtn-* mtn.tgz
			wget -O font.tar.gz https://releases.pagure.org/liberation-fonts/liberation-fonts-ttf-2.00.1.tar.gz
			tar xzf font.tar.gz
			mv liberation-*/*.ttf .
			rm -rf liberation-*/
			else
			echo "mtn was found at ~/.mtn/mtn"
			fi
			
			echo "Isntalling python3"
			if command -v python3.6 2>/dev/null 
				then
					echo "python3.6 is already installed"
				else 
					wget https://www.python.org/ftp/python/3.6.2/Python-3.6.2.tar.xz && \
					tar xJf ./Python-3.6.2.tar.xz && \
					cd ./Python-3.6.2 && \
					./configure --prefix=$HOME && make && make install 
					# Configure environment
					grep -q "export PATH" ~/.bashrc
					if [[ $? -eq 1 ]]; then
						echo 'export PATH=$PATH:$HOME/bin' >> ~/.bashrc
					else
						grep 'export PATH' ~/.bashrc | grep -q '$HOME'
						if [[ $? -eq 1 ]]; then
							sed -i -e 's/PATH=/PATH=$HOME\/bin:/g' ~/.bashrc
						fi
					fi
					# Cleanup
				cd ..
				rm -rf ./Python-3.6.2
				rm -f ./Python-3.6.2.tar.xz
			fi
			echo "Installing emptorrentify"
			wget https://server428.seedhost.eu/alucard/upping/emptorrentify.zip && \
			unzip emptorrentify.zip && \
			mv emptorrentify/* ~/bin/ && \
			rm -rf emptorrentify && \
			rm -f emptorrentify.zip
			grep -q emptorrentify ~/.bashrc
			if [[ $? -eq 1 ]]; then
				echo alias emptorrent=\'~/usr/local/lib/python3.4 ~/lib/emptorrentify.py\' >> ~/.bashrc
			fi
			read -p "Please input your announce key and hit return: " key
			sed -i -e "s/\/announce/\/$key\/announce/g" ~/bin/py3createemptorrent.py
			sed -i -e "s/\/announce/\/$key\/announce/g" ~/bin/py3createtorrent.py
			
			echo "alias mtns='mkdir -p Screens && ~/.mtn/mtn -n -w 1600 -c 4 -D 6 -b 0.6 -r 6 -j 95 -k 00008b -F FFFFFF:12 -f ~/.mtn/DroidSans-Bold.ttf -O Screens'" >> ~/.bashrc
			echo "alias mtnf='mkdir -p Screens && ~/.mtn/mtn -n -I -w 0 -c 1 -j 95 -D 12 -f ~/.mtn/DroidSans-Bold.ttf -O Screens'" >> ~/.bashrc
			echo "alias mtnq='mkdir -p Screens && ~/.mtn/mtn -f ~/.mtn/DroidSans-Bold.ttf -n -s 10 -c 3 -D 6 -b 0.6 -h 100 -r 15 -w 1600 -D7 -b 1 -L 4:1 -j 90 -k 00008b -F FFFFFF:12 -o -empblue.jpg -O Screens'" >> ~/.bashrc
			echo "Done with install"
			exit
			;;
		 a)
     		curlstuff "$3"
			time=$OPTARG
			echo "Making Gifs"
	  		name=$(basename "${ivideo[0]}")
	  		mkdir /tmp/grabs2
	  		ffmpeg -v error -ss "$time" -t 2 -i "${ivideo[0]}" -r 15 -vf "scale=400:-1" /tmp/grabs2/out%03d.png
	  		ffmpeg -v error -i /tmp/grabs2/out%3d.png -vf palettegen /tmp/grabs2/palette.png
	  		ffmpeg -v error -r 15 -i /tmp/grabs2/out%3d.png -i /tmp/grabs2/palette.png -filter_complex paletteuse=floyd_steinberg -loop 0 "$name".gif	  
      		rm -rf /tmp/grabs2
	  		echo "Done"
	  		echo "Making text file"
	  		;;
		\?)
			echo "Invalid option: -"$OPTARG""
			exit
			;;
	esac
done





if [ -z "$time" ]; then
	curlstuff "$1"
fi

echo "Making torrent"
for i in "${ivideo[@]}"; do
	python3 "$HOME"/bin/py3createemptorrent.py -p 16000 -o "$HOME"/_output "$i"
done
echo "Done with Torrent"
echo "Making Screens"
for i in "${ivideo[@]}"; do
	echo "Making screen for $i"
	~/.mtn/mtn -f ~/.mtn/DroidSans-Bold.ttf -n -s 10 -c 3 -D 6 -b 0.6 -h 100 -r 15 -w 1600 -L 4:1 -j 90 -k 00008b -F FFFFFF:12 -o -empblue.jpg -O "$HOME"/_output/ "$i"
done
echo "Done with Screens"
echo "Making text file"
echo "${texts[@]}" >> info.txt
echo "$finaltags" >> info.txt
mediainfo "$1" >> info.txt
echo "Done"
echo "Moving Files"
mv "$curdir"/*.torrent "$HOME"/_output/
mv "$curdir"/*.txt "$HOME"/_output/
mv "$curdir"/*.gif "$HOME"/_output/
echo "Done with moving files"
