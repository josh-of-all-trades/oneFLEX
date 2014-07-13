server.log("HELLO");

// create a global variabled called led, 
// and assign pin2 to it
theLedAndContactPin <- hardware.pin9;
flex <- hardware.pin7;
g_Z <- hardware.pin1;
g_Y <- hardware.pin2;
g_X <- hardware.pin5;



// configure led to be a digital output
theLedAndContactPin.configure(DIGITAL_OUT);
theLedAndContactPinMode <- "LED";


PS_voltage <- hardware.voltage();
server.log("PS_voltage = "+PS_voltage);

// configure flex sensor as analog input
flex.configure(ANALOG_IN);
g_Z.configure(ANALOG_IN);
g_Y.configure(ANALOG_IN);
g_X.configure(ANALOG_IN);


// Set global variables
deviceState <- 0;


// simple functions
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
    if(theLedAndContactPinMode == "LED"){
        flipLed();
        imp.wakeup(duration, flipLed);
        return true;
    }
    return false;
}

function flipLed(){ //ONLY call from blinkLed
    local currentState = theLedAndContactPin.read();
    local newState;
    if(currentState == 1){
        newState = 0;
    }
    else if(currentState == 0){
        newState = 1;
    }
    theLedAndContactPin.write(newState);
}



// sensor data functions
function sampleFlex(mode)
{
    local voltage = hardware.voltage();
    local flexReading = (flex.read() / 65535.0) * voltage;
    if(mode == 0){
        // bit (state) mode
        local flexOnState;
        if (flexReading > 0.5){
            flexOnState = 1;
        }
        else{
            flexOnState = 0;
        }
        return flexOnState;
    }
    if(mode == 1){
        return flexReading;
    }
}


function sampleGyro(mode)
{
    local voltage = hardware.voltage();
    local X_state = (g_X.read() / 65535.0) * voltage - 1.666;
    local Y_state = (g_Y.read() / 65535.0) * voltage - 1.666;
    local Z_state = (g_Z.read() / 65535.0) * voltage - 1.666;
    
    local theta = math.asin(max(min(X_state / 0.333, 1), -1)) * 180 / 3.14159;
    local phi = math.asin(max(min(Y_state / 0.333, 1), -1)) * 180 / 3.14159;
    
    // server.log("Gyro state: (" + X_state + ", "+Y_state + ", "+Z_state+")");
    // server.log(theta);
    // server.log(phi);
    // server.log(theta*theta + phi*phi);

 
    if(mode == 0){
        // bit (state to on) call
        // compute state of gyroscope w.r.t. activation
        local gyroOnState;
        if(theta*theta + phi*phi <=150 && Z_state >= 0.25){
            gyroOnState = 1;
        }
        else{
            gyroOnState = 0;
        }
        return(gyroOnState);
    }
    
    if(mode == 1){
        // verbose call
        return([[X_state, Y_state, Z_state], [theta, phi]]);
    }
    
    if(mode == 2){
        // bit (state to off) call
        // compute state of gyroscope w.r.t. deactivation
        local gyroOffState;
        if(theta*theta <= 50 && phi >= 60){
            gyroOffState = 1;
        }
        else{
            gyroOffState = 0;
        }
        return(gyroOffState);
    }
}

// contact sensor function
function sampleContact()
{
    local voltage = hardware.voltage();
    local contactReading = (theLedAndContactPin.read() / 65535.0) * voltage;
    local contactState;
    if(contactReading >= 2.0 ){
        contactState = 1;
    }
    else{
        contactState = 0;
    }
    return contactState;
}


// poll device configuration for correct state
function checkState() {
  if(deviceState == 0 || deviceState == 2){
    //   check if primed to move into mode 1, noncontact gesture mode, or mode 2, contact gesture mode
      if(sampleFlex(0) == 1){
        // if flex sensor bent
        if(sampleGyro(0) == 1){
            // and if sampleGyro returns true in bit mode 0
            
            // we are to move into noncontact gesture mode
            // need to use LED
            theLedAndContactPin.configure(DIGITAL_OUT);
            theLedAndContactPinMode = "LED";
            theLedAndContactPin.write(1);
            deviceState = 1;
            server.log("Noncontact Interface Active")
            agent.send("stateUpdate", deviceState);
        }
        else if((g_Z.read() / 65535.0) * hardware.voltage() - 1.666 <= -0.30  && deviceState != 2){
            // ie, if device is upside down in addition to being flexed, then we are 
            // device is in contact state
            theLedAndContactPin.configure(ANALOG_IN);
            theLedAndContactPinMode = "CONTACT";
            deviceState = 2;
            server.log("Contact Interface Active")
        }
      }
        
  }
  else if(deviceState == 1){
    // then we are active in noncontact gesture interface
    if(sampleFlex(0) == 1){
        // if flex sensor is bent, then we may change modes
        if(sampleGyro(2) == 1){
            // if gyro returns vertical (fist back), move to inactive mode
            // turn led off
            theLedAndContactPin.configure(DIGITAL_OUT);
            theLedAndContactPin.write(0);
            deviceState = 0;
            server.log("Interface Inactive")
            agent.send("stateUpdate", deviceState);
        }
        else if((g_Z.read() / 65535.0) * hardware.voltage() - 1.666 <= -0.30){
            // ie, if device is upside down in addition to being flexed, then we are 
            // device is in contact state
            theLedAndContactPin.configure(ANALOG_IN);
            theLedAndContactPinMode = "CONTACT";
            deviceState = 2;
            server.log("Contact Interface Active")
        }
    }
  }
    if(deviceState == 2){
        if(sampleFlex(0) == 1){
            // if flex sensor is bent, then we may change modes
            if(sampleGyro(2) == 1){
                // if gyro returns vertical (fist back), move to inactive mode
                // turn led off
                theLedAndContactPin.configure(DIGITAL_OUT);
                theLedAndContactPin.write(0);
                deviceState = 0;
                server.log("Interface Inactive")
                agent.send("stateUpdate", deviceState);
            }
        }
    }
//   we want delay between state change gesture and response to be < 1/2 s
  imp.wakeup(0.5, checkState);
}

checkState();


function dataCollect()
{
    if(deviceState == 0){
        // do nothing
        // server is told device is inactive by shutdown function
        
        // try again in 1s
        imp.wakeup(1.0, dataCollect);
    } 
    if(deviceState == 1){
        local flex_value = sampleFlex(1);
        local gyro_data = sampleGyro(1); 
        agent.send("dataUpdate", [deviceState, flex_value, gyro_data])
        // server.log([flex_value, gyro_data]);
        // collect data again in .025s
        imp.wakeup(0.025, dataCollect);
    }
    if(deviceState == 2){
        local contactState = sampleContact();
        agent.send("dataUpdate", [deviceState, contactState]);
        // collect data again in .025s
        imp.wakeup(0.025, dataCollect);
    }
}

dataCollect();


agent.on("blinkLed", blinkLed);

// prototype for device inactive state:
// agent.send("stateUpdate", deviceState); where deviceState = 0
