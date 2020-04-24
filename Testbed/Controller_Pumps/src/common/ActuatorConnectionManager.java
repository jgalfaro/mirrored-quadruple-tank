/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package common;
/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

import java.io.IOException;
import org.openmuc.j60870.ASdu;
import org.openmuc.j60870.CauseOfTransmission;
import org.openmuc.j60870.IeQualifierOfSetPointCommand;
import org.openmuc.j60870.IeScaledValue;
import pumps_control.TernaryPump;
import pumps_control.GroupTernaryPumpsMessageBuilder;
import pumps_control.GroupTernaryPumpsMessageInterpreter;
import pumps_control.GroupTernaryPumpsStates;


public class ActuatorConnectionManager 
	extends ConnectionManager {

    //bulder for the messages that have to be sent
    protected GroupTernaryPumpsMessageBuilder builder;    
    //states we will use to store values
    protected GroupTernaryPumpsStates states;
    
    public ActuatorConnectionManager(String ip, int port, int commonAddressParameter, String name){
    
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
        
        builder= new GroupTernaryPumpsMessageBuilder();    
	states=new GroupTernaryPumpsStates();
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
                                     
                case C_SC_NA_1:
                    if (aSdu.getCauseOfTransmission()==CauseOfTransmission.ACTIVATION_CON)
                        printWithName("Got end server command confirmation. Server will stop gracefully after next disconnection \n");	
		    else
			do_default=true;
                    break;

		 // received the answer to interrogation command (scaled value)
		 case M_ME_NB_1:			
		    //value in which the activation flags are stored
		    IeScaledValue scaledValue = (IeScaledValue) aSdu.getInformationObjects()[0].getInformationElements()[0][0];
		    //let's convert the received bytes into the states that our pumps should have now
		    states=GroupTernaryPumpsMessageInterpreter.getStatesFromMsg((short)scaledValue.getUnnormalizedValue());
		    printWithName("Received pump states: " + states.toString());
                    //value_latest_received_pumpstate.setText(states.toString());
		    break;

	     // interrogation command 
		case C_IC_NA_1:
		    if (aSdu.getCauseOfTransmission()==CauseOfTransmission.ACTIVATION_CON)
			printWithName("Received confirmation of activation order: interrogation command ");			
		    else
			do_default=true;
		    break;


		// Action command
		case C_SE_NB_1://scaled command
		    if (aSdu.getCauseOfTransmission()==CauseOfTransmission.ACTIVATION_CON)
			printWithName("Received confirmation of activation order: Action command");			
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
    
        
    public void activatePumps(boolean pump1, boolean pump2, boolean pump3, boolean pump4){
        if(connection==null)
	    return;
        
        if (pump1)
            states.state_pump_1=TernaryPump.TERNARY_PUMP_STATE.FORWARD;
        else 
             states.state_pump_1=TernaryPump.TERNARY_PUMP_STATE.OFF;
        
        if (pump2)
            states.state_pump_2=TernaryPump.TERNARY_PUMP_STATE.FORWARD;
        else 
            states.state_pump_2=TernaryPump.TERNARY_PUMP_STATE.OFF;
        
        if (pump3)
            states.state_pump_3=TernaryPump.TERNARY_PUMP_STATE.FORWARD;
        else 
            states.state_pump_3=TernaryPump.TERNARY_PUMP_STATE.OFF;
        
        if (pump4)
            states.state_pump_4=TernaryPump.TERNARY_PUMP_STATE.FORWARD;
        else 
            states.state_pump_4=TernaryPump.TERNARY_PUMP_STATE.OFF;
            
               
        try {
		sendPumpStatesCommand(states);
	} catch (IOException e1) {
	    printWithName(e1.getMessage());
	}
    }
            
            
    @Override
    public void sendCloseConnection(){
        
	activatePumps(false, false, false, false);
	super.sendCloseConnection();	
    }

    
    protected  void sendPumpStatesCommand(GroupTernaryPumpsStates states) throws IOException
    {
	if(connection==null)
	    return;
        locked_logger.log(states.toString());
	builder.setMessagePumpState(states);
	short command=builder.getMessage();
	connection.setScaledValueCommand(commonAddrParam.getValue(), 
	    CauseOfTransmission.ACTIVATION, 2, new IeScaledValue(command), 
	    new IeQualifierOfSetPointCommand(0,false)
	);
	printWithName("** Sending Motor command: "+states.toString()+" **\n");
       
    }
}

