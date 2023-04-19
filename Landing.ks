print(ADDONS:TR:AVAILABLE). //Checking if Correct mods are downloaded
set gearoffset to 7. //Height of rocket on the ground when gear is down
lock trueRadar to alt:radar - gearoffset. //Getting distance from gear to ground
lock g to constant:g * body:mass / body:radius^2. //Get current planet gravity in ms^2
lock maxThrottle to (ship:availablethrust / ship:mass) - g. //Max trust ever needed
lock burnHeight to ship:verticalspeed^2 / (2* maxThrottle). //Needed Height for Hover slam
lock throttlePID to burnHeight / trueRadar. //Throttle required to make a soft landing
lock impactTime to trueRadar / abs(ship:verticalspeed).

lock landingTarget to latlng(0,0). //Landing pad Lat/Lng

//Launch Prep
create(Lauch.log).
log "Starting Lat" + landingTarget:lat to Lauch.log.
log "Starting Lng" + landingTarget:lng to Lauch.log.

//Launch
wait until ag1.
lock throttle to 1.
stage.
lock steering to up.

//Ascent 
wait until alt:apoapsis >= 10000.
lock throttle to 0.
rcs on.

//Landing Prep
wait until ship:verticalspeed <= -1.
toggle brakes.
lock landingOffset to landingTarget - ship:position. 
lock steering to latlng(landingOffset).
print(round(landingOffset)).

//Hover slam
wait until trueRadar < burnHeight.
lock throttle to throttlePID.
when impactTime <= 3 then {gear on.}.
wait until ship:verticalspeed <= -.01.
lock throttle to 0.
print("Hover Slam Complete").
rcs off.
brakes off.