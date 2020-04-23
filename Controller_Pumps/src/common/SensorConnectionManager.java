
package common;

import java.io.IOException;
import org.openmuc.j60870.ASdu;
import org.openmuc.j60870.CauseOfTransmission;
import org.openmuc.j60870.IeNormalizedValue;
import org.openmuc.j60870.IeQualifierOfSetPointCommand;
import org.openmuc.j60870.IeShortFloat;


public class SensorConnectionManager extends ConnectionManager {

    protected int id_sensor_data_callback;
    protected ControllerInterface ctl;   
    
    public SensorConnectionManager(String ip, int port, int commonAddressParameter, String name){
    
        host_param=getNewHostParameter(ip);
	port_param=getNewPortParameter(port);
	commonAddrParam=getNewCommonAddressParameter(commonAddressParameter);
    
        instance_counter++;
	name=name+"_"+instance_counter;
        try {
            locked_logger= new LockedLogger("./logs",name);
        }
        catch (Exception e) {  
            locked_logger = null;
        }
	connection=null;
        silence=false;
    }
    
    //CALLBACK MANAGEMENT    
    public void registerSensorDataCallback(ControllerInterface new_ctl,int new_id) {
	if(new_id <0 || new_ctl ==null)
	    return;
	//if a callback was already present, we resign it
	resetAndResignSensorDataCallback();
	id_sensor_data_callback=new_id;
	ctl=new_ctl;
    }
    
    public boolean hasValidCallback() {
	return ctl!=null && id_sensor_data_callback >=0;
    }
    
    public void resetAndResignSensorDataCallback(){
	//if a callback was already present, we resign it
	if(hasValidCallback())
	    ctl.resetSCCMPair(id_sensor_data_callback);
	ctl=null;
	id_sensor_data_callback=-1;	
    }
    
    public void callbackCtl(double value){
	if (hasValidCallback())
	    ctl.setLatestSensorLevel(value, id_sensor_data_callback);		
    }
    
    
    public int getIdSensorDataCallback(){
        return id_sensor_data_callback;
    }
    
    //LISTENING       
    /*
    * ASDU's informations received by the server 
    */
     @Override
     public void newASdu(ASdu aSdu) {
	 try {
	     boolean do_default=false;
	     switch (aSdu.getTypeIdentification()) {

		// received the answer to interrogation command (short float value)
		 case M_ME_NC_1:			
		    //value in which the activation flags are stored
		    IeShortFloat distance_received = (IeShortFloat) aSdu.getInformationObjects()[0].getInformationElements()[0][0];
		    //printWithName("Received measured distance:"+Float.toString(distance_received.getValue()));
		    callbackCtl(distance_received.getValue());
                    locked_logger.log(Float.toString(distance_received.getValue()));
                    //current_level.setText("Current level: "+distance_received.getValue());
		    break;
                    
                case C_SC_NA_1:
                    if (aSdu.getCauseOfTransmission()== CauseOfTransmission.ACTIVATION_CON)
                        printWithName("Got end server command confirmation. Server will stop gracefully after next disconnection \n");	
		    else
			do_default=true;
                    break;

                // interrogation command 
		case C_IC_NA_1:
		    if (aSdu.getCauseOfTransmission()== CauseOfTransmission.ACTIVATION_CON)
			//printWithName("Received confirmation of activation order:interrogation command ");
                        break;
		    else
			do_default=true;
		    break;

		// Action command
		case C_SE_NA_1://activation floating point command
		    if (aSdu.getCauseOfTransmission()== CauseOfTransmission.ACTIVATION_CON)
			//printWithName("Received confirmation of activation order:Action command");
                        break;			
		    else
			do_default=true;
		    break;

		 default:
		    do_default=true;
		    break;
	     }
	     if (do_default)
		 printWithName("Got unknown request: " + aSdu + "\n");
	 } catch (Exception e) {
	     printWithName("Will quit listening for commands on connection because of error: \"" + e.getMessage() + "\".");
	 } 

    }

    @Override
    public void connectionClosed(IOException e) {
	printWithName("Received connection closed signal. Reason: ");
	if (!e.getMessage().isEmpty()) {
	    printWithName(e.getMessage());
	}
	else {
	    printWithName("unknown");
	}
	connection.close();
    }
    
    
    //SENDING
    public void sendLedOff() {
	if(connection==null)
	    return;
        printNewLine();
	printWithName("** Sending 'LED OFF' command. **");
	try {
	connection.setNormalizedValueCommand(commonAddrParam.getValue(), 
		CauseOfTransmission.ACTIVATION, 2, new IeNormalizedValue(-1), 
		new IeQualifierOfSetPointCommand(0,false));
	} catch (IOException e1) {
		e1.printStackTrace();
	}
    }
    
    public void sendLedOn(){
	if(connection==null)
	    return;
        printNewLine();
	printWithName("** Sending 'LED ON' command. **");
	try {
	connection.setNormalizedValueCommand(commonAddrParam.getValue(), 
		CauseOfTransmission.ACTIVATION, 2, new IeNormalizedValue(1), 
		new IeQualifierOfSetPointCommand(0,false));
	} catch (IOException e1) {
		e1.printStackTrace();
	}
    }

    @Override
    public void sendCloseConnection(){
	sendLedOff();
	super.sendCloseConnection();	
    }
    
    
    
}

