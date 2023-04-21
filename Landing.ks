print(ADDONS:TR:AVAILABLE). //Checking if Correct mods are downloaded
set gearoffset to 7. //Height of rocket on the ground when gear is down
lock trueRadar to alt:radar - gearoffset. //Getting distance from gear to ground
lock g to constant:g * body:mass / body:radius^2. //Get current planet gravity in ms^2
lock maxThrottle to (ship:availablethrust / ship:mass) - g. //Max thrust ever needed
lock burnHeight to ship:verticalspeed^2 / (2* maxThrottle). //Needed Height for Hover slam
lock throttlePID to burnHeight / trueRadar. //Throttle required to make a soft landing
lock impactTime to trueRadar / abs(ship:verticalspeed). //At what time should we burn :|
set landingTarget to latlng(0,0). //Landing pad Lat/Lng
lock aoa to 32.
//This script was made by 3dprinted1, https://www.youtube.com/channel/UC9VmsrN53RzjX8ests54s6Q
function getImpact {
    if addons:tr:hasimpact { return addons:tr:impactpos. }         
        return ship:geoposition.
}
function lngError {                                    
    return getImpact():lng - landingTarget:lng.
}
function latError {
    return getImpact():lat - landingTarget:lat.
}

function errorVector {
    return getImpact():position - landingTarget:position.
}

function getSteering {            
    local errorVector is errorVector().
        local velVector is -ship:velocity:surface.
        local result is velVector + errorVector*1.
        if vang(result, velVector) > aoa
        {
            set result to velVector:normalized
                          + tan(aoa)*errorVector:normalized.
        }

        return lookdirup(result, facing:topvector).
    }
//Launch Prep
brakes off.
rcs off.
gear off.
panels off.

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
lock steering to latlng(getSteering()).


//Hover slam
wait until trueRadar < burnHeight.
lock throttle to throttlePID.
gui:addlabel:text(throttlePID).
lock aoa to -6.
when impactTime <= 3 then {gear on.}.
wait until ship:verticalspeed <= -.01.
lock throttle to 0.
print("Hover Slam Complete").
rcs off.