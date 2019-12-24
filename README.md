# berp-easy-install
```
8 888888888o   8 8888888888   8 888888888o.   8 888888888o   
8 8888    `88. 8 8888         8 8888    `88.  8 8888    `88. 
8 8888     `88 8 8888         8 8888     `88  8 8888     `88 
8 8888     ,88 8 8888         8 8888     ,88  8 8888     ,88 
8 8888.   ,88' 8 888888888888 8 8888.   ,88'  8 8888.   ,88' 
8 8888888888   8 8888         8 888888888P'   8 888888888P'  
8 8888    `88. 8 8888         8 8888`8b       8 8888         
8 8888      88 8 8888         8 8888 `8b.     8 8888         
8 8888    ,88' 8 8888         8 8888   `8b.   8 8888         
8 888888888P   8 888888888888 8 8888     `88. 8 8888
  Beyond         Earth          Role            Play
===[ B.E.R.P EASY (FOR YOU!) FIVEM DEPLOYMENT SCRIPT ]===
```
The 10 Minute From-Scratch Deployment Script, created for Beyond Earth Roleplay (BERP). 
Join us on FiveM! Look us up in the directory... the server is free reign rp!

This script will deploy cFX FiveM, txAdmin, & MariaDB(MySQL) w/ phpMyAdmin...  
FiveM deploys with EssentialMode and ESX with over 150 working modules.  

The whole thing takes about 10-15 minutes to deploy everything; mostly automated with
some input required the first time you deploy it to gen the config file. This is
the script that handles my runtime deployment.  I build the full server from scratch, 
each time I bounce my VPS... so this works amazing!  It has to... cause otherwise 
the server is offline. hahah.

You will need to deploy an image of Debian 10 (Buster) for this to work flawless.

The VPS I am using is Zap-Hosting... so if you have their VPS too, just use thier
Debian 10 image. That is what I've used for all my testing.  It works great!

Once you've deployed the server, connect to txAdmin and configure it... shouldn't
be too hard.  

```
The FXServer tab of the config should be like:
Build Path: /home/fivem/
 Base Path: /home/fivem/server-data/
  CFG Path: server.cfg
 autostart: enable
quiet mode: enable
```

Once you've doen this... don't start the server yet.  Go into your shell and run,  backup-txadmin.sh.  This will store the config data from txAdmin with the deployment scripts...  don't worry, there is a .gitignore for this folder and the config.json file.  If you want to store these on github, you'll have to put them somewhere private.

For those that are not using Zap-Hosting, you should still be okay as long as you
use the same build version they are using.  This script is not dependant on anything
zap-hosting... i just haven't done very limited testing elsewhere. For the image,
I think I was using 10.2... pretty sure... but any version 10 should work.  It will 
not work to try ubuntu (or another debian flavor) and I do not suggest trying it,
unless you plan to alter this all to work with it.  If you do... fork this repo!
Don't ask me for help though... It's up to you now! I believe in you...!!!

DO NOT RELEASE THIS SCRIPT AS YOUR OWN AND ATTEMPT TO TAKE CREDIT.
THAT WILL NOT END WELL FOR YOU- LEARN TO DO SOMETHING REAL WITH YOUR LIFE!

THIS SCRIPT WAS NEARLY 100% CODED BY BEYOND EARTH.  TOOK A TON OF TIME TO TEST!
I SAY NEARLY, BECAUSE I DID TAKE SNIPITS HERE AND THERE... GUESS WHAT, I'VE CREDITED
THEM IN THE SCRIPT! THAT IS WHAT A GOOD DEVELOPER DOES, GIVES CREDIT TO OTHERS.

HAVE SOME RESPECT!

If you edit the functionality of this script at all... I expect a fork!
