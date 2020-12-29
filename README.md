# sd
Raspberry Pi sd image-file reader and writer

 - Easily read an sd card and create an image file

 - Easily write an image to an sd card



TO INSTALL:

Download file:

     curl -O https://raw.githubusercontent.com/RichardMidnight/sd/main/sd.sh


Install to your /usr/local/bin folder

     sudo bash sd.sh install


USAGE:

List available sd devices and image files:

     sd list 
     

To copy your SD card to an image file called newimage.zip

     sd read sda newimage.zip
