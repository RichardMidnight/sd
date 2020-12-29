#!/bin/bash

# by Richard Reed 2018 - 2020
SD_VER=1.5

# references
# https://www.raspberrypi.org/documentation/installation/installing-images/linux.md
# https://www.instructables.com/id/How-to-BackUp-and-Shrink-Your-Raspberry-Pi-Image/

#echo empty the /root/.local/share/Trash folders to free up room


CURRENT_DIR="$(pwd)"
SCRIPTNAME="${0##*/}"
MYNAME="${SCRIPTNAME%.*}"



WHITE='\033[1;37m'
RED='\033[1;31m'
NC='\033[0m' 		# No Color, standard text
echo_white()        { (echo -e "${WHITE}$*${NC}") }
echo_red()          { (echo -e "${RED}$*${NC}") }



help() {

    echo "Raspberry pi image-file reader-writer ver $SD_VER (2020)."
    echo "This will  read an SD card to an image file"
    echo "or         write an image file to an SD card"
    echo
    echo "Supports .img .zip and .xz files"
    echo "Defaults to .zip if no extension is specified"

    #echo It will run dd, then pishrink, then zip to create a zipped image file of the SD card
    echo
    echo "Usage: "
    echo "sd install         (to install this into /usr/local/bin)"
    echo "sd list            (to list sd devices and image files)"
    echo "sd write [file] [device]"
    echo "sd read [device] [file]"
    echo
    echo "Examples:"
    echo sd read sda newimage
    echo sd read sdb newimage.xz
    echo sd write newimage.zip sda
    echo
}



sd_size() {
    #get parameters
    INDEV=$1
    lsblk /dev/$INDEV -d -n -o size
}



sd_size_bytes() {
    #get parameters
    INDEV=$1
    lsblk /dev/$INDEV -d -n -b -o size
}



image_size() {
    #get parameters
    INFILE=$1
    
    case $(file_ext $INFILE) in
        img)
            ls -s -h $INFILE | cut -d' ' -f1
        ;;
        
        zip)
            echo $(( $(zipinfo -t $INFILE | cut -d, -f2 | cut -d" " -f2) / 1024 / 1024 )) MB
        ;;
        
        xz)
            xz -l $INFILE | grep -v Strms | cut -c28-40
        ;;    
    esac
}



image_size_bytes() {
    #get parameters
    INFILE=$1
    
    case $(file_ext $INFILE) in
        img)
            echo $((  $(ls -s $INFILE | cut -d' ' -f1) * 1024 )) 
        ;;
        
        zip)
            zipinfo -t $INFILE | cut -d, -f2 | cut -d" " -f2
        ;;
        
        xz)
            xz -l -v $INFILE | grep Uncompressed | cut -d' ' -f8 | cut -d"(" -f2 | sed -e 's/,//g'
        ;;    
    esac
}    



freespace() {
    echo $(df . -h --output=avail | grep -v Avail)
}    

freespace_bytes() {
    echo $(df . -B1 --output=avail | grep -v Avail)
}    



file_base() {
    fullfilename=$1
    filename=$(basename "$fullfilename")
    fname="${filename%.*}"
    echo $fname
}



file_ext() {
    fullfilename=$1
    filename=$(basename "$fullfilename")
    ext="${filename##*.}"
    if [ $ext == $(file_base $filename) ]; then
      ext=""
    fi
    echo $ext
}







get_tools() {
    # Install PiShrink if needed
    if [ ! -f /usr/local/bin/pishrink.sh ]; then
        echo Installing pishrink...
        wget https://raw.githubusercontent.com/Drewsif/PiShrink/master/pishrink.sh
        chmod +x pishrink.sh
        sudo mv pishrink.sh /usr/local/bin
        echo pishrink installed.
    fi

    # get zip if needed
    if [ ! -f /usr/bin/zip ]; then
        echo_white Installing zip...
        sudo apt install zip -y
    fi
    
    # get xz if needed
    if [ ! -f /usr/bin/xz ]; then
        echo_white Installing xz-utils...
        sudo apt install xz-utils -y
    fi
}    




read_sd(){
    #get parameters
    INDEV=$1
    OUTFILE=$2
    OUTFILE_BASE=$(file_base $OUTFILE)
    OUTFILE_EXT=$(file_ext $OUTFILE)
    
    echo_white Read SD card


    # get INDEV
    while [ -z "$INDEV" ] || [ ! -e "/dev/$INDEV" ] ; do
        echo_red /dev/$INDEV not found.
        echo available devices are:
        lsblk -d -n -l -o NAME,VENDOR,MODEL,SIZE /dev/sd? 
        echo "enter device (eg: sda)"
        read INDEV
    done


    # warning if sd is larger than 16GB
    if (( $(sd_size_bytes $INDEV) > 16000000000 )); then
        echo_red WARNING... $INDEV is $(sd_size $INDEV).   SD card is larger than 16GB, use a smaller SD card if you can. 
    fi
    
    
    # error if there is not enough space on current drive
    if (( $(sd_size_bytes $INDEV) > $(freespace_bytes) )); then
        echo_red ERROR... not enough free space on drive to create an image file.
        echo "SD size                      = $(sd_size $INDEV)"
        echo "Free space in current folder = $(freespace)"
        return
    fi
    
    
    # add .zip if no file extension
    if [ ! -z "$OUTFILE" ] && [ -z "$OUTFILE_EXT" ]; then
        echo Adding .zip extension...
        OUTFILE=$OUTFILE.zip
        OUTFILE_BASE=$(file_base $OUTFILE)
        OUTFILE_EXT=$(file_ext $OUTFILE)
    fi


    # get OUTFILE
    while [ -z "$OUTFILE" ] || [ -f "$OUTFILE" ] || [ -f "$OUTFILE_BASE.img" ]; do
        if [ -f "$OUTFILE" ] ; then
            echo_red $OUTFILE exists
        fi
        
        if [ -f "$OUTFILE_BASE.img" ] ; then
            echo_red $OUTFILE_BASE.img exists
        fi
        
        echo "Enter out file (eg: 2020-04-29-buster)"
        read OUTFILE
    done


    # add .zip if no file extension
    if [ ! -z "$OUTFILE" ] && [ -z "$OUTFILE_EXT" ]; then
        echo Adding .zip extension...
        OUTFILE=$OUTFILE.zip
        OUTFILE_BASE=$(file_base $OUTFILE)
        OUTFILE_EXT=$(file_ext $OUTFILE)
    fi


    echo
    #echo 1 - sudo dd bs=4M if=/dev/$INDEV of=$OUTFILE.img status=progress conv=fsync 
    #echo 2 - sudo pishrink.sh $OUTFILE.img
    #echo 3 - zip -db -dd -m $OUTFILE.zip $OUTFILE.img

    #echo Create image file $OUTFILE.zip from $INDEV
    read -p "Create image file $OUTFILE from /dev/$INDEV [y,N] ? " -n 1 -r RESULT
    echo

    if [ $RESULT == "y" ]; then
        TIME1=$(date +%s)
        echo
        echo
        echo_white Step 1 - Reading SD card to $OUTFILE_BASE.img ...
        date
        echo $(sd_size $INDEV ) to read
        sudo dd bs=4M if=/dev/$INDEV of=$OUTFILE_BASE.img status=progress conv=fsync 
        sleep 5s
        echo Done reading SD card
        echo_white $(ls -s -h $OUTFILE_BASE.img)
        echo_white Step 1 took $(($(($(date +%s)-TIME1))/60)) min

        TIME2=$(date +%s)
        echo
        echo_white Step 2 - Shrinking filesystem with PiShrink ...
        sudo pishrink.sh $OUTFILE_BASE.img
        echo Done shrinking filesystem
        echo_white $(ls -s -h $OUTFILE_BASE.img)
        echo_white  Step 2 took $(($(($(date +%s)-TIME2))/60)) min

        TIME3=$(date +%s)
        echo
        echo_white Step 3 - Compressing $OUTFILE_BASE.img to $OUTFILE ...
       
        case $(file_ext $OUTFILE) in
            img)
                echo not compressing .img file ...
            ;;
            
            zip)
                 zip -db -dd -m $OUTFILE_BASE.zip $OUTFILE_BASE.img
            ;;
            
            xz)
                xz -z -v -T0 -0 $OUTFILE_BASE.img
                mv $OUTFILE_BASE.img.xz $OUTFILE_BASE.xz
            ;;
            
            *)
                echo_red ERROR... unsupported file extension.
            ;;
        esac
       
        echo Done compressing $OUTFILE_BASE.img to $OUTFILE
        echo_white $(ls -s -h $OUTFILE)
        echo_white  Step 3 took $(($(($(date +%s)-TIME3))/60)) min

        echo
        echo_white Total time $(($(($(date +%s)-TIME1))/60)) min
        echo_white  You can remove the SD card in /dev/$INDEV now
    fi  
}  



write_sd() {
    #get parameters
    INFILE=$1
    OUTDEV=$2
    echo_white Write SD card
    
    
    # get INFILE
    while [ ! -f "$INFILE" ] ; do
        echo_red $INFILE does not exist
        echo "Enter in file with ext: (eg: 2020-04-29-buster.img)"
        read INFILE
    done
    
    
    # get OUTDEV
    while [ -z "$OUTDEV" ] || [ ! -e "/dev/$OUTDEV" ] ; do
        echo_red /dev/$OUTDEV not found.
        echo available devices are:
        lsblk -d -n -l -p -o NAME,VENDOR,MODEL,TYPE,SIZE /dev/sd? 
        echo "Enter SD device name (eg: sda)"
        read OUTDEV
    done


    # Check if imagefile will fit on device
    if (( $(image_size_bytes $INFILE) > $(sd_size_bytes $OUTDEV) )); then
        echo_red ERROR... Image file is larger than sd card.
        echo "Image size =$(image_size $INFILE)"
        echo "Device size=$(sd_size $OUTDEV)"
        #return
    fi
    
    
    # Check if device is large... maybe the wrong device
        if (( $(sd_size_bytes $OUTDEV) > 16000000000 )); then
        echo_red WARNING... sd card is bigger than 16GB...
        echo "$OUTDEV size=$(sd_size $OUTDEV)"
        echo
    fi


    echo This will write $INFILE to /dev/$OUTDEV
    echo_red WARNING... All existing data on /dev/$OUTDEV will be erased!
    read  -p "Are you sure you want to continue [YES,N]?" -r RESULT
    echo
    if [ $RESULT == "YES" ]; then
        
        echo Unmounting sd device ...
        umount /dev/$OUTDEV?
        
        date
        TIME1=$(date +%s)
    
        
        #INFILEEXT="${INFILE##*.}"  
        INFILEEXT=$(file_ext $INFILE)
                
        case $INFILEEXT in
            img)
                sudo dd if=$INFILE of=/dev/$OUTDEV bs=4M conv=fsync status=progress
            ;;
            
            
            zip)
                #ls -s -h $INFILE
                #zipinfo -t $INFILE
                #BYTES=$(zipinfo -t $INFILE | cut -d, -f2 | cut -d" " -f2)
                #echo $(( $BYTES / 1024 / 1024  )) MB uncompressed to write
                #printf "%'d" $(( $BYTES / 1024 / 1024  ))
                echo Writing $(image_size $INFILE) to sd card ...
                unzip -p $INFILE | sudo dd of=/dev/$OUTDEV bs=4M conv=fsync status=progress
            ;;


            xz)
                #xz --list $INFILE
                echo Writing $(image_size $INFILE) to sd card ...
                xz -v -d -c $INFILE | sudo dd of=/dev/$OUTDEV bs=4M conv=fsync status=progress
            ;;


            *)
                echo_red ERROR.  Unsupported file extension.  
            ;;

        esac        
   
        echo_white Total time $(($(($(date +%s)-TIME1))/60)) min
        echo_white  You can remove the SD card in /dev/$OUTDEV now
    fi
}



list_info() {
    echo
    echo_white  Current directory:
    echo Freespace in current directory is $(freespace)
    echo

    echo_white sd card devices:
    lsblk -d -n -l -o NAME,VENDOR,MODEL,SIZE /dev/sd? 
    echo
    echo_white Image files:
    ls -s -h -w1 *.img *.zip *.xz
}    



install_sd() {
   # echo "Installing sd v$SD_VER to /usr/local/bin/ ..."
    
    if [ -f /usr/local/bin/sd ]; then
        echo_red WARNING... sd already in /usr/local/bin. 
    fi
    
    read -p "Install sd v$SD_VER to /usr/local/bin [y,N] ? " -n 1 -r RESULT
    echo
    
    if [ $RESULT == "y" ]; then
        if [ -f /usr/local/bin/sd ]; then
            echo Renaming to /usr/local/bin/sd to sd.bak
            sudo mv /usr/local/bin/sd /usr/local/bin/sd_bak
        fi
        sudo cp $SCRIPTNAME /usr/local/bin/sd
        sudo chmod 777 /usr/local/bin/sd
    else
        echo Not installed.
    fi
}



# intro
echo "Copyright (c) 2018-2020 Richard Reed"
echo sd imager v$SD_VER

get_tools


case $1 in
    
    list)
        list_info
    ;;
    
    
    read)
          read_sd $2 $3
    ;;
    
    
    write)
          write_sd $2 $3
    ;;
    
    
    install)
        install_sd
    ;;
    
    
    *)
        help
    ;;

esac



