// Log the URLs we need
// server.log("Turn LED On: " + http.agenturl() + "?led=1");
// server.log("Turn LED Off: " + http.agenturl() + "?led=0");

// binary
deviceState <- 0;

// floating point
flex <- 0;
gyroX <- 0;
gyroY <- 0;
gyroZ <- 0;
theta <- 0;
phi <- 0;

contactState <- 0;

// guestures
activeGesture <- 0;

// simple functions
function abs(val){
    if(val < 0){
        return -1 * val;
    }
    else{
        return val;
    }
}

function sign(val){
    if(val > 0){
        return 1;
    }
    if(val < 0){
        return -1;
    }
    if(val == 0){
        return 0;
    }
}
function max(arg1, arg2){
    if(arg1 >= arg2){
        return arg1;
    }
    else{
        return arg2;
    }
}

function min(arg1, arg2){
    if(arg1 <= arg2){
        return arg1;
    }
    else{
        return arg2;
    }
}

// user feedback functions
function blinkLed(duration){
    device.send("blinkLed", duration);
}



// JSON server
function requestHandler(request, response) {
  try {
    Data <- [];
    // check if the user sent led as a query parameter
    if ("STATE" in request.query) {
        Data.push(["STATE",deviceState.tostring()]);
    }
    
    if("FLEX" in request.query) {
        Data.push(["FLEX",flex.tostring()]);
    }
    
    if("GYROX" in request.query) {
        Data.push(["GYROX",gyroX.tostring()]);
    }
    
    if("GYROY" in request.query) {
        Data.push(["GYROY",gyroY.tostring()]);
    }

    if("GYROZ" in request.query) {
        Data.push(["GYROZ",gyroZ.tostring()]);
    }
    
    if("THETA" in request.query) {
        Data.push(["THETA",theta.tostring()]);
    }
    
    if("PHI" in request.query) {
        Data.push(["PHI",phi.tostring()]);
    }
    
    if("GESTURE" in request.query) {
        Data.push(["GESTURE",activeGesture.tostring()]);
        activeGesture = 0;
    }
    
    
    local agentResponse = "{";
    for(local i = 0; i < Data.len(); i+=1){
        agentResponse += "\"" + Data[i][0] + "\"" + ":" + Data[i][1];
        if(i < Data.len() - 1){
            agentResponse += ",\n"
        }
        else{
            agentResponse += "}";
        }
    }
    
    response.send(200, agentResponse);
  } catch (ex) {
    response.send(500, "Internal Server Error: " + ex);
  }
}
 
 
function deviceStatusHandler(status_update){
    deviceState = status_update;
    // if(status_update == 0){
        
    // }
}

function deviceDataHandler(data_array){
    deviceState = data_array[0]

    if(deviceState == 1){
        flex = data_array[1];
        
        local gyro_data = data_array[2];    

        gyroX = gyro_data[0][0];
        gyroY = gyro_data[0][1];
        gyroZ = gyro_data[0][2];
        theta = gyro_data[1][0];
        phi = gyro_data[1][1];
        
        watchGestures();
    }
    else if(deviceState == 2){
        //contct mode
        contactState = data_array[1];
        watchGestures();
    }
}        

inGesture <- false;
lastThetaInside <- 0;
peakTheta <- 0;

inContactGesture <- false;


// the fun part
function watchGestures()
{
    if(deviceState == 1){
    // it is known that deviceState == 1 or == 2 if deviceDataHandler is called
    if(theta*theta + phi*phi <=150){
        // in home position
        
        // if this is the first reading
        // inside the home position after a gesture,
        // compare reentry theta sign to exit theta sign
        if(inGesture){
            // then the gesture had correct form
        
            // now check if the hand turned far enough
            if(abs(peakTheta) >= 40){
                activeGesture = -1 * sign(peakTheta);
                blinkLed(0.2);
            }
            
        
            inGesture = false;
        }
        
    }
    else{
        // out of home position
        
        // if this is the first reading
        // outside the home position (ie, initiating a gesture),
        
        if(!inGesture){
            inGesture = true;
            // record theta exit
            lastThetaInside = theta;
            // start counting up peakTheta
            peakTheta = theta;
        }
        
        if(inGesture){
            // gesture is in progress
            if(sign(theta) == sign(peakTheta) && abs(theta) > abs(peakTheta)){
                // update peakTheta
                peakTheta = theta;
            }
        }
        
        
    }
    }
    else if(deviceState == 2){
        // contact mode
        if(contactState == 1){
            // in gesture
            if(inContactGesture == false){
                // first reading on contact
                // set gesture to 1
                server.log("activating contact gesture");
                activeGesture = 1;
                inContactGesture = true;
            }
            // else if(inContactGesture == true){
                // already known to be touching
                // do nothing
            // }
        }
        else if(contactState == 0){
            // then contacts not touching
            inContactGesture = false;
            // note we leave any pushed activeGesture alone until intercepted by phone
        }
    }
}


// register the handlers
http.onrequest(requestHandler);
device.on("stateUpdate", deviceStatusHandler);
device.on("dataUpdate", deviceDataHandler);

